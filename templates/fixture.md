#!/usr/bin/env bash
# Fixture: <skill-or-behavior-name>
# A founding test: frozen when the behavior was confirmed working, and never
# updated to match a regression. Sliding scores here are the drift alarm.
#
# Contract: exit 0 = pass, anything else = fail. Keep it deterministic —
# no network, no randomness, no time-dependence. If it needs data, commit
# the data next to it.
#
# Example shape (make your own, one per skill):

set -euo pipefail

# 1. Recreate the original input
INPUT="the original task, exactly as it was when the behavior was confirmed"

# 2. Assert the invariant that must never regress — e.g. the skill's
#    reference file still exists and its key claim still holds:
SKILL_DOC="/path/to/skills/thing/SKILL.md"
grep -q "the rule that must survive" "$SKILL_DOC"

# 3. If the behavior is scriptable end-to-end, run it:
#   result=$(do-the-thing "$INPUT")
#   [[ "$result" == *"expected shape"* ]]

echo "fixture $0 passed" >&2
