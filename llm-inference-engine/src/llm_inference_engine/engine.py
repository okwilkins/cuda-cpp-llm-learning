import torch
from transformers import AutoModelForCausalLM, AutoTokenizer


class InferenceEngine:
    def __init__(self, model_name: str, dtype: torch.dtype = torch.bfloat16):
        tokenizer = AutoTokenizer.from_pretrained(model_name)
        if tokenizer is None:
            raise RuntimeError("Could not create tokenizer!")
        else:
            self.tokenizer = tokenizer

        self.model = AutoModelForCausalLM.from_pretrained(
            model_name,
            dtype=dtype,
            device_map="cuda",
        )

        self.model.eval()
        self.device = self.model.device

    @torch.inference_mode()
    def generate(
        self,
        prompt: str,
        max_new_tokens: int = 128,
        temperature: float = 0.7,
        top_p: float = 0.9,
        do_sample: bool = True,
    ) -> str:
        """Generate LLM outputs for a given set of prompts."""
        inputs = self.tokenizer(prompt, return_tensors="pt").to(self.device)
        input_ids = inputs["input_ids"]
        generated_ids = input_ids.clone()
        prompt_length = input_ids.shape[1]

        # Prefill stage
        outputs = self.model(**inputs, use_cache=True)
        past_key_values = outputs.past_key_values

        next_token = self._sample_next_token(
            outputs.logits[:, -1, :],
            temperature,
            top_p,
            do_sample,
        )
        generated_ids = torch.cat([generated_ids, next_token], dim=1)
        if next_token.item() == self.tokenizer.eos_token_id:
            return self.tokenizer.decode(generated_ids[0], skip_special_tokens=True)

        # Decode stage
        for _ in range(max_new_tokens - 1):
            outputs = self.model(
                input_ids=next_token,
                past_key_values=past_key_values,
                use_cache=True,
            )
            past_key_values = outputs.past_key_values

            next_token = self._sample_next_token(
                outputs.logits[:, -1, :], temperature, top_p, do_sample
            )
            generated_ids = torch.cat([generated_ids, next_token], dim=1)

            if next_token.item() == self.tokenizer.eos_token_id:
                break

        new_tokens = generated_ids[0, prompt_length:]
        return self.tokenizer.decode(new_tokens, skip_special_tokens=True).strip()

    def _sample_next_token(
        self,
        logits: torch.Tensor,
        temperature: float,
        top_p: float,
        do_sample: bool,
    ) -> torch.Tensor:
        """Sample or argmax the next token from logits."""

        if do_sample:
            logits = logits / temperature
            probs = torch.softmax(logits, dim=-1)

            sorted_probs, sorted_indices = torch.sort(probs, descending=True)
            cumsum = torch.cumsum(sorted_probs, dim=-1)
            sorted_indices_to_remove = cumsum > top_p
            sorted_indices_to_remove[..., 1:] = sorted_indices_to_remove[..., :-1].clone()
            sorted_indices_to_remove[..., 0] = False

            indices_to_remove = sorted_indices_to_remove.scatter(
                1, sorted_indices, sorted_indices_to_remove
            )
            probs = probs.masked_fill(indices_to_remove, 0.0)
            probs = probs / probs.sum(dim=-1, keepdim=True)

            next_token = torch.multinomial(probs, num_samples=1)
        else:
            next_token = torch.argmax(logits, dim=-1, keepdim=True)
        return next_token

