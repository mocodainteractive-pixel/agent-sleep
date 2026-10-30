#!/usr/bin/env bash
# prune-ttl.sh — find (or move) memory entries whose TTL has expired.
# Expired = last_validated older than ttl_days ago, or ttl set with no
# last_validated stamp at all. Dry-run by default; --apply moves entries to
# trash/ (snapshot.sh afterwards records the prune).
# Usage: prune-ttl.sh <memory-dir> [--apply]
set -uo pipefail

usage() { echo "usage: $0 <memory-dir> [--apply]" >&2; exit 2; }
[[ $# -ge 1 ]] || usage
DIR=$1
APPLY=0
[[ ${2:-} == "--apply" ]] && APPLY=1

[[ -d $DIR ]] || { echo "error: not a directory: $DIR" >&2; exit 1; }

fm_field() { # fm_field <file> <key> — frontmatter scalar lookup; joins wrapped values
  awk -v key="$2" '
    function flush() {
      if (done) exit
      done = 1
      if (acc == "\"\"") acc = ""   # exactly "" means absent; real quoted values keep their quotes
      print acc; exit
    }
    /^---$/ { if (found) flush(); fm = !fm; next }
    fm && !found && $0 ~ "^  " key ":" { sub("^  " key ":[ ]*", ""); acc = $0; found = 1; next }
    found && fm && /^    / { l = $0; sub(/^ +/, "", l); acc = acc " " l; next }
    found { flush() }
    END { if (found) flush() }
  ' "$1"
}

expired_p() { # expired_p <file> — 0 if expired
  local f=$1 ttl lv
  ttl=$(fm_field "$f" ttl_days)
  [[ -z $ttl || $ttl == "null" ]] && return 1
  ttl=${ttl%% *} # tolerate trailing comments
  lv=$(fm_field "$f" last_validated)
  if [[ -z $lv ]]; then return 0; fi
  local deadline
  deadline=$(date -j -v+"${ttl}"d -f "%Y-%m-%d" "$lv" +%s 2>/dev/null) || return 0
  local now; now=$(date +%s)
  [[ $now -gt $deadline ]]
}

COUNT=0
shopt -s nullglob
mkdir -p "$DIR/trash"
for f in "$DIR"/*.md; do
  base=$(basename "$f")
  [[ $base == MEMORY.md ]] && continue
  if expired_p "$f"; then
    COUNT=$((COUNT+1))
    if [[ $APPLY -eq 1 ]]; then
      mv "$f" "$DIR/trash/"
      echo "pruned  $base  -> trash/"
    else
      echo "expired $base  (dry-run; --apply to prune)"
    fi
  fi
done

echo "---"
if [[ $COUNT -eq 0 ]]; then
  echo "no expired entries"
else
  echo "$COUNT expired"
  [[ $APPLY -eq 1 ]] && echo "run snapshot.sh to record the prune"
fi
exit 0
