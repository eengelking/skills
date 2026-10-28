---
name: git-branching
description: Covers the front half of the git lifecycle — getting from no branch to the correct one. Precondition — about to edit any tracked file in this repo, whether that's a GitHub-issue-tracked unit of work, a parallel batch of issues, or an informal fix with no tracking issue at all; `main`'s state is not yet confirmed current. There is no category of work exempt from this — "it doesn't need a tracking issue" is not "it doesn't need a branch." Postcondition — on a correctly-named branch forked from the correct parent: sequential/informal work off `main`, a parallel batch's integration branch off `main`, and each sub-agent's branch off that integration branch (never off `main` directly). Every working branch is created as a git worktree in a git-ignored folder, by default, so agents working at the same time never share a checkout and the primary checkout stays on the base branch (see `resources/worktree-workflow.md` for the commands, the project-supplied folder and install step, and cleanup). Mandates `isolation: "worktree"` for every parallel-batch sub-agent spawn, covers what a sub-agent running in that worktree needs to know about keeping its shell commands simple before the harness's isolation guard refuses one, and notes that a worktree outlives its branch's merge and needs its own cleanup (see github-pr-merge). If the repo has a `development` branch on the remote, the parent is `development` instead of `main`, and a hotfix forks from `main` only when `development` differs from `main` (when they match it is an ordinary branch off `development`) — see `resources/development-branch.md`. Load this before the first Edit/Write of any session on this repo — including before writing a plan-mode implementation once approved — or before spawning a worktree-isolated sub-agent. For PR creation, merge permissions, and releases once the work is done, see the `github-pr-merge` skill instead.
---

# Starting work: branches in this repo

`main` is shared state, and a stale `main` or a badly-scoped branch is what causes
merge conflicts and drifting claims. This skill is the *how*; if the repo has its own
CLAUDE.md or contributing doc explaining *why* branching discipline matters here,
read that too.

**This applies to every kind of change in this repo, not just GitHub-issue-tracked
work.** A small doc fix or a workflow/process correction with no tracking issue
still branches first — the decision to skip opening an issue and the decision to
skip a branch are unrelated, and only the first one is ever legitimate. If you're
mid-plan-mode and about to make your first Edit/Write on approval, that's the moment
to load this skill, before the first file touches disk.

## Every unit of work, sequential or parallel

```bash
git fetch origin
```

Don't assume `main` is current — always sync before branching, even if you synced
recently in the same session.

**Every working branch is a git worktree.** Assume any branch may have another agent
working in it at the same time; separate worktrees keep two agents from trading files
or racing each other's checkouts. So the branch is created with `git worktree add`, in
a git-ignored folder, not with `git checkout -b` in the primary checkout, which stays
on the base branch as a clean reference. The commands, the folder, installing
dependencies, and cleanup are in `resources/worktree-workflow.md`. Wherever this skill
says "branch off X", it means a worktree on a new branch forked from `origin/X`.

### Technical backstop: the pre-commit hook

Don't rely on discipline alone. This skill ships a pre-commit hook
(`resources/scripts/hooks/pre-commit`) that refuses any commit made while `main` (or
`development`, in the development-branch workflow below) is checked out. Install it
once per clone:

