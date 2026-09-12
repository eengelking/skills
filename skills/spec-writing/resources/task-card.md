# Task card template

Fill this in for every task in the breakdown, regardless of weight class —
lighter classes just have shorter answers to some fields. This is the
intermediate form between "a line in SPEC.md's task-breakdown section" and
"a GitHub issue": everything an implementer needs should be in the card or in
the SPEC.md sections it points to, so nobody needs to search the rest of the
spec to understand the task.

```markdown
# <Task ID or short title> — <one-line description>

<For Staged DAG only:> **Stage** <n>  ·  **Workstream** <name>  ·  **Gate** <G-n>

## Category
<The functional category/workstream this belongs to.>

## Goal
<Two or three sentences: what exists after this task that didn't before, in
the language of the spec's functional sections — not in the language of
files.>

## Scope (the only thing this task creates or modifies)
<For Staged DAG: exact file/path globs, plus its own tests.>
<For Flat/Phased: a functional-area sentence precise enough that a second
reader would draw the same boundary — e.g. "the review-queue UI and its one
API route; nothing in scheduling or notifications.">

## Depends on
<Other task IDs / issue numbers that must be done (merged, not just started)
first, or "none — ready to start.">

## Non-goals
<What a reasonable agent might drift into while doing this and must not —
name the task that actually owns each of those instead.>

## Acceptance criteria
1. <Testable statement — someone who didn't write the task could verify it.>
2. …

## Notes
<Anything already known that would save the implementer from re-deriving it:
a gotcha, the conservative reading of an ambiguity you already anticipated,
a pointer to the exact spec section(s) to read first.>
```

## Turning a filled card into an issue

`github-issue-filing`'s `resources/gh-issue.md` template doesn't have native
`Owns`/`Depends on` fields, so map this card onto it rather than inventing a
parallel format:

| Task card field | Goes into the issue as |
|---|---|
| Category | A label (e.g. `area:billing`) |
| Goal + Scope | The **Context** section: "Part of SPEC.md §<n> (<category>). Scope: <the scope sentence>." |
| Depends on | Also in **Context**, as `Depends on: #12, #14` or `Depends on: none — ready to start` (GitHub auto-links `#N`) |
| Acceptance criteria | The **Requirements** and/or **Definition of Done** sections — copy them verbatim, don't paraphrase down |
| Non-goals | The **Out of Scope** section |
| Notes | Folded into **Context**, or dropped if `github-issue-filing`'s duplicate-check/labeling steps already cover it |

File tasks in dependency order (every task's dependencies already have issue
numbers before you write `Depends on: #N`), per the main skill's "Filing the
tasks" section.
