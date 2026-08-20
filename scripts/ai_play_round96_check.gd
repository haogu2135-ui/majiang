extends SceneTree
## Round 96: defensive visibility includes the acting AI's own concealed tiles.
var failed := false


func _initialize() -> void:
	call_deferred("run")


func check(cond: bool, msg: String) -> void:
	if cond:
		print("  OK  | %s" % msg)
	else:
		print("  FAIL| %s" % msg)
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


func has_claim(details: Array, claim: String) -> bool:
	for item in details:
		if typeof(item) == TYPE_DICTIONARY and str(item.get("claim", "")) == claim:
			return true
	return false


func run() -> void:
	print("=== ai_play_round96 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.current_seat = 1
	scene.offline_turn_needs_draw = false
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	scene.players = [
		make_player("P0"),
		make_player("Actor"),
		make_player("P2"),
		make_player("P3"),
	]
	scene.wall = scene.make_wall()
	scene.players[0]["discards"] = ["1T", "2T", "3T", "4T", "5T", "7T"]
	scene.players[1]["hand"] = [
		"3W", "4W", "4W", "4W", "5W", "5W", "5W",
		"1T", "2T", "3T", "7B", "8B", "9B", "E",
	]

	print("--- A) evaluation context separates public and self-known counts ---")
	var public_counts = scene.visible_tile_counts()
	var context = scene.make_ai_evaluation_context(1, public_counts)
	var four_index = scene.tile_index("4W")
	check(int(public_counts[four_index]) == 0, "public table count excludes concealed 4W")
	check(scene.has_method("ai_context_known_counts"), "AI exposes a self-known count snapshot")
	if scene.has_method("ai_context_known_counts"):
		var known_counts: Array = scene.ai_context_known_counts(context, 1, public_counts)
		check(int(known_counts[four_index]) == 3, "self-known snapshot includes the actor's three concealed 4W")

	print("--- B) concealed triplet can create a defensive wall ---")
	var safety = scene.tile_safety_label("3W", 1, public_counts, context)
	check(safety == "壁", "three self-known adjacent 4W mark 3W as a wall-supported discard")

	print("--- C) a concealed triplet cannot feed an opponent peng ---")
	var feed = scene.discard_feed_risk_report("5W", 1, public_counts, context)
	var feed_details: Array = feed.get("details", [])
	check(not has_claim(feed_details, "peng"), "three self-known 5W remove impossible peng feed warnings")

	print("--- D) self-known scarcity lowers deal-in risk without reading opponents ---")
	var triple_risk = float(scene.tile_risk_vector("5W", 1, public_counts, context).get("score", 0.0))
	scene.players[1]["hand"] = [
		"3W", "4W", "4W", "4W", "5W", "6W", "7W",
		"1T", "2T", "3T", "7B", "8B", "9B", "E",
	]
	var single_context = scene.make_ai_evaluation_context(1, public_counts)
	var single_risk = float(scene.tile_risk_vector("5W", 1, public_counts, single_context).get("score", 0.0))
	print("    risk with one known 5W=%.2f, with three known 5W=%.2f" % [single_risk, triple_risk])
	check(triple_risk < single_risk, "more self-known copies reduce estimated opponent wait risk")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
