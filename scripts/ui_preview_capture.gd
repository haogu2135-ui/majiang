extends SceneTree

const OUTPUT_PATH := "res://build/qa/ui-preview-current.png"

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var scene = load("res://Main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.start_offline(true)
	seed_preview_discards(scene)
	seed_preview_pending_claim(scene)
	scene.render_game()
	await process_frame
	await process_frame
	if DisplayServer.get_name().to_lower() == "headless":
		print("skipped preview capture: screenshots require a non-headless display driver")
		quit(0)
		return
	var viewport_texture = root.get_texture()
	if viewport_texture == null:
		printerr("failed to save preview: viewport texture is unavailable in this display driver")
		quit(1)
		return
	var image = viewport_texture.get_image()
	if image == null:
		printerr("failed to save preview: viewport image is unavailable in this display driver")
		quit(1)
		return
	var output_dir = ProjectSettings.globalize_path("res://build/qa")
	DirAccess.make_dir_recursive_absolute(output_dir)
	var output_path = ProjectSettings.globalize_path(OUTPUT_PATH)
	var err = image.save_png(output_path)
	if err != OK:
		printerr("failed to save preview: %s" % error_string(err))
		quit(1)
		return
	print("saved preview: " + output_path)
	quit(0)

func seed_preview_discards(scene: Node) -> void:
	var preview_discards := [
		["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "E", "S"],
		["1T", "2T", "3T", "4T", "5T", "6T", "7T", "8T"],
		["1B", "2B", "3B", "4B", "5B", "6B", "7B", "8B", "9B"],
		["Z", "F", "P", "R", "N", "E", "S"],
	]
	for seat in range(preview_discards.size()):
		scene.players[seat]["discards"] = preview_discards[seat].duplicate()
	scene.last_discard = "S"
	scene.last_discard_seat = 3
	scene.current_seat = 0
	scene.offline_phase = "await_discard"
	scene.table_logs.clear()
	scene.add_log("预览：弃牌区使用真实牌面贴图。")

func seed_preview_pending_claim(scene: Node) -> void:
	scene.offline_phase = "pending_claim"
	scene.players[0]["hand"] = ["1W", "2W", "3W", "3W", "4W", "5W", "5T", "6T", "7T", "E", "E", "P", "P"]
	scene.offline_pending_claim = {
		"from_seat": 3,
		"tile": "3W",
		"options": ["chi", "peng"],
		"chi_choices": scene.get_chi_choices(scene.players[0]["hand"], "3W"),
	}
	scene.add_log("预览：响应插画展示吃碰选择。")
