extends "res://scripts/ui_interaction_smoke_test.gd"


func table_snapshot(scene: Node) -> Dictionary:
	return {
		"round_id": scene.active_round_id,
		"players": scene.players.duplicate(true),
		"wall": scene.wall.duplicate(),
		"phase": scene.offline_phase,
		"seat": scene.current_seat,
		"needs_draw": scene.offline_turn_needs_draw,
		"pending": scene.offline_pending_claim.duplicate(true),
		"last_draw": scene.offline_last_draw.duplicate(true),
		"events": scene.round_event_history.duplicate(true),
		"event_sequence": scene.round_event_sequence,
		"ai_active": scene.offline_ai_active,
		"ai_queued": scene.offline_ai_run_queued,
		"danger_index": scene.pending_danger_discard_index,
		"danger_tile": scene.pending_danger_discard_tile,
		"danger_report": scene.pending_danger_discard_report.duplicate(true),
		"claim_sequence": scene.offline_claim_sequence,
		"danger_sequence": scene.offline_danger_confirmation_sequence,
	}


func prepare_match(scene: Node) -> void:
	scene.start_new_offline_match()
	check(scene.mode == "offline" and scene.can_self_discard() and scene.players[0]["hand"].size() == 14, "the production restart entry deals a playable fourteen-tile human hand")
	check(scene.offline_tile_ledger_report().get("ok", false) and scene.round_event_history.size() >= 53, "the restart fixture keeps the full tile ledger and real replay events")


func pending_resolution(scene: Node) -> Callable:
	for connection in process_frame.get_connections():
		var callback: Callable = connection.get("callable", Callable())
		if callback.get_object() == scene and callback.get_method() in ["resolve_human_discard_after_frame", "resolve_offline_discard_after_frame"]:
			return callback
	return Callable()


func hand_button(scene: Node, hand_index: int) -> Button:
	if scene.root_layer == null:
		return null
	for candidate in scene.root_layer.find_children("*", "Button", true, false):
		var button := candidate as Button
		if str(button.get_meta("tile_click_role", "")) != "play_tile":
			continue
		var parent: Node = button
		while parent != null and parent != scene.root_layer:
			if parent.has_meta("hand_source_index"):
				if int(parent.get_meta("hand_source_index", -1)) == hand_index:
					return button
				break
			parent = parent.get_parent()
	return null


func leave_and_drain(scene: Node) -> void:
	scene.show_menu(true)
	for pending_timer in scene.runtime_delay_timers.duplicate():
		if pending_timer is Timer and is_instance_valid(pending_timer):
			pending_timer.timeout.emit()
	await process_frame
	await process_frame


func check_different_tile_restart(scene: Node) -> void:
	prepare_match(scene)
	var original_tile: String = scene.players[0]["hand"][0]
	scene.human_discard(0)
	check(scene.offline_phase == "resolving" and not pending_resolution(scene).is_null(), "a real human discard queues its production next-frame resolver")
	prepare_match(scene)
	var replacement_index := -1
	for hand_index in range(scene.players[0]["hand"].size()):
		if str(scene.players[0]["hand"][hand_index]) != original_tile:
			replacement_index = hand_index
			break
	check(replacement_index >= 0, "the replacement hand exposes a different legal discard")
	if replacement_index >= 0:
		scene.human_discard(replacement_index)
		check(scene.offline_phase == "resolving", "the replacement human discard reaches its own resolving phase")
		await process_frame
		check(scene.offline_phase != "resolving", "a rapid restart and different-tile discard cannot lose its resolver or deadlock the table")
	await leave_and_drain(scene)


func check_same_tile_stale_resolver(scene: Node) -> void:
	prepare_match(scene)
	var original_tile: String = scene.players[0]["hand"][0]
	scene.human_discard(0)
	var stale_callback := pending_resolution(scene)
	check(not stale_callback.is_null(), "the original real discard exposes a retainable dispatched callback")
	var replacement_index := -1
	for redeal_index in range(12):
		prepare_match(scene)
		replacement_index = scene.players[0]["hand"].find(original_tile)
		if replacement_index >= 0:
			break
	check(replacement_index >= 0, "a real replacement round contains the same face for ownership collision coverage")
	if replacement_index >= 0 and not stale_callback.is_null():
		scene.human_discard(replacement_index)
		var replacement := table_snapshot(scene)
		stale_callback.call()
		check(table_snapshot(scene) == replacement, "an already-dispatched old same-face resolver cannot adjudicate a replacement round")
	await leave_and_drain(scene)


func check_old_native_button(scene: Node) -> void:
	prepare_match(scene)
	var stale_button := hand_button(scene, 0)
	check(stale_button != null and not stale_button.disabled, "the old hand exposes a real enabled native tile button")
	prepare_match(scene)
	var replacement := table_snapshot(scene)
	if stale_button != null and is_instance_valid(stale_button):
		stale_button.pressed.emit()
		check(table_snapshot(scene) == replacement, "a retained old native button signal cannot discard from the replacement hand")
	await leave_and_drain(scene)


