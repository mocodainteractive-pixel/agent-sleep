#!/usr/bin/env bash
# verify-memory.sh — re-validate every memory file against its declared source.
# Checks file paths, URLs, and verify: commands from frontmatter.
# Updates last_validated on pass; reports failures and exits 1 if any entry fails.
# Read-only apart from the last_validated stamp. Usage: verify-memory.sh <memory-dir>
set -uo pipefail

usage() { echo "usage: $0 <memory-dir>" >&2; exit 2; }
[[ $# -eq 1 ]] || usage
DIR=$1
[[ -d $DIR ]] || { echo "error: not a directory: $DIR" >&2; exit 1; }

TODAY=$(date +%F)
PASS=0; FAIL=0; SKIP=0
FAILED=()

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

check_url() {
  local code
  code=$(curl -sIL -o /dev/null -w '%{http_code}' --max-time 10 "$1" 2>/dev/null || echo 000)
  [[ $code =~ ^[23] ]]
}

shopt -s nullglob
for f in "$DIR"/*.md; do
  base=$(basename "$f")
  [[ $base == MEMORY.md ]] && continue
  src=$(fm_field "$f" source)
  verify=$(fm_field "$f" verify)
  status=PASS; why=""

  if [[ -n $src ]]; then
    case $src in
      http://*|https://*)
        check_url "$src" || { status=FAIL; why="url not reachable: $src"; } ;;
      /*|./*)
        [[ -e $src ]] || { status=FAIL; why="path missing: $src"; } ;;
      session:*)
        : # session sources are checked at consolidation time only
        status=SKIP ;;
      *)
        : # free-form source: nothing machine-checkable
        status=SKIP ;;
    esac
  else
    status=SKIP
  fi

  if [[ $status != FAIL && -n $verify ]]; then
    if ! bash -c "$verify" >/dev/null 2>&1; then
      status=FAIL; why="verify command failed: $verify"
    fi
  fi

  case $status in
    PASS)
      PASS=$((PASS+1))
      # stamp last_validated
      if grep -q '^  last_validated:' "$f"; then
        sed -i '' "s/^  last_validated:.*/  last_validated: $TODAY/" "$f"
      fi
      echo "PASS  $base" ;;
    SKIP) SKIP=$((SKIP+1)); echo "skip  $base  (no machine-checkable source)" ;;
    FAIL) FAIL=$((FAIL+1)); FAILED+=("$base"); echo "FAIL  $base  — $why" ;;
  esac
done

echo "---"
echo "pass=$PASS skip=$SKIP fail=$FAIL"
if [[ $FAIL -gt 0 ]]; then
  echo "drift alarm: failing entries: ${FAILED[*]}"
  echo "next: fix the source, drop the entry (prune-ttl.sh --apply), or rollback.sh"
  exit 1
fi
