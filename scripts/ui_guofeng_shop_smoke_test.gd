extends "res://scripts/ui_reading_evidence_smoke_test.gd"


func shop_capture_state(scene: Node) -> Dictionary:
	var rows: Array[Dictionary] = []
	for item_id in scene.shop_item_ids_shared():
		var row := scene.find_child("ShopItemRow_%s" % item_id, true, false) as Control
		var command := scene.find_child("ShopBuyButtonCommand_%s" % item_id, true, false) as Label
		var button := scene.find_child("ShopItemBuyButton_%s" % item_id, true, false) as Button
		if row != null and command != null and button != null:
			rows.append({"item_id": item_id, "rect": str(row.get_global_rect()), "command": command.text, "disabled": button.disabled, "face_key": button.get_meta("guofeng_button_face_key", ""), "inventory_count": scene.get_item_count(item_id)})
	var scroll := scene.find_child("ShopItemsScroll", true, false) as ScrollContainer
	var focused := root.gui_get_focus_owner()
	var focus_markers := 0
	for marker in scene.find_children("ShopFocusMarker", "Label", true, false):
		if (marker as Label).is_visible_in_tree():
			focus_markers += 1
	var toast_text := ""
	if scene.toast_current != null and is_instance_valid(scene.toast_current):
		toast_text = str(scene.toast_current.get_meta("toast_text", ""))
	return {"surface_key": "settings_readable_gpt", "gems": scene.currency.get("gems", 0), "coins": scene.currency.get("coins", 0), "rows": rows, "scroll_value": scroll.scroll_vertical if scroll != null else -1, "focused_control": str(focused.name) if focused != null else "", "visible_focus_markers": focus_markers, "toast_text": toast_text}


func check_shop_feedback_lane(scene: Node) -> void:
	var toast := scene.toast_current as Control
	var message := toast.find_child("ToastMessageLabel", true, false) as Label if toast != null else null
	var footer := scene.find_child("ShopCabinetFooterPanel", true, false) as Control
	var body := scene.find_child("ShopCabinetFooterBody", true, false) as Control
	check(toast != null and bool(toast.get_meta("shop_inline_feedback", false)) and message != null, "shop feedback uses the native footer message rather than a header overlay")
	if toast == null or message == null or footer == null or body == null:
		return
	check(footer.get_global_rect().grow(1.0).encloses(message.get_global_rect()) and message.size.y >= message.get_minimum_size().y and not body.visible, "the complete feedback text replaces the footer copy without duplicate text or overflow (footer=%s message=%s minimum=%s hidden=%s)" % [footer.get_global_rect(), message.get_global_rect(), message.get_minimum_size(), not body.visible])
	for node_name in ["ShopTitle", "ShopCurrencyValue_coins", "ShopCurrencyValue_gems", "ShopBackButton", "ShopItemsScroll", "ShopCabinetFooterInventoryBadge"]:
		var control := scene.find_child(node_name, true, false) as Control
		check(control != null and not control.get_global_rect().intersects(message.get_global_rect()), "shop feedback keeps %s unobstructed" % node_name)


