# Determining the sequencing rule

Step 3 of the main skill asks you, the orchestrator, to decide — once, before any
subagent starts writing — which doc is the source of truth for which class of
fact. This file lists the fact classes that most often cause cross-doc
disagreement, and a template for writing the rule compactly enough to paste into
every subagent's spawn prompt without bloating it.

## Fact classes that usually need reconciling

- **Version numbers and release tags.** CHANGELOG.md is the historical record —
  it's the only doc allowed to assert "X shipped in v1.2." Every other doc
  (ARCHITECTURE, DECISIONS, the status doc) should either omit version numbers
  entirely or cite CHANGELOG.md rather than stating its own.
- **Dates.** A release date belongs to CHANGELOG.md. A "last reviewed" or
  "current as of" date on another doc is a different fact and should be labeled
  as such — don't let a subagent conflate the two.
- **Feature/status claims.** "Implemented" vs. "planned" vs. "in progress" is
  easy to get wrong when a subagent infers status from an old TODO comment or a
  stale issue title instead of current code. State plainly which doc gets to
  make status claims (usually the status doc and/or SPEC.md, if the project has
  one) and which should describe structure without commenting on completeness
  (usually ARCHITECTURE.md).
- **Architecture claims.** ARCHITECTURE.md describes the system as it is *right
  now* — never "how it evolved" or "what changed in v2." That history belongs in
  CHANGELOG.md or DECISIONS.md; mixing it into ARCHITECTURE.md is what makes it
  go stale the next time something moves.
- **Terminology and naming.** If the codebase or its history refers to the same
  component by more than one name (a rename that didn't fully propagate, an
  internal codename vs. a public one), pick one name for the docs to use and say
  so — otherwise each subagent will independently guess, and guess differently.

## Template

State the rule as a short "ground truths" list, not prose — something a subagent
can scan in a few seconds and hold in mind while writing, e.g.:

```
Ground truths for this bootstrap run — every doc must agree with these,
and cite CHANGELOG.md rather than restating a fact it already owns:
- Versions/release dates: CHANGELOG.md only. Other docs cite it, don't restate it.
- Current status (shipped/in-progress/planned): source from actual code state,
  not old issues/TODOs. [Name the doc that owns status claims for this project.]
- Architecture docs describe current state only — no "used to be X" narrative.
- [Any project-specific naming/terminology note, if one applies.]
```

Paste this block verbatim into every doc-writing subagent's prompt in Step 5 —
not a summary of it, and not left for the subagent to infer from context. The
post-bootstrap validator in Step 6 checks compliance against this exact list, so
a paraphrase that drifts from it will produce false-positive mismatches later.
