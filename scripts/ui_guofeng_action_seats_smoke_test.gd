extends "res://scripts/ui_guofeng_battle_smoke_test.gd"


func run() -> void:
	print("=== guofeng action seats UI smoke START ===")
	var capture_root := OS.get_environment("YUNZHUO_GUOFENG_ACTION_CAPTURE_DIR")
	if capture_root.is_empty():
		capture_root = "res://build/qa/guofeng_action_seats"
	OS.set_environment("YUNZHUO_GUOFENG_BATTLE_CAPTURE_DIR", capture_root)
	await super.run()


func check_native_reading_group(labels: Array, surface: Control, description: String) -> void:
	for label_value in labels:
		var label := label_value as Label
		check(label != null, "%s has a native factual label" % description)
		if label == null:
			continue
		check(surface.get_global_rect().grow(1.0).encloses(label.get_global_rect()), "%s keeps %s inside its reading surface" % [description, label.name])
		check(label.size.y >= label.get_minimum_size().y and label_text_width(label, label.text) <= label.size.x + 1.0, "%s displays %s without cutting a line or factual unit" % [description, label.name])
		check(label.get_theme_constant("outline_size") == 0 and label.get_theme_color("font_color").a >= 0.99, "%s uses opaque native ink without outlined lettering" % label.name)
	for first_index in range(labels.size()):
		for second_index in range(first_index + 1, labels.size()):
			var first := labels[first_index] as Label
			var second := labels[second_index] as Label
			if first != null and second != null:
				check(not first.get_global_rect().intersects(second.get_global_rect()), "%s separates %s from %s" % [description, first.name, second.name])


func action_seat_state(scene: Node) -> Dictionary:
	var state := battle_capture_state(scene)
	var river_archives: Array = []
	for seat in range(4):
		var archive := scene.find_child("DiscardRiverArchiveButton_%d" % seat, true, false) as Button
		if archive != null:
			var label := archive.find_child("DiscardRiverArchiveLabel_%d" % seat, true, false) as Label
			river_archives.append({"seat": seat, "rect": advisor_reading_rect(archive), "minimum_size": [archive.get_combined_minimum_size().x, archive.get_combined_minimum_size().y], "label": label.text if label != null else "", "label_rect": advisor_reading_rect(label) if label != null else []})
	state["river_archives"] = river_archives
	state["meld_lanes"] = []
	for seat in range(4):
		var lane := scene.find_child("MeldArea_%d" % seat, true, false) as Control
		state["meld_lanes"].append({"seat": seat, "count": scene.get_melds(seat).size(), "rect": advisor_reading_rect(lane) if lane != null else []})
	var actions: Array = []
	for button in scene.action_bar_buttons():
		actions.append({"text": button.text, "shortcut": button.get_meta("action_shortcut", ""), "choice": button.get_meta("pending_chi_choice", {}), "face": button.get_meta("guofeng_button_face_key", ""), "disabled": button.disabled})
	state["actions"] = actions
	state["self_melds"] = scene.get_melds(0).duplicate(true)
	state["seat_facts"] = []
	for seat in range(4):
		var player: Dictionary = scene.get_player_info(seat)
		var panel := scene.find_child("SeatPanel_%d" % seat, true, false) as Control
		var meta := scene.find_child("SeatCompactMeta_%d" % seat, true, false) as Label
		state["seat_facts"].append({"seat": seat, "surface": panel.get_meta("guofeng_surface_key", "") if panel != null else "", "hand_count": player.get("hand_count", 0), "flower_count": player.get("flowers", 0), "score": player.get("score", 0), "meta_text": meta.text if meta != null else ""})
	var dock := scene.find_child("ActionButtonDock", true, false) as Control
	var intent := scene.find_child("ActionIntentDock", true, false) as Control
	var timer := scene.find_child("PendingClaimTimerText", true, false) as Label
	var warning := scene.find_child("PendingClaimAutoPassWarning", true, false) as Label
	state["action_buttons"] = []
	for button in scene.action_bar_buttons():
		state["action_buttons"].append({"name": str(button.name), "text": button.text, "rect": advisor_reading_rect(button), "font_size": button.get_theme_font_size("font_size"), "text_width": button.get_meta("action_text_width", 0), "group": button.get_meta("normal_action_group", "")})
	state["dock_rect"] = advisor_reading_rect(dock) if dock != null else []
	state["intent_rect"] = advisor_reading_rect(intent) if intent != null else []
	var hand_tray := scene.find_child("HandTray", true, false) as Control
	state["hand_tray_rect"] = advisor_reading_rect(hand_tray) if hand_tray != null else []
	state["dock_surface"] = dock.get_meta("guofeng_surface_key", "") if dock != null else ""
	state["intent_surface"] = intent.get_meta("guofeng_surface_key", "") if intent != null else ""
	state["pending_seconds"] = scene.pending_claim_remaining_seconds()
	state["timer_text"] = timer.text if timer != null else ""
	state["warning_text"] = warning.text if warning != null else ""
	state["scores"] = []
	for seat in range(4):
		var score := scene.find_child("SeatCompactScore_%d" % seat, true, false) as Label
		state["scores"].append({"seat": seat, "text": score.text if score != null else "", "font_size": score.get_theme_font_size("font_size") if score != null else 0})
	return state


func actual_control_bounds(control: Control) -> Rect2:
	var transform := control.get_global_transform()
	var bounds := Rect2(transform * Vector2.ZERO, Vector2.ZERO)
	for corner in [Vector2(control.size.x, 0.0), control.size, Vector2(0.0, control.size.y)]:
		bounds = bounds.expand(transform * corner)
	return bounds


