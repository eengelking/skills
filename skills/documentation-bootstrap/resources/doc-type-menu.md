# Doc-type selection menu

This is the full checklist for Step 1. It mirrors `documentation-sync`'s doc-type
table exactly — same names, same "what it owns," same "applies when" — so the two
skills never quietly disagree about what a given doc type is for. If that table
changes, update this list to match rather than letting the two drift.

## Detecting "already exists"

Check for the file at its conventional path before presenting the menu. A doc
type counts as existing if that file is present and non-empty — an empty
placeholder file (e.g. an auto-generated blank `CONTRIBUTING.md` from a repo
template) counts as missing, since bootstrapping it is still the right call.

## Detecting whether CHANGELOG counts as "standard" here

Run `git tag --list`. Non-empty output means the project already has releases, so
CHANGELOG.md joins the pre-checked standard group if it's missing. Empty output
means don't pre-check it — a project with no tags yet may not be ready to promise
a versioned release history, and forcing one into existence is a bigger decision
than a doc-scaffolding pass should make silently. It can still be selected
manually if the user wants it anyway.

## The menu

### Standard (missing ones pre-checked)

| Doc type | What it owns | Conventional path |
|---|---|---|
| README.md | Orientation for someone landing in the repo | `README.md` |
| Project status doc | Current-state facts and narrative | `CLAUDE.md` or project equivalent |
| CHANGELOG.md | One entry per release | `CHANGELOG.md` — pre-checked only if `git tag --list` is non-empty |

### Confirm-required (missing ones unchecked by default)

| Doc type | What it owns | Applies when... |
|---|---|---|
| ARCHITECTURE.md | System structure and data flow, for humans | The system is non-trivial enough to outgrow the status doc's own architecture notes |
| SPEC.md | Source of truth for intended behavior/requirements | The project is complex enough to need requirements independent of the code |
| DECISIONS.md | Log of significant design/architecture decisions and their rationale | The project has made non-obvious tradeoffs worth preserving the reasoning for |
| GOTCHAS.md | Known sharp edges and non-obvious pitfalls | The project has accumulated gotchas that would otherwise get retaught each time someone hits them |
| API.md | A public or consumed API surface | The project exposes an API |
| USER_GUIDE.md | End-user-facing usage, distinct from developer docs | The project has end users, not just developers/maintainers |
| DEPLOYMENT.md | How to deploy and operate the project | The project is deployed somewhere beyond local dev |
| NON_NEGOTIABLES.md | Hard, project-specific constraints that never get traded away for convenience | The project has constraints specific to it that are non-negotiable regardless of convenience |
| LICENSE | Legal terms for use/distribution | The repo is, or may become, public |
| CONTRIBUTING.md | How an outside contributor proposes a change | The repo accepts contributions beyond the maintainer |
| `.github/PULL_REQUEST_TEMPLATE.md` | Standard PR checklist | Repo ships a PR template |
| `.github/ISSUE_TEMPLATE/*.md` | Standard issue intake forms | Repo ships issue templates |
| `.github/CODE_OF_CONDUCT.md` | Community behavior expectations | The repo has, or expects, outside contributors |
| `.github/SECURITY.md` | How to report a vulnerability | The repo is public |
| `.github/CODEOWNERS` | GitHub-native automatic review assignment by path | The repo has multiple maintainers/reviewers |
| `.github/dependabot.yml` | Automated dependency-update config | The project has dependencies worth automating updates for |

`ISSUES.md` (the `docs/ISSUES.md` staging inbox from `github-issue-filing`) is
deliberately left off this menu — it's a workflow artifact the user adopts by
starting to use it, not a doc that gets backfilled from history.

## Example prompt shape

This is the first place in this repo establishing a checkbox-style user prompt —
use this as the literal pattern (an `AskUserQuestion`-shaped call, multi-select,
one question):

```json
{
  "question": "Which docs should this bootstrap run create or top up?",
  "multiSelect": true,
  "options": [
    { "label": "README.md (missing — standard)", "description": "Orientation for someone landing in the repo." },
    { "label": "CLAUDE.md (missing — standard)", "description": "Current-state facts and narrative." },
    { "label": "CHANGELOG.md (missing — standard, releases detected)", "description": "One entry per release, derived from git tags/PR history." },
    { "label": "ARCHITECTURE.md (missing)", "description": "System structure and data flow, for humans." },
    { "label": "SPEC.md (already exists — will be skipped)", "description": "Source of truth for intended behavior; not regenerated." }
  ]
}
```

Mark already-existing types clearly in the label (as above) rather than omitting
them from the list — seeing "already exists, skipped" is what tells the user this
run won't clobber something they already have.
