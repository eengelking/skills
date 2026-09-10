---
name: documentation-sync
description: Covers going from an uncommitted change to a commit whose accompanying docs are correct, or a deliberate confirmation that none apply. Precondition — a change is staged or about to be committed, in any project. Postcondition — every doc that owns a slice the change touches is updated in the same commit — a state fact goes in the project's status doc (e.g. CLAUDE.md), a procedure goes in the skill that owns it, and a case that fits neither cleanly gets asked about rather than guessed. Load this before committing any change, not just before a release — a change that isn't reflected in the doc describing it is exactly the kind of gap that's invisible until someone hits it. Project-specific routing tables live under resources/ (e.g. resources/localscore.md, resources/certifications.md); if the current repo has no matching resource file yet, work from the general framework below and consider drafting one.
---

# Keeping documentation in sync

**Before anything else: confirm `git branch --show-current` is not `main`.** If it
is, stop and load `git-branching` — do not commit, and do not treat "this change is
too small to need a branch" as a reason to skip that step. This is a second
checkpoint on top of any project status doc's own Git workflow rule, precisely
because it's caught skipped in the past for informal work with no tracking issue.

Documentation in a project lives in several places, each owning a different slice.
Nothing enforces that a code change updates the doc describing it — that's what
this checklist is for. Run it before every commit, not just before a release.

## Find the project-specific routing table first

Check `resources/` in this skill for a file matching the current repo (e.g.
`localscore.md`, `certifications.md`). That file has the concrete table — which doc
owns which kind of change, in that specific project — plus any project-only
conventions (voice, changelog style, etc. for that repo).

If no resource file matches the current repo, apply the general framework below
directly, then consider drafting a new resource file from what you learn so the
next session doesn't have to rediscover it.

## Three failure modes, not one

A change can go wrong against documentation in three distinct ways. Checking only
"which row of the routing table matches this change" catches the first but silently
misses the other two:

1. **Stale** — doc content that used to be true and no longer is (a hardcoded
   count, a list of steps that's grown since it was written, a feature described
   as "not built yet" that this change just built). The project's routing table is
   aimed mostly at this case: it tells you which doc to open when a change of a
   given *kind* happens.
2. **Invalid** — doc content that's wrong or misleading *right now*, independent of
   whether it was ever accurate — e.g. a doc describing behavior that was never
   actually implemented as written, or a cross-reference to a file/section that's
   since moved. This can be true even on a change that doesn't touch that doc's
   subject at all; if you notice it in passing, fix it or flag it, don't leave it
   for later.
3. **Missing** — a new artifact, tool, script, concept, or convention introduced by
   this change has **no home in any existing doc at all**. The routing table
   answers "which doc owns this kind of change" — it can't answer "does a doc for
   this kind of change exist yet." Before closing out the doc-sync pass, ask that
   second question explicitly: is there a new noun (a script, a config setting, a
   skill, a workflow concept) this change introduced that nothing currently
   describes? If so, that's a missing-doc gap even though no table row is stale —
   don't let "no row matched" read as "nothing to do."

If none of the project's table rows apply, say so — most commits (a single bug fix,
a content correction) only need a changelog line. But check the table rather than
assuming; a silently stale API doc, config table, or — easy to forget precisely
because you're reading it rather than writing to it — a status doc's own "current
state" section is exactly the kind of gap that's invisible until someone hits it. A
project's status doc (CLAUDE.md or equivalent) is often the first thing read at the
start of a session; a stale claim there about what's blocked, what phase is
complete, or which task is next actively misleads the *next* piece of work, not
just this one.

Then run the three-failure-mode check above regardless of which rows matched — a
clean table match only rules out "stale in an obvious, already-documented way," not
"invalid" or "missing."

## When in doubt: fact or procedure?

Two kinds of doc content get confused with each other, since both can be triggered
by the same event (e.g. finishing a task). Ask: *is this something true about the
project right now, or something true about how to do a kind of work here regardless
of when?*

- "KCNA has 121 questions" is a **fact** — it'll be false again the next time
  someone adds a question, so it belongs in the project's status doc.
- "Cert PRs into an integration branch aren't squashed" is a **procedure** — it
  doesn't age the same way, so it belongs in the skill that owns that workflow
  (e.g. `github-pr-merge`).

**If it genuinely doesn't sort cleanly into either bucket, don't guess — ask the
user.** Picking wrong here is exactly how the split degrades over time: a fact
written into a skill goes stale invisibly (skills aren't read every session, so
nobody notices), and a procedure written into a status doc quietly re-bloats the one
file every session pays for, undoing the reason this split exists. Both failure
modes are worse than pausing to ask, and neither is a call an agent should make
alone when it's genuinely unclear.

## Resources

- `resources/localscore.md` — routing table and conventions for the localscore
  repo (also see `documentation-voice-guide` for its prose voice and global
  workflow rules).
- `resources/certifications.md` — routing table and conventions for the
  certifications repo.