func check_exact_duplicate_copy(scene: Node) -> void:
	var first_index := -1
	var chosen_index := -1
	for redeal_index in range(12):
		prepare_match(scene)
		var first_by_tile := {}
		for hand_index in range(scene.players[0]["hand"].size()):
			var tile: String = scene.players[0]["hand"][hand_index]
			if first_by_tile.has(tile):
				first_index = int(first_by_tile[tile])
				chosen_index = hand_index
				break
			first_by_tile[tile] = hand_index
		if chosen_index >= 0:
			break
	check(chosen_index > first_index and first_index >= 0, "a real dealt hand contains separately serialized identical tile copies")
	if chosen_index >= 0:
		var first_serial: int = scene.players[0]["hand_instance_serials"][first_index]
		var chosen_serial: int = scene.players[0]["hand_instance_serials"][chosen_index]
		var chosen_tile: String = scene.players[0]["hand"][chosen_index]
		var chosen_button := hand_button(scene, chosen_index)
		check(chosen_button != null and chosen_button.get_meta("tile_code", "") == chosen_tile and first_serial != chosen_serial, "the selected native button represents the second exact physical copy")
		if chosen_button != null:
			chosen_button.pressed.emit()
			var remaining_serials: Array = scene.players[0]["hand_instance_serials"]
			check(not remaining_serials.has(chosen_serial) and remaining_serials.has(first_serial), "a second-copy native click removes that exact hand serial rather than the first matching face")
			check(scene.offline_tile_ledger_report().get("ok", false), "exact-copy discard keeps the complete tile ledger")
	await leave_and_drain(scene)


func check_live_redraw_and_once(scene: Node) -> void:
	prepare_match(scene)
	scene.render_game(true)
	var current_button := hand_button(scene, 0)
	check(current_button != null and not current_button.disabled, "an ordinary same-hand redraw keeps a live native discard button")
	if current_button != null:
		current_button.pressed.emit()
		var current_callback := pending_resolution(scene)
		check(scene.offline_phase == "resolving" and scene.players[0]["hand"].size() == 13 and not current_callback.is_null(), "the live native button commits exactly one card and queues its own resolver")
		var submitted := table_snapshot(scene)
		scene.human_discard(0)
		check(table_snapshot(scene) == submitted, "a repeated submit while resolving cannot discard a second physical card")
		scene.render_game(true)
		await process_frame
		check(scene.offline_phase != "resolving" and pending_resolution(scene).is_null(), "the legitimate resolver survives a same-hand redraw and adjudicates on the real process frame")
		var resolved := table_snapshot(scene)
		current_callback.call()
		check(table_snapshot(scene) == resolved, "a consumed resolver cannot adjudicate twice or replace a queued AI continuation")
		check(scene.offline_tile_ledger_report().get("ok", false), "ordinary live input and adjudication preserve the full tile ledger")
	await leave_and_drain(scene)


func advance_to_human(scene: Node) -> bool:
	for action_index in range(96):
		if scene.offline_phase == "ended":
			return false
		if scene.offline_phase == "pending_claim":
			scene.human_claim("pass")
		for pending_timer in scene.runtime_delay_timers.duplicate():
			if pending_timer is Timer and is_instance_valid(pending_timer):
				pending_timer.timeout.emit()
		await process_frame
		if scene.can_self_discard() and not scene.offline_ai_active and not scene.offline_ai_run_queued:
			return true
	return false


func check_same_round_nonce(scene: Node) -> void:
	prepare_match(scene)
	var first_index := -1
	var repeated_tile := ""
	for hand_index in range(scene.players[0]["hand"].size()):
		var tile: String = scene.players[0]["hand"][hand_index]
		if scene.players[0]["hand"].count(tile) >= 2:
			first_index = hand_index
			repeated_tile = tile
			break
	check(first_index >= 0, "the same-round nonce fixture begins with two physical copies of one face")
	if first_index >= 0:
		scene.human_discard(first_index)
		var stale_callback := pending_resolution(scene)
		var round_id: String = scene.active_round_id
		var generation: int = scene.offline_ai_run_generation
		check(await advance_to_human(scene), "real AI turns and legal passes return control to the human within the same round")
		var second_index: int = scene.players[0]["hand"].find(repeated_tile)
		check(second_index >= 0 and scene.active_round_id == round_id and scene.offline_ai_run_generation == generation, "the second same-face action shares the round and generation but still has its own intent")
		if second_index >= 0 and scene.can_self_discard():
			scene.human_discard(second_index)
			var newer := table_snapshot(scene)
			stale_callback.call()
			check(table_snapshot(scene) == newer and not pending_resolution(scene).is_null(), "an old same-round same-face nonce cannot consume or adjudicate a newer human intent")
			await process_frame
			check(scene.offline_phase != "resolving", "the newer same-round intent remains live after its stale predecessor is ignored")
			check(scene.offline_tile_ledger_report().get("ok", false), "same-round repeated-face intents preserve every physical tile")
	await leave_and_drain(scene)


