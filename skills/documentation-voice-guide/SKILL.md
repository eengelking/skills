---
name: documentation-voice-guide
description: Voice guide for user-facing and project prose in the localscore repo (README, CLAUDE.md, docs, commit messages, PR descriptions, issue bodies, in-app copy), plus this repo's global workflow rules (branch discipline, commit trailer format, GitHub CLI usage, Podman vs Docker, manual PR merges). Consult before writing any user-facing or project prose, and before any commit/PR/issue in this repo. Other skills (documentation-sync, testing, release, dependabot, attestation) reference this skill by name for voice and workflow conventions rather than duplicating them.
---

# Documentation voice guide

localscore's prose has to read like a person wrote it, not a template. This skill
owns voice, plus the global workflow rules that apply across every skill in this
repo.

## Voice guide

This applies everywhere prose is written for this project: README, CLAUDE.md,
docs, commit messages, PR descriptions, issue bodies, in-app copy, all of it.

**Write like a person, not like an AI.** Say the thing plainly, the way you'd
explain it to a colleague.

- No em-dashes, anywhere user-facing or in project prose. Use a period, a comma,
  or "and"/"but" instead. (`server/test/catalog.test.ts` has a regression test
  scanning every catalog question/label/`whyWeAsk`/`finePrint`/`helpDetail`
  string for `—`; the same discipline applies to every other prose surface even
  where there's no automated test for it.)
- No formulaic constructions: "It's not just X, it's Y", triplet lists built for
  rhythm rather than content, "Whether you're doing A or B, ..." framing.
- No corporate/marketing filler: "robust", "seamless", "elevate", "unlock", and
  similar words that sound like they're selling something rather than describing
  it.
- Reread what you wrote once, specifically hunting for these tells, before
  calling it finished. This is a real pass, not a formality, and the tells are
  easy to write without noticing but easy to catch on a dedicated reread.

### In-app copy conventions

- Every user-facing mention of "localscore" is wrapped in `<strong>`.
- Button, tab, and `.link-button` labels use Title Case.
- Option cards, `aria-label`s, tooltips, and placeholders stay in sentence case.

## Global workflow rules

These apply across every workflow in this repo (testing, release, dependabot,
attestation, documentation-sync) and live here since this is the
first-referenced skill for prose/workflow conventions; other skills point back to
this section by name rather than repeating it:

- Never commit directly to `main`. Branch off the latest `main` before starting
  any work.
- Commit subject lines are short titles, well under 72 characters, with detail
  in the body after a blank line, ending with the
  `Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>` trailer. A long
  subject line makes GitHub's PR-creation autofill (which pulls title/body from
  a single-commit branch's commit message) split mid-sentence, so the tail spills
  into the description looking broken. A short subject plus a real body
  paragraph is what makes that autofill look intentional.
- All GitHub operations (issues, PR status/checks, viewing existing issues, etc.)
  go through the `gh` CLI, not manual web UI steps or guessed URLs.
- The maintainer runs **Podman, not Docker**, day to day. All commands and docs
  in this repo use `podman`/`podman compose`, even though the underlying
  Dockerfile/compose file are plain OCI and work under Docker too.
- Merging PRs stays manual (the user reviews and merges in the GitHub UI),
  **except** the documented Dependabot patch/minor autonomous path, owned by the
  `dependabot` skill.
