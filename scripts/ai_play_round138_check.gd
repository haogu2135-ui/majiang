extends SceneTree
## Round 138: hand rendering reuses one interaction-state snapshot.

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


func rendered_hand_tiles(root_node: Control) -> Array[Control]:
	var result: Array[Control] = []
	for node in root_node.find_children("HandTile_*", "Control", true, false):
		var tile := node as Control
		if tile != null:
			result.append(tile)
	return result


func run() -> void:
	print("=== ai_play_round138 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.offline_sim_quiet = true
	scene.show_hand_hint = false
	scene.ai_assist_enabled = false
	scene.current_seat = 0
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[0]["hand"] = ["1W", "2W", "3W", "1T", "2T", "3T", "1B", "2B", "3B", "E", "E", "R", "H1", "H2"]
	scene.wall.clear()
	for _i in range(60):
		scene.wall.append("1B")

	var hand_root := Control.new()
	hand_root.name = "HandInteractionSnapshotRoot"
	hand_root.size = Vector2(1280.0, 720.0)
	root.add_child(hand_root)
	scene.root_layer = hand_root
	var expected_can_discard: bool = scene.can_self_discard()
	var expected_pending_claim: bool = scene.has_pending_claim_window()
	var expected_pending_danger: bool = scene.has_pending_danger_discard()
	scene.draw_hand(hand_root)

	var hand_box := hand_root.get_node_or_null("HandTray/HandTrayTiles") as Control
	check(hand_box != null, "hand render creates the tile row for the interaction snapshot")
	if hand_box != null:
		check(str(hand_box.get_meta("hand_interaction_snapshot_policy", "")) == "one_action_state_snapshot_per_draw", "hand row declares one action-state snapshot per draw")
		check(bool(hand_box.get_meta("hand_can_self_discard_snapshot", false)) == expected_can_discard, "hand row records the turn-state snapshot")
		check(bool(hand_box.get_meta("hand_pending_claim_window_snapshot", false)) == expected_pending_claim, "hand row records the claim-window snapshot")
		check(bool(hand_box.get_meta("hand_pending_danger_discard_snapshot", false)) == expected_pending_danger, "hand row records the danger-discard snapshot")
		check(str(hand_box.get_meta("interaction_state", "")) == "interactive", "interactive hand keeps its native row state")

	var first_tiles := rendered_hand_tiles(hand_root)
	var all_tiles_interactive: bool = first_tiles.size() == scene.get_self_hand().size()
	for tile in first_tiles:
		if str(tile.get_meta("focus_state", "")) != "available":
			all_tiles_interactive = false
	check(all_tiles_interactive, "all hand tiles consume the same interactive snapshot")

	scene.offline_phase = "resolving"
	scene.offline_turn_needs_draw = true
	var old_tray := hand_root.get_node_or_null("HandTray") as Control
	if old_tray != null:
		old_tray.queue_free()
	await process_frame
	scene.draw_hand(hand_root)
	var read_only_box := hand_root.get_node_or_null("HandTray/HandTrayTiles") as Control
	check(read_only_box != null and str(read_only_box.get_meta("interaction_state", "")) == "read_only", "a later render takes a fresh snapshot after the turn changes")
	var read_only_tiles := rendered_hand_tiles(hand_root)
	var all_tiles_read_only: bool = read_only_tiles.size() == scene.get_self_hand().size()
	for tile in read_only_tiles:
		if str(tile.get_meta("focus_state", "")) != "read_only":
			all_tiles_read_only = false
	check(all_tiles_read_only, "fresh read-only snapshot propagates to every tile")

	hand_root.queue_free()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
