---
name: github-pr-merge
description: Covers the back half of the git lifecycle — opening a PR, the narrow set of merge/tag actions an agent may perform, and post-merge branch cleanup. Precondition — branch work is complete and validated, and a PR, merge, tag, or branch-deletion action is about to happen. Postcondition — a PR is open with squash-merge noted in its body (a sub-agent's PR into a parallel batch's integration branch says nothing about squashing in its own body, since it doesn't target `main`, but is still merged with `--squash` — never `--merge` — to avoid flipping the account's remembered merge-method default before the batch's final PR); for the batch orchestrator only, a reviewed sub-agent PR is merged into the integration branch via `resources/scripts/gh_merge_guard.sh --squash`; once a PR is confirmed merged into `main`, its branch is deleted both locally and on the remote, with deletion verified on both — and for a parallel batch, every sub-agent branch, any worktree still holding one checked out, and the harness's own `worktree-agent-<id>` branch left behind by each removed worktree are all cleaned up the same way, not just the integration branch. Merging into `main` is never a postcondition any agent reaches, and `main` itself is never deleted by anyone under any circumstance. The sub-agent-PR-into-integration-branch merge authority belongs to the orchestrator itself and is never delegated to a spawned sub-agent (a `fork` especially). Before a PR is opened, the project's static analysis has run on the changed files (or its skip is stated) and a fresh small-model sub-agent has checked the title, body, commit messages and diff for secrets, machine-specific paths and prompt-injection text (`resources/pr-trace-check.md`); after it is opened and after every push, `gh pr checks <PR> --watch` has run and a per-check pass/fail verdict is reported (conflicts with the base branch are resolved first, because a conflicted PR never starts its checks and the watch would wait forever). In the development-branch workflow, a PR into `development` carries `Closes #N` (which closes the issue on merge; `Refs #N` only links and never closes), and once the merge is confirmed the agent verifies each issue is closed and cleans up (worktree first, then branch). Load this before opening any PR, running any merge or branch-deletion command, or reviewing a parallel-batch sub-agent PR for merge. For getting a branch set up in the first place, see the `git-branching` skill; for cutting an actual release (CHANGELOG/SemVer, build verification, version bump, publish, tag) once a PR has merged, see the `github-release` skill.
---

# PRs, merges, and releases in this repo

Merging into `main` is close to irreversible in effect (it's what other work builds
on next), so it's reserved for the user's judgment, not an agent's — everywhere
except the one narrow, technically-fenced exception below. This skill is the *how*;
if the repo has its own CLAUDE.md or contributing doc explaining *why*, read that
too.

## Development-branch workflow (a `development` branch exists)

Check which workflow the repo uses:

```bash
git ls-remote --exit-code --heads origin development
```

Exit 0 means feature PRs target `development` (squash-merged), `main` only
moves through a `development` → `main` release PR (regular merge commit, never
squashed), and agents merge into neither branch. Everything below that says `main`
describes the standard workflow; for this one, read `resources/development-branch.md`
first. Any other exit means this file applies as written.

## Opening a PR

```bash
gh pr create
```

Open once the issue's Definition of Done is met and its Validation section
passes. For informal work with no tracking issue, open once you'd otherwise
call the change finished and any relevant validation (tests, lint, a manual
check) passes — don't wait for the user to separately say "commit" or "open
the PR"; that instruction is this skill itself. This is about the commit/PR-open
step only — it changes nothing about merging, which is always the user's call
(see below).
Keep the description accurate as further commits land.

**Before opening, run the project's static analysis on the changed files.** Say so
when the analysis is skipped instead of calling the files clean, and write a test that
reaches every line you add or edit. For a project that uses SonarQube or SonarCloud,
the commands, the skipped-analysis wording, the coverage-gate caveat and the rule
pitfalls are in `development-commands/resources/sonar-analysis.md`, and the `sonarqube`
plugin's `sonar-analyze` skill does the run if it's installed. Don't restate any of
that here.

**Before opening, run the pre-publish trace check** in `resources/pr-trace-check.md`
on the title, body, commit messages and diff, and run it again after any later edit to
the title or body.

**If this PR resolves a GitHub issue, its body must include `Closes #N`** so GitHub
closes the issue automatically on merge, with no separate manual close step.
`Refs #N` only links an issue and never closes it, so don't use it on a PR that
resolves one. A PR for informal work with no tracking issue (a small doc fix,
a workflow correction) has nothing to close; don't invent a `Closes #N` for one.
**A sub-agent's PR into a parallel batch's integration branch should *not* claim
`Closes #N`** — merging it would close the issue while its work is still only on the
integration branch, before the batch's final PR lands. Put every closing reference for
the batch's issues in the final integration-branch PR instead (see "Reviewing and
merging" below).

**Every PR against `main` must say in its body that it is to be squash-merged**, and
must actually be merged with `--squash` — state this in the PR body at creation time,
not as an afterthought later. `main`'s history is one commit per PR regardless of how
many commits the branch accumulated.

**Exception: a sub-agent's PR opened against a parallel batch's integration branch
doesn't need the squash-body-note** — that rule is about PRs against `main`, and this
one isn't. Don't carry the squash-body-note habit over to a sub-agent PR opened
against an integration branch; say nothing about squashing in that PR's body. (It is
still merged with `--squash`, same as any other PR — see "Reviewing and merging"
below for why — but that's a fact about the merge command, not something the PR body
itself needs to state.)

