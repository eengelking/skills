# Build/test verification: interpreted languages (Python, Node/TypeScript, ...)

There's no separate compile step that catches errors tests don't, so the test
suite carries the whole weight of "verified" here. Don't skip it or run a
narrowed subset for release purposes.

## Sequence

1. **Run the full test suite**, not just the files this change touched.
   - Python: `pytest` (or this repo's configured runner — `uv run pytest`,
     `tox`, etc.)
   - Node/TypeScript: `npm test` / `pnpm test` / `yarn test`, per this repo's
     package manager.
2. **If this repo type-checks** (TypeScript, or Python with `mypy`/`pyright`),
   run that too — a type error is a real defect even though nothing here
   "compiles" in the traditional sense.
   - TypeScript: `tsc --noEmit` (or this repo's build script, if it bundles)
   - Python: `mypy .` / `pyright`, whichever this repo has configured
3. **If TypeScript is bundled/transpiled for distribution** (a library
   published to npm, a frontend build, etc.), run that build step and confirm
   it exits clean — even though the language itself doesn't require it, the
   *artifact* being published does.

A red test, type-check, or build is treated exactly like any other CI
failure: never push past it, and don't proceed to the version-bump or
publish steps until it's resolved.
