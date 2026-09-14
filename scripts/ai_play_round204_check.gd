extends SceneTree
## Round 204: round summary reuses one viewport/content snapshot.

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
	print("=== ai_play_round204 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame

	var summary_root := Control.new()
	summary_root.name = "RoundSummaryViewportSnapshotRoot"
	summary_root.size = Vector2(1280.0, 720.0)
	root.add_child(summary_root)
	scene.root_layer = summary_root
	scene.mode = "offline"
	scene.offline_phase = "ended"
	scene.round_result_kind = "win"
	scene.round_summary = "P0胡五万，2番 1000分。庄家连庄。"
	while scene.players.size() < 4:
		scene.players.append({"name": "玩家", "score": 8000, "hand": [], "discards": [], "melds": [], "flowers": 0})
	scene.last_win_score = {"winner": 0, "fan": 2, "points": 1000, "reasons": ["平和"], "win_tile": "5W", "self_draw": false, "limit_name": ""}
	scene.offline_last_winner = 0
	scene.offline_dealer_repeat = true

	var live_viewport: Vector2 = scene.effective_viewport_size()
	var live_content_size: Vector2 = scene.safe_content_pixel_size()
	var fallback_signature: String = scene.battle_round_summary_identity_signature()
	var explicit_signature: String = scene.battle_round_summary_identity_signature(live_viewport, live_content_size)
	var compact_viewport := Vector2(960.0, 540.0)
	var compact_content_size := Vector2(880.0, 500.0)
	var compact_signature: String = scene.battle_round_summary_identity_signature(compact_viewport, compact_content_size)
	check(explicit_signature == fallback_signature, "summary signature preserves the live fallback result")
	check(compact_signature != fallback_signature, "summary signature consumes an explicit compact viewport snapshot")
	check(scene.ui_layout_density(compact_viewport) == "compact", "summary signature density accepts the explicit viewport snapshot")
	check(scene.action_bar_dock_layout_rect(live_viewport, live_content_size) == scene.action_bar_dock_layout_rect(), "summary action-dock geometry preserves the live fallback result")

	scene.draw_round_summary(summary_root)
	var panel := summary_root.get_node_or_null("RoundSummaryPanel") as Control
	var shield := summary_root.get_node_or_null("RoundSummaryModalInputShield") as Control
	check(summary_root.get_meta("round_summary_viewport_snapshot", Vector2.ZERO) == live_viewport, "summary draw publishes one viewport snapshot")
	check(summary_root.get_meta("round_summary_content_size_snapshot", Vector2.ZERO) == live_content_size, "summary draw publishes one content-size snapshot")
	check(str(summary_root.get_meta("round_summary_snapshot_policy", "")) == "one_viewport_and_content_snapshot_per_draw", "summary draw declares its paired snapshot policy")
	check(panel != null and panel.get_meta("round_summary_viewport_snapshot", Vector2.ZERO) == live_viewport and panel.get_meta("round_summary_content_size_snapshot", Vector2.ZERO) == live_content_size, "summary panel retains the draw snapshots")
	check(shield != null and shield.get_meta("round_summary_viewport_snapshot", Vector2.ZERO) == live_viewport and shield.get_meta("round_summary_content_size_snapshot", Vector2.ZERO) == live_content_size, "summary input shield retains the draw snapshots")

	var saved_viewport: Vector2 = summary_root.get_meta("round_summary_viewport_snapshot", Vector2.ZERO)
	var saved_content_size: Vector2 = summary_root.get_meta("round_summary_content_size_snapshot", Vector2.ZERO)
	scene.large_text_enabled = true
	check(summary_root.get_meta("round_summary_viewport_snapshot", Vector2.ZERO) == saved_viewport and summary_root.get_meta("round_summary_content_size_snapshot", Vector2.ZERO) == saved_content_size, "later state changes do not rewrite the completed summary snapshots")

	summary_root.queue_free()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
