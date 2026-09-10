---
name: documentation-bootstrap
description: Covers going from a project with an incomplete or missing doc set to a full, internally-consistent set of bootstrapped docs, written in parallel and reconciled against each other. Precondition — the project is missing docs and needs initial or partial scaffolding (a top-up run on a partially-documented project is the common case, not just true first-time bootstrap), or the user explicitly asks to "start the documentation process," "bootstrap the docs," or similar. Postcondition — the user has confirmed which doc types apply via an explicit selection pass (doc types that already exist are shown as already satisfied, not regenerated), every newly-confirmed doc type exists and is internally correct, a single orchestrator-determined sequencing/fact rule was passed to every doc-writing subagent so they don't contradict each other, and a post-bootstrap validation pass has confirmed no subagent overstepped its assigned file(s) and that facts (versions, dates, feature descriptions) agree across CHANGELOG/ARCHITECTURE/DECISIONS/the status doc. This is a one-time or occasional bulk operation, not a per-commit check — for per-commit doc-sync and missing-doc detection on an already-scaffolded project, see the `documentation-sync` skill instead.
---

# Bootstrapping a project's documentation

A project that's been running for a while without this plugin, or that only ever
had a README, doesn't have a doc gap from one change — it has a doc gap from every
change it's ever made without one. `documentation-sync` catches the first kind of
gap (a single change with no doc home); it isn't built for the second. This skill
is for the second: standing up, or topping up, a project's whole doc set at once,
written from its actual history rather than invented, and checked for internal
consistency before anything is committed. Once the doc set exists, go back to
`documentation-sync` for keeping it in sync commit by commit — this skill isn't a
replacement for that, just the one-time (or occasional) catch-up before it.

**Before anything else: confirm `git branch --show-current` is not `main`.** This
is inherently a parallel batch (see Step 5), so load `git-branching` for the
integration-branch shape rather than branching directly off `main` yourself.

## Step 1 — Doc-type selection

Don't assume which doc types this project needs. Present the user one multi-select
checklist covering every doc type from `documentation-sync`'s doc-type table, with
three rules:

- **A doc type that already exists is shown pre-checked and labeled "already
  exists — will be skipped."** This skill tops up what's missing; it doesn't
  regenerate a doc that's already there, even if it looks thin. If an existing
  doc genuinely needs a rewrite rather than a top-up, that's a `documentation-sync`
  judgment call (or an explicit, separate ask), not something this skill decides
  on its own.
- **Missing "standard" types are pre-checked by default** — README, the project's
  status doc, and CHANGELOG (only when the project already has releases).
- **Every other missing type starts unchecked.** The user's explicit confirmation
  is what puts a type in scope — even one that looks obviously applicable, like
  ARCHITECTURE.md for a clearly non-trivial codebase. Guessing here is exactly
  the mistake this step exists to prevent: a doc nobody asked for is still a doc
  someone now has to maintain.

Load `resources/doc-type-menu.md` for the full option list, how to tell "already
exists" from "missing," how to tell whether CHANGELOG counts as standard here, and
a literal example of how to phrase this as a checklist prompt.

## Step 2 — Subagent count

Ask the user how many subagents to run in parallel: `1`, `2`, `4` (default), `6`,
or `as many as needed`. "As many as needed" resolves to one subagent per
confirmed-and-missing doc type after the grouping rule in Step 4, hard-capped at
**8** — more parallel writers than that risks burning through a session's budget
for a task that isn't usually urgent. If the confirmed set still exceeds 8 after
grouping, that's unusual enough to flag back to the user and ask how to
prioritize, rather than silently picking which docs to defer.

## Step 3 — Determine the sequencing rule, before spawning anyone

Every doc-writing subagent is about to independently read the same git history and
draw its own conclusions about what happened and when. Left alone, a CHANGELOG
subagent and an ARCHITECTURE subagent can easily disagree — one says a feature
shipped in v1.2, the other describes it as still in progress — not because either
is wrong on its own terms, but because nobody made them agree on the same facts
first.

The orchestrator (you, before spawning anything) fixes this by deciding, once, who
speaks for which class of fact, then pasting that decision verbatim into every
subagent's prompt. This isn't a suggestion each subagent can override — it's the
one shared foundation everyone's writing is checked against afterward, and the
reason Step 6's validation pass exists at all is to catch a subagent that ignored
it. Load `resources/sequencing-rule.md` for the fact classes that usually need
this and a compact template for stating the rule.

