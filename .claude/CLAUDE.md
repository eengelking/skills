# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working in this repository.

## Project Overview

This repo holds Claude Code skills meant to be reusable across multiple projects: the
procedural *how* behind git/PR/issue workflow, git safety, documentation sync, prose
voice, and generic dev tooling. It ships as a single Claude Code plugin (`skills`,
versioned via `.claude-plugin/plugin.json`) that other projects install via the plugin
marketplace, or symlink from individually for local development. Skills tied to one
specific project's paths, tools, or conventions belong in that project's own
`.claude/skills/` directory instead, since this repo is only for skills that hold up
project-agnostically.

## Shortcuts

The operator uses shorthand in place of typing a full request out. Case-insensitive — treat any casing the same. Expand the shorthand below and act on it as if the full phrase had been typed. Add project- or user-specific entries as they come up.

| Shorthand | Expands to |
|---|---|
| `plmk` | "Please let me know if you have any questions or if I can provide any further context and/or information." |
| `wni` | "What is the next GitHub issue to resolve?" |
| `pmm` | "PR has been merged to main." |
| `cii` | "Please review outstanding docs/ISSUES.md and create GitHub issues for anything not yet tracked. Let me know when done." |
| `pnb` | "Please process the next batch of queued items." |

## Do Not

- Edit directly on `main`, or merge a PR into `main` yourself — both are always the user's call.
- Commit secrets, API keys, tokens, or credentials.
- Force-push, skip commit safety checks, or bypass signing without the user's explicit, in-the-moment approval.
- Delegate any task via a fork, no matter how narrow or read-only it looks — no exception.
- Start implementing an issue just because it (or you) filed it — filing and authorization are separate steps.
- Create a new standing doc when an existing one can hold the content.
- Document architecture in this file — use `docs/ARCHITECTURE.md`.
- Record current-state facts or status narrative in this file — facts belong in `CHANGELOG.md`; narrative belongs in commit history, PR descriptions, or `docs/ISSUES.md`.
- Silently pick a reading, or "fix" it in passing, when code and `docs/SPEC.md` disagree — flag the contradiction and ask.

## Skills

Procedural detail — the *how* behind the rules this file states — lives in skills, loaded on demand rather than carried in every session's context. "Orchestrator" means whichever agent is coordinating a piece of work (driving a single issue end to end, or running a parallel batch); "sub-agent" means an agent it spawned to do a scoped piece of that work. For a single issue worked solo, there's only one agent, so both columns apply to it.

| Skill | Load it when... | Orchestrator | Sub-agent |
|---|---|---|---|
| `git-branching` | Creating any branch — for an issue, a sub-agent, or a batch integration branch | Creates the batch integration branch (if parallel) | Branches off `main` (solo work) or off the integration branch (parallel batch) |
| `github-pr-merge` | Opening a PR; running any merge command; proposing a release tag | Reviews and merges a sub-agent's PR into the integration branch; never merges into `main` | Opens its own PR; never merges any PR itself |
| `github-release` | Cutting an actual release once a PR has merged `main` to a releasable state | Runs the release steps | N/A — releases aren't a sub-agent's job |
| `github-issue-filing` | Filing issues — grouping related reports, checking for duplicates | Runs standalone, on explicit request | Same as orchestrator |
| `github-issue-workflow` | Starting, resuming, or closing GitHub-issue-tracked work | Decides sequencing and whether a parallel batch applies | Follows the same checklist/Validation discipline within its own issue |
| `documentation-sync` | Before committing any change | Runs the batch-wide consolidation commit (if parallel) | Keeps its own PR's changes in sync |
| `documentation-bootstrap` | Backfilling or topping up a project's missing doc set (bulk scaffolding, not a single commit's worth of sync) | Runs the doc-type selection pass, sets the sequencing rule, and runs the parallel batch (integration branch, post-bootstrap validation) | Writes its one assigned doc type per the orchestrator's sequencing rule; no merge authority |
| `development-commands` | Running tests/lint, starting the app for UI review, seeding a database | Yes | Yes |
| `git-safety` | Force-push, skipping commit checks, secrets review | Yes | Yes |

## Working Style

