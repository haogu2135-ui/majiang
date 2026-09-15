extends SceneTree
## Round 285: discard candidate shanten searches share one batch memo.

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
	print("=== ai_play_round285 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.offline_all_bot_mode = true
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]

	var ai_source_285 := FileAccess.get_file_as_string("res://scripts/main_src/ai_brain.gd.part")
	var post_start_285 := ai_source_285.find("func best_ai_post_claim_discard_report")
	var post_end_285 := ai_source_285.find("func choose_ai_rob_gang", post_start_285)
	var post_function_285 := ai_source_285.substr(post_start_285, post_end_285 - post_start_285)
	check(post_function_285.contains("var post_claim_shanten_memo: Dictionary = {}"), "post-claim discard candidates allocate one shanten memo")
	check(post_function_285.contains("candidate_index, post_claim_shanten_memo)"), "post-claim fast reports consume the shared shanten memo")
	check(post_function_285.contains("candidate_index, -99, {}, post_claim_shanten_memo)"), "post-claim complete reports consume the shared shanten memo")

	var fast_start_285 := ai_source_285.find("func build_ai_fast_post_claim_discard_report")
	var fast_end_285 := ai_source_285.find("func choose_ai_rob_gang", fast_start_285)
	var fast_function_285 := ai_source_285.substr(fast_start_285, fast_end_285 - fast_start_285)
	check(fast_function_285.contains("shanten_search_memo: Dictionary = {}"), "fast post-claim report keeps a direct-call memo fallback")
	check(fast_function_285.contains("calculate_min_shanten_from_counts_with_memo(simulated_counts, open_melds, \"\", shanten_search_memo)"), "fast post-claim report uses the supplied memo")

	var discard_start_285 := ai_source_285.find("func get_ai_discard_reports")
	var discard_end_285 := ai_source_285.find("func sort_ai_discard_reports", discard_start_285)
	var discard_function_285 := ai_source_285.substr(discard_start_285, discard_end_285 - discard_start_285)
	check(discard_function_285.contains("var discard_shanten_memo: Dictionary = {}"), "discard candidate ranking allocates one batch shanten memo")
	check(discard_function_285.contains("calculate_min_shanten_from_counts_with_memo(simulated_counts, open_melds, \"\", discard_shanten_memo)"), "discard candidates reuse the batch memo")
	check(discard_function_285.contains("fast_risk_vector, discard_shanten_memo)"), "complete discard reports retain the batch memo")

	var hand_285: Array = ["1W", "2W", "3W", "5W", "6W", "7W", "9W", "1T", "2T", "4T", "5T", "7B", "E", "R"]
	var counts_285: Array = scene.tile_counts(hand_285)
	var candidate_indices_285: Array[int] = []
	for tile_285 in hand_285:
		var index_285: int = scene.tile_index(str(tile_285))
		if not candidate_indices_285.has(index_285):
			candidate_indices_285.append(index_285)

	scene.clear_shanten_cache()
	var shared_memo_285: Dictionary = {}
	var shared_values_285: Array[int] = []
	for index_285 in candidate_indices_285:
		counts_285[index_285] = int(counts_285[index_285]) - 1
		shared_values_285.append(scene.calculate_min_shanten_from_counts_with_memo(counts_285, 0, "", shared_memo_285))
		counts_285[index_285] = int(counts_285[index_285]) + 1
	check(shared_memo_285.size() > 0, "candidate shanten probes retain shared recursive sub-states")

	scene.clear_shanten_cache()
	var independent_values_285: Array[int] = []
	for index_285 in candidate_indices_285:
		counts_285[index_285] = int(counts_285[index_285]) - 1
		independent_values_285.append(scene.calculate_min_shanten_from_counts(counts_285, 0))
		counts_285[index_285] = int(counts_285[index_285]) + 1
	check(shared_values_285 == independent_values_285, "shared candidate recursion preserves independent shanten results")
	check(scene.counts_compact_key(counts_285) == scene.counts_compact_key(scene.tile_counts(hand_285)), "candidate count mutations are restored after memo probes")

	var visible_285: Array = scene.make_empty_tile_counts()
	var context_285: Dictionary = scene.make_ai_evaluation_context(1, visible_285)
	var post_report_285: Dictionary = scene.best_ai_post_claim_discard_report(1, hand_285, 0, context_285, scene.tile_counts(hand_285), [])
	check(not post_report_285.is_empty() and post_report_285.has("shanten"), "post-claim candidate evaluation remains callable with the shared memo")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
