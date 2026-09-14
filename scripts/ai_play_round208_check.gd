extends SceneTree
## Round 208: pending-claim layout reuses one viewport snapshot through nested helpers.

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
	return {"name": name, "hand": [], "discards": [], "melds": [], "flowers": 0, "flower_tiles": [], "score": 25000, "bot": true}


func run() -> void:
	print("=== ai_play_round208 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_phase = "pending_claim"
	scene.current_seat = 0
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.offline_pending_claim = {"from_seat": 1, "tile": "5W", "options": ["peng"], "chi_choices": [], "snapshot_token": 208}

	var live_viewport: Vector2 = scene.effective_viewport_size()
	var live_content_size: Vector2 = scene.safe_content_pixel_size()
	var fallback_rect: Rect2 = scene.pending_claim_context_layout_rect(live_content_size)
	var explicit_rect: Rect2 = scene.pending_claim_context_layout_rect(live_content_size, live_viewport)
	var compact_viewport := Vector2(960.0, 540.0)
	var compact_content_size := Vector2(880.0, 500.0)
	var compact_rect: Rect2 = scene.pending_claim_context_layout_rect(compact_content_size, compact_viewport)
	check(explicit_rect == fallback_rect, "nested pending layout preserves the live fallback geometry")
	check(compact_rect != fallback_rect, "nested pending layout consumes the explicit compact viewport snapshot")

	var pending_root := Control.new()
	pending_root.name = "PendingClaimNestedViewportSnapshotRoot"
	pending_root.size = Vector2(1280.0, 720.0)
	root.add_child(pending_root)
	scene.root_layer = pending_root
	scene.draw_pending_claim_illustration(pending_root)
	var panel := pending_root.get_node_or_null("PendingClaimIllustration") as Control
	check(panel != null and panel.get_meta("viewport_snapshot", Vector2.ZERO) == live_viewport, "pending illustration publishes the draw viewport snapshot")
	check(panel != null and str(panel.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "pending illustration retains its one-read policy")

	scene.current_seat = 2
	check(panel != null and panel.get_meta("viewport_snapshot", Vector2.ZERO) == live_viewport, "later state changes do not rewrite the pending viewport snapshot")

	pending_root.queue_free()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
