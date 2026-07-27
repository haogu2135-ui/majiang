extends SceneTree
## Round 39: stale prepared AI claims must not leave the discard resolver stuck.
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


func reset_resolver(scene) -> void:
	scene.players = [make_player("Source"), make_player("Actor"), make_player("P2"), make_player("P3")]
	scene.players[0]["discards"] = ["5W"]
	scene.mode = "offline"
	scene.offline_phase = "resolving"
	scene.offline_turn_needs_draw = false
	scene.current_seat = 0
	scene.last_discard = "5W"
	scene.last_discard_seat = 0
	scene.offline_pending_claim.clear()


func run() -> void:
	print("=== ai_play_round39 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.offline_sim_quiet = true
	scene.setup_tile_order()

	print("--- A) an invalid prepared claim advances as an uncontested discard ---")
	reset_resolver(scene)
	scene.players[1]["hand"] = ["5W"]
	scene.resolve_ai_or_advance(0, "5W", {"seat": 1, "claim": "peng"})
	check(scene.offline_phase == "await_discard" and scene.current_seat == 1 and scene.offline_turn_needs_draw, "失效预选响应不让状态停在 resolving")
	check(scene.players[0]["discards"] == ["5W"] and scene.players[1]["melds"].is_empty(), "失效响应不消费牌河或伪造副露")

	print("--- B) a valid prepared claim still applies exactly once ---")
	reset_resolver(scene)
	scene.players[1]["hand"] = ["5W", "5W", "1B"]
	scene.resolve_ai_or_advance(0, "5W", {"seat": 1, "claim": "peng"})
	check(scene.players[1]["melds"] == [["5W", "5W", "5W"]], "有效预选碰牌正常落地")
	check(scene.players[0]["discards"].is_empty() and scene.offline_phase == "await_discard" and scene.current_seat == 1 and not scene.offline_turn_needs_draw, "有效响应消费弃牌并给响应者出牌权")

	print("--- C) stale resolver input cannot move a later turn ---")
	reset_resolver(scene)
	scene.last_discard = "6W"
	scene.resolve_ai_or_advance(0, "5W", {})
	check(scene.offline_phase == "resolving" and scene.current_seat == 0 and scene.players[0]["discards"] == ["5W"], "陈旧解析调用保持当前状态")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
