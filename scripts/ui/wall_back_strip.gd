class_name WallBackStrip
extends Control

var tile_count := 0
var horizontal := true
var tile_size := Vector2.ZERO
var tile_style: StyleBoxFlat
var shade_color := Color(0.53, 0.45, 0.28, 0.16)
var rail_color := Color(0.86, 0.72, 0.38, 0.16)
var endpoint_color := Color(0.92, 0.78, 0.42, 0.22)
var rhythm_color := Color(0.96, 0.84, 0.50, 0.18)
var flow_color := Color(0.42, 0.72, 0.58, 0.14)
var break_color := Color(0.96, 0.82, 0.42, 0.24)
var count_mark_color := Color(0.18, 0.12, 0.07, 0.20)

func configure(count: int, is_horizontal: bool, requested_tile_size: Vector2, fill_color: Color, border_color: Color) -> void:
	tile_count = count
	horizontal = is_horizontal
	tile_size = requested_tile_size
	name = "WallBackStrip_%s_%d" % ["h" if horizontal else "v", tile_count]
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
	draw_wall_strip_rail()
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
	draw_wall_strip_flow()
	draw_wall_strip_count_marks()
	draw_wall_strip_endpoints()
	draw_wall_strip_break()
	draw_wall_strip_rhythm()

func draw_wall_strip_rail() -> void:
	var rail_rect: Rect2
	if horizontal:
		rail_rect = Rect2(Vector2(0.0, max(0.0, size.y * 0.5 - tile_size.y * 0.58)), Vector2(size.x, max(1.0, tile_size.y * 1.16)))
	else:
		rail_rect = Rect2(Vector2(max(0.0, size.x * 0.5 - tile_size.x * 0.58), 0.0), Vector2(max(1.0, tile_size.x * 1.16), size.y))
	draw_rect(rail_rect, rail_color, true)

func draw_wall_strip_endpoints() -> void:
	var cap_size = Vector2(max(3.0, tile_size.x * 0.20), max(3.0, tile_size.y * 0.20))
	var positions := []
	if horizontal:
		positions = [Vector2(0.0, size.y * 0.5 - cap_size.y * 0.5), Vector2(max(0.0, size.x - cap_size.x), size.y * 0.5 - cap_size.y * 0.5)]
	else:
		positions = [Vector2(size.x * 0.5 - cap_size.x * 0.5, 0.0), Vector2(size.x * 0.5 - cap_size.x * 0.5, max(0.0, size.y - cap_size.y))]
	for pos in positions:
		draw_rect(Rect2(pos, cap_size), endpoint_color, true)

func draw_wall_strip_rhythm() -> void:
	var marks = min(6, max(2, int(ceil(float(tile_count) / 4.0))))
	for i in range(marks):
		var t = (float(i) + 0.5) / float(marks)
		var rect: Rect2
		if horizontal:
			rect = Rect2(Vector2(size.x * t - 2.0, max(0.0, size.y * 0.5 - tile_size.y * 0.66)), Vector2(4.0, max(2.0, tile_size.y * 0.16)))
		else:
			rect = Rect2(Vector2(max(0.0, size.x * 0.5 - tile_size.x * 0.66), size.y * t - 2.0), Vector2(max(2.0, tile_size.x * 0.16), 4.0))
		draw_rect(rect, rhythm_color, true)

func draw_wall_strip_flow() -> void:
	var flow_rect: Rect2
	if horizontal:
		flow_rect = Rect2(Vector2(size.x * 0.10, max(0.0, size.y * 0.5 - tile_size.y * 0.08)), Vector2(size.x * 0.80, max(1.0, tile_size.y * 0.16)))
	else:
		flow_rect = Rect2(Vector2(max(0.0, size.x * 0.5 - tile_size.x * 0.08), size.y * 0.10), Vector2(max(1.0, tile_size.x * 0.16), size.y * 0.80))
	draw_rect(flow_rect, flow_color, true)

func draw_wall_strip_break() -> void:
	var gap_size = Vector2(max(3.0, tile_size.x * 0.28), max(3.0, tile_size.y * 0.28))
	var pos: Vector2
	if horizontal:
		pos = Vector2(size.x * 0.78 - gap_size.x * 0.5, size.y * 0.5 - gap_size.y * 0.5)
	else:
		pos = Vector2(size.x * 0.5 - gap_size.x * 0.5, size.y * 0.78 - gap_size.y * 0.5)
	draw_rect(Rect2(pos, gap_size), break_color, true)

func draw_wall_strip_count_marks() -> void:
	var mark_count = min(4, max(2, int(ceil(float(tile_count) / 6.0))))
	for i in range(mark_count):
		var t = (float(i) + 1.0) / float(mark_count + 1)
		var rect: Rect2
		if horizontal:
			rect = Rect2(Vector2(size.x * t - 1.5, size.y * 0.5 + tile_size.y * 0.32), Vector2(3.0, max(2.0, tile_size.y * 0.14)))
		else:
			rect = Rect2(Vector2(size.x * 0.5 + tile_size.x * 0.32, size.y * t - 1.5), Vector2(max(2.0, tile_size.x * 0.14), 3.0))
		draw_rect(rect, count_mark_color, true)
