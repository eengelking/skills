# Build/test verification: compiled languages (Go, Rust, ...)

Applies to any language where "it builds" is a real, separate assertion from
"the tests pass" — the compiler can reject code the tests never exercise.

## Sequence

1. **Build first, before running tests.** A compile failure is a different,
   cheaper-to-diagnose signal than a test failure — don't let a broken build
   masquerade as a failing test.
   - Go: `go build ./...`
   - Rust: `cargo build --all-targets`
2. **Then run the full test suite**, not just the packages this change
   touched — a change in one package can break another's assumptions.
   - Go: `go test ./...`
   - Rust: `cargo test --all`
3. **Run this repo's linter/vet step if it has one** (`go vet`, `clippy`,
   etc.) — treat a lint failure the same as a build failure for release
   purposes if this repo's own testing/CI conventions do.

A red build or red test is treated exactly like any other CI failure: never
push past it, and don't proceed to the version-bump or publish steps until
it's resolved.

## Cross-compilation, if this repo ships binaries for multiple platforms

If step 3 (publish) will produce binaries for more than one OS/arch, verify
the build for *each* target this repo publishes, not just the host platform —
a target-specific compile error won't show up building for the host alone.