func check_shop_paper_layout(scene: Node) -> void:
	var paper := scene.find_child("ShopGuofengPaperSurface", true, false) as TextureRect
	var garden := scene.find_child("ShopGuofengGardenBackdrop", true, false) as TextureRect
	check(paper != null and paper.texture == scene.optional_gpt_illustration_texture("settings_readable_gpt") and paper.modulate == Color.WHITE, "the shop has one full opaque authored paper surface")
	check(garden != null and garden.texture == scene.optional_gpt_illustration_texture("menu_guofeng_moonlit"), "the shop shares the authored moonlit garden with the home")
	for obsolete in ["ShopCabinet3DCastShadow", "ShopDisplayCabinet3DShell", "ShopTransactionMapArt", "ShopItemValueRoute", "ShopItemEnergyRail", "ShopItemCountBadgeArt", "ShopBuyButtonArt", "ShopCabinetFooter3DDepthEdge"]:
		check(scene.find_child(obsolete, true, false) == null, "the paper shop removes obsolete decoration %s" % obsolete)
	var scroll := scene.find_child("ShopItemsScroll", true, false) as ScrollContainer
	var footer := scene.find_child("ShopCabinetFooterPanel", true, false) as Control
	var hit_target := scene.find_child("ShopItemsScrollHitTarget", true, false) as Control
	check(scroll != null and footer != null and scroll.get_global_rect().end.y + 8.0 <= footer.get_global_rect().position.y, "the list keeps an eight-pixel gap before the footer")
	check(hit_target != null and hit_target.size.x >= 44.0 and hit_target.mouse_filter == Control.MOUSE_FILTER_STOP, "the authored shop scrollbar keeps its native forty-four-pixel drag target")
	var back := scene.find_child("ShopBackButton", true, false) as Button
	check(back != null and back.size.y >= 44.0 and back.has_focus() and back.get_theme_color("font_focus_color").get_luminance() <= 0.24 and back.get_meta("guofeng_button_face_key", "") == "button_face_jiangnan_gpt", "the default focused secondary return has readable dark ink on paper and a native target")
	check(shop_capture_state(scene)["visible_focus_markers"] == 1, "only the currently focused return action shows its native focus marker")
	for label_name in ["ShopTitle", "ShopCurrencyValue_coins", "ShopCurrencyValue_gems", "ShopCabinetFooterTitle", "ShopCabinetFooterBody"]:
		var label := scene.find_child(label_name, true, false) as Label
		check(label != null and label.get_theme_color("font_color").get_luminance() <= 0.24 and label.size.y + 1.0 >= label.get_minimum_size().y, "paper copy %s has dark ink and a complete measured height" % label_name)
	for item_id in scene.shop_item_ids_shared():
		var row := scene.find_child("ShopItemRow_%s" % item_id, true, false) as Control
		var face := row.find_child("ShopItemRowGptPlate", true, false) as TextureRect if row != null else null
		var title := scene.find_child("ShopItemName_%s" % item_id, true, false) as Label
		var description := scene.find_child("ShopItemDescription_%s" % item_id, true, false) as Label
		var inventory := scene.find_child("ShopItemCountBadge_%s" % item_id, true, false) as Control
		var button := scene.find_child("ShopItemBuyButton_%s" % item_id, true, false) as Button
		var command := scene.find_child("ShopBuyButtonCommand_%s" % item_id, true, false) as Label
		check(row != null and face != null and face.texture == scene.optional_gpt_illustration_texture("menu_card_readable_gpt") and face.modulate == Color.WHITE, "item %s owns one authored paper face" % item_id)
		check(title != null and description != null and inventory != null and button != null and command != null, "item %s preserves its name description inventory and purchase controls" % item_id)
		if row == null or title == null or description == null or inventory == null or button == null or command == null:
			continue
		check(row.get_global_rect().grow(1.0).encloses(title.get_global_rect()) and row.get_global_rect().grow(1.0).encloses(description.get_global_rect()), "item %s keeps complete copy inside its row" % item_id)
		check(not title.get_global_rect().intersects(description.get_global_rect()) and not description.get_global_rect().intersects(inventory.get_global_rect()) and not inventory.get_global_rect().intersects(button.get_global_rect()), "item %s separates title description owned count and purchase target" % item_id)
		check(title.size.y + 1.0 >= title.get_minimum_size().y and description.size.y + 1.0 >= description.get_minimum_size().y, "item %s preserves the full font-height lanes" % item_id)
		check(title.get_theme_color("font_color").get_luminance() <= 0.24 and description.get_theme_color("font_color").get_luminance() <= 0.24, "item %s keeps readable ink in high contrast as well as default mode" % item_id)
		check(button.size.x >= 100.0 and button.size.y >= 44.0 and label_text_width(command, command.text) <= command.size.x + 1.0, "item %s has a usable action and complete price or shortage text" % item_id)
		var cost := int(button.get_meta("shop_cost_gems", -1))
		var gap := int(button.get_meta("currency_gap_gems", -1))
		var expected_copy := "%d玉·差%d玉" % [cost, gap] if button.disabled else "购买 %d玉符" % cost
		check(command.text == expected_copy, "item %s visibly shows its total price and exact shortage when unavailable" % item_id)
		if button.disabled:
			var button_face := button.get_node_or_null("GptButtonFacePlate") as TextureRect
			var button_edges := button_face.get_node_or_null("AuthoredBitmapEdges") as NinePatchRect if button_face != null else null
			check(button_edges != null and button_edges.visible and button_edges.texture == scene.optional_gpt_illustration_texture("button_face_jiangnan_gpt"), "item %s keeps the authored outlined unavailable purchase face" % item_id)
		check(command.get_theme_font_size("font_size") >= scene.accessibility_font_size(14), "item %s keeps its complete purchase command at a readable action font floor" % item_id)
		check(button.get_global_rect().end.x + 4.0 <= hit_target.get_global_rect().position.x, "item %s keeps the buy action outside the scrollbar hit lane" % item_id)
		check(scene.find_child("ShopItemTextReadabilityPanel_%s" % item_id, true, false) == null and scene.find_child("ShopItem3DCharmPlinth_%s" % item_id, true, false) == null, "item %s does not add another text pad or display plinth" % item_id)


