extends SceneTree
## Round 203: top HUD identity reuses one viewport snapshot.

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
	print("=== ai_play_round203 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame

	var hud_root := Control.new()
	hud_root.name = "TopHudViewportSnapshotRoot"
	hud_root.size = Vector2(1280.0, 720.0)
	root.add_child(hud_root)
	scene.root_layer = hud_root
	scene.mode = "offline"
	while scene.players.size() < 4:
		scene.players.append({"name": "玩家", "score": 8000, "hand": [], "discards": [], "melds": [], "flowers": 0})

	var live_viewport: Vector2 = scene.effective_viewport_size()
	var compact_viewport := Vector2(960.0, 540.0)
	var fallback_signature: String = scene.battle_top_hud_identity_signature()
	var explicit_signature: String = scene.battle_top_hud_identity_signature(live_viewport)
	var compact_signature: String = scene.battle_top_hud_identity_signature(compact_viewport)
	check(explicit_signature == fallback_signature, "top HUD signature preserves the live fallback result")
	check(compact_signature != fallback_signature, "top HUD signature consumes an explicit viewport snapshot")

	scene.draw_game_top_hud(hud_root)
	var hud := hud_root.get_node_or_null("TopHud3DShell") as Control
	check(hud != null and hud.get_meta("viewport_snapshot", Vector2.ZERO) == live_viewport, "top HUD publishes the viewport snapshot used by its signature")
	check(hud != null and str(hud.get_meta("viewport_snapshot_policy", "")) == "one_snapshot_per_hud_build", "top HUD keeps one viewport snapshot per build")

	var saved_viewport: Vector2 = hud.get_meta("viewport_snapshot", Vector2.ZERO) if hud != null else Vector2.ZERO
	scene.large_text_enabled = true
	check(hud != null and hud.get_meta("viewport_snapshot", Vector2.ZERO) == saved_viewport, "later state changes do not rewrite the completed HUD viewport snapshot")

	hud_root.queue_free()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
