extends SceneTree
## Round 103: claim selection reuses the hand count snapshot for ron reports.

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
	print("=== ai_play_round103 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.offline_phase = "resolving"
	scene.players = [make_player("P0"), make_player("AI"), make_player("P2"), make_player("P3")]
	var waiting_hand: Array = ["1W", "1W", "1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "9W", "9W"]
	scene.players[1]["hand"] = waiting_hand.duplicate()
	var hand_counts: Array = scene.tile_counts(waiting_hand)
	var counts_key: String = scene.counts_compact_key(hand_counts)

	print("--- A) direct report equivalence ---")
	var array_report: Dictionary = scene.ai_ron_decision_report(1, "5W")
	var snapshot_report: Dictionary = scene.ai_ron_decision_report(1, "5W", "", hand_counts)
	check(array_report == snapshot_report, "snapshot ron report matches the legacy report")
	check(scene.counts_compact_key(hand_counts) == counts_key, "ron report restores the caller count vector")

	print("--- B) claim selection still accepts the legal ron ---")
	scene.last_discard = "5W"
	scene.last_discard_seat = 0
	var claim: Dictionary = scene.choose_ai_claim(0, "5W")
	check(str(claim.get("claim", "")) == "hu" and int(claim.get("seat", -1)) == 1, "claim chooser keeps the shared-snapshot ron path")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
