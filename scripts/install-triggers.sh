#!/usr/bin/env bash
# install-triggers.sh — detect installed agent platforms and print the
# wake/sleep trigger wiring for each. Advisory by design: hooks and queues
# are config, and platforms change faster than scripts.
# Optional: --cron "<expr>" adds a crontab entry running the daily check.
set -euo pipefail

HERE=$(cd "$(dirname "$0")/.." && pwd)

echo "agent-sleep trigger wiring"
echo "========================="
echo

found=0
if [[ -d ${HOME}/.zcode ]]; then
  found=1
  echo "[zcode]      read adapters/zcode.md — OffPeakCreate for consolidate/prestudy,"
  echo "             CronCreate for the daily check, session-end hook to queue consolidation."
fi
if [[ -d ${HOME}/.claude ]]; then
  found=1
  echo "[claude]     read adapters/claude-code.md — SessionEnd hook + 'claude -p' for"
  echo "             offline phases, cron for the daily check."
fi
if [[ -d ${HOME}/.config/opencode ]] || command -v opencode >/dev/null 2>&1; then
  found=1
  echo "[opencode]   read adapters/opencode.md — plugin event or cron + headless run."
fi
if [[ $found -eq 0 ]]; then
  echo "no known platform dirs found — read adapters/generic.md (cron + any headless"
  echo "agent CLI works: Gemini CLI, Codex, Aider, ...)."
fi
echo
echo "scripts live in: $HERE/scripts"
echo "prompt templates: $HERE/templates/prompts"

if [[ ${1:-} == "--cron" ]]; then
  EXPR=${2:?--cron needs an expression, e.g. --cron "15 9 * * *"}
  CMD="cd '$HERE' && ./scripts/verify-memory.sh \"\${AGENT_SLEEP_MEMORY:?set AGENT_SLEEP_MEMORY}\""
  LINE="$EXPR $CMD # agent-sleep daily check"
  (crontab -l 2>/dev/null || true; echo "$LINE") | crontab -
  echo "installed crontab: $EXPR (set AGENT_SLEEP_MEMORY in your crontab env)"
fi
