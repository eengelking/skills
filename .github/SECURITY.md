# Security Policy

## What "security" means for this repo

This repo isn't a running service — it's Markdown instructions and a couple of
shell scripts (e.g. `skills/github-pr-merge/resources/scripts/gh_merge_guard.sh`,
the pre-commit hook under `skills/git-branching/resources/scripts/hooks`) that a
Claude Code agent reads and runs on someone else's machine and repo. So the
vulnerability classes that matter here look different from a typical web app:

- A skill instructing a destructive or overly permissive git/shell command
  (force-push, hard reset, skipping commit checks) without the safeguards it
  claims to have.
- A script with a command-injection-shaped bug — unsanitized input reaching a
  shell command, unsafe use of `eval`, or similar.
- A skill that could cause an agent to leak secrets or credentials, or take a
  destructive action, without the user's knowledge or approval.

If you've found something like this, please report it rather than opening a
public issue.

## Reporting a vulnerability

Open a private GitHub Security Advisory on this repo:
[github.com/eengelking/skills](https://github.com/eengelking/skills) → the
"Security" tab → "Report a vulnerability". That's GitHub's built-in
private-disclosure mechanism, so the report stays visible only to the
maintainer until it's resolved.

Please don't file a public issue for a suspected vulnerability — everything
in this repo is public, so a public issue discloses it before there's a fix.

## What to expect

This is a solo-maintained project, so response times aren't guaranteed, but
reports are read and taken seriously. If a report turns out to be valid,
the fix ships as a normal PR and the plugin version in
`.claude-plugin/plugin.json` gets bumped along with it.
