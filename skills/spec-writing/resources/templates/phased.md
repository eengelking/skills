# SPEC: <Project name>

<One or two paragraphs: what this is, who uses it, and — if the domain has
real-world grounding (regulatory, industry-specific, etc.) — the context that
makes later phases judgeable without re-deriving it each time.>

## 1. Goals and non-goals

### Goals
- <Concrete capability.>

### Non-goals (do NOT build these)
- <Something a reasonable builder might assume is in scope — ruled out by name.>

## 2. Tech stack

| Concern | Choice | Why |
|---|---|---|
| … | | |

## 3. Glossary

<Only if the domain has vocabulary a builder can't be assumed to know. Delete
this section entirely if not.>

## 4. Architecture / components

<One subsection per subsystem — enough that a task inside it knows what it's
building against without re-reading the whole spec.>

## 5. Data model

<As needed.>

## 6. Feature flags

<If later phases build behavior that must stay dark until its phase
completes, list the flag and which phase turns it on. Flag the config, not
the code path.>

## 7. Phased build plan

Phases execute in order; each ends in a runnable, committed state.

### Phase 1 — <name>
**Goal:** <what exists after this phase that didn't before.>

#### <Task title>
- **Scope:** <functional-area sentence>
- **Depends on (in-phase):** none — ready to start
- **Acceptance:**
  1. <testable statement>

#### <Task title>
- **Scope:** …
- **Depends on (in-phase):** <previous task title>
- **Acceptance:**
  1. …

**Exit criterion:** <the specific, checkable state that means this phase is
done — not "everything above is implemented," a concrete behavior someone can
observe.>

### Phase 2 — <name>
**Goal:** …
**Needs from Phase 1:** <name the specific Phase 1 deliverable(s) this phase's
tasks depend on — not just "Phase 1" as a whole.>

#### <Task title>
- …

**Exit criterion:** …

<Repeat per phase.>

## 8. Explicitly out of scope / deferred

- <Thing the design must not preclude later, but no phase implements now.>

## 9. Open questions / future roadmap

- <Anything genuinely undecided.>

---

Consider adding `docs/WORK.md` once there are more than a handful of phases —
a live checkbox tracker per milestone, status only, never restating
acceptance criteria that already live here or in the issues.
