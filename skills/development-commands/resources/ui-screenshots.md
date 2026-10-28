# Checking a UI at a set width

To see a built page at a narrow and a wide width, use `scripts/page-shot.mjs` in this
resource folder. It starts headless Chrome with a throwaway profile, loads a URL at a
width, waits, optionally runs JavaScript in the page and prints the JSON result, saves a
full-page PNG, and stops Chrome and deletes the profile.

Needs Chrome or Chromium and Node 22 or later (the script uses the built-in
`WebSocket`).

## Get the script

Run it from where it lives, or copy it into the project (a `scripts/` folder is the
usual place) if the project wants to keep it. It has no dependencies. If the project
already has its own copy, use that one.

```bash
node page-shot.mjs --help
```

## Run it

Start a throwaway server first (`throwaway-server.md`), seed it, then:

```bash
node page-shot.mjs --url 'http://127.0.0.1:<port>/#/some-page' --width 400
node page-shot.mjs --url 'http://127.0.0.1:<port>/#/some-page' --width 1440
```

- Check **400 and 1440**: a phone-sized layout and a desktop one. Open each PNG and
  look at it. A screenshot nobody read verifies nothing.
- `--url` is required and has no default, on purpose, so it can never land on a server
  you use by accident.
- `--eval '<javascript>'` runs in the page once it settles, and its result is printed as
  JSON. Use it to open a panel before the shot, sign in with test values, or report
  where elements sit (`getBoundingClientRect`). A returned promise is awaited.
- **Set the theme** from `--eval` by writing the document's dataset, for example
  `document.documentElement.dataset.theme = 'dark'`. Use whatever attribute the app reads.
- `--wait <ms>` gives a page that draws late more time. `--height` and `--out` set the
  viewport height and the file.
- Stop the throwaway server when you are done.

## Why this and not the alternatives

- A browser extension's window resize may do nothing, so the page never gets narrower.
- An iframe at a narrow width is refused by many pages (`X-Frame-Options`, CSP
  `frame-ancestors`).
- `chrome --headless --screenshot` waits for the network to go idle. A page that keeps
  an event stream open (SSE or a WebSocket) never goes idle, so it never finishes. This
  script waits for the load event plus a fixed delay instead.
