extends SceneTree

const MainScript := preload("res://scripts/main.gd")

var failed := false

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var scene: MainScript = load("res://Main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	check(scene.app_version() == "1.0.159-godot", "project version matches exported app version")
	check(scene.AUDIO_DEFAULTS_VERSION == "1.0.159-godot", "audio defaults migrate for this release")
	check(not scene.player_ai_assist_enabled(), "offline player side does not enable AI assistance")
	check(scene.UPDATE_MANIFEST_URL == "http://129.146.180.88:18081/YunzhuoMahjongGodot-update.json", "update manifest URL points to live download service")
	check(scene.UPDATE_URL == "http://129.146.180.88:18081/YunzhuoMahjongGodot-v1.0.159-godot.apk", "fallback update APK URL uses this release's immutable APK path")
	check(bool(ProjectSettings.get_setting("audio/general/text_to_speech", false)), "Godot text-to-speech project setting is enabled")
	check(bool(ProjectSettings.get_setting("audio/driver/enable_input", false)), "audio input is enabled for voice features")
	var copied_profile = scene.ai_profile(1)
	copied_profile["attack"] = 9.99
	check(is_equal_approx(scene.ai_profile_value(1, "attack"), 1.02) and scene.ai_profile_label(1) == "守门清" and scene.ai_profile_short_label(2) == "速", "AI profile reads use canonical profiles while public profile copies stay isolated")
	scene.start_offline()
	check(scene.mode == "offline", "starts offline mode")
	check(scene.can_self_discard(), "human can discard after deal")
	check(scene.make_wall().size() == 144, "wall includes eight flowers")
	check(scene.fx_enabled and scene.fx_layer != null and is_instance_valid(scene.fx_layer), "fx animation layer is created and enabled by default")
	var before_fx: bool = scene.fx_enabled
	scene.toggle_fx_setting()
	check(scene.fx_enabled == (not before_fx), "fx setting toggles and persists through the settings path")
	scene.toggle_fx_setting()
	check(scene.fx_enabled == before_fx, "fx setting toggles back to default")
	var fx_rect := scene.root_layer_rect_to_screen_rect_for(Rect2(Vector2(0.0, 0.0), Vector2(1.0, 1.0)), Vector2(1280, 720), Vector4(0, 0, 0, 0))
	check(is_equal_approx(fx_rect.position.x, 0.0) and is_equal_approx(fx_rect.size.x, 1.0), "fx rect conversion maps a full safe-area rect to the full viewport")
	var fx_inset := scene.root_layer_rect_to_screen_rect_for(Rect2(Vector2(0.0, 0.0), Vector2(1.0, 1.0)), Vector2(1280, 720), Vector4(80, 0, 80, 0))
	check(is_equal_approx(fx_inset.position.x, 80.0 / 1280.0) and is_equal_approx(fx_inset.size.x, (1280.0 - 80.0) / 1280.0), "fx rect conversion accounts for left and right safe-area margins")
	var fx_center := scene.root_layer_rect_to_screen_rect_for(Rect2(Vector2(0.5, 0.5), Vector2(0.5, 0.5)), Vector2(1000, 1000), Vector4(0, 0, 0, 0))
	check(is_equal_approx(fx_center.position.x, 0.5) and is_equal_approx(fx_center.position.y, 0.5) and is_equal_approx(fx_center.size.x, 0.5), "fx rect conversion keeps center anchors centered")
	check(scene.tile_index("E") == 27 and scene.tile_sort_index("H1") > scene.tile_index("P"), "tile order cache gives stable fast tile lookup")
	check(scene.tile_metadata_ready and scene.tile_sort_order.has("H8") and scene.tile_label_cache.has("5W"), "tile metadata cache initializes sort order and display labels")
	check(scene.tile_suit_index("5W") == 0 and scene.tile_suit_index("5T") == 1 and scene.tile_suit_index("5B") == 2, "tile metadata cache gives stable fast suit lookup")
	check(scene.is_number_tile("5W") and not scene.is_number_tile("E") and scene.is_honor_tile("E") and scene.is_flower_tile("H1"), "tile metadata cache preserves number honor and flower classification")
	check(scene.TILE_RANK_SPEECH_LABELS.size() == 9 and scene.TILE_RANK_SPEECH_LABELS[4] == "五" and scene.FLOWER_LABELS == ["春", "夏", "秋", "冬", "梅", "兰", "竹", "菊"], "tile metadata uses shared fixed label tables")
	check(scene.is_terminal_or_honor("1W") and scene.is_terminal_or_honor("E") and not scene.is_terminal_or_honor("5W") and scene.is_simple_number_tile("5W") and not scene.is_simple_number_tile("1W"), "tile metadata cache preserves terminal and simple classification")
	check(scene.thirteen_orphans_indices.size() == scene.THIRTEEN_ORPHANS_CODES.size() and scene.is_thirteen_orphans_tile("1W") and scene.is_thirteen_orphans_tile("P") and not scene.is_thirteen_orphans_tile("5W") and not scene.is_thirteen_orphans_tile("H1"), "tile metadata cache preserves thirteen-orphans lookup")
	check(scene.tile_label("5W") == "5万" and scene.tile_speech_label("5W") == "五万" and scene.tile_label("H1") == "春" and scene.tile_face_main("5W") == "5" and scene.tile_face_sub("5W") == "万" and scene.tile_corner("5W") == "5", "tile metadata cache preserves UI and speech labels")
	check(scene.tile_array_key(["3W", "1W", "3W", "E"]) == "1W1,3W2,E1", "small tile array key keeps tile order without dictionary allocation")
	check(scene.tile_array_key(["E", "3W", "1W", "3W"]) == "1W1,3W2,E1", "sparse tile array key is stable for shuffled tiles")
	check(scene.meld_array_key([["3W", "1W", "3W"], ["E", "E", "E"]]) == "1W1,3W2;E3", "meld cache key reuses small tile keys")
	check(scene.counts_compact_key([0, 1, 4, 0]) == "0140" and scene.counts_compact_key([10, 0, 2]) == "1002", "compact count keys use fast digit encoding while preserving multi-digit fallback")
	var empty_counts = scene.make_empty_tile_counts()
	check(empty_counts.size() == scene.TILE_CODES.size() and int(empty_counts[0]) == 0 and int(empty_counts[empty_counts.size() - 1]) == 0, "empty tile count helper builds a fixed zero-filled count array")
	var isolated_empty_counts = scene.make_empty_tile_counts()
	empty_counts[0] = 3
	check(int(isolated_empty_counts[0]) == 0, "empty tile count helper returns isolated copies from the zero template")
	var sample_counts = scene.tile_counts(["1W", "1W", "P"])
	check(int(sample_counts[scene.tile_index("1W")]) == 2 and int(sample_counts[scene.tile_index("P")]) == 1, "tile counts reuse zero-filled count arrays without changing counts")
	var tile_lookup = scene.tile_presence_set(["E", "5W", "E"])
	check(tile_lookup.has("E") and tile_lookup.has("5W") and not tile_lookup.has("9B"), "tile presence set supports repeated wait lookup without rescanning discards")
	scene.players[1]["discards"] = ["5W", "5W"]
	scene.players[2]["melds"] = [["5W", "5W", "5W"]]
	var visible_counts = scene.visible_tile_counts()
	var five_man_index = scene.tile_index("5W")
	check(int(visible_counts[five_man_index]) == scene.visible_tile_count("5W"), "visible tile count cache matches per-tile scan")
	check(scene.visible_tile_count_from_counts("5W", visible_counts) == scene.visible_tile_count("5W"), "visible tile count helper reuses visible count snapshots")
	var cached_visible_metrics = scene.effective_tile_metrics(tenpai_hand(), 0, 0, 0, visible_counts)
	var default_visible_metrics = scene.effective_tile_metrics(tenpai_hand(), 0, 0, 0)
	check(int(cached_visible_metrics.get("count", -1)) == int(default_visible_metrics.get("count", -2)) and cached_visible_metrics.get("tiles", []) == default_visible_metrics.get("tiles", []), "effective tile metrics can reuse visible tile counts")
	var tenpai_counts = scene.tile_counts(tenpai_hand())
	var winning_counts = scene.tile_counts(winning_hand())
	var ai_shape_counts = scene.tile_counts(ai_shape_hand())
	check(scene.NUMBER_SUIT_STARTS == [0, 9, 18] and scene.SHAPE_NEIGHBOR_DELTAS == [-2, -1, 1, 2], "shape scans reuse fixed number-suit and neighbor tables")
	check(scene.TILE_BASE_VALUES.size() == scene.TILE_CODES.size() and is_equal_approx(float(scene.TILE_BASE_VALUES[0]), 4.0) and is_equal_approx(float(scene.TILE_BASE_VALUES[4]), 8.0) and is_equal_approx(float(scene.TILE_BASE_VALUES[27]), 5.0), "tile base values reuse a fixed scoring table")
	check(is_equal_approx(scene.tile_base_value(scene.tile_index("1W")), 4.0) and is_equal_approx(scene.tile_base_value(scene.tile_index("2W")), 6.0) and is_equal_approx(scene.tile_base_value(scene.tile_index("5W")), 8.0) and is_equal_approx(scene.tile_base_value(scene.tile_index("E")), 5.0), "tile base value table preserves terminal simple and honor scoring")
	check(scene.calculate_min_shanten_from_counts(tenpai_counts, 0) == scene.calculate_min_shanten(tenpai_hand(), 0), "count-based shanten matches hand-array shanten")
	check(scene.shanten_memo_key(ai_shape_counts, 1, 2, true) == "1:2:1:" + scene.counts_compact_key(ai_shape_counts), "shanten memo keys reuse the compact count key")
	scene.clear_shanten_cache()
	var first_shape_shanten = scene.calculate_min_shanten_from_counts(ai_shape_counts, 0)
	var shanten_cache_misses_after_first = scene.shanten_cache_misses
	var shanten_cache_hits_after_first = scene.shanten_cache_hits
	check(scene.calculate_min_shanten_from_counts(ai_shape_counts, 0) == first_shape_shanten and scene.shanten_cache_hits > shanten_cache_hits_after_first and scene.shanten_cache_misses == shanten_cache_misses_after_first, "shanten cache still reuses compact keys")
	check(scene.is_complete_hand_from_counts(winning_counts, winning_hand().size(), 0) == scene.is_complete_hand(winning_hand(), 0), "count-based complete hand check matches hand-array path")
	var complete_counts_before = winning_counts.duplicate()
	check(scene.is_standard_complete_from_counts(winning_counts, 4) and winning_counts == complete_counts_before, "standard complete hand search restores count snapshots after in-place recursion")
	var two_set_counts = scene.tile_counts(["1W", "2W", "3W", "E", "E", "E"])
	var two_set_counts_before = two_set_counts.duplicate()
	check(scene.can_form_sets(two_set_counts, 2) and two_set_counts == two_set_counts_before, "set-forming recursion restores count snapshots without per-branch array copies")
	check(is_equal_approx(scene.evaluate_ai_hand_from_counts(ai_shape_counts), scene.evaluate_ai_hand(ai_shape_hand())), "count-based AI hand value matches hand-array path")
	check(is_equal_approx(float(scene.hand_shape_quality_report_from_counts(ai_shape_counts).get("score", 0.0)), float(scene.hand_shape_quality_report(ai_shape_hand()).get("score", 0.0))), "count-based shape quality matches hand-array path")
	check(is_equal_approx(scene.hand_plan_score_from_counts(ai_shape_counts, ai_shape_hand().size()), scene.hand_plan_score(ai_shape_hand())), "count-based hand plan score matches hand-array path")
	var bamboo_plan_features = scene.hand_plan_features_from_counts(scene.tile_counts(["1B", "2B", "3B", "4B", "5B", "E"]), 6)
	check(int(bamboo_plan_features.get("best_suit", -1)) == 2, "hand plan feature scan checks all three number suits")
	check(int(bamboo_plan_features.get("honor_count", 0)) == 1 and int(bamboo_plan_features.get("suit_counts", [])[2]) == 5 and int(bamboo_plan_features.get("suit_rank_masks", [])[2]) == 31, "hand plan feature scan counts simple tiles outside thirteen-orphans tiles")
	check(str(scene.hand_plan_report_from_counts(ai_shape_counts, ai_shape_hand().size()).get("label", "")) == str(scene.hand_plan_report(ai_shape_hand()).get("label", "")), "count-based hand plan report matches hand-array path")
	scene.players[1]["discards"] = []
	scene.players[2]["melds"] = []
	scene.style_cache.clear()
	scene.style_cache_order.clear()
	var rounded_style = scene.style(Color(0.2, 0.3, 0.4, 1.0), 8, Color(0.7, 0.6, 0.3, 1.0), 2)
	var style_cache_size = scene.style_cache.size()
	scene.style(Color(0.2, 0.3, 0.4, 1.0), 8, Color(0.7, 0.6, 0.3, 1.0), 2)
	check(scene.style_cache.size() == style_cache_size, "style cache reuses repeated UI styleboxes")
	check(rounded_style.corner_radius_top_left == 8 and rounded_style.corner_radius_top_right == 8 and rounded_style.corner_radius_bottom_right == 8 and rounded_style.corner_radius_bottom_left == 8 and rounded_style.border_width_left == 2 and rounded_style.border_width_right == 2 and rounded_style.border_width_top == 2 and rounded_style.border_width_bottom == 2, "style helper applies uniform corner radius and border width")
	var shadowless_style = scene.style(Color(0.2, 0.3, 0.4, 1.0), 8, Color(0.7, 0.6, 0.3, 1.0), 2, 0)
	check(shadowless_style.shadow_size == 0 and scene.style_cache.size() == style_cache_size + 1, "style cache keeps shadow variants separate for lightweight UI")
	scene.style_cache.clear()
	scene.style_cache_order.clear()
	scene.button_style_set_cache.clear()
	scene.button_style_set_cache_order.clear()
	var first_button_style_set = scene.button_style_set(Color(0.24, 0.60, 0.45), 12)
	var style_cache_size_after_button_set = scene.style_cache.size()
	var repeated_button_style_set = scene.button_style_set(Color(0.24, 0.60, 0.45), 12)
	check(scene.button_style_set_cache.size() == 1 and style_cache_size_after_button_set == 3 and scene.style_cache.size() == style_cache_size_after_button_set, "button style set cache builds normal hover pressed styles once")
	check(first_button_style_set.has("normal") and first_button_style_set.has("hover") and first_button_style_set.has("pressed") and first_button_style_set["normal"] == repeated_button_style_set["normal"], "button style set cache reuses repeated button styleboxes")
	scene.style_cache.clear()
	scene.style_cache_order.clear()
	scene.button_style_set_cache.clear()
	scene.button_style_set_cache_order.clear()
	var action_style_button = scene.make_action_button("动作", Color(0.25, 0.58, 0.48), func() -> void:
		pass
	)
	check(scene.button_style_set_cache.size() == 1 and scene.style_cache.size() == 3, "action buttons build one compact style set without small-button leftovers")
	action_style_button.queue_free()
	scene.style_cache.clear()
	scene.style_cache_order.clear()
	scene.button_style_set_cache.clear()
	scene.button_style_set_cache_order.clear()
	var top_style_button = scene.make_top_hud_button("设置", Color(0.22, 0.42, 0.54), func() -> void:
		pass
	)
	check(scene.button_style_set_cache.size() == 1 and scene.style_cache.size() == 3, "top HUD buttons build only their compact style set")
	top_style_button.queue_free()
	var report_sort = [
		{"tile": "3W", "score": 10.0},
		{"tile": "2W", "score": 20.0},
		{"tile": "1W", "score": 20.0},
	]
	scene.sort_ai_discard_reports(report_sort)
	check(str(report_sort[0].get("tile", "")) == "1W" and str(report_sort[1].get("tile", "")) == "2W", "AI discard report sort runs once and keeps tile-order tie breaks")
	var effective_sort: Array[String] = ["3W", "1W", "2W"]
	scene.sort_effective_tiles_by_remaining(effective_sort, {"1W": 1, "2W": 4, "3W": 4})
	check(effective_sort == ["2W", "3W", "1W"], "effective tile sort preserves remaining-count priority")
	scene.clear_ai_report_cache()
	var ai_report_hand_before = scene.players[0]["hand"].duplicate()
	var first_reports = scene.get_ai_discard_reports(0)
	var first_misses = scene.ai_report_cache_misses
	check(scene.same_tile_list(scene.players[0]["hand"], ai_report_hand_before), "AI discard report generation reuses working hand arrays without mutating the player hand")
	var cached_reports = scene.get_ai_discard_reports(0)
	check(scene.ai_report_cache_hits >= 1 and scene.ai_report_cache_misses == first_misses, "AI discard reports reuse cache on repeated render state")
	if not cached_reports.is_empty() and typeof(cached_reports[0]) == TYPE_DICTIONARY:
		cached_reports[0]["tile"] = "ZZ"
	var refreshed_reports = scene.get_ai_discard_reports(0)
	check(not refreshed_reports.is_empty() and str(refreshed_reports[0].get("tile", "")) != "ZZ" and not first_reports.is_empty(), "AI report cache returns cheap isolated top-level copies")
	var nested_cache_report := {
		"tile": "1W",
		"effective_tiles": ["2W"],
		"effective_remaining": {"2W": 4},
		"feed_report": {"score": 1.0, "details": [{"opponent": 1, "score": 2.0}]},
		"danger_source": {"opponent": 1},
		"wait_self_discarded": ["3W"],
	}
	scene.store_ai_report_cache("nested-copy-test", [nested_cache_report])
	var source_effective_tiles: Array = nested_cache_report.get("effective_tiles", [])
	var source_effective_remaining: Dictionary = nested_cache_report.get("effective_remaining", {})
	var source_feed_report: Dictionary = nested_cache_report.get("feed_report", {})
	var source_feed_details: Array = source_feed_report.get("details", [])
	var source_danger: Dictionary = nested_cache_report.get("danger_source", {})
	var source_self_discarded: Array = nested_cache_report.get("wait_self_discarded", [])
	var source_feed_detail: Dictionary = source_feed_details[0] if not source_feed_details.is_empty() and typeof(source_feed_details[0]) == TYPE_DICTIONARY else {}
	source_effective_tiles[0] = "ZZ"
	source_effective_remaining["2W"] = 0
	if not source_feed_detail.is_empty():
		source_feed_detail["opponent"] = 9
	source_danger["opponent"] = 9
	source_self_discarded[0] = "ZZ"
	var stored_nested_reports: Array = scene.ai_report_cache.get("nested-copy-test", [])
	var stored_nested_report: Dictionary = stored_nested_reports[0] if not stored_nested_reports.is_empty() and typeof(stored_nested_reports[0]) == TYPE_DICTIONARY else {}
	var stored_effective_tiles: Array = stored_nested_report.get("effective_tiles", [])
	var stored_effective_remaining: Dictionary = stored_nested_report.get("effective_remaining", {})
	var stored_feed_report: Dictionary = stored_nested_report.get("feed_report", {})
	var stored_feed_details: Array = stored_feed_report.get("details", [])
	var stored_feed_detail: Dictionary = stored_feed_details[0] if not stored_feed_details.is_empty() and typeof(stored_feed_details[0]) == TYPE_DICTIONARY else {}
	var stored_danger: Dictionary = stored_nested_report.get("danger_source", {})
	var stored_self_discarded: Array = stored_nested_report.get("wait_self_discarded", [])
	var nested_copy_ok = not stored_effective_tiles.is_empty() and str(stored_effective_tiles[0]) == "2W"
	nested_copy_ok = nested_copy_ok and int(stored_effective_remaining.get("2W", 0)) == 4
	nested_copy_ok = nested_copy_ok and int(stored_feed_detail.get("opponent", -1)) == 1
	nested_copy_ok = nested_copy_ok and int(stored_danger.get("opponent", -1)) == 1
	nested_copy_ok = nested_copy_ok and not stored_self_discarded.is_empty() and str(stored_self_discarded[0]) == "3W"
	check(nested_copy_ok, "AI report cache stores targeted nested copies for mutable report fields")
	var ui_report_copy = scene.duplicate_ai_report(nested_cache_report, true)
	var ui_copy_effective_tiles: Array = ui_report_copy.get("effective_tiles", [])
	var ui_copy_feed_report: Dictionary = ui_report_copy.get("feed_report", {})
	var ui_copy_feed_details: Array = ui_copy_feed_report.get("details", [])
	if not ui_copy_effective_tiles.is_empty():
		ui_copy_effective_tiles[0] = "YY"
	if not ui_copy_feed_details.is_empty() and typeof(ui_copy_feed_details[0]) == TYPE_DICTIONARY:
		var ui_copy_feed_detail: Dictionary = ui_copy_feed_details[0]
		ui_copy_feed_detail["opponent"] = 8
	check(str(source_effective_tiles[0]) == "ZZ" and int(source_feed_detail.get("opponent", -1)) == 9, "UI AI report copies protect targeted nested fields without recursive deep copy")
	scene.clear_ai_report_cache()
	var ai_visible_counts = scene.visible_tile_counts()
	var ai_eval_context = scene.make_ai_evaluation_context(0, ai_visible_counts)
	var baseline_risk = scene.tile_risk_vector("5W", 0, ai_visible_counts)
	var cached_risk = scene.tile_risk_vector("5W", 0, ai_visible_counts, ai_eval_context)
	check(is_equal_approx(float(baseline_risk.get("score", 0.0)), float(cached_risk.get("score", 0.0))) and is_equal_approx(float(baseline_risk.get("threat", 0.0)), float(cached_risk.get("threat", 0.0))), "AI risk context preserves baseline risk math")
	var risk_cache: Dictionary = ai_eval_context.get("risk_vectors", {})
	var risk_cache_size = risk_cache.size()
	scene.tile_risk_vector("5W", 0, ai_visible_counts, ai_eval_context)
	check(risk_cache.size() == risk_cache_size and risk_cache_size >= 1, "AI risk context reuses per-tile vector cache")
	var base_pressure = scene.discard_pressure_score("5W", 0, ai_visible_counts)
	var cached_pressure = scene.discard_pressure_score("5W", 0, ai_visible_counts, ai_eval_context)
	check(is_equal_approx(base_pressure, cached_pressure), "AI pressure context preserves baseline pressure score")
	var pressure_cache: Dictionary = ai_eval_context.get("discard_pressures", {})
	var pressure_cache_size = pressure_cache.size()
	scene.discard_pressure_score("5W", 0, ai_visible_counts, ai_eval_context)
	var safety_label = scene.tile_safety_label("5W", 0, ai_visible_counts, ai_eval_context)
	var safety_cache: Dictionary = ai_eval_context.get("safety_labels", {})
	var safety_cache_size = safety_cache.size()
	check(str(scene.tile_safety_label("5W", 0, ai_visible_counts, ai_eval_context)) == safety_label and safety_cache.size() == safety_cache_size, "AI safety label context reuses one generated cache key")
	var feed_report_contextual = scene.discard_feed_risk_report("5W", 0, ai_visible_counts, ai_eval_context)
	var feed_cache: Dictionary = ai_eval_context.get("feed_reports", {})
	var feed_cache_size = feed_cache.size()
	var cached_feed_report_contextual = scene.discard_feed_risk_report("5W", 0, ai_visible_counts, ai_eval_context)
	check(pressure_cache.size() == pressure_cache_size and feed_cache.size() == feed_cache_size and is_equal_approx(float(cached_feed_report_contextual.get("score", -1.0)), float(feed_report_contextual.get("score", -2.0))), "AI pressure and feed contexts reuse generated cache keys")
	for code in scene.TILE_CODES + scene.FLOWER_CODES:
		check(FileAccess.file_exists(scene.tile_path(str(code))), "tile asset exists: " + str(code))
		check(scene.tile_textures.get(str(code), null) != null, "tile texture loads: " + str(code))
	for audio_key in ["bgm", "discard", "draw", "peng", "gang", "win"]:
		check(scene.audio_streams.get(audio_key, null) != null, "audio stream loads: " + str(audio_key))
	for voice_key in ["tile_5W", "tile_E", "tile_P", "action_peng", "action_zimo"]:
		check(scene.voice_streams.get(voice_key, null) != null, "bundled voice stream loads: " + str(voice_key))
	check(scene.bgm_player != null and scene.sfx_player != null and scene.action_sfx_player != null, "audio players are initialized")
	check(scene.audio_layer != null and scene.bgm_player.get_parent() == scene.audio_layer, "persistent audio layer owns background music")
	check(scene.BGM_STREAM_PATH.ends_with("bgm_guofeng2.mp3") and scene.audio_streams.get("bgm", null) is AudioStreamMP3, "background music uses the current MP3 default track")
	var bgm_mp3 = scene.bgm_player.stream as AudioStreamMP3
	check(bgm_mp3 != null and bgm_mp3.loop, "background music loops without restart gaps")
	check(scene.BGM_VOLUME_DB == 0.0, "background music keeps the configured default gain")
	check(scene.boosted_sfx_volume_db(-8.0) <= -5.0 and scene.boosted_sfx_volume_db(-1.0) <= 1.5, "mobile sfx boost is capped below clipping")
	check(scene.is_action_sfx("gang") and not scene.is_action_sfx("discard"), "frequent tile sfx reuse the persistent tile player")
	check(scene.voice_clip_key_for_tile("5W") == "tile_5W" and scene.voice_clip_key_for_action("暗杠") == "action_hidden_gang", "bundled voice clip keys cover tile and action speech")
	var one_shot_sfx = scene.make_one_shot_sfx_player(scene.audio_streams.get("discard", null), -1.0)
	check(one_shot_sfx.stream != null and one_shot_sfx.bus == "Master" and one_shot_sfx.process_mode == Node.PROCESS_MODE_ALWAYS and one_shot_sfx.get_parent() == scene.audio_layer, "one-shot sfx players use persistent game audio bus")
	var scaled_safe_margins = scene.safe_area_margins_for_viewport(Vector2(1280, 720), Vector2(2560, 1440), Rect2(Vector2(120, 48), Vector2(2320, 1320)))
	check(is_equal_approx(scaled_safe_margins.x, 60.0) and is_equal_approx(scaled_safe_margins.y, 24.0) and is_equal_approx(scaled_safe_margins.z, 60.0) and is_equal_approx(scaled_safe_margins.w, 36.0), "safe-area margins scale physical Android insets into stretched viewport space")
	var clamped_safe_margins = scene.safe_area_margins_for_viewport(Vector2(1280, 720), Vector2(1280, 720), Rect2(Vector2(500, 200), Vector2(100, 100)))
	check(clamped_safe_margins.x <= 1280.0 * scene.SAFE_CONTENT_MAX_SIDE_FRACTION + 0.5 and clamped_safe_margins.y <= 720.0 * scene.SAFE_CONTENT_MAX_TOP_FRACTION + 0.5 and clamped_safe_margins.w <= 720.0 * scene.SAFE_CONTENT_MAX_BOTTOM_FRACTION + 0.5, "safe-area margins are clamped to preserve usable table space")
	check(scene.safe_content_pixel_size_for_margins(Vector2(1280, 720), scene.SAFE_CONTENT_MIN_MARGIN) == Vector2(1256, 702), "safe content size subtracts minimum touch-edge margins")
	scene.clear_screen()
	check(is_instance_valid(one_shot_sfx) and not one_shot_sfx.is_queued_for_deletion(), "screen redraw keeps active one-shot audio alive")
	check(scene.screen_layer != null and scene.root_layer != null and scene.root_layer.get_parent() == scene.screen_layer, "screen redraw separates full-bleed background from safe content layer")
	check(is_equal_approx(scene.root_layer.offset_left, scene.safe_area_margins.x) and is_equal_approx(scene.root_layer.offset_top, scene.safe_area_margins.y) and is_equal_approx(scene.root_layer.offset_right, -scene.safe_area_margins.z) and is_equal_approx(scene.root_layer.offset_bottom, -scene.safe_area_margins.w), "safe content layer applies display safe-area offsets")
	one_shot_sfx.queue_free()
	check(not scene.android_tts_runtime_available(), "headless smoke test does not enter Android TTS path")
	check(not scene.speech_backend_ready(), "headless smoke test does not report TTS backend ready")
	scene.audio_touch_unlocked = false
	scene.wake_audio_from_interaction()
	check(scene.audio_touch_unlocked, "touch interaction unlocks audio startup path")
	check(scene.tile_speech_label("5W") == "五万" and scene.tile_speech_label("7T") == "七条", "number tile speech names are localized")
	check(scene.tile_speech_label("P") == "白板" and scene.tile_speech_label("F") == "发财", "honor tile speech names are complete")
	check(scene.tts_voice_identifier({"id": "zh-cn-default", "name": "fallback"}) == "zh-cn-default", "tts voice dictionaries use stable ids")
	scene.speech_queue.clear()
	scene.speech_queue_active = false
	scene.speak_tile_call("5W")
	check(scene.speech_queue.size() == 1 and str(scene.speech_queue[0].get("text", "")) == "五万", "tile speech is queued before TTS playback")
	check(float(scene.speech_queue[0].get("delay", 1.0)) <= 0.13, "tile speech is queued after the discard sound without being dropped")
	scene.speech_queue.clear()
	check(is_equal_approx(scene.AI_DRAW_DELAY_SECONDS, 0.35) and is_equal_approx(scene.AI_DISCARD_DELAY_SECONDS, 0.35) and is_equal_approx(scene.HUMAN_DRAW_DELAY_SECONDS, 0.006), "turn decision delays are tuned for faster operation")
	check(is_equal_approx(scene.HUMAN_DISCARD_RESPONSE_GAP_SECONDS, 0.01) and is_equal_approx(scene.AI_RETURN_TO_HUMAN_GAP_SECONDS, 0.08), "human discard feedback and AI return-to-human gaps stay short")
	check(is_equal_approx(scene.AI_ACTION_GAP_SECONDS, 0.35) and scene.AI_ACTION_GAP_SECONDS >= scene.SPEECH_TILE_DELAY_SECONDS + 0.12, "AI visible action gap gives discard audio room without making play feel stalled")
	check(scene.UI_RENDER_MIN_INTERVAL_MSEC == 16, "AI action redraws are coalesced to reduce stutter")
	check(scene.ONLINE_POLL_INTERVAL_MSEC >= 16 and scene.ONLINE_POLL_INTERVAL_MSEC <= 50, "online polling is throttled without adding visible input lag")
	check(scene.UPDATE_PROGRESS_INTERVAL_MSEC >= 80 and scene.UPDATE_PROGRESS_INTERVAL_MSEC <= 200, "download progress UI refresh is throttled to avoid per-frame churn")
	scene.mode = "menu"
	scene.next_online_poll_msec = 0
	scene.poll_online(1000)
	check(scene.next_online_poll_msec == 0, "offline frames skip online poll scheduling")
	scene.mode = "online_lobby"
	scene.next_online_poll_msec = 1050
	scene.poll_online(1000)
	check(scene.next_online_poll_msec == 1050, "online polling skips frames before the throttle window")
	scene.poll_online(1050)
	check(scene.next_online_poll_msec == 1050 + scene.ONLINE_POLL_INTERVAL_MSEC, "online polling advances the throttle window when due")
	scene.mode = "offline"
	scene.update_state = "downloading"
	scene.next_update_progress_msec = 1100
	scene.update_download_progress(1000)
	check(scene.next_update_progress_msec == 1100, "download progress skips frames before the refresh window")
	scene.update_download_progress(1100)
	check(scene.next_update_progress_msec == 1100 + scene.UPDATE_PROGRESS_INTERVAL_MSEC, "download progress advances the refresh window when due")
	scene.update_state = "idle"
	scene.game_render_queued = false
	check(not scene.should_yield_before_ai_discard(), "AI skips pre-discard frame yield when no render is queued")
	scene.game_render_queued = true
	check(scene.should_yield_before_ai_discard(), "AI yields before discard only when a coalesced render is queued")
	scene.game_render_queued = false
	scene.music_enabled = true
	scene.sfx_enabled = true
	scene.tts_enabled = true
	scene.fast_mode_enabled = true
	check(scene.ai_draw_delay() == scene.AI_DRAW_DELAY_SECONDS and scene.ai_discard_delay() == scene.AI_DISCARD_DELAY_SECONDS and scene.ai_action_gap_delay() == scene.AI_ACTION_GAP_SECONDS and scene.human_discard_response_gap_delay() == scene.HUMAN_DISCARD_RESPONSE_GAP_SECONDS and scene.ai_return_to_human_gap_delay() == scene.AI_RETURN_TO_HUMAN_GAP_SECONDS, "fast mode uses short decision delays with audible AI action pacing")
	scene.fast_mode_enabled = false
	check(is_equal_approx(scene.ai_draw_delay(), 0.18) and is_equal_approx(scene.ai_discard_delay(), 0.35) and is_equal_approx(scene.ai_action_gap_delay(), 0.35) and is_equal_approx(scene.human_discard_response_gap_delay(), 0.05) and is_equal_approx(scene.ai_return_to_human_gap_delay(), 0.12) and is_equal_approx(scene.human_draw_delay(), 0.08), "steady mode uses the configured readable delays")
	scene.music_enabled = false
	scene.sfx_enabled = false
	scene.tts_enabled = false
	scene.fast_mode_enabled = false
	scene.save_settings()
	scene.music_enabled = true
	scene.sfx_enabled = true
	scene.tts_enabled = true
	scene.fast_mode_enabled = true
	scene.load_settings()
	check(not scene.music_enabled and not scene.sfx_enabled and not scene.tts_enabled and not scene.fast_mode_enabled, "settings persist audio and speed toggles")
	scene.music_enabled = true
	scene.sfx_enabled = true
	scene.tts_enabled = true
	scene.fast_mode_enabled = true
	scene.save_settings()
	var setting_button = scene.make_setting_button("音乐", true, Callable())
	check(setting_button.text == "音乐开", "setting button labels enabled state")
	check(setting_button.action_mode == BaseButton.ACTION_MODE_BUTTON_PRESS, "setting buttons trigger on press for mobile responsiveness")
	check(not setting_button.button_down.is_connected(scene.wake_audio_from_interaction), "touch buttons rely on global input to wake audio")
	setting_button.queue_free()
	var label_parent = Control.new()
	root.add_child(label_parent)
	var default_label = scene.make_label(label_parent, "普通 UI 标签", 16, Color.WHITE, false)
	check(default_label.autowrap_mode == TextServer.AUTOWRAP_OFF, "default labels avoid automatic wrapping for cheaper UI layout")
	check(default_label.mouse_filter == Control.MOUSE_FILTER_IGNORE and labels_ignore_mouse(label_parent), "default labels skip mouse hit testing")
	label_parent.queue_free()
	var form_label_parent = VBoxContainer.new()
	root.add_child(form_label_parent)
	var form_edit = scene.add_line_edit(form_label_parent, "昵称", "云桌道友")
	check(form_edit is LineEdit and labels_ignore_mouse(form_label_parent), "line-edit captions skip mouse hit testing")
	form_label_parent.queue_free()
	var panel_parent = Control.new()
	root.add_child(panel_parent)
	var decorative_panel = scene.make_panel(panel_parent, scene.rect_full(0.1, 0.1, 0.9, 0.9), Color(0.1, 0.2, 0.3), 8, Color(0.4, 0.5, 0.6))
	check(decorative_panel.mouse_filter == Control.MOUSE_FILTER_IGNORE and panels_ignore_mouse(panel_parent), "decorative panels skip mouse hit testing")
	check(panel_shadow_size(decorative_panel) == 4, "default panels keep depth shadow unless marked lightweight")
	panel_parent.queue_free()
	var passive_row = HBoxContainer.new()
	scene.configure_passive_container(passive_row)
	check(passive_row.mouse_filter == Control.MOUSE_FILTER_IGNORE, "passive container helper skips mouse hit testing")
	passive_row.queue_free()
	var background_parent = Control.new()
	root.add_child(background_parent)
	scene.add_background(background_parent)
	check(count_texture_rects(background_parent) >= 1 and texture_rects_ignore_mouse(background_parent), "decorative background textures skip mouse hit testing")
	check(count_color_rects(background_parent) >= 3 and color_rects_ignore_mouse(background_parent), "decorative background color overlays skip mouse hit testing")
	background_parent.queue_free()
	var decorative_texture_parent = Control.new()
	root.add_child(decorative_texture_parent)
	var decorative_texture = scene.add_texture(decorative_texture_parent, scene.wood_texture, scene.rect_full(0.0, 0.0, 1.0, 1.0), 0.5)
	check(decorative_texture.mouse_filter == Control.MOUSE_FILTER_IGNORE, "decorative table textures skip mouse hit testing")
	decorative_texture_parent.queue_free()
	var quick_press_count := {"value": 0}
	var quick_button = scene.make_small_button("快按", Color(0.24, 0.60, 0.45), func() -> void:
		quick_press_count["value"] = int(quick_press_count.get("value", 0)) + 1
	)
	quick_button.emit_signal("button_down")
	check(int(quick_press_count.get("value", 0)) == 1, "buttons run callbacks on button down for mobile responsiveness")
	quick_button.queue_free()
	var hud_press_count := {"value": 0}
	var top_button = scene.make_top_hud_button("设置", Color(0.22, 0.42, 0.54), func() -> void:
		hud_press_count["value"] = int(hud_press_count.get("value", 0)) + 1
	)
	check(top_button.custom_minimum_size == scene.TOP_HUD_BUTTON_SIZE and top_button.clip_text, "top HUD buttons keep mobile touch target and clipped labels")
	top_button.emit_signal("button_down")
	check(int(hud_press_count.get("value", 0)) == 1, "top HUD buttons trigger on button down")
	top_button.queue_free()
	var menu_press_count := {"value": 0}
	var menu_card = scene.make_menu_card("测试", Color(0.30, 0.50, 0.70), func() -> void:
		menu_press_count["value"] = int(menu_press_count.get("value", 0)) + 1
	)
	menu_card.emit_signal("button_down")
	check(int(menu_press_count.get("value", 0)) == 1, "menu cards run callbacks on button down")
	menu_card.queue_free()
	var settings_parent = Control.new()
	root.add_child(settings_parent)
	scene.settings_panel_open = true
	scene.draw_settings_overlay(settings_parent)
	check(settings_parent.get_child_count() == 1 and has_button_text(settings_parent, "音乐开") and has_button_text(settings_parent, "快速开") and has_button_text(settings_parent, "试音"), "settings overlay renders toggle and test-audio buttons")
	check(panels_ignore_mouse(settings_parent), "settings overlay panels skip mouse hit testing while buttons remain interactive")
	check(containers_ignore_mouse(settings_parent), "settings overlay layout containers skip mouse hit testing")
	settings_parent.queue_free()
	scene.settings_panel_open = false
	var ornament_parent = Control.new()
	root.add_child(ornament_parent)
	check(scene.TABLE_ORNAMENT_EDGES.size() == 4 and scene.TABLE_CORNER_RECTS.size() == 4, "table ornaments reuse fixed geometry constants")
	check(scene.TABLE_ORNAMENT_EDGES[0][0] is Rect2 and scene.TABLE_ORNAMENT_EDGES[0][1] is Color, "table ornament constants keep precomputed rect and color data")
	scene.draw_table_ornaments(ornament_parent)
	check(count_panel_shadow_size(ornament_parent, 0) >= 12, "table ornaments use shadowless panels for cheaper rendering")
	ornament_parent.queue_free()
	var dice_parent = Control.new()
	root.add_child(dice_parent)
	scene.draw_dice_dot(dice_parent, 0.5, 0.5)
	check(count_panel_shadow_size(dice_parent, 0) == 1, "dice dots use shadowless panels for cheaper rendering")
	dice_parent.queue_free()
	var previous_phase = scene.offline_phase
	var previous_summary = scene.round_summary
	var previous_hand_number = scene.offline_hand_number
	scene.offline_phase = "ended"
	scene.offline_hand_number = 1
	scene.round_summary = "超长顶部状态文本用于验证HUD不会自动换行挤压分数和按钮区域"
	var hud_parent = Control.new()
	root.add_child(hud_parent)
	scene.draw_game_top_hud(hud_parent)
	var hud_panel = hud_parent.get_child(0) as Control if hud_parent.get_child_count() > 0 else null
	check(control_anchor_rect_matches(hud_panel, scene.TOP_HUD_RECT), "top HUD root uses fixed geometry constants")
	check(label_is_clipped(first_label_containing_text(hud_parent, "超长顶部状态文本")), "top HUD status clips long text instead of wrapping")
	check(label_is_clipped(first_label_containing_text(hud_parent, "余")), "top HUD wall summary clips inside its slot")
	check(control_anchor_rect_matches(first_label_containing_text(hud_parent, "单机修炼场"), scene.TOP_HUD_TITLE_RECT), "top HUD title uses fixed geometry constants")
	check(control_anchor_rect_matches(first_label_containing_text(hud_parent, "超长顶部状态文本"), scene.TOP_HUD_STATUS_RECT), "top HUD status uses fixed geometry constants")
	check(control_anchor_rect_matches(first_label_containing_text(hud_parent, "余"), scene.TOP_HUD_WALL_RECT), "top HUD wall summary uses fixed geometry constants")
	var hud_settings_button = first_button_with_text(hud_parent, "设置")
	check(hud_settings_button != null and hud_settings_button.custom_minimum_size == scene.TOP_HUD_BUTTON_SIZE, "rendered top HUD buttons use enlarged touch targets")
	check(control_anchor_rect_matches(hud_settings_button, scene.TOP_HUD_SETTINGS_BUTTON_RECT), "top HUD settings button uses fixed geometry constants")
	check(control_anchor_rect_matches(first_button_with_text(hud_parent, "返回"), scene.TOP_HUD_BACK_BUTTON_RECT), "top HUD back button uses fixed geometry constants")
	check(control_anchor_rect_matches(first_button_with_text(hud_parent, "更新"), scene.TOP_HUD_UPDATE_BUTTON_RECT), "top HUD update button uses fixed geometry constants")
	hud_parent.queue_free()
	scene.offline_phase = previous_phase
	scene.round_summary = previous_summary
	scene.offline_hand_number = previous_hand_number
	var avatar = scene.make_avatar_view(1, true)
	check(has_label_text(avatar, "南") and has_label_text(avatar, "行牌"), "seat avatar renders active 2D identity")
	check(not contains_subviewport(avatar), "seat avatar avoids expensive SubViewport rendering")
	avatar.queue_free()
	check(scene.tile_textures.get("E", null) != scene.tile_back and scene.tile_textures.get("H1", null) != scene.tile_back, "wind and flower textures do not fall back to tile back")
	var east_tile_view = scene.make_tile_view("E", Vector2(62, 84), false, Callable())
	check(east_tile_view.custom_minimum_size == Vector2(62, 84), "wind tile view keeps requested size")
	check(tile_view_inner_frame_is_fixed(east_tile_view, Vector2(62, 84)), "wind tile inner frame stays fixed when parent stretches")
	check(first_button(east_tile_view) == null, "static tile views avoid button nodes")
	check(has_visible_tile_art(east_tile_view), "wind tile view renders real tile art inside fixed frame")
	check(not has_label_text(east_tile_view, "东") and not has_label_text(east_tile_view, "风"), "wind tile view uses real art without duplicate code-drawn labels")
	check(tile_texture_rects_are_bounded(east_tile_view), "wind tile texture ignores source pixel size")
	east_tile_view.queue_free()
	var number_tile_view = scene.make_tile_view("5W", Vector2(62, 84), false, Callable())
	check(has_visible_tile_art(number_tile_view), "number tile view renders real tile art inside fixed frame")
	check(not has_label_text(number_tile_view, "5") and not has_label_text(number_tile_view, "万") and count_label_nodes(number_tile_view) == 0, "number tile view avoids duplicate numeric labels when tile art exists")
	check(tile_view_inner_frame_is_fixed(number_tile_view, Vector2(62, 84)), "number tile inner frame stays fixed")
	number_tile_view.queue_free()
	var small_static_tile_view = scene.make_tile_view("5W", Vector2(38, 52), false, Callable())
	check(small_static_tile_view is Panel and small_static_tile_view.custom_minimum_size == Vector2(38, 52), "small static tile uses panel root without wrapper node")
	check(has_visible_tile_art(small_static_tile_view), "small static tile renders real tile art instead of text-only fallback")
	check(not has_label_text(small_static_tile_view, "5万") and count_label_nodes(small_static_tile_view) == 0, "small static tile avoids duplicate text when tile art exists")
	check(count_control_nodes(small_static_tile_view) == 2, "small static tile keeps only root panel and texture controls")
	check(count_texture_rects(small_static_tile_view) == 1, "small static tile uses one bounded texture node for discard readability")
	check(count_color_rects(small_static_tile_view) == 0, "small static tile skips decorative shade nodes for render performance")
	check(panel_shadow_size(small_static_tile_view) == 0, "small static tile skips panel shadow for render performance")
	small_static_tile_view.queue_free()
	var tile_press_count := {"value": 0}
	var clickable_tile_view = scene.make_tile_view("6W", Vector2(62, 84), true, func() -> void:
		tile_press_count["value"] = int(tile_press_count.get("value", 0)) + 1
	)
	var clickable_tile_button = first_button(clickable_tile_view)
	check(clickable_tile_button != null, "clickable tile contains a button")
	clickable_tile_button.emit_signal("button_down")
	check(int(tile_press_count.get("value", 0)) == 1, "tile callbacks run on button down")
	check(count_label_nodes(clickable_tile_view) == 0, "clickable tile uses real tile art without duplicate code-drawn labels")
	clickable_tile_view.queue_free()
	var flower_tile_view = scene.make_tile_view("H1", Vector2(62, 84), false, Callable())
	check(has_visible_tile_art(flower_tile_view), "flower tile view renders real tile art inside fixed frame")
	check(not has_label_text(flower_tile_view, "春") and not has_label_text(flower_tile_view, "花"), "flower tile view uses real art without duplicate code-drawn labels")
	check(tile_texture_rects_are_bounded(flower_tile_view), "flower tile texture keeps stable bounds")
	flower_tile_view.queue_free()
	var missing_tile_view = scene.make_tile_view("ZZ", Vector2(62, 84), false, Callable())
	check(count_label_nodes(missing_tile_view) == 0 and count_texture_rects(missing_tile_view) == 0, "missing tile art does not fall back to text-only rendering")
	missing_tile_view.queue_free()
	var wall_back_view = scene.make_wall_back_tile()
	check(wall_back_view.custom_minimum_size == scene.WALL_BACK_TILE_SIZE, "wall back tile has compact fixed size")
	check(has_label_text(wall_back_view, "云"), "wall back tile has visible compact mark")
	check(tile_texture_rects_are_bounded(wall_back_view), "wall back texture ignores 600x800 source size")
	wall_back_view.queue_free()
	var wall_layout_parent = Control.new()
	root.add_child(wall_layout_parent)
	check(scene.WALL_LAYOUTS.size() == 4 and int(scene.WALL_LAYOUTS[0][2]) == 16 and int(scene.WALL_LAYOUTS[2][2]) == 12, "wall layout reuses fixed geometry constants")
	scene.draw_walls(wall_layout_parent)
	check(wall_layout_parent.get_child_count() == scene.WALL_LAYOUTS.size() and count_descendants(wall_layout_parent) == scene.WALL_LAYOUTS.size(), "wall layout uses four self-drawing strips instead of per-tile nodes")
	check(count_texture_rects(wall_layout_parent) == 0, "wall layout uses self-drawn backs without per-tile textures")
	wall_layout_parent.queue_free()
	check(scene.DISCARD_ZONES.size() == 4 and int(scene.DISCARD_ZONES[0][0]) == 0 and int(scene.DISCARD_ZONES[0][2]) == 10, "discard layout reuses fixed geometry constants")
	check(scene.TABLE_OUTER_RECT == scene.rect_full(0.145, 0.108, 0.855, 0.765) and scene.TABLE_INNER_RECT == scene.rect_full(0.045, 0.055, 0.955, 0.945), "main table panel layout reuses fixed geometry constants")
	check(scene.TABLE_OUTER_TEXTURE_RECT == scene.rect_full(0.008, 0.012, 0.992, 0.988) and scene.TABLE_INNER_TEXTURE_RECT == scene.rect_full(0.012, 0.016, 0.988, 0.984), "main table texture layout reuses fixed geometry constants")
	check(scene.SEAT_LAYOUTS.size() == 4 and int(scene.SEAT_LAYOUTS[0][0]) == 2 and str(scene.SEAT_LAYOUTS[3][2]) == "bottom", "seat layout reuses fixed geometry constants")
	check(scene.CENTER_WIND_LABELS == ["东", "南", "西", "北"], "center wind labels reuse fixed order constants")
	check(scene.CENTER_WIND_RECTS.size() == 4, "center wind label rects reuse fixed layout constants")
	check(scene.CENTER_DICE_DOT_POINTS.size() == 4 and scene.CENTER_DICE_DOT_POINTS[0] == Vector2(0.35, 0.32), "center dice dots reuse fixed layout constants")
	check(scene.CENTER_DICE_DOT_RECTS.size() == 4 and scene.CENTER_DICE_DOT_RECTS[0] == scene.rect_full(0.332, 0.302, 0.368, 0.338), "center dice dots reuse precomputed anchor rects")
	var bottom_discard_zone = scene.rect_full(0.285, 0.585, 0.715, 0.825)
	var discard_table_size = scene.game_table_pixel_size()
	check(scene.discard_zone_pixel_size_for_table_size(bottom_discard_zone, discard_table_size) == scene.discard_zone_pixel_size(bottom_discard_zone), "discard zone pixel sizing can reuse cached table size")
	var bottom_discard_rows = scene.discard_zone_visible_rows(bottom_discard_zone, 10)
	check(scene.discard_zone_visible_rows_for_table_size(bottom_discard_zone, 10, discard_table_size) == bottom_discard_rows, "discard row sizing can reuse cached table size")
	var bottom_discard_tile_size = scene.discard_zone_tile_size(bottom_discard_zone, 10, bottom_discard_rows)
	check(scene.discard_zone_tile_size_for_table_size(bottom_discard_zone, 10, bottom_discard_rows, discard_table_size) == bottom_discard_tile_size, "discard tile sizing can reuse cached table size")
	check(scene.discard_grid_fits_zone(bottom_discard_zone, 10, bottom_discard_rows, bottom_discard_tile_size), "bottom discard grid sizes tiles to stay inside table zone")
	check(scene.discard_grid_fits_zone_for_table_size(bottom_discard_zone, 10, bottom_discard_rows, bottom_discard_tile_size, discard_table_size), "discard grid fit checks can reuse cached table size")
	check(bottom_discard_tile_size.x < scene.DISCARD_TILE_MAX_SIZE.x and bottom_discard_tile_size.y < scene.DISCARD_TILE_MAX_SIZE.y, "bottom discard grid shrinks compact tiles instead of overflowing")
	var side_discard_zone = scene.rect_full(0.135, 0.315, 0.300, 0.705)
	var side_discard_rows = scene.discard_zone_visible_rows(side_discard_zone, 4)
	var side_discard_tile_size = scene.discard_zone_tile_size(side_discard_zone, 4, side_discard_rows)
	check(scene.discard_grid_fits_zone(side_discard_zone, 4, side_discard_rows, side_discard_tile_size), "side discard grid sizes tiles to stay inside table zone")
	var center_parent = Control.new()
	root.add_child(center_parent)
	scene.draw_center(center_parent)
	for wind_label in scene.CENTER_WIND_LABELS:
		check(has_label_text(center_parent, wind_label), "center renders fixed wind label %s" % wind_label)
	check(count_panel_shadow_size(center_parent, 0) >= 5, "center inner panel and dice dots skip shadows for cheaper redraws")
	center_parent.queue_free()
	scene.players[1]["name"] = "超长在线昵称十二字测试"
	scene.players[1]["discards"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W"]
	var clipped_seat_parent = Control.new()
	root.add_child(clipped_seat_parent)
	scene.draw_seat(clipped_seat_parent, 1, scene.rect_full(0.0, 0.0, 1.0, 1.0), "right")
	check(label_is_clipped(first_label_with_text_prefix(clipped_seat_parent, "超长在线昵称")), "seat name clips long names without wrapping over badges")
	check(label_is_clipped(first_label_containing_text(clipped_seat_parent, "手")) and label_is_clipped(first_label_containing_text(clipped_seat_parent, "花")) and label_is_clipped(first_label_containing_text(clipped_seat_parent, "分")), "seat stats render as clipped compact pills")
	check(label_is_clipped(first_label_containing_text(clipped_seat_parent, "1万")), "seat discard preview clips recent river text")
	clipped_seat_parent.queue_free()
	var log_parent = Control.new()
	root.add_child(log_parent)
	scene.table_logs.clear()
	scene.table_logs.append("这是一条很长的补花和包赔牌谱记录一")
	scene.table_logs.append("这是一条很长的补花和包赔牌谱记录二")
	scene.table_logs.append("这是一条很长的补花和包赔牌谱记录三")
	scene.table_logs.append("这是一条很长的补花和包赔牌谱记录四")
	scene.draw_table_log(log_parent)
	check(label_is_clipped(first_label_containing_text(log_parent, "补花")), "table log clips long rows inside compact panel")
	check(count_label_nodes(log_parent) == 2, "table log reuses one body label for visible rows")
	log_parent.queue_free()
	scene.players[0]["flower_tiles"] = ["H1", "H2"]
	var flower_strip_parent = Control.new()
	root.add_child(flower_strip_parent)
	check(scene.draw_seat_flower_tiles(flower_strip_parent, 0), "seat panel renders flower tile strip")
	check(count_texture_rects(flower_strip_parent) >= 2 and not has_label_text(flower_strip_parent, "春") and not has_label_text(flower_strip_parent, "夏"), "flower strip uses real tile art without duplicate text")
	flower_strip_parent.queue_free()

	scene.players[0]["hand"] = []
	scene.players[0]["flowers"] = 0
	scene.players[0]["flower_tiles"] = []
	scene.wall.clear()
	scene.wall.append("5W")
	scene.wall.append("H1")
	var drawn = scene.draw_tile_for(0, false)
	check(drawn == "5W", "flower draw supplements to a normal tile")
	check(int(scene.players[0]["flowers"]) == 1, "flower count increases")
	check(scene.players[0]["hand"].size() == 1 and scene.players[0]["hand"][0] == "5W", "flower tile is not kept in hand")

	scene.players[0]["hand"] = [
		"1W", "1W", "1W",
		"2W", "3W", "4W",
		"5W", "6W", "7W",
		"2T", "3T", "4T",
		"E", "E",
	]
	scene.players[0]["melds"] = []
	check(scene.can_win_for_seat(0), "standard winning hand is detected")
	check(scene.calculate_min_shanten(winning_hand(), 0) == -1, "winning hand shanten is -1")
	check(scene.calculate_min_shanten(tenpai_hand(), 0) == 0, "tenpai hand shanten is zero")
	check(scene.effective_tile_count(tenpai_hand(), 0, 0) >= 3, "tenpai hand has winning tiles")
	scene.players[0]["hand"] = seven_pairs_hand()
	scene.players[0]["melds"] = []
	check(scene.can_win_for_seat(0), "seven pairs winning hand is detected")
	check(scene.calculate_min_shanten(seven_pairs_hand(), 0) == -1, "seven pairs shanten is complete")
	var seven_pairs_score = scene.calculate_win_score(0, "", false)
	check(seven_pairs_score.get("reasons", []).has("七对"), "seven pairs is scored")
	scene.players[0]["hand"] = thirteen_orphans_hand()
	scene.players[0]["melds"] = []
	check(scene.can_win_for_seat(0), "thirteen orphans winning hand is detected")
	check(scene.calculate_min_shanten(thirteen_orphans_hand(), 0) == -1, "thirteen orphans shanten is complete")
	var thirteen_score = scene.calculate_win_score(0, "", false)
	check(thirteen_score.get("reasons", []).has("十三幺"), "thirteen orphans is scored")
	scene.players[0]["hand"] = thirteen_orphans_unique_tenpai()
	check(scene.calculate_min_shanten(scene.players[0]["hand"], 0) == 0, "thirteen unique orphans are waiting for any pair")
	check(scene.effective_tile_variety(scene.players[0]["hand"], 0, 0) == scene.THIRTEEN_ORPHANS_CODES.size(), "thirteen unique orphans wait on every orphan tile")
	scene.players[0]["hand"] = thirteen_orphans_missing_pair_tenpai()
	var missing_metrics = scene.effective_tile_metrics(scene.players[0]["hand"], 0, 0)
	var missing_tiles: Array = missing_metrics.get("tiles", [])
	check(scene.calculate_min_shanten(scene.players[0]["hand"], 0) == 0, "paired twelve orphans wait on the missing orphan")
	check(missing_tiles.size() == 1 and str(missing_tiles[0]) == "P", "missing orphan wait is identified")
	scene.players[0]["hand"] = thirteen_orphans_route_hand()
	scene.players[0]["melds"] = []
	check(str(scene.hand_plan_report_for_seat(0, scene.players[0]["hand"]).get("label", "")) == "十三幺", "AI report identifies thirteen orphans route")
	check(scene.choose_ai_discard_for_seat(0) == "2W", "AI preserves thirteen orphans route by cutting off-route tile")
	scene.players[0]["melds"] = [["E", "E", "E"]]
	check(str(scene.hand_plan_report_for_seat(0, scene.players[0]["hand"]).get("label", "")) != "十三幺", "open meld cannot keep thirteen orphans route")
	scene.players[0]["melds"] = []
	scene.clear_shanten_cache()
	var cached_shanten = scene.calculate_min_shanten(tenpai_hand(), 0)
	var shanten_hits_before = scene.shanten_cache_hits
	check(scene.calculate_min_shanten(tenpai_hand(), 0) == cached_shanten and scene.shanten_cache_hits > shanten_hits_before, "shanten cache reuses repeated hand state")

	scene.players[0]["hand"] = [
		"1W", "1W", "2W", "2W", "3W", "3W", "4W",
		"4W", "5T", "5T", "6T", "6T", "P",
	]
	var win_claim_counts = scene.tile_counts(scene.players[0]["hand"])
	check(scene.get_claim_options(0, 1, "P").has("hu"), "discard win option is offered")
	check(scene.can_win_for_seat_from_counts(0, win_claim_counts, "P") and scene.get_claim_options(0, 1, "P", win_claim_counts).has("hu"), "discard win option can reuse hand count snapshot")

	scene.players[0]["hand"] = ["2W", "3W", "5T", "5T", "5T", "E", "S", "N", "R", "Z", "F", "P", "9B"]
	var chi_option_counts = scene.tile_counts(scene.players[0]["hand"])
	var options = scene.get_claim_options(0, 3, "4W")
	check(options.has("chi"), "next seat chi option is offered")
	check(scene.get_claim_options(0, 3, "4W", chi_option_counts) == options, "claim options reuse hand counts without changing offered actions")
	scene.players[0]["hand"] = ["1W", "2W", "2W", "4W", "4W", "5W", "5T", "6T", "7T", "E", "E", "P", "P"]
	var chi_choice_counts = scene.tile_counts(scene.players[0]["hand"])
	var chi_choice_counts_before_generation = chi_choice_counts.duplicate()
	var chi_choices = scene.get_chi_choices(scene.players[0]["hand"], "3W")
	var counted_chi_choices = scene.get_chi_choices_from_counts(chi_choice_counts, "3W")
	check(chi_choices.size() == 3, "multiple chi choices are exposed")
	check(counted_chi_choices.size() == chi_choices.size() and scene.same_tile_list(counted_chi_choices[1].get("needed", []), chi_choices[1].get("needed", [])), "chi choices can be generated from hand count snapshot")
	check(chi_choice_counts == chi_choice_counts_before_generation and scene.same_tile_list(counted_chi_choices[0].get("needed", []), ["4W", "5W"]) and scene.same_tile_list(counted_chi_choices[0].get("meld", []), ["3W", "4W", "5W"]), "chi choices use direct index checks without mutating count snapshots")
	check(scene.has_tile_list_counts(chi_choice_counts, counted_chi_choices[2].get("needed", [])), "chi count snapshot checks required tiles without rescanning the hand")
	var missing_pair_counts = scene.tile_counts(["4W"])
	var missing_pair_counts_before = missing_pair_counts.duplicate()
	check(not scene.consume_tile_list_counts(missing_pair_counts, ["4W", "5W"]) and missing_pair_counts == missing_pair_counts_before, "two-tile count consumption fails atomically when a required tile is missing")
	var duplicate_pair_counts = scene.tile_counts(["5W", "5W", "7T"])
	var duplicate_pair_counts_before = duplicate_pair_counts.duplicate()
	check(scene.has_tile_list_counts(duplicate_pair_counts, ["5W", "5W"]) and scene.consume_tile_list_counts(duplicate_pair_counts, ["5W", "5W"]), "two-tile count helpers handle duplicate required tiles without a required dictionary")
	scene.restore_tile_list_counts(duplicate_pair_counts, ["5W", "5W"])
	check(duplicate_pair_counts == duplicate_pair_counts_before, "two-tile count restoration returns duplicate-pair counts to the original snapshot")
	check(scene.chi_choice_label(chi_choices[1]) == "吃234万", "chi choice label is compact")
	var chi_choice_counts_before = chi_choice_counts.duplicate()
	var best_chi_from_counts = scene.best_chi_choice_from_counts(chi_choice_counts, "3W")
	var best_chi_from_hand = scene.best_chi_choice(scene.players[0]["hand"], "3W")
	check(scene.same_tile_list(best_chi_from_counts.get("needed", []), best_chi_from_hand.get("needed", [])) and chi_choice_counts == chi_choice_counts_before, "best chi choice can score from counts without mutating snapshots")
	var copied_chi_choice = scene.duplicate_chi_choice(chi_choices[1])
	var copied_chi_needed: Array = copied_chi_choice.get("needed", [])
	var original_chi_needed: Array = chi_choices[1].get("needed", [])
	if not copied_chi_needed.is_empty():
		copied_chi_needed[0] = "ZZ"
	check(not original_chi_needed.is_empty() and str(original_chi_needed[0]) != "ZZ", "chi choice copies protect needed tile arrays without recursive deep copy")
	scene.offline_phase = "pending_claim"
	scene.players[3]["discards"] = ["3W"]
	scene.offline_pending_claim = {
		"from_seat": 3,
		"tile": "3W",
		"options": ["chi"],
		"chi_choices": chi_choices,
	}
	check(scene.claim_options_text(scene.offline_pending_claim).find("吃123万") >= 0, "claim summary lists concrete chi choices")
	var claim_hint = scene.human_claim_hint_text()
	check(claim_hint.find("建议") < 0 and claim_hint.find("吃") >= 0, "claim hint lists legal responses without AI advice")
	var claim_recommendation = scene.recommended_claim_report()
	check(claim_recommendation.is_empty(), "claim recommendation is disabled for the human player")
	var original_claim_hand = scene.players[0]["hand"].duplicate()
	var original_pending_claim = scene.offline_pending_claim.duplicate(true)
	scene.players[0]["hand"] = ["1W", "2W", "3W", "3W", "4W", "5W", "5T", "6T", "7T", "E", "E", "P", "P"]
	var shared_human_chi_choices = scene.get_chi_choices(scene.players[0]["hand"], "3W")
	scene.offline_pending_claim = {
		"from_seat": 3,
		"tile": "3W",
		"options": ["chi", "peng"],
		"chi_choices": shared_human_chi_choices,
	}
	var contextless_human_claims: Array = []
	for shared_choice in shared_human_chi_choices:
		var shared_choice_report = scene.build_ai_claim_report(0, "chi", "3W", shared_choice)
		shared_choice_report["label"] = scene.chi_choice_label(shared_choice)
		shared_choice_report["chi_choice"] = shared_choice
		contextless_human_claims.append(shared_choice_report)
	var contextless_peng_report = scene.build_ai_claim_report(0, "peng", "3W")
	contextless_peng_report["label"] = scene.claim_label("peng")
	contextless_human_claims.append(contextless_peng_report)
	contextless_human_claims.sort_custom(func(a, b):
		var score_a = scene.human_claim_report_score(a)
		var score_b = scene.human_claim_report_score(b)
		if is_equal_approx(score_a, score_b):
			return scene.claim_priority(str(a.get("claim", ""))) > scene.claim_priority(str(b.get("claim", "")))
		return score_a > score_b
	)
	var shared_human_claims = scene.human_claim_candidate_reports()
	var shared_human_claims_match = shared_human_claims.size() == contextless_human_claims.size()
	for i in range(min(shared_human_claims.size(), contextless_human_claims.size())):
		var shared_report: Dictionary = shared_human_claims[i]
		var contextless_report: Dictionary = contextless_human_claims[i]
		shared_human_claims_match = shared_human_claims_match and str(shared_report.get("claim", "")) == str(contextless_report.get("claim", ""))
		shared_human_claims_match = shared_human_claims_match and str(shared_report.get("label", "")) == str(contextless_report.get("label", ""))
		shared_human_claims_match = shared_human_claims_match and bool(shared_report.get("allow", false)) == bool(contextless_report.get("allow", false))
		shared_human_claims_match = shared_human_claims_match and str(shared_report.get("reason", "")) == str(contextless_report.get("reason", ""))
		shared_human_claims_match = shared_human_claims_match and scene.same_tile_list(shared_report.get("chi_choice", {}).get("needed", []), contextless_report.get("chi_choice", {}).get("needed", []))
	check(shared_human_claims_match, "human claim candidates reuse one shared claim context without changing recommendation order")
	scene.players[0]["hand"] = original_claim_hand
	scene.offline_pending_claim = original_pending_claim
	var claim_copy_source = scene.build_ai_claim_report(0, "chi", "3W", chi_choices[1])
	var copied_claim_report = scene.duplicate_claim_report(claim_copy_source)
	var copied_claim_choice: Dictionary = copied_claim_report.get("chi_choice", {})
	var copied_claim_needed: Array = copied_claim_choice.get("needed", [])
	if not copied_claim_needed.is_empty():
		copied_claim_needed[0] = "YY"
	check(scene.same_tile_list(claim_copy_source.get("chi_choice", {}).get("needed", []), chi_choices[1].get("needed", [])), "claim report copies protect nested chi choices without recursive deep copy")
	var claim_actions_parent = Control.new()
	root.add_child(claim_actions_parent)
	scene.draw_actions(claim_actions_parent)
	check(count_button_text_prefix(claim_actions_parent, "荐吃") == 0 and has_button_text(claim_actions_parent, "吃234万"), "claim action bar shows legal chi choices without recommendation badge")
	claim_actions_parent.queue_free()
	check(scene.hand_tray_text().find("建议") < 0, "hand tray does not show claim advice")
	scene.human_claim("chi", chi_choices[1])
	check(scene.offline_phase == "await_discard", "chosen chi returns to discard phase")
	check(scene.players[0]["melds"].size() > 0 and scene.same_tile_list(scene.players[0]["melds"].back(), ["2W", "3W", "4W"]), "chosen chi meld is applied")
	check(scene.count_tile(scene.players[0]["hand"], "1W") == 1 and scene.count_tile(scene.players[0]["hand"], "5W") == 1, "unchosen chi edge tiles stay in hand")
	check(scene.same_tile_list(scene.filter_claim_options_by_priority(["chi", "peng", "hu"], 3), ["peng", "hu"]), "claim priority filters lower actions")
	scene.start_offline()
	scene.offline_phase = "resolving"
	scene.players[0]["discards"] = ["3W"]
	scene.players[1]["hand"] = ["1W", "2W", "2W", "4W", "4W", "5W", "5T", "6T", "7T", "E", "E", "P", "P"]
	scene.players[1]["melds"] = []
	scene.players[2]["hand"] = []
	scene.players[2]["melds"] = []
	scene.players[3]["hand"] = []
	scene.players[3]["melds"] = []
	var ai_chi_choices = scene.get_chi_choices(scene.players[1]["hand"], "3W")
	var expected_ai_chi_choice: Dictionary = {}
	var expected_ai_chi_report: Dictionary = {}
	var expected_ai_chi_score = -1000000.0
	for choice in ai_chi_choices:
		var report = scene.build_ai_claim_report(1, "chi", "3W", choice)
		if not bool(report.get("allow", false)):
			continue
		var score = scene.ai_claim_action_score(report, 1)
		if expected_ai_chi_choice.is_empty() or score > expected_ai_chi_score or (is_equal_approx(score, expected_ai_chi_score) and scene.ai_chi_choice_tiebreak(report) > scene.ai_chi_choice_tiebreak(expected_ai_chi_report)):
			expected_ai_chi_choice = (choice as Dictionary).duplicate(true)
			expected_ai_chi_report = report
			expected_ai_chi_score = score
	check(not expected_ai_chi_choice.is_empty(), "AI has at least one allowed chi choice")
	var direct_ai_chi = scene.best_ai_chi_claim(1, "3W", 1)
	check(scene.same_tile_list(direct_ai_chi.get("chi_choice", {}).get("meld", []), expected_ai_chi_choice.get("meld", [])), "AI chi helper evaluates all chi choices")
	var chosen_ai_claim = scene.choose_ai_claim(0, "3W")
	check(str(chosen_ai_claim.get("claim", "")) == "chi", "AI chooses chi when the best chi response is allowed")
	check(scene.same_tile_list(chosen_ai_claim.get("chi_choice", {}).get("meld", []), expected_ai_chi_choice.get("meld", [])), "AI claim selection uses the highest-scoring chi choice")

	scene.start_offline()
	scene.offline_phase = "resolving"
	scene.players[0]["hand"] = ["1W", "2W", "5T", "6T", "7T", "E", "E", "P", "P", "4B", "5B", "6B", "9B"]
	scene.players[0]["melds"] = []
	scene.players[1]["hand"] = waits_for_3w_hand()
	scene.players[1]["melds"] = []
	scene.players[3]["discards"] = ["3W"]
	scene.resolve_after_discard(3, "3W")
	check(scene.offline_phase == "ended", "AI hu takes priority over human chi")
	check(scene.offline_last_winner == 1, "higher priority AI hu wins the discard")
	check(scene.players[0]["melds"].is_empty(), "human chi is not applied under hu priority")

	scene.start_offline()
	scene.offline_phase = "resolving"
	scene.players[0]["hand"] = waits_for_3w_hand()
	scene.players[0]["melds"] = []
	scene.players[1]["hand"] = waits_for_3w_hand()
	scene.players[1]["melds"] = []
	scene.players[3]["discards"] = ["3W"]
	scene.resolve_after_discard(3, "3W")
	check(scene.offline_phase == "pending_claim", "human hu is still offered against AI hu")
	check(scene.offline_pending_claim.get("options", []) == ["hu"], "only equal-priority human hu is offered")
	check(scene.human_claim_hint_text().find("建议") < 0 and scene.human_claim_hint_text().find("胡") >= 0, "human hu prompt avoids AI advice wording")
	scene.human_claim("pass")
	check(scene.offline_phase == "ended" and scene.offline_last_winner == 1, "AI hu resolves after human passes equal-priority response")

	scene.start_offline()
	scene.offline_phase = "await_discard"
	scene.current_seat = 0
	scene.offline_turn_needs_draw = false
	scene.players[0]["melds"] = [["5W", "5W", "5W"]]
	scene.players[0]["hand"] = ["5W", "1T", "2T", "3T", "4T", "5T", "6T", "7T", "8T", "9T", "E"]
	scene.wall.clear()
	scene.wall.append("7B")
	check(scene.first_added_gang_tile(0) == "5W", "human added gang tile is detected")
	scene.human_added_gang("5W")
	check(scene.players[0]["melds"][0].size() == 4, "added gang upgrades existing pung")
	check(scene.count_tile(scene.players[0]["hand"], "5W") == 0, "added gang removes fourth tile from hand")
	check(scene.players[0]["hand"].has("7B"), "added gang draws replacement tile")
	check(str(scene.offline_last_draw.get("source", "")) == "gang", "added gang replacement marks gang source")
	scene.players[1]["melds"] = [["E", "E", "E"]]
	scene.players[1]["hand"] = ["E", "1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "P"]
	check(scene.can_added_gang(1, "E"), "AI added gang is legal")
	check(scene.choose_ai_added_gang(1) == "E", "AI considers honor added gang")
	var value_added_gang = scene.build_ai_self_gang_report(1, "E", "added")
	check(bool(value_added_gang.get("allow", false)), "AI self-gang report allows valuable added gang")
	check(float(value_added_gang.get("score", 0.0)) > 0.0, "AI self-gang report scores valuable gang")
	scene.players[2]["hand"] = seven_pairs_concealed_gang_hand()
	scene.players[2]["melds"] = []
	var seven_pairs_concealed_gang = scene.build_ai_self_gang_report(2, "E", "concealed")
	check(not bool(seven_pairs_concealed_gang.get("allow", true)), "AI declines concealed gang that breaks seven pairs route")
	check(bool(seven_pairs_concealed_gang.get("declined_by_plan", false)), "AI self-gang report marks seven pairs route decline")
	check(str(seven_pairs_concealed_gang.get("reason", "")) == "保七对", "AI self-gang report names seven pairs protection")
	check(scene.choose_ai_concealed_gang(2) == "", "AI concealed gang helper preserves seven pairs route")

	scene.start_offline()
	scene.offline_phase = "await_discard"
	scene.current_seat = 0
	scene.offline_turn_needs_draw = false
	scene.players[0]["melds"] = [["3W", "3W", "3W"]]
	scene.players[0]["hand"] = ["3W", "1T", "2T", "3T", "4T", "5T", "6T", "7T", "8T", "9T", "E"]
	scene.players[1]["hand"] = waits_for_3w_hand()
	scene.players[1]["melds"] = []
	scene.human_added_gang("3W")
	check(scene.offline_phase == "ended", "AI can rob human added gang")
	check(scene.offline_last_winner == 1, "AI rob gang winner is recorded")
	check(scene.players[0]["melds"][0].size() == 3, "robbed added gang does not upgrade pung")
	check(scene.players[0]["hand"].has("3W"), "robbed added gang keeps fourth tile in hand")
	check(scene.round_summary.find("抢杠胡") >= 0, "rob gang score reason is shown")

	scene.start_offline()
	scene.offline_phase = "await_discard"
	scene.current_seat = 1
	scene.offline_turn_needs_draw = false
	scene.players[0]["hand"] = waits_for_3w_hand()
	scene.players[0]["melds"] = []
	scene.players[1]["melds"] = [["3W", "3W", "3W"]]
	scene.players[1]["hand"] = ["3W", "1T", "2T", "3T", "4T", "5T", "6T", "7T", "8T", "9T", "E"]
	var rob_risk_added_gang = scene.build_ai_self_gang_report(1, "3W", "added")
	check(not bool(rob_risk_added_gang.get("allow", true)), "AI self-gang report declines added gang that can be robbed")
	check(bool(rob_risk_added_gang.get("rob_risk", false)), "AI self-gang report marks rob-gang risk")
	check(str(rob_risk_added_gang.get("reason", "")) == "防抢杠", "AI self-gang report names rob-gang defense")
	check(scene.choose_ai_added_gang(1) == "", "AI added gang helper avoids known rob-gang loss")
	scene.perform_added_gang(1, "3W")
	check(scene.offline_phase == "pending_claim", "human can respond to AI added gang with rob win")
	check(bool(scene.offline_pending_claim.get("rob_gang", false)), "pending claim is marked as rob gang")
	check(scene.offline_pending_claim.get("options", []) == ["hu"], "rob gang only offers hu")
	check(scene.human_claim_hint_text().find("建议") < 0 and scene.human_claim_hint_text().find("胡") >= 0, "rob gang prompt avoids AI advice wording")
	scene.human_claim("hu")
	check(scene.offline_phase == "ended" and scene.offline_last_winner == 0, "human rob gang win resolves")

	scene.start_offline()
	scene.offline_phase = "await_discard"
	scene.current_seat = 1
	scene.offline_turn_needs_draw = false
	scene.players[0]["hand"] = waits_for_3w_hand()
	scene.players[0]["melds"] = []
	scene.players[1]["melds"] = [["3W", "3W", "3W"]]
	scene.players[1]["hand"] = ["3W", "1T", "2T", "3T", "4T", "5T", "6T", "7T", "8T", "9T", "E"]
	scene.wall.clear()
	scene.wall.append("7B")
	scene.perform_added_gang(1, "3W")
	scene.human_claim("pass")
	check(scene.offline_phase == "await_discard", "added gang continues after human passes rob gang")
	check(scene.players[1]["melds"][0].size() == 4, "passed rob gang upgrades pung")
	check(scene.players[1]["hand"].has("7B"), "passed rob gang draws replacement tile")

	scene.start_offline()
	var discard = scene.choose_ai_discard_for_seat(0)
	check(scene.players[0]["hand"].has(discard), "AI discard exists in hand")
	scene.players[0]["hand"] = ai_shape_hand()
	scene.players[0]["melds"] = []
	discard = scene.choose_ai_discard_for_seat(0)
	check(discard == "E", "AI discards isolated honor before breaking useful shape")
	scene.clear_ai_report_cache()
	var ai_reports = scene.get_ai_discard_reports(0)
	check(not ai_reports.is_empty(), "AI discard reports are produced")
	check(ai_reports.size() == unique_tile_count(scene.players[0]["hand"]), "AI discard reports evaluate duplicate tile candidates once")
	var report_hits_before = scene.ai_report_cache_hits
	var cached_ai_reports = scene.get_ai_discard_reports(0)
	check(not cached_ai_reports.is_empty() and scene.ai_report_cache_hits > report_hits_before and str(cached_ai_reports[0].get("tile", "")) == str(ai_reports[0].get("tile", "")), "AI report cache reuses identical table state")
	var report_misses_before = scene.ai_report_cache_misses
	scene.players[1]["discards"].append("9W")
	var changed_state_reports = scene.get_ai_discard_reports(0)
	check(scene.ai_report_cache_misses > report_misses_before and not changed_state_reports.is_empty(), "AI report cache key changes when visible table state changes")
	scene.players[1]["discards"].clear()
	check(str(ai_reports[0].get("tile", "")) == "E", "AI report keeps best discard first")
	check(int(ai_reports[0].get("ukeire", -1)) >= 0, "AI report includes effective tile count")
	check(int(ai_reports[0].get("variety", -1)) >= 0, "AI report includes effective tile variety")
	check(typeof(ai_reports[0].get("effective_remaining", {})) == TYPE_DICTIONARY, "AI report includes remaining effective tile counts")
	check(float(ai_reports[0].get("shape_quality", 0.0)) > 0.0 and str(ai_reports[0].get("shape_label", "")).find("形") >= 0, "AI report includes shape quality text")
	check(str(ai_reports[0].get("risk_label", "")) == scene.risk_label(float(ai_reports[0].get("risk", 0.0))), "AI report reuses the same risk label bucket in report fields and reasons")
	check(str(ai_reports[0].get("reason_label", "")) == "切孤张", "AI report labels isolated tile discard reason")
	var isolated_reason_counts = scene.tile_counts(scene.players[0]["hand"])
	check(scene.discard_reason_label("E", scene.players[0]["hand"], ai_reports[0]) == scene.discard_reason_label("E", [], ai_reports[0], isolated_reason_counts), "discard reason label can reuse original hand counts for isolated tile checks")
	check(str(scene.ai_discard_brief(ai_reports[0])).find("推荐打东") >= 0, "AI brief explains recommended discard")
	check(str(scene.ai_discard_brief(ai_reports[0])).find("形") >= 0, "AI brief includes shape quality")
	check(str(scene.ai_discard_brief(ai_reports[0])).find("切孤张") >= 0, "AI brief includes discard reason")
	var minimal_ai_brief = scene.ai_discard_brief({"tile": "E", "shanten": 1, "ukeire": 4, "variety": 2, "risk_label": "低"})
	check(minimal_ai_brief == "推荐打东 · 1向听 · 进张4/2 · 风险低", "AI brief joins only present optional fragments")
	var two_sided_quality = scene.hand_shape_quality_report(["3W", "4W", "5W", "6W", "2T", "4T", "1B", "9B", "E"])
	var edge_quality = scene.hand_shape_quality_report(["1W", "2W", "8W", "9W", "2T", "4T", "1B", "9B", "E"])
	check(float(two_sided_quality.get("score", 0.0)) > float(edge_quality.get("score", 0.0)), "two-sided shapes score higher than edge and gap shapes")
	check(scene.hand_shape_quality_text(two_sided_quality).find("两面") >= 0, "shape quality text names two-sided shapes")
	var flush_route_hand = ["1W", "1W", "2W", "2W", "3W", "3W", "4W", "4W", "5W", "5W", "6W", "7W", "8W", "9T"]
	scene.players[0]["hand"] = flush_route_hand.duplicate()
	scene.players[0]["melds"] = []
	for route_seat in range(4):
		scene.players[route_seat]["discards"] = []
		if route_seat != 0:
			scene.players[route_seat]["melds"] = []
	var flush_after_offsuit = flush_route_hand.duplicate()
	flush_after_offsuit.erase("9T")
	var flush_after_suit = flush_route_hand.duplicate()
	flush_after_suit.erase("5W")
	var flush_route_report = scene.build_ai_discard_report(0, "9T", flush_after_offsuit, 0)
	var broken_route_report = scene.build_ai_discard_report(0, "5W", flush_after_suit, 0)
	check(str(flush_route_report.get("plan_label", "")) == "清一色", "AI report identifies pure suit route")
	check(str(flush_route_report.get("reason_label", "")) == "保路线", "AI report labels route-preserving discard")
	check(float(flush_route_report.get("plan_bonus", 0.0)) > float(broken_route_report.get("plan_bonus", 0.0)), "AI route bonus favors discarding off-suit tile")
	check(scene.hand_plan_text(flush_route_report) == "路线清一色", "AI route text names pure suit route")
	check(scene.ai_discard_brief(flush_route_report).find("路线清一色") >= 0, "AI brief includes hand route")
	var dragon_route_hand = full_straight_route_hand()
	scene.players[0]["hand"] = dragon_route_hand.duplicate()
	scene.players[0]["melds"] = []
	var dragon_after_offroute = dragon_route_hand.duplicate()
	dragon_after_offroute.erase("E")
	var dragon_after_route_break = dragon_route_hand.duplicate()
	dragon_after_route_break.erase("5W")
	var dragon_route_report = scene.build_ai_discard_report(0, "E", dragon_after_offroute, 0)
	var broken_dragon_report = scene.build_ai_discard_report(0, "5W", dragon_after_route_break, 0)
	check(str(dragon_route_report.get("plan_label", "")) == "一条龙", "AI report identifies full straight route")
	check(str(dragon_route_report.get("reason_label", "")) == "保路线", "AI labels off-route discard for full straight")
	check(float(dragon_route_report.get("plan_bonus", 0.0)) > float(broken_dragon_report.get("plan_bonus", 0.0)), "AI route bonus favors preserving full straight ranks")
	check(scene.hand_plan_text(dragon_route_report) == "路线一条龙", "AI route text names full straight")
	var simples_route_hand = all_simples_route_hand()
	scene.players[0]["hand"] = simples_route_hand.duplicate()
	scene.players[0]["melds"] = []
	var simples_after_offroute = simples_route_hand.duplicate()
	simples_after_offroute.erase("E")
	var simples_after_route_break = simples_route_hand.duplicate()
	simples_after_route_break.erase("5W")
	var simples_route_report = scene.build_ai_discard_report(0, "E", simples_after_offroute, 0)
	var broken_simples_report = scene.build_ai_discard_report(0, "5W", simples_after_route_break, 0)
	check(str(simples_route_report.get("plan_label", "")) == "断幺九", "AI report identifies all-simples route")
	check(str(simples_route_report.get("reason_label", "")) == "保路线", "AI labels terminal/honor discard for all-simples route")
	check(float(simples_route_report.get("plan_bonus", 0.0)) > float(broken_simples_report.get("plan_bonus", 0.0)), "AI route bonus favors preserving simple tiles")
	check(scene.hand_plan_text(simples_route_report) == "路线断幺九", "AI route text names all-simples")
	var dragon_honor_route_hand = small_three_dragons_route_hand()
	scene.players[0]["hand"] = dragon_honor_route_hand.duplicate()
	scene.players[0]["melds"] = []
	var dragon_honor_after_offroute = dragon_honor_route_hand.duplicate()
	dragon_honor_after_offroute.erase("9B")
	var dragon_honor_after_route_break = dragon_honor_route_hand.duplicate()
	dragon_honor_after_route_break.erase("Z")
	var dragon_honor_route_report = scene.build_ai_discard_report(0, "9B", dragon_honor_after_offroute, 0)
	var broken_dragon_honor_report = scene.build_ai_discard_report(0, "Z", dragon_honor_after_route_break, 0)
	check(str(dragon_honor_route_report.get("plan_label", "")) == "小三元", "AI report identifies small three dragons route")
	check(str(dragon_honor_route_report.get("reason_label", "")) == "保路线", "AI labels non-dragon discard for dragon route")
	check(float(dragon_honor_route_report.get("plan_bonus", 0.0)) > float(broken_dragon_honor_report.get("plan_bonus", 0.0)), "AI route bonus favors preserving dragon groups")
	check(scene.hand_plan_text(dragon_honor_route_report) == "路线小三元", "AI route text names small three dragons")
	var seven_pairs_route_tiles = seven_pairs_route_hand()
	scene.players[0]["hand"] = seven_pairs_route_tiles.duplicate()
	scene.players[0]["melds"] = []
	var seven_pairs_after_single = seven_pairs_route_tiles.duplicate()
	seven_pairs_after_single.erase("8T")
	var seven_pairs_after_pair_break = seven_pairs_route_tiles.duplicate()
	seven_pairs_after_pair_break.erase("1W")
	var seven_pairs_route_report = scene.build_ai_discard_report(0, "8T", seven_pairs_after_single, 0)
	var broken_seven_pairs_report = scene.build_ai_discard_report(0, "1W", seven_pairs_after_pair_break, 0)
	check(str(seven_pairs_route_report.get("plan_label", "")) == "七对", "AI report identifies seven pairs route")
	check(str(seven_pairs_route_report.get("reason_label", "")) == "保路线", "AI labels singleton discard for seven pairs route")
	var seven_pairs_original = seven_pairs_after_single.duplicate()
	seven_pairs_original.append("8T")
	var seven_pairs_counts = scene.tile_counts(seven_pairs_original)
	check(scene.discard_reason_label("8T", seven_pairs_original, seven_pairs_route_report) == scene.discard_reason_label("8T", [], seven_pairs_route_report, seven_pairs_counts), "discard reason label can reuse original hand counts for seven pairs offcut checks")
	check(float(seven_pairs_route_report.get("plan_bonus", 0.0)) > float(broken_seven_pairs_report.get("plan_bonus", 0.0)), "AI route bonus favors preserving pairs")
	check(scene.hand_plan_text(seven_pairs_route_report) == "路线七对", "AI route text names seven pairs")
	check(["8T", "9B"].has(scene.choose_ai_discard_for_seat(0)), "AI preserves seven pairs route by cutting a singleton tile")
	scene.players[0]["melds"] = [["E", "E", "E"]]
	check(str(scene.hand_plan_report_for_seat(0, scene.players[0]["hand"]).get("label", "")) != "七对", "open meld cannot keep seven pairs route")
	scene.players[0]["melds"] = []
	check(scene.effective_tile_variety(tenpai_hand(), 0, 0) > 0, "tenpai hand reports effective tile variety")
	var tenpai_metrics = scene.effective_tile_metrics(tenpai_hand(), 0, 0, 0)
	check(tenpai_metrics.get("tiles", []).has("E"), "effective tile metrics include concrete wait tile")
	check(int(tenpai_metrics.get("remaining_by_tile", {}).get("E", 0)) > 0, "effective tile metrics include live count per wait tile")
	var checked_wait_metrics = scene.wait_value_metrics(0, tenpai_hand(), 0, 0, tenpai_metrics.get("tiles", []), tenpai_metrics.get("remaining_by_tile", {}))
	var reusable_wait_hand = tenpai_hand()
	var reusable_wait_size = reusable_wait_hand.size()
	var trusted_wait_metrics = scene.wait_value_metrics(0, tenpai_hand(), 0, 0, tenpai_metrics.get("tiles", []), tenpai_metrics.get("remaining_by_tile", {}), true)
	var reusable_wait_metrics = scene.wait_value_metrics(0, reusable_wait_hand, 0, 0, tenpai_metrics.get("tiles", []), tenpai_metrics.get("remaining_by_tile", {}), true)
	var snapshot_wait_metrics = scene.wait_value_metrics(0, tenpai_hand(), 0, 0, tenpai_metrics.get("tiles", []), tenpai_metrics.get("remaining_by_tile", {}), true, {}, scene.ai_total_attack_multiplier(0))
	var non_tenpai_wait_metrics = scene.wait_value_metrics(0, ai_shape_hand(), 0, 2, [], {})
	var empty_wait_metrics = scene.empty_wait_value_metrics()
	var isolated_empty_wait_metrics = scene.empty_wait_value_metrics()
	var empty_wait_self_discards: Array = empty_wait_metrics.get("self_discarded", [])
	empty_wait_self_discards.append("E")
	check(is_equal_approx(float(checked_wait_metrics.get("score", -1.0)), float(trusted_wait_metrics.get("score", -2.0))) and str(checked_wait_metrics.get("best_tile", "")) == str(trusted_wait_metrics.get("best_tile", "")), "wait value metrics can skip duplicate complete-hand checks for known winning waits")
	check(reusable_wait_hand.size() == reusable_wait_size and is_equal_approx(float(reusable_wait_metrics.get("score", -1.0)), float(trusted_wait_metrics.get("score", -2.0))), "wait value metrics reuses a temporary winning hand without mutating the source hand")
	check(is_equal_approx(float(snapshot_wait_metrics.get("score", -1.0)), float(trusted_wait_metrics.get("score", -2.0))), "wait value metrics can reuse precomputed attack multipliers")
	check(is_equal_approx(float(non_tenpai_wait_metrics.get("score", -1.0)), 0.0) and not non_tenpai_wait_metrics.has("attack_multiplier") and not non_tenpai_wait_metrics.has("wait_focus"), "non-tenpai wait value metrics skip wait weight calculations")
	check(is_equal_approx(float(empty_wait_metrics.get("score", -1.0)), 0.0) and str(empty_wait_metrics.get("best_tile", "x")) == "" and str(empty_wait_metrics.get("quality_text", "x")) == "" and isolated_empty_wait_metrics.get("self_discarded", []).is_empty(), "empty wait value metrics reuse a template with isolated self-discard arrays")
	var non_tenpai_report_hand = ["1W", "4W", "7W", "1T", "4T", "7T", "1B", "4B", "7B", "E", "S", "R", "N"]
	var non_tenpai_report = scene.build_ai_discard_report(0, "9B", non_tenpai_report_hand, 0)
	var non_tenpai_self_discards: Array = non_tenpai_report.get("wait_self_discarded", [])
	check(int(non_tenpai_report.get("shanten", 0)) > 0 and is_equal_approx(float(non_tenpai_report.get("wait_value", -1.0)), 0.0) and str(non_tenpai_report.get("wait_best_tile", "")) == "" and int(non_tenpai_report.get("wait_total_remaining", -1)) == 0 and non_tenpai_self_discards.is_empty(), "non-tenpai AI reports keep zero wait fields without building wait metrics")
	var lazy_wait_visible = scene.visible_tile_counts()
	var lazy_wait_context = scene.make_ai_evaluation_context(0, lazy_wait_visible)
	var lazy_wait_pressure = scene.ai_pressure_context(0, lazy_wait_context)
	scene.build_ai_discard_report(0, "9B", non_tenpai_report_hand, 0, lazy_wait_visible, lazy_wait_pressure, lazy_wait_context)
	check(not bool(lazy_wait_context.get("self_discard_lookup_ready", false)), "non-tenpai AI reports leave self-discard lookup unbuilt in shared contexts")
	var tenpai_report = {
		"tile": "P",
		"shanten": 0,
		"ukeire": tenpai_metrics.get("count", 0),
		"variety": tenpai_metrics.get("variety", 0),
		"effective_tiles": tenpai_metrics.get("tiles", []),
		"risk_label": "低",
	}
	check(scene.effective_tile_text(tenpai_report, 3) == "听东", "effective tile text names concrete wait")
	tenpai_report["effective_remaining"] = tenpai_metrics.get("remaining_by_tile", {})
	check(scene.effective_tile_text(tenpai_report, 3).find("东") >= 0 and scene.effective_tile_text(tenpai_report, 3).find("张") >= 0, "effective tile text shows live tile counts when available")
	check(scene.ai_discard_brief(tenpai_report).find("听东") >= 0, "AI brief includes concrete wait tile")
	check(scene.ai_discard_brief(tenpai_report).find("张") >= 0, "AI brief includes live wait count")
	scene.players[0]["melds"] = []
	scene.players[0]["flowers"] = 0
	for value_seat in range(4):
		scene.players[value_seat]["discards"] = []
		scene.players[value_seat]["melds"] = []
	var low_wait_report = scene.build_ai_discard_report(0, "P", tenpai_hand(), 0)
	check(float(low_wait_report.get("wait_value", 0.0)) > 0.0, "AI report scores tenpai wait value")
	check(str(low_wait_report.get("wait_best_tile", "")) == "E", "AI report names best wait tile")
	check(scene.wait_value_text(low_wait_report).find("价值东") >= 0, "AI report exposes wait value text")
	scene.players[0]["discards"] = ["E"]
	var lazy_self_discard_context = scene.make_ai_evaluation_context(0, scene.visible_tile_counts())
	var lazy_self_discard_pressure = scene.ai_pressure_context(0, lazy_self_discard_context)
	var self_discarded_wait_report = scene.build_ai_discard_report(0, "P", tenpai_hand(), 0)
	var lazy_self_discard_wait_report = scene.build_ai_discard_report(0, "P", tenpai_hand(), 0, scene.ai_context_visible_counts(lazy_self_discard_context), lazy_self_discard_pressure, lazy_self_discard_context)
	check(float(self_discarded_wait_report.get("wait_adjusted_remaining", 0.0)) < float(low_wait_report.get("wait_adjusted_remaining", 0.0)), "self-discarded wait has lower weighted live tiles")
	check(float(self_discarded_wait_report.get("wait_value", 0.0)) < float(low_wait_report.get("wait_value", 0.0)), "self-discarded wait lowers tenpai value")
	check(bool(lazy_self_discard_context.get("self_discard_lookup_ready", false)) and int(lazy_self_discard_wait_report.get("wait_total_remaining", 0)) == int(self_discarded_wait_report.get("wait_total_remaining", 0)), "tenpai AI reports lazily build self-discard lookup when scoring waits")
	check(scene.wait_quality_text(self_discarded_wait_report).find("回头待东") >= 0, "wait quality text names self-discarded wait")
	check(scene.wait_quality_text(self_discarded_wait_report) != "", "wait quality text remains available for self-discarded waits")
	check(scene.ai_discard_brief(self_discarded_wait_report).find("回头待东") >= 0, "AI brief exposes self-discarded wait quality")
	scene.players[0]["discards"] = []
	var pure_tenpai = pure_one_suit_hand()
	pure_tenpai.remove_at(pure_tenpai.size() - 1)
	var pure_wait_report = scene.build_ai_discard_report(0, "P", pure_tenpai, 0)
	check(str(pure_wait_report.get("wait_best_tile", "")) != "", "pure suit tenpai names a best wait tile")
	check(int(pure_wait_report.get("wait_best_points", 0)) > int(low_wait_report.get("wait_best_points", 0)), "higher fan tenpai gets higher wait points")
	check(float(pure_wait_report.get("wait_value", 0.0)) > float(low_wait_report.get("wait_value", 0.0)), "higher fan tenpai gets stronger AI value")
	check(scene.ai_discard_brief(pure_wait_report).find("价值") >= 0 and scene.ai_discard_brief(pure_wait_report).find("分") >= 0, "AI brief includes high value wait")
	scene.mode = "offline"
	scene.offline_hand_number = 7
	scene.players[0]["score"] = 33000
	scene.players[1]["score"] = 30000
	scene.players[2]["score"] = 24000
	scene.players[3]["score"] = 13000
	scene.players[0]["hand"] = ai_shape_hand()
	scene.current_human_advice = []
	var leader_context = scene.score_context_report(0)
	var trailer_context = scene.score_context_report(3)
	check(int(leader_context.get("rank", 0)) == 1 and str(leader_context.get("strategy", "")) == "守成", "late leader score context switches to guard strategy")
	check(int(trailer_context.get("rank", 0)) == 4 and str(trailer_context.get("strategy", "")) == "追分", "late trailer score context switches to chase strategy")
	check(scene.score_strategy_text(0).find("分势") >= 0 and scene.score_strategy_text(0).find("守成") >= 0, "score strategy text names leader guard mode")
	check(scene.score_defense_adjustment(0) > 0.0 and scene.score_defense_adjustment(3) < 0.0, "score context adjusts defense direction")
	check(scene.score_attack_multiplier(3) > scene.score_attack_multiplier(0), "trailing score context boosts attack multiplier")
	var value_metrics = scene.effective_tile_metrics(tenpai_hand(), 0, 0, 0)
	var leader_wait = scene.wait_value_metrics(0, tenpai_hand(), 0, 0, value_metrics.get("tiles", []), value_metrics.get("remaining_by_tile", {}))
	var trailer_wait = scene.wait_value_metrics(3, tenpai_hand(), 0, 0, value_metrics.get("tiles", []), value_metrics.get("remaining_by_tile", {}))
	check(float(trailer_wait.get("score", 0.0)) > float(leader_wait.get("score", 0.0)), "trailing player values tenpai waits more aggressively")
	check(scene.ai_advice_summary(0, 2).find("分势") >= 0, "advisor includes score strategy line")
	var score_claim_report = {"seat": 0, "claim": "peng", "before_shanten": 2, "after_shanten": 1, "shape_gain": 40.0, "forced_discard_risk": 22.0}
	var leader_claim_score = scene.ai_claim_action_score(score_claim_report, 0)
	score_claim_report["seat"] = 3
	var trailer_claim_score = scene.ai_claim_action_score(score_claim_report, 0)
	check(trailer_claim_score > leader_claim_score, "trailing player values productive claims more aggressively")
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.current_seat = 0
	scene.offline_turn_needs_draw = false
	scene.players[0]["hand"] = ai_shape_hand()
	scene.players[0]["melds"] = []
	scene.current_human_advice = scene.get_ai_discard_reports(0)
	check(not scene.current_human_advice.is_empty(), "AI reports remain available for computer decision logic")
	var recommend_actions_parent = Control.new()
	root.add_child(recommend_actions_parent)
	scene.draw_actions(recommend_actions_parent)
	check(not has_button_text(recommend_actions_parent, "推荐东"), "action bar does not render human recommended discard")
	check(count_button_text_prefix(recommend_actions_parent, "备") == 0, "action bar does not render human alternative discards")
	check(not has_button_text(recommend_actions_parent, "提示"), "action bar does not render human AI hint button")
	recommend_actions_parent.queue_free()
	check(scene.discard_action_alternative_reports("E", 2).is_empty(), "human alternative discard helper is disabled")
	var recommend_hand_parent = Control.new()
	root.add_child(recommend_hand_parent)
	scene.draw_hand(recommend_hand_parent)
	check(not has_label_text(recommend_hand_parent, "荐"), "hand does not render recommendation badge")
	recommend_hand_parent.queue_free()
	var hint_text = scene.human_hint_text()
	check(hint_text.find("建议") < 0 and hint_text == scene.current_status_text(), "human hint text returns status without AI advice")
	var tray_summary = scene.hand_tray_text()
	check(not tray_summary.begins_with("荐") and tray_summary == scene.current_status_text(), "hand tray uses status without AI summary")
	check(scene.discard_alternative_text(scene.current_human_advice, 2).find("/") >= 0, "internal AI alternative text remains available for AI reports")
	check(scene.shanten_label(0) == "听牌", "shanten label names tenpai")
	check(scene.risk_label(10.0) == "低" and scene.risk_label(40.0) == "高", "risk labels bucket danger")
	scene.players[1]["melds"] = [["3W", "4W", "5W"], ["6W", "7W", "8W"]]
	scene.players[1]["discards"] = ["1T", "9B", "E", "P"]
	scene.players[2]["melds"] = []
	scene.players[2]["discards"] = []
	scene.players[3]["melds"] = []
	scene.players[3]["discards"] = []
	var threatened_risk = scene.deal_in_risk_score("5W", 0)
	var neutral_risk = scene.deal_in_risk_score("5T", 0)
	check(scene.opponent_tile_threat_score("5W", 0) > scene.opponent_tile_threat_score("5T", 0), "same-suit exposed melds raise tile threat")
	check(threatened_risk > neutral_risk, "same-suit exposed melds raise deal-in risk")
	var risk_summary = scene.deal_in_risk_summary("5W", 0)
	var visible_risk_counts = scene.visible_tile_counts()
	var cached_risk_summary = scene.deal_in_risk_summary("5W", 0, visible_risk_counts)
	var tile_risk_vector = scene.tile_risk_vector("5W", 0, visible_risk_counts)
	var vector_risk_summary = scene.deal_in_risk_summary("5W", 0, visible_risk_counts, tile_risk_vector)
	var vector_threat = scene.opponent_tile_threat_score("5W", 0, visible_risk_counts, tile_risk_vector)
	var risk_vector_context = scene.make_ai_evaluation_context(0, visible_risk_counts)
	var contextual_risk_vector = scene.tile_risk_vector("5W", 0, visible_risk_counts, risk_vector_context)
	var contextual_risk_source: Dictionary = contextual_risk_vector.get("danger_source", {})
	var expected_risk_source_opponent = int(contextual_risk_source.get("opponent", -1))
	var direct_contextual_risk_score = scene.deal_in_risk_score("5W", 0, risk_vector_context)
	var cached_contextual_risk_vector = scene.tile_risk_vector("5W", 0, visible_risk_counts, risk_vector_context)
	var cached_contextual_source: Dictionary = cached_contextual_risk_vector.get("danger_source", {})
	if not cached_contextual_source.is_empty():
		cached_contextual_source["opponent"] = 9
	var refreshed_contextual_risk_vector = scene.tile_risk_vector("5W", 0, visible_risk_counts, risk_vector_context)
	var refreshed_contextual_source: Dictionary = refreshed_contextual_risk_vector.get("danger_source", {})
	var pressure_score = scene.discard_pressure_score("5W", 0)
	var cached_pressure_score = scene.discard_pressure_score("5W", 0, visible_risk_counts)
	var pressure_context = scene.ai_pressure_context(0)
	var visible_five_man = scene.visible_tile_count("5W")
	var manual_risk = 0.0
	for other in range(scene.players.size()):
		manual_risk += scene.single_opponent_deal_in_risk("5W", 0, other, visible_five_man, visible_risk_counts)
	var reusable_risk_components: Dictionary = {"risk": -1.0, "pattern_threat": -1.0}
	scene.write_single_opponent_deal_in_risk_components(reusable_risk_components, "5W", 0, 1, visible_five_man, visible_risk_counts)
	var returned_risk_components = scene.single_opponent_deal_in_risk_components("5W", 0, 1, visible_five_man, visible_risk_counts)
	var reusable_matches_returned = is_equal_approx(float(reusable_risk_components.get("risk", -1.0)), float(returned_risk_components.get("risk", -2.0))) and is_equal_approx(float(reusable_risk_components.get("pattern_threat", -1.0)), float(returned_risk_components.get("pattern_threat", -2.0)))
	scene.write_single_opponent_deal_in_risk_components(reusable_risk_components, "", 0, 1, visible_five_man, visible_risk_counts)
	var summary_source = risk_summary.get("danger_source", {})
	check(is_equal_approx(float(risk_summary.get("score", -1.0)), manual_risk), "deal-in risk summary scans opponent risks once")
	check(reusable_matches_returned and is_equal_approx(float(reusable_risk_components.get("risk", -1.0)), 0.0) and is_equal_approx(float(reusable_risk_components.get("pattern_threat", -1.0)), 0.0), "deal-in risk component scan can reuse one result dictionary safely")
	check(is_equal_approx(direct_contextual_risk_score, float(contextual_risk_vector.get("score", -1.0))), "direct deal-in risk score reuses risk vectors without summary allocation")
	check(is_equal_approx(float(cached_risk_summary.get("score", -1.0)), float(risk_summary.get("score", -2.0))), "deal-in risk summary can reuse visible count snapshots")
	check(is_equal_approx(float(vector_risk_summary.get("score", -1.0)), float(risk_summary.get("score", -2.0))), "deal-in risk summary can reuse tile risk vectors")
	check(is_equal_approx(vector_threat, scene.opponent_tile_threat_score("5W", 0, visible_risk_counts)), "tile risk vector reuses opponent threat scores")
	check(expected_risk_source_opponent >= 0 and int(refreshed_contextual_source.get("opponent", -1)) == expected_risk_source_opponent, "tile risk vector cache protects nested danger source with targeted copies")
	check(is_equal_approx(pressure_score, cached_pressure_score), "discard pressure score can reuse visible count snapshots")
	check(is_equal_approx(float(pressure_context.get("opponent_pressure", -1.0)), scene.opponent_pressure_score(0)), "AI pressure context reuses opponent pressure for candidate reports")
	check(is_equal_approx(float(pressure_context.get("readiness_pressure", -1.0)), scene.opponent_readiness_pressure_score(0)), "AI pressure context reuses readiness pressure for candidate reports")
	check(typeof(summary_source) == TYPE_DICTIONARY and int(summary_source.get("opponent", -1)) == 1, "deal-in risk summary carries danger source")
	var shared_simulated_hand = ["1B", "1B", "1B", "2B", "3B", "4B", "5B", "6B", "7B", "E", "E", "P", "P"]
	var shared_simulated_counts = scene.tile_counts(shared_simulated_hand)
	var safe_report = scene.build_ai_discard_report(0, "5T", shared_simulated_hand, 0)
	var danger_report = scene.build_ai_discard_report(0, "5W", shared_simulated_hand, 0)
	var cached_context_report = scene.build_ai_discard_report(0, "5W", shared_simulated_hand, 0, visible_risk_counts, pressure_context)
	var counted_context_report = scene.build_ai_discard_report(0, "5W", shared_simulated_hand, 0, visible_risk_counts, pressure_context, {}, shared_simulated_counts)
	var original_shared_counts = shared_simulated_counts.duplicate()
	original_shared_counts[scene.tile_index("5W")] = int(original_shared_counts[scene.tile_index("5W")]) + 1
	var original_shared_counts_before = original_shared_counts.duplicate()
	var counted_original_report = scene.build_ai_discard_report(0, "5W", shared_simulated_hand, 0, visible_risk_counts, pressure_context, {}, shared_simulated_counts, original_shared_counts)
	check(float(safe_report.get("score", 0.0)) > float(danger_report.get("score", 0.0)), "AI scores dangerous exposed-suit discard lower")
	check(is_equal_approx(float(cached_context_report.get("score", -1.0)), float(danger_report.get("score", -2.0))), "AI discard report can reuse pressure context without score changes")
	check(is_equal_approx(float(cached_context_report.get("defense", -1.0)), float(danger_report.get("defense", -2.0))), "AI discard report can reuse pressure context without defense changes")
	check(is_equal_approx(float(cached_context_report.get("emergency_defense", -1.0)), float(danger_report.get("emergency_defense", -2.0))), "AI discard report can reuse pressure context without emergency defense changes")
	check(is_equal_approx(float(counted_context_report.get("score", -1.0)), float(cached_context_report.get("score", -2.0))) and int(counted_context_report.get("shanten", 8)) == int(cached_context_report.get("shanten", 9)) and int(counted_context_report.get("ukeire", -1)) == int(cached_context_report.get("ukeire", -2)), "AI discard report can reuse simulated hand counts without score or shanten changes")
	check(str(counted_original_report.get("reason_label", "")) == str(counted_context_report.get("reason_label", "")) and original_shared_counts == original_shared_counts_before, "AI discard report can reuse original hand counts without mutating snapshots")
	scene.clear_threat_report_cache()
	var cached_threat_report = scene.opponent_seat_threat_report(0, 1)
	var threat_cache_size = scene.threat_report_cache.size()
	var cached_threat_report_again = scene.opponent_seat_threat_report(0, 1)
	check(threat_cache_size == scene.threat_report_cache.size() and str(cached_threat_report_again.get("plan_label", "")) == str(cached_threat_report.get("plan_label", "")), "threat report cache reuses identical table state")
	var cached_safe_tiles: Array = cached_threat_report.get("safe_tiles", [])
	if not cached_safe_tiles.is_empty():
		var original_safe_tile = str(cached_safe_tiles[0])
		cached_safe_tiles[0] = "ZZ"
		check(str(scene.opponent_seat_threat_report(0, 1).get("safe_tiles", [])[0]) == original_safe_tile, "threat report cache protects nested safe tile arrays")
	var threat_report = scene.opponent_threat_report(0)
	check(int(threat_report.get("opponent", -1)) == 1, "threat report identifies most dangerous opponent")
	check(str(threat_report.get("level", "")) == "高", "threat report buckets focused open meld pressure")
	check(str(threat_report.get("plan_label", "")) == "万", "threat report names exposed suit plan")
	check(not threat_report.get("safe_tiles", []).is_empty(), "threat report suggests safe tiles")
	check(scene.opponent_threat_summary(0).find("万") >= 0, "advisor threat summary names exposed suit")
	check(scene.opponent_threat_summary(0).find("安牌") >= 0, "advisor threat summary names safe tile candidates")
	check(scene.ai_advice_summary(0, 2).find("防守") >= 0, "advisor includes defensive threat line")
	check(str(scene.opponent_seat_threat_report(0, 1).get("plan_label", "")) == "万", "seat threat report names opponent plan")
	check(scene.opponent_seat_threat_badge_text(1, 0).find("万") >= 0, "seat threat badge names exposed suit")
	check(scene.opponent_seat_threat_line(1, 0).find("威万") >= 0, "seat threat line summarizes danger")
	scene.clear_threat_report_cache()
	var render_threat_context = scene.make_ai_evaluation_context(0, scene.visible_tile_counts())
	var render_threat_reports = scene.render_seat_threat_reports(0, render_threat_context)
	var render_risk_cache: Dictionary = render_threat_context.get("risk_vectors", {})
	var render_safety_cache: Dictionary = render_threat_context.get("safety_labels", {})
	check(render_risk_cache.size() > 0 and render_safety_cache.size() > 0, "seat render threat reports share one AI risk/safety context")
	var render_risk_cache_size = render_risk_cache.size()
	scene.render_seat_threat_reports(0, render_threat_context)
	check(render_risk_cache.size() == render_risk_cache_size, "seat render threat report cache avoids repeated risk scans")
	check(render_threat_reports.has(1) and scene.opponent_seat_threat_badge_text_from_report(render_threat_reports[1]) == scene.opponent_seat_threat_badge_text(1, 0), "seat render threat reports reuse one report for badge text")
	check(scene.opponent_seat_threat_line_from_report(render_threat_reports[1]) == scene.opponent_seat_threat_line(1, 0), "seat render threat reports reuse one report for line text")
	var threat_seat_parent = Control.new()
	root.add_child(threat_seat_parent)
	scene.draw_seat(threat_seat_parent, 1, scene.rect_full(0.0, 0.0, 1.0, 1.0), "right", render_threat_reports)
	check(has_label_text(threat_seat_parent, scene.opponent_seat_threat_badge_text(1, 0)), "seat panel renders opponent threat badge")
	threat_seat_parent.queue_free()
	scene.players[1]["discards"].append("2W")
	check(scene.main_threat_opponent(0) == 1, "main threat opponent is identified without using safe tile recursion")
	check(scene.is_main_threat_genbutsu("2W", 0), "tile discarded by main threat is recognized as genbutsu")
	check(scene.tile_safety_label("2W", 0) == "现", "main-threat genbutsu gets safety label")
	check(scene.discard_safety_text({"safety_label": "现", "risk_label": "低"}) == "主现物", "AI brief names main-threat genbutsu")
	check(scene.ai_safety_bonus("现", 1.8, 3) > scene.ai_safety_bonus("熟", 1.8, 3) and scene.ai_safety_bonus("现", 1.8, 3) < scene.ai_safety_bonus("安", 1.8, 3), "main-threat genbutsu safety bonus sits between visible safe and all-safe")
	var genbutsu_tile = scene.make_tile_view("2W", Vector2(62, 84), true, Callable(), false, "现")
	check(count_label_nodes(genbutsu_tile) == 0 and has_visible_tile_art(genbutsu_tile), "tile view keeps main-threat genbutsu as image-only tile")
	genbutsu_tile.queue_free()
	var danger_source = scene.discard_danger_source_report("5W", 0)
	check(int(danger_source.get("opponent", -1)) == 1, "danger source identifies the opponent driving discard risk")
	check(scene.discard_danger_text(danger_source).find("青竹道人") >= 0 and scene.discard_danger_text(danger_source).find("万") >= 0, "danger source text names opponent and plan")
	var feed_report = scene.discard_feed_risk_report("5W", 0)
	var cached_feed_report = scene.discard_feed_risk_report("5W", 0, visible_risk_counts)
	var feed_context = scene.make_ai_evaluation_context(0, visible_risk_counts)
	var contextual_feed_report = scene.discard_feed_risk_report("5W", 0, visible_risk_counts, feed_context)
	var contextual_feed_details: Array = contextual_feed_report.get("details", [])
	var expected_feed_opponent = -1
	if not contextual_feed_details.is_empty() and typeof(contextual_feed_details[0]) == TYPE_DICTIONARY:
		var contextual_feed_detail: Dictionary = contextual_feed_details[0]
		expected_feed_opponent = int(contextual_feed_detail.get("opponent", -1))
	var cached_contextual_feed_report = scene.discard_feed_risk_report("5W", 0, visible_risk_counts, feed_context)
	var cached_contextual_feed_details: Array = cached_contextual_feed_report.get("details", [])
	if not cached_contextual_feed_details.is_empty() and typeof(cached_contextual_feed_details[0]) == TYPE_DICTIONARY:
		var cached_contextual_feed_detail: Dictionary = cached_contextual_feed_details[0]
		cached_contextual_feed_detail["opponent"] = 9
	var refreshed_contextual_feed_report = scene.discard_feed_risk_report("5W", 0, visible_risk_counts, feed_context)
	var refreshed_contextual_feed_details: Array = refreshed_contextual_feed_report.get("details", [])
	var refreshed_feed_opponent = -1
	if not refreshed_contextual_feed_details.is_empty() and typeof(refreshed_contextual_feed_details[0]) == TYPE_DICTIONARY:
		var refreshed_contextual_feed_detail: Dictionary = refreshed_contextual_feed_details[0]
		refreshed_feed_opponent = int(refreshed_contextual_feed_detail.get("opponent", -1))
	var low_feed_report = scene.discard_feed_risk_report("9B", 0)
	check(float(feed_report.get("score", 0.0)) > float(low_feed_report.get("score", 0.0)), "same-suit middle discard has higher public feed risk")
	check(is_equal_approx(float(feed_report.get("score", -1.0)), float(cached_feed_report.get("score", -2.0))), "feed risk report can reuse visible count snapshots")
	check(expected_feed_opponent >= 0 and refreshed_feed_opponent == expected_feed_opponent, "feed risk report cache protects nested details with targeted copies")
	check(scene.discard_feed_risk_text(feed_report).find("青竹道人") >= 0, "feed risk text names the likely claimant")
	var feed_ai_report = scene.build_ai_discard_report(0, "5W", shared_simulated_hand, 0)
	check(float(feed_ai_report.get("feed_risk", 0.0)) > 0.0, "AI discard report includes feed risk")
	check(scene.discard_safety_text(feed_ai_report).find("喂") >= 0, "discard safety text includes feed risk")
	scene.players[1]["melds"] = []
	scene.players[1]["discards"] = []
	var no_feed_ai_report = scene.build_ai_discard_report(0, "5W", shared_simulated_hand, 0)
	check(float(no_feed_ai_report.get("score", 0.0)) > float(feed_ai_report.get("score", 0.0)), "feed risk lowers discard score")
	scene.players[1]["melds"] = []
	scene.players[1]["discards"] = ["1W", "9W", "1T", "9T", "1B", "9B", "E", "S", "N", "R", "Z", "F", "P"]
	scene.players[2]["melds"] = []
	scene.players[2]["discards"] = []
	scene.players[3]["melds"] = []
	scene.players[3]["discards"] = []
	scene.wall.clear()
	for n in range(20):
		scene.wall.append("1W")
	var readiness_report = scene.opponent_readiness_report(0, 1)
	check(str(readiness_report.get("label", "")).find("听") >= 0, "late concealed opponent gets near-tenpai readiness label")
	check(readiness_report.get("reasons", []).has("末盘") and readiness_report.get("reasons", []).has("弃牌多"), "readiness report explains late discard pressure")
	var readiness_threat = scene.opponent_threat_report(0)
	check(int(readiness_threat.get("opponent", -1)) == 1 and str(readiness_threat.get("readiness_label", "")).find("听") >= 0, "threat report includes concealed readiness pressure")
	check(scene.opponent_threat_summary(0).find("听") >= 0, "advisor threat summary names near-tenpai pressure")
	check(scene.opponent_seat_threat_badge_text(1, 0).find("听") >= 0, "seat badge shows near-tenpai pressure")
	var ready_mid_risk = scene.deal_in_risk_score("5W", 0)
	var ready_defense = scene.ai_defense_weight(0, 3)
	scene.players[1]["discards"] = []
	scene.wall.clear()
	for n in range(84):
		scene.wall.append("1W")
	var quiet_mid_risk = scene.deal_in_risk_score("5W", 0)
	var quiet_defense = scene.ai_defense_weight(0, 3)
	check(ready_mid_risk > quiet_mid_risk, "near-tenpai readiness raises middle tile deal-in risk")
	check(ready_defense > quiet_defense, "near-tenpai readiness raises AI defense weight")
	scene.players[1]["melds"] = [["3W", "4W", "5W"], ["6W", "7W", "8W"]]
	scene.players[1]["discards"] = ["1T", "9B", "E", "P", "2W"]
	check(scene.risk_badge_text("高") == "高危" and scene.risk_badge_text("低") == "低", "risk badge text is compact")
	check(scene.risk_badge_text("现") == "现", "main-threat genbutsu badge text is compact")
	check(scene.tile_risk_color("高").r > scene.tile_risk_color("低").r, "risk badge colors distinguish high danger")
	var risk_tile = scene.make_tile_view("5W", Vector2(62, 84), true, Callable(), false, "高")
	check(count_label_nodes(risk_tile) == 0 and has_visible_tile_art(risk_tile), "tile view keeps high risk state image-only")
	risk_tile.queue_free()
	scene.start_offline()
	scene.offline_phase = "await_discard"
	scene.current_seat = 0
	scene.offline_turn_needs_draw = false
	scene.wall.clear()
	scene.players[0]["hand"] = ["1W", "2W", "3W", "5W", "7W", "8W", "9W", "1T", "2T", "3T", "1B", "2B", "3B", "P"]
	scene.players[0]["discards"] = []
	scene.players[0]["melds"] = []
	scene.players[1]["hand"] = []
	scene.players[1]["melds"] = [["3W", "4W", "5W"], ["6W", "7W", "8W"], ["2T", "2T", "2T"]]
	scene.players[1]["discards"] = ["1T", "9T", "1B", "9B", "E", "S", "N", "R", "Z", "F", "P", "8B"]
	scene.players[2]["hand"] = []
	scene.players[2]["melds"] = []
	scene.players[2]["discards"] = []
	scene.players[3]["hand"] = []
	scene.players[3]["melds"] = []
	scene.players[3]["discards"] = []
	var confirm_danger_report = scene.discard_report_for_tile("5W")
	check(confirm_danger_report.is_empty(), "human discard risk report is disabled")
	var confirm_danger_index = scene.find_tile_in_hand(scene.players[0]["hand"], "5W")
	var hand_size_before_danger = scene.players[0]["hand"].size()
	scene.human_discard_by_tile("5W")
	check(scene.players[0]["hand"].size() == hand_size_before_danger - 1, "human discard commits immediately without AI confirmation")
	check(scene.players[0]["discards"].has("5W"), "human discard path commits selected tile")
	check(scene.offline_phase == "resolving", "human discard enters resolving phase immediately to block accidental second taps")
	scene.human_discard(confirm_danger_index)
	check(scene.players[0]["hand"].size() == hand_size_before_danger - 1, "resolving phase blocks accidental repeated discard taps")
	check(not scene.has_pending_danger_discard(), "human discard does not enter pending danger confirmation")
	var confirm_hand_parent = Control.new()
	root.add_child(confirm_hand_parent)
	scene.draw_hand(confirm_hand_parent)
	check(not has_label_text(confirm_hand_parent, "确认") and not has_label_text(confirm_hand_parent, "高危"), "hand does not render AI risk confirmation badges")
	confirm_hand_parent.queue_free()
	check(scene.hand_tray_text().find("再点确认") < 0, "hand tray does not ask for AI danger confirmation")
	var safe_alternatives = scene.safe_discard_alternative_reports("5W", 2)
	check(safe_alternatives.is_empty(), "human safe alternative reports are disabled")
	scene.mode = "menu"
	await process_frame
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.current_seat = 0
	scene.offline_turn_needs_draw = false
	scene.players[1]["discards"] = ["9W"]
	scene.players[2]["discards"] = ["9W"]
	scene.players[3]["discards"] = ["9W"]
	check(scene.is_tile_safe_against_all("9W", 0), "tile discarded by all opponents is all-safe")
	check(scene.tile_safety_label("9W", 0) == "安", "all-safe tile gets safety label")
	var all_safe_report = scene.build_ai_discard_report(0, "9W", shared_simulated_hand, 0)
	check(str(all_safe_report.get("safety_label", "")) == "安", "AI report marks all-safe discard")
	check(scene.discard_safety_text(all_safe_report) == "全现物", "AI brief safety text names all-safe discard")
	check(str(all_safe_report.get("stance", "")) != "", "AI report includes attack-defense stance")
	scene.wall.clear()
	scene.players[1]["melds"] = [["3W", "4W", "5W"], ["6W", "7W", "8W"], ["2T", "2T", "2T"]]
	scene.players[1]["discards"] = ["9W", "1T", "9T", "1B", "9B", "E", "S", "N", "R", "Z", "F", "P"]
	scene.players[2]["discards"] = ["9W"]
	scene.players[3]["discards"] = ["9W"]
	var defensive_report = scene.build_ai_discard_report(0, "9W", ["1W", "4W", "7W", "2T", "5T", "8T", "1B", "4B", "7B", "E", "S", "N", "P"], 0)
	check(float(defensive_report.get("safety_bonus", 0.0)) > 0.0, "AI report gives defensive bonus to all-safe discard under pressure")
	check(float(defensive_report.get("emergency_defense", 0.0)) > 0.0, "emergency defense boosts all-safe discard under pressure")
	check(str(defensive_report.get("stance", "")) == "防守", "AI report switches to defense stance under pressure")
	var unsafe_defensive_report = scene.build_ai_discard_report(0, "5W", ["1W", "4W", "7W", "2T", "5T", "8T", "1B", "4B", "7B", "E", "S", "N", "P"], 0)
	check(float(unsafe_defensive_report.get("emergency_defense", 0.0)) < 0.0, "emergency defense penalizes unsafe middle discard under pressure")
	var severe_threat = scene.opponent_threat_report(0)
	check(str(severe_threat.get("level", "")) == "危", "threat report escalates severe open-meld pressure")
	scene.offline_phase = "await_discard"
	scene.current_seat = 0
	scene.offline_turn_needs_draw = false
	scene.current_human_advice = []
	var safest_report = scene.safest_discard_report()
	check(safest_report.is_empty(), "human safest discard shortcut is disabled")
	var safest_button_text = "最安%s" % scene.tile_label("9W")
	var safest_hint_text = "最安打%s" % scene.tile_label("9W")
	var safe_action_parent = Control.new()
	root.add_child(safe_action_parent)
	scene.draw_actions(safe_action_parent)
	check(not has_button_text(safe_action_parent, safest_button_text), "action bar does not render safest discard shortcut")
	safe_action_parent.queue_free()
	check(scene.human_hint_text().find(safest_hint_text) < 0, "human hint does not include safest discard")
	check(scene.hand_tray_text().find(safest_hint_text) < 0, "hand tray does not include safest discard")
	var alternatives_without_safe = scene.discard_action_alternative_reports(["9W"], 3)
	check(alternatives_without_safe.is_empty(), "human action alternative helper is disabled under pressure")
	check(scene.threat_safe_tile_labels(0, "suit", 0, 2)[0] == scene.tile_label("9W"), "threat safe tile labels keep all-safe tile first after one-pass sort")
	var threat_safe_top_two = scene.threat_safe_tile_labels(0, "suit", 0, 2)
	var threat_safe_full = scene.threat_safe_tile_labels(0, "suit", 0, 99)
	check(threat_safe_top_two == threat_safe_full.slice(0, min(2, threat_safe_full.size())) and scene.threat_safe_tile_labels(0, "suit", 0, 0).is_empty(), "threat safe tile labels keep top-N insertion order without full candidate sort")
	var threat_safe_context = scene.make_ai_evaluation_context(0, scene.visible_tile_counts())
	var cached_threat_safe_labels = scene.threat_safe_tile_labels(0, "suit", 0, 2, threat_safe_context)
	var threat_safe_risk_cache: Dictionary = threat_safe_context.get("risk_vectors", {})
	var threat_safe_risk_cache_size = threat_safe_risk_cache.size()
	check(scene.threat_safe_tile_labels(0, "suit", 0, 2, threat_safe_context) == cached_threat_safe_labels and threat_safe_risk_cache.size() == threat_safe_risk_cache_size, "threat safe tile labels reuse risk vector scores without summary allocation")
	var safe_tile = scene.make_tile_view("9W", Vector2(62, 84), true, Callable(), false, "安")
	check(count_label_nodes(safe_tile) == 0 and has_visible_tile_art(safe_tile), "tile view keeps all-safe state image-only")
	safe_tile.queue_free()
	scene.players[1]["discards"] = []
	scene.players[1]["melds"] = [["8W", "8W", "8W"]]
	scene.players[2]["discards"] = []
	scene.players[3]["discards"] = []
	var visible_safety_counts = scene.visible_tile_counts()
	check(scene.tile_safety_label("8W", 0) == "熟", "three visible copies get safe-live tile label")
	check(scene.tile_safety_label("8W", 0, visible_safety_counts) == "熟", "tile safety label can reuse visible count snapshots")
	check(scene.discard_safety_text({"safety_label": "熟", "risk_label": "低"}) == "熟张", "AI brief safety text names fully visible tile")
	check(scene.ai_safety_bonus("安", 1.8, 3) > scene.ai_safety_bonus("熟", 1.8, 3), "all-safe gets stronger defense bonus than fully visible tile")
	scene.players[1]["melds"] = [["3W", "4W", "5W"]]
	scene.players[1]["discards"] = ["4W", "1T", "9T", "E", "P", "9B"]
	scene.players[2]["discards"] = []
	scene.players[3]["discards"] = []
	check(scene.is_suji_safe_against_opponent("7W", 1), "discarded four creates suji safety for seven")
	var suji_context = scene.make_ai_evaluation_context(0, scene.visible_tile_counts())
	check(scene.is_suji_safe_against_opponent("7W", 1, suji_context), "suji safety can use indexed opponent discard context without anchor arrays")
	check(not scene.is_suji_safe_against_opponent("8W", 1), "unrelated tile is not suji safe")
	check(scene.tile_safety_label("7W", 0) == "筋", "suji tile gets weak safety label")
	check(scene.discard_safety_text({"safety_label": "筋", "risk_label": "中"}) == "筋线", "AI brief safety text names suji tile")
	check(scene.deal_in_risk_score("1W", 0) < scene.deal_in_risk_score("2W", 0), "outside suji lowers deal-in risk against pressure")
	check(scene.risk_badge_text("筋") == "筋", "suji badge text is compact")
	var suji_tile = scene.make_tile_view("7W", Vector2(62, 84), true, Callable(), false, "筋")
	check(count_label_nodes(suji_tile) == 0 and has_visible_tile_art(suji_tile), "tile view keeps suji safety state image-only")
	suji_tile.queue_free()
	scene.players[1]["melds"] = [["4W", "4W", "4W"]]
	scene.players[1]["discards"] = ["1T", "9T", "E", "P", "9B", "2B"]
	scene.players[2]["discards"] = []
	scene.players[3]["discards"] = []
	check(scene.is_kabe_safe_against_opponent("5W", 1), "three visible adjacent tiles create wall safety")
	var kabe_safety_counts = scene.visible_tile_counts()
	check(scene.is_kabe_safe_against_opponent("5W", 1, kabe_safety_counts), "wall safety can use indexed visible count snapshots without wall tile arrays")
	check(not scene.is_kabe_safe_against_opponent("5T", 1), "unblocked suit is not wall safe")
	check(scene.tile_safety_label("5W", 0) == "壁", "wall-safe tile gets weak safety label")
	check(scene.discard_safety_text({"safety_label": "壁", "risk_label": "中"}) == "壁牌", "AI brief safety text names wall safety")
	var wall_risk = scene.deal_in_risk_score("5W", 0)
	scene.players[1]["melds"] = [["6W", "7W", "8W"]]
	check(wall_risk < scene.deal_in_risk_score("5W", 0), "wall safety lowers deal-in risk against matching suit pressure")
	scene.players[1]["melds"] = [["4W", "4W", "4W"]]
	check(scene.risk_badge_text("壁") == "壁", "wall badge text is compact")
	var kabe_tile = scene.make_tile_view("5W", Vector2(62, 84), true, Callable(), false, "壁")
	check(count_label_nodes(kabe_tile) == 0 and has_visible_tile_art(kabe_tile), "tile view keeps wall safety state image-only")
	kabe_tile.queue_free()
	check(scene.ai_safety_bonus("壁", 1.8, 3) > 0.0 and scene.ai_safety_bonus("壁", 1.8, 3) < scene.ai_safety_bonus("熟", 1.8, 3), "wall safety gets weaker defense bonus than fully visible tile")
	check(scene.ai_safety_bonus("安", 1.8, 0) < scene.ai_safety_bonus("安", 1.8, 3), "tenpai reduces safety bonus")
	check(scene.ai_stance_label(1.6, 3) == "防守" and scene.ai_stance_label(0.8, 0) == "进攻", "AI stance labels attack and defense modes")
	check(scene.ai_advice_summary(0, 2).find("模式") >= 0, "advisor includes AI stance line")
	check(scene.risk_badge_text("安") == "安" and scene.risk_badge_text("熟") == "熟", "safe badge text is compact")
	scene.start_offline()
	var defensive_peng_hand = ["E", "E", "1W", "3W", "5W", "7W", "9W", "1T", "3T", "5T", "7B", "9B", "P"]
	scene.players[2]["hand"] = defensive_peng_hand.duplicate()
	scene.players[2]["melds"] = []
	scene.players[2]["discards"] = []
	scene.players[1]["hand"] = []
	scene.players[1]["melds"] = []
	scene.players[1]["discards"] = []
	scene.players[3]["hand"] = []
	scene.players[3]["melds"] = []
	scene.players[3]["discards"] = []
	scene.wall.clear()
	for n in range(84):
		scene.wall.append("1W")
	var low_pressure_peng = scene.build_ai_claim_report(2, "peng", "E")
	check(bool(low_pressure_peng.get("allow", false)), "AI may peng for shape value when pressure is low")
	check(str(low_pressure_peng.get("reason", "")) == "牌型收益", "low pressure peng is explained by shape value")
	var claim_count_snapshot = scene.tile_counts(defensive_peng_hand)
	var claim_after_counts = claim_count_snapshot.duplicate()
	var claim_after_hand = defensive_peng_hand.duplicate()
	check(scene.consume_tile_count(claim_after_counts, "E", 2) and scene.remove_known_tiles(claim_after_hand, "E", 2), "claim count snapshot consumes peng tiles without rescanning availability")
	check(scene.calculate_min_shanten_from_counts(claim_after_counts, scene.players[2]["melds"].size() + 1) == scene.calculate_min_shanten(claim_after_hand, scene.players[2]["melds"].size() + 1), "claim count snapshot keeps post-peng shanten equivalent to array removal")
	check(is_equal_approx(scene.evaluate_ai_hand_from_counts(claim_after_counts), scene.evaluate_ai_hand(claim_after_hand)), "claim count snapshot keeps post-peng shape value equivalent to array removal")
	scene.players[2]["hand"] = seven_pairs_claim_hand()
	scene.players[2]["melds"] = []
	var seven_pairs_peng = scene.build_ai_claim_report(2, "peng", "E")
	check(not bool(seven_pairs_peng.get("allow", true)), "AI declines peng that breaks seven pairs route")
	check(bool(seven_pairs_peng.get("declined_by_plan", false)), "AI claim report marks seven pairs route decline")
	check(str(seven_pairs_peng.get("reason", "")) == "保七对", "seven pairs claim decline reason is visible")
	check(scene.claim_report_reason_text(seven_pairs_peng).find("保七对") >= 0, "claim report reason explains seven pairs route")
	check(not scene.should_ai_peng(2, "E"), "AI peng helper preserves seven pairs route")
	scene.players[0]["hand"] = []
	scene.players[0]["discards"] = ["E"]
	check(scene.choose_ai_claim(0, "E").is_empty(), "AI does not choose peng that breaks seven pairs route")
	scene.wall.clear()
	scene.players[1]["melds"] = [["3W", "4W", "5W"], ["6W", "7W", "8W"], ["2T", "2T", "2T"]]
	scene.players[1]["discards"] = ["9W", "1T", "9T", "1B", "9B", "E", "S", "N", "R", "Z", "F", "P"]
	scene.players[2]["hand"] = defensive_peng_hand.duplicate()
	var high_pressure_peng = scene.build_ai_claim_report(2, "peng", "E")
	check(not bool(high_pressure_peng.get("allow", true)), "AI declines non-improving peng under high pressure")
	check(bool(high_pressure_peng.get("declined_by_pressure", false)), "AI claim report marks pressure decline")
	check(str(high_pressure_peng.get("reason", "")) == "高压防守", "pressure decline reason is visible")
	check(scene.claim_report_reason_text(high_pressure_peng).find("高压防守") >= 0, "claim report reason explains pressure defense")
	check(not scene.should_ai_peng(2, "E"), "AI peng helper uses pressure-aware report")
	scene.players[0]["hand"] = []
	scene.players[0]["discards"] = ["E"]
	var high_pressure_claim = scene.choose_ai_claim(0, "E")
	check(high_pressure_claim.is_empty(), "AI does not choose defensive peng from high-pressure discard")
	var weak_peng = scene.build_ai_claim_report(2, "peng", "5W")
	check(not bool(weak_peng.get("declined_by_pressure", false)), "shape-insufficient claims are not mislabeled as pressure declines")
	var pressure_chi_hand = ["2W", "4W", "1W", "7W", "9W", "1T", "3T", "5T", "7T", "1B", "4B", "7B", "P"]
	scene.players[2]["hand"] = pressure_chi_hand.duplicate()
	var pressure_chi_choice = scene.best_chi_choice(scene.players[2]["hand"], "3W")
	var pressure_chi = scene.build_ai_claim_report(2, "chi", "3W", pressure_chi_choice)
	check(bool(pressure_chi.get("allow", false)) and str(pressure_chi.get("reason", "")) == "降向听", "AI still accepts shanten-improving chi under pressure")
	var shared_claim_context = scene.make_ai_claim_context(2, scene.visible_tile_counts())
	var shared_pressure_chi = scene.build_ai_claim_report(2, "chi", "3W", pressure_chi_choice, shared_claim_context)
	check(bool(shared_pressure_chi.get("allow", false)) == bool(pressure_chi.get("allow", false)) and str(shared_pressure_chi.get("reason", "")) == str(pressure_chi.get("reason", "")) and is_equal_approx(float(shared_pressure_chi.get("forced_discard_risk", 0.0)), float(pressure_chi.get("forced_discard_risk", 0.0))), "AI claim report reuses shared claim context without changing pressure chi")
	var shared_best_chi = scene.best_ai_chi_claim(2, "3W", 1, shared_claim_context)
	check(str(shared_best_chi.get("claim", "")) == "chi" and scene.same_tile_list(shared_best_chi.get("chi_choice", {}).get("needed", []), pressure_chi_choice.get("needed", [])), "AI chi selection can reuse one shared claim context")
	var shared_claim_eval_context: Dictionary = shared_claim_context.get("eval_context", {})
	var shared_claim_pressure_context: Dictionary = shared_claim_context.get("pressure_context", {})
	var shared_claim_risk_cache: Dictionary = shared_claim_eval_context.get("risk_vectors", {})
	check(not shared_claim_pressure_context.is_empty() and shared_claim_risk_cache.size() > 0, "AI claim context precomputes pressure and fills shared risk cache")
	var shared_claim_risk_cache_size = shared_claim_risk_cache.size()
	scene.build_ai_claim_report(2, "chi", "3W", pressure_chi_choice, shared_claim_context)
	check(shared_claim_risk_cache.size() == shared_claim_risk_cache_size, "AI claim report reuses risk cache on repeated shared-context checks")
	var chi_after_counts = scene.tile_counts(pressure_chi_hand)
	var chi_after_hand = pressure_chi_hand.duplicate()
	check(scene.consume_tile_list_counts(chi_after_counts, pressure_chi_choice.get("needed", [])) and scene.remove_known_tile_list(chi_after_hand, pressure_chi_choice.get("needed", [])), "claim count snapshot consumes chi tiles without rescanning availability")
	check(scene.calculate_min_shanten_from_counts(chi_after_counts, scene.players[2]["melds"].size() + 1) == scene.calculate_min_shanten(chi_after_hand, scene.players[2]["melds"].size() + 1), "claim count snapshot keeps post-chi shanten equivalent to array removal")
	var post_claim_after = pressure_chi_hand.duplicate()
	scene.remove_tile_list(post_claim_after, pressure_chi_choice.get("needed", []))
	var post_claim_after_before = post_claim_after.duplicate()
	var chi_after_counts_before_post_eval = chi_after_counts.duplicate()
	var baseline_post_claim = scene.best_ai_post_claim_discard_report(2, post_claim_after, scene.players[2]["melds"].size() + 1)
	var post_claim_context = scene.make_ai_evaluation_context(2, scene.visible_tile_counts())
	var seeded_post_claim_pressure = scene.ai_pressure_context(2, post_claim_context)
	seeded_post_claim_pressure["sentinel"] = 77
	post_claim_context["pressure_context"] = seeded_post_claim_pressure
	var cached_post_claim = scene.best_ai_post_claim_discard_report(2, post_claim_after, scene.players[2]["melds"].size() + 1, post_claim_context)
	var counted_post_claim = scene.best_ai_post_claim_discard_report(2, post_claim_after, scene.players[2]["melds"].size() + 1, post_claim_context, chi_after_counts)
	var post_claim_risk_cache: Dictionary = post_claim_context.get("risk_vectors", {})
	var post_claim_safety_cache: Dictionary = post_claim_context.get("safety_labels", {})
	check(str(cached_post_claim.get("tile", "")) == str(baseline_post_claim.get("tile", "")) and is_equal_approx(float(cached_post_claim.get("score", 0.0)), float(baseline_post_claim.get("score", 0.0))), "post-claim discard evaluation reuses AI context without changing the best discard")
	check(str(counted_post_claim.get("tile", "")) == str(cached_post_claim.get("tile", "")) and is_equal_approx(float(counted_post_claim.get("score", 0.0)), float(cached_post_claim.get("score", 0.0))), "post-claim discard evaluation can reuse post-claim hand counts without changing the best discard")
	check(scene.same_tile_list(post_claim_after, post_claim_after_before) and chi_after_counts == chi_after_counts_before_post_eval, "post-claim discard evaluation reuses working hand and count arrays without mutating inputs")
	check(int(post_claim_context.get("pressure_context", {}).get("sentinel", 0)) == 77, "post-claim discard evaluation keeps the precomputed pressure context")
	check(post_claim_risk_cache.size() > 0 and post_claim_safety_cache.size() > 0, "post-claim discard evaluation fills shared risk and safety caches")
	var post_claim_risk_cache_size = post_claim_risk_cache.size()
	scene.best_ai_post_claim_discard_report(2, post_claim_after, scene.players[2]["melds"].size() + 1, post_claim_context)
	check(post_claim_risk_cache.size() == post_claim_risk_cache_size, "post-claim discard evaluation reuses cached risk vectors on repeated checks")
	var pressure_chi_claim = scene.choose_ai_claim(1, "3W")
	check(str(pressure_chi_claim.get("claim", "")) == "chi" and int(pressure_chi_claim.get("seat", -1)) == 2, "AI chooses pressure chi when it improves shanten")
	var grouped_hand = ["1W", "2W", "1T", "2T", "1B", "E", "P", "H1"]
	check(scene.hand_group_index("1W") == 0 and scene.hand_group_index("1T") == 1 and scene.hand_group_index("1B") == 2, "hand groups number suits")
	check(scene.hand_group_index("E") == scene.hand_group_index("P"), "hand groups honor tiles together")
	check(scene.hand_group_index("H1") > scene.hand_group_index("E"), "hand groups flowers after honors")
	check(not scene.should_insert_hand_group_gap(grouped_hand, 1), "hand group gap is skipped inside a suit")
	check(scene.should_insert_hand_group_gap(grouped_hand, 2), "hand group gap appears between suits")
	check(scene.should_insert_hand_group_gap(grouped_hand, 5), "hand group gap appears before honors")
	check(scene.should_insert_hand_group_gap(grouped_hand, 7), "hand group gap appears before flowers")
	var spacer = scene.make_hand_group_spacer(84.0)
	check(spacer.custom_minimum_size.x >= 10.0 and spacer.get_child_count() == 1, "hand group spacer has stable width and divider")
	spacer.queue_free()
	var crowded_hand = ["1W", "2W", "3W", "4W", "1T", "2T", "3T", "1B", "2B", "3B", "E", "S", "P", "H1"]
	var narrow_hand_content = Vector2(960.0 * 0.840 * 0.970, 540.0 * 0.220 * 0.810)
	check(scene.HAND_LAYOUT_CANDIDATES.size() == 4 and float(scene.HAND_LAYOUT_CANDIDATES[0][0]) == 12.0 and int(scene.HAND_LAYOUT_CANDIDATES[3][1]) == 1, "hand layout reuses fixed spacing candidates")
	var crowded_hand_layout = scene.hand_layout_metrics_for_content(crowded_hand, narrow_hand_content)
	check(scene.hand_layout_fits_content(crowded_hand, crowded_hand_layout), "crowded 14-tile hand layout fits a narrow landscape tray")
	check(float(crowded_hand_layout.get("tile_width", 0.0)) >= scene.HAND_TILE_MIN_TOUCH_WIDTH, "crowded hand keeps a practical touch width on narrow landscape")
	check(int(crowded_hand_layout.get("separation", 9)) <= 3 and float(crowded_hand_layout.get("group_gap_width", 99.0)) <= 8.0, "crowded hand reduces spacing before shrinking tiles too far")
	var narrow_action_width = 960.0 * (0.975 - 0.305)
	check(scene.action_buttons_fit_available(8, narrow_action_width), "eight action buttons fit inside a narrow action bar")
	check(scene.action_button_width_for_available(8, narrow_action_width) >= scene.ACTION_BUTTON_MIN_TOUCH_WIDTH, "crowded action bar keeps practical button width")
	var action_layout_parent = Control.new()
	root.add_child(action_layout_parent)
	scene.action_bar = HBoxContainer.new()
	action_layout_parent.add_child(scene.action_bar)
	var action_press_count := {"value": 0}
	for label in ["吃123万", "吃234万", "吃345万", "碰", "杠", "胡", "过", "语音"]:
		scene.action_bar.add_child(scene.make_action_button(label, Color(0.25, 0.58, 0.48), func() -> void:
			action_press_count["value"] = int(action_press_count.get("value", 0)) + 1
		))
	check(scene.action_bar_button_count() == 8, "action bar layout counts buttons without building a button list")
	scene.finalize_action_bar_layout()
	var crowded_action_button = first_button(action_layout_parent)
	check(crowded_action_button != null and crowded_action_button.custom_minimum_size.x <= scene.ACTION_BUTTON_MAX_WIDTH and crowded_action_button.clip_text, "crowded action buttons are sized and clipped by final layout")
	crowded_action_button.emit_signal("button_down")
	check(int(action_press_count.get("value", 0)) == 1, "finalized action buttons still run callbacks on button down")
	action_layout_parent.queue_free()
	scene.action_bar = null

	scene.players[0]["flowers"] = 2
	var score = scene.calculate_win_score(0, "", true)
	check(int(score.get("fan", 0)) >= 4, "flowers are counted in score")
	check(scene.deal_in_risk_score("5W", 0) > scene.deal_in_risk_score("1W", 0), "middle tiles carry higher deal-in risk")
	scene.players[0]["flowers"] = 0
	scene.players[0]["melds"] = []
	scene.players[0]["hand"] = pure_one_suit_hand()
	var pure_score = scene.calculate_win_score(0, "", false)
	check(pure_score.get("reasons", []).has("清一色"), "pure one suit is scored")
	scene.players[0]["hand"] = mixed_one_suit_hand()
	var mixed_score = scene.calculate_win_score(0, "", false)
	check(mixed_score.get("reasons", []).has("混一色"), "mixed one suit is scored")
	check(not mixed_score.get("reasons", []).has("清一色"), "mixed one suit is not pure one suit")
	scene.players[0]["hand"] = full_straight_hand()
	var dragon_score = scene.calculate_win_score(0, "", false)
	check(dragon_score.get("reasons", []).has("一条龙"), "full straight is scored")
	scene.players[0]["hand"] = all_simples_hand()
	var simples_score = scene.calculate_win_score(0, "", false)
	check(simples_score.get("reasons", []).has("断幺九"), "all-simples hand is scored")
	scene.players[0]["hand"] = big_three_dragons_hand()
	var big_three_score = scene.calculate_win_score(0, "", false)
	check(big_three_score.get("reasons", []).has("大三元"), "big three dragons is scored")
	scene.players[0]["hand"] = small_three_dragons_hand()
	var small_three_score = scene.calculate_win_score(0, "", false)
	check(small_three_score.get("reasons", []).has("小三元"), "small three dragons is scored")
	scene.players[0]["hand"] = big_four_winds_hand()
	var big_four_score = scene.calculate_win_score(0, "", false)
	check(big_four_score.get("reasons", []).has("大四喜"), "big four winds is scored")
	scene.players[0]["hand"] = small_four_winds_hand()
	var small_four_score = scene.calculate_win_score(0, "", false)
	check(small_four_score.get("reasons", []).has("小四喜"), "small four winds is scored")
	scene.players[0]["hand"] = all_triplet_hand()
	var triplet_score = scene.calculate_win_score(0, "", false)
	check(triplet_score.get("reasons", []).has("碰碰胡"), "all triplets are scored")
	scene.players[0]["hand"] = all_honor_hand()
	var honor_score = scene.calculate_win_score(0, "", false)
	check(honor_score.get("reasons", []).has("字一色"), "all honors are scored")
	check(scene.score_points_for_fan(1) == 200, "score table one fan is correct")
	check(scene.score_points_for_fan(8) == 25600, "score table limit fan is correct")
	check(scene.score_points_for_fan(12) == 25600, "score table caps above limit")
	scene.players[0]["hand"] = winning_hand()
	scene.players[0]["melds"] = []
	scene.offline_last_draw = {"seat": 0, "source": "gang", "wall_empty": false}
	var gang_flower_score = scene.calculate_win_score(0, "", true)
	check(gang_flower_score.get("reasons", []).has("杠上开花"), "gang draw win is scored")
	scene.offline_last_draw = {"seat": 0, "source": "normal", "wall_empty": true}
	var final_draw_score = scene.calculate_win_score(0, "", true)
	check(final_draw_score.get("reasons", []).has("海底捞月"), "final draw win is scored")
	scene.players[0]["melds"] = [
		["1W", "1W", "1W"],
		["2T", "2T", "2T"],
		["3B", "3B", "3B"],
		["E", "E", "E"],
	]
	scene.players[0]["hand"] = ["P", "P"]
	var single_wait_score = scene.calculate_win_score(0, "", false)
	check(single_wait_score.get("reasons", []).has("大吊车"), "single pair after four melds is scored")
	check(scene.is_newer_version("1.0.26-godot", "1.0.25-godot"), "newer manifest version is detected")
	check(not scene.is_newer_version("1.0.25-godot", "1.0.25-godot"), "same manifest version is current")
	check(scene.tail_window_start(10, 3) == 7 and scene.tail_window_start(2, 8) == 0 and scene.tail_window_start(5, 0) == 5, "tail window helper avoids slice allocations with stable bounds")
	check(scene.join_tail_lines(["一", "二", "三", "四"], 2) == "三\n四" and scene.join_tail_lines(["一"], 4) == "一" and scene.join_tail_lines(["一"], 0) == "", "tail line join helper builds recent log text without temporary line arrays")
	var manifest = scene.parse_update_manifest({
		"version": "1.0.26-godot",
		"apkUrl": "https://example.com/YunzhuoMahjongGodot.apk",
		"apkSize": 123456,
		"sha256": "abc123",
		"releaseNotes": ["AI 优化", "UI 优化"],
	})
	check(str(manifest.get("url", "")) == "https://example.com/YunzhuoMahjongGodot.apk", "manifest apkUrl is parsed")
	check(str(manifest.get("notes", "")).find("AI 优化") >= 0, "manifest notes are parsed")
	check(int(manifest.get("size", 0)) == 123456, "manifest apk size is parsed")
	check(str(manifest.get("sha256", "")) == "abc123", "manifest sha is parsed")
	scene.update_release_notes = "第一条更新说明内容很长需要在更新弹窗里截断避免撑破布局\n第二条 UI 优化\n第三条 E2E 校验"
	var notes_summary = scene.update_release_notes_summary()
	check(notes_summary.find("第三条") < 0 and notes_summary.find("等3项") >= 0, "update dialog release notes are summarized")
	check(notes_summary.length() <= 56, "update dialog release notes summary stays compact")
	check(scene.safe_filename_part("1.0.26-godot 测试") == "1.0.26-godot___", "unsafe update filename chars are replaced")
	var hash_path = "user://offline-smoke-sha.bin"
	var hash_file = FileAccess.open(hash_path, FileAccess.WRITE)
	hash_file.store_buffer(PackedByteArray([97, 98, 99]))
	hash_file.close()
	var abc_sha = "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"
	check(scene.file_sha256(hash_path) == abc_sha, "download hash helper computes SHA-256")
	check(scene.is_valid_sha256(abc_sha), "valid SHA-256 is accepted")
	check(not scene.is_valid_sha256("abc123"), "short SHA-256 is rejected")
	scene.update_file_path = hash_path
	scene.update_remote_sha256 = "0000000000000000000000000000000000000000000000000000000000000000"
	check(not scene.verify_downloaded_update(), "download hash mismatch is rejected")
	check(not FileAccess.file_exists(hash_path), "bad downloaded update file is removed")
	hash_file = FileAccess.open(hash_path, FileAccess.WRITE)
	hash_file.store_buffer(PackedByteArray([97, 98, 99]))
	hash_file.close()
	scene.update_file_path = hash_path
	scene.update_remote_sha256 = abc_sha
	check(scene.verify_downloaded_update(), "matching downloaded update hash is accepted")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(hash_path))
	var online_state = scene.normalize_online_game_state({
		"type": "gameState",
		"game": {
			"room_code": "ROOM9",
			"playerSeat": 2,
			"turnSeat": 2,
			"state": "await_discard",
			"yourHand": [{"tile": "1W"}, "2W"],
			"wallRemaining": 55,
			"lastDiscard": {"tile": "5T", "seat": 1},
			"claimOptions": [{"claim": "胡"}, {"action": "chi"}, "pass"],
			"chiChoices": [
				["3T", "4T", "5T"],
				{"meld": ["4T", "5T", "6T"], "needed": ["4T", "6T"]},
			],
			"players": [
				{
					"index": 2,
					"nickname": "测试玩家",
					"tiles": ["1W", "2W"],
					"flowers": ["H1", "H2"],
					"river": ["E"],
					"sets": [{"tiles": ["3W", "4W", "5W"]}],
					"points": 26000,
				}
			],
		},
	})
	check(str(online_state.get("roomCode", "")) == "ROOM9", "online room code alias is normalized")
	check(int(online_state.get("youSeat", -1)) == 2, "online player seat alias is normalized")
	check(str(online_state.get("phase", "")) == "awaitDiscard", "online phase alias is normalized")
	check(str(online_state.get("lastDiscard", "")) == "5T", "nested last discard tile is normalized")
	check(int(online_state.get("lastDiscardSeat", -1)) == 1, "nested last discard seat is normalized")
	check(online_state.get("hand", []).size() == 2, "online hand aliases are normalized")
	check(online_state.get("pending", {}).get("options", []).has("hu"), "online claim option text is normalized")
	check(online_state.get("pending", {}).get("options", []).has("chi"), "online chi option object is normalized")
	check(online_state.get("pending", {}).get("chi_choices", []).size() == 2, "online chi choices are normalized")
	check(scene.chi_choice_label(online_state.get("pending", {}).get("chi_choices", [])[0]) == "吃345条", "online chi choice label is compact")
	var online_chi_payload = scene.online_claim_payload("chi", online_state.get("pending", {}).get("chi_choices", [])[1])
	check(str(online_chi_payload.get("claim", "")) == "chi", "online chi payload keeps claim")
	check(online_chi_payload.get("meld", []).size() == 3 and online_chi_payload.get("needed", []).size() == 2, "online chi payload includes meld and needed tiles")
	check(scene.normalize_online_message_kind({"type": "game_state"}) == "gameState", "online game state type alias is normalized")
	check(scene.normalize_online_message_kind({"event": "actionRejected"}) == "error", "online rejected event alias is normalized")
	check(scene.normalize_online_message_kind({"type": "actionAck"}) == "ack", "online ack type alias is normalized")
	check(scene.normalize_online_message_kind({"type": "message"}) == "info", "online plain message type is treated as info")
	scene.online_last_sent_action = "打出五条"
	scene.online_waiting_for_server = true
	scene.handle_online_message(JSON.stringify({"type": "actionAck"}))
	check(not scene.online_waiting_for_server and scene.online_feedback.find("确认") >= 0, "online ack clears waiting feedback")
	scene.handle_online_message(JSON.stringify({"event": "actionRejected", "reason": "不是你的回合"}))
	check(not scene.online_waiting_for_server and scene.online_feedback.find("不是你的回合") >= 0, "online rejection keeps server reason visible")
	scene.handle_online_message(JSON.stringify({"type": "message", "message": "服务器维护"}))
	check(scene.online_feedback.find("服务器维护") >= 0, "online plain server message remains visible")
	scene.online_room = {"code": "ROOM9", "players": [], "logs": []}
	scene.handle_online_message(JSON.stringify({"type": "roomLog", "text": "玩家加入房间"}))
	check(scene.online_room.get("logs", []).has("玩家加入房间"), "online room log event is appended")
	scene.handle_online_message(JSON.stringify({"type": "room_update", "roomCode": "ROOM8", "players": [], "logs": []}))
	check(scene.selected_room == "ROOM8", "online room update alias refreshes selected room")
	scene.mode = "online_game"
	scene.online_game = online_state
	check(scene.can_self_discard(), "normalized online state allows self discard")
	check(scene.get_wall_count() == 55, "normalized online wall count is used")
	check(scene.get_player_info(2).get("flowers", 0) == 2, "online flower array is counted")
	check(scene.get_discards(2).size() == 1 and scene.get_melds(2).size() == 1, "online discards and melds are normalized")
	scene.speech_queue.clear()
	scene.speech_queue_active = false
	scene.online_game = {}
	scene.online_announced_discard_key = ""
	scene.announce_online_game_audio(online_state)
	check(scene.speech_queue.is_empty() and scene.online_announced_discard_key != "", "initial online snapshot records discard without stale speech")
	var previous_online_audio_state = scene.normalize_online_game_state({
		"type": "gameState",
		"game": {
			"roomCode": "ROOM9",
			"youSeat": 2,
			"lastDiscard": "4T",
			"lastDiscardSeat": 1,
			"players": [{"seat": 1, "name": "上家", "discards": ["4T"]}],
		},
	})
	var next_online_audio_state = scene.normalize_online_game_state({
		"type": "gameState",
		"game": {
			"roomCode": "ROOM9",
			"youSeat": 2,
			"lastDiscard": "5T",
			"lastDiscardSeat": 1,
			"players": [{"seat": 1, "name": "上家", "discards": ["4T", "5T"]}],
		},
	})
	scene.online_game = previous_online_audio_state
	scene.online_announced_discard_key = scene.online_discard_audio_key(previous_online_audio_state)
	scene.speech_queue.clear()
	scene.announce_online_game_audio(next_online_audio_state)
	check(scene.speech_queue.size() == 1 and str(scene.speech_queue[0].get("text", "")) == "五条", "new online discard is queued for tile speech")
	var self_confirm_audio_state = scene.normalize_online_game_state({
		"type": "gameState",
		"game": {
			"roomCode": "ROOM9",
			"youSeat": 2,
			"lastDiscard": "7B",
			"lastDiscardSeat": 2,
			"players": [{"seat": 2, "name": "测试玩家", "discards": ["E", "7B"]}],
		},
	})
	scene.online_game = previous_online_audio_state
	scene.online_announced_discard_key = scene.online_discard_audio_key(previous_online_audio_state)
	scene.online_pending_local_discard_identity = scene.online_discard_identity(2, "7B")
	scene.speech_queue.clear()
	scene.announce_online_game_audio(self_confirm_audio_state)
	check(scene.speech_queue.is_empty() and scene.online_pending_local_discard_identity == "", "server echo of local discard does not duplicate speech")
	scene.speech_queue.clear()
	scene.online_game = {"youSeat": 2}
	scene.play_outgoing_online_action_audio({"type": "discard", "tile": "7B"})
	check(scene.online_pending_local_discard_identity == scene.online_discard_identity(2, "7B"), "outgoing online discard marks pending speech identity")
	check(scene.speech_queue.size() == 1 and str(scene.speech_queue[0].get("text", "")) == "七筒", "outgoing online discard queues tile speech immediately")
	scene.speech_queue.clear()
	var voice_frames = PackedVector2Array()
	voice_frames.append(Vector2(-1.0, -1.0))
	voice_frames.append(Vector2(0.0, 0.0))
	voice_frames.append(Vector2(1.0, 1.0))
	var encoded_voice = scene.encode_voice_frames(voice_frames)
	check(int(encoded_voice.get("bytes", 0)) == 6, "voice pcm16 byte size is correct")
	check(float(encoded_voice.get("peak", 0.0)) == 1.0, "voice peak is detected")
	var voice_payload = scene.build_voice_payload(voice_frames)
	check(str(voice_payload.get("type", "")) == "voiceMessage", "voice payload type is correct")
	check(int(voice_payload.get("sequence", -1)) == 0, "voice sequence starts at zero")
	var next_voice_payload = scene.build_voice_payload(voice_frames)
	check(int(next_voice_payload.get("sequence", -1)) == 1, "voice sequence increments")
	var voice_stream = scene.make_voice_stream(str(voice_payload.get("audio", "")), 16000, 1)
	check(voice_stream != null and voice_stream.data.size() == 6, "voice wav stream is created")

	scene.start_offline()
	scene.record_claim_source(1, 0, "chi")
	scene.record_claim_source(1, 0, "peng")
	scene.record_claim_source(1, 0, "gang")
	check(scene.package_payer_for(1) == 0, "third claim creates package liability")
	var payer_before = int(scene.players[0]["score"])
	var winner_before = int(scene.players[1]["score"])
	var other_before = int(scene.players[2]["score"])
	scene.players[1]["hand"] = winning_hand()
	scene.players[1]["melds"] = []
	var package_points = int(scene.calculate_win_score(1, "", true).get("points", 0)) * 3
	scene.finish_offline_round(1, "E", true, -1)
	check(int(scene.players[0]["score"]) == payer_before - package_points, "package payer covers all self draw payments")
	check(int(scene.players[1]["score"]) == winner_before + package_points, "package winner receives package payment")
	check(int(scene.players[2]["score"]) == other_before, "non-package opponent does not pay")
	check(scene.round_summary.find("包三搭") >= 0, "round summary mentions package liability")
	check(int(scene.last_score_deltas[0]) == -package_points and int(scene.last_score_deltas[1]) == package_points, "score deltas track package payment")
	check(scene.score_delta_text(1).begins_with(" +"), "positive score delta is formatted")
	check(scene.score_delta_text(0).find("-") >= 0, "negative score delta is formatted")
	check(scene.compact_score_text(98860) == "9.9万" and scene.compact_score_text(-172000) == "-17万", "compact score text keeps large UI scores short")

	scene.start_offline()
	scene.record_claim_source(1, 0, "chi")
	scene.record_claim_source(1, 0, "peng")
	scene.record_claim_source(1, 0, "gang")
	payer_before = int(scene.players[0]["score"])
	winner_before = int(scene.players[1]["score"])
	other_before = int(scene.players[2]["score"])
	scene.players[1]["hand"] = winning_hand()
	scene.players[1]["melds"] = []
	var discard_points = int(scene.calculate_win_score(1, "E", false).get("points", 0)) * 3
	scene.finish_offline_round(1, "E", false, 2)
	check(int(scene.players[2]["score"]) == other_before - discard_points, "discarder pays discard win despite package liability")
	check(int(scene.players[1]["score"]) == winner_before + discard_points, "winner receives discard payment despite package liability")
	check(int(scene.players[0]["score"]) == payer_before, "package payer does not cover discard win")
	check(scene.round_summary.find("包三搭") == -1, "discard win summary does not mention package payout")

	scene.start_offline()
	scene.offline_hand_number = 1
	scene.dealer_seat = 0
	scene.offline_dealer_repeat = false
	scene.players[1]["hand"] = winning_hand()
	scene.players[1]["melds"] = []
	scene.finish_offline_round(1, "E", false, 0)
	var winner_score = int(scene.players[1]["score"])
	check(scene.offline_phase == "ended", "round ends after win")
	check(not scene.offline_dealer_repeat, "dealer steps down after non-dealer win")
	check(scene.score_delta_text(1).find("+") >= 0 and scene.score_delta_text(0).find("-") >= 0, "round summary deltas include winner and payer changes")
	scene.start_next_offline_hand(false)
	check(scene.offline_hand_number == 2, "next hand increments hand number")
	check(scene.dealer_seat == 1, "dealer rotates to winner side")
	check(int(scene.players[1]["score"]) == winner_score, "scores persist across hands")

	scene.players[1]["hand"] = winning_hand()
	scene.players[1]["melds"] = []
	scene.finish_offline_round(1, "E", true, -1)
	var repeated_hand = scene.offline_hand_number
	check(scene.offline_dealer_repeat, "dealer repeats after dealer win")
	scene.start_next_offline_hand(false)
	check(scene.offline_hand_number == repeated_hand, "dealer repeat keeps hand number")
	check(scene.dealer_seat == 1, "dealer repeat keeps dealer")

	scene.offline_hand_number = 8
	scene.dealer_seat = 0
	scene.players[1]["hand"] = winning_hand()
	scene.players[1]["melds"] = []
	scene.finish_offline_round(1, "E", false, 0)
	check(scene.is_offline_match_finished(), "match finishes after final non-repeat hand")
	scene.start_next_offline_hand(false)
	check(scene.offline_hand_number == 8, "finished match does not advance")
	scene.queue_free()
	await process_frame
	await process_frame
	await process_frame
	quit(1 if failed else 0)

func check(condition: bool, message: String) -> void:
	if condition:
		return
	failed = true
	push_error("offline smoke test failed: " + message)

func count_descendants(node: Node) -> int:
	var count = 0
	for child in node.get_children():
		count += 1
		count += count_descendants(child)
	return count

func pcm16_peak(data: PackedByteArray) -> int:
	var peak = 0
	for i in range(0, data.size() - 1, 2):
		var sample = int(data[i]) | (int(data[i + 1]) << 8)
		if sample >= 32768:
			sample -= 65536
		peak = max(peak, abs(sample))
	return peak

func has_label_text(node: Node, text: String) -> bool:
	if node is Label and str((node as Label).text) == text:
		return true
	for child in node.get_children():
		if has_label_text(child, text):
			return true
	return false

func first_label_with_text_prefix(node: Node, prefix: String) -> Label:
	if node is Label and str((node as Label).text).begins_with(prefix):
		return node as Label
	for child in node.get_children():
		var label = first_label_with_text_prefix(child, prefix)
		if label != null:
			return label
	return null

func first_label_containing_text(node: Node, text: String) -> Label:
	if node is Label and str((node as Label).text).find(text) >= 0:
		return node as Label
	for child in node.get_children():
		var label = first_label_containing_text(child, text)
		if label != null:
			return label
	return null

func label_is_clipped(label: Label) -> bool:
	return label != null and label.clip_text and label.autowrap_mode == TextServer.AUTOWRAP_OFF and label.text_overrun_behavior == TextServer.OVERRUN_TRIM_ELLIPSIS

func count_label_nodes(node: Node) -> int:
	var total = 1 if node is Label else 0
	for child in node.get_children():
		total += count_label_nodes(child)
	return total

func labels_ignore_mouse(node: Node) -> bool:
	if node is Label and (node as Control).mouse_filter != Control.MOUSE_FILTER_IGNORE:
		return false
	for child in node.get_children():
		if not labels_ignore_mouse(child):
			return false
	return true

func panels_ignore_mouse(node: Node) -> bool:
	if node is Panel and (node as Control).mouse_filter != Control.MOUSE_FILTER_IGNORE:
		return false
	for child in node.get_children():
		if not panels_ignore_mouse(child):
			return false
	return true

func containers_ignore_mouse(node: Node) -> bool:
	if (node is HBoxContainer or node is VBoxContainer or node is GridContainer) and (node as Control).mouse_filter != Control.MOUSE_FILTER_IGNORE:
		return false
	for child in node.get_children():
		if not containers_ignore_mouse(child):
			return false
	return true

func count_control_nodes(node: Node) -> int:
	var total = 1 if node is Control else 0
	for child in node.get_children():
		total += count_control_nodes(child)
	return total

func has_button_text(node: Node, text: String) -> bool:
	if node is Button and str((node as Button).text) == text:
		return true
	for child in node.get_children():
		if has_button_text(child, text):
			return true
	return false

func first_button_with_text(node: Node, text: String) -> Button:
	if node is Button and str((node as Button).text) == text:
		return node as Button
	for child in node.get_children():
		var button = first_button_with_text(child, text)
		if button != null:
			return button
	return null

func count_button_text_prefix(node: Node, prefix: String) -> int:
	var count = 0
	if node is Button and str((node as Button).text).begins_with(prefix):
		count += 1
	for child in node.get_children():
		count += count_button_text_prefix(child, prefix)
	return count

func unique_tile_count(tiles: Array) -> int:
	var seen := {}
	for item in tiles:
		seen[str(item)] = true
	return seen.size()

func first_button(node: Node) -> Button:
	if node is Button:
		return node as Button
	for child in node.get_children():
		var button = first_button(child)
		if button != null:
			return button
	return null

func contains_subviewport(node: Node) -> bool:
	if node is SubViewport or node is SubViewportContainer:
		return true
	for child in node.get_children():
		if contains_subviewport(child):
			return true
	return false

func tile_texture_rects_are_bounded(node: Node) -> bool:
	if node is TextureRect:
		var texture_rect = node as TextureRect
		if texture_rect.expand_mode != TextureRect.EXPAND_IGNORE_SIZE:
			return false
		if texture_rect.stretch_mode != TextureRect.STRETCH_KEEP_ASPECT_CENTERED:
			return false
	for child in node.get_children():
		if not tile_texture_rects_are_bounded(child):
			return false
	return true

func has_visible_tile_art(node: Node) -> bool:
	if node is TextureRect:
		var texture_rect = node as TextureRect
		if texture_rect.texture != null and texture_rect.visible and texture_rect.modulate.a > 0.0:
			return true
	for child in node.get_children():
		if has_visible_tile_art(child):
			return true
	return false

func texture_rects_ignore_mouse(node: Node) -> bool:
	if node is TextureRect and (node as Control).mouse_filter != Control.MOUSE_FILTER_IGNORE:
		return false
	for child in node.get_children():
		if not texture_rects_ignore_mouse(child):
			return false
	return true

func color_rects_ignore_mouse(node: Node) -> bool:
	if node is ColorRect and (node as Control).mouse_filter != Control.MOUSE_FILTER_IGNORE:
		return false
	for child in node.get_children():
		if not color_rects_ignore_mouse(child):
			return false
	return true

func tile_view_inner_frame_is_fixed(node: Node, expected: Vector2) -> bool:
	if not (node is Control):
		return false
	if (node as Control).custom_minimum_size != expected:
		return false
	for child in node.get_children():
		if child is Button or child is Panel:
			var inner = child as Control
			return inner.custom_minimum_size == expected and control_offsets_match_size(inner, expected)
	return false

func count_panel_shadow_size(node: Node, shadow_size: int) -> int:
	var total = 0
	if node is Panel and panel_shadow_size(node) == shadow_size:
		total += 1
	for child in node.get_children():
		total += count_panel_shadow_size(child, shadow_size)
	return total

func panel_shadow_size(node: Node) -> int:
	if not (node is Panel):
		return -1
	var box = (node as Panel).get_theme_stylebox("panel")
	if box is StyleBoxFlat:
		return (box as StyleBoxFlat).shadow_size
	return -1

func count_texture_rects(node: Node) -> int:
	var total = 1 if node is TextureRect else 0
	for child in node.get_children():
		total += count_texture_rects(child)
	return total

func count_color_rects(node: Node) -> int:
	var total = 1 if node is ColorRect else 0
	for child in node.get_children():
		total += count_color_rects(child)
	return total

func control_offsets_match_size(control: Control, expected: Vector2) -> bool:
	return is_equal_approx(control.offset_right - control.offset_left, expected.x) and is_equal_approx(control.offset_bottom - control.offset_top, expected.y)

func control_anchor_rect_matches(control: Control, expected: Rect2) -> bool:
	if control == null:
		return false
	return is_equal_approx(control.anchor_left, expected.position.x) and is_equal_approx(control.anchor_top, expected.position.y) and is_equal_approx(control.anchor_right, expected.size.x) and is_equal_approx(control.anchor_bottom, expected.size.y)

func winning_hand() -> Array:
	return [
		"1W", "1W", "1W",
		"2W", "3W", "4W",
		"5W", "6W", "7W",
		"2T", "3T", "4T",
		"E", "E",
	]

func tenpai_hand() -> Array:
	return [
		"1W", "1W", "1W",
		"2W", "3W", "4W",
		"5W", "6W", "7W",
		"2T", "3T", "4T",
		"E",
	]

func thirteen_orphans_hand() -> Array:
	return [
		"1W", "9W",
		"1T", "9T",
		"1B", "9B",
		"E", "S", "N", "R", "Z", "F", "P",
		"1W",
	]

func seven_pairs_hand() -> Array:
	return [
		"1W", "1W",
		"2W", "2W",
		"3T", "3T",
		"4T", "4T",
		"5B", "5B",
		"E", "E",
		"P", "P",
	]

func seven_pairs_route_hand() -> Array:
	return [
		"1W", "1W",
		"2W", "2W",
		"3T", "3T",
		"4T", "4T",
		"5B", "5B",
		"E", "E",
		"8T", "9B",
	]

func seven_pairs_concealed_gang_hand() -> Array:
	return [
		"E", "E", "E", "E",
		"1W", "1W",
		"2W", "2W",
		"3T", "3T",
		"4T", "4T",
		"8T", "9B",
	]

func seven_pairs_claim_hand() -> Array:
	return [
		"1W", "1W",
		"2W", "2W",
		"3T", "3T",
		"4T", "4T",
		"5B", "5B",
		"E", "E",
		"8T",
	]

func thirteen_orphans_unique_tenpai() -> Array:
	return [
		"1W", "9W",
		"1T", "9T",
		"1B", "9B",
		"E", "S", "N", "R", "Z", "F", "P",
	]

func thirteen_orphans_missing_pair_tenpai() -> Array:
	return [
		"1W", "9W",
		"1T", "9T",
		"1B", "9B",
		"E", "E", "S", "N", "R", "Z", "F",
	]

func thirteen_orphans_route_hand() -> Array:
	return [
		"1W", "9W",
		"1T", "9T",
		"1B", "9B",
		"E", "S", "N", "R", "Z", "F",
		"2W",
	]

func waits_for_3w_hand() -> Array:
	return [
		"1T", "1T", "1T",
		"2T", "3T", "4T",
		"5T", "6T", "7T",
		"2B", "3B", "4B",
		"3W",
	]

func ai_shape_hand() -> Array:
	return [
		"1W", "1W",
		"2W", "3W", "4W",
		"5W", "6W", "7W",
		"2T", "3T", "4T",
		"5B", "6B",
		"E",
	]

func pure_one_suit_hand() -> Array:
	return [
		"1W", "1W", "1W",
		"2W", "3W", "4W",
		"4W", "5W", "6W",
		"6W", "7W", "8W",
		"9W", "9W",
	]

func mixed_one_suit_hand() -> Array:
	return [
		"1W", "1W", "1W",
		"2W", "3W", "4W",
		"4W", "5W", "6W",
		"7W", "8W", "9W",
		"E", "E",
	]

func full_straight_hand() -> Array:
	return [
		"1W", "2W", "3W",
		"4W", "5W", "6W",
		"7W", "8W", "9W",
		"2T", "3T", "4T",
		"E", "E",
	]

func full_straight_route_hand() -> Array:
	return [
		"1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W",
		"2T", "3T", "4T",
		"E", "P",
	]

func all_simples_hand() -> Array:
	return [
		"2W", "3W", "4W",
		"3W", "4W", "5W",
		"4T", "5T", "6T",
		"6B", "7B", "8B",
		"2T", "2T",
	]

func all_simples_route_hand() -> Array:
	return [
		"2W", "3W", "4W", "5W", "6W",
		"3T", "4T", "5T",
		"4B", "5B", "6B", "7B",
		"E",
	]

func big_three_dragons_hand() -> Array:
	return [
		"Z", "Z", "Z",
		"F", "F", "F",
		"P", "P", "P",
		"2W", "3W", "4W",
		"5T", "5T",
	]

func small_three_dragons_hand() -> Array:
	return [
		"Z", "Z", "Z",
		"F", "F", "F",
		"P", "P",
		"2W", "3W", "4W",
		"5T", "6T", "7T",
	]

func small_three_dragons_route_hand() -> Array:
	return [
		"Z", "Z", "Z",
		"F", "F", "F",
		"P", "P",
		"2W", "3W", "4W",
		"5T", "6T",
		"9B",
	]

func big_four_winds_hand() -> Array:
	return [
		"E", "E", "E",
		"S", "S", "S",
		"N", "N", "N",
		"R", "R", "R",
		"5W", "5W",
	]

func small_four_winds_hand() -> Array:
	return [
		"E", "E", "E",
		"S", "S", "S",
		"N", "N", "N",
		"R", "R",
		"2W", "3W", "4W",
	]

func all_triplet_hand() -> Array:
	return [
		"1W", "1W", "1W",
		"2T", "2T", "2T",
		"3B", "3B", "3B",
		"E", "E", "E",
		"P", "P",
	]

func all_honor_hand() -> Array:
	return [
		"E", "E", "E",
		"S", "S", "S",
		"N", "N", "N",
		"R", "R", "R",
		"Z", "Z",
	]
