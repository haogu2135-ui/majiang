extends SceneTree
## Round 163: action rendering reuses pending-state snapshots.

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
		"bot": false,
	}


func run() -> void:
	print("=== ai_play_round163 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.ai_assist_enabled = false
	scene.current_seat = 0
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[0]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "2T", "3T", "5B", "E"]

	var action_root := Control.new()
	action_root.name = "ActionStateSnapshotRoot"
	action_root.size = Vector2(1280.0, 720.0)
	root.add_child(action_root)
	scene.root_layer = action_root
	scene.draw_actions(action_root)
	var action_bar := scene.action_bar as Control
	check(action_bar != null and not bool(action_bar.get_meta("pending_claim_window_snapshot", true)), "action bar publishes a false pending-claim snapshot in the normal lane")
	check(action_bar != null and not bool(action_bar.get_meta("pending_danger_discard_snapshot", true)), "action bar publishes a false danger snapshot in the normal lane")

	scene.offline_phase = "pending_claim"
	scene.offline_pending_claim = {"from_seat": 1, "tile": "5W", "options": ["peng"], "chi_choices": [], "snapshot_token": 163}
	check(action_bar != null and not bool(action_bar.get_meta("pending_claim_window_snapshot", true)) and not bool(action_bar.get_meta("pending_danger_discard_snapshot", true)), "later state changes do not rewrite the completed action snapshot")

	action_root.queue_free()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
