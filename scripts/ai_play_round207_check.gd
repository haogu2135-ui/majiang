extends SceneTree
## Round 207: round-summary win detail consumes the parent viewport snapshot.

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
	print("=== ai_play_round207 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.mode = "offline"

	var live_root := Control.new()
	live_root.name = "WinDetailParentViewportSnapshotRoot"
	live_root.size = Vector2(1280.0, 720.0)
	root.add_child(live_root)
	scene.root_layer = live_root
	var live_viewport: Vector2 = scene.effective_viewport_size()
	var score_data := {"winner": 0, "fan": 2, "points": 100, "reasons": ["立直"], "win_tile": "5W", "self_draw": false}
	scene.draw_win_detail_section(live_root, score_data, live_viewport)
	var live_panel := live_root.get_node_or_null("WinDetailPanel") as Control
	var live_showcase := live_panel.get_node_or_null("WinDetailShowcase") as Control if live_panel != null else null
	check(live_panel != null and live_panel.get_meta("viewport_snapshot", Vector2.ZERO) == live_viewport, "win detail consumes the supplied parent viewport snapshot")
	check(live_showcase != null and live_showcase.get_meta("viewport_snapshot", Vector2.ZERO) == live_viewport, "win-detail showcase receives the same parent snapshot")

	var compact_root := Control.new()
	compact_root.name = "WinDetailCompactViewportSnapshotRoot"
	compact_root.size = Vector2(1280.0, 720.0)
	root.add_child(compact_root)
	scene.root_layer = compact_root
	var compact_viewport := Vector2(960.0, 540.0)
	scene.draw_win_detail_section(compact_root, score_data, compact_viewport)
	var compact_panel := compact_root.get_node_or_null("WinDetailPanel") as Control
	var compact_showcase := compact_panel.get_node_or_null("WinDetailShowcase") as Control if compact_panel != null else null
	check(compact_panel != null and compact_panel.get_meta("viewport_snapshot", Vector2.ZERO) == compact_viewport, "win detail applies an explicit compact viewport snapshot")
	check(compact_showcase != null and compact_showcase.get_meta("viewport_snapshot", Vector2.ZERO) == compact_viewport, "win-detail showcase preserves the compact snapshot")

	live_root.queue_free()
	compact_root.queue_free()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
