# Branching when the default branch is `development`

Applies only when the repo's GitHub default branch is `development`:

```bash
gh repo view --json defaultBranchRef --jq .defaultBranchRef.name
```

If that prints anything else, ignore this file; the `main` instructions in `SKILL.md`
are the whole story.

## The model in one place

- `development` is the source of truth for unreleased work. It can be broken at any
  given time, and that's expected.
- `main` only moves on a release or a hotfix.
- Nothing is ever edited, committed, or pushed on `development` or `main` directly.
  Both change only through a PR that the user merges. That holds for a one-line doc
  fix too.

## Sync before branching

```bash
git checkout development && git pull
```

Don't assume `development` is current, same as `main` in the standard workflow.

## Which branch forks from where

| Work | Branch name | Forks from | PR targets |
|---|---|---|---|
| A GitHub issue, worked sequentially | `issue/<n>-<slug>` | `development` | `development` |
| Informal fix, no issue | `fix/<slug>` (any clear name) | `development` | `development` |
| Parallel batch: orchestrator's integration branch | `batch/<description>-round<n>` | `development` | `development` |
| Parallel batch: each sub-agent | `issue/<n>-<slug>` | the integration branch | the integration branch |
| Release prep (version bump + changelog retitle) | `release-prep/<version>` | `development` | `development` |
| Hotfix | `hotfix/<n>-<slug>` | `main` | `main` |

The integration branch means what it always has: the orchestrator's branch for a
worktree batch. It is not `development`. `isolation: "worktree"` and the
plain-command constraint for sub-agents apply exactly as in `SKILL.md`.

A hotfix is the one case that forks from `main`. Sync with `git checkout main && git
pull` first. See `github-release`'s `resources/development-branch.md` for the full
hotfix procedure, including the cherry-pick back into `development` that keeps the two
branches from drifting. The cherry-pick happens when the user tells the agent to do
it; it gets its own branch off `development` (e.g. `hotfix/<n>-<slug>-backport`).

## Pre-commit hook

`resources/scripts/hooks/pre-commit` refuses a commit while either `main` or
`development` is checked out. Install it the same way as in `SKILL.md`. The hook is a
backstop; branch first regardless.
