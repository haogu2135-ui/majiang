# ============================================================
# 云桌麻将 动画效果增强模块 / Animation Effects Enhancement Module
# ============================================================
# 提供过渡动画、弹窗动画、卡牌翻转动画等增强效果。
# ============================================================

extends Node

class_name AnimationEffects

# 缓动函数类型
enum EaseType {
	LINEAR,
	EASE_IN,
	EASE_OUT,
	EASE_IN_OUT,
	BACK_IN,
	BACK_OUT,
	ELASTIC_IN,
	ELASTIC_OUT,
	BOUNCE_IN,
	BOUNCE_OUT
}

# 动画时长常量 (秒)
const DURATION_FAST := 0.15
const DURATION_NORMAL := 0.3
const DURATION_SLOW := 0.6
const DURATION_VERY_SLOW := 1.0

# ============================================================
# 通用过渡动画 / General Transition Animations
# ============================================================

# 淡入动画
static func fade_in(node: Node, duration: float = DURATION_NORMAL, ease_type: EaseType = EaseType.EASE_OUT) -> Tween:
	var tw = node.create_tween()
	tw.set_ease(_get_ease(ease_type))
	tw.set_trans(Tween.TRANS_LINEAR)
	tw.tween_property(node, "modulate:a", 1.0, duration).from(0.0)
	return tw

# 淡出动画
static func fade_out(node: Node, duration: float = DURATION_NORMAL, ease_type: EaseType = EaseType.EASE_IN) -> Tween:
	var tw = node.create_tween()
	tw.set_ease(_get_ease(ease_type))
	tw.set_trans(Tween.TRANS_LINEAR)
	tw.tween_property(node, "modulate:a", 0.0, duration).from(1.0)
	return tw

# 缩放进入动画 (从0放大)
static func scale_in(node: Node, duration: float = DURATION_NORMAL, ease_type: EaseType = EaseType.BACK_OUT) -> Tween:
	var tw = node.create_tween()
	tw.set_ease(_get_ease(ease_type))
	tw.set_trans(Tween.TRANS_BACK)
	tw.tween_property(node, "scale", Vector2.ONE, duration).from(Vector2.ZERO)
	return tw

# 缩放退出动画 (缩小到0)
static func scale_out(node: Node, duration: float = DURATION_FAST, ease_type: EaseType = EaseType.EASE_IN) -> Tween:
	var tw = node.create_tween()
	tw.set_ease(_get_ease(ease_type))
	tw.set_trans(Tween.TRANS_LINEAR)
	tw.tween_property(node, "scale", Vector2.ZERO, duration).from(Vector2.ONE)
	return tw

# 滑入动画 (从屏幕边缘滑入)
static func slide_in(node: Node, direction: Vector2, duration: float = DURATION_NORMAL, ease_type: EaseType = EaseType.EASE_OUT) -> Tween:
	var tw = node.create_tween()
	tw.set_ease(_get_ease(ease_type))
	tw.set_trans(Tween.TRANS_QUAD)
	var start_pos = node.position + direction * 100  # 100 pixels offset
	tw.tween_property(node, "position", node.position, duration).from(start_pos)
	return tw

# 滑出动画 (向屏幕边缘滑出)
static func slide_out(node: Node, direction: Vector2, duration: float = DURATION_FAST, ease_type: EaseType = EaseType.EASE_IN) -> Tween:
	var tw = node.create_tween()
	tw.set_ease(_get_ease(ease_type))
	tw.set_trans(Tween.TRANS_QUAD)
	var end_pos = node.position + direction * 100
	tw.tween_property(node, "position", end_pos, duration).from(node.position)
	return tw

# 弹跳动画
static func bounce(node: Node, strength: float = 10.0, duration: float = DURATION_NORMAL, ease_type: EaseType = EaseType.BOUNCE_OUT) -> Tween:
	var tw = node.create_tween()
	tw.set_ease(_get_ease(ease_type))
	tw.set_trans(Tween.TRANS_BOUNCE)
	var original_y = node.position.y
	tw.tween_property(node, "position:y", original_y, duration).from(original_y - strength)
	return tw

# 脉冲动画 (循环缩放)
static func pulse(node: Node, scale_factor: float = 1.1, duration: float = 0.5) -> Tween:
	var tw = node.create_tween()
	tw.set_loops(3600)
	tw.set_ease(Tween.EASE_IN_OUT)
	tw.set_trans(Tween.TRANS_SINE)
	tw.tween_property(node, "scale", Vector2(scale_factor, scale_factor), duration * 0.5)
	tw.tween_property(node, "scale", Vector2.ONE, duration * 0.5)
	return tw

