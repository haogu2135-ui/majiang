class_name WallBackStrip
extends Control

# 牌墙背面：仅 GPT/既有 illustrations + 牌背纹理，不使用程序 draw_rect 色块当视觉。

const WALL_STRIP_TEXTURE_PATH := "res://assets/illustrations/wall_strip_landscape_v2.png"
const WALL_STRIP_FALLBACK_TEXTURE_PATH := "res://assets/illustrations/wall_strip_landscape.png"
const WALL_BACK_TEXTURE_PATH := "res://assets/tiles/tile_back.png"
const WALL_BACK_FALLBACK_TEXTURE_PATH := "res://assets/tiles/tile_back_3d.png"
const SOFT_FLASH_PATH := "res://assets/illustrations/ui_soft_flash.png"
const WARNING_PATH := "res://assets/illustrations/center_wall_gpt_warning.png"
const WARNING_FALLBACK_PATH := "res://assets/illustrations/top_hud_wall_gpt_warning.png"

var tile_count := 0
var capacity_count := 0
var horizontal := true
var tile_size := Vector2.ZERO
var tile_style: StyleBoxFlat
var remaining_ratio := 1.0
var low_wall := false
var recent_feedback := false
var shade_color := Color(0.12, 0.09, 0.06, 0.22)
var depth_color := Color(0.050, 0.035, 0.020, 0.28)
var lower_edge_color := Color(0.040, 0.030, 0.020, 0.34)
var porcelain_highlight := Color(0.96, 0.90, 0.70, 0.13)
var feedback_glint_color := Color(0.98, 0.78, 0.36, 0.22)
# 兼容旧烟测属性（不再绘制程序色）
var rail_color := Color(0.86, 0.72, 0.38, 0.16)
var endpoint_color := Color(0.92, 0.78, 0.42, 0.22)
var rhythm_color := Color(0.96, 0.84, 0.50, 0.18)
var flow_color := Color(0.42, 0.72, 0.58, 0.14)
var break_color := Color(0.96, 0.82, 0.42, 0.24)
var count_mark_color := Color(0.18, 0.12, 0.07, 0.20)
var wall_strip_texture_cache: Texture2D
var wall_back_texture_cache: Texture2D
var soft_flash_texture_cache: Texture2D
var warning_texture_cache: Texture2D

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
	# Keep StyleBox for smoke/property probes only — never paint program slabs.
	tile_style.bg_color = Color(fill_color.r, fill_color.g, fill_color.b, 0.0)
	tile_style.border_color = Color(border_color.r, border_color.g, border_color.b, 0.0)
	tile_style.set_border_width_all(0)
	tile_style.set_corner_radius_all(7)
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()

