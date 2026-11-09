extends "res://scripts/ui_interaction_smoke_test.gd"


func run() -> void:
	print("=== ui lobby feedback smoke START ===")
	OS.set_environment("YUNZHUO_UI_CAPTURE", "1")
	root.size = Vector2i(1280, 720)
	root.content_scale_size = Vector2i(1280, 720)
	var scene = load("res://Main.tscn").instantiate()
	scene.music_enabled = false
	scene.sfx_enabled = false
	scene.tts_enabled = false
	scene.fx_enabled = false
	root.add_child(scene)
	await settle(0.10)
	var snapshot := capture_smoke_state(scene)
	scene.tcp = ConnectedLobbyTransport.new()
	scene.tcp_status = StreamPeerTCP.STATUS_CONNECTED
	scene.selected_room = "ROOM7"
	scene.online_room = {
		"code": "ROOM7",
		"hostSeat": 0,
		"youSeat": 0,
		"players": [
			{"seat": 0, "name": "甲", "ready": true},
			{"seat": 1, "name": "乙", "ready": true},
			{"seat": 2, "name": "丙", "ready": true},
		],
		"logs": ["房间同步完成，等待房主开始。"],
	}
	scene.online_feedback = "房间同步完成，等待房主开始。"
	scene.online_waiting_for_server = false
	scene._show_online_lobby_impl()
	await settle(0.10)
	var feedback := scene.find_child("OnlineLobbyFormFeedbackLabel", true, false) as Label
	var reason := scene.find_child("OnlineLobbyStartGateReason", true, false) as Label
	var start_button := scene.find_child("OnlineLobbyPrimaryStartButton", true, false) as Button
	var logs := scene.find_child("OnlineLobbyLogListText", true, false) as RichTextLabel
	check(feedback != null and reason != null and start_button != null, "lobby exposes feedback, current gate, and the native start action")
	if feedback != null and reason != null and start_button != null:
		check(feedback.text.contains("3/4") and not feedback.text.contains("等待房主"), "three-seat lobby replaces stale host-ready feedback with the actual occupancy gate")
		check(logs != null and logs.text.contains("等待房主"), "historical feedback remains available in the room log")
		scene.online_room["players"].pop_back()
		scene.refresh_online_lobby_state()
		await settle(0.03)
		check(feedback.text.contains("2/4") and reason.text.contains("2/4") and start_button.tooltip_text.contains("2/4"), "same start label refreshes its reason when occupancy changes from three to two")
		scene.online_room["players"].append({"seat": 2, "name": "丙", "ready": true})
		scene.online_room["players"].append({"seat": 3, "name": "丁", "ready": false})
		scene.refresh_online_lobby_state()
		await settle(0.03)
		check(start_button.text == "等准备" and feedback.text.contains("准备") and not feedback.text.contains("等待房主"), "four-seat unready lobby uses the preparation gate rather than stale host feedback")
		scene.online_room["players"][3]["ready"] = true
		scene.online_room["youSeat"] = 1
		scene.refresh_online_lobby_state()
		await settle(0.03)
		check(start_button.text == "等房主" and feedback.text.contains("等待房主"), "ready nonhost lobby explicitly waits for the host")
		scene.online_room["youSeat"] = 0
		scene.refresh_online_lobby_state()
		await settle(0.03)
		check(not start_button.disabled and feedback.text.contains("房主可开始") and not feedback.text.contains("等待房主"), "ready host lobby replaces stale wait feedback with its enabled start action")
		for error_text in ["房间同步失败：请重试", "服务器拒绝：等待房主开始无效", "房间同步异常：请检查连接"]:
			scene.online_feedback = error_text
			scene.refresh_online_lobby_action_states()
			check(feedback.text == error_text and feedback.tooltip_text.contains(error_text), "gate copy cannot swallow server feedback: %s" % error_text)
		scene.online_room["players"].pop_back()
		scene.online_feedback = "房间同步失败：请重试"
		scene.refresh_online_lobby_action_states()
		check(feedback.text == scene.online_feedback, "blocked-start lobby also preserves synchronization errors")
		scene.online_room.clear()
		scene.selected_room = ""
		scene.online_room_edit.text = ""
		scene.online_feedback = ""
		scene.refresh_online_lobby_state()
		await settle(0.03)
		check(feedback.text.contains("创建可用") and feedback.text.contains("加入需房号"), "connected empty-room lobby distinguishes create from join requirements")
		check(feedback.get_theme_font_size("font_size") >= 12, "default conditions keep the 12px reading budget at 1280x720")
	if scene.has_method("shutdown_runtime"):
		scene.shutdown_runtime()
	restore_smoke_state(scene, snapshot)
	scene.queue_free()
	await process_frame
	print("=== RESULT: %s ===" % ("FAIL" if failed else "OK"))
	quit(1 if failed else 0)
