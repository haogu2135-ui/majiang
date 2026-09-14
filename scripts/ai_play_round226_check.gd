extends SceneTree
## Round 226: added-gang public risk keeps one river lookup per opponent.

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
	print("=== ai_play_round226 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[1]["melds"] = [["5W", "5W", "5W"], ["6W", "6W", "6W"], ["7W", "7W", "7W"]]
	scene.players[1]["discards"] = ["1W", "2W", "3W", "8W", "9W", "E", "S", "W", "N", "P", "F", "C", "4W"]

	var discarded_report: Dictionary = scene.added_gang_rob_threat_report(0, "4W")
	var discarded_details: Array = discarded_report.get("risk_details", [])
	var discarded_seen := false
	for item in discarded_details:
		if int(item.get("seat", -1)) == 1:
			discarded_seen = true
			break
	check(not discarded_seen, "publicly discarded gang tiles remain excluded from chankan risk")
	check(discarded_report.has("risk_score") and discarded_report.has("risk_details"), "added-gang risk keeps its report structure")

	scene.ai_state_revision += 1
	scene.players[1]["discards"] = []
	var live_report: Dictionary = scene.added_gang_rob_threat_report(0, "4W")
	check(live_report.has("risk_score") and live_report.has("max_risk"), "live public risk keeps aggregate fields after river changes")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
