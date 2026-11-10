extends "res://scripts/ui_guofeng_battle_smoke_test.gd"


func run() -> void:
	print("=== guofeng hand tray UI smoke START ===")
	var capture_root := OS.get_environment("YUNZHUO_GUOFENG_HAND_CAPTURE_DIR")
	if capture_root.is_empty():
		capture_root = "res://build/qa/guofeng_hand_tray"
	OS.set_environment("YUNZHUO_GUOFENG_BATTLE_CAPTURE_DIR", capture_root)
	await super.run()


func hand_capture_state(scene: Node) -> Dictionary:
	var state := battle_capture_state(scene)
	if scene.mode == "online_game":
		state["phase"] = str(scene.online_game.get("phase", ""))
		state["meld_count"] = scene.get_melds(0).size()
		state["hand_counts"] = []
		for player in scene.online_game.get("players", []):
			state["hand_counts"].append(int(player.get("handCount", 0)))
	state["pending_claim_visible"] = scene.has_pending_claim_window()
	state["river_history_targets"] = []
	for target in scene.find_children("DiscardRiverArchiveButton_*", "Button", true, false):
		if target.is_visible_in_tree():
			state["river_history_targets"].append({"name": str(target.name), "rect": advisor_reading_rect(target)})
	state["action_targets"] = []
	for target in scene.action_bar_buttons():
		if is_instance_valid(target) and target.is_visible_in_tree():
			state["action_targets"].append({"name": str(target.name), "rect": advisor_reading_rect(target)})
	var timer := scene.find_child("PendingClaimTimerArt", true, false) as Control
	state["pending_timer_rect"] = advisor_reading_rect(timer) if timer != null and timer.is_visible_in_tree() else []
	var wall_label := scene.find_child("TopHudWallText", true, false) as Label
	state["hud_wall_reading"] = {"text": wall_label.text, "rect": advisor_reading_rect(wall_label), "font_size": wall_label.get_theme_font_size("font_size")} if wall_label != null else {}
	state["hud_score_reading"] = []
	for seat in range(4):
		var wind := scene.find_child("ScoreStripName_%d" % seat, true, false) as Label
		var score := scene.find_child("ScoreStripScore_%d" % seat, true, false) as Label
		if wind != null and score != null:
			state["hud_score_reading"].append({"seat": seat, "wind": wind.text, "wind_rect": advisor_reading_rect(wind), "score": score.text, "score_rect": advisor_reading_rect(score), "font_size": score.get_theme_font_size("font_size")})
	state["meld_lanes"] = []
	for seat in range(4):
		var lane := scene.find_child("MeldArea_%d" % seat, true, false) as Control
		state["meld_lanes"].append({"seat": seat, "count": scene.get_melds(seat).size(), "rect": advisor_reading_rect(lane) if lane != null else []})
	var tray := scene.find_child("HandTray", true, false) as Control
	state["tray_surface"] = tray.get_meta("guofeng_surface_key", "") if tray != null else ""
	state["hand"] = scene.get_self_hand().duplicate()
	state["selection"] = scene.hand_keyboard_selection
	state["selected_tile"] = scene.hand_keyboard_selected_tile()
	state["tutorial_step"] = scene.tutorial_step
	state["tutorial_visible"] = scene.find_child("HandTrayTutorialHint", true, false) != null
	state["mode"] = scene.mode
	state["waiting_for_server"] = scene.online_waiting_for_server
	state["disconnected"] = scene.online_game_disconnected()
	state["redundant_wall_count"] = scene.find_child("WallRemainingBadgeText", true, false) != null
	state["labels"] = []
	for label_name in ["HandTrayStatusText", "HandTrayShortcutHint", "HandTrayStateBadge", "HandTrayTutorialHintText"]:
		var label := scene.find_child(label_name, true, false) as Label
		if label != null and label.is_visible_in_tree():
			var bounds := label.get_global_rect()
			state["labels"].append({"name": label_name, "text": label.text, "tooltip": label.tooltip_text, "font_size": label.get_theme_font_size("font_size"), "rect": [bounds.position.x, bounds.position.y, bounds.size.x, bounds.size.y]})
	state["tiles"] = []
	for tile_value in scene.find_children("HandTile_*", "Control", true, false):
		var tile := tile_value as Control
		var bounds := tile.get_global_rect()
		state["tiles"].append({"code": tile.get_meta("hand_tile_code", ""), "index": tile.get_meta("hand_source_index", -1), "keyboard_selected": tile.get_meta("keyboard_selected", false), "guide_target": tile.get_meta("guide_target", false), "focus_state": tile.get_meta("focus_state", ""), "rect": [bounds.position.x, bounds.position.y, bounds.size.x, bounds.size.y]})
	return state