func check_menu_and_same_id_restore(scene: Node) -> void:
	prepare_match(scene)
	var saved_state: Dictionary = scene.offline_progress_state_payload().duplicate(true)
	var stale_button := hand_button(scene, 0)
	scene.human_discard(0)
	var stale_callback := pending_resolution(scene)
	scene.show_menu(true)
	check(pending_resolution(scene).is_null() and scene.offline_human_discard_callback.is_null(), "leaving the offline page immediately detaches its pending human resolver")
	check(scene.restore_offline_progress_state(saved_state) and scene.active_round_id == saved_state.get("active_round_id", ""), "accepted restore keeps the same replay round id while changing action ownership")
	var restored := table_snapshot(scene)
	stale_callback.call()
	if stale_button != null and is_instance_valid(stale_button):
		stale_button.pressed.emit()
	check(table_snapshot(scene) == restored and pending_resolution(scene).is_null(), "old resolvers and native controls cannot submit into a restored identical hand and round id")
	await leave_and_drain(scene)


func check_preferred_index_validation(scene: Node) -> void:
	prepare_match(scene)
	var tile: String = scene.players[0]["hand"][0]
	var wrong_index := -1
	for hand_index in range(scene.players[0]["hand"].size()):
		if str(scene.players[0]["hand"][hand_index]) != tile:
			wrong_index = hand_index
			break
	var original := table_snapshot(scene)
	check(wrong_index >= 0 and not scene.commit_discard(0, tile, wrong_index) and table_snapshot(scene) == original, "a preferred index pointing at a different face cannot consume either physical copy")
	check(not scene.commit_discard(0, tile, scene.players[0]["hand"].size()) and table_snapshot(scene) == original, "an out-of-range preferred index cannot fall back to the first matching face")
	check(scene.commit_discard(0, tile) and scene.players[0]["discards"].size() == 1 and scene.offline_tile_ledger_report().get("ok", false), "legacy by-value callers still commit one legal face with conserved inventory")
	await leave_and_drain(scene)


func check_shutdown_resolver(scene: Node) -> void:
	prepare_match(scene)
	scene.human_discard(0)
	var stale_callback := pending_resolution(scene)
	var before := table_snapshot(scene)
	scene.shutdown_runtime()
	check(pending_resolution(scene).is_null() and scene.offline_human_discard_callback.is_null(), "shutdown detaches every pending human process-frame resolver")
	stale_callback.call()
	check(table_snapshot(scene) == before, "a dispatched human resolver cannot mutate inventory replay or AI ownership after shutdown")


func repeated_hand_indices(scene: Node) -> Array[int]:
	var first_by_tile := {}
	for hand_index in range(scene.players[0]["hand"].size()):
		var tile: String = scene.players[0]["hand"][hand_index]
		if first_by_tile.has(tile):
			return [int(first_by_tile[tile]), hand_index]
		first_by_tile[tile] = hand_index
	return []


func open_danger_intent(scene: Node, hand_index: int) -> void:
	scene.ai_assist_enabled = true
	var tile: String = scene.players[0]["hand"][hand_index]
	scene.current_human_advice = [{"tile": tile, "hand_index": hand_index, "risk": 55.0, "feed_risk": 45.0, "risk_label": "高", "danger_source": {"reason": "input ownership fixture", "seat": 2}}]
	for alternative_index in range(scene.players[0]["hand"].size()):
		var alternative: String = scene.players[0]["hand"][alternative_index]
		if alternative != tile:
			scene.current_human_advice.append({"tile": alternative, "hand_index": alternative_index, "risk": 4.0, "feed_risk": 2.0, "risk_label": "低", "safety_label": "安", "shanten": 1, "ukeire": 3})
			break
	scene.human_discard(hand_index)
	check(scene.has_pending_danger_discard() and scene.pending_danger_discard_index == hand_index and scene.players[0]["hand"].size() == 14, "the real danger entry preserves the selected physical copy while awaiting consent")
	check(scene.offline_tile_ledger_report().get("ok", false), "the danger UI risk fixture keeps the authentic dealt tile ledger")


func current_action_button(scene: Node, button_name: String) -> Button:
	return scene.root_layer.find_child(button_name, true, false) as Button


