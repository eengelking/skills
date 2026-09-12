# skills

Shared Claude Code skills meant to be reusable across multiple projects. Skills tied to
one specific project's paths, tools, or conventions live in that project's own
`.claude/skills/` directory instead of here.

## Available skills

| Skill | Description |
|---|---|
| [`git-branching`](skills/git-branching) | Getting from no branch to the correct one — branch naming, the two-tier integration-branch model for parallel work, and a pre-commit hook backstopping the branch-first rule. |
| [`github-pr-merge`](skills/github-pr-merge) | Opening a PR, the merge/tag actions an agent may perform, and post-merge branch cleanup. |
| [`github-release`](skills/github-release) | Cutting a release once a PR has merged — CHANGELOG/SemVer policy, build verification, version bumps, artifact publishing, and the git tag + GitHub Release. |
| [`github-issue-filing`](skills/github-issue-filing) | Converts a staging inbox of informally-noted findings into properly labeled GitHub issues. |
| [`github-issue-workflow`](skills/github-issue-workflow) | Governs the lifecycle of a GitHub-issue-tracked unit of work, from starting it to closing it out. |
| [`documentation-sync`](skills/documentation-sync) | Keeps a change's accompanying docs correct in the same commit — a generic framework for deciding what doc owns what, including SPEC.md-as-source-of-truth; a project's own doc-ownership table lives in that project's own `.claude/skills/`. |
| [`documentation-bootstrap`](skills/documentation-bootstrap) | Backfills or tops up a project's missing doc set in bulk — doc-type selection, a sequencing rule shared across parallel doc-writing sub-agents, and a post-bootstrap consistency check. For a single commit's worth of doc sync, see `documentation-sync` instead. |
| [`documentation-voice-guide`](skills/documentation-voice-guide) | Voice and prose conventions for user-facing writing (READMEs, commit messages, PR descriptions, issue bodies). |
| [`development-commands`](skills/development-commands) | Running tests/lint, starting the app for UI work, and seeding a throwaway database, generically across projects. |
| [`git-safety`](skills/git-safety) | Reference for dangerous git commands that need explicit per-use approval (force-push, hook-skipping flags, signing bypass, hard resets, branch/tag deletion, and more) and the practical routine for catching secrets before they're committed. |
| [`retrospective`](skills/retrospective) | Running a retrospective on finished work — went-well/went-wrong, root-causing every went-wrong item, sorting findings into skill-gap/model-behavior/tool-bug/fine, and implementing any real skill-gap fix through the host project's own branch/PR/merge workflow. |

## Installing

### Via the Claude Code plugin marketplace

```
/plugin marketplace add eengelking/skills
/plugin install skills@skills-marketplace
```

This installs all of the skills above at once.

### Manually, for local development

Symlink the skill directory into a project's `.claude/skills/`, e.g.:

```sh
ln -s /path/to/skills/skills/git-branching .claude/skills/git-branching
```

## Updating

When a skill in this repo changes, the plugin's `version` in `.claude-plugin/plugin.json`
gets bumped in the same PR. To pick up a new version after installing via the
marketplace:

```
/plugin marketplace update skills-marketplace
```

This refreshes the marketplace's metadata from this repo; Claude Code picks up the
new version on your next session. There's no separate per-skill update step —
`/plugin marketplace update` covers all of the skills above at once, since they
ship as one plugin.

If you installed manually via symlink instead, there's nothing to run — the
symlink always points at this repo's current working tree, so a local `git pull`
here is the update.

## License

[MIT](LICENSE)