func check_hand_surface(scene: Node) -> void:
	var tray := scene.find_child("HandTray", true, false) as Control
	var paper := scene.find_child("HandTrayPaper", true, false) as TextureRect
	var tile_lane := scene.find_child("HandTrayTiles", true, false) as Control
	check(tray != null and tile_lane != null, "hand tray has one real bitmap surface and its native tile lane")
	if tray == null or tile_lane == null:
		return
	check(paper != null and paper.texture is AtlasTexture and (paper.texture as AtlasTexture).atlas == scene.optional_gpt_illustration_texture("hand_tray_jiangnan_gpt") and paper.self_modulate == Color.WHITE, "hand tray keeps one untinted authored jade mat")
	check(scene.HAND_TRAY_RECT == Rect2(Vector2(0.185, 0.815), Vector2(0.985, 0.985)) and scene.HAND_TRAY_TILES_RECT == Rect2(Vector2(0.015, 0.270), Vector2(0.985, 0.982)), "hand surface and actual tile lane keep their established geometry")
	check(scene.find_child("WallRemainingBadge", true, false) == null and scene.find_child("WallDrawFeedbackArt", true, false) == null, "full battle does not hide duplicate wall text and ornament behind the top seat")
	var wall_label := scene.find_child("TopHudWallText", true, false) as Label
	check(wall_label != null and wall_label.text.contains("%d/%d" % [scene.get_wall_count(), scene.display_wall_total()]), "one native HUD owner shows the actual current wall count and total")
	var reading_labels: Array[Label] = []
	for label_name in ["HandTrayStatusText", "HandTrayShortcutHint", "HandTrayStateBadge", "HandTrayTutorialHintText"]:
		var label := scene.find_child(label_name, true, false) as Label
		if label == null or not label.is_visible_in_tree():
			continue
		reading_labels.append(label)
		var color := label.get_theme_color("font_color")
		var contrast_color := color.r <= 0.25 and color.g <= 0.35 and color.b <= 0.30 if label_name == "HandTrayTutorialHintText" else color.r >= 0.94 and color.g >= 0.90 and color.b >= 0.80
		check(color.a >= 0.99 and contrast_color and label.get_theme_constant("outline_size") == 0, "%s uses opaque native text contrasting with its paper hint or jade mat" % label_name)
		var text_fits := label_text_width(label, label.text) <= label.size.x + 1.0
		if label_name == "HandTrayTutorialHintText":
			text_fits = label.get_line_count() <= 2 and label.get_theme_font("font").get_height(label.get_theme_font_size("font_size")) * label.get_line_count() <= label.size.y + 1.0
		check(label.get_theme_font_size("font_size") >= 11 and label.size.y >= label.get_minimum_size().y and text_fits, "%s has enough real width and line height" % label_name)
		check(label.get_global_rect().end.y <= tile_lane.get_global_rect().position.y - 1.0, "%s stays outside native tile hit cells" % label_name)
		check(label.tooltip_text != "", "%s preserves its full state or shortcut meaning" % label_name)
	for first_index in range(reading_labels.size()):
		for second_index in range(first_index + 1, reading_labels.size()):
			check(not reading_labels[first_index].get_global_rect().intersects(reading_labels[second_index].get_global_rect()), "native hand reading slots remain separate")
	for retired in ["HandTray3DCastShadow", "HandTray3DFrontLip", "HandTray3DSideBevel", "HandGPTTrayTexture", "HandTrayTileGroundShadow", "HandTrayTileBackRail", "HandTrayTileBaseline", "HandTrayStateChip", "HandTraySuitFlow", "HandTrayMomentumArt", "HandTrayCompletionBusArt"]:
		check(tray.find_child(retired, true, false) == null, "hand tray does not restore retired ornament %s" % retired)
	var tiles := scene.find_children("HandTile_*", "Control", true, false)
	check(tiles.size() == scene.get_self_hand().size(), "every self hand tile keeps one native geometry owner")
	for tile_value in tiles:
		var tile := tile_value as Control
		check(tray.get_global_rect().grow(1.0).encloses(tile.get_global_rect()) and tile.modulate == Color.WHITE and tile.self_modulate == Color.WHITE, "%s remains bounded and untinted" % tile.name)
		if scene.effective_viewport_size().x >= 1600.0 and scene.effective_viewport_size().y >= 900.0 and scene.safe_content_pixel_size().y >= 1000.0:
			check(tile.size.x > 68.0 and tile.size.x <= 88.0, "%s uses the larger bounded wide-screen hand size" % tile.name)


func check_tutorial_clearance(scene: Node) -> void:
	var hint := scene.find_child("HandTrayTutorialHint", true, false) as Control
	var button := scene.find_child("HandTutorialSkipButton", true, false) as Button
	if button == null:
		button = scene.find_child("HandTutorialCompleteButton", true, false) as Button
	var dock := scene.find_child("ActionButtonDock", true, false) as Control
	check(hint != null and button != null and dock != null, "tutorial exposes its prompt, action and game action dock")
	if hint == null or button == null or dock == null:
		return
	check(not hint.get_global_rect().grow(-0.5).intersects(dock.get_global_rect().grow(-0.5)), "tutorial prompt clears the complete action dock")
	check(hint.get_global_rect().grow(0.5).encloses(button.get_global_rect()) and button.size.x >= 44.0 and button.size.y >= 44.0, "tutorial action stays inside its prompt with a full touch target")
	var chat := scene.find_child("ChatActionButton", true, false) as Control
	if chat != null and chat.is_visible_in_tree():
		check(not hint.get_global_rect().grow(-0.5).intersects(chat.get_global_rect().grow(-0.5)), "tutorial prompt and online chat entry have separate hit targets")


