extends SceneTree
## Round 287: declining ron must not suppress independent legal meld claims.

class RonPassClaimProbe:
	extends "res://scripts/main.gd"
	var evaluated_claims: Array[String] = []

	func ai_ron_decision_report(seat: int, tile: String, win_context: String = "", hand_counts_snapshot: Array = [], claim_options_validated: bool = false) -> Dictionary:
		return {"accept": false, "reason": "留听", "score": 0.0}

	func build_ai_claim_report(seat: int, claim: String, tile: String, chi_choice: Dictionary = {}, claim_context: Dictionary = {}) -> Dictionary:
		evaluated_claims.append(claim)
		return {"allow": true, "claim": claim, "seat": seat, "before_shanten": 1, "after_shanten": 1, "shape_gain": 0.0, "forced_discard_risk": 0.0, "ai_attack_multiplier": 1.0, "ai_claim_aggression": 1.0, "ai_risk_factor": 1.0, "ai_route_focus": 1.0}

	func ai_claim_action_score(report: Dictionary, offset: int) -> float:
		return 10.0 - float(offset)

var failed := false


func _initialize() -> void:
	call_deferred("run")


func check(condition: bool, message: String) -> void:
	if condition:
		print("  OK  | %s" % message)
	else:
		print("  FAIL| %s" % message)
		failed = true


func make_player(name: String, hand: Array, bot: bool) -> Dictionary:
	return {
		"name": name,
		"hand": hand,
		"discards": [],
		"melds": [],
		"flowers": 0,
		"flower_tiles": [],
		"score": 25000,
		"bot": bot,
	}


func run() -> void:
	print("=== ai_play_round287 check START ===")
	var scene = RonPassClaimProbe.new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.offline_phase = "resolving"
	scene.offline_all_bot_mode = false
	scene.offline_passed_win_tiles.clear()
	scene.players = [
		make_player("Human", [], false),
		make_player("AI", ["5W", "5W", "1W", "1W", "1W", "2W", "3W", "4W", "6W", "7W", "8W", "9W", "9W"], true),
		make_player("Other 2", [], true),
		make_player("Other 3", [], true),
	]
	scene.last_discard = "5W"
	scene.last_discard_seat = 0

	var options: Array = scene.get_claim_options(1, 0, "5W")
	check(options.has("hu") and options.has("peng"), "fixture exposes both a legal ron and a lower-priority peng")
	var selected: Dictionary = scene.choose_ai_claim(0, "5W")
	check(scene.is_passed_win_tile(1, "5W"), "declining ron still records temporary passed-win state")
	check(scene.evaluated_claims.has("peng"), "AI evaluates the legal peng after declining ron")
	check(int(selected.get("seat", -1)) == 1 and str(selected.get("claim", "")) == "peng", "AI may select the approved lower-priority claim")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
