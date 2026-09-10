# Contributing

Thanks for considering a contribution to this repo. It holds Claude Code skills meant
to work across many projects, shipped together as one plugin. This doc covers what
belongs here, how to propose a change, and how it gets merged.

## What belongs in this repo

A skill belongs here if it holds up project-agnostically: the procedural *how* behind
git/PR/issue workflow, git safety, documentation sync, prose voice, or generic dev
tooling. If a skill only makes sense with a specific project's paths, tools, or
conventions baked in, it belongs in that project's own `.claude/skills/` directory
instead, not here.

A good test: could this skill be symlinked into an unrelated project and still make
sense as written, with no per-project detail stripped out first? If yes, it's a
candidate for this repo. If it references a specific project's file layout, tool
choices, or house style, keep it local to that project.

## Proposing a new skill or a change to an existing one

Look at an existing skill directory (`skills/<name>/`) before writing anything. Each
one has a `SKILL.md` with frontmatter (`name` and `description`, where the description
states the skill's precondition and postcondition) plus the skill's body, and
sometimes a `resources/` directory for scripts or templates the skill references.
Match that shape for a new skill.

For a change to an existing skill, keep the edit scoped to what's actually wrong or
missing, since a `SKILL.md` accumulates cruft fast if every change also reorganizes
unrelated sections.

Open an issue first if you're proposing something non-trivial (a new skill, or a
behavior change to an existing one) so the direction can be discussed before you put
work into it. A small, obvious fix (a typo, a broken cross-reference) can skip
straight to a PR.

### The version bump

Editing a `SKILL.md` or a skill's `resources/` requires bumping the `version` field in
`.claude-plugin/plugin.json`, in the same PR as the change. This repo ships every
skill as a single plugin, so there's no per-skill version, and that one field is what
`/plugin marketplace update` checks to decide whether there's anything new for an
installed project to pull. A change that lands without the bump sits in `main` but
never reaches anyone who already installed the plugin. Bump the patch component for a
wording or clarity fix, the minor component for new guidance or a behavior change,
following the version history already in that file.

### Voice

Skills, and any other prose in this repo, should read like a person wrote them: say
the thing plainly, skip formulaic constructions and corporate filler, no em-dashes.
See the `documentation-voice-guide` skill for the full guide, and follow it for
anything you write here.

## Branching, PRs, and merging

Every change lands on a branch, never directly on `main`, regardless of how small it
is. Branch off a current `main`:

```sh
git checkout main && git pull
git checkout -b <your-branch-name>
```

Once your change is ready, open a PR against `main` with `gh pr create` (or the
GitHub web UI). Note in the PR body that it's meant to be squash-merged. This repo
keeps one commit per PR on `main`, regardless of how many commits your branch
accumulated getting there.

Only the maintainer merges PRs into `main`. That's true no matter how confident you
are the change is correct or how small it looks; open the PR and wait for review
rather than merging it yourself.

## Filing issues

Bug reports and proposals both go through GitHub issues. Before filing, check for an
existing issue covering the same thing. If you're reporting several related problems
that share a root cause, one issue covering all of them is more useful than one issue
per symptom.

## Questions

If anything about scope or process is unclear, open an issue and ask before doing the
work. That's cheaper for everyone than a PR that has to be redirected after the
fact.
