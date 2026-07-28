extends SceneTree
## Round 74: every quiet commercial benchmark hand keeps the full 144-tile ledger intact.
var failed := false


func _initialize() -> void:
	call_deferred("run")


func check(cond: bool, msg: String) -> void:
	if cond:
		print("  OK  | %s" % msg)
	else:
		print("  FAIL| %s" % msg)
		failed = true


func run() -> void:
	print("=== ai_play_round74 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.fast_mode_enabled = true
	scene.sfx_enabled = false
	scene.music_enabled = false
	scene.fx_enabled = false

	print("--- A) direct ledger detects loss, duplication, and invalid tile codes ---")
	scene.ensure_ai_benchmark_players()
	scene.enable_offline_all_bot_mode(true, true)
	scene.mode = "offline"
	scene.offline_hand_number = 1
	scene.dealer_seat = 0
	seed(20260774)
	scene.offline_skip_ai_profile_reshuffle = true
	scene.deal_offline_hand()
	var clean = scene.offline_tile_ledger_report()
	print("    clean expected=%d actual=%d" % [int(clean.get("expected_total", 0)), int(clean.get("actual_total", 0))])
	check(bool(clean.get("ok", false)), "fresh dealt hand preserves all 144 physical tiles")
	check(int(clean.get("expected_total", 0)) == 144 and int(clean.get("actual_total", 0)) == 144, "ledger reports the complete local tile set")

	scene.players[0]["hand"].append("1W")
	var duplicated = scene.offline_tile_ledger_report()
	check(not bool(duplicated.get("ok", true)) and not (duplicated.get("overflow", []) as Array).is_empty(), "ledger rejects duplicated tile")
	scene.players[0]["hand"].pop_back()

	var saved_wall_tile = str(scene.wall[0])
	scene.wall[0] = "X9"
	var unknown = scene.offline_tile_ledger_report()
	check(not bool(unknown.get("ok", true)) and not (unknown.get("unknown", []) as Array).is_empty(), "ledger rejects unknown tile code")
	scene.wall[0] = saved_wall_tile

	print("--- B) paired AI sample carries integrity through every decision difficulty ---")
	var raw = scene.sample_bot_strength_across_difficulties(1, 20260774, false, [scene.AI_DIFFICULTY_EASY, scene.AI_DIFFICULTY_NORMAL, scene.AI_DIFFICULTY_HARD])
	var by_diff: Dictionary = raw.get("by_diff", {})
	for diff in [scene.AI_DIFFICULTY_EASY, scene.AI_DIFFICULTY_NORMAL, scene.AI_DIFFICULTY_HARD]:
		var row: Dictionary = by_diff.get(diff, {})
		print("    diff=%d ended=%d integrity=%s discards=%d" % [
			diff,
			int(row.get("ended", 0)),
			str(row.get("integrity_ok", false)),
			int(row.get("discards", 0)),
		])
		check(int(row.get("ended", 0)) == 1, "difficulty %d finishes its seeded hand" % diff)
		check(int(row.get("integrity_passed", 0)) == 1 and bool(row.get("integrity_ok", false)), "difficulty %d preserves the tile ledger" % diff)

	var bench = scene.sample_ai_strength_benchmark(1, 20260774, false, false)
	print("    benchmark integrity e/h=%s/%s aggregate=%s" % [
		str(bench.get("easy_integrity", false)),
		str(bench.get("hard_integrity", false)),
		str(bench.get("integrity_all", false)),
	])
	check(bool(bench.get("integrity_all", false)), "commercial strength result requires easy and hard ledger integrity")

	scene.enable_offline_all_bot_mode(false, false)
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
