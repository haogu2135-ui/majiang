extends SceneTree

const MainScript := preload("res://scripts/main.gd")

var failed := false

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var scene: MainScript = load("res://Main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	check(scene.app_version() == "1.0.162-godot", "project version matches exported app version")
	check(scene.AUDIO_DEFAULTS_VERSION == "1.0.159-godot", "audio defaults migrate for this release")
	check(not scene.player_ai_assist_enabled(), "offline player side does not enable AI assistance")
	check(scene.UPDATE_MANIFEST_URL == "http://129.146.180.88:18081/YunzhuoMahjongGodot-update.json", "update manifest URL points to live download service")
	check(scene.UPDATE_URL == "http://129.146.180.88:18081/YunzhuoMahjongGodot-v1.0.162-godot.apk", "fallback update APK URL uses this release's immutable APK path")
	check(bool(ProjectSettings.get_setting("audio/general/text_to_speech", false)), "Godot text-to-speech project setting is enabled")
	check(bool(ProjectSettings.get_setting("audio/driver/enable_input", false)), "audio input is enabled for voice features")
	check(scene.illustration_textures.size() == scene.ILLUSTRATION_ASSET_PATHS.size(), "all configured UI illustration PNGs load into the illustration texture registry")
	check(scene.illustration_texture("menu_hero") != null and scene.illustration_texture("table_wash") != null and scene.illustration_texture("win_fanfare") != null, "core menu table and win illustration textures are available")
	scene.show_loading_screen()
	check(scene.find_child("LoadingGateTexture", true, false) != null, "loading screen renders reusable moon-gate PNG texture")
	check(scene.find_child("LoadingShuffleArt", true, false) != null and scene.find_child("LoadingShuffleRail", true, false) != null and scene.find_child("LoadingShuffleSeal", true, false), "loading screen renders shuffle illustration rail and seal")
	check(scene.find_child("LoadingShuffleGlow", true, false) != null and scene.find_child("LoadingShuffleProgress", true, false) != null and count_nodes_with_name_prefix(scene, "LoadingShuffleTile_") == 5, "loading screen renders wall-back shuffle tiles and progress glow")
	check(scene.find_child("LoadingShuffleSyncRoute", true, false) != null and scene.find_child("LoadingShuffleSyncFill", true, false) != null and scene.find_child("LoadingShuffleSyncGate", true, false) != null and count_nodes_with_name_prefix(scene, "LoadingShuffleSyncTick_") == 3, "loading screen renders shuffle-to-progress sync route")
	check(scene.find_child("LoadingTipArt", true, false) != null and scene.find_child("LoadingTipRail", true, false) != null and scene.find_child("LoadingTipFill", true, false) != null and scene.find_child("LoadingTipSeal", true, false) != null, "loading screen renders tip route illustration")
	check(count_nodes_with_name_prefix(scene, "LoadingTipNode_") == 2 and count_nodes_with_name_prefix(scene, "LoadingTipTick_") == 3, "loading tip art renders nodes and rhythm ticks")
	scene.show_daily_login_panel({"consecutive_days": 7, "show_reward": true})
	check(scene.find_child("DailyLoginCalendarTexture", true, false) != null, "daily login renders reusable seven-day calendar PNG texture")
	check(scene.find_child("DailyLoginStreakArt", true, false) != null and scene.find_child("DailyLoginStreakRail", true, false) != null and scene.find_child("DailyLoginStreakFill", true, false) != null, "daily login renders streak rail illustration")
	check(count_nodes_with_name_prefix(scene, "DailyLoginDayNode_") == 7 and count_nodes_with_name_prefix(scene, "DailyLoginStreakNode_") == 7, "daily login renders seven visible day nodes and streak nodes")
	check(scene.find_child("DailyLoginCurrentHalo", true, false) != null and scene.find_child("DailyLoginSevenDayGate", true, false) != null and scene.find_child("DailyLoginMilestoneGlow", true, false) != null, "daily login highlights current milestone reward")
	check(scene.find_child("DailyLoginRewardArt", true, false) != null and scene.find_child("DailyLoginRewardRoute", true, false) != null and scene.find_child("DailyLoginRewardRouteFill", true, false) != null and scene.find_child("DailyLoginRewardMilestoneBurst", true, false) != null, "daily login reward panel renders milestone reward route")
	check(count_nodes_with_name_prefix(scene, "DailyLoginRewardNode_") == 2 and count_nodes_with_name_prefix(scene, "DailyLoginRewardTick_") == 3 and scene.find_child("DailyLoginProgressRail", true, false) != null and scene.find_child("DailyLoginProgressFill", true, false) != null, "daily login reward panel renders reward nodes ticks and named progress fill")
	check(scene.find_child("DailyLoginProgressConfirmArt", true, false) != null and scene.find_child("DailyLoginProgressConfirmRoute", true, false) != null and scene.find_child("DailyLoginProgressConfirmFill", true, false) != null and scene.find_child("DailyLoginProgressConfirmGate", true, false) != null, "daily login progress renders claim confirmation route")
	check(count_nodes_with_name_prefix(scene, "DailyLoginProgressConfirmTick_") == 3 and scene.find_child("DailyLoginProgressReadySeal", true, false) != null, "daily login progress renders confirmation rhythm ticks and ready seal")
	check(scene.find_child("DailyLoginClaimButton", true, false) != null and scene.find_child("DailyLoginClaimButtonArt", true, false) != null and scene.find_child("DailyLoginClaimRail", true, false) != null and scene.find_child("DailyLoginClaimFill", true, false) != null and scene.find_child("DailyLoginClaimGate", true, false) != null, "daily login claim button renders reward claim route")
	check(count_nodes_with_name_prefix(scene, "DailyLoginClaimTick_") == 3, "daily login claim button renders reward rhythm ticks")
	scene.show_diagnostic_dialog(["【音频系统诊断 v1.0.156】", "✓ BGM文件加载成功", "✗ BGM未播放", "• 建议检查媒体音量", "   →省电策略→无限制"])
	check(scene.find_child("DiagnosticWaveTexture", true, false) != null, "diagnostic dialog renders reusable wave PNG texture")
	check(scene.find_child("DiagnosticDialogPanel", true, false) != null and scene.find_child("DiagnosticDialogArt", true, false) != null and scene.find_child("DiagnosticHealthRail", true, false) != null, "diagnostic dialog renders illustrated health rail")
	check(scene.find_child("DiagnosticStatusSeal", true, false) != null and scene.find_child("DiagnosticHealthFill", true, false) != null and count_nodes_with_name_prefix(scene, "DiagnosticStatusNode_") == 3, "diagnostic dialog renders status seal and summary nodes")
	check(scene.find_child("DiagnosticTracePanel", true, false) != null and count_nodes_with_name_prefix(scene, "DiagnosticTracePulse_") == 4, "diagnostic dialog renders trace pulse art")
	check(scene.find_child("DiagnosticLineTrace", true, false) != null and count_nodes_with_name_prefix(scene, "DiagnosticLineLane_") == 5 and count_nodes_with_name_prefix(scene, "DiagnosticLineNode_") == 5, "diagnostic dialog renders one trace lane per visible diagnostic line")
	check(scene.find_child("DiagnosticDismissOverlay", true, false) != null and scene.find_child("DiagnosticDismissArt", true, false) != null and scene.find_child("DiagnosticDismissRoute", true, false) != null and scene.find_child("DiagnosticDismissTapSeal", true, false) != null, "diagnostic dialog renders tap-to-dismiss route art")
	check(count_nodes_with_name_prefix(scene, "DiagnosticDismissTick_") == 3, "diagnostic dialog renders dismiss rhythm ticks")
	check(first_label_containing_text(scene, "BGM文件加载成功") != null and first_label_containing_text(scene, "BGM未播放") != null, "diagnostic dialog keeps detailed diagnostic text visible")
	var copied_profile = scene.ai_profile(1)
	copied_profile["attack"] = 9.99
	check(is_equal_approx(scene.ai_profile_value(1, "attack"), 0.92) and scene.ai_profile_label(1) == "防守型" and scene.ai_profile_short_label(2) == "攻", "AI profile reads use canonical profiles while public profile copies stay isolated")
	scene.start_offline(true)
	check(scene.mode == "offline", "starts offline mode")
	check(scene.can_self_discard(), "human can discard after deal")
	check(scene.find_child("TopHudHandProgress", true, false) != null and scene.find_child("HandProgressRail", true, false) != null and scene.find_child("HandProgressDealerBadge", true, false) != null and count_nodes_with_name_prefix(scene, "HandProgressPip_") == scene.MATCH_MAX_HANDS, "top HUD renders hand progress rail, dealer badge and match pips")
	check(scene.find_child("HandProgressRouteFill", true, false) != null and scene.find_child("HandProgressCurrentCursor", true, false) != null and count_nodes_with_name_prefix(scene, "HandProgressRhythmTick_") == 3, "top HUD hand progress renders route fill current cursor and rhythm ticks")
	check(scene.find_child("HandProgressDealerRoute", true, false) != null and scene.find_child("HandProgressDealerRouteFill", true, false) != null and scene.find_child("HandProgressDealerRouteGate", true, false) != null and count_nodes_with_name_prefix(scene, "HandProgressDealerRouteTick_") == 2, "top HUD hand progress renders dealer route")
	check(scene.find_child("HandTrayActionPath", true, false) != null and scene.find_child("HandTrayActionPathRail", true, false) != null and scene.find_child("HandTrayActionPathFocus", true, false) != null and scene.find_child("HandTrayActionPathTarget", true, false) != null and count_nodes_with_name_prefix(scene, "HandTrayActionPathNode_") == 4, "hand tray renders action path illustration with focus target and route nodes")
	check(scene.find_child("HandTrayActionPathStream", true, false) != null and scene.find_child("HandTrayActionPathStreamFill", true, false) != null and scene.find_child("HandTrayActionPathGate", true, false) != null and count_nodes_with_name_prefix(scene, "HandTrayActionPathTick_") == 3, "hand tray action path renders stream fill gate and direction ticks")
	check(scene.offline_draw_serial > 0 and not bool(scene.offline_last_draw.get("announce", true)) and scene.fx_last_animated_draw_serial == -1, "initial deal tracks draw order without replaying hand draw animation")
	var human_fly_start = scene.human_discard_fly_start_position(0, scene.players[0]["hand"].size())
	var human_fly_target = scene.human_discard_fly_target_position()
	check(human_fly_start.x >= 0.0 and human_fly_start.y >= 0.0 and human_fly_target.x >= 0.0 and human_fly_target.y >= 0.0 and human_fly_start.distance_to(human_fly_target) > 24.0, "human discard fly animation travels from hand tray toward the discard river")
	var human_discard_tile = str(scene.players[0]["hand"][0])
	scene.human_discard(0)
	await process_frame
	check(scene.find_child("ClaimBurstLabel_打", true, false) != null and scene.find_child("FlyingTile_%s" % human_discard_tile, true, false) != null, "human discard creates a flying tile and action burst")
	check(scene.find_child("FlyingTileRouteArt", true, false) != null and scene.find_child("FlyingTileRouteRail", true, false) != null and scene.find_child("FlyingTileRouteFill", true, false) != null, "human discard flying tile renders route art")
	for route_wait in range(4):
		if scene.find_child("FlyingTileSourceGate", true, false) != null and scene.find_child("FlyingTileLandingGate", true, false) != null and count_nodes_with_name_prefix(scene, "FlyingTileRouteTick_") == 3:
			break
		await process_frame
	check(scene.find_child("FlyingTileSourceGate", true, false) != null and scene.find_child("FlyingTileLandingGate", true, false) != null and count_nodes_with_name_prefix(scene, "FlyingTileRouteTick_") == 3, "human discard flying route renders source landing gates and rhythm ticks")
	scene.fx_enabled = true
	scene.ensure_fx_layer()
	scene.play_discard_splash(Vector2(320, 240), human_discard_tile)
	check(scene.find_child("DiscardSplashFx", true, false) != null and count_nodes_with_name_prefix(scene, "DiscardSplashRing_") >= 3 and count_nodes_with_name_prefix(scene, "DiscardSplashDrop_") >= 6, "discard splash renders named rings and droplets")
	check(scene.find_child("DiscardSplashLandingRoute", true, false) != null and scene.find_child("DiscardSplashLandingFill", true, false) != null and scene.find_child("DiscardSplashLandingGate", true, false) != null and count_nodes_with_name_prefix(scene, "DiscardSplashLandingTick_") >= 3, "discard splash renders landing route and rhythm ticks")
	scene.play_claim_trail_particles(Vector2(120, 240), Vector2(320, 180), 60.0, scene.GOLD_PRIMARY)
	check(scene.find_child("ClaimTrailFx", true, false) != null and scene.find_child("ClaimTrailRoute", true, false) != null and scene.find_child("ClaimTrailRouteFill", true, false) != null and scene.find_child("ClaimTrailLandingGate", true, false) != null, "claim trail renders route fill and landing gate")
	check(count_nodes_with_name_prefix(scene, "ClaimTrailSpark_") >= 8 and count_nodes_with_name_prefix(scene, "ClaimTrailRhythmNode_") >= 3, "claim trail renders named sparks and rhythm nodes")
	scene.play_claim_resolution_art("gang", Vector2(140, 250), Vector2(360, 190), scene.AZURE, scene.FX_CLAIM_FLY_DURATION_MSEC)
	check(scene.find_child("ClaimResolutionArt_gang", true, false) != null and scene.find_child("ClaimResolutionRoute_gang", true, false) != null and scene.find_child("ClaimResolutionFill_gang", true, false) != null, "claim resolution renders action-specific route art")
	check(scene.find_child("ClaimResolutionLandingGate_gang", true, false) != null and scene.find_child("ClaimResolutionGateCore_gang", true, false) != null and scene.find_child("ClaimResolutionGlyph_gang", true, false) != null, "claim resolution renders landing gate and action glyph")
	check(count_nodes_with_name_prefix(scene, "ClaimResolutionMeldSlot_gang_") == 4 and count_nodes_with_name_prefix(scene, "ClaimResolutionMeldPip_gang_") == 4 and count_nodes_with_name_prefix(scene, "ClaimResolutionTick_gang_") == 3, "claim resolution renders gang meld slots pips and rhythm ticks")
	scene.play_fx_gang_burst("concealed", 0)
	check(scene.find_child("GangBurstRoute", true, false) != null and scene.find_child("GangBurstRouteFill", true, false) != null and scene.find_child("GangBurstDrawGate", true, false) != null and scene.find_child("GangBurstQuadNode", true, false) != null, "gang burst renders route to replacement draw gate")
	check(count_nodes_with_name_prefix(scene, "GangBurstTileMark_") == 4 and count_nodes_with_name_prefix(scene, "GangBurstRouteTick_") == 3, "gang burst renders four-tile marks and rhythm ticks")
	check(scene.find_child("GangBurstTypeRoute", true, false) != null and scene.find_child("GangBurstTypeFill", true, false) != null and scene.find_child("GangBurstTypeSource", true, false) != null and scene.find_child("GangBurstTypeGate", true, false) != null, "gang burst renders gang-type confirmation route")
	check(count_nodes_with_name_prefix(scene, "GangBurstTypeTick_") == 2, "gang burst renders gang-type rhythm ticks")
	scene.start_offline(true)
	check(scene.make_wall().size() == 144, "wall includes eight flowers")
	check(scene.fx_enabled and scene.fx_layer != null and is_instance_valid(scene.fx_layer), "fx animation layer is created and enabled for smoke paths")
	scene.play_fx_deal_cascade(0)
	check(count_nodes_with_name_prefix(scene, "DealCascadeRoute_") >= 4 and count_nodes_with_name_prefix(scene, "DealCascadeRouteFill_") >= 4 and count_nodes_with_name_prefix(scene, "DealCascadeSeatGate_") >= 4, "deal cascade animation renders one route fill and seat gate per player")
	check(count_nodes_with_name_prefix(scene, "DealCascadeRouteTick_") >= 12, "deal cascade animation renders route rhythm ticks toward all seats")
	scene.play_fx_turn_switch_slide(2)
	check(scene.find_child("TurnSwitchHalo", true, false) != null and scene.find_child("TurnSwitchRoute", true, false) != null and scene.find_child("TurnSwitchRouteFill", true, false) != null and scene.find_child("TurnSwitchSeatGate", true, false) != null, "turn switch animation renders active-seat route and gate")
	check(count_nodes_with_name_prefix(scene, "TurnSwitchRouteTick_") == 3, "turn switch animation renders route rhythm ticks")
	var before_fx: bool = scene.fx_enabled
	scene.toggle_fx_setting()
	check(scene.fx_enabled == (not before_fx), "fx setting toggles and persists through the settings path")
	scene.toggle_fx_setting()
	check(scene.fx_enabled == before_fx, "fx setting toggles back to default")
	var fx_rect := scene.root_layer_rect_to_screen_rect_for(Rect2(Vector2(0.0, 0.0), Vector2(1.0, 1.0)), Vector2(1280, 720), Vector4(0, 0, 0, 0))
	check(is_equal_approx(fx_rect.position.x, 0.0) and is_equal_approx(fx_rect.size.x, 1.0), "fx rect conversion maps a full safe-area rect to the full viewport")
	var fx_inset := scene.root_layer_rect_to_screen_rect_for(Rect2(Vector2(0.0, 0.0), Vector2(1.0, 1.0)), Vector2(1280, 720), Vector4(80, 0, 80, 0))
	check(is_equal_approx(fx_inset.position.x, 80.0 / 1280.0) and is_equal_approx(fx_inset.size.x, (1280.0 - 80.0) / 1280.0), "fx rect conversion accounts for left and right safe-area margins")
	var fx_center := scene.root_layer_rect_to_screen_rect_for(Rect2(Vector2(0.5, 0.5), Vector2(0.5, 0.5)), Vector2(1000, 1000), Vector4(0, 0, 0, 0))
	check(is_equal_approx(fx_center.position.x, 0.5) and is_equal_approx(fx_center.position.y, 0.5) and is_equal_approx(fx_center.size.x, 0.5), "fx rect conversion keeps center anchors centered")
	var discard_ripple = scene.discard_ripple_rect_for_seat(0)
	var discard_zone_screen = Rect2()
	for zone in scene.DISCARD_ZONES:
		if int(zone[0]) == 0:
			discard_zone_screen = scene.root_layer_rect_to_screen_rect(zone[1])
			break
	var discard_ripple_center = (discard_ripple.position + discard_ripple.size) * 0.5
	check(discard_ripple.position.x < discard_ripple.size.x and discard_ripple.position.y < discard_ripple.size.y, "discard ripple rect has valid anchor bounds")
	check(discard_ripple_center.x >= discard_zone_screen.position.x and discard_ripple_center.x <= discard_zone_screen.size.x and discard_ripple_center.y >= discard_zone_screen.position.y and discard_ripple_center.y <= discard_zone_screen.size.y, "discard ripple centers inside the active discard zone")
	check(scene.wall_meter_color(0.10).r > scene.wall_meter_color(0.10).g, "wall meter uses warm warning color for low wall count")
	check(scene.wall_meter_color(0.80).g > scene.wall_meter_color(0.80).r, "wall meter uses calm green color for healthy wall count")
	var wall_warning_parent = Control.new()
	root.add_child(wall_warning_parent)
	scene.draw_center_wall_meter(wall_warning_parent, 18)
	check(wall_warning_parent.find_child("CenterWallFlowArt", true, false) != null and wall_warning_parent.find_child("CenterWallFlowCore", true, false) != null and wall_warning_parent.find_child("CenterWallFlowFill", true, false) != null, "center wall meter renders remaining-wall flow art")
	check(count_nodes_with_name_prefix(wall_warning_parent, "CenterWallFlowNode_") == 4 and count_nodes_with_name_prefix(wall_warning_parent, "CenterWallFlowTick_") == 3, "center wall meter renders flow nodes and ticks")
	check(wall_warning_parent.find_child("CenterWallLowWarning", true, false) != null and wall_warning_parent.find_child("CenterWallLowWarningBadge", true, false) != null and wall_warning_parent.find_child("CenterWallLowSpark", true, false) != null, "low wall meter renders warning badge and sparks")
	check(wall_warning_parent.find_child("CenterWallLowDangerRoute", true, false) != null and wall_warning_parent.find_child("CenterWallLowDangerFill", true, false) != null and wall_warning_parent.find_child("CenterWallLowDangerGate", true, false) != null, "low wall meter renders danger countdown route")
	check(count_nodes_with_name_prefix(wall_warning_parent, "CenterWallLowDangerTick_") == 3, "low wall meter renders danger rhythm ticks")
	var low_wall_fill = wall_warning_parent.find_child("CenterWallLowDangerFill", true, false) as Control
	check(low_wall_fill != null and low_wall_fill.anchor_right > 0.60 and low_wall_fill.anchor_right < 0.70, "low wall danger fill tracks remaining wall count")
	check(has_label_text(wall_warning_parent, "荒庄临近"), "low wall warning names the near-draw state")
	wall_warning_parent.queue_free()
	check(scene.tile_index("E") == 27 and scene.tile_sort_index("H1") > scene.tile_index("P"), "tile order cache gives stable fast tile lookup")
	check(scene.tile_metadata_ready and scene.tile_sort_order.has("H8") and scene.tile_label_cache.has("5W"), "tile metadata cache initializes sort order and display labels")
	check(scene.tile_suit_index("5W") == 0 and scene.tile_suit_index("5T") == 1 and scene.tile_suit_index("5B") == 2, "tile metadata cache gives stable fast suit lookup")
	check(scene.is_number_tile("5W") and not scene.is_number_tile("E") and scene.is_honor_tile("E") and scene.is_flower_tile("H1"), "tile metadata cache preserves number honor and flower classification")
	check(scene.TILE_RANK_SPEECH_LABELS.size() == 9 and scene.TILE_RANK_SPEECH_LABELS[4] == "五" and scene.FLOWER_LABELS == ["春", "夏", "秋", "冬", "梅", "兰", "竹", "菊"], "tile metadata uses shared fixed label tables")
	check(scene.is_terminal_or_honor("1W") and scene.is_terminal_or_honor("E") and not scene.is_terminal_or_honor("5W") and scene.is_simple_number_tile("5W") and not scene.is_simple_number_tile("1W"), "tile metadata cache preserves terminal and simple classification")
	check(scene.thirteen_orphans_indices.size() == scene.THIRTEEN_ORPHANS_CODES.size() and scene.is_thirteen_orphans_tile("1W") and scene.is_thirteen_orphans_tile("P") and not scene.is_thirteen_orphans_tile("5W") and not scene.is_thirteen_orphans_tile("H1"), "tile metadata cache preserves thirteen-orphans lookup")
	check(scene.tile_label("5W") == "5万" and scene.tile_speech_label("5W") == "五万" and scene.tile_label("H1") == "春" and scene.tile_face_main("5W") == "5" and scene.tile_face_sub("5W") == "万" and scene.tile_corner("5W") == "5", "tile metadata cache preserves UI and speech labels")
	check(scene.meld_kind_label(["1W", "2W", "3W"]) == "吃" and scene.meld_kind_label(["E", "E", "E"]) == "碰" and scene.meld_kind_label(["5B", "5B", "5B", "5B"]) == "杠", "meld illustration labels distinguish chi peng and gang")
	var gang_meld_view = scene.make_meld_group_view(["5B", "5B", "5B", "5B"], 0)
	root.add_child(gang_meld_view)
	check(gang_meld_view.find_child("MeldGroupArt", true, false) != null and gang_meld_view.find_child("MeldKindRail", true, false) != null and count_nodes_with_name_prefix(gang_meld_view, "MeldFlowBead_") == 4, "meld group renders common flow art")
	check(gang_meld_view.find_child("MeldRouteRail", true, false) != null and gang_meld_view.find_child("MeldRouteFill", true, false) != null and gang_meld_view.find_child("MeldRouteArrow", true, false) != null and count_nodes_with_name_prefix(gang_meld_view, "MeldRouteNode_") == 3, "meld group renders route rail nodes and arrow")
	check(gang_meld_view.find_child("MeldCompletionRoute", true, false) != null and gang_meld_view.find_child("MeldCompletionFill", true, false) != null and gang_meld_view.find_child("MeldCompletionGate", true, false) != null and count_nodes_with_name_prefix(gang_meld_view, "MeldCompletionTick_") == 2, "meld group renders completion route and rhythm ticks")
	check(gang_meld_view.find_child("MeldGangGoldRail", true, false) != null and gang_meld_view.find_child("MeldGangSeal", true, false) != null and gang_meld_view.find_child("MeldGangRaisedTile", true, false) != null and gang_meld_view.find_child("MeldGangCrownGlow", true, false) != null, "gang meld illustration renders rail seal crown glow and raised fourth tile")
	gang_meld_view.queue_free()
	var chi_meld_view = scene.make_meld_group_view(["1W", "2W", "3W"], 1)
	root.add_child(chi_meld_view)
	check(chi_meld_view.find_child("MeldChiBridge", true, false) != null and chi_meld_view.find_child("MeldKindSeal", true, false) != null and count_nodes_with_name_prefix(chi_meld_view, "MeldFlowBead_") == 3, "chi meld illustration renders sequence bridge and flow beads")
	chi_meld_view.queue_free()
	var peng_meld_view = scene.make_meld_group_view(["E", "E", "E"], 2)
	root.add_child(peng_meld_view)
	check(count_nodes_with_name_prefix(peng_meld_view, "MeldPengPulse_") == 2 and peng_meld_view.find_child("MeldKindRail", true, false) != null, "peng meld illustration renders pair pulse art")
	peng_meld_view.queue_free()
	var meld_lane_parent = Control.new()
	root.add_child(meld_lane_parent)
	scene.players[2]["melds"] = [["3W", "4W", "5W"], ["E", "E", "E"]]
	scene.draw_melds(meld_lane_parent)
	check(meld_lane_parent.find_child("MeldLaneArt_2", true, false) != null and meld_lane_parent.find_child("MeldLaneRail_2", true, false) != null and meld_lane_parent.find_child("MeldLaneFill_2", true, false) != null and meld_lane_parent.find_child("MeldLaneGate_2", true, false) != null, "meld area renders seat lane rail and gate")
	check(meld_lane_parent.find_child("MeldLaneExitRoute_2", true, false) != null and meld_lane_parent.find_child("MeldLaneExitFill_2", true, false) != null and meld_lane_parent.find_child("MeldLaneExitGate_2", true, false) != null and count_nodes_with_name_prefix(meld_lane_parent, "MeldLaneExitTick_2_") == 2, "meld area renders lane exit route to open meld gate")
	check(count_nodes_with_name_prefix(meld_lane_parent, "MeldLaneNode_2_") == 2 and count_nodes_with_name_prefix(meld_lane_parent, "MeldLaneTick_2_") == 3 and count_nodes_with_name_prefix(meld_lane_parent, "MeldGroup_") == 2, "meld area lane tracks open meld count and keeps meld groups")
	meld_lane_parent.queue_free()
	scene.players[2]["melds"] = []
	check(scene.claim_display_label("chi") == "吃" and scene.claim_display_label("peng") == "碰" and scene.claim_display_label("gang") == "杠", "claim burst animation renders localized action labels")
	check(scene.tile_array_key(["3W", "1W", "3W", "E"]) == "1W1,3W2,E1", "small tile array key keeps tile order without dictionary allocation")
	check(scene.tile_array_key(["E", "3W", "1W", "3W"]) == "1W1,3W2,E1", "sparse tile array key is stable for shuffled tiles")
	check(scene.meld_array_key([["3W", "1W", "3W"], ["E", "E", "E"]]) == "1W1,3W2;E3", "meld cache key reuses small tile keys")
	check(scene.counts_compact_key([0, 1, 4, 0]) == "0140" and scene.counts_compact_key([10, 0, 2]) == "1002", "compact count keys use fast digit encoding while preserving multi-digit fallback")
	var empty_counts = scene.make_empty_tile_counts()
	check(empty_counts.size() == scene.TILE_CODES.size() and int(empty_counts[0]) == 0 and int(empty_counts[empty_counts.size() - 1]) == 0, "empty tile count helper builds a fixed zero-filled count array")
	var isolated_empty_counts = scene.make_empty_tile_counts()
	empty_counts[0] = 3
	check(int(isolated_empty_counts[0]) == 0, "empty tile count helper returns isolated copies from the zero template")
	var sample_counts = scene.tile_counts(["1W", "1W", "P"])
	check(int(sample_counts[scene.tile_index("1W")]) == 2 and int(sample_counts[scene.tile_index("P")]) == 1, "tile counts reuse zero-filled count arrays without changing counts")
	var tile_lookup = scene.tile_presence_set(["E", "5W", "E"])
	check(tile_lookup.has("E") and tile_lookup.has("5W") and not tile_lookup.has("9B"), "tile presence set supports repeated wait lookup without rescanning discards")
	scene.players[1]["discards"] = ["5W", "5W"]
	scene.players[2]["melds"] = [["5W", "5W", "5W"]]
	var visible_counts = scene.visible_tile_counts()
	var five_man_index = scene.tile_index("5W")
	check(int(visible_counts[five_man_index]) == scene.visible_tile_count("5W"), "visible tile count cache matches per-tile scan")
	check(scene.visible_tile_count_from_counts("5W", visible_counts) == scene.visible_tile_count("5W"), "visible tile count helper reuses visible count snapshots")
	var cached_visible_metrics = scene.effective_tile_metrics(tenpai_hand(), 0, 0, 0, visible_counts)
	var default_visible_metrics = scene.effective_tile_metrics(tenpai_hand(), 0, 0, 0)
	check(int(cached_visible_metrics.get("count", -1)) == int(default_visible_metrics.get("count", -2)) and cached_visible_metrics.get("tiles", []) == default_visible_metrics.get("tiles", []), "effective tile metrics can reuse visible tile counts")
	var tenpai_counts = scene.tile_counts(tenpai_hand())
	var winning_counts = scene.tile_counts(winning_hand())
	var ai_shape_counts = scene.tile_counts(ai_shape_hand())
	check(scene.NUMBER_SUIT_STARTS == [0, 9, 18] and scene.SHAPE_NEIGHBOR_DELTAS == [-2, -1, 1, 2], "shape scans reuse fixed number-suit and neighbor tables")
	check(scene.TILE_BASE_VALUES.size() == scene.TILE_CODES.size() and is_equal_approx(float(scene.TILE_BASE_VALUES[0]), 4.0) and is_equal_approx(float(scene.TILE_BASE_VALUES[4]), 8.0) and is_equal_approx(float(scene.TILE_BASE_VALUES[27]), 5.0), "tile base values reuse a fixed scoring table")
	check(is_equal_approx(scene.tile_base_value(scene.tile_index("1W")), 4.0) and is_equal_approx(scene.tile_base_value(scene.tile_index("2W")), 6.0) and is_equal_approx(scene.tile_base_value(scene.tile_index("5W")), 8.0) and is_equal_approx(scene.tile_base_value(scene.tile_index("E")), 5.0), "tile base value table preserves terminal simple and honor scoring")
	check(scene.calculate_min_shanten_from_counts(tenpai_counts, 0) == scene.calculate_min_shanten(tenpai_hand(), 0), "count-based shanten matches hand-array shanten")
	check(scene.shanten_memo_key(ai_shape_counts, 1, 2, true) == "1:2:1:" + scene.counts_compact_key(ai_shape_counts), "shanten memo keys reuse the compact count key")
	scene.clear_shanten_cache()
	var first_shape_shanten = scene.calculate_min_shanten_from_counts(ai_shape_counts, 0)
	var shanten_cache_misses_after_first = scene.shanten_cache_misses
	var shanten_cache_hits_after_first = scene.shanten_cache_hits
	check(scene.calculate_min_shanten_from_counts(ai_shape_counts, 0) == first_shape_shanten and scene.shanten_cache_hits > shanten_cache_hits_after_first and scene.shanten_cache_misses == shanten_cache_misses_after_first, "shanten cache still reuses compact keys")
	check(scene.is_complete_hand_from_counts(winning_counts, winning_hand().size(), 0) == scene.is_complete_hand(winning_hand(), 0), "count-based complete hand check matches hand-array path")
	var complete_counts_before = winning_counts.duplicate()
	check(scene.is_standard_complete_from_counts(winning_counts, 4) and winning_counts == complete_counts_before, "standard complete hand search restores count snapshots after in-place recursion")
	var two_set_counts = scene.tile_counts(["1W", "2W", "3W", "E", "E", "E"])
	var two_set_counts_before = two_set_counts.duplicate()
	check(scene.can_form_sets(two_set_counts, 2) and two_set_counts == two_set_counts_before, "set-forming recursion restores count snapshots without per-branch array copies")
	check(is_equal_approx(scene.evaluate_ai_hand_from_counts(ai_shape_counts), scene.evaluate_ai_hand(ai_shape_hand())), "count-based AI hand value matches hand-array path")
	check(is_equal_approx(float(scene.hand_shape_quality_report_from_counts(ai_shape_counts).get("score", 0.0)), float(scene.hand_shape_quality_report(ai_shape_hand()).get("score", 0.0))), "count-based shape quality matches hand-array path")
	check(is_equal_approx(scene.hand_plan_score_from_counts(ai_shape_counts, ai_shape_hand().size()), scene.hand_plan_score(ai_shape_hand())), "count-based hand plan score matches hand-array path")
	var bamboo_plan_features = scene.hand_plan_features_from_counts(scene.tile_counts(["1B", "2B", "3B", "4B", "5B", "E"]), 6)
	check(int(bamboo_plan_features.get("best_suit", -1)) == 2, "hand plan feature scan checks all three number suits")
	check(int(bamboo_plan_features.get("honor_count", 0)) == 1 and int(bamboo_plan_features.get("suit_counts", [])[2]) == 5 and int(bamboo_plan_features.get("suit_rank_masks", [])[2]) == 31, "hand plan feature scan counts simple tiles outside thirteen-orphans tiles")
	check(str(scene.hand_plan_report_from_counts(ai_shape_counts, ai_shape_hand().size()).get("label", "")) == str(scene.hand_plan_report(ai_shape_hand()).get("label", "")), "count-based hand plan report matches hand-array path")
	scene.players[1]["discards"] = []
	scene.players[2]["melds"] = []
	scene.style_cache.clear()
	scene.style_cache_order.clear()
	var rounded_style = scene.style(Color(0.2, 0.3, 0.4, 1.0), 8, Color(0.7, 0.6, 0.3, 1.0), 2)
	var style_cache_size = scene.style_cache.size()
	scene.style(Color(0.2, 0.3, 0.4, 1.0), 8, Color(0.7, 0.6, 0.3, 1.0), 2)
	check(scene.style_cache.size() == style_cache_size, "style cache reuses repeated UI styleboxes")
	check(rounded_style.corner_radius_top_left == 8 and rounded_style.corner_radius_top_right == 8 and rounded_style.corner_radius_bottom_right == 8 and rounded_style.corner_radius_bottom_left == 8 and rounded_style.border_width_left == 2 and rounded_style.border_width_right == 2 and rounded_style.border_width_top == 2 and rounded_style.border_width_bottom == 2, "style helper applies uniform corner radius and border width")
	var shadowless_style = scene.style(Color(0.2, 0.3, 0.4, 1.0), 8, Color(0.7, 0.6, 0.3, 1.0), 2, 0)
	check(shadowless_style.shadow_size == 0 and scene.style_cache.size() == style_cache_size + 1, "style cache keeps shadow variants separate for lightweight UI")
	scene.style_cache.clear()
	scene.style_cache_order.clear()
	scene.button_style_set_cache.clear()
	scene.button_style_set_cache_order.clear()
	var first_button_style_set = scene.button_style_set(Color(0.24, 0.60, 0.45), 12)
	var style_cache_size_after_button_set = scene.style_cache.size()
	var repeated_button_style_set = scene.button_style_set(Color(0.24, 0.60, 0.45), 12)
	check(scene.button_style_set_cache.size() == 1 and style_cache_size_after_button_set == 3 and scene.style_cache.size() == style_cache_size_after_button_set, "button style set cache builds normal hover pressed styles once")
	check(first_button_style_set.has("normal") and first_button_style_set.has("hover") and first_button_style_set.has("pressed") and first_button_style_set["normal"] == repeated_button_style_set["normal"], "button style set cache reuses repeated button styleboxes")
	scene.style_cache.clear()
	scene.style_cache_order.clear()
	scene.button_style_set_cache.clear()
	scene.button_style_set_cache_order.clear()
	var action_style_button = scene.make_action_button("动作", Color(0.25, 0.58, 0.48), func() -> void:
		pass
	)
	check(scene.button_style_set_cache.size() == 1 and scene.style_cache.size() == 5 and action_style_button.find_child("ActionButtonArt", true, false) != null, "action buttons build compact button styles plus reusable icon accents")
	check(action_style_button.find_child("ActionButtonRoleRail", true, false) != null and count_nodes_with_name_prefix(action_style_button, "ActionButtonEnergyDot_") == 3, "action buttons render role rail and energy dots without extra styleboxes")
	check(action_style_button.find_child("ActionButtonCommandRoute", true, false) != null and action_style_button.find_child("ActionButtonCommandFill", true, false) != null and action_style_button.find_child("ActionButtonCommandNode", true, false) != null and count_nodes_with_name_prefix(action_style_button, "ActionButtonCommandTick_") == 2, "action buttons render command route and execution ticks")
	check(action_style_button.find_child("ActionButtonExecutionGate", true, false) != null and count_nodes_with_name_prefix(action_style_button, "ActionButtonExecutionTick_") == 3, "action buttons render execution gate and activation ticks without extra styleboxes")
	check(action_style_button.find_child("ActionButtonConfirmRoute", true, false) != null and action_style_button.find_child("ActionButtonConfirmFill", true, false) != null and action_style_button.find_child("ActionButtonConfirmGate", true, false) != null and count_nodes_with_name_prefix(action_style_button, "ActionButtonConfirmTick_") == 2, "action buttons render tap confirmation route")
	action_style_button.queue_free()
	scene.style_cache.clear()
	scene.style_cache_order.clear()
	scene.button_style_set_cache.clear()
	scene.button_style_set_cache_order.clear()
	var top_style_button = scene.make_top_hud_button("设置", Color(0.22, 0.42, 0.54), func() -> void:
		pass
	)
	check(scene.button_style_set_cache.size() == 1 and scene.style_cache.size() == 3, "top HUD buttons build only their compact style set")
	top_style_button.queue_free()
	var report_sort = [
		{"tile": "3W", "score": 10.0},
		{"tile": "2W", "score": 20.0},
		{"tile": "1W", "score": 20.0},
	]
	scene.sort_ai_discard_reports(report_sort)
	check(str(report_sort[0].get("tile", "")) == "1W" and str(report_sort[1].get("tile", "")) == "2W", "AI discard report sort runs once and keeps tile-order tie breaks")
	var effective_sort: Array[String] = ["3W", "1W", "2W"]
	scene.sort_effective_tiles_by_remaining(effective_sort, {"1W": 1, "2W": 4, "3W": 4})
	check(effective_sort == ["2W", "3W", "1W"], "effective tile sort preserves remaining-count priority")
	scene.clear_ai_report_cache()
	var ai_report_hand_before = scene.players[0]["hand"].duplicate()
	var first_reports = scene.get_ai_discard_reports(0)
	var first_misses = scene.ai_report_cache_misses
	check(scene.same_tile_list(scene.players[0]["hand"], ai_report_hand_before), "AI discard report generation reuses working hand arrays without mutating the player hand")
	var cached_reports = scene.get_ai_discard_reports(0)
	check(scene.ai_report_cache_hits >= 1 and scene.ai_report_cache_misses == first_misses, "AI discard reports reuse cache on repeated render state")
	if not cached_reports.is_empty() and typeof(cached_reports[0]) == TYPE_DICTIONARY:
		cached_reports[0]["tile"] = "ZZ"
	var refreshed_reports = scene.get_ai_discard_reports(0)
	check(not refreshed_reports.is_empty() and str(refreshed_reports[0].get("tile", "")) != "ZZ" and not first_reports.is_empty(), "AI report cache returns cheap isolated top-level copies")
	var nested_cache_report := {
		"tile": "1W",
		"effective_tiles": ["2W"],
		"effective_remaining": {"2W": 4},
		"feed_report": {"score": 1.0, "details": [{"opponent": 1, "score": 2.0}]},
		"danger_source": {"opponent": 1},
		"wait_self_discarded": ["3W"],
	}
	scene.store_ai_report_cache("nested-copy-test", [nested_cache_report])
	var source_effective_tiles: Array = nested_cache_report.get("effective_tiles", [])
	var source_effective_remaining: Dictionary = nested_cache_report.get("effective_remaining", {})
	var source_feed_report: Dictionary = nested_cache_report.get("feed_report", {})
	var source_feed_details: Array = source_feed_report.get("details", [])
	var source_danger: Dictionary = nested_cache_report.get("danger_source", {})
	var source_self_discarded: Array = nested_cache_report.get("wait_self_discarded", [])
	var source_feed_detail: Dictionary = source_feed_details[0] if not source_feed_details.is_empty() and typeof(source_feed_details[0]) == TYPE_DICTIONARY else {}
	source_effective_tiles[0] = "ZZ"
	source_effective_remaining["2W"] = 0
	if not source_feed_detail.is_empty():
		source_feed_detail["opponent"] = 9
	source_danger["opponent"] = 9
	source_self_discarded[0] = "ZZ"
	var stored_nested_reports: Array = scene.ai_report_cache.get("nested-copy-test", [])
	var stored_nested_report: Dictionary = stored_nested_reports[0] if not stored_nested_reports.is_empty() and typeof(stored_nested_reports[0]) == TYPE_DICTIONARY else {}
	var stored_effective_tiles: Array = stored_nested_report.get("effective_tiles", [])
	var stored_effective_remaining: Dictionary = stored_nested_report.get("effective_remaining", {})
	var stored_feed_report: Dictionary = stored_nested_report.get("feed_report", {})
	var stored_feed_details: Array = stored_feed_report.get("details", [])
	var stored_feed_detail: Dictionary = stored_feed_details[0] if not stored_feed_details.is_empty() and typeof(stored_feed_details[0]) == TYPE_DICTIONARY else {}
	var stored_danger: Dictionary = stored_nested_report.get("danger_source", {})
	var stored_self_discarded: Array = stored_nested_report.get("wait_self_discarded", [])
	var nested_copy_ok = not stored_effective_tiles.is_empty() and str(stored_effective_tiles[0]) == "2W"
	nested_copy_ok = nested_copy_ok and int(stored_effective_remaining.get("2W", 0)) == 4
	nested_copy_ok = nested_copy_ok and int(stored_feed_detail.get("opponent", -1)) == 1
	nested_copy_ok = nested_copy_ok and int(stored_danger.get("opponent", -1)) == 1
	nested_copy_ok = nested_copy_ok and not stored_self_discarded.is_empty() and str(stored_self_discarded[0]) == "3W"
	check(nested_copy_ok, "AI report cache stores targeted nested copies for mutable report fields")
	var ui_report_copy = scene.duplicate_ai_report(nested_cache_report, true)
	var ui_copy_effective_tiles: Array = ui_report_copy.get("effective_tiles", [])
	var ui_copy_feed_report: Dictionary = ui_report_copy.get("feed_report", {})
	var ui_copy_feed_details: Array = ui_copy_feed_report.get("details", [])
	if not ui_copy_effective_tiles.is_empty():
		ui_copy_effective_tiles[0] = "YY"
	if not ui_copy_feed_details.is_empty() and typeof(ui_copy_feed_details[0]) == TYPE_DICTIONARY:
		var ui_copy_feed_detail: Dictionary = ui_copy_feed_details[0]
		ui_copy_feed_detail["opponent"] = 8
	check(str(source_effective_tiles[0]) == "ZZ" and int(source_feed_detail.get("opponent", -1)) == 9, "UI AI report copies protect targeted nested fields without recursive deep copy")
	scene.clear_ai_report_cache()
	var ai_visible_counts = scene.visible_tile_counts()
	var ai_eval_context = scene.make_ai_evaluation_context(0, ai_visible_counts)
	var baseline_risk = scene.tile_risk_vector("5W", 0, ai_visible_counts)
	var cached_risk = scene.tile_risk_vector("5W", 0, ai_visible_counts, ai_eval_context)
	check(is_equal_approx(float(baseline_risk.get("score", 0.0)), float(cached_risk.get("score", 0.0))) and is_equal_approx(float(baseline_risk.get("threat", 0.0)), float(cached_risk.get("threat", 0.0))), "AI risk context preserves baseline risk math")
	var risk_cache: Dictionary = ai_eval_context.get("risk_vectors", {})
	var risk_cache_size = risk_cache.size()
	scene.tile_risk_vector("5W", 0, ai_visible_counts, ai_eval_context)
	check(risk_cache.size() == risk_cache_size and risk_cache_size >= 1, "AI risk context reuses per-tile vector cache")
	var base_pressure = scene.discard_pressure_score("5W", 0, ai_visible_counts)
	var cached_pressure = scene.discard_pressure_score("5W", 0, ai_visible_counts, ai_eval_context)
	check(is_equal_approx(base_pressure, cached_pressure), "AI pressure context preserves baseline pressure score")
	var pressure_cache: Dictionary = ai_eval_context.get("discard_pressures", {})
	var pressure_cache_size = pressure_cache.size()
	scene.discard_pressure_score("5W", 0, ai_visible_counts, ai_eval_context)
	var safety_label = scene.tile_safety_label("5W", 0, ai_visible_counts, ai_eval_context)
	var safety_cache: Dictionary = ai_eval_context.get("safety_labels", {})
	var safety_cache_size = safety_cache.size()
	check(str(scene.tile_safety_label("5W", 0, ai_visible_counts, ai_eval_context)) == safety_label and safety_cache.size() == safety_cache_size, "AI safety label context reuses one generated cache key")
	var feed_report_contextual = scene.discard_feed_risk_report("5W", 0, ai_visible_counts, ai_eval_context)
	var feed_cache: Dictionary = ai_eval_context.get("feed_reports", {})
	var feed_cache_size = feed_cache.size()
	var cached_feed_report_contextual = scene.discard_feed_risk_report("5W", 0, ai_visible_counts, ai_eval_context)
	check(pressure_cache.size() == pressure_cache_size and feed_cache.size() == feed_cache_size and is_equal_approx(float(cached_feed_report_contextual.get("score", -1.0)), float(feed_report_contextual.get("score", -2.0))), "AI pressure and feed contexts reuse generated cache keys")
	for code in scene.TILE_CODES + scene.FLOWER_CODES:
		check(FileAccess.file_exists(scene.tile_path(str(code))), "tile asset exists: " + str(code))
		check(scene.tile_textures.get(str(code), null) != null, "tile texture loads: " + str(code))
	for audio_key in ["bgm", "discard", "draw", "peng", "gang", "win"]:
		check(scene.audio_streams.get(audio_key, null) != null, "audio stream loads: " + str(audio_key))
	for voice_key in ["tile_5W", "tile_E", "tile_P", "action_peng", "action_zimo"]:
		check(scene.voice_streams.get(voice_key, null) != null, "bundled voice stream loads: " + str(voice_key))
	check(scene.bgm_player != null and scene.sfx_player != null and scene.action_sfx_player != null, "audio players are initialized")
	check(scene.audio_layer != null and scene.bgm_player.get_parent() == scene.audio_layer, "persistent audio layer owns background music")
	check(scene.BGM_STREAM_PATH.ends_with("bgm_guofeng2.mp3") and scene.audio_streams.get("bgm", null) is AudioStreamMP3, "background music uses the current MP3 default track")
	check(scene.lucide_icon_texture("settings") != null and scene.lucide_icon_texture("play") != null, "lucide SVG icons load for UI illustration")
	var coin_animation = scene.animation_asset_spec("coin_spin")
	var victory_animation = scene.animation_asset_spec("victory_sparkle")
	check(str(coin_animation.get("name", "")) == "Gold Coin Spin" and int(coin_animation.get("layer_count", 0)) >= 1, "coin animation JSON metadata loads for UI preview")
	check(str(victory_animation.get("name", "")) == "Victory Sparkle" and int(victory_animation.get("layer_count", 0)) >= 3, "victory animation JSON metadata loads for UI preview")
	check(scene.animation_duration_seconds("coin_spin") > 0.0 and scene.animation_duration_seconds("victory_sparkle") > scene.animation_duration_seconds("coin_spin"), "animation preview durations come from Lottie frame data")
	var bgm_mp3 = scene.bgm_player.stream as AudioStreamMP3
	check(bgm_mp3 != null and bgm_mp3.loop, "background music loops without restart gaps")
	check(scene.BGM_VOLUME_DB == 0.0, "background music keeps the configured default gain")
	check(scene.boosted_sfx_volume_db(-8.0) <= -5.0 and scene.boosted_sfx_volume_db(-1.0) <= 1.5, "mobile sfx boost is capped below clipping")
	check(scene.is_action_sfx("gang") and not scene.is_action_sfx("discard"), "frequent tile sfx reuse the persistent tile player")
	check(scene.voice_clip_key_for_tile("5W") == "tile_5W" and scene.voice_clip_key_for_action("暗杠") == "action_hidden_gang", "bundled voice clip keys cover tile and action speech")
	var one_shot_sfx = scene.make_one_shot_sfx_player(scene.audio_streams.get("discard", null), -1.0)
	check(one_shot_sfx.stream != null and one_shot_sfx.bus == "Master" and one_shot_sfx.process_mode == Node.PROCESS_MODE_ALWAYS and one_shot_sfx.get_parent() == scene.audio_layer, "one-shot sfx players use persistent game audio bus")
	var scaled_safe_margins = scene.safe_area_margins_for_viewport(Vector2(1280, 720), Vector2(2560, 1440), Rect2(Vector2(120, 48), Vector2(2320, 1320)))
	check(is_equal_approx(scaled_safe_margins.x, 60.0) and is_equal_approx(scaled_safe_margins.y, 24.0) and is_equal_approx(scaled_safe_margins.z, 60.0) and is_equal_approx(scaled_safe_margins.w, 36.0), "safe-area margins scale physical Android insets into stretched viewport space")
	var clamped_safe_margins = scene.safe_area_margins_for_viewport(Vector2(1280, 720), Vector2(1280, 720), Rect2(Vector2(500, 200), Vector2(100, 100)))
	check(clamped_safe_margins.x <= 1280.0 * scene.SAFE_CONTENT_MAX_SIDE_FRACTION + 0.5 and clamped_safe_margins.y <= 720.0 * scene.SAFE_CONTENT_MAX_TOP_FRACTION + 0.5 and clamped_safe_margins.w <= 720.0 * scene.SAFE_CONTENT_MAX_BOTTOM_FRACTION + 0.5, "safe-area margins are clamped to preserve usable table space")
	check(scene.safe_content_pixel_size_for_margins(Vector2(1280, 720), scene.SAFE_CONTENT_MIN_MARGIN) == Vector2(1256, 702), "safe content size subtracts minimum touch-edge margins")
	scene.clear_screen()
	check(is_instance_valid(one_shot_sfx) and not one_shot_sfx.is_queued_for_deletion(), "screen redraw keeps active one-shot audio alive")
	check(scene.screen_layer != null and scene.root_layer != null and scene.root_layer.get_parent() == scene.screen_layer, "screen redraw separates full-bleed background from safe content layer")
	check(is_equal_approx(scene.root_layer.offset_left, scene.safe_area_margins.x) and is_equal_approx(scene.root_layer.offset_top, scene.safe_area_margins.y) and is_equal_approx(scene.root_layer.offset_right, -scene.safe_area_margins.z) and is_equal_approx(scene.root_layer.offset_bottom, -scene.safe_area_margins.w), "safe content layer applies display safe-area offsets")
	one_shot_sfx.queue_free()
	check(not scene.android_tts_runtime_available(), "headless smoke test does not enter Android TTS path")
	check(not scene.speech_backend_ready(), "headless smoke test does not report TTS backend ready")
	scene.audio_touch_unlocked = false
	scene.wake_audio_from_interaction()
	check(scene.audio_touch_unlocked, "touch interaction unlocks audio startup path")
	check(scene.tile_speech_label("5W") == "五万" and scene.tile_speech_label("7T") == "七条", "number tile speech names are localized")
	check(scene.tile_speech_label("P") == "白板" and scene.tile_speech_label("F") == "发财", "honor tile speech names are complete")
	check(scene.tts_voice_identifier({"id": "zh-cn-default", "name": "fallback"}) == "zh-cn-default", "tts voice dictionaries use stable ids")
	scene.speech_queue.clear()
	scene.speech_queue_active = false
	scene.speak_tile_call("5W")
	check(scene.speech_queue.size() == 1 and str(scene.speech_queue[0].get("text", "")) == "五万", "tile speech is queued before TTS playback")
	check(float(scene.speech_queue[0].get("delay", 1.0)) <= 0.13, "tile speech is queued after the discard sound without being dropped")
	scene.speech_queue.clear()
	check(is_equal_approx(scene.AI_DRAW_DELAY_SECONDS, 0.35) and is_equal_approx(scene.AI_DISCARD_DELAY_SECONDS, 0.35) and is_equal_approx(scene.HUMAN_DRAW_DELAY_SECONDS, 0.006), "turn decision delays are tuned for faster operation")
	check(is_equal_approx(scene.HUMAN_DISCARD_RESPONSE_GAP_SECONDS, 0.01) and is_equal_approx(scene.AI_RETURN_TO_HUMAN_GAP_SECONDS, 0.08), "human discard feedback and AI return-to-human gaps stay short")
	check(is_equal_approx(scene.AI_ACTION_GAP_SECONDS, 0.35) and scene.AI_ACTION_GAP_SECONDS >= scene.SPEECH_TILE_DELAY_SECONDS + 0.12, "AI visible action gap gives discard audio room without making play feel stalled")
	check(scene.UI_RENDER_MIN_INTERVAL_MSEC == 16, "AI action redraws are coalesced to reduce stutter")
	check(scene.ONLINE_POLL_INTERVAL_MSEC >= 16 and scene.ONLINE_POLL_INTERVAL_MSEC <= 50, "online polling is throttled without adding visible input lag")
	check(scene.UPDATE_PROGRESS_INTERVAL_MSEC >= 80 and scene.UPDATE_PROGRESS_INTERVAL_MSEC <= 200, "download progress UI refresh is throttled to avoid per-frame churn")
	scene.mode = "menu"
	scene.next_online_poll_msec = 0
	scene.poll_online(1000)
	check(scene.next_online_poll_msec == 0, "offline frames skip online poll scheduling")
	scene.mode = "online_lobby"
	scene.next_online_poll_msec = 1050
	scene.poll_online(1000)
	check(scene.next_online_poll_msec == 1050, "online polling skips frames before the throttle window")
	scene.poll_online(1050)
	check(scene.next_online_poll_msec == 1050 + scene.ONLINE_POLL_INTERVAL_MSEC, "online polling advances the throttle window when due")
	scene.mode = "offline"
	scene.update_state = "downloading"
	scene.next_update_progress_msec = 1100
	scene.update_download_progress(1000)
	check(scene.next_update_progress_msec == 1100, "download progress skips frames before the refresh window")
	scene.update_download_progress(1100)
	check(scene.next_update_progress_msec == 1100 + scene.UPDATE_PROGRESS_INTERVAL_MSEC, "download progress advances the refresh window when due")
	scene.update_state = "downloading"
	scene.update_message = "正在下载测试包..."
	scene.update_downloaded_bytes = 512
	scene.update_total_bytes = 1024
	scene.update_release_notes = "第一条 UI 优化\n第二条 动画增强\n第三条 插画补齐"
	scene.ensure_update_dialog()
	check(scene.find_child("UpdateDialogArt", true, false) != null and scene.find_child("UpdateDialogArtRail", true, false) != null and scene.find_child("UpdateDialogArtFill", true, false) != null, "update dialog renders package progress illustration")
	check(scene.find_child("UpdateDialogPackageIcon", true, false) != null and scene.find_child("UpdateDialogStatusLight", true, false) != null and count_nodes_with_name_prefix(scene, "UpdateDialogPacketPip_") == 4, "update dialog renders package icon status light and packet pips")
	check(scene.find_child("UpdateDialogDownloadChannel", true, false) != null and scene.find_child("UpdateDialogVerifyNode", true, false) != null and count_nodes_with_name_prefix(scene, "UpdateDialogMovingPacket_") == 3, "update dialog renders download channel verify node and moving packets")
	check(scene.find_child("UpdateDialogVerifyRail", true, false) != null and scene.find_child("UpdateDialogVerifyFill", true, false) != null and count_nodes_with_name_prefix(scene, "UpdateDialogVerifyStep_") == 2, "update dialog renders verification rail and steps")
	check(count_nodes_with_name_prefix(scene, "UpdateDialogVerifyTick_") == 3, "update dialog renders verification ticks")
	check(scene.find_child("UpdateDialogStageMap", true, false) != null and scene.find_child("UpdateDialogStageRail", true, false) != null and scene.find_child("UpdateDialogStageFill", true, false) != null and scene.find_child("UpdateDialogStageGate", true, false) != null and count_nodes_with_name_prefix(scene, "UpdateDialogStageNode_") == 4, "update dialog renders stage map")
	check(scene.find_child("UpdateDialogStageNode_downloading", true, false) != null and scene.find_child("UpdateDialogStageGlyph_ready", true, false) != null, "update dialog stage map names download and verify stages")
	check(count_nodes_with_name_prefix(scene, "UpdateDialogStageTick_") == 3, "update dialog stage map renders route ticks")
	check(scene.find_child("UpdateReleaseNotesTexture", true, false) != null and scene.find_child("UpdateReleaseNotesArt", true, false) != null and scene.find_child("UpdateReleaseNotesRail", true, false) != null and scene.find_child("UpdateReleaseNotesFill", true, false) != null and scene.find_child("UpdateReleaseNotesLabel", true, false) != null, "update dialog renders reusable PNG release notes summary route")
	check(count_nodes_with_name_prefix(scene, "UpdateReleaseNotesTick_") == 3 and count_nodes_with_name_prefix(scene, "UpdateReleaseNotesNode_") == 2, "update dialog release notes art renders rhythm ticks and nodes")
	check(scene.find_child("UpdateReleaseNotesStageRoute", true, false) != null and scene.find_child("UpdateReleaseNotesStageFill", true, false) != null and scene.find_child("UpdateReleaseNotesStageGate", true, false) != null and count_nodes_with_name_prefix(scene, "UpdateReleaseNotesStageTick_") == 2, "update dialog release notes art links notes to stage route")
	check(scene.find_child("UpdateDialogButtonTexture_primary", true, false) != null and scene.find_child("UpdateDialogButtonTexture_secondary", true, false) != null and scene.find_child("UpdateDialogButtonArt_primary", true, false) != null and scene.find_child("UpdateDialogButtonRail_primary", true, false) != null and scene.find_child("UpdateDialogButtonFill_secondary", true, false) != null and scene.find_child("UpdateDialogButtonGate_secondary", true, false) != null, "update dialog buttons render reusable PNG action route art")
	check(count_nodes_with_name_prefix(scene, "UpdateDialogButtonTick_") == 4, "update dialog buttons render command rhythm ticks")
	check(scene.update_stage_index() == 1, "downloading update state highlights the download stage")
	var update_fill = scene.find_child("UpdateDialogArtFill", true, false) as Control
	check(update_fill != null and update_fill.anchor_right > 0.45 and update_fill.anchor_right < 0.55, "update dialog art fill tracks download progress")
	var update_stage_fill = scene.find_child("UpdateDialogStageFill", true, false) as Control
	var update_stage_gate = scene.find_child("UpdateDialogStageGate", true, false) as Control
	check(update_stage_fill != null and update_stage_fill.anchor_right > 0.30 and update_stage_fill.anchor_right < 0.36, "update dialog stage fill tracks active stage")
	check(update_stage_gate != null and update_stage_gate.anchor_left > 0.32 and update_stage_gate.anchor_left < 0.35, "update dialog stage gate follows active stage")
	check(scene.find_child("UpdatePackageTexture", true, false) != null, "update dialog renders reusable package PNG texture")
	scene.update_state = "idle"
	scene.show_toast("任务完成！+30金币", 1000)
	check(scene.find_child("ToastRibbonTexture", true, false) != null, "toast renders reusable ribbon PNG texture")
	check(scene.find_child("ToastIconSeal", true, false) != null and scene.find_child("ToastSheen", true, false) != null and count_nodes_with_name_prefix(scene, "ToastSpark_") == 3, "success toast renders icon seal sheen and reward sparks")
	check(scene.find_child("ToastMessageRoute", true, false) != null and scene.find_child("ToastMessageRouteFill", true, false) != null and scene.find_child("ToastTypeNode", true, false) != null and count_nodes_with_name_prefix(scene, "ToastMessageRouteNode_") == 3, "toast renders message route and type node")
	check(scene.find_child("ToastLifeRail", true, false) != null and scene.find_child("ToastLifeFill", true, false) != null and count_nodes_with_name_prefix(scene, "ToastStatusDot_") == 3, "toast renders lifetime rail fill and status dots")
	check(scene.find_child("ToastConfirmRoute", true, false) != null and scene.find_child("ToastConfirmFill", true, false) != null and scene.find_child("ToastConfirmGate", true, false) != null and count_nodes_with_name_prefix(scene, "ToastConfirmTick_") == 2, "toast renders confirmation route and ticks")
	check(scene.find_child("ToastAckBridge", true, false) != null and scene.find_child("ToastAckBridgeFill", true, false) != null and scene.find_child("ToastAckBridgeGate", true, false) != null and count_nodes_with_name_prefix(scene, "ToastAckBridgeTick_") == 2, "toast renders acknowledgement bridge route and ticks")
	check(scene.find_child("ToastRewardBridge", true, false) != null and scene.find_child("ToastRewardBridgeRail", true, false) != null and scene.find_child("ToastRewardBridgeFill", true, false) != null and scene.find_child("ToastRewardGate", true, false) != null, "reward toast renders reward bridge route")
	check(scene.find_child("ToastRewardSourceNode", true, false) != null and count_nodes_with_name_prefix(scene, "ToastRewardPip_") == 3 and count_nodes_with_name_prefix(scene, "ToastRewardTick_") == 2, "reward toast renders source node pips and rhythm ticks")
	check(scene.toast_icon_name("钻石不足") == "triangle-alert" and scene.toast_icon_name("正在下载更新") == "download", "toast illustrations choose contextual icons")
	scene.show_toast("购买成功！获得换牌卡", 1000)
	check(scene.toast_item_key_for_text("购买成功！获得换牌卡") == "swap_card" and scene.find_child("ToastItemActivationTexture", true, false) != null and scene.find_child("ToastItemBadge", true, false) != null and count_nodes_with_name_prefix(scene, "ToastItemPip_") == 3, "item toast renders reusable PNG charm item badge and stock pips")
	check(scene.find_child("ToastItemActivationRoute", true, false) != null and scene.find_child("ToastItemActivationFill", true, false) != null and scene.find_child("ToastItemActivationGate", true, false) != null and count_nodes_with_name_prefix(scene, "ToastItemActivationTick_") == 2, "item toast renders activation route and ticks")
	scene.inventory = {"swap_card": 1}
	check(scene.use_item("swap_card") and int(scene.inventory.get("swap_card", 0)) == 0 and scene.find_child("ToastItemCore", true, false) != null, "using an item decrements inventory and renders item toast art")
	check(scene.find_child("ToastItemActivationRoute", true, false) != null and scene.find_child("ToastItemActivationFill", true, false) != null and count_nodes_with_name_prefix(scene, "ToastItemActivationTick_") >= 2, "using an item renders activation route feedback")
	var coins_before_task_reward = int(scene.currency.get("coins", 0))
	scene.claim_task_reward({"reward_coins": 25})
	check(int(scene.currency.get("coins", 0)) == coins_before_task_reward + 25 and scene.find_child("ToastIconSeal", true, false) != null, "task reward updates currency and renders illustrated toast")
	scene.achievements["first_win"] = false
	check(scene.achievement_display_name("first_win") == "首次胡牌" and scene.unlock_achievement("first_win"), "achievement unlock maps keys to display names and succeeds once")
	check(scene.find_child("ToastAchievementGlowTexture", true, false) != null, "achievement unlock toast renders reusable medal glow PNG texture")
	check(scene.find_child("ToastAchievementMedal", true, false) != null and scene.find_child("ToastAchievementMedalCore", true, false) != null and count_nodes_with_name_prefix(scene, "ToastAchievementRay_") == 4, "achievement unlock toast renders medal and rays")
	check(scene.find_child("ToastAchievementUnlockRoute", true, false) != null and scene.find_child("ToastAchievementUnlockFill", true, false) != null and scene.find_child("ToastAchievementUnlockGate", true, false) != null and count_nodes_with_name_prefix(scene, "ToastAchievementUnlockTick_") == 3, "achievement unlock toast renders unlock route and rhythm ticks")
	check(not scene.unlock_achievement("first_win"), "achievement unlock does not replay for already unlocked achievements")
	scene.play_screen_transition(func() -> void:
		pass
	, false, "curtain")
	check(scene.find_child("CurtainStrips", true, false) != null and scene.find_child("CurtainTopRail", true, false) != null and scene.find_child("CurtainCloseGate", true, false) != null, "curtain transition renders rail and close gate")
	check(count_nodes_with_name_prefix(scene, "CurtainBead_") == 6 and count_nodes_with_name_prefix(scene, "CurtainCloseTick_") == 6, "curtain transition renders one bead and close tick per strip")
	scene.clear_fx_overlays()
	var curtain_strips = scene.find_child("CurtainStrips", true, false)
	if curtain_strips != null:
		curtain_strips.queue_free()
	scene.play_screen_transition(func() -> void:
		pass
	, false, "ink_wash")
	check(scene.find_child("InkWashTransitionArt", true, false) != null and scene.find_child("InkWashSpine", true, false) != null and scene.find_child("InkWashFill", true, false) != null and scene.find_child("InkWashCompletionGate", true, false) != null, "ink wash transition renders spine fill and completion gate")
	check(count_nodes_with_name_prefix(scene, "InkWashBlot_") == 4 and count_nodes_with_name_prefix(scene, "InkWashTick_") == 3, "ink wash transition renders blot rhythm art")
	scene.clear_fx_overlays()
	var ink_wash_art = scene.find_child("InkWashTransitionArt", true, false)
	if ink_wash_art != null:
		ink_wash_art.queue_free()
	scene.play_screen_transition(func() -> void:
		pass
	, false, "fade")
	check(scene.find_child("FadeTransitionArt", true, false) != null and scene.find_child("FadeTransitionRail", true, false) != null and scene.find_child("FadeTransitionFill", true, false) != null and scene.find_child("FadeTransitionGate", true, false) != null, "fade transition renders progress rail fill and gate")
	check(count_nodes_with_name_prefix(scene, "FadeTransitionTick_") == 3, "fade transition renders rhythm ticks")
	scene.clear_fx_overlays()
	var fade_art = scene.find_child("FadeTransitionArt", true, false)
	if fade_art != null:
		fade_art.queue_free()
	scene.game_render_queued = false
	check(not scene.should_yield_before_ai_discard(), "AI skips pre-discard frame yield when no render is queued")
	scene.game_render_queued = true
	check(scene.should_yield_before_ai_discard(), "AI yields before discard only when a coalesced render is queued")
	scene.game_render_queued = false
	scene.music_enabled = true
	scene.sfx_enabled = true
	scene.tts_enabled = true
	scene.fast_mode_enabled = true
	check(scene.ai_draw_delay() == scene.AI_DRAW_DELAY_SECONDS and scene.ai_discard_delay() == scene.AI_DISCARD_DELAY_SECONDS and scene.ai_action_gap_delay() == scene.AI_ACTION_GAP_SECONDS and scene.human_discard_response_gap_delay() == scene.HUMAN_DISCARD_RESPONSE_GAP_SECONDS and scene.ai_return_to_human_gap_delay() == scene.AI_RETURN_TO_HUMAN_GAP_SECONDS, "fast mode uses short decision delays with audible AI action pacing")
	scene.fast_mode_enabled = false
	check(is_equal_approx(scene.ai_draw_delay(), 0.18) and is_equal_approx(scene.ai_discard_delay(), 0.35) and is_equal_approx(scene.ai_action_gap_delay(), 0.35) and is_equal_approx(scene.human_discard_response_gap_delay(), 0.05) and is_equal_approx(scene.ai_return_to_human_gap_delay(), 0.12) and is_equal_approx(scene.human_draw_delay(), 0.08), "steady mode uses the configured readable delays")
	scene.music_enabled = false
	scene.sfx_enabled = false
	scene.tts_enabled = false
	scene.fast_mode_enabled = false
	scene.save_settings()
	scene.music_enabled = true
	scene.sfx_enabled = true
	scene.tts_enabled = true
	scene.fast_mode_enabled = true
	scene.load_settings()
	check(not scene.music_enabled and not scene.sfx_enabled and not scene.tts_enabled and not scene.fast_mode_enabled, "settings persist audio and speed toggles")
	scene.music_enabled = true
	scene.sfx_enabled = true
	scene.tts_enabled = true
	scene.fast_mode_enabled = true
	scene.save_settings()
	var setting_button = scene.make_setting_button("音乐", true, Callable())
	check(setting_button.text == "音乐开", "setting button labels enabled state")
	check(setting_button.action_mode == BaseButton.ACTION_MODE_BUTTON_PRESS, "setting buttons trigger on press for mobile responsiveness")
	check(not setting_button.button_down.is_connected(scene.wake_audio_from_interaction), "touch buttons rely on global input to wake audio")
	check(setting_button.find_child("SettingSwitchArt", true, false) != null and setting_button.find_child("SettingSwitchRail", true, false) != null and setting_button.find_child("SettingSwitchKnobOn", true, false) != null, "enabled setting buttons render switch illustration")
	check(setting_button.find_child("SettingSwitchEnergyRail", true, false) != null and setting_button.find_child("SettingSwitchEnergyFill", true, false) != null and count_nodes_with_name_prefix(setting_button, "SettingSwitchStateSpark_") == 2, "enabled setting buttons render energy rail and state sparks")
	check(setting_button.find_child("SettingSwitchDirectionRoute", true, false) != null and setting_button.find_child("SettingSwitchDirectionFill", true, false) != null and setting_button.find_child("SettingSwitchDirectionGate", true, false) != null and count_nodes_with_name_prefix(setting_button, "SettingSwitchDirectionTick_") == 2, "enabled setting buttons render direction route and ticks")
	setting_button.queue_free()
	var disabled_setting_button = scene.make_setting_button("音乐", false, Callable())
	check(disabled_setting_button.text == "音乐关" and disabled_setting_button.find_child("SettingSwitchKnobOff", true, false) != null, "disabled setting buttons render off switch illustration")
	check(disabled_setting_button.find_child("SettingSwitchOffLock", true, false) != null and disabled_setting_button.find_child("SettingSwitchEnergyFill", true, false) != null, "disabled setting buttons render lock and dim energy fill")
	check(disabled_setting_button.find_child("SettingSwitchDirectionRoute", true, false) != null and disabled_setting_button.find_child("SettingSwitchDirectionFill", true, false) != null and disabled_setting_button.find_child("SettingSwitchDirectionGate", true, false) != null and count_nodes_with_name_prefix(disabled_setting_button, "SettingSwitchDirectionTick_") == 2, "disabled setting buttons render reverse direction route and ticks")
	disabled_setting_button.queue_free()
	var label_parent = Control.new()
	root.add_child(label_parent)
	var default_label = scene.make_label(label_parent, "普通 UI 标签", 16, Color.WHITE, false)
	check(default_label.autowrap_mode == TextServer.AUTOWRAP_OFF, "default labels avoid automatic wrapping for cheaper UI layout")
	check(default_label.mouse_filter == Control.MOUSE_FILTER_IGNORE and labels_ignore_mouse(label_parent), "default labels skip mouse hit testing")
	label_parent.queue_free()
	var form_label_parent = VBoxContainer.new()
	root.add_child(form_label_parent)
	var form_edit = scene.add_line_edit(form_label_parent, "昵称", "云桌道友")
	check(form_edit is LineEdit and labels_ignore_mouse(form_label_parent), "line-edit captions skip mouse hit testing")
	check(form_edit.find_child("LineEditInputArt_name", true, false) != null and form_edit.find_child("LineEditInputRail_name", true, false) != null and form_edit.find_child("LineEditInputFocusNode_name", true, false) != null, "line edits render input rail illustration")
	check(count_nodes_with_name_prefix(form_edit, "LineEditInputPulse_name_") == 2, "line edits render input pulse accents")
	check(form_edit.find_child("LineEditInputTargetRoute_name", true, false) != null and form_edit.find_child("LineEditInputTargetFill_name", true, false) != null and form_edit.find_child("LineEditInputTargetGate_name", true, false) != null and count_nodes_with_name_prefix(form_edit, "LineEditInputTargetTick_name_") == 2, "line edits render target route and ticks")
	check(form_edit.find_child("LineEditInputValueRoute_name", true, false) != null and form_edit.find_child("LineEditInputValueFill_name", true, false) != null and form_edit.find_child("LineEditInputValueGate_name", true, false) != null and count_nodes_with_name_prefix(form_edit, "LineEditInputValueTick_name_") == 2, "line edits render value route and ticks")
	form_label_parent.queue_free()
	var panel_parent = Control.new()
	root.add_child(panel_parent)
	var decorative_panel = scene.make_panel(panel_parent, scene.rect_full(0.1, 0.1, 0.9, 0.9), Color(0.1, 0.2, 0.3), 8, Color(0.4, 0.5, 0.6))
	check(decorative_panel.mouse_filter == Control.MOUSE_FILTER_IGNORE and panels_ignore_mouse(panel_parent), "decorative panels skip mouse hit testing")
	check(panel_shadow_size(decorative_panel) == 4, "default panels keep depth shadow unless marked lightweight")
	panel_parent.queue_free()
	var passive_row = HBoxContainer.new()
	scene.configure_passive_container(passive_row)
	check(passive_row.mouse_filter == Control.MOUSE_FILTER_IGNORE, "passive container helper skips mouse hit testing")
	passive_row.queue_free()
	var background_parent = Control.new()
	root.add_child(background_parent)
	scene.add_background(background_parent)
	check(count_texture_rects(background_parent) >= 1 and texture_rects_ignore_mouse(background_parent), "decorative background textures skip mouse hit testing")
	check(count_color_rects(background_parent) >= 3 and color_rects_ignore_mouse(background_parent), "decorative background color overlays skip mouse hit testing")
	background_parent.queue_free()
	var decorative_texture_parent = Control.new()
	root.add_child(decorative_texture_parent)
	var decorative_texture = scene.add_texture(decorative_texture_parent, scene.wood_texture, scene.rect_full(0.0, 0.0, 1.0, 1.0), 0.5)
	check(decorative_texture.mouse_filter == Control.MOUSE_FILTER_IGNORE, "decorative table textures skip mouse hit testing")
	decorative_texture_parent.queue_free()
	var quick_press_count := {"value": 0}
	var quick_button = scene.make_small_button("快按", Color(0.24, 0.60, 0.45), func() -> void:
		quick_press_count["value"] = int(quick_press_count.get("value", 0)) + 1
	)
	check(quick_button.find_child("ButtonPressSheen", true, false) != null, "small buttons render a press sheen overlay")
	scene.play_button_press_animation(quick_button)
	check(quick_button.find_child("ButtonPressFeedback", true, false) != null and quick_button.find_child("ButtonPressFeedbackRail", true, false) != null and quick_button.find_child("ButtonPressFeedbackFill", true, false) != null and quick_button.find_child("ButtonPressFeedbackGate", true, false) != null, "button press animation renders feedback rail fill and gate")
	check(count_nodes_with_name_prefix(quick_button, "ButtonPressFeedbackTick_") == 2, "button press animation renders rhythm ticks")
	quick_button.emit_signal("button_down")
	check(int(quick_press_count.get("value", 0)) == 1, "buttons run callbacks on button down for mobile responsiveness")
	quick_button.queue_free()
	var hud_press_count := {"value": 0}
	var top_button = scene.make_top_hud_button("设置", Color(0.22, 0.42, 0.54), func() -> void:
		hud_press_count["value"] = int(hud_press_count.get("value", 0)) + 1
	)
	check(top_button.custom_minimum_size == scene.TOP_HUD_BUTTON_SIZE and top_button.clip_text, "top HUD buttons keep mobile touch target and clipped labels")
	check(top_button.find_child("ButtonPressSheen", true, false) != null, "top HUD buttons render a press sheen overlay")
	check(top_button.find_child("TopHudButtonCommandRoute_设置", true, false) != null and top_button.find_child("TopHudButtonCommandFill_设置", true, false) != null and top_button.find_child("TopHudButtonCommandGate_设置", true, false) != null and count_nodes_with_name_prefix(top_button, "TopHudButtonCommandTick_设置_") == 2, "top HUD buttons render command route feedback")
	top_button.emit_signal("button_down")
	check(int(hud_press_count.get("value", 0)) == 1, "top HUD buttons trigger on button down")
	top_button.queue_free()
	var menu_press_count := {"value": 0}
	var menu_callback = func() -> void:
		menu_press_count["value"] = int(menu_press_count.get("value", 0)) + 1
	var menu_card = scene.make_menu_card("测试", Color(0.30, 0.50, 0.70), menu_callback, "play")
	menu_card.emit_signal("button_down")
	check(int(menu_press_count.get("value", 0)) == 1, "menu cards run callbacks on button down")
	check(count_texture_rects(menu_card) >= 1, "menu cards render lucide SVG illustration icons")
	check(menu_card.find_child("MenuCardEntryArt", true, false) != null and menu_card.find_child("MenuCardEntryRail", true, false) != null and menu_card.find_child("MenuCardEntryFocus", true, false) != null, "menu cards render entry route art")
	check(count_nodes_with_name_prefix(menu_card, "MenuCardEntryNode_") == 3 and count_nodes_with_name_prefix(menu_card, "MenuCardEntrySpark_") == 3, "menu cards render route nodes and entry sparks")
	check(menu_card.find_child("MenuCardEntryConfirmRoute", true, false) != null and menu_card.find_child("MenuCardEntryConfirmFill", true, false) != null and menu_card.find_child("MenuCardEntryConfirmGate", true, false) != null and count_nodes_with_name_prefix(menu_card, "MenuCardEntryConfirmTick_") == 2, "menu cards render title-to-entry confirmation route")
	menu_card.queue_free()
	var card_flip_parent = Control.new()
	root.add_child(card_flip_parent)
	var flip_card_a = scene.make_panel(card_flip_parent, scene.rect_full(0.0, 0.0, 0.3, 0.2), Color(0.02, 0.04, 0.05), 8, Color(0.5, 0.4, 0.2), 0)
	var flip_card_b = scene.make_panel(card_flip_parent, scene.rect_full(0.35, 0.0, 0.65, 0.2), Color(0.02, 0.04, 0.05), 8, Color(0.5, 0.4, 0.2), 0)
	scene.play_card_flip_animation(card_flip_parent, [flip_card_a, flip_card_b], true)
	check(flip_card_a.find_child("CardFlipEntryArt_0", true, false) != null and flip_card_a.find_child("CardFlipEntryRail_0", true, false) != null and flip_card_a.find_child("CardFlipEntryFill_0", true, false) != null and flip_card_a.find_child("CardFlipEntryGate_0", true, false) != null, "card flip animation renders entry route art on the first card")
	check(flip_card_b.find_child("CardFlipEntryArt_1", true, false) != null and count_nodes_with_name_prefix(card_flip_parent, "CardFlipEntryTick_") == 4, "card flip animation renders indexed entry ticks for staggered cards")
	check(flip_card_a.find_child("CardFlipEntrySpine_0", true, false) != null and flip_card_a.find_child("CardFlipEntryFocus_0", true, false) != null and flip_card_a.find_child("CardFlipEntryCompletionGate_0", true, false) != null, "card flip animation renders spine focus and completion gate")
	check(count_nodes_with_name_prefix(card_flip_parent, "CardFlipEntryCompletionPip_") == 6, "card flip animation renders completion pips for every staggered card")
	card_flip_parent.queue_free()
	var animation_preview_parent = Control.new()
	root.add_child(animation_preview_parent)
	var coin_preview = scene.draw_animation_preview(animation_preview_parent, scene.rect_full(0.0, 0.0, 0.2, 0.2), "coin_spin")
	var victory_preview = scene.draw_animation_preview(animation_preview_parent, scene.rect_full(0.2, 0.0, 0.4, 0.2), "victory_sparkle")
	check(coin_preview != null and animation_preview_parent.find_child("AnimationPreview_coin_spin", true, false) != null and count_texture_rects(coin_preview) >= 1, "coin animation JSON renders a native coin illustration preview")
	check(victory_preview != null and animation_preview_parent.find_child("AnimationPreview_victory_sparkle", true, false) != null and has_label_text(victory_preview, "✦"), "victory animation JSON renders native sparkle illustration preview")
	check(coin_preview.find_child("AnimationPreviewTimeline_coin_spin", true, false) != null and coin_preview.find_child("AnimationPreviewTimelineRail_coin_spin", true, false) != null and coin_preview.find_child("AnimationPreviewTimelineFill_coin_spin", true, false) != null and coin_preview.find_child("AnimationPreviewPlayGate_coin_spin", true, false) != null, "coin animation preview renders timeline rail fill and play gate")
	check(victory_preview.find_child("AnimationPreviewTimeline_victory_sparkle", true, false) != null and victory_preview.find_child("AnimationPreviewTimelineRail_victory_sparkle", true, false) != null and victory_preview.find_child("AnimationPreviewTimelineFill_victory_sparkle", true, false) != null and victory_preview.find_child("AnimationPreviewPlayGate_victory_sparkle", true, false) != null, "victory animation preview renders timeline rail fill and play gate")
	check(count_nodes_with_name_prefix(animation_preview_parent, "AnimationPreviewKeyframe_") == 6 and count_nodes_with_name_prefix(animation_preview_parent, "AnimationPreviewTempoTick_") == 4, "animation previews render keyframes and tempo ticks from JSON timing")
	animation_preview_parent.queue_free()
	var illustration_parent = Control.new()
	root.add_child(illustration_parent)
	var win_art = scene.draw_win_celebration_art(illustration_parent, Color(0.90, 0.72, 0.30), "special")
	check(illustration_parent.find_child("WinFanfareTexture", true, false) != null, "win celebration art renders reusable fanfare PNG texture")
	check(win_art != null and illustration_parent.find_child("WinCelebrationArt", true, false) != null and illustration_parent.find_child("WinCelebrationMedal", true, false) != null, "win celebration art renders medal layer")
	check(illustration_parent.find_child("WinCelebrationTrack", true, false) != null and illustration_parent.find_child("WinCelebrationTrackFill", true, false) != null and illustration_parent.find_child("WinCelebrationScoreGate", true, false) != null and illustration_parent.find_child("WinCelebrationMedalNode", true, false) != null, "win celebration art renders energy track fill and score gate")
	check(count_nodes_with_name_prefix(illustration_parent, "WinCelebrationTrackTick_") == 3, "win celebration art renders track rhythm ticks")
	check(illustration_parent.find_child("WinCelebrationSpecialCrown", true, false) != null and count_nodes_with_name_prefix(illustration_parent, "WinCelebrationStar_") == 10, "special win celebration renders crown and ten stars")
	win_art.queue_free()
	scene.ensure_fx_layer()
	scene.clear_win_burst_dynamic_art()
	scene.play_fx_win_burst_enhanced("自摸", Color(0.90, 0.72, 0.30), "self_draw")
	check(scene.find_child("WinCelebrationArt", true, false) != null and scene.find_child("WinCelebrationSelfDrawOrbit", true, false) != null and scene.find_child("WinCelebrationSeal", true, false) != null, "enhanced win burst creates self-draw celebration art in fx layer")
	check(count_nodes_with_name_prefix(scene, "WinCelebrationStar_") >= 8, "enhanced win burst creates animated celebration stars")
	var menu_hero = scene.draw_menu_hero_illustration(illustration_parent)
	check(menu_hero != null and illustration_parent.find_child("MenuHeroIllustration", true, false) != null and illustration_parent.find_child("MenuHeroRoundTable", true, false) != null, "menu hero renders native guofeng table illustration")
	check(illustration_parent.find_child("MenuHeroPaintedBackdrop", true, false) != null and illustration_parent.find_child("MenuHeroPaintedBackdropWash", true, false) != null, "menu hero renders reusable painted PNG backdrop")
	check(illustration_parent.find_child("MenuHeroSeal", true, false) != null and count_texture_rects(menu_hero) >= 3, "menu hero illustration combines seal, SVG icon, and tile art")
	check(illustration_parent.find_child("MenuHeroWindPath", true, false) != null and illustration_parent.find_child("MenuHeroWindPathRail", true, false) != null and illustration_parent.find_child("MenuHeroWindPathFill", true, false) != null and illustration_parent.find_child("MenuHeroWindPathGate", true, false) != null, "menu hero renders animated wind path illustration")
	check(count_nodes_with_name_prefix(illustration_parent, "MenuHeroWindPathTick_") == 4 and count_nodes_with_name_prefix(illustration_parent, "MenuHeroWindLeaf_") == 3, "menu hero wind path renders rhythm ticks and drifting leaves")
	var table_frame = scene.draw_table_atmosphere_frame(illustration_parent)
	check(table_frame != null and illustration_parent.find_child("TableAtmosphereFrame", true, false) != null and illustration_parent.find_child("TableBambooLeft", true, false) != null, "table atmosphere frame renders bamboo and cloud ornaments")
	check(illustration_parent.find_child("TableInkWashTexture", true, false) != null, "table atmosphere frame renders reusable ink-wash PNG texture")
	check(illustration_parent.find_child("TableAtmosphereBreathRoute", true, false) != null and illustration_parent.find_child("TableAtmosphereBreathFill", true, false) != null and illustration_parent.find_child("TableAtmosphereBreathGate", true, false) != null, "table atmosphere frame renders ambient breath route")
	check(count_nodes_with_name_prefix(illustration_parent, "TableAtmosphereBreathTick_") == 4, "table atmosphere frame renders breath rhythm ticks")
	scene.last_discard = "S"
	scene.last_discard_seat = 3
	scene.players[3]["discards"] = ["Z", "F", "P", "S"]
	var living_table = scene.draw_table_living_illustration(illustration_parent)
	check(living_table != null and illustration_parent.find_child("TableLivingIllustration", true, false) != null and count_nodes_with_name_prefix(illustration_parent, "TableWallLantern_") == 4, "table living illustration renders wall lanterns")
	check(illustration_parent.find_child("TableWallPressureRoute", true, false) != null and count_nodes_with_name_prefix(illustration_parent, "TableWallPressureSegment_") == 4 and illustration_parent.find_child("TableWallPressureFill", true, false) != null and illustration_parent.find_child("TableWallPressureGate", true, false) != null, "table living illustration renders wall pressure route")
	check(count_nodes_with_name_prefix(illustration_parent, "TableWallPressureTick_") == 4, "table living illustration renders wall pressure rhythm ticks")
	check(illustration_parent.find_child("TableTurnFlowSeal", true, false) != null and illustration_parent.find_child("TableTurnFlowRibbon", true, false) != null, "table living illustration renders current-turn flow art")
	check(illustration_parent.find_child("TableTurnFlowRoute", true, false) != null and illustration_parent.find_child("TableTurnFlowRouteFill", true, false) != null and illustration_parent.find_child("TableTurnFlowGate", true, false) != null, "table living illustration renders current-turn route")
	check(count_nodes_with_name_prefix(illustration_parent, "TableTurnFlowTick_") == 3, "table living illustration renders current-turn rhythm ticks")
	check(illustration_parent.find_child("TableLastDiscardRipple", true, false) != null and count_nodes_with_name_prefix(illustration_parent, "TableLastDiscardRippleRing_") == 3, "table living illustration renders last-discard ripple rings")
	check(illustration_parent.find_child("TableLastDiscardRoute", true, false) != null and illustration_parent.find_child("TableLastDiscardRouteFill", true, false) != null and illustration_parent.find_child("TableLastDiscardSourceNode", true, false) != null and illustration_parent.find_child("TableLastDiscardResponseGate", true, false) != null, "table living illustration renders last-discard response route")
	check(count_nodes_with_name_prefix(illustration_parent, "TableLastDiscardRouteTick_") == 4, "table living illustration renders last-discard response ticks")
	check(illustration_parent.find_child("TableCenterStarlight", true, false) != null and count_nodes_with_name_prefix(illustration_parent, "TableCenterStarlightSpark_") == 8, "table living illustration renders center starlight sparks")
	check(illustration_parent.find_child("TableRoundTempoArt", true, false) != null and illustration_parent.find_child("TableRoundTempoRail", true, false) != null and illustration_parent.find_child("TableRoundTempoFill", true, false) != null and illustration_parent.find_child("TableRoundTempoGate", true, false) != null, "table living illustration renders round tempo route")
	check(count_nodes_with_name_prefix(illustration_parent, "TableRoundTempoNode_") == scene.MATCH_MAX_HANDS and illustration_parent.find_child("TableRoundTempoCursor", true, false) != null and count_nodes_with_name_prefix(illustration_parent, "TableRoundTempoTick_") == 3, "table round tempo renders hand nodes cursor and rhythm ticks")
	var compass = scene.draw_center_wind_compass(illustration_parent)
	check(compass != null and illustration_parent.find_child("CenterWindCompass", true, false) != null and illustration_parent.find_child("CenterWindCompass_东", true, false) != null, "center wind compass renders directional illustration badges")
	check(illustration_parent.find_child("CenterWindActiveHalo", true, false) != null and illustration_parent.find_child("CenterWindNextBadge", true, false) != null and illustration_parent.find_child("CenterWindTurnTrack", true, false) != null, "center wind compass renders active turn halo and next-seat cue")
	check(illustration_parent.find_child("CenterWindDealerBadge", true, false) != null and illustration_parent.find_child("CenterWindCurrentPointer", true, false) != null and count_nodes_with_name_prefix(illustration_parent, "CenterWindDirectionBead_") == 4, "center wind compass renders dealer marker, current pointer, and turn-direction beads")
	var center_previous_phase = scene.offline_phase
	var center_previous_seat = scene.current_seat
	var center_previous_turn_needs_draw = scene.offline_turn_needs_draw
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.current_seat = 0
	scene.offline_turn_needs_draw = false
	var phase_ribbon = scene.draw_center_phase_ribbon(illustration_parent)
	check(phase_ribbon != null and illustration_parent.find_child("CenterPhaseRibbon", true, false) != null and illustration_parent.find_child("CenterPhaseSeal", true, false) != null and illustration_parent.find_child("CenterPhasePulse", true, false) != null, "center panel renders a phase ribbon with seal and pulse art")
	check(illustration_parent.find_child("CenterPhaseFlowArt", true, false) != null and illustration_parent.find_child("CenterPhaseFlowRail", true, false) != null and illustration_parent.find_child("CenterPhaseFlowFill", true, false) != null, "center phase ribbon renders phase flow meter")
	check(count_nodes_with_name_prefix(illustration_parent, "CenterPhaseFlowNode_") == 4 and illustration_parent.find_child("CenterPhaseFlowCursor", true, false) != null, "center phase ribbon renders flow nodes and cursor")
	check(illustration_parent.find_child("CenterPhaseSourceNode", true, false) != null and illustration_parent.find_child("CenterPhaseConfirmRoute", true, false) != null and illustration_parent.find_child("CenterPhaseConfirmFill", true, false) != null and illustration_parent.find_child("CenterPhaseConfirmGate", true, false) != null, "center phase ribbon renders confirmation route and gate")
	check(count_nodes_with_name_prefix(illustration_parent, "CenterPhaseConfirmTick_") == 2, "center phase ribbon renders confirmation rhythm ticks")
	check(has_label_text(phase_ribbon, "我方出牌"), "center phase ribbon names the human discard state")
	scene.offline_phase = "pending_claim"
	check(scene.center_phase_key() == "claim" and scene.center_phase_label("claim") == "响应窗口", "center phase mapping names claim response windows")
	check(scene.center_phase_flow_index("discard") == 0 and scene.center_phase_flow_index("claim") == 1 and scene.center_phase_flow_index("wait") == 2 and scene.center_phase_flow_index("ended") == 3, "center phase flow indexes match the visible turn sequence")
	scene.offline_phase = "ended"
	check(scene.center_phase_key() == "ended" and scene.center_phase_label("ended") == "结算", "center phase mapping names round settlement")
	scene.offline_phase = "await_discard"
	scene.current_seat = 1
	check(scene.center_phase_key() == "wait" and scene.center_phase_label("wait") == "对手行牌", "center phase mapping names opponent turns")
	scene.offline_phase = center_previous_phase
	scene.current_seat = center_previous_seat
	scene.offline_turn_needs_draw = center_previous_turn_needs_draw
	var ribbon = scene.draw_summary_victory_ribbon(illustration_parent)
	check(ribbon != null and illustration_parent.find_child("SummaryVictoryRibbon", true, false) != null and count_texture_rects(ribbon) >= 1, "round summary renders victory ribbon illustration")
	var summary_previous_hand_number = scene.offline_hand_number
	scene.last_score_deltas = [-1200, 3600, -1200, -1200]
	scene.offline_last_winner = 1
	scene.offline_hand_number = 3
	var summary_ambience = scene.draw_round_summary_ambience(illustration_parent)
	check(summary_ambience != null and illustration_parent.find_child("RoundSummaryAmbience", true, false) != null and illustration_parent.find_child("RoundSummaryScoreOrbit", true, false) != null, "round summary ambience renders score orbit art")
	check(illustration_parent.find_child("RoundSummaryVictoryBadgeTexture", true, false) != null, "round summary ambience renders reusable victory badge PNG texture")
	check(illustration_parent.find_child("RoundSummaryWinnerBeacon", true, false) != null and illustration_parent.find_child("RoundSummaryWinnerBeaconSeal", true, false) != null, "round summary ambience renders winner beacon")
	check(count_nodes_with_name_prefix(illustration_parent, "RoundSummaryScoreNode_") == 4 and count_nodes_with_name_prefix(illustration_parent, "RoundSummaryDeltaSpark_") == 4, "round summary ambience renders one score node and delta spark per changed seat")
	check(illustration_parent.find_child("RoundSummarySettlementRoute", true, false) != null and illustration_parent.find_child("RoundSummarySettlementFill", true, false) != null and illustration_parent.find_child("RoundSummarySettlementGate", true, false) != null, "round summary ambience renders winner-to-settlement route")
	check(count_nodes_with_name_prefix(illustration_parent, "RoundSummarySettlementTick_") == 3, "round summary ambience renders settlement rhythm ticks")
	check(illustration_parent.find_child("RoundSummaryNextHandGate", true, false) != null and count_nodes_with_name_prefix(illustration_parent, "RoundSummaryNextHandPip_") == 3, "round summary ambience renders next-hand gate pips")
	scene.offline_hand_number = summary_previous_hand_number
	scene.players[1]["name"] = "青竹道人"
	var win_detail_parent = Control.new()
	root.add_child(win_detail_parent)
	scene.draw_win_detail_section(win_detail_parent, {
		"winner": 1,
		"fan": 4,
		"points": 3200,
		"reasons": ["平胡", "自摸", "花牌"],
		"win_tile": "5W",
		"self_draw": true,
	})
	check(win_detail_parent.find_child("WinDetailScrollTexture", true, false) != null, "win detail renders reusable scroll PNG texture")
	check(win_detail_parent.find_child("WinDetailShowcase", true, false) != null and win_detail_parent.find_child("WinDetailTile", true, false) != null and win_detail_parent.find_child("WinDetailSeal", true, false) != null, "win detail renders tile showcase and seal")
	check(win_detail_parent.find_child("WinDetailShowcaseRoute", true, false) != null and win_detail_parent.find_child("WinDetailShowcaseRouteFill", true, false) != null and win_detail_parent.find_child("WinDetailShowcaseScoreGate", true, false) != null, "win detail showcase renders tile-to-score route")
	check(count_nodes_with_name_prefix(win_detail_parent, "WinDetailShowcaseRouteTick_") == 3 and count_nodes_with_name_prefix(win_detail_parent, "WinDetailShowcaseFanPip_") == 4, "win detail showcase renders route rhythm ticks and fan pips")
	check(win_detail_parent.find_child("WinDetailYakuTrack", true, false) != null and win_detail_parent.find_child("WinDetailYakuRail", true, false) != null and count_nodes_with_name_prefix(win_detail_parent, "WinDetailYakuNode_") == 3, "win detail renders yaku track rail and one node per reason")
	check(win_detail_parent.find_child("WinDetailYakuLeadGlow", true, false) != null, "win detail highlights the leading yaku track node")
	check(win_detail_parent.find_child("WinDetailYakuRailFill", true, false) != null and win_detail_parent.find_child("WinDetailYakuGate", true, false) != null and count_nodes_with_name_prefix(win_detail_parent, "WinDetailYakuTick_") == 3, "win detail yaku track renders fill gate and rhythm ticks")
	var win_yaku_fill = win_detail_parent.find_child("WinDetailYakuRailFill", true, false) as Control
	check(win_yaku_fill != null and win_yaku_fill.anchor_right > 0.55 and win_yaku_fill.anchor_right < 0.65, "win detail yaku rail fill tracks yaku count")
	check(win_detail_parent.find_child("WinDetailScoreConstellation", true, false) != null and win_detail_parent.find_child("WinDetailScoreArc", true, false) != null and win_detail_parent.find_child("WinDetailScoreCore", true, false) != null and win_detail_parent.find_child("WinDetailScorePulse", true, false) != null, "win detail renders score constellation art")
	check(count_nodes_with_name_prefix(win_detail_parent, "WinDetailScoreStar_") == 3 and win_detail_parent.find_child("WinDetailScorePointLabel", true, false) != null, "win detail renders one score constellation star per yaku and a point label")
	check(win_detail_parent.find_child("WinDetailScoreRoute", true, false) != null and win_detail_parent.find_child("WinDetailScoreRouteFill", true, false) != null and win_detail_parent.find_child("WinDetailScoreGate", true, false) != null, "win detail renders yaku-to-score route")
	check(count_nodes_with_name_prefix(win_detail_parent, "WinDetailScoreRouteTick_") == 3, "win detail renders score route rhythm ticks")
	var win_score_route_fill = win_detail_parent.find_child("WinDetailScoreRouteFill", true, false) as Control
	check(win_score_route_fill != null and win_score_route_fill.anchor_right > 0.45 and win_score_route_fill.anchor_right < 0.55, "win detail score route fill tracks fan strength")
	check(win_detail_parent.find_child("WinDetailResolutionBridge", true, false) != null and win_detail_parent.find_child("WinDetailResolutionRail", true, false) != null and win_detail_parent.find_child("WinDetailResolutionFill", true, false) != null and win_detail_parent.find_child("WinDetailResolutionGate", true, false) != null, "win detail renders fan-to-score resolution bridge")
	check(win_detail_parent.find_child("WinDetailResolutionFanNode", true, false) != null and win_detail_parent.find_child("WinDetailResolutionScoreNode", true, false) != null and win_detail_parent.find_child("WinDetailResolutionYakuRoute", true, false) != null and win_detail_parent.find_child("WinDetailResolutionYakuFill", true, false) != null, "win detail resolution bridge renders fan score and yaku route nodes")
	check(count_nodes_with_name_prefix(win_detail_parent, "WinDetailResolutionTick_") == 3 and count_nodes_with_name_prefix(win_detail_parent, "WinDetailResolutionPip_") == 2, "win detail resolution bridge renders rhythm ticks and confirmation pips")
	win_detail_parent.queue_free()
	var limit_win_detail_parent = Control.new()
	root.add_child(limit_win_detail_parent)
	scene.draw_win_detail_section(limit_win_detail_parent, {
		"winner": 1,
		"fan": 13,
		"points": 32000,
		"reasons": ["十三幺"],
		"win_tile": "P",
		"self_draw": false,
		"limit_name": "役满",
	})
	check(limit_win_detail_parent.find_child("WinDetailLimitBadge", true, false) != null and limit_win_detail_parent.find_child("WinDetailLimitArt", true, false) != null and limit_win_detail_parent.find_child("WinDetailLimitRoute", true, false) != null and limit_win_detail_parent.find_child("WinDetailLimitFill", true, false) != null and limit_win_detail_parent.find_child("WinDetailLimitGate", true, false) != null, "win detail limit hand renders named limit badge and confirmation route")
	check(limit_win_detail_parent.find_child("WinDetailLimitBurst", true, false) != null and count_nodes_with_name_prefix(limit_win_detail_parent, "WinDetailLimitTick_") == 3 and count_nodes_with_name_prefix(limit_win_detail_parent, "WinDetailLimitSpark_") == 4, "win detail limit hand renders burst sparks and rhythm ticks")
	var limit_fill = limit_win_detail_parent.find_child("WinDetailLimitFill", true, false) as Control
	check(limit_fill != null and limit_fill.anchor_right > 0.90, "win detail limit route fill reaches the high-value gate")
	limit_win_detail_parent.queue_free()
	check(is_equal_approx(scene.round_summary_delta_bar_fraction(3600), 1.0) and is_equal_approx(scene.round_summary_delta_bar_fraction(-1200), 1.0 / 3.0), "round summary delta bars scale by the largest score change")
	var rank_row_parent = Control.new()
	root.add_child(rank_row_parent)
	scene.draw_round_summary_rank_row(rank_row_parent, 1, 1)
	check(rank_row_parent.find_child("RankRowRibbonTexture_1", true, false) != null, "round summary rank row renders reusable ribbon PNG texture")
	check(rank_row_parent.find_child("RoundSummaryRankRow_1", true, false) != null and rank_row_parent.find_child("RoundSummaryWinnerSeal", true, false) != null, "round summary rank row renders winner seal")
	check(rank_row_parent.find_child("RoundSummaryDeltaBar", true, false) != null and rank_row_parent.find_child("RoundSummaryDeltaBarFill", true, false) != null, "round summary rank row renders animated score delta bar")
	check(rank_row_parent.find_child("RoundSummaryDeltaCenterGate", true, false) != null and count_nodes_with_name_prefix(rank_row_parent, "RoundSummaryDeltaTick_") == 3, "round summary rank row renders delta direction gate and ticks")
	check(rank_row_parent.find_child("RoundSummaryRankRouteArt", true, false) != null and rank_row_parent.find_child("RoundSummaryRankRouteRail", true, false) != null and rank_row_parent.find_child("RoundSummaryRankRouteFill", true, false) != null, "round summary rank row renders rank route art")
	check(count_nodes_with_name_prefix(rank_row_parent, "RoundSummaryRankRouteNode_") == 4 and rank_row_parent.find_child("RoundSummaryRankTrendGlow", true, false) != null and count_nodes_with_name_prefix(rank_row_parent, "RoundSummaryRankTrendSpark_") == 3, "round summary rank row renders route nodes and score trend sparks")
	rank_row_parent.queue_free()
	illustration_parent.queue_free()
	var advisor_card_parent = Control.new()
	root.add_child(advisor_card_parent)
	scene.draw_advisor_info_card(advisor_card_parent, scene.rect_full(0.0, 0.0, 0.32, 0.20), "防守", "安全优先", "看现物与筋", Color(0.84, 0.62, 0.54))
	check(advisor_card_parent.find_child("AdvisorCardMapTexture_防守", true, false) != null, "advisor card renders reusable decision-map PNG texture")
	check(advisor_card_parent.find_child("AdvisorSignalStrip_防守", true, false) != null and advisor_card_parent.find_child("AdvisorSignalPulse_防守", true, false) != null, "advisor cards render compact signal strip")
	check(advisor_card_parent.find_child("AdvisorCardSignalRoute_防守", true, false) != null and advisor_card_parent.find_child("AdvisorCardSignalFill_防守", true, false) != null and advisor_card_parent.find_child("AdvisorCardSignalSource_防守", true, false) != null and advisor_card_parent.find_child("AdvisorCardSignalGate_防守", true, false) != null, "advisor cards render signal-to-meter route")
	check(count_nodes_with_name_prefix(advisor_card_parent, "AdvisorCardSignalTick_防守_") == 2, "advisor cards render signal route rhythm ticks")
	check(advisor_card_parent.find_child("AdvisorCardMeter_防守", true, false) != null and advisor_card_parent.find_child("AdvisorCardMeterRail_防守", true, false) != null and advisor_card_parent.find_child("AdvisorCardMeterFill_防守", true, false) != null, "advisor cards render compact signal meter")
	check(advisor_card_parent.find_child("AdvisorCardMeterFocus_防守", true, false) != null and count_nodes_with_name_prefix(advisor_card_parent, "AdvisorCardMeterPip_防守_") == 3, "advisor card meter renders focus and three status pips")
	check(advisor_card_parent.find_child("AdvisorCardDecisionRoute_防守", true, false) != null and advisor_card_parent.find_child("AdvisorCardDecisionFill_防守", true, false) != null and advisor_card_parent.find_child("AdvisorCardDecisionGate_防守", true, false) != null, "advisor cards render decision route and gate")
	check(count_nodes_with_name_prefix(advisor_card_parent, "AdvisorCardDecisionTick_防守_") == 3, "advisor cards render decision rhythm ticks")
	scene.draw_advisor_panel_context_route(advisor_card_parent)
	check(advisor_card_parent.find_child("AdvisorPanelContextRoute", true, false) != null and advisor_card_parent.find_child("AdvisorPanelContextFill", true, false) != null and advisor_card_parent.find_child("AdvisorPanelContextGate", true, false) != null, "advisor panel renders context route")
	check(count_nodes_with_name_prefix(advisor_card_parent, "AdvisorPanelContextTick_") == 3 and count_nodes_with_name_prefix(advisor_card_parent, "AdvisorPanelContextNode_") == 3, "advisor panel context route renders ticks and card nodes")
	scene.draw_advisor_panel_decision_bridge(advisor_card_parent)
	check(advisor_card_parent.find_child("AdvisorPanelDecisionBridge", true, false) != null and advisor_card_parent.find_child("AdvisorPanelDecisionBridgeRail", true, false) != null and advisor_card_parent.find_child("AdvisorPanelDecisionBridgeFill", true, false) != null and advisor_card_parent.find_child("AdvisorPanelDecisionBridgeGate", true, false) != null, "advisor panel renders decision bridge route")
	check(count_nodes_with_name_prefix(advisor_card_parent, "AdvisorPanelDecisionNode_") == 3 and count_nodes_with_name_prefix(advisor_card_parent, "AdvisorPanelDecisionTick_") == 4, "advisor panel decision bridge renders nodes and rhythm ticks")
	advisor_card_parent.queue_free()
	var action_intent_parent = Control.new()
	root.add_child(action_intent_parent)
	scene.action_bar = HBoxContainer.new()
	action_intent_parent.add_child(scene.action_bar)
	scene.action_bar.add_child(scene.make_action_button("提示", Color(0.25, 0.58, 0.48), Callable()))
	scene.action_bar.add_child(scene.make_action_button("重开", Color(0.70, 0.32, 0.22), Callable()))
	scene.mode = "offline"
	scene.offline_phase = "playing"
	scene.draw_action_dock(action_intent_parent)
	check(action_intent_parent.find_child("ActionIntentDock", true, false) != null and action_intent_parent.find_child("ActionIntentRail", true, false) != null, "action dock renders contextual intent strip")
	check(action_intent_parent.find_child("ActionIntentFlow", true, false) != null and action_intent_parent.find_child("ActionIntentFlowFill", true, false) != null and action_intent_parent.find_child("ActionIntentCurrentMarker", true, false) != null, "action intent strip renders flow meter and current marker")
	check(count_nodes_with_name_prefix(action_intent_parent, "ActionIntentFlowBead_") == 2, "action intent strip renders one flow bead per available action up to cap")
	check(action_intent_parent.find_child("ActionIntentCommandBridge", true, false) != null and action_intent_parent.find_child("ActionIntentCommandBridgeRail", true, false) != null and action_intent_parent.find_child("ActionIntentCommandBridgeFill", true, false) != null and action_intent_parent.find_child("ActionIntentCommandBridgeGate", true, false) != null, "action intent strip renders command bridge route")
	check(count_nodes_with_name_prefix(action_intent_parent, "ActionIntentCommandNode_") == 2 and count_nodes_with_name_prefix(action_intent_parent, "ActionIntentCommandTick_") == 3, "action intent command bridge renders action nodes and rhythm ticks")
	check(action_intent_parent.find_child("ActionIntentExitRoute", true, false) != null and action_intent_parent.find_child("ActionIntentExitFill", true, false) != null and action_intent_parent.find_child("ActionIntentExitGate", true, false) != null, "action intent strip renders command exit route")
	check(count_nodes_with_name_prefix(action_intent_parent, "ActionIntentExitTick_") == 3, "action intent strip renders exit rhythm ticks")
	var action_exit_fill = action_intent_parent.find_child("ActionIntentExitFill", true, false) as Control
	check(action_exit_fill != null and action_exit_fill.anchor_right > 0.45 and action_exit_fill.anchor_right < 0.55, "action intent exit fill tracks available action count")
	check(has_label_text(action_intent_parent, "2项"), "action intent strip renders button count badge")
	action_intent_parent.queue_free()
	var voice_button_parent = Control.new()
	root.add_child(voice_button_parent)
	var voice_on_button = scene.make_action_button("闭麦", Color(0.74, 0.24, 0.24), Callable())
	voice_button_parent.add_child(voice_on_button)
	scene.draw_voice_button_art(voice_on_button, true, 0.70)
	check(voice_on_button.find_child("VoiceWaveTexture", true, false) != null, "active voice button renders reusable voice-wave PNG texture")
	check(voice_on_button.find_child("VoiceButtonArt", true, false) != null and voice_on_button.find_child("VoiceButtonStatusDot", true, false) != null and voice_on_button.find_child("VoiceButtonPulse", true, false) != null, "active voice button renders status dot and pulse")
	check(count_nodes_with_name_prefix(voice_on_button, "VoiceButtonWave_") == 3, "active voice button renders three wave bars")
	check(voice_on_button.find_child("VoiceButtonListenRing", true, false) != null and voice_on_button.find_child("VoiceButtonPeakMeter", true, false) != null and count_nodes_with_name_prefix(voice_on_button, "VoiceButtonPeakTick_") == 3, "active voice button renders listening ring and peak ticks")
	check(voice_on_button.find_child("VoiceButtonMicChannel", true, false) != null and voice_on_button.find_child("VoiceButtonMicChannelFill", true, false) != null and voice_on_button.find_child("VoiceButtonInputNode", true, false) != null and count_nodes_with_name_prefix(voice_on_button, "VoiceButtonPacketTick_") == 3, "active voice button renders mic channel and packet ticks")
	check(voice_on_button.find_child("VoiceButtonTransmitRoute", true, false) != null and voice_on_button.find_child("VoiceButtonTransmitFill", true, false) != null and voice_on_button.find_child("VoiceButtonTransmitGate", true, false) != null and count_nodes_with_name_prefix(voice_on_button, "VoiceButtonSyncTick_") == 3, "active voice button renders transmit route gate and sync ticks")
	var voice_peak_fill = voice_on_button.find_child("VoiceButtonPeakFill", true, false) as Control
	check(voice_peak_fill != null and voice_peak_fill.anchor_right > 0.65, "active voice button peak fill tracks microphone level")
	var voice_off_button = scene.make_action_button("语音", Color(0.24, 0.52, 0.72), Callable())
	voice_button_parent.add_child(voice_off_button)
	scene.draw_voice_button_art(voice_off_button, false, 0.0)
	check(voice_off_button.find_child("VoiceButtonMutedSlash", true, false) != null and count_nodes_with_name_prefix(voice_off_button, "VoiceButtonWave_") == 3, "inactive voice button renders muted slash and retained wave silhouette")
	check(voice_off_button.find_child("VoiceButtonMutedLock", true, false) != null and voice_off_button.find_child("VoiceButtonPeakFill", true, false) != null and voice_off_button.find_child("VoiceButtonMicChannel", true, false) != null, "inactive voice button renders muted lock dim peak meter and channel")
	check(voice_off_button.find_child("VoiceButtonTransmitRoute", true, false) != null and voice_off_button.find_child("VoiceButtonTransmitGate", true, false) != null and count_nodes_with_name_prefix(voice_off_button, "VoiceButtonSyncTick_") == 3, "inactive voice button keeps muted transmit route silhouette")
	check(voice_off_button.find_child("VoiceButtonMuteRoute", true, false) != null and voice_off_button.find_child("VoiceButtonMuteFill", true, false) != null and voice_off_button.find_child("VoiceButtonMuteGate", true, false) != null and count_nodes_with_name_prefix(voice_off_button, "VoiceButtonMuteTick_") == 2, "inactive voice button renders mute confirmation route")
	voice_button_parent.queue_free()
	var danger_art_parent = Control.new()
	root.add_child(danger_art_parent)
	scene.draw_danger_discard_confirmation_art(danger_art_parent, "5W", {"tile": "5W", "risk_label": "高", "risk": 42.0, "feed_risk": 36.0, "safety_label": "", "stance": "防守"}, [{"tile": "1W"}, {"tile": "E"}])
	check(danger_art_parent.find_child("DangerWarningTexture", true, false) != null, "danger discard confirmation renders reusable warning PNG texture")
	check(danger_art_parent.find_child("DangerDiscardConfirmationArt", true, false) != null and danger_art_parent.find_child("DangerDiscardTile", true, false) != null and danger_art_parent.find_child("DangerDiscardRiskSeal", true, false) != null, "danger discard confirmation renders tile and risk seal illustration")
	check(danger_art_parent.find_child("DangerDiscardRouteRail", true, false) != null and danger_art_parent.find_child("DangerDiscardRiskFill", true, false) != null and danger_art_parent.find_child("DangerDiscardConfirmSeal", true, false) != null, "danger discard confirmation renders risk route and confirm seal")
	check(count_nodes_with_name_prefix(danger_art_parent, "DangerDiscardRiskNode_") == 4 and danger_art_parent.find_child("DangerDiscardAlertHalo", true, false) != null and count_nodes_with_name_prefix(danger_art_parent, "DangerDiscardAlertRing_") == 3, "danger discard confirmation renders risk nodes and alert halo")
	check(danger_art_parent.find_child("DangerDiscardSourceTrace", true, false) != null and danger_art_parent.find_child("DangerDiscardSourceFill", true, false) != null and danger_art_parent.find_child("DangerDiscardSourceGate", true, false) != null, "danger discard confirmation renders risk source trace")
	check(count_nodes_with_name_prefix(danger_art_parent, "DangerDiscardSourceNode_") == 3, "danger discard confirmation renders risk source nodes")
	check(danger_art_parent.find_child("DangerDiscardSafeRail", true, false) != null and count_nodes_with_name_prefix(danger_art_parent, "DangerDiscardSafeTile_") == 2 and count_nodes_with_name_prefix(danger_art_parent, "DangerDiscardSafePulse_") == 3, "danger discard confirmation renders safe alternative rail")
	check(danger_art_parent.find_child("DangerDiscardConfirmRoute", true, false) != null and danger_art_parent.find_child("DangerDiscardConfirmFill", true, false) != null and danger_art_parent.find_child("DangerDiscardConfirmGate", true, false) != null, "danger discard confirmation renders confirm decision route")
	check(danger_art_parent.find_child("DangerDiscardAlternativeRoute", true, false) != null and danger_art_parent.find_child("DangerDiscardAlternativeFill", true, false) != null and count_nodes_with_name_prefix(danger_art_parent, "DangerDiscardAlternativeTick_") == 2, "danger discard confirmation renders alternative decision route")
	check(count_nodes_with_name_prefix(danger_art_parent, "DangerDiscardConfirmTick_") == 2, "danger discard confirmation renders confirm rhythm ticks")
	danger_art_parent.queue_free()
	scene.chat_messages = ["甲: 准备好了", "乙: 碰", "你: 收到"]
	scene.show_chat_panel()
	check(scene.find_child("ChatStreamTexture", true, false) != null, "chat panel renders reusable stream PNG texture")
	check(scene.find_child("ChatPanel", true, false) != null and scene.find_child("ChatPanelArt", true, false) != null and scene.find_child("ChatPanelHeader", true, false) != null, "chat panel renders illustrated header")
	check(scene.find_child("ChatPanelHeaderBridge", true, false) != null and scene.find_child("ChatPanelHeaderBridgeFill", true, false) != null and scene.find_child("ChatPanelHeaderBridgeGate", true, false) != null and count_nodes_with_name_prefix(scene, "ChatPanelHeaderBridgeTick_") == 2, "chat panel renders header-to-feed bridge route")
	check(scene.find_child("ChatPanelActivityRail", true, false) != null and scene.find_child("ChatPanelLatestGlow", true, false) != null and count_nodes_with_name_prefix(scene, "ChatPanelMessageNode_") == 3, "chat panel renders activity rail and one visible node per recent message")
	check(count_nodes_with_name_prefix(scene, "ChatPanelSenderChip_") == 3 and count_nodes_with_name_prefix(scene, "ChatPanelUnreadBead_") == 3, "chat panel renders sender chips and unread beads")
	check(count_nodes_with_name_prefix(scene, "ChatPanelMessageLane_") == 3 and count_nodes_with_name_prefix(scene, "ChatPanelFlowTick_") == 3 and scene.find_child("ChatPanelLatestCursor", true, false) != null, "chat panel renders per-message lanes and latest cursor")
	check(count_nodes_with_name_prefix(scene, "ChatPanelOutgoingRibbon_") == 1 and scene.find_child("ChatPanelInputPulse", true, false) != null and count_nodes_with_name_prefix(scene, "ChatPanelTypingWave_") == 3, "chat panel renders outgoing and typing feedback art")
	check(scene.find_child("ChatPanelSyncRoute", true, false) != null and scene.find_child("ChatPanelSyncFill", true, false) != null and scene.find_child("ChatPanelSyncGate", true, false) != null and count_nodes_with_name_prefix(scene, "ChatPanelSyncTick_") == 2, "chat panel renders latest-message sync route")
	check(scene.find_child("ChatPanelDeliveryRoute", true, false) != null and scene.find_child("ChatPanelDeliveryFill", true, false) != null and scene.find_child("ChatPanelDeliveryGate", true, false) != null, "chat panel renders delivery route")
	check(count_nodes_with_name_prefix(scene, "ChatPanelDeliveryTick_") == 3, "chat panel renders delivery rhythm ticks")
	check(first_label_containing_text(scene, "3条") != null and first_label_containing_text(scene, "甲: 准备好了") != null, "chat panel labels message count and latest chat text")
	scene.clear_screen()
	scene.chat_messages.clear()
	scene.show_chat_panel()
	check(scene.find_child("ChatPanelEmptyStateArt", true, false) != null and scene.find_child("ChatPanelEmptyRail", true, false) != null and scene.find_child("ChatPanelEmptyFill", true, false) != null and scene.find_child("ChatPanelEmptyGate", true, false) != null, "empty chat panel renders waiting-state route art")
	check(scene.find_child("ChatPanelEmptySource", true, false) != null and count_nodes_with_name_prefix(scene, "ChatPanelEmptyPulse_") == 3 and has_label_text(scene, "等待房间消息"), "empty chat panel renders source pulse art and waiting text")
	check(scene.find_child("ChatPanelEmptyListenRoute", true, false) != null and scene.find_child("ChatPanelEmptyListenFill", true, false) != null and scene.find_child("ChatPanelEmptyListenGate", true, false) != null, "empty chat panel renders listen-ready route")
	check(count_nodes_with_name_prefix(scene, "ChatPanelEmptyListenTick_") == 2, "empty chat panel renders listen-ready rhythm ticks")
	scene.clear_screen()
	scene.show_exit_confirm()
	check(scene.find_child("ExitGateTexture", true, false) != null, "exit confirm dialog renders reusable save-gate PNG texture")
	check(scene.find_child("ExitConfirmDialog", true, false) != null and scene.find_child("ExitConfirmArt", true, false) != null and scene.find_child("ExitConfirmSaveRail", true, false) != null, "exit confirm dialog renders save-flow illustration")
	check(scene.find_child("ExitConfirmTableNode", true, false) != null and scene.find_child("ExitConfirmSaveNode", true, false) != null and scene.find_child("ExitConfirmLeaveNode", true, false) != null, "exit confirm illustration renders table save and leave nodes")
	check(scene.find_child("ExitConfirmSaveGlow", true, false) != null and count_nodes_with_name_prefix(scene, "ExitConfirmSavePip_") == 3, "exit confirm illustration renders save glow and progress pips")
	check(scene.find_child("ExitConfirmAutosaveRoute", true, false) != null and scene.find_child("ExitConfirmAutosaveFill", true, false) != null and scene.find_child("ExitConfirmAutosaveGate", true, false) != null and count_nodes_with_name_prefix(scene, "ExitConfirmAutosaveTick_") == 3, "exit confirm illustration renders autosave confirmation route")
	check(scene.find_child("ExitConfirmChoiceArt", true, false) != null and scene.find_child("ExitConfirmKeepChoiceRail", true, false) != null and scene.find_child("ExitConfirmLeaveChoiceRail", true, false) != null, "exit confirm dialog renders choice rail illustration")
	check(scene.find_child("ExitConfirmKeepChoiceFill", true, false) != null and scene.find_child("ExitConfirmLeaveChoiceFill", true, false) != null and count_nodes_with_name_prefix(scene, "ExitConfirmKeepChoiceNode_") == 3 and count_nodes_with_name_prefix(scene, "ExitConfirmLeaveChoiceNode_") == 3, "exit confirm choice art renders decision fills and comparison nodes")
	check(scene.find_child("ExitConfirmChoiceBridge", true, false) != null and scene.find_child("ExitConfirmChoiceBridgeKeepFill", true, false) != null and scene.find_child("ExitConfirmChoiceBridgeLeaveFill", true, false) != null and scene.find_child("ExitConfirmChoiceBridgeGate", true, false) != null, "exit confirm choice art renders save-to-choice bridge")
	check(count_nodes_with_name_prefix(scene, "ExitConfirmChoiceBridgeKeepTick_") == 2 and count_nodes_with_name_prefix(scene, "ExitConfirmChoiceBridgeLeaveTick_") == 2, "exit confirm choice art renders bridge rhythm ticks")
	check(scene.find_child("ExitConfirmSaveStamp", true, false) != null and count_nodes_with_name_prefix(scene, "ExitConfirmKeepSpark_") == 2 and count_nodes_with_name_prefix(scene, "ExitConfirmLeaveSpark_") == 2, "exit confirm choice art renders save stamp and directional sparks")
	check(scene.find_child("ExitConfirmButtonArt_keep", true, false) != null and scene.find_child("ExitConfirmButtonRail_keep", true, false) != null and scene.find_child("ExitConfirmButtonFill_leave", true, false) != null and scene.find_child("ExitConfirmButtonGate_leave", true, false) != null, "exit confirm buttons render keep and leave command route art")
	check(count_nodes_with_name_prefix(scene, "ExitConfirmButtonTick_") == 4, "exit confirm buttons render command rhythm ticks")
	scene.hide_exit_confirm()
	await process_frame
	var settings_parent = Control.new()
	root.add_child(settings_parent)
	scene.settings_panel_open = true
	scene.draw_settings_overlay(settings_parent)
	check(settings_parent.find_child("SettingsCompassTexture", true, false) != null, "settings overlay renders reusable compass PNG texture")
	check(settings_parent.get_child_count() == 1 and has_button_text(settings_parent, "音乐开") and has_button_text(settings_parent, "快速开") and has_button_text(settings_parent, "试音"), "settings overlay renders toggle and test-audio buttons")
	check(count_texture_rects(settings_parent) >= 1, "settings overlay renders lucide title icon")
	check(settings_parent.find_child("SettingsCloseButton", true, false) != null and settings_parent.find_child("SettingsCloseButtonArt", true, false) != null and settings_parent.find_child("SettingsCloseRail", true, false) != null and settings_parent.find_child("SettingsCloseFill", true, false) != null and settings_parent.find_child("SettingsCloseGate", true, false) != null, "settings close button renders dismiss route art")
	check(count_nodes_with_name_prefix(settings_parent, "SettingsCloseTick_") == 2, "settings close button renders dismiss rhythm ticks")
	check(settings_parent.find_child("SettingsOverviewArt", true, false) != null and settings_parent.find_child("SettingsOverviewRail", true, false) != null and settings_parent.find_child("SettingsOverviewFill", true, false) != null, "settings overlay renders overview meter")
	check(settings_parent.find_child("SettingsOverviewNode_audio", true, false) != null and settings_parent.find_child("SettingsOverviewNode_play", true, false) != null and settings_parent.find_child("SettingsOverviewNode_maint", true, false) != null and settings_parent.find_child("SettingsOverviewStatusLight", true, false) != null, "settings overview renders audio play maintenance nodes and status light")
	check(settings_parent.find_child("SettingsOverviewSystemBus", true, false) != null and settings_parent.find_child("SettingsOverviewSystemBusFill", true, false) != null and settings_parent.find_child("SettingsOverviewSystemBusGate", true, false) != null, "settings overview renders system status bus")
	check(count_nodes_with_name_prefix(settings_parent, "SettingsOverviewSystemBusTick_") == 3 and count_nodes_with_name_prefix(settings_parent, "SettingsOverviewBusPulse_") == 3, "settings overview renders bus ticks and group pulses")
	check(settings_parent.find_child("SettingsSectionSignal_声音", true, false) != null and settings_parent.find_child("SettingsSectionSignalRail_体验", true, false) != null and settings_parent.find_child("SettingsSectionSignalIcon_维护", true, false) != null, "settings overlay renders section signal art")
	check(count_nodes_with_name_prefix(settings_parent, "SettingsSectionSignalPulse_声音_") == 3 and count_nodes_with_name_prefix(settings_parent, "SettingsSectionSignalPulse_体验_") == 3, "settings overlay renders section signal pulses")
	check(count_nodes_with_name_prefix(settings_parent, "SettingRowStatusArt_") == 8 and count_nodes_with_name_prefix(settings_parent, "SettingRowStatusRail_") == 8 and count_nodes_with_name_prefix(settings_parent, "SettingRowStatusFill_") == 8, "settings rows render status rails and fills")
	check(count_nodes_with_name_prefix(settings_parent, "SettingRowStatusDot_") == 24, "settings rows render compact status dots")
	check(count_nodes_with_name_prefix(settings_parent, "SettingSwitchDirectionRoute") == 5 and count_nodes_with_name_prefix(settings_parent, "SettingSwitchDirectionFill") == 5 and count_nodes_with_name_prefix(settings_parent, "SettingSwitchDirectionGate") == 5, "settings toggle buttons render repeated direction routes")
	check(count_nodes_with_name_prefix(settings_parent, "SettingSwitchDirectionTick_") == 10, "settings toggle buttons render direction rhythm ticks")
	check(count_nodes_with_name_prefix(settings_parent, "SettingSwitchStateRoute") == 5 and count_nodes_with_name_prefix(settings_parent, "SettingSwitchStateFill") == 5 and count_nodes_with_name_prefix(settings_parent, "SettingSwitchStateGate") == 5, "settings toggle buttons render state confirmation routes")
	check(count_nodes_with_name_prefix(settings_parent, "SettingSwitchStateTick_") == 10, "settings toggle buttons render state confirmation rhythm ticks")
	check(settings_parent.find_child("AudioTestTexture", true, false) != null and settings_parent.find_child("AudioTestButtonArt", true, false) != null and settings_parent.find_child("AudioTestWaveRail", true, false) != null and settings_parent.find_child("AudioTestSpeakerSeal", true, false) != null and count_nodes_with_name_prefix(settings_parent, "AudioTestWaveBar_") == 4, "settings audio test button renders reusable PNG wave illustration")
	check(settings_parent.find_child("AudioTestCommandRoute", true, false) != null and settings_parent.find_child("AudioTestCommandFill", true, false) != null and settings_parent.find_child("AudioTestCommandGate", true, false) != null and count_nodes_with_name_prefix(settings_parent, "AudioTestCommandTick_") == 2, "settings audio test button renders command route art")
	check(settings_parent.find_child("AudioTestPlaybackRoute", true, false) != null and settings_parent.find_child("AudioTestPlaybackFill", true, false) != null and settings_parent.find_child("AudioTestPlaybackGate", true, false) != null and count_nodes_with_name_prefix(settings_parent, "AudioTestPlaybackTick_") == 3, "settings audio test button renders speaker-to-wave playback route")
	check(settings_parent.find_child("BgmSwitchTexture", true, false) != null and settings_parent.find_child("BgmSwitchButtonArt", true, false) != null and settings_parent.find_child("BgmSwitchDisc", true, false) != null and settings_parent.find_child("BgmSwitchTrackRail", true, false) != null and count_nodes_with_name_prefix(settings_parent, "BgmSwitchNote_") == 3, "settings BGM switch button renders reusable PNG track illustration")
	check(settings_parent.find_child("BgmSwitchCommandRoute", true, false) != null and settings_parent.find_child("BgmSwitchCommandFill", true, false) != null and settings_parent.find_child("BgmSwitchCommandGate", true, false) != null and count_nodes_with_name_prefix(settings_parent, "BgmSwitchCommandTick_") == 2, "settings BGM switch button renders next-track command route")
	check(settings_parent.find_child("BgmSwitchPlaybackRoute", true, false) != null and settings_parent.find_child("BgmSwitchPlaybackFill", true, false) != null and settings_parent.find_child("BgmSwitchPlaybackGate", true, false) != null and count_nodes_with_name_prefix(settings_parent, "BgmSwitchPlaybackTick_") == 3, "settings BGM switch button renders disc-to-note playback route")
	check(settings_parent.find_child("ResetDangerSealTexture", true, false) != null and settings_parent.find_child("ResetProgressButtonArt", true, false) != null and settings_parent.find_child("ResetProgressDangerRail", true, false) != null and settings_parent.find_child("ResetProgressLockSeal", true, false) != null, "settings reset progress button renders reusable PNG danger art")
	check(settings_parent.find_child("ResetProgressHoldRoute", true, false) != null and settings_parent.find_child("ResetProgressHoldFill", true, false) != null and settings_parent.find_child("ResetProgressHoldGate", true, false) != null and count_nodes_with_name_prefix(settings_parent, "ResetProgressHoldTick_") == 2, "settings reset progress button renders confirmation route art")
	check(settings_parent.find_child("ResetProgressLockRoute", true, false) != null and settings_parent.find_child("ResetProgressLockFill", true, false) != null and settings_parent.find_child("ResetProgressLockGate", true, false) != null and count_nodes_with_name_prefix(settings_parent, "ResetProgressLockTick_") == 3, "settings reset progress button renders lock confirmation route")
	check(count_nodes_with_name_prefix(settings_parent, "ResetProgressDangerNode_") == 3 and count_nodes_with_name_prefix(settings_parent, "ResetProgressWarningSpark_") == 2, "settings reset progress button renders danger nodes and warning sparks")
	check(panels_ignore_mouse(settings_parent), "settings overlay panels skip mouse hit testing while buttons remain interactive")
	check(containers_ignore_mouse(settings_parent), "settings overlay layout containers skip mouse hit testing")
	settings_parent.queue_free()
	scene.settings_panel_open = false
	scene.currency = {"coins": 1200, "gems": 33}
	scene.inventory = {"swap_card": 2, "peek_card": 0, "lucky_charm": 1, "double_coins": 0}
	scene._show_shop_screen_impl()
	check(scene.mode == "shop" and scene.find_child("ShopItemRow_swap_card", true, false) != null, "shop screen renders named item rows")
	check(scene.find_child("ShopVaultTexture", true, false) != null, "shop screen renders reusable vault PNG texture")
	check(scene.find_child("SecondaryBackTexture_shop", true, false) != null and scene.find_child("SecondaryBackButtonArt_shop", true, false) != null and scene.find_child("SecondaryBackButtonRail_shop", true, false) != null and scene.find_child("SecondaryBackButtonFill_shop", true, false) != null and count_nodes_with_name_prefix(scene, "SecondaryBackButtonTick_shop_") == 2, "shop back button renders reusable PNG return-route art")
	check(scene.find_child("SecondaryBackSourceNode_shop", true, false) != null and scene.find_child("SecondaryBackDestinationNode_shop", true, false) != null and scene.find_child("SecondaryBackConfirmRoute_shop", true, false) != null and scene.find_child("SecondaryBackConfirmFill_shop", true, false) != null and scene.find_child("SecondaryBackConfirmGate_shop", true, false) != null, "shop back button renders source destination and confirmation route")
	check(count_nodes_with_name_prefix(scene, "SecondaryBackNodeTick_shop_") == 2 and count_nodes_with_name_prefix(scene, "SecondaryBackConfirmTick_shop_") == 2, "shop back button renders node and confirmation rhythm ticks")
	check(scene.find_child("ShopCurrencyPanel_coins", true, false) != null and scene.find_child("ShopCurrencyPanel_gems", true, false) != null, "shop screen renders named currency panels")
	check(scene.find_child("ShopCurrencyMeterArt_coins", true, false) != null and scene.find_child("ShopCurrencyRail_coins", true, false) != null and scene.find_child("ShopCurrencyFill_coins", true, false) != null and scene.find_child("ShopCurrencyVault_coins", true, false) != null, "shop coins balance renders resource meter art")
	check(scene.find_child("ShopCurrencyMeterArt_gems", true, false) != null and scene.find_child("ShopCurrencyRail_gems", true, false) != null and scene.find_child("ShopCurrencyFill_gems", true, false) != null and scene.find_child("ShopCurrencyThreshold_gems", true, false) != null, "shop gems balance renders resource meter art")
	check(count_nodes_with_name_prefix(scene, "ShopCurrencyPulse_coins_") == 4 and count_nodes_with_name_prefix(scene, "ShopCurrencyPulse_gems_") == 3, "shop currency meters render resource pulse accents")
	check(scene.find_child("ShopCurrencyFlowRail_coins", true, false) != null and scene.find_child("ShopCurrencyFlowFill_coins", true, false) != null and scene.find_child("ShopCurrencyFlowGate_coins", true, false) != null, "shop coins balance renders resource flow rail")
	check(scene.find_child("ShopCurrencyFlowRail_gems", true, false) != null and scene.find_child("ShopCurrencyFlowFill_gems", true, false) != null and scene.find_child("ShopCurrencyFlowGate_gems", true, false) != null and count_nodes_with_name_prefix(scene, "ShopCurrencyFlowNode_") == 6, "shop gems balance renders resource flow nodes")
	check(count_nodes_with_name_prefix(scene, "ShopCurrencyFlowTick_") == 6, "shop currency meters render resource flow rhythm ticks")
	check(count_named_nodes(scene, "ShopItemShelfRail") == scene.ITEM_TYPES.size() and count_named_nodes(scene, "ShopItemPriceAura") == scene.ITEM_TYPES.size(), "shop item rows render shelf rail and price aura art")
	check(scene.find_child("ShopItemShelfTexture_swap_card", true, false) != null and count_nodes_with_name_prefix(scene, "ShopItemShelfTexture_") == scene.ITEM_TYPES.size(), "shop item rows render reusable shelf PNG textures")
	check(count_nodes_with_name_prefix(scene, "ShopItemStockPip_") >= scene.ITEM_TYPES.size(), "shop item rows render stock pip illustrations")
	check(count_named_nodes(scene, "ShopItemEnergyRail") == scene.ITEM_TYPES.size() and count_named_nodes(scene, "ShopItemEnergyFill") == scene.ITEM_TYPES.size(), "shop item rows render energy rails and inventory fill")
	check(count_nodes_with_name_prefix(scene, "ShopItemCountBadge_") == scene.ITEM_TYPES.size() and count_named_nodes(scene, "ShopItemCountBadgeArt") == scene.ITEM_TYPES.size(), "shop item rows render named inventory count badges")
	check(count_named_nodes(scene, "ShopItemCountRail") == scene.ITEM_TYPES.size() and count_named_nodes(scene, "ShopItemCountFill") == scene.ITEM_TYPES.size() and count_named_nodes(scene, "ShopItemCountGate") == scene.ITEM_TYPES.size(), "shop item count badges render inventory rails fills and gates")
	check(count_nodes_with_name_prefix(scene, "ShopItemCountPip_") == scene.ITEM_TYPES.size() * 3, "shop item count badges render stock pips")
	check(count_named_nodes(scene, "ShopItemRouteRail") == scene.ITEM_TYPES.size() and count_named_nodes(scene, "ShopItemRouteArrow") == scene.ITEM_TYPES.size() and count_nodes_with_name_prefix(scene, "ShopItemRouteNode_") == scene.ITEM_TYPES.size() * 3, "shop item rows render route rails arrows and comparison nodes")
	check(count_named_nodes(scene, "ShopItemValueRoute") == scene.ITEM_TYPES.size() and count_named_nodes(scene, "ShopItemValueFill") == scene.ITEM_TYPES.size() and count_named_nodes(scene, "ShopItemValueGate") == scene.ITEM_TYPES.size(), "shop item rows render value bridge routes")
	check(count_named_nodes(scene, "ShopItemValueTick_0") == scene.ITEM_TYPES.size() and count_named_nodes(scene, "ShopItemValueTick_1") == scene.ITEM_TYPES.size(), "shop item rows render value bridge rhythm ticks")
	check(count_named_nodes(scene, "ShopItemSettlementRail") == scene.ITEM_TYPES.size() and count_named_nodes(scene, "ShopItemSettlementFill") == scene.ITEM_TYPES.size() and count_named_nodes(scene, "ShopItemSettlementGate") == scene.ITEM_TYPES.size(), "shop item rows render settlement rails fills and gates")
	check(count_named_nodes(scene, "ShopItemSettlementTick_0") == scene.ITEM_TYPES.size() and count_named_nodes(scene, "ShopItemSettlementTick_1") == scene.ITEM_TYPES.size() and count_named_nodes(scene, "ShopItemSettlementTick_2") == scene.ITEM_TYPES.size(), "shop item rows render settlement rhythm ticks")
	check(scene.find_child("ShopItemTypeMark_swap_card", true, false) != null and count_named_nodes(scene, "ShopItemTypeGlyph") == scene.ITEM_TYPES.size(), "shop item rows render item type marks")
	check(count_named_nodes(scene, "ShopItemPriceSpark_0") == scene.ITEM_TYPES.size() and count_named_nodes(scene, "ShopItemPriceSpark_1") == scene.ITEM_TYPES.size(), "shop item rows render price sparkle accents")
	check(count_named_nodes(scene, "ShopBuyButtonArt") == scene.ITEM_TYPES.size() and count_named_nodes(scene, "ShopBuyButtonAffordRail") == scene.ITEM_TYPES.size() and count_named_nodes(scene, "ShopBuyButtonPriceSeal") == scene.ITEM_TYPES.size(), "shop buy buttons render affordance rails and price seals")
	check(count_named_nodes(scene, "ShopBuyButtonCommandRoute") == scene.ITEM_TYPES.size() and count_named_nodes(scene, "ShopBuyButtonCommandFill") == scene.ITEM_TYPES.size() and count_named_nodes(scene, "ShopBuyButtonCommandGate") == scene.ITEM_TYPES.size(), "shop buy buttons render purchase command routes")
	check(count_named_nodes(scene, "ShopBuyButtonCommandTick_0") == scene.ITEM_TYPES.size() and count_named_nodes(scene, "ShopBuyButtonCommandTick_1") == scene.ITEM_TYPES.size(), "shop buy buttons render purchase command ticks")
	check(count_named_nodes(scene, "ShopBuyButtonSettlementRoute") == scene.ITEM_TYPES.size() and count_named_nodes(scene, "ShopBuyButtonSettlementFill") == scene.ITEM_TYPES.size() and count_named_nodes(scene, "ShopBuyButtonSettlementGate") == scene.ITEM_TYPES.size(), "shop buy buttons render settlement confirmation routes")
	check(count_named_nodes(scene, "ShopBuyButtonSettlementTick_0") == scene.ITEM_TYPES.size() and count_named_nodes(scene, "ShopBuyButtonSettlementTick_1") == scene.ITEM_TYPES.size() and count_named_nodes(scene, "ShopBuyButtonSettlementTick_2") == scene.ITEM_TYPES.size(), "shop buy buttons render settlement rhythm ticks")
	check(count_named_nodes(scene, "ShopBuyButtonSpark_0") == scene.ITEM_TYPES.size() and count_named_nodes(scene, "ShopBuyButtonInsufficientLock") == 0, "shop buy buttons render price sparks and omit locks when gems are sufficient")
	scene.currency = {"coins": 0, "gems": 3}
	scene._show_shop_screen_impl()
	check(scene.find_child("ShopCurrencyLowRoute_coins", true, false) != null and scene.find_child("ShopCurrencyLowFill_coins", true, false) != null and scene.find_child("ShopCurrencyLowGate_coins", true, false), "shop coins balance renders low-resource route")
	check(scene.find_child("ShopCurrencyLowRoute_gems", true, false) != null and scene.find_child("ShopCurrencyLowFill_gems", true, false) != null and scene.find_child("ShopCurrencyLowGate_gems", true, false), "shop gems balance renders low-resource route")
	check(count_nodes_with_name_prefix(scene, "ShopCurrencyLowTick_") == 6, "shop low-resource meters render rhythm ticks")
	check(count_named_nodes(scene, "ShopBuyButtonInsufficientLock") == scene.ITEM_TYPES.size(), "shop buy buttons render insufficient locks when gems are low")
	check(count_named_nodes(scene, "ShopBuyButtonInsufficientRoute") == scene.ITEM_TYPES.size() and count_named_nodes(scene, "ShopBuyButtonInsufficientFill") == scene.ITEM_TYPES.size() and count_named_nodes(scene, "ShopBuyButtonInsufficientGate") == scene.ITEM_TYPES.size(), "shop buy buttons render insufficient-resource routes when gems are low")
	check(count_named_nodes(scene, "ShopBuyButtonInsufficientTick_0") == scene.ITEM_TYPES.size() and count_named_nodes(scene, "ShopBuyButtonInsufficientTick_1") == scene.ITEM_TYPES.size(), "shop buy buttons render insufficient-resource rhythm ticks")
	scene.start_offline(true)
	scene.game_stats = {"games_played": 12, "games_won": 7, "total_score": 18800, "best_score": 9600, "win_rate": 7.0 / 12.0, "total_hands": 44}
	scene._show_stats_screen_impl()
	check(scene.mode == "stats" and scene.find_child("StatsDashboardArt", true, false) != null, "stats screen renders dashboard illustration")
	check(scene.find_child("StatsChartTexture", true, false) != null, "stats screen renders reusable chart PNG texture")
	check(scene.find_child("StatsDashboardGridTexture", true, false) != null, "stats dashboard renders reusable grid PNG texture")
	check(scene.find_child("SecondaryBackTexture_stats", true, false) != null and scene.find_child("SecondaryBackButtonArt_stats", true, false) != null and scene.find_child("SecondaryBackButtonRail_stats", true, false) != null and scene.find_child("SecondaryBackButtonFill_stats", true, false) != null and count_nodes_with_name_prefix(scene, "SecondaryBackButtonTick_stats_") == 2, "stats back button renders reusable PNG return-route art")
	check(scene.find_child("SecondaryBackSourceNode_stats", true, false) != null and scene.find_child("SecondaryBackDestinationNode_stats", true, false) != null and scene.find_child("SecondaryBackConfirmRoute_stats", true, false) != null and scene.find_child("SecondaryBackConfirmFill_stats", true, false) != null and scene.find_child("SecondaryBackConfirmGate_stats", true, false) != null, "stats back button renders source destination and confirmation route")
	check(count_nodes_with_name_prefix(scene, "SecondaryBackNodeTick_stats_") == 2 and count_nodes_with_name_prefix(scene, "SecondaryBackConfirmTick_stats_") == 2, "stats back button renders node and confirmation rhythm ticks")
	check(scene.find_child("StatsWinRateRing", true, false) != null and count_nodes_with_name_prefix(scene, "StatsWinRateSegment_") == 8, "stats dashboard renders segmented win-rate ring")
	check(scene.find_child("StatsGamesTrack", true, false) != null and scene.find_child("StatsGamesTrackFill", true, false) != null and scene.find_child("StatsBestScoreMedal", true, false) != null, "stats dashboard renders games track and best-score medal")
	check(scene.find_child("StatsSummaryChannel", true, false) != null and scene.find_child("StatsSummaryChannelFill", true, false) != null and scene.find_child("StatsSummaryGate", true, false) != null, "stats dashboard renders summary performance channel")
	check(count_nodes_with_name_prefix(scene, "StatsSummaryNode_") == 3, "stats dashboard renders summary metric nodes")
	check(scene.find_child("StatsDashboardScanRoute", true, false) != null and scene.find_child("StatsDashboardScanFill", true, false) != null and scene.find_child("StatsDashboardScanGate", true, false) != null and count_nodes_with_name_prefix(scene, "StatsDashboardScanTick_") == 4, "stats dashboard renders scan route from summary to trend")
	check(scene.find_child("StatsTrendLineArt", true, false) != null and count_nodes_with_name_prefix(scene, "StatsTrendNode_") == 5 and count_nodes_with_name_prefix(scene, "StatsTrendConnector_") == 4, "stats dashboard renders trend line illustration")
	check(scene.find_child("StatsPerformanceRoute", true, false) != null and scene.find_child("StatsPerformanceFill", true, false) != null and scene.find_child("StatsPerformanceGate", true, false) != null and count_nodes_with_name_prefix(scene, "StatsPerformanceTick_") == 2, "stats dashboard renders performance-to-medal route")
	check(count_nodes_with_name_prefix(scene, "StatsBestScoreMilestone_") == 3, "stats dashboard renders best-score milestone badges")
	check(scene.find_child("StatsBestScoreRoute", true, false) != null and scene.find_child("StatsBestScoreRouteFill", true, false) != null and scene.find_child("StatsBestScoreGate", true, false) != null and count_nodes_with_name_prefix(scene, "StatsBestScoreTick_") == 3, "stats dashboard renders best-score route gate and ticks")
	var stats_best_score_fill = scene.find_child("StatsBestScoreRouteFill", true, false) as Control
	check(stats_best_score_fill != null and stats_best_score_fill.anchor_right > 0.70, "stats best-score route fill tracks best score strength")
	check(has_label_text(scene, "胜率 58%") and has_label_text(scene, "历练 12局"), "stats dashboard labels win rate and played games")
	check(count_nodes_with_name_prefix(scene, "StatsRowArt_") == 6 and count_nodes_with_name_prefix(scene, "StatsRowRail_") == 6 and count_nodes_with_name_prefix(scene, "StatsRowFill_") == 6, "stats rows render illustrated metric rails and fills")
	check(count_nodes_with_name_prefix(scene, "StatsRowNode_") == 18 and count_nodes_with_name_prefix(scene, "StatsRowFocus_") == 6, "stats rows render status nodes and focus accents")
	check(count_nodes_with_name_prefix(scene, "StatsRowTrendRoute_") == 6 and count_nodes_with_name_prefix(scene, "StatsRowTrendFill_") == 6 and count_nodes_with_name_prefix(scene, "StatsRowTrendGate_") == 6, "stats rows render trend routes fills and gates")
	check(count_nodes_with_name_prefix(scene, "StatsRowTrendTick_") == 12, "stats rows render trend rhythm ticks")
	check(count_nodes_with_name_prefix(scene, "StatsRowValueRoute_") == 6 and count_nodes_with_name_prefix(scene, "StatsRowValueFill_") == 6 and count_nodes_with_name_prefix(scene, "StatsRowValueGate_") == 6, "stats rows render value readout routes fills and gates")
	check(count_nodes_with_name_prefix(scene, "StatsRowValueTick_") == 12, "stats rows render value readout rhythm ticks")
	scene.game_stats = {"games_played": 0, "games_won": 0, "total_score": 0, "best_score": 0, "win_rate": 0.0, "total_hands": 0}
	scene._show_stats_screen_impl()
	check(scene.find_child("StatsEmptyStateArt", true, false) != null and scene.find_child("StatsEmptyRoute", true, false) != null and scene.find_child("StatsEmptyFill", true, false) != null and scene.find_child("StatsEmptyGate", true, false) != null, "empty stats dashboard renders first-game route")
	check(scene.find_child("StatsEmptySeedNode", true, false) != null and scene.find_child("StatsEmptyGateGlyph", true, false) != null and count_nodes_with_name_prefix(scene, "StatsEmptyTick_") == 3, "empty stats dashboard renders seed node glyph and rhythm ticks")
	scene.start_offline(true)
	scene.season_data = {"season_id": "test", "points": 650, "highest_rank": 3, "wins": 8, "games": 12}
	scene.task_progress = {"win_3": 3, "peng_3": 1, "gang_1": 1, "play_5": 2, "score_plus": 0}
	scene.tutorial_step = 0
	scene.show_menu(true)
	check(count_named_nodes(scene, "MenuCardEntryArt") == 3 and count_named_nodes(scene, "MenuCardEntryRail") == 3 and count_named_nodes(scene, "MenuCardIconEcho") == 3, "main menu cards render entry route illustrations")
	check(count_nodes_with_name_prefix(scene, "MenuCardEntryNode_") == 9 and count_nodes_with_name_prefix(scene, "MenuCardEntrySpark_") == 9, "main menu cards render route nodes and sparks for each entry")
	check(count_named_nodes(scene, "MenuCardEntryConfirmRoute") == 3 and count_named_nodes(scene, "MenuCardEntryConfirmFill") == 3 and count_named_nodes(scene, "MenuCardEntryConfirmGate") == 3, "main menu cards render confirmation routes")
	check(count_nodes_with_name_prefix(scene, "MenuCardEntryConfirmTick_") == 6, "main menu cards render confirmation rhythm ticks")
	check(scene.mode == "menu" and scene.find_child("MenuSeasonProgressArt", true, false) != null, "menu footer renders season progress illustration")
	check(scene.find_child("MenuSeasonScrollTexture", true, false) != null, "menu season progress renders reusable scroll PNG texture")
	check(scene.find_child("MenuSeasonProgressRail", true, false) != null and scene.find_child("MenuSeasonProgressFill", true, false) != null and count_nodes_with_name_prefix(scene, "MenuSeasonRankNode_") == scene.SEASON_RANKS.size(), "menu season progress renders rail fill and rank nodes")
	check(scene.find_child("MenuSeasonCurrentRankHalo", true, false) != null and scene.find_child("MenuSeasonNextRankArrow", true, false) != null and count_nodes_with_name_prefix(scene, "MenuSeasonPointSpark_") == 3, "menu season progress renders current rank focus and point sparks")
	check(scene.find_child("MenuSeasonRouteRail", true, false) != null and scene.find_child("MenuSeasonRouteFill", true, false) != null and scene.find_child("MenuSeasonRouteGate", true, false) != null and count_nodes_with_name_prefix(scene, "MenuSeasonRouteNode_") == 2, "menu season progress renders promotion route")
	check(scene.find_child("MenuSeasonNextRankBridge", true, false) != null and scene.find_child("MenuSeasonNextRankBridgeFill", true, false) != null and scene.find_child("MenuSeasonNextRankBridgeGate", true, false) != null and count_nodes_with_name_prefix(scene, "MenuSeasonBridgeTick_") == 2, "menu season progress renders next-rank bridge route")
	check(count_nodes_with_name_prefix(scene, "MenuSeasonEnergyTick_") == 3, "menu season progress renders energy ticks")
	check(has_label_text(scene, "铂金"), "menu season badge names the current rank")
	check(scene.find_child("MenuCurrencyBadge", true, false) != null and scene.find_child("MenuCurrencyBrocadeTexture", true, false) != null and scene.find_child("MenuCurrencyBadgeArt", true, false) != null and scene.find_child("MenuCurrencyBadgeRail", true, false) != null and scene.find_child("MenuCurrencyBadgeFill", true, false) != null and scene.find_child("MenuCurrencyBadgeGate", true, false) != null, "menu footer currency badge renders reusable PNG resource route art")
	check(count_nodes_with_name_prefix(scene, "MenuCurrencyBadgeNode_") == 2 and count_nodes_with_name_prefix(scene, "MenuCurrencyBadgeTick_") == 3 and count_nodes_with_name_prefix(scene, "MenuCurrencyBadgeGateTick_") == 2, "menu footer currency badge renders resource nodes and ticks")
	check(scene.find_child("MenuStatsBadge", true, false) != null and scene.find_child("MenuStatsBadgeArt", true, false) != null and scene.find_child("MenuStatsBadgeRail", true, false) != null and scene.find_child("MenuStatsBadgeFill", true, false) != null and scene.find_child("MenuStatsBadgeGate", true, false) != null, "menu footer stats badge renders trend route art")
	check(count_nodes_with_name_prefix(scene, "MenuStatsBadgeTrendNode_") == 3 and count_nodes_with_name_prefix(scene, "MenuStatsBadgePip_") == 2 and count_nodes_with_name_prefix(scene, "MenuStatsBadgeGateTick_") == 2, "menu footer stats badge renders trend nodes and pips")
	check(scene.find_child("MenuDailyTaskArt", true, false) != null and scene.find_child("MenuDailyTaskRail", true, false) != null and scene.find_child("MenuDailyTaskFill", true, false), "menu footer renders daily task progress illustration")
	check(scene.find_child("MenuDailyLedgerTexture", true, false) != null, "menu daily task art renders reusable ledger PNG texture")
	check(count_nodes_with_name_prefix(scene, "MenuDailyTaskNode_") == scene.DAILY_TASKS.size() and scene.find_child("MenuDailyTaskFocusGlow", true, false) != null, "menu daily task art renders one node per task and focus glow")
	check(count_nodes_with_name_prefix(scene, "MenuDailyTaskClaimMark_") == 2 and scene.find_child("MenuDailyTaskFocusPulse", true, false) != null and count_nodes_with_name_prefix(scene, "MenuDailyTaskProgressPip_") == 3, "menu daily task art renders claim markers and focus pulse")
	check(scene.find_child("MenuDailyTaskRewardRail", true, false) != null and scene.find_child("MenuDailyTaskRewardFill", true, false) != null and count_nodes_with_name_prefix(scene, "MenuDailyTaskRewardNode_") == 2, "menu daily task art renders reward route")
	check(count_nodes_with_name_prefix(scene, "MenuDailyTaskRewardTick_") == 3, "menu daily task art renders reward rhythm ticks")
	check(scene.find_child("MenuDailyTaskCompletionRoute", true, false) != null and scene.find_child("MenuDailyTaskCompletionFill", true, false) != null and scene.find_child("MenuDailyTaskCompletionGate", true, false) != null and count_nodes_with_name_prefix(scene, "MenuDailyTaskCompletionTick_") == 2, "menu daily task art renders completion-to-reward route")
	check(has_label_text(scene, "每日任务 2/5"), "menu daily task badge names completed task count")
	check(scene.find_child("MenuSettingsButton", true, false) != null and scene.find_child("MenuSettingsGearTexture", true, false) != null and scene.find_child("MenuSettingsButtonArt", true, false) != null and scene.find_child("MenuSettingsButtonRail", true, false) != null and scene.find_child("MenuSettingsButtonFill", true, false) != null and scene.find_child("MenuSettingsButtonGate", true, false) != null, "menu settings button renders reusable PNG settings-entry route")
	check(count_nodes_with_name_prefix(scene, "MenuSettingsButtonTick_") == 2, "menu settings button renders entry rhythm ticks")
	check(scene.find_child("MenuQuickActionRail", true, false) != null and scene.find_child("MenuQuickActionPathTexture", true, false) != null and scene.find_child("MenuQuickActionRoute", true, false) != null and scene.find_child("MenuQuickActionRouteFill", true, false) != null and scene.find_child("MenuQuickActionGate", true, false) != null, "main menu renders quick action route with reusable path texture")
	check(scene.find_child("MenuQuickRulesButton", true, false) != null and scene.find_child("MenuQuickStatsButton", true, false) != null and scene.find_child("MenuQuickShopButton", true, false) != null, "main menu quick rail renders rules stats and shop buttons")
	check(count_nodes_with_name_prefix(scene, "MenuQuickActionTick_") == 4 and count_nodes_with_name_prefix(scene, "MenuQuickButtonArt_") == 3 and count_nodes_with_name_prefix(scene, "MenuQuickButtonNode_") == 3, "main menu quick rail renders button art nodes and route ticks")
	check(count_nodes_with_name_prefix(scene, "MenuQuickButtonTick_") == 6, "main menu quick rail renders per-button rhythm ticks")
	check(scene.find_child("MenuTutorialHintArt", true, false) != null and scene.find_child("MenuTutorialHintRail", true, false) != null and scene.find_child("MenuTutorialHintEntryBridge", true, false) != null and scene.find_child("MenuTutorialHintEntryGate", true, false) != null, "main menu tutorial renders rules-entry guide route")
	check(scene.find_child("MenuTutorialTargetRoute", true, false) != null and scene.find_child("MenuTutorialTargetFill", true, false) != null and scene.find_child("MenuTutorialTargetGate", true, false) != null and count_nodes_with_name_prefix(scene, "MenuTutorialTargetTick_") == 3, "main menu tutorial renders target route to rules button")
	scene.start_offline(true)
	scene._show_rules_screen_impl()
	check(scene.mode == "rules" and scene.find_child("RulesGuideArt", true, false) != null and scene.find_child("RulesGuideRail", true, false) != null, "rules screen renders guide illustration")
	check(scene.find_child("RulesScrollTexture", true, false) != null, "rules screen renders reusable scroll PNG texture")
	check(scene.find_child("RulesGuideRailFill", true, false) != null and scene.find_child("RulesGuideCompletionGate", true, false) != null and count_nodes_with_name_prefix(scene, "RulesGuideRhythmTick_") == 3, "rules guide renders completion route fill gate and rhythm ticks")
	check(scene.find_child("SecondaryBackTexture_rules", true, false) != null and scene.find_child("SecondaryBackButtonArt_rules", true, false) != null and scene.find_child("SecondaryBackButtonRail_rules", true, false) != null and scene.find_child("SecondaryBackButtonFill_rules", true, false) != null and scene.find_child("SecondaryBackButtonGate_rules", true, false) != null, "rules back button renders reusable PNG return-route art")
	check(count_nodes_with_name_prefix(scene, "SecondaryBackButtonTick_rules_") == 2, "rules back button renders return rhythm ticks")
	check(scene.find_child("SecondaryBackConfirmRoute_rules", true, false) != null and scene.find_child("SecondaryBackConfirmFill_rules", true, false) != null and scene.find_child("SecondaryBackConfirmGate_rules", true, false) != null and count_nodes_with_name_prefix(scene, "SecondaryBackConfirmTick_rules_") == 2, "rules back button renders return confirmation route")
	check(scene.find_child("SecondaryBackSourceNode_rules", true, false) != null and scene.find_child("SecondaryBackDestinationNode_rules", true, false) != null and count_nodes_with_name_prefix(scene, "SecondaryBackNodeTick_rules_") == 2, "rules back button renders source destination and node rhythm ticks")
	check(count_nodes_with_name_prefix(scene, "RulesGuideStep_") == 4 and count_nodes_with_name_prefix(scene, "RulesGuideConnector_") == 3, "rules guide renders four steps and connectors")
	check(scene.find_child("RulesGuideLeadGlow", true, false) != null and count_named_nodes(scene, "RuleSectionMarker") == 4, "rules screen renders animated lead glow and section markers")
	check(count_nodes_with_name_prefix(scene, "RuleSectionArtStrip_") == 4 and count_nodes_with_name_prefix(scene, "RuleSectionCategoryBadge_") == 4, "rules sections render category strip illustrations")
	check(count_nodes_with_name_prefix(scene, "RuleSectionPathRail_") == 4 and count_nodes_with_name_prefix(scene, "RuleSectionPathNode_") == 12, "rules sections render path rails and nodes")
	check(count_nodes_with_name_prefix(scene, "RuleSectionPathFill_") == 4 and count_nodes_with_name_prefix(scene, "RuleSectionPathGate_") == 4 and count_nodes_with_name_prefix(scene, "RuleSectionPathGlyph_") == 4, "rules sections render path fills gates and glyph accents")
	check(count_nodes_with_name_prefix(scene, "RuleSectionExampleBridge_") == 4 and count_nodes_with_name_prefix(scene, "RuleSectionExampleBridgeFill_") == 4 and count_nodes_with_name_prefix(scene, "RuleSectionExampleBridgeGate_") == 4, "rules sections render title-to-example bridge routes")
	check(count_nodes_with_name_prefix(scene, "RuleSectionExampleBridgeTick_") == 8, "rules sections render title-to-example bridge rhythm ticks")
	check(count_nodes_with_name_prefix(scene, "RuleLineGuide_") == 4 and count_nodes_with_name_prefix(scene, "RuleLineRail_") == 4 and count_nodes_with_name_prefix(scene, "RuleLineLead_") == 4, "rules sections render line guide rails and leads")
	check(count_nodes_with_name_prefix(scene, "RuleLineBullet_") == 13 and count_nodes_with_name_prefix(scene, "RuleLinePulse_") == 13, "rules sections render one visual bullet and pulse per rule line")
	check(count_nodes_with_name_prefix(scene, "RuleSectionExampleArt_") == 4 and count_nodes_with_name_prefix(scene, "RuleGoalGroup_") == 5, "rules sections render concrete example art and goal groups")
	check(count_nodes_with_name_prefix(scene, "RulesExampleTableTexture_") == 4, "rules examples render reusable table PNG textures")
	check(count_nodes_with_name_prefix(scene, "RuleExampleCompletionRoute_") == 4 and count_nodes_with_name_prefix(scene, "RuleExampleCompletionFill_") == 4 and count_nodes_with_name_prefix(scene, "RuleExampleCompletionGate_") == 4, "rules examples render completion routes")
	check(count_nodes_with_name_prefix(scene, "RuleExampleCompletionTick_") == 8, "rules examples render completion rhythm ticks")
	check(count_nodes_with_name_prefix(scene, "RuleSectionExampleTile_1_") == 3 and count_nodes_with_name_prefix(scene, "RuleSectionExamplePairTile_") == 2, "rules tile section renders sequence and pair tile examples")
	check(count_nodes_with_name_prefix(scene, "RuleSevenPairsNode_") == 7 and scene.find_child("RuleOrphanBadge", true, false) != null, "rules special hand section renders seven-pairs and orphan examples")
	check(scene.find_child("RuleActionChip_吃", true, false) != null and scene.find_child("RuleActionChip_胡", true, false) != null and scene.find_child("RuleActionWinPulse", true, false) != null, "rules action section renders action chips and win pulse")
	check(scene.find_child("RuleActionFlowRail", true, false) != null and scene.find_child("RuleActionFlowFill", true, false) != null and count_nodes_with_name_prefix(scene, "RuleActionFlowNode_") == 4, "rules action section renders response flow rail and nodes")
	check(count_nodes_with_name_prefix(scene, "RuleActionFlowTick_") == 3, "rules action section renders response flow ticks")
	scene.start_offline(true)
	scene.selected_room = "ROOM7"
	scene.online_room = {"code": "ROOM7", "players": [{"name": "甲"}, {"name": "乙"}], "logs": ["甲加入房间", "乙准备"]}
	scene.online_feedback = "已发送加入房间，等待服务器确认。"
	scene.online_waiting_for_server = true
	scene._show_online_lobby_impl()
	check(scene.mode == "online_lobby" and scene.find_child("OnlineLobbyRoomArt", true, false) != null and scene.find_child("OnlineLobbyRoomNode", true, false) != null, "online lobby renders room status illustration")
	check(scene.find_child("OnlineLobbyNetworkTexture", true, false) != null, "online lobby renders reusable network PNG texture")
	check(scene.find_child("LineEditInputArt_name", true, false) != null and scene.find_child("LineEditInputArt_server", true, false) != null and scene.find_child("LineEditInputArt_room", true, false) != null, "online lobby line edits render input illustrations")
	check(count_nodes_with_name_prefix(scene, "LineEditInputPulse_") == 6, "online lobby line edits render input pulse accents")
	check(scene.find_child("LineEditInputTargetRoute_name", true, false) != null and scene.find_child("LineEditInputTargetRoute_server", true, false) != null and scene.find_child("LineEditInputTargetRoute_room", true, false) != null, "online lobby line edits render target routes")
	check(count_nodes_with_name_prefix(scene, "LineEditInputTargetGate_") == 3 and count_nodes_with_name_prefix(scene, "LineEditInputTargetTick_") == 6, "online lobby line edits render target gates and ticks")
	check(count_nodes_with_name_prefix(scene, "LineEditInputValueRoute_") == 3 and count_nodes_with_name_prefix(scene, "LineEditInputValueGate_") == 3 and count_nodes_with_name_prefix(scene, "LineEditInputValueTick_") == 6, "online lobby line edits render value routes and ticks")
	check(count_nodes_with_name_prefix(scene, "LobbyActionTokenTexture_") == 5 and count_nodes_with_name_prefix(scene, "LobbyActionButtonArt_") == 5 and scene.find_child("LobbyActionButtonRoute_连接", true, false) != null and scene.find_child("LobbyActionButtonRoute_开始游戏", true, false) != null, "online lobby action buttons render reusable PNG command route art")
	check(count_nodes_with_name_prefix(scene, "LobbyActionButtonNode_") == 5 and count_nodes_with_name_prefix(scene, "LobbyActionButtonGlyph_") == 5 and count_nodes_with_name_prefix(scene, "LobbyActionButtonTick_") == 15, "online lobby action buttons render command nodes, glyphs, and rhythm ticks")
	check(count_nodes_with_name_prefix(scene, "LobbyActionCommandRoute_") == 5 and count_nodes_with_name_prefix(scene, "LobbyActionCommandFill_") == 5 and count_nodes_with_name_prefix(scene, "LobbyActionCommandGate_") == 5, "online lobby action buttons render execution command routes")
	check(count_nodes_with_name_prefix(scene, "LobbyActionCommandTick_") == 10, "online lobby action buttons render execution command rhythm ticks")
	check(scene.find_child("OnlineLobbyRoomRail", true, false) != null and count_nodes_with_name_prefix(scene, "OnlineLobbyPlayerSlot_") == 4 and count_nodes_with_name_prefix(scene, "OnlineLobbyLogPulse_") == 2, "online lobby room art renders player slots and log pulses")
	check(scene.find_child("OnlineLobbyReadyRail", true, false) != null and count_nodes_with_name_prefix(scene, "OnlineLobbySeatSignal_") == 4, "online lobby room art renders ready signal rail")
	check(count_nodes_with_name_prefix(scene, "OnlineLobbySeatReadyGlow_") == 2 and count_nodes_with_name_prefix(scene, "OnlineLobbyConnectionWave_") == 3, "online lobby room art renders active seat glows and connection waves")
	check(scene.find_child("OnlineLobbySyncGate", true, false) != null and scene.find_child("OnlineLobbyStartGateBack", true, false) != null and scene.find_child("OnlineLobbyStartGateFill", true, false) != null and scene.find_child("OnlineLobbyStartGateSeal", true, false) != null, "online lobby room art renders start gate readiness illustration")
	check(scene.find_child("OnlineLobbySyncTimeline", true, false) != null and count_nodes_with_name_prefix(scene, "OnlineLobbySyncBead_") == 3 and scene.find_child("OnlineLobbyWaitingSeal", true, false) != null, "online lobby room art renders sync timeline and waiting seal")
	check(scene.find_child("OnlineLobbyLogStreamArt", true, false) != null and scene.find_child("OnlineLobbyLogSpine", true, false) != null and scene.find_child("OnlineLobbyLogStreamRail", true, false) != null and scene.find_child("OnlineLobbyLogStreamFill", true, false) != null, "online lobby log panel renders stream art")
	check(count_nodes_with_name_prefix(scene, "OnlineLobbyLogNode_") == 2 and count_nodes_with_name_prefix(scene, "OnlineLobbyLogLane_") == 2 and count_nodes_with_name_prefix(scene, "OnlineLobbyLogStreamTick_") == 3, "online lobby log stream renders one node per visible room log and sync ticks")
	check(scene.find_child("OnlineLobbyConnectionRouteArt", true, false) != null and scene.find_child("OnlineLobbyConnectionRoute", true, false) != null and scene.find_child("OnlineLobbyConnectionFill", true, false) != null and scene.find_child("OnlineLobbyConnectionGate", true, false) != null, "online lobby renders panel-level connection route")
	check(count_nodes_with_name_prefix(scene, "OnlineLobbyConnectionNode_") == 2 and count_nodes_with_name_prefix(scene, "OnlineLobbyConnectionTick_") == 3, "online lobby connection route renders endpoint nodes and rhythm ticks")
	check(scene.find_child("OnlineLobbyHandshakeRoute", true, false) != null and scene.find_child("OnlineLobbyHandshakeFill", true, false) != null and scene.find_child("OnlineLobbyHandshakeGate", true, false) != null, "online lobby connection route renders handshake status band")
	check(scene.find_child("OnlineLobbyHandshakeStep_connect", true, false) != null and scene.find_child("OnlineLobbyHandshakeStep_room", true, false) != null and scene.find_child("OnlineLobbyHandshakeStep_start", true, false) != null, "online lobby handshake band renders connect room and start steps")
	check(scene.find_child("OnlineFeedbackArt", true, false) != null and scene.find_child("OnlineFeedbackStatusSeal", true, false) != null and scene.find_child("OnlineFeedbackRail", true, false) != null and scene.find_child("OnlineFeedbackFill", true, false) != null, "online lobby renders server feedback status strip")
	check(scene.find_child("OnlineFeedbackMessageLane", true, false) != null and scene.find_child("OnlineFeedbackPendingHalo", true, false) != null and count_nodes_with_name_prefix(scene, "OnlineFeedbackPulse_") == 3, "online feedback strip renders waiting lane and pulses")
	check(scene.find_child("OnlineFeedbackResponseRoute", true, false) != null and scene.find_child("OnlineFeedbackResponseFill", true, false) != null and scene.find_child("OnlineFeedbackResponseGate", true, false) != null and count_nodes_with_name_prefix(scene, "OnlineFeedbackResponseTick_") == 2, "online feedback strip renders response route and rhythm ticks")
	check(scene.find_child("OnlineFeedbackResultNode", true, false) != null and count_nodes_with_name_prefix(scene, "OnlineFeedbackResultTick_") == 2, "online feedback strip renders result node and ticks")
	check(has_label_text(scene, "房间号 ROOM7"), "online lobby room badge names the selected room")
	var empty_lobby_log_parent = Control.new()
	root.add_child(empty_lobby_log_parent)
	scene.online_room = {"code": "ROOM0", "players": [], "logs": []}
	scene.draw_online_lobby_log_stream_art(empty_lobby_log_parent)
	check(empty_lobby_log_parent.find_child("OnlineLobbyEmptyLogRoute", true, false) != null and empty_lobby_log_parent.find_child("OnlineLobbyEmptyLogFill", true, false) != null and empty_lobby_log_parent.find_child("OnlineLobbyEmptyLogGate", true, false) != null, "online lobby empty log stream renders waiting route")
	check(empty_lobby_log_parent.find_child("OnlineLobbyEmptyLogGlyph", true, false) != null and count_nodes_with_name_prefix(empty_lobby_log_parent, "OnlineLobbyEmptyLogTick_") == 3, "online lobby empty log stream renders waiting glyph and rhythm ticks")
	empty_lobby_log_parent.queue_free()
	scene.start_offline(true)
	var ornament_parent = Control.new()
	root.add_child(ornament_parent)
	check(scene.TABLE_ORNAMENT_EDGES.size() == 4 and scene.TABLE_CORNER_RECTS.size() == 4, "table ornaments reuse fixed geometry constants")
	check(scene.TABLE_ORNAMENT_EDGES[0][0] is Rect2 and scene.TABLE_ORNAMENT_EDGES[0][1] is Color, "table ornament constants keep precomputed rect and color data")
	scene.draw_table_ornaments(ornament_parent)
	check(count_panel_shadow_size(ornament_parent, 0) >= 12, "table ornaments use shadowless panels for cheaper rendering")
	ornament_parent.queue_free()
	var dice_parent = Control.new()
	root.add_child(dice_parent)
	scene.draw_dice_dot(dice_parent, 0.5, 0.5)
	check(count_panel_shadow_size(dice_parent, 0) == 1, "dice dots use shadowless panels for cheaper rendering")
	dice_parent.queue_free()
	var previous_phase = scene.offline_phase
	var previous_summary = scene.round_summary
	var previous_hand_number = scene.offline_hand_number
	scene.offline_phase = "ended"
	scene.offline_hand_number = 1
	scene.round_summary = "超长顶部状态文本用于验证HUD不会自动换行挤压分数和按钮区域"
	var hud_parent = Control.new()
	root.add_child(hud_parent)
	scene.draw_game_top_hud(hud_parent)
	var hud_panel = hud_parent.get_child(0) as Control if hud_parent.get_child_count() > 0 else null
	check(control_anchor_rect_matches(hud_panel, scene.TOP_HUD_RECT), "top HUD root uses fixed geometry constants")
	check(label_is_clipped(first_label_containing_text(hud_parent, "超长顶部状态文本")), "top HUD status clips long text instead of wrapping")
	check(label_is_clipped(first_label_containing_text(hud_parent, "余")), "top HUD wall summary clips inside its slot")
	check(control_anchor_rect_matches(first_label_containing_text(hud_parent, "单机修炼场"), scene.TOP_HUD_TITLE_RECT), "top HUD title uses fixed geometry constants")
	check(control_anchor_rect_matches(first_label_containing_text(hud_parent, "超长顶部状态文本"), scene.TOP_HUD_STATUS_RECT), "top HUD status uses fixed geometry constants")
	check(control_anchor_rect_matches(first_label_containing_text(hud_parent, "余"), scene.TOP_HUD_WALL_RECT), "top HUD wall summary uses fixed geometry constants")
	check(hud_parent.find_child("TopHudWallMeter", true, false) != null and hud_parent.find_child("TopHudWallMeterFill", true, false) != null and hud_parent.find_child("TopHudWallStatusDot", true, false) != null, "top HUD renders compact wall progress illustration")
	check(hud_parent.find_child("TopHudWallStack", true, false) != null and count_nodes_with_name_prefix(hud_parent, "TopHudWallStackLayer_") == 3 and hud_parent.find_child("TopHudWallLastNode", true, false) != null, "top HUD wall meter renders stack and last-tile node")
	check(hud_parent.find_child("TopHudWallStackBridge", true, false) != null and hud_parent.find_child("TopHudWallStackBridgeFill", true, false) != null and hud_parent.find_child("TopHudWallStackBridgeGate", true, false) != null and count_nodes_with_name_prefix(hud_parent, "TopHudWallStackBridgeTick_") == 2, "top HUD wall meter renders stack-to-status bridge")
	check(hud_parent.find_child("TopHudWallStatusRoute", true, false) != null and hud_parent.find_child("TopHudWallStatusFill", true, false) != null and hud_parent.find_child("TopHudWallStatusGate", true, false) != null and count_nodes_with_name_prefix(hud_parent, "TopHudWallStatusTick_") == 2, "top HUD wall meter renders status route")
	check(count_nodes_with_name_prefix(hud_parent, "TopHudWallRhythmTick_") == 3, "top HUD wall meter renders rhythm ticks")
	check(hud_parent.find_child("TopHudBannerTexture", true, false) != null, "top HUD renders reusable status banner PNG texture")
	check(hud_parent.find_child("TopHudModeBadge", true, false) != null and hud_parent.find_child("TopHudStatusArt", true, false) != null and hud_parent.find_child("TopHudStatusPulse", true, false) != null, "top HUD renders mode badge and animated status art")
	check(hud_parent.find_child("TopHudStatusIconBack", true, false) != null and hud_parent.find_child("TopHudStatusRail", true, false) != null and count_nodes_with_name_prefix(hud_parent, "TopHudStatusPip_") == 3, "top HUD renders status icon rail and rhythm pips")
	check(hud_parent.find_child("TopHudStatusRoute", true, false) != null and hud_parent.find_child("TopHudStatusRouteFill", true, false) != null and hud_parent.find_child("TopHudStatusRouteGate", true, false) != null and count_nodes_with_name_prefix(hud_parent, "TopHudStatusRouteTick_") == 3, "top HUD renders status route to the phase text")
	check(hud_parent.find_child("ScoreStrip", true, false) != null and count_nodes_with_name_prefix(hud_parent, "ScoreStripChip_") == 4 and count_nodes_with_name_prefix(hud_parent, "ScoreStripSeatSeal_") == 4, "top HUD score strip renders four chip seals")
	check(count_nodes_with_name_prefix(hud_parent, "ScoreStripMomentumRail_") == 4 and count_nodes_with_name_prefix(hud_parent, "ScoreStripMomentumFill_") == 4 and hud_parent.find_child("ScoreStripActivePulse", true, false) != null, "top HUD score strip renders momentum rails and active pulse")
	check(hud_parent.find_child("ScoreStripActiveRoute", true, false) != null and hud_parent.find_child("ScoreStripActiveRouteFill", true, false) != null and hud_parent.find_child("ScoreStripActiveRouteGate", true, false) != null and count_nodes_with_name_prefix(hud_parent, "ScoreStripActiveRouteTick_") == 3, "top HUD score strip renders active-player route")
	check(count_nodes_with_name_prefix(hud_parent, "ScoreStripRankRoute_") == 4 and count_nodes_with_name_prefix(hud_parent, "ScoreStripRankRouteFill_") == 4 and count_nodes_with_name_prefix(hud_parent, "ScoreStripRankNode_") == 4, "top HUD score strip renders rank routes and nodes")
	var score_strip_rank_ticks_present = true
	var score_strip_leader_routes_present = false
	for seat in range(4):
		score_strip_rank_ticks_present = score_strip_rank_ticks_present and hud_parent.find_child("ScoreStripRankTick_%d_0" % seat, true, false) != null and hud_parent.find_child("ScoreStripRankTick_%d_1" % seat, true, false) != null
		if scene.score_strip_rank_for_score(int(scene.players[seat].get("score", 0))) == 1:
			score_strip_leader_routes_present = score_strip_leader_routes_present or hud_parent.find_child("ScoreStripLeaderRoute_%d" % seat, true, false) != null
			score_strip_rank_ticks_present = score_strip_rank_ticks_present and hud_parent.find_child("ScoreStripLeaderFill_%d" % seat, true, false) != null and hud_parent.find_child("ScoreStripLeaderGate_%d" % seat, true, false) != null and hud_parent.find_child("ScoreStripLeaderTick_%d_0" % seat, true, false) != null and hud_parent.find_child("ScoreStripLeaderTick_%d_1" % seat, true, false) != null
	check(score_strip_rank_ticks_present, "top HUD score strip renders rank ticks")
	check(score_strip_leader_routes_present, "top HUD score strip renders leader confirmation route")
	var score_strip_test_ceiling = 1
	for player in scene.players:
		if typeof(player) == TYPE_DICTIONARY:
			score_strip_test_ceiling = max(score_strip_test_ceiling, int(player.get("score", 0)) + 1)
	check(scene.score_strip_rank_for_score(score_strip_test_ceiling) == 1, "top HUD score strip ranks high scores first")
	var hud_settings_button = first_button_with_text(hud_parent, "设置")
	check(hud_settings_button != null and hud_settings_button.custom_minimum_size == scene.TOP_HUD_BUTTON_SIZE, "rendered top HUD buttons use enlarged touch targets")
	check(hud_settings_button != null and count_texture_rects(hud_settings_button) >= 1, "top HUD settings button renders a lucide icon")
	check(count_nodes_with_name_prefix(hud_parent, "TopHudButtonArt_") == 3 and hud_settings_button.find_child("TopHudButtonIconBack_设置", true, false) != null and hud_settings_button.find_child("TopHudButtonRail_设置", true, false) != null, "top HUD buttons render illustrated icon backs and rails")
	check(hud_settings_button.find_child("TopHudButtonRailFill_设置", true, false) != null and count_nodes_with_name_prefix(hud_settings_button, "TopHudButtonPulse_设置_") == 2, "top HUD settings button renders rail fill and pulse accents")
	check(count_nodes_with_name_prefix(hud_parent, "TopHudButtonCommandRoute_") == 3 and count_nodes_with_name_prefix(hud_parent, "TopHudButtonCommandFill_") == 3 and count_nodes_with_name_prefix(hud_parent, "TopHudButtonCommandGate_") == 3, "top HUD buttons render command routes")
	check(count_nodes_with_name_prefix(hud_parent, "TopHudButtonCommandTick_") == 6, "top HUD buttons render command rhythm ticks")
	check(control_anchor_rect_matches(hud_settings_button, scene.TOP_HUD_SETTINGS_BUTTON_RECT), "top HUD settings button uses fixed geometry constants")
	check(control_anchor_rect_matches(first_button_with_text(hud_parent, "返回"), scene.TOP_HUD_BACK_BUTTON_RECT), "top HUD back button uses fixed geometry constants")
	check(control_anchor_rect_matches(first_button_with_text(hud_parent, "更新"), scene.TOP_HUD_UPDATE_BUTTON_RECT), "top HUD update button uses fixed geometry constants")
	hud_parent.queue_free()
	scene.offline_phase = previous_phase
	scene.round_summary = previous_summary
	scene.offline_hand_number = previous_hand_number
	var avatar = scene.make_avatar_view(1, true)
	check(has_label_text(avatar, "南") and has_label_text(avatar, "行牌"), "seat avatar renders active 2D identity")
	check(avatar.find_child("SeatAvatarHead", true, false) != null and avatar.find_child("SeatAvatarShoulders", true, false) != null and avatar.find_child("SeatAvatarWindSeal", true, false) != null and avatar.find_child("SeatAvatarActiveHalo", true, false) != null, "seat avatar renders layered 2D character illustration")
	check(not contains_subviewport(avatar), "seat avatar avoids expensive SubViewport rendering")
	avatar.queue_free()
	check(scene.tile_textures.get("E", null) != scene.tile_back and scene.tile_textures.get("H1", null) != scene.tile_back, "wind and flower textures do not fall back to tile back")
	var east_tile_view = scene.make_tile_view("E", Vector2(62, 84), false, Callable())
	check(east_tile_view.custom_minimum_size == Vector2(62, 84), "wind tile view keeps requested size")
	check(tile_view_inner_frame_is_fixed(east_tile_view, Vector2(62, 84)), "wind tile inner frame stays fixed when parent stretches")
	check(first_button(east_tile_view) == null, "static tile views avoid button nodes")
	check(has_visible_tile_art(east_tile_view), "wind tile view renders real tile art inside fixed frame")
	check(not has_label_text(east_tile_view, "东") and not has_label_text(east_tile_view, "风"), "wind tile view uses real art without duplicate code-drawn labels")
	check(tile_texture_rects_are_bounded(east_tile_view), "wind tile texture ignores source pixel size")
	east_tile_view.queue_free()
	var number_tile_view = scene.make_tile_view("5W", Vector2(62, 84), false, Callable())
	check(has_visible_tile_art(number_tile_view), "number tile view renders real tile art inside fixed frame")
	check(not has_label_text(number_tile_view, "5") and not has_label_text(number_tile_view, "万") and count_label_nodes(number_tile_view) == 0, "number tile view avoids duplicate numeric labels when tile art exists")
	check(tile_view_inner_frame_is_fixed(number_tile_view, Vector2(62, 84)), "number tile inner frame stays fixed")
	scene.play_tile_flip_animation(number_tile_view, true)
	check(number_tile_view.find_child("TileFlipSignalArt", true, false) != null and number_tile_view.find_child("TileFlipAxis", true, false) != null and number_tile_view.find_child("TileFlipAxisCore", true, false) != null, "tile flip animation renders axis signal art")
	check(number_tile_view.find_child("TileFlipSourceGate", true, false) != null and number_tile_view.find_child("TileFlipRevealGate", true, false) != null and number_tile_view.find_child("TileFlipFaceBadge_front", true, false) != null, "tile flip animation renders source reveal gates and front-state badge")
	check(number_tile_view.find_child("TileFlipRoute", true, false) != null and number_tile_view.find_child("TileFlipRouteFill", true, false) != null and count_nodes_with_name_prefix(number_tile_view, "TileFlipRhythmTick_") == 3, "tile flip animation renders route fill and rhythm ticks")
	number_tile_view.queue_free()
	var small_static_tile_view = scene.make_tile_view("5W", Vector2(38, 52), false, Callable())
	check(small_static_tile_view is Panel and small_static_tile_view.custom_minimum_size == Vector2(38, 52), "small static tile uses panel root without wrapper node")
	check(has_visible_tile_art(small_static_tile_view), "small static tile renders real tile art instead of text-only fallback")
	check(not has_label_text(small_static_tile_view, "5万") and count_label_nodes(small_static_tile_view) == 0, "small static tile avoids duplicate text when tile art exists")
	check(count_control_nodes(small_static_tile_view) == 2, "small static tile keeps only root panel and texture controls")
	check(count_texture_rects(small_static_tile_view) == 1, "small static tile uses one bounded texture node for discard readability")
	check(count_color_rects(small_static_tile_view) == 0, "small static tile skips decorative shade nodes for render performance")
	check(panel_shadow_size(small_static_tile_view) == 0, "small static tile skips panel shadow for render performance")
	small_static_tile_view.queue_free()
	var tile_press_count := {"value": 0}
	var clickable_tile_view = scene.make_tile_view("6W", Vector2(62, 84), true, func() -> void:
		tile_press_count["value"] = int(tile_press_count.get("value", 0)) + 1
	)
	var clickable_tile_button = first_button(clickable_tile_view)
	check(clickable_tile_button != null, "clickable tile contains a button")
	check(clickable_tile_view.find_child("ClickableTilePressSheen", true, false) != null and clickable_tile_view.find_child("ClickableTileTapDot", true, false) != null, "clickable tiles render press sheen and tap ripple art")
	check(clickable_tile_view.find_child("ClickableTileReleaseRoute", true, false) != null and clickable_tile_view.find_child("ClickableTileReleaseFill", true, false) != null and clickable_tile_view.find_child("ClickableTileReleaseGate", true, false) != null, "clickable tiles render release route and gate")
	check(count_nodes_with_name_prefix(clickable_tile_view, "ClickableTileReleaseTick_") == 2, "clickable tiles render release rhythm ticks")
	clickable_tile_button.emit_signal("button_down")
	check(int(tile_press_count.get("value", 0)) == 1, "tile callbacks run on button down")
	check(count_label_nodes(clickable_tile_view) == 0, "clickable tile uses real tile art without duplicate code-drawn labels")
	clickable_tile_view.queue_free()
	var highlighted_clickable_tile = scene.make_tile_view("6W", Vector2(62, 84), true, Callable(), true)
	check(highlighted_clickable_tile.find_child("ClickableTileFocusGlow", true, false) != null and highlighted_clickable_tile.find_child("ClickableTilePressSheen", true, false) != null, "highlighted clickable tiles render focus glow and press art")
	highlighted_clickable_tile.queue_free()
	var hand_group_spacer = scene.make_hand_group_spacer(84.0, 12.0, scene.hand_group_label("1B"))
	check(hand_group_spacer.name == "HandGroupDivider" and hand_group_spacer.find_child("HandGroupDividerCap", true, false) != null, "hand group divider renders stable cap decoration")
	check(hand_group_spacer.find_child("HandGroupDividerRoute", true, false) != null and hand_group_spacer.find_child("HandGroupDividerFill", true, false) != null and hand_group_spacer.find_child("HandGroupDividerGate", true, false) != null and count_nodes_with_name_prefix(hand_group_spacer, "HandGroupDividerTick_") == 2, "hand group divider renders route fill gate and rhythm ticks")
	check(hand_group_spacer.find_child("HandGroupDividerLabel_筒", true, false) != null, "hand group divider renders suit label without changing tile nodes")
	hand_group_spacer.queue_free()
	var hand_counts = scene.hand_group_counts(["1W", "2W", "3T", "4B", "E", "H1"])
	check(hand_counts == [2, 1, 1, 1, 1], "hand group counts summarize suits honors and flowers")
	var hand_tray_parent = Control.new()
	root.add_child(hand_tray_parent)
	var previous_last_draw = scene.offline_last_draw.duplicate(true)
	var previous_show_hand_hint = scene.show_hand_hint
	var previous_tutorial_step = scene.tutorial_step
	scene.players[0]["hand"] = ["1W", "2W", "3W", "4T", "5T", "6B", "E", "H1"]
	scene.offline_last_draw = {"seat": 0, "tile": "6B", "source": "normal", "serial": 99, "announce": false}
	scene.show_hand_hint = true
	scene.tutorial_step = 0
	scene.draw_hand(hand_tray_parent)
	check(hand_tray_parent.find_child("HandTray", true, false) != null and hand_tray_parent.find_child("HandTrayStateBadge", true, false) != null and hand_tray_parent.find_child("HandTrayStateArt", true, false) != null, "hand tray renders named state badge and state art")
	check(hand_tray_parent.find_child("HandTrayTutorialHint", true, false) != null and hand_tray_parent.find_child("HandTrayTutorialHintArt", true, false) != null and hand_tray_parent.find_child("HandTrayTutorialSeal", true, false) != null, "hand tutorial hint renders illustrated seal")
	check(hand_tray_parent.find_child("HandTrayTutorialStepRail", true, false) != null and hand_tray_parent.find_child("HandTrayTutorialStepFill", true, false) != null and count_nodes_with_name_prefix(hand_tray_parent, "HandTrayTutorialStepNode_") == 3, "hand tutorial hint renders step rail and nodes")
	check(hand_tray_parent.find_child("HandTrayTutorialTargetTile", true, false) != null and hand_tray_parent.find_child("HandTrayTutorialArrow", true, false) != null and count_nodes_with_name_prefix(hand_tray_parent, "HandTrayTutorialClickRipple_") == 3, "hand tutorial hint renders target tile and click ripples")
	check(hand_tray_parent.find_child("HandTraySuitFlow", true, false) != null and hand_tray_parent.find_child("HandTraySuitRail", true, false) != null and count_nodes_with_name_prefix(hand_tray_parent, "HandTraySuitNode_") == 5, "hand tray renders five-part suit flow illustration")
	check(hand_tray_parent.find_child("HandTraySuitRailFill", true, false) != null and hand_tray_parent.find_child("HandTraySuitDominantGate", true, false) != null and count_nodes_with_name_prefix(hand_tray_parent, "HandTraySuitFlowTick_") == 4, "hand tray suit flow renders coverage fill dominant gate and rhythm ticks")
	var hand_suit_fill = hand_tray_parent.find_child("HandTraySuitRailFill", true, false) as Control
	var hand_suit_gate = hand_tray_parent.find_child("HandTraySuitDominantGate", true, false) as Control
	check(hand_suit_fill != null and hand_suit_fill.anchor_right > 0.95, "hand tray suit flow fill tracks occupied suit coverage")
	check(hand_suit_gate != null and hand_suit_gate.anchor_left < 0.05, "hand tray suit flow dominant gate follows the strongest suit")
	check(hand_tray_parent.find_child("HandTrayFlowTexture", true, false) != null, "hand tray renders reusable flow PNG texture")
	check(hand_tray_parent.find_child("HandTrayMomentumArt", true, false) != null and hand_tray_parent.find_child("HandTrayMomentumRail", true, false) != null and hand_tray_parent.find_child("HandTrayMomentumFocus", true, false) != null, "hand tray renders momentum rail and focus art")
	check(count_nodes_with_name_prefix(hand_tray_parent, "HandTrayMomentumPip_") >= 3 and hand_tray_parent.find_child("HandTrayLastDrawBadge", true, false) != null, "hand tray momentum art renders hand pips and last draw badge")
	check(hand_tray_parent.find_child("HandTrayDrawDecisionRoute", true, false) != null and hand_tray_parent.find_child("HandTrayDrawDecisionFill", true, false) != null and hand_tray_parent.find_child("HandTrayDrawDecisionGate", true, false) != null and count_nodes_with_name_prefix(hand_tray_parent, "HandTrayDrawDecisionTick_") == 2, "hand tray renders draw-to-decision route")
	check(hand_tray_parent.find_child("HandTrayDrawSourceNode", true, false) != null and hand_tray_parent.find_child("HandTrayReplacementGate", true, false) != null, "hand tray draw decision renders source node and replacement gate")
	var normal_replacement_gate = hand_tray_parent.find_child("HandTrayReplacementGate", true, false) as Control
	check(normal_replacement_gate != null and normal_replacement_gate.modulate.a >= 0.99, "normal draw replacement gate remains visible as a low-intensity silhouette")
	hand_tray_parent.queue_free()
	var gang_draw_parent = Control.new()
	root.add_child(gang_draw_parent)
	scene.offline_last_draw = {"seat": 0, "tile": "6B", "source": "gang", "serial": 100, "announce": false}
	scene.show_hand_hint = false
	scene.draw_hand(gang_draw_parent)
	check(gang_draw_parent.find_child("HandTrayDrawSourceNode", true, false) != null and gang_draw_parent.find_child("HandTrayReplacementGate", true, false) != null and has_label_text(gang_draw_parent, "杠"), "gang replacement draw renders source node replacement gate and gang badge")
	gang_draw_parent.queue_free()
	scene.offline_last_draw = previous_last_draw
	scene.show_hand_hint = previous_show_hand_hint
	scene.tutorial_step = previous_tutorial_step
	var flower_tile_view = scene.make_tile_view("H1", Vector2(62, 84), false, Callable())
	check(has_visible_tile_art(flower_tile_view), "flower tile view renders real tile art inside fixed frame")
	check(not has_label_text(flower_tile_view, "春") and not has_label_text(flower_tile_view, "花"), "flower tile view uses real art without duplicate code-drawn labels")
	check(tile_texture_rects_are_bounded(flower_tile_view), "flower tile texture keeps stable bounds")
	flower_tile_view.queue_free()
	var missing_tile_view = scene.make_tile_view("ZZ", Vector2(62, 84), false, Callable())
	check(count_label_nodes(missing_tile_view) == 0 and count_texture_rects(missing_tile_view) == 0, "missing tile art does not fall back to text-only rendering")
	missing_tile_view.queue_free()
	var wall_back_view = scene.make_wall_back_tile()
	check(wall_back_view.custom_minimum_size == scene.WALL_BACK_TILE_SIZE, "wall back tile has compact fixed size")
	check(has_label_text(wall_back_view, "云"), "wall back tile has visible compact mark")
	check(tile_texture_rects_are_bounded(wall_back_view), "wall back texture ignores 600x800 source size")
	wall_back_view.queue_free()
	var wall_layout_parent = Control.new()
	root.add_child(wall_layout_parent)
	check(scene.WALL_LAYOUTS.size() == 4 and int(scene.WALL_LAYOUTS[0][2]) == 16 and int(scene.WALL_LAYOUTS[2][2]) == 12, "wall layout reuses fixed geometry constants")
	scene.draw_walls(wall_layout_parent)
	check(wall_layout_parent.get_child_count() == scene.WALL_LAYOUTS.size() and count_descendants(wall_layout_parent) == scene.WALL_LAYOUTS.size(), "wall layout uses four self-drawing strips instead of per-tile nodes")
	check(count_texture_rects(wall_layout_parent) == 0, "wall layout uses self-drawn backs without per-tile textures")
	var horizontal_strip_count := 0
	var vertical_strip_count := 0
	for strip in wall_layout_parent.get_children():
		if bool(strip.get("horizontal")) and int(strip.get("tile_count")) == 16:
			horizontal_strip_count += 1
		if not bool(strip.get("horizontal")) and int(strip.get("tile_count")) == 12:
			vertical_strip_count += 1
	check(horizontal_strip_count == 2 and vertical_strip_count == 2 and wall_layout_parent.find_child("WallBackStrip_h_16", true, false) != null and wall_layout_parent.find_child("WallBackStrip_v_12", true, false) != null, "wall layout names horizontal and vertical illustrated strips")
	var horizontal_wall_strip = wall_layout_parent.find_child("WallBackStrip_h_16", true, false)
	var vertical_wall_strip = wall_layout_parent.find_child("WallBackStrip_v_12", true, false)
	check(horizontal_wall_strip != null and bool(horizontal_wall_strip.get("horizontal")) and int(horizontal_wall_strip.get("tile_count")) == 16, "horizontal wall strip keeps self-drawn tile metadata")
	check(vertical_wall_strip != null and not bool(vertical_wall_strip.get("horizontal")) and int(vertical_wall_strip.get("tile_count")) == 12, "vertical wall strip keeps self-drawn tile metadata")
	check(horizontal_wall_strip != null and horizontal_wall_strip.get("rail_color") is Color and horizontal_wall_strip.get("endpoint_color") is Color and horizontal_wall_strip.get("rhythm_color") is Color, "wall strips expose rail endpoint and rhythm illustration colors")
	check(horizontal_wall_strip != null and horizontal_wall_strip.get("flow_color") is Color and horizontal_wall_strip.get("break_color") is Color and horizontal_wall_strip.get("count_mark_color") is Color, "wall strips expose flow break and count-mark illustration colors")
	wall_layout_parent.queue_free()
	check(scene.DISCARD_ZONES.size() == 4 and int(scene.DISCARD_ZONES[0][0]) == 0 and int(scene.DISCARD_ZONES[0][2]) == 10, "discard layout reuses fixed geometry constants")
	scene.last_discard = "5W"
	scene.last_discard_seat = 0
	scene.players[0]["discards"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "1T", "2T", "3T", "4T", "5T", "5W"]
	for i in range(24):
		scene.players[0]["discards"].append("5W")
	var last_discard_marker_rect = scene.last_discard_focus_marker_rect_for_seat(0)
	check(last_discard_marker_rect.position.x >= scene.DISCARD_ZONES[0][1].position.x and last_discard_marker_rect.size.x <= scene.DISCARD_ZONES[0][1].size.x and last_discard_marker_rect.position.y >= scene.DISCARD_ZONES[0][1].position.y, "last discard focus marker stays inside the discard zone")
	var last_discard_parent = Control.new()
	root.add_child(last_discard_parent)
	scene.draw_discards(last_discard_parent)
	check(count_nodes_with_name_prefix(last_discard_parent, "DiscardRiverArt_") == 4 and last_discard_parent.find_child("DiscardRiverSeatRail_0", true, false) != null, "discard river renders illustrated zones for every seat")
	check(last_discard_parent.find_child("DiscardRiverLastSource_0", true, false) != null and last_discard_parent.find_child("DiscardRiverOverflow_0", true, false) != null, "discard river highlights latest source and overflow window")
	check(last_discard_parent.find_child("DiscardRiverOverflowRoute_0", true, false) != null and last_discard_parent.find_child("DiscardRiverOverflowFill_0", true, false) != null and last_discard_parent.find_child("DiscardRiverOverflowGate_0", true, false) != null and count_nodes_with_name_prefix(last_discard_parent, "DiscardRiverOverflowTick_0_") == 2, "discard river renders overflow-to-visible-window route")
	check(count_nodes_with_name_prefix(last_discard_parent, "DiscardRiverWindowBead_0_") >= 3, "discard river renders visible-window beads for active river")
	check(count_nodes_with_name_prefix(last_discard_parent, "DiscardRiverWindowFill_") == 4 and count_nodes_with_name_prefix(last_discard_parent, "DiscardRiverWindowGate_") == 4 and count_nodes_with_name_prefix(last_discard_parent, "DiscardRiverWindowTick_") == 8, "discard river renders visible-window progress fills gates and ticks")
	var discard_window_fill = last_discard_parent.find_child("DiscardRiverWindowFill_0", true, false) as Control
	check(discard_window_fill != null and discard_window_fill.anchor_right > 0.95, "discard river window fill tracks the visible range end for long rivers")
	check(last_discard_parent.find_child("LastDiscardFocusMarker", true, false) != null and last_discard_parent.find_child("LastDiscardFocusBadge", true, false) != null, "discard river renders a focus marker for the latest discard")
	check(last_discard_parent.find_child("DiscardRiverWashTexture_0", true, false) != null and last_discard_parent.find_child("LastDiscardAuraTexture", true, false) != null, "discard river renders reusable wash and focus-aura PNG textures")
	check(last_discard_parent.find_child("LastDiscardFocusRoute", true, false) != null and last_discard_parent.find_child("LastDiscardFocusRouteFill", true, false) != null and last_discard_parent.find_child("LastDiscardFocusSourceDot", true, false) != null, "last discard focus marker renders source route art")
	check(count_nodes_with_name_prefix(last_discard_parent, "LastDiscardFocusRipple_") == 3, "last discard focus marker renders ripple rings")
	check(has_label_text(last_discard_parent, "东家 刚打 5万"), "discard focus marker names the source seat and tile")
	last_discard_parent.queue_free()
	check(scene.TABLE_OUTER_RECT == scene.rect_full(0.145, 0.108, 0.855, 0.765) and scene.TABLE_INNER_RECT == scene.rect_full(0.045, 0.055, 0.955, 0.945), "main table panel layout reuses fixed geometry constants")
	check(scene.TABLE_OUTER_TEXTURE_RECT == scene.rect_full(0.008, 0.012, 0.992, 0.988) and scene.TABLE_INNER_TEXTURE_RECT == scene.rect_full(0.012, 0.016, 0.988, 0.984), "main table texture layout reuses fixed geometry constants")
	check(scene.SEAT_LAYOUTS.size() == 4 and int(scene.SEAT_LAYOUTS[0][0]) == 2 and str(scene.SEAT_LAYOUTS[3][2]) == "bottom", "seat layout reuses fixed geometry constants")
	check(scene.CENTER_WIND_LABELS == ["东", "南", "西", "北"], "center wind labels reuse fixed order constants")
	check(scene.CENTER_WIND_RECTS.size() == 4, "center wind label rects reuse fixed layout constants")
	check(scene.CENTER_DICE_DOT_POINTS.size() == 4 and scene.CENTER_DICE_DOT_POINTS[0] == Vector2(0.35, 0.32), "center dice dots reuse fixed layout constants")
	check(scene.CENTER_DICE_DOT_RECTS.size() == 4 and scene.CENTER_DICE_DOT_RECTS[0] == scene.rect_full(0.332, 0.302, 0.368, 0.338), "center dice dots reuse precomputed anchor rects")
	var bottom_discard_zone = scene.rect_full(0.285, 0.585, 0.715, 0.825)
	var discard_table_size = scene.game_table_pixel_size()
	check(scene.discard_zone_pixel_size_for_table_size(bottom_discard_zone, discard_table_size) == scene.discard_zone_pixel_size(bottom_discard_zone), "discard zone pixel sizing can reuse cached table size")
	var bottom_discard_rows = scene.discard_zone_visible_rows(bottom_discard_zone, 10)
	check(scene.discard_zone_visible_rows_for_table_size(bottom_discard_zone, 10, discard_table_size) == bottom_discard_rows, "discard row sizing can reuse cached table size")
	var bottom_discard_tile_size = scene.discard_zone_tile_size(bottom_discard_zone, 10, bottom_discard_rows)
	check(scene.discard_zone_tile_size_for_table_size(bottom_discard_zone, 10, bottom_discard_rows, discard_table_size) == bottom_discard_tile_size, "discard tile sizing can reuse cached table size")
	check(scene.discard_grid_fits_zone(bottom_discard_zone, 10, bottom_discard_rows, bottom_discard_tile_size), "bottom discard grid sizes tiles to stay inside table zone")
	check(scene.discard_grid_fits_zone_for_table_size(bottom_discard_zone, 10, bottom_discard_rows, bottom_discard_tile_size, discard_table_size), "discard grid fit checks can reuse cached table size")
	check(bottom_discard_tile_size.x < scene.DISCARD_TILE_MAX_SIZE.x and bottom_discard_tile_size.y < scene.DISCARD_TILE_MAX_SIZE.y, "bottom discard grid shrinks compact tiles instead of overflowing")
	var side_discard_zone = scene.rect_full(0.135, 0.315, 0.300, 0.705)
	var side_discard_rows = scene.discard_zone_visible_rows(side_discard_zone, 4)
	var side_discard_tile_size = scene.discard_zone_tile_size(side_discard_zone, 4, side_discard_rows)
	check(scene.discard_grid_fits_zone(side_discard_zone, 4, side_discard_rows, side_discard_tile_size), "side discard grid sizes tiles to stay inside table zone")
	var center_parent = Control.new()
	root.add_child(center_parent)
	scene.last_discard = "5W"
	scene.last_discard_seat = 0
	scene.draw_center(center_parent)
	for wind_label in scene.CENTER_WIND_LABELS:
		check(has_label_text(center_parent, wind_label), "center renders fixed wind label %s" % wind_label)
	check(center_parent.find_child("CenterPulseNetwork", true, false) != null and center_parent.find_child("CenterPulseNetworkRoute", true, false) != null and center_parent.find_child("CenterPulseNetworkFill", true, false) != null and center_parent.find_child("CenterPulseNetworkGate", true, false) != null, "center renders pulse network route")
	check(center_parent.find_child("CenterPulseNetworkVerticalRoute", true, false) != null and center_parent.find_child("CenterPulseNetworkVerticalFill", true, false) != null and count_nodes_with_name_prefix(center_parent, "CenterPulseNetworkNode_") == 4, "center pulse network links phase wind wall and last tile nodes")
	check(count_nodes_with_name_prefix(center_parent, "CenterPulseNetworkTick_") == 4 and count_nodes_with_name_prefix(center_parent, "CenterPulseNetworkPulse_") == 3, "center pulse network renders rhythm ticks and vertical pulses")
	check(center_parent.find_child("CenterLastTileTrace", true, false) != null and center_parent.find_child("CenterLastTileRoute", true, false) != null and center_parent.find_child("CenterLastTileFill", true, false) != null and center_parent.find_child("CenterLastTileResponseGate", true, false) != null, "center last tile renders response route")
	check(center_parent.find_child("CenterLastTileSourceNode", true, false) != null and count_nodes_with_name_prefix(center_parent, "CenterLastTileTick_") == 3, "center last tile renders source node and rhythm ticks")
	check(center_parent.find_child("CenterLastTileTargetNode", true, false) != null and center_parent.find_child("CenterLastTileClaimRoute", true, false) != null and center_parent.find_child("CenterLastTileClaimFill", true, false) != null and center_parent.find_child("CenterLastTileClaimGate", true, false) != null, "center last tile renders claim-window route and target node")
	check(count_nodes_with_name_prefix(center_parent, "CenterLastTileClaimTick_") == 2, "center last tile renders claim-window rhythm ticks")
	check(center_parent.find_child("CenterDicePlate", true, false) != null and center_parent.find_child("CenterDicePlateBack", true, false) != null and center_parent.find_child("CenterDiceOrbit", true, false) != null and center_parent.find_child("CenterDiceFocus", true, false) != null, "center renders dice plate illustration")
	check(count_nodes_with_name_prefix(center_parent, "CenterDiceDot") == scene.CENTER_DICE_DOT_RECTS.size() and count_nodes_with_name_prefix(center_parent, "CenterDiceSpark_") == 4, "center dice plate renders dots and spark accents")
	check(center_parent.find_child("CenterDiceTurnRoute", true, false) != null and center_parent.find_child("CenterDiceTurnFill", true, false) != null and center_parent.find_child("CenterDiceTurnGate", true, false) != null and count_nodes_with_name_prefix(center_parent, "CenterDiceTurnTick_") == 2, "center dice plate renders current-turn route")
	check(center_parent.find_child("CenterDiceOutcomeRoute", true, false) != null and center_parent.find_child("CenterDiceOutcomeFill", true, false) != null and center_parent.find_child("CenterDiceOutcomeGate", true, false) != null and count_nodes_with_name_prefix(center_parent, "CenterDiceOutcomeTick_") == 3, "center dice plate renders outcome confirmation route")
	check(count_panel_shadow_size(center_parent, 0) >= 5, "center inner panel and dice dots skip shadows for cheaper redraws")
	center_parent.queue_free()
	scene.players[1]["name"] = "超长在线昵称十二字测试"
	scene.players[1]["discards"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W"]
	scene.players[1]["flowers"] = 5
	scene.players[1]["flower_tiles"] = ["H1", "H2", "H3", "H4", "H5"]
	var clipped_seat_parent = Control.new()
	root.add_child(clipped_seat_parent)
	scene.draw_seat(clipped_seat_parent, 1, scene.rect_full(0.0, 0.0, 1.0, 1.0), "right")
	check(clipped_seat_parent.find_child("SeatBrocadeTexture_1", true, false) != null, "seat panel renders reusable brocade PNG texture")
	check(label_is_clipped(first_label_with_text_prefix(clipped_seat_parent, "超长在线昵称")), "seat name clips long names without wrapping over badges")
	check(label_is_clipped(first_label_containing_text(clipped_seat_parent, "手")) and label_is_clipped(first_label_containing_text(clipped_seat_parent, "花")) and label_is_clipped(first_label_containing_text(clipped_seat_parent, "分")), "seat stats render as clipped compact pills")
	check(clipped_seat_parent.find_child("SeatStatPill_手", true, false) != null and clipped_seat_parent.find_child("SeatStatPill_花", true, false) != null and clipped_seat_parent.find_child("SeatStatPill_分", true, false) != null, "seat stat pills render named illustrated containers")
	check(clipped_seat_parent.find_child("SeatStatMeter_手", true, false) != null and clipped_seat_parent.find_child("SeatStatMeterFill_手", true, false) != null and clipped_seat_parent.find_child("SeatStatMeter_花", true, false) != null and clipped_seat_parent.find_child("SeatStatMeterFill_花", true, false) != null and clipped_seat_parent.find_child("SeatStatMeter_分", true, false) != null and clipped_seat_parent.find_child("SeatStatMeterFill_分", true, false) != null and count_nodes_with_name_prefix(clipped_seat_parent, "SeatStatMeterDot_") == 6, "seat stat pills render compact meters and status dots")
	check(count_nodes_with_name_prefix(clipped_seat_parent, "SeatStatMeterGate_") == 3 and count_nodes_with_name_prefix(clipped_seat_parent, "SeatStatMeterTick_") == 6, "seat stat pills render meter gates and rhythm ticks")
	check(clipped_seat_parent.find_child("SeatStatValueRoute_手", true, false) != null and clipped_seat_parent.find_child("SeatStatValueFill_手", true, false) != null and clipped_seat_parent.find_child("SeatStatValueRoute_花", true, false) != null and clipped_seat_parent.find_child("SeatStatValueFill_花", true, false) != null and clipped_seat_parent.find_child("SeatStatValueRoute_分", true, false) != null and clipped_seat_parent.find_child("SeatStatValueFill_分", true, false) != null, "seat stat pills connect values to compact route fills")
	check(count_nodes_with_name_prefix(clipped_seat_parent, "SeatStatValueGate_") == 3 and count_nodes_with_name_prefix(clipped_seat_parent, "SeatStatValueTick_") == 6, "seat stat pills render value gates and rhythm ticks")
	check(clipped_seat_parent.find_child("SeatFlowerTileArt", true, false) != null and clipped_seat_parent.find_child("SeatFlowerTileRail", true, false) != null and clipped_seat_parent.find_child("SeatFlowerTileSeal", true, false) != null, "seat flower tiles render illustrated collection block")
	check(clipped_seat_parent.find_child("SeatFlowerTileGlow", true, false) != null and count_nodes_with_name_prefix(clipped_seat_parent, "SeatFlowerTile_") == 4 and clipped_seat_parent.find_child("SeatFlowerMoreBadge", true, false) != null, "seat flower tile art renders visible flowers, glow, and overflow badge")
	check(clipped_seat_parent.find_child("SeatFlowerCollectionRoute", true, false) != null and clipped_seat_parent.find_child("SeatFlowerCollectionRouteFill", true, false) != null and clipped_seat_parent.find_child("SeatFlowerCollectionGate", true, false) != null, "seat flower tile art renders collection route")
	check(count_nodes_with_name_prefix(clipped_seat_parent, "SeatFlowerCollectionTick_") == 3, "seat flower tile art renders collection rhythm ticks")
	check(label_is_clipped(first_label_containing_text(clipped_seat_parent, "1万")), "seat discard preview clips recent river text")
	check(clipped_seat_parent.find_child("SeatDiscardPreviewArt_1", true, false) != null and clipped_seat_parent.find_child("SeatDiscardPreviewRail_1", true, false) != null and clipped_seat_parent.find_child("SeatDiscardPreviewFill_1", true, false) != null and clipped_seat_parent.find_child("SeatDiscardPreviewGate_1", true, false) != null, "seat discard preview renders illustrated river rail")
	check(count_nodes_with_name_prefix(clipped_seat_parent, "SeatDiscardPreviewTile_1_") == 3 and clipped_seat_parent.find_child("SeatDiscardPreviewOverflow_1", true, false) != null and count_nodes_with_name_prefix(clipped_seat_parent, "SeatDiscardPreviewTick_1_") == 3, "seat discard preview renders recent tiles overflow and rhythm ticks")
	clipped_seat_parent.queue_free()
	var log_parent = Control.new()
	root.add_child(log_parent)
	scene.table_logs.clear()
	scene.table_logs.append("这是一条很长的补花和包赔牌谱记录一")
	scene.table_logs.append("这是一条很长的补花和包赔牌谱记录二")
	scene.table_logs.append("这是一条很长的补花和包赔牌谱记录三")
	scene.table_logs.append("这是一条很长的补花和包赔牌谱记录四")
	scene.draw_table_log(log_parent)
	check(log_parent.find_child("TableLogScrollTexture", true, false) != null, "table log renders reusable scroll PNG texture")
	check(label_is_clipped(first_label_containing_text(log_parent, "补花")), "table log clips long rows inside compact panel")
	check(count_label_nodes(log_parent) == 8, "table log renders title, count, and three structured action rows")
	check(count_labels_with_exact_text(log_parent, "摸") == 3, "table log tags recent draw and flower events")
	check(log_parent.find_child("TableLogTimelineRail", true, false) != null and count_named_nodes(log_parent, "TableLogTimelineNode") == 3 and count_named_nodes(log_parent, "TableLogTimelineConnector") == 3, "table log renders a non-text timeline rail and row nodes")
	check(log_parent.find_child("TableLogTimelineFlow", true, false) != null and count_named_nodes(log_parent, "TableLogEventLane") == 3 and count_nodes_with_name_prefix(log_parent, "TableLogEventPulse_") == 6, "table log renders event flow lanes and pulses without extra text")
	check(count_named_nodes(log_parent, "TableLogTagRoute") == 3 and count_named_nodes(log_parent, "TableLogTagRouteFill") == 3 and count_named_nodes(log_parent, "TableLogTagRouteGate") == 3, "table log rows render tag connection routes")
	check(count_nodes_with_name_prefix(log_parent, "TableLogTagRouteTick_") == 6, "table log rows render tag route rhythm ticks")
	check(log_parent.find_child("TableLogLatestGlow", true, false) != null and log_parent.find_child("TableLogLatestCursor", true, false) != null, "table log highlights the latest visible action with glow and cursor")
	check(has_label_text(log_parent, "4条"), "table log shows total event count")
	log_parent.queue_free()
	var empty_log_parent = Control.new()
	root.add_child(empty_log_parent)
	scene.table_logs.clear()
	scene.draw_table_log(empty_log_parent)
	check(empty_log_parent.find_child("TableLogEmptyArt", true, false) != null and empty_log_parent.find_child("TableLogEmptyRail", true, false) != null and count_nodes_with_name_prefix(empty_log_parent, "TableLogEmptyBead_") == 3, "empty table log renders waiting-state illustration")
	check(has_label_text(empty_log_parent, "等待开局"), "empty table log keeps waiting-state text visible")
	empty_log_parent.queue_free()
	scene.players[0]["flower_tiles"] = ["H1", "H2"]
	var flower_strip_parent = Control.new()
	root.add_child(flower_strip_parent)
	check(scene.draw_seat_flower_tiles(flower_strip_parent, 0), "seat panel renders flower tile strip")
	check(count_texture_rects(flower_strip_parent) >= 2 and not has_label_text(flower_strip_parent, "春") and not has_label_text(flower_strip_parent, "夏"), "flower strip uses real tile art without duplicate text")
	check(flower_strip_parent.find_child("SeatFlowerCollectionFill", true, false) != null and flower_strip_parent.find_child("SeatFlowerCollectionRouteFill", true, false) != null, "flower strip renders collection progress fills")
	var flower_route_fill = flower_strip_parent.find_child("SeatFlowerCollectionRouteFill", true, false) as Control
	check(flower_route_fill != null and flower_route_fill.anchor_right > 0.50 and flower_route_fill.anchor_right < 0.60, "flower collection route fill tracks visible flower count")
	flower_strip_parent.queue_free()
	check(scene.flower_bloom_text("H1") == "补花春", "flower bloom animation label names the replacement flower")

	scene.players[0]["hand"] = []
	scene.players[0]["flowers"] = 0
	scene.players[0]["flower_tiles"] = []
	scene.wall.clear()
	scene.wall.append("5W")
	scene.wall.append("H1")
	var drawn = scene.draw_tile_for(0, false)
	check(drawn == "5W", "flower draw supplements to a normal tile")
	check(int(scene.players[0]["flowers"]) == 1, "flower count increases")
	check(scene.players[0]["hand"].size() == 1 and scene.players[0]["hand"][0] == "5W", "flower tile is not kept in hand")
	scene.players[0]["hand"] = []
	scene.players[0]["flowers"] = 0
	scene.players[0]["flower_tiles"] = []
	scene.wall.clear()
	scene.wall.append("6W")
	scene.wall.append("H2")
	var flower_fx_drawn = scene.draw_tile_for(0, true)
	check(scene.find_child("FlowerBloomShadowTexture", true, false) != null, "flower bloom animation renders reusable blossom shadow PNG texture")
	check(flower_fx_drawn == "6W" and scene.find_child("FlowerBloomFx", true, false) != null and scene.find_child("FlowerBloomTile", true, false) != null, "announced flower replacement creates a bloom animation with tile art")
	check(scene.find_child("FlowerBloomReplacementRoute", true, false) != null and scene.find_child("FlowerBloomReplacementFill", true, false) != null and scene.find_child("FlowerBloomReplacementGate", true, false) != null, "flower bloom animation renders replacement route")
	check(count_nodes_with_name_prefix(scene, "FlowerBloomReplacementTick_") == 3, "flower bloom animation renders replacement rhythm ticks")
	await process_frame
	await process_frame

	scene.players[0]["hand"] = [
		"1W", "1W", "1W",
		"2W", "3W", "4W",
		"5W", "6W", "7W",
		"2T", "3T", "4T",
		"E", "E",
	]
	scene.players[0]["melds"] = []
	check(scene.can_win_for_seat(0), "standard winning hand is detected")
	check(scene.calculate_min_shanten(winning_hand(), 0) == -1, "winning hand shanten is -1")
	check(scene.calculate_min_shanten(tenpai_hand(), 0) == 0, "tenpai hand shanten is zero")
	check(scene.effective_tile_count(tenpai_hand(), 0, 0) >= 3, "tenpai hand has winning tiles")
	scene.players[0]["hand"] = seven_pairs_hand()
	scene.players[0]["melds"] = []
	check(scene.can_win_for_seat(0), "seven pairs winning hand is detected")
	check(scene.calculate_min_shanten(seven_pairs_hand(), 0) == -1, "seven pairs shanten is complete")
	var seven_pairs_score = scene.calculate_win_score(0, "", false)
	check(seven_pairs_score.get("reasons", []).has("七对"), "seven pairs is scored")
	scene.players[0]["hand"] = thirteen_orphans_hand()
	scene.players[0]["melds"] = []
	check(scene.can_win_for_seat(0), "thirteen orphans winning hand is detected")
	check(scene.calculate_min_shanten(thirteen_orphans_hand(), 0) == -1, "thirteen orphans shanten is complete")
	var thirteen_score = scene.calculate_win_score(0, "", false)
	check(thirteen_score.get("reasons", []).has("十三幺"), "thirteen orphans is scored")
	scene.players[0]["hand"] = thirteen_orphans_unique_tenpai()
	check(scene.calculate_min_shanten(scene.players[0]["hand"], 0) == 0, "thirteen unique orphans are waiting for any pair")
	check(scene.effective_tile_variety(scene.players[0]["hand"], 0, 0) == scene.THIRTEEN_ORPHANS_CODES.size(), "thirteen unique orphans wait on every orphan tile")
	scene.players[0]["hand"] = thirteen_orphans_missing_pair_tenpai()
	var missing_metrics = scene.effective_tile_metrics(scene.players[0]["hand"], 0, 0)
	var missing_tiles: Array = missing_metrics.get("tiles", [])
	check(scene.calculate_min_shanten(scene.players[0]["hand"], 0) == 0, "paired twelve orphans wait on the missing orphan")
	check(missing_tiles.size() == 1 and str(missing_tiles[0]) == "P", "missing orphan wait is identified")
	scene.players[0]["hand"] = thirteen_orphans_route_hand()
	scene.players[0]["melds"] = []
	check(str(scene.hand_plan_report_for_seat(0, scene.players[0]["hand"]).get("label", "")) == "十三幺", "AI report identifies thirteen orphans route")
	check(scene.choose_ai_discard_for_seat(0) == "2W", "AI preserves thirteen orphans route by cutting off-route tile")
	scene.players[0]["melds"] = [["E", "E", "E"]]
	check(str(scene.hand_plan_report_for_seat(0, scene.players[0]["hand"]).get("label", "")) != "十三幺", "open meld cannot keep thirteen orphans route")
	scene.players[0]["melds"] = []
	scene.clear_shanten_cache()
	var cached_shanten = scene.calculate_min_shanten(tenpai_hand(), 0)
	var shanten_hits_before = scene.shanten_cache_hits
	check(scene.calculate_min_shanten(tenpai_hand(), 0) == cached_shanten and scene.shanten_cache_hits > shanten_hits_before, "shanten cache reuses repeated hand state")

	scene.players[0]["hand"] = [
		"1W", "1W", "2W", "2W", "3W", "3W", "4W",
		"4W", "5T", "5T", "6T", "6T", "P",
	]
	var win_claim_counts = scene.tile_counts(scene.players[0]["hand"])
	check(scene.get_claim_options(0, 1, "P").has("hu"), "discard win option is offered")
	check(scene.can_win_for_seat_from_counts(0, win_claim_counts, "P") and scene.get_claim_options(0, 1, "P", win_claim_counts).has("hu"), "discard win option can reuse hand count snapshot")

	scene.players[0]["hand"] = ["2W", "3W", "5T", "5T", "5T", "E", "S", "N", "R", "Z", "F", "P", "9B"]
	var chi_option_counts = scene.tile_counts(scene.players[0]["hand"])
	var options = scene.get_claim_options(0, 3, "4W")
	check(options.has("chi"), "next seat chi option is offered")
	check(scene.get_claim_options(0, 3, "4W", chi_option_counts) == options, "claim options reuse hand counts without changing offered actions")
	scene.players[0]["hand"] = ["1W", "2W", "2W", "4W", "4W", "5W", "5T", "6T", "7T", "E", "E", "P", "P"]
	var chi_choice_counts = scene.tile_counts(scene.players[0]["hand"])
	var chi_choice_counts_before_generation = chi_choice_counts.duplicate()
	var chi_choices = scene.get_chi_choices(scene.players[0]["hand"], "3W")
	var counted_chi_choices = scene.get_chi_choices_from_counts(chi_choice_counts, "3W")
	check(chi_choices.size() == 3, "multiple chi choices are exposed")
	check(counted_chi_choices.size() == chi_choices.size() and scene.same_tile_list(counted_chi_choices[1].get("needed", []), chi_choices[1].get("needed", [])), "chi choices can be generated from hand count snapshot")
	check(chi_choice_counts == chi_choice_counts_before_generation and scene.same_tile_list(counted_chi_choices[0].get("needed", []), ["4W", "5W"]) and scene.same_tile_list(counted_chi_choices[0].get("meld", []), ["3W", "4W", "5W"]), "chi choices use direct index checks without mutating count snapshots")
	check(scene.has_tile_list_counts(chi_choice_counts, counted_chi_choices[2].get("needed", [])), "chi count snapshot checks required tiles without rescanning the hand")
	var missing_pair_counts = scene.tile_counts(["4W"])
	var missing_pair_counts_before = missing_pair_counts.duplicate()
	check(not scene.consume_tile_list_counts(missing_pair_counts, ["4W", "5W"]) and missing_pair_counts == missing_pair_counts_before, "two-tile count consumption fails atomically when a required tile is missing")
	var duplicate_pair_counts = scene.tile_counts(["5W", "5W", "7T"])
	var duplicate_pair_counts_before = duplicate_pair_counts.duplicate()
	check(scene.has_tile_list_counts(duplicate_pair_counts, ["5W", "5W"]) and scene.consume_tile_list_counts(duplicate_pair_counts, ["5W", "5W"]), "two-tile count helpers handle duplicate required tiles without a required dictionary")
	scene.restore_tile_list_counts(duplicate_pair_counts, ["5W", "5W"])
	check(duplicate_pair_counts == duplicate_pair_counts_before, "two-tile count restoration returns duplicate-pair counts to the original snapshot")
	check(scene.chi_choice_label(chi_choices[1]) == "吃234万", "chi choice label is compact")
	var chi_choice_counts_before = chi_choice_counts.duplicate()
	var best_chi_from_counts = scene.best_chi_choice_from_counts(chi_choice_counts, "3W")
	var best_chi_from_hand = scene.best_chi_choice(scene.players[0]["hand"], "3W")
	check(scene.same_tile_list(best_chi_from_counts.get("needed", []), best_chi_from_hand.get("needed", [])) and chi_choice_counts == chi_choice_counts_before, "best chi choice can score from counts without mutating snapshots")
	var copied_chi_choice = scene.duplicate_chi_choice(chi_choices[1])
	var copied_chi_needed: Array = copied_chi_choice.get("needed", [])
	var original_chi_needed: Array = chi_choices[1].get("needed", [])
	if not copied_chi_needed.is_empty():
		copied_chi_needed[0] = "ZZ"
	check(not original_chi_needed.is_empty() and str(original_chi_needed[0]) != "ZZ", "chi choice copies protect needed tile arrays without recursive deep copy")
	scene.offline_phase = "pending_claim"
	scene.players[3]["discards"] = ["3W"]
	scene.offline_pending_claim = {
		"from_seat": 3,
		"tile": "3W",
		"options": ["chi"],
		"chi_choices": chi_choices,
	}
	check(scene.claim_options_text(scene.offline_pending_claim).find("吃123万") >= 0, "claim summary lists concrete chi choices")
	var claim_hint = scene.human_claim_hint_text()
	check(claim_hint.find("建议") < 0 and claim_hint.find("吃") >= 0, "claim hint lists legal responses without AI advice")
	check(scene.pending_claim_source_badge_text(3) == "北家" and scene.pending_claim_focus_text().find("吃牌机会") >= 0, "pending claim illustration derives source badge and focus text")
	var pending_claim_parent = Control.new()
	root.add_child(pending_claim_parent)
	scene.draw_pending_claim_illustration(pending_claim_parent)
	check(pending_claim_parent.find_child("PendingClaimBannerTexture", true, false) != null, "pending claim illustration renders reusable response-banner PNG texture")
	check(pending_claim_parent.find_child("PendingClaimIllustration", true, false) != null and pending_claim_parent.find_child("PendingClaimSourceBadge", true, false) != null, "pending claim illustration renders source and tile panel")
	check(pending_claim_parent.find_child("PendingClaimOptionRail", true, false) != null and pending_claim_parent.find_child("PendingClaimOption_chi", true, false) != null and pending_claim_parent.find_child("PendingClaimPassChip", true, false) != null, "pending claim illustration renders action option rail")
	check(pending_claim_parent.find_child("PendingClaimPriorityArt", true, false) != null and pending_claim_parent.find_child("PendingClaimPriorityRail", true, false) != null and pending_claim_parent.find_child("PendingClaimPriorityFill", true, false) != null, "pending claim illustration renders priority meter")
	check(pending_claim_parent.find_child("PendingClaimPriorityNode_chi", true, false) != null and pending_claim_parent.find_child("PendingClaimPriorityPassNode", true, false) != null and count_nodes_with_name_prefix(pending_claim_parent, "PendingClaimPriorityTick_") == 3, "pending claim illustration renders priority nodes and rhythm ticks")
	check(pending_claim_parent.find_child("PendingClaimActionExitArt", true, false) != null and pending_claim_parent.find_child("PendingClaimActionExitRail", true, false) != null and pending_claim_parent.find_child("PendingClaimActionExitFill", true, false) != null and pending_claim_parent.find_child("PendingClaimActionExitGate", true, false) != null, "pending claim illustration renders action exit route")
	check(count_nodes_with_name_prefix(pending_claim_parent, "PendingClaimActionExitTick_") == 3, "pending claim illustration renders action exit rhythm ticks")
	check(pending_claim_parent.find_child("PendingClaimTimerArt", true, false) != null and pending_claim_parent.find_child("PendingClaimTimerRail", true, false) != null and pending_claim_parent.find_child("PendingClaimTimerFill", true, false) != null and pending_claim_parent.find_child("PendingClaimTimerGate", true, false) != null, "pending claim illustration renders response timer route")
	check(count_nodes_with_name_prefix(pending_claim_parent, "PendingClaimTimerTick_") == 4, "pending claim illustration renders response timer rhythm ticks")
	check(pending_claim_parent.find_child("PendingClaimFlowArt", true, false) != null and pending_claim_parent.find_child("PendingClaimFlowArrow", true, false) != null and pending_claim_parent.find_child("PendingClaimTileGlow", true, false) != null, "pending claim illustration renders source-to-tile flow and tile glow")
	check(pending_claim_parent.find_child("PendingClaimOptionSpark_0", true, false) != null, "pending claim illustration renders option spark accents")
	check(has_label_text(pending_claim_parent, "吃牌机会 · 选择顺子组合"), "pending claim illustration renders contextual focus copy")
	scene.draw_actions(pending_claim_parent)
	check(pending_claim_parent.find_child("ActionDockRibbonTexture", true, false) != null, "pending claim action dock renders reusable command-ribbon PNG texture")
	check(pending_claim_parent.find_child("ActionButtonDock", true, false) != null and pending_claim_parent.find_child("ActionIntentDock", true, false) != null, "pending claim actions render dock and intent rail")
	check(pending_claim_parent.find_child("ActionDockLeftTail", true, false) != null and pending_claim_parent.find_child("ActionDockRightTail", true, false) != null and count_nodes_with_name_prefix(pending_claim_parent, "ActionDockRhythmDot_") >= 2, "pending claim action dock renders scroll tails and rhythm dots")
	check(pending_claim_parent.find_child("ActionButtonArt", true, false) != null and pending_claim_parent.find_child("ActionButtonIconBack", true, false) != null and pending_claim_parent.find_child("ActionButtonSheen", true, false) != null, "action buttons render icon art and sheen accents")
	check(pending_claim_parent.find_child("ActionButtonRoleRail", true, false) != null and pending_claim_parent.find_child("ActionButtonEnergyDot_0", true, false) != null and pending_claim_parent.find_child("ActionButtonPrioritySeal", true, false) != null, "action buttons render role rail, energy dots, and priority seals")
	check(pending_claim_parent.find_child("ActionButtonCommandRoute", true, false) != null and pending_claim_parent.find_child("ActionButtonCommandFill", true, false) != null and pending_claim_parent.find_child("ActionButtonCommandNode", true, false) != null, "action buttons render command route in live action bar")
	check(pending_claim_parent.find_child("ActionButtonExecutionGate", true, false) != null and count_nodes_with_name_prefix(pending_claim_parent, "ActionButtonExecutionTick_") >= 3, "action buttons render execution gate feedback in live action bar")
	pending_claim_parent.queue_free()
	var claim_recommendation = scene.recommended_claim_report()
	check(claim_recommendation.is_empty(), "claim recommendation is disabled for the human player")
	var original_claim_hand = scene.players[0]["hand"].duplicate()
	var original_pending_claim = scene.offline_pending_claim.duplicate(true)
	scene.players[0]["hand"] = ["1W", "2W", "3W", "3W", "4W", "5W", "5T", "6T", "7T", "E", "E", "P", "P"]
	var shared_human_chi_choices = scene.get_chi_choices(scene.players[0]["hand"], "3W")
	scene.offline_pending_claim = {
		"from_seat": 3,
		"tile": "3W",
		"options": ["chi", "peng"],
		"chi_choices": shared_human_chi_choices,
	}
	var contextless_human_claims: Array = []
	for shared_choice in shared_human_chi_choices:
		var shared_choice_report = scene.build_ai_claim_report(0, "chi", "3W", shared_choice)
		shared_choice_report["label"] = scene.chi_choice_label(shared_choice)
		shared_choice_report["chi_choice"] = shared_choice
		contextless_human_claims.append(shared_choice_report)
	var contextless_peng_report = scene.build_ai_claim_report(0, "peng", "3W")
	contextless_peng_report["label"] = scene.claim_label("peng")
	contextless_human_claims.append(contextless_peng_report)
	contextless_human_claims.sort_custom(func(a, b):
		var score_a = scene.human_claim_report_score(a)
		var score_b = scene.human_claim_report_score(b)
		if is_equal_approx(score_a, score_b):
			return scene.claim_priority(str(a.get("claim", ""))) > scene.claim_priority(str(b.get("claim", "")))
		return score_a > score_b
	)
	var shared_human_claims = scene.human_claim_candidate_reports()
	var shared_human_claims_match = shared_human_claims.size() == contextless_human_claims.size()
	for i in range(min(shared_human_claims.size(), contextless_human_claims.size())):
		var shared_report: Dictionary = shared_human_claims[i]
		var contextless_report: Dictionary = contextless_human_claims[i]
		shared_human_claims_match = shared_human_claims_match and str(shared_report.get("claim", "")) == str(contextless_report.get("claim", ""))
		shared_human_claims_match = shared_human_claims_match and str(shared_report.get("label", "")) == str(contextless_report.get("label", ""))
		shared_human_claims_match = shared_human_claims_match and bool(shared_report.get("allow", false)) == bool(contextless_report.get("allow", false))
		shared_human_claims_match = shared_human_claims_match and str(shared_report.get("reason", "")) == str(contextless_report.get("reason", ""))
		shared_human_claims_match = shared_human_claims_match and scene.same_tile_list(shared_report.get("chi_choice", {}).get("needed", []), contextless_report.get("chi_choice", {}).get("needed", []))
	check(shared_human_claims_match, "human claim candidates reuse one shared claim context without changing recommendation order")
	scene.players[0]["hand"] = original_claim_hand
	scene.offline_pending_claim = original_pending_claim
	var claim_copy_source = scene.build_ai_claim_report(0, "chi", "3W", chi_choices[1])
	var copied_claim_report = scene.duplicate_claim_report(claim_copy_source)
	var copied_claim_choice: Dictionary = copied_claim_report.get("chi_choice", {})
	var copied_claim_needed: Array = copied_claim_choice.get("needed", [])
	if not copied_claim_needed.is_empty():
		copied_claim_needed[0] = "YY"
	check(scene.same_tile_list(claim_copy_source.get("chi_choice", {}).get("needed", []), chi_choices[1].get("needed", [])), "claim report copies protect nested chi choices without recursive deep copy")
	var claim_actions_parent = Control.new()
	root.add_child(claim_actions_parent)
	scene.draw_actions(claim_actions_parent)
	check(count_button_text_prefix(claim_actions_parent, "荐吃") == 0 and has_button_text(claim_actions_parent, "吃234万"), "claim action bar shows legal chi choices without recommendation badge")
	claim_actions_parent.queue_free()
	check(scene.hand_tray_text().find("建议") < 0, "hand tray does not show claim advice")
	scene.human_claim("chi", chi_choices[1])
	check(scene.offline_phase == "await_discard", "chosen chi returns to discard phase")
	check(scene.players[0]["melds"].size() > 0 and scene.same_tile_list(scene.players[0]["melds"].back(), ["2W", "3W", "4W"]), "chosen chi meld is applied")
	check(scene.count_tile(scene.players[0]["hand"], "1W") == 1 and scene.count_tile(scene.players[0]["hand"], "5W") == 1, "unchosen chi edge tiles stay in hand")
	check(scene.same_tile_list(scene.filter_claim_options_by_priority(["chi", "peng", "hu"], 3), ["peng", "hu"]), "claim priority filters lower actions")
	scene.start_offline(true)
	scene.offline_phase = "resolving"
	scene.players[0]["discards"] = ["3W"]
	scene.players[1]["hand"] = ["1W", "2W", "2W", "4W", "4W", "5W", "5T", "6T", "7T", "E", "E", "P", "P"]
	scene.players[1]["melds"] = []
	scene.players[2]["hand"] = []
	scene.players[2]["melds"] = []
	scene.players[3]["hand"] = []
	scene.players[3]["melds"] = []
	var ai_chi_choices = scene.get_chi_choices(scene.players[1]["hand"], "3W")
	var expected_ai_chi_choice: Dictionary = {}
	var expected_ai_chi_report: Dictionary = {}
	var expected_ai_chi_score = -1000000.0
	for choice in ai_chi_choices:
		var report = scene.build_ai_claim_report(1, "chi", "3W", choice)
		if not bool(report.get("allow", false)):
			continue
		var score = scene.ai_claim_action_score(report, 1)
		if expected_ai_chi_choice.is_empty() or score > expected_ai_chi_score or (is_equal_approx(score, expected_ai_chi_score) and scene.ai_chi_choice_tiebreak(report) > scene.ai_chi_choice_tiebreak(expected_ai_chi_report)):
			expected_ai_chi_choice = (choice as Dictionary).duplicate(true)
			expected_ai_chi_report = report
			expected_ai_chi_score = score
	check(not expected_ai_chi_choice.is_empty(), "AI has at least one allowed chi choice")
	var direct_ai_chi = scene.best_ai_chi_claim(1, "3W", 1)
	check(scene.same_tile_list(direct_ai_chi.get("chi_choice", {}).get("meld", []), expected_ai_chi_choice.get("meld", [])), "AI chi helper evaluates all chi choices")
	var chosen_ai_claim = scene.choose_ai_claim(0, "3W")
	check(str(chosen_ai_claim.get("claim", "")) == "chi", "AI chooses chi when the best chi response is allowed")
	check(scene.same_tile_list(chosen_ai_claim.get("chi_choice", {}).get("meld", []), expected_ai_chi_choice.get("meld", [])), "AI claim selection uses the highest-scoring chi choice")

	scene.start_offline(true)
	scene.offline_phase = "resolving"
	scene.players[0]["hand"] = ["1W", "2W", "5T", "6T", "7T", "E", "E", "P", "P", "4B", "5B", "6B", "9B"]
	scene.players[0]["melds"] = []
	scene.players[1]["hand"] = waits_for_3w_hand()
	scene.players[1]["melds"] = []
	scene.players[3]["discards"] = ["3W"]
	scene.resolve_after_discard(3, "3W")
	check(scene.offline_phase == "ended", "AI hu takes priority over human chi")
	check(scene.offline_last_winner == 1, "higher priority AI hu wins the discard")
	check(scene.players[0]["melds"].is_empty(), "human chi is not applied under hu priority")

	scene.start_offline(true)
	scene.offline_phase = "resolving"
	scene.players[0]["hand"] = waits_for_3w_hand()
	scene.players[0]["melds"] = []
	scene.players[1]["hand"] = waits_for_3w_hand()
	scene.players[1]["melds"] = []
	scene.players[3]["discards"] = ["3W"]
	scene.resolve_after_discard(3, "3W")
	check(scene.offline_phase == "pending_claim", "human hu is still offered against AI hu")
	check(scene.offline_pending_claim.get("options", []) == ["hu"], "only equal-priority human hu is offered")
	check(scene.human_claim_hint_text().find("建议") < 0 and scene.human_claim_hint_text().find("胡") >= 0, "human hu prompt avoids AI advice wording")
	scene.human_claim("pass")
	check(scene.offline_phase == "ended" and scene.offline_last_winner == 1, "AI hu resolves after human passes equal-priority response")

	scene.start_offline(true)
	scene.offline_phase = "await_discard"
	scene.current_seat = 0
	scene.offline_turn_needs_draw = false
	scene.players[0]["melds"] = [["5W", "5W", "5W"]]
	scene.players[0]["hand"] = ["5W", "1T", "2T", "3T", "4T", "5T", "6T", "7T", "8T", "9T", "E"]
	scene.wall.clear()
	scene.wall.append("7B")
	check(scene.first_added_gang_tile(0) == "5W", "human added gang tile is detected")
	scene.human_added_gang("5W")
	check(scene.players[0]["melds"][0].size() == 4, "added gang upgrades existing pung")
	check(scene.count_tile(scene.players[0]["hand"], "5W") == 0, "added gang removes fourth tile from hand")
	check(scene.players[0]["hand"].has("7B"), "added gang draws replacement tile")
	check(str(scene.offline_last_draw.get("source", "")) == "gang", "added gang replacement marks gang source")
	check(bool(scene.offline_last_draw.get("announce", false)) and int(scene.offline_last_draw.get("serial", -1)) == scene.fx_last_animated_draw_serial, "announced replacement draw is consumed by one hand-entry animation render")
	scene.players[1]["melds"] = [["E", "E", "E"]]
	scene.players[1]["hand"] = ["E", "1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W", "P"]
	check(scene.can_added_gang(1, "E"), "AI added gang is legal")
	check(scene.choose_ai_added_gang(1) == "E", "AI considers honor added gang")
	var value_added_gang = scene.build_ai_self_gang_report(1, "E", "added")
	check(bool(value_added_gang.get("allow", false)), "AI self-gang report allows valuable added gang")
	check(float(value_added_gang.get("score", 0.0)) > 0.0, "AI self-gang report scores valuable gang")
	scene.players[2]["hand"] = seven_pairs_concealed_gang_hand()
	scene.players[2]["melds"] = []
	var seven_pairs_concealed_gang = scene.build_ai_self_gang_report(2, "E", "concealed")
	check(not bool(seven_pairs_concealed_gang.get("allow", true)), "AI declines concealed gang that breaks seven pairs route")
	check(bool(seven_pairs_concealed_gang.get("declined_by_plan", false)), "AI self-gang report marks seven pairs route decline")
	check(str(seven_pairs_concealed_gang.get("reason", "")) == "保七对", "AI self-gang report names seven pairs protection")
	check(scene.choose_ai_concealed_gang(2) == "", "AI concealed gang helper preserves seven pairs route")

	scene.start_offline(true)
	scene.offline_phase = "await_discard"
	scene.current_seat = 0
	scene.offline_turn_needs_draw = false
	scene.players[0]["melds"] = [["3W", "3W", "3W"]]
	scene.players[0]["hand"] = ["3W", "1T", "2T", "3T", "4T", "5T", "6T", "7T", "8T", "9T", "E"]
	scene.players[1]["hand"] = waits_for_3w_hand()
	scene.players[1]["melds"] = []
	scene.human_added_gang("3W")
	check(scene.offline_phase == "ended", "AI can rob human added gang")
	check(scene.offline_last_winner == 1, "AI rob gang winner is recorded")
	check(scene.players[0]["melds"][0].size() == 3, "robbed added gang does not upgrade pung")
	check(scene.players[0]["hand"].has("3W"), "robbed added gang keeps fourth tile in hand")
	check(scene.round_summary.find("抢杠胡") >= 0, "rob gang score reason is shown")

	scene.start_offline(true)
	scene.offline_phase = "await_discard"
	scene.current_seat = 1
	scene.offline_turn_needs_draw = false
	scene.players[0]["hand"] = waits_for_3w_hand()
	scene.players[0]["melds"] = []
	scene.players[1]["melds"] = [["3W", "3W", "3W"]]
	scene.players[1]["hand"] = ["3W", "1T", "2T", "3T", "4T", "5T", "6T", "7T", "8T", "9T", "E"]
	var rob_risk_added_gang = scene.build_ai_self_gang_report(1, "3W", "added")
	check(not bool(rob_risk_added_gang.get("allow", true)), "AI self-gang report declines added gang that can be robbed")
	check(bool(rob_risk_added_gang.get("rob_risk", false)), "AI self-gang report marks rob-gang risk")
	check(str(rob_risk_added_gang.get("reason", "")) == "防抢杠", "AI self-gang report names rob-gang defense")
	check(scene.choose_ai_added_gang(1) == "", "AI added gang helper avoids known rob-gang loss")
	scene.perform_added_gang(1, "3W")
	check(scene.offline_phase == "pending_claim", "human can respond to AI added gang with rob win")
	check(bool(scene.offline_pending_claim.get("rob_gang", false)), "pending claim is marked as rob gang")
	check(scene.offline_pending_claim.get("options", []) == ["hu"], "rob gang only offers hu")
	check(scene.human_claim_hint_text().find("建议") < 0 and scene.human_claim_hint_text().find("胡") >= 0, "rob gang prompt avoids AI advice wording")
	scene.human_claim("hu")
	check(scene.offline_phase == "ended" and scene.offline_last_winner == 0, "human rob gang win resolves")

	scene.start_offline(true)
	scene.offline_phase = "await_discard"
	scene.current_seat = 1
	scene.offline_turn_needs_draw = false
	scene.players[0]["hand"] = waits_for_3w_hand()
	scene.players[0]["melds"] = []
	scene.players[1]["melds"] = [["3W", "3W", "3W"]]
	scene.players[1]["hand"] = ["3W", "1T", "2T", "3T", "4T", "5T", "6T", "7T", "8T", "9T", "E"]
	scene.wall.clear()
	scene.wall.append("7B")
	scene.perform_added_gang(1, "3W")
	scene.human_claim("pass")
	check(scene.offline_phase == "await_discard", "added gang continues after human passes rob gang")
	check(scene.players[1]["melds"][0].size() == 4, "passed rob gang upgrades pung")
	check(scene.players[1]["hand"].has("7B"), "passed rob gang draws replacement tile")

	scene.start_offline(true)
	var discard = scene.choose_ai_discard_for_seat(0)
	check(scene.players[0]["hand"].has(discard), "AI discard exists in hand")
	scene.players[0]["hand"] = ai_shape_hand()
	scene.players[0]["melds"] = []
	discard = scene.choose_ai_discard_for_seat(0)
	check(discard == "E", "AI discards isolated honor before breaking useful shape")
	scene.clear_ai_report_cache()
	var ai_reports = scene.get_ai_discard_reports(0)
	check(not ai_reports.is_empty(), "AI discard reports are produced")
	check(ai_reports.size() == unique_tile_count(scene.players[0]["hand"]), "AI discard reports evaluate duplicate tile candidates once")
	var report_hits_before = scene.ai_report_cache_hits
	var cached_ai_reports = scene.get_ai_discard_reports(0)
	check(not cached_ai_reports.is_empty() and scene.ai_report_cache_hits > report_hits_before and str(cached_ai_reports[0].get("tile", "")) == str(ai_reports[0].get("tile", "")), "AI report cache reuses identical table state")
	var report_misses_before = scene.ai_report_cache_misses
	scene.players[1]["discards"].append("9W")
	var changed_state_reports = scene.get_ai_discard_reports(0)
	check(scene.ai_report_cache_misses > report_misses_before and not changed_state_reports.is_empty(), "AI report cache key changes when visible table state changes")
	scene.players[1]["discards"].clear()
	check(str(ai_reports[0].get("tile", "")) == "E", "AI report keeps best discard first")
	check(int(ai_reports[0].get("ukeire", -1)) >= 0, "AI report includes effective tile count")
	check(int(ai_reports[0].get("variety", -1)) >= 0, "AI report includes effective tile variety")
	check(typeof(ai_reports[0].get("effective_remaining", {})) == TYPE_DICTIONARY, "AI report includes remaining effective tile counts")
	check(float(ai_reports[0].get("shape_quality", 0.0)) > 0.0 and str(ai_reports[0].get("shape_label", "")).find("形") >= 0, "AI report includes shape quality text")
	check(str(ai_reports[0].get("risk_label", "")) == scene.risk_label(float(ai_reports[0].get("risk", 0.0))), "AI report reuses the same risk label bucket in report fields and reasons")
	check(str(ai_reports[0].get("reason_label", "")) == "切孤张", "AI report labels isolated tile discard reason")
	var isolated_reason_counts = scene.tile_counts(scene.players[0]["hand"])
	check(scene.discard_reason_label("E", scene.players[0]["hand"], ai_reports[0]) == scene.discard_reason_label("E", [], ai_reports[0], isolated_reason_counts), "discard reason label can reuse original hand counts for isolated tile checks")
	check(str(scene.ai_discard_brief(ai_reports[0])).find("推荐打东") >= 0, "AI brief explains recommended discard")
	check(str(scene.ai_discard_brief(ai_reports[0])).find("形") >= 0, "AI brief includes shape quality")
	check(str(scene.ai_discard_brief(ai_reports[0])).find("切孤张") >= 0, "AI brief includes discard reason")
	var minimal_ai_brief = scene.ai_discard_brief({"tile": "E", "shanten": 1, "ukeire": 4, "variety": 2, "risk_label": "低"})
	check(minimal_ai_brief == "推荐打东 · 1向听 · 进张4/2 · 风险低", "AI brief joins only present optional fragments")
	var two_sided_quality = scene.hand_shape_quality_report(["3W", "4W", "5W", "6W", "2T", "4T", "1B", "9B", "E"])
	var edge_quality = scene.hand_shape_quality_report(["1W", "2W", "8W", "9W", "2T", "4T", "1B", "9B", "E"])
	check(float(two_sided_quality.get("score", 0.0)) > float(edge_quality.get("score", 0.0)), "two-sided shapes score higher than edge and gap shapes")
	check(scene.hand_shape_quality_text(two_sided_quality).find("两面") >= 0, "shape quality text names two-sided shapes")
	var flush_route_hand = ["1W", "1W", "2W", "2W", "3W", "3W", "4W", "4W", "5W", "5W", "6W", "7W", "8W", "9T"]
	scene.players[0]["hand"] = flush_route_hand.duplicate()
	scene.players[0]["melds"] = []
	for route_seat in range(4):
		scene.players[route_seat]["discards"] = []
		if route_seat != 0:
			scene.players[route_seat]["melds"] = []
	var flush_after_offsuit = flush_route_hand.duplicate()
	flush_after_offsuit.erase("9T")
	var flush_after_suit = flush_route_hand.duplicate()
	flush_after_suit.erase("5W")
	var flush_route_report = scene.build_ai_discard_report(0, "9T", flush_after_offsuit, 0)
	var broken_route_report = scene.build_ai_discard_report(0, "5W", flush_after_suit, 0)
	check(str(flush_route_report.get("plan_label", "")) == "清一色", "AI report identifies pure suit route")
	check(str(flush_route_report.get("reason_label", "")) == "保路线", "AI report labels route-preserving discard")
	check(float(flush_route_report.get("plan_bonus", 0.0)) > float(broken_route_report.get("plan_bonus", 0.0)), "AI route bonus favors discarding off-suit tile")
	check(scene.hand_plan_text(flush_route_report) == "路线清一色", "AI route text names pure suit route")
	check(scene.ai_discard_brief(flush_route_report).find("路线清一色") >= 0, "AI brief includes hand route")
	var dragon_route_hand = full_straight_route_hand()
	scene.players[0]["hand"] = dragon_route_hand.duplicate()
	scene.players[0]["melds"] = []
	var dragon_after_offroute = dragon_route_hand.duplicate()
	dragon_after_offroute.erase("E")
	var dragon_after_route_break = dragon_route_hand.duplicate()
	dragon_after_route_break.erase("5W")
	var dragon_route_report = scene.build_ai_discard_report(0, "E", dragon_after_offroute, 0)
	var broken_dragon_report = scene.build_ai_discard_report(0, "5W", dragon_after_route_break, 0)
	check(str(dragon_route_report.get("plan_label", "")) == "一条龙", "AI report identifies full straight route")
	check(str(dragon_route_report.get("reason_label", "")) == "保路线", "AI labels off-route discard for full straight")
	check(float(dragon_route_report.get("plan_bonus", 0.0)) > float(broken_dragon_report.get("plan_bonus", 0.0)), "AI route bonus favors preserving full straight ranks")
	check(scene.hand_plan_text(dragon_route_report) == "路线一条龙", "AI route text names full straight")
	var simples_route_hand = all_simples_route_hand()
	scene.players[0]["hand"] = simples_route_hand.duplicate()
	scene.players[0]["melds"] = []
	var simples_after_offroute = simples_route_hand.duplicate()
	simples_after_offroute.erase("E")
	var simples_after_route_break = simples_route_hand.duplicate()
	simples_after_route_break.erase("5W")
	var simples_route_report = scene.build_ai_discard_report(0, "E", simples_after_offroute, 0)
	var broken_simples_report = scene.build_ai_discard_report(0, "5W", simples_after_route_break, 0)
	check(str(simples_route_report.get("plan_label", "")) == "断幺九", "AI report identifies all-simples route")
	check(str(simples_route_report.get("reason_label", "")) == "保路线", "AI labels terminal/honor discard for all-simples route")
	check(float(simples_route_report.get("plan_bonus", 0.0)) > float(broken_simples_report.get("plan_bonus", 0.0)), "AI route bonus favors preserving simple tiles")
	check(scene.hand_plan_text(simples_route_report) == "路线断幺九", "AI route text names all-simples")
	var dragon_honor_route_hand = small_three_dragons_route_hand()
	scene.players[0]["hand"] = dragon_honor_route_hand.duplicate()
	scene.players[0]["melds"] = []
	var dragon_honor_after_offroute = dragon_honor_route_hand.duplicate()
	dragon_honor_after_offroute.erase("9B")
	var dragon_honor_after_route_break = dragon_honor_route_hand.duplicate()
	dragon_honor_after_route_break.erase("Z")
	var dragon_honor_route_report = scene.build_ai_discard_report(0, "9B", dragon_honor_after_offroute, 0)
	var broken_dragon_honor_report = scene.build_ai_discard_report(0, "Z", dragon_honor_after_route_break, 0)
	check(str(dragon_honor_route_report.get("plan_label", "")) == "小三元", "AI report identifies small three dragons route")
	check(str(dragon_honor_route_report.get("reason_label", "")) == "保路线", "AI labels non-dragon discard for dragon route")
	check(float(dragon_honor_route_report.get("plan_bonus", 0.0)) > float(broken_dragon_honor_report.get("plan_bonus", 0.0)), "AI route bonus favors preserving dragon groups")
	check(scene.hand_plan_text(dragon_honor_route_report) == "路线小三元", "AI route text names small three dragons")
	var seven_pairs_route_tiles = seven_pairs_route_hand()
	scene.players[0]["hand"] = seven_pairs_route_tiles.duplicate()
	scene.players[0]["melds"] = []
	var seven_pairs_after_single = seven_pairs_route_tiles.duplicate()
	seven_pairs_after_single.erase("8T")
	var seven_pairs_after_pair_break = seven_pairs_route_tiles.duplicate()
	seven_pairs_after_pair_break.erase("1W")
	var seven_pairs_route_report = scene.build_ai_discard_report(0, "8T", seven_pairs_after_single, 0)
	var broken_seven_pairs_report = scene.build_ai_discard_report(0, "1W", seven_pairs_after_pair_break, 0)
	check(str(seven_pairs_route_report.get("plan_label", "")) == "七对", "AI report identifies seven pairs route")
	check(str(seven_pairs_route_report.get("reason_label", "")) == "保路线", "AI labels singleton discard for seven pairs route")
	var seven_pairs_original = seven_pairs_after_single.duplicate()
	seven_pairs_original.append("8T")
	var seven_pairs_counts = scene.tile_counts(seven_pairs_original)
	check(scene.discard_reason_label("8T", seven_pairs_original, seven_pairs_route_report) == scene.discard_reason_label("8T", [], seven_pairs_route_report, seven_pairs_counts), "discard reason label can reuse original hand counts for seven pairs offcut checks")
	check(float(seven_pairs_route_report.get("plan_bonus", 0.0)) > float(broken_seven_pairs_report.get("plan_bonus", 0.0)), "AI route bonus favors preserving pairs")
	check(scene.hand_plan_text(seven_pairs_route_report) == "路线七对", "AI route text names seven pairs")
	check(["8T", "9B"].has(scene.choose_ai_discard_for_seat(0)), "AI preserves seven pairs route by cutting a singleton tile")
	scene.players[0]["melds"] = [["E", "E", "E"]]
	check(str(scene.hand_plan_report_for_seat(0, scene.players[0]["hand"]).get("label", "")) != "七对", "open meld cannot keep seven pairs route")
	scene.players[0]["melds"] = []
	check(scene.effective_tile_variety(tenpai_hand(), 0, 0) > 0, "tenpai hand reports effective tile variety")
	var tenpai_metrics = scene.effective_tile_metrics(tenpai_hand(), 0, 0, 0)
	check(tenpai_metrics.get("tiles", []).has("E"), "effective tile metrics include concrete wait tile")
	check(int(tenpai_metrics.get("remaining_by_tile", {}).get("E", 0)) > 0, "effective tile metrics include live count per wait tile")
	var checked_wait_metrics = scene.wait_value_metrics(0, tenpai_hand(), 0, 0, tenpai_metrics.get("tiles", []), tenpai_metrics.get("remaining_by_tile", {}))
	var reusable_wait_hand = tenpai_hand()
	var reusable_wait_size = reusable_wait_hand.size()
	var trusted_wait_metrics = scene.wait_value_metrics(0, tenpai_hand(), 0, 0, tenpai_metrics.get("tiles", []), tenpai_metrics.get("remaining_by_tile", {}), true)
	var reusable_wait_metrics = scene.wait_value_metrics(0, reusable_wait_hand, 0, 0, tenpai_metrics.get("tiles", []), tenpai_metrics.get("remaining_by_tile", {}), true)
	var snapshot_wait_metrics = scene.wait_value_metrics(0, tenpai_hand(), 0, 0, tenpai_metrics.get("tiles", []), tenpai_metrics.get("remaining_by_tile", {}), true, {}, scene.ai_total_attack_multiplier(0))
	var non_tenpai_wait_metrics = scene.wait_value_metrics(0, ai_shape_hand(), 0, 2, [], {})
	var empty_wait_metrics = scene.empty_wait_value_metrics()
	var isolated_empty_wait_metrics = scene.empty_wait_value_metrics()
	var empty_wait_self_discards: Array = empty_wait_metrics.get("self_discarded", [])
	empty_wait_self_discards.append("E")
	check(is_equal_approx(float(checked_wait_metrics.get("score", -1.0)), float(trusted_wait_metrics.get("score", -2.0))) and str(checked_wait_metrics.get("best_tile", "")) == str(trusted_wait_metrics.get("best_tile", "")), "wait value metrics can skip duplicate complete-hand checks for known winning waits")
	check(reusable_wait_hand.size() == reusable_wait_size and is_equal_approx(float(reusable_wait_metrics.get("score", -1.0)), float(trusted_wait_metrics.get("score", -2.0))), "wait value metrics reuses a temporary winning hand without mutating the source hand")
	check(is_equal_approx(float(snapshot_wait_metrics.get("score", -1.0)), float(trusted_wait_metrics.get("score", -2.0))), "wait value metrics can reuse precomputed attack multipliers")
	check(is_equal_approx(float(non_tenpai_wait_metrics.get("score", -1.0)), 0.0) and not non_tenpai_wait_metrics.has("attack_multiplier") and not non_tenpai_wait_metrics.has("wait_focus"), "non-tenpai wait value metrics skip wait weight calculations")
	check(is_equal_approx(float(empty_wait_metrics.get("score", -1.0)), 0.0) and str(empty_wait_metrics.get("best_tile", "x")) == "" and str(empty_wait_metrics.get("quality_text", "x")) == "" and isolated_empty_wait_metrics.get("self_discarded", []).is_empty(), "empty wait value metrics reuse a template with isolated self-discard arrays")
	var non_tenpai_report_hand = ["1W", "4W", "7W", "1T", "4T", "7T", "1B", "4B", "7B", "E", "S", "R", "N"]
	var non_tenpai_report = scene.build_ai_discard_report(0, "9B", non_tenpai_report_hand, 0)
	var non_tenpai_self_discards: Array = non_tenpai_report.get("wait_self_discarded", [])
	check(int(non_tenpai_report.get("shanten", 0)) > 0 and is_equal_approx(float(non_tenpai_report.get("wait_value", -1.0)), 0.0) and str(non_tenpai_report.get("wait_best_tile", "")) == "" and int(non_tenpai_report.get("wait_total_remaining", -1)) == 0 and non_tenpai_self_discards.is_empty(), "non-tenpai AI reports keep zero wait fields without building wait metrics")
	var lazy_wait_visible = scene.visible_tile_counts()
	var lazy_wait_context = scene.make_ai_evaluation_context(0, lazy_wait_visible)
	var lazy_wait_pressure = scene.ai_pressure_context(0, lazy_wait_context)
	scene.build_ai_discard_report(0, "9B", non_tenpai_report_hand, 0, lazy_wait_visible, lazy_wait_pressure, lazy_wait_context)
	check(not bool(lazy_wait_context.get("self_discard_lookup_ready", false)), "non-tenpai AI reports leave self-discard lookup unbuilt in shared contexts")
	var tenpai_report = {
		"tile": "P",
		"shanten": 0,
		"ukeire": tenpai_metrics.get("count", 0),
		"variety": tenpai_metrics.get("variety", 0),
		"effective_tiles": tenpai_metrics.get("tiles", []),
		"risk_label": "低",
	}
	check(scene.effective_tile_text(tenpai_report, 3) == "听东", "effective tile text names concrete wait")
	tenpai_report["effective_remaining"] = tenpai_metrics.get("remaining_by_tile", {})
	check(scene.effective_tile_text(tenpai_report, 3).find("东") >= 0 and scene.effective_tile_text(tenpai_report, 3).find("张") >= 0, "effective tile text shows live tile counts when available")
	check(scene.ai_discard_brief(tenpai_report).find("听东") >= 0, "AI brief includes concrete wait tile")
	check(scene.ai_discard_brief(tenpai_report).find("张") >= 0, "AI brief includes live wait count")
	scene.players[0]["melds"] = []
	scene.players[0]["flowers"] = 0
	for value_seat in range(4):
		scene.players[value_seat]["discards"] = []
		scene.players[value_seat]["melds"] = []
	var low_wait_report = scene.build_ai_discard_report(0, "P", tenpai_hand(), 0)
	check(float(low_wait_report.get("wait_value", 0.0)) > 0.0, "AI report scores tenpai wait value")
	check(str(low_wait_report.get("wait_best_tile", "")) == "E", "AI report names best wait tile")
	check(scene.wait_value_text(low_wait_report).find("价值东") >= 0, "AI report exposes wait value text")
	scene.players[0]["discards"] = ["E"]
	var lazy_self_discard_context = scene.make_ai_evaluation_context(0, scene.visible_tile_counts())
	var lazy_self_discard_pressure = scene.ai_pressure_context(0, lazy_self_discard_context)
	var self_discarded_wait_report = scene.build_ai_discard_report(0, "P", tenpai_hand(), 0)
	var lazy_self_discard_wait_report = scene.build_ai_discard_report(0, "P", tenpai_hand(), 0, scene.ai_context_visible_counts(lazy_self_discard_context), lazy_self_discard_pressure, lazy_self_discard_context)
	check(float(self_discarded_wait_report.get("wait_adjusted_remaining", 0.0)) < float(low_wait_report.get("wait_adjusted_remaining", 0.0)), "self-discarded wait has lower weighted live tiles")
	check(float(self_discarded_wait_report.get("wait_value", 0.0)) < float(low_wait_report.get("wait_value", 0.0)), "self-discarded wait lowers tenpai value")
	check(bool(lazy_self_discard_context.get("self_discard_lookup_ready", false)) and int(lazy_self_discard_wait_report.get("wait_total_remaining", 0)) == int(self_discarded_wait_report.get("wait_total_remaining", 0)), "tenpai AI reports lazily build self-discard lookup when scoring waits")
	check(scene.wait_quality_text(self_discarded_wait_report).find("回头待东") >= 0, "wait quality text names self-discarded wait")
	check(scene.wait_quality_text(self_discarded_wait_report) != "", "wait quality text remains available for self-discarded waits")
	check(scene.ai_discard_brief(self_discarded_wait_report).find("回头待东") >= 0, "AI brief exposes self-discarded wait quality")
	scene.players[0]["discards"] = []
	var pure_tenpai = pure_one_suit_hand()
	pure_tenpai.remove_at(pure_tenpai.size() - 1)
	var pure_wait_report = scene.build_ai_discard_report(0, "P", pure_tenpai, 0)
	check(str(pure_wait_report.get("wait_best_tile", "")) != "", "pure suit tenpai names a best wait tile")
	check(int(pure_wait_report.get("wait_best_points", 0)) > int(low_wait_report.get("wait_best_points", 0)), "higher fan tenpai gets higher wait points")
	check(float(pure_wait_report.get("wait_value", 0.0)) > float(low_wait_report.get("wait_value", 0.0)), "higher fan tenpai gets stronger AI value")
	check(scene.ai_discard_brief(pure_wait_report).find("价值") >= 0 and scene.ai_discard_brief(pure_wait_report).find("分") >= 0, "AI brief includes high value wait")
	scene.mode = "offline"
	scene.offline_hand_number = 7
	scene.players[0]["score"] = 33000
	scene.players[1]["score"] = 30000
	scene.players[2]["score"] = 24000
	scene.players[3]["score"] = 13000
	scene.players[0]["hand"] = ai_shape_hand()
	scene.current_human_advice = []
	var leader_context = scene.score_context_report(0)
	var trailer_context = scene.score_context_report(3)
	check(int(leader_context.get("rank", 0)) == 1 and str(leader_context.get("strategy", "")) == "守成", "late leader score context switches to guard strategy")
	check(int(trailer_context.get("rank", 0)) == 4 and str(trailer_context.get("strategy", "")) == "追分", "late trailer score context switches to chase strategy")
	check(scene.score_strategy_text(0).find("分势") >= 0 and scene.score_strategy_text(0).find("守成") >= 0, "score strategy text names leader guard mode")
	check(scene.score_momentum_label(leader_context) == "第1 守成" and scene.score_momentum_label(trailer_context) == "第4 追分", "seat score momentum labels rank and strategy compactly")
	var score_ribbon_parent = Control.new()
	root.add_child(score_ribbon_parent)
	scene.draw_seat(score_ribbon_parent, 0, scene.rect_full(0.0, 0.0, 1.0, 1.0), "bottom")
	check(score_ribbon_parent.find_child("SeatScoreMomentumRibbon", true, false) != null and score_ribbon_parent.find_child("SeatScoreMomentumSeal", true, false) != null and score_ribbon_parent.find_child("SeatScoreMomentumPulse", true, false) != null, "seat panel renders score momentum ribbon art")
	check(score_ribbon_parent.find_child("SeatScoreMomentumRoute", true, false) != null and score_ribbon_parent.find_child("SeatScoreMomentumFill", true, false) != null and score_ribbon_parent.find_child("SeatScoreMomentumGate", true, false) != null and score_ribbon_parent.find_child("SeatScoreMomentumRankNode", true, false) != null, "seat score momentum ribbon renders rank route art")
	check(count_nodes_with_name_prefix(score_ribbon_parent, "SeatScoreMomentumTick_") == 3, "seat score momentum ribbon renders strategy rhythm ticks")
	check(has_label_text(score_ribbon_parent, "第1 守成"), "seat score momentum ribbon names leader guard state")
	score_ribbon_parent.queue_free()
	check(scene.score_defense_adjustment(0) > 0.0 and scene.score_defense_adjustment(3) < 0.0, "score context adjusts defense direction")
	check(scene.score_attack_multiplier(3) > scene.score_attack_multiplier(0), "trailing score context boosts attack multiplier")
	var value_metrics = scene.effective_tile_metrics(tenpai_hand(), 0, 0, 0)
	var leader_wait = scene.wait_value_metrics(0, tenpai_hand(), 0, 0, value_metrics.get("tiles", []), value_metrics.get("remaining_by_tile", {}))
	var trailer_wait = scene.wait_value_metrics(3, tenpai_hand(), 0, 0, value_metrics.get("tiles", []), value_metrics.get("remaining_by_tile", {}))
	check(float(trailer_wait.get("score", 0.0)) > float(leader_wait.get("score", 0.0)), "trailing player values tenpai waits more aggressively")
	check(scene.ai_advice_summary(0, 2).find("分势") >= 0, "advisor includes score strategy line")
	var score_claim_report = {"seat": 0, "claim": "peng", "before_shanten": 2, "after_shanten": 1, "shape_gain": 40.0, "forced_discard_risk": 22.0}
	var leader_claim_score = scene.ai_claim_action_score(score_claim_report, 0)
	score_claim_report["seat"] = 3
	var trailer_claim_score = scene.ai_claim_action_score(score_claim_report, 0)
	check(trailer_claim_score > leader_claim_score, "trailing player values productive claims more aggressively")
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.current_seat = 0
	scene.offline_turn_needs_draw = false
	scene.players[0]["hand"] = ai_shape_hand()
	scene.players[0]["melds"] = []
	scene.current_human_advice = scene.get_ai_discard_reports(0)
	check(not scene.current_human_advice.is_empty(), "AI reports remain available for computer decision logic")
	var recommend_actions_parent = Control.new()
	root.add_child(recommend_actions_parent)
	scene.draw_actions(recommend_actions_parent)
	check(not has_button_text(recommend_actions_parent, "推荐东"), "action bar does not render human recommended discard")
	check(count_button_text_prefix(recommend_actions_parent, "备") == 0, "action bar does not render human alternative discards")
	check(not has_button_text(recommend_actions_parent, "提示"), "action bar does not render human AI hint button")
	recommend_actions_parent.queue_free()
	check(scene.discard_action_alternative_reports("E", 2).is_empty(), "human alternative discard helper is disabled")
	var recommend_hand_parent = Control.new()
	root.add_child(recommend_hand_parent)
	scene.draw_hand(recommend_hand_parent)
	check(not has_label_text(recommend_hand_parent, "荐"), "hand does not render recommendation badge")
	recommend_hand_parent.queue_free()
	var hint_text = scene.human_hint_text()
	check(hint_text.find("建议") < 0 and hint_text == scene.current_status_text(), "human hint text returns status without AI advice")
	var tray_summary = scene.hand_tray_text()
	check(not tray_summary.begins_with("荐") and tray_summary == scene.current_status_text(), "hand tray uses status without AI summary")
	check(scene.discard_alternative_text(scene.current_human_advice, 2).find("/") >= 0, "internal AI alternative text remains available for AI reports")
	check(scene.shanten_label(0) == "听牌", "shanten label names tenpai")
	check(scene.risk_label(10.0) == "低" and scene.risk_label(40.0) == "高", "risk labels bucket danger")
	scene.players[1]["melds"] = [["3W", "4W", "5W"], ["6W", "7W", "8W"]]
	scene.players[1]["discards"] = ["1T", "9B", "E", "P"]
	scene.players[2]["melds"] = []
	scene.players[2]["discards"] = []
	scene.players[3]["melds"] = []
	scene.players[3]["discards"] = []
	var threatened_risk = scene.deal_in_risk_score("5W", 0)
	var neutral_risk = scene.deal_in_risk_score("5T", 0)
	check(scene.opponent_tile_threat_score("5W", 0) > scene.opponent_tile_threat_score("5T", 0), "same-suit exposed melds raise tile threat")
	check(threatened_risk > neutral_risk, "same-suit exposed melds raise deal-in risk")
	var risk_summary = scene.deal_in_risk_summary("5W", 0)
	var visible_risk_counts = scene.visible_tile_counts()
	var cached_risk_summary = scene.deal_in_risk_summary("5W", 0, visible_risk_counts)
	var tile_risk_vector = scene.tile_risk_vector("5W", 0, visible_risk_counts)
	var vector_risk_summary = scene.deal_in_risk_summary("5W", 0, visible_risk_counts, tile_risk_vector)
	var vector_threat = scene.opponent_tile_threat_score("5W", 0, visible_risk_counts, tile_risk_vector)
	var risk_vector_context = scene.make_ai_evaluation_context(0, visible_risk_counts)
	var contextual_risk_vector = scene.tile_risk_vector("5W", 0, visible_risk_counts, risk_vector_context)
	var contextual_risk_source: Dictionary = contextual_risk_vector.get("danger_source", {})
	var expected_risk_source_opponent = int(contextual_risk_source.get("opponent", -1))
	var direct_contextual_risk_score = scene.deal_in_risk_score("5W", 0, risk_vector_context)
	var cached_contextual_risk_vector = scene.tile_risk_vector("5W", 0, visible_risk_counts, risk_vector_context)
	var cached_contextual_source: Dictionary = cached_contextual_risk_vector.get("danger_source", {})
	if not cached_contextual_source.is_empty():
		cached_contextual_source["opponent"] = 9
	var refreshed_contextual_risk_vector = scene.tile_risk_vector("5W", 0, visible_risk_counts, risk_vector_context)
	var refreshed_contextual_source: Dictionary = refreshed_contextual_risk_vector.get("danger_source", {})
	var pressure_score = scene.discard_pressure_score("5W", 0)
	var cached_pressure_score = scene.discard_pressure_score("5W", 0, visible_risk_counts)
	var pressure_context = scene.ai_pressure_context(0)
	var visible_five_man = scene.visible_tile_count("5W")
	var manual_risk = 0.0
	for other in range(scene.players.size()):
		manual_risk += scene.single_opponent_deal_in_risk("5W", 0, other, visible_five_man, visible_risk_counts)
	var reusable_risk_components: Dictionary = {"risk": -1.0, "pattern_threat": -1.0}
	scene.write_single_opponent_deal_in_risk_components(reusable_risk_components, "5W", 0, 1, visible_five_man, visible_risk_counts)
	var returned_risk_components = scene.single_opponent_deal_in_risk_components("5W", 0, 1, visible_five_man, visible_risk_counts)
	var reusable_matches_returned = is_equal_approx(float(reusable_risk_components.get("risk", -1.0)), float(returned_risk_components.get("risk", -2.0))) and is_equal_approx(float(reusable_risk_components.get("pattern_threat", -1.0)), float(returned_risk_components.get("pattern_threat", -2.0)))
	scene.write_single_opponent_deal_in_risk_components(reusable_risk_components, "", 0, 1, visible_five_man, visible_risk_counts)
	var summary_source = risk_summary.get("danger_source", {})
	check(is_equal_approx(float(risk_summary.get("score", -1.0)), manual_risk), "deal-in risk summary scans opponent risks once")
	check(reusable_matches_returned and is_equal_approx(float(reusable_risk_components.get("risk", -1.0)), 0.0) and is_equal_approx(float(reusable_risk_components.get("pattern_threat", -1.0)), 0.0), "deal-in risk component scan can reuse one result dictionary safely")
	check(is_equal_approx(direct_contextual_risk_score, float(contextual_risk_vector.get("score", -1.0))), "direct deal-in risk score reuses risk vectors without summary allocation")
	check(is_equal_approx(float(cached_risk_summary.get("score", -1.0)), float(risk_summary.get("score", -2.0))), "deal-in risk summary can reuse visible count snapshots")
	check(is_equal_approx(float(vector_risk_summary.get("score", -1.0)), float(risk_summary.get("score", -2.0))), "deal-in risk summary can reuse tile risk vectors")
	check(is_equal_approx(vector_threat, scene.opponent_tile_threat_score("5W", 0, visible_risk_counts)), "tile risk vector reuses opponent threat scores")
	check(expected_risk_source_opponent >= 0 and int(refreshed_contextual_source.get("opponent", -1)) == expected_risk_source_opponent, "tile risk vector cache protects nested danger source with targeted copies")
	check(is_equal_approx(pressure_score, cached_pressure_score), "discard pressure score can reuse visible count snapshots")
	check(is_equal_approx(float(pressure_context.get("opponent_pressure", -1.0)), scene.opponent_pressure_score(0)), "AI pressure context reuses opponent pressure for candidate reports")
	check(is_equal_approx(float(pressure_context.get("readiness_pressure", -1.0)), scene.opponent_readiness_pressure_score(0)), "AI pressure context reuses readiness pressure for candidate reports")
	check(typeof(summary_source) == TYPE_DICTIONARY and int(summary_source.get("opponent", -1)) == 1, "deal-in risk summary carries danger source")
	var shared_simulated_hand = ["1B", "1B", "1B", "2B", "3B", "4B", "5B", "6B", "7B", "E", "E", "P", "P"]
	var shared_simulated_counts = scene.tile_counts(shared_simulated_hand)
	var safe_report = scene.build_ai_discard_report(0, "5T", shared_simulated_hand, 0)
	var danger_report = scene.build_ai_discard_report(0, "5W", shared_simulated_hand, 0)
	var cached_context_report = scene.build_ai_discard_report(0, "5W", shared_simulated_hand, 0, visible_risk_counts, pressure_context)
	var counted_context_report = scene.build_ai_discard_report(0, "5W", shared_simulated_hand, 0, visible_risk_counts, pressure_context, {}, shared_simulated_counts)
	var original_shared_counts = shared_simulated_counts.duplicate()
	original_shared_counts[scene.tile_index("5W")] = int(original_shared_counts[scene.tile_index("5W")]) + 1
	var original_shared_counts_before = original_shared_counts.duplicate()
	var counted_original_report = scene.build_ai_discard_report(0, "5W", shared_simulated_hand, 0, visible_risk_counts, pressure_context, {}, shared_simulated_counts, original_shared_counts)
	check(float(safe_report.get("score", 0.0)) > float(danger_report.get("score", 0.0)), "AI scores dangerous exposed-suit discard lower")
	check(is_equal_approx(float(cached_context_report.get("score", -1.0)), float(danger_report.get("score", -2.0))), "AI discard report can reuse pressure context without score changes")
	check(is_equal_approx(float(cached_context_report.get("defense", -1.0)), float(danger_report.get("defense", -2.0))), "AI discard report can reuse pressure context without defense changes")
	check(is_equal_approx(float(cached_context_report.get("emergency_defense", -1.0)), float(danger_report.get("emergency_defense", -2.0))), "AI discard report can reuse pressure context without emergency defense changes")
	check(is_equal_approx(float(counted_context_report.get("score", -1.0)), float(cached_context_report.get("score", -2.0))) and int(counted_context_report.get("shanten", 8)) == int(cached_context_report.get("shanten", 9)) and int(counted_context_report.get("ukeire", -1)) == int(cached_context_report.get("ukeire", -2)), "AI discard report can reuse simulated hand counts without score or shanten changes")
	check(str(counted_original_report.get("reason_label", "")) == str(counted_context_report.get("reason_label", "")) and original_shared_counts == original_shared_counts_before, "AI discard report can reuse original hand counts without mutating snapshots")
	scene.clear_threat_report_cache()
	var cached_threat_report = scene.opponent_seat_threat_report(0, 1)
	var threat_cache_size = scene.threat_report_cache.size()
	var cached_threat_report_again = scene.opponent_seat_threat_report(0, 1)
	check(threat_cache_size == scene.threat_report_cache.size() and str(cached_threat_report_again.get("plan_label", "")) == str(cached_threat_report.get("plan_label", "")), "threat report cache reuses identical table state")
	var cached_safe_tiles: Array = cached_threat_report.get("safe_tiles", [])
	if not cached_safe_tiles.is_empty():
		var original_safe_tile = str(cached_safe_tiles[0])
		cached_safe_tiles[0] = "ZZ"
		check(str(scene.opponent_seat_threat_report(0, 1).get("safe_tiles", [])[0]) == original_safe_tile, "threat report cache protects nested safe tile arrays")
	var threat_report = scene.opponent_threat_report(0)
	check(int(threat_report.get("opponent", -1)) == 1, "threat report identifies most dangerous opponent")
	check(scene.threat_level_rank(str(threat_report.get("level", ""))) >= scene.threat_level_rank("高"), "threat report buckets focused open meld pressure")
	check(str(threat_report.get("plan_label", "")) == "万", "threat report names exposed suit plan")
	check(not threat_report.get("safe_tiles", []).is_empty(), "threat report suggests safe tiles")
	check(scene.opponent_threat_summary(0).find("万") >= 0, "advisor threat summary names exposed suit")
	check(scene.opponent_threat_summary(0).find("安牌") >= 0, "advisor threat summary names safe tile candidates")
	check(scene.ai_advice_summary(0, 2).find("防守") >= 0, "advisor includes defensive threat line")
	check(str(scene.opponent_seat_threat_report(0, 1).get("plan_label", "")) == "万", "seat threat report names opponent plan")
	check(scene.opponent_seat_threat_badge_text(1, 0).find("万") >= 0, "seat threat badge names exposed suit")
	check(scene.opponent_seat_threat_line(1, 0).find("威万") >= 0, "seat threat line summarizes danger")
	scene.clear_threat_report_cache()
	var render_threat_context = scene.make_ai_evaluation_context(0, scene.visible_tile_counts())
	var render_threat_reports = scene.render_seat_threat_reports(0, render_threat_context)
	var render_risk_cache: Dictionary = render_threat_context.get("risk_vectors", {})
	var render_safety_cache: Dictionary = render_threat_context.get("safety_labels", {})
	check(render_risk_cache.size() > 0 and render_safety_cache.size() > 0, "seat render threat reports share one AI risk/safety context")
	var render_risk_cache_size = render_risk_cache.size()
	scene.render_seat_threat_reports(0, render_threat_context)
	check(render_risk_cache.size() == render_risk_cache_size, "seat render threat report cache avoids repeated risk scans")
	check(render_threat_reports.has(1) and scene.opponent_seat_threat_badge_text_from_report(render_threat_reports[1]) == scene.opponent_seat_threat_badge_text(1, 0), "seat render threat reports reuse one report for badge text")
	check(scene.opponent_seat_threat_line_from_report(render_threat_reports[1]) == scene.opponent_seat_threat_line(1, 0), "seat render threat reports reuse one report for line text")
	var threat_seat_parent = Control.new()
	root.add_child(threat_seat_parent)
	scene.draw_seat(threat_seat_parent, 1, scene.rect_full(0.0, 0.0, 1.0, 1.0), "right", render_threat_reports)
	check(has_label_text(threat_seat_parent, scene.opponent_seat_threat_badge_text(1, 0)), "seat panel renders opponent threat badge")
	check(threat_seat_parent.find_child("SeatThreatBadgeArt_1", true, false) != null and threat_seat_parent.find_child("SeatThreatSourceNode_1", true, false) != null and threat_seat_parent.find_child("SeatThreatPressureNode_1", true, false) != null, "seat panel renders opponent threat source and pressure nodes")
	check(threat_seat_parent.find_child("SeatThreatRoute_1", true, false) != null and threat_seat_parent.find_child("SeatThreatFill_1", true, false) != null and threat_seat_parent.find_child("SeatThreatGate_1", true, false) != null and count_nodes_with_name_prefix(threat_seat_parent, "SeatThreatSafeTick_1_") == 3, "seat panel renders opponent threat route and safe-tile rhythm ticks")
	threat_seat_parent.queue_free()
	scene.players[1]["discards"].append("2W")
	check(scene.main_threat_opponent(0) == 1, "main threat opponent is identified without using safe tile recursion")
	check(scene.is_main_threat_genbutsu("2W", 0), "tile discarded by main threat is recognized as genbutsu")
	check(scene.tile_safety_label("2W", 0) == "现", "main-threat genbutsu gets safety label")
	check(scene.discard_safety_text({"safety_label": "现", "risk_label": "低"}) == "主现物", "AI brief names main-threat genbutsu")
	check(scene.ai_safety_bonus("现", 1.8, 3) > scene.ai_safety_bonus("熟", 1.8, 3) and scene.ai_safety_bonus("现", 1.8, 3) < scene.ai_safety_bonus("安", 1.8, 3), "main-threat genbutsu safety bonus sits between visible safe and all-safe")
	var genbutsu_tile = scene.make_tile_view("2W", Vector2(62, 84), true, Callable(), false, "现")
	check(count_label_nodes(genbutsu_tile) == 0 and has_visible_tile_art(genbutsu_tile), "tile view keeps main-threat genbutsu as image-only tile")
	check(genbutsu_tile.find_child("TileStatusRoute", true, false) != null and genbutsu_tile.find_child("TileStatusFill", true, false) != null and genbutsu_tile.find_child("TileStatusGate", true, false) != null and count_nodes_with_name_prefix(genbutsu_tile, "TileStatusTick_") == 2, "tile view renders non-text safety status route")
	genbutsu_tile.queue_free()
	scene.players[1]["name"] = scene.SEAT_NAMES[1]
	var danger_source = scene.discard_danger_source_report("5W", 0)
	check(int(danger_source.get("opponent", -1)) == 1, "danger source identifies the opponent driving discard risk")
	check(scene.discard_danger_text(danger_source).find("青竹道人") >= 0 and scene.discard_danger_text(danger_source).find("万") >= 0, "danger source text names opponent and plan")
	var feed_report = scene.discard_feed_risk_report("5W", 0)
	var cached_feed_report = scene.discard_feed_risk_report("5W", 0, visible_risk_counts)
	var feed_context = scene.make_ai_evaluation_context(0, visible_risk_counts)
	var contextual_feed_report = scene.discard_feed_risk_report("5W", 0, visible_risk_counts, feed_context)
	var contextual_feed_details: Array = contextual_feed_report.get("details", [])
	var expected_feed_opponent = -1
	if not contextual_feed_details.is_empty() and typeof(contextual_feed_details[0]) == TYPE_DICTIONARY:
		var contextual_feed_detail: Dictionary = contextual_feed_details[0]
		expected_feed_opponent = int(contextual_feed_detail.get("opponent", -1))
	var cached_contextual_feed_report = scene.discard_feed_risk_report("5W", 0, visible_risk_counts, feed_context)
	var cached_contextual_feed_details: Array = cached_contextual_feed_report.get("details", [])
	if not cached_contextual_feed_details.is_empty() and typeof(cached_contextual_feed_details[0]) == TYPE_DICTIONARY:
		var cached_contextual_feed_detail: Dictionary = cached_contextual_feed_details[0]
		cached_contextual_feed_detail["opponent"] = 9
	var refreshed_contextual_feed_report = scene.discard_feed_risk_report("5W", 0, visible_risk_counts, feed_context)
	var refreshed_contextual_feed_details: Array = refreshed_contextual_feed_report.get("details", [])
	var refreshed_feed_opponent = -1
	if not refreshed_contextual_feed_details.is_empty() and typeof(refreshed_contextual_feed_details[0]) == TYPE_DICTIONARY:
		var refreshed_contextual_feed_detail: Dictionary = refreshed_contextual_feed_details[0]
		refreshed_feed_opponent = int(refreshed_contextual_feed_detail.get("opponent", -1))
	var low_feed_report = scene.discard_feed_risk_report("9B", 0)
	check(float(feed_report.get("score", 0.0)) > float(low_feed_report.get("score", 0.0)), "same-suit middle discard has higher public feed risk")
	check(is_equal_approx(float(feed_report.get("score", -1.0)), float(cached_feed_report.get("score", -2.0))), "feed risk report can reuse visible count snapshots")
	check(expected_feed_opponent >= 0 and refreshed_feed_opponent == expected_feed_opponent, "feed risk report cache protects nested details with targeted copies")
	check(scene.discard_feed_risk_text(feed_report).find("青竹道人") >= 0, "feed risk text names the likely claimant")
	var feed_ai_report = scene.build_ai_discard_report(0, "5W", shared_simulated_hand, 0)
	check(float(feed_ai_report.get("feed_risk", 0.0)) > 0.0, "AI discard report includes feed risk")
	check(scene.discard_safety_text(feed_ai_report).find("喂") >= 0, "discard safety text includes feed risk")
	scene.players[1]["melds"] = []
	scene.players[1]["discards"] = []
	var no_feed_ai_report = scene.build_ai_discard_report(0, "5W", shared_simulated_hand, 0)
	check(float(no_feed_ai_report.get("score", 0.0)) > float(feed_ai_report.get("score", 0.0)), "feed risk lowers discard score")
	scene.players[1]["melds"] = []
	scene.players[1]["discards"] = ["1W", "9W", "1T", "9T", "1B", "9B", "E", "S", "N", "R", "Z", "F", "P"]
	scene.players[2]["melds"] = []
	scene.players[2]["discards"] = []
	scene.players[3]["melds"] = []
	scene.players[3]["discards"] = []
	scene.wall.clear()
	for n in range(20):
		scene.wall.append("1W")
	var readiness_report = scene.opponent_readiness_report(0, 1)
	check(str(readiness_report.get("label", "")).find("听") >= 0, "late concealed opponent gets near-tenpai readiness label")
	check(readiness_report.get("reasons", []).has("末盘") and readiness_report.get("reasons", []).has("弃牌多"), "readiness report explains late discard pressure")
	var readiness_threat = scene.opponent_threat_report(0)
	check(int(readiness_threat.get("opponent", -1)) == 1 and str(readiness_threat.get("readiness_label", "")).find("听") >= 0, "threat report includes concealed readiness pressure")
	check(scene.opponent_threat_summary(0).find("听") >= 0, "advisor threat summary names near-tenpai pressure")
	check(scene.opponent_seat_threat_badge_text(1, 0).find("听") >= 0, "seat badge shows near-tenpai pressure")
	var ready_mid_risk = scene.deal_in_risk_score("5W", 0)
	var ready_defense = scene.ai_defense_weight(0, 3)
	scene.players[1]["discards"] = []
	scene.wall.clear()
	for n in range(84):
		scene.wall.append("1W")
	var quiet_mid_risk = scene.deal_in_risk_score("5W", 0)
	var quiet_defense = scene.ai_defense_weight(0, 3)
	check(ready_mid_risk > quiet_mid_risk, "near-tenpai readiness raises middle tile deal-in risk")
	check(ready_defense > quiet_defense, "near-tenpai readiness raises AI defense weight")
	scene.players[1]["melds"] = [["3W", "4W", "5W"], ["6W", "7W", "8W"]]
	scene.players[1]["discards"] = ["1T", "9B", "E", "P", "2W"]
	check(scene.risk_badge_text("高") == "高危" and scene.risk_badge_text("低") == "低", "risk badge text is compact")
	check(scene.risk_badge_text("现") == "现", "main-threat genbutsu badge text is compact")
	check(scene.tile_risk_color("高").r > scene.tile_risk_color("低").r, "risk badge colors distinguish high danger")
	var risk_tile = scene.make_tile_view("5W", Vector2(62, 84), true, Callable(), false, "高")
	check(count_label_nodes(risk_tile) == 0 and has_visible_tile_art(risk_tile), "tile view keeps high risk state image-only")
	check(risk_tile.find_child("TileStatusRoute", true, false) != null and risk_tile.find_child("TileStatusFill", true, false) != null and risk_tile.find_child("TileStatusGate", true, false) != null and count_nodes_with_name_prefix(risk_tile, "TileStatusTick_") == 2, "tile view renders non-text risk status route")
	risk_tile.queue_free()
	scene.start_offline(true)
	scene.offline_phase = "await_discard"
	scene.current_seat = 0
	scene.offline_turn_needs_draw = false
	scene.wall.clear()
	scene.players[0]["hand"] = ["1W", "2W", "3W", "5W", "7W", "8W", "9W", "1T", "2T", "3T", "1B", "2B", "3B", "P"]
	scene.players[0]["discards"] = []
	scene.players[0]["melds"] = []
	scene.players[1]["hand"] = []
	scene.players[1]["melds"] = [["3W", "4W", "5W"], ["6W", "7W", "8W"], ["2T", "2T", "2T"]]
	scene.players[1]["discards"] = ["1T", "9T", "1B", "9B", "E", "S", "N", "R", "Z", "F", "P", "8B"]
	scene.players[2]["hand"] = []
	scene.players[2]["melds"] = []
	scene.players[2]["discards"] = []
	scene.players[3]["hand"] = []
	scene.players[3]["melds"] = []
	scene.players[3]["discards"] = []
	var confirm_danger_report = scene.discard_report_for_tile("5W")
	check(confirm_danger_report.is_empty(), "human discard risk report is disabled")
	var confirm_danger_index = scene.find_tile_in_hand(scene.players[0]["hand"], "5W")
	var hand_size_before_danger = scene.players[0]["hand"].size()
	scene.human_discard_by_tile("5W")
	check(scene.players[0]["hand"].size() == hand_size_before_danger - 1, "human discard commits immediately without AI confirmation")
	check(scene.players[0]["discards"].has("5W"), "human discard path commits selected tile")
	check(scene.offline_phase == "resolving", "human discard enters resolving phase immediately to block accidental second taps")
	scene.human_discard(confirm_danger_index)
	check(scene.players[0]["hand"].size() == hand_size_before_danger - 1, "resolving phase blocks accidental repeated discard taps")
	check(not scene.has_pending_danger_discard(), "human discard does not enter pending danger confirmation")
	var confirm_hand_parent = Control.new()
	root.add_child(confirm_hand_parent)
	scene.draw_hand(confirm_hand_parent)
	check(not has_label_text(confirm_hand_parent, "确认") and not has_label_text(confirm_hand_parent, "高危"), "hand does not render AI risk confirmation badges")
	confirm_hand_parent.queue_free()
	check(scene.hand_tray_text().find("再点确认") < 0, "hand tray does not ask for AI danger confirmation")
	var safe_alternatives = scene.safe_discard_alternative_reports("5W", 2)
	check(safe_alternatives.is_empty(), "human safe alternative reports are disabled")
	scene.mode = "menu"
	await process_frame
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.current_seat = 0
	scene.offline_turn_needs_draw = false
	scene.players[1]["discards"] = ["9W"]
	scene.players[2]["discards"] = ["9W"]
	scene.players[3]["discards"] = ["9W"]
	check(scene.is_tile_safe_against_all("9W", 0), "tile discarded by all opponents is all-safe")
	check(scene.tile_safety_label("9W", 0) == "安", "all-safe tile gets safety label")
	var all_safe_report = scene.build_ai_discard_report(0, "9W", shared_simulated_hand, 0)
	check(str(all_safe_report.get("safety_label", "")) == "安", "AI report marks all-safe discard")
	check(scene.discard_safety_text(all_safe_report) == "全现物", "AI brief safety text names all-safe discard")
	check(str(all_safe_report.get("stance", "")) != "", "AI report includes attack-defense stance")
	scene.wall.clear()
	scene.players[1]["melds"] = [["3W", "4W", "5W"], ["6W", "7W", "8W"], ["2T", "2T", "2T"]]
	scene.players[1]["discards"] = ["9W", "1T", "9T", "1B", "9B", "E", "S", "N", "R", "Z", "F", "P"]
	scene.players[2]["discards"] = ["9W"]
	scene.players[3]["discards"] = ["9W"]
	var defensive_report = scene.build_ai_discard_report(0, "9W", ["1W", "4W", "7W", "2T", "5T", "8T", "1B", "4B", "7B", "E", "S", "N", "P"], 0)
	check(float(defensive_report.get("safety_bonus", 0.0)) > 0.0, "AI report gives defensive bonus to all-safe discard under pressure")
	check(float(defensive_report.get("emergency_defense", 0.0)) > 0.0, "emergency defense boosts all-safe discard under pressure")
	check(str(defensive_report.get("stance", "")) == "防守", "AI report switches to defense stance under pressure")
	var unsafe_defensive_report = scene.build_ai_discard_report(0, "5W", ["1W", "4W", "7W", "2T", "5T", "8T", "1B", "4B", "7B", "E", "S", "N", "P"], 0)
	check(float(unsafe_defensive_report.get("emergency_defense", 0.0)) < 0.0, "emergency defense penalizes unsafe middle discard under pressure")
	var severe_threat = scene.opponent_threat_report(0)
	check(str(severe_threat.get("level", "")) == "危", "threat report escalates severe open-meld pressure")
	scene.offline_phase = "await_discard"
	scene.current_seat = 0
	scene.offline_turn_needs_draw = false
	scene.current_human_advice = []
	var safest_report = scene.safest_discard_report()
	check(safest_report.is_empty(), "human safest discard shortcut is disabled")
	var safest_button_text = "最安%s" % scene.tile_label("9W")
	var safest_hint_text = "最安打%s" % scene.tile_label("9W")
	var safe_action_parent = Control.new()
	root.add_child(safe_action_parent)
	scene.draw_actions(safe_action_parent)
	check(not has_button_text(safe_action_parent, safest_button_text), "action bar does not render safest discard shortcut")
	safe_action_parent.queue_free()
	check(scene.human_hint_text().find(safest_hint_text) < 0, "human hint does not include safest discard")
	check(scene.hand_tray_text().find(safest_hint_text) < 0, "hand tray does not include safest discard")
	var alternatives_without_safe = scene.discard_action_alternative_reports(["9W"], 3)
	check(alternatives_without_safe.is_empty(), "human action alternative helper is disabled under pressure")
	check(scene.threat_safe_tile_labels(0, "suit", 0, 2)[0] == scene.tile_label("9W"), "threat safe tile labels keep all-safe tile first after one-pass sort")
	var threat_safe_top_two = scene.threat_safe_tile_labels(0, "suit", 0, 2)
	var threat_safe_full = scene.threat_safe_tile_labels(0, "suit", 0, 99)
	check(threat_safe_top_two == threat_safe_full.slice(0, min(2, threat_safe_full.size())) and scene.threat_safe_tile_labels(0, "suit", 0, 0).is_empty(), "threat safe tile labels keep top-N insertion order without full candidate sort")
	var threat_safe_context = scene.make_ai_evaluation_context(0, scene.visible_tile_counts())
	var cached_threat_safe_labels = scene.threat_safe_tile_labels(0, "suit", 0, 2, threat_safe_context)
	var threat_safe_risk_cache: Dictionary = threat_safe_context.get("risk_vectors", {})
	var threat_safe_risk_cache_size = threat_safe_risk_cache.size()
	check(scene.threat_safe_tile_labels(0, "suit", 0, 2, threat_safe_context) == cached_threat_safe_labels and threat_safe_risk_cache.size() == threat_safe_risk_cache_size, "threat safe tile labels reuse risk vector scores without summary allocation")
	var safe_tile = scene.make_tile_view("9W", Vector2(62, 84), true, Callable(), false, "安")
	check(count_label_nodes(safe_tile) == 0 and has_visible_tile_art(safe_tile), "tile view keeps all-safe state image-only")
	check(safe_tile.find_child("TileStatusRoute", true, false) != null and safe_tile.find_child("TileStatusFill", true, false) != null and safe_tile.find_child("TileStatusGate", true, false) != null and count_nodes_with_name_prefix(safe_tile, "TileStatusTick_") == 2, "tile view renders all-safe status route")
	safe_tile.queue_free()
	scene.players[1]["discards"] = []
	scene.players[1]["melds"] = [["8W", "8W", "8W"]]
	scene.players[2]["discards"] = []
	scene.players[3]["discards"] = []
	var visible_safety_counts = scene.visible_tile_counts()
	check(scene.tile_safety_label("8W", 0) == "熟", "three visible copies get safe-live tile label")
	check(scene.tile_safety_label("8W", 0, visible_safety_counts) == "熟", "tile safety label can reuse visible count snapshots")
	check(scene.discard_safety_text({"safety_label": "熟", "risk_label": "低"}) == "熟张", "AI brief safety text names fully visible tile")
	check(scene.ai_safety_bonus("安", 1.8, 3) > scene.ai_safety_bonus("熟", 1.8, 3), "all-safe gets stronger defense bonus than fully visible tile")
	scene.players[1]["melds"] = [["3W", "4W", "5W"]]
	scene.players[1]["discards"] = ["4W", "1T", "9T", "E", "P", "9B"]
	scene.players[2]["discards"] = []
	scene.players[3]["discards"] = []
	check(scene.is_suji_safe_against_opponent("7W", 1), "discarded four creates suji safety for seven")
	var suji_context = scene.make_ai_evaluation_context(0, scene.visible_tile_counts())
	check(scene.is_suji_safe_against_opponent("7W", 1, suji_context), "suji safety can use indexed opponent discard context without anchor arrays")
	check(not scene.is_suji_safe_against_opponent("8W", 1), "unrelated tile is not suji safe")
	check(scene.tile_safety_label("7W", 0) == "筋", "suji tile gets weak safety label")
	check(scene.discard_safety_text({"safety_label": "筋", "risk_label": "中"}) == "筋线", "AI brief safety text names suji tile")
	check(scene.deal_in_risk_score("1W", 0) < scene.deal_in_risk_score("2W", 0), "outside suji lowers deal-in risk against pressure")
	check(scene.risk_badge_text("筋") == "筋", "suji badge text is compact")
	var suji_tile = scene.make_tile_view("7W", Vector2(62, 84), true, Callable(), false, "筋")
	check(count_label_nodes(suji_tile) == 0 and has_visible_tile_art(suji_tile), "tile view keeps suji safety state image-only")
	suji_tile.queue_free()
	scene.players[1]["melds"] = [["4W", "4W", "4W"]]
	scene.players[1]["discards"] = ["1T", "9T", "E", "P", "9B", "2B"]
	scene.players[2]["discards"] = []
	scene.players[3]["discards"] = []
	check(scene.is_kabe_safe_against_opponent("5W", 1), "three visible adjacent tiles create wall safety")
	var kabe_safety_counts = scene.visible_tile_counts()
	check(scene.is_kabe_safe_against_opponent("5W", 1, kabe_safety_counts), "wall safety can use indexed visible count snapshots without wall tile arrays")
	check(not scene.is_kabe_safe_against_opponent("5T", 1), "unblocked suit is not wall safe")
	check(scene.tile_safety_label("5W", 0) == "壁", "wall-safe tile gets weak safety label")
	check(scene.discard_safety_text({"safety_label": "壁", "risk_label": "中"}) == "壁牌", "AI brief safety text names wall safety")
	var wall_risk = scene.deal_in_risk_score("5W", 0)
	scene.players[1]["melds"] = [["6W", "7W", "8W"]]
	check(wall_risk < scene.deal_in_risk_score("5W", 0), "wall safety lowers deal-in risk against matching suit pressure")
	scene.players[1]["melds"] = [["4W", "4W", "4W"]]
	check(scene.risk_badge_text("壁") == "壁", "wall badge text is compact")
	var kabe_tile = scene.make_tile_view("5W", Vector2(62, 84), true, Callable(), false, "壁")
	check(count_label_nodes(kabe_tile) == 0 and has_visible_tile_art(kabe_tile), "tile view keeps wall safety state image-only")
	kabe_tile.queue_free()
	check(scene.ai_safety_bonus("壁", 1.8, 3) > 0.0 and scene.ai_safety_bonus("壁", 1.8, 3) < scene.ai_safety_bonus("熟", 1.8, 3), "wall safety gets weaker defense bonus than fully visible tile")
	check(scene.ai_safety_bonus("安", 1.8, 0) < scene.ai_safety_bonus("安", 1.8, 3), "tenpai reduces safety bonus")
	check(scene.ai_stance_label(1.6, 3) == "防守" and scene.ai_stance_label(0.8, 0) == "进攻", "AI stance labels attack and defense modes")
	check(scene.ai_advice_summary(0, 2).find("模式") >= 0, "advisor includes AI stance line")
	check(scene.risk_badge_text("安") == "安" and scene.risk_badge_text("熟") == "熟", "safe badge text is compact")
	scene.start_offline(true)
	var defensive_peng_hand = ["E", "E", "1W", "3W", "5W", "7W", "9W", "1T", "3T", "5T", "7B", "9B", "P"]
	scene.players[2]["hand"] = defensive_peng_hand.duplicate()
	scene.players[2]["melds"] = []
	scene.players[2]["discards"] = []
	scene.players[1]["hand"] = []
	scene.players[1]["melds"] = []
	scene.players[1]["discards"] = []
	scene.players[3]["hand"] = []
	scene.players[3]["melds"] = []
	scene.players[3]["discards"] = []
	scene.wall.clear()
	for n in range(84):
		scene.wall.append("1W")
	var low_pressure_peng = scene.build_ai_claim_report(2, "peng", "E")
	check(bool(low_pressure_peng.get("allow", false)), "AI may peng for shape value when pressure is low")
	check(str(low_pressure_peng.get("reason", "")) == "牌型收益", "low pressure peng is explained by shape value")
	var claim_count_snapshot = scene.tile_counts(defensive_peng_hand)
	var claim_after_counts = claim_count_snapshot.duplicate()
	var claim_after_hand = defensive_peng_hand.duplicate()
	check(scene.consume_tile_count(claim_after_counts, "E", 2) and scene.remove_known_tiles(claim_after_hand, "E", 2), "claim count snapshot consumes peng tiles without rescanning availability")
	check(scene.calculate_min_shanten_from_counts(claim_after_counts, scene.players[2]["melds"].size() + 1) == scene.calculate_min_shanten(claim_after_hand, scene.players[2]["melds"].size() + 1), "claim count snapshot keeps post-peng shanten equivalent to array removal")
	check(is_equal_approx(scene.evaluate_ai_hand_from_counts(claim_after_counts), scene.evaluate_ai_hand(claim_after_hand)), "claim count snapshot keeps post-peng shape value equivalent to array removal")
	scene.players[2]["hand"] = seven_pairs_claim_hand()
	scene.players[2]["melds"] = []
	var seven_pairs_peng = scene.build_ai_claim_report(2, "peng", "E")
	check(not bool(seven_pairs_peng.get("allow", true)), "AI declines peng that breaks seven pairs route")
	check(bool(seven_pairs_peng.get("declined_by_plan", false)), "AI claim report marks seven pairs route decline")
	check(str(seven_pairs_peng.get("reason", "")) == "保七对", "seven pairs claim decline reason is visible")
	check(scene.claim_report_reason_text(seven_pairs_peng).find("保七对") >= 0, "claim report reason explains seven pairs route")
	check(not scene.should_ai_peng(2, "E"), "AI peng helper preserves seven pairs route")
	scene.players[0]["hand"] = []
	scene.players[0]["discards"] = ["E"]
	check(scene.choose_ai_claim(0, "E").is_empty(), "AI does not choose peng that breaks seven pairs route")
	scene.wall.clear()
	scene.players[1]["melds"] = [["3W", "4W", "5W"], ["6W", "7W", "8W"], ["2T", "2T", "2T"]]
	scene.players[1]["discards"] = ["9W", "1T", "9T", "1B", "9B", "E", "S", "N", "R", "Z", "F", "P"]
	scene.players[2]["hand"] = defensive_peng_hand.duplicate()
	var high_pressure_peng = scene.build_ai_claim_report(2, "peng", "E")
	check(not bool(high_pressure_peng.get("allow", true)), "AI declines non-improving peng under high pressure")
	check(bool(high_pressure_peng.get("declined_by_pressure", false)), "AI claim report marks pressure decline")
	check(str(high_pressure_peng.get("reason", "")) == "高压防守", "pressure decline reason is visible")
	check(scene.claim_report_reason_text(high_pressure_peng).find("高压防守") >= 0, "claim report reason explains pressure defense")
	check(not scene.should_ai_peng(2, "E"), "AI peng helper uses pressure-aware report")
	scene.players[0]["hand"] = []
	scene.players[0]["discards"] = ["E"]
	var high_pressure_claim = scene.choose_ai_claim(0, "E")
	check(high_pressure_claim.is_empty(), "AI does not choose defensive peng from high-pressure discard")
	var weak_peng = scene.build_ai_claim_report(2, "peng", "5W")
	check(not bool(weak_peng.get("declined_by_pressure", false)), "shape-insufficient claims are not mislabeled as pressure declines")
	var pressure_chi_hand = ["2W", "4W", "1W", "7W", "9W", "1T", "3T", "5T", "7T", "1B", "4B", "7B", "P"]
	scene.players[2]["hand"] = pressure_chi_hand.duplicate()
	var pressure_chi_choice = scene.best_chi_choice(scene.players[2]["hand"], "3W")
	var pressure_chi = scene.build_ai_claim_report(2, "chi", "3W", pressure_chi_choice)
	check(bool(pressure_chi.get("allow", false)) and str(pressure_chi.get("reason", "")) == "降向听", "AI still accepts shanten-improving chi under pressure")
	var shared_claim_context = scene.make_ai_claim_context(2, scene.visible_tile_counts())
	var shared_pressure_chi = scene.build_ai_claim_report(2, "chi", "3W", pressure_chi_choice, shared_claim_context)
	check(bool(shared_pressure_chi.get("allow", false)) == bool(pressure_chi.get("allow", false)) and str(shared_pressure_chi.get("reason", "")) == str(pressure_chi.get("reason", "")) and is_equal_approx(float(shared_pressure_chi.get("forced_discard_risk", 0.0)), float(pressure_chi.get("forced_discard_risk", 0.0))), "AI claim report reuses shared claim context without changing pressure chi")
	var shared_best_chi = scene.best_ai_chi_claim(2, "3W", 1, shared_claim_context)
	check(str(shared_best_chi.get("claim", "")) == "chi" and scene.same_tile_list(shared_best_chi.get("chi_choice", {}).get("needed", []), pressure_chi_choice.get("needed", [])), "AI chi selection can reuse one shared claim context")
	var shared_claim_eval_context: Dictionary = shared_claim_context.get("eval_context", {})
	var shared_claim_pressure_context: Dictionary = shared_claim_context.get("pressure_context", {})
	var shared_claim_risk_cache: Dictionary = shared_claim_eval_context.get("risk_vectors", {})
	check(not shared_claim_pressure_context.is_empty() and shared_claim_risk_cache.size() > 0, "AI claim context precomputes pressure and fills shared risk cache")
	var shared_claim_risk_cache_size = shared_claim_risk_cache.size()
	scene.build_ai_claim_report(2, "chi", "3W", pressure_chi_choice, shared_claim_context)
	check(shared_claim_risk_cache.size() == shared_claim_risk_cache_size, "AI claim report reuses risk cache on repeated shared-context checks")
	var chi_after_counts = scene.tile_counts(pressure_chi_hand)
	var chi_after_hand = pressure_chi_hand.duplicate()
	check(scene.consume_tile_list_counts(chi_after_counts, pressure_chi_choice.get("needed", [])) and scene.remove_known_tile_list(chi_after_hand, pressure_chi_choice.get("needed", [])), "claim count snapshot consumes chi tiles without rescanning availability")
	check(scene.calculate_min_shanten_from_counts(chi_after_counts, scene.players[2]["melds"].size() + 1) == scene.calculate_min_shanten(chi_after_hand, scene.players[2]["melds"].size() + 1), "claim count snapshot keeps post-chi shanten equivalent to array removal")
	var post_claim_after = pressure_chi_hand.duplicate()
	scene.remove_tile_list(post_claim_after, pressure_chi_choice.get("needed", []))
	var post_claim_after_before = post_claim_after.duplicate()
	var chi_after_counts_before_post_eval = chi_after_counts.duplicate()
	var baseline_post_claim = scene.best_ai_post_claim_discard_report(2, post_claim_after, scene.players[2]["melds"].size() + 1)
	var post_claim_context = scene.make_ai_evaluation_context(2, scene.visible_tile_counts())
	var seeded_post_claim_pressure = scene.ai_pressure_context(2, post_claim_context)
	seeded_post_claim_pressure["sentinel"] = 77
	post_claim_context["pressure_context"] = seeded_post_claim_pressure
	var cached_post_claim = scene.best_ai_post_claim_discard_report(2, post_claim_after, scene.players[2]["melds"].size() + 1, post_claim_context)
	var counted_post_claim = scene.best_ai_post_claim_discard_report(2, post_claim_after, scene.players[2]["melds"].size() + 1, post_claim_context, chi_after_counts)
	var post_claim_risk_cache: Dictionary = post_claim_context.get("risk_vectors", {})
	var post_claim_safety_cache: Dictionary = post_claim_context.get("safety_labels", {})
	check(str(cached_post_claim.get("tile", "")) == str(baseline_post_claim.get("tile", "")) and is_equal_approx(float(cached_post_claim.get("score", 0.0)), float(baseline_post_claim.get("score", 0.0))), "post-claim discard evaluation reuses AI context without changing the best discard")
	check(str(counted_post_claim.get("tile", "")) == str(cached_post_claim.get("tile", "")) and is_equal_approx(float(counted_post_claim.get("score", 0.0)), float(cached_post_claim.get("score", 0.0))), "post-claim discard evaluation can reuse post-claim hand counts without changing the best discard")
	check(scene.same_tile_list(post_claim_after, post_claim_after_before) and chi_after_counts == chi_after_counts_before_post_eval, "post-claim discard evaluation reuses working hand and count arrays without mutating inputs")
	check(int(post_claim_context.get("pressure_context", {}).get("sentinel", 0)) == 77, "post-claim discard evaluation keeps the precomputed pressure context")
	check(post_claim_risk_cache.size() > 0 and post_claim_safety_cache.size() > 0, "post-claim discard evaluation fills shared risk and safety caches")
	var post_claim_risk_cache_size = post_claim_risk_cache.size()
	scene.best_ai_post_claim_discard_report(2, post_claim_after, scene.players[2]["melds"].size() + 1, post_claim_context)
	check(post_claim_risk_cache.size() == post_claim_risk_cache_size, "post-claim discard evaluation reuses cached risk vectors on repeated checks")
	var pressure_chi_claim = scene.choose_ai_claim(1, "3W")
	check(str(pressure_chi_claim.get("claim", "")) == "chi" and int(pressure_chi_claim.get("seat", -1)) == 2, "AI chooses pressure chi when it improves shanten")
	var grouped_hand = ["1W", "2W", "1T", "2T", "1B", "E", "P", "H1"]
	check(scene.hand_group_index("1W") == 0 and scene.hand_group_index("1T") == 1 and scene.hand_group_index("1B") == 2, "hand groups number suits")
	check(scene.hand_group_index("E") == scene.hand_group_index("P"), "hand groups honor tiles together")
	check(scene.hand_group_index("H1") > scene.hand_group_index("E"), "hand groups flowers after honors")
	check(not scene.should_insert_hand_group_gap(grouped_hand, 1), "hand group gap is skipped inside a suit")
	check(scene.should_insert_hand_group_gap(grouped_hand, 2), "hand group gap appears between suits")
	check(scene.should_insert_hand_group_gap(grouped_hand, 5), "hand group gap appears before honors")
	check(scene.should_insert_hand_group_gap(grouped_hand, 7), "hand group gap appears before flowers")
	var spacer = scene.make_hand_group_spacer(84.0)
	check(spacer.custom_minimum_size.x >= 10.0 and spacer.find_child("HandGroupDividerCap", true, false) != null, "hand group spacer has stable width and divider")
	spacer.queue_free()
	var crowded_hand = ["1W", "2W", "3W", "4W", "1T", "2T", "3T", "1B", "2B", "3B", "E", "S", "P", "H1"]
	var narrow_hand_content = Vector2(960.0 * 0.840 * 0.970, 540.0 * 0.220 * 0.810)
	check(scene.HAND_LAYOUT_CANDIDATES.size() == 4 and float(scene.HAND_LAYOUT_CANDIDATES[0][0]) == 12.0 and int(scene.HAND_LAYOUT_CANDIDATES[3][1]) == 1, "hand layout reuses fixed spacing candidates")
	var crowded_hand_layout = scene.hand_layout_metrics_for_content(crowded_hand, narrow_hand_content)
	check(scene.hand_layout_fits_content(crowded_hand, crowded_hand_layout), "crowded 14-tile hand layout fits a narrow landscape tray")
	check(float(crowded_hand_layout.get("tile_width", 0.0)) >= scene.HAND_TILE_MIN_TOUCH_WIDTH, "crowded hand keeps a practical touch width on narrow landscape")
	check(int(crowded_hand_layout.get("separation", 9)) <= 3 and float(crowded_hand_layout.get("group_gap_width", 99.0)) <= 8.0, "crowded hand reduces spacing before shrinking tiles too far")
	var narrow_action_width = 960.0 * (0.975 - 0.305)
	check(scene.action_buttons_fit_available(8, narrow_action_width), "eight action buttons fit inside a narrow action bar")
	check(scene.action_button_width_for_available(8, narrow_action_width) >= scene.ACTION_BUTTON_MIN_TOUCH_WIDTH, "crowded action bar keeps practical button width")
	var action_layout_parent = Control.new()
	root.add_child(action_layout_parent)
	scene.action_bar = HBoxContainer.new()
	action_layout_parent.add_child(scene.action_bar)
	var action_press_count := {"value": 0}
	for label in ["吃123万", "吃234万", "吃345万", "碰", "杠", "胡", "过", "语音"]:
		scene.action_bar.add_child(scene.make_action_button(label, Color(0.25, 0.58, 0.48), func() -> void:
			action_press_count["value"] = int(action_press_count.get("value", 0)) + 1
		))
	check(scene.action_bar_button_count() == 8, "action bar layout counts buttons without building a button list")
	scene.finalize_action_bar_layout()
	var crowded_action_button = first_button(action_layout_parent)
	check(crowded_action_button != null and crowded_action_button.custom_minimum_size.x <= scene.ACTION_BUTTON_MAX_WIDTH and crowded_action_button.clip_text, "crowded action buttons are sized and clipped by final layout")
	crowded_action_button.emit_signal("button_down")
	check(int(action_press_count.get("value", 0)) == 1, "finalized action buttons still run callbacks on button down")
	action_layout_parent.queue_free()
	scene.action_bar = null

	scene.players[0]["flowers"] = 2
	var score = scene.calculate_win_score(0, "", true)
	check(int(score.get("fan", 0)) >= 4, "flowers are counted in score")
	check(scene.deal_in_risk_score("5W", 0) > scene.deal_in_risk_score("1W", 0), "middle tiles carry higher deal-in risk")
	scene.players[0]["flowers"] = 0
	scene.players[0]["melds"] = []
	scene.players[0]["hand"] = pure_one_suit_hand()
	var pure_score = scene.calculate_win_score(0, "", false)
	check(pure_score.get("reasons", []).has("清一色"), "pure one suit is scored")
	scene.players[0]["hand"] = mixed_one_suit_hand()
	var mixed_score = scene.calculate_win_score(0, "", false)
	check(mixed_score.get("reasons", []).has("混一色"), "mixed one suit is scored")
	check(not mixed_score.get("reasons", []).has("清一色"), "mixed one suit is not pure one suit")
	scene.players[0]["hand"] = full_straight_hand()
	var dragon_score = scene.calculate_win_score(0, "", false)
	check(dragon_score.get("reasons", []).has("一条龙"), "full straight is scored")
	scene.players[0]["hand"] = all_simples_hand()
	var simples_score = scene.calculate_win_score(0, "", false)
	check(simples_score.get("reasons", []).has("断幺九"), "all-simples hand is scored")
	scene.players[0]["hand"] = big_three_dragons_hand()
	var big_three_score = scene.calculate_win_score(0, "", false)
	check(big_three_score.get("reasons", []).has("大三元"), "big three dragons is scored")
	scene.players[0]["hand"] = small_three_dragons_hand()
	var small_three_score = scene.calculate_win_score(0, "", false)
	check(small_three_score.get("reasons", []).has("小三元"), "small three dragons is scored")
	scene.players[0]["hand"] = big_four_winds_hand()
	var big_four_score = scene.calculate_win_score(0, "", false)
	check(big_four_score.get("reasons", []).has("大四喜"), "big four winds is scored")
	scene.players[0]["hand"] = small_four_winds_hand()
	var small_four_score = scene.calculate_win_score(0, "", false)
	check(small_four_score.get("reasons", []).has("小四喜"), "small four winds is scored")
	scene.players[0]["hand"] = all_triplet_hand()
	var triplet_score = scene.calculate_win_score(0, "", false)
	check(triplet_score.get("reasons", []).has("碰碰胡"), "all triplets are scored")
	scene.players[0]["hand"] = all_honor_hand()
	var honor_score = scene.calculate_win_score(0, "", false)
	check(honor_score.get("reasons", []).has("字一色"), "all honors are scored")
	check(scene.score_points_for_fan(1) == 200, "score table one fan is correct")
	check(scene.score_points_for_fan(8) == 25600, "score table limit fan is correct")
	check(scene.score_points_for_fan(12) == 25600, "score table caps above limit")
	scene.players[0]["hand"] = winning_hand()
	scene.players[0]["melds"] = []
	scene.offline_last_draw = {"seat": 0, "source": "gang", "wall_empty": false}
	var gang_flower_score = scene.calculate_win_score(0, "", true)
	check(gang_flower_score.get("reasons", []).has("杠上开花"), "gang draw win is scored")
	scene.offline_last_draw = {"seat": 0, "source": "normal", "wall_empty": true}
	var final_draw_score = scene.calculate_win_score(0, "", true)
	check(final_draw_score.get("reasons", []).has("海底捞月"), "final draw win is scored")
	scene.players[0]["melds"] = [
		["1W", "1W", "1W"],
		["2T", "2T", "2T"],
		["3B", "3B", "3B"],
		["E", "E", "E"],
	]
	scene.players[0]["hand"] = ["P", "P"]
	var single_wait_score = scene.calculate_win_score(0, "", false)
	check(single_wait_score.get("reasons", []).has("大吊车"), "single pair after four melds is scored")
	check(scene.is_newer_version("1.0.26-godot", "1.0.25-godot"), "newer manifest version is detected")
	check(not scene.is_newer_version("1.0.25-godot", "1.0.25-godot"), "same manifest version is current")
	check(scene.tail_window_start(10, 3) == 7 and scene.tail_window_start(2, 8) == 0 and scene.tail_window_start(5, 0) == 5, "tail window helper avoids slice allocations with stable bounds")
	check(scene.join_tail_lines(["一", "二", "三", "四"], 2) == "三\n四" and scene.join_tail_lines(["一"], 4) == "一" and scene.join_tail_lines(["一"], 0) == "", "tail line join helper builds recent log text without temporary line arrays")
	var manifest = scene.parse_update_manifest({
		"version": "1.0.26-godot",
		"apkUrl": "https://example.com/YunzhuoMahjongGodot.apk",
		"apkSize": 123456,
		"sha256": "abc123",
		"releaseNotes": ["AI 优化", "UI 优化"],
	})
	check(str(manifest.get("url", "")) == "https://example.com/YunzhuoMahjongGodot.apk", "manifest apkUrl is parsed")
	check(str(manifest.get("notes", "")).find("AI 优化") >= 0, "manifest notes are parsed")
	check(int(manifest.get("size", 0)) == 123456, "manifest apk size is parsed")
	check(str(manifest.get("sha256", "")) == "abc123", "manifest sha is parsed")
	scene.update_release_notes = "第一条更新说明内容很长需要在更新弹窗里截断避免撑破布局\n第二条 UI 优化\n第三条 E2E 校验"
	var notes_summary = scene.update_release_notes_summary()
	check(notes_summary.find("第三条") < 0 and notes_summary.find("等3项") >= 0, "update dialog release notes are summarized")
	check(notes_summary.length() <= 56, "update dialog release notes summary stays compact")
	check(scene.safe_filename_part("1.0.26-godot 测试") == "1.0.26-godot___", "unsafe update filename chars are replaced")
	var hash_path = "user://offline-smoke-sha.bin"
	var hash_file = FileAccess.open(hash_path, FileAccess.WRITE)
	hash_file.store_buffer(PackedByteArray([97, 98, 99]))
	hash_file.close()
	var abc_sha = "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"
	check(scene.file_sha256(hash_path) == abc_sha, "download hash helper computes SHA-256")
	check(scene.is_valid_sha256(abc_sha), "valid SHA-256 is accepted")
	check(not scene.is_valid_sha256("abc123"), "short SHA-256 is rejected")
	scene.update_file_path = hash_path
	scene.update_remote_sha256 = "0000000000000000000000000000000000000000000000000000000000000000"
	check(not scene.verify_downloaded_update(), "download hash mismatch is rejected")
	check(not FileAccess.file_exists(hash_path), "bad downloaded update file is removed")
	hash_file = FileAccess.open(hash_path, FileAccess.WRITE)
	hash_file.store_buffer(PackedByteArray([97, 98, 99]))
	hash_file.close()
	scene.update_file_path = hash_path
	scene.update_remote_sha256 = abc_sha
	check(scene.verify_downloaded_update(), "matching downloaded update hash is accepted")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(hash_path))
	var online_state = scene.normalize_online_game_state({
		"type": "gameState",
		"game": {
			"room_code": "ROOM9",
			"playerSeat": 2,
			"turnSeat": 2,
			"state": "await_discard",
			"yourHand": [{"tile": "1W"}, "2W"],
			"wallRemaining": 55,
			"lastDiscard": {"tile": "5T", "seat": 1},
			"claimOptions": [{"claim": "胡"}, {"action": "chi"}, "pass"],
			"chiChoices": [
				["3T", "4T", "5T"],
				{"meld": ["4T", "5T", "6T"], "needed": ["4T", "6T"]},
			],
			"players": [
				{
					"index": 2,
					"nickname": "测试玩家",
					"tiles": ["1W", "2W"],
					"flowers": ["H1", "H2"],
					"river": ["E"],
					"sets": [{"tiles": ["3W", "4W", "5W"]}],
					"points": 26000,
				}
			],
		},
	})
	check(str(online_state.get("roomCode", "")) == "ROOM9", "online room code alias is normalized")
	check(int(online_state.get("youSeat", -1)) == 2, "online player seat alias is normalized")
	check(str(online_state.get("phase", "")) == "awaitDiscard", "online phase alias is normalized")
	check(str(online_state.get("lastDiscard", "")) == "5T", "nested last discard tile is normalized")
	check(int(online_state.get("lastDiscardSeat", -1)) == 1, "nested last discard seat is normalized")
	check(online_state.get("hand", []).size() == 2, "online hand aliases are normalized")
	check(online_state.get("pending", {}).get("options", []).has("hu"), "online claim option text is normalized")
	check(online_state.get("pending", {}).get("options", []).has("chi"), "online chi option object is normalized")
	check(online_state.get("pending", {}).get("chi_choices", []).size() == 2, "online chi choices are normalized")
	check(scene.chi_choice_label(online_state.get("pending", {}).get("chi_choices", [])[0]) == "吃345条", "online chi choice label is compact")
	var online_chi_payload = scene.online_claim_payload("chi", online_state.get("pending", {}).get("chi_choices", [])[1])
	check(str(online_chi_payload.get("claim", "")) == "chi", "online chi payload keeps claim")
	check(online_chi_payload.get("meld", []).size() == 3 and online_chi_payload.get("needed", []).size() == 2, "online chi payload includes meld and needed tiles")
	check(scene.normalize_online_message_kind({"type": "game_state"}) == "gameState", "online game state type alias is normalized")
	check(scene.normalize_online_message_kind({"event": "actionRejected"}) == "error", "online rejected event alias is normalized")
	check(scene.normalize_online_message_kind({"type": "actionAck"}) == "ack", "online ack type alias is normalized")
	check(scene.normalize_online_message_kind({"type": "message"}) == "info", "online plain message type is treated as info")
	scene.online_last_sent_action = "打出五条"
	scene.online_waiting_for_server = true
	scene.handle_online_message(JSON.stringify({"type": "actionAck"}))
	check(not scene.online_waiting_for_server and scene.online_feedback.find("确认") >= 0, "online ack clears waiting feedback")
	scene.handle_online_message(JSON.stringify({"event": "actionRejected", "reason": "不是你的回合"}))
	check(not scene.online_waiting_for_server and scene.online_feedback.find("不是你的回合") >= 0, "online rejection keeps server reason visible")
	scene.handle_online_message(JSON.stringify({"type": "message", "message": "服务器维护"}))
	check(scene.online_feedback.find("服务器维护") >= 0, "online plain server message remains visible")
	scene.online_room = {"code": "ROOM9", "players": [], "logs": []}
	scene.handle_online_message(JSON.stringify({"type": "roomLog", "text": "玩家加入房间"}))
	check(scene.online_room.get("logs", []).has("玩家加入房间"), "online room log event is appended")
	scene.handle_online_message(JSON.stringify({"type": "room_update", "roomCode": "ROOM8", "players": [], "logs": []}))
	check(scene.selected_room == "ROOM8", "online room update alias refreshes selected room")
	scene.mode = "online_game"
	scene.online_game = online_state
	check(scene.can_self_discard(), "normalized online state allows self discard")
	check(scene.get_wall_count() == 55, "normalized online wall count is used")
	check(scene.get_player_info(2).get("flowers", 0) == 2, "online flower array is counted")
	check(scene.get_discards(2).size() == 1 and scene.get_melds(2).size() == 1, "online discards and melds are normalized")
	scene.speech_queue.clear()
	scene.speech_queue_active = false
	scene.online_game = {}
	scene.online_announced_discard_key = ""
	scene.announce_online_game_audio(online_state)
	check(scene.speech_queue.is_empty() and scene.online_announced_discard_key != "", "initial online snapshot records discard without stale speech")
	var previous_online_audio_state = scene.normalize_online_game_state({
		"type": "gameState",
		"game": {
			"roomCode": "ROOM9",
			"youSeat": 2,
			"lastDiscard": "4T",
			"lastDiscardSeat": 1,
			"players": [{"seat": 1, "name": "上家", "discards": ["4T"]}],
		},
	})
	var next_online_audio_state = scene.normalize_online_game_state({
		"type": "gameState",
		"game": {
			"roomCode": "ROOM9",
			"youSeat": 2,
			"lastDiscard": "5T",
			"lastDiscardSeat": 1,
			"players": [{"seat": 1, "name": "上家", "discards": ["4T", "5T"]}],
		},
	})
	scene.online_game = previous_online_audio_state
	scene.online_announced_discard_key = scene.online_discard_audio_key(previous_online_audio_state)
	scene.speech_queue.clear()
	scene.announce_online_game_audio(next_online_audio_state)
	check(scene.speech_queue.size() == 1 and str(scene.speech_queue[0].get("text", "")) == "五条", "new online discard is queued for tile speech")
	var self_confirm_audio_state = scene.normalize_online_game_state({
		"type": "gameState",
		"game": {
			"roomCode": "ROOM9",
			"youSeat": 2,
			"lastDiscard": "7B",
			"lastDiscardSeat": 2,
			"players": [{"seat": 2, "name": "测试玩家", "discards": ["E", "7B"]}],
		},
	})
	scene.online_game = previous_online_audio_state
	scene.online_announced_discard_key = scene.online_discard_audio_key(previous_online_audio_state)
	scene.online_pending_local_discard_identity = scene.online_discard_identity(2, "7B")
	scene.speech_queue.clear()
	scene.announce_online_game_audio(self_confirm_audio_state)
	check(scene.speech_queue.is_empty() and scene.online_pending_local_discard_identity == "", "server echo of local discard does not duplicate speech")
	scene.speech_queue.clear()
	scene.online_game = {"youSeat": 2}
	scene.play_outgoing_online_action_audio({"type": "discard", "tile": "7B"})
	check(scene.online_pending_local_discard_identity == scene.online_discard_identity(2, "7B"), "outgoing online discard marks pending speech identity")
	check(scene.speech_queue.size() == 1 and str(scene.speech_queue[0].get("text", "")) == "七筒", "outgoing online discard queues tile speech immediately")
	scene.speech_queue.clear()
	var voice_frames = PackedVector2Array()
	voice_frames.append(Vector2(-1.0, -1.0))
	voice_frames.append(Vector2(0.0, 0.0))
	voice_frames.append(Vector2(1.0, 1.0))
	var encoded_voice = scene.encode_voice_frames(voice_frames)
	check(int(encoded_voice.get("bytes", 0)) == 6, "voice pcm16 byte size is correct")
	check(float(encoded_voice.get("peak", 0.0)) == 1.0, "voice peak is detected")
	var voice_payload = scene.build_voice_payload(voice_frames)
	check(str(voice_payload.get("type", "")) == "voiceMessage", "voice payload type is correct")
	check(int(voice_payload.get("sequence", -1)) == 0, "voice sequence starts at zero")
	var next_voice_payload = scene.build_voice_payload(voice_frames)
	check(int(next_voice_payload.get("sequence", -1)) == 1, "voice sequence increments")
	var voice_stream = scene.make_voice_stream(str(voice_payload.get("audio", "")), 16000, 1)
	check(voice_stream != null and voice_stream.data.size() == 6, "voice wav stream is created")

	scene.start_offline(true)
	scene.record_claim_source(1, 0, "chi")
	scene.record_claim_source(1, 0, "peng")
	scene.record_claim_source(1, 0, "gang")
	check(scene.package_payer_for(1) == 0, "third claim creates package liability")
	var payer_before = int(scene.players[0]["score"])
	var winner_before = int(scene.players[1]["score"])
	var other_before = int(scene.players[2]["score"])
	scene.players[1]["hand"] = winning_hand()
	scene.players[1]["melds"] = []
	var package_points = int(scene.calculate_win_score(1, "", true).get("points", 0)) * 3
	scene.finish_offline_round(1, "E", true, -1)
	check(int(scene.players[0]["score"]) == payer_before - package_points, "package payer covers all self draw payments")
	check(int(scene.players[1]["score"]) == winner_before + package_points, "package winner receives package payment")
	check(int(scene.players[2]["score"]) == other_before, "non-package opponent does not pay")
	check(scene.round_summary.find("包三搭") >= 0, "round summary mentions package liability")
	check(int(scene.last_score_deltas[0]) == -package_points and int(scene.last_score_deltas[1]) == package_points, "score deltas track package payment")
	check(scene.score_delta_text(1).begins_with(" +"), "positive score delta is formatted")
	check(scene.score_delta_text(0).find("-") >= 0, "negative score delta is formatted")
	check(scene.compact_score_text(98860) == "9.9万" and scene.compact_score_text(-172000) == "-17万", "compact score text keeps large UI scores short")

	scene.start_offline(true)
	scene.record_claim_source(1, 0, "chi")
	scene.record_claim_source(1, 0, "peng")
	scene.record_claim_source(1, 0, "gang")
	payer_before = int(scene.players[0]["score"])
	winner_before = int(scene.players[1]["score"])
	other_before = int(scene.players[2]["score"])
	scene.players[1]["hand"] = winning_hand()
	scene.players[1]["melds"] = []
	var discard_points = int(scene.calculate_win_score(1, "E", false).get("points", 0)) * 3
	scene.finish_offline_round(1, "E", false, 2)
	check(int(scene.players[2]["score"]) == other_before - discard_points, "discarder pays discard win despite package liability")
	check(int(scene.players[1]["score"]) == winner_before + discard_points, "winner receives discard payment despite package liability")
	check(int(scene.players[0]["score"]) == payer_before, "package payer does not cover discard win")
	check(scene.round_summary.find("包三搭") == -1, "discard win summary does not mention package payout")

	scene.start_offline(true)
	scene.offline_hand_number = 1
	scene.dealer_seat = 0
	scene.offline_dealer_repeat = false
	scene.players[1]["hand"] = winning_hand()
	scene.players[1]["melds"] = []
	scene.finish_offline_round(1, "E", false, 0)
	var winner_score = int(scene.players[1]["score"])
	check(scene.offline_phase == "ended", "round ends after win")
	check(not scene.offline_dealer_repeat, "dealer steps down after non-dealer win")
	check(scene.score_delta_text(1).find("+") >= 0 and scene.score_delta_text(0).find("-") >= 0, "round summary deltas include winner and payer changes")
	scene.start_next_offline_hand(false)
	check(scene.offline_hand_number == 2, "next hand increments hand number")
	check(scene.dealer_seat == 1, "dealer rotates to winner side")
	check(int(scene.players[1]["score"]) == winner_score, "scores persist across hands")

	scene.players[1]["hand"] = winning_hand()
	scene.players[1]["melds"] = []
	scene.finish_offline_round(1, "E", true, -1)
	var repeated_hand = scene.offline_hand_number
	check(scene.offline_dealer_repeat, "dealer repeats after dealer win")
	scene.start_next_offline_hand(false)
	check(scene.offline_hand_number == repeated_hand, "dealer repeat keeps hand number")
	check(scene.dealer_seat == 1, "dealer repeat keeps dealer")

	scene.offline_hand_number = 8
	scene.dealer_seat = 0
	scene.players[1]["hand"] = winning_hand()
	scene.players[1]["melds"] = []
	scene.finish_offline_round(1, "E", false, 0)
	check(scene.is_offline_match_finished(), "match finishes after final non-repeat hand")
	scene.start_next_offline_hand(false)
	check(scene.offline_hand_number == 8, "finished match does not advance")
	scene.queue_free()
	await process_frame
	await process_frame
	await process_frame
	quit(1 if failed else 0)

func check(condition: bool, message: String) -> void:
	if condition:
		return
	failed = true
	push_error("offline smoke test failed: " + message)

func count_descendants(node: Node) -> int:
	var count = 0
	for child in node.get_children():
		count += 1
		count += count_descendants(child)
	return count

func pcm16_peak(data: PackedByteArray) -> int:
	var peak = 0
	for i in range(0, data.size() - 1, 2):
		var sample = int(data[i]) | (int(data[i + 1]) << 8)
		if sample >= 32768:
			sample -= 65536
		peak = max(peak, abs(sample))
	return peak

func has_label_text(node: Node, text: String) -> bool:
	if node is Label and str((node as Label).text) == text:
		return true
	for child in node.get_children():
		if has_label_text(child, text):
			return true
	return false

func first_label_with_text_prefix(node: Node, prefix: String) -> Label:
	if node is Label and str((node as Label).text).begins_with(prefix):
		return node as Label
	for child in node.get_children():
		var label = first_label_with_text_prefix(child, prefix)
		if label != null:
			return label
	return null

func first_label_containing_text(node: Node, text: String) -> Label:
	if node is Label and str((node as Label).text).find(text) >= 0:
		return node as Label
	for child in node.get_children():
		var label = first_label_containing_text(child, text)
		if label != null:
			return label
	return null

func label_is_clipped(label: Label) -> bool:
	return label != null and label.clip_text and label.autowrap_mode == TextServer.AUTOWRAP_OFF and label.text_overrun_behavior == TextServer.OVERRUN_TRIM_ELLIPSIS

func count_label_nodes(node: Node) -> int:
	var total = 1 if node is Label else 0
	for child in node.get_children():
		total += count_label_nodes(child)
	return total

func count_named_nodes(node: Node, node_name: String) -> int:
	var total = 1 if node.name == node_name else 0
	for child in node.get_children():
		total += count_named_nodes(child, node_name)
	return total

func count_nodes_with_name_prefix(node: Node, prefix: String) -> int:
	var total = 1 if str(node.name).begins_with(prefix) else 0
	for child in node.get_children():
		total += count_nodes_with_name_prefix(child, prefix)
	return total

func count_labels_with_exact_text(node: Node, text: String) -> int:
	var total = 0
	if node is Label and str((node as Label).text) == text:
		total += 1
	for child in node.get_children():
		total += count_labels_with_exact_text(child, text)
	return total

func labels_ignore_mouse(node: Node) -> bool:
	if node is Label and (node as Control).mouse_filter != Control.MOUSE_FILTER_IGNORE:
		return false
	for child in node.get_children():
		if not labels_ignore_mouse(child):
			return false
	return true

func panels_ignore_mouse(node: Node) -> bool:
	if node is Panel and (node as Control).mouse_filter != Control.MOUSE_FILTER_IGNORE:
		return false
	for child in node.get_children():
		if not panels_ignore_mouse(child):
			return false
	return true

func containers_ignore_mouse(node: Node) -> bool:
	if (node is HBoxContainer or node is VBoxContainer or node is GridContainer) and (node as Control).mouse_filter != Control.MOUSE_FILTER_IGNORE:
		return false
	for child in node.get_children():
		if not containers_ignore_mouse(child):
			return false
	return true

func count_control_nodes(node: Node) -> int:
	var total = 1 if node is Control else 0
	for child in node.get_children():
		total += count_control_nodes(child)
	return total

func has_button_text(node: Node, text: String) -> bool:
	if node is Button and str((node as Button).text) == text:
		return true
	for child in node.get_children():
		if has_button_text(child, text):
			return true
	return false

func first_button_with_text(node: Node, text: String) -> Button:
	if node is Button and str((node as Button).text) == text:
		return node as Button
	for child in node.get_children():
		var button = first_button_with_text(child, text)
		if button != null:
			return button
	return null

func count_button_text_prefix(node: Node, prefix: String) -> int:
	var count = 0
	if node is Button and str((node as Button).text).begins_with(prefix):
		count += 1
	for child in node.get_children():
		count += count_button_text_prefix(child, prefix)
	return count

func unique_tile_count(tiles: Array) -> int:
	var seen := {}
	for item in tiles:
		seen[str(item)] = true
	return seen.size()

func first_button(node: Node) -> Button:
	if node is Button:
		return node as Button
	for child in node.get_children():
		var button = first_button(child)
		if button != null:
			return button
	return null

func contains_subviewport(node: Node) -> bool:
	if node is SubViewport or node is SubViewportContainer:
		return true
	for child in node.get_children():
		if contains_subviewport(child):
			return true
	return false

func tile_texture_rects_are_bounded(node: Node) -> bool:
	if node is TextureRect:
		var texture_rect = node as TextureRect
		if texture_rect.expand_mode != TextureRect.EXPAND_IGNORE_SIZE:
			return false
		if texture_rect.stretch_mode != TextureRect.STRETCH_KEEP_ASPECT_CENTERED:
			return false
	for child in node.get_children():
		if not tile_texture_rects_are_bounded(child):
			return false
	return true

func has_visible_tile_art(node: Node) -> bool:
	if node is TextureRect:
		var texture_rect = node as TextureRect
		if texture_rect.texture != null and texture_rect.visible and texture_rect.modulate.a > 0.0:
			return true
	for child in node.get_children():
		if has_visible_tile_art(child):
			return true
	return false

func texture_rects_ignore_mouse(node: Node) -> bool:
	if node is TextureRect and (node as Control).mouse_filter != Control.MOUSE_FILTER_IGNORE:
		return false
	for child in node.get_children():
		if not texture_rects_ignore_mouse(child):
			return false
	return true

func color_rects_ignore_mouse(node: Node) -> bool:
	if node is ColorRect and (node as Control).mouse_filter != Control.MOUSE_FILTER_IGNORE:
		return false
	for child in node.get_children():
		if not color_rects_ignore_mouse(child):
			return false
	return true

func tile_view_inner_frame_is_fixed(node: Node, expected: Vector2) -> bool:
	if not (node is Control):
		return false
	if (node as Control).custom_minimum_size != expected:
		return false
	for child in node.get_children():
		if child is Button or child is Panel:
			var inner = child as Control
			return inner.custom_minimum_size == expected and control_offsets_match_size(inner, expected)
	return false

func count_panel_shadow_size(node: Node, shadow_size: int) -> int:
	var total = 0
	if node is Panel and panel_shadow_size(node) == shadow_size:
		total += 1
	for child in node.get_children():
		total += count_panel_shadow_size(child, shadow_size)
	return total

func panel_shadow_size(node: Node) -> int:
	if not (node is Panel):
		return -1
	var box = (node as Panel).get_theme_stylebox("panel")
	if box is StyleBoxFlat:
		return (box as StyleBoxFlat).shadow_size
	return -1

func count_texture_rects(node: Node) -> int:
	var total = 1 if node is TextureRect else 0
	for child in node.get_children():
		total += count_texture_rects(child)
	return total

func count_color_rects(node: Node) -> int:
	var total = 1 if node is ColorRect else 0
	for child in node.get_children():
		total += count_color_rects(child)
	return total

func control_offsets_match_size(control: Control, expected: Vector2) -> bool:
	return is_equal_approx(control.offset_right - control.offset_left, expected.x) and is_equal_approx(control.offset_bottom - control.offset_top, expected.y)

func control_anchor_rect_matches(control: Control, expected: Rect2) -> bool:
	if control == null:
		return false
	return is_equal_approx(control.anchor_left, expected.position.x) and is_equal_approx(control.anchor_top, expected.position.y) and is_equal_approx(control.anchor_right, expected.size.x) and is_equal_approx(control.anchor_bottom, expected.size.y)

func winning_hand() -> Array:
	return [
		"1W", "1W", "1W",
		"2W", "3W", "4W",
		"5W", "6W", "7W",
		"2T", "3T", "4T",
		"E", "E",
	]

func tenpai_hand() -> Array:
	return [
		"1W", "1W", "1W",
		"2W", "3W", "4W",
		"5W", "6W", "7W",
		"2T", "3T", "4T",
		"E",
	]

func thirteen_orphans_hand() -> Array:
	return [
		"1W", "9W",
		"1T", "9T",
		"1B", "9B",
		"E", "S", "N", "R", "Z", "F", "P",
		"1W",
	]

func seven_pairs_hand() -> Array:
	return [
		"1W", "1W",
		"2W", "2W",
		"3T", "3T",
		"4T", "4T",
		"5B", "5B",
		"E", "E",
		"P", "P",
	]

func seven_pairs_route_hand() -> Array:
	return [
		"1W", "1W",
		"2W", "2W",
		"3T", "3T",
		"4T", "4T",
		"5B", "5B",
		"E", "E",
		"8T", "9B",
	]

func seven_pairs_concealed_gang_hand() -> Array:
	return [
		"E", "E", "E", "E",
		"1W", "1W",
		"2W", "2W",
		"3T", "3T",
		"4T", "4T",
		"8T", "9B",
	]

func seven_pairs_claim_hand() -> Array:
	return [
		"1W", "1W",
		"2W", "2W",
		"3T", "3T",
		"4T", "4T",
		"5B", "5B",
		"E", "E",
		"8T",
	]

func thirteen_orphans_unique_tenpai() -> Array:
	return [
		"1W", "9W",
		"1T", "9T",
		"1B", "9B",
		"E", "S", "N", "R", "Z", "F", "P",
	]

func thirteen_orphans_missing_pair_tenpai() -> Array:
	return [
		"1W", "9W",
		"1T", "9T",
		"1B", "9B",
		"E", "E", "S", "N", "R", "Z", "F",
	]

func thirteen_orphans_route_hand() -> Array:
	return [
		"1W", "9W",
		"1T", "9T",
		"1B", "9B",
		"E", "S", "N", "R", "Z", "F",
		"2W",
	]

func waits_for_3w_hand() -> Array:
	return [
		"1T", "1T", "1T",
		"2T", "3T", "4T",
		"5T", "6T", "7T",
		"2B", "3B", "4B",
		"3W",
	]

func ai_shape_hand() -> Array:
	return [
		"1W", "1W",
		"2W", "3W", "4W",
		"5W", "6W", "7W",
		"2T", "3T", "4T",
		"5B", "6B",
		"E",
	]

func pure_one_suit_hand() -> Array:
	return [
		"1W", "1W", "1W",
		"2W", "3W", "4W",
		"4W", "5W", "6W",
		"6W", "7W", "8W",
		"9W", "9W",
	]

func mixed_one_suit_hand() -> Array:
	return [
		"1W", "1W", "1W",
		"2W", "3W", "4W",
		"4W", "5W", "6W",
		"7W", "8W", "9W",
		"E", "E",
	]

func full_straight_hand() -> Array:
	return [
		"1W", "2W", "3W",
		"4W", "5W", "6W",
		"7W", "8W", "9W",
		"2T", "3T", "4T",
		"E", "E",
	]

func full_straight_route_hand() -> Array:
	return [
		"1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W",
		"2T", "3T", "4T",
		"E", "P",
	]

func all_simples_hand() -> Array:
	return [
		"2W", "3W", "4W",
		"3W", "4W", "5W",
		"4T", "5T", "6T",
		"6B", "7B", "8B",
		"2T", "2T",
	]

func all_simples_route_hand() -> Array:
	return [
		"2W", "3W", "4W", "5W", "6W",
		"3T", "4T", "5T",
		"4B", "5B", "6B", "7B",
		"E",
	]

func big_three_dragons_hand() -> Array:
	return [
		"Z", "Z", "Z",
		"F", "F", "F",
		"P", "P", "P",
		"2W", "3W", "4W",
		"5T", "5T",
	]

func small_three_dragons_hand() -> Array:
	return [
		"Z", "Z", "Z",
		"F", "F", "F",
		"P", "P",
		"2W", "3W", "4W",
		"5T", "6T", "7T",
	]

func small_three_dragons_route_hand() -> Array:
	return [
		"Z", "Z", "Z",
		"F", "F", "F",
		"P", "P",
		"2W", "3W", "4W",
		"5T", "6T",
		"9B",
	]

func big_four_winds_hand() -> Array:
	return [
		"E", "E", "E",
		"S", "S", "S",
		"N", "N", "N",
		"R", "R", "R",
		"5W", "5W",
	]

func small_four_winds_hand() -> Array:
	return [
		"E", "E", "E",
		"S", "S", "S",
		"N", "N", "N",
		"R", "R",
		"2W", "3W", "4W",
	]

func all_triplet_hand() -> Array:
	return [
		"1W", "1W", "1W",
		"2T", "2T", "2T",
		"3B", "3B", "3B",
		"E", "E", "E",
		"P", "P",
	]

func all_honor_hand() -> Array:
	return [
		"E", "E", "E",
		"S", "S", "S",
		"N", "N", "N",
		"R", "R", "R",
		"Z", "Z",
	]
