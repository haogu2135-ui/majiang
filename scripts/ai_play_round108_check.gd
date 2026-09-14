extends SceneTree
## Round 108: tenpai effective-tile probes do not repeat shanten searches.

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
	print("=== ai_play_round108 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]

	print("--- A) standard tenpai only probes exact completion ---")
	var standard_tenpai: Array = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "2T", "3T", "E"]
	var standard_counts: Array = scene.tile_counts(standard_tenpai)
	scene.clear_ai_report_cache()
	var standard_metrics: Dictionary = scene.effective_tile_metrics(standard_tenpai, 0, 1, 0, [], standard_counts)
	check(standard_metrics.get("tiles", []).has("E"), "standard tenpai still exposes the winning tile")
	check(scene.shanten_cache_hits == 0 and scene.shanten_cache_misses == 0, "standard tenpai skips redundant shanten searches")

	print("--- B) alternate tenpai families remain exact ---")
	var seven_pairs_tenpai: Array = ["1W", "1W", "2W", "2W", "3W", "3W", "4W", "4W", "5T", "5T", "6T", "6T", "E"]
	var seven_pairs_counts: Array = scene.tile_counts(seven_pairs_tenpai)
	scene.clear_ai_report_cache()
	var seven_pairs_metrics: Dictionary = scene.effective_tile_metrics(seven_pairs_tenpai, 0, 1, 0, [], seven_pairs_counts)
	check(seven_pairs_metrics.get("tiles", []).has("E"), "seven-pairs tenpai still uses the alternate completion check")
	check(scene.shanten_cache_hits == 0 and scene.shanten_cache_misses == 0, "alternate tenpai also avoids shanten fallback searches")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
