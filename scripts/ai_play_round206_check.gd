extends SceneTree
## Round 206: seat rendering reuses one viewport snapshot.

var failed := false


func _initialize() -> void:
	call_deferred("run")


func check(condition: bool, message: String) -> void:
	if condition:
		print("  OK  | %s" % message)
	else:
		print("  FAIL| %s" % message)
		failed = true


func run() -> void:
	print("=== ai_play_round206 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame

	var seat_root := Control.new()
	seat_root.name = "SeatViewportSnapshotRoot"
	seat_root.size = Vector2(1280.0, 720.0)
	root.add_child(seat_root)
	scene.root_layer = seat_root
	scene.mode = "offline"
	scene.offline_phase = "resolving"
	scene.offline_sim_quiet = true
	while scene.players.size() < 4:
		scene.players.append({"name": "玩家", "score": 8000, "hand": [], "discards": [], "melds": [], "flowers": 0})

	var seat_rect: Rect2 = scene.SEAT_LAYOUTS[0][1]
	var seat_side := str(scene.SEAT_LAYOUTS[0][2])
	var live_viewport: Vector2 = scene.effective_viewport_size()
	var fallback_signature: String = scene.battle_seat_identity_signature(0, seat_rect, seat_side)
	var explicit_signature: String = scene.battle_seat_identity_signature(0, seat_rect, seat_side, {}, {}, live_viewport)
	var compact_viewport := Vector2(960.0, 540.0)
	var compact_signature: String = scene.battle_seat_identity_signature(0, seat_rect, seat_side, {}, {}, compact_viewport)
	check(explicit_signature == fallback_signature, "seat signature preserves the live fallback result")
	check(compact_signature != fallback_signature, "seat signature consumes an explicit compact viewport snapshot")

	scene.draw_seat(seat_root, 0, seat_rect, seat_side, {}, {}, live_viewport)
	var panel := seat_root.get_node_or_null("SeatPanel_0") as Control
	var shadow := seat_root.get_node_or_null("SeatPanel3DCastShadow_0") as Control
	check(seat_root.get_meta("seat_viewport_snapshot", Vector2.ZERO) == live_viewport, "seat draw publishes one viewport snapshot")
	check(str(seat_root.get_meta("seat_viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_seat_draw", "seat draw declares one viewport read per seat")
	check(panel != null and panel.get_meta("seat_viewport_snapshot", Vector2.ZERO) == live_viewport, "seat panel retains the draw viewport snapshot")
	check(shadow != null and shadow.get_meta("seat_viewport_snapshot", Vector2.ZERO) == live_viewport, "seat shadow retains the draw viewport snapshot")

	var saved_viewport: Vector2 = seat_root.get_meta("seat_viewport_snapshot", Vector2.ZERO)
	scene.large_text_enabled = true
	check(seat_root.get_meta("seat_viewport_snapshot", Vector2.ZERO) == saved_viewport, "later state changes do not rewrite the completed seat snapshot")

	seat_root.queue_free()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
