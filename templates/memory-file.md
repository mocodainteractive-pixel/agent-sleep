---
name: short-kebab-slug
description: One line, written for recall decisions — what this tells the agent and when it matters.
metadata:
  type: project          # user | feedback | project | reference
  scope: Applies when working on X. Does NOT apply to Y.
  source: /absolute/path | https://url | session:<id>
  # verify: any-command    # optional — omit the key entirely when nothing is machine-checkable
  ttl_days: 30           # expires unless re-validated; omit for durable entries
  last_validated: 2026-10-28
---

One fact per file. The body states the fact, why it's true (with a pointer
to the source), and nothing else. If a second fact is fighting to get in,
it wants its own file.

Rules that make the machinery work:

- `scope` is required and names the negative case too — query similarity
  does not respect workflow compatibility, so the file must say when it
  should NOT be recalled.
- `source` is the ground truth this fact came from. `verify-memory.sh`
  checks it: paths must exist, URLs must answer, commands must exit 0.
- `ttl_days` defaults to 30. Anything durable (who the user is, contract
  terms) omits it; anything environmental (ports, quotas, versions) keeps
  it short.
- Never edit this file to "refresh" it. Re-derive it from source, or let
  it expire.