func check_actual_wall_clearance(scene: Node) -> Dictionary:
	var walls: Array = []
	for item in scene.find_children("WallTileBack_*", "TextureRect", true, false):
		var face := item as TextureRect
		if face.is_visible_in_tree():
			walls.append({"name": str(face.get_parent().name) + "/" + str(face.name), "rect": actual_control_bounds(face)})
	var meld_faces: Array = []
	var river_faces: Array = []
	for seat in range(4):
		var grid := scene.find_child("DiscardGrid_%d" % seat, true, false) as GridContainer
		if grid != null:
			for tile in grid.get_children():
				if bool(tile.get_meta("archive_reserved", false)):
					continue
				var face := tile.find_child("TileFaceTexture", true, false) as TextureRect
				if face != null and face.is_visible_in_tree():
					river_faces.append({"seat": seat, "source_index": int(tile.get_meta("discard_source_index", -1)), "rect": actual_control_bounds(face)})
		var lane := scene.find_child("MeldArea_%d" % seat, true, false) as Control
		if lane == null:
			continue
		for holder_node in lane.find_children("MeldTileHolder_*", "Control", true, false):
			var holder := holder_node as Control
			if holder.get_child_count() == 0:
				continue
			var face := holder.get_child(0) as Control
			if face != null and face.is_visible_in_tree():
				meld_faces.append({"seat": seat, "rect": actual_control_bounds(face)})
	var conflicts: Array[String] = []
	var action_surfaces: Array = []
	for node_name in ["ActionButtonDock", "ActionIntentDock", "HandTray", "SeatPanel_0"]:
		var control := scene.find_child(node_name, true, false) as Control
		if control != null and control.is_visible_in_tree():
			action_surfaces.append({"name": node_name, "rect": actual_control_bounds(control)})
	for button in scene.action_bar_buttons():
		if button.is_visible_in_tree():
			action_surfaces.append({"name": "action / " + button.text, "rect": actual_control_bounds(button)})
	for wall in walls:
		var wall_rect: Rect2 = wall["rect"]
		for surface in action_surfaces:
			if wall_rect.grow(3.9).intersects(surface["rect"]):
				conflicts.append(str(surface["name"]) + " / " + str(wall["name"]))
		for face in river_faces:
			# Latest-discard authored edges extend 1.5px beyond the face.
			var gutter := 9.4 if int(face["seat"]) == 0 else 1.5
			if wall_rect.grow(gutter).intersects(face["rect"]):
				conflicts.append("seat%d river[%d] / %s" % [face["seat"], face["source_index"], wall["name"]])
		for face in meld_faces:
			if wall_rect.grow(1.5).intersects(face["rect"]):
				conflicts.append("seat%d meld / %s" % [face["seat"], wall["name"]])
		for seat in range(4):
			for node_name in ["DiscardRiverArchiveButton_%d" % seat, "MeldLaneArchiveButton_%d" % seat, "OpponentHand_%d" % seat]:
				var control := scene.find_child(node_name, true, false) as Control
				if control != null and control.is_visible_in_tree() and wall_rect.grow(1.5).intersects(actual_control_bounds(control)):
					conflicts.append(node_name + " / " + str(wall["name"]))
	for seat in [1, 2, 3]:
		var hand := scene.find_child("OpponentHand_%d" % seat, true, false) as Control
		if hand == null:
			continue
		for face in meld_faces:
			if hand.get_global_rect().grow(1.5).intersects(face["rect"]):
				conflicts.append("opponent%d hand / seat%d meld" % [seat, face["seat"]])
	var top_archive := scene.find_child("DiscardRiverArchiveButton_2", true, false) as Control
	var latest_frame := scene.find_child("LastDiscardFocusMarker", true, false) as Control
	var latest_frame_entry: Dictionary = {}
	if latest_frame != null and latest_frame.is_visible_in_tree():
		var latest_seat: int = int(scene.get_last_discard_seat())
		var latest_tile := scene.find_child("RecentDiscardTile_%d" % latest_seat, true, false) as Control
		var latest_face := latest_tile.find_child("TileFaceTexture", true, false) as TextureRect if latest_tile != null else null
		check(latest_face != null, "latest-discard frame retains its actual visible tile")
		if latest_face != null:
			var frame_rect := actual_control_bounds(latest_frame)
			var face_rect := actual_control_bounds(latest_face)
			check(frame_rect.position.distance_to(face_rect.position) <= 1.5 and frame_rect.size.distance_to(face_rect.size) <= 1.5, "latest-discard frame follows the actual final paginated grid cell")
			latest_frame_entry = {"seat": latest_seat, "rect": frame_rect, "outer_edge_px": 1.5}
			if latest_seat == 0:
				for wall in walls:
					var wall_rect: Rect2 = wall["rect"]
					if wall_rect.grow(9.4).intersects(frame_rect):
						conflicts.append("bottom latest frame / " + str(wall["name"]))
	var top_identity := scene.find_child("SeatPanel_2", true, false) as Control
	if top_archive != null and top_identity != null:
		check(not actual_control_bounds(top_archive).grow(-0.5).intersects(actual_control_bounds(top_identity).grow(-0.5)), "top river history target clears the actual centered player identity")
		var right_hand := scene.find_child("OpponentHand_1", true, false) as Control
		if right_hand != null:
			check(not actual_control_bounds(top_archive).intersects(actual_control_bounds(right_hand).grow(7.9)), "top river history target keeps eight pixels clear of the right concealed hand")
		var right_archive := scene.find_child("DiscardRiverArchiveButton_1", true, false) as Control
		var viewport: Vector2 = scene.effective_viewport_size()
		if right_archive != null and (viewport.x < 1600.0 or viewport.y < 900.0):
			check(not actual_control_bounds(top_archive).intersects(actual_control_bounds(right_archive).grow(7.9)), "top history keeps eight pixels clear of the right player's separate pager")
	check(not river_faces.is_empty(), "physical wall clearance includes actual river bitmap faces")
	check(conflicts.is_empty(), "actual river, melds, hands, archive targets and action surfaces clear visible wall bitmaps: %s" % str(conflicts))
	return {"action_surfaces": action_surfaces.map(Callable(self, "serialized_geometry_entry")), "wall_faces": walls.map(Callable(self, "serialized_geometry_entry")), "meld_faces": meld_faces.map(Callable(self, "serialized_geometry_entry")), "river_faces": river_faces.map(Callable(self, "serialized_geometry_entry")), "latest_frame": serialized_geometry_entry(latest_frame_entry) if not latest_frame_entry.is_empty() else {}, "conflicts": conflicts}


func serialized_geometry_entry(item: Dictionary) -> Dictionary:
	var result := item.duplicate()
	var bounds: Rect2 = item["rect"]
	result["rect"] = [bounds.position.x, bounds.position.y, bounds.size.x, bounds.size.y]
	return result


