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

# GPT spark host — never StyleBoxFlat program paint for VFX chrome.
var _spark_tex_cache: Texture2D
var _spark_tex_ready := false

func _spark_texture() -> Texture2D:
	if _spark_tex_ready:
		return _spark_tex_cache
	_spark_tex_ready = true
	for path in [
		"res://assets/illustrations/ui_soft_flash.png",
		"res://assets/illustrations/center_active_bloom.png",
		"res://assets/illustrations/petals_spring.png",
	]:
		if ResourceLoader.exists(path):
			var tex = load(path)
			if tex is Texture2D:
				_spark_tex_cache = tex
				break
	return _spark_tex_cache

func _make_gpt_spark(spark_size: float, color: Color) -> Control:
	var tex = _spark_texture()
	if tex != null:
		var tr = TextureRect.new()
		tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tr.texture = tex
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_SCALE
		tr.custom_minimum_size = Vector2(spark_size, spark_size)
		tr.size = Vector2(spark_size, spark_size)
		tr.modulate = color
		return tr
	# Invisible host fallback — never program ColorRect/StyleBox paint.
	var host = Control.new()
	host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	host.custom_minimum_size = Vector2(spark_size, spark_size)
	host.size = Vector2(spark_size, spark_size)
	host.modulate = Color(1, 1, 1, 0)
	return host


