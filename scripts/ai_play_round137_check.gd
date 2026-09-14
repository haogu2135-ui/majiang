extends SceneTree
## Round 137: hand rendering reuses one required-width snapshot.

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
	print("=== ai_play_round137 check START ===")
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
	hand_root.name = "HandWidthSnapshotRoot"
	hand_root.size = Vector2(1280.0, 720.0)
	root.add_child(hand_root)
	scene.root_layer = hand_root
	scene.draw_hand(hand_root)

	var hand: Array = scene.get_self_hand()
	var metrics: Dictionary = scene.hand_layout_metrics(hand)
	var required_width: float = scene.hand_layout_required_width(hand, metrics)
	var hand_box := hand_root.get_node_or_null("HandTray/HandTrayTiles") as Control
	check(hand_box != null, "hand render creates the native tile row for the width snapshot")
	if hand_box != null:
		check(is_equal_approx(float(hand_box.get_meta("layout_required_width", -1.0)), required_width), "hand row publishes the width already solved for the tray")
		check(str(hand_box.get_meta("layout_required_width_policy", "")) == "one_required_width_snapshot_per_draw", "hand row declares one required-width snapshot per draw")
		check(bool(hand_box.get_meta("layout_fits_content", false)) == scene.hand_layout_fits_content(hand, metrics, required_width), "fit metadata consumes the same required-width snapshot")

	var legacy_fit: bool = scene.hand_layout_fits_content(hand, metrics)
	var snapshot_fit: bool = scene.hand_layout_fits_content(hand, metrics, required_width)
	check(legacy_fit == snapshot_fit, "explicit width snapshot preserves the legacy fit result")
	var altered_metrics: Dictionary = metrics.duplicate(true)
	altered_metrics["tile_width"] = float(altered_metrics.get("tile_width", 0.0)) + 1000.0
	check(scene.hand_layout_fits_content(hand, altered_metrics, required_width) == snapshot_fit and scene.hand_layout_fits_content(hand, altered_metrics) != snapshot_fit, "snapshot path avoids recalculating width from altered layout metrics")

	hand_root.queue_free()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
