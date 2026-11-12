extends "res://scripts/ui_battle_reading_evidence_smoke_test.gd"


func advisor_obstacles(scene: Node) -> Array:
	var obstacles: Array = []
	for seat in range(4):
		for node_name in ["SeatPanel_%d" % seat, "MeldArea_%d" % seat, "OpponentHand_%d" % seat]:
			var control := scene.find_child(node_name, true, false) as Control
			if control != null and control.is_visible_in_tree() and (node_name.begins_with("SeatPanel") or node_name.begins_with("OpponentHand") or not scene.get_melds(seat).is_empty()):
				obstacles.append({"name": node_name, "rect": advisor_reading_rect(control)})
	var table := scene.find_child("OfflineTable3DInnerSurface", true, false)
	if table != null:
		for node in table.get_children():
			var strip := node as Control
			if strip == null or not str(strip.name).begins_with("WallBackStrip") or not strip.is_visible_in_tree() or strip.modulate.a <= 0.01:
				continue
			for face_node in strip.get_children():
				var wall_face := face_node as TextureRect
				if wall_face == null or not wall_face.is_visible_in_tree():
					continue
				obstacles.append({"name": "%s/%s" % [strip.name, wall_face.name], "rect": advisor_reading_rect(wall_face)})
	return obstacles


func check_advisor_obstacles(scene: Node) -> void:
	var panel := scene.find_child("AdvisorPanel", true, false) as Control
	if panel == null or not panel.is_visible_in_tree():
		return
	for obstacle in advisor_obstacles(scene):
		var bounds: Array = obstacle["rect"]
		var occupied := Rect2(Vector2(bounds[0], bounds[1]), Vector2(bounds[2], bounds[3]))
		check(not panel.get_global_rect().intersects(occupied.grow(5.5)), "advisor keeps six pixels clear of actual %s" % obstacle["name"])
	var name := scene.find_child("SeatCompactName_0", true, false) as Label
	check(name != null and not name.text.is_empty() and name.is_visible_in_tree(), "self seat retains its actual visible native identity")


func battle_capture_state(scene: Node) -> Dictionary:
	var focused := root.gui_get_focus_owner()
	var wall_state := scene.find_child("TopHudWallState", true, false) as Label
	var hud := scene.find_child("TopHud3DShell", true, false) as Control
	var center := scene.find_child("CenterConsole3DShell", true, false) as Control
	var center_wall_state := scene.find_child("CenterWallStatusLabel", true, false) as Label
	var ledger := scene.find_child("TableLogLedgerPanel", true, false) as Control
	var advisor := scene.find_child("AdvisorPanel", true, false) as Control
	var self_name := scene.find_child("SeatCompactName_0", true, false) as Label
	var state := {"hud_surface_key": hud.get_meta("guofeng_surface_key", "") if hud != null else "", "center_surface_key": center.get_meta("guofeng_surface_key", "") if center != null else "", "ledger_surface_key": ledger.get_meta("guofeng_surface_key", "") if ledger != null else "", "ledger_visible": ledger.is_visible_in_tree() if ledger != null else false, "wall_count": scene.get_wall_count(), "wall_total": scene.display_wall_total(), "wall_state": wall_state.text if wall_state != null else "", "center_wall_state": center_wall_state.text if center_wall_state != null else "", "phase": scene.offline_phase, "hand_number": scene.offline_hand_number, "meld_count": scene.players[0]["melds"].size(), "focused_control": str(focused.name) if focused != null else "", "advisor_visible": advisor != null and advisor.is_visible_in_tree(), "advisor_rect": advisor_reading_rect(advisor) if advisor != null else [], "advisor_layout_mode": advisor.get_meta("advisor_layout_mode", "") if advisor != null else "", "advisor_obstacles": advisor_obstacles(scene), "self_name": self_name.text if self_name != null else ""}
	state["ledger_rect"] = advisor_reading_rect(ledger) if ledger != null else []
	state["hand_counts"] = [scene.players[0]["hand"].size(), scene.players[1]["hand"].size(), scene.players[2]["hand"].size(), scene.players[3]["hand"].size()]
	var top_seat := scene.find_child("SeatPanel_2", true, false) as Control
	state["top_seat_rect"] = advisor_reading_rect(top_seat) if top_seat != null else []
	state["top_seat_layout_mode"] = top_seat.get_meta("seat_layout_mode", "") if top_seat != null else ""
	state["opponent_hands"] = []
	for seat in [1, 2, 3]:
		var host := scene.find_child("OpponentHand_%d" % seat, true, false) as Control
		var visible_count := 0
		if host != null:
			for face in host.get_children():
				if face is TextureRect and (face as TextureRect).is_visible_in_tree():
					visible_count += 1
		state["opponent_hands"].append({"seat": seat, "visible_bitmap_count": visible_count, "rect": advisor_reading_rect(host) if host != null else []})
	state["visible_wall_bitmap_count"] = scene.find_children("WallTileBack_*", "TextureRect", true, false).filter(func(face: TextureRect) -> bool: return face.is_visible_in_tree()).size()
	return state


