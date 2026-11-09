class_name WallBackStrip
extends Control

# 牌墙背面：仅 GPT/既有 illustrations + 牌背纹理，不使用程序 draw_rect 色块当视觉。

const WALL_STRIP_TEXTURE_PATH := "res://assets/illustrations/wall_strip_landscape_v2.png"
const WALL_STRIP_FALLBACK_TEXTURE_PATH := "res://assets/illustrations/wall_strip_landscape.png"
const WALL_BACK_TEXTURE_PATH := "res://assets/tiles/tile_back.png"
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
var wall_face_pool: Array[TextureRect] = []
var soft_flash_texture_cache: Texture2D
var warning_texture_cache: Texture2D

func configure(count: int, is_horizontal: bool, requested_tile_size: Vector2, fill_color: Color, border_color: Color, requested_capacity: int = -1, ratio: float = 1.0, is_low_wall: bool = false, has_recent_feedback: bool = false) -> void:
	var next_tile_count: int = maxi(0, count)
	var requested_capacity_value: int = requested_capacity if requested_capacity >= 0 else next_tile_count
	var next_capacity_count: int = maxi(next_tile_count, requested_capacity_value)
	var next_ratio: float = clampf(ratio, 0.0, 1.0)
	var visual_state_changed: bool = tile_count != next_tile_count or capacity_count != next_capacity_count or horizontal != is_horizontal or tile_size != requested_tile_size or not is_equal_approx(remaining_ratio, next_ratio) or low_wall != is_low_wall or recent_feedback != has_recent_feedback
	tile_count = next_tile_count
	capacity_count = next_capacity_count
	horizontal = is_horizontal
	tile_size = requested_tile_size
	remaining_ratio = next_ratio
	low_wall = is_low_wall
	recent_feedback = has_recent_feedback
	name = "WallBackStrip_%s_%d" % ["h" if horizontal else "v", capacity_count]
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style_was_created := false
	if tile_style == null:
		tile_style = StyleBoxFlat.new()
		style_was_created = true
	# Keep StyleBox for smoke/property probes only — never paint program slabs.
	tile_style.bg_color = Color(fill_color.r, fill_color.g, fill_color.b, 0.0)
	tile_style.border_color = Color(border_color.r, border_color.g, border_color.b, 0.0)
	tile_style.set_border_width_all(0)
	tile_style.set_corner_radius_all(7)
	if visual_state_changed or style_was_created:
		sync_wall_faces()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		sync_wall_faces()


static func face_center_for_layout(index: int, capacity: int, is_horizontal: bool, available_size: Vector2, face_size: Vector2) -> Vector2:
	var slots := float(maxi(1, capacity))
	var pitch := minf(available_size.x / slots, face_size.x * 4.0 / 3.0) if is_horizontal else available_size.y / slots
	var start := (available_size.x - pitch * slots) * 0.5 if is_horizontal else 0.0
	return Vector2(start + (float(index) + 0.5) * pitch, available_size.y * 0.5) if is_horizontal else Vector2(available_size.x * 0.5, (float(index) + 0.5) * pitch)


func sync_wall_faces() -> void:
	# Reuse original untinted 2D bitmaps. No generated slot, rail, shadow or
	# texture painting: each remaining wall marker is an ordinary TextureRect.
	var back := get_wall_back_texture()
	var visible_count := tile_count if back != null and capacity_count > 0 else 0
	while wall_face_pool.size() < visible_count:
		var face := TextureRect.new()
		face.name = "WallTileBack_%d" % wall_face_pool.size()
		face.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		face.stretch_mode = TextureRect.STRETCH_SCALE
		face.mouse_filter = Control.MOUSE_FILTER_IGNORE
		face.texture = back
		add_child(face)
		wall_face_pool.append(face)
	for index in range(wall_face_pool.size()):
		var face := wall_face_pool[index]
		face.visible = index < visible_count
		if not face.visible:
			continue
		# Large tables keep the authored backs in a readable group. Empty slots
		# retain their positions as the wall is drawn down.
		var center := face_center_for_layout(index, capacity_count, horizontal, size, tile_size)
		face.position = center - tile_size * 0.5
		face.size = tile_size
	set_meta("wall_bitmap_face_count", visible_count)
	set_meta("wall_bitmap_source", WALL_BACK_TEXTURE_PATH)


func get_wall_back_texture() -> Texture2D:
	if wall_back_texture_cache != null:
		return wall_back_texture_cache
	wall_back_texture_cache = load_wall_texture(WALL_BACK_TEXTURE_PATH)
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
