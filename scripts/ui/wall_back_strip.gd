class_name WallBackStrip
extends Control

# 牌墙背面使用真实牌背和整条牌墙底图渲染。余牌变化会改变活跃槽数量，
# 让堆牌区本身响应 wallCount，而不是只更新文本数字。

const WALL_STRIP_TEXTURE_PATH := "res://assets/illustrations/wall_strip_landscape_v2.png"
const WALL_STRIP_FALLBACK_TEXTURE_PATH := "res://assets/illustrations/wall_strip_landscape.png"
const WALL_BACK_TEXTURE_PATH := "res://assets/tiles/tile_back.png"  # r389: prefer 2D back (less neon green)
const WALL_BACK_FALLBACK_TEXTURE_PATH := "res://assets/tiles/tile_back_3d.png"

var tile_count := 0
var capacity_count := 0
var horizontal := true
var tile_size := Vector2.ZERO
var tile_style: StyleBoxFlat
var remaining_ratio := 1.0
var low_wall := false
var recent_feedback := false
var shade_color := Color(0.12, 0.09, 0.06, 0.22)  # r389
var depth_color := Color(0.050, 0.035, 0.020, 0.28)  # r389
var lower_edge_color := Color(0.040, 0.030, 0.020, 0.34)  # r389
var porcelain_highlight := Color(0.96, 0.90, 0.70, 0.13)
var feedback_glint_color := Color(0.98, 0.78, 0.36, 0.22)
# 以下装饰色已不再绘制，仅保留供旧烟测属性读取兼容。
var rail_color := Color(0.86, 0.72, 0.38, 0.16)
var endpoint_color := Color(0.92, 0.78, 0.42, 0.22)
var rhythm_color := Color(0.96, 0.84, 0.50, 0.18)
var flow_color := Color(0.42, 0.72, 0.58, 0.14)
var break_color := Color(0.96, 0.82, 0.42, 0.24)
var count_mark_color := Color(0.18, 0.12, 0.07, 0.20)
var wall_strip_texture_cache: Texture2D
var wall_back_texture_cache: Texture2D

func configure(count: int, is_horizontal: bool, requested_tile_size: Vector2, fill_color: Color, border_color: Color, requested_capacity: int = -1, ratio: float = 1.0, is_low_wall: bool = false, has_recent_feedback: bool = false) -> void:
	tile_count = max(0, count)
	capacity_count = max(tile_count, requested_capacity if requested_capacity >= 0 else tile_count)
	horizontal = is_horizontal
	tile_size = requested_tile_size
	remaining_ratio = clamp(ratio, 0.0, 1.0)
	low_wall = is_low_wall
	recent_feedback = has_recent_feedback
	name = "WallBackStrip_%s_%d" % ["h" if horizontal else "v", capacity_count]
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if tile_style == null:
		tile_style = StyleBoxFlat.new()
	tile_style.bg_color = fill_color
	tile_style.border_color = border_color
	tile_style.set_border_width_all(1)
	tile_style.set_corner_radius_all(7)
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()

