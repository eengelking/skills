# git and gh commands: where each one is covered

This is an index, not a second copy. Each command has one home. Use the skill named.

| Command | Covered in |
|---|---|
| `git ls-remote --exit-code --heads origin development` (which workflow applies) | `git-branching`, `SKILL.md` |
| `git config core.hooksPath scripts/hooks` (install the pre-commit hook) | `git-branching`, `SKILL.md` |
| `git worktree add` / `remove` / `prune` / `list` | `git-branching`, `resources/worktree-workflow.md`; cleanup order in `github-pr-merge` |
| `gh pr checks <PR> --watch` (wait for CI) | `github-pr-merge`, "Verify after opening" |
| `gh run view --log-failed` (why a check failed) | `github-pr-merge`, "Verify after opening" |
| `gh issue close <N> --comment ...` (close after a merge into `development`) | `github-pr-merge`, `resources/development-branch.md`, "After a merge" |
| Force-push, `--no-verify`, `reset --hard`, branch and tag deletion | `git-safety` |
