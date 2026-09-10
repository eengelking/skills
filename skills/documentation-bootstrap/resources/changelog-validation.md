# CHANGELOG-specific validation

Spawn this as one fresh, non-fork subagent (`general-purpose`), alongside the
cross-doc validator in Step 6, but treat it separately — this one checks
CHANGELOG.md against its actual sources, not against sibling docs. Unlike the
cross-doc validator, **this subagent may fix `CHANGELOG.md` directly** if it
finds a problem: its whole scope is the one file it's already validating, so
routing a fix back through the orchestrator for a re-spawn would just repeat the
same check with extra steps. It does not get authority over any other file.

CHANGELOG.md, more than any other doc type this skill bootstraps, is prone to
invented specifics — a subagent reconstructing "what happened when" from git
history will happily produce a plausible-looking version number or date that
isn't actually backed by anything. This check exists specifically to catch that
before it ships.

## Spawn prompt template

```
Validate (and if needed, fix) CHANGELOG.md from this documentation-bootstrap
run. You have edit authority for this file only — no other file, and no merge
authority.

For every entry in CHANGELOG.md:
1. Confirm it's derivable from `git log`, `git tag --list`, or
   `gh pr list --state merged` — not just plausible-sounding. If you can't find
   the source for a claimed version number, date, or change description, that
   entry is unsupported.
2. Anything genuinely inferred rather than directly sourced (e.g. approximating
   a version's date from a nearby commit's date because no tag exists for it)
   must be marked inline as inferred — don't let an inference read as a sourced
   fact.
3. Fix what you find: remove or correct unsupported entries, add the inferred
   marker where it's missing, and confirm the fixed file's entries are ordered
   correctly (newest first, or whatever convention the rest of this doc/project
   already uses).

Report what you changed and why, even though you have authority to make the
change directly — the orchestrator still needs a record of it.
```

## Checklist

- Cross-check every version number against `git tag --list` — a version that
  appears in CHANGELOG.md but has no corresponding tag either needs the
  "inferred" marker or needs to be dropped, not left stated as fact.
- Cross-check dates the same way — prefer a tag's actual date over an
  approximation whenever one exists.
- For projects with no tags at all (a pre-release project bootstrapping its
  first CHANGELOG), treat every entry as derived from commit/PR history rather
  than releases, and say so in the file's own framing rather than implying a
  release cadence that hasn't happened yet.
- Never invent a version number or date that isn't backed by *something* in git
  or PR history, even an inferred one — an entry with no basis at all should be
  dropped, not guessed.
