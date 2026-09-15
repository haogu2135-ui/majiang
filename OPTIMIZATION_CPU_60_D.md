# CPU Optimization Ledger: Batch D

This ledger records the fourth batch of CPU-focused optimizations. Items
`287-346` are the 60 new items in this batch. The source of truth is the
`.gd.part` file named in each row; `scripts/main.gd` is assembled output.

| # | File / function | Previous hotspot | Optimization | Verification |
|---:|---|---|---|---|
| 287 | `main_base.gd` / online schema keys | Normalization rebuilt compatibility key arrays. | Share common online key arrays as constants. | `performance_optimization_60_d_check.gd` |
| 288 | `main_base.gd` / `tile_path` | Tile face paths were rebuilt for every face render. | Cache canonical face paths with a bounded table. | `performance_optimization_60_d_check.gd` |
| 289 | `main_base.gd` / `tile_sort_index` | Sorting repeated canonical order resolution. | Cache canonical sort indexes. | `performance_optimization_60_d_check.gd` |
| 290 | `main_base.gd` / `suit_code` | Suit integer-to-code conversion repeated. | Cache the three suit codes. | `performance_optimization_60_d_check.gd` |
| 291 | `main_base.gd` / `suit_label` | Suit labels repeated match branches. | Cache the three suit labels. | `performance_optimization_60_d_check.gd` |
| 292 | `main_base.gd` / `tile_label` | Computed Chinese tile names were not always stored. | Write resolved face labels back to cache. | `performance_optimization_60_d_check.gd` |
| 293 | `main_base.gd` / `tile_speech_label` | Speech names repeated canonical branches. | Store the resolved speech name. | `performance_optimization_60_d_check.gd` |
| 294 | `main_base.gd` / `tile_corner` | Corner glyphs repeated tile classification. | Store the resolved corner glyph. | `performance_optimization_60_d_check.gd` |
| 295 | `main_base.gd` / `tile_accent` | Accent color selection repeated per tile control. | Store the resolved accent color. | `performance_optimization_60_d_check.gd` |
| 296 | `main_base.gd` / semantic cache bound | Semantic cache limits were duplicated as literals. | Centralize the cache capacity. | `performance_optimization_60_d_check.gd` |
| 297 | `main_base.gd` / `claim_label` | Claim labels rebuilt during action redraw. | Cache normalized claim labels. | `performance_optimization_60_d_check.gd` |
| 298 | `main_base.gd` / `claim_color` | Claim colors repeated for each button. | Cache claim colors. | `performance_optimization_60_d_check.gd` |
| 299 | `core.gd.part` / `seat_wind_label` | Seat wind names repeated across table art. | Cache the four seat wind labels. | `performance_optimization_60_d_check.gd` |
| 300 | `core.gd.part` / `shanten_label` | Shanten text repeated across advisor cards. | Cache integer shanten labels. | `performance_optimization_60_d_check.gd` |
| 301 | `core.gd.part` / `risk_label` | Risk bucket text repeated during hand rendering. | Cache the risk bucket key. | `performance_optimization_60_d_check.gd` |
| 302 | `core.gd.part` / `wall_state_text` | Wall status text recomputed on each HUD reader. | Cache by mode, wall, total, and revision. | `performance_optimization_60_d_check.gd` |
| 303 | `core.gd.part` / `center_phase_label` | Center phase labels repeated match branches. | Cache phase text. | `performance_optimization_60_d_check.gd` |
| 304 | `core.gd.part` / `center_phase_color` | Center phase colors repeated match branches. | Cache phase colors. | `performance_optimization_60_d_check.gd` |
| 305 | `core.gd.part` / `normalize_tile_array` | The same JSON tile arrays were normalized by each consumer. | Add an isolated bounded normalized-array cache. | `performance_optimization_60_d_check.gd` |
| 306 | `core.gd.part` / `normalize_claim_options` | Claim aliases were normalized repeatedly. | Cache normalized claim option arrays. | `performance_optimization_60_d_check.gd` |
| 307 | `online.gd.part` / `normalize_online_chi_choices` | Chi payloads were rebuilt for each response reader. | Cache by payload and claimed tile. | `performance_optimization_60_d_check.gd` |
| 308 | `online.gd.part` / `normalize_online_melds` | Meld payloads were normalized per player consumer. | Cache normalized meld projections. | `performance_optimization_60_d_check.gd` |
| 309 | `online.gd.part` / `normalize_online_players` | Roster normalization copied every player repeatedly. | Cache bounded roster projections with isolated copies. | `performance_optimization_60_d_check.gd` |
| 310 | `online.gd.part` / `normalize_online_message_kind` | Protocol aliases repeated lower/replace/match work. | Cache compact message identities. | `performance_optimization_60_d_check.gd` |
| 311 | `online.gd.part` / `normalize_online_phase` | Phase aliases repeated lower/replace/match work. | Cache compact phase identities. | `performance_optimization_60_d_check.gd` |
| 312 | `online.gd.part` / `normalize_last_discard_tile` | Last-discard aliases were normalized by each reader. | Cache canonical last-discard tile values. | `performance_optimization_60_d_check.gd` |
| 313 | `core.gd.part` / retained log count | Count readers repeatedly inspected the retained array. | Cache count by log revision and array size. | `performance_optimization_60_d_check.gd` |
| 314 | `core.gd.part` / visible log range | Range text rebuilt on repeated navigation reads. | Cache by root, scroll, revision, total, and viewport. | `performance_optimization_60_d_check.gd` |
| 315 | `main_base.gd` / score delta refresh | Summary bars rescanned score deltas independently. | Compute maximum absolute delta once per refresh. | `performance_optimization_60_d_check.gd` |
| 316 | `main_base.gd` / shop item order | Shop consumers rebuilt item order and indexes. | Share one stable item ID array and index map. | `performance_optimization_60_d_check.gd` |
| 317 | `gameplay.gd.part` / runtime delays | Each pacing await allocated and freed a Timer. | Reuse a bounded runtime delay Timer pool. | `performance_optimization_60_d_check.gd` |
| 318 | `audio.gd.part` / one-shot SFX | Fallback effects allocated player and cleanup Timer objects. | Reuse bounded one-shot player subtrees. | `performance_optimization_60_d_check.gd` |
| 319 | `gameplay.gd.part`, `render.gd.part` / discard draw | River drawing reread viewport, table, and discard state. | Pass one battle snapshot to river drawing. | `performance_optimization_60_d_check.gd` |
| 320 | `gameplay.gd.part`, `render.gd.part` / meld draw | Meld drawing reread viewport, content, and meld state. | Pass one battle snapshot to meld drawing. | `performance_optimization_60_d_check.gd` |
| 321 | `render.gd.part` / `tile_face_font_size` | Tile font sizing repeated height multiplication. | Cache by tile control dimensions. | `performance_optimization_60_d_check.gd` |
| 322 | `main_base.gd` / `tile_index` | Canonical index lookup repeated after normalization. | Cache normalized tile indexes. | `performance_optimization_60_d_check.gd` |
| 323 | `main_base.gd` / `tile_index_normalized` | Internal callers repeated direct index lookups. | Cache already-normalized indexes separately. | `performance_optimization_60_d_check.gd` |
| 324 | `main_base.gd` / `chinese_rank` | Numeric Chinese rank conversion repeated in speech. | Cache the nine rank strings. | `performance_optimization_60_d_check.gd` |
| 325 | `core.gd.part` / `hand_group_index` | Hand grouping repeatedly classified tile suits. | Cache normalized group indexes. | `performance_optimization_60_d_check.gd` |
| 326 | `core.gd.part` / `hand_group_label` | Hand grouping repeatedly mapped group labels. | Cache normalized group labels. | `performance_optimization_60_d_check.gd` |
| 327 | `core.gd.part` / pending source badge | Source-seat text repeated for response cards. | Cache the bounded seat-to-badge mapping. | `performance_optimization_60_d_check.gd` |
| 328 | `core.gd.part` / pending priority text | Priority text rebuilt its label map per redraw. | Cache by option ordering. | `performance_optimization_60_d_check.gd` |
| 329 | `core.gd.part` / pending shortcut text | Shortcut text rebuilt its map per redraw. | Cache by option ordering. | `performance_optimization_60_d_check.gd` |
| 330 | `core.gd.part` / `claim_options_text` | Claim and chi labels were joined repeatedly. | Cache by options and chi-choice snapshots. | `performance_optimization_60_d_check.gd` |
| 331 | `core.gd.part` / `chi_choice_label` | The same chi meld label was formatted repeatedly. | Cache meld-derived chi labels. | `performance_optimization_60_d_check.gd` |
| 332 | `core.gd.part` / compact chi label | Compact chi labels repeated rank/suit formatting. | Cache the compact variant separately. | `performance_optimization_60_d_check.gd` |
| 333 | `core.gd.part` / `compact_tile_run_label` | Short tile runs were regrouped by every summary reader. | Cache by tile-run representation. | `performance_optimization_60_d_check.gd` |
| 334 | `core.gd.part` / action intent state | Intent readers independently probed dynamic mode state. | Publish one state token with revisions and flags. | `performance_optimization_60_d_check.gd` |
| 335 | `core.gd.part` / `action_intent_text` | Intent text rebuilt state-specific sentences. | Cache by token and visible count. | `performance_optimization_60_d_check.gd` |
| 336 | `core.gd.part` / `action_intent_color` | Intent color repeated state branches. | Cache by action token. | `performance_optimization_60_d_check.gd` |
| 337 | `core.gd.part` / `action_intent_icon_name` | Intent icon selection repeated state branches. | Cache by action token. | `performance_optimization_60_d_check.gd` |
| 338 | `core.gd.part` / fallback intent glyph | Fallback glyph selection repeated state branches. | Cache by action token. | `performance_optimization_60_d_check.gd` |
| 339 | `core.gd.part` / `action_button_tooltip` | The tooltip match tree ran on each refresh. | Cache by trimmed button text with a fixed bound. | `performance_optimization_60_d_check.gd` |
| 340 | `core.gd.part` / connection status text | Status text was recomputed by each HUD reader. | Cache by transport, disconnect state, and revision. | `performance_optimization_60_d_check.gd` |
| 341 | `core.gd.part` / `update_stage_index` | Update stage mapping repeated on every dialog read. | Cache by update state. | `performance_optimization_60_d_check.gd` |
| 342 | `core.gd.part` / `update_state_color` | Update colors repeated match branches. | Cache by update state. | `performance_optimization_60_d_check.gd` |
| 343 | `core.gd.part` / `update_progress_text` | Progress text reformatted bytes and percentages. | Cache by displayed fields and viewport dimensions. | `performance_optimization_60_d_check.gd` |
| 344 | `core.gd.part` / `manifest_notes_to_text` | Manifest notes were joined repeatedly. | Cache bounded notes conversions. | `performance_optimization_60_d_check.gd` |
| 345 | `core.gd.part` / `version_numbers` | Version comparisons reparsed the same strings. | Cache isolated numeric vectors. | `performance_optimization_60_d_check.gd` |
| 346 | `core.gd.part` / `safe_filename_part` | Download filenames repeated character sanitization. | Cache bounded sanitized filename parts. | `performance_optimization_60_d_check.gd` |

The ledger describes bounded work and reuse; it does not claim a benchmark
percentage without a controlled before/after profile. The UI remains on
GPT-generated raster assets for the Guofeng bright theme; this batch adds no
code-drawn image replacement.

## Validation commands

```bash
python3 tools/assemble_main.py --verify
git diff --check
env GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 godot --headless --path . -s scripts/performance_optimization_60_d_check.gd
```
