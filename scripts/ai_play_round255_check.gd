extends SceneTree
## Round 255: discard route classification reuses the report tile index.

var failed := false


func _initialize() -> void:
	call_deferred("run")


func check(condition: bool, message: String) -> void:
	if condition:
		print("  OK  | %s" % message)
	else:
		print("  FAIL| %s" % message)
		failed = true


func make_player(name: String) -> Dictionary:
	return {
		"name": name,
		"hand": [],
		"discards": [],
		"melds": [],
		"flowers": 0,
		"flower_tiles": [],
		"score": 25000,
		"bot": true,
	}


func run() -> void:
	print("=== ai_play_round255 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.mode = "offline"
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]

	var route_source_255 := FileAccess.get_file_as_string("res://scripts/main_src/core.gd.part")
	var reason_source_255 := FileAccess.get_file_as_string("res://scripts/main_src/gameplay.gd.part")
	check(route_source_255.contains("tile_index_snapshot: int = -2"), "route offcut classification accepts an index snapshot")
	check(reason_source_255.contains("is_plan_offcut(tile, report, original_hand, original_counts_snapshot, tile_index_snapshot)"), "discard reasons forward the candidate index to route classification")
	var route_index_255: int = scene.tile_index("4W")
	var indexed_route_report_255: Dictionary = {"plan_label": "清一色", "plan_suit": 1, "tile_index": route_index_255}
	check(scene.discard_reason_label("ZZ", [], indexed_route_report_255) == "保路线", "report tile indexes classify canonical route offcuts")
	var fallback_route_report_255: Dictionary = {"plan_label": "清一色", "plan_suit": 1}
	var fallback_reason_255: String = scene.discard_reason_label("4W", [], fallback_route_report_255)
	var explicit_reason_255: String = scene.discard_reason_label("4M", [], fallback_route_report_255, [], route_index_255)
	check(explicit_reason_255 == fallback_reason_255, "explicit route indexes preserve normalized aliases")
	var simple_report_255: Dictionary = {"plan_label": "断幺九", "tile_index": scene.tile_index("4W")}
	check(not scene.is_plan_offcut("ZZ", simple_report_255) and not scene.is_plan_offcut("4W", simple_report_255), "route classification keeps non-offcut simple-number behavior")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
