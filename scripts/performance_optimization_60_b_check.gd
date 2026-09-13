extends SceneTree
## Focused regression checks for the second CPU optimization batch.

var failed := false


func _initialize() -> void:
	call_deferred("run")


func check(condition: bool, message: String) -> void:
	if condition:
		print("  OK  | %s" % message)
	else:
		print("  FAIL| %s" % message)
		failed = true


func make_archive_fixture(scene, round_id: String, event_type: String) -> Dictionary:
	scene.active_round_id = round_id
	scene.round_event_sequence = 0
	scene.round_event_history = []
	scene.offline_sim_quiet = false
	scene.record_round_event(event_type, {"value": round_id})
	var events: Array = scene.round_event_history.duplicate(true)
	return {
		"round_id": round_id,
		"rule_variant": scene.RULE_VARIANT_YANGZHOU,
		"result_kind": "win",
		"summary": "CPU archive %s" % round_id,
		"seed": 6060,
		"events": events,
		"replay_digest": scene.round_replay_digest(events),
		"replay_valid": true,
		"source": "local",
		"saved_at": 6060,
		"archived_at": 6060,
	}


func run() -> void:
	print("=== performance optimization 60 B check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()

	print("--- A) replay archive index ---")
	var saved_archive: Array = scene.replay_archive.duplicate(true)
	scene.replay_archive = []
	scene.replay_archive_id_index.clear()
	var first: Dictionary = make_archive_fixture(scene, "CPU-ARCHIVE-A", "draw")
	var second: Dictionary = make_archive_fixture(scene, "CPU-ARCHIVE-B", "win")
	check(scene.upsert_replay_archive_entry(first, false), "archive upsert inserts the first verified entry")
	check(scene.upsert_replay_archive_entry(second, false), "archive upsert inserts a second verified entry")
	var first_id: String = scene.replay_archive_entry_id(first)
	var second_id: String = scene.replay_archive_entry_id(second)
	check(scene.replay_archive_id_index.get(first_id, -1) == 0 and scene.replay_archive_id_index.get(second_id, -1) == 1, "archive index records both array positions")
	check(scene.replay_archive_entry(second_id).get("round_id", "") == "CPU-ARCHIVE-B", "archive lookup uses the indexed entry")
	var updated_first := first.duplicate(true)
	updated_first["summary"] = "CPU archive A updated"
	check(scene.upsert_replay_archive_entry(updated_first, false) and scene.replay_archive.size() == 2 and scene.replay_archive_entry(first_id).get("summary", "") == "CPU archive A updated", "archive update replaces an indexed entry without appending a duplicate")
	check(not scene.upsert_replay_archive_entry(updated_first, false), "archive duplicate upsert avoids rebuilding an unchanged entry")
	scene.toggle_replay_archive_favorite(second_id)
	check(bool(scene.replay_archive_entry(second_id).get("favorite", false)), "favorite update uses the archive index")
	scene.request_delete_replay_archive(first_id)
	scene.request_delete_replay_archive(first_id)
	check(scene.replay_archive.size() == 1 and scene.replay_archive_index_for_id(second_id) == 0, "delete rebuilds shifted archive indexes")

	print("--- B) toast queue indexes ---")
	scene.toast_queue.clear()
	scene.toast_queue_text_index.clear()
	scene.toast_queue_pending_count = 0
	scene.toast_queue_pending_bytes = 0
	check(scene.enqueue_toast_message("重复通知", 1000), "toast queue accepts the first message")
	check(scene.enqueue_toast_message("重复通知", 1200), "toast queue merges a duplicate in O(1)")
	var queued: Dictionary = scene.toast_queue_text_index.get("重复通知", {})
	check(scene.toast_queue.size() == 1 and int(queued.get("count", 0)) == 2 and scene.toast_queue_pending_count == 2, "toast duplicate count and text index stay synchronized")
	scene.evict_toast_queue_entry(0)
	check(scene.toast_queue.is_empty() and not scene.toast_queue_text_index.has("重复通知") and scene.toast_queue_pending_count == 0, "toast eviction removes its text index entry")

	print("--- C) empty UI cache ---")
	var focus_root := Control.new()
	root.add_child(focus_root)
	var stale_button := Button.new()
	stale_button.name = "StaleButton"
	focus_root.add_child(stale_button)
	scene.configure_button_focus_navigation(focus_root)
	stale_button.queue_free()
	await process_frame
	scene.configure_button_focus_navigation(focus_root)
	check(not is_instance_valid(stale_button), "button focus cache skips freed controls before casting")
	focus_root.queue_free()
	var empty_root := Control.new()
	check(scene.cached_ui_control_list(empty_root).is_empty(), "empty UI tree returns an empty control list")
	var first_scan_count := int(empty_root.get_meta("ui_contract_index_scan_count", 0))
	scene.cached_ui_control_list(empty_root)
	check(int(empty_root.get_meta("ui_contract_index_scan_count", 0)) == first_scan_count, "empty UI tree reuses its valid cached list")
	empty_root.free()

	scene.replay_archive = saved_archive
	scene.rebuild_replay_archive_id_index()
	scene.save_replay_archive()
	scene.dismiss_active_toast()
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
