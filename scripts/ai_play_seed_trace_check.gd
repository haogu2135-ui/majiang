extends SceneTree

const TRACE_SEED := 20260730
const TRACE_HAND_COUNT := 4
const TRACE_DIFFICULTIES := [0, 2]


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
	scene.ai_sim_trace_enabled = true

	for difficulty in TRACE_DIFFICULTIES:
		for hand_offset in range(TRACE_HAND_COUNT):
			scene.ensure_ai_benchmark_players()
			scene.ai_difficulty = difficulty
			scene.ai_benchmark_base_difficulty = difficulty
			scene.ai_benchmark_probe_seat = -1
			scene.ai_benchmark_probe_difficulty = -1
			scene.enable_offline_all_bot_mode(true, true)
			scene.reset_ai_profile_seat_map()
			seed(TRACE_SEED + hand_offset * 17)
			scene.offline_skip_ai_profile_reshuffle = true
			scene.mode = "offline"
			scene.offline_hand_number = 1
			scene.dealer_seat = hand_offset % 4
			for seat in range(4):
				scene.players[seat]["score"] = scene.MATCH_START_SCORE
			scene.deal_offline_hand()
			scene.reset_ai_profile_seat_map()
			var result: Dictionary = scene.simulate_offline_bot_hand_sync(700)
			var deal_in_seat := int(result.get("deal_in_seat", -1))
			print("MATCH diff=%d hand=%d seed=%d deal_in=%d winner=%d tile=%s high=%d/%d human_high=%d/%d" % [
				difficulty,
				hand_offset,
				TRACE_SEED + hand_offset * 17,
				deal_in_seat,
				int(result.get("winner", -1)),
				str(result.get("terminal_tile", "")),
				int(result.get("high_danger_discards", 0)),
				int(result.get("discards", 0)),
				int(result.get("human_high_danger_discards", 0)),
				int(result.get("discards", 0)),
			])
			for entry in result.get("discard_trace", []):
				if int(entry.get("seat", -1)) != deal_in_seat and not bool(entry.get("hard_guard_moved", false)):
					continue
				print("TRACE step=%d seat=%d tile=%s rank=%d risk=%.1f feed=%.1f human=%.1f sh=%d score=%.1f best=%s/%.1f/sh%d safe=%s/%.1f/sh%d avoid=%s guard=%s" % [
					int(entry.get("step", -1)),
					int(entry.get("seat", -1)),
					str(entry.get("tile", "")),
					int(entry.get("selected_rank", -1)),
					float(entry.get("risk", 0.0)),
					float(entry.get("feed", 0.0)),
					float(entry.get("human_pressure", 0.0)),
					int(entry.get("shanten", -1)),
					float(entry.get("score", 0.0)),
					str(entry.get("best_tile", "")),
					float(entry.get("best_risk", 0.0)),
					int(entry.get("best_shanten", -1)),
					str(entry.get("safest_tile", "")),
					float(entry.get("safest_risk", 0.0)),
					int(entry.get("safest_shanten", -1)),
					str(entry.get("avoidable_high_danger", false)),
					str(entry.get("hard_guard_moved", false)),
				])
	scene.enable_offline_all_bot_mode(false, false)
	scene.queue_free()
	quit()
