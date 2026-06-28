extends "res://scripts/main_base.gd"

func _ready() -> void:
	randomize()
	DisplayServer.screen_set_orientation(DisplayServer.SCREEN_LANDSCAPE)
	setup_tile_order()
	show_loading_screen()
	load_assets()
	verify_audio_assets()
	load_settings()
	load_game_stats()
	load_tutorial_state()
	load_achievements()
	load_login_state()
	load_season_data()
	load_tasks()
	load_inventory()
	load_currency()
	setup_audio()
	ensure_fx_layer()
	setup_update_downloader()
	# v1.0.149: 移除立即播放，恢复用户交互触发
	call_deferred("_finish_startup")

func _finish_startup() -> void:
	if OS.get_cmdline_user_args().has("--offline-preview"):
		start_offline(true)
	else:
		# 检查每日签到
		var login_result = check_and_update_login()
		if login_result.get("show_reward", false):
			show_daily_login_panel(login_result)
		else:
			show_menu(true)

func show_daily_login_panel(login_result: Dictionary) -> void:
	"""显示每日登录签到面板 - 增强版"""
	mode = "daily_login"
	clear_screen()

	# 背景装饰 - 远山与云纹
	make_mountain_silhouette(root_layer, rect_full(0.0, 0.60, 1.0, 1.0), 2, INK_WASH).name = "DailyLoginMountain"
	make_cloud_decoration(root_layer, rect_full(0.02, 0.05, 0.30, 0.30), "mist", false)
	make_cloud_decoration(root_layer, rect_full(0.70, 0.70, 0.98, 0.95), "gold", false)

	# 灯笼装饰 - 两侧对称
	make_lantern(root_layer, rect_full(0.06, 0.04, 0.14, 0.22), CINNABAR, true).name = "DailyLoginLanternLeft"
	make_lantern(root_layer, rect_full(0.86, 0.04, 0.94, 0.22), CINNABAR, true).name = "DailyLoginLanternRight"

	# 梅花点缀 - 右下角
	make_plum_blossom(root_layer, rect_full(0.78, 0.62, 0.98, 0.92), 2, ROUGE, true).name = "DailyLoginPlumBlossom"

	# 主面板
	var panel = make_panel(root_layer, rect_full(0.18, 0.10, 0.82, 0.90), Color(0.008, 0.020, 0.024, 0.98), 24, Color(0.62, 0.52, 0.32, 0.56), 5)
	panel.add_child(make_color_rect(rect_full(0.006, 0.03, 0.014, 0.97), GOLD_PRIMARY.darkened(0.2)))

	# 顶部金色装饰线
	panel.add_child(make_color_rect(rect_full(0.02, 0.06, 0.98, 0.08), Color(0.92, 0.78, 0.38, 0.18)))

	# 标题 - 使用Lucide图标
	var title = make_label(panel, "每日签到", 32, Color(0.96, 0.88, 0.52), true)
	apply_rect(title, rect_full(0.15, 0.06, 0.85, 0.16))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_lucide_icon(panel, "gift", rect_full(0.08, 0.07, 0.14, 0.15), GOLD_BRIGHT)

	# 连续签到天数 - 更醒目
	var days = int(login_result.get("consecutive_days", 1))
	var days_text = "已连续签到 %d 天" % days
	var days_label = make_label(panel, days_text, 26, Color(0.94, 0.94, 0.88), true)
	apply_rect(days_label, rect_full(0.10, 0.18, 0.90, 0.28))
	days_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# 7天签到指示器 - 每天一个小圆圈
	var day_indicators_container = Control.new()
	day_indicators_container.name = "DailyLoginDayIndicators"
	day_indicators_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(day_indicators_container, rect_full(0.10, 0.30, 0.90, 0.42))
	panel.add_child(day_indicators_container)

	var current_day_in_cycle = days % 7
	if current_day_in_cycle == 0:
		current_day_in_cycle = 7

	for i in range(7):
		var day_num = i + 1
		var is_claimed = day_num < current_day_in_cycle
		var is_current = day_num == current_day_in_cycle
		var is_milestone = day_num == 7

		# 计算位置 - 均匀分布
		var x_pos = 0.06 + float(i) * 0.13
		var indicator_rect = rect_full(x_pos, 0.10, x_pos + 0.10, 0.90)

		# 选择颜色
		var fill_color: Color
		var border_color: Color
		var text_color: Color
		if is_claimed:
			fill_color = Color(0.28, 0.56, 0.48, 0.92)
			border_color = Color(0.42, 0.72, 0.62, 0.88)
			text_color = Color(0.96, 0.96, 0.92)
		elif is_current:
			fill_color = Color(0.88, 0.72, 0.28, 0.92)
			border_color = GOLD_BRIGHT
			text_color = Color(0.12, 0.10, 0.08)
		else:
			fill_color = Color(0.08, 0.12, 0.14, 0.88)
			border_color = Color(0.28, 0.32, 0.30, 0.42)
			text_color = Color(0.52, 0.54, 0.50)

		# 里程碑天数特殊样式
		var radius = 16 if is_milestone else 12
		var indicator = make_panel(day_indicators_container, indicator_rect, fill_color, radius, border_color, 0)
		indicator.name = "DailyLoginDayNode_%d" % day_num

		# 天数标签
		var day_label = make_label(indicator, str(day_num), 14, text_color, true)
		apply_rect(day_label, rect_full(0.0, 0.0, 1.0, 0.65))

		# 奖励图标
		var reward_icon = "×2" if is_milestone else "+"
		var icon_label = make_label(indicator, reward_icon, 10, text_color.darkened(0.2), false)
		apply_rect(icon_label, rect_full(0.0, 0.55, 1.0, 0.95))

		# 已签到的天数添加对勾
		if is_claimed:
			add_lucide_icon(indicator, "check", rect_full(0.25, 0.15, 0.75, 0.65), text_color)

		# 当前天数脉冲动画
		if is_current and fx_enabled_effective():
			var pulse_tween := create_tween()
			pulse_tween.set_loops(3600)
			pulse_tween.tween_property(indicator, "modulate:a", 0.6, 0.8).from(1.0)
			pulse_tween.tween_property(indicator, "modulate:a", 1.0, 0.8).from(0.6)
	draw_daily_login_streak_art(panel, days, current_day_in_cycle)

	# 奖励说明 - 增强视觉效果
	var reward_text = "今日奖励："
	var reward_icon_name = "gift"
	if days % 7 == 0:
		reward_text += "双倍分数加成卡 ×1"
		reward_icon_name = "sparkles"
	else:
		reward_text += "金币 +100"
		reward_icon_name = "coin"

	var reward_panel = make_panel(panel, rect_full(0.14, 0.44, 0.86, 0.56), Color(0.018, 0.030, 0.034, 0.92), 14, Color(0.46, 0.52, 0.42, 0.36), 0)
	reward_panel.add_child(make_color_rect(rect_full(0.0, 0.0, 0.012, 1.0), GOLD_PRIMARY.darkened(0.2)))

	var reward_label = make_label(reward_panel, reward_text, 20, Color(0.96, 0.92, 0.68), true)
	apply_rect(reward_label, rect_full(0.12, 0.15, 0.88, 0.85))
	reward_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_lucide_icon(reward_panel, reward_icon_name, rect_full(0.04, 0.20, 0.12, 0.80), GOLD_PRIMARY)

	# 签到进度条 - 增强版
	var progress = days % 7
	if progress == 0:
		progress = 7
	var progress_panel = make_panel(panel, rect_full(0.14, 0.58, 0.86, 0.68), Color(0.018, 0.030, 0.034, 0.92), 12, Color(0.38, 0.42, 0.40, 0.36), 0)

	# 进度条背景
	var progress_bg = make_panel(progress_panel, rect_full(0.04, 0.20, 0.96, 0.80), Color(0.06, 0.10, 0.12, 0.92), 8, Color(0.24, 0.28, 0.26, 0.36), 0)

	# 进度条填充 - 带动画
	var progress_fill = ColorRect.new()
	progress_fill.color = Color(0.40, 0.72, 0.56, 0.88)
	progress_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	progress_bg.add_child(progress_fill)

	# 动画填充进度条
	var target_width = float(progress) / 7.0
	if fx_enabled_effective():
		apply_rect(progress_fill, rect_full(0.0, 0.0, 0.0, 1.0))
		var fill_tween := create_tween()
		fill_tween.tween_property(progress_fill, "anchor_right", target_width, 0.8).from(0.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	else:
		apply_rect(progress_fill, rect_full(0.0, 0.0, target_width, 1.0))

	# 进度文字
	var progress_text = make_label(progress_panel, "%d/7 天" % progress, 14, Color(0.96, 0.96, 0.92), true)
	apply_rect(progress_text, rect_full(0.0, 0.0, 1.0, 1.0))
	progress_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# 确认按钮 - 增强样式
	var confirm_btn = make_small_button("领取奖励", Color(0.32, 0.62, 0.52), func() -> void:
		# 领取奖励动画
		if fx_enabled_effective():
			_play_reward_claim_animation(panel, reward_text)
		show_toast("签到成功！%s" % reward_text.replace("今日奖励：", ""), 2500)
		show_menu(true)
	)
	confirm_btn.custom_minimum_size = Vector2(220, 58)
	panel.add_child(confirm_btn)
	apply_rect(confirm_btn, rect_full(0.30, 0.72, 0.70, 0.84))
	add_lucide_icon(confirm_btn, "check", rect_full(0.08, 0.22, 0.22, 0.78), Color(0.96, 0.96, 0.92))

	# 底部提示
	var tip_label = make_label(panel, "连续签到7天可获得双倍分数加成卡", 12, Color(0.62, 0.66, 0.60, 0.78), false)
	apply_rect(tip_label, rect_full(0.15, 0.86, 0.85, 0.94))
	tip_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# 面板弹出动画
	if fx_enabled_effective():
		panel.modulate = Color(1, 1, 1, 0)
		panel.scale = Vector2(0.85, 0.85)
		var tw := create_tween()
		tw.set_parallel(true)
		tw.tween_property(panel, "modulate:a", 1.0, 0.3).from(0.0)
		tw.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.3).from(Vector2(0.85, 0.85)).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func draw_daily_login_streak_art(parent: Control, days: int, current_day_in_cycle: int) -> Control:
	var art = Control.new()
	art.name = "DailyLoginStreakArt"
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(art, rect_full(0.145, 0.395, 0.855, 0.465))
	parent.add_child(art)
	var rail = make_color_rect(rect_full(0.035, 0.470, 0.965, 0.540), Color(0.82, 0.70, 0.36, 0.20))
	rail.name = "DailyLoginStreakRail"
	art.add_child(rail)
	var filled = clamp(float(current_day_in_cycle) / 7.0, 0.0, 1.0)
	var fill = make_color_rect(rect_full(0.035, 0.480, 0.035 + 0.930 * filled, 0.530), Color(0.42, 0.74, 0.58, 0.42))
	fill.name = "DailyLoginStreakFill"
	art.add_child(fill)
	for i in range(7):
		var day_num = i + 1
		var center = 0.055 + float(i) * 0.148
		var active = day_num <= current_day_in_cycle
		var node_color = Color(0.88, 0.72, 0.34, 0.50) if active else Color(0.28, 0.34, 0.34, 0.34)
		var node = make_panel(art, rect_full(center - 0.018, 0.285, center + 0.018, 0.725), node_color, 999, Color(1.0, 0.88, 0.48, 0.18 if active else 0.08), 0)
		node.name = "DailyLoginStreakNode_%d" % day_num
		if day_num == current_day_in_cycle:
			var halo = make_panel(art, rect_full(center - 0.030, 0.160, center + 0.030, 0.850), Color(0.96, 0.78, 0.34, 0.14), 999, Color(1.0, 0.88, 0.48, 0.24), 0)
			halo.name = "DailyLoginCurrentHalo"
	var gate = make_panel(art, rect_full(0.925, 0.120, 0.995, 0.900), Color(0.72, 0.34, 0.24, 0.24), 999, Color(1.0, 0.82, 0.42, 0.28), 0)
	gate.name = "DailyLoginSevenDayGate"
	var gate_label = make_label(gate, "7", 10, Color(0.98, 0.92, 0.68, 0.92), true)
	gate_label.name = "DailyLoginSevenDayGlyph"
	apply_rect(gate_label, rect_full(0.0, 0.0, 1.0, 1.0))
	if days >= 7 and days % 7 == 0:
		var glow = make_panel(art, rect_full(0.900, 0.020, 1.020, 0.980), Color(0.96, 0.72, 0.30, 0.12), 999, Color(1.0, 0.88, 0.48, 0.22), 0)
		glow.name = "DailyLoginMilestoneGlow"
	return art

func _play_reward_claim_animation(panel: Control, reward_text: String) -> void:
	"""播放奖励领取动画 - 闪光和粒子效果"""
	# 闪光效果
	var flash = ColorRect.new()
	flash.color = Color(1.0, 0.92, 0.55, 0.0)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.add_child(flash)

	var flash_tween := create_tween()
	flash_tween.tween_property(flash, "color:a", 0.3, 0.15)
	flash_tween.tween_property(flash, "color:a", 0.0, 0.3)
	flash_tween.tween_callback(flash.queue_free)

	# 创建粒子效果
	for i in range(12):
		var particle = Control.new()
		particle.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_child(particle)

		var shape = Panel.new()
		shape.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var style_box = StyleBoxFlat.new()
		style_box.bg_color = GOLD_PRIMARY.lightened(0.3)
		style_box.set_corner_radius_all(50)
		shape.add_theme_stylebox_override("panel", style_box)
		shape.custom_minimum_size = Vector2(randf_range(6, 12), randf_range(6, 12))
		particle.add_child(shape)

		# 从中心向外扩散
		particle.position = Vector2(panel.size.x * 0.5, panel.size.y * 0.5)
		var angle = randf() * PI * 2
		var distance = randf_range(80, 200)
		var target_pos = particle.position + Vector2(cos(angle), sin(angle)) * distance

		var particle_tween := create_tween()
		particle_tween.set_parallel(true)
		particle_tween.tween_property(particle, "position", target_pos, 0.6).set_ease(Tween.EASE_OUT)
		particle_tween.tween_property(particle, "modulate:a", 0.0, 0.6).from(1.0)
		particle_tween.tween_property(shape, "scale", Vector2(0.3, 0.3), 0.6).from(Vector2(1.0, 1.0))
		particle_tween.tween_callback(particle.queue_free).set_delay(0.65)

func show_loading_screen() -> void:
	clear_screen()

	# 背景面板 - 水墨风格 + 远山意境
	var bg = make_panel(root_layer, rect_full(0.0, 0.0, 1.0, 1.0), Color(0.012, 0.018, 0.024, 1.0), 0, Color(0.0, 0.0, 0.0, 0.0), 0)

	# 远山层叠 - 增加远景深度
	make_mountain_silhouette(bg, rect_full(0.0, 0.40, 1.0, 0.95), 3, INK_WASH).name = "LoadingFarMountain"

	# 装饰性云纹背景
	make_cloud_decoration(bg, rect_full(0.02, 0.05, 0.35, 0.35), "mist", false)
	make_cloud_decoration(bg, rect_full(0.65, 0.65, 0.98, 0.95), "gold", false)

	# 月亮装饰 - 右上
	make_moon_or_sun(bg, rect_full(0.78, 0.02, 1.02, 0.22), "full_moon").name = "LoadingMoon"

	# 中央装饰面板
	var center_panel = make_panel(bg, rect_full(0.25, 0.20, 0.75, 0.80), Color(0.018, 0.028, 0.036, 0.92), 24, Color(0.62, 0.52, 0.28, 0.42), 8)
	center_panel.add_child(make_color_rect(rect_full(0.008, 0.02, 0.015, 0.98), GOLD_PRIMARY.darkened(0.2)))

	# 顶部金色装饰线
	center_panel.add_child(make_color_rect(rect_full(0.02, 0.06, 0.98, 0.08), Color(0.92, 0.78, 0.38, 0.18)))
	# 底部金色装饰线
	center_panel.add_child(make_color_rect(rect_full(0.02, 0.92, 0.98, 0.94), Color(0.92, 0.78, 0.38, 0.18)))

	# 游戏标题
	var title = make_label(center_panel, "云桌麻将", 52, GOLD_BRIGHT, true)
	apply_rect(title, rect_full(0.10, 0.15, 0.90, 0.38))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# 副标题
	var subtitle = make_label(center_panel, "国风雅韵 · 智慧博弈", 18, Color(0.78, 0.82, 0.74, 0.88), false)
	apply_rect(subtitle, rect_full(0.15, 0.38, 0.85, 0.48))
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	draw_loading_shuffle_art(center_panel)

	# 加载动画区域
	var loading_area = Control.new()
	loading_area.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(loading_area, rect_full(0.30, 0.55, 0.70, 0.72))
	center_panel.add_child(loading_area)

	# 加载文字
	var loading_text = make_label(loading_area, "正在加载", 20, Color(0.88, 0.86, 0.78, 0.92), true)
	apply_rect(loading_text, rect_full(0.0, 0.0, 0.6, 1.0))
	loading_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	# 动态加载点动画
	var dots_container = Control.new()
	dots_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(dots_container, rect_full(0.62, 0.20, 0.90, 0.80))
	loading_area.add_child(dots_container)

	var dots: Array[Label] = []
	for i in range(3):
		var dot = make_label(dots_container, "·", 28, GOLD_PRIMARY, true)
		apply_rect(dot, rect_full(float(i) * 0.30, 0.0, float(i + 1) * 0.30, 1.0))
		dots.append(dot)

	# 加载点动画
	if fx_enabled_effective() and DisplayServer.get_name().to_lower() != "headless":
		var dots_tween := create_tween()
		dots_tween.set_loops(10)
		for i in range(3):
			var dot_label = dots[i]
			dots_tween.tween_property(dot_label, "modulate:a", 1.0, 0.3).set_delay(float(i) * 0.2)
			dots_tween.tween_property(dot_label, "modulate:a", 0.3, 0.3)

	# 底部游戏提示
	var tips := [
		"提示：合理利用吃碰杠，加速听牌",
		"提示：注意观察对手弃牌，判断危险牌",
		"提示：听牌时优先选择多面听",
		"提示：保持手牌灵活性，避免过早定型",
	]
	var tip_text = tips[randi() % tips.size()]
	var tip_label = make_label(center_panel, tip_text, 14, Color(0.68, 0.72, 0.66, 0.78), false)
	apply_rect(tip_label, rect_full(0.10, 0.78, 0.90, 0.88))
	tip_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# 版本信息
	var version_label = make_label(center_panel, "v%s" % app_version(), 12, Color(0.52, 0.54, 0.50, 0.62), false)
	apply_rect(version_label, rect_full(0.35, 0.90, 0.65, 0.97))
	version_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# 底部水面装饰
	make_water_ripple(bg, rect_full(0.05, 0.88, 0.95, 0.98), "still", true).name = "LoadingWater"

	# 整体淡入动画
	if fx_enabled_effective():
		center_panel.modulate.a = 0.0
		var fade_tween := create_tween()
		fade_tween.tween_property(center_panel, "modulate:a", 1.0, 0.5).set_ease(Tween.EASE_OUT)

func draw_loading_shuffle_art(parent: Control) -> Control:
	var art = make_panel(parent, rect_full(0.160, 0.500, 0.840, 0.625), Color(0.010, 0.022, 0.026, 0.66), 14, Color(0.56, 0.48, 0.26, 0.24), 0)
	art.name = "LoadingShuffleArt"
	var rail = make_panel(art, rect_full(0.065, 0.570, 0.935, 0.700), Color(0.70, 0.56, 0.28, 0.18), 999, Color(0.92, 0.78, 0.42, 0.12), 0)
	rail.name = "LoadingShuffleRail"
	var seal = make_panel(art, rect_full(0.455, 0.155, 0.545, 0.845), Color(0.64, 0.48, 0.24, 0.34), 999, Color(0.96, 0.78, 0.38, 0.26), 0)
	seal.name = "LoadingShuffleSeal"
	var seal_label = make_label(seal, "云", 13, Color(0.96, 0.86, 0.58), true)
	apply_rect(seal_label, rect_full(0.0, 0.0, 1.0, 1.0))
	for i in range(5):
		var left = 0.145 + float(i) * 0.175
		var tile = make_wall_back_tile(Vector2(24, 34), true)
		tile.name = "LoadingShuffleTile_%d" % i
		art.add_child(tile)
		apply_rect(tile, rect_full(left, 0.170 + float(i % 2) * 0.080, left + 0.070, 0.740 + float(i % 2) * 0.080))
	# 墨迹晕染进度条 - 从左到右渐变展宽
	var glow = make_panel(art, rect_full(0.085, 0.500, 0.165, 0.780), Color(0.92, 0.72, 0.34, 0.20), 999, Color(1.0, 0.84, 0.46, 0.14), 0)
	glow.name = "LoadingShuffleGlow"
	var progress = make_panel(rail, rect_full(0.030, 0.300, 0.420, 0.700), Color(0.78, 0.64, 0.30, 0.48), 999, Color(0.96, 0.78, 0.38, 0.16), 0)
	progress.name = "LoadingShuffleProgress"
	if fx_enabled_effective() and DisplayServer.get_name().to_lower() != "headless":
		var tw := create_tween()
		tw.set_loops(8)
		tw.tween_property(glow, "anchor_left", 0.840, 1.10).from(0.085)
		tw.parallel().tween_property(glow, "anchor_right", 0.920, 1.10).from(0.165)
		tw.tween_property(glow, "modulate:a", 0.42, 0.18).from(0.92)
		tw.tween_property(glow, "modulate:a", 0.92, 0.18).from(0.42)
		# 印章旋转出现
		var seal_tw := create_tween()
		seal_tw.tween_property(seal, "scale", Vector2(1.0, 1.0), 0.6).from(Vector2(0.3, 0.3)).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		seal_tw.parallel().tween_property(seal, "modulate:a", 1.0, 0.5).from(0.0)
	return art


func _process(_delta: float) -> void:
	var now = Time.get_ticks_msec()
	keep_background_music_alive(now)
	# 音频系统健康检查 - 每5秒检查一次
	audio_health_check_counter += 1
	if audio_health_check_counter >= 300:  # 60fps * 5秒 = 300帧
		audio_health_check_counter = 0
		check_audio_health(now)
	if update_state == "downloading":
		update_download_progress(now)
	if voice_enabled:
		poll_voice_capture()
	if mode == "online_lobby" or mode == "online_game":
		poll_online(now)

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_RESUMED or what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		recover_audio_after_screen_change()
		update_safe_area_layout()
	elif what == NOTIFICATION_WM_SIZE_CHANGED or what == NOTIFICATION_WM_DPI_CHANGE:
		update_safe_area_layout()
		call_deferred("refresh_current_screen")

func _input(event: InputEvent) -> void:
	var pressed = false
	if event is InputEventScreenTouch:
		pressed = event.pressed
	elif event is InputEventMouseButton:
		pressed = event.pressed
	if pressed:
		wake_audio_from_interaction()
	# 主菜单视差 - 鼠标/触摸移动驱动层次位移
	if menu_parallax_enabled and event is InputEventMouseMotion:
		update_menu_parallax(get_global_mouse_position())
	elif menu_parallax_enabled and event is InputEventScreenDrag:
		update_menu_parallax(event.position)

func setup_audio() -> void:
	print("AudioSetup: Starting audio system initialization")
	ensure_master_audio_bus()
	ensure_audio_layer()

	# v1.0.153: Android音频焦点请求
	if OS.get_name() == "Android":
		request_android_audio_focus()

	if bgm_player == null or not is_instance_valid(bgm_player):
		print("AudioSetup: Creating background music player")
		bgm_player = AudioStreamPlayer.new()
		bgm_player.name = "BackgroundMusic"
		bgm_player.volume_db = BGM_VOLUME_DB
		bgm_player.bus = "Master"
		bgm_player.process_mode = Node.PROCESS_MODE_ALWAYS
		attach_audio_node(bgm_player)
		if not bgm_player.finished.is_connected(_on_background_music_finished):
			bgm_player.finished.connect(_on_background_music_finished)
		print("AudioSetup: BGM player created successfully")
	else:
		print("AudioSetup: BGM player already exists")
	if sfx_player == null or not is_instance_valid(sfx_player):
		print("AudioSetup: Creating SFX player")
		sfx_player = AudioStreamPlayer.new()
		sfx_player.name = "TileSfx"
		sfx_player.volume_db = -1.0
		sfx_player.bus = "Master"
		sfx_player.process_mode = Node.PROCESS_MODE_ALWAYS
		attach_audio_node(sfx_player)
	if action_sfx_player == null or not is_instance_valid(action_sfx_player):
		print("AudioSetup: Creating action SFX player")
		action_sfx_player = AudioStreamPlayer.new()
		action_sfx_player.name = "ActionSfx"
		action_sfx_player.volume_db = -1.0
		action_sfx_player.bus = "Master"
		action_sfx_player.process_mode = Node.PROCESS_MODE_ALWAYS
		attach_audio_node(action_sfx_player)
	bgm_player.stream = audio_streams.get("bgm", null)
	if bgm_player.stream != null:
		print("AudioSetup: BGM stream loaded successfully")
	else:
		print("AudioSetup: WARNING - BGM stream is null")
	configure_background_music_stream()
	select_tts_voice()
	apply_audio_settings()
	print("AudioSetup: Audio system initialization complete")

func _exit_tree() -> void:
	shutdown_android_tts()



func unlock_achievement(key: String) -> bool:
	if not achievements.has(key):
		return false
	if achievements[key]:
		return false  # 已解锁
	achievements[key] = true
	save_achievements()
	show_toast("成就解锁：%s" % achievement_display_name(key), 2800)
	return true

func update_task_progress(task_id: String, amount: int = 1) -> void:
	if not task_progress.has(task_id):
		return
	task_progress[task_id] = int(task_progress.get(task_id, 0)) + amount
	# 检查任务完成
	for task in DAILY_TASKS:
		if task.id == task_id:
			var target = int(task.get("target", 1))
			if int(task_progress.get(task_id, 0)) >= target:
				claim_task_reward(task)
			break
	save_tasks()

func claim_task_reward(task: Dictionary) -> void:
	var reward = int(task.get("reward_coins", 0))
	currency["coins"] = int(currency.get("coins", 0)) + reward
	save_currency()
	show_toast("任务完成！+%d金币" % reward, 2500)


func use_item(item_id: String) -> bool:
	if int(inventory.get(item_id, 0)) <= 0:
		return false
	inventory[item_id] = int(inventory.get(item_id, 0)) - 1
	save_inventory()
	show_toast("使用道具：%s" % item_display_name(item_id), 1800)
	return true


func add_coins(amount: int) -> void:
	currency["coins"] = int(currency.get("coins", 0)) + amount
	save_currency()
	# 金币变化toast提示
	if amount > 0 and mode == "menu":
		show_toast("💰 +%d 金币" % amount)

func add_gems(amount: int) -> void:
	currency["gems"] = int(currency.get("gems", 0)) + amount
	save_currency()
	if amount > 0 and mode == "menu":
		show_toast("💎 +%d 宝石" % amount)


func apply_audio_settings() -> void:
	if bgm_player == null or not is_instance_valid(bgm_player):
		return
	ensure_master_audio_bus()
	configure_background_music_stream()
	bgm_player.volume_db = BGM_VOLUME_DB
	if music_enabled and audio_runtime_enabled() and bgm_player.stream != null:
		if not bgm_player.playing:
			bgm_player.play()
	elif bgm_player.playing:
		bgm_player.stop()

func audio_runtime_enabled() -> bool:
	return DisplayServer.get_name().to_lower() != "headless"

func wake_audio_from_interaction() -> void:
	if not audio_touch_unlocked:
		# v1.0.150: 首次交互也改为异步，不阻塞UI
		print("AudioWake: 首次用户交互，异步初始化音频系统")
		audio_touch_unlocked = true
		# 立即异步执行，不阻塞按钮响应
		call_deferred("_wake_audio_first_time")
	else:
		# 后续交互：异步
		call_deferred("_wake_audio_deferred")

func _wake_audio_first_time() -> void:
	print("AudioWake: 开始异步初始化")
	ensure_master_audio_bus()
	print("AudioWake: 主音频总线已确保")
	warm_speech_backend()
	print("AudioWake: TTS初始化完成")
	if music_enabled:
		print("AudioWake: 准备启动背景音乐")
		start_background_music()
	print("AudioWake: 首次初始化完成")

func _wake_audio_deferred() -> void:
	ensure_master_audio_bus()
	warm_speech_backend()
	if music_enabled:
		start_background_music()

func recover_audio_after_screen_change() -> void:
	if not audio_runtime_enabled():
		return
	ensure_master_audio_bus()
	warm_speech_backend()
	if music_enabled:
		call_deferred("start_background_music")

func switch_bgm_track() -> void:
	# v1.0.157: 切换到下一首BGM
	current_bgm_index = (current_bgm_index + 1) % BGM_TRACKS.size()
	var track = BGM_TRACKS[current_bgm_index]
	print("BGM: 切换到", track["name"], " - ", track["path"])

	# 停止当前BGM
	if bgm_player != null and is_instance_valid(bgm_player) and bgm_player.playing:
		bgm_player.stop()

	# 加载新BGM
	var new_stream = load(track["path"])
	if new_stream == null:
		print("BGM: 警告 - 无法加载", track["path"])
		set_status("BGM文件不存在: " + track["name"])
		return

	audio_streams["bgm"] = new_stream

	# 更新播放器
	if bgm_player != null and is_instance_valid(bgm_player):
		bgm_player.stream = new_stream
		configure_background_music_stream()
		if music_enabled:
			bgm_player.play()
			print("BGM: 开始播放", track["name"])
			set_status("正在播放: " + track["name"])

func start_background_music() -> void:
	if not music_enabled or not audio_runtime_enabled():
		print("BGM: 音乐已关闭或音频不可用")
		return

	# 确保播放器存在
	if bgm_player == null or not is_instance_valid(bgm_player):
		print("BGM: 播放器不存在，调用setup_audio")
		setup_audio()
		if bgm_player == null or not is_instance_valid(bgm_player):
			print("BGM: ERROR - setup_audio后播放器仍然为null")
			return

	# 确保音频流已加载
	if bgm_player.stream == null:
		print("BGM: 音频流为null，尝试加载")
		bgm_player.stream = audio_streams.get("bgm", null)
		if bgm_player.stream == null:
			print("BGM: ERROR - 音频流加载失败")
			return
		print("BGM: 音频流加载成功")

	# 配置循环
	configure_background_music_stream()

	# 确保主音频总线开启
	ensure_master_audio_bus()

	# 如果已经在播放，不要重复播放
	if bgm_player.playing:
		print("BGM: 已经在播放中")
		return

	# v1.0.149: 使用AudioServer直接播放，绕过可能的播放阻止
	print("BGM: 尝试方法1 - 标准play()")
	bgm_player.stream_paused = false
	bgm_player.volume_db = BGM_VOLUME_DB
	bgm_player.play()

	# 等待一帧验证
	await get_tree().process_frame

	if bgm_player.playing:
		print("BGM: ✓ 方法1成功")
		next_bgm_retry_msec = Time.get_ticks_msec() + 850
		return

	# 方法1失败，尝试方法2：从0位置开始
	print("BGM: 尝试方法2 - play(0.0)")
	bgm_player.play(0.0)
	await get_tree().process_frame

	if bgm_player.playing:
		print("BGM: ✓ 方法2成功")
		next_bgm_retry_msec = Time.get_ticks_msec() + 850
		return

	# 方法2失败，尝试方法3：重新加载stream
	print("BGM: 尝试方法3 - 重新加载stream")
	var stream_backup = bgm_player.stream
	bgm_player.stream = null
	await get_tree().process_frame
	bgm_player.stream = stream_backup
	configure_background_music_stream()
	bgm_player.play()
	await get_tree().process_frame

	if bgm_player.playing:
		print("BGM: ✓ 方法3成功")
		next_bgm_retry_msec = Time.get_ticks_msec() + 850
		return

	# 方法3失败，尝试方法4：完全重建播放器
	print("BGM: 尝试方法4 - 重建播放器")
	if bgm_player.get_parent() != null:
		bgm_player.get_parent().remove_child(bgm_player)
	bgm_player.queue_free()
	bgm_player = null
	setup_audio()
	if bgm_player != null and bgm_player.stream != null:
		bgm_player.play()
		await get_tree().process_frame
		if bgm_player.playing:
			print("BGM: ✓ 方法4成功")
		else:
			print("BGM: ✗ 所有方法都失败")

	next_bgm_retry_msec = Time.get_ticks_msec() + 850

func configure_background_music_stream() -> void:
	if bgm_player == null or not is_instance_valid(bgm_player) or bgm_player.stream == null:
		return
	var bgm_mp3 = bgm_player.stream as AudioStreamMP3
	if bgm_mp3 != null:
		bgm_mp3.loop = true
		return
	var bgm_wav = bgm_player.stream as AudioStreamWAV
	if bgm_wav != null:
		bgm_wav.loop_mode = AudioStreamWAV.LOOP_FORWARD

func keep_background_music_alive(now_msec: int = -1) -> void:
	if not music_enabled or not audio_runtime_enabled():
		return
	if bgm_player != null and is_instance_valid(bgm_player) and bgm_player.playing:
		return
	var now = now_msec if now_msec >= 0 else Time.get_ticks_msec()
	if now < next_bgm_retry_msec:
		return
	start_background_music()

func check_audio_health(now_msec: int) -> void:
	# 音频系统健康检查，用于检测和恢复音频问题
	if not audio_touch_unlocked:
		return  # 用户还未激活音频，跳过检查

	# 检查背景音乐状态
	if music_enabled and audio_runtime_enabled():
		if bgm_player == null or not is_instance_valid(bgm_player):
			print("AudioHealth: BGM player lost, recreating...")
			setup_audio()
			return

		if bgm_player.stream == null:
			print("AudioHealth: BGM stream lost, reloading...")
			bgm_player.stream = audio_streams.get("bgm", null)
			configure_background_music_stream()

		# 如果音乐应该播放但没有播放，且已经很久没检查了
		if not bgm_player.playing and (now_msec - last_bgm_health_check) > 10000:
			last_bgm_health_check = now_msec
			print("AudioHealth: BGM should be playing but isn't, attempting restart...")
			# 强制重新初始化
			ensure_master_audio_bus()
			start_background_music()

	# 检查音效播放器
	if sfx_enabled and (sfx_player == null or not is_instance_valid(sfx_player)):
		print("AudioHealth: SFX player lost, recreating...")
		setup_audio()

func _on_background_music_finished() -> void:
	next_bgm_retry_msec = 0
	start_background_music()

func play_sfx(name: String, volume_db: float = -3.0) -> void:
	if not sfx_enabled or not audio_runtime_enabled():
		return
	ensure_master_audio_bus()
	if music_enabled and bgm_player != null and is_instance_valid(bgm_player) and not bgm_player.playing:
		start_background_music()
	var stream = audio_streams.get(name, null)
	if stream == null:
		return
	var player = action_sfx_player if is_action_sfx(name) else sfx_player
	if player == null or not is_instance_valid(player):
		player = make_one_shot_sfx_player(stream, boosted_sfx_volume_db(volume_db))
		player.play()
	else:
		play_stream_on_audio_player(player, stream, boosted_sfx_volume_db(volume_db))

func is_action_sfx(name: String) -> bool:
	return ["peng", "gang", "win"].has(name)

func play_stream_on_audio_player(player: AudioStreamPlayer, stream: AudioStream, volume_db: float) -> void:
	if player == null or stream == null:
		return
	if player.playing:
		player.stop()
	player.stream = stream
	player.volume_db = volume_db
	player.bus = "Master"
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	attach_audio_node(player)
	player.play()

func boosted_sfx_volume_db(volume_db: float) -> float:
	return clamp(volume_db + SFX_VOLUME_BOOST_DB, -10.0, 1.5)

func make_one_shot_sfx_player(stream: AudioStream, volume_db: float) -> AudioStreamPlayer:
	var player = AudioStreamPlayer.new()
	player.name = "OneShotSfx"
	player.stream = stream
	player.volume_db = volume_db
	player.bus = "Master"
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	attach_audio_node(player)
	player.finished.connect(func() -> void:
		if is_instance_valid(player):
			player.queue_free()
	)
	if get_tree() != null:
		get_tree().create_timer(3.0).timeout.connect(func() -> void:
			if is_instance_valid(player):
				player.queue_free()
		)
	return player

func select_tts_voice() -> void:
	tts_voice_id = ""
	if ClassDB.class_has_method("DisplayServer", "tts_get_voices_for_language"):
		for language in ["zh", "zh_CN", "zh-CN", "cmn"]:
			var zh_voices = DisplayServer.tts_get_voices_for_language(language)
			if not zh_voices.is_empty():
				tts_voice_id = tts_voice_identifier(zh_voices[0])
				if tts_voice_id != "":
					return
	if not ClassDB.class_has_method("DisplayServer", "tts_get_voices"):
		return
	for voice in DisplayServer.tts_get_voices():
		var voice_id = tts_voice_identifier(voice)
		if typeof(voice) == TYPE_DICTIONARY:
			var language = str(voice.get("language", "")).to_lower()
			if voice_id != "" and (tts_voice_id == "" or language.begins_with("zh")):
				tts_voice_id = voice_id
				if language.begins_with("zh"):
					return
		elif tts_voice_id == "":
			tts_voice_id = voice_id

func tts_voice_identifier(voice) -> String:
	if typeof(voice) == TYPE_DICTIONARY:
		return str(voice.get("id", voice.get("name", "")))
	return str(voice)

func display_tts_runtime_available() -> bool:
	return ClassDB.class_has_method("DisplayServer", "tts_speak")

func warm_speech_backend() -> void:
	if not tts_enabled or not audio_runtime_enabled():
		return
	if display_tts_runtime_available():
		if tts_voice_id == "":
			select_tts_voice()
		return
	setup_android_tts()

func can_speak_text() -> bool:
	if not tts_enabled or not audio_runtime_enabled():
		return false
	if display_tts_runtime_available():
		return true
	if android_tts_runtime_available():
		setup_android_tts()
		return true
	return false

func speech_backend_ready() -> bool:
	if not tts_enabled or not audio_runtime_enabled():
		return false
	if display_tts_runtime_available():
		return true
	if android_tts_runtime_available():
		setup_android_tts()
		if android_tts != null:
			configure_android_tts()
			return Time.get_ticks_msec() - android_tts_started_msec >= ANDROID_TTS_WARMUP_MSEC
		if android_tts_requested and android_tts_requested_msec > 0:
			if Time.get_ticks_msec() - android_tts_requested_msec < ANDROID_TTS_FALLBACK_MSEC:
				return false
		return ClassDB.class_has_method("DisplayServer", "tts_speak")
	return ClassDB.class_has_method("DisplayServer", "tts_speak")

func speak_text(text: String, interrupt: bool = false) -> bool:
	if text.strip_edges() == "" or not can_speak_text():
		return false
	if speak_text_display(text, interrupt):
		return true
	if speak_text_android(text, interrupt):
		return true
	return false

func speak_text_display(text: String, interrupt: bool = false) -> bool:
	if not display_tts_runtime_available():
		return false
	if tts_voice_id == "":
		select_tts_voice()
	ensure_master_audio_bus()
	if interrupt and ClassDB.class_has_method("DisplayServer", "tts_stop"):
		DisplayServer.tts_stop()
	var utterance_id = next_tts_utterance_id()
	DisplayServer.tts_speak(text, tts_voice_id, 100, 1.0, 1.03, utterance_id, interrupt)
	return true

func request_android_audio_focus() -> void:
	# v1.0.154: 请求Android音频焦点，针对小米MIUI优化
	if not OS.get_name() == "Android":
		return

	print("AudioFocus: 请求Android音频焦点（小米MIUI优化）")

	# 强制设置AudioServer为最大音量
	var master_idx = AudioServer.get_bus_index("Master")
	if master_idx >= 0:
		AudioServer.set_bus_volume_db(master_idx, 0.0)
		AudioServer.set_bus_mute(master_idx, false)
		print("AudioFocus: Master总线音量=0dB，未静音")

	# 小米专属：强制启用所有音频效果
	var bus_count = AudioServer.get_bus_count()
	for i in range(bus_count):
		AudioServer.set_bus_mute(i, false)
		print("AudioFocus: 总线", i, AudioServer.get_bus_name(i), "已解除静音")

func play_test_tone_440hz() -> void:
	# v1.0.155: 播放440Hz测试音，验证AudioStreamGenerator是否能工作
	print("TestTone: 创建440Hz测试音播放器")

	var generator = AudioStreamGenerator.new()
	generator.mix_rate = 44100.0
	generator.buffer_length = 0.1

	var tone_player = AudioStreamPlayer.new()
	tone_player.name = "TestTonePlayer"
	tone_player.stream = generator
	tone_player.volume_db = 0.0
	tone_player.bus = "Master"
	tone_player.process_mode = Node.PROCESS_MODE_ALWAYS

	ensure_audio_layer()
	get_node("/root/Main/AudioLayer").add_child(tone_player)

	tone_player.play()
	print("TestTone: 开始播放440Hz音调")

	var playback = tone_player.get_stream_playback() as AudioStreamGeneratorPlayback
	if playback == null:
		print("TestTone: ERROR - 无法获取AudioStreamGeneratorPlayback")
		tone_player.queue_free()
		return

	# 生成1秒的440Hz正弦波
	var frequency = 440.0
	var sample_rate = 44100.0
	var samples_to_generate = int(sample_rate * 1.0)  # 1秒
	var phase = 0.0

	for i in range(samples_to_generate):
		var sample = sin(phase * TAU)
		playback.push_frame(Vector2(sample, sample))
		phase = fmod(phase + frequency / sample_rate, 1.0)

		# 每1000个样本让出一帧，避免阻塞
		if i % 1000 == 0:
			await get_tree().process_frame

	print("TestTone: 440Hz音调生成完成")

	# 等待播放完成后清理
	await get_tree().create_timer(1.2).timeout
	tone_player.stop()
	tone_player.queue_free()
	print("TestTone: 测试音播放器已清理")

func android_tts_runtime_available() -> bool:
	return OS.get_name() == "Android" and Engine.has_singleton("AndroidRuntime") and Engine.has_singleton("JavaClassWrapper")

func setup_android_tts() -> void:
	if not android_tts_runtime_available() or android_tts != null:
		return
	var now = Time.get_ticks_msec()
	if android_tts_requested:
		if android_tts_requested_msec > 0 and now - android_tts_requested_msec < ANDROID_TTS_FALLBACK_MSEC:
			return
		android_tts_requested = false
		android_tts_requested_msec = 0
	if android_tts_retry_after_msec > 0 and now < android_tts_retry_after_msec:
		return
	android_tts_requested = true
	android_tts_requested_msec = now
	var android_runtime = Engine.get_singleton("AndroidRuntime")
	var activity = android_runtime.getActivity()
	if activity == null:
		android_tts_requested = false
		android_tts_requested_msec = 0
		android_tts_retry_after_msec = now + ANDROID_TTS_RETRY_MSEC
		return
	var create_tts = func() -> void:
		var TextToSpeech = JavaClassWrapper.wrap("android.speech.tts.TextToSpeech")
		var created_tts = TextToSpeech.TextToSpeech(activity, null)
		var exception = JavaClassWrapper.get_exception()
		if exception != null or created_tts == null:
			android_tts = null
			android_tts_requested = false
			android_tts_requested_msec = 0
			android_tts_retry_after_msec = Time.get_ticks_msec() + ANDROID_TTS_RETRY_MSEC
			return
		android_tts = created_tts
		android_tts_started_msec = Time.get_ticks_msec()
		android_tts_retry_after_msec = 0
		android_tts_language_configured = false
	if activity.has_java_method("runOnUiThread"):
		activity.runOnUiThread(android_runtime.createRunnableFromGodotCallable(create_tts))
	else:
		create_tts.call()

func configure_android_tts() -> void:
	if android_tts == null or android_tts_language_configured:
		return
	if Time.get_ticks_msec() - android_tts_started_msec < ANDROID_TTS_WARMUP_MSEC:
		return
	var Locale = JavaClassWrapper.wrap("java.util.Locale")
	var result = android_tts.setLanguage(Locale.CHINA)
	if int(result) == -1 or int(result) == -2:
		android_tts.setLanguage(Locale.CHINESE)
	var exception = JavaClassWrapper.get_exception()
	if exception != null:
		android_tts_language_configured = false
		android_tts_retry_after_msec = Time.get_ticks_msec() + ANDROID_TTS_RETRY_MSEC
		return
	android_tts.setSpeechRate(1.08)
	android_tts.setPitch(1.02)
	android_tts_language_configured = true

func speak_text_android(text: String, interrupt: bool = false) -> bool:
	if not android_tts_runtime_available():
		return false
	setup_android_tts()
	if android_tts == null:
		return false
	configure_android_tts()
	if Time.get_ticks_msec() - android_tts_started_msec < ANDROID_TTS_WARMUP_MSEC:
		return false
	var queue_mode = 0 if interrupt else 1
	var utterance_id = "mahjong-%d" % next_tts_utterance_id()
	var result = android_tts.speak(text, queue_mode, make_android_tts_params(), utterance_id)
	var exception = JavaClassWrapper.get_exception()
	if exception != null:
		android_tts = null
		android_tts_requested = false
		android_tts_requested_msec = 0
		android_tts_language_configured = false
		android_tts_retry_after_msec = Time.get_ticks_msec() + ANDROID_TTS_RETRY_MSEC
		return false
	return int(result) == 0

func make_android_tts_params():
	var Bundle = JavaClassWrapper.wrap("android.os.Bundle")
	var wrap_exception = JavaClassWrapper.get_exception()
	if wrap_exception != null or Bundle == null:
		return null
	var params = Bundle.Bundle()
	var exception = JavaClassWrapper.get_exception()
	if exception != null:
		return null
	return params

func next_tts_utterance_id() -> int:
	var utterance_id = tts_utterance_id
	tts_utterance_id += 1
	if tts_utterance_id > 1000000000:
		tts_utterance_id = 1
	return utterance_id

func shutdown_android_tts() -> void:
	if android_tts == null:
		return
	if android_tts.has_java_method("stop"):
		android_tts.stop()
	if android_tts.has_java_method("shutdown"):
		android_tts.shutdown()
	android_tts = null
	android_tts_requested = false
	android_tts_requested_msec = 0
	android_tts_retry_after_msec = 0
	android_tts_language_configured = false

func stop_current_speech() -> void:
	if android_tts != null and android_tts.has_java_method("stop"):
		android_tts.stop()
	if ClassDB.class_has_method("DisplayServer", "tts_stop") and audio_runtime_enabled():
		DisplayServer.tts_stop()

func speak_text_delayed(text: String, delay_seconds: float = 0.0, interrupt: bool = false) -> void:
	if text.strip_edges() == "":
		return
	if not tts_enabled:
		return
	if interrupt:
		speech_queue.clear()
		speech_queue_generation += 1
		stop_current_speech()
	speech_queue.append({
		"text": text,
		"delay": max(0.0, delay_seconds),
		"interrupt": interrupt,
		"generation": speech_queue_generation,
		"attempts": 0,
		"queued_msec": Time.get_ticks_msec(),
	})
	if not speech_queue_active:
		call_deferred("drain_speech_queue")

func speak_voice_clips_delayed(clips: Array, delay_seconds: float = 0.0, interrupt: bool = false) -> bool:
	if clips.is_empty() or not tts_enabled or not audio_runtime_enabled():
		return false
	var normalized: Array[String] = []
	for clip in clips:
		var key = str(clip)
		if key == "" or voice_streams.get(key, null) == null:
			return false
		normalized.append(key)
	if interrupt:
		speech_queue.clear()
		speech_queue_generation += 1
		stop_current_speech()
	speech_queue.append({
		"clips": normalized,
		"delay": max(0.0, delay_seconds),
		"interrupt": interrupt,
		"generation": speech_queue_generation,
		"queued_msec": Time.get_ticks_msec(),
	})
	if not speech_queue_active:
		call_deferred("drain_speech_queue")
	return true

func drain_speech_queue() -> void:
	if speech_queue_active:
		return
	speech_queue_active = true
	while not speech_queue.is_empty():
		var next_item: Dictionary = speech_queue[0]
		if next_item.has("clips"):
			var clip_item: Dictionary = speech_queue.pop_front()
			var clip_generation = int(clip_item.get("generation", speech_queue_generation))
			var clip_delay = float(clip_item.get("delay", 0.0))
			if clip_delay > 0.0:
				await get_tree().create_timer(clip_delay).timeout
			if clip_generation != speech_queue_generation:
				continue
			var clips: Array = clip_item.get("clips", [])
			for clip in clips:
				if clip_generation != speech_queue_generation:
					break
				play_voice_clip(str(clip))
				await get_tree().create_timer(SPEECH_CLIP_GAP_SECONDS).timeout
			if clip_generation == speech_queue_generation and SPEECH_CLIP_TAIL_SECONDS > 0.0:
				await get_tree().create_timer(SPEECH_CLIP_TAIL_SECONDS).timeout
			continue
		if not speech_backend_ready():
			var queued_msec = int(speech_queue[0].get("queued_msec", Time.get_ticks_msec()))
			if Time.get_ticks_msec() - queued_msec < SPEECH_MAX_READY_WAIT_MSEC and can_speak_text():
				await get_tree().create_timer(SPEECH_READY_RETRY_SECONDS).timeout
				continue
			speech_queue.pop_front()
			continue
		var item: Dictionary = speech_queue.pop_front()
		var generation = int(item.get("generation", speech_queue_generation))
		var delay = float(item.get("delay", 0.0))
		if delay > 0.0:
			await get_tree().create_timer(delay).timeout
		if generation != speech_queue_generation:
			continue
		var spoken = speak_text(str(item.get("text", "")), bool(item.get("interrupt", false)))
		if spoken:
			await get_tree().create_timer(0.34).timeout
		else:
			var attempts = int(item.get("attempts", 0))
			if attempts < 2 and can_speak_text():
				item["attempts"] = attempts + 1
				speech_queue.push_front(item)
				await get_tree().create_timer(SPEECH_READY_RETRY_SECONDS).timeout
	speech_queue_active = false

func play_voice_clip(key: String) -> bool:
	if key == "" or not tts_enabled or not audio_runtime_enabled():
		return false
	var stream = voice_streams.get(key, null)
	if stream == null:
		return false
	ensure_master_audio_bus()
	if music_enabled and bgm_player != null and is_instance_valid(bgm_player) and not bgm_player.playing:
		start_background_music()
	var player = make_one_shot_sfx_player(stream, VOICE_VOLUME_DB)
	player.play()
	return true

func speak_tile_call(tile: String) -> void:
	if speak_voice_clips_delayed([voice_clip_key_for_tile(tile)], SPEECH_TILE_DELAY_SECONDS, false):
		return
	speak_text_delayed(tile_speech_label(tile), SPEECH_TILE_DELAY_SECONDS, false)

func speak_action_call(action: String, tile: String) -> void:
	var clips: Array[String] = []
	var action_key = voice_clip_key_for_action(action)
	if action_key != "":
		clips.append(action_key)
	var tile_key = voice_clip_key_for_tile(tile)
	if tile_key != "":
		clips.append(tile_key)
	if not clips.is_empty() and speak_voice_clips_delayed(clips, SPEECH_ACTION_DELAY_SECONDS, true):
		return
	var suffix = tile_speech_label(tile)
	speak_text_delayed(action + suffix if suffix != "" else action, SPEECH_ACTION_DELAY_SECONDS, true)

func ai_draw_delay() -> float:
	return AI_DRAW_DELAY_SECONDS if fast_mode_enabled else 0.18

func ai_discard_delay() -> float:
	return AI_DISCARD_DELAY_SECONDS if fast_mode_enabled else 0.35

func ai_action_gap_delay() -> float:
	return AI_ACTION_GAP_SECONDS if fast_mode_enabled else 0.35

func human_discard_response_gap_delay() -> float:
	return HUMAN_DISCARD_RESPONSE_GAP_SECONDS if fast_mode_enabled else 0.05

func ai_return_to_human_gap_delay() -> float:
	return AI_RETURN_TO_HUMAN_GAP_SECONDS if fast_mode_enabled else 0.12

func human_draw_delay() -> float:
	return HUMAN_DRAW_DELAY_SECONDS if fast_mode_enabled else 0.08

func pace_after_human_discard_response() -> void:
	await get_tree().process_frame
	var delay = human_discard_response_gap_delay()
	if delay > 0.0:
		await get_tree().create_timer(delay).timeout

func pace_after_visible_ai_action(returning_to_human: bool = false) -> void:
	await get_tree().process_frame
	var delay = ai_return_to_human_gap_delay() if returning_to_human else ai_action_gap_delay()
	if delay > 0.0:
		await get_tree().create_timer(delay).timeout

func toggle_music_setting() -> void:
	music_enabled = not music_enabled
	apply_audio_settings()
	save_settings()
	refresh_current_screen()

func toggle_sfx_setting() -> void:
	sfx_enabled = not sfx_enabled
	save_settings()
	refresh_current_screen()

func toggle_tts_setting() -> void:
	tts_enabled = not tts_enabled
	save_settings()
	refresh_current_screen()

func toggle_fast_mode_setting() -> void:
	fast_mode_enabled = not fast_mode_enabled
	save_settings()
	refresh_current_screen()

func toggle_fx_setting() -> void:
	fx_enabled = not fx_enabled
	save_settings()
	if not fx_enabled:
		clear_fx_overlays()
	refresh_current_screen()

func test_audio_setting() -> void:
	music_enabled = true
	sfx_enabled = true
	tts_enabled = true
	save_settings()

	# 强制同步初始化
	ensure_master_audio_bus()
	warm_speech_backend()

	print("===== 开始音频测试 v1.0.155 =====")

	# v1.0.155: 先测试AudioStreamGenerator生成的音调
	print("AudioTest: 播放440Hz测试音（1秒）")
	play_test_tone_440hz()
	await get_tree().create_timer(1.2).timeout

	if music_enabled:
		start_background_music()

	# 播放测试音效
	await get_tree().create_timer(0.3).timeout
	play_sfx("discard", -1.0)
	await get_tree().create_timer(0.7).timeout

	# 收集诊断信息
	var diag = []
	diag.append("【音频系统诊断 v1.0.156】")
	diag.append("")
	diag.append("1. 用户激活: " + ("是" if audio_touch_unlocked else "否"))
	diag.append("2. 设备: 小米手机 (MIUI)")
	diag.append("")
	diag.append("⚠️ v1.0.156重大改动")
	diag.append("BGM已从WAV改为MP3格式")
	diag.append("因为您能听到TTS语音提示")
	diag.append("说明音频系统正常")
	diag.append("只是WAV格式不兼容")
	diag.append("")
	diag.append("【请回答】")
	diag.append("1. 能听到背景音乐了吗？")
	diag.append("2. 刚才的440Hz测试音听到了吗？")
	diag.append("")

	if bgm_player != null and is_instance_valid(bgm_player):
		diag.append("3. BGM播放器: 正常")
		diag.append("4. BGM音频流: " + ("已加载" if bgm_player.stream != null else "未加载"))
		diag.append("5. BGM正在播放: " + ("是" if bgm_player.playing else "否"))
		diag.append("6. BGM音量: " + str(bgm_player.volume_db) + "dB (0dB=最大)")
		diag.append("7. 音频总线: " + bgm_player.bus)

		# 检查音频总线音量
		var master_idx = AudioServer.get_bus_index("Master")
		if master_idx >= 0:
			var bus_vol = AudioServer.get_bus_volume_db(master_idx)
			var bus_muted = AudioServer.is_bus_mute(master_idx)
			diag.append("8. Master总线音量: " + str(bus_vol) + "dB")
			diag.append("9. Master总线静音: " + ("是" if bus_muted else "否"))

		if bgm_player.stream != null:
			var stream_type = bgm_player.stream.get_class()
			diag.append("10. 音频格式: " + stream_type)

			# 检查音频流大小
			if stream_type == "AudioStreamWAV":
				var wav = bgm_player.stream as AudioStreamWAV
				if wav != null and wav.data != null:
					diag.append("11. 音频数据大小: " + str(wav.data.size()) + " bytes")

		if bgm_player.playing:
			diag.append("")
			diag.append("✓ BGM播放成功")
			diag.append("")
			diag.append("小米手机听不到声音？")
			diag.append("请检查以下MIUI设置:")
			diag.append("")
			diag.append("1. 断开蓝牙设备")
			diag.append("2. 按音量+键调整【媒体音量】")
			diag.append("3. 关闭【游戏加速】")
			diag.append("4. 关闭【省电模式】")
			diag.append("5. 设置→应用管理→本应用")
			diag.append("   →省电策略→无限制")
			diag.append("6. 尝试重启手机")
		else:
			diag.append("")
			diag.append("✗ BGM未播放")
			diag.append("")
			diag.append("已尝试4种播放方法:")
			diag.append("1. 标准play()")
			diag.append("2. play(0.0)从头播放")
			diag.append("3. 重新加载音频流")
			diag.append("4. 完全重建播放器")
			diag.append("")
			diag.append("所有方法都被系统阻止")
	else:
		diag.append("3. ✗ BGM播放器未初始化")

	diag.append("")
	diag.append("点击任意位置关闭")

	print("===== 诊断结果 =====")
	for line in diag:
		print(line)

	# 在屏幕中央显示诊断窗口
	show_diagnostic_dialog(diag)

func show_diagnostic_dialog(lines: Array) -> void:
	# 清除当前屏幕
	clear_screen()

	# 创建半透明背景
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.72)
	root_layer.add_child(bg)
	apply_rect(bg, rect_full(0, 0, 1, 1))

	# 创建诊断信息面板
	var panel = make_panel(root_layer, rect_full(0.1, 0.15, 0.9, 0.85), Color(0.026, 0.058, 0.060, 0.95), 10, Color(0.66, 0.55, 0.28, 0.62))

	# 创建文本容器
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	panel.add_child(vbox)
	apply_rect(vbox, rect_full(0.05, 0.05, 0.95, 0.95))

	# 添加每一行文本
	for line in lines:
		var label = Label.new()
		label.text = line
		label.add_theme_font_size_override("font_size", 28)
		if line.begins_with("【"):
			label.add_theme_color_override("font_color", Color(0.94, 0.86, 0.44))
			label.add_theme_font_size_override("font_size", 36)
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		elif line.begins_with("✓"):
			label.add_theme_color_override("font_color", Color(0.42, 0.82, 0.56))
		elif line.begins_with("✗"):
			label.add_theme_color_override("font_color", Color(0.84, 0.42, 0.38))
		elif line.begins_with("•"):
			label.add_theme_color_override("font_color", Color(0.76, 0.78, 0.84))
		else:
			label.add_theme_color_override("font_color", Color(0.88, 0.90, 0.91))
		vbox.add_child(label)

	# 添加点击关闭功能
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	bg.gui_input.connect(func(event):
		if event is InputEventScreenTouch and event.pressed:
			refresh_current_screen()
	)

func toggle_settings_panel() -> void:
	settings_panel_open = not settings_panel_open
	reset_progress_confirming = false
	refresh_current_screen()

func close_settings_panel() -> void:
	settings_panel_open = false
	reset_progress_confirming = false
	refresh_current_screen()

func show_exit_confirm() -> void:
	"""显示退出确认对话框"""
	if exit_confirm_panel != null and is_instance_valid(exit_confirm_panel):
		return
	var overlay = Control.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.modulate = Color(1, 1, 1, 0)
	root_layer.add_child(overlay)
	exit_confirm_panel = overlay

	# 遮罩层
	var mask = ColorRect.new()
	mask.color = Color(0, 0, 0, 0.65)
	mask.set_anchors_preset(Control.PRESET_FULL_RECT)
	mask.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_child(mask)

	# 对话框面板
	var dialog = make_panel(overlay, rect_full(0.28, 0.35, 0.72, 0.65), Color(0.012, 0.026, 0.032, 0.98), 20, Color(0.48, 0.40, 0.24, 0.52), 5)
	dialog.name = "ExitConfirmDialog"
	dialog.add_child(make_color_rect(rect_full(0.006, 0.04, 0.012, 0.96), Color(0.90, 0.76, 0.36, 0.72)))
	draw_exit_confirm_art(dialog)

	# 标题
	var title = make_label(dialog, "确认退出", 24, Color(0.94, 0.86, 0.48), true)
	apply_rect(title, rect_full(0.08, 0.08, 0.92, 0.25))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# 提示文本
	var message = "是否退出当前游戏？\n进度将自动保存。"
	var msg_label = make_label(dialog, message, 16, Color(0.80, 0.84, 0.78), false)
	apply_rect(msg_label, rect_full(0.10, 0.47, 0.90, 0.64))
	msg_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	msg_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	draw_exit_confirm_choice_art(dialog)

	# 按钮行
	var button_row = HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	button_row.add_theme_constant_override("separation", 16)
	apply_rect(button_row, rect_full(0.12, 0.72, 0.88, 0.92))
	dialog.add_child(button_row)

	# 继续游戏按钮
	var continue_btn = make_small_button("继续游戏", Color(0.28, 0.52, 0.44), func() -> void:
		hide_exit_confirm()
	)
	continue_btn.custom_minimum_size = Vector2(140, 52)
	button_row.add_child(continue_btn)

	# 退出按钮
	var exit_btn = make_small_button("退出游戏", Color(0.56, 0.36, 0.30), func() -> void:
		hide_exit_confirm()
		save_offline_progress()
		show_menu()
	)
	exit_btn.custom_minimum_size = Vector2(140, 52)
	button_row.add_child(exit_btn)

	# 淡入动画
	var tween = create_tween()
	tween.tween_property(overlay, "modulate", Color(1, 1, 1, 1), 0.2)

func draw_exit_confirm_art(parent: Control) -> Control:
	var art = Control.new()
	art.name = "ExitConfirmArt"
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(art, rect_full(0.150, 0.255, 0.850, 0.455))
	parent.add_child(art)
	var rail = make_panel(art, rect_full(0.120, 0.450, 0.880, 0.570), Color(0.48, 0.64, 0.54, 0.18), 999, Color(0.80, 0.88, 0.62, 0.14), 0)
	rail.name = "ExitConfirmSaveRail"
	var table_node = make_panel(art, rect_full(0.060, 0.180, 0.210, 0.840), Color(0.24, 0.48, 0.42, 0.46), 16, Color(0.48, 0.78, 0.64, 0.30), 0)
	table_node.name = "ExitConfirmTableNode"
	add_lucide_icon(table_node, "home", rect_full(0.22, 0.20, 0.78, 0.76), Color(0.88, 0.94, 0.78, 0.82))
	var save_node = make_panel(art, rect_full(0.425, 0.130, 0.575, 0.870), Color(0.70, 0.56, 0.28, 0.36), 999, Color(0.96, 0.78, 0.38, 0.28), 0)
	save_node.name = "ExitConfirmSaveNode"
	add_lucide_icon(save_node, "check", rect_full(0.26, 0.22, 0.74, 0.74), Color(0.98, 0.92, 0.66, 0.86))
	var exit_node = make_panel(art, rect_full(0.790, 0.180, 0.940, 0.840), Color(0.54, 0.40, 0.34, 0.34), 16, Color(0.82, 0.62, 0.46, 0.24), 0)
	exit_node.name = "ExitConfirmLeaveNode"
	add_lucide_icon(exit_node, "chevron-right", rect_full(0.24, 0.22, 0.76, 0.76), Color(0.96, 0.84, 0.68, 0.80))
	for i in range(3):
		var left = 0.270 + float(i) * 0.145
		var pip = make_panel(art, rect_full(left, 0.385, left + 0.040, 0.635), Color(0.88, 0.72, 0.34, 0.42), 999, Color(1.0, 0.86, 0.46, 0.16), 0)
		pip.name = "ExitConfirmSavePip_%d" % i
	var glow = make_panel(art, rect_full(0.400, 0.070, 0.600, 0.930), Color(0.92, 0.76, 0.34, 0.14), 999, Color(1.0, 0.86, 0.46, 0.14), 0)
	glow.name = "ExitConfirmSaveGlow"
	if fx_enabled_effective() and DisplayServer.get_name().to_lower() != "headless":
		var tw := create_tween()
		tw.set_loops(3600)
		tw.tween_property(glow, "modulate:a", 0.38, 0.85).from(0.88)
		tw.tween_property(glow, "modulate:a", 0.88, 0.85).from(0.38)
	return art

func draw_exit_confirm_choice_art(parent: Control) -> Control:
	var art = Control.new()
	art.name = "ExitConfirmChoiceArt"
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(art, rect_full(0.120, 0.675, 0.880, 0.945))
	parent.add_child(art)
	var keep_rail = make_panel(art, rect_full(0.020, 0.180, 0.455, 0.820), Color(0.34, 0.68, 0.54, 0.10), 14, Color(0.54, 0.86, 0.66, 0.10), 0)
	keep_rail.name = "ExitConfirmKeepChoiceRail"
	var leave_rail = make_panel(art, rect_full(0.545, 0.180, 0.980, 0.820), Color(0.78, 0.52, 0.34, 0.10), 14, Color(0.92, 0.70, 0.48, 0.10), 0)
	leave_rail.name = "ExitConfirmLeaveChoiceRail"
	var keep_dot = make_panel(art, rect_full(0.055, 0.375, 0.105, 0.625), Color(0.48, 0.82, 0.62, 0.34), 999, Color(0.76, 0.94, 0.72, 0.16), 0)
	keep_dot.name = "ExitConfirmKeepChoiceDot"
	var leave_dot = make_panel(art, rect_full(0.895, 0.375, 0.945, 0.625), Color(0.88, 0.66, 0.38, 0.34), 999, Color(0.98, 0.82, 0.48, 0.16), 0)
	leave_dot.name = "ExitConfirmLeaveChoiceDot"
	var stamp = make_panel(art, rect_full(0.455, 0.260, 0.545, 0.740), Color(0.92, 0.74, 0.34, 0.18), 999, Color(1.0, 0.86, 0.46, 0.16), 0)
	stamp.name = "ExitConfirmSaveStamp"
	add_lucide_icon(stamp, "save", rect_full(0.250, 0.220, 0.750, 0.780), Color(0.98, 0.90, 0.62, 0.78))
	for i in range(2):
		var keep_spark = make_panel(art, rect_full(0.150 + float(i) * 0.145, 0.430, 0.178 + float(i) * 0.145, 0.570), Color(0.54, 0.86, 0.66, 0.22), 999, Color(0.78, 0.96, 0.74, 0.10), 0)
		keep_spark.name = "ExitConfirmKeepSpark_%d" % i
		var leave_spark = make_panel(art, rect_full(0.675 + float(i) * 0.145, 0.430, 0.703 + float(i) * 0.145, 0.570), Color(0.92, 0.70, 0.42, 0.22), 999, Color(1.0, 0.86, 0.50, 0.10), 0)
		leave_spark.name = "ExitConfirmLeaveSpark_%d" % i
	if fx_enabled_effective() and DisplayServer.get_name().to_lower() != "headless":
		var tw := create_tween()
		tw.set_loops(3600)
		tw.tween_property(stamp, "modulate:a", 0.48, 1.0).from(1.0)
		tw.tween_property(stamp, "modulate:a", 1.0, 1.0).from(0.48)
	return art

func hide_exit_confirm() -> void:
	"""隐藏退出确认对话框"""
	if exit_confirm_panel == null or not is_instance_valid(exit_confirm_panel):
		return
	var panel = exit_confirm_panel
	exit_confirm_panel = null
	var panel_id = panel.get_instance_id()
	var tween = create_tween()
	tween.tween_property(panel, "modulate", Color(1, 1, 1, 0), 0.15)
	tween.tween_callback(func() -> void:
		var target = instance_from_id(panel_id)
		if target != null and is_instance_valid(target):
			(target as Node).queue_free()
	)

func refresh_current_screen() -> void:
	if mode == "menu":
		show_menu(true)
	elif mode == "rules":
		show_rules_screen(true)
	elif mode == "stats":
		show_stats_screen(true)
	elif mode == "online_lobby":
		show_online_lobby(true)
	elif mode == "offline" or mode == "online_game":
		request_game_render()

func request_game_render() -> void:
	if mode != "offline" and mode != "online_game":
		return
	if game_render_queued:
		return
	game_render_queued = true
	call_deferred("flush_game_render")

func flush_game_render() -> void:
	var elapsed = Time.get_ticks_msec() - last_game_render_msec
	if last_game_render_msec > 0 and elapsed < UI_RENDER_MIN_INTERVAL_MSEC:
		await get_tree().create_timer(float(UI_RENDER_MIN_INTERVAL_MSEC - elapsed) / 1000.0).timeout
	game_render_queued = false
	if mode == "offline" or mode == "online_game":
		render_game()

func should_yield_before_ai_discard() -> bool:
	return game_render_queued


func clear_screen() -> void:
	for child in get_children():
		if child == audio_layer or child.name == "PersistentAudio":
			continue
		if child == update_request:
			continue
		if child == voice_mic_player:
			continue
		if child == bgm_player or child == sfx_player or child == action_sfx_player:
			continue
		if child == fx_layer:
			continue
		child.queue_free()
	screen_layer = null
	status_label = null
	logs_label = null
	action_bar = null
	update_dialog = null
	update_status_label = null
	update_progress_label = null
	update_progress = null
	update_art_fill = null
	update_art_status_light = null
	update_primary_button = null
	update_secondary_button = null
	safe_area_margins = current_safe_area_margins()
	screen_layer = Control.new()
	screen_layer.name = "ScreenLayer"
	screen_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(screen_layer)
	add_background(screen_layer)
	root_layer = Control.new()
	root_layer.name = "SafeContent"
	root_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	apply_safe_area_offsets(root_layer)
	screen_layer.add_child(root_layer)

func show_menu(instant: bool = false) -> void:
	if transition_active and not instant:
		return
	menu_parallax_enabled = false
	var _build_menu = func() -> void:
		_show_menu_impl()
	if instant or not fx_enabled_effective():
		_build_menu.call()
	else:
		play_screen_transition(_build_menu)

func _show_menu_impl() -> void:
	if voice_enabled:
		stop_voice_chat(false)
	mode = "menu"
	clear_fx_overlays()
	# 停止环境动画
	stop_ambient_animation()
	recover_audio_after_screen_change()
	clear_screen()

	# 增强的背景效果
	add_background(root_layer)

	# 添加国风装饰元素 - 水墨边框装饰
	make_ink_border(root_layer, rect_full(0.015, 0.025, 0.985, 0.225), 3.0)

	# 主标题区域 - 增大高度，更好的视觉层次
	var header = make_panel(root_layer, rect_full(0.02, 0.03, 0.98, 0.22), GUOFENG_PANEL_FILL, 22, GUOFENG_PANEL_BORDER)
	# 左侧金色装饰条
	header.add_child(make_color_rect(rect_full(0.006, 0.04, 0.016, 0.96), GOLD_GLOW))
	# 顶部高光线 - 更柔和
	header.add_child(make_color_rect(rect_full(0.016, 0.012, 0.984, 0.028), Color(1.0, 1.0, 1.0, 0.05)))
	# 底部分隔线 - 金色
	header.add_child(make_color_rect(rect_full(0.016, 0.88, 0.984, 0.92), GUOFENG_PANEL_GOLD_LINE))
	menu_hero_art = draw_menu_hero_illustration(header)
	menu_parallax_enabled = true

	# 游戏标题 - 更大更突出，使用国风金色
	var title = make_label(header, "云桌麻将", 44, GOLD_BRIGHT, true)
	apply_rect(title, rect_full(0.04, 0.08, 0.42, 0.55))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

	# 副标题 - 更柔和的颜色
	var subtitle = make_label(header, "Godot 4.6 · 国风雅韵 · 真实牌面", 15, Color(0.68, 0.80, 0.76), false)
	apply_rect(subtitle, rect_full(0.04, 0.54, 0.56, 0.82))
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

	# 版本徽章 - 使用国风配色
	var version = make_badge(header, rect_full(0.04, 0.82, 0.14, 0.95), "v%s" % app_version(), 12, INK_DARK, GOLD_DARK, Color(0.84, 0.86, 0.78))
	version.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# 右侧功能徽章组 - 使用国风配色
	var hero_badge_a = make_badge(header, rect_full(0.72, 0.12, 0.82, 0.36), "单机模式", 14, JADE_DARK, JADE_PRIMARY, PAPER_WARM)
	hero_badge_a.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var hero_badge_b = make_badge(header, rect_full(0.84, 0.12, 0.94, 0.36), "联机对战", 14, AZURE.darkened(0.3), AZURE_LIGHT, PAPER_WARM)
	hero_badge_b.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# 主菜单卡片区域 - 居中，增大间距
	var row = HBoxContainer.new()
	configure_passive_container(row)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 32)
	row.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE, 0)
	row.custom_minimum_size = Vector2(1040, 240)
	root_layer.add_child(row)
	var content_size = safe_content_pixel_size()
	row.position = Vector2(max(0.0, (content_size.x - 1040.0) * 0.5), max(0.0, (content_size.y - 240.0) * 0.5))

	# 三个主功能卡片 - 更大更醒目，使用国风配色
	var cards: Array = []
	var card1 = make_menu_card("单机人机\nAI 自动打牌", JADE_PRIMARY, func() -> void: start_offline(), "play")
	row.add_child(card1)
	cards.append(card1)

	var card2 = make_menu_card("联机房间\n连接本机服务器", AZURE, func() -> void: show_online_lobby(), "users")
	row.add_child(card2)
	cards.append(card2)

	var card3 = make_menu_card("商店\n道具和货币", VERMILION, func() -> void: show_shop_screen(), "gift")
	row.add_child(card3)
	cards.append(card3)

	# 添加卡片进场动画
	play_card_flip_animation(row, cards, true)

	# 底部信息栏 - 使用国风配色
	var footer = make_panel(root_layer, rect_full(0.02, 0.82, 0.98, 0.97), INK_MEDIUM, 18, GOLD_DARK)
	footer.add_child(make_color_rect(rect_full(0.006, 0.04, 0.016, 0.96), GOLD_PRIMARY))

	var footer_text = make_label(footer, "当前版本 v%s" % app_version(), 15, Color(0.80, 0.78, 0.70), true)
	apply_rect(footer_text, rect_full(0.04, 0.25, 0.28, 0.75))
	footer_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

	# 货币显示 - 使用国风配色
	var coins_text = "💰%d" % int(currency.get("coins", 0))
	var gems_text = "💎%d" % int(currency.get("gems", 0))
	var currency_badge = make_badge(footer, rect_full(0.30, 0.20, 0.50, 0.80), "%s  %s" % [coins_text, gems_text], 12, INK_DARK, GOLD_DARK, GOLD_LIGHT)
	currency_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	draw_animation_preview(footer, rect_full(0.270, 0.22, 0.315, 0.78), "coin_spin")

	# 赛季段位
	var rank_name = get_rank_name()
	var rank_badge = make_badge(footer, rect_full(0.52, 0.20, 0.66, 0.80), rank_name, 12, Color(0.024, 0.046, 0.052, 0.92), Color(0.44, 0.50, 0.46, 0.30), Color(0.80, 0.86, 0.76))
	rank_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	draw_menu_season_progress_art(footer)

	# 统计概览 - 显示胜率等信息
	var stats_text = "已玩%d局 · 胜率%d%%" % [
		int(game_stats.get("games_played", 0)),
		int(float(game_stats.get("win_rate", 0.0)) * 100.0)
	]
	var stats_badge = make_badge(footer, rect_full(0.68, 0.20, 0.84, 0.80), stats_text, 12, Color(0.024, 0.046, 0.052, 0.92), Color(0.34, 0.50, 0.46, 0.30), Color(0.80, 0.86, 0.76))
	stats_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	draw_menu_daily_task_art(footer)

	# 设置按钮 - 更大的触摸目标
	var settings = make_small_button("设置", Color(0.26, 0.44, 0.58), func() -> void:
		toggle_settings_panel()
	)
	settings.custom_minimum_size = Vector2(88, 48)
	footer.add_child(settings)
	apply_rect(settings, rect_full(0.86, 0.18, 0.96, 0.82))

	add_lucide_icon(settings, "settings", rect_full(0.09, 0.22, 0.31, 0.78), Color(0.92, 0.94, 0.88, 0.92))

	# 首次游戏提示 - 可点击
	if tutorial_step == 0:
		var tutorial_hint = make_badge(root_layer, rect_full(0.35, 0.70, 0.65, 0.78), "新玩家？点击查看规则", 15, Color(0.18, 0.40, 0.36, 0.92), Color(0.30, 0.62, 0.52, 0.48), Color(0.94, 0.96, 0.92))
		tutorial_hint.mouse_filter = Control.MOUSE_FILTER_STOP
		# 添加脉冲动画吸引注意力
		if fx_enabled_effective():
			var pulse_tween := create_tween()
			pulse_tween.set_loops(3600)
			pulse_tween.tween_property(tutorial_hint, "modulate:a", 0.6, 1.0).from(1.0)
			pulse_tween.tween_property(tutorial_hint, "modulate:a", 1.0, 1.0).from(0.6)
		# 连接点击事件
		tutorial_hint.gui_input.connect(func(event: InputEvent) -> void:
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				show_rules_screen()
		)

	draw_settings_overlay(root_layer)
	ensure_update_dialog()

	# 菜单入场动画 - 标题区和底栏交错出现
	if fx_enabled_effective() and DisplayServer.get_name().to_lower() != "headless":
		if header != null:
			header.modulate.a = 0.0
			header.offset_top = 12.0
			var h_tw := create_tween()
			h_tw.tween_property(header, "modulate:a", 1.0, 0.22).from(0.0).set_ease(Tween.EASE_OUT)
			h_tw.parallel().tween_property(header, "offset_top", 0.0, 0.22).from(12.0).set_ease(Tween.EASE_OUT)
		if footer != null:
			footer.modulate.a = 0.0
			footer.offset_top = 8.0
			var f_tw := create_tween()
			f_tw.tween_property(footer, "modulate:a", 1.0, 0.22).from(0.0).set_delay(0.08).set_ease(Tween.EASE_OUT)
			f_tw.parallel().tween_property(footer, "offset_top", 0.0, 0.22).from(8.0).set_delay(0.08).set_ease(Tween.EASE_OUT)

func draw_menu_season_progress_art(parent: Control) -> Control:
	var art = Control.new()
	art.name = "MenuSeasonProgressArt"
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(art, rect_full(0.520, 0.150, 0.660, 0.880))
	parent.add_child(art)
	var points = int(season_data.get("points", 0))
	var rank = get_current_rank()
	var next_index = min(rank + 1, SEASON_RANK_POINTS.size() - 1)
	var current_points = int(SEASON_RANK_POINTS[rank])
	var next_points = int(SEASON_RANK_POINTS[next_index])
	var progress = 1.0 if next_index == rank else clamp(float(points - current_points) / float(max(1, next_points - current_points)), 0.0, 1.0)
	var rail = make_panel(art, rect_full(0.080, 0.760, 0.920, 0.900), Color(0.028, 0.046, 0.048, 0.78), 999, Color(0.64, 0.56, 0.34, 0.22), 0)
	rail.name = "MenuSeasonProgressRail"
	var fill = make_panel(rail, rect_full(0.030, 0.280, 0.030 + 0.940 * progress, 0.720), Color(0.78, 0.64, 0.30, 0.64), 999, Color(0.92, 0.78, 0.42, 0.20), 0)
	fill.name = "MenuSeasonProgressFill"
	for i in range(SEASON_RANKS.size()):
		var center = 0.08 + float(i) * (0.84 / float(max(1, SEASON_RANKS.size() - 1)))
		var active = i <= rank
		var node = make_panel(art, rect_full(center - 0.025, 0.690, center + 0.025, 0.970), Color(0.86, 0.70, 0.34, 0.72 if active else 0.20), 999, Color(1.0, 0.84, 0.46, 0.32 if active else 0.10), 0)
		node.name = "MenuSeasonRankNode_%d" % i
	var current_center = 0.08 + float(rank) * (0.84 / float(max(1, SEASON_RANKS.size() - 1)))
	var rank_halo = make_panel(art, rect_full(current_center - 0.040, 0.620, current_center + 0.040, 1.000), Color(0.92, 0.74, 0.34, 0.16), 999, Color(1.0, 0.86, 0.46, 0.16), 0)
	rank_halo.name = "MenuSeasonCurrentRankHalo"
	if next_index != rank:
		var next_center = 0.08 + float(next_index) * (0.84 / float(max(1, SEASON_RANKS.size() - 1)))
		var arrow_left = min(current_center, next_center) + 0.030
		var arrow_right = max(current_center, next_center) - 0.030
		var arrow = make_color_rect(rect_full(arrow_left, 0.595, arrow_right, 0.635), Color(0.92, 0.78, 0.42, 0.22))
		arrow.name = "MenuSeasonNextRankArrow"
		art.add_child(arrow)
	for i in range(3):
		var left = 0.125 + float(i) * 0.055
		var spark = make_panel(art, rect_full(left, 0.160 + float(i % 2) * 0.085, left + 0.022, 0.300 + float(i % 2) * 0.085), Color(0.92, 0.76, 0.34, 0.30), 999, Color(1.0, 0.88, 0.52, 0.12), 0)
		spark.name = "MenuSeasonPointSpark_%d" % i
	if fx_enabled_effective() and DisplayServer.get_name().to_lower() != "headless":
		var tw := create_tween()
		tw.set_loops(3600)
		tw.tween_property(fill, "modulate:a", 0.52, 0.90).from(0.96)
		tw.tween_property(fill, "modulate:a", 0.96, 0.90).from(0.52)
		var halo_tw := create_tween()
		halo_tw.set_loops(3600)
		halo_tw.tween_property(rank_halo, "modulate:a", 0.42, 1.0).from(1.0)
		halo_tw.tween_property(rank_halo, "modulate:a", 1.0, 1.0).from(0.42)
	return art

func draw_menu_daily_task_art(parent: Control) -> Control:
	var art = Control.new()
	art.name = "MenuDailyTaskArt"
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(art, rect_full(0.040, 0.760, 0.840, 0.965))
	parent.add_child(art)
	var task_count = max(1, DAILY_TASKS.size())
	var completed = 0
	var best_index = 0
	var best_fraction = -1.0
	for i in range(DAILY_TASKS.size()):
		var task: Dictionary = DAILY_TASKS[i]
		var progress = int(task_progress.get(str(task.get("id", "")), 0))
		var target = max(1, int(task.get("target", 1)))
		var fraction = clamp(float(progress) / float(target), 0.0, 1.0)
		if fraction >= 1.0:
			completed += 1
		if fraction > best_fraction and fraction < 1.0:
			best_fraction = fraction
			best_index = i
	if completed >= DAILY_TASKS.size() and DAILY_TASKS.size() > 0:
		best_index = DAILY_TASKS.size() - 1
	var rail = make_panel(art, rect_full(0.160, 0.420, 0.980, 0.620), Color(0.026, 0.044, 0.042, 0.74), 999, Color(0.42, 0.58, 0.48, 0.16), 0)
	rail.name = "MenuDailyTaskRail"
	var fill_fraction = clamp(float(completed) / float(task_count), 0.035, 1.0)
	var fill = make_panel(rail, rect_full(0.020, 0.280, 0.020 + 0.960 * fill_fraction, 0.720), Color(0.42, 0.74, 0.56, 0.58), 999, Color(0.72, 0.92, 0.62, 0.18), 0)
	fill.name = "MenuDailyTaskFill"
	var label = make_label(art, "每日任务 %d/%d" % [completed, DAILY_TASKS.size()], 10, Color(0.78, 0.88, 0.76), true)
	apply_rect(label, rect_full(0.000, 0.060, 0.150, 0.920))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	for i in range(DAILY_TASKS.size()):
		var center = 0.175 + float(i) * (0.780 / float(max(1, DAILY_TASKS.size() - 1)))
		var task: Dictionary = DAILY_TASKS[i]
		var progress = int(task_progress.get(str(task.get("id", "")), 0))
		var target = max(1, int(task.get("target", 1)))
		var done = progress >= target
		var node_color = Color(0.56, 0.84, 0.60, 0.70) if done else Color(0.78, 0.66, 0.34, 0.30)
		var node = make_panel(art, rect_full(center - 0.012, 0.300, center + 0.012, 0.740), node_color, 999, Color(node_color.r, node_color.g, node_color.b, 0.24), 0)
		node.name = "MenuDailyTaskNode_%d" % i
		if done:
			var claim = make_panel(art, rect_full(center - 0.020, 0.080, center + 0.020, 0.260), Color(0.62, 0.88, 0.58, 0.34), 999, Color(0.82, 0.96, 0.70, 0.14), 0)
			claim.name = "MenuDailyTaskClaimMark_%d" % i
	var focus_center = 0.175 + float(best_index) * (0.780 / float(max(1, DAILY_TASKS.size() - 1)))
	var focus = make_panel(art, rect_full(focus_center - 0.020, 0.200, focus_center + 0.020, 0.840), Color(0.92, 0.76, 0.34, 0.22), 999, Color(1.0, 0.86, 0.46, 0.18), 0)
	focus.name = "MenuDailyTaskFocusGlow"
	var focus_pulse = make_panel(art, rect_full(focus_center - 0.034, 0.135, focus_center + 0.034, 0.905), Color(0.92, 0.76, 0.34, 0.10), 999, Color(1.0, 0.86, 0.46, 0.10), 0)
	focus_pulse.name = "MenuDailyTaskFocusPulse"
	for i in range(3):
		var progress_pip = make_panel(art, rect_full(0.055 + float(i) * 0.032, 0.690, 0.075 + float(i) * 0.032, 0.815), Color(0.48, 0.78, 0.58, 0.26), 999, Color(0.74, 0.92, 0.66, 0.10), 0)
		progress_pip.name = "MenuDailyTaskProgressPip_%d" % i
	if fx_enabled_effective() and DisplayServer.get_name().to_lower() != "headless":
		var tw := create_tween()
		tw.set_loops(3600)
		tw.tween_property(focus, "modulate:a", 0.40, 0.90).from(0.92)
		tw.tween_property(focus, "modulate:a", 0.92, 0.90).from(0.40)
		var pulse_tw := create_tween()
		pulse_tw.set_loops(3600)
		pulse_tw.tween_property(focus_pulse, "modulate:a", 0.30, 0.90).from(0.90)
		pulse_tw.tween_property(focus_pulse, "modulate:a", 0.90, 0.90).from(0.30)
	return art

func make_menu_card(text: String, color: Color, callback: Callable, icon_name: String = "") -> Button:
	var button = Button.new()
	button.text = ""
	button.custom_minimum_size = Vector2(310, 210)
	configure_touch_button(button)
	var muted = soften_menu_color(color)
	# 增强的卡片样式 - 更大的圆角，更显眼的边框高亮
	button.add_theme_stylebox_override("normal", style(Color(0.018, 0.032, 0.038, 0.97), 20, muted.darkened(0.78), 2, 6))
	button.add_theme_stylebox_override("hover", style(Color(0.026, 0.042, 0.048, 0.98), 20, muted.darkened(0.60), 2, 4))
	button.add_theme_stylebox_override("pressed", style(Color(0.014, 0.026, 0.032, 0.99), 20, muted.darkened(0.72), 2, 2))
	# 左侧彩色条纹装饰 - 更宽更醒目
	button.add_child(make_color_rect(rect_full(0.02, 0.08, 0.055, 0.92), Color(color.r, color.g, color.b, 0.24)))
	# 顶部高光
	button.add_child(make_color_rect(rect_full(0.055, 0.04, 0.945, 0.11), Color(1.0, 1.0, 1.0, 0.025)))
	# 底部渐变
	button.add_child(make_color_rect(rect_full(0.055, 0.86, 0.945, 0.92), Color(0.0, 0.0, 0.0, 0.045)))
	if icon_name != "":
		var icon_back = make_panel(button, rect_full(0.70, 0.13, 0.90, 0.43), Color(color.r, color.g, color.b, 0.12), 14, Color(color.r, color.g, color.b, 0.30), 0)
		icon_back.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_lucide_icon(button, icon_name, rect_full(0.735, 0.165, 0.865, 0.395), Color(0.92, 0.88, 0.68, 0.88))
	var parts = text.split("\n", false, 2)
	var title_text = parts[0] if parts.size() > 0 else text
	var subtitle_text = parts[1] if parts.size() > 1 else ""
	var title = make_label(button, title_text, 26, Color(0.94, 0.92, 0.84), true)
	apply_rect(title, rect_full(0.10, 0.14, 0.68 if icon_name != "" else 0.92, 0.52))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	configure_clipped_label(title)
	if subtitle_text != "":
		var subtitle = make_label(button, subtitle_text, 14, Color(0.74, 0.84, 0.78), false)
		apply_rect(subtitle, rect_full(0.10, 0.52, 0.92, 0.82))
		subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		subtitle.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		configure_clipped_label(subtitle)
	# 菜单卡hover缩放动画
	button.mouse_entered.connect(func() -> void:
		if not is_instance_valid(button):
			return
		var tw := button.create_tween()
		tw.tween_property(button, "scale", Vector2(1.02, 1.02), 0.15).from(Vector2(1.0, 1.0)).set_ease(Tween.EASE_OUT)
	)
	button.mouse_exited.connect(func() -> void:
		if not is_instance_valid(button):
			return
		var tw := button.create_tween()
		tw.tween_property(button, "scale", Vector2(1.0, 1.0), 0.15).from(Vector2(1.02, 1.02)).set_ease(Tween.EASE_OUT)
	)
	if callback.is_valid():
		connect_immediate_button_action(button, callback)
	return button

func show_online_lobby(instant: bool = false) -> void:
	if transition_active and not instant:
		return
	var _build = func() -> void:
		_show_online_lobby_impl()
	if instant or not fx_enabled_effective():
		_build.call()
	else:
		play_screen_transition(_build)

func _show_online_lobby_impl() -> void:
	mode = "online_lobby"
	recover_audio_after_screen_change()
	clear_screen()

	# 装饰 - 远山背景
	make_mountain_silhouette(root_layer, rect_full(0.0, 0.50, 1.0, 1.0), 2, INK_WASH)

	# 主面板 - 统一的全屏面板
	var panel = make_panel(root_layer, rect_full(0.02, 0.02, 0.98, 0.98), Color(0.012, 0.032, 0.040, 0.96), 20, Color(0.62, 0.52, 0.30, 0.52))
	# 左侧金色装饰
	panel.add_child(make_color_rect(rect_full(0.006, 0.03, 0.016, 0.97), Color(0.92, 0.78, 0.38, 0.84)))
	# 顶部分隔线
	panel.add_child(make_color_rect(rect_full(0.016, 0.012, 0.984, 0.03), Color(1.0, 1.0, 1.0, 0.05)))

	# 标题区域
	var title = make_label(panel, "联机大厅", 32, Color(0.94, 0.86, 0.48), true)
	apply_rect(title, rect_full(0.04, 0.028, 0.28, 0.10))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	var subtitle = make_label(panel, "连接本机或局域网房间，创建后等待玩家进入。", 15, Color(0.70, 0.82, 0.76), false)
	apply_rect(subtitle, rect_full(0.04, 0.095, 0.48, 0.14))
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

	# 服务器和状态徽章
	var server_badge = make_badge(panel, rect_full(0.68, 0.040, 0.84, 0.105), "%s:%d" % [DEFAULT_HOST, DEFAULT_PORT], 12, Color(0.020, 0.046, 0.054, 0.94), Color(0.34, 0.52, 0.48, 0.36), Color(0.82, 0.90, 0.82))
	server_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var state_badge = make_badge(panel, rect_full(0.86, 0.040, 0.96, 0.105), lobby_connection_state_text(), 12, Color(0.18, 0.28, 0.26, 0.94), Color(0.36, 0.56, 0.46, 0.36), Color(0.90, 0.94, 0.84))
	state_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# 表单面板 - 连接与房间设置
	var form_panel = make_panel(panel, rect_full(0.035, 0.17, 0.475, 0.87), Color(0.010, 0.026, 0.034, 0.95), 16, Color(0.38, 0.44, 0.40, 0.28))
	# 表单标题栏装饰
	form_panel.add_child(make_color_rect(rect_full(0.006, 0.02, 0.016, 0.98), Color(0.84, 0.72, 0.38, 0.52)))
	form_panel.add_child(make_color_rect(rect_full(0.02, 0.065, 0.98, 0.08), Color(0.84, 0.74, 0.42, 0.10)))
	var form_title = make_label(form_panel, "连接与房间", 20, Color(0.90, 0.86, 0.60), true)
	apply_rect(form_title, rect_full(0.05, 0.020, 0.50, 0.095))
	form_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

	var form = VBoxContainer.new()
	configure_passive_container(form)
	form.anchor_left = 0.06
	form.anchor_top = 0.15
	form.anchor_right = 0.94
	form.anchor_bottom = 0.68
	form.add_theme_constant_override("separation", 14)
	form_panel.add_child(form)
	online_name_edit = add_line_edit(form, "昵称", "云桌道友")
	online_host_edit = add_line_edit(form, "服务器 IP/域名", DEFAULT_HOST)
	online_room_edit = add_line_edit(form, "房间号", selected_room)

	# 操作按钮组 - 连接/创建/加入
	var button_row = HBoxContainer.new()
	configure_passive_container(button_row)
	button_row.add_theme_constant_override("separation", 10)
	apply_rect(button_row, rect_full(0.06, 0.72, 0.94, 0.81))
	form_panel.add_child(button_row)
	button_row.add_child(make_lobby_action_button("连接", Color(0.20, 0.48, 0.66), func() -> void:
		connect_online()
	))
	button_row.add_child(make_lobby_action_button("创建", Color(0.22, 0.54, 0.42), func() -> void:
		send_online_action({"type": "createRoom", "name": online_name_edit.text}, "创建房间")
	))
	button_row.add_child(make_lobby_action_button("加入", Color(0.72, 0.48, 0.24), func() -> void:
		selected_room = online_room_edit.text
		send_online_action({"type": "joinRoom", "roomCode": online_room_edit.text, "name": online_name_edit.text}, "加入房间")
	))

	# 底部按钮 - 开始/返回
	var start_row = HBoxContainer.new()
	configure_passive_container(start_row)
	start_row.add_theme_constant_override("separation", 10)
	apply_rect(start_row, rect_full(0.06, 0.84, 0.94, 0.93))
	form_panel.add_child(start_row)
	start_row.add_child(make_lobby_action_button("开始游戏", Color(0.56, 0.28, 0.22), func() -> void:
		send_online_action({"type": "startGame"}, "开始游戏")
	))
	start_row.add_child(make_lobby_action_button("返回菜单", Color(0.28, 0.34, 0.36), func() -> void:
		show_menu()
	))

	# 状态栏
	status_label = make_label(panel, "未连接。服务器默认 %s:%d" % [DEFAULT_HOST, DEFAULT_PORT], 15, Color(0.82, 0.94, 0.86), false)
	apply_rect(status_label, rect_full(0.04, 0.885, 0.50, 0.945))
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	configure_clipped_label(status_label)

	# 房间状态面板
	var log_panel = make_panel(panel, rect_full(0.505, 0.17, 0.965, 0.87), Color(0.010, 0.026, 0.032, 0.95), 16, Color(0.34, 0.44, 0.38, 0.28))
	log_panel.add_child(make_color_rect(rect_full(0.006, 0.02, 0.016, 0.98), Color(0.84, 0.72, 0.38, 0.42)))
	log_panel.add_child(make_color_rect(rect_full(0.02, 0.13, 0.98, 0.15), Color(1.0, 1.0, 1.0, 0.028)))
	var log_title = make_label(log_panel, "房间状态", 20, Color(0.84, 0.87, 0.74), true)
	apply_rect(log_title, rect_full(0.05, 0.020, 0.48, 0.095))
	log_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	var room_badge_text = "房间号 " + (selected_room if selected_room != "" else "--")
	var room_badge = make_badge(log_panel, rect_full(0.68, 0.030, 0.94, 0.100), room_badge_text, 12, Color(0.020, 0.044, 0.050, 0.94), Color(0.46, 0.52, 0.34, 0.30), Color(0.82, 0.87, 0.72))
	room_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	draw_online_lobby_room_art(log_panel)
	logs_label = make_label(log_panel, "", 15, Color(0.84, 0.87, 0.76), false)
	apply_rect(logs_label, rect_full(0.05, 0.31, 0.95, 0.94))
	logs_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	logs_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	logs_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	render_room_log()
	ensure_update_dialog()

func draw_online_lobby_room_art(parent: Control) -> Control:
	var art = Control.new()
	art.name = "OnlineLobbyRoomArt"
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(art, rect_full(0.050, 0.160, 0.950, 0.285))
	parent.add_child(art)
	var player_count = 0
	var players_value = online_room.get("players", [])
	if typeof(players_value) == TYPE_ARRAY:
		player_count = (players_value as Array).size()
	var logs_value = online_room.get("logs", [])
	var log_count = (logs_value as Array).size() if typeof(logs_value) == TYPE_ARRAY else 0
	var rail = make_panel(art, rect_full(0.055, 0.440, 0.945, 0.560), Color(0.42, 0.58, 0.52, 0.18), 999, Color(0.66, 0.78, 0.58, 0.16), 0)
	rail.name = "OnlineLobbyRoomRail"
	var ready_rail = make_color_rect(rect_full(0.080, 0.790, 0.920, 0.835), Color(0.78, 0.68, 0.36, 0.18))
	ready_rail.name = "OnlineLobbyReadyRail"
	art.add_child(ready_rail)
	var room_node = make_panel(art, rect_full(0.420, 0.140, 0.580, 0.860), Color(0.050, 0.040, 0.026, 0.58), 18, Color(0.86, 0.70, 0.34, 0.32), 0)
	room_node.name = "OnlineLobbyRoomNode"
	add_lucide_icon(room_node, "users", rect_full(0.25, 0.22, 0.75, 0.78), GOLD_BRIGHT)
	for i in range(3):
		var wave = make_panel(art, rect_full(0.385 - float(i) * 0.018, 0.085 - float(i) * 0.035, 0.615 + float(i) * 0.018, 0.915 + float(i) * 0.035), Color(0.86, 0.72, 0.34, 0.050 - float(i) * 0.010), 999, Color(0.96, 0.82, 0.42, 0.055 - float(i) * 0.012), 0)
		wave.name = "OnlineLobbyConnectionWave_%d" % i
	for i in range(4):
		var center = 0.110 + float(i) * 0.255
		var active = i < player_count
		var slot = make_panel(art, rect_full(center - 0.028, 0.270, center + 0.028, 0.730), Color(0.38, 0.70, 0.56, 0.62 if active else 0.18), 999, Color(0.72, 0.90, 0.70, 0.28 if active else 0.08), 0)
		slot.name = "OnlineLobbyPlayerSlot_%d" % i
		var seat_signal = make_panel(art, rect_full(center - 0.020, 0.790, center + 0.020, 0.910), Color(0.78, 0.68, 0.36, 0.42 if active else 0.14), 999, Color(0.96, 0.82, 0.42, 0.22 if active else 0.08), 0)
		seat_signal.name = "OnlineLobbySeatSignal_%d" % i
		if active:
			var glow = make_panel(art, rect_full(center - 0.048, 0.225, center + 0.048, 0.775), Color(0.60, 0.86, 0.62, 0.11), 999, Color(0.78, 0.96, 0.72, 0.10), 0)
			glow.name = "OnlineLobbySeatReadyGlow_%d" % i
	var pulse_count = min(3, max(1, log_count))
	for i in range(pulse_count):
		var left = 0.735 + float(i) * 0.060
		var pulse = make_panel(art, rect_full(left, 0.150, left + 0.030, 0.390), Color(0.84, 0.68, 0.30, 0.46), 999, Color(1.0, 0.84, 0.46, 0.18), 0)
		pulse.name = "OnlineLobbyLogPulse_%d" % i
	if fx_enabled_effective() and DisplayServer.get_name().to_lower() != "headless":
		var tw := create_tween()
		tw.set_loops(3600)
		tw.tween_property(ready_rail, "modulate:a", 0.44, 1.0).from(1.0)
		tw.tween_property(ready_rail, "modulate:a", 1.0, 1.0).from(0.44)
	return art

func add_line_edit(parent: Control, label_text: String, value: String) -> LineEdit:
	var caption = Label.new()
	caption.text = label_text
	caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	caption.add_theme_font_size_override("font_size", 18)
	caption.add_theme_color_override("font_color", Color(0.92, 0.86, 0.62))
	parent.add_child(caption)
	var edit = LineEdit.new()
	edit.text = value
	edit.custom_minimum_size = Vector2(360, 46)
	edit.add_theme_font_size_override("font_size", 21)
	var input_styles = input_style_set()
	edit.add_theme_stylebox_override("normal", input_styles["normal"])
	edit.add_theme_stylebox_override("focus", input_styles["focus"])
	edit.add_theme_stylebox_override("read_only", input_styles["read_only"])
	edit.add_theme_color_override("font_color", Color(0.96, 0.95, 0.89))
	edit.add_theme_color_override("font_placeholder_color", Color(0.70, 0.74, 0.68))
	edit.add_theme_color_override("font_selected_color", Color(0.10, 0.12, 0.10))
	edit.add_theme_color_override("selection_color", Color(0.56, 0.70, 0.48, 0.72))
	edit.add_theme_color_override("caret_color", Color(0.94, 0.86, 0.54))
	parent.add_child(edit)
	return edit

func make_lobby_action_button(text: String, color: Color, callback: Callable) -> Button:
	var button = make_small_button(text, color, callback)
	button.custom_minimum_size = Vector2(130, 50)
	button.add_theme_font_size_override("font_size", 17)
	return button

func lobby_connection_state_text() -> String:
	match tcp.get_status():
		StreamPeerTCP.STATUS_CONNECTED:
			return "已连接"
		StreamPeerTCP.STATUS_CONNECTING:
			return "连接中"
		StreamPeerTCP.STATUS_ERROR:
			return "异常"
	return "未连接"

func connect_online() -> void:
	tcp.disconnect_from_host()
	tcp = StreamPeerTCP.new()
	tcp_buffer = ""
	next_online_poll_msec = 0
	online_room.clear()
	online_game.clear()
	clear_online_feedback()
	sent_hello = false
	var err = tcp.connect_to_host(online_host_edit.text.strip_edges(), DEFAULT_PORT)
	set_status("正在连接 %s:%d ..." % [online_host_edit.text.strip_edges(), DEFAULT_PORT])
	if err != OK:
		set_status("连接失败：%s" % error_string(err))

func poll_online(now_msec: int = -1) -> void:
	if mode != "online_lobby" and mode != "online_game":
		return
	if now_msec >= 0:
		if now_msec < next_online_poll_msec:
			return
		next_online_poll_msec = now_msec + ONLINE_POLL_INTERVAL_MSEC
	tcp.poll()
	var status = tcp.get_status()
	if status != tcp_status:
		tcp_status = status
		if status == StreamPeerTCP.STATUS_CONNECTED:
			set_status("已连接服务器")
			if not sent_hello:
				sent_hello = true
				send_online({"type": "hello", "name": online_name_edit.text if online_name_edit else "云桌道友"})
		elif status == StreamPeerTCP.STATUS_ERROR:
			set_status("连接出错")
		elif status == StreamPeerTCP.STATUS_NONE and mode.begins_with("online"):
			pass
	if status != StreamPeerTCP.STATUS_CONNECTED:
		return
	var available = tcp.get_available_bytes()
	if available <= 0:
		return
	tcp_buffer += tcp.get_utf8_string(available)
	while tcp_buffer.find("\n") >= 0:
		var split_at = tcp_buffer.find("\n")
		var line = tcp_buffer.substr(0, split_at).strip_edges()
		tcp_buffer = tcp_buffer.substr(split_at + 1)
		if line.length() > 0:
			handle_online_message(line)

func send_online(payload: Dictionary) -> bool:
	if tcp.get_status() != StreamPeerTCP.STATUS_CONNECTED:
		set_status("请先连接服务器。")
		return false
	var text = JSON.stringify(payload) + "\n"
	tcp.put_data(text.to_utf8_buffer())
	return true

func send_online_action(payload: Dictionary, label: String = "") -> void:
	var action_label = label if label.strip_edges() != "" else online_action_label(payload)
	if send_online(payload):
		play_outgoing_online_action_audio(payload)
		online_last_sent_action = action_label
		online_last_sent_msec = Time.get_ticks_msec()
		set_online_feedback("已发送%s，等待服务器确认。" % action_label, true)

func play_outgoing_online_action_audio(payload: Dictionary) -> void:
	var kind = str(payload.get("type", "")).to_lower()
	if kind == "discard":
		var tile = str(payload.get("tile", ""))
		if tile == "":
			return
		var seat = int(online_game.get("youSeat", -1))
		online_pending_local_discard_identity = online_discard_identity(seat, tile)
		play_sfx("discard", -1.0)
		speak_tile_call(tile)
	elif kind == "claim":
		var claim = str(payload.get("claim", ""))
		if claim == "pass":
			return
		var tile = str(first_present(payload, ["tile", "discard", "lastDiscard"], ""))
		if tile == "" and typeof(online_game.get("pending", null)) == TYPE_DICTIONARY:
			tile = str(online_game.get("pending", {}).get("tile", ""))
		play_sfx(claim_sfx_key(claim), -1.5)
		speak_action_call(claim_label(claim), tile)

func claim_sfx_key(claim: String) -> String:
	match claim:
		"peng":
			return "peng"
		"gang":
			return "gang"
		"hu":
			return "win"
		"chi":
			return "peng"
	return "discard"

func online_action_label(payload: Dictionary) -> String:
	var kind = str(payload.get("type", "操作"))
	if kind == "discard":
		return "打出%s" % tile_label(str(payload.get("tile", "")))
	if kind == "claim":
		return claim_label(str(payload.get("claim", "操作")))
	if kind == "createRoom":
		return "创建房间"
	if kind == "joinRoom":
		return "加入房间"
	if kind == "startGame":
		return "开始游戏"
	return "操作"

func set_online_feedback(text: String, waiting: bool = false) -> void:
	online_feedback = text
	online_waiting_for_server = waiting
	if not waiting:
		online_last_sent_msec = 0
	set_status(text)

func clear_online_feedback() -> void:
	online_feedback = ""
	online_waiting_for_server = false
	online_last_sent_action = ""
	online_last_sent_msec = 0

func online_claim_payload(claim: String, choice: Dictionary = {}) -> Dictionary:
	var payload: Dictionary = {"type": "claim", "claim": claim}
	if not choice.is_empty():
		var meld = normalize_tile_array(choice.get("meld", choice.get("tiles", [])))
		var needed = normalize_tile_array(choice.get("needed", []))
		payload["choice"] = choice
		payload["meld"] = meld
		payload["tiles"] = meld
		payload["needed"] = needed
	return payload

func toggle_voice_chat() -> void:
	if mode != "online_game" and mode != "online_lobby":
		set_status("语音需要进入联机房间后使用。")
		return
	if tcp.get_status() != StreamPeerTCP.STATUS_CONNECTED:
		set_status("语音需要先连接服务器。")
		return
	if voice_enabled:
		stop_voice_chat(true)
	else:
		start_voice_chat()
	render_game()

func start_voice_chat() -> void:
	if not ensure_voice_capture():
		set_status("麦克风初始化失败。")
		return
	voice_sequence = 0
	voice_peak = 0.0
	voice_capture_effect.clear_buffer()
	voice_mic_player.play()
	voice_enabled = true
	send_online({"type": "voiceState", "speaking": true})
	set_status("语音已开启。")

func stop_voice_chat(notify: bool = true) -> void:
	if voice_mic_player != null and is_instance_valid(voice_mic_player):
		voice_mic_player.stop()
	if voice_capture_effect != null:
		voice_capture_effect.clear_buffer()
	voice_enabled = false
	voice_peak = 0.0
	if notify and tcp.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		send_online({"type": "voiceState", "speaking": false})
	set_status("语音已关闭。")

func ensure_voice_capture() -> bool:
	if voice_capture_effect != null and voice_mic_player != null and is_instance_valid(voice_mic_player):
		return true
	var bus_index = AudioServer.get_bus_index(VOICE_BUS_NAME)
	if bus_index < 0:
		AudioServer.add_bus()
		bus_index = AudioServer.get_bus_count() - 1
		AudioServer.set_bus_name(bus_index, VOICE_BUS_NAME)
		AudioServer.set_bus_volume_db(bus_index, -80.0)
	voice_capture_effect = AudioEffectCapture.new()
	AudioServer.add_bus_effect(bus_index, voice_capture_effect)
	voice_mic_player = AudioStreamPlayer.new()
	voice_mic_player.stream = AudioStreamMicrophone.new()
	voice_mic_player.bus = VOICE_BUS_NAME
	voice_mic_player.process_mode = Node.PROCESS_MODE_ALWAYS
	attach_audio_node(voice_mic_player)
	return true

func poll_voice_capture() -> void:
	if not voice_enabled or voice_capture_effect == null:
		return
	if tcp.get_status() != StreamPeerTCP.STATUS_CONNECTED:
		stop_voice_chat(false)
		return
	while voice_capture_effect.get_frames_available() >= VOICE_CHUNK_FRAMES:
		var frames = voice_capture_effect.get_buffer(VOICE_CHUNK_FRAMES)
		var payload = build_voice_payload(frames)
		if payload.is_empty():
			return
		send_online(payload)

func build_voice_payload(frames: PackedVector2Array) -> Dictionary:
	var encoded = encode_voice_frames(frames)
	if encoded.is_empty():
		return {}
	var payload = {
		"type": "voiceMessage",
		"format": "pcm16",
		"sampleRate": int(AudioServer.get_mix_rate()),
		"channels": 1,
		"sequence": voice_sequence,
		"audio": str(encoded.get("audio", "")),
		"peak": float(encoded.get("peak", 0.0)),
	}
	voice_sequence += 1
	voice_peak = float(encoded.get("peak", 0.0))
	return payload

func encode_voice_frames(frames: PackedVector2Array) -> Dictionary:
	if frames.is_empty():
		return {}
	var bytes = PackedByteArray()
	var peak = 0.0
	for frame in frames:
		var mono = clamp((frame.x + frame.y) * 0.5, -1.0, 1.0)
		peak = max(peak, abs(mono))
		var sample = int(round(mono * 32767.0))
		if sample < 0:
			sample += 65536
		bytes.append(sample & 0xff)
		bytes.append((sample >> 8) & 0xff)
	return {
		"audio": Marshalls.raw_to_base64(bytes),
		"peak": peak,
		"bytes": bytes.size(),
	}

func handle_voice_message(data: Dictionary) -> void:
	var speaker_seat = int(data.get("seat", data.get("fromSeat", -1)))
	if speaker_seat >= 0 and speaker_seat == int(online_game.get("youSeat", -2)):
		return
	var stream = make_voice_stream(str(data.get("audio", "")), int(data.get("sampleRate", AudioServer.get_mix_rate())), int(data.get("channels", 1)))
	if stream == null:
		return
	var player = AudioStreamPlayer.new()
	player.stream = stream
	player.bus = "Master"
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	attach_audio_node(player)
	player.finished.connect(func() -> void:
		player.queue_free()
	)
	player.play()

func make_voice_stream(audio_base64: String, sample_rate: int, channels: int) -> AudioStreamWAV:
	if audio_base64 == "":
		return null
	var data = Marshalls.base64_to_raw(audio_base64)
	if data.is_empty():
		return null
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = max(8000, sample_rate)
	stream.stereo = channels == 2
	stream.data = data
	return stream

func handle_online_message(line: String) -> void:
	var data = JSON.parse_string(line)
	if typeof(data) != TYPE_DICTIONARY:
		set_status("服务器消息解析失败")
		return
	var kind = normalize_online_message_kind(data)
	if kind == "welcome":
		set_status("已连接：" + str(data.get("name", "")))
	elif kind == "info":
		set_online_feedback(online_server_message_text(data, "服务器提示"), false)
	elif kind == "error":
		handle_online_error(data)
	elif kind == "ack":
		handle_online_ack(data)
	elif kind == "log":
		handle_online_log(data)
	elif kind == "roomState":
		clear_online_feedback()
		var room_value = data.get("room", data)
		online_room = (room_value as Dictionary).duplicate(true) if typeof(room_value) == TYPE_DICTIONARY else {}
		selected_room = str(first_present(online_room, ["code", "roomCode", "room_code"], ""))
		if online_room_edit:
			online_room_edit.text = selected_room
		render_room_log()
	elif kind == "gameState":
		clear_online_feedback()
		var next_game = normalize_online_game_state(data)
		announce_online_game_audio(next_game)
		online_game = next_game
		mode = "online_game"
		request_game_render()
	elif kind == "voiceMessage":
		handle_voice_message(data)
	else:
		var message = online_server_message_text(data, "")
		if message != "":
			set_online_feedback(message, false)

func normalize_online_message_kind(data: Dictionary) -> String:
	var raw = str(first_present(data, ["type", "event", "kind", "messageType"], "")).strip_edges()
	var compact = raw.to_lower().replace("_", "").replace("-", "")
	if compact == "message" and data.has("event"):
		raw = str(data.get("event", ""))
		compact = raw.to_lower().replace("_", "").replace("-", "")
	match compact:
		"welcome", "hello":
			return "welcome"
		"info", "notice", "status", "servermessage", "message":
			return "info"
		"error", "err", "reject", "rejected", "actionrejected", "invalidaction", "denied":
			return "error"
		"ack", "ok", "success", "accepted", "actionack", "actionaccepted":
			return "ack"
		"roomstate", "roomupdate", "lobbystate", "lobbyupdate", "room":
			return "roomState"
		"gamestate", "gameupdate", "gamesnapshot", "state", "snapshot", "game":
			return "gameState"
		"voicemessage", "voice", "voicepacket":
			return "voiceMessage"
		"log", "roomlog", "eventlog":
			return "log"
	if data.has("game") or data.has("hand") or data.has("yourHand") or data.has("selfHand"):
		return "gameState"
	if data.has("room") or (data.has("players") and data.has("roomCode")):
		return "roomState"
	return raw

func online_server_message_text(data: Dictionary, fallback: String) -> String:
	var value = first_present(data, ["message", "text", "detail", "reason", "error"], fallback)
	var text = str(value).strip_edges()
	return text if text != "" else fallback

func handle_online_ack(data: Dictionary) -> void:
	var message = online_server_message_text(data, "")
	if message == "":
		message = "%s已确认" % (online_last_sent_action if online_last_sent_action != "" else "操作")
	set_online_feedback("服务器确认：%s" % message, false)

func handle_online_error(data: Dictionary) -> void:
	var message = online_server_message_text(data, "操作被服务器拒绝")
	set_online_feedback("服务器拒绝：%s" % message, false)

func handle_online_log(data: Dictionary) -> void:
	var message = online_server_message_text(data, "")
	if message == "":
		return
	if typeof(online_room.get("logs", [])) != TYPE_ARRAY:
		online_room["logs"] = []
	var logs: Array = online_room.get("logs", [])
	logs.append(message)
	while logs.size() > 14:
		logs.remove_at(0)
	online_room["logs"] = logs
	set_online_feedback(message, false)
	render_room_log()

func announce_online_game_audio(next_game: Dictionary) -> void:
	var tile = str(next_game.get("lastDiscard", ""))
	var seat = int(next_game.get("lastDiscardSeat", -1))
	if tile == "" or seat < 0:
		return
	var next_key = online_discard_audio_key(next_game)
	if next_key == "" or next_key == online_announced_discard_key:
		return
	if online_game.is_empty():
		online_announced_discard_key = next_key
		return
	var identity = online_discard_identity(seat, tile)
	if identity != "" and identity == online_pending_local_discard_identity:
		online_pending_local_discard_identity = ""
		online_announced_discard_key = next_key
		return
	online_announced_discard_key = next_key
	play_sfx("discard", -1.0)
	speak_tile_call(tile)

func online_discard_audio_key(game: Dictionary) -> String:
	var tile = str(game.get("lastDiscard", ""))
	var seat = int(game.get("lastDiscardSeat", -1))
	if tile == "" or seat < 0:
		return ""
	var discard_count = 0
	for player in game.get("players", []):
		if typeof(player) != TYPE_DICTIONARY:
			continue
		if int(player.get("seat", -1)) == seat:
			var discards = player.get("discards", [])
			if typeof(discards) == TYPE_ARRAY:
				discard_count = discards.size()
			break
	return "%s:%d" % [online_discard_identity(seat, tile), discard_count]

func online_discard_identity(seat: int, tile: String) -> String:
	if seat < 0 or tile == "":
		return ""
	return "%d:%s" % [seat, tile]

func normalize_online_game_state(message: Dictionary) -> Dictionary:
	var source = message.get("game", message)
	if typeof(source) != TYPE_DICTIONARY:
		source = {}
	var game: Dictionary = (source as Dictionary).duplicate(true)
	game["roomCode"] = str(first_present(game, ["roomCode", "room_code", "code"], selected_room))
	game["youSeat"] = int(first_present(game, ["youSeat", "seat", "playerSeat", "selfSeat"], message.get("seat", game.get("youSeat", -1))))
	game["currentSeat"] = int(first_present(game, ["currentSeat", "turnSeat", "activeSeat", "current"], 0))
	game["wallCount"] = int(first_present(game, ["wallCount", "wallRemaining", "remainingTiles"], game.get("wallCount", 0)))
	game["phase"] = normalize_online_phase(str(first_present(game, ["phase", "state", "status"], "")))
	game["hand"] = normalize_tile_array(first_present(game, ["hand", "tiles", "yourHand", "selfHand"], []))
	var last_discard_value = first_present(game, ["lastDiscard", "discard", "lastTile"], "")
	game["lastDiscard"] = normalize_last_discard_tile(last_discard_value)
	game["lastDiscardSeat"] = normalize_last_discard_seat(last_discard_value, int(first_present(game, ["lastDiscardSeat", "discardSeat", "lastDiscarder", "fromSeat"], -1)))
	game["players"] = normalize_online_players(first_present(game, ["players", "seats"], []))
	game["pending"] = normalize_online_pending(first_present(game, ["pending", "pendingClaim", "claim"], {}), game)
	if str(game.get("phase", "")) == "" and typeof(game.get("pending", null)) == TYPE_DICTIONARY and game["pending"].get("options", []).size() > 0:
		game["phase"] = "pendingClaim"
	return game

func first_present(data: Dictionary, keys: Array, fallback = null):
	for key in keys:
		if data.has(key):
			var value = data[key]
			if value != null:
				return value
	return fallback

func normalize_online_phase(value: String) -> String:
	var phase = value.strip_edges()
	var compact = phase.to_lower().replace("_", "").replace("-", "")
	if compact == "awaitdiscard" or compact == "discard" or compact == "turn":
		return "awaitDiscard"
	if compact == "pendingclaim" or compact == "claim" or compact == "response":
		return "pendingClaim"
	if compact == "ended" or compact == "finished" or compact == "gameover":
		return "ended"
	if compact == "ready" or compact == "waiting":
		return compact
	return phase

func normalize_tile_array(value) -> Array:
	var result: Array = []
	if typeof(value) != TYPE_ARRAY:
		return result
	for item in value:
		if typeof(item) == TYPE_DICTIONARY:
			result.append(str(first_present(item, ["tile", "code", "id"], "")))
		else:
			result.append(str(item))
	return result

func normalize_last_discard_tile(value) -> String:
	if typeof(value) == TYPE_DICTIONARY:
		return str(first_present(value, ["tile", "code", "id"], ""))
	return str(value)

func normalize_last_discard_seat(value, fallback: int) -> int:
	if typeof(value) == TYPE_DICTIONARY:
		return int(first_present(value, ["seat", "fromSeat", "discardSeat"], fallback))
	return fallback

func normalize_online_players(value) -> Array:
	var result: Array = []
	if typeof(value) != TYPE_ARRAY:
		return result
	for item in value:
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var player: Dictionary = (item as Dictionary).duplicate(true)
		var hand_value = first_present(player, ["hand", "tiles"], [])
		var normalized_hand = normalize_tile_array(hand_value)
		player["seat"] = int(first_present(player, ["seat", "index", "position"], result.size()))
		player["name"] = str(first_present(player, ["name", "nickname", "userName"], "玩家"))
		player["handCount"] = numeric_count(first_present(player, ["handCount", "hand_count", "tileCount"], normalized_hand), normalized_hand.size())
		player["flowerCount"] = numeric_count(first_present(player, ["flowerCount", "flowers", "flower_count"], 0), 0)
		player["score"] = int(first_present(player, ["score", "points"], 0))
		player["discards"] = normalize_tile_array(first_present(player, ["discards", "discarded", "river"], []))
		player["melds"] = normalize_online_melds(first_present(player, ["melds", "openMelds", "sets"], []))
		result.append(player)
	return result


func normalize_online_melds(value) -> Array:
	var melds: Array = []
	if typeof(value) != TYPE_ARRAY:
		return melds
	for meld in value:
		if typeof(meld) == TYPE_ARRAY:
			melds.append(normalize_tile_array(meld))
		elif typeof(meld) == TYPE_DICTIONARY:
			melds.append(normalize_tile_array(first_present(meld, ["tiles", "meld", "cards"], [])))
	return melds

func normalize_online_pending(value, game: Dictionary) -> Dictionary:
	var pending: Dictionary = {}
	if typeof(value) == TYPE_DICTIONARY:
		pending = (value as Dictionary).duplicate(true)
	var options = normalize_claim_options(first_present(pending, ["options", "claims", "actions"], game.get("claimOptions", [])))
	pending["options"] = options
	pending["tile"] = normalize_last_discard_tile(first_present(pending, ["tile", "discard", "lastDiscard"], game.get("lastDiscard", "")))
	pending["fromSeat"] = int(first_present(pending, ["fromSeat", "discardSeat", "lastDiscardSeat"], game.get("lastDiscardSeat", -1)))
	pending["chi_choices"] = normalize_online_chi_choices(first_present(pending, ["chi_choices", "chiChoices", "choices", "chi"], game.get("chiChoices", [])), str(pending.get("tile", "")))
	if pending["chi_choices"].size() > 0 and not options.has("chi"):
		options.append("chi")
	return pending

func normalize_claim_options(value) -> Array:
	var options: Array = []
	if typeof(value) != TYPE_ARRAY:
		return options
	for item in value:
		var name = ""
		if typeof(item) == TYPE_DICTIONARY:
			name = str(first_present(item, ["claim", "type", "action", "name"], "")).strip_edges().to_lower()
		else:
			name = str(item).strip_edges().to_lower()
		match name:
			"吃", "chi":
				name = "chi"
			"碰", "peng", "pong":
				name = "peng"
			"杠", "gang", "kong":
				name = "gang"
			"胡", "hu", "win":
				name = "hu"
			"过", "pass":
				name = "pass"
		if name != "" and not options.has(name):
			options.append(name)
	return options

func normalize_online_chi_choices(value, claimed_tile: String = "") -> Array:
	var choices: Array = []
	if typeof(value) != TYPE_ARRAY:
		return choices
	for item in value:
		var choice = normalize_online_chi_choice(item, claimed_tile)
		if not choice.is_empty():
			choices.append(choice)
	return choices

func normalize_online_chi_choice(value, claimed_tile: String = "") -> Dictionary:
	var meld: Array = []
	var needed: Array = []
	if typeof(value) == TYPE_DICTIONARY:
		meld = normalize_tile_array(first_present(value, ["meld", "tiles", "cards"], []))
		needed = normalize_tile_array(first_present(value, ["needed", "handTiles", "use"], []))
	elif typeof(value) == TYPE_ARRAY:
		meld = normalize_tile_array(value)
	if meld.is_empty() and not needed.is_empty() and claimed_tile != "":
		meld = needed.duplicate()
		meld.append(claimed_tile)
		sort_hand(meld)
	if needed.is_empty() and not meld.is_empty() and claimed_tile != "":
		needed = meld.duplicate()
		needed.erase(claimed_tile)
	if meld.size() < 3:
		return {}
	return {"meld": meld, "needed": needed}

func render_room_log() -> void:
	if logs_label == null:
		return
	var room_code = str(first_present(online_room, ["code", "roomCode", "room_code"], selected_room))
	if room_code == "":
		room_code = "--"
	var text = "房间号：" + room_code + "\n\n"
	var players = online_room.get("players", [])
	if typeof(players) == TYPE_ARRAY and not players.is_empty():
		for player in players:
			if typeof(player) != TYPE_DICTIONARY:
				continue
			text += "%d号位  %s%s\n" % [int(player.get("seat", 0)) + 1, str(player.get("name", "空位")), "  AI" if bool(player.get("bot", false)) else ""]
	else:
		text += "等待房间状态同步。\n"
	text += "\n房间日志\n"
	var logs = online_room.get("logs", [])
	if typeof(logs) != TYPE_ARRAY:
		logs = []
	if logs.is_empty():
		text += "暂无日志。\n"
	for log_item in logs:
		if typeof(log_item) == TYPE_DICTIONARY:
			text += str(log_item.get("text", "")) + "\n"
		else:
			text += str(log_item) + "\n"
	logs_label.text = text

func start_offline(instant: bool = false) -> void:
	if transition_active and not instant:
		return
	var _build = func() -> void:
		_start_offline_impl()
	if instant or not fx_enabled_effective():
		_build.call()
	else:
		play_screen_transition(_build, false, "ink_wash")

func _start_offline_impl() -> void:
	if voice_enabled:
		stop_voice_chat(false)
	mode = "offline"
	recover_audio_after_screen_change()
	# 尝试加载进度
	var loaded = load_offline_progress()
	if not loaded:
		# 没有保存的进度，开始新游戏
		dealer_seat = 0
		offline_hand_number = 1
		offline_last_winner = -1
		offline_dealer_repeat = false
		table_logs.clear()
		players.clear()
		for i in range(4):
			players.append({
				"name": SEAT_NAMES[i],
				"hand": [],
				"discards": [],
				"melds": [],
				"flowers": 0,
				"flower_tiles": [],
				"score": MATCH_START_SCORE,
				"bot": i != 0,
			})
	else:
		# 加载了进度，继续之前的游戏
		set_status("已加载进度：第%d局" % offline_hand_number)
		offline_last_winner = -1
		offline_dealer_repeat = false
		table_logs.clear()
		# 确保players数组已经有4个玩家
		while players.size() < 4:
			players.append({
				"name": SEAT_NAMES[players.size()],
				"hand": [],
				"discards": [],
				"melds": [],
				"flowers": 0,
				"flower_tiles": [],
				"score": MATCH_START_SCORE,
				"bot": players.size() != 0,
			})
	deal_offline_hand()
	# 启动环境氛围动画
	start_ambient_animation("default")

func deal_offline_hand() -> void:
	mode = "offline"
	offline_phase = "await_discard"
	offline_turn_needs_draw = false
	offline_pending_claim.clear()
	clear_pending_danger_discard()
	offline_claim_counts.clear()
	offline_package_liability.clear()
	offline_last_draw.clear()
	offline_ai_active = false
	round_summary = ""
	last_score_deltas.clear()
	offline_last_winner = -1
	offline_dealer_repeat = false
	offline_draw_serial = 0
	fx_last_animated_draw_serial = -1
	current_seat = dealer_seat
	last_discard = ""
	last_discard_seat = -1
	for seat in range(players.size()):
		players[seat]["hand"] = []
		players[seat]["discards"] = []
		players[seat]["melds"] = []
		players[seat]["flowers"] = 0
		players[seat]["flower_tiles"] = []
	wall = make_wall()
	wall.shuffle()
	for round_index in range(13):
		for seat in range(4):
			draw_tile_for(seat, false)
	draw_tile_for(dealer_seat, false)
	for seat in range(4):
		sort_hand(players[seat]["hand"])
	add_log("第%d局开始，%s坐庄。" % [offline_hand_number, players[dealer_seat]["name"]])
	render_game()
	play_fx_deal_start(dealer_seat)
	play_fx_deal_cascade(dealer_seat)

func start_next_offline_hand(auto_run_ai: bool = true) -> void:
	if mode != "offline":
		return
	if is_offline_match_finished():
		return
	clear_fx_overlays()
	if not offline_dealer_repeat:
		dealer_seat = (dealer_seat + 1) % 4
		offline_hand_number += 1
	else:
		add_log("%s连庄。" % players[dealer_seat]["name"])
	deal_offline_hand()
	if auto_run_ai and current_seat != 0:
		run_ai_until_human()

func make_wall() -> Array[String]:
	var next_wall: Array[String] = []
	for code in TILE_CODES:
		for copy in range(4):
			next_wall.append(code)
	for code in FLOWER_CODES:
		next_wall.append(code)
	return next_wall

func draw_tile_for(seat: int, announce: bool = true, source: String = "normal") -> String:
	while not wall.is_empty():
		var tile = wall.pop_back()
		if is_flower_tile(tile):
			players[seat]["flowers"] = int(players[seat].get("flowers", 0)) + 1
			players[seat]["flower_tiles"].append(tile)
			if announce:
				add_log("%s补花%s。" % [players[seat]["name"], tile_label(tile)])
				play_sfx("draw", -7.0)
				play_fx_flower_bloom(seat, tile)
			continue
		players[seat]["hand"].append(tile)
		if announce:
			play_sfx("draw", -8.0)
		offline_draw_serial += 1
		offline_last_draw = {
			"seat": seat,
			"tile": tile,
			"source": source,
			"wall_empty": wall.is_empty(),
			"announce": announce,
			"serial": offline_draw_serial,
		}
		return tile
	return ""

func sort_hand(hand: Array) -> void:
	hand.sort_custom(func(a, b): return tile_sort_index(str(a)) < tile_sort_index(str(b)))

func render_game() -> void:
	var render_start_time = Time.get_ticks_msec()
	game_render_queued = false
	last_game_render_msec = Time.get_ticks_msec()
	clear_screen()
	# 延迟AI辅助计算，优先渲染关键UI
	current_human_advice = []
	draw_game_top_hud(root_layer)

	var outer = make_panel(root_layer, TABLE_OUTER_RECT, Color(0.11, 0.070, 0.033, 0.98), 34, UI_GOLD_SOFT)
	add_texture(outer, wood_texture, TABLE_OUTER_TEXTURE_RECT, 0.58)
	draw_table_ornaments(outer)

	var table = make_panel(outer, TABLE_INNER_RECT, UI_FELT, 26, UI_FELT_LINE)
	add_texture(table, felt_texture, TABLE_INNER_TEXTURE_RECT, 0.88)
	draw_table_atmosphere_frame(table)
	draw_walls(table)
	draw_table_living_illustration(table)
	draw_discards(table)
	draw_center(table)
	draw_melds(table)

	# 座位面板暂时不显示威胁报告
	var seat_threat_reports: Dictionary = {}
	for seat_layout in SEAT_LAYOUTS:
		draw_seat(root_layer, int(seat_layout[0]), seat_layout[1], str(seat_layout[2]), seat_threat_reports)
	draw_table_log(root_layer)
	draw_advisor_panel(root_layer)
	draw_hand(root_layer)
	draw_actions(root_layer)
	draw_round_summary(root_layer)

	# 记录渲染性能
	var render_elapsed = Time.get_ticks_msec() - render_start_time
	perf_render_count += 1
	perf_render_total_ms += render_elapsed

	# AI辅助异步更新（延迟到下一帧）
	if player_ai_assist_enabled() and mode == "offline" and can_self_discard():
		call_deferred("update_ai_assistance_async")
	draw_settings_overlay(root_layer)
	ensure_update_dialog()
	update_fx_turn_pulse()

func player_ai_assist_enabled() -> bool:
	return PLAYER_AI_ASSIST_ENABLED

func update_ai_assistance_async() -> void:
	# 异步更新AI辅助信息，不阻塞UI渲染
	if mode != "offline" or not can_self_discard():
		return

	var start_time = Time.get_ticks_msec()

	# 计算AI推荐
	current_human_advice = get_ai_discard_reports(0)

	var elapsed = Time.get_ticks_msec() - start_time
	perf_ai_decision_count += 1
	perf_ai_decision_total_ms += elapsed

	# 更新手牌显示的AI标注
	if not current_human_advice.is_empty():
		update_hand_ai_hints()

	# 计算对手威胁（如果启用）
	if player_ai_assist_enabled():
		var seat_threat_context = make_ai_evaluation_context(0, visible_tile_counts())
		var seat_threat_reports = render_seat_threat_reports(0, seat_threat_context)
		# 更新座位威胁显示
		update_seat_threats_display(seat_threat_reports)

func update_hand_ai_hints() -> void:
	# 更新手牌上的AI提示标记（如果手牌托盘已渲染）
	# 这里可以选择性地重绘手牌区域，或者等待下次render_game
	pass

func update_seat_threats_display(seat_threat_reports: Dictionary) -> void:
	# 更新座位威胁显示（如果座位面板已渲染）
	# 这里可以选择性地更新座位信息，或者等待下次render_game
	pass

func draw_game_top_hud(parent: Control) -> void:
	# 顶部HUD面板 - 增强视觉效果
	var hud = make_panel(parent, TOP_HUD_RECT, Color(0.010, 0.018, 0.022, 0.98), 20, Color(0.52, 0.44, 0.26, 0.58), 6)
	# 左侧金色装饰
	hud.add_child(make_color_rect(rect_full(0.008, 0.08, 0.015, 0.92), Color(0.90, 0.76, 0.36, 0.82)))
	# 顶部高光线
	hud.add_child(make_color_rect(rect_full(0.015, 0.04, 0.985, 0.12), Color(1.0, 1.0, 1.0, 0.04)))

	# 模式徽章
	var mode_text = "单机" if mode == "offline" else "联机"
	var mode_badge = make_badge(hud, TOP_HUD_MODE_BADGE_RECT, mode_text, 12, Color(0.018, 0.042, 0.048, 0.94), SEAT_ACCENT_COLORS[0], Color(0.92, 0.94, 0.88))
	mode_badge.name = "TopHudModeBadge"
	mode_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	draw_top_hud_status_art(hud)

	# 标题
	var title_text = "单机修炼场 第%d局" % [offline_hand_number] if mode == "offline" else "联机房间 " + str(online_game.get("roomCode", selected_room))
	var title = make_label(hud, title_text, 22, Color(0.96, 0.90, 0.60), true)
	apply_rect(title, TOP_HUD_TITLE_RECT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	configure_clipped_label(title)

	# 状态
	var status = make_label(hud, current_status_text(), 17, UI_TEXT_SUB, true)
	apply_rect(status, TOP_HUD_STATUS_RECT)
	configure_clipped_label(status)
	draw_top_hud_hand_progress(hud)

	# 分数条
	draw_score_strip(hud, TOP_HUD_SCORE_STRIP_RECT)

	# 余牌信息
	var wall = make_label(hud, top_hud_wall_text(), 12, Color(0.74, 0.78, 0.72), true)
	wall.add_theme_stylebox_override("normal", style(Color(0.016, 0.024, 0.028, 0.94), 10, Color(0.24, 0.28, 0.26, 0.36), 1, 0))
	apply_rect(wall, TOP_HUD_WALL_RECT)
	configure_clipped_label(wall)
	draw_top_hud_wall_meter(hud)

	# 操作按钮组
	var settings = make_top_hud_button("设置", Color(0.22, 0.44, 0.56), func() -> void:
		toggle_settings_panel()
	)
	hud.add_child(settings)
	apply_rect(settings, TOP_HUD_SETTINGS_BUTTON_RECT)

	var back = make_top_hud_button("返回", Color(0.36, 0.40, 0.40), func() -> void:
		if mode == "offline":
			show_exit_confirm()
		else:
			show_online_lobby()
	)
	hud.add_child(back)
	apply_rect(back, TOP_HUD_BACK_BUTTON_RECT)

	var update = make_top_hud_button("更新", Color(0.38, 0.48, 0.74), func() -> void:
		start_update_download()
	)
	hud.add_child(update)
	apply_rect(update, TOP_HUD_UPDATE_BUTTON_RECT)

func top_hud_wall_text() -> String:
	var last = get_last_discard()
	return "余%d 上%s" % [get_wall_count(), tile_label(last) if last != "" else "--"]

func draw_top_hud_hand_progress(parent: Control) -> Control:
	var progress = Control.new()
	progress.name = "TopHudHandProgress"
	progress.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(progress, TOP_HUD_HAND_PROGRESS_RECT)
	parent.add_child(progress)
	var fill = Color(0.012, 0.024, 0.026, 0.72)
	var accent = SEAT_ACCENT_COLORS[dealer_seat] if dealer_seat >= 0 and dealer_seat < SEAT_ACCENT_COLORS.size() else GOLD_PRIMARY
	var rail_panel = make_panel(progress, rect_full(0.010, 0.160, 0.990, 0.840), fill, 999, Color(accent.r, accent.g, accent.b, 0.20), 0)
	rail_panel.name = "HandProgressRail"
	var hand_count = MATCH_MAX_HANDS if mode == "offline" else 4
	var current_hand = clamp(offline_hand_number if mode == "offline" else 1, 1, hand_count)
	for i in range(hand_count):
		var center = 0.070 + float(i) * (0.700 / float(max(1, hand_count - 1)))
		var reached = i < current_hand
		var active = i == current_hand - 1
		var pip_color = Color(accent.r, accent.g, accent.b, 0.74 if reached else 0.20)
		var pip_border = Color(0.98, 0.86, 0.46, 0.42 if active else 0.16)
		var pip = make_panel(progress, rect_full(center - 0.015, 0.310, center + 0.015, 0.690), pip_color, 999, pip_border, 0)
		pip.name = "HandProgressPip_%d" % (i + 1)
		if active:
			var glow = make_panel(progress, rect_full(center - 0.029, 0.150, center + 0.029, 0.850), Color(accent.r, accent.g, accent.b, 0.14), 999, Color(1.0, 0.86, 0.42, 0.24), 0)
			glow.name = "HandProgressActiveGlow"
			progress.move_child(glow, max(0, pip.get_index()))
	var label = make_label(progress, "%d/%d局" % [current_hand, hand_count], 10, Color(0.90, 0.88, 0.74), true)
	label.name = "HandProgressLabel"
	apply_rect(label, rect_full(0.785, 0.100, 0.920, 0.900))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	var dealer_badge = make_badge(progress, rect_full(0.925, 0.160, 0.995, 0.840), CENTER_WIND_LABELS[dealer_seat] if dealer_seat >= 0 and dealer_seat < CENTER_WIND_LABELS.size() else "庄", 9, Color(accent.r, accent.g, accent.b, 0.42), Color(0.96, 0.78, 0.38, 0.28), Color(0.98, 0.92, 0.72))
	dealer_badge.name = "HandProgressDealerBadge"
	dealer_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if mode == "offline" and offline_dealer_repeat:
		var repeat_badge = make_badge(progress, rect_full(0.805, -0.160, 0.930, 0.300), "连庄", 8, Color(0.50, 0.12, 0.08, 0.94), Color(0.96, 0.62, 0.34, 0.32), Color(0.98, 0.90, 0.72))
		repeat_badge.name = "HandProgressRepeatBadge"
		repeat_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if fx_enabled_effective() and DisplayServer.get_name().to_lower() != "headless":
		var tw := create_tween()
		tw.set_loops(12)
		tw.tween_property(rail_panel, "modulate:a", 0.58, 0.72).from(0.94)
		tw.tween_property(rail_panel, "modulate:a", 0.94, 0.72).from(0.58)
	return progress

func draw_top_hud_status_art(parent: Control) -> Control:
	var art = Control.new()
	art.name = "TopHudStatusArt"
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(art, rect_full(0.104, 0.120, 0.132, 0.880))
	parent.add_child(art)
	var color = center_phase_color(center_phase_key())
	var icon_back = make_panel(art, rect_full(0.08, 0.18, 0.92, 0.82), Color(color.r, color.g, color.b, 0.18), 999, Color(color.r, color.g, color.b, 0.36), 0)
	icon_back.name = "TopHudStatusIconBack"
	var icon_name = top_hud_status_icon_name()
	if icon_name != "":
		add_lucide_icon(art, icon_name, rect_full(0.24, 0.30, 0.76, 0.70), Color(0.96, 0.92, 0.76, 0.86))
	var pulse = make_panel(art, rect_full(0.010, 0.080, 0.990, 0.920), Color(color.r, color.g, color.b, 0.08), 999, Color(color.r, color.g, color.b, 0.18), 0)
	pulse.name = "TopHudStatusPulse"
	art.move_child(pulse, 0)
	var rail = make_panel(parent, rect_full(0.106, 0.820, 0.425, 0.870), Color(color.r, color.g, color.b, 0.16), 999, Color(color.r, color.g, color.b, 0.12), 0)
	rail.name = "TopHudStatusRail"
	for i in range(3):
		var left = 0.118 + float(i) * 0.018
		var pip = make_panel(parent, rect_full(left, 0.180, left + 0.008, 0.300), Color(color.r, color.g, color.b, 0.38), 999, Color(1.0, 0.90, 0.56, 0.12), 0)
		pip.name = "TopHudStatusPip_%d" % i
	if fx_enabled_effective() and DisplayServer.get_name().to_lower() != "headless":
		var tw := create_tween()
		tw.set_loops(12)
		tw.tween_property(pulse, "modulate:a", 0.24, 0.70).from(0.86)
		tw.tween_property(pulse, "modulate:a", 0.86, 0.70).from(0.24)
	return art

func top_hud_status_icon_name() -> String:
	if mode == "online_game" or mode == "online_lobby":
		return "users"
	match center_phase_key():
		"discard":
			return "zap"
		"claim":
			return "sparkles"
		"ended":
			return "trophy"
		"wait":
			return "pause"
	return "info"

func draw_top_hud_wall_meter(parent: Control) -> Control:
	var meter = Control.new()
	meter.name = "TopHudWallMeter"
	meter.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(meter, TOP_HUD_WALL_RECT)
	parent.add_child(meter)
	var progress = clamp(float(get_wall_count()) / 144.0, 0.0, 1.0)
	var color = wall_meter_color(progress)
	var rail = make_panel(meter, rect_full(0.08, 0.76, 0.92, 0.90), Color(0.006, 0.012, 0.014, 0.76), 999, Color(color.r, color.g, color.b, 0.18), 0)
	rail.name = "TopHudWallMeterRail"
	var fill = make_panel(meter, rect_full(0.08, 0.76, 0.08 + 0.84 * progress, 0.90), Color(color.r, color.g, color.b, 0.70), 999, Color(color.r, color.g, color.b, 0.22), 0)
	fill.name = "TopHudWallMeterFill"
	var dot = make_panel(meter, rect_full(0.060, 0.170, 0.190, 0.430), Color(color.r, color.g, color.b, 0.72), 999, Color(1.0, 0.90, 0.56, 0.28), 0)
	dot.name = "TopHudWallStatusDot"
	return meter

func draw_score_strip(parent: Control, rect: Rect2) -> void:
	var strip = Control.new()
	strip.name = "ScoreStrip"
	parent.add_child(strip)
	apply_rect(strip, rect)
	for seat in range(4):
		var active = get_current_seat() == seat
		var player = get_player_info(seat)
		var chip_fill = Color(0.008, 0.016, 0.018, 0.96) if active else Color(0.006, 0.014, 0.016, 0.92)
		var chip_border = Color(0.56, 0.46, 0.22, 0.72) if active else Color(0.28, 0.32, 0.30, 0.28)
		var chip = make_panel(strip, SCORE_STRIP_CHIP_RECTS[seat], chip_fill, 12, chip_border, 3)
		chip.name = "ScoreStripChip_%d" % seat
		# 座位颜色标识
		chip.add_child(make_color_rect(SCORE_STRIP_ACCENT_RECT, SEAT_ACCENT_COLORS[seat]))
		draw_score_strip_chip_art(chip, seat, int(player.get("score", 0)), active)
		# 玩家名称
		var name_text = "我" if seat == 0 else ai_profile_short_label(seat) if mode == "offline" else str(player.get("name", "玩家"))
		var name = make_label(chip, name_text, 11, Color(0.94, 0.90, 0.78), true)
		name.add_theme_stylebox_override("normal", style(SEAT_NAME_BADGE_COLORS[seat].darkened(0.12), 8, Color(0.88, 0.78, 0.44, 0.14), 1, 0))
		apply_rect(name, SCORE_STRIP_NAME_RECT)
		configure_clipped_label(name)
		# 分数
		var score = make_label(chip, compact_score_text(int(player.get("score", 0))), 13, Color(0.96, 0.94, 0.88), true)
		apply_rect(score, SCORE_STRIP_SCORE_RECT)
		score.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		configure_clipped_label(score)

func draw_score_strip_chip_art(parent: Control, seat: int, score: int, active: bool) -> Control:
	var art = Control.new()
	art.name = "ScoreStripChipArt_%d" % seat
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art.set_anchors_preset(Control.PRESET_FULL_RECT)
	parent.add_child(art)
	var accent = SEAT_ACCENT_COLORS[seat] if seat >= 0 and seat < SEAT_ACCENT_COLORS.size() else GOLD_PRIMARY
	var seal = make_panel(art, rect_full(0.045, 0.165, 0.170, 0.835), Color(accent.r, accent.g, accent.b, 0.18), 999, Color(accent.r, accent.g, accent.b, 0.30), 0)
	seal.name = "ScoreStripSeatSeal_%d" % seat
	var wind = make_label(seal, seat_wind_label(seat), 9, Color(0.96, 0.88, 0.62, 0.86), true)
	apply_rect(wind, rect_full(0.0, 0.0, 1.0, 1.0))
	var baseline = MATCH_START_SCORE
	var delta = score - baseline
	var momentum = clamp(abs(float(delta)) / float(max(1, baseline)), 0.08, 1.0)
	var positive = delta >= 0
	var fill_color = Color(0.34, 0.68, 0.48, 0.52) if positive else Color(0.72, 0.36, 0.30, 0.52)
	var rail = make_panel(art, rect_full(0.205, 0.760, 0.940, 0.875), Color(0.006, 0.014, 0.016, 0.54), 999, Color(accent.r, accent.g, accent.b, 0.10), 0)
	rail.name = "ScoreStripMomentumRail_%d" % seat
	var fill_right = 0.205 + 0.735 * momentum
	var fill = make_panel(art, rect_full(0.205, 0.760, fill_right, 0.875), fill_color, 999, fill_color.lightened(0.12), 0)
	fill.name = "ScoreStripMomentumFill_%d" % seat
	if active:
		var pulse = make_panel(art, rect_full(0.010, 0.060, 0.990, 0.940), Color(accent.r, accent.g, accent.b, 0.07), 12, Color(0.96, 0.78, 0.34, 0.18), 0)
		pulse.name = "ScoreStripActivePulse"
		art.move_child(pulse, 0)
		if fx_enabled_effective() and DisplayServer.get_name().to_lower() != "headless":
			var tw := create_tween()
			tw.set_loops(12)
			tw.tween_property(pulse, "modulate:a", 0.25, 0.70).from(0.82)
			tw.tween_property(pulse, "modulate:a", 0.82, 0.70).from(0.25)
	return art

func draw_settings_overlay(parent: Control) -> void:
	if not settings_panel_open:
		return
	var overlay = Control.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	parent.add_child(overlay)

	# 设置面板 - 更精致的样式
	var panel = make_panel(overlay, SETTINGS_PANEL_RECT, Color(0.008, 0.014, 0.016, 0.99), 20, Color(0.14, 0.12, 0.08, 0.36), 5)
	# 标题栏
	make_panel(panel, rect_full(0.0, 0.0, 1.0, 0.16), Color(0.040, 0.052, 0.048, 0.76), 20, Color(1.0, 1.0, 1.0, 0.030))
	# 左侧金色装饰
	panel.add_child(make_color_rect(rect_full(0.006, 0.02, 0.014, 0.98), Color(0.90, 0.76, 0.36, 0.72)))

	var title = make_label(panel, "设置", 24, Color(0.94, 0.82, 0.42), true)
	apply_rect(title, SETTINGS_TITLE_RECT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	add_lucide_icon(panel, "settings", rect_full(0.035, 0.050, 0.068, 0.125), Color(0.96, 0.84, 0.46, 0.86))

	var close = make_small_button("关闭", Color(0.30, 0.34, 0.36), func() -> void:
		close_settings_panel()
	)
	close.custom_minimum_size = Vector2(88, 42)
	panel.add_child(close)
	apply_rect(close, SETTINGS_CLOSE_RECT)

	# 声音设置
	var audio_grid = make_settings_section(panel, SETTINGS_AUDIO_SECTION_RECT, "声音")
	audio_grid.columns = 1
	make_setting_row(audio_grid, "背景音乐", "当前: %s" % ("开启" if music_enabled else "关闭"), make_setting_button("音乐", music_enabled, func() -> void:
		toggle_music_setting()
	))
	make_setting_row(audio_grid, "音效反馈", "当前: %s" % ("开启" if sfx_enabled else "关闭"), make_setting_button("音效", sfx_enabled, func() -> void:
		toggle_sfx_setting()
	))
	make_setting_row(audio_grid, "语音报牌", "当前: %s" % ("开启" if tts_enabled else "关闭"), make_setting_button("报牌", tts_enabled, func() -> void:
		toggle_tts_setting()
	))
	make_setting_row(audio_grid, "播放测试", "试听当前音效音量", make_audio_test_button(func() -> void:
		test_audio_setting()
	))

	# 体验设置
	var play_grid = make_settings_section(panel, SETTINGS_PLAY_SECTION_RECT, "体验")
	play_grid.columns = 1
	make_setting_row(play_grid, "AI 节奏", "当前: %s" % ("快速" if fast_mode_enabled else "标准"), make_setting_button("快速", fast_mode_enabled, func() -> void:
		toggle_fast_mode_setting()
	))
	make_setting_row(play_grid, "桌面特效", "当前: %s" % ("开启" if fx_enabled else "关闭"), make_setting_button("特效", fx_enabled, func() -> void:
		toggle_fx_setting()
	))
	make_setting_row(play_grid, "播放曲目", str(BGM_TRACKS[current_bgm_index].get("name", "默认曲目")), make_bgm_switch_button(func() -> void:
		switch_bgm_track()
	))

	# 维护设置
	var maint_grid = make_settings_section(panel, SETTINGS_MAINT_SECTION_RECT, "维护")
	maint_grid.columns = 1
	make_setting_row(maint_grid, "本地进度", "清空统计、偏好和离线记录", make_reset_progress_button(func() -> void:
		reset_offline_progress()
		close_settings_panel()
	))

func make_settings_section(parent: Control, rect: Rect2, title_text: String) -> GridContainer:
	var section = make_panel(parent, rect, Color(0.010, 0.018, 0.022, 0.88), 14, Color(0.30, 0.34, 0.30, 0.26), 0)
	# 左侧彩色装饰条
	section.add_child(make_color_rect(rect_full(0.004, 0.02, 0.012, 0.98), Color(0.86, 0.74, 0.38, 0.52)))
	draw_settings_section_signal(section, title_text)
	var section_title = make_label(section, title_text, 14, Color(0.90, 0.84, 0.60), true)
	apply_rect(section_title, SETTINGS_SECTION_TITLE_RECT)
	section_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	var grid = GridContainer.new()
	configure_passive_container(grid)
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 12)
	section.add_child(grid)
	apply_rect(grid, SETTINGS_SECTION_GRID_RECT)
	return grid

func draw_settings_section_signal(parent: Control, title_text: String) -> Control:
	var art = Control.new()
	art.name = "SettingsSectionSignal_%s" % title_text
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(art, rect_full(0.585, 0.035, 0.965, 0.155))
	parent.add_child(art)
	var accent = settings_section_color(title_text)
	var rail = make_panel(art, rect_full(0.080, 0.430, 0.920, 0.570), Color(accent.r, accent.g, accent.b, 0.18), 999, Color(accent.r, accent.g, accent.b, 0.12), 0)
	rail.name = "SettingsSectionSignalRail_%s" % title_text
	var icon = make_panel(art, rect_full(0.000, 0.155, 0.115, 0.845), Color(accent.r, accent.g, accent.b, 0.22), 999, Color(accent.r, accent.g, accent.b, 0.28), 0)
	icon.name = "SettingsSectionSignalIcon_%s" % title_text
	var icon_name = settings_section_icon(title_text)
	if icon_name != "":
		add_lucide_icon(icon, icon_name, rect_full(0.22, 0.22, 0.78, 0.78), Color(0.96, 0.90, 0.64, 0.82))
	for i in range(3):
		var left = 0.270 + float(i) * 0.185
		var pulse = make_panel(art, rect_full(left, 0.270, left + 0.050, 0.730), Color(accent.r, accent.g, accent.b, 0.38), 999, Color(1.0, 0.90, 0.54, 0.12), 0)
		pulse.name = "SettingsSectionSignalPulse_%s_%d" % [title_text, i]
	return art

func settings_section_color(title_text: String) -> Color:
	match title_text:
		"声音":
			return Color(0.34, 0.58, 0.72)
		"体验":
			return Color(0.34, 0.62, 0.46)
		"维护":
			return Color(0.70, 0.48, 0.34)
	return Color(0.62, 0.54, 0.34)

func settings_section_icon(title_text: String) -> String:
	match title_text:
		"声音":
			return "volume-2"
		"体验":
			return "sparkles"
		"维护":
			return "wrench"
	return "settings"

func make_setting_row(parent: Control, title: String, status: String, button: Button) -> void:
	var row = Panel.new()
	configure_passive_container(row)
	row.custom_minimum_size = Vector2(0, 42)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_stylebox_override("panel", style(Color(0.018, 0.028, 0.032, 0.88), 10, Color(0.28, 0.34, 0.30, 0.42), 1, 0))
	parent.add_child(row)
	var label = make_label(row, "%s\n%s" % [title, status], 12, Color(0.82, 0.84, 0.78), false)
	apply_rect(label, SETTINGS_ROW_STATUS_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	configure_clipped_label(label)
	button.custom_minimum_size = Vector2(0, 0)
	apply_rect(button, SETTINGS_ROW_BUTTON_RECT)
	row.add_child(button)

func make_setting_button(label: String, enabled: bool, callback: Callable) -> Button:
	var color = Color(0.22, 0.52, 0.42) if enabled else Color(0.44, 0.32, 0.28)
	var button = make_small_button("%s%s" % [label, "开" if enabled else "关"], color, callback)
	button.custom_minimum_size = Vector2(140, 48)
	button.add_theme_font_size_override("font_size", 18)
	draw_setting_switch_art(button, enabled)
	return button

func draw_setting_switch_art(parent: Control, enabled: bool) -> Control:
	var art = Control.new()
	art.name = "SettingSwitchArt"
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(art, rect_full(0.690, 0.230, 0.960, 0.770))
	parent.add_child(art)
	var rail_color = Color(0.16, 0.36, 0.30, 0.86) if enabled else Color(0.30, 0.22, 0.20, 0.82)
	var rail_border = Color(0.48, 0.78, 0.60, 0.42) if enabled else Color(0.66, 0.46, 0.38, 0.30)
	var rail = make_panel(art, rect_full(0.04, 0.20, 0.96, 0.80), rail_color, 999, rail_border, 0)
	rail.name = "SettingSwitchRail"
	var energy_rail = make_panel(art, rect_full(0.115, 0.405, 0.885, 0.595), Color(0.010, 0.020, 0.022, 0.54), 999, Color(rail_border.r, rail_border.g, rail_border.b, 0.14), 0)
	energy_rail.name = "SettingSwitchEnergyRail"
	var energy_right = 0.115 + 0.770 * (0.88 if enabled else 0.18)
	var energy_fill = make_panel(art, rect_full(0.115, 0.430, energy_right, 0.570), Color(0.54, 0.86, 0.62, 0.48) if enabled else Color(0.74, 0.48, 0.40, 0.22), 999, Color(0.78, 0.96, 0.70, 0.12), 0)
	energy_fill.name = "SettingSwitchEnergyFill"
	var knob_left = 0.58 if enabled else 0.10
	var knob = make_panel(art, rect_full(knob_left, 0.08, knob_left + 0.32, 0.92), Color(0.92, 0.88, 0.72, 0.96), 999, Color(1.0, 0.94, 0.64, 0.42), 0)
	knob.name = "SettingSwitchKnobOn" if enabled else "SettingSwitchKnobOff"
	for i in range(2):
		var spark_left = (0.210 + float(i) * 0.150) if enabled else (0.620 + float(i) * 0.120)
		var spark = make_panel(art, rect_full(spark_left, 0.065, spark_left + 0.038, 0.210), Color(0.74, 0.94, 0.66, 0.32) if enabled else Color(0.82, 0.54, 0.44, 0.18), 999, Color(0.86, 0.98, 0.70, 0.10), 0)
		spark.name = "SettingSwitchStateSpark_%d" % i
	# 滑钮入场滑动动画
	if fx_enabled_effective() and DisplayServer.get_name().to_lower() != "headless":
		var start_left = 0.10 if enabled else 0.58
		knob.anchor_left = start_left
		knob.anchor_right = start_left + 0.32
		var slide_tw := create_tween()
		slide_tw.tween_property(knob, "anchor_left", knob_left, 0.22).from(start_left).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		slide_tw.parallel().tween_property(knob, "anchor_right", knob_left + 0.32, 0.22).from(start_left + 0.32).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if enabled:
		var shine = make_panel(art, rect_full(0.18, 0.34, 0.36, 0.66), Color(0.72, 0.94, 0.70, 0.38), 999, Color(0, 0, 0, 0), 0)
		shine.name = "SettingSwitchOnLight"
	else:
		var off_lock = make_panel(art, rect_full(0.660, 0.285, 0.840, 0.715), Color(0.82, 0.54, 0.44, 0.20), 999, Color(0.92, 0.64, 0.54, 0.12), 0)
		off_lock.name = "SettingSwitchOffLock"
	return art

func make_audio_test_button(callback: Callable) -> Button:
	var button = make_small_button("试音", Color(0.28, 0.42, 0.56), callback)
	button.custom_minimum_size = Vector2(140, 48)
	button.add_theme_font_size_override("font_size", 18)
	return button

func make_bgm_switch_button(callback: Callable) -> Button:
	# v1.0.157: 切换BGM按钮
	var track_name = BGM_TRACKS[current_bgm_index]["name"]
	var button = make_small_button("切歌:" + track_name, Color(0.38, 0.40, 0.56), callback)
	button.custom_minimum_size = Vector2(140, 48)
	button.add_theme_font_size_override("font_size", 16)
	return button

func make_reset_progress_button(callback: Callable) -> Button:
	var button = make_small_button("重置进度", Color(0.56, 0.36, 0.30), callback)
	button.custom_minimum_size = Vector2(140, 48)
	button.add_theme_font_size_override("font_size", 18)
	return button

func draw_table_ornaments(parent: Control) -> void:
	for item in TABLE_ORNAMENT_EDGES:
		make_panel(parent, item[0], item[1], 8, item[2], 0)
	for item in TABLE_CORNER_RECTS:
		draw_table_corner(parent, item)

func draw_table_corner(parent: Control, rects: Array) -> void:
	make_panel(parent, rects[0], TABLE_CORNER_FILL, 5, TABLE_CORNER_BORDER, 0)
	make_panel(parent, rects[1], TABLE_CORNER_VERTICAL_FILL, 5, TABLE_CORNER_VERTICAL_BORDER, 0)

func draw_walls(parent: Control) -> void:
	for item in WALL_LAYOUTS:
		var strip = make_wall_back_strip(int(item[2]), bool(item[3]))
		strip.anchor_left = item[0].x
		strip.anchor_top = item[0].y
		strip.anchor_right = item[1].x
		strip.anchor_bottom = item[1].y
		parent.add_child(strip)


func make_wall_back_tile(size: Vector2 = WALL_BACK_TILE_SIZE, detailed: bool = true) -> Control:
	var panel = Panel.new()
	panel.custom_minimum_size = size
	panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.clip_contents = true
	panel.add_theme_stylebox_override("panel", style(Color(0.73, 0.69, 0.56, 0.98), 7, Color(0.34, 0.29, 0.18, 0.82), 1, 2 if detailed else 0))
	if not detailed:
		return panel
	var texture = TextureRect.new()
	texture.texture = tile_back
	texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture.modulate = Color(1, 1, 1, 0.20)
	texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture.set_anchors_preset(Control.PRESET_FULL_RECT)
	texture.offset_left = 3
	texture.offset_top = 3
	texture.offset_right = -3
	texture.offset_bottom = -3
	panel.add_child(texture)
	var mark = make_label(panel, "云", max(9, int(size.y * 0.34)), Color(0.22, 0.17, 0.10, 0.82), true)
	mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(mark, rect_full(0.12, 0.18, 0.88, 0.82))
	return panel

func draw_discards(parent: Control) -> void:
	var table_size = game_table_pixel_size()
	for zone in DISCARD_ZONES:
		var seat = int(zone[0])
		var zone_rect: Rect2 = zone[1]
		var grid = GridContainer.new()
		configure_passive_container(grid)
		grid.columns = int(zone[2])
		apply_rect(grid, zone_rect)
		grid.add_theme_constant_override("h_separation", DISCARD_GRID_SEPARATION)
		grid.add_theme_constant_override("v_separation", DISCARD_GRID_SEPARATION)
		parent.add_child(grid)
		var discards = get_discards(seat)
		var visible_rows = discard_zone_visible_rows_for_table_size(zone_rect, grid.columns, table_size)
		var tile_size = discard_zone_tile_size_for_table_size(zone_rect, grid.columns, visible_rows, table_size)
		var visible_start = tail_window_start(discards.size(), grid.columns * visible_rows)
		var visible_count = discards.size() - visible_start
		draw_discard_river_art(parent, seat, zone_rect, discards.size(), visible_start, visible_count)
		for i in range(visible_count):
			var source_index = visible_start + i
			var highlighted = seat == get_last_discard_seat() and i == visible_count - 1
			grid.add_child(make_tile_view(str(discards[source_index]), tile_size, false, Callable(), highlighted))
		if seat == get_last_discard_seat() and visible_count > 0:
			draw_last_discard_focus_marker(parent, seat, table_size)

func draw_discard_river_art(parent: Control, seat: int, zone_rect: Rect2, discard_count: int, visible_start: int, visible_count: int) -> Control:
	var art = Control.new()
	art.name = "DiscardRiverArt_%d" % seat
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(art, zone_rect)
	parent.add_child(art)
	var accent = SEAT_ACCENT_COLORS[seat] if seat >= 0 and seat < SEAT_ACCENT_COLORS.size() else GOLD_PRIMARY
	var wash = make_color_rect(rect_full(0.000, 0.000, 1.000, 1.000), Color(0.006, 0.014, 0.016, 0.10))
	wash.name = "DiscardRiverWash_%d" % seat
	art.add_child(wash)
	var rail = make_color_rect(rect_full(0.020, 0.050, 0.980, 0.075), Color(accent.r, accent.g, accent.b, 0.24))
	rail.name = "DiscardRiverSeatRail_%d" % seat
	art.add_child(rail)
	var flow = make_color_rect(rect_full(0.060, 0.900, 0.940, 0.930), Color(0.86, 0.74, 0.42, 0.12))
	flow.name = "DiscardRiverFlowLine_%d" % seat
	art.add_child(flow)
	var bead_count = min(5, max(1, visible_count))
	for i in range(bead_count):
		var center = 0.110 + float(i) * (0.780 / float(max(1, bead_count - 1)))
		var bead = make_panel(art, rect_full(center - 0.014, 0.855, center + 0.014, 0.970), Color(accent.r, accent.g, accent.b, 0.28), 999, Color(1.0, 0.88, 0.48, 0.10), 0)
		bead.name = "DiscardRiverWindowBead_%d_%d" % [seat, i]
	if visible_start > 0:
		var overflow = make_panel(art, rect_full(0.018, 0.780, 0.092, 0.960), Color(0.72, 0.54, 0.26, 0.20), 999, Color(0.96, 0.82, 0.46, 0.16), 0)
		overflow.name = "DiscardRiverOverflow_%d" % seat
	if seat == get_last_discard_seat() and discard_count > 0:
		var focus = make_color_rect(rect_full(0.015, 0.120, 0.985, 0.160), Color(0.96, 0.78, 0.34, 0.20))
		focus.name = "DiscardRiverLastSource_%d" % seat
		art.add_child(focus)
	return art

func draw_last_discard_focus_marker(parent: Control, seat: int, table_size: Vector2 = Vector2.ZERO) -> Control:
	var marker_rect = last_discard_focus_marker_rect_for_seat(seat, table_size)
	if marker_rect.size == Vector2.ZERO:
		return null
	var tile = get_last_discard()
	var marker = Control.new()
	marker.name = "LastDiscardFocusMarker"
	marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(marker, marker_rect)
	parent.add_child(marker)
	var accent = SEAT_ACCENT_COLORS[seat] if seat >= 0 and seat < SEAT_ACCENT_COLORS.size() else GOLD_PRIMARY
	var glow = make_panel(marker, rect_full(0.04, 0.04, 0.96, 0.96), Color(accent.r, accent.g, accent.b, 0.10), 12, Color(0.96, 0.78, 0.34, 0.58), 0)
	glow.name = "LastDiscardFocusGlow"
	var badge = make_badge(marker, rect_full(-0.32, -0.34, 1.32, 0.20), "%s 刚打 %s" % [pending_claim_source_badge_text(seat), tile_label(tile)], 9, Color(0.018, 0.036, 0.038, 0.94), Color(0.88, 0.68, 0.32, 0.42), Color(0.96, 0.92, 0.76))
	badge.name = "LastDiscardFocusBadge"
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_lucide_icon(marker, "sparkles", rect_full(0.68, -0.28, 1.10, 0.22), Color(0.98, 0.86, 0.42, 0.72))
	if fx_enabled_effective():
		marker.modulate = Color(1, 1, 1, 0)
		marker.scale = Vector2(0.92, 0.92)
		var tw := create_tween()
		tw.set_parallel(true)
		tw.tween_property(marker, "modulate:a", 1.0, 0.16).from(0.0)
		tw.tween_property(marker, "scale", Vector2(1.0, 1.0), 0.18).from(Vector2(0.92, 0.92)).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	return marker

func last_discard_focus_marker_rect_for_seat(seat: int, table_size: Vector2 = Vector2.ZERO) -> Rect2:
	var discards = get_discards(seat)
	if discards.is_empty() or seat != get_last_discard_seat():
		return Rect2()
	var resolved_table_size = table_size if table_size.x > 0.0 and table_size.y > 0.0 else game_table_pixel_size()
	for zone in DISCARD_ZONES:
		if int(zone[0]) != seat:
			continue
		var zone_rect: Rect2 = zone[1]
		var columns = int(zone[2])
		var visible_rows = discard_zone_visible_rows_for_table_size(zone_rect, columns, resolved_table_size)
		var tile_size = discard_zone_tile_size_for_table_size(zone_rect, columns, visible_rows, resolved_table_size)
		var visible_start = tail_window_start(discards.size(), columns * visible_rows)
		var visible_index = discards.size() - 1 - visible_start
		if visible_index < 0:
			return Rect2()
		var col = visible_index % max(1, columns)
		var row = visible_index / max(1, columns)
		var left_px = float(col) * (tile_size.x + float(DISCARD_GRID_SEPARATION))
		var top_px = float(row) * (tile_size.y + float(DISCARD_GRID_SEPARATION))
		var zone_width_px = max(1.0, (zone_rect.size.x - zone_rect.position.x) * resolved_table_size.x)
		var zone_height_px = max(1.0, (zone_rect.size.y - zone_rect.position.y) * resolved_table_size.y)
		var left = zone_rect.position.x + left_px / resolved_table_size.x
		var top = zone_rect.position.y + top_px / resolved_table_size.y
		var right = left + tile_size.x / resolved_table_size.x
		var bottom = top + tile_size.y / resolved_table_size.y
		var pad_x = min(0.014, (zone_rect.size.x - zone_rect.position.x) * 0.08)
		var pad_y = min(0.020, (zone_rect.size.y - zone_rect.position.y) * 0.08)
		left = clamp(left - pad_x, zone_rect.position.x, zone_rect.size.x)
		top = clamp(top - pad_y, zone_rect.position.y, zone_rect.size.y)
		right = clamp(right + pad_x, zone_rect.position.x, zone_rect.size.x)
		bottom = clamp(bottom + pad_y, zone_rect.position.y, zone_rect.size.y)
		if right <= left or bottom <= top or zone_width_px <= 0.0 or zone_height_px <= 0.0:
			return Rect2()
		return Rect2(Vector2(left, top), Vector2(right, bottom))
	return Rect2()

func discard_zone_visible_rows(zone_rect: Rect2, columns: int) -> int:
	return discard_zone_visible_rows_for_table_size(zone_rect, columns, game_table_pixel_size())

func discard_zone_visible_rows_for_table_size(zone_rect: Rect2, columns: int, table_size: Vector2) -> int:
	var zone_size = discard_zone_pixel_size_for_table_size(zone_rect, table_size)
	var max_rows = int(floor((zone_size.y + float(DISCARD_GRID_SEPARATION)) / (DISCARD_TILE_MIN_SIZE.y + float(DISCARD_GRID_SEPARATION))))
	return clamp(max_rows, 1, 3)

func discard_zone_tile_size(zone_rect: Rect2, columns: int, rows: int) -> Vector2:
	return discard_zone_tile_size_for_table_size(zone_rect, columns, rows, game_table_pixel_size())

func discard_zone_tile_size_for_table_size(zone_rect: Rect2, columns: int, rows: int, table_size: Vector2) -> Vector2:
	var zone_size = discard_zone_pixel_size_for_table_size(zone_rect, table_size)
	var safe_columns = max(1, columns)
	var safe_rows = max(1, rows)
	var available_width = max(1.0, (zone_size.x - float(DISCARD_GRID_SEPARATION * (safe_columns - 1))) / float(safe_columns))
	var available_height = max(1.0, (zone_size.y - float(DISCARD_GRID_SEPARATION * (safe_rows - 1))) / float(safe_rows))
	var width = min(DISCARD_TILE_MAX_SIZE.x, available_width, available_height / DISCARD_TILE_ASPECT)
	var height = min(DISCARD_TILE_MAX_SIZE.y, available_height, width * DISCARD_TILE_ASPECT)
	width = min(width, height / DISCARD_TILE_ASPECT)
	return Vector2(max(1.0, floor(width)), max(1.0, floor(height)))

func discard_grid_fits_zone(zone_rect: Rect2, columns: int, rows: int, tile_size: Vector2) -> bool:
	return discard_grid_fits_zone_for_table_size(zone_rect, columns, rows, tile_size, game_table_pixel_size())

func discard_grid_fits_zone_for_table_size(zone_rect: Rect2, columns: int, rows: int, tile_size: Vector2, table_size: Vector2) -> bool:
	var zone_size = discard_zone_pixel_size_for_table_size(zone_rect, table_size)
	var required_width = float(columns) * tile_size.x + float(max(0, columns - 1) * DISCARD_GRID_SEPARATION)
	var required_height = float(rows) * tile_size.y + float(max(0, rows - 1) * DISCARD_GRID_SEPARATION)
	return required_width <= zone_size.x + 0.5 and required_height <= zone_size.y + 0.5

func discard_zone_pixel_size(zone_rect: Rect2) -> Vector2:
	return discard_zone_pixel_size_for_table_size(zone_rect, game_table_pixel_size())

func discard_zone_pixel_size_for_table_size(zone_rect: Rect2, table_size: Vector2) -> Vector2:
	return Vector2((zone_rect.size.x - zone_rect.position.x) * table_size.x, (zone_rect.size.y - zone_rect.position.y) * table_size.y)

func game_table_pixel_size() -> Vector2:
	var content_size = safe_content_pixel_size()
	return Vector2(content_size.x * 0.710 * 0.910, content_size.y * 0.657 * 0.890)

func effective_viewport_size() -> Vector2:
	var viewport_size = get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		viewport_size = Vector2(
			float(ProjectSettings.get_setting("display/window/size/viewport_width", 1280)),
			float(ProjectSettings.get_setting("display/window/size/viewport_height", 720))
		)
	return viewport_size

func current_safe_area_margins() -> Vector4:
	var window_size_i = DisplayServer.window_get_size()
	var safe_area_i = DisplayServer.get_display_safe_area()
	var window_size = Vector2(float(window_size_i.x), float(window_size_i.y))
	var safe_area = Rect2(
		Vector2(float(safe_area_i.position.x), float(safe_area_i.position.y)),
		Vector2(float(safe_area_i.size.x), float(safe_area_i.size.y))
	)
	return safe_area_margins_for_viewport(effective_viewport_size(), window_size, safe_area)

func safe_area_margins_for_viewport(viewport_size: Vector2, window_size: Vector2 = Vector2.ZERO, safe_area: Rect2 = Rect2()) -> Vector4:
	var margins = SAFE_CONTENT_MIN_MARGIN
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return margins
	if window_size.x > 0.0 and window_size.y > 0.0 and safe_area.size.x > 0.0 and safe_area.size.y > 0.0:
		var scale_x = viewport_size.x / window_size.x
		var scale_y = viewport_size.y / window_size.y
		margins.x = max(margins.x, max(0.0, safe_area.position.x) * scale_x)
		margins.y = max(margins.y, max(0.0, safe_area.position.y) * scale_y)
		margins.z = max(margins.z, max(0.0, window_size.x - safe_area.position.x - safe_area.size.x) * scale_x)
		margins.w = max(margins.w, max(0.0, window_size.y - safe_area.position.y - safe_area.size.y) * scale_y)
	return clamp_safe_area_margins(margins, viewport_size)

func clamp_safe_area_margins(margins: Vector4, viewport_size: Vector2) -> Vector4:
	return Vector4(
		clamp(margins.x, 0.0, viewport_size.x * SAFE_CONTENT_MAX_SIDE_FRACTION),
		clamp(margins.y, 0.0, viewport_size.y * SAFE_CONTENT_MAX_TOP_FRACTION),
		clamp(margins.z, 0.0, viewport_size.x * SAFE_CONTENT_MAX_SIDE_FRACTION),
		clamp(margins.w, 0.0, viewport_size.y * SAFE_CONTENT_MAX_BOTTOM_FRACTION)
	)

func update_safe_area_layout() -> void:
	safe_area_margins = current_safe_area_margins()
	if root_layer != null and is_instance_valid(root_layer):
		apply_safe_area_offsets(root_layer)

func apply_safe_area_offsets(control: Control) -> void:
	if control == null:
		return
	control.set_anchors_preset(Control.PRESET_FULL_RECT)
	control.offset_left = safe_area_margins.x
	control.offset_top = safe_area_margins.y
	control.offset_right = -safe_area_margins.z
	control.offset_bottom = -safe_area_margins.w

func safe_content_pixel_size() -> Vector2:
	return safe_content_pixel_size_for_margins(effective_viewport_size(), safe_area_margins)

func safe_content_pixel_size_for_margins(viewport_size: Vector2, margins: Vector4) -> Vector2:
	return Vector2(max(1.0, viewport_size.x - margins.x - margins.z), max(1.0, viewport_size.y - margins.y - margins.w))

func draw_center(parent: Control) -> void:
	# 中心区域面板 - 增强视觉效果
	var center = make_panel(parent, CENTER_PANEL_RECT, Color(0.006, 0.014, 0.016, 0.96), 30, Color(0.48, 0.42, 0.24, 0.52), 4)
	# 内部装饰框
	make_panel(center, CENTER_INNER_RECT, Color(0.004, 0.036, 0.036, 0.98), 62, Color(0.28, 0.26, 0.18, 0.42), 0)
	draw_center_wind_compass(center)
	draw_center_phase_ribbon(center)

	# 状态文本
	var status = make_label(center, current_status_text(), 16, Color(0.92, 0.90, 0.82), true)
	apply_rect(status, CENTER_STATUS_RECT)

	# 余牌信息
	var wall_label = make_label(center, "余牌", 13, Color(0.72, 0.76, 0.70), false)
	apply_rect(wall_label, CENTER_WALL_LABEL_RECT)
	var wall_text = make_label(center, "%d" % get_wall_count(), 28, Color(0.66, 0.74, 0.70, 0.94), true)
	apply_rect(wall_text, CENTER_WALL_COUNT_RECT)
	draw_center_wall_meter(center, get_wall_count())

	# 上张牌
	var last = get_last_discard()
	if last != "":
		var last_label = make_label(center, "上张", 13, Color(0.72, 0.76, 0.70), false)
		apply_rect(last_label, CENTER_LAST_LABEL_RECT)
		var tile = make_tile_view(last, CENTER_LAST_TILE_SIZE, false, Callable(), true)
		center.add_child(tile)
		apply_rect(tile, CENTER_LAST_TILE_RECT)

	# 风位标签
	for i in range(4):
		var wind_color = Color(0.70, 0.70, 0.46, 0.94) if i == get_current_seat() else Color(0.50, 0.48, 0.32, 0.76)
		var wind = make_label(center, str(CENTER_WIND_LABELS[i]), 19, wind_color, true)
		apply_rect(wind, CENTER_WIND_RECTS[i])

	# 骰子点装饰
	for dot_rect in CENTER_DICE_DOT_RECTS:
		make_panel(center, dot_rect, Color(0.58, 0.54, 0.40, 0.64), 22, Color(0.74, 0.70, 0.56, 0.28), 0)

func draw_center_phase_ribbon(parent: Control) -> Control:
	var phase_key = center_phase_key()
	var accent = center_phase_color(phase_key)
	var ribbon = make_panel(parent, CENTER_PHASE_RIBBON_RECT, Color(accent.r * 0.18, accent.g * 0.18, accent.b * 0.18, 0.88), 999, Color(accent.r, accent.g, accent.b, 0.44), 0)
	ribbon.name = "CenterPhaseRibbon"
	ribbon.add_child(make_color_rect(rect_full(0.06, 0.46, 0.94, 0.54), Color(accent.r, accent.g, accent.b, 0.26)))
	var left_seal = make_panel(ribbon, rect_full(0.035, 0.18, 0.125, 0.82), Color(accent.r, accent.g, accent.b, 0.28), 999, Color(accent.r, accent.g, accent.b, 0.52), 0)
	left_seal.name = "CenterPhaseSeal"
	var pulse = make_panel(ribbon, rect_full(0.865, 0.28, 0.935, 0.72), Color(accent.r, accent.g, accent.b, 0.32), 999, Color(accent.r, accent.g, accent.b, 0.40), 0)
	pulse.name = "CenterPhasePulse"
	var label = make_label(ribbon, center_phase_label(phase_key), 11, Color(0.96, 0.94, 0.82), true)
	label.name = "CenterPhaseLabel"
	apply_rect(label, rect_full(0.14, 0.05, 0.85, 0.95))
	configure_clipped_label(label)
	if fx_enabled_effective() and DisplayServer.get_name().to_lower() != "headless":
		var tw := create_tween()
		tw.set_loops(3600)
		tw.tween_property(pulse, "modulate:a", 0.30, 0.58).from(0.95)
		tw.tween_property(pulse, "modulate:a", 0.95, 0.58).from(0.30)
	return ribbon

func center_phase_key() -> String:
	if mode == "offline":
		if offline_phase == "ended":
			return "ended"
		if offline_phase == "pending_claim":
			return "claim"
		if can_self_discard():
			return "discard"
		return "wait"
	if mode == "online_game":
		if str(online_game.get("phase", "")) == "ended":
			return "ended"
		if typeof(online_game.get("pending", null)) == TYPE_DICTIONARY or str(online_game.get("phase", "")) == "pendingClaim":
			return "claim"
		if can_self_discard():
			return "discard"
		return "wait"
	return "ready"

func center_phase_label(phase_key: String) -> String:
	match phase_key:
		"discard":
			return "我方出牌"
		"claim":
			return "响应窗口"
		"ended":
			return "结算"
		"wait":
			return "对手行牌"
	return "准备"

func center_phase_color(phase_key: String) -> Color:
	match phase_key:
		"discard":
			return Color(0.38, 0.72, 0.58, 1.0)
		"claim":
			return Color(0.88, 0.58, 0.28, 1.0)
		"ended":
			return Color(0.88, 0.72, 0.34, 1.0)
		"wait":
			return Color(0.42, 0.58, 0.72, 1.0)
	return Color(0.62, 0.64, 0.58, 1.0)

func draw_center_wall_meter(parent: Control, wall_count: int) -> void:
	var progress = clamp(float(wall_count) / 144.0, 0.0, 1.0)
	var meter_color = wall_meter_color(progress)
	var meter = Control.new()
	meter.name = "CenterWallMeter"
	meter.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(meter, rect_full(0.23, 0.30, 0.77, 0.74))
	parent.add_child(meter)
	var segments := [
		[rect_full(0.18, 0.00, 0.82, 0.035), 0.00],
		[rect_full(0.965, 0.17, 1.00, 0.83), 0.25],
		[rect_full(0.18, 0.965, 0.82, 1.00), 0.50],
		[rect_full(0.00, 0.17, 0.035, 0.83), 0.75],
	]
	for segment in segments:
		var lit = progress >= float(segment[1])
		var fill = Color(meter_color.r, meter_color.g, meter_color.b, 0.50 if lit else 0.10)
		var border = Color(meter_color.r, meter_color.g, meter_color.b, 0.38 if lit else 0.12)
		var bar = make_panel(meter, segment[0], fill, 18, border, 0)
		bar.name = "CenterWallMeterSegment"
	if progress <= 0.18:
		draw_center_low_wall_warning(meter, wall_count, meter_color)

func draw_center_low_wall_warning(parent: Control, wall_count: int, meter_color: Color) -> Control:
	var warning = make_panel(parent, rect_full(0.28, 0.34, 0.72, 0.66), Color(0.16, 0.040, 0.026, 0.30), 999, Color(meter_color.r, meter_color.g, meter_color.b, 0.42), 0)
	warning.name = "CenterWallLowWarning"
	var badge_text = "荒庄临近" if wall_count <= 18 else "余牌偏低"
	var badge = make_badge(warning, rect_full(0.10, 0.26, 0.90, 0.74), badge_text, 9, Color(0.20, 0.058, 0.038, 0.94), Color(0.96, 0.54, 0.32, 0.42), Color(0.98, 0.84, 0.64))
	badge.name = "CenterWallLowWarningBadge"
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for i in range(5):
		var left = 0.12 + float(i) * 0.19
		var spark = make_panel(parent, rect_full(left, 0.08, left + 0.038, 0.15), Color(0.96, 0.62, 0.28, 0.56), 999, Color(1.0, 0.84, 0.42, 0.24), 0)
		spark.name = "CenterWallLowSpark"
	if fx_enabled_effective() and DisplayServer.get_name().to_lower() != "headless":
		var tw := create_tween()
		tw.set_loops(3600)
		tw.tween_property(warning, "modulate:a", 0.35, 0.45).from(0.85)
		tw.tween_property(warning, "modulate:a", 0.85, 0.45).from(0.35)
	return warning

func wall_meter_color(progress: float) -> Color:
	if progress <= 0.18:
		return Color(0.88, 0.36, 0.22, 1.0)
	if progress <= 0.42:
		return Color(0.82, 0.62, 0.28, 1.0)
	return Color(0.42, 0.70, 0.58, 1.0)

func draw_dice_dot(parent: Control, x: float, y: float) -> void:
	make_panel(parent, rect_full(x - CENTER_DICE_DOT_RADIUS, y - CENTER_DICE_DOT_RADIUS, x + CENTER_DICE_DOT_RADIUS, y + CENTER_DICE_DOT_RADIUS), CENTER_DICE_DOT_FILL, 20, CENTER_DICE_DOT_BORDER, 0)

func draw_melds(parent: Control) -> void:
	for layout in MELD_LAYOUTS:
		var seat = int(layout[0])
		var meld_list = get_melds(seat)
		if meld_list.is_empty():
			continue
		var area = HBoxContainer.new()
		configure_passive_container(area)
		area.add_theme_constant_override("separation", 3)
		apply_rect(area, layout[1])
		parent.add_child(area)
		for meld in meld_list:
			if typeof(meld) == TYPE_ARRAY:
				area.add_child(make_meld_group_view(meld as Array, seat))

func make_meld_group_view(meld: Array, seat: int) -> Control:
	var group = Panel.new()
	var kind = meld_kind_label(meld)
	group.name = "MeldGroup_%s" % kind
	group.mouse_filter = Control.MOUSE_FILTER_IGNORE
	group.custom_minimum_size = Vector2(max(40.0, float(meld.size()) * 28.0 + 18.0), 54.0)
	var accent = SEAT_ACCENT_COLORS[seat] if seat >= 0 and seat < SEAT_ACCENT_COLORS.size() else GOLD_PRIMARY
	group.add_theme_stylebox_override("panel", style(Color(0.010, 0.022, 0.024, 0.88), 9, Color(accent.r, accent.g, accent.b, 0.34), 1, 2))
	group.add_child(make_color_rect(rect_full(0.0, 0.0, 0.035, 1.0), Color(accent.r, accent.g, accent.b, 0.52)))
	draw_meld_group_art(group, kind, accent, meld.size())
	if kind == "杠":
		var gang_rail = make_panel(group, rect_full(0.070, 0.075, 0.960, 0.145), Color(0.88, 0.70, 0.30, 0.34), 999, Color(1.0, 0.88, 0.48, 0.24), 0)
		gang_rail.name = "MeldGangGoldRail"
		var seal = make_seal_stamp(group, rect_full(0.040, 0.520, 0.180, 0.930), "杠", "round")
		seal.name = "MeldGangSeal"
	var label = make_label(group, kind, 10, Color(0.92, 0.84, 0.58), true)
	apply_rect(label, rect_full(0.05, 0.04, 0.28, 0.32))
	var tiles = HBoxContainer.new()
	configure_passive_container(tiles)
	tiles.alignment = BoxContainer.ALIGNMENT_BEGIN
	tiles.add_theme_constant_override("separation", 1)
	apply_rect(tiles, rect_full(0.145 if kind == "杠" else 0.06, 0.24, 0.96, 0.96))
	group.add_child(tiles)
	for i in range(meld.size()):
		var tile_view = make_tile_view(str(meld[i]), Vector2(26, 36), false, Callable())
		if kind == "杠" and i == meld.size() - 1:
			tile_view.name = "MeldGangRaisedTile"
			tile_view.position.y = -5.0
			tile_view.modulate = Color(1.10, 1.08, 1.0, 1.0)
		tiles.add_child(tile_view)
	return group

func draw_meld_group_art(parent: Control, kind: String, accent: Color, meld_size: int) -> Control:
	var art = Control.new()
	art.name = "MeldGroupArt"
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(art, rect_full(0.035, 0.040, 0.985, 0.965))
	parent.add_child(art)
	var rail = make_color_rect(rect_full(0.025, 0.760, 0.975, 0.820), Color(accent.r, accent.g, accent.b, 0.22))
	rail.name = "MeldKindRail"
	art.add_child(rail)
	var seal = make_panel(art, rect_full(0.760, 0.060, 0.930, 0.360), Color(accent.r, accent.g, accent.b, 0.20), 999, Color(0.96, 0.82, 0.46, 0.18), 0)
	seal.name = "MeldKindSeal"
	for i in range(max(2, min(4, meld_size))):
		var left = 0.110 + float(i) * 0.145
		var bead = make_panel(art, rect_full(left, 0.700, left + 0.040, 0.880), Color(accent.r, accent.g, accent.b, 0.38), 999, Color(1.0, 0.88, 0.48, 0.14), 0)
		bead.name = "MeldFlowBead_%d" % i
	match kind:
		"吃":
			var bridge = make_color_rect(rect_full(0.190, 0.395, 0.720, 0.455), Color(0.42, 0.70, 0.58, 0.28))
			bridge.name = "MeldChiBridge"
			art.add_child(bridge)
		"碰":
			for i in range(2):
				var center = 0.300 + float(i) * 0.180
				var pulse = make_panel(art, rect_full(center - 0.060, 0.270, center + 0.060, 0.590), Color(accent.r, accent.g, accent.b, 0.10), 999, Color(accent.r, accent.g, accent.b, 0.22), 0)
				pulse.name = "MeldPengPulse_%d" % i
		"杠":
			var crown = make_panel(art, rect_full(0.570, 0.085, 0.720, 0.300), Color(0.92, 0.72, 0.30, 0.22), 999, Color(1.0, 0.88, 0.48, 0.18), 0)
			crown.name = "MeldGangCrownGlow"
	return art

func meld_kind_label(meld: Array) -> String:
	if meld.size() >= 4:
		return "杠"
	if meld.size() == 3:
		var first = str(meld[0])
		if str(meld[1]) == first and str(meld[2]) == first:
			return "碰"
		return "吃"
	return "副"

func draw_seat(parent: Control, seat: int, rect: Rect2, side: String, seat_threat_reports: Dictionary = {}) -> void:
	var active = get_current_seat() == seat
	var p = get_player_info(seat)
	# 座位面板 - 增强的视觉区分
	var panel_fill = Color(0.016, 0.028, 0.032, 0.94) if active else Color(0.012, 0.020, 0.024, 0.90)
	var panel_border = Color(0.60, 0.52, 0.30, 0.56) if active else Color(0.32, 0.36, 0.34, 0.28)
	var panel = make_panel(parent, rect, panel_fill, 18, panel_border, 3)
	# 左侧座位颜色条
	panel.add_child(make_color_rect(rect_full(0.0, 0.0, 0.025, 1.0), SEAT_ACCENT_COLORS[seat].blend(Color(0.12, 0.14, 0.14, 1.0))))
	# 顶部高光
	panel.add_child(make_color_rect(rect_full(0.025, 0.015, 0.975, 0.05), Color(1.0, 1.0, 1.0, 0.03)))
	# 头部区域
	make_panel(panel, rect_full(0.0, 0.0, 1.0, 0.19), SEAT_HEADER_COLORS[seat].darkened(0.14), 18, Color(1.0, 0.90, 0.52, 0.06))
	# 底部区域
	make_panel(panel, rect_full(0.0, 0.78, 1.0, 1.0), Color(0.008, 0.014, 0.016, 0.24), 18, Color(0.14, 0.18, 0.18, 0.05))

	# 头像
	var avatar = make_avatar_view(seat, active)
	panel.add_child(avatar)
	apply_rect(avatar, rect_full(0.04, 0.14, 0.36, 0.92))

	var threat_report = seat_threat_report_from_map(seat, seat_threat_reports)
	var threat_badge_text = opponent_seat_threat_badge_text_from_report(threat_report)
	var display_name = str(p.get("name", "玩家"))
	if mode == "offline" and seat != 0:
		display_name += " · " + ai_profile_short_label(seat)
	var name = make_label(panel, display_name, 15, Color(0.94, 0.90, 0.80), true)
	var name_right = 0.55 if threat_badge_text != "" else 0.75 if active else 0.96
	apply_rect(name, rect_full(0.39, 0.10, name_right, 0.36))
	name.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	configure_clipped_label(name)

	if active:
		var turn_badge = make_badge(panel, rect_full(0.77, 0.11, 0.96, 0.32), "行牌", 11, Color(0.72, 0.60, 0.24, 0.92), Color(1.0, 0.86, 0.44, 0.42), Color(0.13, 0.12, 0.08))
		turn_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if threat_badge_text != "":
		var threat_badge = make_badge(panel, rect_full(0.57, 0.11, 0.75, 0.32), threat_badge_text, 12, opponent_seat_threat_color_from_report(threat_report), Color(1.0, 0.91, 0.48, 0.56), Color(0.10, 0.11, 0.10))
		threat_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var package_text = package_preview(seat)
	var threat_line = opponent_seat_threat_line_from_report(threat_report)
	# 统计信息 - 增强的视觉效果
	draw_seat_stat_pill(panel, SEAT_STAT_RECTS[0], "手", str(int(p.get("hand_count", 0))), SEAT_ACCENT_COLORS[seat])
	draw_seat_stat_pill(panel, SEAT_STAT_RECTS[1], "花", str(int(p.get("flowers", 0))), Color(0.56, 0.44, 0.28))
	draw_seat_stat_pill(panel, SEAT_STAT_RECTS[2], "分", compact_score_text(int(p.get("score", 0))), Color(0.32, 0.44, 0.46))
	var has_score_ribbon = draw_seat_score_momentum_ribbon(panel, seat)

	if package_text != "" or threat_line != "":
		var info_text = package_text if package_text != "" else threat_line
		var info = make_label(panel, info_text, 11, Color(0.70, 0.74, 0.68), false)
		apply_rect(info, rect_full(0.39, 0.69 if has_score_ribbon else 0.58, 0.96, 0.77 if has_score_ribbon else 0.72))
		info.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		configure_clipped_label(info)

	var river_text = discard_preview(seat)
	var flowers = flower_preview(seat)
	var has_flower_tiles = draw_seat_flower_tiles(panel, seat)
	if flowers != "" and not has_flower_tiles:
		river_text = "花 " + flowers + ("\n" + river_text if river_text != "" else "")
	var river = make_label(panel, river_text, 12, UI_TEXT_MUTED, false)
	apply_rect(river, rect_full(0.39, 0.78 if has_flower_tiles else 0.63, 0.96, 0.92))
	river.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	configure_clipped_label(river)
	if seat == dealer_seat:
		var dealer = make_badge(panel, rect_full(0.27, 0.06, 0.38, 0.28), "庄", 16, Color(0.58, 0.12, 0.08, 0.90), Color(1.0, 0.79, 0.34, 0.76), Color(0.96, 0.90, 0.72))
		dealer.mouse_filter = Control.MOUSE_FILTER_IGNORE

func draw_seat_score_momentum_ribbon(parent: Control, seat: int) -> bool:
	var report = score_context_report(seat)
	if report.is_empty():
		return false
	var accent = score_momentum_color(report)
	var ribbon = make_panel(parent, rect_full(0.39, 0.600, 0.96, 0.705), Color(accent.r * 0.16, accent.g * 0.16, accent.b * 0.16, 0.84), 999, Color(accent.r, accent.g, accent.b, 0.36), 0)
	ribbon.name = "SeatScoreMomentumRibbon"
	ribbon.add_child(make_color_rect(rect_full(0.08, 0.46, 0.92, 0.54), Color(accent.r, accent.g, accent.b, 0.22)))
	var seal = make_panel(ribbon, rect_full(0.025, 0.18, 0.118, 0.82), Color(accent.r, accent.g, accent.b, 0.28), 999, Color(accent.r, accent.g, accent.b, 0.50), 0)
	seal.name = "SeatScoreMomentumSeal"
	var pulse = make_panel(ribbon, rect_full(0.885, 0.28, 0.948, 0.72), Color(accent.r, accent.g, accent.b, 0.32), 999, Color(accent.r, accent.g, accent.b, 0.42), 0)
	pulse.name = "SeatScoreMomentumPulse"
	var label = make_label(ribbon, score_momentum_label(report), 10, Color(0.96, 0.94, 0.84), true)
	label.name = "SeatScoreMomentumLabel"
	apply_rect(label, rect_full(0.135, 0.06, 0.875, 0.94))
	configure_clipped_label(label)
	if fx_enabled_effective() and DisplayServer.get_name().to_lower() != "headless":
		var tw := create_tween()
		tw.set_loops(3600)
		tw.tween_property(pulse, "modulate:a", 0.30, 0.72).from(0.90)
		tw.tween_property(pulse, "modulate:a", 0.90, 0.72).from(0.30)
	return true

func score_momentum_label(report: Dictionary) -> String:
	var rank = int(report.get("rank", 0))
	var strategy = str(report.get("strategy", "均衡"))
	if rank <= 0:
		return "分势"
	return "第%d %s" % [rank, strategy]

func score_momentum_color(report: Dictionary) -> Color:
	match str(report.get("strategy", "均衡")):
		"守成":
			return Color(0.38, 0.64, 0.52, 1.0)
		"追分":
			return Color(0.86, 0.50, 0.26, 1.0)
	return Color(0.62, 0.58, 0.34, 1.0)

func draw_seat_stat_pill(parent: Control, rect: Rect2, label_text: String, value_text: String, accent: Color) -> void:
	var pill = make_panel(parent, rect, Color(0.010, 0.018, 0.022, 0.92), 10, accent.blend(Color(0.18, 0.19, 0.17, 1.0)), 0)
	# 左侧强调色条
	pill.add_child(make_color_rect(rect_full(0.0, 0.0, 0.06, 1.0), accent.darkened(0.06)))
	var label = make_label(pill, label_text, 9, Color(0.72, 0.74, 0.66, 0.94), false)
	apply_rect(label, rect_full(0.10, 0.12, 0.42, 0.88))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	configure_clipped_label(label)
	var value = make_label(pill, value_text, 12, Color(0.96, 0.94, 0.88), true)
	apply_rect(value, rect_full(0.34, 0.06, 0.94, 0.94))
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	configure_clipped_label(value)

func draw_seat_flower_tiles(parent: Control, seat: int) -> bool:
	if mode != "offline" or seat < 0 or seat >= players.size():
		return false
	var flowers: Array = players[seat].get("flower_tiles", [])
	if flowers.is_empty():
		return false
	var art = make_panel(parent, rect_full(0.390, 0.585, 0.960, 0.765), Color(0.030, 0.030, 0.020, 0.52), 10, Color(0.76, 0.58, 0.28, 0.20), 0)
	art.name = "SeatFlowerTileArt"
	var rail = make_panel(art, rect_full(0.030, 0.720, 0.970, 0.850), Color(0.78, 0.58, 0.28, 0.18), 999, Color(0.96, 0.78, 0.38, 0.14), 0)
	rail.name = "SeatFlowerTileRail"
	var seal = make_panel(art, rect_full(0.020, 0.160, 0.130, 0.660), Color(0.68, 0.42, 0.18, 0.26), 999, Color(0.96, 0.72, 0.36, 0.24), 0)
	seal.name = "SeatFlowerTileSeal"
	var seal_label = make_label(seal, "花", 10, Color(0.96, 0.86, 0.58), true)
	apply_rect(seal_label, rect_full(0.0, 0.0, 1.0, 1.0))
	var glow = make_panel(art, rect_full(0.875, 0.180, 0.945, 0.620), Color(0.92, 0.70, 0.34, 0.18), 999, Color(1.0, 0.84, 0.46, 0.16), 0)
	glow.name = "SeatFlowerTileGlow"
	var strip = HBoxContainer.new()
	strip.name = "SeatFlowerTileStrip"
	configure_passive_container(strip)
	strip.alignment = BoxContainer.ALIGNMENT_BEGIN
	strip.add_theme_constant_override("separation", 2)
	apply_rect(strip, rect_full(0.155, 0.105, 0.835, 0.790))
	art.add_child(strip)
	var visible_count = min(4, flowers.size())
	for i in range(visible_count):
		var tile_view = make_tile_view(str(flowers[i]), Vector2(22, 31), false, Callable())
		tile_view.name = "SeatFlowerTile_%d" % i
		strip.add_child(tile_view)
	if flowers.size() > visible_count:
		var more = make_label(strip, "+%d" % (flowers.size() - visible_count), 11, Color(0.96, 0.86, 0.58), true)
		more.name = "SeatFlowerMoreBadge"
		more.custom_minimum_size = Vector2(24, 31)
	if fx_enabled_effective() and DisplayServer.get_name().to_lower() != "headless":
		var tw := create_tween()
		tw.set_loops(10)
		tw.tween_property(glow, "modulate:a", 0.35, 0.80).from(0.88)
		tw.tween_property(glow, "modulate:a", 0.88, 0.80).from(0.35)
	return true

func draw_table_log(parent: Control) -> void:
	var panel = make_panel(parent, rect_full(0.018, 0.585, 0.205, 0.755), Color(0.012, 0.028, 0.032, 0.90), 14, Color(0.34, 0.44, 0.40, 0.26))
	make_panel(panel, rect_full(0.0, 0.0, 1.0, 0.24), Color(0.040, 0.052, 0.050, 0.68), 14, Color(1.0, 1.0, 1.0, 0.025))
	var title = make_label(panel, "行动流", 12, Color(0.84, 0.78, 0.60), true)
	apply_rect(title, rect_full(0.06, 0.02, 0.45, 0.24))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	var count = make_label(panel, "%d条" % table_logs.size(), 10, Color(0.54, 0.66, 0.62), false)
	apply_rect(count, rect_full(0.52, 0.03, 0.94, 0.24))
	count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	var recent = table_log_tail(3)
	if recent.is_empty():
		var empty = make_label(panel, "等待开局", 11, Color(0.62, 0.72, 0.68), false)
		apply_rect(empty, rect_full(0.06, 0.36, 0.94, 0.72))
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		configure_clipped_label(empty)
		return
	draw_table_log_timeline(panel, recent.size())
	for i in range(recent.size()):
		draw_table_log_row(panel, i, str(recent[i]))

func draw_table_log_timeline(parent: Control, row_count: int) -> Control:
	var rail_bottom = 0.340 + float(max(0, row_count - 1)) * 0.215
	var rail = make_panel(parent, rect_full(0.092, 0.342, 0.112, rail_bottom + 0.085), Color(0.78, 0.66, 0.34, 0.16), 999, Color(0.88, 0.76, 0.44, 0.16), 0)
	rail.name = "TableLogTimelineRail"
	return rail

func table_log_tail(limit: int) -> Array[String]:
	var result: Array[String] = []
	var start = max(0, table_logs.size() - limit)
	for i in range(start, table_logs.size()):
		result.append(str(table_logs[i]))
	return result

func draw_table_log_row(parent: Control, index: int, text: String) -> void:
	var top = 0.30 + float(index) * 0.215
	var row = make_panel(parent, rect_full(0.045, top, 0.955, top + 0.175), Color(0.026, 0.044, 0.044, 0.76), 8, Color(1.0, 1.0, 1.0, 0.030), 0)
	var tag = table_log_tag(text)
	var tag_color = table_log_tag_color(tag)
	var node = make_panel(row, rect_full(0.006, 0.34, 0.034, 0.66), Color(tag_color.r, tag_color.g, tag_color.b, 0.30), 999, Color(tag_color.r, tag_color.g, tag_color.b, 0.56), 0)
	node.name = "TableLogTimelineNode"
	var connector = make_color_rect(rect_full(0.034, 0.49, 0.058, 0.54), Color(tag_color.r, tag_color.g, tag_color.b, 0.22))
	connector.name = "TableLogTimelineConnector"
	row.add_child(connector)
	if index == 2:
		var glow = make_panel(row, rect_full(0.000, 0.26, 0.044, 0.74), Color(tag_color.r, tag_color.g, tag_color.b, 0.12), 999, Color(tag_color.r, tag_color.g, tag_color.b, 0.32), 0)
		glow.name = "TableLogLatestGlow"
	var badge = make_panel(row, rect_full(0.035, 0.22, 0.205, 0.78), tag_color.darkened(0.16), 6, tag_color, 0)
	var badge_text = make_label(badge, tag, 10, Color(0.98, 0.96, 0.86), true)
	apply_rect(badge_text, rect_full(0.0, 0.0, 1.0, 1.0))
	var body = make_label(row, table_log_display_text(text), 11, Color(0.76, 0.84, 0.78), false)
	apply_rect(body, rect_full(0.24, 0.10, 0.96, 0.90))
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	configure_clipped_label(body)

func table_log_tag(text: String) -> String:
	if text.find("胡") >= 0 or text.find("自摸") >= 0:
		return "胡"
	if text.find("杠") >= 0:
		return "杠"
	if text.find("碰") >= 0:
		return "碰"
	if text.find("吃") >= 0:
		return "吃"
	if text.find("可响应") >= 0:
		return "应"
	if text.find("打出") >= 0:
		return "打"
	if text.find("摸到") >= 0 or text.find("补花") >= 0:
		return "摸"
	if text.find("开始") >= 0 or text.find("坐庄") >= 0 or text.find("连庄") >= 0:
		return "局"
	return "记"

func table_log_tag_color(tag: String) -> Color:
	match tag:
		"胡":
			return Color(0.94, 0.42, 0.30, 0.96)
		"杠":
			return Color(0.62, 0.54, 0.88, 0.96)
		"碰", "吃":
			return Color(0.38, 0.66, 0.82, 0.96)
		"应":
			return Color(0.88, 0.62, 0.22, 0.96)
		"打":
			return Color(0.22, 0.58, 0.48, 0.96)
		"摸":
			return Color(0.42, 0.62, 0.52, 0.96)
		"局":
			return Color(0.74, 0.62, 0.34, 0.96)
	return Color(0.44, 0.54, 0.54, 0.92)

func table_log_display_text(text: String) -> String:
	return text.replace("。", "")

func draw_advisor_panel(parent: Control) -> void:
	if mode != "offline" or offline_phase == "ended" or not player_ai_assist_enabled():
		return
	var panel = make_panel(parent, rect_full(0.155, 0.625, 0.545, 0.755), Color(0.014, 0.034, 0.040, 0.90), 14, Color(0.42, 0.36, 0.22, 0.34))
	make_panel(panel, rect_full(0.0, 0.0, 1.0, 0.14), Color(0.044, 0.056, 0.058, 0.72), 14, Color(1.0, 1.0, 1.0, 0.025))
	var title = make_label(panel, "牌势", 13, Color(0.86, 0.78, 0.56), true)
	apply_rect(title, rect_full(0.03, 0.04, 0.16, 0.22))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	var context = make_label(panel, advisor_context_line(), 11, Color(0.62, 0.72, 0.68), false)
	apply_rect(context, rect_full(0.17, 0.04, 0.97, 0.22))
	context.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	configure_clipped_label(context)
	if offline_phase == "pending_claim":
		draw_advisor_info_card(panel, rect_full(0.03, 0.28, 0.36, 0.88), "响应", "%s · %s" % [
			tile_label(str(offline_pending_claim.get("tile", ""))),
			claim_options_text(offline_pending_claim),
		], human_claim_hint_text(), Color(0.86, 0.78, 0.56))
		draw_advisor_info_card(panel, rect_full(0.38, 0.28, 0.68, 0.88), "牌局", advisor_turn_line(), current_status_text(), Color(0.62, 0.78, 0.82))
		draw_advisor_info_card(panel, rect_full(0.70, 0.28, 0.97, 0.88), "防守", advisor_defense_text(0), opponent_threat_summary(0), Color(0.84, 0.62, 0.54))
		return
	if can_self_discard():
		var reports = current_human_advice if not current_human_advice.is_empty() else get_ai_discard_reports(0)
		if reports.is_empty():
			draw_advisor_info_card(panel, rect_full(0.03, 0.28, 0.36, 0.88), "推荐", "整理手牌", "等待可执行出牌", Color(0.86, 0.78, 0.56))
			draw_advisor_info_card(panel, rect_full(0.38, 0.28, 0.68, 0.88), "收益", score_strategy_text(0), advisor_turn_line(), Color(0.62, 0.78, 0.82))
			draw_advisor_info_card(panel, rect_full(0.70, 0.28, 0.97, 0.88), "防守", advisor_defense_text(0), opponent_threat_summary(0), Color(0.84, 0.62, 0.54))
			return
		var best: Dictionary = reports[0]
		draw_advisor_info_card(panel, rect_full(0.03, 0.28, 0.36, 0.88), "推荐", advisor_primary_text(best), advisor_options_text(reports, 3), Color(0.86, 0.78, 0.56))
		draw_advisor_info_card(panel, rect_full(0.38, 0.28, 0.68, 0.88), "收益", advisor_value_text(best), advisor_shape_text(best), Color(0.62, 0.78, 0.82))
		draw_advisor_info_card(panel, rect_full(0.70, 0.28, 0.97, 0.88), "防守", advisor_defense_text(0, best), opponent_threat_summary(0), Color(0.84, 0.62, 0.54))
		return
	draw_advisor_info_card(panel, rect_full(0.03, 0.28, 0.36, 0.88), "牌局", advisor_turn_line(), current_status_text(), Color(0.86, 0.78, 0.56))
	draw_advisor_info_card(panel, rect_full(0.38, 0.28, 0.68, 0.88), "进程", score_strategy_text(0), "余牌%d" % get_wall_count(), Color(0.62, 0.78, 0.82))
	draw_advisor_info_card(panel, rect_full(0.70, 0.28, 0.97, 0.88), "防守", advisor_defense_text(0), opponent_threat_summary(0), Color(0.84, 0.62, 0.54))

func draw_advisor_info_card(parent: Control, rect: Rect2, heading: String, main_text: String, sub_text: String, accent: Color) -> void:
	var card = make_panel(parent, rect, Color(0.028, 0.048, 0.050, 0.78), 10, accent.darkened(0.28), 0)
	card.name = "AdvisorInfoCard_%s" % heading
	draw_advisor_signal_strip(card, heading, accent)
	var label = make_label(card, heading, 10, accent, true)
	apply_rect(label, rect_full(0.13, 0.07, 0.93, 0.26))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	configure_clipped_label(label)
	var primary = make_label(card, main_text if main_text != "" else "--", 12, Color(0.86, 0.91, 0.84), true)
	apply_rect(primary, rect_full(0.13, 0.30, 0.93, 0.56))
	primary.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	configure_clipped_label(primary)
	var secondary = make_label(card, sub_text if sub_text != "" else "暂无", 10, Color(0.66, 0.74, 0.70), false)
	apply_rect(secondary, rect_full(0.13, 0.58, 0.93, 0.92))
	secondary.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	secondary.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	secondary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	secondary.clip_text = true

func draw_advisor_signal_strip(parent: Control, heading: String, accent: Color) -> Control:
	var strip = make_panel(parent, rect_full(0.035, 0.13, 0.080, 0.88), accent.blend(Color(0.08, 0.10, 0.09, 1.0)), 8, accent.lightened(0.12), 0)
	strip.name = "AdvisorSignalStrip_%s" % heading
	var pulse = make_panel(strip, rect_full(0.18, 0.07, 0.82, 0.22), accent.lightened(0.20), 8, Color(1.0, 0.96, 0.78, 0.22), 0)
	pulse.name = "AdvisorSignalPulse_%s" % heading
	make_panel(strip, rect_full(0.28, 0.36, 0.72, 0.64), accent.darkened(0.10), 8, Color(1.0, 1.0, 1.0, 0.04), 0)
	var icon_text = advisor_signal_icon_text(heading)
	var icon = make_label(strip, icon_text, 8, Color(0.09, 0.12, 0.10), true)
	icon.name = "AdvisorSignalIcon_%s" % heading
	apply_rect(icon, rect_full(0.04, 0.72, 0.96, 0.96))
	icon.clip_text = true
	if fx_enabled_effective():
		var tw := create_tween()
		tw.set_loops(12)
		tw.tween_property(pulse, "modulate:a", 0.38, 0.72).from(0.92)
		tw.tween_property(pulse, "modulate:a", 0.92, 0.72)
	return strip

func advisor_signal_icon_text(heading: String) -> String:
	match heading:
		"推荐", "响应":
			return "先"
		"收益", "进程":
			return "势"
		"防守":
			return "守"
		"牌局":
			return "局"
	return heading.substr(0, 1) if heading != "" else "牌"

func advisor_context_line() -> String:
	if offline_phase == "pending_claim":
		return "响应窗口 · %s" % advisor_turn_line()
	if can_self_discard():
		return "我方决策 · %s" % advisor_turn_line()
	return "观测中 · %s" % advisor_turn_line()

func advisor_turn_line() -> String:
	if current_seat >= 0 and current_seat < players.size():
		return "%s行牌 · 余牌%d" % [players[current_seat]["name"], get_wall_count()]
	return "余牌%d" % get_wall_count()

func advisor_primary_text(report: Dictionary) -> String:
	return "打%s · %s/%d" % [
		tile_label(str(report.get("tile", ""))),
		shanten_label(int(report.get("shanten", 8))),
		int(report.get("ukeire", 0)),
	]

func advisor_options_text(reports: Array, limit: int = 3) -> String:
	var options: Array[String] = []
	for i in range(min(limit, reports.size())):
		var report: Dictionary = reports[i]
		var reason = str(report.get("reason_label", ""))
		options.append("%s %s/%d%s" % [
			tile_label(str(report.get("tile", ""))),
			shanten_label(int(report.get("shanten", 8))),
			int(report.get("ukeire", 0)),
			" " + reason if reason != "" else "",
		])
	return "备选 " + "  ".join(options) if not options.is_empty() else "暂无备选"

func advisor_value_text(report: Dictionary) -> String:
	var parts: Array[String] = []
	var plan_hint = hand_plan_text(report)
	if plan_hint != "":
		parts.append(plan_hint)
	var tile_hint = effective_tile_text(report, 5)
	if tile_hint != "":
		parts.append(tile_hint)
	var value_hint = wait_value_text(report)
	if value_hint != "":
		parts.append(value_hint)
	return " · ".join(parts) if not parts.is_empty() else "保持牌型"

func advisor_shape_text(report: Dictionary) -> String:
	var parts: Array[String] = []
	var reason_hint = str(report.get("reason_label", ""))
	if reason_hint != "":
		parts.append(reason_hint)
	var shape_hint = str(report.get("shape_label", ""))
	if shape_hint != "":
		parts.append(shape_hint)
	var quality_hint = wait_quality_text(report)
	if quality_hint != "":
		parts.append(quality_hint)
	var score_text = score_strategy_text(0)
	if score_text != "":
		parts.append(score_text)
	return " · ".join(parts)

func advisor_defense_text(seat: int, best: Dictionary = {}) -> String:
	var parts: Array[String] = []
	if not best.is_empty():
		parts.append(discard_safety_text(best))
		var safest_hint = safest_discard_hint_text(best, safest_discard_report())
		if safest_hint != "":
			parts.append(safest_hint)
	var threat = opponent_threat_summary(seat)
	if threat != "":
		parts.append(threat)
	if get_last_discard() != "":
		parts.append("上张 " + tile_label(get_last_discard()))
	return " · ".join(parts) if not parts.is_empty() else "无明显压力"

func advisor_panel_text() -> String:
	if offline_phase == "pending_claim":
		return "响应 %s · %s\n%s" % [
			tile_label(str(offline_pending_claim.get("tile", ""))),
			claim_options_text(offline_pending_claim),
			human_claim_hint_text(),
		]
	if can_self_discard():
		return ai_advice_summary(0, 3)
	if current_seat >= 0 and current_seat < players.size():
		return "%s行牌 · 余牌%d\n上张 %s" % [
			players[current_seat]["name"],
			get_wall_count(),
			tile_label(get_last_discard()) if get_last_discard() != "" else "--",
		]
	return current_status_text()

func draw_round_summary(parent: Control) -> void:
	if mode != "offline" or offline_phase != "ended":
		return
	var panel = make_panel(parent, ROUND_SUMMARY_PANEL_RECT, Color(0.010, 0.026, 0.032, 0.97), 22, Color(0.54, 0.44, 0.26, 0.54), 5)
	# 标题栏
	make_panel(panel, ROUND_SUMMARY_HEADER_RECT, Color(0.042, 0.054, 0.052, 0.82), 22, Color(1.0, 1.0, 1.0, 0.032))
	# 左侧金色装饰
	panel.add_child(make_color_rect(rect_full(0.006, 0.04, 0.012, 0.96), Color(0.90, 0.76, 0.36, 0.68)))
	draw_round_summary_ambience(panel)

	# 标题 - 始终显示
	var title = make_label(panel, "本局结算" if not is_offline_match_finished() else "全场结算", 26, Color(0.94, 0.86, 0.48), true)
	apply_rect(title, ROUND_SUMMARY_TITLE_RECT)

	# 胜利丝带和星光 - 始终显示
	draw_summary_victory_ribbon(panel)
	draw_animation_preview(panel, rect_full(0.705, 0.035, 0.785, 0.145), "victory_sparkle")

	# 结算面板弹出动画
	if fx_enabled_effective():
		panel.modulate = Color(1, 1, 1, 0)
		panel.scale = Vector2(0.88, 0.88)
		var tw := create_tween()
		tw.set_parallel(true)
		tw.tween_property(panel, "modulate:a", 1.0, 0.22).from(0.0)
		tw.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.22).from(Vector2(0.88, 0.88)).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	# 胡牌详情展示（如果有）
	if not last_win_score.is_empty() and int(last_win_score.get("fan", 0)) > 0:
		draw_win_detail_section(panel, last_win_score)

	var lines: Array[String] = [round_summary]
	var package_lines = active_package_lines()
	if not package_lines.is_empty():
		lines.append("")
		lines.append_array(package_lines)
	var body = make_label(panel, "\n".join(lines), 14, Color(0.76, 0.86, 0.80), false)
	apply_rect(body, ROUND_SUMMARY_TEXT_RECT)
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	body.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	configure_clipped_label(body)
	var rank = 1
	for seat in ranked_seats_by_score():
		draw_round_summary_rank_row(panel, seat, rank)
		rank += 1
	if not is_offline_match_finished():
		var next_dealer = dealer_seat if offline_dealer_repeat else (dealer_seat + 1) % 4
		var next = make_badge(panel, ROUND_SUMMARY_NEXT_DEALER_RECT, "下一局庄家  %s" % players[next_dealer]["name"], 13, Color(0.030, 0.046, 0.048, 0.90), Color(0.46, 0.40, 0.24, 0.36), Color(0.82, 0.86, 0.76))
		next.mouse_filter = Control.MOUSE_FILTER_IGNORE

func draw_round_summary_ambience(parent: Control) -> Control:
	var art = Control.new()
	art.name = "RoundSummaryAmbience"
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(art, rect_full(0.0, 0.0, 1.0, 1.0))
	parent.add_child(art)
	var wash = make_color_rect(rect_full(0.018, 0.170, 0.982, 0.960), Color(0.82, 0.66, 0.30, 0.032))
	wash.name = "RoundSummaryAmbienceWash"
	art.add_child(wash)
	var orbit = make_panel(art, rect_full(0.070, 0.720, 0.930, 0.755), Color(0.82, 0.70, 0.36, 0.13), 999, Color(0.96, 0.82, 0.46, 0.10), 0)
	orbit.name = "RoundSummaryScoreOrbit"
	var ranked = ranked_seats_by_score()
	var spark_index = 0
	for i in range(ranked.size()):
		var seat = int(ranked[i])
		var center = 0.095 + float(i) * 0.270
		var delta = round_summary_score_delta(seat)
		var accent = round_summary_delta_color(delta, i + 1)
		var node = make_panel(art, rect_full(center - 0.020, 0.688, center + 0.020, 0.788), Color(accent.r, accent.g, accent.b, 0.42), 999, Color(accent.r, accent.g, accent.b, 0.34), 0)
		node.name = "RoundSummaryScoreNode_%d" % seat
		if delta != 0:
			var spark = make_panel(art, rect_full(center - 0.034, 0.662, center + 0.034, 0.814), Color(accent.r, accent.g, accent.b, 0.10), 999, Color(accent.r, accent.g, accent.b, 0.20), 0)
			spark.name = "RoundSummaryDeltaSpark_%d" % spark_index
			spark_index += 1
	if offline_last_winner >= 0 and offline_last_winner < players.size():
		var winner_accent = SEAT_ACCENT_COLORS[offline_last_winner]
		var beacon = make_panel(art, rect_full(0.790, 0.035, 0.965, 0.160), Color(winner_accent.r, winner_accent.g, winner_accent.b, 0.22), 999, Color(1.0, 0.86, 0.46, 0.26), 0)
		beacon.name = "RoundSummaryWinnerBeacon"
		var seal = make_seal_stamp(beacon, rect_full(0.070, 0.180, 0.300, 0.820), "胜", "round")
		seal.name = "RoundSummaryWinnerBeaconSeal"
		var ray = make_color_rect(rect_full(0.320, 0.470, 0.900, 0.530), Color(0.96, 0.82, 0.42, 0.24))
		ray.name = "RoundSummaryWinnerBeaconRay"
		beacon.add_child(ray)
	if not is_offline_match_finished():
		var gate = make_panel(art, rect_full(0.700, 0.880, 0.940, 0.950), Color(0.020, 0.040, 0.040, 0.56), 999, Color(0.74, 0.66, 0.36, 0.22), 0)
		gate.name = "RoundSummaryNextHandGate"
		for i in range(3):
			var left = 0.060 + float(i) * 0.300
			var pip = make_panel(gate, rect_full(left, 0.310, left + 0.070, 0.690), Color(0.90, 0.76, 0.34, 0.46), 999, Color(1.0, 0.88, 0.48, 0.18), 0)
			pip.name = "RoundSummaryNextHandPip_%d" % i
	if fx_enabled_effective() and DisplayServer.get_name().to_lower() != "headless":
		var tw := create_tween()
		tw.tween_property(orbit, "modulate:a", 0.52, 0.72).from(1.0).set_ease(Tween.EASE_OUT)
		tw.tween_property(orbit, "modulate:a", 1.0, 0.72).from(0.52).set_ease(Tween.EASE_IN)
	return art

func draw_win_detail_section(parent: Control, score_data: Dictionary) -> void:
	"""绘制胡牌详情区域 - 增强版：番种徽章化展示"""
	var winner = int(score_data.get("winner", -1))
	if winner < 0 or winner >= players.size():
		return

	var fan = int(score_data.get("fan", 0))
	var points = int(score_data.get("points", 0))
	var reasons: Array = score_data.get("reasons", [])
	var win_tile = str(score_data.get("win_tile", ""))
	var self_draw = bool(score_data.get("self_draw", false))

	# 详情面板 - 增大高度以容纳徽章
	var detail_rect = Rect2(Vector2(0.04, 0.18), Vector2(0.96, 0.50))
	var detail_panel = make_panel(parent, detail_rect, Color(0.012, 0.024, 0.030, 0.94), 14, Color(0.38, 0.42, 0.40, 0.28), 0)
	detail_panel.add_child(make_color_rect(rect_full(0.0, 0.0, 0.015, 1.0), Color(0.84, 0.72, 0.38, 0.48)))

	# 胡牌者信息行
	var winner_text = "%s %s" % [players[winner]["name"], "自摸" if self_draw else "胡"]
	if win_tile != "":
		winner_text += " %s" % tile_label(win_tile)
	var winner_label = make_label(detail_panel, winner_text, 18, Color(0.94, 0.88, 0.58), true)
	apply_rect(winner_label, rect_full(0.04, 0.06, 0.60, 0.22))
	winner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

	# 番数和分数 - 更醒目
	var score_text = "%d番  %d分" % [fan, points]
	var score_label = make_label(detail_panel, score_text, 22, Color(0.96, 0.88, 0.52), true)
	apply_rect(score_label, rect_full(0.62, 0.06, 0.96, 0.22))
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	draw_win_detail_showcase(detail_panel, win_tile, self_draw, fan, points)

	# 番种徽章列表 - 每个番种独立展示（依次弹出动画）
	if reasons.size() > 0:
		draw_win_detail_yaku_track(detail_panel, reasons)
		var badge_container = HBoxContainer.new()
		badge_container.alignment = BoxContainer.ALIGNMENT_BEGIN
		badge_container.add_theme_constant_override("separation", 6)
		apply_rect(badge_container, rect_full(0.04, 0.28, 0.70, 0.56))
		detail_panel.add_child(badge_container)

		for i in range(reasons.size()):
			var reason_str = str(reasons[i])
			# 根据番种类型选择不同颜色
			var badge_color = fan_badge_color(reason_str)
			var badge_border = badge_color.lightened(0.16)
			var badge = make_badge(badge_container, Rect2(Vector2.ZERO, Vector2.ZERO), reason_str, 13, badge_color.darkened(0.18), badge_border, Color(0.96, 0.94, 0.88))
			badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
			# 徽章依次弹出动画
			if fx_enabled_effective():
				badge.modulate = Color(1, 1, 1, 0)
				badge.scale = Vector2(0.6, 0.6)
				var delay = 0.16 + float(i) * 0.06
				var tw := create_tween()
				tw.set_parallel(true)
				tw.tween_property(badge, "modulate:a", 1.0, 0.18).from(0.0).set_delay(delay)
				tw.tween_property(badge, "scale", Vector2(1.0, 1.0), 0.18).from(Vector2(0.6, 0.6)).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_delay(delay)

	# 特殊标记
	var limit_name = str(score_data.get("limit_name", ""))
	if limit_name != "":
		var limit_badge = make_badge(detail_panel, rect_full(0.70, 0.70, 0.96, 0.92), limit_name, 12, Color(0.72, 0.32, 0.28, 0.92), Color(0.96, 0.66, 0.42, 0.48), Color(0.96, 0.94, 0.88))
		limit_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE

func draw_win_detail_yaku_track(parent: Control, reasons: Array) -> Control:
	var track = Control.new()
	track.name = "WinDetailYakuTrack"
	track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(track, rect_full(0.04, 0.595, 0.70, 0.700))
	parent.add_child(track)
	var count = min(5, max(1, reasons.size()))
	var rail = make_panel(track, rect_full(0.04, 0.44, 0.96, 0.56), Color(0.82, 0.70, 0.36, 0.18), 999, Color(0.92, 0.80, 0.46, 0.18), 0)
	rail.name = "WinDetailYakuRail"
	for i in range(count):
		var reason = str(reasons[i])
		var accent = fan_badge_color(reason)
		var center = 0.10 + float(i) * (0.80 / float(max(1, count - 1))) if count > 1 else 0.50
		var node = make_panel(track, rect_full(center - 0.030, 0.24, center + 0.030, 0.76), Color(accent.r, accent.g, accent.b, 0.30), 999, Color(accent.r, accent.g, accent.b, 0.56), 0)
		node.name = "WinDetailYakuNode_%d" % i
		if i == 0:
			var glow = make_panel(track, rect_full(center - 0.046, 0.12, center + 0.046, 0.88), Color(accent.r, accent.g, accent.b, 0.12), 999, Color(accent.r, accent.g, accent.b, 0.26), 0)
			glow.name = "WinDetailYakuLeadGlow"
	return track

func draw_win_detail_showcase(parent: Control, win_tile: String, self_draw: bool, fan: int, points: int) -> Control:
	var showcase = Control.new()
	showcase.name = "WinDetailShowcase"
	showcase.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(showcase, rect_full(0.72, 0.27, 0.96, 0.68))
	parent.add_child(showcase)
	make_cloud_decoration(showcase, rect_full(-0.08, 0.06, 0.56, 0.82), "gold", false)
	make_panel(showcase, rect_full(0.16, 0.08, 0.90, 0.92), Color(0.018, 0.036, 0.038, 0.72), 18, Color(0.88, 0.72, 0.32, 0.30), 0)
	if win_tile != "":
		var tile = make_tile_view(win_tile, Vector2(52, 72), false, Callable(), true)
		tile.name = "WinDetailTile"
		showcase.add_child(tile)
		apply_rect(tile, rect_full(0.10, 0.10, 0.48, 0.88))
	else:
		add_lucide_icon(showcase, "trophy", rect_full(0.12, 0.22, 0.44, 0.78), GOLD_BRIGHT)
	var seal_text = "摸" if self_draw else "胡"
	var seal = make_seal_stamp(showcase, rect_full(0.52, 0.06, 0.88, 0.52), seal_text, "round")
	seal.name = "WinDetailSeal"
	var fan_label = make_label(showcase, "%d番" % fan, 15, Color(0.96, 0.88, 0.58), true)
	apply_rect(fan_label, rect_full(0.52, 0.50, 0.92, 0.72))
	var point_label = make_label(showcase, compact_score_text(points), 13, Color(0.74, 0.84, 0.76), true)
	apply_rect(point_label, rect_full(0.52, 0.70, 0.92, 0.90))
	var pip_count = min(6, max(1, fan))
	for i in range(pip_count):
		var left = 0.08 + float(i) * 0.045
		make_panel(showcase, rect_full(left, 0.02, left + 0.030, 0.08), Color(0.96, 0.80, 0.34, 0.70), 999, Color(1.0, 0.92, 0.56, 0.30), 0)
	if fx_enabled_effective():
		showcase.modulate = Color(1, 1, 1, 0)
		showcase.scale = Vector2(0.92, 0.92)
		var tw := create_tween()
		tw.set_parallel(true)
		tw.tween_property(showcase, "modulate:a", 1.0, 0.24).from(0.0).set_delay(0.08)
		tw.tween_property(showcase, "scale", Vector2(1.0, 1.0), 0.24).from(Vector2(0.92, 0.92)).set_delay(0.08).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	return showcase

func fan_badge_color(reason: String) -> Color:
	# 高番型 - 金色
	if reason == "十三幺" or reason == "大四喜" or reason == "字一色":
		return Color(0.92, 0.76, 0.28)
	# 中等番型 - 紫色
	if reason == "大三元" or reason == "小四喜" or reason == "清一色" or reason == "七对":
		return Color(0.58, 0.42, 0.82)
	# 低番型 - 青色
	if reason == "小三元" or reason == "混一色" or reason == "碰碰胡" or reason == "一条龙":
		return Color(0.32, 0.56, 0.72)
	# 基础番型 - 绿色
	if reason == "平胡" or reason == "自摸" or reason == "门清" or reason == "断幺九" or reason == "庄家" or reason == "花牌":
		return Color(0.28, 0.58, 0.42)
	# 特殊操作 - 橙色
	if reason == "杠" or reason == "杠上开花" or reason == "海底捞月" or reason == "抢杠胡" or reason == "大吊车":
		return Color(0.82, 0.56, 0.28)
	# 封顶 - 红色
	if reason == "封顶":
		return Color(0.88, 0.28, 0.22)
	# 默认
	return Color(0.40, 0.46, 0.50)

func draw_round_summary_rank_row(parent: Control, seat: int, rank: int) -> void:
	var top = ROUND_SUMMARY_RANK_START_Y + float(rank - 1) * (ROUND_SUMMARY_RANK_ROW_HEIGHT + ROUND_SUMMARY_RANK_ROW_GAP)
	var row_rect = Rect2(Vector2(0.08, top), Vector2(0.92, top + ROUND_SUMMARY_RANK_ROW_HEIGHT))
	var delta = round_summary_score_delta(seat)
	var accent = round_summary_delta_color(delta, rank)
	var row = make_panel(parent, row_rect, Color(0.016, 0.026, 0.030, 0.92), 11, accent.darkened(0.10), 0)
	row.name = "RoundSummaryRankRow_%d" % seat
	row.add_child(make_color_rect(rect_full(0.0, 0.0, 0.026, 1.0), accent))
	var rank_badge = make_badge(row, rect_full(0.045, 0.18, 0.155, 0.82), "第%d" % rank, 12, accent.darkened(0.12), accent.lightened(0.10), Color(0.96, 0.94, 0.84))
	rank_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if seat == offline_last_winner:
		var winner_seal = make_seal_stamp(row, rect_full(0.020, 0.080, 0.060, 0.480), "胜", "round")
		winner_seal.name = "RoundSummaryWinnerSeal"
	var name = make_label(row, str(players[seat]["name"]), 14, UI_TEXT_MAIN, true)
	apply_rect(name, rect_full(0.185, 0.12, 0.500, 0.88))
	name.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	configure_clipped_label(name)
	var score = make_label(row, compact_score_text(int(players[seat].get("score", 0))), 14, UI_TEXT_MAIN, true)
	apply_rect(score, rect_full(0.500, 0.12, 0.675, 0.88))
	score.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	configure_clipped_label(score)
	var delta_label = make_label(row, round_summary_delta_text(delta), 13, accent.lightened(0.28), true)
	apply_rect(delta_label, rect_full(0.700, 0.12, 0.835, 0.88))
	delta_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	configure_clipped_label(delta_label)
	var flowers = make_label(row, "花%d" % int(players[seat].get("flowers", 0)), 12, UI_TEXT_MUTED, false)
	apply_rect(flowers, rect_full(0.860, 0.12, 0.970, 0.88))
	flowers.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	configure_clipped_label(flowers)
	draw_round_summary_delta_bar(row, delta)
	if fx_enabled_effective():
		row.modulate = Color(1, 1, 1, 0)
		row.offset_left = -10.0
		row.offset_right = -10.0
		var tw := create_tween()
		tw.set_parallel(true)
		var delay = 0.14 + float(rank - 1) * 0.072
		tw.tween_property(row, "modulate:a", 1.0, 0.22).from(0.0).set_delay(delay).set_ease(Tween.EASE_OUT)
		tw.tween_property(row, "offset_left", 0.0, 0.22).from(-18.0).set_delay(delay).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(row, "offset_right", 0.0, 0.22).from(-18.0).set_delay(delay).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		# 分数变化从右侧飞入 / Score delta fly-in
		var delta_bar = row.get_node_or_null("RoundSummaryDeltaBar")
		if delta_bar != null and is_instance_valid(delta_bar):
			delta_bar.modulate.a = 0.0
			var d_tw := create_tween()
			d_tw.tween_property(delta_bar, "modulate:a", 1.0, 0.18).from(0.0).set_delay(delay + 0.12).set_ease(Tween.EASE_OUT)

func draw_round_summary_delta_bar(row: Control, delta: int) -> Control:
	var bar_root = Control.new()
	bar_root.name = "RoundSummaryDeltaBar"
	bar_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(bar_root, rect_full(0.185, 0.785, 0.970, 0.910))
	row.add_child(bar_root)
	make_panel(bar_root, rect_full(0.0, 0.22, 1.0, 0.78), Color(0.006, 0.014, 0.016, 0.72), 999, Color(0.88, 0.78, 0.52, 0.10), 0)
	var fraction = round_summary_delta_bar_fraction(delta)
	var center = 0.5
	var accent = Color(0.30, 0.64, 0.46, 0.78) if delta >= 0 else Color(0.68, 0.34, 0.30, 0.78)
	var left = center if delta >= 0 else center - fraction * 0.48
	var right = center + fraction * 0.48 if delta >= 0 else center
	var fill = make_panel(bar_root, rect_full(left, 0.18, right, 0.82), accent, 999, accent.lightened(0.18), 0)
	fill.name = "RoundSummaryDeltaBarFill"
	make_panel(bar_root, rect_full(0.492, 0.02, 0.508, 0.98), Color(0.88, 0.78, 0.50, 0.34), 999, Color(0, 0, 0, 0), 0)
	return bar_root

func round_summary_delta_bar_fraction(delta: int) -> float:
	var max_delta = 1
	for value in last_score_deltas:
		max_delta = max(max_delta, abs(int(value)))
	return clamp(float(abs(delta)) / float(max_delta), 0.0, 1.0)

func round_summary_score_delta(seat: int) -> int:
	if seat < 0 or seat >= last_score_deltas.size():
		return 0
	return int(last_score_deltas[seat])

func round_summary_delta_text(delta: int) -> String:
	if delta > 0:
		return "+%s" % compact_score_text(delta)
	if delta < 0:
		return compact_score_text(delta)
	return "+0"

func round_summary_delta_color(delta: int, rank: int) -> Color:
	if delta > 0:
		return Color(0.30, 0.64, 0.46, 0.92)
	if delta < 0:
		return Color(0.64, 0.34, 0.30, 0.88)
	if rank == 1:
		return Color(0.70, 0.58, 0.28, 0.90)
	return Color(0.34, 0.42, 0.44, 0.84)

func score_delta_text(seat: int) -> String:
	if seat < 0 or seat >= last_score_deltas.size():
		return ""
	var delta = int(last_score_deltas[seat])
	if delta > 0:
		return " +%s" % compact_score_text(delta)
	if delta < 0:
		return " %s" % compact_score_text(delta)
	return " +0"

func compact_score_text(value: int) -> String:
	var sign = "-" if value < 0 else ""
	var amount = abs(value)
	if amount >= 100000:
		return "%s%d万" % [sign, int(round(float(amount) / 10000.0))]
	if amount >= 10000:
		return "%s%.1f万" % [sign, float(amount) / 10000.0]
	return "%s%d" % [sign, amount]

func draw_hand(parent: Control) -> void:
	# 手牌托盘 - 增强视觉效果
	var tray = make_panel(parent, HAND_TRAY_RECT, Color(0.014, 0.022, 0.024, 0.98), 22, Color(0.62, 0.54, 0.34, 0.56), 4)
	tray.name = "HandTray"
	# 顶部栏
	make_panel(tray, HAND_TRAY_TOP_RAIL_RECT, Color(0.062, 0.070, 0.058, 0.82), 14, Color(1.0, 0.88, 0.45, 0.20))
	# 分隔线
	make_panel(tray, HAND_TRAY_DIVIDER_RECT, Color(0.010, 0.018, 0.020, 0.36), 12, Color(0.16, 0.18, 0.16, 0.08))

	# 状态文本
	var tray_text = make_label(tray, hand_tray_text(), 14, Color(0.92, 0.86, 0.62), true)
	tray_text.clip_text = true
	apply_rect(tray_text, HAND_TRAY_TEXT_RECT)
	tray_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	configure_clipped_label(tray_text)

	# 状态徽章
	var state_badge = make_badge(tray, HAND_TRAY_STATE_BADGE_RECT, hand_tray_state_text(), 12, hand_tray_state_fill(), hand_tray_state_border(), Color(0.92, 0.92, 0.84))
	state_badge.name = "HandTrayStateBadge"
	state_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	draw_hand_tray_state_art(tray)

	# 新手提示：首次出牌时显示
	if show_hand_hint and tutorial_step == 0 and can_self_discard():
		var hint_panel = make_panel(tray, rect_full(0.02, 0.50, 0.98, 0.92), Color(0.020, 0.042, 0.048, 0.94), 12, Color(0.30, 0.58, 0.48, 0.42), 0)
		hint_panel.add_child(make_color_rect(rect_full(0.0, 0.0, 0.015, 1.0), Color(0.30, 0.62, 0.52, 0.56)))
		var hint_text = "💡 点击手牌即可打出 · 出牌后等待对手响应"
		var hint_label = make_label(hint_panel, hint_text, 14, Color(0.94, 0.96, 0.92), false)
		apply_rect(hint_label, rect_full(0.04, 0.15, 0.96, 0.85))
		hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		# 首次出牌后关闭提示
		var close_hint = func() -> void:
			show_hand_hint = false
		if not tray.is_connected("tree_exiting", close_hint):
			tray.connect("tree_exiting", close_hint)
		# 激活交互式引导
		interactive_guide_active = true
		interactive_guide_type = "discard"

	var hand = get_self_hand()
	draw_hand_tray_suit_flow(tray, hand)
	draw_hand_tray_momentum_art(tray, hand)
	var hand_layout = hand_layout_metrics(hand)
	var hand_box = HBoxContainer.new()
	hand_box.alignment = BoxContainer.ALIGNMENT_CENTER
	configure_passive_container(hand_box)
	hand_box.add_theme_constant_override("separation", int(hand_layout.get("separation", 5)))
	apply_rect(hand_box, HAND_TRAY_TILES_RECT)
	tray.add_child(hand_box)

	# 手牌滑入动画
	if fx_enabled_effective():
		tray.modulate = Color(1, 1, 1, 0)
		tray.offset_top = 24.0
		var tw := create_tween()
		var slide_dur := float(HAND_SLIDE_IN_DURATION_MSEC) / 1000.0
		tw.set_parallel(true)
		tw.tween_property(tray, "modulate:a", 1.0, slide_dur).from(0.0)
		tw.tween_property(tray, "offset_top", 0.0, slide_dur).from(24.0)

	var assist_enabled = player_ai_assist_enabled()
	var suggested_tile = suggest_human_discard() if assist_enabled else ""
	var hand_reports = discard_report_map_for_hand() if assist_enabled else {}
	var pending_tile = pending_danger_discard_tile if assist_enabled and has_pending_danger_discard() else ""
	var tile_width = float(hand_layout.get("tile_width", HAND_TILE_MAX_WIDTH))
	var tile_height = float(hand_layout.get("tile_height", tile_width * HAND_TILE_ASPECT))
	var group_gap_width = float(hand_layout.get("group_gap_width", 12.0))
	var drawn_tile = str(offline_last_draw.get("tile", ""))
	var drawn_serial = int(offline_last_draw.get("serial", -1))
	var should_animate_drawn_tile = mode == "offline" and fx_enabled_effective() and bool(offline_last_draw.get("announce", false)) and int(offline_last_draw.get("seat", -1)) == 0 and drawn_tile != "" and drawn_serial != fx_last_animated_draw_serial
	var draw_animation_applied := false
	for i in range(hand.size()):
		var index = i
		var tile = str(hand[i])
		if should_insert_hand_group_gap(hand, i):
			hand_box.add_child(make_hand_group_spacer(tile_height, group_gap_width, hand_group_label(tile)))
		var clickable = can_self_discard()
		# 新手引导高亮：可点击时添加视觉提示
		var should_highlight = clickable and ((suggested_tile != "" and tile == suggested_tile) or (pending_tile != "" and tile == pending_tile))
		var guide_highlight = interactive_guide_active and interactive_guide_type == "discard" and clickable
		var highlighted = should_highlight or guide_highlight
		var report: Dictionary = hand_reports.get(tile, {})
		var risk = str(report.get("safety_label", report.get("risk_label", ""))) if assist_enabled and clickable else ""
		var hint_badge = hand_tile_hint_badge(tile, suggested_tile, pending_tile) if assist_enabled and clickable else ""
		var callback = func() -> void:
			# 玩家执行操作时关闭引导
			if interactive_guide_active:
				interactive_guide_active = false
				interactive_guide_type = ""
			if mode == "offline":
				human_discard(index)
			else:
				send_online_action({"type": "discard", "tile": tile}, "打出%s" % tile_label(tile))
		var tile_node = make_tile_view(tile, Vector2(tile_width, tile_height), clickable, callback, highlighted, risk, hint_badge)
		hand_box.add_child(tile_node)
		if should_animate_drawn_tile and not draw_animation_applied and tile == drawn_tile:
			draw_animation_applied = true
			fx_last_animated_draw_serial = drawn_serial
			play_hand_draw_tile_animation(tile_node, str(offline_last_draw.get("source", "normal")))

func draw_hand_tray_state_art(parent: Control) -> Control:
	var state = hand_tray_state_text()
	var accent = hand_tray_state_fill()
	var art = Control.new()
	art.name = "HandTrayStateArt"
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(art, rect_full(0.760, 0.030, 0.985, 0.150))
	parent.add_child(art)
	var rail = make_panel(art, rect_full(0.02, 0.70, 0.98, 0.88), Color(accent.r, accent.g, accent.b, 0.22), 999, Color(accent.r, accent.g, accent.b, 0.18), 0)
	rail.name = "HandTrayStateRail"
	var pulse = make_panel(art, rect_full(0.030, 0.180, 0.120, 0.620), Color(accent.r, accent.g, accent.b, 0.32), 999, Color(accent.r, accent.g, accent.b, 0.36), 0)
	pulse.name = "HandTrayStatePulse"
	var icon_name = hand_tray_state_icon_name(state)
	if icon_name != "":
		add_lucide_icon(art, icon_name, rect_full(0.040, 0.210, 0.105, 0.590), Color(0.96, 0.92, 0.76, 0.82))
	if fx_enabled_effective() and DisplayServer.get_name().to_lower() != "headless":
		var tw := create_tween()
		tw.set_loops(12)
		tw.tween_property(pulse, "modulate:a", 0.36, 0.64).from(0.92)
		tw.tween_property(pulse, "modulate:a", 0.92, 0.64).from(0.36)
	return art

func hand_tray_state_icon_name(state: String) -> String:
	match state:
		"出牌":
			return "zap"
		"响应":
			return "sparkles"
		"结算":
			return "trophy"
		"等待":
			return "pause"
	return "info"

func draw_hand_tray_suit_flow(parent: Control, hand: Array) -> Control:
	var flow = Control.new()
	flow.name = "HandTraySuitFlow"
	flow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(flow, rect_full(0.020, 0.855, 0.235, 0.960))
	parent.add_child(flow)
	var counts := hand_group_counts(hand)
	var max_count = 1
	for value in counts:
		max_count = max(max_count, int(value))
	var labels := ["万", "条", "筒", "字", "花"]
	var colors := [
		Color(0.74, 0.46, 0.34),
		Color(0.34, 0.62, 0.46),
		Color(0.34, 0.52, 0.72),
		Color(0.66, 0.56, 0.34),
		Color(0.70, 0.42, 0.62),
	]
	var rail = make_panel(flow, rect_full(0.020, 0.440, 0.980, 0.570), Color(0.88, 0.74, 0.42, 0.10), 999, Color(0.96, 0.82, 0.46, 0.10), 0)
	rail.name = "HandTraySuitRail"
	for i in range(labels.size()):
		var count = int(counts[i])
		var center = 0.085 + float(i) * 0.205
		var height = 0.22 + 0.52 * float(count) / float(max_count)
		var color: Color = colors[i]
		var node = make_panel(flow, rect_full(center - 0.035, 0.500 - height * 0.5, center + 0.035, 0.500 + height * 0.5), Color(color.r, color.g, color.b, 0.54 if count > 0 else 0.18), 999, Color(color.r, color.g, color.b, 0.34), 0)
		node.name = "HandTraySuitNode_%s" % labels[i]
		var label = make_label(flow, labels[i], 8, Color(0.96, 0.88, 0.62, 0.88 if count > 0 else 0.42), true)
		label.name = "HandTraySuitLabel_%s" % labels[i]
		apply_rect(label, rect_full(center - 0.055, 0.680, center + 0.055, 0.980))
		configure_clipped_label(label)
	if has_pending_danger_discard():
		var danger = make_panel(flow, rect_full(0.000, 0.000, 1.000, 1.000), Color(0.92, 0.34, 0.24, 0.08), 999, Color(1.0, 0.58, 0.36, 0.18), 0)
		danger.name = "HandTraySuitDangerGlow"
	return flow

func draw_hand_tray_momentum_art(parent: Control, hand: Array) -> Control:
	var art = Control.new()
	art.name = "HandTrayMomentumArt"
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(art, rect_full(0.250, 0.835, 0.745, 0.965))
	parent.add_child(art)
	var accent = hand_tray_state_fill()
	var active = can_self_discard()
	var rail = make_color_rect(rect_full(0.020, 0.420, 0.980, 0.580), Color(accent.r, accent.g, accent.b, 0.20 if active else 0.10))
	rail.name = "HandTrayMomentumRail"
	art.add_child(rail)
	var track = make_color_rect(rect_full(0.060, 0.480, 0.940, 0.520), Color(0.96, 0.86, 0.52, 0.22 if active else 0.08))
	track.name = "HandTrayMomentumTrack"
	art.add_child(track)
	var count = max(1, hand.size())
	var visible_pips = min(6, max(3, int(ceil(float(count) / 3.0))))
	for i in range(visible_pips):
		var center = 0.090 + (0.820 * float(i) / float(max(1, visible_pips - 1)))
		var pip = make_panel(art, rect_full(center - 0.014, 0.305, center + 0.014, 0.695), Color(accent.r, accent.g, accent.b, 0.48 if active else 0.18), 999, Color(1.0, 0.88, 0.54, 0.18), 0)
		pip.name = "HandTrayMomentumPip_%d" % i
	var focus_left = 0.790 if active else 0.060
	var focus = make_panel(art, rect_full(focus_left, 0.145, focus_left + 0.085, 0.855), Color(accent.r, accent.g, accent.b, 0.30), 999, Color(1.0, 0.88, 0.54, 0.30), 0)
	focus.name = "HandTrayMomentumFocus"
	var drawn_tile = str(offline_last_draw.get("tile", ""))
	if mode == "offline" and int(offline_last_draw.get("seat", -1)) == 0 and drawn_tile != "":
		var draw_badge = make_panel(art, rect_full(0.865, 0.050, 0.990, 0.930), Color(0.030, 0.044, 0.040, 0.80), 10, Color(0.92, 0.76, 0.34, 0.30), 0)
		draw_badge.name = "HandTrayLastDrawBadge"
		var badge_label = "杠" if str(offline_last_draw.get("source", "")) == "gang" else "摸"
		var draw_label = make_label(draw_badge, badge_label, 11, Color(0.96, 0.86, 0.56, 0.92), true)
		draw_label.name = "HandTrayLastDrawLabel"
		draw_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		draw_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		apply_rect(draw_label, rect_full(0.0, 0.08, 1.0, 0.92))
		configure_clipped_label(draw_label)
	if has_pending_danger_discard():
		var warning = make_color_rect(rect_full(0.010, 0.120, 0.024, 0.880), Color(0.96, 0.36, 0.24, 0.46))
		warning.name = "HandTrayMomentumWarning"
		art.add_child(warning)
	if fx_enabled_effective() and DisplayServer.get_name().to_lower() != "headless":
		var tw := create_tween()
		tw.set_loops(10)
		tw.tween_property(focus, "modulate:a", 0.46, 0.55).from(1.0).set_ease(Tween.EASE_OUT)
		tw.tween_property(focus, "modulate:a", 1.0, 0.55).from(0.46).set_ease(Tween.EASE_IN)
	return art

func hand_group_counts(hand: Array) -> Array[int]:
	var counts: Array[int] = [0, 0, 0, 0, 0]
	for tile in hand:
		var group = hand_group_index(str(tile))
		if group >= 0 and group < counts.size():
			counts[group] += 1
	return counts

func hand_layout_metrics(hand: Array) -> Dictionary:
	return hand_layout_metrics_for_content(hand, hand_content_pixel_size())

func hand_layout_metrics_for_content(hand: Array, content_size: Vector2) -> Dictionary:
	var count = max(1, hand.size())
	var gap_count = hand_group_gap_count(hand)
	var selected_gap = 0.0
	var selected_separation = 1
	var selected_width = 1.0
	for candidate in HAND_LAYOUT_CANDIDATES:
		var gap_width = float(candidate[0])
		var separation = int(candidate[1])
		var candidate_width = hand_tile_width_for_space(content_size, count, gap_count, gap_width, separation)
		selected_gap = gap_width
		selected_separation = separation
		selected_width = candidate_width
		if candidate_width >= HAND_TILE_MIN_TOUCH_WIDTH:
			break
	var tile_width = min(HAND_TILE_MAX_WIDTH, floor(max(1.0, selected_width)))
	var tile_height = floor(tile_width * HAND_TILE_ASPECT)
	return {
		"tile_width": tile_width,
		"tile_height": tile_height,
		"group_gap_width": selected_gap,
		"separation": selected_separation,
		"content_width": content_size.x,
		"content_height": content_size.y,
	}

func hand_tile_width_for_space(content_size: Vector2, tile_count: int, gap_count: int, gap_width: float, separation: int) -> float:
	var gaps_width = float(max(0, gap_count)) * gap_width
	var separations_width = float(max(0, tile_count - 1)) * float(max(0, separation))
	var width_by_space = (content_size.x - gaps_width - separations_width) / float(max(1, tile_count))
	var width_by_height = content_size.y / HAND_TILE_ASPECT
	return min(width_by_space, width_by_height)

func hand_group_gap_count(hand: Array) -> int:
	var count = 0
	for i in range(1, hand.size()):
		if should_insert_hand_group_gap(hand, i):
			count += 1
	return count

func hand_content_pixel_size() -> Vector2:
	var content_size = safe_content_pixel_size()
	return Vector2(content_size.x * 0.810 * 0.970, content_size.y * 0.220 * 0.810)

func hand_layout_required_width(hand: Array, metrics: Dictionary) -> float:
	var tile_count = hand.size()
	var gap_count = hand_group_gap_count(hand)
	return float(tile_count) * float(metrics.get("tile_width", 0.0)) + float(gap_count) * float(metrics.get("group_gap_width", 0.0)) + float(max(0, tile_count - 1)) * float(metrics.get("separation", 0))

func hand_layout_fits_content(hand: Array, metrics: Dictionary) -> bool:
	return hand_layout_required_width(hand, metrics) <= float(metrics.get("content_width", hand_content_pixel_size().x)) + 0.5

func hand_tile_hint_badge(tile: String, suggested_tile: String, pending_tile: String) -> String:
	if pending_tile != "" and tile == pending_tile:
		return "确认"
	if suggested_tile != "" and tile == suggested_tile:
		return "荐"
	return ""

func should_insert_hand_group_gap(hand: Array, index: int) -> bool:
	if index <= 0 or index >= hand.size():
		return false
	return hand_group_index(str(hand[index - 1])) != hand_group_index(str(hand[index]))

func hand_group_index(tile: String) -> int:
	var index = tile_index(tile)
	if index >= 0 and index < 27:
		return int(index / 9)
	if index >= 27:
		return 3
	if is_flower_tile(tile):
		return 4
	return 5

func make_hand_group_spacer(height: float, width: float = 12.0, label_text: String = "") -> Control:
	var spacer = Control.new()
	spacer.name = "HandGroupDivider"
	spacer.custom_minimum_size = Vector2(width, height)
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var line = ColorRect.new()
	line.color = Color(1.0, 0.78, 0.30, 0.38)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(line, rect_full(0.44, 0.12, 0.56, 0.88))
	spacer.add_child(line)
	var cap = make_panel(spacer, rect_full(0.18, 0.04, 0.82, 0.11), Color(0.96, 0.78, 0.34, 0.58), 4, Color(1.0, 0.92, 0.62, 0.18), 0)
	cap.name = "HandGroupDividerCap"
	if label_text != "" and width >= 8.0:
		var label = make_label(spacer, label_text, 8, Color(0.98, 0.88, 0.58, 0.92), true)
		label.name = "HandGroupDividerLabel_%s" % label_text
		apply_rect(label, rect_full(0.0, 0.78, 1.0, 0.99))
		configure_clipped_label(label)
	return spacer

func hand_group_label(tile: String) -> String:
	var group_index = hand_group_index(tile)
	match group_index:
		0:
			return "万"
		1:
			return "条"
		2:
			return "筒"
		3:
			return "字"
		4:
			return "花"
	return ""

func discard_report_map_for_hand() -> Dictionary:
	if not player_ai_assist_enabled() or mode != "offline" or not can_self_discard():
		return {}
	var reports = current_human_advice if not current_human_advice.is_empty() else get_ai_discard_reports(0)
	var result: Dictionary = {}
	for report in reports:
		if typeof(report) == TYPE_DICTIONARY:
			result[str(report.get("tile", ""))] = report
	return result

func hand_tray_text() -> String:
	if not player_ai_assist_enabled():
		return current_status_text()
	if has_pending_danger_discard():
		return pending_danger_discard_text()
	if mode == "offline" and offline_phase == "pending_claim":
		return human_claim_hint_text()
	if mode == "offline" and can_self_discard():
		var reports = current_human_advice if not current_human_advice.is_empty() else get_ai_discard_reports(0)
		if not reports.is_empty():
			var best: Dictionary = reports[0]
			var safest = safest_discard_report()
			return compact_hand_tray_summary(best, safest)
	return current_status_text()

func compact_hand_tray_summary(best: Dictionary, safest: Dictionary = {}) -> String:
	if best.is_empty():
		return current_status_text()
	var parts: Array[String] = []
	parts.append("荐%s" % tile_label(str(best.get("tile", ""))))
	parts.append(shanten_label(int(best.get("shanten", 8))))
	var reason = str(best.get("reason_label", ""))
	if reason != "":
		parts.append(reason)
	var plan = hand_plan_text(best)
	if plan != "":
		parts.append(plan)
	parts.append("进%d/%d" % [int(best.get("ukeire", 0)), int(best.get("variety", 0))])
	var wait = effective_tile_text(best, 2)
	if wait != "":
		parts.append(wait)
	var safety = discard_safety_short_text(best)
	if safety != "":
		parts.append(safety)
	parts.append(str(best.get("stance", "均衡")))
	var safe_hint = safest_discard_hint_text(best, safest)
	if safe_hint != "":
		parts.append(safe_hint)
	return " · ".join(parts)

func hand_tray_state_text() -> String:
	if mode == "offline":
		if offline_phase == "ended":
			return "结算"
		if offline_phase == "pending_claim":
			return "响应"
		if can_self_discard():
			return "出牌"
		return "等待"
	if mode == "online_game":
		var pending = online_game.get("pending", null)
		if typeof(pending) == TYPE_DICTIONARY and pending.get("options", []).size() > 0:
			return "响应"
		return "出牌" if can_self_discard() else "等待"
	return "准备"

func hand_tray_state_fill() -> Color:
	match hand_tray_state_text():
		"出牌":
			return Color(0.20, 0.48, 0.42, 0.94)
		"响应":
			return Color(0.62, 0.38, 0.22, 0.94)
		"结算":
			return Color(0.42, 0.32, 0.54, 0.94)
		"等待":
			return Color(0.24, 0.30, 0.34, 0.92)
	return Color(0.26, 0.34, 0.42, 0.92)

func hand_tray_state_border() -> Color:
	var fill = hand_tray_state_fill()
	return Color(fill.r + 0.18, fill.g + 0.16, fill.b + 0.12, 0.42)

func draw_actions(parent: Control) -> void:
	action_bar = HBoxContainer.new()
	action_bar.alignment = BoxContainer.ALIGNMENT_END
	configure_passive_container(action_bar)
	action_bar.add_theme_constant_override("separation", 6)
	apply_rect(action_bar, ACTION_BAR_RECT)
	parent.add_child(action_bar)

	# 操作按钮淡入动画
	if fx_enabled_effective():
		action_bar.modulate = Color(1, 1, 1, 0)
		var tw := create_tween()
		tw.tween_property(action_bar, "modulate:a", 1.0, 0.18).from(0.0)

	if mode == "offline":
		if offline_phase == "ended":
			if not is_offline_match_finished():
				action_bar.add_child(make_action_button("下一局", Color(0.32, 0.72, 0.60), func() -> void:
					start_next_offline_hand()
				))
			action_bar.add_child(make_action_button("新赛", Color(0.86, 0.42, 0.32), func() -> void:
				start_offline()
			))
			action_bar.add_child(make_action_button("菜单", Color(0.48, 0.54, 0.56), func() -> void:
				show_menu()
			))
			draw_action_dock(parent)
			finalize_action_bar_layout()
			return
		if offline_phase == "pending_claim":
			# 新手引导：吃碰杠提示
			if interactive_guide_active and interactive_guide_type == "claim":
				show_toast("💡 对手打出了一张牌，你可以选择吃/碰/杠/胡或过")
			draw_pending_claim_illustration(parent)
			var claim_recommendation = recommended_claim_report() if player_ai_assist_enabled() else {}
			for claim in offline_pending_claim.get("options", []):
				var claim_name = str(claim)
				if claim_name == "chi":
					var chi_choices: Array = offline_pending_claim.get("chi_choices", [])
					if chi_choices.is_empty():
						var is_recommended_claim = is_recommended_claim_action(claim_name, {}, claim_recommendation)
						action_bar.add_child(make_action_button(claim_action_button_text(claim_name, {}, claim_recommendation), claim_action_button_color(claim_name, is_recommended_claim), func() -> void:
							human_claim(claim_name)
						))
					else:
						for choice in chi_choices:
							var selected_choice: Dictionary = choice
							var is_recommended_choice = is_recommended_claim_action(claim_name, selected_choice, claim_recommendation)
							action_bar.add_child(make_action_button(claim_action_button_text(claim_name, selected_choice, claim_recommendation), claim_action_button_color(claim_name, is_recommended_choice), func() -> void:
								human_claim("chi", selected_choice)
							))
				else:
					var is_recommended_claim = is_recommended_claim_action(claim_name, {}, claim_recommendation)
					action_bar.add_child(make_action_button(claim_action_button_text(claim_name, {}, claim_recommendation), claim_action_button_color(claim_name, is_recommended_claim), func() -> void:
						human_claim(claim_name)
					))
			action_bar.add_child(make_action_button(pass_claim_button_text(claim_recommendation), pass_claim_button_color(claim_recommendation), func() -> void:
				human_claim("pass")
			))
			draw_action_dock(parent)
			finalize_action_bar_layout()
			return
		if can_self_discard() and can_win_for_seat(0):
			action_bar.add_child(make_action_button("自摸", Color(0.94, 0.42, 0.32), func() -> void:
				human_self_win()
			))
		var gang_tile = first_concealed_gang_tile(0)
		if can_self_discard() and gang_tile != "":
			action_bar.add_child(make_action_button("暗杠", Color(0.62, 0.54, 0.88), func() -> void:
				human_concealed_gang(gang_tile)
			))
		var added_gang_tile = first_added_gang_tile(0)
		if can_self_discard() and added_gang_tile != "":
			action_bar.add_child(make_action_button("补杠", Color(0.66, 0.58, 0.92), func() -> void:
				human_added_gang(added_gang_tile)
			))
		if player_ai_assist_enabled() and can_self_discard() and not has_pending_danger_discard():
			var recommended_report = recommended_discard_report()
			var recommended_tile = str(recommended_report.get("tile", ""))
			var safest_report = safest_discard_report()
			var safest_tile = str(safest_report.get("tile", ""))
			var offer_safest = should_offer_safest_discard_button(recommended_report, safest_report)
			var excluded_action_tiles: Array[String] = []
			if recommended_tile != "":
				var selected_recommended_tile = recommended_tile
				excluded_action_tiles.append(selected_recommended_tile)
				if offer_safest and safest_tile != "" and safest_tile != recommended_tile:
					var selected_safest_tile = safest_tile
					excluded_action_tiles.append(selected_safest_tile)
					action_bar.add_child(make_action_button(safest_discard_button_text(safest_report), safe_discard_button_color(safest_report), func() -> void:
						human_discard_by_tile(selected_safest_tile)
					))
				var recommended_button_text = safest_discard_button_text(recommended_report) if offer_safest and safest_tile == recommended_tile else recommended_discard_button_text(selected_recommended_tile)
				action_bar.add_child(make_action_button(recommended_button_text, recommended_discard_button_color(recommended_report), func() -> void:
					human_discard_by_tile(selected_recommended_tile)
				))
				var alternative_limit = 1 if offer_safest and safest_tile != "" and safest_tile != recommended_tile else 2
				for report in discard_action_alternative_reports(excluded_action_tiles, alternative_limit):
					var alternative_tile = str(report.get("tile", ""))
					if alternative_tile == "":
						continue
					var selected_action_tile = alternative_tile
					action_bar.add_child(make_action_button(alternative_discard_button_text(report), alternative_discard_button_color(report), func() -> void:
						human_discard_by_tile(selected_action_tile)
					))
		if player_ai_assist_enabled() and has_pending_danger_discard():
			for report in safe_discard_alternative_reports(pending_danger_discard_tile, 2):
				var alternative_tile = str(report.get("tile", ""))
				if alternative_tile == "":
					continue
				var selected_alternative_tile = alternative_tile
				action_bar.add_child(make_action_button("改打%s" % tile_label(selected_alternative_tile), safe_discard_button_color(report), func() -> void:
					human_discard_by_tile(selected_alternative_tile)
				))
			action_bar.add_child(make_action_button("取消", Color(0.52, 0.56, 0.58), func() -> void:
				clear_pending_danger_discard()
				set_status(current_status_text())
				render_game()
			))
		action_bar.add_child(make_action_button("重开", Color(0.70, 0.32, 0.22), func() -> void:
			start_offline()
		))
		if player_ai_assist_enabled():
			action_bar.add_child(make_action_button("提示", Color(0.25, 0.58, 0.48), func() -> void:
				set_status(human_hint_text())
			))
	if mode == "online_game":
		var pending = online_game.get("pending", null)
		if typeof(pending) == TYPE_DICTIONARY:
			for claim in pending.get("options", []):
				var claim_name = str(claim)
				if claim_name == "chi":
					var chi_choices: Array = pending.get("chi_choices", [])
					if chi_choices.is_empty():
						action_bar.add_child(make_action_button(claim_label(claim_name), claim_color(claim_name), func() -> void:
							send_online_action(online_claim_payload(claim_name), claim_label(claim_name))
						))
					else:
						for choice in chi_choices:
							var selected_choice: Dictionary = choice
							action_bar.add_child(make_action_button(chi_choice_label(selected_choice), claim_color(claim_name), func() -> void:
								send_online_action(online_claim_payload("chi", selected_choice), chi_choice_label(selected_choice))
							))
				else:
					action_bar.add_child(make_action_button(claim_label(claim_name), claim_color(claim_name), func() -> void:
						send_online_action(online_claim_payload(claim_name), claim_label(claim_name))
					))
			if pending.get("options", []).size() > 0:
				action_bar.add_child(make_action_button("过", Color(0.38, 0.43, 0.44), func() -> void:
					send_online_action(online_claim_payload("pass"), "过")
				))
	var voice = make_action_button("闭麦" if voice_enabled else "语音", Color(0.74, 0.24, 0.24) if voice_enabled else Color(0.24, 0.52, 0.72), func() -> void:
		toggle_voice_chat()
	)
	voice.name = "VoiceActionButton"
	draw_voice_button_art(voice, voice_enabled, voice_peak)
	action_bar.add_child(voice)
	draw_action_dock(parent)
	finalize_action_bar_layout()

func draw_voice_button_art(button: Control, active: bool, peak: float = 0.0) -> Control:
	var art = Control.new()
	art.name = "VoiceButtonArt"
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(art, rect_full(0.650, 0.150, 0.965, 0.850))
	button.add_child(art)
	var accent = Color(0.42, 0.86, 0.64) if active else Color(0.70, 0.42, 0.42)
	var base = make_panel(art, rect_full(0.020, 0.120, 0.300, 0.880), Color(accent.r, accent.g, accent.b, 0.26 if active else 0.18), 999, Color(accent.r, accent.g, accent.b, 0.32), 0)
	base.name = "VoiceButtonStatusDot"
	var pulse_alpha = clamp(0.18 + peak * 0.36, 0.18, 0.54) if active else 0.10
	var pulse = make_panel(art, rect_full(0.000, 0.060, 0.340, 0.940), Color(accent.r, accent.g, accent.b, pulse_alpha), 999, Color(accent.r, accent.g, accent.b, 0.12), 0)
	pulse.name = "VoiceButtonPulse"
	var listen_ring = make_panel(art, rect_full(0.000, 0.000, 0.360, 1.000), Color(accent.r, accent.g, accent.b, 0.070 if active else 0.030), 999, Color(accent.r, accent.g, accent.b, 0.090 if active else 0.040), 0)
	listen_ring.name = "VoiceButtonListenRing"
	var meter = make_panel(art, rect_full(0.405, 0.815, 0.930, 0.900), Color(0.020, 0.036, 0.038, 0.68), 999, Color(accent.r, accent.g, accent.b, 0.16), 0)
	meter.name = "VoiceButtonPeakMeter"
	var meter_fill_right = 0.045 + 0.910 * (clamp(peak, 0.0, 1.0) if active else 0.10)
	var meter_fill = make_panel(meter, rect_full(0.045, 0.260, meter_fill_right, 0.740), Color(accent.r, accent.g, accent.b, 0.54 if active else 0.18), 999, Color(accent.r, accent.g, accent.b, 0.16), 0)
	meter_fill.name = "VoiceButtonPeakFill"
	for i in range(3):
		var height = (0.24 + float(i) * 0.15) * (0.72 + peak * 0.38 if active else 1.0)
		var top = 0.50 - height * 0.5
		var left = 0.430 + float(i) * 0.155
		var wave = make_panel(art, rect_full(left, top, left + 0.080, top + height), Color(accent.r, accent.g, accent.b, 0.68 if active else 0.28), 999, Color(accent.r, accent.g, accent.b, 0.18), 0)
		wave.name = "VoiceButtonWave_%d" % i
		var tick = make_panel(art, rect_full(left + 0.018, 0.080, left + 0.062, 0.155), Color(accent.r, accent.g, accent.b, 0.30 if active else 0.12), 999, Color(accent.r, accent.g, accent.b, 0.08), 0)
		tick.name = "VoiceButtonPeakTick_%d" % i
	if not active:
		var slash = make_panel(art, rect_full(0.385, 0.410, 0.930, 0.570), Color(0.90, 0.72, 0.62, 0.48), 999, Color(0.96, 0.78, 0.66, 0.20), 0)
		slash.name = "VoiceButtonMutedSlash"
		slash.rotation = -0.42
		var lock = make_panel(art, rect_full(0.040, 0.680, 0.245, 0.920), Color(0.78, 0.48, 0.42, 0.22), 999, Color(0.92, 0.64, 0.56, 0.12), 0)
		lock.name = "VoiceButtonMutedLock"
	if active and fx_enabled_effective() and DisplayServer.get_name().to_lower() != "headless":
		var tw := create_tween()
		tw.set_loops(3600)
		tw.tween_property(pulse, "modulate:a", 0.38, 0.72).from(0.92)
		tw.tween_property(pulse, "modulate:a", 0.92, 0.72).from(0.38)
		var ring_tw := create_tween()
		ring_tw.set_loops(3600)
		ring_tw.tween_property(listen_ring, "modulate:a", 0.34, 0.90).from(0.90)
		ring_tw.tween_property(listen_ring, "modulate:a", 0.90, 0.90).from(0.34)
	return art

func draw_pending_claim_illustration(parent: Control) -> void:
	if mode != "offline" or offline_phase != "pending_claim":
		return
	var tile = str(offline_pending_claim.get("tile", ""))
	if tile == "":
		return
	var panel = make_panel(parent, rect_full(0.500, 0.724, 0.982, 0.842), Color(0.014, 0.030, 0.034, 0.96), 16, Color(0.76, 0.58, 0.30, 0.44), 4)
	panel.name = "PendingClaimIllustration"
	panel.add_child(make_color_rect(rect_full(0.0, 0.0, 0.012, 1.0), Color(0.92, 0.70, 0.32, 0.64)))
	panel.add_child(make_color_rect(rect_full(0.020, 0.080, 0.982, 0.105), Color(1.0, 0.86, 0.45, 0.12)))
	make_cloud_decoration(panel, rect_full(0.64, -0.14, 1.04, 0.64), "mist", false).name = "PendingClaimMistCloud"
	var source_seat = int(offline_pending_claim.get("from_seat", -1))
	var source_name = str(players[source_seat]["name"]) if source_seat >= 0 and source_seat < players.size() else "对手"
	var source_badge = make_badge(panel, rect_full(0.035, 0.155, 0.162, 0.485), pending_claim_source_badge_text(source_seat), 11, Color(0.18, 0.32, 0.36, 0.92), Color(0.40, 0.68, 0.64, 0.42), Color(0.94, 0.96, 0.90))
	source_badge.name = "PendingClaimSourceBadge"
	source_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	draw_pending_claim_flow_art(panel, source_seat)
	var title = make_label(panel, "%s 打出" % source_name, 12, Color(0.72, 0.78, 0.72), true)
	apply_rect(title, rect_full(0.175, 0.105, 0.405, 0.345))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	var tile_view = make_tile_view(tile, Vector2(42, 58), false, Callable(), true)
	tile_view.name = "PendingClaimTile"
	panel.add_child(tile_view)
	apply_rect(tile_view, rect_full(0.300, 0.155, 0.405, 0.900))
	var tile_glow = make_panel(panel, rect_full(0.286, 0.118, 0.418, 0.938), Color(0.96, 0.72, 0.30, 0.08), 14, Color(1.0, 0.84, 0.42, 0.28), 0)
	tile_glow.name = "PendingClaimTileGlow"
	panel.move_child(tile_glow, max(0, tile_view.get_index()))
	var tile_name = make_label(panel, tile_label(tile), 18, Color(0.96, 0.88, 0.58), true)
	apply_rect(tile_name, rect_full(0.425, 0.105, 0.585, 0.350))
	tile_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	var focus = make_label(panel, pending_claim_focus_text(), 12, Color(0.92, 0.88, 0.66), true)
	focus.name = "PendingClaimFocusText"
	apply_rect(focus, rect_full(0.425, 0.375, 0.960, 0.565))
	focus.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	configure_clipped_label(focus)
	var hint = make_label(panel, claim_options_text(offline_pending_claim), 11, Color(0.76, 0.84, 0.78), false)
	apply_rect(hint, rect_full(0.425, 0.610, 0.650, 0.850))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	configure_clipped_label(hint)
	var rail = make_panel(panel, rect_full(0.662, 0.555, 0.970, 0.870), Color(0.010, 0.022, 0.024, 0.62), 12, Color(0.88, 0.68, 0.32, 0.22), 0)
	rail.name = "PendingClaimOptionRail"
	var options: Array = offline_pending_claim.get("options", [])
	var left = 0.030
	for i in range(min(4, options.size())):
		var claim_name = str(options[i])
		var chip_color = claim_color(claim_name)
		var chip = make_badge(rail, rect_full(left + float(i) * 0.190, 0.180, left + float(i) * 0.190 + 0.155, 0.820), claim_label(claim_name), 11, chip_color.darkened(0.18), chip_color.lightened(0.12), Color(0.98, 0.94, 0.84))
		chip.name = "PendingClaimOption_%s" % claim_name
		chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		draw_pending_claim_option_spark(rail, left + float(i) * 0.190, chip_color, i)
	var pass_chip = make_badge(rail, rect_full(0.805, 0.180, 0.970, 0.820), "过", 11, Color(0.20, 0.26, 0.28, 0.94), Color(0.46, 0.50, 0.48, 0.32), Color(0.86, 0.88, 0.82))
	pass_chip.name = "PendingClaimPassChip"
	pass_chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if fx_enabled_effective():
		panel.modulate = Color(1, 1, 1, 0)
		panel.offset_top = 10.0
		var tw := create_tween()
		tw.set_parallel(true)
		tw.tween_property(panel, "modulate:a", 1.0, 0.18).from(0.0)
		tw.tween_property(panel, "offset_top", 0.0, 0.18).from(10.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(tile_view, "scale", Vector2(1.0, 1.0), 0.20).from(Vector2(0.88, 0.88)).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(tile_glow, "modulate:a", 0.34, 0.28).from(0.84)

func draw_pending_claim_flow_art(parent: Control, source_seat: int) -> Control:
	var flow = Control.new()
	flow.name = "PendingClaimFlowArt"
	flow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(flow, rect_full(0.150, 0.438, 0.316, 0.690))
	parent.add_child(flow)
	var accent = SEAT_ACCENT_COLORS[source_seat] if source_seat >= 0 and source_seat < SEAT_ACCENT_COLORS.size() else GOLD_PRIMARY
	for i in range(3):
		var left = 0.020 + float(i) * 0.260
		var dash = make_panel(flow, rect_full(left, 0.430, left + 0.150, 0.570), Color(accent.r, accent.g, accent.b, 0.36), 999, Color(0.96, 0.78, 0.38, 0.18), 0)
		dash.name = "PendingClaimFlowDash_%d" % i
	var arrow = make_label(flow, ">", 16, Color(0.96, 0.82, 0.44, 0.82), true)
	arrow.name = "PendingClaimFlowArrow"
	apply_rect(arrow, rect_full(0.780, 0.080, 0.980, 0.920))
	if fx_enabled_effective():
		var tw := create_tween()
		tw.set_loops(12)
		tw.tween_property(arrow, "offset_left", 3.0, 0.42).from(0.0)
		tw.parallel().tween_property(arrow, "modulate:a", 0.46, 0.42).from(0.92)
		tw.tween_property(arrow, "offset_left", 0.0, 0.42).from(3.0)
		tw.parallel().tween_property(arrow, "modulate:a", 0.92, 0.42).from(0.46)
	return flow

func draw_pending_claim_option_spark(parent: Control, left: float, color: Color, index: int) -> Control:
	var spark = make_panel(parent, rect_full(left + 0.060, 0.030, left + 0.095, 0.170), Color(color.r, color.g, color.b, 0.28), 999, Color(1.0, 0.90, 0.54, 0.18), 0)
	spark.name = "PendingClaimOptionSpark_%d" % index
	if fx_enabled_effective():
		var tw := create_tween()
		tw.set_loops(12)
		tw.tween_property(spark, "modulate:a", 0.26, 0.58).from(0.88).set_delay(float(index) * 0.08)
		tw.tween_property(spark, "modulate:a", 0.88, 0.58).from(0.26)
	return spark

func pending_claim_source_badge_text(source_seat: int) -> String:
	if source_seat >= 0 and source_seat < CENTER_WIND_LABELS.size():
		return CENTER_WIND_LABELS[source_seat] + "家"
	return "对手"

func pending_claim_focus_text() -> String:
	if bool(offline_pending_claim.get("rob_gang", false)):
		return "抢杠窗口 · 优先确认胡牌"
	var options: Array = offline_pending_claim.get("options", [])
	if options.has("hu"):
		return "胡牌机会 · 可选择胡或过"
	if options.has("gang"):
		return "杠牌机会 · 注意后续补牌"
	if options.has("peng") and options.has("chi"):
		return "吃碰选择 · 比较进张与安全"
	if options.has("peng"):
		return "碰牌机会 · 确认是否加速成型"
	if options.has("chi"):
		return "吃牌机会 · 选择顺子组合"
	return "响应窗口 · 可操作或过"

func draw_action_dock(parent: Control) -> void:
	var count = action_bar_button_count()
	if count <= 0:
		return
	var dock = make_panel(parent, action_dock_rect_for_count(count), Color(0.014, 0.021, 0.024, 0.76), 16, Color(0.46, 0.40, 0.24, 0.24), 2)
	dock.name = "ActionButtonDock"
	var left_tail = make_color_rect(rect_full(0.010, 0.180, 0.020, 0.820), Color(0.92, 0.72, 0.34, 0.32))
	left_tail.name = "ActionDockLeftTail"
	dock.add_child(left_tail)
	var right_tail = make_color_rect(rect_full(0.980, 0.180, 0.990, 0.820), Color(0.92, 0.72, 0.34, 0.26))
	right_tail.name = "ActionDockRightTail"
	dock.add_child(right_tail)
	for i in range(min(8, count)):
		var left = 0.065 + float(i) * 0.050
		var dot = make_color_rect(rect_full(left, 0.830, left + 0.014, 0.870), Color(0.88, 0.70, 0.34, 0.28))
		dot.name = "ActionDockRhythmDot_%d" % i
		dock.add_child(dot)
	parent.move_child(dock, max(0, action_bar.get_index()))
	draw_action_intent_dock(parent, count)

func draw_action_intent_dock(parent: Control, count: int) -> Control:
	var intent = make_panel(parent, action_intent_rect_for_count(count), Color(0.020, 0.036, 0.038, 0.88), 13, action_intent_color().darkened(0.18), 0)
	intent.name = "ActionIntentDock"
	var color = action_intent_color()
	var rail = make_panel(intent, rect_full(0.012, 0.18, 0.028, 0.82), color, 8, color.lightened(0.18), 0)
	rail.name = "ActionIntentRail"
	var icon_name = action_intent_icon_name()
	if add_lucide_icon(intent, icon_name, rect_full(0.045, 0.18, 0.118, 0.82), color.lightened(0.22)) == null:
		var fallback = make_label(intent, action_intent_fallback_icon_text(), 12, color.lightened(0.22), true)
		fallback.name = "ActionIntentFallbackIcon"
		apply_rect(fallback, rect_full(0.045, 0.16, 0.118, 0.84))
	var text = make_label(intent, action_intent_text(count), 11, Color(0.84, 0.90, 0.84), true)
	text.name = "ActionIntentText"
	apply_rect(text, rect_full(0.130, 0.10, 0.845, 0.90))
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	configure_clipped_label(text)
	var count_badge = make_badge(intent, rect_full(0.858, 0.18, 0.982, 0.82), "%d项" % count, 10, color.darkened(0.20), color.lightened(0.12), Color(0.96, 0.95, 0.84))
	count_badge.name = "ActionIntentCount"
	if fx_enabled_effective():
		var tw := create_tween()
		tw.set_loops(12)
		tw.tween_property(rail, "modulate:a", 0.42, 0.64).from(0.92)
		tw.tween_property(rail, "modulate:a", 0.92, 0.64)
	return intent

func action_intent_rect_for_count(count: int) -> Rect2:
	var dock_rect = action_dock_rect_for_count(count)
	var left = max(0.580, dock_rect.position.x)
	return Rect2(Vector2(left, 0.604), Vector2(0.975, 0.650))

func action_intent_text(count: int) -> String:
	if mode == "offline" and offline_phase == "pending_claim":
		return "响应窗口 · 选择吃碰杠胡或过"
	if mode == "offline" and offline_phase == "ended":
		return "本局结束 · 继续下一局或重开"
	if mode == "offline" and has_pending_danger_discard():
		return "风险确认 · 可改打更安全牌"
	if mode == "offline" and can_self_discard():
		return "我方行动 · 点击手牌或采用推荐"
	if mode == "online_game":
		return "在线操作 · 等待或提交响应" if count <= 1 else "在线操作 · 处理当前响应"
	return "可用操作 · %d项" % count

func action_intent_color() -> Color:
	if mode == "offline" and offline_phase == "pending_claim":
		return Color(0.86, 0.62, 0.32)
	if mode == "offline" and has_pending_danger_discard():
		return Color(0.92, 0.46, 0.34)
	if mode == "offline" and can_self_discard():
		return Color(0.34, 0.68, 0.54)
	if mode == "online_game":
		return Color(0.34, 0.58, 0.78)
	return Color(0.66, 0.58, 0.38)

func action_intent_icon_name() -> String:
	if mode == "offline" and has_pending_danger_discard():
		return "alert-triangle"
	if mode == "offline" and can_self_discard():
		return "zap"
	if mode == "offline" and offline_phase == "pending_claim":
		return "sparkles"
	if mode == "online_game":
		return "users"
	return "info"

func action_intent_fallback_icon_text() -> String:
	if mode == "offline" and has_pending_danger_discard():
		return "!"
	if mode == "offline" and can_self_discard():
		return "行"
	if mode == "offline" and offline_phase == "pending_claim":
		return "应"
	return "i"

func action_dock_rect_for_count(count: int) -> Rect2:
	var content_width = max(1.0, safe_content_pixel_size().x)
	var separation = action_button_separation_for_count(count)
	var width = action_button_width_for_count(count, separation)
	var dock_pixels = float(count) * width + float(max(0, count - 1) * separation) + 36.0
	var left = max(ACTION_BAR_DOCK_RECT.position.x, ACTION_BAR_RECT.size.x - dock_pixels / content_width)
	return Rect2(Vector2(left, ACTION_BAR_DOCK_RECT.position.y), ACTION_BAR_DOCK_RECT.size)

func finalize_action_bar_layout() -> void:
	if action_bar == null:
		return
	var count = action_bar_button_count()
	if count <= 0:
		return
	var separation = action_button_separation_for_count(count)
	action_bar.add_theme_constant_override("separation", separation)
	var width = action_button_width_for_count(count, separation)
	var font_size = action_button_font_size(width)
	var height = ACTION_BUTTON_HEIGHT if width >= ACTION_BUTTON_MIN_TOUCH_WIDTH else 48.0
	for child in action_bar.get_children():
		if child is Button:
			configure_action_button_size(child as Button, width, height, font_size)

func action_bar_button_count() -> int:
	if action_bar == null:
		return 0
	var count = 0
	for child in action_bar.get_children():
		if child is Button:
			count += 1
	return count

func action_bar_buttons() -> Array[Button]:
	var buttons: Array[Button] = []
	if action_bar == null:
		return buttons
	for child in action_bar.get_children():
		if child is Button:
			buttons.append(child as Button)
	return buttons

func action_bar_pixel_width() -> float:
	return safe_content_pixel_size().x * (ACTION_BAR_RECT.size.x - ACTION_BAR_RECT.position.x)

func action_button_separation_for_count(count: int) -> int:
	if count <= 5:
		return 6
	if count <= 8:
		return 4
	return 2

func action_button_width_for_count(count: int, separation: int = -1) -> float:
	return action_button_width_for_available(count, action_bar_pixel_width(), separation)

func action_button_width_for_available(count: int, available_width: float, separation: int = -1) -> float:
	if count <= 0:
		return ACTION_BUTTON_MAX_WIDTH
	var gap = action_button_separation_for_count(count) if separation < 0 else separation
	var available = available_width - float(max(0, count - 1) * gap)
	return min(ACTION_BUTTON_MAX_WIDTH, floor(max(1.0, available / float(count))))

func action_button_font_size(width: float) -> int:
	if width >= 78.0:
		return 18
	if width >= 68.0:
		return 16
	return 14

func action_buttons_fit_width(count: int) -> bool:
	return action_buttons_fit_available(count, action_bar_pixel_width())

func action_buttons_fit_available(count: int, available_width: float) -> bool:
	var separation = action_button_separation_for_count(count)
	var width = action_button_width_for_available(count, available_width, separation)
	var required = float(count) * width + float(max(0, count - 1) * separation)
	return required <= available_width + 0.5

func setup_update_downloader() -> void:
	update_request = HTTPRequest.new()
	update_request.use_threads = true
	update_request.timeout = 180.0
	update_request.request_completed.connect(_on_update_request_completed)
	add_child(update_request)

func start_update_download() -> void:
	if update_state == "checking":
		update_message = "正在检查更新 manifest..."
		ensure_update_dialog()
		refresh_update_dialog()
		return
	if update_state == "downloading":
		update_message = "升级包正在下载中。"
		ensure_update_dialog()
		refresh_update_dialog()
		return
	update_downloaded_bytes = 0
	update_total_bytes = 0
	update_download_url = UPDATE_URL
	update_remote_version = app_version()
	update_release_notes = ""
	update_remote_sha256 = ""
	update_remote_size = 0
	update_file_path = UPDATE_FILE_PATH
	next_update_progress_msec = 0
	update_state = "checking"
	update_request_mode = "manifest"
	update_message = "正在检查更新 manifest..."
	update_request.download_file = ""
	ensure_update_dialog()
	refresh_update_dialog()
	var err = update_request.request(UPDATE_MANIFEST_URL)
	if err != OK:
		begin_update_download(UPDATE_URL, app_version(), "manifest 请求失败，使用备用下载。")
	set_status(update_message)

func begin_update_download(url: String, version: String, notes: String = "") -> void:
	var dir_error = DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://updates"))
	if dir_error != OK:
		update_state = "error"
		update_request_mode = "idle"
		update_message = "创建下载目录失败：%s" % error_string(dir_error)
		ensure_update_dialog()
		refresh_update_dialog()
		return
	update_download_url = url if url.strip_edges() != "" else UPDATE_URL
	update_remote_version = version if version.strip_edges() != "" else app_version()
	update_release_notes = notes
	update_file_path = "user://updates/YunzhuoMahjongGodot-v%s.apk" % safe_filename_part(update_remote_version)
	if FileAccess.file_exists(update_file_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(update_file_path))
	update_downloaded_bytes = 0
	update_total_bytes = 0
	next_update_progress_msec = 0
	update_state = "downloading"
	update_request_mode = "download"
	update_message = "正在下载 v%s 升级包..." % update_remote_version
	update_request.download_file = update_file_path
	ensure_update_dialog()
	refresh_update_dialog()
	var err = update_request.request(update_download_url)
	if err != OK:
		update_request.download_file = ""
		update_request_mode = "idle"
		update_state = "error"
		update_message = "开始下载失败：%s" % error_string(err)
		refresh_update_dialog()
	set_status(update_message)

func update_download_progress(now_msec: int = -1) -> void:
	if update_state != "downloading" or update_request == null:
		return
	if now_msec >= 0 and now_msec < next_update_progress_msec:
		return
	update_downloaded_bytes = update_request.get_downloaded_bytes()
	update_total_bytes = update_request.get_body_size()
	if now_msec >= 0:
		next_update_progress_msec = now_msec + UPDATE_PROGRESS_INTERVAL_MSEC
	refresh_update_dialog()

func _on_update_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if update_request_mode == "manifest":
		handle_update_manifest_completed(result, response_code, body)
		return
	update_downloaded_bytes = update_request.get_downloaded_bytes()
	update_total_bytes = update_request.get_body_size()
	update_request.download_file = ""
	update_request_mode = "idle"
	if result == HTTPRequest.RESULT_SUCCESS and response_code >= 200 and response_code < 300 and FileAccess.file_exists(update_file_path):
		if verify_downloaded_update():
			update_state = "ready"
			update_message = "v%s 升级包下载完成。" % update_remote_version
	else:
		update_state = "error"
		if response_code > 0:
			update_message = "下载失败：HTTP %d，结果码 %d。" % [response_code, result]
		else:
			update_message = "下载失败：结果码 %d。" % result
		if FileAccess.file_exists(update_file_path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(update_file_path))
	refresh_update_dialog()
	set_status(update_message)

func verify_downloaded_update() -> bool:
	if update_remote_sha256.strip_edges() == "":
		return true
	var expected = update_remote_sha256.strip_edges().to_lower()
	if not is_valid_sha256(expected):
		update_state = "error"
		update_message = "manifest SHA-256 格式无效。"
		remove_downloaded_update_file()
		return false
	var actual = file_sha256(update_file_path)
	if actual == "":
		update_state = "error"
		update_message = "无法读取下载包校验 SHA-256。"
		remove_downloaded_update_file()
		return false
	if actual != expected:
		update_state = "error"
		update_message = "下载包 SHA-256 不匹配，已删除。"
		remove_downloaded_update_file()
		return false
	return true

func remove_downloaded_update_file() -> void:
	if FileAccess.file_exists(update_file_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(update_file_path))

func is_valid_sha256(value: String) -> bool:
	if value.length() != 64:
		return false
	for i in range(value.length()):
		var ch = value.substr(i, 1)
		var is_digit = ch >= "0" and ch <= "9"
		var is_hex = ch >= "a" and ch <= "f"
		if not is_digit and not is_hex:
			return false
	return true

func file_sha256(path: String) -> String:
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	var context = HashingContext.new()
	var err = context.start(HashingContext.HASH_SHA256)
	if err != OK:
		return ""
	while not file.eof_reached():
		var chunk = file.get_buffer(65536)
		if not chunk.is_empty():
			context.update(chunk)
	return context.finish().hex_encode()

func handle_update_manifest_completed(result: int, response_code: int, body: PackedByteArray) -> void:
	update_request_mode = "idle"
	if result != HTTPRequest.RESULT_SUCCESS or response_code < 200 or response_code >= 300:
		begin_update_download(UPDATE_URL, app_version(), "manifest 暂不可用，使用备用下载。")
		return
	var parsed = JSON.parse_string(body.get_string_from_utf8())
	if typeof(parsed) != TYPE_DICTIONARY:
		begin_update_download(UPDATE_URL, app_version(), "manifest 解析失败，使用备用下载。")
		return
	var manifest = parse_update_manifest(parsed)
	if manifest.is_empty():
		begin_update_download(UPDATE_URL, app_version(), "manifest 缺少下载地址，使用备用下载。")
		return
	var remote_version = str(manifest.get("version", app_version()))
	update_remote_sha256 = str(manifest.get("sha256", ""))
	update_remote_size = int(manifest.get("size", 0))
	if not is_newer_version(remote_version, app_version()):
		update_state = "current"
		update_download_url = str(manifest.get("url", UPDATE_URL))
		update_remote_version = remote_version
		update_release_notes = str(manifest.get("notes", ""))
		update_message = "当前已是最新版本 v%s。" % app_version()
		refresh_update_dialog()
		set_status(update_message)
		return
	begin_update_download(str(manifest.get("url", UPDATE_URL)), remote_version, str(manifest.get("notes", "")))

func ensure_update_dialog() -> void:
	if update_state == "idle" or root_layer == null:
		return
	if update_dialog != null and is_instance_valid(update_dialog):
		refresh_update_dialog()
		return
	update_dialog = Control.new()
	update_dialog.set_anchors_preset(Control.PRESET_FULL_RECT)
	update_dialog.mouse_filter = Control.MOUSE_FILTER_STOP
	root_layer.add_child(update_dialog)

	var dim = ColorRect.new()
	dim.color = Color(0.0, 0.0, 0.0, 0.40)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	update_dialog.add_child(dim)

	var panel = make_panel(update_dialog, rect_full(0.325, 0.275, 0.675, 0.640), Color(0.016, 0.050, 0.058, 0.98), 18, Color(0.66, 0.54, 0.24, 0.62))
	var title = make_label(panel, "游戏更新", 22, Color(0.90, 0.82, 0.46), true)
	apply_rect(title, rect_full(0.06, 0.06, 0.94, 0.22))
	draw_update_dialog_art(panel)
	update_status_label = make_label(panel, "", 18, Color(0.84, 1.0, 0.90), false)
	apply_rect(update_status_label, rect_full(0.08, 0.25, 0.92, 0.42))
	update_progress = ProgressBar.new()
	update_progress.min_value = 0.0
	update_progress.max_value = 100.0
	update_progress.value = 0.0
	update_progress.show_percentage = false
	update_progress.mouse_filter = Control.MOUSE_FILTER_IGNORE
	update_progress.add_theme_stylebox_override("background", style(Color(0.014, 0.034, 0.038, 0.92), 10, Color(0.22, 0.30, 0.30, 0.52), 1))
	update_progress.add_theme_stylebox_override("fill", style(Color(0.16, 0.48, 0.36, 0.96), 10, Color(0.54, 0.76, 0.60, 0.34), 1))
	panel.add_child(update_progress)
	apply_rect(update_progress, rect_full(0.08, 0.45, 0.92, 0.55))
	update_progress_label = make_label(panel, "", 15, Color(0.88, 0.90, 0.78), false)
	update_progress_label.clip_contents = true
	apply_rect(update_progress_label, rect_full(0.08, 0.57, 0.92, 0.72))

	var row = HBoxContainer.new()
	configure_passive_container(row)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	panel.add_child(row)
	apply_rect(row, rect_full(0.08, 0.76, 0.92, 0.94))
	update_primary_button = make_small_button("安装", Color(0.18, 0.42, 0.34), func() -> void:
		on_update_primary_pressed()
	)
	row.add_child(update_primary_button)
	update_secondary_button = make_small_button("关闭", Color(0.26, 0.30, 0.34), func() -> void:
		on_update_secondary_pressed()
	)
	row.add_child(update_secondary_button)
	refresh_update_dialog()

func draw_update_dialog_art(parent: Control) -> Control:
	var art = Control.new()
	art.name = "UpdateDialogArt"
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(art, rect_full(0.070, 0.420, 0.930, 0.585))
	parent.add_child(art)
	var rail = make_panel(art, rect_full(0.045, 0.380, 0.955, 0.620), Color(0.014, 0.034, 0.038, 0.90), 999, Color(0.28, 0.38, 0.36, 0.46), 0)
	rail.name = "UpdateDialogArtRail"
	update_art_fill = make_panel(rail, rect_full(0.018, 0.260, 0.018, 0.740), Color(0.28, 0.68, 0.50, 0.58), 999, Color(0.64, 0.86, 0.62, 0.24), 0)
	update_art_fill.name = "UpdateDialogArtFill"
	var pack = make_panel(art, rect_full(0.012, 0.170, 0.120, 0.830), Color(0.050, 0.040, 0.026, 0.72), 12, Color(0.88, 0.72, 0.34, 0.32), 0)
	pack.name = "UpdateDialogPackageIcon"
	add_lucide_icon(pack, "download", rect_full(0.24, 0.22, 0.76, 0.78), GOLD_BRIGHT)
	update_art_status_light = make_panel(art, rect_full(0.890, 0.240, 0.956, 0.760), Color(0.42, 0.58, 0.52, 0.36), 999, Color(0.72, 0.86, 0.70, 0.24), 0)
	update_art_status_light.name = "UpdateDialogStatusLight"
	for i in range(4):
		var left = 0.170 + float(i) * 0.160
		var pip = make_panel(art, rect_full(left, 0.240, left + 0.050, 0.760), Color(0.70, 0.60, 0.34, 0.20), 999, Color(0.90, 0.78, 0.44, 0.12), 0)
		pip.name = "UpdateDialogPacketPip_%d" % i
	draw_update_dialog_stage_map(parent)
	return art

func draw_update_dialog_stage_map(parent: Control) -> Control:
	var map = Control.new()
	map.name = "UpdateDialogStageMap"
	map.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(map, rect_full(0.120, 0.720, 0.880, 0.815))
	parent.add_child(map)
	var rail = make_color_rect(rect_full(0.040, 0.480, 0.960, 0.540), Color(0.82, 0.72, 0.42, 0.16))
	rail.name = "UpdateDialogStageRail"
	map.add_child(rail)
	var stages := [
		["checking", "查"],
		["downloading", "下"],
		["ready", "验"],
		["install", "装"],
	]
	for i in range(stages.size()):
		var stage_id = str(stages[i][0])
		var label_text = str(stages[i][1])
		var center = 0.080 + float(i) * 0.280
		var node = make_panel(map, rect_full(center - 0.035, 0.180, center + 0.035, 0.820), Color(0.26, 0.36, 0.36, 0.42), 999, Color(0.54, 0.62, 0.54, 0.20), 0)
		node.name = "UpdateDialogStageNode_%s" % stage_id
		var label = make_label(node, label_text, 9, Color(0.92, 0.88, 0.70, 0.82), true)
		label.name = "UpdateDialogStageGlyph_%s" % stage_id
		apply_rect(label, rect_full(0.0, 0.0, 1.0, 1.0))
	return map

func refresh_update_dialog() -> void:
	if update_state == "idle":
		if update_dialog != null and is_instance_valid(update_dialog):
			update_dialog.queue_free()
		return
	if update_status_label == null or not is_instance_valid(update_status_label):
		return
	update_status_label.text = update_message
	if update_progress != null and is_instance_valid(update_progress):
		if update_total_bytes > 0:
			update_progress.value = clamp(float(update_downloaded_bytes) * 100.0 / float(update_total_bytes), 0.0, 100.0)
		elif update_state == "ready":
			update_progress.value = 100.0
		else:
			update_progress.value = 0.0
	if update_progress_label != null and is_instance_valid(update_progress_label):
		update_progress_label.text = update_progress_text()
	refresh_update_dialog_art()
	if update_primary_button != null and is_instance_valid(update_primary_button):
		update_primary_button.visible = update_state != "checking" and update_state != "downloading" and update_state != "current"
		update_primary_button.text = "安装" if update_state == "ready" else "重试"
	if update_secondary_button != null and is_instance_valid(update_secondary_button):
		update_secondary_button.text = "取消" if update_state == "checking" or update_state == "downloading" else "关闭"

func refresh_update_dialog_art() -> void:
	if update_art_fill != null and is_instance_valid(update_art_fill):
		var progress = 0.0
		if update_total_bytes > 0:
			progress = clamp(float(update_downloaded_bytes) / float(update_total_bytes), 0.0, 1.0)
		elif update_state == "ready" or update_state == "current":
			progress = 1.0
		apply_rect(update_art_fill, rect_full(0.018, 0.260, 0.018 + 0.964 * progress, 0.740))
	if update_art_status_light != null and is_instance_valid(update_art_status_light):
		var color = update_state_color()
		update_art_status_light.add_theme_stylebox_override("panel", style(Color(color.r, color.g, color.b, 0.34), 999, Color(color.r, color.g, color.b, 0.42), 1, 0))
	refresh_update_dialog_stage_map()

func refresh_update_dialog_stage_map() -> void:
	if update_dialog == null or not is_instance_valid(update_dialog):
		return
	var active_index = update_stage_index()
	var stages := ["checking", "downloading", "ready", "install"]
	for i in range(stages.size()):
		var stage_id = stages[i]
		var node = update_dialog.find_child("UpdateDialogStageNode_%s" % stage_id, true, false)
		if node is Panel:
			var color = update_state_color() if i <= active_index else Color(0.26, 0.36, 0.36, 1.0)
			var alpha = 0.52 if i == active_index else 0.32 if i < active_index else 0.18
			(node as Panel).add_theme_stylebox_override("panel", style(Color(color.r, color.g, color.b, alpha), 999, Color(color.r, color.g, color.b, alpha * 0.82), 1, 0))

func update_stage_index() -> int:
	match update_state:
		"checking":
			return 0
		"downloading":
			return 1
		"ready", "current":
			return 2
		"error":
			return 1
	return 3

func update_state_color() -> Color:
	match update_state:
		"downloading":
			return Color(0.34, 0.72, 0.54, 1.0)
		"ready":
			return Color(0.86, 0.70, 0.30, 1.0)
		"error":
			return Color(0.86, 0.34, 0.26, 1.0)
		"current":
			return Color(0.42, 0.62, 0.76, 1.0)
	return Color(0.60, 0.66, 0.58, 1.0)

func update_progress_text() -> String:
	if update_state == "checking":
		return "manifest " + UPDATE_MANIFEST_URL
	if update_state == "downloading":
		if update_total_bytes > 0:
			var percent = int(round(float(update_downloaded_bytes) * 100.0 / float(update_total_bytes)))
			return "%s / %s  %d%%" % [format_bytes(update_downloaded_bytes), format_bytes(update_total_bytes), percent]
		return "已下载 %s\n%s" % [format_bytes(update_downloaded_bytes), update_download_url]
	if update_state == "ready":
		return "已保存 v%s 升级包%s%s" % [update_remote_version, update_manifest_detail_text(), update_release_notes_summary()]
	if update_state == "current":
		return "远端版本 v%s%s%s" % [update_remote_version, update_manifest_detail_text(), update_release_notes_summary()]
	if update_state == "error":
		return "下载地址 " + update_download_url
	return ""

func update_manifest_detail_text() -> String:
	var parts: Array[String] = []
	if update_remote_size > 0:
		parts.append(format_bytes(update_remote_size))
	if update_remote_sha256 != "":
		parts.append("SHA-256 " + update_remote_sha256.substr(0, 12))
	if parts.is_empty():
		return ""
	return "\n" + "  ".join(parts)

func update_release_notes_summary() -> String:
	var first_line = ""
	var count = 0
	for raw_line in update_release_notes.split("\n", false):
		var line = str(raw_line).strip_edges()
		if line == "":
			continue
		count += 1
		if first_line == "":
			first_line = line
	if count <= 0:
		return ""
	if first_line.length() > UPDATE_NOTES_PREVIEW_CHARS:
		first_line = first_line.substr(0, UPDATE_NOTES_PREVIEW_CHARS).strip_edges() + "..."
	var suffix = " 等%d项" % count if count > 1 else ""
	return "\n更新说明: %s%s" % [first_line, suffix]

func on_update_primary_pressed() -> void:
	if update_state == "ready":
		open_downloaded_update()
	else:
		start_update_download()

func on_update_secondary_pressed() -> void:
	if update_state == "checking" or update_state == "downloading":
		update_request.cancel_request()
		update_request.download_file = ""
		update_request_mode = "idle"
		update_state = "error"
		update_message = "已取消更新。"
		if FileAccess.file_exists(update_file_path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(update_file_path))
		refresh_update_dialog()
		set_status(update_message)
	else:
		update_state = "idle"
		update_message = ""
		refresh_update_dialog()

func open_downloaded_update() -> void:
	if not FileAccess.file_exists(update_file_path):
		update_state = "error"
		update_message = "安装包不存在，请重新下载。"
		refresh_update_dialog()
		return
	var absolute_path = ProjectSettings.globalize_path(update_file_path)
	var err = OS.shell_open(absolute_path)
	if err != OK:
		err = OS.shell_open("file://" + absolute_path)
	if err == OK:
		update_message = "已请求系统打开安装包。"
	else:
		update_state = "error"
		update_message = "无法打开安装包：%s" % error_string(err)
	refresh_update_dialog()
	set_status(update_message)

func format_bytes(value: int) -> String:
	if value < 0:
		return "未知大小"
	var amount = float(value)
	var units = ["B", "KB", "MB", "GB"]
	var unit_index = 0
	while amount >= 1024.0 and unit_index < units.size() - 1:
		amount /= 1024.0
		unit_index += 1
	if unit_index == 0:
		return "%d %s" % [int(amount), units[unit_index]]
	return "%.1f %s" % [amount, units[unit_index]]

func app_version() -> String:
	return str(ProjectSettings.get_setting("application/config/version", APP_VERSION))

func parse_update_manifest(data: Dictionary) -> Dictionary:
	var source: Dictionary = data
	if data.has("android") and typeof(data["android"]) == TYPE_DICTIONARY:
		source = data["android"]
	var version = str(source.get("version", data.get("version", ""))).strip_edges()
	var url = str(source.get("apkUrl", source.get("apk_url", source.get("downloadUrl", source.get("url", ""))))).strip_edges()
	var notes_value = source.get("releaseNotes", source.get("notes", data.get("releaseNotes", data.get("notes", ""))))
	var notes = manifest_notes_to_text(notes_value)
	var sha256 = str(source.get("sha256", data.get("sha256", ""))).strip_edges()
	var size = int(source.get("apkSize", source.get("size", data.get("apkSize", data.get("size", 0)))))
	if url == "":
		return {}
	if version == "":
		version = app_version()
	return {
		"version": version,
		"url": url,
		"notes": notes,
		"sha256": sha256,
		"size": size,
	}

func manifest_notes_to_text(value) -> String:
	if typeof(value) == TYPE_ARRAY:
		var lines: Array[String] = []
		for item in value:
			lines.append(str(item))
		return "\n".join(lines)
	return str(value)

func is_newer_version(remote: String, current: String) -> bool:
	var remote_numbers = version_numbers(remote)
	var current_numbers = version_numbers(current)
	var count = max(remote_numbers.size(), current_numbers.size())
	for i in range(count):
		var remote_part = int(remote_numbers[i]) if i < remote_numbers.size() else 0
		var current_part = int(current_numbers[i]) if i < current_numbers.size() else 0
		if remote_part > current_part:
			return true
		if remote_part < current_part:
			return false
	return false

func version_numbers(version: String) -> Array:
	var numbers: Array = []
	var current = ""
	for i in range(version.length()):
		var ch = version.substr(i, 1)
		if ch >= "0" and ch <= "9":
			current += ch
		elif current != "":
			numbers.append(int(current))
			current = ""
	if current != "":
		numbers.append(int(current))
	if numbers.is_empty():
		numbers.append(0)
	return numbers

func safe_filename_part(text: String) -> String:
	var result = ""
	for i in range(text.length()):
		var ch = text.substr(i, 1)
		if (ch >= "0" and ch <= "9") or (ch >= "A" and ch <= "Z") or (ch >= "a" and ch <= "z") or ch == "." or ch == "-" or ch == "_":
			result += ch
		else:
			result += "_"
	return result if result != "" else app_version()

func human_discard(index: int) -> void:
	if not can_self_discard():
		return
	var hand: Array = players[0]["hand"]
	if index < 0 or index >= hand.size():
		return
	var tile = str(hand[index])
	var report = discard_report_for_tile(tile)
	if should_confirm_danger_discard(index, tile, report):
		begin_danger_discard_confirmation(index, tile, report)
		render_game()
		return
	clear_pending_danger_discard()
	play_human_discard_fly_animation(tile, index, hand.size())
	tile = discard_tile_by_index(0, index)
	render_game()
	await get_tree().process_frame
	if mode != "offline" or offline_phase != "resolving" or last_discard_seat != 0 or last_discard != tile:
		return
	resolve_after_discard(0, tile)
	if mode == "offline" and offline_phase == "await_discard" and current_seat != 0:
		run_ai_until_human()

func human_discard_by_tile(tile: String) -> void:
	if not can_self_discard() or tile == "":
		return
	var index = find_tile_in_hand(players[0]["hand"], tile)
	if index < 0:
		set_status("手牌中没有%s。" % tile_label(tile))
		return
	var report = discard_report_for_tile(tile)
	if not is_high_risk_discard_report(report):
		clear_pending_danger_discard()
	human_discard(index)

func human_claim(claim: String, chi_choice: Dictionary = {}) -> void:
	if mode != "offline" or offline_phase != "pending_claim":
		return
	clear_pending_danger_discard()
	var from_seat = int(offline_pending_claim.get("from_seat", -1))
	var tile = str(offline_pending_claim.get("tile", ""))
	if from_seat < 0 or tile == "":
		return
	if claim == "pass":
		add_log("你选择过。")
		var was_rob_gang = bool(offline_pending_claim.get("rob_gang", false))
		var prepared_ai_claim: Dictionary = offline_pending_claim.get("ai_claim", {})
		offline_pending_claim.clear()
		if was_rob_gang:
			resolve_after_rob_gang_pass(from_seat, tile, prepared_ai_claim)
		else:
			resolve_ai_or_advance(from_seat, tile)
		if offline_phase == "await_discard":
			run_ai_until_human()
		return
	var options: Array = offline_pending_claim.get("options", [])
	if not options.has(claim):
		return
	if claim == "chi" and not chi_choice.is_empty() and not is_valid_pending_chi_choice(chi_choice):
		return
	var was_rob_gang = bool(offline_pending_claim.get("rob_gang", false))
	offline_pending_claim.clear()
	if was_rob_gang and claim == "hu":
		finish_offline_round(0, tile, false, from_seat, "rob_gang")
	else:
		apply_offline_claim(0, from_seat, tile, claim, chi_choice)
	render_game()

func human_self_win() -> void:
	if mode != "offline" or not can_self_discard() or not can_win_for_seat(0):
		return
	finish_offline_round(0, str(players[0]["hand"].back()), true, -1)

func human_concealed_gang(tile: String) -> void:
	if mode != "offline" or not can_self_discard():
		return
	if count_tile(players[0]["hand"], tile) < 4:
		return
	clear_pending_danger_discard()
	perform_concealed_gang(0, tile)
	render_game()

func human_added_gang(tile: String) -> void:
	if mode != "offline" or not can_self_discard():
		return
	if not can_added_gang(0, tile):
		return
	clear_pending_danger_discard()
	perform_added_gang(0, tile)
	render_game()

func run_ai_until_human() -> void:
	if offline_ai_active:
		return
	offline_ai_active = true
	if last_discard_seat == 0:
		await pace_after_human_discard_response()
	while mode == "offline" and offline_phase == "await_discard" and current_seat != 0:
		var seat = current_seat
		if offline_turn_needs_draw:
			if wall.is_empty():
				finish_wall_draw()
				break
			await get_tree().create_timer(ai_draw_delay()).timeout
			if mode != "offline" or offline_phase != "await_discard" or current_seat != seat:
				break
			var drawn = draw_tile_for(seat)
			sort_hand(players[seat]["hand"])
			offline_turn_needs_draw = false
			if can_win_for_seat(seat):
				finish_offline_round(seat, drawn, true, -1)
				break
			var gang_tile = choose_ai_concealed_gang(seat)
			var ai_declared_gang = false
			if gang_tile != "":
				perform_concealed_gang(seat, gang_tile)
				ai_declared_gang = true
				if offline_phase == "ended":
					break
			else:
				gang_tile = choose_ai_added_gang(seat)
				if gang_tile != "":
					perform_added_gang(seat, gang_tile)
					ai_declared_gang = true
					if offline_phase == "ended":
						break
			if ai_declared_gang and mode == "offline" and offline_phase == "await_discard":
				request_game_render()
				await pace_after_visible_ai_action()
			if should_yield_before_ai_discard():
				await get_tree().process_frame
			await get_tree().create_timer(ai_discard_delay()).timeout
		if mode != "offline" or offline_phase != "await_discard" or current_seat == 0:
			break
		seat = current_seat
		var tile = choose_ai_discard_for_seat(seat)
		discard_tile_by_value(seat, tile)
		resolve_after_discard(seat, tile)
		if offline_phase == "pending_claim" or offline_phase == "ended":
			break
		if mode == "offline" and offline_phase == "await_discard":
			await pace_after_visible_ai_action(current_seat == 0)
	if mode == "offline" and offline_phase == "await_discard" and current_seat == 0 and offline_turn_needs_draw:
		if wall.is_empty():
			finish_wall_draw()
		else:
			await get_tree().create_timer(human_draw_delay()).timeout
			if mode == "offline" and offline_phase == "await_discard" and current_seat == 0:
				var drawn = draw_tile_for(0)
				sort_hand(players[0]["hand"])
				offline_turn_needs_draw = false
				if can_win_for_seat(0):
					add_log("你摸到%s，可以自摸。" % tile_label(drawn))
				else:
					add_log("轮到你出牌。")
				render_game()
	offline_ai_active = false

func discard_tile_by_index(seat: int, index: int) -> String:
	var hand: Array = players[seat]["hand"]
	var tile = str(hand[index])
	hand.remove_at(index)
	commit_discard(seat, tile)
	return tile

func discard_tile_by_value(seat: int, tile: String) -> void:
	var hand: Array = players[seat]["hand"]
	var index = find_tile_in_hand(hand, tile)
	if index < 0 and hand.size() > 0:
		index = 0
		tile = str(hand[index])
	if index >= 0:
		hand.remove_at(index)
	commit_discard(seat, tile)

func commit_discard(seat: int, tile: String) -> void:
	if seat == 0:
		clear_pending_danger_discard()
	players[seat]["discards"].append(tile)
	last_discard = tile
	last_discard_seat = seat
	offline_phase = "resolving"
	offline_turn_needs_draw = false
	play_sfx("discard", -2.5)
	play_fx_discard_ripple(seat)
	speak_tile_call(tile)
	add_log("%s打出%s。" % [players[seat]["name"], tile_label(tile)])

func resolve_after_discard(from_seat: int, tile: String) -> void:
	if mode != "offline" or offline_phase == "ended":
		return
	var ai_claim = choose_ai_claim(from_seat, tile)
	if from_seat != 0:
		var human_hand_counts = tile_counts(players[0]["hand"])
		var human_options = get_claim_options(0, from_seat, tile, human_hand_counts)
		var visible_human_options = filter_claim_options_by_priority(human_options, claim_priority(str(ai_claim.get("claim", ""))))
		if not visible_human_options.is_empty():
			offline_pending_claim = {
				"from_seat": from_seat,
				"tile": tile,
				"options": visible_human_options,
				"chi_choices": get_chi_choices_from_counts(human_hand_counts, tile) if visible_human_options.has("chi") else [],
			}
			offline_phase = "pending_claim"
			add_log("你可响应%s。" % tile_label(tile))
			# 新手引导：首次吃碰杠时显示提示
			if tutorial_step >= 0 and tutorial_step < 5:
				interactive_guide_active = true
				interactive_guide_type = "claim"
				tutorial_step = 5
				save_tutorial_state()
			render_game()
			return
	resolve_ai_or_advance(from_seat, tile, ai_claim)

func resolve_ai_or_advance(from_seat: int, tile: String, prepared_claim: Dictionary = {}) -> void:
	var claim = prepared_claim if not prepared_claim.is_empty() else choose_ai_claim(from_seat, tile)
	if not claim.is_empty():
		apply_offline_claim(int(claim.get("seat", -1)), from_seat, tile, str(claim.get("claim", "")), claim.get("chi_choice", {}))
	else:
		pass_discard_to_next(from_seat)
	request_game_render()

func filter_claim_options_by_priority(options: Array, minimum_priority: int) -> Array:
	var result: Array = []
	for option in options:
		var claim = str(option)
		if claim_priority(claim) >= minimum_priority:
			result.append(claim)
	return result

func claim_priority(claim: String) -> int:
	match claim:
		"hu":
			return 4
		"gang", "peng":
			return 3
		"chi":
			return 2
	return 0

func get_claim_options(seat: int, from_seat: int, tile: String, hand_counts_snapshot: Array = []) -> Array:
	var options: Array = []
	if seat == from_seat or offline_phase == "ended":
		return options
	var hand: Array = players[seat]["hand"] if seat >= 0 and seat < players.size() else []
	var hand_counts = hand_counts_snapshot if not hand_counts_snapshot.is_empty() else tile_counts(hand)
	if can_win_for_seat_from_counts(seat, hand_counts, tile):
		options.append("hu")
	var held_count = tile_count_from_counts(tile, hand_counts)
	if held_count >= 3:
		options.append("gang")
	if held_count >= 2:
		options.append("peng")
	if seat == (from_seat + 1) % 4 and not get_chi_choices_from_counts(hand_counts, tile).is_empty():
		options.append("chi")
	return options

func choose_ai_claim(from_seat: int, tile: String) -> Dictionary:
	var best: Dictionary = {}
	var best_score = -1.0
	var visible_counts_snapshot = visible_tile_counts()
	for offset in range(1, 4):
		var seat = (from_seat + offset) % 4
		if seat == 0:
			continue
		var hand_counts = tile_counts(players[seat]["hand"])
		var options = get_claim_options(seat, from_seat, tile, hand_counts)
		if options.is_empty():
			continue
		if options.has("hu"):
			return {"seat": seat, "claim": "hu", "score": 1000.0 - offset}
		var claim_context = make_ai_claim_context(seat, visible_counts_snapshot, hand_counts)
		if options.has("gang"):
			var gang_report = build_ai_claim_report(seat, "gang", tile, {}, claim_context)
			if not bool(gang_report.get("allow", false)):
				pass
			else:
				var gang_score = ai_claim_action_score(gang_report, offset)
				if gang_score > best_score:
					best = {"seat": seat, "claim": "gang", "score": gang_score, "claim_report": gang_report}
					best_score = gang_score
		if options.has("peng"):
			var peng_report = build_ai_claim_report(seat, "peng", tile, {}, claim_context)
			if not bool(peng_report.get("allow", false)):
				pass
			else:
				var peng_score = ai_claim_action_score(peng_report, offset)
				if peng_score > best_score:
					best = {"seat": seat, "claim": "peng", "score": peng_score, "claim_report": peng_report}
					best_score = peng_score
		if options.has("chi"):
			var chi_claim = best_ai_chi_claim(seat, tile, offset, claim_context)
			var chi_score = float(chi_claim.get("score", -1000000.0))
			if not chi_claim.is_empty() and chi_score > best_score:
				best = chi_claim
				best_score = chi_score
	return best

func best_ai_chi_claim(seat: int, tile: String, offset: int = 1, claim_context: Dictionary = {}) -> Dictionary:
	var best: Dictionary = {}
	var best_score = -1000000.0
	if seat < 0 or seat >= players.size() or tile == "":
		return best
	var choices = get_chi_choices_from_counts(claim_context.get("hand_counts", []), tile) if is_ai_claim_context_for_seat(claim_context, seat) else get_chi_choices(players[seat]["hand"], tile)
	for choice in choices:
		var chi_choice: Dictionary = choice
		var report = build_ai_claim_report(seat, "chi", tile, chi_choice, claim_context)
		if not bool(report.get("allow", false)):
			continue
		var score = ai_claim_action_score(report, offset)
		if best.is_empty() or score > best_score or (is_equal_approx(score, best_score) and ai_chi_choice_tiebreak(report) > ai_chi_choice_tiebreak(best.get("claim_report", {}))):
			best = {
				"seat": seat,
				"claim": "chi",
				"score": score,
				"chi_choice": duplicate_chi_choice(chi_choice),
				"claim_report": report,
			}
			best_score = score
	return best

func ai_chi_choice_tiebreak(report: Dictionary) -> float:
	if report.is_empty():
		return -1000000.0
	return -float(report.get("after_shanten", 8)) * 1000.0 + float(report.get("shape_gain", 0.0)) - float(report.get("forced_discard_risk", 0.0)) * 0.25

func ai_claim_action_score(report: Dictionary, offset: int) -> float:
	var claim = str(report.get("claim", ""))
	var base = 0.0
	match claim:
		"gang":
			base = 82.0
		"peng":
			base = 58.0
		"chi":
			base = 36.0
	var before_shanten = int(report.get("before_shanten", 8))
	var after_shanten = int(report.get("after_shanten", before_shanten))
	var shanten_gain = max(0, before_shanten - after_shanten)
	var shape_gain = float(report.get("shape_gain", 0.0))
	var forced_risk = float(report.get("forced_discard_risk", 0.0))
	var seat = int(report.get("seat", -1))
	var attack = ai_total_attack_multiplier(seat)
	var claim_aggression = ai_claim_aggression(seat)
	var risk_multiplier = clamp((2.0 - attack) * ai_risk_factor(seat), 0.64, 1.42)
	return base * claim_aggression - float(offset) + (float(shanten_gain) * 28.0 + clamp(shape_gain, -24.0, 96.0) * 0.05) * attack - forced_risk * 0.03 * risk_multiplier

func make_ai_claim_context(seat: int, visible_counts_snapshot: Array = [], hand_counts_snapshot: Array = []) -> Dictionary:
	if seat < 0 or seat >= players.size():
		return {}
	var hand: Array = players[seat]["hand"]
	var open_melds = players[seat]["melds"].size()
	var hand_counts = hand_counts_snapshot if not hand_counts_snapshot.is_empty() else tile_counts(hand)
	var route_focus = ai_route_focus(seat)
	var visible_counts = visible_counts_snapshot if not visible_counts_snapshot.is_empty() else visible_tile_counts()
	var eval_context = make_ai_evaluation_context(seat, visible_counts)
	var pressure_context = ai_pressure_context(seat, eval_context)
	eval_context["pressure_context"] = pressure_context
	var before_shanten = calculate_min_shanten_from_counts(hand_counts, open_melds)
	return {
		"seat": seat,
		"hand_counts": hand_counts,
		"hand_size": hand.size(),
		"open_melds": open_melds,
		"before_shanten": before_shanten,
		"before_plan_label": str(hand_plan_report_for_seat_from_counts(seat, hand_counts, hand.size()).get("label", "")),
		"route_focus": route_focus,
		"before_score": evaluate_ai_hand_from_counts(hand_counts) + hand_plan_score_from_counts(hand_counts, hand.size()) * 0.35 * route_focus,
		"visible_counts": visible_counts,
		"eval_context": eval_context,
		"pressure_context": pressure_context,
	}

func is_ai_claim_context_for_seat(claim_context: Dictionary, seat: int) -> bool:
	if claim_context.is_empty() or int(claim_context.get("seat", -1)) != seat:
		return false
	var hand_counts = claim_context.get("hand_counts", [])
	return typeof(hand_counts) == TYPE_ARRAY and not (hand_counts as Array).is_empty()

func ai_context_pressure_context(seat: int, eval_context: Dictionary = {}) -> Dictionary:
	if not eval_context.is_empty() and (not eval_context.has("seat") or int(eval_context.get("seat", -1)) == seat):
		var cached_pressure = eval_context.get("pressure_context", {})
		if typeof(cached_pressure) == TYPE_DICTIONARY and not (cached_pressure as Dictionary).is_empty():
			return cached_pressure
	var pressure_context = ai_pressure_context(seat, eval_context)
	if not eval_context.is_empty():
		eval_context["pressure_context"] = pressure_context
	return pressure_context

func build_ai_claim_report(seat: int, claim: String, tile: String, chi_choice: Dictionary = {}, claim_context: Dictionary = {}) -> Dictionary:
	var report: Dictionary = {
		"seat": seat,
		"claim": claim,
		"tile": tile,
		"allow": false,
		"reason": "非法响应",
		"before_shanten": 8,
		"after_shanten": 8,
		"shape_gain": 0.0,
		"threshold": 0.0,
		"defense": 0.0,
		"pressure": 0.0,
		"forced_discard": "",
		"forced_discard_risk": 0.0,
		"forced_discard_safety": "",
		"declined_by_pressure": false,
		"declined_by_plan": false,
		"plan_label": "",
		"chi_choice": {},
		"ai_profile": ai_profile_label(seat),
		"ai_profile_short": ai_profile_short_label(seat),
	}
	if seat < 0 or seat >= players.size() or tile == "":
		return report
	var hand: Array = players[seat]["hand"]
	var has_claim_context = is_ai_claim_context_for_seat(claim_context, seat)
	var open_melds = int(claim_context.get("open_melds", 0)) if has_claim_context else players[seat]["melds"].size()
	var hand_counts = claim_context.get("hand_counts", []) if has_claim_context else tile_counts(hand)
	var before_shanten = int(claim_context.get("before_shanten", 8)) if has_claim_context else calculate_min_shanten_from_counts(hand_counts, open_melds)
	var before_plan_label = str(claim_context.get("before_plan_label", "")) if has_claim_context else str(hand_plan_report_for_seat_from_counts(seat, hand_counts, hand.size()).get("label", ""))
	var after = hand.duplicate()
	var after_counts = hand_counts.duplicate()
	var route_focus = float(claim_context.get("route_focus", 1.0)) if has_claim_context else ai_route_focus(seat)
	var bonus = ai_claim_meld_bonus(seat, claim, tile, chi_choice)
	var threshold = ai_claim_shape_threshold(seat, claim, open_melds)
	match claim:
		"gang":
			if not consume_tile_count(after_counts, tile, 3) or not remove_known_tiles(after, tile, 3):
				return report
		"peng":
			if not consume_tile_count(after_counts, tile, 2) or not remove_known_tiles(after, tile, 2):
				return report
		"chi":
			var needed: Array = chi_choice.get("needed", [])
			if needed.is_empty() or not consume_tile_list_counts(after_counts, needed) or not remove_known_tile_list(after, needed):
				return report
			report["chi_choice"] = duplicate_chi_choice(chi_choice)
		_:
			return report
	var after_open_melds = open_melds + 1
	var after_shanten = calculate_min_shanten_from_counts(after_counts, after_open_melds)
	var before_score = float(claim_context.get("before_score", 0.0)) if has_claim_context else evaluate_ai_hand_from_counts(hand_counts) + hand_plan_score_from_counts(hand_counts, hand.size()) * 0.35 * route_focus
	var after_score = evaluate_ai_hand_from_counts(after_counts) + hand_plan_score_from_counts(after_counts, after.size()) * 0.35 * route_focus + bonus
	var shape_gain = after_score - before_score
	var allow = false
	var reason = "牌型收益不足"
	if after_shanten < before_shanten:
		allow = true
		reason = "降向听"
	elif after_shanten > before_shanten:
		reason = "升向听"
	elif shape_gain >= threshold:
		allow = true
		reason = "牌型收益"
	var declined_by_plan = false
	if open_melds == 0 and before_plan_label == "七对":
		allow = false
		reason = "保七对"
		declined_by_plan = true
	elif open_melds == 0 and seat != 0 and ai_route_focus(seat) >= 1.15 and ["清一色", "混一色", "一条龙", "十三幺"].has(before_plan_label) and after_shanten >= before_shanten and shape_gain < max(18.0, threshold * 1.2):
		allow = false
		reason = "保路线"
		declined_by_plan = true
	var pressure_report = ai_open_claim_pressure_report(seat, claim, tile, before_shanten, after_shanten, after, after_open_melds, claim_context, after_counts)
	var declined_by_pressure = allow and bool(pressure_report.get("decline", false))
	if declined_by_pressure:
		allow = false
		reason = "高压防守"
	report["allow"] = allow
	report["reason"] = reason
	report["before_shanten"] = before_shanten
	report["after_shanten"] = after_shanten
	report["shape_gain"] = shape_gain
	report["threshold"] = threshold
	report["defense"] = float(pressure_report.get("defense", 0.0))
	report["pressure"] = float(pressure_report.get("pressure", 0.0))
	report["forced_discard"] = str(pressure_report.get("discard", ""))
	report["forced_discard_risk"] = float(pressure_report.get("risk", 0.0))
	report["forced_discard_safety"] = str(pressure_report.get("safety", ""))
	report["declined_by_pressure"] = declined_by_pressure
	report["declined_by_plan"] = declined_by_plan
	report["plan_label"] = before_plan_label
	return report

func ai_claim_meld_bonus(seat: int, claim: String, tile: String, chi_choice: Dictionary = {}) -> float:
	var claim_aggression = ai_claim_aggression(seat)
	match claim:
		"gang":
			return (64.0 if is_terminal_or_honor(tile) else 48.0) * claim_aggression
		"peng":
			return (50.0 if is_terminal_or_honor(tile) else 34.0) * claim_aggression
		"chi":
			return (28.0 + float(chi_choice.get("score", 0.0)) * 0.08) * claim_aggression
	return 0.0

func ai_claim_shape_threshold(seat: int, claim: String, open_melds: int) -> float:
	var threshold = 9999.0
	match claim:
		"peng":
			threshold = 10.0 if open_melds == 0 else -4.0
		"chi":
			threshold = 14.0 if open_melds == 0 else 0.0
		"gang":
			threshold = 6.0 if open_melds == 0 else -2.0
	if threshold >= 0.0:
		return threshold / max(0.45, ai_claim_aggression(seat))
	return threshold - max(0.0, ai_claim_aggression(seat) - 1.0) * 6.0

func ai_open_claim_pressure_report(seat: int, claim: String, tile: String, before_shanten: int, after_shanten: int, after_hand: Array, after_open_melds: int, claim_context: Dictionary = {}, after_counts_snapshot: Array = []) -> Dictionary:
	var eval_context: Dictionary = {}
	var pressure_context: Dictionary = {}
	if is_ai_claim_context_for_seat(claim_context, seat):
		var shared_eval_context = claim_context.get("eval_context", {})
		if typeof(shared_eval_context) == TYPE_DICTIONARY:
			eval_context = shared_eval_context
		var shared_pressure_context = claim_context.get("pressure_context", {})
		if typeof(shared_pressure_context) == TYPE_DICTIONARY:
			pressure_context = shared_pressure_context
	if eval_context.is_empty():
		var visible_counts_snapshot = visible_tile_counts()
		eval_context = make_ai_evaluation_context(seat, visible_counts_snapshot)
	if pressure_context.is_empty():
		pressure_context = ai_context_pressure_context(seat, eval_context)
	var defense = ai_defense_weight(seat, before_shanten, pressure_context)
	var pressure = float(pressure_context.get("opponent_pressure", 0.0))
	var best_post = best_ai_post_claim_discard_report(seat, after_hand, after_open_melds, eval_context, after_counts_snapshot) if claim != "gang" else {}
	var forced_tile = str(best_post.get("tile", ""))
	var forced_risk = float(best_post.get("risk", 0.0))
	var forced_safety = str(best_post.get("safety_label", ""))
	var decline = false
	var pressure_limit = 4.6 * ai_pressure_tolerance(seat)
	var risk_limit = 27.0 * ai_pressure_tolerance(seat)
	if after_shanten >= before_shanten and before_shanten >= 2 and defense >= 1.45:
		if claim == "gang":
			decline = after_shanten > 1 and pressure >= pressure_limit and not is_terminal_or_honor(tile)
		elif forced_safety != "安":
			decline = forced_risk >= risk_limit or pressure >= pressure_limit
	return {
		"defense": defense,
		"pressure": pressure,
		"discard": forced_tile,
		"risk": forced_risk,
		"safety": forced_safety,
		"decline": decline,
	}

func best_ai_post_claim_discard_report(seat: int, after_hand: Array, open_melds: int, eval_context: Dictionary = {}, after_counts_snapshot: Array = []) -> Dictionary:
	var best: Dictionary = {}
	var visible_counts_snapshot = visible_tile_counts() if eval_context.is_empty() else ai_context_visible_counts(eval_context)
	var shared_context = make_ai_evaluation_context(seat, visible_counts_snapshot) if eval_context.is_empty() else eval_context
	var pressure_context = ai_context_pressure_context(seat, shared_context)
	var after_counts = after_counts_snapshot if not after_counts_snapshot.is_empty() else tile_counts(after_hand)
	var evaluated_tiles := {}
	var simulated = after_hand.duplicate()
	var simulated_counts = after_counts.duplicate()
	for i in range(after_hand.size()):
		var candidate = str(after_hand[i])
		if evaluated_tiles.has(candidate):
			continue
		evaluated_tiles[candidate] = true
		var candidate_index = tile_index(candidate)
		if candidate_index < 0 or candidate_index >= simulated_counts.size() or int(simulated_counts[candidate_index]) <= 0:
			continue
		simulated.remove_at(i)
		simulated_counts[candidate_index] = int(simulated_counts[candidate_index]) - 1
		var report = build_ai_discard_report(seat, candidate, simulated, open_melds, visible_counts_snapshot, pressure_context, shared_context, simulated_counts, after_counts)
		simulated_counts[candidate_index] = int(simulated_counts[candidate_index]) + 1
		simulated.insert(i, candidate)
		if best.is_empty() or float(report.get("score", -1000000.0)) > float(best.get("score", -1000000.0)):
			best = report
	return best

func apply_offline_claim(seat: int, from_seat: int, tile: String, claim: String, chi_choice: Dictionary = {}) -> void:
	if seat < 0 or seat >= players.size():
		return
	if claim == "hu":
		finish_offline_round(seat, tile, false, from_seat)
		return
	remove_last_discard(from_seat, tile)
	var hand: Array = players[seat]["hand"]
	var meld: Array = []
	match claim:
		"peng":
			if not remove_tiles(hand, tile, 2):
				pass_discard_to_next(from_seat)
				return
			meld = [tile, tile, tile]
			play_sfx("peng", -2.0)
			speak_action_call("碰", tile)
			add_log("%s碰%s。" % [players[seat]["name"], tile_label(tile)])
		"gang":
			if not remove_tiles(hand, tile, 3):
				pass_discard_to_next(from_seat)
				return
			meld = [tile, tile, tile, tile]
			play_sfx("gang", -2.0)
			speak_action_call("杠", tile)
			add_log("%s杠%s。" % [players[seat]["name"], tile_label(tile)])
			play_fx_gang_burst("open", seat)
		"chi":
			var choice = chi_choice if not chi_choice.is_empty() else best_chi_choice(hand, tile)
			if choice.is_empty():
				pass_discard_to_next(from_seat)
				return
			var needed: Array = choice.get("needed", [])
			if not remove_tile_list(hand, needed):
				pass_discard_to_next(from_seat)
				return
			meld = choice.get("meld", [])
			play_sfx("peng", -4.0)
			speak_action_call("吃", tile)
			add_log("%s吃%s。" % [players[seat]["name"], tile_label(tile)])
		_:
			pass_discard_to_next(from_seat)
			return
	players[seat]["melds"].append(meld)
	record_claim_source(seat, from_seat, claim)
	play_claim_animation(claim, tile, from_seat, seat)
	sort_hand(hand)
	last_discard = ""
	last_discard_seat = -1
	current_seat = seat
	offline_turn_needs_draw = false
	offline_phase = "await_discard"
	offline_pending_claim.clear()
	if claim == "gang":
		draw_after_gang(seat)
	play_fx_turn_switch_slide(seat)

func pass_discard_to_next(from_seat: int) -> void:
	current_seat = (from_seat + 1) % 4
	offline_turn_needs_draw = true
	offline_phase = "await_discard"
	offline_pending_claim.clear()
	play_fx_turn_switch_slide(current_seat)

func record_claim_source(claimer: int, from_seat: int, claim: String) -> void:
	if claimer < 0 or from_seat < 0 or claimer == from_seat:
		return
	if claim != "chi" and claim != "peng" and claim != "gang":
		return
	var key = claim_source_key(claimer, from_seat)
	var count = int(offline_claim_counts.get(key, 0)) + 1
	offline_claim_counts[key] = count
	if count >= 3 and not offline_package_liability.has(claimer):
		offline_package_liability[claimer] = from_seat
		add_log("%s对%s三搭成包。" % [players[from_seat]["name"], players[claimer]["name"]])

func claim_source_key(claimer: int, from_seat: int) -> String:
	return "%d:%d" % [claimer, from_seat]

func package_payer_for(winner: int) -> int:
	return int(offline_package_liability.get(winner, -1))

func remove_last_discard(seat: int, tile: String) -> void:
	var discards: Array = players[seat]["discards"]
	if not discards.is_empty() and str(discards.back()) == tile:
		discards.pop_back()
		return
	var index = find_tile_in_hand(discards, tile)
	if index >= 0:
		discards.remove_at(index)

func perform_concealed_gang(seat: int, tile: String) -> void:
	var hand: Array = players[seat]["hand"]
	if not remove_tiles(hand, tile, 4):
		return
	players[seat]["melds"].append([tile, tile, tile, tile])
	play_sfx("gang", -2.0)
	speak_action_call("暗杠", tile)
	add_log("%s暗杠%s。" % [players[seat]["name"], tile_label(tile)])
	play_fx_gang_burst("concealed", seat)
	sort_hand(hand)
	draw_after_gang(seat)

func perform_added_gang(seat: int, tile: String) -> void:
	if not can_added_gang(seat, tile):
		return
	if begin_rob_gang_resolution(seat, tile):
		return
	complete_added_gang(seat, tile)

func complete_added_gang(seat: int, tile: String) -> void:
	var hand: Array = players[seat]["hand"]
	if not remove_tiles(hand, tile, 1):
		return
	var melds: Array = players[seat]["melds"]
	for i in range(melds.size()):
		var meld: Array = melds[i]
		if is_triplet_meld(meld, tile):
			meld.append(tile)
			melds[i] = meld
			break
	play_sfx("gang", -2.0)
	speak_action_call("补杠", tile)
	add_log("%s补杠%s。" % [players[seat]["name"], tile_label(tile)])
	play_fx_gang_burst("added", seat)
	sort_hand(hand)
	draw_after_gang(seat)

func begin_rob_gang_resolution(gang_seat: int, tile: String) -> bool:
	var ai_claim = choose_ai_rob_gang(gang_seat, tile)
	if gang_seat != 0 and can_win_for_seat(0, tile):
		offline_pending_claim = {
			"from_seat": gang_seat,
			"tile": tile,
			"options": ["hu"],
			"rob_gang": true,
			"ai_claim": ai_claim,
		}
		offline_phase = "pending_claim"
		add_log("你可抢杠胡%s。" % tile_label(tile))
		render_game()
		return true
	if not ai_claim.is_empty():
		finish_offline_round(int(ai_claim.get("seat", -1)), tile, false, gang_seat, "rob_gang")
		return true
	return false

func resolve_after_rob_gang_pass(gang_seat: int, tile: String, prepared_ai_claim: Dictionary = {}) -> void:
	var ai_claim = prepared_ai_claim if not prepared_ai_claim.is_empty() else choose_ai_rob_gang(gang_seat, tile)
	if not ai_claim.is_empty():
		finish_offline_round(int(ai_claim.get("seat", -1)), tile, false, gang_seat, "rob_gang")
	else:
		complete_added_gang(gang_seat, tile)
	render_game()

func choose_ai_rob_gang(gang_seat: int, tile: String) -> Dictionary:
	for offset in range(1, 4):
		var seat = (gang_seat + offset) % 4
		if seat == gang_seat or seat == 0:
			continue
		if can_win_for_seat(seat, tile):
			return {"seat": seat, "claim": "hu", "score": 1100.0 - offset}
	return {}

func can_added_gang(seat: int, tile: String) -> bool:
	if seat < 0 or seat >= players.size() or tile == "":
		return false
	if count_tile(players[seat]["hand"], tile) <= 0:
		return false
	for meld in players[seat]["melds"]:
		if is_triplet_meld(meld, tile):
			return true
	return false

func is_triplet_meld(meld: Array, tile: String) -> bool:
	if meld.size() != 3:
		return false
	for item in meld:
		if str(item) != tile:
			return false
	return true

func draw_after_gang(seat: int) -> void:
	if wall.is_empty():
		finish_wall_draw()
		return
	var drawn = draw_tile_for(seat, true, "gang")
	sort_hand(players[seat]["hand"])
	offline_turn_needs_draw = false
	offline_phase = "await_discard"
	add_log("%s杠后补牌。" % players[seat]["name"])
	if can_win_for_seat(seat):
		finish_offline_round(seat, drawn, true, -1)

func finish_wall_draw() -> void:
	offline_phase = "ended"
	offline_turn_needs_draw = false
	offline_pending_claim.clear()
	offline_last_winner = -1
	offline_dealer_repeat = true
	last_score_deltas = [0, 0, 0, 0]
	round_summary = "荒庄，牌墙已空。%s连庄。" % players[dealer_seat]["name"]
	add_log(round_summary)
	play_fx_win_burst_enhanced("荒庄", INK_WASH, "normal")
	save_offline_progress()
	render_game()

func finish_offline_round(winner: int, win_tile: String, self_draw: bool, from_seat: int, win_context: String = "") -> void:
	play_sfx("win", -1.0)
	speak_action_call("自摸" if self_draw else "胡", win_tile)
	var score_data = calculate_win_score(winner, win_tile, self_draw, win_context)
	var fx_burst_text = ("自摸" if self_draw else "胡") + ("" if winner == 0 else " " + str(players[winner].get("name", "")))
	var fx_burst_color = GOLD_PRIMARY if winner == 0 else VERMILION
	# 判断胜利类型
	var win_type = "self_draw" if self_draw else "normal"
	if score_data.get("points", 0) >= 6:  # 高番数使用special效果
		win_type = "special"
	play_fx_win_burst_enhanced(fx_burst_text, fx_burst_color, win_type)
	var points = int(score_data.get("points", 0))
	var package_payer = package_payer_for(winner)
	var before_scores: Array[int] = []
	for seat in range(players.size()):
		before_scores.append(int(players[seat].get("score", 0)))
	var has_package_self_draw = self_draw and package_payer >= 0 and package_payer != winner
	if has_package_self_draw:
		var package_payment = points * 3
		players[package_payer]["score"] = int(players[package_payer].get("score", 0)) - package_payment
		players[winner]["score"] = int(players[winner].get("score", 0)) + package_payment
	elif self_draw:
		for seat in range(4):
			if seat == winner:
				continue
			players[seat]["score"] = int(players[seat].get("score", 0)) - points
			players[winner]["score"] = int(players[winner].get("score", 0)) + points
	else:
		var payer = from_seat if from_seat >= 0 else last_discard_seat
		var payment = points * 3
		players[payer]["score"] = int(players[payer].get("score", 0)) - payment
		players[winner]["score"] = int(players[winner].get("score", 0)) + payment
	last_score_deltas = []
	for seat in range(players.size()):
		last_score_deltas.append(int(players[seat].get("score", 0)) - int(before_scores[seat]))

	# 记录游戏统计
	var player_score_delta = int(last_score_deltas[0])
	var player_won = winner == 0
	record_game_result(player_won, player_score_delta, offline_hand_number)

	# 解锁成就
	if player_won:
		unlock_achievement("first_win")
		if self_draw:
			unlock_achievement("self_draw")
		if win_context == "rob_gang":
			unlock_achievement("rob_gang")
		# 检查特殊牌型成就
		var reasons: Array = score_data.get("reasons", [])
		if reasons.has("七对"):
			unlock_achievement("seven_pairs")
		if reasons.has("十三幺"):
			unlock_achievement("thirteen_orphans")
		if reasons.has("清一色"):
			unlock_achievement("pure_one_suit")
		if reasons.has("混一色"):
			unlock_achievement("mixed_one_suit")
		if reasons.has("大三元"):
			unlock_achievement("big_three_dragons")
		if reasons.has("小三元"):
			unlock_achievement("small_three_dragons")
		if reasons.has("大四喜"):
			unlock_achievement("big_four_winds")
		if reasons.has("小四喜"):
			unlock_achievement("small_four_winds")
		if reasons.has("字一色"):
			unlock_achievement("all_honors")
		if reasons.has("碰碰胡"):
			unlock_achievement("all_triplets")
		if reasons.has("一条龙"):
			unlock_achievement("full_straight")
		if reasons.has("门清"):
			unlock_achievement("concealed_hand")
		# 检查累计胜场成就
		var total_wins = int(game_stats.get("games_won", 0))
		if total_wins >= 5:
			unlock_achievement("five_wins")
		if total_wins >= 10:
			unlock_achievement("ten_wins")

	offline_phase = "ended"
	offline_turn_needs_draw = false
	offline_pending_claim.clear()
	current_seat = winner
	offline_last_winner = winner
	offline_dealer_repeat = winner == dealer_seat
	var limit_text = " %s" % str(score_data.get("limit_name", "")) if str(score_data.get("limit_name", "")) != "" else ""
	round_summary = "%s%s%s，%d番%s %d分。%s" % [
		players[winner]["name"],
		"自摸" if self_draw else "胡",
		tile_label(win_tile) if win_tile != "" else "",
		int(score_data.get("fan", 1)),
		limit_text,
		points,
		"、".join(score_data.get("reasons", [])),
	]
	round_summary += " %s" % ("庄家连庄。" if offline_dealer_repeat else "庄家下庄。")
	if has_package_self_draw:
		round_summary += " 包三搭：%s包赔。" % players[package_payer]["name"]
	if is_offline_match_finished():
		round_summary += " 全场结束。"

	# 保存详细得分数据用于结算页
	last_win_score = score_data.duplicate()
	last_win_score["winner"] = winner
	last_win_score["win_tile"] = win_tile
	last_win_score["self_draw"] = self_draw

	add_log(round_summary)
	save_offline_progress()
	render_game()

func is_offline_match_finished() -> bool:
	return offline_hand_number >= MATCH_MAX_HANDS

func ranked_seats_by_score() -> Array:
	var seats: Array = [0, 1, 2, 3]
	seats.sort_custom(func(a, b): return int(players[int(a)].get("score", 0)) > int(players[int(b)].get("score", 0)))
	return seats

func score_context_report(seat: int) -> Dictionary:
	if mode != "offline" or seat < 0 or seat >= players.size() or players.is_empty():
		return {}
	var ranked = ranked_seats_by_score()
	var rank = ranked.find(seat) + 1
	if rank <= 0:
		return {}
	var score = int(players[seat].get("score", 0))
	var leader = int(ranked[0])
	var leader_score = int(players[leader].get("score", 0))
	var second_score = leader_score
	if ranked.size() > 1:
		second_score = int(players[int(ranked[1])].get("score", 0))
	var lead_gap = score - second_score if rank == 1 else score - leader_score
	var late = clamp((float(offline_hand_number) - float(MATCH_MAX_HANDS - 3)) / 3.0, 0.0, 1.0)
	var strategy = "均衡"
	if late > 0.0 and rank == 1 and lead_gap >= 1200:
		strategy = "守成"
	elif late > 0.0 and rank >= 3 and lead_gap <= -1800:
		strategy = "追分"
	return {
		"rank": rank,
		"score": score,
		"leader_gap": lead_gap,
		"late": late,
		"strategy": strategy,
	}

func score_strategy_text(seat: int) -> String:
	var report = score_context_report(seat)
	if report.is_empty():
		return ""
	var rank = int(report.get("rank", 0))
	var gap = int(report.get("leader_gap", 0))
	var strategy = str(report.get("strategy", "均衡"))
	if rank == 1:
		return "分势 第1 %s %s" % ["均分" if gap == 0 else "领先%d" % gap, strategy]
	return "分势 第%d 落后%d %s" % [rank, abs(gap), strategy]

func score_defense_adjustment(seat: int) -> float:
	var report = score_context_report(seat)
	if report.is_empty():
		return 0.0
	var late = float(report.get("late", 0.0))
	if late <= 0.0:
		return 0.0
	var rank = int(report.get("rank", 0))
	var gap = int(report.get("leader_gap", 0))
	if rank == 1 and gap > 0:
		return min(0.30, 0.08 + float(gap) / 18000.0) * late
	if rank >= 3 and gap < 0:
		return -min(0.18, 0.04 + float(abs(gap)) / 26000.0) * late
	return 0.0

func score_attack_multiplier(seat: int) -> float:
	var report = score_context_report(seat)
	if report.is_empty():
		return 1.0
	var late = float(report.get("late", 0.0))
	if late <= 0.0:
		return 1.0
	var rank = int(report.get("rank", 0))
	var gap = int(report.get("leader_gap", 0))
	if rank == 1 and gap > 0:
		return clamp(1.0 - (0.06 + float(gap) / 60000.0) * late, 0.84, 1.0)
	if rank >= 3 and gap < 0:
		return clamp(1.0 + (0.08 + float(abs(gap)) / 52000.0) * late, 1.0, 1.34)
	return 1.0

func ai_profile(seat: int) -> Dictionary:
	return ai_profile_source(seat).duplicate(true)

func ai_profile_source(seat: int) -> Dictionary:
	if seat >= 0 and seat < AI_PROFILES.size():
		return AI_PROFILES[seat] as Dictionary
	return AI_PROFILES[0] as Dictionary

func ai_profile_value(seat: int, key: String, fallback: float = 1.0) -> float:
	return float(ai_profile_source(seat).get(key, fallback))

func ai_profile_label(seat: int) -> String:
	return str(ai_profile_source(seat).get("label", ""))

func ai_profile_short_label(seat: int) -> String:
	return str(ai_profile_source(seat).get("short", ""))

func ai_total_attack_multiplier(seat: int) -> float:
	return score_attack_multiplier(seat) * ai_profile_value(seat, "attack")

func ai_claim_aggression(seat: int) -> float:
	return ai_profile_value(seat, "claim")

func ai_risk_factor(seat: int) -> float:
	return ai_profile_value(seat, "risk")

func ai_route_focus(seat: int) -> float:
	return ai_profile_value(seat, "route")

func ai_wait_value_focus(seat: int) -> float:
	return ai_profile_value(seat, "wait")

func ai_gang_aggression(seat: int) -> float:
	return ai_profile_value(seat, "gang")

func ai_pressure_tolerance(seat: int) -> float:
	return ai_profile_value(seat, "pressure")

func calculate_win_score(seat: int, win_tile: String, self_draw: bool, win_context: String = "") -> Dictionary:
	var test_hand: Array = players[seat]["hand"].duplicate()
	if not self_draw and win_tile != "":
		test_hand.append(win_tile)
	return calculate_win_score_from_tiles(seat, test_hand, self_draw, win_context)

func calculate_win_score_from_tiles(seat: int, test_hand: Array, self_draw: bool, win_context: String = "") -> Dictionary:
	if seat < 0 or seat >= players.size():
		return {"fan": 0, "limit_fan": 0, "limit_name": "", "points": 0, "reasons": []}
	var fan = 1
	var reasons: Array[String] = ["平胡"]
	if self_draw:
		fan += 1
		reasons.append("自摸")
	if self_draw and is_last_draw_context(seat, "gang"):
		fan += 2
		reasons.append("杠上开花")
	if self_draw and bool(offline_last_draw.get("wall_empty", false)) and int(offline_last_draw.get("seat", -1)) == seat:
		fan += 1
		reasons.append("海底捞月")
	if win_context == "rob_gang":
		fan += 1
		reasons.append("抢杠胡")
	if seat == dealer_seat:
		fan += 1
		reasons.append("庄家")
	if int(players[seat]["flowers"]) > 0:
		fan += int(players[seat]["flowers"])
		reasons.append("花牌")
	if players[seat]["melds"].size() == 0:
		fan += 1
		reasons.append("门清")
	if players[seat]["melds"].size() == 0 and is_seven_pairs(test_hand):
		fan += 3
		reasons.append("七对")
	if players[seat]["melds"].size() == 0 and is_thirteen_orphans(test_hand):
		fan += 7
		reasons.append("十三幺")
	if is_all_honor_hand(seat, test_hand):
		fan += 5
		reasons.append("字一色")
	elif is_pure_one_suit_hand(seat, test_hand):
		fan += 3
		reasons.append("清一色")
	elif is_mixed_one_suit_hand(seat, test_hand):
		fan += 2
		reasons.append("混一色")
	if is_big_three_dragons_hand(seat, test_hand):
		fan += 6
		reasons.append("大三元")
	elif is_small_three_dragons_hand(seat, test_hand):
		fan += 4
		reasons.append("小三元")
	if is_big_four_winds_hand(seat, test_hand):
		fan += 7
		reasons.append("大四喜")
	elif is_small_four_winds_hand(seat, test_hand):
		fan += 5
		reasons.append("小四喜")
	if is_all_simples_hand(seat, test_hand):
		fan += 1
		reasons.append("断幺九")
	if is_full_straight_hand(seat, test_hand):
		fan += 2
		reasons.append("一条龙")
	if is_all_triplet_hand(seat, test_hand):
		fan += 2
		reasons.append("碰碰胡")
	if players[seat]["melds"].size() >= 4:
		fan += 2
		reasons.append("大吊车")
	var gang_count = count_gang_melds(seat)
	if gang_count > 0:
		fan += gang_count
		reasons.append("杠")
	var points = score_points_for_fan(fan)
	return {
		"fan": fan,
		"limit_fan": min(fan, SCORE_LIMIT_FAN),
		"limit_name": "封顶" if fan >= SCORE_LIMIT_FAN else "",
		"points": points,
		"reasons": reasons,
	}

func score_points_for_fan(fan: int) -> int:
	var key = clamp(fan, 1, SCORE_LIMIT_FAN)
	return int(SCORE_TABLE.get(key, SCORE_TABLE[SCORE_LIMIT_FAN]))

func is_last_draw_context(seat: int, source: String) -> bool:
	return int(offline_last_draw.get("seat", -1)) == seat and str(offline_last_draw.get("source", "")) == source

func can_win_for_seat(seat: int, extra_tile: String = "") -> bool:
	if seat < 0 or seat >= players.size():
		return false
	var tiles: Array = players[seat]["hand"].duplicate()
	if extra_tile != "":
		tiles.append(extra_tile)
	return is_complete_hand(tiles, players[seat]["melds"].size())

func can_win_for_seat_from_counts(seat: int, hand_counts: Array, extra_tile: String = "") -> bool:
	if seat < 0 or seat >= players.size() or hand_counts.is_empty():
		return false
	var counts = hand_counts
	var tile_count = players[seat]["hand"].size()
	if extra_tile != "":
		var index = tile_index(extra_tile)
		if index < 0 or index >= counts.size():
			return false
		counts = hand_counts.duplicate()
		counts[index] = int(counts[index]) + 1
		tile_count += 1
	return is_complete_hand_from_counts(counts, tile_count, players[seat]["melds"].size())

func is_complete_hand(tiles: Array, open_melds: int) -> bool:
	return is_complete_hand_from_counts(tile_counts(tiles), tiles.size(), open_melds)

func is_complete_hand_from_counts(counts: Array, tile_count: int, open_melds: int) -> bool:
	var needed_melds = 4 - open_melds
	if needed_melds < 0:
		return false
	if tile_count != needed_melds * 3 + 2:
		return false
	if open_melds == 0 and is_seven_pairs_from_counts(counts, tile_count):
		return true
	if open_melds == 0 and is_thirteen_orphans_from_counts(counts, tile_count):
		return true
	return is_standard_complete_from_counts(counts, needed_melds)

func is_seven_pairs(tiles: Array) -> bool:
	return is_seven_pairs_from_counts(tile_counts(tiles), tiles.size())

func is_seven_pairs_from_counts(counts: Array, tile_count: int) -> bool:
	if tile_count != 14:
		return false
	var pairs = 0
	for count in counts:
		if int(count) == 2:
			pairs += 1
		elif int(count) == 4:
			pairs += 2
		elif int(count) != 0:
			return false
	return pairs == 7

func is_thirteen_orphans(tiles: Array) -> bool:
	return is_thirteen_orphans_from_counts(tile_counts(tiles), tiles.size())

func is_thirteen_orphans_from_counts(counts: Array, tile_count: int) -> bool:
	if not tile_metadata_ready:
		setup_tile_order()
	if tile_count != 14:
		return false
	var unique = 0
	var has_pair = false
	for i in range(TILE_CODES.size()):
		var amount = int(counts[i])
		if amount <= 0:
			continue
		if i >= tile_order.size() or not bool(tile_thirteen_orphans_cache.get(TILE_CODES[i], false)):
			return false
		unique += 1
		if amount >= 2:
			if has_pair or amount > 2:
				return false
			has_pair = true
	return unique == THIRTEEN_ORPHANS_CODES.size() and has_pair

func is_thirteen_orphans_tile(tile: String) -> bool:
	if not tile_metadata_ready:
		setup_tile_order()
	if tile_thirteen_orphans_cache.has(tile):
		return bool(tile_thirteen_orphans_cache[tile])
	return THIRTEEN_ORPHANS_CODES.has(tile)

func is_standard_complete(tiles: Array, needed_melds: int) -> bool:
	return is_standard_complete_from_counts(tile_counts(tiles), needed_melds)

func is_standard_complete_from_counts(counts: Array, needed_melds: int) -> bool:
	var memo: Dictionary = {}
	for i in range(TILE_CODES.size()):
		if int(counts[i]) >= 2:
			counts[i] = int(counts[i]) - 2
			if can_form_sets_with_memo(counts, needed_melds, memo):
				counts[i] = int(counts[i]) + 2
				return true
			counts[i] = int(counts[i]) + 2
	return false

func can_form_sets(counts: Array, melds_needed: int) -> bool:
	var memo: Dictionary = {}
	return can_form_sets_with_memo(counts, melds_needed, memo)

func can_form_sets_with_memo(counts: Array, melds_needed: int, memo: Dictionary) -> bool:
	var first = -1
	for i in range(TILE_CODES.size()):
		if int(counts[i]) > 0:
			first = i
			break
	if first == -1:
		return melds_needed == 0
	if melds_needed <= 0:
		return false
	var memo_key = "%d:%s" % [melds_needed, counts_compact_key(counts)]
	if memo.has(memo_key):
		return bool(memo[memo_key])
	if int(counts[first]) >= 3:
		counts[first] = int(counts[first]) - 3
		if can_form_sets_with_memo(counts, melds_needed - 1, memo):
			counts[first] = int(counts[first]) + 3
			memo[memo_key] = true
			return true
		counts[first] = int(counts[first]) + 3
	if can_sequence_from(counts, first):
		counts[first] = int(counts[first]) - 1
		counts[first + 1] = int(counts[first + 1]) - 1
		counts[first + 2] = int(counts[first + 2]) - 1
		if can_form_sets_with_memo(counts, melds_needed - 1, memo):
			counts[first] = int(counts[first]) + 1
			counts[first + 1] = int(counts[first + 1]) + 1
			counts[first + 2] = int(counts[first + 2]) + 1
			memo[memo_key] = true
			return true
		counts[first] = int(counts[first]) + 1
		counts[first + 1] = int(counts[first + 1]) + 1
		counts[first + 2] = int(counts[first + 2]) + 1
	memo[memo_key] = false
	return false

func can_sequence_from(counts: Array, index: int) -> bool:
	if index < 0 or index >= 27:
		return false
	var rank = index % 9
	if rank > 6:
		return false
	return int(counts[index]) > 0 and int(counts[index + 1]) > 0 and int(counts[index + 2]) > 0

func choose_ai_discard_for_seat(seat: int) -> String:
	if seat < 0 or seat >= players.size():
		return ""
	var hand: Array = players[seat]["hand"]
	if hand.is_empty():
		return ""
	var reports = get_ai_discard_reports(seat)
	if reports.is_empty():
		return str(hand[0])
	return str(reports[0].get("tile", hand[0]))

func get_ai_discard_reports(seat: int) -> Array:
	var reports: Array = []
	if seat < 0 or seat >= players.size():
		return reports
	var hand: Array = players[seat]["hand"]
	if hand.is_empty():
		return reports
	var cache_key = ai_report_cache_key(seat)
	if ai_report_cache.has(cache_key):
		ai_report_cache_hits += 1
		return duplicate_report_array(ai_report_cache[cache_key])
	ai_report_cache_misses += 1
	var open_melds = players[seat]["melds"].size()
	var visible_counts_snapshot = visible_tile_counts()
	var eval_context = make_ai_evaluation_context(seat, visible_counts_snapshot)
	var pressure_context = ai_pressure_context(seat, eval_context)
	eval_context["pressure_context"] = pressure_context
	var hand_counts = tile_counts(hand)
	var evaluated_tiles := {}
	var simulated = hand.duplicate()
	var simulated_counts = hand_counts.duplicate()
	for i in range(hand.size()):
		var candidate = str(hand[i])
		if evaluated_tiles.has(candidate):
			continue
		evaluated_tiles[candidate] = true
		var candidate_index = tile_index(candidate)
		if candidate_index < 0 or candidate_index >= simulated_counts.size() or int(simulated_counts[candidate_index]) <= 0:
			continue
		simulated.remove_at(i)
		simulated_counts[candidate_index] = int(simulated_counts[candidate_index]) - 1
		var report = build_ai_discard_report(seat, candidate, simulated, open_melds, visible_counts_snapshot, pressure_context, eval_context, simulated_counts, hand_counts)
		reports.append(report)
		simulated_counts[candidate_index] = int(simulated_counts[candidate_index]) + 1
		simulated.insert(i, candidate)
	sort_ai_discard_reports(reports)
	store_ai_report_cache(cache_key, reports)
	return duplicate_report_array(reports)

func sort_ai_discard_reports(reports: Array) -> void:
	reports.sort_custom(func(a, b):
		var score_a = float(a.get("score", 0.0))
		var score_b = float(b.get("score", 0.0))
		if is_equal_approx(score_a, score_b):
			return tile_sort_index(str(a.get("tile", ""))) < tile_sort_index(str(b.get("tile", "")))
		return score_a > score_b
	)

func duplicate_report_array(reports: Array, copy_nested: bool = false) -> Array:
	var result: Array = []
	for report in reports:
		if typeof(report) == TYPE_DICTIONARY:
			result.append(duplicate_ai_report(report, copy_nested))
		else:
			result.append(report)
	return result

func duplicate_ai_report(report: Dictionary, copy_nested: bool = false) -> Dictionary:
	var copy: Dictionary = report.duplicate(false)
	if not copy_nested:
		return copy
	duplicate_report_array_field(copy, "effective_tiles")
	duplicate_report_array_field(copy, "wait_self_discarded")
	duplicate_report_dictionary_field(copy, "effective_remaining")
	duplicate_report_dictionary_field(copy, "danger_source")
	var feed_report = copy.get("feed_report", {})
	if typeof(feed_report) == TYPE_DICTIONARY:
		copy["feed_report"] = duplicate_feed_report(feed_report)
	return copy

func duplicate_report_array_field(report: Dictionary, key: String) -> void:
	var value = report.get(key, [])
	if typeof(value) == TYPE_ARRAY:
		report[key] = (value as Array).duplicate(false)

func duplicate_report_dictionary_field(report: Dictionary, key: String) -> void:
	var value = report.get(key, {})
	if typeof(value) == TYPE_DICTIONARY:
		report[key] = (value as Dictionary).duplicate(false)

func duplicate_feed_report(feed_report: Dictionary) -> Dictionary:
	var copy: Dictionary = feed_report.duplicate(false)
	var details = copy.get("details", [])
	if typeof(details) == TYPE_ARRAY:
		var detail_copies: Array = []
		for detail in details:
			if typeof(detail) == TYPE_DICTIONARY:
				detail_copies.append((detail as Dictionary).duplicate(false))
			else:
				detail_copies.append(detail)
		copy["details"] = detail_copies
	return copy

func duplicate_risk_vector(vector: Dictionary) -> Dictionary:
	var copy: Dictionary = vector.duplicate(false)
	duplicate_report_dictionary_field(copy, "danger_source")
	return copy

func duplicate_chi_choice(choice: Dictionary) -> Dictionary:
	var copy: Dictionary = choice.duplicate(false)
	duplicate_report_array_field(copy, "needed")
	duplicate_report_array_field(copy, "meld")
	return copy

func duplicate_claim_report(report: Dictionary) -> Dictionary:
	var copy: Dictionary = report.duplicate(false)
	var chi_choice = copy.get("chi_choice", {})
	if typeof(chi_choice) == TYPE_DICTIONARY:
		copy["chi_choice"] = duplicate_chi_choice(chi_choice)
	var declined = copy.get("declined", {})
	if typeof(declined) == TYPE_DICTIONARY and not (declined as Dictionary).is_empty():
		copy["declined"] = duplicate_claim_report(declined)
	return copy

func make_ai_evaluation_context(seat: int, visible_counts_snapshot: Array = []) -> Dictionary:
	var visible_counts = visible_counts_snapshot if not visible_counts_snapshot.is_empty() else visible_tile_counts()
	var opponents: Dictionary = {}
	for other in range(players.size()):
		if other == seat:
			continue
		opponents[other] = build_opponent_runtime_state(other)
	return {
		"seat": seat,
		"visible_counts": visible_counts,
		"opponents": opponents,
		"discard_pressures": {},
		"feed_reports": {},
		"risk_vectors": {},
		"safety_labels": {},
		"self_discard_lookup_ready": false,
		"main_threat": -2,
	}

func build_opponent_runtime_state(opponent: int) -> Dictionary:
	var state: Dictionary = {
		"discard_counts": {},
		"suit_discards": [0, 0, 0],
		"meld_count_by_suit": [0, 0, 0],
		"meld_tile_count_by_suit": [0, 0, 0],
		"honor_meld_count": 0,
		"melds": 0,
		"discards": 0,
		"suit_plan_threats": [0.0, 0.0, 0.0],
		"honor_plan_threat": 0.0,
		"plan_pressure": 0.0,
		"readiness": 0.0,
	}
	if opponent < 0 or opponent >= players.size():
		return state
	var discards: Array = players[opponent]["discards"]
	state["discards"] = discards.size()
	for item in discards:
		var tile = str(item)
		var counts: Dictionary = state["discard_counts"]
		counts[tile] = int(counts.get(tile, 0)) + 1
		var suit = tile_suit_index(tile)
		if suit >= 0 and suit < 3:
			var suit_discards: Array = state["suit_discards"]
			suit_discards[suit] = int(suit_discards[suit]) + 1
	var melds: Array = players[opponent]["melds"]
	state["melds"] = melds.size()
	for meld in melds:
		var suit_seen := [false, false, false]
		var has_honor = false
		for item in meld:
			var tile = str(item)
			var suit = tile_suit_index(tile)
			if suit >= 0 and suit < 3:
				suit_seen[suit] = true
				var tile_counts_by_suit: Array = state["meld_tile_count_by_suit"]
				tile_counts_by_suit[suit] = int(tile_counts_by_suit[suit]) + 1
			elif is_honor_tile(tile):
				has_honor = true
		for suit in range(3):
			if bool(suit_seen[suit]):
				var meld_counts_by_suit: Array = state["meld_count_by_suit"]
				meld_counts_by_suit[suit] = int(meld_counts_by_suit[suit]) + 1
		if has_honor:
			state["honor_meld_count"] = int(state["honor_meld_count"]) + 1
	var suit_plan_threats: Array = state["suit_plan_threats"]
	for suit in range(3):
		var meld_count = int((state["meld_count_by_suit"] as Array)[suit])
		if meld_count <= 0:
			suit_plan_threats[suit] = 0.0
			continue
		var meld_tiles = int((state["meld_tile_count_by_suit"] as Array)[suit])
		var suit_discards = int((state["suit_discards"] as Array)[suit])
		var off_suit_discards = max(0, discards.size() - suit_discards)
		var score = float(meld_count) * 4.0 + float(meld_tiles) * 0.70 + min(5.0, float(off_suit_discards) * 0.45)
		if meld_count >= 2:
			score += 6.0
		if meld_count >= 3:
			score += 8.0
		if suit_discards == 0:
			score += 4.0
		elif suit_discards <= 2:
			score += 1.8
		suit_plan_threats[suit] = score
	var honor_melds = int(state["honor_meld_count"])
	var honor_plan = 0.0
	if honor_melds > 0:
		honor_plan = float(honor_melds) * 5.0 + float(melds.size()) * 0.9
	state["honor_plan_threat"] = honor_plan
	var plan_pressure = honor_plan
	for suit in range(3):
		plan_pressure = max(plan_pressure, float(suit_plan_threats[suit]))
	state["plan_pressure"] = plan_pressure
	state["readiness"] = opponent_readiness_score_from_plan(opponent, plan_pressure)
	return state

func ai_context_visible_counts(eval_context: Dictionary, fallback: Array = []) -> Array:
	if not eval_context.is_empty() and eval_context.has("visible_counts"):
		var counts = eval_context.get("visible_counts", [])
		if typeof(counts) == TYPE_ARRAY and not counts.is_empty():
			return counts
	return fallback if not fallback.is_empty() else visible_tile_counts()

func ai_context_opponent_state(eval_context: Dictionary, opponent: int) -> Dictionary:
	if eval_context.is_empty() or not eval_context.has("opponents"):
		return {}
	var opponents = eval_context.get("opponents", {})
	if typeof(opponents) != TYPE_DICTIONARY or not opponents.has(opponent):
		return {}
	var state = opponents.get(opponent, {})
	return state if typeof(state) == TYPE_DICTIONARY else {}

func ai_context_self_discard_lookup(eval_context: Dictionary, seat: int) -> Dictionary:
	if not eval_context.is_empty() and bool(eval_context.get("self_discard_lookup_ready", false)):
		var cached = eval_context.get("self_discard_lookup", {})
		if typeof(cached) == TYPE_DICTIONARY:
			return cached
	if seat < 0 or seat >= players.size():
		return {}
	var lookup = tile_presence_set(players[seat]["discards"])
	if not eval_context.is_empty():
		eval_context["self_discard_lookup"] = lookup
		eval_context["self_discard_lookup_ready"] = true
	return lookup

func opponent_discard_tile_count(opponent: int, tile: String, eval_context: Dictionary = {}) -> int:
	var state = ai_context_opponent_state(eval_context, opponent)
	if not state.is_empty():
		var counts = state.get("discard_counts", {})
		if typeof(counts) == TYPE_DICTIONARY:
			return int(counts.get(tile, 0))
	if opponent < 0 or opponent >= players.size():
		return 0
	return count_tile(players[opponent]["discards"], tile)

func ai_context_cache_key(tile: String, seat: int) -> String:
	return "%d:%s" % [seat, tile]

func store_ai_report_cache(key: String, reports: Array) -> void:
	if key == "":
		return
	if not ai_report_cache.has(key):
		ai_report_cache_order.append(key)
	ai_report_cache[key] = duplicate_report_array(reports, true)
	while ai_report_cache_order.size() > AI_REPORT_CACHE_LIMIT:
		var oldest = ai_report_cache_order.pop_front()
		ai_report_cache.erase(oldest)

func clear_ai_report_cache() -> void:
	ai_report_cache.clear()
	ai_report_cache_order.clear()
	ai_report_cache_hits = 0
	ai_report_cache_misses = 0
	effective_tiles_cache.clear()
	effective_tiles_cache_order.clear()
	effective_tiles_cache_hits = 0
	effective_tiles_cache_misses = 0

func ai_report_cache_key(seat: int) -> String:
	var parts: Array[String] = [
		"seat=%d" % seat,
		"mode=" + mode,
		"phase=" + offline_phase,
		"cur=%d" % current_seat,
		"draw=%d" % (1 if offline_turn_needs_draw else 0),
		"dealer=%d" % dealer_seat,
		"handno=%d" % offline_hand_number,
		"wall=%d" % get_wall_count(),
	]
	for player_seat in range(players.size()):
		var player: Dictionary = players[player_seat]
		parts.append("p%d_score=%d" % [player_seat, int(player.get("score", 0))])
		parts.append("p%d_flowers=%d" % [player_seat, int(player.get("flowers", 0))])
		parts.append("p%d_hand=%s" % [player_seat, tile_array_key(player.get("hand", [])) if player_seat == seat else "%d" % numeric_count(player.get("hand", []), 0)])
		parts.append("p%d_disc=%s" % [player_seat, tile_array_key(player.get("discards", []))])
		parts.append("p%d_meld=%s" % [player_seat, meld_array_key(player.get("melds", []))])
	return "|".join(parts)

func tile_array_key(tiles: Array) -> String:
	if tiles.is_empty():
		return ""
	if tiles.size() <= 4:
		return small_tile_array_key(tiles)
	var counts: Dictionary = {}
	var indices: Array[int] = []
	for item in tiles:
		var index = tile_index(str(item))
		if index < 0:
			continue
		if not counts.has(index):
			counts[index] = 1
			indices.append(index)
		else:
			counts[index] = int(counts[index]) + 1
	if indices.is_empty():
		return ""
	indices.sort()
	var parts: Array[String] = []
	for i in indices:
		var amount = int(counts[i])
		if amount > 0:
			parts.append("%s%d" % [TILE_CODES[i], amount])
	return ",".join(parts)

func small_tile_array_key(tiles: Array) -> String:
	var first = -1
	var second = -1
	var third = -1
	var fourth = -1
	var valid = 0
	for item in tiles:
		var index = tile_index(str(item))
		if index < 0:
			continue
		match valid:
			0:
				first = index
			1:
				second = index
			2:
				third = index
			3:
				fourth = index
		valid += 1
	if valid == 0:
		return ""
	var swap = 0
	if valid > 1 and second < first:
		swap = first
		first = second
		second = swap
	if valid > 2:
		if third < second:
			swap = second
			second = third
			third = swap
		if second < first:
			swap = first
			first = second
			second = swap
	if valid > 3:
		if fourth < third:
			swap = third
			third = fourth
			fourth = swap
		if third < second:
			swap = second
			second = third
			third = swap
		if second < first:
			swap = first
			first = second
			second = swap
	var key = ""
	var current = first
	var amount = 1
	if valid > 1:
		if second == current:
			amount += 1
		else:
			key = append_tile_array_key_part(key, current, amount)
			current = second
			amount = 1
	if valid > 2:
		if third == current:
			amount += 1
		else:
			key = append_tile_array_key_part(key, current, amount)
			current = third
			amount = 1
	if valid > 3:
		if fourth == current:
			amount += 1
		else:
			key = append_tile_array_key_part(key, current, amount)
			current = fourth
			amount = 1
	return append_tile_array_key_part(key, current, amount)

func append_tile_array_key_part(key: String, index: int, amount: int) -> String:
	var part = TILE_CODES[index] + str(amount)
	return part if key == "" else key + "," + part

func meld_array_key(melds: Array) -> String:
	var parts: Array[String] = []
	for meld in melds:
		if typeof(meld) == TYPE_ARRAY:
			parts.append(tile_array_key(meld))
		else:
			parts.append(str(meld))
	return ";".join(parts)

func build_ai_discard_report(seat: int, tile: String, simulated: Array, open_melds: int, visible_counts_snapshot: Array = [], pressure_context: Dictionary = {}, eval_context: Dictionary = {}, simulated_counts_snapshot: Array = [], original_counts_snapshot: Array = []) -> Dictionary:
	var simulated_counts = simulated_counts_snapshot if not simulated_counts_snapshot.is_empty() else tile_counts(simulated)
	var original_counts = original_counts_snapshot
	if original_counts.is_empty():
		original_counts = simulated_counts.duplicate()
		var discarded_index = tile_index(tile)
		if discarded_index >= 0 and discarded_index < original_counts.size():
			original_counts[discarded_index] = int(original_counts[discarded_index]) + 1
	var simulated_tile_count = simulated.size()
	var visible_counts = ai_context_visible_counts(eval_context, visible_counts_snapshot)
	var shanten = calculate_min_shanten_from_counts(simulated_counts, open_melds)
	var attack = ai_total_attack_multiplier(seat)
	var route_focus = ai_route_focus(seat)
	var risk_factor = ai_risk_factor(seat)
	var metrics = effective_tile_metrics(simulated, open_melds, seat, shanten, visible_counts, simulated_counts)
	var ukeire = int(metrics.get("count", 0))
	var variety = int(metrics.get("variety", 0))
	var effective_tiles: Array = metrics.get("tiles", [])
	var effective_remaining: Dictionary = metrics.get("remaining_by_tile", {})
	var wait_value = 0.0
	var wait_best_tile = ""
	var wait_best_fan = 0
	var wait_best_points = 0
	var wait_average_points = 0.0
	var wait_total_remaining = 0
	var wait_adjusted_remaining = 0.0
	var wait_self_discarded: Array = []
	var wait_quality_text = ""
	if shanten <= 0:
		var self_discard_lookup = ai_context_self_discard_lookup(eval_context, seat)
		var wait_metrics = wait_value_metrics(seat, simulated, open_melds, shanten, effective_tiles, effective_remaining, true, self_discard_lookup, attack)
		wait_value = float(wait_metrics.get("score", 0.0))
		wait_best_tile = str(wait_metrics.get("best_tile", ""))
		wait_best_fan = int(wait_metrics.get("best_fan", 0))
		wait_best_points = int(wait_metrics.get("best_points", 0))
		wait_average_points = float(wait_metrics.get("average_points", 0.0))
		wait_total_remaining = int(wait_metrics.get("total_remaining", 0))
		wait_adjusted_remaining = float(wait_metrics.get("adjusted_remaining", 0.0))
		wait_self_discarded = wait_metrics.get("self_discarded", [])
		wait_quality_text = str(wait_metrics.get("quality_text", ""))
	var shape_metrics = ai_hand_shape_metrics_from_counts(simulated_counts)
	var shape = float(shape_metrics.get("value", 0.0))
	var shape_report: Dictionary = shape_metrics.get("quality_report", {})
	var shape_quality = float(shape_report.get("score", 0.0))
	var shape_label = hand_shape_quality_text(shape_report)
	var plan_eval = hand_plan_eval_for_seat_from_counts(seat, simulated_counts, simulated_tile_count)
	var plan = float(plan_eval.get("score", 0.0))
	var plan_report: Dictionary = plan_eval.get("report", {})
	var plan_label = str(plan_report.get("label", "标准"))
	var plan_suit = int(plan_report.get("suit", -1))
	var plan_bonus = float(plan_report.get("score_bonus", 0.0))
	var pressure = discard_pressure_score(tile, seat, visible_counts, eval_context)
	var risk_vector = tile_risk_vector(tile, seat, visible_counts, eval_context)
	var risk_summary = deal_in_risk_summary(tile, seat, visible_counts, risk_vector)
	var risk = float(risk_summary.get("score", 0.0))
	var risk_label_text = risk_label(risk)
	var feed_report = discard_feed_risk_report(tile, seat, visible_counts, eval_context)
	var feed_risk = float(feed_report.get("score", 0.0))
	var threat = opponent_tile_threat_score(tile, seat, visible_counts, risk_vector, eval_context)
	var safety = tile_safety_label(tile, seat, visible_counts, eval_context)
	var danger_source: Dictionary = risk_summary.get("danger_source", {})
	var defense = ai_defense_weight(seat, shanten, pressure_context)
	var safety_bonus = ai_safety_bonus(safety, defense, shanten)
	var emergency_defense = emergency_defense_adjustment(seat, shanten, safety, risk, feed_risk, pressure_context)
	var tenpai_bonus = 220.0 if shanten <= 0 else 0.0
	var score = -float(shanten) * 760.0
	score += (float(ukeire) * 26.0 + float(variety) * 18.0) * attack
	score += (shape * 0.30 + shape_quality * 0.42) * attack
	score += (plan * 0.42 + plan_bonus) * route_focus + tenpai_bonus * attack
	score += pressure * 1.12 - risk * defense * risk_factor + safety_bonus + emergency_defense
	score -= feed_risk * discard_feed_penalty_weight(defense, shanten) * risk_factor
	score += wait_value
	return {
		"tile": tile,
		"score": score,
		"shanten": shanten,
		"ukeire": ukeire,
		"variety": variety,
		"effective_tiles": effective_tiles,
		"effective_remaining": effective_remaining,
		"shape": shape,
		"shape_quality": shape_quality,
		"shape_label": shape_label,
		"plan": plan,
		"plan_label": plan_label,
		"plan_progress": int(plan_report.get("progress", 0)),
		"plan_suit": plan_suit,
		"plan_bonus": plan_bonus,
		"pressure": pressure,
		"risk": risk,
		"feed_risk": feed_risk,
		"feed_report": feed_report,
		"feed_text": discard_feed_risk_text(feed_report),
		"threat": threat,
		"safety_label": safety,
		"danger_source": danger_source,
		"danger_text": discard_danger_text(danger_source),
		"safety_bonus": safety_bonus,
		"emergency_defense": emergency_defense,
		"stance": ai_stance_label(defense, shanten),
		"defense": defense,
		"ai_profile": ai_profile_label(seat),
		"ai_profile_short": ai_profile_short_label(seat),
		"ai_attack_multiplier": attack,
		"ai_route_focus": route_focus,
		"ai_risk_factor": risk_factor,
		"risk_label": risk_label_text,
		"wait_value": wait_value,
		"wait_best_tile": wait_best_tile,
		"wait_best_fan": wait_best_fan,
		"wait_best_points": wait_best_points,
		"wait_average_points": wait_average_points,
		"wait_total_remaining": wait_total_remaining,
		"wait_adjusted_remaining": wait_adjusted_remaining,
		"wait_self_discarded": wait_self_discarded,
		"wait_quality_text": wait_quality_text,
		"reason_label": discard_reason_label(tile, [], {
			"safety_label": safety,
			"risk_label": risk_label_text,
			"plan_label": plan_label,
			"plan_suit": plan_suit,
			"shape_label": shape_label,
			"shanten": shanten,
			"wait_value": wait_value,
		}, original_counts),
	}

func empty_wait_value_metrics() -> Dictionary:
	var result = EMPTY_WAIT_VALUE_METRICS_TEMPLATE.duplicate(false)
	result["self_discarded"] = []
	return result

func wait_value_metrics(seat: int, hand: Array, open_melds: int, shanten: int, effective_tiles: Array, remaining_by_tile: Dictionary, effective_tiles_are_winning: bool = false, self_discarded_lookup_snapshot: Dictionary = {}, attack_multiplier_snapshot: float = -1.0, wait_focus_snapshot: float = -1.0) -> Dictionary:
	if shanten > 0 or seat < 0 or seat >= players.size():
		return empty_wait_value_metrics()
	var result = empty_wait_value_metrics()
	var attack_base = attack_multiplier_snapshot if attack_multiplier_snapshot >= 0.0 else ai_total_attack_multiplier(seat)
	var wait_focus = wait_focus_snapshot if wait_focus_snapshot >= 0.0 else ai_wait_value_focus(seat)
	result["attack_multiplier"] = attack_base
	result["wait_focus"] = wait_focus
	var total_remaining = 0
	var weighted_points = 0.0
	var adjusted_remaining = 0.0
	var self_discarded_waits: Array[String] = []
	var self_discarded_lookup = self_discarded_lookup_snapshot if not self_discarded_lookup_snapshot.is_empty() else tile_presence_set(players[seat]["discards"])
	var best_tile = ""
	var best_fan = 0
	var best_points = 0
	var best_score = 0.0
	var winning_hand = hand.duplicate()
	for item in effective_tiles:
		var tile = str(item)
		var remaining = int(remaining_by_tile.get(tile, remaining_tile_count(tile, hand)))
		if remaining <= 0:
			continue
		winning_hand.append(tile)
		if not effective_tiles_are_winning and not is_complete_hand(winning_hand, open_melds):
			winning_hand.pop_back()
			continue
		var score_data = calculate_win_score_from_tiles(seat, winning_hand, false)
		winning_hand.pop_back()
		var fan = int(score_data.get("fan", 0))
		var points = int(score_data.get("points", 0))
		var self_discarded = self_discarded_lookup.has(tile)
		var wait_weight = 0.62 if self_discarded else 1.0
		if self_discarded:
			self_discarded_waits.append(tile)
		total_remaining += remaining
		adjusted_remaining += float(remaining) * wait_weight
		weighted_points += float(points * remaining) * wait_weight
		var candidate_best_score = float(points) + float(remaining) * 24.0 - (150.0 if self_discarded else 0.0)
		if candidate_best_score > best_score:
			best_tile = tile
			best_fan = fan
			best_points = points
			best_score = candidate_best_score
	if total_remaining <= 0:
		return result
	var average_points = weighted_points / max(1.0, adjusted_remaining)
	var attack_multiplier = attack_base * wait_focus
	var quality_penalty = wait_quality_penalty(total_remaining, self_discarded_waits.size(), effective_tiles.size())
	result["best_tile"] = best_tile
	result["best_fan"] = best_fan
	result["best_points"] = best_points
	result["total_remaining"] = total_remaining
	result["adjusted_remaining"] = adjusted_remaining
	result["average_points"] = average_points
	result["self_discarded"] = self_discarded_waits
	result["quality_penalty"] = quality_penalty
	result["quality_text"] = wait_quality_text_from_values(total_remaining, self_discarded_waits)
	result["score"] = max(0.0, (adjusted_remaining * 12.0 + float(effective_tiles.size()) * 16.0 + float(result["best_points"]) * 0.04 + average_points * 0.02 - quality_penalty) * attack_multiplier)
	return result

func wait_quality_penalty(total_remaining: int, self_discarded_count: int, wait_variety: int) -> float:
	var penalty = 0.0
	if total_remaining <= 2:
		penalty += float(3 - total_remaining) * 18.0
	if self_discarded_count > 0:
		var ratio = float(self_discarded_count) / max(1.0, float(wait_variety))
		penalty += 24.0 + 34.0 * ratio + float(self_discarded_count - 1) * 10.0
	return penalty

func wait_quality_text_from_values(total_remaining: int, self_discarded_waits: Array) -> String:
	var parts: Array[String] = []
	if total_remaining > 0:
		if total_remaining <= 2:
			parts.append("待薄%d张" % total_remaining)
		elif total_remaining >= 6:
			parts.append("待厚%d张" % total_remaining)
	if not self_discarded_waits.is_empty():
		var labels: Array[String] = []
		var label_count = min(2, self_discarded_waits.size())
		for i in range(label_count):
			labels.append(tile_label(str(self_discarded_waits[i])))
		var suffix = "等" if self_discarded_waits.size() > 2 else ""
		parts.append("回头待%s%s" % ["、".join(labels), suffix])
	return " ".join(parts)

func discard_report_for_tile(tile: String) -> Dictionary:
	if not player_ai_assist_enabled() or mode != "offline" or not can_self_discard() or tile == "":
		return {}
	var reports = current_human_advice if not current_human_advice.is_empty() else get_ai_discard_reports(0)
	for report in reports:
		if typeof(report) == TYPE_DICTIONARY and str(report.get("tile", "")) == tile:
			return report
	if not current_human_advice.is_empty():
		for report in get_ai_discard_reports(0):
			if typeof(report) == TYPE_DICTIONARY and str(report.get("tile", "")) == tile:
				return report
	return {}

func is_high_risk_discard_report(report: Dictionary) -> bool:
	if report.is_empty():
		return false
	if str(report.get("safety_label", "")) != "":
		return false
	return str(report.get("risk_label", "")) == "高" or float(report.get("risk", 0.0)) >= 31.0 or float(report.get("feed_risk", 0.0)) >= 34.0

func should_confirm_danger_discard(index: int, tile: String, report: Dictionary) -> bool:
	if not player_ai_assist_enabled():
		clear_pending_danger_discard()
		return false
	if not is_high_risk_discard_report(report):
		if pending_danger_discard_tile != "":
			clear_pending_danger_discard()
		return false
	if has_pending_danger_discard() and pending_danger_discard_tile == tile:
		return false
	pending_danger_discard_index = index
	pending_danger_discard_tile = tile
	pending_danger_discard_report = duplicate_ai_report(report, true)
	return true

func begin_danger_discard_confirmation(index: int, tile: String, report: Dictionary) -> void:
	pending_danger_discard_index = index
	pending_danger_discard_tile = tile
	pending_danger_discard_report = duplicate_ai_report(report, true)
	var message = pending_danger_discard_text()
	add_log(message)
	set_status(message)

func has_pending_danger_discard() -> bool:
	if not player_ai_assist_enabled():
		return false
	if pending_danger_discard_tile == "":
		return false
	if mode != "offline" or not can_self_discard():
		return false
	return count_tile(players[0]["hand"], pending_danger_discard_tile) > 0

func clear_pending_danger_discard() -> void:
	pending_danger_discard_index = -1
	pending_danger_discard_tile = ""
	pending_danger_discard_report.clear()

func pending_danger_discard_text() -> String:
	if pending_danger_discard_tile == "":
		return current_status_text()
	var report = pending_danger_discard_report if not pending_danger_discard_report.is_empty() else discard_report_for_tile(pending_danger_discard_tile)
	var alternatives = safe_discard_alternative_text(pending_danger_discard_tile)
	var details = discard_safety_text(report) if not report.is_empty() else "风险高"
	return "高危：再点确认打出%s · %s%s" % [
		tile_label(pending_danger_discard_tile),
		details,
		" · 可改打" + alternatives if alternatives != "" else "",
	]

func safe_discard_alternative_text(excluded_tile: String, limit: int = 2) -> String:
	var text := ""
	for report in safe_discard_alternative_reports(excluded_tile, limit):
		if text != "":
			text += "、"
		text += tile_label(str(report.get("tile", "")))
	return text

func safe_discard_alternative_reports(excluded_tile: String, limit: int = 2) -> Array:
	var result: Array = []
	if not player_ai_assist_enabled():
		return result
	var reports = current_human_advice if not current_human_advice.is_empty() else get_ai_discard_reports(0)
	for report in reports:
		if typeof(report) != TYPE_DICTIONARY:
			continue
		var tile = str(report.get("tile", ""))
		if tile == "" or tile == excluded_tile or count_tile(players[0]["hand"], tile) <= 0:
			continue
		var safety = str(report.get("safety_label", ""))
		var risk = str(report.get("risk_label", ""))
		if safety == "安" or safety == "现" or safety == "熟" or safety == "筋" or safety == "壁" or risk == "低":
			result.append(duplicate_ai_report(report, true))
		if result.size() >= limit:
			break
	return result

func safe_discard_button_color(report: Dictionary) -> Color:
	var safety = str(report.get("safety_label", ""))
	if safety != "":
		return tile_risk_color(safety)
	var risk = str(report.get("risk_label", "低"))
	return tile_risk_color(risk)

func safest_discard_report(excluded_tiles = []) -> Dictionary:
	if not player_ai_assist_enabled():
		return {}
	var excluded = discard_excluded_tile_set(excluded_tiles)
	var best: Dictionary = {}
	var best_score = -1000000.0
	for report in human_discard_reports():
		if typeof(report) != TYPE_DICTIONARY:
			continue
		var tile = str(report.get("tile", ""))
		if tile == "" or excluded.has(tile) or count_tile(players[0]["hand"], tile) <= 0:
			continue
		if not is_safety_candidate_report(report):
			continue
		var score = safest_discard_action_score(report)
		if best.is_empty() or score > best_score:
			best = duplicate_ai_report(report, true)
			best_score = score
	return best

func is_safety_candidate_report(report: Dictionary) -> bool:
	if report.is_empty():
		return false
	if str(report.get("safety_label", "")) != "":
		return true
	return str(report.get("risk_label", "")) == "低" and float(report.get("risk", 0.0)) < 18.0

func safest_discard_action_score(report: Dictionary) -> float:
	var base = 0.0
	match str(report.get("safety_label", "")):
		"安":
			base = 1000.0
		"现":
			base = 920.0
		"熟":
			base = 820.0
		"筋":
			base = 740.0
		"壁":
			base = 700.0
		_:
			base = 610.0 if str(report.get("risk_label", "")) == "低" else 0.0
	return base - float(report.get("risk", 0.0)) * 7.0 + float(report.get("score", 0.0)) * 0.025 + float(report.get("ukeire", 0)) * 0.4

func should_offer_safest_discard_button(recommended_report: Dictionary, safest_report: Dictionary) -> bool:
	if safest_report.is_empty() or str(safest_report.get("tile", "")) == "":
		return false
	if is_high_risk_discard_report(recommended_report):
		return true
	if str(recommended_report.get("stance", "")) == "防守" or str(safest_report.get("stance", "")) == "防守":
		return true
	var threat = opponent_threat_report(0)
	var level = str(threat.get("level", ""))
	return level == "高" or level == "危"

func safest_discard_button_text(report: Dictionary) -> String:
	return "最安%s" % tile_label(str(report.get("tile", "")))

func safest_discard_hint_text(recommended_report: Dictionary, safest_report: Dictionary) -> String:
	if not should_offer_safest_discard_button(recommended_report, safest_report):
		return ""
	var tile = str(safest_report.get("tile", ""))
	if tile == "":
		return ""
	return "最安打%s%s" % [tile_label(tile), discard_safety_text(safest_report)]

func suggest_human_discard() -> String:
	if not player_ai_assist_enabled() or mode != "offline" or not can_self_discard():
		return ""
	var reports = human_discard_reports()
	if reports.is_empty():
		return ""
	return str(reports[0].get("tile", ""))

func recommended_discard_report() -> Dictionary:
	if not player_ai_assist_enabled():
		return {}
	var reports = human_discard_reports()
	if reports.is_empty() or typeof(reports[0]) != TYPE_DICTIONARY:
		return {}
	return duplicate_ai_report(reports[0], true)

func human_discard_reports() -> Array:
	if not player_ai_assist_enabled() or mode != "offline" or not can_self_discard():
		return []
	return current_human_advice if not current_human_advice.is_empty() else get_ai_discard_reports(0)

func recommended_discard_button_text(tile: String) -> String:
	return "推荐%s" % tile_label(tile)

func recommended_discard_button_color(report: Dictionary) -> Color:
	var safety = str(report.get("safety_label", ""))
	if safety != "":
		return tile_risk_color(safety)
	if float(report.get("feed_risk", 0.0)) >= 34.0:
		return Color(0.76, 0.34, 0.18)
	var risk = str(report.get("risk_label", "低"))
	if risk == "高":
		return Color(0.76, 0.34, 0.18)
	return tile_risk_color(risk)

func discard_action_alternative_reports(excluded_tiles = [], limit: int = 2) -> Array:
	var result: Array = []
	if not player_ai_assist_enabled():
		return result
	var excluded = discard_excluded_tile_set(excluded_tiles)
	for report in human_discard_reports():
		if typeof(report) != TYPE_DICTIONARY:
			continue
		var tile = str(report.get("tile", ""))
		if tile == "" or excluded.has(tile) or count_tile(players[0]["hand"], tile) <= 0:
			continue
		if is_high_risk_discard_report(report):
			continue
		result.append(duplicate_ai_report(report, true))
		if result.size() >= limit:
			break
	return result

func discard_excluded_tile_set(excluded_tiles) -> Dictionary:
	var excluded: Dictionary = {}
	if typeof(excluded_tiles) == TYPE_ARRAY:
		for item in excluded_tiles:
			var tile = str(item)
			if tile != "":
				excluded[tile] = true
	elif str(excluded_tiles) != "":
		excluded[str(excluded_tiles)] = true
	return excluded

func alternative_discard_button_text(report: Dictionary) -> String:
	return "备%s" % tile_label(str(report.get("tile", "")))

func alternative_discard_button_color(report: Dictionary) -> Color:
	var safety = str(report.get("safety_label", ""))
	if safety != "":
		return tile_risk_color(safety)
	return tile_risk_color(str(report.get("risk_label", "低")))

func human_hint_text(limit: int = 2) -> String:
	if not player_ai_assist_enabled() or mode != "offline" or not can_self_discard():
		return current_status_text()
	var reports = human_discard_reports()
	if reports.is_empty():
		return "整理手牌"
	var best: Dictionary = reports[0]
	var parts: Array[String] = []
	parts.append("建议打%s" % tile_label(str(best.get("tile", ""))))
	parts.append(shanten_label(int(best.get("shanten", 8))))
	var reason_hint = str(best.get("reason_label", ""))
	if reason_hint != "":
		parts.append(reason_hint)
	var plan_hint = hand_plan_text(best)
	if plan_hint != "":
		parts.append(plan_hint)
	var shape_hint = str(best.get("shape_label", ""))
	if shape_hint != "":
		parts.append(shape_hint)
	parts.append("进张%d/%d" % [int(best.get("ukeire", 0)), int(best.get("variety", 0))])
	var tile_hint = effective_tile_text(best, 4)
	if tile_hint != "":
		parts.append(tile_hint)
		var value_hint = wait_value_text(best)
		if value_hint != "":
			parts.append(value_hint)
		var quality_hint = wait_quality_text(best)
		if quality_hint != "":
			parts.append(quality_hint)
		parts.append(discard_safety_text(best))
	parts.append("模式%s" % str(best.get("stance", "均衡")))
	var score_text = score_strategy_text(0)
	if score_text != "":
		parts.append(score_text)
	var safest_hint = safest_discard_hint_text(best, safest_discard_report())
	if safest_hint != "":
		parts.append(safest_hint)
	var alternatives = discard_alternative_text(reports, limit)
	if alternatives != "":
		parts.append("备选%s" % alternatives)
	var threat = opponent_threat_summary(0)
	if threat != "":
		parts.append("防守%s" % threat)
	return " · ".join(parts)

func discard_alternative_text(reports: Array, limit: int = 2) -> String:
	var options: Array[String] = []
	for i in range(1, min(reports.size(), limit + 1)):
		var report: Dictionary = reports[i]
		var reason = str(report.get("reason_label", ""))
		options.append("%s%s/%d%s%s" % [
			tile_label(str(report.get("tile", ""))),
			shanten_label(int(report.get("shanten", 8))),
			int(report.get("ukeire", 0)),
			discard_safety_short_text(report),
			"/" + reason if reason != "" else "",
		])
	return "、".join(options)

func discard_safety_short_text(report: Dictionary) -> String:
	var safety = str(report.get("safety_label", ""))
	if safety != "":
		return safety
	return str(report.get("risk_label", "中"))

func recommended_claim_report() -> Dictionary:
	if not player_ai_assist_enabled() or mode != "offline" or offline_phase != "pending_claim":
		return {}
	var options: Array = offline_pending_claim.get("options", [])
	var tile = str(offline_pending_claim.get("tile", ""))
	if bool(offline_pending_claim.get("rob_gang", false)) and options.has("hu"):
		return {"claim": "hu", "label": claim_label("hu"), "allow": true, "tile": tile}
	if options.has("hu"):
		return {"claim": "hu", "label": claim_label("hu"), "allow": true, "tile": tile}
	var candidates = human_claim_candidate_reports()
	if candidates.is_empty():
		return {"claim": "pass", "label": "过", "allow": true, "tile": tile}
	var best: Dictionary = candidates[0]
	if not bool(best.get("allow", false)):
		return {"claim": "pass", "label": "过", "allow": true, "tile": tile, "declined": duplicate_claim_report(best)}
	return duplicate_claim_report(best)

func claim_action_button_text(claim: String, chi_choice: Dictionary, recommendation: Dictionary) -> String:
	var base = chi_choice_label(chi_choice) if claim == "chi" and not chi_choice.is_empty() else claim_label(claim)
	return "荐%s" % base if is_recommended_claim_action(claim, chi_choice, recommendation) else base

func is_recommended_claim_action(claim: String, chi_choice: Dictionary, recommendation: Dictionary) -> bool:
	if recommendation.is_empty() or str(recommendation.get("claim", "")) != claim:
		return false
	if claim != "chi":
		return true
	var recommended_choice = recommendation.get("chi_choice", {})
	if typeof(recommended_choice) != TYPE_DICTIONARY:
		return chi_choice.is_empty()
	if chi_choice.is_empty():
		return false
	return same_tile_list(chi_choice.get("meld", []), recommended_choice.get("meld", [])) and same_tile_list(chi_choice.get("needed", []), recommended_choice.get("needed", []))

func claim_action_button_color(claim: String, recommended: bool) -> Color:
	return Color(0.88, 0.61, 0.20) if recommended else claim_color(claim)

func pass_claim_button_text(recommendation: Dictionary) -> String:
	return "建议过" if str(recommendation.get("claim", "")) == "pass" else "过"

func pass_claim_button_color(recommendation: Dictionary) -> Color:
	return Color(0.25, 0.58, 0.48) if str(recommendation.get("claim", "")) == "pass" else Color(0.38, 0.43, 0.44)

func human_claim_hint_text() -> String:
	if mode != "offline" or offline_phase != "pending_claim":
		return current_status_text()
	if not player_ai_assist_enabled():
		var tile = str(offline_pending_claim.get("tile", ""))
		return "可响应%s · %s" % [
			tile_label(tile) if tile != "" else "",
			claim_options_text(offline_pending_claim),
		]
	if bool(offline_pending_claim.get("rob_gang", false)):
		return "建议胡 · 抢杠机会优先确认"
	var options: Array = offline_pending_claim.get("options", [])
	var tile = str(offline_pending_claim.get("tile", ""))
	if tile == "":
		return "等待响应"
	if options.has("hu"):
		return "建议胡%s · 胡牌优先" % tile_label(tile)
	var candidates = human_claim_candidate_reports()
	if candidates.is_empty():
		return "建议过 · 没有明显收益"
	var best: Dictionary = candidates[0]
	if not bool(best.get("allow", false)):
		return "建议过 · %s" % claim_report_reason_text(best)
	var forced = str(best.get("forced_discard", ""))
	var forced_text = ""
	if forced != "":
		forced_text = " · 后续打%s %s" % [tile_label(forced), forced_discard_risk_text(best)]
	return "建议%s · %s%s" % [
		str(best.get("label", claim_label(str(best.get("claim", ""))))),
		claim_report_reason_text(best),
		forced_text,
	]

func human_claim_candidate_reports() -> Array:
	var tile = str(offline_pending_claim.get("tile", ""))
	var candidates: Array = []
	var claim_context: Dictionary = {}
	for claim in offline_pending_claim.get("options", []):
		var claim_name = str(claim)
		if claim_name == "hu":
			continue
		if claim_name == "chi":
			var chi_choices: Array = offline_pending_claim.get("chi_choices", [])
			if chi_choices.is_empty():
				if claim_context.is_empty():
					claim_context = make_ai_claim_context(0)
				var choice = best_chi_choice_from_counts(claim_context.get("hand_counts", []), tile)
				if not choice.is_empty():
					var report = build_ai_claim_report(0, "chi", tile, choice, claim_context)
					report["label"] = chi_choice_label(choice)
					report["chi_choice"] = choice
					candidates.append(report)
			else:
				for choice in chi_choices:
					if typeof(choice) != TYPE_DICTIONARY:
						continue
					if claim_context.is_empty():
						claim_context = make_ai_claim_context(0)
					var report = build_ai_claim_report(0, "chi", tile, choice, claim_context)
					report["label"] = chi_choice_label(choice)
					report["chi_choice"] = choice
					candidates.append(report)
		else:
			if claim_context.is_empty():
				claim_context = make_ai_claim_context(0)
			var report = build_ai_claim_report(0, claim_name, tile, {}, claim_context)
			report["label"] = claim_label(claim_name)
			candidates.append(report)
	candidates.sort_custom(func(a, b):
		var score_a = human_claim_report_score(a)
		var score_b = human_claim_report_score(b)
		if is_equal_approx(score_a, score_b):
			return claim_priority(str(a.get("claim", ""))) > claim_priority(str(b.get("claim", "")))
		return score_a > score_b
	)
	return candidates

func human_claim_report_score(report: Dictionary) -> float:
	var score = ai_claim_action_score(report, 0)
	if not bool(report.get("allow", false)):
		score -= 120.0
	if str(report.get("reason", "")) == "高压防守":
		score -= 80.0
	return score

func claim_report_reason_text(report: Dictionary) -> String:
	var before = int(report.get("before_shanten", 8))
	var after = int(report.get("after_shanten", 8))
	var reason = str(report.get("reason", "牌型收益不足"))
	var shape_gain = float(report.get("shape_gain", 0.0))
	if reason == "降向听":
		return "%s到%s" % [shanten_label(before), shanten_label(after)]
	if reason == "高压防守":
		return "高压防守，吃碰后风险偏高"
	if reason == "保七对":
		return "保七对，不拆对子路线"
	if reason == "牌型收益":
		return "牌型收益+%d" % int(round(shape_gain))
	if reason == "升向听":
		return "会升向听"
	return reason

func forced_discard_risk_text(report: Dictionary) -> String:
	var safety = str(report.get("forced_discard_safety", ""))
	if safety != "":
		return discard_safety_text({"safety_label": safety, "risk_label": risk_label(float(report.get("forced_discard_risk", 0.0)))})
	return "风险%s" % risk_label(float(report.get("forced_discard_risk", 0.0)))

func ai_advice_summary(seat: int, limit: int = 3) -> String:
	var reports = current_human_advice if seat == 0 and not current_human_advice.is_empty() else get_ai_discard_reports(seat)
	if reports.is_empty():
		return "整理手牌"
	var best: Dictionary = reports[0]
	var lines: Array[String] = []
	lines.append(ai_discard_brief(best))
	lines.append("模式 " + str(best.get("stance", "均衡")))
	var reason_hint = str(best.get("reason_label", ""))
	if reason_hint != "":
		lines.append("理由 " + reason_hint)
	var plan_hint = hand_plan_text(best)
	if plan_hint != "":
		lines.append(plan_hint)
	var shape_hint = str(best.get("shape_label", ""))
	if shape_hint != "":
		lines.append(shape_hint)
	var score_text = score_strategy_text(seat)
	if score_text != "":
		lines.append(score_text)
	if seat == 0:
		var safest_hint = safest_discard_hint_text(best, safest_discard_report())
		if safest_hint != "":
			lines.append(safest_hint)
	var options: Array[String] = []
	for i in range(min(limit, reports.size())):
		var report: Dictionary = reports[i]
		var reason = str(report.get("reason_label", ""))
		options.append("%s %s/%d%s" % [
			tile_label(str(report.get("tile", ""))),
			shanten_label(int(report.get("shanten", 8))),
			int(report.get("ukeire", 0)),
			"/" + reason if reason != "" else "",
		])
	var best_tiles = effective_tile_text(best, 6)
	if best_tiles != "":
		lines.append(best_tiles)
	var value_hint = wait_value_text(best)
	if value_hint != "":
		lines.append(value_hint)
	var quality_hint = wait_quality_text(best)
	if quality_hint != "":
		lines.append(quality_hint)
	lines.append("备选 " + "  ".join(options))
	var threat = opponent_threat_summary(seat)
	if threat != "":
		lines.append("防守 " + threat)
	return "\n".join(lines)

func ai_discard_brief(report: Dictionary) -> String:
	var primary_parts: Array[String] = [
		shanten_label(int(report.get("shanten", 8))),
	]
	var tile_hint = effective_tile_text(report, 3)
	var value_hint = wait_value_text(report)
	var quality_hint = wait_quality_text(report)
	var plan_hint = hand_plan_text(report)
	var shape_hint = str(report.get("shape_label", ""))
	var reason_hint = str(report.get("reason_label", ""))
	if reason_hint != "":
		primary_parts.append(reason_hint)
	if plan_hint != "":
		primary_parts.append(plan_hint)
	if shape_hint != "":
		primary_parts.append(shape_hint)
	var draw_parts: Array[String] = [
		"进张%d/%d" % [
			int(report.get("ukeire", 0)),
			int(report.get("variety", 0)),
		],
	]
	if tile_hint != "":
		draw_parts.append(tile_hint)
	if value_hint != "":
		draw_parts.append(value_hint)
	if quality_hint != "":
		draw_parts.append(quality_hint)
	return "推荐打%s · %s · %s · %s" % [
		tile_label(str(report.get("tile", ""))),
		" · ".join(primary_parts),
		" · ".join(draw_parts),
		discard_safety_text(report),
	]

func effective_tile_text(report: Dictionary, limit: int = 5) -> String:
	var tiles: Array = report.get("effective_tiles", [])
	if tiles.is_empty():
		return ""
	var remaining_by_tile: Dictionary = report.get("effective_remaining", {})
	var labels: Array[String] = []
	var label_count = min(limit, tiles.size())
	for i in range(label_count):
		labels.append(effective_tile_label(str(tiles[i]), remaining_by_tile))
	var suffix = "等%d种" % tiles.size() if tiles.size() > limit else ""
	var prefix = "听" if int(report.get("shanten", 8)) <= 0 else "进"
	return "%s%s%s" % [prefix, "、".join(labels), suffix]

func effective_tile_label(tile: String, remaining_by_tile: Dictionary) -> String:
	var remaining = int(remaining_by_tile.get(tile, 0))
	if remaining <= 0:
		return tile_label(tile)
	return "%s%d张" % [tile_label(tile), remaining]

func hand_plan_text(report: Dictionary) -> String:
	var label = str(report.get("plan_label", "标准"))
	if label == "" or label == "标准":
		return ""
	return "路线%s" % label

func discard_reason_label(tile: String, original_hand: Array, report: Dictionary, original_counts_snapshot: Array = []) -> String:
	var safety = str(report.get("safety_label", ""))
	if safety != "":
		return "防守" + discard_safety_short_text(report)
	if is_plan_offcut(tile, report, original_hand, original_counts_snapshot):
		return "保路线"
	if is_discard_isolated(tile, original_hand, original_counts_snapshot):
		return "切孤张"
	if int(report.get("shanten", 8)) <= 0 and float(report.get("wait_value", 0.0)) > 0.0:
		return "成听牌"
	if str(report.get("shape_label", "")) != "":
		return "保好形"
	return "提效率"

func is_plan_offcut(tile: String, report: Dictionary, original_hand: Array = [], original_counts_snapshot: Array = []) -> bool:
	var label = str(report.get("plan_label", "标准"))
	if label == "标准" or tile == "":
		return false
	if label == "七对":
		if not original_counts_snapshot.is_empty():
			return tile_count_from_counts(tile, original_counts_snapshot) == 1
		return not original_hand.is_empty() and count_tile(original_hand, tile) == 1
	if label == "字一色":
		return not is_honor_tile(tile)
	if label == "清一色":
		return is_number_tile(tile) and tile_suit_index(tile) != int(report.get("plan_suit", -1))
	if label == "混一色":
		return is_number_tile(tile) and tile_suit_index(tile) != int(report.get("plan_suit", -1))
	if label == "碰碰胡":
		return is_number_tile(tile) and not is_terminal_or_honor(tile)
	if label == "十三幺":
		return not is_thirteen_orphans_tile(tile)
	if label == "一条龙":
		return not is_number_tile(tile) or tile_suit_index(tile) != int(report.get("plan_suit", -1))
	if label == "断幺九":
		return not is_simple_number_tile(tile)
	if label == "大三元" or label == "小三元":
		return not DRAGON_CODES.has(tile)
	if label == "大四喜" or label == "小四喜":
		return not WIND_CODES.has(tile)
	return false

func is_discard_isolated(tile: String, original_hand: Array, original_counts_snapshot: Array = []) -> bool:
	var counts = original_counts_snapshot if not original_counts_snapshot.is_empty() else tile_counts(original_hand)
	var index = tile_index(tile)
	if index < 0:
		return false
	return is_isolated_shape_tile(counts, index)

func wait_value_text(report: Dictionary) -> String:
	if int(report.get("shanten", 8)) > 0:
		return ""
	var best_tile = str(report.get("wait_best_tile", ""))
	var points = int(report.get("wait_best_points", 0))
	var fan = int(report.get("wait_best_fan", 0))
	if best_tile == "" or points <= 0 or fan <= 0:
		return ""
	return "价值%s%d番%d分" % [tile_label(best_tile), fan, points]

func wait_quality_text(report: Dictionary) -> String:
	if int(report.get("shanten", 8)) > 0:
		return ""
	var text = str(report.get("wait_quality_text", ""))
	if text != "":
		return text
	var total_remaining = int(report.get("wait_total_remaining", 0))
	var self_discarded_waits: Array = report.get("wait_self_discarded", [])
	return wait_quality_text_from_values(total_remaining, self_discarded_waits)

func discard_safety_text(report: Dictionary) -> String:
	var feed = str(report.get("feed_text", ""))
	var suffix = " · " + feed if feed != "" else ""
	match str(report.get("safety_label", "")):
		"安":
			return "全现物" + suffix
		"现":
			return "主现物" + suffix
		"熟":
			return "熟张" + suffix
		"筋":
			return "筋线" + suffix
		"壁":
			return "壁牌" + suffix
	var danger = discard_danger_text(report.get("danger_source", {}))
	var extra_parts: Array[String] = []
	if danger != "":
		extra_parts.append(danger)
	if feed != "":
		extra_parts.append(feed)
	return "风险%s%s" % [
		str(report.get("risk_label", "中")),
		" · " + " · ".join(extra_parts) if not extra_parts.is_empty() else "",
	]

func ai_safety_bonus(safety: String, defense: float, shanten: int) -> float:
	if safety == "":
		return 0.0
	var urgency = clamp((defense - 0.70) / 1.20, 0.0, 1.0)
	if shanten <= 0:
		urgency *= 0.25
	elif shanten == 1:
		urgency *= 0.55
	var base = 22.0
	if safety == "安":
		base = 72.0
	elif safety == "现":
		base = 46.0
	elif safety == "熟":
		base = 36.0
	elif safety == "壁":
		base = 28.0
	return base * urgency

func emergency_defense_adjustment(seat: int, shanten: int, safety: String, risk: float, feed_risk: float, pressure_context: Dictionary = {}) -> float:
	if seat < 0 or seat >= players.size() or shanten <= 1:
		return 0.0
	var readiness = float(pressure_context.get("readiness_pressure", 0.0)) if pressure_context.has("readiness_pressure") else opponent_readiness_pressure_score(seat)
	var threat_rank = int(pressure_context.get("threat_rank", -1))
	if threat_rank < 0:
		var threat_level = str(opponent_threat_report(seat).get("level", ""))
		threat_rank = threat_level_rank(threat_level)
	if readiness < 9.5 and threat_rank < 2:
		return 0.0
	var scale = clamp(0.55 + max(0.0, readiness - 7.0) / 6.0 + float(threat_rank) * 0.18, 0.55, 1.85)
	var safety_value = 0.0
	match safety:
		"安":
			safety_value = 280.0
		"现":
			safety_value = 230.0
		"熟":
			safety_value = 175.0
		"筋":
			safety_value = 125.0
		"壁":
			safety_value = 110.0
	var danger_penalty = risk * 0.84 + feed_risk * 0.34
	if risk >= 31.0:
		danger_penalty += 130.0
	elif risk >= 18.0:
		danger_penalty += 58.0
	return (safety_value - danger_penalty) * scale

func ai_stance_label(defense: float, shanten: int) -> String:
	if shanten <= 0 and defense < 1.0:
		return "进攻"
	if defense >= 1.45:
		return "防守"
	if shanten <= 1:
		return "进攻"
	return "均衡"

func evaluate_ai_hand(hand: Array) -> float:
	return evaluate_ai_hand_from_counts(tile_counts(hand))

func evaluate_ai_hand_from_counts(counts: Array) -> float:
	var score = 0.0
	for i in range(TILE_CODES.size()):
		var amount = int(counts[i])
		if amount == 0:
			continue
		score += tile_base_value(i) * amount
		if amount >= 2:
			score += 22.0
		if amount >= 3:
			score += 42.0
		if amount == 4:
			score += 10.0
		if i < 27:
			if has_neighbor(counts, i, -1):
				score += 9.0
			if has_neighbor(counts, i, 1):
				score += 9.0
			if has_neighbor(counts, i, -2):
				score += 5.0
			if has_neighbor(counts, i, 2):
				score += 5.0
	for start in NUMBER_SUIT_STARTS:
		for rank in range(0, 7):
			var index = start + rank
			if int(counts[index]) > 0 and int(counts[index + 1]) > 0 and int(counts[index + 2]) > 0:
				score += 28.0
	return score

func ai_hand_shape_metrics_from_counts(counts: Array) -> Dictionary:
	var value = 0.0
	var sequences = 0
	var ryanmen = 0
	var kanchan = 0
	var penchan = 0
	var pairs = 0
	var triplets = 0
	var isolated = 0
	for i in range(TILE_CODES.size()):
		var amount = int(counts[i])
		if amount == 0:
			continue
		value += tile_base_value(i) * amount
		if amount >= 2:
			value += 22.0
			pairs += 1
		if amount >= 3:
			value += 42.0
			triplets += 1
		if amount == 4:
			value += 10.0
		if i < 27:
			if has_neighbor(counts, i, -1):
				value += 9.0
			if has_neighbor(counts, i, 1):
				value += 9.0
			if has_neighbor(counts, i, -2):
				value += 5.0
			if has_neighbor(counts, i, 2):
				value += 5.0
		if is_isolated_shape_tile(counts, i):
			isolated += amount
	for start in NUMBER_SUIT_STARTS:
		for rank in range(0, 7):
			var index = start + rank
			if int(counts[index]) > 0 and int(counts[index + 1]) > 0 and int(counts[index + 2]) > 0:
				value += 28.0
				sequences += 1
		for rank in range(0, 8):
			if int(counts[start + rank]) <= 0 or int(counts[start + rank + 1]) <= 0:
				continue
			if rank == 0 or rank == 7:
				penchan += 1
			else:
				ryanmen += 1
		for rank in range(0, 7):
			if int(counts[start + rank]) > 0 and int(counts[start + rank + 2]) > 0:
				kanchan += 1
	var quality_score = float(sequences) * 30.0 + float(ryanmen) * 24.0 + float(kanchan) * 13.0 + float(penchan) * 9.0 + float(pairs) * 14.0 + float(triplets) * 20.0 - float(isolated) * 8.0
	return {
		"value": value,
		"quality_report": {
			"score": quality_score,
			"sequences": sequences,
			"ryanmen": ryanmen,
			"kanchan": kanchan,
			"penchan": penchan,
			"pairs": pairs,
			"triplets": triplets,
			"isolated": isolated,
		},
	}

func hand_shape_quality_report(hand: Array) -> Dictionary:
	return hand_shape_quality_report_from_counts(tile_counts(hand))

func hand_shape_quality_report_from_counts(counts: Array) -> Dictionary:
	var sequences = 0
	var ryanmen = 0
	var kanchan = 0
	var penchan = 0
	var pairs = 0
	var triplets = 0
	var isolated = 0
	for i in range(TILE_CODES.size()):
		var amount = int(counts[i])
		if amount <= 0:
			continue
		if amount >= 2:
			pairs += 1
		if amount >= 3:
			triplets += 1
		if is_isolated_shape_tile(counts, i):
			isolated += amount
	for start in NUMBER_SUIT_STARTS:
		for rank in range(0, 7):
			if int(counts[start + rank]) > 0 and int(counts[start + rank + 1]) > 0 and int(counts[start + rank + 2]) > 0:
				sequences += 1
		for rank in range(0, 8):
			if int(counts[start + rank]) <= 0 or int(counts[start + rank + 1]) <= 0:
				continue
			if rank == 0 or rank == 7:
				penchan += 1
			else:
				ryanmen += 1
		for rank in range(0, 7):
			if int(counts[start + rank]) > 0 and int(counts[start + rank + 2]) > 0:
				kanchan += 1
	var score = float(sequences) * 30.0 + float(ryanmen) * 24.0 + float(kanchan) * 13.0 + float(penchan) * 9.0 + float(pairs) * 14.0 + float(triplets) * 20.0 - float(isolated) * 8.0
	return {
		"score": score,
		"sequences": sequences,
		"ryanmen": ryanmen,
		"kanchan": kanchan,
		"penchan": penchan,
		"pairs": pairs,
		"triplets": triplets,
		"isolated": isolated,
	}

func is_isolated_shape_tile(counts: Array, index: int) -> bool:
	if index < 0 or index >= TILE_CODES.size() or int(counts[index]) <= 0:
		return false
	if int(counts[index]) >= 2:
		return false
	if index >= 27:
		return true
	for delta in SHAPE_NEIGHBOR_DELTAS:
		if has_neighbor(counts, index, delta):
			return false
	return true

func hand_shape_quality_text(report: Dictionary) -> String:
	var parts: Array[String] = []
	var ryanmen = int(report.get("ryanmen", 0))
	var kanchan = int(report.get("kanchan", 0))
	var penchan = int(report.get("penchan", 0))
	var pairs = int(report.get("pairs", 0))
	if ryanmen > 0:
		parts.append("两面%d" % ryanmen)
	if kanchan > 0:
		parts.append("坎%d" % kanchan)
	if penchan > 0:
		parts.append("边%d" % penchan)
	if pairs > 0:
		parts.append("对%d" % pairs)
	if parts.is_empty():
		return ""
	return "形" + join_limited_strings(parts, " ", 3)

func calculate_min_shanten(hand: Array, open_melds: int = 0) -> int:
	return calculate_min_shanten_from_counts(tile_counts(hand), open_melds)

func calculate_min_shanten_from_counts(counts: Array, open_melds: int = 0) -> int:
	var cache_key = shanten_cache_key(counts, open_melds)
	if shanten_cache.has(cache_key):
		shanten_cache_hits += 1
		return int(shanten_cache[cache_key])
	shanten_cache_misses += 1
	var memo: Dictionary = {}
	var standard = standard_shanten_search(counts, open_melds, 0, false, memo)
	if open_melds == 0:
		standard = min(standard, seven_pairs_shanten(counts))
		standard = min(standard, thirteen_orphans_shanten(counts))
	store_shanten_cache(cache_key, standard)
	return standard

func shanten_cache_key(counts: Array, open_melds: int) -> String:
	return "%d:%s" % [open_melds, counts_compact_key(counts)]

func counts_compact_key(counts: Array) -> String:
	var bytes := PackedByteArray()
	bytes.resize(counts.size())
	for i in range(counts.size()):
		var amount = int(counts[i])
		if amount < 0 or amount > 9:
			var fallback: Array[String] = []
			for count in counts:
				fallback.append(str(int(count)))
			return "".join(fallback)
		bytes[i] = 48 + amount
	return bytes.get_string_from_ascii()

func store_shanten_cache(key: String, value: int) -> void:
	if key == "":
		return
	if not shanten_cache.has(key):
		shanten_cache_order.append(key)
	shanten_cache[key] = value
	while shanten_cache_order.size() > SHANTEN_CACHE_LIMIT:
		var oldest = shanten_cache_order.pop_front()
		shanten_cache.erase(oldest)

func clear_shanten_cache() -> void:
	shanten_cache.clear()
	shanten_cache_order.clear()
	shanten_cache_hits = 0
	shanten_cache_misses = 0

func standard_shanten_search(counts: Array, melds: int, taatsu: int, has_pair: bool, memo: Dictionary) -> int:
	var first = -1
	for i in range(TILE_CODES.size()):
		if int(counts[i]) > 0:
			first = i
			break
	if first == -1:
		var capped_taatsu = min(taatsu, max(0, 4 - melds))
		return 8 - melds * 2 - capped_taatsu - (1 if has_pair else 0)
	var key = shanten_memo_key(counts, melds, taatsu, has_pair)
	if memo.has(key):
		return int(memo[key])
	var best = 8
	counts[first] = int(counts[first]) - 1
	best = min(best, standard_shanten_search(counts, melds, taatsu, has_pair, memo))
	counts[first] = int(counts[first]) + 1
	if int(counts[first]) >= 3:
		counts[first] = int(counts[first]) - 3
		best = min(best, standard_shanten_search(counts, melds + 1, taatsu, has_pair, memo))
		counts[first] = int(counts[first]) + 3
	if can_sequence_from(counts, first):
		counts[first] = int(counts[first]) - 1
		counts[first + 1] = int(counts[first + 1]) - 1
		counts[first + 2] = int(counts[first + 2]) - 1
		best = min(best, standard_shanten_search(counts, melds + 1, taatsu, has_pair, memo))
		counts[first] = int(counts[first]) + 1
		counts[first + 1] = int(counts[first + 1]) + 1
		counts[first + 2] = int(counts[first + 2]) + 1
	if int(counts[first]) >= 2:
		counts[first] = int(counts[first]) - 2
		if not has_pair:
			best = min(best, standard_shanten_search(counts, melds, taatsu, true, memo))
		best = min(best, standard_shanten_search(counts, melds, taatsu + 1, has_pair, memo))
		counts[first] = int(counts[first]) + 2
	if first < 27:
		if same_suit_index(first, first + 1) and int(counts[first + 1]) > 0:
			counts[first] = int(counts[first]) - 1
			counts[first + 1] = int(counts[first + 1]) - 1
			best = min(best, standard_shanten_search(counts, melds, taatsu + 1, has_pair, memo))
			counts[first] = int(counts[first]) + 1
			counts[first + 1] = int(counts[first + 1]) + 1
		if same_suit_index(first, first + 2) and int(counts[first + 2]) > 0:
			counts[first] = int(counts[first]) - 1
			counts[first + 2] = int(counts[first + 2]) - 1
			best = min(best, standard_shanten_search(counts, melds, taatsu + 1, has_pair, memo))
			counts[first] = int(counts[first]) + 1
			counts[first + 2] = int(counts[first + 2]) + 1
	memo[key] = best
	return best

func shanten_memo_key(counts: Array, melds: int, taatsu: int, has_pair: bool) -> String:
	return "%d:%d:%d:%s" % [melds, taatsu, 1 if has_pair else 0, counts_compact_key(counts)]

func same_suit_index(a: int, b: int) -> bool:
	if a < 0 or b < 0 or a >= 27 or b >= 27:
		return false
	return a / 9 == b / 9

func seven_pairs_shanten(counts: Array) -> int:
	var pairs = 0
	var unique = 0
	for count in counts:
		var amount = int(count)
		if amount <= 0:
			continue
		unique += 1
		pairs += min(2, amount / 2)
	return 6 - pairs + max(0, 7 - unique)

func thirteen_orphans_shanten(counts: Array) -> int:
	if not tile_metadata_ready:
		setup_tile_order()
	var unique = 0
	var has_pair = false
	for index in thirteen_orphans_indices:
		if index < 0 or index >= counts.size():
			continue
		var amount = int(counts[index])
		if amount > 0:
			unique += 1
		if amount >= 2:
			has_pair = true
	return THIRTEEN_ORPHANS_CODES.size() - unique - (1 if has_pair else 0)

func effective_tile_count(hand: Array, open_melds: int, seat: int) -> int:
	return int(effective_tile_metrics(hand, open_melds, seat).get("count", 0))

func effective_tile_variety(hand: Array, open_melds: int, seat: int) -> int:
	return int(effective_tile_metrics(hand, open_melds, seat).get("variety", 0))

func effective_tile_metrics(hand: Array, open_melds: int, seat: int, known_shanten: int = 99, visible_counts_snapshot: Array = [], hand_counts_snapshot: Array = []) -> Dictionary:
	var hand_counts = hand_counts_snapshot if not hand_counts_snapshot.is_empty() else tile_counts(hand)
	var current_shanten = known_shanten if known_shanten != 99 else calculate_min_shanten_from_counts(hand_counts, open_melds)

	# 缓存键：向听数 + 手牌计数
	var cache_key = "%d:%d:%s" % [current_shanten, open_melds, counts_compact_key(hand_counts)]
	if effective_tiles_cache.has(cache_key):
		effective_tiles_cache_hits += 1
		# 移到最近使用
		effective_tiles_cache_order.erase(cache_key)
		effective_tiles_cache_order.append(cache_key)
		return effective_tiles_cache[cache_key]

	effective_tiles_cache_misses += 1
	var next_tile_count = hand.size() + 1
	var visible_counts = visible_counts_snapshot if not visible_counts_snapshot.is_empty() else visible_tile_counts()
	var total = 0
	var variety = 0
	var tiles: Array[String] = []
	var remaining_by_tile: Dictionary = {}
	for i in range(TILE_CODES.size()):
		var tile = TILE_CODES[i]
		var remaining = remaining_tile_count_from_counts(i, visible_counts, hand_counts)
		if remaining <= 0:
			continue
		hand_counts[i] = int(hand_counts[i]) + 1
		var improves = false
		if current_shanten <= 0:
			improves = is_complete_hand_from_counts(hand_counts, next_tile_count, open_melds)
		if not improves:
			improves = calculate_min_shanten_from_counts(hand_counts, open_melds) < current_shanten
		hand_counts[i] = int(hand_counts[i]) - 1
		if improves:
			total += remaining
			variety += 1
			tiles.append(tile)
			remaining_by_tile[tile] = remaining
	sort_effective_tiles_by_remaining(tiles, remaining_by_tile)

	var result = {"count": total, "variety": variety, "tiles": tiles, "remaining_by_tile": remaining_by_tile}

	# 存入缓存
	effective_tiles_cache[cache_key] = result
	effective_tiles_cache_order.append(cache_key)
	while effective_tiles_cache_order.size() > EFFECTIVE_TILES_CACHE_LIMIT:
		var old_key = effective_tiles_cache_order.pop_front()
		effective_tiles_cache.erase(old_key)

	return result

func sort_effective_tiles_by_remaining(tiles: Array, remaining_by_tile: Dictionary) -> void:
	tiles.sort_custom(func(a, b):
		var remaining_a = int(remaining_by_tile.get(str(a), 0))
		var remaining_b = int(remaining_by_tile.get(str(b), 0))
		if remaining_a == remaining_b:
			return tile_sort_index(str(a)) < tile_sort_index(str(b))
		return remaining_a > remaining_b
	)

func remaining_tile_count_from_counts(index: int, visible_counts: Array, hand_counts: Array) -> int:
	if index < 0 or index >= TILE_CODES.size():
		return 0
	return max(0, 4 - int(visible_counts[index]) - int(hand_counts[index]))

func remaining_tile_count(tile: String, hand: Array) -> int:
	return max(0, 4 - visible_tile_count(tile) - count_tile(hand, tile))

func hand_plan_score(hand: Array) -> float:
	return hand_plan_score_from_counts(tile_counts(hand), hand.size())

func hand_plan_score_from_counts(counts: Array, tile_count: int) -> float:
	return hand_plan_score_from_features(counts, hand_plan_features_from_counts(counts, tile_count))

func rank_mask_unique_count(mask: int) -> int:
	var total = 0
	while mask > 0:
		total += mask & 1
		mask >>= 1
	return total

func hand_plan_features_from_counts(counts: Array, tile_count: int) -> Dictionary:
	var suit_counts = [0, 0, 0]
	var suit_rank_masks = [0, 0, 0]
	var honor_count = 0
	var pair_count = 0
	var triplet_count = 0
	var unique_count = 0
	var seven_pair_slots = 0
	var single_tile_count = 0
	var orphan_unique = 0
	var orphan_tiles = 0
	var orphan_pair = false
	var simple_tiles = 0
	var terminal_honor_tiles = 0
	for i in range(TILE_CODES.size()):
		var amount = int(counts[i])
		if amount <= 0:
			continue
		unique_count += 1
		seven_pair_slots += min(2, int(amount / 2))
		if amount % 2 == 1:
			single_tile_count += 1
		if is_simple_number_tile(TILE_CODES[i]):
			simple_tiles += amount
		else:
			terminal_honor_tiles += amount
		if i < 27:
			var suit_index = int(i / 9)
			suit_counts[suit_index] = int(suit_counts[suit_index]) + amount
			suit_rank_masks[suit_index] = int(suit_rank_masks[suit_index]) | (1 << (i % 9))
		else:
			honor_count += amount
		if is_thirteen_orphans_tile(TILE_CODES[i]):
			orphan_unique += 1
			orphan_tiles += amount
			if amount >= 2:
				orphan_pair = true
		if amount >= 2:
			pair_count += 1
		if amount >= 3:
			triplet_count += 1
	var best_suit = 0
	for suit in range(1, 3):
		if int(suit_counts[suit]) > int(suit_counts[best_suit]):
			best_suit = suit
	return {
		"total": tile_count,
		"suit_counts": suit_counts,
		"suit_rank_masks": suit_rank_masks,
		"honor_count": honor_count,
		"best_suit": best_suit,
		"pair_count": pair_count,
		"triplet_count": triplet_count,
		"unique_count": unique_count,
		"seven_pair_slots": seven_pair_slots,
		"single_tile_count": single_tile_count,
		"orphan_unique": orphan_unique,
		"orphan_tiles": orphan_tiles,
		"orphan_pair": orphan_pair,
		"simple_tiles": simple_tiles,
		"terminal_honor_tiles": terminal_honor_tiles,
	}

func hand_plan_score_from_features(counts: Array, features: Dictionary) -> float:
	var tile_count = int(features.get("total", 0))
	var suit_counts: Array = features.get("suit_counts", [0, 0, 0])
	var suit_rank_masks: Array = features.get("suit_rank_masks", EMPTY_SUIT_RANK_MASKS)
	var honor_count = int(features.get("honor_count", 0))
	var pair_count = int(features.get("pair_count", 0))
	var triplet_count = int(features.get("triplet_count", 0))
	var orphan_unique = int(features.get("orphan_unique", 0))
	var orphan_tiles = int(features.get("orphan_tiles", 0))
	var orphan_pair = bool(features.get("orphan_pair", false))
	var simple_tiles = int(features.get("simple_tiles", 0))
	var terminal_honor_tiles = int(features.get("terminal_honor_tiles", 0))
	var max_suit = max(int(suit_counts[0]), max(int(suit_counts[1]), int(suit_counts[2])))
	var off_suit = tile_count - max_suit - honor_count
	var score = float(max_suit) * 2.8 + float(honor_count) * 1.3
	if max_suit >= 8 and off_suit == 0:
		score += 72.0
	elif max_suit >= 7 and off_suit <= 2:
		score += 36.0
	if max_suit + honor_count >= 10 and off_suit == 0:
		score += 46.0
	elif max_suit + honor_count >= 9 and off_suit <= 1:
		score += 22.0
	score += float(pair_count) * 8.0 + float(triplet_count) * 18.0
	if pair_count + triplet_count >= 5:
		score += 28.0
	score += seven_pairs_route_score_from_features(features) * 0.65
	var non_orphan = max(0, tile_count - orphan_tiles)
	if orphan_unique >= 9:
		score += float(orphan_unique) * 7.6 + (18.0 if orphan_pair else 0.0) - float(non_orphan) * 18.0
	var best_dragon_unique = 0
	var best_dragon_suit = 0
	for suit in range(3):
		var unique = rank_mask_unique_count(int(suit_rank_masks[suit]))
		if unique > best_dragon_unique:
			best_dragon_unique = unique
			best_dragon_suit = suit
	var dragon_off_suit = max(0, tile_count - int(suit_counts[best_dragon_suit]) - honor_count)
	if best_dragon_unique >= 6:
		score += float(best_dragon_unique) * 7.2 + float(suit_counts[best_dragon_suit]) * 1.2 - float(dragon_off_suit) * 7.0
	if simple_tiles >= 9 and terminal_honor_tiles <= 2:
		score += float(simple_tiles) * 6.2 - float(terminal_honor_tiles) * 12.0
	score += max(honor_route_score_from_counts(counts, DRAGON_CODES), honor_route_score_from_counts(counts, WIND_CODES))
	return score

func hand_plan_report_for_seat(seat: int, hand: Array) -> Dictionary:
	return hand_plan_report_for_seat_from_counts(seat, tile_counts(hand), hand.size())

func hand_plan_report_for_seat_from_counts(seat: int, counts: Array, tile_count: int) -> Dictionary:
	return hand_plan_report_for_seat_from_features(seat, counts, tile_count, hand_plan_features_from_counts(counts, tile_count))

func hand_plan_report_for_seat_from_features(seat: int, counts: Array, tile_count: int, features: Dictionary) -> Dictionary:
	var plan_counts = counts.duplicate()
	var total = tile_count
	var open_melds = 0
	if seat >= 0 and seat < players.size():
		open_melds = players[seat]["melds"].size()
		for meld in players[seat]["melds"]:
			for item in meld:
				var index = tile_index(str(item))
				if index >= 0 and index < plan_counts.size():
					plan_counts[index] = int(plan_counts[index]) + 1
					total += 1
	var report: Dictionary
	if open_melds > 0:
		report = hand_plan_report_from_counts(plan_counts, total)
	else:
		report = hand_plan_report_from_features(plan_counts, total, features)
	if open_melds > 0 and (str(report.get("label", "")) == "十三幺" or str(report.get("label", "")) == "七对"):
		report["label"] = "标准"
		report["score_bonus"] = 0.0
	return report

func hand_plan_eval_for_seat_from_counts(seat: int, counts: Array, tile_count: int) -> Dictionary:
	var features = hand_plan_features_from_counts(counts, tile_count)
	return {
		"score": hand_plan_score_from_features(counts, features),
		"report": hand_plan_report_for_seat_from_features(seat, counts, tile_count, features),
	}

func hand_plan_report(tiles: Array) -> Dictionary:
	return hand_plan_report_from_counts(tile_counts(tiles), tiles.size())

func hand_plan_report_from_counts(counts: Array, total: int) -> Dictionary:
	return hand_plan_report_from_features(counts, total, hand_plan_features_from_counts(counts, total))

func hand_plan_report_from_features(counts: Array, total: int, features: Dictionary) -> Dictionary:
	var suit_counts: Array = features.get("suit_counts", [0, 0, 0])
	var suit_rank_masks: Array = features.get("suit_rank_masks", EMPTY_SUIT_RANK_MASKS)
	var honors = int(features.get("honor_count", 0))
	var pair_count = int(features.get("pair_count", 0))
	var triplet_count = int(features.get("triplet_count", 0))
	var orphan_unique = int(features.get("orphan_unique", 0))
	var orphan_tiles = int(features.get("orphan_tiles", 0))
	var orphan_pair = bool(features.get("orphan_pair", false))
	var simple_tiles = int(features.get("simple_tiles", 0))
	var terminal_honor_tiles = int(features.get("terminal_honor_tiles", 0))
	var best_suit = int(features.get("best_suit", 0))
	var best_suit_count = int(suit_counts[best_suit])
	var off_suit = max(0, total - best_suit_count - honors)
	var best = {
		"label": "标准",
		"score": 0.0,
		"score_bonus": 0.0,
		"progress": 0,
		"suit": best_suit,
	}
	if total <= 0:
		return best
	var non_orphan = max(0, total - orphan_tiles)
	var orphan_score = float(orphan_unique) * 8.4 + (20.0 if orphan_pair else 0.0) - float(non_orphan) * 22.0
	if orphan_unique >= 9 and non_orphan <= 3 and orphan_score > float(best.get("score", 0.0)):
		best = {"label": "十三幺", "score": orphan_score, "progress": orphan_unique, "suit": -1}
	var dragon_suit = 0
	var dragon_unique = 0
	for suit in range(3):
		var unique = rank_mask_unique_count(int(suit_rank_masks[suit]))
		if unique > dragon_unique:
			dragon_unique = unique
			dragon_suit = suit
	var dragon_off_suit = max(0, total - int(suit_counts[dragon_suit]) - honors)
	var dragon_score = float(dragon_unique) * 8.0 + float(suit_counts[dragon_suit]) * 1.3 - float(dragon_off_suit) * 7.5
	if dragon_unique >= 7 and dragon_score > float(best.get("score", 0.0)):
		best = {"label": "一条龙", "score": dragon_score, "progress": dragon_unique, "suit": dragon_suit}
	var simple_score = float(simple_tiles) * 6.6 - float(terminal_honor_tiles) * 13.0
	if simple_tiles >= 10 and terminal_honor_tiles <= 1 and simple_score > float(best.get("score", 0.0)):
		best = {"label": "断幺九", "score": simple_score, "progress": simple_tiles, "suit": -1}
	var seven_pairs_report = seven_pairs_plan_report_from_features(features)
	if not seven_pairs_report.is_empty() and float(seven_pairs_report.get("score", 0.0)) > float(best.get("score", 0.0)):
		best = seven_pairs_report
	var dragon_honor_report = honor_group_plan_report_from_counts(counts, DRAGON_CODES, "大三元", "小三元")
	if not dragon_honor_report.is_empty() and float(dragon_honor_report.get("score", 0.0)) > float(best.get("score", 0.0)):
		best = dragon_honor_report
	var wind_honor_report = honor_group_plan_report_from_counts(counts, WIND_CODES, "大四喜", "小四喜")
	if not wind_honor_report.is_empty() and float(wind_honor_report.get("score", 0.0)) > float(best.get("score", 0.0)):
		best = wind_honor_report
	var honor_score = float(honors) * 8.2 - float(total - honors) * 20.0
	if honors >= 8 and honor_score > float(best.get("score", 0.0)):
		best = {"label": "字一色", "score": honor_score, "progress": honors, "suit": -1}
	var pure_score = float(best_suit_count) * 7.0 - float(off_suit) * 24.0 - float(honors) * 10.0
	if best_suit_count >= 8 and off_suit + honors <= 2 and pure_score > float(best.get("score", 0.0)):
		best = {"label": "清一色", "score": pure_score, "progress": best_suit_count, "suit": best_suit}
	var mixed_score = float(best_suit_count + honors) * 6.2 + float(honors) * 1.6 - float(off_suit) * 24.0
	if best_suit_count + honors >= 9 and honors > 0 and off_suit <= 2 and mixed_score > float(best.get("score", 0.0)):
		best = {"label": "混一色", "score": mixed_score, "progress": best_suit_count + honors, "suit": best_suit}
	var triplet_progress = pair_count + triplet_count * 2
	var triplet_score = float(pair_count) * 10.0 + float(triplet_count) * 22.0
	if triplet_progress >= 5 and triplet_score > float(best.get("score", 0.0)):
		best = {"label": "碰碰胡", "score": triplet_score, "progress": triplet_progress, "suit": -1}
	var score = float(best.get("score", 0.0))
	if score < 42.0:
		best["label"] = "标准"
		best["score_bonus"] = 0.0
	else:
		best["score_bonus"] = clamp((score - 36.0) * 0.85, 0.0, 88.0)
	return best

func seven_pairs_route_score_from_features(features: Dictionary) -> float:
	var pair_slots = int(features.get("seven_pair_slots", 0))
	if pair_slots < 4:
		return 0.0
	var unique = int(features.get("unique_count", 0))
	var single_tiles = int(features.get("single_tile_count", 0))
	var missing_unique = max(0, 7 - unique)
	var score = float(pair_slots) * 21.0 - float(single_tiles) * 6.0 - float(missing_unique) * 16.0
	if pair_slots >= 5:
		score += 36.0
	if pair_slots >= 6:
		score += 46.0
	return max(0.0, score)

func seven_pairs_plan_report_from_features(features: Dictionary) -> Dictionary:
	var score = seven_pairs_route_score_from_features(features)
	if score <= 0.0:
		return {}
	var pair_slots = int(features.get("seven_pair_slots", 0))
	if pair_slots < 6:
		return {}
	return {
		"label": "七对",
		"score": score,
		"progress": pair_slots,
		"suit": -1,
	}

func seven_pairs_route_score_from_counts(counts: Array) -> float:
	var pair_slots = 0
	var unique = 0
	var single_tiles = 0
	for count in counts:
		var amount = int(count)
		if amount <= 0:
			continue
		unique += 1
		pair_slots += min(2, int(amount / 2))
		if amount % 2 == 1:
			single_tiles += 1
	if pair_slots < 4:
		return 0.0
	var missing_unique = max(0, 7 - unique)
	var score = float(pair_slots) * 21.0 - float(single_tiles) * 6.0 - float(missing_unique) * 16.0
	if pair_slots >= 5:
		score += 36.0
	if pair_slots >= 6:
		score += 46.0
	return max(0.0, score)

func seven_pairs_plan_report_from_counts(counts: Array) -> Dictionary:
	var score = seven_pairs_route_score_from_counts(counts)
	if score <= 0.0:
		return {}
	var pair_slots = 0
	for count in counts:
		pair_slots += min(2, int(int(count) / 2))
	if pair_slots < 6:
		return {}
	return {
		"label": "七对",
		"score": score,
		"progress": pair_slots,
		"suit": -1,
	}

func honor_route_score_from_counts(counts: Array, codes: Array) -> float:
	var stats = honor_group_stats_from_counts(counts, codes)
	var triplets = int(stats.get("triplets", 0))
	var pairs = int(stats.get("pairs", 0))
	var singles = int(stats.get("singles", 0))
	var tiles = int(stats.get("tiles", 0))
	if codes.size() == 3:
		if triplets >= 2 and pairs + singles >= 1:
			return float(tiles) * 3.5 + float(triplets) * 28.0 + float(pairs) * 12.0 + 70.0
		if triplets + pairs >= 2 and tiles >= 5:
			return float(tiles) * 3.0 + float(triplets) * 22.0 + float(pairs) * 10.0 + 34.0
		return 0.0
	if codes.size() == 4:
		if triplets >= 3 and pairs + singles >= 1:
			return float(tiles) * 3.5 + float(triplets) * 28.0 + float(pairs) * 12.0 + 90.0
		if triplets + pairs >= 3 and tiles >= 7:
			return float(tiles) * 3.0 + float(triplets) * 22.0 + float(pairs) * 10.0 + 48.0
	return 0.0

func honor_group_plan_report_from_counts(counts: Array, codes: Array, big_label: String, small_label: String) -> Dictionary:
	var score = honor_route_score_from_counts(counts, codes)
	if score <= 0.0:
		return {}
	var stats = honor_group_stats_from_counts(counts, codes)
	var triplets = int(stats.get("triplets", 0))
	var pairs = int(stats.get("pairs", 0))
	var singles = int(stats.get("singles", 0))
	var label = small_label
	if codes.size() == 3:
		if triplets >= 3 or (triplets >= 2 and pairs == 0 and singles >= 1):
			label = big_label
	elif codes.size() == 4:
		if triplets >= 4 or (triplets >= 3 and pairs == 0 and singles >= 1):
			label = big_label
	return {
		"label": label,
		"score": score,
		"progress": triplets * 2 + pairs + singles,
		"suit": -1,
	}

func ai_defense_weight(seat: int, shanten: int, pressure_context: Dictionary = {}) -> float:
	var base = 0.40
	if shanten <= 0:
		base = 0.42
	elif shanten == 1:
		base = 0.86
	elif shanten == 2:
		base = 1.16
	else:
		base = 1.34
	var progress = clamp(1.0 - float(get_wall_count()) / 84.0, 0.0, 1.0)
	var pressure = float(pressure_context.get("opponent_pressure", 0.0)) if pressure_context.has("opponent_pressure") else opponent_pressure_score(seat)
	var readiness = float(pressure_context.get("readiness_pressure", 0.0)) if pressure_context.has("readiness_pressure") else opponent_readiness_pressure_score(seat)
	return max(0.20, (base + progress * 0.52 + pressure * 0.08 + readiness * 0.10 + score_defense_adjustment(seat)) * ai_risk_factor(seat))

func ai_pressure_context(seat: int, eval_context: Dictionary = {}) -> Dictionary:
	var context: Dictionary = {
		"opponent_pressure": 0.0,
		"readiness_pressure": 0.0,
		"threat_rank": 0,
	}
	if seat < 0 or seat >= players.size():
		return context
	var pressure = 0.0
	var readiness_pressure = 0.0
	for other in range(players.size()):
		if other == seat:
			continue
		var plan = opponent_plan_pressure(other, eval_context)
		var readiness = opponent_readiness_score_from_plan(other, plan)
		var value = float(players[other]["melds"].size()) * 1.55 + float(players[other]["discards"].size()) * 0.12
		value += plan * 0.18
		value += readiness * 0.42
		if players[other]["discards"].size() >= 12:
			value += 1.0
		pressure = max(pressure, value)
		readiness_pressure = max(readiness_pressure, readiness)
	var threat = opponent_threat_report(seat, eval_context)
	context["opponent_pressure"] = pressure
	context["readiness_pressure"] = readiness_pressure
	context["threat_rank"] = threat_level_rank(str(threat.get("level", ""))) if typeof(threat) == TYPE_DICTIONARY else 0
	return context

func opponent_pressure_score(seat: int, eval_context: Dictionary = {}) -> float:
	var pressure = 0.0
	for other in range(players.size()):
		if other == seat:
			continue
		var value = float(players[other]["melds"].size()) * 1.55 + float(players[other]["discards"].size()) * 0.12
		var plan = opponent_plan_pressure(other, eval_context)
		value += plan * 0.18
		value += opponent_readiness_score_from_plan(other, plan) * 0.42
		if players[other]["discards"].size() >= 12:
			value += 1.0
		pressure = max(pressure, value)
	return pressure

func opponent_readiness_pressure_score(seat: int, eval_context: Dictionary = {}) -> float:
	var pressure = 0.0
	for other in range(players.size()):
		if other == seat:
			continue
		pressure = max(pressure, opponent_readiness_score(other, eval_context))
	return pressure

func shanten_label(shanten: int) -> String:
	if shanten < 0:
		return "已胡"
	if shanten == 0:
		return "听牌"
	return "%d向听" % shanten

func risk_label(risk: float) -> String:
	if risk < 18.0:
		return "低"
	if risk < 31.0:
		return "中"
	return "高"

func tile_safety_label(tile: String, seat: int, visible_counts_snapshot: Array = [], eval_context: Dictionary = {}) -> String:
	if tile == "" or seat < 0 or seat >= players.size():
		return ""
	var cache_key = ""
	if not eval_context.is_empty():
		cache_key = ai_context_cache_key(tile, seat)
		var cache = eval_context.get("safety_labels", {})
		if typeof(cache) == TYPE_DICTIONARY and cache.has(cache_key):
			return str(cache.get(cache_key, ""))
	var visible_counts = ai_context_visible_counts(eval_context, visible_counts_snapshot)
	var label = ""
	if is_tile_safe_against_all(tile, seat, eval_context):
		label = "安"
	elif is_main_threat_genbutsu(tile, seat, eval_context):
		label = "现"
	elif visible_tile_count_from_counts(tile, visible_counts) >= 3:
		label = "熟"
	elif is_suji_safe_tile(tile, seat, eval_context):
		label = "筋"
	elif is_kabe_safe_tile(tile, seat, visible_counts, eval_context):
		label = "壁"
	if not eval_context.is_empty():
		var cache = eval_context.get("safety_labels", {})
		if typeof(cache) == TYPE_DICTIONARY:
			cache[cache_key] = label
	return label

func is_main_threat_genbutsu(tile: String, seat: int, eval_context: Dictionary = {}) -> bool:
	var opponent = main_threat_opponent(seat, eval_context)
	return opponent >= 0 and opponent_discard_tile_count(opponent, tile, eval_context) > 0

func main_threat_opponent(seat: int, eval_context: Dictionary = {}) -> int:
	if seat < 0 or seat >= players.size():
		return -1
	if not eval_context.is_empty() and int(eval_context.get("main_threat", -2)) != -2:
		return int(eval_context.get("main_threat", -1))
	var best_opponent = -1
	var best_score = 0.0
	for other in range(players.size()):
		if other == seat:
			continue
		var score = opponent_plan_pressure(other, eval_context)
		if score > best_score:
			best_score = score
			best_opponent = other
	var result = best_opponent if best_score >= 8.0 else -1
	if not eval_context.is_empty():
		eval_context["main_threat"] = result
	return result

func is_tile_safe_against_all(tile: String, seat: int, eval_context: Dictionary = {}) -> bool:
	var opponents = 0
	for other in range(players.size()):
		if other == seat:
			continue
		opponents += 1
		if opponent_discard_tile_count(other, tile, eval_context) <= 0:
			return false
	return opponents > 0

func is_suji_safe_tile(tile: String, seat: int, eval_context: Dictionary = {}) -> bool:
	if not is_number_tile(tile) or seat < 0 or seat >= players.size():
		return false
	for other in range(players.size()):
		if other == seat:
			continue
		if players[other]["melds"].size() <= 0 and players[other]["discards"].size() < 6:
			continue
		if is_suji_safe_against_opponent(tile, other, eval_context):
			return true
	return false

func is_suji_safe_against_opponent(tile: String, opponent: int, eval_context: Dictionary = {}) -> bool:
	if not is_number_tile(tile) or opponent < 0 or opponent >= players.size():
		return false
	var index = tile_index(tile)
	if index < 0 or index >= 27:
		return false
	var rank = index % 9
	if rank <= 2:
		return opponent_discard_tile_count(opponent, TILE_CODES[index + 3], eval_context) > 0
	if rank >= 6:
		return opponent_discard_tile_count(opponent, TILE_CODES[index - 3], eval_context) > 0
	return opponent_discard_tile_count(opponent, TILE_CODES[index - 3], eval_context) > 0 and opponent_discard_tile_count(opponent, TILE_CODES[index + 3], eval_context) > 0

func suji_anchor_tiles(tile: String) -> Array[String]:
	var result: Array[String] = []
	if not is_number_tile(tile):
		return result
	var suit = tile.right(1)
	var rank = int(tile.left(tile.length() - 1))
	match rank:
		1, 7:
			result.append("4" + suit)
		2, 8:
			result.append("5" + suit)
		3, 9:
			result.append("6" + suit)
		4:
			result.append("1" + suit)
			result.append("7" + suit)
		5:
			result.append("2" + suit)
			result.append("8" + suit)
		6:
			result.append("3" + suit)
			result.append("9" + suit)
	return result

func is_kabe_safe_tile(tile: String, seat: int, visible_counts_snapshot: Array = [], eval_context: Dictionary = {}) -> bool:
	if not is_number_tile(tile) or seat < 0 or seat >= players.size():
		return false
	if visible_tile_count_from_counts(tile, visible_counts_snapshot) >= 3:
		return false
	for other in range(players.size()):
		if other == seat:
			continue
		if players[other]["melds"].size() <= 0 and players[other]["discards"].size() < 6:
			continue
		if is_kabe_safe_against_opponent(tile, other, visible_counts_snapshot, eval_context):
			return true
	return false

func is_kabe_safe_against_opponent(tile: String, opponent: int, visible_counts_snapshot: Array = [], eval_context: Dictionary = {}) -> bool:
	if not is_number_tile(tile) or opponent < 0 or opponent >= players.size():
		return false
	var visible_counts = ai_context_visible_counts(eval_context, visible_counts_snapshot)
	var index = tile_index(tile)
	if index < 0 or index >= 27 or index >= visible_counts.size():
		return false
	var rank = index % 9
	if rank > 0 and int(visible_counts[index - 1]) >= 3:
		return true
	if rank < 8 and int(visible_counts[index + 1]) >= 3:
		return true
	return false

func kabe_wall_tiles(tile: String) -> Array[String]:
	var result: Array[String] = []
	if not is_number_tile(tile):
		return result
	var suit = tile.right(1)
	var rank = int(tile.left(tile.length() - 1))
	if rank > 1:
		result.append(str(rank - 1) + suit)
	if rank < 9:
		result.append(str(rank + 1) + suit)
	return result

func discard_pressure_score(tile: String, seat: int, visible_counts_snapshot: Array = [], eval_context: Dictionary = {}) -> float:
	var cache_key = ""
	if not eval_context.is_empty():
		cache_key = ai_context_cache_key(tile, seat)
		var cache = eval_context.get("discard_pressures", {})
		if typeof(cache) == TYPE_DICTIONARY and cache.has(cache_key):
			return float(cache.get(cache_key, 0.0))
	var score = 0.0
	var visible_counts = ai_context_visible_counts(eval_context, visible_counts_snapshot)
	var visible = visible_tile_count_from_counts(tile, visible_counts)
	score += float(visible) * 3.4
	if is_terminal_or_honor(tile):
		score += 3.0
	var next_seat = (seat + 1) % 4
	if next_seat != seat and opponent_discard_tile_count(next_seat, tile, eval_context) > 0:
		score += 5.0
	for other in range(players.size()):
		if other == seat:
			continue
		if opponent_discard_tile_count(other, tile, eval_context) > 0:
			score += 3.5
		if same_suit_pressure(other, tile, eval_context):
			score += 1.2
	if not eval_context.is_empty():
		var cache = eval_context.get("discard_pressures", {})
		if typeof(cache) == TYPE_DICTIONARY:
			cache[cache_key] = score
	return score

func discard_feed_risk_report(tile: String, seat: int, visible_counts_snapshot: Array = [], eval_context: Dictionary = {}) -> Dictionary:
	var cache_key = ""
	if not eval_context.is_empty():
		cache_key = ai_context_cache_key(tile, seat)
		var cache = eval_context.get("feed_reports", {})
		if typeof(cache) == TYPE_DICTIONARY and cache.has(cache_key):
			return duplicate_feed_report(cache[cache_key])
	var report = {"score": 0.0, "details": []}
	if tile == "" or seat < 0 or seat >= players.size():
		return report
	var details: Array = []
	var visible_counts = ai_context_visible_counts(eval_context, visible_counts_snapshot)
	var visible = visible_tile_count_from_counts(tile, visible_counts)
	var next_seat = (seat + 1) % 4
	if next_seat != seat:
		var chi_score = chi_feed_risk_score(tile, seat, next_seat, visible, eval_context)
		if chi_score > 0.0:
			details.append({
				"opponent": next_seat,
				"name": str(players[next_seat]["name"]),
				"claim": "chi",
				"label": "吃",
				"score": chi_score,
			})
	for other in range(players.size()):
		if other == seat:
			continue
		var meld_score = meld_feed_risk_score(tile, seat, other, visible, eval_context)
		if meld_score > 0.0:
			details.append({
				"opponent": other,
				"name": str(players[other]["name"]),
				"claim": "peng",
				"label": "碰",
				"score": meld_score,
			})
	details.sort_custom(func(a, b):
		var score_a = float(a.get("score", 0.0))
		var score_b = float(b.get("score", 0.0))
		if is_equal_approx(score_a, score_b):
			return int(a.get("opponent", 0)) < int(b.get("opponent", 0))
		return score_a > score_b
	)
	var total = 0.0
	for i in range(details.size()):
		var score = float(details[i].get("score", 0.0))
		total += score if i == 0 else score * 0.28
	report["details"] = details
	report["score"] = total
	if not eval_context.is_empty():
		var cache = eval_context.get("feed_reports", {})
		if typeof(cache) == TYPE_DICTIONARY:
			cache[cache_key] = duplicate_feed_report(report)
	return report

func chi_feed_risk_score(tile: String, seat: int, opponent: int, visible_override: int = -1, eval_context: Dictionary = {}) -> float:
	if not can_feed_chi(tile) or opponent < 0 or opponent >= players.size():
		return 0.0
	if opponent_discard_tile_count(opponent, tile, eval_context) > 0:
		return 0.0
	var index = tile_index(tile)
	var rank = index % 9
	var score = 7.0
	if rank >= 2 and rank <= 6:
		score += 7.0
	elif rank == 1 or rank == 7:
		score += 4.0
	var visible = visible_override if visible_override >= 0 else visible_tile_count(tile)
	if visible == 0:
		score += 3.5
	elif visible == 1:
		score += 1.5
	elif visible >= 3:
		score -= 6.0
	var suit = tile_suit_index(tile)
	var suit_pressure = opponent_suit_plan_threat(opponent, suit, eval_context)
	score += suit_pressure * 0.42
	if opponent_meld_count_for_suit(opponent, suit, eval_context) > 0:
		score += 4.5
	if players[opponent]["discards"].size() >= 10:
		score += 2.5
	return max(0.0, score)

func meld_feed_risk_score(tile: String, seat: int, opponent: int, visible_override: int = -1, eval_context: Dictionary = {}) -> float:
	if tile == "" or opponent < 0 or opponent >= players.size() or opponent == seat:
		return 0.0
	if opponent_discard_tile_count(opponent, tile, eval_context) > 0:
		return 0.0
	var visible = visible_override if visible_override >= 0 else visible_tile_count(tile)
	if visible >= 3:
		return 0.0
	var unseen = max(0, 4 - visible)
	var score = float(unseen) * 3.0
	score += float(players[opponent]["melds"].size()) * 2.2
	if visible == 0:
		score += 4.0
	elif visible == 1:
		score += 1.8
	if is_number_tile(tile):
		var suit = tile_suit_index(tile)
		var suit_pressure = opponent_suit_plan_threat(opponent, suit, eval_context)
		score += suit_pressure * 0.34
		if opponent_meld_count_for_suit(opponent, suit, eval_context) > 0:
			score += 3.0
		if is_middle_number_tile(tile):
			score += 2.5
	elif is_honor_tile(tile):
		var honor_pressure = opponent_honor_plan_threat(opponent, eval_context)
		score += honor_pressure * 0.42
		if opponent_honor_meld_count(opponent, eval_context) > 0:
			score += 4.0
		else:
			score += 1.5
	if players[opponent]["discards"].size() >= 10:
		score += 1.8
	return max(0.0, score)

func discard_feed_penalty_weight(defense: float, shanten: int) -> float:
	var weight = 0.42 + max(0.0, defense - 0.70) * 0.28
	if shanten <= 0:
		weight *= 0.35
	elif shanten == 1:
		weight *= 0.62
	return weight

func discard_feed_risk_text(feed_report) -> String:
	if typeof(feed_report) != TYPE_DICTIONARY:
		return ""
	var details: Array = feed_report.get("details", [])
	if details.is_empty() or float(feed_report.get("score", 0.0)) < 10.0:
		return ""
	var best: Dictionary = details[0]
	return "喂%s%s" % [str(best.get("name", "")), str(best.get("label", ""))]

func deal_in_risk_score(tile: String, seat: int, eval_context: Dictionary = {}) -> float:
	return float(tile_risk_vector(tile, seat, [], eval_context).get("score", 0.0))

func deal_in_risk_summary(tile: String, seat: int, visible_counts_snapshot: Array = [], risk_vector: Dictionary = {}, eval_context: Dictionary = {}) -> Dictionary:
	var summary: Dictionary = {"score": 0.0, "danger_source": {}}
	if tile == "" or seat < 0 or seat >= players.size():
		return summary
	if not risk_vector.is_empty():
		summary["score"] = float(risk_vector.get("score", 0.0))
		var vector_source = risk_vector.get("danger_source", {})
		if typeof(vector_source) == TYPE_DICTIONARY:
			summary["danger_source"] = vector_source
		return summary
	var vector = tile_risk_vector(tile, seat, visible_counts_snapshot, eval_context)
	summary["score"] = float(vector.get("score", 0.0))
	var computed_source = vector.get("danger_source", {})
	if typeof(computed_source) == TYPE_DICTIONARY:
		summary["danger_source"] = computed_source
	return summary

func tile_risk_vector(tile: String, seat: int, visible_counts_snapshot: Array = [], eval_context: Dictionary = {}) -> Dictionary:
	var cache_key = ""
	if not eval_context.is_empty():
		cache_key = ai_context_cache_key(tile, seat)
		var cache = eval_context.get("risk_vectors", {})
		if typeof(cache) == TYPE_DICTIONARY and cache.has(cache_key):
			return duplicate_risk_vector(cache[cache_key])
	var vector: Dictionary = {"score": 0.0, "threat": 0.0, "visible": 0, "danger_source": {}}
	if tile == "" or seat < 0 or seat >= players.size():
		return vector
	var visible_counts = ai_context_visible_counts(eval_context, visible_counts_snapshot)
	var visible = visible_tile_count_from_counts(tile, visible_counts)
	vector["visible"] = visible
	var risk = 0.0
	var threat = 0.0
	var best_opponent = -1
	var best_risk = 0.0
	var opponent_vector: Dictionary = {"risk": 0.0, "pattern_threat": 0.0}
	for other in range(players.size()):
		if other == seat:
			continue
		write_single_opponent_deal_in_risk_components(opponent_vector, tile, seat, other, visible, visible_counts, eval_context)
		var opponent_risk = float(opponent_vector.get("risk", 0.0))
		risk += opponent_risk
		threat += float(opponent_vector.get("pattern_threat", 0.0))
		if opponent_risk > best_risk:
			best_risk = opponent_risk
			best_opponent = other
	vector["score"] = risk
	vector["threat"] = threat
	if best_opponent >= 0 and best_risk >= 10.0:
		vector["danger_source"] = {
				"opponent": best_opponent,
				"name": str(players[best_opponent]["name"]),
				"risk": best_risk,
				"reason": discard_danger_reason(tile, seat, best_opponent, eval_context),
			}
	if not eval_context.is_empty():
		var cache = eval_context.get("risk_vectors", {})
		if typeof(cache) == TYPE_DICTIONARY:
			cache[cache_key] = duplicate_risk_vector(vector)
	return vector

func single_opponent_deal_in_risk(tile: String, seat: int, opponent: int, visible_override: int = -1, visible_counts_snapshot: Array = []) -> float:
	return float(single_opponent_deal_in_risk_components(tile, seat, opponent, visible_override, visible_counts_snapshot).get("risk", 0.0))

func single_opponent_deal_in_risk_components(tile: String, seat: int, opponent: int, visible_override: int = -1, visible_counts_snapshot: Array = [], eval_context: Dictionary = {}) -> Dictionary:
	var result: Dictionary = {"risk": 0.0, "pattern_threat": 0.0}
	write_single_opponent_deal_in_risk_components(result, tile, seat, opponent, visible_override, visible_counts_snapshot, eval_context)
	return result

func write_single_opponent_deal_in_risk_components(result: Dictionary, tile: String, seat: int, opponent: int, visible_override: int = -1, visible_counts_snapshot: Array = [], eval_context: Dictionary = {}) -> void:
	result["risk"] = 0.0
	result["pattern_threat"] = 0.0
	if tile == "" or seat < 0 or seat >= players.size() or opponent < 0 or opponent >= players.size() or opponent == seat:
		return
	if opponent_discard_tile_count(opponent, tile, eval_context) > 0:
		return
	var visible = visible_override if visible_override >= 0 else visible_tile_count(tile)
	var pressure = 2.0 + float(players[opponent]["melds"].size()) * 3.2
	var readiness = opponent_readiness_score(opponent, eval_context)
	if visible == 0:
		pressure += 4.8
	elif visible == 1:
		pressure += 2.2
	elif visible >= 3:
		pressure -= 4.0
	if is_middle_number_tile(tile):
		pressure += 3.0
	elif is_terminal_or_honor(tile):
		pressure -= 1.4
	if is_honor_tile(tile) and visible == 0:
		pressure += 2.0
	if opponent == (seat + 1) % 4 and can_feed_chi(tile):
		pressure += 1.8
	if players[opponent]["discards"].size() >= 12 or players[opponent]["melds"].size() >= 3:
		pressure += 2.8
	if readiness >= 7.0:
		pressure += readiness * (0.32 if is_terminal_or_honor(tile) else 0.52)
		if is_middle_number_tile(tile):
			pressure += readiness * 0.18
	if is_suji_safe_against_opponent(tile, opponent, eval_context):
		pressure -= 8.6
	elif is_kabe_safe_against_opponent(tile, opponent, visible_counts_snapshot, eval_context):
		pressure -= 5.4
	var pattern_threat = opponent_pattern_threat_score(opponent, tile, visible, eval_context)
	pressure += pattern_threat
	result["risk"] = max(0.0, pressure)
	result["pattern_threat"] = pattern_threat

func discard_danger_source_report(tile: String, seat: int) -> Dictionary:
	var source = deal_in_risk_summary(tile, seat).get("danger_source", {})
	if typeof(source) == TYPE_DICTIONARY:
		return source
	return {}

func discard_danger_reason(tile: String, seat: int, opponent: int, eval_context: Dictionary = {}) -> String:
	var parts: Array[String] = []
	var visible_counts = ai_context_visible_counts(eval_context)
	var visible = visible_tile_count_from_counts(tile, visible_counts)
	if is_number_tile(tile):
		var suit = tile_suit_index(tile)
		var suit_melds = opponent_meld_count_for_suit(opponent, suit, eval_context)
		if suit_melds >= 2:
			parts.append("%s染手" % suit_label(suit_code(suit)))
		elif suit_melds == 1:
			parts.append("%s副露" % suit_label(suit_code(suit)))
		if is_middle_number_tile(tile):
			parts.append("中张")
	elif is_honor_tile(tile):
		if opponent_honor_meld_count(opponent, eval_context) > 0:
			parts.append("字牌副露")
		else:
			parts.append("字牌")
	if visible == 0:
		parts.append("生张")
	elif visible == 1:
		parts.append("少见")
	if opponent == (seat + 1) % 4 and can_feed_chi(tile):
		parts.append("下家可吃")
	if players[opponent]["melds"].size() >= 3:
		parts.append("三副露")
	elif players[opponent]["melds"].size() >= 2:
		parts.append("两副露")
	if players[opponent]["discards"].size() >= 12:
		parts.append("末盘")
	if parts.is_empty():
		parts.append("牌路危险")
	return join_limited_strings(parts, "、", 3)

func discard_danger_text(source) -> String:
	if typeof(source) != TYPE_DICTIONARY or source.is_empty():
		return ""
	var reason = str(source.get("reason", "牌路危险"))
	return "主危%s：%s" % [str(source.get("name", "")), reason]

func opponent_tile_threat_score(tile: String, seat: int, visible_counts_snapshot: Array = [], risk_vector: Dictionary = {}, eval_context: Dictionary = {}) -> float:
	if seat < 0 or seat >= players.size():
		return 0.0
	if not risk_vector.is_empty():
		return float(risk_vector.get("threat", 0.0))
	var total = 0.0
	var visible = visible_tile_count_from_counts(tile, visible_counts_snapshot)
	for other in range(players.size()):
		if other == seat:
			continue
		if opponent_discard_tile_count(other, tile, eval_context) > 0:
			continue
		total += opponent_pattern_threat_score(other, tile, visible, eval_context)
	return total

func opponent_pattern_threat_score(opponent: int, tile: String, visible: int, eval_context: Dictionary = {}) -> float:
	if opponent < 0 or opponent >= players.size():
		return 0.0
	var index = tile_index(tile)
	if index < 0:
		return 0.0
	var threat = 0.0
	if index < 27:
		var suit = tile_suit_index(tile)
		var meld_count = opponent_meld_count_for_suit(opponent, suit, eval_context)
		if meld_count <= 0:
			return 0.0
		var meld_tiles = opponent_meld_tile_count_for_suit(opponent, suit, eval_context)
		var suit_discards = opponent_discard_count_for_suit(opponent, suit, eval_context)
		var off_suit_discards = max(0, players[opponent]["discards"].size() - suit_discards)
		threat += float(meld_count) * 3.2 + float(meld_tiles) * 0.65
		if meld_count >= 2:
			threat += 6.0
		if meld_count >= 3:
			threat += 8.0
		if suit_discards == 0:
			threat += 4.2
		elif suit_discards <= 2:
			threat += 2.0
		threat += min(5.0, float(off_suit_discards) * 0.45)
		if is_middle_number_tile(tile):
			threat += 2.4
		elif is_terminal_or_honor(tile):
			threat += 0.6
	else:
		var honor_melds = opponent_honor_meld_count(opponent, eval_context)
		if honor_melds <= 0:
			return 0.0
		threat += float(honor_melds) * 4.4 + float(players[opponent]["melds"].size()) * 0.9
		if visible == 0:
			threat += 3.6
		elif visible >= 2:
			threat -= 1.2
	return max(0.0, threat)

func opponent_threat_summary(seat: int) -> String:
	var report = opponent_threat_report(seat)
	if report.is_empty():
		return ""
	var safe_tiles: Array = report.get("safe_tiles", [])
	var safe_text = "，安牌%s" % "、".join(safe_tiles) if not safe_tiles.is_empty() else ""
	var readiness = str(report.get("readiness_label", ""))
	var plan = str(report.get("plan_label", ""))
	var plan_text = "偏%s" % plan if plan != "" else "手牌推进"
	return "%s %s%s%s，慎放%s%s" % [
		str(report.get("level", "中")),
		str(report.get("name", "")),
		readiness,
		plan_text,
		str(report.get("avoid", "")),
		safe_text,
	]

func opponent_threat_report(seat: int, eval_context: Dictionary = {}) -> Dictionary:
	if seat < 0 or seat >= players.size():
		return {}
	var best_score = 0.0
	var best_report: Dictionary = {}
	for other in range(players.size()):
		if other == seat:
			continue
		var report = opponent_seat_threat_report(seat, other, eval_context)
		var score = float(report.get("score", 0.0))
		if score > best_score:
			best_score = score
			best_report = report
	if best_score < 8.0 or best_report.is_empty():
		return {}
	return best_report

func opponent_seat_threat_report(viewer: int, opponent: int, eval_context: Dictionary = {}) -> Dictionary:
	if viewer < 0 or viewer >= players.size() or opponent < 0 or opponent >= players.size() or viewer == opponent:
		return {}
	var cache_key = threat_report_cache_key(viewer, opponent)
	if cache_key != "" and threat_report_cache.has(cache_key):
		return duplicate_threat_report(threat_report_cache[cache_key])
	var best_score = 0.0
	var best_label = ""
	var best_hint = ""
	var best_type = ""
	var best_suit = -1
	for suit in range(3):
		var score = opponent_suit_plan_threat(opponent, suit, eval_context)
		if score > best_score:
			best_score = score
			best_label = suit_label(suit_code(suit))
			best_hint = "%s中张" % best_label
			best_type = "suit"
			best_suit = suit
	var honor_score = opponent_honor_plan_threat(opponent, eval_context)
	if honor_score > best_score:
		best_score = honor_score
		best_label = "字牌"
		best_hint = "生张字牌"
		best_type = "honor"
		best_suit = -1
	var readiness = opponent_readiness_report(viewer, opponent, eval_context)
	var readiness_score = float(readiness.get("score", 0.0))
	var readiness_label = str(readiness.get("label", ""))
	if best_score < 8.0 and readiness_label != "":
		best_score = readiness_score * 1.55
		best_label = ""
		best_hint = "生张中张"
		best_type = "readiness"
		best_suit = -1
	if best_score < 8.0 and readiness_label == "":
		store_threat_report_cache(cache_key, {})
		return {}
	var level = opponent_threat_level(best_score)
	if readiness_label != "":
		level = stronger_threat_level(level, readiness_threat_level(readiness_score))
	var report = {
		"opponent": opponent,
		"name": str(players[opponent]["name"]),
		"score": best_score,
		"level": level,
		"plan_type": best_type,
		"plan_suit": best_suit,
		"plan_label": best_label,
		"avoid": best_hint,
		"readiness_score": readiness_score,
		"readiness_label": readiness_label,
		"readiness_reasons": readiness.get("reasons", []),
		"safe_tiles": threat_safe_tile_labels(viewer, best_type, best_suit, 3, eval_context),
	}
	store_threat_report_cache(cache_key, report)
	return duplicate_threat_report(report)

func threat_report_cache_key(viewer: int, opponent: int) -> String:
	if mode != "offline" or viewer < 0 or opponent < 0:
		return ""
	var parts: Array[String] = [
		"viewer=%d" % viewer,
		"opponent=%d" % opponent,
		"phase=" + offline_phase,
		"cur=%d" % current_seat,
		"wall=%d" % get_wall_count(),
	]
	for seat in range(players.size()):
		var player: Dictionary = players[seat]
		parts.append("p%d_hand=%s" % [seat, tile_array_key(player.get("hand", [])) if seat == viewer else "%d" % numeric_count(player.get("hand", []), 0)])
		parts.append("p%d_disc=%s" % [seat, tile_array_key(player.get("discards", []))])
		parts.append("p%d_meld=%s" % [seat, meld_array_key(player.get("melds", []))])
	return "|".join(parts)

func store_threat_report_cache(key: String, report: Dictionary) -> void:
	if key == "":
		return
	if not threat_report_cache.has(key):
		threat_report_cache_order.append(key)
	threat_report_cache[key] = duplicate_threat_report(report)
	while threat_report_cache_order.size() > THREAT_REPORT_CACHE_LIMIT:
		var oldest = threat_report_cache_order.pop_front()
		threat_report_cache.erase(oldest)

func duplicate_threat_report(report) -> Dictionary:
	if typeof(report) != TYPE_DICTIONARY:
		return {}
	var copy: Dictionary = (report as Dictionary).duplicate(false)
	var safe_tiles = copy.get("safe_tiles", [])
	if typeof(safe_tiles) == TYPE_ARRAY:
		copy["safe_tiles"] = (safe_tiles as Array).duplicate(false)
	var reasons = copy.get("readiness_reasons", [])
	if typeof(reasons) == TYPE_ARRAY:
		copy["readiness_reasons"] = (reasons as Array).duplicate(false)
	return copy

func clear_threat_report_cache() -> void:
	threat_report_cache.clear()
	threat_report_cache_order.clear()

func render_seat_threat_reports(viewer: int, eval_context: Dictionary = {}) -> Dictionary:
	var reports: Dictionary = {}
	if mode != "offline" or viewer < 0 or viewer >= players.size():
		return reports
	for seat in range(players.size()):
		if seat == viewer:
			continue
		var report = opponent_seat_threat_report(viewer, seat, eval_context)
		if not report.is_empty():
			reports[seat] = report
	return reports

func seat_threat_report_from_map(seat: int, seat_threat_reports: Dictionary) -> Dictionary:
	if seat_threat_reports.has(seat):
		var report = seat_threat_reports.get(seat, {})
		if typeof(report) == TYPE_DICTIONARY:
			return report
	if not player_ai_assist_enabled():
		return {}
	if mode == "offline" and seat != 0:
		return opponent_seat_threat_report(0, seat)
	return {}

func opponent_seat_threat_badge_text(seat: int, viewer: int = 0) -> String:
	if mode != "offline" or seat == viewer:
		return ""
	var report = opponent_seat_threat_report(viewer, seat)
	return opponent_seat_threat_badge_text_from_report(report)

func opponent_seat_threat_badge_text_from_report(report: Dictionary) -> String:
	if report.is_empty():
		return ""
	var readiness = str(report.get("readiness_label", ""))
	if readiness != "":
		return "%s%s" % [readiness, str(report.get("plan_label", ""))]
	return "%s%s" % [str(report.get("level", "中")), str(report.get("plan_label", ""))]

func opponent_seat_threat_line(seat: int, viewer: int = 0) -> String:
	if mode != "offline" or seat == viewer:
		return ""
	var report = opponent_seat_threat_report(viewer, seat)
	return opponent_seat_threat_line_from_report(report)

func opponent_seat_threat_line_from_report(report: Dictionary) -> String:
	if report.is_empty():
		return ""
	var safe_tiles: Array = report.get("safe_tiles", [])
	var safe_text = " 安%s" % join_limited_strings(safe_tiles, "、", 2) if not safe_tiles.is_empty() else ""
	var readiness = str(report.get("readiness_label", ""))
	var plan = str(report.get("plan_label", ""))
	var threat_text = "威%s" % plan if plan != "" else "威手"
	return "%s%s%s" % [readiness + " " if readiness != "" else "", threat_text, safe_text]

func opponent_seat_threat_color(seat: int, viewer: int = 0) -> Color:
	var report = opponent_seat_threat_report(viewer, seat)
	return opponent_seat_threat_color_from_report(report)

func opponent_seat_threat_color_from_report(report: Dictionary) -> Color:
	match str(report.get("level", "")):
		"危":
			return Color(0.84, 0.20, 0.14, 0.96)
		"高":
			return Color(0.90, 0.54, 0.18, 0.96)
		"中":
			return Color(0.86, 0.72, 0.22, 0.94)
	return Color(0.32, 0.56, 0.48, 0.90)

func opponent_threat_level(score: float) -> String:
	if score >= 24.5:
		return "危"
	if score >= 16.0:
		return "高"
	if score >= 8.0:
		return "中"
	return "低"

func readiness_threat_level(score: float) -> String:
	if score >= 13.0:
		return "危"
	if score >= 9.5:
		return "高"
	if score >= 7.0:
		return "中"
	return "低"

func stronger_threat_level(left: String, right: String) -> String:
	return left if threat_level_rank(left) >= threat_level_rank(right) else right

func threat_level_rank(level: String) -> int:
	match level:
		"危":
			return 3
		"高":
			return 2
		"中":
			return 1
	return 0

func opponent_plan_pressure(opponent: int, eval_context: Dictionary = {}) -> float:
	var state = ai_context_opponent_state(eval_context, opponent)
	if not state.is_empty():
		return float(state.get("plan_pressure", 0.0))
	var pressure = opponent_honor_plan_threat(opponent, eval_context)
	for suit in range(3):
		pressure = max(pressure, opponent_suit_plan_threat(opponent, suit, eval_context))
	return pressure

func opponent_readiness_report(viewer: int, opponent: int, eval_context: Dictionary = {}) -> Dictionary:
	if viewer < 0 or viewer >= players.size() or opponent < 0 or opponent >= players.size() or viewer == opponent:
		return {"score": 0.0, "label": "", "reasons": []}
	var score = opponent_readiness_score(opponent, eval_context)
	var reasons: Array[String] = []
	var discards = players[opponent]["discards"].size()
	var melds = players[opponent]["melds"].size()
	var wall_count = get_wall_count()
	if discards >= 13:
		reasons.append("弃牌多")
	elif discards >= 10:
		reasons.append("中后盘")
	if melds >= 3:
		reasons.append("三副露")
	elif melds >= 2:
		reasons.append("两副露")
	elif melds == 1:
		reasons.append("一副露")
	if wall_count <= 24:
		reasons.append("末盘")
	elif wall_count <= 40:
		reasons.append("后盘")
	var plan = opponent_plan_pressure(opponent, eval_context)
	if plan >= 16.0:
		reasons.append("牌路集中")
	elif plan >= 8.0:
		reasons.append("有主线")
	return {
		"score": score,
		"label": opponent_readiness_label(score),
		"reasons": reasons,
	}

func opponent_readiness_score(opponent: int, eval_context: Dictionary = {}) -> float:
	if opponent < 0 or opponent >= players.size():
		return 0.0
	var state = ai_context_opponent_state(eval_context, opponent)
	if not state.is_empty():
		return float(state.get("readiness", 0.0))
	return opponent_readiness_score_from_plan(opponent, opponent_plan_pressure(opponent, eval_context))

func opponent_readiness_score_from_plan(opponent: int, plan_pressure: float) -> float:
	if opponent < 0 or opponent >= players.size():
		return 0.0
	var discards = players[opponent]["discards"].size()
	var melds = players[opponent]["melds"].size()
	var wall_progress = clamp(1.0 - float(get_wall_count()) / 84.0, 0.0, 1.0)
	var score = float(discards) * 0.45 + float(melds) * 2.15 + wall_progress * 5.2 + plan_pressure * 0.20
	if discards >= 10:
		score += 1.0
	if discards >= 13:
		score += 1.2
	if melds >= 2:
		score += 1.2
	if melds >= 3:
		score += 1.8
	var wall_count = get_wall_count()
	if wall_count <= 40:
		score += 1.0
	if wall_count <= 24:
		score += 1.2
	return score

func opponent_readiness_label(score: float) -> String:
	if score >= 13.0:
		return "疑听"
	if score >= 9.5:
		return "近听"
	if score >= 7.0:
		return "快进"
	return ""

func threat_safe_tile_labels(seat: int, plan_type: String, plan_suit: int, limit: int, eval_context: Dictionary = {}) -> Array:
	if seat < 0 or seat >= players.size() or limit <= 0:
		return []
	var seen: Dictionary = {}
	var best_tiles: Array[String] = []
	var best_scores: Array = []
	var best_sorts: Array = []
	for item in players[seat]["hand"]:
		var tile = str(item)
		if seen.has(tile):
			continue
		seen[tile] = true
		var safety = tile_safety_label(tile, seat, [], eval_context)
		var risk = float(tile_risk_vector(tile, seat, [], eval_context).get("score", 0.0))
		var score = -risk
		if safety == "安":
			score += 120.0
		elif safety == "熟":
			score += 72.0
		elif safety == "筋":
			score += 42.0
		elif safety == "壁":
			score += 34.0
		if plan_type == "suit" and tile_suit_index(tile) != plan_suit:
			score += 16.0
		if plan_type == "honor" and not is_honor_tile(tile):
			score += 12.0
		if is_terminal_or_honor(tile):
			score += 4.0
		var tile_sort = tile_sort_index(tile)
		var insert_at = best_tiles.size()
		for i in range(best_tiles.size()):
			var current_score = float(best_scores[i])
			if score > current_score or (is_equal_approx(score, current_score) and tile_sort < int(best_sorts[i])):
				insert_at = i
				break
		if best_tiles.size() < limit or insert_at < limit:
			best_tiles.insert(insert_at, tile)
			best_scores.insert(insert_at, score)
			best_sorts.insert(insert_at, tile_sort)
			if best_tiles.size() > limit:
				best_tiles.resize(limit)
				best_scores.resize(limit)
				best_sorts.resize(limit)
	var labels: Array[String] = []
	for i in range(best_tiles.size()):
		labels.append(tile_label(best_tiles[i]))
	return labels

func opponent_suit_plan_threat(opponent: int, suit: int, eval_context: Dictionary = {}) -> float:
	var state = ai_context_opponent_state(eval_context, opponent)
	if not state.is_empty():
		var threats = state.get("suit_plan_threats", [])
		if typeof(threats) == TYPE_ARRAY and suit >= 0 and suit < threats.size():
			return float(threats[suit])
	var meld_count = opponent_meld_count_for_suit(opponent, suit, eval_context)
	if meld_count <= 0:
		return 0.0
	var meld_tiles = opponent_meld_tile_count_for_suit(opponent, suit, eval_context)
	var suit_discards = opponent_discard_count_for_suit(opponent, suit, eval_context)
	var off_suit_discards = max(0, players[opponent]["discards"].size() - suit_discards)
	var score = float(meld_count) * 4.0 + float(meld_tiles) * 0.70 + min(5.0, float(off_suit_discards) * 0.45)
	if meld_count >= 2:
		score += 6.0
	if meld_count >= 3:
		score += 8.0
	if suit_discards == 0:
		score += 4.0
	elif suit_discards <= 2:
		score += 1.8
	return score

func opponent_honor_plan_threat(opponent: int, eval_context: Dictionary = {}) -> float:
	var state = ai_context_opponent_state(eval_context, opponent)
	if not state.is_empty():
		return float(state.get("honor_plan_threat", 0.0))
	var honor_melds = opponent_honor_meld_count(opponent, eval_context)
	if honor_melds <= 0:
		return 0.0
	return float(honor_melds) * 5.0 + float(players[opponent]["melds"].size()) * 0.9

func opponent_meld_count_for_suit(opponent: int, suit: int, eval_context: Dictionary = {}) -> int:
	var state = ai_context_opponent_state(eval_context, opponent)
	if not state.is_empty():
		var counts = state.get("meld_count_by_suit", [])
		if typeof(counts) == TYPE_ARRAY and suit >= 0 and suit < counts.size():
			return int(counts[suit])
	var count = 0
	for meld in players[opponent]["melds"]:
		for tile in meld:
			if tile_suit_index(str(tile)) == suit:
				count += 1
				break
	return count

func opponent_meld_tile_count_for_suit(opponent: int, suit: int, eval_context: Dictionary = {}) -> int:
	var state = ai_context_opponent_state(eval_context, opponent)
	if not state.is_empty():
		var counts = state.get("meld_tile_count_by_suit", [])
		if typeof(counts) == TYPE_ARRAY and suit >= 0 and suit < counts.size():
			return int(counts[suit])
	var count = 0
	for meld in players[opponent]["melds"]:
		for tile in meld:
			if tile_suit_index(str(tile)) == suit:
				count += 1
	return count

func opponent_discard_count_for_suit(opponent: int, suit: int, eval_context: Dictionary = {}) -> int:
	var state = ai_context_opponent_state(eval_context, opponent)
	if not state.is_empty():
		var counts = state.get("suit_discards", [])
		if typeof(counts) == TYPE_ARRAY and suit >= 0 and suit < counts.size():
			return int(counts[suit])
	var count = 0
	for tile in players[opponent]["discards"]:
		if tile_suit_index(str(tile)) == suit:
			count += 1
	return count

func opponent_honor_meld_count(opponent: int, eval_context: Dictionary = {}) -> int:
	var state = ai_context_opponent_state(eval_context, opponent)
	if not state.is_empty():
		return int(state.get("honor_meld_count", 0))
	var count = 0
	for meld in players[opponent]["melds"]:
		for tile in meld:
			if is_honor_tile(str(tile)):
				count += 1
				break
	return count

func tile_suit_index(tile: String) -> int:
	if not tile_metadata_ready:
		setup_tile_order()
	if tile_suit_cache.has(tile):
		return int(tile_suit_cache[tile])
	var index = tile_index(tile)
	if index < 0 or index >= 27:
		return -1
	return int(index / 9)


func should_ai_gang_claim(seat: int, tile: String) -> bool:
	return bool(build_ai_claim_report(seat, "gang", tile).get("allow", false))

func should_ai_peng(seat: int, tile: String) -> bool:
	return bool(build_ai_claim_report(seat, "peng", tile).get("allow", false))

func should_ai_chi(seat: int, tile: String, choice: Dictionary) -> bool:
	return bool(build_ai_claim_report(seat, "chi", tile, choice).get("allow", false))

func choose_ai_concealed_gang(seat: int) -> String:
	if seat < 0 or seat >= players.size():
		return ""
	var best_tile = ""
	var best_score = -1000000.0
	for tile in TILE_CODES:
		var report = build_ai_self_gang_report(seat, tile, "concealed")
		if not bool(report.get("allow", false)):
			continue
		var score = float(report.get("score", 0.0))
		if best_tile == "" or score > best_score:
			best_tile = tile
			best_score = score
	return best_tile

func choose_ai_added_gang(seat: int) -> String:
	if seat < 0 or seat >= players.size():
		return ""
	var best_tile = ""
	var best_score = -1000000.0
	for tile in TILE_CODES:
		var report = build_ai_self_gang_report(seat, tile, "added")
		if not bool(report.get("allow", false)):
			continue
		var score = float(report.get("score", 0.0))
		if best_tile == "" or score > best_score:
			best_tile = tile
			best_score = score
	return best_tile

func build_ai_self_gang_report(seat: int, tile: String, gang_kind: String) -> Dictionary:
	var report: Dictionary = {
		"seat": seat,
		"tile": tile,
		"gang_kind": gang_kind,
		"allow": false,
		"reason": "非法杠",
		"before_shanten": 8,
		"after_shanten": 8,
		"before_plan_label": "",
		"score": -1000000.0,
		"pressure": 0.0,
		"defense": 0.0,
		"rob_risk": false,
		"declined_by_plan": false,
	}
	if seat < 0 or seat >= players.size() or tile == "":
		return report
	var hand: Array = players[seat]["hand"]
	var open_melds = players[seat]["melds"].size()
	var before_shanten = calculate_min_shanten(hand, open_melds)
	var before_plan_label = str(hand_plan_report_for_seat(seat, hand).get("label", ""))
	var after = hand.duplicate()
	var after_open_melds = open_melds
	match gang_kind:
		"concealed":
			if count_tile(hand, tile) < 4 or not remove_tiles(after, tile, 4):
				return report
			after_open_melds = open_melds + 1
		"added":
			if not can_added_gang(seat, tile) or not remove_tiles(after, tile, 1):
				return report
		_:
			return report
	var after_shanten = calculate_min_shanten(after, after_open_melds)
	var pressure = opponent_pressure_score(seat)
	var defense = ai_defense_weight(seat, before_shanten)
	var rob_risk = gang_kind == "added" and seat != 0 and can_win_for_seat(0, tile)
	report["before_shanten"] = before_shanten
	report["after_shanten"] = after_shanten
	report["before_plan_label"] = before_plan_label
	report["pressure"] = pressure
	report["defense"] = defense
	report["rob_risk"] = rob_risk
	report["score"] = ai_self_gang_action_score(report)
	var route_break = gang_kind == "concealed" and open_melds == 0 and (before_plan_label == "七对" or before_plan_label == "十三幺")
	if route_break:
		report["reason"] = "保%s" % before_plan_label
		report["declined_by_plan"] = true
	elif rob_risk:
		report["reason"] = "防抢杠"
	elif after_shanten > before_shanten:
		report["reason"] = "升向听"
	elif after_shanten < before_shanten:
		report["allow"] = true
		report["reason"] = "降向听"
	elif after_shanten <= 0:
		report["allow"] = true
		report["reason"] = "听牌杠"
	elif after_shanten <= 1 and float(report.get("score", 0.0)) >= 34.0:
		report["allow"] = true
		report["reason"] = "近听杠"
	elif float(report.get("score", 0.0)) >= ai_self_gang_score_threshold(gang_kind, before_shanten):
		report["allow"] = true
		report["reason"] = "牌值杠"
	else:
		report["reason"] = "杠牌收益不足"
	if bool(report.get("allow", false)) and pressure >= 6.8 and after_shanten >= 2 and not is_terminal_or_honor(tile):
		report["allow"] = false
		report["reason"] = "高压防守"
	return report

func ai_self_gang_action_score(report: Dictionary) -> float:
	if report.is_empty():
		return -1000000.0
	var gang_kind = str(report.get("gang_kind", ""))
	var tile = str(report.get("tile", ""))
	var before_shanten = int(report.get("before_shanten", 8))
	var after_shanten = int(report.get("after_shanten", before_shanten))
	var shanten_gain = max(0, before_shanten - after_shanten)
	var score = 44.0 if gang_kind == "concealed" else 36.0
	score += float(shanten_gain) * 46.0
	if after_shanten <= 0:
		score += 38.0
	elif after_shanten == 1:
		score += 22.0
	if is_honor_tile(tile):
		score += 18.0
	elif is_terminal_or_honor(tile):
		score += 10.0
	var seat = int(report.get("seat", -1))
	var attack = ai_total_attack_multiplier(seat)
	score *= ai_gang_aggression(seat)
	score += max(0.0, attack - 1.0) * 36.0
	var pressure = float(report.get("pressure", 0.0))
	var defense = float(report.get("defense", 0.0))
	if after_shanten >= 2:
		score -= pressure * 0.90 + defense * 8.0
	else:
		score -= pressure * 0.28
	if gang_kind == "added":
		score -= 6.0
	if bool(report.get("rob_risk", false)):
		score -= 1000.0
	if bool(report.get("declined_by_plan", false)):
		score -= 1000.0
	return score

func ai_self_gang_score_threshold(gang_kind: String, before_shanten: int) -> float:
	if before_shanten <= 1:
		return 34.0
	if gang_kind == "concealed":
		return 54.0
	return 46.0

func first_concealed_gang_tile(seat: int) -> String:
	if seat < 0 or seat >= players.size():
		return ""
	for tile in TILE_CODES:
		if count_tile(players[seat]["hand"], tile) >= 4:
			return tile
	return ""

func first_added_gang_tile(seat: int) -> String:
	if seat < 0 or seat >= players.size():
		return ""
	for tile in TILE_CODES:
		if can_added_gang(seat, tile):
			return tile
	return ""

func best_chi_choice(hand: Array, tile: String) -> Dictionary:
	return best_chi_choice_from_counts(tile_counts(hand), tile)

func best_chi_choice_from_counts(hand_counts: Array, tile: String) -> Dictionary:
	var choices = get_chi_choices_from_counts(hand_counts, tile)
	var best: Dictionary = {}
	var best_score = -100000.0
	for choice in choices:
		var needed: Array = choice.get("needed", [])
		if not consume_tile_list_counts(hand_counts, needed):
			continue
		var score = evaluate_ai_hand_from_counts(hand_counts)
		restore_tile_list_counts(hand_counts, needed)
		if score > best_score:
			best_score = score
			best = choice
			best["score"] = score
	return best

func get_chi_choices(hand: Array, tile: String) -> Array:
	return get_chi_choices_from_counts(tile_counts(hand), tile)

func get_chi_choices_from_counts(hand_counts: Array, tile: String) -> Array:
	var choices: Array = []
	var index = tile_index(tile)
	if index < 0 or index >= 27 or hand_counts.is_empty():
		return choices
	var rank = index % 9
	var suit_start = index - rank
	for offset in range(3):
		var start_rank = rank - offset
		if start_rank < 0 or start_rank > 6:
			continue
		var first_index = suit_start + start_rank
		var second_index = first_index + 1
		var third_index = first_index + 2
		var need_a = second_index if index == first_index else first_index
		var need_b = second_index if index == third_index else third_index
		if need_a < 0 or need_b < 0 or need_b >= hand_counts.size():
			continue
		if int(hand_counts[need_a]) <= 0 or int(hand_counts[need_b]) <= 0:
			continue
		choices.append({
			"needed": [TILE_CODES[need_a], TILE_CODES[need_b]],
			"meld": [TILE_CODES[first_index], TILE_CODES[second_index], TILE_CODES[third_index]],
		})
	return choices

func is_valid_pending_chi_choice(choice: Dictionary) -> bool:
	var choices: Array = offline_pending_claim.get("chi_choices", [])
	if choices.is_empty():
		return true
	for item in choices:
		if typeof(item) != TYPE_DICTIONARY:
			continue
		if same_tile_list(item.get("meld", []), choice.get("meld", [])) and same_tile_list(item.get("needed", []), choice.get("needed", [])):
			return true
	return false

func same_tile_list(left: Array, right: Array) -> bool:
	if left.size() != right.size():
		return false
	for i in range(left.size()):
		if str(left[i]) != str(right[i]):
			return false
	return true

func claim_options_text(pending: Dictionary) -> String:
	var names: Array[String] = []
	for claim in pending.get("options", []):
		var claim_name = str(claim)
		if claim_name == "chi":
			var chi_choices: Array = pending.get("chi_choices", [])
			if chi_choices.is_empty():
				names.append(claim_label(claim_name))
			else:
				for choice in chi_choices:
					if typeof(choice) == TYPE_DICTIONARY:
						names.append(chi_choice_label(choice))
		else:
			names.append(claim_label(claim_name))
	return " / ".join(names)

func chi_choice_label(choice: Dictionary) -> String:
	return "吃" + compact_tile_run_label(choice.get("meld", []))

func compact_tile_run_label(tiles: Array) -> String:
	if tiles.is_empty():
		return ""
	var first = str(tiles[0])
	if is_number_tile(first):
		var suit = first.right(1)
		var ranks = ""
		var same_suit = true
		for tile in tiles:
			var code = str(tile)
			if not is_number_tile(code) or code.right(1) != suit:
				same_suit = false
				break
			ranks += code.left(code.length() - 1)
		if same_suit:
			return ranks + suit_label(suit)
	var labels: Array[String] = []
	for tile in tiles:
		labels.append(tile_label(str(tile)))
	return "".join(labels)



func tile_base_value(index: int) -> float:
	if index < 0 or index >= TILE_BASE_VALUES.size():
		return 0.0
	return float(TILE_BASE_VALUES[index])

func has_neighbor(counts: Array, index: int, delta: int) -> bool:
	var neighbor = index + delta
	if neighbor < 0 or neighbor >= 27:
		return false
	return index / 9 == neighbor / 9 and int(counts[neighbor]) > 0

func can_feed_chi(tile: String) -> bool:
	var index = tile_index(tile)
	return index >= 0 and index < 27

func is_middle_number_tile(tile: String) -> bool:
	var index = tile_index(tile)
	if index < 0 or index >= 27:
		return false
	var rank = index % 9
	return rank >= 2 and rank <= 6

func same_suit_pressure(seat: int, tile: String, eval_context: Dictionary = {}) -> bool:
	var index = tile_index(tile)
	if index < 0 or index >= 27:
		return false
	var suit = index / 9
	var state = ai_context_opponent_state(eval_context, seat)
	if not state.is_empty():
		var counts = state.get("suit_discards", [])
		if typeof(counts) == TYPE_ARRAY and suit >= 0 and suit < counts.size():
			return int(counts[suit]) >= 3
	var count = 0
	for discarded in players[seat]["discards"]:
		var discarded_index = tile_index(str(discarded))
		if discarded_index >= 0 and discarded_index < 27 and discarded_index / 9 == suit:
			count += 1
	return count >= 3

func is_honor_tile(tile: String) -> bool:
	if not tile_metadata_ready:
		setup_tile_order()
	if tile_honor_cache.has(tile):
		return bool(tile_honor_cache[tile])
	var index = tile_index(tile)
	return index >= 27

func is_terminal_or_honor(tile: String) -> bool:
	if not tile_metadata_ready:
		setup_tile_order()
	if tile_terminal_or_honor_cache.has(tile):
		return bool(tile_terminal_or_honor_cache[tile])
	var index = tile_index(tile)
	if index >= 27:
		return true
	if index < 0:
		return false
	var rank = index % 9
	return rank == 0 or rank == 8

func is_simple_number_tile(tile: String) -> bool:
	if not tile_metadata_ready:
		setup_tile_order()
	if tile_simple_number_cache.has(tile):
		return bool(tile_simple_number_cache[tile])
	var index = tile_index(tile)
	if index < 0 or index >= 27:
		return false
	var rank = index % 9
	return rank >= 1 and rank <= 7

func visible_tile_counts() -> Array:
	var counts = make_empty_tile_counts()
	for seat in range(players.size()):
		add_visible_tile_counts(counts, players[seat]["discards"])
		for meld in players[seat]["melds"]:
			add_visible_tile_counts(counts, meld)
	return counts

func add_visible_tile_counts(counts: Array, tiles: Array) -> void:
	for tile in tiles:
		var index = tile_index(str(tile))
		if index >= 0 and index < counts.size():
			counts[index] = int(counts[index]) + 1

func visible_tile_count(tile: String) -> int:
	var visible = 0
	for seat in range(players.size()):
		visible += count_tile(players[seat]["discards"], tile)
		for meld in players[seat]["melds"]:
			visible += count_tile(meld, tile)
	return visible

func visible_tile_count_from_counts(tile: String, visible_counts_snapshot: Array = []) -> int:
	if visible_counts_snapshot.is_empty():
		return visible_tile_count(tile)
	var index = tile_index(tile)
	if index < 0 or index >= visible_counts_snapshot.size():
		return 0
	return int(visible_counts_snapshot[index])

func is_pure_one_suit_hand(seat: int, tiles: Array) -> bool:
	var suit = ""
	var has_number = false
	for tile in all_scoring_tiles(seat, tiles):
		var code = str(tile)
		if is_honor_tile(code):
			return false
		has_number = true
		var current = code.right(1)
		if suit == "":
			suit = current
		elif suit != current:
			return false
	return has_number

func is_mixed_one_suit_hand(seat: int, tiles: Array) -> bool:
	var suit = ""
	var has_number = false
	var has_honor = false
	for tile in all_scoring_tiles(seat, tiles):
		var code = str(tile)
		if is_honor_tile(code):
			has_honor = true
			continue
		has_number = true
		var current = code.right(1)
		if suit == "":
			suit = current
		elif suit != current:
			return false
	return has_number and has_honor

func is_all_simples_hand(seat: int, tiles: Array) -> bool:
	var has_tile = false
	for tile in all_scoring_tiles(seat, tiles):
		var code = str(tile)
		if not is_simple_number_tile(code):
			return false
		has_tile = true
	return has_tile

func is_big_three_dragons_hand(seat: int, tiles: Array) -> bool:
	return int(honor_group_stats(seat, tiles, DRAGON_CODES).get("triplets", 0)) == DRAGON_CODES.size()

func is_small_three_dragons_hand(seat: int, tiles: Array) -> bool:
	var stats = honor_group_stats(seat, tiles, DRAGON_CODES)
	return int(stats.get("triplets", 0)) == 2 and int(stats.get("pairs", 0)) >= 1

func is_big_four_winds_hand(seat: int, tiles: Array) -> bool:
	return int(honor_group_stats(seat, tiles, WIND_CODES).get("triplets", 0)) == WIND_CODES.size()

func is_small_four_winds_hand(seat: int, tiles: Array) -> bool:
	var stats = honor_group_stats(seat, tiles, WIND_CODES)
	return int(stats.get("triplets", 0)) == 3 and int(stats.get("pairs", 0)) >= 1

func honor_group_stats(seat: int, tiles: Array, codes: Array) -> Dictionary:
	return honor_group_stats_from_counts(tile_counts(all_scoring_tiles(seat, tiles)), codes)

func honor_group_stats_from_counts(counts: Array, codes: Array) -> Dictionary:
	var triplets = 0
	var pairs = 0
	var singles = 0
	var tile_total = 0
	for code in codes:
		var index = tile_index(str(code))
		if index < 0 or index >= counts.size():
			continue
		var amount = int(counts[index])
		tile_total += amount
		if amount >= 3:
			triplets += 1
		elif amount == 2:
			pairs += 1
		elif amount == 1:
			singles += 1
	return {
		"triplets": triplets,
		"pairs": pairs,
		"singles": singles,
		"tiles": tile_total,
	}

func is_all_honor_hand(seat: int, tiles: Array) -> bool:
	for tile in all_scoring_tiles(seat, tiles):
		if not is_honor_tile(str(tile)):
			return false
	return true

func is_full_straight_hand(seat: int, tiles: Array) -> bool:
	return full_straight_suit(seat, tiles) >= 0

func full_straight_suit(seat: int, tiles: Array) -> int:
	var ranks_by_suit: Array = []
	for suit in range(3):
		var ranks: Dictionary = {}
		ranks_by_suit.append(ranks)
	for tile in all_scoring_tiles(seat, tiles):
		var code = str(tile)
		if not is_number_tile(code):
			continue
		var index = tile_index(code)
		if index < 0 or index >= 27:
			continue
		var suit = int(index / 9)
		var rank = index % 9
		(ranks_by_suit[suit] as Dictionary)[rank] = true
	for suit in range(3):
		var ranks: Dictionary = ranks_by_suit[suit]
		var complete = true
		for rank in range(9):
			if not ranks.has(rank):
				complete = false
				break
		if complete:
			return suit
	return -1

func is_all_triplet_hand(seat: int, tiles: Array) -> bool:
	for meld in players[seat]["melds"]:
		if meld.size() < 3:
			return false
		var first = str(meld[0])
		for tile in meld:
			if str(tile) != first:
				return false
	return can_form_triplets_with_pair(tiles)

func can_form_triplets_with_pair(tiles: Array) -> bool:
	if tiles.size() % 3 != 2:
		return false
	var counts = tile_counts(tiles)
	var pair_found = false
	for count in counts:
		var amount = int(count)
		if amount == 0:
			continue
		if amount == 2 and not pair_found:
			pair_found = true
		elif amount == 3:
			continue
		else:
			return false
	return pair_found

func all_scoring_tiles(seat: int, tiles: Array) -> Array:
	var result = tiles.duplicate()
	for meld in players[seat]["melds"]:
		for tile in meld:
			result.append(tile)
	return result

func count_gang_melds(seat: int) -> int:
	var amount = 0
	for meld in players[seat]["melds"]:
		if meld.size() == 4:
			amount += 1
	return amount


func make_tile_view(tile: String, size: Vector2, clickable: bool, callback: Callable, highlighted: bool = false, risk: String = "", hint_badge: String = "") -> Control:
	var lightweight_static_tile = should_use_lightweight_static_tile(clickable, size)
	var frame: Control = null
	var tile_body: Control
	var button: Button = null
	if lightweight_static_tile:
		var panel = Panel.new()
		panel.custom_minimum_size = size
		panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		panel.clip_contents = true
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tile_body = panel
	elif clickable:
		frame = Control.new()
		frame.custom_minimum_size = size
		frame.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		frame.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		frame.mouse_filter = Control.MOUSE_FILTER_PASS
		frame.clip_contents = true
		button = Button.new()
		button.text = ""
		button.custom_minimum_size = size
		button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		button.clip_contents = true
		configure_touch_button(button)
		tile_body = button
	else:
		frame = Control.new()
		frame.custom_minimum_size = size
		frame.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		frame.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		frame.mouse_filter = Control.MOUSE_FILTER_PASS
		frame.clip_contents = true
		var panel = Panel.new()
		panel.custom_minimum_size = size
		panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		panel.clip_contents = true
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tile_body = panel
	if frame != null:
		frame.add_child(tile_body)
		apply_centered_rect(tile_body, Vector2(0.5, 0.5), size)
	# 优化的牌面边框和颜色 - 使用国风配色
	var risk_text = risk_badge_text(risk)
	var border = tile_risk_color(risk) if risk_text != "" else GOLD_DARK
	if highlighted:
		border = GOLD_BRIGHT
	var face = PORCELAIN if not highlighted else Color(1.0, 0.98, 0.92, 1.0)
	if button != null:
		# 可点击牌面的增强样式
		button.add_theme_stylebox_override("normal", style(face, 8, border, 2, 6))
		button.add_theme_stylebox_override("hover", style(Color(0.98, 0.96, 0.90), 8, GOLD_PRIMARY, 3, 8))
		button.add_theme_stylebox_override("pressed", style(Color(0.96, 0.94, 0.88), 8, GOLD_DARK, 2, 4))
		button.add_theme_stylebox_override("disabled", style(face.darkened(0.08), 8, border.darkened(0.12), 1, 3))
		# 手牌hover发光效果 - 可点击牌专用 / Hand tile hover glow
		button.mouse_entered.connect(func() -> void:
			if not is_instance_valid(button):
				return
			var glow_rect = ColorRect.new()
			glow_rect.name = "TileHoverGlow"
			glow_rect.color = Color(GOLD_GLOW.r, GOLD_GLOW.g, GOLD_GLOW.b, 0.0)
			glow_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
			glow_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
			button.add_child(glow_rect)
			button.move_child(glow_rect, 0)
			var g_tw := button.create_tween()
			g_tw.tween_property(glow_rect, "color:a", 0.14, 0.18).from(0.0).set_ease(Tween.EASE_OUT)
		)
		button.mouse_exited.connect(func() -> void:
			if not is_instance_valid(button):
				return
			var glow_rect = button.get_node_or_null("TileHoverGlow")
			if glow_rect != null and is_instance_valid(glow_rect):
				var g_tw := button.create_tween()
				g_tw.tween_property(glow_rect, "color:a", 0.0, 0.14).from(glow_rect.color.a).set_ease(Tween.EASE_IN)
				g_tw.tween_callback(func() -> void:
					if glow_rect != null and is_instance_valid(glow_rect):
						glow_rect.queue_free()
				)
		)
	else:
		(tile_body as Panel).add_theme_stylebox_override("panel", style(face, 8, border, 2 if not highlighted else 3, static_tile_shadow_size(size)))
	var tile_texture = tile_textures.get(tile, null)
	if tile_texture != null:
		if not lightweight_static_tile:
			# 优化的牌面阴影效果 - 更柔和的视觉层次
			var shade = ColorRect.new()
			shade.color = Color(0.50, 0.45, 0.35, 0.18)
			shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
			shade.set_anchors_preset(Control.PRESET_FULL_RECT)
			shade.offset_left = size.x * 0.76
			shade.offset_top = size.y * 0.05
			shade.offset_right = -2
			shade.offset_bottom = -2
			tile_body.add_child(shade)
			# 添加内部高光效果
			var highlight = ColorRect.new()
			highlight.color = Color(1.0, 1.0, 0.98, 0.08)
			highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
			highlight.set_anchors_preset(Control.PRESET_FULL_RECT)
			highlight.offset_left = 3
			highlight.offset_top = 3
			highlight.offset_right = -size.x * 0.7
			highlight.offset_bottom = -size.y * 0.5
			tile_body.add_child(highlight)
		var texture = TextureRect.new()
		texture.texture = tile_texture
		texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		texture.modulate = Color(1, 1, 1, tile_art_alpha(tile, size))
		texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
		texture.set_anchors_preset(Control.PRESET_FULL_RECT)
		var inset_x = max(2, int(size.x * 0.07)) if lightweight_static_tile else max(3, int(size.x * 0.08))
		var inset_y = max(2, int(size.y * 0.06)) if lightweight_static_tile else max(3, int(size.y * 0.07))
		texture.offset_left = inset_x
		texture.offset_top = inset_y
		texture.offset_right = -inset_x
		texture.offset_bottom = -inset_y
		tile_body.add_child(texture)
	if should_draw_tile_face_label(tile, tile_texture, lightweight_static_tile):
		if lightweight_static_tile:
			draw_compact_tile_face(tile_body, tile, size)
		else:
			draw_tile_face(tile_body, tile, size)
	if should_draw_tile_corner(clickable, size, tile_texture, lightweight_static_tile):
		var corner = Label.new()
		corner.text = tile_corner(tile)
		corner.mouse_filter = Control.MOUSE_FILTER_IGNORE
		corner.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		corner.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		corner.add_theme_font_size_override("font_size", max(9, int(size.y * 0.16)))
		corner.add_theme_color_override("font_color", tile_accent(tile))
		tile_body.add_child(corner)
		apply_rect(corner, rect_full(0.08, 0.04, 0.45, 0.30))
	if TILE_TEXT_OVERLAYS_ENABLED and risk_text != "":
		var badge = make_label(tile_body, risk_text, max(9, int(size.y * 0.14)), Color(1.0, 0.98, 0.90), true)
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var risk_color = tile_risk_color(risk)
		badge.add_theme_stylebox_override("normal", style(risk_color.darkened(0.20), 8, risk_color.lightened(0.16), 1))
		apply_rect(badge, rect_full(0.12, 0.76, 0.88, 0.96))
	if TILE_TEXT_OVERLAYS_ENABLED and hint_badge != "":
		var hint = make_label(tile_body, hint_badge, max(9, int(size.y * 0.13)), Color(0.09, 0.12, 0.08), true)
		hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hint.clip_text = true
		var hint_color = tile_hint_badge_color(hint_badge)
		hint.add_theme_stylebox_override("normal", style(hint_color, 8, hint_color.lightened(0.16), 1))
		var left = 0.50 if hint_badge.length() > 1 else 0.62
		apply_rect(hint, rect_full(left, 0.04, 0.92, 0.23))
	if button != null:
		add_clickable_tile_press_art(button, size, highlighted)
	if button != null and callback.is_valid():
		connect_immediate_button_action(button, callback)
	return tile_body if lightweight_static_tile else frame

func add_clickable_tile_press_art(button: Button, size: Vector2, highlighted: bool) -> void:
	var focus_glow = Panel.new()
	focus_glow.name = "ClickableTileFocusGlow"
	focus_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	focus_glow.add_theme_stylebox_override("panel", style(Color(1.0, 0.92, 0.58, 0.0), 8, GOLD_BRIGHT, 2, 0))
	focus_glow.modulate = Color(1.0, 1.0, 1.0, 0.48 if highlighted else 0.0)
	button.add_child(focus_glow)
	apply_rect(focus_glow, rect_full(0.035, 0.035, 0.965, 0.965))

	var sheen = ColorRect.new()
	sheen.name = "ClickableTilePressSheen"
	sheen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sheen.color = Color(1.0, 0.93, 0.60, 0.0)
	button.add_child(sheen)
	apply_rect(sheen, rect_full(0.12, 0.07, 0.88, 0.16))

	var tap_dot = Panel.new()
	tap_dot.name = "ClickableTileTapDot"
	tap_dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tap_dot.add_theme_stylebox_override("panel", style(Color(1.0, 0.92, 0.48, 0.30), max(6, int(size.x * 0.16)), Color(1.0, 0.96, 0.78, 0.42), 1, 0))
	tap_dot.modulate = Color(1.0, 1.0, 1.0, 0.0)
	tap_dot.scale = Vector2(0.58, 0.58)
	button.add_child(tap_dot)
	apply_rect(tap_dot, rect_full(0.37, 0.40, 0.63, 0.60))

	button.button_down.connect(func() -> void:
		if not is_instance_valid(button) or not is_instance_valid(sheen) or not is_instance_valid(tap_dot):
			return
		var tw := button.create_tween()
		tw.set_parallel(true)
		tw.tween_property(sheen, "color:a", 0.28, 0.05).from(0.0)
		tw.tween_property(sheen, "color:a", 0.0, 0.16).set_delay(0.05)
		tw.tween_property(tap_dot, "modulate:a", 0.62, 0.05).from(0.0)
		tw.tween_property(tap_dot, "modulate:a", 0.0, 0.18).set_delay(0.05)
		tw.tween_property(tap_dot, "scale", Vector2(1.12, 1.12), 0.18).from(Vector2(0.58, 0.58)).set_ease(Tween.EASE_OUT)
		if is_instance_valid(focus_glow) and not highlighted:
			tw.tween_property(focus_glow, "modulate:a", 0.35, 0.05).from(0.0)
			tw.tween_property(focus_glow, "modulate:a", 0.0, 0.18).set_delay(0.05)
	)

func tile_hint_badge_color(hint_badge: String) -> Color:
	return HINT_BADGE_COLORS.get(hint_badge, DEFAULT_HINT_BADGE_COLOR)

func should_draw_tile_corner(clickable: bool, size: Vector2, texture: Texture2D, _lightweight_static_tile: bool) -> bool:
	return TILE_TEXT_OVERLAYS_ENABLED and texture == null and (clickable or size.x >= 50.0)

func should_use_lightweight_static_tile(clickable: bool, size: Vector2) -> bool:
	return not clickable and size.x < 50.0

func static_tile_shadow_size(size: Vector2) -> int:
	if size.x < 50.0:
		return 0
	if size.x < 60.0:
		return 3
	return 8

func should_draw_tile_face_label(tile: String, texture: Texture2D, _lightweight_static_tile: bool) -> bool:
	return TILE_TEXT_OVERLAYS_ENABLED and tile != "" and texture == null

func tile_art_alpha(tile: String, size: Vector2) -> float:
	if size.x < 30.0:
		return 0.62
	if size.x >= 50.0:
		return 1.0
	if is_flower_tile(tile):
		return 0.94
	if is_honor_tile(tile):
		return 0.94
	return 0.96

func draw_tile_face(parent: Control, tile: String, size: Vector2) -> void:
	var main = make_label(parent, tile_face_main(tile), tile_face_font_size(size), tile_accent(tile), true)
	main.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main.clip_text = true
	var sub_text = tile_face_sub(tile)
	if is_number_tile(tile):
		apply_rect(main, rect_full(0.18, 0.22, 0.82, 0.64))
	else:
		apply_rect(main, rect_full(0.12, 0.20, 0.88, 0.72))
	if sub_text != "" and size.y >= 40:
		var sub = make_label(parent, sub_text, max(9, int(size.y * 0.20)), tile_accent(tile).darkened(0.08), true)
		sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
		sub.clip_text = true
		apply_rect(sub, rect_full(0.16, 0.58, 0.84, 0.83))

func draw_compact_tile_face(parent: Control, tile: String, size: Vector2) -> void:
	var face = make_label(parent, tile_label(tile), compact_tile_face_font_size(size), tile_accent(tile), true)
	face.mouse_filter = Control.MOUSE_FILTER_IGNORE
	face.clip_text = true
	apply_rect(face, rect_full(0.08, 0.15, 0.92, 0.85))

func tile_face_main(tile: String) -> String:
	if not tile_metadata_ready:
		setup_tile_order()
	if tile_face_main_cache.has(tile):
		return str(tile_face_main_cache[tile])
	if is_number_tile(tile):
		return tile.left(tile.length() - 1)
	return tile_label(tile)

func tile_face_sub(tile: String) -> String:
	if not tile_metadata_ready:
		setup_tile_order()
	if tile_face_sub_cache.has(tile):
		return str(tile_face_sub_cache[tile])
	if tile.ends_with("W"):
		return "万"
	if tile.ends_with("T"):
		return "条"
	if tile.ends_with("B"):
		return "筒"
	if is_flower_tile(tile):
		return "花"
	if ["E", "S", "N", "R"].has(tile):
		return "风"
	if ["Z", "F", "P"].has(tile):
		return "箭"
	return ""

func tile_face_font_size(size: Vector2) -> int:
	return max(10, int(size.y * 0.42))

func compact_tile_face_font_size(size: Vector2) -> int:
	return max(9, int(size.y * 0.32))

func risk_badge_text(risk: String) -> String:
	return RISK_BADGE_TEXT.get(risk, "")

func tile_risk_color(risk: String) -> Color:
	return RISK_BADGE_COLORS.get(risk, DEFAULT_RISK_BADGE_COLOR)

func make_action_button(text: String, color: Color, callback: Callable) -> Button:
	var button = make_base_button(text, callback)
	configure_action_button_size(button, ACTION_BUTTON_MIN_TOUCH_WIDTH, ACTION_BUTTON_HEIGHT, 19)
	apply_button_style(button, color, 14, 2, 3)
	draw_action_button_art(button, text, color)
	return button

func draw_action_button_art(button: Button, text: String, color: Color) -> Control:
	var art = Control.new()
	art.name = "ActionButtonArt"
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(art, rect_full(0.030, 0.120, 0.245, 0.880))
	button.add_child(art)
	var role = action_button_visual_role(text)
	var role_rail = make_color_rect(rect_full(0.000, 0.120, 0.018, 0.880), Color(color.r, color.g, color.b, 0.74))
	role_rail.name = "ActionButtonRoleRail"
	button.add_child(role_rail)
	for i in range(3):
		var dot = make_color_rect(rect_full(0.730 + float(i) * 0.070, 0.800, 0.760 + float(i) * 0.070, 0.850), Color(color.r, color.g, color.b, 0.44 - float(i) * 0.08))
		dot.name = "ActionButtonEnergyDot_%d" % i
		button.add_child(dot)
	var icon_back = make_panel(art, rect_full(0.040, 0.080, 0.700, 0.920), Color(color.r, color.g, color.b, 0.20), 999, Color(color.r, color.g, color.b, 0.32), 0)
	icon_back.name = "ActionButtonIconBack"
	var icon_name = action_button_icon_name(role)
	var icon_color = Color(0.96, 0.94, 0.82, 0.88)
	if icon_name != "":
		add_lucide_icon(art, icon_name, rect_full(0.160, 0.235, 0.580, 0.765), icon_color)
	else:
		var fallback = make_label(art, action_button_fallback_icon_text(role, text), 10, icon_color, true)
		fallback.name = "ActionButtonFallbackIcon"
		apply_rect(fallback, rect_full(0.100, 0.150, 0.640, 0.850))
	var sheen = make_panel(button, rect_full(0.060, 0.075, 0.940, 0.155), Color(1.0, 1.0, 1.0, 0.030), 999, Color(1.0, 1.0, 1.0, 0.0), 0)
	sheen.name = "ActionButtonSheen"
	if role in ["win", "gang", "safe", "advice", "pass"]:
		var seal = make_label(button, action_button_priority_mark(role), 10, Color(0.98, 0.90, 0.62, 0.78), true)
		seal.name = "ActionButtonPrioritySeal"
		apply_rect(seal, rect_full(0.740, 0.145, 0.940, 0.455))
	if action_button_should_pulse(role) and fx_enabled_effective():
		var pulse = make_panel(button, rect_full(0.012, 0.090, 0.988, 0.910), Color(color.r, color.g, color.b, 0.06), 14, Color(color.r, color.g, color.b, 0.20), 0)
		pulse.name = "ActionButtonPulse"
		button.move_child(pulse, 0)
		var tw := create_tween()
		tw.set_loops(12)
		tw.tween_property(pulse, "modulate:a", 0.25, 0.64).from(0.84)
		tw.tween_property(pulse, "modulate:a", 0.84, 0.64).from(0.25)
	return art

func action_button_visual_role(text: String) -> String:
	if text.contains("过") or text.contains("取消"):
		return "pass"
	if text.contains("胡") or text.contains("自摸"):
		return "win"
	if text.contains("杠"):
		return "gang"
	if text.contains("碰"):
		return "peng"
	if text.contains("吃"):
		return "chi"
	if text.contains("改打") or text.contains("安全"):
		return "safe"
	if text.contains("打") or text.contains("荐") or text.contains("提示"):
		return "advice"
	if text.contains("语音") or text.contains("闭麦"):
		return "voice"
	if text.contains("菜单"):
		return "menu"
	if text.contains("下一") or text.contains("新赛") or text.contains("重开"):
		return "refresh"
	return "action"

func action_button_icon_name(role: String) -> String:
	match role:
		"pass":
			return "x"
		"win":
			return "trophy"
		"gang":
			return "crown"
		"safe":
			return "check"
		"advice":
			return "sparkles"
		"voice":
			return "volume-2"
		"menu":
			return "menu"
		"refresh":
			return "refresh-cw"
	return ""

func action_button_fallback_icon_text(role: String, text: String) -> String:
	match role:
		"chi":
			return "吃"
		"peng":
			return "碰"
		"action":
			return text.substr(0, 1) if text != "" else "行"
	return role.substr(0, 1) if role != "" else "行"

func action_button_priority_mark(role: String) -> String:
	match role:
		"win":
			return "胡"
		"gang":
			return "杠"
		"safe":
			return "安"
		"advice":
			return "荐"
		"pass":
			return "过"
	return ""

func action_button_should_pulse(role: String) -> bool:
	return role in ["win", "gang", "safe", "advice"]

func configure_action_button_size(button: Button, width: float, height: float, font_size: int) -> void:
	button.custom_minimum_size = Vector2(width, height)
	button.clip_text = true
	button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	button.add_theme_font_size_override("font_size", font_size)

func make_avatar_view(seat: int, active: bool) -> Control:
	var avatar = Panel.new()
	avatar.clip_contents = true
	avatar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var border = Color(0.66, 0.58, 0.40, 0.52) if active else SEAT_AVATAR_BORDER_COLORS[seat].blend(Color(0.28, 0.27, 0.26, 1.0))
	avatar.add_theme_stylebox_override("panel", style(Color(0.018, 0.038, 0.042, 0.96), 13, border, 1))
	var band = ColorRect.new()
	band.color = SEAT_AVATAR_BAND_COLORS[seat].blend(Color(0.12, 0.14, 0.14, 1.0))
	band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	avatar.add_child(band)
	apply_rect(band, rect_full(0.0, 0.0, 1.0, 0.22))
	var cap = ColorRect.new()
	cap.color = Color(1.0, 1.0, 1.0, 0.045)
	cap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	avatar.add_child(cap)
	apply_rect(cap, rect_full(0.0, 0.22, 1.0, 0.26))
	draw_avatar_figure(avatar, seat, active)

	# 为不同座位添加独特的装饰元素
	match seat:
		0:  # 玩家 - 东风
			var decoration = make_label(avatar, "☀", 16, Color(0.96, 0.84, 0.52, 0.72), true)
			decoration.mouse_filter = Control.MOUSE_FILTER_IGNORE
			apply_rect(decoration, rect_full(0.72, 0.04, 0.96, 0.26))
		1:  # 青竹道人 - 南风 - 竹叶装饰
			var bamboo1 = make_label(avatar, "竹", 10, Color(0.38, 0.62, 0.42, 0.58), true)
			bamboo1.mouse_filter = Control.MOUSE_FILTER_IGNORE
			apply_rect(bamboo1, rect_full(0.76, 0.04, 0.94, 0.20))
			var bamboo2 = make_label(avatar, "竹", 8, Color(0.42, 0.66, 0.46, 0.48), true)
			bamboo2.mouse_filter = Control.MOUSE_FILTER_IGNORE
			apply_rect(bamboo2, rect_full(0.68, 0.10, 0.82, 0.24))
		2:  # 南山客 - 西风 - 山峰装饰
			var mountain = make_label(avatar, "⛰", 12, Color(0.56, 0.52, 0.48, 0.62), true)
			mountain.mouse_filter = Control.MOUSE_FILTER_IGNORE
			apply_rect(mountain, rect_full(0.70, 0.06, 0.96, 0.24))
		3:  # 扶摇散人 - 北风 - 云朵装饰
			var cloud = make_label(avatar, "☁", 11, Color(0.72, 0.76, 0.82, 0.56), true)
			cloud.mouse_filter = Control.MOUSE_FILTER_IGNORE
			apply_rect(cloud, rect_full(0.68, 0.06, 0.94, 0.22))

	var seat_mark = make_label(avatar, seat_wind_label(seat), 33, Color(0.88, 0.82, 0.66), true)
	seat_mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(seat_mark, rect_full(0.10, 0.22, 0.90, 0.70))
	var name = make_label(avatar, seat_short_name(seat), 12, Color(0.70, 0.80, 0.76), false)
	name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(name, rect_full(0.08, 0.68, 0.92, 0.90))
	if active:
		var active_badge = make_label(avatar, "行牌", 11, Color(0.12, 0.13, 0.10), true)
		active_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		active_badge.add_theme_stylebox_override("normal", style(Color(0.66, 0.56, 0.22, 0.82), 8, Color(0.84, 0.76, 0.46, 0.22), 1))
		apply_rect(active_badge, rect_full(0.18, 0.06, 0.82, 0.25))
	return avatar

func draw_avatar_figure(parent: Control, seat: int, active: bool) -> void:
	var accent = SEAT_ACCENT_COLORS[seat] if seat >= 0 and seat < SEAT_ACCENT_COLORS.size() else GOLD_PRIMARY
	if active:
		var halo = make_panel(parent, rect_full(0.18, 0.24, 0.82, 0.72), Color(accent.r, accent.g, accent.b, 0.10), 999, Color(0.96, 0.82, 0.42, 0.32), 0)
		halo.name = "SeatAvatarActiveHalo"
	var shoulders = make_panel(parent, rect_full(0.25, 0.52, 0.75, 0.90), Color(accent.r * 0.55, accent.g * 0.55, accent.b * 0.55, 0.56), 999, Color(accent.r, accent.g, accent.b, 0.20), 0)
	shoulders.name = "SeatAvatarShoulders"
	var head = make_panel(parent, rect_full(0.34, 0.28, 0.66, 0.58), Color(0.78, 0.68, 0.50, 0.58), 999, Color(0.92, 0.82, 0.58, 0.22), 0)
	head.name = "SeatAvatarHead"
	var seal_text = seat_wind_label(seat)
	var seal = make_seal_stamp(parent, rect_full(0.05, 0.06, 0.27, 0.30), seal_text, "round")
	seal.name = "SeatAvatarWindSeal"

func seat_wind_label(seat: int) -> String:
	match seat:
		0:
			return "东"
		1:
			return "南"
		2:
			return "西"
		3:
			return "北"
	return "位"

func seat_short_name(seat: int) -> String:
	if seat >= 0 and seat < SEAT_NAMES.size():
		if seat == 0:
			return "你"
		return SEAT_NAMES[seat].substr(0, 2)
	return "玩家"

# ===== 动画 / 特效 (FX) =====
# fx_layer 是 self 的直接子节点，覆盖整个视口并在 clear_screen 中被保留。
# 所有动画节点挂在其下，因此整桌每次 render_game 重建时补间动画不会被中断。
# 所有动效都使用持久节点上的 tween 驱动，fx 关闭或离开牌桌时立刻清空，空闲时零开销。

func ensure_fx_layer() -> void:
	if fx_layer != null and is_instance_valid(fx_layer):
		return
	fx_layer = Control.new()
	fx_layer.name = "FxLayer"
	fx_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	fx_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fx_layer.z_index = FX_LAYER_Z_INDEX
	add_child(fx_layer)
	_build_fx_turn_pulse()
	_build_fx_burst()
	_build_fx_ripple()
	_build_fx_transition()
	_build_fx_toast()

func _build_fx_turn_pulse() -> void:
	fx_turn_pulse = Control.new()
	fx_turn_pulse.name = "TurnPulse"
	fx_turn_pulse.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fx_turn_pulse.visible = false
	fx_layer.add_child(fx_turn_pulse)
	fx_turn_glow = Panel.new()
	fx_turn_glow.name = "TurnGlow"
	fx_turn_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fx_turn_glow.set_anchors_preset(Control.PRESET_FULL_RECT)
	fx_turn_glow.modulate.a = 0.0
	fx_turn_pulse.add_child(fx_turn_glow)
	fx_turn_pulse_tween = create_tween()
	fx_turn_pulse_tween.set_loops(3600)
	var half_pulse := float(FX_TURN_PULSE_PERIOD_MSEC) / 2000.0
	fx_turn_pulse_tween.tween_property(fx_turn_glow, "modulate:a", 0.95, half_pulse).from(0.40)
	fx_turn_pulse_tween.tween_property(fx_turn_glow, "modulate:a", 0.40, half_pulse).from(0.95)
	fx_turn_pulse_tween.pause()

func _build_fx_burst() -> void:
	fx_burst_root = Control.new()
	fx_burst_root.name = "WinBurst"
	fx_burst_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fx_burst_root.visible = false
	fx_layer.add_child(fx_burst_root)
	fx_burst_flash = ColorRect.new()
	fx_burst_flash.name = "Flash"
	fx_burst_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fx_burst_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	fx_burst_flash.color = Color(1.0, 0.90, 0.55, 0.0)
	fx_burst_root.add_child(fx_burst_flash)
	fx_burst_rings.clear()
	for i in range(FX_WIN_RING_COUNT):
		var ring = Panel.new()
		ring.name = "Ring%d" % i
		ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ring.set_anchors_preset(Control.PRESET_CENTER)
		fx_burst_root.add_child(ring)
		fx_burst_rings.append(ring)
	fx_burst_label = Label.new()
	fx_burst_label.name = "BurstLabel"
	fx_burst_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fx_burst_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	fx_burst_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	fx_burst_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	fx_burst_label.add_theme_font_size_override("font_size", FX_BURST_LABEL_FONT_SIZE)
	fx_burst_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.72))
	fx_burst_label.add_theme_constant_override("shadow_offset_x", 2)
	fx_burst_label.add_theme_constant_override("shadow_offset_y", 3)
	fx_burst_label.modulate.a = 0.0
	fx_burst_root.add_child(fx_burst_label)

func _build_fx_ripple() -> void:
	fx_ripple_root = Control.new()
	fx_ripple_root.name = "DiscardRipple"
	fx_ripple_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fx_ripple_root.visible = false
	fx_layer.add_child(fx_ripple_root)
	fx_ripple_rings.clear()
	for i in range(2):
		var ring = Panel.new()
		ring.name = "Ripple%d" % i
		ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ring.set_anchors_preset(Control.PRESET_CENTER)
		fx_ripple_root.add_child(ring)
		fx_ripple_rings.append(ring)


# 把 root_layer（已扣除安全区）相对的归一化锚点矩形换算成覆盖整个视口的归一化锚点矩形，
# 这样挂在全视口 fx_layer 上的特效节点可以对齐到座位等牌桌元素。
func root_layer_rect_to_screen_rect_for(layer_rect: Rect2, viewport_size: Vector2, margins: Vector4) -> Rect2:
	var vp_w = viewport_size.x if viewport_size.x > 0.0 else 1.0
	var vp_h = viewport_size.y if viewport_size.y > 0.0 else 1.0
	var content_w = max(1.0, vp_w - margins.x - margins.z)
	var content_h = max(1.0, vp_h - margins.y - margins.w)
	var left = (margins.x + layer_rect.position.x * content_w) / vp_w
	var top = (margins.y + layer_rect.position.y * content_h) / vp_h
	var right = (margins.x + layer_rect.size.x * content_w) / vp_w
	var bottom = (margins.y + layer_rect.size.y * content_h) / vp_h
	return Rect2(Vector2(left, top), Vector2(right, bottom))

func root_layer_rect_to_screen_rect(layer_rect: Rect2) -> Rect2:
	return root_layer_rect_to_screen_rect_for(layer_rect, effective_viewport_size(), safe_area_margins)

func fx_seat_screen_rect(seat: int) -> Rect2:
	for layout in SEAT_LAYOUTS:
		if int(layout[0]) == seat:
			return root_layer_rect_to_screen_rect(layout[1])
	return root_layer_rect_to_screen_rect(Rect2(Vector2(0.40, 0.40), Vector2(0.60, 0.60)))

func update_fx_turn_pulse() -> void:
	if fx_turn_pulse == null or not is_instance_valid(fx_turn_pulse):
		return
	# 提前退出：特效未启用时避免后续计算
	if not fx_enabled_effective() or settings_panel_open or (mode != "offline" and mode != "online_game"):
		fx_turn_pulse.visible = false
		var tween_running = fx_turn_pulse_tween != null and is_instance_valid(fx_turn_pulse_tween)
		if tween_running and fx_turn_pulse_tween.is_running():
			fx_turn_pulse_tween.pause()
		return
	var tween_running = fx_turn_pulse_tween != null and is_instance_valid(fx_turn_pulse_tween)
	var seat = get_current_seat()
	apply_rect(fx_turn_pulse, fx_seat_screen_rect(seat))
	var accent = SEAT_ACCENT_COLORS[seat] if seat >= 0 and seat < SEAT_ACCENT_COLORS.size() else UI_GOLD
	fx_turn_glow.add_theme_stylebox_override("panel", style(Color(accent.r * 0.18, accent.g * 0.18, accent.b * 0.18, 0.08), 22, Color(accent.r, accent.g, accent.b, 0.30), 2, 0))
	fx_turn_pulse.visible = true
	if tween_running:
		fx_turn_pulse_tween.play()

func play_fx_win_burst(text: String, color: Color) -> void:
	if not fx_enabled_effective() or fx_burst_root == null or not is_instance_valid(fx_burst_root):
		return
	if fx_burst_tween != null and is_instance_valid(fx_burst_tween):
		fx_burst_tween.kill()
	apply_rect(fx_burst_root, rect_full(0.18, 0.24, 0.82, 0.76))
	fx_burst_flash.color = Color(color.r, color.g, color.b, 0.0)
	for ring in fx_burst_rings:
		ring.modulate.a = 0.0
		ring.add_theme_stylebox_override("panel", style(Color(0, 0, 0, 0), 60, color.darkened(0.18), 3, 0))
		ring.offset_left = -42.0
		ring.offset_top = -42.0
		ring.offset_right = 42.0
		ring.offset_bottom = 42.0
	fx_burst_label.text = text
	fx_burst_label.add_theme_color_override("font_color", color)
	fx_burst_label.modulate.a = 0.0
	fx_burst_label.offset_top = 28.0
	fx_burst_label.offset_bottom = 28.0
	fx_burst_root.visible = true
	var half := float(FX_WIN_BURST_DURATION_MSEC) / 1000.0
	var tw := create_tween()
	fx_burst_tween = tw
	tw.set_parallel(true)
	tw.tween_property(fx_burst_flash, "color:a", 0.10, 0.18).from(0.0)
	tw.tween_property(fx_burst_flash, "color:a", 0.0, 0.55).set_delay(max(0.0, half - 0.55))
	tw.tween_property(fx_burst_label, "modulate:a", 1.0, 0.22).from(0.0)
	tw.tween_property(fx_burst_label, "modulate:a", 0.0, 0.45).set_delay(max(0.0, half - 0.45))
	tw.tween_property(fx_burst_label, "offset_top", -16.0, half).from(28.0)
	tw.tween_property(fx_burst_label, "offset_bottom", -16.0, half).from(28.0)
	for i in range(fx_burst_rings.size()):
		var ring = fx_burst_rings[i]
		var delay = float(i) * 0.10
		var span = max(0.30, half - delay)
		tw.tween_property(ring, "modulate:a", 0.0, span).from(0.72).set_delay(delay)
		tw.tween_property(ring, "offset_left", -185.0, span).from(-42.0).set_delay(delay)
		tw.tween_property(ring, "offset_top", -185.0, span).from(-42.0).set_delay(delay)
		tw.tween_property(ring, "offset_right", 185.0, span).from(42.0).set_delay(delay)
		tw.tween_property(ring, "offset_bottom", 185.0, span).from(42.0).set_delay(delay)
	tw.tween_callback(_hide_fx_burst).set_delay(half + 0.05)

func _hide_fx_burst() -> void:
	if fx_burst_root != null and is_instance_valid(fx_burst_root):
		fx_burst_root.visible = false

func play_fx_deal_start(dealer: int) -> void:
	if not fx_enabled_effective():
		return
	var root = Control.new()
	root.name = "DealStartFx"
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	fx_layer.add_child(root)
	var center_rect = root_layer_rect_to_screen_rect(CENTER_PANEL_RECT)
	var center = (center_rect.position + center_rect.size) * 0.5
	var accent = SEAT_ACCENT_COLORS[dealer] if dealer >= 0 and dealer < SEAT_ACCENT_COLORS.size() else GOLD_PRIMARY
	for i in range(4):
		var seat = (dealer + i) % 4
		var seat_rect = fx_seat_screen_rect(seat)
		var target = (seat_rect.position + seat_rect.size) * 0.5
		var tile = make_wall_back_tile(Vector2(24, 34), true)
		tile.name = "DealStartTile_%d" % seat
		tile.modulate = Color(1, 1, 1, 0.0)
		tile.scale = Vector2(0.55, 0.55)
		root.add_child(tile)
		var viewport_size = effective_viewport_size()
		tile.position = Vector2(center.x * viewport_size.x - 12.0, center.y * viewport_size.y - 17.0)
		var target_position = Vector2(target.x * viewport_size.x - 12.0, target.y * viewport_size.y - 17.0)
		var delay = float(i) * 0.055
		var tw := create_tween()
		tw.set_parallel(true)
		tw.tween_property(tile, "modulate:a", 0.80, 0.12).from(0.0).set_delay(delay)
		tw.tween_property(tile, "position", target_position, 0.46).set_delay(delay).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(tile, "scale", Vector2(0.88, 0.88), 0.28).from(Vector2(0.55, 0.55)).set_delay(delay).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(tile, "modulate:a", 0.0, 0.18).set_delay(delay + 0.34)
	var ring_root = Control.new()
	ring_root.name = "DealStartRing"
	ring_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(ring_root, center_rect)
	root.add_child(ring_root)
	for i in range(3):
		var ring = Panel.new()
		ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ring.set_anchors_preset(Control.PRESET_CENTER)
		ring.add_theme_stylebox_override("panel", style(Color(0, 0, 0, 0), 48, Color(accent.r, accent.g, accent.b, 0.38), 2, 0))
		ring_root.add_child(ring)
		var delay = float(i) * 0.08
		var tw_ring := create_tween()
		tw_ring.set_parallel(true)
		tw_ring.tween_property(ring, "modulate:a", 0.0, 0.42).from(0.62).set_delay(delay)
		tw_ring.tween_property(ring, "offset_left", -72.0, 0.42).from(-16.0).set_delay(delay)
		tw_ring.tween_property(ring, "offset_top", -72.0, 0.42).from(-16.0).set_delay(delay)
		tw_ring.tween_property(ring, "offset_right", 72.0, 0.42).from(16.0).set_delay(delay)
		tw_ring.tween_property(ring, "offset_bottom", 72.0, 0.42).from(16.0).set_delay(delay)
	var cleanup := create_tween()
	cleanup.tween_callback(func() -> void:
		if root != null and is_instance_valid(root):
			root.queue_free()
	).set_delay(0.72)

# 进局发牌级联动画 - 中心牌堆向四家分发连串牌背 / Deal Cascade Animation
func play_fx_deal_cascade(dealer: int) -> void:
	if not fx_enabled_effective():
		return
	var root = Control.new()
	root.name = "DealCascadeFx"
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	fx_layer.add_child(root)
	var viewport_size = effective_viewport_size()
	var center_rect = root_layer_rect_to_screen_rect(CENTER_PANEL_RECT)
	var center = (center_rect.position + center_rect.size) * 0.5
	var accent = SEAT_ACCENT_COLORS[dealer] if dealer >= 0 and dealer < SEAT_ACCENT_COLORS.size() else GOLD_PRIMARY
	var span := float(FX_DEAL_CASCADE_DURATION_MSEC) / 1000.0
	# 向每个座位分发一批牌背，模拟连发手感
	for i in range(4):
		var seat = (dealer + i) % 4
		var seat_rect = fx_seat_screen_rect(seat)
		var target = (seat_rect.position + seat_rect.size) * 0.5
		var target_pos = Vector2(target.x * viewport_size.x, target.y * viewport_size.y)
		var seat_delay = float(i) * 0.05
		for j in range(FX_DEAL_CASCADE_TILE_COUNT):
			var tile = make_wall_back_tile(Vector2(20, 28), true)
			tile.name = "DealCascadeTile_%d_%d" % [seat, j]
			tile.modulate = Color(1, 1, 1, 0.0)
			tile.scale = Vector2(0.5, 0.5)
			tile.position = Vector2(center.x * viewport_size.x, center.y * viewport_size.y)
			root.add_child(tile)
			# 散射偏移：每张落点略错开，模拟真实码牌
			var jitter_x: float = (float(j) - float(FX_DEAL_CASCADE_TILE_COUNT) * 0.5) * 3.0
			var jitter_y: float = (float(j) - float(FX_DEAL_CASCADE_TILE_COUNT) * 0.5) * 2.0
			var land_pos = Vector2(target_pos.x + jitter_x, target_pos.y + jitter_y)
			var step_delay = seat_delay + float(j) * 0.022
			var tw := create_tween()
			tw.set_parallel(true)
			tw.tween_property(tile, "modulate:a", 0.82, 0.10).from(0.0).set_delay(step_delay)
			tw.tween_property(tile, "position", land_pos, 0.30).set_delay(step_delay).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			tw.tween_property(tile, "scale", Vector2(0.78, 0.78), 0.22).from(Vector2(0.5, 0.5)).set_delay(step_delay).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tw.tween_property(tile, "modulate:a", 0.0, 0.14).set_delay(step_delay + 0.22)
	# 中心扩散光圈 - 收束感
	var ring_root = Control.new()
	ring_root.name = "DealCascadeRing"
	ring_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(ring_root, center_rect)
	root.add_child(ring_root)
	for i in range(4):
		var ring = Panel.new()
		ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ring.set_anchors_preset(Control.PRESET_CENTER)
		ring.add_theme_stylebox_override("panel", style(Color(0, 0, 0, 0), 56, Color(accent.r, accent.g, accent.b, 0.30), 2, 0))
		ring_root.add_child(ring)
		var delay = float(i) * 0.10
		var tw_ring := create_tween()
		tw_ring.set_parallel(true)
		tw_ring.tween_property(ring, "modulate:a", 0.0, 0.50).from(0.55).set_delay(delay)
		tw_ring.tween_property(ring, "offset_left", -90.0, 0.50).from(-16.0).set_delay(delay)
		tw_ring.tween_property(ring, "offset_top", -90.0, 0.50).from(-16.0).set_delay(delay)
		tw_ring.tween_property(ring, "offset_right", 90.0, 0.50).from(16.0).set_delay(delay)
		tw_ring.tween_property(ring, "offset_bottom", 90.0, 0.50).from(16.0).set_delay(delay)
	var cleanup := create_tween()
	cleanup.tween_callback(func() -> void:
		if root != null and is_instance_valid(root):
			root.queue_free()
	).set_delay(span + 0.45)

# 换手时中心面板轻滑反馈 / Turn-Start Slide Feedback
func play_fx_turn_switch_slide(seat: int) -> void:
	if not fx_enabled_effective() or seat < 0 or seat >= 4:
		return
	if mode != "offline" and mode != "online_game":
		return
	var center_node = screen_layer.get_node_or_null("SafeContent")
	if center_node == null:
		return
	# 找到中心面板节点 - 由 draw_center 创建，无独立name，定位SafeContent下Table层级较深
	# 改为对整个 root_layer 做极轻微的偏移脉冲，避免依赖具体节点名
	var target = root_layer
	if target == null or not is_instance_valid(target):
		return
	var accent = SEAT_ACCENT_COLORS[seat] if seat < SEAT_ACCENT_COLORS.size() else GOLD_PRIMARY
	# 极轻微的缩放呼吸 + 偏色高光，不打扰阅读
	var dur := float(FX_TURN_SWITCH_SLIDE_MSEC) / 1000.0
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(target, "scale", Vector2(1.004, 1.004), dur * 0.5).from(Vector2(0.998, 0.998)).set_ease(Tween.EASE_OUT)
	tw.chain().tween_property(target, "scale", Vector2(1.0, 1.0), dur * 0.5).set_ease(Tween.EASE_IN_OUT)
	# 中心罗盘高光闪
	var compass_halo := make_color_rect(rect_full(0.0, 0.0, 1.0, 1.0), Color(accent.r, accent.g, accent.b, 0.0))
	compass_halo.name = "TurnSwitchHalo"
	compass_halo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if fx_layer != null and is_instance_valid(fx_layer):
		fx_layer.add_child(compass_halo)
		var halo_tw := create_tween()
		halo_tw.tween_property(compass_halo, "color:a", 0.10, dur * 0.4).from(0.0)
		halo_tw.tween_property(compass_halo, "color:a", 0.0, dur * 0.6).from(0.10)
		halo_tw.tween_callback(func() -> void:
			if compass_halo != null and is_instance_valid(compass_halo):
				compass_halo.queue_free()
		)
	target.pivot_offset = target.size * 0.5

func play_fx_discard_ripple(seat: int = -1) -> void:
	if not fx_enabled_effective() or fx_ripple_root == null or not is_instance_valid(fx_ripple_root):
		return
	if fx_ripple_tween != null and is_instance_valid(fx_ripple_tween):
		fx_ripple_tween.kill()
	var ripple_rect = root_layer_rect_to_screen_rect(CENTER_PANEL_RECT)
	if seat >= 0:
		ripple_rect = discard_ripple_rect_for_seat(seat)
	apply_rect(fx_ripple_root, ripple_rect)
	for ring in fx_ripple_rings:
		ring.modulate.a = 0.0
		ring.add_theme_stylebox_override("panel", style(Color(0, 0, 0, 0), 36, Color(0.74, 0.58, 0.22, 0.34), 1, 0))
		ring.offset_left = -16.0
		ring.offset_top = -16.0
		ring.offset_right = 16.0
		ring.offset_bottom = 16.0
	fx_ripple_root.visible = true
	var span := float(FX_DISCARD_RIPPLE_DURATION_MSEC) / 1000.0
	var tw := create_tween()
	fx_ripple_tween = tw
	tw.set_parallel(true)
	for i in range(fx_ripple_rings.size()):
		var ring = fx_ripple_rings[i]
		var delay = float(i) * 0.10
		var dur = max(0.20, span - delay)
		tw.tween_property(ring, "modulate:a", 0.0, dur).from(0.42).set_delay(delay)
		tw.tween_property(ring, "offset_left", -52.0, dur).from(-16.0).set_delay(delay)
		tw.tween_property(ring, "offset_top", -52.0, dur).from(-16.0).set_delay(delay)
		tw.tween_property(ring, "offset_right", 52.0, dur).from(16.0).set_delay(delay)
		tw.tween_property(ring, "offset_bottom", 52.0, dur).from(16.0).set_delay(delay)
	tw.tween_callback(_hide_fx_ripple).set_delay(span + 0.05)

func discard_ripple_rect_for_seat(seat: int) -> Rect2:
	var base_rect = root_layer_rect_to_screen_rect(CENTER_PANEL_RECT)
	for zone in DISCARD_ZONES:
		if int(zone[0]) == seat:
			var screen_rect = root_layer_rect_to_screen_rect(zone[1])
			var zone_size = screen_rect.size - screen_rect.position
			var center = (screen_rect.position + screen_rect.size) * 0.5
			var size = Vector2(
				clamp(zone_size.x * 0.46, 0.08, 0.18),
				clamp(zone_size.y * 0.70, 0.08, 0.18)
			)
			return Rect2(center - size * 0.5, center + size * 0.5)
	return base_rect

func _hide_fx_ripple() -> void:
	if fx_ripple_root != null and is_instance_valid(fx_ripple_root):
		fx_ripple_root.visible = false

func play_hand_draw_tile_animation(tile_node: Control, source: String = "normal") -> void:
	if not fx_enabled_effective() or tile_node == null or not is_instance_valid(tile_node):
		return
	var rest_y = tile_node.position.y
	var accent = Color(0.66, 0.58, 0.92) if source == "gang" else GOLD_PRIMARY
	var glow = Panel.new()
	glow.name = "DrawTileGlow"
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glow.set_anchors_preset(Control.PRESET_FULL_RECT)
	glow.modulate = Color(accent.r, accent.g, accent.b, 0.0)
	glow.add_theme_stylebox_override("panel", style(Color(accent.r, accent.g, accent.b, 0.08), 10, Color(accent.r, accent.g, accent.b, 0.42), 2, 0))
	tile_node.add_child(glow)
	tile_node.move_child(glow, 0)
	tile_node.pivot_offset = tile_node.custom_minimum_size * 0.5
	tile_node.position.y = rest_y - 18.0
	tile_node.scale = Vector2(0.92, 0.92)
	tile_node.modulate = Color(1.0, 1.0, 1.0, 0.78)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(tile_node, "position:y", rest_y, 0.22).from(rest_y - 18.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(tile_node, "scale", Vector2(1.0, 1.0), 0.24).from(Vector2(0.92, 0.92)).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(tile_node, "modulate:a", 1.0, 0.16).from(0.78)
	tw.tween_property(glow, "modulate:a", 1.0, 0.12).from(0.0)
	tw.tween_property(glow, "modulate:a", 0.0, 0.28).set_delay(0.14)
	tw.tween_callback(func() -> void:
		if glow != null and is_instance_valid(glow):
			glow.queue_free()
	).set_delay(0.46)

func flower_bloom_text(tile: String) -> String:
	var label = tile_label(tile)
	return "补花" + (label if label != "" else "")

func play_fx_flower_bloom(seat: int, tile: String) -> void:
	if not fx_enabled_effective():
		return
	ensure_fx_layer()
	var seat_rect = fx_seat_screen_rect(seat)
	var viewport_size = effective_viewport_size()
	var center = (seat_rect.position + seat_rect.size) * 0.5
	var root = Control.new()
	root.name = "FlowerBloomFx"
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.position = Vector2(center.x * viewport_size.x, center.y * viewport_size.y)
	root.z_index = FX_LAYER_Z_INDEX + 2
	fx_layer.add_child(root)
	var accent = tile_accent(tile).lightened(0.18)
	var tile_view = make_tile_view(tile, Vector2(42, 58), false, Callable(), true)
	tile_view.name = "FlowerBloomTile"
	tile_view.position = Vector2(-21.0, -34.0)
	tile_view.scale = Vector2(0.72, 0.72)
	tile_view.modulate.a = 0.0
	root.add_child(tile_view)
	var label = make_label(root, flower_bloom_text(tile), 18, Color(0.96, 0.86, 0.52), true)
	label.name = "FlowerBloomLabel"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.76))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 2)
	label.offset_left = -66.0
	label.offset_top = 22.0
	label.offset_right = 66.0
	label.offset_bottom = 54.0
	label.modulate.a = 0.0
	for i in range(8):
		var petal = Panel.new()
		petal.name = "FlowerBloomPetal"
		petal.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var petal_style = StyleBoxFlat.new()
		petal_style.bg_color = Color(0.96, 0.58 + randf() * 0.18, 0.42 + randf() * 0.20, 0.78)
		petal_style.set_corner_radius_all(999)
		petal.add_theme_stylebox_override("panel", petal_style)
		petal.offset_left = -4.0
		petal.offset_top = -6.0
		petal.offset_right = 4.0
		petal.offset_bottom = 6.0
		petal.rotation = randf_range(-0.7, 0.7)
		petal.modulate.a = 0.0
		root.add_child(petal)
		var angle = -PI * 0.85 + float(i) * PI * 1.70 / 7.0
		var distance = randf_range(34.0, 70.0)
		var target = Vector2(cos(angle), sin(angle)) * distance
		var petal_tw := create_tween()
		petal_tw.set_parallel(true)
		var delay = float(i) * 0.018
		petal_tw.tween_property(petal, "modulate:a", 0.92, 0.08).from(0.0).set_delay(delay)
		petal_tw.tween_property(petal, "position", target, 0.46).from(Vector2.ZERO).set_delay(delay).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		petal_tw.tween_property(petal, "rotation", petal.rotation + randf_range(-1.6, 1.6), 0.46).set_delay(delay)
		petal_tw.tween_property(petal, "modulate:a", 0.0, 0.24).set_delay(delay + 0.28)
	var ring = Panel.new()
	ring.name = "FlowerBloomRing"
	ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ring.set_anchors_preset(Control.PRESET_CENTER)
	ring.add_theme_stylebox_override("panel", style(Color(0, 0, 0, 0), 999, Color(accent.r, accent.g, accent.b, 0.50), 2, 0))
	root.add_child(ring)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(tile_view, "modulate:a", 1.0, 0.14).from(0.0)
	tw.tween_property(tile_view, "scale", Vector2(1.0, 1.0), 0.22).from(Vector2(0.72, 0.72)).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(tile_view, "position:y", -46.0, 0.42).from(-34.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(tile_view, "modulate:a", 0.0, 0.20).set_delay(0.50)
	tw.tween_property(label, "modulate:a", 1.0, 0.12).from(0.0).set_delay(0.06)
	tw.tween_property(label, "modulate:a", 0.0, 0.22).set_delay(0.46)
	tw.tween_property(label, "position:y", -10.0, 0.48).from(0.0).set_delay(0.06)
	tw.tween_property(ring, "modulate:a", 0.0, 0.44).from(0.75)
	tw.tween_property(ring, "offset_left", -58.0, 0.44).from(-16.0)
	tw.tween_property(ring, "offset_top", -58.0, 0.44).from(-16.0)
	tw.tween_property(ring, "offset_right", 58.0, 0.44).from(16.0)
	tw.tween_property(ring, "offset_bottom", 58.0, 0.44).from(16.0)
	tw.tween_callback(func() -> void:
		if root != null and is_instance_valid(root):
			root.queue_free()
	).set_delay(0.78)

func clear_fx_overlays() -> void:
	if fx_burst_tween != null and is_instance_valid(fx_burst_tween):
		fx_burst_tween.kill()
	if fx_ripple_tween != null and is_instance_valid(fx_ripple_tween):
		fx_ripple_tween.kill()
	if fx_burst_root != null and is_instance_valid(fx_burst_root):
		fx_burst_root.visible = false
	if fx_ripple_root != null and is_instance_valid(fx_ripple_root):
		fx_ripple_root.visible = false
	if fx_turn_pulse != null and is_instance_valid(fx_turn_pulse):
		fx_turn_pulse.visible = false
	if transition_tween != null and is_instance_valid(transition_tween):
		transition_tween.kill()
	if transition_overlay != null and is_instance_valid(transition_overlay):
		transition_overlay.visible = false
	transition_active = false

# ============================================================
# 屏幕过渡动画系统
# ============================================================

func _build_fx_transition() -> void:
	transition_overlay = ColorRect.new()
	transition_overlay.name = "ScreenTransition"
	transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	transition_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	transition_overlay.color = Color(0.004, 0.006, 0.008, 0.0)
	transition_overlay.visible = false
	fx_layer.add_child(transition_overlay)

func play_screen_transition(callback: Callable, instant: bool = false, style: String = "fade") -> void:
	"""屏幕过渡动画：支持渐隐/水墨/珠帘风格"""
	if instant or not fx_enabled_effective():
		callback.call()
		return
	if transition_overlay == null or not is_instance_valid(transition_overlay):
		ensure_fx_layer()
	if transition_active:
		if transition_tween != null and is_instance_valid(transition_tween):
			transition_tween.kill()
		transition_active = false
	transition_overlay.visible = true
	transition_overlay.color = Color(0.004, 0.006, 0.008, 0.0)
	var half_dur := float(TRANSITION_DURATION_MSEC) / 2000.0
	match style:
		"ink_wash":
			# 水墨过渡 - 墨色从右侧扩散覆盖
			transition_overlay.color = Color(0.02, 0.02, 0.03, 0.0)
			var ink_dur := 0.22
			var tw := create_tween()
			transition_tween = tw
			transition_active = true
			tw.set_parallel(true)
			tw.tween_property(transition_overlay, "color:a", 0.96, ink_dur).from(0.0).set_ease(Tween.EASE_IN)
			tw.tween_property(transition_overlay, "anchor_left", 0.0, ink_dur).from(1.0).set_trans(Tween.TRANS_QUAD)
			tw.set_parallel(false)
			tw.tween_callback(func() -> void:
				callback.call()
				transition_overlay.anchor_left = 0.0
			)
			tw.tween_property(transition_overlay, "color:a", 0.0, ink_dur).from(0.96).set_ease(Tween.EASE_OUT)
			tw.tween_callback(func() -> void:
				transition_active = false
				if transition_overlay != null and is_instance_valid(transition_overlay):
					transition_overlay.visible = false
					transition_overlay.anchor_left = 0.0
			)
		"curtain":
			# 珠帘过渡 - 多列竖线依次落下
			transition_overlay.color = Color(0.01, 0.01, 0.02, 0.0)
			var curtain_strips := 6
			var strip_container = Control.new()
			strip_container.name = "CurtainStrips"
			strip_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
			strip_container.set_anchors_preset(Control.PRESET_FULL_RECT)
			fx_layer.add_child(strip_container)
			for i in range(curtain_strips):
				var strip = ColorRect.new()
				strip.color = Color(0.02, 0.02, 0.03, 0.94)
				strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
				var left_frac = float(i) / float(curtain_strips)
				var right_frac = float(i + 1) / float(curtain_strips)
				strip.anchor_left = left_frac
				strip.anchor_right = right_frac
				strip.anchor_top = -1.0
				strip.anchor_bottom = -1.0
				strip_container.add_child(strip)
				var s_tw := create_tween()
				s_tw.tween_property(strip, "anchor_top", 0.0, 0.25).from(-1.0).set_delay(float(i) * 0.04).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
				s_tw.parallel().tween_property(strip, "anchor_bottom", 1.0, 0.25).from(-0.5).set_delay(float(i) * 0.04)
			var tw := create_tween()
			transition_tween = tw
			transition_active = true
			tw.tween_callback(func() -> void:
				callback.call()
			).set_delay(0.28)
			tw.tween_callback(func() -> void:
				for child in strip_container.get_children():
					var c_tw := create_tween()
					c_tw.tween_property(child, "anchor_top", -1.0, 0.20).from(0.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
					c_tw.parallel().tween_property(child, "anchor_bottom", -0.5, 0.20).from(1.0)
			).set_delay(0.35)
			tw.tween_callback(func() -> void:
				transition_active = false
				strip_container.queue_free()
				if transition_overlay != null and is_instance_valid(transition_overlay):
					transition_overlay.visible = false
			).set_delay(0.60)
		_:
			# 默认渐隐过渡
			var tw := create_tween()
			transition_tween = tw
			transition_active = true
			tw.tween_property(transition_overlay, "color:a", 0.92, half_dur).from(0.0)
			tw.tween_callback(func() -> void:
				callback.call()
			)
			tw.tween_property(transition_overlay, "color:a", 0.0, half_dur).from(0.92)
			tw.tween_callback(func() -> void:
				transition_active = false
				if transition_overlay != null and is_instance_valid(transition_overlay):
					transition_overlay.visible = false
			)

# ============================================================
# 杠牌特写动画
# ============================================================

func play_fx_gang_burst(gang_type: String, seat: int) -> void:
	"""杠牌特写动画：暗杠/补杠独立动画效果"""
	if not fx_enabled_effective() or fx_burst_root == null or not is_instance_valid(fx_burst_root):
		return
	if fx_burst_tween != null and is_instance_valid(fx_burst_tween):
		fx_burst_tween.kill()
	apply_rect(fx_burst_root, rect_full(0.18, 0.24, 0.82, 0.76))
	var accent := Color(0.50, 0.42, 0.72, 1.0)
	var label_text := "杠"
	match gang_type:
		"concealed":
			accent = Color(0.50, 0.42, 0.72)
			label_text = "暗杠"
		"added":
			accent = Color(0.66, 0.58, 0.92)
			label_text = "补杠"
		_:
			accent = Color(0.62, 0.54, 0.88)
			label_text = "杠"
	fx_burst_flash.color = Color(accent.r, accent.g, accent.b, 0.0)
	for ring in fx_burst_rings:
		ring.modulate.a = 0.0
		ring.add_theme_stylebox_override("panel", style(Color(0, 0, 0, 0), 60, accent.darkened(0.18), 3, 0))
		ring.offset_left = -42.0
		ring.offset_top = -42.0
		ring.offset_right = 42.0
		ring.offset_bottom = 42.0
	fx_burst_label.text = label_text
	fx_burst_label.add_theme_color_override("font_color", accent.lightened(0.30))
	fx_burst_label.modulate.a = 0.0
	fx_burst_label.offset_top = 28.0
	fx_burst_label.offset_bottom = 28.0
	fx_burst_root.visible = true
	var half := 0.70
	var tw := create_tween()
	fx_burst_tween = tw
	tw.set_parallel(true)
	tw.tween_property(fx_burst_flash, "color:a", 0.12, 0.16).from(0.0)
	tw.tween_property(fx_burst_flash, "color:a", 0.0, 0.40).set_delay(max(0.0, half - 0.40))
	tw.tween_property(fx_burst_label, "modulate:a", 1.0, 0.18).from(0.0)
	tw.tween_property(fx_burst_label, "modulate:a", 0.0, 0.35).set_delay(max(0.0, half - 0.35))
	tw.tween_property(fx_burst_label, "offset_top", -16.0, half).from(28.0)
	tw.tween_property(fx_burst_label, "offset_bottom", -16.0, half).from(28.0)
	for i in range(fx_burst_rings.size()):
		var ring = fx_burst_rings[i]
		var delay = float(i) * 0.08
		var span = max(0.22, half - delay)
		tw.tween_property(ring, "modulate:a", 0.0, span).from(0.62).set_delay(delay)
		tw.tween_property(ring, "offset_left", -145.0, span).from(-42.0).set_delay(delay)
		tw.tween_property(ring, "offset_top", -145.0, span).from(-42.0).set_delay(delay)
		tw.tween_property(ring, "offset_right", 145.0, span).from(42.0).set_delay(delay)
		tw.tween_property(ring, "offset_bottom", 145.0, span).from(42.0).set_delay(delay)
	tw.tween_callback(_hide_fx_burst).set_delay(half + 0.05)

# ============================================================
# Toast提示系统
# ============================================================

func _build_fx_toast() -> void:
	toast_container = Control.new()
	toast_container.name = "ToastContainer"
	toast_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	toast_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	toast_container.visible = false
	fx_layer.add_child(toast_container)

func show_toast(text: String, duration_msec: int = TOAST_DEFAULT_DURATION_MSEC) -> void:
	"""显示临时Toast提示"""
	if fx_layer == null or not is_instance_valid(fx_layer):
		return
	if toast_container == null or not is_instance_valid(toast_container):
		_build_fx_toast()
	# 清除旧toast
	if toast_current != null and is_instance_valid(toast_current):
		toast_current.queue_free()
		toast_current = null
	if toast_tween != null and is_instance_valid(toast_tween):
		toast_tween.kill()
	# 创建toast节点
	var toast_bg = Panel.new()
	toast_bg.name = "Toast"
	toast_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	toast_bg.anchor_left = 0.18
	toast_bg.anchor_right = 0.82
	toast_bg.anchor_top = 0.06
	toast_bg.anchor_bottom = 0.12
	toast_bg.offset_left = 0
	toast_bg.offset_top = 0
	toast_bg.offset_right = 0
	toast_bg.offset_bottom = 0
	toast_bg.add_theme_stylebox_override("panel", style(Color(0.020, 0.042, 0.048, 0.96), 16, Color(0.50, 0.64, 0.56, 0.62), 2, 6))
	toast_bg.add_child(make_color_rect(rect_full(0.0, 0.0, 0.018, 1.0), Color(0.40, 0.72, 0.58, 0.72)))
	draw_toast_illustration(toast_bg, text)
	var label = make_label(toast_bg, text, 16, Color(0.96, 0.96, 0.92), true)
	apply_rect(label, rect_full(0.12, 0.04, 0.94, 0.96))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_bg.modulate = Color(1, 1, 1, 0)
	toast_bg.offset_top = -28.0
	toast_container.add_child(toast_bg)
	toast_container.visible = true
	toast_current = toast_bg
	# 动画：弹跳滑入 → 停留 → 下滑淡出
	var slide_dur := float(TOAST_SLIDE_DURATION_MSEC) / 1000.0
	var stay_dur := float(duration_msec) / 1000.0
	var fade_dur := 0.28
	var tw := create_tween()
	toast_tween = tw
	# 入场 - 从上方弹出 + 缩放弹跳
	tw.tween_property(toast_bg, "modulate:a", 1.0, slide_dur).from(0.0)
	tw.parallel().tween_property(toast_bg, "offset_top", 0.0, slide_dur).from(-28.0).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(toast_bg, "scale", Vector2(1.0, 1.0), slide_dur).from(Vector2(0.90, 0.90)).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(toast_bg, "modulate:a", 0.0, fade_dur).set_delay(stay_dur)
	# 退出 - 下滑
	tw.parallel().tween_property(toast_bg, "offset_top", 14.0, fade_dur).set_delay(stay_dur)
	tw.tween_callback(func() -> void:
		if toast_bg != null and is_instance_valid(toast_bg):
			toast_bg.queue_free()
		if toast_container != null and is_instance_valid(toast_container):
			toast_container.visible = false
		if toast_current == toast_bg:
			toast_current = null
	).set_delay(stay_dur + fade_dur + 0.02)

func draw_toast_illustration(toast_bg: Control, text: String) -> void:
	var accent = toast_accent_color(text)
	var seal = make_panel(toast_bg, rect_full(0.035, 0.18, 0.095, 0.82), Color(accent.r, accent.g, accent.b, 0.28), 999, Color(accent.r, accent.g, accent.b, 0.52), 0)
	seal.name = "ToastIconSeal"
	var icon_name = toast_icon_name(text)
	if icon_name != "":
		add_lucide_icon(seal, icon_name, rect_full(0.24, 0.24, 0.76, 0.76), Color(0.96, 0.92, 0.72, 0.92))
	var sheen = make_color_rect(rect_full(0.115, 0.18, 0.910, 0.28), Color(1.0, 0.90, 0.48, 0.12))
	sheen.name = "ToastSheen"
	toast_bg.add_child(sheen)
	var spark_count = 3 if text.find("成功") >= 0 or text.find("完成") >= 0 else 2
	for i in range(spark_count):
		var left = 0.900 + float(i) * 0.026
		var spark = make_panel(toast_bg, rect_full(left, 0.26 + float(i % 2) * 0.22, left + 0.014, 0.40 + float(i % 2) * 0.22), Color(accent.r, accent.g, accent.b, 0.48), 999, Color(1.0, 0.92, 0.56, 0.18), 0)
		spark.name = "ToastSpark_%d" % i
	if text.find("成就") >= 0:
		draw_achievement_toast_art(toast_bg, accent)
	var item_key = toast_item_key_for_text(text)
	if item_key != "":
		draw_item_toast_art(toast_bg, item_key, accent)

func draw_achievement_toast_art(toast_bg: Control, accent: Color) -> void:
	var medal = make_panel(toast_bg, rect_full(0.100, 0.185, 0.142, 0.815), Color(accent.r, accent.g, accent.b, 0.22), 999, Color(accent.r, accent.g, accent.b, 0.42), 0)
	medal.name = "ToastAchievementMedal"
	var core = make_panel(medal, rect_full(0.260, 0.250, 0.740, 0.750), Color(0.96, 0.82, 0.36, 0.52), 999, Color(1.0, 0.90, 0.50, 0.28), 0)
	core.name = "ToastAchievementMedalCore"
	for i in range(4):
		var left = 0.150 + float(i) * 0.025
		var ray = make_panel(toast_bg, rect_full(left, 0.300 + float(i % 2) * 0.240, left + 0.012, 0.430 + float(i % 2) * 0.240), Color(1.0, 0.86, 0.42, 0.34), 999, Color(1.0, 0.92, 0.56, 0.14), 0)
		ray.name = "ToastAchievementRay_%d" % i

func draw_item_toast_art(toast_bg: Control, item_id: String, accent: Color) -> void:
	var badge = make_panel(toast_bg, rect_full(0.820, 0.185, 0.870, 0.815), Color(accent.r, accent.g, accent.b, 0.22), 12, Color(accent.r, accent.g, accent.b, 0.38), 0)
	badge.name = "ToastItemBadge"
	var core = make_panel(badge, rect_full(0.220, 0.220, 0.780, 0.780), Color(accent.r, accent.g, accent.b, 0.40), 999, Color(1.0, 0.92, 0.62, 0.22), 0)
	core.name = "ToastItemCore"
	var item_mark = make_label(core, item_short_mark(item_id), 10, Color(0.98, 0.94, 0.78), true)
	apply_rect(item_mark, rect_full(0.0, 0.0, 1.0, 1.0))
	for i in range(3):
		var top = 0.255 + float(i) * 0.165
		var pip = make_panel(toast_bg, rect_full(0.878, top, 0.892, top + 0.070), Color(accent.r, accent.g, accent.b, 0.44), 999, Color(1.0, 0.92, 0.56, 0.16), 0)
		pip.name = "ToastItemPip_%d" % i

func toast_item_key_for_text(text: String) -> String:
	for item_id in ITEM_TYPES.keys():
		if text.find(item_display_name(str(item_id))) >= 0:
			return str(item_id)
	return ""

func item_short_mark(item_id: String) -> String:
	match item_id:
		"swap_card":
			return "换"
		"peek_card":
			return "看"
		"lucky_charm":
			return "运"
		"double_coins":
			return "倍"
	return "具"

func toast_icon_name(text: String) -> String:
	if text.find("成就") >= 0:
		return "sparkles"
	if toast_item_key_for_text(text) != "":
		return "gift"
	if text.find("成功") >= 0 or text.find("完成") >= 0:
		return "sparkles"
	if text.find("不足") >= 0 or text.find("失败") >= 0:
		return "triangle-alert"
	if text.find("更新") >= 0 or text.find("下载") >= 0:
		return "download"
	return "info"

func toast_accent_color(text: String) -> Color:
	if text.find("不足") >= 0 or text.find("失败") >= 0:
		return Color(0.86, 0.36, 0.26, 1.0)
	if text.find("成就") >= 0:
		return Color(0.92, 0.70, 0.30, 1.0)
	if toast_item_key_for_text(text) != "":
		return Color(0.62, 0.54, 0.86, 1.0)
	if text.find("成功") >= 0 or text.find("完成") >= 0:
		return Color(0.84, 0.68, 0.30, 1.0)
	return Color(0.40, 0.72, 0.58, 1.0)


func current_status_text() -> String:
	if mode == "offline":
		if offline_phase == "ended":
			if is_offline_match_finished():
				return "全场结束"
			return round_summary if round_summary != "" else "牌局结束"
		if has_pending_danger_discard():
			return pending_danger_discard_text()
		if offline_phase == "pending_claim":
			return "等待你响应%s" % tile_label(str(offline_pending_claim.get("tile", "")))
		if wall.is_empty() and offline_turn_needs_draw:
			return "牌墙已空"
		if current_seat == 0:
			return "轮到你出牌"
		return "%s行牌" % players[current_seat]["name"]
	var phase = str(online_game.get("phase", ""))
	if online_feedback != "":
		return online_feedback
	if phase == "ended":
		return str(online_game.get("winnerText", "牌局结束"))
	if phase == "pendingClaim":
		return "等待吃碰杠胡响应"
	return "轮到你出牌" if can_self_discard() else "等待对家行牌"


func show_rules_screen(instant: bool = false) -> void:
	"""显示麻将规则和玩法说明"""
	if transition_active and not instant:
		return
	var _build = func() -> void:
		_show_rules_screen_impl()
	if instant or not fx_enabled_effective():
		_build.call()
	else:
		play_screen_transition(_build, false, "curtain")

func _show_rules_screen_impl() -> void:
	mode = "rules"
	clear_screen()

	# 主面板
	var panel = make_panel(root_layer, rect_full(0.02, 0.02, 0.98, 0.98), Color(0.010, 0.024, 0.032, 0.98), 20, Color(0.52, 0.44, 0.26, 0.48))
	panel.add_child(make_color_rect(rect_full(0.006, 0.02, 0.014, 0.98), Color(0.90, 0.76, 0.36, 0.72)))
	panel.add_child(make_color_rect(rect_full(0.014, 0.012, 0.986, 0.028), Color(1.0, 1.0, 1.0, 0.045)))
	# 书架式滑入动画 / Shelf-slide entrance
	if fx_enabled_effective() and DisplayServer.get_name().to_lower() != "headless":
		panel.modulate = Color(1, 1, 1, 0)
		panel.offset_right = -22.0
		var tw := create_tween()
		tw.set_parallel(true)
		tw.tween_property(panel, "modulate:a", 1.0, 0.26).from(0.0).set_ease(Tween.EASE_OUT)
		tw.tween_property(panel, "offset_right", 0.0, 0.26).from(-22.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

	# 标题
	var title = make_label(panel, "麻将玩法指南", 30, Color(0.94, 0.86, 0.48), true)
	apply_rect(title, rect_full(0.04, 0.028, 0.40, 0.095))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

	draw_rules_guide_art(panel)

	# 返回按钮
	var back = make_small_button("返回", Color(0.32, 0.38, 0.40), func() -> void:
		show_menu()
	)
	back.custom_minimum_size = Vector2(100, 48)
	panel.add_child(back)
	apply_rect(back, rect_full(0.84, 0.030, 0.94, 0.090))

	# 内容区域
	var content = VBoxContainer.new()
	content.anchor_left = 0.05
	content.anchor_top = 0.25
	content.anchor_right = 0.95
	content.anchor_bottom = 0.95
	content.add_theme_constant_override("separation", 16)
	panel.add_child(content)

	# 基础规则
	add_rule_section(content, "🎯 游戏目标", [
		"组成4组面子（顺子或刻子）+ 1对将牌即可胡牌",
		"通过摸牌、打牌、吃碰杠来组合手牌",
		"可以自摸胡牌，也可以点炮胡牌",
	], 0)

	# 牌型说明
	add_rule_section(content, "🀄 牌型介绍", [
		"顺子：同花色连续3张牌（如 123万）",
		"刻子：相同3张牌（如 111万）",
		"杠子：相同4张牌（杠牌专用）",
		"将牌：任意一对相同的牌",
	], 1)

	# 特殊牌型
	add_rule_section(content, "⭐ 特殊牌型", [
		"七对：7对将牌即可胡牌",
		"十三幺：13种幺九牌各一张 + 其中任意一对",
		"清一色：全部是同一花色的牌",
	], 2)

	# 操作说明
	add_rule_section(content, "🎮 游戏操作", [
		"点击手牌打出该张牌",
		"出现吃、碰、杠、胡按钮时点击操作",
		"点击'重开'可重新开始本局",
	], 3)

	# 记录已查看教程
	tutorial_step = -1
	save_tutorial_state()

func draw_rules_guide_art(parent: Control) -> Control:
	var art = make_panel(parent, rect_full(0.05, 0.115, 0.95, 0.225), Color(0.016, 0.036, 0.040, 0.86), 16, Color(0.44, 0.40, 0.24, 0.36), 0)
	art.name = "RulesGuideArt"
	# 水墨画框装饰
	make_ink_border(art, rect_full(0.0, 0.0, 1.0, 0.08), 2.0)
	make_ink_border(art, rect_full(0.0, 0.92, 1.0, 1.0), 2.0)
	var rail = make_panel(art, rect_full(0.060, 0.480, 0.940, 0.560), Color(0.58, 0.50, 0.28, 0.22), 999, Color(0.82, 0.72, 0.38, 0.18), 0)
	rail.name = "RulesGuideRail"
	var steps = [
		{"label": "目标", "icon": "target", "color": Color(0.78, 0.54, 0.30)},
		{"label": "组牌", "icon": "layers", "color": Color(0.36, 0.66, 0.54)},
		{"label": "听牌", "icon": "ear", "color": Color(0.48, 0.58, 0.78)},
		{"label": "胡牌", "icon": "sparkles", "color": Color(0.88, 0.70, 0.34)},
	]
	for i in range(steps.size()):
		var step = steps[i]
		var center_x = 0.105 + float(i) * 0.265
		var col: Color = step.get("color", Color(0.62, 0.62, 0.42))
		var node = make_panel(art, rect_full(center_x - 0.042, 0.170, center_x + 0.042, 0.830), Color(col.r, col.g, col.b, 0.30), 999, Color(col.r, col.g, col.b, 0.34), 0)
		node.name = "RulesGuideStep_%d" % i
		add_lucide_icon(node, str(step.get("icon", "circle")), rect_full(0.25, 0.16, 0.75, 0.56), col.lightened(0.36))
		var label = make_label(node, str(step.get("label", "")), 12, Color(0.94, 0.92, 0.78), true)
		apply_rect(label, rect_full(0.06, 0.58, 0.94, 0.94))
		if i < steps.size() - 1:
			var connector = make_panel(art, rect_full(center_x + 0.055, 0.435, center_x + 0.205, 0.605), Color(col.r, col.g, col.b, 0.18), 999, Color(col.r, col.g, col.b, 0.10), 0)
			connector.name = "RulesGuideConnector_%d" % i
	var lead_glow = make_panel(art, rect_full(0.035, 0.180, 0.135, 0.820), Color(0.90, 0.72, 0.34, 0.16), 999, Color(1.0, 0.84, 0.42, 0.18), 0)
	lead_glow.name = "RulesGuideLeadGlow"
	if fx_enabled_effective() and DisplayServer.get_name().to_lower() != "headless":
		var tw := create_tween()
		tw.set_loops(3600)
		tw.tween_property(lead_glow, "modulate:a", 0.42, 1.0).from(0.92)
		tw.tween_property(lead_glow, "modulate:a", 0.92, 1.0).from(0.42)
	return art

func draw_rule_section_path_art(section: Control, section_index: int, title_text: String) -> void:
	var colors = [
		Color(0.86, 0.62, 0.34),
		Color(0.38, 0.70, 0.58),
		Color(0.62, 0.56, 0.86),
		Color(0.86, 0.72, 0.38),
	]
	var icons = ["target", "layers", "sparkles", "mouse-pointer-click"]
	var accent: Color = colors[clamp(section_index, 0, colors.size() - 1)]
	var icon_name = str(icons[clamp(section_index, 0, icons.size() - 1)])
	var strip = make_panel(section, rect_full(0.740, 0.160, 0.970, 0.840), Color(accent.r, accent.g, accent.b, 0.065), 14, Color(accent.r, accent.g, accent.b, 0.12), 0)
	strip.name = "RuleSectionArtStrip_%d" % section_index
	var rail = make_color_rect(rect_full(0.120, 0.470, 0.880, 0.530), Color(accent.r, accent.g, accent.b, 0.26))
	rail.name = "RuleSectionPathRail_%d" % section_index
	strip.add_child(rail)
	for i in range(3):
		var x = 0.160 + float(i) * 0.340
		var node = make_panel(strip, rect_full(x - 0.055, 0.300, x + 0.055, 0.700), Color(accent.r, accent.g, accent.b, 0.22 + float(i) * 0.035), 999, Color(accent.r, accent.g, accent.b, 0.16), 0)
		node.name = "RuleSectionPathNode_%d_%d" % [section_index, i]
	var badge = make_panel(strip, rect_full(0.040, 0.120, 0.250, 0.420), Color(accent.r, accent.g, accent.b, 0.18), 999, Color(accent.r, accent.g, accent.b, 0.20), 0)
	badge.name = "RuleSectionCategoryBadge_%d" % section_index
	add_lucide_icon(badge, icon_name, rect_full(0.220, 0.180, 0.780, 0.820), accent.lightened(0.32))
	var glyph = make_label(strip, title_text.substr(0, 1), 20, Color(0.96, 0.90, 0.62, 0.50), true)
	glyph.name = "RuleSectionPathGlyph_%d" % section_index
	apply_rect(glyph, rect_full(0.705, 0.120, 0.920, 0.470))
	if fx_enabled_effective() and DisplayServer.get_name().to_lower() != "headless":
		var tw := create_tween()
		tw.set_loops(3600)
		tw.tween_property(strip, "modulate:a", 0.72, 1.2).from(1.0)
		tw.tween_property(strip, "modulate:a", 1.0, 1.2).from(0.72)

func add_rule_section(parent: VBoxContainer, title_text: String, lines: Array, section_index: int = -1) -> void:
	var section = make_panel(parent, rect_full(0.0, 0.0, 1.0, 0.22), Color(0.012, 0.022, 0.028, 0.92), 14, Color(0.34, 0.38, 0.36, 0.28), 0)
	section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	section.custom_minimum_size.y = 86
	var marker = make_panel(section, rect_full(0.020, 0.170, 0.034, 0.830), Color(0.82, 0.66, 0.32, 0.42), 999, Color(0.96, 0.78, 0.38, 0.18), 0)
	marker.name = "RuleSectionMarker"
	if section_index >= 0:
		draw_rule_section_path_art(section, section_index, title_text)

	var vbox = VBoxContainer.new()
	vbox.anchor_left = 0.055
	vbox.anchor_top = 0.08
	vbox.anchor_right = 0.72 if section_index >= 0 else 0.96
	vbox.anchor_bottom = 0.92
	section.add_child(vbox)

	var title_label = make_label(vbox, title_text, 18, Color(0.90, 0.82, 0.50), true)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

	for line in lines:
		var line_label = make_label(vbox, "  " + str(line), 14, Color(0.80, 0.84, 0.76), false)
		line_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		line_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func show_stats_screen(instant: bool = false) -> void:
	"""显示详细游戏统计"""
	if transition_active and not instant:
		return
	var _build = func() -> void:
		_show_stats_screen_impl()
	if instant or not fx_enabled_effective():
		_build.call()
	else:
		play_screen_transition(_build, false, "curtain")

func _show_stats_screen_impl() -> void:
	mode = "stats"
	clear_screen()

	var panel = make_panel(root_layer, rect_full(0.02, 0.02, 0.98, 0.98), Color(0.010, 0.024, 0.032, 0.98), 20, Color(0.52, 0.44, 0.26, 0.48))
	panel.add_child(make_color_rect(rect_full(0.006, 0.02, 0.014, 0.98), Color(0.90, 0.76, 0.36, 0.72)))
	# 书架式滑入动画 / Shelf-slide entrance
	if fx_enabled_effective() and DisplayServer.get_name().to_lower() != "headless":
		panel.modulate = Color(1, 1, 1, 0)
		panel.offset_top = 18.0
		var tw := create_tween()
		tw.set_parallel(true)
		tw.tween_property(panel, "modulate:a", 1.0, 0.26).from(0.0).set_ease(Tween.EASE_OUT)
		tw.tween_property(panel, "offset_top", 0.0, 0.26).from(18.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

	var title = make_label(panel, "游戏统计", 30, Color(0.94, 0.86, 0.48), true)
	apply_rect(title, rect_full(0.04, 0.028, 0.40, 0.095))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

	var back = make_small_button("返回", Color(0.32, 0.38, 0.40), func() -> void:
		show_menu()
	)
	back.custom_minimum_size = Vector2(100, 48)
	panel.add_child(back)
	apply_rect(back, rect_full(0.84, 0.030, 0.94, 0.090))
	draw_stats_dashboard_art(panel)

	# 统计数据
	var content = VBoxContainer.new()
	content.anchor_left = 0.08
	content.anchor_top = 0.34
	content.anchor_right = 0.92
	content.anchor_bottom = 0.92
	content.add_theme_constant_override("separation", 12)
	panel.add_child(content)

	add_stat_row(content, "总场次", "%d 局" % int(game_stats.get("games_played", 0)))
	add_stat_row(content, "胜场", "%d 局" % int(game_stats.get("games_won", 0)))
	add_stat_row(content, "胜率", "%.1f%%" % (float(game_stats.get("win_rate", 0.0)) * 100.0))
	add_stat_row(content, "累计分数", "%s 分" % compact_score_text(int(game_stats.get("total_score", 0))))
	add_stat_row(content, "最高得分", "%s 分" % compact_score_text(int(game_stats.get("best_score", 0))))
	add_stat_row(content, "总手牌数", "%d 局" % int(game_stats.get("total_hands", 0)))

func draw_stats_dashboard_art(parent: Control) -> Control:
	var dash = make_panel(parent, rect_full(0.08, 0.120, 0.92, 0.300), Color(0.014, 0.034, 0.040, 0.88), 16, Color(0.42, 0.36, 0.22, 0.34), 0)
	dash.name = "StatsDashboardArt"
	# 水墨框装饰
	make_ink_border(dash, rect_full(0.0, 0.0, 1.0, 0.06), 2.0)
	make_ink_border(dash, rect_full(0.0, 0.94, 1.0, 1.0), 2.0)
	var win_rate = clamp(float(game_stats.get("win_rate", 0.0)), 0.0, 1.0)
	var games = int(game_stats.get("games_played", 0))
	var best_score = int(game_stats.get("best_score", 0))
	var accent = Color(0.42, 0.70, 0.58, 1.0)
	var ring = Control.new()
	ring.name = "StatsWinRateRing"
	ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(ring, rect_full(0.035, 0.14, 0.185, 0.86))
	dash.add_child(ring)
	make_panel(ring, rect_full(0.05, 0.05, 0.95, 0.95), Color(0.018, 0.030, 0.034, 0.92), 999, Color(accent.r, accent.g, accent.b, 0.20), 0)
	var lit_segments = clamp(int(ceil(win_rate * 8.0)), 0, 8)
	for i in range(8):
		var col = i % 4
		var row = int(i / 4)
		var left = 0.18 + float(col) * 0.17
		var top = 0.12 + float(row) * 0.58
		var lit = i < lit_segments
		var seg = make_panel(ring, rect_full(left, top, left + 0.10, top + 0.18), Color(accent.r, accent.g, accent.b, 0.66 if lit else 0.12), 999, Color(accent.r, accent.g, accent.b, 0.26 if lit else 0.08), 0)
		seg.name = "StatsWinRateSegment_%d" % i
	var games_track = make_panel(dash, rect_full(0.235, 0.26, 0.600, 0.74), Color(0.020, 0.036, 0.040, 0.70), 999, Color(0.72, 0.62, 0.34, 0.20), 0)
	games_track.name = "StatsGamesTrack"
	var games_fill = clamp(float(games) / 20.0, 0.05, 1.0)
	var games_bar = make_panel(games_track, rect_full(0.035, 0.35, 0.035 + 0.90 * games_fill, 0.65), Color(0.78, 0.64, 0.30, 0.58), 999, Color(0.92, 0.78, 0.42, 0.22), 0)
	games_bar.name = "StatsGamesTrackFill"
	var trend = Control.new()
	trend.name = "StatsTrendLineArt"
	trend.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(trend, rect_full(0.245, 0.720, 0.595, 0.900))
	dash.add_child(trend)
	var trend_base = make_color_rect(rect_full(0.020, 0.720, 0.980, 0.775), Color(0.82, 0.72, 0.42, 0.14))
	trend_base.name = "StatsTrendBaseLine"
	trend.add_child(trend_base)
	var trend_points = [
		Vector2(0.080, 0.660),
		Vector2(0.260, 0.520 - win_rate * 0.16),
		Vector2(0.450, 0.610 - games_fill * 0.18),
		Vector2(0.660, 0.380 - win_rate * 0.14),
		Vector2(0.860, 0.300 - min(float(best_score) / 12000.0, 1.0) * 0.12),
	]
	for i in range(trend_points.size()):
		var point = trend_points[i]
		var node = make_panel(trend, rect_full(point.x - 0.028, point.y - 0.090, point.x + 0.028, point.y + 0.090), Color(0.46, 0.74, 0.62, 0.46), 999, Color(0.76, 0.92, 0.70, 0.20), 0)
		node.name = "StatsTrendNode_%d" % i
		if i < trend_points.size() - 1:
			var next_point: Vector2 = trend_points[i + 1]
			var left = min(point.x, next_point.x) + 0.030
			var right = max(point.x, next_point.x) - 0.030
			var mid_y = (point.y + next_point.y) * 0.5
			var connector = make_color_rect(rect_full(left, mid_y - 0.025, right, mid_y + 0.025), Color(0.46, 0.74, 0.62, 0.24))
			connector.name = "StatsTrendConnector_%d" % i
			trend.add_child(connector)
	var score_medal = make_panel(dash, rect_full(0.665, 0.18, 0.925, 0.82), Color(0.050, 0.040, 0.026, 0.62), 18, Color(0.92, 0.72, 0.34, 0.30), 0)
	score_medal.name = "StatsBestScoreMedal"
	var medal_glow = make_panel(score_medal, rect_full(0.08, 0.16, 0.30, 0.84), Color(0.92, 0.72, 0.34, 0.24 if best_score != 0 else 0.10), 999, Color(1.0, 0.86, 0.46, 0.26), 0)
	medal_glow.name = "StatsBestScoreGlow"
	add_lucide_icon(score_medal, "trophy", rect_full(0.10, 0.24, 0.28, 0.76), GOLD_BRIGHT)
	var milestone_count = 0
	for threshold in [3000, 6000, 9000]:
		var unlocked = best_score >= int(threshold)
		var left = 0.360 + float(milestone_count) * 0.145
		var milestone = make_panel(score_medal, rect_full(left, 0.690, left + 0.080, 0.860), Color(0.92, 0.72, 0.34, 0.40 if unlocked else 0.12), 999, Color(1.0, 0.86, 0.46, 0.20 if unlocked else 0.06), 0)
		milestone.name = "StatsBestScoreMilestone_%d" % milestone_count
		milestone_count += 1
	var rate_label = make_label(dash, "胜率 %d%%" % int(round(win_rate * 100.0)), 14, Color(0.86, 0.92, 0.80), true)
	apply_rect(rate_label, rect_full(0.035, 0.02, 0.210, 0.18))
	var games_label = make_label(dash, "历练 %d局" % games, 14, Color(0.92, 0.86, 0.62), true)
	apply_rect(games_label, rect_full(0.255, 0.04, 0.580, 0.24))
	games_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	var best_label = make_label(score_medal, "最高 %s" % compact_score_text(best_score), 14, Color(0.96, 0.88, 0.58), true)
	apply_rect(best_label, rect_full(0.33, 0.16, 0.94, 0.84))
	best_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	return dash

func add_stat_row(parent: VBoxContainer, label_text: String, value_text: String) -> void:
	var row = Panel.new()
	row.custom_minimum_size = Vector2(0, 52)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_stylebox_override("panel", style(Color(0.014, 0.024, 0.030, 0.92), 12, Color(0.30, 0.34, 0.32, 0.32), 0))
	parent.add_child(row)

	var label = make_label(row, label_text, 18, Color(0.82, 0.84, 0.78), true)
	apply_rect(label, rect_full(0.06, 0.15, 0.45, 0.85))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

	var value = make_label(row, value_text, 20, Color(0.94, 0.90, 0.68), true)
	apply_rect(value, rect_full(0.52, 0.12, 0.94, 0.88))
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

# ============================================================
# 商店系统
# ============================================================

func show_shop_screen(instant: bool = false) -> void:
	if transition_active and not instant:
		return
	var _build = func() -> void:
		_show_shop_screen_impl()
	if instant or not fx_enabled_effective():
		_build.call()
	else:
		play_screen_transition(_build, false, "curtain")

func _show_shop_screen_impl() -> void:
	mode = "shop"
	clear_screen()

	# 背景装饰 - 祥云与灯笼
	make_cloud_decoration(root_layer, rect_full(0.02, 0.75, 0.25, 0.95), "mist", false)
	make_cloud_decoration(root_layer, rect_full(0.75, 0.04, 0.98, 0.18), "gold", false)
	make_lantern(root_layer, rect_full(0.03, 0.04, 0.09, 0.18), CINNABAR, true)

	# 主面板
	var panel = make_panel(root_layer, rect_full(0.02, 0.02, 0.98, 0.98), Color(0.010, 0.024, 0.032, 0.98), 20, Color(0.52, 0.44, 0.26, 0.48))
	panel.add_child(make_color_rect(rect_full(0.006, 0.02, 0.014, 0.98), GOLD_PRIMARY.darkened(0.2)))
	# 书架式滑入动画 / Shelf-slide entrance
	if fx_enabled_effective() and DisplayServer.get_name().to_lower() != "headless":
		panel.modulate = Color(1, 1, 1, 0)
		panel.offset_left = 22.0
		var tw := create_tween()
		tw.set_parallel(true)
		tw.tween_property(panel, "modulate:a", 1.0, 0.26).from(0.0).set_ease(Tween.EASE_OUT)
		tw.tween_property(panel, "offset_left", 0.0, 0.26).from(22.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

	# 顶部金色装饰线
	panel.add_child(make_color_rect(rect_full(0.015, 0.06, 0.985, 0.08), Color(0.92, 0.78, 0.38, 0.18)))

	# 标题 - 带图标
	add_lucide_icon(panel, "shopping-bag", rect_full(0.03, 0.030, 0.06, 0.090), GOLD_BRIGHT)
	var title = make_label(panel, "商店", 30, Color(0.94, 0.86, 0.48), true)
	apply_rect(title, rect_full(0.07, 0.028, 0.40, 0.095))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

	# 货币显示 - 增强样式
	var coins_panel = make_panel(panel, rect_full(0.50, 0.035, 0.72, 0.090), Color(0.020, 0.036, 0.042, 0.92), 12, Color(0.46, 0.52, 0.42, 0.36), 0)
	add_lucide_icon(coins_panel, "coin", rect_full(0.06, 0.15, 0.22, 0.85), GOLD_PRIMARY)
	var coins_label = make_label(coins_panel, str(int(currency.get("coins", 0))), 16, Color(0.96, 0.92, 0.68), true)
	apply_rect(coins_label, rect_full(0.25, 0.10, 0.95, 0.90))
	coins_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

	var gems_panel = make_panel(panel, rect_full(0.73, 0.035, 0.84, 0.090), Color(0.020, 0.036, 0.042, 0.92), 12, Color(0.42, 0.38, 0.56, 0.36), 0)
	add_lucide_icon(gems_panel, "diamond", rect_full(0.06, 0.15, 0.22, 0.85), Color(0.62, 0.52, 0.82))
	var gems_label = make_label(gems_panel, str(int(currency.get("gems", 0))), 16, Color(0.96, 0.92, 0.68), true)
	apply_rect(gems_label, rect_full(0.25, 0.10, 0.95, 0.90))
	gems_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

	# 返回按钮
	var back = make_small_button("返回", Color(0.32, 0.38, 0.40), func() -> void:
		show_menu()
	)
	back.custom_minimum_size = Vector2(100, 48)
	panel.add_child(back)
	apply_rect(back, rect_full(0.86, 0.030, 0.96, 0.090))
	add_lucide_icon(back, "chevron-left", rect_full(0.08, 0.22, 0.30, 0.78), Color(0.92, 0.94, 0.88, 0.86))

	# 道具列表 - 带滚动支持
	var scroll = ScrollContainer.new()
	scroll.anchor_left = 0.04
	scroll.anchor_top = 0.12
	scroll.anchor_right = 0.96
	scroll.anchor_bottom = 0.95
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	panel.add_child(scroll)

	var content = VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 12)
	scroll.add_child(content)

	# 道具图标映射
	var item_icon_map := {
		"swap_card": "refresh-cw",
		"peek_card": "info",
		"lucky_charm": "leaf",
		"double_coins": "coin",
	}
	# 道具颜色映射
	var item_color_map := {
		"swap_card": Color(0.22, 0.48, 0.72),
		"peek_card": Color(0.62, 0.38, 0.72),
		"lucky_charm": Color(0.28, 0.56, 0.42),
		"double_coins": Color(0.72, 0.52, 0.22),
	}

	for item_id in ITEM_TYPES.keys():
		var item_info = ITEM_TYPES[item_id]
		var count = get_item_count(item_id)
		var cost = int(item_info.get("cost_gems", 10))
		var item_color = item_color_map.get(item_id, Color(0.42, 0.48, 0.44))
		var icon_name = item_icon_map.get(item_id, "gift")

		# 道具行面板
		var row = Panel.new()
		row.name = "ShopItemRow_%s" % item_id
		row.custom_minimum_size = Vector2(0, 72)
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var row_style = style(Color(0.018, 0.030, 0.034, 0.92), 14, Color(0.34, 0.38, 0.36, 0.32), 0)
		row.add_theme_stylebox_override("panel", row_style)
		content.add_child(row)
		# 道具行交错入场 / Staggered item entrance
		if fx_enabled_effective() and DisplayServer.get_name().to_lower() != "headless":
			var item_index = int(ITEM_TYPES.keys().find(item_id))
			row.modulate = Color(1, 1, 1, 0)
			row.offset_left = 14.0
			var r_tw := create_tween()
			r_tw.set_parallel(true)
			r_tw.tween_property(row, "modulate:a", 1.0, 0.22).from(0.0).set_delay(float(item_index) * 0.06).set_ease(Tween.EASE_OUT)
			r_tw.tween_property(row, "offset_left", 0.0, 0.22).from(14.0).set_delay(float(item_index) * 0.06).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

		# 左侧彩色装饰条
		row.add_child(make_color_rect(rect_full(0.0, 0.0, 0.008, 1.0), item_color.darkened(0.2)))
		draw_shop_item_row_art(row, item_color, count, item_id)

		# 道具图标背景
		var icon_bg = make_panel(row, rect_full(0.02, 0.10, 0.10, 0.90), item_color.darkened(0.6), 12, item_color.darkened(0.3), 0)
		icon_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_lucide_icon(row, icon_name, rect_full(0.035, 0.18, 0.085, 0.82), item_color.lightened(0.3))

		# 道具名称
		var name_label = make_label(row, str(item_info.get("name", item_id)), 18, Color(0.94, 0.92, 0.86), true)
		apply_rect(name_label, rect_full(0.12, 0.10, 0.50, 0.48))
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

		# 道具描述
		var desc_label = make_label(row, str(item_info.get("desc", "")), 12, Color(0.68, 0.74, 0.70), false)
		apply_rect(desc_label, rect_full(0.12, 0.52, 0.55, 0.90))
		desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

		# 拥有数量 - 带徽章样式
		var count_badge_color = Color(0.28, 0.56, 0.48) if count > 0 else Color(0.38, 0.42, 0.40)
		var count_badge = make_badge(row, rect_full(0.56, 0.20, 0.70, 0.80), "拥有 %d" % count, 13, count_badge_color.darkened(0.2), count_badge_color.lightened(0.2), Color(0.96, 0.96, 0.92))
		count_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE

		# 购买按钮 - 增强样式
		var buy_btn = make_small_button("", Color(0.42, 0.38, 0.58), func() -> void:
			if spend_gems(cost):
				add_item(item_id, 1)
				show_toast("购买成功！获得%s" % item_info.get("name", item_id), 2000)
				# 播放购买成功动画
				if fx_enabled_effective():
					_play_purchase_success_animation(row, item_color)
				# 刷新显示
				_show_shop_screen_impl()
			else:
				show_toast("钻石不足", 1800)
		)
		buy_btn.custom_minimum_size = Vector2(100, 48)
		row.add_child(buy_btn)
		apply_rect(buy_btn, rect_full(0.78, 0.15, 0.97, 0.85))
		draw_shop_buy_button_art(buy_btn, cost, int(currency.get("gems", 0)) >= cost)

		# 按钮内容 - 图标和价格
		add_lucide_icon(buy_btn, "diamond", rect_full(0.10, 0.22, 0.30, 0.78), Color(0.72, 0.62, 0.88))
		var price_label = make_label(buy_btn, str(cost), 16, Color(0.96, 0.94, 0.88), true)
		apply_rect(price_label, rect_full(0.32, 0.10, 0.92, 0.90))
		price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

		# 按钮悬停效果
		buy_btn.mouse_entered.connect(func() -> void:
			if is_instance_valid(buy_btn):
				var tw := buy_btn.create_tween()
				tw.tween_property(buy_btn, "scale", Vector2(1.05, 1.05), 0.15).set_ease(Tween.EASE_OUT)
		)
		buy_btn.mouse_exited.connect(func() -> void:
			if is_instance_valid(buy_btn):
				var tw := buy_btn.create_tween()
				tw.tween_property(buy_btn, "scale", Vector2(1.0, 1.0), 0.15).set_ease(Tween.EASE_OUT)
		)

	# 面板弹出动画
	if fx_enabled_effective():
		panel.modulate = Color(1, 1, 1, 0)
		panel.scale = Vector2(0.95, 0.95)
		var tw := create_tween()
		tw.set_parallel(true)
		tw.tween_property(panel, "modulate:a", 1.0, 0.25).from(0.0)
		tw.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.25).from(Vector2(0.95, 0.95)).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func draw_shop_buy_button_art(button: Control, cost: int, affordable: bool) -> Control:
	var art = Control.new()
	art.name = "ShopBuyButtonArt"
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art.set_anchors_preset(Control.PRESET_FULL_RECT)
	button.add_child(art)
	var accent = Color(0.62, 0.52, 0.86) if affordable else Color(0.74, 0.44, 0.38)
	var rail = make_panel(art, rect_full(0.075, 0.760, 0.925, 0.875), Color(0.010, 0.018, 0.022, 0.54), 999, Color(accent.r, accent.g, accent.b, 0.16), 0)
	rail.name = "ShopBuyButtonAffordRail"
	var fill_fraction = 0.86 if affordable else 0.28
	var fill = make_panel(art, rect_full(0.080, 0.782, 0.080 + 0.840 * fill_fraction, 0.852), Color(accent.r, accent.g, accent.b, 0.48), 999, Color(accent.r, accent.g, accent.b, 0.12), 0)
	fill.name = "ShopBuyButtonAffordFill"
	var seal = make_panel(art, rect_full(0.705, 0.135, 0.905, 0.600), Color(accent.r, accent.g, accent.b, 0.14), 999, Color(accent.r, accent.g, accent.b, 0.12), 0)
	seal.name = "ShopBuyButtonPriceSeal"
	for i in range(2):
		var top = 0.185 + float(i) * 0.190
		var spark = make_panel(art, rect_full(0.622 + float(i) * 0.044, top, 0.648 + float(i) * 0.044, top + 0.110), Color(accent.r, accent.g, accent.b, 0.28 if affordable else 0.14), 999, Color(1.0, 0.92, 0.60, 0.10), 0)
		spark.name = "ShopBuyButtonSpark_%d" % i
	if not affordable:
		var lock = make_panel(art, rect_full(0.050, 0.155, 0.215, 0.575), Color(0.82, 0.46, 0.40, 0.22), 999, Color(0.94, 0.64, 0.56, 0.12), 0)
		lock.name = "ShopBuyButtonInsufficientLock"
	if affordable and fx_enabled_effective() and DisplayServer.get_name().to_lower() != "headless":
		var tw := create_tween()
		tw.set_loops(3600)
		tw.tween_property(seal, "modulate:a", 0.50, 0.90).from(1.0)
		tw.tween_property(seal, "modulate:a", 1.0, 0.90).from(0.50)
	return art

func draw_shop_item_row_art(row: Control, item_color: Color, count: int, item_id: String = "") -> void:
	var shelf = make_panel(row, rect_full(0.110, 0.820, 0.735, 0.885), Color(item_color.r, item_color.g, item_color.b, 0.16), 999, Color(item_color.r, item_color.g, item_color.b, 0.20), 0)
	shelf.name = "ShopItemShelfRail"
	var energy = make_panel(row, rect_full(0.120, 0.060, 0.535, 0.105), Color(item_color.r, item_color.g, item_color.b, 0.12), 999, Color(item_color.r, item_color.g, item_color.b, 0.16), 0)
	energy.name = "ShopItemEnergyRail"
	var fill_right = 0.120 + 0.415 * clamp(float(count) / 3.0, 0.08, 1.0)
	var fill = make_color_rect(rect_full(0.120, 0.068, fill_right, 0.097), Color(item_color.r, item_color.g, item_color.b, 0.34 if count > 0 else 0.16))
	fill.name = "ShopItemEnergyFill"
	row.add_child(fill)
	var mark = make_panel(row, rect_full(0.705, 0.190, 0.755, 0.810), Color(item_color.r, item_color.g, item_color.b, 0.18), 999, Color(item_color.r, item_color.g, item_color.b, 0.30), 0)
	mark.name = "ShopItemTypeMark_%s" % (item_id if item_id != "" else "generic")
	var mark_label = make_label(mark, item_short_mark(item_id), 9, Color(0.98, 0.94, 0.78, 0.88), true)
	mark_label.name = "ShopItemTypeGlyph"
	apply_rect(mark_label, rect_full(0.0, 0.0, 1.0, 1.0))
	mark_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mark_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var stock = Control.new()
	stock.name = "ShopItemStockPips"
	stock.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(stock, rect_full(0.565, 0.075, 0.700, 0.180))
	row.add_child(stock)
	var pip_count = min(4, max(1, count))
	for i in range(pip_count):
		var left = 0.02 + float(i) * 0.235
		var alpha = 0.72 if count > 0 else 0.22
		var pip = make_panel(stock, rect_full(left, 0.18, left + 0.145, 0.82), Color(item_color.r, item_color.g, item_color.b, alpha), 999, Color(item_color.r, item_color.g, item_color.b, 0.34), 0)
		pip.name = "ShopItemStockPip_%d" % i
	var price_aura = make_panel(row, rect_full(0.755, 0.120, 0.988, 0.880), Color(0.62, 0.52, 0.82, 0.08), 14, Color(0.72, 0.62, 0.88, 0.18), 0)
	price_aura.name = "ShopItemPriceAura"
	for i in range(2):
		var shine = make_panel(row, rect_full(0.772 + float(i) * 0.035, 0.185, 0.792 + float(i) * 0.035, 0.315), Color(0.82, 0.70, 0.96, 0.24), 999, Color(1.0, 0.92, 0.56, 0.10), 0)
		shine.name = "ShopItemPriceSpark_%d" % i
	if fx_enabled_effective() and DisplayServer.get_name().to_lower() != "headless":
		var tw := create_tween()
		tw.set_loops(3600)
		tw.tween_property(price_aura, "modulate:a", 0.42, 0.90).from(0.88)
		tw.tween_property(price_aura, "modulate:a", 0.88, 0.90).from(0.42)

func _play_purchase_success_animation(row: Control, item_color: Color) -> void:
	"""播放购买成功动画 - 增强版：物品闪光 + 金币粒子飞溅"""
	# 闪光效果
	var flash = ColorRect.new()
	flash.color = Color(item_color.r, item_color.g, item_color.b, 0.0)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	row.add_child(flash)

	var flash_tween := create_tween()
	flash_tween.tween_property(flash, "color:a", 0.3, 0.15)
	flash_tween.tween_property(flash, "color:a", 0.0, 0.3)
	flash_tween.tween_callback(flash.queue_free)

	# 边框高亮 - 增强为更明显的发光
	var highlight_tween := create_tween()
	highlight_tween.tween_property(row, "modulate", Color(1.25, 1.22, 1.18, 1.0), 0.15)
	highlight_tween.tween_property(row, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.3)

	# 金币粒子飞溅 - 从行中心向四周散开
	if fx_enabled_effective() and is_instance_valid(row):
		var row_size = row.size
		var center = Vector2(row_size.x * 0.5, row_size.y * 0.5)
		for i in range(10):
			var particle = Panel.new()
			particle.mouse_filter = Control.MOUSE_FILTER_IGNORE
			var p_style = StyleBoxFlat.new()
			var gold_tone = GOLD_PRIMARY if i % 2 == 0 else GOLD_BRIGHT
			p_style.bg_color = Color(gold_tone.r, gold_tone.g, gold_tone.b, 0.92)
			p_style.set_corner_radius_all(50)
			particle.add_theme_stylebox_override("panel", p_style)
			var psize = 4.0 + randf() * 5.0
			particle.size = Vector2(psize, psize)
			particle.position = center - Vector2(psize * 0.5, psize * 0.5)
			row.add_child(particle)
			var angle := float(i) * TAU / 10.0 + randf() * 0.3
			var dist := 40.0 + randf() * 50.0
			var target_pos: Vector2 = center + Vector2(cos(angle), sin(angle)) * dist - Vector2(psize * 0.5, psize * 0.5)
			var p_tw := create_tween()
			p_tw.set_parallel(true)
			p_tw.tween_property(particle, "position", target_pos, 0.6).set_ease(Tween.EASE_OUT)
			p_tw.tween_property(particle, "modulate:a", 0.0, 0.6).set_ease(Tween.EASE_IN)
			p_tw.tween_property(particle, "scale", Vector2(0.3, 0.3), 0.6).set_ease(Tween.EASE_IN)
			p_tw.tween_callback(particle.queue_free).set_delay(0.65)


# ============================================================
# 房间聊天功能
# ============================================================

var chat_messages: Array = []
var chat_input: LineEdit = null

func show_chat_panel() -> void:
	if chat_messages.is_empty():
		return
	var chat_panel = make_panel(root_layer, rect_full(0.02, 0.38, 0.28, 0.72), Color(0.008, 0.018, 0.022, 0.95), 14, Color(0.38, 0.42, 0.40, 0.36), 0)
	chat_panel.name = "ChatPanel"
	draw_chat_panel_art(chat_panel)
	var chat_text = "\n".join(chat_messages.slice(-8))
	var chat_label = make_label(chat_panel, chat_text, 12, Color(0.82, 0.86, 0.80), false)
	apply_rect(chat_label, rect_full(0.075, 0.260, 0.940, 0.910))
	chat_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	chat_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	chat_label.clip_text = true

func draw_chat_panel_art(parent: Control) -> Control:
	var art = Control.new()
	art.name = "ChatPanelArt"
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(art, rect_full(0.0, 0.0, 1.0, 1.0))
	# 笔触分隔线
	make_brush_stroke_divider(art, rect_full(0.10, 0.12, 0.90, 0.15))
	parent.add_child(art)
	art.add_child(make_color_rect(rect_full(0.0, 0.0, 0.014, 1.0), Color(0.38, 0.70, 0.62, 0.50)))
	art.add_child(make_color_rect(rect_full(0.045, 0.205, 0.955, 0.220), Color(0.86, 0.74, 0.42, 0.12)))
	var header = make_panel(art, rect_full(0.055, 0.055, 0.945, 0.190), Color(0.020, 0.044, 0.050, 0.78), 999, Color(0.48, 0.68, 0.58, 0.22), 0)
	header.name = "ChatPanelHeader"
	add_lucide_icon(header, "users", rect_full(0.035, 0.190, 0.155, 0.810), Color(0.76, 0.88, 0.72, 0.86))
	var title = make_label(header, "房间消息", 12, Color(0.88, 0.92, 0.80), true)
	apply_rect(title, rect_full(0.170, 0.080, 0.575, 0.920))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	var count_badge = make_badge(header, rect_full(0.620, 0.170, 0.925, 0.830), "%d条" % min(99, chat_messages.size()), 10, Color(0.22, 0.40, 0.38, 0.92), Color(0.48, 0.72, 0.62, 0.34), Color(0.94, 0.96, 0.88))
	count_badge.name = "ChatPanelCountBadge"
	count_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var rail = make_panel(art, rect_full(0.058, 0.285, 0.070, 0.900), Color(0.60, 0.76, 0.64, 0.20), 999, Color(0.80, 0.92, 0.72, 0.12), 0)
	rail.name = "ChatPanelActivityRail"
	var visible_count = min(5, chat_messages.size())
	for i in range(visible_count):
		var top = 0.320 + float(i) * 0.112
		var message_text = str(chat_messages[chat_messages.size() - visible_count + i])
		var is_self_message = message_text.begins_with("你:")
		var node = make_panel(art, rect_full(0.044, top, 0.084, top + 0.048), Color(0.48, 0.78, 0.64, 0.46), 999, Color(0.80, 0.92, 0.70, 0.22), 0)
		node.name = "ChatPanelMessageNode_%d" % i
		var sender_chip = make_panel(art, rect_full(0.100, top - 0.008, 0.158, top + 0.056), Color(0.76, 0.62, 0.34, 0.36 if is_self_message else 0.18), 999, Color(0.96, 0.82, 0.42, 0.18 if is_self_message else 0.08), 0)
		sender_chip.name = "ChatPanelSenderChip_%d" % i
		if is_self_message:
			var ribbon = make_color_rect(rect_full(0.168, top + 0.018, 0.305, top + 0.034), Color(0.86, 0.72, 0.36, 0.28))
			ribbon.name = "ChatPanelOutgoingRibbon_%d" % i
			art.add_child(ribbon)
		var bead = make_panel(art, rect_full(0.895, top - 0.002, 0.915, top + 0.046), Color(0.42, 0.74, 0.62, 0.38), 999, Color(0.78, 0.92, 0.72, 0.14), 0)
		bead.name = "ChatPanelUnreadBead_%d" % i
	var latest_glow = make_panel(art, rect_full(0.036, 0.300, 0.092, 0.368), Color(0.92, 0.76, 0.34, 0.20), 999, Color(1.0, 0.86, 0.46, 0.18), 0)
	latest_glow.name = "ChatPanelLatestGlow"
	var input_pulse = make_panel(art, rect_full(0.760, 0.825, 0.940, 0.905), Color(0.42, 0.72, 0.62, 0.10), 999, Color(0.74, 0.92, 0.72, 0.10), 0)
	input_pulse.name = "ChatPanelInputPulse"
	for i in range(3):
		var wave = make_panel(art, rect_full(0.790 + float(i) * 0.045, 0.850 - float(i % 2) * 0.020, 0.815 + float(i) * 0.045, 0.890), Color(0.62, 0.84, 0.70, 0.36 - float(i) * 0.06), 999, Color(0.82, 0.96, 0.76, 0.12), 0)
		wave.name = "ChatPanelTypingWave_%d" % i
	add_lucide_icon(art, "sparkles", rect_full(0.835, 0.058, 0.930, 0.176), Color(0.94, 0.82, 0.46, 0.50))
	if fx_enabled_effective() and DisplayServer.get_name().to_lower() != "headless":
		var tw := create_tween()
		tw.set_loops(3600)
		tw.tween_property(latest_glow, "modulate:a", 0.36, 0.90).from(0.90)
		tw.tween_property(latest_glow, "modulate:a", 0.90, 0.90).from(0.36)
		var input_tw := create_tween()
		input_tw.set_loops(3600)
		input_tw.tween_property(input_pulse, "modulate:a", 0.44, 0.80).from(1.0)
		input_tw.tween_property(input_pulse, "modulate:a", 1.0, 0.80).from(0.44)
	return art

func add_chat_message(text: String) -> void:
	chat_messages.append(text)
	if chat_messages.size() > 50:
		chat_messages = chat_messages.slice(-30)

func send_quick_chat(message: String) -> void:
	if mode != "online_lobby" and mode != "online_game":
		return
	add_chat_message("你: %s" % message)
	send_online_action({"type": "chat", "message": message}, "发送消息")
	show_toast("已发送: %s" % message, 1500)

# 牌面动画系统、增强胜利特效、国风装饰元素等新增函数
# 这些代码将被追加到 scripts/main.gd 文件末尾

# ============================================================
# 牌面动画系统 / Tile Animation System
# ============================================================

func play_tile_flip_animation(tile_view: Control, from_face_up: bool, duration_msec: int = FX_TILE_FLIP_DURATION_MSEC) -> void:
	"""牌面翻转动画 - 2D缩放模拟3D翻转效果"""
	if not fx_enabled_effective() or tile_view == null or not is_instance_valid(tile_view):
		return

	var anim_id = tile_view.get_instance_id()
	if tile_flip_animations.has(anim_id):
		var existing_tween: Tween = tile_flip_animations[anim_id]
		if is_instance_valid(existing_tween):
			existing_tween.kill()

	var duration := float(duration_msec) / 1000.0
	var half_dur := duration * 0.5

	var tw := create_tween()
	tile_flip_animations[anim_id] = tw

	# 第一阶段：正面缩放到0（模拟翻转到侧面）
	tw.tween_property(tile_view, "scale:x", 0.0, half_dur).from(1.0).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)

	# 在中点切换可见性
	tw.tween_callback(func() -> void:
		if tile_view == null or not is_instance_valid(tile_view):
			return
		tile_view.modulate = tile_view.modulate.darkened(0.1)
	)

	# 第二阶段：从0缩放到1
	tw.tween_property(tile_view, "scale:x", 1.0, half_dur).from(0.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

	# 恢复颜色
	tw.tween_callback(func() -> void:
		if tile_view == null or not is_instance_valid(tile_view):
			return
		tile_view.modulate = Color(1, 1, 1, tile_view.modulate.a)
		tile_flip_animations.erase(anim_id)
	)

func play_tile_fly_animation(tile: String, from_pos: Vector2, to_pos: Vector2, duration_msec: int = FX_CLAIM_FLY_DURATION_MSEC, arc_height: float = 80.0, callback: Callable = Callable()) -> void:
	"""牌面飞行动画 - 带抛物线弧度"""
	if not fx_enabled_effective():
		if callback.is_valid():
			callback.call()
		return

	ensure_fx_layer()

	# 创建飞行中的牌面
	var flying_tile = make_tile_view(tile, Vector2(56, 76), false, Callable())
	flying_tile.name = "FlyingTile_%s" % tile
	flying_tile.z_index = FX_LAYER_Z_INDEX + 2
	flying_tile.modulate = Color(1, 1, 1, 0.95)
	flying_tile.position = from_pos
	flying_tile.scale = Vector2(0.9, 0.9)
	fx_layer.add_child(flying_tile)

	var duration := float(duration_msec) / 1000.0
	var tw := create_tween()
	tile_fly_animations.append({"tween": tw, "tile": flying_tile})
	tw.tween_method(func(progress: float) -> void:
		if flying_tile == null or not is_instance_valid(flying_tile):
			return
		var eased = ease(progress, -1.8)
		var base_pos = from_pos.lerp(to_pos, eased)
		var arc_offset = sin(progress * PI) * arc_height
		flying_tile.position = Vector2(base_pos.x, base_pos.y - arc_offset)
		var scale_value = lerp(0.90, 1.04, sin(progress * PI))
		flying_tile.scale = Vector2(scale_value, scale_value)
		flying_tile.rotation = lerp(-0.08, 0.08, progress)
		flying_tile.modulate.a = lerp(0.95, 0.78, max(0.0, progress - 0.78) / 0.22)
	, 0.0, 1.0, duration).set_trans(FX_TILE_FLY_CURVE).set_ease(FX_TILE_FLY_EASE)
	tw.tween_callback(func() -> void:
		if flying_tile != null and is_instance_valid(flying_tile):
			flying_tile.queue_free()
		for i in range(tile_fly_animations.size() - 1, -1, -1):
			var item: Dictionary = tile_fly_animations[i]
			if item.get("tween") == tw:
				tile_fly_animations.remove_at(i)
		if callback.is_valid():
			callback.call()
	)

func human_discard_fly_start_position(index: int, hand_size: int) -> Vector2:
	var screen_rect = root_layer_rect_to_screen_rect(HAND_TRAY_RECT)
	var viewport_size = effective_viewport_size()
	var left = screen_rect.position.x * viewport_size.x
	var top = screen_rect.position.y * viewport_size.y
	var width = (screen_rect.size.x - screen_rect.position.x) * viewport_size.x
	var height = (screen_rect.size.y - screen_rect.position.y) * viewport_size.y
	var safe_count = max(1, hand_size)
	var slot = clamp(index, 0, safe_count - 1)
	var x = left + width * (0.10 + 0.80 * (float(slot) + 0.5) / float(safe_count))
	var y = top + height * 0.64
	return Vector2(x, y)

func human_discard_fly_target_position() -> Vector2:
	return rect_center_screen_position(seat_discard_rect(0))

func play_human_discard_fly_animation(tile: String, index: int, hand_size: int) -> void:
	if not fx_enabled_effective() or tile == "":
		return
	var from_pos = human_discard_fly_start_position(index, hand_size)
	var to_pos = human_discard_fly_target_position()
	play_tile_claim_burst(from_pos, Color(0.82, 0.64, 0.30), "打")
	play_tile_fly_animation(tile, from_pos, to_pos, 260, 52.0)
	# 弃牌落水溅射 - 落点处水花扩散 / Discard splash on landing
	call_deferred("play_discard_splash", to_pos, tile)

func play_claim_animation(claim: String, tile: String, from_seat: int, to_seat: int, callback: Callable = Callable()) -> void:
	"""碰/杠/吃动画 - 组合飞行动画"""
	if not fx_enabled_effective():
		if callback.is_valid():
			callback.call()
		return

	var from_rect = seat_discard_rect(from_seat)
	var to_rect = seat_meld_rect(to_seat)

	var from_pos = rect_center_screen_position(from_rect)
	var to_pos = rect_center_screen_position(to_rect)

	# 根据操作类型调整动画参数
	var duration := FX_CLAIM_FLY_DURATION_MSEC
	var arc := 60.0
	var color := GOLD_PRIMARY

	match claim:
		"peng":
			arc = 80.0
			color = VERMILION
		"gang":
			arc = 120.0
			duration = int(duration * 1.3)
			color = AZURE
		"chi":
			arc = 50.0
			color = JADE_PRIMARY

	# 先播放缩放爆发效果
	play_tile_claim_burst(from_pos, color, claim_display_label(claim))

	# 然后播放飞行动画
	play_tile_fly_animation(tile, from_pos, to_pos, duration, arc, callback)
	# 碰杠吃飞行尾迹粒子 - 沿弧线撒落金粉 / Claim fly trailing particles
	play_claim_trail_particles(from_pos, to_pos, arc, color)

func play_claim_trail_particles(from_pos: Vector2, to_pos: Vector2, arc: float, color: Color) -> void:
	"""沿碰杠吃飞行弧线撒落尾迹粒子"""
	if not fx_enabled_effective():
		return
	ensure_fx_layer()
	var trail_root = Control.new()
	trail_root.name = "ClaimTrailFx"
	trail_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	trail_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	fx_layer.add_child(trail_root)
	var spark_count := 8
	var fly_dur := float(FX_CLAIM_FLY_DURATION_MSEC) / 1000.0
	for i in range(spark_count):
		var spark = Panel.new()
		spark.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var s_style = StyleBoxFlat.new()
		s_style.bg_color = Color(color.r, color.g, color.b, 0.0)
		s_style.set_corner_radius_all(50)
		spark.add_theme_stylebox_override("panel", s_style)
		var ssize := randf_range(2.0, 4.5)
		spark.custom_minimum_size = Vector2(ssize, ssize)
		trail_root.add_child(spark)
		var step = float(i) / float(spark_count - 1)
		# 弧线中点位置 + 随机散射
		var eased = ease(step, -1.8)
		var base = from_pos.lerp(to_pos, eased)
		var arc_offset = sin(step * PI) * arc
		spark.position = Vector2(base.x + randf_range(-6.0, 6.0), base.y - arc_offset + randf_range(-6.0, 6.0))
		var delay = step * fly_dur
		var tw := create_tween()
		tw.tween_property(spark, "modulate:a", 0.9, 0.12).from(0.0).set_delay(delay).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(spark, "scale", Vector2(1.3, 1.3), 0.18).from(Vector2(0.5, 0.5)).set_delay(delay)
		tw.tween_property(spark, "modulate:a", 0.0, 0.40).from(0.9).set_delay(delay + 0.18)
		tw.parallel().tween_property(spark, "position:y", spark.position.y + randf_range(18.0, 38.0), 0.40).set_delay(delay + 0.18).set_trans(Tween.TRANS_QUAD)
	var cleanup := create_tween()
	cleanup.tween_callback(func() -> void:
		if trail_root != null and is_instance_valid(trail_root):
			trail_root.queue_free()
	).set_delay(fly_dur + 0.6)

func claim_display_label(claim: String) -> String:
	match claim:
		"peng":
			return "碰"
		"gang":
			return "杠"
		"chi":
			return "吃"
		"hu":
			return "胡"
	return ""

func play_tile_claim_burst(position: Vector2, color: Color, label_text: String = "") -> void:
	"""牌面操作时的爆发特效"""
	if not fx_enabled_effective():
		return

	ensure_fx_layer()

	var burst_root = Control.new()
	burst_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	burst_root.position = position
	fx_layer.add_child(burst_root)

	# 创建多个扩散圆环
	var ring_count := 3
	var rings: Array[Panel] = []

	for i in range(ring_count):
		var ring = Panel.new()
		ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ring.modulate = Color(color.r, color.g, color.b, 0.0)
		ring.set_anchors_preset(Control.PRESET_CENTER)
		ring.add_theme_stylebox_override("panel", style(Color(0, 0, 0, 0), 40, color, 2, 0))
		burst_root.add_child(ring)
		rings.append(ring)

	var label: Label = null
	if label_text != "":
		label = make_label(burst_root, label_text, 26, color.lightened(0.30), true)
		label.name = "ClaimBurstLabel_%s" % label_text
		label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.72))
		label.add_theme_constant_override("shadow_offset_x", 1)
		label.add_theme_constant_override("shadow_offset_y", 2)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.offset_left = -30.0
		label.offset_top = -42.0
		label.offset_right = 30.0
		label.offset_bottom = 12.0
		label.modulate.a = 0.0
		label.scale = Vector2(0.72, 0.72)

	var tw := create_tween()
	tw.set_parallel(true)

	for i in range(ring_count):
		var ring = rings[i]
		var delay = float(i) * 0.06
		tw.tween_property(ring, "modulate:a", 0.0, 0.25).from(0.65).set_delay(delay)
		tw.tween_property(ring, "offset_left", -55.0, 0.25).from(-18.0).set_delay(delay)
		tw.tween_property(ring, "offset_top", -55.0, 0.25).from(-18.0).set_delay(delay)
		tw.tween_property(ring, "offset_right", 55.0, 0.25).from(18.0).set_delay(delay)
		tw.tween_property(ring, "offset_bottom", 55.0, 0.25).from(18.0).set_delay(delay)
	if label != null:
		tw.tween_property(label, "modulate:a", 1.0, 0.10).from(0.0)
		tw.tween_property(label, "modulate:a", 0.0, 0.22).set_delay(0.18)
		tw.tween_property(label, "scale", Vector2(1.0, 1.0), 0.18).from(Vector2(0.72, 0.72)).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(label, "position:y", -16.0, 0.32).from(0.0)

	tw.tween_callback(func() -> void:
		if burst_root != null and is_instance_valid(burst_root):
			burst_root.queue_free()
	).set_delay(0.35)

func seat_discard_rect(seat: int) -> Rect2:
	"""获取座位弃牌区矩形"""
	for zone in DISCARD_ZONES:
		if int(zone[0]) == seat:
			return zone[1]
	return Rect2(Vector2(0.4, 0.4), Vector2(0.2, 0.2))

# 弃牌落水溅射动画 / Discard Splash Animation
func play_discard_splash(target_pos: Vector2, tile: String) -> void:
	"""弃牌落入河中水花溅射效果"""
	if not fx_enabled_effective():
		return
	ensure_fx_layer()
	var splash_root = Control.new()
	splash_root.name = "DiscardSplashFx"
	splash_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	splash_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	fx_layer.add_child(splash_root)
	var accent = tile_accent(tile) if tile != "" else GOLD_PRIMARY
	# 水花环 - 从落点扩散
	var ring_count := 3
	for i in range(ring_count):
		var ring = Panel.new()
		ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ring.set_anchors_preset(Control.PRESET_CENTER)
		var r_style = StyleBoxFlat.new()
		r_style.bg_color = Color(0, 0, 0, 0)
		r_style.set_corner_radius_all(40)
		r_style.border_color = Color(accent.r * 0.6 + 0.4, accent.g * 0.6 + 0.4, accent.b * 0.6 + 0.3, 0.38)
		r_style.set_border_width_all(1)
		ring.add_theme_stylebox_override("panel", r_style)
		ring.custom_minimum_size = Vector2(18, 18)
		ring.position = target_pos - Vector2(9.0, 9.0)
		splash_root.add_child(ring)
		var delay = float(i) * 0.07
		var tw := create_tween()
		tw.tween_property(ring, "offset_left", -42.0, 0.32).from(0.0).set_delay(delay).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(ring, "offset_top", -42.0, 0.32).from(0.0).set_delay(delay)
		tw.parallel().tween_property(ring, "offset_right", 42.0, 0.32).from(0.0).set_delay(delay)
		tw.parallel().tween_property(ring, "offset_bottom", 42.0, 0.32).from(0.0).set_delay(delay)
		tw.parallel().tween_property(ring, "modulate:a", 0.0, 0.32).from(0.72).set_delay(delay)
	# 散射小水滴
	var droplet_count := 6
	for i in range(droplet_count):
		var drop = Panel.new()
		drop.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var d_style = StyleBoxFlat.new()
		d_style.bg_color = Color(0.60, 0.76, 0.72, 0.72)
		d_style.set_corner_radius_all(50)
		drop.add_theme_stylebox_override("panel", d_style)
		drop.custom_minimum_size = Vector2(randf_range(2, 4), randf_range(2, 4))
		drop.position = target_pos + Vector2(randf_range(-3, 3), randf_range(-3, 3))
		splash_root.add_child(drop)
		var angle := float(i) * TAU / float(droplet_count)
		var dist := randf_range(16.0, 32.0)
		var dx: float = cos(angle) * dist
		var dy: float = sin(angle) * dist
		var tw := create_tween()
		tw.set_parallel(true)
		tw.tween_property(drop, "position:x", drop.position.x + dx, 0.28).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(drop, "position:y", drop.position.y + dy, 0.28).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(drop, "modulate:a", 0.0, 0.34).from(0.72)
	var cleanup := create_tween()
	cleanup.tween_callback(func() -> void:
		if splash_root != null and is_instance_valid(splash_root):
			splash_root.queue_free()
	).set_delay(0.42)

func seat_meld_rect(seat: int) -> Rect2:
	"""获取座位明牌区矩形"""
	# 根据 SEAT_LAYOUTS 查找对应座位的明牌区
	match seat:
		0: return Rect2(Vector2(0.08, 0.58), Vector2(0.25, 0.15))
		1: return Rect2(Vector2(0.08, 0.22), Vector2(0.25, 0.15))
		2: return Rect2(Vector2(0.67, 0.22), Vector2(0.25, 0.15))
		3: return Rect2(Vector2(0.67, 0.58), Vector2(0.25, 0.15))
		_: return Rect2(Vector2(0.4, 0.4), Vector2(0.2, 0.2))

func rect_center_screen_position(rect: Rect2) -> Vector2:
	"""将anchor矩形转换为屏幕中心坐标"""
	var screen_rect = root_layer_rect_to_screen_rect(rect)
	var viewport_size = effective_viewport_size()
	return Vector2(
		(screen_rect.position.x + screen_rect.size.x * 0.5) * viewport_size.x,
		(screen_rect.position.y + screen_rect.size.y * 0.5) * viewport_size.y
	)

# ============================================================
# 增强胜利特效 / Enhanced Victory Effect
# ============================================================

func play_fx_win_burst_enhanced(text: String, color: Color, win_type: String = "normal") -> void:
	"""增强版胜利特效 - 带粒子、光效、震动"""
	if not fx_enabled_effective() or fx_burst_root == null or not is_instance_valid(fx_burst_root):
		return

	if fx_burst_tween != null and is_instance_valid(fx_burst_tween):
		fx_burst_tween.kill()
	clear_win_burst_dynamic_art()

	apply_rect(fx_burst_root, rect_full(0.18, 0.24, 0.82, 0.76))

	# 根据胜利类型调整效果参数
	var particle_count := FX_WIN_PARTICLE_COUNT
	var duration := FX_WIN_DURATION_ENHANCED_MSEC
	var flash_intensity := 0.12

	match win_type:
		"self_draw":
			particle_count = int(particle_count * 1.5)
			duration = int(duration * 1.3)
			flash_intensity = 0.18
		"special":
			particle_count = int(particle_count * 2.2)
			duration = int(duration * 1.6)
			flash_intensity = 0.25

	# 背景闪烁
	fx_burst_flash.color = Color(color.r, color.g, color.b, 0.0)

	# 创建粒子系统（使用Control节点模拟）
	var particles_root = Control.new()
	particles_root.name = "WinParticles"
	particles_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	particles_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	fx_burst_root.add_child(particles_root)

	# 生成粒子
	var particles: Array[Control] = []
	for i in range(particle_count):
		var particle = _create_win_particle(color, i, particle_count)
		particles_root.add_child(particle)
		particles.append(particle)

	# 配置原有圆环 - 增强扩散效果
	for ring in fx_burst_rings:
		ring.modulate.a = 0.0
		ring.add_theme_stylebox_override("panel", style(Color(0, 0, 0, 0), 60, color, 4, 0))
		ring.offset_left = -42.0
		ring.offset_top = -42.0
		ring.offset_right = 42.0
		ring.offset_bottom = 42.0

	# 设置标签 - 增强文字效果
	fx_burst_label.text = text
	fx_burst_label.add_theme_color_override("font_color", color.lightened(0.30))
	fx_burst_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	fx_burst_label.modulate.a = 0.0
	fx_burst_label.offset_top = 28.0
	fx_burst_label.offset_bottom = 28.0

	# 添加印章装饰 - 增强印章效果
	var seal_text = "胡" if win_type != "self_draw" else "摸"
	var seal = make_seal_stamp(fx_burst_root, rect_full(0.42, 0.62, 0.58, 0.82), seal_text, "square")
	seal.name = "WinCelebrationSeal"
	seal.modulate.a = 0.0
	seal.scale = Vector2(0.4, 0.4)
	var celebration_art = draw_win_celebration_art(fx_burst_root, color, win_type)

	fx_burst_root.visible = true

	var half := float(duration) / 2000.0

	# 创建主动画
	var tw := create_tween()
	fx_burst_tween = tw
	tw.set_parallel(true)

	# 背景闪烁动画
	tw.tween_property(fx_burst_flash, "color:a", flash_intensity, 0.18).from(0.0)
	tw.tween_property(fx_burst_flash, "color:a", 0.0, 0.65).set_delay(max(0.0, half - 0.65))

	# 标签动画
	tw.tween_property(fx_burst_label, "modulate:a", 1.0, 0.22).from(0.0)
	tw.tween_property(fx_burst_label, "modulate:a", 0.0, 0.55).set_delay(max(0.0, half - 0.55))
	tw.tween_property(fx_burst_label, "offset_top", -16.0, half).from(28.0)
	tw.tween_property(fx_burst_label, "offset_bottom", -16.0, half).from(28.0)

	# 印章动画 - 更强的弹出效果
	tw.tween_property(seal, "modulate:a", 1.0, 0.32).from(0.0).set_delay(0.12)
	tw.tween_property(seal, "scale", Vector2(1.15, 1.15), 0.32).from(Vector2(0.4, 0.4)).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_delay(0.12)
	tw.tween_property(seal, "scale", Vector2(1.0, 1.0), 0.15).from(Vector2(1.15, 1.15)).set_delay(0.44)
	tw.tween_property(seal, "modulate:a", 0.0, 0.40).set_delay(half - 0.15)

	# 圆环扩散动画 - 更大的扩散范围和更强的效果
	for i in range(fx_burst_rings.size()):
		var ring = fx_burst_rings[i]
		var delay = float(i) * 0.08
		var span = max(0.35, half - delay)
		tw.tween_property(ring, "modulate:a", 0.0, span).from(0.85).set_delay(delay)
		tw.tween_property(ring, "offset_left", -280.0, span).from(-42.0).set_delay(delay)
		tw.tween_property(ring, "offset_top", -280.0, span).from(-42.0).set_delay(delay)
		tw.tween_property(ring, "offset_right", 280.0, span).from(42.0).set_delay(delay)
		tw.tween_property(ring, "offset_bottom", 280.0, span).from(42.0).set_delay(delay)

	# 粒子动画
	for i in range(particles.size()):
		var particle = particles[i]
		var delay = fmod(float(i) * 0.015, 0.4)
		_animate_win_particle(particle, tw, delay, half)

	# 屏幕震动效果
	_play_screen_shake(FX_WIN_SHAKE_AMPLITUDE, FX_WIN_SHAKE_FREQUENCY, 0.25)

	# 结束清理
	tw.tween_callback(func() -> void:
		_hide_fx_burst()
		if particles_root != null and is_instance_valid(particles_root):
			particles_root.queue_free()
		if seal != null and is_instance_valid(seal):
			seal.queue_free()
		if celebration_art != null and is_instance_valid(celebration_art):
			celebration_art.queue_free()
	).set_delay(half + 0.05)

func clear_win_burst_dynamic_art() -> void:
	if fx_burst_root == null or not is_instance_valid(fx_burst_root):
		return
	var dynamic_names := ["WinParticles", "WinCelebrationArt", "WinCelebrationSeal"]
	for child in fx_burst_root.get_children():
		if dynamic_names.has(str(child.name)):
			child.queue_free()

func draw_win_celebration_art(parent: Control, color: Color, win_type: String) -> Control:
	var art = Control.new()
	art.name = "WinCelebrationArt"
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art.set_anchors_preset(Control.PRESET_FULL_RECT)
	parent.add_child(art)
	var track = make_panel(art, rect_full(0.220, 0.535, 0.780, 0.575), Color(color.r, color.g, color.b, 0.16), 999, Color(1.0, 0.86, 0.46, 0.16), 0)
	track.name = "WinCelebrationTrack"
	var medal = make_panel(art, rect_full(0.455, 0.185, 0.545, 0.355), Color(color.r, color.g, color.b, 0.26), 999, Color(1.0, 0.86, 0.46, 0.34), 0)
	medal.name = "WinCelebrationMedal"
	add_lucide_icon(medal, "trophy", rect_full(0.22, 0.22, 0.78, 0.78), Color(0.98, 0.88, 0.50, 0.86))
	var star_count = 10 if win_type == "special" else 8 if win_type == "self_draw" else 6
	for i in range(star_count):
		var angle = -PI * 0.92 + float(i) * PI * 1.84 / float(max(1, star_count - 1))
		var radius_x = 0.255
		var radius_y = 0.255
		var cx = 0.5 + cos(angle) * radius_x
		var cy = 0.505 + sin(angle) * radius_y
		var star = make_panel(art, rect_full(cx - 0.010, cy - 0.018, cx + 0.010, cy + 0.018), Color(color.r, color.g, color.b, 0.48), 999, Color(1.0, 0.92, 0.58, 0.18), 0)
		star.name = "WinCelebrationStar_%d" % i
	match win_type:
		"self_draw":
			var orbit = make_panel(art, rect_full(0.380, 0.145, 0.620, 0.395), Color(0.0, 0.0, 0.0, 0.0), 999, Color(color.r, color.g, color.b, 0.28), 0)
			orbit.name = "WinCelebrationSelfDrawOrbit"
		"special":
			var crown = make_panel(art, rect_full(0.405, 0.105, 0.595, 0.220), Color(0.92, 0.62, 0.22, 0.22), 999, Color(1.0, 0.86, 0.46, 0.30), 0)
			crown.name = "WinCelebrationSpecialCrown"
		_:
			var ribbon = make_color_rect(rect_full(0.350, 0.370, 0.650, 0.405), Color(color.r, color.g, color.b, 0.24))
			ribbon.name = "WinCelebrationRibbon"
			art.add_child(ribbon)
	if fx_enabled_effective() and DisplayServer.get_name().to_lower() != "headless":
		art.modulate.a = 0.0
		medal.scale = Vector2(0.72, 0.72)
		var tw := create_tween()
		tw.set_parallel(true)
		tw.tween_property(art, "modulate:a", 1.0, 0.18).from(0.0)
		tw.tween_property(medal, "scale", Vector2(1.0, 1.0), 0.26).from(Vector2(0.72, 0.72)).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	return art

func _create_win_particle(base_color: Color, index: int, total: int) -> Control:
	"""创建单个胜利粒子"""
	var particle = Control.new()
	particle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	particle.set_anchors_preset(Control.PRESET_CENTER)

	# 随机位置和大小
	var angle = randf() * PI * 2.0
	var radius = randf_range(50.0, 180.0)
	particle.position = Vector2(cos(angle) * radius * 0.3, sin(angle) * radius * 0.3)

	# 粒子核心
	var core = Panel.new()
	core.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var core_size = randf_range(6.0, 14.0)
	core.custom_minimum_size = Vector2(core_size, core_size)

	var particle_style = StyleBoxFlat.new()
	var particle_color = base_color.lightened(randf_range(-0.2, 0.4))
	particle_style.bg_color = Color(particle_color.r, particle_color.g, particle_color.b, randf_range(0.6, 0.95))
	particle_style.set_corner_radius_all(int(core_size * 0.5))
	core.add_theme_stylebox_override("panel", particle_style)

	core.offset_left = -core_size * 0.5
	core.offset_top = -core_size * 0.5
	core.offset_right = core_size * 0.5
	core.offset_bottom = core_size * 0.5

	particle.add_child(core)
	particle.modulate.a = 0.0

	# 存储动画参数
	particle.set_meta("target_x", cos(angle) * radius)
	particle.set_meta("target_y", sin(angle) * radius - randf_range(30.0, 80.0))
	particle.set_meta("rotation_speed", randf_range(-3.0, 3.0))
	particle.set_meta("scale_target", randf_range(0.3, 0.7))

	return particle

func _animate_win_particle(particle: Control, tw: Tween, delay: float, duration: float) -> void:
	"""动画化单个胜利粒子"""
	var target_x: float = particle.get_meta("target_x", 100.0)
	var target_y: float = particle.get_meta("target_y", -100.0)
	var rot_speed: float = particle.get_meta("rotation_speed", 1.0)
	var scale_target: float = particle.get_meta("scale_target", 0.5)

	tw.tween_property(particle, "modulate:a", 1.0, duration * 0.18).from(0.0).set_delay(delay)
	tw.parallel().tween_property(particle, "modulate:a", 0.0, duration * 0.52).set_delay(delay + duration * 0.22)
	tw.parallel().tween_property(particle, "position:x", target_x, duration * 0.8).set_delay(delay).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(particle, "position:y", target_y, duration * 0.8).set_delay(delay).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(particle, "rotation", rot_speed, duration * 0.6).from(0.0).set_delay(delay)
	tw.parallel().tween_property(particle, "scale", Vector2(scale_target, scale_target), duration * 0.5).from(Vector2(1.0, 1.0)).set_delay(delay + duration * 0.3)

func _play_screen_shake(amplitude: float, frequency: float, duration: float) -> void:
	"""屏幕震动效果"""
	if not fx_enabled_effective():
		return

	var shake_count = int(duration * frequency)
	var tw := create_tween()

	for i in range(shake_count):
		var progress = float(i) / float(shake_count)
		var decay = 1.0 - progress
		var current_amplitude = amplitude * decay

		var offset = Vector2(
			randf_range(-current_amplitude, current_amplitude),
			randf_range(-current_amplitude, current_amplitude)
		)

		tw.tween_property(root_layer, "position", offset, 1.0 / frequency).from(root_layer.position)

	tw.tween_property(root_layer, "position", Vector2.ZERO, 0.05)

	# ============================================================
# 国风装饰元素工厂 / Guofeng Decorative Element Factory
# ============================================================

func update_menu_parallax(mouse_pos: Vector2) -> void:
	"""根据鼠标位置驱动主菜单Hero插画的视差位移 - 远近层不同幅度"""
	if menu_hero_art == null or not is_instance_valid(menu_hero_art):
		return
	var viewport_size = get_viewport().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	# 鼠标相对视口中心的归一化偏移 [-1, 1]
	var nx: float = clamp((mouse_pos.x / viewport_size.x) * 2.0 - 1.0, -1.0, 1.0)
	var ny: float = clamp((mouse_pos.y / viewport_size.y) * 2.0 - 1.0, -1.0, 1.0)
	# 视差层：远景小幅度、中景中等、近景大幅度（营造纵深）
	var layers := [
		["MenuHeroFarMountain", -2.0, -1.2],     # 远山：最小位移
		["MenuHeroMoon", -3.0, -2.0],            # 月亮：略大
		["MenuHeroMistCloud1", -4.0, -1.6],
		["MenuHeroMistCloud2", -3.6, -1.4],
		["MenuHeroGoldCloud", 4.0, 1.6],
		["MenuHeroWater", -5.0, -2.4],           # 水面：中等
		["MenuHeroPineLeft", 6.0, 3.0],          # 松枝：较大
		["MenuHeroBambooRight", -6.0, 3.0],      # 竹子：较大
		["MenuHeroPlumBlossom", 7.0, 3.6],       # 梅花：近景
		["MenuHeroRoundTable", 9.0, 4.4],        # 牌桌：近景
		["MenuHeroSeal", -8.0, -4.0],            # 印章：近景反向
	]
	for entry in layers:
		var node = menu_hero_art.get_node_or_null(str(entry[0]))
		if node == null or not is_instance_valid(node):
			continue
		var dx: float = float(entry[1]) * nx
		var dy: float = float(entry[2]) * ny
		# 用offset而非直接改position，避免与布局冲突，平滑跟随
		node.offset_left = lerp(node.offset_left, -dx, 0.18)
		node.offset_top = lerp(node.offset_top, -dy, 0.18)
		node.offset_right = lerp(node.offset_right, dx, 0.18)
		node.offset_bottom = lerp(node.offset_bottom, dy, 0.18)

func draw_menu_hero_illustration(parent: Control) -> Control:
	var art = Control.new()
	art.name = "MenuHeroIllustration"
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(art, rect_full(0.55, 0.12, 0.97, 0.86))
	parent.add_child(art)

	# 远景层 - 层叠远山剪影
	make_mountain_silhouette(art, rect_full(0.0, 0.0, 1.0, 0.60), 3, INK_WASH).name = "MenuHeroFarMountain"
	# 中景层 - 水面波纹
	make_water_ripple(art, rect_full(0.05, 0.58, 0.95, 0.82), "lake", true).name = "MenuHeroWater"

	# 月亮 - 右上角满月辉光
	make_moon_or_sun(art, rect_full(0.72, -0.05, 1.05, 0.28), "full_moon").name = "MenuHeroMoon"

	# 背景装饰层 - 云纹
	make_cloud_decoration(art, rect_full(-0.05, -0.05, 0.30, 0.28), "mist", false).name = "MenuHeroMistCloud1"
	make_cloud_decoration(art, rect_full(0.60, 0.55, 1.05, 1.05), "gold", false).name = "MenuHeroGoldCloud"
	make_cloud_decoration(art, rect_full(0.30, -0.08, 0.60, 0.18), "mist", false).name = "MenuHeroMistCloud2"

	# 松枝装饰 - 左侧
	make_pine_branch(art, rect_full(-0.02, 0.05, 0.14, 0.40), "left").name = "MenuHeroPineLeft"
	# 竹子装饰 - 右侧
	make_bamboo_decoration(art, rect_full(0.88, 0.25, 0.96, 0.75), 3).name = "MenuHeroBambooRight"

	# 梅花装饰 - 左下枝头
	make_plum_blossom(art, rect_full(0.02, 0.50, 0.28, 0.95), 2, ROUGE, true).name = "MenuHeroPlumBlossom"

	# 金色装饰线 - 画框边
	for item in [
		[rect_full(0.08, 0.08, 0.92, 0.10), Color(0.92, 0.78, 0.36, 0.22)],
		[rect_full(0.08, 0.90, 0.92, 0.92), Color(0.92, 0.78, 0.36, 0.18)],
		[rect_full(0.06, 0.10, 0.08, 0.90), Color(0.92, 0.78, 0.36, 0.15)],
		[rect_full(0.92, 0.10, 0.94, 0.90), Color(0.92, 0.78, 0.36, 0.15)],
	]:
		art.add_child(make_color_rect(item[0], item[1]))

	# 圆形牌桌 - 置于水面之上
	var table_disc = make_panel(art, rect_full(0.18, 0.42, 0.82, 0.96), Color(0.012, 0.060, 0.052, 0.86), 999, Color(0.68, 0.56, 0.28, 0.42), 0)
	table_disc.name = "MenuHeroRoundTable"
	var inner_table = make_panel(table_disc, rect_full(0.12, 0.14, 0.88, 0.86), Color(0.018, 0.092, 0.078, 0.78), 999, Color(0.86, 0.74, 0.38, 0.26), 0)
	inner_table.name = "MenuHeroInnerTable"

	# 桌面纹理装饰 - 同心圆
	make_panel(table_disc, rect_full(0.25, 0.25, 0.75, 0.75), Color(0.015, 0.080, 0.070, 0.35), 999, Color(0.86, 0.74, 0.38, 0.12), 0)
	make_panel(table_disc, rect_full(0.35, 0.35, 0.65, 0.65), Color(0.015, 0.080, 0.070, 0.25), 999, Color(0.86, 0.74, 0.38, 0.08), 0)

	# 水面锦鲤 - 两尾
	make_koi_fish(art, rect_full(0.22, 0.72, 0.38, 0.86), GOLD_PRIMARY, "right").name = "MenuHeroKoiGold"
	make_koi_fish(art, rect_full(0.58, 0.76, 0.74, 0.90), JADE_PRIMARY, "left").name = "MenuHeroKoiJade"

	# 麻将牌展示 - 三张牌形成视觉焦点
	var tiles := ["E", "Z", "5W"]
	for i in range(tiles.size()):
		var tile = make_tile_view(str(tiles[i]), Vector2(38, 52), false, Callable(), true)
		tile.name = "MenuHeroTile_%s" % str(tiles[i])
		table_disc.add_child(tile)
		apply_rect(tile, rect_full(0.26 + float(i) * 0.16, 0.15, 0.42 + float(i) * 0.16, 0.80))

	# 印章装饰 - 调整至月亮旁更佳构图位置
	var seal = make_seal_stamp(art, rect_full(0.62, 0.04, 0.80, 0.28), "云", "round")
	seal.name = "MenuHeroSeal"

		# 装饰性图标
	add_lucide_icon(art, "sparkles", rect_full(0.04, 0.44, 0.15, 0.68), Color(0.96, 0.84, 0.44, 0.42))
	add_lucide_icon(art, "star", rect_full(0.85, 0.42, 0.95, 0.58), Color(0.96, 0.84, 0.44, 0.38))

	# 金粉飘浮粒子 - 增强插画氛围感 / Gold dust shimmer particles
	if fx_enabled_effective() and DisplayServer.get_name().to_lower() != "headless":
		var dust_layer = Control.new()
		dust_layer.name = "MenuHeroDustLayer"
		dust_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		dust_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
		art.add_child(dust_layer)
		art.move_child(dust_layer, 0)  # 置于最底层，不遮挡牌面
		var dust_count := 14
		for i in range(dust_count):
			var dust = Panel.new()
			dust.mouse_filter = Control.MOUSE_FILTER_IGNORE
			var d_style = StyleBoxFlat.new()
			d_style.bg_color = Color(0.98, 0.90, 0.55, randf_range(0.28, 0.58))
			d_style.set_corner_radius_all(50)
			dust.add_theme_stylebox_override("panel", d_style)
			var dsize = randf_range(2.0, 5.0)
			dust.custom_minimum_size = Vector2(dsize, dsize)
			dust_layer.add_child(dust)
			var art_size = art.size
			if art_size.x <= 0.0:
				art_size = Vector2(420.0, 320.0)
			dust.position = Vector2(randf() * art_size.x, randf() * art_size.y)
			# 缓慢上浮 + 横向漂移 + 透明度呼吸
			var rise_dur = randf_range(6.0, 11.0)
			var d_tw := dust.create_tween()
			d_tw.set_loops(3600)
			d_tw.tween_property(dust, "position:y", dust.position.y - randf_range(40.0, 90.0), rise_dur).set_delay(float(i) * 0.3)
			d_tw.parallel().tween_property(dust, "modulate:a", 0.0, rise_dur).from(randf_range(0.4, 0.9))
			var d_sw := dust.create_tween()
			d_sw.set_loops(3600)
			d_sw.tween_property(dust, "position:x", dust.position.x + randf_range(-18.0, 18.0), randf_range(2.5, 4.5)).set_delay(float(i) * 0.3)
			d_sw.tween_property(dust, "position:x", dust.position.x, randf_range(2.5, 4.5))

	# 画意动画 - 多层次动效
	if fx_enabled_effective() and DisplayServer.get_name().to_lower() != "headless":
		# 整体呼吸 - 更柔和的节奏
		var breath_tween := art.create_tween()
		breath_tween.set_loops(3600)
		breath_tween.tween_property(art, "modulate:a", 0.88, 3.0).from(1.0)
		breath_tween.tween_property(art, "modulate:a", 1.0, 3.0).from(0.88)

		# 牌面柔和闪光 - 交替shimmer
		for i in range(tiles.size()):
			var tile_node = table_disc.get_node_or_null("MenuHeroTile_%s" % str(tiles[i]))
			if tile_node != null:
				var sparkle_tween := art.create_tween()
				sparkle_tween.set_loops(3600)
				sparkle_tween.tween_property(tile_node, "modulate", Color(1.08, 1.10, 1.06, 1.0), 2.0).set_delay(float(i) * 0.7)
				sparkle_tween.tween_property(tile_node, "modulate", Color(1.0, 1.0, 1.0, 1.0), 2.0)

		# 印章脉冲 - 更有节奏感
		if seal != null:
			var seal_tween := create_tween()
			seal_tween.set_loops(3600)
			seal_tween.tween_property(seal, "modulate:a", 0.65, 2.0).from(1.0)
			seal_tween.tween_property(seal, "modulate:a", 1.0, 2.0).from(0.65)

		# 锦鲤游动 - 轻微位移
		var koi_gold = art.get_node_or_null("MenuHeroKoiGold")
		if koi_gold != null:
			var koi_tw := create_tween()
			koi_tw.set_loops(3600)
			koi_tw.tween_property(koi_gold, "offset_left", 6.0, 4.0).from(0.0)
			koi_tw.parallel().tween_property(koi_gold, "offset_top", -3.0, 4.0).from(0.0)
			koi_tw.tween_property(koi_gold, "offset_left", 0.0, 4.0).from(6.0)
			koi_tw.parallel().tween_property(koi_gold, "offset_top", 0.0, 4.0).from(-3.0)
		var koi_jade = art.get_node_or_null("MenuHeroKoiJade")
		if koi_jade != null:
			var koi_tw2 := create_tween()
			koi_tw2.set_loops(3600)
			koi_tw2.tween_property(koi_jade, "offset_left", -5.0, 3.5).from(0.0)
			koi_tw2.parallel().tween_property(koi_jade, "offset_top", -2.0, 3.5).from(0.0)
			koi_tw2.tween_property(koi_jade, "offset_left", 0.0, 3.5).from(-5.0)
			koi_tw2.parallel().tween_property(koi_jade, "offset_top", 0.0, 3.5).from(-2.0)

	return art

func draw_table_atmosphere_frame(parent: Control) -> Control:
	var frame = Control.new()
	frame.name = "TableAtmosphereFrame"
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	parent.add_child(frame)
	# 角落装饰 - 回纹式
	make_chinese_corner(frame, rect_full(0.010, 0.010, 0.080, 0.080), "elaborate").name = "TableCornerTL"
	make_chinese_corner(frame, rect_full(0.920, 0.010, 0.990, 0.080), "elaborate").name = "TableCornerTR"
	make_chinese_corner(frame, rect_full(0.010, 0.920, 0.080, 0.990), "elaborate").name = "TableCornerBL"
	make_chinese_corner(frame, rect_full(0.920, 0.920, 0.990, 0.990), "elaborate").name = "TableCornerBR"
	make_cloud_decoration(frame, rect_full(0.030, 0.030, 0.250, 0.155), "mist", false).name = "TableMistCloudNW"
	make_cloud_decoration(frame, rect_full(0.740, 0.815, 0.970, 0.965), "mist", false).name = "TableMistCloudSE"
	# 竹子装饰 - 增加segments
	make_bamboo_decoration(frame, rect_full(0.018, 0.235, 0.045, 0.585), 5).name = "TableBambooLeft"
	make_bamboo_decoration(frame, rect_full(0.955, 0.415, 0.982, 0.765), 5).name = "TableBambooRight"
	# 笔触分隔线替换单色金线
	make_brush_stroke_divider(frame, rect_full(0.300, 0.040, 0.700, 0.050)).name = "TableTopDiv"
	make_brush_stroke_divider(frame, rect_full(0.300, 0.950, 0.700, 0.960)).name = "TableBottomDiv"
	# 侧面保留简单金线
	for item in [
		[rect_full(0.040, 0.300, 0.052, 0.700), Color(0.92, 0.78, 0.36, 0.12)],
		[rect_full(0.948, 0.300, 0.960, 0.700), Color(0.92, 0.78, 0.36, 0.12)],
	]:
		var line = make_color_rect(item[0], item[1])
		line.name = "TableAtmosphereGoldLine"
		frame.add_child(line)
	return frame

func draw_table_living_illustration(parent: Control) -> Control:
	var layer = Control.new()
	layer.name = "TableLivingIllustration"
	layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	parent.add_child(layer)
	draw_table_wall_lanterns(layer)
	draw_table_turn_flow(layer)
	draw_table_last_discard_ripple(layer)
	draw_table_center_starlight(layer)
	return layer

func draw_table_wall_lanterns(parent: Control) -> void:
	var wall_progress = clamp(float(get_wall_count()) / 144.0, 0.0, 1.0)
	var lantern_positions := [
		Vector2(0.500, 0.075),
		Vector2(0.912, 0.505),
		Vector2(0.500, 0.905),
		Vector2(0.088, 0.505),
	]
	for i in range(lantern_positions.size()):
		var pos: Vector2 = lantern_positions[i]
		var active_alpha = 0.20 + wall_progress * 0.34
		var lantern = make_panel(parent, rect_full(pos.x - 0.030, pos.y - 0.030, pos.x + 0.030, pos.y + 0.030), Color(0.72, 0.42, 0.16, active_alpha), 999, Color(0.96, 0.78, 0.34, 0.24 + wall_progress * 0.18), 0)
		lantern.name = "TableWallLantern_%d" % i
		var core = make_panel(lantern, rect_full(0.30, 0.24, 0.70, 0.76), Color(0.96, 0.76, 0.30, 0.40 + wall_progress * 0.30), 999, Color(1.0, 0.90, 0.52, 0.18), 0)
		core.name = "TableWallLanternCore_%d" % i
		if get_wall_count() <= 24:
			var warning = make_panel(lantern, rect_full(0.08, 0.08, 0.92, 0.92), Color(0.86, 0.28, 0.16, 0.18), 999, Color(1.0, 0.58, 0.28, 0.38), 0)
			warning.name = "TableWallLanternLowWarning_%d" % i
		if fx_enabled_effective() and DisplayServer.get_name().to_lower() != "headless":
			var tw := create_tween()
			tw.set_loops(3600)
			tw.tween_property(core, "modulate:a", 0.42, 0.80).from(1.0).set_delay(float(i) * 0.10)
			tw.tween_property(core, "modulate:a", 1.0, 0.80).from(0.42)

func draw_table_turn_flow(parent: Control) -> void:
	var positions := [
		Vector2(0.500, 0.815),
		Vector2(0.812, 0.505),
		Vector2(0.500, 0.205),
		Vector2(0.188, 0.505),
	]
	var seat = clamp(get_current_seat(), 0, 3)
	var pos: Vector2 = positions[seat]
	var accent = SEAT_ACCENT_COLORS[seat] if seat >= 0 and seat < SEAT_ACCENT_COLORS.size() else GOLD_PRIMARY
	var halo = make_panel(parent, rect_full(pos.x - 0.060, pos.y - 0.060, pos.x + 0.060, pos.y + 0.060), Color(accent.r, accent.g, accent.b, 0.10), 999, Color(0.96, 0.78, 0.34, 0.22), 0)
	halo.name = "TableTurnFlowHalo"
	var seal = make_panel(parent, rect_full(pos.x - 0.030, pos.y - 0.030, pos.x + 0.030, pos.y + 0.030), Color(accent.r, accent.g, accent.b, 0.30), 999, Color(0.96, 0.82, 0.42, 0.46), 0)
	seal.name = "TableTurnFlowSeal"
	var label = make_label(seal, CENTER_WIND_LABELS[seat], 13, Color(0.96, 0.90, 0.66), true)
	apply_rect(label, rect_full(0.0, 0.0, 1.0, 1.0))
	var flow = make_panel(parent, rect_full(0.380, 0.482, 0.620, 0.518), Color(accent.r, accent.g, accent.b, 0.11), 999, Color(accent.r, accent.g, accent.b, 0.11), 0)
	flow.name = "TableTurnFlowRibbon"
	if fx_enabled_effective() and DisplayServer.get_name().to_lower() != "headless":
		var tw := create_tween()
		tw.set_loops(3600)
		tw.tween_property(halo, "scale", Vector2(1.12, 1.12), 1.0).from(Vector2(0.92, 0.92)).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(halo, "modulate:a", 0.0, 1.0).from(0.82)
		tw.tween_property(halo, "scale", Vector2(0.92, 0.92), 0.05)
		tw.parallel().tween_property(halo, "modulate:a", 0.82, 0.05)

func draw_table_last_discard_ripple(parent: Control) -> void:
	var seat = get_last_discard_seat()
	if seat < 0 or get_last_discard() == "":
		return
	var ripple_rect = last_discard_focus_marker_rect_for_seat(seat)
	if ripple_rect.size == Vector2.ZERO:
		return
	var ripple = Control.new()
	ripple.name = "TableLastDiscardRipple"
	ripple.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(ripple, ripple_rect)
	parent.add_child(ripple)
	var accent = SEAT_ACCENT_COLORS[seat] if seat >= 0 and seat < SEAT_ACCENT_COLORS.size() else GOLD_PRIMARY
	for i in range(3):
		var pad = 0.04 + float(i) * 0.12
		var ring = make_panel(ripple, rect_full(-pad, -pad, 1.0 + pad, 1.0 + pad), Color(accent.r, accent.g, accent.b, 0.03), 999, Color(0.96, 0.78, 0.34, 0.20 - float(i) * 0.04), 0)
		ring.name = "TableLastDiscardRippleRing_%d" % i
		if fx_enabled_effective() and DisplayServer.get_name().to_lower() != "headless":
			var tw := create_tween()
			tw.set_loops(3600)
			tw.tween_property(ring, "scale", Vector2(1.08, 1.08), 0.90).from(Vector2(0.88, 0.88)).set_delay(float(i) * 0.14)
			tw.parallel().tween_property(ring, "modulate:a", 0.0, 0.90).from(0.78)

func draw_table_center_starlight(parent: Control) -> void:
	var star = Control.new()
	star.name = "TableCenterStarlight"
	star.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(star, rect_full(0.392, 0.348, 0.608, 0.660))
	parent.add_child(star)
	for i in range(8):
		var angle = float(i) * TAU / 8.0
		var radius = 0.34 if i % 2 == 0 else 0.24
		var center = Vector2(0.5 + cos(angle) * radius, 0.5 + sin(angle) * radius)
		var spark = make_panel(star, rect_full(center.x - 0.015, center.y - 0.015, center.x + 0.015, center.y + 0.015), Color(0.96, 0.78, 0.34, 0.24), 999, Color(1.0, 0.90, 0.52, 0.22), 0)
		spark.name = "TableCenterStarlightSpark_%d" % i
		if fx_enabled_effective() and DisplayServer.get_name().to_lower() != "headless":
			var tw := create_tween()
			tw.set_loops(3600)
			tw.tween_property(spark, "modulate:a", 0.18, 0.72).from(0.82).set_delay(float(i) * 0.08)
			tw.tween_property(spark, "modulate:a", 0.82, 0.72).from(0.18)


func draw_center_wind_compass(parent: Control) -> Control:
	var compass = Control.new()
	compass.name = "CenterWindCompass"
	compass.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(compass, rect_full(0.08, 0.08, 0.92, 0.92))
	parent.add_child(compass)
	# 精致同心环底盘
	make_panel(compass, rect_full(0.22, 0.22, 0.78, 0.78), Color(0.010, 0.050, 0.046, 0.18), 999, Color(0.88, 0.76, 0.42, 0.20), 0)
	make_panel(compass, rect_full(0.28, 0.28, 0.72, 0.72), Color(0.012, 0.046, 0.042, 0.14), 999, Color(0.86, 0.72, 0.38, 0.16), 0)
	make_panel(compass, rect_full(0.34, 0.34, 0.66, 0.66), Color(0.66, 0.54, 0.24, 0.12), 999, Color(0.96, 0.82, 0.44, 0.22), 0)
	var current = get_current_seat()
	var next = (current + 1) % 4
	var turn_track = make_panel(compass, rect_full(0.405, 0.405, 0.595, 0.595), Color(0, 0, 0, 0), 999, Color(0.88, 0.72, 0.34, 0.22), 1)
	turn_track.name = "CenterWindTurnTrack"
	draw_center_wind_direction_beads(compass, current)
	var wind_marks := [
		[rect_full(0.45, 0.00, 0.55, 0.15), "东", 0],
		[rect_full(0.85, 0.45, 1.00, 0.55), "南", 1],
		[rect_full(0.45, 0.85, 0.55, 1.00), "西", 2],
		[rect_full(0.00, 0.45, 0.15, 0.55), "北", 3],
	]
	for mark in wind_marks:
		var seat = int(mark[2])
		var active = seat == current
		var upcoming = seat == next
		var badge = make_panel(compass, mark[0], Color(0.52, 0.42, 0.16, 0.36 if active else 0.16), 999, Color(0.96, 0.82, 0.42, 0.46 if active else 0.18), 0)
		badge.name = "CenterWindCompass_%s" % str(mark[1])
		if active:
			# 双层脉冲光圈
			var halo = make_panel(badge, rect_full(-0.18, -0.18, 1.18, 1.18), Color(0.96, 0.80, 0.34, 0.12), 999, Color(1.0, 0.86, 0.42, 0.46), 0)
			halo.name = "CenterWindActiveHalo"
			var halo_outer = make_panel(badge, rect_full(-0.32, -0.32, 1.32, 1.32), Color(0.96, 0.80, 0.34, 0.06), 999, Color(1.0, 0.86, 0.42, 0.0), 0)
			halo_outer.name = "CenterWindActiveHaloOuter"
			var pointer = make_panel(badge, rect_full(0.360, -0.430, 0.640, -0.150), Color(0.96, 0.78, 0.32, 0.62), 999, Color(1.0, 0.90, 0.52, 0.30), 0)
			pointer.name = "CenterWindCurrentPointer"
			if fx_enabled_effective() and DisplayServer.get_name().to_lower() != "headless":
				var tw := create_tween()
				tw.set_loops(3600)
				tw.tween_property(halo, "modulate:a", 0.40, 0.72).from(0.88)
				tw.tween_property(halo, "modulate:a", 0.88, 0.72).from(0.40)
				var tw2 := create_tween()
				tw2.set_loops(3600)
				tw2.tween_property(halo_outer, "scale", Vector2(1.15, 1.15), 1.2).from(Vector2(0.85, 0.85)).set_ease(Tween.EASE_OUT)
				tw2.parallel().tween_property(halo_outer, "modulate:a", 0.0, 1.2).from(0.6)
				var pointer_tw := create_tween()
				pointer_tw.set_loops(3600)
				pointer_tw.tween_property(pointer, "offset_top", -2.0, 0.48).from(0.0).set_ease(Tween.EASE_OUT)
				pointer_tw.tween_property(pointer, "offset_top", 0.0, 0.48).from(-2.0).set_ease(Tween.EASE_IN)
		if seat == dealer_seat:
			var dealer_badge = make_badge(badge, rect_full(-0.20, 0.76, 0.48, 1.22), "庄", 8, Color(0.52, 0.12, 0.08, 0.94), Color(0.96, 0.62, 0.34, 0.42), Color(0.98, 0.90, 0.72))
			dealer_badge.name = "CenterWindDealerBadge"
			dealer_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if upcoming:
			var next_badge = make_badge(badge, rect_full(0.62, -0.20, 1.22, 0.24), "次", 8, Color(0.028, 0.048, 0.050, 0.94), Color(0.78, 0.66, 0.34, 0.34), Color(0.90, 0.86, 0.66))
			next_badge.name = "CenterWindNextBadge"
			next_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
			# 指向箭头脉冲
			if fx_enabled_effective() and DisplayServer.get_name().to_lower() != "headless":
				var arrow_tw := create_tween()
				arrow_tw.set_loops(3600)
				arrow_tw.tween_property(next_badge, "offset_top", -2.0, 0.6).from(0.0).set_ease(Tween.EASE_OUT)
				arrow_tw.tween_property(next_badge, "offset_top", 0.0, 0.6).from(-2.0).set_ease(Tween.EASE_IN)
		var label = make_label(badge, str(mark[1]), 12, GOLD_LIGHT if active else Color(0.64, 0.62, 0.46, 0.72), true)
		apply_rect(label, rect_full(0.0, 0.0, 1.0, 1.0))
	return compass

func draw_center_wind_direction_beads(parent: Control, current: int) -> void:
	var bead_positions := [
		Vector2(0.50, 0.205),
		Vector2(0.795, 0.50),
		Vector2(0.50, 0.795),
		Vector2(0.205, 0.50),
	]
	for i in range(bead_positions.size()):
		var turn_distance = (i - current + 4) % 4
		var pos: Vector2 = bead_positions[i]
		var alpha = 0.58 if turn_distance == 0 else 0.34 if turn_distance == 1 else 0.18
		var bead = make_panel(parent, rect_full(pos.x - 0.018, pos.y - 0.018, pos.x + 0.018, pos.y + 0.018), Color(0.88, 0.72, 0.34, alpha), 999, Color(1.0, 0.86, 0.46, alpha * 0.54), 0)
		bead.name = "CenterWindDirectionBead_%d" % i
		if fx_enabled_effective() and DisplayServer.get_name().to_lower() != "headless":
			var tw := create_tween()
			tw.set_loops(3600)
			tw.tween_property(bead, "modulate:a", max(0.18, alpha * 0.55), 0.60).from(alpha).set_delay(float(turn_distance) * 0.10)
			tw.tween_property(bead, "modulate:a", alpha, 0.60).from(max(0.18, alpha * 0.55))


func draw_summary_victory_ribbon(parent: Control) -> Control:
	var ribbon = Control.new()
	ribbon.name = "SummaryVictoryRibbon"
	ribbon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(ribbon, rect_full(0.105, 0.055, 0.305, 0.145))
	parent.add_child(ribbon)
	make_panel(ribbon, rect_full(0.08, 0.20, 0.92, 0.80), Color(0.58, 0.12, 0.08, 0.58), 4, Color(1.0, 0.78, 0.34, 0.42), 0)
	var left_tail = make_color_rect(rect_full(0.00, 0.30, 0.16, 0.70), Color(0.42, 0.08, 0.06, 0.54))
	left_tail.name = "SummaryRibbonLeftTail"
	ribbon.add_child(left_tail)
	var right_tail = make_color_rect(rect_full(0.84, 0.30, 1.00, 0.70), Color(0.42, 0.08, 0.06, 0.54))
	right_tail.name = "SummaryRibbonRightTail"
	ribbon.add_child(right_tail)
	add_lucide_icon(ribbon, "trophy", rect_full(0.44, 0.08, 0.56, 0.92), Color(0.98, 0.86, 0.46, 0.86))
	return ribbon

func make_ink_border(parent: Control, rect: Rect2, thickness: float = 2.0) -> Control:
	"""创建水墨笔触边框 - 模拟毛笔绘制效果"""
	var container = Control.new()
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(container, rect)

	# 外框 - 粗笔触
	var outer = make_color_rect(rect_full(0.0, 0.0, 1.0, thickness / rect.size.y), INK_DARK)
	container.add_child(outer)

	# 内框 - 细笔触
	var inner = make_color_rect(rect_full(0.0, 0.0, 1.0, (thickness * 0.5) / rect.size.y), INK_MEDIUM)
	inner.offset_top = thickness / rect.size.y
	container.add_child(inner)

	# 添加随机噪点模拟墨迹
	var noise_count = int(rect.size.x * 0.3)
	for i in range(noise_count):
		var x = randf()
		var noise_alpha = randf_range(0.1, 0.3)
		var noise = make_color_rect(
			rect_full(x - 0.002, 0.0, x + 0.002, 0.02),
			Color(INK_DARK.r, INK_DARK.g, INK_DARK.b, noise_alpha)
		)
		container.add_child(noise)

	parent.add_child(container)
	return container

func make_cloud_decoration(parent: Control, rect: Rect2, style: String = "auspicious", animated: bool = false) -> Control:
	"""创建祥云装饰元素"""
	var cloud = Control.new()
	cloud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(cloud, rect)

	var cloud_color: Color
	match style:
		"auspicious":
			cloud_color = CLOUD_WHITE
		"mist":
			cloud_color = CLOUD_MIST
		"gold":
			cloud_color = CLOUD_GOLD
		_:
			cloud_color = CLOUD_WHITE

	# 使用多个椭圆组合成祥云形状
	var puffs := [
		{"x": 0.15, "y": 0.55, "rx": 0.18, "ry": 0.28},
		{"x": 0.35, "y": 0.42, "rx": 0.22, "ry": 0.32},
		{"x": 0.58, "y": 0.48, "rx": 0.20, "ry": 0.30},
		{"x": 0.78, "y": 0.58, "rx": 0.16, "ry": 0.24},
		{"x": 0.25, "y": 0.68, "rx": 0.15, "ry": 0.22},
		{"x": 0.50, "y": 0.72, "rx": 0.18, "ry": 0.26},
		{"x": 0.72, "y": 0.76, "rx": 0.14, "ry": 0.20},
	]

	for puff in puffs:
		var ellipse = Panel.new()
		ellipse.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ellipse.modulate = cloud_color
		var style_box = StyleBoxFlat.new()
		style_box.bg_color = Color(cloud_color.r, cloud_color.g, cloud_color.b, cloud_color.a * 0.6)
		style_box.set_corner_radius_all(50)
		ellipse.add_theme_stylebox_override("panel", style_box)
		apply_rect(ellipse, rect_full(
			puff["x"] - puff["rx"],
			puff["y"] - puff["ry"],
			puff["x"] + puff["rx"],
			puff["y"] + puff["ry"]
		))
		cloud.add_child(ellipse)

	if animated and fx_enabled_effective():
		var tw := create_tween()
		tw.set_loops(3600)
		tw.tween_property(cloud, "modulate:a", cloud_color.a * 0.7, 2.5).from(cloud_color.a)
		tw.tween_property(cloud, "modulate:a", cloud_color.a, 2.5).from(cloud_color.a * 0.7)
		tw.tween_property(cloud, "offset_left", 8.0, 4.0).from(0.0)
		tw.tween_property(cloud, "offset_left", 0.0, 4.0).from(8.0)

	parent.add_child(cloud)
	return cloud

func make_chinese_corner(parent: Control, rect: Rect2, style: String = "simple") -> Control:
	"""创建中式角落装饰 - 回纹或如意纹"""
	var corner = Control.new()
	corner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(corner, rect)

	var line_color = GOLD_PRIMARY
	var line_width = max(1.0, rect.size.x * 0.08)

	# 绘制回纹图案 (使用ColorRect模拟)
	# 水平线
	var h1 = make_color_rect(rect_full(0.0, 0.0, 1.0, line_width / rect.size.y), line_color)
	corner.add_child(h1)

	# 垂直线
	var v1 = make_color_rect(rect_full(0.0, 0.0, line_width / rect.size.x, 1.0), line_color)
	corner.add_child(v1)

	# 内部回纹
	if style == "elaborate":
		var margin = 0.15
		var h2 = make_color_rect(
			rect_full(margin, margin, 1.0 - margin, margin + line_width / rect.size.y),
			line_color
		)
		h2.modulate.a = 0.7
		corner.add_child(h2)

		var v2 = make_color_rect(
			rect_full(margin, margin, margin + line_width / rect.size.x, 1.0 - margin),
			line_color
		)
		v2.modulate.a = 0.7
		corner.add_child(v2)

	parent.add_child(corner)
	return corner

func make_seal_stamp(parent: Control, rect: Rect2, text: String = "胡", style: String = "square") -> Control:
	"""创建印章装饰效果"""
	var seal = Control.new()
	seal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(seal, rect)

	# 印章底色
	var stamp = Panel.new()
	stamp.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stamp.modulate = CINNABAR

	var stamp_style = StyleBoxFlat.new()
	stamp_style.bg_color = Color(CINNABAR.r, CINNABAR.g, CINNABAR.b, 0.85)
	stamp_style.set_border_width_all(2)
	stamp_style.border_color = CINNABAR.darkened(0.2)
	if style == "round":
		stamp_style.set_corner_radius_all(int(min(rect.size.x, rect.size.y) * 0.5))
	else:
		stamp_style.set_corner_radius_all(4)
	stamp.add_theme_stylebox_override("panel", stamp_style)
	stamp.set_anchors_preset(Control.PRESET_FULL_RECT)
	seal.add_child(stamp)

	# 印章文字
	var label = make_label(seal, text, max(12, int(min(rect.size.x, rect.size.y) * 0.6)), PAPER_WARM, true)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.3))

	# 添加磨损效果
	var wear_count = 3
	for i in range(wear_count):
		var wear = make_color_rect(
			rect_full(randf() * 0.6, randf() * 0.6, randf() * 0.4 + 0.5, randf() * 0.4 + 0.5),
			Color(PAPER_WARM.r, PAPER_WARM.g, PAPER_WARM.b, randf_range(0.05, 0.15))
		)
		seal.add_child(wear)

	parent.add_child(seal)
	return seal

func make_bamboo_decoration(parent: Control, rect: Rect2, segments: int = 3) -> Control:
	"""创建竹节装饰"""
	var bamboo = Control.new()
	bamboo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(bamboo, rect)

	var segment_height = 1.0 / float(segments)

	for i in range(segments):
		var y_start = i * segment_height
		var y_end = (i + 1) * segment_height

		# 竹节主体
		var segment = make_color_rect(
			rect_full(0.2, y_start + segment_height * 0.1, 0.8, y_end - segment_height * 0.1),
			JADE_DARK.darkened(0.1 + float(i) * 0.05)
		)
		bamboo.add_child(segment)

		# 竹节环
		if i < segments - 1:
			var ring = make_color_rect(
				rect_full(0.15, y_end - segment_height * 0.15, 0.85, y_end + segment_height * 0.05),
				JADE_DARK.darkened(0.2)
			)
			bamboo.add_child(ring)

	parent.add_child(bamboo)
	return bamboo

# ============================================================
# 国风雅韵扩展装饰图元 / Guofeng Extended Decoration Primitives
# ============================================================

func make_mountain_silhouette(parent: Control, rect: Rect2, layers: int = 3, base_color: Color = INK_WASH) -> Control:
	"""创建层叠远山剪影 - 水墨山水远景点缀"""
	var mountain = Control.new()
	mountain.name = "MountainSilhouette"
	mountain.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(mountain, rect)
	for layer_i in range(layers):
		var layer_alpha = 0.25 + 0.20 * float(layer_i) / float(max(1, layers - 1))
		var layer_color = Color(base_color.r, base_color.g, base_color.b, layer_alpha)
		var peaks := 3 + layer_i % 2
		var base_y := 0.80 - float(layer_i) * 0.12
		var peak_spread := 0.90 / float(peaks)
		for p in range(peaks):
			var peak_x := 0.05 + float(p) * peak_spread + (0.05 * float(layer_i % 3))
			var peak_height := 0.28 + 0.14 * sin(float(p + layer_i) * 1.7)
			var peak_width := peak_spread * 0.55
			var peak = Panel.new()
			peak.mouse_filter = Control.MOUSE_FILTER_IGNORE
			var peak_style = StyleBoxFlat.new()
			peak_style.bg_color = layer_color
			peak_style.set_corner_radius_all(4)
			peak.add_theme_stylebox_override("panel", peak_style)
			mountain.add_child(peak)
			apply_rect(peak, rect_full(peak_x - peak_width * 0.5, base_y - peak_height, peak_x + peak_width * 0.5, base_y + 0.06))
		var base_strip = Panel.new()
		base_strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var strip_style = StyleBoxFlat.new()
		strip_style.bg_color = layer_color
		strip_style.set_corner_radius_all(0)
		base_strip.add_theme_stylebox_override("panel", strip_style)
		mountain.add_child(base_strip)
		apply_rect(base_strip, rect_full(0.0, base_y, 1.0, base_y + 0.10))
	parent.add_child(mountain)
	return mountain

func make_water_ripple(parent: Control, rect: Rect2, style: String = "still", animated: bool = false) -> Control:
	"""创建水面波纹装饰 - 静水/流水/湖面效果"""
	var water = Control.new()
	water.name = "WaterRipple"
	water.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(water, rect)
	var wave_color := Color(0.28, 0.48, 0.52, 0.18) if style == "lake" else Color(0.22, 0.42, 0.46, 0.14)
	var wave_count := 5 if style == "flowing" else 3
	var base_alpha := 0.18 if style == "still" else (0.14 if style == "flowing" else 0.22)
	for w in range(wave_count):
		var wave = Panel.new()
		wave.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var wave_style = StyleBoxFlat.new()
		wave_style.bg_color = Color(wave_color.r, wave_color.g, wave_color.b, base_alpha * (1.0 - float(w) * 0.25))
		wave_style.set_corner_radius_all(50)
		wave.add_theme_stylebox_override("panel", wave_style)
		water.add_child(wave)
		var y_pos := 0.20 + float(w) * (0.60 / float(max(1, wave_count - 1)))
		var x_shrink := float(w) * 0.08
		apply_rect(wave, rect_full(0.02 + x_shrink, y_pos - 0.04, 0.98 - x_shrink, y_pos + 0.04))
		if style == "flowing":
			wave.rotation = 0.01 * float(w % 2 * 2 - 1)
	if animated and fx_enabled_effective():
		var tw := create_tween()
		tw.set_loops(3600)
		tw.tween_property(water, "modulate:a", 0.70, 3.0).from(1.0)
		tw.tween_property(water, "modulate:a", 1.0, 3.0).from(0.70)
		if style == "flowing":
			var tw2 := create_tween()
			tw2.set_loops(3600)
			tw2.tween_property(water, "offset_left", 4.0, 2.0).from(0.0)
			tw2.tween_property(water, "offset_left", 0.0, 2.0).from(4.0)
	parent.add_child(water)
	return water

func make_moon_or_sun(parent: Control, rect: Rect2, phase: String = "full_moon") -> Control:
	"""创建月亮/太阳装饰 - 满月/新月/旭日"""
	var moon = Control.new()
	moon.name = "MoonOrSun"
	moon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(moon, rect)
	var body_color: Color
	var glow_color: Color
	match phase:
		"full_moon":
			body_color = Color(0.96, 0.94, 0.86, 0.92)
			glow_color = Color(0.98, 0.96, 0.82, 0.28)
		"crescent":
			body_color = Color(0.94, 0.92, 0.84, 0.88)
			glow_color = Color(0.96, 0.94, 0.80, 0.22)
		"rising_sun":
			body_color = Color(0.96, 0.68, 0.32, 0.94)
			glow_color = Color(1.0, 0.78, 0.42, 0.35)
		_:
			body_color = Color(0.96, 0.94, 0.86, 0.92)
			glow_color = Color(0.98, 0.96, 0.82, 0.28)
	# Outer glow layers
	for g in range(3):
		var glow = Panel.new()
		glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var glow_style = StyleBoxFlat.new()
		glow_style.bg_color = Color(glow_color.r, glow_color.g, glow_color.b, glow_color.a * (0.30 - float(g) * 0.08))
		glow_style.set_corner_radius_all(50)
		glow.add_theme_stylebox_override("panel", glow_style)
		moon.add_child(glow)
		var expand := 0.08 * float(g + 1)
		apply_rect(glow, rect_full(0.50 - 0.24 - expand, 0.50 - 0.24 - expand, 0.50 + 0.24 + expand, 0.50 + 0.24 + expand))
	# Moon body
	var body = Panel.new()
	body.name = "MoonBody"
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var body_style = StyleBoxFlat.new()
	body_style.bg_color = body_color
	body_style.set_corner_radius_all(50)
	if phase == "rising_sun":
		body_style.border_color = Color(1.0, 0.58, 0.28, 0.42)
		body_style.set_border_width_all(2)
	body.add_theme_stylebox_override("panel", body_style)
	moon.add_child(body)
	apply_rect(body, rect_full(0.26, 0.26, 0.74, 0.74))
	# Crescent shadow
	if phase == "crescent":
		var shadow = Panel.new()
		shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var shadow_style = StyleBoxFlat.new()
		shadow_style.bg_color = Color(0.02, 0.02, 0.03, 0.92)
		shadow_style.set_corner_radius_all(50)
		shadow.add_theme_stylebox_override("panel", shadow_style)
		moon.add_child(shadow)
		apply_rect(shadow, rect_full(0.34, 0.18, 0.82, 0.82))
	if fx_enabled_effective() and DisplayServer.get_name().to_lower() != "headless":
		var tw := create_tween()
		tw.set_loops(3600)
		tw.tween_property(moon, "modulate:a", 0.72, 4.0).from(1.0)
		tw.tween_property(moon, "modulate:a", 1.0, 4.0).from(0.72)
	parent.add_child(moon)
	return moon

func make_plum_blossom(parent: Control, rect: Rect2, count: int = 3, petal_color: Color = ROUGE, animated: bool = false) -> Control:
	"""创建梅花装饰 - 五瓣梅花 + 花蕊 + 短枝"""
	var blossom = Control.new()
	blossom.name = "PlumBlossom"
	blossom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(blossom, rect)
	# Branch lines
	var branch_color = Color(0.36, 0.26, 0.22, 0.72)
	var branch_segments := [
		rect_full(0.42, 0.80, 0.48, 0.95),
		rect_full(0.48, 0.55, 0.52, 0.82),
		rect_full(0.30, 0.30, 0.50, 0.56),
		rect_full(0.52, 0.40, 0.68, 0.56),
	]
	for seg in branch_segments:
		var branch = Panel.new()
		branch.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var b_style = StyleBoxFlat.new()
		b_style.bg_color = branch_color
		b_style.set_corner_radius_all(50)
		branch.add_theme_stylebox_override("panel", b_style)
		blossom.add_child(branch)
		apply_rect(branch, seg)
	# Flowers
	for f_idx in range(count):
		var flower = Control.new()
		flower.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var positions := [Vector2(0.32, 0.28), Vector2(0.62, 0.42), Vector2(0.48, 0.16), Vector2(0.72, 0.28), Vector2(0.25, 0.48)]
		var fpos = positions[f_idx % positions.size()]
		var fsize := 0.08 + 0.03 * float(f_idx % 3)
		# Five petals
		for p in range(5):
			var angle := float(p) * TAU / 5.0
			var petal = Panel.new()
			petal.mouse_filter = Control.MOUSE_FILTER_IGNORE
			var petal_style = StyleBoxFlat.new()
			petal_style.bg_color = Color(petal_color.r, petal_color.g, petal_color.b, 0.78 - 0.08 * float(f_idx))
			petal_style.set_corner_radius_all(50)
			petal.add_theme_stylebox_override("panel", petal_style)
			flower.add_child(petal)
			var px: float = fpos.x + cos(angle) * fsize * 0.5
			var py: float = fpos.y + sin(angle) * fsize * 0.5
			apply_rect(petal, rect_full(px - fsize * 0.32, py - fsize * 0.32, px + fsize * 0.32, py + fsize * 0.32))
		# Stamen
		var stamen = Panel.new()
		stamen.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var stamen_style = StyleBoxFlat.new()
		stamen_style.bg_color = Color(GOLD_BRIGHT.r, GOLD_BRIGHT.g, GOLD_BRIGHT.b, 0.86)
		stamen_style.set_corner_radius_all(50)
		stamen.add_theme_stylebox_override("panel", stamen_style)
		flower.add_child(stamen)
		var stamen_size := fsize * 0.22
		apply_rect(stamen, rect_full(fpos.x - stamen_size, fpos.y - stamen_size, fpos.x + stamen_size, fpos.y + stamen_size))
		blossom.add_child(flower)
	if animated and fx_enabled_effective() and DisplayServer.get_name().to_lower() != "headless":
		var tw := create_tween()
		tw.set_loops(3600)
		tw.tween_property(blossom, "rotation", 0.012, 3.0).from(-0.012)
		tw.tween_property(blossom, "rotation", -0.012, 3.0).from(0.012)
	parent.add_child(blossom)
	return blossom

func make_pine_branch(parent: Control, rect: Rect2, direction: String = "left") -> Control:
	"""创建松枝装饰 - 斜向枝干 + 针叶簇"""
	var pine = Control.new()
	pine.name = "PineBranch"
	pine.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(pine, rect)
	var bark_color := Color(0.32, 0.24, 0.18, 0.82)
	var needle_color := Color(0.18, 0.38, 0.28, 0.78)
	var flip_x := -1.0 if direction == "right" else 1.0
	# Main branch
	var branch_angle := 0.22 * flip_x
	var main_branch = Panel.new()
	main_branch.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main_branch.rotation = branch_angle
	var mb_style = StyleBoxFlat.new()
	mb_style.bg_color = bark_color
	mb_style.set_corner_radius_all(50)
	main_branch.add_theme_stylebox_override("panel", mb_style)
	pine.add_child(main_branch)
	apply_rect(main_branch, rect_full(0.15, 0.42, 0.85, 0.58))
	# Needle clusters
	var clusters := [
		Vector2(0.28, 0.30), Vector2(0.48, 0.26), Vector2(0.68, 0.32),
		Vector2(0.38, 0.56), Vector2(0.58, 0.60), Vector2(0.78, 0.58),
	]
	for cluster_pos in clusters:
		var cluster = Panel.new()
		cluster.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var cl_style = StyleBoxFlat.new()
		cl_style.bg_color = Color(needle_color.r, needle_color.g, needle_color.b, 0.62 + 0.14 * randf())
		cl_style.set_corner_radius_all(50)
		cluster.add_theme_stylebox_override("panel", cl_style)
		pine.add_child(cluster)
		apply_rect(cluster, rect_full(cluster_pos.x - 0.10, cluster_pos.y - 0.10, cluster_pos.x + 0.10, cluster_pos.y + 0.10))
	parent.add_child(pine)
	return pine

func make_koi_fish(parent: Control, rect: Rect2, fish_color: Color = GOLD_PRIMARY, direction: String = "right") -> Control:
	"""创建简化锦鲤装饰 - 椭圆鱼身 + 尾 + 眼"""
	var koi = Control.new()
	koi.name = "KoiFish"
	koi.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(koi, rect)
	var flip := -1.0 if direction == "left" else 1.0
	# Body
	var body = Panel.new()
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var body_style = StyleBoxFlat.new()
	body_style.bg_color = Color(fish_color.r, fish_color.g, fish_color.b, 0.82)
	body_style.set_corner_radius_all(50)
	body.add_theme_stylebox_override("panel", body_style)
	koi.add_child(body)
	apply_rect(body, rect_full(0.22, 0.30, 0.72, 0.70))
	# Tail
	var tail = Panel.new()
	tail.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tail.rotation = 0.28 * flip
	var tail_style = StyleBoxFlat.new()
	tail_style.bg_color = Color(fish_color.r, fish_color.g, fish_color.b, 0.68)
	tail_style.set_corner_radius_all(50)
	tail.add_theme_stylebox_override("panel", tail_style)
	koi.add_child(tail)
	if direction == "right":
		apply_rect(tail, rect_full(0.04, 0.22, 0.28, 0.50))
	else:
		apply_rect(tail, rect_full(0.72, 0.22, 0.96, 0.50))
	# Eye
	var eye = Panel.new()
	eye.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var eye_style = StyleBoxFlat.new()
	eye_style.bg_color = Color(0.04, 0.04, 0.06, 0.92)
	eye_style.set_corner_radius_all(50)
	eye.add_theme_stylebox_override("panel", eye_style)
	koi.add_child(eye)
	var eye_x := 0.62 if direction == "right" else 0.32
	apply_rect(eye, rect_full(eye_x - 0.04, 0.38, eye_x + 0.04, 0.46))
	# Dorsal fin
	var fin = Panel.new()
	fin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var fin_style = StyleBoxFlat.new()
	fin_style.bg_color = Color(fish_color.r * 0.82, fish_color.g * 0.82, fish_color.b * 0.82, 0.58)
	fin_style.set_corner_radius_all(50)
	fin.add_theme_stylebox_override("panel", fin_style)
	koi.add_child(fin)
	apply_rect(fin, rect_full(0.38, 0.18, 0.58, 0.34))
	parent.add_child(koi)
	return koi

func make_brush_stroke_divider(parent: Control, rect: Rect2, thickness: float = 2.5) -> Control:
	"""创建毛笔笔触分隔线 - 中粗端细的流线造型"""
	var stroke = Control.new()
	stroke.name = "BrushStrokeDivider"
	stroke.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(stroke, rect)
	var ink_color := INK_MEDIUM
	var ink_alpha := 0.52
	# Main body - wider center
	var main = Panel.new()
	main.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var main_style = StyleBoxFlat.new()
	main_style.bg_color = Color(ink_color.r, ink_color.g, ink_color.b, ink_alpha)
	main_style.set_corner_radius_all(50)
	main.add_theme_stylebox_override("panel", main_style)
	stroke.add_child(main)
	apply_rect(main, rect_full(0.12, 0.28, 0.88, 0.72))
	# Start dot (brush press - thicker start)
	var start_dot = Panel.new()
	start_dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var s_style = StyleBoxFlat.new()
	s_style.bg_color = Color(ink_color.r, ink_color.g, ink_color.b, ink_alpha * 1.3)
	s_style.set_corner_radius_all(50)
	start_dot.add_theme_stylebox_override("panel", s_style)
	stroke.add_child(start_dot)
	apply_rect(start_dot, rect_full(0.06, 0.20, 0.14, 0.80))
	# Taper ends
	var taper_r = Panel.new()
	taper_r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tr_style = StyleBoxFlat.new()
	tr_style.bg_color = Color(ink_color.r, ink_color.g, ink_color.b, ink_alpha * 0.5)
	tr_style.set_corner_radius_all(50)
	taper_r.add_theme_stylebox_override("panel", tr_style)
	stroke.add_child(taper_r)
	apply_rect(taper_r, rect_full(0.86, 0.32, 0.96, 0.68))
	# Splatter dots (ink spray)
	for _i in range(3):
		var dot = Panel.new()
		dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var d_style = StyleBoxFlat.new()
		d_style.bg_color = Color(ink_color.r, ink_color.g, ink_color.b, 0.18 + randf() * 0.12)
		d_style.set_corner_radius_all(50)
		dot.add_theme_stylebox_override("panel", d_style)
		stroke.add_child(dot)
		var dx := 0.88 + randf() * 0.10
		var dy := 0.30 + randf() * 0.40
		apply_rect(dot, rect_full(dx - 0.02, dy - 0.02, dx + 0.02, dy + 0.02))
	parent.add_child(stroke)
	return stroke

func make_lantern(parent: Control, rect: Rect2, color: Color = CINNABAR, lit: bool = true) -> Control:
	"""创建灯笼装饰 - 灯体 + 金环 + 穗子"""
	var lantern = Control.new()
	lantern.name = "Lantern"
	lantern.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(lantern, rect)
	# Top cap
	var top_cap = Panel.new()
	top_cap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tc_style = StyleBoxFlat.new()
	tc_style.bg_color = GOLD_DARK
	tc_style.set_corner_radius_all(3)
	top_cap.add_theme_stylebox_override("panel", tc_style)
	lantern.add_child(top_cap)
	apply_rect(top_cap, rect_full(0.32, 0.04, 0.68, 0.10))
	# Hanging string
	var hstring = Panel.new()
	hstring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var hs_style = StyleBoxFlat.new()
	hs_style.bg_color = GOLD_DARK
	hs_style.set_corner_radius_all(1)
	hstring.add_theme_stylebox_override("panel", hs_style)
	lantern.add_child(hstring)
	apply_rect(hstring, rect_full(0.46, 0.0, 0.54, 0.06))
	# Main body
	var body = Panel.new()
	body.name = "LanternBody"
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var body_style = StyleBoxFlat.new()
	body_style.bg_color = color
	body_style.border_color = Color(color.r * 0.72, color.g * 0.72, color.b * 0.72, 0.52)
	body_style.set_border_width_all(1)
	body_style.set_corner_radius_all(12)
	body.add_theme_stylebox_override("panel", body_style)
	lantern.add_child(body)
	apply_rect(body, rect_full(0.12, 0.10, 0.88, 0.76))
	# Bottom cap
	var bottom_cap = Panel.new()
	bottom_cap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bc_style = StyleBoxFlat.new()
	bc_style.bg_color = GOLD_DARK
	bc_style.set_corner_radius_all(3)
	bottom_cap.add_theme_stylebox_override("panel", bc_style)
	lantern.add_child(bottom_cap)
	apply_rect(bottom_cap, rect_full(0.32, 0.76, 0.68, 0.82))
	# Tassel
	var tassel = Panel.new()
	tassel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tl_style = StyleBoxFlat.new()
	tl_style.bg_color = Color(color.r * 0.88, color.g * 0.72, color.b * 0.42, 0.78)
	tl_style.set_corner_radius_all(2)
	tassel.add_theme_stylebox_override("panel", tl_style)
	lantern.add_child(tassel)
	apply_rect(tassel, rect_full(0.42, 0.82, 0.58, 0.96))
	# Inner glow when lit
	if lit:
		var glow = Panel.new()
		glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var gl_style = StyleBoxFlat.new()
		gl_style.bg_color = Color(1.0, 0.92, 0.62, 0.18)
		gl_style.set_corner_radius_all(50)
		glow.add_theme_stylebox_override("panel", gl_style)
		lantern.add_child(glow)
		apply_rect(glow, rect_full(0.18, 0.16, 0.82, 0.72))
		if fx_enabled_effective() and DisplayServer.get_name().to_lower() != "headless":
			var tw := create_tween()
			tw.set_loops(3600)
			tw.tween_property(glow, "modulate:a", 0.62, 1.8).from(1.0)
			tw.tween_property(glow, "modulate:a", 1.0, 1.8).from(0.62)
	parent.add_child(lantern)
	return lantern

# ============================================================
# 界面过渡动画 / Interface Transition Animation
# ============================================================

func play_menu_transition(from_menu: Control, to_menu: Callable, style: String = "slide_left") -> void:
	"""菜单切换动画"""
	if not fx_enabled_effective():
		to_menu.call()
		return

	var duration := float(TRANSITION_SLIDE_DURATION_MSEC) / 1000.0
	var viewport_size = get_viewport().size

	match style:
		"slide_left":
			# 当前菜单滑出
			var tw_out := create_tween()
			tw_out.tween_property(from_menu, "position:x", -viewport_size.x, duration).from(0.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			tw_out.parallel().tween_property(from_menu, "modulate:a", 0.5, duration).from(1.0)

			# 新菜单从右侧滑入
			tw_out.tween_callback(func() -> void:
				from_menu.queue_free()
				to_menu.call()
				root_layer.position.x = viewport_size.x

				var tw_in := create_tween()
				tw_in.tween_property(root_layer, "position:x", 0.0, duration).from(viewport_size.x).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
				tw_in.parallel().tween_property(root_layer, "modulate:a", 1.0, duration).from(0.5)
			)

		"slide_right":
			var tw_out := create_tween()
			tw_out.tween_property(from_menu, "position:x", viewport_size.x, duration).from(0.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			tw_out.parallel().tween_property(from_menu, "modulate:a", 0.5, duration).from(1.0)

			tw_out.tween_callback(func() -> void:
				from_menu.queue_free()
				to_menu.call()
				root_layer.position.x = -viewport_size.x

				var tw_in := create_tween()
				tw_in.tween_property(root_layer, "position:x", 0.0, duration).from(-viewport_size.x).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
				tw_in.parallel().tween_property(root_layer, "modulate:a", 1.0, duration).from(0.5)
			)

		"fade":
			var tw := create_tween()
			tw.tween_property(from_menu, "modulate:a", 0.0, duration * 0.5)
			tw.tween_callback(func() -> void:
				from_menu.queue_free()
				to_menu.call()
				root_layer.modulate.a = 0.0
			)
			tw.tween_property(root_layer, "modulate:a", 1.0, duration * 0.5)

		"zoom":
			var tw := create_tween()
			tw.set_parallel(true)
			tw.tween_property(from_menu, "scale", Vector2(0.8, 0.8), duration * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
			tw.tween_property(from_menu, "modulate:a", 0.0, duration * 0.5)

			tw.tween_callback(func() -> void:
				from_menu.queue_free()
				to_menu.call()
				root_layer.scale = Vector2(1.1, 1.1)
				root_layer.modulate.a = 0.0
			).set_delay(duration * 0.5)

			tw.tween_property(root_layer, "scale", Vector2(1.0, 1.0), duration * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT).set_delay(duration * 0.5)
			tw.tween_property(root_layer, "modulate:a", 1.0, duration * 0.5).set_delay(duration * 0.5)

func play_card_flip_animation(container: Control, cards: Array, stagger: bool = true) -> void:
	"""卡片翻转进场动画（用于菜单卡片等）"""
	if not fx_enabled_effective() or cards.is_empty():
		return

	var duration := float(TRANSITION_CARD_FLIP_DURATION_MSEC) / 1000.0
	var stagger_delay := float(TRANSITION_STAGGER_DELAY_MSEC) / 1000.0

	for i in range(cards.size()):
		var card = cards[i]
		card.scale = Vector2(0.0, 1.0)
		card.modulate.a = 0.0

		var delay = 0.0
		if stagger:
			delay = float(i) * stagger_delay

		var tw := create_tween()
		tw.set_parallel(true)
		tw.tween_property(card, "scale:x", 1.0, duration).from(0.0).set_delay(delay).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(card, "modulate:a", 1.0, duration * 0.6).from(0.0).set_delay(delay)

func play_button_press_animation(button: Button, scale_amount: float = 0.92) -> void:
	"""按钮按下动画"""
	if not fx_enabled_effective():
		return

	var tw := create_tween()
	tw.tween_property(button, "scale", Vector2(scale_amount, scale_amount), 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(button, "scale", Vector2(1.0, 1.0), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

# ============================================================
# 环境氛围动画系统 / Environmental Atmosphere Animation
# ============================================================

func start_ambient_animation(theme: String = "default") -> void:
	"""启动环境氛围动画 - 支持四季自动主题"""
	if not fx_enabled_effective() or DisplayServer.get_name().to_lower() == "headless":
		return

	stop_ambient_animation()

	ambient_layer = Control.new()
	ambient_layer.name = "AmbientLayer"
	ambient_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ambient_layer.z_index = -1
	ambient_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(ambient_layer)

	# 四季自动主题 - 根据月份选择
	var resolved_theme: String = theme
	if theme == "default":
		var month: int = int(Time.get_datetime_dict_from_system().get("month", 1))
		match month:
			3, 4, 5:
				resolved_theme = "spring"
			6, 7, 8:
				resolved_theme = "summer"
			9, 10, 11:
				resolved_theme = "autumn"
			12, 1, 2:
				resolved_theme = "winter"
			_:
				resolved_theme = "default"

	match resolved_theme:
		"spring":
			_start_petal_fall()
		"summer":
			_start_firefly_particles()
		"autumn":
			_start_leaf_fall()
		"festival":
			_start_firework_particles()
		"winter":
			_start_snow_fall()
		_:
			_start_default_ambient()

func stop_ambient_animation() -> void:
	"""停止环境氛围动画"""
	if ambient_tween != null and is_instance_valid(ambient_tween):
		ambient_tween.kill()

	for petal in ambient_petals:
		if petal != null and is_instance_valid(petal):
			petal.queue_free()
	ambient_petals.clear()

	for cloud in ambient_clouds:
		if cloud != null and is_instance_valid(cloud):
			cloud.queue_free()
	ambient_clouds.clear()

	for particle in ambient_particles:
		if particle != null and is_instance_valid(particle):
			particle.queue_free()
	ambient_particles.clear()

	if ambient_layer != null and is_instance_valid(ambient_layer):
		ambient_layer.queue_free()
	ambient_layer = null

# 氛围粒子调色板 / Ambient Particle Color Palettes
const PETAL_COLORS := [
	Color(1.00, 0.88, 0.92),  # 樱粉
	Color(1.00, 0.78, 0.86),  # 桃红
	Color(1.00, 0.92, 0.96),  # 浅粉白
	Color(0.96, 0.70, 0.74),  # 胭脂
	Color(1.00, 0.94, 0.90),  # 暖白
]
const LEAF_COLORS := [
	Color(0.86, 0.40, 0.18),  # 赭石
	Color(0.92, 0.58, 0.22),  # 橙黄
	Color(0.74, 0.30, 0.16),  # 枫红
	Color(0.62, 0.46, 0.18),  # 暗金
	Color(0.80, 0.36, 0.40),  # 暗红
]
const FIREWORK_COLORS := [
	Color(1.00, 0.84, 0.32),  # 金黄
	Color(0.96, 0.28, 0.30),  # 朱红
	Color(0.42, 0.72, 0.96),  # 青蓝
	Color(0.58, 0.88, 0.62),  # 翠绿
	Color(0.86, 0.52, 0.96),  # 紫霞
]

func _start_petal_fall() -> void:
	"""启动花瓣飘落动画 - 多色五瓣樱花"""
	var petal_count := 16
	for i in range(petal_count):
		var petal = _create_petal()
		ambient_layer.add_child(petal)
		ambient_petals.append(petal)
		_animate_petal_fall(petal, float(i) * 0.35)

func _create_petal() -> Control:
	"""创建花瓣粒子 - 五瓣樱花造型 + 微光"""
	var petal = Control.new()
	petal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var base_color: Color = PETAL_COLORS[randi() % PETAL_COLORS.size()]
	var alpha := randf_range(0.42, 0.78)
	# 五瓣花形 - 围绕中心五个椭圆
	var flower_root = Control.new()
	flower_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flower_root.set_anchors_preset(Control.PRESET_CENTER)
	var petal_size := randf_range(7.0, 13.0)
	for p in range(5):
		var angle := float(p) * TAU / 5.0
		var shape = Panel.new()
		shape.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var p_style = StyleBoxFlat.new()
		p_style.bg_color = Color(base_color.r, base_color.g, base_color.b, alpha)
		p_style.set_corner_radius_all(50)
		shape.add_theme_stylebox_override("panel", p_style)
		shape.custom_minimum_size = Vector2(petal_size, petal_size * 1.6)
		shape.rotation = angle
		shape.position = Vector2(cos(angle) * petal_size * 0.5 - petal_size * 0.5, sin(angle) * petal_size * 0.5 - petal_size * 0.8)
		flower_root.add_child(shape)
	# 花蕊金点
	var stamen = Panel.new()
	stamen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var s_style = StyleBoxFlat.new()
	s_style.bg_color = Color(1.0, 0.90, 0.50, alpha)
	s_style.set_corner_radius_all(50)
	stamen.add_theme_stylebox_override("panel", s_style)
	stamen.custom_minimum_size = Vector2(petal_size * 0.4, petal_size * 0.4)
	stamen.position = Vector2(-petal_size * 0.2, -petal_size * 0.2)
	flower_root.add_child(stamen)
	petal.add_child(flower_root)
	flower_root.position = Vector2(-petal_size, -petal_size)
	petal.rotation = randf() * PI * 0.5
	var vp_x = get_viewport().size.x
	petal.position = Vector2(randf_range(0.0, 1.0) * vp_x, -30.0)
	return petal

func _animate_petal_fall(petal: Control, delay: float) -> void:
	"""花瓣飘落动画 - 自然飘摇 + 自旋"""
	var viewport_size = get_viewport().size
	var fall_duration = randf_range(9.0, 16.0)
	var sway_amplitude = randf_range(40.0, 110.0)
	var sway_frequency = randf_range(0.4, 1.2)
	# 垂直下落
	var tw := create_tween()
	tw.set_loops(3600)
	tw.tween_property(petal, "position:y", viewport_size.y + 40.0, fall_duration).from(-30.0).set_delay(delay)
	# 水平摇摆（正弦感）
	var sway_tw := create_tween()
	sway_tw.set_loops(3600)
	sway_tw.tween_property(petal, "position:x", petal.position.x + sway_amplitude, 1.0 / sway_frequency).set_delay(delay).set_trans(Tween.TRANS_SINE)
	sway_tw.tween_property(petal, "position:x", petal.position.x - sway_amplitude, 1.0 / sway_frequency).set_trans(Tween.TRANS_SINE)
	# 旋转
	var rot_tw := create_tween()
	rot_tw.set_loops(3600)
	rot_tw.tween_property(petal, "rotation", PI * 0.5, fall_duration * 0.5).from(0.0).set_delay(delay)
	rot_tw.tween_property(petal, "rotation", -PI * 0.5, fall_duration * 0.5).set_delay(delay)

func _start_default_ambient() -> void:
	"""启动默认氛围动画（祥云流动）"""
	var cloud_count := 5
	for i in range(cloud_count):
		var cloud = make_cloud_decoration(
			ambient_layer,
			rect_full(randf() * 0.6 - 0.3, randf() * 0.5 + 0.1, randf() * 0.3 + 0.15, randf() * 0.15 + 0.05),
			"mist",
			true
		)
		cloud.scale = Vector2(randf_range(0.6, 1.2), randf_range(0.6, 1.2))
		ambient_clouds.append(cloud)
		_animate_cloud_drift(cloud, float(i) * 1.5)

func _animate_cloud_drift(cloud: Control, delay: float) -> void:
	"""云朵漂移动画"""
	var drift_duration = randf_range(20.0, 35.0)
	var viewport_size = get_viewport().size
	cloud.position.x = -cloud.size.x
	var tw := create_tween()
	tw.set_loops(3600)
	tw.tween_property(cloud, "position:x", viewport_size.x + cloud.size.x, drift_duration).set_delay(delay)

func _start_leaf_fall() -> void:
	"""启动落叶飘落动画 - 多色枫叶"""
	var leaf_count := 14
	for i in range(leaf_count):
		var leaf = _create_leaf()
		ambient_layer.add_child(leaf)
		ambient_particles.append(leaf)
		_animate_leaf_fall(leaf, float(i) * 0.4)

func _create_leaf() -> Control:
	"""创建落叶粒子 - 多色 + 渐变质感"""
	var leaf = Control.new()
	leaf.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var base_color: Color = LEAF_COLORS[randi() % LEAF_COLORS.size()]
	var alpha := randf_range(0.5, 0.85)
	# 叶身 - 带尖角的椭圆
	var shape = Panel.new()
	shape.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style = StyleBoxFlat.new()
	style.bg_color = Color(base_color.r, base_color.g, base_color.b, alpha)
	style.set_corner_radius_all(30)
	shape.add_theme_stylebox_override("panel", style)
	var lw := randf_range(10.0, 18.0)
	var lh := randf_range(8.0, 14.0)
	shape.custom_minimum_size = Vector2(lw, lh)
	shape.rotation = randf() * PI
	leaf.add_child(shape)
	# 叶脉 - 暗色中线
	var vein = Panel.new()
	vein.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var v_style = StyleBoxFlat.new()
	v_style.bg_color = Color(base_color.r * 0.6, base_color.g * 0.6, base_color.b * 0.6, alpha * 0.7)
	v_style.set_corner_radius_all(50)
	vein.add_theme_stylebox_override("panel", v_style)
	vein.custom_minimum_size = Vector2(lw * 0.7, 1.5)
	vein.position = Vector2(lw * 0.15, lh * 0.5 - 0.75)
	vein.rotation = 0.0
	leaf.add_child(vein)
	leaf.position = Vector2(randf_range(0.0, 1.0) * get_viewport().size.x, -30.0)
	return leaf

func _animate_leaf_fall(leaf: Control, delay: float) -> void:
	"""落叶飘落动画 - 飘摇 + 翻转"""
	var viewport_size = get_viewport().size
	var fall_duration = randf_range(11.0, 19.0)
	var tw := create_tween()
	tw.set_loops(3600)
	tw.tween_property(leaf, "position:y", viewport_size.y + 40.0, fall_duration).from(-30.0).set_delay(delay).set_trans(Tween.TRANS_QUAD)
	var sway_tw := create_tween()
	sway_tw.set_loops(3600)
	var amp := randf_range(40.0, 100.0)
	sway_tw.tween_property(leaf, "position:x", leaf.position.x + amp, randf_range(1.2, 2.4)).set_delay(delay).set_trans(Tween.TRANS_SINE)
	sway_tw.tween_property(leaf, "position:x", leaf.position.x - amp, randf_range(1.2, 2.4)).set_trans(Tween.TRANS_SINE)
	# 翻转 - 落叶特有
	var flip_tw := create_tween()
	flip_tw.set_loops(3600)
	flip_tw.tween_property(leaf, "rotation", PI * 1.2, fall_duration * 0.6).from(0.0).set_delay(delay)
	flip_tw.tween_property(leaf, "rotation", 0.0, fall_duration * 0.4).from(PI * 1.2).set_delay(delay + fall_duration * 0.6)

func _start_firework_particles() -> void:
	"""启动节日烟花粒子动画 - 多色绽放 + 辉光"""
	var particle_count := 22
	var viewport_size = get_viewport().size
	for i in range(particle_count):
		var particle = Control.new()
		particle.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var base_color: Color = FIREWORK_COLORS[randi() % FIREWORK_COLORS.size()]
		var core = Panel.new()
		core.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var style = StyleBoxFlat.new()
		style.bg_color = Color(base_color.r, base_color.g, base_color.b, 0.92)
		style.set_corner_radius_all(50)
		core.add_theme_stylebox_override("panel", style)
		core.custom_minimum_size = Vector2(randf_range(3, 6), randf_range(3, 6))
		# 辉光层
		var glow = Panel.new()
		glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var gl_style = StyleBoxFlat.new()
		gl_style.bg_color = Color(base_color.r, base_color.g, base_color.b, 0.32)
		gl_style.set_corner_radius_all(50)
		glow.add_theme_stylebox_override("panel", gl_style)
		var gsize := randf_range(10, 18)
		glow.custom_minimum_size = Vector2(gsize, gsize)
		glow.position = Vector2(-(gsize - core.custom_minimum_size.x) * 0.5, -(gsize - core.custom_minimum_size.y) * 0.5)
		core.add_child(glow)
		particle.add_child(core)
		var cx: float = randf() * viewport_size.x
		var cy: float = randf_range(0.10, 0.72) * viewport_size.y
		particle.position = Vector2(cx, cy)
		ambient_layer.add_child(particle)
		ambient_particles.append(particle)
		# 闪烁 + 微扩散
		var tw := create_tween()
		tw.set_loops(3600)
		tw.tween_property(particle, "modulate:a", 1.0, randf_range(0.18, 0.42)).from(0.0).set_delay(float(i) * 0.12)
		tw.parallel().tween_property(particle, "scale", Vector2(1.4, 1.4), randf_range(0.4, 0.9)).from(Vector2(0.6, 0.6)).set_delay(float(i) * 0.12).set_ease(Tween.EASE_OUT)
		tw.tween_property(particle, "modulate:a", 0.0, randf_range(0.6, 1.4)).from(1.0)
		tw.tween_property(particle, "scale", Vector2(0.8, 0.8), randf_range(0.6, 1.2))
		# 漂浮回落
		var fall_tw := create_tween()
		fall_tw.set_loops(3600)
		fall_tw.tween_property(particle, "position:y", cy + randf_range(20.0, 50.0), randf_range(2.0, 3.5)).set_delay(float(i) * 0.12)
		fall_tw.tween_property(particle, "position:y", cy, randf_range(2.0, 3.5))

func _start_firefly_particles() -> void:
	"""启动夏日萤火虫粒子动画 - 漂移+呼吸闪烁+辉光"""
	var particle_count := 22
	var viewport_size = get_viewport().size
	for i in range(particle_count):
		var particle = Control.new()
		particle.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var core = Panel.new()
		core.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var style = StyleBoxFlat.new()
		style.bg_color = Color(randf_range(0.72, 0.95), randf_range(0.88, 1.0), randf_range(0.32, 0.52), 0.0)
		style.set_corner_radius_all(50)
		core.add_theme_stylebox_override("panel", style)
		var csize := randf_range(3, 6)
		core.custom_minimum_size = Vector2(csize, csize)
		# 萤火虫辉光 - 双层
		var glow = Panel.new()
		glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var gl_style = StyleBoxFlat.new()
		gl_style.bg_color = Color(0.85, 0.95, 0.45, 0.0)
		gl_style.set_corner_radius_all(50)
		glow.add_theme_stylebox_override("panel", gl_style)
		glow.custom_minimum_size = Vector2(14, 14)
		glow.position = Vector2(-4, -4)
		core.add_child(glow)
		var glow2 = Panel.new()
		glow2.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var gl2_style = StyleBoxFlat.new()
		gl2_style.bg_color = Color(1.0, 1.0, 0.62, 0.0)
		gl2_style.set_corner_radius_all(50)
		glow2.add_theme_stylebox_override("panel", gl2_style)
		glow2.custom_minimum_size = Vector2(26, 26)
		glow2.position = Vector2(-10, -10)
		core.add_child(glow2)
		particle.add_child(core)
		var px: float = randf() * viewport_size.x
		var py: float = randf_range(0.15, 0.85) * viewport_size.y
		particle.position = Vector2(px, py)
		ambient_layer.add_child(particle)
		ambient_particles.append(particle)
		# 呼吸闪烁 - core与glow同步
		var tw := create_tween()
		tw.set_loops(3600)
		tw.tween_property(core, "modulate:a", 1.0, randf_range(0.9, 2.0)).from(0.0).set_ease(Tween.EASE_IN_OUT)
		tw.tween_property(core, "modulate:a", 0.0, randf_range(0.9, 2.0)).from(1.0).set_ease(Tween.EASE_IN_OUT)
		var glow_tw := create_tween()
		glow_tw.set_loops(3600)
		glow_tw.tween_property(glow, "modulate:a", 0.8, randf_range(0.9, 2.0)).from(0.0)
		glow_tw.tween_property(glow, "modulate:a", 0.0, randf_range(0.9, 2.0)).from(0.8)
		# 漂移 - 8字形漫游
		var drift_tw := create_tween()
		drift_tw.set_loops(3600)
		drift_tw.tween_property(particle, "position:x", px + randf_range(25.0, 65.0), randf_range(2.5, 4.5)).set_trans(Tween.TRANS_SINE)
		drift_tw.parallel().tween_property(particle, "position:y", py + randf_range(-30.0, 30.0), randf_range(2.5, 4.5)).set_trans(Tween.TRANS_SINE)
		drift_tw.tween_property(particle, "position:x", px, randf_range(2.5, 4.5)).set_trans(Tween.TRANS_SINE)
		drift_tw.parallel().tween_property(particle, "position:y", py, randf_range(2.5, 4.5)).set_trans(Tween.TRANS_SINE)

func _start_snow_fall() -> void:
	"""启动冬日雪花飘落动画 - 六角晶体感 + 辉光"""
	var flake_count := 30
	var viewport_size = get_viewport().size
	for i in range(flake_count):
		var flake = Control.new()
		flake.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var fsize := randf_range(3.0, 8.0)
		# 雪花核心
		var core = Panel.new()
		core.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.97, 0.99, 1.0, randf_range(0.5, 0.92))
		style.set_corner_radius_all(50)
		core.add_theme_stylebox_override("panel", style)
		core.custom_minimum_size = Vector2(fsize, fsize)
		flake.add_child(core)
		# 柔光层 - 冰晶泛蓝白
		var halo = Panel.new()
		halo.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var h_style = StyleBoxFlat.new()
		h_style.bg_color = Color(0.80, 0.92, 1.0, randf_range(0.10, 0.22))
		h_style.set_corner_radius_all(50)
		halo.add_theme_stylebox_override("panel", h_style)
		var hsize := fsize * 2.6
		halo.custom_minimum_size = Vector2(hsize, hsize)
		halo.position = Vector2(-(hsize - fsize) * 0.5, -(hsize - fsize) * 0.5)
		core.add_child(halo)
		var px: float = randf() * viewport_size.x
		var py: float = randf_range(-1.0, 1.0) * viewport_size.y
		flake.position = Vector2(px, py)
		ambient_layer.add_child(flake)
		ambient_particles.append(flake)
		# 下落
		var fall_tw := create_tween()
		fall_tw.set_loops(3600)
		var fall_dur = randf_range(9.0, 17.0)
		fall_tw.tween_property(flake, "position:y", viewport_size.y + 30.0, fall_dur).from(py - viewport_size.y).set_delay(float(i) * 0.25).set_trans(Tween.TRANS_LINEAR)
		# 随风飘 + 自旋
		var sway_tw := create_tween()
		sway_tw.set_loops(3600)
		var amp := randf_range(30.0, 80.0)
		sway_tw.tween_property(flake, "position:x", px + amp, randf_range(1.5, 3.5)).set_delay(float(i) * 0.25).set_trans(Tween.TRANS_SINE)
		sway_tw.tween_property(flake, "position:x", px - amp, randf_range(1.5, 3.5)).set_trans(Tween.TRANS_SINE)
		var rot_tw := create_tween()
		rot_tw.set_loops(3600)
		rot_tw.tween_property(flake, "rotation", PI, randf_range(3.0, 6.0)).from(0.0).set_delay(float(i) * 0.25)