func prepare_hand_fixture(scene: Node) -> void:
	await prepare_offline_reading_fixture(scene)
	scene.ai_assist_enabled = false
	scene.show_hand_hint = false
	scene.hand_keyboard_selection = -1
	scene.tutorial_step = scene.TUTORIAL_STEP_COMPLETE
	scene.online_resume_pending = false
	scene.online_feedback = ""
	scene.online_waiting_for_server = false
	scene.offline_last_draw.clear()
	scene.ai_state_revision += 1
	scene.render_game()
	await settle()


func check_guofeng_battle_inputs(scene: Node, output_dir: String) -> void:
	await prepare_hand_fixture(scene)
	check_hand_surface(scene)
	await save_reading_capture(scene, output_dir, "hand_idle", hand_capture_state(scene))
	var tray := scene.find_child("HandTray", true, false) as Control
	var retained_id := tray.get_instance_id()
	scene.render_game()
	await settle()
	check(scene.find_child("HandTray", true, false).get_instance_id() == retained_id, "unchanged hand reuses its real paper and native input subtree")
	send_key(KEY_RIGHT, 0)
	await settle()
	check(scene.hand_keyboard_selection >= 0 and scene.hand_keyboard_selected_tile() != "", "real right-arrow input selects an actual tile")
	check_hand_surface(scene)
	await save_reading_capture(scene, output_dir, "hand_keyboard", hand_capture_state(scene))
	scene.wall.resize(18)
	scene.ai_state_revision += 1
	scene.render_game()
	await settle()
	check_hand_surface(scene)
	await save_reading_capture(scene, output_dir, "hand_low_wall", hand_capture_state(scene))
	await prepare_hand_fixture(scene)
	scene.offline_phase = "pending_claim"
	scene.offline_pending_claim = {"from_seat": 3, "tile": "3W", "options": ["peng", "chi"], "deadline_msec": Time.get_ticks_msec() + 18000}
	scene.render_game()
	await settle()
	check_hand_surface(scene)
	var response_keys := scene.find_child("HandTrayShortcutHint", true, false) as Label
	check(response_keys != null and response_keys.text.contains("过"), "pending hand preserves its real response shortcut explanation")
	await save_reading_capture(scene, output_dir, "hand_pending", hand_capture_state(scene))
	await prepare_hand_fixture(scene)
	scene.show_hand_hint = true
	scene.tutorial_step = scene.TUTORIAL_STEP_DISCARD
	scene.ai_assist_enabled = true
	scene.render_game()
	await settle()
	check_hand_surface(scene)
	check_tutorial_clearance(scene)
	var skip_button := scene.find_child("HandTutorialSkipButton", true, false) as Button
	var tutorial_target_count := 0
	for tile_value in scene.find_children("HandTile_*", "Control", true, false):
		if bool(tile_value.get_meta("guide_target", false)):
			tutorial_target_count += 1
	check(tutorial_target_count == 1, "tutorial highlights one actual authored hand tile rather than a fake target tile")
	check(skip_button != null and skip_button.size.x >= 44.0 and skip_button.size.y >= 44.0, "tutorial keeps its real skip hit target")
	await save_reading_capture(scene, output_dir, "hand_tutorial", hand_capture_state(scene))
	if skip_button != null:
		var position := skip_button.get_global_rect().get_center()
		send_left_button(position, true)
		send_left_button(position, false)
		await settle()
		check(scene.tutorial_step == scene.TUTORIAL_STEP_SKIPPED and scene.find_child("HandTrayTutorialHint", true, false) == null, "real tutorial skip click saves the checkpoint and removes the prompt")
	scene.show_hand_hint = true
	scene.tutorial_step = scene.TUTORIAL_STEP_WIN
	scene.render_game()
	await settle()
	check_hand_surface(scene)
	check_tutorial_clearance(scene)
	await save_reading_capture(scene, output_dir, "hand_tutorial_finish", hand_capture_state(scene))
	var finish_button := scene.find_child("HandTutorialCompleteButton", true, false) as Button
	check(finish_button != null and finish_button.size.y >= 44.0, "final tutorial checkpoint has its actual completion button")
	if finish_button != null:
		var position := finish_button.get_global_rect().get_center()
		send_screen_touch(position, true)
		send_screen_touch(position, false)
		await settle()
		check(scene.tutorial_step == scene.TUTORIAL_STEP_COMPLETE and not scene.show_hand_hint, "real touch completes the tutorial without changing a hand tile")
	scene.mode = "online_game"
	scene.online_game = online_pending_game_fixture()
	scene.online_game["phase"] = "awaitDiscard"
	scene.online_game["pending"] = {}
	scene.online_game_revision += 1
	scene.tcp = ConnectedLobbyTransport.new()
	scene.tcp_status = StreamPeerTCP.STATUS_CONNECTED
	scene.show_hand_hint = true
	scene.tutorial_step = scene.TUTORIAL_STEP_DISCARD
	scene.online_waiting_for_server = false
	scene.render_game()
	await settle()
	check_hand_surface(scene)
	check_tutorial_clearance(scene)
	await save_reading_capture(scene, output_dir, "hand_online_tutorial", hand_capture_state(scene))
	await activate_button(scene.find_child("ChatActionButton", true, false) as Button, "mouse")
	await settle()
	check(scene.chat_panel_open, "online chat opens while the tutorial is visible")
	await send_key(KEY_ESCAPE, 0)
	await settle()
	check(not scene.chat_panel_open, "online chat closes without dismissing the tutorial")
	await activate_button(scene.find_child("HandTutorialSkipButton", true, false) as Button, "touch")
	await settle()
	check(scene.tutorial_step == scene.TUTORIAL_STEP_SKIPPED and scene.find_child("HandTrayTutorialHint", true, false) == null, "online tutorial skip remains independently touchable")
	scene.online_waiting_for_server = true
	scene.render_game()
	await settle()
	check_hand_surface(scene)
	await save_reading_capture(scene, output_dir, "hand_online_waiting", hand_capture_state(scene))
	scene.online_waiting_for_server = false
	scene.online_feedback = "连接已断开，请重新连接。"
	scene.render_game()
	await settle()
	check_hand_surface(scene)
	check(not scene.can_self_discard() and scene.hand_shortcut_hint_text() == "", "disconnected hand keeps one read-only recovery line and no submission shortcuts")
	await save_reading_capture(scene, output_dir, "hand_online_disconnected", hand_capture_state(scene))
	await check_meld_hand_combinations(scene, output_dir)