# 闪烁动画
static func flash(node: Node, min_alpha: float = 0.3, max_alpha: float = 1.0, duration: float = 0.5) -> Tween:
	var tw = node.create_tween()
	tw.set_loops(3600)
	tw.set_ease(Tween.EASE_IN_OUT)
	tw.set_trans(Tween.TRANS_SINE)
	tw.tween_property(node, "modulate:a", max_alpha, duration * 0.5).from(min_alpha)
	tw.tween_property(node, "modulate:a", min_alpha, duration * 0.5).from(max_alpha)
	return tw

# ============================================================
# 卡牌翻转动画 / Card Flip Animation
# ============================================================

# 3D翻转效果 (增强模拟 — 加入Y轴透视缩放与阴影偏移)
static func flip_card_3d(node: Node, duration: float = DURATION_NORMAL) -> Tween:
	var tw = node.create_tween()
	tw.set_ease(Tween.EASE_IN_OUT)
	tw.set_trans(Tween.TRANS_CUBIC)

	# 第一阶段: X缩至扁平 + Y轴微张(透视感) + 投影偏移
	tw.set_parallel(true)
	tw.tween_property(node, "scale:x", 0.0, duration * 0.5)
	tw.tween_property(node, "scale:y", 1.08, duration * 0.25).from(1.0)
	if node is Control:
		tw.parallel().tween_property(node, "offset_top", 2.0, duration * 0.5).from(0.0)

	# 第二阶段: X恢复原始 + Y回缩 + 投影归位
	tw.chain().set_parallel(true)
	tw.tween_property(node, "scale:x", 1.0, duration * 0.5)
	tw.tween_property(node, "scale:y", 1.0, duration * 0.25).from(1.08)
	if node is Control:
		tw.parallel().tween_property(node, "offset_top", 0.0, duration * 0.5).from(2.0)

	return tw

# 翻转并显示背面 (增强 - 加入Y轴透视与阴影)
static func flip_and_swap(node: Node, new_texture: Texture2D = null, duration: float = DURATION_NORMAL) -> Tween:
	var tw = node.create_tween()
	tw.set_ease(Tween.EASE_IN_OUT)
	tw.set_trans(Tween.TRANS_CUBIC)

	# 第一阶段: 翻转到一半 + Y轴微张
	tw.set_parallel(true)
	tw.tween_property(node, "scale:x", 0.0, duration * 0.5)
	tw.tween_property(node, "scale:y", 1.08, duration * 0.25).from(1.0)

	# 在翻转中点更换纹理
	if new_texture != null:
		var sprite = node as Sprite2D
		if sprite != null:
			tw.chain().tween_callback(func():
				sprite.texture = new_texture
			)

	# 第二阶段: 翻转完成 + Y回缩
	tw.set_parallel(true)
	tw.tween_property(node, "scale:x", 1.0, duration * 0.5)
	tw.tween_property(node, "scale:y", 1.0, duration * 0.25).from(1.08)

	return tw

# ============================================================
# 弹窗动画 / Popup Animations
# ============================================================

# 弹出动画 (带背景遮罩)
static func popup_show(panel: Control, overlay: Control, duration: float = DURATION_NORMAL) -> void:
	# 设置初始状态
	overlay.modulate.a = 0.0
	panel.scale = Vector2.ZERO

	# 遮罩淡入
	var overlay_tw = overlay.create_tween()
	overlay_tw.tween_property(overlay, "modulate:a", 0.6, duration).from(0.0)

	# 面板缩放进入
	var panel_tw = panel.create_tween()
	panel_tw.set_ease(Tween.EASE_OUT)
	panel_tw.set_trans(Tween.TRANS_BACK)
	panel_tw.tween_property(panel, "scale", Vector2.ONE, duration).from(Vector2.ZERO)

# 关闭弹窗动画
static func popup_hide(panel: Control, overlay: Control, duration: float = DURATION_FAST) -> void:
	# 面板缩放退出
	var panel_tw = panel.create_tween()
	panel_tw.set_ease(Tween.EASE_IN)
	panel_tw.set_trans(Tween.TRANS_QUAD)
	panel_tw.tween_property(panel, "scale", Vector2.ZERO, duration)

	# 遮罩淡出
	var overlay_tw = overlay.create_tween()
	overlay_tw.tween_property(overlay, "modulate:a", 0.0, duration).from(0.6)

# 弹窗抖动 (错误提示)
static func shake_popup(panel: Control, strength: float = 10.0, duration: float = 0.4) -> Tween:
	var tw = panel.create_tween()
	var original_pos = panel.position
	var shake_count = 5

	for i in range(shake_count):
		var offset = Vector2(randf_range(-strength, strength), 0)
		tw.tween_property(panel, "position", original_pos + offset, duration / shake_count)

	tw.chain().tween_property(panel, "position", original_pos, duration / shake_count)
	return tw

