extends SceneTree
## Round 198: pending-claim layout calculations reuse one viewport/content snapshot.

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
	print("=== ai_play_round198 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame

	var layout_root := Control.new()
	layout_root.name = "PendingClaimLayoutSnapshotRoot"
	layout_root.size = Vector2(1280.0, 720.0)
	root.add_child(layout_root)
	scene.root_layer = layout_root
	scene.mode = "offline"
	scene.offline_phase = "pending_claim"
	scene.offline_pending_claim = {
		"from_seat": 1,
		"tile": "3W",
		"options": ["chi", "peng", "gang", "hu"],
		"deadline_msec": Time.get_ticks_msec() + 12000,
	}
	scene.pending_claim_display_cache_key = ""

	var action_count := 20
	var live_viewport: Vector2 = scene.effective_viewport_size()
	var live_content_size: Vector2 = scene.safe_content_pixel_size()
	var live_columns: int = scene.pending_claim_action_columns(action_count)
	var live_dock: Rect2 = scene.pending_claim_action_dock_rect_for_count(action_count)
	var live_bar: Rect2 = scene.pending_claim_action_bar_rect_for_count(action_count)
	var compact_viewport := Vector2(960.0, 540.0)
	var compact_content_size := Vector2(960.0, 540.0)
	var compact_columns: int = scene.pending_claim_action_columns(action_count, compact_viewport, compact_content_size)
	var compact_rows: int = scene.pending_claim_action_row_count(action_count, compact_viewport, compact_content_size)
	var compact_dock: Rect2 = scene.pending_claim_action_dock_rect_for_count(action_count, compact_viewport, compact_content_size)
	var compact_bar: Rect2 = scene.pending_claim_action_bar_rect_for_count(action_count, compact_viewport, compact_content_size)
	var compact_response_width: float = scene.pending_claim_response_button_width(action_count, scene.action_button_separation_for_count(action_count, compact_viewport), compact_viewport, compact_content_size)
	var smaller_content_columns: int = scene.pending_claim_action_columns(action_count, compact_viewport, Vector2(720.0, 400.0))

	check(live_viewport.y > 560.0 and compact_viewport.y <= 560.0, "夹具覆盖标准和紧凑两种 pending 响应 viewport")
	check(compact_columns < live_columns, "显式 viewport 快照会改变响应列数，而不是被实时窗口覆盖")
	check(smaller_content_columns < compact_columns, "显式 content-size 快照会参与响应列容量计算")
	check(compact_rows > 0 and compact_dock != live_dock and compact_bar != live_bar, "显式 viewport/content 快照同时驱动行数和 dock/bar 几何")
	check(compact_response_width >= scene.PENDING_CLAIM_BUTTON_MIN_WIDTH, "快照驱动的响应按钮仍保持最小触控宽度")
	check(scene.pending_claim_action_columns(action_count, live_viewport, live_content_size) == live_columns, "无参实时回退与显式实时快照保持一致")
	check(scene.pending_claim_action_dock_rect_for_count(action_count, live_viewport, live_content_size) == live_dock, "dock 无参实时回退与显式实时快照保持一致")

	var saved_dock := compact_dock
	var saved_columns := compact_columns
	scene.large_text_enabled = true
	scene.offline_pending_claim["options"] = ["hu"]
	check(saved_dock == compact_dock and saved_columns == compact_columns, "后续响应状态不会改写已完成的布局快照结果")

	layout_root.queue_free()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
