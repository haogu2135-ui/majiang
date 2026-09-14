extends SceneTree
## Round 143: general threat-card ranking reuses its visible-count snapshot.

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
	print("=== ai_play_round143 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.players = [make_player("AI"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[0]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "3T", "5T", "E", "S"]
	scene.players[1]["discards"] = ["1W", "4W", "7W", "2T"]
	scene.players[2]["melds"] = [["5W", "5W", "5W"]]
	scene.players[3]["discards"] = ["9W", "9W", "E"]

	var visible_counts: Array = scene.visible_tile_counts_shared()
	var context: Dictionary = scene.make_ai_evaluation_context(0, visible_counts)
	var with_context: Array = scene.threat_safe_tile_labels(0, "suit", 0, 3, context)
	var without_context: Array = scene.threat_safe_tile_labels(0, "suit", 0, 3)

	print("--- A) general threat-card labels preserve the live result ---")
	print("    contextual=%s fallback=%s" % [with_context, without_context])
	check(with_context == without_context, "通用威胁卡显式快照保持标签和排序一致")
	check(scene.threat_safe_tile_labels(0, "suit", 0, 0, context).is_empty(), "通用威胁卡仍尊重空 Top-K 限制")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
