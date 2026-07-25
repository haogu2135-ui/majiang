extends SceneTree
## Round 21: a late closed-hand readiness threat must supply genbutsu safety.
var failed := false


func _initialize() -> void:
	call_deferred("run")


func check(cond: bool, msg: String) -> void:
	if cond:
		print("  OK  | %s" % msg)
	else:
		print("  FAIL| %s" % msg)
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
	print("=== ai_play_round21 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.setup_tile_order()
	scene.players = [make_player("Self"), make_player("LateThreat"), make_player("Route"), make_player("Third")]
	# Seat 1 has no open meld, but its deep river and short wall make it a
	# readiness threat. It has already discarded the candidate 5W.
	scene.players[1]["discards"] = ["5W", "1W", "2W", "3W", "4W", "6W", "7W", "8W", "9W", "1T", "2T", "3T", "4T", "5T"]
	# Seat 2 has a visible route, but is weaker than seat 1's late readiness.
	scene.players[2]["melds"] = [["4B", "5B", "6B"]]
	scene.players[2]["discards"] = ["1W", "2W", "3W"]
	var late_wall: Array[String] = []
	scene.wall = late_wall
	for i in range(20):
		scene.wall.append("9B")

	print("--- A) closed late threat becomes main threat ---")
	var context = scene.make_ai_evaluation_context(0, scene.visible_tile_counts())
	var late_plan = scene.opponent_plan_pressure(1, context)
	var late_readiness = scene.opponent_readiness_score(1, context)
	print("    seat1 plan=%.2f readiness=%.2f main=%d" % [late_plan, late_readiness, scene.main_threat_opponent(0, context)])
	check(is_equal_approx(late_plan, 0.0), "无副露对手没有虚假染手压力")
	check(late_readiness >= 13.0, "深牌河残墙对手进入疑听就绪度")
	check(scene.main_threat_opponent(0, context) == 1, "就绪威胁被选为主威胁")

	print("--- B) its genbutsu receives defensive label ---")
	check(scene.is_main_threat_genbutsu("5W", 0, context), "主威胁已打 5W 被识别为现物")
	check(scene.tile_safety_label("5W", 0, scene.visible_tile_counts(), context) == "现", "弃牌报告显示主威胁现物")
	check(scene.tile_safety_label("E", 0, scene.visible_tile_counts(), context) != "现", "未打出的牌不伪装为现物")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
