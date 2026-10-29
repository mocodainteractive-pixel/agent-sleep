# OpenCode adapter

OpenCode runs any model and reads AGENTS.md — the two facts that make it a
good sleep host. The clock is external: plugin events if you want in-app
triggering, cron + headless otherwise.

## Memory directory

`.agent/memory/` per project, same as the Claude Code adapter. AGENTS.md is
the charter and stays out of every write path.

## Triggers

**Headless runs (any trigger).** OpenCode's non-interactive mode drives all
four offline phases:

    opencode run "$(cat /path/to/agent-sleep/templates/prompts/consolidate.md)"

**Consolidate (session end).** Two options, pick one:
- a small plugin listening for session end that shells the headless run
  above (backgrounded), or
- simplest: an explicit end-of-session slash command you (or the agent as
  its last act) invoke that runs the same headless command.

**Check (daily).** Plain cron; scripts-only, so on healthy days cron calls
`scripts/*.sh` directly and no model burns at all. Model runs happen when
something fails and the check prompt needs interpreting.

**Reconcile / prestudy.** Headless runs triggered by the promotion counter
or an idle schedule, same as the other adapters.

## Model note

Token-space memory pays off most on a model-agnostic host: the memory you
build survives every provider swap. Run consolidation on the strongest
model you have access to and the daily check on whatever is cheapest — the
two jobs have opposite quality sensitivity.
