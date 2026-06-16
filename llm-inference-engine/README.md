# llm-inference-engine

LLM inference engine.

## Getting Started

### Enter the Dev Shell

All tools (Python 3.14, uv, ruff, ty) come from Nix.

```bash
cd llm-inference-engine
nix develop --command $SHELL
```

### Download the Model

The model used by this project can be downloaded with:

```bash
download-model
```


### Sync the Project

```bash
uv sync
```

This creates `.venv` and installs the project (editable).

### Common commands

- Lint: `ruff check .`
- Format: `ruff format .`
- Type check: `ty check .`

Use `uv run` to execute anything inside the managed environment:

```bash
uv run python path/to/script.py
```

## Adding dependencies

```bash
# Runtime
uv add <package>

# Dev only (then re-sync)
# Edit [dependency-groups] dev in pyproject.toml, then:
uv lock
uv sync
```
