extends "res://scripts/ai_play_round298_check.gd"


func prepare_furiten_table(scene: Node, case_name: String, open_hand: bool = false, prospective: bool = false) -> void:
	scene.cancel_offline_ai_run()
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.offline_active_rule_variant = scene.RULE_VARIANT_YANGZHOU
	scene.rule_variant = scene.RULE_VARIANT_YANGZHOU
	scene.current_seat = 0 if prospective else 1
	scene.dealer_seat = 0
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	scene.ai_benchmark_base_difficulty = -1
	scene.ai_benchmark_probe_seat = -1
	scene.ai_benchmark_probe_difficulty = -1
	scene.active_round_id = "wait-wide-furiten-%s-%s-%s-%s" % [case_name, open_hand, prospective, scene.offline_sim_quiet]
	scene.offline_pending_claim.clear()
	scene.offline_passed_win_tiles.clear()
	scene.offline_claim_discard_bans.clear()
	scene.offline_concealed_gang_tiles.clear()
	scene.offline_claim_counts.clear()
	scene.offline_package_liability.clear()
	scene.players = [make_player(0), make_player(1), make_player(2), make_player(3)]
	scene.wall = scene.make_wall()
	var hand: Array = ["1T", "2T", "3T", "4T", "5T", "6T", "7B", "8B", "9B", "E", "E", "4W", "5W", "9T"]
	if open_hand:
		scene.players[1]["melds"] = [["1T", "2T", "3T"]]
		for tile in scene.players[1]["melds"][0]:
			hand.erase(str(tile))
			scene.wall.erase(str(tile))
	if prospective:
		hand.erase("1T")
		scene.players[0]["hand"].append("1T")
		scene.wall.erase("1T")
	scene.players[1]["hand"] = hand
	for tile in hand:
		scene.wall.erase(str(tile))
	var river_tile := "N" if case_name == "clean" else "6W"
	scene.players[1]["discards"].append(river_tile)
	scene.wall.erase(river_tile)
	if case_name == "dead":
		for copy_index in range(3):
			scene.players[2]["discards"].append("6W")
			scene.wall.erase("6W")
	for seat in [0, 2, 3]:
		var target_size := 14 if prospective and seat == 0 else 13
		while scene.players[seat]["hand"].size() < target_size:
			var tile: String = scene.wall.pop_back()
			if scene.is_flower_tile(tile):
				scene.players[seat]["flower_tiles"].append(tile)
				scene.players[seat]["flowers"] += 1
			else:
				scene.players[seat]["hand"].append(tile)
	scene.last_discard = ""
	scene.last_discard_seat = -1
	scene.offline_last_draw = {"seat": scene.current_seat, "tile": "1T" if prospective else "9T", "source": "normal", "serial": 300, "wall_empty": false}
	scene.round_event_history.clear()
	scene.round_event_sequence = 0
	scene.record_round_event("round_start", {"dealer": 0, "seed": 300, "rule_variant": scene.RULE_VARIANT_YANGZHOU})
	scene.clear_ai_report_cache()
	check(scene.offline_tile_ledger_report().get("ok", false), "the wait-wide furiten fixture conserves every physical tile and flower")
	if prospective:
		var choice := {"needed": ["2T", "3T"], "meld": ["1T", "2T", "3T"]}
		check(scene.commit_discard(0, "1T") and scene.is_valid_offline_claim(1, 0, "1T", "chi", choice), "the future-furiten fixture starts with a legal source discard and chi")