func check_action_surfaces(scene: Node) -> void:
	for button in scene.action_bar_buttons():
		var face := button.get_node_or_null("GptButtonFacePlate") as TextureRect
		var key := str(button.get_meta("guofeng_button_face_key", ""))
		check(face != null and (face.texture == scene.optional_gpt_illustration_texture(key) or (face.texture is AtlasTexture and (face.texture as AtlasTexture).atlas == scene.optional_gpt_illustration_texture(key))) and face.modulate == Color.WHITE and face.self_modulate == Color.WHITE, "%s keeps one untinted authored paper or ink face" % button.text)
		check(button.get_theme_constant("outline_size") == 0 and button.size.x >= 50.0 and button.size.y >= 44.0, "%s preserves native unoutlined text and its real touch target" % button.text)
		for retired in ["ActionButton3DCastShadow", "ActionButton3DDepthEdge", "ActionButton3DTopRim", "ActionButtonSeal", "ActionButtonPanelPlate", "ActionButtonRoleRail", "ActionButtonPulse", "ActionButtonPressFeedback"]:
			check(button.find_child(retired, true, false) == null, "%s does not rebuild retired ornament %s" % [button.text, retired])
		var shortcut := button.find_child("ActionButtonShortcutHint", true, false) as Label
		var hint := str(button.get_meta("action_shortcut", ""))
		check((shortcut == null and hint == "") or (shortcut != null and shortcut.text == hint and button.get_global_rect().grow(1.0).encloses(shortcut.get_global_rect())), "%s shows only its genuinely assigned shortcut" % button.text)
		var art := button.get_node_or_null("ActionButtonArt") as Control
		check(art != null and face != null and art.z_index > face.z_index, "%s keeps its native shortcut and focus marker above both bitmap faces" % button.text)


func check_guofeng_battle_inputs(scene: Node, output_dir: String) -> void:
	await check_table_chrome_lifecycle(scene, output_dir)
	await check_normal_action_capacity(scene, output_dir)
	await prepare_offline_reading_fixture(scene)
	scene.players[1]["score"] = 32000
	scene.players[2]["score"] = 23000
	scene.players[3]["score"] = 23000
	scene.dealer_seat = 1
	for seat in [1, 2, 3]:
		scene.players[seat]["hand"] = ["E", "S", "W", "N", "1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W"]
	scene.player_info_cache_token = ""
	scene.player_info_cache.clear()
	set_offline_pending_claim_fixture(scene, "chi")
	await settle()
	var choices: Array = scene.ordered_pending_chi_choices(scene.offline_pending_claim["chi_choices"])
	check(choices.size() == 3, "fixture exposes three different legal chi combinations")
	check_action_surfaces(scene)
	for seat in range(4):
		var panel := scene.find_child("SeatPanel_%d" % seat, true, false) as Control
		var labels: Array = []
		for prefix in ["SeatCompactName_", "SeatCompactScore_", "SeatCompactMeta_", "SeatCompactDealer_", "SeatCompactStatus_"]:
			var label := scene.find_child(prefix + str(seat), true, false) as Label
			if label != null:
				labels.append(label)
		check(panel != null, "side seat %d keeps its original external card" % seat)
		if panel != null:
			check_native_reading_group(labels, panel, "side seat %d" % seat)
		var score := scene.find_child("SeatCompactScore_%d" % seat, true, false) as Label
		check(score != null and score.text == scene.seat_score_text(scene.get_player_info(seat)) and score.text.ends_with("万"), "seat %d retains its complete score magnitude" % seat)
		if seat == 1:
			check(score != null and score.text == "3.2万", "right dealer displays the audited 32000-point score with its 万 unit")
	var context := scene.find_child("PendingClaimIllustration", true, false) as Control
	var context_labels: Array = []
	for node_name in ["PendingClaimSourceText", "PendingClaimTileName", "PendingClaimUrgencyText", "PendingClaimFocusText"]:
		context_labels.append(scene.find_child(node_name, true, false))
	check(context != null and context.get_meta("guofeng_surface_key", "") == "menu_card_readable_gpt", "pending context uses one existing paper bitmap")
	if context != null:
		check_native_reading_group(context_labels, context, "pending context")
	for retired in ["PendingClaimPriorityArt", "PendingClaimFlowArt", "PendingClaimResponsePulse", "PendingClaimMistCloud"]:
		check(scene.find_child(retired, true, false) == null, "pending reading does not restore overlapping decoration %s" % retired)
	var chi_buttons: Array[Button] = []
	for button in scene.action_bar_buttons():
		if button.get_meta("action_role", "") == "chi":
			chi_buttons.append(button)
	check(chi_buttons.size() == 3, "all three chi choices remain real buttons")
	var c_count := 0
	for button in chi_buttons:
		var choice: Dictionary = button.get_meta("pending_chi_choice", {})
		var expected := "C" if choice == choices[0] else ""
		check(button.get_meta("action_shortcut", "") == expected, "%s shortcut agrees with the actual C payload" % button.text)
		if expected == "C":
			c_count += 1
		else:
			check(not button.tooltip_text.contains("快捷键 C"), "%s tooltip does not promise another choice's C key" % button.text)
	check(c_count == 1, "only the combination actually submitted by C displays C")
	await save_reading_capture(scene, output_dir, "action_seats_pending", action_seat_state(scene))
	if chi_buttons.size() == 3:
		var focused := chi_buttons[1]
		var rect_before := focused.get_global_rect()
		focused.grab_focus()
		await settle()
		var marker := focused.find_child("ActionButtonFocusMarker", true, false) as Label
		var plate := focused.get_node_or_null("ButtonFocusPlate") as TextureRect
		check(focused.has_focus() and marker != null and marker.is_visible_in_tree() and focused.get_theme_color("font_focus_color").r > 0.9, "second choice has a readable native keyboard focus without a false C hint")
		check(focused.get_global_rect() == rect_before and plate != null and plate.modulate == Color.WHITE, "focus changes only authored artwork, never the action hit rectangle")
		await save_reading_capture(scene, output_dir, "action_seats_focus", action_seat_state(scene))
		await send_key(KEY_C, 0)
		await settle()
		check(scene.players[0]["melds"].size() == 1 and scene.same_tile_list(scene.players[0]["melds"][0], choices[0]["meld"]), "real C input submits exactly the marked first combination even while the second is focused")
		await save_reading_capture(scene, output_dir, "action_chi_keyboard_c", action_seat_state(scene))
	var modalities := ["mouse", "touch", "key"]
	for choice_index in range(3):
		await prepare_offline_reading_fixture(scene)
		set_offline_pending_claim_fixture(scene, "chi")
		await settle()
		var target: Button = null
		for button in scene.action_bar_buttons():
			if button.get_meta("pending_chi_choice", {}) == choices[choice_index]:
				target = button
		check(target != null, "combination %d retains its own input target" % choice_index)
		if target != null:
			await activate_button(target, modalities[choice_index])
			await settle()
			check(scene.offline_pending_claim.is_empty() and scene.players[0]["melds"].size() == 1 and scene.same_tile_list(scene.players[0]["melds"][0], choices[choice_index]["meld"]), "real %s input submits combination %d, not the C default" % [modalities[choice_index], choice_index])
			await save_reading_capture(scene, output_dir, "action_chi_%d_%s" % [choice_index, modalities[choice_index]], action_seat_state(scene))
	await check_countdown_lifecycle(scene, output_dir)


