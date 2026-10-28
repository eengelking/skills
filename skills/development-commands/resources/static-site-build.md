# Building and previewing a docs site

For a repo that builds a documentation site from its own files. The generator and its
commands are the project's, so read its docs and the build script's `--help`. The
habits below hold for any generator.

## Build

The build command is whatever the project documents. Common ones:

```bash
node site/scripts/build.mjs        # a project's own Node build script
mkdocs build                       # MkDocs
hugo                               # Hugo
bundle exec jekyll build           # Jekyll
```

- **Install the site's own dependencies where they live.** If the site is its own
  package with its own manifest and lockfile, install inside its folder, not from the
  repo root (for Node, `node/npm.md`; for Python, `python/testing.md`).
- **Build the quick version while you work, the full one before you finish.** Some
  builds offer a "latest version only" flag that takes seconds. A full build can read
  git tags to find every documented version, so fetch them first (`git fetch --tags`).
  A shallow or tagless clone builds fewer versions than CI, and a broken link in an old
  version only shows up in the full build.
- **A build that rejects a link or a page has told you something real.** Fix the link
  or the page. Don't loosen the check.

## Preview

Serve the output folder with any static file server and open it:

```bash
python3 -m http.server -d <output-dir> 4400     # needs Python 3.7 or later
```

Open `http://127.0.0.1:4400`. Stop the server when you finish, and check the port is
free afterward.

## Check how it looks

Take a screenshot at a narrow and a wide width with `ui-screenshots.md` (400 and 1440),
and read both. If the site has a light and a dark theme, set the theme from `--eval` and
shoot each.

## Before a release

Run the full build as part of the release check (`github-release`'s
`resources/release-check.md`). The release PR's CI usually runs it too, but find out
sooner.
