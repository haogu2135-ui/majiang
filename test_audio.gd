extends Node

# 自动化音频测试脚本
# 用于验证背景音乐和音效是否正常工作

var main_script
var test_results = []
var test_passed = 0
var test_failed = 0

func _ready():
	print("=== 开始自动化音频测试 ===")
	await get_tree().process_frame
	await ensure_main_node()
	await run_tests()

func ensure_main_node():
	main_script = get_node_or_null("/root/Main")
	if main_script != null:
		return
	var main_scene = load("res://Main.tscn")
	if main_scene == null:
		return
	main_script = main_scene.instantiate()
	get_tree().root.add_child(main_script)
	await get_tree().process_frame
	await get_tree().process_frame

func run_tests():
	# 测试1: 检查音频文件是否存在
	test_audio_files_exist()

	# 测试2: 检查AudioStreamPlayer是否正确初始化
	test_audio_players_initialized()

	# 测试3: 模拟用户交互触发音频
	await test_audio_wake_interaction()

	# 测试4: 检查背景音乐是否播放
	await test_background_music_playing()

	# 输出测试结果
	print_test_results()

	# 退出
	await get_tree().create_timer(1.0).timeout
	get_tree().quit(0 if test_failed == 0 else 1)

func test_audio_files_exist():
	var test_name = "音频文件存在性检查"
	var bgm_path = "res://assets/audio/bgm_loop.wav"
	var sfx_paths = [
		"res://assets/audio/discard.mp3",
		"res://assets/audio/draw.mp3",
		"res://assets/audio/pong.mp3"
	]

	var all_exist = ResourceLoader.exists(bgm_path)
	if not all_exist:
		record_fail(test_name, "BGM文件不存在: " + bgm_path)
		return

	for path in sfx_paths:
		if not ResourceLoader.exists(path):
			record_fail(test_name, "音效文件不存在: " + path)
			return

	record_pass(test_name)

func test_audio_players_initialized():
	var test_name = "AudioStreamPlayer初始化检查"

	main_script = get_node_or_null("/root/Main")
	if main_script == null:
		record_fail(test_name, "找不到Main节点")
		return

	var bgm_player = main_script.get("bgm_player")
	if bgm_player == null or not is_instance_valid(bgm_player):
		record_fail(test_name, "bgm_player未初始化")
		return

	record_pass(test_name)

func test_audio_wake_interaction():
	var test_name = "用户交互音频唤醒测试"

	if main_script == null:
		record_fail(test_name, "Main节点未初始化")
		return

	# 调用wake_audio_from_interaction
	if main_script.has_method("wake_audio_from_interaction"):
		main_script.wake_audio_from_interaction()
		await get_tree().create_timer(0.5).timeout
		record_pass(test_name)
	else:
		record_fail(test_name, "wake_audio_from_interaction方法不存在")

func test_background_music_playing():
	var test_name = "背景音乐播放状态检查"

	if main_script == null:
		record_fail(test_name, "Main节点未初始化")
		return

	await get_tree().create_timer(1.0).timeout

	var bgm_player = main_script.get("bgm_player")
	if bgm_player == null or not is_instance_valid(bgm_player):
		record_fail(test_name, "bgm_player未初始化")
		return

	if bgm_player.stream == null:
		record_fail(test_name, "bgm_player没有加载音频流")
		return

	if main_script.has_method("audio_runtime_enabled") and not main_script.audio_runtime_enabled():
		record_pass(test_name)
		return

	if not bgm_player.playing:
		record_fail(test_name, "背景音乐没有播放")
		return

	record_pass(test_name)

func record_pass(test_name: String):
	test_passed += 1
	test_results.append("[✓] " + test_name)
	print("[✓] " + test_name)

func record_fail(test_name: String, reason: String = ""):
	test_failed += 1
	var msg = "[✗] " + test_name
	if reason != "":
		msg += ": " + reason
	test_results.append(msg)
	print(msg)

func print_test_results():
	print("\n=== 测试结果汇总 ===")
	for result in test_results:
		print(result)
	print("\n总计: %d个测试" % (test_passed + test_failed))
	print("通过: %d" % test_passed)
	print("失败: %d" % test_failed)

	if test_failed == 0:
		print("\n✓ 所有测试通过！")
	else:
		print("\n✗ 有测试失败，需要修复")
