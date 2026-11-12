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
	scene.currency = {"coins": 1000, "gems": 0}
	scene.save_economy_state()
	scene.show_shop_screen(true)
	await process_frame
	var exchange := scene.find_child("ShopGetGemsButton", true, false) as Button
	check(exchange != null, "shop offers native currency exchange action")
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
	scene.start_offline(true)
	scene.cancel_offline_ai_run()
	scene.set_process(false)
	scene.current_seat = 0
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	scene.inventory = {"swap_card": 2, "peek_card": 1, "lucky_charm": 1, "double_coins": 0}
	scene.save_economy_state()
	var ledger_before: Dictionary = scene.offline_tile_ledger_report()
	check(bool(ledger_before.get("ok", false)), "inventory fixture starts with a conserved tile ledger")
	var wall_count := scene.wall.size() as int
	var hand_count := scene.players[0]["hand"].size() as int
	check(scene.use_offline_inventory_item("swap_card"), "swap card replaces the actual draw on the human discard turn")
	check(scene.wall.size() == wall_count and scene.players[0]["hand"].size() == hand_count and bool(scene.offline_tile_ledger_report().get("ok", false)) and scene.get_item_count("swap_card") == 1, "swap preserves every tile and consumes exactly one inventory item")
	scene.offline_self_draw_ready = {"seat": -1, "serial": -1}
	check(not scene.use_offline_inventory_item("swap_card") and scene.get_item_count("swap_card") == 1, "swap cannot bypass a claim turn without a current draw")
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
