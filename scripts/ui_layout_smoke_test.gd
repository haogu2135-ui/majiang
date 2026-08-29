extends SceneTree

const VIEWPORTS := [
	Vector2(1280, 720),
	Vector2(1920, 1080),
	Vector2(960, 540),
]
const SAFE_AREA_PROBE_VIEWPORT := Vector2(960, 540)
const SAFE_AREA_PROBE_MARGINS := Vector4(42.0, 26.0, 34.0, 46.0)
const CONTINUOUS_RESIZE_VIEWPORTS := [
	Vector2(1920, 1080),
	Vector2(1280, 720),
	Vector2(960, 540),
]

var failed := false

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	for viewport_size in VIEWPORTS:
		await run_layout_checks_for_viewport(viewport_size)
	await run_safe_area_layout_probe(SAFE_AREA_PROBE_VIEWPORT, SAFE_AREA_PROBE_MARGINS)
	await run_continuous_resize_capacity_probe()
	if failed:
		quit(1)
	else:
		print("ui layout smoke test passed")
		quit(0)

func seed_offline_battle_layout_state(scene) -> void:
	scene.mode = "offline"
	scene.players = [
		{"name": "你", "hand": ["1W", "2W", "3W", "3W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "E", "E"], "discards": ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "E", "S"], "melds": [["1W", "1W", "1W"], ["2W", "3W", "4W"], ["5W", "5W", "5W"], ["6W", "6W", "6W", "6W"]], "flowers": 0, "score": 7400},
		{"name": "青竹道人", "hand_count": 13, "discards": ["1T", "2T", "3T", "4T", "5T", "6T", "7T", "8T"], "melds": [["1T", "1T", "1T"], ["2T", "3T", "4T"], ["5T", "5T", "5T"], ["6T", "6T", "6T", "6T"]], "flowers": 1, "score": 53000},
		{"name": "南山客", "hand_count": 13, "discards": ["1B", "2B", "3B", "4B", "5B", "6B", "7B", "8B", "9B"], "melds": [["1B", "1B", "1B"], ["2B", "3B", "4B"], ["5B", "5B", "5B"], ["6B", "6B", "6B", "6B"]], "flowers": 1, "score": 21000},
		{"name": "扶摇散人", "hand_count": 13, "discards": ["Z", "F", "P", "R", "N", "E", "S"], "melds": [["E", "E", "E"], ["S", "S", "S"], ["N", "N", "N"], ["R", "R", "R", "R"]], "flowers": 0, "score": 19700},
	]
	scene.table_logs.clear()
	scene.table_logs.append("北家碰东风")
	scene.table_logs.append("你摸入五条")
	scene.wall.clear()
	scene.wall.append("5T")
	scene.wall.append("6T")
	scene.wall.append("7T")
	scene.last_discard = "S"
	scene.last_discard_seat = 3
	scene.current_seat = 0
	scene.offline_phase = "pending_claim"
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
	scene.ai_assist_enabled = false

func seed_online_pending_claim_layout_state(scene) -> void:
	scene.mode = "online_game"
	scene.offline_phase = "await_discard"
	scene.online_feedback = ""
	scene.online_waiting_for_server = false
	scene.current_seat = 0
	scene.online_game = {
		"roomCode": "QA7",
		"phase": "pendingClaim",
		"youSeat": 0,
		"currentSeat": 0,
		"wallCount": 55,
		"wallTotal": 108,
		"ruleVariant": "sichuan",
		"hand": ["1W", "2W", "3W", "3W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "E", "E", "R"],
		"lastDiscard": "3W",
		"lastDiscardSeat": 3,
		"players": [
			{"seat": 0, "name": "你", "handCount": 14, "flowerCount": 0, "score": 26400, "discards": ["1W", "2W"], "melds": []},
			{"seat": 1, "name": "东风夜放", "handCount": 13, "flowerCount": 1, "score": 23800, "discards": ["1T", "2T"], "melds": []},
			{"seat": 2, "name": "南山客", "handCount": 13, "flowerCount": 0, "score": 27200, "discards": ["1B", "2B"], "melds": []},
			{"seat": 3, "name": "北海若", "handCount": 13, "flowerCount": 0, "score": 22600, "discards": ["Z", "F", "P"], "melds": []},
		],
		"pending": {
			"tile": "3W",
			"fromSeat": 3,
			"options": ["hu", "gang", "peng", "chi"],
			"chi_choices": [
				{"meld": ["1W", "2W", "3W"]},
				{"meld": ["2W", "3W", "4W"]},
				{"meld": ["3W", "4W", "5W"]},
			],
		},
	}
	scene.table_logs.clear()
	scene.table_logs.append("北海若打出三万，等待响应")
	scene.table_logs.append("在线房间 QA7 已同步")
	scene.ai_assist_enabled = false

func seed_danger_discard_layout_state(scene) -> void:
	seed_offline_battle_layout_state(scene)
	scene.offline_phase = "await_discard"
	scene.offline_pending_claim.clear()
	scene.current_seat = 0
	scene.offline_turn_needs_draw = false
	scene.ai_assist_enabled = true
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

func seed_win_detail_layout_state(scene) -> void:
	seed_offline_battle_layout_state(scene)
	scene.offline_phase = "ended"
	scene.offline_pending_claim.clear()
	scene.offline_last_winner = 0
	scene.offline_dealer_repeat = false
	scene.dealer_seat = 1
	scene.offline_hand_number = 1
	scene.round_summary = "你自摸九万，8番高番 16分。清一色、碰碰胡、门清、一条龙、杠上开花、海底捞月、自摸、花牌加番。庄家下庄。包三搭：青竹道人包赔你。全场结束。"
	scene.last_win_score = {
		"winner": 0,
		"fan": 8,
		"points": 16,
		"reasons": ["清一色", "碰碰胡", "门清", "一条龙", "杠上开花", "海底捞月", "自摸", "花牌加番"],
		"win_tile": "9W",
		"self_draw": true,
		"limit_name": "高番",
	}
	scene.last_score_deltas.clear()
	for delta in [3600, -1200, -1200, -1200]:
		scene.last_score_deltas.append(delta)
	for seat in range(4):
		scene.players[seat]["score"] = 22000 + seat * 900
	scene.players[0]["score"] = 31200
	scene.players[0]["name"] = "你"
	scene.offline_package_liability = {0: 1}


func seed_battle_capacity_layout_state(scene) -> void:
	# Deliberately stress independent visible zones at once; the fixture validates
	# layout capacity rather than a legal in-progress tile ledger.
	seed_offline_battle_layout_state(scene)
	scene.offline_phase = "await_discard"
	scene.offline_pending_claim.clear()
	scene.current_seat = 0
	scene.offline_turn_needs_draw = false
	scene.players[0]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "5T", "9T", "E", "R"]
	scene.offline_last_draw = {"seat": 0, "tile": "R", "source": "normal", "announce": false, "serial": 901}
	scene.offline_self_draw_ready = {"seat": 0, "tile": "R", "serial": 901}
	var river_codes := ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "2T", "3T", "4T", "5T", "6T", "7T", "8T", "9T", "1B", "2B", "3B", "4B", "5B", "6B", "7B", "8B", "9B", "E", "S", "W", "N", "Z", "F", "P", "R"]
	var meld_sets := [
		["1W", "1W", "1W"],
		["2T", "3T", "4T"],
		["5B", "5B", "5B"],
		["R", "R", "R", "R"],
	]
	var flower_tiles := ["H1", "H2", "H3", "H4", "H5", "H6", "H7", "H8"]
	for seat in range(4):
		scene.players[seat]["discards"] = river_codes.duplicate()
		scene.players[seat]["melds"] = meld_sets.duplicate(true)
		scene.players[seat]["flowers"] = flower_tiles.size()
		scene.players[seat]["flower_tiles"] = flower_tiles.duplicate()
	scene.last_discard = "R"
	scene.last_discard_seat = 3
	scene.table_logs.clear()
	for i in range(scene.ONLINE_LOG_HISTORY_LIMIT):
		scene.table_logs.append("第%02d巡：北家杠上补花后打出一张牌，四家牌河与副露状态已同步" % (i + 1))


func settle_layout(seconds: float = 0.0) -> void:
	await process_frame
	await process_frame
	if seconds > 0.0:
		await create_timer(seconds).timeout
		await process_frame


func apply_runtime_resize(scene, viewport_size: Vector2) -> void:
	var viewport_i := Vector2i(int(viewport_size.x), int(viewport_size.y))
	root.size = viewport_i
	root.content_scale_size = viewport_i
	DisplayServer.window_set_size(viewport_i)
	# Exercise the production deferred resize path even when the headless display
	# backend does not emit a native window notification.
	scene._notification(1008) # Node.NOTIFICATION_WM_SIZE_CHANGED
	await settle_layout(0.14)


func run_continuous_resize_capacity_probe() -> void:
	var initial_size: Vector2 = CONTINUOUS_RESIZE_VIEWPORTS[0]
	var initial_i := Vector2i(int(initial_size.x), int(initial_size.y))
	root.size = initial_i
	root.content_scale_size = initial_i
	DisplayServer.window_set_size(initial_i)
	await process_frame
	var scene = load("res://Main.tscn").instantiate()
	root.add_child(scene)
	await settle_layout()
	scene.fx_enabled = false
	seed_battle_capacity_layout_state(scene)
	scene.render_game()
	await settle_layout()
	for viewport_size in CONTINUOUS_RESIZE_VIEWPORTS:
		await apply_runtime_resize(scene, viewport_size)
		var actual_viewport: Vector2 = scene.effective_viewport_size()
		check(actual_viewport.distance_to(viewport_size) <= 1.0, "continuous resize reaches %s without recreating the scene (got %s)" % [viewport_size, actual_viewport])
		check_battle_capacity_layout(scene, actual_viewport)
	await check_discard_archive_access(scene, Vector2(960, 540), 1)

	# Pages that compute compact layout at build time must rebuild from their
	# persisted state on every notification, without recreating Main itself.
	var loading_fixture := {"status": "正在同步商用资源", "progress_ratio": 0.43, "tip": "提示：旋转屏幕不会丢失加载状态"}
	scene.show_loading_screen(loading_fixture)
	await settle_layout()
	for viewport_size in CONTINUOUS_RESIZE_VIEWPORTS:
		await apply_runtime_resize(scene, viewport_size)
		var loading_panel = scene.find_child("LoadingPanel", true, false) as Control
		var loading_status = scene.find_child("LoadingStatusLabel", true, false) as Label
		var loading_fill = scene.find_child("LoadingProgressFill", true, false) as Control
		check(loading_panel != null and loading_status != null and loading_status.text == str(loading_fixture["status"]), "loading screen and status survive live resize at %s" % viewport_size)
		check(loading_fill != null and absf(loading_fill.anchor_right - float(loading_fixture["progress_ratio"])) <= 0.001 and scene.loading_view_state == loading_fixture, "loading progress and view state survive live resize at %s" % viewport_size)

	scene._show_shop_screen_impl()
	await settle_layout()
	for viewport_size in CONTINUOUS_RESIZE_VIEWPORTS:
		await apply_runtime_resize(scene, viewport_size)
		check_shop_layout(scene, viewport_size)
		var shop_rows := controls_with_name_prefix(scene, "ShopItemRow_")
		check(shop_rows.size() == 4, "shop preserves all four product rows through live resize at %s" % viewport_size)
		if not shop_rows.is_empty():
			var expected_wide: bool = viewport_size.x >= 1600.0
			var expected_columns: int = 2 if expected_wide else 1
			var expected_rows: int = maxi(1, ceili(4.0 / float(expected_columns)))
			var expected_gap := 12.0 if expected_wide else 10.0
			var expected_row_cap := 320.0 if expected_wide else 120.0
			var expected_row_height := clampf(floorf((scene.safe_content_pixel_size().y * 0.96 * (0.750 - 0.12) - expected_gap * float(expected_rows - 1)) / float(expected_rows)), 68.0, expected_row_cap)
			check(absf((shop_rows[0] as Control).custom_minimum_size.y - expected_row_height) <= 1.0, "shop recomputes compact row height through live resize at %s" % viewport_size)
			if viewport_size.x >= 1600.0:
				check((shop_rows[0] as Control).custom_minimum_size.y > 120.0, "wide shop uses the full display height instead of leaving a shelf-sized blank lane at %s" % viewport_size)

	var daily_fixture := {"consecutive_days": 5, "claimed_today": true, "show_reward": true}
	scene.show_daily_login_panel(daily_fixture)
	await settle_layout()
	for viewport_size in CONTINUOUS_RESIZE_VIEWPORTS:
		await apply_runtime_resize(scene, viewport_size)
		check_daily_login_layout(scene, viewport_size)
		var claim_button = scene.find_child("DailyLoginClaimButton", true, false) as Button
		check(claim_button != null and claim_button.disabled and scene.daily_login_view_state == daily_fixture, "daily-login claimed state survives live resize at %s" % viewport_size)

	seed_battle_capacity_layout_state(scene)
	scene.offline_active_rule_variant = scene.RULE_VARIANT_YANGZHOU
	scene.rule_variant = scene.RULE_VARIANT_SICHUAN
	scene.settings_panel_open = true
	scene.render_game()
	await settle_layout()
	for viewport_size in CONTINUOUS_RESIZE_VIEWPORTS:
		await apply_runtime_resize(scene, viewport_size)
		check_settings_overlay(scene, viewport_size)
		var settings_close = scene.find_child("SettingsCloseButton", true, false) as Button
		check(settings_close != null and settings_close.has_focus(), "settings modal keeps its safe default focus through live resize at %s" % viewport_size)
	scene.close_settings_panel()
	await settle_layout()

	seed_battle_capacity_layout_state(scene)
	scene.render_game()
	await settle_layout()

	# Transient overlays must survive the same production resize notification.
	scene.show_exit_confirm()
	await settle_layout()
	await apply_runtime_resize(scene, Vector2(1280, 720))
	var exit_dialog = scene.find_child("ExitConfirmDialog", true, false) as Control
	check(exit_dialog != null and Rect2(Vector2.ZERO, Vector2(1280, 720)).grow(1.0).encloses(screen_rect(exit_dialog)), "exit confirmation remains mounted and bounded through a live resize")
	scene.hide_exit_confirm()
	await settle_layout(0.20)

	var diagnostic_lines := diagnostic_layout_lines()
	scene.show_diagnostic_dialog(diagnostic_lines)
	await settle_layout()
	var diagnostic_scroll = scene.find_child("DiagnosticContentScroll", true, false) as ScrollContainer
	if diagnostic_scroll != null:
		diagnostic_scroll.scroll_vertical = mini(180, int(diagnostic_scroll.get_v_scroll_bar().max_value))
		await settle_layout(0.05)
	var diagnostic_scroll_before: int = diagnostic_scroll.scroll_vertical if diagnostic_scroll != null else -1
	await apply_runtime_resize(scene, Vector2(960, 540))
	check(scene.find_child("DiagnosticDialogPanel", true, false) != null, "diagnostic modal remains open through a live resize")
	diagnostic_scroll = scene.find_child("DiagnosticContentScroll", true, false) as ScrollContainer
	check(diagnostic_scroll != null and diagnostic_scroll_before > 0 and abs(diagnostic_scroll.scroll_vertical - diagnostic_scroll_before) <= 1, "diagnostic modal preserves its non-zero scroll position through live resize")
	await check_diagnostic_layout(scene, Vector2(960, 540), diagnostic_lines.size())
	scene.dismiss_diagnostic_dialog()
	await settle_layout(0.08)

	scene.update_state = "error"
	scene.update_message = "更新服务器暂时不可用，请稍后重试。"
	scene.ensure_update_dialog()
	await settle_layout()
	await apply_runtime_resize(scene, Vector2(1280, 720))
	var update_overlay = scene.find_child("UpdateDialogOverlay", true, false) as Control
	var update_secondary = scene.find_child("UpdateSecondaryButton", true, false) as Button
	check(update_overlay != null and update_secondary != null and update_secondary.has_focus(), "update modal remains mounted with focus through a live resize")
	scene.update_state = "idle"
	scene.refresh_update_dialog()
	scene.queue_free()
	await settle_layout()


func check_battle_capacity_layout(scene, viewport_size: Vector2) -> void:
	check(scene.get_self_hand().size() == 14, "capacity fixture keeps all fourteen pending-discard hand tiles at %s" % viewport_size)
	var metrics: Dictionary = scene.hand_layout_metrics(scene.get_self_hand())
	check(scene.hand_layout_fits_content(scene.get_self_hand(), metrics), "fourteen-tile hand fits the authored tray at %s" % viewport_size)
	check(controls_with_name_prefix(scene, "HandTile_").size() == 14, "fourteen-tile hand renders every 2D face at %s" % viewport_size)
	for zone in scene.DISCARD_ZONES:
		var seat := int(zone[0])
		var grid = scene.find_child("DiscardGrid_%d" % seat, true, false) as GridContainer
		var visible_capacity := int(grid.get_meta("visible_capacity", 0)) if grid != null else 0
		var expected_visible := mini(scene.get_discards(seat).size(), visible_capacity)
		check(grid != null and grid.get_child_count() == expected_visible, "river %d exposes its full %d-tile visible window at %s" % [seat, expected_visible, viewport_size])
		var latest_start: int = int(scene.tail_window_start(scene.get_discards(seat).size(), visible_capacity))
		var archive_button = scene.find_child("DiscardRiverArchiveButton_%d" % seat, true, false) as Button
		check(archive_button != null and int(archive_button.get_meta("hidden_count", -1)) == latest_start and archive_button.text == scene.discard_archive_button_text(scene.get_discards(seat).size(), latest_start, visible_capacity), "river %d exposes an accurate authored archive entry for %d older tiles at %s" % [seat, latest_start, viewport_size])
		if archive_button != null:
			var archive_rect := screen_rect(archive_button)
			var archive_label = archive_button.find_child("DiscardRiverArchiveLabel_%d" % seat, true, false) as Label
			check(archive_rect.size.x >= 44.0 and archive_rect.size.y >= 44.0 and archive_button.get_combined_minimum_size().x <= archive_rect.size.x + 1.0, "river %d archive entry remains a readable 44px target at %s" % [seat, viewport_size])
			check(archive_label != null and str(archive_label.text).contains("历史") and str(archive_label.text).contains(archive_button.text) and relative_luma(archive_label.get_theme_color("font_color")) >= 0.88 and archive_rect.grow(1.0).encloses(screen_rect(archive_label)), "river %d archive entry exposes a labelled history action above the authored art at %s" % [seat, viewport_size])
		if seat == scene.get_last_discard_seat():
			var recent = scene.find_child("RecentDiscardTile_%d" % seat, true, false) as Control
			check(recent != null and int(recent.get_meta("discard_source_index", -1)) == scene.get_discards(seat).size() - 1 and str(recent.get_meta("discard_tile_code", "")) == str(scene.get_discards(seat)[-1]), "river %d retains one accurate latest-discard marker at capacity at %s" % [seat, viewport_size])
		var flower_meta = scene.find_child("SeatCompactMeta_%d" % seat, true, false) as Label
		check(flower_meta != null and flower_meta.text.contains("花8"), "seat %d preserves the full eight-flower count at %s" % [seat, viewport_size])
	check_battle_viewport_bounds(scene, viewport_size)
	check_hand_tray_layout(scene, viewport_size)
	var hand_tiles := controls_with_name_prefix(scene, "HandTile_")
	var regular_gaps: Array[float] = []
	var group_gaps: Array[float] = []
	var regular_button_y: Array[float] = []
	var drawn_button_y := INF
	var drawn_count := 0
	for i in range(hand_tiles.size()):
		var tile := hand_tiles[i]
		var tile_rect := screen_rect(tile)
		var face = tile.find_child("TileFaceTexture", true, false) as TextureRect
		var buttons := tile.find_children("*", "Button", true, false)
		var hit_button = buttons[0] as Button if not buttons.is_empty() else null
		var expected_code := str(scene.get_self_hand()[i])
		check(tile_rect.size.x >= scene.HAND_TILE_MIN_TOUCH_WIDTH and tile_rect.size.y >= 44.0, "fourteen-tile hand target %s remains at least 46x44px at %s" % [tile.name, viewport_size])
		check(str(tile.get_meta("hand_tile_code", "")) == expected_code and int(tile.get_meta("hand_source_index", -1)) == i, "hand tile %d preserves its source identity at %s" % [i, viewport_size])
		check(face != null and face.texture != null and face.texture != scene.tile_back and str(face.texture.resource_path).begins_with("res://assets/tiles/"), "hand tile %d uses its authored 2D face instead of a back or fallback at %s" % [i, viewport_size])
		check(hit_button != null and not hit_button.disabled and hit_button.mouse_filter == Control.MOUSE_FILTER_STOP and tile_rect.grow(5.0).encloses(screen_rect(hit_button)), "hand tile %d exposes a bounded native button target at %s" % [i, viewport_size])
		if hit_button != null:
			if bool(tile.get_meta("drawn_tile", false)):
				drawn_count += 1
				drawn_button_y = screen_rect(hit_button).position.y
			else:
				regular_button_y.append(screen_rect(hit_button).position.y)
		if i > 0:
			var previous_rect := screen_rect(hand_tiles[i - 1])
			var gap := tile_rect.position.x - previous_rect.end.x
			check(gap >= -0.5, "adjacent hand tiles %d/%d do not overlap at %s" % [i - 1, i, viewport_size])
			if scene.should_insert_hand_group_gap(scene.get_self_hand(), i):
				group_gaps.append(gap)
			else:
				regular_gaps.append(gap)
	var largest_regular_gap := 0.0
	for gap in regular_gaps:
		largest_regular_gap = maxf(largest_regular_gap, gap)
	check(not group_gaps.is_empty() and group_gaps.min() >= largest_regular_gap + 3.0, "hand suit groups retain a clear but compact authored gap at %s" % viewport_size)
	var regular_top := INF
	for y in regular_button_y:
		regular_top = minf(regular_top, y)
	check(drawn_count == 1 and drawn_button_y <= regular_top - 3.0, "fourteen-tile hand exposes one stable raised drawn tile at %s" % viewport_size)


func check_discard_archive_access(scene, viewport_size: Vector2, seat: int) -> void:
	var discards: Array = scene.get_discards(seat)
	var archive_button = scene.find_child("DiscardRiverArchiveButton_%d" % seat, true, false) as Button
	check(archive_button != null, "river %d exposes its archive navigation at %s" % [seat, viewport_size])
	if archive_button == null:
		return
	var initial_capacity := maxi(1, int(archive_button.get_meta("visible_capacity", 1)))
	var maximum_page_steps := ceili(float(discards.size()) / float(initial_capacity)) + 1
	for _step in range(maximum_page_steps):
		if int(archive_button.get_meta("window_start", -1)) <= 0:
			break
		archive_button.button_down.emit()
		await settle_layout(0.06)
		archive_button = scene.find_child("DiscardRiverArchiveButton_%d" % seat, true, false) as Button
		if archive_button == null:
			break
	var earliest_grid = scene.find_child("DiscardGrid_%d" % seat, true, false) as GridContainer
	var earliest_first = earliest_grid.get_child(0) as Control if earliest_grid != null and earliest_grid.get_child_count() > 0 else null
	var earliest_start := int(archive_button.get_meta("window_start", -1)) if archive_button != null else -1
	var earliest_capacity := int(archive_button.get_meta("visible_capacity", 0)) if archive_button != null else 0
	var earliest_source := int(earliest_first.get_meta("discard_source_index", -1)) if earliest_first != null else -1
	check(archive_button != null and archive_button.text == scene.discard_archive_button_text(discards.size(), 0, earliest_capacity) and earliest_source == 0, "river %d archive navigation reaches the first public discard at %s (start=%d capacity=%d source=%d)" % [seat, viewport_size, earliest_start, earliest_capacity, earliest_source])
	if archive_button == null:
		return
	archive_button.button_down.emit()
	await settle_layout(0.06)
	var latest_grid = scene.find_child("DiscardGrid_%d" % seat, true, false) as GridContainer
	var latest_last = latest_grid.get_child(latest_grid.get_child_count() - 1) as Control if latest_grid != null and latest_grid.get_child_count() > 0 else null
	var latest_start := int(scene.find_child("DiscardRiverArchiveButton_%d" % seat, true, false).get_meta("window_start", -1)) if scene.find_child("DiscardRiverArchiveButton_%d" % seat, true, false) != null else -1
	var latest_source := int(latest_last.get_meta("discard_source_index", -1)) if latest_last != null else -1
	check(latest_last != null and latest_source == discards.size() - 1, "river %d archive navigation returns to the true latest discard at %s (start=%d source=%d expected=%d)" % [seat, viewport_size, latest_start, latest_source, discards.size() - 1])


func diagnostic_layout_lines() -> Array[String]:
	return [
		"【音频系统诊断 1.0.180-godot】", "",
		"1. 用户激活: 是", "2. 设备: 小米手机 (MIUI)", "",
		"⚠️ 当前音频说明", "BGM已从WAV改为MP3格式", "因为您能听到TTS语音提示",
		"说明音频系统正常", "只是WAV格式不兼容", "", "【请回答】",
		"1. 能听到背景音乐了吗？", "2. 刚才的440Hz测试音听到了吗？", "",
		"3. BGM播放器: 正常", "4. BGM音频流: 已加载", "5. BGM正在播放: 是",
		"6. BGM音量: -8.0dB (0dB=最大)", "7. 音频总线: Master",
		"8. Master总线音量: 0.0dB", "9. Master总线静音: 否",
		"10. 音频格式: AudioStreamMP3", "", "✓ BGM播放成功", "",
		"小米手机听不到声音？", "请检查以下MIUI设置:", "",
		"1. 断开蓝牙设备", "2. 按音量+键调整【媒体音量】", "3. 关闭【游戏加速】",
		"4. 关闭【省电模式】", "5. 设置→应用管理→本应用", "   →省电策略→无限制",
		"6. 尝试重启手机", "", "点击任意位置关闭",
	]


func run_safe_area_layout_probe(viewport_size: Vector2, margins: Vector4) -> void:
	var viewport_i = Vector2i(int(viewport_size.x), int(viewport_size.y))
	root.size = viewport_i
	root.content_scale_size = viewport_i
	DisplayServer.window_set_size(viewport_i)
	await process_frame
	var scene = load("res://Main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.fx_enabled = false
	scene.safe_area_test_margins_override = margins
	scene.show_menu(true)
	await process_frame
	check_safe_area_layout(scene, viewport_size, "menu")
	scene.settings_panel_open = true
	scene.draw_settings_overlay(scene.root_layer)
	await process_frame
	check_safe_area_layout(scene, viewport_size, "settings overlay")
	scene.settings_panel_open = false
	seed_offline_battle_layout_state(scene)
	scene.clear_screen()
	scene.draw_game_top_hud(scene.root_layer)
	for seat_layout in scene.SEAT_LAYOUTS:
		scene.draw_seat(scene.root_layer, int(seat_layout[0]), seat_layout[1], str(seat_layout[2]), {})
	scene.draw_discards(scene.root_layer)
	scene.draw_melds(scene.root_layer)
	scene.draw_table_log(scene.root_layer)
	scene.draw_hand(scene.root_layer)
	scene.draw_actions(scene.root_layer)
	await process_frame
	check_safe_area_layout(scene, viewport_size, "offline battle")
	scene.selected_room = "ROOM7"
	scene.online_room = {"code": "ROOM7", "players": [{"name": "甲"}, {"name": "乙"}], "logs": ["甲加入房间", "乙准备"]}
	scene.online_feedback = "已发送加入房间，等待服务器确认。"
	scene.online_waiting_for_server = true
	scene._show_online_lobby_impl()
	await process_frame
	check_safe_area_layout(scene, viewport_size, "online lobby")
	scene.queue_free()
	await process_frame

func run_layout_checks_for_viewport(viewport_size: Vector2) -> void:
	var viewport_i = Vector2i(int(viewport_size.x), int(viewport_size.y))
	root.size = viewport_i
	root.content_scale_size = viewport_i
	DisplayServer.window_set_size(viewport_i)
	await process_frame
	var scene = load("res://Main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	var original_rule_variant := str(scene.rule_variant)
	var actual_viewport = scene.effective_viewport_size()
	scene.fx_enabled = false
	scene.show_loading_screen()
	await process_frame
	check_loading_layout(scene, actual_viewport)
	seed_offline_battle_layout_state(scene)
	scene.clear_screen()
	scene.draw_game_top_hud(scene.root_layer)
	for seat_layout in scene.SEAT_LAYOUTS:
		scene.draw_seat(scene.root_layer, int(seat_layout[0]), seat_layout[1], str(seat_layout[2]), {})
	scene.draw_discards(scene.root_layer)
	scene.draw_melds(scene.root_layer)
	scene.draw_table_log(scene.root_layer)
	scene.draw_hand(scene.root_layer)
	scene.draw_actions(scene.root_layer)
	await process_frame
	check_top_hud_buttons(scene, actual_viewport)
	check_compact_seat_panels(scene, actual_viewport)
	check_pending_claim_action_bar(scene, actual_viewport)
	await check_table_log_archive_layout(scene, actual_viewport)
	seed_online_pending_claim_layout_state(scene)
	scene.clear_screen()
	scene.draw_game_top_hud(scene.root_layer)
	for seat_layout in scene.SEAT_LAYOUTS:
		scene.draw_seat(scene.root_layer, int(seat_layout[0]), seat_layout[1], str(seat_layout[2]), {})
	scene.draw_discards(scene.root_layer)
	scene.draw_melds(scene.root_layer)
	scene.draw_table_log(scene.root_layer)
	scene.draw_hand(scene.root_layer)
	scene.draw_actions(scene.root_layer)
	await process_frame
	check_pending_claim_action_bar(scene, actual_viewport)
	check_online_pending_claim_layout(scene, actual_viewport)
	await check_chat_panel_layout(scene, actual_viewport)
	seed_offline_battle_layout_state(scene)
	scene.render_game()
	await process_frame
	scene.ai_assist_enabled = true
	scene.render_game()
	await process_frame
	check_advisor_interaction_layout(scene, actual_viewport)
	await check_advisor_detail_layout(scene, actual_viewport)
	scene.ai_assist_enabled = false
	scene.render_game()
	await process_frame
	check(scene.find_child("AdvisorPanel", true, false) == null, "disabling AI advisor removes the panel at %s" % actual_viewport)
	check_hand_tray_layout(scene, actual_viewport)
	check_battle_viewport_bounds(scene, actual_viewport)
	check_discard_tile_original_rgb(scene, actual_viewport)
	seed_danger_discard_layout_state(scene)
	scene.render_game()
	await process_frame
	check_danger_discard_layout(scene, actual_viewport)
	seed_win_detail_layout_state(scene)
	scene.render_game()
	await process_frame
	check_round_summary_layout(scene, actual_viewport)
	await check_online_score_strip_probe(scene, actual_viewport)
	scene.offline_active_rule_variant = scene.RULE_VARIANT_YANGZHOU
	scene.rule_variant = scene.RULE_VARIANT_SICHUAN
	scene.settings_panel_open = true
	scene.draw_settings_overlay(scene.root_layer)
	await process_frame
	check_settings_overlay(scene, actual_viewport)
	await check_accessibility_profile_cycle(scene, actual_viewport)
	var rule_variant_button = scene.find_child("SettingsRuleVariantButton", true, false) as Button
	if rule_variant_button != null:
		rule_variant_button.button_down.emit()
		var refreshed_rule_status = scene.find_child("SettingsRuleVariantStatus", true, false) as Label
		var refreshed_rule_text: String = str(refreshed_rule_status.text) if refreshed_rule_status != null else "<missing>"
		check(refreshed_rule_text == "当前局：扬州 · 下一局：南京", "settings local-rule state refreshes after cycling the queued profile at %s (got %s)" % [actual_viewport, refreshed_rule_text])
	# The selector callback intentionally persists. Restore the pre-smoke profile
	# so layout QA cannot alter later gameplay tests or the developer's settings.
	scene.rule_variant = original_rule_variant
	scene.save_settings()
	scene.settings_panel_open = false
	scene.selected_room = "ROOM7"
	scene.online_room = {"code": "ROOM7", "players": [{"name": "甲"}, {"name": "乙"}], "logs": ["甲加入房间", "乙准备"]}
	scene.online_feedback = "已发送加入房间，等待服务器确认。"
	scene.online_waiting_for_server = true
	scene.show_toast("AI难度 标准", 60000)
	await process_frame
	check(scene.toast_current != null and scene.toast_mode == "offline", "offline battle toast records its source mode at %s" % actual_viewport)
	scene._show_online_lobby_impl()
	var pending_room_edit = scene.find_child("OnlineLobbyRoomEdit", true, false) as LineEdit
	check(scene.online_waiting_for_server and pending_room_edit != null and pending_room_edit.text == "ROOM7", "waiting lobby keeps its pending room draft before transport recovery at %s" % actual_viewport)
	await process_frame
	check(scene.toast_current == null and scene.toast_mode == "" and scene.toast_container != null and not scene.toast_container.visible, "changing from battle to lobby clears the stale toast at %s" % actual_viewport)
	scene.show_toast("大厅同页提示", 60000)
	await process_frame
	var same_page_toast_id: int = scene.toast_current.get_instance_id() if scene.toast_current != null else -1
	scene._show_online_lobby_impl()
	await process_frame
	check(scene.toast_current != null and scene.toast_current.get_instance_id() == same_page_toast_id and scene.toast_mode == "online_lobby", "same-page lobby refresh preserves its active toast at %s" % actual_viewport)
	var waiting_occupancy = scene.find_child("OnlineLobbyRoomSummaryOccupancyLabel", true, false) as Label
	var waiting_room_badge = scene.find_child("OnlineLobbyRoomBadgeLabel", true, false) as Label
	check(not scene.online_waiting_for_server and scene.selected_room == "" and scene.online_room.is_empty() and waiting_occupancy != null and waiting_room_badge != null and waiting_room_badge.text == "房间号 连接后显示", "disconnected lobby recovery clears the stale room snapshot at %s" % actual_viewport)
	scene.set_online_feedback("请先连接服务器。", false)
	scene.clear_online_room_snapshot()
	scene.refresh_online_lobby_state()
	await process_frame
	check_online_lobby_layout(scene, actual_viewport)
	scene._show_rules_screen_impl()
	await process_frame
	check(scene.toast_current == null and scene.toast_mode == "" and not scene.toast_container.visible, "leaving the lobby clears its toast before rules at %s" % actual_viewport)
	check_rules_layout(scene, actual_viewport)
	scene.achievements["first_win"] = true
	scene.achievements["seven_pairs"] = true
	scene.achievements["thirteen_orphans"] = false
	scene.achievements["five_wins"] = false
	scene.achievements["ten_wins"] = false
	scene.game_stats["games_won"] = 3
	scene._show_achievements_screen_impl()
	await process_frame
	check_achievements_layout(scene, actual_viewport)
	scene.game_stats["games_played"] = 9
	scene.game_stats["games_won"] = 1
	scene.game_stats["win_rate"] = 0.111
	scene.game_stats["total_score"] = -7600
	scene.game_stats["best_score"] = 4800
	scene.game_stats["total_hands"] = 17
	scene._show_stats_screen_impl()
	await process_frame
	check_stats_layout(scene, actual_viewport)
	scene._show_shop_screen_impl()
	await process_frame
	check_shop_layout(scene, actual_viewport)
	scene.show_daily_login_panel({"consecutive_days": 5, "show_reward": true})
	await process_frame
	check_daily_login_layout(scene, actual_viewport)
	scene.show_menu(true)
	var diagnostic_lines := diagnostic_layout_lines()
	scene.show_diagnostic_dialog(diagnostic_lines)
	await process_frame
	await check_diagnostic_layout(scene, actual_viewport, diagnostic_lines.size())
	scene.currency = {"coins": 28975, "gems": 10}
	scene.season_data = {"season_id": "qa", "points": 1250, "highest_rank": 2, "wins": 6, "games": 9}
	scene.game_stats["games_played"] = 9
	scene.game_stats["win_rate"] = 0.111
	scene.tutorial_step = 1
	scene.show_menu(true)
	await process_frame
	check_menu_card_layout(scene, actual_viewport)
	check_menu_footer_layout(scene, actual_viewport)
	scene.queue_free()
	await process_frame


func check_diagnostic_layout(scene, viewport_size: Vector2, line_count: int) -> void:
	var panel = scene.find_child("DiagnosticDialogPanel", true, false) as Control
	var scroll = scene.find_child("DiagnosticContentScroll", true, false) as ScrollContainer
	var content_list = scene.find_child("DiagnosticContentList", true, false) as VBoxContainer
	var close_button = scene.find_child("DiagnosticCloseButton", true, false) as Button
	var last_line = scene.find_child("DiagnosticContentLine_%02d" % (line_count - 1), true, false) as Label
	check(panel != null and scroll != null and content_list != null and close_button != null and last_line != null, "diagnostic exposes panel, native content scroll, complete list, and close action at %s" % viewport_size)
	if panel == null or scroll == null or content_list == null or close_button == null or last_line == null:
		return
	var panel_rect = screen_rect(panel)
	var scroll_rect = screen_rect(scroll)
	var list_rect = screen_rect(content_list)
	var close_rect = screen_rect(close_button)
	check(Rect2(Vector2.ZERO, viewport_size).grow(1.0).encloses(panel_rect), "diagnostic panel stays inside viewport at %s" % viewport_size)
	check(panel_rect.grow(1.0).encloses(scroll_rect) and panel_rect.grow(1.0).encloses(close_rect), "diagnostic scroll and fixed close action stay inside panel at %s" % viewport_size)
	check(scroll_rect.size.y >= 44.0 and close_rect.size.x >= 104.0 and close_rect.size.y >= 44.0, "diagnostic scroll and close action retain usable hit areas at %s" % viewport_size)
	check(scroll_rect.end.y + 4.0 <= close_rect.position.y, "diagnostic content clears the fixed close lane at %s" % viewport_size)
	check(scroll.horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED and scroll.vertical_scroll_mode == ScrollContainer.SCROLL_MODE_AUTO, "diagnostic uses vertical-only native scrolling at %s" % viewport_size)
	check(content_list.size_flags_horizontal == Control.SIZE_EXPAND_FILL and list_rect.size.x <= scroll_rect.size.x + 1.0, "diagnostic wrapped content fits the scroll width at %s" % viewport_size)
	check(close_button.focus_mode == Control.FOCUS_ALL and close_button.has_focus(), "diagnostic close action owns modal keyboard focus at %s" % viewport_size)
	check(scroll_rect.end.y + 12.0 <= close_rect.position.y, "diagnostic reading lane leaves a visual buffer before the close action at %s" % viewport_size)
	if scroll.scroll_vertical <= 1:
		for child in content_list.get_children():
			if not child is Label:
				continue
			var row_rect := screen_rect(child as Control)
			var row_intersects_viewport: bool = row_rect.end.y > scroll_rect.position.y and row_rect.position.y < scroll_rect.end.y
			if row_intersects_viewport:
				check(row_rect.position.y >= scroll_rect.position.y - 1.0 and row_rect.end.y <= scroll_rect.end.y + 1.0, "diagnostic initial viewport shows complete text rows at %s" % viewport_size)
	var scroll_bar := scroll.get_v_scroll_bar()
	check(scroll_bar != null and scroll_bar.max_value > scroll_bar.page, "full diagnostic report creates a vertical scroll range at %s" % viewport_size)
	if scroll_bar == null or scroll_bar.max_value <= scroll_bar.page:
		return
	scroll.scroll_vertical = int(ceil(scroll_bar.max_value - scroll_bar.page))
	await process_frame
	await process_frame
	var last_rect = screen_rect(last_line)
	check(last_rect.position.y >= scroll_rect.position.y - 1.0 and last_rect.end.y <= scroll_rect.end.y + 1.0, "diagnostic final line is reachable at the bottom of the scroll range at %s" % viewport_size)


func check_loading_layout(scene, viewport_size: Vector2) -> void:
	var center_panel = scene.find_child("LoadingCenterPanel", true, false) as Control
	var title = scene.find_child("LoadingTitleLabel", true, false) as Label
	var subtitle = scene.find_child("LoadingSubtitleLabel", true, false) as Label
	var status = scene.find_child("LoadingStatusLabel", true, false) as Label
	var tip = scene.find_child("LoadingTipLabel", true, false) as Label
	var version = scene.find_child("LoadingVersionLabel", true, false) as Label
	var shuffle_art = scene.find_child("LoadingShuffleArt", true, false) as Control
	var progress_art = scene.find_child("LoadingProgressFeedback", true, false) as Control
	var progress_route = scene.find_child("LoadingProgressRoute", true, false) as Control
	var progress_fill = scene.find_child("LoadingProgressFill", true, false) as Control
	var progress_gate = scene.find_child("LoadingProgressGate", true, false) as Control
	var tip_art = scene.find_child("LoadingTipArt", true, false) as Control
	var tip_rail = scene.find_child("LoadingTipRail", true, false) as Control
	var tip_fill = scene.find_child("LoadingTipFill", true, false) as Control
	var gpt_backdrop = scene.find_child("LoadingGPTBackdropTexture", true, false) as Control
	var moon = scene.find_child("LoadingMoon", true, false) as Panel
	var moon_glow = scene.find_child("MoonGlowBloom", true, false) as Control
	var far_mountain = scene.find_child("LoadingFarMountain", true, false) as Control
	var water = scene.find_child("LoadingWater", true, false) as Control
	check(center_panel != null and title != null and subtitle != null and status != null and tip != null and version != null, "loading screen exposes named readable text nodes at %s" % viewport_size)
	check(shuffle_art != null and progress_art != null and progress_route != null and progress_fill != null and progress_gate != null and tip_art != null and tip_rail != null and tip_fill != null, "loading screen renders progress and tip route art for layout audit at %s" % viewport_size)
	var loading_face_count := 0
	for i in range(5):
		var shuffle_tile = scene.find_child("LoadingShuffleTile_%d" % i, true, false) as Control
		if shuffle_tile != null and shuffle_tile.find_child("TileFaceTexture", true, false) is TextureRect:
			loading_face_count += 1
	check(loading_face_count == 5, "loading shuffle uses five authored 2D tile faces instead of blank box-like backs at %s" % viewport_size)
	if gpt_backdrop != null:
		var moon_style: StyleBoxFlat = null
		if moon != null:
			moon_style = moon.get_theme_stylebox("panel") as StyleBoxFlat
		check(moon_style != null and moon_style.bg_color.a <= 0.01 and moon_style.border_color.a <= 0.01, "loading GPT backdrop suppresses fallback moon rectangle at %s" % viewport_size)
		check(moon_glow != null and _control_is_subdued_art(moon_glow, 0.02), "loading GPT backdrop suppresses rectangular moon glow overlay at %s" % viewport_size)
		check(far_mountain != null and _control_is_subdued_art(far_mountain, 0.02), "loading GPT backdrop suppresses fallback mountain rectangle at %s" % viewport_size)
		check(water != null and _control_is_subdued_art(water, 0.02), "loading GPT backdrop suppresses fallback water rectangle at %s" % viewport_size)
	if center_panel == null:
		return
	var center_rect = screen_rect(center_panel)
	check(center_rect.position.x >= viewport_size.x * 0.250 and center_rect.end.x <= viewport_size.x * 0.750 and center_rect.position.y >= viewport_size.y * 0.170 and center_rect.end.y <= viewport_size.y * 0.835, "loading center panel stays in the safe focal area at %s" % viewport_size)
	check(center_rect.size.x >= viewport_size.x * 0.40 and center_rect.size.y >= viewport_size.y * 0.55, "loading center panel keeps enough room for title, shuffle, progress and tip at %s" % viewport_size)
	var label_nodes: Array[Label] = [title, subtitle, status, tip, version]
	for label in label_nodes:
		if label == null:
			continue
		var label_rect = screen_rect(label)
		check(center_rect.grow(1.0).encloses(label_rect), "loading label %s stays inside center panel at %s" % [label.name, viewport_size])
		check(label.clip_text, "loading label %s clips safely at %s" % [label.name, viewport_size])
	check(title != null and title.get_theme_font_size("font_size") >= 44 and relative_luma(title.get_theme_color("font_color")) >= 0.82, "loading title remains prominent and bright at %s" % viewport_size)
	check(subtitle != null and subtitle.get_theme_font_size("font_size") >= 17 and relative_luma(subtitle.get_theme_color("font_color")) >= 0.74, "loading subtitle remains readable at %s" % viewport_size)
	check(status != null and status.get_theme_font_size("font_size") >= 19 and relative_luma(status.get_theme_color("font_color")) >= 0.82, "loading status text remains readable at %s" % viewport_size)
	check(tip != null and tip.get_theme_font_size("font_size") >= 13 and relative_luma(tip.get_theme_color("font_color")) >= 0.66, "loading tip text remains readable at %s" % viewport_size)
	check(version != null and version.get_theme_font_size("font_size") >= 11 and relative_luma(version.get_theme_color("font_color")) >= 0.50, "loading version text remains visible but quiet at %s" % viewport_size)
	for node in [shuffle_art, progress_art, progress_route, progress_fill, progress_gate, tip_art, tip_rail, tip_fill]:
		if node == null:
			continue
		check(center_rect.grow(1.0).encloses(screen_rect(node)), "loading art node %s stays inside center panel at %s" % [node.name, viewport_size])
	if progress_route != null and progress_fill != null:
		check(screen_rect(progress_route).grow(1.0).encloses(screen_rect(progress_fill)), "loading progress fill stays inside progress route at %s" % viewport_size)
	if tip_rail != null and tip_fill != null:
		check(screen_rect(tip_rail).grow(1.0).encloses(screen_rect(tip_fill)), "loading tip fill stays inside tip rail at %s" % viewport_size)
	if shuffle_art != null and status != null:
		check(screen_rect(shuffle_art).end.y <= screen_rect(status).position.y - 4.0, "loading shuffle art clears the status text at %s" % viewport_size)
	if status != null and progress_art != null:
		check(screen_rect(status).end.y <= screen_rect(progress_art).position.y - 6.0, "loading progress feedback clears the status text at %s" % viewport_size)
	if status != null and progress_route != null:
		check(screen_rect(status).end.y <= screen_rect(progress_route).position.y - 8.0, "loading progress route leaves a readable gap below the status text at %s" % viewport_size)
	if progress_art != null and tip_art != null:
		check(screen_rect(progress_art).end.y <= screen_rect(tip_art).position.y - 3.0, "loading progress feedback clears the tip art lane at %s" % viewport_size)

func check_online_score_strip_probe(scene, viewport_size: Vector2) -> void:
	var saved_mode = scene.mode
	var saved_online_game = scene.online_game.duplicate(true)
	var saved_current_seat = scene.current_seat
	var probe = Control.new()
	probe.name = "OnlineScoreStripProbe"
	probe.size = viewport_size
	probe.set_anchors_preset(Control.PRESET_FULL_RECT)
	scene.root_layer.add_child(probe)
	scene.mode = "online_game"
	scene.current_seat = 0
	scene.online_game = {
		"roomCode": "QA7",
		"phase": "awaitDiscard",
		"youSeat": 0,
		"currentSeat": 2,
		"wallCount": 58,
		"players": [
			{"seat": 0, "name": "南屏听雨阁主", "handCount": 13, "flowerCount": 0, "score": 26000},
			{"seat": 1, "name": "东风夜放花千树", "handCount": 13, "flowerCount": 1, "score": 23800},
			{"seat": 2, "name": "南山有鸟", "handCount": 13, "flowerCount": 0, "score": 27200},
			{"seat": 3, "name": "北海若", "handCount": 13, "flowerCount": 0, "score": 23000},
		],
	}
	scene.draw_game_top_hud(probe)
	await process_frame
	check_score_strip_layout(probe, viewport_size)
	probe.queue_free()
	scene.mode = saved_mode
	scene.online_game = saved_online_game
	scene.current_seat = saved_current_seat

func check_top_hud_buttons(scene, viewport_size: Vector2) -> void:
	var hud = scene.find_child("TopHud3DShell", true, false) as Control
	var title = scene.find_child("TopHudTitle", true, false) as Control
	var status = scene.find_child("TopHudStatus", true, false) as Control
	var title_back = scene.find_child("TopHudTitleBack", true, false) as Control
	var status_back = scene.find_child("TopHudStatusBack", true, false) as Control
	var wall_back = scene.find_child("TopHudWallBack", true, false) as Control
	var wall_text = scene.find_child("TopHudWallText", true, false) as Label
	var wall_meter = scene.find_child("TopHudWallMeter", true, false) as Control
	var score_strip = scene.find_child("ScoreStrip", true, false) as Control
	check(hud != null and hud.clip_contents, "top HUD clips decorative artwork at %s" % viewport_size)
	check(title != null and status != null and title_back != null and status_back != null and wall_back != null and wall_text != null and wall_meter != null, "top HUD exposes readable title status and wall groups at %s" % viewport_size)
	check(scene.rule_wall_size("guangdong") == 136 and scene.rule_wall_size("sichuan") == 108 and scene.rule_wall_size("yangzhou") == 144, "rule profiles expose their actual wall totals at %s" % viewport_size)
	var saved_active_variant := str(scene.offline_active_rule_variant)
	scene.offline_active_rule_variant = scene.RULE_VARIANT_GUANGDONG
	check(scene.display_wall_total() == 136 and scene.wall_low_threshold() == 23 and scene.wall_critical_threshold() == 17, "Guangdong wall thresholds scale from the active 136-tile rule at %s" % viewport_size)
	scene.offline_active_rule_variant = scene.RULE_VARIANT_SICHUAN
	check(scene.display_wall_total() == 108 and scene.wall_low_threshold() == 18 and scene.wall_critical_threshold() == 14, "Sichuan wall thresholds scale from the active 108-tile rule at %s" % viewport_size)
	scene.offline_active_rule_variant = saved_active_variant
	if title != null and status != null:
		var title_rect = screen_rect(title)
		var status_rect = screen_rect(status)
		check(title_rect.size.x >= min(132.0, viewport_size.x * 0.13), "top HUD title keeps enough width for round text at %s" % viewport_size)
		check(not title_rect.intersects(status_rect, true), "top HUD title and status do not overlap at %s" % viewport_size)
		if title_back != null and status_back != null:
			check(screen_rect(title_back).grow(1.0).encloses(title_rect), "top HUD title backplate contains title at %s" % viewport_size)
			check(screen_rect(status_back).grow(1.0).encloses(status_rect), "top HUD status backplate contains status at %s" % viewport_size)
		if title is Label:
			var title_label := title as Label
			check(title_label.clip_text and title_label.get_theme_font_size("font_size") >= 15 and relative_luma(title_label.get_theme_color("font_color")) >= 0.74, "top HUD title remains bright and clipped at %s" % viewport_size)
			if viewport_size.x <= 960.0:
				check(not title_label.text.contains("...") and not title_label.text.contains("…"), "compact top HUD title keeps the round and dealer visible without ellipsis at %s" % viewport_size)
		if status is Label:
			var status_label := status as Label
			check(status_label.clip_text and status_label.get_theme_font_size("font_size") >= 15 and relative_luma(status_label.get_theme_color("font_color")) >= 0.86, "top HUD status remains bright and clipped at %s" % viewport_size)
	if wall_text != null and wall_back != null and wall_meter != null:
		var wall_text_rect = screen_rect(wall_text)
		var wall_back_rect = screen_rect(wall_back)
		var wall_meter_rect = screen_rect(wall_meter)
		check(wall_back_rect.grow(1.0).encloses(wall_text_rect) and wall_back_rect.grow(1.0).encloses(wall_meter_rect), "top HUD wall backplate contains text and meter at %s" % viewport_size)
		check(wall_text.clip_text and wall_text.get_theme_font_size("font_size") >= 11 and relative_luma(wall_text.get_theme_color("font_color")) >= 0.78, "top HUD wall text remains readable at %s" % viewport_size)
		check(str(wall_text.text).begins_with("余牌 ") and wall_text.tooltip_text.contains("牌墙剩余") and wall_text.tooltip_text.contains("上张"), "top HUD wall counter and last-discard context remain explicit at %s" % viewport_size)
		if status != null:
			check(screen_rect(status).end.x <= wall_back_rect.position.x - 2.0, "top HUD status clears wall badge at %s" % viewport_size)
	if scene.mode == "offline":
		check(score_strip == null, "offline top HUD keeps duplicate score strip off at %s" % viewport_size)
	var labels := ["设置", "返回", "更新"]
	var rects: Array[Rect2] = []
	for label_text in labels:
		var button = first_top_hud_button(scene.root_layer, label_text)
		check(button != null, "top HUD has %s button at %s" % [label_text, viewport_size])
		if button == null:
			continue
		check(button.tooltip_text != label_text and button.tooltip_text != "", "top HUD %s tooltip explains the full action at %s" % [label_text, viewport_size])
		var rect = screen_rect(button)
		rects.append(rect)
		check(rect.size.x >= 44.0 and rect.size.y >= 36.0, "top HUD %s keeps practical touch target at %s" % [label_text, viewport_size])
		check(rect.position.x >= -0.5 and rect.end.x <= viewport_size.x + 0.5, "top HUD %s stays inside viewport at %s" % [label_text, viewport_size])
		if wall_back != null:
			check(screen_rect(wall_back).end.x <= rect.position.x - 2.0 or label_text != "设置", "top HUD wall badge clears settings button at %s" % viewport_size)
		var icon_back = button.find_child("TopHudButtonIconBack_%s" % label_text, true, false) as Control
		var rail = button.find_child("TopHudButtonRail_%s" % label_text, true, false) as Control
		var seal = button.find_child("TopHudButtonSeal_%s" % label_text, true, false) as Control
		check(icon_back != null and rail != null and seal != null, "top HUD %s keeps compact icon material accents at %s" % [label_text, viewport_size])
		check(button.find_child("TopHudButtonCommandRoute_%s" % label_text, true, false) == null and button.find_child("TopHudButtonCommandFill_%s" % label_text, true, false) == null and button.find_child("TopHudButtonCommandGate_%s" % label_text, true, false) == null, "top HUD %s omits command route clutter at %s" % [label_text, viewport_size])
		check(count_nodes_with_name_prefix(button, "TopHudButtonCommandTick_%s_" % label_text) == 0 and count_nodes_with_name_prefix(button, "TopHudButtonPulse_%s_" % label_text) == 0, "top HUD %s omits rhythm ticks and pulses at %s" % [label_text, viewport_size])
		if icon_back != null:
			check(rect.grow(1.0).encloses(screen_rect(icon_back)), "top HUD %s icon back stays inside button at %s" % [label_text, viewport_size])
		if rail != null:
			var rail_rect = screen_rect(rail)
			check(rail_rect.size.y <= rect.size.y * 0.06 and rail_rect.position.y >= rect.position.y + rect.size.y * 0.78, "top HUD %s rail stays as a bottom edge detail at %s" % [label_text, viewport_size])
		if seal != null:
			var seal_rect = screen_rect(seal)
			check(seal_rect.size.x <= rect.size.x * 0.08 and seal_rect.position.x >= rect.position.x + rect.size.x * 0.70, "top HUD %s seal stays compact at %s" % [label_text, viewport_size])
		for i in range(rects.size()):
			for j in range(i + 1, rects.size()):
				check(not rects[i].intersects(rects[j], true), "top HUD buttons do not overlap at %s" % viewport_size)

func check_menu_card_layout(scene, viewport_size: Vector2) -> void:
	var text_backplates = controls_with_name_prefix(scene, "MenuCardTextBackplate")
	var title_labels = controls_with_name_prefix(scene, "MenuCardTitleLabel")
	var subtitle_labels = controls_with_name_prefix(scene, "MenuCardSubtitleLabel")
	var quick_rail = scene.find_child("MenuQuickActionRail", true, false) as Control
	var footer = scene.find_child("MenuFooterTextLayer", true, false) as Control
	var header = scene.find_child("MenuTitleTextLayer", true, false) as Control
	var product_title = scene.find_child("MenuTitleLabel", true, false) as Label
	var rule_summary = scene.find_child("MenuTitleRule", true, false) as Label
	var stage_overlay = scene.find_child("MenuPrimary3DStageGPTOverlay", true, false) as CanvasItem
	var commercial_stage = scene.find_child("MenuCommercial3DStage", true, false) as CanvasItem
	var menu_scrim = scene.find_child("MenuBackgroundReadabilityScrim", true, false) as CanvasItem
	check(text_backplates.size() == 3 and title_labels.size() == 3 and subtitle_labels.size() == 3, "menu primary cards expose readable title subtitle and text backplates at %s" % viewport_size)
	check(header != null and product_title != null and rule_summary != null, "menu exposes named foreground title and current-rule summary at %s" % viewport_size)
	if header != null and product_title != null:
		check(product_title.text == "云桌麻将" and product_title.get_theme_font_size("font_size") >= 28, "menu product title keeps its full name and commercial display size at %s" % viewport_size)
		check(relative_luma(product_title.get_theme_color("font_color")) >= 0.80, "menu product title keeps bright foreground contrast at %s" % viewport_size)
	if rule_summary != null:
		check(rule_summary.text.contains(scene.rule_variant_label()) and rule_summary.clip_text, "menu title summary exposes the active local rule without truncation at %s" % viewport_size)
		if stage_overlay != null and stage_overlay.get_parent() == header.get_parent():
			check(header.get_index() > stage_overlay.get_index(), "menu product title draws above the full-screen GPT stage at %s" % viewport_size)
			if commercial_stage != null and commercial_stage.get_parent() == header.get_parent():
				check(header.get_index() > commercial_stage.get_index(), "menu product title draws above the commercial stage at %s" % viewport_size)
	check(commercial_stage == null, "menu does not mount an executable 3D tile showcase at %s" % viewport_size)
	check(menu_scrim != null and stage_overlay != null, "menu keeps one GPT background scrim and one full-screen scene at %s" % viewport_size)
	check(scene.find_child("MenuHeroGPTBackdropTexture", true, false) == null and scene.find_child("MenuLobbyGeneratedUIOverlay", true, false) == null and scene.find_child("GuofengPaperSceneryBackdrop", true, false) == null, "menu omits duplicate full-screen hero and generic scenery layers at %s" % viewport_size)
	var quick_actions := {
		"Rules": "规则",
		"Stats": "战绩",
		"Achievements": "成就",
		"Shop": "商店",
	}
	var quick_rects: Array[Rect2] = []
	for quick_id in quick_actions:
		var quick_button = scene.find_child("MenuQuick%sButton" % quick_id, true, false) as Button
		check(quick_button != null, "menu quick action %s exists at %s" % [quick_actions[quick_id], viewport_size])
		if quick_button != null:
			check(quick_button.text == str(quick_actions[quick_id]) and quick_button.get_theme_font_size("font_size") >= 18, "menu quick action %s keeps a readable native label at %s" % [quick_actions[quick_id], viewport_size])
			check_button_face_behind_native_text(quick_button, "menu quick action %s" % quick_actions[quick_id], viewport_size)
			var quick_rect = screen_rect(quick_button)
			check(quick_rect.size.x >= 96.0 and quick_rect.size.y >= 44.0, "menu quick action %s keeps a non-overlapping touch target at %s" % [quick_actions[quick_id], viewport_size])
			if quick_rail != null:
				check(screen_rect(quick_rail).grow(1.0).encloses(quick_rect), "menu quick action %s stays inside its rail at %s" % [quick_actions[quick_id], viewport_size])
			for previous_rect in quick_rects:
				check(not previous_rect.intersects(quick_rect, true), "menu quick action %s does not overlap another shortcut at %s" % [quick_actions[quick_id], viewport_size])
			quick_rects.append(quick_rect)
	for backplate in text_backplates:
		var card = backplate.get_parent() as Button
		check(card != null, "menu card text backplate belongs to a button at %s" % viewport_size)
		if card == null:
			continue
		var card_rect = screen_rect(card)
		var back_rect = screen_rect(backplate)
		var title = card.find_child("MenuCardTitleLabel", true, false) as Label
		var subtitle = card.find_child("MenuCardSubtitleLabel", true, false) as Label
		check(card_rect.grow(1.0).encloses(back_rect), "menu card text backplate stays inside card at %s" % viewport_size)
		check(back_rect.size.x >= card_rect.size.x * 0.58 and back_rect.size.y >= card_rect.size.y * 0.52, "menu card text backplate gives labels a stable reading lane at %s" % viewport_size)
		if title != null and subtitle != null:
			var title_rect = screen_rect(title)
			var subtitle_rect = screen_rect(subtitle)
			check(back_rect.grow(1.0).encloses(title_rect) and back_rect.grow(1.0).encloses(subtitle_rect), "menu card labels stay inside text backplate at %s" % viewport_size)
			check(title.clip_text and subtitle.clip_text and title.get_theme_font_size("font_size") >= 21 and subtitle.get_theme_font_size("font_size") >= 14, "menu card text clips safely and keeps readable size at %s" % viewport_size)
			check(relative_luma(title.get_theme_color("font_color")) >= 0.86 and relative_luma(subtitle.get_theme_color("font_color")) >= 0.86, "menu card title and subtitle keep readable contrast at %s" % viewport_size)
			check(not rects_overlap(title_rect, subtitle_rect), "menu card title and subtitle do not overlap at %s" % viewport_size)
		if quick_rail != null:
			check(screen_rect(card).end.y <= screen_rect(quick_rail).position.y + 26.0, "menu card clears the quick action rail at %s" % viewport_size)
		if footer != null:
			check(screen_rect(card).end.y <= screen_rect(footer).position.y - 8.0, "menu card clears the footer status bar at %s" % viewport_size)

func check_menu_footer_layout(scene, viewport_size: Vector2) -> void:
	var footer = scene.find_child("MenuFooterTextLayer", true, false) as Control
	var settings = scene.find_child("MenuSettingsButton", true, false) as Button
	var bridge = scene.find_child("MenuFooterEconomyStatsBridge", true, false) as Control
	check(footer != null and settings != null and bridge != null, "menu footer exposes footer settings and bridge at %s" % viewport_size)
	if footer == null:
		return
	var footer_rect = screen_rect(footer)
	check(footer_rect.position.x >= -0.5 and footer_rect.end.x <= viewport_size.x + 0.5, "menu footer stays horizontally inside viewport at %s" % viewport_size)
	check(footer_rect.end.y <= viewport_size.y + 0.5 and footer_rect.size.y >= max(50.0, viewport_size.y * 0.105), "menu footer keeps a readable status band at %s" % viewport_size)
	var chip_labels := {
		"version": "MenuVersionBadge",
		"currency": "MenuCurrencyBadge",
		"rank": "MenuRankBadge",
		"stats": "MenuStatsBadge",
	}
	var previous_right := -1.0
	var previous_top := -1.0
	var rects: Array[Rect2] = []
	for chip_id in ["version", "currency", "rank", "stats"]:
		var chip = scene.find_child("MenuFooterStatusChip_%s" % chip_id, true, false) as Control
		var label = scene.find_child(str(chip_labels[chip_id]), true, false) as Label
		check(chip != null and label != null, "menu footer chip %s exposes chip and label at %s" % [chip_id, viewport_size])
		if chip == null or label == null:
			continue
		var chip_rect = screen_rect(chip)
		var label_rect = screen_rect(label)
		rects.append(chip_rect)
		check(footer_rect.grow(1.0).encloses(chip_rect), "menu footer chip %s stays inside footer at %s" % [chip_id, viewport_size])
		check(chip_rect.grow(1.0).encloses(label_rect), "menu footer chip %s contains its label at %s" % [chip_id, viewport_size])
		check(chip_rect.size.y >= 32.0 and chip_rect.size.x >= 100.0, "menu footer chip %s keeps a readable footprint at %s" % [chip_id, viewport_size])
		check(label.clip_text and label.text_overrun_behavior == TextServer.OVERRUN_TRIM_ELLIPSIS, "menu footer label %s clips safely at %s" % [chip_id, viewport_size])
		check(label.get_theme_font_size("font_size") >= 13 and relative_luma(label.get_theme_color("font_color")) >= 0.82, "menu footer label %s remains readable at %s" % [chip_id, viewport_size])
		if chip_id == "version":
			var expected_version_text := "版本 v%s" % scene.app_version_short()
			check(label.text == expected_version_text, "menu footer version uses compact display text at %s" % viewport_size)
			check(not str(label.text).contains("-godot") and not str(label.text).contains("...") and not str(label.text).contains("…"), "menu footer version avoids visible truncation at %s" % viewport_size)
			check(label_text_width(label, str(label.text)) <= label_rect.size.x + 1.0, "menu footer version text fits without rendered ellipsis at %s" % viewport_size)
		check(chip_rect.position.x >= previous_right + 4.0, "menu footer chips remain ordered with gaps at %s" % viewport_size)
		previous_right = chip_rect.end.x
	check(scene.find_child("MenuCurrencyBadgeArt", true, false) != null and scene.find_child("MenuCurrencyBrocadeTexture", true, false) != null, "menu footer currency chip keeps reusable art layer or fallback at %s" % viewport_size)
	check(scene.find_child("MenuStatsBadgeArt", true, false) != null and scene.find_child("MenuStatsBadgeRail", true, false) != null, "menu footer stats chip keeps trend art layer at %s" % viewport_size)
	if settings != null:
		var settings_rect = screen_rect(settings)
		rects.append(settings_rect)
		check(footer_rect.grow(1.0).encloses(settings_rect), "menu settings button stays inside footer at %s" % viewport_size)
		check(settings_rect.size.x >= 88.0 and settings_rect.size.y >= 40.0, "menu settings button keeps practical touch size at %s" % viewport_size)
		check(settings.text == "设置" and settings.get_theme_font_size("font_size") >= 15, "menu settings button keeps a readable native label at %s" % viewport_size)
		check_button_face_behind_native_text(settings, "menu settings button", viewport_size)
		scene.center_touch_button_pivot_by_id(settings.get_instance_id())
		check(settings.pivot_offset.distance_to(settings.size * 0.5) <= 1.0, "menu settings button press feedback stays centered at %s" % viewport_size)
		check(settings.find_child("MenuSettingsButtonArt", true, false) != null and settings.find_child("MenuSettingsGearTexture", true, false) != null, "menu settings button keeps material art and gear layer at %s" % viewport_size)
	for i in range(rects.size()):
		for j in range(i + 1, rects.size()):
			check(not rects_overlap(rects[i], rects[j]), "menu footer status elements do not overlap at %s" % viewport_size)

func check_score_strip_layout(scope: Node, viewport_size: Vector2) -> void:
	var score_strip = scope.find_child("ScoreStrip", true, false) as Control
	check(score_strip != null, "online top HUD exposes score strip at %s" % viewport_size)
	if score_strip != null:
		var strip_rect = screen_rect(score_strip)
		check(count_nodes_with_name_prefix(score_strip, "ScoreStripChip_") == 4 and count_nodes_with_name_prefix(score_strip, "ScoreStripSeatSeal_") == 4, "score strip keeps four quiet seat chips at %s" % viewport_size)
		check(count_nodes_with_name_prefix(score_strip, "ScoreStripName_") == 4 and count_nodes_with_name_prefix(score_strip, "ScoreStripScore_") == 4, "score strip keeps four clipped names and scores at %s" % viewport_size)
		check(count_nodes_with_name_prefix(score_strip, "ScoreStripDeltaRoute_") == 0 and count_nodes_with_name_prefix(score_strip, "ScoreStripChaseRoute_") == 0 and count_nodes_with_name_prefix(score_strip, "ScoreStripLeaderRoute_") == 0, "score strip omits route clutter at %s" % viewport_size)
		check(count_nodes_with_name_prefix(score_strip, "ScoreStripDeltaTick_") == 0 and count_nodes_with_name_prefix(score_strip, "ScoreStripChaseTick_") == 0 and count_nodes_with_name_prefix(score_strip, "ScoreStripRankTick_") == 0, "score strip omits rhythm ticks at %s" % viewport_size)
		for seat in range(4):
			var chip = score_strip.find_child("ScoreStripChip_%d" % seat, true, false) as Control
			var name = score_strip.find_child("ScoreStripName_%d" % seat, true, false) as Label
			var score = score_strip.find_child("ScoreStripScore_%d" % seat, true, false) as Label
			var momentum = score_strip.find_child("ScoreStripMomentumRail_%d" % seat, true, false) as Control
			check(chip != null and name != null and score != null and momentum != null, "score strip seat %d exposes compact chip parts at %s" % [seat, viewport_size])
			if chip == null:
				continue
			var chip_rect = screen_rect(chip)
			check(strip_rect.grow(1.0).encloses(chip_rect), "score strip seat %d chip stays inside strip at %s" % [seat, viewport_size])
			if name != null:
				check(chip_rect.grow(1.0).encloses(screen_rect(name)) and name.clip_text, "score strip seat %d name clips inside chip at %s" % [seat, viewport_size])
				check(str(name.text).length() <= 3, "score strip seat %d name stays compact (<=3) at %s" % [seat, viewport_size])
				check(relative_luma(name.get_theme_color("font_color")) >= 0.90, "score strip seat %d name stays bright at %s" % [seat, viewport_size])
			if score != null:
				check(chip_rect.grow(1.0).encloses(screen_rect(score)) and score.clip_text, "score strip seat %d score clips inside chip at %s" % [seat, viewport_size])
			if momentum != null:
				var momentum_rect = screen_rect(momentum)
				check(momentum_rect.size.y <= chip_rect.size.y * 0.16 and momentum_rect.position.y >= chip_rect.position.y + chip_rect.size.y * 0.62, "score strip seat %d momentum stays a bottom detail at %s" % [seat, viewport_size])

func check_pending_claim_action_bar(scene, viewport_size: Vector2) -> void:
	var expected := ["胡", "杠", "碰", "吃1-3", "吃2-4", "吃3-5", "过"]
	var removed_long_labels := ["吃123万", "吃234万", "吃345万"]
	var previous_right := -1.0
	var previous_top := -1.0
	var found := 0
	for text in expected:
		var button = first_button_with_text(scene.action_bar, text)
		check(button != null, "pending claim action bar has %s at %s" % [text, viewport_size])
		if button == null:
			continue
		found += 1
		var rect = screen_rect(button)
		check(rect.size.x >= scene.ACTION_BUTTON_MIN_TOUCH_WIDTH - 0.5 and rect.size.y >= 40.0, "pending claim %s keeps touch target at %s" % [text, viewport_size])
		check(button.get_theme_font_size("font_size") >= 14, "pending claim %s keeps readable native action text at %s" % [text, viewport_size])
		check_button_face_behind_native_text(button, "pending claim action %s" % text, viewport_size)
		for decoration_name in ["ActionButtonArt", "ActionButton3DDepthEdge", "ActionButton3DTopRim", "ActionButton3DSideBevel", "ActionButtonSheen", "ActionButtonPanelPlate"]:
			var decoration = button.find_child(decoration_name, false, false) as CanvasItem
			check(decoration == null or decoration.show_behind_parent, "pending claim %s keeps %s behind native text at %s" % [text, decoration_name, viewport_size])
		check(rect.position.x >= -0.5 and rect.end.x <= viewport_size.x + 0.5, "pending claim %s stays inside viewport at %s" % [text, viewport_size])
		if previous_top >= 0.0 and rect.position.y > previous_top + 2.0:
			previous_right = -1.0
		check(rect.position.x >= previous_right - 0.5, "pending claim buttons remain ordered within each wrapped row at %s" % viewport_size)
		check(button.find_child("ActionButtonEnergyDot_0", true, false) == null, "pending claim %s uses compact action styling without energy dots at %s" % [text, viewport_size])
		var shortcut_hint = button.find_child("ActionButtonShortcutHint", true, false) as Label
		check(shortcut_hint != null and shortcut_hint.text == scene.action_button_shortcut_hint(text) and button.get_meta("action_shortcut", "") == shortcut_hint.text, "pending claim %s exposes its keyboard shortcut in the action node at %s" % [text, viewport_size])
		previous_right = rect.end.x
		previous_top = rect.position.y
	check(found == expected.size(), "pending claim complex action bar renders all legal choices at %s" % viewport_size)
	var response_grid = scene.find_child("PendingClaimResponseGrid", true, false) as Control
	var response_buttons: Array[Button] = []
	if response_grid != null:
		collect_buttons(response_grid, response_buttons)
	var tail_buttons: Array[Button] = []
	var tail_lane = scene.find_child("PendingClaimSecondaryLane", true, false) as Control
	if tail_lane != null:
		collect_buttons(tail_lane, tail_buttons)
	var pending_buttons: Array[Button] = scene.action_bar_buttons()
	var response_rows: Dictionary = {}
	var pending_last_button_bottom := -1.0
	for button in response_buttons:
		var action_rect = screen_rect(button)
		var row_key := int(round(action_rect.position.y))
		response_rows[row_key] = int(response_rows.get(row_key, 0)) + 1
	for button in pending_buttons:
		pending_last_button_bottom = maxf(pending_last_button_bottom, screen_rect(button).end.y)
	var response_columns := 1
	if response_grid is GridContainer:
		response_columns = (response_grid as GridContainer).columns
	check(response_grid != null, "pending claim actions expose a dedicated response grid at %s" % viewport_size)
	check(response_buttons.size() == scene.pending_claim_response_count(pending_buttons.size()), "pending claim response grid contains only response choices at %s" % viewport_size)
	check(response_rows.size() == int(ceil(float(response_buttons.size()) / float(maxi(1, response_columns)))), "pending claim response rows match the grid contract at %s" % viewport_size)
	check(tail_lane != null and tail_buttons.size() == scene.pending_claim_tail_button_count(), "pending claim actions expose the expected secondary tail lane at %s" % viewport_size)
	if viewport_size.x <= 960.0:
		var widest_row := 0
		for row_count in response_rows.values():
			widest_row = maxi(widest_row, int(row_count))
		check(widest_row >= mini(5, response_buttons.size()), "compact pending claim responses keep the widened primary row at %s" % viewport_size)
	check(tail_lane != null and tail_buttons.size() == scene.pending_claim_tail_button_count(), "pending claim actions expose the expected buttons inside one secondary lane at %s" % viewport_size)
	if tail_lane != null:
		var tail_lane_rect = screen_rect(tail_lane)
		check(absf(tail_lane_rect.size.x - scene.action_bar_pixel_width()) <= 2.0, "pending claim secondary lane spans the action width at %s (actual=%.1f expected=%.1f)" % [viewport_size, tail_lane_rect.size.x, scene.action_bar_pixel_width()])
		for tail_button in tail_buttons:
			check(tail_lane_rect.grow(1.0).encloses(screen_rect(tail_button)) and screen_rect(tail_button).size.x >= scene.ACTION_BUTTON_MIN_TOUCH_WIDTH - 0.5, "pending claim tail button stays in its secondary lane at %s" % viewport_size)
	check(response_rows.size() + scene.pending_claim_action_tail_count() == scene.pending_claim_action_row_count(pending_buttons.size()), "pending claim response and tail rows form the complete action stack at %s" % viewport_size)
	if response_grid is GridContainer and not response_buttons.is_empty():
		var focus_columns := maxi(1, (response_grid as GridContainer).columns)
		var expected_right := response_buttons[1] if focus_columns > 1 and response_buttons.size() > 1 else response_buttons[0]
		var expected_bottom := response_buttons[focus_columns] if response_buttons.size() > focus_columns else (tail_buttons[0] if not tail_buttons.is_empty() else response_buttons[0])
		check(response_buttons[0].focus_neighbor_right == expected_right.get_path(), "pending claim left/right focus follows the visible response row at %s" % viewport_size)
		check(response_buttons[0].focus_neighbor_bottom == expected_bottom.get_path(), "pending claim up/down focus follows the visible response column at %s" % viewport_size)
		if not tail_buttons.is_empty():
			var last_response := response_buttons[response_buttons.size() - 1]
			var last_column := (response_buttons.size() - 1) % focus_columns
			var expected_tail := tail_buttons[mini(last_column, tail_buttons.size() - 1)]
			var last_row_start := int((response_buttons.size() - 1) / focus_columns) * focus_columns
			var expected_tail_top := response_buttons[mini(response_buttons.size() - 1, last_row_start + mini(last_column, tail_buttons.size() - 1))]
			check(last_response.focus_neighbor_bottom == expected_tail.get_path() and expected_tail.focus_neighbor_top == expected_tail_top.get_path(), "pending claim secondary lane is reachable from the final response row at %s" % viewport_size)
	for text in removed_long_labels:
		check(first_button_with_text(scene.action_bar, text) == null, "pending claim action bar omits long label %s at %s" % [text, viewport_size])
	var summary = scene.find_child("PendingClaimIllustration", true, false) as Control
	var urgency_text = scene.find_child("PendingClaimUrgencyText", true, false) as Label
	var dock = scene.find_child("ActionButtonDock", true, false) as Control
	var dock_shadow = scene.find_child("ActionDock3DCastShadow", true, false) as Control
	var dock_apron = scene.find_child("ActionDock3DFrontApron", true, false) as Control
	var hand = scene.find_child("HandTray", true, false) as Control
	var context_tile = scene.find_child("PendingClaimTile", true, false) as Control
	var source_text = scene.find_child("PendingClaimSourceText", true, false) as Label
	var tile_name = scene.find_child("PendingClaimTileName", true, false) as Label
	check(summary != null and dock != null and dock_shadow != null and dock_apron != null and hand != null, "pending claim renders summary, physical dock shell, and hand tray at %s" % viewport_size)
	check(context_tile != null and source_text != null and tile_name != null and urgency_text != null, "pending claim exposes readable source, urgency, and real target tile context at %s" % viewport_size)
	if urgency_text != null:
		check(urgency_text.text.contains("紧迫度") and urgency_text.clip_text, "pending claim urgency stays visible and clipped inside its context strip at %s" % viewport_size)
	check(scene.find_child("ActionDock3DRearShell", true, false) != null and scene.find_child("ActionDock3DJadeTrack", true, false) != null, "action dock exposes rear shell and jade track at %s" % viewport_size)
	var seat_shell = scene.find_child("SeatPanel3DRearShell_0", true, false)
	var seat_lip = scene.find_child("SeatPanel3DJadeLip_0", true, false)
	check(seat_shell != null and seat_lip != null and scene.find_child("SeatPanel3DRightBevel_0", true, false) != null and scene.find_child("SeatPanel3DJadeWash_0", true, false) != null, "seat HUD exposes commercial rear shell, jade lip, right bevel, and jade wash at %s" % viewport_size)
	check(scene.find_child("TopHud3DRearShell", true, false) == null and scene.find_child("TopHud3DTopRim", true, false) != null and scene.find_child("TopHud3DJadeRail", true, false) != null, "top HUD keeps one primary surface without a duplicate rear shell at %s" % viewport_size)
	var top_hud_banner = scene.find_child("TopHudGPTBannerTexture", true, false) as TextureRect
	if top_hud_banner != null:
		check(top_hud_banner.modulate.a <= 0.40, "top HUD banner stays subdued behind status text at %s" % viewport_size)
	check(scene.optional_gpt_illustration_texture("pending_claim_action_dock") == null or scene.find_child("PendingClaimActionGPTDockTexture", true, false) != null, "pending claim consumes GPT action dock at %s" % viewport_size)
	check(scene.optional_gpt_illustration_texture("pending_claim_status_strip") == null or scene.find_child("PendingClaimStatusStripTexture", true, false) != null, "pending claim consumes GPT status strip at %s" % viewport_size)
	if summary != null and dock != null and hand != null:
		var summary_rect = screen_rect(summary)
		var dock_rect = screen_rect(dock)
		var hand_rect = screen_rect(hand)
		for zone in scene.DISCARD_ZONES:
			var discard_grid = scene.find_child("DiscardGrid_%d" % int(zone[0]), true, false) as Control
			if discard_grid != null:
				check(not rects_overlap(summary_rect, screen_rect(discard_grid)), "pending claim context does not occlude river %d at %s" % [int(zone[0]), viewport_size])
		for meld_layout in scene.MELD_LAYOUTS:
			var meld_area = scene.find_child("MeldArea_%d" % int(meld_layout[0]), true, false) as Control
			if meld_area != null:
				check(not rects_overlap(summary_rect, screen_rect(meld_area)), "pending claim summary clears meld area %d at %s" % [int(meld_layout[0]), viewport_size])
		check(summary_rect.size.y >= 44.0, "pending claim summary keeps at least 44px decision context height at %s" % viewport_size)
		check(summary_rect.end.y <= dock_rect.position.y - 5.0, "pending claim summary clears action dock at %s" % viewport_size)
		var horizontal_gap = maxf(0.0, maxf(dock_rect.position.x - summary_rect.end.x, summary_rect.position.x - dock_rect.end.x))
		var reference_button = first_button_with_text(scene.action_bar, "过")
		var reference_width = screen_rect(reference_button).size.x if reference_button != null else scene.ACTION_BUTTON_MAX_WIDTH
		check(horizontal_gap <= reference_width + 1.0, "pending claim summary stays within one action-button width of the dock at %s" % viewport_size)
		check(dock.clip_contents, "pending claim action dock clips decorative artwork at %s" % viewport_size)
		check(dock_rect.end.y <= hand_rect.position.y - 10.0, "pending claim action dock keeps a clear channel above hand tray at %s" % viewport_size)
		if pending_last_button_bottom >= 0.0:
			var dock_bottom_padding = dock_rect.end.y - pending_last_button_bottom
			check(dock_bottom_padding >= 10.0 and dock_bottom_padding <= 24.0, "pending claim action dock keeps compact bottom padding at %s (padding=%.1f dock_bottom=%.1f last_button=%.1f)" % [viewport_size, dock_bottom_padding, dock_rect.end.y, pending_last_button_bottom])
		var dock_texture = scene.find_child("PendingClaimActionGPTDockTexture", true, false) as TextureRect
		if dock_texture != null:
			var dock_texture_rect = screen_rect(dock_texture)
			check(dock_rect.grow(1.0).encloses(dock_texture_rect), "pending claim GPT dock texture stays inside action dock at %s" % viewport_size)
			check(not rects_overlap(summary_rect.grow(-1.0), dock_texture_rect.grow(-1.0)), "pending claim GPT dock texture clears summary strip at %s" % viewport_size)
			check(dock_texture_rect.end.y <= hand_rect.position.y - 10.0, "pending claim GPT dock texture clears hand tray at %s" % viewport_size)
		check(summary.clip_contents, "pending claim context clips decorative artwork to its decision lane at %s" % viewport_size)
		var pending_decorations: Array[Control] = []
		collect_controls_with_name_prefix(summary, "PendingClaim", pending_decorations)
		for decoration in pending_decorations:
			if decoration == summary or decoration is Label:
				continue
			check(summary_rect.grow(1.0).encloses(screen_rect(decoration)), "pending claim decorative child %s stays inside the context lane at %s" % [decoration.name, viewport_size])
	if context_tile != null:
		var context_tile_rect = screen_rect(context_tile)
		check(context_tile_rect.size.x >= 32.0 and context_tile_rect.size.y >= 44.0, "pending claim target tile keeps a readable 32x44 preview at %s" % viewport_size)
		check(context_tile.tooltip_text.contains("点击下方按钮"), "pending claim target tile explains the response route at %s" % viewport_size)
	if source_text != null and tile_name != null:
		check(source_text.get_theme_font_size("font_size") >= 13 and tile_name.get_theme_font_size("font_size") >= 13, "pending claim source and tile labels keep 13px+ text at %s" % viewport_size)
		check(source_text.clip_text and tile_name.clip_text, "pending claim source and tile labels clip safely at %s" % viewport_size)
		check(source_text.tooltip_text.contains("正在等待"), "pending claim source label exposes the complete response context at %s" % viewport_size)
	var pending_dock_texture = scene.find_child("PendingClaimActionGPTDockTexture", true, false) as TextureRect
	if pending_dock_texture != null:
		check(pending_dock_texture.modulate.a <= 0.40, "pending claim GPT action dock stays subdued behind individual actions at %s" % viewport_size)
	var first_button = first_button_with_text(scene.action_bar, "吃3-5")
	if first_button != null:
		check(first_button.find_child("ActionButton3DDepthEdge", true, false) != null and first_button.find_child("ActionButton3DTopRim", true, false) != null, "pending claim buttons expose physical depth and a light-catching top rim at %s" % viewport_size)
		var panel_plate = first_button.find_child("ActionButtonPanelPlate", true, false) as TextureRect
		if panel_plate != null:
			check(panel_plate.modulate.a >= 0.50 and panel_plate.modulate.a <= 0.70 and panel_plate.show_behind_parent, "pending claim compact GPT panel provides a dark text backing behind the native label at %s" % viewport_size)
		check(scene.find_child("ActionIntentDock", true, false) == null, "pending claim omits extra action intent strip at %s" % viewport_size)
	var primary_claim = scene.find_child("PendingClaimPrimaryButton", true, false) as Button
	check(primary_claim != null and primary_claim.has_focus(), "pending claim gives keyboard focus to the first legal response at %s" % viewport_size)
	var compact_pending_grid := scene.find_child("PendingClaimResponseGrid", true, false) as GridContainer
	for response_button in compact_pending_grid.get_children() if compact_pending_grid != null else []:
		if response_button is Button:
			var response_rect := screen_rect(response_button as Button)
			var required_response_width: float = float(scene.PENDING_CLAIM_BUTTON_MIN_WIDTH if viewport_size.y <= 560.0 and scene.mode == "offline" else scene.ACTION_BUTTON_MIN_TOUCH_WIDTH)
			check(response_rect.size.x >= required_response_width - 0.5 and response_rect.size.y >= 44.0, "pending claim response keeps a readable touch target at %s" % viewport_size)

func check_online_pending_claim_layout(scene, viewport_size: Vector2) -> void:
	var pending = scene.pending_claim_state()
	check(scene.mode == "online_game" and not pending.is_empty(), "online pending fixture exposes a real response window at %s" % viewport_size)
	check(scene.action_bar is VBoxContainer, "online pending actions use a stacked response and secondary action lane at %s" % viewport_size)
	var pending_grid := scene.find_child("PendingClaimResponseGrid", true, false) as GridContainer
	var action_count: int = scene.action_bar_button_count()
	check(pending_grid != null, "online pending actions expose their response grid at %s" % viewport_size)
	if pending_grid != null:
		var response_count: int = scene.pending_claim_response_count(action_count)
		check(pending_grid.columns == scene.pending_claim_action_columns(action_count), "online pending response columns match the layout contract at %s" % viewport_size)
		check(pending_grid.get_child_count() == response_count and int(ceil(float(response_count) / float(maxi(1, pending_grid.columns)))) + scene.pending_claim_action_tail_count() == scene.pending_claim_action_row_count(action_count), "online pending response and tail rows match the stack contract at %s" % viewport_size)
	var voice = scene.find_child("VoiceActionButton", true, false) as Button
	check(voice != null, "online pending keeps the voice action available during response at %s" % viewport_size)
	if voice != null:
		var voice_rect = screen_rect(voice)
		check(voice_rect.size.x >= scene.ACTION_BUTTON_MIN_TOUCH_WIDTH - 0.5 and voice_rect.size.y >= 44.0, "online voice action keeps a full touch target during response at %s" % viewport_size)
	var source_text = scene.find_child("PendingClaimSourceText", true, false) as Label
	var tile_name = scene.find_child("PendingClaimTileName", true, false) as Label
	var focus_text = scene.find_child("PendingClaimFocusText", true, false) as Label
	var urgency_text = scene.find_child("PendingClaimUrgencyText", true, false) as Label
	var mode_badge = scene.find_child("TopHudModeBadge", true, false) as Control
	var wall_text = scene.find_child("TopHudWallText", true, false) as Label
	var mode_label: Label = null
	if mode_badge != null:
		for badge_child in mode_badge.get_children():
			if badge_child is Label:
				mode_label = badge_child as Label
				break
	check(source_text != null and source_text.text == "北海若 打出", "online pending context names the discard source at %s" % viewport_size)
	check(tile_name != null and tile_name.text == scene.tile_label("3W"), "online pending context shows the server tile at %s" % viewport_size)
	check(focus_text != null and focus_text.text.contains("胡牌机会"), "online pending context explains the response priority at %s" % viewport_size)
	check(focus_text != null and focus_text.text.contains("H胡") and focus_text.text.contains("X过"), "online pending context exposes response keyboard shortcuts at %s" % viewport_size)
	check(urgency_text != null and urgency_text.text.contains("紧迫度高") and urgency_text.clip_text, "online pending context exposes a visible urgency cue at %s" % viewport_size)
	check(mode_badge != null and mode_label != null and mode_label.text == "联机 · 四川" and mode_badge.tooltip_text.contains("108张"), "online HUD displays the server rule profile instead of the local setting at %s" % viewport_size)
	check(wall_text != null and wall_text.text.contains("55/108") and wall_text.tooltip_text.contains("55/108"), "online HUD scales the wall meter and tooltip to the server total at %s" % viewport_size)
	var live_status = scene.find_child("TopHudStatus", true, false) as Label
	var status_before: String = live_status.text if live_status != null else ""
	scene.set_status("即时反馈：联机操作已送达")
	check(live_status != null and live_status.text == "即时反馈：联机操作已送达", "online gameplay feedback updates the visible top HUD status immediately at %s" % viewport_size)
	if status_before != "":
		scene.set_status(status_before)
	var action_dock = scene.find_child("ActionButtonDock", true, false) as Control
	var summary = scene.find_child("PendingClaimIllustration", true, false) as Control
	check(action_dock != null and summary != null, "online pending mounts context and action dock together at %s" % viewport_size)
	if action_dock != null and summary != null:
		check(screen_rect(summary).end.y <= screen_rect(action_dock).position.y - 5.0, "online pending context clears the action dock at %s" % viewport_size)
	var waiting_state_before: bool = bool(scene.online_waiting_for_server)
	var waiting_feedback_before: String = str(scene.online_feedback)
	scene.online_waiting_for_server = true
	scene.online_feedback = ""
	scene.render_game()
	await settle_layout()


	var waiting_status = scene.find_child("TopHudStatus", true, false) as Label
	var waiting_action = scene.find_child("ActionDockWaitingStatus", true, false) as Label
	check(scene.current_status_text() == "操作已提交 · 等待服务器确认" and waiting_status != null and waiting_status.text == scene.current_status_text(), "online submitted state is explicit in the top HUD at %s" % viewport_size)
	check(waiting_action != null and waiting_action.text.contains("等待服务器"), "online submitted state is explicit in the action dock at %s" % viewport_size)
	var online_chat_button := scene.find_child("ChatActionButton", true, false) as Button
	var online_response_buttons: Array[Button] = []
	if pending_grid != null:
		collect_buttons(pending_grid, online_response_buttons)
	var waiting_voice := scene.find_child("VoiceActionButton", true, false) as Button
	var online_first_action: Button = waiting_voice if scene.online_waiting_for_server else (online_response_buttons[0] if not online_response_buttons.is_empty() else waiting_voice)
	check(online_chat_button != null and online_first_action != null and online_chat_button.focus_neighbor_right == online_first_action.get_path(), "online chat is reachable from the response action lane via directional focus at %s" % viewport_size)
	scene.online_waiting_for_server = waiting_state_before
	scene.online_feedback = waiting_feedback_before
	scene.render_game()
	await settle_layout()


func check_accessibility_profile_cycle(scene, viewport_size: Vector2) -> void:
	var saved_large := bool(scene.large_text_enabled)
	var saved_contrast := bool(scene.high_contrast_enabled)
	var saved_motion := bool(scene.reduce_motion_enabled)
	scene.large_text_enabled = false
	scene.high_contrast_enabled = false
	scene.reduce_motion_enabled = false
	scene.settings_focus_restore_name = ""
	scene.refresh_current_screen()
	await settle_layout()
	var expected_profiles := ["标准", "大字", "高对比", "减动效", "专注", "清晰"]
	for index in range(expected_profiles.size()):
		var button := scene.find_child("SettingRowButton_阅读辅助", true, false) as Button
		var expected := str(expected_profiles[index])
		check(button != null and button.text == expected, "accessibility profile reaches %s at %s" % [expected, viewport_size])
		if button == null:
			continue
		if index > 0:
			check(button.has_focus(), "accessibility profile restores focus after selecting %s at %s" % [expected, viewport_size])
		if expected == "大字":
			for title in ["AI 难度", "阅读辅助", "3D 画质"]:
				var large_button := scene.find_child("SettingRowButton_%s" % title, true, false) as Button
				check(large_button != null and large_button.get_theme_font_size("font_size") >= 17 and screen_rect(large_button).size.y >= 46.0, "large-text setting button %s scales with the profile at %s" % [title, viewport_size])
		button.button_down.emit()
		await settle_layout()
	var final_button := scene.find_child("SettingRowButton_阅读辅助", true, false) as Button
	check(final_button != null and final_button.text == "标准" and final_button.has_focus(), "accessibility profile wraps to standard while preserving focus at %s" % viewport_size)
	scene.large_text_enabled = saved_large
	scene.high_contrast_enabled = saved_contrast
	scene.reduce_motion_enabled = saved_motion
	scene.save_settings()
	scene.settings_focus_restore_name = ""
	scene.refresh_current_screen()
	await settle_layout()

func check_chat_panel_layout(scene, viewport_size: Vector2) -> void:
	scene.show_chat_panel()
	await settle_layout(0.04)
	var panel = scene.find_child("ChatPanel", true, false) as Control
	var input = scene.find_child("ChatInput", true, false) as LineEdit
	var close_button = scene.find_child("ChatPanelCloseButton", true, false) as Button
	var send_button = scene.find_child("ChatSendButton", true, false) as Button
	check(panel != null and input != null and close_button != null and send_button != null, "online chat exposes drawer, input, close, and send controls at %s" % viewport_size)
	if panel != null:
		var panel_rect = screen_rect(panel)
		var route := str(panel.get_meta("layout_role", ""))
		check(route == scene.chat_panel_route_name(), "online game chat exposes the state-specific drawer route at %s" % viewport_size)
		check(Rect2(Vector2.ZERO, viewport_size).grow(-2.0).encloses(panel_rect), "online game chat drawer stays inside viewport at %s" % viewport_size)
		if route == "top_safe_drawer":
			check(panel_rect.position.x >= viewport_size.x * 0.70, "online game chat default route stays in the upper-right safe lane at %s" % viewport_size)
		else:
			check(panel_rect.end.x <= viewport_size.x * 0.30, "online game chat meld route stays in the upper-left gutter at %s" % viewport_size)
		check(panel_rect.size.x >= 180.0 and panel_rect.end.y <= viewport_size.y * 0.33, "online game chat drawer keeps a wide compact touch lane at %s" % viewport_size)
		check(panel.get_meta("compact_chat", false), "online game chat marks the narrow route as compact at %s" % viewport_size)
		for seat in range(4):
			var seat_panel = scene.find_child("SeatPanel_%d" % seat, true, false) as Control
			var meld_area = scene.find_child("MeldArea_%d" % seat, true, false) as Control
			var discard_grid = scene.find_child("DiscardGrid_%d" % seat, true, false) as Control
			if seat_panel != null:
				check(not rects_overlap(panel_rect, screen_rect(seat_panel)), "online chat clears seat HUD %d at %s" % [seat, viewport_size])
			if meld_area != null:
				check(not rects_overlap(panel_rect, screen_rect(meld_area)), "online chat clears meld lane %d at %s" % [seat, viewport_size])
			if discard_grid != null:
				check(not rects_overlap(panel_rect, screen_rect(discard_grid)), "online chat clears discard river %d at %s" % [seat, viewport_size])
	if input != null and panel != null:
		check(screen_rect(panel).grow(1.0).encloses(screen_rect(input)) and input.max_length == scene.CHAT_MESSAGE_MAX_LENGTH, "online chat input stays inside the drawer and preserves its length boundary at %s" % viewport_size)
	if close_button != null and send_button != null and panel != null:
		check(close_button.tooltip_text.contains("关闭") and send_button.tooltip_text.contains("Enter"), "online chat close/send controls expose complete action hints at %s" % viewport_size)
		check(screen_rect(panel).grow(1.0).encloses(screen_rect(close_button)), "online chat close action stays inside the drawer at %s" % viewport_size)
		check(screen_rect(send_button).size.x >= 42.0 and screen_rect(send_button).size.y >= 36.0, "online chat send action keeps a 42x36 touch target at %s" % viewport_size)
		check(screen_rect(panel).grow(1.0).encloses(screen_rect(send_button)), "online chat send action stays inside the drawer at %s" % viewport_size)
	var quick_row := scene.find_child("ChatPanelQuickMessages", true, false) as Control
	var quick_buttons: Array[Button] = []
	if quick_row != null:
		collect_buttons(quick_row, quick_buttons)
	check(quick_row != null and quick_buttons.size() == scene.CHAT_QUICK_MESSAGES.size(), "online chat keeps every quick-message action in its compact lane at %s" % viewport_size)
	if panel != null:
		for quick_button in quick_buttons:
			var quick_rect := screen_rect(quick_button)
			check(screen_rect(panel).grow(1.0).encloses(quick_rect) and quick_rect.size.x >= 46.0 and quick_rect.size.y >= 26.0, "online chat quick action %s stays readable and touchable at %s" % [quick_button.text, viewport_size])
	check(input != null and input.has_focus(), "online chat opens with focus in the message input at %s" % viewport_size)
	scene.close_chat_panel()
	await settle_layout()
	check(scene.find_child("ChatPanel", true, false) == null and not scene.chat_panel_open, "online chat closes cleanly and clears its open state at %s" % viewport_size)
	await check_chat_panel_meld_route(scene, viewport_size, 2, "top_meld_safe_drawer")
	await check_chat_panel_meld_route(scene, viewport_size, 1, "right_meld_safe_drawer")


func check_chat_panel_meld_route(scene, viewport_size: Vector2, seat: int, expected_route: String) -> void:
	var online_players: Array = scene.online_game.get("players", [])
	var target_player: Dictionary = {}
	for player_value in online_players:
		var player: Dictionary = player_value
		if int(player.get("seat", -1)) == seat:
			target_player = player
			break
	if target_player.is_empty():
		check(false, "chat route fixture finds seat %d player at %s" % [seat, viewport_size])
		return
	var saved_melds: Array = target_player.get("melds", []).duplicate(true)
	target_player["melds"] = [["1W", "1W", "1W"]]
	scene.render_game()
	await settle_layout()
	scene.show_chat_panel()
	await settle_layout(0.04)
	var panel := scene.find_child("ChatPanel", true, false) as Control
	check(panel != null and str(panel.get_meta("layout_role", "")) == expected_route, "online chat routes seat %d meld state to a named safe lane at %s" % [seat, viewport_size])
	if panel != null:
		var panel_rect := screen_rect(panel)
		check(panel_rect.end.x <= viewport_size.x * 0.30 and panel_rect.size.x >= 180.0, "online chat seat %d meld route keeps a wide upper-left gutter at %s" % [seat, viewport_size])
		for other_seat in range(4):
			var meld_area = scene.find_child("MeldArea_%d" % other_seat, true, false) as Control
			var discard_grid = scene.find_child("DiscardGrid_%d" % other_seat, true, false) as Control
			if meld_area != null:
				check(not rects_overlap(panel_rect.grow(-1.0), screen_rect(meld_area)), "online chat seat %d route clears meld lane %d at %s" % [seat, other_seat, viewport_size])
			if discard_grid != null:
				check(not rects_overlap(panel_rect.grow(-1.0), screen_rect(discard_grid)), "online chat seat %d route clears river %d at %s" % [seat, other_seat, viewport_size])
	scene.close_chat_panel()
	await settle_layout()
	target_player["melds"] = saved_melds
	scene.render_game()
	await settle_layout()

func check_table_log_archive_layout(scene, viewport_size: Vector2) -> void:
	var saved_logs: Array = scene.table_logs.duplicate()
	while scene.table_logs.size() < 4:
		scene.table_logs.append("第%02d巡：牌桌状态已同步" % (scene.table_logs.size() + 1))
	scene.render_game()
	await settle_layout()
	var archive_button = scene.find_child("TableLogArchiveButton", true, false) as Button
	check(archive_button != null and archive_button.text == "历史" and archive_button.tooltip_text.contains("完整"), "table log keeps an explicit history action in the compact ledger at %s" % viewport_size)
	scene.toggle_table_log_archive()
	await settle_layout(0.04)
	var panel = scene.find_child("TableLogArchivePanel", true, false) as Control
	var scroll = scene.find_child("TableLogArchiveScroll", true, false) as ScrollContainer
	var list = scene.find_child("TableLogArchiveList", true, false) as VBoxContainer
	var close_button = scene.find_child("TableLogArchiveCloseButton", true, false) as Button
	var title = scene.find_child("TableLogArchiveTitle", true, false) as Label
	check(panel != null and scroll != null and list != null and close_button != null and title != null, "table log archive exposes a dedicated scroll panel and close route at %s" % viewport_size)
	if panel != null:
		var panel_rect = screen_rect(panel)
		check(Rect2(Vector2.ZERO, viewport_size).grow(-2.0).encloses(panel_rect), "table log archive stays inside viewport at %s" % viewport_size)
		var dock = scene.find_child("ActionButtonDock", true, false) as Control
		var hand = scene.find_child("HandTray", true, false) as Control
		check((dock == null or not rects_overlap(panel_rect, screen_rect(dock))) and (hand == null or not rects_overlap(panel_rect, screen_rect(hand))), "table log archive clears action dock and hand tray at %s" % viewport_size)
	if list != null:
		var rows = controls_with_name_prefix(list, "TableLogArchiveRow_")
		check(rows.size() >= 3, "table log archive exposes at least three recent records at %s" % viewport_size)
		for row in rows:
			var row_label := row as Label
			check(row_label != null and not row_label.clip_text and row_label.tooltip_text != "", "table log archive keeps full row text available in the scroll surface at %s" % viewport_size)
	if scroll != null:
		check(scroll.horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED and scroll.vertical_scroll_mode == ScrollContainer.SCROLL_MODE_AUTO, "table log archive uses native vertical touch scrolling at %s" % viewport_size)
	check(close_button == null or close_button.has_focus(), "table log archive returns focus to its close route at %s" % viewport_size)
	scene.close_table_log_archive()
	await settle_layout()
	scene.table_logs.clear()
	for log_item in saved_logs:
		scene.table_logs.append(str(log_item))
	scene.render_game()
	await settle_layout()


func check_advisor_interaction_layout(scene, viewport_size: Vector2) -> void:
	var panel = scene.find_child("AdvisorPanel", true, false) as Control
	var dock = scene.find_child("ActionButtonDock", true, false) as Control
	var hand = scene.find_child("HandTray", true, false) as Control
	if scene.offline_phase == "pending_claim":
		var pending_context = scene.find_child("PendingClaimIllustration", true, false) as Control
		var pending_source = scene.find_child("PendingClaimSourceText", true, false) as Label
		var pending_focus = scene.find_child("PendingClaimFocusText", true, false) as Label
		check(panel == null, "pending claim hides the general AI advisor to preserve one response focus lane at %s" % viewport_size)
		check(pending_context != null and pending_source != null and pending_focus != null, "pending claim keeps its dedicated response context when advisor is hidden at %s" % viewport_size)
		check(pending_source.text.contains("打出") and pending_focus.text.contains("H胡") and pending_focus.text.contains("X过"), "pending claim context preserves the source and keyboard response route at %s" % viewport_size)
		if pending_context != null and dock != null:
			check(screen_rect(pending_context).end.y <= screen_rect(dock).position.y - 5.0, "pending claim context clears the action dock after advisor collapse at %s" % viewport_size)
		return
	check(panel != null and dock != null and hand != null, "AI advisor exposes panel, action dock, and hand context at %s" % viewport_size)
	if panel == null:
		return
	var panel_rect = screen_rect(panel)
	check(Rect2(Vector2.ZERO, viewport_size).grow(-2.0).encloses(panel_rect), "AI advisor panel stays inside viewport at %s" % viewport_size)
	if dock != null:
		check(not rects_overlap(panel_rect, screen_rect(dock)), "AI advisor panel clears the action dock at %s" % viewport_size)
	if hand != null:
		check(not rects_overlap(panel_rect, screen_rect(hand)), "AI advisor panel clears the hand tray at %s" % viewport_size)
	for heading in ["响应", "牌局", "防守"]:
		var card = panel.find_child("AdvisorInfoCard_%s" % heading, true, false) as Control
		check(card != null and panel_rect.grow(1.0).encloses(screen_rect(card)), "AI advisor %s card stays inside the panel at %s" % [heading, viewport_size])
	var detail_button = scene.find_child("AdvisorDetailButton", true, false) as Button
	check(detail_button != null and detail_button.text == "详解" and detail_button.tooltip_text.contains("展开"), "AI advisor exposes an explicit detail action at %s" % viewport_size)
	var recommended_count := 0
	for child in scene.action_bar_buttons():
		if str(child.text).contains("荐"):
			recommended_count += 1
	check(recommended_count > 0, "AI advisor exposes a recommended claim action at %s" % viewport_size)

func check_advisor_detail_layout(scene, viewport_size: Vector2) -> void:
	var detail_button = scene.find_child("AdvisorDetailButton", true, false) as Button
	if detail_button == null:
		check(scene.offline_phase == "pending_claim" and scene.find_child("PendingClaimIllustration", true, false) != null, "pending claim keeps detail focus in its single response context at %s" % viewport_size)
		return
	detail_button.button_down.emit()
	await settle_layout(0.04)
	var panel = scene.find_child("AdvisorDetailPanel", true, false) as Control
	var text = scene.find_child("AdvisorDetailText", true, false) as Label
	var close_button = scene.find_child("AdvisorDetailCloseButton", true, false) as Button
	check(panel != null and text != null and close_button != null, "AI advisor opens a dedicated detail panel at %s" % viewport_size)
	if panel != null:
		var panel_rect = screen_rect(panel)
		check(panel_rect.size.x >= viewport_size.x * 0.55, "AI advisor detail panel provides a wide reading lane at %s" % viewport_size)
		check(Rect2(Vector2.ZERO, viewport_size).grow(-2.0).encloses(panel_rect), "AI advisor detail panel stays inside viewport at %s" % viewport_size)
		var dock = scene.find_child("ActionButtonDock", true, false) as Control
		var hand = scene.find_child("HandTray", true, false) as Control
		check((dock == null or not rects_overlap(panel_rect, screen_rect(dock))) and (hand == null or not rects_overlap(panel_rect, screen_rect(hand))), "AI advisor detail clears action dock and hand tray at %s" % viewport_size)
	if text != null:
		check(text.text.contains("响应目标") and text.clip_text and text.tooltip_text == text.text and screen_rect(text).size.x >= viewport_size.x * 0.40, "AI advisor detail exposes readable in-panel rationale instead of tooltip-only copy at %s" % viewport_size)
	check(close_button == null or close_button.has_focus(), "AI advisor detail gives focus to its close route at %s" % viewport_size)
	if close_button != null:
		close_button.button_down.emit()
	await settle_layout()
	check(scene.find_child("AdvisorDetailPanel", true, false) == null and not scene.advisor_detail_open, "AI advisor detail closes cleanly at %s" % viewport_size)

func check_danger_discard_layout(scene, viewport_size: Vector2) -> void:
	var panel = scene.find_child("DangerDiscardConfirmationArt", true, false) as Control
	var tile = scene.find_child("DangerDiscardTile", true, false) as Control
	var title = scene.find_child("DangerDiscardTitleText", true, false) as Label
	var detail = scene.find_child("DangerDiscardDetailText", true, false) as Label
	var risk_seal = scene.find_child("DangerDiscardRiskSeal", true, false) as Control
	var dock = scene.find_child("ActionButtonDock", true, false) as Control
	var confirm_button = scene.find_child("DangerDiscardConfirmButton", true, false) as Button
	var cancel_button = first_button_with_text(scene.action_bar, "取消")
	check(panel != null and tile != null and title != null and detail != null and risk_seal != null and dock != null and confirm_button != null and cancel_button != null, "danger discard exposes warning context, target tile, explicit confirm/cancel actions, and dock at %s" % viewport_size)
	var compact_danger_text = scene.pending_danger_discard_text()
	var compact_alternatives = scene.safe_discard_alternative_text(scene.pending_danger_discard_tile)
	check(not compact_danger_text.contains("..."), "danger discard compact status avoids ellipsis at %s" % viewport_size)
	check(compact_danger_text.contains(scene.tile_label(scene.pending_danger_discard_tile)) and compact_danger_text.contains("高危"), "danger discard compact status keeps target and risk at %s" % viewport_size)
	if compact_alternatives != "":
		check(compact_danger_text.contains("可改打"), "danger discard compact status keeps alternative action at %s" % viewport_size)
	var hud_danger_text = scene.top_hud_status_text()
	check(hud_danger_text.contains("风险确认") and hud_danger_text.contains(scene.tile_label(scene.pending_danger_discard_tile)) and hud_danger_text != compact_danger_text, "danger discard top HUD uses a distinct complete event summary at %s" % viewport_size)
	if panel == null:
		return
	var panel_rect = screen_rect(panel)
	check(panel.mouse_filter == Control.MOUSE_FILTER_STOP and panel.clip_contents and bool(panel.get_meta("modal_input_shield", false)), "danger discard warning is a clipped modal input surface at %s" % viewport_size)
	check(confirm_button != null and confirm_button.has_focus(), "danger discard defaults focus to the real confirm action at %s" % viewport_size)
	check(Rect2(Vector2.ZERO, viewport_size).grow(-2.0).encloses(panel_rect), "danger discard warning stays inside the viewport safe bounds at %s" % viewport_size)
	check(panel_rect.size.y >= 32.0, "danger discard warning keeps a readable compact height at %s" % viewport_size)
	for seat in range(4):
		var discard_grid = scene.find_child("DiscardGrid_%d" % seat, true, false) as GridContainer
		if discard_grid != null:
			for discard_tile in discard_grid.get_children():
				if discard_tile is Control and (discard_tile as Control).visible:
					check(not rects_overlap(panel_rect, screen_rect(discard_tile as Control)), "danger discard warning clears visible river tile %d/%s at %s" % [seat, discard_tile.name, viewport_size])
		var meld_area = scene.find_child("MeldArea_%d" % seat, true, false) as Control
		if meld_area != null:
			for meld_group in meld_area.get_children():
				if meld_group is Control and str(meld_group.name).begins_with("MeldGroup_"):
					check(not rects_overlap(panel_rect, screen_rect(meld_group as Control)), "danger discard warning clears meld %d/%s at %s" % [seat, meld_group.name, viewport_size])
	if tile != null:
		check(panel_rect.grow(1.0).encloses(screen_rect(tile)), "danger discard target tile stays inside the warning panel at %s" % viewport_size)
		if title != null and detail != null:
			check(title.tooltip_text.contains("高危") and detail.tooltip_text.contains(scene.tile_label(scene.pending_danger_discard_tile)), "danger discard warning exposes its full reason on hover at %s" % viewport_size)
	var pending_hand_tiles := controls_with_name_prefix(scene, "HandTile_")
	var pending_target_count := 0
	for hand_tile in pending_hand_tiles:
		if bool(hand_tile.get_meta("danger_pending", false)):
			pending_target_count += 1
			check(hand_tile.tooltip_text.contains("当前待确认"), "danger discard marks the exact hand target with a full action hint at %s" % viewport_size)
	check(pending_target_count == 1, "danger discard exposes exactly one pending hand target at %s" % viewport_size)
	if title != null and detail != null:
		check(title.clip_text and title.get_theme_font_size("font_size") >= 13, "danger discard title remains clipped and prominent at %s" % viewport_size)
		check(detail.clip_text and detail.get_theme_font_size("font_size") >= 12, "danger discard detail text remains clipped and readable at %s" % viewport_size)
	if confirm_button != null:
		var confirm_rect = screen_rect(confirm_button)
		check(confirm_button.text == "确认打南", "danger discard primary action names the exact tile at %s" % viewport_size)
		check(confirm_rect.size.x >= 72.0 and confirm_rect.size.y >= 40.0, "danger discard confirm action keeps a prominent touch target at %s" % viewport_size)
	if cancel_button != null:
		var cancel_rect = screen_rect(cancel_button)
		check(cancel_rect.size.x >= scene.ACTION_BUTTON_MIN_TOUCH_WIDTH - 0.5 and cancel_rect.size.y >= 40.0, "danger discard cancel action keeps a practical touch target at %s" % viewport_size)
	check(first_button_with_text(scene.action_bar, "重开") == null and first_button_with_text(scene.action_bar, "提示") == null and scene.find_child("VoiceActionButton", true, false) == null, "danger discard dedicated dock hides secondary global actions at %s" % viewport_size)
	if dock != null:
		check(screen_rect(dock).end.y <= viewport_size.y - 44.0, "danger discard action dock leaves room for the hand tray at %s" % viewport_size)
	check(confirm_button != null and confirm_button.focus_mode == Control.FOCUS_ALL and str(confirm_button.focus_neighbor_left) != "", "danger discard confirm action remains in the keyboard focus loop at %s" % viewport_size)

func check_round_summary_layout(scene, viewport_size: Vector2) -> void:
	var panel = scene.find_child("RoundSummaryPanel", true, false) as Control
	var title = scene.find_child("RoundSummaryTitle", true, false) as Label
	var body = scene.find_child("RoundSummaryBody", true, false) as Label
	var top_status = scene.find_child("TopHudStatus", true, false) as Label
	var detail_panel = scene.find_child("WinDetailPanel", true, false) as Control
	var winner_label = scene.find_child("WinDetailWinnerLabel", true, false) as Label
	var score_label = scene.find_child("WinDetailScoreLabel", true, false) as Label
	var win_tile = scene.find_child("WinDetailTile", true, false) as Control
	var rank_header = scene.find_child("RoundSummaryRankHeader", true, false) as Control
	var dock = scene.find_child("ActionButtonDock", true, false) as Control
	var next_button = first_button_with_text(scene.action_bar, "下一局")
	var menu_button = first_button_with_text(scene.action_bar, "菜单")
	var replay_button = scene.find_child("CopyReplayCodeButton", true, false) as Button
	check(panel != null and title != null and body != null and top_status != null and detail_panel != null and winner_label != null and score_label != null and win_tile != null and rank_header != null, "round summary exposes title, score body, compact top status, win detail, winning tile, and rank header at %s" % viewport_size)
	check(next_button != null and menu_button != null, "round summary exposes clear next-hand and menu routes at %s" % viewport_size)
	var expected_replay_label := "回放码" if viewport_size.x < 1100.0 or viewport_size.y <= 560.0 else "复制回放码"
	check(replay_button != null and replay_button.text == expected_replay_label and not replay_button.text.contains("...") and not replay_button.text.contains("…"), "round summary keeps the replay-copy CTA readable at %s" % viewport_size)
	check(replay_button != null and replay_button.tooltip_text.contains("复制本局回放码") and replay_button.tooltip_text.contains("回放"), "round summary exposes the full replay-copy instruction in status feedback at %s" % viewport_size)
	if replay_button != null:
		check(screen_rect(replay_button).size.y >= 44.0, "round summary replay-copy action keeps a usable touch target at %s" % viewport_size)
	check(scene.find_child("ActionIntentDock", true, false) == null, "round summary omits the live action intent strip at %s" % viewport_size)
	if top_status != null:
		check(top_status.text == "本局结算 · 你自摸 8番 16分" and not top_status.text.contains("..."), "round summary top HUD uses a complete short settlement status at %s" % viewport_size)
	var saved_summary_score: Dictionary = scene.last_win_score.duplicate(true)
	var saved_summary_hand_number: int = int(scene.offline_hand_number)
	scene.last_win_score = {"wall_draw": true}
	scene.offline_hand_number = 1
	check(scene.top_hud_status_text() == "本局结算 · 荒庄", "wall draw top HUD uses a short settlement status at %s" % viewport_size)
	scene.offline_hand_number = scene.MATCH_MAX_HANDS
	check(scene.top_hud_status_text() == "全场结束 · 荒庄", "match-complete wall draw top HUD names the terminal settlement at %s" % viewport_size)
	scene.last_win_score = saved_summary_score
	scene.offline_hand_number = saved_summary_hand_number
	if panel == null:
		return
	var panel_rect = screen_rect(panel)
	var panel_texture_path := ""
	if panel is TextureRect and (panel as TextureRect).texture != null:
		var panel_texture = (panel as TextureRect).texture
		var panel_source = (panel_texture as AtlasTexture).atlas if panel_texture is AtlasTexture else panel_texture
		panel_texture_path = str(panel_source.resource_path) if panel_source != null else ""
	check(panel_texture_path.ends_with("/ui_dark_scrim.png") and panel.self_modulate.a >= 0.98, "round summary uses an opaque authored reading scrim at %s" % viewport_size)
	check(Rect2(Vector2.ZERO, viewport_size).grow(-2.0).encloses(panel_rect), "round summary panel stays inside the viewport safe bounds at %s" % viewport_size)
	for node in [title, body, detail_panel, rank_header]:
		if node != null:
			check(panel_rect.grow(1.0).encloses(screen_rect(node)), "round summary keeps %s inside its panel at %s" % [node.name, viewport_size])
	for seat in range(4):
		var rank_row = scene.find_child("RoundSummaryRankRow_%d" % seat, true, false) as Control
		check(rank_row != null, "round summary exposes rank row %d at %s" % [seat, viewport_size])
		if rank_row != null:
			check(panel_rect.grow(1.0).encloses(screen_rect(rank_row)), "round summary rank row %d stays inside the panel at %s" % [seat, viewport_size])
	if title != null:
		check(title.get_theme_font_size("font_size") >= 26 and title.clip_text == false, "round summary title remains prominent at %s" % viewport_size)
	if body != null:
		var minimum_summary_font := 12 if viewport_size.y <= 560.0 else 14
		check(body.clip_text and body.get_theme_font_size("font_size") >= minimum_summary_font and relative_luma(body.get_theme_color("font_color")) >= 0.92, "round summary body remains bright, clipped, and readable at %s" % viewport_size)
		check(body.text.contains("庄家下庄") and body.text.contains("包赔") and body.text.contains("全场结束") and body.tooltip_text.contains(scene.round_summary), "round summary keeps dealer, package-liability, and match-end text visible while exposing the complete source at %s" % viewport_size)
		check(body.autowrap_mode == TextServer.AUTOWRAP_WORD_SMART, "long settlement text uses smart wrapping at %s" % viewport_size)
		check(body.get_line_count() >= 2 and body.get_visible_line_count() >= 2, "long settlement renders both compact information lines at %s" % viewport_size)
	if detail_panel != null:
		var detail_rect = screen_rect(detail_panel)
		check(not rects_overlap(detail_rect, screen_rect(body)), "round summary win detail clears settlement body at %s" % viewport_size)
		if rank_header != null:
			check(not rects_overlap(detail_rect, screen_rect(rank_header)), "round summary win detail clears rank header at %s" % viewport_size)
		for node in [winner_label, score_label, win_tile]:
			if node != null:
				check(detail_rect.grow(1.0).encloses(screen_rect(node)), "win detail keeps %s inside its panel at %s" % [node.name, viewport_size])
		var yaku_badges = scene.find_child("WinDetailYakuBadges", true, false) as Container
		check(yaku_badges != null and yaku_badges.get_child_count() == scene.last_win_score.get("reasons", []).size(), "win detail retains every long-fixture yaku entry at %s" % viewport_size)
		if yaku_badges != null:
			check(detail_rect.grow(1.0).encloses(screen_rect(yaku_badges)), "win detail yaku container stays inside its panel at %s" % viewport_size)
			for badge in yaku_badges.get_children():
				if badge is Control:
					check(detail_rect.grow(1.0).encloses(screen_rect(badge as Control)), "win detail yaku entry %s stays visible inside the panel at %s" % [badge.name, viewport_size])
			var limit_badge = scene.find_child("WinDetailLimitBadge", true, false) as Control
			if limit_badge != null:
				check(not rects_overlap(screen_rect(limit_badge), screen_rect(yaku_badges)), "win detail limit badge clears the yaku lane at %s" % viewport_size)
	for seat in range(4):
		var row = scene.find_child("RoundSummaryRankRow_%d" % seat, true, false) as Control
		if row != null and detail_panel != null:
			check(not rects_overlap(screen_rect(detail_panel), screen_rect(row)), "round summary rank row %d clears win detail at %s" % [seat, viewport_size])
		if row != null and rank_header != null:
			check(not rects_overlap(screen_rect(rank_header), screen_rect(row)), "round summary rank row %d clears rank header at %s" % [seat, viewport_size])
		for other_seat in range(seat):
			var other_row = scene.find_child("RoundSummaryRankRow_%d" % other_seat, true, false) as Control
			if row != null and other_row != null:
				check(not rects_overlap(screen_rect(row), screen_rect(other_row)), "round summary rank rows %d and %d remain mutually exclusive at %s" % [other_seat, seat, viewport_size])
	if winner_label != null and score_label != null:
		check(winner_label.get_theme_font_size("font_size") >= 18 and score_label.get_theme_font_size("font_size") >= 22, "win detail winner and score text remain prominent at %s" % viewport_size)
	if dock != null:
		check(panel_rect.end.y <= screen_rect(dock).position.y - 8.0, "round summary clears the action dock at %s" % viewport_size)
	for button in [next_button, menu_button]:
		if button != null:
			var button_rect = screen_rect(button)
			check(button_rect.size.x >= scene.ACTION_BUTTON_MIN_TOUCH_WIDTH - 0.5 and button_rect.size.y >= 40.0, "round summary action %s keeps a practical touch target at %s" % [button.text, viewport_size])
			check(button.tooltip_text != "", "round summary action %s exposes its next-step consequence at %s" % [button.text, viewport_size])

func check_hand_tray_layout(scene, viewport_size: Vector2) -> void:
	var hand = scene.find_child("HandTray", true, false) as Control
	var stage = scene.find_child("HandTrayTileStage", true, false) as Control
	var ground_shadow = scene.find_child("HandTrayTileGroundShadow", true, false) as Control
	var back_rail = scene.find_child("HandTrayTileBackRail", true, false) as Control
	var baseline = scene.find_child("HandTrayTileBaseline", true, false) as Control
	var hand_tile_samples = controls_with_name_prefix(scene, "HandTile_")
	var hand_tile_sample = hand_tile_samples[0] if not hand_tile_samples.is_empty() else null
	var shortcut_hint = scene.find_child("HandTrayShortcutHint", true, false) as Label
	var realtime_3d_stage = null
	check(hand != null and stage != null and ground_shadow != null and back_rail != null and baseline != null and hand_tile_sample != null, "hand tray exposes tile stage, 2D hand tiles, ground shadow, back rail, and baseline at %s" % viewport_size)
	check(shortcut_hint != null and shortcut_hint.text != "", "hand tray exposes a dedicated keyboard or response shortcut line at %s" % viewport_size)
	if hand == null:
		return
	var hand_rect = screen_rect(hand)
	check(hand.clip_contents, "hand tray clips decorative artwork at %s" % viewport_size)
	check(Rect2(Vector2.ZERO, viewport_size).grow(1.0).encloses(hand_rect), "hand tray stays inside viewport at %s" % viewport_size)
	check(hand_rect.end.y <= viewport_size.y - max(8.0, viewport_size.y * 0.015), "hand tray leaves a visible bottom margin at %s" % viewport_size)
	if stage != null:
		check(hand_rect.grow(1.0).encloses(screen_rect(stage)), "hand tile stage stays inside hand tray at %s" % viewport_size)
	if hand_tile_sample != null:
		check(hand_rect.grow(2.0).encloses(screen_rect(hand_tile_sample)), "2D hand tile stays inside hand tray at %s" % viewport_size)
	var battle_commercial = scene.find_child("OfflineCommercial3DStage", true, false) as CanvasItem
	check(battle_commercial == null, "offline battle does not mount an executable 3D tile stage at %s" % viewport_size)
	var visible_walls := 0
	var wall_total := 0
	var table_surface = scene.find_child("OfflineTable3DInnerSurface", true, false) as Node
	var wall_search_root: Node = table_surface if table_surface != null else scene
	for wall_node in wall_search_root.get_children():
		if not str(wall_node.name).begins_with("WallBackStrip"):
			continue
		wall_total += 1
		var canvas_wall := wall_node as CanvasItem
		if canvas_wall != null and canvas_wall.visible and canvas_wall.modulate.a > 0.01:
			visible_walls += 1
	check(wall_total == scene.WALL_LAYOUTS.size() and visible_walls == scene.WALL_LAYOUTS.size(), "offline battle keeps all wall strips as visible 2D assets at %s" % viewport_size)
	var tiles = controls_with_name_prefix(scene, "HandTile_")
	check(tiles.size() == scene.get_self_hand().size(), "hand tray exposes one named hand tile per self tile at %s" % viewport_size)
	for tile in tiles:
		var tile_rect = screen_rect(tile)
		check(hand_rect.grow(1.0).encloses(tile_rect), "hand tile %s stays inside hand tray at %s" % [tile.name, viewport_size])
		check(tile_rect.end.y <= hand_rect.end.y - 2.0, "hand tile %s clears the tray bottom lip at %s" % [tile.name, viewport_size])
		check(tile_rect.size.y <= hand_rect.size.y * 0.84 + 1.0, "hand tile %s remains visually grounded instead of filling the tray at %s" % [tile.name, viewport_size])
		check(not bool(tile.get_meta("is_3d_hit_proxy", false)), "hand tile %s is a visible 2D tile (not a transparent 3D hit proxy) at %s" % [tile.name, viewport_size])

func check_battle_viewport_bounds(scene, viewport_size: Vector2) -> void:
	var viewport_rect = Rect2(Vector2.ZERO, viewport_size).grow(1.0)
	var hand = scene.find_child("HandTray", true, false) as Control
	var dock = scene.find_child("ActionButtonDock", true, false) as Control
	check(hand != null and dock != null, "battle screen exposes hand tray and action dock at %s" % viewport_size)
	var hand_rect = screen_rect(hand) if hand != null else Rect2()
	var dock_rect = screen_rect(dock) if dock != null else Rect2()
	if hand != null and dock != null:
		check(dock_rect.end.y <= hand_rect.position.y - 12.0, "battle action dock keeps a clear gap above hand tray at %s" % viewport_size)
		var dock_height_limit := viewport_size.y * (0.24 if scene.has_pending_claim_window() else 0.115) + 1.0
		check(dock_rect.size.y <= dock_height_limit, "battle action dock remains within its one/two-row height budget at %s" % viewport_size)
	var discard_rects = battle_discard_zone_screen_rects(scene)
	var root_rect = screen_rect(scene.root_layer)
	var outer_rect = anchor_rect_in_parent(root_rect, scene.TABLE_OUTER_RECT)
	var table_rect = anchor_rect_in_parent(outer_rect, scene.TABLE_INNER_RECT)
	var center_rect = anchor_rect_in_parent(table_rect, scene.CENTER_PANEL_RECT)
	var center_shell = scene.find_child("CenterConsole3DShell", true, false) as Control
	check(center_shell != null, "battle screen exposes the center console shell at %s" % viewport_size)
	if center_shell != null:
		center_rect = screen_rect(center_shell)
	var active_wind_luma := -1.0
	var inactive_wind_luma_max := -1.0
	var current_wind_seat := int(scene.get_current_seat())
	for i in range(scene.CENTER_WIND_LABELS.size()):
		var wind_text := str(scene.CENTER_WIND_LABELS[i])
		var wind_label = scene.find_child("CenterWindLabel_%s" % wind_text, true, false) as Label
		check(wind_label != null, "center wind label %s exists at %s" % [wind_text, viewport_size])
		if wind_label == null:
			continue
		var expected_wind_rect: Rect2 = scene.CENTER_WIND_RECTS[i]
		var actual_wind_rect := Rect2(
			Vector2(wind_label.anchor_left, wind_label.anchor_top),
			Vector2(wind_label.anchor_right, wind_label.anchor_bottom)
		)
		var wind_color = wind_label.get_theme_color("font_color")
		var outline_color = wind_label.get_theme_color("font_outline_color")
		check(wind_label.text == wind_text and wind_label.get_theme_font_size("font_size") == 17, "center wind label %s keeps stable text sizing at %s" % [wind_text, viewport_size])
		check(actual_wind_rect.position.distance_to(expected_wind_rect.position) <= 0.001 and actual_wind_rect.size.distance_to(expected_wind_rect.size) <= 0.001, "center wind label %s keeps its compass anchor at %s" % [wind_text, viewport_size])
		check(center_rect.grow(1.0).encloses(screen_rect(wind_label)), "center wind label %s stays inside the center console at %s" % [wind_text, viewport_size])
		check(wind_label.get_theme_constant("outline_size") >= 1 and outline_color.a >= 0.89, "center wind label %s keeps a dark readability outline at %s" % [wind_text, viewport_size])
		if i == current_wind_seat:
			active_wind_luma = relative_luma(wind_color)
			check(wind_color.a >= 0.81, "active center wind label remains fully legible at %s" % viewport_size)
		else:
			inactive_wind_luma_max = maxf(inactive_wind_luma_max, relative_luma(wind_color))
			check(wind_color.a >= 0.80, "inactive center wind label %s remains legible at %s" % [wind_text, viewport_size])
	var wall_status = scene.find_child("CenterWallStatusLabel", true, false) as Label
	check(wall_status != null and wall_status.tooltip_text.contains("牌墙剩余"), "center wall status exposes a precise remaining-wall tooltip at %s" % viewport_size)
	check(active_wind_luma > inactive_wind_luma_max, "active center wind label remains brighter than inactive labels at %s" % viewport_size)
	for i in range(discard_rects.size()):
		check(not rects_overlap(discard_rects[i], center_rect), "battle discard zone %d clears the center panel at %s" % [i, viewport_size])
		for j in range(i + 1, discard_rects.size()):
			check(not rects_overlap(discard_rects[i], discard_rects[j]), "battle discard zones %d and %d remain independent at %s" % [i, j, viewport_size])
	var seat_rects: Array[Rect2] = []
	var seat_rect_by_id: Dictionary = {}
	for seat_layout in scene.SEAT_LAYOUTS:
		var seat_id := int(seat_layout[0])
		var seat_panel = scene.find_child("SeatPanel_%d" % seat_id, true, false) as Control
		if seat_panel != null:
			var seat_rect = screen_rect(seat_panel)
			seat_rects.append(seat_rect)
			seat_rect_by_id[seat_id] = seat_rect
			check(viewport_rect.encloses(seat_rect), "battle seat panel %d stays inside viewport at %s" % [seat_id, viewport_size])
	var meld_rects: Array[Rect2] = []
	for meld_layout in scene.MELD_LAYOUTS:
		var meld_seat := int(meld_layout[0])
		var meld_area = scene.find_child("MeldArea_%d" % meld_seat, true, false) as Control
		if meld_area == null:
			continue
		var meld_rect = screen_rect(meld_area)
		meld_rects.append(meld_rect)
		check(viewport_rect.encloses(meld_rect), "battle meld area %d stays inside viewport at %s" % [meld_seat, viewport_size])
		if seat_rect_by_id.has(meld_seat):
			check(not rects_overlap(meld_rect, seat_rect_by_id[meld_seat]), "battle meld area %d clears its seat HUD at %s" % [meld_seat, viewport_size])
		for discard_rect in discard_rects:
			check(not rects_overlap(meld_rect, discard_rect), "battle meld area %d clears discard rivers at %s" % [meld_seat, viewport_size])
		var group_count := 0
		for child in meld_area.get_children():
			var meld_group := child as Control
			if meld_group == null or not str(meld_group.name).begins_with("MeldGroup_"):
				continue
			group_count += 1
			var group_rect := screen_rect(meld_group)
			check(meld_rect.grow(1.0).encloses(group_rect), "battle meld group %d/%d stays inside its assigned lane at %s" % [meld_seat, group_count, viewport_size])
			var expected_vertical: bool = bool(scene.seat_meld_is_vertical(meld_seat))
			check(str(meld_area.get_meta("orientation", "")) == ("vertical" if expected_vertical else "horizontal") and int(meld_area.get_meta("seat", -1)) == meld_seat, "battle meld area %d exposes its seat-facing orientation metadata at %s" % [meld_seat, viewport_size])
			var lane_tile_size = meld_area.get_meta("tile_size", Vector2.ZERO)
			check(lane_tile_size is Vector2 and lane_tile_size.x >= 18.0 and lane_tile_size.y >= 28.0, "battle meld area %d exposes a stable tile-size contract at %s" % [meld_seat, viewport_size])
			var meld_tiles = meld_group.find_child("MeldTiles", true, false) as Control
			var lane_orientation_ok: bool = bool(meld_tiles is VBoxContainer if expected_vertical else meld_tiles is HBoxContainer)
			check(lane_orientation_ok and meld_tiles.get_child_count() >= 3, "battle meld group %d/%d keeps the seat-facing %s tile lane at %s" % [meld_seat, group_count, "vertical" if expected_vertical else "horizontal", viewport_size])
			check(str(meld_group.get_meta("orientation", "")) == ("vertical" if expected_vertical else "horizontal") and int(meld_group.get_meta("tile_count", 0)) == meld_tiles.get_child_count(), "battle meld group %d/%d keeps its direction and tile-count metadata at %s" % [meld_seat, group_count, viewport_size])
			if meld_tiles != null:
				for holder in meld_tiles.get_children():
					if not (holder is Control) or holder.get_child_count() == 0:
						continue
					var tile_view := holder.get_child(0) as Control
					check(tile_view != null and absf(tile_view.rotation - scene.seat_meld_face_rotation(meld_seat)) <= 0.001, "battle meld group %d/%d faces toward the table center at %s" % [meld_seat, group_count, viewport_size])
					if not expected_vertical and viewport_size.y <= 560.0 and tile_view != null:
						check(tile_view.size.x >= 18.0, "compact horizontal meld group %d/%d keeps an 18px tile face minimum at %s" % [meld_seat, group_count, viewport_size])
		check(group_count == 4, "battle meld area %d fits all four groups at %s" % [meld_seat, viewport_size])
	var table_log = scene.find_child("TableLogLedgerPanel", true, false) as Control
	check(table_log != null, "battle renders named table log ledger at %s" % viewport_size)
	if table_log != null:
		var log_rect = screen_rect(table_log)
		check(viewport_rect.encloses(log_rect), "battle table log stays inside viewport at %s" % viewport_size)
		for seat_rect in seat_rects:
			check(not rects_overlap(log_rect, seat_rect), "battle table log clears seat HUDs at %s" % viewport_size)
		for meld_rect in meld_rects:
			check(not rects_overlap(log_rect, meld_rect), "battle table log clears meld areas at %s" % viewport_size)
		var expected_log_rows := 1 if viewport_size.y <= 560.0 else 2
		check(controls_with_name_prefix(table_log, "TableLogLedgerRow_").size() == expected_log_rows, "battle table log uses %d readable rows at %s" % [expected_log_rows, viewport_size])
		for body in controls_with_name_prefix(table_log, "TableLogLedgerBody_"):
			var body_label := body as Label
			check(body_label != null and body_label.clip_text and (label_text_width(body_label, body_label.text) <= screen_rect(body_label).size.x + 2.0 or body_label.tooltip_text == body_label.text), "battle table log latest event fits or exposes its full value at %s" % viewport_size)
	var action_children: Array = scene.action_bar_buttons()
	for child in action_children:
		var button = child as Button
		var button_rect = screen_rect(button)
		check(button.tooltip_text != "", "battle action button %s exposes a consequence tooltip at %s" % [button.text, viewport_size])
		check(viewport_rect.encloses(button_rect), "battle action button %s stays inside viewport at %s" % [button.text, viewport_size])
		if hand != null:
			check(not rects_overlap(button_rect, hand_rect), "battle action button %s clears hand tray at %s" % [button.text, viewport_size])
			check(button_rect.end.y <= hand_rect.position.y - 12.0, "battle action button %s keeps a readable lane above hand tray at %s" % [button.text, viewport_size])
		for seat_rect in seat_rects:
			check(not rects_overlap(button_rect, seat_rect), "battle action button %s clears seat panels at %s" % [button.text, viewport_size])
		for discard_rect in discard_rects:
			check(not rects_overlap(button_rect, discard_rect), "battle action button %s clears discard zones at %s" % [button.text, viewport_size])
	var text_controls: Array[Control] = []
	collect_visible_text_and_buttons(scene.root_layer, text_controls)
	for control in text_controls:
		var rect = screen_rect(control)
		if rect.size.x <= 0.5 or rect.size.y <= 0.5:
			continue
		check(viewport_rect.encloses(rect), "battle visible text/button %s stays inside viewport at %s" % [control.name, viewport_size])
	for hand_tile in controls_with_name_prefix(scene, "HandTile_"):
		check(hand_tile.tooltip_text != "", "hand tile %s exposes its tile and action meaning on hover at %s" % [hand_tile.name, viewport_size])

func battle_discard_zone_screen_rects(scene) -> Array[Rect2]:
	var root_rect = screen_rect(scene.root_layer)
	var outer_rect = anchor_rect_in_parent(root_rect, scene.TABLE_OUTER_RECT)
	var table_rect = anchor_rect_in_parent(outer_rect, scene.TABLE_INNER_RECT)
	var rects: Array[Rect2] = []
	for zone in scene.DISCARD_ZONES:
		rects.append(anchor_rect_in_parent(table_rect, zone[1]))
	return rects

func check_discard_tile_original_rgb(scene, viewport_size: Vector2) -> void:
	for seat in range(4):
		var grid = scene.find_child("DiscardGrid_%d" % seat, true, false) as GridContainer
		check(grid != null, "battle river %d exists for original-RGB audit at %s" % [seat, viewport_size])
		if grid == null:
			continue
		var checked_tiles := 0
		for tile_node in grid.get_children():
			var face = tile_node.find_child("TileFaceTexture", true, false) as TextureRect
			if face == null:
				continue
			checked_tiles += 1
			var tile_canvas = tile_node as CanvasItem
			check(tile_canvas != null and is_equal_approx(tile_canvas.modulate.r, 1.0) and is_equal_approx(tile_canvas.modulate.g, 1.0) and is_equal_approx(tile_canvas.modulate.b, 1.0), "battle river %d tile host keeps authored RGB at %s" % [seat, viewport_size])
			check(is_equal_approx(face.modulate.r, 1.0) and is_equal_approx(face.modulate.g, 1.0) and is_equal_approx(face.modulate.b, 1.0), "battle river %d tile face keeps authored RGB at %s" % [seat, viewport_size])
		check(checked_tiles > 0, "battle river %d exposes tile faces for original-RGB audit at %s" % [seat, viewport_size])

func anchor_rect_in_parent(parent_rect: Rect2, anchor_rect: Rect2) -> Rect2:
	var left = parent_rect.position.x + anchor_rect.position.x * parent_rect.size.x
	var top = parent_rect.position.y + anchor_rect.position.y * parent_rect.size.y
	var right = parent_rect.position.x + anchor_rect.size.x * parent_rect.size.x
	var bottom = parent_rect.position.y + anchor_rect.size.y * parent_rect.size.y
	return Rect2(Vector2(left, top), Vector2(max(0.0, right - left), max(0.0, bottom - top)))

func collect_visible_text_and_buttons(node: Node, found: Array[Control]) -> void:
	if node == null:
		return
	if node is Control:
		var control = node as Control
		if control.is_visible_in_tree() and (control is Label or control is Button):
			found.append(control)
	for child in node.get_children():
		collect_visible_text_and_buttons(child, found)

func collect_buttons(node: Node, found: Array[Button]) -> void:
	if node == null:
		return
	if node is Button:
		found.append(node as Button)
		return
	for child in node.get_children():
		collect_buttons(child, found)

func check_settings_overlay(scene, viewport_size: Vector2) -> void:
	var overlay = scene.root_layer.get_child(scene.root_layer.get_child_count() - 1) if scene.root_layer.get_child_count() > 0 else null
	check(overlay is Control, "settings overlay creates a top-level Control at %s" % viewport_size)
	if not (overlay is Control):
		return
	var overlay_control := overlay as Control
	check(overlay_control.mouse_filter == Control.MOUSE_FILTER_STOP, "settings overlay blocks clicks behind the modal at %s" % viewport_size)
	var overlay_rect = screen_rect(overlay_control)
	var root_rect = screen_rect(scene.root_layer)
	check(overlay_rect.position.distance_to(root_rect.position) <= 0.5 and overlay_rect.size.distance_to(root_rect.size) <= 1.0, "settings overlay covers the safe content viewport at %s" % viewport_size)
	var scrim = overlay_control.find_child("SettingsOverlayScrim", true, false) as Control
	check(scrim != null, "settings overlay exposes a named full-screen scrim at %s" % viewport_size)
	if scrim != null:
		var scrim_rect = screen_rect(scrim)
		check(scrim_rect.position.distance_to(overlay_rect.position) <= 0.5 and scrim_rect.size.distance_to(overlay_rect.size) <= 1.0, "settings scrim covers the entire overlay at %s" % viewport_size)
		var scrim_ok := false
		if scrim is ColorRect:
			var sc := scrim as ColorRect
			scrim_ok = sc.color.a >= 0.62 and relative_luma(sc.color) <= 0.02
		elif scrim is TextureRect:
			scrim_ok = scrim.modulate.a >= 0.55
		else:
			scrim_ok = scrim.visible and scrim.modulate.a >= 0.55
		check(scrim_ok, "settings scrim darkens background controls enough at %s" % viewport_size)
	var panel = overlay_control.find_child("SettingsPanel", true, false) as Control
	var panel_shadow = overlay_control.find_child("SettingsConsole3DCastShadow", true, false) as Control
	var rear_shell = overlay_control.find_child("SettingsConsole3DRearShell", true, false) as Control
	check(panel != null, "settings overlay exposes a named modal panel at %s" % viewport_size)
	check(panel_shadow != null and rear_shell == null, "settings overlay keeps one primary surface without a duplicate rear shell at %s" % viewport_size)
	var panel_rect := Rect2()
	if panel != null:
		panel_rect = screen_rect(panel)
		check(Rect2(Vector2.ZERO, viewport_size).grow(-4.0).encloses(panel_rect), "settings modal stays fully inside viewport with visible margin at %s" % viewport_size)
		if scrim != null:
			check(panel.get_index() > scrim.get_index(), "settings modal renders above the background scrim at %s" % viewport_size)
	var close_button = first_button_with_text(overlay_control, "关闭")
	check(close_button != null, "settings overlay exposes close button at %s" % viewport_size)
	if close_button != null and panel != null:
		check(panel_rect.grow(1.0).encloses(screen_rect(close_button)), "settings close button stays inside modal bounds at %s" % viewport_size)
	var header_title_label = overlay_control.find_child("SettingsTitleLabel", true, false) as Label
	var rule_variant_label = overlay_control.find_child("SettingsRuleVariantLabel", true, false) as Label
	var rule_variant_button = overlay_control.find_child("SettingsRuleVariantButton", true, false) as Button
	var rule_variant_status = overlay_control.find_child("SettingsRuleVariantStatus", true, false) as Label
	var overview_art = overlay_control.find_child("SettingsOverviewArt", true, false) as Control
	var overview_summary = overlay_control.find_child("SettingsOverviewSummary", true, false) as Label
	check(header_title_label != null and overview_art != null and overview_summary != null, "settings header exposes named title and overview controls at %s" % viewport_size)
	check(rule_variant_label != null and rule_variant_button != null and rule_variant_status != null, "settings header exposes the local-rule selector and persistent activation state at %s" % viewport_size)
	check(overlay_control.find_child("SettingsTitleBack", true, false) == null, "settings header relies on the dedicated clean panel surface without a duplicate texture rail at %s" % viewport_size)
	if rule_variant_label != null and rule_variant_button != null and rule_variant_status != null:
		var rule_label_rect = screen_rect(rule_variant_label)
		var rule_button_rect = screen_rect(rule_variant_button)
		var rule_status_rect = screen_rect(rule_variant_status)
		check(rule_variant_status.text == "当前局：扬州 · 下一局：四川", "settings local-rule state distinguishes the active and queued profiles at %s" % viewport_size)
		check(rule_variant_status.clip_text and rule_variant_status.get_theme_font_size("font_size") >= 11 and relative_luma(rule_variant_status.get_theme_color("font_color")) >= 0.80, "settings local-rule state remains readable and clipped at %s" % viewport_size)
		check(not rects_overlap(rule_label_rect.grow(-1.0), rule_button_rect.grow(-1.0)) and not rects_overlap(rule_status_rect.grow(-1.0), rule_button_rect.grow(-1.0)), "settings local-rule label and state clear the selector button at %s" % viewport_size)
		check(label_text_width(rule_variant_status, rule_variant_status.text) <= rule_status_rect.size.x + 1.0, "settings local-rule state fits its header lane at %s" % viewport_size)
	if header_title_label != null and panel != null:
		check(panel_rect.grow(1.0).encloses(screen_rect(header_title_label)), "settings title stays inside modal at %s" % viewport_size)
		check(header_title_label.clip_text and header_title_label.text_overrun_behavior == TextServer.OVERRUN_TRIM_ELLIPSIS, "settings title clips safely at %s" % viewport_size)
	if overview_art != null and panel != null:
		var overview_rect = screen_rect(overview_art)
		check(panel_rect.grow(1.0).encloses(overview_rect), "settings overview meter stays inside modal at %s" % viewport_size)
		var overview_panel_texture = overview_art.find_child("SettingsOverviewPanelTexture", true, false) as CanvasItem
		check(overview_panel_texture == null or overview_panel_texture.modulate.a <= 0.04, "settings overview generated plate stays below native state controls at %s" % viewport_size)
		if header_title_label != null:
			var title_rect = screen_rect(header_title_label)
			check(not rects_overlap(overview_rect.grow(-1.0), title_rect.grow(-1.0)), "settings overview meter clears title lane at %s" % viewport_size)
			check(overview_rect.position.y >= title_rect.end.y + 4.0, "settings overview meter sits below title lane with breathing room at %s" % viewport_size)
		if close_button != null:
			var close_rect = screen_rect(close_button)
			check(not rects_overlap(overview_rect.grow(-1.0), close_rect.grow(-1.0)), "settings overview meter clears close button lane at %s" % viewport_size)
			check(overview_rect.position.y >= close_rect.end.y + 4.0, "settings overview meter sits below close button lane with breathing room at %s" % viewport_size)
	if overview_summary != null and overview_art != null:
		var summary_rect = screen_rect(overview_summary)
		check(screen_rect(overview_art).grow(1.0).encloses(summary_rect), "settings overview summary stays inside overview meter at %s" % viewport_size)
		check(overview_summary.clip_text and overview_summary.text_overrun_behavior == TextServer.OVERRUN_TRIM_ELLIPSIS, "settings overview summary clips safely at %s" % viewport_size)
		check(label_text_width(overview_summary, overview_summary.text) <= summary_rect.size.x - 4.0, "settings overview summary text fits its compact lane at %s" % viewport_size)
		for overview_node_name in ["audio", "play", "maint"]:
			var overview_node = overlay_control.find_child("SettingsOverviewNode_%s" % overview_node_name, true, false) as Control
			check(overview_node != null, "settings overview exposes %s state node at %s" % [overview_node_name, viewport_size])
			if overview_node != null:
				check(not rects_overlap(summary_rect.grow(-1.0), screen_rect(overview_node).grow(-1.0)), "settings overview summary clears %s state node at %s" % [overview_node_name, viewport_size])
	if viewport_size.x <= 960.0 and overview_art != null:
		var small_overview_rect = screen_rect(overview_art)
		check(small_overview_rect.size.y >= 26.0, "settings overview keeps readable compact height at %s" % viewport_size)
		var small_audio_section = overlay_control.find_child("SettingsSection_声音", true, false) as Control
		var small_play_section = overlay_control.find_child("SettingsSection_体验", true, false) as Control
		var small_maint_section = overlay_control.find_child("SettingsSection_系统", true, false) as Control
		check(small_audio_section != null and small_play_section != null and small_maint_section != null, "settings small viewport exposes all sections at %s" % viewport_size)
		if small_audio_section != null and small_play_section != null and small_maint_section != null:
			var small_audio_rect = screen_rect(small_audio_section)
			var small_play_rect = screen_rect(small_play_section)
			var small_maint_rect = screen_rect(small_maint_section)
			check(small_audio_rect.position.y >= small_overview_rect.end.y + 8.0, "settings audio section clears overview on compact viewport at %s" % viewport_size)
			check(small_play_rect.position.y >= small_overview_rect.end.y + 8.0, "settings play section clears overview on compact viewport at %s" % viewport_size)
			check(small_maint_rect.size.y >= 64.0, "settings maintenance section keeps readable height on compact viewport at %s" % viewport_size)
			check(small_maint_rect.position.y >= small_audio_rect.end.y + 8.0 and small_maint_rect.position.y >= small_play_rect.end.y + 8.0, "settings maintenance clears upper sections on compact viewport at %s" % viewport_size)
	var expected_setting_buttons := {
		"背景音乐": ["已开", "已关"],
		"音效反馈": ["已开", "已关"],
		"语音报牌": ["已开", "已关"],
		"播放测试": "试音",
		"AI 节奏": ["快速", "标准"],
		"AI 难度": ["简单", "标准", "困难"],
		"桌面特效": ["已开", "已关"],
		"阅读辅助": ["标准", "大字", "高对比", "减动效", "专注", "清晰"],
		"3D 画质": ["自动", "省电", "标准", "精细"],
		"出牌辅助": ["已开", "已关"],
		"播放曲目": "切歌",
		"本地进度": "重置",
	}
	var settings_sections := {
		"声音": ["背景音乐", "音效反馈", "语音报牌", "播放测试"],
		"体验": ["AI 节奏", "AI 难度", "桌面特效", "阅读辅助", "出牌辅助", "播放曲目"],
		"系统": ["3D 画质", "本地进度"],
	}
	var section_rects: Array = []
	for section_name in settings_sections.keys():
		var section = overlay_control.find_child("SettingsSection_%s" % section_name, true, false) as Control
		var grid = overlay_control.find_child("SettingsSectionGrid_%s" % section_name, true, false) as Control
		var section_shadow = overlay_control.find_child("SettingsSection3DCastShadow_%s" % section_name, true, false) as Control
		var section_depth = overlay_control.find_child("SettingsSection3DDepthEdge_%s" % section_name, true, false) as Control
		check(section != null and grid != null and section_shadow != null and section_depth != null, "settings section %s exposes named physical section shell and grid at %s" % [section_name, viewport_size])
		if section != null and panel != null:
			var section_rect = screen_rect(section)
			check(panel_rect.grow(1.0).encloses(section_rect), "settings section %s stays inside modal at %s" % [section_name, viewport_size])
			for previous_rect in section_rects:
				check(not rects_overlap(section_rect.grow(-1.0), previous_rect.grow(-1.0)), "settings section %s does not overlap another section at %s" % [section_name, viewport_size])
			section_rects.append(section_rect)
		if grid != null and section != null:
			check(screen_rect(section).grow(1.0).encloses(screen_rect(grid)), "settings section %s keeps its grid inside the section at %s" % [section_name, viewport_size])
	for title in expected_setting_buttons.keys():
		var row = overlay_control.find_child("SettingRow_%s" % title, true, false) as Control
		var button = overlay_control.find_child("SettingRowButton_%s" % title, true, false) as Button
		check(row != null and button != null, "settings row %s exposes a named row and button at %s" % [title, viewport_size])
		if button == null:
			continue
		var row_rect := Rect2()
		if row != null:
			row_rect = screen_rect(row)
		var button_rect = screen_rect(button)
		if row != null:
			check(row_rect.size.y >= 48.0 and row_rect.size.x >= button_rect.size.x + 96.0, "settings row %s keeps 960-safe row rhythm and width at %s" % [title, viewport_size])
			check(row_rect.grow(1.0).encloses(button_rect), "settings row %s encloses its button at %s" % [title, viewport_size])
		check(button_rect.size.x >= 92.0 and button_rect.size.y >= 32.0, "settings row %s keeps a practical button target at %s" % [title, viewport_size])
		var expected_text = expected_setting_buttons[title]
		var matches_expected_text := false
		if expected_text is Array:
			matches_expected_text = expected_text.has(button.text)
		else:
			matches_expected_text = button.text == str(expected_text)
		check(matches_expected_text or (title == "本地进度" and button.text == "清空"), "settings row %s uses compact button text at %s" % [title, viewport_size])
		check(button.text.length() <= 4 and button.clip_text and button.text_overrun_behavior == TextServer.OVERRUN_TRIM_ELLIPSIS, "settings row %s clips compact text safely at %s" % [title, viewport_size])
		check(button.get_theme_font_size("font_size") <= 15, "settings row %s caps button font size at %s" % [title, viewport_size])
		var title_label = overlay_control.find_child("SettingRowTitle_%s" % title, true, false) as Label
		var status_label = overlay_control.find_child("SettingRowStatus_%s" % title, true, false) as Label
		var text_panel = overlay_control.find_child("SettingRowTextReadabilityPanel_%s" % title, true, false) as Control
		check(title_label != null and status_label != null and text_panel != null, "settings row %s exposes title status and readability panel at %s" % [title, viewport_size])
		if title_label != null:
			check(title_label.clip_text and title_label.text_overrun_behavior == TextServer.OVERRUN_TRIM_ELLIPSIS and title_label.get_theme_font_size("font_size") >= 14 and relative_luma(title_label.get_theme_color("font_color")) >= 0.94, "settings row %s title stays bright clipped and readable at %s" % [title, viewport_size])
			check(not rects_overlap(screen_rect(title_label), button_rect), "settings row %s title clears the button lane at %s" % [title, viewport_size])
		if status_label != null:
			check(status_label.clip_text and status_label.text_overrun_behavior == TextServer.OVERRUN_TRIM_ELLIPSIS and status_label.get_theme_font_size("font_size") >= 13 and relative_luma(status_label.get_theme_color("font_color")) >= 0.94, "settings row %s status stays bright clipped and readable at %s" % [title, viewport_size])
			check(not rects_overlap(screen_rect(status_label), button_rect), "settings row %s status clears the button lane at %s" % [title, viewport_size])
		if text_panel != null:
			var text_panel_rect = screen_rect(text_panel)
			check(text_panel_rect.end.x <= button_rect.position.x - max(4.0, viewport_size.x * 0.004), "settings row %s readability panel clears the button lane at %s" % [title, viewport_size])
			if row != null:
				check(row_rect.grow(1.0).encloses(text_panel_rect), "settings row %s encloses its text readability panel at %s" % [title, viewport_size])
			if title_label != null:
				check(text_panel_rect.grow(1.0).encloses(screen_rect(title_label)), "settings row %s readability panel backs the title at %s" % [title, viewport_size])
			if status_label != null:
				check(text_panel_rect.grow(1.0).encloses(screen_rect(status_label)), "settings row %s readability panel backs the status at %s" % [title, viewport_size])
		var switch_art = button.find_child("SettingSwitchArt", true, false) as Control
		if title == "AI 节奏" or title == "AI 难度":
			check(str(button.get_meta("setting_kind", "")) == "selector" and switch_art == null, "settings row %s uses enum selector semantics instead of a boolean switch at %s" % [title, viewport_size])
		if switch_art != null:
			var switch_rect = screen_rect(switch_art)
			check(switch_rect.position.x >= button_rect.position.x + button_rect.size.x * 0.66 and switch_rect.end.x <= button_rect.end.x + 1.0, "settings row %s switch art stays in the right edge lane at %s" % [title, viewport_size])
		if title == "播放测试":
			check_settings_button_art_text_safe_zone(button, [
				"AudioTestWaveRail",
				"AudioTestWaveFill",
				"AudioTestWaveBar_",
				"AudioTestCommandRoute",
				"AudioTestCommandFill",
				"AudioTestCommandGate",
				"AudioTestCommandTick_",
				"AudioTestPlaybackRoute",
				"AudioTestPlaybackFill",
				"AudioTestPlaybackGate",
				"AudioTestPlaybackTick_",
			], title, viewport_size)
		if title == "播放曲目":
			check_settings_button_art_text_safe_zone(button, [
				"BgmSwitchTrackRail",
				"BgmSwitchTrackFill",
				"BgmSwitchNote_",
				"BgmSwitchNoteStem_",
				"BgmSwitchCommandRoute",
				"BgmSwitchCommandFill",
				"BgmSwitchCommandGate",
				"BgmSwitchCommandTick_",
				"BgmSwitchPlaybackRoute",
				"BgmSwitchPlaybackFill",
				"BgmSwitchPlaybackGate",
				"BgmSwitchPlaybackTick_",
			], title, viewport_size)
		if title == "本地进度":
			var reset_texture = button.find_child("ResetDangerSealTexture", true, false) as CanvasItem
			check(reset_texture == null or reset_texture.modulate.a <= 0.12, "settings reset row keeps full-button texture subdued at %s" % viewport_size)
			check_settings_button_art_text_safe_zone(button, [
				"ResetProgressDangerRail",
				"ResetProgressDangerFill",
				"ResetProgressHoldRoute",
				"ResetProgressHoldFill",
				"ResetProgressHoldGate",
				"ResetProgressHoldTick_",
				"ResetProgressLockSeal",
				"ResetProgressLockRoute",
				"ResetProgressLockFill",
				"ResetProgressLockGate",
				"ResetProgressLockTick_",
				"ResetProgressDangerNode_",
				"ResetProgressWarningSpark_",
			], title, viewport_size)
	for long_text in ["音乐关", "音效关", "报牌关", "特效关", "辅助关", "快速开", "快速关", "重置进度", "确认清空"]:
		check(first_button_with_text(overlay_control, long_text) == null, "settings overlay omits long button label %s at %s" % [long_text, viewport_size])
	for compact_section_name in ["声音", "体验", "系统"]:
		var compact_grid = overlay_control.find_child("SettingsSectionGrid_%s" % compact_section_name, true, false) as Control
		if compact_grid == null:
			continue
		var section_signal_texture = overlay_control.find_child("SettingsSectionSignalPanelTexture_%s" % compact_section_name, true, false) as CanvasItem
		check(section_signal_texture == null or section_signal_texture.modulate.a <= 0.03, "settings section %s generated signal plate stays quiet at %s" % [compact_section_name, viewport_size])
		var previous_setting_row_rects: Array[Rect2] = []
		for grid_child in compact_grid.get_children():
			if not (grid_child is Control):
				continue
			var setting_child_rect = screen_rect(grid_child as Control)
			for previous_setting_row_rect in previous_setting_row_rects:
				check(not rects_overlap(setting_child_rect.grow(-1.5), previous_setting_row_rect.grow(-1.5)), "settings rows keep a clear grid gap in %s at %s" % [compact_section_name, viewport_size])
			previous_setting_row_rects.append(setting_child_rect)

func check_online_lobby_layout(scene, viewport_size: Vector2) -> void:
	var page_plate = scene.find_child("OnlineLobbyLowFrequencyPagePlate", true, false) as TextureRect
	var form_panel = scene.find_child("OnlineLobbyFormPanel", true, false) as Control
	var log_panel = scene.find_child("OnlineLobbyLogPanel", true, false) as Control
	var input_backplate = scene.find_child("OnlineLobbyInputGroupBackplate", true, false) as Control
	var action_backplate = scene.find_child("OnlineLobbyActionClusterBackplate", true, false) as Control
	var status_backplate = scene.find_child("OnlineLobbyStatusReadabilityBackplate", true, false) as Control
	var status_label = scene.find_child("OnlineLobbyStatusLabel", true, false) as Label
	var divider = scene.find_child("OnlineLobbySplitDivider", true, false) as Control
	var feedback = scene.find_child("OnlineFeedbackArt", true, false) as Control
	var feedback_text = scene.find_child("OnlineFeedbackText", true, false) as Label
	var feedback_text_backplate = scene.find_child("OnlineFeedbackTextBackplate", true, false) as Control
	var feedback_seal = scene.find_child("OnlineFeedbackStatusSeal", true, false) as Control
	var room_status_art = scene.find_child("OnlineLobbyRoomArt", true, false) as Control
	var room_summary_panel = scene.find_child("OnlineLobbyRoomSummaryPanel", true, false) as Control
	var room_summary_occupancy = scene.find_child("OnlineLobbyRoomSummaryOccupancy", true, false) as Control
	var room_summary_ready = scene.find_child("OnlineLobbyRoomSummaryReady", true, false) as Control
	var room_summary_state = scene.find_child("OnlineLobbyRoomSummaryState", true, false) as Control
	var room_summary_occupancy_label = scene.find_child("OnlineLobbyRoomSummaryOccupancyLabel", true, false) as Label
	var room_summary_ready_label = scene.find_child("OnlineLobbyRoomSummaryReadyLabel", true, false) as Label
	var room_summary_state_label = scene.find_child("OnlineLobbyRoomSummaryStateLabel", true, false) as Label
	var roster_panel = scene.find_child("OnlineLobbyRosterPanel", true, false) as Control
	var log_list_panel = scene.find_child("OnlineLobbyLogListPanel", true, false) as Control
	var log_scroll = scene.find_child("OnlineLobbyLogScroll", true, false) as ScrollContainer
	var log_list_text = scene.find_child("OnlineLobbyLogListText", true, false) as RichTextLabel
	var name_edit = scene.find_child("OnlineLobbyNameEdit", true, false) as LineEdit
	var host_edit = scene.find_child("OnlineLobbyHostEdit", true, false) as LineEdit
	var room_edit = scene.find_child("OnlineLobbyRoomEdit", true, false) as LineEdit
	var roster_title = scene.find_child("OnlineLobbyRosterTitle", true, false) as Label
	var log_list_title = scene.find_child("OnlineLobbyLogListTitle", true, false) as Label
	var log_count_badge = scene.find_child("OnlineLobbyLogCountBadge", true, false) as Control
	var log_latest_button = scene.find_child("OnlineLobbyLogLatestButton", true, false) as Button
	var log_unread_label = scene.find_child("OnlineLobbyLogUnreadLabel", true, false) as Label
	var room_badge = scene.find_child("OnlineLobbyRoomBadge", true, false) as Control
	var room_offline_state = scene.find_child("OnlineLobbyRoomOfflineState", true, false) as Label
	var endpoint_badge = scene.find_child("OnlineLobbyServerEndpointBadge", true, false) as Control
	var endpoint_label = scene.find_child("OnlineLobbyServerEndpointLabel", true, false) as Label
	var state_badge = scene.find_child("OnlineLobbyConnectionStateBadge", true, false) as Control
	var connection_state_label = scene.find_child("OnlineLobbyConnectionStateLabel", true, false) as Label
	check(page_plate != null and form_panel != null and log_panel != null, "online lobby exposes a low-frequency page plate and named split panels at %s" % viewport_size)
	if page_plate != null:
		var page_source = (page_plate.texture as AtlasTexture).atlas if page_plate.texture is AtlasTexture else page_plate.texture
		check(page_source != null and str(page_source.resource_path).ends_with("ui_dark_scrim.png") and page_plate.self_modulate.a >= 0.35 and page_plate.self_modulate.a <= 0.60, "disconnected lobby uses a restrained low-frequency authored bitmap substrate at %s" % viewport_size)
	check(input_backplate != null and action_backplate != null and status_backplate != null and status_label != null and divider != null, "online lobby exposes readability grouping backplates and status label at %s" % viewport_size)
	check(room_status_art != null and room_summary_panel != null and roster_panel != null and log_list_panel != null and log_list_text != null and log_latest_button != null and log_unread_label != null, "online lobby exposes room summary roster log list and latest-log controls at %s" % viewport_size)
	var roster_texture = (roster_panel as TextureRect).texture if roster_panel is TextureRect else null
	var log_list_texture = (log_list_panel as TextureRect).texture if log_list_panel is TextureRect else null
	var roster_source = (roster_texture as AtlasTexture).atlas if roster_texture is AtlasTexture else roster_texture
	var log_list_source = (log_list_texture as AtlasTexture).atlas if log_list_texture is AtlasTexture else log_list_texture
	var roster_texture_path := str(roster_source.resource_path) if roster_source != null else ""
	var log_list_texture_path := str(log_list_source.resource_path) if log_list_source != null else ""
	check(roster_texture_path.ends_with("ui_dark_scrim.png") and log_list_texture_path.ends_with("ui_dark_scrim.png"), "online lobby reading panels use the low-frequency dark bitmap substrate at %s" % viewport_size)
	check(room_offline_state != null and not room_status_art.visible and not roster_panel.visible and not log_list_panel.visible, "disconnected lobby hides stale room, roster, and log content behind an explicit empty state at %s" % viewport_size)
	check(scene.online_room.is_empty() and room_offline_state != null and room_offline_state.text == "连接后显示房间、席位和日志", "disconnected lobby clears the room snapshot and explains the empty state at %s" % viewport_size)
	if room_badge != null and room_badge.get_child_count() > 0:
		var room_badge_label = room_badge.get_child(room_badge.get_child_count() - 1) as Label
		check(room_badge_label != null and room_badge_label.text == "房间号 连接后显示", "disconnected lobby replaces the room badge with a connection-state hint at %s" % viewport_size)
		check(not room_badge.visible and room_badge.mouse_filter == Control.MOUSE_FILTER_IGNORE, "disconnected lobby hides the room detail target until a room snapshot exists at %s" % viewport_size)
	check(endpoint_badge != null and endpoint_label != null and state_badge != null and connection_state_label != null, "online lobby exposes top endpoint and connection-state badges at %s" % viewport_size)
	check(name_edit != null and name_edit.max_length == scene.ONLINE_NAME_MAX_LENGTH, "online lobby nickname input enforces its client boundary at %s" % viewport_size)
	check(host_edit != null and host_edit.max_length == scene.ONLINE_HOST_MAX_LENGTH and host_edit.virtual_keyboard_type == LineEdit.KEYBOARD_TYPE_URL, "online lobby host input enforces its boundary and URL keyboard at %s" % viewport_size)
	check(room_edit != null and room_edit.max_length == scene.ONLINE_ROOM_CODE_MAX_LENGTH, "online lobby room input enforces its client boundary at %s" % viewport_size)
	check(scene.optional_gpt_illustration_texture("online_lobby_panel_frame") == null or (scene.find_child("OnlineLobbyFormGPTPanelFrameTexture", true, false) != null and scene.find_child("OnlineLobbyLogGPTPanelFrameTexture", true, false) != null), "online lobby consumes GPT panel-frame textures at %s" % viewport_size)
	check(scene.optional_gpt_illustration_texture("online_lobby_group_plate") == null or (scene.find_child("OnlineLobbyInputGPTGroupPlateTexture", true, false) != null and scene.find_child("OnlineLobbyActionGPTGroupPlateTexture", true, false) != null), "online lobby consumes GPT group-plate textures at %s" % viewport_size)
	var form_gpt_frame = scene.find_child("OnlineLobbyFormGPTPanelFrameTexture", true, false) as CanvasItem
	var log_gpt_frame = scene.find_child("OnlineLobbyLogGPTPanelFrameTexture", true, false) as CanvasItem
	var input_gpt_plate = scene.find_child("OnlineLobbyInputGPTGroupPlateTexture", true, false) as CanvasItem
	var action_gpt_plate = scene.find_child("OnlineLobbyActionGPTGroupPlateTexture", true, false) as CanvasItem
	var fan_texture = scene.find_child("OnlineLobbyFanTexture", true, false) as CanvasItem
	check(form_gpt_frame == null or form_gpt_frame.modulate.a <= 0.06, "online lobby form GPT frame stays edge-level at %s" % viewport_size)
	check(log_gpt_frame == null or log_gpt_frame.modulate.a <= 0.06, "online lobby log GPT frame stays edge-level at %s" % viewport_size)
	check(input_gpt_plate == null or input_gpt_plate.modulate.a <= 0.05, "online lobby input GPT group plate stays below the controls at %s" % viewport_size)
	check(action_gpt_plate == null or action_gpt_plate.modulate.a <= 0.05, "online lobby action GPT group plate stays below the controls at %s" % viewport_size)
	check(fan_texture == null or fan_texture.modulate.a <= 0.01, "online lobby fan remains a quiet header-edge decoration at %s" % viewport_size)
	if form_panel == null or log_panel == null:
		return
	var form_rect = screen_rect(form_panel)
	var log_rect = screen_rect(log_panel)
	check(not form_rect.intersects(log_rect, true), "online lobby form and log panels do not overlap at %s" % viewport_size)
	check(form_rect.position.x >= -0.5 and log_rect.end.x <= viewport_size.x + 0.5, "online lobby split panels stay inside viewport at %s" % viewport_size)
	if endpoint_badge != null and endpoint_label != null and state_badge != null:
		var expected_endpoint: String = str(scene.online_connection_endpoint_text())
		var endpoint_rect = screen_rect(endpoint_badge)
		var endpoint_label_rect = screen_rect(endpoint_label)
		var state_rect = screen_rect(state_badge)
		check(str(endpoint_label.text) == expected_endpoint, "online lobby top endpoint label keeps the full host:port value at %s" % viewport_size)
		check(not str(endpoint_label.text).contains("...") and not str(endpoint_label.text).contains("…"), "online lobby top endpoint source text is not pre-truncated at %s" % viewport_size)
		check(endpoint_rect.position.x >= viewport_size.x * 0.56 and endpoint_rect.end.x <= viewport_size.x * 0.83, "online lobby endpoint badge stays in the top-right status lane at %s" % viewport_size)
		check(endpoint_rect.end.x <= state_rect.position.x - max(4.0, viewport_size.x * 0.004), "online lobby endpoint and state badges keep visible separation at %s" % viewport_size)
		check(endpoint_rect.position.y >= 0.0 and endpoint_rect.end.y <= form_rect.position.y - 8.0, "online lobby endpoint badge clears the split content panels at %s" % viewport_size)
		check(label_text_width(endpoint_label, expected_endpoint) <= endpoint_label_rect.size.x + 1.0, "online lobby endpoint text fits without rendered ellipsis at %s" % viewport_size)
	if input_backplate != null and action_backplate != null:
		var input_rect = screen_rect(input_backplate)
		var action_rect = screen_rect(action_backplate)
		check(input_rect.position.y < action_rect.position.y and not input_rect.intersects(action_rect, true), "online lobby input and action groups remain vertically separated at %s" % viewport_size)
		check(action_rect.end.y <= form_rect.end.y - max(10.0, form_rect.size.y * 0.030), "online lobby action cluster lifts off the form bottom at %s" % viewport_size)
		for input_id in ["name", "server", "room"]:
			var input_art = scene.find_child("LineEditInputArt_%s" % input_id, true, false) as CanvasItem
			var input_edit = input_art.get_parent() as LineEdit if input_art != null else null
			check(input_edit != null, "online lobby keeps the %s input visible at %s" % [input_id, viewport_size])
			if input_edit == null:
				continue
			check(input_art.show_behind_parent, "online lobby %s GPT field art stays behind native text caret and selection at %s" % [input_id, viewport_size])
			var room_input_may_be_empty: bool = input_id == "room" and scene.lobby_connection_state_text() != "已连接" and not scene.online_waiting_for_server
			check((input_edit.text.strip_edges() != "" or room_input_may_be_empty) and input_edit.get_theme_font_size("font_size") >= 18, "online lobby %s input keeps a visible value or an intentional disconnected empty state at %s" % [input_id, viewport_size])
			var edit_rect = screen_rect(input_edit)
			check(edit_rect.position.y >= input_rect.position.y - 1.0 and edit_rect.end.y <= input_rect.end.y + 1.0, "online lobby %s input stays inside input group at %s" % [input_id, viewport_size])
			check(edit_rect.end.y <= action_rect.position.y - 2.0, "online lobby %s input clears action group at %s" % [input_id, viewport_size])
			var focus_glow = input_edit.find_child("LineEditInputFocusGlow_%s" % input_id, true, false) as Control
			var accent_wash = input_edit.find_child("LineEditInputAccentWash_%s" % input_id, true, false) as Control
			var corner_seal = input_edit.find_child("LineEditInputCornerSeal_%s" % input_id, true, false) as Control
			check(focus_glow != null and accent_wash != null and corner_seal != null, "online lobby %s input exposes restrained material accents at %s" % [input_id, viewport_size])
			if focus_glow != null:
				var focus_rect = screen_rect(focus_glow)
				check(focus_rect.size.x <= edit_rect.size.x * 0.04 and focus_rect.size.y <= edit_rect.size.y * 0.04, "online lobby %s input focus rail stays thin and non-button-like at %s" % [input_id, viewport_size])
			if accent_wash != null:
				var accent_rect = screen_rect(accent_wash)
				check(accent_rect.size.x <= edit_rect.size.x * 0.012 and accent_rect.size.y <= edit_rect.size.y * 0.40, "online lobby %s input accent wash remains a quiet edge detail at %s" % [input_id, viewport_size])
			if corner_seal != null:
				var seal_rect = screen_rect(corner_seal)
				check(seal_rect.size.x <= edit_rect.size.x * 0.035 and seal_rect.size.y <= edit_rect.size.y * 0.18, "online lobby %s input corner seal stays compact at %s" % [input_id, viewport_size])
	if room_status_art != null and roster_panel != null and log_list_panel != null:
		var room_status_rect = screen_rect(room_status_art)
		var roster_rect = screen_rect(roster_panel)
		var log_list_rect = screen_rect(log_list_panel)
		check(log_rect.grow(1.0).encloses(room_status_rect) and log_rect.grow(1.0).encloses(roster_rect) and log_rect.grow(1.0).encloses(log_list_rect), "online lobby room hierarchy stays inside log panel at %s" % viewport_size)
		check(room_status_rect.end.y <= roster_rect.position.y - 2.0 and roster_rect.end.y <= log_list_rect.position.y - 2.0, "online lobby room roster and log list remain vertically separated at %s" % viewport_size)
		if room_summary_panel != null:
			var summary_rect = screen_rect(room_summary_panel)
			check(room_status_rect.grow(1.0).encloses(summary_rect), "online lobby room summary stays inside room art at %s" % viewport_size)
			check(summary_rect.size.y >= max(20.0, room_status_rect.size.y * 0.42), "online lobby room summary keeps readable height at %s" % viewport_size)
			for chip in [room_summary_occupancy, room_summary_ready, room_summary_state]:
				check(chip != null and summary_rect.grow(1.0).encloses(screen_rect(chip)), "online lobby room summary chip stays inside summary panel at %s" % viewport_size)
			var previous_chip_rect := Rect2()
			var has_previous_chip := false
			for chip in [room_summary_occupancy, room_summary_ready, room_summary_state]:
				if chip == null:
					continue
				var chip_rect = screen_rect(chip)
				if has_previous_chip:
					check(previous_chip_rect.end.x <= chip_rect.position.x - 2.0, "online lobby room summary chips keep horizontal separation at %s" % viewport_size)
				previous_chip_rect = chip_rect
				has_previous_chip = true
			for label in [room_summary_occupancy_label, room_summary_ready_label, room_summary_state_label]:
				check(label != null and label.clip_text and label.get_theme_font_size("font_size") >= 11 and relative_luma(label.get_theme_color("font_color")) >= 0.84, "online lobby room summary label is readable and clipped at %s" % viewport_size)
				if label != null:
					var label_rect = screen_rect(label)
					check(summary_rect.grow(1.0).encloses(label_rect), "online lobby room summary label stays inside summary panel at %s" % viewport_size)
					check(label_text_width(label, str(label.text)) <= label_rect.size.x + 1.0, "online lobby room summary label text fits its lane at %s" % viewport_size)
		if roster_title != null:
			check(roster_rect.grow(1.0).encloses(screen_rect(roster_title)) and roster_title.get_theme_font_size("font_size") >= 13 and relative_luma(roster_title.get_theme_color("font_color")) >= 0.88, "online lobby roster title is readable and contained at %s" % viewport_size)
		if log_list_title != null:
			check(log_list_rect.grow(1.0).encloses(screen_rect(log_list_title)) and log_list_title.get_theme_font_size("font_size") >= 13 and relative_luma(log_list_title.get_theme_color("font_color")) >= 0.88, "online lobby log title is readable and contained at %s" % viewport_size)
			if log_count_badge != null:
				check(log_list_rect.grow(1.0).encloses(screen_rect(log_count_badge)), "online lobby log count badge stays inside log panel at %s" % viewport_size)
			if log_latest_button != null and log_unread_label != null:
				check(log_list_rect.grow(1.0).encloses(screen_rect(log_latest_button)) and log_latest_button.tooltip_text.contains("最新"), "online lobby latest-log button stays inside the log header and explains its route at %s" % viewport_size)
				check(log_list_rect.grow(1.0).encloses(screen_rect(log_unread_label)), "online lobby unread-log indicator stays inside the log header at %s" % viewport_size)
		for i in range(4):
			var row = scene.find_child("OnlineLobbyRosterRow_%d" % i, true, false) as Control
			check(row != null, "online lobby roster row %d exists at %s" % [i, viewport_size])
			if row != null:
				var row_rect = screen_rect(row)
				check(roster_rect.grow(1.0).encloses(row_rect), "online lobby roster row %d stays inside roster panel at %s" % [i, viewport_size])
				check(row_rect.size.y >= max(18.0, roster_rect.size.y * 0.14), "online lobby roster row %d keeps readable height at %s" % [i, viewport_size])
				check(row.mouse_filter == Control.MOUSE_FILTER_STOP, "online lobby roster row %d exposes a touch detail target at %s" % [i, viewport_size])
			var name_label = scene.find_child("OnlineLobbyRosterName_%d" % i, true, false) as Label
			var state_label = scene.find_child("OnlineLobbyRosterState_%d" % i, true, false) as Label
			check(name_label != null and state_label != null, "online lobby roster row %d exposes name and state labels at %s" % [i, viewport_size])
			if name_label != null:
				check(name_label.clip_text and name_label.get_theme_font_size("font_size") >= 12 and relative_luma(name_label.get_theme_color("font_color")) >= 0.88, "online lobby roster row %d name is readable and clipped at %s" % [i, viewport_size])
			if state_label != null:
				check(state_label.clip_text and state_label.get_theme_font_size("font_size") >= 11 and relative_luma(state_label.get_theme_color("font_color")) >= 0.84, "online lobby roster row %d state is readable and clipped at %s" % [i, viewport_size])
		if log_scroll != null:
			check(log_list_rect.grow(1.0).encloses(screen_rect(log_scroll)), "online lobby native log scroll stays inside log list panel at %s" % viewport_size)
			check(log_scroll.horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED and log_scroll.vertical_scroll_mode == ScrollContainer.SCROLL_MODE_AUTO and log_scroll.get_v_scroll_bar() != null, "online lobby log uses native touch-scroll with a vertical range at %s" % viewport_size)
		if log_list_text != null:
			check(log_scroll != null and log_list_text.get_parent() == log_scroll, "online lobby log text is owned by the native scroll container at %s" % viewport_size)
			var minimum_log_font := 13 if viewport_size.y <= 560.0 else 14
			check(log_list_text.fit_content and not log_list_text.scroll_active and log_list_text.get_theme_font_size("normal_font_size") >= minimum_log_font and relative_luma(log_list_text.get_theme_color("default_color")) >= 0.90, "online lobby log text stays readable and delegates scrolling to its parent at %s" % viewport_size)
		# Exercise the unread path with a bounded synthetic snapshot, then restore
		# the disconnected fixture so this probe cannot leak room state downstream.
		var saved_room: Dictionary = scene.online_room.duplicate(true)
		var saved_seen: int = int(scene.online_log_seen_count)
		scene.online_room = {"logs": ["第一条", "第二条", "第三条"]}
		scene.online_log_seen_count = 1
		scene.refresh_online_log_navigation()
		check(log_latest_button != null and log_latest_button.text == "最新 2" and log_unread_label != null and log_unread_label.visible and log_unread_label.text == "未读 2", "online lobby exposes an accurate unread-log count at %s" % viewport_size)
		scene.scroll_online_log_to_end()
		check(scene.online_log_seen_count == 3 and log_latest_button != null and log_latest_button.text == "最新" and log_unread_label != null and not log_unread_label.visible, "online lobby latest-log route clears unread state at %s" % viewport_size)
		scene.online_room = saved_room
		scene.online_log_seen_count = saved_seen
		scene.render_room_log()
		scene.refresh_online_log_navigation()
	var feedback_rect := Rect2()
	if feedback != null:
		feedback_rect = screen_rect(feedback)
		check(feedback_rect.position.x >= log_rect.position.x - 1.0 and feedback_rect.end.x <= log_rect.end.x + 1.0, "online feedback strip aligns with the room panel at %s" % viewport_size)
		check(feedback_rect.position.y >= log_rect.end.y + max(6.0, viewport_size.y * 0.012) and feedback_rect.end.y <= viewport_size.y + 0.5, "online feedback strip clears the room panel and stays inside viewport at %s" % viewport_size)
		check(feedback_rect.size.y <= viewport_size.y * 0.064, "online feedback strip stays thin at the bottom edge at %s" % viewport_size)
		check(scene.optional_gpt_illustration_texture("online_feedback_gpt_strip") == null or feedback.find_child("OnlineFeedbackGPTStripTexture", true, false) != null, "online feedback strip consumes GPT v2 texture at %s" % viewport_size)
	check(feedback_text != null and feedback_text_backplate != null and feedback_seal != null, "online feedback strip exposes text safety backplate and status seal at %s" % viewport_size)
	if feedback != null and feedback_text != null and feedback_text_backplate != null:
		var feedback_text_rect = screen_rect(feedback_text)
		var feedback_back_rect = screen_rect(feedback_text_backplate)
		check(feedback_rect.grow(1.0).encloses(feedback_back_rect) and feedback_back_rect.grow(1.0).encloses(feedback_text_rect), "online feedback text stays inside its local backplate at %s" % viewport_size)
		check(feedback_text.clip_text and feedback_text.get_theme_font_size("font_size") >= 12 and relative_luma(feedback_text.get_theme_color("font_color")) >= 0.88, "online feedback text remains readable and clipped at %s" % viewport_size)
		check(feedback_text_rect.end.x <= feedback_rect.position.x + feedback_rect.size.x * 0.78, "online feedback text clears the right ornament lane at %s" % viewport_size)
		if feedback_seal != null:
			check(not rects_overlap(feedback_text_rect, screen_rect(feedback_seal)), "online feedback text clears status seal at %s" % viewport_size)
	var action_rects: Array[Rect2] = []
	for text in ["连接", "创建", "加入", "待连接", "返回菜单"]:
		var button = first_button_with_text(scene, text)
		check(button != null, "online lobby exposes %s action button at %s" % [text, viewport_size])
		if button == null:
			continue
		var rect = screen_rect(button)
		action_rects.append(rect)
		check(rect.size.x >= 96.0 and rect.size.y >= 46.0, "online lobby %s keeps stable touch size at %s" % [text, viewport_size])
		check(rect.position.x >= form_rect.position.x - 1.0 and rect.end.x <= form_rect.end.x + 1.0, "online lobby %s stays inside form panel at %s" % [text, viewport_size])
		check(button.text == text and button.get_theme_font_size("font_size") >= 17, "online lobby %s keeps a readable native label at %s" % [text, viewport_size])
		check_button_face_behind_native_text(button, "online lobby %s button" % text, viewport_size)
		var button_art = button.find_child("LobbyActionButtonArt_%s" % text, true, false) as Control
		var button_glow = button.find_child("LobbyActionButtonGlow_%s" % text, true, false) as Control
		var button_seal = button.find_child("LobbyActionButtonSeal_%s" % text, true, false) as Control
		check(button_art != null and button_glow != null and button_seal != null, "online lobby %s keeps restrained button material art at %s" % [text, viewport_size])
		if button_art != null:
			check(rect.grow(1.0).encloses(screen_rect(button_art)), "online lobby %s button art stays inside the touch target at %s" % [text, viewport_size])
		if button_glow != null:
			var glow_rect = screen_rect(button_glow)
			check(glow_rect.size.x <= rect.size.x * 0.04 and glow_rect.position.x >= rect.position.x + rect.size.x * 0.90, "online lobby %s button glow stays as a right-edge detail at %s" % [text, viewport_size])
		if button_seal != null:
			var button_seal_rect = screen_rect(button_seal)
			check(button_seal_rect.size.x <= rect.size.x * 0.10 and button_seal_rect.size.y <= rect.size.y * 0.22 and button_seal_rect.end.x <= rect.position.x + rect.size.x * 0.19, "online lobby %s button seal stays outside the label lane at %s" % [text, viewport_size])
	for i in range(action_rects.size()):
		for j in range(i + 1, action_rects.size()):
			check(not action_rects[i].intersects(action_rects[j], true), "online lobby action buttons do not overlap at %s" % viewport_size)
	var primary_start = scene.find_child("OnlineLobbyPrimaryStartButton", true, false) as Button
	var secondary_return = scene.find_child("OnlineLobbySecondaryReturnButton", true, false) as Button
	check(primary_start != null and secondary_return != null, "online lobby exposes primary start and secondary return buttons at %s" % viewport_size)
	if primary_start != null and secondary_return != null:
		var primary_start_rect = screen_rect(primary_start)
		var secondary_return_rect = screen_rect(secondary_return)
		check(primary_start_rect.size.x > secondary_return_rect.size.x + 16.0, "online lobby start button has stronger width hierarchy than return at %s" % viewport_size)
		check(primary_start_rect.end.y <= form_rect.end.y - max(12.0, viewport_size.y * 0.025) and secondary_return_rect.end.y <= form_rect.end.y - max(12.0, viewport_size.y * 0.025), "online lobby bottom actions leave a clear form-panel footer at %s" % viewport_size)
		check(primary_start.disabled and primary_start.text == "待连接", "online lobby start button becomes a disabled waiting state before server connection at %s" % viewport_size)
	if status_backplate != null:
		var status_rect = screen_rect(status_backplate)
		check(status_rect.position.x >= form_rect.position.x - 1.0 and status_rect.end.x <= log_rect.position.x + 1.0, "online lobby status backplate stays in the lower left lane at %s" % viewport_size)
		check(status_rect.position.y >= form_rect.end.y + max(6.0, viewport_size.y * 0.012) and status_rect.size.y <= viewport_size.y * 0.064, "online lobby lower status reads as a thin strip below the form panel at %s" % viewport_size)
		if feedback != null:
			var feedback_rect_for_status = screen_rect(feedback)
			check(abs(status_rect.position.y - feedback_rect_for_status.position.y) <= 2.0 and abs(status_rect.size.y - feedback_rect_for_status.size.y) <= 2.0, "online lobby lower status and feedback strips share a calm baseline at %s" % viewport_size)
		if status_label != null:
			var status_label_rect = screen_rect(status_label)
			check(status_rect.grow(1.0).encloses(status_label_rect), "online lobby status label stays inside lower status backplate at %s" % viewport_size)
			check(status_label.clip_text and not str(status_label.text).contains(str(scene.DEFAULT_HOST)) and not str(status_label.text).contains(":"), "online lobby lower status avoids repeating raw server endpoint at %s" % viewport_size)
			check(label_text_width(status_label, str(status_label.text)) <= status_label_rect.size.x + 1.0, "online lobby lower status text fits without truncation at %s" % viewport_size)


func _control_is_subdued_art(node: Control, max_alpha: float) -> bool:
	if node == null:
		return false
	if not node.visible:
		return true
	if node is ColorRect:
		return (node as ColorRect).color.a <= max_alpha + 0.001
	if node is TextureRect:
		return node.modulate.a * node.self_modulate.a <= max_alpha + 0.001
	# Empty Control host (program art removed) counts as subdued.
	return node.modulate.a <= max_alpha + 0.001 or node.get_child_count() == 0


func inherited_canvas_modulate_alpha(node: Node) -> float:
	var alpha := 1.0
	var current := node
	while current != null:
		if current is CanvasItem:
			alpha *= (current as CanvasItem).modulate.a
		current = current.get_parent()
	return alpha


func check_secondary_back_button_art(scene, screen_id: String, viewport_size: Vector2) -> void:
	# r372: route nodes may be Control/TextureRect (GPT plates) — no ColorRect program art required.
	var art = scene.find_child("SecondaryBackButtonArt_%s" % screen_id, true, false) as Control
	var confirm_route = scene.find_child("SecondaryBackConfirmRoute_%s" % screen_id, true, false) as Control
	var confirm_fill = scene.find_child("SecondaryBackConfirmFill_%s" % screen_id, true, false) as Control
	var confirm_gate = scene.find_child("SecondaryBackConfirmGate_%s" % screen_id, true, false) as Control
	check(art != null and confirm_route != null and confirm_fill != null and confirm_gate != null, "secondary back button %s exposes quiet route art at %s" % [screen_id, viewport_size])
	if art != null:
		var back_button = art.get_parent() as Button
		check(back_button != null and back_button.text == "返回", "secondary back button %s keeps its native 返回 label at %s" % [screen_id, viewport_size])
		if back_button != null:
			check_button_face_behind_native_text(back_button, "secondary back button %s" % screen_id, viewport_size)
	if confirm_route != null and confirm_fill != null and confirm_gate != null:
		# Subdued route: either invisible host / low-modulate plate, or legacy low-alpha ColorRect.
		# r372: program color routes removed — empty Control hosts or low-alpha plates are OK.
		var route_ok := not (confirm_route is ColorRect) or _control_is_subdued_art(confirm_route, 0.20)
		var fill_ok := not (confirm_fill is ColorRect) or _control_is_subdued_art(confirm_fill, 0.16)
		var gate_ok := not (confirm_gate is ColorRect) or _control_is_subdued_art(confirm_gate, 0.16)
		check(route_ok and fill_ok and gate_ok, "secondary back button %s keeps center route subdued below label at %s" % [screen_id, viewport_size])
	for i in range(2):
		var confirm_tick = scene.find_child("SecondaryBackConfirmTick_%s_%d" % [screen_id, i], true, false) as Control
		if confirm_tick != null:
			check(_control_is_subdued_art(confirm_tick, 0.12), "secondary back button %s center tick %d stays subdued below label at %s" % [screen_id, i, viewport_size])

func check_rules_layout(scene, viewport_size: Vector2) -> void:
	var codex_front = scene.find_child("RulesCodexFrontPanel", true, false) as Control
	var codex_shadow = scene.find_child("RulesCodex3DCastShadow", true, false) as Control
	var reading_inset = scene.find_child("RulesCodex3DReadingInset", true, false) as Control
	check(codex_front != null and codex_shadow != null and reading_inset == null, "rules exposes one front surface and shadow without a duplicate reading inset at %s" % viewport_size)
	var guide = scene.find_child("RulesGuideArt", true, false) as Control
	var content_backplate = scene.find_child("RulesContentReadabilityBackplate", true, false) as Control
	var content_surface = scene.find_child("RulesContentLowFrequencySurface", true, false) as Control
	var content_scroll = scene.find_child("RulesContentScroll", true, false) as ScrollContainer
	var content_scrollbar = scene.find_child("RulesContentScrollBar", true, false) as VScrollBar
	var scroll_gutter = scene.find_child("RulesContentScrollGutter", true, false) as Control
	var scroll_thumb = scene.find_child("RulesContentScrollThumb", true, false) as Control
	var scroll_hit_target = scene.find_child("RulesContentScrollHitTarget", true, false) as Control
	var content_list = scene.find_child("RulesContentList", true, false) as Control
	var back_button = first_button_with_text(scene, "返回")
	check(guide != null and content_backplate != null and content_scroll != null and content_list != null and back_button != null, "rules screen exposes guide, content backplate, scroll list, and back button at %s" % viewport_size)
	check(content_surface == null, "rules reading content does not add a duplicate full reading surface at %s" % viewport_size)
	if guide == null or content_backplate == null or content_scroll == null or content_list == null:
		return
	var guide_rect = screen_rect(guide)
	var content_rect = screen_rect(content_backplate)
	var scroll_rect = screen_rect(content_scroll)
	var content_list_rect = screen_rect(content_list)
	check(guide_rect.size.y <= viewport_size.y * 0.090, "rules guide stays compact so reading content gets priority at %s" % viewport_size)
	check(content_rect.size.y >= viewport_size.y * 0.765, "rules content backplate uses most of the viewport height at %s" % viewport_size)
	check(guide_rect.end.y <= content_rect.position.y - 4.0, "rules guide clears content backplate at %s" % viewport_size)
	check(content_scroll.clip_contents, "rules content scroll clips only the reading list at %s" % viewport_size)
	check(content_rect.grow(1.0).encloses(scroll_rect), "rules content scroll stays inside the readability backplate at %s" % viewport_size)
	if viewport_size.x <= 960.0:
		check(content_list.get_combined_minimum_size().y >= scroll_rect.size.y + 54.0, "rules content list exposes extra scrollable reading depth on compact viewport at %s" % viewport_size)
	if content_scrollbar != null:
		check(not content_scrollbar.visible and content_scroll.vertical_scroll_mode == ScrollContainer.SCROLL_MODE_SHOW_NEVER, "rules screen hides the default bright scrollbar at %s" % viewport_size)
	if scroll_gutter != null and scroll_thumb != null:
		var gutter_rect = screen_rect(scroll_gutter)
		check(content_rect.grow(1.0).encloses(gutter_rect) and gutter_rect.position.x >= scroll_rect.end.x + 2.0, "rules custom scroll gutter stays outside the text viewport at %s" % viewport_size)
		check(gutter_rect.grow(1.0).encloses(screen_rect(scroll_thumb)), "rules custom scroll thumb stays inside gutter at %s" % viewport_size)
		check(screen_rect(scroll_thumb).size.x <= 16.0, "rules custom scrollbar keeps its narrow visual treatment at %s" % viewport_size)
		if viewport_size.y <= 560.0:
			check(screen_rect(scroll_thumb).size.x >= 8.0, "rules custom scrollbar remains discoverable on compact viewports at %s" % viewport_size)
	check(scroll_hit_target != null, "rules exposes a dedicated transparent scroll hit target at %s" % viewport_size)
	if scroll_hit_target != null:
		var hit_rect = screen_rect(scroll_hit_target)
		check(hit_rect.size.x >= 44.0, "rules scroll hit target keeps at least 44px width at %s" % viewport_size)
		check(scroll_hit_target.mouse_filter == Control.MOUSE_FILTER_STOP, "rules scroll hit target receives pointer and touch input at %s" % viewport_size)
		if scroll_gutter != null:
			check(hit_rect.grow(1.0).encloses(screen_rect(scroll_gutter)), "rules scroll hit target contains the narrow visual gutter at %s" % viewport_size)
	if back_button != null:
		var back_rect = screen_rect(back_button)
		check(not guide_rect.intersects(back_rect, true), "rules back button does not overlap guide at %s" % viewport_size)
		check(back_rect.size.x >= 88.0 and back_rect.size.y >= 44.0, "rules back button keeps a 44px mobile touch height at %s" % viewport_size)
		var back_plate = back_button.find_child("SecondaryBackGptPlate", true, false) as CanvasItem
		var back_rail = back_button.find_child("SecondaryBackGptRail", true, false) as CanvasItem
		check(back_plate == null or back_plate.show_behind_parent, "rules back plate stays behind native exit text at %s" % viewport_size)
		check(back_rail == null or back_rail.show_behind_parent, "rules back rail stays behind native exit text at %s" % viewport_size)
		var back_art = back_button.find_child("SecondaryBackButtonArt_rules", true, false) as CanvasItem
		check(back_art != null and back_art.show_behind_parent, "rules back button keeps authored chrome behind native exit text at %s" % viewport_size)
		check_secondary_back_button_art(scene, "rules", viewport_size)
	var previous_bottom := -1.0
	var rules_section_count = int(scene.RULES_SECTION_COUNT)
	for i in range(rules_section_count):
		var section = scene.find_child("RuleSection_%d" % i, true, false) as Control
		check(section != null, "rules section %d exists at %s" % [i, viewport_size])
		if section == null:
			continue
		var rect = screen_rect(section)
		check(rect.position.x >= scroll_rect.position.x - 1.0 and rect.end.x <= scroll_rect.end.x + 1.0, "rules section %d stays inside the scroll reading lane at %s" % [i, viewport_size])
		check(rect.position.y >= content_list_rect.position.y - 1.0 and rect.end.y <= content_list_rect.end.y + 1.0, "rules section %d stays inside the full scroll content list at %s" % [i, viewport_size])
		check(rect.position.y >= previous_bottom - 0.5, "rules sections remain vertically ordered at %s" % viewport_size)
		if previous_bottom >= 0.0:
			check(rect.position.y >= previous_bottom + 8.0, "rules sections keep readable separation at %s" % viewport_size)
		previous_bottom = rect.end.y
		var marker = section.find_child("RuleSectionMarker", true, false) as Control
		var example_strip = section.find_child("RuleSectionArtStrip_%d" % i, true, false) as Control
		var text_backplate = section.find_child("RuleSectionTextBackplate_%d" % i, true, false) as Control
		var title_label = section.find_child("RuleSectionTitle_%d" % i, true, false) as Label
		var section_depth = section.find_child("RuleSection3DDepthEdge_%d" % i, true, false) as Control
		var example_plinth = section.find_child("RuleSection3DExamplePlinth_%d" % i, true, false) as Control
		var line_labels: Array[Control] = []
		collect_controls_with_name_prefix(section, "RuleSectionLine_", line_labels)
		check(marker != null and example_strip != null and section_depth != null and example_plinth != null, "rules section %d renders physical card depth, marker, and example plinth at %s" % [i, viewport_size])
		check(text_backplate != null, "rules section %d renders text readability backplate at %s" % [i, viewport_size])
		check(title_label != null, "rules section %d exposes named title label at %s" % [i, viewport_size])
		if title_label != null:
			check(title_label.text.begins_with("%02d ·" % (i + 1)) and title_label.tooltip_text != "", "rules section %d exposes numbered title and full-title tooltip at %s" % [i, viewport_size])
		check(line_labels.size() >= 3, "rules section %d exposes named body labels at %s" % [i, viewport_size])
		if text_backplate != null and example_strip != null:
			var text_rect = screen_rect(text_backplate)
			var strip_rect = screen_rect(example_strip)
			check(text_rect.end.x <= strip_rect.position.x - 6.0, "rules section %d text and example lanes do not overlap at %s" % [i, viewport_size])
			check(text_rect.size.x >= rect.size.x * 0.70, "rules section %d keeps a readable text lane beside example art at %s" % [i, viewport_size])
			check(strip_rect.size.x <= rect.size.x * 0.18, "rules section %d keeps example strip compact at %s" % [i, viewport_size])
			check(rect.grow(1.0).encloses(text_rect), "rules section %d text backplate stays inside section frame at %s" % [i, viewport_size])
		if title_label != null:
			check(title_label.clip_text and title_label.get_theme_font_size("font_size") >= 18 and relative_luma(title_label.get_theme_color("font_color")) >= 0.88, "rules section %d title is clipped bright and large enough at %s" % [i, viewport_size])
			if text_backplate != null:
				check(screen_rect(text_backplate).grow(1.0).encloses(screen_rect(title_label)), "rules section %d title stays inside text backplate at %s" % [i, viewport_size])
		for line_control in line_labels:
			var line_label = line_control as Label
			check(line_label != null and line_label.clip_text and line_label.get_theme_font_size("font_size") >= 15 and line_label.text_overrun_behavior == TextServer.OVERRUN_TRIM_ELLIPSIS and relative_luma(line_label.get_theme_color("font_color")) >= 0.90, "rules section %d body text is clipped bright and large enough at %s" % [i, viewport_size])
			if line_label != null and text_backplate != null:
				var line_rect = screen_rect(line_label)
				var text_back_rect = screen_rect(text_backplate)
				check(text_back_rect.grow(1.0).encloses(line_rect), "rules section %d body label %s stays inside text backplate at %s" % [i, line_label.name, viewport_size])
				check(label_text_width(line_label, line_label.text) <= line_rect.size.x + 1.0, "rules section %d body label %s fits without ellipsis at %s" % [i, line_label.name, viewport_size])
		var section_plate = example_strip.find_child("RuleSectionArtGPTPlate_%d" % i, true, false) as Control if example_strip != null else null
		var has_section_plate := section_plate != null
		if has_section_plate:
			# GPT plate carries the full illustration; the clean-panel branch skips the
			# code-drawn example readability panel and native pattern tiles by design.
			var plate_glyph = example_strip.find_child("RuleSectionPathGlyph_%d" % i, true, false) as Control
			check(plate_glyph != null, "rules section %d GPT plate exposes a title glyph at %s" % [i, viewport_size])
		else:
			if example_strip != null:
				var example_panel = example_strip.find_child("RuleSectionExampleReadabilityPanel_%d" % i, true, false) as Control
				check(example_panel != null, "rules section %d example strip has local readability panel at %s" % [i, viewport_size])
			if i == 1 and example_strip != null:
				var pattern_texture = example_strip.find_child("RulesPatternQuadsTexture", true, false) as TextureRect
				check(pattern_texture == null, "rules pattern section uses native runtime tile examples instead of generated teaching strip at %s" % viewport_size)
				for group_id in ["sequence", "triplet", "quad", "pair"]:
					var group = example_strip.find_child("RulePatternExampleGroup_%s" % group_id, true, false) as Control
					var first_tile = example_strip.find_child("RulePatternExampleTile_%s_0" % group_id, true, false) as Control
					check(group != null and first_tile != null, "rules pattern section exposes native %s tile example at %s" % [group_id, viewport_size])
	if scroll_gutter != null and scroll_thumb != null and content_scrollbar != null:
		var gutter_rect = screen_rect(scroll_gutter)
		var thumb_rect = screen_rect(scroll_thumb)
		var max_scroll = maxf(0.0, content_scrollbar.max_value - content_scrollbar.page)
		check(scroll_thumb.mouse_filter == Control.MOUSE_FILTER_IGNORE and scroll_hit_target != null and scroll_hit_target.mouse_filter == Control.MOUSE_FILTER_STOP and scroll_hit_target.mouse_default_cursor_shape == Control.CURSOR_VSIZE, "rules custom scrollbar routes vertical drag input through its wide hit target at %s" % viewport_size)
		check(thumb_rect.size.y <= gutter_rect.size.y + 1.0, "rules custom thumb stays within its gutter height at %s" % viewport_size)
		if max_scroll > 1.0:
			check(thumb_rect.size.y < gutter_rect.size.y - 2.0, "rules custom thumb reflects scrollable content depth at %s" % viewport_size)
			var last_section = scene.find_child("RuleSection_%d" % (rules_section_count - 1), true, false) as Control
			if last_section != null:
				check(max_scroll >= screen_rect(last_section).end.y - scroll_rect.end.y - 1.0, "rules viewport can reach the final section at %s" % viewport_size)
			content_scrollbar.value = max_scroll
			scene.sync_rules_scroll_thumb(content_scroll, scroll_thumb)
			var end_thumb_rect = screen_rect(scroll_thumb)
			check(end_thumb_rect.end.y >= gutter_rect.end.y - max(2.0, gutter_rect.size.y * 0.06), "rules custom thumb reaches the gutter end at full scroll at %s" % viewport_size)

func check_achievements_layout(scene, viewport_size: Vector2) -> void:
	check_secondary_back_button_art(scene, "achievements", viewport_size)
	var gallery_front = scene.find_child("AchievementGalleryFrontPanel", true, false) as Control
	var gallery_rear = scene.find_child("AchievementGallery3DRearShell", true, false) as Control
	var gallery_shadow = scene.find_child("AchievementGallery3DCastShadow", true, false) as Control
	var gallery_inset = scene.find_child("AchievementGallery3DListInset", true, false) as Control
	check(gallery_front != null and gallery_rear != null and gallery_shadow != null and gallery_inset != null, "achievements exposes a physical gallery front, rear shell, shadow, and list inset at %s" % viewport_size)
	var scroll = scene.find_child("AchievementsScroll", true, false) as ScrollContainer
	var scrollbar = scene.find_child("AchievementsScrollBar", true, false) as VScrollBar
	var scroll_gutter = scene.find_child("AchievementsScrollGutter", true, false) as Control
	var scroll_thumb = scene.find_child("AchievementsScrollThumb", true, false) as Control
	var grid = scene.find_child("AchievementsGrid", true, false) as Control
	var lane = scene.find_child("AchievementRowReadabilityLane", true, false) as Control
	var bottom_spacer = scene.find_child("AchievementsBottomSafeSpacer", true, false) as Control
	var bottom_fade = scene.find_child("AchievementsBottomFadePanel", true, false) as Control
	var gallery_texture = scene.find_child("AchievementGPTGalleryTexture", true, false) as CanvasItem
	check(scroll != null and scrollbar != null and scroll_gutter != null and scroll_thumb != null and grid != null and lane != null and bottom_spacer != null and bottom_fade != null, "achievements screen exposes scroll lane custom gutter safe spacer and bottom fade at %s" % viewport_size)
	check(gallery_texture == null or gallery_texture.modulate.a <= 0.26, "achievements generated gallery remains a subdued backdrop below native rows at %s" % viewport_size)
	if scroll == null or lane == null:
		return
	var scroll_rect = screen_rect(scroll)
	var lane_rect = screen_rect(lane)
	check(scroll.clip_contents, "achievements scroll clips row content at %s" % viewport_size)
	check(lane_rect.grow(1.0).encloses(scroll_rect), "achievements scroll stays inside readability lane at %s" % viewport_size)
	check(scroll_rect.end.y <= viewport_size.y * 0.890 + 1.0, "achievements scroll leaves a bottom safe band at %s" % viewport_size)
	var gutter_rect := Rect2()
	if scrollbar != null and scroll_gutter != null and scroll_thumb != null:
		gutter_rect = screen_rect(scroll_gutter)
		var thumb_rect = screen_rect(scroll_thumb)
		var scrollbar_rect = screen_rect(scrollbar)
		check(not scrollbar.visible and scroll.vertical_scroll_mode == ScrollContainer.SCROLL_MODE_SHOW_NEVER, "achievements hides default bright system scrollbar at %s" % viewport_size)
		check(gutter_rect.size.x <= max(14.0, viewport_size.x * 0.016) and gutter_rect.position.x >= scroll_rect.end.x + 2.0, "achievements custom scrollbar gutter is narrow and outside rows at %s" % viewport_size)
		check(gutter_rect.grow(1.0).encloses(thumb_rect), "achievements custom scrollbar thumb stays inside gutter at %s" % viewport_size)
		check(not rects_overlap(scrollbar_rect, gutter_rect) or not scrollbar.visible, "achievements hidden system scrollbar does not become the visible gutter at %s" % viewport_size)
		var gutter_style = scroll_gutter.get_theme_stylebox("panel") as StyleBoxFlat
		var thumb_style = scroll_thumb.get_theme_stylebox("panel") as StyleBoxFlat
		check(gutter_style != null and thumb_style != null and relative_luma(gutter_style.bg_color) <= 0.20 and relative_luma(thumb_style.bg_color) <= 0.54, "achievements custom scrollbar avoids default bright white styling at %s" % viewport_size)
	if bottom_spacer != null:
		check(bottom_spacer.custom_minimum_size.y >= 72.0, "achievements list has enough bottom spacer for final rows at %s" % viewport_size)
	if bottom_fade != null:
		var fade_rect = screen_rect(bottom_fade)
		check(fade_rect.position.y >= scroll_rect.end.y - 2.0, "achievements bottom fade begins below the scroll viewport at %s" % viewport_size)
	var dashboard = scene.find_child("AchievementsDashboardArt", true, false) as Control
	var progress_label = scene.find_child("AchievementsProgressLabel", true, false) as Label
	var progress_detail = scene.find_child("AchievementsProgressDetailLabel", true, false) as Label
	var medal_glyph = scene.find_child("AchievementsMedalGlyph", true, false) as Label
	var progress_rail = scene.find_child("AchievementsProgressRail", true, false) as Control
	var progress_fill = scene.find_child("AchievementsProgressFill", true, false) as Control
	var progress_gate = scene.find_child("AchievementsProgressGate", true, false) as Control
	var unlock_route = scene.find_child("AchievementsUnlockRoute", true, false) as Control
	var unlock_fill = scene.find_child("AchievementsUnlockFill", true, false) as Control
	var unlock_source = scene.find_child("AchievementsUnlockSource", true, false) as Control
	var summary_backplate = scene.find_child("AchievementsSummaryTextBackplate", true, false) as Control
	var medal_node = scene.find_child("AchievementsMedalNode", true, false) as Control
	var dashboard_depth = scene.find_child("AchievementsDashboard3DDepthEdge", true, false) as Control
	var dashboard_pedestal = scene.find_child("AchievementsDashboard3DMedalPedestal", true, false) as Control
	check(dashboard != null and progress_label != null and progress_detail != null and medal_glyph != null and progress_rail != null and progress_fill != null and progress_gate != null and unlock_route != null and unlock_fill != null and unlock_source != null and summary_backplate != null and medal_node != null and dashboard_depth != null and dashboard_pedestal != null, "achievements dashboard exposes readable summary, physical medal pedestal, and progress parts at %s" % viewport_size)
	if dashboard != null:
		var dashboard_rect = screen_rect(dashboard)
		for node in [progress_label, progress_detail, medal_glyph, progress_rail, progress_gate, summary_backplate, medal_node]:
			if node != null:
				check(dashboard_rect.grow(1.0).encloses(screen_rect(node)), "achievements dashboard part %s stays inside summary card at %s" % [node.name, viewport_size])
		if progress_fill != null and progress_rail != null:
			check(screen_rect(progress_rail).grow(1.0).encloses(screen_rect(progress_fill)), "achievements progress fill stays inside rail at %s" % viewport_size)
		if summary_backplate != null and progress_label != null and progress_detail != null:
			var summary_back_rect = screen_rect(summary_backplate)
			check(summary_back_rect.grow(1.0).encloses(screen_rect(progress_label)) and summary_back_rect.grow(1.0).encloses(screen_rect(progress_detail)), "achievements summary text stays on its local backplate at %s" % viewport_size)
		if progress_rail != null and progress_label != null and progress_detail != null:
			check(screen_rect(progress_label).end.y <= screen_rect(progress_detail).position.y + 2.0, "achievements summary labels keep vertical order at %s" % viewport_size)
			check(screen_rect(progress_detail).end.y <= screen_rect(progress_rail).position.y + 2.0, "achievements progress rail clears summary text at %s" % viewport_size)
		if progress_rail != null and medal_node != null:
			check(screen_rect(progress_rail).end.x <= screen_rect(medal_node).position.x - 8.0, "achievements progress rail clears reward medal node at %s" % viewport_size)
		if progress_rail != null and progress_fill != null and progress_gate != null and unlock_route != null and unlock_fill != null and unlock_source != null:
			check((not (progress_rail is ColorRect) or _control_is_subdued_art(progress_rail, 0.45)) and (not (progress_fill is ColorRect) or _control_is_subdued_art(progress_fill, 0.45)) and (not (progress_gate is ColorRect) or _control_is_subdued_art(progress_gate, 0.45)), "achievements dashboard progress ornament stays subdued behind text at %s" % viewport_size)
			check((not (unlock_route is ColorRect) or _control_is_subdued_art(unlock_route, 0.40)) and (not (unlock_fill is ColorRect) or _control_is_subdued_art(unlock_fill, 0.40)) and (not (unlock_source is ColorRect) or _control_is_subdued_art(unlock_source, 0.40)), "achievements dashboard unlock ornament stays subdued behind text at %s" % viewport_size)
	if progress_label != null and progress_detail != null:
		check(progress_label.clip_text and progress_label.get_theme_font_size("font_size") >= 17 and relative_luma(progress_label.get_theme_color("font_color")) >= 0.86, "achievements progress label stays readable at %s" % viewport_size)
		check(progress_detail.clip_text and progress_detail.get_theme_font_size("font_size") >= 14 and relative_luma(progress_detail.get_theme_color("font_color")) >= 0.80, "achievements progress detail stays readable at %s" % viewport_size)
	if medal_glyph != null:
		check(medal_glyph.get_theme_font_size("font_size") >= 22 and relative_luma(medal_glyph.get_theme_color("font_color")) >= 0.86 and medal_glyph.get_theme_color("font_color").a >= 0.90, "achievements medal glyph stays bright at %s" % viewport_size)
	var visible_rows := 0
	for key in scene.achievements.keys():
		var row = scene.find_child("AchievementRow_%s" % str(key), true, false) as Control
		if row == null:
			continue
		var row_rect = screen_rect(row)
		var row_depth = scene.find_child("AchievementRow3DDepthEdge_%s" % str(key), true, false) as Control
		var medal_pedestal = scene.find_child("AchievementRow3DMedalPedestal_%s" % str(key), true, false) as Control
		check(row_depth != null and medal_pedestal != null, "achievement row %s exposes physical depth and medal pedestal at %s" % [str(key), viewport_size])
		var overlap = vertical_overlap(row_rect, scroll_rect)
		if overlap <= 1.0:
			continue
		visible_rows += 1
		check(overlap >= row_rect.size.y - 1.0, "achievement row %s is fully visible when it intersects the scroll viewport at %s" % [str(key), viewport_size])
		check(scroll_rect.grow(1.0).encloses(row_rect), "achievement row %s stays within the scroll viewport at %s" % [str(key), viewport_size])
		check(row_rect.size.y >= 80.0, "achievement row %s keeps enough vertical room for separated goal and progress lanes at %s" % [str(key), viewport_size])
		if scrollbar != null and scroll_gutter != null and scroll_thumb != null:
			var row_name = scene.find_child("AchievementRowName_%s" % str(key), true, false) as Label
			var row_goal = scene.find_child("AchievementRowGoal_%s" % str(key), true, false) as Label
			var row_goal_back = scene.find_child("AchievementRowGoalBackplate_%s" % str(key), true, false) as Control
			var row_progress_text = scene.find_child("AchievementRowProgressText_%s" % str(key), true, false) as Label
			var row_progress_back = scene.find_child("AchievementRowProgressTextBackplate_%s" % str(key), true, false) as Control
			var row_progress_rail = row.find_child("AchievementRowProgressRail", true, false) as Control
			var row_state = scene.find_child("AchievementRowState_%s" % str(key), true, false) as Label
			for node in [row_name, row_goal, row_progress_text, row_state]:
				if node != null:
					check(not rects_overlap(screen_rect(node), gutter_rect), "achievement row %s text clears custom scrollbar gutter at %s" % [str(key), viewport_size])
			check(row_name != null and row_goal != null and row_goal_back != null and row_progress_text != null and row_progress_back != null and row_progress_rail != null and row_state != null, "achievement row %s exposes separated name goal backplate progress lane and state at %s" % [str(key), viewport_size])
			if row_name != null and row_goal != null and row_state != null:
				check(row_name.get_theme_font_size("font_size") >= 16 and row_goal.get_theme_font_size("font_size") >= 13 and row_state.get_theme_font_size("font_size") >= 13, "achievement row %s uses scan-friendly name goal and state fonts at %s" % [str(key), viewport_size])
				check(relative_luma(row_goal.get_theme_color("font_color")) >= 0.72 and relative_luma(row_state.get_theme_color("font_color")) >= 0.86, "achievement row %s goal and state labels keep readable contrast at %s" % [str(key), viewport_size])
			if row_goal_back != null and row_goal != null:
				check(row_rect.grow(1.0).encloses(screen_rect(row_goal_back)) and screen_rect(row_goal_back).grow(1.0).encloses(screen_rect(row_goal)), "achievement row %s keeps goal text on a local readability backplate at %s" % [str(key), viewport_size])
			if row_progress_text != null and row_progress_back != null:
				var progress_back_rect = screen_rect(row_progress_back)
				check(row_rect.grow(1.0).encloses(progress_back_rect) and progress_back_rect.grow(1.0).encloses(screen_rect(row_progress_text)), "achievement row %s keeps progress text inside a compact chip at %s" % [str(key), viewport_size])
				check(row_progress_text.get_theme_font_size("font_size") >= 13 and row_progress_text.clip_text and row_progress_text.text_overrun_behavior == TextServer.OVERRUN_TRIM_ELLIPSIS, "achievement row %s progress chip text remains readable and clipped at %s" % [str(key), viewport_size])
				check(label_text_width(row_progress_text, row_progress_text.text) <= screen_rect(row_progress_text).size.x - 2.0, "achievement row %s progress chip text fits its lane at %s" % [str(key), viewport_size])
				if row_goal != null:
					check(not rects_overlap(progress_back_rect.grow(-1.0), screen_rect(row_goal).grow(-1.0)), "achievement row %s progress chip clears goal text at %s" % [str(key), viewport_size])
					check(progress_back_rect.position.y >= screen_rect(row_goal).end.y + 4.0, "achievement row %s progress chip sits below the goal line at %s" % [str(key), viewport_size])
				if row_state != null:
					check(not rects_overlap(progress_back_rect.grow(-1.0), screen_rect(row_state).grow(-1.0)), "achievement row %s progress chip clears state text at %s" % [str(key), viewport_size])
				if row_progress_rail != null and row_goal != null and row_state != null:
					var rail_rect = screen_rect(row_progress_rail)
					check(rail_rect.position.y >= screen_rect(row_goal).end.y + 4.0, "achievement row %s progress rail sits below the goal line at %s" % [str(key), viewport_size])
					check(rail_rect.end.x <= screen_rect(row_state).position.x - 8.0, "achievement row %s progress rail clears the state badge lane at %s" % [str(key), viewport_size])
	check(visible_rows >= 3, "achievements screen keeps several complete rows visible at %s" % viewport_size)
	var locked_name = scene.find_child("AchievementRowName_thirteen_orphans", true, false) as Label
	var locked_goal = scene.find_child("AchievementRowGoal_thirteen_orphans", true, false) as Label
	var locked_progress_text = scene.find_child("AchievementRowProgressText_thirteen_orphans", true, false) as Label
	var locked_progress_back = scene.find_child("AchievementRowProgressTextBackplate_thirteen_orphans", true, false) as Control
	var locked_goal_back = scene.find_child("AchievementRowGoalBackplate_thirteen_orphans", true, false) as Control
	var locked_state = scene.find_child("AchievementRowState_thirteen_orphans", true, false) as Label
	var locked_route = scene.find_child("AchievementRowLockedRoute_thirteen_orphans", true, false) as Control
	var locked_status_icon = scene.find_child("AchievementRowStatusIcon_thirteen_orphans", true, false) as Control
	var locked_seal = scene.find_child("AchievementRowSeal_thirteen_orphans", true, false) as Control
	check(locked_name != null and locked_goal != null and locked_goal_back != null and locked_progress_text != null and locked_state != null and locked_route != null and locked_status_icon != null, "locked achievement row exposes readable state parts at %s" % viewport_size)
	if locked_name != null and locked_goal != null and locked_progress_text != null and locked_state != null:
		check(relative_luma(locked_name.get_theme_color("font_color")) >= 0.82 and relative_luma(locked_state.get_theme_color("font_color")) >= 0.86, "locked achievement text keeps readable contrast at %s" % viewport_size)
		check(relative_luma(locked_goal.get_theme_color("font_color")) >= 0.66 and relative_luma(locked_progress_text.get_theme_color("font_color")) >= 0.74, "locked achievement helper text keeps readable contrast at %s" % viewport_size)
		check(locked_name.clip_text and locked_goal.clip_text and locked_progress_text.clip_text and locked_state.clip_text, "locked achievement labels clip safely at %s" % viewport_size)
		check(locked_goal.text.begins_with("目标：") and locked_progress_text.text == "进度 0/1", "locked achievement exposes goal and truthful completion state at %s" % viewport_size)
		var five_progress = scene.find_child("AchievementRowProgressText_five_wins", true, false) as Label
		check(five_progress != null and five_progress.text == "进度 3/5", "cumulative five-win achievement exposes live 3/5 progress at %s" % viewport_size)
		check(not rects_overlap(screen_rect(locked_name), screen_rect(locked_state)), "locked achievement name and state chip text stay separated at %s" % viewport_size)
		check(screen_rect(locked_name).get_center().y < screen_rect(locked_goal).get_center().y, "locked achievement name stays visually above goal text at %s" % viewport_size)
		if locked_goal_back != null:
			check(screen_rect(locked_goal_back).grow(1.0).encloses(screen_rect(locked_goal)), "locked achievement goal text stays on a local readability backplate at %s" % viewport_size)
		if locked_progress_back != null:
			check(screen_rect(locked_progress_back).grow(1.0).encloses(screen_rect(locked_progress_text)), "locked achievement progress text stays inside progress chip at %s" % viewport_size)
			check(not rects_overlap(screen_rect(locked_progress_back).grow(-1.0), screen_rect(locked_goal).grow(-1.0)), "locked achievement progress chip clears goal text at %s" % viewport_size)
			check(screen_rect(locked_progress_back).position.y >= screen_rect(locked_goal).end.y + 4.0, "locked achievement progress chip sits below goal text at %s" % viewport_size)
	if locked_status_icon != null:
		var icon_color = locked_status_icon.get_theme_color("font_color") if locked_status_icon is Label else locked_status_icon.modulate
		check(relative_luma(icon_color) >= 0.82 and icon_color.a >= 0.90, "locked achievement status icon stays visible at %s" % viewport_size)
	if locked_seal != null and locked_state != null and locked_status_icon != null:
		var locked_seal_rect = screen_rect(locked_seal)
		check(locked_seal_rect.grow(1.0).encloses(screen_rect(locked_state)) and locked_seal_rect.grow(1.0).encloses(screen_rect(locked_status_icon)), "locked achievement status text stays inside compact seal at %s" % viewport_size)

func check_stats_layout(scene, viewport_size: Vector2) -> void:
	check_secondary_back_button_art(scene, "stats", viewport_size)
	var console_front = scene.find_child("StatsConsoleFrontPanel", true, false) as Control
	var console_rear = scene.find_child("StatsConsole3DRearShell", true, false) as Control
	var console_shadow = scene.find_child("StatsConsole3DCastShadow", true, false) as Control
	var data_inset = scene.find_child("StatsConsole3DDataInset", true, false) as Control
	check(console_front != null and console_rear != null and console_shadow != null and data_inset != null, "stats exposes a physical console front, rear shell, shadow, and data inset at %s" % viewport_size)
	var lane = scene.find_child("StatsRowReadabilityLane", true, false) as Control
	var rows = scene.find_child("StatsRows", true, false) as Control
	var dash = scene.find_child("StatsDashboardArt", true, false) as Control
	var backplate = scene.find_child("StatsReadabilityBackplate", true, false) as Control
	check(lane != null and rows != null and dash != null and backplate != null, "stats screen exposes dashboard rows and readability plates at %s" % viewport_size)
	if lane == null or rows == null:
		return
	var lane_rect = screen_rect(lane)
	var rows_rect = screen_rect(rows)
	check(lane_rect.grow(1.0).encloses(rows_rect), "stats rows stay inside readability lane at %s" % viewport_size)
	check(rows_rect.end.y <= viewport_size.y * 0.925 + 1.0, "stats rows leave a bottom safe band at %s" % viewport_size)
	var stat_labels := ["总场次", "胜场", "胜率", "累计净分", "单局最佳", "总手牌数"]
	var previous_bottom := -1.0
	for label_text in stat_labels:
		var row = scene.find_child("StatsRow_%s" % label_text, true, false) as Control
		var name_label = scene.find_child("StatsRowLabel_%s" % label_text, true, false) as Label
		var value_label = scene.find_child("StatsRowValueLabel_%s" % label_text, true, false) as Label
		var value_panel = scene.find_child("StatsRowValuePanel_%s" % label_text, true, false) as Control
		var row_depth = scene.find_child("StatsRow3DDepthEdge_%s" % label_text, true, false) as Control
		var icon_plinth = scene.find_child("StatsRow3DIconPlinth_%s" % label_text, true, false) as Control
		check(row != null and name_label != null and value_label != null and value_panel != null and row_depth != null and icon_plinth != null, "stats row %s exposes readable physical data-slot parts at %s" % [label_text, viewport_size])
		if row == null:
			continue
		var row_rect = screen_rect(row)
		check(lane_rect.grow(1.0).encloses(row_rect), "stats row %s stays inside readability lane at %s" % [label_text, viewport_size])
		var stats_row_cap := 104.0 if viewport_size.x >= 1600.0 else 56.0
		check(row_rect.size.y >= 40.0 and row_rect.size.y <= stats_row_cap, "stats row %s keeps a complete readable height at %s" % [label_text, viewport_size])
		if previous_bottom >= 0.0:
			check(row_rect.position.y >= previous_bottom + 4.0, "stats row %s keeps readable vertical separation at %s" % [label_text, viewport_size])
		previous_bottom = row_rect.end.y
		if name_label != null and value_label != null and value_panel != null:
			var name_rect = screen_rect(name_label)
			var value_rect = screen_rect(value_label)
			var panel_rect = screen_rect(value_panel)
			check(row_rect.grow(1.0).encloses(name_rect) and row_rect.grow(1.0).encloses(value_rect), "stats row %s labels stay inside row at %s" % [label_text, viewport_size])
			check(panel_rect.grow(1.0).encloses(value_rect), "stats row %s value uses local backplate at %s" % [label_text, viewport_size])
			check(name_label.clip_text and value_label.clip_text, "stats row %s labels clip safely at %s" % [label_text, viewport_size])
			check(relative_luma(name_label.get_theme_color("font_color")) >= 0.88 and relative_luma(value_label.get_theme_color("font_color")) >= 0.90, "stats row %s text keeps readable contrast at %s" % [label_text, viewport_size])
	var chip_ids := ["winrate", "games", "best"]
	var narrative = scene.find_child("StatsSummaryNarrativePanel", true, false) as Control
	var narrative_title = scene.find_child("StatsSummaryNarrativeTitle", true, false) as Label
	var narrative_body = scene.find_child("StatsSummaryNarrativeBody", true, false) as Label
	var narrative_meta = scene.find_child("StatsSummaryNarrativeMeta", true, false) as Label
	var narrative_rail = scene.find_child("StatsSummaryNarrativeRail", true, false) as Control
	var dashboard_depth = scene.find_child("StatsDashboard3DDepthEdge", true, false) as Control
	check(narrative != null and narrative_title != null and narrative_body != null and narrative_meta != null and narrative_rail != null and dashboard_depth != null, "stats dashboard exposes physical depth and left narrative summary panel at %s" % viewport_size)
	if dash != null and narrative != null:
		check(screen_rect(dash).grow(1.0).encloses(screen_rect(narrative)), "stats narrative summary stays inside dashboard at %s" % viewport_size)
	if narrative != null and narrative_title != null and narrative_body != null and narrative_meta != null and narrative_rail != null:
		var narrative_rect = screen_rect(narrative)
		check(narrative_rect.size.x >= 65.0 and narrative_rect.size.y >= 42.0, "stats narrative summary keeps usable compact dimensions at %s" % viewport_size)
		check(narrative_rect.grow(1.0).encloses(screen_rect(narrative_title)) and narrative_rect.grow(1.0).encloses(screen_rect(narrative_body)) and narrative_rect.grow(1.0).encloses(screen_rect(narrative_meta)) and narrative_rect.grow(1.0).encloses(screen_rect(narrative_rail)), "stats narrative summary text and rail stay inside panel at %s" % viewport_size)
		check(narrative_title.clip_text and narrative_body.clip_text and narrative_meta.clip_text, "stats narrative summary labels clip safely at %s" % viewport_size)
		check(relative_luma(narrative_title.get_theme_color("font_color")) >= 0.86 and relative_luma(narrative_body.get_theme_color("font_color")) >= 0.90 and relative_luma(narrative_meta.get_theme_color("font_color")) >= 0.70, "stats narrative summary labels stay readable at %s" % viewport_size)
	for chip_id in chip_ids:
		var chip = scene.find_child("StatsSummaryChip_%s" % chip_id, true, false) as Control
		var value = scene.find_child("StatsSummaryValue_%s" % chip_id, true, false) as Label
		var caption = scene.find_child("StatsSummaryCaption_%s" % chip_id, true, false) as Label
		var chip_depth = scene.find_child("StatsSummary3DDepthEdge_%s" % chip_id, true, false) as Control
		check(chip != null and value != null and caption != null and chip_depth != null, "stats summary chip %s exposes physical depth, value, and caption at %s" % [chip_id, viewport_size])
		if dash != null and chip != null:
			check(screen_rect(dash).grow(1.0).encloses(screen_rect(chip)), "stats summary chip %s stays inside dashboard at %s" % [chip_id, viewport_size])
		if chip != null and value != null and caption != null:
			var chip_rect = screen_rect(chip)
			if narrative != null:
				check(not chip_rect.intersects(screen_rect(narrative)), "stats summary chip %s does not overlap left narrative summary at %s" % [chip_id, viewport_size])
			check(chip_rect.grow(1.0).encloses(screen_rect(value)) and chip_rect.grow(1.0).encloses(screen_rect(caption)), "stats summary chip %s keeps text inside its backplate at %s" % [chip_id, viewport_size])
			check(value.clip_text and caption.clip_text and relative_luma(value.get_theme_color("font_color")) >= 0.90 and relative_luma(caption.get_theme_color("font_color")) >= 0.86, "stats summary chip %s text stays clipped and readable at %s" % [chip_id, viewport_size])
			if chip_id == "best":
				check(str(value.text).ends_with("分"), "stats best summary chip includes score unit at %s" % viewport_size)
				check(label_text_width(value, str(value.text)) <= screen_rect(value).size.x + 1.0, "stats best summary chip unit fits without truncation at %s" % viewport_size)

func check_shop_layout(scene, viewport_size: Vector2) -> void:
	check_secondary_back_button_art(scene, "shop", viewport_size)
	var cabinet_front = scene.find_child("ShopCabinetFrontPanel", true, false) as Control
	var cabinet_rear = scene.find_child("ShopCabinet3DRearShell", true, false) as Control
	var cabinet_shadow = scene.find_child("ShopCabinet3DCastShadow", true, false) as Control
	var display_shell = scene.find_child("ShopDisplayCabinet3DShell", true, false) as Control
	check(cabinet_front != null and cabinet_rear == null and cabinet_shadow != null and display_shell != null, "shop exposes one front cabinet surface without a duplicate rear shell at %s" % viewport_size)
	var vault_texture = scene.find_child("ShopGPTVaultTexture", true, false) as CanvasItem
	check(vault_texture == null or vault_texture.modulate.a <= 0.03, "shop full-page vault texture stays below the reading surfaces at %s" % viewport_size)
	var item_ids := ["swap_card", "peek_card", "lucky_charm", "double_coins"]
	var scroll = scene.find_child("ShopItemsScroll", true, false) as ScrollContainer
	var scrollbar = scene.find_child("ShopItemsScrollBar", true, false) as VScrollBar
	var scroll_gutter = scene.find_child("ShopItemsScrollGutter", true, false) as Control
	var scroll_thumb = scene.find_child("ShopItemsScrollThumb", true, false) as Control
	var content = scene.find_child("ShopItemsContent", true, false) as Control
	var footer_panel = scene.find_child("ShopCabinetFooterPanel", true, false) as Control
	var footer_title = scene.find_child("ShopCabinetFooterTitle", true, false) as Label
	var footer_body = scene.find_child("ShopCabinetFooterBody", true, false) as Label
	var footer_inventory = scene.find_child("ShopCabinetFooterInventoryBadge", true, false) as Control
	var footer_state = scene.find_child("ShopCabinetFooterStateBadge", true, false) as Control
	var row_rects: Array[Rect2] = []
	check(scroll != null and scrollbar != null and scroll_gutter != null and scroll_thumb != null and content != null, "shop exposes named item scroll content and custom scrollbar gutter at %s" % viewport_size)
	check(footer_panel != null and footer_title != null and footer_body != null and footer_inventory != null and footer_state != null, "shop exposes cabinet footer information panel at %s" % viewport_size)
	for meter_kind in ["coins", "gems"]:
		var meter_texture = scene.find_child("ShopCurrencyMeterPanelTexture_%s" % meter_kind, true, false) as CanvasItem
		check(meter_texture == null or meter_texture.modulate.a <= 0.12, "shop currency %s generated meter plate stays behind native values at %s" % [meter_kind, viewport_size])
	for item_id in item_ids:
		var row = scene.find_child("ShopItemRow_%s" % item_id, true, false) as Control
		var charm_texture = scene.find_child("ShopItemCharmTexture_%s" % item_id, true, false) as TextureRect
		var native_charm = scene.find_child("ShopItemNativeCharm_%s" % item_id, true, false) as Control
		var name_label = scene.find_child("ShopItemName_%s" % item_id, true, false) as Label
		var desc_label = scene.find_child("ShopItemDescription_%s" % item_id, true, false) as Label
		var text_plate = scene.find_child("ShopItemTextReadabilityPanel_%s" % item_id, true, false) as Control
		var count_badge = scene.find_child("ShopItemCountBadge_%s" % item_id, true, false) as Control
		var buy_button = scene.find_child("ShopItemBuyButton_%s" % item_id, true, false) as Control
		var buy_command = scene.find_child("ShopBuyButtonCommand_%s" % item_id, true, false) as Label
		var buy_price = scene.find_child("ShopBuyButtonPrice_%s" % item_id, true, false) as Label
		var row_depth = scene.find_child("ShopItem3DDepthEdge_%s" % item_id, true, false) as Control
		var charm_plinth = scene.find_child("ShopItem3DCharmPlinth_%s" % item_id, true, false) as Control
		var row_readability = row.find_child("ShopItemRowLowFrequencyPlate", true, false) as TextureRect if row != null else null
		var row_generated_plate = row.find_child("ShopItemRowGptPlate", true, false) as CanvasItem if row != null else null
		check(row != null, "shop row %s exists at %s" % [item_id, viewport_size])
		check(row_readability != null, "shop row %s exposes an authored low-frequency reading surface at %s" % [item_id, viewport_size])
		if row_readability != null:
			var row_source = (row_readability.texture as AtlasTexture).atlas if row_readability.texture is AtlasTexture else row_readability.texture
			check(row_source != null and str(row_source.resource_path).ends_with("ui_dark_scrim.png") and row_readability.self_modulate.a >= 0.45 and row_readability.self_modulate.a <= 0.75, "shop row %s uses a subdued low-frequency bitmap center crop at %s" % [item_id, viewport_size])
		check(row_generated_plate == null or row_generated_plate.modulate.a <= 0.05, "shop row %s keeps high-frequency generated art at edge-level alpha at %s" % [item_id, viewport_size])
		check(row_depth != null and charm_plinth != null, "shop row %s exposes a physical shelf edge and charm plinth at %s" % [item_id, viewport_size])
		if row != null:
			row_rects.append(screen_rect(row))
		check(charm_texture != null, "shop row %s consumes GPT charm texture at %s" % [item_id, viewport_size])
		check(native_charm == null, "shop row %s skips native fallback when transparent GPT charm is available at %s" % [item_id, viewport_size])
		check(name_label != null and desc_label != null and text_plate != null, "shop row %s exposes readable text parts at %s" % [item_id, viewport_size])
		if row != null and charm_texture != null:
			var charm_row_rect = screen_rect(row)
			var texture_rect = screen_rect(charm_texture)
			check(charm_row_rect.grow(1.0).encloses(texture_rect), "shop charm texture %s stays inside its row at %s" % [item_id, viewport_size])
		if row != null and name_label != null and desc_label != null and text_plate != null:
			var text_row_rect = screen_rect(row)
			var name_rect = screen_rect(name_label)
			var desc_rect = screen_rect(desc_label)
			var plate_rect = screen_rect(text_plate)
			check(text_row_rect.grow(1.0).encloses(name_rect) and text_row_rect.grow(1.0).encloses(desc_rect), "shop row %s keeps labels inside row bounds at %s" % [item_id, viewport_size])
			check(plate_rect.grow(1.0).encloses(name_rect) and plate_rect.grow(1.0).encloses(desc_rect), "shop row %s uses local text readability backplate at %s" % [item_id, viewport_size])
			check(inherited_canvas_modulate_alpha(name_label) >= 0.98 and inherited_canvas_modulate_alpha(desc_label) >= 0.98, "shop row %s keeps text opacity independent from decorative plate alpha at %s" % [item_id, viewport_size])
			check(name_label.clip_text and desc_label.clip_text, "shop row %s clips name and description safely at %s" % [item_id, viewport_size])
			check(relative_luma(name_label.get_theme_color("font_color")) >= 0.90 and relative_luma(desc_label.get_theme_color("font_color")) >= 0.86, "shop row %s keeps text contrast readable at %s" % [item_id, viewport_size])
			if charm_texture != null:
				check(not rects_overlap(name_rect, screen_rect(charm_texture)) and not rects_overlap(desc_rect, screen_rect(charm_texture)), "shop row %s text does not overlap charm art at %s" % [item_id, viewport_size])
			if count_badge != null:
				check(not rects_overlap(name_rect, screen_rect(count_badge)) and not rects_overlap(desc_rect, screen_rect(count_badge)), "shop row %s text does not overlap count badge at %s" % [item_id, viewport_size])
			if buy_button != null:
				check(not rects_overlap(name_rect, screen_rect(buy_button)) and not rects_overlap(desc_rect, screen_rect(buy_button)), "shop row %s text does not overlap buy button at %s" % [item_id, viewport_size])
		if row != null and count_badge != null and buy_button != null:
			var control_row_rect = screen_rect(row)
			var count_rect = screen_rect(count_badge)
			var buy_rect = screen_rect(buy_button)
			check(control_row_rect.grow(1.0).encloses(count_rect) and control_row_rect.grow(1.0).encloses(buy_rect), "shop row %s keeps count badge and buy button inside row at %s" % [item_id, viewport_size])
			check(count_rect.end.x <= buy_rect.position.x - max(8.0, control_row_rect.size.x * 0.025), "shop row %s keeps a visible gap between count badge and buy button at %s" % [item_id, viewport_size])
			check(buy_rect.end.x <= control_row_rect.end.x - max(4.0, control_row_rect.size.x * 0.010), "shop row %s keeps buy button away from row edge and scrollbar lane at %s" % [item_id, viewport_size])
			check(buy_rect.size.x >= 82.0 and buy_rect.size.y >= 42.0, "shop row %s keeps buy button touch target usable at %s" % [item_id, viewport_size])
		check(buy_button != null and buy_command != null and buy_price != null, "shop row %s exposes readable buy command and price at %s" % [item_id, viewport_size])
		if buy_button != null and buy_command != null and buy_price != null:
			var expected_affordable := int(scene.currency.get("gems", 0)) >= int(scene.ITEM_TYPES[item_id].get("cost_gems", 10))
			check(buy_button.disabled == not expected_affordable and buy_button.tooltip_text != "", "shop buy button %s exposes truthful affordability state and tooltip at %s" % [item_id, viewport_size])
			check(buy_button.find_child("ShopBuyButton3DDepthEdge", true, false) != null and buy_button.find_child("ShopBuyButton3DSideBevel", true, false) != null, "shop buy button %s exposes physical depth and side bevel at %s" % [item_id, viewport_size])
			var buy_rect = screen_rect(buy_button)
			check(buy_rect.grow(1.0).encloses(screen_rect(buy_command)) and buy_rect.grow(1.0).encloses(screen_rect(buy_price)), "shop buy button %s keeps command and price inside button at %s" % [item_id, viewport_size])
			check(buy_command.clip_text and buy_price.clip_text and buy_price.text.ends_with("玉"), "shop buy button %s exposes clipped command and gem price anchor at %s" % [item_id, viewport_size])
			check(str(buy_command.text).begins_with("购买 ") or str(buy_command.text).begins_with("不足 "), "shop buy button %s uses explicit single-line purchase/shortage CTA at %s" % [item_id, viewport_size])
			check(str(buy_command.text).ends_with(buy_price.text) and not buy_price.visible, "shop buy button %s folds gem price into one visible CTA and hides the price anchor at %s" % [item_id, viewport_size])
			check(label_text_width(buy_command, buy_command.text) <= screen_rect(buy_command).size.x + 2.0, "shop buy button %s fits single-line CTA within its label at %s" % [item_id, viewport_size])
			check(count_named_nodes(buy_button, "ShopBuyButtonStatus") == 0, "shop buy button %s omits right-side status medallion at %s" % [item_id, viewport_size])
	if scroll != null and scrollbar != null and scroll_gutter != null and scroll_thumb != null:
		var scroll_rect = screen_rect(scroll)
		var scrollbar_rect = screen_rect(scrollbar)
		var gutter_rect = screen_rect(scroll_gutter)
		var thumb_rect = screen_rect(scroll_thumb)
		check(scroll.clip_contents, "shop item scroll clips row content at %s" % viewport_size)
		check(scroll_rect.end.y <= viewport_size.y * 0.78 and scroll_rect.end.x <= viewport_size.x * 0.955, "shop item scroll leaves room for footer and gutter at %s" % viewport_size)
		check(not scrollbar.visible and scroll.vertical_scroll_mode == ScrollContainer.SCROLL_MODE_SHOW_NEVER, "shop hides default bright system scrollbar at %s" % viewport_size)
		check(gutter_rect.size.x <= max(14.0, viewport_size.x * 0.016) and gutter_rect.position.x >= scroll_rect.end.x + 2.0, "shop custom scrollbar gutter is narrow and separate from rows at %s" % viewport_size)
		check(gutter_rect.grow(1.0).encloses(thumb_rect), "shop custom scrollbar thumb stays inside gutter at %s" % viewport_size)
		var gutter_style = scroll_gutter.get_theme_stylebox("panel") as StyleBoxFlat
		var thumb_style = scroll_thumb.get_theme_stylebox("panel") as StyleBoxFlat
		check(gutter_style != null and thumb_style != null and relative_luma(gutter_style.bg_color) <= 0.20 and relative_luma(thumb_style.bg_color) <= 0.52, "shop custom scrollbar avoids default bright white styling at %s" % viewport_size)
		for item_id in item_ids:
			var name_label = scene.find_child("ShopItemName_%s" % item_id, true, false) as Label
			var desc_label = scene.find_child("ShopItemDescription_%s" % item_id, true, false) as Label
			var count_badge = scene.find_child("ShopItemCountBadge_%s" % item_id, true, false) as Control
			var buy_button = scene.find_child("ShopItemBuyButton_%s" % item_id, true, false) as Control
			var buy_command = scene.find_child("ShopBuyButtonCommand_%s" % item_id, true, false) as Label
			var buy_price = scene.find_child("ShopBuyButtonPrice_%s" % item_id, true, false) as Label
			for node in [name_label, desc_label, count_badge, buy_button, buy_command, buy_price]:
				if node != null:
					check(not rects_overlap(screen_rect(node), gutter_rect), "shop interactive/text node clears custom scrollbar gutter at %s" % viewport_size)
	if footer_panel != null and footer_title != null and footer_body != null and footer_inventory != null and footer_state != null:
		var footer_rect = screen_rect(footer_panel)
		check(footer_rect.size.y >= 58.0 and footer_rect.end.y <= viewport_size.y + 0.5, "shop footer fills the lower cabinet lane at %s" % viewport_size)
		check(footer_rect.position.y <= viewport_size.y * 0.82 and footer_rect.end.y >= viewport_size.y * 0.88, "shop footer uses visible lower-page space at %s" % viewport_size)
		check(footer_rect.grow(1.0).encloses(screen_rect(footer_title)) and footer_rect.grow(1.0).encloses(screen_rect(footer_body)), "shop footer text stays inside its panel at %s" % viewport_size)
		check(footer_rect.grow(1.0).encloses(screen_rect(footer_inventory)) and footer_rect.grow(1.0).encloses(screen_rect(footer_state)), "shop footer inventory and state badges stay inside the footer at %s" % viewport_size)
		check(footer_title.clip_text and footer_body.clip_text and footer_title.get_theme_font_size("font_size") >= 16 and footer_body.get_theme_font_size("font_size") >= 13, "shop footer text remains clipped and readable at %s" % viewport_size)
		check(relative_luma(footer_title.get_theme_color("font_color")) >= 0.86 and relative_luma(footer_body.get_theme_color("font_color")) >= 0.86, "shop footer text keeps readable contrast at %s" % viewport_size)
		if row_rects.size() > 0:
			var last_row_rect = row_rects[row_rects.size() - 1]
			check(last_row_rect.end.y <= footer_rect.position.y - 6.0, "shop item list clears the lower footer panel at %s" % viewport_size)
			for row_rect in row_rects:
				check(not rects_overlap(row_rect, footer_rect), "shop item rows do not overlap the footer panel at %s" % viewport_size)

func check_daily_login_layout(scene, viewport_size: Vector2) -> void:
	var panel = scene.find_child("DailyLoginPanel", true, false) as Control
	var indicators = scene.find_child("DailyLoginDayIndicators", true, false) as Control
	var reward_panel = scene.find_child("DailyLoginRewardPanel", true, false) as Control
	var progress_panel = scene.find_child("DailyLoginProgressPanel", true, false) as Control
	var claim_button = scene.find_child("DailyLoginClaimButton", true, false) as Button
	var back_button = scene.find_child("DailyLoginBackButton", true, false) as Button
	var claim_art = scene.find_child("DailyLoginClaimButtonArt", true, false) as CanvasItem
	var tip_back = scene.find_child("DailyLoginTipBack", true, false) as Control
	var tip_label = scene.find_child("DailyLoginTipLabel", true, false) as Label
	var forecast_panel = scene.find_child("DailyLoginForecastPanel", true, false) as Control
	var forecast_rail = scene.find_child("DailyLoginForecastRail", true, false) as Control
	var forecast_title = scene.find_child("DailyLoginForecastTitle", true, false) as Label
	var forecast_body = scene.find_child("DailyLoginForecastBody", true, false) as Label
	var forecast_badge = scene.find_child("DailyLoginForecastBadge", true, false) as Label
	var forecast_badge_back = scene.find_child("DailyLoginForecastBadgeBack", true, false) as Control
	check(panel != null and indicators != null and reward_panel != null and progress_panel != null and claim_button != null and back_button != null and forecast_panel != null, "daily login exposes panel, day reward progress, claim, return, and forecast controls at %s" % viewport_size)
	check(scene.optional_gpt_illustration_texture("daily_login_gpt_calendar") == null or scene.find_child("DailyLoginGPTCalendarTexture", true, false) != null, "daily login consumes GPT calendar art at %s" % viewport_size)
	if panel == null or indicators == null or reward_panel == null or progress_panel == null or claim_button == null or back_button == null or forecast_panel == null:
		return
	var panel_rect = screen_rect(panel)
	var daily_back_rect = screen_rect(back_button)
	check(panel_rect.grow(1.0).encloses(daily_back_rect), "daily login return button stays inside the panel at %s" % viewport_size)
	check(daily_back_rect.size.x >= 92.0 and daily_back_rect.size.y >= 44.0 and back_button.text == "返回", "daily login exposes an explicit 44px+ return path at %s" % viewport_size)
	check((claim_button.text == "领取奖励" or claim_button.text == "已领取") and claim_art != null and claim_art.show_behind_parent, "daily login keeps the native claim CTA text above its bitmap art at %s" % viewport_size)
	var indicator_rect = screen_rect(indicators)
	var previous_rect := Rect2()
	for i in range(1, 8):
		var day_node = scene.find_child("DailyLoginDayNode_%d" % i, true, false) as Control
		var day_label = scene.find_child("DailyLoginDayLabel_%d" % i, true, false) as Label
		var reward_label = scene.find_child("DailyLoginRewardLabel_%d" % i, true, false) as Label
		var text_back = scene.find_child("DailyLoginDayTextBack_%d" % i, true, false) as Control
		check(day_node != null and day_label != null and reward_label != null and text_back != null, "daily login day %d exposes node labels and text backplate at %s" % [i, viewport_size])
		if day_node == null:
			continue
		var node_rect = screen_rect(day_node)
		check(indicator_rect.grow(1.0).encloses(node_rect), "daily login day %d stays inside day indicator lane at %s" % [i, viewport_size])
		check(node_rect.size.x >= 42.0 and node_rect.size.y >= 38.0, "daily login day %d keeps readable tile size at %s" % [i, viewport_size])
		if i > 1:
			check(node_rect.position.x >= previous_rect.end.x + 3.0, "daily login day %d has stable separation at %s" % [i, viewport_size])
		previous_rect = node_rect
		if text_back != null and day_label != null and reward_label != null:
			var back_rect = screen_rect(text_back)
			check(back_rect.grow(1.0).encloses(screen_rect(day_label)) and back_rect.grow(1.0).encloses(screen_rect(reward_label)), "daily login day %d text backplate covers both labels at %s" % [i, viewport_size])
		if day_label != null:
			var day_luma = relative_luma(day_label.get_theme_color("font_color"))
			check(day_label.clip_text and day_label.get_theme_font_size("font_size") >= 11, "daily login day %d title clips and keeps readable font at %s" % [i, viewport_size])
			check(day_luma >= 0.70 or day_luma <= 0.22, "daily login day %d title color has deliberate contrast at %s" % [i, viewport_size])
		if reward_label != null:
			var reward_luma = relative_luma(reward_label.get_theme_color("font_color"))
			check(reward_label.clip_text and reward_label.get_theme_font_size("font_size") >= 11, "daily login day %d reward clips and keeps readable font at %s" % [i, viewport_size])
			check(reward_luma >= 0.70 or reward_luma <= 0.24, "daily login day %d reward color has deliberate contrast at %s" % [i, viewport_size])
	var reward_rect = screen_rect(reward_panel)
	var progress_rect = screen_rect(progress_panel)
	var claim_rect = screen_rect(claim_button)
	var forecast_rect = screen_rect(forecast_panel)
	var reward_text = scene.find_child("DailyLoginRewardTextLabel", true, false) as Label
	var reward_text_back = scene.find_child("DailyLoginRewardTextBack", true, false) as Control
	var reward_icon_back = scene.find_child("DailyLoginRewardIconBack", true, false) as Control
	check(reward_text != null and reward_text_back != null and reward_icon_back != null, "daily login reward row exposes readable text and icon backplates at %s" % viewport_size)
	if reward_text != null:
		check(reward_text.clip_text and reward_text.get_theme_font_size("font_size") >= 20 and relative_luma(reward_text.get_theme_color("font_color")) >= 0.88, "daily login reward text is bright and clipped at %s" % viewport_size)
		check(reward_rect.grow(1.0).encloses(screen_rect(reward_text)), "daily login reward text stays inside reward panel at %s" % viewport_size)
	if reward_text_back != null and reward_text != null:
		check(screen_rect(reward_text_back).grow(1.0).encloses(screen_rect(reward_text)), "daily login reward text backplate contains reward text at %s" % viewport_size)
	var progress_text = scene.find_child("DailyLoginProgressText", true, false) as Label
	var progress_fill = scene.find_child("DailyLoginProgressFill", true, false) as Control
	check(progress_text != null and progress_fill != null, "daily login progress exposes text and fill at %s" % viewport_size)
	if progress_text != null:
		check(progress_text.get_theme_font_size("font_size") >= 14 and relative_luma(progress_text.get_theme_color("font_color")) >= 0.92, "daily login progress text remains readable at %s" % viewport_size)
	check(reward_rect.end.y <= progress_rect.position.y - 4.0 and progress_rect.end.y <= claim_rect.position.y - 6.0, "daily login reward progress and claim button remain vertically separated at %s" % viewport_size)
	check(claim_rect.size.x >= 200.0 and claim_rect.size.y >= 50.0, "daily login claim button keeps practical touch size at %s" % viewport_size)
	check(not rects_overlap(claim_rect, forecast_rect), "daily login forecast panel clears claim button at %s" % viewport_size)
	check(forecast_rect.position.y >= claim_rect.end.y + 10.0, "daily login forecast panel keeps a clear gap below claim button at %s" % viewport_size)
	check(forecast_rect.size.x >= 360.0 and forecast_rect.size.y >= 54.0, "daily login forecast strip keeps readable size at %s" % viewport_size)
	check(forecast_rect.size.y <= viewport_size.y * 0.135, "daily login forecast remains a low-priority strip at %s" % viewport_size)
	if forecast_title != null and forecast_body != null and forecast_badge != null and forecast_badge_back != null and forecast_rail != null:
		var forecast_title_rect = screen_rect(forecast_title)
		var forecast_body_rect = screen_rect(forecast_body)
		var forecast_badge_rect = screen_rect(forecast_badge)
		check(forecast_title.clip_text and forecast_title.get_theme_font_size("font_size") >= 12 and relative_luma(forecast_title.get_theme_color("font_color")) >= 0.74, "daily login forecast title stays readable and clipped at %s" % viewport_size)
		check(forecast_body.clip_text and forecast_body.get_theme_font_size("font_size") >= 12 and relative_luma(forecast_body.get_theme_color("font_color")) >= 0.78, "daily login forecast body stays readable and clipped at %s" % viewport_size)
		check(forecast_badge.clip_text and forecast_badge.get_theme_font_size("font_size") >= 11 and relative_luma(forecast_badge.get_theme_color("font_color")) >= 0.80, "daily login forecast badge stays readable and clipped at %s" % viewport_size)
		check(forecast_rect.grow(1.0).encloses(screen_rect(forecast_rail)) and forecast_rect.grow(1.0).encloses(screen_rect(forecast_title)) and forecast_rect.grow(1.0).encloses(screen_rect(forecast_body)) and forecast_rect.grow(1.0).encloses(screen_rect(forecast_badge)), "daily login forecast content stays inside panel at %s" % viewport_size)
		check(not rects_overlap(forecast_title_rect, forecast_badge_rect), "daily login forecast title and badge keep separate top lanes at %s" % viewport_size)
		check(forecast_title_rect.end.x <= forecast_badge_rect.position.x - 8.0, "daily login forecast title clears status badge at %s" % viewport_size)
		check(forecast_body_rect.position.y >= max(forecast_title_rect.end.y, forecast_badge_rect.end.y) + 3.0, "daily login forecast body sits below the title and badge row at %s" % viewport_size)
		check(forecast_body_rect.size.x >= forecast_rect.size.x * 0.72, "daily login forecast body keeps a wide readable copy lane at %s" % viewport_size)
		check(forecast_body_rect.position.x <= forecast_title_rect.position.x + max(22.0, forecast_rect.size.x * 0.04), "daily login forecast body starts from the message column at %s" % viewport_size)
		check(screen_rect(forecast_badge_back).grow(1.0).encloses(screen_rect(forecast_badge)), "daily login forecast badge backplate contains badge text at %s" % viewport_size)
	if forecast_body != null and tip_back != null:
		check(screen_rect(tip_back).grow(1.0).encloses(screen_rect(forecast_body)), "daily login forecast body backplate contains text at %s" % viewport_size)
		check(screen_rect(forecast_body).position.y >= claim_rect.end.y + 4.0, "daily login forecast body clears claim button at %s" % viewport_size)
	if tip_label != null:
		check(tip_label.clip_text, "daily login compatibility tip label remains clipped at %s" % viewport_size)

func check_compact_seat_panels(scene, viewport_size: Vector2) -> void:
	for seat_layout in scene.SEAT_LAYOUTS:
		var seat := int(seat_layout[0])
		var panel = scene.find_child("SeatPanel_%d" % seat, true, false) as Control
		var avatar = scene.find_child("SeatAvatar_%d" % seat, true, false) as Control
		var wind_mark = scene.find_child("SeatAvatarWindMark_%d" % seat, true, false) as Label
		var short_name = scene.find_child("SeatAvatarShortName_%d" % seat, true, false) as Label
		var text_back = scene.find_child("SeatCompactTextBack_%d" % seat, true, false) as Control
		var name = scene.find_child("SeatCompactName_%d" % seat, true, false) as Label
		var meta = scene.find_child("SeatCompactMeta_%d" % seat, true, false) as Label
		var score = scene.find_child("SeatCompactScore_%d" % seat, true, false) as Label
		var status = scene.find_child("SeatCompactStatus_%d" % seat, true, false) as Label
		var river = scene.find_child("SeatCompactRiver_%d" % seat, true, false) as Label
		var discard_recent = scene.find_child("SeatDiscardPreviewRecentLabel_%d" % seat, true, false) as Label
		var turn_badge = scene.find_child("SeatCompactTurn_%d" % seat, true, false) as Control
		var dealer_badge = scene.find_child("SeatCompactDealer_%d" % seat, true, false) as Control
		check(panel != null and avatar != null and text_back != null and name != null and meta != null and score != null, "seat %d exposes compact panel avatar text backplate and labels at %s" % [seat, viewport_size])
		if panel == null or avatar == null or text_back == null or name == null or meta == null or score == null:
			continue
		var side := str(seat_layout[2])
		var is_side_thumbnail := side == "left" or side == "right"
		var recent_source: bool = seat == int(scene.get_last_discard_seat()) and str(scene.get_last_discard()) != ""
		check(panel.clip_contents, "seat %d compact panel clips overflow at %s" % [seat, viewport_size])
		if is_side_thumbnail and not recent_source and seat != int(scene.get_current_seat()):
			check(discard_recent == null or str(discard_recent.text).length() <= 12, "inactive side AI seat %d keeps river text thumbnail-sized at %s" % [seat, viewport_size])
		var brocade_texture = panel.find_child("SeatGPTBrocadeTexture_%d" % seat, true, false) as TextureRect
		check(scene.optional_gpt_illustration_texture("seat_gpt_brocade") == null or brocade_texture != null, "seat %d consumes v4 GPT brocade frame when generated at %s" % [seat, viewport_size])
		var panel_rect = screen_rect(panel)
		var avatar_rect = screen_rect(avatar)
		if is_side_thumbnail:
			check(panel_rect.size.x <= viewport_size.x * 0.120 + 1.0 and panel_rect.size.y <= viewport_size.y * 0.170 + 1.0, "side AI seat %d stays compact while preserving readable identity at %s" % [seat, viewport_size])
		var minimum_name_size := 10 if is_side_thumbnail else 12
		var minimum_detail_size := 9 if is_side_thumbnail else 10
		check(name.get_theme_font_size("font_size") >= minimum_name_size, "seat %d name keeps commercial HUD type scale at %s" % [seat, viewport_size])
		check(meta.get_theme_font_size("font_size") >= minimum_detail_size and score.get_theme_font_size("font_size") >= minimum_detail_size, "seat %d score and state remain readable at %s" % [seat, viewport_size])
		check(relative_luma(name.get_theme_color("font_color")) >= 0.80 and relative_luma(meta.get_theme_color("font_color")) >= 0.76 and relative_luma(score.get_theme_color("font_color")) >= 0.80, "seat %d compact text keeps production contrast at %s" % [seat, viewport_size])
		check(panel_rect.grow(1.0).encloses(avatar_rect), "seat %d avatar stays inside panel at %s" % [seat, viewport_size])
		for label in [name, meta, score]:
			var label_rect = screen_rect(label)
			check(panel_rect.grow(1.0).encloses(label_rect), "seat %d compact label stays inside panel at %s" % [seat, viewport_size])
			check(screen_rect(text_back).grow(1.0).encloses(label_rect), "seat %d compact text backplate contains label at %s" % [seat, viewport_size])
			check(not rects_overlap(label_rect, avatar_rect), "seat %d compact label clears avatar wind mark area at %s" % [seat, viewport_size])
			check(label.clip_text and label.text_overrun_behavior == TextServer.OVERRUN_TRIM_ELLIPSIS, "seat %d compact label clips safely at %s" % [seat, viewport_size])
		for optional_label in [status, river, discard_recent]:
			if optional_label == null:
				continue
			var optional_rect = screen_rect(optional_label)
			check(panel_rect.grow(1.0).encloses(optional_rect), "seat %d compact optional text stays inside panel at %s" % [seat, viewport_size])
			check(screen_rect(text_back).grow(1.0).encloses(optional_rect), "seat %d compact optional text stays inside text backplate at %s" % [seat, viewport_size])
			check(not rects_overlap(optional_rect, avatar_rect), "seat %d compact optional text clears avatar at %s" % [seat, viewport_size])
			check(optional_label.clip_text and optional_label.text_overrun_behavior == TextServer.OVERRUN_TRIM_ELLIPSIS, "seat %d compact optional text clips safely at %s" % [seat, viewport_size])
			if is_side_thumbnail:
				if optional_label == discard_recent:
					check(str(optional_label.text).begins_with("弃") and str(optional_label.text).length() <= 4, "side AI seat %d uses discard-count thumbnail text at %s" % [seat, viewport_size])
				elif optional_label == status:
					check(str(optional_label.text).length() <= 4, "side AI seat %d keeps recent action thumbnail-sized at %s" % [seat, viewport_size])
				else:
					check(str(optional_label.text).length() <= 6, "side AI seat %d avoids full river text in compact card at %s" % [seat, viewport_size])
		for badge in [turn_badge, dealer_badge]:
			if badge == null:
				continue
			var badge_rect = screen_rect(badge)
			check(panel_rect.grow(1.0).encloses(badge_rect), "seat %d compact badge stays inside panel at %s" % [seat, viewport_size])
			check(screen_rect(text_back).grow(1.0).encloses(badge_rect), "seat %d compact badge stays inside text backplate at %s" % [seat, viewport_size])
			check(not rects_overlap(badge_rect, avatar_rect), "seat %d compact badge clears avatar at %s" % [seat, viewport_size])
		if seat == int(scene.dealer_seat):
			check(dealer_badge != null, "dealer seat %d exposes compact dealer badge inside text area at %s" % [seat, viewport_size])
		check(not rects_overlap(screen_rect(name), screen_rect(score)), "seat %d name and score do not overlap at %s" % [seat, viewport_size])
		check(screen_rect(meta).position.y >= min(screen_rect(name).end.y, screen_rect(score).end.y) + 1.0, "seat %d meta clears name row at %s" % [seat, viewport_size])
		check(relative_luma(name.get_theme_color("font_color")) >= 0.82 and relative_luma(score.get_theme_color("font_color")) >= 0.80 and relative_luma(meta.get_theme_color("font_color")) >= 0.78, "seat %d compact text keeps readable contrast at %s" % [seat, viewport_size])
		if wind_mark != null and short_name != null:
			check(wind_mark.clip_text and short_name.clip_text, "seat %d avatar wind and short name clip safely at %s" % [seat, viewport_size])
			check(wind_mark.anchor_bottom <= short_name.anchor_top - 0.04, "seat %d avatar wind mark anchor band clears short name band at %s" % [seat, viewport_size])
		if seat != 0:
			check(str(name.text).length() <= 2, "AI seat %d uses abbreviated name/profile label at %s" % [seat, viewport_size])
		check(str(meta.text).find("分") < 0, "seat %d keeps score out of hand/flower meta at %s" % [seat, viewport_size])
		if is_side_thumbnail:
			check(str(meta.text).begins_with("手") and str(meta.text).find("弃") >= 0, "side seat %d merges hand flower and discard counts into one scan line at %s" % [seat, viewport_size])
			check(label_text_width(meta, meta.text) <= screen_rect(meta).size.x + 2.0, "side seat %d combined meta fits without ellipsis at %s" % [seat, viewport_size])
		check(str(score.text).strip_edges() != "", "seat %d keeps score visible as its own label at %s" % [seat, viewport_size])

func check_safe_area_layout(scene, viewport_size: Vector2, page_label: String) -> void:
	check(scene.root_layer != null, "%s has a safe content root at %s" % [page_label, viewport_size])
	if scene.root_layer == null:
		return
	var safe_rect = safe_content_rect_for(viewport_size, scene.safe_area_margins)
	var root_rect = screen_rect(scene.root_layer)
	check(root_rect.position.distance_to(safe_rect.position) <= 1.0 and root_rect.size.distance_to(safe_rect.size) <= 1.0, "%s safe content root applies simulated margins at %s" % [page_label, viewport_size])
	var visible_controls: Array[Control] = []
	collect_visible_text_and_buttons(scene.root_layer, visible_controls)
	for control in visible_controls:
		var rect = screen_rect(control)
		if rect.size.x <= 0.5 or rect.size.y <= 0.5:
			continue
		check(safe_rect.grow(1.0).encloses(rect), "%s visible text/button %s stays inside simulated safe area at %s" % [page_label, control.name, viewport_size])
	var key_names := [
		"MenuFooterTextLayer",
		"MenuQuickActionRail",
		"MenuSettingsButton",
		"SettingsPanel",
		"TopHudTitleBack",
		"TopHudStatusBack",
		"TopHudWallBack",
		"ActionButtonDock",
		"HandTray",
		"OnlineLobbyFormPanel",
		"OnlineLobbyLogPanel",
		"OnlineFeedbackArt",
	]
	for node_name in key_names:
		var control = scene.find_child(node_name, true, false) as Control
		if control == null or not control.is_visible_in_tree():
			continue
		check(safe_rect.grow(1.0).encloses(screen_rect(control)), "%s key surface %s stays inside simulated safe area at %s" % [page_label, node_name, viewport_size])

func safe_content_rect_for(viewport_size: Vector2, margins: Vector4) -> Rect2:
	return Rect2(
		Vector2(margins.x, margins.y),
		Vector2(max(1.0, viewport_size.x - margins.x - margins.z), max(1.0, viewport_size.y - margins.y - margins.w))
	)

func first_top_hud_button(node: Node, label_text: String) -> Button:
	if node == null:
		return null
	if node is Button and (node as Button).find_child("TopHudButtonArt_%s" % label_text, true, false) != null:
		return node as Button
	for child in node.get_children():
		var found = first_top_hud_button(child, label_text)
		if found != null:
			return found
	return null

func first_button_with_text(node: Node, text: String) -> Button:
	if node == null:
		return null
	if node is Button and (node as Button).text == text:
		return node as Button
	for child in node.get_children():
		var found = first_button_with_text(child, text)
		if found != null:
			return found
	return null

func controls_with_name_prefix(node: Node, prefix: String) -> Array[Control]:
	var found: Array[Control] = []
	collect_controls_with_name_prefix(node, prefix, found)
	return found

func count_nodes_with_name_prefix(node: Node, prefix: String) -> int:
	if node == null:
		return 0
	var total := 1 if str(node.name).begins_with(prefix) else 0
	for child in node.get_children():
		total += count_nodes_with_name_prefix(child, prefix)
	return total

func count_named_nodes(node: Node, node_name: String) -> int:
	if node == null:
		return 0
	var total := 1 if str(node.name) == node_name else 0
	for child in node.get_children():
		total += count_named_nodes(child, node_name)
	return total

func collect_controls_with_name_prefix(node: Node, prefix: String, found: Array[Control]) -> void:
	if node == null:
		return
	if node is Control and str(node.name).begins_with(prefix):
		found.append(node as Control)
	for child in node.get_children():
		collect_controls_with_name_prefix(child, prefix, found)

func screen_rect(control: Control) -> Rect2:
	var rect = control.get_global_rect()
	return Rect2(rect.position, rect.size)

func label_text_width(label: Label, text: String) -> float:
	var font = label.get_theme_font("font")
	if font == null:
		return 0.0
	return font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, label.get_theme_font_size("font_size")).x

func vertical_overlap(a: Rect2, b: Rect2) -> float:
	return max(0.0, min(a.end.y, b.end.y) - max(a.position.y, b.position.y))

func rects_overlap(a: Rect2, b: Rect2) -> bool:
	return a.position.x < b.end.x and a.end.x > b.position.x and a.position.y < b.end.y and a.end.y > b.position.y

func check_settings_button_art_text_safe_zone(button: Button, prefixes: Array, label_text: String, viewport_size: Vector2) -> void:
	var button_rect = screen_rect(button)
	var safe_zone = Rect2(
		Vector2(button_rect.position.x + button_rect.size.x * 0.27, button_rect.position.y + button_rect.size.y * 0.31),
		Vector2(button_rect.size.x * 0.49, button_rect.size.y * 0.38)
	)
	for prefix in prefixes:
		var nodes = controls_with_name_prefix(button, str(prefix))
		check(nodes.size() > 0, "settings row %s exposes %s art for safe-zone audit at %s" % [label_text, prefix, viewport_size])
		for node in nodes:
			check(not rects_overlap(safe_zone, screen_rect(node)), "settings row %s keeps %s out of the button text safe zone at %s" % [label_text, node.name, viewport_size])

func check_button_face_behind_native_text(button: Button, label_text: String, viewport_size: Vector2) -> void:
	if button == null:
		return
	var face = button.find_child("GptButtonFacePlate", false, false) as CanvasItem
	check(face != null and face.show_behind_parent, "%s keeps its GPT face behind native text at %s" % [label_text, viewport_size])

func relative_luma(color: Color) -> float:
	return color.r * 0.2126 + color.g * 0.7152 + color.b * 0.0722

func check(condition: bool, message: String) -> void:
	if condition:
		return
	failed = true
	push_error("ui layout smoke test failed: %s" % message)
