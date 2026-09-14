extends SceneTree
## Round 115: the BGM watchdog throttles runtime availability checks.

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
	print("=== ai_play_round115 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.music_enabled = true
	scene.next_bgm_retry_msec = 0
	scene.bgm_start_in_flight = false

	print("--- A) unavailable runtime retry deadline ---")
	scene.keep_background_music_alive(1000)
	check(scene.next_bgm_retry_msec == 2000, "unavailable runtime audio schedules a one-second retry")
	scene.keep_background_music_alive(1500)
	check(scene.next_bgm_retry_msec == 2000, "watchdog keeps the deadline without another runtime check")
	scene.keep_background_music_alive(2000)
	check(scene.next_bgm_retry_msec == 3000, "watchdog retries only when the deadline arrives")

	print("--- B) async startup guard ---")
	scene.next_bgm_retry_msec = 0
	scene.bgm_start_in_flight = true
	scene.keep_background_music_alive(3000)
	check(scene.next_bgm_retry_msec == 0, "watchdog exits before the runtime query during async startup")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
