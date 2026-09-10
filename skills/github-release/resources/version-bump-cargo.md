# Version-bump mechanics: Rust (`Cargo.toml`/`Cargo.lock`)

Performed as a single commit, typically the last one on the feature branch
before pushing, once `build-verify-compiled.md` is green.

## What gets bumped

1. **`version` in every `Cargo.toml` this repo publishes** — a workspace can
   have a root version plus per-crate versions; check whether this repo's
   crates are meant to version together (common for a workspace with a
   single published binary/library) or independently before assuming "bump
   the root" is enough.
2. **`Cargo.lock`**: a `version` edit in `Cargo.toml` doesn't automatically
   update `Cargo.lock`'s own entry for this package. Run `cargo build` (or
   `cargo update -p <package>`) after the manifest edit so the lockfile picks
   up the new version — don't commit a `Cargo.toml`/`Cargo.lock` pair that
   disagree on the package's own version.
3. **`CHANGELOG.md`** per the parent skill's policy spine.

## Deciding the bump size

Patch/minor/major per the parent skill's SemVer policy — Rust's own ecosystem
convention (crates.io, `cargo semver-checks` if this repo uses it) already
expects strict SemVer, so there's no separate convention to reconcile here.
