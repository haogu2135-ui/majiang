extends SceneTree
## Round 23: each seat threat card must rank safety against that displayed opponent.
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
	print("=== ai_play_round23 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.setup_tile_order()
	scene.players = [make_player("Self"), make_player("WThreat"), make_player("MainThreat"), make_player("Third")]
	# Seat 1 is a real W-suit threat and has already discarded 5W. Seat 2 is
	# stronger overall, so it is the table main threat but 5W is not its genbutsu.
	scene.players[0]["hand"] = ["5W", "9T", "E"]
	scene.players[1]["melds"] = [["1W", "2W", "3W"], ["6W", "7W", "8W"]]
	scene.players[1]["discards"] = ["5W", "1T", "2T", "3T", "4T", "5T", "6T"]
	scene.players[2]["melds"] = [["2W", "3W", "4W"], ["6W", "7W", "8W"], ["1W", "1W", "1W"]]
	scene.players[2]["discards"] = ["1T", "2T", "3T", "4T", "5T", "6T", "7T"]

	print("--- A) per-seat genbutsu is not hidden by global main threat ---")
	var context = scene.make_ai_evaluation_context(0, scene.visible_tile_counts())
	check(scene.main_threat_opponent(0, context) == 2, "更强副露座位仍是全桌主威胁")
	check(not scene.is_main_threat_genbutsu("5W", 0, context), "5W 不是全桌主威胁现物")
	var target_safe = scene.threat_safe_tile_labels(0, "suit", 0, 3, context, 1)
	print("    target safe=%s" % str(target_safe))
	check(not target_safe.is_empty() and str(target_safe[0]) == scene.tile_label("5W"), "对座位 1 的安全牌优先其 5W 现物")

	print("--- B) rendered seat report keeps that opponent-specific ordering ---")
	var report = scene.opponent_seat_threat_report(0, 1, context)
	var report_safe: Array = report.get("safe_tiles", [])
	print("    report safe=%s" % str(report_safe))
	check(not report_safe.is_empty() and str(report_safe[0]) == scene.tile_label("5W"), "座位威胁卡显示自身现物为首选安全牌")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
