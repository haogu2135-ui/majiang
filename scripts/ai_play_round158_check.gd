extends SceneTree
## Round 158: meld rendering reuses one pending-danger snapshot.

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
	print("=== ai_play_round158 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.offline_sim_quiet = true
	scene.ai_assist_enabled = true
	scene.current_seat = 0
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[0]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "2T", "3T", "5B", "E"]
	scene.players[0]["melds"] = [["1W", "2W", "3W"]]
	scene.pending_danger_discard_tile = "1W"
	scene.pending_danger_discard_index = 0

	var danger_root := Control.new()
	danger_root.name = "MeldDangerSnapshotRoot"
	danger_root.size = Vector2(1280.0, 720.0)
	root.add_child(danger_root)
	scene.root_layer = danger_root
	scene.draw_melds(danger_root)
	var danger_area := danger_root.get_node_or_null("MeldArea_0") as Control
	check(danger_area != null and bool(danger_area.get_meta("danger_compact_snapshot", false)) and bool(danger_area.get_meta("compact_melds_snapshot", false)), "危险确认时副露布局复用同一状态快照")
	danger_root.queue_free()

	scene.pending_danger_discard_tile = ""
	scene.pending_danger_discard_index = -1
	var normal_root := Control.new()
	normal_root.name = "MeldNormalSnapshotRoot"
	normal_root.size = Vector2(1280.0, 720.0)
	root.add_child(normal_root)
	scene.root_layer = normal_root
	scene.draw_melds(normal_root)
	var normal_area := normal_root.get_node_or_null("MeldArea_0") as Control
	check(normal_area != null and not bool(normal_area.get_meta("danger_compact_snapshot", true)), "危险状态清除后副露布局仍能取得新的实时快照")

	normal_root.queue_free()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
