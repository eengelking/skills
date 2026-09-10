---
name: git-safety
description: Reference for git/GitHub commands that are dangerous enough to need explicit, in-the-moment approval before running — force-push, hook-skipping flags (--no-verify and friends), commit-signing bypass, git reset --hard, git clean -f, branch or tag deletion, amending or rewriting already-pushed commits, and git push --mirror. For each, explains what it actually does, why it's gated, and the safe alternative to reach for first. Also covers the practical routine for reviewing staged changes for accidental secrets before committing, and what to do if one turns out to already be committed — see references/secrets-check.md. Load this before running any of these commands, before committing whenever secrets are a live concern, or whenever asked to force/skip/bypass/override a git safety mechanism, even if a similar action was approved earlier in the same session — a prior approval never carries forward to the next instance of the same command.
---

# git-safety

Every command on this page shares one property: it's either genuinely hard to undo,
or it silently defeats a check that exists to catch a real class of mistake. Neither
kind is something to run "because it's probably fine" or because it worked without
complaint last time. Ask before running any of them, every time, even if the user
approved the same kind of action minutes ago in the same conversation — the
approval was for that instance, not a standing grant.

For each command below: what it does, why it's gated, and the safe alternative to
try first. If the safe alternative genuinely doesn't fit the situation, that's the
point to explain why and ask — not to reach for the dangerous form on your own
judgment.

## Force-push (`git push --force`)

Overwrites the remote branch's history with your local branch, discarding whatever
commits existed there that you don't have. If anyone else has pulled the old tip,
their next pull will look like a conflict or silently diverge, and any commits that
only existed on the old remote tip are gone unless someone still has a local copy.

**Try first:** `git push --force-with-lease`. It refuses the push if the remote tip
has moved since you last fetched it — the exact case where a plain `--force` would
clobber someone else's work — while still letting the push through when the remote
genuinely only has your own stale history.

**If force-push is genuinely necessary** (e.g. cleaning up a feature branch only you
work on, or a deliberate history rewrite already discussed with the user): confirm
who else might have this branch checked out or pulled, then use
`--force-with-lease` rather than bare `--force` even when approved — there's no
downside to the safer form when the outcome you want is the same.

## Hook-skipping flags (`--no-verify`, disabling hooks)

`git commit --no-verify` / `git push --no-verify` skip pre-commit and pre-push
hooks entirely — the checks a repo installed specifically to catch something before
it lands (lint, tests, the branch-protection hook from `git-branching`, a
secrets scan). Same effect from `core.hooksPath` pointed elsewhere, hooks
directory renamed, or a hook file made non-executable.

**Try first:** find out *why* the hook is failing and fix that. A failing hook is
almost always telling you something true about the change, not being an obstacle
to route around.

**If skipping is genuinely warranted** (a hook that's broken independent of your
change, confirmed with the user): skip it for that one command, then fix or report
the broken hook — don't leave the team's safety net silently broken for the next
person.

## Commit-signing bypass (`--no-gpg-sign`, `-c commit.gpgsign=false`)

Skips cryptographic signing on a commit that would otherwise be signed, breaking
the chain of verified authorship for that commit. If signing is failing, that
usually means a real, fixable local problem (expired key, misconfigured agent,
wrong key selected) rather than a reason to produce an unsigned commit.

**Try first:** diagnose the signing failure (`gpg --list-secret-keys`, check
`GPG_TTY`, confirm the configured key matches what's loaded) and fix it.

**If bypass is genuinely warranted:** confirm with the user first — this isn't a
call to make unilaterally, since it changes what the commit can later prove about
who made it.

## `git reset --hard`

Rewrites the working tree and index to match a given commit, discarding *all*
uncommitted changes — staged and unstaged — with no undo beyond what happens to
still be in the reflog. Unlike a merge conflict or a bad commit, there's no partial
version of this: everything not committed is just gone.

**Try first:** `git status` to see what's actually at stake, then either commit or
`git stash -u` (the `-u` matters — plain `stash` leaves untracked files behind)
before resetting. If the goal is "throw away my local changes and match a specific
commit," stashing first costs nothing and gives you a recovery path if the reset
turns out to have discarded something you needed.

**If a hard reset is genuinely the right tool:** run the `git status` check
immediately before it, in the same breath — state at that moment is what matters,
not state from earlier in the session.

## `git clean -f` / `-fd`

Deletes untracked files (`-f`) and untracked directories (`-fd`) with no recovery
path — these were never committed, so there's no reflog entry to fall back on.
Build artifacts and scratch files are the common target, but this doesn't
distinguish those from a file you forgot to `git add`.

**Try first:** `git clean -n` (or `-ndf` for directories) — a dry run that lists
exactly what would be deleted, with no changes made. Read the list before deciding
this is what you want.

**If cleaning is genuinely necessary:** run the dry run immediately before the real
command and actually check its output, don't just run `-n` as a formality.

## Amending or rewriting already-pushed commits

`git commit --amend`, `git rebase`, or `git filter-branch`/`filter-repo` applied to
a commit that's already on the remote changes that commit's hash. Anyone who
already pulled the old version now has a branch that's diverged from yours, and
reconciling it requires their own force-fetch or reset — not something they'll
expect without being told.

**Try first:** a new commit. History that's already shared is, practically
speaking, public — treat it as append-only unless there's a specific, discussed
reason not to (e.g. scrubbing a committed secret — see `references/secrets-check.md`).

**If rewriting shared history is genuinely warranted:** confirm with the user, and
expect it to require a force-push (see above) plus telling anyone else with a copy
of the branch to re-sync rather than merge.

## `git push --mirror`

Pushes and *deletes* remote refs to make the remote match your local repo exactly
— including deleting remote branches and tags that don't exist locally. This is a
different, wider blast radius than a normal push or even a force-push to one
branch: it can silently remove other people's branches you never intended to touch.

**Try first:** push the specific branch or tag you actually mean to update.
`--mirror` is very rarely the right tool outside of setting up a repo migration or
backup, and even then it's worth a second look at exactly what refs exist on both
sides first.

## Deleting a branch or tag

`git branch -D` / `git push origin --delete <branch>` and `git tag -d` / `git push
origin --delete <tag>` remove something that (for a tag especially) may be what a
release or a deployment refers to by name.

**Try first:** confirm the branch is actually merged (`git branch -d`, the
lowercase form, refuses to delete an unmerged branch — that refusal is useful
signal, not an obstacle) or that the tag is genuinely unreleased/mistaken, not just
old. `github-pr-merge`'s own post-merge cleanup already covers the routine,
expected case of deleting a branch right after its PR merges — this entry is about
any *other* branch or tag deletion, where "was this actually supposed to go" hasn't
already been established by a merge you just confirmed.

**If deletion is genuinely warranted:** for a tag already used in a release or
deployment, confirm with the user before deleting — someone or something may
reference it by name.

## Committing: secrets review

Before committing, staged changes need a quick pass for anything sensitive — this
applies to every commit, not just ones that look like they'd touch credentials. See
`references/secrets-check.md` for the actual routine: what to run, which
unassuming file types deserve a closer look, and what to do if something sensitive
turns out to already be committed.