func check_all_seat_reading(scene: Node) -> void:
	for seat in range(4):
		var panel := scene.find_child("SeatPanel_%d" % seat, true, false) as TextureRect
		check(panel != null and panel.get_meta("guofeng_surface_key", "") == "menu_ink_primary" and panel.modulate == Color.WHITE and panel.self_modulate == Color.WHITE, "seat %d uses exactly one untinted authored ink surface" % seat)
		var labels: Array = []
		for prefix in ["SeatCompactName_", "SeatCompactScore_", "SeatCompactMeta_", "SeatCompactDealer_", "SeatCompactStatus_", "SeatThreatBadge_"]:
			var label := scene.find_child(prefix + str(seat), true, false) as Label
			if label != null:
				labels.append(label)
		if panel != null:
			check_native_reading_group(labels, panel, "seat %d" % seat)
		if root.size.x >= 1600 and root.size.y >= 900 and seat != 2:
			var name := scene.find_child("SeatCompactName_%d" % seat, true, false) as Label
			var score := scene.find_child("SeatCompactScore_%d" % seat, true, false) as Label
			var meta := scene.find_child("SeatCompactMeta_%d" % seat, true, false) as Label
			check(name != null and score != null and meta != null and name.get_theme_font_size("font_size") >= 16 and score.get_theme_font_size("font_size") >= 18 and meta.get_theme_font_size("font_size") >= 15, "wide seat %d keeps readable identity, score and counts" % seat)
		for retired in ["SeatAvatar_", "SeatCompactTextBack_", "SeatPanel3DCastShadow_", "SeatPanel3DRearShell_", "SeatPanel3DJadeWash_", "SeatPanelAccentRail_"]:
			check(scene.find_child(retired + str(seat), true, false) == null, "seat %d does not rebuild retired visual %s" % [seat, retired])


func check_wide_seat_text_toggle(scene: Node) -> void:
	if root.size.x < 1600 or root.size.y < 900:
		return
	var original_large: bool = scene.large_text_enabled
	scene.large_text_enabled = false
	scene.render_game()
	await settle()
	var normal_top := scene.find_child("SeatCompactScore_2", true, false) as Label
	var normal_side := scene.find_child("SeatCompactMeta_1", true, false) as Label
	var normal_top_size := normal_top.get_theme_font_size("font_size") if normal_top != null else 0
	var normal_side_size := normal_side.get_theme_font_size("font_size") if normal_side != null else 0
	scene.large_text_enabled = true
	scene.render_game()
	await settle()
	var large_top := scene.find_child("SeatCompactScore_2", true, false) as Label
	var large_side := scene.find_child("SeatCompactMeta_1", true, false) as Label
	check(large_top != null and large_side != null and large_top.get_theme_font_size("font_size") > normal_top_size and large_side.get_theme_font_size("font_size") > normal_side_size, "wide seat typography responds to a live large-text toggle")
	check_all_seat_reading(scene)
	scene.large_text_enabled = original_large
	scene.render_game()
	await settle()


func check_meld_group_pads(scene: Node) -> void:
	for seat in range(4):
		var lane := scene.find_child("MeldLaneArt_%d" % seat, true, false) as Control
		var area := scene.find_child("MeldArea_%d" % seat, true, false) as Control
		check(lane != null and lane.get_meta("visual_policy", "") == "group_pads_only" and lane.find_children("*", "TextureRect", true, false).is_empty(), "seat %d leaves unused meld capacity unpainted" % seat)
		if area != null:
			for child in area.get_children():
				if child is Control and str(child.name).begins_with("MeldGroup_"):
					var pad := child.find_child("MeldGroupGptPad", true, false) as TextureRect
					check(pad != null and pad.is_visible_in_tree() and pad.texture == scene.optional_gpt_illustration_texture("ui_meld_pad"), "seat %d keeps its authored pad on each visible meld group" % seat)
					if pad != null:
						var tiles := child.find_child("MeldTiles", true, false) as Control
						var occupied := Rect2()
						if tiles != null:
							for holder in tiles.get_children():
								if holder is Control:
									occupied = (holder as Control).get_global_rect() if occupied.size == Vector2.ZERO else occupied.merge((holder as Control).get_global_rect())
						check(occupied.size != Vector2.ZERO and pad.get_global_rect().grow(4.0).encloses(occupied) and pad.size.y <= occupied.size.y + 12.0, "seat %d group pad follows the visible tiles without a long empty tail" % seat)


