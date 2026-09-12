## What this changes and why

<!-- One or two sentences. Link the tracking issue if there is one. -->

## Checklist

- [ ] Targets the right base branch (`main` for standalone work, or the batch's
      integration branch for a parallel-batch sub-agent PR).
- [ ] If this PR targets `main` and touches a skill's `SKILL.md` or its
      `resources/`, the plugin `version` in `.claude-plugin/plugin.json` was
      bumped to match — CI (`plugin-version-check`) enforces this for any PR
      into `main`. A sub-agent's PR into a parallel batch's integration
      branch is exempt — that bump happens once, in the batch's final PR to
      `main`.
- [ ] Docs that describe this change are updated in the same PR (see the
      `documentation-sync` skill for what owns what).
- [ ] Tests and lint pass, where this repo has any to run (see the
      `development-commands` skill).
- [ ] If this PR targets `main`, the body says it's to be squash-merged, and
      it closes its tracking issue (`Closes #N`) if one exists. A sub-agent
      PR into a batch's integration branch skips both of these.

## Test plan

<!-- How you verified this, or why verification doesn't apply. -->
