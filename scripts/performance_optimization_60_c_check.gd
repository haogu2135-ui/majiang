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

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