func check_furiten_prediction(scene: Node, case_name: String, quiet: bool, open_hand: bool = false, prospective: bool = false) -> void:
	print("=== FURITEN CASE: %s quiet=%s open=%s prospective=%s ===" % [case_name, quiet, open_hand, prospective])
	scene.offline_sim_quiet = quiet
	prepare_furiten_table(scene, case_name, open_hand, prospective)
	var visible: Array = scene.visible_tile_counts_shared()
	var original: Dictionary = scene.make_ai_evaluation_context(1, visible)
	scene.ai_context_self_discard_lookup(original, 1)
	var original_inputs := {"visible": original["visible_counts"].duplicate(), "known": original["known_counts"].duplicate(), "river": original["self_discard_lookup"].duplicate()}
	var context := original
	var after: Array = scene.players[1]["hand"].duplicate()
	var meld_count: int = scene.players[1]["melds"].size()
	if prospective:
		after.erase("2T")
		after.erase("3T")
		meld_count += 1
		context = scene.make_ai_post_claim_evaluation_context(1, after, ["1T", "2T", "3T"], original)
	var simulated := after.duplicate()
	simulated.erase("9T")
	var before := snapshot(scene)
	var report: Dictionary = scene.build_ai_discard_report(1, "9T", simulated, meld_count, visible, {}, context, scene.tile_counts(simulated), scene.tile_counts(after))
	var expected_furiten := case_name != "clean"
	var expected_remaining := 4 if case_name == "dead" else (8 if case_name == "clean" else 7)
	check(int(report.get("shanten", 8)) == 0 and int(report.get("ukeire", -1)) == expected_remaining, "wait-wide furiten forecasting keeps physical live-wait inventory unchanged")
	check(report.get("effective_tiles", []).has("3W") and report.get("effective_tiles", []).has("6W") == (case_name != "dead"), "an exhausted structural wait is not exported as a live physical wait")
	check(bool(report.get("wait_discard_furiten", false)) == expected_furiten, "the candidate exports the same wait-wide discard-furiten state as legal ron")
	check(is_equal_approx(float(report.get("wait_adjusted_remaining", -1.0)), float(expected_remaining) * (0.62 if expected_furiten else 1.0)), "every live face receives the existing self-draw-only weight when any structural wait is self-discarded")
	check(report.get("wait_self_discarded", []).has("6W") == expected_furiten, "the candidate retains a self-discarded structural trigger even when every copy is exhausted")
	check(str(scene.wait_quality_text(report)).contains("仅自摸") == expected_furiten and str(scene.advisor_value_short_text(report)).contains("仅自摸") == expected_furiten, "advisor wait quality clearly distinguishes self-draw-only furiten from unrestricted live waits")
	check(snapshot(scene) == before and original["visible_counts"] == original_inputs["visible"] and original["known_counts"] == original_inputs["known"] and original["self_discard_lookup"] == original_inputs["river"], "wait-wide furiten forecasting preserves the live table and shared snapshots")
	if prospective:
		scene.apply_offline_claim(1, 0, "1T", "chi", {"needed": ["2T", "3T"], "meld": ["1T", "2T", "3T"]})
		check(scene.offline_phase == "await_discard" and scene.players[1]["melds"].size() == 1, "the prospective furiten hand commits its real chi before the forced discard")
	check(scene.commit_discard(1, "9T") and scene.offline_tile_ledger_report().get("ok", false), "the predicted furiten continuation commits through the real discard boundary")
	check(scene.can_win_for_seat(1, "3W") and scene.is_discard_furiten(1, "3W") == expected_furiten and scene.can_ron_for_seat(1, "3W") == not expected_furiten, "legal ron on the un-discarded live face is wait-wide blocked exactly when the prediction says furiten")
	var actual_hand: Array = scene.players[1]["hand"]
	var actual_counts: Array = scene.tile_counts(actual_hand)
	var actual: Dictionary = scene.build_ai_discard_report(1, "9T", actual_hand, meld_count, scene.visible_tile_counts_shared(), {}, scene.make_ai_evaluation_context(1), actual_counts, actual_counts)
	check(actual.get("wait_discard_furiten", false) == report.get("wait_discard_furiten", false) and actual.get("wait_self_discarded", []) == report.get("wait_self_discarded", []) and is_equal_approx(float(actual.get("wait_adjusted_remaining", -1.0)), float(report.get("wait_adjusted_remaining", -2.0))), "predicted furiten metadata and adjusted live waits match the independently committed table")
	scene.current_seat = 1
	scene.offline_phase = "await_discard"
	scene.offline_pending_claim.clear()
	scene.wall.erase("3W")
	scene.wall.append("3W")
	check(scene.draw_tile_for(1, false) == "3W" and scene.offline_tile_ledger_report().get("ok", false), "the furiten hand can draw a conserved live winning tile through the production draw path")
	check(scene.can_win_for_seat(1) and scene.can_finish_offline_round(1, "3W", true, -1), "discard furiten never blocks the actual self-draw settlement guard")
	scene.offline_sim_quiet = true
	scene.finish_offline_round(1, "3W", true, -1)
	check(scene.offline_phase == "ended" and scene.offline_last_winner == 1 and scene.offline_tile_ledger_report().get("ok", false), "the self-draw-only forecast finishes a legal round with all physical tiles conserved")