func check_shop_purchase_inputs(scene: Node, output_dir: String) -> void:
	scene.currency = {"coins": 100, "gems": 0}
	scene.inventory = {"swap_card": 2}
	scene.save_currency()
	scene._show_shop_screen_impl()
	await settle(0.12)
	check_shop_paper_layout(scene)
	await save_reading_capture(scene, output_dir, "shop_shortage", shop_capture_state(scene))
	var blocked := scene.find_child("ShopItemBuyButton_swap_card", true, false) as Button
	check(blocked != null and blocked.disabled and blocked.get_meta("currency_gap_gems", 0) == 5, "zero gems disables the real purchase with the exact five-gem gap")
	if blocked != null:
		var center := blocked.get_global_rect().get_center()
		await send_left_button(center, true)
		await send_left_button(center, false)
		await send_screen_touch(center, true)
		await send_screen_touch(center, false)
	check(int(scene.currency.get("gems", -1)) == 0 and scene.get_item_count("swap_card") == 2, "mouse and touch cannot spend through an unavailable purchase")
	var recovery := scene.find_child("ShopGetGemsButton", true, false) as Button
	check(recovery != null and recovery.size.y >= 44.0 and recovery.tooltip_text.contains("未接入充值渠道"), "the empty shop offers an honest native currency explanation rather than a dead end")
	await activate_button(recovery, "key")
	check(scene.mode == "shop" and int(scene.currency.get("gems", -1)) == 0 and scene.get_item_count("swap_card") == 2, "keyboard currency recovery explains the limitation without changing balances")
	await settle()
	check_shop_feedback_lane(scene)
	await save_reading_capture(scene, output_dir, "shop_recovery", shop_capture_state(scene))
	scene.dismiss_active_toast()
	var restored_body := scene.find_child("ShopCabinetFooterBody", true, false) as Control
	check(restored_body != null and restored_body.visible and scene.toast_current == null, "dismissing recovery feedback restores the original footer explanation")
	scene.currency["gems"] = 100
	scene.save_currency()
	scene._show_shop_screen_impl()
	await settle(0.10)
	var range_label := scene.find_child("ShopItemsScrollPosition", true, false) as Label
	var item_scroll := scene.find_child("ShopItemsScroll", true, false) as ScrollContainer
	check(range_label != null and item_scroll != null and range_label.get_global_rect().position.y >= item_scroll.get_global_rect().end.y + 4.0 - 0.1, "shop range text has a separate measured lane four pixels below the clipped catalogue")
	await save_reading_capture(scene, output_dir, "shop_available", shop_capture_state(scene))
	var purchase_probes: Array[Dictionary] = []
	for modality in ["mouse", "touch", "key"]:
		scene.dismiss_active_toast()
		var buy := scene.find_child("ShopItemBuyButton_swap_card", true, false) as Button
		var scroll := scene.find_child("ShopItemsScroll", true, false) as ScrollContainer
		if scroll != null and buy != null:
			scroll.ensure_control_visible(buy)
			await settle()
		var gems_before: int = scene.currency.get("gems", 0)
		var items_before: int = scene.get_item_count("swap_card")
		check(buy != null and not buy.disabled and buy.get_meta("guofeng_button_face_key", "") == "menu_ink_primary", "the available %s purchase uses a distinct ink action" % modality)
		# Observe the real production callback before any software-rendered frames
		# elapse. Freeze only this screenshot owner; Toast's timed lifecycle has
		# its own tests. Repeated purchases must not share an older owner here.
		var probe := {"modality": modality, "owner_id": 0, "text": "", "frozen_for_capture": false}
		buy.pressed.connect(func() -> void:
			if scene.toast_current != null and is_instance_valid(scene.toast_current):
				probe["owner_id"] = scene.toast_current.get_instance_id()
				probe["text"] = str(scene.toast_current.get_meta("toast_text", ""))
				if scene.toast_tween != null and is_instance_valid(scene.toast_tween):
					# Deferred native layout may resume a hidden toast. A zero
					# speed keeps this observed owner stable across that reflow.
					scene.toast_tween.set_speed_scale(0.0)
					probe["frozen_for_capture"] = true
		)
		await activate_button(buy, modality)
		purchase_probes.append(probe)
		check(int(probe["owner_id"]) > 0 and str(probe["text"]).begins_with("购买成功") and bool(probe["frozen_for_capture"]), "the %s production purchase creates its own real feedback before capture timing is frozen" % modality)
		await settle(0.10)
		check(int(scene.currency.get("gems", 0)) == gems_before - 5 and scene.get_item_count("swap_card") == items_before + 1 and int(scene.currency.get("coins", 0)) == 100, "a real %s purchase debits gems once adds one item and preserves coins" % modality)
		var restored := scene.find_child("ShopItemBuyButton_swap_card", true, false) as Button
		check(scene.mode == "shop" and restored != null and restored.has_focus(), "the %s purchase redraw restores native focus to the same item" % modality)
		check(shop_capture_state(scene)["visible_focus_markers"] == 1, "the %s purchase restores exactly one visible native focus marker" % modality)
		var persisted := ConfigFile.new()
		check(persisted.load(scene.ECONOMY_PATH) == OK and int(persisted.get_value("currency", "gems", -1)) == gems_before - 5 and int((persisted.get_value("inventory", "items", {}) as Dictionary).get("swap_card", -1)) == items_before + 1, "the %s purchase persists the same balance and inventory" % modality)
	scene.clear_fx_overlays()
	await settle()
	check_shop_feedback_lane(scene)
	check(scene.toast_current != null and str(scene.toast_current.get_meta("toast_text", "")).begins_with("购买成功"), "the purchased evidence shows actual purchase feedback rather than an older recovery notice")
	var purchased_state := shop_capture_state(scene)
	purchased_state["feedback_capture_probes"] = purchase_probes
	await save_reading_capture(scene, output_dir, "shop_purchased", purchased_state)
	if scene.toast_tween != null and is_instance_valid(scene.toast_tween):
		scene.toast_tween.set_speed_scale(1.0)
		scene.toast_tween.play()
	var scroll := scene.find_child("ShopItemsScroll", true, false) as ScrollContainer
	var last_row := scene.find_child("ShopItemRow_double_coins", true, false) as Control
	if scroll != null and last_row != null:
		last_row.custom_minimum_size.y = maxf(last_row.custom_minimum_size.y, scroll.size.y + 240.0)
		await settle(0.08)
		var scrollbar := scroll.get_v_scroll_bar()
		check(scrollbar.max_value > scrollbar.page, "the real final item supports a native overflow range")
		scroll.grab_focus()
		await send_key(KEY_END, 0)
		check(scrollbar.value >= scrollbar.max_value - scrollbar.page - 1.0, "End reaches the native bottom of the product list")
		await send_key(KEY_HOME, 0)
		check(scrollbar.value <= 1.0, "Home returns to the first product")
		var hit := scene.find_child("ShopItemsScrollHitTarget", true, false) as Control
		var thumb := scene.find_child("ShopItemsScrollThumb", true, false) as Control
		check(hit != null and thumb != null, "the overflow list retains its custom input owner and bitmap thumb")
		if hit != null and thumb != null:
			hit.grab_focus()
			await send_key(KEY_PAGEDOWN, 0)
			check(scrollbar.value > 0.0, "PageDown advances the real product list")
			await send_key(KEY_HOME, 0)
			var start := thumb.get_global_rect().get_center()
			var finish := Vector2(start.x, hit.get_global_rect().position.y + hit.size.y * 0.70)
			await send_screen_touch(start, true)
			var before_drag := scrollbar.value
			await send_screen_drag(start, finish)
			await send_screen_touch(finish, false)
			check(scrollbar.value > before_drag + 1.0, "touch dragging the authored thumb moves the native product range")
			check(absf(float(thumb.get_meta("shop_scroll_progress", -1.0)) - scrollbar.value / (scrollbar.max_value - scrollbar.page)) <= 0.01, "touch input leaves the authored thumb synchronized with the real list")
	await send_key(KEY_ESCAPE, 0)
	check(scene.mode == "menu", "Escape leaves the shop through the native menu route")


