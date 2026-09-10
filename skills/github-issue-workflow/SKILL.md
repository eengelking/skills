---
name: github-issue-workflow
description: Governs the lifecycle of a unit of tracked work — a GitHub issue. Precondition — about to start, resume, or close out work tracked as a GitHub issue. Postcondition — on start, the issue is confirmed to be the one the user authorized and its Requirements are read; on close, its checklist is fully checked off and its Validation section passes before the closing PR is opened. Covers the one-issue-at-a-time gate, the generalized parallel-batch pattern (formerly Phase 7), per-certification file scoping, the no-forks-in-a-single-worktree rule, and the blanket rule against delegating any step — bounded review/merge or otherwise, including read-only research — via a fork (use a fresh non-fork sub-agent instead), and updating the issue body when it turns out to be wrong. Load this before starting, resuming, or closing any GitHub-issue-tracked work, or before deciding whether the next issue is safe to start. Historical `archived/tasks/001`-`031` files are a frozen archive — not this skill's concern.
---

# Work-tracking workflow (GitHub issues)

Every unit of tracked work is a **GitHub issue**, not a file in `archived/tasks/` — that
directory is a frozen historical archive of everything completed before this
skill's rewrite (see CLAUDE.md's Current state). An issue's body carries what a
`archived/tasks/NNN-slug.md` file used to: Requirements, Definition of Done, Out of Scope,
the docs/SPEC.md section(s) it implements, a Validation command list, and a
Checklist — written from the `github-issue-filing` skill's `resources/gh-issue.md`
template (see that skill for how an issue gets created in the first place).

## Sequencing

**Work one open issue at a time.** A merged PR closes the issue it references
(`Closes #N` in the PR body — see `github-pr-merge`) and GitHub closes it
automatically on merge. That closure **never authorizes starting the next issue** —
the user decides what's next, every time, exactly as it worked when this was a
numbered task file.

**The one exception is a deliberately scoped parallel batch** — the generalized form
of what used to be Phase 7's per-certification content tasks. When a body of work is
explicitly split into multiple issues meant to run in parallel (e.g. one issue per
certification when adding a new path like AWS/Azure), the same integration-branch
structure applies:

- Each sub-agent's changes stay scoped to its own issue's files (e.g., for a
  per-certification issue: its `content/questions/<cert>/*.yaml` and
  `content/certifications/<cert>.yaml`).
- Never let a parallel-batch agent touch a shared, ordered, single-section file like
  `CHANGELOG.md`'s `[Unreleased]` section or CLAUDE.md's Current state — independent
  agents editing the same lines produces guaranteed merge conflicts and drifting
  claims.
- Load `git-branching` for the integration-branch structure this requires and
  `github-pr-merge` for how those branches get merged and the shared docs get
  consolidated.

## While working an issue

- **Read the referenced docs/SPEC.md section(s) before starting** — the issue body
  is a pointer and a checklist, not a paraphrase good enough to skip the source.
- **Check off checklist items in the issue body as you complete them**, not in one
  batch at the end — fetch the current body (`gh issue view <n> --json body -q
  .body`), flip the relevant `- [ ]` to `- [x]`, then `gh issue edit <n>
  --body-file <tmpfile>`. This keeps the issue an honest record of progress if the
  session is interrupted, the same way checking off a task file's checklist used
  to.
