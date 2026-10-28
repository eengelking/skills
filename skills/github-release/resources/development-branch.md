# Releasing when a `development` branch exists

Applies only when `development` exists on the remote:

```bash
git ls-remote --exit-code --heads origin development
```

If that exits non-zero, ignore this file; `SKILL.md` as written is the whole
story. Here, merging a feature PR is not a release. Feature PRs land on `development`
without a version bump, and a release happens only when the user decides
`development` is a release candidate.

## What changes from the policy spine

- **No version bump per merge.** Feature PRs add to `CHANGELOG.md`'s `[Unreleased]`
  section and nothing else version-related.
- **Doc-only changes** still produce no release on their own. A release is cut when
  `[Unreleased]` holds at least one code-changing entry; doc-only entries ride along.
- **The bump level comes from `[Unreleased]`.** Read everything accumulated since the
  last release (a hotfix counts as a release, so the base version is the newest tag on
  `main`, not the manifest on an older `development`) and apply the SemVer rules in `SKILL.md`: any breaking entry means
  MAJOR, otherwise any new feature means MINOR, otherwise PATCH. Pre-1.0 and the
  agent-workflow-contract rules are unchanged. If it's unclear which level an entry is,
  ask the user instead of picking. Choose by what the entries change, never by an
  issue's label: an `enhancement` that only removes unused code or tidies internals is
  a patch, and one that adds behavior a person can see is a minor.
- **Staged-DAG repos:** the merge that completes a stage's gate is the cue to ask the
  user about starting a release; the gate no longer produces one by itself.
- **Tag format and "tagging is the user's call"** are unchanged. Propose the version
  and tag; don't push one unprompted.

## The release candidate gate

A release candidate is valid only if all tests pass and there are no breaking tests,
conditions, or regressions. That's checked in two places, and failing either one means
no release:

1. Step 1 (Verify) is run against the tip of `development`, using the same
   `resources/build-verify-*.md` as the standard workflow.
2. The release PR's own CI checks are green.

`development` is allowed to be broken between releases. If Verify fails, fix it with
ordinary PRs into `development` and verify again. Don't open the release PR with a
known failure, and don't cut a hotfix to dodge one.

## Release sequence

1. **Verify** `development` (above).
2. **Release prep.** Branch `release-prep/<version>` from `development` and, in one
   commit: bump any manifest the repo tracks (`resources/version-bump-*.md`) and retitle
   `[Unreleased]` to `[<version>] - <date>`, leaving a new empty `[Unreleased]` above
   it. Run the release check in `resources/release-check.md` before opening the PR.
   Open a PR into `development`; the user merges it. This exists because nothing is
   committed to `development` directly.
3. **Publish**, if the repo ships an artifact, from the `development` tip that now
   carries the bump. As in the standard flow this runs before the merge to `main`, so a
   failed publish doesn't leave `main` ahead of the registry.
4. **Release PR.** Open `development` → `main`. Its body states that it is to be merged
   with a regular merge commit and not squashed, names the version, quotes the
   CHANGELOG section. It closes nothing and carries no `Closes #N`: each issue was
   closed when its own PR merged into `development` (`github-pr-merge`). The user
   merges it.
5. **Tag and GitHub Release** from `main` after the merge, per
   `resources/tag-and-github-release.md`. Tag the merge commit.

## Hotfixes

A hotfix is a fix that can't wait for the next release. Which path it takes depends on
whether `development` holds work that `main` doesn't:

```bash
git fetch origin && git diff --quiet origin/main origin/development && echo matches || echo differs
```

**`development` matches `main`.** There's no unreleased work to protect, so skip the
cherry-pick. Make the fix on a branch off `development` with a PR into `development`,
failing test first, like any other change (`Closes #N`, and the agent closes the issue
after the merge). Then release it with the normal sequence above: a `release-prep` PR
that bumps the PATCH version and gives the fix its CHANGELOG section, then the
`development` to `main` release PR. Re-run the comparison before starting; if
`development` has since gained other work, use the path below.

**`development` differs from `main`.** The fix goes to `main` directly and is then
copied into `development` so the branches don't drift.

1. Branch `hotfix/<n>-<slug>` from `main` (synced), reproduce the bug with a failing
   test first, then fix it.
2. In the same branch, bump the PATCH version in any manifest and add a
   `## [<version>] - <date>` section to `CHANGELOG.md` for the fix. A hotfix never
   moves `[Unreleased]`.
3. Run Verify against the branch. Open the PR into `main`; the user merges it. Then tag
   and create the GitHub Release as in step 5 above.
4. **Backport into `development`.** The user tells the agent to do this; don't start it
   unprompted. Branch `hotfix/<n>-<slug>-backport` from a synced `development`, then
   `git cherry-pick -x` every commit from the hotfix branch (the fix, test, version
   bump, and CHANGELOG section all, not just the code). Resolve the CHANGELOG so the
   hotfix's section sits below `[Unreleased]` under its own version heading, exactly
   as on `main`, with nothing from the hotfix duplicated into `[Unreleased]`. Open a
   PR into `development` that says `Refs #N` for the hotfix issue (the hotfix PR into `main` already closed it); the user merges
   it.
5. If a release-prep PR is already merged but its release hasn't happened yet, the
   backport's version and the pending one disagree. Stop and ask the user how to
   order them.

Skipping the backport lets the fix vanish at the next release, because `development`
doesn't contain it. The hotfix issue closed when the PR into `main` merged; track the
backport in a comment or follow-up until it merges.
