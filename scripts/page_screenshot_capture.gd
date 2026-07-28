extends SceneTree

const DEFAULT_OUTPUT_DIR := "res://build/qa/pages"
const DEFAULT_VIEWPORT_SIZE := Vector2i(1280, 720)
const SCREEN_NAMES := [
	"01_menu",
	"02_menu_settings",
	"03_offline_battle",
	"04_rules",
	"05_stats",
	"06_achievements",
	"07_shop",
	"08_online_lobby",
	"09_daily_login",
	"10_loading",
]

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	OS.set_environment("YUNZHUO_UI_CAPTURE", "1")
	if DisplayServer.get_name().to_lower() == "headless":
		print("skipped page capture: screenshots require a non-headless display driver")
		quit(0)
		return

	var viewport_size = requested_viewport_size()
	DisplayServer.window_set_size(viewport_size)
	root.size = viewport_size
	root.content_scale_size = viewport_size
	await process_frame
	await process_frame

	var output_dir_res = requested_output_dir(viewport_size)
	var output_dir = ProjectSettings.globalize_path(output_dir_res)
	DirAccess.make_dir_recursive_absolute(output_dir)

	var selected_screens := selected_screen_names()
	var scene = load("res://Main.tscn").instantiate()
	apply_static_capture_mode(scene)
	root.add_child(scene)
	apply_static_capture_mode(scene)
	await settle()
	for screen_name in selected_screens:
		await capture_screen(scene, screen_name, output_dir_res)
	if scene.has_method("clear_fx_overlays"):
		scene.clear_fx_overlays()
	if scene.has_method("shutdown_runtime"):
		scene.shutdown_runtime()
	scene.queue_free()
	await process_frame
	await process_frame
	await create_timer(0.06).timeout
	await process_frame

	if selected_screens.size() == 1 and selected_screens[0] == "03_offline_battle":
		print("saved offline battle screenshot %dx%d: %s" % [viewport_size.x, viewport_size.y, output_dir])
	elif selected_screens.size() == 1 and selected_screens[0] == "08_online_lobby":
		print("saved online lobby screenshot %dx%d: %s" % [viewport_size.x, viewport_size.y, output_dir])
	else:
		print("saved page screenshots %dx%d: %s" % [viewport_size.x, viewport_size.y, output_dir])
	call_deferred("finish_capture", 0)

func finish_capture(exit_code: int) -> void:
	quit(exit_code)

func requested_viewport_size() -> Vector2i:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--size="):
			var raw_size = arg.substr("--size=".length())
			var parts = raw_size.split("x")
			if parts.size() == 2:
				var width = max(320, int(parts[0]))
				var height = max(240, int(parts[1]))
				return Vector2i(width, height)
			printerr("invalid screenshot size: %s" % raw_size)
			quit(1)
			return DEFAULT_VIEWPORT_SIZE
	return DEFAULT_VIEWPORT_SIZE

func requested_output_dir(viewport_size: Vector2i) -> String:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--output-dir="):
			return arg.substr("--output-dir=".length())
	if viewport_size == DEFAULT_VIEWPORT_SIZE:
		return DEFAULT_OUTPUT_DIR
	return "res://build/qa/pages_%dx%d" % [viewport_size.x, viewport_size.y]

func selected_screen_names() -> Array:
	var args := OS.get_cmdline_user_args()
	for arg in args:
		if arg.begins_with("--screen="):
			return [arg.substr("--screen=".length())]
	if args.has("--offline-battle-only"):
		return ["03_offline_battle"]
	if args.has("--online-lobby-only"):
		return ["08_online_lobby"]
	return SCREEN_NAMES.duplicate()

