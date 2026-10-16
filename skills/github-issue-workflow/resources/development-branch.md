# Working issues when the default branch is `development`

Applies only when the repo's GitHub default branch is `development`:

```bash
gh repo view --json defaultBranchRef --jq .defaultBranchRef.name
```

If that prints anything else, ignore this file. The lifecycle in `SKILL.md` (one issue
at a time, plan-mode kickoff, task list, Validation before the closing PR) is the same
in both workflows; only the points below change.

## Where the work lands

- Branch off `development`, and the closing PR targets `development`. See
  `git-branching`'s `resources/development-branch.md` for branch names.
- `development` is the default branch, so `Closes #N` in that PR closes the issue when
  the user merges it. There's still no separate manual close step.
- A merged PR still doesn't authorize starting the next issue.

## Parallel batches

The structure is unchanged: the orchestrator's integration branch forks from
`development`, each sub-agent forks from the integration branch, and the final
integration-branch PR is the only one that targets `development`, carrying a
`Closes #N` for every issue in the round. The shared-file rule widens by one entry:
sub-agents never touch a version manifest at all in this workflow, because no feature
PR bumps the version (see `github-release`).

## Hotfix issues

A hotfix PR targets `main`, which is not the default branch, so `Closes #N` on it
does not close anything. The hotfix issue closes through the backport instead: put
`Closes #N` in the PR that cherry-picks the fix into `development`. The user tells the
agent when to do the backport. Leave the issue open, with its checklist showing the
backport as the remaining item, until then. The Validation section is run against the
hotfix branch before the PR into `main`, and again on the backport branch before its
PR into `development`.

## Closing out

"Closing out an issue" in `SKILL.md` applies as written. One addition: a change that
lands on `development` is not released. If the issue's Definition of Done includes "is
live" or "is published", say in the issue that it ships with the next release, and do
not treat the merge as the release.
