---
name: documentation-sync
description: Covers going from an uncommitted change to a commit whose accompanying docs are correct, or a deliberate confirmation that none apply. Precondition — a change is staged or about to be committed, in any project. Postcondition — every doc that owns a slice the change touches is updated in the same commit — a state fact goes in the project's status doc (e.g. CLAUDE.md), a procedure goes in the skill that owns it, a spec-governed behavior defers to SPEC.md, and a case that fits neither cleanly gets asked about rather than guessed. Load this before committing any change, not just before a release — a change that isn't reflected in the doc describing it is exactly the kind of gap that's invisible until someone hits it. This is a generic, project-agnostic skill; a project's own doc-ownership table (which doc owns which kind of change, in that specific repo) belongs in that project's own `.claude/skills/`, not here.
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

This skill is generic and project-agnostic by design — it holds no per-repo
routing tables itself. Check the current repo's own `.claude/skills/` for a
project-specific `documentation-sync` skill (or equivalent doc-ownership table,
often referenced from that project's `CLAUDE.md`). That's where the concrete
table lives — which doc owns which kind of change, in that specific project —
plus any project-only conventions (voice, changelog style, etc.).

If the repo has no such table yet, apply the general framework below directly,
and consider drafting one in that project's own `.claude/skills/` (not here) from
what you learn, so the next session doesn't have to rediscover it.

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

- "The catalog has 121 entries" is a **fact** — it'll be false again the next
  time someone adds an entry, so it belongs in the project's status doc.
- "PRs into an integration branch aren't squashed" is a **procedure** — it
  doesn't age the same way, so it belongs in the skill that owns that workflow
  (e.g. `github-pr-merge`).

**If it genuinely doesn't sort cleanly into either bucket, don't guess — ask the
user.** Picking wrong here is exactly how the split degrades over time: a fact
written into a skill goes stale invisibly (skills aren't read every session, so
nobody notices), and a procedure written into a status doc quietly re-bloats the one
file every session pays for, undoing the reason this split exists. Both failure
modes are worse than pausing to ask, and neither is a call an agent should make
alone when it's genuinely unclear.

## SPEC.md is the source of truth, when a project has one

If the current project has a `SPEC.md` (commonly `docs/SPEC.md`), it — not any
other doc, and not code — is the single source of truth for intended behavior.
Before implementing or touching code in an area `SPEC.md` covers, read the actual
section yourself; don't rely on a paraphrase in another doc, a status doc's
summary, or memory of what it used to say.

- **If code and `SPEC.md` disagree, `SPEC.md` wins — no exception** — unless the
  user explicitly states the spec itself should change, and confirms that change
  as its own separate gate before it's made. Implying agreement, or the user
  staying quiet after you raise it, is not that confirmation.
- **Don't silently pick a reading, and don't "fix" a contradiction in passing** —
  flag it and ask. A code/spec mismatch is a decision for the user, not a doc-sync
  judgment call.
- Other docs (status trackers, notes, README) should **link back to the relevant
  `SPEC.md` section** rather than restating its requirements in their own words —
  two descriptions of the same requirement is exactly how they quietly drift
  apart.

## Recognizing what kind of doc a change needs

A project accumulates more doc *types* than any one routing table entry names
explicitly. When deciding whether a change has a home, check it against the doc
types below rather than only the rows a project's own table happens to list —
not every project needs every type, but a change that doesn't match any existing
doc *and* doesn't match one of these types either is a strong signal to ask,
not assume.

| Doc type | What it owns | Applies when... |
|---|---|---|
| `README.md` | Orientation for someone landing in the repo | Always |
| `LICENSE` | Legal terms for use/distribution | The repo is, or may become, public |
| `CHANGELOG.md` | One entry per release | The project cuts versioned releases |
| `CONTRIBUTING.md` | How an outside contributor proposes a change | The repo accepts contributions beyond the maintainer |
| `SPEC.md` (e.g. `docs/SPEC.md`) | Source of truth for intended behavior/requirements — see above | The project is complex enough to need requirements independent of the code |
| `ARCHITECTURE.md` (e.g. `docs/ARCHITECTURE.md`) | System structure and data flow, for humans | The system is non-trivial enough to outgrow the status doc's own architecture notes |
| `DECISIONS.md` (e.g. `docs/DECISIONS.md`) | Log of significant design/architecture decisions and their rationale | The project has made non-obvious tradeoffs worth preserving the reasoning for |
| `GOTCHAS.md` (e.g. `docs/GOTCHAS.md`) | Known sharp edges and non-obvious pitfalls | The project has accumulated gotchas that would otherwise get retaught each time someone hits them |
| `API.md` (e.g. `docs/API.md`) | A public or consumed API surface | The project exposes an API |
| `USER_GUIDE.md` (e.g. `docs/USER_GUIDE.md`) | End-user-facing usage, distinct from developer docs | The project has end users, not just developers/maintainers |
| `DEPLOYMENT.md` (e.g. `docs/DEPLOYMENT.md`) | How to deploy and operate the project | The project is deployed somewhere beyond local dev |
| `NON_NEGOTIABLES.md` (e.g. `docs/NON_NEGOTIABLES.md`) | Hard, project-specific constraints that never get traded away for convenience | The project has constraints specific to it that are non-negotiable regardless of convenience |
| `ISSUES.md` (e.g. `docs/ISSUES.md`) | Staging inbox for informally-found issues before triage into GitHub Issues | The project uses this staging pattern — see `github-issue-filing` |
| `.github/PULL_REQUEST_TEMPLATE.md` | Standard PR checklist | Repo ships a PR template |
| `.github/ISSUE_TEMPLATE/*.md` | Standard issue intake forms | Repo ships issue templates |
| `.github/CODE_OF_CONDUCT.md` | Community behavior expectations | The repo has, or expects, outside contributors |
| `.github/SECURITY.md` | How to report a vulnerability | The repo is public |
| `.github/CODEOWNERS` | GitHub-native automatic review assignment by path | The repo has multiple maintainers/reviewers |
| `.github/dependabot.yml` | Automated dependency-update config | The project has dependencies worth automating updates for |
| A project's own status doc (e.g. `CLAUDE.md`) | Current-state facts and narrative — see fact-vs-procedure above | Always |

This table is a checklist for recognizing doc *types*, not a project-specific
routing table — a given project's actual doc set, and which of these it has
adopted, still lives in that project's own status doc or its own
`.claude/skills/documentation-sync`.

## Special case: editing a skill in this repo

If the change being committed edits a `SKILL.md` or a skill's `resources/` in
this repo, that's a doc-sync case with one extra step: bump the `version` field
in `.claude-plugin/plugin.json`. This repo ships all its skills as a single
plugin (`skills`), so there's no per-skill version — one version field covers
every skill, and it's what a `/plugin marketplace update` actually checks to
decide whether there's anything new to pull. Skipping the bump means the fix or
addition sits in `main` but nobody who already installed the plugin gets it.
Bump the patch component for wording/clarity fixes, the minor component for new
guidance or behavior change, consistent with the version history already in that
file.