- **An agent working inside its own worktree must never spawn forks/sub-agents to
  parallelize that issue's own file-writing** — see the `git-branching` skill for
  why (it's already caused real data corruption once).
- If working an issue surfaces a gap its body didn't anticipate, **edit the issue
  body** to reflect it rather than silently deviating — it's meant to stay the
  accurate record of what "done" means for that unit of work.

## Delegating any step — never a fork

See CLAUDE.md's blanket no-fork rule for *why*: a fork inherits the delegating
agent's entire conversation, including authority and context it was never given
for its specific task, and that's already caused real problems twice. In this
skill's workflow, that means every delegation — reviewing one PR,
spot-checking one cert's content, running one validation pass, or even a
read-only research/documentation-audit task — goes to a **fresh, non-fork
sub-agent** (e.g. `general-purpose`), never a `fork`. There is no category of
delegated task exempt from this, including one that looks safe because it's
"just reading files."

When writing that prompt, state the task's authority explicitly, not just its scope —
"review PR #N and report a verdict; you do not have merge authority for this task" is
what actually bounds the agent, not "don't touch the other PRs." And keep the merge
itself a separate, later step the orchestrator performs directly per `github-pr-merge` —
never bundle "review this PR and merge it if it looks good" into one delegated prompt
whose outcome isn't seen before it acts.

## When a sub-agent has to build a tool that doesn't exist

If finishing an issue requires writing a script or other tool that isn't already in
`scripts/` or covered by an existing skill, that's not just incidental scope — it's a
signal of a gap in the workflow itself.

- **A sub-agent** reports this back to the orchestrator, not just in its own PR: why
  the tool was needed, what it does, and how it should be integrated into the
  workflow — which skill should reference it going forward, and whether it belongs in
  `scripts/` as a permanent tool or was genuinely one-off.
- **The orchestrator** (or, for a solo sequential task, the same agent doing both
  roles) captures that as a `docs/ISSUES.md` AI Issues entry per the `documentation-sync` skill's
  table, rather than letting the finding evaporate at session end. It gets filed as
  its own GitHub issue (via `github-issue-filing`) once it's a real body of work.

This mirrors the lifecycle already observed with `scripts/check_distractor_bias.py`
(historical `archived/tasks/029`): two review agents in a content batch independently wrote
scratch scripts to catch the same content-quality defect; the finding was written up
in the staging file, scoped into tracked work, built as a real repo-wide tool wired
into `content-authoring`, and only then was the staging entry removed — the gap was
closed and durably documented in the owning skill and script instead. That's the
intended path for one of these findings: staging-file entry → filed GitHub issue →
implemented tool integrated into the owning skill → staging entry already removed at
filing time.

## Closing out an issue

**Before opening the closing PR, run every command in the issue's Validation
section and confirm it passes.** If something fails, fix the underlying work —
never the validation command — and re-run. Only open the PR once the checklist is
fully checked and validation passes.

**The checklist is never fully checked until its `documentation-sync` pass item is checked
too.** `github-issue-filing`'s `resources/gh-issue.md` template carries a standing
Definition-of-Done line and checklist item for this — don't treat "load documentation-sync before committing" as
sufficient on its own; the issue's own checklist is what makes the pass a checkable,
verifiable part of "done" rather than something that relies on an agent remembering
to do it unprompted. If an older issue predates that template line, add the item to
its checklist before closing rather than skipping it because the template didn't
originally have it.

**A `ui-ux`-labeled issue's checklist is never fully checked until its
Chrome-based visual verification item is checked too**, on the same basis as the
`documentation-sync` item above — see `ui-design`'s "Before calling a UI change done" section
for what that verification actually requires (loading the Claude-in-Chrome tools,
inspecting the change in both light and dark mode, and exercising any interactive
element). Confirming the HTML response looks right via `curl` or a template diff
does not satisfy this — it has to be seen and, where interactive, used, in a real
browser. If an older `ui-ux` issue predates this checklist item, add it before
closing rather than skipping it because the template didn't originally have it.

**An issue touching `app/`, `scripts/`, `migrations/`, or `container/` is never
fully checked until its container-rebuild item is checked too.** `compose.yaml`
bind-mounts `./content` live but bakes app code into the image at build time — a
plain `podman compose up` silently keeps running the old code, which can pass every
other Validation command and still crash-loop in the actual container (a real
incident: a new Pydantic field on `CertificationFile` shipped without a rebuild,
and a stale image's old schema rejected content YAML already using the field on
every startup). Before closing such an issue, run `podman compose up --build -d`
and confirm the container stays up and `curl` against it returns 200 — see
`development-commands`'s `resources/containers.md` troubleshooting pointer and
`docs/DEPLOYMENT.md`'s "container is
up but the app never becomes ready" entry for the full symptom. An issue scoped to
only `content/` or `docs/` doesn't need this — the live content mount already
covers that case. If an older issue predates this checklist item, add it before
closing rather than skipping it because the template didn't originally have it.

Open the PR per the `github-pr-merge` skill, with `Closes #N` in its body. GitHub
closes the issue automatically when the PR merges — there's no separate manual
close step. A merged PR closes out that issue — it does not authorize starting the
next one. Wait for the user to say to proceed before branching for the next piece
of work.