func check_duplicate_danger_confirmation(scene: Node) -> void:
	var indices: Array[int] = []
	for redeal_index in range(12):
		prepare_match(scene)
		indices = repeated_hand_indices(scene)
		if not indices.is_empty():
			break
	check(indices.size() == 2, "the danger-confirm fixture has two authentic serialized copies of one face")
	if indices.size() == 2:
		var first_serial: int = scene.players[0]["hand_instance_serials"][indices[0]]
		var chosen_serial: int = scene.players[0]["hand_instance_serials"][indices[1]]
		open_danger_intent(scene, indices[1])
		scene.render_game(true)
		var confirm := current_action_button(scene, "DangerDiscardConfirmButton")
		check(confirm != null and not confirm.disabled, "an ordinary danger redraw leaves a live native confirmation button")
		if confirm != null:
			confirm.pressed.emit()
			check(scene.players[0]["hand"].size() == 13 and not scene.has_pending_danger_discard(), "one native danger confirmation submits the selected copy without opening a different duplicate intent")
			var remaining: Array = scene.players[0]["hand_instance_serials"]
			check(not remaining.has(chosen_serial) and remaining.has(first_serial), "danger confirmation removes the selected second serial and preserves the first identical copy")
			var submitted := table_snapshot(scene)
			confirm.pressed.emit()
			check(table_snapshot(scene) == submitted, "a repeated native danger confirmation cannot consume another physical copy")
	scene.ai_assist_enabled = false
	await leave_and_drain(scene)


func check_reopened_danger_controls(scene: Node) -> void:
	prepare_match(scene)
	open_danger_intent(scene, 0)
	var stale_confirm := current_action_button(scene, "DangerDiscardConfirmButton")
	var stale_cancel := current_action_button(scene, "DangerDiscardCancelButton")
	check(stale_confirm != null and stale_cancel != null, "the original danger intent exposes real confirm and cancel controls")
	scene.clear_pending_danger_discard()
	open_danger_intent(scene, 0)
	var reopened := table_snapshot(scene)
	if stale_cancel != null and is_instance_valid(stale_cancel):
		stale_cancel.pressed.emit()
		check(table_snapshot(scene) == reopened, "an old cancel cannot dismiss a reopened same-hand same-face danger intent")
	if not scene.has_pending_danger_discard():
		open_danger_intent(scene, 0)
	reopened = table_snapshot(scene)
	if stale_confirm != null and is_instance_valid(stale_confirm):
		stale_confirm.pressed.emit()
		check(table_snapshot(scene) == reopened, "an old confirm cannot consent to a reopened same-hand same-face danger intent")
	scene.ai_assist_enabled = false
	await leave_and_drain(scene)


func check_replacement_danger_controls(scene: Node) -> void:
	prepare_match(scene)
	var tile: String = scene.players[0]["hand"][0]
	open_danger_intent(scene, 0)
	var stale_confirm := current_action_button(scene, "DangerDiscardConfirmButton")
	var replacement_index := -1
	for redeal_index in range(12):
		prepare_match(scene)
		replacement_index = scene.players[0]["hand"].find(tile)
		if replacement_index >= 0:
			break
	check(replacement_index >= 0, "the replacement danger fixture deals the same face in a new authoritative round")
	if replacement_index >= 0:
		open_danger_intent(scene, replacement_index)
		var replacement := table_snapshot(scene)
		if stale_confirm != null and is_instance_valid(stale_confirm):
			stale_confirm.pressed.emit()
			check(table_snapshot(scene) == replacement, "an old danger confirm cannot submit or consent inside a replacement round")
	scene.ai_assist_enabled = false
	await leave_and_drain(scene)


func advance_to_claim_window(scene: Node) -> bool:
	for action_index in range(96):
		if scene.offline_phase == "pending_claim":
			return true
		if scene.offline_phase == "ended":
			return false
		if scene.can_self_discard():
			scene.human_discard(0)
		for pending_timer in scene.runtime_delay_timers.duplicate():
			if pending_timer is Timer and is_instance_valid(pending_timer):
				pending_timer.timeout.emit()
		await process_frame
	return scene.offline_phase == "pending_claim"


func native_pass_button(scene: Node) -> Button:
	var tail: Node = scene.root_layer.find_child("PendingClaimResponseTailLane", true, false)
	if tail != null:
		for candidate in tail.get_children():
			if candidate is Button and bool(candidate.get_meta("pending_tail", false)):
				return candidate as Button
	return null


