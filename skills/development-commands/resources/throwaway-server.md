# A throwaway server for checks and UI review

When you need a running server to test against or to look at, start your own on a
free port with its own temporary database. Never use the server the user works with,
and never seed demo data into the project's real database. `database-seeding.md` covers
filling it with data.

## Start it

Build first, then start the built output with environment variables. The names are the
project's; read them from its docs. The shape is:

```bash
npm run build
PORT=<free-port> DB_PATH=<temp-dir>/app.sqlite TOKEN=<random> node server/dist/index.js
```

- **A free port.** Don't hard-code one that might be taken. Let the OS pick:

  ```bash
  node -e "const s=require('net').createServer().listen(0,'127.0.0.1',()=>{console.log(s.address().port);s.close()})"
  ```

- **A temporary database** in a directory made with `mktemp -d`, so it can be deleted
  with one command. A random `TOKEN` from `node -e "console.log(require('crypto').randomBytes(24).toString('hex'))"`.
- **Bind to `127.0.0.1`** unless you mean to expose it.
- Wait for the server to answer a health endpoint before using it, instead of sleeping:

  ```bash
  for _ in $(seq 1 60); do curl -sf "http://127.0.0.1:$PORT/<health-path>" >/dev/null && break; sleep 0.25; done
  ```

## Use it

Seed it (see `database-seeding.md`), point a browser or `ui-screenshots.md` at it, or
run the project's end-to-end scripts (`end-to-end-scripts.md`).

### A traffic simulator for a live view

An app that shows live activity looks empty without any. If the project ships a traffic
simulator, run it against the throwaway server in a second terminal to get a live
fleet of fake clients without real ones:

```bash
npm run <simulator-script> -- --url "http://127.0.0.1:$PORT" --sessions 5 --chaos
```

Flags differ by project; read `--help`. A `--chaos` style flag makes it fail and
recover on purpose, which is what you want when checking error states.

## Stop it

Stop everything you started, then confirm it is gone:

```bash
kill <server-pid>
lsof -nP -iTCP:"$PORT" -sTCP:LISTEN     # expect no output
rm -rf <temp-dir>
```

Put the PIDs in an array and kill them in a `trap ... EXIT` handler, so a failed run
still cleans up. If you changed the server's code, restart it before treating its
behavior as evidence.
