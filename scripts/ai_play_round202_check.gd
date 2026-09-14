extends SceneTree
## Round 202: meld lane signatures reuse one viewport snapshot.

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
	print("=== ai_play_round202 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame

	var meld_root := Control.new()
	meld_root.name = "MeldViewportSnapshotRoot"
	meld_root.size = Vector2(1280.0, 720.0)
	root.add_child(meld_root)
	scene.root_layer = meld_root
	scene.mode = "offline"
	while scene.players.size() < 4:
		scene.players.append({"discards": [], "melds": []})
	scene.players[0]["melds"] = [["1W", "1W", "1W"], ["2W", "3W", "4W"]]
	scene.draw_melds(meld_root)

	var expected_viewport: Vector2 = scene.effective_viewport_size()
	check(meld_root.get_meta("meld_viewport_snapshot", Vector2.ZERO) == expected_viewport, "meld draw publishes the viewport snapshot")
	check(str(meld_root.get_meta("meld_viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "meld draw declares one viewport read per draw")

	var meld_rect: Rect2 = scene.seat_meld_rect(0)
	var content_size: Vector2 = scene.safe_content_pixel_size()
	var live_viewport: Vector2 = scene.effective_viewport_size()
	var compact_viewport := Vector2(960.0, 540.0)
	var meld_list: Array = scene.players[0]["melds"]
	var fallback_signature: String = scene.meld_lane_render_signature(0, meld_list, meld_rect, meld_rect, 2, 2, 0, 1, false, false, false, content_size)
	var explicit_signature: String = scene.meld_lane_render_signature(0, meld_list, meld_rect, meld_rect, 2, 2, 0, 1, false, false, false, content_size, live_viewport)
	var compact_signature: String = scene.meld_lane_render_signature(0, meld_list, meld_rect, meld_rect, 2, 2, 0, 1, false, false, false, content_size, compact_viewport)
	check(explicit_signature == fallback_signature, "meld lane signature preserves the live fallback result")
	check(compact_signature != fallback_signature, "meld lane signature consumes an explicit viewport snapshot")

	var saved_viewport: Vector2 = meld_root.get_meta("meld_viewport_snapshot", Vector2.ZERO)
	scene.large_text_enabled = true
	check(meld_root.get_meta("meld_viewport_snapshot", Vector2.ZERO) == saved_viewport, "later state changes do not rewrite the completed meld viewport snapshot")

	meld_root.queue_free()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
