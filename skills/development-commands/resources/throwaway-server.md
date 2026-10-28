# A throwaway server for checks and UI review

When you need a running server to test against or to look at, start your own on a
free port with its own temporary data. Never use the server the user works with, and
never seed demo data into the project's real data store. `database-seeding.md` covers
filling it with data. This file is about the pattern, which holds for any language and
any data store. The command that starts the server comes from the project's docs and,
for a given tool, from that tool's folder (for example `node/testing-and-build.md`).

## Start it

Build first if the project builds, then start the built output with its settings
passed as environment variables or flags. The names are the project's. What you need to
set, whatever it calls them:

- **A free port.** Don't hard-code one that might be taken. Ask the OS for one, with
  whatever is installed:

  ```bash
  python3 -c "import socket; s=socket.socket(); s.bind(('127.0.0.1',0)); print(s.getsockname()[1]); s.close()"
  node -e "const s=require('net').createServer().listen(0,'127.0.0.1',()=>{console.log(s.address().port);s.close()})"
  ```

  Some servers accept port `0` and print the port they got. Use that if the project's does.
- **Its own temporary data.** Make a directory with `mktemp -d` (on Windows,
  `New-TemporaryFile` or `[System.IO.Path]::GetTempPath()`), and point the server's data
  setting at a path inside it, so one command removes everything. An embedded database
  is a file there. A server database (Postgres, MySQL) is a throwaway container or a
  database with a unique name that you drop afterward.
- **A random credential**, if the server needs a token or password, generated for this
  run and never reused. `openssl rand -hex 24` works wherever OpenSSL is installed.
- **Loopback only.** Bind to `127.0.0.1` unless you mean to expose it.

Wait for the server to answer a health endpoint before you use it, instead of sleeping:

```bash
for _ in $(seq 1 60); do curl -sf "http://127.0.0.1:$PORT/<health-path>" >/dev/null && break; sleep 0.25; done
```

## Use it

Seed it (see `database-seeding.md`), point a browser or `ui-screenshots.md` at it, or
run the project's end-to-end scripts (`end-to-end-scripts.md`).

### A traffic simulator for a live view

An app that shows live activity looks empty without any. If the project ships a traffic
simulator, run it against the throwaway server in a second terminal to get a live
set of fake clients without real ones. Its flags differ by project; read `--help`.
A flag that makes it fail and recover on purpose (often called `chaos` or `faults`) is
what you want when checking error states.

## Stop it

Stop everything you started, then confirm it is gone:

```bash
kill <server-pid>
lsof -nP -iTCP:"$PORT" -sTCP:LISTEN     # expect no output (Linux: ss -ltnp "sport = :$PORT")
rm -rf <temp-dir>
```

On Windows, use `Stop-Process -Id <pid>` and
`Get-NetTCPConnection -LocalPort $PORT -ErrorAction SilentlyContinue` (expect nothing).

Put the PIDs in an array and kill them in a `trap ... EXIT` handler, so a failed run
still cleans up. If you changed the server's code, restart it before treating its
behavior as evidence.
