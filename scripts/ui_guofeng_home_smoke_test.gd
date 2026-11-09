extends "res://scripts/ui_reading_evidence_smoke_test.gd"


func check_settings_navigation(scene: Node, section_name: String) -> void:
	var navigation := scene.find_child("SettingsSectionNavigation", true, false) as Control
	var marker := scene.find_child("SettingsSectionActiveMarker", true, false) as Control
	var active_count := 0
	for node in scene.find_children("SettingsSectionNavButton_*", "Button", true, false):
		var button := node as Button
		if bool(button.get_meta("section_active", false)):
			active_count += 1
			check(str(button.get_meta("section_name", "")) == section_name and button.text.contains("当前") and button.text.ends_with(section_name), "native settings navigation names the section currently in view")
	check(navigation != null and str(navigation.get_meta("active_section", "")) == section_name and active_count == 1, "settings exposes exactly one current section after native input")
	var visible_count := 0
	for section in scene.find_children("SettingsSection_*", "Control", true, false):
		if section.is_visible_in_tree():
			visible_count += 1
			check(str(section.name) == "SettingsSection_%s" % section_name, "selected settings category owns the visible content")
	check(visible_count == 1, "only one settings category is visible and reachable")
	check(marker != null and marker.is_visible_in_tree() and str(marker.get_parent().name) == "SettingsSectionNavButton_%s" % section_name and str(marker.get_meta("marker_owner", "")) == section_name, "the single authored active marker follows the visible settings section")