func check_restored_claim_controls(scene: Node) -> void:
	prepare_match(scene)
	check(await advance_to_claim_window(scene), "real AI discards open an authentic human claim window")
	if scene.offline_phase != "pending_claim":
		await leave_and_drain(scene)
		return
	check(scene.offline_tile_ledger_report().get("ok", false) and scene.round_event_history.size() > 53, "the native claim fixture has a conserved physical ledger and nonempty production replay")
	var stale_pass := native_pass_button(scene)
	check(stale_pass != null and not stale_pass.disabled, "the real claim window exposes an enabled native pass button")
	var saved_state: Dictionary = scene.offline_progress_state_payload().duplicate(true)
	var callbacks: Array = stale_pass.pressed.get_connections() if stale_pass != null else []
	check(callbacks.size() == 1, "the retained native pass signal contains its actual production action callable")
	var stale_callback: Callable = callbacks[0].get("callable", Callable()) if callbacks.size() == 1 else Callable()
	scene.show_menu(true)
	check(scene.restore_offline_progress_state(saved_state) and scene.offline_phase == "pending_claim" and scene.active_round_id == saved_state.get("active_round_id", ""), "production restore accepts the identical pending claim and round id")
	scene.render_game(true)
	var restored := table_snapshot(scene)
	if stale_pass != null and is_instance_valid(stale_pass):
		stale_pass.pressed.emit()
		check(table_snapshot(scene) == restored, "an old native pass cannot answer the same claim after menu and restore")
	check(scene.restore_offline_progress_state(saved_state), "the original real pending state remains accepted for dispatched-callable coverage")
	scene.render_game(true)
	await process_frame
	restored = table_snapshot(scene)
	check(stale_callback.is_valid(), "an already-dispatched native claim action remains a callable after its old control is released")
	if stale_callback.is_valid():
		stale_callback.call()
		check(table_snapshot(scene) == restored, "an already-dispatched old pass cannot consume restored claim options or append replay events")
	check(scene.restore_offline_progress_state(saved_state), "the authentic pending state remains restorable for legitimate input coverage")
	scene.render_game(true)
	var live_sequence: int = scene.offline_claim_sequence
	var live_round: String = scene.active_round_id
	scene.render_game(true)
	var current_pass := native_pass_button(scene)
	check(current_pass != null and not current_pass.disabled and scene.offline_claim_sequence == live_sequence, "a same-window redraw preserves a live native pass and its intent sequence")
	if current_pass != null:
		var live_connections: Array = current_pass.pressed.get_connections()
		check(live_connections.size() == 1, "the current native pass retains its production callback for later-window coverage")
		var consumed_callback: Callable = live_connections[0].get("callable", Callable()) if live_connections.size() == 1 else Callable()
		var before_pass := table_snapshot(scene)
		current_pass.pressed.emit()
		check(table_snapshot(scene) != before_pass and scene.offline_phase != "pending_claim", "the current native pass still answers its authentic claim exactly once")
		var consumed := table_snapshot(scene)
		current_pass.pressed.emit()
		check(table_snapshot(scene) == consumed, "a consumed native pass cannot adjudicate twice")
		check(scene.offline_tile_ledger_report().get("ok", false), "legitimate native claim input preserves the complete tile ledger")
		check(await advance_to_claim_window(scene), "real AI play reaches another human claim within the same authoritative round")
		if scene.offline_phase == "pending_claim":
			check(scene.active_round_id == live_round and scene.offline_claim_sequence > live_sequence, "a newer same-round claim has its own monotonic input sequence")
			var newer := table_snapshot(scene)
			check(consumed_callback.is_valid(), "the consumed native pass still exposes its already-dispatched callback in a later window")
			if consumed_callback.is_valid():
				consumed_callback.call()
			check(table_snapshot(scene) == newer, "consumed claim controls cannot answer a newer same-round response window")
	check(scene.restore_offline_progress_state(saved_state), "the real pending state remains accepted for timeout boundary coverage")
	scene.render_game(true)
	var expiring_pass := native_pass_button(scene)
	check(expiring_pass != null and not expiring_pass.disabled, "the timeout fixture retains a live native response control")
	scene.offline_pending_claim["deadline_msec"] = Time.get_ticks_msec() - 1
	if expiring_pass != null:
		expiring_pass.pressed.emit()
		check(scene.offline_phase != "pending_claim" and scene.offline_tile_ledger_report().get("ok", false), "an owned native action at expiry still follows the automatic-pass contract")
	await leave_and_drain(scene)


func check_live_danger_actions(scene: Node) -> void:
	prepare_match(scene)
	open_danger_intent(scene, 0)
	var cancel := current_action_button(scene, "DangerDiscardCancelButton")
	var hand_before: Array = scene.players[0]["hand_instance_serials"].duplicate()
	if cancel != null:
		cancel.pressed.emit()
		check(not scene.has_pending_danger_discard() and scene.players[0]["hand_instance_serials"] == hand_before, "the current native danger cancel dismisses only its intent without discarding")
	open_danger_intent(scene, 0)
	var alternative := current_action_button(scene, "DangerDiscardAlternativeButton_0")
	var selected_serial: int = scene.players[0]["hand_instance_serials"][0]
	check(alternative != null and not alternative.disabled, "the real danger intent exposes a live safe-alternative control")
	if alternative != null:
		alternative.pressed.emit()
		check(scene.players[0]["hand"].size() == 13 and scene.players[0]["hand_instance_serials"].has(selected_serial) and scene.offline_tile_ledger_report().get("ok", false), "a current safe alternative submits its own face and retains the declined danger copy")
	scene.ai_assist_enabled = false
	await leave_and_drain(scene)


