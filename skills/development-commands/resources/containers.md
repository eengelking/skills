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
