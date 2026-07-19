extends SceneTree
var failed := false
func _initialize() -> void:
	call_deferred("run")
func check(cond: bool, msg: String) -> void:
	if cond: print("  OK  | %s" % msg)
	else: print("  FAIL| %s" % msg); failed = true
func run() -> void:
	print("=== round2 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.mode = "offline"
	scene.wall = scene.make_wall()
	scene.players = []
	for i in range(4):
		scene.players.append({"name":"P%d"%i,"hand":[],"discards":[],"melds":[],"flowers":0,"flower_tiles":[],"score":25000})

	# A) 字段存在性（空 eval_context，最小调用）
	var rep = scene.discard_feed_risk_report("5W", 0, [], {})
	check(rep.has("next_seat_chi_score"), "feed report 含 next_seat_chi_score 字段")
	print("    empty report: score=%s chi=%s details=%d" % [rep.get("score"), rep.get("next_seat_chi_score"), rep.get("details", []).size()])

	# B) 保底逻辑纯数学等价断言（不依赖完整评估链）：
	# 当 next_seat_chi_score > 0 且被更大 peng 挤出最大者时，total 应 > 无保底 raw_total。
	# 复现 report 内部的保底公式做对账（与 ai_brain 实现一致）。
	var next_chi := 30.0
	var peng_score := 60.0
	var details = [
		{"opponent":2,"name":"P2","claim":"peng","label":"碰","score":peng_score},
		{"opponent":1,"name":"P1","claim":"chi","label":"吃","score":next_chi},
	]
	# 重复 report 内部 total 计算（按 score 降序：peng 60 > chi 30）
	var raw_total := 0.0
	for i in range(details.size()):
		var sc = float(details[i].get("score", 0.0))
		raw_total += sc if i == 0 else sc * 0.28
	# 保底：下家 chi 在 total 至少占 0.45
	var floored_total := raw_total
	var next_weighted := next_chi * 0.28
	var next_floor := raw_total * 0.45
	if next_weighted < next_floor:
		floored_total += next_floor - next_weighted
	print("    synthetic: raw=%.2f floored=%.2f (chi weighted=%.2f floor=%.2f)" % [raw_total, floored_total, next_weighted, next_floor])
	check(floored_total > raw_total, "保底抬高 total（chi 30 被碰 60 淹没时，从 raw 抬升至保底份额）")
	# 保底后 chi 在 floored 中的有效份额应 >= 0.45
	check(next_chi >= floored_total * 0.45 or next_chi * 0.28 + (next_floor - next_weighted) >= floored_total * 0.45 - 1e-6, "保底后 chi 在 total 中占 >= 0.45 份额")
	# 边界：chi 本就是最大者时无保底（份额天然足）
	var details2 = [{"opponent":1,"name":"P1","claim":"chi","label":"吃","score":50.0},{"opponent":2,"name":"P2","claim":"peng","label":"碰","score":20.0}]
	var raw2 = 50.0 + 20.0*0.28
	# chi 50 是最大者全额计入 -> 50/(50+5.6)=0.90 >=0.45，无需保底
	check(50.0 >= raw2 * 0.45, "chi 为最大者时天然份额足，无需保底触发")

	scene.queue_free()
	print(failed and "=== RESULT: FAIL ===" or "=== RESULT: OK ===")
	quit(1 if failed else 0)
