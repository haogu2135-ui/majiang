# CPU Optimization Ledger: 60 Items

This ledger records the 60 distinct CPU-focused optimizations currently in the
Godot client. The source of truth is the `.gd.part` file named in each row;
`scripts/main.gd` is assembled output. The last two items were completed in the
current pass.

| # | File / function | Previous hotspot | Optimization | Verification |
|---:|---|---|---|---|
| 1 | `main_base.gd` / `normalize_tile_code` | Every canonical tile paid for trimming and uppercasing. | Return canonical codes before string work. | `offline_smoke_test.gd` |
| 2 | `main_base.gd` / `normalize_tile_code` | Repeated alias normalization grew an unbounded or shifting cache. | Use a bounded linked-list LRU cache. | `offline_smoke_test.gd` |
| 3 | `main_base.gd` / `tile_index_normalized` | Already-normalized callers entered `tile_index` and normalized again. | Add a direct canonical `tile_order` lookup. | `performance_optimization_60_check.gd` |
| 4 | `main_base.gd` / `tile_sort_index` | Sort lookup fell through to a second index conversion. | Resolve canonical tile order directly. | `offline_smoke_test.gd` |
| 5 | `main_base.gd` / `tile_counts` | Each tile called the normalizing index helper. | Normalize once, then increment the direct index. | `performance_optimization_60_check.gd` |
| 6 | `main_base.gd` / `tile_count_from_counts` | Count lookup repeated the full index helper path. | Normalize once and read `tile_order`. | `offline_smoke_test.gd` |
| 7 | `main_base.gd` / `find_tile_in_hand` | Canonical hands normalized every item during a search. | Fast canonical pass with alias fallback. | `offline_smoke_test.gd` |
| 8 | `main_base.gd` / `count_tile` | Counting a canonical hand normalized every item. | Fast canonical pass with compatibility fallback. | `ai_play_round51_check.gd` |
| 9 | `main_base.gd` / `tile_label` | Callers could repeatedly normalize the same face. | Normalize once at the cached label boundary. | `offline_smoke_test.gd` |
| 10 | `main_base.gd` / `tile_speech_label` | Speech label lookup repeated alias handling. | Normalize before cache lookup. | `offline_smoke_test.gd` |
| 11 | `main_base.gd` / `tile_corner` | Corner glyph lookup repeated alias handling. | Normalize before cache lookup. | `offline_smoke_test.gd` |
| 12 | `main_base.gd` / `tile_accent` | Accent lookup repeated alias handling. | Normalize before cache lookup. | `offline_smoke_test.gd` |
| 13 | `main_base.gd` / `tile_semantic_record` | Semantic cache hits used an array order list. | Use linked-list LRU touch and eviction. | `ui_layout_smoke_test.gd` |
| 14 | `ai_brain.gd.part` / `calculate_min_shanten_from_counts` | Repeated count-form shanten entries scanned an order array. | Add O(1) shanten-count LRU links. | `ai_play_round80_check.gd` |
| 15 | `core.gd.part` / `calculate_min_shanten` | Shanten cache eviction shifted an array. | Evict by linked-list tail. | `ai_play_round80_check.gd` |
| 16 | `ai_brain.gd.part` / `effective_tile_metrics` | Ukeire cache touches scanned key order. | Maintain an O(1) LRU chain. | `ai_play_round80_check.gd` |
| 17 | `ai_brain.gd.part` / `get_ai_discard_reports` | Report cache hits and eviction scanned arrays. | Store and touch reports through linked-list LRU state. | `ai_play_round80_check.gd` |
| 18 | `ai_brain.gd.part` / `get_ai_discard_reports` | Quiet simulations retained state-unique report copies. | Bypass report cache and accounting in quiet mode. | `ai_play_round80_check.gd` |
| 19 | `ai_brain.gd.part` / `get_ai_discard_reports` | Direct external cache clears left stale LRU links. | Repair stale links before the next cached insert. | `ai_play_round80_check.gd` |
| 20 | `ai_brain.gd.part` / `added_gang_rob_threat_report` | Rob-gang threat eviction scanned insertion order. | Add dedicated O(1) threat LRU links. | `ai_play_round51_check.gd` |
| 21 | `ai_brain.gd.part` / `ai_hand_shape_metrics_from_counts` | Identical 34-count shape metrics were recomputed. | Cache shape metrics with linked-list eviction. | `ai_play_round87_check.gd` |
| 22 | `ai_brain.gd.part` / `score_context_report_cached` | Four score adjustments rebuilt the same context. | Share one state-keyed score context per seat. | `ai_play_round80_check.gd` |
| 23 | `core.gd.part` / `ranked_seats_by_score_shared` | Score rank ordering was repeated by each strategy read. | Cache the ranked seat vector for the score state. | `ai_play_round82_check.gd` |
| 24 | `ai_brain.gd.part` / `wait_value_metrics` | A dictionary default expression scanned the hand eagerly. | Read cached remaining count before fallback scanning. | `ai_play_round80_check.gd` |
| 25 | `ai_brain.gd.part` / `ai_opponent_state_count` | Risk paths repeatedly inspected opponent arrays. | Reuse snapshot counts and only inspect live arrays on fallback. | `ai_play_round96_check.gd` |
| 26 | `core.gd.part` / `evaluate_ai_hand` | Claim evaluation rescanned the same hand shape. | Reuse count-based shape metrics value. | `ai_play_round87_check.gd` |
| 27 | `core.gd.part` / `calculate_win_score_from_tiles` | Win scoring rebuilt and normalized several tile lists. | Build one concealed count vector and reuse it through scoring gates. | `offline_smoke_test.gd` |
| 28 | `core.gd.part` / `scoring_tile_counts_from_counts` | Each scoring pattern rebuilt meld-inclusive counts. | Merge concealed counts with meld tiles once. | `offline_smoke_test.gd` |
| 29 | `core.gd.part` / `is_seven_pairs_from_counts` | Seven-pairs checks iterated raw tile arrays. | Evaluate the existing count vector. | `offline_smoke_test.gd` |
| 30 | `core.gd.part` / `is_thirteen_orphans_from_counts` | Orphan checks repeatedly converted tile lists. | Evaluate orphan counts directly. | `offline_smoke_test.gd` |
| 31 | `core.gd.part` / `is_pure_one_suit_from_counts` | Pure-suit scoring rebuilt suit membership. | Scan 34 counters once. | `offline_smoke_test.gd` |
| 32 | `core.gd.part` / `is_mixed_one_suit_from_counts` | Mixed-suit scoring rebuilt suit membership. | Track suit and honor flags in one counter pass. | `offline_smoke_test.gd` |
| 33 | `core.gd.part` / `is_all_simples_from_counts` | All-simples scoring converted every tile. | Reject terminals/honors directly from indexes. | `offline_smoke_test.gd` |
| 34 | `core.gd.part` / `is_all_honor_from_counts` | All-honor scoring rebuilt a tile list. | Scan only the numbered range in counts. | `offline_smoke_test.gd` |
| 35 | `core.gd.part` / `full_straight_suit_from_counts` | Full-straight scoring recounted concealed tiles per suit. | Reuse a concealed count vector per candidate suit. | `offline_smoke_test.gd` |
| 36 | `core.gd.part` / `is_all_triplet_from_counts` | All-triplet scoring rebuilt raw tile counts. | Pass the existing counts into set formation. | `offline_smoke_test.gd` |
| 37 | `core.gd.part` / `can_form_triplets_with_pair_from_counts` | Triplet-plus-pair checks rebuilt arrays. | Evaluate count vectors directly. | `offline_smoke_test.gd` |
| 38 | `core.gd.part` / `visible_tile_counts_shared` | The same visible table state rebuilt counts per caller. | Cache by visible-state key and return the shared vector. | `ai_play_round96_check.gd` |
| 39 | `core.gd.part` / `add_visible_tile_counts` | Every visible tile entered the normalizing index helper. | Normalize once and increment direct indexes. | `ai_play_round96_check.gd` |
| 40 | `core.gd.part` / `visible_tile_count_from_counts` | Snapshot reads paid for repeated index conversion. | Use one normalized direct lookup. | `ai_play_round96_check.gd` |
| 41 | `core.gd.part` / `tile_suit_index` | Suit lookup normalized twice. | Resolve the already-normalized code directly. | `offline_smoke_test.gd` |
| 42 | `core.gd.part` / `is_honor_tile` | Honor lookup repeated index conversion. | Read the canonical index table directly. | `offline_smoke_test.gd` |
| 43 | `core.gd.part` / `is_terminal_or_honor` | Terminal lookup repeated index conversion. | Read the canonical index table directly. | `offline_smoke_test.gd` |
| 44 | `core.gd.part` / `is_simple_number_tile` | Simple-number lookup repeated index conversion. | Read the canonical index table directly. | `offline_smoke_test.gd` |
| 45 | `gameplay.gd.part` / `get_chi_choices_from_counts` | A normalized claim tile entered `tile_index` again. | Normalize once and use the direct canonical index. | `performance_optimization_60_check.gd` |
| 46 | `core.gd.part` / `tile_array_key` | Key construction normalized and indexed each item twice. | Normalize once, then count by canonical index. | `performance_optimization_60_check.gd` |
| 47 | `core.gd.part` / `small_tile_array_key` | Short keys allocated a dictionary and sorted it. | Use a fixed four-slot insertion sequence. | `offline_smoke_test.gd` |
| 48 | `core.gd.part` / `first_concealed_gang_tile` | Each tile candidate searched the hand independently. | Build one hand count vector and scan tile indexes. | `offline_smoke_test.gd` |
| 49 | `core.gd.part` / `first_added_gang_tile` | Up to 34 candidates repeated hand counts and meld scans. | Build counts once and collect valid triplet tiles once. | `performance_optimization_60_check.gd` |
| 50 | `main_base.gd` / `touch_cache_key`, `evict_cache_key` | Each cache had array erase/pop-front costs. | Centralize linked-list O(1) touch and eviction. | `performance_optimization_60_check.gd` |
| 51 | `core.gd.part` / `collect_visible_focusable_controls` | Focus registry misses rebuilt traversal results. | Cache bounded focus lists with the shared LRU helper. | `ui_interaction_smoke_test.gd` |
| 52 | `render.gd.part` / `center_wall_view_model` | Wall status model was rebuilt on repeated HUD draws. | Cache the small model with an 8-entry LRU. | `ui_layout_smoke_test.gd` |
| 53 | `render.gd.part` / `center_last_discard_view_model` | Center discard model was rebuilt during redraws. | Cache by tile and seat with an 8-entry LRU. | `ui_layout_smoke_test.gd` |
| 54 | `render.gd.part` / `discard_river_tile_semantics` | River semantics recomputed for retained tiles. | Cache by seat, source index, tile and state. | `ui_layout_smoke_test.gd` |
| 55 | `render.gd.part` / `discard_history_summary` | Identical river summaries rebuilt during layout. | Cache by revision key with a bounded LRU. | `ui_layout_smoke_test.gd` |
| 56 | `render.gd.part` / `seat_river_summary` | Seat river summaries rescanned on each HUD refresh. | Cache summaries by state token and seat. | `ui_layout_smoke_test.gd` |
| 57 | `main_base.gd` / `_gpt_plate_texture_for_rect` | Plate crop eviction shifted a texture-key array. | Keep crop entries in a linked-list LRU. | `ui_layout_smoke_test.gd` |
| 58 | `main_base.gd` / `gpt_center_crop_texture` | Center crop eviction shifted a texture-key array. | Keep crop entries in a linked-list LRU. | `ui_layout_smoke_test.gd` |
| 59 | `online.gd.part` / `remember_online_message_identity` | Duplicate eviction allocated `Dictionary.keys()` on every overflow. | Track insertion order with a bounded cursor FIFO. | `performance_optimization_60_check.gd` |
| 60 | `online.gd.part`, `core.gd.part` / voice sequence tracking | Voice duplicate eviction used `pop_front()` and shifted the array. | Track voice sequence order with a bounded cursor FIFO and self-healing reset. | `performance_optimization_60_check.gd` |

## Validation commands

```bash
python3 tools/assemble_main.py --verify
git diff --check
env GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 godot --headless --path . -s scripts/performance_optimization_60_check.gd
```

The ledger describes bounded work and reuse; it does not claim a benchmark
percentage without a controlled before/after profile. The full online protocol
smoke still has a pre-existing frame-budget sensitivity for a 1500-log burst;
the focused check above isolates the new FIFO behavior.
