# Project

## Project Overview

This repo holds Claude Code skills meant to be reusable across multiple projects: the
procedural *how* behind git/PR/issue workflow, git safety, documentation sync, prose
voice, and generic dev tooling. Skills tied to one specific project's paths, tools, or
conventions belong in that project's own `.claude/skills/` directory instead, since this
repo is only for skills that hold up project-agnostically.

It ships as a single Claude Code plugin (`eengelking`, versioned via
`.claude-plugin/plugin.json`) that other projects install via the plugin marketplace, or
symlink from individually for local development. The skills under `skills/` are the
product; there is no application code to build or run.

## Do Not

None beyond CLAUDE.md's list.

## Branching and Workflow Overrides

- **Worktrees.** The folder is `.claude/worktrees/`, which CLAUDE.md names and which is
  git-ignored here. There is no install step in a fresh worktree, because the repo has no
  dependencies.
- **Version check (pre-PR).** CLAUDE.md's Git & GitHub Workflow has no such step; this repo
  adds one. It applies only when the branch changes skill content (any `skills/*/SKILL.md`
  or `skills/*/resources/` file). A docs-only diff that touches no skill (`CLAUDE.md`,
  `PROJECT.md`, `README.md`, `CHANGELOG.md` alone) skips it and can be submitted as is.
  When it applies:
  1. In the standard workflow, bump the versions first: `.claude-plugin/plugin.json`'s
     `version`, plus retitling `CHANGELOG.md`'s `[Unreleased]` section to that version
     with today's date. In the development-branch workflow the bump waits for the release
     PR.
  2. Spawn a fresh, non-fork sub-agent with `model: "haiku"` to check that every place
     that carries the version agrees: `plugin.json`, the newest `CHANGELOG.md` heading,
     and anything else a grep for the old and new version strings turns up. Give it its
     authority in the prompt ("report a pass/fail list; you may not edit, commit, push, or
     open a PR").
  3. Fix anything it reports yourself, then open the PR.

  Run it once per PR; don't loop it. Skills: `documentation-sync`, `github-pr-merge`.

## Skills

None. This repo's skills are the plugin itself and are all in CLAUDE.md's table.

## Working Style

- **Sub-agents in a parallel batch never touch `.claude-plugin/plugin.json`'s `version`
  field.** It is a shared, single-line file like `CHANGELOG.md`'s `[Unreleased]` section;
  independent agents editing it is a guaranteed conflict. The orchestrator bumps it.

## Releases

The `eengelking` plugin is the only thing released. The version lives in
`.claude-plugin/plugin.json` (`version`) and must match the newest `CHANGELOG.md` heading.
Each release is tagged `vMAJOR.MINOR.PATCH` on the commit that set the version, and the
project follows Semantic Versioning. The steps are `github-release`'s.

## Delegation and Checks

The pre-PR version check above runs through a fresh haiku sub-agent that reports a
pass/fail list and has no edit, commit, push or PR authority. The main session fixes
what it reports.