func check_guofeng_home(scene: Node, output_dir: String) -> void:
	scene.tutorial_step = scene.TUTORIAL_STEP_COMPLETE
	scene.settings_panel_open = false
	scene.show_menu(true)
	await settle(0.10)
	var backdrop := scene.find_child("MenuGuofengBackdrop", true, false) as TextureRect
	check(backdrop != null and backdrop.texture == scene.optional_gpt_illustration_texture("menu_guofeng_moonlit"), "the home uses the existing authored moonlit garden without generated tile artwork")
	check(scene.find_child("MenuPrimary3DStage", true, false) == null and scene.find_child("MenuTitleReadingPlate", true, false) == null, "the home removes duplicate stage slabs and the title block")
	var primary := scene.find_child("MenuPrimaryOfflineCard", true, false) as Button
	var online := scene.find_child("MenuPrimaryOnlineCard", true, false) as Button
	var shop := scene.find_child("MenuPrimaryShopCard", true, false) as Button
	check(primary != null and online != null and shop != null and primary.has_focus(), "all three home actions remain native buttons with default offline keyboard focus")
	var faces := []
	for button in [primary, online, shop]:
		if button == null:
			continue
		var face := button.find_child("MenuCardGptFace", true, false) as TextureRect
		var title := button.find_child("MenuCardTitleLabel", true, false) as Label
		var subtitle := button.find_child("MenuCardSubtitleLabel", true, false) as Label
		var is_primary: bool = button == primary
		var key := "menu_entry_offline_gpt" if is_primary else ("menu_entry_online_gpt" if button == online else "menu_entry_shop_gpt")
		check(face != null and face.texture == scene.optional_gpt_illustration_texture(key) and str(button.get_meta("menu_entry_hierarchy", "")) == ("primary" if is_primary else "secondary"), "each home action owns exactly one authored face with explicit primary or secondary hierarchy")
		check(button.find_child("MenuCardTextBackplate", true, false) == null and button.find_child("MenuCardTopSheen", true, false) == null and button.find_child("MenuCardAccent", true, false) == null, "the home card contains no duplicate text pad or false progress bars")
		if face != null and title != null and subtitle != null:
			check(face.get_global_rect().grow(1.0).encloses(title.get_global_rect()) and face.get_global_rect().grow(1.0).encloses(subtitle.get_global_rect()) and not title.get_global_rect().intersects(subtitle.get_global_rect()), "the native title and subtitle share the complete quiet face without overlapping")
			check(title.size.y >= title.get_minimum_size().y and subtitle.size.y >= subtitle.get_minimum_size().y and button.size.y >= 44.0, "the home keeps full text-height lanes and practical action targets")
			faces.append({"name": str(button.name), "texture_key": key, "rect": str(button.get_global_rect()), "title": title.text, "subtitle": subtitle.text})
	check(primary != null and primary.tooltip_text.contains("入席开局") and primary.tooltip_text.contains("单机对局"), "the primary entry clearly promises a local game rather than an ambiguous AI demo")
	var tile_emblem := scene.find_child("MenuOfflineTileEmblem", true, false) as TextureRect
	check(tile_emblem != null and tile_emblem.texture == scene.tile_textures.get("E", null) and tile_emblem.modulate == Color.WHITE and tile_emblem.self_modulate == Color.WHITE and tile_emblem.mouse_filter == Control.MOUSE_FILTER_IGNORE, "offline entry reuses the original untinted 2D East tile as passive business artwork")
	for button in [primary, online, shop]:
		if button == null:
			continue
		var title := button.find_child("MenuCardTitleLabel", true, false) as Label
		var subtitle := button.find_child("MenuCardSubtitleLabel", true, false) as Label
		check(title != null and subtitle != null and label_text_width(title, title.text) <= title.size.x + 1.0 and label_text_width(subtitle, subtitle.text) <= subtitle.size.x + 1.0, "entry titles and subtitles fit completely in the quiet lane beside their artwork")
	check(scene.find_children("MenuFooterStatusRail_*", "", true, false).is_empty() and scene.find_child("MenuCurrencyBadgeArt", true, false) == null, "passive account status is not decorated as fake progress")
	for node_name in ["MenuCurrencyBadge", "MenuRankBadge", "MenuStatsBadge"]:
		var label := scene.find_child(node_name, true, false) as Label
		check(label != null and label_text_width(label, label.text) <= label.size.x + 1.0, "%s retains its complete visible account facts" % node_name)
	for entry in [["Rules", "rules"], ["Stats", "stats"], ["Achievements", "achievements"], ["DailyLogin", "daily_login"], ["Replay", "replay"]]:
		var button := scene.find_child("MenuQuick%sButton" % entry[0], true, false) as Button
		var icon := scene.find_child("MenuQuick%sIcon" % entry[0], true, false) as TextureRect
		var label := scene.find_child("MenuQuick%sLabel" % entry[0], true, false) as Label
		check(button != null and icon != null and label != null, "quick navigation %s has an authored icon and native action" % entry[1])
		if button != null and icon != null and label != null:
			check(button.get_global_rect().grow(1.0).encloses(icon.get_global_rect()) and button.get_global_rect().grow(1.0).encloses(label.get_global_rect()) and not icon.get_global_rect().intersects(label.get_global_rect()), "quick navigation %s keeps its whole icon and title inside the target" % entry[1])
	await save_reading_capture(scene, output_dir, "home", {"background_key": "menu_guofeng_moonlit", "faces": faces, "focused_control": str(root.gui_get_focus_owner().name)})
	await send_key(KEY_TAB, 0)
	await settle()
	check(root.gui_get_focus_owner() != null and root.gui_get_focus_owner() != primary, "the refined home preserves native keyboard navigation between actions")
	await save_reading_capture(scene, output_dir, "home_keyboard", {"focused_control": str(root.gui_get_focus_owner().name)})
	var settings := scene.find_child("MenuSettingsButton", true, false) as Button
	await activate_button(settings, "mouse")
	await settle(0.08)
	var panel := scene.find_child("SettingsPanel", true, false) as TextureRect
	check(scene.settings_panel_open and panel != null and panel.texture is AtlasTexture and (panel.texture as AtlasTexture).atlas == scene.optional_gpt_illustration_texture("settings_readable_gpt"), "the real settings action opens one opaque fine-edged authored paper panel")
	var tutorial_entry := scene.find_child("MenuTutorialButton", true, false) as Button
	check(tutorial_entry != null and tutorial_entry.get_theme_stylebox("disabled") is StyleBoxEmpty, "disabled background actions do not add native gray slabs around the paper modal")
	check(scene.find_children("SettingsConsole3D*", "", true, false).is_empty() and scene.find_children("SettingsSection3D*", "", true, false).is_empty(), "settings sections no longer stack shadow slabs rims and depth rectangles")
	check(scene.find_children("SettingRowGptPlate_*", "", true, false).is_empty() and scene.find_children("SettingRowTextReadabilityPanel_*", "", true, false).is_empty() and scene.find_child("SettingsOverviewRail", true, false) == null, "settings copy shares one paper surface without nested pads or passive meters")
	for section_name in ["声音", "体验", "系统"]:
		var section := scene.find_child("SettingsSection_%s" % section_name, true, false) as Control
		var grid := scene.find_child("SettingsSectionGrid_%s" % section_name, true, false) as GridContainer
		check(section != null and not section is TextureRect and grid != null, "all original settings groups remain native layouts on one paper surface")
	var close := scene.find_child("SettingsCloseButton", true, false) as Button
	check(close != null and close.size.x >= 44.0 and close.size.y >= 44.0 and scene.find_child("SettingsRuleVariantButton", true, false) != null, "settings retains its local-rule selector and full close target")
	var rule_selector := scene.find_child("SettingsRuleVariantButton", true, false) as Button
	check(rule_selector != null and close != null and not rule_selector.get_global_rect().intersects(close.get_global_rect()), "settings rule selector and close retain separate complete header targets")
	for header_name in ["SettingsRuleVariantLabel", "SettingsRuleVariantStatus", "SettingsOverviewSummary"]:
		var label := scene.find_child(header_name, true, false) as Label
		check(label != null and label.get_theme_color("font_color").get_luminance() <= 0.24, "settings header copy keeps dark readable ink in every accessibility profile")
	for navigation in scene.find_children("SettingsSectionNavButton_*", "Button", true, false):
		var button := navigation as Button
		var text_width := button.get_theme_font("font").get_string_size(button.text, HORIZONTAL_ALIGNMENT_LEFT, -1, button.get_theme_font_size("font_size")).x
		check(text_width <= button.size.x - 8.0, "settings section navigation shows its complete native active-state text")
	var row_evidence := []
	for category in ["声音", "体验", "系统"]:
		await activate_button(scene.find_child("SettingsSectionNavButton_%s" % category, true, false) as Button, "mouse")
		await settle()
		check_settings_navigation(scene, category)
		for action in scene.find_children("SettingRowButton_*", "Button", true, false):
			var button := action as Button
			if not button.is_visible_in_tree():
				continue
			var face := button.get_node_or_null("GptButtonFacePlate") as TextureRect
			var face_key := str(button.get_meta("guofeng_button_face_key", ""))
			var edges := face.get_node_or_null("AuthoredBitmapEdges") as NinePatchRect if face != null else null
			var actual_texture := edges.texture if edges != null and edges.visible else (face.texture if face != null else null)
			check(face != null and actual_texture == scene.optional_gpt_illustration_texture(face_key) and button.size.y >= 44.0, "each settings row keeps one authored native action and a forty-four-pixel target")
			if edges != null and edges.visible:
				var edge_rect := edges.get_global_rect()
				check(face.texture == null and edge_rect.position.distance_to(face.get_global_rect().position) < 0.5 and edge_rect.size.distance_to(face.get_global_rect().size) < 0.5 and edges.mouse_filter == Control.MOUSE_FILTER_IGNORE, "the single sliced bitmap fills its real native target after layout without intercepting input")
			check(button.find_child("SettingSwitchArt", true, false) == null and button.find_child("ResetProgressButtonArt", true, false) == null and button.find_child("AudioTestButtonArt", true, false) == null and button.find_child("BgmSwitchButtonArt", true, false) == null, "settings actions omit decorative switches locks and meter assemblies")
			var setting_title := str(button.name).trim_prefix("SettingRowButton_")
			var status := button.get_parent().find_child("SettingRowStatus_%s" % setting_title, true, false) as Label
			if category == "体验" and not scene.large_text_enabled and root.size.x > 960 and root.size.y > 560:
				check(status != null and label_text_width(status, status.text) <= status.size.x + 1.0, "ordinary two-column experience settings show the complete current state beside their bounded actions")
			if setting_title == "本地进度" and not scene.large_text_enabled and (root.size.x <= 960 or root.size.y <= 560):
				check(status != null and status.text == "清空续局·保留战绩" and label_text_width(status, status.text) <= status.size.x and status.size.y >= status.get_theme_font("font").get_height(status.get_theme_font_size("font_size")), "compact reset visibly preserves the complete save scope and retained statistics without shrinking text")
			row_evidence.append({"name": str(button.name), "text": button.text, "rect": str(button.get_global_rect()), "face_key": face_key, "status_text": status.text if status != null else "missing", "status_rect": str(status.get_global_rect()) if status != null else "missing", "status_height": status.size.y if status != null else 0.0, "status_minimum_height": status.get_minimum_size().y if status != null else 0.0, "status_font_height": status.get_theme_font("font").get_height(status.get_theme_font_size("font_size")) if status != null else 0.0})
		await save_reading_capture(scene, output_dir, "settings_" + str(category), {"active_section": category})
	check(row_evidence.size() == 13, "all thirteen original settings rows remain reachable across the three categories")
	await activate_button(scene.find_child("SettingsSectionNavButton_声音", true, false) as Button, "key")
	await save_reading_capture(scene, output_dir, "settings", {"panel_rect": str(panel.get_global_rect()) if panel != null else "missing", "surface_key": "settings_readable_gpt", "rows": row_evidence, "active_section": "声音"})
	var scroll := scene.find_child("SettingsLargeTextScroll", true, false) as ScrollContainer
	check((scroll != null) == scene.large_text_enabled, "large text retains its real settings scroll viewport")
	if scroll != null:
		var navigation := scene.find_child("SettingsSectionNavigation", true, false) as Control
		check(navigation != null and scroll.get_global_rect().position.y >= navigation.get_global_rect().end.y + 8.0, "large-text first-section reading viewport clears the resolved fixed navigation by eight pixels")
		scroll.grab_focus()
		await send_key(KEY_END, 0)
		await settle()
		check_settings_navigation(scene, "声音")
		check(scroll.has_focus(), "native End scrolls the current category while preserving keyboard focus")
		await send_key(KEY_HOME, 0)
		await settle()
		check_settings_navigation(scene, "声音")
		check(scroll.has_focus(), "native Home retains the selected category and keyboard focus")
	await activate_button(scene.find_child("SettingsSectionNavButton_体验", true, false) as Button, "mouse")
	check_settings_navigation(scene, "体验")
	await activate_button(scene.find_child("SettingsSectionNavButton_系统", true, false) as Button, "touch")
	await settle()
	check_settings_navigation(scene, "系统")
	var reset := scene.find_child("SettingRowButton_本地进度", true, false) as Button
	if scroll != null:
		scroll.grab_focus()
		await send_key(KEY_END, 0)
		await settle()
		check_settings_navigation(scene, "系统")
		check(reset != null and scroll.get_global_rect().encloses(reset.get_global_rect()), "the system category exposes its complete reset action")
		await save_reading_capture(scene, output_dir, "settings_end", {"scroll_value": scroll.scroll_vertical, "active_section": "系统", "native_input": "End"})
	await activate_button(scene.find_child("SettingsSectionNavButton_声音", true, false) as Button, "key")
	check_settings_navigation(scene, "声音")
	var trial := scene.find_child("SettingRowButton_背景音乐", true, false) as Button
	var music_before_focus: bool = scene.music_enabled
	check(trial != null, "sound settings retain the real music switch")
	if trial != null:
		if not scene.music_enabled:
			await activate_button(trial, "key")
		trial.grab_focus()
		await settle(0.08)
		await save_reading_capture(scene, output_dir, "settings_row_focus", {"focused_control": str(trial.name), "native_focus": trial.has_focus()})
		await send_left_button(trial.get_global_rect().get_center(), true)
		await settle(0.08)
		check(trial.is_pressed() and trial.has_focus() and not scene.music_enabled, "the real music press switches to its sliced paper state while retaining native pressed focus")
		await save_reading_capture(scene, output_dir, "settings_row_pressed", {"pressed_control": str(trial.name), "native_pressed": trial.is_pressed(), "native_focus": trial.has_focus(), "face_key": trial.get_meta("guofeng_button_face_key", "")})
		await send_left_button(trial.get_global_rect().get_center(), false)
		await settle(0.04)
		if scene.music_enabled != music_before_focus:
			await activate_button(trial, "key")
	close.grab_focus()
	await settle(0.08)
	await save_reading_capture(scene, output_dir, "settings_close_focus", {"focused_control": str(close.name), "native_focus": close.has_focus()})
	var close_center := close.get_global_rect().get_center()
	await send_left_button(close_center, true)
	await settle(0.08)
	check(not scene.settings_panel_open, "the native close press immediately performs its production action")
	await save_reading_capture(scene, output_dir, "settings_close_press_result", {"native_input": "mouse_down_on_close", "settings_panel_open": scene.settings_panel_open})
	await send_left_button(close_center, false)
	await settle(0.08)
	var restored := scene.find_child("MenuSettingsButton", true, false) as Button
	check(not scene.settings_panel_open and restored != null and restored.has_focus(), "closing refined settings restores its real home action focus")
	scene.tutorial_step = scene.TUTORIAL_STEP_DISCARD
	scene.show_menu(true)
	await settle(0.08)
	check(scene.find_child("MenuTutorialEntryBanner", true, false) != null and scene.find_child("MenuTutorialContinueButton", true, false) != null and scene.find_child("MenuTutorialSkipButton", true, false) != null, "the restrained home keeps the resumable tutorial and skip actions")
	var banner := scene.find_child("MenuTutorialEntryBanner", true, false) as Control
	var header := scene.find_child("MenuTitleTextLayer", true, false) as Control
	var continue_button := scene.find_child("MenuTutorialContinueButton", true, false) as Button
	var skip := scene.find_child("MenuTutorialSkipButton", true, false) as Button
	var tutorial_title := scene.find_child("MenuTutorialEntryTitle", true, false) as Label
	var tutorial_status := scene.find_child("MenuTutorialEntryStatus", true, false) as Label
	var card := scene.find_child("MenuPrimaryOfflineCard", true, false) as Button
	check(banner != null and header != null and not banner.get_global_rect().intersects(header.get_global_rect()), "the tutorial banner clears the complete measured product header")
	check(continue_button != null and skip != null and not continue_button.get_global_rect().intersects(skip.get_global_rect()) and banner.get_global_rect().encloses(skip.get_global_rect()), "tutorial continue and skip keep separate complete native targets")
	check(tutorial_title != null and tutorial_status != null and tutorial_title.get_theme_color("font_color").get_luminance() <= 0.24 and tutorial_status.get_theme_color("font_color").get_luminance() <= 0.24, "tutorial copy keeps readable dark ink on paper in every accessibility profile")
	check(card != null and banner != null and banner.get_global_rect().end.y + 12.0 <= card.get_global_rect().position.y, "the tutorial banner clears the complete primary action by twelve pixels")
	await save_reading_capture(scene, output_dir, "home_tutorial", {"tutorial_step": scene.tutorial_step, "header_rect": str(header.get_global_rect()), "banner_rect": str(banner.get_global_rect()), "continue_rect": str(continue_button.get_global_rect()), "skip_rect": str(skip.get_global_rect()), "title_luminance": tutorial_title.get_theme_color("font_color").get_luminance(), "status_luminance": tutorial_status.get_theme_color("font_color").get_luminance(), "card_clearance": card.get_global_rect().position.y - banner.get_global_rect().end.y})
	await activate_button(scene.find_child("MenuSettingsButton", true, false) as Button, "mouse")
	var toggle := scene.find_child("SettingRowButton_背景音乐", true, false) as Button
	var music_before: bool = scene.music_enabled
	await activate_button(toggle, "mouse")
	check(scene.music_enabled != music_before and scene.find_child("SettingRowButton_背景音乐", true, false) == toggle and toggle.has_focus(), "the restyled switch updates its real setting in place without losing focus")
	check(toggle != null and toggle.text == ("已开" if scene.music_enabled else "已关") and str(toggle.get_meta("guofeng_button_face_key", "")) == ("menu_ink_primary" if scene.music_enabled else "button_face_jiangnan_gpt"), "switch state remains explicit in native text and the authored face")
	await activate_button(toggle, "key")
	check(scene.music_enabled == music_before and toggle.find_child("SettingSwitchArt", true, false) == null, "keyboard activation restores the setting without rebuilding obsolete switch art")
	await activate_button(scene.find_child("SettingsSectionNavButton_系统", true, false) as Button, "key")
	var reset_action := scene.find_child("SettingRowButton_本地进度", true, false) as Button
	var reset_scroll := scene.find_child("SettingsLargeTextScroll", true, false) as ScrollContainer
	if reset_scroll != null and reset_action != null:
		reset_scroll.ensure_control_visible(reset_action)
		await settle()
	await activate_button(reset_action, "key")
	check(scene.reset_progress_confirming and reset_action != null and reset_action.text == "确认清空" and str(reset_action.get_meta("confirmation_state", "")) == "armed", "the real reset action only arms an explicit second-click confirmation")
	var reset_status := scene.find_child("SettingRowStatus_本地进度", true, false) as Label
	if not scene.large_text_enabled and (root.size.x <= 960 or root.size.y <= 560):
		check(reset_status != null and reset_status.text == "清空续局·保留战绩" and label_text_width(reset_status, reset_status.text) <= reset_status.size.x, "arming compact reset keeps the complete visible save-only consequence")
	await activate_button(scene.find_child("SettingsCloseButton", true, false) as Button, "mouse")
	check(not scene.reset_progress_confirming, "closing settings cancels the armed reset without clearing any save")


func run() -> void:
	print("=== guofeng home UI smoke START ===")
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
	var capture_root := OS.get_environment("YUNZHUO_GUOFENG_CAPTURE_DIR")
	if capture_root.is_empty():
		capture_root = "res://build/qa/guofeng_home"
	var output_dir := ProjectSettings.globalize_path("%s/%dx%d%s" % [capture_root, viewport_size.x, viewport_size.y, suffix])
	check(DirAccess.make_dir_recursive_absolute(output_dir) == OK, "the guofeng home evidence directory is writable")
	var scene = load("res://Main.tscn").instantiate()
	if scene.get_script() == null:
		check(false, "the runtime scene script loads before graphical evidence is captured")
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
	await check_guofeng_home(scene, output_dir)
	scene.shutdown_runtime()
	restore_smoke_state(scene, user_state)
	scene.queue_free()
	await process_frame
	print("=== RESULT: %s ===" % ("FAIL" if failed else "OK"))
	quit(1 if failed else 0)
