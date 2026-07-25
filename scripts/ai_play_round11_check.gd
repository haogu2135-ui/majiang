extends SceneTree
## Round 11: forced-feed signal correctness + package-liability-aware discards.
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
			"hand": [],
			"discards": [],
			"melds": [],
			"flowers": 0,
			"flower_tiles": [],
			"score": 25000,
			"bot": i != 0,
		})


func run() -> void:
	print("=== ai_play_round11 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.mode = "offline"
	scene.offline_hand_number = 5
	scene.dealer_seat = 0
	scene.wall = scene.make_wall()
	make_players(scene)
	if scene.has_method("setup_tile_order"):
		scene.setup_tile_order()
	scene.offline_all_bot_mode = false
	scene.offline_sim_quiet = false

	print("--- A) forced discard feed signal ---")
	# seat3 打 5W 时，seat0 是唯一可吃的下家；即使点炮 risk 很低，吃碰喂牌信号也应存在。
	var forced = {"discard": "5W", "risk": 4.0, "safety": ""}
	scene.ai_difficulty = scene.AI_DIFFICULTY_EASY
	var feed_easy = scene.human_claim_discipline_report(3, "chi", 2, 3, 3, 0.0, forced, 0)
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	var feed_hard = scene.human_claim_discipline_report(3, "chi", 2, 3, 3, 0.0, forced, 0)
	print("    feed easy/hard=%.1f/%.1f decline=%s/%s" % [
		float(feed_easy.get("feed_human", 0.0)), float(feed_hard.get("feed_human", 0.0)),
		str(feed_easy.get("decline", false)), str(feed_hard.get("decline", false)),
	])
	check(float(feed_easy.get("feed_human", 0.0)) > 0.0, "副露后被迫弃牌读取吃碰喂牌详情")
	check(float(feed_hard.get("penalty", 0.0)) > float(feed_easy.get("penalty", 0.0)), "困难档对喂玩家副露惩罚更高")
	check(bool(feed_hard.get("decline", false)), "困难档拒绝无收益且会喂玩家的副露")

	print("--- B) package liability discipline ---")
	var synthetic_feed = {
		"score": 24.0,
		"details": [{"opponent": 2, "name": "P2", "claim": "peng", "label": "碰", "score": 24.0}],
	}
	scene.offline_claim_counts.clear()
	scene.offline_package_liability.clear()
	var before_third = scene.package_feed_discipline_report(1, "5W", synthetic_feed, 3)
	check(not bool(before_third.get("pending", false)), "不足两搭时不误报包三搭")
	scene.offline_claim_counts[scene.claim_source_key(2, 1)] = 2
	scene.ai_difficulty = scene.AI_DIFFICULTY_EASY
	var package_easy = scene.package_feed_discipline_report(1, "5W", synthetic_feed, 3)
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	var package_hard = scene.package_feed_discipline_report(1, "5W", synthetic_feed, 3)
	var package_tenpai = scene.package_feed_discipline_report(1, "5W", synthetic_feed, 0)
	print("    package easy/hard/tenpai=%.1f/%.1f/%.1f" % [
		float(package_easy.get("penalty", 0.0)), float(package_hard.get("penalty", 0.0)), float(package_tenpai.get("penalty", 0.0)),
	])
	check(bool(package_hard.get("pending", false)), "第三搭候选识别为包赔风险")
	check(int(package_hard.get("opponent", -1)) == 2, "包赔风险定位到正确对手")
	check(float(package_hard.get("penalty", 0.0)) > float(package_easy.get("penalty", 0.0)), "困难档更重视包赔责任")
	check(float(package_tenpai.get("penalty", 0.0)) < float(package_hard.get("penalty", 0.0)), "听牌时允许为进攻适度承担包赔风险")
	scene.offline_package_liability[2] = 3
	var already_liable = scene.package_feed_discipline_report(1, "5W", synthetic_feed, 3)
	check(not bool(already_liable.get("pending", false)), "责任已归属别人时不重复惩罚")

	print("--- C) discard report + cache wiring ---")
	scene.offline_package_liability.clear()
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	scene.players[1]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7T", "8T", "9T", "2B", "3B", "4B", "E", "E"]
	scene.players[1]["melds"] = []
	scene.players[1]["discards"] = []
	scene.players[2]["melds"] = [["1B", "1B", "1B"], ["2B", "2B", "2B"]]
	var cache_with_two = scene.ai_report_cache_key(1)
	scene.offline_claim_counts[scene.claim_source_key(2, 1)] = 1
	var cache_with_one = scene.ai_report_cache_key(1)
	check(cache_with_two != cache_with_one, "AI 缓存键包含包三搭进度")
	scene.offline_claim_counts[scene.claim_source_key(2, 1)] = 2
	var simulated: Array = scene.players[1]["hand"].duplicate()
	simulated.erase("5W")
	var report = scene.build_ai_discard_report(1, "5W", simulated, 0)
	print("    report pending=%s pen=%.1f opponent=%s text=%s" % [
		str(report.get("package_feed_pending", false)), float(report.get("package_feed_penalty", 0.0)),
		str(report.get("package_feed_opponent", -1)), str(report.get("package_feed_text", "")),
	])
	check(bool(report.get("package_feed_pending", false)), "弃牌报告接入包三搭风险")
	check(float(report.get("package_feed_penalty", 0.0)) > 0.0, "弃牌总分扣除包赔惩罚")
	check(str(report.get("package_feed_text", "")).find("包三搭") >= 0, "弃牌报告提供可读包赔原因")
	check(scene.discard_safety_text(report).find("包三搭") >= 0, "弃牌安全说明展示包赔风险")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
