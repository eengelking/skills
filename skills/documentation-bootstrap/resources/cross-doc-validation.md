# Cross-doc consistency and scope validation

Spawn this as one fresh, non-fork subagent (`general-purpose`) after every
doc-writing subagent's PR has merged into the integration branch. It is
**report-only** — it diagnoses, it never edits. The orchestrator decides what to
do with its findings, the same way any other review subagent's verdict gets
handled in this repo's workflow.

## Spawn prompt template

```
Review the integration branch for this documentation-bootstrap run. You are
validating, not writing — you have no authority to edit any file, and no merge
authority. Report findings; the orchestrator decides what happens next.

Ground truths this run was supposed to follow:
<paste the exact sequencing-rule block from Step 3, verbatim>

Doc types written this run, and which subagent/PR wrote each:
<list: doc type -> file path -> PR number/branch>

Check, for each doc:
1. Scope — did the PR that added/edited it touch only its assigned file(s)? Any
   edit outside the assignment is a scope violation, regardless of whether the
   edit itself looks reasonable.
2. Fact agreement — for each ground truth above, does this doc's content
   actually agree with it and with the other docs that also touch that fact
   class? Quote the conflicting lines when you find a mismatch, not just a
   description of the disagreement.

Report a structured list: one entry per finding, each with the doc(s) involved,
the specific lines, and whether it's a scope violation or a fact mismatch. If
nothing is wrong, say so plainly rather than manufacturing a finding.
```

**Do not flag leftover sub-agent or integration branches as a finding.** If
this validation runs mid-batch — its normal timing, since it runs after
subagent PRs merge into the integration branch but before that integration
branch's own PR into `main` — every sub-agent branch and the integration
branch itself are expected to still exist. Per `github-pr-merge`, branch and
worktree cleanup happens only after the batch's *final*
integration-branch-to-`main` PR merges, not per sub-agent-PR-merge. A branch
still present at this point is normal batch-in-progress state, not a hygiene
defect — don't report it as one.

## Checklist

- Diff each subagent's PR against its assignment from Step 5 — anything touched
  outside that assignment is a finding, even if it's a small, arguably-correct
  edit. Scope discipline is what made the parallel batch safe to run; a subagent
  that quietly stepped outside it undermines that even when it happened to be
  right.
- Walk the fact classes from `sequencing-rule.md` one at a time across every doc
  that could plausibly mention them — don't just spot-check the docs that seem
  most likely to disagree.
- Return findings as data (doc, location, what's wrong), not prose only — the
  orchestrator needs to act on this, not just read it.
- Never edit anything. If a finding is severe enough that leaving it feels
  wrong, that urgency belongs in how the finding is reported, not in an
  unauthorized fix.
- Don't report an un-deleted sub-agent branch or the integration branch
  itself as a finding — see the caveat above about cleanup timing.
