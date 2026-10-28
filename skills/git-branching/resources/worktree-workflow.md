# Every working branch is a worktree

This is the default way to make a branch. Several branches never trade files, a test
run or a server in one cannot be disturbed by another, and two agents never race over
one checkout. The primary checkout stays on the base branch (`main`, or `development`
in the development-branch workflow) as a clean, current reference. Nobody edits, tests
or commits there.

It replaces only the `git checkout -b` step. Parents, names, hotfix forks and parallel
batches in `SKILL.md` and `development-branch.md` apply unchanged.

## Read the project's details first

Two details belong to the project, not to this skill. Read them from the project's
`PROJECT.md` if it has one, otherwise its `CLAUDE.md` or contributing doc:

- the worktree folder (this skill assumes `.claude/worktrees/` when the project says
  nothing), which must be git-ignored;
- the command that installs dependencies in a fresh worktree (see
  `development-commands`).

If the folder is not ignored, add it to `.gitignore`, or to `.git/info/exclude` when you
should not change a tracked file, before creating the first worktree.

## Create

```bash
git fetch origin
git worktree add <dir>/<branch-slug> -b <branch> origin/<base>
cd <dir>/<branch-slug>
# then the project's install command
```

- `<base>` is the branch the new one forks from: `main` or `development` for ordinary
  work, `main` for a hotfix, the integration branch for a parallel batch's sub-agent.
- `<branch-slug>` is the branch name with each `/` written as `-`, so
  `issue/42-grading-and-drill` lives in `<dir>/issue-42-grading-and-drill`.
- A branch that already exists gets `git worktree add <dir>/<branch-slug> <branch>`.
- Do every edit, test run, commit and push for the branch inside its worktree. Confirm
  `pwd` and `git branch --show-current` before the first one, and again after any
  command that may have changed directory.

## The pre-commit hook

If `core.hooksPath` is a path inside the checkout, such as `scripts/hooks`, every
worktree has the hook with no extra setup, because the worktree is a checkout of a ref
that already contains it. A worktree forked from a ref that predates the hook does not
have it. Branch first regardless; the hook is a backstop.

## Parallel batches

Sub-agents get their own worktrees from the harness (`isolation: "worktree"`, see
`SKILL.md`), forked from the batch's integration branch. The orchestrator's own work,
including the integration branch, follows this file. All of those branches merge up to
their parent, and the batch's final PR goes to the base branch (or to `main` for a
hotfix).

## Clean up

Only when the merge is confirmed, not before. A worktree outlives its branch's merge,
and a worktree that still holds a branch checked out blocks deleting that branch, so
the worktree goes first:

1. `git worktree remove <dir>/<branch-slug>` (see `github-pr-merge` before using
   `--force`).
2. Delete the branch locally and on the remote, and verify both, per
   `github-pr-merge`'s cleanup.
3. `git worktree prune`, then check that `git worktree list` shows only what is still
   in use.
