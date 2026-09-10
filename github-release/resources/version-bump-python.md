# Version-bump mechanics: Python (`pyproject.toml`/`uv.lock`)

Use this if the repo being released uses `uv`/`pyproject.toml` for Python
packaging. Performed as a single commit, typically the last one on the
feature branch before pushing, once `build-verify-interpreted.md` is green.

## The version-bump sequence

All three of the following belong in the **same PR** that merges to reach
the release state — not a follow-up commit after the tag:

1. Retitle `CHANGELOG.md`'s `[Unreleased]` section to the new version and
   date (per the parent skill's policy spine).
2. Bump `pyproject.toml`'s `version` field to match.
3. Run `uv lock` so `uv.lock`'s own package entry picks up the same version.

**Don't skip step 3.** `uv.lock`'s version can silently drift from
`pyproject.toml` across releases, because CI typically runs `uv sync
--frozen` (installs exactly what's pinned, no staleness check) rather than
`--locked`, which would catch a mismatch. Nothing else catches this — it's on
the release step to get it right.

If this repo instead uses `setup.py`/`setuptools` or Poetry, the same
same-PR/no-drift principle applies to whatever files those tools use to
track the version (`setup.cfg`, `poetry.lock`) — the `uv.lock` gotcha above
is the concrete instance of a general rule: any lockfile that embeds a
version needs the same bump, in the same commit, as the manifest it locks.
