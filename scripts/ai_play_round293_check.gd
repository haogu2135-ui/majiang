extends SceneTree

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
	print("=== ai_play_round293 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.offline_phase = "await_discard"
	scene.current_seat = 0
	scene.offline_turn_needs_draw = false
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	scene.players = [make_player("Actor"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.wall = scene.make_wall()
	scene.players[1]["melds"] = [["1B", "2B", "3B"]]
	scene.players[2]["melds"] = [["4B", "5B", "6B"]]
	scene.players[3]["melds"] = [["7B", "8B", "9B"]]
	for opponent in range(1, 4):
		scene.players[opponent]["discards"] = ["1T", "2T", "3T", "4T", "5T", "6T"]
	for honor in scene.WIND_CODES + scene.DRAGON_CODES:
		scene.players[0]["hand"] = [honor]
		scene.players[0]["discards"] = [honor, honor, honor]
		var public_counts: Array = scene.visible_tile_counts_shared()
		var context: Dictionary = scene.make_ai_evaluation_context(0, public_counts)
		var known_counts: Array = scene.ai_context_known_counts(context, 0, public_counts)
		var index: int = scene.tile_index(honor)
		check(int(public_counts[index]) == 3 and int(known_counts[index]) == 4, "%s separates public and self-known copies" % honor)
		var vector: Dictionary = scene.tile_risk_vector(honor, 0, public_counts, context, index)
		check(is_zero_approx(float(vector.get("score", -1.0))) and vector.get("danger_source", {}).is_empty(), "%s cannot deal into an opponent with a meld when all copies are known" % honor)
		for opponent in range(1, 4):
			var components: Dictionary = scene.single_opponent_deal_in_risk_components(honor, 0, opponent, -1, known_counts, context, index)
			check(is_zero_approx(float(components.get("risk", -1.0))), "%s direct risk excludes opponent %d" % [honor, opponent])
		var feed: Dictionary = scene.discard_feed_risk_report(honor, 0, public_counts, context, index)
		check(is_zero_approx(float(feed.get("score", -1.0))), "%s cannot feed a meld when all copies are known" % honor)

	scene.players[0]["hand"] = ["E"]
	scene.players[0]["discards"] = ["E", "E"]
	var three_context: Dictionary = scene.make_ai_evaluation_context(0)
	check(float(scene.tile_risk_vector("E", 0, [], three_context).get("score", 0.0)) > 0.0, "three known honors retain possible single-pair waits")
	scene.players[0]["discards"].append("E")
	scene.players[1]["melds"] = [["Z", "Z", "Z"]]
	var honor_context: Dictionary = scene.make_ai_evaluation_context(0)
	var exhausted_vector: Dictionary = scene.tile_risk_vector("E", 0, [], honor_context)
	check(is_zero_approx(float(exhausted_vector.get("threat", -1.0))), "honor-pattern bonuses cannot revive an impossible ron")
	check(is_zero_approx(scene.opponent_tile_threat_score("E", 0, [], {}, honor_context)), "standalone and batched pattern threats agree on exhausted honors")
	var old_vector: Dictionary = exhausted_vector.duplicate(true)
	scene.players[1]["hand"] = ["N", "N", "N", "R", "R", "R", "F", "F", "F", "P"]
	var hidden_context: Dictionary = scene.make_ai_evaluation_context(0)
	check(scene.tile_risk_vector("E", 0, [], hidden_context) == old_vector, "concealed opponent tiles do not affect exhausted-honor decisions")

	scene.players[1]["melds"].clear()
	scene.players[1]["hand"] = scene.THIRTEEN_ORPHANS_CODES.duplicate()
	scene.players[1]["hand"].erase("E")
	scene.players[1]["hand"].append("1W")
	var orphan_context: Dictionary = scene.make_ai_evaluation_context(0)
	var orphan_vector: Dictionary = scene.tile_risk_vector("E", 0, [], orphan_context)
	check(scene.can_win_for_seat(1, "E"), "a closed thirteen-orphans hand can win on the fourth honor")
	check(float(orphan_vector.get("opponent_risks", {}).get(1, 0.0)) > 0.0, "closed opponents retain thirteen-orphans risk")
	check(scene.tile_risk_vector("E", 0, [], honor_context) == old_vector, "an existing evaluation keeps its captured opponent-meld state")
	check(str(scene.tile_safety_label("E", 0, [], orphan_context)) != "安", "the UI never promises all-table safety against closed thirteen orphans")
	for opponent in range(2, 4):
		check(is_zero_approx(float(orphan_vector.get("opponent_risks", {}).get(opponent, -1.0))), "only the closed opponent retains exhausted-honor risk")
	scene.players[1]["hand"] = ["2W", "3W", "4W", "5W", "6W", "7W", "2T", "3T", "4T", "5T", "6T", "7T", "8T"]
	var closed_hidden_context: Dictionary = scene.make_ai_evaluation_context(0)
	check(scene.tile_risk_vector("E", 0, [], closed_hidden_context) == orphan_vector, "the AI cannot inspect whether a closed opponent actually holds thirteen orphans")
	scene.players[1]["discards"].append("E")
	var furiten_context: Dictionary = scene.make_ai_evaluation_context(0)
	check(is_zero_approx(float(scene.tile_risk_vector("E", 0, [], furiten_context).get("score", -1.0))), "public furiten still overrides the residual thirteen-orphans estimate")
	scene.players[1]["discards"].pop_back()

	scene.players[1]["melds"] = [["Z", "Z", "Z", "Z"]]
	scene.offline_concealed_gang_tiles = {1: {"Z": true}}
	var gang_context: Dictionary = scene.make_ai_evaluation_context(0)
	check(is_zero_approx(float(scene.tile_risk_vector("E", 0, [], gang_context).get("score", -1.0))), "a concealed gang also excludes thirteen orphans")

	scene.players[0]["hand"] = ["5W"]
	scene.players[0]["discards"] = ["5W", "5W", "5W"]
	scene.players[1]["melds"] = [["1B", "2B", "3B"]]
	scene.offline_concealed_gang_tiles.clear()
	scene.players[1]["hand"] = ["1T", "2T", "3T", "7T", "8T", "9T", "4W", "6W", "Z", "Z"]
	var number_context: Dictionary = scene.make_ai_evaluation_context(0)
	check(scene.can_win_for_seat(1, "5W"), "a numbered tile can complete a sequence without another copy in the opponent hand")
	check(float(scene.tile_risk_vector("5W", 0, [], number_context).get("score", 0.0)) > 0.0, "four known numbered tiles are not treated as honor safety")

	scene.players[0]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "1T", "2T", "3T", "7T", "8T", "E", "N", "R"]
	scene.players[0]["discards"] = ["E", "E", "E"]
	scene.offline_sim_quiet = false
	var found_honor_report := false
	for report in scene.get_ai_discard_reports(0):
		if str(report.get("tile", "")) == "E":
			found_honor_report = true
			check(is_zero_approx(float(report.get("risk", -1.0))) and is_zero_approx(float(report.get("threat", -1.0))), "full discard evaluation consumes the corrected honor risk")
	check(found_honor_report, "full evaluation includes the exhausted-honor discard candidate")
	scene.players[0]["hand"] = ["E"]
	scene.players[0]["discards"].clear()
	scene.players[0]["melds"] = [["E", "E", "E"]]
	var exhausted_gang_report: Dictionary = scene.added_gang_rob_threat_report(0, "E")
	check(is_zero_approx(float(exhausted_gang_report.get("risk_score", -1.0))), "added-gang risk also counts the declarer's known fourth honor")
	scene.players[0]["hand"].clear()
	var public_only_gang_report: Dictionary = scene.added_gang_rob_threat_report(0, "E")
	check(float(public_only_gang_report.get("risk_score", 0.0)) > 0.0, "added-gang memo invalidates when the declarer's own known copies change")

	scene.queue_free()
	await process_frame
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
