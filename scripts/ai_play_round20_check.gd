extends SceneTree
## Round 20: all-bot games preserve score, tile inventory, and terminal state.
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
			"score": scene.MATCH_START_SCORE,
			"bot": true,
		})


func table_tile_count(scene) -> int:
	var total = scene.wall.size()
	for player in scene.players:
		total += player.get("hand", []).size()
		total += player.get("discards", []).size()
		total += player.get("flower_tiles", []).size()
		for meld in player.get("melds", []):
			total += meld.size()
	return total


func score_total(scene) -> int:
	var total = 0
	for player in scene.players:
		total += int(player.get("score", 0))
	return total


func delta_total(scene) -> int:
	var total = 0
	for delta in scene.last_score_deltas:
		total += int(delta)
	return total


func run_hand(scene, diff: int, hand_index: int) -> void:
	seed(20260810 + diff * 1009 + hand_index * 37)
	scene.ai_difficulty = diff
	scene.mode = "offline"
	scene.offline_hand_number = 1
	scene.dealer_seat = hand_index % 4
	for player in scene.players:
		player["score"] = scene.MATCH_START_SCORE
	scene.deal_offline_hand()
	var result = scene.simulate_offline_bot_hand_sync(900)
	var prefix = "%s hand%d" % [str(scene.AI_DIFFICULTY_LABELS[diff]), hand_index + 1]
	print("    %s ended=%s winner=%d wall=%d steps=%d" % [
		prefix,
		str(result.get("ended", false)),
		int(result.get("winner", -1)),
		int(result.get("wall", -1)),
		int(result.get("steps", -1)),
	])
	check(bool(result.get("ended", false)) and str(result.get("phase", "")) == "ended", "%s 在步数上限内完成" % prefix)
	check(score_total(scene) == scene.MATCH_START_SCORE * 4, "%s 全桌分数守恒" % prefix)
	check(table_tile_count(scene) == scene.make_wall().size(), "%s 牌张总数守恒" % prefix)
	check(delta_total(scene) == 0, "%s 本局分差守恒" % prefix)
	if int(result.get("winner", -1)) >= 0:
		check(not scene.last_win_score.is_empty() and int(scene.last_win_score.get("fan", 0)) >= 1, "%s 胡牌保留当前结算详情" % prefix)
	else:
		check(scene.last_win_score.is_empty() and scene.last_score_deltas == [0, 0, 0, 0], "%s 荒庄没有残留胡牌结算" % prefix)


func run() -> void:
	print("=== ai_play_round20 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.fast_mode_enabled = true
	scene.sfx_enabled = false
	scene.music_enabled = false
	scene.setup_tile_order()
	make_players(scene)

	print("--- A) deterministic all-bot stability sweep ---")
	for diff in [scene.AI_DIFFICULTY_EASY, scene.AI_DIFFICULTY_NORMAL, scene.AI_DIFFICULTY_HARD]:
		for hand_index in range(3):
			run_hand(scene, diff, hand_index)

	scene.enable_offline_all_bot_mode(false, false)
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
