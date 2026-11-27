extends SceneTree

var failed := false

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, detail: String) -> void:
	print(("PASS: " if condition else "FAIL: ") + detail)
	failed = failed or not condition

func run() -> void:
	var scene = load("res://Main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.fx_enabled = false
	scene.reduce_motion_enabled = true
	scene.currency = {"coins": 499, "gems": 0}
	scene.save_economy_state()
	check(not scene.exchange_coins_for_gems() and scene.currency == {"coins": 499, "gems": 0}, "insufficient coins cannot create gems or debit currency")
	scene.show_shop_screen(true)
	await process_frame
	var currency_help := scene.find_child("ShopGetGemsButton", true, false) as Button
	var shortfall := scene.find_child("ShopCabinetFooterInventoryBadge", true, false) as Label
	check(currency_help != null and currency_help.text == "铜钱获取" and shortfall != null and shortfall.text == "还差 1 铜钱", "one coin below the exchange threshold shows an exact shortfall before input")
	scene.currency = {"coins": 1000, "gems": 0}
	scene.save_economy_state()
	scene.show_shop_screen(true)
	await process_frame
	var exchange := scene.find_child("ShopGetGemsButton", true, false) as Button
	check(exchange != null and exchange.text == "兑换玉符", "sufficient coins expose the native exchange action")
	if exchange != null:
		exchange.pressed.emit()
		await process_frame
		check(scene.currency == {"coins": 1000, "gems": 0}, "first activation requests confirmation without spending")
		exchange = scene.find_child("ShopGetGemsButton", true, false) as Button
		exchange.pressed.emit()
		await process_frame
		check(scene.currency == {"coins": 500, "gems": 5}, "confirmed native exchange debits coins and credits gems together")
		var persisted := ConfigFile.new()
		check(persisted.load(scene.ECONOMY_PATH) == OK and int(persisted.get_value("currency", "coins", -1)) == 500 and int(persisted.get_value("currency", "gems", -1)) == 5, "confirmed exchange survives a fresh config read")
		exchange = scene.find_child("ShopGetGemsButton", true, false) as Button
		check(exchange != null and exchange.text == "兑换玉符", "exactly 500 coins still offers exchange")
		if exchange != null:
			exchange.pressed.emit()
			await process_frame
			check(scene.currency == {"coins": 500, "gems": 5}, "extra activation starts a fresh confirmation instead of spending twice")
		scene.shop_exchange_confirm_until_msec = Time.get_ticks_msec() - 1
		scene.request_shop_currency_exchange()
		check(scene.currency == {"coins": 500, "gems": 5}, "expired confirmation cannot perform a transaction")
	scene.inventory = {"swap_card": 0}
	check(scene.purchase_shop_item("swap_card") and scene.currency == {"coins": 500, "gems": 0} and scene.get_item_count("swap_card") == 1, "purchase atomically converts the displayed gem price into inventory")
	var purchased := ConfigFile.new()
	check(purchased.load(scene.ECONOMY_PATH) == OK and int(purchased.get_value("currency", "gems", -1)) == 0 and int(purchased.get_value("inventory", "items", {}).get("swap_card", 0)) == 1, "fresh config contains both the purchase debit and item credit")
	check(not scene.purchase_shop_item("swap_card") and scene.get_item_count("swap_card") == 1, "insufficient purchase cannot debit gems or duplicate inventory")
	scene.achievements["first_win"] = true
	scene.achievements["five_wins"] = false
	scene.game_stats["games_won"] = 3
	scene.show_achievements_screen(true)
	await process_frame
	var target := scene.find_child("AchievementsNextTargetButton", true, false) as Button
	check(target != null and str(target.get_meta("achievement_target_key", "")) == "five_wins" and "3/5" in target.text, "next achievement reflects saved wins and a locked milestone")
	if target != null:
		target.pressed.emit()
		await process_frame
		var row := scene.find_child("AchievementRow_five_wins", true, false) as Control
		var focus_target := row.find_child("AchievementRowFocusTarget", true, false) as Control
		check(focus_target != null and focus_target.has_focus(), "next achievement action focuses its native gallery row")
	var first := scene.achievement_medallion_texture("first_win", true) as AtlasTexture
	var fifth := scene.achievement_medallion_texture("mixed_one_suit", true) as AtlasTexture
	var sixth := scene.achievement_medallion_texture("big_three_dragons", false) as AtlasTexture
	check(first != null and fifth != null and sixth != null and first.region.position == Vector2.ZERO and fifth.region.position.x > 0 and sixth.region.position.y > 0 and sixth.region.position.x == 0, "achievement atlas uses distinct cells across row boundary")
	var setting := scene.make_setting_button("测试声音", true, Callable()) as Button
	check(setting.text == "关闭" and str(setting.get_meta("setting_state", "")) == "on", "enabled setting exposes disable action with actual state")
	setting.free()
	scene.tutorial_step = scene.TUTORIAL_STEP_COMPLETE
	# A resumed round can belong to another seat. Deal a fresh human-dealer
	# hand so the swap fixture uses a real current draw and its instance serial.
	scene.reset_offline_progress()
	scene.start_offline(true)
	scene.cancel_offline_ai_run()
	scene.set_process(false)
	check(scene.current_seat == 0 and scene.offline_phase == "await_discard" and int(scene.offline_self_draw_ready.get("seat", -1)) == 0, "inventory fixture starts on the human dealer's actual draw")
	scene.inventory = {"swap_card": 3, "peek_card": 1, "lucky_charm": 1, "double_coins": 0}
	scene.save_economy_state()
	var ledger_before: Dictionary = scene.offline_tile_ledger_report()
	check(bool(ledger_before.get("ok", false)), "inventory fixture starts with a conserved tile ledger")
	var wall_count := scene.wall.size() as int
	var hand_count := scene.players[0]["hand"].size() as int
	var first_drawn_tile := str(scene.offline_last_draw.get("tile", ""))
	check(scene.use_offline_inventory_item("swap_card"), "swap card replaces the actual draw on the human discard turn")
	var swapped_tile_1 := str(scene.offline_last_draw.get("tile", ""))
	check(scene.wall.size() == wall_count and scene.players[0]["hand"].size() == hand_count and bool(scene.offline_tile_ledger_report().get("ok", false)) and scene.get_item_count("swap_card") == 2, "swap preserves every tile and consumes exactly one inventory item")
	check(str(scene.wall.front()) == first_drawn_tile and (wall_count <= 1 or str(scene.wall.back()) != first_drawn_tile), "F-04: swap places the swapped-out tile at the bottom of the wall instead of the top")
	check(scene.use_offline_inventory_item("swap_card"), "F-04: second consecutive swap card succeeds on the same discard turn")
	var swapped_tile_2 := str(scene.offline_last_draw.get("tile", ""))
	check(str(scene.wall.front()) == swapped_tile_1 and (wall_count <= 2 or swapped_tile_2 != first_drawn_tile or scene.wall.count(first_drawn_tile) > 1), "F-04: second consecutive swap draws a fresh wall tile rather than reverting to the first swapped-out tile")
	scene.offline_self_draw_ready = {"seat": -1, "serial": -1}
	check(not scene.use_offline_inventory_item("swap_card") and scene.get_item_count("swap_card") == 1, "swap cannot bypass a claim turn without a current draw")

	# F-02 regression: consecutive win settlements must add 1 hand each, not offline_hand_number.
	scene.game_stats = {"games_played": 0, "games_won": 0, "win_rate": 0.0, "total_score": 0, "best_score": 0, "total_hands": 0}
	scene.applied_result_transactions.clear()
	scene.round_history_id_index.clear()
	for round_hand_num in [1, 3]:
		scene.mode = "offline"
		scene.offline_phase = "await_discard"
		scene.offline_turn_needs_draw = false
		scene.offline_sim_quiet = false
		scene.offline_hand_number = round_hand_num
		scene.active_round_id = "F02-ROUND-%d" % round_hand_num
		scene.current_seat = 0
		scene.players[0]["hand"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "1T", "1T", "E", "E"]
		scene.players[0]["melds"] = []
		scene.offline_last_draw = {"seat": 0, "tile": "E", "source": "normal", "announce": false, "serial": 900 + round_hand_num}
		scene.offline_self_draw_ready = {"seat": 0, "tile": "E", "serial": 900 + round_hand_num}
		scene.finish_offline_round(0, "E", true, -1)
	check(int(scene.game_stats.get("games_played", 0)) == 2 and int(scene.game_stats.get("total_hands", 0)) == 2, "F-02: win settlements increment total_hands by 1 per completed round instead of offline_hand_number")

	# F-03 regression: replay timeline retains and formats concealed_gang and added_gang events.
	var gang_replay_events := [
		{"sequence": 1, "type": "round_start", "dealer": 0},
		{"sequence": 2, "type": "concealed_gang", "seat": 0, "tile": "5W"},
		{"sequence": 3, "type": "added_gang", "seat": 2, "tile": "3T"},
		{"sequence": 4, "type": "win", "winner": 0, "points": 800},
	]
	var gang_visible: Array = scene.replay_timeline_visible_events({"events": gang_replay_events})
	check(gang_visible.size() == 4, "F-03: replay timeline retains concealed_gang and added_gang without dropping events")
	var concealed_line: String = scene.replay_event_line_text(gang_replay_events[1])
	var added_line: String = scene.replay_event_line_text(gang_replay_events[2])
	check(concealed_line.contains("暗杠") and concealed_line.contains("东家") and concealed_line.contains(scene.tile_label("5W")), "F-03: concealed_gang formats with label, seat, and tile")
	check(added_line.contains("补杠") and added_line.contains("西家") and added_line.contains(scene.tile_label("3T")), "F-03: added_gang formats with label, seat, and tile")

	# F-05 regression: switch_bgm_track persists current_bgm_index and load_settings bounds invalid values.
	var bgm_before := int(scene.current_bgm_index)
	scene.switch_bgm_track()
	var bgm_after := int(scene.current_bgm_index)
	var saved_settings := ConfigFile.new()
	check(saved_settings.load(scene.SETTINGS_PATH) == OK and int(saved_settings.get_value("gameplay", "current_bgm_index", -1)) == bgm_after and bgm_after == posmod(bgm_before + 1, scene.BGM_TRACKS.size()), "F-05: switch_bgm_track persists updated current_bgm_index to settings.cfg")
	saved_settings.set_value("gameplay", "current_bgm_index", 999)
	saved_settings.save(scene.SETTINGS_PATH)
	scene.load_settings()
	check(int(scene.current_bgm_index) == posmod(999, scene.BGM_TRACKS.size()), "F-05: load_settings normalizes oversized current_bgm_index safely")
	saved_settings.set_value("gameplay", "current_bgm_index", -3)
	saved_settings.save(scene.SETTINGS_PATH)
	scene.load_settings()
	check(int(scene.current_bgm_index) == posmod(-3, scene.BGM_TRACKS.size()), "F-05: load_settings normalizes negative current_bgm_index safely")

	# F-06 & F-07 regression: real JSON save/load roundtrip preserves integer seat keys,
	# hand_instance_serials, and swap_card functionality after resume (plus legacy fallback).
	scene.reset_offline_progress()
	scene.start_offline(true)
	scene.cancel_offline_ai_run()
	scene.set_process(false)
	scene.inventory = {"swap_card": 3, "peek_card": 3, "lucky_charm": 1, "double_coins": 0}
	scene.save_economy_state()
	scene.offline_claim_counts = {"0:1": 3}
	scene.offline_package_liability = {0: 1}
	scene.offline_passed_win_tiles = {0: {"5W": true}}
	scene.offline_claim_discard_bans = {0: {"9T": true}}
	scene.offline_concealed_gang_tiles = {0: {"1W": true}}
	scene.mark_offline_progress_dirty()
	scene.save_offline_progress(false)
	check(scene.offline_progress_last_save_ok, "F-06/F-07: offline progress saves cleanly before JSON roundtrip")
	var saved_payload_for_legacy: Dictionary = scene.offline_progress_state_payload()
	scene.offline_claim_counts.clear()
	scene.offline_package_liability.clear()
	scene.offline_passed_win_tiles.clear()
	scene.offline_claim_discard_bans.clear()
	scene.offline_concealed_gang_tiles.clear()
	scene.players[0]["hand_instance_serials"] = []
	check(scene.load_offline_progress(), "F-06/F-07: real JSON load_offline_progress succeeds")
	check(scene.package_payer_from_state(0) == 1 and int(scene.offline_claim_counts.get("0:1", 0)) == 3, "F-06: package liability and claim counts survive JSON roundtrip with int keys/values")
	check(scene.is_passed_win_tile(0, "5W") and scene.claim_discard_ban_snapshot_for_seat(0).has("9T") and scene.is_concealed_gang_meld(0, ["1W", "1W", "1W", "1W"]), "F-06: passed-win, kuikae discard bans, and concealed-gang menzen survive JSON roundtrip")
	var resumed_serials: Array = scene.players[0].get("hand_instance_serials", [])
	check(resumed_serials.size() == scene.players[0]["hand"].size() and resumed_serials.has(int(scene.offline_last_draw.get("serial", -1))), "F-07: resumed hand restores hand_instance_serials matching offline_last_draw")
	check(scene.use_offline_inventory_item("swap_card") and bool(scene.offline_tile_ledger_report().get("ok", false)), "F-07: swap_card succeeds after JSON resume with conserved tile ledger")
	var legacy_state: Dictionary = JSON.parse_string(JSON.stringify(saved_payload_for_legacy)) as Dictionary
	for legacy_p in legacy_state.get("players", []):
		if typeof(legacy_p) == TYPE_DICTIONARY:
			(legacy_p as Dictionary).erase("hand_instance_serials")
	check(scene.restore_offline_progress_state(legacy_state) and scene.use_offline_inventory_item("swap_card") and bool(scene.offline_tile_ledger_report().get("ok", false)), "F-07: legacy save without hand_instance_serials reconstructs draw serial for swap_card")

	# F-09 regression: peek_card does not repeatedly return hand[0] in the same round, and handles empty hand safely.
	scene.offline_peeked_tiles.clear()
	scene.players[1]["hand"] = ["1W", "2W", "3W"]
	var peek_before: int = int(scene.get_item_count("peek_card"))
	check(scene.use_offline_inventory_item("peek_card") and scene.use_offline_inventory_item("peek_card"), "F-09: two consecutive peek_card uses succeed")
	check(scene.offline_peeked_tiles.size() == 2 and scene.offline_peeked_tiles[0] != scene.offline_peeked_tiles[1] and scene.get_item_count("peek_card") == peek_before - 2, "F-09: consecutive peek_card uses show distinct unseen opponent tiles instead of repeating hand[0]")
	scene.players[1]["hand"] = []
	var peek_before_empty: int = int(scene.get_item_count("peek_card"))
	check(not scene.use_offline_inventory_item("peek_card") and scene.get_item_count("peek_card") == peek_before_empty, "F-09: peek_card refuses empty opponent hand without consuming an item")
	scene.players[1]["hand"] = ["1W", "2W", "3W"]

	scene.mode = "online_game"
	check(not scene.use_offline_inventory_item("peek_card") and scene.get_item_count("peek_card") == 1, "inventory cannot expose opponents in online matches")
	scene.mode = "offline"
	scene.open_battle_tools_menu()
	var tools_menu := scene.find_child("BattleToolsMenu", true, false) as PopupMenu
	check(tools_menu != null and tools_menu.get_item_text(0).contains("需确认"), "native tools menu exposes restart confirmation and inventory")
	if tools_menu != null:
		tools_menu.id_pressed.emit(0)
		check(scene.offline_restart_confirming, "tools menu restart requests confirmation before replacing the round")
		tools_menu.hide()
	scene.queue_free()
	for _step in range(4):
		await process_frame
	quit(1 if failed else 0)
