extends SceneTree
## Verify complete all-bot hands across every supported local rule profile.
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
	print("=== ai_rule_variant_soak check START ===")
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.setup_tile_order()
	scene.fast_mode_enabled = true
	scene.sfx_enabled = false
	scene.music_enabled = false
	scene.fx_enabled = false
	scene.ai_difficulty = scene.AI_DIFFICULTY_NORMAL

	var seeds := [20260820, 20260871]
	var expected_sizes := {
		scene.RULE_VARIANT_GUANGDONG: 136,
		scene.RULE_VARIANT_SICHUAN: 108,
		scene.RULE_VARIANT_NANJING: 144,
		scene.RULE_VARIANT_YANGZHOU: 144,
	}
	var total_hands := 0
	var completed_hands := 0
	for variant_value in scene.RULE_VARIANT_ORDER:
		var variant := str(variant_value)
		print("--- %s ---" % scene.rule_variant_label(variant))
		scene.rule_variant = variant
		var expected_wall_size := int(expected_sizes.get(variant, -1))
		check(scene.rule_wall_size(variant) == expected_wall_size, "%s profile wall size is %d" % [scene.rule_variant_short_label(variant), expected_wall_size])
		for seed_value in seeds:
			total_hands += 1
			scene.ensure_ai_benchmark_players()
			scene.enable_offline_all_bot_mode(true, true)
			scene.dealer_seat = total_hands % 4
			scene.offline_hand_number = total_hands
			scene.offline_skip_ai_profile_reshuffle = true
			seed(int(seed_value))
			scene.deal_offline_hand()
			var active_variant: String = scene.active_rule_variant()
			var wall_size: int = scene.rule_wall_size(active_variant)
			check(active_variant == variant, "%s seed %d activates the selected profile" % [scene.rule_variant_short_label(variant), int(seed_value)])
			check(scene.make_wall().size() == wall_size and wall_size == expected_wall_size, "%s seed %d uses the profile wall" % [scene.rule_variant_short_label(variant), int(seed_value)])
			var initial_integrity: Dictionary = scene.offline_tile_ledger_report()
			check(bool(initial_integrity.get("ok", false)), "%s seed %d starts with a valid tile ledger" % [scene.rule_variant_short_label(variant), int(seed_value)])
			# Package liability is a per-profile rule.  A disabled profile must not
			# accumulate invisible claim responsibility or penalize its AI discard
			# candidates for a settlement rule that will never be applied.
			if not bool(scene.rule_profile(variant).get("package_liability", false)):
				scene.offline_claim_counts.clear()
				scene.offline_package_liability.clear()
				scene.record_claim_source(1, 0, "peng")
				scene.record_claim_source(1, 0, "peng")
				scene.record_claim_source(1, 0, "peng")
				var disabled_feed := {"details": [{"opponent": 1, "score": 36.0}]}
				var disabled_package: Dictionary = scene.package_feed_discipline_report(0, "5W", disabled_feed, 2, {})
				check(int(scene.offline_claim_counts.get(scene.claim_source_key(1, 0), 0)) == 0, "%s does not track disabled package responsibility" % scene.rule_variant_short_label(variant))
				check(scene.package_payer_for(1) == -1 and not bool(disabled_package.get("pending", false)) and float(disabled_package.get("penalty", 0.0)) == 0.0, "%s AI ignores disabled package liability" % scene.rule_variant_short_label(variant))
			var result: Dictionary = scene.simulate_offline_bot_hand_sync(700)
			var prefix: String = "%s seed %d" % [scene.rule_variant_short_label(variant), int(seed_value)]
			var flower_count := 0
			for player in scene.players:
				flower_count += int(player.get("flowers", 0))
			print("    ended=%s steps=%s wall=%s winner=%s integrity=%s score=%s flowers=%s" % [
				str(result.get("ended", false)),
				str(result.get("steps", 0)),
				str(result.get("wall", -1)),
				str(result.get("winner", -1)),
				str(result.get("integrity_ok", false)),
				str(result.get("score_conserved", false)),
				str(flower_count),
			])
			check(bool(result.get("ended", false)), "%s reaches a terminal hand" % prefix)
			check(bool(result.get("integrity_ok", false)), "%s preserves the physical tile ledger" % prefix)
			check(bool(result.get("score_conserved", false)), "%s preserves the score ledger" % prefix)
			check(int(result.get("steps", 0)) < 700, "%s completes before the simulation guard" % prefix)
			var winner := int(result.get("winner", -1))
			if winner >= 0:
				var win_score: Dictionary = scene.last_win_score
				var fan := int(win_score.get("fan", 0))
				var points := int(win_score.get("points", 0))
				check(fan >= scene.rule_min_fan(variant), "%s winner meets the %d-fan minimum" % [prefix, scene.rule_min_fan(variant)])
				check(int(win_score.get("limit_fan", 0)) <= scene.rule_score_limit_fan(variant), "%s winner respects the %d-fan limit" % [prefix, scene.rule_score_limit_fan(variant)])
				check(points == scene.score_points_for_fan(fan), "%s settlement points match the active rule score table" % prefix)
			if bool(result.get("ended", false)) and bool(result.get("integrity_ok", false)) and bool(result.get("score_conserved", false)):
				completed_hands += 1

	check(completed_hands == total_hands, "all %d rule-variant hands complete with conserved ledgers" % total_hands)
	scene.enable_offline_all_bot_mode(false, false)
	scene.queue_free()
	if failed:
		print("=== RESULT: FAIL ===")
		quit(1)
	else:
		print("=== RESULT: OK ===")
		quit(0)
