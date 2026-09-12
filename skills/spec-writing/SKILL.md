---
name: spec-writing
description: Turns a rough project idea, a premade brief/PRD, or a back-and-forth conversation into a SPEC.md that is decomposable into unambiguous, dependency-ordered tasks — then files those tasks as GitHub issues. Precondition — asked to draft, write, or overhaul a SPEC.md / project spec / build spec, plan out a project's build order, turn a brief or PRD into an execution plan, or break a large feature down into GitHub issues with dependencies; also load this before decomposing an *existing* SPEC.md's scope into tasks, even if the document itself doesn't need changes. Postcondition — SPEC.md exists (or is updated) with goals/non-goals and an explicit weight-class decision (flat list, phased, or staged DAG — see below), its task-breakdown section groups tasks into functional categories with explicit Depends-on relationships and testable acceptance criteria, and every task in that breakdown has been filed as its own GitHub issue with correct labels and cross-linked dependencies via `github-issue-filing` — no task is left living only in SPEC.md prose. Load this whenever a spec needs writing from scratch, needs its scope re-decomposed, or a user says things like "let's spec this out," "turn this PRD into issues," or "what's the build plan for X."
---

# Writing a SPEC.md

A SPEC.md earns its place only if it can be cut into tasks that different agents
(or different people) would scope identically from reading the same section. A
spec that reads well but leaves task boundaries fuzzy has failed at its actual
job — task-writing agents will draw the lines differently, tasks will collide on
files, and dependencies will be guessed rather than known. Everything in this
skill exists to prevent that failure, not to produce a longer document.

The other standing rule, non-negotiable regardless of project size: **a task
exists nowhere but a GitHub issue.** SPEC.md's task-breakdown section is the
*source* a task gets written from, never itself the ledger. A "task list" that
lives only as markdown checkboxes in SPEC.md, `docs/WORK.md`, or a PR description
is not done until it's also an issue — see "Filing the tasks" below.

## Two ways in

- **A premade document exists.** The user hands over a brief, PRD, notes doc,
  transcript, or an existing (possibly stale or incomplete) SPEC.md. Read it in
  full before asking anything — most of what you'd otherwise ask is already
  answered in there, and re-asking it reads as not having read the document.
  Use the clarification pass (below) only for what the document leaves
  genuinely ambiguous or silent on.
- **No document exists.** Run a back-and-forth Q&A session before drafting
  anything. Do not draft a full SPEC.md from a single short message and present
  it as done — a spec built on one round of guessing is exactly the kind of
  fuzzy-boundary document this skill exists to prevent. At minimum, before
  drafting, pin down: what the thing is and who uses it; explicit non-goals
  (what it deliberately will not do, not just what it doesn't mention); the
  tech stack, if the user has a preference or an existing codebase to match;
  roughly how big this is — a weekend build, a few weeks, or a multi-month
  multi-agent effort (this drives the weight-class decision below); and, for
  every entity the idea implies has a lifecycle (an incident, an order, a
  request — anything that opens and later closes), how it actually closes.
  That last one is easy to skip because the request rarely states it, but a
  downstream task (a digest, a report, a status check) almost always silently
  depends on the closing condition — better to ask now than have that task's
  agent guess.

  If a live back-and-forth genuinely isn't available (no human to answer in
  the moment), don't stall — draft with clearly flagged assumptions for each
  open question instead, list them in the Open Questions section, and treat
  the result as provisional until someone actually confirms it. That's a
  fallback for when asking isn't possible, not a substitute for asking when
  it is.

Either way, **draft, then check back with the user before treating the spec as
final** — show the drafted sections (or a summary of the structure and the
judgment calls you made) and let them correct direction before you spend effort
on a task breakdown for the wrong spec. A spec is cheap to redirect before the
task breakdown exists and expensive to redirect after twenty issues reference
its section numbers.

## Picking the weight class