func _exit_tree() -> void:
	clear_all_effects()

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

		# 粒子核心 — GPT spark
		var core_size = randf_range(4.0, 10.0)
		var base_color = palette[randi() % palette.size()]
		var core = _make_gpt_spark(core_size, Color(base_color.r, base_color.g, base_color.b, randf_range(0.7, 0.95)))
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

		# 动画结束后清理。Tween 回调只保存实例 ID，避免场景切换后捕获已释放节点。
		var particle_id := particle.get_instance_id()
		tw.chain().tween_callback(func():
			var particle_node := instance_from_id(particle_id) as Control
			if particle_node != null:
				particle_node.queue_free()
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
		var star_size = randf_range(3.0, 7.0)
		var hue = randf()
		var col = Color.from_hsv(hue, 0.3, 1.0, randf_range(0.6, 0.9))
		var star = _make_gpt_spark(star_size, col)
		star.name = "Star_%d" % i
		var angle = randf() * TAU
		var radius = randf_range(0.0, min(rect.size.x, rect.size.y) * 0.45)
		star.position = center + Vector2(cos(angle), sin(angle)) * radius - Vector2(star_size * 0.5, star_size * 0.5)
		star_container.add_child(star)
		particle_nodes.append(star)
		var tw = create_tween()
		tw.set_loops()
		var duration = randf_range(0.8, 1.8)
		tw.tween_property(star, "modulate:a", 0.15, duration).set_trans(Tween.TRANS_SINE)
		tw.tween_property(star, "modulate:a", col.a, duration).set_trans(Tween.TRANS_SINE)
		active_particles.append(tw)
	return star_container

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

# 创建飘动的祥云效果 — GPT soft flash puffs
func create_floating_cloud(parent: Control, rect: Rect2, speed: float = 20.0) -> Control:
	var cloud = Control.new()
	cloud.name = "FloatingCloud"
	cloud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cloud.position = rect.position
	cloud.size = rect.size
	parent.add_child(cloud)

	var puffs = [
		{"pos": Vector2(0.2, 0.5), "size": Vector2(0.3, 0.4)},
		{"pos": Vector2(0.4, 0.4), "size": Vector2(0.35, 0.5)},
		{"pos": Vector2(0.6, 0.45), "size": Vector2(0.3, 0.45)},
		{"pos": Vector2(0.8, 0.55), "size": Vector2(0.25, 0.35)},
	]

	for puff in puffs:
		var puff_size = Vector2(rect.size.x * puff.size.x, rect.size.y * puff.size.y)
		var spark = _make_gpt_spark(max(puff_size.x, puff_size.y), Color(1.0, 1.0, 1.0, randf_range(0.18, 0.34)))
		spark.custom_minimum_size = puff_size
		spark.size = puff_size
		spark.position = Vector2(rect.size.x * puff.pos.x - puff_size.x * 0.5, rect.size.y * puff.pos.y - puff_size.y * 0.5)
		cloud.add_child(spark)

	var tw = create_tween()
	tw.set_loops(48)
	var duration = rect.size.x / max(1.0, speed)
	tw.tween_property(cloud, "position:x", rect.position.x + rect.size.x, duration).from(rect.position.x - rect.size.x)
	active_particles.append(tw)
	return cloud

# 竹子微风：仅用 GPT 纹理条，不再 StyleBox 程序绿
func create_bamboo_sway(parent: Control, rect: Rect2, segments: int = 5) -> Control:
	var bamboo = Control.new()
	bamboo.name = "SwayingBamboo"
	bamboo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bamboo.position = rect.position
	bamboo.size = rect.size
	parent.add_child(bamboo)

	var segment_height = rect.size.y / max(1, segments)
	for i in range(segments):
		var seg_h = segment_height * 0.8
		var seg_w = rect.size.x * 0.6
		var segment = _make_gpt_spark(max(seg_w, seg_h), Color(0.42, 0.62, 0.48, 0.22 + float(i) * 0.02))
		segment.custom_minimum_size = Vector2(seg_w, seg_h)
		segment.size = Vector2(seg_w, seg_h)
		segment.position = Vector2(rect.size.x * 0.2, i * segment_height)
		bamboo.add_child(segment)
		if i < segments - 1:
			var ring_h = segment_height * 0.15
			var ring_w = rect.size.x * 0.7
			var ring = _make_gpt_spark(max(ring_w, ring_h), Color(0.55, 0.72, 0.48, 0.18))
			ring.custom_minimum_size = Vector2(ring_w, ring_h)
			ring.size = Vector2(ring_w, ring_h)
			ring.position = Vector2(rect.size.x * 0.15, (i + 1) * segment_height - segment_height * 0.075)
			bamboo.add_child(ring)

	var tw = create_tween()
	tw.set_loops(48)
	tw.set_trans(Tween.TRANS_SINE)
	tw.set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(bamboo, "rotation", 0.05, 2.0).from(-0.05)
	tw.tween_property(bamboo, "rotation", -0.05, 2.0).from(0.05)
	active_particles.append(tw)
	return bamboo

# 梅花飘落 — petals 纹理
func create_falling_plum_blossoms(parent: Control, rect: Rect2, count: int = 8) -> void:
	for i in range(count):
		var blossom = Control.new()
		blossom.name = "FallingBlossom_%d" % i
		blossom.mouse_filter = Control.MOUSE_FILTER_IGNORE
		blossom.position = Vector2(randf_range(rect.position.x, rect.position.x + rect.size.x), rect.position.y - randf_range(0, 50))
		parent.add_child(blossom)
		particle_nodes.append(blossom)

		var petal_color = Color(0.96, 0.70, 0.74, randf_range(0.7, 0.9))
		var petal_size = randf_range(8.0, 14.0)
		var petal = _make_gpt_spark(petal_size, petal_color)
		# prefer seasonal petal asset when available
		if ResourceLoader.exists("res://assets/illustrations/petals_spring.png"):
			var ptex = load("res://assets/illustrations/petals_spring.png") as Texture2D
			if ptex != null and petal is TextureRect:
				(petal as TextureRect).texture = ptex
		blossom.add_child(petal)

		var tw = create_tween()
		tw.set_loops(48)
		var fall_x = blossom.position.x + randf_range(-40.0, 40.0)
		var fall_y = rect.position.y + rect.size.y + 40.0
		var dur = randf_range(4.5, 8.0)
		tw.tween_property(blossom, "position", Vector2(fall_x, fall_y), dur).set_trans(Tween.TRANS_SINE)
		tw.parallel().tween_property(blossom, "rotation", randf_range(-1.2, 1.2), dur)
		tw.tween_callback(func() -> void:
			blossom.position = Vector2(randf_range(rect.position.x, rect.position.x + rect.size.x), rect.position.y - 20.0)
			blossom.rotation = 0.0
		)
		active_particles.append(tw)

func clear_all_effects() -> void:
	for tw in active_particles:
		if tw != null and is_instance_valid(tw):
			tw.kill()
	active_particles.clear()
	for node in particle_nodes:
		if node != null and is_instance_valid(node):
			node.queue_free()
	particle_nodes.clear()

func get_active_effect_count() -> int:
	return active_particles.size()

func create_floating_spirit(parent: Control, rect: Rect2, count: int = 6) -> void:
	for i in range(count):
		var spirit_size = randf_range(4.0, 8.0)
		var hue = randf_range(0.08, 0.18)
		var spirit = _make_gpt_spark(spirit_size, Color.from_hsv(hue, 0.5, 0.95, randf_range(0.3, 0.6)))
		spirit.name = "SpiritGlow_%d" % i
		spirit.position = Vector2(
			randf_range(rect.position.x, rect.position.x + rect.size.x),
			randf_range(rect.position.y, rect.position.y + rect.size.y)
		)
		parent.add_child(spirit)
		particle_nodes.append(spirit)

		var glow = _make_gpt_spark(spirit_size * 2.2, Color.from_hsv(hue, 0.3, 1.0, 0.18))
		glow.position = Vector2(-spirit_size * 0.6, -spirit_size * 0.6)
		spirit.add_child(glow)

		var tw = create_tween()
		tw.set_loops(48)
		var drift = Vector2(randf_range(-30.0, 30.0), randf_range(-40.0, -10.0))
		var dur = randf_range(3.0, 6.0)
		tw.tween_property(spirit, "position", spirit.position + drift, dur).set_trans(Tween.TRANS_SINE)
		tw.tween_property(spirit, "position", spirit.position, dur).set_trans(Tween.TRANS_SINE)
		active_particles.append(tw)

func create_ripple_ring(parent: Control, center: Vector2, color: Color = Color(1.0, 0.9, 0.5, 0.8), ring_count: int = 3) -> void:
	for i in range(ring_count):
		var base = 12.0 + float(i) * 10.0
		var ring = _make_gpt_spark(base, Color(color.r, color.g, color.b, 0.55))
		ring.name = "RippleRing_%d" % i
		ring.position = center - Vector2(base * 0.5, base * 0.5)
		parent.add_child(ring)
		particle_nodes.append(ring)
		var tw = create_tween()
		tw.set_parallel(true)
		var target = base * 3.5
		tw.tween_property(ring, "size", Vector2(target, target), 0.7 + float(i) * 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(ring, "custom_minimum_size", Vector2(target, target), 0.7 + float(i) * 0.12)
		tw.tween_property(ring, "position", center - Vector2(target * 0.5, target * 0.5), 0.7 + float(i) * 0.12)
		tw.tween_property(ring, "modulate:a", 0.0, 0.7 + float(i) * 0.12)
		tw.chain().tween_callback(ring.queue_free)
		active_particles.append(tw)

func create_gold_dust(parent: Control, rect: Rect2, count: int = 8) -> void:
	for i in range(count):
		var d_size = randf_range(2.0, 5.0)
		var dust = _make_gpt_spark(d_size, Color(0.96, 0.86, 0.46, randf_range(0.2, 0.5)))
		dust.name = "GoldDust_%d" % i
		dust.position = Vector2(
			randf_range(rect.position.x, rect.position.x + rect.size.x),
			randf_range(rect.position.y, rect.position.y + rect.size.y)
		)
		parent.add_child(dust)
		particle_nodes.append(dust)

		var tw = create_tween()
		tw.set_loops(48)
		var drift_x = randf_range(-40.0, 40.0)
		var drift_y = randf_range(-20.0, 20.0)
		var dur = randf_range(4.0, 8.0)
		tw.tween_property(dust, "position:x", dust.position.x + drift_x, dur).set_trans(Tween.TRANS_SINE)
		tw.parallel().tween_property(dust, "position:y", dust.position.y + drift_y, dur).set_trans(Tween.TRANS_SINE)
		tw.tween_property(dust, "position:x", dust.position.x, dur).set_trans(Tween.TRANS_SINE)
		tw.parallel().tween_property(dust, "position:y", dust.position.y, dur).set_trans(Tween.TRANS_SINE)

		var flicker_tw = create_tween()
		flicker_tw.set_loops(48)
		flicker_tw.set_trans(Tween.TRANS_SINE)
		flicker_tw.tween_property(dust, "modulate:a", 0.1, randf_range(1.0, 2.5))
		flicker_tw.tween_property(dust, "modulate:a", 1.0, randf_range(1.0, 2.5))
		active_particles.append(tw)
		active_particles.append(flicker_tw)

func animate_panel_breath(panel: Control, drift: Vector2 = Vector2(0.0, -4.0), duration: float = 2.8, min_alpha: float = 0.92) -> void:
	if panel == null:
		return
	var base_pos = panel.position
	var tw = create_tween()
	tw.set_loops(48)
	tw.set_trans(Tween.TRANS_SINE)
	tw.set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(panel, "position", base_pos + drift, duration)
	tw.parallel().tween_property(panel, "modulate:a", min_alpha, duration).from(1.0)
	tw.tween_property(panel, "position", base_pos, duration)
	tw.parallel().tween_property(panel, "modulate:a", 1.0, duration).from(min_alpha)
	active_particles.append(tw)

func create_orbiting_motes(parent: Control, rect: Rect2, theme: String = "gold", count: int = 6) -> Control:
	var orbit = Control.new()
	orbit.name = "OrbitingMotes"
	orbit.mouse_filter = Control.MOUSE_FILTER_IGNORE
	orbit.position = rect.position
	orbit.size = rect.size
	parent.add_child(orbit)
	particle_nodes.append(orbit)

	var palette = PARTICLE_PALETTES.get(theme, PARTICLE_PALETTES["gold"])
	var center = rect.size * 0.5
	var radius_x = rect.size.x * 0.42
	var radius_y = rect.size.y * 0.34

	for i in range(count):
		var mote_size = randf_range(4.0, 9.0)
		var color = palette[i % palette.size()]
		var mote = _make_gpt_spark(mote_size, Color(color.r, color.g, color.b, randf_range(0.24, 0.58)))
		mote.name = "OrbitingMote_%d" % i
		orbit.add_child(mote)

		var halo_size = mote_size * 2.8
		var halo = _make_gpt_spark(halo_size, Color(color.r, color.g, color.b, 0.14))
		halo.position = Vector2(-(halo_size - mote_size) * 0.5, -(halo_size - mote_size) * 0.5)
		mote.add_child(halo)

		var angle = TAU * float(i) / float(max(1, count))
		var start = center + Vector2(cos(angle) * radius_x, sin(angle) * radius_y)
		mote.position = start - Vector2(mote_size * 0.5, mote_size * 0.5)

		var mote_id := mote.get_instance_id()
		var orbit_tw = create_tween()
		orbit_tw.set_loops(48)
		orbit_tw.tween_method(func(t: float) -> void:
			var mote_node := instance_from_id(mote_id) as Control
			if mote_node == null:
				return
			var a = angle + t * TAU
			var p = center + Vector2(cos(a) * radius_x, sin(a) * radius_y)
			mote_node.position = p - Vector2(mote_size * 0.5, mote_size * 0.5)
		, 0.0, 1.0, randf_range(7.5, 12.0))
		active_particles.append(orbit_tw)

		var flicker_tw = create_tween()
		flicker_tw.set_loops(48)
		flicker_tw.set_trans(Tween.TRANS_SINE)
		flicker_tw.tween_property(mote, "modulate:a", 0.24, randf_range(1.2, 2.4)).from(0.82)
		flicker_tw.tween_property(mote, "modulate:a", 0.82, randf_range(1.2, 2.4)).from(0.24)
		active_particles.append(flicker_tw)

	return orbit

func create_ribbon_sweep(parent: Control, rect: Rect2, color: Color, duration: float = 3.6) -> Control:
	var sweep = Control.new()
	sweep.name = "RibbonSweep"
	sweep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sweep.anchor_left = rect.position.x
	sweep.anchor_top = rect.position.y
	sweep.anchor_right = rect.position.x + rect.size.x
	sweep.anchor_bottom = rect.position.y + rect.size.y
	sweep.offset_left = 0.0
	sweep.offset_top = 0.0
	sweep.offset_right = 0.0
	sweep.offset_bottom = 0.0
	parent.add_child(sweep)
	particle_nodes.append(sweep)

	# GPT soft flash streak — no program ColorRect
	var streak: Control
	var flash_tex: Texture2D = null
	if ResourceLoader.exists("res://assets/illustrations/ui_soft_flash.png"):
		flash_tex = load("res://assets/illustrations/ui_soft_flash.png") as Texture2D
	if flash_tex != null:
		var tex_streak = TextureRect.new()
		tex_streak.texture = flash_tex
		tex_streak.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex_streak.stretch_mode = TextureRect.STRETCH_SCALE
		tex_streak.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tex_streak.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		tex_streak.modulate = Color(color.r, color.g, color.b, clampf(color.a, 0.12, 0.55))
		streak = tex_streak
	else:
		streak = Control.new()
		streak.mouse_filter = Control.MOUSE_FILTER_IGNORE
		streak.modulate = Color(1, 1, 1, 0)
	streak.name = "RibbonStreak"
	streak.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sweep.add_child(streak)

	var tw = create_tween()
	tw.set_loops(48)
	tw.tween_property(sweep, "modulate:a", 0.15, duration * 0.5).from(0.85)
	tw.tween_property(sweep, "modulate:a", 0.85, duration * 0.5)
	active_particles.append(tw)
	return sweep
