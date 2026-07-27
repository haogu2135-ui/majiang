extends SceneTree
## Round 31: claim application is the authoritative state-machine boundary.
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


func reset_claim(scene) -> void:
	scene.players = [make_player("Source"), make_player("Next"), make_player("Third"), make_player("Fourth")]
	scene.mode = "offline"
	scene.offline_phase = "resolving"
	scene.offline_pending_claim.clear()
	scene.offline_turn_needs_draw = false
	scene.last_discard = "5W"
	scene.last_discard_seat = 0
	scene.players[0]["discards"] = ["5W"]


func run() -> void:
	print("=== ai_play_round31 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.offline_sim_quiet = true
	scene.setup_tile_order()

	print("--- A) invalid seats and stale state expose no options ---")
	reset_claim(scene)
	check(scene.get_claim_options(-1, 0, "5W").is_empty() and scene.get_claim_options(1, -1, "5W").is_empty(), "非法座位不生成响应选项")
	scene.players[1]["hand"] = ["4W", "6W"]
	scene.last_discard_seat = 2
	check(not scene.is_valid_offline_claim(1, 0, "5W", "chi"), "过期弃牌不能进入副露状态机")
	var before_hand = scene.players[1]["hand"].duplicate()
	scene.apply_offline_claim(1, 0, "5W", "chi")
	check(scene.players[1]["hand"] == before_hand and scene.players[0]["discards"] == ["5W"], "过期响应不修改手牌或牌河")

	print("--- B) forged chi composition is rejected ---")
	reset_claim(scene)
	scene.players[1]["hand"] = ["1W", "1W", "4W", "6W"]
	var forged = {"needed": ["1W", "1W"], "meld": ["1W", "1W", "5W"]}
	check(not scene.is_valid_offline_claim(1, 0, "5W", "chi", forged), "伪造吃法不通过合法性校验")
	before_hand = scene.players[1]["hand"].duplicate()
	scene.apply_offline_claim(1, 0, "5W", "chi", forged)
	check(scene.players[1]["hand"] == before_hand and scene.players[1]["melds"].is_empty(), "伪造吃法不消耗无关牌")

	print("--- C) legal chi still applies exactly once ---")
	reset_claim(scene)
	scene.players[1]["hand"] = ["4W", "6W", "E"]
	var choices = scene.get_chi_choices(scene.players[1]["hand"], "5W")
	check(choices.size() == 1 and scene.is_valid_offline_claim(1, 0, "5W", "chi", choices[0]), "真实吃法通过状态机校验")
	scene.apply_offline_claim(1, 0, "5W", "chi", choices[0])
	check(scene.players[0]["discards"].is_empty() and scene.players[1]["hand"] == ["E"], "合法吃牌取走弃牌和两张所需牌")
	check(scene.players[1]["melds"] == [["4W", "5W", "6W"]] and scene.current_seat == 1 and scene.offline_phase == "await_discard", "合法吃牌进入正确出牌状态")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
