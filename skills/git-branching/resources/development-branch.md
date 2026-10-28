# Branching when a `development` branch exists

Applies only when `development` exists on the remote:

```bash
git ls-remote --exit-code --heads origin development
```

If that exits non-zero, ignore this file; the `main` instructions in `SKILL.md`
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
git fetch origin
```

Don't assume `development` is current, same as `main` in the standard workflow. The
branch is then created as a worktree forked from `origin/development`, per
`worktree-workflow.md`.

## Which branch forks from where

| Work | Branch name | Forks from | PR targets |
|---|---|---|---|
| A GitHub issue, worked sequentially | `issue/<n>-<slug>` | `development` | `development` |
| Informal work, no issue (`feat/`, `fix/`, `docs/`, `chore/`, `refactor/`, `test/`, `revert/`; see the table in `SKILL.md`) | `<prefix>/<slug>` | `development` | `development` |
| Parallel batch: orchestrator's integration branch | `batch/<description>-round<n>` | `development` | `development` |
| Parallel batch: each sub-agent | `issue/<n>-<slug>` | the integration branch | the integration branch |
| Release prep (version bump + changelog retitle) | `release-prep/<version>` | `development` | `development` |
| Hotfix, `development` differs from `main` | `hotfix/<n>-<slug>` | `main` | `main` |
| Hotfix, `development` matches `main` | `hotfix/<n>-<slug>` | `development` | `development` |

The integration branch means what it always has: the orchestrator's branch for a
worktree batch. It is not `development`. `isolation: "worktree"` and the
plain-command constraint for sub-agents apply exactly as in `SKILL.md`.

A hotfix forks from `main` only when `development` holds work `main` doesn't. Fetch
first, then compare contents:

```bash
git fetch origin && git diff --quiet origin/main origin/development && echo matches || echo differs
```

If they match, there's nothing in `development` to protect, so the fix is made there
like any other change and the next release carries it with a PATCH bump. That avoids a
cherry-pick that would do nothing useful. If they differ, the hotfix forks from
`origin/main`. See `github-release`'s `resources/development-branch.md` for both
procedures, including the cherry-pick back into `development` that keeps the two
branches from drifting. The cherry-pick happens when the user tells the agent to do
it; it gets its own branch off `development` (e.g. `hotfix/<n>-<slug>-backport`).

## Pre-commit hook

`resources/scripts/hooks/pre-commit` refuses a commit while either `main` or
`development` is checked out. Install it the same way as in `SKILL.md`. The hook is a
backstop; branch first regardless.
