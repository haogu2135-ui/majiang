# ============================================================
# 云桌麻将 UI/动画/插画增强模块 / UI Animation Illustration Enhancements
# ============================================================
# 本模块提供了一套用于增强游戏UI视觉表现和动画效果的工具函数。
# 旨在通过更细腻的粒子效果、动态插画和流畅的交互动画，
# 提升玩家的沉浸感和操作反馈。
#
# 主要功能包括：
# - 增强的胜利特效粒子系统
# - 动态插画元素（星光、波纹、粒子轨迹）
# - 手牌交互反馈增强（悬停、选中、高光）
# - 国风装饰的动态化
# ============================================================

extends Control

class_name UIEnhancements

# ============================================================
# 粒子特效增强 / Particle Effect Enhancements
# ============================================================

# 存储当前的粒子动画，用于管理和清理
var active_particles: Array[Tween] = []
var particle_nodes: Array[Control] = []

# 粒子颜色调色板 - 国风主题
const PARTICLE_PALETTES := {
	"gold": [
		Color(0.98, 0.88, 0.42, 0.92),
		Color(0.96, 0.82, 0.28, 0.88),
		Color(1.0, 0.92, 0.58, 0.76),
		Color(0.88, 0.72, 0.24, 0.84),
	],
	"jade": [
		Color(0.42, 0.72, 0.62, 0.88),
		Color(0.32, 0.62, 0.52, 0.84),
		Color(0.52, 0.82, 0.72, 0.76),
		Color(0.28, 0.56, 0.48, 0.82),
	],
	"cinnabar": [
		Color(0.92, 0.28, 0.18, 0.88),
		Color(0.82, 0.18, 0.12, 0.84),
		Color(0.96, 0.42, 0.32, 0.76),
		Color(0.72, 0.22, 0.24, 0.82),
	],
	"azure": [
		Color(0.42, 0.64, 0.88, 0.88),
		Color(0.32, 0.54, 0.78, 0.84),
		Color(0.52, 0.74, 0.92, 0.76),
		Color(0.22, 0.48, 0.72, 0.82),
	],
}

