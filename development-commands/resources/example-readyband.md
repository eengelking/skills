# Example: readyband certifications app

A concrete instance of the generic patterns in this skill, as applied to the
readyband certifications app. This is a worked example, not a template —
don't copy these specific commands/paths into a different project; use them
as a reference for how the generic patterns cash out in practice.

## Tooling

`uv`-managed Python (see `resources/python-testing.md` for the generic
`.venv`/`pytest`/`ruff` pattern). Project-specific scripts, run the same way:

```bash
python -m scripts.validate_content
python -m scripts.load_content
python -m scripts.check_distractor_bias   # add --refs GLOB or --since GIT_REF to scope a deepening
                                           # pass to just its own new/changed refs, --verbose for full
                                           # ref lists (see content-authoring skill)
python -m scripts.check_command_regex --verbose
python -m scripts.check_exam_currency --verbose   # add --as-of YYYY-MM-DD to preview a future date
python -m scripts.backup_db
python -m scripts.seed_demo
```

See this repo's `.github/CONTRIBUTING.md` Tooling section for what each
script does, when it runs, and blocking-in-CI vs. advisory vs. manual-only —
that table is the single source of truth; don't re-describe a script's
purpose independently of it.

Coverage target ≥85% on `grading.py`, `scheduling.py`, `sessions.py`,
`stats.py`, `loader.py`. Required test cases are enumerated per-module in
`docs/SPEC.md` §16 — treat that list as acceptance criteria, not suggestions.

## Containers

`podman compose up` builds + serves on `http://127.0.0.1:8080`. See
`resources/containers.md` for the generic rebuild-on-code-change gotcha —
this repo has hit the stale-image crash loop it describes; see
`docs/DEPLOYMENT.md`'s "container is up but the app never becomes ready"
entry for the full symptom, verification command, and fix.

## Running outside a container (for UI work)

The repo's `readyband.db` is empty — build a throwaway database rather than
seeding demo data into it (see `resources/database-seeding.md` for the
generic pattern):

```bash
export DATABASE_URL="sqlite:////tmp/readyband-demo.db"
.venv/bin/alembic upgrade head
.venv/bin/python -m scripts.load_content     # loads every cert's question bank
.venv/bin/python -m scripts.seed_demo        # synthetic attempts/sessions/flags — see below
.venv/bin/python -m uvicorn app.main:app --host 127.0.0.1 --port 8099
```

`scripts/seed_demo.py` splits certifications into `deep` / `mid` / `light` /
`untouched` review tiers so every readiness band, coverage state, and empty
state shows up somewhere in the UI being reviewed.

`review_items.queue` accepts only `needs_review` or `spaced` — there's a
`CHECK` constraint, and `scheduled` is not a valid value, which is easy to
get wrong when writing seed data by hand.
