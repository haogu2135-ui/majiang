# CPU Optimization Ledger: Batch B

This ledger records the second batch of CPU-focused optimizations. The source
of truth is the `.gd.part` file named in each row; `scripts/main.gd` is
assembled output.

| # | File / function | Previous hotspot | Optimization | Verification |
|---:|---|---|---|---|
| 61 | `quality.gd.part` / replay archive | Archive lookups, upserts, favorites, and deletes scanned the entry array. | Maintain an `archive_id -> array index` map, rebuilding only after bulk loads or array shifts. | `performance_optimization_60_b_check.gd`, `offline_smoke_test.gd` |
| 62 | `screens.gd.part` / Toast queue | Duplicate toast enqueue scanned every queued message. | Index queued entries by text and synchronize the index on enqueue, eviction, dequeue, and clear. | `performance_optimization_60_b_check.gd` |
| 63 | `screens.gd.part` / Toast queue | Repeat count could keep growing after its visual bound was reached. | Stop count accounting at the configured repeat cap while retaining the bounded entry. | `performance_optimization_60_b_check.gd` |
| 64 | `screens.gd.part`, `audio.gd.part` / Toast indicator | Queue indicator refreshes recursively searched the active Toast tree. | Retain the active pending Label and clear it with the Toast lifecycle. | `performance_optimization_60_b_check.gd` |
| 65 | `render.gd.part` / `cached_ui_control_list` | An empty valid control list was treated as an uncached result and rescanned. | Use metadata presence plus structure tokens to accept empty cached lists. | `performance_optimization_60_b_check.gd` |
| 66 | `main_base.gd` / `find_ui_contract_control` | Every lookup indirectly called the render-part cache helper. | Read the existing name-index metadata directly and retain the tree fallback. | `performance_optimization_60_b_check.gd`, `ui_interaction_smoke_test.gd` |
| 67 | `online.gd.part` / `online_message_revision` | A fallback `first_present` call was eagerly evaluated even when the nested state had a revision. | Resolve the nested source first and evaluate the outer fallback only when needed. | `online_protocol_smoke_test.gd` |
| 68 | `core.gd.part` / `standard_shanten_search` | Each recursive state scanned tile counters from slot zero. | Pass the current first candidate slot into recursive calls and scan only the remaining suffix. | `ai_play_round80_check.gd`, `ai_play_round87_check.gd` |
| 69 | `ai_brain.gd.part` / discard candidate loops | Candidate deduplication allocated a dictionary keyed by tile strings. | Deduplicate canonical candidates with a fixed 34-slot Boolean array. | `ai_play_round80_check.gd`, `ai_play_round96_check.gd` |

The ledger describes bounded work and reuse; it does not claim a benchmark
percentage without a controlled before/after profile.
