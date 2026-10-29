# ZCode adapter

ZCode is the reference platform: it has the idle queue, scheduled jobs, and
hooks the sleep cycle wants natively.

## Memory directory

Use the project memory directory ZCode already maintains
(`~/.zcode/cli/memories/projects/<project>/memory/`). Its `MEMORY.md` is the
index this skill expects. Point all scripts at that path.

## Triggers

**Consolidate (session end → off-peak).** Queue an idle-time task when a
session wraps. The task prompt = `templates/prompts/consolidate.md` plus the
session id; the run continues the conversation unattended with full history.

- OffPeakCreate tool: title `consolidate: session <id>`, prompt = the
  consolidate template with `<session-id>` and `<memory-dir>` filled in.
- If no hook fires automatically, end-of-session consolidation can also be
  queued by the interactive agent itself as its last act — one tool call,
  then the session ends clean.

**Check (daily).** CronCreate with a daily expression (e.g. `15 9 * * *`),
prompt = `templates/prompts/check.md`. Scripts-only; runs fine at the
default model.

**Reconcile (on trigger).** Two sane triggers:
- after every N consolidations (track N in a one-line counter file in the
  memory dir; the check cron can read it and queue reconcile when it
  crosses the threshold), or
- immediately when a check run reports a contradiction or verify-FAIL on an
  entry whose source still exists.

**Prestudy (idle).** OffPeakCreate whenever the queue is quiet and the repo
moved today (`git log --since=midnight`). Prompt =
`templates/prompts/prestudy.md`.

## Charter fencing

ZCode permission modes are the one platform where the charter fence is
enforced, not just instructed: run sleep phases in a mode that cannot write
outside the memory directory, and keep `AGENTS.md` + skill files outside
that directory's write scope. Skill maturation edits happen in their own
runs, never inside consolidation.

## Fixture hosting

Keep per-skill fixtures in `<memory-dir>/fixtures/` so they version with
the memory that would break them.
