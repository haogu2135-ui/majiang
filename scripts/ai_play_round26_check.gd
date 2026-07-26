extends SceneTree
## Round 26: quiet claim previews use the bounded safety evaluator without changing live play.
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


func contains_tile(hand: Array, tile: String) -> bool:
	for item in hand:
		if str(item) == tile:
			return true
	return false


func run() -> void:
	print("=== ai_play_round26 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.mode = "offline"
	scene.setup_tile_order()
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.wall = scene.make_wall()
	scene.players[1]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "2B", "3B", "E"]
	scene.players[1]["melds"] = [["5T", "5T", "5T"]]
	for seat in [0, 2, 3]:
		scene.players[seat]["discards"] = ["9B", "9B", "1T", "1T", "E", "S", "W", "N"]

	print("--- A) quiet preview stays bounded and returns safety data ---")
	scene.offline_sim_quiet = true
	var quiet_start = Time.get_ticks_msec()
	var quiet = scene.best_ai_post_claim_discard_report(1, scene.players[1]["hand"], 1)
	var quiet_ms = Time.get_ticks_msec() - quiet_start
	print("    quiet tile=%s risk=%.1f ms=%d" % [str(quiet.get("tile", "")), float(quiet.get("risk", 0.0)), quiet_ms])
	check(bool(quiet.get("fast_post_claim", false)), "静默预演使用快速后续弃牌评估")
	check(contains_tile(scene.players[1]["hand"], str(quiet.get("tile", ""))), "静默预演返回副露后可实际打出的牌")
	check(quiet.has("risk") and quiet.has("safety_label"), "静默预演保留防守所需的风险和安全字段")
	check(quiet_ms < 700, "静默后续弃牌预演保持低开销")

	print("--- B) live preview keeps the complete evaluator ---")
	scene.offline_sim_quiet = false
	var live = scene.best_ai_post_claim_discard_report(1, scene.players[1]["hand"], 1)
	print("    live tile=%s risk=%.1f" % [str(live.get("tile", "")), float(live.get("risk", 0.0))])
	check(not bool(live.get("fast_post_claim", false)), "前台对局不降级为静默快速预演")
	check(contains_tile(scene.players[1]["hand"], str(live.get("tile", ""))), "前台预演仍返回合法弃牌")
	check(live.has("plan_label") and live.has("feed_report"), "前台预演保留完整牌效与喂牌信息")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
