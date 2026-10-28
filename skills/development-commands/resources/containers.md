# Containers: Podman, Docker, nerdctl

A project runs on one container engine, and the commands are nearly the same across
them. Use the one the project's docs name, or the one installed. Below, `<engine>` is
`podman`, `docker`, or `nerdctl` (the Docker-compatible CLI for containerd).

| | Podman | Docker | nerdctl (containerd) |
|---|---|---|---|
| Compose | `podman compose` | `docker compose` | `nerdctl compose` |
| Build an image | `podman build` | `docker build` | `nerdctl build` |
| Run, list, stop | `podman run`, `ps`, `stop` | `docker run`, `ps`, `stop` | `nerdctl run`, `ps`, `stop` |
| Shell in a container | `podman exec -it <c> /bin/sh` | `docker exec -it <c> /bin/sh` | `nerdctl exec -it <c> /bin/sh` |
| Build file | `Containerfile` or `Dockerfile` | `Dockerfile` (reads `Containerfile` with `-f`) | `Dockerfile` (reads `Containerfile` with `-f`) |
| Daemon | none (rootless by default) | `dockerd` | `containerd`, plus BuildKit for `build` |

Things that differ in practice:

- **nerdctl needs containerd running, and BuildKit for `nerdctl build`.** Without
  BuildKit, `build` fails even though `run` works.
- **nerdctl uses containerd namespaces.** Images built in one namespace are invisible in
  another. Add `--namespace <name>` (for example `k8s.io` for images a local Kubernetes
  uses) if an image you just built is not found.
- **Podman tags local images `localhost/<name>`.** Docker and nerdctl use plain
  `<name>`. Use the full name the engine prints, and don't hard-code the prefix in a
  script that must run on more than one engine.
- A project's compose file or wrapper script may only support one engine. Check its docs
  before swapping engines.

## Running via compose

```bash
<engine> compose up          # builds and serves per the repo's compose file
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
<engine> compose down && <engine> compose up --build -d
<engine> compose up --build -d --force-recreate
```

If the container comes up but the app doesn't seem to reflect a recent
change, check this before debugging further. See if this repo's own docs
have a specific "container is up but stale" troubleshooting entry.

## Building an image by hand

A project without compose builds from its `Containerfile` or `Dockerfile`:

```bash
<engine> build -t <name>:latest -f Containerfile .
<engine> run --rm -p <host-port>:<container-port> <name>:latest
<engine> exec -it <container> /bin/sh        # a shell in a running container
```

The stale-code warning above applies here too: building a new image does not replace a
container that is already running the old one. Stop and remove the container, then
start it from the new image. For what a good Containerfile for a Node app looks like,
see `node/containerfile.md`.

## A project's own CLI wrapper

Some projects ship a wrapper command for their container (a script on `PATH` or in
`bin/`). When one exists, use it instead of raw `<engine>` commands, because it holds the
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
