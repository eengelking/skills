# Static analysis before the PR

Run the project's analyzer on the files you changed before opening a PR, so a fix does
not start a loop with the quality gate in CI. The SonarQube CLI is the example below;
if the project uses another analyzer, the same rules apply.

If the `sonarqube` plugin is installed, its `sonar-analyze` skill runs the analysis
for you. The notes here cover what the plugin does not tell you.

## Run it

```bash
sonar analyze --file <path> [--file <path> ...] 2>&1 | tail -40
```

- It always runs the secrets scan.
- The code analysis can come back `[SKIPPED]`, with a message such as "Vortex analysis
  is not available on this connection". That is not a clean result. Say in your report
  and in the PR that the analysis was skipped, and don't call the files clean.

## Coverage is not measured by the run

A quality gate usually requires a coverage figure on new lines (80% is common), and
`sonar analyze` does not measure it. So for every line you add or edit, write a test
that reaches it, or leave the line alone. A change with many untested log or error
branches can fail the gate badly on a first push.

Code that can only run inside a host runtime (a plugin loaded by an app, a function
only the host calls) counts as uncovered, because the project's test run cannot reach
it. Keep that file to a few lines of glue. Put the logic in a plain module that takes
what it needs as arguments, and test that module with the project's normal runner.

## Rules that catch people (TypeScript)

Write the fix so it does not trip a rule of its own:

- `typescript:S6324`: no control characters in a regex literal.
- Use `replaceAll` instead of `replace` with a global regex.
- Use `Number.parseInt` and `Number.NaN` instead of the globals.
- `typescript:S4036`: don't run a binary by bare name from `PATH`. Give its full path,
  or resolve it first.

## The project's analyzer config

A `sonar-project.properties` file at the repo root controls what the analysis sees:

- `sonar.exclusions` leaves files out. A huge generated tree, or a bootstrap entry file
  that only starts the app, is excluded because it would drag coverage down without
  anything to test.
- `sonar.test.inclusions` (and related keys) tells the analyzer which files are tests, so
  test code is not scored as production code.

Read the file before assuming a path is analyzed, and update it when you add a tree of
generated files or a new test layout.

## CodeQL

CodeQL (for example the `security-extended` query set) usually runs only in CI. It
does not run on your machine. Its results appear in the repo's Security tab, under Code
scanning. Fix what it flags in the same PR.
