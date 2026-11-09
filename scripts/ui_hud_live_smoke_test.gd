extends "res://scripts/ui_input_safety_smoke_test.gd"


func check_wall(scene: Node, expected_count: int, label: String) -> void:
	var wall_text := scene.find_child("TopHudWallText", true, false) as Label
	var wall_state := scene.find_child("TopHudWallState", true, false) as Label
	var center_count := scene.find_child("CenterWallCount", true, false) as Label
	var center_status := scene.find_child("CenterWallStatusLabel", true, false) as Label
	var expected_state: String = scene.wall_state_text(expected_count)
	check(wall_text != null and wall_text.text == "余牌 %d/%d" % [expected_count, scene.display_wall_total()], "%s wall count follows the current state" % label)
	check(wall_state != null and wall_state.text.contains(expected_state.replace("牌墙", "")), "%s retains the textual wall warning" % label)
	check(wall_text != null and str(wall_text.get_meta("wall_state", "")) == expected_state, "%s accessibility wall-state metadata follows the live label" % label)
	check(center_count != null and center_count.text == str(expected_count), "%s center count follows the same wall snapshot" % label)
	var viewport_size: Vector2 = scene.effective_viewport_size()
	var center_model: Dictionary = scene.center_wall_view_model(expected_count, scene.display_wall_total(), viewport_size.x <= 960.0 or viewport_size.y < 720.0)
	check(center_status != null and center_status.text == center_model["label_text"] and center_status.tooltip_text == center_model["tooltip"], "%s center caption and tooltip follow the same live wall threshold" % label)
	check(wall_state != null and ((wall_state.get_theme_color("font_color").r > wall_state.get_theme_color("font_color").g) == scene.wall_is_low(expected_count)), "%s native low-wall warning ink switches with the live threshold" % label)
	for duplicate_name in ["TopHudWallCount", "TopHudWallLastSeal", "TopHudWallInkBar", "TopHudWallLowWarningText"]:
		var duplicate := scene.find_child(duplicate_name, true, false) as Control
		check(duplicate == null or not duplicate.is_visible_in_tree(), "%s never revives duplicate %s" % [label, duplicate_name])