func _draw() -> void:
	if capacity_count <= 0 or tile_size.x <= 0.0 or tile_size.y <= 0.0 or tile_style == null:
		return
	var strip_shadow_rect = Rect2(Vector2(3.0, 5.0), Vector2(max(1.0, size.x - 5.0), max(1.0, size.y - 6.0)))
	draw_rect(strip_shadow_rect, Color(0.0, 0.0, 0.0, 0.26), true)
	var strip_rect = Rect2(Vector2(1.0, 1.0), Vector2(max(1.0, size.x - 2.0), max(1.0, size.y - 3.0)))
	draw_rect(strip_rect, Color(0.040, 0.030, 0.020, 0.30), true)  # r389 warm
	var wall_strip_texture = get_wall_strip_texture()
	_draw_oriented_texture(wall_strip_texture, strip_rect, Color(0.56, 0.48, 0.36, 0.14))
	var table_lip = Rect2(Vector2(strip_rect.position.x + 2.0, strip_rect.end.y - max(2.0, strip_rect.size.y * 0.18)), Vector2(max(1.0, strip_rect.size.x - 4.0), max(2.0, strip_rect.size.y * 0.15)))
	if not horizontal:
		table_lip = Rect2(Vector2(strip_rect.end.x - max(2.0, strip_rect.size.x * 0.20), strip_rect.position.y + 2.0), Vector2(max(2.0, strip_rect.size.x * 0.16), max(1.0, strip_rect.size.y - 4.0)))
	draw_rect(table_lip, Color(0.0, 0.0, 0.0, 0.16), true)
	var active_rect = strip_rect
	if horizontal:
		active_rect.size.x = max(1.0, strip_rect.size.x * clamp(float(tile_count) / float(capacity_count), 0.0, 1.0))
	else:
		active_rect.size.y = max(1.0, strip_rect.size.y * clamp(float(tile_count) / float(capacity_count), 0.0, 1.0))
	_draw_oriented_texture(wall_strip_texture, active_rect, Color(1.0, 1.0, 1.0, 0.50 + remaining_ratio * 0.18))
	if low_wall:
		draw_rect(strip_rect, Color(0.72, 0.22, 0.10, 0.10), true)
	elif recent_feedback:
		draw_rect(active_rect, Color(0.96, 0.76, 0.36, 0.105), true)
	if tile_count > 0 and (recent_feedback or low_wall):
		var edge_color = Color(0.96, 0.54, 0.26, 0.34) if low_wall else feedback_glint_color
		if horizontal:
			var edge_x = clamp(active_rect.position.x + active_rect.size.x - 3.0, strip_rect.position.x + 2.0, strip_rect.end.x - 4.0)
			draw_rect(Rect2(Vector2(edge_x, strip_rect.position.y + 3.0), Vector2(3.0, max(1.0, strip_rect.size.y - 6.0))), edge_color, true)
			if recent_feedback:
				for i in range(3):
					var tick_x = clamp(edge_x - 10.0 - float(i) * 9.0, strip_rect.position.x + 3.0, strip_rect.end.x - 8.0)
					draw_rect(Rect2(Vector2(tick_x, strip_rect.position.y + 5.0), Vector2(4.0, max(1.0, strip_rect.size.y - 10.0))), Color(feedback_glint_color.r, feedback_glint_color.g, feedback_glint_color.b, 0.20 - float(i) * 0.045), true)
		else:
			var edge_y = clamp(active_rect.position.y + active_rect.size.y - 3.0, strip_rect.position.y + 2.0, strip_rect.end.y - 4.0)
			draw_rect(Rect2(Vector2(strip_rect.position.x + 3.0, edge_y), Vector2(max(1.0, strip_rect.size.x - 6.0), 3.0)), edge_color, true)
			if recent_feedback:
				for i in range(3):
					var tick_y = clamp(edge_y - 10.0 - float(i) * 9.0, strip_rect.position.y + 3.0, strip_rect.end.y - 8.0)
					draw_rect(Rect2(Vector2(strip_rect.position.x + 5.0, tick_y), Vector2(max(1.0, strip_rect.size.x - 10.0), 4.0)), Color(feedback_glint_color.r, feedback_glint_color.g, feedback_glint_color.b, 0.20 - float(i) * 0.045), true)

	for tile_number in range(capacity_count):
		var active = tile_number < tile_count
		var slot_alpha = 1.0 if active else 0.14
		var center = Vector2(
			(float(tile_number) + 0.5) * size.x / float(capacity_count) if horizontal else size.x * 0.5,
			size.y * 0.5 if horizontal else (float(tile_number) + 0.5) * size.y / float(capacity_count)
		)
		var tile_rect = Rect2(center - tile_size * 0.5, tile_size)
		var cast_shadow = Rect2(tile_rect.position + Vector2(2.5, 4.5), tile_rect.size)
		draw_rect(cast_shadow, Color(0.0, 0.0, 0.0, 0.22 * slot_alpha), true)
		var side_shadow = Rect2(Vector2(tile_rect.position.x + tile_rect.size.x * 0.76, tile_rect.position.y + 2.0), Vector2(max(1.0, tile_rect.size.x * 0.22), max(1.0, tile_rect.size.y - 3.0)))
		draw_rect(side_shadow, Color(depth_color.r, depth_color.g, depth_color.b, depth_color.a * slot_alpha), true)
		if active:
			draw_style_box(tile_style, tile_rect)
			var texture_rect = tile_rect.grow(-1.0)
			var wall_back_texture = get_wall_back_texture()
			if wall_back_texture != null:
				draw_texture_rect(wall_back_texture, texture_rect, false, Color(1.0, 1.0, 1.0, 0.90))
		else:
			draw_rect(tile_rect, Color(0.05, 0.08, 0.07, 0.10), true)
		var bottom_rect = Rect2(
			Vector2(tile_rect.position.x + 2.0, tile_rect.position.y + tile_rect.size.y * 0.82),
			Vector2(max(1.0, tile_rect.size.x - 4.0), max(1.0, tile_rect.size.y * 0.15))
		)
		draw_rect(bottom_rect, Color(lower_edge_color.r, lower_edge_color.g, lower_edge_color.b, lower_edge_color.a * slot_alpha), true)
		var shade_rect = Rect2(
			Vector2(tile_rect.position.x + tile_rect.size.x * 0.76, tile_rect.position.y + 2.0),
			Vector2(max(1.0, tile_rect.size.x * 0.16), max(1.0, tile_rect.size.y - 4.0))
		)
		draw_rect(shade_rect, Color(shade_color.r, shade_color.g, shade_color.b, shade_color.a * slot_alpha), true)
		var top_highlight = Rect2(
			Vector2(tile_rect.position.x + 3.0, tile_rect.position.y + 2.0),
			Vector2(max(1.0, tile_rect.size.x * 0.62), max(1.0, tile_rect.size.y * 0.08))
		)
		draw_rect(top_highlight, Color(porcelain_highlight.r, porcelain_highlight.g, porcelain_highlight.b, porcelain_highlight.a * slot_alpha), true)
		if active and recent_feedback and tile_number == tile_count - 1:
			draw_rect(tile_rect.grow(3.0), Color(feedback_glint_color.r, feedback_glint_color.g, feedback_glint_color.b, 0.16), true)
			draw_rect(tile_rect.grow(1.5), Color(1.0, 0.88, 0.54, 0.42), false, 1.5)
			var draw_sheen = Rect2(
				Vector2(tile_rect.position.x + tile_rect.size.x * 0.16, tile_rect.position.y + tile_rect.size.y * 0.12),
				Vector2(max(1.0, tile_rect.size.x * 0.62), max(1.0, tile_rect.size.y * 0.12))
			)
			draw_rect(draw_sheen, Color(1.0, 0.94, 0.66, 0.30), true)
	if low_wall:
		var warning_edge = Rect2(Vector2(1.0, 1.0), Vector2(max(1.0, size.x - 2.0), max(2.0, size.y * 0.10)))
		if not horizontal:
			warning_edge = Rect2(Vector2(1.0, 1.0), Vector2(max(2.0, size.x * 0.12), max(1.0, size.y - 2.0)))
		draw_rect(warning_edge, Color(0.96, 0.58, 0.28, 0.32), true)

