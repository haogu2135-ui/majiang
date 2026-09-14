extends SceneTree
## Round 196: AI evaluation contexts reuse the visible-count state key.

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
	print("=== ai_play_round196 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame

	scene.mode = "offline"
	var visible_counts: Array = scene.visible_tile_counts_shared()
	var live_state_key: String = scene.visible_tile_counts_cache_key
	var context: Dictionary = scene.make_ai_evaluation_context(0)
	check(context.get("visible_counts") == visible_counts, "AI 上下文仍复用共享的可见牌快照")
	check(str(context.get("visible_state_cache_key", "")) == live_state_key, "无参 AI 上下文复用已发布的可见牌状态键")
	check(str(context.get("visible_state_cache_key", "")) == scene.visible_tile_counts_cache_key, "复用后的状态键仍与可见牌缓存保持一致")
	var explicit_context: Dictionary = scene.make_ai_evaluation_context(0, visible_counts.duplicate(false))
	check(str(explicit_context.get("visible_state_cache_key", "")) == live_state_key, "显式可见牌快照保留实时状态键回退")
	check(explicit_context.get("visible_counts") != null and explicit_context.get("known_counts") != null, "显式快照上下文仍完整构建已知牌数据")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
