extends SceneTree
## Round 219: feed-risk scoring reuses one candidate tile-index snapshot.

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
	print("=== ai_play_round219 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_sim_quiet = true
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[1]["melds"] = [["5W", "5W", "5W"]]
	var visible_counts: Array = scene.make_empty_tile_counts()
	var tile_index: int = scene.tile_index("5W")

	var chi_fallback: float = scene.chi_feed_risk_score("5W", 0, 1, 0)
	var chi_explicit: float = scene.chi_feed_risk_score("5W", 0, 1, 0, {}, -1, tile_index)
	check(is_equal_approx(chi_fallback, chi_explicit), "chi feed risk preserves the no-argument tile-index fallback")
	var chi_alias: float = scene.chi_feed_risk_score("5M", 0, 1, 0, {}, -1, tile_index)
	check(is_equal_approx(chi_explicit, chi_alias), "chi feed risk preserves normalized aliases with an explicit index")

	var meld_fallback: float = scene.meld_feed_risk_score("5W", 0, 1, 0)
	var meld_explicit: float = scene.meld_feed_risk_score("5W", 0, 1, 0, {}, -1, tile_index)
	check(is_equal_approx(meld_fallback, meld_explicit), "meld feed risk preserves the no-argument tile-index fallback")
	var meld_alias: float = scene.meld_feed_risk_score("5M", 0, 1, 0, {}, -1, tile_index)
	check(is_equal_approx(meld_explicit, meld_alias), "meld feed risk preserves normalized aliases with an explicit index")

	var invalid_index: int = scene.tile_index("ZZ")
	check(scene.chi_feed_risk_score("ZZ", 0, 1, 0, {}, -1, invalid_index) == scene.chi_feed_risk_score("ZZ", 0, 1, 0), "invalid chi tiles keep their bounded zero result")
	check(scene.meld_feed_risk_score("ZZ", 0, 1, 0, {}, -1, invalid_index) == scene.meld_feed_risk_score("ZZ", 0, 1, 0), "invalid meld tiles keep their fallback result")

	var feed_report: Dictionary = scene.discard_feed_risk_report("5W", 0, visible_counts)
	check(feed_report.has("score") and feed_report.has("details"), "aggregate feed risk still returns its report structure")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
