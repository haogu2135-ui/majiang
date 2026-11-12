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
	scene.queue_free()
	for _step in range(4):
		await process_frame
	quit(1 if failed else 0)
