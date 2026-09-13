extends SceneTree
## Focused regression checks for the 60-item CPU optimization ledger.

var failed := false


func _initialize() -> void:
	call_deferred("run")


func check(condition: bool, message: String) -> void:
	if condition:
		print("  OK  | %s" % message)
	else:
		print("  FAIL| %s" % message)
		failed = true


func make_player(name: String) -> Dictionary:
	return {
		"name": name,
		"hand": [],
		"discards": [],
		"melds": [],
		"flowers": 0,
		"flower_tiles": [],
		"score": 25000,
		"bot": true,
	}


func run() -> void:
	print("=== performance optimization 60 check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()

	print("--- A) bounded message identity FIFO ---")
	scene.online_seen_message_ids.clear()
	scene.online_seen_message_id_order.clear()
	scene.online_seen_message_id_order_head = 0
	for i in range(scene.ONLINE_SEEN_EVENT_LIMIT + 260):
		scene.remember_online_message_identity("message-%03d" % i)
	check(scene.online_seen_message_ids.size() == scene.ONLINE_SEEN_EVENT_LIMIT, "message identity map remains bounded")
	check(not scene.online_seen_message_ids.has("message-000") and scene.online_seen_message_ids.has("message-260"), "message FIFO evicts the oldest identity")
	check(not scene.remember_online_message_identity("message-260"), "message duplicate lookup remains O(1) and rejects repeats")
	scene.online_seen_message_ids.clear()
	scene.remember_online_message_identity("fresh")
	check(scene.online_seen_message_id_order.size() == 1 and scene.online_seen_message_id_order_head == 0, "message FIFO repairs stale order state after external clear")

	print("--- B) bounded voice sequence FIFO ---")
	scene.online_seen_voice_sequences.clear()
	scene.online_seen_voice_sequence_order.clear()
	scene.online_seen_voice_sequence_order_head = 0
	for i in range(scene.ONLINE_SEEN_EVENT_LIMIT + 260):
		scene.remember_online_voice_sequence("voice-%03d" % i)
	check(scene.online_seen_voice_sequences.size() == scene.ONLINE_SEEN_EVENT_LIMIT, "voice sequence map remains bounded")
	check(not scene.online_seen_voice_sequences.has("voice-000") and scene.online_seen_voice_sequences.has("voice-260"), "voice FIFO evicts the oldest sequence")

	print("--- C) canonical lookup and gameplay equivalence ---")
	check(scene.tile_array_key(["m1", "1W", "E"]) == "1W2,E1", "tile keys normalize aliases once and preserve counts")
	var chi_counts = scene.tile_counts(["2W", "4W"])
	var chi_choices = scene.get_chi_choices_from_counts(chi_counts, "m3")
	check(chi_choices.size() == 1 and (chi_choices[0] as Dictionary).get("needed", []) == ["2W", "4W"], "chi choices keep canonical behavior for aliases")
	scene.players = [make_player("P0"), make_player("P1"), make_player("P2"), make_player("P3")]
	scene.players[0]["hand"] = ["5W"]
	scene.players[0]["melds"] = [["5W", "5W", "5W"]]
	check(scene.first_added_gang_tile(0) == "5W", "added-gang scan returns the first legal tile")

	print("--- D) linked-list LRU behavior ---")
	var cache: Dictionary = {"a": 1, "b": 2}
	var lru: Dictionary = {}
	scene.touch_cache_key(lru, "a")
	scene.touch_cache_key(lru, "b")
	scene.touch_cache_key(lru, "a")
	scene.evict_cache_key(lru, cache)
	check(cache.has("a") and not cache.has("b"), "generic LRU evicts the least recently used entry")

	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
