extends SceneTree
## Round 18: ukeire cache must account for table visibility.
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
	print("=== ai_play_round18 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.setup_tile_order()
	scene.players = [make_player("Self"), make_player("P1"), make_player("P2"), make_player("P3")]
	# Four complete runs plus a singleton 5B: only 5B completes the hand.
	var tenpai := ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "2T", "3T", "4T", "5B"]
	scene.players[0]["hand"] = tenpai.duplicate()
	scene.clear_ai_report_cache()

	print("--- A) baseline live wait ---")
	var baseline = scene.effective_tile_metrics(tenpai, 0, 0, 0, scene.visible_tile_counts())
	var baseline_remaining = int(baseline.get("remaining_by_tile", {}).get("5B", -1))
	print("    baseline waits=%s remaining_5B=%d" % [str(baseline.get("tiles", [])), baseline_remaining])
	check(baseline.get("tiles", []) == ["5B"], "夹具只有 5B 成和")
	check(baseline_remaining == 3, "未见 5B 时保留三枚有效张")

	print("--- B) same hand after visible tiles change ---")
	scene.players[1]["discards"] = ["5B", "5B"]
	var after_two_visible = scene.effective_tile_metrics(tenpai, 0, 0, 0, scene.visible_tile_counts())
	var after_remaining = int(after_two_visible.get("remaining_by_tile", {}).get("5B", -1))
	print("    after_two_visible remaining_5B=%d" % after_remaining)
	check(after_remaining == 1, "牌河露出两枚后有效张即时降为一枚")

	print("--- C) exhausted wait is removed ---")
	scene.players[2]["discards"] = ["5B"]
	var exhausted = scene.effective_tile_metrics(tenpai, 0, 0, 0, scene.visible_tile_counts())
	print("    exhausted waits=%s count=%d" % [str(exhausted.get("tiles", [])), int(exhausted.get("count", -1))])
	check(not exhausted.get("tiles", []).has("5B") and int(exhausted.get("count", -1)) == 0, "四枚 5B 已知时不保留假有效张")
	check(int(scene.effective_tiles_cache_misses) >= 3, "可见牌变化生成独立有效张缓存")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
