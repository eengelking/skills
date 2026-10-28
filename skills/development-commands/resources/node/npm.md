# Node and npm: installing and keeping the lockfile honest

The project's own docs name its Node version and its scripts. Read them there first.
This file covers the npm behavior that trips people up.

## Node version

- Use the version the project asks for (an `.nvmrc`, `.node-version`, or the root
  `package.json` `engines` field). Check with `node --version` before blaming a failure
  on the code.
- A nested package can carry its own `engines` that differs from the root. Read the
  `package.json` of the folder you are working in.
- Node 22 or later has a built-in `WebSocket`, which scripts that drive a browser over
  the DevTools protocol rely on (see `../ui-screenshots.md`).

## Install

```bash
npm ci --ignore-scripts      # clean, reproducible install from the lockfile
npm install                  # only when you mean to change the lockfile
```

- Prefer `npm ci` over `npm install` for a fresh checkout, a fresh worktree, a CI run
  and an image build. It installs exactly what the lockfile says and fails if the
  lockfile and `package.json` disagree.
- `--ignore-scripts` means no dependency's install script runs, so none is trusted. If
  one package really needs its script (a native build), run it alone:
  `npm rebuild <pkg>`. If you find yourself rebuilding many packages, stop and check
  whether the project meant to allow scripts.
- Read the `npm audit` summary that prints after an install. Report new findings; don't
  run `npm audit fix` unprompted, because it rewrites the lockfile.

## Workspaces

A repo with a `workspaces` field in the root `package.json` is one install for several
packages.

```bash
npm ci --ignore-scripts                 # once, at the root
npm run build -w <workspace-name>       # one workspace
npm test -w <workspace-name>
npm test                                # root script, usually fans out to every workspace
npm install --package-lock-only         # rewrite the lockfile to follow the manifests
```

- Run workspace commands from the root with `-w <name>`, where `<name>` is the
  `name` field in that workspace's `package.json`, not its folder.
- After you change a version or a dependency in any manifest, run
  `npm install --package-lock-only` so the lockfile's entries follow. Commit the
  lockfile with the manifest change.

## A nested package that is not a workspace

A folder with its own `package.json` that the root `workspaces` field does not list is
a separate package. It has its own lockfile and its own `node_modules`. Install it from
inside its folder (`cd <folder> && npm ci --ignore-scripts`), and never from the root.
Installing it from the root does nothing for it, and a root install can leave you
thinking it is ready.
