class_name WallBackStrip
extends Control

var tile_count := 0
var horizontal := true
var tile_size := Vector2.ZERO
var tile_style: StyleBoxFlat
var shade_color := Color(0.53, 0.45, 0.28, 0.16)

func configure(count: int, is_horizontal: bool, requested_tile_size: Vector2, fill_color: Color, border_color: Color) -> void:
	tile_count = count
	horizontal = is_horizontal
	tile_size = requested_tile_size
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
	if tile_count <= 0 or tile_size.x <= 0.0 or tile_size.y <= 0.0 or tile_style == null:
		return
	for tile_number in range(tile_count):
		var center = Vector2(
			(float(tile_number) + 0.5) * size.x / float(tile_count) if horizontal else size.x * 0.5,
			size.y * 0.5 if horizontal else (float(tile_number) + 0.5) * size.y / float(tile_count)
		)
		var tile_rect = Rect2(center - tile_size * 0.5, tile_size)
		draw_style_box(tile_style, tile_rect)
		var shade_rect = Rect2(
			Vector2(tile_rect.position.x + tile_rect.size.x * 0.76, tile_rect.position.y + 2.0),
			Vector2(max(1.0, tile_rect.size.x * 0.16), max(1.0, tile_rect.size.y - 4.0))
		)
		draw_rect(shade_rect, shade_color, true)