func check_meld_hand_clearance(scene: Node, state_name: String, required_surface: String) -> void:
	var lane := scene.find_child("MeldArea_0", true, false) as Control
	var required := scene.find_child(required_surface, true, false) as Control
	check(lane != null and int(lane.get_meta("group_count", 0)) == 4, "%s renders all four self melds in its lane" % state_name)
	check(required != null and required.is_visible_in_tree(), "%s renders its expected state surface" % state_name)
	if lane == null:
		return
	var occupied: Array[Control] = []
	for child in lane.get_children():
		if child is Control and str(child.name).begins_with("MeldGroup_") and child.is_visible_in_tree():
			occupied.append(child)
	var pager := scene.find_child("MeldLaneArchiveButton_0", true, false) as Control
	if pager != null and pager.is_visible_in_tree():
		occupied.append(pager)
	check(not occupied.is_empty(), "%s exposes visible self melds or their pager" % state_name)
	for surface_name in ["HandTray", "HandTrayTutorialHint", "PendingClaimActionStack", "DangerDiscardConfirmationArt", "ActionButtonDock", "ChatActionButton"]:
		var surface := scene.find_child(surface_name, true, false) as Control
		if surface == null or not surface.is_visible_in_tree():
			continue
		for item in occupied:
			check(not item.get_global_rect().grow(-0.5).intersects(surface.get_global_rect().grow(-0.5)), "%s self meld %s clears %s" % [state_name, item.name, surface_name])


func transformed_bounds(control: Control) -> Rect2:
	var transform := control.get_global_transform()
	var bounds := Rect2(transform * Vector2.ZERO, Vector2.ZERO)
	for corner in [Vector2(control.size.x, 0.0), control.size, Vector2(0.0, control.size.y)]:
		bounds = bounds.expand(transform * corner)
	return bounds


func check_online_hud_readability(scene: Node) -> void:
	var wall := scene.find_child("TopHudWallText", true, false) as Label
	var expected_wall := "%d/%d" % [scene.get_wall_count(), scene.display_wall_total()]
	check(wall != null and wall.text.contains(expected_wall) and label_text_width(wall, wall.text) <= wall.size.x + 1.0, "online HUD keeps the complete live wall count visible")
	for seat in range(4):
		var wind := scene.find_child("ScoreStripName_%d" % seat, true, false) as Label
		var score := scene.find_child("ScoreStripScore_%d" % seat, true, false) as Label
		check(wind != null and score != null, "online HUD exposes wind and score for seat %d" % seat)
		if wind == null or score == null:
			continue
		check(wind.is_visible_in_tree() and wind.text == scene.seat_wind_label(seat) and label_text_width(wind, wind.text) <= wind.size.x + 1.0 and wind.size.y >= wind.get_minimum_size().y, "online HUD shows the complete wind for seat %d" % seat)
		check(score.is_visible_in_tree() and score.text == scene.compact_score_text(int(scene.get_player_info(seat).get("score", 0))) and label_text_width(score, score.text) <= score.size.x + 1.0 and score.size.y >= score.get_minimum_size().y, "online HUD shows the complete score and unit for seat %d" % seat)
		check(not wind.get_global_rect().grow(-0.5).intersects(score.get_global_rect().grow(-0.5)), "online HUD separates wind and score for seat %d" % seat)


