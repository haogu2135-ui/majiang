extends SceneTree
## Round 54: snapshot-based single-opponent risk must not rescan live visibility.
var failed := false


func _initialize() -> void:
	call_deferred("run")


func check(cond: bool, msg: String) -> void:
	if cond:
		print("  OK  | %s" % msg)
	else:
		print("  FAIL| %s" % msg)
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
	print("=== ai_play_round54 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.setup_tile_order()
	scene.players = [make_player("Self"), make_player("Threat"), make_player("P2"), make_player("P3")]
	# Keep the live table empty while the caller's immutable snapshot marks 5W
	# as three-visible. The implicit-snapshot and explicit-count paths must agree.
	var visible_counts = scene.make_empty_tile_counts()
	var tile_index = scene.tile_index("5W")
	visible_counts[tile_index] = 3
	var explicit = scene.single_opponent_deal_in_risk_components("5W", 0, 1, 3, visible_counts)
	var from_snapshot = scene.single_opponent_deal_in_risk_components("5W", 0, 1, -1, visible_counts)
	print("    explicit=%.3f snapshot=%.3f" % [float(explicit.get("risk", 0.0)), float(from_snapshot.get("risk", 0.0))])
	check(is_equal_approx(float(from_snapshot.get("risk", 0.0)), float(explicit.get("risk", 0.0))), "snapshot visibility matches an equivalent explicit count")
	check(is_equal_approx(float(from_snapshot.get("pattern_threat", 0.0)), float(explicit.get("pattern_threat", 0.0))), "snapshot pattern threat uses the same visible count")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
