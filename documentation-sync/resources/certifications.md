# Doc-sync routing for the certifications repo

Documentation in this repo lives in several places, each owning a different slice:

| If the change... | ...update |
|---|---|
| Adds, removes, or changes the meaning of an `app/config.py` setting | `docs/DEPLOYMENT.md`'s Configuration table |
| Adds, removes, or changes the shape of an `/api/v1` (or `/healthz`) response | `docs/API.md` |
| Adds a new core module, moves ownership between modules, or changes what a module in the table owns | `docs/ARCHITECTURE.md`'s module table |
| Changes a route, the data model, grading, scheduling, sampling, or stats behavior | the relevant `docs/SPEC.md` section — SPEC.md is the design authority; an undocumented behavior change makes it wrong, not just stale |
| Is user-visible (feature, fix, content milestone, design change) | `CHANGELOG.md`'s `[Unreleased]` section, in the same PR — not batched up later from memory |
| Changes how the app is run, built, or deployed | `README.md` and/or `docs/DEPLOYMENT.md` |
| Changes what a study mode does, what a flag reason means, or what a progress/readiness number represents | `docs/USER_GUIDE.md` |
| Changes a contributor-facing rule, invariant, or the dev setup | `.github/CONTRIBUTING.md` |
| **Adds, removes, or significantly changes a `scripts/*` tool, or adds/removes/reorders a CI step in `.github/workflows/ci.yml`** | **`.github/CONTRIBUTING.md`'s Tooling section** — the single source of truth for what each script does, when it runs, and blocking-in-CI vs. advisory vs. manual-only; also re-check `.github/CONTRIBUTING.md`'s "Pull requests" CI-description line and the CI workflow file itself for a word-for-word match to `ci.yml`'s actual step list, not just the Tooling section. `development-commands` (and any other doc listing dev commands) should reference that section rather than re-describing the script inline. |
| Completes or blocks a GitHub issue, finishes a phase, changes a certification's milestone, or otherwise changes a **fact** CLAUDE.md's Current state or Invariants section asserts as currently true | **CLAUDE.md itself** — never a skill; project-state facts live only there |
| Surfaces a new or changed **procedure** — a command, a branch/PR/merge convention, a review checklist step, a content- or UI-authoring rule, anything a skill's body already describes as *how* — whether by discovering a gap, a wrong assumption, or an edge case a skill didn't anticipate | **the specific skill that owns it** (`github-issue-workflow`, `git-branching`, `github-pr-merge`, `documentation-sync` itself, `development-commands`, `content-authoring`, `content-audit`, `ui-design`, `feature-development`, or `github-issue-filing`) — never CLAUDE.md |
| A sub-agent had to build a tool/script that doesn't already exist to complete its task (a workflow gap) | `docs/ISSUES.md`'s AI Issues section — see `github-issue-workflow`'s reporting protocol for what the sub-agent owes the orchestrator first |

If none of these apply, say so — most commits (a single bug fix, a content
correction) only need the `CHANGELOG.md` line. But check the table rather than
assuming; a silently stale `docs/API.md`, Configuration table, or — easy to forget
precisely because you're reading it rather than writing to it — CLAUDE.md's own
Current state section is exactly the kind of gap that's invisible until someone hits
it. CLAUDE.md is the first thing read at the start of every session; a stale claim
there about what's blocked, what phase is complete, or which task is next actively
misleads the *next* piece of work, not just this one.

"KCNA has 121 questions" is the standing example of a fact that belongs in CLAUDE.md
(see `documentation-sync`'s fact-vs-procedure section) since it changes every time a
question is added.
