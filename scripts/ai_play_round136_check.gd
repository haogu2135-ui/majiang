extends SceneTree
## Round 136: action-dock rendering reuses one nested button snapshot.

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
	print("=== ai_play_round136 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.wall.clear()
	for _i in range(60):
		scene.wall.append("1B")

	var action_root := Control.new()
	action_root.size = Vector2(1280.0, 720.0)
	root.add_child(action_root)
	scene.root_layer = action_root
	var action_bar := HBoxContainer.new()
	action_bar.name = "ActionSnapshotTestBar"
	action_bar.size = Vector2(520.0, 64.0)
	action_bar.position = Vector2(700.0, 620.0)
	action_root.add_child(action_bar)
	var nested_lane := VBoxContainer.new()
	nested_lane.name = "NestedActionLane"
	action_bar.add_child(nested_lane)
	var game_button := Button.new()
	game_button.name = "SnapshotGameButton"
	game_button.text = "出牌"
	nested_lane.add_child(game_button)
	var support_button := Button.new()
	support_button.name = "SnapshotSupportButton"
	support_button.text = "语音"
	support_button.set_meta("non_game_action", true)
	action_bar.add_child(support_button)
	scene.action_bar = action_bar

	var button_snapshot: Array[Button] = scene.action_bar_buttons()
	var snapshot_signature: String = scene.battle_action_chrome_identity_signature(button_snapshot)
	var snapshot_count: int = scene.action_bar_button_count(button_snapshot)
	check(button_snapshot.size() == 2 and snapshot_count == 1, "one nested button walk preserves the non-game action filter")
	var empty_snapshot: Array[Button] = []
	check(scene.action_bar_button_count(empty_snapshot) == 0 and scene.action_bar_button_count() == 1, "an explicit empty snapshot stays distinct from the live fallback")

	nested_lane.remove_child(game_button)
	var live_buttons: Array[Button] = scene.action_bar_buttons()
	check(live_buttons.size() == 1 and scene.action_bar_button_count(button_snapshot) == 1 and scene.action_bar_button_count() == 0, "a retained snapshot remains stable after the action tree changes")
	check(scene.battle_action_chrome_identity_signature(button_snapshot) == snapshot_signature, "the action identity signature consumes the supplied snapshot")

	nested_lane.add_child(game_button)
	var drawn_snapshot: Array[Button] = scene.draw_action_dock(action_root)
	check(drawn_snapshot.size() == 2 and action_root.find_child("ActionButtonDock", true, false) != null, "action-dock rendering returns its collected nested button snapshot")
	scene.finalize_action_bar_layout(drawn_snapshot)
	check(scene.action_bar_button_count(drawn_snapshot) == 1, "final action layout accepts the draw snapshot without rebuilding the list")
	scene.retain_battle_action_chrome_for_render()
	var retained_snapshot: Array[Button] = scene.draw_action_dock(action_root)
	check(retained_snapshot.size() == 2 and scene.retained_battle_action_dock == null, "retained action-dock redraw returns the same button snapshot")
	scene.finalize_action_bar_layout(retained_snapshot)

	action_root.queue_free()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