func _draw() -> void:
	if capacity_count <= 0 or tile_size.x <= 0.0 or tile_size.y <= 0.0:
		return
	var strip_rect = Rect2(Vector2(1.0, 1.0), Vector2(max(1.0, size.x - 2.0), max(1.0, size.y - 3.0)))
	var wall_strip_texture = get_wall_strip_texture()
	var flash = get_soft_flash_texture()
	# Soft depth via GPT/strip textures only.
	var strip_shadow_rect = Rect2(Vector2(3.0, 5.0), Vector2(max(1.0, size.x - 5.0), max(1.0, size.y - 6.0)))
	_draw_oriented_texture(wall_strip_texture, strip_shadow_rect, Color(0.04, 0.03, 0.02, 0.62))
	_draw_oriented_texture(wall_strip_texture, strip_rect, Color(0.56, 0.48, 0.36, 0.38))
	var table_lip = Rect2(Vector2(strip_rect.position.x + 2.0, strip_rect.end.y - max(2.0, strip_rect.size.y * 0.18)), Vector2(max(1.0, strip_rect.size.x - 4.0), max(2.0, strip_rect.size.y * 0.15)))
	if not horizontal:
		table_lip = Rect2(Vector2(strip_rect.end.x - max(2.0, strip_rect.size.x * 0.20), strip_rect.position.y + 2.0), Vector2(max(2.0, strip_rect.size.x * 0.16), max(1.0, strip_rect.size.y - 4.0)))
	_draw_oriented_texture(wall_strip_texture, table_lip, Color(0.08, 0.05, 0.03, 0.55))
	var active_rect = strip_rect
	if horizontal:
		active_rect.size.x = max(1.0, strip_rect.size.x * clamp(float(tile_count) / float(capacity_count), 0.0, 1.0))
	else:
		active_rect.size.y = max(1.0, strip_rect.size.y * clamp(float(tile_count) / float(capacity_count), 0.0, 1.0))
	_draw_oriented_texture(wall_strip_texture, active_rect, Color(1.0, 1.0, 1.0, 0.50 + remaining_ratio * 0.18))
	if low_wall:
		_draw_oriented_texture(get_warning_texture(), strip_rect, Color(0.96, 0.58, 0.34, 0.28))
	elif recent_feedback:
		_draw_oriented_texture(flash, active_rect, Color(0.96, 0.82, 0.42, 0.22))
	if tile_count > 0 and (recent_feedback or low_wall):
		var edge_tint = Color(0.96, 0.54, 0.26, 0.55) if low_wall else Color(feedback_glint_color.r, feedback_glint_color.g, feedback_glint_color.b, 0.55)
		if horizontal:
			var edge_x = clamp(active_rect.position.x + active_rect.size.x - 6.0, strip_rect.position.x + 2.0, strip_rect.end.x - 8.0)
			_draw_oriented_texture(flash, Rect2(Vector2(edge_x, strip_rect.position.y + 2.0), Vector2(6.0, max(1.0, strip_rect.size.y - 4.0))), edge_tint)
			if recent_feedback:
				for i in range(3):
					var tick_x = clamp(edge_x - 10.0 - float(i) * 9.0, strip_rect.position.x + 3.0, strip_rect.end.x - 8.0)
					_draw_oriented_texture(flash, Rect2(Vector2(tick_x, strip_rect.position.y + 4.0), Vector2(5.0, max(1.0, strip_rect.size.y - 8.0))), Color(feedback_glint_color.r, feedback_glint_color.g, feedback_glint_color.b, 0.28 - float(i) * 0.06))
		else:
			var edge_y = clamp(active_rect.position.y + active_rect.size.y - 6.0, strip_rect.position.y + 2.0, strip_rect.end.y - 8.0)
			_draw_oriented_texture(flash, Rect2(Vector2(strip_rect.position.x + 2.0, edge_y), Vector2(max(1.0, strip_rect.size.x - 4.0), 6.0)), edge_tint)
			if recent_feedback:
				for i in range(3):
					var tick_y = clamp(edge_y - 10.0 - float(i) * 9.0, strip_rect.position.y + 3.0, strip_rect.end.y - 8.0)
					_draw_oriented_texture(flash, Rect2(Vector2(strip_rect.position.x + 4.0, tick_y), Vector2(max(1.0, strip_rect.size.x - 8.0), 5.0)), Color(feedback_glint_color.r, feedback_glint_color.g, feedback_glint_color.b, 0.28 - float(i) * 0.06))

	var wall_back_texture = get_wall_back_texture()
	for tile_number in range(capacity_count):
		var active = tile_number < tile_count
		var slot_alpha = 1.0 if active else 0.16
		var center = Vector2(
			(float(tile_number) + 0.5) * size.x / float(capacity_count) if horizontal else size.x * 0.5,
			size.y * 0.5 if horizontal else (float(tile_number) + 0.5) * size.y / float(capacity_count)
		)
		var tile_rect = Rect2(center - tile_size * 0.5, tile_size)
		# cast / side depth via strip texture tint — no program slabs
		_draw_oriented_texture(wall_strip_texture, Rect2(tile_rect.position + Vector2(2.5, 4.5), tile_rect.size), Color(0.02, 0.015, 0.01, 0.45 * slot_alpha))
		if active:
			if wall_back_texture != null:
				draw_texture_rect(wall_back_texture, tile_rect.grow(-1.0), false, Color(1.0, 1.0, 1.0, 0.92))
			else:
				_draw_oriented_texture(wall_strip_texture, tile_rect.grow(-1.0), Color(0.72, 0.62, 0.48, 0.85))
		else:
			_draw_oriented_texture(wall_strip_texture, tile_rect, Color(0.18, 0.14, 0.10, 0.22))
		# lower edge + side shade + top sheen as soft GPT flash tints
		var bottom_rect = Rect2(
			Vector2(tile_rect.position.x + 2.0, tile_rect.position.y + tile_rect.size.y * 0.82),
			Vector2(max(1.0, tile_rect.size.x - 4.0), max(1.0, tile_rect.size.y * 0.15))
		)
		_draw_oriented_texture(wall_strip_texture, bottom_rect, Color(lower_edge_color.r, lower_edge_color.g, lower_edge_color.b, lower_edge_color.a * slot_alpha))
		var shade_rect = Rect2(
			Vector2(tile_rect.position.x + tile_rect.size.x * 0.76, tile_rect.position.y + 2.0),
			Vector2(max(1.0, tile_rect.size.x * 0.16), max(1.0, tile_rect.size.y - 4.0))
		)
		_draw_oriented_texture(wall_strip_texture, shade_rect, Color(shade_color.r, shade_color.g, shade_color.b, shade_color.a * slot_alpha))
		var top_highlight = Rect2(
			Vector2(tile_rect.position.x + 3.0, tile_rect.position.y + 2.0),
			Vector2(max(1.0, tile_rect.size.x * 0.62), max(1.0, tile_rect.size.y * 0.08))
		)
		_draw_oriented_texture(flash, top_highlight, Color(porcelain_highlight.r, porcelain_highlight.g, porcelain_highlight.b, porcelain_highlight.a * slot_alpha * 1.4))
		if active and recent_feedback and tile_number == tile_count - 1:
			_draw_oriented_texture(flash, tile_rect.grow(3.0), Color(feedback_glint_color.r, feedback_glint_color.g, feedback_glint_color.b, 0.28))
			var draw_sheen = Rect2(
				Vector2(tile_rect.position.x + tile_rect.size.x * 0.16, tile_rect.position.y + tile_rect.size.y * 0.12),
				Vector2(max(1.0, tile_rect.size.x * 0.62), max(1.0, tile_rect.size.y * 0.12))
			)
			_draw_oriented_texture(flash, draw_sheen, Color(1.0, 0.94, 0.66, 0.42))
	if low_wall:
		var warning_edge = Rect2(Vector2(1.0, 1.0), Vector2(max(1.0, size.x - 2.0), max(2.0, size.y * 0.12)))
		if not horizontal:
			warning_edge = Rect2(Vector2(1.0, 1.0), Vector2(max(2.0, size.x * 0.14), max(1.0, size.y - 2.0)))
		_draw_oriented_texture(get_warning_texture(), warning_edge, Color(0.96, 0.58, 0.28, 0.48))

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

