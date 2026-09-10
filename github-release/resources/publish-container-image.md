# Publishing a release container image

Only applies if this repo actually ships a container image — check for a
`Dockerfile`/`Containerfile` plus an existing published registry path (in
CLAUDE.md, CI config, or a README badge) before assuming this step applies.
If this repo builds containers but there's no established registry
destination yet, ask the user rather than inventing one.

This is separate from any local-only container build this repo's own testing
skill performs for verification (build-and-run locally, never pushed). A
release build is specifically one meant to be published to this repo's
registry.

This runs on the **feature branch itself, before the PR merges**. The image
that gets published is built from the code that will land on `main` once the
PR merges, not from `main` after the fact. Only the git tag and GitHub
Release (see `tag-and-github-release.md`) wait for the actual merge.

## Build, tag, push

```bash
<build-tool> build -t <image>:<version> .
```

Always a fresh build — never reuse a stale local image, since the whole point
is publishing what's actually on this branch. If using Podman rather than
Docker, pass `--format docker` explicitly: Podman's default OCI build format
silently drops a Dockerfile's `HEALTHCHECK` instruction with only a warning,
no error, and a release image without a working healthcheck defeats the
point of shipping one.

```bash
<build-tool> tag <image>:<version> <registry>/<image>:<version>
<build-tool> tag <image>:<version> <registry>/<image>:latest
<build-tool> push <registry>/<image>:<version>
<build-tool> push <registry>/<image>:latest
```

Never push an ad-hoc/untagged image, and never push `latest` alone without
also pushing the matching version tag — a `latest`-only push loses the
ability to pin or roll back to a specific release.

## Verify, don't trust exit codes

A clean exit from the push command isn't sufficient confirmation. Verify the
push actually landed on the registry, e.g.:

```bash
<build-tool> inspect <registry>/<image>:<version> --format '{{.Digest}}'
<build-tool> inspect <registry>/<image>:latest --format '{{.Digest}}'
```

Assert the two digests are equal — that confirms both tags point at the same
image on the registry, not just that both push commands returned 0. If
`skopeo` is available in this environment, `skopeo inspect` against the
registry reference is an alternative that doesn't require a local pull; if
not, the `podman inspect`/`docker inspect` approach above works against a
locally-pulled reference. Note that `podman manifest inspect` against a
plain (non-manifest-list) image returns `"manifests": null`, not a digest —
that's not the right tool for this check.

If this repo publishes multiple platforms as a single manifest list, verify
the manifest list's digest instead, and confirm it references an entry for
each platform this repo claims to support.

## After a verified push

If this repo has a supply-chain attestation process (SBOM + signing), hand
off to it now, bound to the exact digest just verified. Don't consider the
image "published" until that step also succeeds, if this repo has one — an
attestation failure blocks the release from being announced as complete.

## Cleanup

Once the push (and attestation, if applicable) is verified, clean up the
local build per this repo's own container-cleanup conventions if it has
them — ask before removing images, and prune dangling images after repeated
builds against the same tag.
