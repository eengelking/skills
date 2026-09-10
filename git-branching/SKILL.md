---
name: git-branching
description: Covers the front half of the git lifecycle — getting from no branch to the correct one. Precondition — about to edit any tracked file in this repo, whether that's a GitHub-issue-tracked unit of work, a parallel batch of issues, or an informal fix with no tracking issue at all; `main`'s state is not yet confirmed current. There is no category of work exempt from this — "it doesn't need a tracking issue" is not "it doesn't need a branch." Postcondition — on a correctly-named branch forked from the correct parent: sequential/informal work off `main`, a parallel batch's integration branch off `main`, and each sub-agent's branch off that integration branch (never off `main` directly). Covers what a worktree-isolated sub-agent needs to know about keeping its shell commands simple before the harness's isolation guard refuses one, and notes that a worktree outlives its branch's merge and needs its own cleanup (see github-pr-merge). Load this before the first Edit/Write of any session on this repo — including before writing a plan-mode implementation once approved — or before spawning a worktree-isolated sub-agent. For PR creation, merge permissions, and releases once the work is done, see the `github-pr-merge` skill instead.
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
git checkout main && git pull
```

Don't assume `main` is current — always sync before branching, even if you synced
recently in the same session.

### Technical backstop: the pre-commit hook

Don't rely on discipline alone. This skill ships a pre-commit hook
(`resources/scripts/hooks/pre-commit`) that refuses any commit made while `main` is
checked out. Install it once per clone:

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
branch you're forking from before running `git checkout -b`.

**If a sub-agent runs in an isolated worktree** (the orchestrator spawned it with
worktree isolation rather than sharing the main checkout), it must run plain,
single-purpose git/shell commands — one command per invocation, no chaining with `&&`
or `;`, no heredocs. The harness's worktree-isolation guard refuses any command it
can't statically verify stays scoped to that agent's own worktree path, and a chained
or heredoc'd command is exactly what it can't verify — the refusal itself is correct
behavior, but discovering the constraint by trial and error burns a retry and tokens
for nothing. Confirm `pwd` resolves to the assigned worktree path before running
anything, and do large or repetitive file edits with the Edit/Write tools rather than
shell heredocs, which hit this guard every time. **The orchestrator should state this
constraint directly in the sub-agent's spawn prompt** rather than let it learn the
guard from an error.

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
will block deleting that branch later. See `github-pr-merge`'s cleanup section once the
batch's final PR has merged.
