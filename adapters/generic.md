# Generic adapter — cron + any headless agent CLI

Everything except the session-end hook degrades gracefully to cron, and the
session-end hook degrades to "the agent queues its own consolidation as its
last act of the session." That covers Gemini CLI, Codex CLI, Aider, Goose,
Cline, and anything else with a non-interactive mode.

## The three cron entries

    # daily check — scripts only, no model
    15 9 * * *  /path/to/agent-sleep/scripts/verify-memory.sh "$AGENT_SLEEP_MEMORY" >> /var/log/agent-sleep.log 2>&1

    # reconcile — weekly sweep; move to on-trigger when you add a counter
    0 10 * * 0  <agent-cli> -p "$(cat /path/to/agent-sleep/templates/prompts/reconcile.md)"

    # prestudy — early morning, before the workday starts sessions
    30 7 * * *  <agent-cli> -p "$(cat /path/to/agent-sleep/templates/prompts/prestudy.md)"

`<agent-cli>` is your tool's headless form: `gemini -p`, `codex exec`,
`aider --message`, `goose run`, and so on. `AGENT_SLEEP_MEMORY` points at
the memory directory.

## Consolidate without a hook

At the end of a session, the last thing the interactive agent does is hand
off its own consolidation:

    <agent-cli> -p "$(cat .../consolidate.md)" &

If your tool logs sessions to a file (most do), the consolidate prompt's
"read the raw transcript" step reads that file; otherwise keep a running
`session-notes.md` scratch file the agent appends to during the session,
and treat THAT as the raw source. Never let the scratch file itself be
promoted to memory — it is an input, not an artifact.

## Goose note

Goose has a built-in scheduler: run the three entries as goose crons with
the same prompts and skip system cron entirely.

## Charter

Whatever your tool loads each run (AGENTS.md, a system prompt file, rules
file) is the charter. Keep it out of the memory directory and out of the
sleep run's write scope — instructed fence on generic platforms, so the
prompt's prohibition is doing the work; honor it.
