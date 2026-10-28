# Building and previewing a docs site

For a repo that builds a documentation site from its own files. The build script's path
and flags are the project's; the examples use common ones. Read its docs and `--help`.

## Build

The site is usually its own package, with its own `package.json` and lockfile, so
install inside it, not from the repo root (`node-npm.md`):

```bash
cd site && npm ci --ignore-scripts
```

Then build:

```bash
node site/scripts/build.mjs --latest-only     # newest version only, quick (seconds)
node site/scripts/build.mjs                   # every version
```

- `--latest-only` is for checking your change. It is fast and enough for most edits.
- The full multi-version build reads git tags to find the other versions, so fetch them
  first: `git fetch --tags`. A shallow or tagless clone builds fewer versions than CI,
  and a broken link in an old version only shows up in the full build.
- A build that rejects a link or a page has told you something real. Fix the link or
  the page; don't loosen the check.

## Preview

```bash
python3 -m http.server -d site/out 4400
```

Open `http://127.0.0.1:4400`. Stop the server when you finish. Check the port is free
afterward.

## Check how it looks

Take a screenshot at a narrow and a wide width with `ui-screenshots.md` (400 and 1440),
and read both. If the site has a light and a dark theme, set the theme from `--eval` and
shoot each.

## Before a release

Run the full build as part of the release check (`github-release`'s
`resources/release-check.md`). The release PR's CI usually runs it too, but find out
sooner.