func _draw_oriented_texture(texture: Texture2D, rect: Rect2, tint: Color) -> void:
	if texture == null or rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return
	if horizontal:
		draw_texture_rect(texture, rect, false, tint)
		return
	draw_set_transform(rect.position + Vector2(rect.size.x, 0.0), PI * 0.5, Vector2.ONE)
	draw_texture_rect(texture, Rect2(Vector2.ZERO, Vector2(rect.size.y, rect.size.x)), false, tint)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func get_wall_back_texture() -> Texture2D:
	if wall_back_texture_cache != null:
		return wall_back_texture_cache
	wall_back_texture_cache = load_wall_texture(WALL_BACK_TEXTURE_PATH)
	if wall_back_texture_cache == null:
		wall_back_texture_cache = load_wall_texture(WALL_BACK_FALLBACK_TEXTURE_PATH)
	return wall_back_texture_cache

func get_wall_strip_texture() -> Texture2D:
	if wall_strip_texture_cache != null:
		return wall_strip_texture_cache
	wall_strip_texture_cache = load_wall_texture(WALL_STRIP_TEXTURE_PATH)
	if wall_strip_texture_cache == null:
		wall_strip_texture_cache = load_wall_texture(WALL_STRIP_FALLBACK_TEXTURE_PATH)
	return wall_strip_texture_cache

func load_wall_texture(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		var imported_texture = load(path)
		if imported_texture is Texture2D:
			return imported_texture
	var image = Image.new()
	var err = image.load(ProjectSettings.globalize_path(path))
	if err != OK:
		return null
	return ImageTexture.create_from_image(image)