func check_native_paper_label(scene: Node, node_name: String, minimum_size: int) -> void:
	var label := scene.find_child(node_name, true, false) as Label
	check(label != null, "%s has a real native reading owner" % node_name)
	if label == null:
		return
	var color := label.get_theme_color("font_color")
	check(color.a >= 0.99 and color.r <= 0.25 and color.g <= 0.35 and color.b <= 0.30 and label.get_theme_constant("outline_size") == 0, "%s keeps dark ink without a light outline in both reading profiles" % node_name)
	check(label.get_theme_font_size("font_size") >= scene.accessibility_font_size(minimum_size) and label.size.y >= label.get_minimum_size().y, "%s preserves its requested accessible size and full line height (font=%d required=%d height=%.2f minimum=%.2f)" % [node_name, label.get_theme_font_size("font_size"), scene.accessibility_font_size(minimum_size), label.size.y, label.get_minimum_size().y])
	check(label_text_width(label, label.text) <= label.size.x + 1.0, "%s displays its complete factual text without clipping" % node_name)


func check_battle_surfaces(scene: Node) -> void:
	var hud := scene.find_child("TopHud3DShell", true, false) as TextureRect
	var center := scene.find_child("CenterConsole3DShell", true, false) as TextureRect
	var ledger := scene.find_child("TableLogLedgerPanel", true, false) as TextureRect
	check(hud != null and center != null and ledger != null, "battle has authored HUD, center and ledger bitmap surfaces")
	if ledger != null and ledger.is_visible_in_tree():
		for obstacle in advisor_obstacles(scene):
			if not str(obstacle["name"]).begins_with("WallBackStrip"):
				continue
			var bounds: Array = obstacle["rect"]
			var face := Rect2(Vector2(bounds[0], bounds[1]), Vector2(bounds[2], bounds[3]))
			var clearance := 8.0 if str(obstacle["name"]).begins_with("WallBackStrip_h_16_0") else 4.0
			check(not ledger.get_global_rect().intersects(face.grow(clearance - 0.5)), "ledger keeps %d pixels clear of actual %s" % [int(clearance), obstacle["name"]])
	for entry in [[hud, "battle_hud_jiangnan_gpt"], [center, "battle_ink_plaque_20261112"], [ledger, "menu_card_readable_gpt"]]:
		var surface := entry[0] as TextureRect
		if surface != null:
			var source: Texture2D = surface.texture
			var edges := surface.get_node_or_null("AuthoredBitmapEdges") as NinePatchRect
			if source == null and edges != null:
				source = edges.texture
			if source != scene.optional_gpt_illustration_texture(entry[1]) and source is AtlasTexture:
				source = (source as AtlasTexture).atlas
			check(surface.get_meta("guofeng_surface_key", "") == entry[1] and source == scene.optional_gpt_illustration_texture(entry[1]) and surface.self_modulate == Color.WHITE, "each battle reading surface uses its declared authored bitmap without tinting")
	for retired_name in ["TopHud3DCastShadow", "TopHud3DDepthEdge", "TopHud3DTopRim", "TopHud3DJadeRail", "TopHudTitleBack", "TopHudStatusBack", "TopHudWallBack", "TopHudWallMeter", "TopHudStatusArt", "HandProgressRail", "HandProgressWallSyncRoute", "CenterConsole3DCastShadow", "CenterConsole3DDepthEdge", "CenterConsoleTopLight", "CenterGPTCompassTexture", "TableLogLedgerSpine"]:
		check(scene.find_child(retired_name, true, false) == null, "battle does not rebuild retired decoration %s" % retired_name)
	for node_name in ["TopHudModeBadge", "TopHudTitle", "TopHudStatus", "TopHudWallText", "TopHudWallState", "HandProgressLabel", "HandProgressDealerLabel"]:
		var minimum_size := 10 if node_name == "TopHudWallState" else 11 if node_name in ["TopHudModeBadge", "HandProgressDealerLabel"] else 12 if node_name == "HandProgressLabel" else 14 if node_name == "TopHudWallText" else 15
		check_native_paper_label(scene, node_name, minimum_size)
		var label := scene.find_child(node_name, true, false) as Label
		if label != null and hud != null:
			check(hud.get_global_rect().grow(1.0).encloses(label.get_global_rect()), "%s stays inside the single HUD paper surface" % node_name)
	var title := scene.find_child("TopHudTitle", true, false) as Label
	var status := scene.find_child("TopHudStatus", true, false) as Label
	var progress := scene.find_child("HandProgressLabel", true, false) as Label
	if title != null and status != null and progress != null:
		check(not title.get_global_rect().intersects(status.get_global_rect()) and not status.get_global_rect().intersects(progress.get_global_rect()) and not title.get_global_rect().intersects(progress.get_global_rect()), "round title, phase and match facts have separate actual reading lanes")
	for node_name in ["CenterWallStatusLabel", "CenterWallCount", "CenterLastDiscardLabel"]:
		var label := scene.find_child(node_name, true, false) as Label
		if node_name == "CenterLastDiscardLabel" and scene.get_last_discard().is_empty():
			check(label == null and scene.find_child("CenterLastDiscardTile", true, false) == null, "a freshly dealt table correctly has no last-discard caption or tile")
			continue
		check(label != null and label.get_theme_color("font_color").a >= 0.99 and label.get_theme_color("font_color").r >= 0.95, "%s stays fully opaque on the authored ink center" % node_name)
	var center_count := scene.find_child("CenterWallCount", true, false) as Label
	check(center_count != null and center_count.text == str(scene.get_wall_count()) and center_count.tooltip_text.contains("/%d" % scene.display_wall_total()), "center count retains the same live wall fact and complete total")
	check(scene.find_child("CenterWindGPTCompassArt", true, false) == null and scene.find_child("CenterLastTileTrace", true, false) == null and scene.find_child("CenterLastDiscardFeedback", true, false) == null, "live center facts have no painted compass or persistent feedback routes behind them")
	var dealer := scene.find_child("CenterDiceSimpleGlyph", true, false) as Label
	check(dealer != null and dealer.text == "庄·%s" % scene.seat_wind_label(scene.dealer_seat), "the center dealer caption names this round's actual dealer")
	var center_caption := scene.find_child("CenterWallStatusLabel", true, false) as Label
	var center_last := scene.find_child("CenterLastDiscardLabel", true, false) as Label
	if center_count != null and center_caption != null and center_last != null:
		check(not center_count.get_global_rect().intersects(center_caption.get_global_rect()) and not center_count.get_global_rect().intersects(center_last.get_global_rect()), "the larger wall number has a complete separate lane between its caption and last discard")
	for seat in range(4):
		var wind := scene.find_child("CenterWindLabel_%s" % scene.CENTER_WIND_LABELS[seat], true, false) as Label
		check(wind != null and wind.get_theme_color("font_color").a >= 0.99 and bool(wind.get_meta("active_seat", false)) == (seat == scene.get_current_seat()), "wind seat %d preserves legible native text and current-seat semantics" % seat)


