extends SceneTree
## Round 65: ron arbitration policy is explicit and single-winner.
var failed := false


func _initialize() -> void:
	call_deferred("run")


func check(cond: bool, msg: String) -> void:
	if cond:
		print("  OK  | %s" % msg)
	else:
		print("  FAIL| %s" % msg)
		failed = true


func make_player(name: String, bot: bool = true) -> Dictionary:
	return {
		"name": name,
		"hand": [],
		"discards": [],
		"melds": [],
		"flowers": 0,
		"flower_tiles": [],
		"score": 25000,
		"bot": bot,
	}


func tenpai_hand() -> Array:
	return ["1W", "1W", "1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "9W", "9W"]


func fill_wall(scene, count: int) -> void:
	var wall: Array[String] = []
	for i in range(count):
		wall.append("9B")
	scene.wall = wall


func reset_ron_table(scene) -> void:
	scene.players = [
		make_player("Human", false),
		make_player("Discarder", true),
		make_player("NearAI", true),
		make_player("FarAI", true),
	]
	scene.mode = "offline"
	scene.offline_phase = "resolving"
	scene.offline_turn_needs_draw = false
	scene.current_seat = 2
	scene.dealer_seat = 0
	scene.offline_hand_number = 1
	scene.offline_all_bot_mode = false
	scene.offline_sim_quiet = true
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	fill_wall(scene, 8)
	for seat in range(4):
		scene.players[seat]["melds"] = []
		scene.players[seat]["discards"] = []
		scene.players[seat]["score"] = 25000
	scene.players[0]["hand"] = tenpai_hand()
	scene.players[2]["hand"] = tenpai_hand()
	scene.players[3]["hand"] = tenpai_hand()
	scene.players[1]["discards"] = ["5W"]
	scene.last_discard = "5W"
	scene.last_discard_seat = 1
	scene.offline_last_winner = -1
	scene.last_win_score = {}
	scene.offline_pending_claim.clear()
	scene.clear_ai_report_cache()


func run() -> void:
	print("=== ai_play_round65 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.fast_mode_enabled = true
	scene.sfx_enabled = false
	scene.music_enabled = false
	scene.fx_enabled = false

	print("--- A) AI ron chooses nearest accepting seat ---")
	reset_ron_table(scene)
	var ai_claim = scene.choose_ai_claim(1, "5W")
	print("    ai_claim=%s seat=%s" % [str(ai_claim.get("claim", "")), str(ai_claim.get("seat", -1))])
	check(str(ai_claim.get("claim", "")) == "hu", "AI claim is ron")
	check(int(ai_claim.get("seat", -1)) == 2, "nearest AI ron wins AI arbitration")

	print("--- B) farther human hu window is preserved ---")
	var filtered = scene.filter_human_claim_options(["hu"], 1, ai_claim)
	check(filtered == ["hu"], "human hu remains visible even behind nearer AI hu")
	scene.resolve_after_discard(1, "5W")
	check(scene.offline_phase == "pending_claim", "human receives hu response window")
	check(scene.offline_pending_claim.get("options", []).has("hu"), "pending window includes hu")
	var prepared: Dictionary = scene.offline_pending_claim.get("ai_claim", {})
	check(str(prepared.get("claim", "")) == "hu" and int(prepared.get("seat", -1)) == 2, "pending window caches nearest AI ron")

	print("--- C) human submit wins single-winner settlement ---")
	scene.human_claim("hu")
	check(scene.offline_phase == "ended", "human ron ends the hand")
	check(scene.offline_last_winner == 0, "human submit records player as single winner")
	check(int(scene.last_win_score.get("winner", -1)) == 0 and int(scene.last_win_score.get("from_seat", -1)) == 1, "human ron score metadata is single-winner")

	print("--- D) human pass lets cached nearest AI win once ---")
	reset_ron_table(scene)
	scene.resolve_after_discard(1, "5W")
	check(scene.offline_phase == "pending_claim", "human gets second hu window before pass")
	scene.human_claim("pass")
	check(scene.offline_phase == "ended", "passing human hu resolves cached AI ron")
	check(scene.offline_last_winner == 2, "nearest AI becomes single winner after human pass")
	check(int(scene.last_win_score.get("winner", -1)) == 2 and int(scene.last_win_score.get("from_seat", -1)) == 1, "AI ron score metadata is single-winner")
	check(not bool(scene.last_win_score.get("multi_ron", false)), "settlement does not claim unsupported multi-ron")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
