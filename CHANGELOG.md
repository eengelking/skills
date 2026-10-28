# Changelog

All notable changes to this project are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project follows [Semantic Versioning](https://semver.org/). The version
is the plugin version in `.claude-plugin/plugin.json`; each release is tagged
`vMAJOR.MINOR.PATCH` on the commit that set it. Versions 1.0.0 through 1.11.0 were
tagged after the fact, from the history of that file.

## [Unreleased]

## [1.14.0] - 2026-10-28

### Added

- `git-branching`: `resources/worktree-workflow.md`. Every working branch is now a git
  worktree by default, in a git-ignored folder, so agents working at the same time never
  share a checkout. The project supplies the folder and the install command. `SKILL.md`
  also has a branch-name table (`issue/`, `feat/`, `fix/`, `docs/`, `chore/`,
  `refactor/`, `test/`, `revert/`, `hotfix/`, `batch/`, `release-prep/`).
- `github-pr-merge`: a "Verify after opening" section (check for conflicts first, since a
  conflicted PR never starts its checks, then `gh pr checks <PR> --watch`, a per-check
  verdict, and a three-attempt stop), `resources/pr-trace-check.md` (a pre-publish check
  by a fresh small-model sub-agent for secrets, machine-specific paths and
  prompt-injection text), and a short pre-PR static-analysis note.
- `github-release`: `resources/release-check.md`, a pre-release-prep check by a fresh
  small-model sub-agent, and a bump-level rule: choose by what the entries change, never
  by an issue's label.
- `development-commands`: resources grouped by tool. `python/` (the existing testing
  resource, moved) and `node/` (`npm.md`, `testing-and-build.md`, `containerfile.md`),
  plus tool-agnostic ones: a throwaway server, UI screenshots (with
  `resources/scripts/page-shot.mjs`), end-to-end scripts, host sampling (GPU load on
  macOS, Linux and Windows), building a docs site, `sonar-analysis.md`, and
  `codeql-results.md` (reading code scanning alerts for a PR). `containers.md` now covers
  Podman, Docker and nerdctl with containerd, building an image by hand, and a project's
  own CLI wrapper. `SKILL.md` points at the folder for the tool in use.
- `documentation-sync`: `resources/what-why-vs-how.md`, the test and method for keeping
  rules in instruction files and moving steps into skills.

### Changed

- In the development-branch workflow, an issue is closed when the PR that resolves it
  merges into `development`, not when a release ships. The PR carries `Closes #N` and
  GitHub closes the issue on merge, so nobody closes it by hand; the agent only verifies
  it is closed. `Refs #N` only links an issue and never closes it. The release PR closes
  nothing. A hotfix PR into `main` carries `Closes #N` and its backport uses `Refs #N`.
  `github-pr-merge` and `github-issue-workflow` agree on this.
- In the development-branch workflow, a hotfix now has two paths. If `development`
  matches `main`, the fix is made on `development` and ships in the next release with a
  patch bump, with no cherry-pick. If they differ, the hotfix branches from `main` and is
  cherry-picked back, as before.
- Branch cleanup removes the worktree first, then deletes the branch locally and on the
  remote, then prunes worktrees.

## [1.13.0] - 2026-10-16

### Changed

- The development-branch workflow now triggers on whether a `development` branch exists
  on the remote (`git ls-remote --exit-code --heads origin development`), not on the
  GitHub default branch. The default branch stays `main`, so a plain clone gets released
  code. Because `Closes #N` only fires for PRs into the default branch, feature and batch
  PRs into `development` use `Refs #N` and the release PR carries `Closes #N` for every
  issue it ships. `CLAUDE.md` and the four git/PR/issue/release skills are updated to
  match, and "the default branch" in `CLAUDE.md` is now "the base branch" where it means
  the PR target.
- `CLAUDE.md` now requires a Haiku sub-agent version check before opening any PR that
  changes skill content, to confirm every place that carries a version was bumped.

## [1.12.0] - 2026-10-16

### Added

- A development-branch workflow for `git-branching`, `github-pr-merge`,
  `github-issue-workflow`, and `github-release`, each with a new
  `resources/development-branch.md`. It applies when the repo's GitHub default branch is
  `development`; any other default branch keeps the existing `main` workflow unchanged.
  Feature PRs squash-merge into `development` with no version bump. A release is a
  release-prep PR (version bump and CHANGELOG retitle) into `development`, then a
  `development` → `main` PR merged with a regular merge commit, which acts as the
  release-candidate gate. Hotfixes branch from `main` and are cherry-picked back into
  `development`. (#37)

### Changed

- The `git-branching` pre-commit hook now also refuses commits on `development`, and
  `github-pr-merge`'s `gh_merge_guard.sh` also refuses PRs whose base is `development`.
  Neither changes behavior for a repo with no `development` branch. (#37)

## [1.11.0] - 2026-10-11

### Added

- `github-issue-filing` now covers `gh issue create --attach` and
  `gh issue comment --attach`: a screenshot or video the user shared while describing
  a problem gets attached to the issue, with alt text, a note on inline placement, what
  to do when only some uploads succeed, and a check for sensitive content before
  upload. `resources/gh-issue.md` points to it. (#35)

## [1.10.1] - 2026-10-11

### Added

- Listed `podium-reporter` in `.claude-plugin/marketplace.json`, pointing at the
  `mod/podium-reporter` folder of `eengelking/podium` (a `git-subdir` source). The
  marketplace can now carry plugins that live in other repos; the `eengelking` skills
  plugin is unchanged. README.md has a short section listing plugins that live
  elsewhere. (#32)

### Changed

- Added a description to the marketplace (`.claude-plugin/marketplace.json`),
  which `claude plugin validate` had been warning about. README.md's row for
  `podium-reporter` now says to enter the server's auth token with
  `/plugin configure` and links the Podium user guide. (#34)
- Synced `.claude/CLAUDE.md` with the canonical standard model
  (`eengelking/agent`'s `CLAUDE.md`, PR #14, "Bound the pre-PR code-review
  cycle to one round"): added a `Do Not` bullet against re-invoking
  `/code-review` a second time on the same diff "to confirm" a fix, since the
  review skill's finder/verifier fan-out isn't guaranteed to converge on a
  repeat run; and replaced the `Review (pre-PR)` row in Git & GitHub Workflow
  so it applies only to branches that change code (a docs/prose-only diff has
  nothing for `/code-review` to check), runs `/code-review` exactly once
  before opening the PR, and verifies fixes via the project's own test/lint
  suite rather than a second review round. (#31)
- Synced `.claude/CLAUDE.md` with the canonical standard model
  (`eengelking/agent`'s `CLAUDE.md`): added a `Starting` row to Issue
  Management (mandatory TaskCreate/TaskUpdate tracking when starting an
  issue, with a documented fallback to enabling
  `CLAUDE_CODE_ENABLE_TODO_TOOLS` when a session doesn't provision task
  tools by default); added a `Review (pre-PR)` row to Git & GitHub Workflow
  so `/code-review --fix` runs on the branch before opening the PR rather
  than after; added a `Remote access` row noting `gh` CLI availability and
  the SSH-to-HTTPS remote fallback; and added a Working Style bullet on
  checking `scripts/` for an existing helper before writing a new one. This
  repo's own additions (the extra `Skills` table columns, the
  `.claude-plugin/plugin.json` version-field callout) were left in place. (#30)

### Fixed

- The `podium-reporter` entry in `.claude-plugin/marketplace.json` now uses the full
  `https://github.com/eengelking/podium.git` URL. The `eengelking/podium` shorthand made
  Claude Code clone over SSH, so installing failed with "Permission denied (publickey)" for
  anyone without a GitHub SSH key. (#33)
- `skills/documentation-sync/SKILL.md` and `.claude/CLAUDE.md` called the plugin
  `skills`; its name has been `eengelking` since the rename. (#34)

## [1.10.0] - 2026-09-24

### Changed

- Renamed the marketplace (`.claude-plugin/marketplace.json`'s `name` field)
  from `skills-marketplace` to `eengelking-marketplace`. `skills-marketplace`
  is a generic name another plugin author's marketplace could plausibly reuse,
  the same namespace-collision concern that already prompted renaming the
  plugin itself from `skills` to `eengelking`. The plugin name and repo are
  unchanged. README.md's install/update instructions now reference the new
  marketplace name, and gained a migration section for anyone who installed
  before this rename: the old `skills-marketplace` registration is orphaned
  once this change is pulled, and needs `/plugin marketplace remove
  skills-marketplace` followed by re-adding and reinstalling under the new
  name — removing a marketplace uninstalls its plugins, so reinstalling isn't
  optional. (#29)

## [1.9.0] - 2026-09-24

### Added

- `github-issue-workflow` gained a "Starting an issue" section covering the
  sequence between "user says begin" and the first file edit: enter plan
  mode, research the issue (including any referenced `docs/SPEC.md`
  section), finalize the plan, then exit plan mode and start work without
  waiting for human approval — a deliberate, scoped exception to Claude
  Code's normal plan-mode gate — and create a task list (TaskCreate) covering
  every task including planned delegation before touching any file, kept
  current (TaskUpdate) for the entire duration of the work, not just at
  kickoff. (#28)

## [1.8.0] - 2026-09-15

### Added

- `github-issue-workflow`'s "Closing out an issue" section now requires
  independently re-running an issue's Validation commands and checking the
  diff against its file scope whenever any part of the work was delegated to
  a subagent — solo, sequential delegation included, not just a parallel
  batch. A subagent's self-report (test counts, "verification passed", scope
  claims) is a claim, not a check. `github-pr-merge`'s existing parallel-batch
  review checklist now cross-references this as the general form of the same
  rule, so the two don't drift apart over time. (#27)

### Changed

- Renamed the plugin (`.claude-plugin/plugin.json` and the marketplace entry in
  `.claude-plugin/marketplace.json`) from `skills` to `eengelking`, so installed
  skills invoke as `/eengelking:<skillName>` instead of `/skills:<skillName>`.
  `skills` is a name other plugin authors are likely to reuse; this avoids
  namespace collisions when multiple marketplaces are installed side by side.
  Nothing had been tagged when this landed, so it had no upgrade impact for
  existing installs. (#26)

## [1.7.1] - 2026-09-13

### Added

- `github-release`'s Staged-DAG opt-in now ties gate passage to actually
  invoking `spec-writing`'s Verifier role at the gate (a fresh, non-implementer
  agent re-running the gate test and full CI from a clean checkout), not just
  every task in the stage having merged; `spec-writing`'s Verifier row gained
  a matching "at a gate" entry, and `docs/DECISIONS.md`'s companion-doc note
  now covers recording gate passage itself (gate id, commit SHA, verifier
  report pointer). (#25)
- `github-release`'s version-bump step now notes that a repo's version string
  can live in more places than its manifest resource covers (OpenAPI
  `info.version`, an API snapshot, a Dockerfile `LABEL`, etc.) — grep for it
  fresh on every release rather than trusting a previously-known list. (#25)

## [1.7.0] - 2026-09-12

### Added

- `github-release` policy option for repos using `spec-writing`'s Staged-DAG
  weight class: tie MINOR version bumps to stage-gate passage instead of a
  per-PR feature/fix judgment call, since the spec's own gates already give
  the project natural release checkpoints. Opt-in and additive — repos on
  Flat/Phased spec classes, or with no `spec-writing` spec, are unaffected. (#24)

## [1.6.0] - 2026-09-12

### Added

- `spec-writing` skill for turning a rough idea, a premade brief, or a Q&A
  session into a SPEC.md decomposable into unambiguous, dependency-ordered
  tasks. Picks a flat/phased/staged-DAG weight class to match project size
  (modeled on patterns observed across several real SPEC.md documents, from
  small single-shot build specs up to a full task-DAG-with-orchestration-roles
  spec), and hands off the actual `gh issue create` mechanics to
  `github-issue-filing` rather than duplicating them. (#23)

## [1.5.1] - 2026-09-12

### Changed

- `CLAUDE.md`'s Git & GitHub Workflow table and `github-pr-merge`'s "Opening
  a PR" section now say explicitly that committing and opening a PR for
  informal, no-issue work happens once the change is finished and validated,
  without waiting for a separate go-ahead — closing a gap where only
  issue-tracked work had that instruction; merging into `main` remains
  unchanged, always the user's call. (#22)

## [1.5.0] - 2026-09-12

### Added

- `retrospective` skill for running a post-hoc retrospective on a finished
  piece of work: splitting went-well from went-wrong, tracing every
  went-wrong item to a root cause, sorting each into a skill-instruction
  gap / one-off model misjudgment / tool bug / genuinely-fine bucket, and
  routing a real skill-gap finding through a concrete corrective plan and
  the host project's own branch/PR/merge workflow rather than a shortcut. (#21)

## [1.4.0] - 2026-09-12

### Added

- Public-repo docs: `CONTRIBUTING.md`, `.github/SECURITY.md`, bug-report and
  feature-request issue templates, a pull request template, and this
  `CHANGELOG.md`. (#19)
- `.github/CODE_OF_CONDUCT.md`, adapted from the Contributor Covenant for a
  small single-maintainer project. (#19)
- MIT `LICENSE`. (#12)
- A GitHub Actions check (`.github/workflows/plugin-version-check.yml`)
  that fails a PR into `main` if it changes a `SKILL.md` or a skill's
  `resources/` without bumping `.claude-plugin/plugin.json`'s `version`. (#20)

### Changed

- `git-branching` now requires every parallel-batch sub-agent to be spawned
  with `isolation: "worktree"`, grounded in a real incident where sub-agents
  sharing one working directory clobbered each other's git checkouts. (#20)
- `documentation-sync`'s plugin-version-bump rule now distinguishes a PR
  targeting `main` (bump required) from a parallel-batch sub-agent's PR into
  an integration branch (bump forbidden there; happens once at the
  orchestrator's final consolidation instead); `github-pr-merge` and
  `github-issue-workflow` add `.claude-plugin/plugin.json` to the shared
  files a sub-agent must never touch, and `documentation-bootstrap`'s
  cross-doc validator no longer flags a mid-batch sub-agent branch as a
  stale-branch finding. (#20)
- `.claude/CLAUDE.md` gained an explicit "Always Branch First" rule. (#11)
- README gained instructions for updating installed skills. (#10)

### Fixed

- Added the `.claude/skills` symlink for `documentation-bootstrap`, missing
  since the skill was added after the repo's own local dev setup. (#9)
- Added the missing `documentation-bootstrap` row to README's skill table. (#10)

## [1.3.0] - 2026-09-10

### Added

- `documentation-bootstrap` skill for backfilling or topping up a project's
  missing doc set in bulk, including a doc-type selection pass, a
  sequencing rule shared across parallel doc-writing sub-agents, and a
  post-bootstrap consistency check. (#8)
- `.claude/CLAUDE.md`, this repo's own project guidance file. (#7)

## [1.2.1] - 2026-09-10

### Changed

- `documentation-voice-guide` and its `example-readyband` resource, cleaned
  of file paths, UI conventions, and cross-references specific to the
  project they were copied from. (#5)

## [1.2.0] - 2026-09-09

### Changed

- `github-issue-filing` and `github-issue-workflow` rewritten to drop
  references to skills and paths from the projects they were ported from,
  and to work generically for any project. (#3)
- `documentation-sync` now treats `SPEC.md` (when a project has one) as the
  source of truth for intended behavior, gained a generic doc-type
  checklist covering the full expected doc set, and dropped
  project-specific resource files that didn't belong in a shared skills
  repo. (#4)

## [1.1.0] - 2026-09-09

### Added

- `git-safety` skill, covering commands that need explicit per-use approval
  (force-push, hook-skipping flags, signing bypass, hard resets, branch/tag
  deletion) plus a routine for catching secrets before they're committed. (#2)

## [1.0.0] - 2026-09-09

### Added

- Eight reusable skills, rescoped from project-specific originals into
  project-agnostic form: `git-branching`, `github-pr-merge`,
  `github-release`, `github-issue-filing`, `github-issue-workflow`,
  `documentation-sync`, `documentation-voice-guide`, and
  `development-commands`. (#1)
- A plugin marketplace structure (`.claude-plugin/plugin.json`,
  `.claude-plugin/marketplace.json`) so the repo can be added directly with
  `/plugin marketplace add` and installed as a single `skills` plugin. (#1)

### Changed

- README consolidated into a single skill catalog table, with install
  instructions for both the plugin marketplace and manual symlinking. (#1)

[Unreleased]: https://github.com/eengelking/skills/compare/v1.14.0...HEAD
[1.14.0]: https://github.com/eengelking/skills/compare/v1.13.0...v1.14.0
[1.13.0]: https://github.com/eengelking/skills/compare/v1.12.0...v1.13.0
[1.12.0]: https://github.com/eengelking/skills/compare/v1.11.0...v1.12.0
[1.11.0]: https://github.com/eengelking/skills/compare/v1.10.1...v1.11.0
[1.10.1]: https://github.com/eengelking/skills/compare/v1.10.0...v1.10.1
[1.10.0]: https://github.com/eengelking/skills/compare/v1.9.0...v1.10.0
[1.9.0]: https://github.com/eengelking/skills/compare/v1.8.0...v1.9.0
[1.8.0]: https://github.com/eengelking/skills/compare/v1.7.1...v1.8.0
[1.7.1]: https://github.com/eengelking/skills/compare/v1.7.0...v1.7.1
[1.7.0]: https://github.com/eengelking/skills/compare/v1.6.0...v1.7.0
[1.6.0]: https://github.com/eengelking/skills/compare/v1.5.1...v1.6.0
[1.5.1]: https://github.com/eengelking/skills/compare/v1.5.0...v1.5.1
[1.5.0]: https://github.com/eengelking/skills/compare/v1.4.0...v1.5.0
[1.4.0]: https://github.com/eengelking/skills/compare/v1.3.0...v1.4.0
[1.3.0]: https://github.com/eengelking/skills/compare/v1.2.1...v1.3.0
[1.2.1]: https://github.com/eengelking/skills/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/eengelking/skills/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/eengelking/skills/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/eengelking/skills/releases/tag/v1.0.0