func run() -> void:
	print("=== guofeng shop UI smoke START ===")
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
	var large_contrast: bool = arguments.size() > 1 and arguments[1] == "large_contrast"
	DisplayServer.window_set_size(viewport_size)
	root.size = viewport_size
	root.content_scale_size = viewport_size
	var suffix := "_large_contrast" if large_contrast else ""
	var capture_root := OS.get_environment("YUNZHUO_GUOFENG_SHOP_CAPTURE_DIR")
	if capture_root.is_empty():
		capture_root = "res://build/qa/guofeng_shop"
	var output_dir := ProjectSettings.globalize_path("%s/%dx%d%s" % [capture_root, viewport_size.x, viewport_size.y, suffix])
	check(DirAccess.make_dir_recursive_absolute(output_dir) == OK, "the shop evidence directory is writable")
	var scene = load("res://Main.tscn").instantiate()
	if scene.get_script() == null:
		check(false, "the runtime script loads before capturing shop evidence")
		scene.free()
		quit(1)
		return
	root.add_child(scene)
	await settle(0.10)
	var user_state := capture_smoke_state(scene)
	scene.set_process(false)
	scene.music_enabled = false
	scene.sfx_enabled = false
	scene.tts_enabled = false
	scene.fx_enabled = false
	scene.reduce_motion_enabled = true
	scene.large_text_enabled = large_contrast
	scene.high_contrast_enabled = large_contrast
	scene.tutorial_step = scene.TUTORIAL_STEP_COMPLETE
	await check_shop_purchase_inputs(scene, output_dir)
	scene.shutdown_runtime()
	restore_smoke_state(scene, user_state)
	scene.queue_free()
	await process_frame
	print("=== RESULT: %s ===" % ("FAIL" if failed else "OK"))
	quit(1 if failed else 0)
