# Containers: podman/docker compose

```bash
podman compose up          # or `docker compose up` — builds + serves per the repo's compose file
```

**A plain `up` (or even `up --build`) after a code change can silently serve
stale code.** Against an image that was already built, `up` alone reuses it
without rebuilding. `up --build` on its own isn't enough either, against an
*already-running* container: compose can rebuild and retag the image without
recreating the container, so the running container keeps serving the old
image with no error. This has caused real crash loops (e.g. a schema change
landing without a rebuild taking effect).

Whenever code under the image's build context has changed (application code,
dependency manifests, Dockerfile/Containerfile, migrations), use one of:

```bash
podman compose down && podman compose up --build -d
podman compose up --build -d --force-recreate
```

If the container comes up but the app doesn't seem to reflect a recent
change, check this before debugging further — see if this repo's own docs
have a specific "container is up but stale" troubleshooting entry.

## Building an image by hand

A project without compose builds from its `Containerfile` (or `Dockerfile`):

```bash
podman build -t localhost/<name>:latest -f Containerfile .    # or: docker build ...
podman exec -it <container> /bin/sh                           # a shell in the running container
```

The stale-code warning above applies here too: building a new image does not replace a
container that is already running the old one. Stop and remove the container, then
start it from the new image.

### A two-stage Containerfile for a Node app

What a good one looks like, so you can tell when a project's has drifted:

- A **build stage** copies the manifests and lockfile first, runs `npm ci
  --ignore-scripts`, then copies the source and builds. Copying manifests before source
  means a source-only change reuses the cached install layer.
- A **run stage** starts from the same slim base, copies the manifests again, runs
  `npm ci --ignore-scripts --omit=dev`, and copies only the built output from the build
  stage. Nothing from the source tree or the dev dependencies ships.
- It ends with a non-root `USER`, a `VOLUME` for the data directory (owned by that
  user), `EXPOSE` for the ports, and a `CMD`.
- A build `ARG` that records the commit (and the `ENV` made from it) comes **last**, so
  a new commit invalidates only that one layer.
- A slim base image does not carry `openssl`. If the app shells out to it, install it
  in the run stage with `apt-get install -y --no-install-recommends openssl` and clear
  the apt lists in the same `RUN`.

## A project's own CLI wrapper

Some projects ship a wrapper command for their container (a script on `PATH` or in
`bin/`). When one exists, use it instead of raw `podman` commands, because it holds the
project's flags, volume names and ports. Run its `--help` to see the verbs. Typical
ones:

| Verb | What it does |
|---|---|
| `build` | Build the image |
| `start`, `stop`, `restart` | Run, stop, or stop and run again |
| `status`, `health`, `url` | Show state, check it answers, print its address |
| `logs` | Print the log; `-f` follows, `--tail N` shows the last N lines |
| `token` | Print the admin secret; `--rotate` makes a new one |
| `config`, `config set K=V`, `config unset K` | Show or change settings |
| `enable`, `disable` | Start or stop starting on boot |
| `run` | Run in the foreground |
| `shell` | A shell in the container |
| `rm` | Remove the container (a flag to also purge data needs `--yes`) |

- **Restart after a config change.** Settings are read at start, so `config set` does
  nothing to a running server until `restart`.
- The stale-code warning above applies to the wrapper's `build` and `restart` as well. If
  the app does not show your change, rebuild, then recreate the container.
