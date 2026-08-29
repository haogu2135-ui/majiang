extends SceneTree

var failed := false


func _initialize() -> void:
	call_deferred("run")


func check(condition: bool, message: String) -> void:
	if condition:
		print("  OK  | %s" % message)
	else:
		print("  FAIL| %s" % message)
		failed = true


func settle() -> void:
	await process_frame
	await process_frame


func screen_rect(control: Control) -> Rect2:
	return Rect2(control.get_global_position(), control.size)


func toast_text(scene: Node) -> String:
	var toast := scene.toast_current as Control
	if toast == null or not is_instance_valid(toast):
		return ""
	for candidate in toast.find_children("*", "Label", true, false):
		var label := candidate as Label
		if label != null and label.text != "":
			return label.text
	return ""


func run() -> void:
	var scene = load("res://Main.tscn").instantiate()
	root.add_child(scene)
	await settle()
	scene.fx_enabled = false

	var saved_consent := bool(scene.telemetry_consent)
	var saved_decided := bool(scene.telemetry_consent_decided)
	var saved_outbox: Array = scene.telemetry_outbox.duplicate(true)
	var saved_sequence := int(scene.telemetry_event_sequence)

	scene.telemetry_consent = false
	scene.telemetry_consent_decided = false
	scene.telemetry_outbox = []
	scene.telemetry_event_sequence = 0
	scene.settings_panel_open = false
	scene.show_menu(true)
	scene.settings_panel_open = true
	scene.refresh_current_screen()
	scene.show_telemetry_data_sheet()
	await settle()

	var sheet := scene.find_child("TelemetryDataSheet", true, false) as Control
	var card := scene.find_child("TelemetryDataSheetCard", true, false) as Control
	var title := scene.find_child("TelemetryDataSheetTitle", true, false) as Label
	var body := scene.find_child("TelemetryDataSheetBody", true, false) as Label
	var status := scene.find_child("TelemetryDataStatus", true, false) as Label
	var export_status := scene.find_child("TelemetryExportStatus", true, false) as Label
	var consent_button := scene.find_child("TelemetryConsentButton", true, false) as Button
	var export_button := scene.find_child("TelemetryExportButton", true, false) as Button
	var clear_button := scene.find_child("TelemetryClearButton", true, false) as Button
	var close_button := scene.find_child("TelemetryDataSheetCloseButton", true, false) as Button
	check(sheet != null and card != null and title != null and body != null and status != null and export_status != null and consent_button != null and export_button != null and clear_button != null and close_button != null, "telemetry sheet exposes the complete privacy and diagnostics surface")
	if sheet == null or card == null or title == null or body == null or status == null or export_status == null or consent_button == null or export_button == null or clear_button == null or close_button == null:
		finish(scene, saved_consent, saved_decided, saved_outbox, saved_sequence)
		return

	var viewport_rect := Rect2(Vector2.ZERO, scene.effective_viewport_size())
	var card_rect := screen_rect(card)
	check(viewport_rect.grow(-2.0).encloses(card_rect), "telemetry reading card stays inside the viewport")
	for control in [title, body, status, export_status, consent_button, export_button, clear_button, close_button]:
		check(card_rect.grow(1.0).encloses(screen_rect(control)), "telemetry control %s stays inside the reading card" % control.name)
	check(body.autowrap_mode == TextServer.AUTOWRAP_WORD_SMART and body.clip_text, "telemetry explanation wraps and clips safely")
	check(consent_button.custom_minimum_size.y >= 44.0 and export_button.custom_minimum_size.y >= 44.0 and clear_button.custom_minimum_size.y >= 44.0, "telemetry actions retain touch-sized minimum heights")
	check(status.text == "未同意 · 默认不记录" and export_status.text == "导出：未导出" and consent_button.text == "同意记录", "telemetry defaults to an explicit no-record state")

	scene.toggle_telemetry_consent()
	await settle()
	check(scene.telemetry_consent and scene.telemetry_consent_decided and scene.telemetry_outbox.size() == 1, "telemetry consent records one local consent event")
	check(status.text == "已同意 · 本地队列 1 条" and consent_button.text == "关闭记录", "telemetry sheet refreshes to the consented state")

	scene.clear_telemetry_data()
	await settle()
	check(scene.telemetry_outbox.is_empty() and status.text == "已同意 · 本地队列 0 条", "clearing telemetry removes the local queue and refreshes status")

	check(scene.telemetry_record_event("round_started", {"rule_variant": "yangzhou", "difficulty": "QA", "hand_number": 1}), "consented telemetry accepts an allowed minimal event")
	check(scene.export_telemetry_data(), "telemetry export completes without an upload dependency")
	await settle()
	check(export_status.text.contains("已复制") and scene.telemetry_outbox.size() == 1, "telemetry export exposes a confirmation without changing the queue")

	scene.toggle_telemetry_consent()
	await settle()
	check(not scene.telemetry_consent and scene.telemetry_consent_decided and scene.telemetry_outbox.is_empty(), "revoking telemetry consent clears all local events")
	check(status.text == "已关闭 · 不记录" and consent_button.text == "同意记录", "telemetry sheet exposes the revoked state")
	check(not scene.telemetry_record_event("round_started", {"rule_variant": "yangzhou", "difficulty": "QA", "hand_number": 2}), "revoked telemetry rejects new events")

	scene.close_telemetry_data_sheet()
	await settle()
	check(scene.find_child("TelemetryDataSheet", true, false) == null and not scene.telemetry_sheet_open, "telemetry sheet closes cleanly and clears its modal state")
	finish(scene, saved_consent, saved_decided, saved_outbox, saved_sequence)


func finish(scene: Node, saved_consent: bool, saved_decided: bool, saved_outbox: Array, saved_sequence: int) -> void:
	scene.telemetry_consent = saved_consent
	scene.telemetry_consent_decided = saved_decided
	scene.telemetry_outbox = saved_outbox
	scene.telemetry_event_sequence = saved_sequence
	scene.save_telemetry_state()
	scene.save_settings()
	if scene.has_method("shutdown_runtime"):
		scene.shutdown_runtime()
	scene.queue_free()
	await process_frame
	if failed:
		quit(1)
	else:
		print("ui telemetry smoke test passed")
		quit(0)
