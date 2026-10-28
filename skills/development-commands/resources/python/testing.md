# Python: uv-managed venv, tests, lint

If the repo is `uv`-managed (a `uv.lock` and `pyproject.toml` at the root), its
tools — `pytest`, `ruff`, etc. — live in `.venv/` and are **not** on `PATH`
outside it. Create/update it with `uv sync` (include dev extras if the repo
defines them), then either `source .venv/bin/activate` or prefix each command
with `.venv/bin/` (e.g. `.venv/bin/ruff check .`).

```bash
pytest                                        # full suite
pytest path/to/test_file.py::test_name -x     # single test, stop on first failure
ruff check . && ruff format --check .         # lint + format check
ruff format .                                 # auto-fix formatting, then re-check
```

**`ruff check` passing does not mean `ruff format --check` also passes** — they
check different things (lint rules vs. formatting) and are independent. If this
repo's CI runs both as separate steps, run both locally before opening or
pushing to a PR, not just `check`. If `ruff format --check` fails, run
`ruff format .` to fix it, then re-run `ruff format --check .` to confirm.

Coverage targets, required test cases, and any project-specific scripts
(`python -m scripts.*` or similar) are this repo's own — check its
CONTRIBUTING doc or CLAUDE.md for the authoritative list rather than
guessing from another project's script names.
