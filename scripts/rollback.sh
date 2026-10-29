#!/usr/bin/env bash
# rollback.sh — restore last-known-good memory state.
# Usage: rollback.sh <memory-dir> [N]   (N commits back, default 1)
set -euo pipefail

usage() { echo "usage: $0 <memory-dir> [N]" >&2; exit 2; }
[[ $# -ge 1 ]] || usage

DIR=$1
N=${2:-1}

[[ -d $DIR/.git ]] || { echo "error: no git history in $DIR (run snapshot.sh first)" >&2; exit 1; }

cd "$DIR"
if ! git rev-parse --verify -q "HEAD~$N" >/dev/null 2>&1; then
  echo "error: only $(git rev-list --count HEAD) commit(s) in history — nothing $N back to restore" >&2
  exit 1
fi
echo "restoring to HEAD~$N ($(git rev-parse --short "HEAD~$N"))"
echo "current state will be kept as a rescue ref 'pre-rollback'"
git branch -q -f pre-rollback 2>/dev/null || true
git reset -q --hard "HEAD~$N"
echo "done. current: $(git rev-parse --short HEAD)"
echo "if this was wrong: git -C '$DIR' reset --hard pre-rollback"
