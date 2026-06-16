import os

from llm_inference_engine.engine import InferenceEngine

if __name__ == "__main__":
    MODEL_PATH = os.environ.get("MODEL_PATH")

    if MODEL_PATH is None:
        print("No MODEL_PATH env variable was supplied!")
        exit(1)
    else:
        print(f"Loading in model from: {MODEL_PATH}")

    engine = InferenceEngine(model_name=MODEL_PATH)

    messages = []
    print("Type 'exit' or 'quit' (q) to stop.\n")

    while True:
        user_input = input("Input: ").strip()
        if user_input.lower() in ("exit", "quit", "q"):
            break

        messages.append({"role": "user", "content": user_input})
        prompt = engine.tokenizer.apply_chat_template(
            messages,
            tokenize=False,
            add_generation_prompt=True,
        )

        output = engine.generate(
            prompt,
            max_new_tokens=256,
            temperature=0.7,
            top_p=0.9,
            do_sample=True,
        )

        print(f"\nAssistant: {output}\n")

        messages.append({"role": "assistant", "content": output})

