extends SceneTree
## Round 190: online-lobby roster text budgets reuse their viewport snapshot.

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
	print("=== ai_play_round190 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.online_waiting_for_server = true
	scene.online_room = {"players": [{"name": "P0", "ready": true}, {"name": "P1", "ready": false}]}

	var roster_root := Control.new()
	roster_root.name = "OnlineRosterViewportSnapshotRoot"
	roster_root.size = Vector2(1280.0, 720.0)
	root.add_child(roster_root)
	scene.root_layer = roster_root
	var expected_viewport: Vector2 = scene.effective_viewport_size()
	var roster: Control = scene.draw_online_lobby_roster_panel(roster_root)
	var name_label := roster.get_node_or_null("OnlineLobbyRosterRow_0/OnlineLobbyRosterName_0") as Label if roster != null else null
	var state_label := roster.get_node_or_null("OnlineLobbyRosterRow_0/OnlineLobbyRosterState_0") as Label if roster != null else null
	check(roster != null and roster.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport, "联机大厅席位面板发布本次绘制的 viewport 快照")
	check(roster != null and str(roster.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "联机大厅席位面板声明每次绘制只读取一次 viewport")
	check(name_label != null and state_label != null and name_label.text != "" and state_label.text != "", "席位名称和状态仍完整构建")
	scene.online_room = {"players": [{"name": "P9", "ready": true}]}
	check(roster != null and roster.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport, "后续房间状态不会改写已完成的 roster viewport 快照")

	roster_root.queue_free()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