func capture_screen(scene: Node, screen_name: String, output_dir_res: String) -> void:
	apply_static_capture_mode(scene)
	build_screen(scene, screen_name)
	apply_static_capture_mode(scene)
	if scene.has_method("clear_fx_overlays"):
		scene.clear_fx_overlays()
	await settle()
	_force_capture_visible_screens(scene)

	var viewport_texture = root.get_texture()
	if viewport_texture == null:
		printerr("failed to save %s: viewport texture is unavailable" % screen_name)
		quit(1)
		return

	var image = viewport_texture.get_image()
	if image == null:
		printerr("failed to save %s: viewport image is unavailable" % screen_name)
		quit(1)
		return

	var output_path = ProjectSettings.globalize_path("%s/%s.png" % [output_dir_res, screen_name])
	var err = image.save_png(output_path)
	if err != OK:
		printerr("failed to save %s: %s" % [screen_name, error_string(err)])
		quit(1)
		return
	print("saved %s: %s" % [screen_name, output_path])
	if scene.has_method("clear_fx_overlays"):
		scene.clear_fx_overlays()
	if scene.has_method("shutdown_runtime_tweens"):
		scene.shutdown_runtime_tweens()
	await process_frame
	await process_frame

func apply_static_capture_mode(scene: Node) -> void:
	scene.set("fx_enabled", false)
	scene.set("music_enabled", false)
	scene.set("sfx_enabled", false)
	scene.set("tts_enabled", false)
	scene.set("voice_enabled", false)