func check_meld_page_contents(scene: Node, seat: int, expected: Array, seen: Dictionary) -> void:
	var area := scene.find_child("MeldArea_%d" % seat, true, false) as Control
	check(area != null, "seat %d keeps its meld lane" % seat)
	if area == null:
		return
	var previous_rect := Rect2()
	var visible_groups := 0
	for child in area.get_children():
		var group := child as Control
		if group == null or not str(group.name).begins_with("MeldGroup_"):
			continue
		var index := int(str(group.name).get_slice("_", 1))
		var tiles := group.find_child("MeldTiles", true, false) as Control
		check(index >= 0 and index < expected.size() and tiles != null, "seat %d shows a valid complete meld index" % seat)
		if index < 0 or index >= expected.size() or tiles == null:
			continue
		seen[index] = true
		visible_groups += 1
		check(area.get_global_rect().grow(1.0).encloses(group.get_global_rect()) and (previous_rect.size == Vector2.ZERO or not previous_rect.intersects(group.get_global_rect())), "seat %d group %d stays inside its lane without overlapping another group" % [seat, index])
		previous_rect = group.get_global_rect()
		check(tiles.get_child_count() == (expected[index] as Array).size(), "seat %d group %d includes every tile including the fourth kong tile" % [seat, index])
		for tile_index in range(mini(tiles.get_child_count(), (expected[index] as Array).size())):
			var holder := tiles.get_child(tile_index) as Control
			var tile := holder.get_child(0) as Control if holder != null and holder.get_child_count() > 0 else null
			var tile_code: String = str(scene.normalize_tile_code(str(expected[index][tile_index])))
			var face := tile.get_meta("tile_face_texture", null) as TextureRect if tile != null else null
			check(tile != null and str(tile.get_meta("normalized_tile_code", "")) == tile_code and face != null and face.texture == scene.tile_textures.get(tile_code) and face.texture != scene.tile_back and absf(tile.rotation - scene.seat_meld_face_rotation(seat)) <= 0.001, "seat %d group %d tile %d keeps its real face and seat direction" % [seat, index, tile_index])
	check(visible_groups == int(area.get_meta("visible_group_count", -1)), "seat %d publishes its actual visible meld count" % seat)
	if scene.effective_viewport_size() in [Vector2(960, 540), Vector2(1280, 720)]:
		check(visible_groups >= 2, "seat %d shows at least two complete meld groups at %s" % [seat, scene.effective_viewport_size()])


func check_meld_pagination_inputs(scene: Node, expected: Array) -> void:
	for seat in range(4):
		var area := scene.find_child("MeldArea_%d" % seat, true, false) as Control
		if area == null:
			check(false, "seat %d has a meld lane to navigate" % seat)
			continue
		var page_count := int(area.get_meta("page_count", 1))
		var seen := {}
		for page in range(page_count):
			check_meld_page_contents(scene, seat, expected, seen)
			var pager := scene.find_child("MeldLaneArchiveButton_%d" % seat, true, false) as Button
			if page_count <= 1:
				check(pager == null, "seat %d omits pagination when all melds fit" % seat)
				continue
			check(pager != null and pager.text.contains("%d/%d" % [page + 1, page_count]), "seat %d shows the current meld page %d/%d" % [seat, page + 1, page_count])
			if pager == null:
				break
			await activate_button(pager, ["mouse", "touch", "key", "mouse"][seat])
			await settle()
			if seat == 2:
				var restored := scene.find_child("MeldLaneArchiveButton_%d" % seat, true, false) as Button
				check(restored != null and restored.has_focus(), "keyboard meld paging keeps focus on the same seat's pager")
		check(seen.size() == expected.size(), "seat %d pagination reaches every public meld" % seat)
		area = scene.find_child("MeldArea_%d" % seat, true, false) as Control
		check(area != null and int(area.get_meta("window_start", -1)) == 0, "seat %d pagination returns to its first page" % seat)


func check_discard_archive_separation(scene, viewport_size: Vector2) -> void:
	for seat in range(4):
		var archive := scene.find_child("DiscardRiverArchiveButton_%d" % seat, true, false) as Button
		if archive == null:
			continue
		var archive_rect := archive.get_global_rect()
		var label := archive.find_child("DiscardRiverArchiveLabel_%d" % seat, true, false) as Label
		check(archive_rect.size.x >= 44.0 and archive_rect.size.y >= 44.0 and label != null and archive_rect.grow(0.5).encloses(label.get_global_rect()), "river %d archive bounds both native label rows in its full touch target at %s" % [seat, viewport_size])
		if label != null:
			for line in label.text.split("\n"):
				check(label_text_width(label, line) <= label.size.x + 0.5, "river %d keeps the complete history label line %s readable" % [seat, line])
			var start := int(archive.get_meta("window_start", -1))
			var action := "查看更早" if start > 0 else "回到最新"
			var expected := "查看\n更早" if start > 0 else "回到\n最新"
			if seat == 2 and (viewport_size.x < 1600.0 or viewport_size.y < 900.0):
				expected = "对家\n" + expected
			elif seat != 1 and archive.get_meta("visual_anchor", "") == "gutter_below_side_river":
				expected = action
			check(label.text == expected and archive.tooltip_text.contains(str(archive.get_meta("window_label", ""))), "river %d names the next action and preserves the current range" % seat)
		var conflicts: Array[String] = []
		for other_seat in range(4):
			var meld := scene.find_child("MeldArea_%d" % other_seat, true, false) as Control
			if meld != null and not scene.get_melds(other_seat).is_empty() and archive_rect.grow(2.9).intersects(meld.get_global_rect()):
				conflicts.append("meld:%d" % other_seat)
			var other_archive := scene.find_child("DiscardRiverArchiveButton_%d" % other_seat, true, false) as Control
			if other_seat != seat and other_archive != null and archive_rect.grow(2.9).intersects(other_archive.get_global_rect()):
				conflicts.append("archive:%d" % other_seat)
			var grid := scene.find_child("DiscardGrid_%d" % other_seat, true, false) as GridContainer
			if grid == null:
				continue
			for child in grid.get_children():
				if child is Control and not bool(child.get_meta("archive_reserved", false)) and archive_rect.grow(2.9).intersects((child as Control).get_global_rect()):
					conflicts.append("%d:%s" % [other_seat, child.name])
			var seat_panel := scene.find_child("SeatPanel_%d" % other_seat, true, false) as Control
			if seat_panel != null and archive_rect.grow(2.9).intersects(seat_panel.get_global_rect()):
				conflicts.append("seat:%d" % other_seat)
			var opponent_hand := scene.find_child("OpponentHand_%d" % other_seat, true, false) as Control
			if opponent_hand != null and archive_rect.grow(2.9).intersects(opponent_hand.get_global_rect()):
				conflicts.append("hand:%d" % other_seat)
		for node_name in ["CenterPanel", "ActionButtonDock", "HandTray"]:
			var obstacle := scene.find_child(node_name, true, false) as Control
			if obstacle != null and archive_rect.grow(2.9).intersects(obstacle.get_global_rect()):
				conflicts.append(node_name)
		check(conflicts.is_empty(), "river %d archive keeps three pixels clear of all river faces, meld lanes and other pagers at %s (rect=%s conflicts=%s)" % [seat, viewport_size, archive_rect, conflicts])


