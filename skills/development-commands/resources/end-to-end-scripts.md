# End-to-end check scripts

A project that has more than unit tests usually keeps a few shell scripts that start the
real thing and check it. This file describes the pattern, so you can run the project's
scripts, read them, or write a new one. Script names and flags are the project's. Run
each with `--help` first.

## The shape every one of them has

- A `--help` flag that says what it starts, what it asserts, and what its exit codes mean
  (0 all passed, 1 a check failed, 2 a setup error).
- A **throwaway server** on a free port with a temporary database (`throwaway-server.md`).
- A **`trap` on exit** that kills every process it started, escalates to `kill -9`, checks
  nothing is left running, and deletes the temp directory. A `--keep` flag skips the
  delete so you can read the logs after a failure.
- Plain `ok` and `FAIL` lines, one per check, and a final summary.

## Smoke check

Runs the server plus a traffic simulator for about 20 seconds and asserts that:

- the state endpoint lists live clients while the simulator runs;
- the event stream yields a `snapshot` first, then the update events (for example
  `session` and `tick`);
- the same stream works **through the front end's dev proxy** without buffering. Stamp
  each line with the time it arrives: a buffering proxy delivers everything at the end,
  so the arrival times are bunched instead of spread out.

Typical flags: `--no-vite` (skip the proxy check), `--keep`. Run it with the project's
npm script, which wraps the shell script.

## Soak and restart check

Opens N event-stream clients and runs the simulator for minutes. It prints the server's
resident memory over time and how many messages each client got in its first 30 seconds
and its last 30 seconds. A client that gets none at the end has been starved. A
`--restart` flag kills the server with `SIGKILL` partway through and starts it again on
the same database, then checks that clients come back as stale and then recover.

Memory is the server process's, not the wrapper's: when the server runs through `tsx` or
a shell, find the PID that is listening on the port
(`lsof -nP -tiTCP:<port> -sTCP:LISTEN`) and read its RSS with `ps -o rss= -p <pid>`.

## Browser cost check

Starts the throwaway server and simulator, opens the page in headless Chrome using
`ui-screenshots.md`'s script with `--eval`, watches for N seconds, and prints JSON:
DOM node count, JS heap at start and end, long tasks (over 50 ms) and their total, and
frames drawn per second. The `--eval` code observes `longtask` entries with a
`PerformanceObserver` and counts `requestAnimationFrame` callbacks. Needs a built
front end. For GPU load see `host-sampling.md`.

## An end-to-end run with real Claude Code sessions

When the thing under test is how real sessions behave, a script can start several, one
tmux window each, each in its own git worktree, against the throwaway server. This
**costs model usage**, so say so to the user before running it, and use the smallest
model that shows the behavior.

- Needs `node`, `curl`, `git`, `tmux` and `claude` on `PATH`.
- It has an `up` and a `down` command. `down` must remove only what `up` made.
- Attach with `tmux attach -t <name>`. Each new folder asks once whether to trust it,
  so accept it in every window before sending a prompt.
- To type a prompt into a window, send the text, pause, then send Enter on its own. A
  long prompt sent with its Enter in one `send-keys` is often left unsubmitted:

  ```bash
  tmux send-keys -t <name>:<window> -l '<text>'
  sleep 1; tmux send-keys -t <name>:<window> C-m
  ```

- Run `down` when you finish. Check `tmux ls` shows the session gone.
