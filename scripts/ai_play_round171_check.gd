extends SceneTree
## Round 171: action-dock rendering consumes one pending-state snapshot.

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
		"bot": false,
	}


func make_action_root(root_name: String) -> Control:
	var action_root := Control.new()
	action_root.name = root_name
	action_root.size = Vector2(1280.0, 720.0)
	root.add_child(action_root)
	return action_root


func add_action_bar(scene, action_root: Control) -> void:
	var bar := HBoxContainer.new()
	bar.name = "ActionSnapshotTestBar"
	bar.size = Vector2(520.0, 64.0)
	bar.position = Vector2(700.0, 620.0)
	action_root.add_child(bar)
	var button := Button.new()
	button.name = "SnapshotActionButton"
	button.text = "出牌"
	bar.add_child(button)
	scene.action_bar = bar


func run() -> void:
	print("=== ai_play_round171 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]

	var live_root := make_action_root("LiveActionStateRoot")
	scene.root_layer = live_root
	add_action_bar(scene, live_root)
	var live_buttons: Array[Button] = scene.action_bar_buttons()
	var live_signature: String = scene.battle_action_chrome_identity_signature(live_buttons)
	var live_drawn: Array[Button] = scene.draw_action_dock(live_root)
	var live_dock := live_root.get_node_or_null("ActionButtonDock") as Control
	check(live_drawn.size() == 1 and live_dock != null, "dock keeps the direct-call live fallback")
	check(live_dock != null and not bool(live_dock.get_meta("pending_claim_window_snapshot", true)) and not bool(live_dock.get_meta("pending_danger_discard_snapshot", true)), "live fallback publishes the current false pending states")
	check(live_dock != null and str(live_dock.get_meta("action_state_snapshot_policy", "")) == "one_action_state_snapshot_per_dock", "dock declares one pending-state snapshot per draw")

	var explicit_root := make_action_root("ExplicitActionStateRoot")
	scene.root_layer = explicit_root
	add_action_bar(scene, explicit_root)
	var explicit_buttons: Array[Button] = scene.action_bar_buttons()
	var explicit_signature: String = scene.battle_action_chrome_identity_signature(explicit_buttons, 1, 1)
	var explicit_drawn: Array[Button] = scene.draw_action_dock(explicit_root, false, 1, 1)
	var explicit_dock := explicit_root.get_node_or_null("ActionButtonDock") as Control
	check(explicit_drawn.size() == 1 and explicit_dock != null, "dock accepts explicit pending-state snapshots")
	check(explicit_dock != null and bool(explicit_dock.get_meta("pending_claim_window_snapshot", false)) and bool(explicit_dock.get_meta("pending_danger_discard_snapshot", false)), "explicit snapshots reach the dock chrome")
	check(explicit_signature != live_signature, "the action chrome signature consumes explicit pending-state snapshots")

	scene.offline_phase = "pending_claim"
	scene.offline_pending_claim = {"from_seat": 1, "tile": "5W", "options": ["peng"], "chi_choices": [], "snapshot_token": 171}
	check(explicit_dock != null and bool(explicit_dock.get_meta("pending_claim_window_snapshot", false)) and bool(explicit_dock.get_meta("pending_danger_discard_snapshot", false)), "later live state changes do not rewrite the completed dock snapshot")

	live_root.queue_free()
	explicit_root.queue_free()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