func check_restored_action_bar(scene: Node) -> void:
	prepare_match(scene)
	scene.ai_assist_enabled = true
	scene.render_game(true)
	var old_recommendation := current_action_button(scene, "RecommendedDiscardButton")
	var original_bar: int = scene.action_bar.get_instance_id()
	check(old_recommendation != null and not old_recommendation.disabled, "the authentic fresh hand exposes a live recommended-discard action")
	var saved_state: Dictionary = scene.offline_progress_state_payload().duplicate(true)
	check(scene.restore_offline_progress_state(saved_state), "direct same-hand restore succeeds without first removing the visible action bar")
	scene.render_game(true)
	check(scene.action_bar.get_instance_id() != original_bar, "an ownership-changing identical-hand restore rebuilds retained action callbacks")
	var restored := table_snapshot(scene)
	if old_recommendation != null and is_instance_valid(old_recommendation):
		old_recommendation.pressed.emit()
		check(table_snapshot(scene) == restored, "a retired recommendation cannot submit into an identical restored hand")
	var current_recommendation := current_action_button(scene, "RecommendedDiscardButton")
	check(current_recommendation != null and not current_recommendation.disabled, "the replacement action bar contains a live newly owned recommendation")
	if current_recommendation != null:
		current_recommendation.pressed.emit()
		check(scene.players[0]["hand"].size() == 13 or scene.has_pending_danger_discard(), "a newly owned recommended action still submits or opens its valid danger intent")
		check(scene.offline_tile_ledger_report().get("ok", false), "ownership-aware action-bar replacement preserves every physical tile")
	scene.ai_assist_enabled = false
	await leave_and_drain(scene)


func pending_controls_snapshot(scene: Node) -> Dictionary:
	var stack := scene.root_layer.find_child("PendingClaimActionStack", true, false) as Control
	var buttons: Array = []
	if stack != null:
		for candidate in stack.find_children("*", "BaseButton", true, false):
			var button := candidate as BaseButton
			buttons.append({"id": button.get_instance_id(), "disabled": button.disabled, "focus": button.focus_mode, "mouse": button.mouse_filter})
	var focus: Control = scene.get_viewport().gui_get_focus_owner()
	return {
		"visible": stack != null and stack.visible,
		"invalidated": bool(stack.get_meta("pending_action_invalidated", false)) if stack != null else true,
		"buttons": buttons,
		"focus": focus.get_instance_id() if focus != null else 0,
		"guide": [scene.interactive_guide_active, scene.interactive_guide_type, scene.interactive_guide_target_index],
		"keyboard": scene.hand_keyboard_selection,
	}


func check_rejected_claim_controls(scene: Node) -> void:
	prepare_match(scene)
	check(await advance_to_claim_window(scene), "real AI play opens a legal response for rejection-boundary coverage")
	if scene.offline_phase == "pending_claim":
		var pass_button := native_pass_button(scene)
		check(pass_button != null and not pass_button.disabled and scene.pending_claim_remaining_seconds() > 0, "the rejection fixture begins with a live unexpired native response")
		if pass_button != null:
			pass_button.grab_focus()
			var controls := pending_controls_snapshot(scene)
			var table := table_snapshot(scene)
			scene.human_claim("unsupported_response")
			check(table_snapshot(scene) == table, "a rejected response leaves inventory claim options replay and intent sequence unchanged")
			check(pending_controls_snapshot(scene) == controls, "a rejected response preserves the visible native controls focus and guide state")
			check(not pass_button.disabled and bool(pending_controls_snapshot(scene).get("visible", false)), "a rejected response cannot hide or disable the legitimate pass action")
			if not pass_button.disabled:
				pass_button.pressed.emit()
				check(scene.offline_phase != "pending_claim" and scene.offline_tile_ledger_report().get("ok", false), "the existing native pass remains usable after an invalid submission without a redraw")
	await leave_and_drain(scene)


func check_saved_human_resolution(scene: Node) -> void:
	prepare_match(scene)
	var round_id: String = scene.active_round_id
	var tile: String = scene.players[0]["hand"][0]
	scene.human_discard(0)
	var old_callback := pending_resolution(scene)
	check(not old_callback.is_null() and scene.offline_phase == "resolving", "the immediate-menu fixture commits one real discard before its frame adjudication")
	scene.show_menu(true)
	check(scene.offline_progress_last_save_ok and pending_resolution(scene).is_null(), "the production menu flush saves the committed boundary and detaches its old resolver")
	scene.start_offline(true)
	check(scene.offline_progress_loaded_state and scene.active_round_id == round_id and scene.players[0]["discards"] == [tile], "the production resume entry restores the exact committed discard and original round")
	check(not pending_resolution(scene).is_null(), "a restored resolving human discard receives a newly owned production frame resolver")
	var resumed := table_snapshot(scene)
	old_callback.call()
	check(table_snapshot(scene) == resumed, "the old dispatched resolver cannot adjudicate the restored committed boundary")
	await process_frame
	check(scene.offline_phase != "resolving" and pending_resolution(scene).is_null(), "the resumed human discard adjudicates once instead of remaining permanently resolving")
	check(scene.players[0]["discards"] == [tile] and scene.offline_tile_ledger_report().get("ok", false), "resuming adjudication never discards a second copy and preserves the complete tile ledger")
	await leave_and_drain(scene)


