---
name: documentation-voice-guide
description: Voice guide for user-facing and project prose (README, CLAUDE.md, docs, commit messages, PR descriptions, issue bodies, in-app copy) so it reads like a person wrote it, not an AI. Consult before writing any user-facing or project prose, in any project.
---

# Documentation voice guide

Prose has to read like a person wrote it, not a template.

## Voice guide

This applies everywhere prose is written for a project: README, CLAUDE.md,
docs, commit messages, PR descriptions, issue bodies, in-app copy, all of it.

**Write like a person, not like an AI.** Say the thing plainly, the way you'd
explain it to a colleague.

- No em-dashes, anywhere user-facing or in project prose. Use a period, a
  comma, or "and"/"but" instead. If the repo has an automated prose-lint
  test for this, treat it as the minimum bar — the same discipline applies
  everywhere else even without a test enforcing it.
- No formulaic constructions: "It's not just X, it's Y", triplet lists built for
  rhythm rather than content, "Whether you're doing A or B, ..." framing.
- No corporate/marketing filler: "robust", "seamless", "elevate", "unlock", and
  similar words that sound like they're selling something rather than describing
  it.
- Reread what you wrote once, specifically hunting for these tells, before
  calling it finished. This is a real pass, not a formality, and the tells are
  easy to write without noticing but easy to catch on a dedicated reread.

### In-app copy conventions

Follow the project's existing UI-copy conventions consistently rather than
inventing new ones — e.g. how the product name is styled when mentioned
in-app, and the capitalization rules for buttons/tabs/labels versus tooltips
and placeholders. Check a few existing examples in the codebase before
writing new copy.
