extends SceneTree
## Round 146: human-claim discipline reuses one wall-count snapshot.

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
	print("=== ai_play_round146 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.players = [make_player("P0"), make_player("AI"), make_player("P2"), make_player("P3")]
	scene.wall = scene.make_wall()
	scene.players[0]["melds"] = [["E", "E", "E"]]
	scene.players[0]["discards"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T"]

	var wall_count: int = scene.get_wall_count()
	var context: Dictionary = scene.make_ai_evaluation_context(1, scene.visible_tile_counts_shared())
	var context_wall: int = int(context.get("discard_report_wall_count", -1))
	var live_readiness: float = scene.human_readiness_for_defense()
	var snapshot_readiness: float = scene.human_readiness_for_defense(wall_count)
	var context_readiness: float = scene.human_readiness_for_defense(context_wall)

	print("--- A) wall snapshots preserve human readiness ---")
	print("    live=%.1f explicit=%.1f context=%.1f" % [live_readiness, snapshot_readiness, context_readiness])
	check(is_equal_approx(live_readiness, snapshot_readiness) and is_equal_approx(live_readiness, context_readiness), "显式与上下文牌墙快照保持玩家准备度一致")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
