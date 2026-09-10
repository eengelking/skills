---
name: github-issue-workflow
description: Governs the lifecycle of a unit of tracked work — a GitHub issue that already exists. Precondition — about to start, resume, or close out work tracked as a GitHub issue. Postcondition — on start, the issue is confirmed to be the one the user authorized and its Requirements are read; on close, its checklist is fully checked off and its Validation section passes before the closing PR is opened. Covers the one-issue-at-a-time gate, the generalized parallel-batch pattern, parallel-batch file scoping, the no-forks-in-a-single-worktree rule, and the blanket rule against delegating any step — bounded review/merge or otherwise, including read-only research — via a fork (use a fresh non-fork sub-agent instead), and updating the issue body when it turns out to be wrong. Load this before starting, resuming, or closing any GitHub-issue-tracked work, or before deciding whether the next issue is safe to start. For creating the issue in the first place, see `github-issue-filing`.
---

# Working a GitHub issue

Every unit of tracked work is a **GitHub issue**. An issue's body carries
Requirements, Definition of Done, Out of Scope, a Validation command list, and a
Checklist — written from the `github-issue-filing` skill's `resources/gh-issue.md`
template (see that skill for how an issue gets created in the first place). This
skill governs everything from there: starting it, doing the work, and closing it
out.

## Sequencing

**Work one open issue at a time.** A merged PR closes the issue it references
(`Closes #N` in the PR body — see `github-pr-merge`) and GitHub closes it
automatically on merge. That closure **never authorizes starting the next issue** —
the user decides what's next, every time.

**The one exception is a deliberately scoped parallel batch.** When a body of work
is explicitly split into multiple issues meant to run in parallel (e.g. one issue
per component when rolling out the same change across several areas), the same
integration-branch structure applies:

- Each sub-agent's changes stay scoped to its own issue's files (e.g., for a
  per-component issue: whatever that component's own files are, and nothing
  outside them).
- Never let a parallel-batch agent touch a shared, ordered, single-section file
  like `CHANGELOG.md`'s `[Unreleased]` section or CLAUDE.md's current-state
  content — independent agents editing the same lines produces guaranteed merge
  conflicts and drifting claims.
- Load `git-branching` for the integration-branch structure this requires and
  `github-pr-merge` for how those branches get merged and the shared docs get
  consolidated.

## While working an issue

- **If the issue references a spec or design doc section, read it before
  starting** — the issue body is a pointer and a checklist, not a paraphrase good
  enough to skip the source.
- **Check off checklist items in the issue body as you complete them**, not in one
  batch at the end — fetch the current body (`gh issue view <n> --json body -q
  .body`), flip the relevant `- [ ]` to `- [x]`, then `gh issue edit <n>
  --body-file <tmpfile>`. This keeps the issue an honest record of progress if the
  session is interrupted.
- **An agent working inside its own worktree must never spawn forks/sub-agents to
  parallelize that issue's own file-writing** — see the `git-branching` skill for
  why (it's already caused real data corruption once).
- If working an issue surfaces a gap its body didn't anticipate, **edit the issue
  body** to reflect it rather than silently deviating — it's meant to stay the
  accurate record of what "done" means for that unit of work.

## Delegating any step — never a fork

If this project's CLAUDE.md has a blanket no-fork rule, follow it: a fork inherits
the delegating agent's entire conversation, including authority and context it was
never given for its specific task. In this skill's workflow, that means every
delegation — reviewing one PR, spot-checking one portion of the work, running one
validation pass, or even a read-only research/documentation-audit task — goes to a
**fresh, non-fork sub-agent** (e.g. `general-purpose`), never a `fork`. There is no
category of delegated task exempt from this, including one that looks safe because
it's "just reading files."

When writing that prompt, state the task's authority explicitly, not just its scope —
"review PR #N and report a verdict; you do not have merge authority for this task" is
what actually bounds the agent, not "don't touch the other PRs." And keep the merge
itself a separate, later step the orchestrator performs directly per `github-pr-merge` —
never bundle "review this PR and merge it if it looks good" into one delegated prompt
whose outcome isn't seen before it acts.

## When a sub-agent has to build a tool that doesn't exist

If finishing an issue requires writing a script or other tool that isn't already
covered by an existing skill or the project's own scripts, that's not just
incidental scope — it's a signal of a gap in the workflow itself.

- **A sub-agent** reports this back to the orchestrator, not just in its own PR: why
  the tool was needed, what it does, and how it should be integrated going
  forward — which skill should reference it, and whether it belongs in the project
  as a permanent tool or was genuinely one-off.
- **The orchestrator** (or, for a solo sequential task, the same agent doing both
  roles) captures that as a `docs/ISSUES.md` entry, if the project uses that
  staging pattern, rather than letting the finding evaporate at session end. It
  gets filed as its own GitHub issue (via `github-issue-filing`) once it's a real
  body of work.

## Closing out an issue

**Before opening the closing PR, run every command in the issue's Validation
section and confirm it passes.** If something fails, fix the underlying work —
never the validation command — and re-run. Only open the PR once the checklist is
fully checked and validation passes.

**The checklist is never fully checked until its `documentation-sync` pass item is
checked too.** `github-issue-filing`'s `resources/gh-issue.md` template carries a
standing Definition-of-Done line and checklist item for this — don't treat "load
documentation-sync before committing" as sufficient on its own; the issue's own
checklist is what makes the pass a checkable, verifiable part of "done" rather than
something that relies on an agent remembering to do it unprompted. If an older
issue predates that template line, add the item to its checklist before closing
rather than skipping it because the template didn't originally have it.

**A UI-facing issue isn't done just because the HTTP response looks right.** If
the project has its own UI-review convention or skill, run it before closing —
`curl` output or a template diff doesn't substitute for actually seeing (and, for
anything interactive, using) the change the way a person would.

**If the project runs from a built artifact or container image that isn't
automatically kept in sync with source** (a bind mount that covers data but not
code, for instance), confirm it's been rebuilt and is healthy before closing — see
`development-commands`. A stale build can pass every Validation command while
still running old code in whatever actually gets deployed or used; this is a real,
recurring failure mode, not a hypothetical one.

Open the PR per the `github-pr-merge` skill, with `Closes #N` in its body. GitHub
closes the issue automatically when the PR merges — there's no separate manual
close step. A merged PR closes out that issue — it does not authorize starting the
next one. Wait for the user to say to proceed before branching for the next piece
of work.
