# Release check

A release goes wrong in small places: a version string left behind, a changelog link
pointing at the old tag, a documented default that stopped matching the code. This
check looks for those before the release-prep PR is opened.

## The checker

Start a fresh, non-fork subagent on a small model (the Agent tool with `model: "haiku"`
and no `subagent_type: "fork"`). A fork would inherit merge and tag authority, so it is
never used for this.

Its prompt names the version and states its authority: "report a verdict; you do not
have merge, tag or push authority, and you do not edit files." It checks that:

- every file that carries the version agrees with the others and with the release
  version (the project lists those files; if it doesn't, build the list from a grep);
- `CHANGELOG.md` has a dated section for exactly this version, holding what accumulated
  under `[Unreleased]`, with a fresh empty `[Unreleased]` above it and the compare links
  at the bottom correct;
- a grep for the old version string has been looked at, and each hit that is not known
  sample data is listed;
- documentation that quotes numbers (defaults, limits, ports, counts) still matches the
  code, checked for each part an `[Unreleased]` entry touches;
- the docs site or any other build artifact the project has builds, with no broken
  link;
- tests and the build pass.

It reports a short pass/fail list, with the file and line of each mismatch.

## After it reports

Fix every failure and run the checker once more. If the second run still fails, stop
and ask.

## A pass is a claim, not the check

Run the project's tests and build yourself too, as you do before any PR. The checker's
report says what it saw, not what is true.
