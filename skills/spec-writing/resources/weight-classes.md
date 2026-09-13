# Weight classes: deciding how much structure a spec needs

Three classes cover the range from a weekend build to a multi-month multi-agent
platform build. Each is a real pattern observed across existing specs, not a
theoretical scale — cited examples below are the shape a class takes in
practice, not names to copy verbatim.

## Deciding

Ask, in order — the first "yes" picks the class:

1. **Will more than one or two agents ever work on this at the same time,
   touching different subsystems, before the first version ships?** If no —
   one agent/person works through the list roughly in order — use **Flat**.
2. **Does the build have a natural sequence where later work is meaningless
   without earlier work existing (e.g., grading needs content; a dashboard
   needs the data it displays), but not so much simultaneous parallel work
   that file-ownership collisions are a real risk?** Use **Phased**.
3. **Otherwise** — genuinely large scope, many agents expected to work
   different areas concurrently, and collisions on shared files/contracts are
   a real risk without an enforced ownership scheme — use **Staged DAG**.

When genuinely unsure, ask the user how many agents/people they expect working
on this concurrently and over what timeframe; that answer alone usually
settles it.

Don't over-provision "just in case it grows" — a Flat or Phased spec is not
locked in forever. If the project outgrows its class, that's a deliberate,
visible spec revision later (with its own version-history entry), not a
reason to build DAG machinery nobody needs yet.

## Flat

**Shape.** A single ordered (or partially ordered) task list. Each task: a
short title, a one-line functional scope, a one-line dependency note ("none"
or "after: <task title>"), and testable acceptance criteria. No stages, no
gates, no orchestration-role section — one agent works the list roughly
top-to-bottom, occasionally skipping ahead to an independent task.

**What the rest of SPEC.md looks like.** Usually short (a few hundred lines):
goals/non-goals, a tech-stack table, a route/module inventory if it's a web
app, the task list, and an acceptance-criteria section at the end covering the
whole build (distinct from each task's own criteria — this one is "how do we
know the whole thing works," e.g. "starting the server with the example config
shows real data within a few seconds").

**Companion docs.** None needed beyond the issues themselves.

Use `resources/templates/flat.md` as the skeleton.

## Phased

**Shape.** Numbered phases (`Phase 1`, `Phase 2`, …), each phase a named
functional milestone that ends in a runnable, committed state with an
explicit exit criterion ("Exit: the drill session shows generated cards for
seeded content and grades all four question types"). Tasks live inside their
phase, listing in-phase dependencies explicitly; cross-phase ordering is
implicit (a Phase 2 task simply may not start before Phase 1's exit criterion
is met) but each Phase 2+ task should still name which specific Phase 1
deliverable it needs, not just "Phase 1" as a whole — that's what makes the
dependency machine-checkable later rather than a vague temporal claim.

Feature flags are a useful device here when later phases build behavior that
must stay dark until its phase completes (e.g., `ensemble_validation = false`
until the phase that implements it lands) — flag the config, not the code
path, so a half-finished phase never accidentally activates.

**What the rest of SPEC.md looks like.** Substantial (self-contained specs in
this range commonly run past a thousand lines): the standard sections plus a
component/architecture breakdown per subsystem, and — if the domain has
regulatory, compliance, or other real-world grounding — a section establishing
that context before the component sections, so later phases can be judged
against it without re-deriving it each time.

**Companion docs.** A live status tracker (e.g. `docs/WORK.md`) — one checkbox
per milestone, sliced into child checkboxes when a milestone spans multiple
issues/PRs — is worth adding once there's more than a handful of phases; it
answers "what's next" without re-deriving it from `git log`. Keep it to status
only; it never restates acceptance criteria that already live in SPEC.md or
the issues.

Use `resources/templates/phased.md` as the skeleton.

## Staged DAG

**Shape.** Tasks named by stage and sequence (`T<stage>.<nn>`). Every task
states, explicitly:

- **Owns** — the exact file/path globs (plus its own tests) it may create or
  modify. Nothing else. Two tasks with disjoint `Owns` and no dependency
  between them can run fully in parallel; overlapping `Owns` between
  simultaneously-ready tasks is a decomposition bug, not something to resolve
  by serializing around it.
- **Depends on** — other task IDs that must be merged (not just started)
  first.
- **Acceptance criteria** — testable statements, each mapped to a test a
  verifier can run without reading the implementer's reasoning.

Group tasks into **stages** (Stage 0 foundation, Stage 1 core, Stage 2+
parallel workstreams, …) separated by **gates** — a gate only passes once
every task in its stage is merged and verified, and no task in the next stage
starts before its gate passes. Within a stage, tasks are further grouped into
**workstreams** (independent categories that can run in parallel because their
`Owns` sets are disjoint by construction).

**Hub files.** Any file more than one task would otherwise need to edit (a
composition root, an append-only registry, a shared migration range) needs an
explicit protocol stated once, in the architecture section, rather than left
implicit — e.g., "no task edits the composition root to register itself; each
task's own package self-registers via a discovered manifest instead." Without
this, hub files serialize the entire build regardless of how well everything
else is parallelized.

**Orchestration roles.** A DAG this size needs the coordination rules stated
explicitly, not assumed:

| Role | Does | Never |
|---|---|---|
| Coordinator | Assigns ready tasks (every dependency merged and green), resolves ownership disputes, declares gates passed | Implement tasks |
| Implementer | Implements exactly one task, in its own branch, to its acceptance criteria | Touch paths outside its `Owns`; merge its own work |
| Verifier | A *different* agent from the implementer; checks each acceptance criterion against a test in the merged diff, re-runs the suite from clean state | Fix what it finds — a verifier that patches code stops being able to verify it |
| Verifier, at a gate | Same rules, applied to the whole stage, not one task: a fresh, non-implementer agent, from a clean checkout of `main` — not cached state, not any implementer's self-report — re-runs this repo's gate test plus its full CI suite (however this repo's own `development-commands` or docs define "green"). Only a clean pass from that independent run counts as the gate having passed; see `github-release`'s Staged-DAG opt-in for what a passed gate then authorizes | Treat every task in the stage merging as sufficient on its own |
| Integrator | Runs the merge queue in dependency order; may be the coordinator | Merge red CI, or a task that failed verification |

State a lifecycle explicitly too (a minimal version: `todo → assigned →
in_progress → in_review → verified/changes_requested → merged`), and an
escalation rule: an agent that finds two sections of the spec contradicting
each other, or that can't meet its acceptance criteria without touching
another task's `Owns`, stops and escalates rather than guessing — but an
ambiguity that isn't a contradiction gets the most conservative reading,
implemented, and recorded as a decision rather than escalated.

**What the rest of SPEC.md looks like.** The heaviest class: a "how to use
this document" section stating keyword conventions (MUST/SHOULD/DEFERRED), a
constitution of global constraints every task inherits, a glossary, an
architecture section with an explicit module dependency graph, any frozen
interface contracts (and the rule that a task may add to a contract additively
but never edit an existing one after its freeze gate without a recorded spec
change), and a version-history table at the top recording every spec revision
with what changed and why.

**Companion docs.** `docs/GOTCHAS.md` (patterns and gotchas discovered
mid-build, appended by whichever task finds them) and `docs/DECISIONS.md`
(interpretations of ambiguity, contract-freeze status, and gate passage
itself — gate id, commit SHA, and a pointer to the verifier's report) — both
plain docs edited directly by whoever needs to add an entry, no coordinator
fold step.

Use `resources/templates/dag.md` as the skeleton and `resources/task-card.md`
for the per-task card shape (this is the shape a task-writing agent expands
each DAG entry into before it becomes an issue body).
