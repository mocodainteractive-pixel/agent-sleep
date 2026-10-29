# Reconcile — offline prompt (event-triggered, never calendar)

You run because N new memories were promoted since the last reconcile, or a
contradiction was flagged. Every rewrite below is a compression event; this
run exists to spend a batch of them well. You never write the charter.

## 1. Load and cluster

Read every memory file and the index. Cluster by topic and scope. Look for:

- Duplicates: same fact, two files (near-duplicate description or body).
- Overlaps: one file's scope swallowed by a broader one.
- Contradictions: two files whose claims or scopes conflict.

## 2. Resolve — with the right authority

- Duplicates/overlaps: merge into the better-written file, keep the stricter
  scope, carry forward source + verify + the EARLIER last_validated (do not
  refresh stamps by merging). Delete the loser, update the index.
- Contradictions: check both against their sources. If one is simply stale
  (expired facts, moved paths), it loses. If both verify clean against
  current source, DO NOT pick a winner — write both claims to the run
  report under "needs human decision" and leave both files untouched.
  Auto-merging a real contradiction is how the agent quietly changes its
  mind about something that matters.

## 3. Prune

Run `prune-ttl.sh <memory-dir> --apply` for entries already flagged expired
by the daily check. Move, don't delete; trash/ keeps history and git keeps
the rest.

## 4. Rewrite scopes only where evidence demands

If clustering revealed that a scope was wrong (a file recalled where it
shouldn't be), fix the scope line. Do not rewrite bodies for style, brevity,
or "clarity" — repeated refinement is a documented drift vector, and the
current text is what verification validated.

## 5. Snapshot once

    scripts/snapshot.sh <memory-dir> "reconcile: -X merged, -Y pruned, Z flagged"

## Output

Counts (merged/pruned/flagged), the "needs human decision" list verbatim,
and nothing else.