**If this PR targets `main` and touches a skill's `SKILL.md` or
`resources/`, a required CI check (`plugin-version-check`) will fail the PR
if `.claude-plugin/plugin.json`'s `version` wasn't bumped** — bump it before
opening, per `documentation-sync`, rather than finding out from a red check.

An open PR is a checkpoint: don't merge it, push more work past it silently, or start
the next issue until the user has reviewed it. A parallel batch's sibling branches
are the exception, since they don't block each other.

## Verify after opening

Right after opening the PR, and again after every push to it, do this in order.

**1. Check for conflicts first.** A PR that conflicts with its base never gets a merge
commit for CI to build, so its checks never start, and `gh pr checks --watch` then
waits forever.

```bash
gh pr view <PR> --json mergeable,mergeStateStatus
```

- `mergeable: CONFLICTING` (or `mergeStateStatus: DIRTY`) means conflicts. Fix them
  before anything else. In the branch's worktree, `git fetch origin`, then
  `git merge origin/<base>` (the PR's base branch), resolve the files, run the
  project's tests, commit, and push. Don't rebase a branch that is already pushed, since
  that needs a force-push (`git-safety`). If resolving a conflict means choosing between
  two behaviors, stop and ask the user. Then run this check again.
- `mergeable: UNKNOWN` means GitHub is still working it out, usually right after a push.
  Wait a few seconds and ask again until it answers.
- `mergeStateStatus: BLOCKED` or `BEHIND` is not a conflict. `BLOCKED` is usually a
  required check or review still outstanding, which is what the watch is for.

**2. Then watch the checks.** Only once there are no conflicts:

```bash
gh pr checks <PR> --watch
```

It blocks until every check finishes. Report the result the same way each time: one
line per check as `name: pass|fail`, a link for each failure, then a verdict (all green,
or N failing). Run it as a background command and wait for it to exit rather than
polling.

On a failure, find out why: `gh run view --log-failed`, and for a SonarCloud quality
gate, the PR's open issues. Fix it, push, and start again from step 1. After 3 fix attempts
on the same failure, stop and give the user the cause, what was tried, and the options.

## Merging — the one absolute rule

**Merging a PR into `main` is always the user's call, never an agent's.** No
exception exists for any agent, sub-agent, or fork.

Enforce this technically, not just by documenting it: deny the raw `gh pr merge`
command in your agent harness's permission config, so the only way to merge a PR at
all is:

```bash
resources/scripts/gh_merge_guard.sh <pr-number-or-url> [gh pr merge flags]
```

Copy `resources/scripts/gh_merge_guard.sh` into this repo (e.g. `scripts/`) and wire
it into your permission config's deny rule for `gh pr merge`. The wrapper looks up
the PR's actual base branch via the GitHub API and refuses (exit 1, no merge
attempted) if that base is `main` or `development`. Never try to route around it —
raw `gh api` PR-merge calls, editing the permission config, etc. If work genuinely
seems to need a `main` merge, that's the point to stop and ask the user, not to find another path
to the same merge.

The **only** merge an agent may ever perform unattended is a parallel-batch
sub-agent's PR into that batch's *integration branch* — never into `main`. See
below.

**`main` itself is never deleted, by anyone, under any circumstance.** Not the
orchestrator, not a sub-agent, not as cleanup, not because a branch merge left it
looking redundant. If a git command you're about to run would delete, force-push
over, or otherwise remove `main` (locally or on `origin`), stop — that is never a
correct step in any workflow this repo has, no matter how the situation got there.

