# Reading CodeQL results from a GitHub pipeline

CodeQL runs in CI (a workflow using `github/codeql-action`), not on your machine. Its
findings are "code scanning alerts". Check them on your PR before asking for review, and
fix what they flag in the same PR.

## From the PR's checks

```bash
gh pr checks <PR>                 # the CodeQL jobs show as pass or fail
gh run view <run-id> --log-failed # why a CodeQL job failed to run (not the findings)
```

A failing CodeQL job usually means the analysis itself broke (a build step failed, a
language was not detected). The findings are separate, below.

## The alerts for a PR

```bash
gh api "repos/{owner}/{repo}/code-scanning/alerts?ref=refs/pull/<PR>/merge&state=open" \
  --jq '.[] | "\(.rule.severity) \(.rule.id) \(.most_recent_instance.location.path):\(.most_recent_instance.location.start_line)  \(.html_url)"'
```

- `ref=refs/pull/<PR>/merge` asks for the alerts on the PR's merge result.
- `state=open` hides ones already fixed or dismissed. Drop it to see everything.
- `gh` fills `{owner}` and `{repo}` from the current checkout.
- The same list is in the browser under the repo's Security tab, Code scanning, or on
  the PR itself as annotations in the Files changed view.

An empty result is only meaningful once the CodeQL job on that commit has finished. Run
the command after `gh pr checks --watch` reports the job done.

## What to do with an alert

Fix it in the PR. If it is a false positive, don't dismiss it yourself. Tell the user
the alert, why you think it is wrong, and let them decide, because a dismissal removes
the alert from everyone's view.

A token that can read code scanning alerts is needed: `gh auth status` should show the
`security_events` scope (or the repo permission "Code scanning alerts: read").
