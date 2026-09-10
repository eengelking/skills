# Doc-sync routing for localscore

Before committing any change, deliberately check three files for claims the change
made stale:

- `CLAUDE.md`: the Status/topical section covering what changed
- `README.md`
- `docs/API.md`, if the change alters mandated API behavior (a new route, a
  changed request/response shape, a new status code, a new error case)

Look for a feature described as "not built yet" that this change just built, a
route or shape that changed, or a screen that didn't exist before. Fix the stale
claim in the **same commit** as the code, not a follow-up. Do this as a deliberate
last step before committing, not opportunistically while coding.

If the change alters routes/shapes/status codes/error bodies, read
`api-docs.md` (in this same resources directory) before touching `docs/API.md`. If
it alters how the project is tested, read `testing-docs.md`. If it's
release-worthy, read `changelog.md` before touching `CHANGELOG.md`.

## Placement policy

All project documentation except `README.md`, `CONTRIBUTING.md`, `CHANGELOG.md`,
and `CLAUDE.md` itself lives under `docs/` (e.g. `docs/API.md`, `docs/BACKEND.md`,
`docs/FRONTEND.md`). When adding a new doc, put it under `docs/` and link to it
from `README.md`/`CLAUDE.md` as appropriate. Never add a new root-level `.md`
file.

The one exception is GitHub-specific community-health files, since GitHub only
recognizes them at fixed paths: `.github/CODE_OF_CONDUCT.md`, `.github/SECURITY.md`,
`.github/ISSUE_TEMPLATE/*`, and `.github/pull_request_template.md`. These live
under `.github/`, not `docs/`; `CONTRIBUTING.md` links to the first two rather
than duplicating their content inline.

## Prose voice

Prose in this repo (docs, commit messages, PR descriptions, issue bodies, in-app
copy) follows the `documentation-voice-guide` skill. Load it before writing
anything user-facing or committing project prose.

## Sibling resources

- `api-docs.md`: keeping `docs/API.md` in sync with the actual route table.
- `testing-docs.md`: keeping testing procedure docs from forking across
  `CLAUDE.md`/`CONTRIBUTING.md` and the `testing` skill.
- `changelog.md`: `CHANGELOG.md` conventions, with real entry examples from this
  repo's history.
