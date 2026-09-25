extends SceneTree

var failed := false


func _initialize() -> void:
	call_deferred("run")


func check(condition: bool, message: String) -> void:
	if condition:
		print("  OK  | %s" % message)
	else:
		print("  FAIL| %s" % message)
		failed = true


func set_scores(scene, scores: Array) -> void:
	scene.players = []
	for seat in range(scores.size()):
		scene.players.append({"score": int(scores[seat])})


func run() -> void:
	print("=== ai_play_round288 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.mode = "offline"
	scene.ai_difficulty = scene.AI_DIFFICULTY_HARD
	scene.offline_hand_number = scene.MATCH_MAX_HANDS
	set_scores(scene, [36000, 42000, 27000, 25000])
	var second_place_context: Dictionary = scene.score_context_report(0)
	var second_place_attack: float = scene.score_attack_multiplier(0)
	var second_place_defense: float = scene.score_defense_adjustment(0)
	print("    late second-place context=%s attack=%.3f defense=%.3f" % [str(second_place_context), second_place_attack, second_place_defense])
	check(int(second_place_context.get("rank", 0)) == 2, "probe seat is ranked second")
	check(int(second_place_context.get("leader_gap", 0)) == -6000, "second-place gap is measured against the leader")
	check(int(second_place_context.get("target_rank", 0)) == 1 and int(second_place_context.get("target_seat", -1)) == 1 and int(second_place_context.get("target_gap", 0)) == -6000, "second place targets the leader")
	check(str(second_place_context.get("strategy", "")) == "追分", "late second place adopts chase strategy")
	check(second_place_attack > 1.0, "late second place increases attack priority")
	check(second_place_defense < 0.0, "late second place reduces defensive bias")

	set_scores(scene, [40000, 41000, 32000, 28000])
	var close_gap_context: Dictionary = scene.score_context_report(0)
	check(int(close_gap_context.get("rank", 0)) == 2, "close-gap probe remains second place")
	check(str(close_gap_context.get("strategy", "")) == "均衡", "small leader gap does not force a chase")
	check(is_equal_approx(scene.score_attack_multiplier(0), 1.0), "small leader gap keeps baseline attack")
	check(is_equal_approx(scene.score_defense_adjustment(0), 0.0), "small leader gap keeps baseline defense")

	set_scores(scene, [50000, 30000, 29000, 10000])
	var close_third_context: Dictionary = scene.score_context_report(2)
	var close_third_attack: float = scene.score_attack_multiplier(2)
	var close_third_defense: float = scene.score_defense_adjustment(2)
	var close_third_base_attack: float = close_third_attack / scene.human_relative_attack_bias(2)
	var close_third_base_defense: float = close_third_defense - scene.human_relative_defense_bias(2)
	print("    late third-place context=%s attack=%.3f defense=%.3f" % [str(close_third_context), close_third_attack, close_third_defense])
	check(int(close_third_context.get("rank", 0)) == 3 and int(close_third_context.get("leader_gap", 0)) == -21000, "third-place report preserves its gap to the leader")
	check(int(close_third_context.get("target_rank", 0)) == 2 and int(close_third_context.get("target_seat", -1)) == 1 and int(close_third_context.get("target_gap", 0)) == -1000, "third place targets the adjacent second-place seat")
	check(str(close_third_context.get("strategy", "")) == "追分", "third place still chases a nearby higher rank")
	check(close_third_base_attack < 1.12, "third-place chase intensity follows the 1000-point adjacent gap")
	check(close_third_base_defense < -0.07 and close_third_base_defense > -0.09, "third-place defense adjustment follows the adjacent gap")
	check(scene.score_strategy_text(2).contains("落后1000"), "third-place strategy text shows the adjacent-rank gap")

	set_scores(scene, [50000, 30000, 29000, 10000])
	var fourth_context: Dictionary = scene.score_context_report(3)
	check(int(fourth_context.get("rank", 0)) == 4 and int(fourth_context.get("target_rank", 0)) == 3, "fourth place targets third place")
	check(int(fourth_context.get("target_seat", -1)) == 2 and int(fourth_context.get("target_gap", 0)) == -19000, "fourth-place target gap measures distance to third")

	scene.offline_hand_number = 1
	var early_context: Dictionary = scene.score_context_report(0)
	check(str(early_context.get("strategy", "")) == "均衡", "early second place does not switch to chase")
	check(is_equal_approx(scene.score_attack_multiplier(0), 1.0), "early second place keeps baseline attack")
	check(is_equal_approx(scene.score_defense_adjustment(0), 0.0), "early second place keeps baseline defense")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
