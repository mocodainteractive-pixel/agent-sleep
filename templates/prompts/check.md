# Daily check — offline prompt (scripts only, no model judgment required)

The cheap, frequent half of the cycle. Everything here is read-only or a
stamp; nothing rewrites memory. Run daily via cron / scheduled task.

    scripts/verify-memory.sh <memory-dir>
    scripts/prune-ttl.sh <memory-dir>            # dry-run: list only
    scripts/run-fixtures.sh <fixtures-dir>

Interpret the results:

- **verify FAIL** — a source went stale (file moved, URL dead, command
  fails). The entry is now suspect. Fix the entry's source if the fact is
  still true and worth keeping; otherwise let it expire or prune it.
- **prune expired** — normal churn. Prune with `--apply` only alongside a
  reconcile run, not automatically.
- **fixture FAIL** — drift alarm. Something changed behavior that used to
  work. Run `scripts/rollback.sh <memory-dir> N` to the last-known-good,
  re-run fixtures to confirm, then investigate the cause before any new
  promotion.

If everything passes: one line in the run log is the whole report. Do not
generate summaries of healthy state — that is noise wearing a badge.
