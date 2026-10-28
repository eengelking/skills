# PRs and merges when a `development` branch exists

Applies only when `development` exists on the remote:

```bash
git ls-remote --exit-code --heads origin development
```

If that exits non-zero, ignore this file; `SKILL.md` as written is the whole
story. Branch names and where each one forks from are in `git-branching`'s
`resources/development-branch.md`; the release itself is in `github-release`'s.

## Who merges what

Nothing reaches `main` or `development` except through a PR, and the user merges every
one of those PRs. Agents never merge into either branch, and `main` and `development`
are never deleted. `resources/scripts/gh_merge_guard.sh` refuses a PR whose base is
either one. The orchestrator's merge of a sub-agent's PR into a batch integration
branch is unchanged.

## PR types

| PR | From → into | Merge method (user merges) | Body must say |
|---|---|---|---|
| Feature or informal fix | `issue/*`, `fix/*` → `development` | squash | to be squash-merged; `Closes #N` for each issue it resolves |
| Batch final PR | `batch/*` → `development` | squash | to be squash-merged; `Closes #N` for every issue in the round |
| Release prep | `release-prep/<version>` → `development` | squash | to be squash-merged; the version being prepared |
| Release | `development` → `main` | regular merge commit | **not** to be squashed; the version and its CHANGELOG section. No `Closes #N`: the issues closed when their own PRs merged |
| Hotfix, `development` differs from `main` | `hotfix/*` → `main` | user's choice, say which (squash or merge commit both work: the backport is cherry-picked from the branch's commits, and identical changes merge cleanly later) | the version and what it fixes; `Closes #N` for the hotfix's issue |
| Hotfix backport | `hotfix/*-backport` → `development` | squash | to be squash-merged; `Refs #N` for the hotfix's issue |
| Hotfix, `development` matches `main` | `hotfix/*` → `development` | squash | to be squash-merged; `Closes #N`. It ships in the next release PR with a PATCH bump; no backport |

## Closing issues

An issue is closed when the PR that resolves it merges, not when a release ships. A
feature, fix or batch-final PR into `development` carries `Closes #N` for each issue it
resolves, so the PR names what it resolves.

**GitHub will not close the issue for a PR into `development`.** GitHub's documentation
says closing keywords in a pull request description "are interpreted only when the pull
request targets the repository's default branch," and that otherwise "these keywords are
ignored, no links are created." The default branch stays `main` in this workflow, so a
PR into `development` links and closes nothing. The agent closes the issue itself once
the merge is confirmed (see "After a merge" below). A commit-message keyword behaves the
same way. If a project does make `development` its default branch, GitHub closes the
issue and the agent only verifies that it did.

`Refs #N` only links a PR to an issue. It never closes it. Use it where the PR relates
to an issue that something else already closed or will close (a hotfix backport), and
never on a PR that resolves the issue.

A hotfix PR into `main` carries `Closes #N`, and GitHub closes the issue when it merges,
because `main` is the default branch. Its backport into `development` carries `Refs #N`,
because the hotfix PR already closed the issue. A sub-agent's PR into a batch integration
branch claims no `Closes #N`, because the issue must stay open until the work reaches
`development`; the batch-final PR into `development` carries them all.

## Feature PRs do not bump the version

A feature or fix PR into `development` adds to `CHANGELOG.md`'s `[Unreleased]`
section and leaves every version manifest alone. The bump belongs to the release-prep
PR (see `github-release`). A repo's own CI check that requires a manifest bump on PRs
into `main` therefore applies to the release PR's contents, which arrive via the
release-prep PR already merged into `development`.

## Never squash the release PR

A squash merge of `development` into `main` gives `main` one new commit that
`development` doesn't contain, so the two branches look permanently different even
though their content matches. Use a regular merge commit. Say so in the release PR's
body at creation, the same way a squash is stated for the others. The user does the
merge, and `gh pr merge` remembers the last method used, so check the merge dropdown
before merging either kind of PR.

## After a merge

Confirm `state: MERGED` first, as in `SKILL.md`. Then:

- Feature, batch and `development`-bound hotfix PRs: close each issue the PR carried
  `Closes #N` for, then verify it. GitHub ignored the keyword (see "Closing issues"),
  so the issue is still open.

  ```bash
  gh issue view <N> --json state        # OPEN: GitHub did not close it
  gh issue close <N> --comment "Fixed in #<PR>. The change is on development and ships with the next release."
  gh issue view <N> --json state        # expect CLOSED
  ```

  Close only the issues the merged PR named with `Closes #N`, and never one it only
  linked with `Refs #N`. The comment always says the change is on `development` and ships
  with the next release, and if the issue's Definition of Done includes "is live" or "is
  published", that item stays open until the release. If the issue is already `CLOSED`
  when you check (the repo's default branch is `development`, or someone closed it), do
  nothing more.
- Feature, batch, release-prep, and backport branches: remove the branch's worktree,
  sync `development` in the primary checkout, and delete the branch locally and on the
  remote, with deletion verified on both sides, exactly as in `SKILL.md`.
- After the release PR: sync both `main` and `development`; delete `release-prep/*`
  branches that are merged. Tagging is `github-release`'s step.
- After a hotfix PR into `main`: leave the hotfix branch until its backport has also
  merged, because the backport is cherry-picked from it. Delete it then.
- A parallel batch's cleanup (sub-agent branches, worktrees, `worktree-agent-*`
  branches) is unchanged apart from "merged into `main`" reading "merged into
  `development`".
