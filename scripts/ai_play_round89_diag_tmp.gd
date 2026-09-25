extends SceneTree

func _initialize() -> void:
	call_deferred("run")


func simulate_hand(scene, wall_seed: int, hand_index: int, difficulty: int) -> Dictionary:
	scene.ai_difficulty = difficulty
	scene.ai_benchmark_base_difficulty = difficulty
	scene.ai_benchmark_probe_seat = 0
	scene.ai_benchmark_probe_difficulty = scene.AI_DIFFICULTY_NORMAL
	scene.enable_offline_all_bot_mode(true, true)
	scene.reset_ai_profile_seat_map()
	seed(wall_seed)
	scene.offline_skip_ai_profile_reshuffle = true
	scene.mode = "offline"
	scene.offline_hand_number = 1
	scene.dealer_seat = hand_index % 4
	for seat in range(4):
		scene.players[seat]["score"] = scene.MATCH_START_SCORE
	scene.deal_offline_hand()
	scene.reset_ai_profile_seat_map()
	return scene.simulate_offline_bot_hand_sync(700)


func print_loss_trace(label: String, result: Dictionary) -> void:
	print("%s winner=%d self_draw=%s actor=%d terminal_step=%d tile=%s" % [label, int(result.get("winner", -1)), str(result.get("self_draw", false)), int(result.get("deal_in_seat", -1)), int(result.get("terminal_trace_step", -1)), str(result.get("terminal_tile", ""))])
	var trace: Array = result.get("discard_trace", [])
	var terminal_step := int(result.get("terminal_trace_step", -1))
	for entry in trace:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		if int(entry.get("step", -1)) < terminal_step - 12:
			continue
		print("  %s" % JSON.stringify(entry))


func run() -> void:
	print("=== Round 89 ron-loss diagnostics ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.fast_mode_enabled = true
	scene.sfx_enabled = false
	scene.music_enabled = false
	scene.fx_enabled = false
	scene.ensure_ai_benchmark_players()
	scene.ai_sim_trace_enabled = true
	var seeds: Array = [20260701, 20260714, 20260742, 20260753, 20260805, 20260819, 20260843, 20260857]
	var losses := 0
	for seed_base in seeds:
		for hand_index in range(2):
			var wall_seed := int(seed_base) + hand_index * 17
			var hard_result := simulate_hand(scene, wall_seed, hand_index, scene.AI_DIFFICULTY_HARD)
			if int(hard_result.get("winner", -1)) != 0 or bool(hard_result.get("self_draw", false)):
				continue
			losses += 1
			print_loss_trace("HARD seed=%d hand=%d" % [int(seed_base), hand_index], hard_result)
			var easy_result := simulate_hand(scene, wall_seed, hand_index, scene.AI_DIFFICULTY_EASY)
			print_loss_trace("EASY seed=%d hand=%d" % [int(seed_base), hand_index], easy_result)
	print("=== ron losses traced: %d ===" % losses)
	scene.ai_sim_trace_enabled = false
	scene.enable_offline_all_bot_mode(false, false)
	scene.queue_free()
	quit(0)
