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
- The PR carries `Closes #N` to name the issue it resolves. GitHub only acts on a closing
  keyword in a PR into the default branch (`main`), so for a PR into `development` it
  ignores the keyword and the issue stays open. After confirming `state: MERGED`, the
  agent closes the issue and verifies it, as in `github-pr-merge`'s
  `resources/development-branch.md` ("After a merge"). The release PR closes nothing.
  `Refs #N` only links an issue and never closes it, so a PR that resolves an issue never
  uses it.
- A merged PR still doesn't authorize starting the next issue.

## Parallel batches

The structure is unchanged: the orchestrator's integration branch forks from
`development`, each sub-agent forks from the integration branch, and the final
integration-branch PR is the only one that targets `development`, carrying a
`Closes #N` for every issue in the round. A sub-agent's PR into the integration branch
claims none. The shared-file rule widens by one entry:
sub-agents never touch a version manifest at all in this workflow, because no feature
PR bumps the version (see `github-release`).

## Hotfix issues

Which path a hotfix takes depends on whether `development` matches `main`; see
`git-branching`'s `resources/development-branch.md`.

- **`development` differs from `main`.** The hotfix PR targets `main` and carries
  `Closes #N`, so the issue closes when it merges. The backport PR into
  `development` uses `Refs #N`, because the issue is already closed. The user tells the agent when to do the backport. Once
  the hotfix merges the issue closes; track the backport in a comment or follow-up. A
  hotfix waiting only on that backport does not count as the "one open issue" in the
  sequencing gate; other work can start. The Validation section is run against the
  hotfix branch before the PR into `main`, and again on the backport branch before its
  PR into `development`.
- **`development` matches `main`.** The fix is an ordinary branch and PR into
  `development`, so the "Where the work lands" rules above apply: `Closes #N` in the
  PR, and the agent closes the issue after the merge. There is no backport.

## Closing out

"Closing out an issue" in `SKILL.md` applies as written. One addition: a change that
lands on `development` is not released. If the issue's Definition of Done includes "is
live" or "is published", say in the issue that it ships with the next release, and do
not treat the merge as the release.
