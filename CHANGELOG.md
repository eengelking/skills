# Changelog

All notable changes to this project are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project intends to follow [Semantic Versioning](https://semver.org/)
once it starts cutting releases.

## [Unreleased]

### Added

- Eight reusable skills, rescoped from project-specific originals into
  project-agnostic form: `git-branching`, `github-pr-merge`,
  `github-release`, `github-issue-filing`, `github-issue-workflow`,
  `documentation-sync`, `documentation-voice-guide`, and
  `development-commands`.
- A plugin marketplace structure (`.claude-plugin/plugin.json`,
  `.claude-plugin/marketplace.json`) so the repo can be added directly with
  `/plugin marketplace add` and installed as a single `skills` plugin.
- `git-safety` skill, covering commands that need explicit per-use approval
  (force-push, hook-skipping flags, signing bypass, hard resets, branch/tag
  deletion) plus a routine for catching secrets before they're committed.
- `documentation-bootstrap` skill for backfilling or topping up a project's
  missing doc set in bulk, including a doc-type selection pass, a
  sequencing rule shared across parallel doc-writing sub-agents, and a
  post-bootstrap consistency check.
- `.claude/CLAUDE.md`, this repo's own project guidance file, later
  expanded with an explicit "Always Branch First" rule.
- `CODE_OF_CONDUCT.md`, adapted from the Contributor Covenant for a small
  single-maintainer project.
- `retrospective` skill for running a post-hoc retrospective on a finished
  piece of work: splitting went-well from went-wrong, tracing every
  went-wrong item to a root cause, sorting each into a skill-instruction
  gap / one-off model misjudgment / tool bug / genuinely-fine bucket, and
  routing a real skill-gap finding through a concrete corrective plan and
  the host project's own branch/PR/merge workflow rather than a shortcut.

### Changed

- `github-issue-filing` and `github-issue-workflow` rewritten to drop
  references to skills and paths from the projects they were ported from,
  and to work generically for any project.
- `documentation-sync` now treats `SPEC.md` (when a project has one) as the
  source of truth for intended behavior, gained a generic doc-type
  checklist covering the full expected doc set, and dropped
  project-specific resource files that didn't belong in a shared skills
  repo.
- `documentation-voice-guide` and its `example-readyband` resource, cleaned
  of file paths, UI conventions, and cross-references specific to the
  project they were copied from.
- README consolidated into a single skill catalog table, with install
  instructions for both the plugin marketplace and manual symlinking, and
  guidance for picking up updates to installed skills.
- `git-branching` now requires every parallel-batch sub-agent to be spawned
  with `isolation: "worktree"`, grounded in a real incident where sub-agents
  sharing one working directory clobbered each other's git checkouts.
- `documentation-sync`'s plugin-version-bump rule now distinguishes a PR
  targeting `main` (bump required) from a parallel-batch sub-agent's PR into
  an integration branch (bump forbidden there; happens once at the
  orchestrator's final consolidation instead); `github-pr-merge` and
  `github-issue-workflow` add `.claude-plugin/plugin.json` to the shared
  files a sub-agent must never touch, and `documentation-bootstrap`'s
  cross-doc validator no longer flags a mid-batch sub-agent branch as a
  stale-branch finding.
- Added a GitHub Actions check (`.github/workflows/plugin-version-check.yml`)
  that fails a PR into `main` if it changes a `SKILL.md` or a skill's
  `resources/` without bumping `.claude-plugin/plugin.json`'s `version`.

### Fixed

- Added the `.claude/skills` symlink for `documentation-bootstrap`, missing
  since the skill was added after the repo's own local dev setup.
- Added the missing `documentation-bootstrap` row to README's skill table.

[Unreleased]: https://github.com/eengelking/skills/commits/main
