# Claude Code adapter

Same skill format, different clock: consolidation runs as a headless
`claude -p` invocation, scheduled outside the interactive session.

## Memory directory

Pick a repo-local path (e.g. `.agent/memory/` in each project) so memory
versions with the code it describes. Commit memory changes on their own —
`snapshot.sh` handles that if the memory dir is its own git repo, or let it
ride the project repo and skip the inner repo entirely.

## Triggers

**Consolidate (session end).** A `SessionEnd` hook in `~/.claude/settings.json`
queues the offline run:

```json
{
  "hooks": {
    "SessionEnd": [{
      "hooks": [{
        "type": "command",
        "command": "claude -p --allowedTools 'Bash,Read,Write,Edit' \"$(cat /path/to/agent-sleep/templates/prompts/consolidate.md)\" >/dev/null 2>&1 &"
      }]
    }]
  }
}
```

Background it (`&`) so session teardown isn't blocked, and pass the session
transcript path as the input the prompt expects.

**Check (daily).** cron or launchd calling a wrapper:

    15 9 * * *  cd /path/to/repo && claude -p "$(cat /path/to/agent-sleep/templates/prompts/check.md)"

Scripts-only means the `-p` run is short and cheap; you can even call
`scripts/*.sh` directly from cron and skip the model entirely on green days.

**Reconcile / prestudy.** Same shape as consolidate — headless `-p` runs,
triggered by a counter check (reconcile) or idle schedule (prestudy).

## Charter fencing

`CLAUDE.md` / `AGENTS.md` is the charter. Instructed fence only: the
consolidate prompt already forbids charter writes, and the hook's
`--allowedTools` list should not include tools that reach the charter
file's path if you want a harder guarantee. Simplest hard fence: keep the
charter outside the working directory permissions the sleep run gets.
