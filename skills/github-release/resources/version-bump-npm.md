# Version-bump mechanics: npm (`package.json`)

Performed as a single commit, typically the last one on the feature branch
before pushing, once `build-verify-interpreted.md` is green.

## What gets bumped

1. **`version` in every `package.json` this repo has**, kept identical. A
   monorepo or a repo with a split client/server layout can have more than
   one `package.json` that needs to match (check for a workspace root plus
   per-package manifests) — bumping only some of them is a real bug if
   anything downstream (a build, a container image) reads from more than one.
   Grep for `package.json` files rather than assuming there's exactly one.
2. **Any doc literally quoting the current published version** (a README
   badge, an install snippet, a "current version" line). Grep for the old
   version string across docs rather than relying on memory of where it's
   quoted — a stale quoted version is easy to miss by inspection alone.
3. **`CHANGELOG.md`** per the parent skill's policy spine — move
   `[Unreleased]`'s entries under a new `## [<new-version>] - <YYYY-MM-DD>`
   heading, add a compare-link reference at the bottom if this repo uses
   those.
4. **If this repo has a lockfile** (`package-lock.json`, `pnpm-lock.yaml`,
   `yarn.lock`), a plain `version` edit in `package.json` doesn't touch it —
   confirm whether this repo's lockfile also embeds the root package's own
   version (most do, for the root entry) and re-run the install/lock command
   if so, so the lockfile doesn't silently drift from `package.json`.

## Deciding the bump size

Patch/minor/major per the parent skill's SemVer policy. The version number
itself is computed from the **prior published tag** (the latest entry in
`CHANGELOG.md`'s version history, which should match the latest git tag).
