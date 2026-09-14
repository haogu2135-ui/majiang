extends SceneTree
## Round 215: hand-tray discard status reuses one AI-assist snapshot.

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
	print("=== ai_play_round215 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.current_seat = 0
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[0]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "2T", "3T", "5B", "E"]
	scene.wall.clear()
	for _i in range(20):
		scene.wall.append("1B")

	scene.ai_assist_enabled = false
	scene.current_human_advice = []
	var disabled_text: String = scene.hand_tray_text()
	check(disabled_text == "牌墙偏少 · 余20 · 点击手牌出牌", "disabled assistance keeps the low-wall hand-tray status")

	scene.ai_assist_enabled = true
	scene.current_human_advice = [{"tile": "1W", "ukeire": 8, "score": 42.0, "safety_label": "安"}]
	var enabled_text: String = scene.hand_tray_text()
	check(enabled_text != disabled_text and enabled_text != "", "enabled assistance keeps the recommendation status branch")

	scene.wall.clear()
	for _i in range(6):
		scene.wall.append("1B")
	var critical_text: String = scene.hand_tray_text()
	check(critical_text == "牌墙将尽 · 余6 · 谨慎出牌", "critical wall keeps its early-return status")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