- **Prefer acting to asking** when the request and the codebase together make the right move obvious; ask when you're genuinely blocked — ambiguous intent, a decision only the user can make, or a destructive/hard-to-reverse action.
- **Verify with real runs, not just lint/build.** A passing type-check or test suite verifies correctness, not that the feature actually works. Where practical, run the thing and exercise the change before calling it done — and say so explicitly when you can't (no way to run the app, no browser access, etc.) rather than implying it was checked.
- **Leave no mess behind.** Stop dev servers you started, close browser tabs you opened, delete branches once their merge is confirmed. A task isn't finished just because the code is right — clean up the process/session state too. Validate the cleanup completed successfully and left no orphans behind.
- **Don't let a stale run fool you.** If you changed code, restart whatever's serving it before treating its behavior as evidence. Testing against cached/stale state produces false confidence.
- **If this project has a `docs/NON_NEGOTIABLES.md`, read it before starting any task.** Its constraints are absolute — they don't get traded away for convenience, ever.
- **Prefer a fresh session per PR or unit of work** rather than accumulating context across many PRs in one long-running session. A long session replays its whole accumulated transcript every turn; starting fresh per PR keeps that small instead of letting it compound.
- **When fixing a bug in code, first write a test that reproduces the failure and confirm it fails for the expected reason, before writing the fix.** A test only ever run against the fixed code doesn't prove it would have caught the regression. This applies to code fixes specifically — it doesn't apply to documentation or other non-code changes.
- **When waiting on a background agent or task, wait for it properly rather than repeatedly checking its status in a loop.** Polling — check, wait a bit, check again — burns tokens re-sending the whole conversation on every check, for no benefit over a real blocking wait. This is a real, recurring waste, not a hypothetical: an orchestrator managing sub-agents or background work is exactly where this loop tends to happen.

## Git & GitHub Workflow

Order of operations for any tracked change. The policy is the invariant that holds regardless of mechanics; the skill covers the how.

| Phase | Policy | Skill |
|---|---|---|
| Start | Branch first, synced from current `main`. | `git-branching` |
| Develop → PR | Changes land via PR; the user reviews and merges. Opening a PR is a stopping point, not a launchpad — it doesn't authorize starting the next unit of work unprompted. | `github-pr-merge` |
| Merge & cleanup | A branch is deleted only after its merge is confirmed, not assumed. | `github-pr-merge` |
| Release (if applicable) | A deliberate step after a PR merges, never an automatic side effect of merging — ask if it's unclear whether this project does releases at all. | `github-release` |
| Dangerous git actions | See Do Not — a prior approval doesn't carry forward to the next instance. | `git-safety` |
| Committing | Review staged changes for anything sensitive before committing, especially in files that don't look like they'd contain any. If a secret is committed anyway, treat it as compromised and flag it to the user for rotation rather than just removing it from the latest commit. | `git-safety` |

## Issue Management

| Phase | Policy | Skill |
|---|---|---|
| Filing | Group related reports under one issue by root cause rather than one per symptom — but split back out when a report actually bundles more than one distinct Definition of Done. | `github-issue-filing` |
| Working | Work one open issue at a time by default — closing one, even by a merged PR, doesn't authorize starting the next unprompted — unless the user has deliberately scoped a parallel batch, in which case an orchestrator may run multiple issues at once via sub-agents. Each sub-agent stays scoped to its own issue's files; never let one touch a shared, single-section file (e.g. `CHANGELOG.md`'s `[Unreleased]` section, this file's own status content) — independent agents editing the same lines is a guaranteed conflict. | `github-issue-workflow` |

## Delegation & Sub-agents

- **Scope a sub-agent's authority to what you actually asked it to do.** A sub-agent asked to research or review should not commit, push, or open/merge a PR on its own initiative — those actions belong to the coordinating session unless explicitly delegated.
- **A forked agent inherits its parent's entire conversation** — full context and full authority, including merge permissions — whether or not the task you gave it needs any of that (see Do Not). This has already caused real incidents (an unauthorized merge, corrupted files from forks racing on the same working directory). "It's just read-only," "it's just reviewing one PR," "the prompt only asked for one thing" — none of these make a fork safe; a fork's authority isn't bounded by what its prompt asked for. Use a fresh, non-fork sub-agent for every delegated step instead — reviewing a PR, running a validation pass, even read-only research. When you spawn it, state its authority explicitly in the prompt ("report a verdict; you do not have merge authority for this"), not just its scope — scope alone doesn't bound what an agent can decide to do.

## Commands

How to build, test, lint, and run this project is procedural — it belongs in a skill, not here. _See skill: `development-commands`._
