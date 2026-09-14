extends SceneTree
## Round 240: discard safety labels reuse the candidate tile index.

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
	print("=== ai_play_round240 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[1]["discards"] = ["1W", "7W"]
	var visible_counts_240: Array = scene.make_empty_tile_counts()
	visible_counts_240[scene.tile_index("4W")] = 2
	var context_240: Dictionary = scene.make_ai_evaluation_context(0, visible_counts_240)
	var index_240: int = scene.tile_index("4W")
	var fallback_label_240: String = scene.tile_safety_label("4W", 0, visible_counts_240, context_240)
	var snapshot_label_240: String = scene.tile_safety_label("4M", 0, visible_counts_240, context_240, index_240)
	check(snapshot_label_240 == fallback_label_240, "explicit safety-label index preserves normalized aliases")
	check(scene.is_suji_safe_tile("4M", 0, context_240, index_240) == scene.is_suji_safe_tile("4W", 0, context_240), "suji safety consumes the explicit tile index")
	check(scene.is_kabe_safe_tile("4M", 0, visible_counts_240, context_240, index_240) == scene.is_kabe_safe_tile("4W", 0, visible_counts_240, context_240), "kabe safety retains the explicit tile index")

	var fast_counts_240: Array = scene.tile_counts(["4W", "1W", "2W", "3W"])
	var fast_pressure_240: Dictionary = scene.ai_pressure_context(0, context_240)
	var fast_fallback_240: Dictionary = scene.build_ai_fast_post_claim_discard_report(0, "4W", 0, fast_pressure_240, context_240, fast_counts_240, visible_counts_240)
	var fast_snapshot_240: Dictionary = scene.build_ai_fast_post_claim_discard_report(0, "4M", 0, fast_pressure_240, context_240, fast_counts_240, visible_counts_240, index_240)
	check(str(fast_snapshot_240.get("safety_label", "")) == str(fast_fallback_240.get("safety_label", "")), "fast post-claim safety preserves the explicit tile-index result")
	check(is_equal_approx(float(fast_snapshot_240.get("score", 0.0)), float(fast_fallback_240.get("score", 0.0))), "fast post-claim report preserves the explicit tile-index score")
	var invalid_label_240: String = scene.tile_safety_label("ZZ", 0, visible_counts_240, context_240, -1)
	check(invalid_label_240 == scene.tile_safety_label("ZZ", 0, visible_counts_240, context_240), "invalid safety tiles keep the legacy fallback")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
