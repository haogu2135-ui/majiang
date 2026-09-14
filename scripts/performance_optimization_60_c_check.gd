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
	var exit_continue_button_194 := exit_confirm_dialog_194.get_node_or_null("HBoxContainer/ExitConfirmContinueButton") as Button if exit_confirm_dialog_194 != null else null
	check(exit_confirm_dialog_194 != null and exit_confirm_dialog_194.get_meta("viewport_snapshot", Vector2.ZERO) == expected_exit_confirm_viewport_194, "退出确认对话框发布本次绘制的 viewport 快照")
	check(exit_confirm_dialog_194 != null and str(exit_confirm_dialog_194.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "退出确认对话框声明每次绘制只读取一次 viewport")
	check(exit_confirm_message_194 != null and exit_continue_button_194 != null and exit_confirm_message_194.text != "", "退出确认消息和继续按钮仍完整构建")
	scene.exit_confirm_decision_locked = true
	check(exit_confirm_dialog_194 != null and exit_confirm_dialog_194.get_meta("viewport_snapshot", Vector2.ZERO) == expected_exit_confirm_viewport_194, "后续退出状态不会改写已完成的对话框快照")
	exit_confirm_snapshot_root_194.queue_free()
	scene.clear_screen()
	scene.root_layer = null

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
