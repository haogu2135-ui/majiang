extends "res://scripts/ui_interaction_smoke_test.gd"


var queued_observation: Dictionary = {}


func table_snapshot(scene: Node) -> Dictionary:
	return {
		"round_id": scene.active_round_id,
		"players": scene.players.duplicate(true),
		"wall": scene.wall.duplicate(),
		"seat": scene.current_seat,
		"phase": scene.offline_phase,
		"needs_draw": scene.offline_turn_needs_draw,
		"events": scene.round_event_history.duplicate(true),
		"event_sequence": scene.round_event_sequence,
		"last_draw": scene.offline_last_draw.duplicate(true),
	}


func prepare_draw_turn(scene: Node, dealer: int = 0) -> void:
	scene.mode = "offline"
	scene.players.clear()
	for seat in range(4):
		scene.players.append({"name": "P%d" % seat, "hand": [], "discards": [], "melds": [], "flowers": 0, "flower_tiles": [], "score": 25000, "bot": seat != 0})
	scene.dealer_seat = dealer
	scene.offline_hand_number = 1
	scene.deal_offline_hand()
	var tile: String = scene.players[dealer]["hand"][0]
	check(scene.commit_discard(dealer, tile), "a real newly dealt hand commits its dealer discard")
	scene.pass_discard_to_next(dealer)
	scene.game_render_queued = false
	check(scene.offline_tile_ledger_report().get("ok", false), "the paused-run fixture retains the full legal tile ledger")


func pause_pending_delay(scene: Node) -> Timer:
	for frame_index in range(12):
		for pending_timer in scene.runtime_delay_timers:
			if pending_timer is Timer and is_instance_valid(pending_timer) and not pending_timer.paused:
				pending_timer.paused = true
				return pending_timer
		await process_frame
	check(false, "the production AI coroutine reaches a real runtime delay")
	return null


func resume_delay(timer: Timer) -> void:
	if timer != null and is_instance_valid(timer):
		timer.paused = false
		timer.timeout.emit()


func drain_old_runs(scene: Node) -> void:
	scene.show_menu(true)
	for drain_index in range(12):
		var timers: Array = scene.runtime_delay_timers.duplicate()
		for pending_timer in timers:
			resume_delay(pending_timer as Timer)
		await process_frame
		if scene.runtime_delay_timers.is_empty() and not scene.offline_ai_active and not scene.offline_ai_run_queued:
			return
	check(false, "cancelled AI coroutines and runtime delays drain without a leak")


func check_redeal_during_ai_draw(scene: Node) -> void:
	prepare_draw_turn(scene)
	scene.run_ai_until_human()
	var response_delay: Timer = await pause_pending_delay(scene)
	resume_delay(response_delay)
	var old_draw_delay: Timer = await pause_pending_delay(scene)
	check(old_draw_delay != null and scene.offline_ai_active and scene.current_seat == 1 and scene.offline_turn_needs_draw, "the original worker is paused at its production AI draw boundary")
	var original_round: String = scene.active_round_id
	prepare_draw_turn(scene)
	check(scene.active_round_id != original_round, "redealing creates an authoritative replacement round")
	scene.run_ai_until_human()
	var new_response_delay: Timer = await pause_pending_delay(scene)
	var replacement := table_snapshot(scene)
	resume_delay(old_draw_delay)
	check(table_snapshot(scene) == replacement, "an old AI draw delay cannot draw discard or score inside a replacement round")
	check(scene.offline_ai_active and scene.runtime_delay_timers.has(new_response_delay), "stale AI cleanup cannot release the replacement worker ownership")
	await drain_old_runs(scene)


