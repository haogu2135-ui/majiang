extends SceneTree
## Round 145: feed-risk scoring reuses its visible-count snapshot.

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
	print("=== ai_play_round145 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.players = [make_player("P0"), make_player("AI"), make_player("P2"), make_player("P3")]
	scene.players[1]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "3T", "5T", "E", "S"]
	scene.players[2]["melds"] = [["1W", "2W", "3W"], ["7W", "8W", "9W"]]
	scene.players[2]["discards"] = ["1T", "2T", "3T", "4T", "5T", "6T"]

	var visible_counts: Array = scene.visible_tile_counts_shared()
	var context: Dictionary = scene.make_ai_evaluation_context(1, visible_counts)
	var explicit_report: Dictionary = scene.discard_feed_risk_report("5W", 1, visible_counts, context)
	var legacy_report: Dictionary = scene.discard_feed_risk_report("5W", 1, [], context)

	print("--- A) explicit snapshot preserves the legacy feed report ---")
	print("    explicit=%.1f legacy=%.1f" % [float(explicit_report.get("score", 0.0)), float(legacy_report.get("score", 0.0))])
	check(explicit_report == legacy_report, "显式可见牌快照保持喂牌报告一致")
	var explicit_details: Array = explicit_report.get("details", [])
	var legacy_details: Array = legacy_report.get("details", [])
	check(explicit_report.has("details") and explicit_details.size() == legacy_details.size(), "喂牌报告继续提供结构化详情")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
