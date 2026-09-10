# Secrets check

The routine for reviewing staged changes before a commit, and what to do if
something sensitive turns out to already be committed. Loaded from `git-safety`'s
own "Committing" section — read that first for why this applies to every commit,
not just ones that look credential-shaped.

## Before committing

1. **Look at the file list, not just the diff.** `git diff --staged --name-only`.
   A diff view can hide what matters in a binary file, a large generated file, or a
   file added wholesale (`git diff` shows the whole new file as "added," which is
   easy to skim past). New files especially warrant a look at their actual content,
   not just their name.
2. **Read the actual diff**, `git diff --staged`, for anything that looks like a
   credential: a long random-looking string, something assigned to a variable named
   `key`/`secret`/`token`/`password`/`credential`/`auth`, a block starting
   `-----BEGIN ... PRIVATE KEY-----`, a URL with a credential embedded
   (`https://user:pass@host`), or a cloud-provider key pattern (AWS access keys
   start `AKIA`, GitHub tokens start `ghp_`/`gho_`/`github_pat_`, Slack tokens start
   `xox`).
3. **Give extra scrutiny to file types that don't look like they'd contain
   secrets** but commonly do by accident: `.env`/`.env.*` files, `.pem`/`.key`
   files, any config file (`.json`, `.yaml`/`.yml`, `.toml`, `.ini`) copied from a
   real environment rather than written from scratch, notebook files (`.ipynb`) —
   their *output cells* can capture whatever a variable held when it ran, not just
   the source, shell history files, IDE workspace settings, `docker-compose
   .override.yml`, Terraform `.tfvars`, CI config with inline values instead of
   secret references, and database dumps or fixture data pulled from a real system.
4. **If a tool like `gitleaks`, `trufflehog`, or `git-secrets` (AWS Labs) is already
   installed and configured in this repo, run it** — it catches patterns a manual
   read will miss. Don't install one specifically for this pass unless the user
   asks; the manual review above is the routine that works with zero setup, on any
   repo, every time.

## If something sensitive is already committed

Treat it as compromised the moment it existed in a commit — not just if it reached
`main`, not just if the repo is public. A commit only on a local branch that never
got pushed is the one case where "just amend it out" is actually sufficient; for
anything that reached a remote, assume it's been seen.

1. **Flag it to the user immediately and recommend rotating the credential.**
   Removing it from the latest commit or even scrubbing it from history does not
   undo exposure that already happened — anyone who fetched, cloned, or forked
   before the fix still has the old commit, and GitHub's own caches/PR diffs can
   retain it independent of what the branch looks like now. Rotation is the only
   thing that actually closes the exposure; history cleanup is about hygiene going
   forward, not incident response.
2. **Only after rotation is handled (or explicitly deferred by the user)**, decide
   whether to also scrub history: `git filter-repo` (preferred over `git
   filter-branch`) rewrites every commit to remove the file or pattern, then
   requires a force-push to the same remote — see `git-safety`'s force-push entry
   for that step, since rewriting already-pushed history hits both that gate and
   the "amending or rewriting already-pushed commits" gate above.
3. **History-scrubbing only closes what you control.** If anyone else has a clone
   or fork, or the repo was ever public, their copies still have the old commit
   regardless of what you rewrite on your own remote — say this to the user rather
   than presenting a history rewrite as if it fully contains the exposure.
