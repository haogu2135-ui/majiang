extends SceneTree
## Round 14: win presentation must classify by fan, not the score-table points.
var failed := false


func _initialize() -> void:
	call_deferred("run")


func check(cond: bool, msg: String) -> void:
	if cond:
		print("  OK  | %s" % msg)
	else:
		print("  FAIL| %s" % msg)
		failed = true


func run() -> void:
	print("=== ai_play_round14 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame

	print("--- A) win presentation tier ---")
	check(scene.win_fx_type_for_score({"fan": 1, "points": 200}, false) == "normal", "低番荣和不误判为高番特效")
	check(scene.win_fx_type_for_score({"fan": 2, "points": 400}, true) == "self_draw", "低番自摸保留自摸特效")
	check(scene.win_fx_type_for_score({"fan": 3, "points": 12800}, false) == "normal", "高分表值不会越过番数门槛")
	check(scene.win_fx_type_for_score({"fan": 6, "points": 6400}, false) == "special", "六番及以上使用高番特效")
	check(scene.win_fx_type_for_score({"fan": 8, "points": 25600}, true) == "special", "封顶高番优先于自摸特效")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