func check_guofeng_battle_inputs(scene: Node, output_dir: String) -> void:
	# Start through the production entry/deal, before artificial reading fixtures.
	# The supervisor isolates user data and this smoke restores its original state.
	scene.reset_offline_progress()
	scene.start_offline(true)
	scene.cancel_offline_ai_run()
	await settle()
	for seat in range(4):
		check(scene.players[seat]["hand"].size() >= 13, "production deal retains the actual hand of seat %d" % seat)
	for seat in [1, 2, 3]:
		var host := scene.find_child("OpponentHand_%d" % seat, true, false) as Control
		check(host != null and host.get_child_count() == scene.players[seat]["hand"].size(), "production opponent %d renders every concealed back" % seat)
		if host != null:
			var live_hud := scene.find_child("TopHud3DShell", true, false) as Control
			check(live_hud != null and not host.get_global_rect().intersects(live_hud.get_global_rect().grow(1.5)), "opponent %d keeps its visible backs clear of the actual accessible HUD" % seat)
			for back_node in host.get_children():
				check(back_node is TextureRect and (back_node as TextureRect).texture == scene.tile_back and (back_node as TextureRect).is_visible_in_tree() and (back_node as TextureRect).modulate == Color.WHITE and (back_node as TextureRect).self_modulate == Color.WHITE, "opponent %d uses a visible original untinted 2D back" % seat)
			if seat == 2 and live_hud != null:
				check(host.get_global_rect().position.y >= live_hud.get_global_rect().end.y + 3.9, "top concealed backs keep four pixels below the actual HUD")
				for face_node in scene.find_children("WallTileBack_*", "TextureRect", true, false):
					var face := face_node as TextureRect
					if face.is_visible_in_tree() and str(face.get_parent().name).ends_with("_0"):
						check(face.get_global_rect().position.y >= host.get_global_rect().end.y + 3.9, "top concealed backs keep four pixels above the actual upper wall")
	for strip_node in scene.find_children("WallBackStrip_h_*", "Control", true, false):
		var previous_face: TextureRect = null
		for face_node in strip_node.get_children():
			var face := face_node as TextureRect
			if face == null or not face.is_visible_in_tree():
				continue
			if previous_face != null and root.size.x >= 1600:
				var gap := face.get_global_rect().position.x - previous_face.get_global_rect().end.x
				check(gap <= face.get_global_rect().size.x / 3.0 + 0.1 and gap >= 0.0, "horizontal original wall backs stay separate with at most one-third-face gaps")
			previous_face = face
	check(not scene.find_children("WallTileBack_*", "TextureRect", true, false).is_empty(), "production wall has actual bitmap children, beyond layout metadata")
	check_battle_surfaces(scene)
	check_advisor_obstacles(scene)
	var live_state := battle_capture_state(scene)
	live_state["evidence_origin"] = "production_start_offline_and_deal"
	await save_reading_capture(scene, output_dir, "battle_live_four_seats", live_state)
	# Public-count reading fixtures cover the visible reductions after melds and
	# the temporary extra drawn tile. They are not a replay of the production deal.
	var public_melds := [["1W", "1W", "1W"], ["2T", "3T", "4T"], ["5B", "5B", "5B"], ["R", "R", "R", "R"]]
	for case_data in [{"name": "battle_hand_counts_mid", "counts": [10, 7, 4], "melds": [1, 2, 3]}, {"name": "battle_hand_counts_late", "counts": [1, 2, 14], "melds": [4, 4, 0]}]:
		for index in range(3):
			var seat: int = index + 1
			var count: int = int(case_data["counts"][index])
			var hand: Array = scene.players[seat]["hand"]
			while hand.size() < count:
				hand.append("E")
			hand.resize(count)
			scene.players[seat]["melds"] = public_melds.slice(0, int(case_data["melds"][index])).duplicate(true)
		scene.ai_state_revision += 1
		scene.clear_ai_report_cache()
		scene.render_game()
		await settle()
		for seat in [1, 2, 3]:
			var host := scene.find_child("OpponentHand_%d" % seat, true, false) as Control
			check(host != null and host.get_child_count() == scene.players[seat]["hand"].size(), "public concealed count changes update seat %d to %d visible backs" % [seat, scene.players[seat]["hand"].size()])
		var count_state := battle_capture_state(scene)
		count_state["evidence_origin"] = "public_hand_count_and_meld_layout_fixture"
		await save_reading_capture(scene, output_dir, str(case_data["name"]), count_state)
	await prepare_offline_reading_fixture(scene)
	scene.wall.resize(64)
	scene.last_discard = "3W"
	scene.last_discard_seat = 3
	scene.players[3]["discards"] = ["3W"]
	scene.table_logs = ["第1巡：北家打出3万", "第1巡：轮到你出牌"] as Array[String]
	scene.render_game()
	await settle()
	check_battle_surfaces(scene)
	check_advisor_obstacles(scene)
	check_advisor_paper_cards(scene)
	await save_reading_capture(scene, output_dir, "battle_healthy", battle_capture_state(scene))
	var hand_before: Array = scene.get_self_hand().duplicate()
	var saved_wall: Array = scene.wall.duplicate()
	scene.wall = scene.make_wall()
	scene.render_game()
	await settle()
	check_advisor_obstacles(scene)
	var full_wall_advisor := scene.find_child("AdvisorPanel", true, false) as Control
	var full_wall_opener := scene.find_child("AdvisorDetailButton", true, false) as Button
	check(full_wall_advisor != null and full_wall_opener != null, "a full wall keeps the analysis opener outside all actual tile faces")
	if full_wall_opener != null:
		await activate_button(full_wall_opener, "key")
		await settle()
		check(scene.advisor_detail_open and scene.get_self_hand() == hand_before, "full-wall analysis opens from the native keyboard action without discarding")
		await send_key(KEY_ESCAPE, 0)
	scene.wall = saved_wall
	scene.render_game()
	await settle()
	for node_name in ["TopHudSettingsButton", "TopHudBackButton", "TopHudUpdateButton"]:
		var button := scene.find_child(node_name, true, false) as Button
		var marker := button.find_child("TopHudButtonFocusMarker", true, false) as Label if button != null else null
		check(button != null and marker != null and button.size.x >= 44.0 and button.size.y >= 44.0 and button.get_meta("guofeng_button_face_key", "") == "button_face_jiangnan_gpt", "%s retains a real forty-four-pixel paper action with native focus" % node_name)
		if button == null or marker == null or button.disabled:
			continue
		button.grab_focus()
		await settle()
		var visible_markers := 0
		for candidate in scene.find_children("TopHudButtonFocusMarker", "Label", true, false):
			if (candidate as Label).is_visible_in_tree():
				visible_markers += 1
		check(button.has_focus() and marker.is_visible_in_tree() and visible_markers == 1, "%s owns the only visible HUD focus marker" % node_name)
		var caption := button.find_child("TopHudButtonCharLabel", true, false) as Label
		var caption_tint := caption.get_theme_color("font_color") if caption != null else Color.TRANSPARENT
		check(caption != null and caption.is_visible_in_tree() and caption_tint.r >= 0.95 and caption_tint.a >= 0.99 and marker.get_theme_color("font_color").r >= 0.95 and marker.get_theme_color("font_color").a >= 0.99, "%s visible focus caption and marker switch to fully opaque paper-white foreground on ink" % node_name)
		check(label_text_width(marker, marker.text) <= marker.size.x + 1.0, "%s native focus arrow fits its actual glyph lane" % node_name)
	var settings := scene.find_child("TopHudSettingsButton", true, false) as Button
	if settings != null:
		settings.grab_focus()
		await save_reading_capture(scene, output_dir, "battle_keyboard", battle_capture_state(scene))
		await activate_button(settings, "mouse")
		await settle()
		check(scene.settings_panel_open and scene.get_self_hand() == hand_before, "real HUD settings opens without a table action")
		await send_key(KEY_ESCAPE, 0)
		await settle()
		check(not scene.settings_panel_open and scene.mode == "offline" and scene.get_self_hand() == hand_before, "Esc returns from settings to the same battle and hand")
	var hud := scene.find_child("TopHud3DShell", true, false) as Control
	var hud_id := hud.get_instance_id() if hud != null else 0
	for wall_size in [18, 0, 64]:
		scene.wall = scene.make_wall()
		scene.wall.resize(wall_size)
		scene.refresh_battle_hud_lane()
		var wall := scene.find_child("TopHudWallText", true, false) as Label
		var state := scene.find_child("TopHudWallState", true, false) as Label
		var count := scene.find_child("CenterWallCount", true, false) as Label
		check(wall != null and wall.text == "余牌 %d/%d" % [wall_size, scene.display_wall_total()] and count != null and count.text == str(wall_size), "native HUD and center track live wall count %d" % wall_size)
		check(state != null and state.text.contains(scene.wall_state_text(wall_size).replace("牌墙", "")) and ((state.get_theme_color("font_color").r > state.get_theme_color("font_color").g) == scene.wall_is_low(wall_size)), "native wall state and warning ink track threshold %d" % wall_size)
		var center_state := scene.find_child("CenterWallStatusLabel", true, false) as Label
		var center_model: Dictionary = scene.center_wall_view_model(wall_size, scene.display_wall_total(), root.size.x <= 960.0 or root.size.y < 720.0)
		check(center_state != null and center_state.text == center_model["label_text"] and center_state.tooltip_text == center_model["tooltip"], "center wall caption and complete tooltip track the same live threshold %d" % wall_size)
		var retained := scene.find_child("TopHud3DShell", true, false) as Control
		check(retained != null and retained.get_instance_id() == hud_id, "live wall updates retain the authored HUD rather than rebuilding it")
		if wall_size == 18:
			await save_reading_capture(scene, output_dir, "battle_low_wall", battle_capture_state(scene))
	set_offline_pending_claim_fixture(scene, "peng")
	await settle()
	var ledger := scene.find_child("TableLogLedgerPanel", true, false) as Control
	check(ledger != null and not ledger.is_visible_in_tree(), "the secondary paper ledger yields to the pending response")
	await save_reading_capture(scene, output_dir, "battle_pending", battle_capture_state(scene))
	var grid := scene.find_child("PendingClaimResponseGrid", true, false) as Control
	var peng := first_button_with_text(grid, scene.claim_label("peng"))
	check(peng != null and not peng.disabled, "pending battle exposes the real peng action")
	if peng != null:
		await activate_button(peng, "touch")
		await settle()
		check(scene.offline_pending_claim.is_empty() and scene.players[0]["melds"].size() == 1, "touch peng commits exactly one meld through the real response")
		# The response fixture disables assistance. Explicitly restore the real
		# optional analysis state to exercise its occupied-meld fallback.
		scene.ai_assist_enabled = true
		scene.render_game()
		await settle()
		check_advisor_obstacles(scene)
		var advisor := scene.find_child("AdvisorPanel", true, false) as Control
		var detail := scene.find_child("AdvisorDetailButton", true, false) as Button
		check(advisor != null and detail != null, "an occupied self-meld channel preserves a real analysis opener")
		if detail != null:
			var melds_before: Array = scene.get_melds(0).duplicate(true)
			await activate_button(detail, "mouse")
			await settle()
			check(scene.advisor_detail_open and scene.find_child("AdvisorDetailText", true, false) != null and scene.get_melds(0) == melds_before, "occupied-channel analysis opens read-only without changing the meld")
			await send_key(KEY_ESCAPE, 0)
			await settle()
		await save_reading_capture(scene, output_dir, "battle_claimed", battle_capture_state(scene))
	await check_table_reading(scene, output_dir)