func check_live_hud(scene: Node, viewport_size: Vector2i) -> void:
	print("--- live HUD %dx%d ---" % [viewport_size.x, viewport_size.y])
	reset_table_fixture(scene)
	scene.offline_ai_active = false
	scene.offline_active_rule_variant = scene.RULE_VARIANT_YANGZHOU
	scene.wall.resize(64)
	scene.last_discard = "3W"
	scene.last_discard_seat = 3
	scene.render_game()
	await settle(0.10)
	scene.refresh_battle_hud_lane()
	var hud := scene.find_child("TopHud3DShell", true, false) as Control
	var hud_id := hud.get_instance_id() if hud != null else 0
	var status := scene.find_child("TopHudStatus", true, false) as Label
	check_wall(scene, 64, "healthy offline")
	scene.current_seat = 1
	scene.refresh_battle_hud_lane()
	check(status != null and status.text == scene.top_hud_short_status_text(), "turn-only changes refresh the main status without changing the wall")
	scene.current_seat = 2
	scene.refresh_battle_hud_lane()
	check(status != null and status.tooltip_text == scene.top_hud_status_tooltip_text(), "tooltip-only changes refresh even when the short status stays the same")
	scene.current_seat = 0
	scene.offline_phase = "pending_claim"
	scene.offline_pending_claim = {"tile": "3W", "from_seat": 3, "options": ["peng", "pass"], "deadline_msec": Time.get_ticks_msec() + 60000}
	scene.refresh_battle_hud_lane()
	check(status != null and status.text == scene.top_hud_short_status_text(), "response-only changes cannot leave the previous turn status behind")
	scene.offline_pending_claim.clear()
	scene.offline_phase = "await_discard"
	for wall_size in [24, 18, 0, 64]:
		scene.wall = scene.make_wall()
		scene.wall.resize(wall_size)
		scene.refresh_battle_hud_lane()
		check_wall(scene, wall_size, "offline %d" % wall_size)
	scene.last_discard = "9T"
	scene.refresh_battle_hud_lane()
	var wall_state := scene.find_child("TopHudWallState", true, false) as Label
	check(wall_state != null and wall_state.text.contains(scene.tile_label("9T")), "last-discard-only changes update the secondary lane")
	var current_hud := scene.find_child("TopHud3DShell", true, false) as Control
	check(current_hud != null and current_hud.get_instance_id() == hud_id, "all live HUD changes retain the original surface instead of rebuilding the page")
	var refresh_count: int = scene.hud_lane_refresh_count
	scene.refresh_battle_hud_lane()
	check(scene.hud_lane_refresh_count == refresh_count, "identical visible and accessible snapshots still skip redundant writes")

	var transport := ConnectedLobbyTransport.new()
	scene.tcp = transport
	scene.mode = "online_game"
	scene.online_room = connected_room_fixture()
	scene.online_game = online_pending_game_fixture()
	scene.online_game_revision += 1
	scene.online_feedback = ""
	scene.online_waiting_for_server = false
	scene.online_retry_available = false
	scene.online_resume_pending = false
	scene.render_game()
	await settle(0.10)
	var online_hud := scene.find_child("TopHud3DShell", true, false) as Control
	var online_hud_id := online_hud.get_instance_id() if online_hud != null else 0
	status = scene.find_child("TopHudStatus", true, false) as Label
	check_wall(scene, 55, "healthy online Sichuan")
	scene.online_game["wallCount"] = 18
	scene.refresh_battle_hud_lane()
	check_wall(scene, 18, "low online Sichuan")
	scene.online_game["wallCount"] = 14
	scene.refresh_battle_hud_lane()
	check_wall(scene, 14, "critical online Sichuan")
	scene.online_waiting_for_server = true
	scene.refresh_battle_hud_lane()
	var expected_wait := "等待服务器" if viewport_size.x <= 960 or viewport_size.y <= 560 else "等待服务器确认"
	check(status != null and status.text == expected_wait, "online server-wait status replaces the stale pending state")
	scene.online_waiting_for_server = false
	scene.online_feedback = "服务器拒绝了这次操作"
	scene.refresh_battle_hud_lane()
	check(status != null and status.text == "连接失败 · 可重试", "online rejection feedback reaches the main HUD status")
	scene.online_feedback = ""
	scene.online_game["phase"] = "awaitDiscard"
	scene.online_game["pending"] = {}
	scene.online_game["currentSeat"] = 0
	scene.online_game["wallCount"] = 24
	scene.online_game["lastDiscard"] = "9T"
	scene.refresh_battle_hud_lane()
	check(status != null and status.text == "轮到你出牌", "online turn transition refreshes the main HUD")
	var online_wall_state := scene.find_child("TopHudWallState", true, false) as Label
	check(online_wall_state != null and online_wall_state.text.contains(scene.tile_label("9T")), "online last-discard transition updates the secondary HUD lane")
	check_wall(scene, 24, "online turn transition")
	var current_online_hud := scene.find_child("TopHud3DShell", true, false) as Control
	check(current_online_hud != null and current_online_hud.get_instance_id() == online_hud_id, "online HUD-only changes retain the original surface")

	scene.online_game["wallCount"] = 18
	scene.request_game_render(0, scene.GAME_RENDER_DIRTY_HUD)
	await settle(0.20)
	check_wall(scene, 18, "deferred HUD-only flush")
	check(scene.root_layer != null and scene.root_layer.get_meta("last_render_lane", "") == "hud_only", "HUD-only flush records the live lane instead of rebuilding the page")
	current_online_hud = scene.find_child("TopHud3DShell", true, false) as Control
	check(current_online_hud != null and current_online_hud.get_instance_id() == online_hud_id, "deferred HUD-only flush keeps the same HUD instance")
	var flush_refresh_count: int = scene.hud_lane_refresh_count
	scene.request_game_render(0, scene.GAME_RENDER_DIRTY_HUD)
	await settle(0.20)
	check(scene.hud_lane_refresh_count == flush_refresh_count, "identical deferred HUD snapshots remain deduplicated")


func run() -> void:
	print("=== ui HUD live smoke START ===")
	OS.set_environment("YUNZHUO_UI_CAPTURE", "1")
	var scene = load("res://Main.tscn").instantiate()
	scene.music_enabled = false
	scene.sfx_enabled = false
	scene.tts_enabled = false
	scene.voice_enabled = false
	scene.fx_enabled = false
	root.add_child(scene)
	await settle(0.10)
	var snapshot := capture_smoke_state(scene)
	scene.large_text_enabled = false
	scene.high_contrast_enabled = false
	for viewport_size in [Vector2i(960, 540), Vector2i(1280, 720), Vector2i(1920, 1080)]:
		root.size = viewport_size
		root.content_scale_size = viewport_size
		await settle()
		await check_live_hud(scene, viewport_size)
	if scene.has_method("shutdown_runtime"):
		scene.shutdown_runtime()
	restore_smoke_state(scene, snapshot)
	scene.queue_free()
	await process_frame
	print("=== RESULT: %s ===" % ("FAIL" if failed else "OK"))
	quit(1 if failed else 0)
