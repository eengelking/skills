---
name: retrospective
description: Covers running a retrospective on a piece of work just finished — and, when it surfaces a real gap, actually implementing the fix rather than just discussing it. Precondition — the user asks for a retrospective, asks "what went well / what could be improved," or asks to "ultrathink through what happened," typically after a nontrivial or multi-agent piece of work (multiple subagents, an autonomous run, or friction/surprises along the way). Postcondition — findings are split into went-well and went-wrong, every went-wrong item is traced to a root cause (not just its symptom) and grounded in specifics from the actual transcript/actions, each finding is sorted into skill-gap / model-behavior / tool-bug / already-fine, every skill-gap finding has a concrete file-and-line corrective plan, and any resulting fix lands through the host project's own branch/PR/merge workflow — never bypassing it. Not every retrospective produces a change; concluding "this was fine" is a valid, complete outcome. This is a generic, project-agnostic skill — it holds no assumptions about a specific repo's layout, tooling, or history, and works whether invoked in this skills repo or installed/symlinked into any other project's `.claude/skills/`.
---

# Running a retrospective

A retrospective is only useful if it changes something real — a skill gets sharper,
a genuine one-off gets reported as feedback, or the team learns the run was actually
fine. A retrospective that just narrates "went well: X, went wrong: Y" without
tracing *why* Y happened, or that turns every finding into a new rule whether or not
one was missing, produces busywork instead of improvement. Run it in five steps:

1. Gather evidence and split went-well from went-wrong.
2. Push every went-wrong item to a root cause.
3. Sort each root cause into the bucket that determines its fix.
4. Write a concrete corrective plan for anything that's a real skill gap.
5. Implement it through the host project's normal workflow — or stop, because
   nothing needs to change.

## 1. Gather evidence, then split

Don't retrospect from a self-report or a vague memory of how the run went — walk
the actual transcript, commands, diffs, and tool results from the unit of work in
question. A subagent's own summary of what it did is a claim, not evidence; check
what it actually ran and wrote.

Produce two lists, not one:

- **Went well** — patterns worth repeating. This matters as much as the
  went-wrong list: if nothing is written down here, the next session has no way
  to know which of its instincts are the ones to keep, and a fix aimed at the
  went-wrong list can easily undo something that was working. Skip this list
  only if the unit of work is too short to have any texture (e.g. a single
  trivial edit).
- **Went wrong** — friction, surprises, mistakes, wasted work, anything that
  took more correction or supervision than it should have.

Don't manufacture problems to pad the went-wrong list, and don't manufacture
praise to pad the went-well list. If a run was genuinely clean, say so and move
on — see step 5.

## 2. Root cause, not symptom

Every went-wrong item needs to answer "why did this actually happen," not just
"what happened." A symptom describes the failure; a root cause describes the
condition that made the failure possible — and only the second one tells you
what to fix.

Ground the root cause in specifics: the exact file and line of the instruction
that was ambiguous or missing, the exact command that was run, the exact
decision point where the agent had (or lacked) the information it needed. "The
agent did X wrong" is not a root cause. "Skill S's step 3 describes isolation as
a recommendation ('consider using a worktree') rather than a requirement, so the
agent judged it unnecessary for a 5-agent batch" is.

If you can't trace a symptom to a specific, checkable cause, say so explicitly
rather than inventing a plausible-sounding one — a fabricated root cause produces
a fix that patches nothing.

## 3. Sort into a bucket — the bucket decides the fix

Every went-wrong root cause belongs in exactly one of these. Getting this
classification wrong is the main way retrospectives make things worse — the
mismatch to watch for is turning a one-off human/model misjudgment into a new
standing rule that adds friction to every future run without preventing a
recurrence, because there was never a missing instruction to fix in the first
place.

