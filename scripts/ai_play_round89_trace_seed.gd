extends SceneTree


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
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
	for difficulty in [scene.AI_DIFFICULTY_EASY, scene.AI_DIFFICULTY_HARD]:
		scene.ai_difficulty = difficulty
		scene.ai_benchmark_base_difficulty = difficulty
		scene.ai_benchmark_probe_seat = 0
		scene.ai_benchmark_probe_difficulty = scene.AI_DIFFICULTY_NORMAL
		for hand_index in range(2):
			scene.enable_offline_all_bot_mode(true, true)
			scene.reset_ai_profile_seat_map()
			seed(20260805 + hand_index * 17)
			scene.offline_skip_ai_profile_reshuffle = true
			scene.mode = "offline"
			scene.offline_hand_number = 1
			scene.dealer_seat = hand_index % 4
			for seat in range(4):
				scene.players[seat]["score"] = scene.MATCH_START_SCORE
			scene.deal_offline_hand()
			scene.reset_ai_profile_seat_map()
			var result: Dictionary = scene.simulate_offline_bot_hand_sync(700)
			print("seed=20260805 difficulty=%d hand=%d ended=%s probeRon=%d winner=%d" % [
				difficulty,
				hand_index,
				str(result.get("ended", false)),
				int(result.get("deal_ins_to_human", 0)),
				int(result.get("terminal_winner", -1)),
			])
			if int(result.get("deal_ins_to_human", 0)) <= 0:
				continue
			var terminal_step := int(result.get("terminal_trace_step", -1))
			var trace: Array = result.get("discard_trace", [])
			for trace_entry in trace:
				if typeof(trace_entry) != TYPE_DICTIONARY or int(trace_entry.get("step", -2)) != terminal_step:
					continue
				print("terminal=%s" % JSON.stringify(trace_entry))
				break
	scene.ai_sim_trace_enabled = false
	scene.enable_offline_all_bot_mode(false, false)
	scene.queue_free()
	quit(0)
