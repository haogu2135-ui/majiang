extends SceneTree
## Round 17: a suji cue must be tied to the table's main threat.
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


func setup_table(scene) -> void:
	scene.players = [make_player("Self"), make_player("Threat"), make_player("Other"), make_player("Third")]
	# Seat 1 is visibly committed to W and must become the main threat.
	scene.players[1]["melds"] = [["4W", "5W", "6W"], ["5W", "6W", "7W"]]
	scene.players[1]["discards"] = ["1T", "2T", "3T", "4T", "5T", "6T"]
	# Seat 2 supplies a 4W suji anchor but has no competing threat.
	scene.players[2]["discards"] = ["4W", "1B", "2B", "3B", "4B", "5B"]
	scene.players[3]["discards"] = ["1T", "2T", "3T", "4T", "5T", "6T"]


func run() -> void:
	print("=== ai_play_round17 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.setup_tile_order()
	setup_table(scene)

	print("--- A) unrelated suji cannot hide the main threat ---")
	var context = scene.make_ai_evaluation_context(0, scene.visible_tile_counts())
	check(scene.main_threat_opponent(0, context) == 1, "副露染手座位被识别为主威胁")
	check(scene.is_suji_safe_against_opponent("1W", 2, context), "次要对手的 4W 构成 1W 筋")
	check(not scene.is_suji_safe_against_opponent("1W", 1, context), "主威胁没有对应筋")
	check(not scene.is_suji_safe_tile("1W", 0, context), "不因次要对手筋将 1W 标为安全")
	check(scene.tile_safety_label("1W", 0, scene.visible_tile_counts(), context) == "", "弃牌报告不显示误导性筋线")

	print("--- B) main-threat suji remains usable ---")
	scene.players[1]["discards"].append("4W")
	var anchored_context = scene.make_ai_evaluation_context(0, scene.visible_tile_counts())
	check(scene.main_threat_opponent(0, anchored_context) == 1, "加入锚牌后主威胁保持不变")
	check(scene.is_suji_safe_tile("1W", 0, anchored_context), "主威胁 4W 正确提供 1W 筋")
	check(scene.tile_safety_label("1W", 0, scene.visible_tile_counts(), anchored_context) == "筋", "弃牌报告保留主威胁筋线")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
