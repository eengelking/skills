---
name: development-commands
description: Covers going from "need to test, lint, run a script, or see the UI with real-looking data" to a running result, generically across projects. Precondition — about to run a project's test/lint tooling, start the app outside a container for UI work, or seed/reset a database for that purpose. Postcondition — tests/lint have run and are interpretable, or a throwaway database is seeded and the app is serving against it (never seed demo data into a repo's real/default database file). Load this before running a repo's tests or linter, before starting the app outside a container for UI work, or before seeding/backing up a database.
---

# Running, testing, and seeding a project

This skill has no project-specific content of its own — it's a generic
pattern plus resources you pick based on what a given repo actually is. A
repo's own CLAUDE.md/CONTRIBUTING doc is the authoritative source for its
exact commands, script names, ports, and paths; don't invent or carry those
over from memory of a different project. If this repo documents them, use
that. If it doesn't and you're about to guess, ask instead.

Pick resources based on what applies to the repo at hand — most repos need
more than one:

- **Tests and linting** — `resources/python-testing.md` for a `uv`-managed
  Python repo's `.venv`/`pytest`/`ruff` pattern. (Add a resource here for
  other languages/tooling as this skill grows to cover them.)
- **Running via compose** — `resources/containers.md` for the
  podman/docker compose pattern, including a real gotcha: a plain `up` (or
  even `up --build` against an already-running container) can silently keep
  serving stale code after a change.
- **Seeding data for UI work** — `resources/database-seeding.md` for the
  generic "throwaway DB, migrate, seed, serve" pattern when a dashboard-style
  app needs real-looking data to review instead of empty states.

`resources/example-readyband.md` is a worked example showing how these
generic patterns cash out as one project's actual commands — useful as a
reference for the shape of a fully-instantiated project, not as something to
copy into an unrelated repo. As this skill covers more projects, add a
sibling `resources/example-<project>.md` for each rather than folding
project-specific specifics into the generic resources above.