func check_redeal_during_human_draw(scene: Node) -> void:
	prepare_draw_turn(scene, 3)
	scene.run_ai_until_human()
	var old_human_delay: Timer = await pause_pending_delay(scene)
	check(old_human_delay != null and scene.current_seat == 0 and scene.offline_turn_needs_draw, "the original worker is paused at its production human draw boundary")
	prepare_draw_turn(scene, 3)
	scene.run_ai_until_human()
	var new_human_delay: Timer = await pause_pending_delay(scene)
	var replacement := table_snapshot(scene)
	resume_delay(old_human_delay)
	check(table_snapshot(scene) == replacement, "an old human draw delay cannot consume the replacement wall or append a replay event")
	check(scene.offline_ai_active and scene.runtime_delay_timers.has(new_human_delay), "an old human-draw completion cannot unlock a live replacement coroutine")
	await drain_old_runs(scene)


func check_restore_same_round(scene: Node) -> void:
	prepare_draw_turn(scene)
	var restored_state: Dictionary = scene.offline_progress_state_payload().duplicate(true)
	scene.run_ai_until_human()
	var old_delay: Timer = await pause_pending_delay(scene)
	var restored_round: String = scene.active_round_id
	scene.show_menu(true)
	check(not scene.offline_ai_active and not scene.offline_ai_run_queued, "leaving the offline page immediately cancels AI ownership")
	check(scene.restore_offline_progress_state(restored_state) and scene.active_round_id == restored_round, "the exact saved hand resumes under its original replay round id")
	var restored := table_snapshot(scene)
	resume_delay(old_delay)
	check(table_snapshot(scene) == restored and not scene.offline_ai_active, "a resumed hand with the same round id cannot revive its pre-menu AI coroutine")
	await drain_old_runs(scene)


func observe_queued_owner(scene: Node) -> void:
	queued_observation = {"queued": scene.offline_ai_run_queued, "active": scene.offline_ai_active, "round_id": scene.active_round_id}


func check_stale_queued_callback(scene: Node) -> void:
	prepare_draw_turn(scene)
	scene.schedule_ai_until_human()
	var stale_callback: Callable = scene.offline_ai_queued_callback
	process_frame.connect(Callable(self, "observe_queued_owner").bind(scene), CONNECT_ONE_SHOT)
	prepare_draw_turn(scene)
	var replacement_round: String = scene.active_round_id
	scene.schedule_ai_until_human()
	var replacement := table_snapshot(scene)
	stale_callback.call()
	check(scene.offline_ai_run_queued and not scene.offline_ai_active and table_snapshot(scene) == replacement, "a late already-dispatched callback cannot consume replacement ownership or mutate its table")
	await process_frame
	check(queued_observation.get("queued", false) and not queued_observation.get("active", true) and queued_observation.get("round_id", "") == replacement_round, "a stale process-frame callback cannot consume or start the replacement queued worker")
	var new_delay: Timer = await pause_pending_delay(scene)
	check(scene.offline_ai_active and new_delay != null, "the legitimate replacement queued worker still reaches its production delay")
	await drain_old_runs(scene)


func check_live_round_redraw(scene: Node) -> void:
	prepare_draw_turn(scene)
	scene.run_ai_until_human()
	var response_delay: Timer = await pause_pending_delay(scene)
	var generation: int = scene.offline_ai_run_generation
	var round_id: String = scene.active_round_id
	scene.render_game(true)
	check(scene.offline_ai_active and scene.offline_ai_run_generation == generation and scene.active_round_id == round_id, "ordinary same-hand redraw preserves the legitimate live AI owner")
	resume_delay(response_delay)
	var draw_delay: Timer = await pause_pending_delay(scene)
	var previous_wall_size: int = scene.wall.size()
	resume_delay(draw_delay)
	check(scene.wall.size() < previous_wall_size and scene.offline_last_draw.get("seat", -1) == 1, "the current worker still performs its real AI draw after a page redraw")
	for action_index in range(48):
		for pending_timer in scene.runtime_delay_timers.duplicate():
			resume_delay(pending_timer as Timer)
		await process_frame
		if not scene.offline_ai_active and not scene.offline_ai_run_queued:
			break
	check(not scene.offline_ai_active and not scene.offline_ai_run_queued, "the legitimate visible AI loop finishes and releases its own ownership")
	check(scene.offline_phase in ["pending_claim", "ended"] or (scene.current_seat == 0 and not scene.offline_turn_needs_draw), "live AI still returns an actionable human turn claim window or completed round")
	check(scene.offline_tile_ledger_report().get("ok", false), "live AI pacing and cancellation preserve the complete tile ledger")
	await drain_old_runs(scene)


