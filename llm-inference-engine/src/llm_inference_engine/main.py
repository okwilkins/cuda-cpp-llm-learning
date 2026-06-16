import os

import torch
from transformers import AutoModelForCausalLM, AutoTokenizer

if __name__ == "__main__":
    MODEL_PATH = os.environ.get("MODEL_PATH")

    if MODEL_PATH is None:
        print("No MODEL_PATH env variable was supplied!")
        exit(1)
    else:
        print(f"Loading in model from: {MODEL_PATH}")

    tokenizer = AutoTokenizer.from_pretrained(
        MODEL_PATH,
        local_files_only=True,
        trust_remote_code=True,
    )
    model = AutoModelForCausalLM.from_pretrained(
        MODEL_PATH,
        dtype=torch.bfloat16,
        device_map="cuda",
        trust_remote_code=True,
        local_files_only=True,
    )

    print("Loaded model!")

