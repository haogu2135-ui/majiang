extends SceneTree
## Round 149: feed risk reuses the next seat's discard-count lookup.

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
	print("=== ai_play_round149 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[1]["discards"] = ["1W", "2W", "3W"]
	scene.players[2]["discards"] = ["5W", "4W", "6W"]
	scene.players[3]["discards"] = ["9B"]

	var visible_counts: Array = scene.visible_tile_counts_shared()
	var context: Dictionary = scene.make_ai_evaluation_context(0, visible_counts)
	var legacy_context: Dictionary = scene.make_ai_evaluation_context(0, visible_counts)
	var report: Dictionary = scene.discard_feed_risk_report("5W", 0, visible_counts, context)
	var legacy_report: Dictionary = scene.discard_feed_risk_report("5W", 0, [], legacy_context)

	print("--- A) feed-risk report preserves one-count opponent scoring ---")
	var details: Array = report.get("details", [])
	print("    score=%.1f chi=%.1f details=%d" % [float(report.get("score", 0.0)), float(report.get("next_seat_chi_score", 0.0)), details.size()])
	check(report == legacy_report, "显式可见牌快照与实时回退保持喂牌报告")
	check(float(report.get("next_seat_chi_score", 0.0)) > 0.0 and not details.is_empty(), "下家吃风险与对手碰详情仍被完整计算")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
