extends SceneTree
## Round 170: pending-claim illustration reuses one viewport snapshot.

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
	print("=== ai_play_round170 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_phase = "pending_claim"
	scene.current_seat = 0
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.offline_pending_claim = {"from_seat": 1, "tile": "5W", "options": ["peng"], "chi_choices": [], "snapshot_token": 170}

	var pending_root := Control.new()
	pending_root.name = "PendingClaimViewportSnapshotRoot"
	pending_root.size = Vector2(1280.0, 720.0)
	root.add_child(pending_root)
	scene.root_layer = pending_root
	var expected_viewport: Vector2 = scene.effective_viewport_size()
	scene.draw_pending_claim_illustration(pending_root)
	var panel := pending_root.get_node_or_null("PendingClaimIllustration") as Control
	check(panel != null and panel.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport, "待响应插画发布本次绘制的 viewport 快照")
	check(panel != null and str(panel.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "待响应插画声明每次绘制只读取一次 viewport")

	scene.current_seat = 2
	check(panel != null and panel.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport, "后续状态变化不会改写已完成的待响应 viewport 快照")

	pending_root.queue_free()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