func get_soft_flash_texture() -> Texture2D:
	if soft_flash_texture_cache != null:
		return soft_flash_texture_cache
	soft_flash_texture_cache = load_wall_texture(SOFT_FLASH_PATH)
	if soft_flash_texture_cache == null:
		soft_flash_texture_cache = get_wall_strip_texture()
	return soft_flash_texture_cache

func get_warning_texture() -> Texture2D:
	if warning_texture_cache != null:
		return warning_texture_cache
	warning_texture_cache = load_wall_texture(WARNING_PATH)
	if warning_texture_cache == null:
		warning_texture_cache = load_wall_texture(WARNING_FALLBACK_PATH)
	if warning_texture_cache == null:
		warning_texture_cache = get_soft_flash_texture()
	return warning_texture_cache

func load_wall_texture(path: String) -> Texture2D:
	if not ResourceLoader.exists(path):
		return null
	var import_path := path + ".import"
	if FileAccess.file_exists(import_path):
		var import_cfg := ConfigFile.new()
		if import_cfg.load(import_path) != OK:
			return null
		var imported_path := str(import_cfg.get_value("remap", "path", ""))
		if imported_path == "" or not FileAccess.file_exists(ProjectSettings.globalize_path(imported_path)):
			return null
	var imported_texture = ResourceLoader.load(path, "Texture2D")
	return imported_texture as Texture2D if imported_texture is Texture2D else null
