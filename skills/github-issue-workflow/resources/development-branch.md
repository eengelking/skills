# Working issues when a `development` branch exists

Applies only when `development` exists on the remote:

```bash
git ls-remote --exit-code --heads origin development
```

If that exits non-zero, ignore this file. The lifecycle in `SKILL.md` (one issue
at a time, plan-mode kickoff, task list, Validation before the closing PR) is the same
in both workflows; only the points below change.

## Where the work lands

- Branch off `development`, and the closing PR targets `development`. See
  `git-branching`'s `resources/development-branch.md` for branch names.
- `development` is not the default branch, so `Closes #N` in that PR would not close the
  issue. Use `Refs #N`; the release PR carries `Closes #N`, and the issue closes when
  the user merges the release. There's still no separate manual close step.
- A merged PR still doesn't authorize starting the next issue.

## Parallel batches

The structure is unchanged: the orchestrator's integration branch forks from
`development`, each sub-agent forks from the integration branch, and the final
integration-branch PR is the only one that targets `development`, carrying a
`Refs #N` for every issue in the round. The shared-file rule widens by one entry:
sub-agents never touch a version manifest at all in this workflow, because no feature
PR bumps the version (see `github-release`).

## Hotfix issues

A hotfix PR targets `main`, the default branch, so `Closes #N` on it closes the issue
when it merges. The backport PR into `development` uses `Refs #N`. The user tells the
agent when to do the backport. Once the hotfix merges the issue closes; track the
backport in a comment or follow-up. A hotfix waiting only on that backport
does not count as the "one open issue" in the sequencing gate; other work can start. The Validation section is run against the
hotfix branch before the PR into `main`, and again on the backport branch before its
PR into `development`.

## Closing out

"Closing out an issue" in `SKILL.md` applies as written. One addition: a change that
lands on `development` is not released. If the issue's Definition of Done includes "is
live" or "is published", say in the issue that it ships with the next release, and do
not treat the merge as the release.
