extends SceneTree

const OUTPUT_PATH := "res://build/qa/ui-preview-current.png"

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var scene = load("res://Main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.start_offline()
	seed_preview_discards(scene)
	scene.render_game()
	await process_frame
	await process_frame
	var image = root.get_texture().get_image()
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