Not every project needs a multi-stage dependency graph with frozen contracts
and named orchestration roles. Forcing that weight onto a weekend build wastes
more effort than it saves; conversely, a large multi-agent build without any
dependency structure will collide constantly. Pick the lightest class that
actually fits — see `resources/weight-classes.md` for the full decision guide
and worked structure for each. In short:

| Class | Fits when | Task structure |
|---|---|---|
| **Flat** | Small, single-agent-at-a-time build (roughly what `louis` or the driving-school mockup in this skill's research were) | One flat, ordered list of tasks, each with a one-line dependency note. No stages, no gates. |
| **Phased** | Medium build with a natural sequence (e.g., "can't do grading before content exists") but no need to run many agents on disjoint file sets at once | Numbered phases, each ending in a runnable/committed state with an exit criterion. Tasks within a phase list their in-phase dependencies; cross-phase order is implicit. |
| **Staged DAG** | Large, multi-month, or explicitly multi-agent-parallel build where many tasks touch overlapping subsystems and need enforced file ownership to avoid collisions | Tasks named by stage (`T<stage>.<nn>`), each with an explicit file-ownership scope, explicit `Depends on` task IDs, and gates between stages. Needs orchestration roles (coordinator/implementer/verifier) — see the same resource file. |

If it's not obvious which class fits, ask the user directly rather than
guessing — the answer changes the shape of the rest of the document, and
re-deriving a flat task list into a DAG later is real rework.

## Structure every SPEC.md needs, regardless of class

Draft into `SPEC.md` (or `docs/SPEC.md` if the project keeps its docs there —
match whatever convention the project already uses). Every spec, light or
heavy, carries these sections; heavier classes add more on top (see
`resources/weight-classes.md` for the additions per class):

1. **Goals and explicit non-goals.** Non-goals are not "things not mentioned" —
   write down what a reasonable builder might assume is in scope and rule it
   out by name. This is the single highest-leverage section for preventing
   scope creep in every downstream task.
2. **Tech stack**, as a table with a one-line rationale per row, not just a
   list of names — the rationale is what keeps a later agent from silently
   swapping a choice that looked arbitrary.
3. **Glossary**, if the domain has vocabulary a builder can't be assumed to
   know (regulatory terms, domain-specific entities). Skip it if the project
   has no such vocabulary — an empty glossary section is worse than none.
4. **The task-breakdown section** (see below) — this is the section every
   other rule in this skill is protecting the quality of.
5. **Explicitly out of scope / deferred**, distinct from non-goals: non-goals
   are permanent; this section is "not now, but the design must not preclude
   it later" (e.g., a schema shaped to add a field cleanly rather than
   retrofit it). Say which is which.
6. **Open questions / future roadmap.** Anything you genuinely don't know or
   the user deferred a decision on. Don't silently resolve these by guessing —
   list them so the next person decides deliberately.

Use `resources/templates/flat.md`, `resources/templates/phased.md`, or
`resources/templates/dag.md` as the starting skeleton for the class you picked
— fill them in rather than starting from a blank page each time.

## Writing the task-breakdown section

This is where ambiguity actually costs something, so hold it to a higher bar
than the rest of the document.

- **Group by functional category, not arbitrarily.** Pick categories that
  reflect real seams in the thing being built (a bounded context, a module, a
  workstream) — categories exist so that tasks *within* one rarely conflict on
  files and tasks *across* two rarely need to touch the same code. "Frontend"
  and "backend" is usually too coarse to prevent collisions; "auth," "billing,"
  "reporting" is closer to the right grain. If you can't articulate why a task
  is in one category rather than another, the categories are wrong.
- **Every task states what it depends on, explicitly, by task ID or issue
  reference — never "later" or "after the backend is done."** A vague
  dependency is not better than none; it just defers the ambiguity to whoever
  files the issue. Two tasks with no shared dependency and no overlapping
  scope can run in parallel; say so if it matters for how the work gets
  staffed.