func build_screen(scene: Node, screen_name: String) -> void:
	match screen_name:
		"01_menu":
			scene.show_menu(true)
		"02_menu_settings":
			scene.show_menu(true)
			scene.settings_panel_open = true
			scene.refresh_current_screen()
		"03_offline_battle":
			scene.settings_panel_open = false
			scene.start_offline(true)
			seed_preview_discards(scene)
			seed_preview_pending_claim(scene)
			scene.render_game()
			scene.clear_fx_overlays()
		"04_rules":
			scene._show_rules_screen_impl()
		"05_stats":
			scene._show_stats_screen_impl()
		"06_achievements":
			scene._show_achievements_screen_impl()
		"07_shop":
			scene._show_shop_screen_impl()
		"08_online_lobby":
			seed_preview_online_lobby(scene)
			scene._show_online_lobby_impl()
		"09_daily_login":
			scene.show_menu(true)
			scene.clear_fx_overlays()
			scene.show_daily_login_panel({
				"show_reward": true,
				"consecutive_days": 5,
			})
		"10_loading":
			scene.show_loading_screen()
		"11_exit_confirm":
			scene.settings_panel_open = false
			scene.start_offline(true)
			seed_preview_discards(scene)
			scene.render_game()
			scene.clear_fx_overlays()
			scene.show_exit_confirm()
			# Capture mode: force fully-visible static dialog (skip entrance fade).
			if scene.exit_confirm_panel != null and is_instance_valid(scene.exit_confirm_panel):
				scene.exit_confirm_panel.modulate = Color(1, 1, 1, 1)
				var dialog = scene.exit_confirm_panel.find_child("ExitConfirmDialog", true, false)
				if dialog != null:
					dialog.scale = Vector2(1, 1)
					if dialog is Control:
						dialog.modulate = Color(1, 1, 1, 1)
		"12_toast":
			scene.show_menu(true)
			scene.clear_fx_overlays()
			# Long duration so capture settle still sees full opacity toast.
			scene.show_toast("成就解锁：初入牌桌", 8000)
			# Freeze toast static for screenshot (kill entrance/exit tweens).
			if scene.toast_tween != null and is_instance_valid(scene.toast_tween):
				scene.toast_tween.kill()
				scene.toast_tween = null
			if scene.toast_current != null and is_instance_valid(scene.toast_current):
				scene.toast_current.modulate = Color(1, 1, 1, 1)
				scene.toast_current.offset_top = 0.0
				scene.toast_current.scale = Vector2(1, 1)
			if scene.toast_container != null and is_instance_valid(scene.toast_container):
				scene.toast_container.visible = true
		"13_round_summary":
			scene.settings_panel_open = false
			scene.start_offline(true)
			seed_preview_discards(scene)
			seed_preview_round_summary(scene)
			scene.render_game()
			scene.clear_fx_overlays()
		"14_danger_discard":
			scene.settings_panel_open = false
			scene.start_offline(true)
			seed_preview_discards(scene)
			seed_preview_danger_discard(scene)
			scene.render_game()
			scene.clear_fx_overlays()
		"15_pending_claim_full":
			scene.settings_panel_open = false
			scene.start_offline(true)
			seed_preview_discards(scene)
			seed_preview_pending_claim_full(scene)
			scene.render_game()
			scene.clear_fx_overlays()
		"16_win_detail":
			scene.settings_panel_open = false
			scene.start_offline(true)
			seed_preview_discards(scene)
			seed_preview_win_detail(scene)
			scene.render_game()
			scene.clear_fx_overlays()
		"17_hand_tutorial":
			scene.settings_panel_open = false
			scene.start_offline(true)
			seed_preview_discards(scene)
			seed_preview_hand_tutorial(scene)
			scene.render_game()
			scene.clear_fx_overlays()
		"18_update_dialog":
			scene.show_menu(true)
			scene.clear_fx_overlays()
			seed_preview_update_dialog(scene)
		"19_reset_progress":
			scene.show_menu(true)
			scene.settings_panel_open = true
			scene.reset_progress_confirming = true
			scene.refresh_current_screen()
			# Force fully-visible static settings overlay under capture.
			var settings_panel = scene.find_child("SettingsPanel", true, false)
			if settings_panel is Control:
				(settings_panel as Control).modulate = Color(1, 1, 1, 1)
		"20_chat_panel":
			scene.settings_panel_open = false
			scene.start_offline(true)
			seed_preview_discards(scene)
			scene.render_game()
			scene.clear_fx_overlays()
			seed_preview_chat_panel(scene)
		"21_diagnostic":
			scene.show_menu(true)
			scene.clear_fx_overlays()
			scene.show_diagnostic_dialog([
				"【系统诊断】",
				"✓ 音频资源完整",
				"✓ 牌面纹理就绪",
				"• 网络：离线预览",
				"✗ 可选：云存档未连接",
			])
			# Capture mode: force fully-visible static dialog (skip entrance fade).
			var diag_panel = scene.find_child("DiagnosticDialogPanel", true, false)
			if diag_panel is Control:
				(diag_panel as Control).modulate = Color(1, 1, 1, 1)
			var diag_bg = scene.find_child("DiagnosticDismissOverlay", true, false)
			if diag_bg is Control:
				(diag_bg as Control).modulate = Color(1, 1, 1, 1)
		"22_advisor":
			scene.settings_panel_open = false
			scene.ai_assist_enabled = true
			scene.start_offline(true)
			seed_preview_discards(scene)
			scene.render_game()
			scene.clear_fx_overlays()
			# Force advisor panel for pure densify capture (even if phase not discard).
			if scene.has_method("draw_advisor_panel"):
				scene.draw_advisor_panel(scene.root_layer, true)
		"23_score_strip":
			# Online HUD shows ScoreStrip; offline intentionally omits it.
			scene.settings_panel_open = false
			scene.start_offline(true)
			seed_preview_discards(scene)
			scene.mode = "online"
			for seat in range(4):
				scene.players[seat]["score"] = 22000 + seat * 1100
			scene.players[0]["score"] = 28500
			scene.players[0]["name"] = "你"
			scene.render_game()
			scene.clear_fx_overlays()
		_:
			push_error("unknown screenshot screen: %s" % screen_name)


func _force_capture_visible_screens(target: Node) -> void:
	if target == null:
		return
	for node_name in [
		"ShopCabinetFrontPanel",
		"OnlineLobbyFormPanel",
		"OnlineLobbyLogPanel",
	]:
		var node = target.find_child(node_name, true, false)
		if node is CanvasItem:
			(node as CanvasItem).modulate = Color(1, 1, 1, 1)


func settle() -> void:
	await process_frame
	await process_frame
	# Entrance staggers (shop/rules/stats/online) can last ~0.4-0.5s under xvfb (DisplayServer=x11).
	await create_timer(0.75).timeout
	await process_frame
	await process_frame