# 创建一个增强的粒子爆发效果
# parent: 父节点, center: 中心位置, color_theme: 颜色主题, count: 粒子数量, radius: 扩散半径
func create_enhanced_particle_burst(parent: Control, center: Vector2, color_theme: String, count: int, radius: float) -> void:
	var palette = PARTICLE_PALETTES.get(color_theme, PARTICLE_PALETTES["gold"])

	radius = abs(radius) # Ensure radius is positive

	for i in range(count):
		var particle = Control.new()
		particle.name = "EnhancedParticle_%d" % i
		particle.mouse_filter = Control.MOUSE_FILTER_IGNORE
		particle.position = center
		parent.add_child(particle)
		particle_nodes.append(particle)

		# 粒子核心
		var core = Panel.new()
		core.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var core_size = randf_range(4.0, 10.0)
		core.custom_minimum_size = Vector2(core_size, core_size)

		var particle_style = StyleBoxFlat.new()
		var base_color = palette[randi() % palette.size()]
		particle_style.bg_color = Color(base_color.r, base_color.g, base_color.b, randf_range(0.7, 0.95))
		particle_style.set_corner_radius_all(int(core_size * 0.5))
		core.add_theme_stylebox_override("panel", particle_style)

		particle.add_child(core)

		# 计算扩散目标位置
		var angle = randf() * TAU
		var distance = randf_range(radius * 0.3, radius)
		var target_pos = center + Vector2(cos(angle), sin(angle)) * distance

		# 创建Tween动画
		var tw = create_tween()
		tw.set_parallel(true)

		# 移动动画
		var duration = randf_range(0.6, 1.2)
		tw.tween_property(particle, "position", target_pos, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

		# 透明度渐变
		tw.tween_property(particle, "modulate:a", 0.0, duration).from(1.0)

		# 缩放动画
		tw.tween_property(core, "scale", Vector2(0.2, 0.2), duration * 0.8).from(Vector2.ONE)

		# 旋转动画
		tw.tween_property(core, "rotation", randf_range(-PI, PI), duration)

		# 动画结束后清理
		tw.chain().tween_callback(func():
			if is_instance_valid(particle):
				particle.queue_free()
		)
		active_particles.append(tw)

# ============================================================
# 动态星光效果 / Dynamic Starlight Effect
# ============================================================

# 创建增强的中心星光效果，带有闪烁和旋转动画
# parent: 父节点, rect: 区域, star_count: 星星数量
func create_enhanced_starlight(parent: Control, rect: Rect2, star_count: int = 12) -> Control:
	var star_container = Control.new()
	star_container.name = "EnhancedStarlight"
	star_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	star_container.position = rect.position
	star_container.size = rect.size
	parent.add_child(star_container)

	var center = rect.size * 0.5

	for i in range(star_count):
		var star = Panel.new()
		star.name = "Star_%d" % i
		star.mouse_filter = Control.MOUSE_FILTER_IGNORE

		var star_size = randf_range(3.0, 7.0)
		star.custom_minimum_size = Vector2(star_size, star_size)

		var star_style = StyleBoxFlat.new()
		var hue = randf()
		star_style.bg_color = Color.from_hsv(hue, 0.3, 1.0, randf_range(0.6, 0.9))
		star_style.set_corner_radius_all(50)
		star.add_theme_stylebox_override("panel", star_style)

		# 随机分布在区域内
		var angle = randf() * TAU
		var radius = randf_range(0.1, 0.45) * min(rect.size.x, rect.size.y)
		var pos = center + Vector2(cos(angle), sin(angle)) * radius

		star.position = pos - Vector2(star_size * 0.5, star_size * 0.5)
		star_container.add_child(star)

		# 闪烁动画
		var tw = create_tween()
		tw.set_loops(3600)
		var blink_duration = randf_range(1.0, 3.0)
		tw.tween_property(star, "modulate:a", 0.2, blink_duration * 0.5).set_ease(Tween.EASE_IN_OUT)
		tw.tween_property(star, "modulate:a", 1.0, blink_duration * 0.5).set_ease(Tween.EASE_IN_OUT)
		active_particles.append(tw)

	return star_container

# ============================================================
# 手牌交互反馈 / Hand Tile Interaction Feedback
# ============================================================

# 为手牌添加悬停高亮效果
func apply_hand_tile_hover_effect(tile_control: Control, is_hovered: bool) -> void:
	if is_hovered:
		# 悬停时的微放大和高亮
		var tw = create_tween()
		tw.set_parallel(true)
		tw.tween_property(tile_control, "scale", Vector2(1.08, 1.08), 0.15).set_ease(Tween.EASE_OUT)
		tw.tween_property(tile_control, "modulate", Color(1.1, 1.1, 1.1, 1.0), 0.15)
		active_particles.append(tw)
	else:
		# 恢复原始状态
		var tw = create_tween()
		tw.set_parallel(true)
		tw.tween_property(tile_control, "scale", Vector2.ONE, 0.15).set_ease(Tween.EASE_OUT)
		tw.tween_property(tile_control, "modulate", Color.WHITE, 0.15)
		active_particles.append(tw)

# 为选中的手牌添加弹跳动画
func apply_hand_tile_select_bounce(tile_control: Control) -> void:
	var tw = create_tween()
	tw.set_trans(Tween.TRANS_BACK)
	tw.set_ease(Tween.EASE_OUT)
	tw.tween_property(tile_control, "position:y", tile_control.position.y - 10.0, 0.2)
	tw.tween_property(tile_control, "position:y", tile_control.position.y, 0.15)
	active_particles.append(tw)

# ============================================================
# 国风装饰动态效果 / Guofeng Decoration Dynamic Effects
# ============================================================

# 创建飘动的祥云效果
func create_floating_cloud(parent: Control, rect: Rect2, speed: float = 20.0) -> Control:
	var cloud = Control.new()
	cloud.name = "FloatingCloud"
	cloud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cloud.position = rect.position
	cloud.size = rect.size
	parent.add_child(cloud)

	# 创建云朵组件
	var puffs = [
		{"pos": Vector2(0.2, 0.5), "size": Vector2(0.3, 0.4)},
		{"pos": Vector2(0.4, 0.4), "size": Vector2(0.35, 0.5)},
		{"pos": Vector2(0.6, 0.45), "size": Vector2(0.3, 0.45)},
		{"pos": Vector2(0.8, 0.55), "size": Vector2(0.25, 0.35)},
	]

	for puff in puffs:
		var puff_panel = Panel.new()
		puff_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var puff_size = Vector2(rect.size.x * puff.size.x, rect.size.y * puff.size.y)
		puff_panel.custom_minimum_size = puff_size

		var puff_style = StyleBoxFlat.new()
		puff_style.bg_color = Color(1.0, 1.0, 1.0, randf_range(0.1, 0.25))
		puff_style.set_corner_radius_all(50)
		puff_panel.add_theme_stylebox_override("panel", puff_style)

		puff_panel.position = Vector2(rect.size.x * puff.pos.x - puff_size.x * 0.5, rect.size.y * puff.pos.y - puff_size.y * 0.5)
		cloud.add_child(puff_panel)

	# 水平飘动动画
	var tw = create_tween()
	tw.set_loops(3600)
	var duration = rect.size.x / speed
	tw.tween_property(cloud, "position:x", rect.position.x + rect.size.x, duration).from(rect.position.x - rect.size.x)
	active_particles.append(tw)

	return cloud

# 创建竹子的微风摆动效果
func create_bamboo_sway(parent: Control, rect: Rect2, segments: int = 5) -> Control:
	var bamboo = Control.new()
	bamboo.name = "SwayingBamboo"
	bamboo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bamboo.position = rect.position
	bamboo.size = rect.size
	parent.add_child(bamboo)

	var segment_height = rect.size.y / segments

	for i in range(segments):
		var segment = Panel.new()
		segment.mouse_filter = Control.MOUSE_FILTER_IGNORE
		segment.custom_minimum_size = Vector2(rect.size.x * 0.6, segment_height * 0.8)

		var seg_style = StyleBoxFlat.new()
		seg_style.bg_color = Color(0.12 + float(i) * 0.02, 0.32 + float(i) * 0.02, 0.28, 0.8)
		seg_style.set_corner_radius_all(4)
		segment.add_theme_stylebox_override("panel", seg_style)

		segment.position = Vector2(rect.size.x * 0.2, i * segment_height)
		bamboo.add_child(segment)

		# 竹节环
		if i < segments - 1:
			var ring = Panel.new()
			ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
			ring.custom_minimum_size = Vector2(rect.size.x * 0.7, segment_height * 0.15)

			var ring_style = StyleBoxFlat.new()
			ring_style.bg_color = Color(0.10, 0.28, 0.24, 0.9)
			ring_style.set_corner_radius_all(2)
			ring.add_theme_stylebox_override("panel", ring_style)

			ring.position = Vector2(rect.size.x * 0.15, (i + 1) * segment_height - segment_height * 0.075)
			bamboo.add_child(ring)

	# 摇摆动画
	var tw = create_tween()
	tw.set_loops(3600)
	tw.set_trans(Tween.TRANS_SINE)
	tw.set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(bamboo, "rotation", 0.05, 2.0).from(-0.05)
	tw.tween_property(bamboo, "rotation", -0.05, 2.0).from(0.05)
	active_particles.append(tw)

	return bamboo

# 创建梅花的飘落效果
func create_falling_plum_blossoms(parent: Control, rect: Rect2, count: int = 8) -> void:
	for i in range(count):
		var blossom = Control.new()
		blossom.name = "FallingBlossom_%d" % i
		blossom.mouse_filter = Control.MOUSE_FILTER_IGNORE
		blossom.position = Vector2(randf_range(rect.position.x, rect.position.x + rect.size.x), rect.position.y - randf_range(0, 50))
		parent.add_child(blossom)
		particle_nodes.append(blossom)

		# 五瓣花
		var petal_color = Color(0.96, 0.70, 0.74, randf_range(0.7, 0.9))
		var petal_size = randf_range(4.0, 7.0)
		for p in range(5):
			var petal = Panel.new()
			petal.mouse_filter = Control.MOUSE_FILTER_IGNORE
			petal.custom_minimum_size = Vector2(petal_size, petal_size * 1.5)

			var petal_style = StyleBoxFlat.new()
			petal_style.bg_color = petal_color
			petal_style.set_corner_radius_all(50)
			petal.add_theme_stylebox_override("panel", petal_style)

			var angle = float(p) * TAU / 5.0
			petal.position = Vector2(cos(angle) * petal_size * 0.5, sin(angle) * petal_size * 0.5)
			petal.rotation = angle
			blossom.add_child(petal)

		# 花蕊
		var stamen = Panel.new()
		stamen.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var stamen_size = petal_size * 0.4
		stamen.custom_minimum_size = Vector2(stamen_size, stamen_size)
		var stamen_style = StyleBoxFlat.new()
		stamen_style.bg_color = Color(1.0, 0.9, 0.5, petal_color.a)
		stamen_style.set_corner_radius_all(50)
		stamen.add_theme_stylebox_override("panel", stamen_style)
		blossom.add_child(stamen)

		# 飘落动画
		var tw = create_tween()
		tw.set_loops(3600)
		var fall_duration = randf_range(8.0, 15.0)
		var sway_amplitude = randf_range(30.0, 80.0)

		# 垂直下落
		tw.tween_property(blossom, "position:y", rect.position.y + rect.size.y + 30.0, fall_duration).from(blossom.position.y)

		# 水平摇摆
		var sway_tw = create_tween()
		sway_tw.set_loops(3600)
		sway_tw.set_trans(Tween.TRANS_SINE)
		sway_tw.tween_property(blossom, "position:x", blossom.position.x + sway_amplitude, 1.5).set_ease(Tween.EASE_IN_OUT)
		sway_tw.tween_property(blossom, "position:x", blossom.position.x - sway_amplitude, 1.5).set_ease(Tween.EASE_IN_OUT)
		active_particles.append(tw)
		active_particles.append(sway_tw)

# ============================================================
# 清理与管理 / Cleanup and Management
# ============================================================

# 清理所有活动的粒子动画
func clear_all_effects() -> void:
	for tween in active_particles:
		if is_instance_valid(tween):
			tween.kill()
	active_particles.clear()

	for node in particle_nodes:
		if is_instance_valid(node):
			node.queue_free()
	particle_nodes.clear()

# 获取活跃的粒子动画数量（用于调试）
func get_active_effect_count() -> int:
	return active_particles.size()


# ============================================================
# 新增装饰效果 / New Decorative Effects
# ============================================================

# 创建漂浮的萤火精灵效果
func create_floating_spirit(parent: Control, rect: Rect2, count: int = 6) -> void:
	for i in range(count):
		var spirit = Panel.new()
		spirit.name = "SpiritGlow_%d" % i
		spirit.mouse_filter = Control.MOUSE_FILTER_IGNORE

		var spirit_size = randf_range(4.0, 8.0)
		spirit.custom_minimum_size = Vector2(spirit_size, spirit_size)

		var s_style = StyleBoxFlat.new()
		var hue = randf_range(0.08, 0.18)
		s_style.bg_color = Color.from_hsv(hue, 0.5, 0.95, randf_range(0.3, 0.6))
		s_style.set_corner_radius_all(50)
		spirit.add_theme_stylebox_override("panel", s_style)

		var start_x = randf_range(rect.position.x, rect.position.x + rect.size.x)
		var start_y = randf_range(rect.position.y, rect.position.y + rect.size.y)
		spirit.position = Vector2(start_x, start_y)
		parent.add_child(spirit)
		particle_nodes.append(spirit)

		# 外层辉光
		var glow = Panel.new()
		glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var glow_size = spirit_size * 2.5
		glow.custom_minimum_size = Vector2(glow_size, glow_size)
		var g_style = StyleBoxFlat.new()
		g_style.bg_color = Color.from_hsv(hue, 0.3, 1.0, 0.12)
		g_style.set_corner_radius_all(50)
		glow.add_theme_stylebox_override("panel", g_style)
		glow.position = Vector2(-(glow_size - spirit_size) * 0.5, -(glow_size - spirit_size) * 0.5)
		spirit.add_child(glow)

		# 缓慢上升 + 左右漂移 + 呼吸
		var tw = create_tween()
		tw.set_loops(3600)
		var rise_h = randf_range(60.0, 150.0)
		var rise_dur = randf_range(10.0, 18.0)
		var drift = randf_range(30.0, 80.0)

		tw.tween_property(spirit, "position:y", spirit.position.y - rise_h, rise_dur)
		tw.parallel().tween_property(spirit, "modulate:a", 0.0, rise_dur).from(randf_range(0.3, 0.7))

		var drift_tw = create_tween()
		drift_tw.set_loops(3600)
		drift_tw.set_trans(Tween.TRANS_SINE)
		drift_tw.tween_property(spirit, "position:x", spirit.position.x + drift, randf_range(3.0, 6.0))
		drift_tw.tween_property(spirit, "position:x", spirit.position.x - drift, randf_range(3.0, 6.0))

		var breath_tw = create_tween()
		breath_tw.set_loops(3600)
		breath_tw.set_trans(Tween.TRANS_SINE)
		breath_tw.tween_property(spirit, "scale", Vector2(1.4, 1.4), randf_range(1.5, 3.0))
		breath_tw.tween_property(spirit, "scale", Vector2.ONE, randf_range(1.5, 3.0))

		active_particles.append(tw)
		active_particles.append(drift_tw)
		active_particles.append(breath_tw)

# 创建涟漪扩散环 (用于胜利/重要事件)
func create_ripple_ring(parent: Control, center: Vector2, color: Color = Color(1.0, 0.9, 0.5, 0.8), ring_count: int = 3) -> void:
	for i in range(ring_count):
		var ring = Panel.new()
		ring.name = "RippleRing_%d" % i
		ring.mouse_filter = Control.MOUSE_FILTER_IGNORE

		var ring_style = StyleBoxFlat.new()
		ring_style.bg_color = Color(color.r, color.g, color.b, 0.0)
		ring_style.border_color = Color(color.r, color.g, color.b, color.a)
		ring_style.set_border_width_all(2)
		ring_style.set_corner_radius_all(50)
		ring.add_theme_stylebox_override("panel", ring_style)

		var initial_size = 8.0
		ring.custom_minimum_size = Vector2(initial_size, initial_size)
		ring.position = center - Vector2(initial_size * 0.5, initial_size * 0.5)
		ring.set_anchors_preset(Control.PRESET_TOP_LEFT)
		parent.add_child(ring)
		particle_nodes.append(ring)

		var tw = create_tween()
		var delay = float(i) * 0.15
		var expand_to = 120.0 + float(i) * 20.0

		tw.tween_property(ring, "custom_minimum_size", Vector2(expand_to, expand_to), 0.8).set_delay(delay).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(ring, "position", center - Vector2(expand_to * 0.5, expand_to * 0.5), 0.8).set_delay(delay).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

		var ring_mat = ring.get_theme_stylebox("panel")
		if ring_mat is StyleBoxFlat:
			tw.parallel().tween_method(func(a: float): ring_style.border_color.a = a, color.a, 0.0, 0.8).set_delay(delay)

		tw.tween_callback(func():
			if is_instance_valid(ring):
				ring.queue_free()
		).set_delay(0.8 + delay)
		active_particles.append(tw)

# 创建飘动的金箔光点 (用于高级UI区域)
func create_gold_dust(parent: Control, rect: Rect2, count: int = 8) -> void:
	for i in range(count):
		var dust = Panel.new()
		dust.name = "GoldDust_%d" % i
		dust.mouse_filter = Control.MOUSE_FILTER_IGNORE

		var d_size = randf_range(2.0, 5.0)
		dust.custom_minimum_size = Vector2(d_size, d_size)

		var d_style = StyleBoxFlat.new()
		d_style.bg_color = Color(0.96, 0.86, 0.46, randf_range(0.2, 0.5))
		d_style.set_corner_radius_all(50)
		dust.add_theme_stylebox_override("panel", d_style)

		dust.position = Vector2(
			randf_range(rect.position.x, rect.position.x + rect.size.x),
			randf_range(rect.position.y, rect.position.y + rect.size.y)
		)
		parent.add_child(dust)
		particle_nodes.append(dust)

		# 缓慢漂移
		var tw = create_tween()
		tw.set_loops(3600)
		var drift_x = randf_range(-40.0, 40.0)
		var drift_y = randf_range(-20.0, 20.0)
		var dur = randf_range(4.0, 8.0)

		tw.tween_property(dust, "position:x", dust.position.x + drift_x, dur).set_trans(Tween.TRANS_SINE)
		tw.parallel().tween_property(dust, "position:y", dust.position.y + drift_y, dur).set_trans(Tween.TRANS_SINE)
		tw.tween_property(dust, "position:x", dust.position.x, dur).set_trans(Tween.TRANS_SINE)
		tw.parallel().tween_property(dust, "position:y", dust.position.y, dur).set_trans(Tween.TRANS_SINE)

		# 闪烁
		var flicker_tw = create_tween()
		flicker_tw.set_loops(3600)
		flicker_tw.set_trans(Tween.TRANS_SINE)
		flicker_tw.tween_property(dust, "modulate:a", 0.1, randf_range(1.0, 2.5))
		flicker_tw.tween_property(dust, "modulate:a", 1.0, randf_range(1.0, 2.5))

		active_particles.append(tw)
		active_particles.append(flicker_tw)
