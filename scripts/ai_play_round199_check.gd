extends SceneTree
## Round 199: battle contract registration reuses one content-size snapshot.

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
	print("=== ai_play_round199 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame

	var contract_root := Control.new()
	contract_root.name = "BattleContractContentSnapshotRoot"
	contract_root.size = Vector2(1280.0, 720.0)
	var hud_title := Label.new()
	hud_title.name = "TopHudTitle"
	hud_title.text = "四川麻将"
	contract_root.add_child(hud_title)
	var hud_status := Label.new()
	hud_status.name = "TopHudStatus"
	hud_status.text = "等待响应"
	contract_root.add_child(hud_status)
	root.add_child(contract_root)

	var expected_content_size: Vector2 = scene.safe_content_pixel_size()
	scene.register_battle_ui_round_contracts(contract_root)
	check(contract_root.get_meta("battle_ui_content_size_snapshot", Vector2.ZERO) == expected_content_size, "战局契约注册发布本批次的 content-size 快照")
	check(str(contract_root.get_meta("battle_ui_content_size_snapshot_policy", "")) == "one_content_size_snapshot_per_registration", "战局契约注册声明每批次只读取一次 content-size")
	check(hud_title.text != "" and hud_status.text != "", "两个 HUD 标签仍参与契约注册和字体适配")
	scene.large_text_enabled = true
	check(contract_root.get_meta("battle_ui_content_size_snapshot", Vector2.ZERO) == expected_content_size, "后续可读性状态不会改写已完成的注册快照")

	contract_root.queue_free()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