func check_meld_hand_combinations(scene: Node, output_dir: String) -> void:
	var melds := [["1W", "1W", "1W"], ["2T", "3T", "4T"], ["5B", "5B", "5B"], ["R", "R", "R", "R"]]
	await prepare_hand_fixture(scene)
	scene.players[0]["melds"] = melds.duplicate(true)
	scene.show_hand_hint = true
	scene.tutorial_step = scene.TUTORIAL_STEP_DISCARD
	scene.render_game()
	await settle()
	check_meld_hand_clearance(scene, "tutorial with melds", "HandTrayTutorialHint")
	await save_reading_capture(scene, output_dir, "hand_meld_tutorial", hand_capture_state(scene))
	scene.show_hand_hint = false
	scene.tutorial_step = scene.TUTORIAL_STEP_COMPLETE
	scene.offline_phase = "pending_claim"
	scene.offline_pending_claim = {"from_seat": 3, "tile": "3W", "options": ["peng", "chi"], "deadline_msec": Time.get_ticks_msec() + 18000}
	scene.render_game()
	await settle()
	check_meld_hand_clearance(scene, "pending response with melds", "PendingClaimActionStack")
	await save_reading_capture(scene, output_dir, "hand_meld_pending", hand_capture_state(scene))
	scene.offline_phase = "await_discard"
	scene.offline_pending_claim.clear()
	scene.ai_assist_enabled = true
	scene.pending_danger_discard_index = 12
	scene.pending_danger_discard_tile = "E"
	scene.pending_danger_discard_report = {"tile": "E", "risk": 52.0, "feed_risk": 48.0, "risk_label": "高", "safety_label": "", "feed_text": "对家听口偏高", "danger_source": {"reason": "牌路危险", "seat": 2}}
	scene.render_game()
	await settle()
	check_meld_hand_clearance(scene, "danger confirmation with melds", "DangerDiscardConfirmationArt")
	await save_reading_capture(scene, output_dir, "hand_meld_danger", hand_capture_state(scene))
	scene.clear_pending_danger_discard()
	scene.mode = "online_game"
	scene.online_game = online_pending_game_fixture()
	scene.online_game["phase"] = "awaitDiscard"
	scene.online_game["pending"] = {}
	scene.online_game["wallCount"] = scene.online_game["wallTotal"]
	var river_stress := ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "2T", "3T", "4T", "5T", "6T", "7T", "8T", "9T", "1B", "2B", "3B", "4B", "5B", "6B", "7B", "8B", "9B", "E", "S", "W", "N", "Z", "F", "P", "R"]
	for player in scene.online_game["players"]:
		player["melds"] = melds.duplicate(true)
		player["discards"] = river_stress.duplicate()
	scene.online_game["lastDiscard"] = "R"
	scene.online_game_revision += 1
	scene.online_waiting_for_server = false
	scene.online_resume_pending = false
	scene.online_feedback = ""
	scene.tcp = ConnectedLobbyTransport.new()
	scene.tcp_status = StreamPeerTCP.STATUS_CONNECTED
	scene.chat_messages.clear()
	scene.render_game()
	await settle()
	check(not scene.online_game_disconnected(), "meld online fixture is connected")
	check_meld_hand_clearance(scene, "connected with melds", "ChatActionButton")
	check_online_hud_readability(scene)
	scene.online_game["wallCount"] = 107
	scene.online_game_revision += 1
	scene.refresh_battle_hud_lane()
	await settle()
	check_online_hud_readability(scene)
	scene.online_game["wallCount"] = scene.online_game["wallTotal"]
	scene.online_game_revision += 1
	scene.refresh_battle_hud_lane()
	await settle()
	var self_lane := scene.find_child("MeldArea_0", true, false) as Control
	if scene.effective_viewport_size() in [Vector2(960, 540), Vector2(1280, 720)]:
		check(self_lane != null and int(self_lane.get_meta("visible_group_count", 0)) >= 2, "connected self seat shows at least two complete melds")
	check(scene.get_wall_count() == scene.display_wall_total(), "online meld fixture keeps a full wall")
	await save_reading_capture(scene, output_dir, "hand_meld_connected", hand_capture_state(scene))
	for modality in ["mouse", "touch", "key"]:
		var lane_before := scene.find_child("MeldArea_0", true, false) as Control
		var pager := scene.find_child("MeldLaneArchiveButton_0", true, false) as Button
		if lane_before != null and int(lane_before.get_meta("page_count", 1)) == 1:
			check(pager == null, "online self melds omit paging when all groups fit")
			break
		if lane_before == null or pager == null:
			check(false, "online self meld pager is available for %s" % modality)
			continue
		var previous_start := int(lane_before.get_meta("window_start", -1))
		var capacity := int(lane_before.get_meta("lane_capacity", 1))
		var last_start := maxi(0, melds.size() - capacity)
		await activate_button(pager, modality)
		await settle()
		var lane_after := scene.find_child("MeldArea_0", true, false) as Control
		var expected_start := 0 if previous_start >= last_start else mini(last_start, previous_start + capacity)
		check(lane_after != null and int(lane_after.get_meta("window_start", -1)) == expected_start, "online self meld pager accepts real %s input" % modality)
		if modality == "key":
			var restored := scene.find_child("MeldLaneArchiveButton_0", true, false) as Button
			check(restored != null and restored.has_focus(), "online keyboard paging restores the pager focus")
		check_meld_hand_clearance(scene, "online meld page after " + modality, "ChatActionButton")
	var chat_button := scene.find_child("ChatActionButton", true, false) as Button
	if chat_button != null:
		check(chat_button.size.x >= 44.0 and chat_button.size.y >= 44.0, "online chat retains its full touch target")
		for wall_value in scene.find_children("WallTileBack_*", "TextureRect", true, false):
			var wall := wall_value as Control
			if wall.is_visible_in_tree():
				check(not chat_button.get_global_rect().grow(-0.5).intersects(wall.get_global_rect().grow(-0.5)), "online chat clears visible wall tile %s" % wall.name)
		await activate_button(chat_button, "mouse")
		await settle()
		var chat_panel := scene.find_child("ChatPanel", true, false) as Control
		check(scene.chat_panel_open and chat_panel != null and chat_panel.is_visible_in_tree(), "four-seat meld fixture opens chat through its real button")
		if chat_panel != null:
			for seat in range(4):
				var lane := scene.find_child("MeldArea_%d" % seat, true, false) as Control
				check(lane != null and not chat_panel.get_global_rect().grow(-1.0).intersects(lane.get_global_rect()), "four-seat meld chat clears seat %d melds" % seat)
				var seat_panel := scene.find_child("SeatPanel_%d" % seat, true, false) as Control
				check(seat_panel != null and not chat_panel.get_global_rect().grow(-1.0).intersects(seat_panel.get_global_rect()), "four-seat meld chat clears seat %d identity" % seat)
			var body := scene.find_child("ChatPanelBodyScroll", true, false) as ScrollContainer
			var send := scene.find_child("ChatSendButton", true, false) as Button
			check(body != null and send != null and scene.chat_input != null and body.get_global_rect().grow(1.0).encloses(send.get_global_rect()) and body.get_global_rect().grow(1.0).encloses(scene.chat_input.get_global_rect()), "four-seat meld chat keeps its full input and send targets visible")
			var preview := scene.find_child("ChatPanelLatestPreview", true, false) as Label
			var messages := scene.find_child("ChatPanelMessageText", true, false) as Label
			check(preview != null and preview.text == "等待房间消息" and messages != null and messages.text.is_empty(), "empty chat displays one waiting message")
			await save_reading_capture(scene, output_dir, "hand_meld_chat_open", hand_capture_state(scene))
			if scene.chat_input != null:
				var writes_before: int = scene.tcp.writes.size()
				scene.chat_input.text = "牌桌消息验证"
				scene.chat_input.grab_focus()
				await send_key(KEY_ENTER, 0)
				await settle(0.08)
				var sent: Variant = JSON.parse_string(str(scene.tcp.writes.back())) if scene.tcp.writes.size() > writes_before else null
				check(scene.tcp.writes.size() == writes_before + 1 and typeof(sent) == TYPE_DICTIONARY and sent.get("type", "") == "chat", "four-seat meld chat sends exactly one real chat request")
				check(preview != null and preview.text.contains("牌桌消息验证") and messages != null and messages.text.contains("牌桌消息验证"), "chat preview and history update after sending")
		await send_key(KEY_ESCAPE, 0)
		await settle()
		check(not scene.chat_panel_open, "four-seat meld chat closes with Escape")
	for visible_seats in [[0], [3], [0, 3]]:
		for seat in range(4):
			scene.online_game["players"][seat]["melds"] = melds.duplicate(true) if visible_seats.has(seat) else []
		scene.online_game_revision += 1
		scene.render_game()
		await settle()
		await activate_button(scene.find_child("ChatActionButton", true, false) as Button, "mouse")
		await settle()
		var panel := scene.find_child("ChatPanel", true, false) as Control
		check(panel != null and scene.chat_panel_open, "chat opens with meld seats %s" % str(visible_seats))
		if panel != null:
			for seat in visible_seats:
				var lane := scene.find_child("MeldArea_%d" % seat, true, false) as Control
				check(lane != null and not panel.get_global_rect().grow(-1.0).intersects(lane.get_global_rect()), "chat clears active meld seat %d in %s" % [seat, str(visible_seats)])
		await send_key(KEY_ESCAPE, 0)
		await settle()
	for player in scene.online_game["players"]:
		player["melds"] = melds.duplicate(true)
	var left_pager_before := scene.find_child("MeldLaneArchiveButton_3", true, false) as Button
	var left_pager_before_rect := left_pager_before.get_global_rect() if left_pager_before != null else Rect2()
	scene.online_game["phase"] = "pendingClaim"
	scene.online_game["pending"] = online_pending_game_fixture()["pending"].duplicate(true)
	scene.online_game_revision += 1
	scene.render_game()
	await settle()
	check_meld_hand_clearance(scene, "online pending response with melds", "PendingClaimActionStack")
	var right_meld_lane := scene.find_child("MeldArea_1", true, false) as Control
	var pending_dock := scene.find_child("ActionButtonDock", true, false) as Control
	check(right_meld_lane != null and pending_dock != null, "pending response exposes right melds and action dock")
	if right_meld_lane != null and pending_dock != null:
		for group_value in right_meld_lane.get_children():
			var group := group_value as Control
			if group != null and str(group.name).begins_with("MeldGroup_") and group.is_visible_in_tree():
				check(not transformed_bounds(group).grow(-0.5).intersects(transformed_bounds(pending_dock).grow(-0.5)), "pending response dock clears right meld %s" % group.name)
		for wall_value in scene.find_children("WallTileBack_*", "TextureRect", true, false):
			var wall := wall_value as Control
			if wall.is_visible_in_tree():
				check(not transformed_bounds(wall).grow(-0.5).intersects(transformed_bounds(pending_dock).grow(-0.5)), "pending response dock clears wall %s" % wall.get_path())
	for archive_value in scene.find_children("DiscardRiverArchiveButton_*", "Button", true, false):
		var archive := archive_value as Button
		if not archive.is_visible_in_tree():
			continue
		var archive_label := archive.find_child("DiscardRiverArchiveLabel_*", true, false) as Label
		check(archive_label != null, "river history %s exposes its visible action label" % archive.name)
		if archive_label != null:
			for line in archive_label.text.split("\n"):
				check(label_text_width(archive_label, line) <= archive_label.size.x + 0.5, "river history %s displays its complete action line %s" % [archive.name, line])
			check(archive_label.size.y + 0.5 >= archive_label.get_minimum_size().y, "river history %s displays every action row" % archive.name)
		for action_value in scene.action_bar_buttons():
			var action := action_value as Button
			if action != null and action.is_visible_in_tree():
				check(not transformed_bounds(archive).grow(-0.5).intersects(transformed_bounds(action).grow(-0.5)), "pending action %s clears river history %s" % [action.name, archive.name])
	var pending_timer := scene.find_child("PendingClaimTimerArt", true, false) as Control
	check(pending_timer != null and pending_timer.is_visible_in_tree(), "online pending response shows its countdown")
	var left_pager_pending := scene.find_child("MeldLaneArchiveButton_3", true, false) as Button
	if left_pager_before_rect != Rect2() and left_pager_pending != null:
		check(left_pager_pending.get_global_rect().position.y > left_pager_before_rect.position.y, "pending response moves the left meld pager below its seat")
		var left_lane_before := scene.find_child("MeldArea_3", true, false) as Control
		var previous_left_start := int(left_lane_before.get_meta("window_start", -1)) if left_lane_before != null else -1
		await activate_button(left_pager_pending, "touch")
		await settle()
		var left_lane_after := scene.find_child("MeldArea_3", true, false) as Control
		check(left_lane_after != null and int(left_lane_after.get_meta("window_start", -1)) != previous_left_start, "relocated left meld pager accepts a real touch during response")
		pending_timer = scene.find_child("PendingClaimTimerArt", true, false) as Control
	if pending_timer != null:
		for pattern in ["WallTileBack_*", "SeatPanel_*", "MeldLaneArchiveButton_*", "DiscardRiverArchiveButton_*", "PendingClaimIllustration", "PendingClaimActionStack", "HandTray"]:
			for obstacle_value in scene.find_children(pattern, "Control", true, false):
				var obstacle := obstacle_value as Control
				if obstacle.is_visible_in_tree():
					check(not transformed_bounds(pending_timer).grow(-0.5).intersects(transformed_bounds(obstacle).grow(-0.5)), "online countdown clears %s" % obstacle.name)
		for seat in range(4):
			var lane := scene.find_child("MeldArea_%d" % seat, true, false) as Control
			if lane == null:
				continue
			for group_value in lane.get_children():
				var group := group_value as Control
				if group != null and str(group.name).begins_with("MeldGroup_") and group.is_visible_in_tree():
					check(not pending_timer.get_global_rect().grow(-0.5).intersects(group.get_global_rect().grow(-0.5)), "online countdown clears seat %d meld %s" % [seat, group.name])
		for label_name in ["PendingClaimTimerText", "PendingClaimAutoPassWarning"]:
			var label := scene.find_child(label_name, true, false) as Label
			if label == null:
				check(false, "online countdown contains %s" % label_name)
			else:
				check(label_text_width(label, label.text) <= label.size.x + 1.0 and label.size.y >= label.get_minimum_size().y, "online countdown displays complete %s (text=%s width=%.1f available=%.1f font=%d height=%.1f minimum=%.1f)" % [label_name, label.text, label_text_width(label, label.text), label.size.x, label.get_theme_font_size("font_size"), label.size.y, label.get_minimum_size().y])
	await save_reading_capture(scene, output_dir, "hand_meld_online_pending", hand_capture_state(scene))
	var right_seen := {}
	var right_page_count := int(right_meld_lane.get_meta("page_count", 1)) if right_meld_lane != null else 0
	for page in range(right_page_count):
		right_meld_lane = scene.find_child("MeldArea_1", true, false) as Control
		pending_dock = scene.find_child("ActionButtonDock", true, false) as Control
		if right_meld_lane == null or pending_dock == null:
			check(false, "pending right meld page %d keeps its lane and action dock" % (page + 1))
			break
		for group_value in right_meld_lane.get_children():
			var group := group_value as Control
			if group == null or not str(group.name).begins_with("MeldGroup_") or not group.is_visible_in_tree():
				continue
			var group_index := int(str(group.name).get_slice("_", 1))
			var tiles := group.find_child("MeldTiles", true, false) as Control
			check(group_index >= 0 and group_index < melds.size() and tiles != null, "pending right page shows a valid meld")
			if group_index < 0 or group_index >= melds.size() or tiles == null:
				continue
			right_seen[group_index] = true
			check(right_meld_lane.get_global_rect().grow(1.0).encloses(group.get_global_rect()) and not transformed_bounds(group).grow(-0.5).intersects(transformed_bounds(pending_dock).grow(-0.5)), "pending right meld %d stays in its lane and clears the action dock" % group_index)
			check(tiles.get_child_count() == (melds[group_index] as Array).size(), "pending right meld %d includes every tile" % group_index)
			for tile_index in range(mini(tiles.get_child_count(), (melds[group_index] as Array).size())):
				var holder := tiles.get_child(tile_index) as Control
				var tile := holder.get_child(0) as Control if holder != null and holder.get_child_count() > 0 else null
				var code := str(scene.normalize_tile_code(str(melds[group_index][tile_index])))
				var face := tile.get_meta("tile_face_texture", null) as TextureRect if tile != null else null
				check(tile != null and str(tile.get_meta("normalized_tile_code", "")) == code and face != null and face.texture == scene.tile_textures.get(code) and absf(tile.rotation - scene.seat_meld_face_rotation(1)) <= 0.001, "pending right meld %d tile %d retains its face and direction" % [group_index, tile_index])
		if scene.effective_viewport_size() == Vector2(960, 540) and scene.large_text_enabled:
			await save_reading_capture(scene, output_dir, "hand_meld_online_pending_right_page_%d" % (page + 1), hand_capture_state(scene))
		if right_page_count > 1:
			var right_pager := scene.find_child("MeldLaneArchiveButton_1", true, false) as Button
			check(right_pager != null, "pending right meld page has a navigation button")
			if right_pager == null:
				break
			await activate_button(right_pager, ["mouse", "touch", "key"][page % 3])
			await settle()
	check(right_seen.size() == melds.size(), "pending right meld pagination reaches every complete public group")
	right_meld_lane = scene.find_child("MeldArea_1", true, false) as Control
	check(right_meld_lane != null and int(right_meld_lane.get_meta("window_start", -1)) == 0, "pending right meld pagination returns to the first page")
	scene.online_game["pending"]["deadline_msec"] = Time.get_ticks_msec() + 60000
	scene.online_game_revision += 1
	scene.render_game()
	await settle()
	var live_timer := scene.find_child("PendingClaimTimerText", true, false) as Label
	check(live_timer != null and live_timer.text.contains("秒") and label_text_width(live_timer, live_timer.text) <= live_timer.size.x + 1.0, "online countdown shows the complete live seconds with melds")
	scene.online_game["pending"]["deadline_msec"] = Time.get_ticks_msec() + 2200
	scene.online_game_revision += 1
	scene.update_pending_claim_live_state()
	await settle()
	var final_warning := scene.find_child("PendingClaimAutoPassWarning", true, false) as Label
	check(live_timer != null and live_timer.text.contains("秒") and final_warning != null and final_warning.text.contains("将自动过") and label_text_width(final_warning, final_warning.text) <= final_warning.size.x + 1.0, "online final seconds and auto-pass warning remain fully visible with melds")
	scene.online_game["pending"]["deadline_msec"] = Time.get_ticks_msec() + 60000
	scene.online_game_revision += 1
	scene.render_game()
	await settle()
	var primary := scene.find_child("PendingClaimPrimaryButton", true, false) as Button
	var writes_before_claim: int = scene.tcp.writes.size()
	await activate_button(primary, "mouse")
	await settle()
	var claim_payload: Variant = JSON.parse_string(str(scene.tcp.writes.back())) if scene.tcp.writes.size() > writes_before_claim else null
	check(scene.tcp.writes.size() == writes_before_claim + 1 and typeof(claim_payload) == TYPE_DICTIONARY and claim_payload.get("type", "") == "claim" and claim_payload.get("claim", "") == "hu", "online primary response sends exactly one claim from its real hit target")
	scene.online_waiting_for_server = false
	scene.online_game["phase"] = "awaitDiscard"
	scene.online_game["pending"] = {}
	scene.online_game_revision += 1
	scene.render_game()
	await settle()
	var left_pager_restored := scene.find_child("MeldLaneArchiveButton_3", true, false) as Button
	if left_pager_before_rect != Rect2():
		check(left_pager_restored != null and left_pager_restored.get_global_rect().position.distance_to(left_pager_before_rect.position) <= 1.0, "left meld pager returns to its normal position after response")
	scene.online_feedback = "连接已断开，请重新连接。"
	scene.render_game()
	await settle()
	check(scene.online_game_disconnected(), "meld recovery fixture is actually disconnected")
	check_meld_hand_clearance(scene, "disconnected with melds", "HandTray")
	await save_reading_capture(scene, output_dir, "hand_meld_disconnected", hand_capture_state(scene))