func check_shutdown_during_delay(scene: Node) -> void:
	prepare_draw_turn(scene)
	scene.run_ai_until_human()
	var pending_delay: Timer = await pause_pending_delay(scene)
	var before := table_snapshot(scene)
	scene.shutdown_runtime()
	check(pending_delay != null and table_snapshot(scene) == before, "shutdown wakes the paused AI without drawing discarding or altering replay state")
	check(scene.runtime_delay_timers.is_empty() and not scene.offline_ai_active and not scene.offline_ai_run_queued and scene.offline_ai_queued_callback.is_null(), "shutdown releases all active queued and timer-owned AI resources")


func check_human_draw_resume_entry(scene: Node) -> void:
	prepare_draw_turn(scene, 3)
	var restored_round: String = scene.active_round_id
	scene.offline_sim_quiet = false
	scene.save_offline_progress(false)
	check(scene.offline_progress_last_save_ok, "the legal awaiting-human-draw hand is saved through the production progress path")
	scene.offline_sim_quiet = true
	scene.show_menu(true)
	scene.start_offline(true)
	check(scene.offline_progress_loaded_state and scene.active_round_id == restored_round and scene.current_seat == 0 and scene.offline_turn_needs_draw, "the real menu resume entry restores the exact thirteen-tile human draw boundary")
	check(scene.offline_ai_run_queued, "restoring an awaiting human draw queues a fresh legitimate draw worker")
	if not scene.offline_ai_run_queued:
		await drain_old_runs(scene)
		return
	var restored_hand_size: int = scene.players[0]["hand"].size()
	var restored_wall_size: int = scene.wall.size()
	var recovery_delay: Timer = await pause_pending_delay(scene)
	resume_delay(recovery_delay)
	check(scene.players[0]["hand"].size() == restored_hand_size + 1 and scene.wall.size() < restored_wall_size and scene.offline_last_draw.get("seat", -1) == 0, "the restored worker performs exactly one human turn draw from the saved wall")
	check(scene.can_self_discard() and not scene.offline_ai_active and not scene.offline_ai_run_queued, "resuming the human draw boundary returns an unlocked playable fourteen-tile hand")
	check(scene.offline_tile_ledger_report().get("ok", false), "the real save-menu-resume route preserves the complete tile ledger")
	await drain_old_runs(scene)


func run() -> void:
	print("=== ai_play_round297 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	await process_frame
	var snapshot := capture_smoke_state(scene)
	scene.set_process(false)
	scene.music_enabled = false
	scene.sfx_enabled = false
	scene.tts_enabled = false
	scene.fx_enabled = false
	scene.reduce_motion_enabled = true
	scene.ai_assist_enabled = false
	scene.offline_sim_quiet = true
	scene.setup_tile_order()
	seed(297000)
	await check_redeal_during_ai_draw(scene)
	await check_redeal_during_human_draw(scene)
	await check_restore_same_round(scene)
	await check_stale_queued_callback(scene)
	await check_live_round_redraw(scene)
	await check_human_draw_resume_entry(scene)
	await check_shutdown_during_delay(scene)
	scene.shutdown_runtime()
	restore_smoke_state(scene, snapshot)
	scene.queue_free()
	await process_frame
	print("=== RESULT: %s ===" % ("FAIL" if failed else "OK"))
	quit(1 if failed else 0)
