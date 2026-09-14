extends SceneTree
## Round 209: advisor identity and mount paths reuse one layout snapshot.

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
	return {"name": name, "hand": ["1W", "2W", "3W"], "discards": [], "melds": [], "flowers": 0, "flower_tiles": [], "score": 25000, "bot": true}


func run() -> void:
	print("=== ai_play_round209 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.ai_assist_enabled = true
	scene.offline_phase = "await_discard"
	scene.current_seat = 0
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.current_human_advice = [{"tile": "1W", "score": 10.0, "shanten": 2, "ukeire": 3, "reason_label": "保持牌形", "risk_label": "低", "safety_label": ""}]
	scene.ai_advice_hand_signature = scene.hand_identity_fingerprint(scene.players[0]["hand"])

	var live_viewport: Vector2 = scene.effective_viewport_size()
	var live_content_size: Vector2 = scene.safe_content_pixel_size()
	var live_layout: Rect2 = scene.advisor_panel_layout_rect()
	var explicit_layout: Rect2 = scene.advisor_panel_layout_rect(live_viewport, live_content_size)
	var live_signature: String = scene.battle_advisor_identity_signature()
	var explicit_signature: String = scene.battle_advisor_identity_signature(live_viewport, live_content_size, explicit_layout)
	check(explicit_layout == live_layout, "advisor layout preserves the live fallback geometry")
	check(explicit_signature == live_signature, "advisor identity preserves the live fallback signature")

	var advisor_root := Control.new()
	advisor_root.name = "AdvisorIdentitySnapshotRoot"
	advisor_root.size = Vector2(1280.0, 720.0)
	root.add_child(advisor_root)
	scene.root_layer = advisor_root
	scene.draw_advisor_panel(advisor_root)
	var panel := advisor_root.get_node_or_null("AdvisorPanel") as Control
	check(panel != null and panel.get_meta("viewport_snapshot", Vector2.ZERO) == live_viewport, "advisor panel publishes the draw viewport snapshot")
	check(panel != null and panel.get_meta("content_size_snapshot", Vector2.ZERO) == live_content_size, "advisor panel publishes the draw content-size snapshot")
	check(panel != null and str(panel.get_meta("layout_snapshot_policy", "")) == "one_viewport_content_and_layout_snapshot_per_draw", "advisor panel declares the shared layout snapshot policy")

	scene.current_seat = 2
	check(panel != null and panel.get_meta("viewport_snapshot", Vector2.ZERO) == live_viewport, "later state changes do not rewrite the advisor viewport snapshot")

	advisor_root.queue_free()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
