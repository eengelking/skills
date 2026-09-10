# Tag and GitHub Release (post-merge)

This is the only part of the release flow that waits for the PR to actually
merge. Version-bump and any artifact publish happen pre-merge, on the
feature branch.

## Git tag

```bash
git checkout main && git pull
git tag -a <version> -m "<version>"
git push origin <version>
```

Tag the `main` commit that resulted from the merge, not the feature branch
tip. Pull first to make sure you're tagging the actual merge commit (or
squash commit, see the merge-mode note below).

## GitHub Release

Extract the version's section from `CHANGELOG.md` (the text between the
`## [<version>] - <date>` heading and the next `## [` heading) and use it
verbatim as the release notes:

```bash
gh release create <version> --title <version> --notes-file <path-to-extracted-section>
```

**Never use `--generate-notes`, and never hand-write different wording.** The
changelog is the single source of truth; the release notes should say
exactly what the changelog says, so there's one place to look for what
shipped in a given version, not two slightly different accounts.

## Merge-mode note

`github-pr-merge`'s merge wrapper always squash-merges, so a squash merge is
what actually lands on `main` — a single new commit, not the original
feature-branch commits preserved individually. This matters here because
it's what determines the commit you're tagging: `git pull` after the merge
gives you that squash commit directly, whichever merge path produced it (the
user merging in the GitHub UI, or the one pre-authorized autonomous path a
repo's own dependabot-style skill might define).
