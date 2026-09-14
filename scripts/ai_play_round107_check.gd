extends SceneTree
## Round 107: claim selection reuses its already-validated ron option.

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
	print("=== ai_play_round107 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.offline_phase = "resolving"
	scene.players = [make_player("P0"), make_player("AI"), make_player("P2"), make_player("P3")]
	scene.dealer_seat = 0
	var complete: Array = ["1W", "1W", "1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "9W", "9W", "5W"]
	var waiting: Array = complete.duplicate()
	waiting.erase("5W")
	scene.players[1]["hand"] = waiting
	scene.players[1]["discards"] = []
	scene.last_discard = "5W"
	scene.last_discard_seat = 0
	var hand_counts: Array = scene.tile_counts(waiting)
	var counts_key: String = scene.counts_compact_key(hand_counts)

	print("--- A) claim options prove the ron win before reporting ---")
	var options: Array = scene.get_claim_options(1, 0, "5W", hand_counts)
	check(options.has("hu"), "claim options expose the legal ron")

	print("--- B) prevalidated and legacy reports remain equivalent ---")
	var legacy_report: Dictionary = scene.ai_ron_decision_report(1, "5W", "", hand_counts)
	var reused_report: Dictionary = scene.ai_ron_decision_report(1, "5W", "", hand_counts, true)
	check(legacy_report == reused_report, "prevalidated ron report preserves all decision fields")
	check(scene.counts_compact_key(hand_counts) == counts_key, "report reuse preserves the source count vector")

	print("--- C) chooser uses the reused report path ---")
	var claim: Dictionary = scene.choose_ai_claim(0, "5W")
	check(str(claim.get("claim", "")) == "hu" and int(claim.get("seat", -1)) == 1, "claim chooser still selects the legal ron")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