func run() -> void:
	print("=== guofeng battle UI smoke START ===")
	if DisplayServer.get_name().to_lower() == "headless":
		quit(1)
		return
	OS.set_environment("YUNZHUO_UI_CAPTURE", "1")
	var viewport_size := Vector2i(1280, 720)
	var arguments := OS.get_cmdline_user_args()
	if not arguments.is_empty():
		var dimensions := arguments[0].split("x")
		if dimensions.size() == 2:
			viewport_size = Vector2i(int(dimensions[0]), int(dimensions[1]))
	var large_contrast := arguments.size() > 1 and arguments[1] == "large_contrast"
	DisplayServer.window_set_size(viewport_size)
	root.size = viewport_size
	root.content_scale_size = viewport_size
	var capture_root := OS.get_environment("YUNZHUO_GUOFENG_BATTLE_CAPTURE_DIR")
	if capture_root.is_empty():
		capture_root = "res://build/qa/guofeng_battle"
	var output_dir := ProjectSettings.globalize_path("%s/%dx%d%s" % [capture_root, viewport_size.x, viewport_size.y, "_large_contrast" if large_contrast else ""])
	check(DirAccess.make_dir_recursive_absolute(output_dir) == OK, "battle evidence directory is writable")
	var scene = load("res://Main.tscn").instantiate()
	if scene.get_script() == null:
		check(false, "runtime script must compile before battle evidence")
		scene.free()
		quit(1)
		return
	root.add_child(scene)
	await settle()
	var user_state := capture_smoke_state(scene)
	scene.set_process(false)
	scene.music_enabled = false
	scene.sfx_enabled = false
	scene.voice_enabled = false
	scene.tts_enabled = false
	scene.fx_enabled = false
	scene.reduce_motion_enabled = true
	scene.large_text_enabled = large_contrast
	scene.high_contrast_enabled = large_contrast
	scene.tutorial_step = scene.TUTORIAL_STEP_COMPLETE
	await check_guofeng_battle_inputs(scene, output_dir)
	scene.shutdown_runtime()
	restore_smoke_state(scene, user_state)
	scene.queue_free()
	await process_frame
	print("=== RESULT: %s ===" % ("FAIL" if failed else "OK"))
	quit(1 if failed else 0)
