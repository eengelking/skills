---
name: github-issue-filing
description: Converts docs/ISSUES.md staging entries — or a finding raised directly in conversation — into properly labeled GitHub issues, checking for existing duplicates first and grouping related reports under one issue by root cause (splitting back out only when a report actually bundles more than one distinct Definition of Done). Precondition — asked to process docs/ISSUES.md, or asked to file a specific finding as a GitHub issue. Postcondition — every fileable unit of work exists as exactly one GitHub issue (title, body from this skill's resources/gh-issue.md, correct label(s)), no duplicate was created for something already tracked, any processed docs/ISSUES.md entries are deleted, and the change is committed and opened as a PR per git-branching/github-pr-merge. Load this before converting docs/ISSUES.md findings into GitHub issues, or when asked to "file the issues", "process ISSUES.md", or "clear the backlog into GitHub."
---

# Filing GitHub issues

`docs/ISSUES.md`, where a project uses it, exists so nothing discovered informally
gets lost before it's triaged — but a markdown file isn't where ongoing work should
live once it's real: GitHub is. This skill is the conversion step between the two:
read a finding, check whether it's already tracked, decide what it actually needs,
file it as a properly labeled GitHub issue, and (if it came from the staging file)
remove it so that file stays a short-lived inbox instead of a permanent,
unbounded log.

## Two ways in

- **Backlog processing**: the user asks to review `docs/ISSUES.md` and file its
  entries ("file the issues", "process ISSUES.md", "clear the backlog into
  GitHub"). Work through every entry, per the sections below, deleting each one
  once it's filed (or once it's confirmed non-actionable — see below).
- **A single finding, filed directly**: the user or an in-progress task surfaces
  one thing that needs to be filed right now, with no staging-file detour. The
  same duplicate-check, grouping, and filing-mechanics steps below still apply —
  there's just no `docs/ISSUES.md` entry to delete afterward.

Either way, filing an issue for something that isn't yet a defined problem — a
vague idea that still needs scoping, a feature with no agreed shape — isn't this
skill's job. This skill converts an already-understood finding into a tracked
issue; it doesn't do the scoping itself.

## Check for duplicates before filing

Before creating anything, search existing issues for the same underlying problem:

```bash
gh issue list --search "<keywords>" --state all
```

or, for a phrase match across title and body:

```bash
gh search issues --repo <owner>/<repo> "<keywords>"
```

If a matching open issue already exists, don't file a second one — add the new
information as a comment (`gh issue comment <n> --body "..."`) instead, and (for
backlog processing) delete the staging entry as already covered. If a matching
issue exists but is closed and the problem has recurred, reopen it
(`gh issue reopen <n>`) rather than filing a fresh duplicate, unless the recurrence
is different enough to warrant its own tracking.

## Group by root cause, split by Definition of Done

The policy this skill implements: **group related reports under one issue by root
cause rather than one per symptom, but split back out when a report actually
bundles more than one distinct Definition of Done.** Two directions this cuts:

- **Merging in**: if you're processing several `docs/ISSUES.md` entries (or an
  entry plus an existing open issue found in the duplicate check) that trace back
  to the same underlying defect, file — or update — a single issue covering all of
  them rather than one per symptom. Note each contributing report in the issue's
  Context section so the connection is traceable later.
- **Splitting out**: it's easy for a single informally-written entry to bundle "fix
  this one thing" with "and also sweep the whole codebase for the same pattern"
  and "and someone should build a script for this" — three different Definitions
  of Done, three different units of work, three different people (or agents) who
  might reasonably pick just one up. Forcing that into one GitHub issue makes it
  unclear when the issue is actually done. File **one GitHub issue per distinct
  Definition of Done**, even when they all trace back to the same source note —
  give each its own title, labels, and Requirements/DoD.

Not every entry needs splitting — plenty describe exactly one thing, and not every
pair of entries shares a root cause. The signal to watch for, in each direction, is
whether two things read as the same underlying problem restated, or one thing reads
as a list of separate asks.

## Not every finding is fileable

Some findings are investigations that concluded "this is working as designed"
rather than defects. Filing one as a GitHub issue would just create a tracker item
with no actual work to do.

- If a `docs/ISSUES.md` entry is fully closed with nothing actionable left
  (confirmed not a bug, no follow-up recommended), it doesn't need to become an
  issue — but don't silently delete it either. A "confirmed not a bug" note can
  still be useful context for whoever hits the same-looking symptom next. When in
  doubt about removing a closed entry versus leaving it in place, ask the user
  rather than guessing.
- If the entry has a genuine, still-open follow-up buried inside an otherwise
  "confirmed not a bug" writeup, file *that* follow-up as its own issue even
  though the original finding wasn't itself a defect.

## Filing mechanics

1. Confirm what labels the project actually uses: `gh label list`, and check
   `.github/ISSUE_TEMPLATE/*.md` if the project has one — each template's
   frontmatter declares the label it applies (e.g. `bug_report.md` → `bug`,
   `feature_request.md` → `enhancement`). An issue can carry more than one label
   when it genuinely spans categories.
2. For each fileable unit of work, copy this skill's `resources/gh-issue.md` to a
   scratch file and fill it in:
   - **Type** and **Reference** (omit the reference line if not applicable).
   - **Context**: quote or summarize the originating finding, so a reader with
     zero session context can trace why this issue exists — including every
     report it was grouped from, if more than one.
   - **Requirements**, **Definition of Done**, **Out of Scope**, **Validation**,
     and an initial unchecked **Checklist** — same rigor regardless of whether
     this was scoped fresh or sourced from a staging note.
3. Write plainly. An issue body is prose for a human audience, same as a commit
   message or PR description: say what happened and what's needed, without stock
   intensifiers ("robust," "leverage," "delve," "seamless"), the "it's not just X,
   it's Y" construction, or a reflexive rule-of-three list. Match the register of
   the rest of the project's issues rather than defaulting to marketing tone.
4. File it:
   ```bash
   gh issue create --title "<short title>" --body-file <rendered-file> \
     --label <label>[,<label>...]
   ```
5. If this came from `docs/ISSUES.md`, delete the entry (or the now-filed portion
   of it) from the file.

## Committing the filing pass

Filing issues and editing `docs/ISSUES.md` is itself a change to a tracked repo
file — it needs a branch, same as anything else (see `git-branching`; this counts
as informal work with no tracking issue of its own, not an exemption). Once the
entries you're processing are filed, commit the `docs/ISSUES.md` deletions and
open a PR per `github-pr-merge`. This pass doesn't need — and shouldn't get — a
GitHub issue of its own; it's the mechanism that produces issues, not a unit of
tracked work itself.

Once an issue exists, everything about actually working it — branching against it,
checking off its checklist, closing it via a PR's `Closes #N` — is
`github-issue-workflow`'s concern, not this skill's. This skill's job ends the
moment the issue is filed (and, if applicable, the staging entry is gone).

## Creating GitHub issues is a visible action

Opening an issue is visible to anyone with access to the repo, the same way
opening a PR or posting a comment is — it's not a private, reversible-without-a-
trace action. This skill only runs when explicitly invoked (the user asked to file
the backlog, process `docs/ISSUES.md`, or file a specific finding) — it should
never fire as an automatic side effect of another skill's own run. A skill that
writes *to* `docs/ISSUES.md` shouldn't turn around and file what it just wrote
without being separately asked to.
