# Seeding a throwaway database for UI work

A dashboard-style app is often blank without real-looking data — empty
states everywhere, nothing to review visually. Rather than seeding demo data
into the repo's real/default database file, point the app at a throwaway one
so the real database stays empty and untouched:

```bash
export DATABASE_URL="<driver>:///<path-to-throwaway-db>"   # e.g. sqlite:////tmp/myapp-demo.db
<migration tool> upgrade head                                # e.g. alembic, or this repo's equivalent
python -m <this repo's content/fixture loader>, if it has one
python -m <this repo's demo-seed script>, if it has one
<run the app>
```

Two things worth checking before assuming a seed script "just works":

- **Idempotency** — can it be re-run against the same throwaway DB, or does
  it need a fresh file each time? Check the script itself or this repo's
  docs rather than guessing.
- **Coverage of states** — a good seed script deliberately varies its data
  (e.g. splitting records across "fully reviewed" / "partially reviewed" /
  "untouched" buckets, or however this domain's states break down) so every
  UI state shows up somewhere, not just the happy path.

If you're hand-writing seed data instead of using a script, check the
schema for `CHECK` constraints or enum-like columns first — a value that
looks plausible but isn't in the allowed set will fail the insert, and it's
easy to get wrong without checking the schema/migration that defines it.

See `resources/example-readyband.md` for one project's concrete instance of
this pattern — not a template to copy verbatim into a different project.
