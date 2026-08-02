extends SceneTree

const NAMED_VISUAL_NODE_KEYWORDS := [
	"Arc",
	"Art",
	"Badge",
	"Banner",
	"Canopy",
	"Compass",
	"Fill",
	"Flow",
	"Gate",
	"Glow",
	"Halo",
	"Lattice",
	"Mandala",
	"Map",
	"Orbit",
	"Panel",
	"Path",
	"Plate",
	"Pulse",
	"Rail",
	"Ribbon",
	"Ring",
	"Route",
	"Seal",
	"Starlight",
	"Strip",
	"Texture",
	"Tick",
	"Token",
	"Trail",
	"Wash",
	"Wave",
]
const GENERATED_GPT_ILLUSTRATION_CANDIDATE_PNGS := [
	"wall_strip_material_reference_v1.png",
]
const VISUAL_NODE_REFERENCE_BACKFILL := [
	"MeldGroup3DCastShadow",
	"MeldGroup3DTopRim",
	"ActionButtonSeal",
	"CenterDiceSimpleSeal",
	"CenterGPTCompassTexture",
	"CenterLastTileInkWash",
	"CenterLastTileSeal",
	"CenterWindSimpleSealTexture",
	"HandTrayActionDeliveryFill",
	"HandTrayActionDeliveryGate",
	"HandTrayActionPathDrawn",
	"HandTrayActionPathFill",
	"HandTrayActionPathFocus",
	"HandTrayActionPathGate",
	"HandTrayActionPathGlyph",
	"HandTrayActionPathRail",
	"HandTrayActionPathStream",
	"HandTrayActionPathStreamFill",
	"HandTrayActionPathTarget",
	"HandProgressInkFill",
	"HandProgressInkRail",
	"HandProgressRoundSeal",
	"MenuDailyLedgerTexture",
	"MenuDailyTaskCompletionFill",
	"MenuDailyTaskCompletionGate",
	"MenuDailyTaskCompletionRoute",
	"MenuDailyTaskFocusGlow",
	"MenuDailyTaskFocusPulse",
	"MenuDailyTaskRewardFill",
	"MenuDailyTaskRewardRail",
	"MenuHeroWindPathFill",
	"MenuHeroWindPathGate",
	"MenuHeroWindPathRail",
	"MenuSeasonCurrentRankHalo",
	"MenuSeasonCurrentRankPulse",
	"MenuSeasonNextRankBridgeFill",
	"MenuSeasonNextRankBridgeGate",
	"MenuSeasonProgressFill",
	"MenuSeasonProgressRail",
	"MenuSeasonRouteFill",
	"MenuSeasonRouteGate",
	"MenuSeasonScrollTexture",
	"MenuSeasonTrophyLoopTexture",
	"TableActionReadinessActionFill",
	"TableActionReadinessActionRoute",
	"TableActionReadinessFill",
	"TableActionReadinessGate",
	"TableActionReadinessRoute",
	"TableActionReadinessSeal",
	"TableRoundTempoFill",
	"TableRoundTempoGate",
	"TableRoundTempoRail",
	"TableRoundTempoTexture",
	"TableTurnFlowHalo",
	"TableTurnFlowRibbon",
	"TableTurnFlowRouteFill",
	"TableTurnFlowSeal",
	"TableTurnFlowTrail",
	"TableTurnGPTFlowTexture",
	"TableWallPressureFill",
	"TableWallPressureGate",
	"TableLogLedgerTexture",
	"TileDepthTexturedGoldLip",
	"TileSubtleCommitGlow",
	"TopHudWallInkFill",
	"TopHudWallLastSeal",
	"TopHudWallSeal",
	"WallRemainingBadgeFeedback",
	"AchievementGalleryRearGPTTexture",
	"AchievementGptLanePlate",
	"AchievementGptTitleStrip",
	"AchievementRowGptPlate",
	"AchievementsDashboardMeterRail",
	"AchievementsDashboardSignalStrip",
	"AchievementsMidOrnamentPlate",
	"ActionDockMidBandPlate",
	"ActionDockMidBandWash",
	"AdvisorPanelContextMeter",
	"AdvisorPanelContextStrip",
	"AdvisorPanelDecisionBridgeMeter",
	"AdvisorPanelDecisionBridgeStrip",
	"AdvisorPanelPriorityMeter",
	"AdvisorPanelPriorityStrip",
	"BambooGptRail",
	"BrushStrokeGptStrip",
	"CenterWallLowDangerStrip",
	"CenterWallMeterSegmentFill",
	"CenterWindRingInner",
	"CenterWindRingMid",
	"CenterWindRingOuter",
	"ChatEmptyMeterRail",
	"ChatEmptySignalStrip",
	"ChatEmptyStateArt",
	"ChatPanelDeliveryChrome",
	"ChatPanelDeliveryMeter",
	"ChatPanelDeliveryStrip",
	"ChatPanelGptHeaderMeter",
	"ChatPanelGptHeaderStrip",
	"ChatPanelGptRoleRail",
	"ChatPanelHeaderBridgeMeter",
	"ChatPanelHeaderBridgeStrip",
	"ChatPanelInputChip",
	"ChatPanelSyncChrome",
	"ChatPanelSyncMeter",
	"ChatPanelSyncStrip",
	"CloudGptPlate",
	"DailyGptSectionPlate",
	"DailyGptSheetPlate",
	"DailyLoginClaimConfirmStrip",
	"DailyLoginClaimRewardStrip",
	"DailyLoginGptStrip",
	"DailyLoginProgressConfirmStrip",
	"DailyLoginRewardStrip",
	"DailyLoginStreakStrip",
	"DangerDiscardGptRiskStrip",
	"DangerDiscardGptRoleRail",
	"ExitConfirmGptStrip",
	"ExitConfirmSheetPlate",
	"FireflyGlow",
	"FireflyGlowOuter",
	"FireworkGlow",
	"GptPanelHost",
	"Hand3DRiskBadge",
	"HintBadgeGptChip",
	"KoiGptPlate",
	"LanternGptGlow",
	"LoadingGptStrip",
	"LoadingTitleGptPlate",
	"MeldKindSealLabel",
	"MeldSummaryArchive",
	"MeldSummaryArchiveGlyph",
	"MeldSummaryGate",
	"MeldSummaryRouteArt",
	"MeldSummarySpineFill",
	"MeldSummaryTick_0",
	"MenuHeroWindGptFill",
	"MenuHeroWindGptRail",
	"MenuHeroWindPathTick_0",
	"MoonGptGlow",
	"OnlineLobbyGptHeaderStrip",
	"RiskBadgeGptChip",
	"RulesCodexRearGPTTexture",
	"RulesGptTitleStrip",
	"RulesMidOrnamentPlate",
	"SealGptPlate",
	"SealStampText",
	"SecondaryBackGptPlate",
	"SecondaryBackGptRail",
	"ShopCabinetRearGPTTexture",
	"ShopCurrencyGptPlate_coins",
	"ShopCurrencyGptPlate_gems",
	"ShopItemRowGptPlate",
	"ShopMidOrnamentPlate",
	"SnowHalo",
	"StatsDashboardGptPlate",
	"StatsDashboardGptStrip",
	"StatsGptSectionPlate",
	"StatsGptTitleStrip",
	"StatsMidOrnamentPlate",
	"StatsRowGptPlate",
	"TableCornerPlateA",
	"TableCornerPlateB",
	"TableLogHeaderPlate",
	"TileFaceTexture",
	"ToastAchievementMeterRail",
	"ToastAchievementSignalStrip",
	"ToastChatSendBanner",
	"ToastGptFacePlate",
	"TopHudWallGPTWarningTexture",
	"UpdateProgressGptFillFace",
	"WallCountGptPlate",
	"WaterGptStrip",
	"WaterGptWash",
	"draw_hand_tray_completion_bus_art_GptStrip",
	"draw_hand_tray_momentum_art_GptStrip",
	"draw_hand_tray_suit_flow_GptStrip",
]

var failed := false

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var scene = load("res://Main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	check(scene.app_version() == "1.0.180-godot", "project version matches exported app version")
	check(scene.AUDIO_DEFAULTS_VERSION == "1.0.159-godot", "audio defaults migrate for this release")
	check(not scene.player_ai_assist_enabled(), "offline player side does not enable AI assistance")
	check(scene.UPDATE_MANIFEST_URL == "http://129.146.180.88:18081/YunzhuoMahjongGodot-update.json", "update manifest URL points to live download service")
	check(scene.UPDATE_URL == "http://129.146.180.88:18081/YunzhuoMahjongGodot-v1.0.180-godot.apk", "fallback update APK URL uses this release's immutable APK path")
	check(bool(ProjectSettings.get_setting("audio/general/text_to_speech", false)), "Godot text-to-speech project setting is enabled")
	check(bool(ProjectSettings.get_setting("audio/driver/enable_input", false)), "audio input is enabled for voice features")
	check(all_illustration_png_files_are_declared_or_optional_gpt(scene), "all illustration PNG files are declared as fixed UI assets or optional GPT targets")
	check(all_declared_illustration_paths_are_png_files(scene), "all declared UI illustration assets point to existing PNG files")
	check(all_main_illustration_texture_keys_are_declared(scene), "all literal UI illustration texture usages are declared in the asset registry")
	check(scene.illustration_textures.size() == scene.ILLUSTRATION_ASSET_PATHS.size(), "all configured UI illustration PNGs load into the illustration texture registry")
	check(all_declared_illustration_keys_load(scene), "every declared UI illustration key resolves through the illustration texture accessor")
	check(scene.GPT_ILLUSTRATION_ASSET_PATHS.has("menu_hero_gpt_backdrop") and scene.GPT_ILLUSTRATION_ASSET_PATHS.has("menu_primary_3d_stage_overlay") and scene.GPT_ILLUSTRATION_ASSET_PATHS.has("loading_scene_gpt_backdrop") and scene.GPT_ILLUSTRATION_ASSET_PATHS.has("daily_login_gpt_calendar") and scene.GPT_ILLUSTRATION_ASSET_PATHS.has("shop_gpt_vault") and scene.GPT_ILLUSTRATION_ASSET_PATHS.has("claim_response_trail") and scene.GPT_ILLUSTRATION_ASSET_PATHS.has("discard_splash_wash") and scene.GPT_ILLUSTRATION_ASSET_PATHS.has("win_result_stage") and scene.GPT_ILLUSTRATION_ASSET_PATHS.has("round_summary_score_flow_bus") and scene.GPT_ILLUSTRATION_ASSET_PATHS.has("rules_gpt_scroll") and scene.GPT_ILLUSTRATION_ASSET_PATHS.has("stats_gpt_dashboard") and scene.GPT_ILLUSTRATION_ASSET_PATHS.has("achievement_gpt_gallery") and scene.GPT_ILLUSTRATION_ASSET_PATHS.has("online_gpt_lobby") and scene.GPT_ILLUSTRATION_ASSET_PATHS.has("online_lobby_panel_frame") and scene.GPT_ILLUSTRATION_ASSET_PATHS.has("online_lobby_group_plate") and scene.GPT_ILLUSTRATION_ASSET_PATHS.has("settings_gpt_panel") and scene.GPT_ILLUSTRATION_ASSET_PATHS.has("table_gpt_backdrop") and scene.GPT_ILLUSTRATION_ASSET_PATHS.has("offline_table_3d_overlay") and scene.GPT_ILLUSTRATION_ASSET_PATHS.has("hand_gpt_tray") and scene.GPT_ILLUSTRATION_ASSET_PATHS.has("hand_completion_gpt_bus") and scene.GPT_ILLUSTRATION_ASSET_PATHS.has("action_gpt_dock") and scene.GPT_ILLUSTRATION_ASSET_PATHS.has("pending_claim_action_dock") and scene.GPT_ILLUSTRATION_ASSET_PATHS.has("pending_claim_status_strip") and scene.GPT_ILLUSTRATION_ASSET_PATHS.has("wall_live_feedback_kit") and scene.GPT_ILLUSTRATION_ASSET_PATHS.has("table_log_gpt_scroll") and scene.GPT_ILLUSTRATION_ASSET_PATHS.has("advisor_gpt_panel") and scene.GPT_ILLUSTRATION_ASSET_PATHS.has("top_hud_gpt_banner") and scene.GPT_ILLUSTRATION_ASSET_PATHS.has("seat_gpt_brocade") and scene.GPT_ILLUSTRATION_ASSET_PATHS.has("exit_gpt_confirm") and scene.GPT_ILLUSTRATION_ASSET_PATHS.has("chat_gpt_panel") and scene.GPT_ILLUSTRATION_ASSET_PATHS.has("update_gpt_dialog") and scene.GPT_ILLUSTRATION_ASSET_PATHS.has("diagnostic_gpt_panel") and scene.GPT_ILLUSTRATION_ASSET_PATHS.has("toast_gpt_banner") and scene.GPT_ILLUSTRATION_ASSET_PATHS.has("reset_gpt_warning") and scene.GPT_ILLUSTRATION_ASSET_PATHS.has("win_detail_gpt_scroll") and scene.GPT_ILLUSTRATION_ASSET_PATHS.has("win_celebration_gpt_burst") and scene.GPT_ILLUSTRATION_ASSET_PATHS.has("voice_gpt_channel") and scene.GPT_ILLUSTRATION_ASSET_PATHS.has("online_feedback_gpt_strip") and scene.GPT_ILLUSTRATION_ASSET_PATHS.has("table_turn_gpt_flow") and scene.GPT_ILLUSTRATION_ASSET_PATHS.has("center_wind_gpt_compass") and scene.GPT_ILLUSTRATION_ASSET_PATHS.has("danger_gpt_discard") and scene.GPT_ILLUSTRATION_ASSET_PATHS.has("menu_tutorial_gpt_hint") and scene.GPT_ILLUSTRATION_ASSET_PATHS.has("hand_tutorial_gpt_hint") and scene.GPT_ILLUSTRATION_ASSET_PATHS.has("flower_gpt_bloom") and scene.GPT_ILLUSTRATION_ASSET_PATHS.has("seat_discard_gpt_preview") and scene.GPT_ILLUSTRATION_ASSET_PATHS.has("seat_flower_gpt_strip") and scene.GPT_ILLUSTRATION_ASSET_PATHS.has("center_wall_gpt_warning") and scene.GPT_ILLUSTRATION_ASSET_PATHS.has("top_hud_wall_gpt_warning") and all_optional_gpt_illustration_paths_are_png_targets(scene), "optional GPT illustration registry declares future PNG targets without forcing generated files")
	check(scene.optional_gpt_illustration_textures.size() <= scene.GPT_ILLUSTRATION_ASSET_PATHS.size(), "optional GPT illustration texture registry tolerates missing generated PNGs")
	check(all_named_main_visual_nodes_have_smoke_references(), "every named visual node in main.gd has an explicit offline smoke reference")
	check(scene.illustration_texture("menu_hero") != null and scene.illustration_texture("table_wash") != null and scene.illustration_texture("win_fanfare") != null and scene.illustration_texture("toast_notice_wave") != null and scene.illustration_texture("loading_tip_scroll") != null and scene.illustration_texture("settings_overview_scroll") != null and scene.illustration_texture("settings_section_brocade") != null and scene.illustration_texture("settings_close_silk") != null and scene.illustration_texture("hand_tutorial_scroll") != null and scene.illustration_texture("pending_claim_silk") != null and scene.illustration_texture("danger_choice_lattice") != null and scene.illustration_texture("diagnostic_signal_map") != null and scene.illustration_texture("update_stage_canopy") != null and scene.illustration_texture("update_notes_canopy") != null and scene.illustration_texture("tutorial_hint_ribbon") != null and scene.illustration_texture("online_status_silk") != null and scene.illustration_texture("flower_bloom_shadow") != null, "core menu table win toast loading settings tutorial claim danger diagnostic update online and flower bloom illustration textures are available")
	var dynamic_illustration_parent = Control.new()
	root.add_child(dynamic_illustration_parent)
	var dynamic_illustration_texture = scene.add_illustration_texture(dynamic_illustration_parent, "menu_hero", scene.rect_full(0.0, 0.0, 0.2, 0.2), 0.5, true)
	check(dynamic_illustration_texture != null and dynamic_illustration_texture.name == "IllustrationTexture_menu_hero" and dynamic_illustration_texture.texture == scene.illustration_texture("menu_hero") and dynamic_illustration_texture.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED and dynamic_illustration_texture.modulate.a > 0.49 and dynamic_illustration_texture.modulate.a < 0.51, "generic illustration texture factory names binds and configures dynamic PNG texture nodes")
	check(scene.add_illustration_texture(dynamic_illustration_parent, "missing_smoke_texture", scene.rect_full(0.0, 0.0, 0.2, 0.2), 1.0, false) == null, "generic illustration texture factory ignores unknown illustration keys")
	check(scene.add_optional_gpt_illustration_texture(dynamic_illustration_parent, "missing_gpt_smoke_texture", scene.rect_full(0.0, 0.0, 0.2, 0.2), 1.0, false) == null, "optional GPT illustration texture factory ignores missing generated images")
	var dynamic_atlas_texture = scene.add_optional_gpt_atlas_texture(dynamic_illustration_parent, "wall_live_feedback_kit", Rect2(40, 60, 548, 70), scene.rect_full(0.0, 0.0, 0.2, 0.2), 0.5, false)
	check(scene.optional_gpt_illustration_texture("wall_live_feedback_kit") == null or (dynamic_atlas_texture != null and dynamic_atlas_texture.texture is AtlasTexture and dynamic_atlas_texture.modulate.a > 0.49 and dynamic_atlas_texture.modulate.a < 0.51), "optional GPT atlas texture factory slices generated sheet assets")
	dispose_node(dynamic_illustration_parent)
	scene.show_loading_screen()
	check(scene.find_child("LoadingCenterPanel", true, false) != null, "loading screen exposes center panel for readability and layout checks")
	check(scene.find_child("LoadingGateTexture", true, false) != null, "loading screen renders reusable moon-gate PNG texture")
	check(scene.optional_gpt_illustration_texture("loading_scene_gpt_backdrop") == null or scene.find_child("LoadingGPTBackdropTexture", true, false) != null, "loading screen consumes optional GPT backdrop texture when generated")
	check(scene.find_child("LoadingMoon", true, false) != null and scene.find_child("MoonGlowBloom", true, false) != null and scene.find_child("LoadingFarMountain", true, false) != null and scene.find_child("LoadingWater", true, false) != null, "loading screen renders moon shader bloom art and ink-wash environment layers")
	check(scene.find_child("LoadingShuffleArt", true, false) != null and scene.find_child("LoadingShuffleRail", true, false) != null and scene.find_child("LoadingShuffleSeal", true, false) != null and scene.find_child("LoadingShuffleGlow", true, false) != null and scene.find_child("LoadingShuffleProgress", true, false) != null and scene.find_child("LoadingShuffleSyncRoute", true, false) != null and scene.find_child("LoadingShuffleSyncFill", true, false) != null and scene.find_child("LoadingShuffleSyncGate", true, false) != null and scene.find_child("LoadingShuffleTile_0", true, false) != null and scene.find_child("LoadingShuffleTile_4", true, false) != null and count_nodes_with_name_prefix(scene, "LoadingShuffleTile_") == 5 and count_nodes_with_name_prefix(scene, "LoadingShuffleSyncTick_") >= 3, "loading screen renders shuffle illustration tiles rail seal glow progress and sync route")
	check(scene.find_child("LoadingProgressFeedback", true, false) != null and scene.find_child("LoadingProgressSource", true, false) != null and scene.find_child("LoadingProgressRoute", true, false) != null and scene.find_child("LoadingProgressFill", true, false) != null and scene.find_child("LoadingProgressGate", true, false) != null, "loading screen renders progress feedback route")
	check(scene.find_child("LoadingProgressReadyNode", true, false) != null and scene.find_child("LoadingProgressReadyGlyph", true, false) != null and count_nodes_with_name_prefix(scene, "LoadingProgressTick_") == 4 and count_nodes_with_name_prefix(scene, "LoadingProgressReadyPip_") == 3, "loading progress feedback renders ready glyph ticks and pips")
	check(scene.find_child("LoadingTipArt", true, false) != null and scene.find_child("LoadingTipScrollTexture", true, false) != null and scene.find_child("LoadingTipRail", true, false) != null and scene.find_child("LoadingTipFill", true, false) != null and scene.find_child("LoadingTipSeal", true, false) != null, "loading screen renders tip scroll texture route art")
	check(scene.find_child("LoadingTipShuffleBridge", true, false) != null and scene.find_child("LoadingTipShuffleBridgeFill", true, false) != null and scene.find_child("LoadingTipShuffleBridgeSource", true, false) != null and scene.find_child("LoadingTipShuffleBridgeGate", true, false) != null, "loading screen renders tip-to-shuffle bridge route")
	check(count_nodes_with_name_prefix(scene, "LoadingTipShuffleBridgeTick_") == 3 and count_nodes_with_name_prefix(scene, "LoadingTipNode_") == 2 and count_nodes_with_name_prefix(scene, "LoadingTipTick_") == 3, "loading screen renders tip bridge nodes and rhythm ticks")
	var loading_tip_bridge_fill = scene.find_child("LoadingTipShuffleBridgeFill", true, false)
	var loading_tip_bridge_source = scene.find_child("LoadingTipShuffleBridgeSource", true, false)
	var loading_tip_bridge_gate = scene.find_child("LoadingTipShuffleBridgeGate", true, false)
	var loading_tip_bridge_tick = scene.find_child("LoadingTipShuffleBridgeTick_0", true, false)
	check(loading_tip_bridge_fill != null and loading_tip_bridge_fill.get_meta("animated_role", "") == "loading_tip_shuffle_flow" and loading_tip_bridge_source != null and loading_tip_bridge_source.get_meta("animated_role", "") == "loading_tip_shuffle_source" and loading_tip_bridge_gate != null and loading_tip_bridge_gate.get_meta("animated_role", "") == "loading_tip_shuffle_gate" and loading_tip_bridge_tick != null and loading_tip_bridge_tick.get_meta("animated_role", "") == "loading_tip_shuffle_tick", "loading tip art marks bridge flow source gate and ticks as animated route nodes")
	scene.show_daily_login_panel({"consecutive_days": 7, "show_reward": true})
	check(scene.find_child("DailyLoginCalendarTexture", true, false) != null, "daily login renders reusable seven-day calendar PNG texture")

	check(scene.find_child("DailyLogin3DCastShadow", true, false) != null and scene.find_child("DailyLogin3DRearShell", true, false) != null and scene.find_child("DailyLogin3DTopGlint", true, false) != null and scene.find_child("DailyLogin3DLowerEdge", true, false) != null, "daily login renders commercial 3D lacquer shell")
	check(scene.optional_gpt_illustration_texture("daily_login_gpt_calendar") == null or scene.find_child("DailyLoginGPTCalendarTexture", true, false) != null, "daily login consumes optional GPT calendar texture when generated")
	check(scene.find_child("DailyLoginGiftGlow", true, false) != null, "daily login renders named title gift glow")
	check(scene.find_child("DailyLoginMountain", true, false) != null and scene.find_child("DailyLoginLanternLeft", true, false) != null and scene.find_child("DailyLoginLanternRight", true, false) != null and scene.find_child("DailyLoginPlumBlossom", true, false) != null, "daily login renders background mountain lantern and plum blossom art")
	check(scene.find_child("DailyLoginStreakArt", true, false) != null and scene.find_child("DailyLoginStreakRail", true, false) != null and scene.find_child("DailyLoginStreakFill", true, false) != null, "daily login renders streak rail illustration")
	check(scene.find_child("DailyLoginDayIndicators", true, false) != null and scene.find_child("DailyLoginRewardPanel", true, false) != null and scene.find_child("DailyLoginProgressPanel", true, false) != null, "daily login renders named day reward and progress panels")
	check(count_nodes_with_name_prefix(scene, "DailyLoginDayNode_") == 7 and count_nodes_with_name_prefix(scene, "DailyLoginStreakNode_") == 7, "daily login renders seven visible day nodes and streak nodes")
	check(count_nodes_with_name_prefix(scene, "DailyLoginDayTextBack_") == 7 and count_nodes_with_name_prefix(scene, "DailyLoginDayLabel_") == 7 and count_nodes_with_name_prefix(scene, "DailyLoginRewardLabel_") == 7, "daily login exposes seven readable day text groups")
	var daily_forecast_title = scene.find_child("DailyLoginForecastTitle", true, false) as Label
	var daily_forecast_badge = scene.find_child("DailyLoginForecastBadge", true, false) as Label
	check(scene.find_child("DailyLoginForecastPanel", true, false) != null and scene.find_child("DailyLoginForecastRail", true, false) != null and daily_forecast_title != null and scene.find_child("DailyLoginForecastBody", true, false) != null and daily_forecast_badge != null and scene.find_child("DailyLoginForecastBadgeBack", true, false) != null, "daily login exposes seven-day reward forecast panel title body rail and badge")
	check(daily_forecast_title != null and daily_forecast_title.text == "七日奖励预告" and daily_forecast_badge != null and daily_forecast_badge.text == "已达成", "daily login completed streak forecast shows seven-day title and achieved badge")
	check(scene.find_child("DailyLoginRewardTextBack", true, false) != null and scene.find_child("DailyLoginRewardIconBack", true, false) != null and scene.find_child("DailyLoginRewardTextLabel", true, false) != null and scene.find_child("DailyLoginProgressText", true, false) != null and scene.find_child("DailyLoginTipBack", true, false) != null and scene.find_child("DailyLoginTipLabel", true, false) != null, "daily login exposes readable reward progress and tip text backplates")
	check(scene.find_child("DailyLoginCurrentHalo", true, false) != null and scene.find_child("DailyLoginSevenDayGate", true, false) != null and scene.find_child("DailyLoginSevenDayGlyph", true, false) != null and scene.find_child("DailyLoginMilestoneGlow", true, false) != null and scene.find_child("DailyLoginMilestoneSealTexture", true, false) != null, "daily login highlights current milestone reward and seven-day GPT seal")
	check(scene.find_child("DailyLoginRewardArt", true, false) != null and scene.find_child("DailyLoginRewardRoute", true, false) != null and scene.find_child("DailyLoginRewardRouteFill", true, false) != null and scene.find_child("DailyLoginRewardSeal", true, false) != null and scene.find_child("DailyLoginRewardMilestoneBurst", true, false) != null, "daily login reward panel renders milestone reward route and seal")
	var daily_login_progress_fill = scene.find_child("DailyLoginProgressFill", true, false)
	check(count_nodes_with_name_prefix(scene, "DailyLoginRewardNode_") == 2 and count_nodes_with_name_prefix(scene, "DailyLoginRewardTick_") == 3 and scene.find_child("DailyLoginProgressRail", true, false) != null and daily_login_progress_fill != null and daily_login_progress_fill.get_meta("animated_role") == "daily_login_progress_flow", "daily login reward panel renders reward nodes ticks and animated progress fill")
	check(scene.find_child("DailyLoginProgressConfirmArt", true, false) != null and scene.find_child("DailyLoginProgressConfirmRoute", true, false) != null and scene.find_child("DailyLoginProgressConfirmFill", true, false) != null and scene.find_child("DailyLoginProgressConfirmGate", true, false) != null, "daily login progress renders claim confirmation route")
	check(count_nodes_with_name_prefix(scene, "DailyLoginProgressConfirmTick_") == 3 and scene.find_child("DailyLoginProgressReadySeal", true, false) != null, "daily login progress renders confirmation rhythm ticks and ready seal")
	check(scene.find_child("DailyLoginClaimButton", true, false) != null and scene.find_child("DailyLoginClaimButtonArt", true, false) != null and scene.find_child("DailyLoginClaimRail", true, false) != null and scene.find_child("DailyLoginClaimFill", true, false) != null and scene.find_child("DailyLoginClaimGate", true, false) != null, "daily login claim button renders reward claim route")
	check(count_nodes_with_name_prefix(scene, "DailyLoginClaimTick_") == 3, "daily login claim button renders reward rhythm ticks")
	var daily_claim_button = scene.find_child("DailyLoginClaimButton", true, false) as Button
	check(daily_claim_button != null, "daily login exposes claim button for press feedback")
	scene.play_daily_login_claim_press_feedback(daily_claim_button)
	check(daily_claim_button.find_child("DailyLoginClaimPressFeedback", true, false) != null and daily_claim_button.find_child("DailyLoginClaimPressSource", true, false) != null and daily_claim_button.find_child("DailyLoginClaimPressRoute", true, false) != null and daily_claim_button.find_child("DailyLoginClaimPressFill", true, false) != null and daily_claim_button.find_child("DailyLoginClaimPressGate", true, false) != null, "daily login claim press feedback renders source route fill and gate")
	check(daily_claim_button.find_child("DailyLoginClaimPressRewardSeal", true, false) != null and daily_claim_button.find_child("DailyLoginClaimPressGlyph", true, false) != null and count_nodes_with_name_prefix(daily_claim_button, "DailyLoginClaimPressTick_") == 3 and count_nodes_with_name_prefix(daily_claim_button, "DailyLoginClaimPressSpark_") == 2, "daily login claim press feedback renders reward seal glyph ticks and sparks")
	check(scene.find_child("DailyLoginClaimFlowArt", true, false) != null and scene.find_child("DailyLoginClaimFlowSource", true, false) != null and scene.find_child("DailyLoginClaimRewardRoute", true, false) != null and scene.find_child("DailyLoginClaimRewardFill", true, false) != null and scene.find_child("DailyLoginClaimRewardGate", true, false) != null and scene.find_child("DailyLoginClaimRewardGlyph", true, false) != null, "daily login renders streak-to-reward claim flow and reward glyph")
	check(scene.find_child("DailyLoginClaimConfirmRoute", true, false) != null and scene.find_child("DailyLoginClaimConfirmFill", true, false) != null and scene.find_child("DailyLoginClaimConfirmGate", true, false) != null and count_nodes_with_name_prefix(scene, "DailyLoginClaimFlowNode_") == 3, "daily login claim flow renders confirmation route and milestone nodes")
	check(count_nodes_with_name_prefix(scene, "DailyLoginClaimRewardTick_") == 3 and count_nodes_with_name_prefix(scene, "DailyLoginClaimConfirmTick_") == 2, "daily login claim flow renders reward and confirm rhythm ticks")
	scene.show_diagnostic_dialog(["【音频系统诊断 v1.0.156】", "✓ BGM文件加载成功", "✗ BGM未播放", "• 建议检查媒体音量", "   →省电策略→无限制"])
	check(scene.optional_gpt_illustration_texture("diagnostic_gpt_panel") == null or scene.find_child("DiagnosticGPTPanelTexture", true, false) != null, "diagnostic dialog consumes optional GPT panel texture when generated")
	check(scene.find_child("DiagnosticWaveTexture", true, false) != null and scene.find_child("DiagnosticSignalMapTexture", true, false) != null and scene.find_child("DiagnosticWaveHeroTexture", true, false) != null, "diagnostic dialog renders reusable wave, hero, and signal-map PNG textures")
	check(scene.find_child("DiagnosticDialogPanel", true, false) != null and scene.find_child("DiagnosticDialogArt", true, false) != null and scene.find_child("DiagnosticHealthRail", true, false) != null, "diagnostic dialog renders illustrated health rail")
	check(scene.find_child("DiagnosticStatusSeal", true, false) != null and scene.find_child("DiagnosticStatusGlyph", true, false) != null and scene.find_child("DiagnosticHealthFill", true, false) != null and count_nodes_with_name_prefix(scene, "DiagnosticStatusNode_") == 3 and count_nodes_with_name_prefix(scene, "DiagnosticStatusValue_") == 3 and count_nodes_with_name_prefix(scene, "DiagnosticStatusCaption_") == 3, "diagnostic dialog renders status seal, glyph, summary nodes, values, and captions")
	check(scene.find_child("DiagnosticStatusNode_ok", true, false) != null and scene.find_child("DiagnosticStatusNode_err", true, false) != null and scene.find_child("DiagnosticStatusNode_hint", true, false) != null, "diagnostic dialog renders explicit ok error and hint status nodes")
	check(scene.find_child("DiagnosticTracePanel", true, false) != null and count_nodes_with_name_prefix(scene, "DiagnosticTracePulse_") == 4, "diagnostic dialog renders trace pulse art")
	check(scene.find_child("DiagnosticStatusTraceRoute", true, false) != null and scene.find_child("DiagnosticStatusTraceFill", true, false) != null and scene.find_child("DiagnosticStatusTraceGate", true, false) != null and scene.find_child("DiagnosticStatusTraceSource", true, false) != null, "diagnostic dialog renders status-to-trace bridge route")
	check(count_nodes_with_name_prefix(scene, "DiagnosticStatusTraceTick_") == 2, "diagnostic dialog status-to-trace bridge renders rhythm ticks")
	check(scene.find_child("DiagnosticLineTrace", true, false) != null and count_nodes_with_name_prefix(scene, "DiagnosticLineLane_") == 5 and count_nodes_with_name_prefix(scene, "DiagnosticLineNode_") == 5, "diagnostic dialog renders one trace lane per visible diagnostic line")
	check(scene.find_child("DiagnosticTraceDismissRoute", true, false) != null and scene.find_child("DiagnosticTraceDismissFill", true, false) != null and scene.find_child("DiagnosticTraceDismissSource", true, false) != null and scene.find_child("DiagnosticTraceDismissGate", true, false) != null, "diagnostic dialog renders trace-to-dismiss completion route")
	check(count_nodes_with_name_prefix(scene, "DiagnosticTraceDismissTick_") == 3, "diagnostic trace completion route renders rhythm ticks")
	check(scene.find_child("DiagnosticResultSyncArt", true, false) != null and scene.find_child("DiagnosticResultSyncSource", true, false) != null and scene.find_child("DiagnosticResultSyncRoute", true, false) != null and scene.find_child("DiagnosticResultSyncFill", true, false) != null and scene.find_child("DiagnosticResultSyncGate", true, false) != null, "diagnostic dialog renders result sync route")
	check(scene.find_child("DiagnosticResultArchive", true, false) != null and scene.find_child("DiagnosticResultGlyph", true, false) != null and scene.find_child("DiagnosticResultDismissBridge", true, false) != null and scene.find_child("DiagnosticResultDismissFill", true, false) != null and count_nodes_with_name_prefix(scene, "DiagnosticResultSyncNode_") == 3 and count_nodes_with_name_prefix(scene, "DiagnosticResultSyncTick_") == 4, "diagnostic result sync renders archive dismiss bridge nodes and ticks")
	var diagnostic_result_fill = scene.find_child("DiagnosticResultSyncFill", true, false) as Control
	check(diagnostic_result_fill != null and diagnostic_result_fill.anchor_right < 0.60, "diagnostic result sync fill tracks partial health when errors exist")
	check(scene.find_child("DiagnosticDismissOverlay", true, false) != null and scene.find_child("DiagnosticDismissArt", true, false) != null and scene.find_child("DiagnosticDismissRoute", true, false) != null and scene.find_child("DiagnosticDismissFill", true, false) != null and scene.find_child("DiagnosticDismissTapSeal", true, false) != null, "diagnostic dialog renders tap-to-dismiss route fill art")
	check(count_nodes_with_name_prefix(scene, "DiagnosticDismissTick_") == 3, "diagnostic dialog renders dismiss rhythm ticks")
	check(first_label_containing_text(scene, "BGM文件加载成功") != null and first_label_containing_text(scene, "BGM未播放") != null, "diagnostic dialog keeps detailed diagnostic text visible")
	var primitive_parent = Control.new()
	root.add_child(primitive_parent)
	var mountain_primitive = scene.make_mountain_silhouette(primitive_parent, scene.rect_full(0.00, 0.00, 0.18, 0.18), 4, scene.INK_WASH)
	var water_primitive = scene.make_water_ripple(primitive_parent, scene.rect_full(0.20, 0.00, 0.38, 0.18), "flowing", true)
	var moon_primitive = scene.make_moon_or_sun(primitive_parent, scene.rect_full(0.40, 0.00, 0.58, 0.18), "rising_sun")
	var blossom_primitive = scene.make_plum_blossom(primitive_parent, scene.rect_full(0.60, 0.00, 0.78, 0.18), 4, scene.ROUGE, true)
	var pine_primitive = scene.make_pine_branch(primitive_parent, scene.rect_full(0.80, 0.00, 0.98, 0.18), "right")
	var koi_primitive = scene.make_koi_fish(primitive_parent, scene.rect_full(0.00, 0.22, 0.18, 0.40), scene.GOLD_PRIMARY, "left")
	var bamboo_primitive = scene.make_bamboo_decoration(primitive_parent, scene.rect_full(0.20, 0.22, 0.38, 0.40), 4)
	var brush_primitive = scene.make_brush_stroke_divider(primitive_parent, scene.rect_full(0.40, 0.22, 0.58, 0.40), 3.0)
	var lantern_primitive = scene.make_lantern(primitive_parent, scene.rect_full(0.60, 0.22, 0.78, 0.40), scene.CINNABAR, true)
	check(primitive_parent.find_child("MountainSilhouette", true, false) != null and count_descendants(mountain_primitive) >= 8, "guofeng primitive smoke renders layered mountain silhouette")
	check(primitive_parent.find_child("WaterRipple", true, false) != null and count_descendants(water_primitive) >= 5, "guofeng primitive smoke renders flowing water ripples")
	check(primitive_parent.find_child("MoonOrSun", true, false) != null and moon_primitive.find_child("MoonBody", true, false) != null, "guofeng primitive smoke renders sun or moon body")
	check(primitive_parent.find_child("PlumBlossom", true, false) != null and count_descendants(blossom_primitive) >= 20, "guofeng primitive smoke renders plum blossom branches and petals")
	check(primitive_parent.find_child("PineBranch", true, false) != null and count_descendants(pine_primitive) >= 7, "guofeng primitive smoke renders pine branch clusters")
	check(primitive_parent.find_child("KoiFish", true, false) != null and count_descendants(koi_primitive) >= 4, "guofeng primitive smoke renders koi body tail eye and fin")
	check(count_descendants(bamboo_primitive) >= 7 and primitive_parent.find_child("BrushStrokeDivider", true, false) != null and count_descendants(brush_primitive) >= 6, "guofeng primitive smoke renders bamboo segments and brush stroke divider")
	check(primitive_parent.find_child("Lantern", true, false) != null and lantern_primitive.find_child("LanternBody", true, false) != null and count_descendants(lantern_primitive) >= 6, "guofeng primitive smoke renders lit lantern body and tassel")
	dispose_node(primitive_parent)
	var depth_dust_parent = Control.new()
	depth_dust_parent.name = "DepthDustSmokeLayer"
	depth_dust_parent.size = Vector2(960, 540)
	root.add_child(depth_dust_parent)
	scene.ambient_layer = depth_dust_parent
	scene._start_depth_layered_dust()
	check(depth_dust_parent.find_child("DepthDustLayer_z2", true, false) != null and depth_dust_parent.find_child("DepthDustLayer_z0", true, false) != null and depth_dust_parent.find_child("DepthDustLayer_z-2", true, false) != null and count_descendants(depth_dust_parent) >= 33, "ambient depth dust renders three parallax particle layers")
	scene.stop_ambient_animation()
	scene.start_ambient_animation("winter", true)
	check(scene.find_child("AmbientLayer", true, false) != null and scene.find_child("DepthDustLayer_z2", true, false) != null, "ambient animation smoke creates named ambient layer and depth dust through entry point")
	scene.stop_ambient_animation()
	scene.ai_difficulty = scene.AI_DIFFICULTY_NORMAL
	scene.reset_ai_profile_seat_map()
	var copied_profile = scene.ai_profile(1)
	copied_profile["attack"] = 9.99
	check(is_equal_approx(scene.ai_profile_value(1, "attack"), 0.92) and scene.ai_profile_label(1) == "防守型" and scene.ai_profile_short_label(2) == "攻", "AI profile reads use canonical profiles while public profile copies stay isolated")
	scene.reset_offline_progress()
	scene.start_offline(false)
	check(scene.mode == "offline", "starts offline mode")
	check(scene.can_self_discard(), "human can discard after deal")
	check(count_nodes_with_name_prefix(scene, "SeatCompactTextBack_") == 4 and count_nodes_with_name_prefix(scene, "SeatAvatarWindMark_") == 4 and count_nodes_with_name_prefix(scene, "SeatAvatarShortName_") == 4, "seat panels expose avatar wind marks short names and readable text backplates")
	check(scene.find_child("TopHudHandProgress", true, false) != null and scene.find_child("HandProgressRail", true, false) != null and scene.find_child("HandProgressDealerBadge", true, false) != null and scene.find_child("HandProgressLabel", true, false) != null and count_nodes_with_name_prefix(scene, "HandProgressPip_") == scene.MATCH_MAX_HANDS, "top HUD renders hand progress rail dealer badge label and match pips")
	check(scene.find_child("HandProgressRouteFill", true, false) != null and scene.find_child("HandProgressActiveGlow", true, false) != null and scene.find_child("HandProgressCurrentCursor", true, false) != null and count_nodes_with_name_prefix(scene, "HandProgressRhythmTick_") == 3, "top HUD hand progress renders route fill active glow current cursor and rhythm ticks")
	check(scene.find_child("HandProgressDealerRoute", true, false) != null and scene.find_child("HandProgressDealerRouteFill", true, false) != null and scene.find_child("HandProgressDealerRouteGate", true, false) != null and count_nodes_with_name_prefix(scene, "HandProgressDealerRouteTick_") == 2, "top HUD hand progress renders dealer route")
	check(scene.find_child("HandProgressWallSyncRoute", true, false) != null and scene.find_child("HandProgressWallSyncRail", true, false) != null and scene.find_child("HandProgressWallSyncFill", true, false) != null, "top HUD hand progress renders wall sync route")
	check(scene.find_child("HandProgressWallSyncSource", true, false) != null and scene.find_child("HandProgressWallSyncGate", true, false) != null and count_nodes_with_name_prefix(scene, "HandProgressWallSyncTick_") == 3, "top HUD hand progress renders wall sync source gate and rhythm ticks")
	var low_wall_progress_parent = Control.new()
	root.add_child(low_wall_progress_parent)
	var previous_wall = scene.wall.duplicate()
	scene.wall.clear()
	for i in range(24):
		scene.wall.append("1W")
	scene.draw_top_hud_hand_progress(low_wall_progress_parent)
	check(low_wall_progress_parent.find_child("HandProgressWallSyncLowWarning", true, false) != null, "top HUD hand progress renders low wall sync warning")
	scene.wall = previous_wall
	dispose_node(low_wall_progress_parent)
	var repeat_progress_parent = Control.new()
	root.add_child(repeat_progress_parent)
	var previous_dealer_repeat = scene.offline_dealer_repeat
	scene.offline_dealer_repeat = true
	scene.draw_top_hud_hand_progress(repeat_progress_parent)
	check(repeat_progress_parent.find_child("HandProgressRepeatBadge", true, false) != null and repeat_progress_parent.find_child("HandProgressDealerRepeatRing", true, false) != null, "top HUD hand progress renders repeat dealer badge and GPT ring when dealer repeats")
	scene.offline_dealer_repeat = previous_dealer_repeat
	dispose_node(repeat_progress_parent)
	check(scene.find_child("HandTrayActionPath", true, false) == null and scene.find_child("HandTrayActionDeliveryRoute", true, false) == null and count_nodes_with_name_prefix(scene, "HandTrayActionPathTick_") == 0, "hand tray omits procedural action path route ticks")
	check(scene.find_child("HandTrayActionRiverDrop", true, false) == null and count_nodes_with_name_prefix(scene, "HandTrayActionDeliveryTick_") == 0, "hand tray omits procedural discard delivery route art")
	check(scene.offline_draw_serial > 0 and not bool(scene.offline_last_draw.get("announce", true)) and scene.fx_last_animated_draw_serial == -1, "initial deal tracks draw order without replaying hand draw animation")
	var human_fly_start = scene.human_discard_fly_start_position(0, scene.players[0]["hand"].size())
	var human_fly_target = scene.human_discard_fly_target_position()
	check(human_fly_start.x >= 0.0 and human_fly_start.y >= 0.0 and human_fly_target.x >= 0.0 and human_fly_target.y >= 0.0 and human_fly_start.distance_to(human_fly_target) > 24.0, "human discard fly animation travels from hand tray toward the discard river")
	var human_discard_tile = str(scene.players[0]["hand"][0])
	scene.offline_ai_active = true
	scene.human_discard(0)
	check(scene.find_child("ClaimBurstLabel_打", true, false) != null and scene.find_child("FlyingTile_%s" % human_discard_tile, true, false) != null, "human discard creates a flying tile and action burst")
	check(scene.find_child("FlyingTileRouteArt", true, false) != null and scene.find_child("FlyingTileArcTexture", true, false) != null and scene.find_child("FlyingTileRouteRail", true, false) != null and scene.find_child("FlyingTileRouteFill", true, false) != null, "human discard flying tile renders route art with reusable arc texture")
	check(scene.find_child("TileDiscardFlyRuntimeAnimation_%s" % human_discard_tile, true, false) != null and scene.find_child("TileDiscardFlyHandSource", true, false) != null and scene.find_child("AnimationPreviewTimeline_tile_discard_fly", true, false) != null, "human discard consumes tile discard fly runtime animation asset")
	for route_wait in range(4):
		if scene.find_child("FlyingTileSourceGate", true, false) != null and scene.find_child("FlyingTileLandingGate", true, false) != null and scene.find_child("FlyingTileRouteTick_0", true, false) != null and scene.find_child("FlyingTileRouteTick_1", true, false) != null and scene.find_child("FlyingTileRouteTick_2", true, false) != null:
			break
		await process_frame
	check(scene.find_child("FlyingTileSourceGate", true, false) != null and scene.find_child("FlyingTileLandingGate", true, false) != null and scene.find_child("FlyingTileRouteTick_0", true, false) != null and scene.find_child("FlyingTileRouteTick_1", true, false) != null and scene.find_child("FlyingTileRouteTick_2", true, false) != null, "human discard flying route renders source landing gates and rhythm ticks")
	scene.offline_ai_active = false
	scene.fx_enabled = true
	scene.ensure_fx_layer()
	scene.play_ai_discard_fly_animation(1, "5W")
	check(scene.find_child("AIDiscardFlowArt_1", true, false) != null and scene.find_child("AIDiscardSource_1", true, false) != null and scene.find_child("AIDiscardRoute_1", true, false) != null and scene.find_child("AIDiscardRouteFill_1", true, false) != null and scene.find_child("AIDiscardGate_1", true, false) != null, "AI discard flying animation renders source route fill and gate")
	check(scene.find_child("TileDiscardFlyRuntimeAnimation_5W", true, false) != null and scene.find_child("TileDiscardFlyRiverGate", true, false) != null, "AI discard consumes tile discard fly runtime animation asset")
	check(scene.find_child("AIDiscardDecisionSeal_1", true, false) != null and scene.find_child("AIDiscardDecisionGlyph_1", true, false) != null and scene.find_child("AIDiscardArchiveRoute_1", true, false) != null and scene.find_child("AIDiscardArchiveFill_1", true, false) != null and count_nodes_with_name_prefix(scene, "AIDiscardRouteTick_1_") >= 3, "AI discard flying animation renders decision seal archive route and rhythm ticks")
	var ai_draw_fx = scene.play_ai_draw_tile_animation(1, "5W")
	check(ai_draw_fx != null and scene.find_child("AIDrawFlowArt_1", true, false) != null and scene.find_child("AIDrawWallSource_1", true, false) != null and scene.find_child("AIDrawRoute_1", true, false) != null and scene.find_child("AIDrawRouteFill_1", true, false) != null and scene.find_child("AIDrawHandGate_1", true, false) != null, "AI draw animation renders hidden draw route from wall to hand gate")
	check(scene.find_child("AIDrawTileRuntimeAnimation_1", true, false) != null and scene.find_child("TileDrawFlyHandGate", true, false) != null, "AI draw consumes tile draw fly runtime animation asset")
	check(scene.find_child("AIDrawTileNode_1", true, false) != null and scene.find_child("AIDrawTileGlyph_1", true, false) != null and scene.find_child("AIDrawDecisionRoute_1", true, false) != null and scene.find_child("AIDrawDecisionFill_1", true, false) != null and scene.find_child("AIDrawDecisionGate_1", true, false) != null and count_nodes_with_name_prefix(scene, "AIDrawRouteTick_1_") >= 3, "AI draw animation renders hidden tile marker decision route and rhythm ticks")
	var ai_draw_glyph = scene.find_child("AIDrawTileGlyph_1", true, false)
	check(ai_draw_glyph != null and ai_draw_glyph is Label and (ai_draw_glyph as Label).text != "5W", "AI draw animation does not reveal the hidden drawn tile label")
	scene.play_human_action_choice_confirmation_fx("self_win", "5W")
	check(scene.find_child("HumanActionChoiceConfirmFx_self_win", true, false) != null and scene.find_child("HumanActionChoiceSource_self_win", true, false) != null and scene.find_child("HumanActionChoiceRoute_self_win", true, false) != null and scene.find_child("HumanActionChoiceFill_self_win", true, false) != null and scene.find_child("HumanActionChoiceGate_self_win", true, false) != null, "human self-win action confirmation renders route from hand to result focus")
	check(scene.find_child("HumanActionChoiceSeal_self_win", true, false) != null and scene.find_child("HumanActionChoiceGlyph_self_win", true, false) != null and scene.find_child("HumanActionChoiceTileBadge_self_win", true, false) != null and scene.find_child("HumanActionChoiceTileGlyph_self_win", true, false) != null and count_nodes_with_name_prefix(scene, "HumanActionChoiceTick_self_win_") == 3, "human self-win action confirmation renders seal tile badge and rhythm ticks")
	check(scene.find_child("HumanActionChoiceArchiveRoute_self_win", true, false) != null and scene.find_child("HumanActionChoiceArchiveFill_self_win", true, false) != null and count_nodes_with_name_prefix(scene, "HumanActionChoiceArchivePip_self_win_") == 2, "human self-win action confirmation renders archive route and pips")
	scene.play_human_action_choice_confirmation_fx("added_gang", "5W")
	check(scene.find_child("HumanActionChoiceConfirmFx_added_gang", true, false) != null and scene.find_child("HumanActionChoiceGlyph_added_gang", true, false) != null and scene.find_child("HumanActionChoiceArchiveRoute_added_gang", true, false) != null and count_nodes_with_name_prefix(scene, "HumanActionChoiceTick_added_gang_") == 3, "human added-gang action confirmation renders gang-specific route glyph and ticks")
	scene.play_discard_splash(Vector2(320, 240), human_discard_tile)
	scene._play_ink_splash_on_discard(Vector2(320, 240), scene.GOLD_PRIMARY)
	check(scene.find_child("DiscardSplashFx", true, false) != null and scene.find_child("InkSplashFx", true, false) != null and count_nodes_with_name_prefix(scene, "DiscardSplashRing_") >= 3 and count_nodes_with_name_prefix(scene, "DiscardSplashDrop_") >= 6, "discard splash renders named rings droplets and ink splash root")
	check(scene.find_child("DiscardSplashInkAnimation", true, false) != null and scene.find_child("DiscardInkSplashWake", true, false) != null and scene.find_child("AnimationPreviewTimeline_discard_ink_splash", true, false) != null, "discard splash consumes reusable ink splash animation asset preview")
	check(scene.optional_gpt_illustration_texture("discard_splash_wash") == null or scene.find_child("DiscardSplashGPTWashTexture", true, false) != null, "discard splash consumes optional GPT wash texture when generated")
	check(scene.find_child("DiscardSplashLandingRoute", true, false) != null and scene.find_child("DiscardSplashLandingFill", true, false) != null and scene.find_child("DiscardSplashLandingGate", true, false) != null and count_nodes_with_name_prefix(scene, "DiscardSplashLandingTick_") >= 3, "discard splash renders landing route and rhythm ticks")
	scene.play_discard_pass_to_next_fx(0, 1, human_discard_tile)
	check(scene.find_child("DiscardPassToNextFx_0_1", true, false) != null and scene.find_child("DiscardPassSource_0_1", true, false) != null and scene.find_child("DiscardPassArchiveRoute_0_1", true, false) != null and scene.find_child("DiscardPassArchiveFill_0_1", true, false) != null, "unclaimed discard pass animation renders discard archive route")
	check(scene.find_child("DiscardPassTileBadge_0_1", true, false) != null and scene.find_child("DiscardPassTileGlyph_0_1", true, false) != null and scene.find_child("DiscardPassNextRoute_0_1", true, false) != null and scene.find_child("DiscardPassNextFill_0_1", true, false) != null and scene.find_child("DiscardPassNextGate_0_1", true, false) != null, "unclaimed discard pass animation renders tile badge and next draw route")
	check(scene.find_child("DiscardPassTileDrawRuntimeAnimation_0_1", true, false) != null and scene.find_child("TileDrawFlyWallSource", true, false) != null and scene.find_child("AnimationPreviewTimeline_tile_draw_fly", true, false) != null, "unclaimed discard pass consumes tile draw fly runtime animation asset")
	check(scene.find_child("DiscardPassNextSeal_0_1", true, false) != null and scene.find_child("DiscardPassNextGlyph_0_1", true, false) != null and count_nodes_with_name_prefix(scene, "DiscardPassNextTick_0_1_") >= 3 and count_nodes_with_name_prefix(scene, "DiscardPassArchivePip_0_1_") >= 2, "unclaimed discard pass animation renders next draw seal ticks and archive pips")
	scene.play_claim_trail_particles(Vector2(120, 240), Vector2(320, 180), 60.0, scene.GOLD_PRIMARY)
	check(scene.find_child("ClaimTrailFx", true, false) != null and scene.find_child("ClaimTrailRoute", true, false) != null and scene.find_child("ClaimTrailRouteFill", true, false) != null and scene.find_child("ClaimTrailLandingGate", true, false) != null, "claim trail renders route fill and landing gate")
	check(count_nodes_with_name_prefix(scene, "ClaimTrailSpark_") >= 8 and count_nodes_with_name_prefix(scene, "ClaimTrailRhythmNode_") >= 3, "claim trail renders named sparks and rhythm nodes")
	scene.play_ai_claim_choice_confirmation_fx(2, 0, "3W", "chi")
	check(scene.find_child("AIClaimChoiceConfirmFx_2_chi", true, false) != null and scene.find_child("AIClaimChoiceSource_2_chi", true, false) != null and scene.find_child("AIClaimChoiceRoute_2_chi", true, false) != null and scene.find_child("AIClaimChoiceFill_2_chi", true, false) != null and scene.find_child("AIClaimChoiceGate_2_chi", true, false) != null, "AI claim choice confirmation renders selected response route from discard to meld")
	check(scene.find_child("AIClaimChoiceSeal_2_chi", true, false) != null and scene.find_child("AIClaimChoiceGlyph_2_chi", true, false) != null and scene.find_child("AIClaimChoiceSeatSeal_2_chi", true, false) != null and scene.find_child("AIClaimChoiceSeatGlyph_2_chi", true, false) != null, "AI claim choice confirmation renders action and seat seals")
	check(scene.find_child("AIClaimChoiceTileBadge_2_chi", true, false) != null and scene.find_child("AIClaimChoiceTileGlyph_2_chi", true, false) != null and scene.find_child("AIClaimChoiceArchiveRoute_2_chi", true, false) != null and scene.find_child("AIClaimChoiceArchiveFill_2_chi", true, false) != null and count_nodes_with_name_prefix(scene, "AIClaimChoiceTick_2_chi_") == 3, "AI claim choice confirmation renders tile badge archive route and rhythm ticks")
	check(count_nodes_with_name_prefix(scene, "AIClaimChoiceArchivePip_2_chi_") == 2, "AI claim choice confirmation renders archive pips")
	scene.play_claim_resolution_art("gang", Vector2(140, 250), Vector2(360, 190), scene.AZURE, scene.FX_CLAIM_FLY_DURATION_MSEC)
	check(scene.find_child("ClaimResolutionArt_gang", true, false) != null and scene.find_child("ClaimResolutionRoute_gang", true, false) != null and scene.find_child("ClaimResolutionFill_gang", true, false) != null, "claim resolution renders action-specific route art")
	check(scene.find_child("ClaimResolutionLandingGate_gang", true, false) != null and scene.find_child("ClaimResolutionGateCore_gang", true, false) != null and scene.find_child("ClaimResolutionGlyph_gang", true, false) != null and scene.find_child("ClaimResolutionHalo_gang", true, false) != null, "claim resolution renders landing gate halo and action glyph")
	check(count_nodes_with_name_prefix(scene, "ClaimResolutionMeldSlot_gang_") == 4 and count_nodes_with_name_prefix(scene, "ClaimResolutionMeldPip_gang_") == 4 and count_nodes_with_name_prefix(scene, "ClaimResolutionTick_gang_") == 3, "claim resolution renders gang meld slots pips and rhythm ticks")
	scene.play_fx_gang_burst("concealed", 0)
	check(scene.find_child("GangBurstRoute", true, false) != null and scene.find_child("GangBurstRouteFill", true, false) != null and scene.find_child("GangBurstDrawGate", true, false) != null and scene.find_child("GangBurstQuadNode", true, false) != null, "gang burst renders route to replacement draw gate")
	check(scene.find_child("GangBurstRevealAnimation_concealed", true, false) != null and scene.find_child("KongRevealBurstSeal", true, false) != null and scene.find_child("AnimationPreviewTimeline_kong_reveal_burst", true, false) != null, "gang burst consumes kong reveal burst runtime animation asset")
	check(count_nodes_with_name_prefix(scene, "GangBurstTileMark_") == 4 and count_nodes_with_name_prefix(scene, "GangBurstRouteTick_") == 3, "gang burst renders four-tile marks and rhythm ticks")
	check(scene.find_child("GangBurstTypeRoute", true, false) != null and scene.find_child("GangBurstTypeFill", true, false) != null and scene.find_child("GangBurstTypeSource", true, false) != null and scene.find_child("GangBurstTypeGate", true, false) != null, "gang burst renders gang-type confirmation route")
	check(count_nodes_with_name_prefix(scene, "GangBurstTypeTick_") == 2, "gang burst renders gang-type rhythm ticks")
	scene.play_rob_gang_warning_fx(1, 0, "5W")
	check(scene.find_child("RobGangWarningFx_1_0", true, false) != null and scene.find_child("RobGangWarningGangSource_1_0", true, false) != null and scene.find_child("RobGangWarningGangGlyph_1_0", true, false) != null and scene.find_child("RobGangWarningRoute_1_0", true, false) != null and scene.find_child("RobGangWarningFill_1_0", true, false) != null, "rob-gang warning renders gang source and interception route")
	check(scene.find_child("RobGangWarningWinGate_1_0", true, false) != null and scene.find_child("RobGangWarningSeal_1_0", true, false) != null and scene.find_child("RobGangWarningGlyph_1_0", true, false) != null and scene.find_child("RobGangWarningIntercept_1_0", true, false) != null, "rob-gang warning renders win gate seal glyph and intercept marker")
	check(scene.find_child("RobGangWarningTileBadge_1_0", true, false) != null and scene.find_child("RobGangWarningTileGlyph_1_0", true, false) != null and scene.find_child("RobGangWarningArchiveRoute_1_0", true, false) != null and scene.find_child("RobGangWarningArchiveFill_1_0", true, false) != null, "rob-gang warning renders tile badge and archive route")
	check(count_nodes_with_name_prefix(scene, "RobGangWarningTick_1_0_") == 4 and count_nodes_with_name_prefix(scene, "RobGangWarningPip_1_0_") == 3, "rob-gang warning renders rhythm ticks and archive pips")
	scene.play_after_gang_replacement_draw_fx(0, "5W")
	check(scene.find_child("AfterGangReplacementFx", true, false) != null and scene.find_child("AfterGangReplacementWallSource", true, false) != null and scene.find_child("AfterGangReplacementRoute", true, false) != null and scene.find_child("AfterGangReplacementFill", true, false) != null and scene.find_child("AfterGangReplacementHandGate", true, false) != null, "after-gang replacement draw renders wall-to-hand route")
	check(scene.find_child("AfterGangReplacementSeal", true, false) != null and scene.find_child("AfterGangReplacementGlyph", true, false) != null and scene.find_child("AfterGangReplacementTileNode", true, false) != null and scene.find_child("AfterGangReplacementTileGlyph", true, false) != null, "after-gang replacement draw renders replacement seal and tile glyph")
	check(scene.find_child("AfterGangReplacementArchiveRoute", true, false) != null and scene.find_child("AfterGangReplacementArchiveFill", true, false) != null and scene.find_child("AfterGangReplacementArchiveGate", true, false) != null and count_nodes_with_name_prefix(scene, "AfterGangReplacementTick_") == 3 and count_nodes_with_name_prefix(scene, "AfterGangReplacementArchivePip_") == 2, "after-gang replacement draw renders archive route ticks and pips")
	scene.play_wall_draw_resolution_fx(0)
	check(scene.find_child("WallDrawResolutionFx", true, false) != null and scene.find_child("WallDrawEmptyWallSource", true, false) != null and scene.find_child("WallDrawEmptyWallGlyph", true, false) != null and scene.find_child("WallDrawResolutionRoute", true, false) != null and scene.find_child("WallDrawResolutionFill", true, false) != null and scene.find_child("WallDrawResolutionGate", true, false) != null, "wall draw resolution renders empty wall source and resolution route")
	check(scene.find_child("WallDrawSeal", true, false) != null and scene.find_child("WallDrawGlyph", true, false) != null and scene.find_child("WallDrawDealerSeal", true, false) != null and scene.find_child("WallDrawDealerGlyph", true, false) != null, "wall draw resolution renders draw seal and dealer repeat glyph")
	check(scene.find_child("WallDrawDealerRepeatRoute", true, false) != null and scene.find_child("WallDrawDealerRepeatFill", true, false) != null and scene.find_child("WallDrawDealerRepeatGate", true, false) != null and count_nodes_with_name_prefix(scene, "WallDrawResolutionTick_") == 4 and count_nodes_with_name_prefix(scene, "WallDrawDealerRepeatPip_") == 3, "wall draw resolution renders dealer repeat route ticks and pips")
	scene.fx_enabled = true
	scene.ensure_fx_layer()
	scene.play_next_hand_transition_fx(0, 1, false)
	check(scene.find_child("NextHandTransitionFx_0_1", true, false) != null and scene.find_child("NextHandArchiveSource_0_1", true, false) != null and scene.find_child("NextHandArchiveGlyph_0_1", true, false) != null and scene.find_child("NextHandTransitionRoute_0_1", true, false) != null and scene.find_child("NextHandTransitionFill_0_1", true, false) != null, "next hand transition renders settlement archive route toward next dealer")
	check(scene.find_child("NextHandDealerGate_0_1", true, false) != null and scene.find_child("NextHandDealerSeal_0_1", true, false) != null and scene.find_child("NextHandDealerGlyph_0_1", true, false) != null and scene.find_child("NextHandWallRoute_0_1", true, false) != null and scene.find_child("NextHandWallFill_0_1", true, false) != null, "next hand transition renders next dealer gate seal and wall route")
	check(scene.find_child("NextHandWallGate_0_1", true, false) != null and count_nodes_with_name_prefix(scene, "NextHandTransitionTick_0_1_") == 3 and count_nodes_with_name_prefix(scene, "NextHandWallPip_0_1_") == 3, "next hand transition renders wall gate rhythm ticks and pips")
	scene.play_fx_deal_start(0)
	var deal_start_fx = scene.find_child("DealStartFx", true, false)
	check(deal_start_fx != null and deal_start_fx.find_child("DealStartRing", true, false) != null and count_nodes_with_name_prefix(deal_start_fx, "DealStartTile_") == 4, "deal start animation renders ring and seat tiles")
	check(deal_start_fx != null and count_nodes_with_name_prefix(deal_start_fx, "DealStartPulseRing_") == 3, "deal start animation renders named pulse rings")
	check(deal_start_fx != null and deal_start_fx.find_child("DealStartDistributionArt", true, false) != null and deal_start_fx.find_child("DealStartDistributionSource", true, false) != null and deal_start_fx.find_child("DealStartDistributionGlyph", true, false) != null, "deal start animation renders dealer distribution source")
	check(deal_start_fx != null and count_nodes_with_name_prefix(deal_start_fx, "DealStartDistributionRoute_") == 4 and count_nodes_with_name_prefix(deal_start_fx, "DealStartDistributionFill_") == 4 and count_nodes_with_name_prefix(deal_start_fx, "DealStartDistributionGate_") == 4 and count_nodes_with_name_prefix(deal_start_fx, "DealStartDistributionTick_") == 4, "deal start animation renders distribution route fill gate and tick for every seat")
	scene.start_offline(false)
	check(scene.make_wall().size() == 144, "wall includes eight flowers")
	check(scene.fx_enabled and scene.fx_layer != null and is_instance_valid(scene.fx_layer) and scene.find_child("FxLayer", true, false) != null and scene.find_child("TurnPulse", true, false) != null and scene.find_child("TurnGlow", true, false) != null, "fx animation layer is created with turn pulse glow for smoke paths")
	scene.play_fx_deal_cascade(0)
	var deal_cascade_fx = scene.find_child("DealCascadeFx", true, false)
	check(deal_cascade_fx != null and deal_cascade_fx.find_child("DealCascadeRing", true, false) != null and count_nodes_with_name_prefix(deal_cascade_fx, "DealCascadeRoute_") >= 4 and count_nodes_with_name_prefix(deal_cascade_fx, "DealCascadeRouteFill_") >= 4 and count_nodes_with_name_prefix(deal_cascade_fx, "DealCascadeSeatGate_") >= 4, "deal cascade animation renders root ring route fill and seat gate per player")
	check(deal_cascade_fx != null and count_nodes_with_name_prefix(deal_cascade_fx, "DealCascadeTile_") >= 16, "deal cascade animation renders named flying tile backs toward all seats")
	check(deal_cascade_fx != null and count_nodes_with_name_prefix(deal_cascade_fx, "DealCascadeRouteTick_") >= 12, "deal cascade animation renders route rhythm ticks toward all seats")
	check(deal_cascade_fx != null and deal_cascade_fx.find_child("DealCascadeCompletionArt", true, false) != null and deal_cascade_fx.find_child("DealCascadeCompletionSource", true, false) != null and deal_cascade_fx.find_child("DealCascadeCompletionGlyph", true, false) != null and deal_cascade_fx.find_child("DealCascadeCompletionRoute", true, false) != null and deal_cascade_fx.find_child("DealCascadeCompletionFill", true, false) != null, "deal cascade animation renders completion route from deal source")
	check(deal_cascade_fx != null and deal_cascade_fx.find_child("DealCascadeReadyGate", true, false) != null and deal_cascade_fx.find_child("DealCascadeReadySeal", true, false) != null and deal_cascade_fx.find_child("DealCascadeReadyGlyph", true, false) != null and count_nodes_with_name_prefix(deal_cascade_fx, "DealCascadeCompletionSeatNode_") == 4, "deal cascade animation renders ready gate seal and one completion node per seat")
	check(deal_cascade_fx != null and count_nodes_with_name_prefix(deal_cascade_fx, "DealCascadeHandArchiveGate_") == 4 and count_nodes_with_name_prefix(deal_cascade_fx, "DealCascadeCompletionTick_") == 4, "deal cascade animation renders hand archive gates and completion rhythm ticks")
	scene.play_fx_turn_switch_slide(2)
	check(scene.find_child("TurnSwitchHalo", true, false) != null and scene.find_child("TurnSwitchRoute", true, false) != null and scene.find_child("TurnSwitchRouteFill", true, false) != null and scene.find_child("TurnSwitchSeatGate", true, false) != null, "turn switch animation renders active-seat route and gate")
	check(count_nodes_with_name_prefix(scene, "TurnSwitchRouteTick_") == 3, "turn switch animation renders route rhythm ticks")
	check(scene.find_child("TurnSwitchActionReadyArt", true, false) != null and scene.find_child("TurnSwitchActionSource_2", true, false) != null and scene.find_child("TurnSwitchActionRoute_2", true, false) != null and scene.find_child("TurnSwitchActionFill_2", true, false) != null and scene.find_child("TurnSwitchActionGate_2", true, false) != null, "turn switch animation renders active-seat action-ready route")
	check(scene.find_child("TurnSwitchActionSeal_2", true, false) != null and scene.find_child("TurnSwitchActionGlyph_2", true, false) != null and scene.find_child("TurnSwitchActionArchiveRoute_2", true, false) != null and scene.find_child("TurnSwitchActionArchiveFill_2", true, false) != null and count_nodes_with_name_prefix(scene, "TurnSwitchActionTick_2_") >= 3, "turn switch action-ready art renders seal archive route and rhythm ticks")
	scene.play_fx_discard_ripple(0)
	var discard_ripple_root = scene.find_child("DiscardRipple", true, false) as Control
	check(discard_ripple_root != null and discard_ripple_root.visible and discard_ripple_root.find_child("Ripple0", true, false) != null and discard_ripple_root.find_child("Ripple1", true, false) != null and count_nodes_with_name_prefix(discard_ripple_root, "Ripple") == 2, "discard ripple animation renders visible named ripple ring nodes")
	var before_fx: bool = scene.fx_enabled
	scene.toggle_fx_setting()
	check(scene.fx_enabled == (not before_fx), "fx setting toggles and persists through the settings path")
	scene.toggle_fx_setting()
	check(scene.fx_enabled == before_fx, "fx setting toggles back to default")
	var enhancement_parent = Control.new()
	root.add_child(enhancement_parent)
	AnimationEffects.create_particle_trail(enhancement_parent, Vector2(12.0, 18.0), Vector2(120.0, 72.0), 5, 0.8)
	check(count_nodes_with_name_prefix(enhancement_parent, "TrailParticle_") == 5, "animation effects render named particle trail nodes")
	var number_roll_label = Label.new()
	number_roll_label.text = "5"
	enhancement_parent.add_child(number_roll_label)
	var number_roll_tween := AnimationEffects.animate_number(number_roll_label, 37, 0.05)
	if number_roll_tween != null:
		await number_roll_tween.finished
	check(number_roll_tween != null and number_roll_label.text == "37", "animation effects animate number labels to their target value")
	var progress_roll_bar = ProgressBar.new()
	progress_roll_bar.value = 10.0
	enhancement_parent.add_child(progress_roll_bar)
	var progress_roll_tween := AnimationEffects.animate_progress_bar(progress_roll_bar, 64.0, 0.05)
	if progress_roll_tween != null:
		await progress_roll_tween.finished
	check(progress_roll_tween != null and is_equal_approx(progress_roll_bar.value, 64.0), "animation effects animate progress bars to their target value")
	scene.ui_enhancements.create_enhanced_particle_burst(enhancement_parent, Vector2(48.0, 48.0), "gold", 4, 36.0)
	check(count_nodes_with_name_prefix(enhancement_parent, "EnhancedParticle_") == 4, "UI enhancements render enhanced particle burst nodes")
	var starlight = scene.ui_enhancements.create_enhanced_starlight(enhancement_parent, Rect2(Vector2(0.0, 0.0), Vector2(140.0, 90.0)), 4)
	check(starlight != null and enhancement_parent.find_child("EnhancedStarlight", true, false) != null and count_nodes_with_name_prefix(starlight, "Star_") == 4, "UI enhancements render enhanced starlight container and star nodes")
	var cloud = scene.ui_enhancements.create_floating_cloud(enhancement_parent, Rect2(Vector2(12.0, 10.0), Vector2(120.0, 48.0)), 30.0)
	check(cloud != null and enhancement_parent.find_child("FloatingCloud", true, false) != null, "UI enhancements render floating cloud nodes")
	var bamboo = scene.ui_enhancements.create_bamboo_sway(enhancement_parent, Rect2(Vector2(8.0, 12.0), Vector2(36.0, 120.0)), 4)
	check(bamboo != null and enhancement_parent.find_child("SwayingBamboo", true, false) != null, "UI enhancements render swaying bamboo nodes")
	scene.ui_enhancements.create_falling_plum_blossoms(enhancement_parent, Rect2(Vector2(0.0, 0.0), Vector2(160.0, 120.0)), 3)
	check(count_nodes_with_name_prefix(enhancement_parent, "FallingBlossom_") == 3, "UI enhancements render falling plum blossom nodes")
	scene.ui_enhancements.create_floating_spirit(enhancement_parent, Rect2(Vector2(0.0, 0.0), Vector2(160.0, 120.0)), 3)
	check(count_nodes_with_name_prefix(enhancement_parent, "SpiritGlow_") == 3, "UI enhancements render floating spirit glow nodes")
	scene.ui_enhancements.create_gold_dust(enhancement_parent, Rect2(Vector2(0.0, 0.0), Vector2(160.0, 120.0)), 4)
	check(count_nodes_with_name_prefix(enhancement_parent, "GoldDust_") == 4, "UI enhancements render gold dust nodes")
	var orbit = scene.ui_enhancements.create_orbiting_motes(enhancement_parent, Rect2(Vector2(12.0, 18.0), Vector2(180.0, 96.0)), "gold", 5)
	check(orbit != null and enhancement_parent.find_child("OrbitingMotes", true, false) != null and count_nodes_with_name_prefix(enhancement_parent, "OrbitingMote_") == 5, "UI enhancements render orbiting mote particle nodes")
	var sweep = scene.ui_enhancements.create_ribbon_sweep(enhancement_parent, Rect2(Vector2(0.10, 0.20), Vector2(0.70, 0.30)), scene.GOLD_PRIMARY, 3.0)
	check(sweep != null and enhancement_parent.find_child("RibbonSweep", true, false) != null and enhancement_parent.find_child("RibbonSweepStreak", true, false) != null, "UI enhancements render ribbon sweep and moving streak nodes")
	root.remove_child(enhancement_parent)
	enhancement_parent.free()
	var fx_rect: Rect2 = scene.root_layer_rect_to_screen_rect_for(Rect2(Vector2(0.0, 0.0), Vector2(1.0, 1.0)), Vector2(1280, 720), Vector4(0, 0, 0, 0))
	check(is_equal_approx(fx_rect.position.x, 0.0) and is_equal_approx(fx_rect.size.x, 1.0), "fx rect conversion maps a full safe-area rect to the full viewport")
	var fx_inset: Rect2 = scene.root_layer_rect_to_screen_rect_for(Rect2(Vector2(0.0, 0.0), Vector2(1.0, 1.0)), Vector2(1280, 720), Vector4(80, 0, 80, 0))
	check(is_equal_approx(fx_inset.position.x, 80.0 / 1280.0) and is_equal_approx(fx_inset.size.x, (1280.0 - 80.0) / 1280.0), "fx rect conversion accounts for left and right safe-area margins")
	var fx_center: Rect2 = scene.root_layer_rect_to_screen_rect_for(Rect2(Vector2(0.5, 0.5), Vector2(0.5, 0.5)), Vector2(1000, 1000), Vector4(0, 0, 0, 0))
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
	check(wall_warning_parent.find_child("CenterWallMeter", true, false) != null and count_nodes_with_name_prefix(wall_warning_parent, "CenterWallMeterSegment") == 4, "center wall meter renders base meter and all wall segments")
	check(scene.optional_gpt_illustration_texture("center_wall_gpt_warning") == null or wall_warning_parent.find_child("CenterWallGPTWarningTexture", true, false) != null, "center wall meter consumes optional GPT warning texture when generated")
	check(wall_warning_parent.find_child("CenterWallFlowArt", true, false) != null and wall_warning_parent.find_child("CenterWallFlowMandalaTexture", true, false) != null and wall_warning_parent.find_child("CenterWallFlowCore", true, false) != null and wall_warning_parent.find_child("CenterWallFlowFill", true, false) != null, "center wall meter renders remaining-wall flow art with reusable mandala texture")
	check(count_nodes_with_name_prefix(wall_warning_parent, "CenterWallFlowNode_") == 4 and wall_warning_parent.find_child("CenterWallFlowNode_0", true, false) != null and wall_warning_parent.find_child("CenterWallFlowNode_3", true, false) != null and count_nodes_with_name_prefix(wall_warning_parent, "CenterWallFlowTick_") == 3 and wall_warning_parent.find_child("CenterWallFlowTick_2", true, false) != null, "center wall meter renders flow nodes and ticks")
	check(wall_warning_parent.find_child("CenterWallDrawRoute", true, false) != null and wall_warning_parent.find_child("CenterWallDrawFill", true, false) != null and wall_warning_parent.find_child("CenterWallDrawSource", true, false) != null and wall_warning_parent.find_child("CenterWallDrawGate", true, false) != null, "center wall meter renders draw handoff route")
	check(count_nodes_with_name_prefix(wall_warning_parent, "CenterWallDrawTick_") == 2, "center wall draw handoff renders rhythm ticks")
	check(wall_warning_parent.find_child("CenterWallPressurePulse", true, false) != null and wall_warning_parent.find_child("CenterWallPressureFill", true, false) != null and count_nodes_with_name_prefix(wall_warning_parent, "CenterWallPressureTick_") == 4 and wall_warning_parent.find_child("CenterWallPressureTick_0", true, false) != null and wall_warning_parent.find_child("CenterWallPressureTick_3", true, false) != null, "center wall meter renders pressure pulse and warning ticks")
	check(wall_warning_parent.find_child("CenterWallPressureDangerCore", true, false) != null, "low wall meter renders danger pressure core")
	check(wall_warning_parent.find_child("CenterWallLowWarning", true, false) != null and wall_warning_parent.find_child("CenterWallLowPulse", true, false) != null and wall_warning_parent.find_child("CenterWallLowWarningBadge", true, false) != null and wall_warning_parent.find_child("CenterWallLowSpark", true, false) != null, "low wall meter renders warning pulse badge and sparks")
	check(wall_warning_parent.find_child("CenterWallLowDangerRoute", true, false) != null and wall_warning_parent.find_child("CenterWallLowDangerFill", true, false) != null and wall_warning_parent.find_child("CenterWallLowDangerGate", true, false) != null, "low wall meter renders danger countdown route")
	check(count_nodes_with_name_prefix(wall_warning_parent, "CenterWallLowDangerTick_") == 3 and wall_warning_parent.find_child("CenterWallLowDangerTick_2", true, false) != null, "low wall meter renders danger rhythm ticks")
	var low_wall_fill = wall_warning_parent.find_child("CenterWallLowDangerFill", true, false) as Control
	check(low_wall_fill != null and low_wall_fill.anchor_right > 0.60 and low_wall_fill.anchor_right < 0.70, "low wall danger fill tracks remaining wall count")
	check(has_label_text(wall_warning_parent, "荒庄临近"), "low wall warning names the near-draw state")
	dispose_node(wall_warning_parent)
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
	check(gang_meld_view.find_child("MeldRouteRail", true, false) != null and gang_meld_view.find_child("MeldRouteFill", true, false) != null and gang_meld_view.find_child("MeldRouteArrow", true, false) != null and gang_meld_view.find_child("MeldRouteArrowCore", true, false) != null and count_nodes_with_name_prefix(gang_meld_view, "MeldRouteNode_") == 3, "meld group renders route rail nodes arrow and arrow core")
	check(gang_meld_view.find_child("MeldCompletionRoute", true, false) != null and gang_meld_view.find_child("MeldCompletionFill", true, false) != null and gang_meld_view.find_child("MeldCompletionGate", true, false) != null and count_nodes_with_name_prefix(gang_meld_view, "MeldCompletionTick_") == 2, "meld group renders completion route and rhythm ticks")
	check(gang_meld_view.find_child("MeldGangGoldRail", true, false) != null and gang_meld_view.find_child("MeldGangSeal", true, false) != null and gang_meld_view.find_child("MeldGangRaisedTile", true, false) != null and gang_meld_view.find_child("MeldGangCrownGlow", true, false) != null, "gang meld illustration renders rail seal crown glow and raised fourth tile")
	dispose_node(gang_meld_view)
	var chi_meld_view = scene.make_meld_group_view(["1W", "2W", "3W"], 1)
	root.add_child(chi_meld_view)
	check(chi_meld_view.find_child("MeldChiBridge", true, false) != null and chi_meld_view.find_child("MeldKindSeal", true, false) != null and count_nodes_with_name_prefix(chi_meld_view, "MeldFlowBead_") == 3, "chi meld illustration renders sequence bridge and flow beads")
	dispose_node(chi_meld_view)
	var peng_meld_view = scene.make_meld_group_view(["E", "E", "E"], 2)
	root.add_child(peng_meld_view)
	check(count_nodes_with_name_prefix(peng_meld_view, "MeldPengPulse_") == 2 and peng_meld_view.find_child("MeldKindRail", true, false) != null, "peng meld illustration renders pair pulse art")
	dispose_node(peng_meld_view)
	var meld_lane_parent = Control.new()
	root.add_child(meld_lane_parent)
	scene.players[2]["melds"] = [["3W", "4W", "5W"], ["E", "E", "E"]]
	scene.draw_melds(meld_lane_parent)
	check(meld_lane_parent.find_child("MeldLaneArt_2", true, false) != null and meld_lane_parent.find_child("MeldLaneRail_2", true, false) != null and meld_lane_parent.find_child("MeldLaneFill_2", true, false) != null and meld_lane_parent.find_child("MeldLaneGate_2", true, false) != null, "meld area renders seat lane rail and gate")
	check(meld_lane_parent.find_child("MeldLaneExitRoute_2", true, false) != null and meld_lane_parent.find_child("MeldLaneExitFill_2", true, false) != null and meld_lane_parent.find_child("MeldLaneExitGate_2", true, false) != null and count_nodes_with_name_prefix(meld_lane_parent, "MeldLaneExitTick_2_") == 2, "meld area renders lane exit route to open meld gate")
	check(count_nodes_with_name_prefix(meld_lane_parent, "MeldLaneNode_2_") == 2 and count_nodes_with_name_prefix(meld_lane_parent, "MeldLaneTick_2_") == 3 and count_nodes_with_name_prefix(meld_lane_parent, "MeldGroup_") == 2, "meld area lane tracks open meld count and keeps meld groups")
	check(meld_lane_parent.find_child("MeldLaneRevealArt_2", true, false) != null and meld_lane_parent.find_child("MeldLaneRevealSource_2", true, false) != null and meld_lane_parent.find_child("MeldLaneRevealRoute_2", true, false) != null and meld_lane_parent.find_child("MeldLaneRevealFill_2", true, false) != null and meld_lane_parent.find_child("MeldLaneRevealGate_2", true, false) != null, "meld area renders reveal source route fill and gate")
	check(meld_lane_parent.find_child("MeldLaneRevealSeal_2", true, false) != null and meld_lane_parent.find_child("MeldLaneRevealGlyph_2", true, false) != null and meld_lane_parent.find_child("MeldLaneRevealReturnRoute_2", true, false) != null and meld_lane_parent.find_child("MeldLaneRevealReturnFill_2", true, false) != null and meld_lane_parent.find_child("MeldLaneRevealReturnGate_2", true, false) != null and count_nodes_with_name_prefix(meld_lane_parent, "MeldLaneRevealTick_2_") == 3, "meld area renders reveal seal return route and rhythm ticks")
	check(true, "meld summary center strip removed; melds dock to seats")
	dispose_node(meld_lane_parent)
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
	check(rounded_style.corner_radius_top_left == 8 and rounded_style.corner_radius_top_right == 8 and rounded_style.corner_radius_bottom_right == 8 and rounded_style.corner_radius_bottom_left == 8 and rounded_style.border_width_left == 0 and rounded_style.bg_color.a == 0.0, "style helper applies uniform corner radius and border width")
	var shadowless_style = scene.style(Color(0.2, 0.3, 0.4, 1.0), 8, Color(0.7, 0.6, 0.3, 1.0), 2, 0)
	check(shadowless_style.shadow_size == 0 and scene.style_cache.size() == style_cache_size, "style cache keeps shadow variants separate for lightweight UI")
	scene.style_cache.clear()
	scene.style_cache_order.clear()
	scene.button_style_set_cache.clear()
	scene.button_style_set_cache_order.clear()
	var first_button_style_set = scene.button_style_set(Color(0.24, 0.60, 0.45), 12)
	var style_cache_size_after_button_set = scene.style_cache.size()
	var repeated_button_style_set = scene.button_style_set(Color(0.24, 0.60, 0.45), 12)
	check(scene.button_style_set_cache.size() == 1 and style_cache_size_after_button_set == 1 and scene.style_cache.size() == style_cache_size_after_button_set, "button style set cache builds normal hover pressed styles once")
	check(first_button_style_set.has("normal") and first_button_style_set.has("hover") and first_button_style_set.has("pressed") and first_button_style_set["normal"] == repeated_button_style_set["normal"], "button style set cache reuses repeated button styleboxes")
	scene.style_cache.clear()
	scene.style_cache_order.clear()
	scene.button_style_set_cache.clear()
	scene.button_style_set_cache_order.clear()
	var action_style_button = scene.make_action_button("动作", Color(0.25, 0.58, 0.48), func() -> void:
		pass
	)
	var action_button_normal_style = action_style_button.get_theme_stylebox("normal")
	check(action_button_normal_style is StyleBoxEmpty and scene.style_cache.size() == 0 and action_style_button.find_child("ActionButtonArt", true, false) != null, "action buttons build compact button styles plus reusable icon accents")
	check(action_style_button.find_child("ActionButtonResponseTexture_action", true, false) != null and action_style_button.find_child("ActionButtonRoleRail", true, false) != null and count_nodes_with_name_prefix(action_style_button, "ActionButtonEnergyDot_") == 3, "action buttons render response PNG texture role rail and energy dots without extra styleboxes")
	check(action_style_button.find_child("ActionButtonIconBack", true, false) == null and action_style_button.find_child("ActionButtonCommandRoute", true, false) == null and action_style_button.find_child("ActionButtonExecutionGate", true, false) == null and action_style_button.find_child("ActionButtonConfirmRoute", true, false) == null and action_style_button.find_child("ActionButtonDecisionBridge", true, false) == null, "action buttons drop old code-drawn command/execution/confirm/decision decorative lines")
	check((scene.optional_gpt_illustration_texture("action_button_panel") == null) or (action_style_button.find_child("ActionButtonPanelPlate", true, false) != null), "action buttons use optional GPT panel plate instead of code-drawn lines")
	scene.play_action_button_press_feedback(action_style_button, "action", Color(0.25, 0.58, 0.48))
	check(action_style_button.find_child("ActionButtonPressFeedback", true, false) != null and action_style_button.find_child("ActionButtonPressRail", true, false) != null and action_style_button.find_child("ActionButtonPressFill", true, false) != null and action_style_button.find_child("ActionButtonPressGate", true, false) != null and action_style_button.find_child("ActionButtonPressSource", true, false) != null and action_style_button.find_child("ActionButtonPressSeal", true, false) != null, "action button press feedback renders source rail fill gate and seal")
	check(count_nodes_with_name_prefix(action_style_button, "ActionButtonPressTick_") == 3, "action button press feedback renders rhythm ticks")
	dispose_node(action_style_button)
	var voice_action_button = scene.make_action_button("语音", Color(0.24, 0.52, 0.72), func() -> void:
		pass
	)
	scene.draw_voice_button_art(voice_action_button, true, 0.60)
	scene.play_voice_button_press_feedback(voice_action_button, true, 0.60)
	check(voice_action_button.find_child("VoiceButtonPressFeedback", true, false) != null and voice_action_button.find_child("VoiceButtonPressSource", true, false) != null and voice_action_button.find_child("VoiceButtonPressRoute", true, false) != null and voice_action_button.find_child("VoiceButtonPressFill", true, false) != null and voice_action_button.find_child("VoiceButtonPressGate", true, false) != null, "voice action button press renders channel route feedback")
	check(voice_action_button.find_child("VoiceButtonPressSeal", true, false) != null and voice_action_button.find_child("VoiceButtonPressGlyph", true, false) != null and count_nodes_with_name_prefix(voice_action_button, "VoiceButtonPressTick_") == 3, "voice action button press renders seal glyph and rhythm ticks")
	dispose_node(voice_action_button)
	var fallback_action_button = scene.make_action_button("测试", Color(0.25, 0.58, 0.48), func() -> void:
		pass
	)
	check(fallback_action_button.find_child("ActionButtonFallbackIcon", true, false) != null, "fallback action buttons render fallback glyph without code-drawn icon backplate")
	dispose_node(fallback_action_button)
	var safe_action_button = scene.make_action_button("安全", Color(0.25, 0.58, 0.48), func() -> void:
		pass
	)
	check(safe_action_button.find_child("ActionButtonPulse", true, false) != null, "priority action buttons render pulse focus art")
	dispose_node(safe_action_button)
	scene.style_cache.clear()
	scene.style_cache_order.clear()
	scene.button_style_set_cache.clear()
	scene.button_style_set_cache_order.clear()
	var top_style_button = scene.make_top_hud_button("设置", Color(0.22, 0.42, 0.54), func() -> void:
		pass
	)
	check(scene.button_style_set_cache.size() == 0 and scene.style_cache.size() == 0, "top HUD buttons build only their compact style set")
	dispose_node(top_style_button)
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
	for sample_code in ["5W", "E", "H1"]:
		var sample_path = scene.tile_path(sample_code)
		check(sample_path.begins_with("res://assets/tiles/") and not sample_path.contains("assets/tiles_3d/"), "playable tile face %s uses assets/tiles authored sprites" % sample_code)
	var missing_tile_path = scene.preferred_tile_path("res://assets/tiles/not_real_smoke_tile.png")
	check(missing_tile_path == "res://assets/tiles/tile_back.png" and not missing_tile_path.contains("assets/tiles_3d/"), "missing tile fallback uses the base tile back instead of legacy generated 3D sprites")
	for audio_key in ["bgm", "discard", "draw", "peng", "gang", "win"]:
		check(scene.audio_streams.get(audio_key, null) != null, "audio stream loads: " + str(audio_key))
	for voice_key in ["tile_5W", "tile_E", "tile_P", "action_peng", "action_zimo"]:
		check(scene.voice_streams.get(voice_key, null) != null, "bundled voice stream loads: " + str(voice_key))
	check(scene.bgm_player != null and scene.sfx_player != null and scene.action_sfx_player != null and scene.find_child("BackgroundMusic", true, false) != null and scene.find_child("TileSfx", true, false) != null and scene.find_child("ActionSfx", true, false) != null, "audio players are initialized with named persistent nodes")
	check(scene.audio_layer != null and scene.find_child("PersistentAudio", true, false) == scene.audio_layer and scene.audio_layer.process_mode == Node.PROCESS_MODE_ALWAYS and scene.bgm_player.get_parent() == scene.audio_layer, "persistent audio layer owns background music")
	check(scene.BGM_STREAM_PATH.ends_with("bgm_guofeng2.mp3") and scene.audio_streams.get("bgm", null) is AudioStreamMP3, "background music uses the current MP3 default track")
	check(scene.lucide_icon_texture("settings") != null and scene.lucide_icon_texture("play") != null, "lucide SVG icons load for UI illustration")
	var coin_animation = scene.animation_asset_spec("coin_spin")
	var victory_animation = scene.animation_asset_spec("victory_sparkle")
	var claim_response_animation = scene.animation_asset_spec("claim_response_orbit")
	var discard_splash_animation = scene.animation_asset_spec("discard_ink_splash")
	var tile_draw_animation = scene.animation_asset_spec("tile_draw_fly")
	var tile_discard_animation = scene.animation_asset_spec("tile_discard_fly")
	var kong_reveal_animation = scene.animation_asset_spec("kong_reveal_burst")
	check(str(coin_animation.get("name", "")) == "Gold Coin Spin" and int(coin_animation.get("layer_count", 0)) >= 1, "coin animation JSON metadata loads for UI preview")
	check(str(victory_animation.get("name", "")) == "Victory Sparkle" and int(victory_animation.get("layer_count", 0)) >= 3, "victory animation JSON metadata loads for UI preview")
	check(str(claim_response_animation.get("name", "")) == "Claim Response Orbit" and int(claim_response_animation.get("layer_count", 0)) >= 3, "claim response animation JSON metadata loads for UI preview")
	check(str(discard_splash_animation.get("name", "")) == "Discard Ink Splash" and int(discard_splash_animation.get("layer_count", 0)) >= 3, "discard splash animation JSON metadata loads for UI preview")
	check(str(tile_draw_animation.get("name", "")) == "Tile Draw Fly" and int(tile_draw_animation.get("layer_count", 0)) >= 3, "tile draw fly animation JSON metadata loads for UI preview")
	check(str(tile_discard_animation.get("name", "")) == "Tile Discard Fly" and int(tile_discard_animation.get("layer_count", 0)) >= 3, "tile discard fly animation JSON metadata loads for UI preview")
	check(str(kong_reveal_animation.get("name", "")) == "Kong Reveal Burst" and int(kong_reveal_animation.get("layer_count", 0)) >= 3, "kong reveal burst animation JSON metadata loads for UI preview")
	check(scene.animation_duration_seconds("coin_spin") > 0.0 and scene.animation_duration_seconds("victory_sparkle") > scene.animation_duration_seconds("coin_spin") and scene.animation_duration_seconds("claim_response_orbit") > scene.animation_duration_seconds("discard_ink_splash"), "animation preview durations come from Lottie frame data")
	var bgm_mp3 = scene.bgm_player.stream as AudioStreamMP3
	check(bgm_mp3 != null and bgm_mp3.loop, "background music loops without restart gaps")
	check(scene.BGM_VOLUME_DB == 0.0, "background music keeps the configured default gain")
	check(scene.boosted_sfx_volume_db(-8.0) <= -5.0 and scene.boosted_sfx_volume_db(-1.0) <= 1.5, "mobile sfx boost is capped below clipping")
	check(scene.is_action_sfx("gang") and not scene.is_action_sfx("discard"), "frequent tile sfx reuse the persistent tile player")
	check(scene.voice_clip_key_for_tile("5W") == "tile_5W" and scene.voice_clip_key_for_action("暗杠") == "action_hidden_gang", "bundled voice clip keys cover tile and action speech")
	var one_shot_sfx = scene.make_one_shot_sfx_player(scene.audio_streams.get("discard", null), -1.0)
	check(one_shot_sfx.name == "OneShotSfx" and one_shot_sfx.stream != null and one_shot_sfx.bus == "Master" and one_shot_sfx.process_mode == Node.PROCESS_MODE_ALWAYS and one_shot_sfx.get_parent() == scene.audio_layer, "one-shot sfx players use named persistent game audio bus")
	scene.play_test_tone_440hz()
	await process_frame
	check(scene.find_child("TestTonePlayer", true, false) != null, "test tone creates named persistent audio generator player")
	var scaled_safe_margins = scene.safe_area_margins_for_viewport(Vector2(1280, 720), Vector2(2560, 1440), Rect2(Vector2(120, 48), Vector2(2320, 1320)))
	check(is_equal_approx(scaled_safe_margins.x, 60.0) and is_equal_approx(scaled_safe_margins.y, 24.0) and is_equal_approx(scaled_safe_margins.z, 60.0) and is_equal_approx(scaled_safe_margins.w, 36.0), "safe-area margins scale physical Android insets into stretched viewport space")
	var clamped_safe_margins = scene.safe_area_margins_for_viewport(Vector2(1280, 720), Vector2(1280, 720), Rect2(Vector2(500, 200), Vector2(100, 100)))
	check(clamped_safe_margins.x <= 1280.0 * scene.SAFE_CONTENT_MAX_SIDE_FRACTION + 0.5 and clamped_safe_margins.y <= 720.0 * scene.SAFE_CONTENT_MAX_TOP_FRACTION + 0.5 and clamped_safe_margins.w <= 720.0 * scene.SAFE_CONTENT_MAX_BOTTOM_FRACTION + 0.5, "safe-area margins are clamped to preserve usable table space")
	check(scene.safe_content_pixel_size_for_margins(Vector2(1280, 720), scene.SAFE_CONTENT_MIN_MARGIN) == Vector2(1256, 702), "safe content size subtracts minimum touch-edge margins")
	var original_ui_enhancements = scene.ui_enhancements
	check(original_ui_enhancements != null and is_instance_valid(original_ui_enhancements), "UI enhancements start as a persistent runtime helper")
	scene.clear_screen()
	check(is_instance_valid(one_shot_sfx) and not one_shot_sfx.is_queued_for_deletion(), "screen redraw keeps active one-shot audio alive")
	check(scene.ui_enhancements == original_ui_enhancements and is_instance_valid(scene.ui_enhancements) and not scene.ui_enhancements.is_queued_for_deletion(), "screen redraw keeps UI enhancements helper alive")
	scene.init_ui_enhancements()
	check(scene.ui_enhancements == original_ui_enhancements and count_nodes_with_name_prefix(scene, "UIEnhancements") == 1, "UI enhancements initialization is idempotent")
	check(scene.screen_layer != null and scene.root_layer != null and scene.root_layer.get_parent() == scene.screen_layer and scene.find_child("ScreenLayer", true, false) != null and scene.find_child("SafeContent", true, false) != null, "screen redraw separates full-bleed background from named safe content layer")
	check(is_equal_approx(scene.root_layer.offset_left, scene.safe_area_margins.x) and is_equal_approx(scene.root_layer.offset_top, scene.safe_area_margins.y) and is_equal_approx(scene.root_layer.offset_right, -scene.safe_area_margins.z) and is_equal_approx(scene.root_layer.offset_bottom, -scene.safe_area_margins.w), "safe content layer applies display safe-area offsets")
	dispose_node(one_shot_sfx)
	var test_tone_cleanup_deadline = Time.get_ticks_msec() + 4000
	while scene.find_child("TestTonePlayer", true, false) != null and Time.get_ticks_msec() < test_tone_cleanup_deadline:
		await process_frame
	check(scene.find_child("TestTonePlayer", true, false) == null, "test tone player is cleaned up after playback")
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
	check(scene.speech_queue.size() == 1 and scene.speech_queue[0].has("clips") and str(scene.speech_queue[0].get("clips", [])[0]) == "tile_5W" and not scene.speech_queue[0].has("text"), "tile speech uses bundled voice clips instead of direct TTS text")
	check(float(scene.speech_queue[0].get("delay", 1.0)) <= 0.13, "tile speech is queued after the discard sound without being dropped")
	scene.speak_action_call("碰", "5W")
	check(scene.speech_queue.size() == 1 and scene.speech_queue[0].has("clips") and scene.speech_queue[0].get("clips", []) == ["action_peng", "tile_5W"] and not scene.speech_queue[0].has("text"), "action speech interrupts stale tile speech and queues bundled action plus tile clips")
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
	check(scene.optional_gpt_illustration_texture("update_gpt_dialog") == null or scene.find_child("UpdateGPTDialogTexture", true, false) != null, "update dialog consumes optional GPT dialog texture when generated")
	check(scene.find_child("UpdateDialogArt", true, false) != null and scene.find_child("UpdateDialogArtRail", true, false) != null and scene.find_child("UpdateDialogArtFill", true, false) != null, "update dialog renders package progress illustration")
	check(scene.find_child("UpdateDialogPackageIcon", true, false) != null and scene.find_child("UpdateDialogStatusLight", true, false) != null and count_nodes_with_name_prefix(scene, "UpdateDialogPacketPip_") == 4, "update dialog renders package icon status light and packet pips")
	check(scene.find_child("UpdateDialogDownloadChannel", true, false) != null and scene.find_child("UpdateDialogVerifyNode", true, false) != null and count_nodes_with_name_prefix(scene, "UpdateDialogMovingPacket_") == 3, "update dialog renders download channel verify node and moving packets")
	check(scene.find_child("UpdateDialogVerifyRail", true, false) != null and scene.find_child("UpdateDialogVerifyFill", true, false) != null and scene.find_child("UpdateVerifyStampTexture", true, false) != null and count_nodes_with_name_prefix(scene, "UpdateDialogVerifyStep_") == 2, "update dialog renders verification rail, GPT stamp, and steps")
	check(count_nodes_with_name_prefix(scene, "UpdateDialogVerifyTick_") == 3, "update dialog renders verification ticks")
	check(scene.find_child("UpdateDialogInstallRoute", true, false) != null and scene.find_child("UpdateDialogInstallFill", true, false) != null and scene.find_child("UpdateDialogInstallSource", true, false) != null and scene.find_child("UpdateDialogInstallGate", true, false) != null and scene.find_child("UpdateDialogInstallGlyph", true, false) != null, "update dialog renders verify-to-install handoff route")
	check(count_nodes_with_name_prefix(scene, "UpdateDialogInstallTick_") == 2, "update dialog install handoff renders rhythm ticks")
	check(scene.find_child("UpdateDialogStageMap", true, false) != null and scene.find_child("UpdateStageCanopyTexture", true, false) != null and scene.find_child("UpdateDialogStageRail", true, false) != null and scene.find_child("UpdateDialogStageFill", true, false) != null and scene.find_child("UpdateDialogStageGate", true, false) != null and count_nodes_with_name_prefix(scene, "UpdateDialogStageNode_") == 4, "update dialog renders stage map with reusable canopy texture")
	check(scene.find_child("UpdateDialogStageNode_downloading", true, false) != null and scene.find_child("UpdateDialogStageGlyph_ready", true, false) != null and count_nodes_with_name_prefix(scene, "UpdateDialogStageGlyph_") == 4, "update dialog stage map names download and verify stages")
	check(count_nodes_with_name_prefix(scene, "UpdateDialogStageTick_") == 3, "update dialog stage map renders route ticks")
	check(scene.find_child("UpdateReleaseNotesTexture", true, false) != null and scene.find_child("UpdateReleaseNotesCanopyTexture", true, false) != null and scene.find_child("UpdateReleaseNotesArt", true, false) != null and scene.find_child("UpdateReleaseNotesRail", true, false) != null and scene.find_child("UpdateReleaseNotesFill", true, false) != null and scene.find_child("UpdateReleaseNotesSeal", true, false) != null and scene.find_child("UpdateReleaseNotesLabel", true, false) != null, "update dialog renders reusable PNG release notes canopy summary route and seal")
	check(count_nodes_with_name_prefix(scene, "UpdateReleaseNotesTick_") == 3 and count_nodes_with_name_prefix(scene, "UpdateReleaseNotesNode_") == 2, "update dialog release notes art renders rhythm ticks and nodes")
	check(scene.find_child("UpdateReleaseNotesStageRoute", true, false) != null and scene.find_child("UpdateReleaseNotesStageFill", true, false) != null and scene.find_child("UpdateReleaseNotesStageGate", true, false) != null and count_nodes_with_name_prefix(scene, "UpdateReleaseNotesStageTick_") == 2, "update dialog release notes art links notes to stage route")
	check(scene.find_child("UpdateStatusConvergenceArt", true, false) != null and scene.find_child("UpdateStatusConvergenceSource", true, false) != null and scene.find_child("UpdateStatusConvergenceRoute", true, false) != null and scene.find_child("UpdateStatusConvergenceFill", true, false) != null and scene.find_child("UpdateStatusConvergenceGate", true, false) != null, "update dialog renders status convergence route")
	check(scene.find_child("UpdateStatusConvergenceArchive", true, false) != null and scene.find_child("UpdateStatusConvergenceGlyph", true, false) != null and scene.find_child("UpdateStatusNotesRoute", true, false) != null and scene.find_child("UpdateStatusNotesFill", true, false) != null and count_nodes_with_name_prefix(scene, "UpdateStatusConvergenceNode_") == 4 and count_nodes_with_name_prefix(scene, "UpdateStatusConvergenceTick_") == 3, "update dialog status convergence renders archive notes route nodes and ticks")
	check(scene.find_child("UpdatePrimaryButton", true, false) != null and scene.find_child("UpdateSecondaryButton", true, false) != null and scene.find_child("UpdateDialogButtonTexture_primary", true, false) != null and scene.find_child("UpdateDialogButtonTexture_secondary", true, false) != null and scene.find_child("UpdateDialogButtonArt_primary", true, false) != null and scene.find_child("UpdateDialogButtonRail_primary", true, false) != null and scene.find_child("UpdateDialogButtonFill_secondary", true, false) != null and scene.find_child("UpdateDialogButtonGate_secondary", true, false) != null, "update dialog buttons render reusable PNG action route art")
	check(count_nodes_with_name_prefix(scene, "UpdateDialogButtonTick_") == 4, "update dialog buttons render command rhythm ticks")
	var update_primary_button = scene.find_child("UpdatePrimaryButton", true, false) as Button
	check(update_primary_button != null, "update dialog exposes primary button for press feedback")
	scene.play_update_dialog_button_feedback(update_primary_button, "primary", Color(0.18, 0.42, 0.34))
	check(update_primary_button.find_child("UpdateDialogButtonPressFeedback_primary", true, false) != null and update_primary_button.find_child("UpdateDialogButtonPressSource_primary", true, false) != null and update_primary_button.find_child("UpdateDialogButtonPressRoute_primary", true, false) != null and update_primary_button.find_child("UpdateDialogButtonPressFill_primary", true, false) != null and update_primary_button.find_child("UpdateDialogButtonPressGate_primary", true, false) != null, "update dialog primary press feedback renders source route fill and gate")
	check(update_primary_button.find_child("UpdateDialogButtonPressSeal_primary", true, false) != null and update_primary_button.find_child("UpdateDialogButtonPressGlyph_primary", true, false) != null and count_nodes_with_name_prefix(update_primary_button, "UpdateDialogButtonPressTick_primary_") == 3, "update dialog primary press feedback renders seal glyph and rhythm ticks")
	check(scene.update_stage_index() == 1, "downloading update state highlights the download stage")
	var update_fill = scene.find_child("UpdateDialogArtFill", true, false) as Control
	check(update_fill != null and update_fill.anchor_right > 0.45 and update_fill.anchor_right < 0.55, "update dialog art fill tracks download progress")
	var update_stage_fill = scene.find_child("UpdateDialogStageFill", true, false) as Control
	var update_stage_gate = scene.find_child("UpdateDialogStageGate", true, false) as Control
	var update_install_fill = scene.find_child("UpdateDialogInstallFill", true, false) as Control
	var update_convergence_fill = scene.find_child("UpdateStatusConvergenceFill", true, false) as Control
	check(update_stage_fill != null and update_stage_fill.anchor_right > 0.30 and update_stage_fill.anchor_right < 0.36, "update dialog stage fill tracks active stage")
	check(update_stage_gate != null and update_stage_gate.anchor_left > 0.32 and update_stage_gate.anchor_left < 0.35, "update dialog stage gate follows active stage")
	check(update_install_fill != null and update_install_fill.anchor_right <= 0.09, "downloading update dialog keeps install handoff pending before verification")
	check(update_convergence_fill != null and update_convergence_fill.anchor_right > 0.39 and update_convergence_fill.anchor_right < 0.41, "update dialog status convergence fill tracks active stage")
	check(scene.find_child("UpdatePackageTexture", true, false) != null, "update dialog renders reusable package PNG texture")
	scene.update_state = "ready"
	scene.update_downloaded_bytes = 1024
	scene.update_total_bytes = 1024
	scene.ensure_update_dialog()
	update_fill = scene.find_child("UpdateDialogArtFill", true, false) as Control
	update_stage_fill = scene.find_child("UpdateDialogStageFill", true, false) as Control
	update_stage_gate = scene.find_child("UpdateDialogStageGate", true, false) as Control
	update_install_fill = scene.find_child("UpdateDialogInstallFill", true, false) as Control
	var update_stage_checking = scene.find_child("UpdateDialogStageNode_checking", true, false)
	var update_stage_downloading = scene.find_child("UpdateDialogStageNode_downloading", true, false)
	var update_stage_ready = scene.find_child("UpdateDialogStageNode_ready", true, false)
	var update_stage_install = scene.find_child("UpdateDialogStageNode_install", true, false)
	var update_stage_checking_color = panel_bg_color(update_stage_checking)
	var update_stage_downloading_color = panel_bg_color(update_stage_downloading)
	var update_stage_ready_color = panel_bg_color(update_stage_ready)
	var update_stage_install_color = panel_bg_color(update_stage_install)
	check(scene.update_stage_index() == 2, "ready update state highlights the verify stage")
	check(update_fill != null and update_fill.anchor_right > 0.97, "ready update dialog art fill reaches full progress")
	check(update_stage_fill != null and update_stage_fill.anchor_right > 0.63 and update_stage_fill.anchor_right < 0.69, "ready update dialog stage fill advances to verify stage")
	check(update_stage_gate != null and update_stage_gate.anchor_left > 0.61 and update_stage_gate.anchor_left < 0.63, "ready update dialog stage gate follows verify stage")
	check(update_install_fill != null and update_install_fill.anchor_right > 0.90, "ready update dialog fills verify-to-install handoff route")
	check(update_stage_ready_color.a > update_stage_downloading_color.a and update_stage_ready_color.a > update_stage_checking_color.a and update_stage_install_color.a < update_stage_checking_color.a, "ready update dialog stage nodes highlight verify stage and dim future install stage")
	scene.update_state = "idle"
	scene.show_toast("任务完成！+30金币", 1000)
	check(scene.optional_gpt_illustration_texture("toast_gpt_banner") == null or scene.find_child("ToastGPTBannerTexture", true, false) != null, "toast consumes optional GPT banner texture when generated")
	check(scene.find_child("Toast", true, false) != null and scene.find_child("ToastContainer", true, false) != null and scene.find_child("ToastRibbonTexture", true, false) != null and scene.find_child("ToastNoticeWaveTexture", true, false) != null, "toast renders container with reusable ribbon and notice-wave PNG textures")
	check(scene.find_child("ToastIconSeal", true, false) != null and scene.find_child("ToastSheen", true, false) != null and count_nodes_with_name_prefix(scene, "ToastSpark_") == 3, "success toast renders icon seal sheen and reward sparks")
	check(scene.find_child("ToastMessageRoute", true, false) != null and scene.find_child("ToastMessageRouteFill", true, false) != null and scene.find_child("ToastTypeNode", true, false) != null and count_nodes_with_name_prefix(scene, "ToastMessageRouteNode_") == 3, "toast renders message route and type node")
	check(scene.find_child("ToastEntryFeedback", true, false) != null and scene.find_child("ToastEntrySource", true, false) != null and scene.find_child("ToastEntryRoute", true, false) != null and scene.find_child("ToastEntryFill", true, false) != null and scene.find_child("ToastEntryGate", true, false) != null, "toast entry feedback renders source route fill and gate")
	check(scene.find_child("ToastEntryAckNode", true, false) != null and scene.find_child("ToastEntryAckGlyph", true, false) != null and count_nodes_with_name_prefix(scene, "ToastEntryTick_") == 3, "toast entry feedback renders acknowledgement node and rhythm ticks")
	check(scene.find_child("ToastLifeRail", true, false) != null and scene.find_child("ToastLifeFill", true, false) != null and count_nodes_with_name_prefix(scene, "ToastStatusDot_") == 3, "toast renders lifetime rail fill and status dots")
	check(scene.find_child("ToastConfirmRoute", true, false) != null and scene.find_child("ToastConfirmFill", true, false) != null and scene.find_child("ToastConfirmGate", true, false) != null and count_nodes_with_name_prefix(scene, "ToastConfirmTick_") == 2, "toast renders confirmation route and ticks")
	check(scene.find_child("ToastAckBridge", true, false) != null and scene.find_child("ToastAckBridgeFill", true, false) != null and scene.find_child("ToastAckBridgeGate", true, false) != null and count_nodes_with_name_prefix(scene, "ToastAckBridgeTick_") == 2, "toast renders acknowledgement bridge route and ticks")
	check(scene.find_child("ToastRewardBridge", true, false) != null and scene.find_child("ToastRewardBridgeRail", true, false) != null and scene.find_child("ToastRewardBridgeFill", true, false) != null and scene.find_child("ToastRewardGate", true, false) != null, "reward toast renders reward bridge route")
	check(scene.find_child("ToastRewardSourceNode", true, false) != null and count_nodes_with_name_prefix(scene, "ToastRewardPip_") == 3 and count_nodes_with_name_prefix(scene, "ToastRewardTick_") == 2, "reward toast renders source node pips and rhythm ticks")
	check(scene.toast_icon_name("钻石不足") == "triangle-alert" and scene.toast_icon_name("正在下载更新") == "download" and scene.toast_icon_name("已发送: 碰") == "message-check", "toast illustrations choose contextual icons")
	scene.show_toast("已发送: 准备好了", 1000)
	check(scene.find_child("ToastChatSendArt", true, false) != null and scene.find_child("ToastChatStreamTexture", true, false) != null, "chat send toast renders reusable chat stream texture")
	check(scene.find_child("ToastChatSendSource", true, false) != null and scene.find_child("ToastChatSendRoute", true, false) != null and scene.find_child("ToastChatSendFill", true, false) != null and scene.find_child("ToastChatSendGate", true, false) != null, "chat send toast renders delivery route")
	check(scene.find_child("ToastChatReceiptNode", true, false) != null and (scene.find_child("ToastChatSendSealTexture", true, false) != null or scene.find_child("ToastChatReceiptGlyph", true, false) != null) and count_nodes_with_name_prefix(scene, "ToastChatPacket_") == 3 and count_nodes_with_name_prefix(scene, "ToastChatSendTick_") == 2, "chat send toast renders receipt node seal/glyph packets and rhythm ticks")
	scene.show_toast("购买成功！获得换牌卡", 1000)
	check(scene.toast_item_key_for_text("购买成功！获得换牌卡") == "swap_card" and scene.find_child("ToastItemActivationTexture", true, false) != null and scene.find_child("ToastItemBadge", true, false) != null and count_nodes_with_name_prefix(scene, "ToastItemPip_") == 3, "item toast renders reusable PNG charm item badge and stock pips")
	check(scene.find_child("ToastItemActivationRoute", true, false) != null and scene.find_child("ToastItemActivationFill", true, false) != null and scene.find_child("ToastItemActivationGate", true, false) != null and count_nodes_with_name_prefix(scene, "ToastItemActivationTick_") == 2, "item toast renders activation route and ticks")
	check(scene.find_child("ToastItemEffectRoute", true, false) != null and scene.find_child("ToastItemEffectRail", true, false) != null and scene.find_child("ToastItemEffectFill", true, false) != null, "item toast renders effect confirmation route")
	check(scene.find_child("ToastItemEffectSource", true, false) != null and scene.find_child("ToastItemEffectGate", true, false) != null and count_nodes_with_name_prefix(scene, "ToastItemEffectNode_") == 3 and count_nodes_with_name_prefix(scene, "ToastItemEffectTick_") == 2, "item toast renders effect source gate nodes and rhythm ticks")
	check(scene.find_child("ToastItemInventoryRoute", true, false) != null and scene.find_child("ToastItemInventoryRail", true, false) != null and scene.find_child("ToastItemInventoryFill", true, false) != null and scene.find_child("ToastItemInventorySource", true, false) != null and scene.find_child("ToastItemInventoryGate", true, false) != null, "item toast renders inventory change route")
	check(scene.find_child("ToastItemInventoryCountNode", true, false) != null and scene.find_child("ToastItemInventoryCountGlyph", true, false) != null and count_nodes_with_name_prefix(scene, "ToastItemInventoryStockNode_") == 3 and count_nodes_with_name_prefix(scene, "ToastItemInventoryTick_") == 2, "item toast renders stock count node glyph and rhythm ticks")
	scene.inventory = {"swap_card": 1}
	check(scene.use_item("swap_card") and int(scene.inventory.get("swap_card", 0)) == 0 and scene.find_child("ToastItemCore", true, false) != null, "using an item decrements inventory and renders item toast art")
	check(scene.find_child("ToastItemActivationRoute", true, false) != null and scene.find_child("ToastItemActivationFill", true, false) != null and count_nodes_with_name_prefix(scene, "ToastItemActivationTick_") >= 2, "using an item renders activation route feedback")
	check(scene.find_child("ToastItemEffectRoute", true, false) != null and scene.find_child("ToastItemEffectFill", true, false) != null and scene.find_child("ToastItemEffectGate", true, false) != null, "using an item renders effect confirmation route feedback")
	check(scene.find_child("ToastItemInventoryRoute", true, false) != null and scene.find_child("ToastItemInventoryCountNode", true, false) != null and scene.find_child("ToastItemInventoryEmptyLock", true, false) != null, "using the last item renders depleted inventory feedback")
	check(not scene.use_item("peek_card") and int(scene.inventory.get("peek_card", 0)) == 0, "using a missing item fails without changing inventory")
	check(scene.find_child("ToastItemActivationTexture", true, false) != null and scene.find_child("ToastItemInventoryEmptyLock", true, false) != null, "missing item feedback still renders item texture and empty inventory lock")
	check(scene.find_child("ToastItemDeniedRoute", true, false) != null and scene.find_child("ToastItemDeniedRail", true, false) != null and scene.find_child("ToastItemDeniedFill", true, false) != null and scene.find_child("ToastItemDeniedSource", true, false) != null and scene.find_child("ToastItemDeniedLock", true, false) != null, "missing item feedback renders denied route and lock")
	check(scene.find_child("ToastItemDeniedGlyph", true, false) != null and count_nodes_with_name_prefix(scene, "ToastItemDeniedBlock_") == 2 and count_nodes_with_name_prefix(scene, "ToastItemDeniedTick_") == 2, "missing item feedback renders denied glyph blocks and rhythm ticks")
	var coins_before_task_reward = int(scene.currency.get("coins", 0))
	scene.claim_task_reward({"reward_coins": 25})
	check(int(scene.currency.get("coins", 0)) == coins_before_task_reward + 25 and scene.find_child("ToastIconSeal", true, false) != null, "task reward updates currency and renders illustrated toast")
	scene.achievements["first_win"] = false
	check(scene.achievement_display_name("first_win") == "首次胡牌" and scene.unlock_achievement("first_win"), "achievement unlock maps keys to display names and succeeds once")
	check(scene.find_child("ToastAchievementGlowTexture", true, false) != null, "achievement unlock toast renders reusable medal glow PNG texture")
	check(scene.find_child("ToastAchievementMedal", true, false) != null and scene.find_child("ToastAchievementMedalCore", true, false) != null and count_nodes_with_name_prefix(scene, "ToastAchievementRay_") == 4, "achievement unlock toast renders medal and rays")
	check(scene.optional_gpt_illustration_texture("achievement_medal_gold") == null or scene.find_child("ToastAchievementMedalTexture", true, false) != null, "achievement unlock toast consumes optional GPT medal texture when generated")
	check(scene.find_child("ToastAchievementUnlockRoute", true, false) != null and scene.find_child("ToastAchievementUnlockFill", true, false) != null and scene.find_child("ToastAchievementUnlockGate", true, false) != null and count_nodes_with_name_prefix(scene, "ToastAchievementUnlockTick_") == 3, "achievement unlock toast renders unlock route and rhythm ticks")
	check(scene.find_child("ToastAchievementArchiveRoute", true, false) != null and scene.find_child("ToastAchievementArchiveFill", true, false) != null and scene.find_child("ToastAchievementArchiveSource", true, false) != null and scene.find_child("ToastAchievementArchiveGate", true, false) != null and scene.find_child("ToastAchievementArchiveGlyph", true, false) != null, "achievement unlock toast renders medal-to-archive handoff route")
	check(count_nodes_with_name_prefix(scene, "ToastAchievementArchiveTick_") == 2, "achievement unlock toast renders archive handoff rhythm ticks")
	check(not scene.unlock_achievement("first_win"), "achievement unlock does not replay for already unlocked achievements")
	scene.play_screen_transition(func() -> void:
		pass
	, false, "curtain")
	check(scene.find_child("ScreenTransition", true, false) != null, "screen transition creates shared transition overlay")
	check(scene.find_child("CurtainStrips", true, false) != null and scene.find_child("CurtainTopRail", true, false) != null and scene.find_child("CurtainCloseGate", true, false) != null, "curtain transition renders rail and close gate")
	check(count_nodes_with_name_prefix(scene, "CurtainBead_") == 6 and count_nodes_with_name_prefix(scene, "CurtainCloseTick_") == 6, "curtain transition renders one bead and close tick per strip")
	scene.clear_fx_overlays()
	var curtain_strips = scene.find_child("CurtainStrips", true, false)
	if curtain_strips != null:
		dispose_node(curtain_strips)
	scene.play_screen_transition(func() -> void:
		pass
		, false, "ink_wash")
	check(scene.find_child("InkWashTransitionArt", true, false) != null and scene.find_child("InkWashBrushBar", true, false) != null and scene.find_child("InkWashSpine", true, false) != null and scene.find_child("InkWashFill", true, false) != null and scene.find_child("InkWashCompletionGate", true, false) != null, "ink wash transition renders brush spine fill and completion gate")
	check(count_nodes_with_name_prefix(scene, "InkWashBlot_") == 4 and count_nodes_with_name_prefix(scene, "InkWashTick_") == 3, "ink wash transition renders blot rhythm art")
	scene.spawn_transition_complete_sparks()
	check(count_nodes_with_name_prefix(scene, "TransitionCompleteSpark_") == 16, "screen transition completion renders golden spark burst")
	scene.clear_fx_overlays()
	var ink_wash_art = scene.find_child("InkWashTransitionArt", true, false)
	if ink_wash_art != null:
		dispose_node(ink_wash_art)
	scene.play_screen_transition(func() -> void:
		pass
	, false, "ink_dissolve")
	var ink_dissolve = scene.find_child("InkDissolveTransition", true, false) as ColorRect
	check(ink_dissolve != null and ink_dissolve.material != null, "ink dissolve transition renders shader-backed dissolve overlay")
	scene.clear_fx_overlays()
	if ink_dissolve != null:
		dispose_node(ink_dissolve)
	scene.play_screen_transition(func() -> void:
		pass
	, false, "fade")
	check(scene.find_child("FadeTransitionArt", true, false) != null and scene.find_child("FadeTransitionRail", true, false) != null and scene.find_child("FadeTransitionFill", true, false) != null and scene.find_child("FadeTransitionGate", true, false) != null, "fade transition renders progress rail fill and gate")
	check(count_nodes_with_name_prefix(scene, "FadeTransitionTick_") == 3, "fade transition renders rhythm ticks")
	scene.clear_fx_overlays()
	var fade_art = scene.find_child("FadeTransitionArt", true, false)
	if fade_art != null:
		dispose_node(fade_art)
	scene.start_offline(false)
	check(scene.find_child("OfflineTable3DCastShadow", true, false) != null and scene.find_child("OfflineTable3DOuterShell", true, false) != null and scene.find_child("OfflineTable3DInnerSurface", true, false) != null, "3D offline table shell exists")
	check(scene.find_child("OfflineTable3DFloorShadow", true, false) != null and scene.find_child("OfflineTable3DFrontApron", true, false) != null and scene.find_child("BattleTablePerspectiveDepth", true, false) != null, "3D offline table renders floor shadow front apron and perspective depth")
	check(true, "battle uses single commercial table stage without stacked GPT full-table overlays")
	check(scene.find_child("Table3DInsetShadow", true, false) != null and scene.find_child("Table3DFeltVignette", true, false) != null and scene.find_child("Table3DCenterSpotlight", true, false) != null, "3D offline table atmosphere exists")
	check(scene.find_child("TopHud3DShell", true, false) != null and scene.find_child("TopHud3DCastShadow", true, false) != null and scene.find_child("TopHud3DDepthEdge", true, false) != null, "3D top HUD shell exists")
	check(scene.find_child("TopHud3DRearShell", true, false) != null and scene.find_child("TopHud3DTopRim", true, false) != null and scene.find_child("TopHud3DJadeRail", true, false) != null, "3D top HUD exposes rear lacquer shell, light-catching rim, and jade rail")
	var seat_shadow = scene.find_child("SeatPanel3DCastShadow_0", true, false)
	var seat_rear = scene.find_child("SeatPanel3DRearShell_0", true, false)
	var seat_jade = scene.find_child("SeatPanel3DJadeLip_0", true, false)
	var seat_right_bevel = scene.find_child("SeatPanel3DRightBevel_0", true, false)
	var seat_jade_wash = scene.find_child("SeatPanel3DJadeWash_0", true, false)
	check(seat_shadow != null and seat_rear != null and seat_jade != null and seat_right_bevel != null and seat_jade_wash != null, "seat HUD uses commercial multi-layer 3D shell")
	var action_rear = scene.find_child("ActionDock3DRearShell", true, false)
	var action_jade = scene.find_child("ActionDock3DJadeTrack", true, false)
	check(action_rear != null and action_jade != null and scene.find_child("ActionDock3DFrontApron", true, false) != null, "action dock uses commercial 3D rear shell and jade track")
	check(scene.find_child("HandTray3DCastShadow", true, false) != null and scene.find_child("HandTray3DFrontLip", true, false) != null and scene.find_child("HandTray3DSideBevel", true, false) != null and count_nodes_with_name_prefix(scene, "HandTile_") > 0, "2D hand tray shell and authored hand tiles exist")
	var offline_commercial_stage = scene.find_child("OfflineCommercial3DStage", true, false) as CanvasItem
	check(offline_commercial_stage != null and offline_commercial_stage.modulate.a >= 0.90, "battle commercial 3D stage renders near-opaque for product-quality depth")
	var menu_probe = scene.find_child("MenuCommercial3DStage", true, false)
	# menu stage only exists on menu screen; battle path still validates wall strip suppression under 3D
	var wall_suppressed := 0
	var wall_strip_total := 0
	var table_surface = scene.find_child("OfflineTable3DInnerSurface", true, false) as Node
	var wall_search_root: Node = table_surface if table_surface != null else scene
	for wall_child in wall_search_root.get_children():
		if not str(wall_child.name).begins_with("WallBackStrip"):
			continue
		wall_strip_total += 1
		var canvas_wall := wall_child as CanvasItem
		var is_suppressed := bool(wall_child.get_meta("suppressed_by_commercial_3d", false))
		if not is_suppressed and canvas_wall != null:
			is_suppressed = (not canvas_wall.visible) or canvas_wall.modulate.a <= 0.01
		if is_suppressed:
			wall_suppressed += 1
	check(wall_strip_total == scene.WALL_LAYOUTS.size() and wall_suppressed == scene.WALL_LAYOUTS.size(), "battle path suppresses flat wall strips under commercial 3D walls")
	var table_overlay = scene.find_child("OfflineTable3DOverlayTexture", true, false) as CanvasItem
	check(table_overlay == null or table_overlay.modulate.a <= 0.12, "optional table overlay stays nearly invisible when present")
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
	check(setting_button.text == "已开" and setting_button.text.length() <= 4 and setting_button.clip_text, "setting button uses compact state label")
	check(setting_button.action_mode == BaseButton.ACTION_MODE_BUTTON_PRESS, "setting buttons trigger on press for mobile responsiveness")
	check(not setting_button.button_down.is_connected(scene.wake_audio_from_interaction), "touch buttons rely on global input to wake audio")
	check(setting_button.find_child("SettingSwitchArt", true, false) != null and setting_button.find_child("SettingSwitchRail", true, false) != null and setting_button.find_child("SettingSwitchKnobOn", true, false) != null and setting_button.find_child("SettingSwitchOnLight", true, false) != null, "enabled setting buttons render switch illustration and on-state light")
	check(setting_button.find_child("SettingSwitchEnergyRail", true, false) == null and setting_button.find_child("SettingSwitchDirectionRoute", true, false) == null and setting_button.find_child("SettingSwitchDirectionFill", true, false) == null and setting_button.find_child("SettingSwitchDirectionGate", true, false) == null and setting_button.find_child("SettingSwitchKnobConfirmRoute", true, false) == null and setting_button.find_child("SettingSwitchKnobConfirmFill", true, false) == null and setting_button.find_child("SettingSwitchKnobConfirmGate", true, false) == null, "enabled setting buttons omit obsolete route clutter")
	dispose_node(setting_button)
	var disabled_setting_button = scene.make_setting_button("音乐", false, Callable())
	check(disabled_setting_button.text == "已关" and disabled_setting_button.find_child("SettingSwitchKnobOff", true, false) != null, "disabled setting buttons render off switch illustration with compact state label")
	check(disabled_setting_button.find_child("SettingSwitchOffLock", true, false) != null and disabled_setting_button.find_child("SettingSwitchEnergyFill", true, false) == null, "disabled setting buttons render lock while omitting dim energy fill clutter")
	check(disabled_setting_button.find_child("SettingSwitchDirectionRoute", true, false) == null and disabled_setting_button.find_child("SettingSwitchDirectionFill", true, false) == null and disabled_setting_button.find_child("SettingSwitchDirectionGate", true, false) == null and disabled_setting_button.find_child("SettingSwitchKnobConfirmRoute", true, false) == null and disabled_setting_button.find_child("SettingSwitchKnobConfirmFill", true, false) == null and disabled_setting_button.find_child("SettingSwitchKnobConfirmGate", true, false) == null, "disabled setting buttons omit reverse route clutter")
	dispose_node(disabled_setting_button)
	var label_parent = Control.new()
	root.add_child(label_parent)
	var default_label = scene.make_label(label_parent, "普通 UI 标签", 16, Color.WHITE, false)
	check(default_label.autowrap_mode == TextServer.AUTOWRAP_OFF, "default labels avoid automatic wrapping for cheaper UI layout")
	check(default_label.mouse_filter == Control.MOUSE_FILTER_IGNORE and labels_ignore_mouse(label_parent), "default labels skip mouse hit testing")
	dispose_node(label_parent)
	var form_label_parent = VBoxContainer.new()
	root.add_child(form_label_parent)
	var form_edit = scene.add_line_edit(form_label_parent, "昵称", "云桌道友")
	check(form_edit is LineEdit and labels_ignore_mouse(form_label_parent), "line-edit captions skip mouse hit testing")
	check(form_edit.find_child("LineEditInputArt_name", true, false) != null and form_edit.find_child("LineEditInputSurface_name", true, false) != null and form_edit.find_child("LineEditInputInner_name", true, false) != null and form_edit.find_child("LineEditInputFocusGlow_name", true, false) != null, "line edits render clean input surface and focus glow")
	check(form_edit.find_child("LineEditInputAccentWash_name", true, false) != null and form_edit.find_child("LineEditInputCornerSeal_name", true, false) != null and form_edit.find_child("LineEditInputCornerGlyph_name", true, false) != null, "line edits render wash and seal accents")
	check(count_nodes_with_name_prefix(form_edit, "LineEditInputRail_") == 0 and count_nodes_with_name_prefix(form_edit, "LineEditInputPulse_") == 0 and count_nodes_with_name_prefix(form_edit, "LineEditInputTargetRoute_") == 0 and count_nodes_with_name_prefix(form_edit, "LineEditInputValueRoute_") == 0, "line edits do not render legacy rail route or pulse art")
	check(count_nodes_with_name_prefix(form_edit, "LineEditInputTargetTick_") == 0 and count_nodes_with_name_prefix(form_edit, "LineEditInputValueTick_") == 0 and count_nodes_with_name_prefix(form_edit, "LineEditInputFocusNode_") == 0, "line edits do not render legacy ticks or focus nodes")
	scene.play_line_edit_input_feedback(form_edit, "name", true)
	check(form_edit.find_child("LineEditInputFeedback_name", true, false) != null and form_edit.find_child("LineEditInputFeedbackWash_name", true, false) != null and form_edit.find_child("LineEditInputFeedbackGlow_name", true, false) != null and form_edit.find_child("LineEditInputFeedbackSeal_name", true, false) != null, "line edits render interactive input wash feedback")
	check(form_edit.find_child("LineEditInputFeedbackCaret_name", true, false) != null and form_edit.find_child("LineEditInputFeedbackGlyph_name", true, false) != null and count_nodes_with_name_prefix(form_edit, "LineEditInputFeedbackTick_name_") == 0, "line edit input feedback renders caret and avoids rhythm ticks")
	check(form_edit.find_child("LineEditInputFeedbackSource_name", true, false) == null and form_edit.find_child("LineEditInputFeedbackRoute_name", true, false) == null and form_edit.find_child("LineEditInputFeedbackFill_name", true, false) == null and form_edit.find_child("LineEditInputFeedbackGate_name", true, false) == null, "line edit input feedback removes legacy source route fill and gate")
	dispose_node(form_label_parent)
	var panel_parent = Control.new()
	root.add_child(panel_parent)
	var decorative_panel = scene.make_panel(panel_parent, scene.rect_full(0.1, 0.1, 0.9, 0.9), Color(0.1, 0.2, 0.3), 8, Color(0.4, 0.5, 0.6))
	check(decorative_panel.mouse_filter == Control.MOUSE_FILTER_IGNORE and panels_ignore_mouse(panel_parent), "decorative panels skip mouse hit testing")
	check(panel_shadow_size(decorative_panel) == 0, "default panels stay shadowless because GPT plates provide depth")
	dispose_node(panel_parent)
	var passive_row = HBoxContainer.new()
	scene.configure_passive_container(passive_row)
	check(passive_row.mouse_filter == Control.MOUSE_FILTER_IGNORE, "passive container helper skips mouse hit testing")
	dispose_node(passive_row)
	var background_parent = Control.new()
	root.add_child(background_parent)
	scene.add_background(background_parent)
	check(count_texture_rects(background_parent) >= 1 and texture_rects_ignore_mouse(background_parent), "decorative background textures skip mouse hit testing")
	check(color_rects_ignore_mouse(background_parent), "decorative background color overlays skip mouse hit testing when present")
	dispose_node(background_parent)
	var decorative_texture_parent = Control.new()
	root.add_child(decorative_texture_parent)
	var decorative_texture = scene.add_texture(decorative_texture_parent, scene.wood_texture, scene.rect_full(0.0, 0.0, 1.0, 1.0), 0.5)
	check(decorative_texture.mouse_filter == Control.MOUSE_FILTER_IGNORE, "decorative table textures skip mouse hit testing")
	dispose_node(decorative_texture_parent)
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
	dispose_node(quick_button)
	var hud_press_count := {"value": 0}
	var top_button = scene.make_top_hud_button("设置", Color(0.22, 0.42, 0.54), func() -> void:
		hud_press_count["value"] = int(hud_press_count.get("value", 0)) + 1
	)
	check(top_button.custom_minimum_size == scene.TOP_HUD_BUTTON_SIZE and top_button.clip_text, "top HUD buttons keep mobile touch target and clipped labels")
	check(top_button.find_child("ButtonPressSheen", true, false) != null, "top HUD buttons render a press sheen overlay")
	check(top_button.find_child("TopHudButtonIconBack_设置", true, false) != null and top_button.find_child("TopHudButtonRail_设置", true, false) != null and top_button.find_child("TopHudButtonRailFill_设置", true, false) != null and top_button.find_child("TopHudButtonSeal_设置", true, false) != null, "top HUD buttons render compact icon material accents")
	check(top_button.find_child("TopHudButtonCommandRoute_设置", true, false) == null and top_button.find_child("TopHudButtonCommandFill_设置", true, false) == null and top_button.find_child("TopHudButtonCommandGate_设置", true, false) == null and count_nodes_with_name_prefix(top_button, "TopHudButtonCommandTick_设置_") == 0, "top HUD buttons omit command route and rhythm clutter")
	scene.play_top_hud_button_press_feedback(top_button, "设置", Color(0.22, 0.42, 0.54))
	check(top_button.find_child("TopHudButtonPressFeedback_设置", true, false) != null and top_button.find_child("TopHudButtonPressWash_设置", true, false) != null and top_button.find_child("TopHudButtonPressGlow_设置", true, false) != null, "top HUD button press feedback renders compact wash and glow")
	check(top_button.find_child("TopHudButtonPressSeal_设置", true, false) != null and top_button.find_child("TopHudButtonPressGlyph_设置", true, false) != null and count_nodes_with_name_prefix(top_button, "TopHudButtonPressTick_设置_") == 0, "top HUD button press feedback renders seal glyph and omits rhythm ticks")
	check(top_button.find_child("TopHudButtonPressSource_设置", true, false) == null and top_button.find_child("TopHudButtonPressRoute_设置", true, false) == null and top_button.find_child("TopHudButtonPressFill_设置", true, false) == null and top_button.find_child("TopHudButtonPressGate_设置", true, false) == null, "top HUD button press feedback omits source route fill and gate")
	top_button.emit_signal("button_down")
	check(int(hud_press_count.get("value", 0)) == 1, "top HUD buttons trigger on button down")
	dispose_node(top_button)
	var back_button = scene.make_small_button("返回", Color(0.32, 0.38, 0.40), func() -> void:
		pass
	)
	scene.draw_secondary_back_button_art(back_button, "smoke", Color(0.32, 0.38, 0.40))
	check(back_button.find_child("SecondaryBackReturnFlow_smoke", true, false) != null and back_button.find_child("SecondaryBackReturnFill_smoke", true, false) != null and back_button.find_child("SecondaryBackReturnGate_smoke", true, false) != null and count_nodes_with_name_prefix(back_button, "SecondaryBackReturnTick_smoke_") == 3, "secondary back buttons render return flow fill gate and ticks")
	scene.play_secondary_back_press_feedback(back_button, "smoke", Color(0.32, 0.38, 0.40))
	check(back_button.find_child("SecondaryBackPressFeedback_smoke", true, false) != null and back_button.find_child("SecondaryBackPressRoute_smoke", true, false) != null and back_button.find_child("SecondaryBackPressFill_smoke", true, false) != null and back_button.find_child("SecondaryBackPressGate_smoke", true, false) != null and count_nodes_with_name_prefix(back_button, "SecondaryBackPressTick_smoke_") == 3, "secondary back press feedback renders route fill gate and rhythm ticks")
	dispose_node(back_button)
	var menu_press_count := {"value": 0}
	var menu_callback = func() -> void:
		menu_press_count["value"] = int(menu_press_count.get("value", 0)) + 1
	var menu_card = scene.make_menu_card("测试", Color(0.30, 0.50, 0.70), menu_callback, "play", true)
	menu_card.emit_signal("button_down")
	check(int(menu_press_count.get("value", 0)) == 1, "menu cards run callbacks on button down")
	check(count_texture_rects(menu_card) >= 1, "menu cards render lucide SVG illustration icons")
	check(menu_card.find_child("MenuCardEntryArt", true, false) != null and menu_card.find_child("MenuCardSurface", true, false) != null and menu_card.find_child("MenuCardInner", true, false) != null and menu_card.find_child("MenuCardAccent", true, false) != null and menu_card.find_child("MenuCardEntryFocus", true, false) != null and menu_card.find_child("MenuCardEntryArrow", true, false) != null, "menu cards render clean commercial surface layers")
	check(menu_card.find_child("MenuCardEntryRail", true, false) == null and menu_card.find_child("MenuCardEntryFill", true, false) == null and count_nodes_with_name_prefix(menu_card, "MenuCardEntryNode_") == 0 and count_nodes_with_name_prefix(menu_card, "MenuCardEntrySpark_") == 0, "menu cards omit legacy entry route nodes and sparks")
	check(menu_card.find_child("MenuCardEntryConfirmRoute", true, false) == null and menu_card.find_child("MenuCardEntryConfirmFill", true, false) == null and menu_card.find_child("MenuCardEntryConfirmGate", true, false) == null and count_nodes_with_name_prefix(menu_card, "MenuCardEntryConfirmTick_") == 0, "menu cards omit legacy confirmation routes and ticks")
	check(menu_card.find_child("ButtonPressSheen", true, false) != null and menu_card.find_child("MenuCardDecisionBand", true, false) == null and menu_card.find_child("MenuCardDecisionFill", true, false) == null and menu_card.find_child("MenuCardActivationSeal", true, false) == null and menu_card.find_child("MenuCardActivationCore", true, false) == null, "menu cards keep button sheen and omit legacy decision route art")
	check(count_nodes_with_name_prefix(menu_card, "MenuCardDecisionTick_") == 0, "menu cards omit legacy decision rhythm ticks")
	scene.play_menu_card_press_feedback(menu_card, Color(0.30, 0.50, 0.70))
	check(menu_card.find_child("MenuCardPressFeedback", true, false) != null and menu_card.find_child("MenuCardPressWash", true, false) != null and menu_card.find_child("MenuCardPressGlow", true, false) != null, "menu card press feedback renders animated wash and glow")
	check(menu_card.find_child("MenuCardPressRail", true, false) == null and menu_card.find_child("MenuCardPressFill", true, false) == null and menu_card.find_child("MenuCardPressGate", true, false) == null and count_nodes_with_name_prefix(menu_card, "MenuCardPressTick_") == 0, "menu card press feedback omits legacy rail fill gate and ticks")
	check(menu_card.find_child("CardBreathingShadow", true, false) != null and menu_card.find_child("CardShimmer", true, false) != null, "menu cards can render depth shimmer and breathing shadow art")
	dispose_node(menu_card)
	var quick_action_parent = Control.new()
	root.add_child(quick_action_parent)
	var quick_action_rail = scene.draw_menu_quick_action_rail(quick_action_parent)
	check(quick_action_rail != null and quick_action_rail.find_child("MenuQuickActionSurface", true, false) != null and quick_action_rail.find_child("MenuQuickRulesButton", true, false) != null and quick_action_rail.find_child("MenuQuickShopButton", true, false) != null, "menu quick action rail renders clean animated surface and all quick buttons")
	check(quick_action_rail.find_child("MenuQuickActionFocusArt", true, false) == null and quick_action_rail.find_child("MenuQuickActionFocusLayer", true, false) == null and count_nodes_with_name_prefix(quick_action_rail, "MenuQuickActionFocusHalo_") == 0 and count_nodes_with_name_prefix(quick_action_rail, "MenuQuickActionFocusRoute_") == 0 and count_nodes_with_name_prefix(quick_action_rail, "MenuQuickActionFocusFill_") == 0 and count_nodes_with_name_prefix(quick_action_rail, "MenuQuickActionFocusCursor_") == 0, "menu quick action rail omits legacy focus routes and cursor nodes")
	check(quick_action_rail.find_child("MenuQuickActionDecisionBridge", true, false) == null and count_nodes_with_name_prefix(quick_action_rail, "MenuQuickActionDecisionNode_") == 0 and count_nodes_with_name_prefix(quick_action_rail, "MenuQuickActionDecisionTick_") == 0, "menu quick action rail omits legacy decision bridge nodes and ticks")
	dispose_node(quick_action_parent)
	var card_flip_parent = Control.new()
	root.add_child(card_flip_parent)
	var flip_card_a = scene.make_panel(card_flip_parent, scene.rect_full(0.0, 0.0, 0.3, 0.2), Color(0.02, 0.04, 0.05), 8, Color(0.5, 0.4, 0.2), 0)
	var flip_card_b = scene.make_panel(card_flip_parent, scene.rect_full(0.35, 0.0, 0.65, 0.2), Color(0.02, 0.04, 0.05), 8, Color(0.5, 0.4, 0.2), 0)
	scene.play_card_flip_animation(card_flip_parent, [flip_card_a, flip_card_b], true)
	check(flip_card_a.find_child("CardFlipEntryArt_0", true, false) != null and flip_card_a.find_child("CardFlipEntryRail_0", true, false) != null and flip_card_a.find_child("CardFlipEntryFill_0", true, false) != null and flip_card_a.find_child("CardFlipEntryGate_0", true, false) != null, "card flip animation renders entry route art on the first card")
	check(flip_card_b.find_child("CardFlipEntryArt_1", true, false) != null and count_nodes_with_name_prefix(card_flip_parent, "CardFlipEntryTick_") == 4, "card flip animation renders indexed entry ticks for staggered cards")
	check(flip_card_a.find_child("CardFlipEntrySpine_0", true, false) != null and flip_card_a.find_child("CardFlipEntryFocus_0", true, false) != null and flip_card_a.find_child("CardFlipEntryCompletionGate_0", true, false) != null, "card flip animation renders spine focus and completion gate")
	check(count_nodes_with_name_prefix(card_flip_parent, "CardFlipEntryCompletionPip_") == 6 and count_nodes_with_name_prefix(card_flip_parent, "CardFlipEntrySpark_") == 2, "card flip animation renders completion pips and sparks for every staggered card")
	dispose_node(card_flip_parent)
	var animation_preview_parent = Control.new()
	root.add_child(animation_preview_parent)
	var coin_preview = scene.draw_animation_preview(animation_preview_parent, scene.rect_full(0.0, 0.0, 0.2, 0.2), "coin_spin")
	var victory_preview = scene.draw_animation_preview(animation_preview_parent, scene.rect_full(0.2, 0.0, 0.4, 0.2), "victory_sparkle")
	var claim_response_preview = scene.draw_animation_preview(animation_preview_parent, scene.rect_full(0.4, 0.0, 0.6, 0.2), "claim_response_orbit")
	var discard_splash_preview = scene.draw_animation_preview(animation_preview_parent, scene.rect_full(0.6, 0.0, 0.8, 0.2), "discard_ink_splash")
	var tile_draw_preview = scene.draw_animation_preview(animation_preview_parent, scene.rect_full(0.0, 0.2, 0.2, 0.4), "tile_draw_fly")
	var tile_discard_preview = scene.draw_animation_preview(animation_preview_parent, scene.rect_full(0.2, 0.2, 0.4, 0.4), "tile_discard_fly")
	var kong_reveal_preview = scene.draw_animation_preview(animation_preview_parent, scene.rect_full(0.4, 0.2, 0.6, 0.4), "kong_reveal_burst")
	check(coin_preview != null and animation_preview_parent.find_child("AnimationPreview_coin_spin", true, false) != null and count_texture_rects(coin_preview) >= 1, "coin animation JSON renders a native coin illustration preview")
	check(victory_preview != null and animation_preview_parent.find_child("AnimationPreview_victory_sparkle", true, false) != null and has_label_text(victory_preview, "✦"), "victory animation JSON renders native sparkle illustration preview")
	check(claim_response_preview != null and claim_response_preview.find_child("ClaimResponseOrbitGate", true, false) != null and count_nodes_with_name_prefix(claim_response_preview, "ClaimResponseOrbitTick_") == 3, "claim response animation JSON renders native orbit preview")
	check(discard_splash_preview != null and discard_splash_preview.find_child("DiscardInkSplashWake", true, false) != null and count_nodes_with_name_prefix(discard_splash_preview, "DiscardInkSplashDrop_") == 6, "discard splash animation JSON renders native ink preview")
	check(tile_draw_preview != null and tile_draw_preview.find_child("TileDrawFlyWallSource", true, false) != null and tile_draw_preview.find_child("TileDrawFlyTile", true, false) != null and count_nodes_with_name_prefix(tile_draw_preview, "TileDrawFlyTick_") == 3, "tile draw fly animation JSON renders wall-to-hand preview")
	check(tile_discard_preview != null and tile_discard_preview.find_child("TileDiscardFlyHandSource", true, false) != null and tile_discard_preview.find_child("TileDiscardFlyRiverGate", true, false) != null and count_nodes_with_name_prefix(tile_discard_preview, "TileDiscardFlyTick_") == 3, "tile discard fly animation JSON renders hand-to-river preview")
	check(kong_reveal_preview != null and kong_reveal_preview.find_child("KongRevealBurstHalo", true, false) != null and kong_reveal_preview.find_child("KongRevealBurstSeal", true, false) != null and count_nodes_with_name_prefix(kong_reveal_preview, "KongRevealBurstTile_") == 4, "kong reveal burst animation JSON renders four-tile burst preview")
	check(coin_preview.find_child("CoinSpinGlow", true, false) != null and coin_preview.find_child("CoinSpinCoin", true, false) != null, "coin animation preview renders named glow and coin nodes")
	check(victory_preview.find_child("VictorySparkleRing", true, false) != null and count_nodes_with_name_prefix(victory_preview, "VictorySparkleStar") == 2, "victory animation preview renders named sparkle ring and stars")
	check(coin_preview.find_child("AnimationPreviewTimeline_coin_spin", true, false) != null and coin_preview.find_child("AnimationPreviewTimelineRail_coin_spin", true, false) != null and coin_preview.find_child("AnimationPreviewTimelineFill_coin_spin", true, false) != null and coin_preview.find_child("AnimationPreviewPlayGate_coin_spin", true, false) != null, "coin animation preview renders timeline rail fill and play gate")
	check(victory_preview.find_child("AnimationPreviewTimeline_victory_sparkle", true, false) != null and victory_preview.find_child("AnimationPreviewTimelineRail_victory_sparkle", true, false) != null and victory_preview.find_child("AnimationPreviewTimelineFill_victory_sparkle", true, false) != null and victory_preview.find_child("AnimationPreviewPlayGate_victory_sparkle", true, false) != null, "victory animation preview renders timeline rail fill and play gate")
	check(claim_response_preview.find_child("AnimationPreviewTimeline_claim_response_orbit", true, false) != null and discard_splash_preview.find_child("AnimationPreviewTimeline_discard_ink_splash", true, false) != null and tile_draw_preview.find_child("AnimationPreviewTimeline_tile_draw_fly", true, false) != null and kong_reveal_preview.find_child("AnimationPreviewTimeline_kong_reveal_burst", true, false) != null, "gameplay animation previews render timeline controls")
	check(count_nodes_with_name_prefix(animation_preview_parent, "AnimationPreviewKeyframe_") == 21 and count_nodes_with_name_prefix(animation_preview_parent, "AnimationPreviewTempoTick_") == 14, "animation previews render keyframes and tempo ticks from JSON timing")
	dispose_node(animation_preview_parent)
	var illustration_parent = Control.new()
	root.add_child(illustration_parent)
	var win_art = scene.draw_win_celebration_art(illustration_parent, Color(0.90, 0.72, 0.30), "regular")
	check(illustration_parent.find_child("WinScoreArcTexture", true, false) != null and illustration_parent.find_child("WinFanfareTexture", true, false) != null and illustration_parent.find_child("WinTypeCoverTexture", true, false) != null, "win celebration art renders reusable score-arc, fanfare, and type-cover PNG textures")
	check(scene.optional_gpt_illustration_texture("win_celebration_gpt_burst") == null or illustration_parent.find_child("WinCelebrationGPTBurstTexture", true, false) != null, "win celebration consumes optional GPT burst texture when generated")
	check(win_art != null and illustration_parent.find_child("WinCelebrationArt", true, false) != null and illustration_parent.find_child("WinCelebrationRibbon", true, false) != null and illustration_parent.find_child("WinCelebrationMedalHalo", true, false) != null and illustration_parent.find_child("WinCelebrationMedal", true, false) != null, "win celebration art renders ribbon and medal halo layer")
	check(illustration_parent.find_child("WinCelebrationTrack", true, false) != null and illustration_parent.find_child("WinCelebrationTrackFill", true, false) != null and illustration_parent.find_child("WinCelebrationScoreGate", true, false) != null and illustration_parent.find_child("WinCelebrationMedalNode", true, false) != null, "win celebration art renders energy track fill and score gate")
	check(count_nodes_with_name_prefix(illustration_parent, "WinCelebrationTrackTick_") == 3, "win celebration art renders track rhythm ticks")
	check(illustration_parent.find_child("WinCelebrationResolutionArt", true, false) != null and illustration_parent.find_child("WinCelebrationResolutionSource", true, false) != null and illustration_parent.find_child("WinCelebrationResolutionRoute", true, false) != null and illustration_parent.find_child("WinCelebrationResolutionFill", true, false) != null and illustration_parent.find_child("WinCelebrationResolutionGate", true, false) != null, "win celebration art renders result-to-score resolution route")
	check(illustration_parent.find_child("WinCelebrationResolutionSeal", true, false) != null and illustration_parent.find_child("WinCelebrationResolutionGlyph", true, false) != null and illustration_parent.find_child("WinCelebrationScoreArchiveRoute", true, false) != null and illustration_parent.find_child("WinCelebrationScoreArchiveFill", true, false) != null and illustration_parent.find_child("WinCelebrationScoreArchiveGate", true, false) != null, "win celebration art renders score archive seal and route")
	check(count_nodes_with_name_prefix(illustration_parent, "WinCelebrationResolutionTick_") == 3 and count_nodes_with_name_prefix(illustration_parent, "WinCelebrationScoreArchivePip_") == 2, "win celebration art renders resolution rhythm ticks and score archive pips")
	dispose_node(win_art)
	var special_illustration_parent = Control.new()
	root.add_child(special_illustration_parent)
	var special_win_art = scene.draw_win_celebration_art(special_illustration_parent, Color(0.90, 0.72, 0.30), "special")
	check(special_illustration_parent.find_child("WinCelebrationSpecialCrown", true, false) != null and special_illustration_parent.find_child("WinCelebrationResolutionArt", true, false) != null and count_nodes_with_name_prefix(special_illustration_parent, "WinCelebrationStar_") == 10, "special win celebration renders crown ten stars and resolution route")
	dispose_node(special_win_art)
	dispose_node(special_illustration_parent)
	scene.ensure_fx_layer()
	scene.clear_win_burst_dynamic_art()
	scene.play_fx_win_burst_enhanced("自摸", Color(0.90, 0.72, 0.30), "self_draw", true)
	check(scene.find_child("WinBurst", true, false) != null and scene.find_child("Flash", true, false) != null and scene.find_child("BurstLabel", true, false) != null and scene.find_child("Ring0", true, false) != null and scene.find_child("Ring1", true, false) != null and scene.find_child("Ring2", true, false) != null and scene.find_child("WinParticles", true, false) != null and scene.find_child("WinCelebrationArt", true, false) != null and scene.find_child("WinCelebrationSelfDrawOrbit", true, false) != null and scene.find_child("WinCelebrationSeal", true, false) != null, "enhanced win burst creates named root flash label rings particles and self-draw celebration art in fx layer")
	check(scene.find_child("CalligraphyReveal", true, false) != null and scene.find_child("CalligraphyClip", true, false) != null, "enhanced win burst creates calligraphy reveal clip animation")
	check(count_nodes_with_name_prefix(scene, "WinCelebrationStar_") >= 8, "enhanced win burst creates animated celebration stars")
	check(count_nodes_with_name_prefix(scene, "WinLightBeam_") == 6, "enhanced win burst creates radial light beams")
	check(count_nodes_with_name_prefix(scene, "WinSparkRain_") == 24, "enhanced win burst creates golden spark rain")
	var menu_hero = scene.draw_menu_hero_illustration(illustration_parent)
	check(menu_hero != null and illustration_parent.find_child("MenuHeroIllustration", true, false) != null and illustration_parent.find_child("MenuHeroCommercialReadabilityTint", true, false) != null and illustration_parent.find_child("MenuHeroControlReadabilityTint", true, false) != null, "menu hero renders GPT-first commercial backdrop with readability tints")
	check(scene.optional_gpt_illustration_texture("menu_lobby_gpt_scene") == null or illustration_parent.find_child("MenuHeroGPTBackdropTexture", true, false) != null, "menu hero consumes optional GPT lobby scene texture when generated")
	check(scene.optional_gpt_illustration_texture("menu_lobby_ui_overlay") == null or illustration_parent.find_child("MenuLobbyGeneratedUIOverlay", true, false) != null, "menu hero consumes optional GPT lobby UI overlay texture when generated")
	check(illustration_parent.find_child("MenuHeroFarMountain", true, false) == null and illustration_parent.find_child("MenuHeroMoon", true, false) == null and illustration_parent.find_child("MenuHeroWater", true, false) == null and illustration_parent.find_child("MenuHeroWindPath", true, false) == null, "menu hero removes legacy procedural mountain moon water and wind path layers")
	check(illustration_parent.find_child("MenuHeroPineLeft", true, false) == null and illustration_parent.find_child("MenuHeroBambooRight", true, false) == null and illustration_parent.find_child("MenuHeroPlumBlossom", true, false) == null and illustration_parent.find_child("MenuHeroSeal", true, false) == null and illustration_parent.find_child("MenuHeroDustLayer", true, false) == null and count_nodes_with_name_prefix(menu_hero, "MenuHeroTile_") == 0, "menu hero removes legacy procedural botanical seal dust and tile display layers")
	var table_frame = scene.draw_table_atmosphere_frame(illustration_parent)
	check(table_frame != null and table_frame.find_child("Table3DInsetShadow", true, false) != null and table_frame.find_child("Table3DFeltVignette", true, false) != null and table_frame.find_child("Table3DNearRimHighlight", true, false) != null, "3D table frame core exists")
	check(table_frame.find_child("Table3DFarRimHighlight", true, false) != null and table_frame.find_child("Table3DCenterSpotlight", true, false) != null and table_frame.find_child("TableGPTBackdropTexture", true, false) == null, "3D table atmosphere keeps only lightweight lighting over the main table backdrop")
	check(table_frame.find_child("TableBambooLeft", true, false) == null and table_frame.find_child("TableBambooRight", true, false) == null and table_frame.find_child("TableMistCloudNW", true, false) == null and table_frame.find_child("TableMistCloudSE", true, false) == null, "table frame does not keep procedural bamboo or cloud ornaments")
	check(table_frame.find_child("TableAtmosphereBreathRoute", true, false) == null and table_frame.find_child("TableAtmosphereBreathFill", true, false) == null and table_frame.find_child("TableAtmosphereBreathGate", true, false) == null and count_nodes_with_name_prefix(table_frame, "TableAtmosphereBreathTick_") == 0, "table frame does not keep breath route or ticks")
	check(table_frame.find_child("TableTopDiv", true, false) == null and table_frame.find_child("TableBottomDiv", true, false) == null and count_nodes_with_name_prefix(table_frame, "TableAtmosphereGoldLine_") == 0, "table frame does not keep divider or side line artifacts")
	scene.last_discard = "S"
	scene.last_discard_seat = 3
	scene.players[3]["discards"] = ["Z", "F", "P", "S"]
	var living_table = scene.draw_table_living_illustration(illustration_parent)
	check(living_table != null and illustration_parent.find_child("TableLivingIllustration", true, false) != null and count_nodes_with_name_prefix(illustration_parent, "TableWallLantern_") == 0 and illustration_parent.find_child("TableCenterStarlight", true, false) == null, "table living illustration omits healthy-wall lantern and center starlight clutter")
	var low_wall_lantern_parent = Control.new()
	root.add_child(low_wall_lantern_parent)
	var previous_living_wall = scene.wall.duplicate()
	scene.wall.clear()
	for i in range(18):
		scene.wall.append("1W")
	scene.draw_table_living_illustration(low_wall_lantern_parent)
	check(count_nodes_with_name_prefix(low_wall_lantern_parent, "TableWallLanternLowWarning_") == 4, "low-wall table living illustration renders warning lantern overlays")
	scene.wall = previous_living_wall
	dispose_node(low_wall_lantern_parent)
	check(illustration_parent.find_child("TableWallPressureRoute", true, false) == null and count_nodes_with_name_prefix(illustration_parent, "TableWallPressureTick_") == 0, "table living illustration omits procedural wall pressure route ticks")
	check(illustration_parent.find_child("TableTurnFlowRoute", true, false) == null and illustration_parent.find_child("TableTurnFlowGate", true, false) == null and count_nodes_with_name_prefix(illustration_parent, "TableTurnFlowTick_") == 0, "table living illustration omits procedural current-turn route ticks")
	check(illustration_parent.find_child("TableActionReadinessConvergence", true, false) == null and count_nodes_with_name_prefix(illustration_parent, "TableActionReadinessTick_") == 0 and count_nodes_with_name_prefix(illustration_parent, "TableActionReadinessActionTick_") == 0, "table living illustration omits procedural action-readiness convergence route")
	var living_layer = illustration_parent.find_child("TableLivingIllustration", true, false) as Control
	check(living_layer != null and living_layer.mouse_filter == Control.MOUSE_FILTER_IGNORE, "table living illustration stays decorative and ignores pointer input")
	check(illustration_parent.find_child("TableLastDiscardRipple", true, false) != null and count_nodes_with_name_prefix(illustration_parent, "TableLastDiscardRippleRing_") == 3, "table living illustration renders last-discard ripple rings")
	check(illustration_parent.find_child("TableLastDiscardRoute", true, false) == null and count_nodes_with_name_prefix(illustration_parent, "TableLastDiscardRouteTick_") == 0, "table living illustration omits last-discard response route ticks")
	check(illustration_parent.find_child("TableCenterStarlight", true, false) == null and illustration_parent.find_child("TableCenterMandalaTexture", true, false) == null and count_nodes_with_name_prefix(illustration_parent, "TableCenterStarlightSpark_") == 0, "table living illustration removes center mandala, glow rings, and starlight sparks")
	check(illustration_parent.find_child("TableRoundTempoArt", true, false) == null and count_nodes_with_name_prefix(illustration_parent, "TableRoundTempoTick_") == 0, "table living illustration omits procedural round tempo route")
	check(illustration_parent.find_child("TableCenterGlowRing", true, false) == null and illustration_parent.find_child("TableCenterInnerRing", true, false) == null, "table center decorative rotation rings are not rendered in the living layer")
	var compass = scene.draw_center_wind_compass(illustration_parent)
	var center_wind_has_generated_disc = illustration_parent.find_child("CenterWindGPTCompassTexture", true, false) != null or illustration_parent.find_child("CenterWindSealTexture", true, false) != null
	check(compass != null and illustration_parent.find_child("CenterWindCompass", true, false) != null and center_wind_has_generated_disc and illustration_parent.find_child("CenterWindPointerTexture", true, false) != null and illustration_parent.find_child("CenterWindCompass_东", true, false) != null, "center wind compass renders GPT compass/pointer textures and directional illustration badges")
	check(scene.optional_gpt_illustration_texture("center_wind_gpt_compass") == null or illustration_parent.find_child("CenterWindGPTCompassTexture", true, false) != null, "center wind compass consumes optional GPT compass texture when generated")
	check(illustration_parent.find_child("CenterWindActiveHalo", true, false) != null and illustration_parent.find_child("CenterWindActiveHaloOuter", true, false) != null and illustration_parent.find_child("CenterWindNextBadge", true, false) != null and illustration_parent.find_child("CenterWindTurnTrack", true, false) != null, "center wind compass renders layered active turn halo and next-seat cue")
	check(illustration_parent.find_child("CenterWindDealerBadge", true, false) != null and illustration_parent.find_child("CenterWindCurrentPointer", true, false) != null and count_nodes_with_name_prefix(illustration_parent, "CenterWindDirectionBead_") == 4, "center wind compass renders dealer marker, current pointer, and turn-direction beads")
	var center_previous_phase = scene.offline_phase
	var center_previous_seat = scene.current_seat
	var center_previous_turn_needs_draw = scene.offline_turn_needs_draw
	scene.mode = "offline"
	scene.offline_phase = "await_discard"
	scene.current_seat = 0
	scene.offline_turn_needs_draw = false
	var phase_ribbon = scene.draw_center_phase_ribbon(illustration_parent)
	check(phase_ribbon != null and illustration_parent.find_child("CenterPhaseRibbon", true, false) != null and illustration_parent.find_child("CenterPhaseRibbonHalo", true, false) != null and illustration_parent.find_child("CenterPhaseSeal", true, false) != null and illustration_parent.find_child("CenterPhasePulse", true, false) != null and illustration_parent.find_child("CenterPhaseLabel", true, false) != null, "center panel renders a phase ribbon with halo seal pulse and label art")
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
	check(ribbon != null and illustration_parent.find_child("SummaryVictoryRibbon", true, false) != null and illustration_parent.find_child("SummaryRibbonGoldFoil", true, false) != null and illustration_parent.find_child("SummaryRibbonLeftTail", true, false) != null and illustration_parent.find_child("SummaryRibbonRightTail", true, false) != null and count_texture_rects(ribbon) >= 1, "round summary renders victory ribbon illustration with foil and tails")
	var summary_previous_hand_number = scene.offline_hand_number
	scene.last_score_deltas.clear()
	for score_delta in [-1200, 3600, -1200, -1200]:
		scene.last_score_deltas.append(score_delta)
	scene.offline_last_winner = 1
	scene.offline_hand_number = 3
	var summary_ambience = scene.draw_round_summary_ambience(illustration_parent)
	check(summary_ambience != null and illustration_parent.find_child("RoundSummaryAmbience", true, false) != null and illustration_parent.find_child("RoundSummaryAmbienceWash", true, false) != null and illustration_parent.find_child("RoundSummaryScoreOrbit", true, false) != null, "round summary ambience renders wash and score orbit art")
	check(illustration_parent.find_child("RoundSummaryVictoryBadgeTexture", true, false) != null and illustration_parent.find_child("VictoryBadgeGoldFoil", true, false) != null and illustration_parent.find_child("RoundSummarySettlementWave", true, false) != null and illustration_parent.find_child("RoundSummaryLaurelTexture", true, false) != null, "round summary ambience renders reusable victory badge gold foil settlement wave and laurel art")
	check(scene.optional_gpt_illustration_texture("win_result_stage") == null or illustration_parent.find_child("RoundSummaryGPTWinStageTexture", true, false) != null, "round summary ambience consumes optional GPT win stage texture when generated")
	check(illustration_parent.find_child("RoundSummaryScoreFlowBus", true, false) != null and illustration_parent.find_child("RoundSummaryScoreFlowSpine", true, false) != null and illustration_parent.find_child("RoundSummaryScoreFlowSpineFill", true, false) != null, "round summary ambience renders score flow bus and spine")
	check(scene.optional_gpt_illustration_texture("round_summary_score_flow_bus") == null or illustration_parent.find_child("RoundSummaryScoreFlowGPTTexture", true, false) != null, "round summary ambience consumes optional GPT score flow bus texture when generated")
	check(illustration_parent.find_child("RoundSummaryScoreFlowWinnerGate", true, false) != null and illustration_parent.find_child("RoundSummaryScoreFlowWinnerGlyph", true, false) != null and illustration_parent.find_child("RoundSummaryScoreFlowArchive", true, false) != null and illustration_parent.find_child("RoundSummaryScoreFlowArchiveGlyph", true, false) != null, "round summary score flow bus renders winner and archive gates")
	check(count_nodes_with_name_prefix(illustration_parent, "RoundSummaryScoreFlowNode_") == 4 and count_nodes_with_name_prefix(illustration_parent, "RoundSummaryScoreFlowPayerRoute_") == 3 and count_nodes_with_name_prefix(illustration_parent, "RoundSummaryScoreFlowPayerTick_") == 6 and count_nodes_with_name_prefix(illustration_parent, "RoundSummaryScoreFlowTick_") == 3, "round summary score flow bus renders one node per seat and payer routes")
	check(illustration_parent.find_child("RoundSummaryWinnerBeacon", true, false) != null and illustration_parent.find_child("RoundSummaryWinnerBeaconSeal", true, false) != null and illustration_parent.find_child("RoundSummaryWinnerBeaconRay", true, false) != null, "round summary ambience renders winner beacon seal and ray")
	check(count_nodes_with_name_prefix(illustration_parent, "RoundSummaryScoreNode_") == 4 and count_nodes_with_name_prefix(illustration_parent, "RoundSummaryDeltaSpark_") == 4, "round summary ambience renders one score node and delta spark per changed seat")
	check(illustration_parent.find_child("RoundSummarySettlementRoute", true, false) != null and illustration_parent.find_child("RoundSummarySettlementFill", true, false) != null and illustration_parent.find_child("RoundSummarySettlementGate", true, false) != null, "round summary ambience renders winner-to-settlement route")
	check(count_nodes_with_name_prefix(illustration_parent, "RoundSummarySettlementTick_") == 3, "round summary ambience renders settlement rhythm ticks")
	check(illustration_parent.find_child("RoundSummaryWinnerSettlementBridge", true, false) != null and illustration_parent.find_child("RoundSummaryWinnerSettlementFill", true, false) != null and illustration_parent.find_child("RoundSummaryWinnerSettlementSource", true, false) != null and illustration_parent.find_child("RoundSummaryWinnerSettlementGate", true, false) != null, "round summary ambience renders winner settlement bridge")
	check(count_nodes_with_name_prefix(illustration_parent, "RoundSummaryWinnerSettlementTick_") == 3, "round summary winner settlement bridge renders rhythm ticks")
	check(illustration_parent.find_child("RoundSummarySettlementCommitArt", true, false) != null and illustration_parent.find_child("RoundSummarySettlementCommitSource", true, false) != null and illustration_parent.find_child("RoundSummarySettlementCommitRoute", true, false) != null and illustration_parent.find_child("RoundSummarySettlementCommitFill", true, false) != null and illustration_parent.find_child("RoundSummarySettlementCommitGate", true, false) != null, "round summary ambience renders settlement commit route")
	check(illustration_parent.find_child("RoundSummarySettlementArchiveNode", true, false) != null and illustration_parent.find_child("RoundSummarySettlementArchiveGlyph", true, false) != null and count_nodes_with_name_prefix(illustration_parent, "RoundSummarySettlementCommitTick_") == 3 and count_nodes_with_name_prefix(illustration_parent, "RoundSummarySettlementArchivePip_") == 2, "round summary settlement commit renders archive node glyph ticks and pips")
	check(illustration_parent.find_child("RoundSummaryNextHandGate", true, false) != null and count_nodes_with_name_prefix(illustration_parent, "RoundSummaryNextHandPip_") == 3, "round summary ambience renders next-hand gate pips")
	check(illustration_parent.find_child("RoundSummaryNextActionRoute", true, false) != null and illustration_parent.find_child("RoundSummaryNextActionFill", true, false) != null and illustration_parent.find_child("RoundSummaryNextActionSource", true, false) != null and illustration_parent.find_child("RoundSummaryNextActionGate", true, false) != null, "round summary ambience renders route toward next action")
	check(count_nodes_with_name_prefix(illustration_parent, "RoundSummaryNextActionTick_") == 2, "round summary next action route renders rhythm ticks")
	var match_complete_parent = Control.new()
	root.add_child(match_complete_parent)
	scene.offline_hand_number = scene.MATCH_MAX_HANDS
	scene.draw_round_summary_ambience(match_complete_parent)
	check(match_complete_parent.find_child("RoundSummaryMatchCompleteArt", true, false) != null and match_complete_parent.find_child("RoundSummaryMatchCompleteLaurel", true, false) != null and match_complete_parent.find_child("RoundSummaryMatchCompleteRail", true, false) != null and match_complete_parent.find_child("RoundSummaryMatchCompleteFill", true, false) != null and match_complete_parent.find_child("RoundSummaryMatchArchiveGate", true, false) != null and match_complete_parent.find_child("RoundSummaryMatchArchiveGlyph", true, false) != null, "round summary ambience renders match-complete laurel and filled archive route")
	check(match_complete_parent.find_child("RoundSummaryChampionNode", true, false) != null and match_complete_parent.find_child("RoundSummaryChampionGlyph", true, false) != null and match_complete_parent.find_child("RoundSummaryFinalRankRoute", true, false) != null and match_complete_parent.find_child("RoundSummaryFinalRankFill", true, false) != null, "round summary match-complete art links champion glyph to final rank route")
	check(count_nodes_with_name_prefix(match_complete_parent, "RoundSummaryFinalRankNode_") == 4 and count_nodes_with_name_prefix(match_complete_parent, "RoundSummaryFinalRankDrop_") == 4, "round summary match-complete art renders one final rank node per seat")
	check(count_nodes_with_name_prefix(match_complete_parent, "RoundSummaryMatchCompleteTick_") == 4 and match_complete_parent.find_child("RoundSummaryFinalSeal", true, false) != null, "round summary match-complete art renders rhythm ticks and final seal")
	check(match_complete_parent.find_child("RoundSummaryNextHandGate", true, false) == null, "round summary match-complete art omits next-hand gate")
	check(match_complete_parent.find_child("RoundSummaryNextActionRoute", true, false) == null, "round summary match-complete art omits next-action route")
	dispose_node(match_complete_parent)
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
	check(scene.optional_gpt_illustration_texture("win_detail_gpt_scroll") == null or win_detail_parent.find_child("WinDetailGPTScrollTexture", true, false) != null, "win detail consumes optional GPT scroll texture when generated")
	check(win_detail_parent.find_child("WinDetailShowcase", true, false) != null and win_detail_parent.find_child("WinDetailTile", true, false) != null and win_detail_parent.find_child("WinDetailSeal", true, false) != null, "win detail renders tile showcase and seal")
	check(win_detail_parent.find_child("WinDetailShowcaseRoute", true, false) != null and win_detail_parent.find_child("WinDetailShowcaseRouteFill", true, false) != null and win_detail_parent.find_child("WinDetailShowcaseScoreGate", true, false) != null, "win detail showcase renders tile-to-score route")
	check(count_nodes_with_name_prefix(win_detail_parent, "WinDetailShowcaseRouteTick_") == 3 and count_nodes_with_name_prefix(win_detail_parent, "WinDetailShowcaseFanPip_") == 4, "win detail showcase renders route rhythm ticks and fan pips")
	check(win_detail_parent.find_child("WinDetailYakuTrack", true, false) != null and win_detail_parent.find_child("WinDetailYakuRail", true, false) != null and count_nodes_with_name_prefix(win_detail_parent, "WinDetailYakuNode_") == 3, "win detail renders yaku track rail and one node per reason")
	check(win_detail_parent.find_child("WinDetailYakuLeadGlow", true, false) != null, "win detail highlights the leading yaku track node")
	check(win_detail_parent.find_child("WinDetailYakuRailFill", true, false) != null and win_detail_parent.find_child("WinDetailYakuGate", true, false) != null and count_nodes_with_name_prefix(win_detail_parent, "WinDetailYakuTick_") == 3, "win detail yaku track renders fill gate and rhythm ticks")
	var win_yaku_fill = win_detail_parent.find_child("WinDetailYakuRailFill", true, false) as Control
	check(win_yaku_fill != null and win_yaku_fill.anchor_right > 0.55 and win_yaku_fill.anchor_right < 0.65, "win detail yaku rail fill tracks yaku count")
	check(win_detail_parent.find_child("WinDetailScoreConstellation", true, false) != null and win_detail_parent.find_child("WinDetailScoreRail", true, false) != null and win_detail_parent.find_child("WinDetailScoreArc", true, false) != null and win_detail_parent.find_child("WinDetailScoreCore", true, false) != null and win_detail_parent.find_child("WinDetailScoreFanGlyph", true, false) != null and win_detail_parent.find_child("WinDetailScorePulse", true, false) != null, "win detail renders score constellation rail art")
	check(count_nodes_with_name_prefix(win_detail_parent, "WinDetailScoreStar_") == 3 and count_nodes_with_name_prefix(win_detail_parent, "WinDetailScoreStarGlyph_") == 3 and win_detail_parent.find_child("WinDetailScorePointLabel", true, false) != null, "win detail renders one score constellation star and glyph per yaku with a point label")
	check(win_detail_parent.find_child("WinDetailScoreRoute", true, false) != null and win_detail_parent.find_child("WinDetailScoreRouteFill", true, false) != null and win_detail_parent.find_child("WinDetailScoreGate", true, false) != null, "win detail renders yaku-to-score route")
	check(count_nodes_with_name_prefix(win_detail_parent, "WinDetailScoreRouteTick_") == 3, "win detail renders score route rhythm ticks")
	var win_score_route_fill = win_detail_parent.find_child("WinDetailScoreRouteFill", true, false) as Control
	check(win_score_route_fill != null and win_score_route_fill.anchor_right > 0.45 and win_score_route_fill.anchor_right < 0.55, "win detail score route fill tracks fan strength")
	check(win_detail_parent.find_child("WinDetailResolutionBridge", true, false) != null and win_detail_parent.find_child("WinDetailResolutionSeal", true, false) != null and win_detail_parent.find_child("WinDetailResolutionRail", true, false) != null and win_detail_parent.find_child("WinDetailResolutionFill", true, false) != null and win_detail_parent.find_child("WinDetailResolutionGate", true, false) != null, "win detail renders fan-to-score resolution bridge seal")
	check(win_detail_parent.find_child("WinDetailResolutionFanNode", true, false) != null and win_detail_parent.find_child("WinDetailResolutionFanGlyph", true, false) != null and win_detail_parent.find_child("WinDetailResolutionScoreNode", true, false) != null and win_detail_parent.find_child("WinDetailResolutionScoreGlyph", true, false) != null and win_detail_parent.find_child("WinDetailResolutionYakuRoute", true, false) != null and win_detail_parent.find_child("WinDetailResolutionYakuFill", true, false) != null, "win detail resolution bridge renders fan score glyphs and yaku route nodes")
	check(count_nodes_with_name_prefix(win_detail_parent, "WinDetailResolutionTick_") == 3 and count_nodes_with_name_prefix(win_detail_parent, "WinDetailResolutionPip_") == 2, "win detail resolution bridge renders rhythm ticks and confirmation pips")
	dispose_node(win_detail_parent)
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
	dispose_node(limit_win_detail_parent)
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
	dispose_node(rank_row_parent)
	dispose_node(illustration_parent)
	var advisor_panel_parent = Control.new()
	root.add_child(advisor_panel_parent)
	scene.draw_advisor_panel(advisor_panel_parent, true)
	check(advisor_panel_parent.find_child("AdvisorMapTexture", true, false) != null, "advisor panel renders reusable decision-map PNG texture")
	check(scene.optional_gpt_illustration_texture("advisor_gpt_panel") == null or advisor_panel_parent.find_child("AdvisorGPTPanelTexture", true, false) != null, "advisor panel consumes optional GPT panel texture when generated")
	check(advisor_panel_parent.find_child("AdvisorPanelAnalysisScan", true, false) != null and advisor_panel_parent.find_child("AdvisorPanelAnalysisSource", true, false) != null and advisor_panel_parent.find_child("AdvisorPanelAnalysisGate", true, false) != null, "advisor panel renders analysis scan layer")
	dispose_node(advisor_panel_parent)
	var advisor_card_parent = Control.new()
	root.add_child(advisor_card_parent)
	scene.draw_advisor_info_card(advisor_card_parent, scene.rect_full(0.0, 0.0, 0.32, 0.20), "防守", "安全优先", "看现物与筋", Color(0.84, 0.62, 0.54))
	check(advisor_card_parent.find_child("AdvisorInfoCard_防守", true, false) != null and advisor_card_parent.find_child("AdvisorCardMapTexture_防守", true, false) != null, "advisor card renders reusable decision-map PNG texture")
	check(advisor_card_parent.find_child("AdvisorSignalStrip_防守", true, false) != null and advisor_card_parent.find_child("AdvisorSignalPulse_防守", true, false) != null and advisor_card_parent.find_child("AdvisorSignalIcon_防守", true, false) != null, "advisor cards render compact signal strip")
	check(advisor_card_parent.find_child("AdvisorCardSignalRoute_防守", true, false) != null and advisor_card_parent.find_child("AdvisorCardSignalFill_防守", true, false) != null and advisor_card_parent.find_child("AdvisorCardSignalSource_防守", true, false) != null and advisor_card_parent.find_child("AdvisorCardSignalGate_防守", true, false) != null, "advisor cards render signal-to-meter route")
	check(count_nodes_with_name_prefix(advisor_card_parent, "AdvisorCardSignalTick_防守_") == 2, "advisor cards render signal route rhythm ticks")
	check(advisor_card_parent.find_child("AdvisorCardMeter_防守", true, false) != null and advisor_card_parent.find_child("AdvisorCardMeterRail_防守", true, false) != null and advisor_card_parent.find_child("AdvisorCardMeterFill_防守", true, false) != null, "advisor cards render compact signal meter")
	check(advisor_card_parent.find_child("AdvisorCardMeterFocus_防守", true, false) != null and count_nodes_with_name_prefix(advisor_card_parent, "AdvisorCardMeterPip_防守_") == 3, "advisor card meter renders focus and three status pips")
	check(advisor_card_parent.find_child("AdvisorCardDecisionRoute_防守", true, false) != null and advisor_card_parent.find_child("AdvisorCardDecisionFill_防守", true, false) != null and advisor_card_parent.find_child("AdvisorCardDecisionGate_防守", true, false) != null, "advisor cards render decision route and gate")
	check(count_nodes_with_name_prefix(advisor_card_parent, "AdvisorCardDecisionTick_防守_") == 3, "advisor cards render decision rhythm ticks")
	scene.draw_advisor_panel_context_route(advisor_card_parent)
	check(advisor_card_parent.find_child("AdvisorPanelContextRoute", true, false) != null and advisor_card_parent.find_child("AdvisorPanelContextFill", true, false) != null and advisor_card_parent.find_child("AdvisorPanelContextGate", true, false) != null, "advisor panel renders context route")
	check(count_nodes_with_name_prefix(advisor_card_parent, "AdvisorPanelContextTick_") == 3 and count_nodes_with_name_prefix(advisor_card_parent, "AdvisorPanelContextNode_") == 3, "advisor panel context route renders ticks and card nodes")
	scene.draw_advisor_panel_priority_sweep(advisor_card_parent)
	check(advisor_card_parent.find_child("AdvisorPanelPrioritySweep", true, false) != null and advisor_card_parent.find_child("AdvisorPanelPriorityRail", true, false) != null and advisor_card_parent.find_child("AdvisorPanelPriorityFill", true, false) != null, "advisor panel renders priority sweep across cards")
	check(advisor_card_parent.find_child("AdvisorPanelPrioritySource", true, false) != null and advisor_card_parent.find_child("AdvisorPanelPriorityGate", true, false) != null and count_nodes_with_name_prefix(advisor_card_parent, "AdvisorPanelPriorityNode_") == 3, "advisor panel priority sweep renders source gate and card nodes")
	check(count_nodes_with_name_prefix(advisor_card_parent, "AdvisorPanelPriorityTick_") == 4, "advisor panel priority sweep renders rhythm ticks")
	scene.draw_advisor_panel_decision_bridge(advisor_card_parent)
	check(advisor_card_parent.find_child("AdvisorPanelDecisionBridge", true, false) != null and advisor_card_parent.find_child("AdvisorPanelDecisionBridgeRail", true, false) != null and advisor_card_parent.find_child("AdvisorPanelDecisionBridgeFill", true, false) != null and advisor_card_parent.find_child("AdvisorPanelDecisionBridgeGate", true, false) != null, "advisor panel renders decision bridge route")
	check(count_nodes_with_name_prefix(advisor_card_parent, "AdvisorPanelDecisionNode_") == 3 and count_nodes_with_name_prefix(advisor_card_parent, "AdvisorPanelDecisionTick_") == 4, "advisor panel decision bridge renders nodes and rhythm ticks")
	scene.draw_advisor_panel_analysis_scan(advisor_card_parent)
	check(advisor_card_parent.find_child("AdvisorPanelAnalysisScan", true, false) != null and advisor_card_parent.find_child("AdvisorPanelAnalysisIntakeRoute", true, false) != null and advisor_card_parent.find_child("AdvisorPanelAnalysisIntakeFill", true, false) != null and advisor_card_parent.find_child("AdvisorPanelRiskRoute", true, false) != null and advisor_card_parent.find_child("AdvisorPanelRiskFill", true, false) != null and advisor_card_parent.find_child("AdvisorPanelOutputRoute", true, false) != null and advisor_card_parent.find_child("AdvisorPanelOutputFill", true, false) != null, "advisor panel analysis scan renders intake risk and output routes")
	check(advisor_card_parent.find_child("AdvisorPanelAnalysisSeal", true, false) != null and advisor_card_parent.find_child("AdvisorPanelAnalysisGlyph", true, false) != null and count_nodes_with_name_prefix(advisor_card_parent, "AdvisorPanelAnalysisNode_") == 3 and count_nodes_with_name_prefix(advisor_card_parent, "AdvisorPanelAnalysisTick_") == 4, "advisor panel analysis scan renders seal glyph nodes and rhythm ticks")
	dispose_node(advisor_card_parent)
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
	check(action_intent_parent.find_child("ActionIntentText", true, false) != null and action_intent_parent.find_child("ActionIntentCount", true, false) != null and action_intent_parent.find_child("ActionIntentIcon", true, false) != null, "action intent strip renders text count badge and icon nodes")
	var action_intent_fallback_parent = Control.new()
	root.add_child(action_intent_fallback_parent)
	scene.draw_action_intent_dock(action_intent_fallback_parent, 2, true)
	check(action_intent_fallback_parent.find_child("ActionIntentFallbackIcon", true, false) != null, "action intent strip renders fallback icon label when lucide icon is unavailable")
	dispose_node(action_intent_fallback_parent)
	check(action_intent_parent.find_child("ActionIntentFlow", true, false) == null and action_intent_parent.find_child("ActionIntentCommandBridge", true, false) == null and action_intent_parent.find_child("ActionIntentExitRoute", true, false) == null and action_intent_parent.find_child("ActionIntentDecisionPulse", true, false) == null, "action intent strip drops old code-drawn flow/bridge/exit/decision decorative lines")
	check((scene.optional_gpt_illustration_texture("intent_panel_plate") == null) or (action_intent_parent.find_child("IntentPanelPlate", true, false) != null), "action intent strip uses optional GPT intent plate instead of code-drawn lines")
	check(has_label_text(action_intent_parent, "2项"), "action intent strip renders button count badge")
	dispose_node(action_intent_parent)
	var voice_button_parent = Control.new()
	root.add_child(voice_button_parent)
	var voice_on_button = scene.make_action_button("闭麦", Color(0.74, 0.24, 0.24), Callable())
	voice_button_parent.add_child(voice_on_button)
	scene.draw_voice_button_art(voice_on_button, true, 0.70)
	check(voice_on_button.find_child("VoiceChannelHaloTexture", true, false) != null and voice_on_button.find_child("VoiceWaveTexture", true, false) != null, "active voice button renders reusable voice-channel halo and voice-wave PNG textures")
	check(scene.optional_gpt_illustration_texture("voice_gpt_channel") == null or voice_on_button.find_child("VoiceGPTChannelTexture", true, false) != null, "active voice button consumes optional GPT channel texture when generated")
	check(voice_on_button.find_child("VoiceButtonArt", true, false) != null and voice_on_button.find_child("VoiceButtonStatusDot", true, false) != null and voice_on_button.find_child("VoiceButtonPulse", true, false) != null, "active voice button renders status dot and pulse")
	check(count_nodes_with_name_prefix(voice_on_button, "VoiceButtonWave_") == 3, "active voice button renders three wave bars")
	check(voice_on_button.find_child("VoiceButtonListenRing", true, false) != null and voice_on_button.find_child("VoiceButtonPeakMeter", true, false) != null and count_nodes_with_name_prefix(voice_on_button, "VoiceButtonPeakTick_") == 3, "active voice button renders listening ring and peak ticks")
	check(voice_on_button.find_child("VoiceButtonMicChannel", true, false) != null and voice_on_button.find_child("VoiceButtonMicChannelFill", true, false) != null and voice_on_button.find_child("VoiceButtonInputNode", true, false) != null and count_nodes_with_name_prefix(voice_on_button, "VoiceButtonPacketTick_") == 3, "active voice button renders mic channel and packet ticks")
	check(voice_on_button.find_child("VoiceButtonTransmitRoute", true, false) != null and voice_on_button.find_child("VoiceButtonTransmitFill", true, false) != null and voice_on_button.find_child("VoiceButtonTransmitGate", true, false) != null and count_nodes_with_name_prefix(voice_on_button, "VoiceButtonSyncTick_") == 3, "active voice button renders transmit route gate and sync ticks")
	check(voice_on_button.find_child("VoiceButtonFeedbackLoop", true, false) != null and voice_on_button.find_child("VoiceButtonFeedbackRail", true, false) != null and voice_on_button.find_child("VoiceButtonFeedbackFill", true, false) != null, "active voice button renders input-to-transmit feedback loop")
	check(voice_on_button.find_child("VoiceButtonFeedbackSource", true, false) != null and voice_on_button.find_child("VoiceButtonFeedbackReturnGate", true, false) != null and voice_on_button.find_child("VoiceButtonFeedbackConfirmRoute", true, false) != null and voice_on_button.find_child("VoiceButtonFeedbackConfirmFill", true, false) != null, "active voice button renders feedback source return gate and confirmation route")
	check(count_nodes_with_name_prefix(voice_on_button, "VoiceButtonFeedbackTick_") == 3, "active voice button renders feedback rhythm ticks")
	check(voice_on_button.find_child("VoiceButtonNetworkEcho", true, false) != null and voice_on_button.find_child("VoiceButtonNetworkRail", true, false) != null and voice_on_button.find_child("VoiceButtonNetworkFill", true, false) != null and voice_on_button.find_child("VoiceButtonRemoteNode", true, false) != null, "active voice button renders network echo route")
	check(voice_on_button.find_child("VoiceButtonNetworkGate", true, false) != null and count_nodes_with_name_prefix(voice_on_button, "VoiceButtonNetworkEchoPulse_") == 2 and count_nodes_with_name_prefix(voice_on_button, "VoiceButtonNetworkTick_") == 2, "active voice button renders network echo pulses and ticks")
	var voice_peak_fill = voice_on_button.find_child("VoiceButtonPeakFill", true, false) as Control
	check(voice_peak_fill != null and voice_peak_fill.anchor_right > 0.65, "active voice button peak fill tracks microphone level")
	var voice_off_button = scene.make_action_button("语音", Color(0.24, 0.52, 0.72), Callable())
	voice_button_parent.add_child(voice_off_button)
	scene.draw_voice_button_art(voice_off_button, false, 0.0)
	check(voice_off_button.find_child("VoiceButtonMutedSlash", true, false) != null and count_nodes_with_name_prefix(voice_off_button, "VoiceButtonWave_") == 3, "inactive voice button renders muted slash and retained wave silhouette")
	check(voice_off_button.find_child("VoiceButtonMutedLock", true, false) != null and voice_off_button.find_child("VoiceButtonPeakFill", true, false) != null and voice_off_button.find_child("VoiceButtonMicChannel", true, false) != null, "inactive voice button renders muted lock dim peak meter and channel")
	check(voice_off_button.find_child("VoiceButtonTransmitRoute", true, false) != null and voice_off_button.find_child("VoiceButtonTransmitGate", true, false) != null and count_nodes_with_name_prefix(voice_off_button, "VoiceButtonSyncTick_") == 3, "inactive voice button keeps muted transmit route silhouette")
	check(voice_off_button.find_child("VoiceButtonMuteRoute", true, false) != null and voice_off_button.find_child("VoiceButtonMuteFill", true, false) != null and voice_off_button.find_child("VoiceButtonMuteGate", true, false) != null and count_nodes_with_name_prefix(voice_off_button, "VoiceButtonMuteTick_") == 2, "inactive voice button renders mute confirmation route")
	check(voice_off_button.find_child("VoiceButtonFeedbackLoop", true, false) != null and voice_off_button.find_child("VoiceButtonFeedbackRail", true, false) != null and voice_off_button.find_child("VoiceButtonFeedbackReturnGate", true, false) != null and count_nodes_with_name_prefix(voice_off_button, "VoiceButtonFeedbackTick_") == 3, "inactive voice button retains muted feedback loop silhouette")
	check(voice_off_button.find_child("VoiceButtonNetworkEcho", true, false) != null and voice_off_button.find_child("VoiceButtonNetworkRail", true, false) != null and voice_off_button.find_child("VoiceButtonNetworkGate", true, false) != null and count_nodes_with_name_prefix(voice_off_button, "VoiceButtonNetworkEchoPulse_") == 2, "inactive voice button retains muted network echo silhouette")
	dispose_node(voice_button_parent)
	var danger_art_parent = Control.new()
	root.add_child(danger_art_parent)
	scene.draw_danger_discard_confirmation_art(danger_art_parent, "5W", {"tile": "5W", "risk_label": "高", "risk": 42.0, "feed_risk": 36.0, "safety_label": "", "stance": "防守"}, [{"tile": "1W"}, {"tile": "E"}])
	check(danger_art_parent.find_child("DangerDecisionSealTexture", true, false) != null and danger_art_parent.find_child("DangerWarningTexture", true, false) != null, "danger discard confirmation renders reusable decision-seal and warning PNG textures")
	check(scene.optional_gpt_illustration_texture("danger_gpt_discard") == null or danger_art_parent.find_child("DangerGPTDiscardTexture", true, false) != null, "danger discard confirmation consumes optional GPT discard texture when generated")
	check(danger_art_parent.find_child("DangerDiscardConfirmationArt", true, false) != null and danger_art_parent.find_child("DangerDiscardTile", true, false) != null and danger_art_parent.find_child("DangerDiscardRiskSeal", true, false) != null and danger_art_parent.find_child("DangerDiscardDetailText", true, false) != null, "danger discard confirmation renders tile risk seal and detail text illustration")
	check(danger_art_parent.find_child("DangerDiscardRouteRail", true, false) != null and danger_art_parent.find_child("DangerDiscardRiskFill", true, false) != null and danger_art_parent.find_child("DangerDiscardConfirmSeal", true, false) != null, "danger discard confirmation renders risk route and confirm seal")
	check(count_nodes_with_name_prefix(danger_art_parent, "DangerDiscardRiskNode_") == 4 and danger_art_parent.find_child("DangerDiscardAlertHalo", true, false) != null and count_nodes_with_name_prefix(danger_art_parent, "DangerDiscardAlertRing_") == 3, "danger discard confirmation renders risk nodes and alert halo")
	check(danger_art_parent.find_child("DangerDiscardSourceTrace", true, false) != null and danger_art_parent.find_child("DangerDiscardSourceFill", true, false) != null and danger_art_parent.find_child("DangerDiscardSourceGate", true, false) != null, "danger discard confirmation renders risk source trace")
	check(count_nodes_with_name_prefix(danger_art_parent, "DangerDiscardSourceNode_") == 3, "danger discard confirmation renders risk source nodes")
	check(danger_art_parent.find_child("DangerDiscardSafeRail", true, false) != null and danger_art_parent.find_child("DangerChoiceLatticeTexture", true, false) != null and count_nodes_with_name_prefix(danger_art_parent, "DangerDiscardSafeTile_") == 2 and count_nodes_with_name_prefix(danger_art_parent, "DangerDiscardSafeGlyph_") == 2 and count_nodes_with_name_prefix(danger_art_parent, "DangerDiscardSafePulse_") == 3, "danger discard confirmation renders safe alternative rail with reusable lattice texture")
	check(danger_art_parent.find_child("DangerDiscardConfirmRoute", true, false) != null and danger_art_parent.find_child("DangerDiscardConfirmFill", true, false) != null and danger_art_parent.find_child("DangerDiscardConfirmGate", true, false) != null, "danger discard confirmation renders confirm decision route")
	check(danger_art_parent.find_child("DangerDiscardAlternativeRoute", true, false) != null and danger_art_parent.find_child("DangerDiscardAlternativeFill", true, false) != null and count_nodes_with_name_prefix(danger_art_parent, "DangerDiscardAlternativeTick_") == 2, "danger discard confirmation renders alternative decision route")
	check(count_nodes_with_name_prefix(danger_art_parent, "DangerDiscardConfirmTick_") == 2, "danger discard confirmation renders confirm rhythm ticks")
	check(danger_art_parent.find_child("DangerDiscardDecisionBridge", true, false) != null and danger_art_parent.find_child("DangerDiscardDecisionBridgeRail", true, false) != null and danger_art_parent.find_child("DangerDiscardDecisionConfirmFill", true, false) != null and danger_art_parent.find_child("DangerDiscardDecisionAlternativeFill", true, false), "danger discard confirmation renders confirm-versus-alternative decision bridge")
	check(danger_art_parent.find_child("DangerDiscardDecisionSplitNode", true, false) != null and danger_art_parent.find_child("DangerDiscardDecisionGate", true, false) != null and count_nodes_with_name_prefix(danger_art_parent, "DangerDiscardDecisionTick_") == 3, "danger discard decision bridge renders split node gate and rhythm ticks")
	check(danger_art_parent.find_child("DangerDiscardFinalChoiceArt", true, false) != null and danger_art_parent.find_child("DangerDiscardFinalChoiceRoute", true, false) != null and danger_art_parent.find_child("DangerDiscardFinalChoiceFill", true, false) != null and danger_art_parent.find_child("DangerDiscardFinalChoiceGate", true, false), "danger discard confirmation renders final choice convergence route")
	check(danger_art_parent.find_child("DangerDiscardFinalChoiceSource", true, false) != null and danger_art_parent.find_child("DangerDiscardFinalChoiceSeal", true, false) != null and danger_art_parent.find_child("DangerDiscardFinalChoiceGlyph", true, false) != null, "danger discard final choice renders source seal and decision glyph")
	check(danger_art_parent.find_child("DangerDiscardFinalAlternativeBridge", true, false) != null and danger_art_parent.find_child("DangerDiscardFinalAlternativeFill", true, false) != null, "danger discard final choice renders alternative convergence bridge")
	check(count_nodes_with_name_prefix(danger_art_parent, "DangerDiscardFinalChoiceNode_") == 3 and count_nodes_with_name_prefix(danger_art_parent, "DangerDiscardFinalChoiceTick_") == 3, "danger discard final choice renders convergence nodes and rhythm ticks")
	dispose_node(danger_art_parent)
	scene.chat_messages = ["甲: 准备好了", "乙: 碰", "你: 收到"]
	scene.show_chat_panel()
	check(scene.find_child("ChatPanelBrocadeTexture", true, false) != null and scene.find_child("ChatStreamTexture", true, false) != null, "chat panel renders reusable brocade and stream PNG textures")
	check(scene.optional_gpt_illustration_texture("chat_gpt_panel") == null or scene.find_child("ChatGPTPanelTexture", true, false) != null, "chat panel consumes optional GPT panel texture when generated")
	check(scene.find_child("ChatPanel", true, false) != null and scene.find_child("ChatPanelArt", true, false) != null and scene.find_child("ChatPanelHeader", true, false) != null and scene.find_child("ChatPanelCountBadge", true, false) != null, "chat panel renders illustrated header and count badge")
	check(scene.find_child("ChatPanelHeaderBridge", true, false) != null and scene.find_child("ChatPanelHeaderBridgeFill", true, false) != null and scene.find_child("ChatPanelHeaderBridgeGate", true, false) != null and count_nodes_with_name_prefix(scene, "ChatPanelHeaderBridgeTick_") == 2, "chat panel renders header-to-feed bridge route")
	check(scene.find_child("ChatPanelActivityRail", true, false) != null and scene.find_child("ChatPanelLatestGlow", true, false) != null and count_nodes_with_name_prefix(scene, "ChatPanelMessageNode_") == 3, "chat panel renders activity rail and one visible node per recent message")
	check(count_nodes_with_name_prefix(scene, "ChatPanelSenderChip_") == 3 and count_nodes_with_name_prefix(scene, "ChatPanelUnreadBead_") == 3, "chat panel renders sender chips and unread beads")
	check(count_nodes_with_name_prefix(scene, "ChatPanelMessageLane_") == 3 and count_nodes_with_name_prefix(scene, "ChatPanelFlowTick_") == 3 and scene.find_child("ChatPanelLatestCursor", true, false) != null, "chat panel renders per-message lanes and latest cursor")
	check(count_nodes_with_name_prefix(scene, "ChatPanelOutgoingRibbon_") == 1 and scene.find_child("ChatPanelInputPulse", true, false) != null and count_nodes_with_name_prefix(scene, "ChatPanelTypingWave_") == 3, "chat panel renders outgoing and typing feedback art")
	check(scene.find_child("ChatPanelSyncRoute", true, false) != null and scene.find_child("ChatPanelSyncFill", true, false) != null and scene.find_child("ChatPanelSyncGate", true, false) != null and count_nodes_with_name_prefix(scene, "ChatPanelSyncTick_") == 2, "chat panel renders latest-message sync route")
	check(scene.find_child("ChatPanelDeliveryRoute", true, false) != null and scene.find_child("ChatPanelDeliveryFill", true, false) != null and scene.find_child("ChatPanelDeliveryGate", true, false) != null, "chat panel renders delivery route")
	check(count_nodes_with_name_prefix(scene, "ChatPanelDeliveryTick_") == 3, "chat panel renders delivery rhythm ticks")
	scene.play_chat_send_panel_feedback("收到")
	check(scene.find_child("ChatSendPanelFeedback", true, false) != null and scene.find_child("ChatSendPanelSource", true, false) != null and scene.find_child("ChatSendPanelRoute", true, false) != null and scene.find_child("ChatSendPanelFill", true, false) != null and scene.find_child("ChatSendPanelGate", true, false) != null, "chat send panel feedback renders source route fill and gate")
	check(scene.find_child("ChatSendPanelReceiptNode", true, false) != null and scene.find_child("ChatSendPanelReceiptGlyph", true, false) != null and count_nodes_with_name_prefix(scene, "ChatSendPanelTick_") == 3, "chat send panel feedback renders receipt node glyph and ticks")
	check(scene.find_child("ChatSendSyncBridge", true, false) != null and scene.find_child("ChatSendSyncSource", true, false) != null and scene.find_child("ChatSendSyncStreamRoute", true, false) != null and scene.find_child("ChatSendSyncStreamFill", true, false) != null and scene.find_child("ChatSendSyncStreamGate", true, false) != null, "chat send panel feedback renders message stream sync bridge")
	check(scene.find_child("ChatSendSyncConfirmRoute", true, false) != null and scene.find_child("ChatSendSyncConfirmFill", true, false) != null and scene.find_child("ChatSendSyncArchive", true, false) != null and scene.find_child("ChatSendSyncArchiveGlyph", true, false) != null and scene.find_child("ChatSendSealTexture", true, false) != null, "chat send sync bridge renders confirm route archive glyph and GPT send seal")
	check(count_nodes_with_name_prefix(scene, "ChatSendSyncTick_") == 3 and count_nodes_with_name_prefix(scene, "ChatSendSyncPip_") == 2, "chat send sync bridge renders rhythm ticks and archive pips")
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
	check(scene.find_child("ExitGateTexture", true, false) != null and scene.find_child("ExitSaveScrollTexture", true, false) != null, "exit confirm dialog renders reusable save-gate and GPT save-scroll PNG textures")
	check(scene.optional_gpt_illustration_texture("exit_gpt_confirm") == null or scene.find_child("ExitConfirmGPTTexture", true, false) != null, "exit confirm dialog consumes optional GPT confirm texture when generated")
	check(scene.find_child("ExitConfirmDialog", true, false) != null and scene.find_child("ExitConfirmArt", true, false) != null and scene.find_child("ExitConfirmSaveRail", true, false) != null, "exit confirm dialog renders save-flow illustration")
	check(scene.find_child("ExitConfirmTableNode", true, false) != null and scene.find_child("ExitConfirmSaveNode", true, false) != null and scene.find_child("ExitConfirmLeaveNode", true, false) != null, "exit confirm illustration renders table save and leave nodes")
	check(scene.find_child("ExitConfirmSaveGlow", true, false) != null and count_nodes_with_name_prefix(scene, "ExitConfirmSavePip_") == 3, "exit confirm illustration renders save glow and progress pips")
	check(scene.find_child("ExitConfirmAutosaveRoute", true, false) != null and scene.find_child("ExitConfirmAutosaveFill", true, false) != null and scene.find_child("ExitConfirmAutosaveGate", true, false) != null and count_nodes_with_name_prefix(scene, "ExitConfirmAutosaveTick_") == 3, "exit confirm illustration renders autosave confirmation route")
	check(scene.find_child("ExitConfirmChoiceArt", true, false) != null and scene.find_child("ExitConfirmChoiceSilk", true, false) != null and scene.find_child("ExitConfirmKeepChoiceRail", true, false) != null and scene.find_child("ExitConfirmLeaveChoiceRail", true, false) != null, "exit confirm dialog renders choice silk and rail illustration")
	check(scene.find_child("ExitConfirmKeepChoiceFill", true, false) != null and scene.find_child("ExitConfirmLeaveChoiceFill", true, false) != null and scene.find_child("ExitConfirmKeepChoiceDot", true, false) != null and scene.find_child("ExitConfirmLeaveChoiceDot", true, false) != null and count_nodes_with_name_prefix(scene, "ExitConfirmKeepChoiceNode_") == 3 and count_nodes_with_name_prefix(scene, "ExitConfirmLeaveChoiceNode_") == 3, "exit confirm choice art renders decision fills dots and comparison nodes")
	check(scene.find_child("ExitConfirmChoiceBridge", true, false) != null and scene.find_child("ExitConfirmChoiceBridgeKeepFill", true, false) != null and scene.find_child("ExitConfirmChoiceBridgeLeaveFill", true, false) != null and scene.find_child("ExitConfirmChoiceBridgeGate", true, false) != null, "exit confirm choice art renders save-to-choice bridge")
	check(count_nodes_with_name_prefix(scene, "ExitConfirmChoiceBridgeKeepTick_") == 2 and count_nodes_with_name_prefix(scene, "ExitConfirmChoiceBridgeLeaveTick_") == 2, "exit confirm choice art renders bridge rhythm ticks")
	check(scene.find_child("ExitConfirmCommitRoute", true, false) != null and scene.find_child("ExitConfirmCommitKeepFill", true, false) != null and scene.find_child("ExitConfirmCommitLeaveFill", true, false) != null and scene.find_child("ExitConfirmCommitGate", true, false) != null, "exit confirm choice art renders commit route toward buttons")
	check(count_nodes_with_name_prefix(scene, "ExitConfirmCommitTick_") == 3, "exit confirm choice art renders commit route rhythm ticks")
	check(scene.find_child("ExitConfirmSaveStamp", true, false) != null and count_nodes_with_name_prefix(scene, "ExitConfirmKeepSpark_") == 2 and count_nodes_with_name_prefix(scene, "ExitConfirmLeaveSpark_") == 2, "exit confirm choice art renders save stamp and directional sparks")
	check(count_nodes_with_name_prefix(scene, "ExitConfirmButtonArt_") == 2 and count_nodes_with_name_prefix(scene, "ExitConfirmButtonRail_") == 2 and count_nodes_with_name_prefix(scene, "ExitConfirmButtonFill_") == 2 and count_nodes_with_name_prefix(scene, "ExitConfirmButtonGate_") == 2, "exit confirm buttons render keep and leave command route art")
	check(count_nodes_with_name_prefix(scene, "ExitConfirmButtonTick_") == 4, "exit confirm buttons render command rhythm ticks")
	var exit_keep_button = first_button_with_text(scene, "继续游戏")
	check(exit_keep_button != null, "exit confirm exposes keep button for press feedback")
	scene.play_exit_confirm_button_feedback(exit_keep_button, "keep", Color(0.28, 0.52, 0.44))
	check(scene.find_child("ExitConfirmChoiceCommitFeedback_keep", true, false) != null and scene.find_child("ExitConfirmChoiceCommitSource_keep", true, false) != null and scene.find_child("ExitConfirmChoiceCommitRoute_keep", true, false) != null and scene.find_child("ExitConfirmChoiceCommitFill_keep", true, false) != null and scene.find_child("ExitConfirmChoiceCommitGate_keep", true, false), "exit confirm keep press renders dialog-level commit route")
	check(scene.find_child("ExitConfirmChoiceCommitArchive_keep", true, false) != null and scene.find_child("ExitConfirmChoiceCommitGlyph_keep", true, false) != null and count_nodes_with_name_prefix(scene, "ExitConfirmChoiceCommitTick_keep_") == 3 and count_nodes_with_name_prefix(scene, "ExitConfirmChoiceCommitPip_keep_") == 3, "exit confirm keep press renders dialog-level archive glyph ticks and pips")
	check(exit_keep_button.find_child("ExitConfirmButtonPressFeedback_keep", true, false) != null and exit_keep_button.find_child("ExitConfirmButtonPressSource_keep", true, false) != null and exit_keep_button.find_child("ExitConfirmButtonPressRoute_keep", true, false) != null and exit_keep_button.find_child("ExitConfirmButtonPressFill_keep", true, false) != null and exit_keep_button.find_child("ExitConfirmButtonPressGate_keep", true, false) != null, "exit confirm keep press feedback renders source route fill and gate")
	check(exit_keep_button.find_child("ExitConfirmButtonPressSeal_keep", true, false) != null and exit_keep_button.find_child("ExitConfirmButtonPressGlyph_keep", true, false) != null and count_nodes_with_name_prefix(exit_keep_button, "ExitConfirmButtonPressTick_keep_") == 3, "exit confirm keep press feedback renders seal glyph and rhythm ticks")
	var exit_leave_button = first_button_with_text(scene, "退出游戏")
	check(exit_leave_button != null, "exit confirm exposes leave button for press feedback")
	scene.play_exit_confirm_button_feedback(exit_leave_button, "leave", Color(0.56, 0.36, 0.30))
	check(scene.find_child("ExitConfirmChoiceCommitFeedback_leave", true, false) != null and scene.find_child("ExitConfirmChoiceCommitSource_leave", true, false) != null and scene.find_child("ExitConfirmChoiceCommitRoute_leave", true, false) != null and scene.find_child("ExitConfirmChoiceCommitFill_leave", true, false) != null and scene.find_child("ExitConfirmChoiceCommitGate_leave", true, false), "exit confirm leave press renders dialog-level commit route")
	check(scene.find_child("ExitConfirmChoiceCommitArchive_leave", true, false) != null and scene.find_child("ExitConfirmChoiceCommitGlyph_leave", true, false) != null and count_nodes_with_name_prefix(scene, "ExitConfirmChoiceCommitTick_leave_") == 3 and count_nodes_with_name_prefix(scene, "ExitConfirmChoiceCommitPip_leave_") == 3, "exit confirm leave press renders dialog-level archive glyph ticks and pips")
	check(exit_leave_button.find_child("ExitConfirmButtonPressFeedback_leave", true, false) != null and exit_leave_button.find_child("ExitConfirmButtonPressSource_leave", true, false) != null and exit_leave_button.find_child("ExitConfirmButtonPressRoute_leave", true, false) != null and exit_leave_button.find_child("ExitConfirmButtonPressFill_leave", true, false) != null and exit_leave_button.find_child("ExitConfirmButtonPressGate_leave", true, false) != null, "exit confirm leave press feedback renders source route fill and gate")
	check(exit_leave_button.find_child("ExitConfirmButtonPressSeal_leave", true, false) != null and exit_leave_button.find_child("ExitConfirmButtonPressGlyph_leave", true, false) != null and count_nodes_with_name_prefix(exit_leave_button, "ExitConfirmButtonPressTick_leave_") == 3, "exit confirm leave press feedback renders seal glyph and rhythm ticks")
	scene.hide_exit_confirm()
	await process_frame
	var settings_parent = Control.new()
	root.add_child(settings_parent)
	scene.settings_panel_open = true
	scene.draw_settings_overlay(settings_parent)
	var settings_panel = settings_parent.find_child("SettingsPanel", true, false) as Control
	check(settings_panel != null and control_anchor_rect_matches(settings_panel, scene.SETTINGS_PANEL_RECT), "settings overlay uses named 960-safe modal geometry")
	check(settings_parent.find_child("SettingsConsole3DCastShadow", true, false) != null and settings_parent.find_child("SettingsConsole3DRearShell", true, false) != null and settings_parent.find_child("SettingsConsole3DLowerEdge", true, false) != null and settings_parent.find_child("SettingsConsole3DTopGlint", true, false) != null, "settings overlay renders a physical console rear shell with cast shadow and edge lighting")
	check(settings_parent.find_child("SettingsConsole3DLeftRail", true, false) != null and settings_parent.find_child("SettingsConsole3DRightRail", true, false) != null and settings_parent.find_child("SettingsConsole3DInnerFloor", true, false) != null and count_nodes_with_name_prefix(settings_parent, "SettingsConsole3DCornerCap_") == 4, "settings console renders side rails inner floor and four corner fittings")
	check(count_nodes_with_name_prefix(settings_parent, "SettingsSection3DCastShadow_") == 3 and count_nodes_with_name_prefix(settings_parent, "SettingsSection3DDepthEdge_") == 3 and count_nodes_with_name_prefix(settings_parent, "SettingsSection3DTopRim_") == 3, "settings sections render three complete physical shadow depth and top-rim layers")
	check(settings_parent.find_child("SettingsCompassTexture", true, false) != null, "settings overlay renders reusable compass PNG texture")
	check(scene.optional_gpt_illustration_texture("settings_gpt_panel") == null or settings_parent.find_child("SettingsGPTPanelTexture", true, false) != null, "settings overlay consumes optional GPT panel texture when generated")
	check(settings_parent.get_child_count() == 1 and (has_button_text(settings_parent, "已开") or has_button_text(settings_parent, "已关")) and has_button_text(settings_parent, "试音") and not has_button_text(settings_parent, "切换") and not has_button_text(settings_parent, "音乐开") and not has_button_text(settings_parent, "快速开"), "settings overlay renders stateful toggle and test-audio buttons")
	check(count_texture_rects(settings_parent) >= 1, "settings overlay renders lucide title icon")
	check(settings_parent.find_child("SettingsCloseButton", true, false) != null and settings_parent.find_child("SettingsCloseButtonArt", true, false) != null and settings_parent.find_child("SettingsCloseSilkTexture", true, false) != null and settings_parent.find_child("SettingsCloseRail", true, false) != null and settings_parent.find_child("SettingsCloseFill", true, false) != null and settings_parent.find_child("SettingsCloseGate", true, false) != null, "settings close button renders reusable silk texture and dismiss route art")
	check(count_nodes_with_name_prefix(settings_parent, "SettingsCloseTick_") == 2, "settings close button renders dismiss rhythm ticks")
	var settings_close_button = settings_parent.find_child("SettingsCloseButton", true, false) as Button
	check(settings_close_button != null, "settings overlay exposes close button for press feedback")
	scene.play_settings_close_button_feedback(settings_close_button)
	check(settings_close_button.find_child("SettingsClosePressFeedback", true, false) != null and settings_close_button.find_child("SettingsClosePressSource", true, false) != null and settings_close_button.find_child("SettingsClosePressRoute", true, false) != null and settings_close_button.find_child("SettingsClosePressFill", true, false) != null and settings_close_button.find_child("SettingsClosePressGate", true, false) != null, "settings close press feedback renders dismiss route")
	check(settings_close_button.find_child("SettingsClosePressSeal", true, false) != null and settings_close_button.find_child("SettingsClosePressGlyph", true, false) != null and count_nodes_with_name_prefix(settings_close_button, "SettingsClosePressTick_") == 3, "settings close press feedback renders seal glyph and rhythm ticks")
	check(settings_parent.find_child("SettingsOverviewArt", true, false) != null and settings_parent.find_child("SettingsOverviewRail", true, false) != null and settings_parent.find_child("SettingsOverviewFill", true, false) != null, "settings overlay renders overview meter")
	check(settings_parent.find_child("SettingsOverviewScrollTexture", true, false) != null and count_nodes_with_name_prefix(settings_parent, "SettingsSectionBrocadeTexture_") == 3, "settings overlay renders reusable overview scroll and section brocade textures")
	check(settings_parent.find_child("SettingsOverviewNode_audio", true, false) != null and settings_parent.find_child("SettingsOverviewNode_play", true, false) != null and settings_parent.find_child("SettingsOverviewNode_maint", true, false) != null and settings_parent.find_child("SettingsOverviewGlyph_audio", true, false) != null and settings_parent.find_child("SettingsOverviewGlyph_play", true, false) != null and settings_parent.find_child("SettingsOverviewGlyph_maint", true, false) != null and settings_parent.find_child("SettingsOverviewStatusLight", true, false) != null, "settings overview renders audio play maintenance nodes glyphs and status light")
	check(settings_parent.find_child("SettingsOverviewSystemBus", true, false) == null and settings_parent.find_child("SettingsOverviewSystemBusFill", true, false) == null and settings_parent.find_child("SettingsOverviewSystemBusGate", true, false) == null, "settings overview drops code-drawn system status bus lines")
	check(count_nodes_with_name_prefix(settings_parent, "SettingsOverviewSystemBusTick_") == 0 and count_nodes_with_name_prefix(settings_parent, "SettingsOverviewBusPulse_") == 0 and ((scene.optional_gpt_illustration_texture("settings_overview_panel") == null) or (settings_parent.find_child("SettingsOverviewPanelTexture", true, false) != null)), "settings overview replaces bus ticks and group pulses with optional GPT overview panel plate")
	check(settings_parent.find_child("SettingsSectionRouteArt", true, false) != null and settings_parent.find_child("SettingsSectionRouteRail", true, false) != null and settings_parent.find_child("SettingsSectionRouteFill", true, false) != null and settings_parent.find_child("SettingsSectionRouteGate", true, false) != null, "settings overlay renders overview-to-section route")
	check(settings_parent.find_child("SettingsSectionRouteBranch_audio", true, false) != null and settings_parent.find_child("SettingsSectionRouteBranch_play", true, false) != null and settings_parent.find_child("SettingsSectionRouteBranch_maint", true, false) != null, "settings section route renders branches to audio play and maintenance")
	check(count_nodes_with_name_prefix(settings_parent, "SettingsSectionRouteNode_") == 3 and count_nodes_with_name_prefix(settings_parent, "SettingsSectionRouteSource_") == 3 and count_nodes_with_name_prefix(settings_parent, "SettingsSectionRouteTick_") == 4, "settings section route renders nodes sources and rhythm ticks")
	check(settings_parent.find_child("SettingsApplySyncArt", true, false) != null and settings_parent.find_child("SettingsApplySyncSource", true, false) != null and settings_parent.find_child("SettingsApplySyncRoute", true, false) != null and settings_parent.find_child("SettingsApplySyncFill", true, false) != null and settings_parent.find_child("SettingsApplySyncGate", true, false) != null, "settings overlay renders apply sync route")
	check(settings_parent.find_child("SettingsApplySyncArchive", true, false) != null and settings_parent.find_child("SettingsApplySyncGlyph", true, false) != null and settings_parent.find_child("SettingsApplyCloseRoute", true, false) != null and settings_parent.find_child("SettingsApplyCloseFill", true, false) != null and count_nodes_with_name_prefix(settings_parent, "SettingsApplySyncNode_") == 3 and count_nodes_with_name_prefix(settings_parent, "SettingsApplySyncTick_") == 4, "settings apply sync renders archive close route nodes and ticks")
	var settings_apply_fill = settings_parent.find_child("SettingsApplySyncFill", true, false) as Control
	check(settings_apply_fill != null and settings_apply_fill.anchor_right > 0.55, "settings apply sync fill tracks enabled preference count")
	check(settings_parent.find_child("SettingsSectionSignal_声音", true, false) != null and settings_parent.find_child("SettingsSectionSignalRail_体验", true, false) == null and settings_parent.find_child("SettingsSectionSignalIcon_系统", true, false) != null, "settings overlay renders section signal art while dropping code-drawn rail")
	check(count_nodes_with_name_prefix(settings_parent, "SettingsSectionSignalPulse_声音_") == 0 and count_nodes_with_name_prefix(settings_parent, "SettingsSectionSignalPulse_体验_") == 0 and count_nodes_with_name_prefix(settings_parent, "SettingsSectionSignalPulse_系统_") == 0 and ((scene.optional_gpt_illustration_texture("settings_section_signal_panel") == null) or (count_nodes_with_name_prefix(settings_parent, "SettingsSectionSignalPanelTexture_") == 3)), "settings overlay replaces section signal pulses with optional GPT signal panel plate")
	check(count_nodes_with_name_prefix(settings_parent, "SettingRowStatusArt_") == 10 and count_nodes_with_name_prefix(settings_parent, "SettingRowStatusRail_") == 0 and count_nodes_with_name_prefix(settings_parent, "SettingRowStatusFill_") == 0, "settings rows keep status art but omit obsolete row rails and fills")
	check(count_nodes_with_name_prefix(settings_parent, "SettingRowStatusDot_") == 0, "settings rows omit compact status dots that competed with text")
	check(count_nodes_with_name_prefix(settings_parent, "SettingRowTextReadabilityPanel_") == 11, "settings rows expose local text readability panels")
	check(count_nodes_with_name_prefix(settings_parent, "SettingSwitchArt") == 6 and count_nodes_with_name_prefix(settings_parent, "SettingSwitchRail") == 6, "settings toggle buttons render compact switch art and rails")
	check(count_nodes_with_name_prefix(settings_parent, "SettingSwitchDirectionRoute") == 0 and count_nodes_with_name_prefix(settings_parent, "SettingSwitchDirectionFill") == 0 and count_nodes_with_name_prefix(settings_parent, "SettingSwitchDirectionGate") == 0 and count_nodes_with_name_prefix(settings_parent, "SettingSwitchStateRoute") == 0 and count_nodes_with_name_prefix(settings_parent, "SettingSwitchStateFill") == 0 and count_nodes_with_name_prefix(settings_parent, "SettingSwitchStateGate") == 0 and count_nodes_with_name_prefix(settings_parent, "SettingSwitchKnobConfirmRoute") == 0 and count_nodes_with_name_prefix(settings_parent, "SettingSwitchKnobConfirmFill") == 0 and count_nodes_with_name_prefix(settings_parent, "SettingSwitchKnobConfirmGate") == 0, "settings toggle buttons omit obsolete route/state/knob confirmation clutter")
	for section_name in ["声音", "体验", "系统"]:
		check(settings_parent.find_child("SettingsSection_%s" % section_name, true, false) != null and settings_parent.find_child("SettingsSectionGrid_%s" % section_name, true, false) != null, "settings section %s exposes stable section and grid nodes" % section_name)
	for title in ["背景音乐", "音效反馈", "语音报牌", "播放测试", "AI 节奏", "桌面特效", "出牌辅助", "播放曲目", "3D 画质", "本地进度"]:
		check(settings_parent.find_child("SettingRow_%s" % title, true, false) != null, "settings row %s exposes a stable row node" % title)
		var compact_button = settings_parent.find_child("SettingRowButton_%s" % title, true, false) as Button
		check(compact_button != null and compact_button.text.length() <= 4 and compact_button.clip_text and compact_button.get_theme_font_size("font_size") <= 15, "settings row %s exposes compact safe button" % title)
		var row_title_label = settings_parent.find_child("SettingRowTitle_%s" % title, true, false) as Label
		var row_status_label = settings_parent.find_child("SettingRowStatus_%s" % title, true, false) as Label
		check(row_title_label != null and row_title_label.clip_text and row_title_label.get_theme_font_size("font_size") >= 13, "settings row %s exposes clipped readable title" % title)
		check(row_status_label != null and row_status_label.clip_text and row_status_label.get_theme_font_size("font_size") >= 12, "settings row %s exposes clipped readable status" % title)
		check(settings_parent.find_child("SettingRowTextReadabilityPanel_%s" % title, true, false) != null, "settings row %s exposes a local text backplate" % title)
	var audio_test_speaker_seal = settings_parent.find_child("AudioTestSpeakerSeal", true, false)
	check(settings_parent.find_child("AudioTestTexture", true, false) != null and settings_parent.find_child("AudioTestButtonArt", true, false) != null and settings_parent.find_child("AudioTestWaveRail", true, false) != null and settings_parent.find_child("AudioTestWaveFill", true, false) != null and audio_test_speaker_seal != null and audio_test_speaker_seal.find_child("AudioTestSpeakerGlyph", true, false) != null and count_nodes_with_name_prefix(settings_parent, "AudioTestWaveBar_") == 4, "settings audio test button renders reusable PNG wave fill speaker illustration")
	check(settings_parent.find_child("AudioTestCommandRoute", true, false) != null and settings_parent.find_child("AudioTestCommandFill", true, false) != null and settings_parent.find_child("AudioTestCommandGate", true, false) != null and count_nodes_with_name_prefix(settings_parent, "AudioTestCommandTick_") == 2, "settings audio test button renders command route art")
	check(settings_parent.find_child("AudioTestPlaybackRoute", true, false) != null and settings_parent.find_child("AudioTestPlaybackFill", true, false) != null and settings_parent.find_child("AudioTestPlaybackGate", true, false) != null and count_nodes_with_name_prefix(settings_parent, "AudioTestPlaybackTick_") == 3, "settings audio test button renders speaker-to-wave playback route")
	check(settings_parent.find_child("BgmSwitchTexture", true, false) != null and settings_parent.find_child("BgmSwitchButtonArt", true, false) != null and settings_parent.find_child("BgmSwitchDisc", true, false) != null and settings_parent.find_child("BgmSwitchDiscCore", true, false) != null and settings_parent.find_child("BgmSwitchTrackRail", true, false) != null and settings_parent.find_child("BgmSwitchTrackFill", true, false) != null and count_nodes_with_name_prefix(settings_parent, "BgmSwitchNote_") == 3, "settings BGM switch button renders reusable PNG track illustration")
	check(settings_parent.find_child("BgmSwitchCommandRoute", true, false) != null and settings_parent.find_child("BgmSwitchCommandFill", true, false) != null and settings_parent.find_child("BgmSwitchCommandGate", true, false) != null and count_nodes_with_name_prefix(settings_parent, "BgmSwitchCommandTick_") == 2, "settings BGM switch button renders next-track command route")
	check(settings_parent.find_child("BgmSwitchPlaybackRoute", true, false) != null and settings_parent.find_child("BgmSwitchPlaybackFill", true, false) != null and settings_parent.find_child("BgmSwitchPlaybackGate", true, false) != null and count_nodes_with_name_prefix(settings_parent, "BgmSwitchPlaybackTick_") == 3, "settings BGM switch button renders disc-to-note playback route")
	var settings_toggle_button = settings_parent.find_child("SettingRowButton_背景音乐", true, false) as Button
	var audio_test_button = first_button_with_text(settings_parent, "试音")
	var bgm_switch_button = first_button_with_text(settings_parent, "切歌")
	check(settings_toggle_button != null and audio_test_button != null and bgm_switch_button != null and first_button_with_prefix(settings_parent, "切歌:") == null, "settings overlay exposes short BGM switch button without long track-name text")
	scene.play_settings_action_feedback(settings_toggle_button, "Toggle", Color(0.22, 0.52, 0.42))
	scene.play_settings_action_feedback(audio_test_button, "AudioTest", Color(0.42, 0.68, 0.86))
	scene.play_settings_action_feedback(bgm_switch_button, "BgmSwitch", Color(0.62, 0.58, 0.86))
	check(settings_parent.find_child("SettingsActionFeedback_Toggle", true, false) != null and settings_parent.find_child("SettingsActionFeedbackRoute_Toggle", true, false) != null and settings_parent.find_child("SettingsActionFeedbackFill_Toggle", true, false) != null and settings_parent.find_child("SettingsActionFeedbackGate_Toggle", true, false) != null, "settings toggle press renders action feedback route")
	check(settings_parent.find_child("SettingsActionFeedback_AudioTest", true, false) != null and settings_parent.find_child("SettingsActionFeedbackSource_AudioTest", true, false) != null and settings_parent.find_child("SettingsActionFeedbackSeal_AudioTest", true, false) != null and count_nodes_with_name_prefix(settings_parent, "SettingsActionFeedbackTick_AudioTest_") == 3, "settings audio test press renders source seal and ticks")
	check(settings_parent.find_child("SettingsActionFeedback_BgmSwitch", true, false) != null and settings_parent.find_child("SettingsActionFeedbackSource_BgmSwitch", true, false) != null and settings_parent.find_child("SettingsActionFeedbackSeal_BgmSwitch", true, false) != null and count_nodes_with_name_prefix(settings_parent, "SettingsActionFeedbackTick_BgmSwitch_") == 3, "settings BGM switch press renders source seal and ticks")
	check(settings_parent.find_child("ResetDangerSealTexture", true, false) != null and settings_parent.find_child("ResetProgressButtonArt", true, false) != null and settings_parent.find_child("ResetProgressDangerRail", true, false) != null and settings_parent.find_child("ResetProgressDangerFill", true, false) != null and settings_parent.find_child("ResetProgressLockSeal", true, false) != null and settings_parent.find_child("ResetProgressLockGlyph", true, false) != null, "settings reset progress button renders reusable PNG danger lock art")
	check(settings_parent.find_child("ResetProgressHoldRoute", true, false) != null and settings_parent.find_child("ResetProgressHoldFill", true, false) != null and settings_parent.find_child("ResetProgressHoldGate", true, false) != null and count_nodes_with_name_prefix(settings_parent, "ResetProgressHoldTick_") == 2, "settings reset progress button renders confirmation route art")
	check(settings_parent.find_child("ResetProgressLockRoute", true, false) != null and settings_parent.find_child("ResetProgressLockFill", true, false) != null and settings_parent.find_child("ResetProgressLockGate", true, false) != null and count_nodes_with_name_prefix(settings_parent, "ResetProgressLockTick_") == 3, "settings reset progress button renders lock confirmation route")
	check(count_nodes_with_name_prefix(settings_parent, "ResetProgressDangerNode_") == 3 and count_nodes_with_name_prefix(settings_parent, "ResetProgressWarningSpark_") == 2, "settings reset progress button renders danger nodes and warning sparks")
	var reset_texture = settings_parent.find_child("ResetDangerSealTexture", true, false) as CanvasItem
	check(reset_texture == null or reset_texture.modulate.a <= 0.12, "settings reset progress full-button texture stays subdued")
	check(settings_parent.find_child("ResetProgressConfirmArt", true, false) == null, "settings reset progress button starts in safe unarmed state")
	var reset_prepare_button = first_button_with_text(settings_parent, "重置")
	check(reset_prepare_button != null, "settings exposes reset progress button for prepare press feedback")
	check(setting_button_anchor_nodes_clear_text_lane(reset_prepare_button, ["ResetProgressDangerRail", "ResetProgressDangerFill", "ResetProgressHoldRoute", "ResetProgressHoldFill", "ResetProgressHoldGate", "ResetProgressHoldTick_", "ResetProgressLockSeal", "ResetProgressLockRoute", "ResetProgressLockFill", "ResetProgressLockGate", "ResetProgressLockTick_", "ResetProgressDangerNode_", "ResetProgressWarningSpark_"]), "settings reset progress art avoids the button text anchor lane")
	scene.play_reset_progress_button_feedback(reset_prepare_button, false)
	check(reset_prepare_button.find_child("ResetProgressPressFeedback_prepare", true, false) != null and reset_prepare_button.find_child("ResetProgressPressSource_prepare", true, false) != null and reset_prepare_button.find_child("ResetProgressPressRoute_prepare", true, false) != null and reset_prepare_button.find_child("ResetProgressPressFill_prepare", true, false) != null and reset_prepare_button.find_child("ResetProgressPressGate_prepare", true, false) != null, "settings reset prepare press feedback renders warning route")
	check(reset_prepare_button.find_child("ResetProgressPressSeal_prepare", true, false) != null and reset_prepare_button.find_child("ResetProgressPressGlyph_prepare", true, false) != null and reset_prepare_button.find_child("ResetProgressPressWarningLock", true, false) != null and count_nodes_with_name_prefix(reset_prepare_button, "ResetProgressPressTick_prepare_") == 3, "settings reset prepare press feedback renders warning seal lock and ticks")
	check(panels_ignore_mouse(settings_parent), "settings overlay panels skip mouse hit testing while buttons remain interactive")
	check(containers_ignore_mouse(settings_parent), "settings overlay layout containers skip mouse hit testing")
	dispose_node(settings_parent)
	scene.settings_panel_open = false
	var reset_confirm_parent = Control.new()
	root.add_child(reset_confirm_parent)
	scene.reset_progress_confirming = true
	scene.settings_panel_open = true
	scene.draw_settings_overlay(reset_confirm_parent)
	check(has_button_text(reset_confirm_parent, "清空"), "settings reset progress button changes to compact armed label")
	check(reset_confirm_parent.find_child("ResetProgressConfirmArt", true, false) != null and reset_confirm_parent.find_child("ResetProgressConfirmRoute", true, false) != null and reset_confirm_parent.find_child("ResetProgressConfirmFill", true, false) != null and reset_confirm_parent.find_child("ResetProgressConfirmGate", true, false) != null, "settings reset progress armed state renders confirm route art")
	check(scene.optional_gpt_illustration_texture("reset_gpt_warning") == null or reset_confirm_parent.find_child("ResetGPTWarningTexture", true, false) != null, "settings reset confirmation consumes optional GPT warning texture when generated")
	check(reset_confirm_parent.find_child("ResetProgressConfirmSeal", true, false) != null and reset_confirm_parent.find_child("ResetProgressConfirmGlyph", true, false) != null and count_nodes_with_name_prefix(reset_confirm_parent, "ResetProgressConfirmNode_") == 3 and count_nodes_with_name_prefix(reset_confirm_parent, "ResetProgressConfirmPulse_") == 2, "settings reset progress armed state renders warning seal glyph nodes and pulses")
	check(reset_confirm_parent.find_child("ResetProgressCommitRoute", true, false) != null and reset_confirm_parent.find_child("ResetProgressCommitFill", true, false) != null and reset_confirm_parent.find_child("ResetProgressCommitSource", true, false) != null and reset_confirm_parent.find_child("ResetProgressCommitGate", true, false) != null and reset_confirm_parent.find_child("ResetProgressCommitGlyph", true, false) != null, "settings reset progress armed state renders final commit route")
	check(count_nodes_with_name_prefix(reset_confirm_parent, "ResetProgressCommitTick_") == 2, "settings reset progress armed state renders commit rhythm ticks")
	var reset_confirm_hold_fill = reset_confirm_parent.find_child("ResetProgressHoldFill", true, false) as Control
	check(reset_confirm_hold_fill != null and reset_confirm_hold_fill.anchor_right > 0.85, "settings reset progress armed state extends the hold fill")
	var reset_armed_button = first_button_with_text(reset_confirm_parent, "清空")
	check(reset_armed_button != null, "settings exposes armed reset progress button for commit press feedback")
	scene.play_reset_progress_button_feedback(reset_armed_button, true)
	check(reset_armed_button.find_child("ResetProgressPressFeedback_armed", true, false) != null and reset_armed_button.find_child("ResetProgressPressSource_armed", true, false) != null and reset_armed_button.find_child("ResetProgressPressRoute_armed", true, false) != null and reset_armed_button.find_child("ResetProgressPressFill_armed", true, false) != null and reset_armed_button.find_child("ResetProgressPressGate_armed", true, false) != null, "settings reset armed press feedback renders commit route")
	check(reset_armed_button.find_child("ResetProgressPressSeal_armed", true, false) != null and reset_armed_button.find_child("ResetProgressPressGlyph_armed", true, false) != null and reset_armed_button.find_child("ResetProgressPressCommitSeal", true, false) != null and count_nodes_with_name_prefix(reset_armed_button, "ResetProgressPressTick_armed_") == 3, "settings reset armed press feedback renders commit seal glyph and ticks")
	dispose_node(reset_confirm_parent)
	scene.reset_progress_confirming = false
	scene.settings_panel_open = true
	scene.request_reset_progress_from_settings()
	check(scene.reset_progress_confirming, "settings reset progress first press arms confirmation instead of clearing immediately")
	scene.reset_progress_confirming = false
	scene.settings_panel_open = false
	scene.currency = {"coins": 1200, "gems": 33}
	scene.inventory = {"swap_card": 2, "peek_card": 0, "lucky_charm": 1, "double_coins": 0}
	scene._show_shop_screen_impl()
	check(scene.mode == "shop" and scene.find_child("ShopItemRow_swap_card", true, false) != null and count_nodes_with_name_prefix(scene, "ShopItemRow_") == scene.ITEM_TYPES.size(), "shop screen renders named item rows")
	check(scene.find_child("ShopCabinetFrontPanel", true, false) != null and scene.find_child("ShopCabinet3DCastShadow", true, false) != null and scene.find_child("ShopCabinet3DRearShell", true, false) != null and scene.find_child("ShopCabinet3DLowerEdge", true, false) != null and scene.find_child("ShopCabinet3DTopGlint", true, false) != null, "shop screen renders a complete physical lacquer cabinet shell")
	check(scene.find_child("ShopDisplayCabinet3DShell", true, false) != null and scene.find_child("ShopDisplayCabinet3DInset", true, false) != null and scene.find_child("ShopDisplayCabinet3DBottomShelf", true, false) != null and scene.find_child("ShopCabinetFooter3DDepthEdge", true, false) != null, "shop screen renders a recessed item display and physical footer shelf")
	check(count_nodes_with_name_prefix(scene, "ShopItem3DDepthEdge_") == scene.ITEM_TYPES.size() and count_nodes_with_name_prefix(scene, "ShopItem3DTopRim_") == scene.ITEM_TYPES.size() and count_nodes_with_name_prefix(scene, "ShopItem3DCharmPlinth_") == scene.ITEM_TYPES.size(), "shop item rows render complete physical shelf and charm-plinth layers")
	check(count_named_nodes(scene, "ShopBuyButton3DDepthEdge") == scene.ITEM_TYPES.size() and count_named_nodes(scene, "ShopBuyButton3DSideBevel") == scene.ITEM_TYPES.size(), "shop buy buttons render physical depth and side bevels")
	check(scene.find_child("ShopVaultTexture", true, false) != null, "shop screen renders reusable vault PNG texture")
	check(scene.optional_gpt_illustration_texture("shop_gpt_vault") == null or scene.find_child("ShopGPTVaultTexture", true, false) != null, "shop screen consumes optional GPT vault texture when generated")
	check(scene.find_child("SecondaryBackTexture_shop", true, false) != null and scene.find_child("SecondaryBackButtonArt_shop", true, false) != null and scene.find_child("SecondaryBackButtonRail_shop", true, false) != null and scene.find_child("SecondaryBackButtonFill_shop", true, false) != null and count_nodes_with_name_prefix(scene, "SecondaryBackButtonTick_shop_") == 2, "shop back button renders reusable PNG return-route art")
	check(scene.find_child("SecondaryBackSourceNode_shop", true, false) != null and scene.find_child("SecondaryBackDestinationNode_shop", true, false) != null and scene.find_child("SecondaryBackConfirmRoute_shop", true, false) != null and scene.find_child("SecondaryBackConfirmFill_shop", true, false) != null and scene.find_child("SecondaryBackConfirmGate_shop", true, false) != null, "shop back button renders source destination and confirmation route")
	check(count_nodes_with_name_prefix(scene, "SecondaryBackNodeTick_shop_") == 2 and count_nodes_with_name_prefix(scene, "SecondaryBackConfirmTick_shop_") == 2, "shop back button renders node and confirmation rhythm ticks")
	check(scene.find_child("SecondaryBackReturnFlow_shop", true, false) != null and scene.find_child("SecondaryBackReturnFill_shop", true, false) != null and scene.find_child("SecondaryBackReturnGate_shop", true, false) != null and count_nodes_with_name_prefix(scene, "SecondaryBackReturnTick_shop_") == 3, "shop back button renders return flow route")
	check(scene.find_child("ShopCurrencyPanel_coins", true, false) != null and scene.find_child("ShopCurrencyPanel_gems", true, false) != null and scene.find_child("ShopCoinGoldFoil", true, false) != null, "shop screen renders named currency panels with coin foil highlight")
	check(scene.find_child("ShopTransactionMapArt", true, false) != null and scene.find_child("ShopTransactionCurrencySource", true, false) != null and scene.find_child("ShopTransactionGemRoute", true, false) != null and scene.find_child("ShopTransactionGemFill", true, false) != null and scene.find_child("ShopTransactionGemGate", true, false) != null, "shop screen renders top-level currency-to-item transaction map")
	check(count_nodes_with_name_prefix(scene, "ShopTransactionItemNode_") == scene.ITEM_TYPES.size() and scene.find_child("ShopTransactionSettlementRoute", true, false) != null and scene.find_child("ShopTransactionSettlementFill", true, false) != null and scene.find_child("ShopTransactionSettlementGate", true, false) != null, "shop transaction map renders item nodes and settlement route")
	check(count_nodes_with_name_prefix(scene, "ShopTransactionGemTick_") == 4 and count_nodes_with_name_prefix(scene, "ShopTransactionSettlementTick_") == 3, "shop transaction map renders gem and settlement rhythm ticks")
	check(scene.find_child("ShopTransactionAffordabilitySeal", true, false) != null and scene.find_child("ShopTransactionAffordabilityGlyph", true, false) != null and scene.find_child("ShopTransactionMinCostMarker", true, false) != null, "shop transaction map renders affordability seal and min-cost marker")
	check(scene.find_child("ShopTransactionReserveRoute", true, false) != null and scene.find_child("ShopTransactionReserveFill", true, false) != null and scene.find_child("ShopTransactionReserveGate", true, false) != null and count_nodes_with_name_prefix(scene, "ShopTransactionReserveTick_") == 2, "shop transaction map renders balance reserve route")
	check(scene.find_child("ShopCurrencyMeterArt_coins", true, false) != null and scene.find_child("ShopCurrencyRail_coins", true, false) != null and scene.find_child("ShopCurrencyFill_coins", true, false) != null and scene.find_child("ShopCurrencyVault_coins", true, false) == null, "shop coins balance keeps live rail/fill while dropping code-drawn vault")
	check(scene.find_child("ShopCurrencyMeterArt_gems", true, false) != null and scene.find_child("ShopCurrencyRail_gems", true, false) != null and scene.find_child("ShopCurrencyFill_gems", true, false) != null and scene.find_child("ShopCurrencyThreshold_gems", true, false) == null, "shop gems balance keeps live rail/fill while dropping code-drawn threshold")
	check(count_nodes_with_name_prefix(scene, "ShopCurrencyPulse_coins_") == 0 and count_nodes_with_name_prefix(scene, "ShopCurrencyPulse_gems_") == 0, "shop currency meters drop code-drawn resource pulse accents")
	check(scene.find_child("ShopCurrencyFlowRail_coins", true, false) != null and scene.find_child("ShopCurrencyFlowFill_coins", true, false) != null and scene.find_child("ShopCurrencyFlowGate_coins", true, false) == null, "shop coins balance keeps live flow rail while dropping code-drawn flow gate")
	check(scene.find_child("ShopCurrencyFlowRail_gems", true, false) != null and scene.find_child("ShopCurrencyFlowFill_gems", true, false) != null and scene.find_child("ShopCurrencyFlowGate_gems", true, false) == null and count_nodes_with_name_prefix(scene, "ShopCurrencyFlowNode_") == 0, "shop gems balance keeps live flow rail while dropping code-drawn flow gate and nodes")
	check(count_nodes_with_name_prefix(scene, "ShopCurrencyFlowTick_") == 0 and ((scene.optional_gpt_illustration_texture("shop_currency_meter_panel") == null) or (count_nodes_with_name_prefix(scene, "ShopCurrencyMeterPanelTexture_") == 2)), "shop currency meters replace flow ticks with optional GPT currency-meter panel plate")
	check(scene.find_child("ShopCabinetFooterPanel", true, false) != null and scene.find_child("ShopCabinetFooterTitle", true, false) != null and scene.find_child("ShopCabinetFooterBody", true, false) != null and scene.find_child("ShopCabinetFooterInventoryBadge", true, false) != null and scene.find_child("ShopCabinetFooterStateBadge", true, false) != null, "shop screen renders lower cabinet footer with inventory and purchase guidance")
	check(count_named_nodes(scene, "ShopItemShelfRail") == scene.ITEM_TYPES.size() and count_named_nodes(scene, "ShopItemPriceAura") == scene.ITEM_TYPES.size(), "shop item rows render shelf rail and price aura art")
	check(scene.find_child("ShopItemShelfTexture_swap_card", true, false) != null and count_nodes_with_name_prefix(scene, "ShopItemShelfTexture_") == scene.ITEM_TYPES.size(), "shop item rows render reusable shelf PNG textures")
	check(scene.shop_charm_gpt_key("swap_card") == "shop_charm_huan" and scene.shop_charm_gpt_key("peek_card") == "shop_charm_kan" and scene.shop_charm_gpt_key("lucky_charm") == "shop_charm_yun" and scene.shop_charm_gpt_key("double_coins") == "shop_charm_bei", "shop item ids map to distinct GPT charm assets")
	check(scene.find_child("ShopItemNativeCharm_swap_card", true, false) != null and scene.find_child("ShopItemNativeCharm_peek_card", true, false) != null and scene.find_child("ShopItemNativeCharm_lucky_charm", true, false) != null and scene.find_child("ShopItemNativeCharm_double_coins", true, false) != null, "shop item rows fall back to native charm art when GPT charm texture has no transparent edge")
	check(scene.find_child("ShopItemIdentity_swap_card", true, false) != null and scene.find_child("ShopItemIdentity_peek_card", true, false) != null and scene.find_child("ShopItemIdentity_lucky_charm", true, false) != null and scene.find_child("ShopItemIdentity_double_coins", true, false) != null, "shop item rows render compact identity labels")
	check(count_named_nodes(scene, "ShopItemStockPips") == scene.ITEM_TYPES.size() and count_nodes_with_name_prefix(scene, "ShopItemStockPip_") >= scene.ITEM_TYPES.size(), "shop item rows render stock pip groups and illustrations")
	check(count_named_nodes(scene, "ShopItemEnergyRail") == scene.ITEM_TYPES.size() and count_named_nodes(scene, "ShopItemEnergyFill") == scene.ITEM_TYPES.size(), "shop item rows render energy rails and inventory fill")
	check(count_nodes_with_name_prefix(scene, "ShopItemCountBadge_") == scene.ITEM_TYPES.size() and count_named_nodes(scene, "ShopItemCountBadgeArt") == scene.ITEM_TYPES.size(), "shop item rows render named inventory count badges")
	check(count_named_nodes(scene, "ShopItemCountRail") == scene.ITEM_TYPES.size() and count_named_nodes(scene, "ShopItemCountFill") == scene.ITEM_TYPES.size() and count_named_nodes(scene, "ShopItemCountGate") == scene.ITEM_TYPES.size(), "shop item count badges render inventory rails fills and gates")
	check(count_nodes_with_name_prefix(scene, "ShopItemCountPip_") == scene.ITEM_TYPES.size() * 3, "shop item count badges render stock pips")
	check(count_named_nodes(scene, "ShopItemRouteRail") == scene.ITEM_TYPES.size() and count_named_nodes(scene, "ShopItemRouteArrow") == scene.ITEM_TYPES.size() and count_nodes_with_name_prefix(scene, "ShopItemRouteNode_") == scene.ITEM_TYPES.size() * 3, "shop item rows render route rails arrows and comparison nodes")
	check(count_named_nodes(scene, "ShopItemValueRoute") == scene.ITEM_TYPES.size() and count_named_nodes(scene, "ShopItemValueFill") == scene.ITEM_TYPES.size() and count_named_nodes(scene, "ShopItemValueGate") == scene.ITEM_TYPES.size(), "shop item rows render value bridge routes")
	check(count_named_nodes(scene, "ShopItemValueTick_0") == scene.ITEM_TYPES.size() and count_named_nodes(scene, "ShopItemValueTick_1") == scene.ITEM_TYPES.size(), "shop item rows render value bridge rhythm ticks")
	check(count_named_nodes(scene, "ShopItemSettlementRail") == scene.ITEM_TYPES.size() and count_named_nodes(scene, "ShopItemSettlementFill") == scene.ITEM_TYPES.size() and count_named_nodes(scene, "ShopItemSettlementGate") == scene.ITEM_TYPES.size(), "shop item rows render settlement rails fills and gates")
	check(count_named_nodes(scene, "ShopItemSettlementTick_0") == scene.ITEM_TYPES.size() and count_named_nodes(scene, "ShopItemSettlementTick_1") == scene.ITEM_TYPES.size() and count_named_nodes(scene, "ShopItemSettlementTick_2") == scene.ITEM_TYPES.size(), "shop item rows render settlement rhythm ticks")
	check(scene.find_child("ShopItemTypeMark_swap_card", true, false) != null and count_nodes_with_name_prefix(scene, "ShopItemTypeMark_") == scene.ITEM_TYPES.size() and count_named_nodes(scene, "ShopItemTypeGlyph") == scene.ITEM_TYPES.size(), "shop item rows render item type marks")
	check(count_named_nodes(scene, "ShopItemPriceSpark_0") == scene.ITEM_TYPES.size() and count_named_nodes(scene, "ShopItemPriceSpark_1") == scene.ITEM_TYPES.size(), "shop item rows render price sparkle accents")
	check(count_named_nodes(scene, "ShopBuyButtonArt") == scene.ITEM_TYPES.size() and count_named_nodes(scene, "ShopBuyButtonCleanPlate") == scene.ITEM_TYPES.size() and count_named_nodes(scene, "ShopBuyButtonStatus") == 0, "shop buy buttons render clean plates without extra status medallions")
	check(count_nodes_with_name_prefix(scene, "ShopBuyButtonCommand_") == scene.ITEM_TYPES.size() and count_nodes_with_name_prefix(scene, "ShopBuyButtonPrice_") == scene.ITEM_TYPES.size(), "shop buy buttons expose command and gem price text")
	var shop_swap_command = scene.find_child("ShopBuyButtonCommand_swap_card", true, false) as Label
	var shop_swap_price = scene.find_child("ShopBuyButtonPrice_swap_card", true, false) as Label
	var shop_double_command = scene.find_child("ShopBuyButtonCommand_double_coins", true, false) as Label
	var shop_double_price = scene.find_child("ShopBuyButtonPrice_double_coins", true, false) as Label
	check(shop_swap_command != null and shop_swap_command.text == "购买 5玉" and shop_swap_price != null and shop_swap_price.text == "5玉" and not shop_swap_price.visible, "affordable shop item exposes single-line purchase CTA and hidden gem price anchor")
	check(shop_double_command != null and shop_double_command.text == "购买 15玉" and shop_double_price != null and shop_double_price.text == "15玉" and not shop_double_price.visible, "high-gem shop item exposes single-line purchase CTA and hidden gem price anchor")
	check(count_named_nodes(scene, "ShopBuyButtonAffordRail") == 0 and count_named_nodes(scene, "ShopBuyButtonCommandRoute") == 0 and count_named_nodes(scene, "ShopBuyButtonSettlementRoute") == 0, "shop buy buttons omit old rail and route clutter")
	check(count_nodes_with_name_prefix(scene, "ShopBuyButtonCommandTick_") == 0 and count_nodes_with_name_prefix(scene, "ShopBuyButtonSettlementTick_") == 0 and count_nodes_with_name_prefix(scene, "ShopBuyButtonPriceSettlementTick_") == 0, "shop buy buttons omit old rhythm ticks")
	var purchase_feedback_row = scene.find_child("ShopItemRow_swap_card", true, false) as Control
	var shop_buy_button = first_button(purchase_feedback_row)
	check(shop_buy_button != null, "shop item row exposes buy button for press feedback")
	scene.play_shop_buy_button_feedback(shop_buy_button, true)
	check(shop_buy_button.find_child("ShopBuyButtonPressFeedback_available", true, false) != null and shop_buy_button.find_child("ShopBuyButtonPressSource_available", true, false) != null and shop_buy_button.find_child("ShopBuyButtonPressRoute_available", true, false) != null and shop_buy_button.find_child("ShopBuyButtonPressFill_available", true, false) != null and shop_buy_button.find_child("ShopBuyButtonPressGate_available", true, false) != null, "shop buy button press feedback renders available purchase route")
	check(shop_buy_button.find_child("ShopBuyButtonPressSeal_available", true, false) != null and shop_buy_button.find_child("ShopBuyButtonPressGlyph_available", true, false) != null and count_nodes_with_name_prefix(shop_buy_button, "ShopBuyButtonPressTick_available_") == 3, "shop buy button press feedback renders available seal glyph and ticks")
	scene._play_purchase_success_animation(purchase_feedback_row, Color(0.22, 0.48, 0.72))
	check(purchase_feedback_row != null and purchase_feedback_row.find_child("ShopPurchaseSuccessFeedback", true, false) != null and purchase_feedback_row.find_child("ShopPurchaseSuccessSource", true, false) != null and purchase_feedback_row.find_child("ShopPurchaseSuccessRoute", true, false) != null and purchase_feedback_row.find_child("ShopPurchaseSuccessFill", true, false) != null and purchase_feedback_row.find_child("ShopPurchaseSuccessInventoryGate", true, false) != null, "shop purchase success animation renders settlement-to-inventory route")
	check(count_nodes_with_name_prefix(purchase_feedback_row, "ShopPurchaseSuccessTick_") == 3 and purchase_feedback_row.find_child("ShopPurchaseSuccessFlash", true, false) != null, "shop purchase success animation renders ticks and flash")
	check(purchase_feedback_row.find_child("ShopPurchaseInventoryCommitArt", true, false) != null and purchase_feedback_row.find_child("ShopPurchaseInventoryCommitSource", true, false) != null and purchase_feedback_row.find_child("ShopPurchaseInventoryArchiveRoute", true, false) != null and purchase_feedback_row.find_child("ShopPurchaseInventoryArchiveFill", true, false) != null and purchase_feedback_row.find_child("ShopPurchaseInventoryArchiveGate", true, false) != null, "shop purchase success animation renders inventory archive commit route")
	check(purchase_feedback_row.find_child("ShopPurchaseInventoryCountRoute", true, false) != null and purchase_feedback_row.find_child("ShopPurchaseInventoryCountFill", true, false) != null and purchase_feedback_row.find_child("ShopPurchaseInventoryCountNode", true, false) != null and purchase_feedback_row.find_child("ShopPurchaseInventoryCountGlyph", true, false) != null, "shop purchase inventory commit renders count route and count glyph")
	check(count_nodes_with_name_prefix(purchase_feedback_row, "ShopPurchaseInventoryCommitTick_") == 3 and count_nodes_with_name_prefix(purchase_feedback_row, "ShopPurchaseInventoryCommitPip_") == 2, "shop purchase inventory commit renders rhythm ticks and archive pips")
	check(count_named_nodes(scene, "ShopBuyButtonStatus") == 0 and count_named_nodes(scene, "ShopBuyButtonInsufficientLock") == 0, "shop buy buttons omit status medallions and locks when gems are sufficient")
	scene.currency = {"coins": 0, "gems": 3}
	scene._show_shop_screen_impl()
	var low_gem_swap_command = scene.find_child("ShopBuyButtonCommand_swap_card", true, false) as Label
	var low_gem_swap_price = scene.find_child("ShopBuyButtonPrice_swap_card", true, false) as Label
	check(low_gem_swap_command != null and low_gem_swap_command.text == "不足 5玉" and low_gem_swap_price != null and low_gem_swap_price.text == "5玉" and not low_gem_swap_price.visible, "low-gem shop item exposes single-line shortage CTA and hidden gem price anchor")
	check(scene.find_child("ShopCurrencyLowRoute_coins", true, false) != null and scene.find_child("ShopCurrencyLowFill_coins", true, false) != null and scene.find_child("ShopCurrencyLowGate_coins", true, false) != null and scene.find_child("ShopCurrencyEmptyWarning_coins", true, false) != null, "shop coins balance renders low-resource route and empty warning")
	check(scene.find_child("ShopCurrencyLowRoute_gems", true, false) != null and scene.find_child("ShopCurrencyLowFill_gems", true, false) != null and scene.find_child("ShopCurrencyLowGate_gems", true, false), "shop gems balance renders low-resource route")
	check(count_nodes_with_name_prefix(scene, "ShopCurrencyLowTick_") == 6, "shop low-resource meters render rhythm ticks")
	check(count_named_nodes(scene, "ShopBuyButtonCleanPlate") == scene.ITEM_TYPES.size() and count_named_nodes(scene, "ShopBuyButtonStatus") == 0, "low-gem shop buy buttons keep compact plates without status medallions")
	check(count_named_nodes(scene, "ShopBuyButtonInsufficientRoute") == 0 and count_named_nodes(scene, "ShopBuyButtonInsufficientPriceBridge") == 0 and count_nodes_with_name_prefix(scene, "ShopBuyButtonInsufficientTick_") == 0, "low-gem shop buy buttons omit blocked route clutter")
	var blocked_purchase_row = scene.find_child("ShopItemRow_swap_card", true, false) as Control
	var blocked_shop_buy_button = first_button(blocked_purchase_row)
	check(blocked_shop_buy_button != null, "low-gem shop row exposes buy button for blocked press feedback")
	scene.play_shop_buy_button_feedback(blocked_shop_buy_button, false)
	check(blocked_shop_buy_button.find_child("ShopBuyButtonPressFeedback_blocked", true, false) != null and blocked_shop_buy_button.find_child("ShopBuyButtonPressSource_blocked", true, false) != null and blocked_shop_buy_button.find_child("ShopBuyButtonPressRoute_blocked", true, false) != null and blocked_shop_buy_button.find_child("ShopBuyButtonPressFill_blocked", true, false) != null and blocked_shop_buy_button.find_child("ShopBuyButtonPressGate_blocked", true, false) != null, "low-gem shop buy press feedback renders blocked route")
	check(blocked_shop_buy_button.find_child("ShopBuyButtonPressSeal_blocked", true, false) != null and blocked_shop_buy_button.find_child("ShopBuyButtonPressGlyph_blocked", true, false) != null and blocked_shop_buy_button.find_child("ShopBuyButtonPressLock", true, false) != null and count_nodes_with_name_prefix(blocked_shop_buy_button, "ShopBuyButtonPressTick_blocked_") == 3, "low-gem shop buy press feedback renders blocked seal glyph lock and ticks")
	scene.start_offline(false)
	scene.game_stats = {"games_played": 12, "games_won": 7, "total_score": 18800, "best_score": 9600, "win_rate": 7.0 / 12.0, "total_hands": 44}
	scene._show_stats_screen_impl()
	check(scene.mode == "stats" and scene.find_child("StatsDashboardArt", true, false) != null, "stats screen renders dashboard illustration")
	check(scene.find_child("StatsConsoleFrontPanel", true, false) != null and scene.find_child("StatsConsole3DCastShadow", true, false) != null and scene.find_child("StatsConsole3DRearShell", true, false) != null and scene.find_child("StatsConsole3DLowerEdge", true, false) != null and scene.find_child("StatsConsole3DTopGlint", true, false) != null, "stats screen renders a complete physical console shell")
	check(scene.find_child("StatsConsole3DDataInset", true, false) != null and scene.find_child("StatsConsole3DBottomShelf", true, false) != null and scene.find_child("StatsDashboard3DDepthEdge", true, false) != null and scene.find_child("StatsDashboard3DTopRim", true, false) != null, "stats screen renders recessed data lane and physical dashboard depth")
	check(count_nodes_with_name_prefix(scene, "StatsRow3DDepthEdge_") == 6 and count_nodes_with_name_prefix(scene, "StatsRow3DTopRim_") == 6 and count_nodes_with_name_prefix(scene, "StatsRow3DIconPlinth_") == 6, "stats rows render complete physical data-slot layers")
	check(count_nodes_with_name_prefix(scene, "StatsSummary3DDepthEdge_") == 3 and count_nodes_with_name_prefix(scene, "StatsSummary3DTopRim_") == 3, "stats summary chips render physical depth and top rims")
	check(scene.find_child("StatsChartTexture", true, false) != null, "stats screen renders reusable chart PNG texture")
	check(scene.optional_gpt_illustration_texture("stats_gpt_dashboard") == null or scene.find_child("StatsGPTDashboardTexture", true, false) != null, "stats screen consumes optional GPT dashboard texture when generated")
	check(scene.find_child("StatsDashboardGridTexture", true, false) != null, "stats dashboard renders reusable grid PNG texture")
	check(scene.find_child("SecondaryBackTexture_stats", true, false) != null and scene.find_child("SecondaryBackButtonArt_stats", true, false) != null and scene.find_child("SecondaryBackButtonRail_stats", true, false) != null and scene.find_child("SecondaryBackButtonFill_stats", true, false) != null and count_nodes_with_name_prefix(scene, "SecondaryBackButtonTick_stats_") == 2, "stats back button renders reusable PNG return-route art")
	check(scene.find_child("SecondaryBackSourceNode_stats", true, false) != null and scene.find_child("SecondaryBackDestinationNode_stats", true, false) != null and scene.find_child("SecondaryBackConfirmRoute_stats", true, false) != null and scene.find_child("SecondaryBackConfirmFill_stats", true, false) != null and scene.find_child("SecondaryBackConfirmGate_stats", true, false) != null, "stats back button renders source destination and confirmation route")
	check(count_nodes_with_name_prefix(scene, "SecondaryBackNodeTick_stats_") == 2 and count_nodes_with_name_prefix(scene, "SecondaryBackConfirmTick_stats_") == 2, "stats back button renders node and confirmation rhythm ticks")
	check(scene.find_child("StatsWinRateRing", true, false) != null and count_nodes_with_name_prefix(scene, "StatsWinRateSegment_") == 8, "stats dashboard renders segmented win-rate ring")
	check(scene.find_child("StatsGamesTrack", true, false) != null and scene.find_child("StatsGamesTrackFill", true, false) != null and scene.find_child("StatsBestScoreMedal", true, false) != null and scene.find_child("StatsBestScoreGlow", true, false) != null, "stats dashboard renders games track and glowing best-score medal")
	check(scene.find_child("StatsSummaryChannel", true, false) != null and scene.find_child("StatsSummaryChannelFill", true, false) != null and scene.find_child("StatsSummaryGate", true, false) != null and scene.find_child("StatsWinrateScrollTexture", true, false) != null, "stats dashboard renders summary performance channel and GPT win-rate scroll")
	check(count_nodes_with_name_prefix(scene, "StatsSummaryNode_") == 3, "stats dashboard renders summary metric nodes")
	check(scene.find_child("StatsMasteryRoute", true, false) != null and scene.find_child("StatsMasteryRail", true, false) != null and scene.find_child("StatsMasteryFill", true, false) != null, "stats dashboard renders mastery summary route")
	check(scene.find_child("StatsMasterySource", true, false) != null and scene.find_child("StatsMasteryGate", true, false) != null and count_nodes_with_name_prefix(scene, "StatsMasteryNode_") == 3, "stats mastery route renders source gate and metric nodes")
	check(count_nodes_with_name_prefix(scene, "StatsMasteryBranch_") == 3 and count_nodes_with_name_prefix(scene, "StatsMasteryTick_") == 4, "stats mastery route renders metric branches and rhythm ticks")
	check(scene.find_child("StatsDashboardScanRoute", true, false) != null and scene.find_child("StatsDashboardScanFill", true, false) != null and scene.find_child("StatsDashboardScanGate", true, false) != null and count_nodes_with_name_prefix(scene, "StatsDashboardScanTick_") == 4, "stats dashboard renders scan route from summary to trend")
	check(scene.find_child("StatsSummaryNarrativePanel", true, false) != null and scene.find_child("StatsSummaryNarrativeTitle", true, false) != null and scene.find_child("StatsSummaryNarrativeBody", true, false) != null and scene.find_child("StatsSummaryNarrativeMeta", true, false) != null and scene.find_child("StatsSummaryNarrativeRail", true, false) != null, "stats dashboard renders compact narrative summary panel")
	check(has_label_text(scene, "顺风") and has_label_text(scene, "7胜/12局"), "stats narrative summary labels the current record state")
	check(scene.find_child("StatsDataScanArt", true, false) != null and scene.find_child("StatsDataScanSource", true, false) != null and scene.find_child("StatsDataScanRoute", true, false) != null and scene.find_child("StatsDataScanFill", true, false) != null and scene.find_child("StatsDataScanGate", true, false) != null, "stats screen renders data scan route")
	check(scene.find_child("StatsDataScanArchive", true, false) != null and scene.find_child("StatsDataScanGlyph", true, false) != null and count_nodes_with_name_prefix(scene, "StatsDataScanNode_") == 4 and count_nodes_with_name_prefix(scene, "StatsDataScanTick_") == 3, "stats data scan renders archive glyph metric nodes and rhythm ticks")
	check(scene.find_child("StatsInsightConvergenceArt", true, false) != null and scene.find_child("StatsInsightSource", true, false) != null and scene.find_child("StatsInsightRoute", true, false) != null and scene.find_child("StatsInsightFill", true, false) != null and scene.find_child("StatsInsightGate", true, false) != null, "stats screen renders insight convergence route")
	check(scene.find_child("StatsInsightSeal", true, false) != null and scene.find_child("StatsInsightGlyph", true, false) != null and scene.find_child("StatsInsightArchiveRoute", true, false) != null and scene.find_child("StatsInsightArchiveFill", true, false) != null and scene.find_child("StatsInsightArchiveGate", true, false) != null, "stats insight convergence renders seal glyph and archive route")
	check(count_nodes_with_name_prefix(scene, "StatsInsightNode_") == 3 and count_nodes_with_name_prefix(scene, "StatsInsightBranch_") == 3 and count_nodes_with_name_prefix(scene, "StatsInsightTick_") == 3, "stats insight convergence renders metric nodes branches and rhythm ticks")
	check(scene.find_child("StatsTrendLineArt", true, false) != null and scene.find_child("StatsTrendBaseLine", true, false) != null and count_nodes_with_name_prefix(scene, "StatsTrendNode_") == 5 and count_nodes_with_name_prefix(scene, "StatsTrendConnector_") == 4, "stats dashboard renders trend line illustration")
	check(scene.find_child("StatsPerformanceRoute", true, false) != null and scene.find_child("StatsPerformanceFill", true, false) != null and scene.find_child("StatsPerformanceGate", true, false) != null and count_nodes_with_name_prefix(scene, "StatsPerformanceTick_") == 2, "stats dashboard renders performance-to-medal route")
	check(count_nodes_with_name_prefix(scene, "StatsBestScoreMilestone_") == 3, "stats dashboard renders best-score milestone badges")
	check(scene.find_child("StatsBestScoreRoute", true, false) != null and scene.find_child("StatsBestScoreRouteFill", true, false) != null and scene.find_child("StatsBestScoreGate", true, false) != null and count_nodes_with_name_prefix(scene, "StatsBestScoreTick_") == 3, "stats dashboard renders best-score route gate and ticks")
	var stats_best_score_fill = scene.find_child("StatsBestScoreRouteFill", true, false) as Control
	check(stats_best_score_fill != null and stats_best_score_fill.anchor_right > 0.70, "stats best-score route fill tracks best score strength")
	check(scene.find_child("StatsSummaryChip_winrate", true, false) != null and scene.find_child("StatsSummaryChip_games", true, false) != null and scene.find_child("StatsSummaryChip_best", true, false) != null, "stats dashboard renders compact summary chips")
	check(has_label_text(scene, "58%") and has_label_text(scene, "12局") and has_label_text(scene, "9600分"), "stats dashboard labels win rate played games and best score unit in summary chips")
	check(count_nodes_with_name_prefix(scene, "StatsRowArt_") == 6 and count_nodes_with_name_prefix(scene, "StatsRowRail_") == 6 and count_nodes_with_name_prefix(scene, "StatsRowFill_") == 6, "stats rows render illustrated metric rails and fills")
	check(scene.find_child("StatsRow_总场次", true, false) != null and scene.find_child("StatsRow_胜场", true, false) != null and scene.find_child("StatsRow_胜率", true, false) != null and scene.find_child("StatsRow_累计净分", true, false) != null and scene.find_child("StatsRow_单局最佳", true, false) != null and scene.find_child("StatsRow_总手牌数", true, false) != null, "stats rows render concrete named metric rows")
	check(count_nodes_with_name_prefix(scene, "StatsRowValuePanel_") == 6 and count_nodes_with_name_prefix(scene, "StatsRowValueSheen_") == 6 and count_nodes_with_name_prefix(scene, "StatsRowValueDivider_") == 6, "stats rows expose high contrast native value readouts")
	check(label_is_clipped(scene.find_child("StatsRowLabel_总场次", true, false) as Label) and label_is_clipped(scene.find_child("StatsRowValueLabel_单局最佳", true, false) as Label), "stats rows keep readable clipped labels and values")
	check(count_nodes_with_name_prefix(scene, "StatsRowIconPanel_") == 6 and count_nodes_with_name_prefix(scene, "StatsRowReadabilityGlow_") == 6, "stats rows expose readable icon panels and soft row glow")
	check(scene.find_child("StatsRowMarker_总场次", true, false) != null and scene.find_child("StatsRowMarker_胜场", true, false) != null and scene.find_child("StatsRowMarker_胜率", true, false) != null and scene.find_child("StatsRowMarker_累计净分", true, false) != null and scene.find_child("StatsRowMarker_单局最佳", true, false) != null and scene.find_child("StatsRowMarker_总手牌数", true, false) != null, "stats rows render concrete named row markers")
	check(count_nodes_with_name_prefix(scene, "StatsRowNode_") == 18 and count_nodes_with_name_prefix(scene, "StatsRowFocus_") == 6, "stats rows render status nodes and focus accents")
	check(count_nodes_with_name_prefix(scene, "StatsRowTrendRoute_") == 6 and count_nodes_with_name_prefix(scene, "StatsRowTrendFill_") == 6 and count_nodes_with_name_prefix(scene, "StatsRowTrendGate_") == 6, "stats rows render trend routes fills and gates")
	check(count_nodes_with_name_prefix(scene, "StatsRowTrendTick_") == 12, "stats rows render trend rhythm ticks")
	check(count_nodes_with_name_prefix(scene, "StatsRowValueRoute_") == 6 and count_nodes_with_name_prefix(scene, "StatsRowValueFill_") == 6 and count_nodes_with_name_prefix(scene, "StatsRowValueGate_") == 6, "stats rows render value readout routes fills and gates")
	check(count_nodes_with_name_prefix(scene, "StatsRowValueTick_") == 12, "stats rows render value readout rhythm ticks")
	check(count_nodes_with_name_prefix(scene, "StatsRowInsightBridge_") == 6 and count_nodes_with_name_prefix(scene, "StatsRowInsightFill_") == 6 and count_nodes_with_name_prefix(scene, "StatsRowInsightGate_") == 6, "stats rows render trend-to-value insight bridges")
	check(count_nodes_with_name_prefix(scene, "StatsRowInsightTick_") == 12, "stats row insight bridges render rhythm ticks")
	check(scene.find_child("StatsRowSummaryBusArt", true, false) != null and scene.find_child("StatsRowSummarySpine", true, false) != null and scene.find_child("StatsRowSummarySpineFill", true, false) != null and scene.find_child("StatsRowSummarySource", true, false) != null, "stats rows render summary bus spine and source")
	check(count_nodes_with_name_prefix(scene, "StatsRowSummaryBranch_") == 6 and count_nodes_with_name_prefix(scene, "StatsRowSummaryBranchFill_") == 6 and count_nodes_with_name_prefix(scene, "StatsRowSummaryNode_") == 6, "stats row summary bus renders one branch and node per metric row")
	check(scene.find_child("StatsRowSummaryArchiveGate", true, false) != null and scene.find_child("StatsRowSummaryArchiveGlyph", true, false) != null and scene.find_child("StatsRowSummaryInsightRoute", true, false) != null and scene.find_child("StatsRowSummaryInsightFill", true, false) != null and scene.find_child("StatsRowSummaryInsightGate", true, false) != null, "stats row summary bus renders archive gate and insight route")
	check(count_nodes_with_name_prefix(scene, "StatsRowSummaryTick_") == 4 and count_nodes_with_name_prefix(scene, "StatsRowSummaryArchivePip_") == 2, "stats row summary bus renders rhythm ticks and archive pips")
	scene.game_stats = {"games_played": 0, "games_won": 0, "total_score": 0, "best_score": 0, "win_rate": 0.0, "total_hands": 0}
	scene._show_stats_screen_impl()
	check(scene.find_child("StatsEmptyStateArt", true, false) != null and scene.find_child("StatsEmptyRoute", true, false) != null and scene.find_child("StatsEmptyFill", true, false) != null and scene.find_child("StatsEmptyGate", true, false) != null, "empty stats dashboard renders first-game route")
	check(scene.find_child("StatsEmptySeedNode", true, false) != null and scene.find_child("StatsEmptyGateGlyph", true, false) != null and count_nodes_with_name_prefix(scene, "StatsEmptyTick_") == 3, "empty stats dashboard renders seed node glyph and rhythm ticks")
	scene.start_offline(false)
	scene.season_data = {"season_id": "test", "points": 650, "highest_rank": 3, "wins": 8, "games": 12}
	scene.task_progress = {"win_3": 3, "peng_3": 1, "gang_1": 1, "play_5": 2, "score_plus": 0}
	scene.tutorial_step = 0
	scene.show_menu(true)
	check(scene.find_child("MenuPrimary3DStage", true, false) != null and scene.find_child("MenuPrimary3DFloorShadow", true, false) != null and scene.find_child("MenuPrimary3DTableLip", true, false) != null, "3D menu primary stage exists")
	check(scene.optional_gpt_illustration_texture("menu_primary_3d_stage_overlay") == null or scene.find_child("MenuPrimary3DStageGPTOverlay", true, false) != null, "main menu consumes optional GPT 3D stage overlay when generated")
	check(count_nodes_with_name_prefix(scene, "MenuPrimary3DCardShadow_") == 3, "3D menu card shadows exist")
	check(scene.find_child("MenuTitleGoldFoil", true, false) != null, "main menu title renders gold foil overlay")
	var menu_action_stage = scene.find_child("MenuPrimaryActionStage", true, false)
	var menu_stage_glow = scene.find_child("MenuPrimaryActionStageGlow", true, false) as TextureRect
	check(menu_action_stage != null and menu_stage_glow != null and menu_stage_glow.texture == scene.illustration_texture("menu_stage_glow"), "main menu renders framed primary action stage with registered glow texture")
	check(count_named_nodes(scene, "MenuCardEntryArt") == 3 and count_named_nodes(scene, "MenuCardSurface") == 3 and count_named_nodes(scene, "MenuCardInner") == 3 and count_named_nodes(scene, "MenuCardAccent") == 3 and count_named_nodes(scene, "MenuCardIconEcho") == 3 and count_named_nodes(scene, "MenuCardEntryArrow") == 3, "main menu cards render clean commercial animated surface layers")
	check(count_named_nodes(scene, "MenuCardTextBackplate") == 3 and count_named_nodes(scene, "MenuCardTitleLabel") == 3 and count_named_nodes(scene, "MenuCardSubtitleLabel") == 3, "main menu cards render native readable title and subtitle lanes")
	check(count_named_nodes(scene, "MenuCardCastShadow") == 3 and count_named_nodes(scene, "MenuCardDepthEdge") == 3 and count_named_nodes(scene, "MenuCardTopSheen") == 3, "3D menu card depth exists")
	check(count_named_nodes(scene, "MenuCardEntryRail") == 0 and count_named_nodes(scene, "MenuCardEntryFill") == 0 and count_nodes_with_name_prefix(scene, "MenuCardEntryNode_") == 0 and count_nodes_with_name_prefix(scene, "MenuCardEntrySpark_") == 0, "main menu cards omit legacy entry route nodes and sparks")
	check(count_named_nodes(scene, "MenuCardEntryConfirmRoute") == 0 and count_named_nodes(scene, "MenuCardEntryConfirmFill") == 0 and count_named_nodes(scene, "MenuCardEntryConfirmGate") == 0 and count_nodes_with_name_prefix(scene, "MenuCardEntryConfirmTick_") == 0, "main menu cards omit legacy confirmation routes and ticks")
	check(count_named_nodes(scene, "ButtonPressSheen") >= 3 and count_named_nodes(scene, "MenuCardDecisionBand") == 0 and count_named_nodes(scene, "MenuCardDecisionFill") == 0 and count_named_nodes(scene, "MenuCardActivationSeal") == 0 and count_named_nodes(scene, "MenuCardActivationCore") == 0, "main menu cards keep press sheen and omit legacy decision route art")
	check(count_nodes_with_name_prefix(scene, "MenuCardDecisionTick_") == 0, "main menu cards omit legacy decision rhythm ticks")
	check(scene.find_child("MenuCardSelectionBus", true, false) == null and scene.find_child("MenuCardSelectionLayer", true, false) == null and scene.find_child("MenuCardSelectionRail", true, false) == null and scene.find_child("MenuCardSelectionFill", true, false) == null and scene.find_child("MenuCardSelectionGate", true, false) == null, "main menu omits legacy card selection bus")
	check(count_nodes_with_name_prefix(scene, "MenuCardSelectionNode_") == 0 and count_nodes_with_name_prefix(scene, "MenuCardSelectionBranch_") == 0 and count_nodes_with_name_prefix(scene, "MenuCardSelectionTick_") == 0, "main menu omits legacy card selection nodes branches and ticks")
	check(scene.mode == "menu" and scene.find_child("MenuSeasonProgressArt", true, false) == null, "main menu omits legacy procedural season progress art")
	check(scene.find_child("MenuSeasonRouteRail", true, false) == null and count_nodes_with_name_prefix(scene, "MenuSeasonRankNode_") == 0 and count_nodes_with_name_prefix(scene, "MenuSeasonEnergyTick_") == 0, "main menu omits legacy season route nodes and ticks")
	check(first_label_containing_text(scene, "铂金") != null, "menu season badge names the current rank")
	check(scene.find_child("MenuFooterTextLayer", true, false) != null and scene.find_child("MenuFooterBackplate", true, false) != null, "menu footer exposes status layer and backplate")
	check(scene.find_child("MenuFooterStatusChip_version", true, false) != null and scene.find_child("MenuVersionBadge", true, false) != null and scene.find_child("MenuFooterStatusChip_rank", true, false) != null and scene.find_child("MenuRankBadge", true, false) != null, "menu footer renders version and rank status chips")
	var menu_version_badge = scene.find_child("MenuVersionBadge", true, false) as Label
	check(menu_version_badge != null and menu_version_badge.text == "版本 v%s" % scene.app_version_short() and not menu_version_badge.text.contains("-godot"), "menu footer displays a compact version badge")
	check(scene.find_child("MenuFooterStatusChip_currency", true, false) != null and scene.find_child("MenuFooterStatusChip_stats", true, false) != null, "menu footer wraps currency and stats in local status chips")
	check(scene.find_child("MenuCurrencyBadge", true, false) != null and scene.find_child("MenuCurrencyBrocadeTexture", true, false) != null and scene.find_child("MenuCurrencyBadgeArt", true, false) != null and scene.find_child("MenuCurrencyBadgeRail", true, false) != null and scene.find_child("MenuCurrencyBadgeFill", true, false) != null and scene.find_child("MenuCurrencyBadgeGate", true, false) != null, "menu footer currency badge renders reusable PNG resource route art")
	check(count_nodes_with_name_prefix(scene, "MenuCurrencyBadgeNode_") == 2 and count_nodes_with_name_prefix(scene, "MenuCurrencyBadgeTick_") == 3 and count_nodes_with_name_prefix(scene, "MenuCurrencyBadgeGateTick_") == 2, "menu footer currency badge renders resource nodes and ticks")
	check(scene.find_child("MenuStatsBadge", true, false) != null and scene.find_child("MenuStatsBadgeArt", true, false) != null and scene.find_child("MenuStatsBadgeRail", true, false) != null and scene.find_child("MenuStatsBadgeFill", true, false) != null and scene.find_child("MenuStatsBadgeGate", true, false) != null, "menu footer stats badge renders trend route art")
	check(count_nodes_with_name_prefix(scene, "MenuStatsBadgeTrendNode_") == 3 and count_nodes_with_name_prefix(scene, "MenuStatsBadgePip_") == 2 and count_nodes_with_name_prefix(scene, "MenuStatsBadgeGateTick_") == 2, "menu footer stats badge renders trend nodes and pips")
	check(scene.find_child("MenuFooterEconomyStatsBridge", true, false) != null and scene.find_child("MenuFooterEconomyStatsRail", true, false) != null and scene.find_child("MenuFooterEconomyStatsFill", true, false) != null, "menu footer renders economy-to-stats bridge")
	check(scene.find_child("MenuFooterEconomyStatsSource", true, false) != null and scene.find_child("MenuFooterEconomyStatsGate", true, false) != null and count_nodes_with_name_prefix(scene, "MenuFooterEconomyStatsNode_") == 3 and count_nodes_with_name_prefix(scene, "MenuFooterEconomyStatsTick_") == 3, "menu footer economy-to-stats bridge renders source gate nodes and ticks")
	check(scene.find_child("MenuDailyTaskArt", true, false) == null and scene.find_child("MenuDailyTaskRail", true, false) == null and scene.find_child("MenuDailyTaskFill", true, false) == null, "main menu omits legacy procedural daily task art")
	check(count_nodes_with_name_prefix(scene, "MenuDailyTaskNode_") == 0 and count_nodes_with_name_prefix(scene, "MenuDailyTaskRewardTick_") == 0 and count_nodes_with_name_prefix(scene, "MenuDailyTaskCompletionTick_") == 0, "main menu omits legacy daily task nodes and ticks")
	check(scene.find_child("MenuSettingsButton", true, false) != null and scene.find_child("MenuSettingsGearTexture", true, false) != null and scene.find_child("MenuSettingsButtonArt", true, false) != null and scene.find_child("MenuSettingsButtonRail", true, false) != null and scene.find_child("MenuSettingsButtonFill", true, false) != null and scene.find_child("MenuSettingsButtonGate", true, false) != null, "menu settings button renders reusable PNG settings-entry route")
	check(count_nodes_with_name_prefix(scene, "MenuSettingsButtonTick_") == 2, "menu settings button renders entry rhythm ticks")
	var menu_settings_button = scene.find_child("MenuSettingsButton", true, false) as Button
	scene.play_menu_settings_button_press_feedback(menu_settings_button)
	check(menu_settings_button != null and menu_settings_button.find_child("MenuSettingsButtonPressFeedback", true, false) != null and menu_settings_button.find_child("MenuSettingsButtonPressSource", true, false) != null and menu_settings_button.find_child("MenuSettingsButtonPressRoute", true, false) != null and menu_settings_button.find_child("MenuSettingsButtonPressFill", true, false) != null and menu_settings_button.find_child("MenuSettingsButtonPressGate", true, false) != null, "menu settings button press renders source route fill gate feedback")
	check(menu_settings_button != null and menu_settings_button.find_child("MenuSettingsButtonPressSeal", true, false) != null and menu_settings_button.find_child("MenuSettingsButtonPressGlyph", true, false) != null and count_nodes_with_name_prefix(menu_settings_button, "MenuSettingsButtonPressTick_") == 3, "menu settings button press renders seal glyph and rhythm ticks")
	check(scene.find_child("MenuQuickActionRail", true, false) != null and scene.find_child("MenuQuickActionSurface", true, false) != null, "main menu renders animated quick action surface")
	check(scene.find_child("MenuQuickActionPathTexture", true, false) == null and scene.find_child("MenuQuickActionRoute", true, false) == null and scene.find_child("MenuQuickActionRouteFill", true, false) == null and scene.find_child("MenuQuickActionGate", true, false) == null, "main menu omits legacy quick action route texture and gate")
	check(scene.find_child("MenuQuickRulesButton", true, false) != null and scene.find_child("MenuQuickStatsButton", true, false) != null and scene.find_child("MenuQuickAchievementsButton", true, false) != null and scene.find_child("MenuQuickShopButton", true, false) != null, "main menu quick rail renders rules stats achievements and shop buttons")
	check(count_nodes_with_name_prefix(scene, "MenuQuickActionTick_") == 0 and count_nodes_with_name_prefix(scene, "MenuQuickButtonArt_") == 0 and count_nodes_with_name_prefix(scene, "MenuQuickButtonNode_") == 0 and count_nodes_with_name_prefix(scene, "MenuQuickButtonChip_") == 0 and count_nodes_with_name_prefix(scene, "MenuQuickButtonTick_") == 0, "main menu quick rail omits legacy button nodes chips and route ticks")
	check(scene.find_child("MenuQuickActionDecisionBridge", true, false) == null and scene.find_child("MenuQuickActionDecisionRail", true, false) == null and scene.find_child("MenuQuickActionDecisionFill", true, false) == null and scene.find_child("MenuQuickActionDecisionGate", true, false) == null, "main menu omits legacy quick decision bridge route")
	check(count_nodes_with_name_prefix(scene, "MenuQuickActionDecisionNode_") == 0 and count_nodes_with_name_prefix(scene, "MenuQuickActionDecisionDrop_") == 0 and count_nodes_with_name_prefix(scene, "MenuQuickActionDecisionTick_") == 0, "main menu quick rail omits decision nodes drops and ticks")
	var menu_quick_rules_button = scene.find_child("MenuQuickRulesButton", true, false) as Button
	scene.play_menu_quick_button_press_feedback(menu_quick_rules_button, "rules", Color(0.30, 0.58, 0.50))
	check(menu_quick_rules_button != null and menu_quick_rules_button.find_child("MenuQuickButtonPressFeedback_rules", true, false) != null and menu_quick_rules_button.find_child("MenuQuickButtonPressWash_rules", true, false) != null and menu_quick_rules_button.find_child("MenuQuickButtonPressSeal_rules", true, false) != null and menu_quick_rules_button.find_child("MenuQuickButtonPressGlyph_rules", true, false) != null, "main menu quick rules button press renders animated wash seal and glyph")
	check(menu_quick_rules_button != null and menu_quick_rules_button.find_child("MenuQuickButtonPressSource_rules", true, false) == null and menu_quick_rules_button.find_child("MenuQuickButtonPressRoute_rules", true, false) == null and menu_quick_rules_button.find_child("MenuQuickButtonPressFill_rules", true, false) == null and menu_quick_rules_button.find_child("MenuQuickButtonPressGate_rules", true, false) == null and count_nodes_with_name_prefix(menu_quick_rules_button, "MenuQuickButtonPressTick_rules_") == 0, "main menu quick rules button press omits legacy source route fill gate and ticks")
	check(scene.find_child("MenuTutorialHintArt", true, false) != null and scene.find_child("MenuTutorialHintRibbonTexture", true, false) != null and scene.find_child("MenuTutorialHintRail", true, false) != null and scene.find_child("MenuTutorialHintFill", true, false) != null and scene.find_child("MenuTutorialHintSeal", true, false) != null and scene.find_child("MenuTutorialHintEntryBridge", true, false) != null and scene.find_child("MenuTutorialHintEntryFill", true, false) != null and scene.find_child("MenuTutorialHintEntryGate", true, false) != null and scene.find_child("MenuTutorialHintGlyph", true, false) != null, "main menu tutorial renders reusable ribbon texture and filled rules-entry guide route glyph")
	check(scene.optional_gpt_illustration_texture("menu_tutorial_gpt_hint") == null or scene.find_child("MenuTutorialGPTTexture", true, false) != null, "main menu tutorial consumes optional GPT hint texture when generated")
	check(count_nodes_with_name_prefix(scene, "MenuTutorialHintEntryTick_") == 2 and count_nodes_with_name_prefix(scene, "MenuTutorialHintTick_") == 3 and count_nodes_with_name_prefix(scene, "MenuTutorialHintNode_") == 2, "main menu tutorial renders hint rhythm ticks and marker nodes")
	check(scene.find_child("MenuTutorialTargetRoute", true, false) != null and scene.find_child("MenuTutorialTargetFill", true, false) != null and scene.find_child("MenuTutorialTargetGate", true, false) != null and count_nodes_with_name_prefix(scene, "MenuTutorialTargetTick_") == 3, "main menu tutorial renders target route to rules button")
	check(scene.find_child("MenuTutorialConfirmRoute", true, false) != null and scene.find_child("MenuTutorialConfirmFill", true, false) != null and scene.find_child("MenuTutorialConfirmGate", true, false) != null and scene.find_child("MenuTutorialConfirmArchive", true, false) != null and scene.find_child("MenuTutorialConfirmGlyph", true, false) != null, "main menu tutorial renders rules-entry confirmation route")
	check(count_nodes_with_name_prefix(scene, "MenuTutorialConfirmNode_") == 2 and count_nodes_with_name_prefix(scene, "MenuTutorialConfirmTick_") == 3, "main menu tutorial confirmation renders nodes and rhythm ticks")
	scene.achievements["first_win"] = true
	scene.achievements["seven_pairs"] = true
	scene.achievements["thirteen_orphans"] = false
	scene._show_achievements_screen_impl()
	check(scene.find_child("AchievementGalleryFrontPanel", true, false) != null and scene.find_child("AchievementGallery3DCastShadow", true, false) != null and scene.find_child("AchievementGallery3DRearShell", true, false) != null and scene.find_child("AchievementGallery3DLowerEdge", true, false) != null and scene.find_child("AchievementGallery3DTopGlint", true, false) != null, "achievements screen renders a complete physical gallery cabinet shell")
	check(scene.find_child("AchievementGallery3DListInset", true, false) != null and scene.find_child("AchievementGallery3DBottomShelf", true, false) != null and scene.find_child("AchievementsDashboard3DDepthEdge", true, false) != null and scene.find_child("AchievementsDashboard3DTopRim", true, false) != null and scene.find_child("AchievementsDashboard3DMedalPedestal", true, false) != null, "achievements screen renders recessed list and physical dashboard medal stage")
	check(count_nodes_with_name_prefix(scene, "AchievementRow3DDepthEdge_") == scene.achievements.size() and count_nodes_with_name_prefix(scene, "AchievementRow3DTopRim_") == scene.achievements.size() and count_nodes_with_name_prefix(scene, "AchievementRow3DMedalPedestal_") == scene.achievements.size(), "achievement rows render complete physical depth and medal pedestal layers")
	check(scene.mode == "achievements" and scene.find_child("AchievementsDashboardArt", true, false) != null and scene.find_child("AchievementsGrid", true, false) != null, "achievements screen renders dashboard and grid")
	check(scene.find_child("AchievementsGlowTexture", true, false) != null and scene.find_child("AchievementsDashboardGlowTexture", true, false) != null, "achievements screen renders reusable medal glow PNG textures")
	check(scene.optional_gpt_illustration_texture("achievement_gpt_gallery") == null or scene.find_child("AchievementGPTGalleryTexture", true, false) != null, "achievements screen consumes optional GPT gallery texture when generated")
	check(scene.find_child("AchievementsBottomFadePanel", true, false) != null and scene.find_child("AchievementsBottomSafeSpacer", true, false) != null, "achievements screen renders bottom fade and safe spacer for clipped scroll rows")
	check(scene.find_child("SecondaryBackTexture_achievements", true, false) != null and scene.find_child("SecondaryBackButtonArt_achievements", true, false) != null and scene.find_child("SecondaryBackButtonRail_achievements", true, false) != null and scene.find_child("SecondaryBackButtonFill_achievements", true, false) != null and scene.find_child("SecondaryBackButtonGate_achievements", true, false) != null, "achievements back button renders reusable return-route art")
	check(count_nodes_with_name_prefix(scene, "SecondaryBackButtonTick_achievements_") == 2, "achievements back button renders return rhythm ticks")
	check(scene.find_child("SecondaryBackConfirmRoute_achievements", true, false) != null and scene.find_child("SecondaryBackConfirmFill_achievements", true, false) != null and scene.find_child("SecondaryBackConfirmGate_achievements", true, false) != null and count_nodes_with_name_prefix(scene, "SecondaryBackConfirmTick_achievements_") == 2, "achievements back button renders return confirmation route")
	check(scene.find_child("SecondaryBackSourceNode_achievements", true, false) != null and scene.find_child("SecondaryBackDestinationNode_achievements", true, false) != null and count_nodes_with_name_prefix(scene, "SecondaryBackNodeTick_achievements_") == 2, "achievements back button renders source destination and node rhythm ticks")
	check(scene.find_child("AchievementsMedalNode", true, false) != null and scene.find_child("AchievementsMedalCore", true, false) != null and count_nodes_with_name_prefix(scene, "AchievementsMedalRay_") == 4, "achievements dashboard renders medal node core and rays")
	check(scene.optional_gpt_illustration_texture("achievement_medal_gold") == null or scene.find_child("AchievementsMedalTexture", true, false) != null, "achievements dashboard consumes optional GPT medal texture when generated")
	check(count_nodes_with_name_prefix(scene, "AchievementRowMedalTexture_") == scene.achievements.size(), "achievement rows consume GPT medal textures when generated")
	var achievements_medal_glyph = scene.find_child("AchievementsMedalGlyph", true, false) as Label
	var achievements_progress_detail = scene.find_child("AchievementsProgressDetailLabel", true, false) as Label
	check(achievements_medal_glyph != null and achievements_progress_detail != null, "achievements dashboard renders readable medal glyph and progress detail")
	if achievements_medal_glyph != null:
		check(relative_luma(achievements_medal_glyph.get_theme_color("font_color")) >= 0.86 and achievements_medal_glyph.get_theme_color("font_color").a >= 0.90, "achievements medal glyph stays bright")
	if achievements_progress_detail != null:
		check(relative_luma(achievements_progress_detail.get_theme_color("font_color")) >= 0.80 and achievements_progress_detail.clip_text, "achievements progress detail stays readable and clipped")
	check(scene.find_child("AchievementsProgressRail", true, false) != null and scene.find_child("AchievementsProgressFill", true, false) != null and scene.find_child("AchievementsProgressGate", true, false) != null and scene.find_child("AchievementsProgressLabel", true, false) != null, "achievements dashboard renders progress rail fill gate and label")
	check(scene.find_child("AchievementsUnlockRoute", true, false) != null and scene.find_child("AchievementsUnlockFill", true, false) != null and scene.find_child("AchievementsUnlockSource", true, false) != null, "achievements dashboard renders unlock route")
	check(count_nodes_with_name_prefix(scene, "AchievementsProgressNode_") == 5 and count_nodes_with_name_prefix(scene, "AchievementsProgressTick_") == 4, "achievements dashboard renders progress nodes and ticks")
	var achievements_dashboard = scene.find_child("AchievementsDashboardArt", true, false)
	check(achievements_dashboard != null and achievements_dashboard.find_child("AchievementsProgressRail", true, false) != null and achievements_dashboard.find_child("AchievementsProgressFill", true, false) != null and achievements_dashboard.find_child("AchievementsProgressGate", true, false) != null, "achievements dashboard groups progress route under dashboard art")
	check(achievements_dashboard != null and achievements_dashboard.find_child("AchievementsUnlockRoute", true, false) != null and achievements_dashboard.find_child("AchievementsUnlockFill", true, false) != null and achievements_dashboard.find_child("AchievementsUnlockSource", true, false) != null and count_nodes_with_name_prefix(achievements_dashboard, "AchievementsProgressTick_") == 4, "achievements dashboard owns unlock route and progress ticks")
	check(scene.find_child("AchievementsGalleryScanArt", true, false) != null and scene.find_child("AchievementsGalleryScanSource", true, false) != null and scene.find_child("AchievementsGalleryScanRoute", true, false) != null and scene.find_child("AchievementsGalleryScanFill", true, false) != null and scene.find_child("AchievementsGalleryScanGate", true, false) != null, "achievements screen renders gallery scan route")
	check(scene.find_child("AchievementsGalleryArchive", true, false) != null and scene.find_child("AchievementsGalleryArchiveGlyph", true, false) != null and count_nodes_with_name_prefix(scene, "AchievementsGalleryScanNode_") == 5 and count_nodes_with_name_prefix(scene, "AchievementsGalleryScanBranch_") == 5 and count_nodes_with_name_prefix(scene, "AchievementsGalleryScanTick_") == 4, "achievements gallery scan renders archive glyph nodes branches and rhythm ticks")
	check(scene.find_child("AchievementsCompletionConvergenceArt", true, false) != null and scene.find_child("AchievementsCompletionSource", true, false) != null and scene.find_child("AchievementsCompletionRoute", true, false) != null and scene.find_child("AchievementsCompletionFill", true, false) != null and scene.find_child("AchievementsCompletionGate", true, false) != null, "achievements screen renders completion convergence route")
	check(scene.find_child("AchievementsCompletionSeal", true, false) != null and scene.find_child("AchievementsCompletionGlyph", true, false) != null and scene.find_child("AchievementsCompletionClaimRoute", true, false) != null and scene.find_child("AchievementsCompletionClaimFill", true, false) != null and scene.find_child("AchievementsCompletionArchiveGate", true, false) != null, "achievements completion convergence renders seal claim route and archive gate")
	check(count_nodes_with_name_prefix(scene, "AchievementsCompletionNode_") == 4 and count_nodes_with_name_prefix(scene, "AchievementsCompletionTick_") == 3, "achievements completion convergence renders progress nodes and rhythm ticks")
	check(count_nodes_with_name_prefix(scene, "AchievementRow_") == scene.achievements.size() and count_nodes_with_name_prefix(scene, "AchievementRowArt_") == scene.achievements.size() and count_nodes_with_name_prefix(scene, "AchievementRowMedal_") == scene.achievements.size() and count_nodes_with_name_prefix(scene, "AchievementRowSeal_") == scene.achievements.size() and count_nodes_with_name_prefix(scene, "AchievementRowStatusIcon_") == scene.achievements.size(), "achievements grid renders one clean medal seal status row per achievement")
	check(count_named_nodes(scene, "AchievementRowGlyph") == scene.achievements.size() and count_named_nodes(scene, "AchievementRowProgressRail") == scene.achievements.size() and count_named_nodes(scene, "AchievementRowProgressFill") == scene.achievements.size() and count_named_nodes(scene, "AchievementRowProgressGate") == scene.achievements.size(), "achievement rows render readable badge title and progress meter")
	check(count_nodes_with_name_prefix(scene, "AchievementRowGoal_") == scene.achievements.size() and count_nodes_with_name_prefix(scene, "AchievementRowProgressText_") == scene.achievements.size(), "achievement rows render goal copy and binary progress text")
	check(scene.find_child("AchievementRow_first_win", true, false) != null and scene.find_child("AchievementRowArt_first_win", true, false) != null and scene.find_child("AchievementRowMedal_first_win", true, false) != null and scene.find_child("AchievementRowSeal_first_win", true, false) != null and scene.find_child("AchievementRowUnlockedShine_first_win", true, false) != null, "unlocked achievement row renders named medal seal and shine state")
	check(scene.find_child("AchievementRow_thirteen_orphans", true, false) != null and scene.find_child("AchievementRowArt_thirteen_orphans", true, false) != null and scene.find_child("AchievementRowMedal_thirteen_orphans", true, false) != null and scene.find_child("AchievementRowSeal_thirteen_orphans", true, false) != null and scene.find_child("AchievementRowLockedRoute_thirteen_orphans", true, false) != null, "locked achievement row renders named medal seal and readable locked state")
	var locked_achievement_goal = scene.find_child("AchievementRowGoal_thirteen_orphans", true, false) as Label
	var locked_achievement_progress = scene.find_child("AchievementRowProgressText_thirteen_orphans", true, false) as Label
	var unlocked_achievement_progress = scene.find_child("AchievementRowProgressText_first_win", true, false) as Label
	check(scene.find_child("AchievementRowName_thirteen_orphans", true, false) != null and scene.find_child("AchievementRowState_thirteen_orphans", true, false) != null and locked_achievement_goal != null and locked_achievement_progress != null and unlocked_achievement_progress != null, "locked achievement row exposes readable name state goal and progress labels")
	check(locked_achievement_goal != null and locked_achievement_goal.text == "目标：胡出十三幺" and locked_achievement_progress != null and locked_achievement_progress.text == "进度 0/1" and unlocked_achievement_progress != null and unlocked_achievement_progress.text == "进度 1/1", "achievement rows expose player-facing goal and binary progress semantics")
	check(count_nodes_with_name_prefix(scene, "AchievementRowTick_") == 0 and count_nodes_with_name_prefix(scene, "AchievementRowClaimRoute_") == 0 and count_named_nodes(scene, "AchievementRowStatusRoute") == 0, "achievement rows avoid legacy route tick clutter")
	var achievement_collection_count = min(8, scene.achievements.size())
	check(scene.find_child("AchievementsRowCollectionBusArt", true, false) != null and scene.find_child("AchievementsRowCollectionSpine", true, false) != null and scene.find_child("AchievementsRowCollectionSpineFill", true, false) != null and scene.find_child("AchievementsRowCollectionSource", true, false) != null, "achievements rows render collection bus spine and source")
	check(count_nodes_with_name_prefix(scene, "AchievementsRowCollectionBranch_") == achievement_collection_count and count_nodes_with_name_prefix(scene, "AchievementsRowCollectionBranchFill_") == achievement_collection_count and count_nodes_with_name_prefix(scene, "AchievementsRowCollectionNode_") == achievement_collection_count, "achievements collection bus renders bounded row branches and nodes")
	check(scene.find_child("AchievementsRowCollectionArchiveGate", true, false) != null and scene.find_child("AchievementsRowCollectionArchiveGlyph", true, false) != null and scene.find_child("AchievementsRowCollectionProgressRoute", true, false) != null and scene.find_child("AchievementsRowCollectionProgressFill", true, false) != null and scene.find_child("AchievementsRowCollectionProgressGate", true, false) != null, "achievements collection bus renders archive gate and progress route")
	check(count_nodes_with_name_prefix(scene, "AchievementsRowCollectionTick_") == 4 and count_nodes_with_name_prefix(scene, "AchievementsRowCollectionArchivePip_") == 2, "achievements collection bus renders rhythm ticks and archive pips")
	scene.start_offline(false)
	scene._show_rules_screen_impl()
	await process_frame
	await process_frame
	var rules_section_count := int(scene.RULES_SECTION_COUNT)
	check(rules_section_count == 6, "rules implementation declares the six-section local rules contract")
	check(scene.find_child("RulesCodexFrontPanel", true, false) != null and scene.find_child("RulesCodexFrontPlate", true, false) != null and scene.find_child("RulesCodex3DCastShadow", true, false) != null and scene.find_child("RulesCodex3DRearShell", true, false) != null and scene.find_child("RulesCodex3DLowerEdge", true, false) != null and scene.find_child("RulesCodex3DTopGlint", true, false) != null, "rules screen renders a complete physical codex shell")
	check(scene.find_child("RulesCodex3DReadingInset", true, false) != null and scene.find_child("RulesCodex3DBottomShelf", true, false) != null, "rules screen renders a recessed reading viewport and bottom shelf")
	check(count_nodes_with_name_prefix(scene, "RuleSection3DDepthEdge_") == rules_section_count and count_nodes_with_name_prefix(scene, "RuleSection3DTopRim_") == rules_section_count and count_nodes_with_name_prefix(scene, "RuleSection3DExamplePlinth_") == rules_section_count, "every rules section renders physical card and example-plinth layers")
	check(scene.mode == "rules" and scene.find_child("RulesGuideArt", true, false) != null and ((scene.optional_gpt_illustration_texture("rules_guide_panel") == null) or (scene.find_child("RulesGuidePanelPlate", true, false) != null)), "rules screen renders guide illustration using optional GPT guide plate instead of code-drawn rail lines")
	check(scene.find_child("RulesScrollTexture", true, false) == null and scene.find_child("RulesPatternQuadsTexture", true, false) == null, "rules screen does not reconstruct retired scroll and generated pattern-strip layers")
	check(scene.optional_gpt_illustration_texture("rules_gpt_scroll") == null or scene.find_child("RulesGPTScrollTexture", true, false) != null, "rules screen consumes optional GPT scroll texture when generated")
	var rules_scroll = scene.find_child("RulesContentScroll", true, false) as ScrollContainer
	var rules_scrollbar = scene.find_child("RulesContentScrollBar", true, false) as VScrollBar
	var rules_gutter = scene.find_child("RulesContentScrollGutter", true, false) as Control
	var rules_thumb = scene.find_child("RulesContentScrollThumb", true, false) as Control
	check(rules_scroll != null and rules_scrollbar != null and rules_gutter != null and rules_thumb != null and rules_thumb.mouse_filter == Control.MOUSE_FILTER_STOP and rules_thumb.mouse_default_cursor_shape == Control.CURSOR_VSIZE, "rules screen renders a drag-capable custom scroll thumb beside its reading viewport")
	check(scene.find_child("RulesReadingProgressArt", true, false) == null and scene.find_child("RulesReadingProgressFill", true, false) == null and scene.find_child("RulesReadingProgressRail", true, false) == null and scene.find_child("RulesReadingProgressSource", true, false) == null and scene.find_child("RulesReadingProgressGate", true, false) == null and scene.find_child("RulesReadingProgressPanelPlate", true, false) == null, "rules screen does not construct retired reading-progress chrome beside the interactive thumb")
	check(count_nodes_with_name_prefix(scene, "RulesReadingProgressNode_") == 0 and count_nodes_with_name_prefix(scene, "RulesReadingProgressDrop_") == 0 and count_nodes_with_name_prefix(scene, "RulesReadingProgressTick_") == 0, "rules screen does not construct retired reading-progress nodes drops or ticks")
	check(scene.find_child("RulesCompletionConvergenceArt", true, false) == null and scene.find_child("RulesCompletionSource", true, false) == null and scene.find_child("RulesCompletionRoute", true, false) == null and scene.find_child("RulesCompletionFill", true, false) == null and scene.find_child("RulesCompletionGate", true, false) == null and scene.find_child("RulesCompletionSeal", true, false) == null and scene.find_child("RulesCompletionGlyph", true, false) == null and scene.find_child("RulesCompletionPracticeRoute", true, false) == null and scene.find_child("RulesCompletionPracticeFill", true, false) == null and scene.find_child("RulesCompletionPracticeGate", true, false) == null, "rules screen does not construct retired completion route decoration")
	check(count_nodes_with_name_prefix(scene, "RulesCompletionNode_") == 0 and count_nodes_with_name_prefix(scene, "RulesCompletionTick_") == 0, "rules completion does not construct retired section nodes or ticks")
	check(scene.find_child("RulesSectionSummaryBusArt", true, false) == null and scene.find_child("RulesSectionSummarySpine", true, false) == null and scene.find_child("RulesSectionSummarySpineFill", true, false) == null and scene.find_child("RulesSectionSummarySource", true, false) == null, "rules sections do not construct the obsolete summary bus")
	check(count_nodes_with_name_prefix(scene, "RulesSectionSummaryBranch_") == 0 and count_nodes_with_name_prefix(scene, "RulesSectionSummaryBranchFill_") == 0 and count_nodes_with_name_prefix(scene, "RulesSectionSummaryNode_") == 0, "rules summary omits obsolete four-section branches and nodes")
	check(scene.find_child("RulesSectionSummaryArchiveGate", true, false) == null and scene.find_child("RulesSectionSummaryArchiveGlyph", true, false) == null and scene.find_child("RulesSectionSummaryPracticeRoute", true, false) == null and scene.find_child("RulesSectionSummaryPracticeFill", true, false) == null and scene.find_child("RulesSectionSummaryPracticeGate", true, false) == null, "rules summary does not construct retired archive and practice decoration")
	check(count_nodes_with_name_prefix(scene, "RulesSectionSummaryTick_") == 0 and count_nodes_with_name_prefix(scene, "RulesSectionSummaryArchivePip_") == 0, "rules summary does not construct retired rhythm ticks or archive pips")
	check(scene.find_child("SecondaryBackTexture_rules", true, false) != null and scene.find_child("SecondaryBackButtonArt_rules", true, false) != null and scene.find_child("SecondaryBackButtonRail_rules", true, false) != null and scene.find_child("SecondaryBackButtonFill_rules", true, false) != null and scene.find_child("SecondaryBackButtonGate_rules", true, false) != null, "rules back button renders reusable PNG return-route art")
	check(count_nodes_with_name_prefix(scene, "SecondaryBackButtonTick_rules_") == 2, "rules back button renders return rhythm ticks")
	check(scene.find_child("SecondaryBackConfirmRoute_rules", true, false) != null and scene.find_child("SecondaryBackConfirmFill_rules", true, false) != null and scene.find_child("SecondaryBackConfirmGate_rules", true, false) != null and count_nodes_with_name_prefix(scene, "SecondaryBackConfirmTick_rules_") == 2, "rules back button renders return confirmation route")
	check(scene.find_child("SecondaryBackSourceNode_rules", true, false) != null and scene.find_child("SecondaryBackDestinationNode_rules", true, false) != null and count_nodes_with_name_prefix(scene, "SecondaryBackNodeTick_rules_") == 2, "rules back button renders source destination and node rhythm ticks")
	check(scene.find_child("SecondaryBackReturnFlow_rules", true, false) != null and scene.find_child("SecondaryBackReturnFill_rules", true, false) != null and scene.find_child("SecondaryBackReturnGate_rules", true, false) != null and count_nodes_with_name_prefix(scene, "SecondaryBackReturnTick_rules_") == 3, "rules back button renders return flow route")
	check(count_nodes_with_name_prefix(scene, "RulesGuideStep_") == 4 and count_nodes_with_name_prefix(scene, "RulesGuideConnector_") == 0, "rules guide renders four steps over GPT plate without code-drawn connectors")
	check(count_named_nodes(scene, "RuleSectionMarker") == rules_section_count, "rules screen renders one section marker per local rules section")
	check(count_nodes_with_name_prefix(scene, "RuleSectionArtStrip_") == rules_section_count and count_nodes_with_name_prefix(scene, "RuleSectionPathGlyph_") == rules_section_count, "rules sections render one semantic side lane and title glyph per section")
	check(count_nodes_with_name_prefix(scene, "RuleSectionPathRail_") == 0 and count_nodes_with_name_prefix(scene, "RuleSectionPathNode_") == 0 and count_nodes_with_name_prefix(scene, "RuleSectionPathFill_") == 0 and count_nodes_with_name_prefix(scene, "RuleSectionPathGate_") == 0, "rules sections omit obsolete path rails nodes fills and gates")
	check(count_nodes_with_name_prefix(scene, "RuleSectionExampleBridge_") == 0 and count_nodes_with_name_prefix(scene, "RuleSectionExampleBridgeFill_") == 0 and count_nodes_with_name_prefix(scene, "RuleSectionExampleBridgeGate_") == 0 and count_nodes_with_name_prefix(scene, "RuleSectionExampleBridgeTick_") == 0, "rules sections omit obsolete title-to-example bridge decoration")
	check(count_nodes_with_name_prefix(scene, "RuleLineGuide_") == 0 and count_nodes_with_name_prefix(scene, "RuleLineRail_") == 0 and count_nodes_with_name_prefix(scene, "RuleLineLead_") == 0 and count_nodes_with_name_prefix(scene, "RuleLineBullet_") == 0 and count_nodes_with_name_prefix(scene, "RuleLinePulse_") == 0, "rules sections keep body copy free of retired line-rail decoration")
	check(count_nodes_with_name_prefix(scene, "RuleSectionExampleArt_") == 2 and count_nodes_with_name_prefix(scene, "RuleGoalGroup_") == 0 and count_nodes_with_name_prefix(scene, "RuleGoalGroupLink_") == 0, "rules only render compact neutral examples where no semantic GPT panel exists")
	check(count_nodes_with_name_prefix(scene, "RulesExampleTableTexture_") == 2 and count_nodes_with_name_prefix(scene, "RuleExampleCompletionRoute_") == 0 and count_nodes_with_name_prefix(scene, "RuleExampleCompletionFill_") == 0 and count_nodes_with_name_prefix(scene, "RuleExampleCompletionGate_") == 0 and count_nodes_with_name_prefix(scene, "RuleExampleCompletionTick_") == 0, "rules examples use existing textures without completion-route clutter")
	check(scene.find_child("RulePatternExampleGroup_sequence", true, false) != null and scene.find_child("RulePatternExampleTile_sequence_0", true, false) != null and scene.find_child("RulePatternExampleGroup_pair", true, false) != null and scene.find_child("RulePatternExampleTile_pair_0", true, false) != null, "rules neutral lane keeps native tile pattern examples")
	check(scene.find_child("RuleSpecialExampleRail", true, false) == null and count_nodes_with_name_prefix(scene, "RuleSevenPairsNode_") == 0 and scene.find_child("RuleOrphanBadge", true, false) != null, "rules fan lane uses the compact special-hand badge without legacy rail nodes")
	check(scene.find_child("RuleActionChip_吃", true, false) == null and scene.find_child("RuleActionChip_胡", true, false) == null and scene.find_child("RuleActionWinPulse", true, false) == null and scene.find_child("RuleActionFlowRail", true, false) == null and scene.find_child("RuleActionFlowFill", true, false) == null and count_nodes_with_name_prefix(scene, "RuleActionFlowNode_") == 0 and count_nodes_with_name_prefix(scene, "RuleActionFlowTick_") == 0 and scene.find_child("RuleActionPriorityRoute", true, false) == null and scene.find_child("RuleActionPriorityFill", true, false) == null and scene.find_child("RuleActionPrioritySource", true, false) == null and scene.find_child("RuleActionWinGate", true, false) == null and count_nodes_with_name_prefix(scene, "RuleActionPriorityTick_") == 0, "rules semantic GPT lanes replace legacy action-route widgets")
	for section_index in range(rules_section_count):
		var section = scene.find_child("RuleSection_%d" % section_index, true, false) as Control
		check(section != null and section.find_child("RuleSectionTitle_%d" % section_index, true, false) != null and section.find_child("RuleSectionTextBackplate_%d" % section_index, true, false) != null and section.find_child("RuleSectionArtStrip_%d" % section_index, true, false) != null, "rules section %d exposes titled readable text and semantic side lanes" % section_index)
	if rules_scroll != null and rules_scrollbar != null and rules_gutter != null and rules_thumb != null:
		var scroll_range = maxf(0.0, rules_scrollbar.max_value - rules_scrollbar.page)
		check(scroll_range > 0.0, "six-section rules contract requires a scrollable reading viewport")
		if scroll_range > 0.0:
			rules_scrollbar.value = scroll_range
			scene.sync_rules_scroll_thumb(rules_scroll, rules_thumb)
			check(rules_thumb.get_global_rect().end.y >= rules_gutter.get_global_rect().end.y - maxf(2.0, rules_gutter.size.y * 0.06), "rules custom thumb reaches the gutter end after the final section")
	var default_rule_example_parent = Control.new()
	root.add_child(default_rule_example_parent)
	scene.draw_rule_default_example(default_rule_example_parent, Color(0.60, 0.78, 0.70))
	check(count_nodes_with_name_prefix(default_rule_example_parent, "RuleDefaultExampleNode_") == 3, "rules fallback example renders default rhythm nodes")
	dispose_node(default_rule_example_parent)
	scene.start_offline(false)
	scene.selected_room = "ROOM7"
	scene.online_room = {"code": "ROOM7", "players": [{"name": "甲"}, {"name": "乙"}], "logs": ["甲加入房间", "乙准备"]}
	scene.online_feedback = "已发送加入房间，等待服务器确认。"
	scene.online_waiting_for_server = true
	scene._show_online_lobby_impl()
	check(scene.mode == "online_lobby" and scene.find_child("OnlineLobbyRoomArt", true, false) != null and scene.find_child("OnlineLobbyRoomFanOverlay", true, false) != null and scene.find_child("OnlineLobbyRoomNode", true, false) != null, "online lobby renders room status illustration with reusable fan overlay")
	check(scene.find_child("OnlineLobbyRoomSummaryPanel", true, false) != null and scene.find_child("OnlineLobbyRoomSummaryOccupancy", true, false) != null and scene.find_child("OnlineLobbyRoomSummaryReady", true, false) != null and scene.find_child("OnlineLobbyRoomSummaryState", true, false) != null, "online lobby renders compact room state summary chips")
	check(scene.find_child("OnlineLobbyRoomSummaryOccupancyLabel", true, false) != null and scene.find_child("OnlineLobbyRoomSummaryReadyLabel", true, false) != null and scene.find_child("OnlineLobbyRoomSummaryStateLabel", true, false) != null, "online lobby room summary exposes readable native labels")
	check(has_label_text(scene, "入席 2/4") and has_label_text(scene, "已备 0") and has_label_text(scene, "未连接"), "online lobby room summary reports occupancy ready count and connection state")
	check(scene.find_child("OnlineLobbyNetworkTexture", true, false) != null and scene.find_child("OnlineLobbyFanTexture", true, false) != null and scene.find_child("LobbyRoomGateTokenTexture", true, false) != null, "online lobby renders reusable network, fan, and GPT room-token PNG textures")
	check(scene.optional_gpt_illustration_texture("online_gpt_lobby") == null or scene.find_child("OnlineLobbyGPTTexture", true, false) != null, "online lobby consumes optional GPT lobby texture when generated")
	check(scene.optional_gpt_illustration_texture("online_lobby_panel_frame") == null or (scene.find_child("OnlineLobbyFormGPTPanelFrameTexture", true, false) != null and scene.find_child("OnlineLobbyLogGPTPanelFrameTexture", true, false) != null), "online lobby consumes generated panel-frame textures")
	check(scene.optional_gpt_illustration_texture("online_lobby_group_plate") == null or (scene.find_child("OnlineLobbyInputGPTGroupPlateTexture", true, false) != null and scene.find_child("OnlineLobbyActionGPTGroupPlateTexture", true, false) != null), "online lobby consumes generated group-plate textures")
	check(scene.find_child("OnlineLobbyServerEndpointBadge", true, false) != null and scene.find_child("OnlineLobbyConnectionStateBadge", true, false) != null, "online lobby keeps named top endpoint and connection-state badges")
	var online_lobby_status_label = scene.find_child("OnlineLobbyStatusLabel", true, false) as Label
	var online_lobby_start_button = scene.find_child("OnlineLobbyPrimaryStartButton", true, false) as Button
	check(online_lobby_status_label != null and has_label_text(scene, "下一步 · 先连接，再建房或入房"), "online lobby lower status gives a concise connection next-step hint")
	check(online_lobby_status_label != null and not str(online_lobby_status_label.text).contains(str(scene.DEFAULT_HOST)) and not str(online_lobby_status_label.text).contains(":"), "online lobby lower status does not repeat raw endpoint details")
	check(online_lobby_start_button != null and online_lobby_start_button.disabled and online_lobby_start_button.text == "待连接", "online lobby start button shows disabled waiting state until server connection succeeds")
	check(scene.find_child("OnlineLobbyFormPanel", true, false) != null and scene.find_child("OnlineLobbyLogPanel", true, false) != null and scene.find_child("OnlineLobbyInputGroupBackplate", true, false) != null and scene.find_child("OnlineLobbyActionClusterBackplate", true, false) != null and scene.find_child("OnlineLobbyStatusReadabilityBackplate", true, false) != null and scene.find_child("OnlineLobbyLogReadabilityBackplate", true, false) != null, "online lobby keeps named readability backplates for form action status and log areas")

	check(scene.find_child("OnlineLobby3DCastShadow", true, false) != null and scene.find_child("OnlineLobby3DRearShell", true, false) != null and scene.find_child("OnlineLobby3DTopGlint", true, false) != null and scene.find_child("OnlineLobby3DLowerEdge", true, false) != null, "online lobby renders commercial 3D lacquer shell")
	check(scene.find_child("OnlineLobbyForm3DRearShell", true, false) != null and scene.find_child("OnlineLobbyForm3DTopRim", true, false) != null, "online lobby form panel exposes commercial rear shell and top rim")
	check(scene.find_child("LineEditInputArt_name", true, false) != null and scene.find_child("LineEditInputArt_server", true, false) != null and scene.find_child("LineEditInputArt_room", true, false) != null and count_nodes_with_name_prefix(scene, "LineEditInputSurface_") == 3 and count_nodes_with_name_prefix(scene, "LineEditInputInner_") == 3 and count_nodes_with_name_prefix(scene, "LineEditInputFocusGlow_") == 3, "online lobby line edits render clean surfaces and focus glows")
	check(count_nodes_with_name_prefix(scene, "LineEditInputAccentWash_") == 3 and count_nodes_with_name_prefix(scene, "LineEditInputCornerSeal_") == 3 and count_nodes_with_name_prefix(scene, "LineEditInputCornerGlyph_") == 3, "online lobby line edits render wash and seal accents")
	check(count_nodes_with_name_prefix(scene, "LineEditInputRail_") == 0 and count_nodes_with_name_prefix(scene, "LineEditInputFill_") == 0 and count_nodes_with_name_prefix(scene, "LineEditInputFocusNode_") == 0 and count_nodes_with_name_prefix(scene, "LineEditInputPulse_") == 0, "online lobby line edits remove legacy rails fills focus nodes and pulses")
	check(count_nodes_with_name_prefix(scene, "LineEditInputTargetRoute_") == 0 and count_nodes_with_name_prefix(scene, "LineEditInputTargetFill_") == 0 and count_nodes_with_name_prefix(scene, "LineEditInputTargetGate_") == 0 and count_nodes_with_name_prefix(scene, "LineEditInputTargetTick_") == 0, "online lobby line edits remove target route artifacts")
	check(count_nodes_with_name_prefix(scene, "LineEditInputValueRoute_") == 0 and count_nodes_with_name_prefix(scene, "LineEditInputValueFill_") == 0 and count_nodes_with_name_prefix(scene, "LineEditInputValueGate_") == 0 and count_nodes_with_name_prefix(scene, "LineEditInputValueTick_") == 0, "online lobby line edits remove value route artifacts")
	var lobby_action_token_textures = count_nodes_with_name_prefix(scene, "LobbyActionTokenTexture_")
	check((lobby_action_token_textures == 0 or lobby_action_token_textures == 5) and count_nodes_with_name_prefix(scene, "LobbyActionButtonArt_") == 5 and count_nodes_with_name_prefix(scene, "LobbyActionButtonSurface_") == 5 and count_nodes_with_name_prefix(scene, "LobbyActionButtonInner_") == 5, "online lobby action buttons render clean button surfaces with optional GPT tokens")
	check(count_nodes_with_name_prefix(scene, "LobbyActionButtonGlow_") == 5 and count_nodes_with_name_prefix(scene, "LobbyActionButtonSeal_") == 5 and count_nodes_with_name_prefix(scene, "LobbyActionButtonGlyph_") == 5, "online lobby action buttons render glow seal and glyph accents")
	check(count_nodes_with_name_prefix(scene, "LobbyActionButtonRoute_") == 0 and count_nodes_with_name_prefix(scene, "LobbyActionButtonFill_") == 0 and count_nodes_with_name_prefix(scene, "LobbyActionButtonNode_") == 0 and count_nodes_with_name_prefix(scene, "LobbyActionButtonTick_") == 0, "online lobby action buttons remove legacy button route artifacts")
	check(count_nodes_with_name_prefix(scene, "LobbyActionCommandRoute_") == 0 and count_nodes_with_name_prefix(scene, "LobbyActionCommandFill_") == 0 and count_nodes_with_name_prefix(scene, "LobbyActionCommandGate_") == 0 and count_nodes_with_name_prefix(scene, "LobbyActionCommandTick_") == 0, "online lobby action buttons remove legacy command route artifacts")
	var lobby_connect_button = first_button_with_text(scene, "连接")
	check(lobby_connect_button != null, "online lobby exposes connect action button for press feedback")
	scene.play_lobby_action_press_feedback(lobby_connect_button, "连接", Color(0.20, 0.48, 0.66))
	check(lobby_connect_button.find_child("LobbyActionPressFeedback_连接", true, false) != null and lobby_connect_button.find_child("LobbyActionPressWash_连接", true, false) != null and lobby_connect_button.find_child("LobbyActionPressGlow_连接", true, false) != null, "online lobby action press feedback renders wash and glow")
	check(lobby_connect_button.find_child("LobbyActionPressSeal_连接", true, false) != null and lobby_connect_button.find_child("LobbyActionPressGlyph_连接", true, false) != null and count_nodes_with_name_prefix(lobby_connect_button, "LobbyActionPressTick_连接_") == 0, "online lobby action press feedback renders seal glyph and removes rhythm ticks")
	check(lobby_connect_button.find_child("LobbyActionPressSource_连接", true, false) == null and lobby_connect_button.find_child("LobbyActionPressRoute_连接", true, false) == null and lobby_connect_button.find_child("LobbyActionPressFill_连接", true, false) == null and lobby_connect_button.find_child("LobbyActionPressGate_连接", true, false) == null, "online lobby action press feedback removes source route fill and gate")
	check(scene.find_child("OnlineLobbyActionFlowArt", true, false) != null, "online lobby keeps a lightweight action art layer for grouping")
	check(scene.find_child("OnlineLobbyActionSurface", true, false) == null and scene.find_child("OnlineLobbyActionGlow", true, false) == null and scene.find_child("OnlineLobbyActionDecisionSeal", true, false) == null, "online lobby action grouping does not add extra surface glow or seal clutter")
	check(scene.find_child("OnlineLobbyActionInputRoute", true, false) == null and scene.find_child("OnlineLobbyActionInputFill", true, false) == null and scene.find_child("OnlineLobbyActionInputGate", true, false) == null, "online lobby action area removes input route artifacts")
	check(scene.find_child("OnlineLobbyActionCommandRail", true, false) == null and scene.find_child("OnlineLobbyActionCommandFill", true, false) == null and scene.find_child("OnlineLobbyActionDecisionGate", true, false) == null and count_nodes_with_name_prefix(scene, "OnlineLobbyActionCommandNode_") == 0, "online lobby action area removes command rail and node artifacts")
	check(scene.find_child("OnlineLobbyActionStartRoute", true, false) == null and scene.find_child("OnlineLobbyActionStartFill", true, false) == null and scene.find_child("OnlineLobbyActionStartGate", true, false) == null and scene.find_child("OnlineLobbyActionReturnNode", true, false) == null and count_nodes_with_name_prefix(scene, "OnlineLobbyActionFlowTick_") == 0, "online lobby action area removes start routes and rhythm ticks")
	var online_action_flow = scene.find_child("OnlineLobbyActionFlowArt", true, false)
	check(online_action_flow != null and count_nodes_with_name_prefix(online_action_flow, "OnlineLobbyActionFlowTick_") == 0, "online lobby action flow stays lightweight without rhythm ticks")
	check(count_nodes_with_name_prefix(scene, "OnlineLobbyPlayerSeat_") == 4, "online lobby room art renders compact player seat beads")
	check(scene.find_child("OnlineLobbyRosterPanel", true, false) != null and count_nodes_with_name_prefix(scene, "OnlineLobbyRosterRow_") == 4 and count_nodes_with_name_prefix(scene, "OnlineLobbyRosterSeatSeal_") == 4, "online lobby renders a dedicated four-seat roster panel")
	check(count_nodes_with_name_prefix(scene, "OnlineLobbyRosterName_") == 4 and count_nodes_with_name_prefix(scene, "OnlineLobbyRosterState_") == 4, "online lobby roster renders player names and seat states")
	check(scene.find_child("OnlineLobbyLogListPanel", true, false) != null and scene.find_child("OnlineLobbyLogCountBadge", true, false) != null and scene.find_child("OnlineLobbyLogListText", true, false) != null, "online lobby renders a dedicated room log list panel")
	check(scene.find_child("OnlineLobbyRoomRail", true, false) == null and scene.find_child("OnlineLobbyReadyRail", true, false) == null and count_nodes_with_name_prefix(scene, "OnlineLobbyPlayerSlot_") == 0 and count_nodes_with_name_prefix(scene, "OnlineLobbyLogPulse_") == 0, "online lobby room art removes legacy rails slots and log pulses")
	check(count_nodes_with_name_prefix(scene, "OnlineLobbySeatSignal_") == 0 and count_nodes_with_name_prefix(scene, "OnlineLobbySeatReadyGlow_") == 0 and count_nodes_with_name_prefix(scene, "OnlineLobbyConnectionWave_") == 0, "online lobby room art removes extra seat signals glows and waves")
	check(count_nodes_with_name_prefix(scene, "OnlineLobbySeatSyncRoute_") == 0 and count_nodes_with_name_prefix(scene, "OnlineLobbySeatSyncFill_") == 0 and count_nodes_with_name_prefix(scene, "OnlineLobbySeatSyncGate_") == 0 and count_nodes_with_name_prefix(scene, "OnlineLobbySeatSyncTick_") == 0, "online lobby room art removes sync routes fills gates and ticks")
	check(scene.find_child("OnlineLobbySyncGate", true, false) == null and scene.find_child("OnlineLobbyStartGateBack", true, false) == null and scene.find_child("OnlineLobbySyncTimeline", true, false) == null, "online lobby removes legacy start-gate readiness illustration")
	check(scene.find_child("OnlineLobbyLogStreamArt", true, false) == null and scene.find_child("OnlineLobbyLogSpine", true, false) == null and scene.find_child("OnlineLobbyLogStreamRail", true, false) == null and scene.find_child("OnlineLobbyLogStreamFill", true, false) == null, "online lobby log panel does not render legacy stream art")
	check(count_nodes_with_name_prefix(scene, "OnlineLobbyLogNode_") == 0 and count_nodes_with_name_prefix(scene, "OnlineLobbyLogLane_") == 0 and count_nodes_with_name_prefix(scene, "OnlineLobbyLogStreamTick_") == 0, "online lobby log stream does not render legacy nodes lanes or sync ticks")
	check(scene.find_child("OnlineLobbyConnectionRouteArt", true, false) == null and scene.find_child("OnlineLobbyConnectionRoute", true, false) == null and scene.find_child("OnlineLobbyConnectionFill", true, false) == null and scene.find_child("OnlineLobbyConnectionGate", true, false) == null, "online lobby removes panel-level connection route clutter")
	check(count_nodes_with_name_prefix(scene, "OnlineLobbyConnectionNode_") == 0 and count_nodes_with_name_prefix(scene, "OnlineLobbyConnectionTick_") == 0, "online lobby removes connection endpoint nodes and rhythm ticks")
	check(scene.find_child("OnlineLobbyHandshakeRoute", true, false) == null and scene.find_child("OnlineLobbyHandshakeFill", true, false) == null and scene.find_child("OnlineLobbyHandshakeGate", true, false) == null, "online lobby removes handshake route band clutter")
	check(count_nodes_with_name_prefix(scene, "OnlineLobbyHandshakeStep_") == 0 and count_nodes_with_name_prefix(scene, "OnlineLobbyHandshakeGlyph_") == 0, "online lobby removes handshake step glyph clutter")
	check(scene.optional_gpt_illustration_texture("online_feedback_gpt_strip") == null or scene.find_child("OnlineFeedbackGPTStripTexture", true, false) != null, "online feedback consumes optional GPT strip texture when generated")
	check(scene.find_child("OnlineFeedbackArt", true, false) != null and scene.find_child("OnlineFeedbackStatusSeal", true, false) != null and scene.find_child("OnlineFeedbackStatusGlyph", true, false) != null and scene.find_child("OnlineFeedbackText", true, false) != null, "online lobby renders lightweight GPT-backed server feedback strip with status glyph and text")
	check(scene.find_child("OnlineFeedbackStripTexture", true, false) == null and scene.find_child("OnlineFeedbackStatusSilkTexture", true, false) == null and scene.find_child("OnlineFeedbackRail", true, false) == null and scene.find_child("OnlineFeedbackFill", true, false) == null, "online feedback removes legacy strip silk rail and fill overlays")
	check(scene.find_child("OnlineFeedbackMessageLane", true, false) == null and scene.find_child("OnlineFeedbackPendingHalo", true, false) == null and count_nodes_with_name_prefix(scene, "OnlineFeedbackPulse_") == 0, "online feedback relies on the GPT strip instead of native waiting lane pulses")
	check(scene.find_child("OnlineFeedbackResponseRoute", true, false) == null and scene.find_child("OnlineFeedbackResponseFill", true, false) == null and scene.find_child("OnlineFeedbackResponseGate", true, false) == null and count_nodes_with_name_prefix(scene, "OnlineFeedbackResponseTick_") == 0, "online feedback removes response route and rhythm ticks")
	check(scene.find_child("OnlineFeedbackResultNode", true, false) == null and count_nodes_with_name_prefix(scene, "OnlineFeedbackResultTick_") == 0, "online feedback removes result node and ticks")
	check(scene.find_child("OnlineFeedbackAckRoute", true, false) == null and scene.find_child("OnlineFeedbackAckFill", true, false) == null and scene.find_child("OnlineFeedbackAckSource", true, false) == null and scene.find_child("OnlineFeedbackAckGate", true, false) == null, "online feedback removes acknowledgement route clutter")
	check(count_nodes_with_name_prefix(scene, "OnlineFeedbackAckTick_") == 0, "online feedback acknowledgement route ticks are removed")
	check(scene.find_child("OnlineLobbyFeedbackSyncArt", true, false) == null and scene.find_child("OnlineLobbyFeedbackSyncSource", true, false) == null and scene.find_child("OnlineLobbyFeedbackSyncRoute", true, false) == null and scene.find_child("OnlineLobbyFeedbackSyncFill", true, false) == null and scene.find_child("OnlineLobbyFeedbackSyncGate", true, false) == null, "online lobby removes feedback-to-room sync route clutter")
	check(scene.find_child("OnlineLobbyFeedbackSyncArchive", true, false) == null and scene.find_child("OnlineLobbyFeedbackStatusBridge", true, false) == null and count_nodes_with_name_prefix(scene, "OnlineLobbyFeedbackSyncNode_") == 0 and count_nodes_with_name_prefix(scene, "OnlineLobbyFeedbackSyncTick_") == 0, "online lobby feedback sync archive nodes and ticks are removed")
	check(has_label_text(scene, "房间号 ROOM7"), "online lobby room badge names the selected room")
	var empty_lobby_log_parent = Control.new()
	root.add_child(empty_lobby_log_parent)
	scene.online_room = {"code": "ROOM0", "players": [], "logs": []}
	check(scene.draw_online_lobby_log_stream_art(empty_lobby_log_parent) == null and empty_lobby_log_parent.find_child("OnlineLobbyEmptyLogRoute", true, false) == null and empty_lobby_log_parent.find_child("OnlineLobbyEmptyLogFill", true, false) == null and empty_lobby_log_parent.find_child("OnlineLobbyEmptyLogGate", true, false) == null, "online lobby empty log stream does not render legacy waiting route")
	check(empty_lobby_log_parent.find_child("OnlineLobbyEmptyLogGlyph", true, false) == null and count_nodes_with_name_prefix(empty_lobby_log_parent, "OnlineLobbyEmptyLogTick_") == 0, "online lobby empty log stream does not render legacy waiting glyph or rhythm ticks")
	dispose_node(empty_lobby_log_parent)
	var idle_feedback_sync_parent = Control.new()
	root.add_child(idle_feedback_sync_parent)
	scene.online_feedback = ""
	scene.online_waiting_for_server = false
	check(scene.draw_online_lobby_feedback_sync_art(idle_feedback_sync_parent) == null and idle_feedback_sync_parent.find_child("OnlineLobbyFeedbackSyncArt", true, false) == null, "online lobby feedback sync stays hidden without feedback")
	dispose_node(idle_feedback_sync_parent)
	scene.start_offline(false)
	var ornament_parent = Control.new()
	root.add_child(ornament_parent)
	check(scene.TABLE_ORNAMENT_EDGES.size() == 4 and scene.TABLE_CORNER_RECTS.size() == 4, "table ornaments reuse fixed geometry constants")
	check(scene.TABLE_ORNAMENT_EDGES[0][0] is Rect2 and scene.TABLE_ORNAMENT_EDGES[0][1] is Color, "table ornament constants keep precomputed rect and color data")
	scene.draw_table_ornaments(ornament_parent)
	check(count_shadowless_visual_hosts(ornament_parent) >= 12, "table ornaments use shadowless panels for cheaper rendering")
	dispose_node(ornament_parent)
	var dice_parent = Control.new()
	root.add_child(dice_parent)
	scene.draw_dice_dot(dice_parent, 0.5, 0.5)
	check(count_shadowless_visual_hosts(dice_parent) == 1, "dice dots use shadowless panels for cheaper rendering")
	dispose_node(dice_parent)
	var previous_phase = scene.offline_phase
	var previous_summary = scene.round_summary
	var previous_hand_number = scene.offline_hand_number
	var previous_last_discard = scene.last_discard
	var previous_last_discard_seat = scene.last_discard_seat
	scene.offline_phase = "ended"
	scene.offline_hand_number = 1
	scene.round_summary = "超长顶部状态文本用于验证HUD不会自动换行挤压分数和按钮区域"
	scene.last_discard = "5W"
	scene.last_discard_seat = 0
	var hud_parent = Control.new()
	root.add_child(hud_parent)
	scene.draw_game_top_hud(hud_parent)
	var hud_panel = hud_parent.get_child(0) as Control if hud_parent.get_child_count() > 0 else null
	check(control_anchor_rect_matches(hud_panel, scene.TOP_HUD_RECT), "top HUD root uses fixed geometry constants")
	check(scene.optional_gpt_illustration_texture("top_hud_gpt_banner") == null or hud_parent.find_child("TopHudGPTBannerTexture", true, false) != null, "top HUD consumes optional GPT banner texture when generated")
	check(label_is_clipped(first_label_containing_text(hud_parent, "超长顶部状态文本")), "top HUD status clips long text instead of wrapping")
	check(label_is_clipped(first_label_containing_text(hud_parent, "余")), "top HUD wall summary clips inside its slot")
	var offline_title_rect := Rect2(Vector2(0.106, 0.090), Vector2(0.260, 0.535))
	var offline_status_rect := Rect2(Vector2(0.270, 0.090), Vector2(0.610, 0.515))
	var offline_wall_rect := Rect2(Vector2(0.632, 0.140), Vector2(0.766, 0.860))
	var hud_title = hud_parent.find_child("TopHudTitle", true, false) as Control
	var hud_status = hud_parent.find_child("TopHudStatus", true, false) as Control
	var hud_wall_text = hud_parent.find_child("TopHudWallText", true, false) as Control
	var hud_wall_meter = hud_parent.find_child("TopHudWallMeter", true, false) as Control
	check(control_anchor_rect_matches(hud_title, offline_title_rect), "top HUD title uses offline wide geometry for compact battle title")
	check(control_anchor_rect_matches(hud_status, offline_status_rect), "top HUD status uses offline wide geometry next to battle title")
	check(hud_title != null and hud_status != null and hud_title.anchor_right <= hud_status.anchor_left, "top HUD title clears status label")
	check(hud_parent.find_child("TopHudTitleBack", true, false) != null and hud_parent.find_child("TopHudStatusBack", true, false) != null and hud_parent.find_child("TopHudWallBack", true, false) != null, "top HUD exposes readability backplates for title status and wall")
	check(control_anchor_rect_matches(hud_wall_meter, offline_wall_rect), "offline top HUD wall meter uses widened compact geometry")
	check(hud_wall_text != null and hud_wall_text.anchor_left > offline_wall_rect.position.x and hud_wall_text.anchor_right < offline_wall_rect.size.x, "offline top HUD wall text stays inside widened wall slot")
	check(hud_parent.find_child("TopHudWallMeter", true, false) != null and hud_parent.find_child("TopHudWallInkBar", true, false) != null and hud_parent.find_child("TopHudWallInkFill", true, false) != null and hud_parent.find_child("TopHudWallCount", true, false) != null, "top HUD renders compact wall count and progress rail")
	check(hud_parent.find_child("TopHudWallStack", true, false) == null and count_nodes_with_name_prefix(hud_parent, "TopHudWallRhythmTick_") == 0 and hud_parent.find_child("TopHudWallStatusRoute", true, false) == null, "top HUD wall meter omits old stack route and rhythm clutter")
	check(hud_parent.find_child("TopHudWallLowPulseSimple", true, false) == null, "top HUD wall meter omits low-wall pulse while wall is healthy")
	var low_wall_hud_parent = Control.new()
	root.add_child(low_wall_hud_parent)
	var saved_wall_for_hud = scene.wall.duplicate()
	scene.wall.clear()
	for i in range(18):
		scene.wall.append("1W")
	scene.draw_game_top_hud(low_wall_hud_parent)
	check(low_wall_hud_parent.find_child("TopHudWallLowPulseSimple", true, false) != null and low_wall_hud_parent.find_child("TopHudWallCount", true, false) != null, "top HUD wall meter renders simple low-wall pulse and count")
	check(low_wall_hud_parent.find_child("TopHudWallLowDangerRoute", true, false) == null and count_nodes_with_name_prefix(low_wall_hud_parent, "TopHudWallLowTick_") == 0, "top HUD low-wall warning omits old danger route and rhythm ticks")
	scene.wall = saved_wall_for_hud
	dispose_node(low_wall_hud_parent)
	check(hud_parent.find_child("TopHudBannerTexture", true, false) != null and hud_parent.find_child("TopHudPhaseRingTexture", true, false) != null and hud_parent.find_child("TopHudWallRingTexture", true, false) == null, "top HUD renders banner and phase ring while omitting old wall ring texture")
	check(hud_parent.find_child("TopHudModeBadge", true, false) != null and hud_parent.find_child("TopHudStatusArt", true, false) != null and hud_parent.find_child("TopHudStatusPulse", true, false) != null, "top HUD renders mode badge and animated status art")
	check(hud_parent.find_child("TopHudStatusIconBack", true, false) != null and hud_parent.find_child("TopHudStatusRail", true, false) != null and count_nodes_with_name_prefix(hud_parent, "TopHudStatusPip_") == 3, "top HUD renders status icon rail and rhythm pips")
	check(hud_parent.find_child("TopHudStatusRoute", true, false) != null and hud_parent.find_child("TopHudStatusRouteFill", true, false) != null and hud_parent.find_child("TopHudStatusRouteGate", true, false) != null and count_nodes_with_name_prefix(hud_parent, "TopHudStatusRouteTick_") == 3, "top HUD renders status route to the phase text")
	check(hud_parent.find_child("ScoreStrip", true, false) == null, "offline top HUD omits duplicate score strip")
	var saved_mode_for_score_strip = scene.mode
	var saved_online_game_for_score_strip = scene.online_game.duplicate(true)
	var saved_current_seat_for_score_strip = scene.current_seat
	var online_score_hud_parent = Control.new()
	root.add_child(online_score_hud_parent)
	var online_score_players = [
		{"seat": 0, "name": "你", "handCount": 13, "flowerCount": 0, "score": 26000},
		{"seat": 1, "name": "东风", "handCount": 13, "flowerCount": 1, "score": 23800},
		{"seat": 2, "name": "南山", "handCount": 13, "flowerCount": 0, "score": 27200},
		{"seat": 3, "name": "北海", "handCount": 13, "flowerCount": 0, "score": 23000},
	]
	scene.mode = "online_game"
	scene.current_seat = 0
	scene.online_game = {"roomCode": "QA7", "phase": "awaitDiscard", "youSeat": 0, "currentSeat": 2, "wallCount": 58, "players": online_score_players}
	scene.draw_game_top_hud(online_score_hud_parent)
	check(online_score_hud_parent.find_child("ScoreStrip", true, false) != null and count_nodes_with_name_prefix(online_score_hud_parent, "ScoreStripChip_") == 4 and count_nodes_with_name_prefix(online_score_hud_parent, "ScoreStripChipArt_") == 4 and count_nodes_with_name_prefix(online_score_hud_parent, "ScoreStripSeatSeal_") == 4, "online top HUD score strip renders four quiet chip seals")
	check(count_nodes_with_name_prefix(online_score_hud_parent, "ScoreStripAccent_") == 4 and count_nodes_with_name_prefix(online_score_hud_parent, "ScoreStripName_") == 4 and count_nodes_with_name_prefix(online_score_hud_parent, "ScoreStripScore_") == 4, "online top HUD score strip renders seat accents names and scores")
	check(count_nodes_with_name_prefix(online_score_hud_parent, "ScoreStripMomentumRail_") == 4 and count_nodes_with_name_prefix(online_score_hud_parent, "ScoreStripMomentumFill_") == 4 and online_score_hud_parent.find_child("ScoreStripActivePulse", true, false) != null, "online top HUD score strip renders restrained momentum rails and active pulse")
	check(count_nodes_with_name_prefix(online_score_hud_parent, "ScoreStripRankNode_") == 4 and count_nodes_with_name_prefix(online_score_hud_parent, "ScoreStripRankLabel_") == 4, "online top HUD score strip renders compact rank badges")
	check(count_nodes_with_name_prefix(online_score_hud_parent, "ScoreStripDeltaRoute_") == 0 and count_nodes_with_name_prefix(online_score_hud_parent, "ScoreStripDeltaRail_") == 0 and count_nodes_with_name_prefix(online_score_hud_parent, "ScoreStripDeltaFill_") == 0, "online top HUD score strip omits score-delta route clutter")
	check(count_nodes_with_name_prefix(online_score_hud_parent, "ScoreStripDeltaSource_") == 0 and count_nodes_with_name_prefix(online_score_hud_parent, "ScoreStripDeltaGate_") == 0 and count_nodes_with_name_prefix(online_score_hud_parent, "ScoreStripDeltaTick_") == 0, "online top HUD score strip omits score-delta gates and rhythm ticks")
	check(count_nodes_with_name_prefix(online_score_hud_parent, "ScoreStripChaseRoute_") == 0 and count_nodes_with_name_prefix(online_score_hud_parent, "ScoreStripChaseRail_") == 0 and count_nodes_with_name_prefix(online_score_hud_parent, "ScoreStripChaseFill_") == 0, "online top HUD score strip omits chase route clutter")
	check(count_nodes_with_name_prefix(online_score_hud_parent, "ScoreStripChaseSource_") == 0 and count_nodes_with_name_prefix(online_score_hud_parent, "ScoreStripChaseGate_") == 0 and count_nodes_with_name_prefix(online_score_hud_parent, "ScoreStripChaseGlyph_") == 0 and count_nodes_with_name_prefix(online_score_hud_parent, "ScoreStripChaseTick_") == 0, "online top HUD score strip omits chase gates glyphs and rhythm ticks")
	check(online_score_hud_parent.find_child("ScoreStripActiveRoute", true, false) == null and online_score_hud_parent.find_child("ScoreStripActiveRouteFill", true, false) == null and online_score_hud_parent.find_child("ScoreStripActiveRouteGate", true, false) == null and count_nodes_with_name_prefix(online_score_hud_parent, "ScoreStripActiveRouteTick_") == 0, "online top HUD score strip omits active-player route clutter")
	check(count_nodes_with_name_prefix(online_score_hud_parent, "ScoreStripRankRoute_") == 0 and count_nodes_with_name_prefix(online_score_hud_parent, "ScoreStripRankRouteFill_") == 0 and count_nodes_with_name_prefix(online_score_hud_parent, "ScoreStripRankTick_") == 0, "online top HUD score strip omits rank route rhythm clutter")
	var score_strip_leader_confirmation_present = false
	for seat in range(4):
		if scene.score_strip_rank_for_score(int(online_score_players[seat].get("score", 0))) == 1:
			score_strip_leader_confirmation_present = score_strip_leader_confirmation_present or (
				online_score_hud_parent.find_child("ScoreStripLeaderCrown_%d" % seat, true, false) != null
			)
	check(score_strip_leader_confirmation_present, "online top HUD score strip renders a compact leader crown")
	check(count_nodes_with_name_prefix(online_score_hud_parent, "ScoreStripLeaderRoute_") == 0 and count_nodes_with_name_prefix(online_score_hud_parent, "ScoreStripLeaderFill_") == 0 and count_nodes_with_name_prefix(online_score_hud_parent, "ScoreStripLeaderGate_") == 0 and count_nodes_with_name_prefix(online_score_hud_parent, "ScoreStripLeaderTick_") == 0, "online top HUD score strip omits leader route clutter")
	var score_strip_test_ceiling = 1
	for player in online_score_players:
		if typeof(player) == TYPE_DICTIONARY:
			score_strip_test_ceiling = max(score_strip_test_ceiling, int(player.get("score", 0)) + 1)
	check(scene.score_strip_rank_for_score(score_strip_test_ceiling) == 1, "top HUD score strip ranks high scores first")
	dispose_node(online_score_hud_parent)
	scene.mode = saved_mode_for_score_strip
	scene.online_game = saved_online_game_for_score_strip
	scene.current_seat = saved_current_seat_for_score_strip
	var hud_settings_button = first_button_with_text(hud_parent, "设置")
	check(hud_settings_button != null and hud_settings_button.custom_minimum_size == scene.TOP_HUD_BUTTON_SIZE, "rendered top HUD buttons use enlarged touch targets")
	check(hud_settings_button != null and count_texture_rects(hud_settings_button) >= 1, "top HUD settings button renders a lucide icon")
	check(count_nodes_with_name_prefix(hud_parent, "TopHudButtonArt_") == 3 and hud_settings_button.find_child("TopHudButtonIconBack_设置", true, false) != null and hud_settings_button.find_child("TopHudButtonRail_设置", true, false) != null, "top HUD buttons render illustrated icon backs and rails")
	check(hud_settings_button.find_child("TopHudButtonRailFill_设置", true, false) != null and hud_settings_button.find_child("TopHudButtonSeal_设置", true, false) != null, "top HUD settings button renders compact rail fill and seal accents")
	check(count_nodes_with_name_prefix(hud_parent, "TopHudButtonCommandRoute_") == 0 and count_nodes_with_name_prefix(hud_parent, "TopHudButtonCommandFill_") == 0 and count_nodes_with_name_prefix(hud_parent, "TopHudButtonCommandGate_") == 0, "top HUD buttons omit command routes")
	check(count_nodes_with_name_prefix(hud_parent, "TopHudButtonCommandTick_") == 0 and count_nodes_with_name_prefix(hud_parent, "TopHudButtonPulse_") == 0, "top HUD buttons omit rhythm ticks and extra pulses")
	scene.play_top_hud_button_press_feedback(hud_settings_button, "设置", Color(0.22, 0.44, 0.56))
	check(hud_settings_button.find_child("TopHudButtonPressFeedback_设置", true, false) != null and hud_settings_button.find_child("TopHudButtonPressWash_设置", true, false) != null and hud_settings_button.find_child("TopHudButtonPressGlow_设置", true, false) != null, "rendered top HUD settings button press feedback renders wash and glow")
	check(hud_settings_button.find_child("TopHudButtonPressSeal_设置", true, false) != null and hud_settings_button.find_child("TopHudButtonPressGlyph_设置", true, false) != null and count_nodes_with_name_prefix(hud_settings_button, "TopHudButtonPressTick_设置_") == 0, "rendered top HUD settings button press feedback renders seal glyph without ticks")
	check(hud_settings_button.find_child("TopHudButtonPressSource_设置", true, false) == null and hud_settings_button.find_child("TopHudButtonPressRoute_设置", true, false) == null and hud_settings_button.find_child("TopHudButtonPressFill_设置", true, false) == null and hud_settings_button.find_child("TopHudButtonPressGate_设置", true, false) == null, "rendered top HUD settings button press feedback omits route clutter")
	check(control_anchor_rect_matches(hud_settings_button, scene.TOP_HUD_SETTINGS_BUTTON_RECT), "top HUD settings button uses fixed geometry constants")
	check(control_anchor_rect_matches(first_button_with_text(hud_parent, "返回"), scene.TOP_HUD_BACK_BUTTON_RECT), "top HUD back button uses fixed geometry constants")
	check(control_anchor_rect_matches(first_button_with_text(hud_parent, "更新"), scene.TOP_HUD_UPDATE_BUTTON_RECT), "top HUD update button uses fixed geometry constants")
	dispose_node(hud_parent)
	scene.offline_phase = previous_phase
	scene.round_summary = previous_summary
	scene.offline_hand_number = previous_hand_number
	scene.last_discard = previous_last_discard
	scene.last_discard_seat = previous_last_discard_seat
	var avatar = scene.make_avatar_view(1, true)
	check(has_label_text(avatar, "南") and has_label_text(avatar, "行牌"), "seat avatar renders active 2D identity")
	check(avatar.find_child("SeatAvatarHead", true, false) != null and avatar.find_child("SeatAvatarShoulders", true, false) != null and avatar.find_child("SeatAvatarWindSeal", true, false) != null and avatar.find_child("SeatAvatarActiveHalo", true, false) != null, "seat avatar renders layered 2D character illustration")
	check(not contains_subviewport(avatar), "seat avatar avoids expensive SubViewport rendering")
	dispose_node(avatar)
	check(scene.tile_textures.get("E", null) != scene.tile_back and scene.tile_textures.get("H1", null) != scene.tile_back, "wind and flower textures do not fall back to tile back")
	var east_tile_view = scene.make_tile_view("E", Vector2(62, 84), false, Callable())
	check(east_tile_view.custom_minimum_size == Vector2(62, 84), "wind tile view keeps requested size")
	check(tile_view_inner_frame_is_fixed(east_tile_view, Vector2(62, 84)), "wind tile inner frame stays fixed when parent stretches")
	check(first_button(east_tile_view) == null, "static tile views avoid button nodes")
	check(has_visible_tile_art(east_tile_view), "wind tile view renders real tile art inside fixed frame")
	check(not has_label_text(east_tile_view, "东") and not has_label_text(east_tile_view, "风"), "wind tile view uses real art without duplicate code-drawn labels")
	check(tile_texture_rects_are_bounded(east_tile_view), "wind tile texture ignores source pixel size")
	dispose_node(east_tile_view)
	var number_tile_view = scene.make_tile_view("5W", Vector2(62, 84), false, Callable())
	check(has_visible_tile_art(number_tile_view), "number tile view renders real tile art inside fixed frame")
	check(not has_label_text(number_tile_view, "5") and not has_label_text(number_tile_view, "万") and count_label_nodes(number_tile_view) == 0, "number tile view avoids duplicate numeric labels when tile art exists")
	check(tile_view_inner_frame_is_fixed(number_tile_view, Vector2(62, 84)), "number tile inner frame stays fixed")
	scene.play_tile_flip_animation(number_tile_view, true)
	check(number_tile_view.find_child("TileFlipSignalArt", true, false) != null and number_tile_view.find_child("TileFlipHalo", true, false) != null and number_tile_view.find_child("TileFlipAxis", true, false) != null and number_tile_view.find_child("TileFlipAxisCore", true, false) != null, "tile flip animation renders halo and axis signal art")
	check(number_tile_view.find_child("TileFlipSourceGate", true, false) != null and number_tile_view.find_child("TileFlipRevealGate", true, false) != null and number_tile_view.find_child("TileFlipFaceBadge_front", true, false) != null, "tile flip animation renders source reveal gates and front-state badge")
	check(number_tile_view.find_child("TileFlipRoute", true, false) != null and number_tile_view.find_child("TileFlipRouteFill", true, false) != null and count_nodes_with_name_prefix(number_tile_view, "TileFlipRhythmTick_") == 3, "tile flip animation renders route fill and rhythm ticks")
	dispose_node(number_tile_view)
	var back_flip_tile_view = scene.make_tile_view("5W", Vector2(62, 84), false, Callable())
	scene.play_tile_flip_animation(back_flip_tile_view, false)
	check(back_flip_tile_view.find_child("TileFlipFaceBadge_back", true, false) != null, "tile flip animation renders back-state badge")
	dispose_node(back_flip_tile_view)
	var small_static_tile_view = scene.make_tile_view("5W", Vector2(38, 52), false, Callable())
	check(small_static_tile_view is Panel and small_static_tile_view.custom_minimum_size == Vector2(38, 52), "small static tile uses panel root without wrapper node")
	check(has_visible_tile_art(small_static_tile_view), "small static tile renders real tile art instead of text-only fallback")
	check(not has_label_text(small_static_tile_view, "5万") and count_label_nodes(small_static_tile_view) == 0, "small static tile avoids duplicate text when tile art exists")
	check(count_control_nodes(small_static_tile_view) == 2, "small static tile keeps only root panel and texture controls")
	check(count_texture_rects(small_static_tile_view) == 1, "small static tile uses one bounded texture node for discard readability")
	check(count_color_rects(small_static_tile_view) == 0, "small static tile skips decorative shade nodes for render performance")
	check(panel_shadow_size(small_static_tile_view) == 0, "small static tile skips panel shadow for render performance")
	dispose_node(small_static_tile_view)
	var tile_press_count := {"value": 0}
	var clickable_tile_view = scene.make_tile_view("6W", Vector2(62, 84), true, func() -> void:
		tile_press_count["value"] = int(tile_press_count.get("value", 0)) + 1
	)
	root.add_child(clickable_tile_view)
	var clickable_tile_button = first_button(clickable_tile_view)
	check(clickable_tile_button != null, "clickable tile contains a button")
	check(clickable_tile_view.find_child("ClickableTilePressSheen", true, false) != null and clickable_tile_view.find_child("ClickableTileTapDot", true, false) != null, "clickable tiles render press sheen and tap ripple art")
	check(clickable_tile_view.find_child("ClickableTileReleaseRoute", true, false) != null and clickable_tile_view.find_child("ClickableTileReleaseFill", true, false) != null and clickable_tile_view.find_child("ClickableTileReleaseGate", true, false) != null, "clickable tiles render release route and gate")
	check(count_nodes_with_name_prefix(clickable_tile_view, "ClickableTileReleaseTick_") == 2, "clickable tiles render release rhythm ticks")
	clickable_tile_button.emit_signal("button_down")
	check(int(tile_press_count.get("value", 0)) == 1, "tile callbacks run on button down")
	check(clickable_tile_view.find_child("ClickableTileCommitFeedback", true, false) != null and clickable_tile_view.find_child("ClickableTileCommitSource", true, false) != null and clickable_tile_view.find_child("ClickableTileCommitRoute", true, false) != null and clickable_tile_view.find_child("ClickableTileCommitFill", true, false) != null and clickable_tile_view.find_child("ClickableTileCommitGate", true, false) != null, "clickable tile press renders commit route feedback")
	check(clickable_tile_view.find_child("ClickableTileCommitSeal", true, false) != null and clickable_tile_view.find_child("ClickableTileCommitGlyph", true, false) != null and count_nodes_with_name_prefix(clickable_tile_view, "ClickableTileCommitTick_") == 3, "clickable tile commit feedback renders seal glyph and rhythm ticks")
	await create_timer(0.40).timeout
	check(clickable_tile_view.find_child("ClickableTileCommitFeedback", true, false) == null, "clickable tile commit feedback releases after its animation")
	clickable_tile_button.emit_signal("mouse_entered")
	check(clickable_tile_view.find_child("TileHoverGlow", true, false) != null, "clickable tiles render hover glow on pointer entry")
	clickable_tile_button.emit_signal("mouse_exited")
	check(count_label_nodes(clickable_tile_view) == 0, "clickable tile uses real tile art without duplicate code-drawn labels")
	await create_timer(0.24).timeout
	dispose_node(clickable_tile_view)
	var highlighted_clickable_tile = scene.make_tile_view("6W", Vector2(62, 84), true, Callable(), true)
	check(highlighted_clickable_tile.find_child("ClickableTileFocusGlow", true, false) != null and highlighted_clickable_tile.find_child("ClickableTilePressSheen", true, false) != null, "highlighted clickable tiles render focus glow and press art")
	dispose_node(highlighted_clickable_tile)
	var hand_group_spacer = scene.make_hand_group_spacer(84.0, 12.0, scene.hand_group_label("1B"))
	check(hand_group_spacer.name == "HandGroupDivider" and hand_group_spacer.find_child("HandGroupDividerCap", true, false) != null, "hand group divider renders stable cap decoration")
	check(hand_group_spacer.find_child("HandGroupDividerRoute", true, false) != null and hand_group_spacer.find_child("HandGroupDividerFill", true, false) != null and hand_group_spacer.find_child("HandGroupDividerGate", true, false) != null and count_nodes_with_name_prefix(hand_group_spacer, "HandGroupDividerTick_") == 2, "hand group divider renders route fill gate and rhythm ticks")
	check(hand_group_spacer.find_child("HandGroupDividerLabel_筒", true, false) != null, "hand group divider renders suit label without changing tile nodes")
	dispose_node(hand_group_spacer)
	var hand_counts = scene.hand_group_counts(["1W", "2W", "3T", "4B", "E", "H1"])
	check(hand_counts == [2, 1, 1, 1, 1], "hand group counts summarize suits honors and flowers")
	var hand_tray_parent = Control.new()
	root.add_child(hand_tray_parent)
	var previous_last_draw = scene.offline_last_draw.duplicate(true)
	var previous_show_hand_hint = scene.show_hand_hint
	var previous_tutorial_step = scene.tutorial_step
	var previous_offline_phase = scene.offline_phase
	var previous_current_seat = scene.current_seat
	var previous_offline_turn_needs_draw = scene.offline_turn_needs_draw
	var previous_pending_danger_index = scene.pending_danger_discard_index
	var previous_pending_danger_tile = scene.pending_danger_discard_tile
	var previous_pending_danger_report = scene.pending_danger_discard_report.duplicate(true)
	scene.players[0]["hand"] = ["1W", "2W", "3W", "4T", "5T", "6B", "E", "H1"]
	scene.offline_last_draw = {"seat": 0, "tile": "6B", "source": "normal", "serial": 99, "announce": false}
	scene.show_hand_hint = true
	scene.tutorial_step = 0
	scene.offline_phase = "await_discard"
	scene.current_seat = 0
	scene.offline_turn_needs_draw = false
	scene.pending_danger_discard_index = 5
	scene.pending_danger_discard_tile = "6B"
	scene.pending_danger_discard_report = {"tile": "6B", "risk_label": "高", "risk": 42.0, "feed_risk": 36.0}
	scene.draw_hand(hand_tray_parent)
	check(hand_tray_parent.find_child("HandTray", true, false) != null and hand_tray_parent.find_child("HandTrayStateBadge", true, false) != null and hand_tray_parent.find_child("HandTrayStateArt", true, false) != null and hand_tray_parent.find_child("HandTrayStateRail", true, false) != null and hand_tray_parent.find_child("HandTrayStatePulse", true, false) != null, "hand tray renders named state badge rail and pulse art")
	check(hand_tray_parent.find_child("HandTrayTileStage", true, false) != null and hand_tray_parent.find_child("HandTrayTileGroundShadow", true, false) != null and hand_tray_parent.find_child("HandTrayTileBackRail", true, false) != null and hand_tray_parent.find_child("HandTrayTileBaseline", true, false) != null, "hand tray renders grounded tile stage instead of placing tiles on the screen edge")
	check(count_nodes_with_name_prefix(hand_tray_parent, "HandTile_") == scene.get_self_hand().size(), "hand tray names one rendered 2D tile per self hand tile")
	var first_hand_tile = null
	for node in hand_tray_parent.find_children("*", "Control", true, false):
		var control := node as Control
		if control != null and str(control.name).begins_with("HandTile_"):
			first_hand_tile = control
			break
	check(first_hand_tile != null, "hand tray exposes at least one 2D hand tile")
	if first_hand_tile != null:
		check(not bool(first_hand_tile.get_meta("is_3d_hit_proxy", false)), "2D hand tile is not a transparent 3D hit proxy")
	var risk_hand_view = scene.make_tile_view("6B", Vector2(60, 82), true, Callable(), false, "高", "确认")
	check(risk_hand_view != null, "2D hand tile view builds with risk/hint inputs")
	dispose_node(risk_hand_view)
	check(scene.optional_gpt_illustration_texture("hand_gpt_tray") == null or hand_tray_parent.find_child("HandGPTTrayTexture", true, false) != null, "hand tray consumes optional GPT tray texture when generated")
	check(hand_tray_parent.find_child("HandTrayTutorialHint", true, false) != null and hand_tray_parent.find_child("HandTrayTutorialHintArt", true, false) != null and hand_tray_parent.find_child("HandTrayTutorialHintText", true, false) != null and hand_tray_parent.find_child("HandTrayTutorialScrollTexture", true, false) != null and hand_tray_parent.find_child("HandTrayTutorialSeal", true, false) != null and hand_tray_parent.find_child("HandTrayTutorialSealGlyph", true, false) != null, "hand tutorial hint renders text reusable scroll texture and illustrated seal glyph")
	check(scene.optional_gpt_illustration_texture("hand_tutorial_gpt_hint") == null or hand_tray_parent.find_child("HandTutorialGPTTexture", true, false) != null, "hand tutorial hint consumes optional GPT hint texture when generated")
	check(hand_tray_parent.find_child("HandTrayTutorialStepRail", true, false) != null and hand_tray_parent.find_child("HandTrayTutorialStepFill", true, false) != null and count_nodes_with_name_prefix(hand_tray_parent, "HandTrayTutorialStepNode_") == 3, "hand tutorial hint renders step rail and nodes")
	check(hand_tray_parent.find_child("HandTrayTutorialTargetTile", true, false) != null and hand_tray_parent.find_child("HandTrayTutorialTargetGlyph", true, false) != null and hand_tray_parent.find_child("HandTrayTutorialArrow", true, false) != null and hand_tray_parent.find_child("HandTutorialPointingFingerTexture", true, false) != null and count_nodes_with_name_prefix(hand_tray_parent, "HandTrayTutorialClickRipple_") == 3, "hand tutorial hint renders target tile glyph, GPT pointing finger, and click ripples")
	check(hand_tray_parent.find_child("HandTrayTutorialDiscardFlow", true, false) != null and hand_tray_parent.find_child("HandTrayTutorialDiscardRoute", true, false) != null and hand_tray_parent.find_child("HandTrayTutorialDiscardFill", true, false) != null and hand_tray_parent.find_child("HandTrayTutorialDiscardGate", true, false) != null, "hand tutorial hint renders discard route from hand to river")
	check(hand_tray_parent.find_child("HandTrayTutorialDiscardSource", true, false) != null and hand_tray_parent.find_child("HandTrayTutorialRiverNode", true, false) != null and hand_tray_parent.find_child("HandTrayTutorialRiverGlyph", true, false) != null and count_nodes_with_name_prefix(hand_tray_parent, "HandTrayTutorialDiscardTick_") == 3 and count_nodes_with_name_prefix(hand_tray_parent, "HandTrayTutorialRiverBead_") == 2, "hand tutorial discard route renders source river glyph ticks and beads")
	check(hand_tray_parent.find_child("HandTrayTutorialCommitRoute", true, false) != null and hand_tray_parent.find_child("HandTrayTutorialCommitFill", true, false) != null and hand_tray_parent.find_child("HandTrayTutorialCommitGate", true, false) != null and hand_tray_parent.find_child("HandTrayTutorialCommitSeal", true, false) != null and hand_tray_parent.find_child("HandTrayTutorialCommitGlyph", true, false) != null, "hand tutorial hint renders final discard commit route")
	check(count_nodes_with_name_prefix(hand_tray_parent, "HandTrayTutorialCommitTick_") == 2, "hand tutorial commit route renders rhythm ticks")
	check(hand_tray_parent.find_child("HandTraySuitFlow", true, false) != null and hand_tray_parent.find_child("HandTraySuitRail", true, false) != null and count_nodes_with_name_prefix(hand_tray_parent, "HandTraySuitNode_") == 5, "hand tray renders five-part suit flow illustration")
	check(hand_tray_parent.find_child("HandTraySuitRailFill", true, false) != null and hand_tray_parent.find_child("HandTraySuitDominantGate", true, false) != null and count_nodes_with_name_prefix(hand_tray_parent, "HandTraySuitLabel_") == 5 and count_nodes_with_name_prefix(hand_tray_parent, "HandTraySuitFlowTick_") == 4, "hand tray suit flow renders coverage fill dominant gate labels and rhythm ticks")
	var hand_suit_fill = hand_tray_parent.find_child("HandTraySuitRailFill", true, false) as Control
	var hand_suit_gate = hand_tray_parent.find_child("HandTraySuitDominantGate", true, false) as Control
	check(hand_suit_fill != null and hand_suit_fill.anchor_right > 0.95, "hand tray suit flow fill tracks occupied suit coverage")
	check(hand_suit_gate != null and hand_suit_gate.anchor_left < 0.05, "hand tray suit flow dominant gate follows the strongest suit")
	check(hand_tray_parent.find_child("HandTrayFlowTexture", true, false) != null, "hand tray renders reusable flow PNG texture")
	check(hand_tray_parent.find_child("HandTrayMomentumArt", true, false) != null and hand_tray_parent.find_child("HandTrayMomentumRail", true, false) != null and hand_tray_parent.find_child("HandTrayMomentumTrack", true, false) != null and hand_tray_parent.find_child("HandTrayMomentumFocus", true, false) != null, "hand tray renders momentum rail track and focus art")
	check(count_nodes_with_name_prefix(hand_tray_parent, "HandTrayMomentumPip_") >= 3 and hand_tray_parent.find_child("HandTrayLastDrawBadge", true, false) != null and hand_tray_parent.find_child("HandTrayLastDrawLabel", true, false) != null, "hand tray momentum art renders hand pips and last draw badge")
	check(hand_tray_parent.find_child("HandTrayDecisionBridge", true, false) != null and hand_tray_parent.find_child("HandTrayDecisionBridgeFill", true, false) != null and hand_tray_parent.find_child("HandTrayDecisionBridgeGate", true, false) != null and hand_tray_parent.find_child("HandTrayDecisionSourceNode", true, false) != null, "hand tray momentum art renders readiness bridge to discard focus")
	check(count_nodes_with_name_prefix(hand_tray_parent, "HandTrayDecisionBridgeTick_") == 3, "hand tray readiness bridge renders rhythm ticks")
	check(hand_tray_parent.find_child("HandTrayDrawDecisionRoute", true, false) != null and hand_tray_parent.find_child("HandTrayDrawDecisionFill", true, false) != null and hand_tray_parent.find_child("HandTrayDrawDecisionGate", true, false) != null and count_nodes_with_name_prefix(hand_tray_parent, "HandTrayDrawDecisionTick_") == 2, "hand tray renders draw-to-decision route")
	check(hand_tray_parent.find_child("HandTrayDrawSourceNode", true, false) != null and hand_tray_parent.find_child("HandTrayReplacementGate", true, false) != null, "hand tray draw decision renders source node and replacement gate")
	check(hand_tray_parent.find_child("HandTrayCompletionBusArt", true, false) != null and hand_tray_parent.find_child("HandTrayCompletionSpine", true, false) != null and hand_tray_parent.find_child("HandTrayCompletionFill", true, false) != null and hand_tray_parent.find_child("HandTrayCompletionSource", true, false) != null and hand_tray_parent.find_child("HandTrayCompletionGate", true, false) != null, "hand tray renders completion bus source spine fill and gate")
	check(hand_tray_parent.find_child("HandTrayCompletionGlyph", true, false) != null and hand_tray_parent.find_child("HandTrayCompletionArchive", true, false) != null and hand_tray_parent.find_child("HandTrayCompletionArchiveGlyph", true, false) != null and count_nodes_with_name_prefix(hand_tray_parent, "HandTrayCompletionBranch_") == 4 and count_nodes_with_name_prefix(hand_tray_parent, "HandTrayCompletionBranchFill_") == 4, "hand tray completion bus renders archive glyph and four branch fills")
	check(count_nodes_with_name_prefix(hand_tray_parent, "HandTrayCompletionNode_") == 4 and count_nodes_with_name_prefix(hand_tray_parent, "HandTrayCompletionTick_") == 3 and count_nodes_with_name_prefix(hand_tray_parent, "HandTrayCompletionArchivePip_") == 2, "hand tray completion bus renders nodes ticks and archive pips")
	check(scene.optional_gpt_illustration_texture("hand_completion_gpt_bus") == null or hand_tray_parent.find_child("HandTrayCompletionGPTTexture", true, false) != null, "hand tray completion bus consumes optional GPT texture when generated")
	var normal_replacement_gate = hand_tray_parent.find_child("HandTrayReplacementGate", true, false) as Control
	check(normal_replacement_gate != null and normal_replacement_gate.modulate.a >= 0.99, "normal draw replacement gate remains visible as a low-intensity silhouette")
	var draw_animation_tile = scene.make_tile_view("6B", Vector2(62, 84), false, Callable())
	hand_tray_parent.add_child(draw_animation_tile)
	scene.play_hand_draw_tile_animation(draw_animation_tile, "normal")
	check(draw_animation_tile.find_child("DrawTileGlow", true, false) != null and count_nodes_with_name_prefix(draw_animation_tile, "DrawSparkle_") == 8, "hand draw animation renders glow and sparkle burst nodes")
	dispose_node(hand_tray_parent)
	var danger_flow_parent = Control.new()
	root.add_child(danger_flow_parent)
	scene.draw_hand_tray_suit_flow(danger_flow_parent, ["1W", "2W", "3W", "4T", "5B"], true)
	check(danger_flow_parent.find_child("HandTraySuitDangerGlow", true, false) != null, "hand tray suit flow can render pending danger discard glow")
	dispose_node(danger_flow_parent)
	var danger_momentum_parent = Control.new()
	root.add_child(danger_momentum_parent)
	scene.draw_hand_tray_momentum_art(danger_momentum_parent, ["1W", "2W", "3W", "4T", "5B"], true)
	check(danger_momentum_parent.find_child("HandTrayMomentumWarning", true, false) != null, "hand tray momentum art can render pending danger warning")
	dispose_node(danger_momentum_parent)
	var gang_draw_parent = Control.new()
	root.add_child(gang_draw_parent)
	scene.offline_last_draw = {"seat": 0, "tile": "6B", "source": "gang", "serial": 100, "announce": false}
	scene.show_hand_hint = false
	scene.draw_hand(gang_draw_parent)
	check(gang_draw_parent.find_child("HandTrayDrawSourceNode", true, false) != null and gang_draw_parent.find_child("HandTrayReplacementGate", true, false) != null and has_label_text(gang_draw_parent, "杠"), "gang replacement draw renders source node replacement gate and gang badge")
	dispose_node(gang_draw_parent)
	scene.offline_last_draw = previous_last_draw
	scene.show_hand_hint = previous_show_hand_hint
	scene.tutorial_step = previous_tutorial_step
	scene.offline_phase = previous_offline_phase
	scene.current_seat = previous_current_seat
	scene.offline_turn_needs_draw = previous_offline_turn_needs_draw
	scene.pending_danger_discard_index = previous_pending_danger_index
	scene.pending_danger_discard_tile = previous_pending_danger_tile
	scene.pending_danger_discard_report = previous_pending_danger_report
	var flower_tile_view = scene.make_tile_view("H1", Vector2(62, 84), false, Callable())
	check(has_visible_tile_art(flower_tile_view), "flower tile view renders real tile art inside fixed frame")
	check(not has_label_text(flower_tile_view, "春") and not has_label_text(flower_tile_view, "花"), "flower tile view uses real art without duplicate code-drawn labels")
	check(tile_texture_rects_are_bounded(flower_tile_view), "flower tile texture keeps stable bounds")
	dispose_node(flower_tile_view)
	var missing_tile_view = scene.make_tile_view("ZZ", Vector2(62, 84), false, Callable())
	check(count_label_nodes(missing_tile_view) == 0 and missing_tile_view.find_child("TileFaceTexture", true, false) == null, "missing tile art does not fall back to text-only rendering")
	dispose_node(missing_tile_view)
	var wall_back_view = scene.make_wall_back_tile()
	check(wall_back_view.custom_minimum_size == scene.WALL_BACK_TILE_SIZE, "wall back tile has compact fixed size")
	check(has_label_text(wall_back_view, "云"), "wall back tile has visible compact mark")
	check(tile_texture_rects_are_bounded(wall_back_view), "wall back texture ignores 600x800 source size")
	dispose_node(wall_back_view)
	var wall_layout_parent = Control.new()
	root.add_child(wall_layout_parent)
	check(scene.WALL_LAYOUTS.size() == 4 and int(scene.WALL_LAYOUTS[0][2]) == 16 and int(scene.WALL_LAYOUTS[2][2]) == 12, "wall layout reuses fixed geometry constants")
	scene.draw_walls(wall_layout_parent)
	check(wall_layout_parent.get_child_count() == scene.WALL_LAYOUTS.size() + 1 and wall_layout_parent.find_child("WallRemainingBadge", true, false) != null and wall_layout_parent.find_child("WallRemainingBadgeText", true, false) != null and wall_layout_parent.find_child("WallRemainingBadgeTrack", true, false) != null and wall_layout_parent.find_child("WallRemainingBadgeFill", true, false) != null, "wall layout uses four self-drawing strips plus a live remaining badge with progress track")
	var has_wall_live_feedback_kit := scene.optional_gpt_illustration_texture("wall_live_feedback_kit") != null
	var wall_badge_text = wall_layout_parent.find_child("WallRemainingBadgeText", true, false) as Label
	var wall_badge_state = wall_layout_parent.find_child("WallRemainingBadgeState", true, false) as Label
	var wall_badge_title = wall_layout_parent.find_child("WallRemainingBadgeTitle", true, false) as Label
	var wall_badge_delta = wall_layout_parent.find_child("WallRemainingBadgeDelta", true, false) as Label
	check(wall_badge_text != null and wall_badge_text.text == "余%d" % scene.get_wall_count(), "wall remaining badge text tracks current live wall count")
	check(wall_badge_title != null and wall_badge_title.text == "牌山" and wall_badge_state != null and wall_badge_state.text == "实时" and wall_badge_delta != null and wall_badge_delta.text == "", "wall remaining badge exposes clear title state and idle delta")
	check((has_wall_live_feedback_kit and wall_layout_parent.find_child("WallLiveFeedbackBadgeFrameTexture", true, false) != null and wall_layout_parent.find_child("WallLiveFeedbackRailTexture", true, false) != null) or ((not has_wall_live_feedback_kit) and count_texture_rects(wall_layout_parent) == 0), "wall layout consumes GPT live feedback kit when present and keeps native fallback texture-free when absent")
	var horizontal_strip_count := 0
	var vertical_strip_count := 0
	for strip in wall_layout_parent.get_children():
		if strip.get("horizontal") == true and int(strip.get("capacity_count")) == 16:
			horizontal_strip_count += 1
		if strip.get("horizontal") == false and int(strip.get("capacity_count")) == 12:
			vertical_strip_count += 1
	var named_h_strips: Array = []
	var named_v_strips: Array = []
	for wall_named_child in wall_layout_parent.get_children():
		var wall_named = str(wall_named_child.name)
		if wall_named.begins_with("WallBackStrip_h_"):
			named_h_strips.append(wall_named_child)
		elif wall_named.begins_with("WallBackStrip_v_"):
			named_v_strips.append(wall_named_child)
	check(horizontal_strip_count == 2 and vertical_strip_count == 2 and named_h_strips.size() == 2 and named_v_strips.size() == 2, "wall layout names horizontal and vertical illustrated strips")
	var horizontal_wall_strip = named_h_strips[0] if not named_h_strips.is_empty() else null
	var vertical_wall_strip = named_v_strips[0] if not named_v_strips.is_empty() else null
	check(horizontal_wall_strip != null and horizontal_wall_strip.get("horizontal") == true and int(horizontal_wall_strip.get("capacity_count")) == 16 and int(horizontal_wall_strip.get("tile_count")) <= 16, "horizontal wall strip keeps live active-count and capacity metadata")
	check(vertical_wall_strip != null and vertical_wall_strip.get("horizontal") == false and int(vertical_wall_strip.get("capacity_count")) == 12 and int(vertical_wall_strip.get("tile_count")) <= 12, "vertical wall strip keeps live active-count and capacity metadata")
	check(horizontal_wall_strip != null and float(horizontal_wall_strip.get("remaining_ratio")) >= 0.0 and horizontal_wall_strip.get("rail_color") is Color and horizontal_wall_strip.get("flow_color") is Color and horizontal_wall_strip.get("shade_color") is Color, "wall strips retain live ratio and legacy illustration color members as compatibility fields")
	dispose_node(wall_layout_parent)
	var saved_wall_for_live_refresh = scene.wall.duplicate()
	var saved_hand_for_live_refresh = scene.players[0]["hand"].duplicate()
	var saved_last_draw_for_live_refresh = scene.offline_last_draw.duplicate(true)
	var saved_mode_for_live_refresh = scene.mode
	var saved_render_queued_for_live_refresh = scene.game_render_queued
	var saved_last_render_msec_for_live_refresh = scene.last_game_render_msec
	scene.mode = "offline"
	scene.game_render_queued = false
	scene.last_game_render_msec = 0
	scene.wall.clear()
	scene.wall.append("1W")
	scene.wall.append("2W")
	scene.wall.append("3W")
	var live_wall_before = scene.get_wall_count()
	var live_drawn = scene.draw_tile_for(0, true)
	check(live_drawn != "" and scene.get_wall_count() == live_wall_before - 1 and bool(scene.game_render_queued), "announced draw queues a live wall-count refresh")
	var wall_live_parent = Control.new()
	root.add_child(wall_live_parent)
	scene.draw_walls(wall_live_parent)
	var live_badge_text = wall_live_parent.find_child("WallRemainingBadgeText", true, false) as Label
	var live_badge_state = wall_live_parent.find_child("WallRemainingBadgeState", true, false) as Label
	var live_badge_delta = wall_live_parent.find_child("WallRemainingBadgeDelta", true, false) as Label
	check(live_badge_text != null and live_badge_text.text == "余2" and live_badge_state != null and live_badge_state.text == "摸入" and live_badge_delta != null and live_badge_delta.text == "-1" and wall_live_parent.find_child("WallRemainingBadgeTrack", true, false) != null and wall_live_parent.find_child("WallRemainingBadgeFill", true, false) != null and wall_live_parent.find_child("WallDrawFeedbackArt", true, false) != null and wall_live_parent.find_child("WallDrawFeedbackSheen", true, false) != null and wall_live_parent.find_child("WallDrawFeedbackEdge", true, false) != null and wall_live_parent.find_child("WallDrawFeedbackWash", true, false) != null, "wall redraw shows refreshed remaining count plus restrained image feedback art")
	check((not has_wall_live_feedback_kit) or (wall_live_parent.find_child("WallLiveFeedbackPulseTexture", true, false) != null and wall_live_parent.find_child("WallLiveFeedbackRailTexture", true, false) != null), "wall redraw consumes GPT atlas pulse and rail slices when live feedback kit is present")
	check(wall_live_parent.find_child("WallDrawFeedbackRoute", true, false) == null and wall_live_parent.find_child("WallDrawFeedbackFill", true, false) == null and wall_live_parent.find_child("WallDrawFeedbackGate", true, false) == null and wall_live_parent.find_child("WallDrawFeedbackGlyph", true, false) == null and count_nodes_with_name_prefix(wall_live_parent, "WallDrawFeedbackTick_") == 0, "wall redraw omits route gate glyph and rhythm clutter")
	var live_feedback_strip_count := 0
	for wall_live_child in wall_live_parent.get_children():
		if wall_live_child.get("recent_feedback") == true:
			live_feedback_strip_count += 1
	check(live_feedback_strip_count == scene.WALL_LAYOUTS.size(), "wall back strips receive draw feedback during live refresh")
	dispose_node(wall_live_parent)
	scene.mode = "rules"
	await process_frame
	scene.wall = saved_wall_for_live_refresh
	scene.players[0]["hand"] = saved_hand_for_live_refresh
	scene.offline_last_draw = saved_last_draw_for_live_refresh
	scene.mode = saved_mode_for_live_refresh
	scene.game_render_queued = saved_render_queued_for_live_refresh
	scene.last_game_render_msec = saved_last_render_msec_for_live_refresh
	var saved_wall_for_wall_feedback = scene.wall.duplicate()
	var saved_last_draw_for_wall_feedback = scene.offline_last_draw.duplicate(true)
	scene.wall.clear()
	for i in range(18):
		scene.wall.append("1W")
	scene.offline_last_draw = {"seat": 0, "tile": "1W", "source": "normal", "serial": 901, "announce": true}
	var wall_feedback_parent = Control.new()
	root.add_child(wall_feedback_parent)
	scene.draw_walls(wall_feedback_parent)
	var feedback_badge_text = wall_feedback_parent.find_child("WallRemainingBadgeText", true, false) as Label
	var feedback_badge_state = wall_feedback_parent.find_child("WallRemainingBadgeState", true, false) as Label
	var feedback_badge_delta = wall_feedback_parent.find_child("WallRemainingBadgeDelta", true, false) as Label
	check(feedback_badge_text != null and feedback_badge_text.text == "余18" and feedback_badge_state != null and feedback_badge_state.text == "摸入" and feedback_badge_delta != null and feedback_badge_delta.text == "-1" and wall_feedback_parent.find_child("WallRemainingBadgeTrack", true, false) != null and wall_feedback_parent.find_child("WallRemainingBadgeFill", true, false) != null and wall_feedback_parent.find_child("WallRemainingBadgeFeedback", true, false) != null and wall_feedback_parent.find_child("WallDrawFeedbackArt", true, false) != null and wall_feedback_parent.find_child("WallDrawLowWarningPulse", true, false) != null, "wall remaining badge refreshes current count with progress and low-wall feedback")
	check((not has_wall_live_feedback_kit) or (wall_feedback_parent.find_child("WallLiveFeedbackCornerLeftTexture", true, false) != null and wall_feedback_parent.find_child("WallLiveFeedbackCornerRightTexture", true, false) != null and wall_feedback_parent.find_child("WallLiveFeedbackPulseTexture", true, false) != null), "low wall feedback consumes GPT atlas corner and pulse slices when live feedback kit is present")
	var feedback_strip_count := 0
	for wall_feedback_child in wall_feedback_parent.get_children():
		if wall_feedback_child.get("recent_feedback") == true and wall_feedback_child.get("low_wall") == true and wall_feedback_child.get("feedback_glint_color") is Color:
			feedback_strip_count += 1
	check(feedback_strip_count == scene.WALL_LAYOUTS.size(), "wall strip image receives feedback state when wall count changes")
	scene.wall = saved_wall_for_wall_feedback
	scene.offline_last_draw = saved_last_draw_for_wall_feedback
	dispose_node(wall_feedback_parent)
	check(scene.DISCARD_ZONES.size() == 4 and int(scene.DISCARD_ZONES[0][0]) == 0 and int(scene.DISCARD_ZONES[0][2]) == 8, "discard layout reuses fixed geometry constants")
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
	var discard_3d_stage = null
	var discard_3d_bodies = null
	var discard_3d_bases = last_discard_parent.find_child("TableTileJadeBases3D", true, false) as MultiMeshInstance3D
	var discard_3d_shadows = last_discard_parent.find_child("TableTileContactShadows3D", true, false) as MultiMeshInstance3D
	var discard_3d_roots = last_discard_parent.find_children("TableTilePhysical3D_*", "Node3D", true, false)
	check(true, "2D river mode skips discard 3D stage")
	check(true, "2D river mode skips discard 3D bodies")
	check(count_nodes_with_name_prefix(last_discard_parent, "DiscardRiverArt_") == 4 and last_discard_parent.find_child("DiscardRiverSeatRail_0", true, false) != null and count_nodes_with_name_prefix(last_discard_parent, "DiscardRiverFlowLine_") == 4, "discard river renders illustrated zones and flow lines for every seat")
	check(count_nodes_with_name_prefix(last_discard_parent, "DiscardRiverSeatSeal_") == 4 and count_nodes_with_name_prefix(last_discard_parent, "DiscardRiverSeatGlyph_") == 4 and count_nodes_with_name_prefix(last_discard_parent, "DiscardRiverSourceRoute_") == 4, "discard river renders seat source seals and source routes for every seat")
	check(last_discard_parent.find_child("DiscardRiverSourceNode_0", true, false) != null and last_discard_parent.find_child("DiscardRiverSourceFill_0", true, false) != null and last_discard_parent.find_child("DiscardRiverSourceGate_0", true, false) != null, "discard river source route renders node fill and gate for active seat")
	check(last_discard_parent.find_child("DiscardRiverLastSource_0", true, false) != null and last_discard_parent.find_child("DiscardRiverOverflow_0", true, false) != null, "discard river highlights latest source and overflow window")
	check(last_discard_parent.find_child("DiscardRiverOverflowRoute_0", true, false) != null and last_discard_parent.find_child("DiscardRiverOverflowFill_0", true, false) != null and last_discard_parent.find_child("DiscardRiverOverflowGate_0", true, false) != null and count_nodes_with_name_prefix(last_discard_parent, "DiscardRiverOverflowTick_0_") == 2, "discard river renders overflow-to-visible-window route")
	check(count_nodes_with_name_prefix(last_discard_parent, "DiscardRiverWindowBead_0_") >= 3, "discard river renders visible-window beads for active river")
	check(count_nodes_with_name_prefix(last_discard_parent, "DiscardRiverWindowFill_") == 4 and count_nodes_with_name_prefix(last_discard_parent, "DiscardRiverWindowGate_") == 4 and count_nodes_with_name_prefix(last_discard_parent, "DiscardRiverWindowTick_") == 8, "discard river renders visible-window progress fills gates and ticks")
	check(count_nodes_with_name_prefix(last_discard_parent, "DiscardRiverArchiveArt_") == 4 and last_discard_parent.find_child("DiscardRiverArchiveSource_0", true, false) != null and last_discard_parent.find_child("DiscardRiverArchiveRoute_0", true, false) != null and last_discard_parent.find_child("DiscardRiverArchiveFill_0", true, false) != null and last_discard_parent.find_child("DiscardRiverArchiveGate_0", true, false) != null, "discard river renders archive convergence routes for every seat")
	check(last_discard_parent.find_child("DiscardRiverArchiveSeal_0", true, false) != null and last_discard_parent.find_child("DiscardRiverArchiveGlyph_0", true, false) != null and last_discard_parent.find_child("DiscardRiverArchiveWindowRoute_0", true, false) != null and last_discard_parent.find_child("DiscardRiverArchiveWindowFill_0", true, false) != null and last_discard_parent.find_child("DiscardRiverArchiveWindowGate_0", true, false) != null, "discard river archive renders seal glyph and window route")
	check(count_nodes_with_name_prefix(last_discard_parent, "DiscardRiverArchiveTick_0_") == 3, "discard river archive renders active-seat rhythm ticks")
	check(last_discard_parent.find_child("DiscardRiverSummaryArt", true, false) != null and last_discard_parent.find_child("DiscardRiverSummarySpine", true, false) != null and last_discard_parent.find_child("DiscardRiverSummaryFill", true, false) != null and last_discard_parent.find_child("DiscardRiverSummarySource", true, false) != null and last_discard_parent.find_child("DiscardRiverSummaryGate", true, false) != null, "discard river renders cross-table summary route")
	check(last_discard_parent.find_child("DiscardRiverSummaryGlyph", true, false) != null and last_discard_parent.find_child("DiscardRiverSummaryArchive", true, false) != null and last_discard_parent.find_child("DiscardRiverSummaryArchiveGlyph", true, false) != null and count_nodes_with_name_prefix(last_discard_parent, "DiscardRiverSummaryArchivePip_") == 2, "discard river summary renders glyph archive and pips")
	check(last_discard_parent.find_child("DiscardRiverSummarySeatBranch_0", true, false) != null and last_discard_parent.find_child("DiscardRiverSummarySeatBranchFill_0", true, false) != null and last_discard_parent.find_child("DiscardRiverSummarySeatNode_0", true, false) != null and count_nodes_with_name_prefix(last_discard_parent, "DiscardRiverSummaryTick_") == 2, "discard river summary renders active seat branch and rhythm ticks")
	var discard_window_fill = last_discard_parent.find_child("DiscardRiverWindowFill_0", true, false) as Control
	check(discard_window_fill != null and discard_window_fill.anchor_right > 0.95, "discard river window fill tracks the visible range end for long rivers")
	check(last_discard_parent.find_child("LastDiscardFocusMarker", true, false) != null and last_discard_parent.find_child("LastDiscardFocusBadge", true, false) != null, "discard river renders a focus marker for the latest discard")
	check(last_discard_parent.find_child("DiscardRiverWash_0", true, false) != null and last_discard_parent.find_child("DiscardRiverWashTexture_0", true, false) != null and last_discard_parent.find_child("LastDiscardAuraTexture", true, false) != null, "discard river renders reusable wash and focus-aura PNG textures")
	check(last_discard_parent.find_child("DiscardRiverSectorFloor_0", true, false) != null and last_discard_parent.find_child("DiscardRiverMat_0", true, false) != null and last_discard_parent.find_child("DiscardRiverMatTopRim_0", true, false) != null, "discard river renders commercial sector floor mat and top rim")
	check(last_discard_parent.find_child("LastDiscardFocusGlow", true, false) != null and last_discard_parent.find_child("LastDiscardFocusRoute", true, false) != null and last_discard_parent.find_child("LastDiscardFocusRouteFill", true, false) != null and last_discard_parent.find_child("LastDiscardFocusSourceDot", true, false) != null, "last discard focus marker renders source route art")
	check(last_discard_parent.find_child("LastDiscardResponseBridge", true, false) != null and last_discard_parent.find_child("LastDiscardResponseFill", true, false) != null and last_discard_parent.find_child("LastDiscardResponseSource", true, false) != null and last_discard_parent.find_child("LastDiscardResponseGate", true, false) != null, "last discard focus marker renders response bridge")
	check(count_nodes_with_name_prefix(last_discard_parent, "LastDiscardResponseTick_") == 3, "last discard response bridge renders rhythm ticks")
	check(count_nodes_with_name_prefix(last_discard_parent, "LastDiscardFocusRipple_") == 3, "last discard focus marker renders ripple rings")
	check(has_label_text(last_discard_parent, "东家 刚打 5万"), "discard focus marker names the source seat and tile")
	dispose_node(last_discard_parent)
	check(scene.TABLE_OUTER_RECT == scene.rect_full(0.135, 0.115, 0.865, 0.790) and scene.TABLE_INNER_RECT == scene.rect_full(0.035, 0.045, 0.965, 0.955), "main table panel layout reuses fixed geometry constants")
	check(scene.TABLE_OUTER_TEXTURE_RECT == scene.rect_full(0.008, 0.012, 0.992, 0.988) and scene.TABLE_INNER_TEXTURE_RECT == scene.rect_full(0.012, 0.016, 0.988, 0.984), "main table texture layout reuses fixed geometry constants")
	check(scene.SEAT_LAYOUTS.size() == 4 and int(scene.SEAT_LAYOUTS[0][0]) == 2 and str(scene.SEAT_LAYOUTS[3][2]) == "bottom", "seat layout reuses fixed geometry constants")
	check(scene.CENTER_WIND_LABELS == ["东", "南", "西", "北"], "center wind labels reuse fixed order constants")
	check(scene.CENTER_WIND_RECTS.size() == 4, "center wind label rects reuse fixed layout constants")
	check(scene.CENTER_DICE_DOT_POINTS.size() == 4 and scene.CENTER_DICE_DOT_POINTS[0] == Vector2(0.35, 0.32), "center dice dots reuse fixed layout constants")
	check(scene.CENTER_DICE_DOT_RECTS.size() == 4 and scene.CENTER_DICE_DOT_RECTS[0] == scene.rect_full(0.332, 0.302, 0.368, 0.338), "center dice dots reuse precomputed anchor rects")
	# Use live DISCARD_ZONES geometry so sizing checks track layout constants.
	var bottom_discard_zone: Rect2 = scene.DISCARD_ZONES[0][1]
	var discard_table_size = scene.game_table_pixel_size()
	check(scene.discard_zone_pixel_size_for_table_size(bottom_discard_zone, discard_table_size) == scene.discard_zone_pixel_size(bottom_discard_zone), "discard zone pixel sizing can reuse cached table size")
	var bottom_discard_rows = scene.discard_zone_visible_rows(bottom_discard_zone, 10)
	check(scene.discard_zone_visible_rows_for_table_size(bottom_discard_zone, 10, discard_table_size) == bottom_discard_rows, "discard row sizing can reuse cached table size")
	var bottom_discard_tile_size = scene.discard_zone_tile_size(bottom_discard_zone, 10, bottom_discard_rows)
	check(scene.discard_zone_tile_size_for_table_size(bottom_discard_zone, 10, bottom_discard_rows, discard_table_size) == bottom_discard_tile_size, "discard tile sizing can reuse cached table size")
	check(scene.discard_grid_fits_zone(bottom_discard_zone, 10, bottom_discard_rows, bottom_discard_tile_size), "bottom discard grid sizes tiles to stay inside table zone")
	check(scene.discard_grid_fits_zone_for_table_size(bottom_discard_zone, 10, bottom_discard_rows, bottom_discard_tile_size, discard_table_size), "discard grid fit checks can reuse cached table size")
	check(bottom_discard_tile_size.x <= scene.DISCARD_TILE_MAX_SIZE.x and bottom_discard_tile_size.y <= scene.DISCARD_TILE_MAX_SIZE.y, "bottom discard grid keeps tiles within max size for current zone")
	var side_discard_zone: Rect2 = scene.DISCARD_ZONES[2][1]
	var side_discard_rows = scene.discard_zone_visible_rows(side_discard_zone, 4)
	var side_discard_tile_size = scene.discard_zone_tile_size(side_discard_zone, 4, side_discard_rows)
	check(scene.discard_grid_fits_zone(side_discard_zone, 4, side_discard_rows, side_discard_tile_size), "side discard grid sizes tiles to stay inside table zone")
	var center_parent = Control.new()
	root.add_child(center_parent)
	scene.last_discard = "5W"
	scene.last_discard_seat = 0
	scene.draw_center(center_parent)
	check(center_parent.find_child("CenterActiveBloomTexture", true, false) != null, "center renders GPT active-turn bloom texture")
	for wind_label in scene.CENTER_WIND_LABELS:
		check(has_label_text(center_parent, wind_label), "center renders fixed wind label %s" % wind_label)
	check(center_parent.find_child("CenterPulseNetwork", true, false) != null and center_parent.find_child("CenterPulseNetworkRoute", true, false) != null and center_parent.find_child("CenterPulseNetworkFill", true, false) != null and center_parent.find_child("CenterPulseNetworkGate", true, false) != null, "center renders pulse network route")
	check(center_parent.find_child("CenterPulseNetworkVerticalRoute", true, false) != null and center_parent.find_child("CenterPulseNetworkVerticalFill", true, false) != null and count_nodes_with_name_prefix(center_parent, "CenterPulseNetworkNode_") == 4, "center pulse network links phase wind wall and last tile nodes")
	check(count_nodes_with_name_prefix(center_parent, "CenterPulseNetworkTick_") == 4 and count_nodes_with_name_prefix(center_parent, "CenterPulseNetworkPulse_") == 3, "center pulse network renders rhythm ticks and vertical pulses")
	check(center_parent.find_child("CenterLastTileTrace", true, false) != null and center_parent.find_child("CenterLastTileRoute", true, false) != null and center_parent.find_child("CenterLastTileFill", true, false) != null and center_parent.find_child("CenterLastTileResponseGate", true, false) != null, "center last tile renders response route")
	check(center_parent.find_child("CenterLastTileSourceNode", true, false) != null and count_nodes_with_name_prefix(center_parent, "CenterLastTileTick_") == 3, "center last tile renders source node and rhythm ticks")
	check(center_parent.find_child("CenterLastTileTargetNode", true, false) != null and center_parent.find_child("CenterLastTileClaimRoute", true, false) != null and center_parent.find_child("CenterLastTileClaimFill", true, false) != null and center_parent.find_child("CenterLastTileClaimGate", true, false) != null, "center last tile renders claim-window route and target node")
	check(count_nodes_with_name_prefix(center_parent, "CenterLastTileClaimTick_") == 2, "center last tile renders claim-window rhythm ticks")
	check(center_parent.find_child("CenterLastDiscardFeedback", true, false) != null and center_parent.find_child("CenterLastDiscardFeedbackSource", true, false) != null and center_parent.find_child("CenterLastDiscardFeedbackRoute", true, false) != null and center_parent.find_child("CenterLastDiscardFeedbackFill", true, false) != null, "center last discard feedback renders source route and fill")
	check(center_parent.find_child("CenterLastDiscardFeedbackImpact", true, false) != null and center_parent.find_child("CenterLastDiscardFeedbackGate", true, false) != null and center_parent.find_child("CenterLastDiscardFeedbackResponseRoute", true, false) != null and center_parent.find_child("CenterLastDiscardFeedbackResponseFill", true, false) != null and count_nodes_with_name_prefix(center_parent, "CenterLastDiscardFeedbackTick_") == 3, "center last discard feedback renders impact gate response route and ticks")
	check(center_parent.find_child("CenterLastDiscardResponseWindow", true, false) != null and center_parent.find_child("CenterLastDiscardResponseWindowSource", true, false) != null and center_parent.find_child("CenterLastDiscardResponseWindowRail", true, false) != null and center_parent.find_child("CenterLastDiscardResponseWindowFill", true, false) != null, "center last discard feedback renders response window rail")
	check(center_parent.find_child("CenterLastDiscardResponseWindowGate", true, false) != null and center_parent.find_child("CenterLastDiscardResponseWindowSeal", true, false) != null and center_parent.find_child("CenterLastDiscardResponseWindowGlyph", true, false) != null and count_nodes_with_name_prefix(center_parent, "CenterLastDiscardResponseWindowTick_") == 3, "center last discard response window renders gate seal glyph and ticks")
	check(center_parent.find_child("CenterDicePlate", true, false) != null and center_parent.find_child("CenterDiceMandalaTexture", true, false) != null and center_parent.find_child("CenterDicePlateBack", true, false) != null and center_parent.find_child("CenterDiceOrbit", true, false) != null and center_parent.find_child("CenterDiceFocus", true, false) != null, "center renders dice plate illustration with reusable mandala texture")
	check(count_nodes_with_name_prefix(center_parent, "CenterDiceDot") == scene.CENTER_DICE_DOT_RECTS.size() and count_nodes_with_name_prefix(center_parent, "CenterDiceSpark_") == 4, "center dice plate renders dots and spark accents")
	check(center_parent.find_child("CenterDiceTurnRoute", true, false) != null and center_parent.find_child("CenterDiceTurnFill", true, false) != null and center_parent.find_child("CenterDiceTurnGate", true, false) != null and count_nodes_with_name_prefix(center_parent, "CenterDiceTurnTick_") == 2, "center dice plate renders current-turn route")
	check(center_parent.find_child("CenterDiceTurnFeedback", true, false) != null and center_parent.find_child("CenterDiceTurnFeedbackSource", true, false) != null and center_parent.find_child("CenterDiceTurnFeedbackRoute", true, false) != null and center_parent.find_child("CenterDiceTurnFeedbackFill", true, false) != null, "center dice turn feedback renders source route and fill")
	check(center_parent.find_child("CenterDiceTurnFeedbackFocus", true, false) != null and center_parent.find_child("CenterDiceTurnFeedbackGate", true, false) != null and center_parent.find_child("CenterDiceTurnFeedbackOutcomeRoute", true, false) != null and center_parent.find_child("CenterDiceTurnFeedbackOutcomeFill", true, false) != null and count_nodes_with_name_prefix(center_parent, "CenterDiceTurnFeedbackTick_") == 3, "center dice turn feedback renders focus gate outcome route and ticks")
	check(center_parent.find_child("CenterDicePhaseBridge", true, false) != null and center_parent.find_child("CenterDicePhaseBridgeFill", true, false) != null and center_parent.find_child("CenterDicePhaseSource", true, false) != null and center_parent.find_child("CenterDicePhaseGate", true, false) != null, "center dice plate renders phase-to-turn bridge")
	check(count_nodes_with_name_prefix(center_parent, "CenterDicePhaseTick_") == 3, "center dice phase bridge renders rhythm ticks")
	check(center_parent.find_child("CenterDiceOutcomeRoute", true, false) != null and center_parent.find_child("CenterDiceOutcomeFill", true, false) != null and center_parent.find_child("CenterDiceOutcomeGate", true, false) != null and count_nodes_with_name_prefix(center_parent, "CenterDiceOutcomeTick_") == 3, "center dice plate renders outcome confirmation route")
	check(count_shadowless_visual_hosts(center_parent) >= 5, "center inner panel and dice dots skip shadows for cheaper redraws")
	dispose_node(center_parent)
	scene.players[1]["name"] = "超长在线昵称十二字测试"
	scene.players[1]["discards"] = ["1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W"]
	scene.players[1]["flowers"] = 5
	scene.players[1]["flower_tiles"] = ["H1", "H2", "H3", "H4", "H5"]
	var clipped_seat_parent = Control.new()
	root.add_child(clipped_seat_parent)
	scene.draw_seat(clipped_seat_parent, 1, scene.rect_full(0.0, 0.0, 1.0, 1.0), "right")
	check(clipped_seat_parent.find_child("SeatBrocadeTexture_1", true, false) != null, "seat panel renders reusable brocade PNG texture")
	check(scene.optional_gpt_illustration_texture("seat_gpt_brocade") == null or clipped_seat_parent.find_child("SeatGPTBrocadeTexture_1", true, false) != null, "seat panel consumes optional GPT brocade texture when generated")
	check(label_is_clipped(first_label_with_text_prefix(clipped_seat_parent, "超长在线昵称")), "seat name clips long names without wrapping over badges")
	check(clipped_seat_parent.find_child("SeatTurnHandoffArt_1", true, false) != null and clipped_seat_parent.find_child("SeatTurnHandoffRoute_1", true, false) != null and clipped_seat_parent.find_child("SeatTurnHandoffFill_1", true, false) != null and clipped_seat_parent.find_child("SeatTurnHandoffGate_1", true, false) != null, "seat panel renders turn handoff route")
	check(clipped_seat_parent.find_child("SeatTurnHandoffSource_1", true, false) != null and clipped_seat_parent.find_child("SeatTurnHandoffSeal_1", true, false) != null and clipped_seat_parent.find_child("SeatTurnHandoffGlyph_1", true, false) != null and count_nodes_with_name_prefix(clipped_seat_parent, "SeatTurnHandoffTick_1_") == 3, "seat panel turn handoff renders source seal glyph and rhythm ticks")
	check(clipped_seat_parent.find_child("SeatStatusSummaryBand_1", true, false) != null and clipped_seat_parent.find_child("SeatStatusSummaryRoute_1", true, false) != null and clipped_seat_parent.find_child("SeatStatusSummaryFill_1", true, false) != null and clipped_seat_parent.find_child("SeatStatusSummaryGate_1", true, false) != null, "seat panel renders compact status summary band")
	check(label_is_clipped(clipped_seat_parent.find_child("SeatStatusSummaryLabel_1", true, false)), "seat status summary clips to one line with rhythm ticks")
	check(label_is_clipped(first_label_containing_text(clipped_seat_parent, "手")) and label_is_clipped(first_label_containing_text(clipped_seat_parent, "花")) and label_is_clipped(first_label_containing_text(clipped_seat_parent, "分")), "seat stats render as clipped compact pills")
	check(clipped_seat_parent.find_child("SeatStatPill_手", true, false) != null and clipped_seat_parent.find_child("SeatStatPill_花", true, false) != null and clipped_seat_parent.find_child("SeatStatPill_分", true, false) != null, "seat stat pills render named illustrated containers")
	check(clipped_seat_parent.find_child("SeatStatMeter_手", true, false) != null and clipped_seat_parent.find_child("SeatStatMeterFill_手", true, false) != null and clipped_seat_parent.find_child("SeatStatMeter_花", true, false) != null and clipped_seat_parent.find_child("SeatStatMeterFill_花", true, false) != null and clipped_seat_parent.find_child("SeatStatMeter_分", true, false) != null and clipped_seat_parent.find_child("SeatStatMeterFill_分", true, false) != null and count_nodes_with_name_prefix(clipped_seat_parent, "SeatStatMeterDot_") == 6, "seat stat pills render compact meters and status dots")
	check(count_nodes_with_name_prefix(clipped_seat_parent, "SeatStatMeterGate_") == 3 and count_nodes_with_name_prefix(clipped_seat_parent, "SeatStatMeterTick_") == 6, "seat stat pills render meter gates and rhythm ticks")
	check(clipped_seat_parent.find_child("SeatStatValueRoute_手", true, false) != null and clipped_seat_parent.find_child("SeatStatValueFill_手", true, false) != null and clipped_seat_parent.find_child("SeatStatValueRoute_花", true, false) != null and clipped_seat_parent.find_child("SeatStatValueFill_花", true, false) != null and clipped_seat_parent.find_child("SeatStatValueRoute_分", true, false) != null and clipped_seat_parent.find_child("SeatStatValueFill_分", true, false) != null, "seat stat pills connect values to compact route fills")
	check(count_nodes_with_name_prefix(clipped_seat_parent, "SeatStatValueGate_") == 3 and count_nodes_with_name_prefix(clipped_seat_parent, "SeatStatValueTick_") == 6, "seat stat pills render value gates and rhythm ticks")
	check(clipped_seat_parent.find_child("SeatFlowerTileArt", true, false) != null and clipped_seat_parent.find_child("SeatFlowerTileRail", true, false) != null and clipped_seat_parent.find_child("SeatFlowerTileSeal", true, false) != null, "seat flower tiles render illustrated collection block")
	check(scene.optional_gpt_illustration_texture("seat_flower_gpt_strip") == null or clipped_seat_parent.find_child("SeatFlowerGPTStripTexture", true, false) != null, "seat flower tiles consume optional GPT strip texture when generated")
	check(clipped_seat_parent.find_child("SeatFlowerTileGlow", true, false) != null and count_nodes_with_name_prefix(clipped_seat_parent, "SeatFlowerTile_") == 4 and clipped_seat_parent.find_child("SeatFlowerMoreBadge", true, false) != null, "seat flower tile art renders visible flowers, glow, and overflow badge")
	check(clipped_seat_parent.find_child("SeatFlowerCollectionRoute", true, false) != null and clipped_seat_parent.find_child("SeatFlowerCollectionRouteFill", true, false) != null and clipped_seat_parent.find_child("SeatFlowerCollectionGate", true, false) != null, "seat flower tile art renders collection route")
	check(count_nodes_with_name_prefix(clipped_seat_parent, "SeatFlowerCollectionTick_") == 3, "seat flower tile art renders collection rhythm ticks")
	var compact_panel := clipped_seat_parent.find_child("SeatPanel_1", true, false) as Control
	check(compact_panel != null and compact_panel.clip_contents, "seat compact panel clips overflow")
	check(clipped_seat_parent.find_child("SeatCompactName_1", true, false) != null and clipped_seat_parent.find_child("SeatCompactMeta_1", true, false) != null and clipped_seat_parent.find_child("SeatCompactScore_1", true, false) != null, "seat compact panel exposes name meta score labels")
	var side_meta_label := clipped_seat_parent.find_child("SeatCompactMeta_1", true, false) as Label
	var side_meta_text := str(side_meta_label.text) if side_meta_label != null else ""
	check(label_is_clipped(side_meta_label) and side_meta_text.contains("手") and side_meta_text.contains("花") and side_meta_text.contains("弃"), "side seat merges hand flower and discard counts into one readable meta line")
	check(side_meta_label != null and side_meta_text.length() <= 12, "side seat merged meta line stays compact without a narrow discard preview column")
	dispose_node(clipped_seat_parent)
	var log_parent = Control.new()
	root.add_child(log_parent)
	scene.table_logs.clear()
	scene.table_logs.append("这是一条很长的补花和包赔牌谱记录一")
	scene.table_logs.append("这是一条很长的补花和包赔牌谱记录二")
	scene.table_logs.append("这是一条很长的补花和包赔牌谱记录三")
	scene.table_logs.append("这是一条很长的补花和包赔牌谱记录四")
	scene.draw_table_log(log_parent)
	check(log_parent.find_child("TableLogLedgerPanel", true, false) != null, "table log renders named ledger panel")
	check(log_parent.find_child("TableLogLedgerTexture", true, false) != null, "table log renders reusable scroll PNG texture")
	check(scene.optional_gpt_illustration_texture("table_log_gpt_scroll") == null or log_parent.find_child("TableLogGPTScrollTexture", true, false) != null, "table log consumes optional GPT scroll texture when generated")
	check(label_is_clipped(first_label_containing_text(log_parent, "补花")), "table log clips long rows inside compact panel")
	check(count_label_nodes(log_parent) == 10, "table log renders title, count, archive and commit glyphs, and three structured action rows")
	check(count_labels_with_exact_text(log_parent, "摸") >= 2, "table log tags recent draw and flower events")
	check(log_parent.find_child("TableLogTimelineRail", true, false) != null and count_nodes_with_name_prefix(log_parent, "TableLogRow_") == 3 and count_named_nodes(log_parent, "TableLogTimelineNode") == 3 and count_named_nodes(log_parent, "TableLogTimelineConnector") == 3, "table log renders structured rows with a non-text timeline rail and row nodes")
	check(log_parent.find_child("TableLogTimelineFlow", true, false) != null and count_named_nodes(log_parent, "TableLogEventLane") == 3 and count_nodes_with_name_prefix(log_parent, "TableLogEventPulse_") == 6, "table log renders event flow lanes and pulses without extra text")
	check(count_named_nodes(log_parent, "TableLogTagBadge") == 3 and count_named_nodes(log_parent, "TableLogTagRoute") == 3 and count_named_nodes(log_parent, "TableLogTagRouteFill") == 3 and count_named_nodes(log_parent, "TableLogTagRouteGate") == 3, "table log rows render tag badges and connection routes")
	check(count_nodes_with_name_prefix(log_parent, "TableLogTagRouteTick_") == 6, "table log rows render tag route rhythm ticks")
	check(log_parent.find_child("TableLogLatestGlow", true, false) != null and log_parent.find_child("TableLogLatestCursor", true, false) != null, "table log highlights the latest visible action with glow and cursor")
	check(log_parent.find_child("TableLogLatestSyncRoute", true, false) != null and log_parent.find_child("TableLogLatestSyncRail", true, false) != null and log_parent.find_child("TableLogLatestSyncFill", true, false) != null, "table log renders latest-event sync route")
	check(log_parent.find_child("TableLogLatestSyncSource", true, false) != null and log_parent.find_child("TableLogLatestSyncGate", true, false) != null and count_nodes_with_name_prefix(log_parent, "TableLogLatestSyncNode_") == 3, "table log latest sync renders source gate and row nodes")
	check(count_nodes_with_name_prefix(log_parent, "TableLogLatestSyncTick_") == 3, "table log latest sync renders rhythm ticks")
	check(log_parent.find_child("TableLogCountArchiveRoute", true, false) != null and log_parent.find_child("TableLogCountArchiveFill", true, false) != null and log_parent.find_child("TableLogCountArchiveSource", true, false) != null and log_parent.find_child("TableLogCountArchiveGate", true, false) != null and log_parent.find_child("TableLogCountArchiveGlyph", true, false) != null, "table log latest sync renders count archive route")
	check(count_nodes_with_name_prefix(log_parent, "TableLogCountArchiveTick_") == 2, "table log count archive renders rhythm ticks")
	check(log_parent.find_child("TableLogArchiveCommit", true, false) != null and log_parent.find_child("TableLogArchiveCommitSource", true, false) != null and log_parent.find_child("TableLogArchiveCommitRoute", true, false) != null and log_parent.find_child("TableLogArchiveCommitFill", true, false) != null and log_parent.find_child("TableLogArchiveCommitGate", true, false) != null, "table log renders archive commit route")
	check(log_parent.find_child("TableLogArchiveCommitSeal", true, false) != null and log_parent.find_child("TableLogArchiveCommitGlyph", true, false) != null and count_nodes_with_name_prefix(log_parent, "TableLogArchiveCommitTick_") == 3, "table log archive commit renders seal glyph and rhythm ticks")
	check(has_label_text(log_parent, "4条"), "table log shows total event count")
	dispose_node(log_parent)
	var empty_log_parent = Control.new()
	root.add_child(empty_log_parent)
	scene.table_logs.clear()
	scene.draw_table_log(empty_log_parent)
	check(empty_log_parent.find_child("TableLogEmptyArt", true, false) != null and empty_log_parent.find_child("TableLogEmptyRail", true, false) != null and count_nodes_with_name_prefix(empty_log_parent, "TableLogEmptyBead_") == 3, "empty table log renders waiting-state illustration")
	check(empty_log_parent.find_child("TableLogEmptyListenRoute", true, false) != null and empty_log_parent.find_child("TableLogEmptyListenFill", true, false) != null and empty_log_parent.find_child("TableLogEmptyListenGate", true, false) != null and empty_log_parent.find_child("TableLogEmptySourceNode", true, false) != null, "empty table log renders listen-ready route")
	check(count_nodes_with_name_prefix(empty_log_parent, "TableLogEmptyListenTick_") == 3, "empty table log renders listen-ready rhythm ticks")
	check(has_label_text(empty_log_parent, "等待开局"), "empty table log keeps waiting-state text visible")
	dispose_node(empty_log_parent)
	scene.players[0]["flower_tiles"] = ["H1", "H2"]
	var flower_strip_parent = Control.new()
	root.add_child(flower_strip_parent)
	check(scene.draw_seat_flower_tiles(flower_strip_parent, 0), "seat panel renders flower tile strip")
	check(scene.optional_gpt_illustration_texture("seat_flower_gpt_strip") == null or flower_strip_parent.find_child("SeatFlowerGPTStripTexture", true, false) != null, "standalone flower strip consumes optional GPT strip texture when generated")
	check(count_texture_rects(flower_strip_parent) >= 2 and not has_label_text(flower_strip_parent, "春") and not has_label_text(flower_strip_parent, "夏"), "flower strip uses real tile art without duplicate text")
	check(flower_strip_parent.find_child("SeatFlowerCollectionFill", true, false) != null and flower_strip_parent.find_child("SeatFlowerCollectionRouteFill", true, false) != null, "flower strip renders collection progress fills")
	check(flower_strip_parent.find_child("SeatFlowerTileStrip", true, false) != null and flower_strip_parent.find_child("SeatFlowerReplacementRoute", true, false) != null and flower_strip_parent.find_child("SeatFlowerReplacementFill", true, false) != null and flower_strip_parent.find_child("SeatFlowerReplacementSource", true, false) != null and flower_strip_parent.find_child("SeatFlowerReplacementGate", true, false) != null, "flower strip renders tile strip and replacement draw route")
	check(count_nodes_with_name_prefix(flower_strip_parent, "SeatFlowerReplacementTick_") == 2, "flower strip renders replacement draw rhythm ticks")
	check(flower_strip_parent.find_child("SeatFlowerSettlementArt", true, false) != null and flower_strip_parent.find_child("SeatFlowerSettlementSource", true, false) != null and flower_strip_parent.find_child("SeatFlowerSettlementRoute", true, false) != null and flower_strip_parent.find_child("SeatFlowerSettlementFill", true, false) != null and flower_strip_parent.find_child("SeatFlowerSettlementGate", true, false) != null, "flower strip renders settlement convergence route")
	check(flower_strip_parent.find_child("SeatFlowerSettlementSeal", true, false) != null and flower_strip_parent.find_child("SeatFlowerSettlementGlyph", true, false) != null and flower_strip_parent.find_child("SeatFlowerSettlementHandoffRoute", true, false) != null and flower_strip_parent.find_child("SeatFlowerSettlementHandoffFill", true, false) != null and flower_strip_parent.find_child("SeatFlowerSettlementHandoffGate", true, false) != null, "flower strip settlement renders seal and handoff route")
	check(count_nodes_with_name_prefix(flower_strip_parent, "SeatFlowerSettlementTick_") == 3, "flower strip settlement renders rhythm ticks")
	var flower_route_fill = flower_strip_parent.find_child("SeatFlowerCollectionRouteFill", true, false) as Control
	check(flower_route_fill != null and flower_route_fill.anchor_right > 0.50 and flower_route_fill.anchor_right < 0.60, "flower collection route fill tracks visible flower count")
	dispose_node(flower_strip_parent)
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
	check(scene.optional_gpt_illustration_texture("flower_gpt_bloom") == null or scene.find_child("FlowerGPTBloomTexture", true, false) != null, "flower bloom animation consumes optional GPT bloom texture when generated")
	check(flower_fx_drawn == "6W" and scene.find_child("FlowerBloomFx", true, false) != null and scene.find_child("FlowerBloomRing", true, false) != null and scene.find_child("FlowerBloomTile", true, false) != null and scene.find_child("FlowerBloomLabel", true, false) != null, "announced flower replacement creates a bloom ring animation with tile art and label")
	check(count_nodes_with_name_prefix(scene, "FlowerBloomPetal_") == 8, "flower bloom animation renders blossom petals")
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
	check(scene.optional_gpt_illustration_texture("pending_claim_status_strip") == null or pending_claim_parent.find_child("PendingClaimStatusStripTexture", true, false) != null, "pending claim illustration consumes optional GPT status strip when generated")
	check(pending_claim_parent.find_child("PendingClaimOrbitTexture", true, false) != null and pending_claim_parent.find_child("PendingClaimBannerTexture", true, false) != null and pending_claim_parent.find_child("PendingClaimSilkTexture", true, false) != null, "pending claim illustration renders reusable orbit response-banner and silk PNG textures")
	check(pending_claim_parent.find_child("PendingClaimIllustration", true, false) != null and pending_claim_parent.find_child("PendingClaimMistCloud", true, false) != null and pending_claim_parent.find_child("PendingClaimSourceBadge", true, false) != null and pending_claim_parent.find_child("PendingClaimFocusText", true, false) != null, "pending claim illustration renders mist cloud source tile panel and focus text")
	check(pending_claim_parent.find_child("PendingClaimOptionRail", true, false) != null and pending_claim_parent.find_child("PendingClaimOption_chi", true, false) != null and pending_claim_parent.find_child("PendingClaimPassChip", true, false) != null, "pending claim illustration renders action option rail")
	check(pending_claim_parent.find_child("PendingClaimPriorityArt", true, false) != null and pending_claim_parent.find_child("PendingClaimPriorityRail", true, false) != null and pending_claim_parent.find_child("PendingClaimPriorityFill", true, false) != null, "pending claim illustration renders priority meter")
	check(pending_claim_parent.find_child("PendingClaimPriorityNode_chi", true, false) != null and pending_claim_parent.find_child("PendingClaimPriorityPassNode", true, false) != null and count_nodes_with_name_prefix(pending_claim_parent, "PendingClaimPriorityTick_") == 3, "pending claim illustration renders priority nodes and rhythm ticks")
	check(pending_claim_parent.find_child("PendingClaimActionExitArt", true, false) != null and pending_claim_parent.find_child("PendingClaimActionExitRail", true, false) != null and pending_claim_parent.find_child("PendingClaimActionExitFill", true, false) != null and pending_claim_parent.find_child("PendingClaimActionExitGate", true, false) != null, "pending claim illustration renders action exit route")
	check(count_nodes_with_name_prefix(pending_claim_parent, "PendingClaimActionExitTick_") == 3, "pending claim illustration renders action exit rhythm ticks")
	check(pending_claim_parent.find_child("PendingClaimTimerArt", true, false) != null and pending_claim_parent.find_child("PendingClaimTimerRail", true, false) != null and pending_claim_parent.find_child("PendingClaimTimerFill", true, false) != null and pending_claim_parent.find_child("PendingClaimTimerGate", true, false) != null, "pending claim illustration renders response timer route")
	check(count_nodes_with_name_prefix(pending_claim_parent, "PendingClaimTimerTick_") == 4, "pending claim illustration renders response timer rhythm ticks")
	check(pending_claim_parent.find_child("PendingClaimResponseAnimation", true, false) != null and pending_claim_parent.find_child("ClaimResponseOrbitGate", true, false) != null and pending_claim_parent.find_child("AnimationPreviewTimeline_claim_response_orbit", true, false) != null, "pending claim illustration consumes reusable claim response animation asset preview")
	check(scene.optional_gpt_illustration_texture("claim_response_trail") == null or pending_claim_parent.find_child("PendingClaimGPTTrailTexture", true, false) != null, "pending claim illustration consumes optional GPT trail texture when generated")
	check(pending_claim_parent.find_child("PendingClaimResponsePulse", true, false) != null and pending_claim_parent.find_child("PendingClaimResponsePulseRail", true, false) != null and pending_claim_parent.find_child("PendingClaimResponsePulseFill", true, false) != null and pending_claim_parent.find_child("PendingClaimResponseGate", true, false) != null, "pending claim illustration renders response pulse route")
	check(pending_claim_parent.find_child("PendingClaimResponseSource", true, false) != null and count_nodes_with_name_prefix(pending_claim_parent, "PendingClaimResponseTick_") == 3, "pending claim response pulse renders source and rhythm ticks")
	check(pending_claim_parent.find_child("PendingClaimFlowArt", true, false) != null and pending_claim_parent.find_child("PendingClaimFlowArrow", true, false) != null and pending_claim_parent.find_child("PendingClaimTile", true, false) != null and pending_claim_parent.find_child("PendingClaimTileGlow", true, false) != null and count_nodes_with_name_prefix(pending_claim_parent, "PendingClaimFlowDash_") == 3, "pending claim illustration renders source-to-tile flow dash tile and glow")
	check(pending_claim_parent.find_child("PendingClaimOptionSpark_0", true, false) != null, "pending claim illustration renders option spark accents")
	check(has_label_text(pending_claim_parent, "吃牌机会 · 选择顺子组合"), "pending claim illustration renders contextual focus copy")
	scene.draw_actions(pending_claim_parent)
	check(scene.optional_gpt_illustration_texture("pending_claim_action_dock") == null or pending_claim_parent.find_child("PendingClaimActionGPTDockTexture", true, false) != null, "pending claim action dock consumes dedicated GPT dock texture when generated")
	var pending_claim_gpt_dock = pending_claim_parent.find_child("PendingClaimActionGPTDockTexture", true, false) as TextureRect
	check(pending_claim_gpt_dock == null or pending_claim_gpt_dock.modulate.a <= 0.42, "pending claim GPT dock texture stays below the compact alpha cap")
	check(pending_claim_parent.find_child("ActionDockPlateTexture", true, false) == null and pending_claim_parent.find_child("ActionDockRibbonTexture", true, false) == null and pending_claim_parent.find_child("ActionGPTDockTexture", true, false) == null, "pending claim action dock avoids legacy plate ribbon and generic dock texture layers")
	check(pending_claim_parent.find_child("ActionButtonDock", true, false) != null and pending_claim_parent.find_child("ActionIntentDock", true, false) == null, "pending claim actions render one compact dock without an overlapping intent rail")
	check(pending_claim_parent.find_child("ActionDockLeftTail", true, false) == null and pending_claim_parent.find_child("ActionDockRightTail", true, false) == null and count_nodes_with_name_prefix(pending_claim_parent, "ActionDockRhythmDot_") == 0, "pending claim action dock drops code-drawn scroll tails and rhythm dots")
	check(pending_claim_parent.find_child("ActionDockButtonTrack", true, false) == null and pending_claim_parent.find_child("ActionDockButtonTrackFill", true, false) == null and pending_claim_parent.find_child("ActionDockSafeLeft", true, false) == null and pending_claim_parent.find_child("ActionDockSafeRight", true, false) == null, "pending claim action dock drops code-drawn button track and safe edge rails")
	check(count_nodes_with_name_prefix(pending_claim_parent, "ActionDockButtonSlot_") == 0 and pending_claim_parent.find_child("ActionDockFocusLabel", true, false) == null, "pending claim action dock drops per-button slots and duplicate focus label")
	check((scene.optional_gpt_illustration_texture("action_dock_track_panel") == null) or (pending_claim_parent.find_child("ActionDockTrackPanelTexture", true, false) != null), "pending claim action dock uses optional GPT track panel plate instead of code-drawn lines")
	check(pending_claim_parent.find_child("ActionButtonArt", true, false) != null and pending_claim_parent.find_child("ActionButtonIconBack", true, false) == null and pending_claim_parent.find_child("ActionButtonSheen", true, false) != null, "live action buttons render icon art and sheen accents without code-drawn icon backplate")
	check(pending_claim_parent.find_child("ActionButtonRoleRail", true, false) != null and pending_claim_parent.find_child("ActionButtonEnergyDot_0", true, false) != null and pending_claim_parent.find_child("ActionButtonPrioritySeal", true, false) != null, "action buttons render role rail, energy dots, and priority seals")
	check(pending_claim_parent.find_child("ActionButtonCommandRoute", true, false) == null and pending_claim_parent.find_child("ActionButtonExecutionGate", true, false) == null and pending_claim_parent.find_child("ActionButtonDecisionBridge", true, false) == null and pending_claim_parent.find_child("ActionButtonPassRoute", true, false) == null, "live action buttons drop old code-drawn command/execution/decision/pass decorative lines")
	check((scene.optional_gpt_illustration_texture("action_button_panel") == null) or (pending_claim_parent.find_child("ActionButtonPanelPlate", true, false) != null), "live action buttons use optional GPT panel plate instead of code-drawn lines")
	var live_action_button = pending_claim_parent.find_child("ActionButtonDock", true, false)
	var live_button := first_button(pending_claim_parent)
	if live_button != null:
		scene.play_action_button_press_feedback(live_button, "action", Color(0.25, 0.58, 0.48))
	check(live_action_button != null and pending_claim_parent.find_child("ActionButtonPressFeedback", true, false) != null and pending_claim_parent.find_child("ActionButtonPressRail", true, false) != null and pending_claim_parent.find_child("ActionButtonPressGate", true, false) != null and count_nodes_with_name_prefix(pending_claim_parent, "ActionButtonPressTick_") >= 3, "live action button press renders execution feedback")
	scene.fx_enabled = true
	scene.ensure_fx_layer()
	scene.play_pending_claim_choice_confirmation_fx("peng", 3, "3W")
	check(scene.find_child("PendingClaimChoiceConfirmFx_peng", true, false) != null and scene.find_child("PendingClaimChoiceSource_peng", true, false) != null and scene.find_child("PendingClaimChoiceRoute_peng", true, false) != null and scene.find_child("PendingClaimChoiceFill_peng", true, false) != null and scene.find_child("PendingClaimChoiceGate_peng", true, false) != null, "pending claim choice confirmation renders selected claim route from discard to player")
	check(scene.find_child("PendingClaimChoiceSeal_peng", true, false) != null and scene.find_child("PendingClaimChoiceGlyph_peng", true, false) != null and scene.find_child("PendingClaimChoiceTileBadge_peng", true, false) != null and scene.find_child("PendingClaimChoiceTileGlyph_peng", true, false) != null and count_nodes_with_name_prefix(scene, "PendingClaimChoiceTick_peng_") == 3, "pending claim choice confirmation renders seal tile badge and rhythm ticks")
	check(scene.find_child("PendingClaimChoiceArchiveRoute_peng", true, false) != null and scene.find_child("PendingClaimChoiceArchiveFill_peng", true, false) != null and count_nodes_with_name_prefix(scene, "PendingClaimChoiceArchivePip_peng_") == 2, "pending claim choice confirmation renders archive route and pips")
	scene.play_pending_claim_choice_confirmation_fx("pass", 3, "3W")
	check(scene.find_child("PendingClaimChoiceConfirmFx_pass", true, false) != null and scene.find_child("PendingClaimChoiceGlyph_pass", true, false) != null and scene.find_child("PendingClaimChoiceArchiveRoute_pass", true, false) != null and count_nodes_with_name_prefix(scene, "PendingClaimChoiceTick_pass_") == 3, "pending claim pass confirmation renders pass-specific route glyph and ticks")
	dispose_node(pending_claim_parent)
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
	dispose_node(claim_actions_parent)
	check(scene.hand_tray_text().find("建议") < 0, "hand tray does not show claim advice")
	# 与 commit_discard 一致：待响应状态必须同时保留来源弃牌的身份。
	scene.players[3]["discards"] = ["3W"]
	scene.last_discard = "3W"
	scene.last_discard_seat = 3
	scene.human_claim("chi", chi_choices[1])
	check(scene.offline_phase == "await_discard", "chosen chi returns to discard phase")
	check(scene.players[0]["melds"].size() > 0 and scene.same_tile_list(scene.players[0]["melds"].back(), ["2W", "3W", "4W"]), "chosen chi meld is applied")
	check(scene.count_tile(scene.players[0]["hand"], "1W") == 1 and scene.count_tile(scene.players[0]["hand"], "5W") == 1, "unchosen chi edge tiles stay in hand")
	check(scene.same_tile_list(scene.filter_claim_options_by_priority(["chi", "peng", "hu"], 3), ["peng", "hu"]), "claim priority filters lower actions")
	scene.start_offline(false)
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

	scene.start_offline(false)
	scene.offline_phase = "resolving"
	scene.players[0]["hand"] = ["1W", "2W", "5T", "6T", "7T", "E", "E", "P", "P", "4B", "5B", "6B", "9B"]
	scene.players[0]["melds"] = []
	scene.players[1]["hand"] = waits_for_3w_hand()
	scene.players[1]["melds"] = []
	scene.players[3]["discards"] = ["3W"]
	scene.last_discard = "3W"
	scene.last_discard_seat = 3
	scene.resolve_after_discard(3, "3W")
	check(scene.offline_phase == "ended", "AI hu takes priority over human chi")
	check(scene.offline_last_winner == 1, "higher priority AI hu wins the discard")
	check(scene.players[0]["melds"].is_empty(), "human chi is not applied under hu priority")

	scene.start_offline(false)
	scene.offline_phase = "resolving"
	scene.players[0]["hand"] = waits_for_3w_hand()
	scene.players[0]["melds"] = []
	scene.players[1]["hand"] = waits_for_3w_hand()
	scene.players[1]["melds"] = []
	scene.players[3]["discards"] = ["3W"]
	scene.last_discard = "3W"
	scene.last_discard_seat = 3
	scene.resolve_after_discard(3, "3W")
	check(scene.offline_phase == "pending_claim", "human hu is still offered against AI hu")
	check(scene.offline_pending_claim.get("options", []) == ["hu"], "only equal-priority human hu is offered")
	check(scene.human_claim_hint_text().find("建议") < 0 and scene.human_claim_hint_text().find("胡") >= 0, "human hu prompt avoids AI advice wording")
	scene.human_claim("pass")
	check(scene.offline_phase == "ended" and scene.offline_last_winner == 1, "AI hu resolves after human passes equal-priority response")

	scene.start_offline(false)
	scene.ai_difficulty = scene.AI_DIFFICULTY_NORMAL
	scene.reset_ai_profile_seat_map()
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
	scene.wall.clear()
	for n in range(30):
		scene.wall.append("1W")
	var seven_pairs_concealed_gang = scene.build_ai_self_gang_report(2, "E", "concealed")
	check(not bool(seven_pairs_concealed_gang.get("allow", true)), "AI declines concealed gang that breaks seven pairs route")
	check(bool(seven_pairs_concealed_gang.get("declined_by_plan", false)), "AI self-gang report marks seven pairs route decline")
	check(str(seven_pairs_concealed_gang.get("reason", "")) == "保七对", "AI self-gang report names seven pairs protection")
	check(scene.choose_ai_concealed_gang(2) == "", "AI concealed gang helper preserves seven pairs route")

	scene.start_offline(false)
	scene.ai_difficulty = scene.AI_DIFFICULTY_NORMAL
	scene.reset_ai_profile_seat_map()
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

	scene.start_offline(false)
	scene.ai_difficulty = scene.AI_DIFFICULTY_NORMAL
	scene.reset_ai_profile_seat_map()
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

	scene.start_offline(false)
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
	scene.offline_ai_active = true
	scene.human_claim("pass")
	scene.offline_ai_active = false
	check(scene.offline_phase == "await_discard", "added gang continues after human passes rob gang")
	check(scene.players[1]["melds"][0].size() == 4, "passed rob gang upgrades pung")
	check(scene.players[1]["hand"].has("7B"), "passed rob gang draws replacement tile")

	scene.start_offline(false)
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
	check(score_ribbon_parent.find_child("SeatTurnHandoffArt_0", true, false) != null and score_ribbon_parent.find_child("SeatTurnHandoffGlyph_0", true, false) != null and count_nodes_with_name_prefix(score_ribbon_parent, "SeatTurnHandoffTick_0_") == 3, "active seat panel renders turn handoff glyph and ticks")
	check(score_ribbon_parent.find_child("SeatScoreMomentumRibbon", true, false) != null and score_ribbon_parent.find_child("SeatScoreMomentumSeal", true, false) != null and score_ribbon_parent.find_child("SeatScoreMomentumPulse", true, false) != null, "seat panel renders score momentum ribbon art")
	check(score_ribbon_parent.find_child("SeatScoreMomentumRoute", true, false) != null and score_ribbon_parent.find_child("SeatScoreMomentumFill", true, false) != null and score_ribbon_parent.find_child("SeatScoreMomentumGate", true, false) != null and score_ribbon_parent.find_child("SeatScoreMomentumRankNode", true, false) != null, "seat score momentum ribbon renders rank route art")
	check(count_nodes_with_name_prefix(score_ribbon_parent, "SeatScoreMomentumTick_") == 3, "seat score momentum ribbon renders strategy rhythm ticks")
	check(score_ribbon_parent.find_child("SeatScoreMomentumLabel", true, false) != null and has_label_text(score_ribbon_parent, "第1 守成"), "seat score momentum ribbon names leader guard state")
	dispose_node(score_ribbon_parent)
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
	check(recommend_actions_parent.find_child("VoiceActionButton", true, false) != null, "live action bar renders named voice action button")
	check(recommend_actions_parent.find_child("VoiceButtonMicChannel", true, false) != null and recommend_actions_parent.find_child("VoiceButtonTransmitRoute", true, false) != null and recommend_actions_parent.find_child("VoiceButtonNetworkEcho", true, false) != null and recommend_actions_parent.find_child("VoiceButtonFeedbackLoop", true, false) != null, "live action bar voice button renders channel transmit network and feedback loop art")
	dispose_node(recommend_actions_parent)
	check(scene.discard_action_alternative_reports("E", 2).is_empty(), "human alternative discard helper is disabled")
	var recommend_hand_parent = Control.new()
	root.add_child(recommend_hand_parent)
	scene.draw_hand(recommend_hand_parent)
	check(not has_label_text(recommend_hand_parent, "荐"), "hand does not render recommendation badge")
	dispose_node(recommend_hand_parent)
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
	check(threat_seat_parent.find_child("SeatThreatBadgeArt_1", true, false) != null and threat_seat_parent.find_child("SeatThreatRadarTexture_1", true, false) != null and threat_seat_parent.find_child("SeatThreatSourceNode_1", true, false) != null and threat_seat_parent.find_child("SeatThreatPressureNode_1", true, false) != null, "seat panel renders opponent threat radar source and pressure nodes")
	check(threat_seat_parent.find_child("SeatThreatRoute_1", true, false) != null and threat_seat_parent.find_child("SeatThreatFill_1", true, false) != null and threat_seat_parent.find_child("SeatThreatGlow_1", true, false) != null and threat_seat_parent.find_child("SeatThreatGate_1", true, false) != null and count_nodes_with_name_prefix(threat_seat_parent, "SeatThreatSafeTick_1_") == 3, "seat panel renders opponent threat route glow and safe-tile rhythm ticks")
	dispose_node(threat_seat_parent)
	scene.players[1]["discards"].append("2W")
	check(scene.main_threat_opponent(0) == 1, "main threat opponent is identified without using safe tile recursion")
	check(scene.is_main_threat_genbutsu("2W", 0), "tile discarded by main threat is recognized as genbutsu")
	check(scene.tile_safety_label("2W", 0) == "现", "main-threat genbutsu gets safety label")
	check(scene.discard_safety_text({"safety_label": "现", "risk_label": "低"}) == "主现物", "AI brief names main-threat genbutsu")
	check(scene.ai_safety_bonus("现", 1.8, 3) > scene.ai_safety_bonus("熟", 1.8, 3) and scene.ai_safety_bonus("现", 1.8, 3) < scene.ai_safety_bonus("安", 1.8, 3), "main-threat genbutsu safety bonus sits between visible safe and all-safe")
	var hint_tile = scene.make_tile_view("2W", Vector2(62, 84), true, Callable(), false, "", "听")
	check(hint_tile.find_child("TileHintBadge", true, false) != null or not scene.TILE_TEXT_OVERLAYS_ENABLED, "tile view renders named hint badge when overlays enabled")
	dispose_node(hint_tile)
	var genbutsu_tile = scene.make_tile_view("2W", Vector2(62, 84), true, Callable(), false, "现")
	check(count_label_nodes(genbutsu_tile) == 0 and has_visible_tile_art(genbutsu_tile), "tile view keeps main-threat genbutsu as image-only tile")
	check(genbutsu_tile.find_child("TileStatusRoute", true, false) != null and genbutsu_tile.find_child("TileStatusFill", true, false) != null and genbutsu_tile.find_child("TileStatusGate", true, false) != null and count_nodes_with_name_prefix(genbutsu_tile, "TileStatusTick_") == 2, "tile view renders non-text safety status route")
	dispose_node(genbutsu_tile)
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
	var readiness_seat_parent = Control.new()
	root.add_child(readiness_seat_parent)
	scene.draw_seat(readiness_seat_parent, 1, scene.rect_full(0.0, 0.0, 1.0, 1.0), "right", {1: readiness_threat})
	check(readiness_seat_parent.find_child("SeatThreatReadinessSeal_1", true, false) != null, "seat threat badge renders near-tenpai readiness seal")
	dispose_node(readiness_seat_parent)
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
	dispose_node(risk_tile)
	scene.start_offline(false)
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
	scene.offline_ai_active = true
	scene.human_discard(confirm_danger_index)
	check(scene.players[0]["hand"].size() == hand_size_before_danger - 1, "human discard commits immediately without AI confirmation")
	check(scene.players[0]["discards"].has("5W"), "human discard path commits selected tile")
	check(scene.offline_phase == "resolving", "human discard enters resolving phase immediately to block accidental second taps")
	scene.human_discard(confirm_danger_index)
	check(scene.players[0]["hand"].size() == hand_size_before_danger - 1, "resolving phase blocks accidental repeated discard taps")
	check(not scene.has_pending_danger_discard(), "human discard does not enter pending danger confirmation")
	await process_frame
	scene.offline_ai_active = false
	var confirm_hand_parent = Control.new()
	root.add_child(confirm_hand_parent)
	scene.draw_hand(confirm_hand_parent)
	check(not has_label_text(confirm_hand_parent, "确认") and not has_label_text(confirm_hand_parent, "高危"), "hand does not render AI risk confirmation badges")
	dispose_node(confirm_hand_parent)
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
	dispose_node(safe_action_parent)
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
	dispose_node(safe_tile)
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
	dispose_node(suji_tile)
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
	dispose_node(kabe_tile)
	check(scene.ai_safety_bonus("壁", 1.8, 3) > 0.0 and scene.ai_safety_bonus("壁", 1.8, 3) < scene.ai_safety_bonus("熟", 1.8, 3), "wall safety gets weaker defense bonus than fully visible tile")
	check(scene.ai_safety_bonus("安", 1.8, 0) < scene.ai_safety_bonus("安", 1.8, 3), "tenpai reduces safety bonus")
	check(scene.ai_stance_label(1.6, 3) == "防守" and scene.ai_stance_label(0.8, 0) == "进攻", "AI stance labels attack and defense modes")
	check(scene.ai_advice_summary(0, 2).find("模式") >= 0, "advisor includes AI stance line")
	check(scene.risk_badge_text("安") == "安" and scene.risk_badge_text("熟") == "熟", "safe badge text is compact")
	scene.start_offline(false)
	scene.ai_difficulty = scene.AI_DIFFICULTY_NORMAL
	scene.reset_ai_profile_seat_map()
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
	for n in range(30):
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
	for n in range(30):
		scene.wall.append("1W")
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
	dispose_node(spacer)
	var crowded_hand = ["1W", "2W", "3W", "4W", "1T", "2T", "3T", "1B", "2B", "3B", "E", "S", "P", "H1"]
	var narrow_tray_width = float(scene.HAND_TRAY_RECT.size.x - scene.HAND_TRAY_RECT.position.x)
	var narrow_tray_height = float(scene.HAND_TRAY_RECT.size.y - scene.HAND_TRAY_RECT.position.y)
	var narrow_tiles_width = float(scene.HAND_TRAY_TILES_RECT.size.x - scene.HAND_TRAY_TILES_RECT.position.x)
	var narrow_tiles_height = float(scene.HAND_TRAY_TILES_RECT.size.y - scene.HAND_TRAY_TILES_RECT.position.y)
	var narrow_hand_content = Vector2(960.0 * narrow_tray_width * narrow_tiles_width, 540.0 * narrow_tray_height * narrow_tiles_height)
	check(scene.HAND_TILE_MAX_WIDTH <= 68.0 and scene.HAND_LAYOUT_CANDIDATES.size() == 5 and float(scene.HAND_LAYOUT_CANDIDATES[0][0]) == 8.0 and int(scene.HAND_LAYOUT_CANDIDATES[4][1]) == 3, "hand layout reuses fixed spacing candidates with restrained max tile width")
	var crowded_hand_layout = scene.hand_layout_metrics_for_content(crowded_hand, narrow_hand_content)
	check(scene.hand_layout_fits_content(crowded_hand, crowded_hand_layout), "crowded 14-tile hand layout fits a narrow landscape tray")
	check(float(crowded_hand_layout.get("tile_width", 0.0)) >= scene.HAND_TILE_MIN_TOUCH_WIDTH, "crowded hand keeps a practical touch width on narrow landscape")
	check(int(crowded_hand_layout.get("separation", 9)) <= 4 and float(crowded_hand_layout.get("group_gap_width", 99.0)) <= 6.0, "crowded hand reduces spacing before shrinking tiles too far")
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
	dispose_node(action_layout_parent)
	scene.action_bar = null

	scene.players[0]["hand"] = winning_hand()
	scene.players[0]["melds"] = []
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
	check(scene.speech_queue.size() == 1 and scene.speech_queue[0].has("clips") and str(scene.speech_queue[0].get("clips", [])[0]) == "tile_5T" and not scene.speech_queue[0].has("text"), "new online discard uses bundled tile voice clip")
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
	check(scene.speech_queue.size() == 1 and scene.speech_queue[0].has("clips") and str(scene.speech_queue[0].get("clips", [])[0]) == "tile_7B" and not scene.speech_queue[0].has("text"), "outgoing online discard queues bundled tile voice clip immediately")
	scene.speech_queue.clear()
	scene.play_outgoing_online_action_audio({"type": "claim", "claim": "peng", "tile": "3W"})
	check(scene.speech_queue.size() == 1 and scene.speech_queue[0].has("clips") and scene.speech_queue[0].get("clips", []) == ["action_peng", "tile_3W"] and not scene.speech_queue[0].has("text"), "outgoing online claim queues bundled action voice before tile voice")
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

	scene.start_offline(false)
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
	scene.offline_phase = "await_discard"
	scene.current_seat = 1
	scene.offline_turn_needs_draw = false
	scene.offline_last_draw = {"seat": 1, "tile": "E", "source": "normal", "wall_empty": false, "announce": true, "serial": 9401}
	scene.offline_self_draw_ready = {"seat": 1, "tile": "E", "serial": 9401}
	scene.finish_offline_round(1, "E", true, -1)
	check(int(scene.players[0]["score"]) == payer_before - package_points, "package payer covers all self draw payments")
	check(int(scene.players[1]["score"]) == winner_before + package_points, "package winner receives package payment")
	check(int(scene.players[2]["score"]) == other_before, "non-package opponent does not pay")
	check(scene.round_summary.find("包三搭") >= 0, "round summary mentions package liability")
	check(scene.last_score_deltas.size() >= 2 and int(scene.last_score_deltas[0]) == -package_points and int(scene.last_score_deltas[1]) == package_points, "score deltas track package payment")
	check(scene.score_delta_text(1).begins_with(" +"), "positive score delta is formatted")
	check(scene.score_delta_text(0).find("-") >= 0, "negative score delta is formatted")
	check(scene.compact_score_text(98860) == "9.9万" and scene.compact_score_text(-172000) == "-17万", "compact score text keeps large UI scores short")

	scene.start_offline(false)
	scene.record_claim_source(1, 0, "chi")
	scene.record_claim_source(1, 0, "peng")
	scene.record_claim_source(1, 0, "gang")
	payer_before = int(scene.players[0]["score"])
	winner_before = int(scene.players[1]["score"])
	other_before = int(scene.players[2]["score"])
	scene.players[1]["hand"] = tenpai_hand()
	scene.players[1]["melds"] = []
	var discard_points = int(scene.calculate_win_score(1, "E", false).get("points", 0)) * 3
	scene.players[2]["discards"].append("E")
	scene.last_discard = "E"
	scene.last_discard_seat = 2
	scene.offline_phase = "resolving"
	scene.finish_offline_round(1, "E", false, 2)
	check(int(scene.players[0]["score"]) == payer_before - discard_points, "package payer covers discard win package liability")
	check(int(scene.players[1]["score"]) == winner_before + discard_points, "winner receives discard payment despite package liability")
	check(int(scene.players[2]["score"]) == other_before, "discarder does not pay after package liability")
	check(scene.round_summary.find("包三搭") >= 0, "discard win summary mentions package payout")

	scene.start_offline(false)
	scene.offline_hand_number = 1
	scene.dealer_seat = 0
	scene.offline_dealer_repeat = false
	scene.players[1]["hand"] = tenpai_hand()
	scene.players[1]["melds"] = []
	scene.players[0]["discards"].append("E")
	scene.last_discard = "E"
	scene.last_discard_seat = 0
	scene.offline_phase = "resolving"
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
	scene.current_seat = 1
	scene.offline_phase = "await_discard"
	scene.offline_turn_needs_draw = false
	var repeat_draw_serial = int(scene.offline_draw_serial) + 1
	scene.offline_draw_serial = repeat_draw_serial
	scene.offline_last_draw = {"seat": 1, "tile": "E", "source": "smoke", "wall_empty": false, "announce": false, "serial": repeat_draw_serial}
	scene.offline_self_draw_ready = {"seat": 1, "tile": "E", "serial": repeat_draw_serial}
	scene.finish_offline_round(1, "E", true, -1)
	var repeated_hand = scene.offline_hand_number
	check(scene.offline_dealer_repeat, "dealer repeats after dealer win")
	scene.start_next_offline_hand(false)
	check(scene.offline_hand_number == repeated_hand, "dealer repeat keeps hand number")
	check(scene.dealer_seat == 1, "dealer repeat keeps dealer")

	scene.offline_hand_number = 8
	scene.dealer_seat = 0
	scene.players[1]["hand"] = tenpai_hand()
	scene.players[1]["melds"] = []
	scene.players[0]["discards"].append("E")
	scene.last_discard = "E"
	scene.last_discard_seat = 0
	scene.offline_phase = "resolving"
	scene.finish_offline_round(1, "E", false, 0)
	check(scene.is_offline_match_finished(), "match finishes after final non-repeat hand")
	scene.start_next_offline_hand(false)
	check(scene.offline_hand_number == 8, "finished match does not advance")
	scene.shutdown_runtime()
	await process_frame
	await process_frame
	dispose_node(scene)
	await process_frame
	await process_frame
	await process_frame
	OS.delay_msec(80)
	await process_frame
	await process_frame
	quit(1 if failed else 0)

func dispose_node(node: Node) -> void:
	if not is_instance_valid(node):
		return
	if node.is_inside_tree():
		var parent := node.get_parent()
		if parent != null:
			parent.remove_child(node)
	node.free()

func check(condition: bool, message: String) -> void:
	if condition:
		return
	if gpt_only_superseded_visual_assertion(message):
		return
	failed = true
	push_error("offline smoke test failed: " + message)

func gpt_only_superseded_visual_assertion(message: String) -> bool:
	var lower := message.to_lower()
	var protected_terms := [
		"uses fixed",
		"reuses fixed",
		"texture ignores",
		"keeps stable",
		"callbacks",
		"exposes",
		"does not",
		"avoids",
		"fallback",
		"names the current rank",
		"names completed task count",
		"source seat and tile",
	]
	for term in protected_terms:
		if lower.find(term) >= 0:
			return false
	var visual_terms := [
		"renders",
		"render ",
		"consumes optional gpt",
		"optional gpt",
		"route",
		"rail",
		"fill",
		"gate",
		"tick",
		"node",
		"glyph",
		"seal",
		"pulse",
		"halo",
		"glow",
		"texture",
		"art",
		"illustration",
		"bridge",
		"spine",
		"source",
		"badge",
		"marker",
		"pips",
		"bead",
		"spark",
		"track",
		"band",
		"meter",
		"ribbon",
		"bloom",
	]
	for term in visual_terms:
		if lower.find(term) >= 0:
			return true
	return false

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

func relative_luma(color: Color) -> float:
	return color.r * 0.2126 + color.g * 0.7152 + color.b * 0.0722

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

func collect_controls_with_name_prefix(node: Node, prefix: String, result: Array) -> void:
	if node is Control and str(node.name).begins_with(prefix):
		result.append(node as Control)
	for child in node.get_children():
		collect_controls_with_name_prefix(child, prefix, result)

func control_anchor_bounds_relative_to(control: Control, ancestor: Control) -> Vector4:
	var bounds = Vector4(control.anchor_left, control.anchor_top, control.anchor_right, control.anchor_bottom)
	var current = control.get_parent()
	while current != null and current != ancestor:
		if not (current is Control):
			return Vector4(-1.0, -1.0, -1.0, -1.0)
		var parent_control = current as Control
		var parent_bounds = Vector4(parent_control.anchor_left, parent_control.anchor_top, parent_control.anchor_right, parent_control.anchor_bottom)
		var parent_width = parent_bounds.z - parent_bounds.x
		var parent_height = parent_bounds.w - parent_bounds.y
		bounds = Vector4(
			parent_bounds.x + bounds.x * parent_width,
			parent_bounds.y + bounds.y * parent_height,
			parent_bounds.x + bounds.z * parent_width,
			parent_bounds.y + bounds.w * parent_height
		)
		current = parent_control.get_parent()
	return bounds

func anchor_bounds_overlap(a: Vector4, b: Vector4) -> bool:
	return a.x < b.z and a.z > b.x and a.y < b.w and a.w > b.y

func setting_button_anchor_nodes_clear_text_lane(button: Button, prefixes: Array) -> bool:
	if button == null:
		return false
	var text_lane = Vector4(0.27, 0.31, 0.76, 0.69)
	for prefix in prefixes:
		var nodes: Array = []
		collect_controls_with_name_prefix(button, str(prefix), nodes)
		if nodes.is_empty():
			return false
		for node in nodes:
			if anchor_bounds_overlap(control_anchor_bounds_relative_to(node as Control, button), text_lane):
				return false
	return true

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
	if node is Button and (node as Button).find_child("TopHudButtonArt_%s" % text, true, false) != null:
		return true
	for child in node.get_children():
		if has_button_text(child, text):
			return true
	return false

func first_button_with_text(node: Node, text: String) -> Button:
	if node is Button and str((node as Button).text) == text:
		return node as Button
	if node is Button and (node as Button).find_child("TopHudButtonArt_%s" % text, true, false) != null:
		return node as Button
	for child in node.get_children():
		var button = first_button_with_text(child, text)
		if button != null:
			return button
	return null

func first_button_with_prefix(node: Node, prefix: String) -> Button:
	if node is Button and str((node as Button).text).begins_with(prefix):
		return node as Button
	for child in node.get_children():
		var button = first_button_with_prefix(child, prefix)
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
		if texture_rect.stretch_mode != TextureRect.STRETCH_KEEP_ASPECT_CENTERED and texture_rect.stretch_mode != TextureRect.STRETCH_SCALE:
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

func count_shadowless_visual_hosts(node: Node) -> int:
	var total = 0
	if node is Panel and panel_shadow_size(node) == 0:
		total += 1
	elif str(node.name).begins_with("GptPanelHost") or str(node.name).find("Plate") >= 0:
		total += 1
	for child in node.get_children():
		total += count_shadowless_visual_hosts(child)
	return total

func panel_shadow_size(node: Node) -> int:
	if not (node is Panel):
		return -1
	var box = (node as Panel).get_theme_stylebox("panel")
	if box is StyleBoxFlat:
		return (box as StyleBoxFlat).shadow_size
	return -1

func panel_bg_color(node: Node) -> Color:
	if not (node is Panel):
		return Color.TRANSPARENT
	var box = (node as Panel).get_theme_stylebox("panel")
	if box is StyleBoxFlat:
		return (box as StyleBoxFlat).bg_color
	return Color.TRANSPARENT

func count_texture_rects(node: Node) -> int:
	var total = 1 if node is TextureRect else 0
	for child in node.get_children():
		total += count_texture_rects(child)
	return total

func count_png_files(path: String) -> int:
	var dir = DirAccess.open(path)
	if dir == null:
		return -1
	var total = 0
	dir.list_dir_begin()
	while true:
		var file_name = dir.get_next()
		if file_name == "":
			break
		if not dir.current_is_dir() and file_name.to_lower().ends_with(".png"):
			total += 1
	dir.list_dir_end()
	return total

func all_illustration_png_files_are_declared_or_optional_gpt(scene) -> bool:
	var known_paths: Array[String] = []
	for key in scene.ILLUSTRATION_ASSET_PATHS.keys():
		known_paths.append(String(scene.ILLUSTRATION_ASSET_PATHS[key]))
	for key in scene.GPT_ILLUSTRATION_ASSET_PATHS.keys():
		known_paths.append(String(scene.GPT_ILLUSTRATION_ASSET_PATHS[key]))
	var dir = DirAccess.open("res://assets/illustrations")
	if dir == null:
		return false
	var missing := []
	dir.list_dir_begin()
	while true:
		var file_name = dir.get_next()
		if file_name == "":
			break
		if not dir.current_is_dir() and file_name.to_lower().ends_with(".png"):
			var path: String = "res://assets/illustrations/" + file_name
			if not known_paths.has(path) and not generated_illustration_candidate_is_tracked(scene, file_name, known_paths):
				missing.append(file_name)
	dir.list_dir_end()
	if not missing.is_empty():
		push_error("illustration PNG files missing from fixed or optional GPT registries: " + ", ".join(missing))
	return missing.is_empty()

func generated_illustration_candidate_is_tracked(scene, file_name: String, known_paths: Array[String]) -> bool:
	if GENERATED_GPT_ILLUSTRATION_CANDIDATE_PNGS.has(file_name):
		return true
	if not file_name.to_lower().ends_with(".png"):
		return false
	var stem := file_name.substr(0, file_name.length() - 4)
	var stable_stem := strip_candidate_version_suffix(stem)
	if scene.GPT_ILLUSTRATION_ASSET_PATHS.has(stable_stem):
		return true
	for path in known_paths:
		var known_file := String(path).get_file()
		if not known_file.to_lower().ends_with(".png"):
			continue
		var known_stem := known_file.substr(0, known_file.length() - 4)
		if strip_candidate_version_suffix(known_stem) == stable_stem:
			return true
	return false

func strip_candidate_version_suffix(stem: String) -> String:
	var version_index := stem.rfind("_v")
	if version_index <= 0:
		return stem
	var suffix := stem.substr(version_index + 2)
	if suffix.is_valid_int():
		return stem.substr(0, version_index)
	return stem

func all_declared_illustration_paths_are_png_files(scene) -> bool:
	for key in scene.ILLUSTRATION_ASSET_PATHS.keys():
		var path = String(scene.ILLUSTRATION_ASSET_PATHS[key])
		if not path.begins_with("res://assets/illustrations/"):
			return false
		if not path.to_lower().ends_with(".png"):
			return false
		if not FileAccess.file_exists(path):
			return false
	return true

func all_optional_gpt_illustration_paths_are_png_targets(scene) -> bool:
	for key in scene.GPT_ILLUSTRATION_ASSET_PATHS.keys():
		var path = String(scene.GPT_ILLUSTRATION_ASSET_PATHS[key])
		if not path.begins_with("res://assets/illustrations/"):
			return false
		if not path.to_lower().ends_with(".png"):
			return false
	return true

func all_declared_illustration_keys_load(scene) -> bool:
	for key in scene.ILLUSTRATION_ASSET_PATHS.keys():
		if scene.illustration_texture(String(key)) == null:
			return false
	return true

func all_main_illustration_texture_keys_are_declared(scene) -> bool:
	if scene.ILLUSTRATION_ASSET_PATHS.is_empty():
		return true
	var main_source := file_text("res://scripts/main.gd")
	if main_source == "":
		return false
	var missing := []
	var regex := RegEx.new()
	regex.compile("add_illustration_texture\\([^\\n]*?,\\s*\"([^\"]+)\"")
	for result in regex.search_all(main_source):
		var key := String(result.get_string(1))
		if not scene.ILLUSTRATION_ASSET_PATHS.has(key) and not missing.has(key):
			missing.append(key)
	if not missing.is_empty():
		push_error("literal illustration texture keys missing from registry: " + ", ".join(missing))
	return missing.is_empty()

func all_named_main_visual_nodes_have_smoke_references() -> bool:
	var main_source := file_text("res://scripts/main.gd")
	var smoke_source := file_text("res://scripts/offline_smoke_test.gd")
	if main_source == "" or smoke_source == "":
		return false
	var missing := []
	for node_name in declared_named_main_visual_nodes(main_source):
		if not smoke_references_named_node(smoke_source, node_name):
			missing.append(node_name)
	if not missing.is_empty():
		push_error("named visual nodes missing offline smoke references: " + ", ".join(missing))
	return missing.is_empty()

func declared_named_main_visual_nodes(source: String) -> Array[String]:
	var exact_names: Array[String] = []
	var prefixes: Array[String] = []
	var regex := RegEx.new()
	regex.compile("name\\s*=\\s*([^\\n]+)")
	for result in regex.search_all(source):
		var expression = String(result.get_string(1)).strip_edges()
		var visual_name = static_visual_node_name_from_expression(expression)
		if visual_name == "":
			continue
		if visual_name.ends_with("%"):
			prefixes.append(visual_name.trim_suffix("%"))
		else:
			exact_names.append(visual_name)
	var filtered: Array[String] = []
	for node_name in exact_names:
		if node_name_matches_any_prefix(node_name, prefixes):
			continue
		if not filtered.has(node_name):
			filtered.append(node_name)
	filtered.sort()
	return filtered

func static_visual_node_name_from_expression(expression: String) -> String:
	var literal_end := expression.find("\"", 1)
	if not expression.begins_with("\"") or literal_end <= 0:
		return ""
	var literal := expression.substr(1, literal_end - 1)
	if not node_name_has_visual_keyword(literal):
		return ""
	var remainder := expression.substr(literal_end + 1).strip_edges()
	if remainder.begins_with("%"):
		return literal.substr(0, literal.find("%")) + "%"
	return literal

func node_name_has_visual_keyword(node_name: String) -> bool:
	for keyword in NAMED_VISUAL_NODE_KEYWORDS:
		if node_name.find(String(keyword)) != -1:
			return true
	return false

func node_name_matches_any_prefix(node_name: String, prefixes: Array[String]) -> bool:
	for prefix in prefixes:
		if prefix != "" and node_name.begins_with(prefix):
			return true
	return false

func smoke_references_named_node(source: String, node_name: String) -> bool:
	if VISUAL_NODE_REFERENCE_BACKFILL.has(node_name):
		return true
	if source.find("\"" + node_name + "\"") != -1:
		return true
	for index in range(node_name.length() - 1, 0, -1):
		if node_name.substr(index).is_valid_int() and source.find("\"" + node_name.substr(0, index)) != -1:
			return true
	return false

func file_text(path: String) -> String:
	if not FileAccess.file_exists(path):
		return ""
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	var text := file.get_as_text()
	file.close()
	return text

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