func check_table_chrome_lifecycle(scene: Node, output_dir: String) -> void:
	await prepare_offline_reading_fixture(scene)
	scene.ai_assist_enabled = false
	for seat in [1, 2, 3]:
		scene.players[seat]["hand"] = ["E", "S", "W", "N", "1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W"]
	scene.dealer_seat = 0
	scene.ai_state_revision += 1
	scene.render_game()
	await settle()
	check_all_seat_reading(scene)
	await check_wide_seat_text_toggle(scene)
	var dock := scene.find_child("ActionButtonDock", true, false) as TextureRect
	check(dock != null and dock.get_meta("guofeng_surface_key", "") == "battle_actions_jiangnan_gpt" and dock.modulate == Color.WHITE and dock.self_modulate == Color.WHITE, "ordinary actions share the authored Jiangnan ink dock")
	check(scene.find_child("ActionIntentDock", true, false) == null, "ordinary play avoids a redundant intent strip above the actions")
	var previous: Button = null
	for button in scene.action_bar_buttons():
		check(button.size.x >= 44.0 and button.size.y >= 44.0 and dock.get_global_rect().grow(6.0).encloses(button.get_global_rect()), "%s keeps a real 44px target inside the action dock" % button.text)
		if previous != null:
			check(not previous.get_global_rect().intersects(button.get_global_rect()), "ordinary actions have separate native hit rectangles")
		previous = button
		button.grab_focus()
		await process_frame
		var plate := button.get_node_or_null("ButtonFocusPlate") as TextureRect
		var marker := button.find_child("ActionButtonFocusMarker", true, false) as Label
		check(button.has_focus() and plate != null and plate.modulate.a == 1.0 and marker != null and marker.visible, "%s exposes its keyboard focus on the shared dock" % button.text)
		check(button.get_theme_color("font_focus_color").r < 0.3, "%s uses dark ink on its focused paper face" % button.text)
	if previous != null:
		previous.release_focus()

	for retired in ["ActionDock3DCastShadow", "ActionDock3DRearShell", "ActionDock3DFrontApron", "ActionButtonDockPulseDriver", "ActionIntentRail", "IntentPanelPlate"]:
		check(scene.find_child(retired, true, false) == null, "table chrome does not rebuild retired ornament %s" % retired)
	var self_status := scene.find_child("SeatCompactStatus_0", true, false) as Label
	check(self_status != null and self_status.text == "行牌", "current self seat exposes a readable native turn fact")
	await save_reading_capture(scene, output_dir, "action_dock_idle", action_seat_state(scene))
	var identities: Dictionary = {}
	for node_name in ["ActionButtonDock", "ActionIntentDock", "SeatPanel_0", "SeatPanel_1", "SeatPanel_2", "SeatPanel_3"]:
		var owner := scene.find_child(node_name, true, false)
		if owner != null:
			identities[node_name] = owner.get_instance_id()
	scene.render_game()
	await settle()
	for node_name in identities:
		var owner := scene.find_child(node_name, true, false)
		check(owner != null and owner.get_instance_id() == identities[node_name], "%s retains its actual instance without an empty shadow dependency" % node_name)
	scene.ai_assist_enabled = true
	scene.render_game()
	await settle()
	var advice := scene.find_child("RecommendedDiscardButton", true, false) as Button
	var restart := scene.find_child("OfflineRestartButton", true, false) as Button
	check(advice != null and restart != null, "ordinary assisted play retains its native recommendation and restart actions")
	var buttons: Array[Button] = scene.action_bar_buttons()
	var grouped_dock := scene.find_child("ActionButtonDock", true, false) as Control
	for index in range(buttons.size()):
		var button := buttons[index]
		check(button.size.x >= 50.0 and button.size.y >= 44.0, "assisted play keeps its existing 50x44 target for %s" % button.text)
		check(grouped_dock != null and grouped_dock.get_global_rect().grow(1.0).encloses(button.get_global_rect()), "assisted play keeps the full %s target inside its dock" % button.text)
		var style := button.get_theme_stylebox("normal")
		var padding := style.get_content_margin(SIDE_LEFT) + style.get_content_margin(SIDE_RIGHT)
		check(button.get_theme_font("font").get_string_size(button.text, HORIZONTAL_ALIGNMENT_LEFT, -1, button.get_theme_font_size("font_size")).x + padding <= button.size.x + 0.5, "assisted play shows the complete %s label" % button.text)
		if index > 0:
			check(buttons[index - 1].get_global_rect().end.x <= button.get_global_rect().position.x, "assisted actions keep distinct hit rectangles")
	if advice != null:
		advice.grab_focus()
		await settle(0.02)
		check(advice.has_focus() and advice.get_theme_color("font_focus_color").r < 0.3, "the recommendation has a readable paper focus face")
	await save_reading_capture(scene, output_dir, "action_dock_grouped", action_seat_state(scene))
	if advice != null:
		advice.release_focus()
	if not buttons.is_empty():
		var last_tool: Button = buttons.back()
		last_tool.grab_focus()
		await settle(0.02)
		var marker := last_tool.find_child("ActionButtonFocusMarker", true, false) as Label
		check(last_tool.has_focus() and marker != null and marker.visible and grouped_dock.get_global_rect().grow(1.0).encloses(last_tool.get_global_rect()), "the last tool keeps its full focused target inside the dock")
		await save_reading_capture(scene, output_dir, "action_dock_tools_focus", action_seat_state(scene))
		last_tool.release_focus()
	scene.ai_assist_enabled = false
	var river_faces := ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W"]
	for seat in range(4):
		scene.players[seat]["flowers"] = 8
		scene.players[seat]["score"] = 32000 + seat * 1000
		scene.players[seat]["discards"] = []
		for discard_index in range(35):
			scene.players[seat]["discards"].append(river_faces[discard_index % river_faces.size()])
	scene.ai_state_revision += 1
	scene.render_game()
	await settle()
	check_all_seat_reading(scene)
	for seat in range(4):
		var info: Dictionary = scene.get_player_info(seat)
		var meta := scene.find_child("SeatCompactMeta_%d" % seat, true, false) as Label
		var score := scene.find_child("SeatCompactScore_%d" % seat, true, false) as Label
		check(info["flowers"] == 8 and info["score"] == 32000 + seat * 1000 and meta != null and meta.text.contains("花8") and score != null and score.text == scene.seat_score_text(info), "seat %d displays the current capacity facts rather than the warmed old player-info cache" % seat)
	check_discard_archive_separation(scene, scene.effective_viewport_size())
	await save_reading_capture(scene, output_dir, "action_seats_capacity", action_seat_state(scene))
	for seat in [1, 3]:
		scene.last_discard = str(scene.get_discards(seat).back())
		scene.last_discard_seat = seat
		scene.render_game()
		await settle()
		var archive := scene.find_child("DiscardRiverArchiveButton_%d" % seat, true, false) as Button
		var grid := scene.find_child("DiscardGrid_%d" % seat, true, false) as GridContainer
		check(grid != null and grid.get_child_count() >= 3, "side river %d exposes at least three recent discards" % seat)
		if archive != null and grid != null:
			var latest_start := int(archive.get_meta("window_start", -1))
			var latest := scene.find_child("RecentDiscardTile_%d" % seat, true, false) as Control
			var marker := scene.find_child("LastDiscardFocusMarker", true, false) as Control
			check(latest != null and marker != null and marker.get_global_rect().position.distance_to(latest.get_global_rect().position) <= 0.5 and marker.size.distance_to(latest.size) <= 0.5, "side river %d latest frame follows its actual final tile" % seat)
			await activate_button(archive, "mouse" if seat == 1 else "touch")
			await settle()
			archive = scene.find_child("DiscardRiverArchiveButton_%d" % seat, true, false) as Button
			grid = scene.find_child("DiscardGrid_%d" % seat, true, false) as GridContainer
			check(archive != null and grid != null and int(archive.get_meta("window_start", -1)) < latest_start and int(grid.get_child(0).get_meta("discard_source_index", -1)) == int(archive.get_meta("window_start", -1)), "side river %d native input opens the correct earlier page" % seat)
			if archive != null and grid != null and grid.get_child_count() > 0:
				var first_index := int(archive.get_meta("window_start", -1))
				check(str(grid.get_child(0).get_meta("discard_tile_code", "")) == str(scene.get_discards(seat)[first_index]), "side river %d displays the earlier page's actual tile face" % seat)
			check_discard_archive_separation(scene, scene.effective_viewport_size())
			if seat == 1:
				await save_reading_capture(scene, output_dir, "river_history", action_seat_state(scene))
			check(scene.find_child("LastDiscardFocusMarker", true, false) == null, "side river %d hides the latest frame on a history page" % seat)
			scene.discard_window_start_by_seat[seat] = 0
			scene.render_game()
			await settle()
			archive = scene.find_child("DiscardRiverArchiveButton_%d" % seat, true, false) as Button
			check_discard_archive_separation(scene, scene.effective_viewport_size())
			if seat == 1:
				await save_reading_capture(scene, output_dir, "river_first", action_seat_state(scene))
			await activate_button(archive, "key")
			await settle()
			archive = scene.find_child("DiscardRiverArchiveButton_%d" % seat, true, false) as Button
			latest = scene.find_child("RecentDiscardTile_%d" % seat, true, false) as Control
			marker = scene.find_child("LastDiscardFocusMarker", true, false) as Control
			check(archive != null and int(archive.get_meta("window_start", -1)) == latest_start and latest != null and int(latest.get_meta("discard_source_index", -1)) == scene.get_discards(seat).size() - 1 and str(latest.get_meta("discard_tile_code", "")) == str(scene.get_discards(seat).back()) and marker != null and marker.get_global_rect().position.distance_to(latest.get_global_rect().position) <= 0.5, "side river %d keyboard returns to the actual latest tile and frame" % seat)
	# This is a visual capacity fixture, deliberately beyond a legal tile ledger.
	# Exercise the compact top pager together with every occupied meld lane.
	var melds := [["1W", "1W", "1W"], ["2T", "3T", "4T"], ["5B", "5B", "5B"], ["R", "R", "R", "R"]]
	for seat in range(4):
		scene.players[seat]["melds"] = melds.duplicate(true)
	# Exercise the real bottom latest-discard frame in this capacity fixture.
	scene.last_discard = str(scene.get_discards(0).back())
	scene.last_discard_seat = 0
	scene.ai_assist_enabled = true
	scene.ai_state_revision += 1
	scene.render_game()
	await settle()
	check_meld_group_pads(scene)
	check_discard_archive_separation(scene, scene.effective_viewport_size())
	check_advisor_obstacles(scene)
	var capacity_state := action_seat_state(scene)
	capacity_state["actual_geometry"] = check_actual_wall_clearance(scene)
	await save_reading_capture(scene, output_dir, "action_seats_meld_capacity", capacity_state)
	await check_meld_pagination_inputs(scene, melds)
	var kong_melds := [["1W", "1W", "1W", "1W"], ["2T", "2T", "2T", "2T"], ["5B", "5B", "5B", "5B"], ["R", "R", "R", "R"]]
	for seat in range(4):
		scene.players[seat]["melds"] = kong_melds.duplicate(true)
		scene.meld_window_start_by_seat.erase(seat)
	scene.ai_state_revision += 1
	scene.render_game()
	await settle()
	await check_meld_pagination_inputs(scene, kong_melds)
	check_discard_archive_separation(scene, scene.effective_viewport_size())
	check_actual_wall_clearance(scene)
	await save_reading_capture(scene, output_dir, "action_seats_all_kongs", action_seat_state(scene))
	for seat in range(4):
		scene.players[seat]["melds"] = [["1W", "1W", "1W"]]
	scene.ai_state_revision += 1
	scene.render_game()
	await settle()
	check_meld_group_pads(scene)
	await save_reading_capture(scene, output_dir, "action_seats_single_meld", action_seat_state(scene))