func prepare_bot_dealer_discard(scene: Node, wants_chi: bool) -> Dictionary:
	prepare_match(scene)
	scene.dealer_seat = 3
	for deal_index in range(16):
		scene.deal_offline_hand()
		for hand_index in range(scene.players[3]["hand"].size()):
			var tile: String = scene.players[3]["hand"][hand_index]
			var human_options: Array = scene.get_claim_options(0, 3, tile)
			if wants_chi and not human_options.has("chi"):
				continue
			if not wants_chi and not human_options.is_empty():
				continue
			if not scene.get_claim_options(1, 3, tile).is_empty() or not scene.get_claim_options(2, 3, tile).is_empty():
				continue
			check(scene.players[3]["hand"].size() == 14 and scene.players[0]["hand"].size() == 13 and scene.offline_tile_ledger_report().get("ok", false) and scene.round_event_history.size() >= 53, "the bot-dealer boundary uses a complete production deal and authentic replay")
			return {"index": hand_index, "tile": tile}
	check(false, "a real bot-dealer deal provides the requested legal discard boundary")
	return {}


func check_saved_bot_resolution(scene: Node) -> void:
	var discard := prepare_bot_dealer_discard(scene, false)
	if not discard.is_empty():
		var tile: String = discard["tile"]
		var round_id: String = scene.active_round_id
		check(scene.commit_discard(3, tile, int(discard["index"])), "the production commit accepts a real uncontested bot discard")
		scene.show_menu(true)
		check(scene.offline_progress_last_save_ok, "the menu flush persists a committed bot resolving boundary")
		scene.start_offline(true)
		var old_callback := pending_resolution(scene)
		check(scene.offline_progress_loaded_state and scene.active_round_id == round_id and scene.players[3]["discards"] == [tile] and not old_callback.is_null(), "a bot resolving save restores its original round river and owned adjudicator")
		var saved_state: Dictionary = scene.offline_progress_state_payload().duplicate(true)
		check(scene.restore_offline_progress_state(saved_state), "an identical bot resolving boundary remains valid for immediate repeated restore")
		var current_callback := pending_resolution(scene)
		var restored := table_snapshot(scene)
		old_callback.call()
		check(not current_callback.is_null() and current_callback.get_bound_arguments() != old_callback.get_bound_arguments() and pending_resolution(scene).get_bound_arguments() == current_callback.get_bound_arguments() and table_snapshot(scene) == restored, "an old bot resolver cannot consume a newer identical restored boundary")
		await process_frame
		check(scene.offline_phase == "await_discard" and scene.current_seat == 0 and (scene.offline_ai_run_queued or scene.offline_ai_active or scene.can_self_discard()), "an uncontested restored bot discard schedules the pending human draw")
		check(await advance_to_human(scene), "restoring seat three completes one real human draw and returns playable control")
		check(scene.players[0]["hand"].size() == 14 and scene.players[3]["discards"] == [tile] and scene.offline_tile_ledger_report().get("ok", false), "bot-boundary resume preserves the complete physical ledger without a second discard")
	await leave_and_drain(scene)


func check_rejected_chi_controls(scene: Node) -> void:
	var discard := prepare_bot_dealer_discard(scene, true)
	if not discard.is_empty():
		var tile: String = discard["tile"]
		check(scene.commit_discard(3, tile, int(discard["index"])), "the production source discard opens an authentic chi opportunity")
		scene.resolve_after_discard(3, tile)
		check(scene.offline_phase == "pending_claim" and scene.offline_pending_claim.get("options", []).has("chi") and scene.offline_tile_ledger_report().get("ok", false), "the real chi response keeps its conserved source river and hand")
		if scene.offline_phase == "pending_claim":
			var pass_button := native_pass_button(scene)
			if pass_button != null:
				pass_button.grab_focus()
			var controls := pending_controls_snapshot(scene)
			var original := table_snapshot(scene)
			var choice: Dictionary = scene.offline_pending_claim["chi_choices"][0].duplicate(true)
			for malformed in [{"meld": "invalid", "needed": []}, {"meld": choice["meld"], "needed": "invalid"}, {"meld": choice["meld"], "needed": []}]:
				scene.human_claim("chi", malformed)
				check(table_snapshot(scene) == original and pending_controls_snapshot(scene) == controls, "a malformed or unoffered chi shape preserves the real response controls and inventory")
			var stack: Node = scene.root_layer.find_child("PendingClaimActionStack", true, false)
			var chi_button := first_button_with_text_prefix(stack, "吃")
			check(chi_button != null and not chi_button.disabled, "the native legal chi action remains available after malformed submissions")
			if chi_button != null and not chi_button.disabled:
				chi_button.pressed.emit()
				check(scene.offline_phase == "await_discard" and scene.current_seat == 0 and scene.players[0]["melds"].size() == 1 and scene.players[0]["hand"].size() == 11 and scene.offline_tile_ledger_report().get("ok", false), "the original native chi still commits its legal meld exactly once after rejection")
	await leave_and_drain(scene)


