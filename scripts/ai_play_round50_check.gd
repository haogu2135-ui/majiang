extends SceneTree
## Round 50: concealed quads remain closed for AI first-open claim discipline.
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


func claim_hand() -> Array:
	return ["3W", "4W", "1B", "3B", "5B", "7B", "2T", "4T", "6T", "8T", "E"]


func reset_scene(scene) -> void:
	scene.players = [make_player("P0"), make_player("Caller"), make_player("P2"), make_player("P3")]
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.offline_hand_number = 1
	scene.wall = scene.make_wall()
	scene.offline_concealed_gang_tiles.clear()


func run() -> void:
	print("=== ai_play_round50 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	reset_scene(scene)

	print("--- A) a registered concealed quad keeps first-open thresholds ---")
	scene.players[1]["hand"] = claim_hand()
	scene.players[1]["melds"] = [["1T", "1T", "1T", "1T"]]
	scene.record_concealed_gang_meld(1, "1T")
	var concealed_context = scene.make_ai_claim_context(1, [], [], 0)
	var choice = {"meld": ["3W", "4W", "5W"], "needed": ["3W", "4W"]}
	var concealed_report = scene.build_ai_claim_report(1, "chi", "5W", choice, concealed_context)
	var first_open_threshold = scene.ai_claim_shape_threshold(1, "chi", 0)
	check(int(concealed_context.get("open_melds", -1)) == 1 and int(concealed_context.get("exposed_melds", -1)) == 0, "暗杠仍计结构固定组但不计明副露")
	check(int(concealed_report.get("structural_melds", -1)) == 1 and int(concealed_report.get("exposed_melds", -1)) == 0, "吃牌报告保留两种副露语义")
	check(is_equal_approx(float(concealed_report.get("threshold", -1.0)), first_open_threshold), "暗杠后的首次吃牌使用首次开门门槛")

	print("--- B) unmarked/open quad uses already-open thresholds conservatively ---")
	scene.offline_concealed_gang_tiles.clear()
	var open_context = scene.make_ai_claim_context(1, [], [], 0)
	var open_report = scene.build_ai_claim_report(1, "chi", "5W", choice, open_context)
	var opened_threshold = scene.ai_claim_shape_threshold(1, "chi", 1)
	check(int(open_context.get("exposed_melds", -1)) == 1 and int(open_report.get("exposed_melds", -1)) == 1, "未登记四张组按明杠处理")
	check(is_equal_approx(float(open_report.get("threshold", -1.0)), opened_threshold), "明杠后续吃牌保留既有低门槛")
	check(float(concealed_report.get("threshold", 0.0)) > float(open_report.get("threshold", 0.0)), "暗杠不会错误放宽首次开门判断")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
