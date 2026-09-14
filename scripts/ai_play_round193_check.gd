extends SceneTree
## Round 193: rules sections reuse their viewport snapshot.

var failed := false


func _initialize() -> void:
	call_deferred("run")


func check(condition: bool, message: String) -> void:
	if condition:
		print("  OK  | %s" % message)
	else:
		print("  FAIL| %s" % message)
		failed = true


func run() -> void:
	print("=== ai_play_round193 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame

	var rules_root := Control.new()
	rules_root.name = "RuleSectionViewportSnapshotRoot"
	rules_root.size = Vector2(1280.0, 720.0)
	root.add_child(rules_root)
	var sections := VBoxContainer.new()
	sections.name = "RulesSections"
	rules_root.add_child(sections)
	scene.root_layer = rules_root
	var expected_viewport: Vector2 = scene.effective_viewport_size()
	scene.add_rule_section(sections, "和牌与响应", ["胡牌后按规则结算", "响应窗口按优先级处理"], 0)
	var section := sections.get_node_or_null("RuleSection_0") as Control
	var title := section.find_child("RuleSectionTitle_0", true, false) as Label if section != null else null
	check(section != null and section.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport, "规则章节发布本次绘制的 viewport 快照")
	check(section != null and str(section.get_meta("viewport_snapshot_policy", "")) == "one_viewport_snapshot_per_draw", "规则章节声明每次绘制只读取一次 viewport")
	check(title != null and title.text != "", "规则章节标题和正文仍完整构建")
	scene.large_text_enabled = true
	check(section != null and section.get_meta("viewport_snapshot", Vector2.ZERO) == expected_viewport, "后续阅读状态不会改写已完成的规则章节快照")

	rules_root.queue_free()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
