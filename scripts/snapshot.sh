#!/usr/bin/env bash
# snapshot.sh — commit the memory directory. The only sanctioned write path.
# Usage: snapshot.sh <memory-dir> [message]
set -euo pipefail

usage() { echo "usage: $0 <memory-dir> [message]" >&2; exit 2; }
[[ $# -ge 1 ]] || usage

DIR=$1
MSG=${2:-"agent-sleep: memory snapshot $(date -u +%Y-%m-%dT%H:%M:%SZ)"}

[[ -d $DIR ]] || { echo "error: not a directory: $DIR" >&2; exit 1; }

cd "$DIR"
if [[ ! -d .git ]]; then
  git init -q
  echo "initialized git in $DIR"
fi

git add -A
if git diff --cached --quiet; then
  echo "nothing to snapshot — tree clean"
else
  git commit -q -m "$MSG"
  echo "snapshot: $(git rev-parse --short HEAD)"
fi
