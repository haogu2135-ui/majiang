extends SceneTree


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.offline_sim_quiet = true
	scene.setup_tile_order()
	scene.players = []
	for i in range(4):
		scene.players.append({
			"name": "P%d" % i,
			"hand": [],
			"discards": [],
			"melds": [],
			"flowers": 0,
			"flower_tiles": [],
			"score": 25000,
			"bot": i != 0,
		})
	scene.mode = "offline"
	scene.offline_phase = "resolving"
	scene.current_seat = 0
	scene.dealer_seat = 0
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	scene.wall.clear()
	for i in range(48):
		scene.wall.append("2B")
	scene.players[3]["hand"] = ["2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "9W", "9W", "2T", "3T", "4T"]
	scene.last_discard = "2W"
	scene.last_discard_seat = 0
	scene.players[0]["discards"] = ["2W"]
	var decision = scene.ai_ron_decision_report(3, "2W")
	print("decision=", decision)
	var low_counts = scene.tile_counts(scene.players[3]["hand"] + ["2W"])
	var high_counts = scene.tile_counts(scene.players[3]["hand"] + ["1W"])
	print("low_score=", scene.calculate_win_score_from_tiles(3, scene.players[3]["hand"] + ["2W"], false))
	print("high_score=", scene.calculate_win_score_from_tiles(3, scene.players[3]["hand"] + ["1W"], false))
	print("low_dragon=", scene.full_straight_suit_from_counts(3, low_counts))
	print("high_dragon=", scene.full_straight_suit_from_counts(3, high_counts))
	var snapshot_high = scene.calculate_win_score_from_tiles(3, [], false, "", true, high_counts, 14, high_counts)
	print("snapshot_high=", snapshot_high)
	var counts = scene.tile_counts(scene.players[3]["hand"])
	var metrics = scene.effective_tile_metrics(scene.players[3]["hand"], 0, 3, 0, scene.visible_tile_counts_shared(), counts)
	print("metrics=", metrics)
	var wait_values = scene.wait_value_metrics(3, scene.players[3]["hand"], 0, 0, metrics.get("tiles", []), metrics.get("remaining_by_tile", {}), true, {}, -1.0, -1.0, counts, -1, metrics.get("tile_indices", {}))
	print("wait_values=", wait_values)
	print("pressure=", scene.ai_pressure_context(3))
	print("profile=", scene.ai_profile_source(3))
	print("wait_focus=", scene.ai_wait_value_focus(3))
	print("attack=", scene.ai_total_attack_multiplier(3))
	print("strategy=", scene.score_context_report_cached(3))
	scene.queue_free()
	quit(0)
