# A two-stage Containerfile for a Node app

What a good one looks like, so you can tell when a project's has drifted. It works with
any engine in `../containers.md`.

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
- In a workspace repo, copy every workspace's `package.json` before `npm ci`, or the
  install does not see the workspaces (`npm.md`).