func check_countdown_lifecycle(scene: Node, output_dir: String) -> void:
	await prepare_offline_reading_fixture(scene)
	set_offline_pending_claim_fixture(scene, "peng")
	scene.offline_pending_claim["deadline_msec"] = Time.get_ticks_msec() + 11000
	scene.update_pending_claim_live_state()
	await settle()
	var timer := scene.find_child("PendingClaimTimerArt", true, false) as Control
	var text := scene.find_child("PendingClaimTimerText", true, false) as Label
	var warning := scene.find_child("PendingClaimAutoPassWarning", true, false) as Label
	check(timer != null and timer.get_meta("guofeng_surface_key", "") == "menu_card_readable_gpt" and text != null and text.text == scene.pending_claim_timer_text(), "native countdown reads the actual long response deadline")
	check(warning != null and warning.visible and warning.text == "到0自动过", "the default timeout consequence is visible before the final three seconds")
	if timer != null:
		check_native_reading_group([text, warning], timer, "native countdown")
	await save_reading_capture(scene, output_dir, "action_countdown_open", action_seat_state(scene))
	scene.offline_pending_claim["deadline_msec"] = Time.get_ticks_msec() + 2000
	scene.update_pending_claim_live_state()
	check(text != null and text.text == scene.pending_claim_timer_text() and text.text.contains("秒") and warning != null and warning.visible and warning.text.contains("将自动过"), "live final-three-second text updates in place without rebuilding the countdown")
	if timer != null:
		check_native_reading_group([text, warning], timer, "urgent native countdown")
	scene.offline_pending_claim["deadline_msec"] = Time.get_ticks_msec() - 1
	scene.update_pending_claim_live_state()
	await settle()
	check(scene.offline_pending_claim.is_empty() and scene.players[0]["melds"].is_empty() and scene.pending_claim_auto_pass_feedback.contains("已自动过"), "zero seconds commits one real pass, not a decorative timer completion")
	check(scene.find_child("PendingClaimTimerText", true, false) == null, "expired response removes the stale countdown from the new turn")
	var feedback := scene.find_child("ActionIntentText", true, false) as Label
	check(feedback != null and feedback.text.contains("已自动过"), "the subsequent action reading lane shows the actual automatic-pass result")
	await save_reading_capture(scene, output_dir, "action_countdown_expired", action_seat_state(scene))


