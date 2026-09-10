# Publishing a release package (npm, PyPI, crates.io, ...)

Only applies if this repo actually publishes a package for others to
install — a library or CLI, not an application deployed only as a container
or service. Check for an existing registry listing (the package's own page
on npm/PyPI/crates.io, or a publish step in CI) before assuming this applies
or inventing a registry destination; ask the user if it's not already
established.

This runs on the **feature branch itself, before the PR merges**, same as a
container publish — the published artifact is built from the code that will
land on `main`, not from `main` after the fact.

## npm

```bash
npm publish --dry-run   # confirm the file list is what you expect first
npm publish
```

Check `package.json`'s `files`/`.npmignore` before the dry run if this is a
repo you haven't published from before — an unexpected file list (missing
`dist/`, an accidentally-included `.env`) is much cheaper to catch here than
after a real publish, since npm versions can't be overwritten once published.

## PyPI

```bash
uv build          # or: python -m build
uv publish        # or: twine upload dist/*
```

Build into a clean `dist/` (remove stale build artifacts first) so a publish
never ships a leftover wheel from a prior version.

## crates.io

```bash
cargo publish --dry-run   # confirm the package first
cargo publish
```

`cargo publish` is permanent for that version number — a dry run catching a
packaging mistake (a missing file via `include`/`exclude` in `Cargo.toml`) is
much cheaper than a real publish.

## After a verified publish

Confirm the new version actually shows up on the registry (its page, or `npm
view <pkg> version` / `pip index versions <pkg>` / `cargo search <pkg>`) —
don't trust a clean exit code alone, registries can lag or reject silently
depending on the failure mode.
