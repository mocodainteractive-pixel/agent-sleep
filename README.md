# agent-sleep

Sleep-cycle memory management for coding agents. Sessions work; offline
phases consolidate what they learned, verify it against source, and forget
it on a schedule. Ships as a portable skill (SKILL.md + bash scripts +
prompt templates) with thin adapters per platform.

The problem it solves is documented now in half a dozen papers: agents with
persistent memory drift. Summaries lose nuance with each pass, compaction
silently drops standing rules, stored workarounds outlive their bugs, and
planted content fires days later. None of that needs an attacker — memory is
a feedback loop, so small errors compound on their own.

The fix is a lifecycle, not more memory. Consolidate per session against the
raw source, check mechanically every day, rewrite only when enough new
material justifies a compression event, and rebuild from source when
maintenance stops being worth it. Every write is a git commit, so every
failure is loud, early, and reversible.

```
wake sessions ──▶ consolidate ──▶ project memory (git) ──▶ warm start
                      │                   ▲   │
                      │                   │   └─ daily check: TTL, pointers, fixtures
                      └─ verify vs raw source  charter stays pinned, never written
```

Full diagram: `docs/architecture.pdf` (system map + defense map).
Animated walkthrough: `docs/animation.mp4`.

## Install

1. Copy this repo (or just `SKILL.md`, `scripts/`, `templates/`) into your
   agent's skills directory, or add the repo as a plugin.
2. Run `scripts/install-triggers.sh` and follow the wiring it prints for your
   platform. Adapters: `adapters/zcode.md`, `adapters/claude-code.md`,
   `adapters/opencode.md`, `adapters/generic.md` (cron + headless CLI —
   covers Gemini CLI, Codex, Aider, and friends).
3. Point the triggers at a memory directory. `scripts/snapshot.sh` git-inits
   it on first run; nothing else needs setup.

Charter rules live in your `AGENTS.md` / `CLAUDE.md` as usual. This skill
never writes them.

## Modes

| Mode | Trigger | Runs |
| --- | --- | --- |
| consolidate | session end, off-peak | `templates/prompts/consolidate.md` — extract, verify, promote; serialized |
| check | daily cron | `verify-memory.sh`, `prune-ttl.sh` (dry-run), `run-fixtures.sh` — read-only |
| reconcile | N promotions or contradiction flag | `templates/prompts/reconcile.md` — dedupe, prune, scoped rewrites |
| prestudy | idle | `templates/prompts/prestudy.md` — regenerate warm-start from repo |
| rebuild | maintenance exceeds value | regenerate from source; inherit charter + tested memories only |
| rollback | drift alarm | `rollback.sh <dir> N` — restore last-known-good |

## Why each gate exists

| Defense | Failure it answers | Evidence |
| --- | --- | --- |
| Verify against raw source, never a summary | semantic drift ("mildly spicy" → "loves spicy") | The AI Corner; arXiv 2605.16746 |
| Founding tests per skill | procedural drift; self-evolution is non-monotonic | arXiv 2605.09315 |
| Charter pinned outside write scope | compaction drops rules, 30–59% violations | arXiv 2606.22528 |
| TTL + daily re-validation | memory rot; broad retention triples violations | arXiv 2605.17830 |
| Per-project isolation + scope frontmatter | cross-context bleed; retrieval collision | The AI Corner; arXiv 2610.25858 |
| Conclusions-not-transcripts handoffs | poisoning and laundering survive compression | arXiv 2605.17830, 2605.16746 |
| Additive scoped skills | catastrophic forgetting on shared-rule edits | arXiv 2605.09315 |
| Rewrite on trigger, never calendar | over-refinement makes memory generic | Letta, *Memory Models* |

The lineage, for the curious: Google's SLEEP framework (arXiv 2606.03979)
supplied the wake/sleep lifecycle and the pruning/selection discipline;
Letta's sleep-time compute supplied the idle-phase economics; the agent-lifespan
research supplied every gate. What this repo adds is the harness-level
implementation — token space, platform-agnostic, no training required.

## License

MIT — see `LICENSE`.