After a PR merges into `main`: confirm the merge actually happened — `gh pr view
<pr-number> --json state,mergedAt` (or equivalent) showing `state: MERGED`, not just
"I opened it and moved on" — then sync `main` and delete the branch **both
locally and on the remote**. A worktree that still holds the branch checked out
blocks deleting it, so remove the worktree first (every working branch is one, per
`git-branching`'s `resources/worktree-workflow.md`):

```bash
git worktree remove <dir>/<branch-slug>   # first; --force only after checking git status shows no real content
git -C <primary-checkout> pull            # the primary checkout stays on main
git branch -d <branch>                    # local; -D only if you're certain it's safe
git push origin --delete <branch>         # remote
```

Then validate the deletion actually took, on both sides — don't assume the commands
succeeded silently:

```bash
git branch --list <branch>            # expect no output
git ls-remote --exit-code --heads origin <branch>   # expect a non-zero exit (not found)
git worktree prune && git worktree list             # only worktrees still in use remain
```

A merged PR closes out that issue (via `Closes #N`, above) — it does not authorize
starting the next one. Wait for the user to say to proceed.

## Reviewing and merging a parallel-batch sub-agent's PR into the integration branch

This checklist is the parallel-batch-specific instance of a general rule stated in
`github-issue-workflow`'s "Closing out an issue" section: never relay a delegate's
self-report as verified fact without having verified it yourself. Keep the two in
sync if either one changes.

This is the one merge an agent (the batch orchestrator) may perform without the user
— because the wrapper's base-branch check makes it structurally impossible for this
path to reach `main`.

That authority belongs to the orchestrator itself, exercised directly — it is never
delegated further. Don't spawn a sub-agent (a `fork` especially) with a prompt like
"review this PR and merge it if it looks good": that hands a decision only the
orchestrator should make to an agent whose action you haven't seen yet. Review and
merge as two things the orchestrator does itself, in sequence — a sub-agent may be
asked to report a verdict, never to act on one.

```bash
resources/scripts/gh_merge_guard.sh <pr-number> --squash
```

Use `--squash` here, not `--merge`, even though the integration branch isn't
`main` and this merge isn't what the squash-body-note rule above is about. The
reason is a side effect, not a history-cleanliness preference: `gh pr merge`
updates the account's remembered `viewerDefaultMergeMethod` for this repo to
whichever method was just used via the API. A batch's own final integration→`main`
PR is opened immediately after this merge, so if this call used `--merge`, that
PR's merge-method dropdown would silently default to "Merge pull request" instead
of "Squash and merge" — purely because of this unrelated prior call, not anything
about that PR itself. Using `--squash` here keeps the remembered default at
`SQUASH`, which is what's needed anyway, so it never flips away in the first place.

Don't "simplify" this back to `--merge` — the sub-agent's individual commits now
collapse into a single commit on the integration branch instead of being
preserved separately. That's not a regression in `main`'s eventual history: the
integration branch's own final PR into `main` already squashes everything into
one commit regardless of whether the intermediate merges were plain-merge or
squash. The only visible difference is that the integration branch's own interim
history (while the batch is still in progress) shows one commit per sub-agent PR
instead of each of that sub-agent's original commits — arguably cleaner, not
worse.

"Review" here is not optional and not a formality. Before merging a sub-agent's PR,
the orchestrator must itself confirm the following — not trust the sub-agent's
self-report:

- Re-run that issue's Validation section commands against the PR's actual branch
  state, not just trust that they passed in the sub-agent's own environment.
- Confirm any claims the sub-agent made about external verification (a live-source
  check, a data re-derivation, anything that can't be re-checked purely by reading
  the diff) were genuinely done, not skipped or copied from a prior check.
- Spot-check the change against this repo's own content/code-quality rules — its
  equivalent of a `content-authoring`- or `code-review`-style skill, if one exists.
- Confirm the PR stayed scoped to that issue's own files (no edits to shared
  docs like `CHANGELOG.md`, CLAUDE.md, `.claude-plugin/plugin.json`, or
  another issue's own files). `plugin.json`'s version bump in particular
  belongs only to the orchestrator's own consolidation pass before the
  batch's final PR to `main` — see `documentation-sync`'s "editing a skill in
  this repo" special case.

**If a problem is found, don't merge.** Launch a sub-agent to fix that specific
problem on the same branch, then repeat the review before merging. Never merge a
PR with a known problem "to fix later."

**Cap a sub-agent's PR at two fix rounds.** Fix round 1: initial review finds a
problem, a sub-agent fixes it, a re-review checks the fix. Fix round 2: if that
re-review still finds a problem — including a *new* problem the round-1 fix itself
introduced, not just a leftover one — one more sub-agent fix and one more re-review
are still routine. If the round-2 re-review *also* still finds a problem, stop
delegating further fix rounds.

At that point the orchestrator has exactly two options, and merging with a known
problem is never one of them unless the option below's carve-out applies:

- Fix the specific remaining problem itself, directly, with a few targeted edits —
  this is the one narrow exception to an authoring-skill's sub-agent-authors /
  orchestrator-reviews split, permitted only for a problem already fully diagnosed
  by two prior review rounds. The orchestrator must still follow the repo's own
  content/code rules for the edit and re-run its validation commands afterward,
  same as any other change before merge.
- Merge anyway, but only if the remaining problem is genuinely non-blocking —
  meaning it does not touch correctness, compliance, or anything a downstream
  consumer relies on. A finding that's merely *cosmetic* or *already present in
  pre-existing content this PR didn't touch* can qualify; a correctness or
  compliance defect never does, no matter how many rounds have run. Record what
  was found and why it was judged non-blocking as a comment on that issue's own
  GitHub issue thread.

This cap exists because a mechanical fix for one flagged problem can mechanically
introduce a different one. Without a cap, each fix round risks trading one
detectable problem for another rather than converging — two rounds is enough to
catch a real regression without either looping indefinitely or writing off a real
defect as "the cap made me do it."

Once the batch's sub-agent PRs are merged into the integration branch, the
orchestrator does a single consolidation pass there — any shared docs this repo
maintains (e.g. `CHANGELOG.md`'s `[Unreleased]` section), referencing every issue in
the round — committed directly on the integration branch. Then it opens one final PR
from the integration branch to `main`, **with a `Closes #N` for every issue in the
round** — this is the only PR in the whole batch that carries them, so the issues
close when the batch's work reaches its base branch, not before. **Only the user
merges this PR**, under any circumstances, regardless of how clean the
orchestrator's own review of the batch was.

A sub-agent's PR that needs more work can keep iterating against the integration
branch without blocking or being blocked by sibling PRs.

## Cleaning up after a parallel batch

Once the final integration-branch → `main` PR is confirmed merged (per the check
above), a batch leaves **multiple** branches to clean up, not one: the integration
branch itself, plus every sub-agent branch merged into it. Both local and remote
copies of all of them need deleting, exactly as in the single-branch case above —
but two things are different here and worth expecting rather than treating as a
problem:

- **Every sub-agent branch will fail `git branch -d` with "not fully merged."** This
  is expected, not a sign something went wrong: the integration branch was
  *squash*-merged into `main`, so `main` doesn't contain the sub-agent branches'
  original commits as direct ancestors even though their content is fully in `main`
  (verify that first — diff or content-check — rather than assuming). Use
  `git branch -D` for these once verified; don't chase the warning as a real problem.
- **A sub-agent branch may still be checked out in its own worktree** if that
  sub-agent ran with worktree isolation — `git branch -D` fails outright until the
  worktree is removed first: `git worktree remove <path>`, or `--force` if `git
  status` in that worktree shows nothing but lockfile/build-artifact noise (check
  first, same as any uncommitted-work check — don't force past real content).
- **Removing the worktree leaves a second, separate branch behind**: the harness
  creates its own `worktree-agent-<id>` branch for each isolated sub-agent (distinct
  from the `issue/*` branch you asked it to create inside that worktree), and
  `git worktree remove` does not delete it. Check `git branch --list
  'worktree-agent-*'` after clearing the batch's sub-agent branches — a branch left
  with zero commits ahead of `main` (`git log main..worktree-agent-<id> --oneline`)
  is pure harness bookkeeping with no unique content and safe to `git branch -d`.
  These are local-only; the harness doesn't push them, so there's no remote copy to
  clean up for this one.

Delete the integration branch itself the same way as any other merged branch (it
*is* fully merged locally, since it's what `main` was fast-forwarded from — a plain
`-d` works there). Verify every deletion, local and remote, per the commands above —
this applies per-branch, not just once for the batch.

## Releases

Cutting an actual release — CHANGELOG/SemVer policy, build/test verification,
version-bump mechanics, artifact publishing, and the git tag + GitHub
Release — is covered by the `github-release` skill, not this one. Load it
once a PR bringing `main` to a releasable state is about to merge or has just
merged.
