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
	var first_meld_group: Control = null
	if first_meld_area != null and first_meld_area.get_child_count() > 0:
		first_meld_group = first_meld_area.get_child(0) as Control
	var first_meld_area_id: int = first_meld_area.get_instance_id() if first_meld_area != null else 0
	var first_meld_lane_id: int = first_meld_lane.get_instance_id() if first_meld_lane != null else 0
	var first_meld_pager_id: int = first_meld_pager.get_instance_id() if first_meld_pager != null else 0
	var first_meld_group_id: int = first_meld_group.get_instance_id() if first_meld_group != null else 0
	scene.retain_battle_meld_lanes_for_render()
	check(scene.retained_battle_meld_lanes.size() == 1, "unchanged populated meld lanes enter the bounded render retention set")
	scene.draw_melds(meld_root)
	var second_meld_area := meld_root.get_node_or_null("MeldArea_0") as Control
	var second_meld_lane := meld_root.get_node_or_null("MeldLaneArt_0") as Control
	var second_meld_pager := meld_root.get_node_or_null("MeldLaneArchiveButton_0") as Control
	var second_meld_group: Control = null
	if second_meld_area != null and second_meld_area.get_child_count() > 0:
		second_meld_group = second_meld_area.get_child(0) as Control
	check(second_meld_area != null and second_meld_area.get_instance_id() == first_meld_area_id and second_meld_lane != null and second_meld_lane.get_instance_id() == first_meld_lane_id and second_meld_group != null and second_meld_group.get_instance_id() == first_meld_group_id and second_meld_pager != null and second_meld_pager.get_instance_id() == first_meld_pager_id and scene.retained_battle_meld_lanes.is_empty(), "unchanged meld redraw reuses the lane, group, and pager subtree instances")
	scene.retain_battle_meld_lanes_for_render()
	scene.players[0]["melds"] = [["9W", "9W", "9W"], ["2W", "3W", "4W"]]
	scene.draw_melds(meld_root)
	var changed_meld_area := meld_root.get_node_or_null("MeldArea_0") as Control
	check(changed_meld_area != null and changed_meld_area.get_instance_id() != first_meld_area_id and scene.retained_battle_meld_lanes.is_empty(), "changed meld content invalidates and releases the retained lane subtree")
	meld_root.queue_free()
	scene.root_layer = null

	print("--- I) retained wall strips ---")
	var wall_root := Control.new()
	wall_root.size = Vector2(1280.0, 720.0)
	root.add_child(wall_root)
	scene.root_layer = wall_root
	scene.wall.clear()
	for _i in range(40):
		scene.wall.append("1W")
	scene.offline_last_draw = {}
	scene.draw_walls(wall_root)
	var first_wall_ids: Dictionary = {}
	for i in range(scene.WALL_LAYOUTS.size()):
		var layout = scene.WALL_LAYOUTS[i]
		var wall_name := "WallBackStrip_%s_%d_%d" % ["h" if bool(layout[3]) else "v", int(layout[2]), i]
		var strip := wall_root.get_node_or_null(wall_name) as WallBackStrip
		first_wall_ids[i] = strip.get_instance_id() if strip != null else 0
	scene.retain_battle_wall_strips_for_render()
	check(scene.retained_battle_wall_strips.size() == scene.WALL_LAYOUTS.size(), "all four fixed wall strips enter the bounded render retention set")
	scene.draw_walls(wall_root)
	var same_wall_instances := true
	for i in range(scene.WALL_LAYOUTS.size()):
		var layout = scene.WALL_LAYOUTS[i]
		var wall_name := "WallBackStrip_%s_%d_%d" % ["h" if bool(layout[3]) else "v", int(layout[2]), i]
		var strip := wall_root.get_node_or_null(wall_name) as WallBackStrip
		if strip == null or strip.get_instance_id() != int(first_wall_ids.get(i, 0)):
			same_wall_instances = false
	check(same_wall_instances and scene.retained_battle_wall_strips.is_empty(), "unchanged wall redraw reuses all four strip instances")
	scene.retain_battle_wall_strips_for_render()
	scene.wall.clear()
	for _i in range(2):
		scene.wall.append("9B")
	scene.offline_last_draw = {"seat": 0, "tile": "9B", "source": "normal", "serial": 902, "announce": true}
	scene.draw_walls(wall_root)
	var state_updated_without_rebuild := true
	for i in range(scene.WALL_LAYOUTS.size()):
		var layout = scene.WALL_LAYOUTS[i]
		var wall_name := "WallBackStrip_%s_%d_%d" % ["h" if bool(layout[3]) else "v", int(layout[2]), i]
		var strip := wall_root.get_node_or_null(wall_name) as WallBackStrip
		if strip == null or strip.get_instance_id() != int(first_wall_ids.get(i, 0)) or int(strip.tile_count) > int(layout[2]) or not bool(strip.low_wall) or not bool(strip.recent_feedback):
			state_updated_without_rebuild = false
	check(state_updated_without_rebuild, "wall count and low-wall feedback update through configure without rebuilding strips")
	wall_root.queue_free()
	scene.root_layer = null

	print("--- J) retained table log ledger ---")
	var log_root := Control.new()
	log_root.size = Vector2(1280.0, 720.0)
	root.add_child(log_root)
	scene.root_layer = log_root
	var saved_table_logs: Array[String] = scene.table_logs.duplicate()
	scene.table_log_archive_open = false
	var test_table_logs: Array[String] = ["event-one", "event-two"]
	scene.table_logs = test_table_logs
	scene.draw_table_log(log_root)
	var first_log_panel := log_root.get_node_or_null("TableLogLedgerPanel") as Control
	var first_log_id: int = first_log_panel.get_instance_id() if first_log_panel != null else 0
	scene.retain_battle_table_log_for_render()
	check(scene.retained_battle_table_log != null and scene.retained_battle_table_log_signature != "", "unchanged table log ledger enters the bounded render retention slot")
	scene.draw_table_log(log_root)
	var second_log_panel := log_root.get_node_or_null("TableLogLedgerPanel") as Control
	check(second_log_panel != null and second_log_panel.get_instance_id() == first_log_id and scene.retained_battle_table_log == null, "unchanged table log redraw reuses the ledger subtree and button binding")
	scene.retain_battle_table_log_for_render()
	scene.table_logs.append("event-three")
	scene.draw_table_log(log_root)
	var changed_log_panel := log_root.get_node_or_null("TableLogLedgerPanel") as Control
	check(changed_log_panel != null and changed_log_panel.get_instance_id() != first_log_id and scene.retained_battle_table_log == null, "new table log content invalidates and rebuilds the ledger subtree")
	scene.table_logs = saved_table_logs
	log_root.queue_free()
	scene.root_layer = null

	print("--- K) retained last-discard focus marker ---")
	var marker_root := Control.new()
	marker_root.size = Vector2(1280.0, 720.0)
	root.add_child(marker_root)
	scene.root_layer = marker_root
	var saved_marker_tile: String = str(scene.last_discard)
	var saved_marker_seat: int = int(scene.last_discard_seat)
	var saved_marker_discards: Array = scene.players[0]["discards"].duplicate()
	scene.last_discard = "1W"
	scene.last_discard_seat = 0
	scene.players[0]["discards"] = ["1W"]
	var first_marker: Control = scene.draw_last_discard_focus_marker(marker_root, 0, Vector2(1000.0, 600.0), "1W", 1)
	var first_marker_id: int = first_marker.get_instance_id() if first_marker != null else 0
	scene.retain_battle_last_discard_marker_for_render()
	check(scene.retained_battle_last_discard_marker != null and scene.retained_battle_last_discard_marker_signature != "", "unchanged last-discard marker enters the bounded render retention slot")
	var second_marker: Control = scene.draw_last_discard_focus_marker(marker_root, 0, Vector2(1000.0, 600.0), "1W", 1)
	check(second_marker != null and second_marker.get_instance_id() == first_marker_id and scene.retained_battle_last_discard_marker == null, "unchanged last-discard redraw reuses the complete marker subtree")
	scene.retain_battle_last_discard_marker_for_render()
	scene.last_discard = "2W"
	scene.last_discard_seat = 0
	scene.players[0]["discards"] = ["1W", "2W"]
	var changed_marker: Control = scene.draw_last_discard_focus_marker(marker_root, 0, Vector2(1000.0, 600.0), "2W", 2)
	check(changed_marker != null and changed_marker.get_instance_id() != first_marker_id and scene.retained_battle_last_discard_marker == null, "new last-discard state invalidates and rebuilds the marker subtree")
	scene.last_discard = saved_marker_tile
	scene.last_discard_seat = saved_marker_seat
	scene.players[0]["discards"] = saved_marker_discards
	marker_root.queue_free()
	scene.root_layer = null

	print("--- L) retained discard river chrome ---")
	var river_root := Control.new()
	river_root.size = Vector2(1280.0, 720.0)
	root.add_child(river_root)
	scene.root_layer = river_root
	var saved_river_discards: Array = scene.players[0]["discards"].duplicate()
	var saved_river_tile: String = str(scene.last_discard)
	var saved_river_seat: int = int(scene.last_discard_seat)
	var river_discards: Array = []
	for _i in range(60):
		river_discards.append("1W")
	scene.players[0]["discards"] = river_discards
	scene.last_discard = "1W"
	scene.last_discard_seat = 0
	scene.draw_discards(river_root)
	var first_river_art := river_root.get_node_or_null("DiscardRiverArt_0") as Control
	var first_owner_overlay := river_root.find_child("DiscardRiverOwnerOverlay_0", true, false) as Control
	var first_archive_button := river_root.find_child("DiscardRiverArchiveButton_0", true, false) as Button
	var first_archive_art := first_archive_button.find_child("DiscardRiverArchiveArt_0", true, false) as Control if first_archive_button != null else null
	var first_river_art_id: int = first_river_art.get_instance_id() if first_river_art != null else 0
	var first_owner_overlay_id: int = first_owner_overlay.get_instance_id() if first_owner_overlay != null else 0
	var first_archive_button_id: int = first_archive_button.get_instance_id() if first_archive_button != null else 0
	var first_archive_art_id: int = first_archive_art.get_instance_id() if first_archive_art != null else 0
	scene.retain_battle_discard_river_art_for_render()
	scene.retain_battle_discard_archive_buttons_for_render()
	scene.retain_battle_discard_grids_for_render()
	scene.retain_battle_discard_foreground_for_render()
	check(scene.retained_battle_discard_river_art.size() == 4 and scene.retained_battle_discard_owner_overlays.size() == 1, "river art and populated owner overlay enter bounded retention")
	check(scene.retained_battle_discard_archive_buttons.size() == 1, "history button remains in its independent retention slot")
	scene.draw_discards(river_root)
	var second_river_art := river_root.get_node_or_null("DiscardRiverArt_0") as Control
	var second_owner_overlay := river_root.find_child("DiscardRiverOwnerOverlay_0", true, false) as Control
	var second_archive_button := river_root.find_child("DiscardRiverArchiveButton_0", true, false) as Button
	var second_archive_art := second_archive_button.find_child("DiscardRiverArchiveArt_0", true, false) as Control if second_archive_button != null else null
	check(second_river_art != null and second_river_art.get_instance_id() == first_river_art_id and second_owner_overlay != null and second_owner_overlay.get_instance_id() == first_owner_overlay_id, "unchanged river redraw reuses art and owner overlay subtrees")
	check(second_archive_button != null and second_archive_button.get_instance_id() == first_archive_button_id and second_archive_art != null and second_archive_art.get_instance_id() == first_archive_art_id, "unchanged river redraw reuses history button and archive art")
	scene.retain_battle_discard_river_art_for_render()
	scene.retain_battle_discard_archive_buttons_for_render()
	scene.retain_battle_discard_grids_for_render()
	scene.retain_battle_discard_foreground_for_render()
	scene.players[0]["discards"].append("9B")
	scene.last_discard = "9B"
	scene.last_discard_seat = 0
	scene.draw_discards(river_root)
	var changed_river_art := river_root.get_node_or_null("DiscardRiverArt_0") as Control
	var changed_owner_overlay := river_root.find_child("DiscardRiverOwnerOverlay_0", true, false) as Control
	var changed_archive_button := river_root.find_child("DiscardRiverArchiveButton_0", true, false) as Button
	var changed_archive_art := changed_archive_button.find_child("DiscardRiverArchiveArt_0", true, false) as Control if changed_archive_button != null else null
	check(changed_river_art != null and changed_river_art.get_instance_id() != first_river_art_id and changed_owner_overlay != null and changed_owner_overlay.get_instance_id() != first_owner_overlay_id, "changed river state invalidates art and owner overlay subtrees")
	check(changed_archive_button != null and changed_archive_button.get_instance_id() == first_archive_button_id and changed_archive_art != null and changed_archive_art.get_instance_id() != first_archive_art_id, "changed river state rebuilds archive art while preserving button binding")
	scene.players[0]["discards"] = saved_river_discards
	scene.last_discard = saved_river_tile
	scene.last_discard_seat = saved_river_seat
	river_root.queue_free()
	scene.root_layer = null

	print("--- M) retained top HUD ---")
	var hud_root := Control.new()
	hud_root.size = Vector2(1280.0, 720.0)
	root.add_child(hud_root)
	scene.root_layer = hud_root
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.current_seat = 0
	scene.dealer_seat = 0
	scene.offline_hand_number = 1
	scene.offline_dealer_repeat = false
	scene.wall.clear()
	for _i in range(40):
		scene.wall.append("1W")
	scene.last_discard = "3W"
	scene.last_discard_seat = 0
	scene.players[0]["discards"] = ["3W"]
	scene.last_status_text = ""
	scene.update_state = "idle"
	scene.update_message = ""
	scene.draw_game_top_hud(hud_root)
	var first_hud := hud_root.get_node_or_null("TopHud3DShell") as Control
	var first_hud_id: int = first_hud.get_instance_id() if first_hud != null else 0
	var first_hud_progress := first_hud.find_child("TopHudHandProgress", true, false) as Control if first_hud != null else null
	var first_hud_progress_id: int = first_hud_progress.get_instance_id() if first_hud_progress != null else 0
	scene.retain_battle_top_hud_for_render()
	check(scene.retained_battle_top_hud != null and scene.retained_battle_top_hud_signature != "", "unchanged top HUD enters the bounded render retention slot")
	scene.draw_game_top_hud(hud_root)
	var second_hud := hud_root.get_node_or_null("TopHud3DShell") as Control
	var second_hud_progress := second_hud.find_child("TopHudHandProgress", true, false) as Control if second_hud != null else null
	var second_hud_status := second_hud.find_child("TopHudStatus", true, false) as Label if second_hud != null else null
	check(second_hud != null and second_hud.get_instance_id() == first_hud_id and second_hud_progress != null and second_hud_progress.get_instance_id() == first_hud_progress_id and scene.retained_battle_top_hud == null and scene.status_label == second_hud_status, "unchanged top HUD redraw reuses the complete shell and restores the live status reference")
	scene.retain_battle_top_hud_for_render()
	scene.wall.append("9B")
	scene.draw_game_top_hud(hud_root)
	var wall_changed_hud := hud_root.get_node_or_null("TopHud3DShell") as Control
	var wall_changed_hud_id: int = wall_changed_hud.get_instance_id() if wall_changed_hud != null else 0
	check(wall_changed_hud != null and wall_changed_hud_id != first_hud_id and scene.retained_battle_top_hud == null, "wall count change invalidates and rebuilds the top HUD subtree")
	scene.retain_battle_top_hud_for_render()
	scene.offline_phase = "pending_claim"
	scene.offline_pending_claim = {"tile": "4W", "from_seat": 1}
	scene.draw_game_top_hud(hud_root)
	var phase_changed_hud := hud_root.get_node_or_null("TopHud3DShell") as Control
	check(phase_changed_hud != null and phase_changed_hud.get_instance_id() != wall_changed_hud_id and scene.retained_battle_top_hud == null, "phase change invalidates the top HUD status art and shell")
	scene.retain_battle_top_hud_for_render()
	scene.mode = "online_game"
	scene.offline_pending_claim.clear()
	scene.online_game = {
		"roomCode": "M-ROOM",
		"phase": "awaitDiscard",
		"currentSeat": 0,
		"youSeat": 0,
		"wallCount": 20,
		"wallTotal": 144,
		"lastDiscard": "3W",
		"lastDiscardSeat": 0,
	}
	scene.online_game_revision += 1
	scene.tcp_status = StreamPeerTCP.STATUS_CONNECTED
	scene.draw_game_top_hud(hud_root)
	var online_hud := hud_root.get_node_or_null("TopHud3DShell") as Control
	var online_hud_id: int = online_hud.get_instance_id() if online_hud != null else 0
	check(online_hud != null and online_hud_id != phase_changed_hud.get_instance_id() and scene.retained_battle_top_hud == null, "online mode boundary does not reuse an offline HUD shell")
	scene.retain_battle_top_hud_for_render()
	var retained_online_hud_signature: String = scene.retained_battle_top_hud_signature
	scene.update_state = "ready"
	scene.update_message = "upgrade ready"
	var update_signature: String = scene.battle_top_hud_identity_signature()
	check(scene.retained_battle_top_hud != null and retained_online_hud_signature != "" and retained_online_hud_signature != update_signature, "update state changes the top HUD retention signature")
	scene.draw_game_top_hud(hud_root)
	var update_changed_hud := hud_root.get_node_or_null("TopHud3DShell") as Control
	check(update_changed_hud != null and update_changed_hud.get_instance_id() != online_hud_id and scene.retained_battle_top_hud == null, "update state change invalidates the top HUD action subtree")
	hud_root.queue_free()
	scene.root_layer = null

	print("--- N) retained action chrome ---")
	var action_root := Control.new()
	action_root.size = Vector2(1280.0, 720.0)
	root.add_child(action_root)
	scene.root_layer = action_root
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.offline_pending_claim.clear()
	var action_test_bar := HBoxContainer.new()
	action_test_bar.name = "ActionTestBar"
	action_test_bar.size = Vector2(520.0, 64.0)
	action_test_bar.position = Vector2(700.0, 620.0)
	action_root.add_child(action_test_bar)
	var action_test_button := Button.new()
	action_test_button.name = "ActionTestAdviceButton"
	action_test_button.text = "提示"
	action_test_bar.add_child(action_test_button)
	scene.action_bar = action_test_bar
	scene.draw_action_dock(action_root)
	var first_action_dock := action_root.get_node_or_null("ActionButtonDock") as Control
	var first_action_intent := action_root.get_node_or_null("ActionIntentDock") as Control
	var first_action_shadow := action_root.get_node_or_null("ActionDock3DCastShadow") as Control
	var first_action_pulse := first_action_dock.find_child("ActionButtonDockPulseDriver", true, false) as Control if first_action_dock != null else null
	var first_action_dock_id: int = first_action_dock.get_instance_id() if first_action_dock != null else 0
	var first_action_intent_id: int = first_action_intent.get_instance_id() if first_action_intent != null else 0
	var first_action_shadow_id: int = first_action_shadow.get_instance_id() if first_action_shadow != null else 0
	scene.retain_battle_action_chrome_for_render()
	check(scene.retained_battle_action_dock != null and scene.retained_battle_action_dock_shadow != null and scene.retained_battle_action_intent != null, "unchanged action chrome enters bounded render retention")
	action_test_bar.queue_free()
	var second_action_test_bar := HBoxContainer.new()
	second_action_test_bar.name = "ActionTestBarSecond"
	second_action_test_bar.size = Vector2(520.0, 64.0)
	second_action_test_bar.position = Vector2(700.0, 620.0)
	action_root.add_child(second_action_test_bar)
	var second_action_test_button := Button.new()
	second_action_test_button.name = "ActionTestAdviceButton"
	second_action_test_button.text = "提示"
	second_action_test_bar.add_child(second_action_test_button)
	scene.action_bar = second_action_test_bar
	scene.draw_action_dock(action_root)
	var second_action_dock := action_root.get_node_or_null("ActionButtonDock") as Control
	var second_action_intent := action_root.get_node_or_null("ActionIntentDock") as Control
	var second_action_shadow := action_root.get_node_or_null("ActionDock3DCastShadow") as Control
	var second_action_pulse := second_action_dock.find_child("ActionButtonDockPulseDriver", true, false) as Control if second_action_dock != null else null
	check(second_action_dock != null and second_action_dock.get_instance_id() == first_action_dock_id and second_action_intent != null and second_action_intent.get_instance_id() == first_action_intent_id and second_action_shadow != null and second_action_shadow.get_instance_id() == first_action_shadow_id and second_action_pulse != null and second_action_pulse.get_instance_id() == first_action_pulse.get_instance_id(), "unchanged action redraw reuses dock shadow intent and pulse owner")
	scene.retain_battle_action_chrome_for_render()
	second_action_test_bar.queue_free()
	var pending_action_test_bar := HBoxContainer.new()
	pending_action_test_bar.name = "ActionTestBarPending"
	pending_action_test_bar.size = Vector2(520.0, 64.0)
	pending_action_test_bar.position = Vector2(700.0, 620.0)
	action_root.add_child(pending_action_test_bar)
	var pending_action_test_button := Button.new()
	pending_action_test_button.name = "ActionTestAdviceButtonPending"
	pending_action_test_button.text = "提示"
	pending_action_test_bar.add_child(pending_action_test_button)
	scene.action_bar = pending_action_test_bar
	scene.offline_phase = "pending_claim"
	scene.offline_pending_claim = {"tile": "4W", "from_seat": 1, "options": ["peng"]}
	scene.draw_action_dock(action_root)
	var pending_action_dock := action_root.get_node_or_null("ActionButtonDock") as Control
	check(pending_action_dock != null and pending_action_dock.get_instance_id() != first_action_dock_id and action_root.get_node_or_null("ActionIntentDock") == null and scene.retained_battle_action_dock == null and scene.retained_battle_action_intent == null, "pending response state invalidates normal action chrome and removes the intent strip")
	action_root.queue_free()
	scene.root_layer = null

	print("--- N2) retained normal offline action bar ---")
	var action_bar_root := Control.new()
	action_bar_root.size = Vector2(1280.0, 720.0)
	root.add_child(action_bar_root)
	scene.root_layer = action_bar_root
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.offline_pending_claim.clear()
	scene.ai_assist_enabled = false
	scene.draw_actions(action_bar_root)
	var first_retained_action_bar := scene.action_bar as Container
	var first_retained_action_bar_id: int = first_retained_action_bar.get_instance_id() if first_retained_action_bar != null else 0
	var first_retained_action_button := first_retained_action_bar.get_node_or_null("OfflineRestartButton") as Button if first_retained_action_bar != null else null
	check(first_retained_action_bar != null and first_retained_action_button != null and str(first_retained_action_bar.get_meta("action_bar_state_signature", "")) == scene.battle_action_bar_state_signature() and str(first_retained_action_bar.get_meta("action_bar_render_signature", "")) == scene.battle_action_bar_identity_signature(), "production action draw writes the callback retention signatures")
	scene.retain_battle_action_chrome_for_render()
	scene.retain_battle_action_bar_for_render()
	check(scene.retained_battle_action_bar != null and scene.retained_battle_action_bar_signature != "" and scene.retained_battle_action_bar_state_signature != "", "unchanged normal action bar enters bounded callback retention")
	scene.action_bar = null
	scene.draw_actions(action_bar_root)
	var reused_action_bar := scene.action_bar as Container
	var reused_action_button := reused_action_bar.get_node_or_null("OfflineRestartButton") as Button if reused_action_bar != null else null
	check(reused_action_bar != null and reused_action_bar.get_instance_id() == first_retained_action_bar_id and reused_action_button != null and scene.retained_battle_action_bar == null, "unchanged offline redraw reuses the complete action bar and native button")
	if reused_action_button != null:
		reused_action_button.pressed.emit()
	check(scene.offline_restart_confirming, "reused action button keeps its original callback binding")
	scene.offline_restart_confirming = false
	scene.offline_restart_confirm_deadline_msec = 0
	scene.retain_battle_action_chrome_for_render()
	scene.retain_battle_action_bar_for_render()
	scene.players[0]["hand"].append("9W")
	check(scene.retained_battle_action_bar != null, "changed hand leaves the old action bar pending validation")
	scene.action_bar = null
	scene.draw_actions(action_bar_root)
	var changed_action_bar := scene.action_bar as Container
	check(changed_action_bar != null and changed_action_bar.get_instance_id() != first_retained_action_bar_id and scene.retained_battle_action_bar == null, "changed offline action state rejects and rebuilds the action bar")
	action_bar_root.queue_free()
	scene.root_layer = null

	print("--- O) retained table living illustration ---")
	var living_root := Control.new()
	living_root.size = Vector2(1280.0, 720.0)
	root.add_child(living_root)
	scene.root_layer = living_root
	scene.mode = "offline"
	scene.last_discard = "2T"
	scene.last_discard_seat = 1
	scene.draw_table_living_illustration(living_root)
	var first_living := living_root.get_node_or_null("TableLivingIllustration") as Control
	var first_living_id: int = first_living.get_instance_id() if first_living != null else 0
	scene.retain_battle_living_illustration_for_render()
	check(scene.retained_battle_living_illustration != null and scene.retained_battle_living_illustration_signature != "", "unchanged table living illustration enters bounded render retention")
	scene.draw_table_living_illustration(living_root)
	var second_living := living_root.get_node_or_null("TableLivingIllustration") as Control
	check(second_living != null and second_living.get_instance_id() == first_living_id and scene.retained_battle_living_illustration == null, "unchanged living illustration redraw reuses its ripple host")
	scene.retain_battle_living_illustration_for_render()
	scene.last_discard = "3T"
	scene.draw_table_living_illustration(living_root)
	var changed_living := living_root.get_node_or_null("TableLivingIllustration") as Control
	check(changed_living != null and changed_living.get_instance_id() != first_living_id and scene.retained_battle_living_illustration == null, "latest-discard change invalidates the living illustration subtree")
	living_root.queue_free()
	scene.root_layer = null

	print("--- P) retained table chrome scaffold ---")
	var chrome_root := Control.new()
	chrome_root.size = Vector2(1280.0, 720.0)
	root.add_child(chrome_root)
	scene.root_layer = chrome_root
	scene.mode = "offline"
	scene.draw_battle_table_chrome(chrome_root)
	var first_floor := chrome_root.get_node_or_null("OfflineTable3DFloorShadow") as Control
	var first_apron := chrome_root.get_node_or_null("OfflineTable3DFrontApron") as Control
	var first_shadow := chrome_root.get_node_or_null("OfflineTable3DCastShadow") as Control
	var first_floor_id: int = first_floor.get_instance_id() if first_floor != null else 0
	var first_apron_id: int = first_apron.get_instance_id() if first_apron != null else 0
	var first_shadow_id: int = first_shadow.get_instance_id() if first_shadow != null else 0
	scene.retain_battle_table_chrome_for_render()
	check(scene.retained_battle_table_chrome.size() == 3 and scene.retained_battle_table_chrome_signature != "", "fixed table chrome enters the bounded render retention set")
	scene.draw_battle_table_chrome(chrome_root)
	var second_floor := chrome_root.get_node_or_null("OfflineTable3DFloorShadow") as Control
	var second_apron := chrome_root.get_node_or_null("OfflineTable3DFrontApron") as Control
	var second_shadow := chrome_root.get_node_or_null("OfflineTable3DCastShadow") as Control
	check(second_floor != null and second_floor.get_instance_id() == first_floor_id and second_apron != null and second_apron.get_instance_id() == first_apron_id and second_shadow != null and second_shadow.get_instance_id() == first_shadow_id and chrome_root.find_child("OfflineTable3DApronHighlight", true, false) != null, "unchanged table redraw reuses chrome hosts and nested apron highlight")
	scene.retain_battle_table_chrome_for_render()
	scene.safe_area_layout_revision += 1
	scene.draw_battle_table_chrome(chrome_root)
	var changed_floor := chrome_root.get_node_or_null("OfflineTable3DFloorShadow") as Control
	check(changed_floor != null and changed_floor.get_instance_id() != first_floor_id and scene.retained_battle_table_chrome.is_empty(), "safe-area geometry change releases and rebuilds the table chrome scaffold")
	chrome_root.queue_free()
	scene.root_layer = null

	print("--- Q) retained wall feedback chrome ---")
	var feedback_root := Control.new()
	feedback_root.size = Vector2(1280.0, 720.0)
	root.add_child(feedback_root)
	scene.root_layer = feedback_root
	scene.mode = "offline"
	scene.wall.clear()
	for _i in range(2):
		scene.wall.append("1W")
	scene.offline_last_draw = {"source": "normal", "announce": true}
	var feedback_count: int = scene.get_wall_count()
	var feedback_progress: float = scene.wall_progress(feedback_count)
	scene.draw_wall_count_feedback_art(feedback_root, feedback_count, feedback_progress, true)
	scene.draw_wall_remaining_badge(feedback_root, feedback_count, feedback_progress, true)
	var first_feedback := feedback_root.get_node_or_null("WallDrawFeedbackArt") as Control
	var first_badge := feedback_root.get_node_or_null("WallRemainingBadge") as Control
	var first_feedback_id: int = first_feedback.get_instance_id() if first_feedback != null else 0
	var first_badge_id: int = first_badge.get_instance_id() if first_badge != null else 0
	scene.retain_battle_wall_feedback_for_render()
	check(scene.retained_battle_wall_feedback_art != null and scene.retained_battle_wall_remaining_badge != null, "wall feedback art and badge enter bounded retention")
	scene.draw_wall_count_feedback_art(feedback_root, feedback_count, feedback_progress, true)
	scene.draw_wall_remaining_badge(feedback_root, feedback_count, feedback_progress, true)
	var second_feedback := feedback_root.get_node_or_null("WallDrawFeedbackArt") as Control
	var second_badge := feedback_root.get_node_or_null("WallRemainingBadge") as Control
	check(second_feedback != null and second_feedback.get_instance_id() == first_feedback_id and second_badge != null and second_badge.get_instance_id() == first_badge_id and scene.retained_battle_wall_feedback_art == null and scene.retained_battle_wall_remaining_badge == null, "unchanged wall feedback redraw reuses art and badge")
	scene.retain_battle_wall_feedback_for_render()
	scene.wall.clear()
	scene.wall.append("9B")
	var changed_count: int = scene.get_wall_count()
	var changed_progress: float = scene.wall_progress(changed_count)
	scene.draw_wall_count_feedback_art(feedback_root, changed_count, changed_progress, true)
	scene.draw_wall_remaining_badge(feedback_root, changed_count, changed_progress, true)
	var changed_feedback := feedback_root.get_node_or_null("WallDrawFeedbackArt") as Control
	var changed_badge := feedback_root.get_node_or_null("WallRemainingBadge") as Control
	check(changed_feedback != null and changed_feedback.get_instance_id() != first_feedback_id and changed_badge != null and changed_badge.get_instance_id() != first_badge_id and scene.retained_battle_wall_feedback_art == null and scene.retained_battle_wall_remaining_badge == null, "wall count change invalidates and rebuilds feedback chrome")
	feedback_root.queue_free()
	scene.root_layer = null

	print("--- R) retained AI advisor panel ---")
	var advisor_root := Control.new()
	advisor_root.size = Vector2(1280.0, 720.0)
	root.add_child(advisor_root)
	scene.root_layer = advisor_root
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.ai_assist_enabled = true
	scene.draw_advisor_panel(advisor_root)
	var first_advisor := advisor_root.get_node_or_null("AdvisorPanel") as Control
	var first_advisor_id: int = first_advisor.get_instance_id() if first_advisor != null else 0
	scene.retain_battle_advisor_panel_for_render()
	check(scene.retained_battle_advisor_panel != null and scene.retained_battle_advisor_panel_signature != "", "unchanged advisor panel enters bounded retention")
	scene.draw_advisor_panel(advisor_root)
	var second_advisor := advisor_root.get_node_or_null("AdvisorPanel") as Control
	check(second_advisor != null and second_advisor.get_instance_id() == first_advisor_id and scene.retained_battle_advisor_panel == null and scene.ai_advisor_root_generation == scene.ui_page_generation, "unchanged advisor redraw reuses the complete panel and restores advisor generation")
	scene.retain_battle_advisor_panel_for_render()
	scene.wall.append("1W")
	if first_advisor != null and is_instance_valid(first_advisor) and first_advisor.get_parent() != null:
		first_advisor.get_parent().remove_child(first_advisor)
		first_advisor.queue_free()
	scene.draw_advisor_panel(advisor_root)
	var changed_advisor := advisor_root.get_node_or_null("AdvisorPanel") as Control
	check(changed_advisor != null and changed_advisor.get_instance_id() != first_advisor_id and scene.retained_battle_advisor_panel == null, "wall state change invalidates and rebuilds the advisor panel")
	advisor_root.queue_free()
	scene.root_layer = null

	print("--- S) retained table surface scaffold ---")
	var surface_root := Control.new()
	surface_root.size = Vector2(1280.0, 720.0)
	root.add_child(surface_root)
	scene.root_layer = surface_root
	scene.mode = "offline"
	var first_table: Control = scene.draw_battle_table_surface(surface_root, 0)
	var first_outer := surface_root.get_node_or_null("OfflineTable3DOuterShell") as Control
	var first_depth := first_table.get_node_or_null("BattleTablePerspectiveDepth") as BattleTableDepth if first_table != null else null
	var first_surface_id: int = first_outer.get_instance_id() if first_outer != null else 0
	var first_depth_id: int = first_depth.get_instance_id() if first_depth != null else 0
	scene.retain_battle_table_surface_for_render()
	check(scene.retained_battle_table_surface != null and scene.retained_battle_table_surface_signature != "", "fixed table surface hosts enter the bounded render retention slot")
	var second_table: Control = scene.draw_battle_table_surface(surface_root, 0)
	var second_outer := surface_root.get_node_or_null("OfflineTable3DOuterShell") as Control
	var second_depth := second_table.get_node_or_null("BattleTablePerspectiveDepth") as BattleTableDepth if second_table != null else null
	check(second_outer != null and second_outer.get_instance_id() == first_surface_id and second_depth != null and second_depth.get_instance_id() == first_depth_id and scene.retained_battle_table_surface == null, "unchanged table surface redraw reuses the outer, inner, and perspective hosts")
	scene.retain_battle_table_surface_for_render()
	scene.safe_area_layout_revision += 1
	var changed_table: Control = scene.draw_battle_table_surface(surface_root, 0)
	var changed_outer := surface_root.get_node_or_null("OfflineTable3DOuterShell") as Control
	check(changed_outer != null and changed_outer.get_instance_id() != first_surface_id and changed_table != null and scene.retained_battle_table_surface == null, "safe-area geometry change invalidates and rebuilds the table surface scaffold")
	surface_root.queue_free()
	scene.root_layer = null

	print("--- T) retained online chat action button ---")
	var chat_root := Control.new()
	chat_root.size = Vector2(1280.0, 720.0)
	root.add_child(chat_root)
	scene.root_layer = chat_root
	scene.mode = "online_game"
	scene.chat_panel_open = false
	scene.offline_pending_claim.clear()
	scene.draw_chat_action_button(chat_root)
	var first_chat_button := chat_root.get_node_or_null("ChatActionButton") as Button
	var first_chat_id: int = first_chat_button.get_instance_id() if first_chat_button != null else 0
	scene.retain_battle_chat_action_button_for_render()
	check(scene.retained_battle_chat_action_button != null and scene.retained_battle_chat_action_button_signature != "", "online chat action button enters the bounded render retention slot")
	scene.draw_chat_action_button(chat_root)
	var second_chat_button := chat_root.get_node_or_null("ChatActionButton") as Button
	check(second_chat_button != null and second_chat_button.get_instance_id() == first_chat_id and scene.retained_battle_chat_action_button == null, "unchanged online chat redraw reuses the button and callback subtree")
	scene.retain_battle_chat_action_button_for_render()
	scene.chat_panel_open = true
	scene.draw_chat_action_button(chat_root)
	var changed_chat_button := chat_root.get_node_or_null("ChatActionButton") as Button
	check(changed_chat_button != null and changed_chat_button.get_instance_id() != first_chat_id and scene.retained_battle_chat_action_button == null and changed_chat_button.modulate.a > 0.0, "chat visibility state invalidates and rebuilds the auxiliary button")
	chat_root.queue_free()
	scene.root_layer = null

	print("--- U) retained round summary modal ---")
	var summary_root := Control.new()
	summary_root.size = Vector2(1280.0, 720.0)
	root.add_child(summary_root)
	scene.root_layer = summary_root
	scene.mode = "offline"
	scene.offline_phase = "ended"
	scene.round_result_kind = "win"
	scene.round_summary = "P0胡五万，2番 1000分。庄家连庄。"
	scene.last_score_deltas.clear()
	scene.last_score_deltas.append(1000)
	scene.last_score_deltas.append(-1000)
	scene.last_score_deltas.append(0)
	scene.last_score_deltas.append(0)
	scene.last_win_score = {"winner": 0, "fan": 2, "points": 1000, "reasons": ["平和"], "win_tile": "5W", "self_draw": false, "limit_name": ""}
	scene.offline_last_winner = 0
	scene.offline_dealer_repeat = true
	scene.offline_package_liability.clear()
	scene.offline_sim_quiet = false
	scene.fx_enabled = true
	scene.draw_round_summary(summary_root)
	var first_summary_panel := summary_root.get_node_or_null("RoundSummaryPanel") as Control
	var first_summary_shield := summary_root.get_node_or_null("RoundSummaryModalInputShield") as Control
	var first_summary_rows := summary_root.find_children("RoundSummaryRankRow_*", "Control", true, false)
	var first_summary_row := first_summary_rows[0] as Control if not first_summary_rows.is_empty() else null
	var first_summary_preview := first_summary_panel.find_child("AnimationPreview_victory_sparkle", true, false) as Control if first_summary_panel != null else null
	var first_summary_panel_id: int = first_summary_panel.get_instance_id() if first_summary_panel != null else 0
	var first_summary_shield_id: int = first_summary_shield.get_instance_id() if first_summary_shield != null else 0
	check(scene.fx_enabled_effective(), "settlement test enables the runtime FX layer")
	check(scene.animation_asset_spec("victory_sparkle").size() > 0, "settlement test can resolve the victory preview asset")
	check(first_summary_panel != null and first_summary_shield != null and str(first_summary_panel.get_meta("round_summary_render_signature", "")) == scene.battle_round_summary_identity_signature() and str(first_summary_shield.get_meta("round_summary_render_signature", "")) == scene.battle_round_summary_identity_signature(), "production summary draw writes the paired modal retention signature")
	check(scene.screen_tweens.size() > 0, "animated settlement registers transient screen work")
	check(first_summary_row != null, "animated settlement includes a reusable rank row")
	check(first_summary_preview != null, "animated settlement includes a reusable animation preview")
	if first_summary_panel != null:
		first_summary_panel.modulate = Color(1.0, 1.0, 1.0, 0.17)
		first_summary_panel.scale = Vector2(0.88, 0.88)
	if first_summary_row != null:
		first_summary_row.modulate = Color(1.0, 1.0, 1.0, 0.12)
		first_summary_row.offset_left = -18.0
		first_summary_row.offset_right = -18.0
	if first_summary_preview != null:
		first_summary_preview.modulate.a = 0.31
		first_summary_preview.rotation = 0.08
	scene.retain_battle_round_summary_for_render()
	check(scene.retained_battle_round_summary_panel != null and scene.retained_battle_round_summary_shield != null and scene.retained_battle_round_summary_signature != "", "unchanged settlement modal enters bounded retention")
	scene.clear_screen()
	scene.root_layer = summary_root
	scene.draw_round_summary(summary_root)
	var second_summary_panel := summary_root.get_node_or_null("RoundSummaryPanel") as Control
	var second_summary_shield := summary_root.get_node_or_null("RoundSummaryModalInputShield") as Control
	var second_summary_rows := summary_root.find_children("RoundSummaryRankRow_*", "Control", true, false)
	var second_summary_row := second_summary_rows[0] as Control if not second_summary_rows.is_empty() else null
	var second_summary_preview := second_summary_panel.find_child("AnimationPreview_victory_sparkle", true, false) as Control if second_summary_panel != null else null
	check(second_summary_panel != null and second_summary_panel.get_instance_id() == first_summary_panel_id and second_summary_shield != null and second_summary_shield.get_instance_id() == first_summary_shield_id and scene.retained_battle_round_summary_panel == null and scene.retained_battle_round_summary_shield == null, "unchanged settlement redraw reuses the panel and its input shield")
	check(second_summary_panel != null and is_equal_approx(second_summary_panel.modulate.a, 1.0) and second_summary_panel.scale.is_equal_approx(Vector2.ONE), "retained settlement restores the panel transform")
	check(second_summary_row != null and is_equal_approx(second_summary_row.modulate.a, 1.0) and is_equal_approx(second_summary_row.offset_left, 0.0) and is_equal_approx(second_summary_row.offset_right, 0.0), "retained settlement restores the rank row transform")
	check(second_summary_preview != null and is_equal_approx(second_summary_preview.rotation, 0.0) and is_equal_approx(second_summary_preview.modulate.a, 1.0), "retained settlement restores the animation preview transform")
	scene.retain_battle_round_summary_for_render()
	scene.round_summary += " 结算记录已归档。"
	scene.draw_round_summary(summary_root)
	var changed_summary_panel := summary_root.get_node_or_null("RoundSummaryPanel") as Control
	check(changed_summary_panel != null and changed_summary_panel.get_instance_id() != first_summary_panel_id and scene.retained_battle_round_summary_panel == null and scene.retained_battle_round_summary_shield == null, "changed settlement content invalidates and rebuilds the paired modal")
	summary_root.queue_free()
	scene.root_layer = null

	print("--- V) ron decision count snapshot equivalence ---")
	scene.mode = "offline"
	scene.offline_phase = "resolving"
	scene.offline_sim_quiet = true
	scene.dealer_seat = 0
	scene.last_discard = ""
	scene.last_discard_seat = -1
	scene.offline_passed_win_tiles.clear()
	scene.players[1]["hand"] = ["2W", "3W", "7W", "8W", "9W", "1T", "2T", "3T", "7B", "8B", "9B", "E", "E"]
	scene.players[1]["discards"] = []
	scene.players[1]["melds"] = []
	var ron_hand: Array = scene.players[1]["hand"]
	var ron_tile := "1W"
	var ron_counts: Array = scene.tile_counts(ron_hand)
	var ron_winning_counts: Array = ron_counts.duplicate()
	var ron_tile_index: int = scene.tile_index_normalized(ron_tile)
	ron_winning_counts[ron_tile_index] = int(ron_winning_counts[ron_tile_index]) + 1
	var ron_winning_hand: Array = ron_hand.duplicate()
	ron_winning_hand.append(ron_tile)
	var array_score: Dictionary = scene.calculate_win_score_from_tiles(1, ron_winning_hand, false, "")
	var snapshot_score: Dictionary = scene.calculate_win_score_from_tiles(1, ron_winning_hand, false, "", false, ron_winning_counts, ron_winning_hand.size())
	check(int(array_score.get("fan", -1)) == int(snapshot_score.get("fan", -2)) and int(array_score.get("points", -1)) == int(snapshot_score.get("points", -2)) and array_score.get("reasons", []) == snapshot_score.get("reasons", []), "ron score snapshot preserves the array-path result")
	var array_metrics: Dictionary = scene.effective_tile_metrics(ron_hand, 0, 1, 0)
	var snapshot_metrics: Dictionary = scene.effective_tile_metrics(ron_hand, 0, 1, 0, [], ron_counts)
	check(int(array_metrics.get("count", -1)) == int(snapshot_metrics.get("count", -2)) and int(array_metrics.get("variety", -1)) == int(snapshot_metrics.get("variety", -2)) and array_metrics.get("tiles", []) == snapshot_metrics.get("tiles", []) and array_metrics.get("remaining_by_tile", {}) == snapshot_metrics.get("remaining_by_tile", {}), "ron wait metrics preserve the array-path result")
	var ron_report: Dictionary = scene.ai_ron_decision_report(1, ron_tile)
	check(int(ron_report.get("fan", -1)) == int(array_score.get("fan", -2)), "count-reused ron report preserves the winning fan")
	check(int(ron_report.get("points", -1)) == int(array_score.get("points", -2)), "count-reused ron report preserves the winning points")
	check(int(ron_report.get("wait_variety", -1)) == int(snapshot_metrics.get("variety", -2)), "count-reused ron report preserves the wait variety")
	scene.players[1]["hand"] = ron_winning_hand.duplicate()
	scene.players[1]["discards"] = [ron_tile]
	var completed_ron_report: Dictionary = scene.ai_ron_decision_report(1, ron_tile)
	check(str(completed_ron_report.get("reason", "")) == "舍张振听", "completed self-draw hand keeps the ron furiten fallback")
	scene.players[1]["hand"] = ron_hand.duplicate()
	scene.players[1]["discards"] = []
	var ron_counts_key_before: String = scene.counts_compact_key(ron_counts)
	var ron_default_report: Dictionary = scene.ai_ron_decision_report(1, ron_tile)
	var ron_snapshot_report: Dictionary = scene.ai_ron_decision_report(1, ron_tile, "", ron_counts)
	check(ron_default_report == ron_snapshot_report and scene.counts_compact_key(ron_counts) == ron_counts_key_before, "claim chooser snapshot preserves ron report and source counts")

	print("--- W) discard report snapshot reuse ---")
	scene.offline_phase = "await_discard"
	scene.players[1]["hand"] = ["1W", "4W", "7W", "1T", "4T", "7T", "1B", "4B", "7B", "E", "S", "W", "N", "P"]
	var report_hand: Array = scene.players[1]["hand"]
	var report_tile := "P"
	var report_simulated: Array = report_hand.duplicate()
	report_simulated.erase(report_tile)
	var report_counts: Array = scene.tile_counts(report_simulated)
	var report_original_counts: Array = scene.tile_counts(report_hand)
	var report_context: Dictionary = scene.make_ai_evaluation_context(1, scene.visible_tile_counts())
	var report_shanten: int = scene.calculate_min_shanten_from_counts(report_counts, 0)
	var report_risk_vector: Dictionary = scene.tile_risk_vector(report_tile, 1, [], report_context)
	scene.clear_shanten_cache()
	var report_without_snapshot: Dictionary = scene.build_ai_discard_report(1, report_tile, report_simulated, 0, scene.visible_tile_counts(), {}, report_context, report_counts, report_original_counts, -1, scene.tile_index_normalized(report_tile))
	var report_without_snapshot_misses: int = scene.shanten_cache_misses
	scene.clear_shanten_cache()
	var report_with_snapshot: Dictionary = scene.build_ai_discard_report(1, report_tile, report_simulated, 0, scene.visible_tile_counts(), {}, report_context, report_counts, report_original_counts, -1, scene.tile_index_normalized(report_tile), report_shanten, report_risk_vector)
	check(report_context.has("discard_report_exposed_melds") and report_context.has("discard_report_attack_multiplier") and report_context.has("discard_report_route_focus") and report_context.has("discard_report_risk_factor"), "evaluation context carries discard-invariant seat snapshots")
	check(report_context.has("discard_report_defense_adjustment") and report_context.has("discard_report_wall_progress"), "evaluation context carries invariant defense inputs")
	check(report_without_snapshot_misses > 0 and scene.shanten_cache_misses == 0, "known candidate shanten avoids a second search")
	check(int(report_without_snapshot.get("shanten", 99)) == report_shanten and int(report_with_snapshot.get("shanten", 99)) == report_shanten and is_equal_approx(float(report_without_snapshot.get("score", -1.0)), float(report_with_snapshot.get("score", -2.0))), "snapshot report keeps the original score")
	check(is_equal_approx(float(report_without_snapshot.get("risk", -1.0)), float(report_with_snapshot.get("risk", -2.0))) and report_without_snapshot.get("danger_source", {}) == report_with_snapshot.get("danger_source", {}), "snapshot report keeps the original danger source")

	print("--- X) tsumo decision count snapshot equivalence ---")
	scene.current_seat = 3
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.offline_last_draw = {"seat": 3, "tile": "2W", "source": "normal", "wall_empty": false, "serial": 101}
	scene.offline_self_draw_ready = {"seat": 3, "tile": "2W", "serial": 101}
	scene.players[3]["hand"] = ["2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "9W", "9W", "2T", "3T", "4T", "2W"]
	var tsumo_hand: Array = scene.players[3]["hand"]
	var tsumo_counts: Array = scene.tile_counts(tsumo_hand)
	var tsumo_array_score: Dictionary = scene.calculate_win_score_from_tiles(3, tsumo_hand, true)
	var tsumo_snapshot_score: Dictionary = scene.calculate_win_score_from_tiles(3, [], true, "", false, tsumo_counts, tsumo_hand.size())
	check(int(tsumo_array_score.get("fan", -1)) == int(tsumo_snapshot_score.get("fan", -2)) and int(tsumo_array_score.get("points", -1)) == int(tsumo_snapshot_score.get("points", -2)) and tsumo_array_score.get("reasons", []) == tsumo_snapshot_score.get("reasons", []), "tsumo count snapshot preserves the array score")
	var tsumo_drawn_index: int = scene.tile_index_normalized("2W")
	var tsumo_tenpai_counts: Array = tsumo_counts.duplicate()
	tsumo_tenpai_counts[tsumo_drawn_index] = int(tsumo_tenpai_counts[tsumo_drawn_index]) - 1
	var tsumo_array_metrics: Dictionary = scene.effective_tile_metrics(tsumo_hand.slice(0, tsumo_hand.size() - 1), 0, 3, 0)
	var tsumo_snapshot_metrics: Dictionary = scene.effective_tile_metrics(tsumo_hand.slice(0, tsumo_hand.size() - 1), 0, 3, 0, [], tsumo_tenpai_counts)
	check(tsumo_array_metrics.get("tiles", []) == tsumo_snapshot_metrics.get("tiles", []) and tsumo_array_metrics.get("remaining_by_tile", {}) == tsumo_snapshot_metrics.get("remaining_by_tile", {}), "tsumo count snapshot preserves alternate waits")
	var tsumo_decision: Dictionary = scene.ai_tsumo_decision_report(3, "2W")
	check(int(tsumo_decision.get("fan", -1)) == int(tsumo_array_score.get("fan", -2)) and int(tsumo_decision.get("points", -1)) == int(tsumo_array_score.get("points", -2)) and int(tsumo_decision.get("wait_variety", -1)) == int(tsumo_snapshot_metrics.get("variety", -2)), "optimized tsumo report preserves its decision fields")

	print("--- Y) self-gang effective-count snapshot reuse ---")
	var gang_hand: Array = ["5W", "5W", "5W", "5W", "1W", "2W", "3W", "7W", "8W", "9W", "2T", "3T", "4T", "E"]
	var gang_counts: Array = scene.tile_counts(gang_hand)
	var gang_before_shanten: int = scene.calculate_min_shanten_from_counts(gang_counts, 0)
	var gang_after_hand: Array = gang_hand.duplicate()
	for _i in range(4):
		gang_after_hand.erase("5W")
	var gang_after_counts: Array = gang_counts.duplicate()
	gang_after_counts[scene.tile_index_normalized("5W")] = int(gang_after_counts[scene.tile_index_normalized("5W")]) - 4
	var gang_after_shanten: int = scene.calculate_min_shanten_from_counts(gang_after_counts, 1)
	var gang_before_array: int = scene.effective_tile_count(gang_hand, 0, 1)
	var gang_before_snapshot: int = scene.effective_tile_count(gang_hand, 0, 1, gang_before_shanten, [], gang_counts)
	var gang_after_array: int = scene.effective_tile_count(gang_after_hand, 1, 1)
	var gang_after_snapshot: int = scene.effective_tile_count(gang_after_hand, 1, 1, gang_after_shanten, [], gang_after_counts)
	check(gang_before_array == gang_before_snapshot and gang_after_array == gang_after_snapshot, "self-gang count snapshots preserve before/after effective counts")
	check(gang_before_shanten == 0 and gang_after_shanten == 0, "self-gang fixture keeps the comparable tenpai branch")

	print("--- Z) completion ordering preserves alternate hand families ---")
	var standard_complete: Array = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "2T", "3T", "E", "E"]
	var seven_pairs: Array = ["1W", "1W", "2W", "2W", "3W", "3W", "4W", "4W", "5T", "5T", "6T", "6T", "E", "E"]
	var thirteen_orphans: Array = ["1W", "9W", "1T", "9T", "1B", "9B", "E", "S", "N", "R", "Z", "F", "P", "1W"]
	var incomplete: Array = standard_complete.slice(0, standard_complete.size() - 1)
	for completion_case in [standard_complete, seven_pairs, thirteen_orphans, incomplete]:
		var completion_counts: Array = scene.tile_counts(completion_case)
		var completion_key: String = scene.counts_compact_key(completion_counts)
		var expected_complete: bool = completion_case != incomplete
		check(scene.is_complete_hand_from_counts(completion_counts, completion_case.size(), 0) == expected_complete and scene.counts_compact_key(completion_counts) == completion_key, "completion ordering preserves hand family and source counts")

	print("--- AA) claim strategy snapshot reuse ---")
	scene.players[1]["melds"] = []
	scene.players[1]["hand"] = ["1W", "1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "E", "E", "R"]
	scene.offline_sim_quiet = true
	var claim_context: Dictionary = scene.make_ai_claim_context(1, scene.visible_tile_counts_shared(), [], 0)
	check(claim_context.has("claim_report_attack_multiplier") and claim_context.has("claim_report_claim_aggression") and claim_context.has("claim_report_risk_factor") and claim_context.has("claim_report_route_focus"), "claim context carries static strategy snapshots")
	var claim_report: Dictionary = scene.build_ai_claim_report(1, "peng", "1W", {}, claim_context)
	var uncached_claim_report: Dictionary = claim_report.duplicate(true)
	for key in ["ai_attack_multiplier", "ai_claim_aggression", "ai_risk_factor", "ai_route_focus"]:
		uncached_claim_report.erase(key)
	check(is_equal_approx(scene.ai_claim_action_score(claim_report, 1), scene.ai_claim_action_score(uncached_claim_report, 1)), "claim action score keeps its fallback result")
	check(is_equal_approx(scene.ai_claim_route_bonus(claim_report), scene.ai_claim_route_bonus(uncached_claim_report)), "claim route bonus keeps its fallback result")

	print("--- AB) self-gang strategy snapshot reuse ---")
	scene.players[1]["hand"] = ["5W", "5W", "5W", "5W", "1W", "2W", "3W", "7W", "8W", "9W", "2T", "3T", "4T", "E"]
	var gang_snapshot_counts: Array = scene.tile_counts(scene.players[1]["hand"])
	var gang_context: Dictionary = scene.make_ai_evaluation_context(1, scene.visible_tile_counts_shared())
	gang_context["hand_counts"] = gang_snapshot_counts
	gang_context["self_gang_attack_multiplier"] = scene.ai_total_attack_multiplier(1)
	gang_context["self_gang_gang_aggression"] = scene.ai_gang_aggression(1)
	gang_context["self_gang_wait_focus"] = scene.ai_wait_value_focus(1)
	gang_context["self_gang_difficulty"] = scene.AI_DIFFICULTY_NORMAL
	check(gang_context.has("self_gang_attack_multiplier") and gang_context.has("self_gang_gang_aggression") and gang_context.has("self_gang_wait_focus") and gang_context.has("self_gang_difficulty"), "self-gang context carries static strategy snapshots")
	var gang_report: Dictionary = scene.build_ai_self_gang_report(1, "5W", "concealed", gang_context)
	var uncached_gang_report: Dictionary = gang_report.duplicate(true)
	for key in ["ai_attack_multiplier", "ai_gang_aggression", "ai_wait_focus", "ai_difficulty"]:
		uncached_gang_report.erase(key)
	check(is_equal_approx(scene.ai_self_gang_action_score(gang_report), scene.ai_self_gang_action_score(uncached_gang_report)), "self-gang action score keeps its fallback result")

	print("--- AC) discard fixed-input snapshot reuse ---")
	scene.players[1]["melds"] = [["1W", "1W", "1W"]]
	scene.players[1]["hand"] = ["2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "2T", "3T", "4T", "E", "S"]
	var discard_context: Dictionary = scene.make_ai_evaluation_context(1, scene.visible_tile_counts_shared())
	check(discard_context.has("discard_report_difficulty") and discard_context.has("discard_report_wall_count") and discard_context.has("discard_report_wait_focus") and discard_context.has("discard_report_profile_label") and discard_context.has("discard_report_profile_short"), "discard context carries fixed difficulty, wall, wait, and profile inputs")
	var discard_fallback_context: Dictionary = discard_context.duplicate(true)
	for key in ["discard_report_difficulty", "discard_report_wall_count", "discard_report_wait_focus", "discard_report_profile_label", "discard_report_profile_short"]:
		discard_fallback_context.erase(key)
	var discard_pressure: Dictionary = scene.ai_pressure_context(1, discard_context)
	var discard_simulated: Array = scene.players[1]["hand"].duplicate()
	discard_simulated.erase("E")
	var discard_counts: Array = scene.tile_counts(discard_simulated)
	var discard_original: Array = scene.tile_counts(scene.players[1]["hand"])
	var discard_snapshot_report: Dictionary = scene.build_ai_discard_report(1, "E", discard_simulated, 1, scene.visible_tile_counts_shared(), discard_pressure, discard_context, discard_counts, discard_original, -1, scene.tile_index_normalized("E"))
	var discard_fallback_report: Dictionary = scene.build_ai_discard_report(1, "E", discard_simulated, 1, scene.visible_tile_counts_shared(), discard_pressure, discard_fallback_context, discard_counts, discard_original, -1, scene.tile_index_normalized("E"))
	check(is_equal_approx(float(discard_snapshot_report.get("score", -1.0)), float(discard_fallback_report.get("score", -2.0))) and str(discard_snapshot_report.get("ai_profile", "")) == str(discard_fallback_report.get("ai_profile", "?")), "discard fixed-input snapshots preserve the legacy report result")

	print("--- AD) BGM watchdog deadline throttling ---")
	scene.music_enabled = true
	scene.bgm_start_in_flight = false
	scene.next_bgm_retry_msec = 0
	scene.keep_background_music_alive(1000)
	check(scene.next_bgm_retry_msec == 2000, "unavailable runtime audio schedules the next BGM retry")
	scene.keep_background_music_alive(1500)
	check(scene.next_bgm_retry_msec == 2000, "BGM watchdog skips runtime checks before its retry deadline")
	scene.keep_background_music_alive(2000)
	check(scene.next_bgm_retry_msec == 3000, "BGM watchdog advances the retry deadline after another unavailable check")
	scene.next_bgm_retry_msec = 0
	scene.bgm_start_in_flight = true
	scene.keep_background_music_alive(3000)
	check(scene.next_bgm_retry_msec == 0, "BGM watchdog skips runtime checks while async startup is in flight")

	print("--- AE) discard player-pressure and wait snapshots ---")
	scene.players[0]["melds"] = [["E", "E", "E"]]
	scene.players[0]["discards"] = ["1W", "9W", "E"]
	scene.bgm_start_in_flight = false
	scene.music_enabled = false
	var pressure_context_116: Dictionary = scene.make_ai_evaluation_context(1, scene.visible_tile_counts_shared())
	check(pressure_context_116.has("discard_report_human_readiness") and int(pressure_context_116.get("discard_report_exposed_melds", -1)) == scene.exposed_meld_count_for_seat(1), "discard context carries human readiness and exposed-meld snapshots")
	var pressure_fallback_context_116: Dictionary = pressure_context_116.duplicate(true)
	pressure_fallback_context_116.erase("discard_report_human_readiness")
	var player_pressure_snapshot: float = scene.human_target_discard_pressure(1, "5W", 24.0, {}, 2, pressure_context_116)
	var player_pressure_fallback: float = scene.human_target_discard_pressure(1, "5W", 24.0, {}, 2, pressure_fallback_context_116)
	check(is_equal_approx(player_pressure_snapshot, player_pressure_fallback), "human readiness snapshot preserves target pressure")
	var open_wait_hand: Array = ["2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "9W", "9W"]
	scene.players[1]["melds"] = [["1W", "1W", "1W"]]
	var open_wait_metrics: Dictionary = scene.effective_tile_metrics(open_wait_hand, 1, 1, 0)
	var open_wait_counts: Array = scene.tile_counts(open_wait_hand)
	var open_wait_array: Dictionary = scene.wait_value_metrics(1, open_wait_hand, 1, 0, open_wait_metrics.get("tiles", []), open_wait_metrics.get("remaining_by_tile", {}), true)
	var open_wait_snapshot: Dictionary = scene.wait_value_metrics(1, open_wait_hand, 1, 0, open_wait_metrics.get("tiles", []), open_wait_metrics.get("remaining_by_tile", {}), true, {}, -1.0, -1.0, open_wait_counts, 1)
	check(open_wait_array == open_wait_snapshot, "exposed-meld wait snapshot preserves wait valuation")

	print("--- AF) discard report inner-loop snapshots ---")
	scene.players[1]["hand"] = open_wait_hand.duplicate()
	var report_context_117: Dictionary = scene.make_ai_evaluation_context(1, scene.visible_tile_counts_shared())
	var report_counts_117: Array = scene.tile_counts(open_wait_hand)
	var report_wait_metrics_117: Dictionary = scene.effective_tile_metrics(open_wait_hand, 1, 1, 0, [], report_counts_117)
	var report_with_context_117: Dictionary = scene.build_ai_discard_report(1, "1W", open_wait_hand, 1, scene.visible_tile_counts_shared(), {}, report_context_117, report_counts_117, report_counts_117, -1, scene.tile_index_normalized("1W"), 0)
	var expected_wait_117: Dictionary = scene.wait_value_metrics(1, open_wait_hand, 1, 0, report_with_context_117.get("effective_tiles", report_wait_metrics_117.get("tiles", [])), report_with_context_117.get("effective_remaining", report_wait_metrics_117.get("remaining_by_tile", {})), true, {}, float(report_context_117.get("discard_report_attack_multiplier", -1.0)), float(report_context_117.get("discard_report_wait_focus", -1.0)), report_counts_117, 1)
	check(is_equal_approx(float(report_with_context_117.get("wait_value", -1.0)), float(expected_wait_117.get("score", -2.0))), "discard reports pass the captured wait focus into wait valuation")
	var report_fallback_context_117: Dictionary = report_context_117.duplicate(true)
	for key in ["discard_report_wait_focus"]:
		report_fallback_context_117.erase(key)
	var report_without_wait_snapshot_117: Dictionary = scene.build_ai_discard_report(1, "1W", open_wait_hand, 1, scene.visible_tile_counts_shared(), {}, report_fallback_context_117, report_counts_117, report_counts_117, -1, scene.tile_index_normalized("1W"), 0)
	check(is_equal_approx(float(report_with_context_117.get("wait_value", -1.0)), float(report_without_wait_snapshot_117.get("wait_value", -2.0))), "wait-focus snapshot preserves the standalone fallback result")
	var readiness_117: float = scene.human_readiness_for_defense()
	var expected_readiness_117 := float(scene.players[0]["melds"].size()) * 3.4 + float(scene.players[0]["discards"].size()) * 0.22
	var readiness_wall_117: int = scene.get_wall_count()
	if readiness_wall_117 <= scene.wall_phase_threshold(30):
		expected_readiness_117 += 2.5
	if readiness_wall_117 <= scene.wall_phase_threshold(18):
		expected_readiness_117 += 3.5
	if scene.players[0]["melds"].size() >= 3 or scene.players[0]["discards"].size() >= 14:
		expected_readiness_117 += 4.0
	check(is_equal_approx(readiness_117, expected_readiness_117) and is_equal_approx(readiness_117, scene.human_readiness_for_defense()), "human readiness remains stable after the single wall read")

	print("--- AG) feed penalty difficulty snapshot ---")
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	var feed_weight_fallback_118: float = scene.discard_feed_penalty_weight(1.20, 0)
	var feed_weight_snapshot_118: float = scene.discard_feed_penalty_weight(1.20, 0, scene.AI_DIFFICULTY_HARD)
	var feed_weight_easy_118: float = scene.discard_feed_penalty_weight(1.20, 0, scene.AI_DIFFICULTY_EASY)
	check(is_equal_approx(feed_weight_fallback_118, feed_weight_snapshot_118), "feed penalty difficulty snapshot preserves the live fallback")
	check(not is_equal_approx(feed_weight_snapshot_118, feed_weight_easy_118), "feed penalty helper honors an explicit difficulty snapshot")

	print("--- AH) targeted threat-card ranking ---")
	scene.players[0]["hand"] = ["1W", "2W", "3W", "5W", "7W", "9W", "E", "S"]
	scene.players[1]["discards"] = ["1W", "4W", "7W"]
	var threat_context_119: Dictionary = scene.make_ai_evaluation_context(0, scene.visible_tile_counts_shared())
	var targeted_labels_119: Array = scene.threat_safe_tile_labels(0, "suit", 0, 3, threat_context_119, 1)
	var general_labels_119: Array = scene.threat_safe_tile_labels(0, "suit", 0, 3, threat_context_119)
	var targeted_repeat_119: Array = scene.threat_safe_tile_labels(0, "suit", 0, 3, threat_context_119, 1)
	check(targeted_labels_119.size() <= 3 and general_labels_119.size() <= 3, "targeted and general threat cards keep their bounded result size")
	check(targeted_labels_119 == targeted_repeat_119, "targeted threat-card ranking remains deterministic")

	print("--- AI) threat/readiness wall snapshots ---")
	var threat_key_120: String = scene.threat_report_table_state_cache_key(0, scene.visible_tile_counts_shared())
	var threat_key_repeat_120: String = scene.threat_report_table_state_cache_key(0, scene.visible_tile_counts_shared())
	var readiness_120: float = scene.opponent_readiness_score_from_plan(1, 12.0)
	check(threat_key_120 != "" and threat_key_120 == threat_key_repeat_120, "threat cache key remains stable across repeated wall snapshots")
	check(readiness_120 >= 0.0, "plan-based opponent readiness remains valid with the wall snapshot")

	print("--- AJ) visible-count key reuse ---")
	var visible_counts_121: Array = scene.visible_tile_counts_shared()
	var visible_key_121: String = scene.counts_compact_key(visible_counts_121)
	var threat_key_default_121: String = scene.threat_report_table_state_cache_key(0, visible_counts_121)
	var threat_key_override_121: String = scene.threat_report_table_state_cache_key(0, visible_counts_121, visible_key_121)
	var context_121: Dictionary = scene.make_ai_evaluation_context(0, visible_counts_121)
	check(threat_key_default_121 == threat_key_override_121, "visible-count key override preserves the threat cache key")
	check(str(context_121.get("visible_counts_key", "")) == visible_key_121 and str(context_121.get("threat_cache_state_key", "")) == threat_key_override_121, "evaluation context reuses one visible-count key")

	print("--- AK) claim context key reuse ---")
	var claim_context_122: Dictionary = scene.make_ai_claim_context(1)
	var claim_eval_context_122: Dictionary = claim_context_122.get("eval_context", {})
	var claim_visible_122: Array = claim_eval_context_122.get("visible_counts", [])
	var claim_visible_key_122: String = scene.counts_compact_key(claim_visible_122)
	check(claim_visible_key_122 != "" and str(claim_eval_context_122.get("visible_counts_key", "")) == claim_visible_key_122, "snapshot-free claim context keeps the live visible-count key")
	var explicit_visible_122: Array = scene.visible_tile_counts_shared()
	var explicit_claim_context_122: Dictionary = scene.make_ai_claim_context(1, explicit_visible_122)
	var explicit_claim_eval_122: Dictionary = explicit_claim_context_122.get("eval_context", {})
	check(str(explicit_claim_eval_122.get("visible_counts_key", "")) == scene.counts_compact_key(explicit_visible_122), "snapshot claim context keeps the supplied visible-count key")

	print("--- AL) tsumo difficulty snapshot reuse ---")
	scene.current_seat = 3
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.offline_last_draw = {"seat": 3, "tile": "2W", "source": "normal", "wall_empty": false, "serial": 123}
	scene.offline_self_draw_ready = {"seat": 3, "tile": "2W", "serial": 123}
	scene.players[3]["hand"] = ["2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "9W", "9W", "2T", "3T", "4T", "2W"]
	scene.ai_difficulty = scene.AI_DIFFICULTY_EASY
	var tsumo_easy_123: Dictionary = scene.ai_tsumo_decision_report(3, "2W")
	scene.ai_difficulty = -100
	var tsumo_clamped_easy_123: Dictionary = scene.ai_tsumo_decision_report(3, "2W")
	check(tsumo_easy_123 == tsumo_clamped_easy_123, "tsumo difficulty reuse preserves the normalized easy decision")
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	var tsumo_hard_123: Dictionary = scene.ai_tsumo_decision_report(3, "2W")
	scene.ai_difficulty = 100
	var tsumo_clamped_hard_123: Dictionary = scene.ai_tsumo_decision_report(3, "2W")
	check(tsumo_hard_123 == tsumo_clamped_hard_123, "tsumo difficulty reuse preserves the normalized hard decision")

	print("--- AM) effective-tile hand key reuse ---")
	var compact_hand_124: Array = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "2T", "E", "S"]
	var compact_counts_124: Array = scene.tile_counts(compact_hand_124)
	var compact_key_124: String = scene.counts_compact_key(compact_counts_124)
	scene.clear_ai_report_cache()
	var unknown_metrics_124: Dictionary = scene.effective_tile_metrics(compact_hand_124, 0, 1)
	var known_shanten_124: int = scene.calculate_min_shanten_from_counts(compact_counts_124)
	var snapshot_metrics_124: Dictionary = scene.effective_tile_metrics(compact_hand_124, 0, 1, known_shanten_124, [], compact_counts_124)
	check(unknown_metrics_124.get("tiles", []) == snapshot_metrics_124.get("tiles", []) and unknown_metrics_124.get("remaining_by_tile", {}) == snapshot_metrics_124.get("remaining_by_tile", {}), "effective-tile metrics preserve results across the reused hand key")
	check(scene.calculate_min_shanten_from_counts(compact_counts_124, 0, compact_key_124) == known_shanten_124 and scene.counts_compact_key(compact_counts_124) == compact_key_124, "explicit hand key preserves shanten and source counts")

	print("--- AN) discard cache visible-count snapshot reuse ---")
	scene.players[1]["hand"] = compact_hand_124.duplicate()
	scene.offline_sim_quiet = false
	var visible_snapshot_125: Array = scene.visible_tile_counts_shared()
	var discard_key_default_125: String = scene.ai_report_cache_key(1)
	var discard_key_snapshot_125: String = scene.ai_report_cache_key(1, visible_snapshot_125)
	check(discard_key_default_125 != "" and discard_key_default_125 == discard_key_snapshot_125, "discard cache key preserves the supplied visible-count snapshot")
	scene.clear_ai_report_cache()
	var discard_reports_125: Array = scene.get_ai_discard_reports(1)
	var discard_repeat_125: Array = scene.get_ai_discard_reports(1)
	check(not discard_reports_125.is_empty() and discard_reports_125 == discard_repeat_125 and scene.ai_report_cache_hits >= 1, "discard cache-miss and cache-hit paths preserve reports")

	print("--- AO) claim wall snapshot reuse ---")
	var claim_context_126: Dictionary = scene.make_ai_claim_context(1, scene.visible_tile_counts_shared())
	var claim_eval_126: Dictionary = claim_context_126.get("eval_context", {})
	var claim_wall_126: int = scene.get_wall_count()
	check(int(claim_eval_126.get("discard_report_wall_count", -1)) == claim_wall_126, "claim context carries the wall count used by claim reports")
	var claim_wall_default_126: Dictionary = scene.wall_draw_claim_discipline_report(1, "chi", 3, 3, 0.0, 0)
	var claim_wall_snapshot_126: Dictionary = scene.wall_draw_claim_discipline_report(1, "chi", 3, 3, 0.0, 0, claim_wall_126)
	check(claim_wall_default_126 == claim_wall_snapshot_126, "claim wall snapshot preserves discipline output")

	print("--- AP) ron difficulty snapshot reuse ---")
	scene.offline_phase = "resolving"
	scene.players[1]["hand"] = ["1W", "1W", "1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "9W", "9W"]
	scene.ai_difficulty = scene.AI_DIFFICULTY_EASY
	var ron_easy_127: Dictionary = scene.ai_ron_decision_report(1, "5W")
	scene.ai_difficulty = -100
	var ron_clamped_easy_127: Dictionary = scene.ai_ron_decision_report(1, "5W")
	check(ron_easy_127 == ron_clamped_easy_127, "ron difficulty reuse preserves the normalized easy decision")
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	var ron_hard_127: Dictionary = scene.ai_ron_decision_report(1, "5W")
	scene.ai_difficulty = 100
	var ron_clamped_hard_127: Dictionary = scene.ai_ron_decision_report(1, "5W")
	check(ron_hard_127 == ron_clamped_hard_127, "ron difficulty reuse preserves the normalized hard decision")

	print("--- AQ) AI assistance visible-count snapshot reuse ---")
	scene.players[1]["hand"] = compact_hand_124.duplicate()
	scene.offline_sim_quiet = false
	var assistance_visible_128: Array = scene.visible_tile_counts_shared()
	scene.clear_ai_report_cache()
	var assistance_default_128: Array = scene.get_ai_discard_reports(1)
	scene.clear_ai_report_cache()
	var assistance_snapshot_128: Array = scene.get_ai_discard_reports(1, assistance_visible_128)
	check(not assistance_default_128.is_empty() and assistance_default_128 == assistance_snapshot_128, "AI assistance preserves reports with the shared visible-count snapshot")
	scene.offline_sim_quiet = true
	check(not scene.get_ai_discard_reports(1).is_empty(), "quiet discard evaluation remains lazy without a snapshot")

	print("--- AR) threat/readiness wall snapshot reuse ---")
	scene.players[1]["discards"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T"]
	scene.players[1]["melds"] = [["E", "E", "E"], ["5W", "5W", "5W"]]
	scene.wall.clear()
	for _i in range(55):
		scene.wall.append("1B")
	var wall_snapshot_129: int = scene.get_wall_count()
	var readiness_context_129: Dictionary = scene.make_ai_evaluation_context(0, scene.visible_tile_counts_shared())
	var readiness_state_129: Dictionary = readiness_context_129.get("opponents", {}).get(1, {})
	var readiness_plan_129: float = float(readiness_state_129.get("plan_pressure", -1.0))
	var readiness_expected_129: float = scene.opponent_readiness_score_from_plan(1, readiness_plan_129, wall_snapshot_129)
	check(int(readiness_context_129.get("discard_report_wall_count", -1)) == wall_snapshot_129, "readiness context carries one wall snapshot")
	check(is_equal_approx(float(readiness_state_129.get("readiness", -1.0)), readiness_expected_129), "runtime readiness matches the explicit wall snapshot")
	scene.wall.clear()
	var readiness_report_129: Dictionary = scene.opponent_readiness_report(0, 1, readiness_context_129)
	check(is_equal_approx(float(readiness_report_129.get("score", -1.0)), readiness_expected_129) and not readiness_report_129.get("reasons", []).has("末盘"), "contextual readiness keeps score and reasons on the captured wall")
	var live_readiness_129: Dictionary = scene.opponent_readiness_report(0, 1)
	check(live_readiness_129.get("reasons", []).has("末盘") and is_equal_approx(float(live_readiness_129.get("score", -1.0)), scene.opponent_readiness_score_from_plan(1, readiness_plan_129, 0)), "context-free readiness retains its live-wall fallback")

	print("--- AS) report/threat cache key wall snapshot reuse ---")
	scene.wall.clear()
	for _i in range(60):
		scene.wall.append("1B")
	var wall_snapshot_130: int = scene.get_wall_count()
	var visible_snapshot_130: Array = scene.visible_tile_counts_shared()
	var threat_key_default_130: String = scene.threat_report_table_state_cache_key(0, visible_snapshot_130)
	var threat_key_snapshot_130: String = scene.threat_report_table_state_cache_key(0, visible_snapshot_130, "", wall_snapshot_130)
	check(threat_key_default_130 != "" and threat_key_default_130 == threat_key_snapshot_130, "threat table key preserves its default result with a wall snapshot")
	var key_context_130: Dictionary = scene.make_ai_evaluation_context(0, visible_snapshot_130)
	check(int(key_context_130.get("discard_report_wall_count", -1)) == wall_snapshot_130 and str(key_context_130.get("threat_cache_state_key", "")) == threat_key_snapshot_130, "evaluation context reuses the captured wall for its threat key")
	var report_key_default_130: String = scene.ai_report_cache_key(1, visible_snapshot_130)
	var report_key_snapshot_130: String = scene.ai_report_cache_key(1, visible_snapshot_130, wall_snapshot_130)
	check(report_key_default_130 != "" and report_key_default_130 == report_key_snapshot_130, "discard report key preserves its default result with a wall snapshot")

	print("--- AT) discard/threat evaluation context reuse ---")
	scene.offline_sim_quiet = false
	scene.offline_phase = "await_discard"
	scene.current_seat = 0
	scene.offline_turn_needs_draw = false
	scene.players[0]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "2T", "3T", "5B", "E"]
	scene.players[1]["discards"] = ["1W", "4W", "7W", "2T"]
	scene.players[2]["discards"] = ["2W", "5W", "8W"]
	scene.players[3]["melds"] = [["E", "E", "E"]]
	scene.wall.clear()
	for _i in range(60):
		scene.wall.append("1B")
	scene.clear_ai_report_cache()
	var visible_snapshot_131: Array = scene.visible_tile_counts_shared()
	var shared_context_131: Dictionary = {}
	var shared_reports_131: Array = scene.get_ai_discard_reports(0, visible_snapshot_131, shared_context_131)
	check(not shared_reports_131.is_empty() and shared_context_131.has("pressure_context"), "discard evaluation exports its completed shared context")
	check(shared_context_131.has("threat_cache_state_key") and shared_context_131.has("opponents"), "shared context retains the threat snapshot inputs")
	var shared_threats_131: Dictionary = scene.render_seat_threat_reports(0, shared_context_131)
	scene.clear_ai_report_cache()
	var baseline_reports_131: Array = scene.get_ai_discard_reports(0, visible_snapshot_131)
	var baseline_context_131: Dictionary = scene.make_ai_evaluation_context(0, visible_snapshot_131)
	var baseline_threats_131: Dictionary = scene.render_seat_threat_reports(0, baseline_context_131)
	check(shared_reports_131 == baseline_reports_131, "shared discard context preserves the baseline ranking")
	check(shared_threats_131 == baseline_threats_131, "shared discard context preserves the baseline threat reports")
	var cache_hit_context_131: Dictionary = {}
	var cached_reports_131: Array = scene.get_ai_discard_reports(0, visible_snapshot_131, cache_hit_context_131)
	check(cached_reports_131 == baseline_reports_131 and cache_hit_context_131.is_empty(), "report-cache hits retain lazy threat-context creation")

	print("--- AU) helper text discard-report snapshot reuse ---")
	scene.ai_assist_enabled = true
	scene.current_human_advice = []
	scene.offline_sim_quiet = false
	scene.offline_phase = "await_discard"
	scene.current_seat = 0
	scene.offline_turn_needs_draw = false
	scene.players[0]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "2T", "3T", "5B", "E"]
	scene.wall.clear()
	for _i in range(60):
		scene.wall.append("1B")
	scene.clear_ai_report_cache()
	var hint_text_132: String = scene.human_hint_text()
	check(hint_text_132 != "" and scene.ai_report_cache_misses == 1 and scene.ai_report_cache_hits == 0, "human hint reuses its report array for safest-discard text")
	scene.current_human_advice = []
	scene.clear_ai_report_cache()
	var tray_text_132: String = scene.hand_tray_text()
	check(tray_text_132 != "" and scene.ai_report_cache_misses == 1 and scene.ai_report_cache_hits == 0, "hand tray reuses its report array for safety text")
	scene.current_human_advice = []
	scene.clear_ai_report_cache()
	var advice_text_132: String = scene.ai_advice_summary(0)
	check(advice_text_132 != "" and scene.ai_report_cache_misses == 1 and scene.ai_report_cache_hits == 0, "advice summary reuses its report array for safest-discard text")
	scene.current_human_advice = []
	scene.clear_ai_report_cache()
	var defense_reports_132: Array = scene.get_ai_discard_reports(0)
	var defense_best_132: Dictionary = defense_reports_132[0] if not defense_reports_132.is_empty() else {}
	var defense_text_132: String = scene.advisor_defense_text(0, defense_best_132, defense_reports_132)
	check(defense_text_132 != "" and scene.ai_report_cache_hits == 0, "detailed defense text reuses its supplied report array")

	print("--- AV) advisor threat summary reuse ---")
	scene.current_seat = 1
	scene.last_discard = "3B"
	scene.players[1]["melds"] = [["5W", "5W", "5W"]]
	scene.offline_phase = "pending_claim"
	scene.offline_pending_claim = {"tile": "5W", "options": ["pass"], "chi_choices": []}
	scene.clear_ai_report_cache()
	var pending_defense_baseline_133: String = scene.advisor_defense_text(0)
	scene.clear_ai_report_cache()
	var pending_cards_133: Array = scene.advisor_panel_card_payloads()
	var pending_card_133: Dictionary = pending_cards_133[2] if pending_cards_133.size() > 2 else {}
	check(str(pending_card_133.get("main", "")) == pending_defense_baseline_133 and str(pending_card_133.get("sub", "")) != "", "pending-claim advisor card preserves both defense texts")
	check(scene.threat_report_cache_misses > 0 and scene.threat_report_cache_hits == 0, "pending-claim advisor card reuses one threat summary")
	scene.offline_phase = "resolving"
	scene.offline_pending_claim = {}
	scene.clear_ai_report_cache()
	var waiting_defense_baseline_133: String = scene.advisor_defense_text(0)
	scene.clear_ai_report_cache()
	var waiting_cards_133: Array = scene.advisor_panel_card_payloads()
	var waiting_card_133: Dictionary = waiting_cards_133[2] if waiting_cards_133.size() > 2 else {}
	check(str(waiting_card_133.get("main", "")) == waiting_defense_baseline_133, "waiting advisor card preserves its defense text")
	check(scene.threat_report_cache_misses > 0 and scene.threat_report_cache_hits == 0, "waiting advisor card reuses one threat summary")

	print("--- AW) advisor helper threat snapshot reuse ---")
	scene.offline_phase = "await_discard"
	scene.current_seat = 0
	scene.offline_turn_needs_draw = false
	scene.players[0]["hand"] = ["1W", "2W"]
	scene.players[1]["melds"] = [["5W", "5W", "5W"], ["6W", "6W", "6W"]]
	var recommended_134: Dictionary = {"tile": "1W", "risk": 12.0, "risk_label": "中", "safety_label": "", "stance": "均衡"}
	var safest_134: Dictionary = {"tile": "2W", "risk": 1.0, "risk_label": "低", "safety_label": "安", "stance": "均衡", "score": 0.0, "ukeire": 0}
	var report_snapshot_134: Array = [recommended_134, safest_134]
	scene.clear_ai_report_cache()
	var threat_snapshot_134: Dictionary = scene.opponent_threat_report(0)
	scene.clear_ai_report_cache()
	var fallback_hint_134: String = scene.safest_discard_hint_text(recommended_134, safest_134)
	scene.clear_ai_report_cache()
	var snapshot_hint_134: String = scene.safest_discard_hint_text(recommended_134, safest_134, threat_snapshot_134)
	check(not threat_snapshot_134.is_empty() and fallback_hint_134 == snapshot_hint_134, "safest-discard helper preserves its fallback text")
	check(scene.threat_report_cache_hits == 0 and scene.threat_report_cache_misses == 0, "safest-discard helper reuses an explicit threat report")
	scene.current_human_advice = report_snapshot_134
	scene.clear_ai_report_cache()
	var hint_text_134: String = scene.human_hint_text()
	check(hint_text_134 != "" and scene.threat_report_cache_misses > 0 and scene.threat_report_cache_hits == 0, "human hint reuses one threat report")
	scene.clear_ai_report_cache()
	var advice_text_134: String = scene.ai_advice_summary(0)
	check(advice_text_134 != "" and scene.threat_report_cache_misses > 0 and scene.threat_report_cache_hits == 0, "advice summary reuses one threat report")
	scene.clear_ai_report_cache()
	var defense_text_134: String = scene.advisor_defense_text(0, recommended_134, report_snapshot_134)
	check(defense_text_134 != "" and scene.threat_report_cache_misses > 0 and scene.threat_report_cache_hits == 0, "advisor defense text does not re-read its threat report")

	print("--- AY) action dock button snapshot reuse ---")
	var action_root_136 := Control.new()
	action_root_136.size = Vector2(1280.0, 720.0)
	root.add_child(action_root_136)
	scene.root_layer = action_root_136
	var action_bar_136 := HBoxContainer.new()
	action_bar_136.name = "ActionSnapshotTestBar"
	action_bar_136.size = Vector2(520.0, 64.0)
	action_bar_136.position = Vector2(700.0, 620.0)
	action_root_136.add_child(action_bar_136)
	var nested_lane_136 := VBoxContainer.new()
	nested_lane_136.name = "NestedActionLane"
	action_bar_136.add_child(nested_lane_136)
	var game_button_136 := Button.new()
	game_button_136.name = "SnapshotGameButton"
	game_button_136.text = "出牌"
	nested_lane_136.add_child(game_button_136)
	var support_button_136 := Button.new()
	support_button_136.name = "SnapshotSupportButton"
	support_button_136.text = "语音"
	support_button_136.set_meta("non_game_action", true)
	action_bar_136.add_child(support_button_136)
	scene.action_bar = action_bar_136
	var button_snapshot_136: Array[Button] = scene.action_bar_buttons()
	var action_signature_136: String = scene.battle_action_chrome_identity_signature(button_snapshot_136)
	check(button_snapshot_136.size() == 2 and scene.action_bar_button_count(button_snapshot_136) == 1, "action snapshot captures nested game and support buttons")
	nested_lane_136.remove_child(game_button_136)
	check(scene.action_bar_button_count(button_snapshot_136) == 1 and scene.action_bar_button_count() == 0 and scene.battle_action_chrome_identity_signature(button_snapshot_136) == action_signature_136, "action snapshot stays stable while the live fallback sees tree mutation")
	nested_lane_136.add_child(game_button_136)
	var drawn_buttons_136: Array[Button] = scene.draw_action_dock(action_root_136)
	check(drawn_buttons_136.size() == 2 and action_root_136.find_child("ActionButtonDock", true, false) != null, "draw action dock returns its button snapshot")
	scene.finalize_action_bar_layout(drawn_buttons_136)
	check(scene.action_bar_button_count(drawn_buttons_136) == 1, "final action layout consumes the draw snapshot")
	scene.retain_battle_action_chrome_for_render()
	var retained_buttons_136: Array[Button] = scene.draw_action_dock(action_root_136)
	check(retained_buttons_136.size() == 2 and scene.retained_battle_action_dock == null, "retained action-dock redraw returns the same button snapshot")
	scene.finalize_action_bar_layout(retained_buttons_136)
	action_root_136.queue_free()
	scene.root_layer = null

	print("--- AX) chat candidate meld snapshot reuse ---")
	var meld_lane_candidate_135 := Rect2(Vector2(0.135, 0.240), Vector2(0.205, 0.510))
	var empty_meld_snapshot_135: Dictionary = {}
	var empty_meld_score_135: float = scene.chat_panel_candidate_overlap_score(meld_lane_candidate_135, empty_meld_snapshot_135)
	scene.players[3]["melds"] = [["5W", "5W", "5W"]]
	var reused_empty_meld_score_135: float = scene.chat_panel_candidate_overlap_score(meld_lane_candidate_135, empty_meld_snapshot_135)
	var live_meld_score_135: float = scene.chat_panel_candidate_overlap_score(meld_lane_candidate_135)
	check(is_equal_approx(empty_meld_score_135, reused_empty_meld_score_135), "chat scoring reuses an explicit empty meld snapshot")
	check(live_meld_score_135 == INF and live_meld_score_135 != reused_empty_meld_score_135, "chat scoring keeps the live meld exclusion fallback")
	var chat_rect_135: Rect2 = scene.chat_panel_rect()
	check(chat_rect_135.size.x > 0.0 and chat_rect_135.size.y > 0.0, "chat panel keeps a bounded lane after meld snapshot selection")

	print("--- AZ) hand required-width snapshot reuse ---")
	var hand_width_snapshot_137: Array = ["1W", "2W", "3W", "1T", "2T", "3T", "1B", "2B", "3B", "E", "E", "R", "H1", "H2"]
	var hand_metrics_137: Dictionary = scene.hand_layout_metrics_for_content(hand_width_snapshot_137, Vector2(720.0, 300.0), -1)
	var required_width_137: float = scene.hand_layout_required_width(hand_width_snapshot_137, hand_metrics_137)
	var live_fit_137: bool = scene.hand_layout_fits_content(hand_width_snapshot_137, hand_metrics_137)
	var snapshot_fit_137: bool = scene.hand_layout_fits_content(hand_width_snapshot_137, hand_metrics_137, required_width_137)
	check(live_fit_137 == snapshot_fit_137, "hand fit preserves the legacy result when given its solved width")
	var altered_metrics_137: Dictionary = hand_metrics_137.duplicate(true)
	altered_metrics_137["tile_width"] = float(altered_metrics_137.get("tile_width", 0.0)) + 1000.0
	check(scene.hand_layout_fits_content(hand_width_snapshot_137, altered_metrics_137, required_width_137) == snapshot_fit_137 and scene.hand_layout_fits_content(hand_width_snapshot_137, altered_metrics_137) != snapshot_fit_137, "hand fit accepts a stable width snapshot without re-solving altered metrics")

	print("--- BA) hand interaction-state snapshot reuse ---")
	scene.ai_assist_enabled = false
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.players[0]["hand"] = ["1W", "2W", "3W", "1T", "2T", "3T", "1B", "2B", "3B", "E", "E", "R", "H1", "H2"]
	var hand_interaction_root_138 := Control.new()
	hand_interaction_root_138.size = Vector2(1280.0, 720.0)
	root.add_child(hand_interaction_root_138)
	scene.root_layer = hand_interaction_root_138
	scene.show_hand_hint = false
	var can_discard_138: bool = scene.can_self_discard()
	var pending_claim_138: bool = scene.has_pending_claim_window()
	var pending_danger_138: bool = scene.has_pending_danger_discard()
	scene.draw_hand(hand_interaction_root_138)
	var hand_box_138 := hand_interaction_root_138.get_node_or_null("HandTray/HandTrayTiles") as Control
	check(hand_box_138 != null and str(hand_box_138.get_meta("hand_interaction_snapshot_policy", "")) == "one_action_state_snapshot_per_draw", "hand row publishes one interaction snapshot policy")
	check(hand_box_138 != null and bool(hand_box_138.get_meta("hand_can_self_discard_snapshot", false)) == can_discard_138 and bool(hand_box_138.get_meta("hand_pending_claim_window_snapshot", false)) == pending_claim_138 and bool(hand_box_138.get_meta("hand_pending_danger_discard_snapshot", false)) == pending_danger_138, "hand row preserves the captured action-state values")
	hand_interaction_root_138.queue_free()
	scene.root_layer = null

	print("--- BB) post-claim visible-count snapshot reuse ---")
	scene.players[1]["hand"] = ["1B", "2B", "3B", "4B", "5B", "6B", "7B", "8B", "9B", "2T", "4T", "6T", "5W"]
	scene.players[2]["melds"] = [["1W", "2W", "3W"], ["7W", "8W", "9W"]]
	scene.players[2]["discards"] = ["1T", "2T", "3T", "4T", "5T", "6T"]
	scene.offline_claim_counts[scene.claim_source_key(2, 1)] = 2
	var visible_counts_139: Array = scene.visible_tile_counts_shared()
	var simulated_counts_139 = scene.tile_counts(scene.players[1]["hand"])
	var candidate_index_139: int = scene.tile_index("5W")
	simulated_counts_139[candidate_index_139] = int(simulated_counts_139[candidate_index_139]) - 1
	var explicit_context_139: Dictionary = scene.make_ai_evaluation_context(1, visible_counts_139)
	var explicit_pressure_139: Dictionary = scene.ai_pressure_context(1, explicit_context_139)
	var explicit_report_139: Dictionary = scene.build_ai_fast_post_claim_discard_report(1, "5W", 1, explicit_pressure_139, explicit_context_139, simulated_counts_139, visible_counts_139)
	var legacy_context_139: Dictionary = scene.make_ai_evaluation_context(1, visible_counts_139)
	var legacy_pressure_139: Dictionary = scene.ai_pressure_context(1, legacy_context_139)
	var legacy_report_139: Dictionary = scene.build_ai_fast_post_claim_discard_report(1, "5W", 1, legacy_pressure_139, legacy_context_139, simulated_counts_139)
	check(str(explicit_report_139.get("safety_label", "")) == str(legacy_report_139.get("safety_label", "")) and is_equal_approx(float(explicit_report_139.get("score", 0.0)), float(legacy_report_139.get("score", 0.0))), "快速副露后弃牌评估复用可见牌快照且保持旧结果")
	check(explicit_report_139.get("feed_report", {}) == legacy_report_139.get("feed_report", {}), "快速副露后弃牌喂牌报告保持旧结果")

	print("--- BC) self-gang visible-count snapshot reuse ---")
	scene.players[1]["hand"] = ["5W", "5W", "5W", "5W", "1W", "2W", "3W", "7W", "8W", "9W", "2T", "3T", "4T", "E"]
	scene.players[1]["melds"] = []
	scene.wall.clear()
	for _i in range(40):
		scene.wall.append("9B")
	var gang_counts_140: Array = scene.tile_counts(scene.players[1]["hand"])
	var gang_before_shanten_140: int = scene.calculate_min_shanten_from_counts(gang_counts_140, 0)
	var gang_after_hand_140: Array = scene.players[1]["hand"].duplicate()
	for _i in range(4):
		gang_after_hand_140.erase("5W")
	var gang_after_counts_140: Array = gang_counts_140.duplicate()
	var gang_index_140: int = scene.tile_index_normalized("5W")
	gang_after_counts_140[gang_index_140] = int(gang_after_counts_140[gang_index_140]) - 4
	var gang_after_shanten_140: int = scene.calculate_min_shanten_from_counts(gang_after_counts_140, 1)
	var visible_counts_140: Array = scene.visible_tile_counts_shared()
	var gang_context_140: Dictionary = scene.make_ai_evaluation_context(1, visible_counts_140)
	gang_context_140["hand_counts"] = gang_counts_140
	gang_context_140["self_gang_attack_multiplier"] = scene.ai_total_attack_multiplier(1)
	gang_context_140["self_gang_gang_aggression"] = scene.ai_gang_aggression(1)
	gang_context_140["self_gang_wait_focus"] = scene.ai_wait_value_focus(1)
	gang_context_140["self_gang_difficulty"] = scene.AI_DIFFICULTY_NORMAL
	var gang_report_140: Dictionary = scene.build_ai_self_gang_report(1, "5W", "concealed", gang_context_140)
	var before_ukeire_140: int = scene.effective_tile_count(scene.players[1]["hand"], 0, 1, gang_before_shanten_140, visible_counts_140, gang_counts_140)
	var after_ukeire_140: int = scene.effective_tile_count(gang_after_hand_140, 1, 1, gang_after_shanten_140, visible_counts_140, gang_after_counts_140)
	check(int(gang_report_140.get("before_ukeire", -1)) == before_ukeire_140 and int(gang_report_140.get("after_ukeire", -1)) == after_ukeire_140, "暗杠报告复用可见牌快照并保持杠前杠后有效进张")
	check(gang_before_shanten_140 == 0 and gang_after_shanten_140 == 0, "Batch C 暗杠夹具保持同向听边界")

	print("--- BD) quiet discard risk-vector snapshot reuse ---")
	scene.players[1]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "3T", "5T", "E", "S"]
	scene.players[1]["melds"] = []
	scene.offline_phase = "await_discard"
	scene.current_seat = 1
	scene.offline_turn_needs_draw = false
	scene.offline_sim_quiet = true
	scene.offline_all_bot_mode = true
	scene.wall = scene.make_wall()
	var visible_counts_141: Array = scene.visible_tile_counts_shared()
	var explicit_risk_context_141: Dictionary = scene.make_ai_evaluation_context(1, visible_counts_141)
	var legacy_risk_context_141: Dictionary = scene.make_ai_evaluation_context(1, visible_counts_141)
	var explicit_risk_141: Dictionary = scene.tile_risk_vector("1W", 1, visible_counts_141, explicit_risk_context_141)
	var legacy_risk_141: Dictionary = scene.tile_risk_vector("1W", 1, [], legacy_risk_context_141)
	check(is_equal_approx(float(explicit_risk_141.get("score", 0.0)), float(legacy_risk_141.get("score", 0.0))) and is_equal_approx(float(explicit_risk_141.get("threat", 0.0)), float(legacy_risk_141.get("threat", 0.0))), "静默粗排风险向量复用可见牌快照且保持旧结果")
	var risk_context_output_141: Dictionary = {}
	var risk_reports_141: Array = scene.get_ai_discard_reports(1, visible_counts_141, risk_context_output_141)
	check(risk_reports_141.size() > 0 and risk_reports_141.size() <= scene.AI_FAST_EVAL_PRESSURE_TOP_K and risk_context_output_141.has("visible_counts"), "静默粗排保留快照并维持 Top-K 边界")

	print("--- BE) deal-in risk score snapshot reuse ---")
	var explicit_score_142: float = scene.deal_in_risk_score("1W", 1, explicit_risk_context_141, visible_counts_141)
	var legacy_score_142: float = scene.deal_in_risk_score("1W", 1, legacy_risk_context_141)
	check(is_equal_approx(explicit_score_142, legacy_score_142), "风险评分复用可见牌快照且保持旧结果")

	print("--- BF) general threat-card visibility snapshot reuse ---")
	var general_labels_with_context_143: Array = scene.threat_safe_tile_labels(1, "suit", 0, 3, explicit_risk_context_141)
	var general_labels_without_context_143: Array = scene.threat_safe_tile_labels(1, "suit", 0, 3)
	check(general_labels_with_context_143 == general_labels_without_context_143, "通用威胁卡复用可见牌快照且保持旧结果")

	print("--- BG) report-key profile remap snapshot reuse ---")
	scene.offline_sim_quiet = false
	scene.clear_ai_report_cache()
	scene.ai_profile_seat_map = [0, 1, 2, 3]
	var profile_reports_144: Array = scene.get_ai_discard_reports(1)
	scene.ai_profile_seat_map = [0, 2, 1, 3]
	var remapped_profile_reports_144: Array = scene.get_ai_discard_reports(1)
	check(not profile_reports_144.is_empty() and not remapped_profile_reports_144.is_empty() and str(profile_reports_144[0].get("ai_profile", "")) != str(remapped_profile_reports_144[0].get("ai_profile", "")), "人设映射变化使报告键失效并重新计算")

	print("--- BH) feed-risk visibility snapshot reuse ---")
	var feed_snapshot_145: Dictionary = scene.make_ai_evaluation_context(1, visible_counts_141)
	var feed_explicit_145: Dictionary = scene.discard_feed_risk_report("1W", 1, visible_counts_141, feed_snapshot_145)
	var feed_legacy_145: Dictionary = scene.discard_feed_risk_report("1W", 1, [], feed_snapshot_145)
	check(feed_explicit_145 == feed_legacy_145, "喂牌风险报告复用可见牌快照且保持旧结果")

	print("--- BI) human-claim wall snapshot reuse ---")
	var claim_wall_146: int = scene.get_wall_count()
	check(is_equal_approx(scene.human_readiness_for_defense(), scene.human_readiness_for_defense(claim_wall_146)), "玩家准备度复用显式牌墙快照且保持旧结果")

	print("--- BJ) exposed-tile route snapshot reuse ---")
	scene.players[1]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "1T", "3T", "5T", "E", "S", "R"]
	scene.players[1]["melds"] = [["1W", "2W", "3W"], ["E", "E", "E"]]
	var hand_counts_147: Array = scene.tile_counts(scene.players[1]["hand"])
	var meld_indices_147: Array = scene.hand_plan_meld_tile_indices_for_seat(1)
	var live_route_147: Dictionary = scene.hand_plan_eval_for_seat_from_counts(1, hand_counts_147, 14)
	var snapshot_route_147: Dictionary = scene.hand_plan_eval_for_seat_from_counts(1, hand_counts_147, 14, meld_indices_147)
	check(not meld_indices_147.is_empty() and live_route_147 == snapshot_route_147, "路线评估复用副露牌索引且保持旧结果")
	var live_claim_route_147: Dictionary = scene.plan_report_with_extra_melds(1, hand_counts_147, 14, ["9B", "9B", "9B"])
	var snapshot_claim_route_147: Dictionary = scene.plan_report_with_extra_melds(1, hand_counts_147, 14, ["9B", "9B", "9B"], meld_indices_147)
	check(live_claim_route_147 == snapshot_claim_route_147, "副露候选路线复用快照且保持旧结果")

	print("--- BK) discard-pressure opponent lookup reuse ---")
	scene.players[0]["discards"] = []
	scene.players[1]["discards"] = ["5W", "1W", "2W", "3W"]
	scene.players[2]["discards"] = ["5W", "4W", "6W"]
	scene.players[3]["discards"] = ["9B"]
	scene.clear_ai_report_cache()
	var pressure_visible_148: Array = scene.visible_tile_counts_shared()
	var pressure_context_148: Dictionary = scene.make_ai_evaluation_context(0, pressure_visible_148)
	var pressure_score_148: float = scene.discard_pressure_score("5W", 0, pressure_visible_148, pressure_context_148)
	var pressure_visible_count_148: int = scene.visible_tile_count_from_counts("5W", pressure_visible_148)
	var expected_pressure_148: float = float(pressure_visible_count_148) * 3.4 + 3.5 + 5.0 + 3.5 + 1.2 + 1.2
	check(is_equal_approx(pressure_score_148, expected_pressure_148), "下家额外弃牌压力与各对手压力只计入一次且保持评分")
	var pressure_fallback_148: float = scene.discard_pressure_score("5W", 0, pressure_visible_148)
	check(is_equal_approx(pressure_fallback_148, pressure_score_148), "无上下文弃牌压力仍保持实时回退结果")

	print("--- BL) feed-risk opponent lookup reuse ---")
	scene.players[1]["discards"] = ["1W", "2W", "3W"]
	scene.players[2]["discards"] = ["5W", "4W", "6W"]
	scene.players[3]["discards"] = ["9B"]
	scene.clear_ai_report_cache()
	var feed_visible_149: Array = scene.visible_tile_counts_shared()
	var feed_context_149: Dictionary = scene.make_ai_evaluation_context(0, feed_visible_149)
	var feed_legacy_context_149: Dictionary = scene.make_ai_evaluation_context(0, feed_visible_149)
	var feed_report_149: Dictionary = scene.discard_feed_risk_report("5W", 0, feed_visible_149, feed_context_149)
	var feed_legacy_report_149: Dictionary = scene.discard_feed_risk_report("5W", 0, [], feed_legacy_context_149)
	check(feed_report_149 == feed_legacy_report_149 and float(feed_report_149.get("next_seat_chi_score", 0.0)) > 0.0, "下家吃风险与其他对手碰风险保持单次查询和原有报告")
	var feed_details_149: Array = feed_report_149.get("details", [])
	check(not feed_details_149.is_empty(), "喂牌风险仍保留对手详情")

	print("--- BM) all-opponent safety cache reuse ---")
	scene.players[1]["discards"] = ["5W"]
	scene.players[2]["discards"] = ["5W"]
	scene.players[3]["discards"] = ["5W"]
	scene.clear_ai_report_cache()
	var safety_visible_150: Array = scene.visible_tile_counts_shared()
	var safety_context_150: Dictionary = scene.make_ai_evaluation_context(0, safety_visible_150)
	var safe_150: bool = scene.is_tile_safe_against_all("5W", 0, safety_context_150)
	var safe_cached_150: bool = scene.is_tile_safe_against_all("5W", 0, safety_context_150)
	var unsafe_150: bool = scene.is_tile_safe_against_all("6W", 0, safety_context_150)
	var safety_cache_150 = safety_context_150.get("all_safe_tiles", {})
	check(safe_150 and safe_cached_150 and not unsafe_150 and typeof(safety_cache_150) == TYPE_DICTIONARY and (safety_cache_150 as Dictionary).size() == 2, "全桌现物结果在评估上下文中复用且保留真假分支")
	check(not scene.is_tile_safe_against_all("6W", 0), "无上下文全桌现物仍保持实时回退")

	print("--- BN) suji safety cache reuse ---")
	scene.players[1]["discards"] = ["2W", "8W"]
	scene.players[2]["discards"] = []
	scene.players[3]["discards"] = []
	scene.clear_ai_report_cache()
	var suji_visible_151: Array = scene.visible_tile_counts_shared()
	var suji_context_151: Dictionary = scene.make_ai_evaluation_context(0, suji_visible_151)
	var suji_safe_151: bool = scene.is_suji_safe_against_opponent("5W", 1, suji_context_151)
	var suji_cached_151: bool = scene.is_suji_safe_against_opponent("5W", 1, suji_context_151)
	var suji_unsafe_151: bool = scene.is_suji_safe_against_opponent("6W", 1, suji_context_151)
	var suji_cache_151 = suji_context_151.get("suji_safe_tiles", {})
	check(suji_safe_151 and suji_cached_151 and not suji_unsafe_151 and typeof(suji_cache_151) == TYPE_DICTIONARY and (suji_cache_151 as Dictionary).size() == 2, "筋安全结果按对手与牌缓存且保留真假分支")
	check(not scene.is_suji_safe_against_opponent("6W", 1), "无上下文筋安全仍保持实时回退")

	print("--- BO) opponent pattern-threat cache reuse ---")
	scene.players[1]["melds"] = [["1W", "2W", "3W"]]
	scene.players[1]["discards"] = ["9B"]
	scene.clear_ai_report_cache()
	var pattern_visible_152: Array = scene.visible_tile_counts_shared()
	var pattern_context_152: Dictionary = scene.make_ai_evaluation_context(0, pattern_visible_152)
	var pattern_visible_count_152: int = scene.visible_tile_count_from_counts("5W", pattern_visible_152)
	var pattern_score_152: float = scene.opponent_pattern_threat_score(1, "5W", pattern_visible_count_152, pattern_context_152)
	var pattern_cached_152: float = scene.opponent_pattern_threat_score(1, "5W", pattern_visible_count_152, pattern_context_152)
	var pattern_fallback_152: float = scene.opponent_pattern_threat_score(1, "5W", pattern_visible_count_152)
	var pattern_cache_152 = pattern_context_152.get("pattern_threats", {})
	check(is_equal_approx(pattern_score_152, pattern_cached_152) and is_equal_approx(pattern_score_152, pattern_fallback_152) and pattern_score_152 > 0.0 and typeof(pattern_cache_152) == TYPE_DICTIONARY and (pattern_cache_152 as Dictionary).size() == 1, "对手模式威胁在上下文中复用且保持实时回退")

	print("--- BP) discard shape-route feature fusion ---")
	var shared_tiles_153: Array = ["1W", "2W", "3W", "4W", "5W", "5W", "7W", "8W", "1T", "1T", "3T", "E", "E", "R"]
	var shared_counts_153: Array = scene.tile_counts(shared_tiles_153)
	var regular_shape_153: Dictionary = scene.ai_hand_shape_metrics_from_counts(shared_counts_153)
	var fused_features_153: Dictionary = scene.hand_plan_features_from_counts(shared_counts_153, shared_tiles_153.size(), true)
	var fused_shape_153: Dictionary = scene.ai_hand_shape_metrics_from_counts(shared_counts_153, fused_features_153)
	var regular_plan_153: Dictionary = scene.hand_plan_eval_for_seat_from_counts(0, shared_counts_153, shared_tiles_153.size())
	var fused_plan_153: Dictionary = scene.hand_plan_eval_for_seat_from_counts(0, shared_counts_153, shared_tiles_153.size(), [], fused_features_153)
	check(fused_features_153.has("shape_value") and regular_shape_153 == fused_shape_153, "融合路线扫描保留独立牌型形状结果")
	check(regular_plan_153 == fused_plan_153, "融合路线扫描保留路线评估结果")

	print("--- BQ) hand-tray status text snapshot reuse ---")
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.offline_sim_quiet = true
	scene.ai_assist_enabled = true
	scene.current_seat = 0
	scene.players[0]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "2T", "3T", "5B", "E"]
	scene.current_human_advice = [{"tile": "1W", "ukeire": 8, "score": 42.0, "safety_label": "安"}]
	var tray_detail_154: String = scene.hand_tray_text()
	var tray_legacy_visible_154: String = scene.hand_tray_visible_text()
	var tray_snapshot_visible_154: String = scene.hand_tray_visible_text(tray_detail_154)
	check(tray_detail_154 != "" and tray_snapshot_visible_154 == tray_legacy_visible_154, "手牌托盘文本快照保持旧的可见结果")
	var tray_root_154 := Control.new()
	tray_root_154.size = Vector2(1280.0, 720.0)
	root.add_child(tray_root_154)
	scene.root_layer = tray_root_154
	scene.hand_keyboard_selection = -1
	scene.draw_hand(tray_root_154)
	var tray_node_154 := tray_root_154.get_node_or_null("HandTray") as Control
	var tray_status_154 := tray_root_154.get_node_or_null("HandTray/HandTrayStatusText") as Label
	var tray_badge_154 := tray_root_154.get_node_or_null("HandTray/HandTrayStateBadge") as Control
	check(tray_node_154 != null and str(tray_node_154.get_meta("hand_tray_text_snapshot_policy", "")) == "one_status_text_snapshot_per_draw", "手牌托盘重绘只保留一次状态文本快照")
	check(tray_node_154 != null and str(tray_node_154.get_meta("hand_tray_detail_text_snapshot", "")) == tray_detail_154, "手牌托盘元数据保留状态文本快照")
	check(tray_status_154 != null and tray_status_154.text == tray_snapshot_visible_154 and tray_badge_154 != null and str(tray_badge_154.get_meta("state_detail", "")) == tray_detail_154, "状态标签与徽章复用同一文本结果")
	tray_root_154.queue_free()
	scene.root_layer = null

	print("--- BR) hand-tray state color snapshot reuse ---")
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.offline_sim_quiet = true
	scene.ai_assist_enabled = true
	scene.current_seat = 0
	scene.players[0]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "2T", "3T", "5B", "E"]
	scene.current_human_advice = [{"tile": "1W", "ukeire": 8, "score": 42.0, "safety_label": "安"}]
	var state_text_155: String = scene.hand_tray_state_text()
	var live_fill_155: Color = scene.hand_tray_state_fill()
	var snapshot_fill_155: Color = scene.hand_tray_state_fill(state_text_155)
	var live_border_155: Color = scene.hand_tray_state_border()
	var snapshot_border_155: Color = scene.hand_tray_state_border(state_text_155, snapshot_fill_155)
	check(state_text_155 == "出牌" and is_equal_approx(live_fill_155.r, snapshot_fill_155.r) and is_equal_approx(live_fill_155.g, snapshot_fill_155.g) and is_equal_approx(live_fill_155.b, snapshot_fill_155.b) and is_equal_approx(live_fill_155.a, snapshot_fill_155.a) and is_equal_approx(live_border_155.r, snapshot_border_155.r) and is_equal_approx(live_border_155.g, snapshot_border_155.g) and is_equal_approx(live_border_155.b, snapshot_border_155.b) and is_equal_approx(live_border_155.a, snapshot_border_155.a), "状态颜色快照保持旧的填充和边框结果")
	var tray_root_155 := Control.new()
	tray_root_155.size = Vector2(1280.0, 720.0)
	root.add_child(tray_root_155)
	scene.root_layer = tray_root_155
	scene.hand_keyboard_selection = -1
	scene.draw_hand(tray_root_155)
	var tray_node_155 := tray_root_155.get_node_or_null("HandTray") as Control
	var tray_badge_155 := tray_root_155.get_node_or_null("HandTray/HandTrayStateBadge") as Control
	check(tray_node_155 != null and str(tray_node_155.get_meta("hand_tray_state_snapshot_policy", "")) == "one_state_text_and_color_snapshot_per_draw", "手牌托盘每次重绘只解析一次状态颜色")
	check(tray_node_155 != null and str(tray_node_155.get_meta("hand_tray_state_text_snapshot", "")) == state_text_155 and tray_badge_155 != null and str(tray_badge_155.get_meta("state_text_snapshot", "")) == state_text_155, "状态徽章消费托盘发布的文本快照")
	scene.offline_phase = "ended"
	check(tray_node_155 != null and str(tray_node_155.get_meta("hand_tray_state_text_snapshot", "")) == state_text_155, "后续实时状态变化不改写已绘制状态快照")
	tray_root_155.queue_free()
	scene.root_layer = null

	print("--- BS) hand-tray decorative interaction snapshot reuse ---")
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.offline_sim_quiet = true
	scene.ai_assist_enabled = true
	scene.current_seat = 0
	scene.players[0]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "2T", "3T", "5B", "E"]
	scene.current_human_advice = [{"tile": "1W", "ukeire": 8, "score": 42.0, "safety_label": "安"}]
	var tray_root_156 := Control.new()
	tray_root_156.size = Vector2(1280.0, 720.0)
	root.add_child(tray_root_156)
	scene.root_layer = tray_root_156
	scene.hand_keyboard_selection = -1
	scene.draw_hand(tray_root_156)
	var tray_node_156 := tray_root_156.get_node_or_null("HandTray") as Control
	var momentum_156 := tray_root_156.get_node_or_null("HandTray/HandTrayMomentumArt") as Control
	var completion_156 := tray_root_156.get_node_or_null("HandTray/HandTrayCompletionBusArt") as Control
	var suit_156 := tray_root_156.get_node_or_null("HandTray/HandTraySuitFlow") as Control
	check(tray_node_156 != null and momentum_156 != null and completion_156 != null and suit_156 != null, "宽屏手牌装饰节点仍完整创建")
	check(bool(momentum_156.get_meta("hand_active_snapshot", false)) and not bool(momentum_156.get_meta("hand_danger_snapshot", true)) and bool(completion_156.get_meta("hand_active_snapshot", false)) and not bool(suit_156.get_meta("hand_danger_snapshot", true)), "手牌装饰复用一次活动与危险状态快照")
	scene.pending_danger_discard_tile = "1W"
	scene.pending_danger_discard_index = 0
	check(scene.has_pending_danger_discard() and not bool(momentum_156.get_meta("hand_danger_snapshot", true)) and not bool(suit_156.get_meta("hand_danger_snapshot", true)), "后续危险状态变化不改写已绘制装饰快照")
	tray_root_156.queue_free()
	scene.root_layer = null

	print("--- BT) self-gang wall snapshot reuse ---")
	scene.current_seat = 1
	scene.players[1]["hand"] = ["5W", "5W", "5W", "5W", "1W", "4W", "7W", "2T", "5T", "8T", "E", "S", "W", "N"]
	scene.wall.clear()
	for _i in range(50):
		scene.wall.append("1B")
	var gang_visible_157: Array = scene.visible_tile_counts_shared()
	var gang_context_157: Dictionary = scene.make_ai_evaluation_context(1, gang_visible_157)
	gang_context_157["hand_counts"] = scene.tile_counts(scene.players[1]["hand"])
	gang_context_157["self_gang_attack_multiplier"] = scene.ai_total_attack_multiplier(1)
	gang_context_157["self_gang_gang_aggression"] = scene.ai_gang_aggression(1)
	gang_context_157["self_gang_wait_focus"] = scene.ai_wait_value_focus(1)
	gang_context_157["self_gang_difficulty"] = scene.AI_DIFFICULTY_NORMAL
	gang_context_157["pressure_context"] = scene.ai_pressure_context(1, gang_context_157)
	var gang_report_live_157: Dictionary = scene.build_ai_self_gang_report(1, "5W", "concealed", gang_context_157)
	var gang_context_snapshot_157: Dictionary = gang_context_157.duplicate(true)
	gang_context_snapshot_157["discard_report_wall_count"] = 8
	var gang_report_snapshot_157: Dictionary = scene.build_ai_self_gang_report(1, "5W", "concealed", gang_context_snapshot_157)
	check(int(gang_report_live_157.get("wall_draw_wall_count", -1)) == 50 and int(gang_report_snapshot_157.get("wall_draw_wall_count", -1)) == 8, "暗杠候选沿上下文复用牌墙快照")
	var expected_gang_discipline_157: Dictionary = scene.wall_draw_self_gang_discipline_report(1, "concealed", int(gang_report_snapshot_157.get("before_shanten", 8)), int(gang_report_snapshot_157.get("after_shanten", 8)), 8)
	check(bool(gang_report_snapshot_157.get("declined_by_wall_draw", false)) == bool(expected_gang_discipline_157.get("decline", false)) and is_equal_approx(float(gang_report_snapshot_157.get("wall_draw_gang_penalty", 0.0)), float(expected_gang_discipline_157.get("penalty", 0.0))), "暗杠残墙拒绝结果保持显式快照语义")

	print("--- BU) meld danger-state snapshot reuse ---")
	scene.current_seat = 0
	scene.players[0]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "2T", "3T", "5B", "E"]
	scene.players[0]["melds"] = [["1W", "2W", "3W"]]
	scene.pending_danger_discard_tile = "1W"
	scene.pending_danger_discard_index = 0
	var meld_danger_root_158 := Control.new()
	meld_danger_root_158.size = Vector2(1280.0, 720.0)
	root.add_child(meld_danger_root_158)
	scene.root_layer = meld_danger_root_158
	scene.draw_melds(meld_danger_root_158)
	var danger_area_158 := meld_danger_root_158.get_node_or_null("MeldArea_0") as Control
	check(danger_area_158 != null and bool(danger_area_158.get_meta("danger_compact_snapshot", false)) and bool(danger_area_158.get_meta("compact_melds_snapshot", false)), "副露重绘发布一次危险紧凑布局快照")
	scene.pending_danger_discard_tile = ""
	scene.pending_danger_discard_index = -1
	var meld_normal_root_158 := Control.new()
	meld_normal_root_158.size = Vector2(1280.0, 720.0)
	root.add_child(meld_normal_root_158)
	scene.root_layer = meld_normal_root_158
	scene.draw_melds(meld_normal_root_158)
	var normal_area_158 := meld_normal_root_158.get_node_or_null("MeldArea_0") as Control
	check(normal_area_158 != null and not bool(normal_area_158.get_meta("danger_compact_snapshot", true)), "副露重绘在状态变化后重新获取实时快照")
	meld_danger_root_158.queue_free()
	meld_normal_root_158.queue_free()
	scene.root_layer = null

	print("--- BV) chat occupancy geometry snapshot reuse ---")
	scene.players[0]["melds"] = []
	scene.players[1]["melds"] = []
	scene.players[2]["melds"] = []
	scene.players[3]["melds"] = []
	var occupancy_snapshot_159: Dictionary = scene.chat_panel_occupancy_snapshot()
	check(occupancy_snapshot_159.has("occupied") and occupancy_snapshot_159.has("ledger_geometry") and occupancy_snapshot_159.has("visible_meld_seats"), "聊天布局发布完整占用几何快照")
	check(int(occupancy_snapshot_159.get("action_bar_button_count", -1)) == scene.action_bar_button_count(), "聊天占用快照复用行动按钮数量")
	var occupancy_candidate_159 := Rect2(Vector2(0.135, 0.240), Vector2(0.205, 0.510))
	var occupancy_live_score_159: float = scene.chat_panel_candidate_overlap_score(occupancy_candidate_159)
	var occupancy_snapshot_score_159: float = scene.chat_panel_candidate_overlap_score(occupancy_candidate_159, occupancy_snapshot_159)
	check((occupancy_live_score_159 == INF and occupancy_snapshot_score_159 == INF) or is_equal_approx(occupancy_live_score_159, occupancy_snapshot_score_159), "占用几何快照保持候选排除结果")
	scene.players[3]["melds"] = [["5W", "5W", "5W"]]
	var occupancy_reused_score_159: float = scene.chat_panel_candidate_overlap_score(occupancy_candidate_159, occupancy_snapshot_159)
	var occupancy_changed_live_score_159: float = scene.chat_panel_candidate_overlap_score(occupancy_candidate_159)
	check(is_equal_approx(occupancy_snapshot_score_159, occupancy_reused_score_159), "显式占用快照不会被后续副露变化改写")
	check(occupancy_changed_live_score_159 == INF and occupancy_changed_live_score_159 != occupancy_reused_score_159, "候选评分保留实时副露回退路径")
	check(scene.chat_panel_rect().size.x > 0.0 and scene.chat_panel_rect().size.y > 0.0, "聊天抽屉仍能选出有效候选区域")

	print("--- BW) pending claim occupancy geometry snapshot reuse ---")
	var content_size_160: Vector2 = scene.safe_content_pixel_size()
	var table_outer_160: Rect2 = scene.table_outer_rect_for_viewport()
	var outer_width_160 := maxf(0.001, table_outer_160.size.x - table_outer_160.position.x)
	var outer_height_160 := maxf(0.001, table_outer_160.size.y - table_outer_160.position.y)
	var table_left_160: float = float(table_outer_160.position.x + scene.TABLE_INNER_RECT.position.x * outer_width_160)
	var table_top_160: float = float(table_outer_160.position.y + scene.TABLE_INNER_RECT.position.y * outer_height_160)
	var table_width_160: float = float(outer_width_160 * maxf(0.001, scene.TABLE_INNER_RECT.size.x - scene.TABLE_INNER_RECT.position.x))
	var table_height_160: float = float(outer_height_160 * maxf(0.001, scene.TABLE_INNER_RECT.size.y - scene.TABLE_INNER_RECT.position.y))
	var pending_occupancy_snapshot_160: Array = scene.pending_claim_context_occupancy_snapshot(table_left_160, table_top_160, table_width_160, table_height_160, content_size_160)
	check(pending_occupancy_snapshot_160.size() > 0, "响应上下文发布有界占用几何快照")
	var pending_candidates_160: Array[Rect2] = [
		Rect2(Vector2(0.015, 0.108), Vector2(0.280, 0.220)),
		Rect2(Vector2(0.110, 0.300), Vector2(0.320, 0.390)),
		Rect2(Vector2(0.350, 0.300), Vector2(0.500, 0.390)),
	]
	for pending_candidate_160 in pending_candidates_160:
		var live_clear_160: bool = scene.pending_claim_context_candidate_is_clear(pending_candidate_160, table_left_160, table_top_160, table_width_160, table_height_160)
		var snapshot_clear_160: bool = scene.pending_claim_context_candidate_is_clear(pending_candidate_160, table_left_160, table_top_160, table_width_160, table_height_160, pending_occupancy_snapshot_160)
		check(live_clear_160 == snapshot_clear_160, "响应占用快照保持候选清除结果")
	check(scene.pending_claim_context_layout_rect(content_size_160).size.x > 0.0 and scene.pending_claim_context_layout_rect(content_size_160).size.y > 0.0, "响应上下文仍选出有界通道")

	print("--- BX) advisor occupancy geometry snapshot reuse ---")
	var advisor_occupancy_snapshot_161: Array = scene.advisor_panel_occupancy_snapshot()
	check(advisor_occupancy_snapshot_161.size() > 0, "牌势面板发布有界占用几何快照")
	var advisor_candidates_161: Array[Rect2] = [
		Rect2(Vector2(0.015, 0.115), Vector2(0.350, 0.305)),
		Rect2(Vector2(0.650, 0.115), Vector2(0.985, 0.305)),
		Rect2(Vector2(0.015, 0.535), Vector2(0.350, 0.705)),
		Rect2(Vector2(0.650, 0.535), Vector2(0.985, 0.705)),
	]
	for advisor_candidate_161 in advisor_candidates_161:
		var advisor_live_clear_161: bool = scene.advisor_panel_candidate_is_clear(advisor_candidate_161)
		var advisor_snapshot_clear_161: bool = scene.advisor_panel_candidate_is_clear(advisor_candidate_161, advisor_occupancy_snapshot_161)
		check(advisor_live_clear_161 == advisor_snapshot_clear_161, "牌势占用快照保持候选清除结果")
	check(scene.advisor_panel_layout_rect().size.x > 0.0 and scene.advisor_panel_layout_rect().size.y > 0.0, "牌势面板仍选出有界通道")

	print("--- BY) table-log viewport snapshot reuse ---")
	var compact_log_signature_162: String = scene.table_log_render_signature(Vector2(640.0, 400.0))
	var wide_log_signature_162: String = scene.table_log_render_signature(Vector2(1280.0, 720.0))
	check(compact_log_signature_162.contains("(640.0, 400.0)") and wide_log_signature_162.contains("(1280.0, 720.0)"), "牌桌记录签名接受显式牌桌 viewport 快照")
	check(compact_log_signature_162 != wide_log_signature_162 and compact_log_signature_162.contains("|1|"), "牌桌记录快照保持紧凑布局签名状态")
	var log_snapshot_root_162 := Control.new()
	log_snapshot_root_162.size = Vector2(1280.0, 720.0)
	root.add_child(log_snapshot_root_162)
	scene.root_layer = log_snapshot_root_162
	var saved_logs_162: Array[String] = scene.table_logs.duplicate()
	var saved_archive_open_162: bool = scene.table_log_archive_open
	var test_table_logs_162: Array[String] = ["event-one", "event-two", "event-three"]
	scene.table_logs = test_table_logs_162
	scene.table_log_archive_open = false
	scene.draw_table_log(log_snapshot_root_162)
	var ledger_snapshot_162 := log_snapshot_root_162.get_node_or_null("TableLogLedgerPanel") as Control
	var live_log_viewport_162: Vector2 = scene.effective_viewport_size()
	check(ledger_snapshot_162 != null and ledger_snapshot_162.get_meta("table_log_viewport_snapshot", Vector2.ZERO) == live_log_viewport_162, "牌桌记录 ledger 发布本次绘制的 viewport 快照")
	check(ledger_snapshot_162 != null and str(ledger_snapshot_162.get_meta("table_log_viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "牌桌记录 ledger 声明每次绘制只取一次 viewport")
	scene.table_log_archive_open = true
	var archive_snapshot_root_162 := Control.new()
	archive_snapshot_root_162.size = Vector2(1280.0, 720.0)
	root.add_child(archive_snapshot_root_162)
	scene.draw_table_log_archive_panel(archive_snapshot_root_162)
	var archive_snapshot_162 := archive_snapshot_root_162.get_node_or_null("TableLogArchivePanel") as Control
	check(archive_snapshot_162 != null and archive_snapshot_162.get_meta("table_log_viewport_snapshot", Vector2.ZERO) == live_log_viewport_162, "牌桌历史面板发布本次绘制的 viewport 快照")
	check(archive_snapshot_162 != null and str(archive_snapshot_162.get_meta("table_log_viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "牌桌历史面板的所有行复用同一 viewport 快照")
	scene.table_logs = saved_logs_162
	scene.table_log_archive_open = saved_archive_open_162
	log_snapshot_root_162.queue_free()
	archive_snapshot_root_162.queue_free()
	scene.root_layer = null

	print("--- BZ) action pending-state snapshot reuse ---")
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.ai_assist_enabled = false
	scene.current_seat = 0
	var action_snapshot_root_163 := Control.new()
	action_snapshot_root_163.size = Vector2(1280.0, 720.0)
	root.add_child(action_snapshot_root_163)
	scene.root_layer = action_snapshot_root_163
	scene.draw_actions(action_snapshot_root_163)
	var action_bar_snapshot_163 := scene.action_bar as Control
	check(action_bar_snapshot_163 != null and not bool(action_bar_snapshot_163.get_meta("pending_claim_window_snapshot", true)), "行动栏发布普通路径的响应状态快照")
	check(action_bar_snapshot_163 != null and not bool(action_bar_snapshot_163.get_meta("pending_danger_discard_snapshot", true)), "行动栏发布普通路径的危险弃牌快照")
	scene.offline_phase = "pending_claim"
	var pending_claim_snapshot_163: Dictionary = {"from_seat": 1, "tile": "5W", "options": ["peng"], "chi_choices": [], "snapshot_token": 163}
	scene.offline_pending_claim = pending_claim_snapshot_163
	check(action_bar_snapshot_163 != null and not bool(action_bar_snapshot_163.get_meta("pending_claim_window_snapshot", true)) and not bool(action_bar_snapshot_163.get_meta("pending_danger_discard_snapshot", true)), "后续牌局状态变化不会改写已完成的行动状态快照")
	action_snapshot_root_163.queue_free()
	scene.root_layer = null

	print("--- CA) center wind compass current-seat snapshot reuse ---")
	scene.mode = "offline"
	scene.current_seat = 2
	var compass_snapshot_root_164 := Control.new()
	compass_snapshot_root_164.size = Vector2(1280.0, 720.0)
	root.add_child(compass_snapshot_root_164)
	scene.root_layer = compass_snapshot_root_164
	var compass_snapshot_164 := scene.draw_center_wind_compass(compass_snapshot_root_164) as Control
	var active_compass_badge_164 := compass_snapshot_164.get_node_or_null("CenterWindCompass_西") as Control if compass_snapshot_164 != null else null
	check(compass_snapshot_164 != null and int(compass_snapshot_164.get_meta("current_seat_snapshot", -1)) == 2, "中心风位罗盘发布当前座位快照")
	check(compass_snapshot_164 != null and str(compass_snapshot_164.get_meta("current_seat_snapshot_policy", "")) == "one_current_seat_snapshot_per_draw", "中心风位罗盘声明每次绘制只读取一次当前座位")
	check(compass_snapshot_164 != null and compass_snapshot_164.get_node_or_null("CenterWindSimpleMark_西") != null and active_compass_badge_164 != null and str(active_compass_badge_164.get_meta("wind_state", "")) == "current", "罗盘的简化和完整标记复用同一座位快照")
	scene.current_seat = 0
	check(compass_snapshot_164 != null and int(compass_snapshot_164.get_meta("current_seat_snapshot", -1)) == 2 and str(active_compass_badge_164.get_meta("wind_state", "")) == "current", "后续状态变化不会改写已完成的罗盘快照")
	compass_snapshot_root_164.queue_free()
	scene.root_layer = null

	print("--- CB) score strip current-seat snapshot reuse ---")
	scene.mode = "offline"
	scene.current_seat = 1
	var score_strip_snapshot_root_165 := Control.new()
	score_strip_snapshot_root_165.size = Vector2(1280.0, 720.0)
	root.add_child(score_strip_snapshot_root_165)
	scene.root_layer = score_strip_snapshot_root_165
	scene.draw_score_strip(score_strip_snapshot_root_165, Rect2(0.0, 0.0, 1.0, 1.0))
	var score_strip_snapshot_165 := score_strip_snapshot_root_165.get_node_or_null("ScoreStrip") as Control
	var active_score_chip_165 := score_strip_snapshot_165.get_node_or_null("ScoreStripChip_1") as Control if score_strip_snapshot_165 != null else null
	var inactive_score_chip_165 := score_strip_snapshot_165.get_node_or_null("ScoreStripChip_0") as Control if score_strip_snapshot_165 != null else null
	check(score_strip_snapshot_165 != null and int(score_strip_snapshot_165.get_meta("current_seat_snapshot", -1)) == 1, "分数条发布当前座位快照")
	check(score_strip_snapshot_165 != null and str(score_strip_snapshot_165.get_meta("current_seat_snapshot_policy", "")) == "one_current_seat_snapshot_per_draw", "分数条声明每次绘制只读取一次当前座位")
	check(active_score_chip_165 != null and bool(active_score_chip_165.get_meta("active_snapshot", false)) and inactive_score_chip_165 != null and not bool(inactive_score_chip_165.get_meta("active_snapshot", true)), "分数 chip 复用同一活动座位快照")
	scene.current_seat = 3
	check(score_strip_snapshot_165 != null and int(score_strip_snapshot_165.get_meta("current_seat_snapshot", -1)) == 1 and bool(active_score_chip_165.get_meta("active_snapshot", false)), "后续状态变化不会改写已完成的分数条快照")
	score_strip_snapshot_root_165.queue_free()
	scene.root_layer = null

	print("--- CC) score-strip delta text snapshot reuse ---")
	scene.mode = "offline"
	scene.current_seat = 0
	scene.last_score_deltas.clear()
	for delta_166 in [100, -200, 0, 0]:
		scene.last_score_deltas.append(delta_166)
	var score_delta_snapshot_root_166 := Control.new()
	score_delta_snapshot_root_166.size = Vector2(1280.0, 720.0)
	root.add_child(score_delta_snapshot_root_166)
	scene.root_layer = score_delta_snapshot_root_166
	scene.draw_score_strip(score_delta_snapshot_root_166, Rect2(0.0, 0.0, 1.0, 1.0))
	var score_delta_snapshot_166 := score_delta_snapshot_root_166.get_node_or_null("ScoreStrip/ScoreStripChip_1/ScoreStripDelta_1") as Label
	check(score_delta_snapshot_166 != null and score_delta_snapshot_166.text == "变化 -200", "分数变化标签保持原有显示文本")
	check(score_delta_snapshot_166 != null and score_delta_snapshot_166.tooltip_text == "分数变化： -200" and str(score_delta_snapshot_166.get_meta("score_delta_text_snapshot", "")) == " -200", "分数变化 tooltip 复用已捕获的文本")
	check(score_delta_snapshot_166 != null and str(score_delta_snapshot_166.get_meta("score_delta_text_snapshot_policy", "")) == "one_score_delta_snapshot_per_chip", "分数变化标签声明每个 chip 只解析一次文本")
	scene.last_score_deltas[1] = 8000
	check(score_delta_snapshot_166 != null and score_delta_snapshot_166.text == "变化 -200" and score_delta_snapshot_166.tooltip_text == "分数变化： -200", "后续分数变化不会改写已完成的 chip 文本快照")
	score_delta_snapshot_root_166.queue_free()
	scene.root_layer = null

	print("--- CD) score-strip viewport snapshot reuse ---")
	scene.mode = "offline"
	scene.current_seat = 0
	var score_strip_viewport_root_167 := Control.new()
	score_strip_viewport_root_167.size = Vector2(1280.0, 720.0)
	root.add_child(score_strip_viewport_root_167)
	scene.root_layer = score_strip_viewport_root_167
	var expected_score_strip_viewport_167: Vector2 = scene.effective_viewport_size()
	scene.draw_score_strip(score_strip_viewport_root_167, Rect2(0.0, 0.0, 1.0, 1.0))
	var score_strip_viewport_snapshot_167 := score_strip_viewport_root_167.get_node_or_null("ScoreStrip") as Control
	check(score_strip_viewport_snapshot_167 != null and score_strip_viewport_snapshot_167.get_meta("viewport_snapshot", Vector2.ZERO) == expected_score_strip_viewport_167, "分数条发布本次绘制的 viewport 快照")
	check(score_strip_viewport_snapshot_167 != null and str(score_strip_viewport_snapshot_167.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "分数条声明每次绘制只读取一次 viewport")
	scene.current_seat = 2
	check(score_strip_viewport_snapshot_167 != null and score_strip_viewport_snapshot_167.get_meta("viewport_snapshot", Vector2.ZERO) == expected_score_strip_viewport_167, "后续状态变化不会改写已完成的 viewport 快照")
	score_strip_viewport_root_167.queue_free()
	scene.root_layer = null

	print("--- CE) center wind label content-size snapshot reuse ---")
	scene.mode = "offline"
	scene.current_seat = 0
	scene.wall.clear()
	for wall_tile_168 in range(60):
		scene.wall.append("1B")
	var center_content_snapshot_root_168 := Control.new()
	center_content_snapshot_root_168.size = Vector2(1280.0, 720.0)
	root.add_child(center_content_snapshot_root_168)
	scene.root_layer = center_content_snapshot_root_168
	var expected_center_content_size_168: Vector2 = scene.safe_content_pixel_size()
	scene.draw_center(center_content_snapshot_root_168)
	var center_content_snapshot_168 := center_content_snapshot_root_168.get_node_or_null("CenterConsole3DShell") as Control
	check(center_content_snapshot_168 != null and center_content_snapshot_168.get_meta("wind_label_content_size_snapshot", Vector2.ZERO) == expected_center_content_size_168, "中心面板发布风位标签使用的 content-size 快照")
	check(center_content_snapshot_168 != null and str(center_content_snapshot_168.get_meta("wind_label_content_size_snapshot_policy", "")) == "one_content_size_snapshot_per_wind_label_pass", "中心面板声明风位标签循环只读取一次 content-size")
	scene.current_seat = 2
	check(center_content_snapshot_168 != null and center_content_snapshot_168.get_meta("wind_label_content_size_snapshot", Vector2.ZERO) == expected_center_content_size_168, "后续状态变化不会改写已完成的风位尺寸快照")
	center_content_snapshot_root_168.queue_free()
	scene.root_layer = null

	print("--- CF) center draw content-size snapshot reuse ---")
	scene.mode = "offline"
	scene.current_seat = 0
	scene.last_discard = "5W"
	scene.last_discard_seat = 1
	scene.wall.clear()
	for wall_tile_169 in range(60):
		scene.wall.append("1B")
	var center_draw_snapshot_root_169 := Control.new()
	center_draw_snapshot_root_169.size = Vector2(1280.0, 720.0)
	root.add_child(center_draw_snapshot_root_169)
	scene.root_layer = center_draw_snapshot_root_169
	var expected_center_draw_content_size_169: Vector2 = scene.safe_content_pixel_size()
	scene.draw_center(center_draw_snapshot_root_169)
	var center_draw_snapshot_169 := center_draw_snapshot_root_169.get_node_or_null("CenterConsole3DShell") as Control
	check(center_draw_snapshot_169 != null and center_draw_snapshot_169.get_meta("center_draw_content_size_snapshot", Vector2.ZERO) == expected_center_draw_content_size_169, "中心绘制发布跨数据通道的 content-size 快照")
	check(center_draw_snapshot_169 != null and str(center_draw_snapshot_169.get_meta("center_draw_content_size_snapshot_policy", "")) == "one_content_size_snapshot_per_center_draw", "中心绘制声明每次只读取一次 content-size")
	check(center_draw_snapshot_169 != null and center_draw_snapshot_169.get_meta("wind_label_content_size_snapshot", Vector2.ZERO) == expected_center_draw_content_size_169 and center_draw_snapshot_root_169.get_node_or_null("CenterConsole3DShell/CenterLastDiscardLabel") != null, "最后弃牌和风位标签复用同一 content-size 快照")
	scene.current_seat = 2
	check(center_draw_snapshot_169 != null and center_draw_snapshot_169.get_meta("center_draw_content_size_snapshot", Vector2.ZERO) == expected_center_draw_content_size_169, "后续状态变化不会改写已完成的中心尺寸快照")
	center_draw_snapshot_root_169.queue_free()
	scene.root_layer = null

	print("--- CG) pending-claim illustration viewport snapshot reuse ---")
	scene.mode = "offline"
	scene.offline_phase = "pending_claim"
	scene.current_seat = 0
	scene.offline_pending_claim = {"from_seat": 1, "tile": "5W", "options": ["peng"], "chi_choices": [], "snapshot_token": 170}
	var pending_viewport_snapshot_root_170 := Control.new()
	pending_viewport_snapshot_root_170.size = Vector2(1280.0, 720.0)
	root.add_child(pending_viewport_snapshot_root_170)
	scene.root_layer = pending_viewport_snapshot_root_170
	var expected_pending_viewport_170: Vector2 = scene.effective_viewport_size()
	scene.draw_pending_claim_illustration(pending_viewport_snapshot_root_170)
	var pending_viewport_snapshot_170 := pending_viewport_snapshot_root_170.get_node_or_null("PendingClaimIllustration") as Control
	check(pending_viewport_snapshot_170 != null and pending_viewport_snapshot_170.get_meta("viewport_snapshot", Vector2.ZERO) == expected_pending_viewport_170, "待响应插画发布本次绘制的 viewport 快照")
	check(pending_viewport_snapshot_170 != null and str(pending_viewport_snapshot_170.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "待响应插画声明每次绘制只读取一次 viewport")
	scene.current_seat = 2
	check(pending_viewport_snapshot_170 != null and pending_viewport_snapshot_170.get_meta("viewport_snapshot", Vector2.ZERO) == expected_pending_viewport_170, "后续状态变化不会改写已完成的待响应 viewport 快照")
	pending_viewport_snapshot_root_170.queue_free()
	scene.root_layer = null

	print("--- CH) action dock pending-state snapshot reuse ---")
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.offline_pending_claim.clear()
	var action_snapshot_root_171 := Control.new()
	action_snapshot_root_171.name = "ActionDockStateSnapshotRoot"
	action_snapshot_root_171.size = Vector2(1280.0, 720.0)
	root.add_child(action_snapshot_root_171)
	scene.root_layer = action_snapshot_root_171
	var action_snapshot_bar_171 := HBoxContainer.new()
	action_snapshot_bar_171.name = "ActionDockSnapshotBar"
	action_snapshot_bar_171.size = Vector2(520.0, 64.0)
	action_snapshot_bar_171.position = Vector2(700.0, 620.0)
	action_snapshot_root_171.add_child(action_snapshot_bar_171)
	var action_snapshot_button_171 := Button.new()
	action_snapshot_button_171.name = "ActionDockSnapshotButton"
	action_snapshot_button_171.text = "出牌"
	action_snapshot_bar_171.add_child(action_snapshot_button_171)
	scene.action_bar = action_snapshot_bar_171
	var action_buttons_171: Array[Button] = scene.action_bar_buttons()
	var live_action_signature_171: String = scene.battle_action_chrome_identity_signature(action_buttons_171)
	var live_action_dock_buttons_171: Array[Button] = scene.draw_action_dock(action_snapshot_root_171)
	var live_action_dock_171 := action_snapshot_root_171.get_node_or_null("ActionButtonDock") as Control
	check(live_action_dock_buttons_171.size() == 1 and live_action_dock_171 != null and not bool(live_action_dock_171.get_meta("pending_claim_window_snapshot", true)) and not bool(live_action_dock_171.get_meta("pending_danger_discard_snapshot", true)), "action dock keeps its direct live fallback")
	check(live_action_dock_171 != null and str(live_action_dock_171.get_meta("action_state_snapshot_policy", "")) == "one_action_state_snapshot_per_dock", "action dock publishes one pending-state snapshot policy")
	var explicit_action_dock_root_171 := Control.new()
	explicit_action_dock_root_171.name = "ExplicitActionDockStateSnapshotRoot"
	explicit_action_dock_root_171.size = Vector2(1280.0, 720.0)
	root.add_child(explicit_action_dock_root_171)
	scene.root_layer = explicit_action_dock_root_171
	var explicit_action_bar_171 := HBoxContainer.new()
	explicit_action_bar_171.name = "ExplicitActionDockSnapshotBar"
	explicit_action_bar_171.size = Vector2(520.0, 64.0)
	explicit_action_bar_171.position = Vector2(700.0, 620.0)
	explicit_action_dock_root_171.add_child(explicit_action_bar_171)
	var explicit_action_button_171 := Button.new()
	explicit_action_button_171.name = "ExplicitActionDockSnapshotButton"
	explicit_action_button_171.text = "出牌"
	explicit_action_bar_171.add_child(explicit_action_button_171)
	scene.action_bar = explicit_action_bar_171
	var explicit_action_buttons_171: Array[Button] = scene.action_bar_buttons()
	var explicit_action_signature_171: String = scene.battle_action_chrome_identity_signature(explicit_action_buttons_171, 1, 1)
	var explicit_action_dock_buttons_171: Array[Button] = scene.draw_action_dock(explicit_action_dock_root_171, false, 1, 1)
	var explicit_action_dock_171 := explicit_action_dock_root_171.get_node_or_null("ActionButtonDock") as Control
	check(explicit_action_dock_buttons_171.size() == 1 and explicit_action_dock_171 != null and bool(explicit_action_dock_171.get_meta("pending_claim_window_snapshot", false)) and bool(explicit_action_dock_171.get_meta("pending_danger_discard_snapshot", false)), "action dock consumes explicit pending-state snapshots")
	check(explicit_action_signature_171 != live_action_signature_171, "action chrome identity consumes explicit pending-state snapshots")
	scene.offline_phase = "pending_claim"
	scene.offline_pending_claim = {"from_seat": 1, "tile": "5W", "options": ["peng"], "chi_choices": [], "snapshot_token": 171}
	check(explicit_action_dock_171 != null and bool(explicit_action_dock_171.get_meta("pending_claim_window_snapshot", false)) and bool(explicit_action_dock_171.get_meta("pending_danger_discard_snapshot", false)), "later state changes do not rewrite the completed action dock snapshot")
	action_snapshot_root_171.queue_free()
	explicit_action_dock_root_171.queue_free()
	scene.root_layer = null

	print("--- CI) daily-login viewport snapshot reuse ---")
	scene.mode = "daily_login"
	scene.large_text_enabled = false
	var expected_daily_login_viewport_172: Vector2 = scene.effective_viewport_size()
	scene.show_daily_login_panel({"consecutive_days": 5, "claimed_today": false})
	var daily_login_panel_172 := scene.root_layer.get_node_or_null("DailyLoginPanel") as Control
	var daily_login_indicators_172 := daily_login_panel_172.get_node_or_null("DailyLoginDayIndicators") as Control if daily_login_panel_172 != null else null
	check(daily_login_panel_172 != null and daily_login_panel_172.get_meta("viewport_snapshot", Vector2.ZERO) == expected_daily_login_viewport_172, "每日签到面板发布本次绘制的 viewport 快照")
	check(daily_login_panel_172 != null and str(daily_login_panel_172.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "每日签到面板声明每次绘制只读取一次 viewport")
	check(daily_login_indicators_172 != null and daily_login_indicators_172.get_child_count() == 7, "七个签到日节点仍完整构建")
	scene.large_text_enabled = true
	scene.mode = "menu"
	check(daily_login_panel_172 != null and daily_login_panel_172.get_meta("viewport_snapshot", Vector2.ZERO) == expected_daily_login_viewport_172, "后续布局状态变化不会改写已完成的签到 viewport 快照")

	scene.clear_screen()
	scene.root_layer = null

	print("--- CJ) shop viewport/content-size snapshot reuse ---")
	scene.mode = "shop"
	scene.currency = {"coins": 1200, "gems": 80}
	var expected_shop_viewport_173: Vector2 = scene.effective_viewport_size()
	var expected_shop_content_size_173: Vector2 = scene.safe_content_pixel_size()
	scene.show_shop_screen(true)
	var shop_panel_173 := scene.root_layer.get_node_or_null("ShopCabinetFrontPanel") as Control
	var shop_content_173 := shop_panel_173.get_node_or_null("ShopItemsScroll/ShopItemsContent") as Control if shop_panel_173 != null else null
	var shop_name_label_173 := shop_panel_173.find_child("ShopItemName_swap_card", true, false) as Label if shop_panel_173 != null else null
	check(shop_panel_173 != null and shop_panel_173.get_meta("viewport_snapshot", Vector2.ZERO) == expected_shop_viewport_173, "商店面板发布本次绘制的 viewport 快照")
	check(shop_panel_173 != null and str(shop_panel_173.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "商店面板声明每次绘制只读取一次 viewport")
	check(shop_panel_173 != null and shop_panel_173.get_meta("content_size_snapshot", Vector2.ZERO) == expected_shop_content_size_173, "商店面板发布本次绘制的 content-size 快照")
	check(shop_panel_173 != null and str(shop_panel_173.get_meta("content_size_snapshot_policy", "")) == "one_content_size_snapshot_per_draw", "商店面板声明每次绘制只读取一次 content-size")
	check(shop_content_173 != null and shop_content_173.find_child("ShopItemRow_swap_card", true, false) != null and shop_content_173.find_child("ShopItemsBottomSpacer", true, false) != null, "商品行和底部间距仍完整构建")
	check(shop_name_label_173 != null and shop_name_label_173.get_meta("shop_name_width_px", 0.0) == maxf(120.0, expected_shop_content_size_173.x * 0.300), "商品名称仍使用原有的 content-size 宽度预算")
	scene.currency["gems"] = 0
	scene.mode = "menu"
	check(shop_panel_173 != null and shop_panel_173.get_meta("viewport_snapshot", Vector2.ZERO) == expected_shop_viewport_173 and shop_panel_173.get_meta("content_size_snapshot", Vector2.ZERO) == expected_shop_content_size_173, "后续状态变化不会改写已完成的商店快照")
	scene.clear_screen()
	scene.root_layer = null

	print("--- CK) loading viewport snapshot reuse ---")
	scene.mode = "menu"
	var expected_loading_viewport_174: Vector2 = scene.effective_viewport_size()
	scene.show_loading_screen({"status": "正在加载中", "progress_ratio": 0.5, "tip": "提示：保持手牌灵活性，避免过早定型"})
	var loading_panel_174 := scene.root_layer.get_node_or_null("LoadingPanel") as Control
	var loading_center_174 := loading_panel_174.get_node_or_null("LoadingCenterPanel") as Control if loading_panel_174 != null else null
	var loading_title_174 := loading_panel_174.find_child("LoadingTitleLabel", true, false) as Label if loading_panel_174 != null else null
	var loading_status_174 := loading_panel_174.find_child("LoadingStatusLabel", true, false) as Label if loading_panel_174 != null else null
	var loading_tip_174 := loading_panel_174.find_child("LoadingTipLabel", true, false) as Label if loading_panel_174 != null else null
	check(loading_panel_174 != null and loading_panel_174.get_meta("viewport_snapshot", Vector2.ZERO) == expected_loading_viewport_174, "加载面板发布本次绘制的 viewport 快照")
	check(loading_panel_174 != null and str(loading_panel_174.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "加载面板声明每次绘制只读取一次 viewport")
	check(loading_center_174 != null and loading_title_174 != null and loading_status_174 != null and loading_tip_174 != null, "正常加载页仍完整构建标题、状态和提示文本")
	scene.show_loading_screen({"error": true, "status": "网络超时", "progress_ratio": -1.0, "tip": "提示：注意观察对手弃牌，判断危险牌"})
	var error_panel_174 := scene.root_layer.get_node_or_null("LoadingPanel") as Control
	var error_hint_174 := error_panel_174.find_child("LoadingErrorHint", true, false) as Label if error_panel_174 != null else null
	check(error_panel_174 != null and error_panel_174.get_meta("viewport_snapshot", Vector2.ZERO) == expected_loading_viewport_174, "错误加载页复用同一 viewport 快照语义")
	check(error_hint_174 != null and error_hint_174.visible, "错误加载页仍构建可见恢复提示")
	scene.mode = "menu"
	check(error_panel_174 != null and error_panel_174.get_meta("viewport_snapshot", Vector2.ZERO) == expected_loading_viewport_174, "后续状态变化不会改写已完成的加载 viewport 快照")
	scene.clear_screen()
	scene.root_layer = null

	print("--- CL) online-lobby viewport snapshot reuse ---")
	scene.mode = "menu"
	var expected_online_lobby_viewport_175: Vector2 = scene.effective_viewport_size()
	scene.show_online_lobby(true)
	var online_lobby_panel_175 := scene.root_layer.get_node_or_null("OnlineLobbyLowFrequencyPagePlate") as Control
	var online_lobby_form_175 := online_lobby_panel_175.get_node_or_null("OnlineLobbyFormPanel") as Control if online_lobby_panel_175 != null else null
	var online_lobby_log_scroll_175 := online_lobby_panel_175.find_child("OnlineLobbyLogScroll", true, false) as Control if online_lobby_panel_175 != null else null
	var online_lobby_room_badge_175 := online_lobby_panel_175.find_child("OnlineLobbyRoomBadge", true, false) as Control if online_lobby_panel_175 != null else null
	check(online_lobby_panel_175 != null and online_lobby_panel_175.get_meta("viewport_snapshot", Vector2.ZERO) == expected_online_lobby_viewport_175, "联机大厅面板发布本次绘制的 viewport 快照")
	check(online_lobby_panel_175 != null and str(online_lobby_panel_175.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "联机大厅面板声明每次绘制只读取一次 viewport")
	check(online_lobby_form_175 != null and online_lobby_log_scroll_175 != null and online_lobby_room_badge_175 != null, "联机大厅首次刷新仍完整构建表单、日志和房间摘要")
	scene.online_waiting_for_server = true
	scene.online_feedback = "等待服务器确认"
	scene.refresh_online_lobby_state()
	check(online_lobby_panel_175 != null and online_lobby_panel_175.get_meta("viewport_snapshot", Vector2.ZERO) == expected_online_lobby_viewport_175, "后续联机状态刷新不会改写已完成的大厅 viewport 快照")
	scene.clear_screen()
	scene.root_layer = null

	print("--- CM) stats viewport/content-size snapshot reuse ---")
	scene.mode = "menu"
	var expected_stats_viewport_176: Vector2 = scene.effective_viewport_size()
	var expected_stats_content_size_176: Vector2 = scene.safe_content_pixel_size()
	scene.show_stats_screen(true)
	var stats_panel_176 := scene.root_layer.get_node_or_null("StatsConsoleFrontPanel") as Control
	var stats_rows_176 := stats_panel_176.get_node_or_null("StatsRows") as Control if stats_panel_176 != null else null
	var stats_status_176 := stats_panel_176.get_node_or_null("StatsRowsScrollStatus") as Label if stats_panel_176 != null else null
	check(stats_panel_176 != null and stats_panel_176.get_meta("viewport_snapshot", Vector2.ZERO) == expected_stats_viewport_176, "统计面板发布本次绘制的 viewport 快照")
	check(stats_panel_176 != null and str(stats_panel_176.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "统计面板声明每次绘制只读取一次 viewport")
	check(stats_panel_176 != null and stats_panel_176.get_meta("content_size_snapshot", Vector2.ZERO) == expected_stats_content_size_176, "统计面板发布本次绘制的 content-size 快照")
	check(stats_panel_176 != null and str(stats_panel_176.get_meta("content_size_snapshot_policy", "")) == "one_content_size_snapshot_per_draw", "统计面板声明每次绘制只读取一次 content-size")
	check(stats_rows_176 != null and stats_status_176 != null, "统计页仍完整构建滚动容器和位置状态")
	scene.stats_selected_rule = "local"
	scene.mode = "menu"
	check(stats_panel_176 != null and stats_panel_176.get_meta("viewport_snapshot", Vector2.ZERO) == expected_stats_viewport_176 and stats_panel_176.get_meta("content_size_snapshot", Vector2.ZERO) == expected_stats_content_size_176, "后续状态变化不会改写已完成的统计快照")
	scene.clear_screen()
	scene.root_layer = null

	print("--- CN) achievements viewport snapshot reuse ---")
	scene.mode = "menu"
	scene.large_text_enabled = false
	var expected_achievement_viewport_177: Vector2 = scene.effective_viewport_size()
	scene.show_achievements_screen(true)
	var achievement_panel_177 := scene.root_layer.get_node_or_null("AchievementGalleryFrontPanel") as Control
	var achievement_grid_177 := achievement_panel_177.find_child("AchievementsGrid", true, false) as Control if achievement_panel_177 != null else null
	var achievement_row_177 := achievement_panel_177.find_child("AchievementRow_first_win", true, false) as Control if achievement_panel_177 != null else null
	check(achievement_panel_177 != null and achievement_panel_177.get_meta("viewport_snapshot", Vector2.ZERO) == expected_achievement_viewport_177, "成就面板发布本次绘制的 viewport 快照")
	check(achievement_panel_177 != null and str(achievement_panel_177.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "成就面板声明每次绘制只读取一次 viewport")
	check(achievement_grid_177 != null and achievement_row_177 != null, "成就页仍完整构建列表和成就行")
	check(achievement_row_177 != null and is_equal_approx(float(achievement_row_177.get_meta("row_height_px", -1.0)), scene.achievement_row_height_contract(expected_achievement_viewport_177)), "成就行使用页面 viewport 快照计算行高")
	check(is_equal_approx(scene.achievement_row_height_contract(), scene.achievement_row_height_contract(expected_achievement_viewport_177)), "成就行高契约保留无参实时回退")
	scene.large_text_enabled = true
	scene.mode = "menu"
	check(achievement_panel_177 != null and achievement_panel_177.get_meta("viewport_snapshot", Vector2.ZERO) == expected_achievement_viewport_177, "后续状态变化不会改写已完成的成就 viewport 快照")
	scene.clear_screen()
	scene.root_layer = null

	print("--- CO) achievement-row viewport snapshot reuse ---")
	scene.mode = "menu"
	scene.large_text_enabled = false
	var expected_achievement_row_viewport_178: Vector2 = scene.effective_viewport_size()
	scene.show_achievements_screen(true)
	var achievement_row_panel_178 := scene.root_layer.get_node_or_null("AchievementGalleryFrontPanel") as Control
	var achievement_row_178 := achievement_row_panel_178.find_child("AchievementRow_first_win", true, false) as Control if achievement_row_panel_178 != null else null
	check(achievement_row_178 != null and achievement_row_178.get_meta("viewport_snapshot", Vector2.ZERO) == expected_achievement_row_viewport_178, "成就行发布页面传入的 viewport 快照")
	check(achievement_row_178 != null and str(achievement_row_178.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_row", "成就行声明只读取一次 viewport")
	check(achievement_row_178 != null and is_equal_approx(float(achievement_row_178.get_meta("row_height_px", -1.0)), scene.achievement_row_height_contract(expected_achievement_row_viewport_178)), "成就行高继续使用页面快照")
	var direct_achievement_row_178: Control = scene.make_achievement_row("first_win", 0)
	check(direct_achievement_row_178 != null and direct_achievement_row_178.get_meta("viewport_snapshot", Vector2.ZERO) == expected_achievement_row_viewport_178, "独立成就行调用保留实时 viewport 回退")
	direct_achievement_row_178.queue_free()
	scene.mode = "menu"
	check(achievement_row_178 != null and achievement_row_178.get_meta("viewport_snapshot", Vector2.ZERO) == expected_achievement_row_viewport_178, "后续页面状态不会改写已完成的成就行快照")
	scene.clear_screen()
	scene.root_layer = null

	print("--- CP) rules viewport snapshot reuse ---")
	scene.mode = "menu"
	var expected_rules_viewport_179: Vector2 = scene.effective_viewport_size()
	scene.show_rules_screen(true)
	var rules_panel_179 := scene.root_layer.get_node_or_null("RulesCodexFrontPanel") as Control
	var rules_guide_179 := rules_panel_179.get_node_or_null("RulesGuideArt") as Control if rules_panel_179 != null else null
	var rules_scroll_179 := rules_panel_179.get_node_or_null("RulesContentScroll") as Control if rules_panel_179 != null else null
	var rules_content_179 := rules_panel_179.find_child("RulesContentList", true, false) as Control if rules_panel_179 != null else null
	check(rules_panel_179 != null and rules_panel_179.get_meta("viewport_snapshot", Vector2.ZERO) == expected_rules_viewport_179, "规则面板发布本次绘制的 viewport 快照")
	check(rules_panel_179 != null and str(rules_panel_179.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "规则面板声明每次绘制只读取一次 viewport")
	check(rules_guide_179 != null and rules_guide_179.get_meta("viewport_snapshot", Vector2.ZERO) == expected_rules_viewport_179, "规则导航复用页面 viewport 快照")
	check(rules_guide_179 != null and str(rules_guide_179.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "规则导航声明复用页面 viewport 快照")
	check(rules_scroll_179 != null and rules_content_179 != null, "规则页仍完整构建滚动容器和内容列表")
	var direct_rules_parent_179 := Control.new()
	var direct_rules_guide_179: Control = scene.draw_rules_guide_art(direct_rules_parent_179)
	check(direct_rules_guide_179 != null and direct_rules_guide_179.get_meta("viewport_snapshot", Vector2.ZERO) == expected_rules_viewport_179, "独立规则导航调用保留实时 viewport 回退")
	direct_rules_parent_179.queue_free()
	scene.mode = "menu"
	check(rules_panel_179 != null and rules_panel_179.get_meta("viewport_snapshot", Vector2.ZERO) == expected_rules_viewport_179 and rules_guide_179 != null and rules_guide_179.get_meta("viewport_snapshot", Vector2.ZERO) == expected_rules_viewport_179, "后续页面状态不会改写已完成的规则快照")
	scene.clear_screen()
	scene.root_layer = null

	print("--- CQ) stats summary-chip viewport snapshot reuse ---")
	scene.mode = "menu"
	var expected_stats_chip_viewport_180: Vector2 = scene.effective_viewport_size()
	scene.show_stats_screen(true)
	var stats_chip_panel_180 := scene.root_layer.get_node_or_null("StatsConsoleFrontPanel") as Control
	var stats_dashboard_180 := stats_chip_panel_180.find_child("StatsDashboardArt", true, false) as Control if stats_chip_panel_180 != null else null
	var stats_chip_180 := stats_chip_panel_180.find_child("StatsSummaryChip_winrate", true, false) as Control if stats_chip_panel_180 != null else null
	check(stats_dashboard_180 != null and stats_dashboard_180.get_meta("viewport_snapshot", Vector2.ZERO) == expected_stats_chip_viewport_180, "统计摘要 dashboard 发布页面 viewport 快照")
	check(stats_dashboard_180 != null and str(stats_dashboard_180.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "统计摘要 dashboard 声明只读取一次 viewport")
	check(stats_chip_180 != null and stats_chip_180.get_meta("viewport_snapshot", Vector2.ZERO) == expected_stats_chip_viewport_180, "统计摘要 chip 复用 dashboard viewport 快照")
	check(stats_chip_180 != null and str(stats_chip_180.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_chip", "统计摘要 chip 声明只读取一次 viewport")
	check(stats_chip_panel_180 != null and stats_chip_panel_180.find_child("StatsSummaryChip_games", true, false) != null and stats_chip_panel_180.find_child("StatsSummaryChip_best", true, false) != null, "三个统计摘要 chip 仍完整构建")
	var direct_stats_parent_180 := Control.new()
	var direct_stats_chip_180: Control = scene.make_stats_summary_chip(direct_stats_parent_180, "fallback", "测试", "1局", Rect2(0.0, 0.0, 0.4, 0.4), Color.WHITE)
	check(direct_stats_chip_180 != null and direct_stats_chip_180.get_meta("viewport_snapshot", Vector2.ZERO) == expected_stats_chip_viewport_180, "独立统计 chip 调用保留实时 viewport 回退")
	direct_stats_parent_180.queue_free()
	scene.mode = "menu"
	check(stats_dashboard_180 != null and stats_dashboard_180.get_meta("viewport_snapshot", Vector2.ZERO) == expected_stats_chip_viewport_180 and stats_chip_180 != null and stats_chip_180.get_meta("viewport_snapshot", Vector2.ZERO) == expected_stats_chip_viewport_180, "后续页面状态不会改写已完成的统计摘要快照")
	scene.clear_screen()
	scene.root_layer = null

	print("--- CR) hand viewport snapshot reuse ---")
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.current_seat = 0
	scene.tutorial_step = scene.TUTORIAL_STEP_DISCARD
	scene.show_hand_hint = true
	scene.hand_keyboard_selection = -1
	scene.players[0]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "2T", "3T", "5B", "E", "E"]
	var hand_viewport_root_181 := Control.new()
	hand_viewport_root_181.name = "HandViewportSnapshotRoot"
	hand_viewport_root_181.size = Vector2(1280.0, 720.0)
	root.add_child(hand_viewport_root_181)
	scene.root_layer = hand_viewport_root_181
	var expected_hand_viewport_181: Vector2 = scene.effective_viewport_size()
	scene.draw_hand(hand_viewport_root_181)
	var hand_tray_181 := hand_viewport_root_181.get_node_or_null("HandTray") as Control
	var hand_hint_181 := hand_viewport_root_181.get_node_or_null("HandTray/HandTrayTutorialHint") as Control
	check(hand_tray_181 != null and hand_tray_181.get_meta("viewport_snapshot", Vector2.ZERO) == expected_hand_viewport_181, "手牌托盘发布本次绘制的 viewport 快照")
	check(hand_tray_181 != null and str(hand_tray_181.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "手牌托盘声明每次绘制只读取一次 viewport")
	check(hand_hint_181 != null, "教程状态仍完整构建手牌提示区域")
	scene.offline_phase = "ended"
	check(hand_tray_181 != null and hand_tray_181.get_meta("viewport_snapshot", Vector2.ZERO) == expected_hand_viewport_181, "后续牌局状态不会改写已完成的手牌 viewport 快照")
	hand_viewport_root_181.queue_free()
	scene.clear_screen()
	scene.root_layer = null

	print("--- CS) achievement completion-art viewport snapshot reuse ---")
	scene.mode = "menu"
	scene.achievements = {"first_win": true, "ten_wins": false}
	var completion_art_snapshot_root_182 := Control.new()
	completion_art_snapshot_root_182.name = "AchievementCompletionSnapshotRoot"
	completion_art_snapshot_root_182.size = Vector2(1280.0, 720.0)
	root.add_child(completion_art_snapshot_root_182)
	scene.root_layer = completion_art_snapshot_root_182
	var expected_completion_art_viewport_182: Vector2 = scene.effective_viewport_size()
	var completion_art_182: Control = scene.draw_achievements_completion_convergence_art(completion_art_snapshot_root_182)
	check(completion_art_182 != null and completion_art_182.get_meta("viewport_snapshot", Vector2.ZERO) == expected_completion_art_viewport_182, "成就收集进度发布本次绘制的 viewport 快照")
	check(completion_art_182 != null and str(completion_art_182.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "成就收集进度声明每次绘制只读取一次 viewport")
	check(completion_art_182 != null and completion_art_182.get_node_or_null("AchievementsCompletionRoute/AchievementsCompletionFill") != null and completion_art_182.get_node_or_null("AchievementsCompletionSeal") != null, "收集进度路线和成就印章仍完整构建")
	scene.achievements["first_win"] = false
	check(completion_art_182 != null and completion_art_182.get_meta("viewport_snapshot", Vector2.ZERO) == expected_completion_art_viewport_182, "后续成就状态变化不会改写已完成的 viewport 快照")
	completion_art_snapshot_root_182.queue_free()
	scene.clear_screen()
	scene.root_layer = null

	print("--- CT) settings-overlay viewport snapshot reuse ---")
	scene.mode = "menu"
	scene.settings_panel_open = true
	scene.large_text_enabled = false
	var settings_overlay_snapshot_root_183 := Control.new()
	settings_overlay_snapshot_root_183.name = "SettingsViewportSnapshotRoot"
	settings_overlay_snapshot_root_183.size = Vector2(1280.0, 720.0)
	root.add_child(settings_overlay_snapshot_root_183)
	scene.root_layer = settings_overlay_snapshot_root_183
	var expected_settings_overlay_viewport_183: Vector2 = scene.effective_viewport_size()
	scene.draw_settings_overlay(settings_overlay_snapshot_root_183)
	var settings_overlay_183 := settings_overlay_snapshot_root_183.get_node_or_null("SettingsOverlay") as Control
	var settings_rule_status_183 := settings_overlay_183.find_child("SettingsRuleVariantStatus", true, false) as Label if settings_overlay_183 != null else null
	check(settings_overlay_183 != null and settings_overlay_183.get_meta("viewport_snapshot", Vector2.ZERO) == expected_settings_overlay_viewport_183, "设置蒙层发布本次绘制的 viewport 快照")
	check(settings_overlay_183 != null and str(settings_overlay_183.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "设置蒙层声明每次绘制只读取一次 viewport")
	check(settings_rule_status_183 != null and settings_rule_status_183.text != "", "地方规则状态标签仍完整构建")
	scene.large_text_enabled = true
	check(settings_overlay_183 != null and settings_overlay_183.get_meta("viewport_snapshot", Vector2.ZERO) == expected_settings_overlay_viewport_183, "后续设置状态变化不会改写已完成的 viewport 快照")
	settings_overlay_snapshot_root_183.queue_free()
	scene.clear_screen()
	scene.root_layer = null

	print("--- CU) win-detail viewport snapshot reuse ---")
	scene.mode = "offline"
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	var win_detail_snapshot_root_184 := Control.new()
	win_detail_snapshot_root_184.name = "WinDetailViewportSnapshotRoot"
	win_detail_snapshot_root_184.size = Vector2(1280.0, 720.0)
	root.add_child(win_detail_snapshot_root_184)
	scene.root_layer = win_detail_snapshot_root_184
	var expected_win_detail_viewport_184: Vector2 = scene.effective_viewport_size()
	scene.draw_win_detail_section(win_detail_snapshot_root_184, {"winner": 0, "fan": 2, "points": 100, "reasons": ["立直"], "win_tile": "5W", "self_draw": false})
	var win_detail_panel_184 := win_detail_snapshot_root_184.get_node_or_null("WinDetailPanel") as Control
	var win_detail_showcase_184 := win_detail_panel_184.get_node_or_null("WinDetailShowcase") as Control if win_detail_panel_184 != null else null
	var win_detail_yaku_scroll_184 := win_detail_panel_184.get_node_or_null("WinDetailYakuScroll") as Control if win_detail_panel_184 != null else null
	check(win_detail_panel_184 != null and win_detail_panel_184.get_meta("viewport_snapshot", Vector2.ZERO) == expected_win_detail_viewport_184, "胡牌详情发布本次绘制的 viewport 快照")
	check(win_detail_panel_184 != null and win_detail_showcase_184 != null and win_detail_showcase_184.get_meta("viewport_snapshot", Vector2.ZERO) == expected_win_detail_viewport_184, "胡牌详情 showcase 复用父绘制 viewport 快照")
	check(win_detail_showcase_184 != null and str(win_detail_showcase_184.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "胡牌详情 showcase 声明只读取一次 viewport")
	check(win_detail_yaku_scroll_184 != null, "胡牌详情仍构建番种滚动区域")
	scene.large_text_enabled = true
	check(win_detail_panel_184 != null and win_detail_panel_184.get_meta("viewport_snapshot", Vector2.ZERO) == expected_win_detail_viewport_184 and win_detail_showcase_184 != null and win_detail_showcase_184.get_meta("viewport_snapshot", Vector2.ZERO) == expected_win_detail_viewport_184, "后续结算状态不会改写已完成的 viewport 快照")
	var direct_win_detail_showcase_root_184 := Control.new()
	root.add_child(direct_win_detail_showcase_root_184)
	var direct_win_detail_showcase_184: Control = scene.draw_win_detail_showcase(direct_win_detail_showcase_root_184, "5W", false, 2, 100)
	check(direct_win_detail_showcase_184 != null and direct_win_detail_showcase_184.get_meta("viewport_snapshot", Vector2.ZERO) == expected_win_detail_viewport_184, "独立 showcase 调用保留实时 viewport 回退")
	direct_win_detail_showcase_root_184.queue_free()
	win_detail_snapshot_root_184.queue_free()
	scene.clear_screen()
	scene.root_layer = null

	print("--- CV) menu-card viewport snapshot reuse ---")
	scene.mode = "menu"
	var menu_card_snapshot_root_185 := Control.new()
	menu_card_snapshot_root_185.name = "MenuCardViewportSnapshotRoot"
	menu_card_snapshot_root_185.size = Vector2(1280.0, 720.0)
	root.add_child(menu_card_snapshot_root_185)
	scene.root_layer = menu_card_snapshot_root_185
	var expected_menu_card_viewport_185: Vector2 = scene.effective_viewport_size()
	var menu_card_185: Button = scene.make_menu_card("联机对战\n局域网房间", Color(0.24, 0.42, 0.38), Callable(), "wifi", false)
	menu_card_snapshot_root_185.add_child(menu_card_185)
	var menu_card_title_185 := menu_card_185.get_node_or_null("MenuCardTitleLabel") as Label
	var menu_card_subtitle_185 := menu_card_185.get_node_or_null("MenuCardSubtitleLabel") as Label
	check(menu_card_185 != null and menu_card_185.get_meta("viewport_snapshot", Vector2.ZERO) == expected_menu_card_viewport_185, "菜单卡片发布本次绘制的 viewport 快照")
	check(menu_card_185 != null and str(menu_card_185.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "菜单卡片声明每次绘制只读取一次 viewport")
	check(menu_card_title_185 != null and menu_card_subtitle_185 != null and menu_card_title_185.text == "联机对战" and menu_card_subtitle_185.text == "局域网房间", "菜单卡片标题和副标题仍完整构建")
	scene.large_text_enabled = true
	check(menu_card_185 != null and menu_card_185.get_meta("viewport_snapshot", Vector2.ZERO) == expected_menu_card_viewport_185, "后续菜单状态变化不会改写已完成的 viewport 快照")
	menu_card_snapshot_root_185.queue_free()
	scene.clear_screen()
	scene.root_layer = null

	print("--- CW) menu-card motion viewport snapshot reuse ---")
	var menu_motion_snapshot_root_186 := Control.new()
	menu_motion_snapshot_root_186.name = "MenuMotionViewportSnapshotRoot"
	menu_motion_snapshot_root_186.size = Vector2(1280.0, 720.0)
	root.add_child(menu_motion_snapshot_root_186)
	var menu_motion_button_186 := Button.new()
	menu_motion_button_186.name = "MenuMotionSnapshotButton"
	menu_motion_snapshot_root_186.add_child(menu_motion_button_186)
	var expected_menu_motion_viewport_186 := Vector2(1136.0, 640.0)
	scene.configure_menu_button_motion(menu_motion_button_186, 0.0, 1.0, 0.0, expected_menu_motion_viewport_186)
	check(menu_motion_button_186.get_meta("motion_viewport_snapshot", Vector2.ZERO) == expected_menu_motion_viewport_186, "菜单按钮动画消费显式 viewport 快照")
	check(str(menu_motion_button_186.get_meta("motion_viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "菜单按钮动画声明复用卡片 viewport 快照")
	check(bool(menu_motion_button_186.get_meta("menu_motion_configured", false)), "菜单按钮动画仍完成配置登记")
	menu_motion_snapshot_root_186.queue_free()
	scene.clear_screen()
	scene.root_layer = null

	print("--- CX) setting-row viewport snapshot reuse ---")
	scene.large_text_enabled = false
	var setting_row_snapshot_root_187 := Control.new()
	setting_row_snapshot_root_187.name = "SettingRowViewportSnapshotRoot"
	setting_row_snapshot_root_187.size = Vector2(1280.0, 720.0)
	root.add_child(setting_row_snapshot_root_187)
	scene.root_layer = setting_row_snapshot_root_187
	var expected_setting_row_viewport_187: Vector2 = scene.effective_viewport_size()
	var setting_row_button_187 := Button.new()
	scene.make_setting_row(setting_row_snapshot_root_187, "AI 节奏", "已开启", setting_row_button_187)
	var setting_row_187 := setting_row_snapshot_root_187.get_node_or_null("SettingRow_AI 节奏") as Control
	var setting_row_title_187 := setting_row_187.get_node_or_null("SettingRowTitle_AI 节奏") as Label if setting_row_187 != null else null
	var setting_row_status_187 := setting_row_187.get_node_or_null("SettingRowStatus_AI 节奏") as Label if setting_row_187 != null else null
	check(setting_row_187 != null and setting_row_187.get_meta("viewport_snapshot", Vector2.ZERO) == expected_setting_row_viewport_187, "设置行发布本次绘制的 viewport 快照")
	check(setting_row_187 != null and str(setting_row_187.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "设置行声明每次绘制只读取一次 viewport")
	check(setting_row_title_187 != null and setting_row_status_187 != null and setting_row_title_187.text == "AI 节奏" and setting_row_status_187.text != "", "设置行标题和状态仍完整构建")
	scene.large_text_enabled = true
	check(setting_row_187 != null and setting_row_187.get_meta("viewport_snapshot", Vector2.ZERO) == expected_setting_row_viewport_187, "后续设置排版状态不会改写已完成的 viewport 快照")
	setting_row_snapshot_root_187.queue_free()
	scene.clear_screen()
	scene.root_layer = null

	print("--- CY) settings local-refresh viewport snapshot reuse ---")
	scene.settings_panel_open = true
	var settings_refresh_snapshot_root_188 := Control.new()
	settings_refresh_snapshot_root_188.name = "SettingsLocalRefreshSnapshotRoot"
	settings_refresh_snapshot_root_188.size = Vector2(1280.0, 720.0)
	settings_refresh_snapshot_root_188.set_meta("ui_page_generation", scene.ui_page_generation)
	root.add_child(settings_refresh_snapshot_root_188)
	var settings_refresh_panel_188 := Control.new()
	settings_refresh_panel_188.name = "SettingsPanel"
	settings_refresh_snapshot_root_188.add_child(settings_refresh_panel_188)
	scene.root_layer = settings_refresh_snapshot_root_188
	var settings_refresh_button_188 := Button.new()
	scene.make_setting_row(settings_refresh_panel_188, "AI 节奏", "当前: 标准", settings_refresh_button_188)
	var expected_settings_refresh_viewport_188: Vector2 = scene.effective_viewport_size()
	var settings_refreshed_188: bool = scene.refresh_settings_local_row("AI 节奏")
	check(settings_refreshed_188 and settings_refresh_panel_188.get_meta("local_update_viewport_snapshot", Vector2.ZERO) == expected_settings_refresh_viewport_188, "设置局部刷新发布本次更新的 viewport 快照")
	check(str(settings_refresh_panel_188.get_meta("local_update_viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_update", "设置局部刷新声明每次更新只读取一次 viewport")
	check(settings_refresh_button_188.text != "", "设置按钮局部刷新仍更新可见状态")
	scene.fast_mode_enabled = not scene.fast_mode_enabled
	check(settings_refresh_panel_188.get_meta("local_update_viewport_snapshot", Vector2.ZERO) == expected_settings_refresh_viewport_188, "后续设置状态变化不会改写已完成的局部刷新快照")
	settings_refresh_snapshot_root_188.queue_free()
	scene.clear_screen()
	scene.root_layer = null

	print("--- CZ) online-feedback viewport snapshot reuse ---")
	scene.online_feedback = "等待服务器确认"
	scene.online_waiting_for_server = true
	var online_feedback_snapshot_root_189 := Control.new()
	online_feedback_snapshot_root_189.name = "OnlineFeedbackViewportSnapshotRoot"
	online_feedback_snapshot_root_189.size = Vector2(1280.0, 720.0)
	root.add_child(online_feedback_snapshot_root_189)
	scene.root_layer = online_feedback_snapshot_root_189
	var expected_online_feedback_viewport_189: Vector2 = scene.effective_viewport_size()
	var online_feedback_art_189: Control = scene.draw_online_feedback_art(online_feedback_snapshot_root_189)
	var online_feedback_label_189 := online_feedback_art_189.get_node_or_null("OnlineFeedbackText") as Label if online_feedback_art_189 != null else null
	check(online_feedback_art_189 != null and online_feedback_art_189.get_meta("viewport_snapshot", Vector2.ZERO) == expected_online_feedback_viewport_189, "联机反馈插画发布本次绘制的 viewport 快照")
	check(online_feedback_art_189 != null and str(online_feedback_art_189.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "联机反馈插画声明每次绘制只读取一次 viewport")
	check(online_feedback_label_189 != null and online_feedback_label_189.text != "", "联机反馈文字仍完整构建")
	scene.online_feedback = "连接已恢复"
	check(online_feedback_art_189 != null and online_feedback_art_189.get_meta("viewport_snapshot", Vector2.ZERO) == expected_online_feedback_viewport_189, "后续联机状态变化不会改写已完成的 viewport 快照")
	scene.online_feedback = ""
	scene.online_waiting_for_server = false
	check(scene.draw_online_feedback_art(online_feedback_snapshot_root_189) == null, "无联机反馈时仍保留早退路径")
	online_feedback_snapshot_root_189.queue_free()
	scene.clear_screen()
	scene.root_layer = null

	print("--- DA) online-roster viewport snapshot reuse ---")
	scene.online_waiting_for_server = true
	scene.online_room = {"players": [{"name": "P0", "ready": true}, {"name": "P1", "ready": false}]}
	var online_roster_snapshot_root_190 := Control.new()
	online_roster_snapshot_root_190.name = "OnlineRosterViewportSnapshotRoot"
	online_roster_snapshot_root_190.size = Vector2(1280.0, 720.0)
	root.add_child(online_roster_snapshot_root_190)
	scene.root_layer = online_roster_snapshot_root_190
	var expected_online_roster_viewport_190: Vector2 = scene.effective_viewport_size()
	var online_roster_190: Control = scene.draw_online_lobby_roster_panel(online_roster_snapshot_root_190)
	var online_roster_name_190 := online_roster_190.get_node_or_null("OnlineLobbyRosterRow_0/OnlineLobbyRosterName_0") as Label if online_roster_190 != null else null
	var online_roster_state_190 := online_roster_190.get_node_or_null("OnlineLobbyRosterRow_0/OnlineLobbyRosterState_0") as Label if online_roster_190 != null else null
	check(online_roster_190 != null and online_roster_190.get_meta("viewport_snapshot", Vector2.ZERO) == expected_online_roster_viewport_190, "联机大厅席位面板发布本次绘制的 viewport 快照")
	check(online_roster_190 != null and str(online_roster_190.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "联机大厅席位面板声明每次绘制只读取一次 viewport")
	check(online_roster_name_190 != null and online_roster_state_190 != null and online_roster_name_190.text != "" and online_roster_state_190.text != "", "席位名称和状态仍完整构建")
	scene.online_room = {"players": [{"name": "P9", "ready": true}]}
	check(online_roster_190 != null and online_roster_190.get_meta("viewport_snapshot", Vector2.ZERO) == expected_online_roster_viewport_190, "后续房间状态不会改写已完成的 roster viewport 快照")
	online_roster_snapshot_root_190.queue_free()
	scene.clear_screen()
	scene.root_layer = null

	print("--- DB) replay-archive date snapshot reuse ---")
	var archive_date_snapshot_root_191 := Control.new()
	archive_date_snapshot_root_191.name = "ReplayArchiveDateSnapshotRoot"
	archive_date_snapshot_root_191.size = Vector2(1280.0, 720.0)
	root.add_child(archive_date_snapshot_root_191)
	scene.root_layer = archive_date_snapshot_root_191
	var archive_date_entry_191 := {"archive_id": "snapshot191", "timestamp": 1789000000, "result_kind": "win", "replay_digest": "abc12345", "rule_variant": "standard", "favorite": false}
	var archive_date_row_191: Control = scene.make_replay_archive_row(archive_date_entry_191)
	archive_date_snapshot_root_191.add_child(archive_date_row_191)
	var archive_date_text_191 := str(archive_date_row_191.get_meta("archive_date_text_snapshot", ""))
	var archive_display_date_text_191 := str(archive_date_row_191.get_meta("archive_display_date_text_snapshot", ""))
	var archive_primary_191 := archive_date_row_191.get_node_or_null("ReplayArchiveRowPrimary") as Label
	check(archive_date_row_191 != null and archive_date_text_191 != "" and archive_display_date_text_191 != "", "回放归档行发布完整日期和展示日期快照")
	check(str(archive_date_row_191.get_meta("archive_date_text_snapshot_policy", "")) == "one_date_parse_per_row", "回放归档行声明每行只解析一次日期")
	check(archive_primary_191 != null and archive_primary_191.text == archive_display_date_text_191 and archive_primary_191.tooltip_text == archive_date_text_191, "归档日期显示和 tooltip 仍保持完整/短文本层级")
	archive_date_entry_191["timestamp"] = 1790000000
	check(archive_date_row_191.get_meta("archive_date_text_snapshot", "") == archive_date_text_191 and archive_primary_191 != null and archive_primary_191.text == archive_display_date_text_191, "后续归档数据变化不会改写已完成的日期快照")
	archive_date_snapshot_root_191.queue_free()
	scene.clear_screen()
	scene.root_layer = null

	print("--- DC) toast viewport snapshot reuse ---")
	scene.mode = "menu"
	scene.ensure_fx_layer()
	var toast_snapshot_root_192 := Control.new()
	toast_snapshot_root_192.name = "ToastViewportSnapshotRoot"
	toast_snapshot_root_192.size = Vector2(1280.0, 720.0)
	root.add_child(toast_snapshot_root_192)
	scene.root_layer = toast_snapshot_root_192
	var expected_toast_viewport_192: Vector2 = scene.effective_viewport_size()
	scene.show_toast("一条较长的连接反馈提示", 1000)
	var toast_192 := scene.toast_current as Control
	var toast_pending_label_192 := toast_192.get_node_or_null("ToastPendingLabel") as Label if toast_192 != null else null
	check(toast_192 != null and toast_192.get_meta("viewport_snapshot", Vector2.ZERO) == expected_toast_viewport_192, "提示条发布本次绘制的 viewport 快照")
	check(toast_192 != null and str(toast_192.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "提示条声明每次绘制只读取一次 viewport")
	check(toast_pending_label_192 != null, "提示条仍完整构建队列状态节点")
	scene.mode = "offline"
	check(toast_192 != null and toast_192.get_meta("viewport_snapshot", Vector2.ZERO) == expected_toast_viewport_192, "后续页面状态不会改写已完成的提示条快照")
	toast_snapshot_root_192.queue_free()
	scene.clear_screen()
	scene.root_layer = null

	print("--- DD) rules-section viewport snapshot reuse ---")
	var rule_section_snapshot_root_193 := Control.new()
	rule_section_snapshot_root_193.name = "RuleSectionViewportSnapshotRoot"
	rule_section_snapshot_root_193.size = Vector2(1280.0, 720.0)
	root.add_child(rule_section_snapshot_root_193)
	var rule_sections_193 := VBoxContainer.new()
	rule_sections_193.name = "RulesSections"
	rule_section_snapshot_root_193.add_child(rule_sections_193)
	scene.root_layer = rule_section_snapshot_root_193
	var expected_rule_section_viewport_193: Vector2 = scene.effective_viewport_size()
	scene.add_rule_section(rule_sections_193, "和牌与响应", ["胡牌后按规则结算", "响应窗口按优先级处理"], 0)
	var rule_section_193 := rule_sections_193.get_node_or_null("RuleSection_0") as Control
	var rule_section_title_193 := rule_section_193.find_child("RuleSectionTitle_0", true, false) as Label if rule_section_193 != null else null
	check(rule_section_193 != null and rule_section_193.get_meta("viewport_snapshot", Vector2.ZERO) == expected_rule_section_viewport_193, "规则章节发布本次绘制的 viewport 快照")
	check(rule_section_193 != null and str(rule_section_193.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "规则章节声明每次绘制只读取一次 viewport")
	check(rule_section_title_193 != null and rule_section_title_193.text != "", "规则章节标题和正文仍完整构建")
	scene.large_text_enabled = true
	check(rule_section_193 != null and rule_section_193.get_meta("viewport_snapshot", Vector2.ZERO) == expected_rule_section_viewport_193, "后续阅读状态不会改写已完成的规则章节快照")
	rule_section_snapshot_root_193.queue_free()
	scene.clear_screen()
	scene.root_layer = null

	print("--- DE) exit-confirm viewport snapshot reuse ---")
	var exit_confirm_snapshot_root_194 := Control.new()
	exit_confirm_snapshot_root_194.name = "ExitConfirmViewportSnapshotRoot"
	exit_confirm_snapshot_root_194.size = Vector2(1280.0, 720.0)
	root.add_child(exit_confirm_snapshot_root_194)
	scene.root_layer = exit_confirm_snapshot_root_194
	scene.mode = "offline"
	var expected_exit_confirm_viewport_194: Vector2 = scene.effective_viewport_size()
	scene.show_exit_confirm()
	var exit_confirm_dialog_194 := exit_confirm_snapshot_root_194.get_node_or_null("ExitConfirmOverlay/ExitConfirmDialog") as Control
	var exit_confirm_message_194 := exit_confirm_dialog_194.get_node_or_null("ExitConfirmMessage") as Label if exit_confirm_dialog_194 != null else null
	var exit_continue_button_194 := exit_confirm_dialog_194.find_child("ExitConfirmContinueButton", true, false) as Button if exit_confirm_dialog_194 != null else null
	check(exit_confirm_dialog_194 != null and exit_confirm_dialog_194.get_meta("viewport_snapshot", Vector2.ZERO) == expected_exit_confirm_viewport_194, "退出确认对话框发布本次绘制的 viewport 快照")
	check(exit_confirm_dialog_194 != null and str(exit_confirm_dialog_194.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "退出确认对话框声明每次绘制只读取一次 viewport")
	check(exit_confirm_message_194 != null and exit_continue_button_194 != null and exit_confirm_message_194.text != "", "退出确认消息和继续按钮仍完整构建")
	scene.exit_confirm_decision_locked = true
	check(exit_confirm_dialog_194 != null and exit_confirm_dialog_194.get_meta("viewport_snapshot", Vector2.ZERO) == expected_exit_confirm_viewport_194, "后续退出状态不会改写已完成的对话框快照")
	exit_confirm_snapshot_root_194.queue_free()
	scene.clear_screen()
	scene.root_layer = null

	print("--- DF) replay-archive viewport snapshot reuse ---")
	var archive_viewport_snapshot_root_195 := Control.new()
	archive_viewport_snapshot_root_195.name = "ReplayArchiveViewportSnapshotRoot"
	archive_viewport_snapshot_root_195.size = Vector2(1280.0, 720.0)
	root.add_child(archive_viewport_snapshot_root_195)
	scene.root_layer = archive_viewport_snapshot_root_195
	scene.mode = "replay_import"
	var expected_archive_viewport_195: Vector2 = scene.effective_viewport_size()
	var archive_entry_195 := {"archive_id": "snapshot195", "timestamp": 1789000000, "result_kind": "win", "replay_digest": "abc12345", "rule_variant": "standard", "favorite": false}
	var archive_row_195: Control = scene.make_replay_archive_row(archive_entry_195)
	archive_viewport_snapshot_root_195.add_child(archive_row_195)
	var archive_primary_195 := archive_row_195.get_node_or_null("ReplayArchiveRowPrimary") as Label
	var archive_result_195 := archive_row_195.get_node_or_null("ReplayArchiveRowResult") as Label
	var archive_open_195 := archive_row_195.find_child("ReplayArchiveOpenButton_snapshot", true, false) as Button
	check(archive_row_195.get_meta("archive_viewport_snapshot", Vector2.ZERO) == expected_archive_viewport_195, "回放归档行发布本次绘制的 viewport 快照")
	check(str(archive_row_195.get_meta("archive_viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_row", "回放归档行声明每行只读取一次 viewport")
	check(archive_primary_195 != null and archive_result_195 != null and archive_open_195 != null and archive_primary_195.text != "" and archive_result_195.text != "", "归档日期、结果和操作仍完整构建")
	scene.large_text_enabled = true
	check(archive_row_195.get_meta("archive_viewport_snapshot", Vector2.ZERO) == expected_archive_viewport_195, "后续阅读状态不会改写已完成的归档 viewport 快照")
	archive_viewport_snapshot_root_195.queue_free()
	scene.clear_screen()
	scene.root_layer = null

	print("--- DG) AI evaluation visible-count state-key reuse ---")
	scene.mode = "offline"
	var visible_counts_196: Array = scene.visible_tile_counts_shared()
	var live_visible_state_key_196: String = scene.visible_tile_counts_cache_key
	var eval_context_196: Dictionary = scene.make_ai_evaluation_context(0)
	check(eval_context_196.get("visible_counts") == visible_counts_196, "AI 上下文仍复用共享的可见牌快照")
	check(str(eval_context_196.get("visible_state_cache_key", "")) == live_visible_state_key_196, "无参 AI 上下文复用已发布的可见牌状态键")
	check(str(eval_context_196.get("visible_state_cache_key", "")) == scene.visible_tile_counts_cache_key, "复用后的状态键仍与可见牌缓存保持一致")
	var explicit_eval_context_196: Dictionary = scene.make_ai_evaluation_context(0, visible_counts_196.duplicate(false))
	check(str(explicit_eval_context_196.get("visible_state_cache_key", "")) == live_visible_state_key_196, "显式可见牌快照保留实时状态键回退")
	check(explicit_eval_context_196.get("visible_counts") != null and explicit_eval_context_196.get("known_counts") != null, "显式快照上下文仍完整构建已知牌数据")

	print("--- DH) replay-archive parsed-date snapshot reuse ---")
	var archive_date_build_snapshot_root_197 := Control.new()
	archive_date_build_snapshot_root_197.name = "ReplayArchiveDateBuildSnapshotRoot"
	archive_date_build_snapshot_root_197.size = Vector2(1280.0, 720.0)
	root.add_child(archive_date_build_snapshot_root_197)
	scene.root_layer = archive_date_build_snapshot_root_197
	scene.mode = "replay_import"
	var archive_entry_197 := {"archive_id": "snapshot197", "timestamp": 1789000000, "result_kind": "win", "replay_digest": "abc12345", "rule_variant": "standard", "favorite": false}
	var expected_archive_date_197: String = scene.replay_archive_date_text(archive_entry_197)
	var archive_row_197: Control = scene.replay_archive_row_for_entry(archive_entry_197)
	archive_date_build_snapshot_root_197.add_child(archive_row_197)
	var archive_primary_197 := archive_row_197.get_node_or_null("ReplayArchiveRowPrimary") as Label
	check(archive_row_197.get_meta("archive_date_text_snapshot", "") == expected_archive_date_197, "归档行仍发布完整日期快照")
	check(str(archive_row_197.get_meta("archive_date_build_policy", "")) == "shared_precomputed_date", "归档行构建复用行签名已解析的日期")
	check(archive_primary_197 != null and archive_primary_197.tooltip_text == expected_archive_date_197 and archive_primary_197.text != "", "共享日期快照仍保持显示和 tooltip 文本")
	archive_entry_197["timestamp"] = 1790000000
	check(archive_row_197.get_meta("archive_date_text_snapshot", "") == expected_archive_date_197 and archive_primary_197 != null and archive_primary_197.tooltip_text == expected_archive_date_197, "后续归档数据变化不会改写已完成的日期快照")
	archive_date_build_snapshot_root_197.queue_free()
	scene.clear_screen()
	scene.root_layer = null

	print("--- DI) pending-claim layout viewport/content snapshot reuse ---")
	var pending_layout_snapshot_root_198 := Control.new()
	pending_layout_snapshot_root_198.name = "PendingClaimLayoutSnapshotRoot"
	pending_layout_snapshot_root_198.size = Vector2(1280.0, 720.0)
	root.add_child(pending_layout_snapshot_root_198)
	scene.root_layer = pending_layout_snapshot_root_198
	scene.mode = "offline"
	scene.offline_phase = "pending_claim"
	scene.offline_pending_claim = {
		"from_seat": 1,
		"tile": "3W",
		"options": ["chi", "peng", "gang", "hu"],
		"deadline_msec": Time.get_ticks_msec() + 12000,
	}
	scene.pending_claim_display_cache_key = ""
	var pending_layout_count_198 := 20
	var pending_live_viewport_198: Vector2 = scene.effective_viewport_size()
	var pending_live_content_198: Vector2 = scene.safe_content_pixel_size()
	var pending_live_columns_198: int = scene.pending_claim_action_columns(pending_layout_count_198)
	var pending_live_dock_198: Rect2 = scene.pending_claim_action_dock_rect_for_count(pending_layout_count_198)
	var pending_compact_viewport_198 := Vector2(960.0, 540.0)
	var pending_compact_content_198 := Vector2(960.0, 540.0)
	var pending_compact_columns_198: int = scene.pending_claim_action_columns(pending_layout_count_198, pending_compact_viewport_198, pending_compact_content_198)
	var pending_compact_rows_198: int = scene.pending_claim_action_row_count(pending_layout_count_198, pending_compact_viewport_198, pending_compact_content_198)
	var pending_compact_dock_198: Rect2 = scene.pending_claim_action_dock_rect_for_count(pending_layout_count_198, pending_compact_viewport_198, pending_compact_content_198)
	var pending_compact_bar_198: Rect2 = scene.pending_claim_action_bar_rect_for_count(pending_layout_count_198, pending_compact_viewport_198, pending_compact_content_198)
	var pending_compact_response_width_198: float = scene.pending_claim_response_button_width(pending_layout_count_198, scene.action_button_separation_for_count(pending_layout_count_198, pending_compact_viewport_198), pending_compact_viewport_198, pending_compact_content_198)
	var pending_smaller_content_columns_198: int = scene.pending_claim_action_columns(pending_layout_count_198, pending_compact_viewport_198, Vector2(720.0, 400.0))
	check(pending_live_viewport_198.y > 560.0 and pending_compact_viewport_198.y <= 560.0, "pending action layout covers standard and compact viewport snapshots")
	check(pending_compact_columns_198 < pending_live_columns_198, "pending action columns consume the supplied viewport snapshot")
	check(pending_smaller_content_columns_198 < pending_compact_columns_198, "pending action columns consume the supplied content-size snapshot")
	check(pending_compact_rows_198 > 0 and pending_compact_dock_198 != pending_live_dock_198 and pending_compact_bar_198 != scene.pending_claim_action_bar_rect_for_count(pending_layout_count_198), "pending action dock/bar geometry consume the supplied snapshots")
	check(pending_compact_response_width_198 >= scene.PENDING_CLAIM_BUTTON_MIN_WIDTH, "pending response width keeps its minimum touch target under supplied snapshots")
	check(scene.pending_claim_action_columns(pending_layout_count_198, pending_live_viewport_198, pending_live_content_198) == pending_live_columns_198, "pending action layout keeps the live fallback equivalent")
	pending_layout_snapshot_root_198.queue_free()
	scene.clear_screen()
	scene.root_layer = null

	print("--- DJ) battle contract content-size snapshot reuse ---")
	var battle_contract_snapshot_root_199 := Control.new()
	battle_contract_snapshot_root_199.name = "BattleContractContentSnapshotRoot"
	battle_contract_snapshot_root_199.size = Vector2(1280.0, 720.0)
	var battle_contract_hud_title_199 := Label.new()
	battle_contract_hud_title_199.name = "TopHudTitle"
	battle_contract_hud_title_199.text = "四川麻将"
	battle_contract_snapshot_root_199.add_child(battle_contract_hud_title_199)
	var battle_contract_hud_status_199 := Label.new()
	battle_contract_hud_status_199.name = "TopHudStatus"
	battle_contract_hud_status_199.text = "等待响应"
	battle_contract_snapshot_root_199.add_child(battle_contract_hud_status_199)
	root.add_child(battle_contract_snapshot_root_199)
	var expected_battle_contract_content_199: Vector2 = scene.safe_content_pixel_size()
	scene.register_battle_ui_round_contracts(battle_contract_snapshot_root_199)
	check(battle_contract_snapshot_root_199.get_meta("battle_ui_content_size_snapshot", Vector2.ZERO) == expected_battle_contract_content_199, "battle contract registration publishes one content-size snapshot")
	check(str(battle_contract_snapshot_root_199.get_meta("battle_ui_content_size_snapshot_policy", "")) == "one_content_size_snapshot_per_registration", "battle contract registration declares one content-size read per batch")
	check(battle_contract_hud_title_199.text != "" and battle_contract_hud_status_199.text != "", "battle HUD title and status remain registered and fitted")
	scene.large_text_enabled = true
	check(battle_contract_snapshot_root_199.get_meta("battle_ui_content_size_snapshot", Vector2.ZERO) == expected_battle_contract_content_199, "later accessibility state does not rewrite the completed registration snapshot")
	battle_contract_snapshot_root_199.queue_free()
	scene.clear_screen()
	scene.root_layer = null

	print("--- DK) discard river row viewport snapshot reuse ---")
	var discard_viewport_snapshot_root_200 := Control.new()
	discard_viewport_snapshot_root_200.name = "DiscardRiverViewportSnapshotRoot"
	discard_viewport_snapshot_root_200.size = Vector2(1280.0, 720.0)
	root.add_child(discard_viewport_snapshot_root_200)
	scene.root_layer = discard_viewport_snapshot_root_200
	scene.mode = "offline"
	var discard_river_discards_200: Array = []
	for _i in range(60):
		discard_river_discards_200.append("1W")
	while scene.players.size() < 4:
		scene.players.append({"discards": []})
	scene.players[0]["discards"] = discard_river_discards_200
	scene.last_discard = "1W"
	scene.last_discard_seat = 0
	scene.draw_discards(discard_viewport_snapshot_root_200)
	var expected_discard_viewport_200: Vector2 = scene.effective_viewport_size()
	check(discard_viewport_snapshot_root_200.get_meta("discard_river_viewport_snapshot", Vector2.ZERO) == expected_discard_viewport_200, "discard river publishes the draw viewport snapshot")
	check(str(discard_viewport_snapshot_root_200.get_meta("discard_river_viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "discard river declares one viewport read per draw")
	var discard_side_zone_200: Rect2 = scene.DISCARD_ZONES[2][1]
	var discard_probe_table_200 := Vector2(1280.0, 1600.0)
	var discard_wide_viewport_200 := Vector2(1280.0, 720.0)
	var discard_compact_viewport_200 := Vector2(960.0, 540.0)
	var discard_wide_rows_200: int = scene.discard_zone_visible_rows_for_table_size(discard_side_zone_200, 3, discard_probe_table_200, discard_wide_viewport_200)
	var discard_compact_rows_200: int = scene.discard_zone_visible_rows_for_table_size(discard_side_zone_200, 3, discard_probe_table_200, discard_compact_viewport_200)
	check(discard_wide_rows_200 == 4 and discard_compact_rows_200 == 3, "explicit viewport snapshots drive side-river row caps")
	var discard_live_viewport_200: Vector2 = scene.effective_viewport_size()
	var discard_live_rows_200: int = scene.discard_zone_visible_rows(discard_side_zone_200, 3)
	var discard_explicit_live_rows_200: int = scene.discard_zone_visible_rows(discard_side_zone_200, 3, discard_live_viewport_200)
	check(discard_explicit_live_rows_200 == discard_live_rows_200, "viewport-aware row sizing preserves the live fallback result")
	var saved_discard_viewport_200: Vector2 = discard_viewport_snapshot_root_200.get_meta("discard_river_viewport_snapshot", Vector2.ZERO)
	scene.large_text_enabled = true
	check(discard_viewport_snapshot_root_200.get_meta("discard_river_viewport_snapshot", Vector2.ZERO) == saved_discard_viewport_200, "later state changes do not rewrite the completed river viewport snapshot")
	discard_viewport_snapshot_root_200.queue_free()
	scene.clear_screen()
	scene.root_layer = null

	print("--- DL) discard river chrome signature viewport snapshot reuse ---")
	var discard_chrome_snapshot_root_201 := Control.new()
	discard_chrome_snapshot_root_201.name = "DiscardRiverChromeViewportSnapshotRoot"
	discard_chrome_snapshot_root_201.size = Vector2(1280.0, 720.0)
	root.add_child(discard_chrome_snapshot_root_201)
	scene.root_layer = discard_chrome_snapshot_root_201
	scene.mode = "offline"
	while scene.players.size() < 4:
		scene.players.append({"discards": []})
	var discard_chrome_discards_201: Array = []
	for _i in range(20):
		discard_chrome_discards_201.append("1W")
	scene.players[0]["discards"] = discard_chrome_discards_201
	scene.last_discard = "1W"
	scene.last_discard_seat = 0
	scene.draw_discards(discard_chrome_snapshot_root_201)
	var expected_chrome_viewport_201: Vector2 = scene.effective_viewport_size()
	check(discard_chrome_snapshot_root_201.get_meta("discard_river_viewport_snapshot", Vector2.ZERO) == expected_chrome_viewport_201, "discard river chrome consumes the draw viewport snapshot")
	var discard_chrome_zone_201: Rect2 = scene.DISCARD_ZONES[0][1]
	var discard_chrome_live_viewport_201: Vector2 = scene.effective_viewport_size()
	var discard_chrome_compact_viewport_201 := Vector2(960.0, 540.0)
	var fallback_art_signature_201: String = scene.discard_river_art_render_signature(0, discard_chrome_zone_201, 20, 0)
	var explicit_art_signature_201: String = scene.discard_river_art_render_signature(0, discard_chrome_zone_201, 20, 0, discard_chrome_live_viewport_201)
	var compact_art_signature_201: String = scene.discard_river_art_render_signature(0, discard_chrome_zone_201, 20, 0, discard_chrome_compact_viewport_201)
	check(explicit_art_signature_201 == fallback_art_signature_201, "river art signature preserves the live fallback result")
	check(compact_art_signature_201 != fallback_art_signature_201, "river art signature consumes an explicit viewport snapshot")
	var fallback_owner_signature_201: String = scene.discard_river_owner_overlay_render_signature(0, discard_chrome_zone_201, 20, 0, 16, 16, 8, 2, -1, 0, 0, false, 0)
	var explicit_owner_signature_201: String = scene.discard_river_owner_overlay_render_signature(0, discard_chrome_zone_201, 20, 0, 16, 16, 8, 2, -1, 0, 0, false, 0, discard_chrome_live_viewport_201)
	var compact_owner_signature_201: String = scene.discard_river_owner_overlay_render_signature(0, discard_chrome_zone_201, 20, 0, 16, 16, 8, 2, -1, 0, 0, false, 0, discard_chrome_compact_viewport_201)
	check(explicit_owner_signature_201 == fallback_owner_signature_201, "owner overlay signature preserves the live fallback result")
	check(compact_owner_signature_201 != fallback_owner_signature_201, "owner overlay signature consumes an explicit viewport snapshot")
	var saved_chrome_viewport_201: Vector2 = discard_chrome_snapshot_root_201.get_meta("discard_river_viewport_snapshot", Vector2.ZERO)
	scene.large_text_enabled = true
	check(discard_chrome_snapshot_root_201.get_meta("discard_river_viewport_snapshot", Vector2.ZERO) == saved_chrome_viewport_201, "later state changes do not rewrite the completed chrome viewport snapshot")
	discard_chrome_snapshot_root_201.queue_free()
	scene.clear_screen()
	scene.root_layer = null

	print("--- DM) meld lane signature viewport snapshot reuse ---")
	var meld_viewport_snapshot_root_202 := Control.new()
	meld_viewport_snapshot_root_202.name = "MeldViewportSnapshotRoot"
	meld_viewport_snapshot_root_202.size = Vector2(1280.0, 720.0)
	root.add_child(meld_viewport_snapshot_root_202)
	scene.root_layer = meld_viewport_snapshot_root_202
	scene.mode = "offline"
	while scene.players.size() < 4:
		scene.players.append({"discards": [], "melds": []})
	scene.players[0]["melds"] = [["1W", "1W", "1W"], ["2W", "3W", "4W"]]
	scene.draw_melds(meld_viewport_snapshot_root_202)
	var expected_meld_viewport_202: Vector2 = scene.effective_viewport_size()
	check(meld_viewport_snapshot_root_202.get_meta("meld_viewport_snapshot", Vector2.ZERO) == expected_meld_viewport_202, "meld draw publishes the viewport snapshot")
	check(str(meld_viewport_snapshot_root_202.get_meta("meld_viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "meld draw declares one viewport read per draw")
	var meld_rect_202: Rect2 = scene.seat_meld_rect(0)
	var meld_content_202: Vector2 = scene.safe_content_pixel_size()
	var meld_live_viewport_202: Vector2 = scene.effective_viewport_size()
	var meld_compact_viewport_202 := Vector2(960.0, 540.0)
	var meld_list_202: Array = scene.players[0]["melds"]
	var fallback_meld_signature_202: String = scene.meld_lane_render_signature(0, meld_list_202, meld_rect_202, meld_rect_202, 2, 2, 0, 1, false, false, false, meld_content_202)
	var explicit_meld_signature_202: String = scene.meld_lane_render_signature(0, meld_list_202, meld_rect_202, meld_rect_202, 2, 2, 0, 1, false, false, false, meld_content_202, meld_live_viewport_202)
	var compact_meld_signature_202: String = scene.meld_lane_render_signature(0, meld_list_202, meld_rect_202, meld_rect_202, 2, 2, 0, 1, false, false, false, meld_content_202, meld_compact_viewport_202)
	check(explicit_meld_signature_202 == fallback_meld_signature_202, "meld lane signature preserves the live fallback result")
	check(compact_meld_signature_202 != fallback_meld_signature_202, "meld lane signature consumes an explicit viewport snapshot")
	var saved_meld_viewport_202: Vector2 = meld_viewport_snapshot_root_202.get_meta("meld_viewport_snapshot", Vector2.ZERO)
	scene.large_text_enabled = true
	check(meld_viewport_snapshot_root_202.get_meta("meld_viewport_snapshot", Vector2.ZERO) == saved_meld_viewport_202, "later state changes do not rewrite the completed meld viewport snapshot")
	meld_viewport_snapshot_root_202.queue_free()
	scene.clear_screen()
	scene.root_layer = null

	print("--- DN) top HUD identity viewport snapshot reuse ---")
	var top_hud_viewport_snapshot_root_203 := Control.new()
	top_hud_viewport_snapshot_root_203.name = "TopHudViewportSnapshotRoot"
	top_hud_viewport_snapshot_root_203.size = Vector2(1280.0, 720.0)
	root.add_child(top_hud_viewport_snapshot_root_203)
	scene.root_layer = top_hud_viewport_snapshot_root_203
	scene.mode = "offline"
	while scene.players.size() < 4:
		scene.players.append({"name": "玩家", "score": 8000, "hand": [], "discards": [], "melds": [], "flowers": 0})
	var top_hud_live_viewport_203: Vector2 = scene.effective_viewport_size()
	var top_hud_compact_viewport_203 := Vector2(960.0, 540.0)
	var fallback_top_hud_signature_203: String = scene.battle_top_hud_identity_signature()
	var explicit_top_hud_signature_203: String = scene.battle_top_hud_identity_signature(top_hud_live_viewport_203)
	var compact_top_hud_signature_203: String = scene.battle_top_hud_identity_signature(top_hud_compact_viewport_203)
	check(explicit_top_hud_signature_203 == fallback_top_hud_signature_203, "top HUD signature preserves the live fallback result")
	check(compact_top_hud_signature_203 != fallback_top_hud_signature_203, "top HUD signature consumes an explicit viewport snapshot")
	scene.draw_game_top_hud(top_hud_viewport_snapshot_root_203)
	var top_hud_203 := top_hud_viewport_snapshot_root_203.get_node_or_null("TopHud3DShell") as Control
	check(top_hud_203 != null and top_hud_203.get_meta("viewport_snapshot", Vector2.ZERO) == top_hud_live_viewport_203, "top HUD publishes the viewport snapshot used by its signature")
	check(top_hud_203 != null and str(top_hud_203.get_meta("viewport_snapshot_policy", "")) == "one_snapshot_per_hud_build", "top HUD keeps one viewport snapshot per build")
	var saved_top_hud_viewport_203: Vector2 = top_hud_203.get_meta("viewport_snapshot", Vector2.ZERO) if top_hud_203 != null else Vector2.ZERO
	scene.large_text_enabled = true
	check(top_hud_203 != null and top_hud_203.get_meta("viewport_snapshot", Vector2.ZERO) == saved_top_hud_viewport_203, "later state changes do not rewrite the completed HUD viewport snapshot")
	top_hud_viewport_snapshot_root_203.queue_free()
	scene.clear_screen()
	scene.root_layer = null

	print("--- DO) round summary viewport/content snapshot reuse ---")
	var summary_viewport_snapshot_root_204 := Control.new()
	summary_viewport_snapshot_root_204.name = "RoundSummaryViewportSnapshotRoot"
	summary_viewport_snapshot_root_204.size = Vector2(1280.0, 720.0)
	root.add_child(summary_viewport_snapshot_root_204)
	scene.root_layer = summary_viewport_snapshot_root_204
	scene.mode = "offline"
	scene.offline_phase = "ended"
	scene.round_result_kind = "win"
	scene.round_summary = "P0胡五万，2番 1000分。庄家连庄。"
	scene.last_win_score = {"winner": 0, "fan": 2, "points": 1000, "reasons": ["平和"], "win_tile": "5W", "self_draw": false, "limit_name": ""}
	scene.offline_last_winner = 0
	scene.offline_dealer_repeat = true
	while scene.players.size() < 4:
		scene.players.append({"name": "玩家", "score": 8000, "hand": [], "discards": [], "melds": [], "flowers": 0})
	var summary_live_viewport_204: Vector2 = scene.effective_viewport_size()
	var summary_live_content_204: Vector2 = scene.safe_content_pixel_size()
	var fallback_summary_signature_204: String = scene.battle_round_summary_identity_signature()
	var explicit_summary_signature_204: String = scene.battle_round_summary_identity_signature(summary_live_viewport_204, summary_live_content_204)
	var summary_compact_viewport_204 := Vector2(960.0, 540.0)
	var summary_compact_content_204 := Vector2(880.0, 500.0)
	var compact_summary_signature_204: String = scene.battle_round_summary_identity_signature(summary_compact_viewport_204, summary_compact_content_204)
	check(explicit_summary_signature_204 == fallback_summary_signature_204, "summary signature preserves the live fallback result")
	check(compact_summary_signature_204 != fallback_summary_signature_204, "summary signature consumes an explicit compact viewport snapshot")
	check(scene.ui_layout_density(summary_compact_viewport_204) == "compact", "summary signature density accepts the explicit viewport snapshot")
	check(scene.action_bar_dock_layout_rect(summary_live_viewport_204, summary_live_content_204) == scene.action_bar_dock_layout_rect(), "summary action-dock geometry preserves the live fallback result")
	scene.draw_round_summary(summary_viewport_snapshot_root_204)
	var summary_panel_204 := summary_viewport_snapshot_root_204.get_node_or_null("RoundSummaryPanel") as Control
	var summary_shield_204 := summary_viewport_snapshot_root_204.get_node_or_null("RoundSummaryModalInputShield") as Control
	check(summary_viewport_snapshot_root_204.get_meta("round_summary_viewport_snapshot", Vector2.ZERO) == summary_live_viewport_204, "summary draw publishes one viewport snapshot")
	check(summary_viewport_snapshot_root_204.get_meta("round_summary_content_size_snapshot", Vector2.ZERO) == summary_live_content_204, "summary draw publishes one content-size snapshot")
	check(str(summary_viewport_snapshot_root_204.get_meta("round_summary_snapshot_policy", "")) == "one_viewport_and_content_snapshot_per_draw", "summary draw declares its paired snapshot policy")
	check(summary_panel_204 != null and summary_panel_204.get_meta("round_summary_viewport_snapshot", Vector2.ZERO) == summary_live_viewport_204 and summary_panel_204.get_meta("round_summary_content_size_snapshot", Vector2.ZERO) == summary_live_content_204, "summary panel retains the draw snapshots")
	check(summary_shield_204 != null and summary_shield_204.get_meta("round_summary_viewport_snapshot", Vector2.ZERO) == summary_live_viewport_204 and summary_shield_204.get_meta("round_summary_content_size_snapshot", Vector2.ZERO) == summary_live_content_204, "summary input shield retains the draw snapshots")
	var saved_summary_viewport_204: Vector2 = summary_viewport_snapshot_root_204.get_meta("round_summary_viewport_snapshot", Vector2.ZERO)
	var saved_summary_content_204: Vector2 = summary_viewport_snapshot_root_204.get_meta("round_summary_content_size_snapshot", Vector2.ZERO)
	scene.large_text_enabled = true
	check(summary_viewport_snapshot_root_204.get_meta("round_summary_viewport_snapshot", Vector2.ZERO) == saved_summary_viewport_204 and summary_viewport_snapshot_root_204.get_meta("round_summary_content_size_snapshot", Vector2.ZERO) == saved_summary_content_204, "later state changes do not rewrite the completed summary snapshots")
	summary_viewport_snapshot_root_204.queue_free()
	scene.clear_screen()
	scene.root_layer = null

	print("--- DP) center identity viewport snapshot reuse ---")
	var center_viewport_snapshot_root_205 := Control.new()
	center_viewport_snapshot_root_205.name = "CenterViewportSnapshotRoot"
	center_viewport_snapshot_root_205.size = Vector2(1280.0, 720.0)
	root.add_child(center_viewport_snapshot_root_205)
	scene.root_layer = center_viewport_snapshot_root_205
	scene.mode = "offline"
	scene.offline_phase = "resolving"
	scene.offline_sim_quiet = true
	scene.last_discard = ""
	scene.last_discard_seat = -1
	while scene.players.size() < 4:
		scene.players.append({"name": "玩家", "score": 8000, "hand": [], "discards": [], "melds": [], "flowers": 0})
	var center_live_viewport_205: Vector2 = scene.effective_viewport_size()
	var fallback_center_signature_205: String = scene.battle_center_identity_signature()
	var explicit_center_signature_205: String = scene.battle_center_identity_signature(center_live_viewport_205)
	var compact_center_viewport_205 := Vector2(960.0, 540.0)
	var compact_center_signature_205: String = scene.battle_center_identity_signature(compact_center_viewport_205)
	check(explicit_center_signature_205 == fallback_center_signature_205, "center signature preserves the live fallback result")
	check(compact_center_signature_205 != fallback_center_signature_205, "center signature consumes an explicit compact viewport snapshot")
	scene.draw_center(center_viewport_snapshot_root_205)
	var center_205 := center_viewport_snapshot_root_205.get_node_or_null("CenterConsole3DShell") as Control
	check(center_viewport_snapshot_root_205.get_meta("center_viewport_snapshot", Vector2.ZERO) == center_live_viewport_205, "center draw publishes one viewport snapshot")
	check(str(center_viewport_snapshot_root_205.get_meta("center_viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "center draw declares one viewport read per draw")
	check(center_205 != null and center_205.get_meta("center_viewport_snapshot", Vector2.ZERO) == center_live_viewport_205, "center shell retains the draw viewport snapshot")
	check(center_205 != null and str(center_205.get_meta("center_viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "center shell declares the viewport snapshot policy")
	var saved_center_viewport_205: Vector2 = center_viewport_snapshot_root_205.get_meta("center_viewport_snapshot", Vector2.ZERO)
	scene.large_text_enabled = true
	check(center_viewport_snapshot_root_205.get_meta("center_viewport_snapshot", Vector2.ZERO) == saved_center_viewport_205, "later state changes do not rewrite the completed center snapshot")
	center_viewport_snapshot_root_205.queue_free()
	scene.clear_screen()
	scene.root_layer = null

	print("--- DQ) seat render viewport snapshot reuse ---")
	var seat_viewport_snapshot_root_206 := Control.new()
	seat_viewport_snapshot_root_206.name = "SeatViewportSnapshotRoot"
	seat_viewport_snapshot_root_206.size = Vector2(1280.0, 720.0)
	root.add_child(seat_viewport_snapshot_root_206)
	scene.root_layer = seat_viewport_snapshot_root_206
	scene.mode = "offline"
	scene.offline_phase = "resolving"
	scene.offline_sim_quiet = true
	while scene.players.size() < 4:
		scene.players.append({"name": "玩家", "score": 8000, "hand": [], "discards": [], "melds": [], "flowers": 0})
	var seat_rect_206: Rect2 = scene.SEAT_LAYOUTS[0][1]
	var seat_side_206 := str(scene.SEAT_LAYOUTS[0][2])
	var seat_live_viewport_206: Vector2 = scene.effective_viewport_size()
	var fallback_seat_signature_206: String = scene.battle_seat_identity_signature(0, seat_rect_206, seat_side_206)
	var explicit_seat_signature_206: String = scene.battle_seat_identity_signature(0, seat_rect_206, seat_side_206, {}, {}, seat_live_viewport_206)
	var compact_seat_viewport_206 := Vector2(960.0, 540.0)
	var compact_seat_signature_206: String = scene.battle_seat_identity_signature(0, seat_rect_206, seat_side_206, {}, {}, compact_seat_viewport_206)
	check(explicit_seat_signature_206 == fallback_seat_signature_206, "seat signature preserves the live fallback result")
	check(compact_seat_signature_206 != fallback_seat_signature_206, "seat signature consumes an explicit compact viewport snapshot")
	scene.draw_seat(seat_viewport_snapshot_root_206, 0, seat_rect_206, seat_side_206, {}, {}, seat_live_viewport_206)
	var seat_panel_206 := seat_viewport_snapshot_root_206.get_node_or_null("SeatPanel_0") as Control
	var seat_shadow_206 := seat_viewport_snapshot_root_206.get_node_or_null("SeatPanel3DCastShadow_0") as Control
	check(seat_viewport_snapshot_root_206.get_meta("seat_viewport_snapshot", Vector2.ZERO) == seat_live_viewport_206, "seat draw publishes one viewport snapshot")
	check(str(seat_viewport_snapshot_root_206.get_meta("seat_viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_seat_draw", "seat draw declares one viewport read per seat")
	check(seat_panel_206 != null and seat_panel_206.get_meta("seat_viewport_snapshot", Vector2.ZERO) == seat_live_viewport_206, "seat panel retains the draw viewport snapshot")
	check(seat_shadow_206 != null and seat_shadow_206.get_meta("seat_viewport_snapshot", Vector2.ZERO) == seat_live_viewport_206, "seat shadow retains the draw viewport snapshot")
	var saved_seat_viewport_206: Vector2 = seat_viewport_snapshot_root_206.get_meta("seat_viewport_snapshot", Vector2.ZERO)
	scene.large_text_enabled = true
	check(seat_viewport_snapshot_root_206.get_meta("seat_viewport_snapshot", Vector2.ZERO) == saved_seat_viewport_206, "later state changes do not rewrite the completed seat snapshot")
	seat_viewport_snapshot_root_206.queue_free()
	scene.clear_screen()
	scene.root_layer = null

	print("--- DR) win-detail parent viewport snapshot reuse ---")
	var win_detail_parent_snapshot_root_207 := Control.new()
	win_detail_parent_snapshot_root_207.name = "WinDetailParentViewportSnapshotRoot"
	win_detail_parent_snapshot_root_207.size = Vector2(1280.0, 720.0)
	root.add_child(win_detail_parent_snapshot_root_207)
	scene.root_layer = win_detail_parent_snapshot_root_207
	scene.setup_tile_order()
	scene.players = [
		{"name": "P0", "hand": [], "discards": [], "melds": [], "flowers": 0, "flower_tiles": [], "score": 25000, "bot": true},
		{"name": "P1", "hand": [], "discards": [], "melds": [], "flowers": 0, "flower_tiles": [], "score": 25000, "bot": true},
		{"name": "P2", "hand": [], "discards": [], "melds": [], "flowers": 0, "flower_tiles": [], "score": 25000, "bot": true},
		{"name": "P3", "hand": [], "discards": [], "melds": [], "flowers": 0, "flower_tiles": [], "score": 25000, "bot": true},
	]
	scene.mode = "offline"
	var win_detail_live_viewport_207: Vector2 = scene.effective_viewport_size()
	var win_detail_score_data_207 := {"winner": 0, "fan": 2, "points": 100, "reasons": ["立直"], "win_tile": "5W", "self_draw": false}
	scene.draw_win_detail_section(win_detail_parent_snapshot_root_207, win_detail_score_data_207, win_detail_live_viewport_207)
	var win_detail_panel_207 := win_detail_parent_snapshot_root_207.get_node_or_null("WinDetailPanel") as Control
	var win_detail_showcase_207 := win_detail_panel_207.get_node_or_null("WinDetailShowcase") as Control if win_detail_panel_207 != null else null
	check(win_detail_panel_207 != null and win_detail_panel_207.get_meta("viewport_snapshot", Vector2.ZERO) == win_detail_live_viewport_207, "win detail consumes the supplied parent viewport snapshot")
	check(win_detail_showcase_207 != null and win_detail_showcase_207.get_meta("viewport_snapshot", Vector2.ZERO) == win_detail_live_viewport_207, "win-detail showcase receives the same parent snapshot")
	win_detail_parent_snapshot_root_207.queue_free()
	scene.clear_screen()

	print("--- DS) pending-claim nested viewport snapshot reuse ---")
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_phase = "pending_claim"
	scene.current_seat = 0
	scene.players = [
		{"name": "P0", "hand": [], "discards": [], "melds": [], "flowers": 0, "flower_tiles": [], "score": 25000, "bot": true},
		{"name": "P1", "hand": [], "discards": [], "melds": [], "flowers": 0, "flower_tiles": [], "score": 25000, "bot": true},
		{"name": "P2", "hand": [], "discards": [], "melds": [], "flowers": 0, "flower_tiles": [], "score": 25000, "bot": true},
		{"name": "P3", "hand": [], "discards": [], "melds": [], "flowers": 0, "flower_tiles": [], "score": 25000, "bot": true},
	]
	scene.offline_pending_claim = {"from_seat": 1, "tile": "5W", "options": ["peng"], "chi_choices": [], "snapshot_token": 208}
	var pending_nested_live_viewport_208: Vector2 = scene.effective_viewport_size()
	var pending_nested_live_content_208: Vector2 = scene.safe_content_pixel_size()
	var pending_nested_fallback_rect_208: Rect2 = scene.pending_claim_context_layout_rect(pending_nested_live_content_208)
	var pending_nested_explicit_rect_208: Rect2 = scene.pending_claim_context_layout_rect(pending_nested_live_content_208, pending_nested_live_viewport_208)
	var pending_nested_compact_rect_208: Rect2 = scene.pending_claim_context_layout_rect(Vector2(880.0, 500.0), Vector2(960.0, 540.0))
	check(pending_nested_explicit_rect_208 == pending_nested_fallback_rect_208, "nested pending layout preserves the live fallback geometry")
	check(pending_nested_compact_rect_208 != pending_nested_fallback_rect_208, "nested pending layout consumes the explicit compact viewport snapshot")
	var pending_nested_root_208 := Control.new()
	pending_nested_root_208.name = "PendingClaimNestedViewportSnapshotRoot"
	pending_nested_root_208.size = Vector2(1280.0, 720.0)
	root.add_child(pending_nested_root_208)
	scene.root_layer = pending_nested_root_208
	scene.draw_pending_claim_illustration(pending_nested_root_208)
	var pending_nested_panel_208 := pending_nested_root_208.get_node_or_null("PendingClaimIllustration") as Control
	check(pending_nested_panel_208 != null and pending_nested_panel_208.get_meta("viewport_snapshot", Vector2.ZERO) == pending_nested_live_viewport_208, "pending illustration publishes the draw viewport snapshot")
	check(pending_nested_panel_208 != null and str(pending_nested_panel_208.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "pending illustration retains its one-read policy")
	scene.current_seat = 2
	check(pending_nested_panel_208 != null and pending_nested_panel_208.get_meta("viewport_snapshot", Vector2.ZERO) == pending_nested_live_viewport_208, "later state changes do not rewrite the pending viewport snapshot")
	pending_nested_root_208.queue_free()
	scene.clear_screen()
	scene.root_layer = null

	print("--- DT) single-opponent risk tile classification snapshot reuse ---")
	var risk_visibility_210: Array = scene.make_empty_tile_counts()
	var middle_risk_210: Dictionary = scene.single_opponent_deal_in_risk_components("5W", 0, 1, 0, risk_visibility_210)
	var terminal_risk_210: Dictionary = scene.single_opponent_deal_in_risk_components("1W", 0, 1, 1, risk_visibility_210)
	var honor_risk_210: Dictionary = scene.single_opponent_deal_in_risk_components("E", 0, 1, 0, risk_visibility_210)
	var invalid_risk_210: Dictionary = scene.single_opponent_deal_in_risk_components("ZZ", 0, 1, 0, risk_visibility_210)
	check(float(middle_risk_210.get("risk", 0.0)) > float(terminal_risk_210.get("risk", 0.0)), "middle-number risk keeps its sequence-feed weighting")
	check(float(honor_risk_210.get("risk", 0.0)) > float(terminal_risk_210.get("risk", 0.0)), "honor risk keeps its zero-visible weighting")
	check(float(invalid_risk_210.get("pattern_threat", 0.0)) == 0.0, "invalid tiles keep the legacy zero pattern threat")
	check(float(invalid_risk_210.get("risk", 0.0)) >= 0.0, "invalid tiles keep a bounded non-negative risk result")

	print("--- DU) opponent pattern-threat tile index snapshot reuse ---")
	scene.offline_pending_claim = {}
	scene.players[1]["melds"] = [["1W", "2W", "3W"]]
	scene.players[1]["discards"] = ["9B"]
	var pattern_visibility_211: Array = scene.make_empty_tile_counts()
	var pattern_index_211: int = scene.tile_index("5W")
	var pattern_visible_211: int = scene.visible_tile_count_from_counts("5W", pattern_visibility_211)
	var explicit_pattern_211: float = scene.opponent_pattern_threat_score(1, "5W", pattern_visible_211, {}, pattern_index_211)
	var fallback_pattern_211: float = scene.opponent_pattern_threat_score(1, "5W", pattern_visible_211)
	check(is_equal_approx(explicit_pattern_211, fallback_pattern_211), "pattern threat preserves its direct fallback with an explicit tile index")
	var aggregate_pattern_context_211: Dictionary = scene.make_ai_evaluation_context(0, pattern_visibility_211)
	var aggregate_pattern_211: float = scene.opponent_tile_threat_score("5W", 0, pattern_visibility_211, {}, aggregate_pattern_context_211)
	check(is_equal_approx(aggregate_pattern_211, explicit_pattern_211), "aggregate opponent threat reuses the single tile index across opponents")

	print("--- DV) added-gang canonical slot scan ---")
	scene.setup_tile_order()
	scene.players = [
		{"name": "P0", "hand": ["9W", "2W"], "discards": [], "melds": [["9W", "9W", "9W"], ["2W", "2W", "2W"]], "flowers": 0, "flower_tiles": [], "score": 25000, "bot": true},
		{"name": "P1", "hand": [], "discards": [], "melds": [], "flowers": 0, "flower_tiles": [], "score": 25000, "bot": true},
		{"name": "P2", "hand": [], "discards": [], "melds": [], "flowers": 0, "flower_tiles": [], "score": 25000, "bot": true},
		{"name": "P3", "hand": [], "discards": [], "melds": [], "flowers": 0, "flower_tiles": [], "score": 25000, "bot": true},
	]
	check(scene.first_added_gang_tile(0) == "2W", "added-gang scan keeps canonical tile order")
	scene.players[0]["hand"] = ["5W"]
	scene.players[0]["melds"] = [["5M", "5M", "5M"]]
	check(scene.first_added_gang_tile(0) == "5W", "added-gang scan keeps normalized meld aliases")
	scene.players[0]["hand"] = ["4W"]
	scene.players[0]["melds"] = [["4W", "4W", "5W"]]
	check(scene.first_added_gang_tile(0) == "", "added-gang scan ignores non-triplet melds")
	scene.players[0]["hand"] = []
	scene.players[0]["melds"] = [["6W", "6W", "6W"]]
	check(scene.first_added_gang_tile(0) == "", "added-gang scan ignores triplets absent from the hand")
	check(scene.first_added_gang_tile(-1) == "" and scene.first_added_gang_tile(4) == "", "added-gang scan keeps invalid-seat behavior")

	print("--- DW) hand-plan canonical tile classification ---")
	var feature_counts_213: Array = scene.make_empty_tile_counts()
	var feature_total_213 := 0
	var expected_simple_213 := 0
	var expected_terminal_213 := 0
	var expected_orphan_unique_213 := 0
	var expected_orphan_tiles_213 := 0
	var expected_orphan_pair_213 := false
	for feature_index_213 in range(scene.TILE_CODES.size()):
		var feature_amount_213 := (feature_index_213 % 4) + 1
		feature_counts_213[feature_index_213] = feature_amount_213
		feature_total_213 += feature_amount_213
		var feature_tile_213: String = str(scene.TILE_CODES[feature_index_213])
		if scene.is_simple_number_tile(feature_tile_213):
			expected_simple_213 += feature_amount_213
		else:
			expected_terminal_213 += feature_amount_213
		if scene.is_thirteen_orphans_tile(feature_tile_213):
			expected_orphan_unique_213 += 1
			expected_orphan_tiles_213 += feature_amount_213
			if feature_amount_213 >= 2:
				expected_orphan_pair_213 = true
	var feature_report_213: Dictionary = scene.hand_plan_features_from_counts(feature_counts_213, feature_total_213, false)
	check(int(feature_report_213.get("simple_tiles", -1)) == expected_simple_213, "hand-plan simple-number totals keep canonical classification")
	check(int(feature_report_213.get("terminal_honor_tiles", -1)) == expected_terminal_213, "hand-plan terminal/honor totals keep canonical classification")
	check(int(feature_report_213.get("orphan_unique", -1)) == expected_orphan_unique_213, "hand-plan orphan unique totals keep canonical classification")
	check(int(feature_report_213.get("orphan_tiles", -1)) == expected_orphan_tiles_213, "hand-plan orphan tile totals keep canonical classification")
	check(bool(feature_report_213.get("orphan_pair", false)) == expected_orphan_pair_213, "hand-plan orphan pair flag keeps canonical classification")

	print("--- DX) shape neighbor snapshot reuse ---")
	var shape_counts_214: Array = scene.make_empty_tile_counts()
	shape_counts_214[0] = 1
	shape_counts_214[4] = 1
	shape_counts_214[9] = 2
	shape_counts_214[18] = 1
	shape_counts_214[27] = 1
	shape_counts_214[31] = 2
	var expected_shape_isolated_214 := 0
	for shape_index_214 in range(scene.TILE_CODES.size()):
		if scene.is_isolated_shape_tile(shape_counts_214, shape_index_214):
			expected_shape_isolated_214 += int(shape_counts_214[shape_index_214])
	var shape_metrics_214: Dictionary = scene.ai_hand_shape_metrics_from_counts(shape_counts_214)
	var shape_quality_214: Dictionary = shape_metrics_214.get("quality_report", {})
	check(int(shape_quality_214.get("isolated", -1)) == expected_shape_isolated_214, "shape metrics reuse neighbor checks without changing isolated count")
	var shape_feature_total_214 := 0
	for shape_amount_214 in shape_counts_214:
		shape_feature_total_214 += int(shape_amount_214)
	var shape_features_214: Dictionary = scene.hand_plan_features_from_counts(shape_counts_214, shape_feature_total_214, true)
	check(int(shape_features_214.get("shape_isolated", -1)) == expected_shape_isolated_214, "fused plan shape metrics reuse neighbor checks without changing isolated count")

	print("--- DY) hand-tray AI-assist status snapshot reuse ---")
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.current_seat = 0
	scene.players[0]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "2T", "3T", "5B", "E"]
	scene.wall.clear()
	for _i in range(20):
		scene.wall.append("1B")
	scene.ai_assist_enabled = false
	scene.current_human_advice = []
	var disabled_tray_text_215: String = scene.hand_tray_text()
	check(disabled_tray_text_215 == "牌墙偏少 · 余20 · 点击手牌出牌", "disabled AI assistance preserves the low-wall tray status")
	scene.ai_assist_enabled = true
	scene.current_human_advice = [{"tile": "1W", "ukeire": 8, "score": 42.0, "safety_label": "安"}]
	var enabled_tray_text_215: String = scene.hand_tray_text()
	check(enabled_tray_text_215 != disabled_tray_text_215 and enabled_tray_text_215 != "", "enabled AI assistance preserves the recommendation tray status")
	scene.wall.clear()
	for _i in range(6):
		scene.wall.append("1B")
	check(scene.hand_tray_text() == "牌墙将尽 · 余6 · 谨慎出牌", "critical wall preserves the hand-tray early return")

	print("--- DZ) deferred AI-assistance enable-state snapshot reuse ---")
	scene.wall.clear()
	for _i in range(60):
		scene.wall.append("1B")
	scene.offline_sim_quiet = true
	scene.ai_assist_enabled = true
	scene.current_human_advice = []
	scene.current_seat_threat_reports = {}
	scene.update_ai_assistance_async()
	check(not scene.current_human_advice.is_empty(), "enabled assistance still commits deferred discard advice")
	scene.ai_assist_enabled = false
	scene.current_human_advice = []
	scene.current_seat_threat_reports = {"sentinel": true}
	scene.update_ai_assistance_async()
	check(not scene.current_human_advice.is_empty(), "disabled assistance preserves deferred report calculation")
	check(bool(scene.current_seat_threat_reports.get("sentinel", false)), "disabled assistance preserves the existing threat display")

	print("--- EA) normal action self-discard and AI-state snapshot reuse ---")
	scene.offline_sim_quiet = true
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.current_seat = 0
	scene.players[0]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "2T", "3T", "5B", "E"]
	scene.ai_assist_enabled = true
	scene.current_human_advice = [{"tile": "1W", "ukeire": 8, "score": 42.0, "safety_label": "安"}]
	scene.ai_advice_hand_signature = scene.hand_identity_fingerprint(scene.get_self_hand())
	var action_snapshot_enabled_root := Control.new()
	action_snapshot_enabled_root.size = Vector2(1280.0, 720.0)
	root.add_child(action_snapshot_enabled_root)
	scene.root_layer = action_snapshot_enabled_root
	scene.draw_actions(action_snapshot_enabled_root)
	check(action_snapshot_enabled_root.find_child("RecommendedDiscardButton", true, false) != null, "enabled assistance keeps the recommended action")
	scene.ai_assist_enabled = false
	scene.current_human_advice = []
	scene.ai_render_report_snapshot_ready = false
	var action_snapshot_disabled_root := Control.new()
	action_snapshot_disabled_root.size = Vector2(1280.0, 720.0)
	root.add_child(action_snapshot_disabled_root)
	scene.root_layer = action_snapshot_disabled_root
	scene.draw_actions(action_snapshot_disabled_root)
	check(action_snapshot_disabled_root.find_child("RecommendedDiscardButton", true, false) == null, "disabled assistance removes the recommended action")
	check(action_snapshot_disabled_root.find_child("OfflineRestartButton", true, false) != null, "disabled assistance preserves the normal restart action")
	action_snapshot_enabled_root.queue_free()
	action_snapshot_disabled_root.queue_free()

	print("--- EB) incremental hand-plan canonical tile classification ---")
	var incremental_counts_218: Array = scene.make_empty_tile_counts()
	var incremental_total_218 := 0
	for incremental_index_218 in range(scene.TILE_CODES.size()):
		var incremental_amount_218 := (incremental_index_218 % 4) + 1
		incremental_counts_218[incremental_index_218] = incremental_amount_218
		incremental_total_218 += incremental_amount_218
	var complete_features_218: Dictionary = scene.hand_plan_features_from_counts(incremental_counts_218, incremental_total_218, false)
	var added_features_218: Dictionary = {}
	for incremental_index_218 in range(scene.TILE_CODES.size()):
		var incremental_amount_218 := int(incremental_counts_218[incremental_index_218])
		for incremental_previous_218 in range(incremental_amount_218):
			scene.hand_plan_features_add_tile(added_features_218, incremental_index_218, incremental_previous_218)
	check(int(added_features_218.get("simple_tiles", -1)) == int(complete_features_218.get("simple_tiles", -2)), "incremental hand-plan simple-number totals preserve canonical classification")
	check(int(added_features_218.get("terminal_honor_tiles", -1)) == int(complete_features_218.get("terminal_honor_tiles", -2)), "incremental hand-plan terminal/honor totals preserve canonical classification")
	check(int(added_features_218.get("orphan_unique", -1)) == int(complete_features_218.get("orphan_unique", -2)), "incremental hand-plan orphan unique totals preserve canonical classification")
	check(int(added_features_218.get("orphan_tiles", -1)) == int(complete_features_218.get("orphan_tiles", -2)), "incremental hand-plan orphan tile totals preserve canonical classification")
	check(bool(added_features_218.get("orphan_pair", false)) == bool(complete_features_218.get("orphan_pair", true)), "incremental hand-plan orphan pair state preserves canonical classification")

	print("--- EC) feed-risk tile-index snapshot reuse ---")
	scene.players[1]["melds"] = [["5W", "5W", "5W"]]
	var feed_visible_219: Array = scene.make_empty_tile_counts()
	var feed_index_219: int = scene.tile_index("5W")
	var chi_fallback_219: float = scene.chi_feed_risk_score("5W", 0, 1, 0)
	var chi_explicit_219: float = scene.chi_feed_risk_score("5W", 0, 1, 0, {}, -1, feed_index_219)
	check(is_equal_approx(chi_fallback_219, chi_explicit_219), "chi feed risk preserves the direct fallback result")
	var meld_fallback_219: float = scene.meld_feed_risk_score("5W", 0, 1, 0)
	var meld_explicit_219: float = scene.meld_feed_risk_score("5W", 0, 1, 0, {}, -1, feed_index_219)
	check(is_equal_approx(meld_fallback_219, meld_explicit_219), "meld feed risk preserves the direct fallback result")
	var feed_report_219: Dictionary = scene.discard_feed_risk_report("5W", 0, feed_visible_219)
	check(feed_report_219.has("score") and feed_report_219.has("details"), "aggregate feed-risk reporting keeps its result structure")

	print("--- ED) suji safety tile-index snapshot reuse ---")
	scene.players[1]["discards"] = ["1W", "7W"]
	var suji_index_220: int = scene.tile_index("4W")
	var suji_fallback_220: bool = scene.is_suji_safe_against_opponent("4W", 1)
	var suji_explicit_220: bool = scene.is_suji_safe_against_opponent("4W", 1, {}, suji_index_220)
	check(suji_fallback_220 == suji_explicit_220, "suji safety preserves its direct fallback result")
	check(scene.is_suji_safe_tile("4M", 0) == suji_fallback_220, "table-level suji safety preserves normalized aliases")

	print("--- EE) kabe safety tile-index snapshot reuse ---")
	scene.players[1]["discards"] = ["E", "S", "W", "N", "P", "F"]
	var kabe_visible_221: Array = scene.make_empty_tile_counts()
	var kabe_index_221: int = scene.tile_index("4W")
	kabe_visible_221[scene.tile_index("3W")] = 3
	var kabe_fallback_221: bool = scene.is_kabe_safe_against_opponent("4W", 1, kabe_visible_221)
	var kabe_explicit_221: bool = scene.is_kabe_safe_against_opponent("4W", 1, kabe_visible_221, {}, kabe_index_221)
	check(kabe_fallback_221 == kabe_explicit_221, "kabe safety preserves its direct fallback result")
	check(scene.is_kabe_safe_tile("4M", 0, kabe_visible_221, {}, kabe_index_221) == kabe_fallback_221, "table-level kabe safety preserves normalized aliases")
	kabe_visible_221[kabe_index_221] = 3
	check(not scene.is_kabe_safe_tile("4W", 0, kabe_visible_221, {}, kabe_index_221), "visible candidate tiles retain the kabe rejection")
	check(not scene.is_kabe_safe_against_opponent("ZZ", 1, kabe_visible_221), "invalid kabe tiles retain the legacy rejection")

	print("--- EF) discard-pressure tile-index snapshot reuse ---")
	scene.players[1]["discards"] = ["1W", "2W", "3W", "E"]
	var pressure_index_222: int = scene.tile_index("4W")
	var pressure_fallback_222: bool = scene.same_suit_pressure(1, "4W")
	var pressure_explicit_222: bool = scene.same_suit_pressure(1, "4W", {}, pressure_index_222)
	check(pressure_fallback_222 == pressure_explicit_222, "same-suit pressure preserves its direct fallback result")
	check(scene.same_suit_pressure(1, "4M", {}, pressure_index_222) == pressure_fallback_222, "same-suit pressure preserves normalized aliases")
	check(not scene.same_suit_pressure(1, "ZZ"), "same-suit pressure keeps invalid-tile behavior")
	var pressure_visible_222: Array = scene.make_empty_tile_counts()
	var pressure_score_222: float = scene.discard_pressure_score("4W", 0, pressure_visible_222)
	check(pressure_score_222 >= 1.2, "discard pressure retains the same-suit contribution")

	print("--- EG) discard-report tile-index snapshot reuse ---")
	var report_counts_223: Array = scene.tile_counts(["E", "2W", "3W", "4W"])
	var report_index_223: int = scene.tile_index("E")
	var report_opening_context_223: Dictionary = {
		"seat": 1,
		"discard_report_wall_count": 60,
		"discard_report_route_focus": 1.0,
		"discard_report_difficulty": 1,
	}
	var report_opening_fallback_223: float = scene.opening_efficiency_adjustment(1, "E", 4, report_counts_223, 0, report_opening_context_223)
	var report_opening_explicit_223: float = scene.opening_efficiency_adjustment(1, "E", 4, report_counts_223, 0, report_opening_context_223, report_index_223)
	check(is_equal_approx(report_opening_fallback_223, report_opening_explicit_223), "opening efficiency preserves its explicit tile-index result")
	var report_post_context_223: Dictionary = {
		"seat": 1,
		"discard_report_route_focus": 1.0,
		"discard_report_difficulty": 1,
	}
	var report_post_fallback_223: float = scene.post_meld_route_adjustment(1, "E", 1, report_counts_223, "标准", -1, 2, report_post_context_223)
	var report_post_explicit_223: float = scene.post_meld_route_adjustment(1, "E", 1, report_counts_223, "标准", -1, 2, report_post_context_223, report_index_223)
	check(is_equal_approx(report_post_fallback_223, report_post_explicit_223), "post-meld route preserves its explicit tile-index result")
	check(is_equal_approx(scene.opening_efficiency_adjustment(1, "ZZ", 4, report_counts_223, 0, report_opening_context_223), 0.0), "opening efficiency keeps invalid-tile behavior")
	check(is_equal_approx(scene.post_meld_route_adjustment(1, "ZZ", 1, report_counts_223, "标准", -1, 2, report_post_context_223), 0.0), "post-meld route keeps invalid-tile behavior")

	print("--- EH) claim tile-index snapshot reuse ---")
	var claim_index_224: int = scene.tile_index("E")
	var claim_bonus_fallback_224: float = scene.ai_claim_meld_bonus(1, "peng", "E", {}, 1.0)
	var claim_bonus_explicit_224: float = scene.ai_claim_meld_bonus(1, "peng", "E", {}, 1.0, claim_index_224)
	check(is_equal_approx(claim_bonus_fallback_224, claim_bonus_explicit_224), "claim meld bonus preserves its explicit tile-index result")
	var claim_pressure_fallback_224: Dictionary = scene.ai_open_claim_pressure_report(1, "gang", "E", 3, 3, [], 1, {}, [], [])
	var claim_pressure_explicit_224: Dictionary = scene.ai_open_claim_pressure_report(1, "gang", "E", 3, 3, [], 1, {}, [], [], claim_index_224)
	check(bool(claim_pressure_fallback_224.get("decline", false)) == bool(claim_pressure_explicit_224.get("decline", false)), "claim pressure preserves its explicit tile-index decision")
	check(is_equal_approx(float(claim_pressure_fallback_224.get("risk", 0.0)), float(claim_pressure_explicit_224.get("risk", 0.0))), "claim pressure preserves its explicit tile-index risk")
	check(is_equal_approx(scene.ai_claim_meld_bonus(1, "peng", "ZZ", {}, 1.0), 34.0), "claim meld bonus keeps invalid-tile fallback behavior")

	print("--- EI) opponent risk tile-index snapshot reuse ---")
	scene.players[1]["discards"] = ["1W", "7W"]
	var risk_visible_225: Array = scene.make_empty_tile_counts()
	var risk_index_225: int = scene.tile_index("4W")
	var risk_fallback_context_225: Dictionary = scene.make_ai_evaluation_context(0, risk_visible_225)
	var risk_explicit_context_225: Dictionary = scene.make_ai_evaluation_context(0, risk_visible_225)
	var risk_fallback_225: Dictionary = scene.single_opponent_deal_in_risk_components("4W", 0, 1, 0, risk_visible_225, risk_fallback_context_225)
	var risk_explicit_225: Dictionary = scene.single_opponent_deal_in_risk_components("4W", 0, 1, 0, risk_visible_225, risk_explicit_context_225, risk_index_225)
	check(is_equal_approx(float(risk_fallback_225.get("risk", 0.0)), float(risk_explicit_225.get("risk", 0.0))), "single-opponent risk preserves its explicit tile-index result")
	check(is_equal_approx(float(risk_fallback_225.get("pattern_threat", 0.0)), float(risk_explicit_225.get("pattern_threat", 0.0))), "single-opponent threat preserves its explicit tile-index result")
	var risk_vector_225: Dictionary = scene.tile_risk_vector("4W", 0, risk_visible_225, risk_fallback_context_225)
	check(risk_vector_225.has("score") and risk_vector_225.has("threat") and risk_vector_225.has("visible"), "aggregate risk vector keeps its result structure")
	var invalid_risk_fallback_225: Dictionary = scene.single_opponent_deal_in_risk_components("ZZ", 0, 1, 0, risk_visible_225)
	var invalid_risk_explicit_225: Dictionary = scene.single_opponent_deal_in_risk_components("ZZ", 0, 1, 0, risk_visible_225, {}, -1)
	check(is_equal_approx(float(invalid_risk_fallback_225.get("risk", 0.0)), float(invalid_risk_explicit_225.get("risk", 0.0))), "invalid risk tiles keep the legacy fallback")

	print("--- EJ) added-gang public risk river lookup reuse ---")
	scene.players[1]["melds"] = [["5W", "5W", "5W"], ["6W", "6W", "6W"], ["7W", "7W", "7W"]]
	scene.players[1]["discards"] = ["1W", "2W", "3W", "8W", "9W", "E", "S", "W", "N", "P", "F", "C", "4W"]
	var chankan_discarded_226: Dictionary = scene.added_gang_rob_threat_report(0, "4W")
	var chankan_discarded_details_226: Array = chankan_discarded_226.get("risk_details", [])
	var chankan_discarded_seen_226 := false
	for chankan_detail_226 in chankan_discarded_details_226:
		if int(chankan_detail_226.get("seat", -1)) == 1:
			chankan_discarded_seen_226 = true
			break
	check(not chankan_discarded_seen_226, "publicly discarded gang tiles remain excluded from chankan risk")
	check(chankan_discarded_226.has("risk_score") and chankan_discarded_226.has("risk_details"), "added-gang risk keeps its report structure")
	scene.ai_state_revision += 1
	scene.players[1]["discards"] = []
	var chankan_live_226: Dictionary = scene.added_gang_rob_threat_report(0, "4W")
	check(chankan_live_226.has("risk_score") and chankan_live_226.has("max_risk"), "live public risk keeps aggregate fields after river changes")

	print("--- EK) threat-safe candidate tile-index snapshot reuse ---")
	scene.players[0]["hand"] = ["1W", "4W", "E", "5T"]
	scene.players[1]["discards"] = ["1W", "7W", "E"]
	var safe_visible_227: Array = scene.make_empty_tile_counts()
	safe_visible_227[scene.tile_index("4W")] = 2
	var safe_index_227: int = scene.tile_index("4W")
	var safe_visible_fallback_227: int = scene.visible_tile_count_from_counts("4W", safe_visible_227)
	var safe_visible_explicit_227: int = scene.visible_tile_count_from_counts("4W", safe_visible_227, safe_index_227)
	check(safe_visible_fallback_227 == safe_visible_explicit_227, "visible-count lookup preserves the explicit tile-index result")
	var safe_context_227: Dictionary = scene.make_ai_evaluation_context(0, safe_visible_227)
	var safe_tiles_227: Array = scene.threat_safe_tile_labels(0, "suit", 0, 3, safe_context_227, 1)
	check(safe_tiles_227.size() <= 3, "targeted threat-safe candidates keep the requested bound")
	var invalid_safe_fallback_227: int = scene.visible_tile_count_from_counts("ZZ", safe_visible_227)
	var invalid_safe_explicit_227: int = scene.visible_tile_count_from_counts("ZZ", safe_visible_227, -1)
	check(invalid_safe_fallback_227 == invalid_safe_explicit_227, "invalid visible-count tiles keep the legacy fallback")

	print("--- EL) discard-report candidate tile-index reuse ---")
	scene.players[0]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "E", "S", "W", "N"]
	var discard_visible_228: Array = scene.make_empty_tile_counts()
	var discard_index_228: int = scene.tile_index("4W")
	var discard_simulated_228: Array = scene.players[0]["hand"].duplicate()
	discard_simulated_228.erase("4W")
	var discard_simulated_counts_228: Array = scene.tile_counts(discard_simulated_228)
	var discard_context_228: Dictionary = scene.make_ai_evaluation_context(0, discard_visible_228)
	var discard_report_228: Dictionary = scene.build_ai_discard_report(0, "4W", discard_simulated_228, 0, discard_visible_228, {}, discard_context_228, discard_simulated_counts_228, [], 3, discard_index_228, 3, {})
	check(int(discard_report_228.get("tile_index", -1)) == discard_index_228, "discard reports preserve the explicit candidate tile index")
	check(str(discard_report_228.get("tile", "")) == "4W", "discard reports preserve the candidate tile")
	var invalid_discard_report_228: Dictionary = scene.build_ai_discard_report(0, "ZZ", ["1W", "2W", "3W"], 0, discard_visible_228, {}, {}, scene.tile_counts(["1W", "2W", "3W"]), [], -1, -1, 3, {})
	check(int(invalid_discard_report_228.get("tile_index", -2)) == -1, "invalid discard candidates keep the legacy index fallback")

	print("--- EM) claim route extra-meld index reuse ---")
	var claim_route_counts_229: Array = scene.tile_counts(["1W", "2W", "3W", "4T", "5T", "6T", "7B", "8B", "9B", "E", "S"])
	var claim_route_tiles_229: Array = ["9B", "9B", "9B"]
	var claim_route_indexes_229: Array[int] = []
	for claim_route_tile_229 in claim_route_tiles_229:
		claim_route_indexes_229.append(scene.tile_index(str(claim_route_tile_229)))
	var claim_route_fallback_229: Dictionary = scene.plan_report_with_extra_melds(1, claim_route_counts_229, 11, claim_route_tiles_229)
	var claim_route_explicit_229: Dictionary = scene.plan_report_with_extra_melds(1, claim_route_counts_229, 11, claim_route_tiles_229, [], claim_route_indexes_229)
	check(str(claim_route_fallback_229.get("label", "")) == str(claim_route_explicit_229.get("label", "")), "claim route labels preserve explicit extra-meld indexes")
	check(is_equal_approx(float(claim_route_fallback_229.get("score", 0.0)), float(claim_route_explicit_229.get("score", 0.0))), "claim route scores preserve explicit extra-meld indexes")
	check(is_equal_approx(float(claim_route_fallback_229.get("score_bonus", 0.0)), float(claim_route_explicit_229.get("score_bonus", 0.0))), "claim route bonuses preserve explicit extra-meld indexes")
	var invalid_claim_route_fallback_229: Dictionary = scene.plan_report_with_extra_melds(1, claim_route_counts_229, 11, ["ZZ"])
	var invalid_claim_route_explicit_229: Dictionary = scene.plan_report_with_extra_melds(1, claim_route_counts_229, 11, ["ZZ"], [], [-1])
	check(str(invalid_claim_route_fallback_229.get("label", "")) == str(invalid_claim_route_explicit_229.get("label", "")), "invalid extra-meld tiles keep the legacy route fallback")

	print("--- EN) discard reason tile-index reuse ---")
	var reason_counts_230: Array = scene.tile_counts(["1W", "2W", "3W", "4T", "5T", "6T", "E"])
	var reason_index_230: int = scene.tile_index("4W")
	var reason_isolated_fallback_230: bool = scene.is_discard_isolated("4W", [], reason_counts_230)
	var reason_isolated_explicit_230: bool = scene.is_discard_isolated("4W", [], reason_counts_230, reason_index_230)
	check(reason_isolated_fallback_230 == reason_isolated_explicit_230, "isolated-discard detection preserves the explicit tile index")
	var reason_input_230: Dictionary = {"safety_label": "", "plan_label": "标准", "shanten": 3, "shape_label": "", "wait_value": 0.0}
	var reason_fallback_230: String = scene.discard_reason_label("4W", [], reason_input_230, reason_counts_230)
	var reason_explicit_230: String = scene.discard_reason_label("4W", [], reason_input_230, reason_counts_230, reason_index_230)
	check(reason_fallback_230 == reason_explicit_230, "discard reason text preserves the explicit tile index")

	print("--- EO) threat-safe candidate classification reuse ---")
	scene.players[0]["hand"] = ["4W", "8W", "E", "5T"]
	scene.players[1]["discards"] = ["1W", "7W", "E"]
	var classification_visible_231: Array = scene.make_empty_tile_counts()
	var classification_context_231: Dictionary = scene.make_ai_evaluation_context(0, classification_visible_231)
	var classification_suit_231: Array = scene.threat_safe_tile_labels(0, "suit", 0, 4, classification_context_231, 1)
	var classification_honor_231: Array = scene.threat_safe_tile_labels(0, "honor", -1, 4, classification_context_231, 1)
	check(classification_suit_231.size() <= 4, "suit threat candidates keep the requested bound")
	check(classification_honor_231.size() <= 4, "honor threat candidates keep the requested bound")
	check(classification_suit_231.has(scene.tile_label("4W")), "number candidates retain their suit classification")
	check(classification_honor_231.has(scene.tile_label("E")), "honor candidates retain their honor classification")

	print("--- EP) threat-safe candidate sort-index reuse ---")
	for sort_index_232 in range(scene.TILE_CODES.size()):
		var sort_tile_232 := str(scene.TILE_CODES[sort_index_232])
		check(scene.tile_index(sort_tile_232) == scene.tile_sort_index(sort_tile_232), "canonical tile sort key matches its captured index")
	var sort_alias_index_232: int = scene.tile_index("4M")
	check(sort_alias_index_232 >= 0 and sort_alias_index_232 == scene.tile_sort_index("4M"), "normalized aliases keep the direct sort key")
	var sort_flower_232: int = scene.tile_sort_index("H1")
	check(scene.tile_index("H1") < 0 and sort_flower_232 == scene.TILE_CODES.size(), "flower candidates keep the sort fallback")
	var sort_invalid_232: int = scene.tile_sort_index("ZZ")
	check(scene.tile_index("ZZ") < 0 and sort_invalid_232 > sort_flower_232, "invalid candidates keep the terminal sort fallback")
	scene.players[0]["hand"] = ["1W", "4M", "E", "H1", "ZZ"]
	var sort_context_232: Dictionary = scene.make_ai_evaluation_context(0, scene.make_empty_tile_counts())
	var sort_labels_first_232: Array = scene.threat_safe_tile_labels(0, "honor", -1, 5, sort_context_232, 1)
	var sort_labels_second_232: Array = scene.threat_safe_tile_labels(0, "honor", -1, 5, sort_context_232, 1)
	check(sort_labels_first_232.size() <= 5, "threat candidates retain the requested bound")
	check(sort_labels_first_232 == sort_labels_second_232, "threat candidate ordering remains deterministic")
	check(sort_labels_first_232.has(scene.tile_label("4M")) and sort_labels_first_232.has(scene.tile_label("H1")), "canonical aliases and flowers remain visible candidates")

	print("--- EQ) self-gang tile classification snapshot reuse ---")
	scene.players[0]["hand"] = ["E", "E", "E", "E", "1W", "2W", "3W", "4T", "5T", "6T", "7B", "8B", "9B"]
	var gang_visible_233: Array = scene.make_empty_tile_counts()
	var gang_context_233: Dictionary = scene.make_ai_evaluation_context(0, gang_visible_233)
	var gang_report_233: Dictionary = scene.build_ai_self_gang_report(0, "E", "concealed", gang_context_233)
	check(int(gang_report_233.get("tile_index", -2)) == scene.tile_index("E"), "self-gang reports publish the canonical tile index")
	check(bool(gang_report_233.get("is_honor_tile", false)), "self-gang reports retain honor classification")
	check(bool(gang_report_233.get("is_terminal_or_honor", false)), "self-gang reports retain terminal/honor classification")
	var gang_fallback_report_233: Dictionary = gang_report_233.duplicate(true)
	gang_fallback_report_233.erase("tile_index")
	gang_fallback_report_233.erase("is_honor_tile")
	gang_fallback_report_233.erase("is_terminal_or_honor")
	check(is_equal_approx(scene.ai_self_gang_action_score(gang_report_233), scene.ai_self_gang_action_score(gang_fallback_report_233)), "honor self-gang score preserves the legacy fallback")
	var gang_invalid_report_233: Dictionary = {"tile": "ZZ", "gang_kind": "concealed"}
	var gang_invalid_snapshot_233: Dictionary = gang_invalid_report_233.duplicate(true)
	gang_invalid_snapshot_233["tile_index"] = -1
	gang_invalid_snapshot_233["is_honor_tile"] = false
	gang_invalid_snapshot_233["is_terminal_or_honor"] = false
	check(is_equal_approx(scene.ai_self_gang_action_score(gang_invalid_report_233), scene.ai_self_gang_action_score(gang_invalid_snapshot_233)), "invalid self-gang tiles retain the fallback score")

	print("--- ER) self-gang selector tile-index reuse ---")
	scene.players[0]["hand"] = ["E", "E", "E", "E", "1W", "2W", "3W", "4T", "5T", "6T", "7B", "8B", "9B"]
	var selector_visible_234: Array = scene.make_empty_tile_counts()
	var selector_context_234: Dictionary = scene.make_ai_evaluation_context(0, selector_visible_234)
	var selector_index_234: int = scene.tile_index("E")
	var selector_fallback_234: Dictionary = scene.build_ai_self_gang_report(0, "E", "concealed", selector_context_234)
	var selector_snapshot_234: Dictionary = scene.build_ai_self_gang_report(0, "E", "concealed", selector_context_234, selector_index_234)
	check(int(selector_snapshot_234.get("tile_index", -2)) == selector_index_234, "explicit self-gang index is retained in the report")
	check(bool(selector_snapshot_234.get("allow", false)) == bool(selector_fallback_234.get("allow", false)) and str(selector_snapshot_234.get("reason", "")) == str(selector_fallback_234.get("reason", "")), "explicit selector index preserves the decision")
	check(is_equal_approx(float(selector_snapshot_234.get("score", 0.0)), float(selector_fallback_234.get("score", 0.0))), "explicit selector index preserves the score")
	var selector_invalid_fallback_234: Dictionary = scene.build_ai_self_gang_report(0, "ZZ", "concealed", selector_context_234)
	var selector_invalid_snapshot_234: Dictionary = scene.build_ai_self_gang_report(0, "ZZ", "concealed", selector_context_234, -1)
	check(int(selector_invalid_snapshot_234.get("tile_index", -2)) == -1 and bool(selector_invalid_snapshot_234.get("allow", false)) == bool(selector_invalid_fallback_234.get("allow", false)), "invalid explicit index keeps the legacy rejection")

	print("--- ES) self-gang hand-count snapshot reuse ---")
	scene.players[0]["hand"] = ["E", "E", "E", "E", "1W", "2W", "3W", "4T", "5T", "6T", "7B", "8B", "9B"]
	var hand_count_visible_235: Array = scene.make_empty_tile_counts()
	var hand_count_context_235: Dictionary = scene.make_ai_evaluation_context(0, hand_count_visible_235)
	hand_count_context_235["hand_counts"] = scene.tile_counts(scene.players[0]["hand"])
	var hand_count_fallback_235: Dictionary = scene.build_ai_self_gang_report(0, "E", "concealed")
	var hand_count_snapshot_235: Dictionary = scene.build_ai_self_gang_report(0, "E", "concealed", hand_count_context_235)
	check(bool(hand_count_snapshot_235.get("allow", false)) == bool(hand_count_fallback_235.get("allow", false)) and str(hand_count_snapshot_235.get("reason", "")) == str(hand_count_fallback_235.get("reason", "")), "hand-count snapshot preserves the concealed-gang decision")
	check(is_equal_approx(float(hand_count_snapshot_235.get("score", 0.0)), float(hand_count_fallback_235.get("score", 0.0))), "hand-count snapshot preserves the concealed-gang score")
	var hand_count_invalid_context_235: Dictionary = hand_count_context_235.duplicate(true)
	hand_count_invalid_context_235["hand_counts"] = scene.make_empty_tile_counts()
	var hand_count_invalid_235: Dictionary = scene.build_ai_self_gang_report(0, "E", "concealed", hand_count_invalid_context_235)
	check(not bool(hand_count_invalid_235.get("allow", false)) and str(hand_count_invalid_235.get("reason", "")) == "非法杠", "stale hand-count snapshot keeps the guarded rejection")
	var hand_count_live_context_235: Dictionary = hand_count_context_235.duplicate(true)
	hand_count_live_context_235.erase("hand_counts")
	var hand_count_live_235: Dictionary = scene.build_ai_self_gang_report(0, "E", "concealed", hand_count_live_context_235)
	check(bool(hand_count_live_235.get("allow", false)) == bool(hand_count_fallback_235.get("allow", false)), "missing hand-count snapshot keeps the live fallback")

	print("--- ET) self-gang open-meld snapshot reuse ---")
	scene.players[0]["hand"] = ["E", "E", "E", "E", "1W", "2W", "3W", "4T", "5T", "6T", "7B", "8B", "9B"]
	scene.players[0]["melds"] = [["1T", "1T", "1T"], ["2T", "2T", "2T"]]
	var open_meld_visible_236: Array = scene.make_empty_tile_counts()
	var open_meld_context_236: Dictionary = scene.make_ai_evaluation_context(0, open_meld_visible_236)
	open_meld_context_236["hand_counts"] = scene.tile_counts(scene.players[0]["hand"])
	open_meld_context_236["self_gang_open_melds"] = scene.players[0]["melds"].size()
	var open_meld_fallback_236: Dictionary = scene.build_ai_self_gang_report(0, "E", "concealed")
	var open_meld_snapshot_236: Dictionary = scene.build_ai_self_gang_report(0, "E", "concealed", open_meld_context_236)
	check(int(open_meld_context_236.get("self_gang_open_melds", -1)) == 2, "self-gang context publishes the open-meld snapshot")
	check(int(open_meld_snapshot_236.get("before_shanten", 99)) == int(open_meld_fallback_236.get("before_shanten", -1)) and int(open_meld_snapshot_236.get("after_shanten", 99)) == int(open_meld_fallback_236.get("after_shanten", -1)), "open-meld snapshot preserves self-gang shanten")
	check(bool(open_meld_snapshot_236.get("allow", false)) == bool(open_meld_fallback_236.get("allow", false)), "open-meld snapshot preserves the decision")
	check(is_equal_approx(float(open_meld_snapshot_236.get("score", 0.0)), float(open_meld_fallback_236.get("score", 0.0))), "open-meld snapshot preserves the score")
	var open_meld_live_context_236: Dictionary = open_meld_context_236.duplicate(true)
	open_meld_live_context_236.erase("self_gang_open_melds")
	var open_meld_live_236: Dictionary = scene.build_ai_self_gang_report(0, "E", "concealed", open_meld_live_context_236)
	check(bool(open_meld_live_236.get("allow", false)) == bool(open_meld_fallback_236.get("allow", false)), "missing open-meld snapshot keeps the live fallback")

	print("--- EU) self-gang added-candidate snapshot reuse ---")
	scene.players[0]["hand"] = ["4M", "1W", "2W", "3W", "5W", "6W", "7W", "8W", "9W", "E", "S", "W", "N"]
	scene.players[0]["melds"] = [["4M", "4M", "4M"]]
	var added_candidate_visible_237: Array = scene.make_empty_tile_counts()
	var added_candidate_context_237: Dictionary = scene.make_ai_evaluation_context(0, added_candidate_visible_237)
	added_candidate_context_237["hand_counts"] = scene.tile_counts(scene.players[0]["hand"])
	added_candidate_context_237["self_gang_open_melds"] = scene.players[0]["melds"].size()
	added_candidate_context_237["self_gang_added_candidates"] = {"4W": true}
	var added_candidate_fallback_237: Dictionary = scene.build_ai_self_gang_report(0, "4M", "added")
	var added_candidate_snapshot_237: Dictionary = scene.build_ai_self_gang_report(0, "4M", "added", added_candidate_context_237, scene.tile_index("4M"))
	check(bool(added_candidate_snapshot_237.get("allow", false)) == bool(added_candidate_fallback_237.get("allow", false)) and str(added_candidate_snapshot_237.get("reason", "")) == str(added_candidate_fallback_237.get("reason", "")), "added-candidate snapshot preserves the decision")
	check(is_equal_approx(float(added_candidate_snapshot_237.get("score", 0.0)), float(added_candidate_fallback_237.get("score", 0.0))), "added-candidate snapshot preserves the score")
	var added_candidate_live_context_237: Dictionary = added_candidate_context_237.duplicate(true)
	added_candidate_live_context_237.erase("self_gang_added_candidates")
	var added_candidate_live_237: Dictionary = scene.build_ai_self_gang_report(0, "4M", "added", added_candidate_live_context_237, scene.tile_index("4M"))
	check(bool(added_candidate_live_237.get("allow", false)) == bool(added_candidate_fallback_237.get("allow", false)), "missing added-candidate snapshot keeps the live fallback")
	var added_candidate_stale_context_237: Dictionary = added_candidate_context_237.duplicate(true)
	added_candidate_stale_context_237["self_gang_added_candidates"] = {}
	var added_candidate_stale_237: Dictionary = scene.build_ai_self_gang_report(0, "4M", "added", added_candidate_stale_context_237, scene.tile_index("4M"))
	check(not bool(added_candidate_stale_237.get("allow", false)) and str(added_candidate_stale_237.get("reason", "")) == "非法杠", "empty added-candidate snapshot remains authoritative")
	var added_candidate_invalid_237: Dictionary = scene.build_ai_self_gang_report(0, "ZZ", "added", added_candidate_context_237, -1)
	check(not bool(added_candidate_invalid_237.get("allow", false)) and str(added_candidate_invalid_237.get("reason", "")) == "非法杠", "invalid added-gang candidates keep the guarded rejection")

	print("--- EV) self-gang before-plan label snapshot reuse ---")
	scene.players[0]["hand"] = ["E", "E", "E", "E", "1W", "2W", "3W", "4T", "5T", "6T", "7B", "8B", "9B"]
	scene.players[0]["melds"] = []
	var before_plan_visible_238: Array = scene.make_empty_tile_counts()
	var before_plan_context_238: Dictionary = scene.make_ai_evaluation_context(0, before_plan_visible_238)
	before_plan_context_238["hand_counts"] = scene.tile_counts(scene.players[0]["hand"])
	var before_plan_label_238: String = str(scene.hand_plan_report_for_seat_from_counts(0, before_plan_context_238["hand_counts"], scene.players[0]["hand"].size()).get("label", ""))
	before_plan_context_238["self_gang_before_plan_label"] = before_plan_label_238
	var before_plan_fallback_238: Dictionary = scene.build_ai_self_gang_report(0, "E", "concealed")
	var before_plan_snapshot_238: Dictionary = scene.build_ai_self_gang_report(0, "E", "concealed", before_plan_context_238, scene.tile_index("E"))
	check(before_plan_label_238 != "", "self-gang context captures the current before-plan label")
	check(str(before_plan_snapshot_238.get("before_plan_label", "")) == before_plan_label_238 and str(before_plan_snapshot_238.get("before_plan_label", "")) == str(before_plan_fallback_238.get("before_plan_label", "")), "before-plan snapshot preserves the route label")
	check(bool(before_plan_snapshot_238.get("allow", false)) == bool(before_plan_fallback_238.get("allow", false)) and str(before_plan_snapshot_238.get("reason", "")) == str(before_plan_fallback_238.get("reason", "")), "before-plan snapshot preserves the decision")
	var before_plan_live_context_238: Dictionary = before_plan_context_238.duplicate(true)
	before_plan_live_context_238.erase("self_gang_before_plan_label")
	var before_plan_live_238: Dictionary = scene.build_ai_self_gang_report(0, "E", "concealed", before_plan_live_context_238, scene.tile_index("E"))
	check(str(before_plan_live_238.get("before_plan_label", "")) == str(before_plan_fallback_238.get("before_plan_label", "")), "missing before-plan snapshot keeps the live fallback")
	var before_plan_changed_context_238: Dictionary = before_plan_context_238.duplicate(true)
	before_plan_changed_context_238["self_gang_before_plan_label"] = "七对"
	var before_plan_changed_238: Dictionary = scene.build_ai_self_gang_report(0, "E", "concealed", before_plan_changed_context_238, scene.tile_index("E"))
	check(str(before_plan_changed_238.get("before_plan_label", "")) == "七对", "explicit before-plan snapshot remains authoritative")

	print("--- EW) self-gang before-shanten snapshot reuse ---")
	scene.players[0]["hand"] = ["E", "E", "E", "E", "1W", "2W", "3W", "4T", "5T", "6T", "7B", "8B", "9B"]
	scene.players[0]["melds"] = []
	var before_shanten_visible_239: Array = scene.make_empty_tile_counts()
	var before_shanten_counts_239: Array = scene.tile_counts(scene.players[0]["hand"])
	var before_shanten_expected_239: int = scene.calculate_min_shanten_from_counts(before_shanten_counts_239, 0)
	var before_shanten_context_239: Dictionary = scene.make_ai_evaluation_context(0, before_shanten_visible_239)
	before_shanten_context_239["hand_counts"] = before_shanten_counts_239
	before_shanten_context_239["self_gang_open_melds"] = 0
	before_shanten_context_239["self_gang_before_shanten"] = before_shanten_expected_239
	var before_shanten_fallback_239: Dictionary = scene.build_ai_self_gang_report(0, "E", "concealed")
	var before_shanten_snapshot_239: Dictionary = scene.build_ai_self_gang_report(0, "E", "concealed", before_shanten_context_239, scene.tile_index("E"))
	check(int(before_shanten_snapshot_239.get("before_shanten", 99)) == before_shanten_expected_239 and int(before_shanten_snapshot_239.get("before_shanten", 99)) == int(before_shanten_fallback_239.get("before_shanten", -1)), "before-shanten snapshot preserves the baseline")
	check(int(before_shanten_snapshot_239.get("after_shanten", 99)) == int(before_shanten_fallback_239.get("after_shanten", -1)) and bool(before_shanten_snapshot_239.get("allow", false)) == bool(before_shanten_fallback_239.get("allow", false)), "before-shanten snapshot preserves the decision")
	var before_shanten_live_context_239: Dictionary = before_shanten_context_239.duplicate(true)
	before_shanten_live_context_239.erase("self_gang_before_shanten")
	var before_shanten_live_239: Dictionary = scene.build_ai_self_gang_report(0, "E", "concealed", before_shanten_live_context_239, scene.tile_index("E"))
	check(int(before_shanten_live_239.get("before_shanten", 99)) == int(before_shanten_fallback_239.get("before_shanten", -1)), "missing before-shanten snapshot keeps the live fallback")
	var before_shanten_changed_context_239: Dictionary = before_shanten_context_239.duplicate(true)
	before_shanten_changed_context_239["self_gang_before_shanten"] = before_shanten_expected_239 + 1
	var before_shanten_changed_239: Dictionary = scene.build_ai_self_gang_report(0, "E", "concealed", before_shanten_changed_context_239, scene.tile_index("E"))
	check(int(before_shanten_changed_239.get("before_shanten", 99)) == before_shanten_expected_239 + 1, "explicit before-shanten snapshot remains authoritative")

	print("--- EX) discard safety tile-index snapshot reuse ---")
	scene.players[0]["hand"] = ["4W", "1W", "2W", "3W", "5W", "6W", "7W", "8W", "9W", "E", "S", "W", "N"]
	scene.players[1]["discards"] = ["1W", "7W"]
	var safety_visible_240: Array = scene.make_empty_tile_counts()
	safety_visible_240[scene.tile_index("4W")] = 2
	var safety_context_240: Dictionary = scene.make_ai_evaluation_context(0, safety_visible_240)
	var safety_index_240: int = scene.tile_index("4W")
	var safety_fallback_240: String = scene.tile_safety_label("4W", 0, safety_visible_240, safety_context_240)
	var safety_snapshot_240: String = scene.tile_safety_label("4M", 0, safety_visible_240, safety_context_240, safety_index_240)
	check(safety_snapshot_240 == safety_fallback_240, "explicit safety-label index preserves normalized aliases")
	check(scene.is_suji_safe_tile("4M", 0, safety_context_240, safety_index_240) == scene.is_suji_safe_tile("4W", 0, safety_context_240), "suji safety consumes the explicit tile index")
	check(scene.is_kabe_safe_tile("4M", 0, safety_visible_240, safety_context_240, safety_index_240) == scene.is_kabe_safe_tile("4W", 0, safety_visible_240, safety_context_240), "kabe safety retains the explicit tile index")
	var safety_invalid_240: String = scene.tile_safety_label("ZZ", 0, safety_visible_240, safety_context_240, -1)
	check(safety_invalid_240 == scene.tile_safety_label("ZZ", 0, safety_visible_240, safety_context_240), "invalid safety tiles keep the legacy fallback")

	print("--- EY) discard-pressure tile-index snapshot reuse ---")
	scene.players[0]["hand"] = ["4W", "1W", "2W", "3W", "5W", "6W", "7W", "8W", "9W", "E", "S", "W", "N"]
	scene.players[1]["discards"] = ["4W", "5W"]
	var pressure_visible_241: Array = scene.make_empty_tile_counts()
	pressure_visible_241[scene.tile_index("4W")] = 2
	var pressure_context_241: Dictionary = scene.make_ai_evaluation_context(0, pressure_visible_241)
	var pressure_index_241: int = scene.tile_index("4W")
	var pressure_fallback_241: float = scene.discard_pressure_score("4W", 0, pressure_visible_241, pressure_context_241)
	var pressure_explicit_241: float = scene.discard_pressure_score("4M", 0, pressure_visible_241, pressure_context_241, pressure_index_241)
	check(is_equal_approx(pressure_explicit_241, pressure_fallback_241), "explicit discard-pressure index preserves normalized aliases")
	var pressure_invalid_241: float = scene.discard_pressure_score("ZZ", 0, pressure_visible_241, pressure_context_241, -1)
	check(is_equal_approx(pressure_invalid_241, scene.discard_pressure_score("ZZ", 0, pressure_visible_241, pressure_context_241)), "invalid discard-pressure tiles keep the legacy fallback")

	print("--- EZ) feed-risk tile-index snapshot reuse ---")
	scene.players[1]["melds"] = [["4W", "4W", "4W"]]
	var feed_visible_242: Array = scene.make_empty_tile_counts()
	var feed_context_242: Dictionary = scene.make_ai_evaluation_context(0, feed_visible_242)
	var feed_index_242: int = scene.tile_index("4W")
	var feed_fallback_242: Dictionary = scene.discard_feed_risk_report("4W", 0, feed_visible_242, feed_context_242)
	var feed_explicit_242: Dictionary = scene.discard_feed_risk_report("4M", 0, feed_visible_242, feed_context_242, feed_index_242)
	check(is_equal_approx(float(feed_explicit_242.get("score", 0.0)), float(feed_fallback_242.get("score", 0.0))) and feed_explicit_242.get("details", []) == feed_fallback_242.get("details", []), "explicit feed-risk index preserves the report")
	var feed_invalid_242: Dictionary = scene.discard_feed_risk_report("ZZ", 0, feed_visible_242, feed_context_242, -1)
	check(is_equal_approx(float(feed_invalid_242.get("score", 0.0)), float(scene.discard_feed_risk_report("ZZ", 0, feed_visible_242, feed_context_242).get("score", 0.0))), "invalid feed-risk tiles keep the legacy fallback")

	print("--- FA) risk-vector tile-index snapshot reuse ---")
	var risk_visible_243: Array = scene.make_empty_tile_counts()
	risk_visible_243[scene.tile_index("4W")] = 2
	var risk_context_243: Dictionary = scene.make_ai_evaluation_context(0, risk_visible_243)
	var risk_index_243: int = scene.tile_index("4W")
	var risk_fallback_243: Dictionary = scene.tile_risk_vector("4W", 0, risk_visible_243, risk_context_243)
	var risk_explicit_243: Dictionary = scene.tile_risk_vector("4M", 0, risk_visible_243, risk_context_243, risk_index_243)
	check(is_equal_approx(float(risk_explicit_243.get("score", 0.0)), float(risk_fallback_243.get("score", 0.0))) and is_equal_approx(float(risk_explicit_243.get("threat", 0.0)), float(risk_fallback_243.get("threat", 0.0))), "explicit risk-vector index preserves score and threat")
	var deal_risk_explicit_243: float = scene.deal_in_risk_score("4M", 0, risk_context_243, risk_visible_243, risk_index_243)
	var deal_risk_fallback_243: float = scene.deal_in_risk_score("4W", 0, risk_context_243, risk_visible_243)
	check(is_equal_approx(deal_risk_explicit_243, deal_risk_fallback_243), "deal-in risk forwards the explicit candidate index")
	var risk_invalid_243: Dictionary = scene.tile_risk_vector("ZZ", 0, risk_visible_243, risk_context_243, -1)
	check(is_equal_approx(float(risk_invalid_243.get("score", 0.0)), float(scene.tile_risk_vector("ZZ", 0, risk_visible_243, risk_context_243).get("score", 0.0))), "invalid risk-vector tiles keep the legacy fallback")

	print("--- FB) honor-route statistics reuse ---")
	var dragon_counts_244: Array = scene.tile_counts(["Z", "Z", "Z", "F", "F", "F", "P", "P", "1W", "2W"])
	var dragon_stats_244: Dictionary = scene.honor_group_stats_from_counts(dragon_counts_244, scene.DRAGON_CODES)
	var dragon_score_244: float = scene.honor_route_score_from_counts(dragon_counts_244, scene.DRAGON_CODES)
	check(is_equal_approx(dragon_score_244, scene.honor_route_score_from_stats(dragon_stats_244, scene.DRAGON_CODES.size())), "honor route score preserves the shared statistics result")
	var dragon_report_244: Dictionary = scene.honor_group_plan_report_from_counts(dragon_counts_244, scene.DRAGON_CODES, "Big dragons", "Small dragons")
	check(str(dragon_report_244.get("label", "")) == "Small dragons" and int(dragon_report_244.get("progress", 0)) == 5, "dragon route report preserves label and progress")
	check(is_equal_approx(float(dragon_report_244.get("score", 0.0)), dragon_score_244), "dragon route report preserves its score")
	var wind_counts_244: Array = scene.tile_counts(["E", "E", "E", "S", "S", "S", "N", "N", "N", "R", "R"])
	var wind_stats_244: Dictionary = scene.honor_group_stats_from_counts(wind_counts_244, scene.WIND_CODES)
	var wind_report_244: Dictionary = scene.honor_group_plan_report_from_counts(wind_counts_244, scene.WIND_CODES, "Big winds", "Small winds")
	check(is_equal_approx(scene.honor_route_score_from_counts(wind_counts_244, scene.WIND_CODES), scene.honor_route_score_from_stats(wind_stats_244, scene.WIND_CODES.size())), "wind route score preserves the shared statistics result")
	check(str(wind_report_244.get("label", "")) == "Small winds" and int(wind_report_244.get("progress", 0)) == 7, "wind route report preserves label and progress")
	var low_counts_244: Array = scene.tile_counts(["Z", "F", "P"])
	check(scene.honor_group_plan_report_from_counts(low_counts_244, scene.DRAGON_CODES, "Big dragons", "Small dragons").is_empty(), "insufficient honor progress keeps the empty report")

	print("--- FC) human-target pressure tile-index reuse ---")
	scene.players[0]["melds"] = [["4W", "4W", "4W"]]
	scene.players[0]["discards"] = ["1W", "7W"]
	var target_visible_245: Array = scene.make_empty_tile_counts()
	var target_index_245: int = scene.tile_index("4W")
	target_visible_245[target_index_245] = 2
	var target_context_245: Dictionary = scene.make_ai_evaluation_context(1, target_visible_245)
	var target_feed_245: Dictionary = {"details": [{"opponent": 0, "score": 14.0}]}
	var target_fallback_245: float = scene.human_target_discard_pressure(1, "4W", 24.0, target_feed_245, 2, target_context_245)
	var target_explicit_245: float = scene.human_target_discard_pressure(1, "4M", 24.0, target_feed_245, 2, target_context_245, target_index_245)
	check(is_equal_approx(target_explicit_245, target_fallback_245), "human-target pressure preserves normalized aliases")
	var target_penalty_fallback_245: float = scene.human_target_discard_penalty(1, "4W", 24.0, target_feed_245, 2, target_context_245)
	var target_penalty_explicit_245: float = scene.human_target_discard_penalty(1, "4M", 24.0, target_feed_245, 2, target_context_245, target_index_245)
	check(is_equal_approx(target_penalty_explicit_245, target_penalty_fallback_245), "human-target penalty forwards the candidate index")
	var target_fast_pressure_245: Dictionary = scene.ai_context_pressure_context(1, target_context_245)
	var target_fast_report_245: Dictionary = scene.build_ai_fast_post_claim_discard_report(1, "4M", 0, target_fast_pressure_245, target_context_245, scene.make_empty_tile_counts(), target_visible_245, target_index_245)
	check(int(target_fast_report_245.get("tile_index", -2)) == target_index_245, "post-claim fast reports retain the candidate index")
	var target_invalid_fallback_245: float = scene.human_target_discard_pressure(1, "ZZ", 0.0, {}, 2, target_context_245)
	var target_invalid_explicit_245: float = scene.human_target_discard_pressure(1, "ZZ", 0.0, {}, 2, target_context_245, -1)
	check(is_equal_approx(target_invalid_explicit_245, target_invalid_fallback_245), "invalid candidate keeps the legacy pressure fallback")

	print("--- FD) claim pressure feed snapshot reuse ---")
	scene.players[0]["melds"] = [["4W", "4W", "4W"]]
	scene.players[0]["discards"] = ["1W", "7W"]
	var claim_target_visible_246: Array = scene.make_empty_tile_counts()
	var claim_target_index_246: int = scene.tile_index("4W")
	claim_target_visible_246[claim_target_index_246] = 2
	var claim_target_context_246: Dictionary = scene.make_ai_evaluation_context(1, claim_target_visible_246)
	var claim_target_feed_246: Dictionary = {"details": [
		{"opponent": 0, "score": 14.0},
		{"opponent": 2, "score": 31.0},
	]}
	var claim_pressure_fallback_246: float = scene.human_target_discard_pressure(1, "4W", 24.0, claim_target_feed_246, 2, claim_target_context_246)
	var claim_pressure_snapshot_246: float = scene.human_target_discard_pressure(1, "4M", 24.0, claim_target_feed_246, 2, claim_target_context_246, claim_target_index_246, 14.0)
	check(is_equal_approx(claim_pressure_snapshot_246, claim_pressure_fallback_246), "feed-score snapshot preserves human-target pressure")
	var claim_pressure_report_246: Dictionary = {
		"discard": "4M",
		"tile_index": claim_target_index_246,
		"risk": 24.0,
		"safety": "筋",
		"feed_report": claim_target_feed_246,
	}
	var claim_difficulty_246: int = int(claim_target_context_246.get("discard_report_difficulty", -1))
	var claim_expected_feed_246: float = max(14.0, scene.human_target_discard_penalty_from_pressure(claim_pressure_fallback_246, claim_difficulty_246) * 0.55)
	var claim_discipline_246: Dictionary = scene.human_claim_discipline_report(1, "chi", 0, 2, 2, 0.0, claim_pressure_report_246, 0, claim_target_context_246)
	check(is_equal_approx(float(claim_discipline_246.get("feed_human", -1.0)), claim_expected_feed_246), "claim discipline keeps the single pressure result")
	check(str(claim_discipline_246.get("reason", "")) != "", "claim discipline still publishes a decision reason")

	print("--- FE) quiet discard risk-vector index forwarding ---")
	var fast_source_247 := FileAccess.get_file_as_string("res://scripts/main_src/ai_brain.gd.part")
	check(fast_source_247.contains("tile_risk_vector(cand, seat, visible_counts_snapshot, eval_context, idx)"), "quiet discard evaluation forwards its captured candidate index")
	scene.offline_all_bot_mode = true
	scene.offline_sim_quiet = true
	scene.players[1]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "2T", "3T", "E"]
	var fast_context_output_247: Dictionary = {}
	var fast_reports_247: Array = scene.get_ai_discard_reports(1, [], fast_context_output_247)
	check(fast_reports_247.size() > 0, "quiet discard evaluation still produces candidate reports")
	if not fast_reports_247.is_empty():
		var fast_report_247: Dictionary = fast_reports_247[0]
		var fast_tile_247 := str(fast_report_247.get("tile", ""))
		var fast_index_247 := int(fast_report_247.get("tile_index", -1))
		var fast_visible_247: Array = scene.ai_context_visible_counts(fast_context_output_247)
		var fast_risk_247: Dictionary = scene.tile_risk_vector(fast_tile_247, 1, fast_visible_247, fast_context_output_247, fast_index_247)
		check(fast_index_247 >= 0 and is_equal_approx(float(fast_report_247.get("risk", -1.0)), float(fast_risk_247.get("score", -2.0))), "quiet report risk remains aligned with the forwarded index")

	print("--- FF) tsumo continuation risk index forwarding ---")
	var tsumo_source_248 := FileAccess.get_file_as_string("res://scripts/main_src/ai_brain.gd.part")
	check(tsumo_source_248.contains("deal_in_risk_score(normalized_drawn_tile, seat, continue_eval_context, continue_visible_counts, drawn_index)"), "tsumo continuation forwards the normalized drawn index to deal-in risk")
	check(tsumo_source_248.contains("discard_feed_risk_report(normalized_drawn_tile, seat, continue_visible_counts, continue_eval_context, drawn_index)"), "tsumo continuation forwards the normalized drawn index to feed risk")
	scene.offline_sim_quiet = true
	scene.offline_all_bot_mode = false
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	scene.current_seat = 3
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.offline_last_draw = {"seat": 3, "tile": "2W", "source": "normal", "wall_empty": false, "serial": 248}
	scene.offline_self_draw_ready = {"seat": 3, "tile": "2W", "serial": 248}
	scene.players[3]["hand"] = ["2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "9W", "9W", "2T", "3T", "4T", "2W"]
	var tsumo_decision_248: Dictionary = scene.ai_tsumo_decision_report(3, "2W")
	check(bool(tsumo_decision_248.get("win_valid", false)) and tsumo_decision_248.has("reason"), "tsumo continuation keeps a valid decision report")
	var tsumo_visible_248: Array = scene.visible_tile_counts_shared()
	var tsumo_context_248: Dictionary = scene.make_ai_evaluation_context(3, tsumo_visible_248)
	var tsumo_index_248: int = scene.tile_index_normalized("2W")
	var tsumo_risk_248: float = scene.deal_in_risk_score("2W", 3, tsumo_context_248, tsumo_visible_248, tsumo_index_248)
	var tsumo_feed_248: Dictionary = scene.discard_feed_risk_report("2W", 3, tsumo_visible_248, tsumo_context_248, tsumo_index_248)
	check(tsumo_index_248 >= 0 and tsumo_risk_248 >= 0.0 and typeof(tsumo_feed_248) == TYPE_DICTIONARY, "explicit continuation index keeps bounded risk outputs")

	print("--- FG) threat-card risk-vector index forwarding ---")
	var threat_card_source_249 := FileAccess.get_file_as_string("res://scripts/main_src/core.gd.part")
	check(threat_card_source_249.contains("tile_risk_vector(tile, seat, visible_counts, eval_context, tile_index_snapshot)"), "general threat cards forward the captured candidate index")
	scene.offline_sim_quiet = true
	scene.players[0]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "2T", "3T", "E"]
	scene.players[1]["discards"] = ["1W", "7W"]
	var threat_card_visible_249: Array = scene.make_empty_tile_counts()
	threat_card_visible_249[scene.tile_index("4W")] = 2
	var threat_card_context_249: Dictionary = scene.make_ai_evaluation_context(0, threat_card_visible_249)
	var threat_card_labels_249: Array = scene.threat_safe_tile_labels(0, "suit", 0, 3, threat_card_context_249)
	check(threat_card_labels_249.size() > 0 and threat_card_labels_249.size() <= 3, "general threat cards still return a bounded safe-tile list")
	var threat_card_repeat_249: Array = scene.threat_safe_tile_labels(0, "suit", 0, 3, threat_card_context_249)
	check(threat_card_repeat_249 == threat_card_labels_249, "general threat-card ranking remains deterministic after index forwarding")

	print("--- FH) claim feed-report fallback index forwarding ---")
	var claim_fallback_source_250 := FileAccess.get_file_as_string("res://scripts/main_src/ai_brain.gd.part")
	check(claim_fallback_source_250.contains("discard_feed_risk_report(forced_tile, seat, claim_visible_counts, eval_context, forced_tile_index)"), "claim discipline forwards the forced tile index on feed-report fallback")
	scene.offline_all_bot_mode = true
	scene.offline_sim_quiet = true
	scene.players[0]["melds"] = [["4W", "4W", "4W"]]
	scene.players[0]["discards"] = ["1W", "7W"]
	var claim_fallback_visible_250: Array = scene.make_empty_tile_counts()
	var claim_fallback_index_250: int = scene.tile_index("4W")
	claim_fallback_visible_250[claim_fallback_index_250] = 2
	var claim_fallback_context_250: Dictionary = scene.make_ai_evaluation_context(1, claim_fallback_visible_250)
	var claim_fallback_pressure_250: Dictionary = {"discard": "4W", "tile_index": claim_fallback_index_250, "risk": 24.0, "safety": "筋", "feed_report": {}}
	var claim_explicit_feed_250: Dictionary = scene.discard_feed_risk_report("4W", 1, claim_fallback_visible_250, claim_fallback_context_250, claim_fallback_index_250)
	var claim_snapshot_pressure_250: Dictionary = claim_fallback_pressure_250.duplicate(true)
	claim_snapshot_pressure_250["feed_report"] = claim_explicit_feed_250
	var claim_fallback_report_250: Dictionary = scene.human_claim_discipline_report(1, "chi", 0, 2, 2, 0.0, claim_fallback_pressure_250, 0, claim_fallback_context_250)
	var claim_snapshot_report_250: Dictionary = scene.human_claim_discipline_report(1, "chi", 0, 2, 2, 0.0, claim_snapshot_pressure_250, 0, claim_fallback_context_250)
	check(is_equal_approx(float(claim_fallback_report_250.get("feed_human", -1.0)), float(claim_snapshot_report_250.get("feed_human", -2.0))), "claim feed fallback preserves the feed-human score")
	check(bool(claim_fallback_report_250.get("decline", false)) == bool(claim_snapshot_report_250.get("decline", true)) and str(claim_fallback_report_250.get("reason", "")) == str(claim_snapshot_report_250.get("reason", "")), "claim feed fallback preserves the decision")

	print("--- FI) danger-source reason index forwarding ---")
	var danger_reason_source_251 := FileAccess.get_file_as_string("res://scripts/main_src/ai_brain.gd.part")
	var danger_reason_gameplay_251 := FileAccess.get_file_as_string("res://scripts/main_src/gameplay.gd.part")
	check(danger_reason_source_251.contains("discard_danger_reason(tile, seat, best_opponent, eval_context, index)"), "risk vectors forward their captured index to danger-source reasons")
	check(danger_reason_gameplay_251.contains("visible_tile_count_from_counts(tile, visible_counts, index)"), "danger-source reasons reuse the supplied tile index for visibility")
	scene.players[1]["melds"] = [["4W", "4W", "4W"]]
	scene.players[1]["discards"] = []
	var danger_visible_251: Array = scene.make_empty_tile_counts()
	var danger_index_251: int = scene.tile_index("4W")
	danger_visible_251[danger_index_251] = 1
	var danger_context_251: Dictionary = scene.make_ai_evaluation_context(0, danger_visible_251)
	var danger_fallback_251: String = scene.discard_danger_reason("4W", 0, 1, danger_context_251)
	var danger_explicit_251: String = scene.discard_danger_reason("4M", 0, 1, danger_context_251, danger_index_251)
	check(danger_explicit_251 == danger_fallback_251 and danger_explicit_251 != "", "danger-source reason preserves normalized aliases with the explicit index")

	print("--- FJ) quiet discard safety tie index reuse ---")
	var fast_sort_source_252 := FileAccess.get_file_as_string("res://scripts/main_src/ai_brain.gd.part")
	check(fast_sort_source_252.contains('var safest_index := int(safest_candidate.get("tile_index", -1))'), "quiet safety tie-break reads the saved candidate index")
	check(not fast_sort_source_252.contains("tile_sort_index(cand)"), "quiet safety tie-break avoids reparsing the candidate tile")
	var canonical_sort_order_252 := true
	for code in scene.TILE_CODES:
		var canonical_code := str(code)
		if scene.tile_sort_index(canonical_code) != scene.tile_index_normalized(canonical_code):
			canonical_sort_order_252 = false
			break
	check(canonical_sort_order_252, "canonical candidate indexes preserve tile sort order")
	check(scene.tile_sort_index("4M") == scene.tile_index_normalized("4W"), "normalized aliases preserve the candidate sort index")
	scene.offline_all_bot_mode = true
	scene.offline_sim_quiet = true
	scene.players[1]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "2T", "3T", "E"]
	var fast_sort_context_output_252: Dictionary = {}
	var fast_sort_reports_252: Array = scene.get_ai_discard_reports(1, [], fast_sort_context_output_252)
	check(fast_sort_reports_252.size() > 0, "quiet discard fast evaluation still returns reports")
	var fast_sort_indexes_valid_252 := true
	for report_value in fast_sort_reports_252:
		if typeof(report_value) != TYPE_DICTIONARY:
			fast_sort_indexes_valid_252 = false
			break
		var report_252: Dictionary = report_value
		var report_tile_252 := str(report_252.get("tile", ""))
		var report_index_252 := int(report_252.get("tile_index", -1))
		if report_index_252 < 0 or report_index_252 >= scene.TILE_CODES.size() or report_index_252 != scene.tile_index(report_tile_252):
			fast_sort_indexes_valid_252 = false
			break
	check(fast_sort_indexes_valid_252, "quiet reports retain canonical indexes for safety ranking")

	print("--- FK) scoring-meld first-tile index reuse ---")
	var scoring_meld_source_253 := FileAccess.get_file_as_string("res://scripts/main_src/core.gd.part")
	check(scoring_meld_source_253.contains("var first_index := -1"), "scoring-meld validation captures the first index in its single pass")
	check(not scoring_meld_source_253.contains('var first_index = tile_index(str(meld[0]))'), "scoring-meld validation avoids the duplicate first-tile lookup")
	check(scene.is_valid_scoring_meld(["4W", "4W", "4W"]), "triplet validation preserves valid scoring melds")
	check(scene.is_valid_scoring_meld(["4M", "5M", "6M"]), "sequence validation preserves normalized aliases")
	check(not scene.is_valid_scoring_meld(["4W", "5W", "6T"]), "mixed-suit sequences remain invalid")
	check(not scene.is_valid_scoring_meld(["ZZ", "ZZ", "ZZ"]), "invalid scoring meld tiles remain rejected")

	print("--- FL) exposed full-straight first-tile index reuse ---")
	var straight_source_254 := FileAccess.get_file_as_string("res://scripts/main_src/core.gd.part")
	check(straight_source_254.contains("full_straight_open_meld_group(meld, meld_suit, meld_first_index)"), "full-straight detection forwards the existing first-tile index")
	check(straight_source_254.contains("first_index_snapshot: int = -2"), "exposed-meld grouping keeps a direct-call fallback")
	var straight_meld_254: Array = ["1W", "2W", "3W"]
	var straight_first_index_254: int = scene.tile_index("1W")
	var straight_fallback_254: int = scene.full_straight_open_meld_group(straight_meld_254, 0)
	var straight_explicit_254: int = scene.full_straight_open_meld_group(["1M", "2M", "3M"], 0, straight_first_index_254)
	check(straight_fallback_254 == 0 and straight_explicit_254 == straight_fallback_254, "exposed sequence grouping preserves normalized aliases")
	check(scene.full_straight_open_meld_group(["4W", "4W", "4W"], 0, scene.tile_index("4W")) == -1, "triplet melds remain outside sequence groups")
	check(scene.full_straight_open_meld_group(["1W", "2W", "3T"], 0, straight_first_index_254) == -1, "mixed-suit exposed melds remain rejected")

	print("--- FM) discard route tile classification reuse ---")
	var route_source_255 := FileAccess.get_file_as_string("res://scripts/main_src/core.gd.part")
	var reason_source_255 := FileAccess.get_file_as_string("res://scripts/main_src/gameplay.gd.part")
	check(route_source_255.contains("tile_index_snapshot: int = -2"), "route offcut classification accepts an index snapshot")
	check(reason_source_255.contains("is_plan_offcut(tile, report, original_hand, original_counts_snapshot, tile_index_snapshot)"), "discard reasons forward the candidate index to route classification")
	var route_index_255: int = scene.tile_index("4W")
	var route_report_255: Dictionary = {"plan_label": "清一色", "plan_suit": 1, "tile_index": route_index_255}
	var indexed_route_reason_255: String = scene.discard_reason_label("ZZ", [], route_report_255)
	check(indexed_route_reason_255 == "保路线", "report tile indexes classify canonical route offcuts")
	var route_fallback_report_255: Dictionary = {"plan_label": "清一色", "plan_suit": 1}
	var fallback_route_reason_255: String = scene.discard_reason_label("4W", [], route_fallback_report_255)
	var explicit_route_reason_255: String = scene.discard_reason_label("4M", [], route_fallback_report_255, [], route_index_255)
	check(explicit_route_reason_255 == fallback_route_reason_255, "explicit route indexes preserve normalized aliases")
	var simple_report_255: Dictionary = {"plan_label": "断幺九", "tile_index": scene.tile_index("4W")}
	check(not scene.is_plan_offcut("ZZ", simple_report_255) and not scene.is_plan_offcut("4W", simple_report_255), "route classification keeps non-offcut simple-number behavior")

	print("--- FN) furiten probe count-vector reuse ---")
	var furiten_source_256 := FileAccess.get_file_as_string("res://scripts/main_src/gameplay.gd.part")
	check(furiten_source_256.contains("var candidate_counts := hand_counts.duplicate()"), "furiten probes allocate one reusable count vector")
	check(furiten_source_256.contains("candidate_counts[index] = int(candidate_counts[index]) - 1"), "furiten probes restore the candidate slot")
	check(not furiten_source_256.contains("var candidate_counts = hand_counts.duplicate()"), "furiten probes avoid per-discard vector copies")
	var furiten_counts_256: Array = scene.tile_counts(["2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "2T", "3T", "4T"])
	var furiten_counts_before_256: Array = furiten_counts_256.duplicate()
	scene.players[0]["hand"] = scene.tiles_from_counts(furiten_counts_256)
	scene.players[0]["discards"] = ["1W", "4W", "1W"]
	var furiten_result_256: bool = scene.is_discard_furiten_from_counts(0, furiten_counts_256, scene.players[0]["hand"].size())
	check(furiten_result_256 == scene.is_discard_furiten_from_counts(0, furiten_counts_256, scene.players[0]["hand"].size()), "furiten cache preserves repeated probe results")
	check(furiten_counts_256 == furiten_counts_before_256, "furiten probes keep the caller count vector unchanged")

	print("--- FO) scoring inventory meld normalization reuse ---")
	var scoring_inventory_source_257 := FileAccess.get_file_as_string("res://scripts/main_src/core.gd.part")
	var scoring_inventory_start_257 := scoring_inventory_source_257.find("func has_valid_scoring_tile_inventory_from_counts")
	var scoring_inventory_end_257 := scoring_inventory_source_257.find("func is_valid_scoring_meld", scoring_inventory_start_257)
	var scoring_inventory_function_257 := scoring_inventory_source_257.substr(scoring_inventory_start_257, scoring_inventory_end_257 - scoring_inventory_start_257)
	check(scoring_inventory_source_257.contains("var normalized_code := normalize_tile_code(str(item))"), "scoring inventory normalizes each meld tile once")
	check(scoring_inventory_source_257.contains("var index := int(tile_order.get(normalized_code, -1))"), "scoring inventory resolves the normalized index directly")
	check(not scoring_inventory_function_257.contains("is_tile_enabled_for_rule("), "scoring inventory avoids the duplicate rule normalization")
	var scoring_inventory_counts_257: Array = scene.tile_counts(["1W", "2W"])
	scene.players[0]["melds"] = [["4M", "5M", "6M"]]
	check(scene.has_valid_scoring_tile_inventory_from_counts(0, scoring_inventory_counts_257, 2), "legacy suit aliases remain accepted for enabled meld tiles")
	var scoring_inventory_repeat_257: bool = scene.has_valid_scoring_tile_inventory_from_counts(0, scoring_inventory_counts_257, 2)
	check(scoring_inventory_repeat_257, "normalized inventory validation remains stable across repeated calls")
	scene.players[0]["melds"] = [["H1", "H1", "H1"]]
	check(not scene.has_valid_scoring_tile_inventory_from_counts(0, scoring_inventory_counts_257, 2), "flower meld tiles remain outside the scoring inventory")
	scene.players[0]["melds"] = [["4W", "5W", "6W"]]
	scene.offline_active_rule_variant = scene.RULE_VARIANT_SICHUAN
	check(scene.has_valid_scoring_tile_inventory_from_counts(0, scoring_inventory_counts_257, 2), "enabled suited melds remain valid under a restricted rule")
	scene.players[0]["melds"] = [["E", "E", "E"]]
	check(not scene.has_valid_scoring_tile_inventory_from_counts(0, scoring_inventory_counts_257, 2), "rule-disabled honor melds remain rejected")

	print("--- FP) combined scoring validation count snapshot ---")
	var scoring_validation_source_258 := FileAccess.get_file_as_string("res://scripts/main_src/core.gd.part")
	var scoring_validation_start_258 := scoring_validation_source_258.find("func calculate_win_score_from_tiles")
	var scoring_validation_end_258 := scoring_validation_source_258.find("func is_last_draw_context", scoring_validation_start_258)
	var scoring_validation_score_source_258 := scoring_validation_source_258.substr(scoring_validation_start_258, scoring_validation_end_258 - scoring_validation_start_258)
	check(scoring_validation_source_258.contains("func validated_scoring_tile_counts_from_counts"), "scoring validation exposes a combined count snapshot helper")
	check(scoring_validation_score_source_258.contains("scoring_counts = validated_scoring_tile_counts_from_counts(seat, hand_counts, canonical_tile_count)"), "normal scoring uses the combined validation pass")
	check(not scoring_validation_score_source_258.contains("has_valid_scoring_melds(seat) or not has_valid_scoring_tile_inventory_from_counts"), "normal scoring avoids separate meld and inventory scans")
	var scoring_validation_concealed_258: Array = ["1W", "2W", "3W", "7W", "8W", "9W", "1T", "2T", "3T", "E", "E"]
	var scoring_validation_counts_258: Array = scene.tile_counts(scoring_validation_concealed_258)
	scene.offline_active_rule_variant = scene.RULE_VARIANT_YANGZHOU
	scene.players[0]["hand"] = scoring_validation_concealed_258.duplicate()
	scene.players[0]["melds"] = [["4M", "5M", "6M"]]
	var scoring_validation_combined_258: Array = scene.validated_scoring_tile_counts_from_counts(0, scoring_validation_counts_258, scoring_validation_concealed_258.size())
	var scoring_validation_legacy_258: Array = scene.scoring_tile_counts_from_counts(0, scoring_validation_counts_258)
	check(scoring_validation_combined_258 == scoring_validation_legacy_258, "combined scoring counts preserve normalized meld aliases")
	var scoring_validation_score_258: Dictionary = scene.calculate_win_score_from_tiles(0, scoring_validation_concealed_258, false)
	check(int(scoring_validation_score_258.get("points", 0)) > 0 and int(scoring_validation_score_258.get("fan", 0)) > 0, "valid open hand still receives a paid score")
	scene.players[0]["melds"] = [["4W", "5W", "7W"]]
	check(scene.validated_scoring_tile_counts_from_counts(0, scoring_validation_counts_258, scoring_validation_concealed_258.size()).is_empty(), "malformed sequence melds remain rejected by the combined pass")
	check(int(scene.calculate_win_score_from_tiles(0, scoring_validation_concealed_258, false).get("points", 0)) == 0, "malformed melds cannot produce a paid score")
	scene.players[0]["melds"] = [["4W", "4W", "4W", "4W"]]
	var scoring_validation_over_limit_258: Array = scoring_validation_counts_258.duplicate()
	scoring_validation_over_limit_258[scene.tile_index("4W")] = 1
	scoring_validation_over_limit_258[scene.tile_index("1W")] = 0
	check(scene.validated_scoring_tile_counts_from_counts(0, scoring_validation_over_limit_258, scoring_validation_concealed_258.size()).is_empty(), "combined inventory still enforces the four-copy limit")

	print("--- FQ) fallback opponent threat tile-index reuse ---")
	var fallback_threat_source_259 := FileAccess.get_file_as_string("res://scripts/main_src/ai_brain.gd.part")
	var fallback_threat_start_259 := fallback_threat_source_259.find("func opponent_tile_threat_score")
	var fallback_threat_end_259 := fallback_threat_source_259.find("func opponent_pattern_threat_score", fallback_threat_start_259)
	var fallback_threat_function_259 := fallback_threat_source_259.substr(fallback_threat_start_259, fallback_threat_end_259 - fallback_threat_start_259)
	check(fallback_threat_function_259.contains("var tile_index_snapshot := tile_index(tile)"), "fallback threat scoring captures the tile index once")
	check(fallback_threat_function_259.contains("visible_tile_count_from_counts(tile, known_counts, tile_index_snapshot)"), "fallback threat scoring forwards the captured index")
	check(fallback_threat_function_259.contains("if not risk_vector.is_empty():"), "precomputed risk vectors keep their early return")
	scene.players[1]["melds"] = [["4W", "5W", "6W"]]
	scene.players[1]["discards"] = ["9B"]
	var fallback_threat_visible_259: Array = scene.make_empty_tile_counts()
	var fallback_threat_canonical_context_259: Dictionary = scene.make_ai_evaluation_context(0, fallback_threat_visible_259)
	var fallback_threat_alias_context_259: Dictionary = scene.make_ai_evaluation_context(0, fallback_threat_visible_259)
	var fallback_threat_canonical_259: float = scene.opponent_tile_threat_score("4W", 0, fallback_threat_visible_259, {}, fallback_threat_canonical_context_259)
	var fallback_threat_alias_259: float = scene.opponent_tile_threat_score("4M", 0, fallback_threat_visible_259, {}, fallback_threat_alias_context_259)
	check(is_equal_approx(fallback_threat_alias_259, fallback_threat_canonical_259), "normalized aliases preserve fallback threat scoring")
	check(is_equal_approx(scene.opponent_tile_threat_score("ZZ", 0, fallback_threat_visible_259, {}, {}), 0.0), "invalid fallback threat tiles retain the zero result")
	check(is_equal_approx(scene.opponent_tile_threat_score("4W", 0, fallback_threat_visible_259, {"threat": 17.5}, {}), 17.5), "precomputed risk vectors retain the threat fast path")

	print("--- FR) shared scoring suit-profile scan ---")
	var scoring_profile_source_260 := FileAccess.get_file_as_string("res://scripts/main_src/core.gd.part")
	var scoring_profile_start_260 := scoring_profile_source_260.find("func calculate_win_score_from_tiles")
	var scoring_profile_end_260 := scoring_profile_source_260.find("func is_last_draw_context", scoring_profile_start_260)
	var scoring_profile_score_source_260 := scoring_profile_source_260.substr(scoring_profile_start_260, scoring_profile_end_260 - scoring_profile_start_260)
	check(scoring_profile_source_260.contains("func scoring_tile_profile_from_counts"), "scoring patterns expose a shared count profile")
	check(scoring_profile_score_source_260.contains("var scoring_profile := scoring_tile_profile_from_counts(scoring_counts)"), "win scoring builds one shared suit profile")
	check(not scoring_profile_score_source_260.contains("is_all_honor_from_counts(scoring_counts)"), "win scoring avoids the separate honor scan")
	check(not scoring_profile_score_source_260.contains("is_pure_one_suit_from_counts(scoring_counts)"), "win scoring avoids the separate pure-suit scan")
	check(not scoring_profile_score_source_260.contains("is_mixed_one_suit_from_counts(scoring_counts)"), "win scoring avoids the separate mixed-suit scan")
	check(not scoring_profile_score_source_260.contains("is_all_simples_from_counts(scoring_counts)"), "win scoring avoids the separate simples scan")
	var scoring_profile_cases_260: Array = [
		["honors", ["E", "S", "N", "R"]],
		["pure", ["1W", "2W", "3W", "4W"]],
		["mixed", ["2W", "3W", "4W", "E"]],
		["simples", ["2T", "3T", "4T", "5T"]],
		["terminal", ["1B", "2B", "3B"]],
		["multi-suit", ["2W", "3W", "4T", "E"]],
		["empty", []],
	]
	for scoring_profile_case_260 in scoring_profile_cases_260:
		var scoring_profile_counts_260: Array = scene.tile_counts(scoring_profile_case_260[1])
		var scoring_profile_expected_260: Dictionary = {
			"all_honor": scene.is_all_honor_from_counts(scoring_profile_counts_260),
			"pure_one_suit": scene.is_pure_one_suit_from_counts(scoring_profile_counts_260),
			"mixed_one_suit": scene.is_mixed_one_suit_from_counts(scoring_profile_counts_260),
			"all_simples": scene.is_all_simples_from_counts(scoring_profile_counts_260),
		}
		check(scene.scoring_tile_profile_from_counts(scoring_profile_counts_260) == scoring_profile_expected_260, "%s profile preserves the four legacy flags" % str(scoring_profile_case_260[0]))
	var scoring_profile_invalid_counts_260: Array = scene.make_empty_tile_counts()
	scoring_profile_invalid_counts_260.append(1)
	var scoring_profile_invalid_expected_260: Dictionary = {
		"all_honor": scene.is_all_honor_from_counts(scoring_profile_invalid_counts_260),
		"pure_one_suit": scene.is_pure_one_suit_from_counts(scoring_profile_invalid_counts_260),
		"mixed_one_suit": scene.is_mixed_one_suit_from_counts(scoring_profile_invalid_counts_260),
		"all_simples": scene.is_all_simples_from_counts(scoring_profile_invalid_counts_260),
	}
	check(scene.scoring_tile_profile_from_counts(scoring_profile_invalid_counts_260) == scoring_profile_invalid_expected_260, "out-of-range profile values keep legacy flags")

	print("--- FS) effective-tile index snapshot reuse ---")
	var effective_metrics_source_261 := FileAccess.get_file_as_string("res://scripts/main_src/ai_brain.gd.part")
	var effective_metrics_start_261 := effective_metrics_source_261.find("func effective_tile_metrics")
	var effective_metrics_end_261 := effective_metrics_source_261.find("func touch_effective_tiles_cache_key", effective_metrics_start_261)
	var effective_metrics_function_261 := effective_metrics_source_261.substr(effective_metrics_start_261, effective_metrics_end_261 - effective_metrics_start_261)
	var wait_metrics_start_261 := effective_metrics_source_261.find("func wait_value_metrics")
	var wait_metrics_end_261 := effective_metrics_source_261.find("func wait_quality_penalty", wait_metrics_start_261)
	var wait_metrics_function_261 := effective_metrics_source_261.substr(wait_metrics_start_261, wait_metrics_end_261 - wait_metrics_start_261)
	check(effective_metrics_function_261.contains("var tile_indices_by_tile: Dictionary = {}"), "effective metrics capture tile indexes during the scan")
	check(effective_metrics_function_261.contains("\"tile_indices\": tile_indices_by_tile"), "effective metrics publish the index snapshot")
	check(wait_metrics_function_261.contains("effective_tile_indices_snapshot: Dictionary = {}"), "wait valuation accepts an optional index snapshot")
	check(wait_metrics_function_261.contains("effective_tile_indices_snapshot.get(tile, -1)"), "wait valuation reuses captured indexes")
	check(wait_metrics_function_261.contains("tile_index_value = tile_index_normalized(tile)"), "wait valuation keeps the direct-call fallback")
	var tenpai_hand_261: Array = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "1T", "1T", "4T"]
	scene.players[0]["hand"] = tenpai_hand_261.duplicate()
	scene.players[0]["melds"] = []
	scene.players[0]["discards"] = []
	var visible_counts_261: Array = scene.make_empty_tile_counts()
	var hand_counts_261: Array = scene.tile_counts(tenpai_hand_261)
	var effective_metrics_261: Dictionary = scene.effective_tile_metrics(tenpai_hand_261, 0, 0, 0, visible_counts_261, hand_counts_261)
	var effective_tiles_261: Array = effective_metrics_261.get("tiles", [])
	var remaining_261: Dictionary = effective_metrics_261.get("remaining_by_tile", {})
	var indexes_261: Dictionary = effective_metrics_261.get("tile_indices", {})
	check(effective_tiles_261.has("4T"), "tenpai metrics retain the expected winning tile")
	check(int(indexes_261.get("4T", -1)) == scene.tile_index("4T"), "captured index matches the canonical tile order")
	var snapshot_wait_261: Dictionary = scene.wait_value_metrics(0, tenpai_hand_261, 0, 0, effective_tiles_261, remaining_261, true, {}, 1.0, 1.0, hand_counts_261, 0, indexes_261)
	var fallback_wait_261: Dictionary = scene.wait_value_metrics(0, tenpai_hand_261, 0, 0, effective_tiles_261, remaining_261, true, {}, 1.0, 1.0, hand_counts_261, 0)
	check(is_equal_approx(float(snapshot_wait_261.get("score", 0.0)), float(fallback_wait_261.get("score", 0.0))), "index snapshot preserves wait score")
	check(str(snapshot_wait_261.get("best_tile", "")) == str(fallback_wait_261.get("best_tile", "")), "index snapshot preserves best wait")

	print("--- FT) alternate-wait index snapshot reuse ---")
	var alternate_wait_source_262 := FileAccess.get_file_as_string("res://scripts/main_src/ai_brain.gd.part")
	var alternate_ron_start_262 := alternate_wait_source_262.find("func ai_ron_decision_report")
	var alternate_ron_end_262 := alternate_wait_source_262.find("func ai_tsumo_decision_report", alternate_ron_start_262)
	var alternate_ron_source_262 := alternate_wait_source_262.substr(alternate_ron_start_262, alternate_ron_end_262 - alternate_ron_start_262)
	var alternate_tsumo_start_262 := alternate_wait_source_262.find("func ai_tsumo_decision_report")
	var alternate_tsumo_end_262 := alternate_wait_source_262.find("func ai_tsumo_continue_discard", alternate_tsumo_start_262)
	var alternate_tsumo_source_262 := alternate_wait_source_262.substr(alternate_tsumo_start_262, alternate_tsumo_end_262 - alternate_tsumo_start_262)
	check(alternate_ron_source_262.contains("var wait_tile_indices: Dictionary = wait_metrics.get(\"tile_indices\", {})"), "ron captures effective-tile indexes")
	check(alternate_ron_source_262.contains("int(wait_tile_indices.get(wait_tile, -1))"), "ron alternate waits reuse captured indexes")
	check(alternate_tsumo_source_262.contains("var wait_tile_indices: Dictionary = wait_metrics.get(\"tile_indices\", {})"), "tsumo captures effective-tile indexes")
	check(alternate_tsumo_source_262.contains("int(wait_tile_indices.get(wait_tile, -1))"), "tsumo alternate waits reuse captured indexes")
	check(alternate_ron_source_262.contains("wait_index = tile_index_normalized(wait_tile)"), "ron keeps the direct-call fallback")
	check(alternate_tsumo_source_262.contains("wait_index = tile_index_normalized(wait_tile)"), "tsumo keeps the direct-call fallback")
	var alternate_tenpai_262: Array = ["1W", "2W", "3W", "4W", "5W", "6W", "7B", "8B", "9B", "1T", "1T", "2T", "3T"]
	var alternate_counts_262: Array = scene.tile_counts(alternate_tenpai_262)
	var alternate_metrics_262: Dictionary = scene.effective_tile_metrics(alternate_tenpai_262, 0, 1, 0, scene.make_empty_tile_counts(), alternate_counts_262)
	var alternate_waits_262: Array = alternate_metrics_262.get("tiles", [])
	var alternate_indexes_262: Dictionary = alternate_metrics_262.get("tile_indices", {})
	check(alternate_waits_262.has("1T") and alternate_waits_262.has("4T"), "fixture exposes multiple alternate waits")
	check(int(alternate_indexes_262.get("1T", -1)) == scene.tile_index("1T") and int(alternate_indexes_262.get("4T", -1)) == scene.tile_index("4T"), "alternate waits carry canonical indexes")
	scene.offline_phase = "resolving"
	scene.dealer_seat = 0
	scene.offline_passed_win_tiles.clear()
	scene.players[1]["hand"] = alternate_tenpai_262.duplicate()
	scene.players[1]["discards"] = []
	scene.players[1]["melds"] = []
	scene.players[1]["flowers"] = 0
	var alternate_ron_report_262: Dictionary = scene.ai_ron_decision_report(1, "4T")
	check(int(alternate_ron_report_262.get("wait_variety", 0)) >= 2 and int(alternate_ron_report_262.get("points", 0)) > 0, "ron alternate-wait report remains valid")
	var alternate_tsumo_hand_262: Array = alternate_tenpai_262.duplicate()
	alternate_tsumo_hand_262.append("1T")
	scene.current_seat = 3
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.offline_last_draw = {"seat": 3, "tile": "1T", "source": "normal", "wall_empty": false, "serial": 262}
	scene.offline_self_draw_ready = {"seat": 3, "tile": "1T", "serial": 262}
	scene.players[3]["hand"] = alternate_tsumo_hand_262
	scene.players[3]["discards"] = []
	var alternate_tsumo_report_262: Dictionary = scene.ai_tsumo_decision_report(3, "1T")
	check(bool(alternate_tsumo_report_262.get("win_valid", false)) and int(alternate_tsumo_report_262.get("wait_variety", 0)) >= 2, "tsumo alternate-wait report remains valid")

	print("--- FU) wait scoring meld-vector reuse ---")
	var wait_score_core_source_263 := FileAccess.get_file_as_string("res://scripts/main_src/core.gd.part")
	var wait_score_core_start_263 := wait_score_core_source_263.find("func calculate_win_score_from_tiles")
	var wait_score_core_end_263 := wait_score_core_source_263.find("func is_last_draw_context", wait_score_core_start_263)
	var wait_score_core_function_263 := wait_score_core_source_263.substr(wait_score_core_start_263, wait_score_core_end_263 - wait_score_core_start_263)
	var wait_score_ai_source_263 := FileAccess.get_file_as_string("res://scripts/main_src/ai_brain.gd.part")
	var wait_score_ai_start_263 := wait_score_ai_source_263.find("func wait_value_metrics")
	var wait_score_ai_end_263 := wait_score_ai_source_263.find("func wait_quality_penalty", wait_score_ai_start_263)
	var wait_score_ai_function_263 := wait_score_ai_source_263.substr(wait_score_ai_start_263, wait_score_ai_end_263 - wait_score_ai_start_263)
	check(wait_score_core_function_263.contains("scoring_counts_snapshot: Array = []"), "scoring accepts an optional meld-inclusive vector")
	check(wait_score_core_function_263.contains("scoring_counts = scoring_counts_snapshot if scoring_counts_snapshot.size() == TILE_CODES.size() else scoring_tile_counts_from_counts(seat, hand_counts)"), "scoring keeps the vector fallback")
	check(wait_score_ai_function_263.contains("var winning_scoring_counts: Array = []"), "wait valuation prepares one scoring vector")
	check(wait_score_ai_function_263.contains("winning_scoring_counts[tile_index_value] = int(winning_scoring_counts[tile_index_value]) + 1"), "wait valuation mutates only the candidate scoring slot")
	check(wait_score_ai_function_263.contains("next_tile_count, winning_scoring_counts)"), "wait valuation forwards the scoring snapshot")
	var wait_score_hand_263: Array = ["4W", "5W", "6W", "7B", "8B", "9B", "1T", "1T", "2T", "3T"]
	scene.players[1]["hand"] = wait_score_hand_263.duplicate()
	scene.players[1]["melds"] = [["1W", "2W", "3W"]]
	var wait_score_counts_263: Array = scene.tile_counts(wait_score_hand_263)
	var wait_score_visible_263: Array = scene.make_empty_tile_counts()
	var wait_score_metrics_263: Dictionary = scene.effective_tile_metrics(wait_score_hand_263, 1, 1, 0, wait_score_visible_263, wait_score_counts_263)
	var wait_score_waits_263: Array = wait_score_metrics_263.get("tiles", [])
	var wait_score_remaining_263: Dictionary = wait_score_metrics_263.get("remaining_by_tile", {})
	var wait_score_indexes_263: Dictionary = wait_score_metrics_263.get("tile_indices", {})
	check(wait_score_waits_263.has("1T") and wait_score_waits_263.has("4T"), "open tenpai exposes multiple waits")
	check(int(wait_score_indexes_263.get("1T", -1)) == scene.tile_index("1T") and int(wait_score_indexes_263.get("4T", -1)) == scene.tile_index("4T"), "open waits retain canonical indexes")
	var wait_score_winning_counts_263: Array = wait_score_counts_263.duplicate()
	var wait_score_winning_index_263: int = scene.tile_index("4T")
	wait_score_winning_counts_263[wait_score_winning_index_263] = int(wait_score_winning_counts_263[wait_score_winning_index_263]) + 1
	var wait_score_scoring_counts_263: Array = scene.scoring_tile_counts_from_counts(1, wait_score_counts_263)
	wait_score_scoring_counts_263[wait_score_winning_index_263] = int(wait_score_scoring_counts_263[wait_score_winning_index_263]) + 1
	var wait_score_legacy_263: Dictionary = scene.calculate_win_score_from_tiles(1, [], false, "", true, wait_score_winning_counts_263, 11)
	var wait_score_snapshot_263: Dictionary = scene.calculate_win_score_from_tiles(1, [], false, "", true, wait_score_winning_counts_263, 11, wait_score_scoring_counts_263)
	check(wait_score_legacy_263 == wait_score_snapshot_263, "scoring vector snapshot preserves the open-hand score")
	var wait_score_array_263: Dictionary = scene.wait_value_metrics(1, wait_score_hand_263, 1, 0, wait_score_waits_263, wait_score_remaining_263, true)
	var wait_score_fast_263: Dictionary = scene.wait_value_metrics(1, wait_score_hand_263, 1, 0, wait_score_waits_263, wait_score_remaining_263, true, {}, -1.0, -1.0, wait_score_counts_263, -1, wait_score_indexes_263)
	check(wait_score_array_263 == wait_score_fast_263, "wait valuation snapshot preserves open-hand wait values")

	print("--- FV) wait score map reuse in ron/tsumo reports ---")
	var wait_map_source_264 := FileAccess.get_file_as_string("res://scripts/main_src/ai_brain.gd.part")
	var wait_map_start_264 := wait_map_source_264.find("func wait_value_metrics")
	var wait_map_end_264 := wait_map_source_264.find("func wait_quality_penalty", wait_map_start_264)
	var wait_map_function_264 := wait_map_source_264.substr(wait_map_start_264, wait_map_end_264 - wait_map_start_264)
	var wait_map_ron_start_264 := wait_map_source_264.find("func ai_ron_decision_report")
	var wait_map_ron_end_264 := wait_map_source_264.find("func ai_tsumo_decision_report", wait_map_ron_start_264)
	var wait_map_ron_function_264 := wait_map_source_264.substr(wait_map_ron_start_264, wait_map_ron_end_264 - wait_map_ron_start_264)
	var wait_map_tsumo_start_264 := wait_map_source_264.find("func ai_tsumo_decision_report")
	var wait_map_tsumo_end_264 := wait_map_source_264.find("func ai_tsumo_continue_discard", wait_map_tsumo_start_264)
	var wait_map_tsumo_function_264 := wait_map_source_264.substr(wait_map_tsumo_start_264, wait_map_tsumo_end_264 - wait_map_tsumo_start_264)
	check(wait_map_function_264.contains("var points_by_tile: Dictionary = {}"), "wait valuation prepares per-tile points")
	check(wait_map_function_264.contains("var fan_by_tile: Dictionary = {}"), "wait valuation prepares per-tile fan")
	check(wait_map_function_264.contains("points_by_tile[tile] = points") and wait_map_function_264.contains("fan_by_tile[tile] = fan"), "wait valuation publishes valid wait scores")
	check(wait_map_ron_function_264.contains("wait_value_metrics(seat, tenpai_hand, open_melds") and wait_map_ron_function_264.contains("if wait_points_by_tile.has(wait_tile):"), "ron consumes the wait score map")
	check(wait_map_tsumo_function_264.contains("wait_value_metrics(seat, tenpai_hand, open_melds") and wait_map_tsumo_function_264.contains("if wait_points_by_tile.has(wait_tile):"), "tsumo consumes the wait score map")
	check(wait_map_ron_function_264.contains("calculate_win_score_from_tiles(seat, [], false, \"\", true, probe_counts") and wait_map_tsumo_function_264.contains("calculate_win_score_from_tiles(seat, [], false, \"\", true, probe_counts"), "both reports retain the missing-map fallback")
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.mode = "offline"
	scene.offline_active_rule_variant = scene.RULE_VARIANT_YANGZHOU
	var wait_map_hand_264: Array = ["1W", "2W", "3W", "4W", "5W", "6W", "7B", "8B", "9B", "1T", "1T", "2T", "3T"]
	var wait_map_counts_264: Array = scene.tile_counts(wait_map_hand_264)
	var wait_map_metrics_264: Dictionary = scene.effective_tile_metrics(wait_map_hand_264, 0, 1, 0, scene.make_empty_tile_counts(), wait_map_counts_264)
	var wait_map_waits_264: Array = wait_map_metrics_264.get("tiles", [])
	var wait_map_remaining_264: Dictionary = wait_map_metrics_264.get("remaining_by_tile", {})
	var wait_map_indexes_264: Dictionary = wait_map_metrics_264.get("tile_indices", {})
	var wait_map_scores_264: Dictionary = scene.wait_value_metrics(1, wait_map_hand_264, 0, 0, wait_map_waits_264, wait_map_remaining_264, true, {}, 1.0, 1.0, wait_map_counts_264, 0, wait_map_indexes_264)
	var wait_map_points_264: Dictionary = wait_map_scores_264.get("points_by_tile", {})
	var wait_map_fan_264: Dictionary = wait_map_scores_264.get("fan_by_tile", {})
	check(wait_map_waits_264.has("1T") and wait_map_waits_264.has("4T"), "score-map fixture exposes multiple waits")
	check(wait_map_points_264.has("1T") and wait_map_points_264.has("4T") and wait_map_fan_264.has("1T") and wait_map_fan_264.has("4T"), "score map contains both wait scores")
	scene.offline_phase = "resolving"
	scene.dealer_seat = 0
	scene.offline_passed_win_tiles.clear()
	scene.players[1]["hand"] = wait_map_hand_264.duplicate()
	scene.players[1]["discards"] = []
	scene.players[1]["melds"] = []
	var wait_map_ron_report_264: Dictionary = scene.ai_ron_decision_report(1, "4T")
	check(int(wait_map_ron_report_264.get("alt_best_points", -1)) == int(wait_map_points_264.get("1T", -2)), "ron report matches the cached alternate score")
	var wait_map_tsumo_hand_264: Array = wait_map_hand_264.duplicate()
	wait_map_tsumo_hand_264.append("1T")
	scene.current_seat = 3
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.offline_last_draw = {"seat": 3, "tile": "1T", "source": "normal", "wall_empty": false, "serial": 264}
	scene.offline_self_draw_ready = {"seat": 3, "tile": "1T", "serial": 264}
	scene.players[3]["hand"] = wait_map_tsumo_hand_264
	scene.players[3]["discards"] = []
	scene.players[3]["melds"] = []
	var wait_map_expected_tsumo_264 := int(round(float(wait_map_points_264.get("4T", 0)) * 0.45 + float(scene.score_points_for_fan(clampi(int(wait_map_fan_264.get("4T", 0)) + 1, 1, scene.SCORE_LIMIT_FAN))) * 0.55))
	var wait_map_tsumo_report_264: Dictionary = scene.ai_tsumo_decision_report(3, "1T")
	check(int(wait_map_tsumo_report_264.get("alt_best_points", -1)) == wait_map_expected_tsumo_264, "tsumo report matches the cached alternate score")

	print("--- FW) full-straight work-vector reuse ---")
	var full_straight_source_265 := FileAccess.get_file_as_string("res://scripts/main_src/core.gd.part")
	var full_straight_start_265 := full_straight_source_265.find("func full_straight_suit_from_counts")
	var full_straight_end_265 := full_straight_source_265.find("func full_straight_open_meld_group", full_straight_start_265)
	var full_straight_function_265 := full_straight_source_265.substr(full_straight_start_265, full_straight_end_265 - full_straight_start_265)
	check(full_straight_function_265.contains("var concealed_counts: Array = concealed_counts_source.duplicate()"), "full-straight scoring prepares one work vector")
	check(full_straight_function_265.contains("consumed_indices.append(index") and full_straight_function_265.contains("for consumed_index in consumed_indices:"), "full-straight scoring restores temporary mutations")
	check(full_straight_function_265.count("concealed_counts_source.duplicate()") == 1, "full-straight scoring avoids per-suit copies")
	var full_straight_hand_265: Array = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "1T", "1T", "E", "E"]
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	var full_straight_counts_265: Array = scene.tile_counts(full_straight_hand_265)
	var full_straight_key_265: String = scene.counts_compact_key(full_straight_counts_265)
	check(scene.full_straight_suit_from_counts(0, full_straight_counts_265) == 0, "concealed full straight remains recognized")
	check(scene.counts_compact_key(full_straight_counts_265) == full_straight_key_265, "full-straight scan leaves caller counts unchanged")
	var full_straight_false_265: Array = ["1W", "1W", "1W", "2W", "2W", "2W", "3W", "4W", "5W", "6W", "7W", "7W", "8W", "9W"]
	check(scene.full_straight_suit_from_counts(0, scene.tile_counts(full_straight_false_265)) == -1, "non-decomposable hand remains rejected")
	scene.players[0]["melds"] = [["1W", "2W", "3W"]]
	var full_straight_open_265: Array = ["4W", "5W", "6W", "7W", "8W", "9W", "1T", "1T", "1T", "E", "E"]
	check(scene.full_straight_suit_from_counts(0, scene.tile_counts(full_straight_open_265)) == 0, "exposed full straight remains recognized")

	print("--- FX) count-based minimum-fan gate ---")
	var minimum_fan_core_source_266 := FileAccess.get_file_as_string("res://scripts/main_src/core.gd.part")
	var minimum_fan_gameplay_source_266 := FileAccess.get_file_as_string("res://scripts/main_src/gameplay.gd.part")
	check(minimum_fan_core_source_266.contains("func rule_minimum_met_for_counts"), "core exposes the count-based minimum-fan gate")
	var minimum_fan_start_266 := minimum_fan_gameplay_source_266.find("func can_win_for_seat_from_counts")
	var minimum_fan_end_266 := minimum_fan_gameplay_source_266.find("func discard_report_for_tile", minimum_fan_start_266)
	var minimum_fan_function_266 := minimum_fan_gameplay_source_266.substr(minimum_fan_start_266, minimum_fan_end_266 - minimum_fan_start_266)
	check(minimum_fan_function_266.contains("rule_minimum_met_for_counts(seat, counts, tile_count, self_draw, \"\", validated_counts)"), "count-based win validation uses the prepared count vector")
	check(not minimum_fan_function_266.contains("tiles_from_counts(counts)"), "count-based win validation avoids count-to-tile expansion")
	var minimum_fan_hand_266: Array = ["1W", "2W", "3W", "4W", "5W", "6W", "7T", "8T", "9T", "E", "E", "E", "S", "S"]
	scene.players[1]["hand"] = minimum_fan_hand_266.duplicate()
	scene.players[1]["melds"] = []
	scene.offline_active_rule_variant = scene.RULE_VARIANT_GUANGDONG
	scene.offline_phase = "resolving"
	var minimum_fan_counts_266: Array = scene.tile_counts(minimum_fan_hand_266)
	var minimum_fan_array_266: bool = scene.rule_minimum_met_for_tiles(1, scene.tiles_from_counts(minimum_fan_counts_266), false)
	var minimum_fan_count_266: bool = scene.rule_minimum_met_for_counts(1, minimum_fan_counts_266, minimum_fan_hand_266.size(), false)
	check(minimum_fan_count_266 == minimum_fan_array_266 and not minimum_fan_count_266, "count gate preserves a Guangdong hand below the minimum fan")
	var qualifying_hand_266: Array = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "E", "E", "E", "S", "S"]
	var qualifying_counts_266: Array = scene.tile_counts(qualifying_hand_266)
	var qualifying_array_266: bool = scene.rule_minimum_met_for_tiles(1, scene.tiles_from_counts(qualifying_counts_266), false)
	var qualifying_count_266: bool = scene.rule_minimum_met_for_counts(1, qualifying_counts_266, qualifying_hand_266.size(), false)
	check(qualifying_count_266 == qualifying_array_266 and qualifying_count_266, "count gate preserves a qualifying Guangdong full-straight hand")
	var bottom_wait_base_266: Array = ["1W", "2W", "3W", "4W", "5W", "6W", "7T", "8T", "9T", "E", "E", "E", "S"]
	var bottom_winning_hand_266: Array = bottom_wait_base_266.duplicate()
	bottom_winning_hand_266.append("S")
	var bottom_winning_counts_266: Array = scene.tile_counts(bottom_winning_hand_266)
	scene.offline_phase = "pending_claim"
	scene.last_discard = "S"
	scene.last_discard_seat = 0
	scene.offline_last_draw = {"wall_empty": true, "seat": 0}
	var bottom_array_266: bool = scene.rule_minimum_met_for_tiles(1, scene.tiles_from_counts(bottom_winning_counts_266), false)
	var bottom_count_266: bool = scene.rule_minimum_met_for_counts(1, bottom_winning_counts_266, bottom_winning_hand_266.size(), false)
	check(bottom_count_266 == bottom_array_266 and bottom_count_266, "count gate preserves the river-bottom bonus context")

	print("--- FY) effective-tile shared shanten memo ---")
	var shanten_source_267 := FileAccess.get_file_as_string("res://scripts/main_src/ai_brain.gd.part")
	var shanten_start_267 := shanten_source_267.find("func calculate_min_shanten_from_counts")
	var shanten_end_267 := shanten_source_267.find("func effective_tile_count", shanten_start_267)
	var shanten_function_267 := shanten_source_267.substr(shanten_start_267, shanten_end_267 - shanten_start_267)
	check(shanten_function_267.contains("func calculate_min_shanten_from_counts_with_memo"), "shanten exposes a shared-memo entry point")
	var effective_start_267 := shanten_source_267.find("func effective_tile_metrics")
	var effective_end_267 := shanten_source_267.find("func touch_effective_tiles_cache_key", effective_start_267)
	var effective_function_267 := shanten_source_267.substr(effective_start_267, effective_end_267 - effective_start_267)
	check(effective_function_267.contains("var effective_tile_search_memo: Dictionary = {}"), "effective-tile scan allocates one batch memo")
	check(effective_function_267.contains("calculate_min_shanten_from_counts_with_memo(hand_counts, open_melds, \"\", effective_tile_search_memo)"), "candidate probes reuse the batch memo")
	var shared_hand_267: Array = ["1W", "2W", "4W", "5W", "7W", "8W", "2T", "3T", "5T", "6T", "8T", "9T", "E", "S"]
	var shared_counts_267: Array = scene.tile_counts(shared_hand_267)
	var shared_key_267: String = scene.counts_compact_key(shared_counts_267)
	var shared_normal_267: int = scene.calculate_min_shanten_from_counts(shared_counts_267.duplicate(), 0)
	scene.clear_shanten_cache()
	var shared_memo_267: Dictionary = {}
	var shared_result_267: int = scene.calculate_min_shanten_from_counts_with_memo(shared_counts_267.duplicate(), 0, "", shared_memo_267)
	check(shared_result_267 == shared_normal_267 and not shared_memo_267.is_empty(), "shared and standalone shanten results remain equal")
	scene.clear_ai_report_cache()
	var shared_metrics_267: Dictionary = scene.effective_tile_metrics(shared_hand_267, 0, 1, 99, scene.make_empty_tile_counts(), shared_counts_267)
	check(int(shared_metrics_267.get("count", 0)) >= 0 and scene.counts_compact_key(shared_counts_267) == shared_key_267, "effective-tile scan preserves results and caller counts")
	var shared_repeat_267: Dictionary = scene.effective_tile_metrics(shared_hand_267, 0, 1, 99, scene.make_empty_tile_counts(), shared_counts_267)
	check(shared_repeat_267 == shared_metrics_267, "effective-tile cache preserves the shared-memo result")
	scene.players[1]["melds"] = [["1W", "1W", "1W"]]
	var shared_open_hand_267: Array = ["2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "2T", "3T", "4T", "E", "S"]
	var shared_open_counts_267: Array = scene.tile_counts(shared_open_hand_267)
	var shared_open_normal_267: int = scene.calculate_min_shanten_from_counts(shared_open_counts_267.duplicate(), 1)
	scene.clear_shanten_cache()
	var shared_open_memo_267: Dictionary = {}
	var shared_open_result_267: int = scene.calculate_min_shanten_from_counts_with_memo(shared_open_counts_267.duplicate(), 1, "", shared_open_memo_267)
	check(shared_open_result_267 == shared_open_normal_267 and not shared_open_memo_267.is_empty(), "open-hand shanten also preserves shared-memo equivalence")

	print("--- FZ) discard visible-count key reuse ---")
	var visible_key_source_268 := FileAccess.get_file_as_string("res://scripts/main_src/ai_brain.gd.part")
	var context_start_268 := visible_key_source_268.find("func make_ai_evaluation_context")
	var context_end_268 := visible_key_source_268.find("func ai_context_visible_counts", context_start_268)
	var context_function_268 := visible_key_source_268.substr(context_start_268, context_end_268 - context_start_268)
	check(context_function_268.contains("visible_counts_key_override: String = \"\""), "evaluation context accepts a visible-count key snapshot")
	check(context_function_268.contains("visible_counts_key_override if visible_counts_key_override != \"\" else counts_compact_key(visible_counts)"), "evaluation context keeps the compact-key fallback")
	var report_key_start_268 := visible_key_source_268.find("func ai_report_cache_key")
	var report_key_end_268 := visible_key_source_268.find("func ai_profile_map_cache_key", report_key_start_268)
	var report_key_function_268 := visible_key_source_268.substr(report_key_start_268, report_key_end_268 - report_key_start_268)
	check(report_key_function_268.contains("visible_counts_key_override: String = \"\""), "discard report cache key accepts the shared count key")
	check(report_key_function_268.contains("threat_report_table_state_cache_key(seat, visible_counts, visible_counts_key_override, wall_count)"), "discard report key forwards the shared count key")
	var reports_start_268 := visible_key_source_268.find("func get_ai_discard_reports")
	var reports_end_268 := visible_key_source_268.find("func sort_ai_discard_reports", reports_start_268)
	var reports_function_268 := visible_key_source_268.substr(reports_start_268, reports_end_268 - reports_start_268)
	check(reports_function_268.contains("var visible_counts_key_snapshot := counts_compact_key(visible_counts_snapshot)"), "discard evaluation builds one visible-count key snapshot")
	check(reports_function_268.contains("ai_report_cache_key(seat, visible_counts_snapshot, -1, visible_counts_key_snapshot)"), "discard cache lookup receives the shared count key")
	check(reports_function_268.contains("make_ai_evaluation_context(seat, visible_counts_snapshot, visible_counts_key_snapshot)"), "discard evaluation forwards the key into its context")
	var visible_counts_268: Array = scene.make_empty_tile_counts()
	visible_counts_268[scene.tile_index("3W")] = 2
	visible_counts_268[scene.tile_index("E")] = 1
	var visible_key_268: String = scene.counts_compact_key(visible_counts_268)
	var baseline_context_268: Dictionary = scene.make_ai_evaluation_context(1, visible_counts_268)
	var snapshot_context_268: Dictionary = scene.make_ai_evaluation_context(1, visible_counts_268, visible_key_268)
	check(snapshot_context_268 == baseline_context_268, "key snapshot preserves the complete evaluation context")
	check(str(snapshot_context_268.get("visible_counts_key", "")) == visible_key_268, "context publishes the forwarded visible-count key")
	var baseline_report_key_268: String = scene.ai_report_cache_key(1, visible_counts_268)
	var snapshot_report_key_268: String = scene.ai_report_cache_key(1, visible_counts_268, -1, visible_key_268)
	check(snapshot_report_key_268 == baseline_report_key_268, "forwarded key preserves the discard report cache partition")

	print("--- FZA) wait scoring exposed-meld index reuse ---")
	var scoring_source_269 := FileAccess.get_file_as_string("res://scripts/main_src/core.gd.part")
	var scoring_start_269 := scoring_source_269.find("func scoring_tile_counts_from_counts")
	var scoring_end_269 := scoring_source_269.find("func is_pure_one_suit_from_counts", scoring_start_269)
	var scoring_function_269 := scoring_source_269.substr(scoring_start_269, scoring_end_269 - scoring_start_269)
	check(scoring_function_269.contains("meld_tile_indices_snapshot: Array = []"), "scoring count helper accepts a meld-index snapshot")
	check(scoring_function_269.contains("if not meld_tile_indices_snapshot.is_empty()"), "scoring count helper has the snapshot fast path")
	check(scoring_function_269.contains("for raw_index in meld_tile_indices_snapshot"), "scoring count helper consumes normalized indexes directly")
	var wait_source_269 := FileAccess.get_file_as_string("res://scripts/main_src/ai_brain.gd.part")
	var wait_start_269 := wait_source_269.find("func wait_value_metrics")
	var wait_end_269 := wait_source_269.find("func wait_quality_penalty", wait_start_269)
	var wait_function_269 := wait_source_269.substr(wait_start_269, wait_end_269 - wait_start_269)
	check(wait_function_269.contains("meld_tile_indices_snapshot: Array = []"), "wait valuation accepts a meld-index snapshot")
	check(wait_function_269.contains("scoring_tile_counts_from_counts(seat, hand_counts_snapshot, meld_tile_indices_snapshot)"), "wait valuation forwards the snapshot to scoring counts")
	var report_start_269 := wait_source_269.find("func build_ai_discard_report")
	var report_end_269 := wait_source_269.find("func wait_value_metrics", report_start_269)
	var report_function_269 := wait_source_269.substr(report_start_269, report_end_269 - report_start_269)
	check(report_function_269.contains("effective_tile_indices, meld_tile_indices_snapshot)"), "discard reports forward their shared meld indexes")
	var hand_269: Array = ["4W", "5W", "6W", "7B", "8B", "9B", "1T", "1T", "2T", "3T"]
	scene.players[1]["hand"] = hand_269.duplicate()
	scene.players[1]["melds"] = [["1W", "2W", "3W"]]
	var hand_counts_269: Array = scene.tile_counts(hand_269)
	var meld_indices_269: Array = scene.hand_plan_meld_tile_indices_for_seat(1)
	check(meld_indices_269 == [scene.tile_index("1W"), scene.tile_index("2W"), scene.tile_index("3W")], "context snapshot contains every exposed tile index")
	var legacy_counts_269: Array = scene.scoring_tile_counts_from_counts(1, hand_counts_269)
	var snapshot_counts_269: Array = scene.scoring_tile_counts_from_counts(1, hand_counts_269, meld_indices_269)
	check(snapshot_counts_269 == legacy_counts_269, "snapshot scoring counts equal the legacy meld scan")
	var visible_counts_269: Array = scene.make_empty_tile_counts()
	var metrics_269: Dictionary = scene.effective_tile_metrics(hand_269, 1, 1, 0, visible_counts_269, hand_counts_269)
	var waits_269: Array = metrics_269.get("tiles", [])
	var remaining_269: Dictionary = metrics_269.get("remaining_by_tile", {})
	var wait_indices_269: Dictionary = metrics_269.get("tile_indices", {})
	var legacy_wait_269: Dictionary = scene.wait_value_metrics(1, hand_269, 1, 0, waits_269, remaining_269, true, {}, -1.0, -1.0, hand_counts_269, 1, wait_indices_269)
	var snapshot_wait_269: Dictionary = scene.wait_value_metrics(1, hand_269, 1, 0, waits_269, remaining_269, true, {}, -1.0, -1.0, hand_counts_269, 1, wait_indices_269, meld_indices_269)
	check(legacy_wait_269 == snapshot_wait_269, "snapshot wait valuation preserves all open-hand metrics")
	check(scene.counts_compact_key(hand_counts_269) == scene.counts_compact_key(scene.tile_counts(hand_269)), "wait probes leave concealed counts unchanged")
	scene.players[1]["melds"] = []
	var closed_wait_269: Dictionary = scene.wait_value_metrics(1, hand_269, 0, 0, waits_269, remaining_269, true, {}, -1.0, -1.0, hand_counts_269, 0, wait_indices_269)
	check(not closed_wait_269.is_empty(), "legacy wait valuation remains available without exposed melds")

	print("--- FZB) closed special-hand profile scan ---")
	var special_source_270 := FileAccess.get_file_as_string("res://scripts/main_src/core.gd.part")
	var score_start_270 := special_source_270.find("func calculate_win_score_from_tiles")
	var score_end_270 := special_source_270.find("func is_last_draw_context", score_start_270)
	var score_function_270 := special_source_270.substr(score_start_270, score_end_270 - score_start_270)
	check(score_function_270.contains("scoring_special_hand_profile_from_counts(hand_counts, canonical_tile_count)"), "scoring uses the shared special-hand profile")
	check(score_function_270.contains("special_hand_profile.get(\"seven_pairs\""), "scoring consumes the shared seven-pairs flag")
	check(score_function_270.contains("special_hand_profile.get(\"thirteen_orphans\""), "scoring consumes the shared thirteen-orphans flag")
	var profile_start_270 := special_source_270.find("func scoring_special_hand_profile_from_counts")
	var profile_end_270 := special_source_270.find("func is_thirteen_orphans_tile", profile_start_270)
	var profile_function_270 := special_source_270.substr(profile_start_270, profile_end_270 - profile_start_270)
	check(profile_function_270.contains("for index in range(TILE_CODES.size())"), "special-hand profile scans the count vector once")
	check(profile_function_270.contains("result[\"seven_pairs\"]"), "special-hand profile publishes seven-pairs classification")
	check(profile_function_270.contains("result[\"thirteen_orphans\"]"), "special-hand profile publishes thirteen-orphans classification")
	var standard_hand_270: Array = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "E", "E", "E", "S", "S"]
	var standard_counts_270: Array = scene.tile_counts(standard_hand_270)
	var standard_profile_270: Dictionary = scene.scoring_special_hand_profile_from_counts(standard_counts_270, standard_hand_270.size())
	check(not bool(standard_profile_270.get("seven_pairs", false)) and not bool(standard_profile_270.get("thirteen_orphans", false)), "standard hand keeps both special flags false")
	check(bool(scene.is_complete_hand_from_counts(standard_counts_270, standard_hand_270.size(), 0)), "standard hand remains complete")
	var seven_pairs_hand_270: Array = ["1W", "1W", "2W", "2W", "3W", "3W", "4T", "4T", "5T", "5T", "6B", "6B", "E", "E"]
	var seven_pairs_counts_270: Array = scene.tile_counts(seven_pairs_hand_270)
	var seven_pairs_profile_270: Dictionary = scene.scoring_special_hand_profile_from_counts(seven_pairs_counts_270, seven_pairs_hand_270.size())
	check(bool(seven_pairs_profile_270.get("seven_pairs", false)) and not bool(seven_pairs_profile_270.get("thirteen_orphans", false)), "seven-pairs hand keeps only the seven-pairs flag")
	check(scene.is_seven_pairs_from_counts(seven_pairs_counts_270, seven_pairs_hand_270.size()), "seven-pairs public predicate agrees with the shared profile")
	var thirteen_hand_270: Array = ["1W", "9W", "1T", "9T", "1B", "9B", "E", "S", "N", "R", "Z", "F", "P", "E"]
	var thirteen_counts_270: Array = scene.tile_counts(thirteen_hand_270)
	var thirteen_profile_270: Dictionary = scene.scoring_special_hand_profile_from_counts(thirteen_counts_270, thirteen_hand_270.size())
	check(not bool(thirteen_profile_270.get("seven_pairs", false)) and bool(thirteen_profile_270.get("thirteen_orphans", false)), "thirteen-orphans hand keeps only the thirteen-orphans flag")
	check(scene.is_thirteen_orphans_from_counts(thirteen_counts_270, thirteen_hand_270.size()), "thirteen-orphans public predicate agrees with the shared profile")
	var short_counts_270: Array = scene.tile_counts(seven_pairs_hand_270.slice(0, 13))
	var short_profile_270: Dictionary = scene.scoring_special_hand_profile_from_counts(short_counts_270, 13)
	check(not bool(short_profile_270.get("seven_pairs", false)) and not bool(short_profile_270.get("thirteen_orphans", false)), "non-fourteen-tile inputs keep both special flags false")

	print("--- FZC) scoring meld-state cache reuse ---")
	var meld_state_source_271 := FileAccess.get_file_as_string("res://scripts/main_src/core.gd.part")
	var exposed_start_271 := meld_state_source_271.find("func exposed_meld_count_for_seat")
	var exposed_end_271 := meld_state_source_271.find("func is_menzen_hand", exposed_start_271)
	var exposed_function_271 := meld_state_source_271.substr(exposed_start_271, exposed_end_271 - exposed_start_271)
	check(exposed_function_271.count("for item in melds") == 1, "meld state uses one exposed-meld scan")
	check(exposed_function_271.contains("var gang_count = 0"), "meld state captures gang count during the scan")
	check(exposed_function_271.contains("\"gang_count\": gang_count"), "meld cache publishes the paired gang count")
	var score_start_271 := meld_state_source_271.find("func calculate_win_score_from_tiles")
	var score_end_271 := meld_state_source_271.find("func is_last_draw_context", score_start_271)
	var score_function_271 := meld_state_source_271.substr(score_start_271, score_end_271 - score_start_271)
	check(score_function_271.contains("var scoring_meld_state := scoring_meld_state_for_seat(seat)"), "scoring captures one meld state")
	check(not score_function_271.contains("is_menzen_hand(seat)"), "scoring avoids a second menzen lookup")
	check(not score_function_271.contains("count_gang_melds(seat)"), "scoring avoids a second gang scan")
	var gang_start_271 := meld_state_source_271.find("func count_gang_melds")
	var gang_end_271 := meld_state_source_271.find("func add_clickable_tile_press_art", gang_start_271)
	var gang_function_271 := meld_state_source_271.substr(gang_start_271, gang_end_271 - gang_start_271)
	check(gang_function_271.contains("scoring_meld_state_for_seat(seat)"), "public gang helper keeps the cached fallback")
	var closed_hand_271: Array = ["1W", "2W", "3W", "4W", "5W", "6W", "7T", "8T", "9T", "E", "E", "E", "S", "S"]
	scene.players[1]["hand"] = closed_hand_271.duplicate()
	scene.players[1]["melds"] = []
	scene.exposed_meld_count_cache.clear()
	var closed_state_271: Dictionary = scene.scoring_meld_state_for_seat(1)
	var closed_score_271: Dictionary = scene.calculate_win_score_from_tiles(1, closed_hand_271, false)
	check(int(closed_state_271.get("value", -1)) == 0 and int(closed_state_271.get("gang_count", -1)) == 0, "closed meld state keeps menzen and gang values")
	check(scene.is_menzen_hand(1) and scene.count_gang_melds(1) == 0, "public closed helpers preserve their results")
	check(closed_score_271.get("reasons", []).has("门清"), "closed scoring keeps the menzen fan")
	var open_hand_271: Array = ["4W", "5W", "6W", "7B", "8B", "9B", "1T", "2T", "3T", "E", "E"]
	scene.players[1]["hand"] = open_hand_271.duplicate()
	scene.players[1]["melds"] = [["1W", "2W", "3W"]]
	scene.exposed_meld_count_cache.clear()
	var open_state_271: Dictionary = scene.scoring_meld_state_for_seat(1)
	var open_score_271: Dictionary = scene.calculate_win_score_from_tiles(1, open_hand_271, false)
	check(int(open_state_271.get("value", -1)) == 1 and int(open_state_271.get("gang_count", -1)) == 0, "open sequence state keeps exposed and gang values")
	check(not scene.is_menzen_hand(1) and scene.count_gang_melds(1) == 0, "public open helpers preserve their results")
	check(int(open_score_271.get("points", 0)) > 0 and not open_score_271.get("reasons", []).has("门清"), "open scoring keeps paid result without menzen fan")
	scene.players[1]["melds"] = [["1W", "1W", "1W", "1W"]]
	scene.exposed_meld_count_cache.clear()
	var gang_state_271: Dictionary = scene.scoring_meld_state_for_seat(1)
	var gang_score_271: Dictionary = scene.calculate_win_score_from_tiles(1, open_hand_271, false)
	check(int(gang_state_271.get("value", -1)) == 1 and int(gang_state_271.get("gang_count", -1)) == 1, "gang state keeps one exposed meld and one gang")
	check(not scene.is_menzen_hand(1) and scene.count_gang_melds(1) == 1, "public gang helper keeps the cached count")
	check(gang_score_271.get("reasons", []).has("杠") and int(gang_score_271.get("points", 0)) > int(open_score_271.get("points", 0)), "gang scoring keeps its extra fan")
	var cached_state_271: Dictionary = scene.scoring_meld_state_for_seat(1)
	check(cached_state_271 == gang_state_271, "repeated scoring state reuses the same cache entry")

	print("--- FZD) full-straight exposed-group cache reuse ---")
	var full_straight_source_272 := FileAccess.get_file_as_string("res://scripts/main_src/core.gd.part")
	var helper_start_272 := full_straight_source_272.find("func full_straight_open_meld_groups_for_seat")
	var helper_end_272 := full_straight_source_272.find("func full_straight_suit_from_counts", helper_start_272)
	var helper_function_272 := full_straight_source_272.substr(helper_start_272, helper_end_272 - helper_start_272)
	check(helper_function_272.contains("exposed_meld_count_for_seat(seat)"), "full-straight grouping uses the meld fingerprint")
	check(helper_function_272.contains("full_straight_open_meld_groups"), "full-straight grouping publishes a cache entry")
	check(helper_function_272.contains("if typeof(cached_groups) == TYPE_ARRAY"), "full-straight grouping has a cache fast path")
	var straight_start_272 := full_straight_source_272.find("func full_straight_suit_from_counts")
	var straight_end_272 := full_straight_source_272.find("func full_straight_open_meld_group", straight_start_272)
	var straight_function_272 := full_straight_source_272.substr(straight_start_272, straight_end_272 - straight_start_272)
	check(straight_function_272.contains("full_straight_open_meld_groups_for_seat(seat)"), "full-straight scoring consumes the cached grouping")
	check(not straight_function_272.contains("for meld in open_melds"), "full-straight scoring avoids rebuilding exposed groups")
	var full_straight_hand_272: Array = ["7W", "8W", "9W", "E", "E", "E", "S", "S"]
	scene.players[1]["hand"] = full_straight_hand_272.duplicate()
	scene.players[1]["melds"] = [["1W", "2W", "3W"], ["4W", "5W", "6W"]]
	scene.exposed_meld_count_cache.clear()
	var groups_272: Array = scene.full_straight_open_meld_groups_for_seat(1)
	check(groups_272[0] == [true, true, false], "exposed groups retain the 123/456 layout")
	check(scene.exposed_meld_count_cache.get(1, {}).has("full_straight_open_meld_groups"), "exposed cache stores the derived grouping")
	var first_result_272: int = scene.full_straight_suit_from_counts(1, scene.tile_counts(full_straight_hand_272))
	var second_result_272: int = scene.full_straight_suit_from_counts(1, scene.tile_counts(full_straight_hand_272))
	check(first_result_272 == 0 and second_result_272 == first_result_272, "repeated full-straight probes preserve the result")
	check(scene.full_straight_open_meld_groups_for_seat(1) == groups_272, "repeated probes reuse the same exposed grouping")
	scene.players[1]["melds"] = [["1W", "2W", "3W"]]
	var changed_groups_272: Array = scene.full_straight_open_meld_groups_for_seat(1)
	check(changed_groups_272[0] == [true, false, false], "meld mutation invalidates the derived grouping")
	var closed_hand_272: Array = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "E", "E", "E", "S", "S"]
	scene.players[1]["hand"] = closed_hand_272.duplicate()
	scene.players[1]["melds"] = []
	var closed_groups_272: Array = scene.full_straight_open_meld_groups_for_seat(1)
	check(closed_groups_272[0] == [false, false, false], "closed hands keep an empty exposed grouping")
	check(scene.full_straight_suit_from_counts(1, scene.tile_counts(closed_hand_272)) == 0, "closed full straight remains recognized")

	print("--- FZE) public win count-boundary reuse ---")
	var win_boundary_source_273 := FileAccess.get_file_as_string("res://scripts/main_src/gameplay.gd.part")
	var win_boundary_start_273 := win_boundary_source_273.find("func can_win_for_seat(seat: int")
	var win_boundary_end_273 := win_boundary_source_273.find("func record_passed_win_tile", win_boundary_start_273)
	var win_boundary_function_273 := win_boundary_source_273.substr(win_boundary_start_273, win_boundary_end_273 - win_boundary_start_273)
	check(win_boundary_function_273.contains("var hand_counts: Array = tile_counts(players[seat][\"hand\"]"), "public win validation builds one count vector")
	check(win_boundary_function_273.contains("_can_win_for_seat_from_counts_normalized(seat, hand_counts, normalized_extra_tile, normalized_extra_tile == \"\")"), "public win validation delegates completion and scoring")
	check(not win_boundary_function_273.contains("has_valid_scoring_melds(seat)"), "public win validation avoids a separate meld scan")
	check(not win_boundary_function_273.contains("has_valid_scoring_tile_inventory(seat, tiles)"), "public win validation avoids rebuilding a tile array")
	check(not win_boundary_function_273.contains("rule_minimum_met_for_tiles(seat, tiles"), "public win validation avoids the array minimum-fan path")
	var win_boundary_self_draw_273: Array = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "1T", "1T", "E", "E"]
	scene.players[0]["hand"] = win_boundary_self_draw_273.duplicate()
	scene.players[0]["melds"] = []
	var win_boundary_self_draw_counts_273: Array = scene.tile_counts(win_boundary_self_draw_273)
	check(scene.can_win_for_seat(0) == scene.can_win_for_seat_from_counts(0, win_boundary_self_draw_counts_273, "", true), "self-draw behavior matches the count boundary")
	var win_boundary_ron_base_273: Array = ["2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "1T", "1T", "E", "E"]
	scene.players[0]["hand"] = win_boundary_ron_base_273.duplicate()
	var win_boundary_ron_counts_273: Array = scene.tile_counts(win_boundary_ron_base_273)
	check(scene.can_win_for_seat(0, "1M") == scene.can_win_for_seat_from_counts(0, win_boundary_ron_counts_273, "1M", false) and scene.can_win_for_seat(0, "1M"), "normalized ron tile keeps the count-boundary result")
	var win_boundary_open_hand_273: Array = ["4W", "5W", "6W", "7W", "8W", "9W", "1T", "1T", "1T", "E", "E"]
	scene.players[0]["hand"] = win_boundary_open_hand_273.duplicate()
	scene.players[0]["melds"] = [["1W", "2W", "3W"]]
	var win_boundary_open_counts_273: Array = scene.tile_counts(win_boundary_open_hand_273)
	check(scene.can_win_for_seat(0) == scene.can_win_for_seat_from_counts(0, win_boundary_open_counts_273, "", true), "open-hand completion keeps the same result")
	var win_boundary_malformed_273: Array = win_boundary_self_draw_273.duplicate()
	win_boundary_malformed_273[0] = "ZZ"
	scene.players[0]["hand"] = win_boundary_malformed_273
	scene.players[0]["melds"] = []
	check(not scene.can_win_for_seat(0), "invalid stored tile remains rejected by the count boundary")

	print("--- FZF) count-win combined validation reuse ---")
	var count_win_source_274 := FileAccess.get_file_as_string("res://scripts/main_src/gameplay.gd.part")
	var count_win_start_274 := count_win_source_274.find("func can_win_for_seat_from_counts")
	var count_win_end_274 := count_win_source_274.find("func discard_report_for_tile", count_win_start_274)
	var count_win_function_274 := count_win_source_274.substr(count_win_start_274, count_win_end_274 - count_win_start_274)
	check(count_win_function_274.contains("validated_scoring_tile_counts_from_counts(seat, counts, tile_count)"), "count win validation uses the combined inventory pass")
	check(not count_win_function_274.contains("has_valid_scoring_melds(seat)"), "count win validation avoids a separate meld scan")
	check(not count_win_function_274.contains("has_valid_scoring_tile_inventory_from_counts(seat, counts, tile_count)"), "count win validation avoids a second inventory scan")
	var count_win_valid_274: Array = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "1T", "1T", "E", "E"]
	scene.players[0]["hand"] = count_win_valid_274.duplicate()
	scene.players[0]["melds"] = []
	var count_win_valid_counts_274: Array = scene.tile_counts(count_win_valid_274)
	var count_win_valid_combined_274: Array = scene.validated_scoring_tile_counts_from_counts(0, count_win_valid_counts_274, count_win_valid_274.size())
	check(not count_win_valid_combined_274.is_empty() and scene.has_valid_scoring_melds(0) and scene.has_valid_scoring_tile_inventory_from_counts(0, count_win_valid_counts_274, count_win_valid_274.size()), "valid closed hand keeps the combined validation result")
	check(scene.can_win_for_seat_from_counts(0, count_win_valid_counts_274, "", true), "valid closed hand still passes the count win boundary")
	var count_win_open_274: Array = ["4W", "5W", "6W", "7W", "8W", "9W", "1T", "1T", "1T", "E", "E"]
	scene.players[0]["hand"] = count_win_open_274.duplicate()
	scene.players[0]["melds"] = [["1W", "2W", "3W"]]
	var count_win_open_counts_274: Array = scene.tile_counts(count_win_open_274)
	check(scene.can_win_for_seat_from_counts(0, count_win_open_counts_274, "", true), "valid open hand still passes the count win boundary")
	scene.players[0]["melds"] = [["4W", "5W", "7W"]]
	check(scene.validated_scoring_tile_counts_from_counts(0, count_win_open_counts_274, count_win_open_274.size()).is_empty() and not scene.can_win_for_seat_from_counts(0, count_win_open_counts_274, "", true), "malformed meld remains rejected by one combined pass")
	scene.players[0]["melds"] = [["1W", "1W", "1W", "1W"]]
	var count_win_over_limit_274: Array = ["1W", "1W", "2T", "3T", "4T", "5T", "6T", "7T", "7B", "8B", "9B"]
	scene.players[0]["hand"] = count_win_over_limit_274.duplicate()
	var count_win_over_limit_counts_274: Array = scene.tile_counts(count_win_over_limit_274)
	check(scene.validated_scoring_tile_counts_from_counts(0, count_win_over_limit_counts_274, count_win_over_limit_274.size()).is_empty() and not scene.can_win_for_seat_from_counts(0, count_win_over_limit_counts_274, "", false), "combined inventory still enforces the four-copy limit")

	print("--- FZG) minimum-fan validated snapshot reuse ---")
	var minimum_snapshot_source_275 := FileAccess.get_file_as_string("res://scripts/main_src/core.gd.part")
	var minimum_snapshot_start_275 := minimum_snapshot_source_275.find("func rule_minimum_met_for_counts")
	var minimum_snapshot_end_275 := minimum_snapshot_source_275.find("func _play_reward_claim_animation", minimum_snapshot_start_275)
	var minimum_snapshot_function_275 := minimum_snapshot_source_275.substr(minimum_snapshot_start_275, minimum_snapshot_end_275 - minimum_snapshot_start_275)
	check(minimum_snapshot_function_275.contains("validated_scoring_counts_snapshot: Array = []"), "minimum-fan gate accepts an optional validated snapshot")
	check(minimum_snapshot_function_275.contains("var use_validated_snapshot := validated_scoring_counts_snapshot.size() == TILE_CODES.size()"), "minimum-fan gate selects the snapshot fast path explicitly")
	check(minimum_snapshot_function_275.contains("calculate_win_score_from_tiles(seat, [], self_draw, win_context, use_validated_snapshot"), "minimum-fan gate keeps the direct-call fallback")
	check(minimum_snapshot_source_275.contains("preserve_context_bonuses: bool = false") and minimum_snapshot_function_275.contains("validated_scoring_counts_snapshot, use_validated_snapshot"), "minimum-fan snapshot preserves context bonuses explicitly")
	var minimum_snapshot_gameplay_275 := FileAccess.get_file_as_string("res://scripts/main_src/gameplay.gd.part")
	var minimum_snapshot_win_start_275 := minimum_snapshot_gameplay_275.find("func can_win_for_seat_from_counts")
	var minimum_snapshot_win_end_275 := minimum_snapshot_gameplay_275.find("func discard_report_for_tile", minimum_snapshot_win_start_275)
	var minimum_snapshot_win_function_275 := minimum_snapshot_gameplay_275.substr(minimum_snapshot_win_start_275, minimum_snapshot_win_end_275 - minimum_snapshot_win_start_275)
	check(minimum_snapshot_win_function_275.contains("rule_minimum_met_for_counts(seat, counts, tile_count, self_draw, \"\", validated_counts)"), "count win validation forwards its validated scoring counts")
	var minimum_snapshot_hand_275: Array = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "1T", "1T", "E", "E"]
	scene.players[0]["hand"] = minimum_snapshot_hand_275.duplicate()
	scene.players[0]["melds"] = []
	scene.offline_active_rule_variant = scene.RULE_VARIANT_GUANGDONG
	var minimum_snapshot_counts_275: Array = scene.tile_counts(minimum_snapshot_hand_275)
	var minimum_snapshot_validated_275: Array = scene.validated_scoring_tile_counts_from_counts(0, minimum_snapshot_counts_275, minimum_snapshot_hand_275.size())
	var minimum_snapshot_direct_gate_275: bool = scene.rule_minimum_met_for_counts(0, minimum_snapshot_counts_275, minimum_snapshot_hand_275.size(), false)
	var minimum_snapshot_fast_gate_275: bool = scene.rule_minimum_met_for_counts(0, minimum_snapshot_counts_275, minimum_snapshot_hand_275.size(), false, "", minimum_snapshot_validated_275)
	check(minimum_snapshot_direct_gate_275 == minimum_snapshot_fast_gate_275, "validated snapshot preserves the minimum-fan result")
	var minimum_snapshot_direct_score_275: Dictionary = scene.calculate_win_score_from_tiles(0, minimum_snapshot_hand_275, false)
	var minimum_snapshot_fast_score_275: Dictionary = scene.calculate_win_score_from_tiles(0, [], false, "", true, minimum_snapshot_counts_275, minimum_snapshot_hand_275.size(), minimum_snapshot_validated_275, true)
	check(minimum_snapshot_direct_score_275 == minimum_snapshot_fast_score_275, "validated snapshot preserves score details")
	check(scene.can_win_for_seat_from_counts(0, minimum_snapshot_counts_275, "", true), "count win boundary remains valid after snapshot forwarding")
	var minimum_snapshot_open_hand_275: Array = ["4W", "5W", "6W", "7W", "8W", "9W", "1T", "1T", "1T", "E", "E"]
	scene.players[0]["hand"] = minimum_snapshot_open_hand_275.duplicate()
	scene.players[0]["melds"] = [["1W", "2W", "3W"]]
	var minimum_snapshot_open_counts_275: Array = scene.tile_counts(minimum_snapshot_open_hand_275)
	var minimum_snapshot_open_validated_275: Array = scene.validated_scoring_tile_counts_from_counts(0, minimum_snapshot_open_counts_275, minimum_snapshot_open_hand_275.size())
	check(scene.rule_minimum_met_for_counts(0, minimum_snapshot_open_counts_275, minimum_snapshot_open_hand_275.size(), false) == scene.rule_minimum_met_for_counts(0, minimum_snapshot_open_counts_275, minimum_snapshot_open_hand_275.size(), false, "", minimum_snapshot_open_validated_275) and scene.can_win_for_seat_from_counts(0, minimum_snapshot_open_counts_275, "", true), "open-hand minimum-fan behavior remains equivalent")
	scene.players[0]["melds"] = [["4W", "5W", "7W"]]
	check(scene.validated_scoring_tile_counts_from_counts(0, minimum_snapshot_open_counts_275, minimum_snapshot_open_hand_275.size()).is_empty() and not scene.can_win_for_seat_from_counts(0, minimum_snapshot_open_counts_275, "", true), "malformed melds are rejected before the snapshot path")

	print("--- FZH) ron normalized tile reuse ---")
	var normalized_win_source_276 := FileAccess.get_file_as_string("res://scripts/main_src/gameplay.gd.part")
	var normalized_win_start_276 := normalized_win_source_276.find("func can_win_for_seat(seat: int")
	var normalized_win_end_276 := normalized_win_source_276.find("func record_passed_win_tile", normalized_win_start_276)
	var normalized_win_function_276 := normalized_win_source_276.substr(normalized_win_start_276, normalized_win_end_276 - normalized_win_start_276)
	var normalized_ron_start_276 := normalized_win_source_276.find("func can_ron_for_seat(seat: int")
	var normalized_ron_end_276 := normalized_win_source_276.find("func can_win_for_seat_from_counts", normalized_ron_start_276)
	var normalized_ron_function_276 := normalized_win_source_276.substr(normalized_ron_start_276, normalized_ron_end_276 - normalized_ron_start_276)
	var normalized_ron_counts_start_276 := normalized_win_source_276.find("func can_ron_for_seat_from_counts")
	var normalized_ron_counts_end_276 := normalized_win_source_276.find("func can_win_for_seat_from_counts", normalized_ron_counts_start_276)
	var normalized_ron_counts_function_276 := normalized_win_source_276.substr(normalized_ron_counts_start_276, normalized_ron_counts_end_276 - normalized_ron_counts_start_276)
	var normalized_count_start_276 := normalized_win_source_276.find("func can_win_for_seat_from_counts")
	var normalized_count_end_276 := normalized_win_source_276.find("func _can_win_for_seat_from_counts_normalized", normalized_count_start_276)
	var normalized_count_function_276 := normalized_win_source_276.substr(normalized_count_start_276, normalized_count_end_276 - normalized_count_start_276)
	check(normalized_win_function_276.contains("var normalized_extra_tile := normalize_tile_code(extra_tile)"), "public win boundary normalizes the extra tile once")
	check(normalized_win_function_276.contains("_can_win_for_seat_from_counts_normalized(seat, hand_counts, normalized_extra_tile"), "public win boundary forwards its normalized tile directly")
	check(normalized_ron_function_276.contains("tile = normalize_tile_code(tile)"), "ron boundary normalizes the winning tile once")
	check(normalized_ron_function_276.contains("_can_ron_for_seat_from_counts_normalized(seat, hand_counts, tile)"), "ron boundary forwards its normalized tile directly")
	check(not normalized_ron_function_276.contains("\tif not can_win_for_seat_from_counts("), "ron boundary avoids re-entering the normalizing wrapper")
	check(normalized_ron_counts_function_276.contains("_can_ron_for_seat_from_counts_normalized(seat, hand_counts, normalize_tile_code(tile))"), "count ron boundary normalizes its tile once")
	check(not normalized_ron_counts_function_276.contains("\tif not can_win_for_seat_from_counts("), "count ron boundary avoids duplicate normalization")
	check(normalized_count_function_276.contains("normalize_tile_code(extra_tile)"), "direct count callers retain the normalization fallback")
	var normalized_ron_hand_276: Array = ["2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "1T", "1T", "E", "E"]
	scene.players[0]["hand"] = normalized_ron_hand_276.duplicate()
	scene.players[0]["melds"] = []
	scene.players[0]["discards"] = []
	scene.offline_passed_win_tiles.clear()
	var normalized_ron_counts_276: Array = scene.tile_counts(normalized_ron_hand_276)
	var normalized_canonical_ron_276: bool = scene.can_ron_for_seat(0, "1W")
	var normalized_alias_ron_276: bool = scene.can_ron_for_seat(0, "1M")
	var normalized_count_alias_ron_276: bool = scene.can_ron_for_seat_from_counts(0, normalized_ron_counts_276, "1M")
	check(normalized_canonical_ron_276 and normalized_alias_ron_276 and normalized_count_alias_ron_276, "canonical and legacy ron tiles keep the same valid result")
	check(scene.can_win_for_seat(0, "1M") and scene.can_win_for_seat_from_counts(0, normalized_ron_counts_276, "1M"), "public and count win boundaries preserve normalized aliases")
	check(not scene.can_ron_for_seat(0, "ZZ") and not scene.can_ron_for_seat_from_counts(0, normalized_ron_counts_276, "ZZ"), "invalid ron tiles remain rejected")

	print("--- FZI) AI ron normalized tile reuse ---")
	var ai_ron_normalized_source_277 := FileAccess.get_file_as_string("res://scripts/main_src/ai_brain.gd.part")
	var ai_ron_normalized_start_277 := ai_ron_normalized_source_277.find("func ai_ron_decision_report")
	var ai_ron_normalized_end_277 := ai_ron_normalized_source_277.find("func ai_tsumo_decision_report", ai_ron_normalized_start_277)
	var ai_ron_normalized_function_277 := ai_ron_normalized_source_277.substr(ai_ron_normalized_start_277, ai_ron_normalized_end_277 - ai_ron_normalized_start_277)
	check(ai_ron_normalized_function_277.contains("var normalized_tile := normalize_tile_code(tile)"), "ron report captures one normalized winning tile")
	check(ai_ron_normalized_function_277.contains("_can_win_for_seat_from_counts_normalized(seat, hand_counts, normalized_tile)"), "ron validation consumes the normalized winning tile")
	check(ai_ron_normalized_function_277.contains("tile_index_normalized(normalized_tile)"), "ron scoring consumes the normalized winning tile index")
	check(not ai_ron_normalized_function_277.contains("tile_index_normalized(normalize_tile_code(tile))"), "ron report avoids a second normalization")
	check(ai_ron_normalized_function_277.contains("remaining_by_tile.get(normalized_tile, 0)"), "ron wait comparison uses the normalized winning tile")
	var ai_ron_waiting_hand_277: Array = ["1W", "1W", "1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "9W", "9W"]
	scene.players[1]["hand"] = ai_ron_waiting_hand_277.duplicate()
	scene.players[1]["discards"] = []
	scene.players[1]["melds"] = []
	scene.offline_passed_win_tiles.clear()
	var ai_ron_canonical_report_277: Dictionary = scene.ai_ron_decision_report(1, "5W")
	var ai_ron_alias_report_277: Dictionary = scene.ai_ron_decision_report(1, "5M")
	check(bool(ai_ron_canonical_report_277.get("accept", false)) == bool(ai_ron_alias_report_277.get("accept", false)), "legacy ron aliases preserve the accept decision")
	check(str(ai_ron_canonical_report_277.get("reason", "")) == str(ai_ron_alias_report_277.get("reason", "")) and int(ai_ron_canonical_report_277.get("fan", -1)) == int(ai_ron_alias_report_277.get("fan", -2)), "legacy ron aliases preserve decision details")
	check(int(ai_ron_canonical_report_277.get("points", -1)) == int(ai_ron_alias_report_277.get("points", -2)) and int(ai_ron_canonical_report_277.get("wait_variety", -1)) == int(ai_ron_alias_report_277.get("wait_variety", -2)), "legacy ron aliases preserve score and wait metrics")
	var ai_ron_invalid_report_277: Dictionary = scene.ai_ron_decision_report(1, "ZZ")
	check(not bool(ai_ron_invalid_report_277.get("accept", true)) and str(ai_ron_invalid_report_277.get("reason", "")) == "未成和", "invalid ron tiles retain the rejection result")

	print("--- FZJ) AI tsumo normalized tile reuse ---")
	var ai_tsumo_normalized_source_278 := FileAccess.get_file_as_string("res://scripts/main_src/ai_brain.gd.part")
	var ai_tsumo_normalized_start_278 := ai_tsumo_normalized_source_278.find("func ai_tsumo_decision_report")
	var ai_tsumo_normalized_end_278 := ai_tsumo_normalized_source_278.find("func ai_tsumo_continue_discard", ai_tsumo_normalized_start_278)
	var ai_tsumo_normalized_function_278 := ai_tsumo_normalized_source_278.substr(ai_tsumo_normalized_start_278, ai_tsumo_normalized_end_278 - ai_tsumo_normalized_start_278)
	check(ai_tsumo_normalized_function_278.contains("var normalized_drawn_tile := normalize_tile_code(drawn_tile)"), "tsumo report captures one normalized drawn tile")
	check(ai_tsumo_normalized_function_278.contains("current_self_draw_tile(seat) != normalized_drawn_tile"), "tsumo validation consumes the normalized drawn tile")
	check(ai_tsumo_normalized_function_278.contains("tile_index_normalized(normalized_drawn_tile)"), "tsumo hand removal consumes the normalized tile index")
	check(not ai_tsumo_normalized_function_278.contains("tile_index_normalized(normalize_tile_code(drawn_tile))"), "tsumo report avoids a second normalization")
	check(ai_tsumo_normalized_function_278.contains("remaining_by_tile.get(normalized_drawn_tile, 0)"), "tsumo wait comparison uses the normalized drawn tile")
	check(ai_tsumo_normalized_function_278.contains("deal_in_risk_score(normalized_drawn_tile") and ai_tsumo_normalized_function_278.contains("discard_feed_risk_report(normalized_drawn_tile"), "tsumo continuation risk uses the normalized drawn tile")
	var ai_tsumo_tenpai_hand_278: Array = ["1W", "2W", "3W", "4W", "5W", "6W", "7B", "8B", "9B", "1T", "1T", "2T", "3T"]
	var ai_tsumo_hand_278: Array = ai_tsumo_tenpai_hand_278.duplicate()
	ai_tsumo_hand_278.append("1T")
	scene.current_seat = 3
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.players[3]["hand"] = ai_tsumo_hand_278
	scene.players[3]["discards"] = []
	scene.players[3]["melds"] = []
	scene.offline_last_draw = {"seat": 3, "tile": "1T", "source": "normal", "wall_empty": false, "serial": 278}
	scene.offline_self_draw_ready = {"seat": 3, "tile": "1T", "serial": 278}
	var ai_tsumo_canonical_report_278: Dictionary = scene.ai_tsumo_decision_report(3, "1T")
	var ai_tsumo_alias_report_278: Dictionary = scene.ai_tsumo_decision_report(3, "1S")
	check(bool(ai_tsumo_canonical_report_278.get("win_valid", false)) and bool(ai_tsumo_alias_report_278.get("win_valid", false)), "canonical and legacy tsumo tiles remain valid")
	check(bool(ai_tsumo_canonical_report_278.get("accept", false)) == bool(ai_tsumo_alias_report_278.get("accept", false)) and str(ai_tsumo_canonical_report_278.get("reason", "")) == str(ai_tsumo_alias_report_278.get("reason", "")), "legacy tsumo aliases preserve the decision")
	check(int(ai_tsumo_canonical_report_278.get("fan", -1)) == int(ai_tsumo_alias_report_278.get("fan", -2)) and int(ai_tsumo_canonical_report_278.get("points", -1)) == int(ai_tsumo_alias_report_278.get("points", -2)), "legacy tsumo aliases preserve score details")
	var ai_tsumo_invalid_report_278: Dictionary = scene.ai_tsumo_decision_report(3, "ZZ")
	check(not bool(ai_tsumo_invalid_report_278.get("accept", true)) and str(ai_tsumo_invalid_report_278.get("reason", "")) == "非当前摸牌", "invalid tsumo tiles retain the legacy rejection result")

	print("--- FZK) claim normalized tile-index reuse ---")
	var claim_normalized_base_source_279 := FileAccess.get_file_as_string("res://scripts/main_base.gd")
	check(claim_normalized_base_source_279.contains("func tile_count_from_counts(tile: String, counts: Array, tile_index_snapshot: int = -2)"), "count lookup accepts an optional tile index")
	check(claim_normalized_base_source_279.contains("if index == -2:"), "count lookup keeps its normalization fallback")
	var claim_normalized_source_279 := FileAccess.get_file_as_string("res://scripts/main_src/gameplay.gd.part")
	var claim_normalized_options_start_279 := claim_normalized_source_279.find("func get_claim_options")
	var claim_normalized_options_end_279 := claim_normalized_source_279.find("func is_valid_offline_claim", claim_normalized_options_start_279)
	var claim_normalized_options_function_279 := claim_normalized_source_279.substr(claim_normalized_options_start_279, claim_normalized_options_end_279 - claim_normalized_options_start_279)
	check(claim_normalized_options_function_279.contains("var normalized_tile := normalize_tile_code(tile)"), "claim options captures one normalized tile")
	check(claim_normalized_options_function_279.contains("var tile_index_snapshot := tile_index_normalized(normalized_tile)"), "claim options captures one tile index")
	check(claim_normalized_options_function_279.contains("_can_ron_for_seat_from_counts_normalized(seat, hand_counts, normalized_tile)"), "claim options reuses the normalized ron boundary")
	check(claim_normalized_options_function_279.contains("tile_count_from_counts(normalized_tile, hand_counts, tile_index_snapshot)"), "claim options reuses the captured count index")
	check(claim_normalized_options_function_279.contains("get_chi_choices_from_counts(hand_counts, normalized_tile, tile_index_snapshot)"), "claim options reuses the captured chi index")
	var claim_normalized_validation_start_279 := claim_normalized_source_279.find("func _is_valid_offline_claim_normalized")
	var claim_normalized_validation_end_279 := claim_normalized_source_279.find("func apply_offline_claim", claim_normalized_validation_start_279)
	var claim_normalized_validation_function_279 := claim_normalized_source_279.substr(claim_normalized_validation_start_279, claim_normalized_validation_end_279 - claim_normalized_validation_start_279)
	check(claim_normalized_validation_function_279.contains("var tile_index_snapshot := tile_index_normalized(tile)"), "claim validation captures one tile index")
	check(claim_normalized_validation_function_279.contains("_can_ron_for_seat_from_counts_normalized(seat, hand_counts, tile)"), "claim validation reuses normalized ron validation")
	check(claim_normalized_validation_function_279.contains("tile_count_from_counts(tile, hand_counts, tile_index_snapshot)"), "claim validation reuses the captured count index")
	check(claim_normalized_validation_function_279.contains("get_chi_choices_from_counts(hand_counts, tile, tile_index_snapshot)"), "claim validation reuses the captured chi index")
	var claim_normalized_chi_start_279 := claim_normalized_source_279.find("func best_chi_choice")
	var claim_normalized_chi_end_279 := claim_normalized_source_279.find("func play_ai_discard_fly_animation", claim_normalized_chi_start_279)
	var claim_normalized_chi_source_279 := claim_normalized_source_279.substr(claim_normalized_chi_start_279, claim_normalized_chi_end_279 - claim_normalized_chi_start_279)
	check(claim_normalized_chi_source_279.contains("tile_index_snapshot: int = -2"), "chi selection keeps a direct-call index fallback")
	check(claim_normalized_chi_source_279.contains("get_chi_choices_from_counts(hand_counts, normalized_tile, index)"), "chi selection forwards its captured index")
	var claim_normalized_hand_279: Array = ["3W", "4W", "7W", "8W", "9W", "1T", "2T", "3T", "4T", "5T", "6T", "E", "E"]
	scene.offline_phase = "resolving"
	scene.players[1]["hand"] = claim_normalized_hand_279.duplicate()
	scene.players[0]["discards"] = ["5W"]
	scene.last_discard = "5W"
	scene.last_discard_seat = 0
	var claim_normalized_counts_279: Array = scene.tile_counts(claim_normalized_hand_279)
	var claim_normalized_canonical_279: Array = scene.get_claim_options(1, 0, "5W", claim_normalized_counts_279)
	var claim_normalized_alias_279: Array = scene.get_claim_options(1, 0, "5M", claim_normalized_counts_279)
	check(claim_normalized_canonical_279 == claim_normalized_alias_279 and claim_normalized_canonical_279.has("chi"), "claim options preserve canonical and legacy aliases")
	var claim_normalized_chi_279: Array = scene.get_chi_choices_from_counts(claim_normalized_counts_279, "5M", scene.tile_index("5W"))
	check(claim_normalized_chi_279 == scene.get_chi_choices_from_counts(claim_normalized_counts_279, "5W") and not claim_normalized_chi_279.is_empty(), "explicit chi index preserves generated meld choices")
	check(scene.best_chi_choice(claim_normalized_hand_279, "5W") == scene.best_chi_choice(claim_normalized_hand_279, "5M"), "best chi selection preserves normalized aliases")
	check(scene.is_valid_offline_claim(1, 0, "5M", "chi", claim_normalized_chi_279[0]), "claim validation accepts the normalized alias")
	check(scene.get_claim_options(1, 0, "ZZ", claim_normalized_counts_279).is_empty(), "invalid claim tiles remain outside response options")

	print("--- FZL) claim chooser normalized tile-index snapshot reuse ---")
	var claim_chooser_source_280 := FileAccess.get_file_as_string("res://scripts/main_src/ai_brain.gd.part")
	var claim_chooser_start_280 := claim_chooser_source_280.find("func choose_ai_claim")
	var claim_chooser_end_280 := claim_chooser_source_280.find("func claim_turn_offset", claim_chooser_start_280)
	var claim_chooser_function_280 := claim_chooser_source_280.substr(claim_chooser_start_280, claim_chooser_end_280 - claim_chooser_start_280)
	check(claim_chooser_function_280.contains("var normalized_tile := normalize_tile_code(tile)"), "claim chooser normalizes the discard once")
	check(claim_chooser_function_280.contains("var tile_index_snapshot := tile_index_normalized(normalized_tile)"), "claim chooser resolves the discard index once")
	check(claim_chooser_function_280.contains("_get_claim_options_normalized(seat, from_seat, normalized_tile, hand_counts, tile_index_snapshot)"), "claim chooser forwards the normalized claim snapshot")
	check(claim_chooser_function_280.contains("claim_context[\"claim_tile\"] = normalized_tile") and claim_chooser_function_280.contains("claim_context[\"claim_tile_index\"] = tile_index_snapshot"), "claim context publishes the normalized claim snapshot")
	check(not claim_chooser_function_280.contains("get_claim_options(seat, from_seat, tile, hand_counts)"), "claim chooser avoids the normalizing options wrapper")
	var claim_chooser_gameplay_source_280 := FileAccess.get_file_as_string("res://scripts/main_src/gameplay.gd.part")
	var claim_chooser_options_start_280 := claim_chooser_gameplay_source_280.find("func get_claim_options")
	var claim_chooser_options_end_280 := claim_chooser_gameplay_source_280.find("func is_valid_offline_claim", claim_chooser_options_start_280)
	var claim_chooser_options_function_280 := claim_chooser_gameplay_source_280.substr(claim_chooser_options_start_280, claim_chooser_options_end_280 - claim_chooser_options_start_280)
	check(claim_chooser_options_function_280.contains("func _get_claim_options_normalized"), "claim options exposes a normalized internal boundary")
	check(claim_chooser_options_function_280.contains("return _get_claim_options_normalized(seat, from_seat, normalized_tile, hand_counts, tile_index_snapshot)"), "public claim options keeps its normalization fallback")
	check(claim_chooser_options_function_280.contains("tile_count_from_counts(normalized_tile, hand_counts, tile_index_snapshot)"), "normalized claim options consumes the supplied tile index")
	var claim_chooser_chi_start_280 := claim_chooser_source_280.find("func best_ai_chi_claim")
	var claim_chooser_chi_end_280 := claim_chooser_source_280.find("func ai_chi_choice_tiebreak", claim_chooser_chi_start_280)
	var claim_chooser_chi_function_280 := claim_chooser_source_280.substr(claim_chooser_chi_start_280, claim_chooser_chi_end_280 - claim_chooser_chi_start_280)
	check(claim_chooser_chi_function_280.contains("get_chi_choices_from_counts(claim_context.get(\"hand_counts\", []), tile, claim_tile_index_snapshot)"), "AI chi selection consumes the claim context index")
	var claim_chooser_report_start_280 := claim_chooser_source_280.find("func build_ai_claim_report")
	var claim_chooser_report_end_280 := claim_chooser_source_280.find("func ai_claim_meld_bonus", claim_chooser_report_start_280)
	var claim_chooser_report_function_280 := claim_chooser_source_280.substr(claim_chooser_report_start_280, claim_chooser_report_end_280 - claim_chooser_report_start_280)
	check(claim_chooser_report_function_280.contains("claim_tile_index_snapshot = int(claim_context.get(\"claim_tile_index\", -2))"), "claim reports consume the shared claim index")
	var claim_chooser_human_source_280 := claim_chooser_gameplay_source_280.substr(claim_chooser_gameplay_source_280.find("func human_claim_candidate_reports"), claim_chooser_gameplay_source_280.find("func human_claim_report_score") - claim_chooser_gameplay_source_280.find("func human_claim_candidate_reports"))
	check(claim_chooser_human_source_280.contains("best_chi_choice_from_counts(claim_context.get(\"hand_counts\", []), tile, tile_index_snapshot)"), "human claim reports forward the pending tile index")
	var claim_chooser_hand_280: Array = ["3W", "4W", "7W", "8W", "9W", "1T", "2T", "3T", "4T", "5T", "6T", "E", "E"]
	scene.offline_phase = "resolving"
	scene.players[1]["hand"] = claim_chooser_hand_280.duplicate()
	scene.players[0]["discards"] = ["5W"]
	scene.last_discard = "5W"
	scene.last_discard_seat = 0
	var claim_chooser_counts_280: Array = scene.tile_counts(claim_chooser_hand_280)
	var claim_chooser_index_280: int = scene.tile_index("5W")
	var claim_chooser_public_280: Array = scene.get_claim_options(1, 0, "5W", claim_chooser_counts_280)
	var claim_chooser_fast_280: Array = scene._get_claim_options_normalized(1, 0, "5W", claim_chooser_counts_280, claim_chooser_index_280)
	check(claim_chooser_public_280 == claim_chooser_fast_280 and claim_chooser_public_280.has("chi"), "normalized claim options preserve the public result")
	var claim_chooser_context_280: Dictionary = scene.make_ai_claim_context(1, [], claim_chooser_counts_280, 0)
	claim_chooser_context_280["claim_tile"] = "5W"
	claim_chooser_context_280["claim_tile_index"] = claim_chooser_index_280
	var claim_chooser_choices_280: Array = scene.get_chi_choices_from_counts(claim_chooser_counts_280, "5W", claim_chooser_index_280)
	var claim_chooser_best_280: Dictionary = scene.best_ai_chi_claim(1, "5W", 1, claim_chooser_context_280)
	check(not claim_chooser_choices_280.is_empty() and not claim_chooser_best_280.is_empty(), "AI chi selection remains valid with the shared claim snapshot")

	print("--- FZM) added-gang normalized tile-index reuse ---")
	var gang_threat_source_281 := FileAccess.get_file_as_string("res://scripts/main_src/ai_brain.gd.part")
	var gang_threat_start_281 := gang_threat_source_281.find("func added_gang_rob_threat_report")
	var gang_threat_end_281 := gang_threat_source_281.find("func touch_ai_rob_threat_cache_key", gang_threat_start_281)
	var gang_threat_function_281 := gang_threat_source_281.substr(gang_threat_start_281, gang_threat_end_281 - gang_threat_start_281)
	check(gang_threat_function_281.contains("var normalized_tile := normalize_tile_code(tile)"), "added-gang risk normalizes the tile once")
	check(gang_threat_function_281.contains("var tile_index_snapshot := tile_index_normalized(normalized_tile)"), "added-gang risk resolves the tile index once")
	check(gang_threat_function_281.contains("%d|%d|%s\" % [ai_state_revision, gang_seat, normalized_tile]"), "added-gang cache keys use the normalized tile")
	check(gang_threat_function_281.contains("visible_tile_count_from_counts(normalized_tile, visible_counts, tile_index_snapshot)"), "visible risk count consumes the captured index")
	check(gang_threat_function_281.contains("single_opponent_deal_in_risk_components(normalized_tile, gang_seat, seat, visible, visible_counts, eval_context, tile_index_snapshot)"), "opponent risk branches consume the normalized snapshot")
	var gang_threat_cache_before_281: int = scene.ai_rob_threat_cache.size()
	scene.clear_threat_report_cache()
	scene.players[1]["melds"] = [["5W", "5W", "5W"], ["6W", "6W", "6W"], ["7W", "7W", "7W"]]
	scene.players[1]["discards"] = ["1W", "2W", "3W", "8W", "9W", "E", "S", "W", "N", "P", "F", "C"]
	var gang_threat_canonical_281: Dictionary = scene.added_gang_rob_threat_report(0, "4W")
	var gang_threat_cache_size_281: int = scene.ai_rob_threat_cache.size()
	var gang_threat_alias_281: Dictionary = scene.added_gang_rob_threat_report(0, "4M")
	check(gang_threat_canonical_281 == gang_threat_alias_281, "legacy tile aliases preserve the public risk report")
	check(gang_threat_cache_size_281 == 1 and scene.ai_rob_threat_cache.size() == gang_threat_cache_size_281, "canonical and legacy tiles share one threat cache entry")
	var gang_threat_invalid_281: Dictionary = scene.added_gang_rob_threat_report(0, "ZZ")
	var gang_threat_invalid_again_281: Dictionary = scene.added_gang_rob_threat_report(0, "ZZ")
	check(gang_threat_invalid_281.has("risk_score") and gang_threat_invalid_281.has("risk_details") and float(gang_threat_invalid_281.get("risk_score", -1.0)) >= 0.0 and gang_threat_invalid_281 == gang_threat_invalid_again_281, "invalid gang tiles retain a stable non-negative report")
	check(gang_threat_cache_before_281 >= 0, "added-gang cache remains available after prior batch checks")

	print("--- FZN) discard risk-summary tile-index forwarding ---")
	var risk_summary_source_282 := FileAccess.get_file_as_string("res://scripts/main_src/ai_brain.gd.part")
	var risk_summary_report_start_282 := risk_summary_source_282.find("func build_ai_discard_report")
	var risk_summary_report_end_282 := risk_summary_source_282.find("func wait_value_metrics", risk_summary_report_start_282)
	var risk_summary_report_function_282 := risk_summary_source_282.substr(risk_summary_report_start_282, risk_summary_report_end_282 - risk_summary_report_start_282)
	check(risk_summary_report_function_282.contains("deal_in_risk_summary(tile, seat, visible_counts, risk_vector, eval_context, candidate_tile_index_snapshot)"), "discard reports forward the candidate index to risk summaries")
	var risk_summary_start_282 := risk_summary_source_282.find("func deal_in_risk_summary")
	var risk_summary_end_282 := risk_summary_source_282.find("func tile_risk_vector", risk_summary_start_282)
	var risk_summary_function_282 := risk_summary_source_282.substr(risk_summary_start_282, risk_summary_end_282 - risk_summary_start_282)
	check(risk_summary_function_282.contains("tile_index_snapshot: int = -2"), "risk summaries keep an optional index for direct callers")
	check(risk_summary_function_282.contains("tile_risk_vector(tile, seat, visible_counts_snapshot, eval_context, tile_index_snapshot)"), "risk summary fallback consumes the supplied index")
	var risk_summary_visible_282: Array = scene.make_empty_tile_counts()
	var risk_summary_context_282: Dictionary = scene.make_ai_evaluation_context(0, risk_summary_visible_282)
	var risk_summary_index_282: int = scene.tile_index("4W")
	var risk_summary_fallback_282: Dictionary = scene.deal_in_risk_summary("4W", 0, risk_summary_visible_282, {}, risk_summary_context_282)
	var risk_summary_explicit_282: Dictionary = scene.deal_in_risk_summary("4M", 0, risk_summary_visible_282, {}, risk_summary_context_282, risk_summary_index_282)
	check(is_equal_approx(float(risk_summary_fallback_282.get("score", 0.0)), float(risk_summary_explicit_282.get("score", 0.0))), "explicit risk-summary indexes preserve the score")
	check(risk_summary_fallback_282.get("danger_source", {}) == risk_summary_explicit_282.get("danger_source", {}), "explicit risk-summary indexes preserve the danger source")
	var risk_summary_cached_vector_282: Dictionary = {"score": 17.5, "danger_source": {"opponent": 1, "reason": "cached"}}
	var risk_summary_cached_282: Dictionary = scene.deal_in_risk_summary("4W", 0, risk_summary_visible_282, risk_summary_cached_vector_282, risk_summary_context_282, risk_summary_index_282)
	check(float(risk_summary_cached_282.get("score", 0.0)) == 17.5 and risk_summary_cached_282.get("danger_source", {}).get("reason", "") == "cached", "precomputed risk vectors keep the summary fast path")
	var risk_summary_invalid_282: Dictionary = scene.deal_in_risk_summary("ZZ", 0, risk_summary_visible_282, {}, risk_summary_context_282, -1)
	check(risk_summary_invalid_282.has("score") and float(risk_summary_invalid_282.get("score", -1.0)) >= 0.0, "invalid risk-summary tiles retain the bounded fallback")

	print("--- FZO) discard count-vector key reuse ---")
	var count_key_source_283 := FileAccess.get_file_as_string("res://scripts/main_src/ai_brain.gd.part")
	var count_key_report_start_283 := count_key_source_283.find("func build_ai_discard_report")
	var count_key_report_end_283 := count_key_source_283.find("func wait_value_metrics", count_key_report_start_283)
	var count_key_report_function_283 := count_key_source_283.substr(count_key_report_start_283, count_key_report_end_283 - count_key_report_start_283)
	check(count_key_report_function_283.contains("var simulated_counts_key := counts_compact_key(simulated_counts)"), "discard reports build one candidate count key")
	check(count_key_report_function_283.contains("calculate_min_shanten_from_counts_with_memo(simulated_counts, open_melds, simulated_counts_key"), "shanten probes consume the shared count key")
	check(count_key_report_function_283.contains("effective_tile_metrics(simulated, open_melds, seat, shanten, visible_counts, simulated_counts, str(eval_context.get(\"visible_counts_key\", \"\")), simulated_counts_key)"), "effective-tile probes consume the shared count key")
	check(count_key_report_function_283.contains("hand_plan_features_from_counts(simulated_counts, simulated_tile_count, true, simulated_counts_key)"), "route features consume the shared count key")
	var count_key_feature_start_283 := count_key_source_283.find("func hand_plan_features_from_counts")
	var count_key_feature_end_283 := count_key_source_283.find("func touch_hand_plan_features_cache_key", count_key_feature_start_283)
	var count_key_feature_function_283 := count_key_source_283.substr(count_key_feature_start_283, count_key_feature_end_283 - count_key_feature_start_283)
	check(count_key_feature_function_283.contains("counts_key_override: String = \"\""), "route feature helper keeps a direct-call key fallback")
	check(count_key_feature_function_283.contains("var counts_key := counts_key_override if counts_key_override != \"\" else counts_compact_key(counts)"), "route feature cache consumes the supplied key")
	var count_key_effective_start_283 := count_key_source_283.find("func effective_tile_metrics")
	var count_key_effective_end_283 := count_key_source_283.find("func touch_effective_tiles_cache_key", count_key_effective_start_283)
	var count_key_effective_function_283 := count_key_source_283.substr(count_key_effective_start_283, count_key_effective_end_283 - count_key_effective_start_283)
	check(count_key_effective_function_283.contains("hand_counts_key_override: String = \"\""), "effective-tile helper keeps a direct-call key fallback")
	check(count_key_effective_function_283.contains("var hand_counts_key := hand_counts_key_override if hand_counts_key_override != \"\" else counts_compact_key(hand_counts)"), "effective-tile cache consumes the supplied key")
	var count_key_hand_283: Array = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "E", "E", "R", "R"]
	var count_key_counts_283: Array = scene.tile_counts(count_key_hand_283)
	var count_key_value_283: String = scene.counts_compact_key(count_key_counts_283)
	var count_key_legacy_features_283: Dictionary = scene.hand_plan_features_from_counts(count_key_counts_283, count_key_hand_283.size(), true)
	var count_key_keyed_features_283: Dictionary = scene.hand_plan_features_from_counts(count_key_counts_283, count_key_hand_283.size(), true, count_key_value_283)
	check(count_key_legacy_features_283 == count_key_keyed_features_283, "explicit route-feature keys preserve all feature values")
	var count_key_visible_283: Array = scene.make_empty_tile_counts()
	var count_key_legacy_metrics_283: Dictionary = scene.effective_tile_metrics(count_key_hand_283, 0, 1, 99, count_key_visible_283, count_key_counts_283)
	var count_key_keyed_metrics_283: Dictionary = scene.effective_tile_metrics(count_key_hand_283, 0, 1, 99, count_key_visible_283, count_key_counts_283, "", count_key_value_283)
	check(count_key_legacy_metrics_283 == count_key_keyed_metrics_283, "explicit effective-tile keys preserve all metrics")

	print("--- FZP) claim shape-route feature fusion ---")
	var claim_fusion_source_284 := FileAccess.get_file_as_string("res://scripts/main_src/ai_brain.gd.part")
	var claim_fusion_context_start_284 := claim_fusion_source_284.find("func make_ai_claim_context")
	var claim_fusion_context_end_284 := claim_fusion_source_284.find("func ai_context_pressure_context", claim_fusion_context_start_284)
	var claim_fusion_context_function_284 := claim_fusion_source_284.substr(claim_fusion_context_start_284, claim_fusion_context_end_284 - claim_fusion_context_start_284)
	check(claim_fusion_context_function_284.contains("var before_features: Dictionary = hand_plan_features_from_counts(hand_counts, hand.size(), true, hand_counts_key)"), "claim context fuses the before shape and route features")
	check(claim_fusion_context_function_284.contains("hand_plan_eval_for_seat_from_counts(seat, hand_counts, hand.size(), meld_tile_indices, before_features)"), "claim context forwards the fused feature snapshot")
	check(claim_fusion_context_function_284.contains("float(before_shape_metrics.get(\"value\", 0.0))"), "claim context consumes the fused shape value")
	var claim_fusion_report_start_284 := claim_fusion_source_284.find("func build_ai_claim_report")
	var claim_fusion_report_end_284 := claim_fusion_source_284.find("func ai_claim_meld_bonus", claim_fusion_report_start_284)
	var claim_fusion_report_function_284 := claim_fusion_source_284.substr(claim_fusion_report_start_284, claim_fusion_report_end_284 - claim_fusion_report_start_284)
	check(claim_fusion_report_function_284.contains("var after_features: Dictionary = hand_plan_features_from_counts(after_counts, after.size(), true, after_counts_key)"), "claim reports build one after-claim feature snapshot")
	check(claim_fusion_report_function_284.contains("var after_shape_metrics: Dictionary = ai_hand_shape_metrics_from_counts(after_counts, after_features)"), "claim reports consume the fused after-claim shape value")
	check(claim_fusion_report_function_284.contains("plan_report_with_extra_melds(seat, after_counts, after.size(), extra_meld_tiles, meld_tile_indices_snapshot, extra_meld_tile_indices_snapshot, after_features)"), "claim reports forward features into incremental route evaluation")
	check(claim_fusion_report_function_284.contains("float(after_shape_metrics.get(\"value\", 0.0))"), "claim reports avoid a second after-claim shape scan")
	var claim_fusion_route_start_284 := claim_fusion_source_284.find("func plan_report_with_extra_melds")
	var claim_fusion_route_end_284 := claim_fusion_source_284.find("func hand_plan_report_for_seat", claim_fusion_route_start_284)
	var claim_fusion_route_function_284 := claim_fusion_source_284.substr(claim_fusion_route_start_284, claim_fusion_route_end_284 - claim_fusion_route_start_284)
	check(claim_fusion_route_function_284.contains("base_features_snapshot: Dictionary = {}"), "route helper keeps an optional feature snapshot fallback")
	check(claim_fusion_route_function_284.contains("hand_plan_features_add_tile(plan_features, index, previous_amount)"), "route helper adds exposed tiles incrementally")
	check(claim_fusion_route_function_284.contains("hand_plan_report_from_features(plan_counts, total, plan_features)"), "route helper consumes the incrementally updated features")
	var claim_fusion_hand_284: Array = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "E", "E", "R"]
	var claim_fusion_counts_284: Array = scene.tile_counts(claim_fusion_hand_284)
	scene.players[1]["melds"] = [["1W", "2W", "3W"]]
	var claim_fusion_existing_284: Array = scene.hand_plan_meld_tile_indices_for_seat(1)
	var claim_fusion_extra_tiles_284: Array = ["5B", "5B", "5B"]
	var claim_fusion_extra_indexes_284: Array[int] = [scene.tile_index("5B"), scene.tile_index("5B"), scene.tile_index("5B")]
	var claim_fusion_legacy_route_284: Dictionary = scene.plan_report_with_extra_melds(1, claim_fusion_counts_284, claim_fusion_hand_284.size(), claim_fusion_extra_tiles_284, claim_fusion_existing_284, claim_fusion_extra_indexes_284)
	var claim_fusion_features_284: Dictionary = scene.hand_plan_features_from_counts(claim_fusion_counts_284, claim_fusion_hand_284.size(), true)
	var claim_fusion_snapshot_route_284: Dictionary = scene.plan_report_with_extra_melds(1, claim_fusion_counts_284, claim_fusion_hand_284.size(), claim_fusion_extra_tiles_284, claim_fusion_existing_284, claim_fusion_extra_indexes_284, claim_fusion_features_284)
	check(claim_fusion_legacy_route_284 == claim_fusion_snapshot_route_284, "incremental route features preserve the full route report")
	scene.players[1]["melds"] = []
	var claim_fusion_context_hand_284: Array = ["5W", "5W", "1W", "2W", "3W", "4W", "6W", "7W", "8W", "9W", "E", "E", "R"]
	scene.players[1]["hand"] = claim_fusion_context_hand_284.duplicate()
	var claim_fusion_visible_284: Array = scene.make_empty_tile_counts()
	var claim_fusion_context_284: Dictionary = scene.make_ai_claim_context(1, claim_fusion_visible_284, scene.tile_counts(claim_fusion_context_hand_284), 0)
	var claim_fusion_context_counts_284: Array = scene.tile_counts(claim_fusion_context_hand_284)
	var claim_fusion_legacy_before_score_284: float = scene.evaluate_ai_hand_from_counts(claim_fusion_context_counts_284) + float(scene.hand_plan_eval_for_seat_from_counts(1, claim_fusion_context_counts_284, claim_fusion_context_hand_284.size()).get("score", 0.0)) * 0.35 * float(claim_fusion_context_284.get("route_focus", 1.0))
	check(is_equal_approx(float(claim_fusion_context_284.get("before_score", 0.0)), claim_fusion_legacy_before_score_284), "claim context preserves the legacy before score")

	print("--- FZQ) discard candidate shanten batch memo ---")
	var candidate_memo_source_285 := FileAccess.get_file_as_string("res://scripts/main_src/ai_brain.gd.part")
	var candidate_memo_post_start_285 := candidate_memo_source_285.find("func best_ai_post_claim_discard_report")
	var candidate_memo_post_end_285 := candidate_memo_source_285.find("func choose_ai_rob_gang", candidate_memo_post_start_285)
	var candidate_memo_post_function_285 := candidate_memo_source_285.substr(candidate_memo_post_start_285, candidate_memo_post_end_285 - candidate_memo_post_start_285)
	check(candidate_memo_post_function_285.contains("var post_claim_shanten_memo: Dictionary = {}"), "post-claim candidate batches allocate one recursive memo")
	check(candidate_memo_post_function_285.contains("candidate_index, post_claim_shanten_memo)"), "post-claim fast reports reuse the candidate memo")
	check(candidate_memo_post_function_285.contains("candidate_index, -99, {}, post_claim_shanten_memo)"), "post-claim complete reports reuse the candidate memo")
	var candidate_memo_fast_start_285 := candidate_memo_source_285.find("func build_ai_fast_post_claim_discard_report")
	var candidate_memo_fast_end_285 := candidate_memo_source_285.find("func choose_ai_rob_gang", candidate_memo_fast_start_285)
	var candidate_memo_fast_function_285 := candidate_memo_source_285.substr(candidate_memo_fast_start_285, candidate_memo_fast_end_285 - candidate_memo_fast_start_285)
	check(candidate_memo_fast_function_285.contains("calculate_min_shanten_from_counts_with_memo(simulated_counts, open_melds, \"\", shanten_search_memo)"), "fast post-claim shanten uses the supplied memo")
	var candidate_memo_discard_start_285 := candidate_memo_source_285.find("func get_ai_discard_reports")
	var candidate_memo_discard_end_285 := candidate_memo_source_285.find("func sort_ai_discard_reports", candidate_memo_discard_start_285)
	var candidate_memo_discard_function_285 := candidate_memo_source_285.substr(candidate_memo_discard_start_285, candidate_memo_discard_end_285 - candidate_memo_discard_start_285)
	check(candidate_memo_discard_function_285.contains("var discard_shanten_memo: Dictionary = {}") and candidate_memo_discard_function_285.contains("calculate_min_shanten_from_counts_with_memo(simulated_counts, open_melds, \"\", discard_shanten_memo)"), "discard candidates reuse one recursive memo")

	print("--- FZR) threat-card safety tile-index forwarding ---")
	var safety_forward_source_286 := FileAccess.get_file_as_string("res://scripts/main_src/core.gd.part")
	var safety_forward_start_286 := safety_forward_source_286.find("func threat_safe_tile_labels")
	var safety_forward_end_286 := safety_forward_source_286.find("func visible_tile_counts_state_cache_key", safety_forward_start_286)
	var safety_forward_function_286 := safety_forward_source_286.substr(safety_forward_start_286, safety_forward_end_286 - safety_forward_start_286)
	check(safety_forward_function_286.contains("var tile_index_snapshot := tile_index(tile)"), "general threat cards capture the candidate safety index")
	check(safety_forward_function_286.contains("safety = tile_safety_label(tile, seat, visible_counts, eval_context, tile_index_snapshot)"), "general threat cards forward the candidate index to safety labels")
	var safety_forward_visible_286: Array = scene.make_empty_tile_counts()
	var safety_forward_context_286: Dictionary = scene.make_ai_evaluation_context(0, safety_forward_visible_286)
	var safety_forward_hand_286: Array = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "E", "S"]
	scene.players[0]["hand"] = safety_forward_hand_286
	scene.players[1]["discards"] = ["1W", "4W", "7W"]
	var safety_forward_labels_286: Array = scene.threat_safe_tile_labels(0, "suit", 0, 4, safety_forward_context_286)
	var safety_forward_repeat_286: Array = scene.threat_safe_tile_labels(0, "suit", 0, 4, safety_forward_context_286)
	check(safety_forward_labels_286.size() > 0 and safety_forward_labels_286.size() <= 4, "general threat cards keep a bounded safety list")
	check(safety_forward_labels_286 == safety_forward_repeat_286, "forwarded safety indexes preserve deterministic labels")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