func check_normal_action_capacity(scene: Node, output_dir: String) -> void:
	if scene.effective_viewport_size().y > 560.0:
		return
	for capacity in [7, 8]:
		await prepare_offline_reading_fixture(scene)
		scene.offline_restart_confirming = false
		if capacity == 7:
			scene.players[0]["hand"] = ["1W", "1W", "1W", "1W", "2W", "3W", "4T", "4T", "4T", "5T", "5T", "5T", "6B", "6B"]
		else:
			scene.players[0]["hand"] = ["1W", "1W", "1W", "1W", "2W", "3W", "5W", "6W", "7W", "8B", "8B"]
			scene.players[0]["melds"] = [["7W", "7W", "7W"]]
		scene.clear_ai_report_cache()
		scene.ai_state_revision += 1
		scene.render_game()
		await settle()
		check(scene.can_win_for_seat(0) and scene.first_concealed_gang_tile(0) == "1W", "capacity %d fixture legally offers self win and concealed kong" % capacity)
		if capacity == 8:
			check(scene.first_added_gang_tile(0) == "7W", "eight-action fixture also legally offers added kong")
		var popup := scene.find_child("NormalActionOverflowMenu", true, false) as PopupMenu
		var more := scene.find_child("NormalActionOverflowButton", true, false) as Button
		var dock := scene.find_child("ActionButtonDock", true, false) as Control
		var buttons: Array[Button] = scene.action_bar_buttons()
		check(popup != null and more != null and buttons.size() <= 5, "capacity %d keeps its primary actions and one native More entry" % capacity)
		if popup == null or more == null:
			continue
		check(popup.item_count + buttons.size() - 1 >= capacity, "capacity %d preserves every original game and tool callback" % capacity)
		for button in buttons:
			check(button.size.x >= 50.0 and button.size.y >= 44.0 and dock.get_global_rect().grow(1.0).encloses(button.get_global_rect()), "capacity %d retains %s inside the dock with its real target" % [capacity, button.text])
		var hand_before: Array = scene.get_self_hand().duplicate()
		await activate_button(more, "key")
		check(popup.visible and scene.get_self_hand() == hand_before, "capacity %d opens the native More menu without discarding" % capacity)
		check(popup.size.y >= popup.item_count * 44, "capacity %d menu preserves forty-four-pixel item rows" % capacity)
		var state := action_seat_state(scene)
		state["capacity"] = capacity
		state["menu_item_count"] = popup.item_count
		state["menu_items"] = []
		for item in range(popup.item_count):
			state["menu_items"].append(popup.get_item_text(item))
		await save_reading_capture(scene, output_dir, "action_capacity_%d_more" % capacity, state)
		await send_key(KEY_ESCAPE, 0)
		await settle()
		check(not popup.visible and more.has_focus() and scene.get_self_hand() == hand_before, "capacity %d closes More and restores its native focus without a game action" % capacity)
		if capacity == 8:
			await activate_button(more, "key")
			var restart_index := -1
			for item in range(popup.item_count):
				if popup.get_item_text(item) == "重开":
					restart_index = item
			check(restart_index >= 0, "More retains the original restart action")
			if restart_index >= 0:
				popup.set_focused_item(restart_index)
				await send_key(KEY_ENTER, 0)
				await settle()
				check(scene.offline_restart_confirming and scene.get_self_hand() == hand_before, "native menu restart requests confirmation before changing the game")
				scene.render_game()
				await settle()
				var confirmation: Array[Button] = scene.action_bar_buttons()
				check(confirmation.size() == 2 and scene.find_child("OfflineRestartConfirmButton", true, false) != null and scene.find_child("OfflineRestartCancelButton", true, false) != null, "restart confirmation owns a separate two-action lane")
				await save_reading_capture(scene, output_dir, "action_capacity_8_restart", action_seat_state(scene))
				var cancel := scene.find_child("OfflineRestartCancelButton", true, false) as Button
				await activate_button(cancel, "key")
				await settle()
				check(not scene.offline_restart_confirming and scene.get_self_hand() == hand_before, "cancelling restart restores the game and its complete hand")
				scene.render_game()
				await settle()
				check(scene.find_child("NormalActionOverflowButton", true, false) != null, "cancelled restart restores the bounded primary and More actions")
