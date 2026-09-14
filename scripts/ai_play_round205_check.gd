extends SceneTree
## Round 205: center identity reuses one viewport snapshot.

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
	print("=== ai_play_round205 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame

	var center_root := Control.new()
	center_root.name = "CenterViewportSnapshotRoot"
	center_root.size = Vector2(1280.0, 720.0)
	root.add_child(center_root)
	scene.root_layer = center_root
	scene.mode = "offline"
	scene.offline_phase = "resolving"
	scene.offline_sim_quiet = true
	scene.last_discard = ""
	scene.last_discard_seat = -1
	while scene.players.size() < 4:
		scene.players.append({"name": "玩家", "score": 8000, "hand": [], "discards": [], "melds": [], "flowers": 0})

	var live_viewport: Vector2 = scene.effective_viewport_size()
	var fallback_signature: String = scene.battle_center_identity_signature()
	var explicit_signature: String = scene.battle_center_identity_signature(live_viewport)
	var compact_viewport := Vector2(960.0, 540.0)
	var compact_signature: String = scene.battle_center_identity_signature(compact_viewport)
	check(explicit_signature == fallback_signature, "center signature preserves the live fallback result")
	check(compact_signature != fallback_signature, "center signature consumes an explicit compact viewport snapshot")

	scene.draw_center(center_root)
	var center := center_root.get_node_or_null("CenterConsole3DShell") as Control
	check(center_root.get_meta("center_viewport_snapshot", Vector2.ZERO) == live_viewport, "center draw publishes one viewport snapshot")
	check(str(center_root.get_meta("center_viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "center draw declares one viewport read per draw")
	check(center != null and center.get_meta("center_viewport_snapshot", Vector2.ZERO) == live_viewport, "center shell retains the draw viewport snapshot")
	check(center != null and str(center.get_meta("center_viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "center shell declares the viewport snapshot policy")

	var saved_viewport: Vector2 = center_root.get_meta("center_viewport_snapshot", Vector2.ZERO)
	scene.large_text_enabled = true
	check(center_root.get_meta("center_viewport_snapshot", Vector2.ZERO) == saved_viewport, "later state changes do not rewrite the completed center snapshot")

	center_root.queue_free()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
