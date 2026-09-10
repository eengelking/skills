---
name: github-release
description: Covers cutting an actual release once a PR has merged `main` to the released state — CHANGELOG/SemVer policy, build/test verification, version-bump mechanics, artifact publishing (container image or package registry), and the git tag + GitHub Release. Precondition — a PR bringing `main` to a releasable state is about to merge or has just merged, and this repo does releases at all (ask the user if that's not already established). Postcondition — `CHANGELOG.md` and any version manifest are bumped in the merging PR, any code/container/package this repo builds has been verified and published, and `main` has an annotated tag plus a GitHub Release whose notes are the CHANGELOG section verbatim. Load this once `github-pr-merge`'s branch/PR/merge work is otherwise done and a release is in scope — for opening the PR itself, merge authority, and branch cleanup, see `github-pr-merge` instead.
---

# Cutting a release

This is the generic release mechanism for any repo in this catalog. It has no
project-specific content of its own — what applies to *this* repo is whichever
resource files below match what this repo actually is (its language(s), its
manifest format(s), what it publishes, if anything). A repo's own CLAUDE.md may
record which of these apply here so you don't have to re-derive it every time.

**Don't invent a release mechanism** (a publish step, a registry, a build
command) by carrying one over from memory of another project. If this repo's
answer to "what do we build, and where does it publish" isn't already
documented, ask the user rather than guessing — then the repo's own docs are
the place to record the answer for next time, not this skill.

## Policy spine (applies to every repo, no exceptions)

- **Doc-only changes get no release.** A PR is doc-only if it touches nothing
  but documentation/comments — no source file, no build/manifest file, no
  Dockerfile or equivalent, in any language this repo contains. A mixed PR
  (any code change plus doc changes) still gets exactly one release for the
  whole PR — the doc-only exception only applies when *nothing but* docs
  changed. Doc changes in a doc-only PR simply ride along uncaptured until the
  next code-changing release.
- **Every release updates `CHANGELOG.md`**, regardless of project or
  language: retitle its `[Unreleased]` section to the new version and date, in
  the same PR that merges to reach the release state — not a follow-up commit
  after the tag. If this repo has no `CHANGELOG.md` yet, that's a gap to raise
  with the user before the first release, not a reason to skip this step going
  forward. Entry *style* (how to phrase a bullet, dependency-bump conventions)
  is owned by this repo's own documentation-authoring skill, if it has one —
  this skill only covers *when* and *where* the edit happens.
- **Every release follows [SemVer](https://semver.org/): `MAJOR.MINOR.PATCH`**:
  - **MAJOR** for a breaking change to the data model, a public interface, or
    a route consumers depend on — **or the agent-workflow contract itself**
    (this repo's CLAUDE.md/AGENTS.md + skills); "consumers" includes any agent
    working this codebase, not just the deployed app's end users.
  - **MINOR** for new features or additions that stay backward compatible.
  - **PATCH** for fixes with no interface change.
  - **Pre-1.0 (`0.y.z`)**: MINOR bumps can still include breaking changes per
    SemVer §4.
  - Never infer MAJOR from diff size or how a change "feels" — that's a
    promise to consumers, not a reflection of implementation effort. If it's
    genuinely ambiguous whether something is patch- or minor-sized, ask the
    user rather than guessing.
- Tag format is `vMAJOR.MINOR.PATCH` (e.g. `v0.1.0`), annotated, cut from
  `main` only after the PR bringing `main` to the released state has actually
  merged — never from a work branch. See `resources/tag-and-github-release.md`.
- Tagging, like merging, is the user's call — propose the tag and version,
  don't push one without confirmation.

## The four steps, in order

1. **Verify.** If this repo has a codebase (it almost always does), run its
   build/test verification before anything else — a release built on
   unverified code is not a release. Pick the resource matching this repo's
   language(s): `resources/build-verify-compiled.md` (Go, Rust, or any
   language with a real compile step) or `resources/build-verify-interpreted.md`
   (Python, Node/TypeScript, or similar). A repo with more than one language
   runs both. Gate on whatever this repo's own testing skill defines as
   "green," if it has one.
2. **Version-bump.** Bump `CHANGELOG.md` (policy above) plus any manifest
   this repo tracks its version in, in the same commit — never a follow-up
   commit, so they can't drift out of sync. Pick the resource matching this
   repo's manifest: `resources/version-bump-npm.md`, `resources/version-bump-python.md`,
   or `resources/version-bump-cargo.md`. A repo with no versioned manifest
   (the version lives only in `CHANGELOG.md`/git tags) skips this resource
   and just does the `CHANGELOG.md` half.
3. **Publish**, only if this repo actually ships a built artifact — many
   repos don't, and skip straight to step 4. If it does:
   - Ships a **container image**: `resources/publish-container-image.md`
     (build, tag, push, verify, then hand off to this repo's attestation
     process if it has one).
   - Ships a **package** to a registry (npm, PyPI, crates.io, etc.):
     `resources/publish-package-registry.md`.
   - A repo can do both (e.g. a CLI published as both an npm package and a
     container image) — run each applicable resource.
   This step runs pre-merge, on the feature branch, from the code that will
   land on `main` — not post-merge from `main` itself. Only the tag and
   GitHub Release (step 4) wait for the actual merge.
4. **Tag and GitHub Release**, post-merge only: `resources/tag-and-github-release.md`.
