#!/usr/bin/env bash
# Wrapper around `gh pr merge` that refuses to merge any PR whose base
# branch is `main` or `development`. Merging into either is a human-only
# action per this repo's github-pr-merge skill -- an orchestrator agent may
# merge a sub-agent's PR into a batch integration branch it created, but
# must never merge anything into `main` or `development`. (`development` is
# only a shared branch in repos that use the development-branch workflow;
# guarding it elsewhere is harmless.) This script is the only way an agent
# is permitted to invoke `gh pr merge` at all (pair it with a deny rule on
# the raw `gh pr merge` command in your agent harness's permission config)
# so that guarantee can't be routed around.
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "usage: $0 <pr-number-or-url> [gh pr merge flags]" >&2
  exit 2
fi

pr="$1"
shift

base="$(gh pr view "$pr" --json baseRefName -q .baseRefName)"

if [[ "$base" == "main" || "$base" == "development" ]]; then
  cat >&2 <<EOF
REFUSED: PR $pr targets '$base'.

Merging into $base is a human-only action (see the github-pr-merge skill) and
this script will never do it, regardless of flags passed. Ask the user to
merge this PR themselves.
EOF
  exit 1
fi

exec gh pr merge "$pr" "$@"