func seed_preview_discards(scene: Node) -> void:
	var preview_discards := [
		["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "E", "S", "N", "1T", "2T", "3T", "4T"],
		["1T", "2T", "3T", "4T", "5T", "6T", "7T", "8T", "9T", "E", "S", "W", "1B", "2B", "3B", "4B"],
		["1B", "2B", "3B", "4B", "5B", "6B", "7B", "8B", "9B", "E", "S", "N", "1W", "2W", "3W", "4W"],
		["Z", "F", "P", "R", "N", "E", "S", "W", "1T", "2T", "3T", "4T", "5T", "6T", "7T", "8T"],
	]
	# r411: denser multi-meld fixture to prove adaptive lane packing (2–4 groups).
	var preview_melds := [
		[["5T", "5T", "5T"], ["2W", "3W", "4W"], ["7B", "7B", "7B"], ["E", "E", "E", "E"]],
		[["2W", "2W", "2W"], ["3T", "4T", "5T"], ["9B", "9B", "9B"]],
		[["1B", "1B", "1B", "1B"], ["4W", "5W", "6W"], ["S", "S", "S"]],
		[["E", "E", "E"], ["1T", "2T", "3T"], ["P", "P", "P"], ["6B", "7B", "8B"]],
	]
	for seat in range(preview_discards.size()):
		scene.players[seat]["discards"] = preview_discards[seat].duplicate()
		scene.players[seat]["melds"] = preview_melds[seat].duplicate(true)
		scene.players[seat]["flowers"] = 2 if seat % 2 == 0 else 1
		scene.players[seat]["score"] = 24000 + seat * 800
		if seat != 0:
			# 13 - 3*open_sets (+1 if gang replaced) approx for visual consistency.
			var open_sets: int = scene.players[seat]["melds"].size()
			scene.players[seat]["hand_count"] = maxi(1, 13 - open_sets * 3)
	scene.last_discard = "S"
	scene.last_discard_seat = 3
	scene.current_seat = 0
	scene.offline_phase = "await_discard"
	scene.table_logs.clear()
	scene.add_log("预览：弃牌区与副露使用真实牌面贴图。")

func seed_preview_pending_claim(scene: Node) -> void:
	scene.offline_phase = "pending_claim"
	scene.players[0]["hand"] = ["1W", "2W", "3W", "3W", "4W", "5W", "5T", "6T", "7T", "E", "E", "P", "P"]
	scene.offline_pending_claim = {
		"from_seat": 3,
		"tile": "3W",
		"options": ["chi", "peng"],
		"chi_choices": scene.get_chi_choices(scene.players[0]["hand"], "3W"),
	}
	scene.offline_last_draw = {
		"seat": 3,
		"tile": "S",
		"source": "normal",
		"wall_empty": false,
		"announce": true,
		"serial": 777,
	}
	scene.add_log("预览：响应插画展示吃碰选择。")

func seed_preview_online_lobby(scene: Node) -> void:
	scene.selected_room = "ROOM7"
	scene.online_room = {
		"code": "ROOM7",
		"players": [
			{"name": "甲"},
			{"name": "乙"},
		],
		"logs": [
			"甲加入房间",
			"乙准备就绪",
			"房间已满，等待开局",
			"系统：对局将按国标麻将规则结算",
		],
	}
	scene.online_feedback = "已发送加入房间，等待服务器确认。"
	scene.online_waiting_for_server = true

func seed_preview_round_summary(scene: Node) -> void:
	scene.offline_phase = "ended"
	scene.offline_last_winner = 0
	scene.offline_dealer_repeat = false
	scene.dealer_seat = 0
	scene.round_summary = "东家自摸平胡，1番 2分。平胡。庄家下庄。"
	scene.last_win_score = {
		"winner": 0,
		"fan": 1,
		"points": 2,
		"reasons": ["平胡"],
		"win_tile": "5W",
		"self_draw": true,
		"limit_name": "",
	}
	for seat in range(4):
		scene.players[seat]["score"] = 24000 + (3 - seat) * 1200
		scene.players[seat]["flowers"] = 2 if seat % 2 == 0 else 1
	scene.players[0]["score"] = 27600
	scene.add_log("预览：本局结算面板。")

func seed_preview_danger_discard(scene: Node) -> void:
	scene.ai_assist_enabled = true
	scene.offline_phase = "await_discard"
	scene.current_seat = 0
	scene.players[0]["hand"] = ["1W", "2W", "3W", "4W", "5W", "5T", "6T", "7T", "E", "E", "P", "P", "S"]
	scene.pending_danger_discard_index = 12
	scene.pending_danger_discard_tile = "S"
	scene.pending_danger_discard_report = {
		"tile": "S",
		"risk": 52.0,
		"feed_risk": 48.0,
		"risk_label": "高",
		"safety_label": "",
		"feed_text": "对家听口偏高",
		"danger_source": {"reason": "牌路危险", "seat": 2},
	}
	scene.add_log("预览：高危弃牌二次确认。")

func seed_preview_pending_claim_full(scene: Node) -> void:
	scene.offline_phase = "pending_claim"
	scene.players[0]["hand"] = ["1W", "2W", "3W", "3W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "E", "E"]
	scene.offline_pending_claim = {
		"from_seat": 3,
		"tile": "3W",
		"options": ["hu", "gang", "peng", "chi"],
		"chi_choices": [
			{"meld": ["1W", "2W", "3W"]},
			{"meld": ["2W", "3W", "4W"]},
			{"meld": ["3W", "4W", "5W"]},
		],
	}
	scene.offline_last_draw = {
		"seat": 3,
		"tile": "S",
		"source": "normal",
		"wall_empty": false,
		"announce": true,
		"serial": 778,
	}
	scene.add_log("预览：完整吃碰杠胡响应条。")

func seed_preview_win_detail(scene: Node) -> void:
	scene.offline_phase = "ended"
	scene.offline_last_winner = 0
	scene.offline_dealer_repeat = false
	scene.dealer_seat = 1
	scene.round_summary = "你自摸清一色碰碰胡，8番 16分。清一色、碰碰胡、自摸。庄家下庄。"
	scene.last_win_score = {
		"winner": 0,
		"fan": 8,
		"points": 16,
		"reasons": ["清一色", "碰碰胡", "自摸"],
		"win_tile": "9W",
		"self_draw": true,
		"limit_name": "高番",
	}
	for seat in range(4):
		scene.players[seat]["score"] = 22000 + seat * 900
		scene.players[seat]["flowers"] = 1 + (seat % 2)
	scene.players[0]["score"] = 31200
	scene.players[0]["name"] = "你"
	scene.add_log("预览：胡牌详情结算。")

func seed_preview_hand_tutorial(scene: Node) -> void:
	scene.ai_assist_enabled = false
	scene.offline_phase = "await_discard"
	scene.current_seat = 0
	scene.tutorial_step = 0
	scene.show_hand_hint = true
	scene.players[0]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "E", "E", "S", "S"]
	scene.offline_pending_claim.clear()
	scene.clear_pending_danger_discard()
	scene.add_log("预览：新手出牌提示。")

func seed_preview_update_dialog(scene: Node) -> void:
	scene.update_state = "ready"
	scene.update_remote_version = "1.0.181"
	scene.update_message = "发现新版本 v1.0.181，校验通过，可安装。"
	scene.update_downloaded_bytes = 10485760
	scene.update_total_bytes = 10485760
	scene.update_release_notes = "修复对局可读性；优化设置与更新弹窗奶油字色。"
	if scene.has_method("ensure_update_dialog"):
		scene.ensure_update_dialog()
	if scene.has_method("refresh_update_dialog"):
		scene.refresh_update_dialog()
	if scene.update_dialog != null and is_instance_valid(scene.update_dialog):
		scene.update_dialog.modulate = Color(1, 1, 1, 1)
		var panel = scene.update_dialog.get_child(1) if scene.update_dialog.get_child_count() > 1 else null
		if panel is Control:
			(panel as Control).scale = Vector2(1, 1)
			(panel as Control).modulate = Color(1, 1, 1, 1)

func seed_preview_chat_panel(scene: Node) -> void:
	scene.chat_messages = [
		"甲: 这局稳了",
		"乙: 小心三筒",
		"你: 收到，注意防守",
		"丙: 准备杠上开花",
	]
	if scene.has_method("show_chat_panel"):
		scene.show_chat_panel()
