class_name BattleTableDepth
extends Control

var active_seat := 0
var accent := Color(0.92, 0.72, 0.34, 1.0)

func configure(seat: int, seat_accent: Color) -> void:
	active_seat = clamp(seat, 0, 3)
	accent = seat_accent
	mouse_filter = Control.MOUSE_FILTER_IGNORE

# This node remains as a compatibility/layout carrier for battle smoke probes.
# The authored GPT table backdrop already owns the table ornament and lighting;
# keeping this layer non-painting avoids procedural UI decoration and duplicate
# borders over the 2D tile surface.
