class_name BattleTableDepth
extends Control

var active_seat := 0
var accent := Color(0.92, 0.72, 0.34, 1.0)

func configure(seat: int, seat_accent: Color) -> void:
	active_seat = clamp(seat, 0, 3)
	accent = seat_accent
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()

func _draw() -> void:
	if size.x <= 1.0 or size.y <= 1.0:
		return
	var w := size.x
	var h := size.y
	var near_y := h * 0.855

	# The table illustration already carries the ornament. These restrained planes
	# reinforce its perspective and stay below all gameplay pieces.
	draw_colored_polygon(PackedVector2Array([
		Vector2(w * 0.035, near_y),
		Vector2(w * 0.965, near_y),
		Vector2(w, h * 0.985),
		Vector2(0.0, h * 0.985),
	]), Color(0.010, 0.008, 0.005, 0.02))  # r427
	draw_colored_polygon(PackedVector2Array([
		Vector2(w * 0.020, h * 0.120),
		Vector2(w * 0.075, h * 0.165),
		Vector2(w * 0.105, h * 0.835),
		Vector2(w * 0.035, h * 0.920),
	]), Color(0.0, 0.0, 0.0, 0.03))  # r423
	draw_colored_polygon(PackedVector2Array([
		Vector2(w * 0.980, h * 0.120),
		Vector2(w * 0.925, h * 0.165),
		Vector2(w * 0.895, h * 0.835),
		Vector2(w * 0.965, h * 0.920),
	]), Color(0.0, 0.0, 0.0, 0.03))  # r423

	var near_edge := PackedVector2Array([
		Vector2(w * 0.055, near_y),
		Vector2(w * 0.945, near_y),
	])
	draw_polyline(near_edge, Color(0.98, 0.80, 0.43, 0.20), 2.0, true)
	draw_polyline(PackedVector2Array([
		Vector2(w * 0.135, h * 0.160),
		Vector2(w * 0.865, h * 0.160),
	]), Color(0.96, 0.78, 0.40, 0.10), 1.0, true)

	var seat_points := [
		Vector2(w * 0.50, h * 0.900),
		Vector2(w * 0.915, h * 0.50),
		Vector2(w * 0.50, h * 0.145),
		Vector2(w * 0.085, h * 0.50),
	]
	var p: Vector2 = seat_points[active_seat]
	draw_circle(p, max(4.0, min(w, h) * 0.014), Color(accent.r, accent.g, accent.b, 0.18))
	draw_arc(p, max(7.0, min(w, h) * 0.024), 0.0, TAU, 32, Color(1.0, 0.86, 0.50, 0.28), 1.5, true)
