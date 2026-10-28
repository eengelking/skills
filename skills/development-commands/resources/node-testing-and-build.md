# Node: testing, building and dev servers

Script names, ports and folders are the project's. Read them from its `PROJECT.md`,
`CLAUDE.md` or contributing doc, and use what is below as the shape of the commands.

## Tests

```bash
npm test                                          # root script, runs every workspace's tests
npm test -w <workspace-name>                      # one workspace
npx vitest run                                    # inside one package, without the root script
npx vitest run --coverage --testTimeout=20000     # the coverage run
```

- `vitest run` runs once and exits. `vitest` alone watches, which hangs a script.
- The coverage run is slower because of instrumentation, so give it a longer
  `--testTimeout`. It writes an `lcov` report under each workspace's coverage folder.
  That folder is generated output and belongs in `.gitignore`.
- **Fixing a bug in code: write the failing test first.** Run it and confirm it fails
  for the reason the bug report gives, then fix. A test only ever run against the fixed
  code does not show it would have caught the bug.

### Accessibility checks inside the unit run

A project can run `axe-core` over rendered pages in its unit tests. If it does:

- A new page, or a large new state, gets a case there.
- A violation that is known and tracked goes in the test's `KNOWN` list with the issue
  that tracks it, and comes out when it is fixed.
- axe in a unit-test DOM cannot judge color contrast or target size, because those
  need a real layout. When a change touches color or size, load `axe.min.js` into a
  real page (see `ui-screenshots.md` for driving one) and run it in each theme and mode.

## Builds

```bash
npx tsc -p tsconfig.json          # type-check or compile one package
npx tsc -b && npx vite build      # a project reference build, then the bundle
npm run build                     # root script, usually chains the workspace builds
                                  # and a type-check of any scripts folder
```

Run the root build before calling a change done. A passing unit test run does not prove
the project still builds.

## Dev servers

```bash
npx vite                          # front end with hot reload
npx tsx watch src/index.ts        # server, restarts on change
npm run dev                       # often runs both at once through `concurrently`
npx vite preview                  # serves an already-built front end, to check the build
```

- A dev server serves the code as of its last reload. After a change it does not
  pick up (a config file, an environment variable, a dependency), restart it.
- Stop every server you started when you finish. Check with `lsof -nP -iTCP -sTCP:LISTEN`
  that the port is free.
- To see the app with real-looking data, don't point a dev server at the project's real
  database. See `throwaway-server.md` and `database-seeding.md`.
