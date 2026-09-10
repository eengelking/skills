# Skills Catalog

This catalogs the skills in this repo. Unlike its earlier incarnation, this repo now holds
only skills meant to be generic and reusable across projects — one-off skills that were
tied to a single project's paths, tools, or conventions have been moved back into that
project's own `.claude/skills/` directory (they already lived there; copies here were
removed on 2026-09-09 when the repo was rescoped).

Legend:
- **Needs review?** — *Yes* means the skill still hardcodes paths, tool names, or
  conventions specific to its origin project and should be generalized further; *No*
  means it reads as already generic/reusable as-is.
- **Depends on (hard)** — other skills this one's own text names as a load-before gate, a
  required step in its lifecycle, or a precondition it can't be followed correctly
  without (e.g. "load X before committing", "gate on X", "per X's checklist before
  opening the PR"). `—` means none. This is deliberately narrower than every skill
  mentioned in a blurb: a "see X for details" pointer, an alternate entry point, or a
  downstream hand-off target is a *soft* reference and is left out of this column even
  though it may appear in the skill's own prose. Cross-check the source skill's
  `SKILL.md` before trusting an entry here if it's load-bearing for what you're doing —
  this column is a map, not a substitute for reading the dependency's own text.

## Git / PR / issue workflow

| Skill | Blurb | Depends on (hard) | Needs review? |
|---|---|---|---|
| `git-branching` | Front half of the git lifecycle: GitHub-issue branch naming, the two-tier integration-branch model for parallel batches, a real installable pre-commit hook (`resources/scripts/hooks/pre-commit`) backstopping the branch-first rule, and the worktree-isolated sub-agent constraints. | — | **No** — genericized, no remaining hardcoded repo specifics. |
| `github-pr-merge` | Back half of the git lifecycle: `Closes #N` + squash-merge-body-note rules, the two-tier integration-branch merge authority (orchestrator-only, `--squash` rationale, two-fix-round cap), a real installable `gh_merge_guard.sh` wrapper (`resources/scripts/gh_merge_guard.sh`), full parallel-batch cleanup (integration branch + sub-agent branches + worktrees + `worktree-agent-*` branches). | — | **No** — genericized, no remaining hardcoded repo specifics. |
| `github-release` | Cutting an actual release once a PR has merged: universal `CHANGELOG.md` + SemVer policy plus a decision tree over per-axis resources — build/test verification by language family (`build-verify-compiled.md` for Go/Rust, `build-verify-interpreted.md` for Python/Node), version-bump mechanics by manifest (`version-bump-npm.md`, `version-bump-python.md`, `version-bump-cargo.md`), artifact publishing by shape (`publish-container-image.md`, `publish-package-registry.md`), and the post-merge tag + GitHub Release. | — | **No** — every resource is keyed by language/manifest/artifact shape, not by repo name. |
| `github-issue-filing` | Converts entries in a staging `docs/ISSUES.md` inbox into properly labeled GitHub issues. | `git-branching`, `github-pr-merge` | **Yes** — the staging-file → GitHub-issue *pattern* is reusable, but some label-taxonomy examples (e.g. `ui-ux` gated on a `docs/SPEC.md §13`-style decision) still carry certifications-project flavor and should be genericized. |
| `github-issue-workflow` | Governs the lifecycle of a GitHub-issue-tracked unit of work: one-issue-at-a-time sequencing, parallel-batch pattern, checklist/validation discipline before closing. | `git-branching`, `documentation-sync`, `github-pr-merge` | **Yes** — still contains a certifications-flavored example path (`content/certifications/<cert>.yaml`) and `docs/SPEC.md`-section language that should be swapped for repo-agnostic phrasing. |

## Documentation

| Skill | Blurb | Depends on (hard) | Needs review? |
|---|---|---|---|
| `documentation-sync` | Doc-sync checklist: branch-safety gate, the three-failure-modes framework (stale/invalid/missing), and the fact-vs-procedure decision rule, with each project's doc-ownership table moved to its own resource file. | `git-branching` (its own first line: confirm `main` isn't checked out, or stop and load `git-branching`) | **No** — the reusable framework lives in `SKILL.md`; project-specific tables are isolated in per-project resource files (`resources/localscore.md`, `resources/certifications.md` — kept as examples of the pattern even though those projects' skills were removed from this repo). |
| `documentation-voice-guide` | Prose voice guide (no em-dashes, no formulaic constructions, no marketing filler, in-app copy casing) plus this repo's global workflow rules (branch discipline, commit trailer, `gh` CLI, Podman vs Docker, manual merges). | — | **Yes** — still explicitly scoped to "the localscore repo" in its own description and body (Podman, the `<strong>`-wrapping rule); the workflow-rules half is close to project-agnostic if the localscore-specific voice rules were split out or genericized. |

## Dev tooling

| Skill | Blurb | Depends on (hard) | Needs review? |
|---|---|---|---|
| `development-commands` | Generic pattern for running tests/lint, running via container compose, and seeding a throwaway database for UI work, with per-concern resources (`resources/python-testing.md`, `resources/containers.md`, `resources/database-seeding.md`) picked by what a given repo actually uses. `resources/example-readyband.md` keeps a worked example (the certifications project's original concrete specifics) rather than dropping it. | — | **No** — `SKILL.md` and the per-concern resources are keyed by tooling/pattern, not by repo name; project-specific detail lives only in the `resources/example-*.md` worked example. |

## Needs Review summary

Three skills still carry residual project-specific content and are candidates for
further genericization:

- `documentation-voice-guide` — still explicitly localscore's voice guide; its workflow-rules half is the more reusable part.
- `github-issue-filing` — reusable staging-file → issue pattern, but a certifications-flavored label example should be swapped out.
- `github-issue-workflow` — reusable issue-lifecycle pattern, but a certifications-flavored example path and SPEC.md-section language should be swapped out.

## History

**2026-09-09:** This repo was rescoped from "catalog of every skill copied in from other
projects, pending genericization" to "shared skills only." The following skills were
removed because they already exist in, and belong to, their origin project's own repo:
`add-feature-flag`, `add-ingestion-connector`, `add-model-backend`, `release-check`,
`run-eval-harness`, `triage-incident` (legal-assist); `attestation`, `dependabot`,
`testing` (localscore); `cert-scoping`, `content-audit`, `content-authoring`,
`feature-development`, `ui-design` (certifications); `verify` (llm-experiments);
`write-post` (website). `job-search-keywords` and `linkedin-profile-builder` were also
removed as personal career-tooling rather than software-engineering skills, not because
they belong to a specific code project.