| Bucket | Test | Fix |
|---|---|---|
| **Skill-instruction gap** | The relevant skill's instructions were absent, ambiguous, or worded weakly enough that a reasonable reading missed the intended behavior. | Edit that skill's `SKILL.md` or its `resources`/`references` — see steps 4-5. |
| **One-off model misjudgment** | The instruction already existed, was clear and strong enough, and the agent simply didn't follow it — with no ambiguity to point to. | This is model-behavior feedback, not a doc problem. Surface it through whatever feedback mechanism the harness provides (e.g. a `SendFeedback`-style tool, if available). Do not invent a new rule or strengthen existing wording to patch a single lapse — that's treating a skill-gap fix for a bucket where none exists, and it degrades the skill for every future run instead of addressing the actual incident. |
| **Tool/product bug** | A denied action that should have been allowed, a confusing or wrong tool result, unexpected harness behavior. | Also feedback, not a skill change — same mechanism as above. |
| **Genuinely fine** | The run matched expectations; friction was proportionate to real task complexity, not avoidable. | Say so plainly. Stop. Don't force a finding to justify having run the retrospective. |

A single went-wrong item can legitimately sort into "genuinely fine" once you
trace it — e.g. a subagent asked a clarifying question that, on inspection, was
actually warranted by real ambiguity. Reclassifying mid-analysis is normal, not
a failure of the retrospective.

## 4. Corrective plan for each skill-gap finding

Before touching any file, write out — for each skill-gap finding — exactly what
changes:

- Which skill, which file (`SKILL.md` or a specific file under
  `resources/`/`references/`).
- The specific section or line the gap lives in, quoted or referenced precisely
  enough that someone could find it without re-deriving your analysis.
- The exact wording change or addition, not just "clarify this" — write the
  actual replacement text, or close to it.
- Why this wording would have changed the outcome — trace it back to the root
  cause from step 2, not just the symptom.

If the fix is non-trivial — touches multiple files, changes a skill's control
flow rather than a single sentence, or you're not fully sure of the right
wording yet — use plan mode: research the current file state yourself first, draft
the exact edits, and get the plan confirmed before implementing. A retrospective
finding doesn't earn an exemption from normal planning discipline just because it
was born from self-analysis rather than a user request.

**Prefer mechanical enforcement over prose where the fix allows it.** A rule an
agent has to remember and apply correctly every time is weaker than one a CI
check, pre-commit hook, or guard script enforces automatically — the same
principle already applied elsewhere (e.g. a repo that backs a branch-first rule
with a pre-commit hook rather than relying on the instruction alone). When a
corrective plan can be backed by something mechanical instead of purely
documentary, propose that as part of the plan, not as an afterthought.

## 5. Implement through the normal workflow — or stop

Not every retrospective produces a change. If step 3 sorted every finding into
"model behavior," "tool bug," or "genuinely fine," report that plainly and stop —
that is a complete, successful retrospective, not an unfinished one.

When a skill-gap fix does need implementing, it goes through this project's own
git workflow exactly like any other change — a retrospective finding is not a
side channel around it:

- Check for the host project's own branching/PR/merge conventions — commonly
  named something like `git-branching` and `github-pr-merge` if it's a Claude
  Code skills-based project, or whatever equivalent process it documents
  elsewhere (a `CONTRIBUTING.md`, a status doc). Use *that* project's actual
  skills/conventions — never assume this skill's own host repo's specific skill
  names apply to a different project it's installed into.
  - If it's ambiguous which skill applies, ask before improvising branch or
   merge steps of your own.
- Never edit the affected skill directly on that project's main branch, and
  never merge your own fix — the same rule that governs every other change in
  a project with that discipline applies here without exception, including
  "the retrospective found the gap" as a reason to skip it.
- If the current project's own doc-sync conventions call for anything beyond
  the skill edit itself — a changelog entry, a version bump — follow those too.
  If this skill is running inside the `skills` repo that authored it
  specifically, that means loading its `documentation-sync` skill, which
  covers bumping `.claude-plugin/plugin.json` when a `SKILL.md` or its
  resources change; a different host project may have no such mechanism at
  all, in which case skip it.

## Reporting the retrospective

Present the went-well list, the went-wrong list with each item's root cause and
bucket, the corrective plan for any skill-gap items, and the outcome (implemented,
planned-pending-approval, or filed as feedback). Don't bury a "this was fine"
conclusion under invented findings — a short retrospective that correctly finds
nothing wrong is more useful than a long one that pads out symptoms it couldn't
actually trace to a cause.
