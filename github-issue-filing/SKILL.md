---
name: github-issue-filing
description: Converts entries in docs/ISSUES.md — a transient staging inbox for informally-discovered findings (a live bug, a content-audit result, a UAT note, a tooling idea) — into real, tracked GitHub issues, then deletes the filed entries from docs/ISSUES.md. Precondition — asked to process docs/ISSUES.md and file its entries as GitHub issues (a backlog-processing pass over things already written down). This is NOT for scoping brand-new work directly out of a live conversation — that's `feature-development`, which opens the issue straight from the conversation with no staging-file detour. Postcondition — every entry that describes one fileable unit of work exists as a GitHub issue (title, body from templates/gh-issue.md, correct label(s)), its docs/ISSUES.md entry is deleted, and the change is committed and opened as a PR per the normal git-branching/github-pr-merge flow. Load this before converting docs/ISSUES.md findings into GitHub issues, or when asked to "file the issues", "process ISSUES.md", or "clear the backlog into GitHub."
---

# Filing docs/ISSUES.md entries as GitHub issues

`docs/ISSUES.md` exists so nothing discovered informally gets lost before it's
triaged — but a markdown file isn't where ongoing work should live once it's real:
GitHub is. This skill is the one-way conversion step between the two: read an
entry, decide what it actually needs, file it as a properly labeled GitHub issue,
and remove it from the staging file so the file stays a short-lived inbox instead
of a permanent, unbounded log.

This is a distinct on-ramp from `feature-development`. That skill scopes work
directly out of a live conversation (a user asks for something right now, an agent
edits docs/SPEC.md, then opens the issue) with no staging-file step at all. This
skill only ever processes what's already been written down in `docs/ISSUES.md` —
if you're scoping something new instead of clearing the backlog, load
`feature-development`, not this skill. If the entry specifically asks for a
certification to be researched (a new path, or re-researching an existing
"complete" cert's blueprint), load `cert-scoping` instead — it's the specialized
front end to `feature-development` that produces that kind of hand-off issue.

## One entry can become several issues

The load-bearing judgment call here is recognizing when a single ISSUES.md bullet
actually describes more than one piece of work. It's easy for an informally-written
entry to bundle "fix this one thing" with "and also sweep the whole bank for the
same pattern" and "and someone should really build a script for this" — three
different Definitions of Done, three different kinds of work, and three different
people (or agents) who might reasonably pick just one of them up. Forcing that into
a single GitHub issue makes it unclear when the issue is actually done: does fixing
the one instance close it, or does someone still owe the sweep and the script?

File **one GitHub issue per distinct Definition of Done**, even when they all trace
back to the same ISSUES.md bullet. Give each its own title, its own labels, and its
own Requirements/DoD — don't let breadth in the source note turn into scope
ambiguity in the tracker.

Not every entry needs splitting — plenty describe exactly one thing. The signal to
watch for is an entry that reads as a list of separate asks rather than one
problem statement, especially ones explicitly called out as "not yet scoped as a
task" or "a tooling idea" alongside a concrete fix.

## An entry isn't automatically fileable

Some ISSUES.md entries are investigations that concluded "this is working as
designed" rather than defects — read `docs/ISSUES.md`'s existing entries for
examples (a UI pagination-style choice confirmed as deliberate, a scheduling
question confirmed correct against docs/SPEC.md). Filing one of these as a GitHub
issue would just create a tracker item with no actual work to do.

- If the entry is fully closed with nothing actionable left (confirmed not a bug,
  no follow-up recommended), it doesn't need to become an issue — but don't
  silently delete it either. A "confirmed not a bug" note can still be useful
  context for whoever hits the same-looking symptom next. When in doubt about
  whether to remove a closed entry versus leave it in place, ask the user rather
  than guessing — deleting a still-relevant historical note loses something a
  quick question would have preserved.
- If the entry has a genuine, still-open follow-up buried inside an otherwise
  "confirmed not a bug" writeup (a UI-visibility idea, a suggested SPEC.md
  revision), file *that* follow-up as its own issue even though the original
  finding wasn't itself a defect.

## Filing mechanics

1. Confirm the label taxonomy is available: `gh label list`. The repo's labels are
   `bug`, `content`, `documentation`, `enhancement` (general-purpose, pre-existing)
   plus `tooling` (scripts/CI/automation ideas), `ui-ux` (docs/SPEC.md §13-governed
   interface work), `spec-change` (needs a docs/SPEC.md decision before work can
   start), and `needs-decision` (blocked on a user call before work can proceed). An
   issue can carry more than one label — a content fix that also motivates a
   checker script is legitimately `content` + `tooling`.
2. For each fileable unit of work, copy `templates/gh-issue.md` and fill it in:
   - **Type** and **Spec reference** (omit the spec line if not applicable).
   - **Context**: quote or summarize the originating docs/ISSUES.md entry, so a
     reader with zero session context can trace why this issue exists.
   - **Requirements**, **Definition of Done**, **Out of Scope**, **Validation**,
     and an initial unchecked **Checklist** — same rigor as an entry authored
     directly by `feature-development`; being sourced from a staging note doesn't
     excuse a thinner scoping pass.
3. File it:
   ```bash
   gh issue create --title "<short title>" --body-file <rendered-file> \
     --label <label>[,<label>...]
   ```
4. Delete the entry (or the now-filed portion of it) from `docs/ISSUES.md`.

## Committing the filing pass

Filing issues and editing `docs/ISSUES.md` is itself a change to a tracked repo
file — it needs a branch, same as anything else (see `git-branching`; this
counts as "informal work with no tracking issue of its own," not an exemption).
Once the entries you're processing are filed, commit the `docs/ISSUES.md` deletions
and open a PR per `github-pr-merge`. This pass doesn't need — and shouldn't get — a
GitHub issue of its own; it's the mechanism that produces issues, not a unit of
tracked work itself.

Once an issue exists, everything about actually working it — branching against it,
checking off its checklist, closing it via a PR's `Closes #N` — is `github-issue-workflow`'s
concern, not this skill's. This skill's job ends the moment the issue is filed and
the staging entry is gone.

## Creating GitHub issues is a visible action

Opening an issue is visible to anyone with access to the repo, the same way opening
a PR or posting a comment is — it's not a private, reversible-without-a-trace
action. This skill only runs when explicitly invoked (the user asked to file the
backlog, or process `docs/ISSUES.md`) — it should never fire as an automatic side
effect of another skill's own run. `content-audit` and `documentation-sync` both write *to*
`docs/ISSUES.md`; neither of them should turn around and file what they just wrote
without being separately asked to.