# ============================================================
# 列表项动画 / List Item Animations
# ============================================================

# 列表项依次进入动画
static func list_items_stagger_in(items: Array[Node], duration: float = DURATION_NORMAL, delay: float = 0.05) -> void:
	for i in range(items.size()):
		var item = items[i]
		item.modulate.a = 0.0
		item.position.x -= 20  # 初始位置偏移

		var tw = item.create_tween()
		tw.set_ease(Tween.EASE_OUT)
		tw.set_trans(Tween.TRANS_QUAD)
		tw.tween_property(item, "modulate:a", 1.0, duration).set_delay(i * delay)
		tw.parallel().tween_property(item, "position:x", item.position.x + 20, duration).set_delay(i * delay)

# ============================================================
# 数字滚动动画 / Number Roll Animation
# ============================================================

# 数字滚动效果 (用于分数变化等)
static func animate_number(label: Label, target_value: int, duration: float = DURATION_SLOW) -> Tween:
	var tw = label.create_tween()
	var start_value = 0

	# 尝试解析当前文本为数字
	var current_text = label.text
	if current_text.is_valid_int():
		start_value = int(current_text)

	var current_value = start_value
	var steps = 20
	var step_duration = duration / steps
	var step_value = float(target_value - start_value) / steps

	for i in range(steps):
		var next_value = start_value + int(step_value * (i + 1))
		tw.tween_callback(func():
			label.text = str(next_value)
		).set_delay(step_duration * i)

	return tw

# ============================================================
# 进度条动画 / Progress Bar Animation
# ============================================================

# 进度条填充动画
static func animate_progress_bar(progress_bar: ProgressBar, target_value: float, duration: float = DURATION_SLOW, ease_type: EaseType = EaseType.EASE_OUT) -> Tween:
	var tw = progress_bar.create_tween()
	tw.set_ease(_get_ease(ease_type))
	tw.set_trans(Tween.TRANS_QUAD)
	tw.tween_property(progress_bar, "value", target_value, duration)
	return tw

# ============================================================
# 粒子轨迹动画 / Particle Trail Animation
# ============================================================

# 创建粒子轨迹
static func create_particle_trail(parent: Node, start_pos: Vector2, end_pos: Vector2, particle_count: int = 10, duration: float = 0.5) -> void:
	for i in range(particle_count):
		var particle = Control.new()
		particle.name = "TrailParticle_%d" % i
		particle.mouse_filter = Control.MOUSE_FILTER_IGNORE
		particle.position = start_pos
		parent.add_child(particle)

		# 粒子核心
		var core = Panel.new()
		core.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var core_size = randf_range(2.0, 5.0)
		core.custom_minimum_size = Vector2(core_size, core_size)

		var particle_style = StyleBoxFlat.new()
		particle_style.bg_color = Color(1.0, 0.9, 0.5, randf_range(0.5, 0.9))
		particle_style.set_corner_radius_all(50)
		core.add_theme_stylebox_override("panel", particle_style)
		particle.add_child(core)

		# 轨迹动画
		var tw = particle.create_tween()
		var delay = randf_range(0.0, duration * 0.3)
		var particle_duration = randf_range(duration * 0.5, duration)

		# 随机偏移
		var random_offset = Vector2(randf_range(-20.0, 20.0), randf_range(-20.0, 20.0))
		var target = end_pos + random_offset

		tw.tween_property(particle, "position", target, particle_duration).set_delay(delay).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(particle, "modulate:a", 0.0, particle_duration).set_delay(delay)
		tw.tween_callback(func():
			if is_instance_valid(particle):
				particle.queue_free()
		).set_delay(particle_duration + delay)

# ============================================================
# 工具函数 / Utility Functions
# ============================================================

# 将自定义的EaseType转换为Godot的Ease常量
static func _get_ease(ease_type: EaseType) -> int:
	match ease_type:
		EaseType.LINEAR:
			return Tween.EASE_IN_OUT
		EaseType.EASE_IN:
			return Tween.EASE_IN
		EaseType.EASE_OUT:
			return Tween.EASE_OUT
		EaseType.EASE_IN_OUT:
			return Tween.EASE_IN_OUT
		EaseType.BACK_IN:
			return Tween.EASE_IN
		EaseType.BACK_OUT:
			return Tween.EASE_OUT
		EaseType.ELASTIC_IN:
			return Tween.EASE_IN
		EaseType.ELASTIC_OUT:
			return Tween.EASE_OUT
		EaseType.BOUNCE_IN:
			return Tween.EASE_IN
		EaseType.BOUNCE_OUT:
			return Tween.EASE_OUT
		_:
			return Tween.EASE_OUT
