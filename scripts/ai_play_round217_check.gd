extends SceneTree
## Round 217: normal action rendering reuses self-discard and AI-state snapshots.

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


func make_root(root_name: String) -> Control:
	var action_root := Control.new()
	action_root.name = root_name
	action_root.size = Vector2(1280.0, 720.0)
	root.add_child(action_root)
	return action_root


func run() -> void:
	print("=== ai_play_round217 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.current_seat = 0
	scene.offline_sim_quiet = true
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[0]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "2T", "3T", "5B", "E"]
	scene.wall.clear()
	for _i in range(60):
		scene.wall.append("1B")

	scene.ai_assist_enabled = true
	scene.current_human_advice = [{"tile": "1W", "ukeire": 8, "score": 42.0, "safety_label": "安"}]
	scene.ai_advice_hand_signature = scene.hand_identity_fingerprint(scene.get_self_hand())
	var enabled_root := make_root("ActionSnapshotEnabledRoot")
	scene.root_layer = enabled_root
	scene.draw_actions(enabled_root)
	check(enabled_root.find_child("RecommendedDiscardButton", true, false) != null, "enabled assistance keeps the recommended discard action")
	check(scene.action_bar != null, "enabled assistance keeps the normal action bar mounted")

	scene.ai_assist_enabled = false
	scene.current_human_advice = []
	scene.ai_render_report_snapshot_ready = false
	var disabled_root := make_root("ActionSnapshotDisabledRoot")
	scene.root_layer = disabled_root
	scene.draw_actions(disabled_root)
	check(disabled_root.find_child("RecommendedDiscardButton", true, false) == null, "disabled assistance removes the recommendation action")
	check(disabled_root.find_child("OfflineRestartButton", true, false) != null, "disabled assistance preserves the normal restart action")

	enabled_root.queue_free()
	disabled_root.queue_free()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
