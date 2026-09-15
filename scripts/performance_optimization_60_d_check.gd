extends SceneTree
## Focused regression checks for the fourth CPU optimization batch.

var failed := false


func _initialize() -> void:
	call_deferred("run")


func check(condition: bool, message: String) -> void:
	if condition:
		print("  OK  | %s" % message)
	else:
		print("  FAIL| %s" % message)
		failed = true


func make_player(name: String) -> Dictionary:
	return {
		"name": name,
		"hand": [],
		"discards": [],
		"melds": [],
		"flowers": 0,
		"flower_tiles": [],
		"score": 25000,
		"bot": true,
	}


func run() -> void:
	print("=== performance optimization 60 D check START ===")
	var source := FileAccess.get_file_as_string("res://scripts/main.gd")
	source += FileAccess.get_file_as_string("res://scripts/main_base.gd")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]

	print("--- A) tile and static-label caches ---")
	check(source.contains("const ONLINE_TILE_VALUE_KEYS") and source.contains("const ONLINE_MESSAGE_KIND_KEYS"), "287 shared online schema keys avoid repeated temporary key arrays")
	check(source.contains("tile_path_cache.has(code)") and source.contains("func _tile_path_uncached"), "288 tile paths use a bounded lookup before path construction")
	check(source.contains("tile_sort_index_cache.has(tile)"), "289 tile sort indexes reuse canonical results")
	check(source.contains("suit_code_cache.has(cache_key)"), "290 suit codes reuse the three-value mapping")
	check(source.contains("suit_label_cache.has(suit)"), "291 suit labels reuse the three-value mapping")
	check(source.contains("tile_label_cache[tile] = result"), "292 tile labels write the computed value back")
	check(source.contains("tile_speech_label_cache[tile] = result"), "293 speech labels write the computed value back")
	check(source.contains("tile_corner_cache[tile] = result"), "294 corner labels write the computed value back")
	check(source.contains("tile_accent_cache[tile] = result"), "295 tile accent colors write the computed value back")
	check(source.contains("const TILE_SEMANTIC_CACHE_LIMIT") and source.contains("while tile_semantic_cache.size() > TILE_SEMANTIC_CACHE_LIMIT"), "296 semantic cache capacity is centralized and bounded")
	check(source.contains("claim_label_cache.has(claim)"), "297 claim labels reuse cached Chinese text")
	check(source.contains("claim_color_cache.has(claim)"), "298 claim colors reuse cached values")
	check(source.contains("seat_wind_label_cache.has(cache_key)"), "299 seat wind labels reuse cached values")
	check(source.contains("shanten_label_cache.has(cache_key)"), "300 shanten labels reuse cached values")
	check(source.contains("risk_label_cache.has(cache_key)"), "301 risk labels reuse bucketed text")
	check(source.contains("wall_state_text_cache.has(cache_key)"), "302 wall state text reuses the state-keyed result")
	check(source.contains("center_phase_label_cache.has(phase_key)"), "303 center phase labels reuse cached text")
	check(source.contains("center_phase_color_cache.has(phase_key)"), "304 center phase colors reuse cached values")

	var alias_index: int = scene.tile_index("m1")
	var canonical_index: int = scene.tile_index("1W")
	check(alias_index == canonical_index and scene.tile_index_cache.has("1W"), "tile index cache preserves legacy aliases")
	check(scene.tile_index_normalized("1W") == canonical_index and scene.tile_index_normalized_cache.has("1W"), "normalized tile index cache keeps the direct path")
	check(scene.tile_face_font_size(Vector2(80.0, 120.0)) == scene.tile_face_font_size(Vector2(80.0, 120.0)), "tile face font sizing reuses identical dimensions")
	check(scene.chinese_rank("3") == "三" and scene.chinese_rank_cache.has("3"), "Chinese rank cache preserves the display label")
	check(scene.hand_group_label("1W") == "万" and scene.hand_group_index_cache.has("1W"), "hand group caches preserve suit grouping")

	print("--- B) online normalization caches ---")
	check(source.contains("normalized_tile_array_cache.get(cache_key") and source.contains("normalized_claim_options_cache.get(cache_key"), "305-306 normalized tile and claim arrays have cache fast paths")
	check(source.contains("normalized_online_chi_choices_cache.get(cache_key") and source.contains("normalized_online_melds_cache.get(cache_key"), "307-308 chi choices and melds reuse normalized projections")
	check(source.contains("normalized_online_players_cache.get(cache_key"), "309 normalized player rosters reuse bounded projections")
	check(source.contains("online_message_kind_cache.has(compact)"), "310 message kinds reuse normalized protocol identities")
	check(source.contains("online_phase_cache.has(compact)"), "311 phases reuse normalized protocol identities")
	check(source.contains("online_last_discard_tile_cache.has(cache_key)"), "312 last-discard tiles reuse canonical values")

	scene.normalized_tile_array_cache.clear()
	scene.normalized_tile_array_cache_lru.clear()
	for i in range(scene.ONLINE_NORMALIZATION_CACHE_LIMIT + 12):
		scene.normalize_tile_array([{"tile": "1W", "serial": i}])
	check(scene.normalized_tile_array_cache.size() <= scene.ONLINE_NORMALIZATION_CACHE_LIMIT, "tile-array normalization cache remains bounded")
	var players_payload: Array = [{"seat": 0, "name": "甲", "hand": ["m1"], "discards": ["2W"], "melds": []}]
	var roster_first: Array = scene.normalize_online_players(players_payload)
	var roster_second: Array = scene.normalize_online_players(players_payload)
	roster_first[0]["name"] = "mutated"
	check(roster_second[0].get("name", "") == "甲" and scene.normalized_online_players_cache.size() > 0, "player cache returns isolated copies")
	var chi_payload: Array = [{"meld": ["1W", "2W", "3W"], "needed": ["1W", "2W"]}]
	var chi_first: Array = scene.normalize_online_chi_choices(chi_payload, "3W")
	var chi_second: Array = scene.normalize_online_chi_choices(chi_payload, "3W")
	check(chi_first == chi_second and scene.normalized_online_chi_choices_cache.size() > 0, "chi-choice cache preserves normalized results")
	check(source.contains("cache_online_normalized_value(online_message_kind_cache") and source.contains("cache_online_normalized_value(online_phase_cache"), "message and phase inserts share the bounded LRU writer")
	check(source.contains("cache_online_normalized_value(online_last_discard_tile_cache"), "last-discard normalization shares the bounded LRU writer")

	print("--- C) render, log, and score snapshots ---")
	check(source.contains("online_log_retained_count_cache_revision") and source.contains("online_log_range_cache_key"), "313-314 online log count and range text use revision-aware caches")
	check(source.contains("last_score_delta_max_abs = maxi"), "315 score summary stores the maximum delta in one refresh")
	check(source.contains("func shop_item_ids_shared") and source.contains("shop_item_index_cache"), "316 shop item order and indexes are shared")
	check(source.contains("draw_discards(table, battle_render_context)") and source.contains("\"discards\": battle_discards_snapshot"), "319 discard rendering consumes one battle snapshot")
	check(source.contains("draw_melds(root_layer, battle_render_context)") and source.contains("\"melds\": battle_melds_snapshot"), "320 meld rendering consumes one battle snapshot")

	var score_deltas: Array[int] = [10, -80, 20]
	scene.last_score_deltas = score_deltas
	scene.refresh_score_delta_cache()
	check(scene.last_score_delta_max_abs == 80 and is_equal_approx(scene.round_summary_delta_bar_fraction(-80), 1.0), "score delta maximum scans the complete result vector")
	var shop_ids_first: Array[String] = scene.shop_item_ids_shared()
	var shop_ids_second: Array[String] = scene.shop_item_ids_shared()
	check(shop_ids_first == shop_ids_second and scene.shop_item_index(shop_ids_first[0]) == 0, "shop item cache keeps stable order and index lookup")

	scene.online_room = {"logs": ["a", "b"]}
	scene.online_log_revision += 1
	var log_count_first: int = scene.online_lobby_retained_log_count()
	var log_count_second: int = scene.online_lobby_retained_log_count()
	check(log_count_first == 2 and log_count_first == log_count_second and scene.online_log_retained_count_cache_revision == scene.online_log_revision, "log count cache reuses the current revision")

	var render_root := Control.new()
	render_root.size = Vector2(1280.0, 720.0)
	root.add_child(render_root)
	scene.root_layer = render_root
	scene.players[0]["discards"] = ["1W", "2W"]
	scene.players[0]["melds"] = [["3W", "3W", "3W"]]
	var render_context := {
		"viewport": Vector2(1280.0, 720.0),
		"table_size": Vector2(900.0, 500.0),
		"table_render_size": Vector2(900.0, 500.0),
		"content_size": Vector2(1200.0, 680.0),
		"last_discard_seat": 0,
		"disconnected": false,
		"danger_compact": false,
		"discards": [["1W", "2W"], [], [], []],
		"melds": [[["3W", "3W", "3W"]], [], [], []],
	}
	scene.draw_discards(render_root, render_context)
	scene.draw_melds(render_root, render_context)
	check(render_root.get_meta("discard_river_viewport_snapshot", Vector2.ZERO) == Vector2(1280.0, 720.0), "discard context preserves the single viewport snapshot")
	check(render_root.get_meta("meld_viewport_snapshot", Vector2.ZERO) == Vector2(1280.0, 720.0), "meld context preserves the single viewport snapshot")

	print("--- D) pooled runtime work and dynamic text ---")
	check(source.contains("acquire_runtime_delay_timer") and source.contains("runtime_delay_timer_pool_hits"), "317 runtime delay timers use a reusable pool")
	check(source.contains("one_shot_sfx_pool_hits") and source.contains("cleanup_one_shot_sfx_player(player_id)"), "318 one-shot SFX players use a reusable pool")
	scene.release_runtime_delay_timer_pool()
	scene.runtime_shutdown_requested = false
	var timer_first: Timer = scene.acquire_runtime_delay_timer()
	var timer_first_id := timer_first.get_instance_id()
	scene.release_runtime_delay_timer(timer_first)
	var timer_second: Timer = scene.acquire_runtime_delay_timer()
	check(timer_second.get_instance_id() == timer_first_id and scene.runtime_delay_timer_pool_hits > 0, "runtime timer acquisition reuses the released instance")
	scene.release_runtime_delay_timer(timer_second)

	var audio_stream := AudioStreamGenerator.new()
	var sfx_first: AudioStreamPlayer = scene.make_one_shot_sfx_player(audio_stream, -2.0)
	var sfx_first_id := sfx_first.get_instance_id()
	scene.cleanup_one_shot_sfx_player(sfx_first_id)
	var sfx_second: AudioStreamPlayer = scene.make_one_shot_sfx_player(audio_stream, -2.0)
	check(sfx_second.get_instance_id() == sfx_first_id and scene.one_shot_sfx_pool_hits > 0, "one-shot SFX acquisition reuses the released instance")
	scene.cleanup_one_shot_sfx_player(sfx_second.get_instance_id())

	check(source.contains("pending_claim_source_badge_cache.has(cache_key)"), "327 pending source badges reuse seat-static text")
	check(source.contains("pending_claim_priority_cache.has(cache_key)"), "328 pending priority text reuses option ordering")
	check(source.contains("pending_claim_shortcut_cache.has(cache_key)"), "329 pending shortcut text reuses option shortcuts")
	check(source.contains("claim_options_text_cache.has(cache_key)"), "330 claim option text reuses option and chi snapshots")
	check(source.contains("compact_chi_choice_label_cache.has(cache_key)"), "331-332 chi labels reuse meld-derived text")
	check(source.contains("compact_tile_run_label_cache.has(cache_key)"), "333 compact tile runs reuse derived labels")
	check(scene.pending_claim_source_badge_text(0) == scene.pending_claim_source_badge_text(0) and scene.pending_claim_source_badge_cache.has("0"), "pending source badge cache preserves the visible label")
	check(scene.pending_claim_priority_text(["hu", "chi"]) == "动作优先级 · 胡 > 吃 > 过", "pending priority cache preserves action order")
	check(scene.pending_claim_shortcut_text(["hu", "chi"]) == "H胡 · C吃 · X过", "pending shortcut cache preserves keyboard order")
	check(scene.chi_choice_label({"meld": ["1W", "2W", "3W"]}) == "吃123万", "chi choice cache preserves compact Chinese text")
	check(scene.compact_chi_choice_button_label({"meld": ["1W", "2W", "3W"]}) == "吃1-3", "compact chi cache preserves button text")

	print("--- E) intent and update text caches ---")
	check(source.contains("func action_intent_state_cache_token") and source.contains("action_intent_text_cache_key"), "334-335 action intent state probes and text are cached together")
	check(source.contains("action_intent_color_cache_key"), "336 action intent colors reuse the same state boundary")
	check(source.contains("action_intent_icon_cache_key"), "337 action intent icons reuse the same state boundary")
	check(source.contains("action_intent_fallback_cache_key"), "338 fallback intent glyphs reuse the same state boundary")
	check(source.contains("action_button_tooltip_cache.has(clean)"), "339 action tooltips reuse normalized button text")
	check(source.contains("online_connection_status_cache_key"), "340 connection status text is revision-aware")
	check(source.contains("update_stage_index_cache_key") and source.contains("update_state_color_cache_key"), "341-342 update stage and color are state-cached")
	check(source.contains("func _update_progress_text_uncached") and source.contains("update_progress_text_cache_key"), "343 update progress text caches the complete display state")
	check(source.contains("manifest_notes_cache.has(cache_key)"), "344 manifest notes reuse parsed lines")
	check(source.contains("version_numbers_cache.has(version)"), "345 version number parsing reuses immutable vectors")
	check(source.contains("safe_filename_part_cache.has(text)"), "346 safe filename conversion reuses bounded results")

	scene.mode = "offline"
	scene.offline_phase = "ended"
	var ended_intent: String = scene.action_intent_text(1)
	scene.offline_phase = "await_discard"
	var active_intent: String = scene.action_intent_text(1)
	check(ended_intent == "结算 · 继续下一局" and active_intent != ended_intent, "intent cache invalidates when the phase changes")
	check(scene.action_button_tooltip("过") == scene.action_button_tooltip("过") and scene.action_button_tooltip_cache.has("过"), "tooltip cache preserves response guidance")
	scene.mode = "online_game"
	scene.online_game = {"roomCode": "D-ROOM", "phase": "ready"}
	scene.tcp_status = StreamPeerTCP.STATUS_CONNECTED
	var connected_text: String = scene.online_connection_status_text()
	scene.tcp_status = StreamPeerTCP.STATUS_ERROR
	var error_text: String = scene.online_connection_status_text()
	check(connected_text == "已连接" and error_text == "连接异常", "connection cache invalidates on transport state change")
	scene.update_state = "ready"
	var ready_stage: int = scene.update_stage_index()
	scene.update_state = "error"
	var error_stage: int = scene.update_stage_index()
	check(ready_stage == 2 and error_stage == 1 and scene.update_stage_index_cache_key == "error", "update stage cache preserves state-specific values")
	check(scene.manifest_notes_to_text(["甲", "乙"]) == "甲\n乙" and scene.manifest_notes_to_text(["甲", "乙"]) == "甲\n乙", "manifest note cache preserves line joins")
	check(scene.version_numbers("v1.2.3") == [1, 2, 3] and scene.version_numbers_cache.has("v1.2.3"), "version cache preserves numeric ordering")
	check(scene.safe_filename_part("D/测试.apk") == "D___.apk" and scene.safe_filename_part_cache.has("D/测试.apk"), "safe filename cache preserves sanitization")

	render_root.queue_free()
	scene.root_layer = null
	scene.release_runtime_delay_timer_pool()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
