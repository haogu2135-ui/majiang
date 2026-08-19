extends SceneTree
## Round 94: all-opponent avoidable danger is a mandatory commercial strength gate.
var failed := false


func _initialize() -> void:
	call_deferred("run")


func check(cond: bool, msg: String) -> void:
	if cond:
		print("  OK  | %s" % msg)
	else:
		print("  FAIL| %s" % msg)
		failed = true


func passing_aggregate(scene) -> Dictionary:
	var aggregate = scene.empty_ai_strength_aggregate()
	aggregate["rows"] = 1
	aggregate["easy_hands"] = 10
	aggregate["hard_hands"] = 10
	aggregate["easy_finished"] = 10
	aggregate["hard_finished"] = 10
	aggregate["easy_integrity_passed"] = 10
	aggregate["hard_integrity_passed"] = 10
	aggregate["easy_score_conserved_passed"] = 10
	aggregate["hard_score_conserved_passed"] = 10
	aggregate["easy_discards"] = 100
	aggregate["hard_discards"] = 100
	return aggregate


func run() -> void:
	print("=== ai_play_round94 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame

	print("--- A) actionable all-opponent regression must fail the commercial gate ---")
	var regressed = passing_aggregate(scene)
	regressed["hard_avoidable_high_danger_discards"] = 9
	var failed_summary = scene.finalize_ai_strength_aggregate(regressed)
	check(bool(failed_summary.get("finished_all", false)), "fixture keeps terminal-hand coverage green")
	check(bool(failed_summary.get("integrity_all", false)) and bool(failed_summary.get("score_conservation_all", false)), "fixture keeps both ledgers green")
	check(not bool(failed_summary.get("hard_safer_avoidable_high_danger", true)), "nine-point avoidable-danger regression crosses the bounded tolerance")
	check(not bool(failed_summary.get("commercial_strength_ok", true)), "all-opponent avoidable danger is mandatory for commercial PASS")

	print("--- B) the documented eight-point tolerance remains inclusive ---")
	var boundary = passing_aggregate(scene)
	boundary["hard_avoidable_high_danger_discards"] = 8
	var boundary_summary = scene.finalize_ai_strength_aggregate(boundary)
	check(bool(boundary_summary.get("hard_safer_avoidable_high_danger", false)), "eight-point boundary remains accepted")
	check(bool(boundary_summary.get("commercial_strength_ok", false)), "otherwise-green boundary fixture passes the complete commercial gate")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
