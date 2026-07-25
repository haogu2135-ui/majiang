extends SceneTree
## Round 15: flower-only tail of the wall must end the hand, including gang replacement.
var failed := false


func _initialize() -> void:
	call_deferred("run")


func check(cond: bool, msg: String) -> void:
	if cond:
		print("  OK  | %s" % msg)
	else:
		print("  FAIL| %s" % msg)
		failed = true


func make_players(scene) -> void:
	scene.players = []
	for i in range(4):
		scene.players.append({
			"name": "P%d" % i,
			"hand": ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "E", "S", "W", "N"],
			"discards": [],
			"melds": [],
			"flowers": 0,
			"flower_tiles": [],
			"score": 25000,
			"bot": i != 0,
		})


func reset_flower_tail(scene) -> void:
	var flower_tail: Array[String] = ["H1", "H2"]
	scene.wall = flower_tail
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = true
	scene.offline_last_winner = -1
	scene.offline_dealer_repeat = false
	var score_deltas: Array[int] = []
	scene.last_score_deltas = score_deltas


func run() -> void:
	print("=== ai_play_round15 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.mode = "offline"
	scene.offline_hand_number = 4
	scene.dealer_seat = 0
	scene.offline_sim_quiet = true
	make_players(scene)
	if scene.has_method("setup_tile_order"):
		scene.setup_tile_order()

	print("--- A) normal draw after flower-only tail ---")
	reset_flower_tail(scene)
	var normal_drawn = scene.draw_turn_tile_or_finish(1, false)
	check(normal_drawn == "", "花牌补完后没有伪造实牌")
	check(scene.wall.is_empty(), "补花会清空花牌尾墙")
	check(int(scene.players[1].get("flowers", 0)) == 2, "摸牌者获得全部尾花")
	check(scene.offline_phase == "ended" and scene.offline_dealer_repeat, "正常摸牌花尽后立即荒庄")
	check(not scene.offline_turn_needs_draw, "荒庄后不保留待摸状态")

	print("--- B) gang replacement after flower-only tail ---")
	reset_flower_tail(scene)
	scene.draw_after_gang(2)
	check(scene.wall.is_empty(), "杠后补花会清空花牌尾墙")
	check(int(scene.players[2].get("flowers", 0)) == 2, "杠后补牌者获得全部尾花")
	check(scene.offline_phase == "ended" and scene.offline_last_winner == -1, "杠后花尽按荒庄结算，不进入错误出牌状态")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
