#!/usr/bin/env bash
# run-fixtures.sh — run founding tests: the frozen set of original tasks each
# skill must still pass. Any failure is the drift alarm.
# A fixture is an executable .sh in <fixtures-dir> that exits 0 on pass.
# Usage: run-fixtures.sh <fixtures-dir>
set -uo pipefail

usage() { echo "usage: $0 <fixtures-dir>" >&2; exit 2; }
[[ $# -eq 1 ]] || usage
DIR=$1
[[ -d $DIR ]] || { echo "error: not a directory: $DIR" >&2; exit 1; }

shopt -s nullglob
FIXTURES=("$DIR"/*.sh)
[[ ${#FIXTURES[@]} -eq 0 ]] && { echo "no fixtures found in $DIR — add one per skill (see templates/fixture.md)" >&2; exit 1; }

PASS=0; FAIL=0; FAILED=()
for f in "${FIXTURES[@]}"; do
  base=$(basename "$f")
  if "$f" >/dev/null 2>&1; then
    PASS=$((PASS+1)); echo "PASS  $base"
  else
    FAIL=$((FAIL+1)); FAILED+=("$base"); echo "FAIL  $base"
  fi
done

echo "---"
echo "pass=$PASS fail=$FAIL"
if [[ $FAIL -gt 0 ]]; then
  echo "drift alarm: failing fixtures: ${FAILED[*]}"
  echo "next: rollback.sh the last memory/skill change, or fix forward and re-freeze"
  exit 1
fi