- **Every task states its scope narrowly enough that two readers would draw
  the same boundary.** For a Staged DAG this is a literal file/path glob list
  (see `resources/weight-classes.md`); for Flat or Phased it can be a
  functional-area sentence ("owns everything under the review-queue UI and its
  API route, nothing in scheduling"), but it must exist in some form. A task
  whose scope is implicit in the surrounding prose is the exact failure mode
  this skill exists to prevent.
- **Every task carries acceptance criteria as testable statements**, not
  descriptions of the work. "Handles edge cases" is not testable; "an invalid
  `sites.yaml` (duplicate names) prevents startup with a named error" is.
  Someone who didn't write the task should be able to verify it from the
  criteria alone.
- **Size tasks for one sitting of focused work**, not a whole category. If a
  task's acceptance criteria run past what one agent or person could
  reasonably verify in one sitting, split it — the split tasks inherit
  whatever dependency the original had on other categories, plus a dependency
  on each other if the split was sequential.

`resources/task-card.md` has the exact template to fill in per task before
filing — same shape regardless of weight class, since it maps directly onto
what `github-issue-filing`'s issue-body template needs.

## Filing the tasks

Once the breakdown is drafted and confirmed with the user, every task becomes
its own GitHub issue. This skill does not reimplement issue-filing mechanics —
that's `github-issue-filing`'s job, including its duplicate-check step (don't
skip that step just because these tasks are freshly drafted; a spec revision
can easily re-propose something already filed). What this skill adds on top,
because the shared issue template has no native concept of task dependencies
or categories:

1. **File in dependency order** — a task with no unfiled dependencies first, so
   that by the time you write a task's issue, every task it depends on already
   has an issue number to link to. Filing out of order means going back to
   edit earlier issue bodies once later numbers exist; avoid the rework by
   sequencing the filing pass itself along the dependency graph.
2. **Put the category as a label** (e.g. `area:billing`, `ws:reporting` — match
   whatever label convention `gh label list` shows the project already using,
   or agree a new one with the user if none exists) alongside `github-issue-filing`'s
   own labels.
3. **Put dependencies in the issue body's Context section**, as explicit
   `Depends on: #12, #14` (or `Depends on: none — ready to start`) — GitHub
   renders `#N` as a live cross-link, so this doubles as documentation and
   navigation. Also carry the task's scope statement there ("Part of SPEC.md
   §4.2 (billing). Depends on: …").
4. **Confirm the dependency graph is acyclic and categories don't overlap
   file-wise** before filing — the same check ERP-style specs run by hand with
   `gh issue list`/`gh issue view` rather than a standing CI gate. Catching a
   cycle before filing is far cheaper than catching it after two agents start
   on mutually-blocked issues.

Once issues exist, everything about actually working one — branching, checking
off its checklist, closing it — is `github-issue-workflow`'s concern, not this
skill's.

## Keeping SPEC.md and the issues in sync

SPEC.md's task-breakdown section describes the plan; GitHub issue labels
(`status:*`, per `github-issue-workflow`) track live status. Don't turn SPEC.md
into a second status tracker — that produces exactly the drift problem
`github-issue-workflow`'s single-ledger rule exists to avoid. Only edit
SPEC.md's task section when the *plan itself* changes (a task splits, scope
moves between categories, a new dependency is discovered) — and when that
happens, note it in the version-history table at the top of SPEC.md if the
project keeps one (see `resources/weight-classes.md`), the same way a schema
or contract change gets recorded.

## Committing

Drafting or editing SPEC.md is a change to a tracked file like any other — it
needs a branch first (`git-branching`) and a PR (`github-pr-merge`), same as
any other change in the project, whether or not the spec itself is tied to a
tracking issue. Filing the resulting GitHub issues is a separate, visible
action (opening issues is as visible as opening a PR) — do it because the
breakdown is ready, not preemptively, and don't let it happen as a silent
side effect of another skill's run.
