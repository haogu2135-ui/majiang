extends "res://scripts/ai_play_round298_check.gd"


func prepare_claim_table(scene: Node, case_name: String) -> Dictionary:
	scene.cancel_offline_ai_run()
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.offline_active_rule_variant = scene.RULE_VARIANT_YANGZHOU
	scene.rule_variant = scene.RULE_VARIANT_YANGZHOU
	scene.current_seat = 0
	scene.dealer_seat = 0
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	scene.ai_benchmark_base_difficulty = -1
	scene.ai_benchmark_probe_seat = -1
	scene.ai_benchmark_probe_difficulty = -1
	scene.active_round_id = "post-claim-%s" % case_name
	scene.offline_pending_claim.clear()
	scene.offline_passed_win_tiles.clear()
	scene.offline_claim_discard_bans.clear()
	scene.offline_concealed_gang_tiles.clear()
	scene.offline_claim_counts.clear()
	scene.offline_package_liability.clear()
	scene.players = [make_player(0), make_player(1), make_player(2), make_player(3)]
	scene.wall = scene.make_wall()
	var hand: Array = []
	var claim := "peng"
	var source_tile := "5B"
	var choice := {}
	var public_copies := 0
	var discard := "E"
	match case_name:
		"peng_dead":
			hand = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "5B", "5B", "5B", "E"]
		"peng_route":
			hand = ["1W", "1W", "2T", "3T", "4T", "5T", "6T", "7T", "8T", "9T", "9T", "9T", "E"]
			source_tile = "1W"
		"peng_dragon":
			hand = ["C", "C", "1W", "1W", "1W", "2T", "2T", "2T", "3B", "3B", "3B", "E", "E"]
			source_tile = "C"
			discard = "E"
		"peng_concealed_gang":
			hand = ["5B", "5B", "2T", "3T", "4T", "6T", "7T", "8T", "E", "E"]
			scene.players[1]["melds"] = [["Z", "Z", "Z", "Z"]]
			scene.offline_concealed_gang_tiles[1] = {"Z": true}
		"chi_straight":
			hand = ["2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "E", "E", "E", "2T", "2T"]
			claim = "chi"
			source_tile = "1W"
			choice = {"needed": ["2W", "3W"], "meld": ["1W", "2W", "3W"]}
			discard = "2T"
		"chi_score":
			hand = ["2W", "3W", "4W", "5W", "6W", "7B", "8B", "9B", "E", "E", "E", "2T", "2T"]
			claim = "chi"
			source_tile = "1W"
			choice = {"needed": ["2W", "3W"], "meld": ["1W", "2W", "3W"]}
			discard = "2T"
		"chi_dead":
			hand = ["1W", "3W", "4B", "5B", "6B", "7B", "8B", "9B", "E", "E", "2T", "2W", "3W"]
			claim = "chi"
			source_tile = "1W"
			choice = {"needed": ["2W", "3W"], "meld": ["1W", "2W", "3W"]}
			public_copies = 3
			discard = "2T"
	hand = scene.normalize_tile_array(hand)
	source_tile = scene.normalize_tile_code(source_tile)
	scene.players[1]["hand"] = hand
	for existing_meld in scene.players[1]["melds"]:
		for tile in existing_meld:
			scene.wall.erase(str(tile))
	for tile in hand:
		scene.wall.erase(str(tile))
	scene.players[0]["hand"].append(source_tile)
	scene.wall.erase(source_tile)
	for copy_index in range(public_copies):
		scene.players[3]["discards"].append("2W")
		scene.wall.erase("2W")
	for seat in [0, 2, 3]:
		var target_size := 14 if seat == 0 else 13
		while scene.players[seat]["hand"].size() < target_size:
			var tile: String = scene.wall.pop_back()
			if scene.is_flower_tile(tile):
				scene.players[seat]["flower_tiles"].append(tile)
				scene.players[seat]["flowers"] += 1
			else:
				scene.players[seat]["hand"].append(tile)
	scene.last_discard = ""
	scene.last_discard_seat = -1
	scene.round_event_history.clear()
	scene.round_event_sequence = 0
	scene.record_round_event("round_start", {"dealer": 0, "seed": 299, "rule_variant": scene.RULE_VARIANT_YANGZHOU})
	scene.clear_ai_report_cache()
	check(scene.offline_tile_ledger_report().get("ok", false), "the post-claim fixture allocates every tile and flower without impossible inventory")
	check(scene.commit_discard(0, source_tile) and scene.is_valid_offline_claim(1, 0, source_tile, claim, choice), "the source discard and planned claim are legal production actions")
	var after: Array = hand.duplicate()
	var meld: Array = choice.get("meld", []) if claim == "chi" else [source_tile, source_tile, source_tile]
	var needed: Array = choice.get("needed", []) if claim == "chi" else [source_tile, source_tile]
	for tile in needed:
		after.erase(str(tile))
	return {"claim": claim, "source_tile": source_tile, "choice": choice, "after": after, "meld": meld, "discard": discard}


func projected_context(scene: Node, fixture: Dictionary, original: Dictionary) -> Dictionary:
	if scene.has_method("make_ai_post_claim_evaluation_context"):
		return scene.make_ai_post_claim_evaluation_context(1, fixture["after"], fixture["meld"], original)
	return original


func check_claim_prediction(scene: Node, case_name: String) -> void:
	print("=== CLAIM CASE: %s ===" % case_name)
	scene.offline_sim_quiet = false
	var fixture := prepare_claim_table(scene, case_name)
	var visible: Array = scene.visible_tile_counts_shared()
	var original: Dictionary = scene.make_ai_evaluation_context(1, visible)
	scene.ai_context_self_discard_lookup(original, 1)
	var original_inputs := {"visible": original["visible_counts"].duplicate(), "known": original["known_counts"].duplicate(), "melds": original["meld_tile_indices"].duplicate(), "river": original["self_discard_lookup"].duplicate()}
	var before := snapshot(scene)
	var after_open_melds: int = scene.players[1]["melds"].size() + 1
	var original_straight_groups: Array = scene.full_straight_open_meld_groups_for_seat(1).duplicate(true)
	var context := projected_context(scene, fixture, original)
	var after: Array = fixture["after"]
	var simulated := after.duplicate()
	simulated.erase(fixture["discard"])
	var predicted: Dictionary = scene.build_ai_discard_report(1, fixture["discard"], simulated, after_open_melds, visible, {}, context, scene.tile_counts(simulated), scene.tile_counts(after))
	var best: Dictionary = scene.best_ai_post_claim_discard_report(1, after, after_open_melds, context, scene.tile_counts(after), scene.claim_discard_ban_tiles(fixture["claim"], fixture["source_tile"], fixture["meld"]))
	var predicted_scores := {}
	for wait_tile in predicted.get("effective_tiles", []):
		var winning: Array = simulated.duplicate()
		winning.append(str(wait_tile))
		predicted_scores[str(wait_tile)] = scene.calculate_win_score_from_tiles(1, winning, false, "", false, [], -1, [], false, context.get("scoring_melds", []))
	var claim_context: Dictionary = scene.make_ai_claim_context(1, visible, [], 0)
	var claim_report: Dictionary = scene.build_ai_claim_report(1, fixture["claim"], fixture["source_tile"], fixture["choice"], claim_context)
	check(claim_report.get("forced_discard_effective_remaining", {}) == best.get("effective_remaining", {}), "the production claim report exports its projected continuation inventory")
	check(int(claim_report.get("forced_discard_wait_best_points", -1)) == int(best.get("wait_best_points", -2)), "the production claim report exports its projected continuation score")
	check(snapshot(scene) == before and original["visible_counts"] == original_inputs["visible"] and original["known_counts"] == original_inputs["known"] and original["meld_tile_indices"] == original_inputs["melds"] and original["self_discard_lookup"] == original_inputs["river"], "claim forecasting leaves the live table and shared pre-claim inputs unchanged")
	check(int(context.get("discard_report_exposed_melds", -1)) == 1 and context.get("meld_tile_indices", []).size() == original["meld_tile_indices"].size() + 3, "the forecast owns the new exposed meld without changing live scoring state")
	check(scene.full_straight_open_meld_groups_for_seat(1) == original_straight_groups, "prospective scoring does not poison the live meld grouping cache")
	if case_name.ends_with("dead"):
		check(int(predicted.get("ukeire", -1)) == 0 and predicted.get("effective_tiles", []).is_empty(), "tiles moved into the new meld cannot create a fifth-copy continuation wait")
	scene.apply_offline_claim(1, 0, fixture["source_tile"], fixture["claim"], fixture["choice"])
	check(scene.offline_phase == "await_discard" and scene.current_seat == 1 and scene.players[1]["melds"].size() == after_open_melds and scene.offline_tile_ledger_report().get("ok", false), "the real claim commits one exposed meld with a complete physical ledger")
	check(scene.commit_discard(1, fixture["discard"]), "the forecasted continuation is a legal real post-claim discard")
	var actual_hand: Array = scene.players[1]["hand"]
	var actual_visible: Array = scene.visible_tile_counts_shared()
	var actual_metrics: Dictionary = scene.effective_tile_metrics(actual_hand, after_open_melds, 1, scene.calculate_min_shanten(actual_hand, after_open_melds), actual_visible)
	check(predicted.get("effective_remaining", {}) == actual_metrics.get("remaining_by_tile", {}) and int(predicted.get("ukeire", -1)) == int(actual_metrics.get("count", -2)), "predicted post-claim waits match the independently measured committed table")
	var actual_context: Dictionary = scene.make_ai_evaluation_context(1, actual_visible)
	var actual_counts: Array = scene.tile_counts(actual_hand)
	var actual_report: Dictionary = scene.build_ai_discard_report(1, fixture["discard"], actual_hand, after_open_melds, actual_visible, {}, actual_context, actual_counts, actual_counts)
	check(int(predicted.get("wait_best_points", -1)) == int(actual_report.get("wait_best_points", -2)) and int(predicted.get("wait_best_fan", -1)) == int(actual_report.get("wait_best_fan", -2)) and is_equal_approx(float(predicted.get("wait_value", -1.0)), float(actual_report.get("wait_value", -2.0))), "predicted wait fan points and quality match the real exposed-hand evaluation")
	check(str(predicted.get("plan_label", "")) == str(actual_report.get("plan_label", "")) and is_equal_approx(float(predicted.get("plan", -1.0)), float(actual_report.get("plan", -2.0))), "the projected route includes the new meld exactly like the committed hand")
	for wait_tile in actual_metrics.get("tiles", []):
		var winning: Array = actual_hand.duplicate()
		winning.append(str(wait_tile))
		var score: Dictionary = scene.calculate_win_score_from_tiles(1, winning, false)
		check(not score.get("reasons", []).has("门清") and int(score.get("points", 0)) > 0, "an actual open continuation cannot retain the pre-claim menzen bonus")
		check(predicted_scores.get(str(wait_tile), {}) == score, "the authoritative prospective score matches every committed winning pattern")
		if case_name == "chi_straight":
			check(score.get("reasons", []).has("一条龙"), "the future chi supplies the missing straight sequence in actual and predicted scoring")
		if case_name == "peng_dragon":
			check(score.get("reasons", []).has("碰碰胡"), "the future canonical dragon peng preserves the triplet scoring pattern")
		if case_name == "peng_concealed_gang":
			check(score.get("reasons", []).has("杠") and scene.scoring_meld_state_for_seat(1).get("value", -1) == 1, "an existing concealed gang retains its gang bonus while only the new peng is exposed")
	if not case_name.ends_with("dead"):
		check(not actual_metrics.get("tiles", []).is_empty(), "the live-pattern fixture has a physical winning continuation")
	check(scene.offline_tile_ledger_report().get("ok", false), "forecast and execution retain all physical cards after claim and discard")


func check_projection_boundaries(scene: Node) -> void:
	scene.offline_sim_quiet = false
	var fixture := prepare_claim_table(scene, "chi_straight")
	var original: Dictionary = scene.make_ai_evaluation_context(1)
	var original_inputs := original.duplicate(true)
	var before := snapshot(scene)
	var invalid_after: Array = fixture["after"].duplicate()
	invalid_after.erase("E")
	check(scene.make_ai_post_claim_evaluation_context(1, invalid_after, fixture["meld"], original).is_empty(), "a claim projection rejects removal of tiles outside its new meld")
	check(scene.make_ai_post_claim_evaluation_context(1, scene.players[1]["hand"], fixture["meld"], original).is_empty(), "a claim projection rejects an incorrect consumed tile total")
	var valid_winning: Array = ["2W", "3W", "4W", "6T", "7T", "8T", "E", "E", "E", "5B", "5B"]
	var invalid_shape: Dictionary = scene.calculate_win_score_from_tiles(1, valid_winning, false, "", false, [], -1, [], false, [["1W", "2W", "4W"]])
	var fifth_copy: Dictionary = scene.calculate_win_score_from_tiles(1, valid_winning, false, "", false, [], -1, [], false, [["5B", "5B", "5B"]])
	check(int(invalid_shape.get("points", -1)) == 0 and int(fifth_copy.get("points", -1)) == 0, "the public prospective scorer rejects malformed melds and fifth-copy inventory")
	check(snapshot(scene) == before and original == original_inputs, "invalid prospective inputs cannot mutate the live table or caller snapshots")
	var context := projected_context(scene, fixture, original)
	var after: Array = fixture["after"]
	var after_counts: Array = scene.tile_counts(after)
	var after_before := after.duplicate()
	var counts_before := after_counts.duplicate()
	var projected_visible_before: Array = context["post_claim_visible_counts"].duplicate()
	scene.offline_sim_quiet = true
	var started := Time.get_ticks_msec()
	var quiet: Dictionary = scene.best_ai_post_claim_discard_report(1, after, 1, context, after_counts, scene.claim_discard_ban_tiles(fixture["claim"], fixture["source_tile"], fixture["meld"]))
	var elapsed := Time.get_ticks_msec() - started
	check(quiet.get("fast_post_claim", false) and after.has(quiet.get("tile", "")) and quiet.has("risk") and quiet.has("feed_report") and elapsed < 700, "prospective quiet evaluation retains the bounded fast safety path")
	check(after == after_before and after_counts == counts_before and context["post_claim_visible_counts"] == projected_visible_before and snapshot(scene) == before, "prospective quiet evaluation preserves caller arrays and physical inventory")
	scene.offline_sim_quiet = false
	var original_claim: Dictionary = scene.build_ai_claim_report(1, fixture["claim"], fixture["source_tile"], fixture["choice"], scene.make_ai_claim_context(1))
	var hidden_tile: String = scene.players[3]["hand"][0]
	var wall_tile: String = scene.wall[0]
	scene.players[3]["hand"][0] = wall_tile
	scene.wall[0] = hidden_tile
	scene.clear_ai_report_cache()
	var swapped_claim: Dictionary = scene.build_ai_claim_report(1, fixture["claim"], fixture["source_tile"], fixture["choice"], scene.make_ai_claim_context(1))
	check(scene.offline_tile_ledger_report().get("ok", false), "the post-claim hidden-information swap conserves every physical copy")
	check(original_claim.get("forced_discard_effective_remaining", {}) == swapped_claim.get("forced_discard_effective_remaining", {}) and original_claim.get("forced_discard_wait_best_points", -1) == swapped_claim.get("forced_discard_wait_best_points", -2) and original_claim.get("forced_discard", "") == swapped_claim.get("forced_discard", "missing"), "post-claim forecasting cannot inspect hidden opponents or wall order")


func run() -> void:
	print("=== ai_play_round299 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	var user_state := capture_smoke_state(scene)
	scene.set_process(false)
	scene.music_enabled = false
	scene.sfx_enabled = false
	scene.tts_enabled = false
	scene.fx_enabled = false
	scene.ai_assist_enabled = false
	scene.setup_tile_order()
	scene.reset_ai_profile_seat_map()
	for case_name in ["peng_dead", "chi_dead", "peng_route", "chi_score", "peng_dragon", "chi_straight", "peng_concealed_gang"]:
		check_claim_prediction(scene, case_name)
	check_projection_boundaries(scene)
	scene.shutdown_runtime()
	restore_smoke_state(scene, user_state)
	scene.queue_free()
	await process_frame
	print("=== RESULT: %s ===" % ("FAIL" if failed else "OK"))
	quit(1 if failed else 0)
