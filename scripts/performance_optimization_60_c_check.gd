extends SceneTree
## Focused regression checks for the third CPU optimization batch.

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
	print("=== performance optimization 60 C check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]

	print("--- A) hand-plan feature cache ---")
	scene.clear_ai_report_cache()
	var route_tiles: Array = ["1W", "1W", "2W", "3W", "4W", "5W", "6W", "7W"]
	var route_counts = scene.tile_counts(route_tiles)
	var first_features: Dictionary = scene.hand_plan_features_from_counts(route_counts, route_tiles.size())
	var second_features: Dictionary = scene.hand_plan_features_from_counts(route_counts, route_tiles.size())
	check(scene.hand_plan_features_cache.size() == 1, "identical route features occupy one bounded cache entry")
	check(scene.hand_plan_features_cache_misses == 1 and scene.hand_plan_features_cache_hits >= 1, "identical route features reuse the cached result")
	first_features["suit_counts"][0] = 999
	var third_features: Dictionary = scene.hand_plan_features_from_counts(route_counts, route_tiles.size())
	check(int(third_features["suit_counts"][0]) != 999 and int(second_features["suit_counts"][0]) != 999, "feature callers cannot mutate cached nested arrays")
	var alternate_total: Dictionary = scene.hand_plan_features_from_counts(route_counts, route_tiles.size() + 1)
	check(int(alternate_total.get("total", 0)) == route_tiles.size() + 1 and scene.hand_plan_features_cache.size() == 2, "feature cache key retains the explicit tile total")

	print("--- B) set formation cursor ---")
	var set_tiles: Array = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "1T", "1T"]
	var set_counts = scene.tile_counts(set_tiles)
	var set_key: String = str(scene.counts_compact_key(set_counts))
	check(scene.can_form_sets_with_memo(set_counts, 4, {}) , "set formation still accepts a valid mixed sequence/triplet decomposition")
	check(scene.counts_compact_key(set_counts) == set_key, "set formation restores the caller count vector")
	var honor_counts = scene.tile_counts(["E", "E", "E"])
	check(scene.can_form_sets_with_memo(honor_counts, 1, {}, 27), "set formation can begin from an explicit suffix cursor")

	print("--- C2) terminal shanten bounds ---")
	var complete_counts = scene.tile_counts(["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "2T", "3T", "E", "E"])
	check(scene.calculate_min_shanten_from_counts(complete_counts, 0) == -1, "four completed groups stop at the standard winning result")
	var four_meld_counts = scene.tile_counts(["E"])
	check(scene.calculate_min_shanten_from_counts(four_meld_counts, 4) == 0, "four open groups stop at the standard tenpai result")

	print("--- C) cached pressure context ---")
	var eval_context: Dictionary = scene.make_ai_evaluation_context(0, scene.visible_tile_counts_shared())
	var pressure_context: Dictionary = scene.ai_pressure_context(0, eval_context)
	eval_context["pressure_context"] = pressure_context
	var cached_pressure: float = float(scene.opponent_pressure_score(0, eval_context))
	check(is_equal_approx(cached_pressure, float(pressure_context.get("opponent_pressure", -1.0))), "opponent pressure reads the existing evaluation context")
	var readiness_context := eval_context.duplicate(true)
	readiness_context["pressure_context"] = {"readiness_pressure": 37.5}
	var cached_readiness: float = float(scene.opponent_readiness_pressure_score(0, readiness_context))
	check(is_equal_approx(cached_readiness, 37.5), "opponent readiness pressure reads the seat-matched evaluation context")
	scene.opponent_runtime_state_cache.clear()
	scene.opponent_runtime_state_cache_key = ""
	var uncached_readiness: float = float(scene.opponent_readiness_pressure_score(0))
	var runtime_cache_entries: int = scene.opponent_runtime_state_cache.size()
	var reused_readiness: float = float(scene.opponent_readiness_pressure_score(0))
	check(runtime_cache_entries == scene.players.size() - 1 and is_equal_approx(uncached_readiness, reused_readiness), "context-free readiness pressure reuses the bounded opponent runtime snapshot")

	print("--- D) retained discard grids ---")
	var discard_root := Control.new()
	discard_root.size = Vector2(1280.0, 720.0)
	root.add_child(discard_root)
	scene.root_layer = discard_root
	scene.players[0]["discards"] = ["1W", "2W", "3W"]
	scene.last_discard = "3W"
	scene.last_discard_seat = 0
	scene.draw_discards(discard_root)
	var first_grid := discard_root.get_node_or_null("DiscardGrid_0") as Control
	var first_grid_id: int = first_grid.get_instance_id() if first_grid != null else 0
	scene.retain_battle_discard_archive_buttons_for_render()
	scene.retain_battle_discard_grids_for_render()
	scene.retain_battle_discard_foreground_for_render()
	check(scene.retained_battle_discard_grids.size() == 4, "all four discard grids enter the bounded render retention set")
	scene.draw_discards(discard_root)
	var second_grid := discard_root.get_node_or_null("DiscardGrid_0") as Control
	check(second_grid != null and second_grid.get_instance_id() == first_grid_id and scene.retained_battle_discard_grids.is_empty(), "unchanged discard state reuses the existing grid instances")
	discard_root.queue_free()
	scene.root_layer = null

	print("--- E) exposed full-straight grouping ---")
	var concealed: Array = ["4W", "5W", "6W", "7W", "8W", "9W", "1T", "1T", "1T", "E", "E"]
	scene.players[0]["melds"] = [["1W", "2W", "3W"]]
	check(scene.full_straight_suit(0, concealed) == 0, "precomputed exposed groups preserve full-straight recognition")

	print("--- F) standalone claim plan report reuse ---")
	scene.players[0]["melds"] = []
	scene.players[0]["hand"] = ["1W", "1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "E", "E", "R", "R"]
	scene.offline_sim_quiet = false
	var standalone_claim: Dictionary = scene.build_ai_claim_report(0, "peng", "1W")
	var standalone_counts: Array = scene.tile_counts(scene.players[0]["hand"])
	var standalone_plan: Dictionary = scene.hand_plan_report_for_seat_from_counts(0, standalone_counts, scene.players[0]["hand"].size())
	check(is_equal_approx(float(standalone_claim.get("plan_bonus", -1.0)), float(standalone_plan.get("score_bonus", -2.0))), "standalone claim reports preserve the plan bonus while reusing the existing plan report")

	print("--- G) retained seat subtrees ---")
	var seat_root := Control.new()
	seat_root.size = Vector2(1280.0, 720.0)
	root.add_child(seat_root)
	scene.root_layer = seat_root
	scene.current_seat = 0
	scene.dealer_seat = 0
	for seat_layout in scene.SEAT_LAYOUTS:
		scene.draw_seat(seat_root, int(seat_layout[0]), seat_layout[1], str(seat_layout[2]), {})
	var first_seat_panel := seat_root.get_node_or_null("SeatPanel_0") as Control
	var first_seat_id: int = first_seat_panel.get_instance_id() if first_seat_panel != null else 0
	scene.retain_battle_seats_for_render()
	check(scene.retained_battle_seats.size() == 4, "all four unchanged seat subtrees enter render retention")
	for seat_layout in scene.SEAT_LAYOUTS:
		scene.draw_seat(seat_root, int(seat_layout[0]), seat_layout[1], str(seat_layout[2]), {})
	var second_seat_panel := seat_root.get_node_or_null("SeatPanel_0") as Control
	check(second_seat_panel != null and second_seat_panel.get_instance_id() == first_seat_id and scene.retained_battle_seats.is_empty(), "unchanged seat render reuses the existing panel instances")
	scene.players[0]["name"] = "P0-renamed"
	scene.ai_state_revision += 1
	scene.retain_battle_seats_for_render()
	check(scene.retained_battle_seats.size() == 3 and seat_root.get_node_or_null("SeatPanel_0") != null, "a changed seat stays mounted while unchanged seats remain eligible for retention")
	scene.release_retained_battle_seats()
	seat_root.queue_free()
	scene.root_layer = null

	print("--- H) retained meld lanes ---")
	var meld_root := Control.new()
	meld_root.size = Vector2(1280.0, 720.0)
	root.add_child(meld_root)
	scene.root_layer = meld_root
	scene.players[0]["melds"] = [["1W", "1W", "1W"], ["2W", "3W", "4W"]]
	scene.draw_melds(meld_root)
	var first_meld_area := meld_root.get_node_or_null("MeldArea_0") as Control
	var first_meld_lane := meld_root.get_node_or_null("MeldLaneArt_0") as Control
	var first_meld_pager := meld_root.get_node_or_null("MeldLaneArchiveButton_0") as Control
	var first_meld_area_id: int = first_meld_area.get_instance_id() if first_meld_area != null else 0
	var first_meld_lane_id: int = first_meld_lane.get_instance_id() if first_meld_lane != null else 0
	var first_meld_pager_id: int = first_meld_pager.get_instance_id() if first_meld_pager != null else 0
	scene.retain_battle_meld_lanes_for_render()
	check(scene.retained_battle_meld_lanes.size() == 1, "unchanged populated meld lanes enter the bounded render retention set")
	scene.draw_melds(meld_root)
	var second_meld_area := meld_root.get_node_or_null("MeldArea_0") as Control
	var second_meld_lane := meld_root.get_node_or_null("MeldLaneArt_0") as Control
	var second_meld_pager := meld_root.get_node_or_null("MeldLaneArchiveButton_0") as Control
	check(second_meld_area != null and second_meld_area.get_instance_id() == first_meld_area_id and second_meld_lane != null and second_meld_lane.get_instance_id() == first_meld_lane_id and second_meld_pager != null and second_meld_pager.get_instance_id() == first_meld_pager_id and scene.retained_battle_meld_lanes.is_empty(), "unchanged meld redraw reuses the lane, group, and pager subtree instances")
	meld_root.queue_free()
	scene.root_layer = null

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