## Step 4 — Group for the ceiling

If the confirmed-missing doc types outnumber the subagent count from Step 2,
cluster the small, GitHub-native, non-narrative types into one subagent: PR
template, issue templates, CODEOWNERS, and dependabot.yml. These are short,
templated, and don't require independent research the way a narrative doc does, so
one subagent handling all of them together doesn't lose anything a split would
have gained. Every narrative doc type (ARCHITECTURE, SPEC, DECISIONS, GOTCHAS,
API, USER_GUIDE, DEPLOYMENT, NON_NEGOTIABLES) stays one-per-subagent — each of
those needs its own research pass over the codebase and history, and bundling them
risks exactly the shallow, half-researched doc this whole skill exists to avoid.

## Step 5 — Parallel batch execution

This is a parallel batch in the same shape `git-branching` and `github-pr-merge`
already define — don't re-derive it, follow it:

- Integration branch off `main` for the whole run; each subagent branches from
  *that*, never from `main` directly.
- Every subagent spawned for this batch must be spawned with `isolation:
  "worktree"` — this is `git-branching`'s hard requirement, not optional here
  just because the work is "just docs." Don't re-derive the reasoning; load
  `git-branching` if you need it restated.
- Each subagent is scoped to exactly one doc type (or its Step 4 cluster) and
  touches only that file — never let two subagents write to a shared,
  single-section file concurrently (e.g. if a top-up run somehow assigns two
  subagents anywhere near `CHANGELOG.md`'s `[Unreleased]` section, that's a
  scoping mistake to fix before spawning, not something to resolve by merge
  order).
- Every subagent is fresh and non-fork (`general-purpose`), per this repo's
  blanket no-fork-for-delegation rule.
- Each subagent's spawn prompt must include, explicitly: (a) its assigned doc
  type(s), (b) the sequencing rule from Step 3, copied in verbatim, not
  paraphrased, and (c) a statement that it does not have merge authority for this
  task.
- Merging a subagent's PR into the integration branch is the orchestrator's job
  alone, via `github-pr-merge`'s `resources/scripts/gh_merge_guard.sh <pr>
  --squash`, with the same fix-round cap of 2 that skill already sets.

## Step 6 — Post-bootstrap validation

Run this once, after every subagent's PR has merged into the integration
branch — not per-subagent as each one finishes. Checking a doc against its own
sources is one thing; checking it against sibling docs written in parallel only
makes sense once all the siblings exist. Spawn two fresh, non-fork subagents:

- **Cross-doc consistency + scope check** (report-only — it never edits anything
  itself) — confirms no subagent touched a file outside its assignment, and that
  the fact classes from Step 3 actually agree across the docs that cite them. Load
  `resources/cross-doc-validation.md` for its spawn prompt and checklist.
- **CHANGELOG-specific correctness check** (this one *may* fix `CHANGELOG.md`
  directly, since its whole scope is the single file it's already validating) —
  confirms every entry is actually derivable from git/PR history rather than
  invented. Load `resources/changelog-validation.md` for its spawn prompt and
  checklist.

The cross-doc validator's findings go back to you, not into a silent fix — decide
whether to correct it yourself or spin up one more fix-round-capped subagent
(same cap of 2, counted across this whole bootstrap run, not reset per doc).

## Step 7 — Finish the batch

Follow `github-pr-merge`'s review, merge, and cleanup sections as written: one
integration-branch-to-`main` PR for the whole batch, merged only by the user,
followed by full branch and worktree cleanup, verified on both local and remote.
If this run touched any skill's `SKILL.md` or `resources/`, this is also where
the single `plugin.json` version bump happens (see the special case below) —
before opening the batch's final PR to `main`.

## Special case: this run itself edits a skill in this repo

If you're running this skill inside the `skills` repo itself — bootstrapping this
repo's own docs, or the PR that adds this skill in the first place — that's a
`documentation-sync` "editing a skill in this repo" case too: bump the `version`
field in `.claude-plugin/plugin.json` in the same PR, per that skill's own rule.

**If this run is a parallel batch** (Step 5), the bump happens exactly once,
during the orchestrator's Step 7 consolidation on the integration branch —
never in an individual subagent's PR. A subagent's own PR targets the
integration branch, not `main`, and per `documentation-sync`'s scoping rule, a
PR that doesn't target `main` must not bump `plugin.json` itself.