1. Copy `resources/scripts/hooks/pre-commit` into this repo at `scripts/hooks/pre-commit`
   (create the directory if it doesn't exist) and make it executable
   (`chmod +x scripts/hooks/pre-commit`).
2. Point git at it: `git config core.hooksPath scripts/hooks`.
3. Confirm it's active: `git config --get core.hooksPath` should print `scripts/hooks`.

Don't rely on the hook instead of actually branching first, though — a relative
`core.hooksPath` resolves per-worktree, so a worktree checked out to a ref that
predates this hook being installed won't have it, and a fresh clone without the
one-time `git config` step won't either.

**A GitHub issue worked sequentially** (the normal case): branch directly off
`main`, named for the issue, e.g. `issue/42-grading-and-drill`.

## A deliberately parallel batch of issues

Use this shape any time a body of work is explicitly split into parallel issues
worked at once, one branch/agent per issue (e.g. one issue per component when
rolling out the same change across several areas). That parallelism is what makes
an integration branch necessary — see below.

1. **The orchestrator** branches an integration branch off `main` for the whole
   batch, e.g. `batch/<short-description>-round1`, and pushes it.
2. **Each sub-agent** branches from *that integration branch* — not from
   `main` — named for its own issue, e.g. `issue/58-<slug>`. Its changes stay
   scoped to that issue's own files.

Branching a sub-agent off `main` instead of the integration branch is the single
most common mistake here — it silently defeats the whole point of the integration
branch, since there's then no single branch the orchestrator can consolidate the
round's shared-doc updates onto before anything reaches `main`. Double check which
branch you're forking from before creating the worktree.

**Every parallel-batch sub-agent spawn MUST pass `isolation: "worktree"` on the
`Agent` tool call — this is not optional and not situational.** Sub-agents
sharing one working directory is a real, already-realized failure mode in this
repo: a batch of 5 parallel sub-agents spawned without worktree isolation shared
a single checkout, and concurrent `git checkout`/commit operations landed
commits on the wrong branches and contaminated a PR with unrelated files. It was
fully recovered, but only because someone caught it — don't rely on catching it
again. If you are the orchestrator spawning a sub-agent for a parallel batch,
`isolation: "worktree"` is a required field on that spawn call, not a judgment
call to make per batch.

**Once a sub-agent is running in its assigned worktree**, it must run plain,
single-purpose git/shell commands — one command per invocation, no chaining
with `&&` or `;`, no heredocs. The harness's worktree-isolation guard refuses
any command it can't statically verify stays scoped to that agent's own
worktree path, and a chained or heredoc'd command is exactly what it can't
verify — the refusal itself is correct behavior, but discovering the
constraint by trial and error burns a retry and tokens for nothing. Confirm
`pwd` resolves to the assigned worktree path before running anything, and do
large or repetitive file edits with the Edit/Write tools rather than shell
heredocs, which hit this guard every time. **The orchestrator must state both
of these — the worktree requirement and the plain-command constraint —
directly in the sub-agent's spawn prompt**, not let it learn either one from
an error.

## Development-branch workflow (a `development` branch exists)

Some projects merge feature work into a long-lived `development` branch and only move
`main` on a release. Check which workflow applies:

```bash
git ls-remote --exit-code --heads origin development
```

Exit 0 (the branch exists) means this workflow; any other exit means everything above
applies unchanged. The GitHub default branch stays `main` either way, so a plain clone
gets released code. In this workflow, "branch off `main`" above becomes "branch off
`development`" (hotfixes are the one exception, and fork from `main`), and neither
`main` nor `development` is ever edited directly. Branch names, parents, and the
hotfix backport are in `resources/development-branch.md`.

## While working

Commit as you go, following the issue's checklist, rather than saving everything for
one commit at the end — this keeps the branch's history reviewable and makes it
obvious where work stalled if it does.

**Inside a single agent's own worktree, never spawn forks/sub-agents to parallelize
that issue's own file-writing.** A fork shares its parent's working directory with no
file locking — this is a real failure mode, not a theoretical one: multiple forks
racing on the same set of files will silently clobber each other's writes. Do the
writing yourself, sequentially, file by file. Spawning a *separate* top-level agent
per issue, each in its own worktree per the parallel-batch structure above, is fine —
the problem is specifically forks sharing one agent's single worktree.

That's a file-corruption problem, not the only reason to avoid forks here. A separate,
authority-inheritance problem applies even to a single fork with no worktree sharing
involved at all: a fork inherits its parent's full authority without the parent having
seen what it's about to do first. Never delegate a decision-bearing step (a PR review,
a merge, a "fix this if it looks right") to a fork — have the fork report findings and
act on them yourself, or use a separate top-level agent instead.

## Next step

Once the branch's work meets its issue's Definition of Done and Validation passes,
load the `github-pr-merge` skill to open the PR.

A worktree created for this branch outlives the branch's PR being merged — it isn't
cleaned up automatically, and a leftover worktree still holding a branch checked out
will block deleting that branch later. Remove the worktree first, then delete the
branch; the order is in `github-pr-merge`'s cleanup section.
