---
name: development-commands
description: Covers going from "need to install, test, build, analyze, run, measure, or look at a project" to a result you can interpret, generically across projects and tools. Precondition — about to run any development command for a repo: dependency install, tests, lint or static analysis, a build or dev server, a container build, a docs-site build, an end-to-end or load script, a screenshot at a set width, or a measurement of the machine, or about to start the app outside a container or seed/reset a database. Postcondition — the command has run and its output is interpretable (a skipped analysis is reported as skipped, never as clean), or a throwaway server and database are running on a free port for the check and then stopped, with nothing left behind (never seed demo data into a repo's real/default database file, never point a check at the server the user works with). Load this before running a repo's tests, linter, analyzer or build, before starting a server or the app for UI work, before taking a screenshot or running an end-to-end script, or before seeding/backing up a database. The commands live in resources, grouped by tool (`resources/python/`, `resources/node/`, and so on); find the tool the repo uses, read that folder, and read only the other resources that match what the repo has.
---

# Running, testing, and seeding a project

This skill has no project-specific content of its own — it's a generic
pattern plus resources you pick based on what a given repo actually is. A
repo's own CLAUDE.md/CONTRIBUTING doc is the authoritative source for its
exact commands, script names, ports, and paths; don't invent or carry those
over from memory of a different project. If this repo documents them, use
that. If it doesn't and you're about to guess, ask instead.

Find the tool the repo is built with, and read that tool's folder first. Each tool has
its own folder under `resources/`, so a Node repo never has to read Python guidance.

## By tool

- **Python** — `resources/python/`. `testing.md` is the `uv`-managed `.venv`,
  `pytest` and `ruff` pattern.
- **Node and npm** — `resources/node/`:
  - `npm.md`: `npm ci --ignore-scripts`, workspaces, `--package-lock-only`, Node
    versions, and a nested package that has its own lockfile.
  - `testing-and-build.md`: `vitest`, the coverage run, `tsc` and `vite` builds, dev
    servers, writing the failing test first, accessibility checks in the unit run, and
    starting the built server on a throwaway port.
  - `containerfile.md`: what a good two-stage Containerfile for a Node app looks like.
- **Another tool** (Go, Rust, Java, and so on) — read the project's own docs. When this
  skill grows a resource for it, it goes in its own `resources/<tool>/` folder, never
  loose at the top level.

## Any stack

These don't depend on the language. Read the ones that match what the repo has.

- **Containers** — `resources/containers.md`: Podman, Docker and nerdctl with
  containerd. Compose, building by hand, and a project's own CLI wrapper. A plain `up`,
  or even `up --build` against an already-running container, can silently keep serving
  stale code.
- **A throwaway server** — `resources/throwaway-server.md`: your own server on a free
  port with temporary data, then stopped. Never the server the user works with.
- **Seeding data for UI work** — `resources/database-seeding.md`: the generic
  "throwaway DB, migrate, seed, serve" pattern when a dashboard-style app needs
  real-looking data to review instead of empty states.
- **Looking at the UI at a set width** — `resources/ui-screenshots.md`, with
  `resources/scripts/page-shot.mjs`: headless Chrome at 400 and 1440 px, run
  JavaScript in the page, save a PNG.
- **End-to-end scripts** — `resources/end-to-end-scripts.md`: the smoke, soak and
  restart, browser-cost, and real-session checks, and the shape every such script has.
- **Measuring the machine** — `resources/host-sampling.md`: GPU load on macOS, Linux and
  Windows, logging an agent's tokens over time, comparing stored counts with a transcript.
- **Building a docs site** — `resources/static-site-build.md`: quick and full builds,
  previewing, and checking the result at narrow and wide widths.
- **SonarQube and SonarCloud** — `resources/sonar-analysis.md`: the `sonar` CLI, a
  skipped analysis is not a clean one, the coverage gate it does not measure, and the
  analyzer config.
- **CodeQL** — `resources/codeql-results.md`: reading code scanning alerts for a PR
  from a GitHub pipeline.

`resources/example-readyband.md` is a worked example showing how these
generic patterns cash out as one project's actual commands — useful as a
reference for the shape of a fully-instantiated project, not as something to
copy into an unrelated repo. As this skill covers more projects, add a
sibling `resources/example-<project>.md` for each rather than folding
project-specific specifics into the generic resources above.
