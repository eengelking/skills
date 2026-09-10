# skills

Shared Claude Code skills meant to be reusable across multiple projects. Skills tied to
one specific project's paths, tools, or conventions live in that project's own
`.claude/skills/` directory instead of here.

## Available skills

| Skill | Description |
|---|---|
| [`git-branching`](git-branching) | Getting from no branch to the correct one — branch naming, the two-tier integration-branch model for parallel work, and a pre-commit hook backstopping the branch-first rule. |
| [`github-pr-merge`](github-pr-merge) | Opening a PR, the merge/tag actions an agent may perform, and post-merge branch cleanup. |
| [`github-release`](github-release) | Cutting a release once a PR has merged — CHANGELOG/SemVer policy, build verification, version bumps, artifact publishing, and the git tag + GitHub Release. |
| [`github-issue-filing`](github-issue-filing) | Converts a staging inbox of informally-noted findings into properly labeled GitHub issues. |
| [`github-issue-workflow`](github-issue-workflow) | Governs the lifecycle of a GitHub-issue-tracked unit of work, from starting it to closing it out. |
| [`documentation-sync`](documentation-sync) | Keeps a change's accompanying docs correct in the same commit — a framework for deciding what doc owns what, plus per-project doc-ownership tables. |
| [`documentation-voice-guide`](documentation-voice-guide) | Voice and prose conventions for user-facing writing (READMEs, commit messages, PR descriptions, issue bodies). |
| [`development-commands`](development-commands) | Running tests/lint, starting the app for UI work, and seeding a throwaway database, generically across projects. |

## Installing a skill

Symlink the skill directory into a project's `.claude/skills/`, e.g.:

```sh
ln -s /path/to/skills/git-branching .claude/skills/git-branching
```
