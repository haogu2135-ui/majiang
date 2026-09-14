extends SceneTree
## Round 224: claim decisions reuse the candidate tile-index snapshot.

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
	print("=== ai_play_round224 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]

	var honor_index: int = scene.tile_index("E")
	var bonus_fallback: float = scene.ai_claim_meld_bonus(1, "peng", "E", {}, 1.0)
	var bonus_explicit: float = scene.ai_claim_meld_bonus(1, "peng", "E", {}, 1.0, honor_index)
	check(is_equal_approx(bonus_fallback, bonus_explicit), "claim meld bonus preserves its explicit tile-index result")

	var pressure_fallback: Dictionary = scene.ai_open_claim_pressure_report(1, "gang", "E", 3, 3, [], 1, {}, [], [])
	var pressure_explicit: Dictionary = scene.ai_open_claim_pressure_report(1, "gang", "E", 3, 3, [], 1, {}, [], [], honor_index)
	check(bool(pressure_fallback.get("decline", false)) == bool(pressure_explicit.get("decline", false)), "claim pressure preserves its explicit tile-index decision")
	check(is_equal_approx(float(pressure_fallback.get("risk", 0.0)), float(pressure_explicit.get("risk", 0.0))), "claim pressure preserves its explicit tile-index risk")
	check(is_equal_approx(scene.ai_claim_meld_bonus(1, "peng", "ZZ", {}, 1.0), 34.0), "claim meld bonus keeps invalid-tile fallback behavior")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
