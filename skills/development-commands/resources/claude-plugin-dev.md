# Developing a Claude Code plugin

For a repo that contains a Claude Code plugin (a `.claude-plugin/plugin.json`, with
skills, hooks or a mod). The plugin's own folder and test scripts are named in the
project's docs.

## Try it in a real session

```bash
claude --plugin-dir <checkout>/<plugin-folder>
```

This loads the plugin from your working copy for that session only, so you see your
change without installing anything. Use it to exercise the change for real, as well as
running the tests.

## Run its tests

```bash
claude plugin test <plugin-dir>
```

This needs Claude Code installed, so CI runners usually cannot run it. Run it locally
before the PR, and report the result in the PR body. Don't let a green CI run stand in
for it.

If it fails, compare against a clean copy of the base branch (or the last release tag)
before deciding whether the failure is yours. A failure that is not new still goes to
the maintainer as an issue. Don't carry it silently into a release.

## Type-check against the host's declarations

A plugin that uses Claude Code's plugin API can be type-checked against the host's
declaration file, `claude-code.d.ts`. There is no command that makes it. The engine
writes it in two situations:

- while an interactive session has loaded the plugin from a folder it watches, it fills
  the plugin's own `.claude-plugin/types/` folder, and `tsc -p <plugin>` then works as is;
- whenever the `plugin-authoring` skill loads, it writes a copy under a temp folder
  that belongs to that process. After a restart, the next load writes a new one.

To check by hand:

1. **Find the newest copy.** `find -H` follows `/tmp`, which is a symlink on macOS (a
   plain `find /tmp` returns nothing there):

   ```bash
   find -H "${TMPDIR:-/tmp}" /tmp -path '*plugin-authoring/types/claude-code.d.ts' -exec ls -t {} + 2>/dev/null | head -1
   ```

2. **If that prints nothing, load the `plugin-authoring` skill, then run step 1 again.**
   In an interactive Claude Code session, type `/plugin-authoring`; an agent can load
   it with the Skill tool. The skill names the file's path when it loads. Older copies
   from earlier Claude Code versions may also be on disk, which is why step 1 takes the
   newest.
3. Copy the file to the plugin's git-ignored `.claude-plugin/types/` folder (the
   project's tsconfig says the exact name, such as
   `.claude-plugin/types/claude-code/index.d.ts`).
4. Run `tsc -p <plugin>/tsconfig.json`.

**If you still cannot find the declaration file, say so. Never report the check as
passing.** A type-check that did not run is not a pass.

## Keep host-only code thin

Code that only runs inside Claude Code (a hook module the host loads) is invisible to a
normal coverage run and to CI. Keep that file to a few lines of glue. Put the logic in a
plain module that takes what it needs as arguments, and test that module with the
project's normal test runner. See `static-analysis.md`.