func check_corrupt_resolution_restore(scene: Node) -> void:
	for corrupt_kind in ["source_seat", "source_tile", "empty_source", "wrong_river", "valid_other_face"]:
		prepare_match(scene)
		scene.human_discard(0)
		var saved_state: Dictionary = scene.offline_progress_state_payload().duplicate(true)
		if corrupt_kind == "source_seat":
			saved_state["last_discard_seat"] = 4
		elif corrupt_kind == "source_tile":
			saved_state["last_discard"] = "invalid_discard_source"
		elif corrupt_kind == "empty_source":
			saved_state["last_discard"] = ""
		elif corrupt_kind == "wrong_river":
			saved_state["last_discard_seat"] = 1
		else:
			for candidate in scene.players[0]["hand"]:
				if str(candidate) != scene.last_discard:
					saved_state["last_discard"] = str(candidate)
					break
		var original := table_snapshot(scene)
		var generation: int = scene.offline_ai_run_generation
		var callback := pending_resolution(scene)
		check(not scene.restore_offline_progress_state(saved_state), "a conserved resolving save rejects unauthenticated %s ownership" % corrupt_kind)
		check(table_snapshot(scene) == original and scene.offline_ai_run_generation == generation and pending_resolution(scene) == callback, "rejected %s restore leaves the current table and legitimate pending resolver untouched" % corrupt_kind)
		await leave_and_drain(scene)


func check_revision_cache_isolation(scene: Node) -> void:
	prepare_match(scene)
	var saved_state: Dictionary = scene.offline_progress_state_payload().duplicate(true)
	check(scene.offline_progress_state_validation_error(saved_state) == "", "the validation cache is warmed by an authentic conserved save")
	var corrupt: Dictionary = saved_state.duplicate(true)
	corrupt["wall"].append(str(corrupt["wall"][0]))
	check(scene.offline_progress_state_validation_error(corrupt) != "", "equal-revision saves with changed inventory cannot reuse a valid cached result")
	var original := table_snapshot(scene)
	var generation: int = scene.offline_ai_run_generation
	check(not scene.restore_offline_progress_state(corrupt) and table_snapshot(scene) == original and scene.offline_ai_run_generation == generation, "rejecting an equal-revision corrupt save cannot clobber the live table or its owner")
	check(scene.offline_progress_state_validation_error(saved_state) == "" and scene.restore_offline_progress_state(saved_state) and scene.offline_tile_ledger_report().get("ok", false), "a cached corrupt verdict cannot poison an authentic equal-revision restore")
	await leave_and_drain(scene)


func run() -> void:
	print("=== offline input lifecycle smoke START ===")
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
	scene.offline_sim_quiet = false
	scene.tutorial_step = scene.TUTORIAL_STEP_COMPLETE
	scene.setup_tile_order()
	seed(298000)
	await check_different_tile_restart(scene)
	await check_same_tile_stale_resolver(scene)
	await check_old_native_button(scene)
	await check_exact_duplicate_copy(scene)
	await check_live_redraw_and_once(scene)
	await check_same_round_nonce(scene)
	await check_menu_and_same_id_restore(scene)
	await check_preferred_index_validation(scene)
	await check_duplicate_danger_confirmation(scene)
	await check_reopened_danger_controls(scene)
	await check_replacement_danger_controls(scene)
	await check_live_danger_actions(scene)
	await check_restored_action_bar(scene)
	await check_restored_claim_controls(scene)
	await check_rejected_claim_controls(scene)
	await check_saved_human_resolution(scene)
	await check_saved_bot_resolution(scene)
	await check_rejected_chi_controls(scene)
	await check_corrupt_resolution_restore(scene)
	await check_revision_cache_isolation(scene)
	await check_shutdown_resolver(scene)
	scene.shutdown_runtime()
	restore_smoke_state(scene, snapshot)
	scene.queue_free()
	await process_frame
	print("=== RESULT: %s ===" % ("FAIL" if failed else "OK"))
	quit(1 if failed else 0)