func check_structural_furiten_boundaries(scene: Node) -> void:
	scene.offline_sim_quiet = false
	prepare_furiten_table(scene, "dead")
	var visible: Array = scene.visible_tile_counts_shared()
	var context: Dictionary = scene.make_ai_evaluation_context(1, visible)
	var before := snapshot(scene)
	var simulated: Array = scene.players[1]["hand"].duplicate()
	simulated.erase("9T")
	var counts: Array = scene.tile_counts(simulated)
	var counts_before := counts.duplicate()
	var alias_lookup := {"6M": true, "6W": true, "N": true}
	var lookup_before := alias_lookup.duplicate()
	check(scene.self_discarded_structural_waits_from_counts(counts, simulated.size(), 0, alias_lookup) == ["6W"], "structural furiten normalizes duplicate aliases without inventing extra trigger faces")
	check(counts == counts_before and alias_lookup == lookup_before and snapshot(scene) == before, "structural furiten probes restore every count and leave caller lookup and live state unchanged")
	check(scene.self_discarded_structural_waits_from_counts(counts, simulated.size(), 0, {}).is_empty() and scene.self_discarded_structural_waits_from_counts(counts, simulated.size() + 1, 0, alias_lookup).is_empty(), "empty rivers and non-ready tile totals cannot inherit a previous furiten result")
	var orphans: Array = ["1W", "9W", "1T", "9T", "1B", "9B", "E", "S", "R", "N", "Z", "F", "P"]
	check(scene.self_discarded_structural_waits_from_counts(scene.tile_counts(orphans), 13, 0, {"C": true}) == ["Z"], "the structural furiten probe honors a canonical thirteen-orphans wait")
	var pairs: Array = ["1W", "1W", "2W", "2W", "3T", "3T", "4T", "4T", "5B", "5B", "6B", "6B", "N"]
	check(scene.self_discarded_structural_waits_from_counts(scene.tile_counts(pairs), 13, 0, {"N": true}) == ["N"], "the structural furiten probe honors a seven-pairs wait")
	var original_report: Dictionary = scene.build_ai_discard_report(1, "9T", simulated, 0, visible, {}, context, counts, scene.tile_counts(scene.players[1]["hand"]))
	check(scene.advisor_compact_value_text(original_report).contains("振听仅自摸"), "the compact advisor card prioritizes the wait-wide self-draw-only restriction")
	var original_self: Dictionary = scene.players[0]
	scene.players[0] = scene.players[1]
	scene.current_seat = 0
	scene.current_human_advice = [original_report]
	check(scene.advisor_detail_text().contains("整手所有听口均仅可自摸，不可接炮"), "the actual advisor detail explains that every wait is ron-blocked even after its trigger is exhausted")
	scene.current_human_advice = [{"tile": "9T", "shanten": 0, "ukeire": 8, "wait_discard_furiten": false}]
	check(not scene.advisor_detail_text().contains("振听限制") and not scene.advisor_compact_value_text(scene.current_human_advice[0]).contains("仅自摸"), "the advisor removes the restriction when the selected candidate is clean")
	scene.players[0] = original_self
	scene.current_seat = 1
	scene.current_human_advice.clear()
	var changed_hand: Array = scene.players[1]["hand"].duplicate()
	changed_hand.erase("4W")
	var changed_report: Dictionary = scene.build_ai_discard_report(1, "4W", changed_hand, 0, visible, {}, context, scene.tile_counts(changed_hand), scene.tile_counts(scene.players[1]["hand"]))
	check(int(changed_report.get("shanten", 0)) > 0 and not changed_report.get("wait_discard_furiten", true) and changed_report.get("wait_self_discarded", []).is_empty(), "a different non-ready discard candidate cannot reuse another candidate's furiten metadata")
	var hidden_tile: String = scene.players[3]["hand"][0]
	var wall_tile: String = scene.wall[0]
	scene.players[3]["hand"][0] = wall_tile
	scene.wall[0] = hidden_tile
	scene.clear_ai_report_cache()
	var swapped_report: Dictionary = scene.build_ai_discard_report(1, "9T", simulated, 0, scene.visible_tile_counts_shared(), {}, scene.make_ai_evaluation_context(1), counts, scene.tile_counts(scene.players[1]["hand"]))
	check(scene.offline_tile_ledger_report().get("ok", false), "the wait-wide furiten hidden-information swap conserves every physical copy")
	check(original_report.get("wait_discard_furiten", false) == swapped_report.get("wait_discard_furiten", false) and original_report.get("wait_self_discarded", []) == swapped_report.get("wait_self_discarded", []) and is_equal_approx(float(original_report.get("wait_value", -1.0)), float(swapped_report.get("wait_value", -2.0))) and original_report.get("effective_remaining", {}) == swapped_report.get("effective_remaining", {}), "wait-wide furiten classification and valuation cannot inspect hidden opponents or wall order")


func run() -> void:
	print("=== ai_play_round300 check START ===")
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
	for quiet in [true, false]:
		for open_hand in [false, true]:
			for case_name in ["clean", "live", "dead"]:
				check_furiten_prediction(scene, case_name, quiet, open_hand)
		check_furiten_prediction(scene, "dead", quiet, false, true)
	check_structural_furiten_boundaries(scene)
	scene.shutdown_runtime()
	restore_smoke_state(scene, user_state)
	scene.queue_free()
	await process_frame
	print("=== RESULT: %s ===" % ("FAIL" if failed else "OK"))
	quit(1 if failed else 0)
