# Prestudy — offline prompt (idle, regenerative)

Re-derive the current state of ONE repo into a warm-start memory file so the
next session begins oriented instead of rediscovering. This mode is
regenerative by construction: it OVERWRITES its own previous output and
never accumulates, so it structurally cannot drift.

## Steps

1. If `prestudy-<repo>.md` exists in memory, delete its body first — you
   will replace it wholesale. Do not read it as an input; the repo is the
   input.
2. Survey the repo: layout, entry points, build/test commands, current
   branch state, open TODOs, recent commits (what changed since the last
   prestudy, from git log).
3. Write `prestudy-<repo>.md` using the memory-file format with:

   - scope: "applies to the first orientation of any session in this repo;
     stale the moment the session starts reading files itself"
   - source: the repo path, verify: `test -d <repo-path> && git -C <repo-path> log -1 --format=%h | grep -q .`
   - ttl_days: 7 — prestudy expires fast because the repo moves
4. Update the index line if the description changed materially.
5. `scripts/snapshot.sh <memory-dir> "prestudy: <repo> @ $(git -C <repo> rev-parse --short HEAD)"`

## Rules

- Facts only, with paths. No interpretations of intent, no speculation
  about why code is the way it is.
- Cap the file at what a newcomer could read in two minutes. If the repo
  needs more than that, the repo needs a README, not a longer memory.
- Never merge prestudy output into other memory files. It is a cache, and
  caches get invalidated, not curated.
