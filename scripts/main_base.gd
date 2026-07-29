extends Control

const WallBackStrip := preload("res://scripts/ui/wall_back_strip.gd")
const BattleTableDepth := preload("res://scripts/ui/battle_table_depth.gd")
const Commercial3DStage := preload("res://scripts/ui/commercial_3d_stage.gd")
const TABLE_CINEMATIC_LIGHTING_SHADER := preload("res://shaders/table_cinematic_lighting.gdshader")
const DEFAULT_HOST := "129.146.180.88"
const DEFAULT_PORT := 23333
const APP_VERSION := "1.0.180-godot"
const UPDATE_MANIFEST_URL := "http://129.146.180.88:18081/YunzhuoMahjongGodot-update.json"
const UPDATE_URL := "http://129.146.180.88:18081/YunzhuoMahjongGodot-v1.0.180-godot.apk"
const UPDATE_FILE_PATH := "user://updates/YunzhuoMahjongGodot-v1.0.180-godot.apk"
const SETTINGS_PATH := "user://settings.cfg"
const PROGRESS_PATH := "user://offline_progress.cfg"
const STATS_PATH := "user://game_stats.cfg"
const TUTORIAL_PATH := "user://tutorial.cfg"
const ACHIEVEMENTS_PATH := "user://achievements.cfg"
const LOGIN_PATH := "user://login.cfg"
const AUDIO_DEFAULTS_VERSION := "1.0.159-godot"
const BGM_STREAM_PATH := "res://assets/audio/bgm_guofeng2.mp3"
const ANIMATION_ASSET_PATHS := {
	"coin_spin": "res://assets/animations/coin_spin.json",
	"victory_sparkle": "res://assets/animations/victory_sparkle.json",
	"claim_response_orbit": "res://assets/animations/claim_response_orbit.json",
	"discard_ink_splash": "res://assets/animations/discard_ink_splash.json",
	"tile_draw_fly": "res://assets/animations/tile_draw_fly.json",
	"tile_discard_fly": "res://assets/animations/tile_discard_fly.json",
	"kong_reveal_burst": "res://assets/animations/kong_reveal_burst.json",
}
const ILLUSTRATION_ASSET_PATHS := {}
const GPT_ILLUSTRATION_ASSET_PATHS := {
	"menu_hero_gpt_backdrop": "res://assets/illustrations/menu_hero_gpt_backdrop.png",
	"menu_hero_gpt_backdrop_warm": "res://assets/illustrations/menu_hero_gpt_backdrop_warm_v390.png",
	"menu_lobby_gpt_scene": "res://assets/illustrations/menu_lobby_gpt_scene.png",
	"menu_lobby_ui_overlay": "res://assets/illustrations/menu_lobby_ui_overlay.png",
	"menu_primary_3d_stage_overlay": "res://assets/illustrations/menu_primary_3d_stage_overlay.png",
	"menu_primary_3d_stage_overlay_warm": "res://assets/illustrations/menu_primary_3d_stage_overlay_warm_v390.png",
	"loading_scene_gpt_backdrop": "res://assets/illustrations/loading_scene_gpt_backdrop.png",
	"daily_login_gpt_calendar": "res://assets/illustrations/daily_login_gpt_calendar.png",
	"daily_login_gpt_calendar_warm": "res://assets/illustrations/daily_login_gpt_calendar_warm_v392.png",
	"shop_gpt_vault": "res://assets/illustrations/shop_gpt_vault.png",
	"shop_gpt_vault_warm": "res://assets/illustrations/shop_gpt_vault_warm_v392.png",
	"claim_response_trail": "res://assets/illustrations/claim_response_trail.png",
	"discard_splash_wash": "res://assets/illustrations/discard_splash_wash.png",
	"win_result_stage": "res://assets/illustrations/win_result_stage.png",
	"round_summary_score_flow_bus": "res://assets/illustrations/round_summary_score_flow_bus.png",
	"rules_gpt_scroll": "res://assets/illustrations/rules_gpt_scroll.png",
	"rules_gpt_scroll_warm": "res://assets/illustrations/rules_gpt_scroll_warm_v391.png",
	"stats_gpt_dashboard": "res://assets/illustrations/stats_gpt_dashboard.png",
	"stats_gpt_dashboard_warm": "res://assets/illustrations/stats_gpt_dashboard_warm_v392.png",
	"achievement_gpt_gallery": "res://assets/illustrations/achievement_gpt_gallery.png",
	"achievement_gpt_gallery_warm": "res://assets/illustrations/achievement_gpt_gallery_warm_v391.png",
	"online_gpt_lobby": "res://assets/illustrations/online_gpt_lobby.png",
	"online_lobby_panel_frame": "res://assets/illustrations/online_lobby_panel_frame_warm_v392.png",
	"online_lobby_group_plate": "res://assets/illustrations/online_lobby_group_plate_v1.png",
	"settings_gpt_panel": "res://assets/illustrations/settings_gpt_panel.png",
	"settings_gpt_panel_v2": "res://assets/illustrations/settings_gpt_panel_v2.png",
	"settings_gpt_panel_warm": "res://assets/illustrations/settings_gpt_panel_warm_v391.png",
	"table_gpt_backdrop": "res://assets/illustrations/table_gpt_backdrop_v4.png",
	"table_gpt_backdrop_warm": "res://assets/illustrations/table_gpt_backdrop_warm_v391.png",
	"offline_table_3d_overlay": "res://assets/illustrations/offline_table_3d_overlay.png",
	"hand_gpt_tray": "res://assets/illustrations/hand_gpt_tray_bright_r432.png",
	"hand_completion_gpt_bus": "res://assets/illustrations/hand_completion_gpt_bus.png",
	"action_gpt_dock": "res://assets/illustrations/action_gpt_dock_banner_r436.png",
	"action_gpt_dock_banner_r433": "res://assets/illustrations/action_gpt_dock_banner_r433.png",
	"action_gpt_dock_bright": "res://assets/illustrations/action_gpt_dock_bright_r431.png",
	"action_gpt_dock_warm": "res://assets/illustrations/action_gpt_dock_warm_v391.png",
	"pending_claim_action_dock": "res://assets/illustrations/action_gpt_dock_banner_r436.png",
	"pending_claim_status_strip": "res://assets/illustrations/pending_claim_status_strip.png",
	"wall_live_feedback_kit": "res://assets/illustrations/wall_live_feedback_kit.png",
	"action_button_panel": "res://assets/illustrations/action_button_panel.png",
	"intent_panel_plate": "res://assets/illustrations/intent_panel_plate.png",
	"rules_guide_panel": "res://assets/illustrations/rules_guide_panel.png",
	"rules_reading_progress_panel": "res://assets/illustrations/rules_reading_progress_panel.png",
	"action_dock_track_panel": "res://assets/illustrations/action_dock_track_panel.png",
	"settings_overview_panel": "res://assets/illustrations/settings_overview_panel.png",
	"settings_section_signal_panel": "res://assets/illustrations/settings_section_signal_panel.png",
	"shop_currency_meter_panel": "res://assets/illustrations/shop_currency_meter_panel.png",
	"table_log_gpt_scroll": "res://assets/illustrations/table_log_gpt_scroll.png",
	"advisor_gpt_panel": "res://assets/illustrations/advisor_gpt_panel.png",
	"top_hud_gpt_banner": "res://assets/illustrations/top_hud_gpt_banner_r434.png",
	"top_hud_gpt_banner_warm": "res://assets/illustrations/top_hud_gpt_banner_warm_v392.png",
	"seat_gpt_brocade": "res://assets/illustrations/seat_gpt_brocade_v5.png",
	"seat_gpt_plaque_warm": "res://assets/illustrations/seat_gpt_plaque_warm_r429.png",
	"exit_gpt_confirm": "res://assets/illustrations/exit_gpt_confirm.png",
	"exit_gpt_confirm_warm": "res://assets/illustrations/exit_gpt_confirm_warm_v392.png",
	"chat_gpt_panel": "res://assets/illustrations/chat_gpt_panel.png",
	"update_gpt_dialog": "res://assets/illustrations/update_gpt_dialog.png",
	"diagnostic_gpt_panel": "res://assets/illustrations/diagnostic_gpt_panel.png",
	"toast_gpt_banner": "res://assets/illustrations/toast_gpt_banner.png",
	"ui_title_backplate": "res://assets/illustrations/ui_title_backplate.png",
	"ui_soft_flash": "res://assets/illustrations/ui_soft_flash.png",
	"ui_dark_scrim": "res://assets/illustrations/ui_dark_scrim.png",
	"ui_river_soft_wash": "res://assets/illustrations/ui_river_soft_wash.png",  # r180: warm ivory GPT wash (no green flood)
	"ui_jade_ink_strip": "res://assets/illustrations/ui_jade_ink_strip.png",
	"ui_jade_reading_plate": "res://assets/illustrations/ui_jade_reading_plate.png",
	"ui_meld_pad": "res://assets/illustrations/ui_meld_pad.png",
	"ui_progress_signal_strip": "res://assets/illustrations/ui_progress_signal_strip.png",
	"ui_meter_rail_plate": "res://assets/illustrations/ui_meter_rail_plate.png",
	"ui_action_role_rail": "res://assets/illustrations/ui_action_role_rail.png",
	"ui_seat_info_plate": "res://assets/illustrations/ui_seat_info_plate.png",
	"ui_hand_tray_state_chip": "res://assets/illustrations/ui_hand_tray_state_chip.png",
	"ui_button_face_plate": "res://assets/illustrations/ui_button_face_plate.png",
	"ui_shop_row_plate": "res://assets/illustrations/ui_shop_row_plate.png",
	"ui_chat_lane_plate": "res://assets/illustrations/ui_chat_lane_plate.png",
	"ui_confirm_sheet_plate": "res://assets/illustrations/ui_confirm_sheet_plate.png",
	"ui_loading_progress_plate": "res://assets/illustrations/ui_loading_progress_plate.png",
	"ui_settings_section_plate": "res://assets/illustrations/ui_settings_section_plate.png",
	"ui_menu_card_face": "res://assets/illustrations/ui_menu_card_face.png",
	"ui_online_form_field": "res://assets/illustrations/ui_online_form_field.png",
	"ui_ornament_tick_strip": "res://assets/illustrations/ui_ornament_tick_strip.png",
	"ui_meter_fill_plate": "res://assets/illustrations/ui_meter_fill_plate.png",
	"ui_route_rail_plate": "res://assets/illustrations/ui_route_rail_plate.png",
	"reset_gpt_warning": "res://assets/illustrations/reset_gpt_warning.png",
	"win_detail_gpt_scroll": "res://assets/illustrations/win_detail_gpt_scroll.png",
	"win_celebration_gpt_burst": "res://assets/illustrations/win_celebration_gpt_burst.png",
	"voice_gpt_channel": "res://assets/illustrations/voice_gpt_channel.png",
	"online_feedback_gpt_strip": "res://assets/illustrations/online_feedback_gpt_strip_v2.png",
	"table_turn_gpt_flow": "res://assets/illustrations/table_turn_gpt_flow.png",
	"center_wind_gpt_compass": "res://assets/illustrations/center_wind_gpt_compass_v2.png",
	"danger_gpt_discard": "res://assets/illustrations/danger_gpt_discard.png",
	"menu_tutorial_gpt_hint": "res://assets/illustrations/menu_tutorial_gpt_hint.png",
	"hand_tutorial_gpt_hint": "res://assets/illustrations/hand_tutorial_gpt_hint.png",
	"flower_gpt_bloom": "res://assets/illustrations/flower_gpt_bloom.png",
	"seat_discard_gpt_preview": "res://assets/illustrations/seat_discard_gpt_preview.png",
	"seat_flower_gpt_strip": "res://assets/illustrations/seat_flower_gpt_strip.png",
	"center_wall_gpt_warning": "res://assets/illustrations/center_wall_gpt_warning.png",
	"top_hud_wall_gpt_warning": "res://assets/illustrations/top_hud_wall_gpt_warning.png",
	"lobby_room_gate_token": "res://assets/illustrations/lobby_room_gate_token.png",
	"exit_save_scroll": "res://assets/illustrations/exit_save_scroll.png",
	"stats_winrate_scroll": "res://assets/illustrations/stats_winrate_scroll.png",
	"rules_pattern_quads": "res://assets/illustrations/rules_pattern_quads.png",
	"diagnostic_wave_hero": "res://assets/illustrations/diagnostic_wave_hero.png",
	"center_wind_pointer": "res://assets/illustrations/center_wind_pointer.png",
	"seat_avatar_scenic_frame": "res://assets/illustrations/seat_avatar_scenic_frame.png",
	"wall_strip_landscape": "res://assets/illustrations/wall_strip_landscape_v2.png",
	"win_cover_self_draw": "res://assets/illustrations/win_cover_self_draw.png",
	"win_cover_deal_in": "res://assets/illustrations/win_cover_deal_in.png",
	"win_cover_draw_game": "res://assets/illustrations/win_cover_draw_game.png",
	"gang_closeup_concealed": "res://assets/illustrations/gang_closeup_concealed.png",
	"gang_closeup_open": "res://assets/illustrations/gang_closeup_open.png",
	"gang_closeup_added": "res://assets/illustrations/gang_closeup_added.png",
	"petals_spring": "res://assets/illustrations/petals_spring.png",
	"petals_summer": "res://assets/illustrations/petals_summer.png",
	"petals_autumn": "res://assets/illustrations/petals_autumn.png",
	"petals_winter": "res://assets/illustrations/petals_winter.png",
	"dealer_seal": "res://assets/illustrations/dealer_seal.png",
	"dealer_repeat_ring": "res://assets/illustrations/dealer_repeat_ring.png",
	"center_active_bloom": "res://assets/illustrations/center_active_bloom.png",
	"guide_pointing_finger": "res://assets/illustrations/guide_pointing_finger.png",
	"fly_transition_flip": "res://assets/illustrations/fly_transition_flip.png",
	"shop_charm_huan": "res://assets/illustrations/shop_charm_huan.png",
	"shop_charm_kan": "res://assets/illustrations/shop_charm_kan.png",
	"shop_charm_yun": "res://assets/illustrations/shop_charm_yun.png",
	"shop_charm_bei": "res://assets/illustrations/shop_charm_bei.png",
	"achievement_medal_bronze": "res://assets/illustrations/achievement_medal_bronze.png",
	"achievement_medal_jade": "res://assets/illustrations/achievement_medal_jade.png",
	"achievement_medal_gold": "res://assets/illustrations/achievement_medal_gold.png",
	"rank_ribbon_gold": "res://assets/illustrations/rank_ribbon_gold.png",
	"rank_ribbon_silver": "res://assets/illustrations/rank_ribbon_silver.png",
	"rank_ribbon_bronze": "res://assets/illustrations/rank_ribbon_bronze.png",
	"season_trophy_loop": "res://assets/illustrations/season_trophy_loop.png",
	"update_verify_stamp": "res://assets/illustrations/update_verify_stamp.png",
	"chat_send_seal": "res://assets/illustrations/chat_send_seal.png",
	"rules_section_goal_panel": "res://assets/illustrations/rules_section_goal_panel.png",
	"rules_section_meld_panel": "res://assets/illustrations/rules_section_meld_panel.png",
	"rules_section_special_panel": "res://assets/illustrations/rules_section_special_panel.png",
	"rules_section_action_panel": "res://assets/illustrations/rules_section_action_panel.png",
}
# v1.0.159: 默认BGM改为《胡笳十八拍》，支持多个BGM切换
const BGM_TRACKS := [
	{"name": "胡笳十八拍", "path": "res://assets/audio/bgm_guofeng2.mp3"},
	{"name": "梅花三弄", "path": "res://assets/audio/bgm_guofeng1.mp3"},
	{"name": "汉宫秋月", "path": "res://assets/audio/bgm_guofeng3.mp3"},
	{"name": "原版", "path": "res://assets/audio/bgm_loop.mp3"}
]
const PLAYER_AI_ASSIST_ENABLED := false
const TILE_TEXT_OVERLAYS_ENABLED := false
const SEAT_NAMES := ["你", "青竹道人", "南山客", "扶摇散人"]
const SEAT_COLORS := [
	Color(0.24, 0.40, 0.54),
	Color(0.26, 0.45, 0.37),
	Color(0.44, 0.36, 0.52),
	Color(0.56, 0.38, 0.30),
]
const SEAT_ACCENT_COLORS := [
	Color(0.20, 0.28, 0.36),
	Color(0.22, 0.34, 0.28),
	Color(0.34, 0.28, 0.38),
	Color(0.38, 0.28, 0.20),
]
const SEAT_NAME_BADGE_COLORS := [
	Color(0.24, 0.32, 0.42),
	Color(0.26, 0.42, 0.34),
	Color(0.42, 0.34, 0.48),
	Color(0.48, 0.34, 0.26),
]
const SEAT_HEADER_COLORS := [
	Color(0.10, 0.13, 0.16),
	Color(0.10, 0.15, 0.13),
	Color(0.13, 0.12, 0.15),
	Color(0.15, 0.12, 0.10),
]
const SEAT_AVATAR_BORDER_COLORS := [
	Color(0.20, 0.32, 0.44),
	Color(0.22, 0.38, 0.32),
	Color(0.38, 0.30, 0.46),
	Color(0.44, 0.32, 0.26),
]
const SEAT_AVATAR_BAND_COLORS := [
	Color(0.16, 0.26, 0.40),
	Color(0.18, 0.34, 0.26),
	Color(0.30, 0.22, 0.38),
	Color(0.38, 0.22, 0.18),
]
const AI_DIFFICULTY_EASY := 0
const AI_DIFFICULTY_NORMAL := 1
const AI_DIFFICULTY_HARD := 2
const AI_DIFFICULTY_LABELS := ["简单", "标准", "困难"]
const AI_DANGER_RISK_SOFT := 18.0
const AI_DANGER_RISK_HIGH := 31.0
const AI_DANGER_FEED_SOFT := 14.0
# Quiet all-bot benchmarks fully score only the strongest three fast-ranked
# candidates. Acute pressure keeps one additional slot so attack and fold can
# be compared together. Interactive play never uses either cap.
const AI_FAST_EVAL_TOP_K := 3
const AI_FAST_EVAL_PRESSURE_TOP_K := 4
const AI_PROFILES := [
	{
		"label": "均衡",
		"short": "均",
		"attack": 1.0,
		"defense": 1.0,
		"claim": 1.0,
		"risk": 1.0,
		"route": 1.0,
		"gang": 1.0,
		"wait": 1.0,
		"pressure": 1.0,
	},
	{
		"label": "防守型",
		"short": "守",
		"attack": 0.92,
		"defense": 1.32,
		"claim": 0.78,
		"risk": 1.42,
		"route": 1.08,
		"gang": 0.82,
		"wait": 1.12,
		"pressure": 0.88,
	},
	{
		"label": "进攻型",
		"short": "攻",
		"attack": 1.28,
		"defense": 0.88,
		"claim": 1.38,
		"risk": 0.82,
		"route": 0.96,
		"gang": 1.24,
		"wait": 1.02,
		"pressure": 1.32,
	},
	{
		"label": "大牌型",
		"short": "大",
		"attack": 1.08,
		"defense": 1.02,
		"claim": 1.12,
		"risk": 1.08,
		"route": 1.48,
		"gang": 1.18,
		"wait": 1.38,
		"pressure": 1.14,
	},
]
const TILE_CODES := [
	"1W", "2W", "3W", "4W", "5W", "6W", "7W", "8W", "9W",
	"1T", "2T", "3T", "4T", "5T", "6T", "7T", "8T", "9T",
	"1B", "2B", "3B", "4B", "5B", "6B", "7B", "8B", "9B",
	"E", "S", "N", "R", "Z", "F", "P"
]
const EMPTY_TILE_COUNTS_TEMPLATE := [
	0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0
]
const EMPTY_SUIT_RANK_MASKS := [0, 0, 0]
const FLOWER_CODES := ["H1", "H2", "H3", "H4", "H5", "H6", "H7", "H8"]
const TILE_RANK_SPEECH_LABELS := ["一", "二", "三", "四", "五", "六", "七", "八", "九"]
const FLOWER_LABELS := ["春", "夏", "秋", "冬", "梅", "兰", "竹", "菊"]
const THIRTEEN_ORPHANS_CODES := ["1W", "9W", "1T", "9T", "1B", "9B", "E", "S", "N", "R", "Z", "F", "P"]
const WIND_CODES := ["E", "S", "N", "R"]
const DRAGON_CODES := ["Z", "F", "P"]
const RISK_BADGE_TEXT := {
	"安": "安",
	"现": "现",
	"熟": "熟",
	"筋": "筋",
	"壁": "壁",
	"高": "高危",
	"中": "中",
	"低": "低",
}
const RISK_BADGE_COLORS := {
	"安": Color(0.14, 0.72, 0.52, 0.96),
	"现": Color(0.12, 0.68, 0.60, 0.96),
	"熟": Color(0.18, 0.62, 0.72, 0.94),
	"筋": Color(0.24, 0.58, 0.82, 0.94),
	"壁": Color(0.22, 0.66, 0.76, 0.94),
	"高": Color(0.92, 0.22, 0.18, 0.98),
	"中": Color(0.96, 0.66, 0.22, 0.96),
	"低": Color(0.20, 0.68, 0.42, 0.92),
}
const DEFAULT_RISK_BADGE_COLOR := Color(0.65, 0.58, 0.40, 0.92)
const HINT_BADGE_COLORS := {
	"荐": Color(1.0, 0.86, 0.32, 0.98),
	"确认": Color(0.96, 0.38, 0.28, 0.98),
}
const DEFAULT_HINT_BADGE_COLOR := Color(0.96, 0.82, 0.38, 0.96)
const MATCH_START_SCORE := 25000
const MATCH_MAX_HANDS := 8
const VOICE_BUS_NAME := "VoiceCapture"
const VOICE_CHUNK_FRAMES := 2048
const AI_DRAW_DELAY_SECONDS := 0.35
const AI_DISCARD_DELAY_SECONDS := 0.35
const AI_ACTION_GAP_SECONDS := 0.35
const HUMAN_DISCARD_RESPONSE_GAP_SECONDS := 0.01
const AI_RETURN_TO_HUMAN_GAP_SECONDS := 0.08
const HUMAN_DRAW_DELAY_SECONDS := 0.006
const SCORE_LIMIT_FAN := 8
const WALL_DRAW_NOTEN_BA := 1000  # 荒庄未听罚符：每家未听支付总额，由听牌者均分
const RULES_SECTION_COUNT := 6
const SCORE_TABLE := {
	1: 200,
	2: 400,
	3: 800,
	4: 1600,
	5: 3200,
	6: 6400,
	7: 12800,
	8: 25600,
}
const SEASON_RANKS := ["青铜", "白银", "黄金", "铂金", "钻石", "大师"]
const SEASON_RANK_POINTS := [0, 100, 300, 600, 1000, 1500]
const SEASON_PATH := "user://season.cfg"
const TASKS_PATH := "user://tasks.cfg"
const INVENTORY_PATH := "user://inventory.cfg"
const CURRENCY_PATH := "user://currency.cfg"
const DAILY_TASKS := [
	{"id": "win_3", "desc": "胡牌3次", "target": 3, "reward_coins": 50},
	{"id": "peng_3", "desc": "使用碰3次", "target": 3, "reward_coins": 30},
	{"id": "gang_1", "desc": "使用杠1次", "target": 1, "reward_coins": 40},
	{"id": "play_5", "desc": "完成5局游戏", "target": 5, "reward_coins": 60},
	{"id": "score_plus", "desc": "单局正分", "target": 1, "reward_coins": 25},
]
const ITEM_TYPES := {
	"swap_card": {"name": "换牌卡", "desc": "重新摸一张牌", "icon": "🔄", "cost_gems": 5},
	"peek_card": {"name": "偷看卡", "desc": "查看对手一张手牌", "icon": "👁", "cost_gems": 8},
	"lucky_charm": {"name": "幸运符", "desc": "本局胡牌概率显示+10%", "icon": "🍀", "cost_gems": 10},
	"double_coins": {"name": "双倍金币卡", "desc": "本局金币奖励翻倍", "icon": "💰", "cost_gems": 15},
}

var tile_textures: Dictionary = {}
var tile_decal_textures: Dictionary = {}
var icon_textures: Dictionary = {}
var animation_specs: Dictionary = {}
var tile_back: Texture2D
var felt_texture: Texture2D
var wood_texture: Texture2D
var illustration_textures: Dictionary = {}
var optional_gpt_illustration_textures: Dictionary = {}
var shader_materials: Dictionary = {}
const SHADER_PATHS := {
	"ink_wash_bg": "res://shaders/ink_wash_bg.gdshader",
	"glow_bloom": "res://shaders/glow_bloom.gdshader",
	"water_ripple": "res://shaders/water_ripple.gdshader",
	"brush_stroke": "res://shaders/brush_stroke.gdshader",
	"gold_foil_shimmer": "res://shaders/gold_foil_shimmer.gdshader",
	"ink_dissolve_transition": "res://shaders/ink_dissolve_transition.gdshader",
}
var audio_streams: Dictionary = {}
var voice_streams: Dictionary = {}
var audio_layer: Node
var bgm_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer
var action_sfx_player: AudioStreamPlayer
var android_tts
var android_tts_requested = false
var android_tts_requested_msec = 0
var android_tts_started_msec = 0
var android_tts_retry_after_msec = 0
var android_tts_language_configured = false
var tts_voice_id = ""
var tts_utterance_id = 1
var next_bgm_retry_msec = 0
var audio_touch_unlocked = false
var audio_health_check_counter = 0
var last_bgm_health_check = 0
var speech_queue: Array = []
var speech_queue_active = false
var speech_queue_generation = 0
var speech_delay_timer: Timer
var music_enabled = true
var sfx_enabled = true
var tts_enabled = true
var fast_mode_enabled = true
var ai_difficulty := AI_DIFFICULTY_NORMAL
var ai_benchmark_base_difficulty := -1
var ai_benchmark_probe_seat := -1
var ai_benchmark_probe_difficulty := -1
var fx_enabled = true
var graphics_quality = Commercial3DStage.QUALITY_AUTO
var ai_assist_enabled = false  # 出牌辅助（推荐/危险提示），玩家可在设置中开启
var current_bgm_index = 0  # v1.0.157: 当前BGM索引
var settings_panel_open = false
var reset_progress_confirming = false
var exit_confirm_panel: Control = null
var tutorial_step = 0  # 新手教程步骤：0=未开始，1-5=各步骤，-1=已完成
var tutorial_panel: Control = null
var show_hand_hint = true  # 是否显示手牌操作提示
var interactive_guide_active = false  # 交互式引导是否激活
var interactive_guide_type = ""  # 当前引导类型：discard/claim/self_win
var game_stats = {
	"games_played": 0,
	"games_won": 0,
	"total_score": 0,
	"best_score": 0,
	"win_rate": 0.0,
	"total_hands": 0,
}
var achievements = {
	"first_win": false,  # 首次胡牌
	"seven_pairs": false,  # 七对
	"thirteen_orphans": false,  # 十三幺
	"pure_one_suit": false,  # 清一色
	"mixed_one_suit": false,  # 混一色
	"big_three_dragons": false,  # 大三元
	"small_three_dragons": false,  # 小三元
	"big_four_winds": false,  # 大四喜
	"small_four_winds": false,  # 小四喜
	"all_honors": false,  # 字一色
	"all_triplets": false,  # 碰碰胡
	"full_straight": false,  # 一条龙
	"concealed_hand": false,  # 门清胡牌
	"self_draw": false,  # 自摸胡牌
	"rob_gang": false,  # 抢杠胡
	"five_wins": false,  # 累计5胜
	"ten_wins": false,  # 累计10胜
}
var last_login_date = ""  # 上次登录日期 YYYY-MM-DD
var consecutive_login_days = 0  # 连续登录天数
# 赛季系统
var season_data = {
	"season_id": "",
	"points": 0,
	"highest_rank": 0,
	"wins": 0,
	"games": 0,
}
# 任务系统
var daily_tasks = []  # 当日任务列表
var task_progress = {}  # 任务进度
var last_task_reset_date = ""  # 上次任务重置日期
# 道具系统
var inventory = {}  # 道具库存 {"swap_card": 2, "peek_card": 1, ...}
# 虚拟货币
var currency = {
	"coins": 0,
	"gems": 0,
}
var mode = "menu"
var screen_layer: Control
var root_layer: Control
var status_label: Label
var logs_label: Label
var action_bar: HBoxContainer
var update_request: HTTPRequest
var update_dialog: Control
var update_status_label: Label
var update_progress_label: Label
var update_progress: ProgressBar
var update_art_fill: Control
var update_art_status_light: Control
var update_release_notes_art: Control
var update_release_notes_label: Label
var update_primary_button: Button
var update_secondary_button: Button
var update_state = "idle"
var update_request_mode = "idle"
var update_message = ""
var update_download_url = UPDATE_URL
var update_remote_version = APP_VERSION
var update_release_notes = ""
var update_remote_sha256 = ""
var update_remote_size = 0
var update_file_path = UPDATE_FILE_PATH
var update_downloaded_bytes = 0
var update_total_bytes = 0
var players: Array = []
var wall: Array[String] = []
var current_seat = 0
var dealer_seat = 0
var offline_hand_number = 1
var offline_last_winner = -1
var offline_dealer_repeat = false
var last_discard = ""
var last_discard_seat = -1
var table_logs: Array[String] = []
var offline_phase = "idle"
var offline_turn_needs_draw = false
var offline_pending_claim: Dictionary = {}
var offline_claim_counts: Dictionary = {}
var offline_package_liability: Dictionary = {}
var offline_passed_win_tiles: Dictionary = {}  # seat -> {tile: true} 同张过水
var offline_claim_discard_bans: Dictionary = {}  # seat -> {tile: true} 吃碰后本回合食替禁打
var offline_concealed_gang_tiles: Dictionary = {}  # seat -> {tile: true} 保留暗杠门清来源
var offline_last_draw: Dictionary = {}
var offline_self_draw_ready: Dictionary = {}  # 当前回合可自摸的真实摸牌；空值只兼容旧局状态
var offline_ai_active = false
var offline_ai_run_queued = false
var offline_all_bot_mode := false
var offline_sim_quiet := false
var offline_match_briefing_shown := false
var offline_skip_ai_profile_reshuffle := false
## seat -> AI_PROFILES index; reshuffled by difficulty for variety
var ai_profile_seat_map: Array = [0, 1, 2, 3]
var ai_sim_stats: Dictionary = {}
var ai_sim_trace_enabled := false  # 仅基准诊断：记录紧凑弃牌链路，不进入正常对局
var round_summary = ""
var last_score_deltas: Array[int] = []
var last_win_score: Dictionary = {}  # 保存上次胡牌得分详情
var current_human_advice: Array = []
var tile_order: Dictionary = {}
var tile_sort_order: Dictionary = {}
var tile_metadata_ready = false
var tile_suit_cache: Dictionary = {}
var tile_number_cache: Dictionary = {}
var tile_flower_cache: Dictionary = {}
var tile_honor_cache: Dictionary = {}
var tile_terminal_or_honor_cache: Dictionary = {}
var tile_simple_number_cache: Dictionary = {}
var tile_thirteen_orphans_cache: Dictionary = {}
var thirteen_orphans_indices: Array[int] = []
var tile_label_cache: Dictionary = {}
var tile_speech_label_cache: Dictionary = {}
var tile_face_main_cache: Dictionary = {}
var tile_face_sub_cache: Dictionary = {}
var tile_corner_cache: Dictionary = {}
var tile_accent_cache: Dictionary = {}
var style_cache: Dictionary = {}
var style_cache_order: Array[String] = []
var button_style_set_cache: Dictionary = {}
var button_style_set_cache_order: Array[String] = []
var input_style_set_cache: Dictionary = {}
var input_style_set_cache_order: Array[String] = []
var shanten_cache: Dictionary = {}
var shanten_cache_order: Array[String] = []
var shanten_cache_hits = 0
var shanten_cache_misses = 0
var ai_report_cache: Dictionary = {}
var ai_report_cache_order: Array[String] = []
var ai_report_cache_hits = 0
var ai_report_cache_misses = 0
var threat_report_cache: Dictionary = {}
var threat_report_cache_order: Array[String] = []
var effective_tiles_cache: Dictionary = {}
var effective_tiles_cache_order: Array[String] = []
var effective_tiles_cache_hits = 0
var effective_tiles_cache_misses = 0
var perf_render_count = 0
var perf_render_total_ms = 0.0
var perf_ai_decision_count = 0
var perf_ai_decision_total_ms = 0.0
var pending_danger_discard_index = -1
var pending_danger_discard_tile = ""
var pending_danger_discard_report: Dictionary = {}
var selected_room = ""
var online_host_edit: LineEdit
var online_room_edit: LineEdit
var online_name_edit: LineEdit
var tcp = StreamPeerTCP.new()
var tcp_status = StreamPeerTCP.STATUS_NONE
var tcp_buffer = ""
var online_room: Dictionary = {}
var online_game: Dictionary = {}
var online_feedback = ""
var online_waiting_for_server = false
var online_last_sent_action = ""
var online_last_sent_msec = 0
var online_announced_discard_key = ""
var online_pending_local_discard_identity = ""
var sent_hello = false
var voice_capture_effect: AudioEffectCapture
var voice_mic_player: AudioStreamPlayer
var voice_enabled = false
var voice_sequence = 0
var voice_peak = 0.0
var game_render_queued = false
var last_game_render_msec = 0
var runtime_shutdown_requested = false
var runtime_delay_timers: Array[Timer] = []
var next_online_poll_msec = 0
var next_update_progress_msec = 0
var safe_area_margins := Vector4(0.0, 0.0, 0.0, 0.0)
var safe_area_test_margins_override := Vector4(-1.0, -1.0, -1.0, -1.0)
var fx_layer: Control
var fx_turn_pulse: Control
var fx_turn_glow: Panel
var fx_turn_pulse_tween: Tween
var fx_burst_root: Control
var fx_burst_label: Label
var fx_burst_rings: Array[Panel] = []
var fx_burst_flash: Control
var fx_burst_tween: Tween
var fx_ripple_root: Control
var fx_ripple_rings: Array[Panel] = []
var fx_ripple_tween: Tween
var transition_overlay: Control
var transition_tween: Tween
var transition_pending_callback: Callable
var transition_active := false
var toast_container: Control
var toast_tween: Tween
var toast_current: Control

# 牌面动画系统变量 / Tile Animation System Variables
var tile_flip_animations: Dictionary = {}  # 进行中的翻转动画
var tile_fly_animations: Array = []         # 进行中的飞行动画
var offline_draw_serial := 0
var fx_last_animated_draw_serial := -1

# 环境氛围动画变量 / Environmental Animation Variables
var ambient_layer: Control
var ambient_petals: Array[Control] = []
var ambient_clouds: Array[Control] = []
var ambient_particles: Array[Control] = []
var ambient_tween: Tween

# 主菜单视差与粒子闪烁变量 / Menu Parallax & Shimmer Variables
var menu_hero_art: Control
var menu_realtime_3d_stage: Control
var menu_parallax_enabled := false

const TILE_FACE_LABELS := ["E", "S", "N", "R", "Z", "F", "P"]
const NUMBER_SUIT_STARTS := [0, 9, 18]
const TILE_BASE_VALUES := [
	4.0, 6.0, 8.0, 8.0, 8.0, 8.0, 8.0, 6.0, 4.0,
	4.0, 6.0, 8.0, 8.0, 8.0, 8.0, 8.0, 6.0, 4.0,
	4.0, 6.0, 8.0, 8.0, 8.0, 8.0, 8.0, 6.0, 4.0,
	5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0,
]
const EMPTY_WAIT_VALUE_METRICS_TEMPLATE := {
	"score": 0.0,
	"best_tile": "",
	"best_fan": 0,
	"best_points": 0,
	"average_points": 0.0,
	"total_remaining": 0,
	"adjusted_remaining": 0.0,
	"self_discarded": [],
	"quality_penalty": 0.0,
	"quality_text": "",
}
const SHAPE_NEIGHBOR_DELTAS := [-2, -1, 1, 2]
const WALL_BACK_TILE_SIZE := Vector2(22, 30)
const WALL_VISUAL_FULL_COUNT := 92
const DISCARD_TILE_MAX_SIZE := Vector2(88, 116)  # r452 denser bottom/side porcelain cap
const DISCARD_TILE_MIN_SIZE := Vector2(34, 46)  # r451 denser floor
const DISCARD_TILE_ASPECT := 52.0 / 38.0
const DISCARD_GRID_SEPARATION := 0  # r449 weld porcelain cells; bleed handles pad
const WALL_LAYOUTS := [
	[Vector2(0.255, 0.050), Vector2(0.745, 0.095), 16, true],
	[Vector2(0.255, 0.850), Vector2(0.745, 0.895), 16, true],
	[Vector2(0.046, 0.165), Vector2(0.094, 0.795), 12, false],
	[Vector2(0.906, 0.165), Vector2(0.954, 0.795), 12, false],
]
const DISCARD_ZONES := [
	# r452: bottom river taller/wider for porcelain density; sides keep dense 4-col.
	[0, Rect2(Vector2(0.140, 0.455), Vector2(0.680, 0.740)), 8],  # bottom denser pocket
	[2, Rect2(Vector2(0.285, 0.120), Vector2(0.715, 0.355)), 8],
	[3, Rect2(Vector2(0.100, 0.155), Vector2(0.390, 0.760)), 4],
	[1, Rect2(Vector2(0.610, 0.155), Vector2(0.900, 0.760)), 4],
]
const MELD_LAYOUTS := [
	[0, Rect2(Vector2(0.165, 0.742), Vector2(0.420, 0.812))],
	[1, Rect2(Vector2(0.882, 0.240), Vector2(0.940, 0.680))],
	[2, Rect2(Vector2(0.615, 0.100), Vector2(0.915, 0.195))],
	[3, Rect2(Vector2(0.070, 0.240), Vector2(0.128, 0.680))],
]
const CENTER_WIND_LABELS := ["东", "南", "西", "北"]
const CENTER_PANEL_RECT := Rect2(Vector2(0.405, 0.345), Vector2(0.595, 0.635))
const CENTER_INNER_RECT := Rect2(Vector2(0.17, 0.14), Vector2(0.83, 0.78))
const CENTER_PHASE_RIBBON_RECT := Rect2(Vector2(0.20, 0.040), Vector2(0.80, 0.125))
const CENTER_STATUS_RECT := Rect2(Vector2(0.15, 0.13), Vector2(0.85, 0.27))
const CENTER_WALL_LABEL_RECT := Rect2(Vector2(0.38, 0.30), Vector2(0.62, 0.42))
const CENTER_WALL_COUNT_RECT := Rect2(Vector2(0.35, 0.39), Vector2(0.65, 0.58))
const CENTER_LAST_LABEL_RECT := Rect2(Vector2(0.38, 0.60), Vector2(0.62, 0.69))
const CENTER_LAST_TILE_RECT := Rect2(Vector2(0.430, 0.700), Vector2(0.570, 0.920))
const CENTER_LAST_TILE_SIZE := Vector2(38, 52)
const CENTER_WIND_RECTS := [
	Rect2(Vector2(0.43, 0.05), Vector2(0.57, 0.22)),
	Rect2(Vector2(0.78, 0.40), Vector2(0.94, 0.57)),
	Rect2(Vector2(0.43, 0.79), Vector2(0.57, 0.94)),
	Rect2(Vector2(0.06, 0.40), Vector2(0.22, 0.57)),
]
const CENTER_DICE_DOT_POINTS := [
	Vector2(0.35, 0.32),
	Vector2(0.65, 0.32),
	Vector2(0.35, 0.60),
	Vector2(0.65, 0.60),
]
const CENTER_DICE_DOT_RECTS := [
	Rect2(Vector2(0.332, 0.302), Vector2(0.368, 0.338)),
	Rect2(Vector2(0.632, 0.302), Vector2(0.668, 0.338)),
	Rect2(Vector2(0.332, 0.582), Vector2(0.368, 0.618)),
	Rect2(Vector2(0.632, 0.582), Vector2(0.668, 0.618)),
]
const CENTER_INNER_FILL := Color(0.082, 0.104, 0.088, 0.800)
const CENTER_INNER_BORDER := Color(0.72, 0.62, 0.38, 0.26)
const CENTER_WALL_COUNT_COLOR := Color(0.86, 0.88, 0.72, 0.88)
const CENTER_ACTIVE_WIND_COLOR := Color(0.92, 0.76, 0.36, 0.88)
const CENTER_IDLE_WIND_COLOR := Color(0.68, 0.64, 0.46, 0.68)
const CENTER_DICE_DOT_RADIUS := 0.018
const CENTER_DICE_DOT_FILL := Color(0.60, 0.56, 0.42, 0.62)
const CENTER_DICE_DOT_BORDER := Color(0.76, 0.72, 0.58, 0.26)
const ROUND_SUMMARY_PANEL_RECT := Rect2(Vector2(0.300, 0.190), Vector2(0.700, 0.610))
const ROUND_SUMMARY_HEADER_RECT := Rect2(Vector2(0.0, 0.0), Vector2(1.0, 0.16))
const ROUND_SUMMARY_TITLE_RECT := Rect2(Vector2(0.06, 0.04), Vector2(0.94, 0.18))
const ROUND_SUMMARY_TEXT_RECT := Rect2(Vector2(0.08, 0.190), Vector2(0.92, 0.335))
const ROUND_SUMMARY_RANK_START_Y := 0.365
const ROUND_SUMMARY_RANK_ROW_HEIGHT := 0.105
const ROUND_SUMMARY_RANK_ROW_GAP := 0.018
const ROUND_SUMMARY_NEXT_DEALER_RECT := Rect2(Vector2(0.08, 0.880), Vector2(0.92, 0.955))
const TABLE_OUTER_RECT := Rect2(Vector2(0.135, 0.115), Vector2(0.865, 0.790))
const TABLE_OUTER_TEXTURE_RECT := Rect2(Vector2(0.008, 0.012), Vector2(0.992, 0.988))
const TABLE_INNER_RECT := Rect2(Vector2(0.035, 0.045), Vector2(0.965, 0.955))
const TABLE_INNER_TEXTURE_RECT := Rect2(Vector2(0.012, 0.016), Vector2(0.988, 0.984))
const SEAT_LAYOUTS := [
	[2, Rect2(Vector2(0.390, 0.108), Vector2(0.610, 0.200)), "top"],
	[3, Rect2(Vector2(0.020, 0.335), Vector2(0.140, 0.505)), "left"],
	[1, Rect2(Vector2(0.860, 0.335), Vector2(0.980, 0.505)), "right"],
	[0, Rect2(Vector2(0.020, 0.745), Vector2(0.180, 0.950)), "bottom"],
]
const TABLE_ORNAMENT_EDGES := [
	[Rect2(Vector2(0.055, 0.040), Vector2(0.945, 0.060)), Color(0.50, 0.42, 0.24, 0.36), Color(0.82, 0.76, 0.56, 0.12)],
	[Rect2(Vector2(0.055, 0.940), Vector2(0.945, 0.960)), Color(0.48, 0.40, 0.22, 0.32), Color(0.82, 0.76, 0.56, 0.12)],
	[Rect2(Vector2(0.030, 0.090), Vector2(0.048, 0.910)), Color(0.48, 0.40, 0.22, 0.28), Color(0.82, 0.76, 0.56, 0.10)],
	[Rect2(Vector2(0.952, 0.090), Vector2(0.970, 0.910)), Color(0.48, 0.40, 0.22, 0.28), Color(0.82, 0.76, 0.56, 0.10)],
]
const TABLE_CORNER_FILL := Color(0.22, 0.20, 0.15, 0.40)
const TABLE_CORNER_BORDER := Color(0.40, 0.38, 0.30, 0.10)
const TABLE_CORNER_VERTICAL_FILL := Color(0.22, 0.20, 0.15, 0.36)
const TABLE_CORNER_VERTICAL_BORDER := Color(0.40, 0.38, 0.30, 0.09)
const TABLE_CORNER_RECTS := [
	[Rect2(Vector2(0.045, 0.070), Vector2(0.100, 0.088)), Rect2(Vector2(0.045, 0.070), Vector2(0.059, 0.142))],
	[Rect2(Vector2(0.905, 0.070), Vector2(0.960, 0.088)), Rect2(Vector2(0.950, 0.070), Vector2(0.964, 0.142))],
	[Rect2(Vector2(0.045, 0.875), Vector2(0.100, 0.893)), Rect2(Vector2(0.045, 0.875), Vector2(0.059, 0.947))],
	[Rect2(Vector2(0.905, 0.875), Vector2(0.960, 0.893)), Rect2(Vector2(0.950, 0.875), Vector2(0.964, 0.947))],
]
const HAND_TILE_MAX_WIDTH := 68.0
const HAND_TILE_MIN_TOUCH_WIDTH := 46.0
const HAND_TILE_ASPECT := 1.36
const HAND_TRAY_RECT := Rect2(Vector2(0.185, 0.815), Vector2(0.985, 0.985))
const HAND_TRAY_TOP_RAIL_RECT := Rect2(Vector2(0.012, 0.055), Vector2(0.988, 0.135))
const HAND_TRAY_DIVIDER_RECT := Rect2(Vector2(0.012, 0.145), Vector2(0.988, 0.170))
const HAND_TRAY_TEXT_RECT := Rect2(Vector2(0.030, 0.040), Vector2(0.760, 0.145))
const HAND_TRAY_STATE_BADGE_RECT := Rect2(Vector2(0.795, 0.040), Vector2(0.970, 0.145))
const HAND_TRAY_TILES_RECT := Rect2(Vector2(0.015, 0.15), Vector2(0.985, 0.96))
const HAND_LAYOUT_CANDIDATES := [
	[8.0, 5],
	[6.0, 4],
	[4.0, 4],
	[3.0, 3],
	[0.0, 3],
]
const ACTION_BUTTON_MAX_WIDTH := 72.0
const ACTION_BUTTON_MIN_TOUCH_WIDTH := 50.0
const ACTION_BUTTON_HEIGHT := 44.0
const ACTION_BAR_DOCK_RECT := Rect2(Vector2(0.520, 0.688), Vector2(0.972, 0.792))
const ACTION_BAR_RECT := Rect2(Vector2(0.534, 0.698), Vector2(0.960, 0.782))
const PENDING_CLAIM_ACTION_BAR_DOCK_RECT := Rect2(Vector2(0.520, 0.688), Vector2(0.972, 0.792))
const PENDING_CLAIM_ACTION_BAR_RECT := Rect2(Vector2(0.534, 0.698), Vector2(0.960, 0.782))
const TOP_HUD_BUTTON_SIZE := Vector2(56, 38)
const TOP_HUD_MODE_BADGE_RECT := Rect2(Vector2(0.018, 0.14), Vector2(0.100, 0.44))
const SAFE_CONTENT_MIN_MARGIN := Vector4(12.0, 8.0, 12.0, 10.0)
const SAFE_CONTENT_MAX_SIDE_FRACTION := 0.16
const SAFE_CONTENT_MAX_TOP_FRACTION := 0.16
const SAFE_CONTENT_MAX_BOTTOM_FRACTION := 0.18
const TOP_HUD_RECT := Rect2(Vector2(0.014, 0.014), Vector2(0.986, 0.105))
const TOP_HUD_TITLE_RECT := Rect2(Vector2(0.106, 0.10), Vector2(0.208, 0.88))
const TOP_HUD_STATUS_RECT := Rect2(Vector2(0.212, 0.10), Vector2(0.432, 0.50))
const TOP_HUD_HAND_PROGRESS_RECT := Rect2(Vector2(0.212, 0.565), Vector2(0.432, 0.890))
const TOP_HUD_SCORE_STRIP_RECT := Rect2(Vector2(0.442, 0.15), Vector2(0.712, 0.85))
const TOP_HUD_WALL_RECT := Rect2(Vector2(0.692, 0.14), Vector2(0.764, 0.86))
const TOP_HUD_SETTINGS_BUTTON_RECT := Rect2(Vector2(0.775, 0.16), Vector2(0.838, 0.84))
const TOP_HUD_BACK_BUTTON_RECT := Rect2(Vector2(0.848, 0.16), Vector2(0.911, 0.84))
const TOP_HUD_UPDATE_BUTTON_RECT := Rect2(Vector2(0.921, 0.16), Vector2(0.984, 0.84))
const SCORE_STRIP_CHIP_RECTS := [
	Rect2(Vector2(0.006, 0.0), Vector2(0.244, 1.0)),
	Rect2(Vector2(0.256, 0.0), Vector2(0.494, 1.0)),
	Rect2(Vector2(0.506, 0.0), Vector2(0.744, 1.0)),
	Rect2(Vector2(0.756, 0.0), Vector2(0.994, 1.0)),
]
const SCORE_STRIP_ACCENT_RECT := Rect2(Vector2(0.0, 0.0), Vector2(0.035, 1.0))
const SCORE_STRIP_NAME_RECT := Rect2(Vector2(0.065, 0.20), Vector2(0.405, 0.80))
const SCORE_STRIP_SCORE_RECT := Rect2(Vector2(0.430, 0.08), Vector2(0.970, 0.92))
const SEAT_STAT_RECTS := [
	Rect2(Vector2(0.39, 0.38), Vector2(0.535, 0.505)),
	Rect2(Vector2(0.550, 0.38), Vector2(0.695, 0.505)),
	Rect2(Vector2(0.39, 0.520), Vector2(0.960, 0.600)),
]
const BGM_VOLUME_DB := 0.0
const SFX_VOLUME_BOOST_DB := 2.5
const VOICE_VOLUME_DB := -2.0
const UI_RENDER_MIN_INTERVAL_MSEC := 16
const ONLINE_POLL_INTERVAL_MSEC := 33
const UPDATE_PROGRESS_INTERVAL_MSEC := 120
const ANDROID_TTS_WARMUP_MSEC := 900
const ANDROID_TTS_FALLBACK_MSEC := 4200
const UPDATE_NOTES_PREVIEW_CHARS := 28
const ANDROID_TTS_RETRY_MSEC := 1400
const SPEECH_READY_RETRY_SECONDS := 0.16
const SPEECH_TILE_DELAY_SECONDS := 0.12
const SPEECH_ACTION_DELAY_SECONDS := 0.10
const SPEECH_MAX_READY_WAIT_MSEC := 7200
const SPEECH_CLIP_GAP_SECONDS := 0.34
const SPEECH_CLIP_TAIL_SECONDS := 0.12
const SHANTEN_CACHE_LIMIT := 4096
const AI_REPORT_CACHE_LIMIT := 256
const THREAT_REPORT_CACHE_LIMIT := 192
const EFFECTIVE_TILES_CACHE_LIMIT := 512
const STYLE_CACHE_LIMIT := 256
const BUTTON_STYLE_SET_CACHE_LIMIT := 96
const INPUT_STYLE_SET_CACHE_LIMIT := 32
const UI_GOLD := Color(0.74, 0.56, 0.26, 0.26)
const UI_GOLD_SOFT := Color(0.68, 0.50, 0.24, 0.15)
const UI_DARK := Color(0.070, 0.060, 0.046, 0.970)
const UI_DARK_SOFT := Color(0.102, 0.086, 0.064, 0.900)
const UI_FELT := Color(0.090, 0.165, 0.122, 0.955)
const UI_FELT_LINE := Color(0.72, 0.61, 0.36, 0.12)
const UI_TEXT_MAIN := Color(0.96, 0.92, 0.80, 1.0)
const UI_TEXT_SUB := Color(0.90, 0.88, 0.76, 0.98)
const UI_TEXT_MUTED := Color(0.78, 0.76, 0.64, 0.94)
const UI_PANEL_FILL := Color(0.108, 0.092, 0.066, 0.925)
const UI_PANEL_BORDER := Color(0.64, 0.48, 0.24, 0.24)
const UI_PANEL_SHADOW := Color(0.020, 0.014, 0.008, 0.20)
const TOP_HUD_FILL := Color(0.118, 0.094, 0.064, 0.920)
const TOP_HUD_BORDER := Color(0.70, 0.52, 0.28, 0.28)
const SCORE_STRIP_FILL := Color(0.095, 0.112, 0.082, 0.860)
const SCORE_STRIP_BORDER := Color(0.60, 0.48, 0.26, 0.20)
const SCORE_STRIP_NAME_FILL := Color(0.92, 0.84, 0.62, 0.90)
const SETTINGS_PANEL_FILL := Color(0.086, 0.106, 0.094, 0.940)
const SETTINGS_PANEL_BORDER := Color(0.68, 0.56, 0.34, 0.32)
const SETTINGS_PANEL_RECT := Rect2(Vector2(0.145, 0.055), Vector2(0.855, 0.955))
const SETTINGS_TITLE_RECT := Rect2(Vector2(0.06, 0.045), Vector2(0.34, 0.155))
const SETTINGS_CLOSE_RECT := Rect2(Vector2(0.830, 0.055), Vector2(0.965, 0.165))
const SETTINGS_AUDIO_SECTION_RECT := Rect2(Vector2(0.040, 0.255), Vector2(0.488, 0.785))
const SETTINGS_PLAY_SECTION_RECT := Rect2(Vector2(0.512, 0.255), Vector2(0.960, 0.785))
const SETTINGS_MAINT_SECTION_RECT := Rect2(Vector2(0.040, 0.805), Vector2(0.960, 0.955))
const SETTINGS_SECTION_TITLE_RECT := Rect2(Vector2(0.035, 0.045), Vector2(0.300, 0.300))
const SETTINGS_SECTION_GRID_RECT := Rect2(Vector2(0.035, 0.165), Vector2(0.965, 0.970))
const SETTINGS_ROW_STATUS_RECT := Rect2(Vector2(0.045, 0.145), Vector2(0.510, 0.855))
const SETTINGS_ROW_BUTTON_RECT := Rect2(Vector2(0.595, 0.020), Vector2(0.975, 0.980))
const UI_BACKGROUND_TINT := Color(0.112, 0.086, 0.052, 0.800)

# ============================================================
# 国风雅韵主题色彩系统 / Guofeng Theme Color System
# ============================================================

# 水墨色系 / Ink Wash Colors
const INK_BLACK := Color(0.030, 0.035, 0.032, 1.0)        # 墨黑
const INK_DARK := Color(0.080, 0.095, 0.086, 1.0)         # 浓墨
const INK_MEDIUM := Color(0.145, 0.155, 0.135, 1.0)       # 淡墨
const INK_LIGHT := Color(0.28, 0.27, 0.23, 1.0)           # 极淡墨
const INK_WASH := Color(0.35, 0.32, 0.36, 0.85)           # 水墨晕染

# 朱红系 / Cinnabar Red System
const CINNABAR := Color(0.82, 0.18, 0.12, 1.0)            # 朱砂红
const VERMILION := Color(0.88, 0.28, 0.18, 1.0)           # 朱红
const ROUGE := Color(0.72, 0.22, 0.24, 1.0)               # 胭脂
const SCARLET_GLOW := Color(0.94, 0.42, 0.32, 0.92)       # 丹霞光

# 金色系 / Gold System
const GOLD_DARK := Color(0.62, 0.48, 0.18, 1.0)           # 暗金
const GOLD_PRIMARY := Color(0.88, 0.72, 0.28, 1.0)        # 正金
const GOLD_BRIGHT := Color(0.96, 0.84, 0.42, 1.0)         # 明金
const GOLD_LIGHT := Color(0.98, 0.92, 0.68, 1.0)          # 淡金
const GOLD_GLOW := Color(1.0, 0.90, 0.55, 0.85)           # 金辉

# 玉色系 / Jade System
const JADE_DARK := Color(0.12, 0.32, 0.28, 1.0)           # 墨玉
const JADE_PRIMARY := Color(0.28, 0.56, 0.48, 1.0)        # 青玉
const JADE_LIGHT := Color(0.42, 0.72, 0.62, 1.0)          # 白玉
const JADE_GLOW := Color(0.52, 0.82, 0.72, 0.88)          # 玉润

# 青花系 / Blue & White Porcelain
const PORCELAIN := Color(0.96, 0.98, 0.98, 1.0)           # 瓷白
const CELADON := Color(0.72, 0.84, 0.80, 1.0)             # 青瓷
const AZURE := Color(0.22, 0.48, 0.72, 1.0)               # 青花蓝
const AZURE_LIGHT := Color(0.42, 0.64, 0.88, 1.0)         # 淡青

# 宣纸系 / Rice Paper System
const PAPER_WARM := Color(0.98, 0.96, 0.90, 1.0)          # 宣纸暖
const PAPER_COOL := Color(0.95, 0.96, 0.94, 1.0)          # 宣纸冷
const PAPER_AGED := Color(0.94, 0.90, 0.82, 1.0)          # 古宣纸

# 祥云装饰色 / Auspicious Cloud Colors
const CLOUD_WHITE := Color(1.0, 1.0, 1.0, 0.72)           # 白云
const CLOUD_GOLD := Color(0.96, 0.88, 0.52, 0.62)         # 金云
const CLOUD_MIST := Color(0.88, 0.90, 0.92, 0.42)         # 烟云

# 国风主题面板色 / Guofeng Theme Panel Colors
const GUOFENG_PANEL_FILL := Color(0.128, 0.104, 0.074, 0.900)
const GUOFENG_PANEL_BORDER := Color(0.66, 0.48, 0.24, 0.34)
const GUOFENG_PANEL_GOLD_LINE := Color(0.86, 0.62, 0.28, 0.38)

# 国风扩展色 - 插画与氛围专用 / Guofeng Extended - Illustration & Atmosphere
const GUOFENG_PANEL_HIGHLIGHT := Color(0.158, 0.128, 0.088, 0.900)
const GUOFENG_ACCENT_JADE := Color(0.22, 0.52, 0.44, 0.88)
const GUOFENG_ACCENT_CINNABAR := Color(0.78, 0.22, 0.16, 0.88)
const GUOFENG_ACCENT_AZURE := Color(0.28, 0.48, 0.72, 0.88)
const GUOFENG_INK_WASH_LIGHT := Color(0.48, 0.44, 0.50, 0.52)
const GUOFENG_WATER_DEEP := Color(0.04, 0.08, 0.10, 0.62)
const GUOFENG_WATER_SURFACE := Color(0.08, 0.14, 0.16, 0.38)
const GUOFENG_MOON_GLOW := Color(1.0, 0.96, 0.82, 0.32)
const GUOFENG_LANTERN_WARM := Color(1.0, 0.88, 0.52, 0.22)

# 雨丝与远风景色 / Rain & Distant Scenery
const RAIN_MIST := Color(0.72, 0.78, 0.82, 0.18)
const RAIN_DROP := Color(0.88, 0.92, 0.96, 0.42)
const DISTANT_MIST := Color(0.58, 0.62, 0.68, 0.28)

# 动画 / 特效层参数。特效节点全部挂在持久化的 fx_layer 上，整桌每次 render_game
# 调用 clear_screen 时 fx_layer 不被释放，因此补间动画可以跨整桌重绘连续播放。
const FX_WIN_BURST_DURATION_MSEC := 1400
const FX_DISCARD_RIPPLE_DURATION_MSEC := 460
const FX_TURN_PULSE_PERIOD_MSEC := 1700
const FX_WIN_RING_COUNT := 3
const FX_BURST_LABEL_FONT_SIZE := 58
const FX_LAYER_Z_INDEX := 16
const TRANSITION_DURATION_MSEC := 280
const HAND_SLIDE_IN_DURATION_MSEC := 220
const TOAST_DEFAULT_DURATION_MSEC := 1800
const TOAST_SLIDE_DURATION_MSEC := 220
const FX_TILE_FLIP_DURATION_MSEC := 180
const FX_SCORE_CHANGE_DURATION_MSEC := 320
const FX_CLAIM_FLY_DURATION_MSEC := 280

# 牌面动画参数 / Tile Animation Parameters
const FX_TILE_FLY_CURVE := Tween.TRANS_QUAD
const FX_TILE_FLY_EASE := Tween.EASE_OUT
const FX_TILE_CLAIM_BURST_DURATION_MSEC := 280

# 增强胜利特效参数 / Enhanced Victory Effect Parameters
const FX_WIN_PARTICLE_COUNT := 48
const FX_WIN_SPARK_COUNT := 24
const FX_WIN_DURATION_ENHANCED_MSEC := 2200
const FX_WIN_SHAKE_AMPLITUDE := 4.0
const FX_WIN_SHAKE_FREQUENCY := 12.0

# 进局发牌级联动画参数 / Deal Cascade Animation Parameters
const FX_DEAL_CASCADE_TILE_COUNT := 8
const FX_DEAL_CASCADE_DURATION_MSEC := 680
const FX_TURN_SWITCH_SLIDE_MSEC := 280

# 界面过渡动画参数 / Interface Transition Parameters
const TRANSITION_SLIDE_DURATION_MSEC := 350
const TRANSITION_CARD_FLIP_DURATION_MSEC := 280
const TRANSITION_STAGGER_DELAY_MSEC := 40
const TRANSITION_INK_WIPE_DURATION_MSEC := 420
const TRANSITION_DISSOLVE_DURATION_MSEC := 380

# 环境氛围动画参数 / Ambient Animation Parameters
const AMBIENT_PETAL_COUNT := 16
const AMBIENT_LEAF_COUNT := 14
const AMBIENT_CLOUD_COUNT := 5
const AMBIENT_FIREFLY_COUNT := 18
const AMBIENT_SNOWFLAKE_COUNT := 20
const AMBIENT_RAINDROP_COUNT := 28
const AMBIENT_FIREWORK_COUNT := 6

# ===== Shared UI helpers =====
func add_background(parent: Control) -> void:
	var bg = TextureRect.new()
	bg.texture = wood_texture
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.modulate = Color(0.86, 0.78, 0.62, 0.82)
	parent.add_child(bg)
	var paper_wash = make_fullrect_overlay(Color(0.54, 0.42, 0.25, 0.15), "ui_jade_reading_plate")  # r181 denser paper wash
	paper_wash.name = "GuofengWarmPaperWash"
	parent.add_child(paper_wash)
	var hero_wash = add_optional_gpt_illustration_texture(parent, "menu_hero_gpt_backdrop", rect_full(0.0, 0.0, 1.0, 1.0), 0.075, false)
	if hero_wash != null:
		hero_wash.name = "GuofengPaperSceneryBackdrop"
	var tint = make_fullrect_overlay(Color(0.070, 0.062, 0.046, 0.600), "ui_dark_scrim")
	tint.name = "GuofengWarmDimTint"
	parent.add_child(tint)
	# Edge wash via GPT plates only — no program ColorRect slabs.
	parent.add_child(make_gpt_plate_rect(rect_full(0.0, 0.0, 1.0, 0.12), Color(0.92, 0.78, 0.48, 0.045), "ui_soft_flash"))  # r181
	parent.add_child(make_gpt_plate_rect(rect_full(0.0, 0.88, 1.0, 1.0), Color(0.035, 0.026, 0.018, 0.155), "ui_dark_scrim"))
	parent.add_child(make_gpt_plate_rect(rect_full(0.0, 0.0, 0.035, 1.0), Color(0.035, 0.026, 0.018, 0.120), "ui_dark_scrim"))
	parent.add_child(make_gpt_plate_rect(rect_full(0.965, 0.0, 1.0, 1.0), Color(0.035, 0.026, 0.018, 0.120), "ui_dark_scrim"))

func add_battle_background(parent: Control) -> void:
	# Dark underfill via GPT plate so transparent PNG edges never flash pure black.
	var base = make_fullrect_overlay(Color(0.030, 0.042, 0.036, 1.0), "ui_dark_scrim")
	base.name = "OfflineBattleGuofengBase"
	parent.add_child(base)

	# Single full-screen guofeng room plate (table_gpt_backdrop). Do not stack a second photo.
	var battle_scene = add_optional_gpt_illustration_texture(parent, "table_gpt_backdrop", rect_full(0.0, 0.0, 1.0, 1.0), 0.92, false)
	if battle_scene != null:
		battle_scene.name = "OfflineBattleGuofengBackdrop"
	else:
		# Fallback to menu hero scenery if table plate missing.
		var garden_scene = add_optional_gpt_illustration_texture(parent, "menu_hero_gpt_backdrop", rect_full(0.0, 0.0, 1.0, 1.0), 0.78, false)
		if garden_scene != null:
			garden_scene.name = "OfflineBattleGuofengBackdrop"
		else:
			var fallback_wash = add_illustration_texture(parent, "table_wash", rect_full(-0.04, -0.06, 1.04, 1.06), 0.55, false)
			if fallback_wash != null:
				fallback_wash.name = "OfflineBattleInkWashBackdrop"

	# Light vignette only — keep guofeng art visible while protecting tile contrast.
	var readability_tint = make_fullrect_overlay(Color(0.008, 0.014, 0.012, 0.18), "ui_dark_scrim")
	readability_tint.name = "OfflineBattleReadabilityTint"
	parent.add_child(readability_tint)
	# Soft edge falloff via GPT plates — no program ColorRect green slabs.
	parent.add_child(make_gpt_plate_rect(rect_full(0.0, 0.0, 1.0, 0.10), Color(0.02, 0.03, 0.02, 0.16), "ui_dark_scrim"))
	parent.add_child(make_gpt_plate_rect(rect_full(0.0, 0.90, 1.0, 1.0), Color(0.02, 0.03, 0.02, 0.20), "ui_dark_scrim"))
	parent.add_child(make_gpt_plate_rect(rect_full(0.0, 0.0, 0.06, 1.0), Color(0.02, 0.03, 0.02, 0.12), "ui_dark_scrim"))
	parent.add_child(make_gpt_plate_rect(rect_full(0.94, 0.0, 1.0, 1.0), Color(0.02, 0.03, 0.02, 0.12), "ui_dark_scrim"))

func add_texture(parent: Control, texture: Texture2D, rect: Rect2, alpha: float) -> TextureRect:
	var tex = TextureRect.new()
	tex.texture = texture
	tex.modulate = Color(1, 1, 1, alpha)
	tex.stretch_mode = TextureRect.STRETCH_SCALE
	tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(tex, rect)
	parent.add_child(tex)
	return tex

func illustration_texture(name: String) -> Texture2D:
	return illustration_textures.get(name, null)

func optional_gpt_illustration_texture(name: String) -> Texture2D:
	return optional_gpt_illustration_textures.get(name, null)

func load_illustration_texture(path: String) -> Texture2D:
	# Prefer imported CompressedTexture2D when present; if import cache is stale
	# (ResourceLoader.exists true but ctex missing), fall back to raw PNG load.
	if ResourceLoader.exists(path):
		var import_path := path + ".import"
		var ctex_ok := true
		if FileAccess.file_exists(import_path):
			var import_cfg := ConfigFile.new()
			if import_cfg.load(import_path) == OK:
				var dest = str(import_cfg.get_value("remap", "path", ""))
				if dest != "" and not FileAccess.file_exists(dest):
					ctex_ok = false
		if ctex_ok:
			var imported = load(path)
			if imported is Texture2D:
				return imported
	var image = Image.new()
	var image_path = ProjectSettings.globalize_path(path)
	var err = image.load(image_path)
	if err != OK:
		return null
	return ImageTexture.create_from_image(image)

func add_illustration_texture(parent: Control, name: String, rect: Rect2, alpha: float = 1.0, keep_aspect: bool = false) -> TextureRect:
	var texture = illustration_texture(name)
	if texture == null:
		return null
	var tex = TextureRect.new()
	tex.name = "IllustrationTexture_%s" % name
	tex.texture = texture
	tex.modulate = Color(1.0, 1.0, 1.0, alpha)
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED if keep_aspect else TextureRect.STRETCH_SCALE
	tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(tex, rect)
	parent.add_child(tex)
	return tex

func add_optional_gpt_illustration_texture(parent: Control, name: String, rect: Rect2, alpha: float = 1.0, keep_aspect: bool = false) -> TextureRect:
	var texture = optional_gpt_illustration_texture(name)
	if texture == null:
		return null
	var tex = TextureRect.new()
	tex.name = "OptionalGPTIllustrationTexture_%s" % name
	tex.texture = texture
	tex.modulate = Color(1.0, 1.0, 1.0, alpha)
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED if keep_aspect else TextureRect.STRETCH_SCALE
	tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(tex, rect)
	parent.add_child(tex)
	return tex

func add_optional_gpt_atlas_texture(parent: Control, name: String, region: Rect2, rect: Rect2, alpha: float = 1.0, keep_aspect: bool = false) -> TextureRect:
	var source_texture = optional_gpt_illustration_texture(name)
	if source_texture == null:
		return null
	var atlas := AtlasTexture.new()
	atlas.atlas = source_texture
	atlas.region = region
	var tex = TextureRect.new()
	tex.name = "OptionalGPTAtlasTexture_%s" % name
	tex.texture = atlas
	tex.modulate = Color(1.0, 1.0, 1.0, alpha)
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED if keep_aspect else TextureRect.STRETCH_SCALE
	tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(tex, rect)
	parent.add_child(tex)
	return tex


func make_layout_host(rect: Rect2) -> Control:
	# Invisible layout host — never paints program ColorRect slabs.
	var host = Control.new()
	host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(host, rect)
	return host


func make_gpt_plate_rect(rect: Rect2, color: Color, plate_key: String = "") -> Control:
	# GPT plate (or invisible host). Never program ColorRect paint for chrome.
	if plate_key == "":
		plate_key = _gpt_plate_key_for_rect_color(rect, color)
	var texture: Texture2D = optional_gpt_illustration_texture(plate_key)
	if texture == null and plate_key != "ui_title_backplate":
		texture = optional_gpt_illustration_texture("ui_title_backplate")
	if texture == null and plate_key != "ui_jade_reading_plate":
		texture = optional_gpt_illustration_texture("ui_jade_reading_plate")
	if texture == null:
		var host = Control.new()
		host.mouse_filter = Control.MOUSE_FILTER_IGNORE
		apply_rect(host, rect)
		return host
	var tex = TextureRect.new()
	tex.texture = texture
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex.stretch_mode = TextureRect.STRETCH_SCALE
	tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Honor intentional alpha=0 (suppressed overlays). Only default when alpha is unset-ish negative.
	var tint_a = 0.0 if color.a <= 0.0 else clampf(color.a, 0.02, 1.0)
	tex.modulate = Color(1.0, 1.0, 1.0, 1.0)
	tex.self_modulate = Color(
		clampf(0.50 + color.r * 0.60, 0.20, 1.20),
		clampf(0.50 + color.g * 0.60, 0.20, 1.20),
		clampf(0.50 + color.b * 0.60, 0.20, 1.20),
		tint_a
	)
	apply_rect(tex, rect)
	return tex


func make_fullrect_overlay(color: Color, plate_key: String = "ui_dark_scrim") -> Control:
	# Full-screen overlay host; animate via modulate.a (not ColorRect.color).
	var texture: Texture2D = optional_gpt_illustration_texture(plate_key)
	if texture == null and plate_key == "ui_soft_flash":
		texture = optional_gpt_illustration_texture("ui_title_backplate")
	if texture == null and plate_key == "ui_dark_scrim":
		texture = optional_gpt_illustration_texture("ui_title_backplate")
	if texture == null:
		texture = optional_gpt_illustration_texture("ui_jade_reading_plate")
	var node: Control
	if texture != null:
		var tex = TextureRect.new()
		tex.texture = texture
		tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex.stretch_mode = TextureRect.STRETCH_SCALE
		node = tex
	else:
		node = Control.new()
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.set_anchors_preset(Control.PRESET_FULL_RECT)
	var a = clampf(color.a if color.a > 0.0 else 0.0, 0.0, 1.0)
	node.modulate = Color(
		clampf(color.r * 0.95 + 0.14, 0.06, 1.10),
		clampf(color.g * 0.95 + 0.14, 0.06, 1.10),
		clampf(color.b * 0.95 + 0.14, 0.06, 1.10),
		a
	)
	return node


func set_overlay_alpha(node: Control, alpha: float) -> void:
	if node == null or not is_instance_valid(node):
		return
	node.modulate.a = clampf(alpha, 0.0, 1.0)


func _gpt_plate_key_for_rect_color(rect: Rect2, color: Color) -> String:
	# Pick an existing GPT illustration plate by chrome shape / luminance.
	# Prefer dedicated denser ornaments for thin rails / fills / ticks (no program slabs).
	var w = maxf(absf(rect.size.x), 0.0001)
	var h = maxf(absf(rect.size.y), 0.0001)
	var aspect = w / h
	var lum = color.r * 0.299 + color.g * 0.587 + color.b * 0.114
	var warm_gold = color.r > 0.70 and color.g > 0.45 and color.b < 0.55 and lum >= 0.45
	var porcelain = lum >= 0.72 and color.b > 0.45 and absf(color.r - color.g) < 0.18
	if color.a <= 0.18 and lum < 0.22:
		return "ui_dark_scrim"
	# Compact gold seals / coins / medallions
	if warm_gold and aspect >= 0.75 and aspect <= 1.35 and maxf(w, h) <= 0.55:
		if optional_gpt_illustration_texture("dealer_seal") != null:
			return "dealer_seal"
		return "ui_hand_tray_state_chip"
	# Porcelain tile-like faces in animation previews
	if porcelain and aspect >= 0.55 and aspect <= 0.95:
		if optional_gpt_illustration_texture("ui_button_face_plate") != null:
			return "ui_button_face_plate"
	# Thin horizontal routes / fills / meter chrome
	if aspect >= 4.0 and h <= 0.16:
		if lum <= 0.22:
			return "ui_route_rail_plate"
		if lum >= 0.28:
			return "ui_meter_fill_plate"
		return "ui_meter_rail_plate"
	if aspect >= 5.5:
		return "ui_meter_rail_plate" if h < 0.08 else "ui_progress_signal_strip"
	if aspect >= 3.2 and aspect < 5.5:
		if h < 0.12:
			return "ui_chat_lane_plate"
		return "ui_shop_row_plate" if w >= 0.55 else "ui_button_face_plate"
	if aspect >= 1.6 and aspect < 3.2:
		return "ui_button_face_plate" if lum > 0.25 else "ui_confirm_sheet_plate"
	if aspect >= 0.70 and aspect < 1.05 and h >= 0.18:
		return "ui_menu_card_face"
	# Thin vertical ticks / rails → dedicated ornament or role rail
	if aspect <= 0.40:
		if w <= 0.05 or h <= 0.55:
			return "ui_ornament_tick_strip"
		return "ui_action_role_rail"
	# Compact gate/seal-like chrome
	if aspect >= 0.45 and aspect <= 1.35 and maxf(w, h) <= 0.12:
		return "ui_hand_tray_state_chip"
	# Soft wash / glow blobs
	if color.a <= 0.20 and aspect >= 0.8 and aspect <= 2.2:
		return "ui_soft_flash"
	if lum >= 0.62:
		return "ui_river_soft_wash"
	if lum <= 0.20:
		return "ui_jade_reading_plate"
	if lum <= 0.38:
		return "ui_seat_info_plate"
	return "ui_title_backplate"


func make_color_rect(rect: Rect2, color: Color) -> Control:
	# GPT plate host — never paints programmatic ColorRect slabs for UI chrome.
	return make_gpt_plate_rect(rect, color, _gpt_plate_key_for_rect_color(rect, color))


func make_gpt_route_rail(rect: Rect2, color: Color = Color(0.006, 0.016, 0.018, 0.46)) -> Control:
	# Dedicated dark GPT trough for HUD routes / meter tracks.
	var key := "ui_route_rail_plate"
	if optional_gpt_illustration_texture(key) == null:
		key = "ui_meter_rail_plate"
	return make_gpt_plate_rect(rect, color, key)


func make_gpt_meter_fill(rect: Rect2, color: Color) -> Control:
	# Dedicated warm GPT fill bar (tint via modulate).
	var key := "ui_meter_fill_plate"
	if optional_gpt_illustration_texture(key) == null:
		key = "ui_progress_signal_strip"
	return make_gpt_plate_rect(rect, color, key)


func make_gpt_tick_strip(rect: Rect2, color: Color) -> Control:
	# One GPT ornament strip instead of multi tick ColorRect stacks.
	var key := "ui_ornament_tick_strip"
	if optional_gpt_illustration_texture(key) == null:
		key = "ui_progress_signal_strip"
	return make_gpt_plate_rect(rect, color, key)


func add_gpt_tick_strip(parent: Control, rect: Rect2, color: Color, node_name: String = "GptTickStrip") -> Control:
	var node = make_gpt_tick_strip(rect, color)
	node.name = node_name
	if parent != null and is_instance_valid(parent):
		parent.add_child(node)
	return node


func make_gpt_gate(rect: Rect2, color: Color) -> Control:
	# Compact GPT gate/seal host (roundish chrome).
	var key := "ui_hand_tray_state_chip"
	if optional_gpt_illustration_texture(key) == null:
		key = "ui_button_face_plate"
	return make_gpt_plate_rect(rect, color, key)


func make_gpt_ribbon(rect: Rect2, color: Color) -> Control:
	# Thin GPT ribbon / accent lane (horizontal).
	var key := "ui_progress_signal_strip"
	if optional_gpt_illustration_texture("ui_ornament_tick_strip") != null and absf(rect.size.y) < 0.08:
		key = "ui_ornament_tick_strip"
	return make_gpt_plate_rect(rect, color, key)


func make_gpt_edge_rail(rect: Rect2, color: Color) -> Control:
	# Vertical edge accent rail.
	var key := "ui_action_role_rail"
	if optional_gpt_illustration_texture(key) == null:
		key = "ui_ornament_tick_strip"
	return make_gpt_plate_rect(rect, color, key)


func make_panel(parent: Control, rect: Rect2, color: Color, radius: int, border: Color, shadow_size: int = 6, plate_key: String = "") -> Panel:
	# Panel is a layout host only; visual fill comes from GPT plates, not StyleBox paint.
	var panel = Panel.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(panel, rect)
	# Keep StyleBoxFlat for theme/luma probes (scrollbar QA), but alpha=0 so GPT plate is the only paint.
	var fill_probe = soften_panel_color(color)
	var box := StyleBoxFlat.new()
	box.bg_color = Color(fill_probe.r, fill_probe.g, fill_probe.b, 0.0)
	var rad := 8 if radius >= 900 else maxi(0, radius)
	box.set_corner_radius_all(rad)
	box.set_border_width_all(0)
	box.border_color = Color(border.r, border.g, border.b, 0.0)
	box.shadow_size = 0
	panel.add_theme_stylebox_override("panel", box)
	if plate_key == "":
		plate_key = _gpt_plate_key_for_rect_color(rect, color)
	var texture: Texture2D = optional_gpt_illustration_texture(plate_key)
	if texture == null and plate_key != "ui_title_backplate":
		texture = optional_gpt_illustration_texture("ui_title_backplate")
	if texture == null:
		texture = optional_gpt_illustration_texture("ui_jade_reading_plate")
	if texture != null:
		var tex = TextureRect.new()
		tex.name = "GptPanelPlate"
		tex.texture = texture
		tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex.stretch_mode = TextureRect.STRETCH_SCALE
		tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tex.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		var fill_color = soften_panel_color(color)
		var tint_a = clampf(fill_color.a if fill_color.a > 0.001 else 0.55, 0.08, 1.0)
		# Keep a whisper of border warmth via slight gold lift on modulate.
		var border_lift = clampf(border.a * 0.18, 0.0, 0.18)
		tex.modulate = Color(
			clampf(0.42 + fill_color.r * 0.70 + border.r * border_lift, 0.16, 1.25),
			clampf(0.42 + fill_color.g * 0.70 + border.g * border_lift, 0.16, 1.25),
			clampf(0.42 + fill_color.b * 0.70 + border.b * border_lift, 0.16, 1.25),
			tint_a
		)
		panel.add_child(tex)
	parent.add_child(panel)
	return panel


func tint_panel_gpt_plate(panel: Control, color: Color, plate_key: String = "") -> void:
	# Re-tint existing GptPanelPlate (or attach one) without StyleBox paint.
	if panel == null or not is_instance_valid(panel):
		return
	if panel is Panel:
		var fill_probe = soften_panel_color(color)
		var box := StyleBoxFlat.new()
		box.bg_color = Color(fill_probe.r, fill_probe.g, fill_probe.b, 0.0)
		box.set_corner_radius_all(8)
		box.set_border_width_all(0)
		box.border_color = Color(0, 0, 0, 0)
		box.shadow_size = 0
		(panel as Panel).add_theme_stylebox_override("panel", box)
	var tex = panel.get_node_or_null("GptPanelPlate") as TextureRect
	if tex == null:
		var key := plate_key if plate_key != "" else "ui_hand_tray_state_chip"
		var texture: Texture2D = optional_gpt_illustration_texture(key)
		if texture == null:
			texture = optional_gpt_illustration_texture("ui_hand_tray_state_chip")
		if texture == null:
			texture = optional_gpt_illustration_texture("ui_button_face_plate")
		if texture == null:
			texture = optional_gpt_illustration_texture("ui_title_backplate")
		if texture == null:
			return
		tex = TextureRect.new()
		tex.name = "GptPanelPlate"
		tex.texture = texture
		tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex.stretch_mode = TextureRect.STRETCH_SCALE
		tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tex.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		panel.add_child(tex)
		panel.move_child(tex, 0)
	var fill_color = soften_panel_color(color)
	var tint_a = clampf(fill_color.a if fill_color.a > 0.001 else 0.40, 0.08, 1.0)
	tex.modulate = Color(
		clampf(0.42 + fill_color.r * 0.70, 0.16, 1.25),
		clampf(0.42 + fill_color.g * 0.70, 0.16, 1.25),
		clampf(0.42 + fill_color.b * 0.70, 0.16, 1.25),
		tint_a
	)



func ensure_fx_ring_gpt_plate(ring: Control, color: Color, alpha: float = 0.40) -> void:
	# FX expanding rings: empty StyleBox host + GPT soft-flash plate (no border paint).
	if ring == null or not is_instance_valid(ring):
		return
	if ring is Panel:
		(ring as Panel).add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	var tex = ring.get_node_or_null("GptPanelPlate") as TextureRect
	if tex == null:
		var texture: Texture2D = optional_gpt_illustration_texture("ui_soft_flash")
		if texture == null:
			texture = optional_gpt_illustration_texture("ui_hand_tray_state_chip")
		if texture == null:
			return
		tex = TextureRect.new()
		tex.name = "GptPanelPlate"
		tex.texture = texture
		tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex.stretch_mode = TextureRect.STRETCH_SCALE
		tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tex.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		ring.add_child(tex)
		ring.move_child(tex, 0)
	var a = clampf(alpha, 0.05, 1.0)
	tex.modulate = Color(
		clampf(0.45 + color.r * 0.70, 0.18, 1.25),
		clampf(0.45 + color.g * 0.70, 0.18, 1.25),
		clampf(0.45 + color.b * 0.70, 0.18, 1.25),
		a
	)



func make_gpt_spark(size: Vector2, color: Color, plate_key: String = "ui_soft_flash") -> Control:
	# Tiny GPT soft-flash particle host (no StyleBoxFlat paint).
	var spark = make_gpt_plate_rect(Rect2(Vector2.ZERO, size), color, plate_key)
	spark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	spark.custom_minimum_size = size
	return spark


func configure_passive_container(container: Control) -> void:
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE

func make_label(parent: Control, text: String, font_size: int, color: Color, bold: bool) -> Label:
	var label = Label.new()
	label.text = text
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	if bold:
		label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
		label.add_theme_constant_override("shadow_offset_x", 1)
		label.add_theme_constant_override("shadow_offset_y", 1)
	parent.add_child(label)
	return label

func make_badge(parent: Control, rect: Rect2, text: String, font_size: int, fill: Color, border: Color, text_color: Color) -> Control:
	var badge = make_panel(parent, rect, fill, 9, border, 0)
	var label = make_label(badge, text, font_size, text_color, true)
	apply_rect(label, rect_full(0.08, 0.04, 0.92, 0.96))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	configure_clipped_label(label)
	return badge

func configure_clipped_label(label: Label) -> void:
	label.clip_text = true
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS

func node_from_instance_id(node_id: int) -> Node:
	if node_id == 0:
		return null
	var object = instance_from_id(node_id)
	if object == null or not is_instance_valid(object) or not object is Node:
		return null
	return object as Node

func queue_free_node_by_id(node_id: int) -> void:
	var node = node_from_instance_id(node_id)
	if node != null:
		node.queue_free()

func queue_free_nodes_by_ids(node_ids: Array) -> void:
	for node_id in node_ids:
		queue_free_node_by_id(int(node_id))

func queue_free_named_children_by_prefix(parent_id: int, prefix: String) -> void:
	var parent = node_from_instance_id(parent_id)
	if parent == null:
		return
	for child in parent.get_children():
		if str(child.name).begins_with(prefix):
			child.queue_free()

func set_label_text_by_id(label_id: int, text: String) -> void:
	var label = node_from_instance_id(label_id) as Label
	if label != null:
		label.text = text

func make_small_button(text: String, color: Color, callback: Callable) -> Button:
	var button = make_base_button(text, callback)
	button.custom_minimum_size = Vector2(104, 44)
	button.add_theme_font_size_override("font_size", 18)
	apply_button_style(button, color, 12, 2, 4)
	return button

func make_top_hud_button(text: String, color: Color, callback: Callable) -> Button:
	var button = make_base_button(text, callback)
	button.tooltip_text = text
	button.text = ""
	button.custom_minimum_size = TOP_HUD_BUTTON_SIZE
	button.clip_text = true
	button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	button.add_theme_font_size_override("font_size", 1)
	apply_button_style(button, color, 10, 1, 1)
	draw_top_hud_button_art(button, text, color)
	button.button_down.connect(Callable(self, "play_top_hud_button_press_feedback_by_id").bind(button.get_instance_id(), text, color))
	var icon_name = icon_name_for_button_text(text)
	if icon_name != "":
		add_lucide_icon(button, icon_name, rect_full(0.245, 0.220, 0.755, 0.780), Color(0.92, 0.94, 0.88, 0.88))
	return button

func draw_top_hud_button_art(button: Button, text: String, color: Color) -> Control:
	var art = Control.new()
	art.name = "TopHudButtonArt_%s" % text
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art.set_anchors_preset(Control.PRESET_FULL_RECT)
	button.add_child(art)
	# r180: GPT accents with smoke-stable names/geometry (IconBack/Rail/Seal).
	var icon_back = add_optional_gpt_illustration_texture(art, "ui_button_face_plate", rect_full(0.180, 0.170, 0.820, 0.830), 0.42, false)
	if icon_back == null:
		icon_back = make_gpt_plate_rect(rect_full(0.180, 0.170, 0.820, 0.830), Color(0.18, 0.13, 0.08, 0.20), "ui_button_face_plate")
		art.add_child(icon_back)
	icon_back.name = "TopHudButtonIconBack_%s" % text
	var rail = add_optional_gpt_illustration_texture(art, "ui_meter_rail_plate", rect_full(0.285, 0.815, 0.715, 0.845), 0.36, false)
	if rail == null:
		rail = make_gpt_plate_rect(rect_full(0.285, 0.815, 0.715, 0.845), Color(0.72, 0.50, 0.22, 0.18), "ui_meter_rail_plate")
		art.add_child(rail)
	rail.name = "TopHudButtonRail_%s" % text
	var seal = add_optional_gpt_illustration_texture(art, "ui_hand_tray_state_chip", rect_full(0.735, 0.305, 0.790, 0.695), 0.40, false)
	if seal == null:
		seal = make_gpt_plate_rect(rect_full(0.735, 0.305, 0.790, 0.695), Color(0.62, 0.18, 0.12, 0.20), "ui_hand_tray_state_chip")
		art.add_child(seal)
	seal.name = "TopHudButtonSeal_%s" % text
	return art

func play_top_hud_button_press_feedback(button: Button, text: String, color: Color) -> void:
	if button == null or not is_instance_valid(button):
		return
	var feedback = Control.new()
	feedback.name = "TopHudButtonPressFeedback_%s" % text
	feedback.mouse_filter = Control.MOUSE_FILTER_IGNORE
	feedback.set_anchors_preset(Control.PRESET_FULL_RECT)
	button.add_child(feedback)
	var wash = make_panel(feedback, rect_full(0.105, 0.125, 0.895, 0.875), Color(color.r, color.g, color.b, 0.10), 10, Color(1.0, 0.88, 0.52, 0.10), 0)
	wash.name = "TopHudButtonPressWash_%s" % text
	var glow = make_panel(feedback, rect_full(0.210, 0.205, 0.790, 0.795), Color(1.0, 0.84, 0.42, 0.050), 999, Color(color.r, color.g, color.b, 0.050), 0)
	glow.name = "TopHudButtonPressGlow_%s" % text
	var seal = make_panel(feedback, rect_full(0.700, 0.185, 0.820, 0.485), Color(color.r, color.g, color.b, 0.11), 999, Color(1.0, 0.88, 0.52, 0.070), 0)
	seal.name = "TopHudButtonPressSeal_%s" % text
	var glyph = make_label(seal, text.substr(0, 1) if text != "" else "行", 8, Color(0.98, 0.92, 0.66, 0.72), true)
	glyph.name = "TopHudButtonPressGlyph_%s" % text
	apply_rect(glyph, rect_full(0.0, 0.0, 1.0, 1.0))
	if fx_enabled_effective():
		feedback.modulate.a = 0.0
		wash.scale = Vector2(0.92, 0.90)
		glow.scale = Vector2(0.74, 0.74)
		seal.scale = Vector2(0.88, 0.88)
		var tw := create_tween()
		tw.bind_node(feedback)
		tw.set_parallel(true)
		tw.tween_property(feedback, "modulate:a", 0.88, 0.06).from(0.0)
		tw.tween_property(wash, "scale", Vector2.ONE, 0.16).from(Vector2(0.92, 0.90)).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tw.tween_property(glow, "scale", Vector2.ONE, 0.18).from(Vector2(0.74, 0.74)).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tw.tween_property(seal, "scale", Vector2(1.04, 1.04), 0.12).from(Vector2(0.88, 0.88)).set_ease(Tween.EASE_OUT)
		tw.set_parallel(false)
		tw.tween_property(feedback, "modulate:a", 0.0, 0.18).from(0.88).set_delay(0.05)
		tw.tween_callback(Callable(self, "queue_free_node_by_id").bind(feedback.get_instance_id()))
	else:
		feedback.modulate.a = 0.24

func play_top_hud_button_press_feedback_by_id(button_id: int, text: String, color: Color) -> void:
	var button = node_from_instance_id(button_id) as Button
	if button == null:
		return
	play_top_hud_button_press_feedback(button, text, color)

func make_base_button(text: String, callback: Callable) -> Button:
	var button = Button.new()
	button.text = text
	configure_touch_button(button)
	button.add_theme_color_override("font_color", Color(0.95, 0.93, 0.82))
	button.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.50))
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.98, 0.92))
	button.add_theme_constant_override("shadow_offset_x", 1)
	button.add_theme_constant_override("shadow_offset_y", 2)
	add_button_press_sheen(button)
	if callback.is_valid():
		connect_immediate_button_action(button, callback)
	return button

func add_button_press_sheen(button: Button) -> Control:
	var sheen = make_gpt_plate_rect(rect_full(0.06, 0.10, 0.94, 0.22), Color(1.0, 0.92, 0.58, 0.0), "ui_soft_flash")
	sheen.name = "ButtonPressSheen"
	button.add_child(sheen)
	button.button_down.connect(Callable(self, "play_button_press_sheen_by_id").bind(button.get_instance_id(), sheen.get_instance_id()))
	return sheen

func play_button_press_sheen_by_id(button_id: int, sheen_id: int) -> void:
	var button = node_from_instance_id(button_id) as Button
	var sheen = node_from_instance_id(sheen_id) as Control
	if button == null or sheen == null:
		return
	var tw := button.create_tween()
	tw.tween_property(sheen, "modulate:a", 0.28, 0.06).from(0.0)
	tw.tween_property(sheen, "modulate:a", 0.0, 0.16)

func configure_touch_button(button: Button) -> void:
	button.focus_mode = Control.FOCUS_NONE
	button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	# 增强的触摸反馈动画 - 加内发光 border flash
	var button_id := button.get_instance_id()
	button.button_down.connect(Callable(self, "play_touch_button_down_by_id").bind(button_id))
	button.button_up.connect(Callable(self, "play_touch_button_up_by_id").bind(button_id))

func center_touch_button_pivot_by_id(button_id: int) -> void:
	var button = node_from_instance_id(button_id) as Button
	if button != null:
		button.pivot_offset = button.size * 0.5

func play_touch_button_down_by_id(button_id: int) -> void:
	var button = node_from_instance_id(button_id) as Button
	if button == null:
		return
	center_touch_button_pivot_by_id(button_id)
	if OS.has_feature("mobile") and fx_enabled:
		Input.vibrate_handheld(18, 0.22)
	var tw := button.create_tween()
	tw.set_parallel(true)
	tw.tween_property(button, "scale", Vector2(0.96, 0.96), 0.08).from(Vector2(1.0, 1.0)).set_ease(Tween.EASE_OUT)
	tw.tween_property(button, "modulate", Color(0.92, 0.92, 0.92, 1.0), 0.08).from(Color(1, 1, 1, 1))
	var flash = make_fullrect_overlay(Color(GOLD_GLOW.r, GOLD_GLOW.g, GOLD_GLOW.b, 0.22), "ui_soft_flash")
	flash.name = "TouchButtonGptFlash"
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	button.add_child(flash)
	var fl_tw := button.create_tween()
	fl_tw.bind_node(flash)
	fl_tw.set_parallel(true)
	fl_tw.tween_property(flash, "modulate:a", 0.0, 0.16).from(0.22)
	fl_tw.tween_callback(Callable(self, "queue_free_node_by_id").bind(flash.get_instance_id())).set_delay(0.18)

func play_touch_button_up_by_id(button_id: int) -> void:
	var button = node_from_instance_id(button_id) as Button
	if button == null:
		return
	var tw := button.create_tween()
	tw.set_parallel(true)
	tw.tween_property(button, "scale", Vector2(1.0, 1.0), 0.12).from(Vector2(0.96, 0.96)).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tw.tween_property(button, "modulate", Color(1, 1, 1, 1), 0.12).from(Color(0.92, 0.92, 0.92, 1.0))

func connect_immediate_button_action(button: Button, callback: Callable) -> void:
	if button == null or not callback.is_valid():
		return
	button.button_down.connect(callback)

func ensure_button_gpt_face_plate(button: Button, color: Color) -> void:
	if button == null or not is_instance_valid(button):
		return
	var old_plate = button.get_node_or_null("GptButtonFacePlate")
	if old_plate != null and is_instance_valid(old_plate):
		button.remove_child(old_plate)
		old_plate.queue_free()
	var plate_keys := [
		"ui_button_face_plate",
		"action_button_panel",
		"ui_seat_info_plate",
		"ui_title_backplate",
		"ui_jade_reading_plate",
	]
	var texture: Texture2D = null
	for key in plate_keys:
		texture = optional_gpt_illustration_texture(str(key))
		if texture != null:
			break
	if texture == null:
		return
	var tex = TextureRect.new()
	tex.name = "GptButtonFacePlate"
	tex.texture = texture
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex.stretch_mode = TextureRect.STRETCH_SCALE
	tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tex.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var fill = soften_button_color(color)
	var tint_a = clampf(fill.a if fill.a > 0.001 else 0.88, 0.35, 1.0)
	tex.modulate = Color(
		clampf(0.40 + fill.r * 0.75, 0.18, 1.25),
		clampf(0.40 + fill.g * 0.75, 0.18, 1.25),
		clampf(0.40 + fill.b * 0.75, 0.18, 1.25),
		tint_a
	)
	button.add_child(tex)
	button.move_child(tex, 0)


func apply_button_style(button: Button, color: Color, radius: int, border_width: int = 2, shadow_size: int = 8) -> void:
	# Transparent style hosts keep hit-testing; visual face is GPT plate (no StyleBoxFlat paint).
	var pad := maxi(6, int(round(float(radius) * 0.35)))
	var empty_normal := StyleBoxEmpty.new()
	empty_normal.set_content_margin_all(pad)
	var empty_hover := StyleBoxEmpty.new()
	empty_hover.set_content_margin_all(pad)
	var empty_pressed := StyleBoxEmpty.new()
	empty_pressed.set_content_margin_all(maxi(4, pad - 1))
	button.add_theme_stylebox_override("normal", empty_normal)
	button.add_theme_stylebox_override("hover", empty_hover)
	button.add_theme_stylebox_override("pressed", empty_pressed)
	ensure_button_gpt_face_plate(button, color)

func icon_name_for_button_text(text: String) -> String:
	match text:
		"设置":
			return "settings"
		"返回":
			return "chevron-left"
		"更新":
			return "refresh-cw"
		"关闭":
			return "x"
		"试音":
			return "volume-2"
	return ""

func button_style_set(color: Color, radius: int, border_width: int = 2, shadow_size: int = 8) -> Dictionary:
	# Cache still returns StyleBoxFlat hosts, but alpha=0 — GPT button face paints the chrome.
	var key = button_style_set_cache_key(color, radius, border_width, shadow_size)
	if button_style_set_cache.has(key):
		return button_style_set_cache[key]
	var fill = soften_button_color(color)
	var cached_set = {
		"normal": style(Color(fill.r, fill.g, fill.b, 0.0), radius, Color(0, 0, 0, 0.0), 0, 0),
		"hover": style(Color(fill.r, fill.g, fill.b, 0.0), radius, Color(0, 0, 0, 0.0), 0, 0),
		"pressed": style(Color(fill.r, fill.g, fill.b, 0.0), radius, Color(0, 0, 0, 0.0), 0, 0),
	}
	store_button_style_set_cache(key, cached_set)
	return cached_set

func input_style_set() -> Dictionary:
	# r180: transparent StyleBoxFlat hosts (no extra content margins that inflate LineEdit min size).
	# GPT ui_online_form_field paints the field face.
	var key = "default"
	if input_style_set_cache.has(key):
		return input_style_set_cache[key]
	var normal = style(Color(0.120, 0.134, 0.112, 0.0), 10, Color(0.62, 0.54, 0.34, 0.0), 0, 0)
	var focus = style(Color(0.145, 0.160, 0.130, 0.0), 10, Color(0.82, 0.68, 0.34, 0.0), 0, 0)
	var read_only = style(Color(0.092, 0.104, 0.090, 0.0), 10, Color(0.40, 0.36, 0.24, 0.0), 0, 0)
	var cached_set = {
		"normal": normal,
		"focus": focus,
		"read_only": read_only,
	}
	store_input_style_set_cache(key, cached_set)
	return cached_set

func button_style_set_cache_key(color: Color, radius: int, border_width: int = 2, shadow_size: int = 8) -> String:
	return "%s:%d:%d:%d" % [color.to_html(true), radius, border_width, shadow_size]

func store_button_style_set_cache(key: String, cached_set: Dictionary) -> void:
	if key == "" or cached_set.is_empty():
		return
	if not button_style_set_cache.has(key):
		button_style_set_cache_order.append(key)
	button_style_set_cache[key] = cached_set
	while button_style_set_cache_order.size() > BUTTON_STYLE_SET_CACHE_LIMIT:
		var oldest = button_style_set_cache_order.pop_front()
		button_style_set_cache.erase(oldest)

func store_input_style_set_cache(key: String, cached_set: Dictionary) -> void:
	if key == "" or cached_set.is_empty():
		return
	if not input_style_set_cache.has(key):
		input_style_set_cache_order.append(key)
	input_style_set_cache[key] = cached_set
	while input_style_set_cache_order.size() > INPUT_STYLE_SET_CACHE_LIMIT:
		var oldest = input_style_set_cache_order.pop_front()
		input_style_set_cache.erase(oldest)

func style(color: Color, radius: int, border: Color, border_width: int, shadow_size: int = 8) -> StyleBoxFlat:
	# Host-only StyleBox: always transparent. GPT plates paint the chrome.
	var safe_color = Color(color.r, color.g, color.b, 0.0)
	var safe_border = Color(border.r, border.g, border.b, 0.0)
	var key = style_cache_key(safe_color, radius, safe_border, 0, 0)
	if style_cache.has(key):
		return style_cache[key]
	var box = StyleBoxFlat.new()
	box.bg_color = safe_color
	box.set_corner_radius_all(radius)
	box.set_border_width_all(0)
	box.border_color = safe_border
	box.shadow_color = Color(UI_PANEL_SHADOW.r, UI_PANEL_SHADOW.g, UI_PANEL_SHADOW.b, 0.0)
	box.shadow_size = 0
	store_style_cache(key, box)
	return box

func soften_panel_color(color: Color) -> Color:
	return Color(
		color.r * 0.42 + UI_PANEL_FILL.r * 0.58,
		color.g * 0.42 + UI_PANEL_FILL.g * 0.58,
		color.b * 0.42 + UI_PANEL_FILL.b * 0.58,
		min(1.0, color.a)
	)

func soften_button_color(color: Color) -> Color:
	return Color(
		color.r * 0.46 + UI_PANEL_FILL.r * 0.54,
		color.g * 0.46 + UI_PANEL_FILL.g * 0.54,
		color.b * 0.46 + UI_PANEL_FILL.b * 0.54,
		min(1.0, color.a)
	)

func soften_menu_color(color: Color) -> Color:
	return Color(
		color.r * 0.36 + UI_PANEL_FILL.r * 0.64,
		color.g * 0.36 + UI_PANEL_FILL.g * 0.64,
		color.b * 0.36 + UI_PANEL_FILL.b * 0.64,
		min(1.0, color.a)
	)

func style_cache_key(color: Color, radius: int, border: Color, border_width: int, shadow_size: int = 8) -> String:
	return "%s:%d:%s:%d:%d" % [color.to_html(true), radius, border.to_html(true), border_width, shadow_size]

func store_style_cache(key: String, box: StyleBoxFlat) -> void:
	if key == "" or box == null:
		return
	if not style_cache.has(key):
		style_cache_order.append(key)
	style_cache[key] = box
	while style_cache_order.size() > STYLE_CACHE_LIMIT:
		var oldest = style_cache_order.pop_front()
		style_cache.erase(oldest)

func rect_full(left: float, top: float, right: float, bottom: float) -> Rect2:
	return Rect2(Vector2(left, top), Vector2(right, bottom))

func apply_rect(control: Control, rect: Rect2) -> void:
	control.anchor_left = rect.position.x
	control.anchor_top = rect.position.y
	control.anchor_right = rect.size.x
	control.anchor_bottom = rect.size.y
	control.offset_left = 0
	control.offset_top = 0
	control.offset_right = 0
	control.offset_bottom = 0

func apply_centered_rect(control: Control, center: Vector2, size: Vector2) -> void:
	control.anchor_left = center.x
	control.anchor_top = center.y
	control.anchor_right = center.x
	control.anchor_bottom = center.y
	control.offset_left = -size.x * 0.5
	control.offset_top = -size.y * 0.5
	control.offset_right = size.x * 0.5
	control.offset_bottom = size.y * 0.5

func set_status(text: String) -> void:
	if status_label:
		status_label.text = text


# ============================================================
# 图标系统 / Icon System
# ============================================================

const ICON_CODES := {
	# Navigation
	"menu": "☰",
	"back": "←",
	"forward": "→",
	"up": "↑",
	"down": "↓",

	# Actions
	"play": "▶",
	"pause": "❚❚",
	"stop": "■",
	"refresh": "↻",
	"settings": "⚙",

	# Game specific
	"coin": "●",
	"gem": "◆",
	"star": "★",
	"heart": "♥",
	"trophy": "🏆",
	"fire": "🔥",

	# Status
	"check": "✓",
	"cross": "✗",
	"warning": "⚠",
	"info": "ℹ",
	"help": "?",

	# Chinese style decorations
	"cloud": "☁",
	"sun": "☀",
	"moon": "☾",
	"bamboo": "🎋",
	"flower": "❀",
	"dragon": "🐉",
}

func make_icon_label(parent: Control, icon_name: String, size: int, color: Color) -> Label:
	"""创建图标Label"""
	var icon_code = ICON_CODES.get(icon_name, "")
	var label = make_label(parent, icon_code, size, color, true)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return label

func make_icon_button(icon_name: String, color: Color, size: int = 24, callback: Callable = Callable()) -> Button:
	"""创建图标按钮"""
	var button = Button.new()
	button.text = ICON_CODES.get(icon_name, "")
	button.custom_minimum_size = Vector2(size * 1.8, size * 1.8)
	configure_touch_button(button)
	button.add_theme_font_size_override("font_size", size)
	button.add_theme_color_override("font_color", color)
	button.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.4))

	apply_button_style(button, Color(0.02, 0.03, 0.04, 0.90), max(8, int(size * 0.4)), 1, 0)

	if callback.is_valid():
		connect_immediate_button_action(button, callback)

	return button

func make_icon_badge(parent: Control, rect: Rect2, icon_name: String, bg_color: Color, icon_color: Color) -> Control:
	"""创建图标徽章"""
	var badge = make_panel(parent, rect, bg_color, 10, bg_color.lightened(0.2), 0)
	var icon = make_icon_label(badge, icon_name, max(12, int(rect.size.y * 0.5)), icon_color)
	apply_rect(icon, rect_full(0.1, 0.1, 0.9, 0.9))
	return badge

func draw_icon_in_panel(parent: Control, icon_name: String, rect: Rect2, color: Color) -> void:
	"""在面板中绘制图标"""
	var container = Control.new()
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(container, rect)

	var icon_code = ICON_CODES.get(icon_name, "")
	var label = make_label(container, icon_code, int(min(rect.size.x, rect.size.y) * 0.6), color, true)
	label.set_anchors_preset(Control.PRESET_FULL_RECT)

	parent.add_child(container)

func lucide_icon_path(icon_name: String) -> String:
	return "res://assets/icons/lucide/%s.svg" % icon_name

func lucide_icon_texture(icon_name: String) -> Texture2D:
	if icon_name == "":
		return null
	if icon_textures.has(icon_name):
		return icon_textures[icon_name]
	var path = lucide_icon_path(icon_name)
	if not ResourceLoader.exists(path):
		icon_textures[icon_name] = null
		return null
	var texture = load(path) as Texture2D
	icon_textures[icon_name] = texture
	return texture

func add_lucide_icon(parent: Control, icon_name: String, rect: Rect2, tint: Color = Color.WHITE) -> TextureRect:
	var texture = lucide_icon_texture(icon_name)
	if texture == null:
		return null
	var icon = TextureRect.new()
	icon.name = "Icon_%s" % icon_name
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.texture = texture
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.modulate = tint
	apply_rect(icon, rect)
	parent.add_child(icon)
	return icon

# ===== Shared data and animation helpers =====
func numeric_count(value, fallback: int = 0) -> int:
	if value == null:
		return fallback
	if typeof(value) == TYPE_ARRAY:
		return value.size()
	return int(value)

func fx_enabled_effective() -> bool:
	if offline_sim_quiet:
		return false
	return fx_enabled and fx_layer != null and is_instance_valid(fx_layer)

func get_shader_material(shader_name: String) -> ShaderMaterial:
	var base_mat = shader_materials.get(shader_name, null)
	if base_mat == null:
		return null
	return base_mat.duplicate() as ShaderMaterial

func apply_shader_to_control(control: Control, shader_name: String, params: Dictionary = {}) -> ShaderMaterial:
	var mat = get_shader_material(shader_name)
	if mat == null:
		return null
	for key in params.keys():
		mat.set_shader_parameter(key, params[key])
	control.material = mat
	return mat

func apply_ink_wash_shader(control: Control, grain: float = 0.04, vignette: float = 0.35, warmth: float = 0.06) -> ShaderMaterial:
	return apply_shader_to_control(control, "ink_wash_bg", {
		"grain_intensity": grain,
		"vignette_strength": vignette,
		"warmth": warmth,
		"brush_streak_intensity": 0.02,
		"time_scale": 0.0,
	})

func apply_glow_shader(control: Control, color: Color = Color(1.0, 0.88, 0.55, 1.0), intensity: float = 1.0, pulse_speed: float = 2.0) -> ShaderMaterial:
	return apply_shader_to_control(control, "glow_bloom", {
		"glow_color": color,
		"intensity": intensity,
		"pulse_speed": pulse_speed,
		"falloff_power": 3.0,
	})

func apply_water_ripple_shader(control: Control, color: Color = Color(0.72, 0.54, 0.28, 0.12), speed: float = 1.5) -> ShaderMaterial:  # r449 warm, no teal
	return apply_shader_to_control(control, "water_ripple", {
		"water_color": color,
		"ripple_speed": speed,
		"wave_frequency": 12.0,
		"wave_amplitude": 0.02,
		"wave_count": 4,
	})

func apply_gold_foil_shader(control: Control, speed: float = 0.8, sparkle: float = 0.4) -> ShaderMaterial:
	return apply_shader_to_control(control, "gold_foil_shimmer", {
		"shimmer_speed": speed,
		"shimmer_width": 0.15,
		"grain_intensity": 0.06,
		"sparkle_density": sparkle,
	})

func apply_brush_stroke_shader(control: Control, color: Color = Color(0.12, 0.16, 0.20, 1.0)) -> ShaderMaterial:
	return apply_shader_to_control(control, "brush_stroke", {
		"ink_color": color,
		"ink_bleed": 0.015,
		"dry_brush_intensity": 0.3,
	})

func animation_asset_spec(animation_name: String) -> Dictionary:
	if animation_name == "":
		return {}
	if animation_specs.has(animation_name):
		return animation_specs[animation_name]
	var path = str(ANIMATION_ASSET_PATHS.get(animation_name, ""))
	if path == "" or not FileAccess.file_exists(path):
		animation_specs[animation_name] = {}
		return {}
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		animation_specs[animation_name] = {}
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		animation_specs[animation_name] = {}
		return {}
	var source: Dictionary = parsed
	var spec := {
		"name": str(source.get("nm", animation_name)),
		"frame_rate": int(source.get("fr", 60)),
		"in_point": int(source.get("ip", 0)),
		"out_point": int(source.get("op", 0)),
		"width": int(source.get("w", 0)),
		"height": int(source.get("h", 0)),
		"layer_count": numeric_count(source.get("layers", []), 0),
	}
	animation_specs[animation_name] = spec
	return spec

func animation_duration_seconds(animation_name: String) -> float:
	var spec = animation_asset_spec(animation_name)
	var frame_rate = max(1, int(spec.get("frame_rate", 60)))
	var frame_count = max(1, int(spec.get("out_point", 0)) - int(spec.get("in_point", 0)))
	return float(frame_count) / float(frame_rate)

func draw_animation_preview(parent: Control, rect: Rect2, animation_name: String) -> Control:
	var spec = animation_asset_spec(animation_name)
	if spec.is_empty():
		return null
	var preview = Control.new()
	preview.name = "AnimationPreview_%s" % animation_name
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(preview, rect)
	parent.add_child(preview)
	match animation_name:
		"coin_spin":
			draw_coin_spin_preview(preview)
		"victory_sparkle":
			draw_victory_sparkle_preview(preview)
		"claim_response_orbit":
			draw_claim_response_orbit_preview(preview)
		"discard_ink_splash":
			draw_discard_ink_splash_preview(preview)
		"tile_draw_fly":
			draw_tile_draw_fly_preview(preview)
		"tile_discard_fly":
			draw_tile_discard_fly_preview(preview)
		"kong_reveal_burst":
			draw_kong_reveal_burst_preview(preview)
		_:
			make_icon_badge(preview, rect_full(0.08, 0.08, 0.92, 0.92), "star", Color(0.20, 0.24, 0.24, 0.72), GOLD_LIGHT)
	draw_animation_preview_timeline(preview, animation_name, spec)
	animate_animation_preview(preview, animation_name)
	return preview

func draw_animation_preview_timeline(parent: Control, animation_name: String, spec: Dictionary) -> Control:
	var timeline = Control.new()
	timeline.name = "AnimationPreviewTimeline_%s" % animation_name
	timeline.mouse_filter = Control.MOUSE_FILTER_IGNORE
	timeline.set_anchors_preset(Control.PRESET_FULL_RECT)
	parent.add_child(timeline)
	var frame_rate = max(1, int(spec.get("frame_rate", 60)))
	var frame_count = max(1, int(spec.get("out_point", 0)) - int(spec.get("in_point", 0)))
	var duration_ratio = clamp(float(frame_count) / float(frame_rate) / 2.4, 0.18, 1.0)
	var accent = animation_preview_accent(animation_name)
	var rail = make_gpt_route_rail(rect_full(0.120, 0.820, 0.880, 0.895), Color(0.006, 0.016, 0.018, 0.46))
	rail.name = "AnimationPreviewTimelineRail_%s" % animation_name
	timeline.add_child(rail)
	var fill = make_gpt_meter_fill(rect_full(0.030, 0.250, 0.030 + 0.900 * duration_ratio, 0.750), Color(accent.r, accent.g, accent.b, 0.30))
	fill.name = "AnimationPreviewTimelineFill_%s" % animation_name
	rail.add_child(fill)
	var gate = make_gpt_gate(rect_full(0.820, 0.700, 0.890, 0.930), Color(0.42, 0.74, 0.60, 0.24))
	gate.name = "AnimationPreviewPlayGate_%s" % animation_name
	timeline.add_child(gate)
	for i in range(3):
		var left = 0.270 + float(i) * 0.185
		var key = make_gpt_plate_rect(rect_full(left, 0.720, left + 0.034, 0.850), Color(accent.r, accent.g, accent.b, 0.26 - float(i) * 0.035))
		key.name = "AnimationPreviewKeyframe_%s_%d" % [animation_name, i]
		timeline.add_child(key)
	var tick = add_gpt_tick_strip(timeline, rect_full(0.645, 0.160, (0.645) + float(1) * (0.060) + (0.024), 0.310), Color(accent.r, accent.g, accent.b, 0.24), "AnimationPreviewTempoTick_%s_0" % [animation_name])
	return timeline

func draw_coin_spin_preview(parent: Control) -> void:
	var glow = make_panel(parent, rect_full(0.04, 0.04, 0.96, 0.96), Color(0.34, 0.26, 0.08, 0.36), 999, Color(0.96, 0.78, 0.32, 0.30), 0)
	glow.name = "CoinSpinGlow"
	var coin = make_panel(parent, rect_full(0.18, 0.18, 0.82, 0.82), Color(0.88, 0.68, 0.18, 0.94), 999, Color(1.0, 0.90, 0.48, 0.82), 0)
	coin.name = "CoinSpinCoin"
	add_lucide_icon(coin, "coin", rect_full(0.20, 0.20, 0.80, 0.80), Color(0.22, 0.13, 0.04, 0.72))

func draw_victory_sparkle_preview(parent: Control) -> void:
	var ring = make_panel(parent, rect_full(0.14, 0.14, 0.86, 0.86), Color(0, 0, 0, 0), 999, Color(0.96, 0.76, 0.28, 0.55), 0)
	ring.name = "VictorySparkleRing"
	var left = make_label(parent, "✦", 18, GOLD_BRIGHT, true)
	left.name = "VictorySparkleStar"
	apply_rect(left, rect_full(0.02, 0.18, 0.42, 0.60))
	var right = make_label(parent, "✧", 14, SCARLET_GLOW, true)
	right.name = "VictorySparkleStar"
	apply_rect(right, rect_full(0.58, 0.08, 0.98, 0.50))
	add_lucide_icon(parent, "sparkles", rect_full(0.28, 0.28, 0.72, 0.72), Color(0.96, 0.86, 0.42, 0.88))

func draw_claim_response_orbit_preview(parent: Control) -> void:
	var rail = make_panel(parent, rect_full(0.08, 0.42, 0.92, 0.58), Color(0.012, 0.026, 0.030, 0.70), 999, Color(0.88, 0.68, 0.32, 0.24), 0)
	rail.name = "ClaimResponseOrbitRail"
	var fill = make_gpt_meter_fill(rect_full(0.055, 0.320, 0.780, 0.680), Color(0.88, 0.68, 0.32, 0.34))
	fill.name = "ClaimResponseOrbitFill"
	rail.add_child(fill)
	var source = make_panel(parent, rect_full(0.030, 0.300, 0.250, 0.700), Color(0.20, 0.44, 0.40, 0.42), 999, Color(0.86, 0.76, 0.42, 0.18), 0)
	source.name = "ClaimResponseOrbitSource"
	var gate = make_panel(parent, rect_full(0.740, 0.230, 0.970, 0.770), Color(0.86, 0.66, 0.28, 0.34), 999, Color(1.0, 0.90, 0.52, 0.24), 0)
	gate.name = "ClaimResponseOrbitGate"
	add_lucide_icon(gate, "zap", rect_full(0.24, 0.24, 0.76, 0.76), Color(0.98, 0.88, 0.48, 0.86))
	var tick = add_gpt_tick_strip(parent, rect_full(0.335, 0.270, (0.335) + float(2) * (0.125) + (0.032), 0.730), Color(0.92, 0.76, 0.38, 0.28), "ClaimResponseOrbitTick_0")

func draw_discard_ink_splash_preview(parent: Control) -> void:
	var wake = make_panel(parent, rect_full(0.18, 0.18, 0.82, 0.82), Color(0, 0, 0, 0), 999, Color(0.86, 0.68, 0.34, 0.36), 0)  # r449 warm
	wake.name = "DiscardInkSplashWake"
	var ink = make_panel(parent, rect_full(0.310, 0.310, 0.690, 0.690), Color(0.06, 0.12, 0.13, 0.74), 999, Color(0.92, 0.76, 0.38, 0.22), 0)
	ink.name = "DiscardInkSplashCore"
	for i in range(6):
		var angle = float(i) * TAU / 6.0
		var cx = 0.50 + cos(angle) * (0.255 + float(i % 2) * 0.045)
		var cy = 0.50 + sin(angle) * (0.235 + float((i + 1) % 2) * 0.035)
		var dot = make_panel(parent, rect_full(cx - 0.035, cy - 0.035, cx + 0.035, cy + 0.035), Color(0.08, 0.16, 0.16, 0.54), 999, Color(0.86, 0.68, 0.34, 0.10), 0)  # r449 warm
		dot.name = "DiscardInkSplashDrop_%d" % i
	add_lucide_icon(parent, "sparkles", rect_full(0.345, 0.155, 0.655, 0.465), Color(0.96, 0.80, 0.36, 0.62))

func draw_tile_draw_fly_preview(parent: Control) -> void:
	var source = make_panel(parent, rect_full(0.045, 0.290, 0.230, 0.740), Color(0.34, 0.52, 0.42, 0.44), 8, Color(0.86, 0.72, 0.36, 0.28), 0)
	source.name = "TileDrawFlyWallSource"
	var route = make_panel(parent, rect_full(0.170, 0.475, 0.820, 0.545), Color(0.006, 0.016, 0.018, 0.46), 999, Color(0.42, 0.78, 0.62, 0.10), 0)
	route.name = "TileDrawFlyRoute"
	var fill = make_panel(route, rect_full(0.030, 0.250, 0.820, 0.750), Color(0.42, 0.78, 0.62, 0.32), 999, Color(0.96, 0.86, 0.50, 0.08), 0)
	fill.name = "TileDrawFlyRouteFill"
	var tile = make_panel(parent, rect_full(0.705, 0.235, 0.880, 0.735), Color(0.92, 0.88, 0.70, 0.94), 8, Color(0.24, 0.18, 0.10, 0.62), 0, "ui_button_face_plate")
	tile.name = "TileDrawFlyTile"
	var gate = make_panel(parent, rect_full(0.835, 0.365, 0.970, 0.655), Color(0.92, 0.74, 0.36, 0.20), 999, Color(1.0, 0.88, 0.52, 0.10), 0)
	gate.name = "TileDrawFlyHandGate"
	var tick = add_gpt_tick_strip(parent, rect_full(0.305, 0.390, (0.305) + float(2) * (0.135) + (0.028), 0.610), Color(0.42, 0.78, 0.62, 0.25), "TileDrawFlyTick_0")

func draw_tile_discard_fly_preview(parent: Control) -> void:
	var source = make_panel(parent, rect_full(0.060, 0.650, 0.285, 0.745), Color(0.34, 0.62, 0.54, 0.36), 999, Color(0.70, 0.90, 0.72, 0.10), 0)
	source.name = "TileDiscardFlyHandSource"
	var arc = make_panel(parent, rect_full(0.165, 0.145, 0.860, 0.765), Color(0, 0, 0, 0), 999, Color(0.92, 0.74, 0.36, 0.34), 0)
	arc.name = "TileDiscardFlyArc"
	var tile = make_panel(parent, rect_full(0.660, 0.130, 0.835, 0.630), Color(0.94, 0.90, 0.76, 0.94), 8, Color(0.28, 0.18, 0.10, 0.62), 0, "ui_button_face_plate")
	tile.name = "TileDiscardFlyTile"
	var river = make_panel(parent, rect_full(0.755, 0.660, 0.970, 0.745), Color(0.10, 0.20, 0.20, 0.42), 999, Color(0.56, 0.82, 0.72, 0.12), 0)
	river.name = "TileDiscardFlyRiverGate"
	var tick = add_gpt_tick_strip(parent, rect_full(0.275, 0.430, (0.275) + float(2) * (0.150) + (0.026), 0.620), Color(0.92, 0.74, 0.36, 0.25), "TileDiscardFlyTick_0")

func draw_kong_reveal_burst_preview(parent: Control) -> void:
	var burst = make_panel(parent, rect_full(0.115, 0.095, 0.885, 0.895), Color(0, 0, 0, 0), 999, Color(0.96, 0.78, 0.32, 0.32), 0)
	burst.name = "KongRevealBurstHalo"
	for i in range(4):
		var left = 0.190 + float(i) * 0.155
		var tile = make_panel(parent, rect_full(left, 0.330, left + 0.118, 0.700), Color(0.92, 0.88, 0.72, 0.95), 7, Color(0.28, 0.18, 0.10, 0.60), 0)
		tile.name = "KongRevealBurstTile_%d" % i
	var seal = make_panel(parent, rect_full(0.705, 0.120, 0.895, 0.355), Color(0.72, 0.18, 0.12, 0.60), 8, Color(1.0, 0.86, 0.46, 0.18), 0)
	seal.name = "KongRevealBurstSeal"
	var glyph = make_label(seal, "杠", 13, Color(0.98, 0.90, 0.62, 0.86), true)
	glyph.name = "KongRevealBurstGlyph"
	apply_rect(glyph, rect_full(0.0, 0.0, 1.0, 1.0))
	for i in range(4):
		var angle = -PI * 0.75 + float(i) * PI * 0.50
		var cx = 0.500 + cos(angle) * 0.325
		var cy = 0.505 + sin(angle) * 0.300
		var spark = make_panel(parent, rect_full(cx - 0.018, cy - 0.030, cx + 0.018, cy + 0.030), Color(0.96, 0.78, 0.32, 0.34 - float(i) * 0.035), 999, Color(1.0, 0.88, 0.52, 0.08), 0)
		spark.name = "KongRevealBurstSpark_%d" % i

func animation_preview_accent(animation_name: String) -> Color:
	match animation_name:
		"coin_spin":
			return GOLD_BRIGHT
		"victory_sparkle":
			return SCARLET_GLOW
		"claim_response_orbit":
			return JADE_LIGHT
		"discard_ink_splash":
			return Color(0.52, 0.74, 0.68, 1.0)
		"tile_draw_fly":
			return Color(0.42, 0.78, 0.62, 1.0)
		"tile_discard_fly":
			return Color(0.92, 0.74, 0.36, 1.0)
		"kong_reveal_burst":
			return Color(0.84, 0.48, 0.76, 1.0)
		_:
			return GOLD_LIGHT

func animate_animation_preview(preview: Control, animation_name: String) -> void:
	if not fx_enabled_effective() or DisplayServer.get_name().to_lower() == "headless":
		return
	var duration = clamp(animation_duration_seconds(animation_name), 0.6, 2.4)
	var tw := preview.create_tween()
	match animation_name:
		"coin_spin":
			tw.tween_property(preview, "rotation", TAU * 0.35, duration * 0.7).from(0.0).set_trans(Tween.TRANS_LINEAR)
			tw.parallel().tween_property(preview, "scale", Vector2(1.05, 1.05), duration * 0.35).from(Vector2.ONE).set_ease(Tween.EASE_OUT)
			tw.tween_property(preview, "scale", Vector2.ONE, duration * 0.35).set_ease(Tween.EASE_IN)
		"victory_sparkle":
			tw.tween_property(preview, "modulate:a", 0.76, duration * 0.30).from(1.0)
			tw.tween_property(preview, "modulate:a", 1.0, duration * 0.30).from(0.76)
			tw.parallel().tween_property(preview, "rotation", 0.08, duration * 0.4).from(-0.08)
			tw.tween_property(preview, "rotation", 0.0, duration * 0.3).from(0.08)
		"claim_response_orbit":
			var gate = preview.find_child("ClaimResponseOrbitGate", true, false)
			if gate != null:
				tw.tween_property(gate, "scale", Vector2(1.10, 1.10), duration * 0.25).from(Vector2(0.86, 0.86)).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
				tw.tween_property(gate, "scale", Vector2.ONE, duration * 0.25).set_ease(Tween.EASE_IN_OUT)
			else:
				tw.tween_property(preview, "modulate:a", 0.78, duration * 0.35).from(1.0)
		"discard_ink_splash":
			var wake = preview.find_child("DiscardInkSplashWake", true, false)
			if wake != null:
				tw.tween_property(wake, "scale", Vector2(1.18, 1.18), duration * 0.35).from(Vector2(0.78, 0.78)).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
				tw.parallel().tween_property(wake, "modulate:a", 0.25, duration * 0.35).from(0.86)
				tw.tween_property(wake, "scale", Vector2.ONE, duration * 0.25).set_ease(Tween.EASE_IN_OUT)
			else:
				tw.tween_property(preview, "scale", Vector2(1.06, 1.06), duration * 0.35).from(Vector2.ONE)
		"tile_draw_fly":
			var tile = preview.find_child("TileDrawFlyTile", true, false)
			if tile != null:
				tw.tween_property(tile, "position:x", 10.0, duration * 0.40).from(-10.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
				tw.parallel().tween_property(tile, "scale", Vector2(1.08, 1.08), duration * 0.30).from(Vector2(0.88, 0.88)).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		"tile_discard_fly":
			var tile = preview.find_child("TileDiscardFlyTile", true, false)
			if tile != null:
				tw.tween_property(tile, "rotation", -0.10, duration * 0.40).from(0.10).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
				tw.parallel().tween_property(tile, "position:y", -8.0, duration * 0.30).from(8.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		"kong_reveal_burst":
			var halo = preview.find_child("KongRevealBurstHalo", true, false)
			if halo != null:
				tw.tween_property(halo, "scale", Vector2(1.12, 1.12), duration * 0.28).from(Vector2(0.78, 0.78)).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
				tw.parallel().tween_property(halo, "modulate:a", 0.42, duration * 0.28).from(0.94)

# ===== Shared persistence helpers =====
func load_settings() -> void:
	var config = ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return
	music_enabled = bool(config.get_value("audio", "music_enabled", music_enabled))
	sfx_enabled = bool(config.get_value("audio", "sfx_enabled", sfx_enabled))
	tts_enabled = bool(config.get_value("audio", "tts_enabled", tts_enabled))
	fast_mode_enabled = bool(config.get_value("gameplay", "fast_mode_enabled", fast_mode_enabled))
	fx_enabled = bool(config.get_value("gameplay", "fx_enabled", fx_enabled))
	graphics_quality = clampi(int(config.get_value("gameplay", "graphics_quality", graphics_quality)), Commercial3DStage.QUALITY_AUTO, Commercial3DStage.QUALITY_HIGH)
	ai_assist_enabled = bool(config.get_value("gameplay", "ai_assist_enabled", ai_assist_enabled))
	ai_difficulty = clampi(int(config.get_value("gameplay", "ai_difficulty", ai_difficulty)), AI_DIFFICULTY_EASY, AI_DIFFICULTY_HARD)
	current_bgm_index = int(config.get_value("gameplay", "current_bgm_index", 0))
	if str(config.get_value("audio", "defaults_version", "")) != AUDIO_DEFAULTS_VERSION:
		music_enabled = true
		sfx_enabled = true
		tts_enabled = true
		save_settings()

func save_settings() -> void:
	var config = ConfigFile.new()
	config.set_value("audio", "music_enabled", music_enabled)
	config.set_value("audio", "sfx_enabled", sfx_enabled)
	config.set_value("audio", "tts_enabled", tts_enabled)
	config.set_value("audio", "defaults_version", AUDIO_DEFAULTS_VERSION)
	config.set_value("gameplay", "fast_mode_enabled", fast_mode_enabled)
	config.set_value("gameplay", "fx_enabled", fx_enabled)
	config.set_value("gameplay", "graphics_quality", graphics_quality)
	config.set_value("gameplay", "ai_assist_enabled", ai_assist_enabled)
	config.set_value("gameplay", "ai_difficulty", ai_difficulty)
	config.set_value("gameplay", "current_bgm_index", current_bgm_index)
	config.save(SETTINGS_PATH)

func load_game_stats() -> void:
	var config = ConfigFile.new()
	if config.load(STATS_PATH) != OK:
		game_stats = {
			"games_played": 0,
			"games_won": 0,
			"total_score": 0,
			"best_score": 0,
			"win_rate": 0.0,
			"total_hands": 0,
		}
		return
	game_stats = {
		"games_played": int(config.get_value("stats", "games_played", 0)),
		"games_won": int(config.get_value("stats", "games_won", 0)),
		"total_score": int(config.get_value("stats", "total_score", 0)),
		"best_score": int(config.get_value("stats", "best_score", 0)),
		"win_rate": float(config.get_value("stats", "win_rate", 0.0)),
		"total_hands": int(config.get_value("stats", "total_hands", 0)),
	}

func save_game_stats() -> void:
	var config = ConfigFile.new()
	config.set_value("stats", "games_played", game_stats.get("games_played", 0))
	config.set_value("stats", "games_won", game_stats.get("games_won", 0))
	config.set_value("stats", "total_score", game_stats.get("total_score", 0))
	config.set_value("stats", "best_score", game_stats.get("best_score", 0))
	config.set_value("stats", "win_rate", game_stats.get("win_rate", 0.0))
	config.set_value("stats", "total_hands", game_stats.get("total_hands", 0))
	config.save(STATS_PATH)

func load_tutorial_state() -> void:
	var config = ConfigFile.new()
	if config.load(TUTORIAL_PATH) == OK:
		tutorial_step = int(config.get_value("tutorial", "step", 0))
	else:
		tutorial_step = 0

func save_tutorial_state() -> void:
	var config = ConfigFile.new()
	config.set_value("tutorial", "step", tutorial_step)
	config.save(TUTORIAL_PATH)

func load_achievements() -> void:
	var config = ConfigFile.new()
	if config.load(ACHIEVEMENTS_PATH) == OK:
		for key in achievements.keys():
			achievements[key] = bool(config.get_value("achievements", key, false))
	else:
		# 初始化默认成就状态
		for key in achievements.keys():
			achievements[key] = false

func save_achievements() -> void:
	var config = ConfigFile.new()
	for key in achievements.keys():
		config.set_value("achievements", key, achievements[key])
	config.save(ACHIEVEMENTS_PATH)

func achievement_display_name(key: String) -> String:
	var names := {
		"first_win": "首次胡牌",
		"seven_pairs": "七对",
		"thirteen_orphans": "十三幺",
		"pure_one_suit": "清一色",
		"mixed_one_suit": "混一色",
		"big_three_dragons": "大三元",
		"small_three_dragons": "小三元",
		"big_four_winds": "大四喜",
		"small_four_winds": "小四喜",
		"all_honors": "字一色",
		"all_triplets": "碰碰胡",
		"full_straight": "一条龙",
		"concealed_hand": "门清胡牌",
		"self_draw": "自摸胡牌",
		"rob_gang": "抢杠胡",
		"five_wins": "五胜达人",
		"ten_wins": "十胜名手",
	}
	return str(names.get(key, key))

func load_login_state() -> void:
	var config = ConfigFile.new()
	if config.load(LOGIN_PATH) == OK:
		last_login_date = str(config.get_value("login", "last_date", ""))
		consecutive_login_days = int(config.get_value("login", "consecutive_days", 0))
	else:
		last_login_date = ""
		consecutive_login_days = 0

func save_login_state() -> void:
	var config = ConfigFile.new()
	config.set_value("login", "last_date", last_login_date)
	config.set_value("login", "consecutive_days", consecutive_login_days)
	config.save(LOGIN_PATH)

func check_and_update_login() -> Dictionary:
	var today = Time.get_date_string_from_system()
	var result = {
		"is_first_login_today": false,
		"consecutive_days": consecutive_login_days,
		"show_reward": false,
	}

	if last_login_date != today:
		# 今天首次登录
		result.is_first_login_today = true
		var yesterday = Time.get_date_string_from_unix_time(Time.get_unix_time_from_system() - 86400)
		if last_login_date == yesterday:
			# 连续登录
			consecutive_login_days += 1
		else:
			# 中断了，重新计数
			consecutive_login_days = 1
		last_login_date = today
		save_login_state()
		result.consecutive_days = consecutive_login_days
		result.show_reward = true
		# 重置每日任务
		reset_daily_tasks()

	return result

# ============================================================
# 赛季系统
# ============================================================

func load_season_data() -> void:
	var config = ConfigFile.new()
	if config.load(SEASON_PATH) == OK:
		season_data = {
			"season_id": str(config.get_value("season", "season_id", "")),
			"points": int(config.get_value("season", "points", 0)),
			"highest_rank": int(config.get_value("season", "highest_rank", 0)),
			"wins": int(config.get_value("season", "wins", 0)),
			"games": int(config.get_value("season", "games", 0)),
		}
	else:
		season_data = {
			"season_id": Time.get_date_string_from_system().substr(0, 7),  # YYYY-MM
			"points": 0,
			"highest_rank": 0,
			"wins": 0,
			"games": 0,
		}

func save_season_data() -> void:
	var config = ConfigFile.new()
	config.set_value("season", "season_id", season_data.get("season_id", ""))
	config.set_value("season", "points", season_data.get("points", 0))
	config.set_value("season", "highest_rank", season_data.get("highest_rank", 0))
	config.set_value("season", "wins", season_data.get("wins", 0))
	config.set_value("season", "games", season_data.get("games", 0))
	config.save(SEASON_PATH)

func get_current_rank() -> int:
	var points = int(season_data.get("points", 0))
	for i in range(SEASON_RANK_POINTS.size() - 1, -1, -1):
		if points >= SEASON_RANK_POINTS[i]:
			return i
	return 0

func get_rank_name(rank: int = -1) -> String:
	var r = rank if rank >= 0 else get_current_rank()
	return SEASON_RANKS[r] if r >= 0 and r < SEASON_RANKS.size() else "青铜"

func add_season_points(points: int, won: bool) -> void:
	season_data["points"] = int(season_data.get("points", 0)) + points
	season_data["games"] = int(season_data.get("games", 0)) + 1
	if won:
		season_data["wins"] = int(season_data.get("wins", 0)) + 1
	var current = get_current_rank()
	if current > int(season_data.get("highest_rank", 0)):
		season_data["highest_rank"] = current
	save_season_data()

# ============================================================
# 任务系统
# ============================================================

func load_tasks() -> void:
	var config = ConfigFile.new()
	if config.load(TASKS_PATH) == OK:
		last_task_reset_date = str(config.get_value("tasks", "last_reset", ""))
		var progress = config.get_value("tasks", "progress", {})
		if typeof(progress) == TYPE_DICTIONARY:
			task_progress = progress.duplicate()
	else:
		task_progress = {}
		last_task_reset_date = ""
	reset_daily_tasks()

func save_tasks() -> void:
	var config = ConfigFile.new()
	config.set_value("tasks", "last_reset", last_task_reset_date)
	config.set_value("tasks", "progress", task_progress)
	config.save(TASKS_PATH)

func reset_daily_tasks() -> void:
	var today = Time.get_date_string_from_system()
	if last_task_reset_date != today:
		last_task_reset_date = today
		task_progress.clear()
		for task in DAILY_TASKS:
			task_progress[task.id] = 0
		daily_tasks = DAILY_TASKS.duplicate()
		save_tasks()


func get_task_status(task_id: String) -> Dictionary:
	for task in DAILY_TASKS:
		if task.id == task_id:
			var progress = int(task_progress.get(task_id, 0))
			var target = int(task.get("target", 1))
			return {
				"desc": task.get("desc", ""),
				"progress": progress,
				"target": target,
				"reward": int(task.get("reward_coins", 0)),
				"completed": progress >= target,
			}
	return {}

# ============================================================
# 道具系统
# ============================================================

func load_inventory() -> void:
	var config = ConfigFile.new()
	if config.load(INVENTORY_PATH) == OK:
		var inv = config.get_value("inventory", "items", {})
		if typeof(inv) == TYPE_DICTIONARY:
			inventory = inv.duplicate()
	else:
		inventory = {}

func save_inventory() -> void:
	var config = ConfigFile.new()
	config.set_value("inventory", "items", inventory)
	config.save(INVENTORY_PATH)

func add_item(item_id: String, count: int = 1) -> void:
	inventory[item_id] = int(inventory.get(item_id, 0)) + count
	save_inventory()

func get_item_count(item_id: String) -> int:
	return int(inventory.get(item_id, 0))

func item_display_name(item_id: String) -> String:
	if ITEM_TYPES.has(item_id):
		return str((ITEM_TYPES[item_id] as Dictionary).get("name", item_id))
	return item_id

# ============================================================
# 虚拟货币系统
# ============================================================

func load_currency() -> void:
	var config = ConfigFile.new()
	if config.load(CURRENCY_PATH) == OK:
		currency = {
			"coins": int(config.get_value("currency", "coins", 0)),
			"gems": int(config.get_value("currency", "gems", 0)),
		}
	else:
		currency = {"coins": 500, "gems": 10}  # 初始货币

func save_currency() -> void:
	var config = ConfigFile.new()
	config.set_value("currency", "coins", currency.get("coins", 0))
	config.set_value("currency", "gems", currency.get("gems", 0))
	config.save(CURRENCY_PATH)

func can_afford_gems(amount: int) -> bool:
	return int(currency.get("gems", 0)) >= amount

func spend_gems(amount: int) -> bool:
	if not can_afford_gems(amount):
		return false
	currency["gems"] = int(currency.get("gems", 0)) - amount
	save_currency()
	return true

func record_game_result(won: bool, score: int, hands_played: int) -> void:
	game_stats["games_played"] = int(game_stats.get("games_played", 0)) + 1
	game_stats["total_hands"] = int(game_stats.get("total_hands", 0)) + hands_played
	game_stats["total_score"] = int(game_stats.get("total_score", 0)) + score
	if won:
		game_stats["games_won"] = int(game_stats.get("games_won", 0)) + 1
	if score > int(game_stats.get("best_score", 0)):
		game_stats["best_score"] = score
	var played = int(game_stats.get("games_played", 0))
	game_stats["win_rate"] = float(game_stats.get("games_won", 0)) / float(max(1, played))
	save_game_stats()

func load_offline_progress() -> bool:
	var config = ConfigFile.new()
	if config.load(PROGRESS_PATH) != OK:
		return false
	dealer_seat = int(config.get_value("progress", "dealer_seat", 0))
	offline_hand_number = int(config.get_value("progress", "hand_number", 1))
	players.clear()
	for i in range(4):
		var section = "player_%d" % i
		players.append({
			"name": str(config.get_value(section, "name", SEAT_NAMES[i])) if config.has_section(section) else SEAT_NAMES[i],
			"hand": [],
			"discards": [],
			"melds": [],
			"flowers": 0,
			"flower_tiles": [],
			"score": int(config.get_value(section, "score", MATCH_START_SCORE)) if config.has_section(section) else MATCH_START_SCORE,
			"bot": i != 0,
		})
	return true

func save_offline_progress() -> void:
	if offline_sim_quiet:
		return
	if mode != "offline":
		return
	var config = ConfigFile.new()
	config.set_value("progress", "dealer_seat", dealer_seat)
	config.set_value("progress", "hand_number", offline_hand_number)
	config.set_value("progress", "saved_time", Time.get_unix_time_from_system())
	for i in range(4):
		var section = "player_%d" % i
		config.set_value(section, "name", players[i].get("name", SEAT_NAMES[i]))
		config.set_value(section, "score", players[i].get("score", MATCH_START_SCORE))
	config.save(PROGRESS_PATH)
	set_status("进度已保存 (第%d局)" % offline_hand_number)

func reset_offline_progress() -> void:
	var dir = DirAccess.open("user://")
	if dir != null and dir.file_exists("offline_progress.cfg"):
		dir.remove("offline_progress.cfg")
	reset_progress_confirming = false
	set_status("进度已重置")

# ===== Shared startup assets and tile metadata =====
func setup_tile_order() -> void:
	if tile_metadata_ready:
		return
	tile_order.clear()
	tile_sort_order.clear()
	tile_suit_cache.clear()
	tile_number_cache.clear()
	tile_flower_cache.clear()
	tile_honor_cache.clear()
	tile_terminal_or_honor_cache.clear()
	tile_simple_number_cache.clear()
	tile_thirteen_orphans_cache.clear()
	thirteen_orphans_indices.clear()
	tile_label_cache.clear()
	tile_speech_label_cache.clear()
	tile_face_main_cache.clear()
	tile_face_sub_cache.clear()
	tile_corner_cache.clear()
	tile_accent_cache.clear()
	var orphan_lookup: Dictionary = {}
	for orphan_code in THIRTEEN_ORPHANS_CODES:
		orphan_lookup[str(orphan_code)] = true
	for i in range(TILE_CODES.size()):
		var code = str(TILE_CODES[i])
		var is_orphan = orphan_lookup.has(code)
		tile_order[code] = i
		tile_sort_order[code] = i
		tile_flower_cache[code] = false
		tile_honor_cache[code] = i >= 27
		tile_thirteen_orphans_cache[code] = is_orphan
		if is_orphan:
			thirteen_orphans_indices.append(i)
		if i < 27:
			var suit = int(i / 9)
			var rank = i % 9 + 1
			var rank_text = str(rank)
			var suit_text = suit_label(suit_code(suit))
			tile_suit_cache[code] = suit
			tile_number_cache[code] = true
			tile_terminal_or_honor_cache[code] = rank == 1 or rank == 9
			tile_simple_number_cache[code] = rank >= 2 and rank <= 8
			tile_label_cache[code] = rank_text + suit_text
			tile_speech_label_cache[code] = str(TILE_RANK_SPEECH_LABELS[rank - 1]) + suit_text
			tile_face_main_cache[code] = rank_text
			tile_face_sub_cache[code] = suit_text
			tile_corner_cache[code] = rank_text
			match suit:
				0:
					tile_accent_cache[code] = Color(0.70, 0.12, 0.12)
				1:
					tile_accent_cache[code] = Color(0.06, 0.46, 0.25)
				2:
					tile_accent_cache[code] = Color(0.08, 0.25, 0.68)
		else:
			var label = ""
			var speech_label = ""
			var sub = ""
			var accent = Color(0.12, 0.15, 0.15)
			match code:
				"E":
					label = "东"
					speech_label = "东风"
					sub = "风"
				"S":
					label = "南"
					speech_label = "南风"
					sub = "风"
				"N":
					label = "西"
					speech_label = "西风"
					sub = "风"
				"R":
					label = "北"
					speech_label = "北风"
					sub = "风"
				"Z":
					label = "中"
					speech_label = "红中"
					sub = "箭"
					accent = Color(0.70, 0.12, 0.12)
				"F":
					label = "发"
					speech_label = "发财"
					sub = "箭"
					accent = Color(0.06, 0.46, 0.25)
				"P":
					label = "白"
					speech_label = "白板"
					sub = "箭"
			tile_suit_cache[code] = -1
			tile_number_cache[code] = false
			tile_terminal_or_honor_cache[code] = true
			tile_simple_number_cache[code] = false
			tile_label_cache[code] = label
			tile_speech_label_cache[code] = speech_label
			tile_face_main_cache[code] = label
			tile_face_sub_cache[code] = sub
			tile_corner_cache[code] = label
			tile_accent_cache[code] = accent
	for i in range(FLOWER_CODES.size()):
		var flower_code = str(FLOWER_CODES[i])
		var flower_label = str(FLOWER_LABELS[i])
		tile_sort_order[flower_code] = TILE_CODES.size() + i
		tile_suit_cache[flower_code] = -1
		tile_number_cache[flower_code] = false
		tile_flower_cache[flower_code] = true
		tile_honor_cache[flower_code] = false
		tile_terminal_or_honor_cache[flower_code] = false
		tile_simple_number_cache[flower_code] = false
		tile_thirteen_orphans_cache[flower_code] = false
		tile_label_cache[flower_code] = flower_label
		tile_speech_label_cache[flower_code] = flower_label
		tile_face_main_cache[flower_code] = flower_label
		tile_face_sub_cache[flower_code] = "花"
		tile_corner_cache[flower_code] = "花"
		tile_accent_cache[flower_code] = Color(0.68, 0.32, 0.08)
	tile_metadata_ready = true

func load_assets() -> void:
	# 优先加载关键资源
	var ui_capture_mode := OS.get_environment("YUNZHUO_UI_CAPTURE") == "1"
	felt_texture = load("res://assets/table/table_felt_green.jpg")
	wood_texture = load("res://assets/table/table_dark_wood.jpg")
	tile_back = load_illustration_texture("res://assets/tiles/tile_back.png")
	illustration_textures.clear()
	for key in ILLUSTRATION_ASSET_PATHS.keys():
		var path = str(ILLUSTRATION_ASSET_PATHS[key])
		var texture = load_illustration_texture(path)
		if texture != null:
			illustration_textures[key] = texture
	optional_gpt_illustration_textures.clear()
	for key in GPT_ILLUSTRATION_ASSET_PATHS.keys():
		var path = str(GPT_ILLUSTRATION_ASSET_PATHS[key])
		if not FileAccess.file_exists(path):
			continue
		var texture = load_illustration_texture(path)
		if texture != null:
			optional_gpt_illustration_textures[key] = texture

	# 着色器材质加载
	shader_materials.clear()
	for key in SHADER_PATHS.keys():
		var shader = load(str(SHADER_PATHS[key]))
		if shader != null:
			var mat = ShaderMaterial.new()
			mat.shader = shader
			shader_materials[key] = mat

	# 音频资源立即加载；截图捕获不需要音频后端，跳过以降低低资源 QA 耗时。
	if ui_capture_mode:
		audio_streams.clear()
	else:
		audio_streams = {
			"bgm": load(BGM_STREAM_PATH),
			"bird": load("res://assets/audio/bird.mp3"),
			"discard": load("res://assets/audio/discard.mp3"),
			"draw": load("res://assets/audio/draw.mp3"),
			"gang": load("res://assets/audio/kong.mp3"),
			"peng": load("res://assets/audio/pong.mp3"),
			"win": load("res://assets/audio/win.mp3"),
		}
		if audio_streams.get("bgm") == null:
			print("BGM: 警告 - BGM文件加载失败！")
		else:
			print("BGM: BGM文件加载成功，类型:", audio_streams.get("bgm").get_class())

	# 麻将牌纹理延迟加载（在空闲时间加载）
	call_deferred("_load_tile_textures")

	# 语音资源延迟加载
	if not ui_capture_mode:
		call_deferred("load_voice_assets")

func _load_tile_textures() -> void:
	tile_textures.clear()
	tile_decal_textures.clear()
	for code in TILE_CODES:
		tile_textures[code] = load_tile_texture(tile_path(code))
		tile_decal_textures[code] = load_tile_texture(tile_decal_path(code))
	for code in FLOWER_CODES:
		tile_textures[code] = load_tile_texture(tile_path(code))
		tile_decal_textures[code] = load_tile_texture(tile_decal_path(code))

func load_tile_texture(path: String) -> Texture2D:
	return load_illustration_texture(path)

func verify_audio_assets() -> void:
	# 验证所有音频资源已正确加载
	print("AudioVerify: Starting audio asset verification...")
	var all_ok = true
	var required_audio = ["bgm", "discard", "draw", "peng", "gang", "win"]

	for audio_key in required_audio:
		var stream = audio_streams.get(audio_key)
		if stream == null:
			print("AudioVerify: ERROR - Missing audio: ", audio_key)
			all_ok = false
		else:
			print("AudioVerify: OK - ", audio_key, " (", stream.get_class(), ")")

	if all_ok:
		print("AudioVerify: All audio assets verified successfully")
	else:
		print("AudioVerify: WARNING - Some audio assets failed to load")
		# 尝试重新加载失败的资源
		for audio_key in required_audio:
			if audio_streams.get(audio_key) == null:
				print("AudioVerify: Attempting to reload ", audio_key)
				match audio_key:
					"bgm":
						audio_streams["bgm"] = load(BGM_STREAM_PATH)
					"discard":
						audio_streams["discard"] = load("res://assets/audio/discard.mp3")
					"draw":
						audio_streams["draw"] = load("res://assets/audio/draw.mp3")
					"peng":
						audio_streams["peng"] = load("res://assets/audio/pong.mp3")
					"gang":
						audio_streams["gang"] = load("res://assets/audio/kong.mp3")
					"win":
						audio_streams["win"] = load("res://assets/audio/win.mp3")
	print("麻将牌纹理加载完成")

func load_voice_assets() -> void:
	voice_streams.clear()
	for code in TILE_CODES + FLOWER_CODES:
		load_voice_stream(voice_clip_key_for_tile(str(code)))
	for key in ["action_chi", "action_peng", "action_gang", "action_hidden_gang", "action_added_gang", "action_hu", "action_zimo"]:
		load_voice_stream(key)

func load_voice_stream(key: String) -> void:
	if key == "":
		return
	var path = "res://assets/audio/voice/%s.mp3" % key
	if not ResourceLoader.exists(path):
		return
	var stream = load(path)
	if stream != null:
		voice_streams[key] = stream

func voice_clip_key_for_tile(tile: String) -> String:
	if tile == "":
		return ""
	return "tile_" + tile

func voice_clip_key_for_action(action: String) -> String:
	match action:
		"吃":
			return "action_chi"
		"碰":
			return "action_peng"
		"杠":
			return "action_gang"
		"暗杠":
			return "action_hidden_gang"
		"补杠":
			return "action_added_gang"
		"胡":
			return "action_hu"
		"自摸":
			return "action_zimo"
	return ""


func ensure_master_audio_bus() -> void:
	var master_index = AudioServer.get_bus_index("Master")
	if master_index >= 0:
		AudioServer.set_bus_mute(master_index, false)
		AudioServer.set_bus_volume_db(master_index, 0.0)

func ensure_audio_layer() -> Node:
	if audio_layer != null and is_instance_valid(audio_layer):
		return audio_layer
	audio_layer = get_node_or_null("PersistentAudio")
	if audio_layer == null:
		audio_layer = Node.new()
		audio_layer.name = "PersistentAudio"
		audio_layer.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(audio_layer)
	return audio_layer

func attach_audio_node(node: Node) -> void:
	if node == null:
		return
	var layer = ensure_audio_layer()
	if node.get_parent() == layer:
		return
	if node.get_parent() != null:
		node.get_parent().remove_child(node)
	layer.add_child(node)

func normalize_tile_code(code: String) -> String:
	# Map legacy aliases so river/meld never fall through to tile_back.
	# Canonical suits: W=万 T=条 B=筒; honors E/S/N/R/Z/F/P.
	var c := str(code).strip_edges()
	if c.is_empty():
		return c
	if is_flower_tile(c):
		return c
	if c.length() == 2 and c[0] >= "1" and c[0] <= "9":
		var suit := c.substr(1, 1)
		if suit == "S":
			# Legacy sou (条) suffix → T
			return c[0] + "T"
		if suit == "P":
			# Legacy pin (筒) suffix → B (honor 白 is bare "P")
			return c[0] + "B"
	match c:
		"W":
			return "N"  # 西
		"C":
			return "Z"  # 中
		"B":
			return "P"  # 白 (bare B alias)
		_:
			pass
	return c


func tile_path(code: String) -> String:
	code = normalize_tile_code(code)
	if is_flower_tile(code):
		return preferred_tile_path("res://assets/tiles/tile_flower_%s.png" % code.to_lower())
	if code.length() >= 2 and code.ends_with("W"):
		return preferred_tile_path("res://assets/tiles/tile_man%s.png" % code.left(code.length() - 1))
	if code.length() >= 2 and code.ends_with("T"):
		return preferred_tile_path("res://assets/tiles/tile_sou%s.png" % code.left(code.length() - 1))
	if code.length() >= 2 and code.ends_with("B"):
		return preferred_tile_path("res://assets/tiles/tile_pin%s.png" % code.left(code.length() - 1))
	match code:
		"E":
			return preferred_tile_path("res://assets/tiles/tile_honor_east.png")
		"S":
			return preferred_tile_path("res://assets/tiles/tile_honor_south.png")
		"N":
			return preferred_tile_path("res://assets/tiles/tile_honor_west.png")
		"R":
			return preferred_tile_path("res://assets/tiles/tile_honor_north.png")
		"Z":
			return preferred_tile_path("res://assets/tiles/tile_honor_red.png")
		"F":
			return preferred_tile_path("res://assets/tiles/tile_honor_green.png")
		"P":
			return preferred_tile_path("res://assets/tiles/tile_honor_white.png")
	return "res://assets/tiles/tile_back.png"

func preferred_tile_path(primary: String) -> String:
	# Authoritative runtime faces live in assets/tiles.
	if FileAccess.file_exists(primary):
		return primary
	var subtle_3d_path = primary.replace("res://assets/tiles/", "res://assets/tiles_subtle_3d/")
	if FileAccess.file_exists(subtle_3d_path):
		return subtle_3d_path
	return "res://assets/tiles/tile_back.png"

func tile_decal_path(code: String) -> String:
	var source_path := tile_path(code)
	var decal_path := "res://assets/tile_decals_3d/%s" % source_path.get_file()
	return decal_path if FileAccess.file_exists(decal_path) else source_path

func suit_code(suit: int) -> String:
	match suit:
		0:
			return "W"
		1:
			return "T"
		2:
			return "B"
	return ""

func suit_label(suit: String) -> String:
	match suit:
		"W":
			return "万"
		"T":
			return "条"
		"B":
			return "筒"
	return suit

func tile_index(tile: String) -> int:
	if not tile_metadata_ready:
		setup_tile_order()
	return int(tile_order.get(tile, -1))

func tile_sort_index(tile: String) -> int:
	if not tile_metadata_ready:
		setup_tile_order()
	if tile_sort_order.has(tile):
		return int(tile_sort_order[tile])
	var flower_index = FLOWER_CODES.find(tile)
	if flower_index >= 0:
		return TILE_CODES.size() + flower_index
	var index = tile_index(tile)
	if index >= 0:
		return index
	return TILE_CODES.size() + FLOWER_CODES.size() + 1

func is_flower_tile(tile: String) -> bool:
	if not tile_metadata_ready:
		setup_tile_order()
	if tile_flower_cache.has(tile):
		return bool(tile_flower_cache[tile])
	return FLOWER_CODES.has(tile)

# ===== Shared tile collection helpers =====
func is_number_tile(tile: String) -> bool:
	if not tile_metadata_ready:
		setup_tile_order()
	if tile_number_cache.has(tile):
		return bool(tile_number_cache[tile])
	return tile.ends_with("W") or tile.ends_with("T") or tile.ends_with("B")


func tile_counts(tiles: Array) -> Array:
	var counts = make_empty_tile_counts()
	for tile in tiles:
		var index = tile_index(str(tile))
		if index >= 0:
			counts[index] = int(counts[index]) + 1
	return counts

func make_empty_tile_counts() -> Array:
	return EMPTY_TILE_COUNTS_TEMPLATE.duplicate(false)

func tile_count_from_counts(tile: String, counts: Array) -> int:
	var index = tile_index(tile)
	if index < 0 or index >= counts.size():
		return 0
	return int(counts[index])

func tile_presence_set(tiles: Array) -> Dictionary:
	var result: Dictionary = {}
	for tile in tiles:
		var code = str(tile)
		if code != "":
			result[code] = true
	return result

func has_tile_list(hand: Array, tiles: Array) -> bool:
	var copy = hand.duplicate()
	return remove_tile_list(copy, tiles)

func consume_tile_count(counts: Array, tile: String, amount: int) -> bool:
	var index = tile_index(tile)
	if index < 0 or index >= counts.size() or amount <= 0:
		return false
	if int(counts[index]) < amount:
		return false
	counts[index] = int(counts[index]) - amount
	return true

func consume_tile_list_counts(counts: Array, tiles: Array) -> bool:
	var tile_size = tiles.size()
	if tile_size == 0:
		return true
	if tile_size == 1:
		return consume_tile_count(counts, str(tiles[0]), 1)
	if tile_size == 2:
		var first_index = tile_index(str(tiles[0]))
		var second_index = tile_index(str(tiles[1]))
		if first_index < 0 or second_index < 0 or first_index >= counts.size() or second_index >= counts.size():
			return false
		if first_index == second_index:
			if int(counts[first_index]) < 2:
				return false
			counts[first_index] = int(counts[first_index]) - 2
			return true
		if int(counts[first_index]) <= 0 or int(counts[second_index]) <= 0:
			return false
		counts[first_index] = int(counts[first_index]) - 1
		counts[second_index] = int(counts[second_index]) - 1
		return true
	var required: Dictionary = {}
	for tile in tiles:
		var index = tile_index(str(tile))
		if index < 0 or index >= counts.size():
			return false
		required[index] = int(required.get(index, 0)) + 1
	for index in required.keys():
		if int(counts[int(index)]) < int(required[index]):
			return false
	for index in required.keys():
		counts[int(index)] = int(counts[int(index)]) - int(required[index])
	return true

func restore_tile_list_counts(counts: Array, tiles: Array) -> void:
	for tile in tiles:
		var index = tile_index(str(tile))
		if index >= 0 and index < counts.size():
			counts[index] = int(counts[index]) + 1

func has_tile_list_counts(counts: Array, tiles: Array) -> bool:
	var tile_size = tiles.size()
	if tile_size == 0:
		return true
	if tile_size == 1:
		var single_index = tile_index(str(tiles[0]))
		return single_index >= 0 and single_index < counts.size() and int(counts[single_index]) > 0
	if tile_size == 2:
		var first_index = tile_index(str(tiles[0]))
		var second_index = tile_index(str(tiles[1]))
		if first_index < 0 or second_index < 0 or first_index >= counts.size() or second_index >= counts.size():
			return false
		if first_index == second_index:
			return int(counts[first_index]) >= 2
		return int(counts[first_index]) > 0 and int(counts[second_index]) > 0
	var required: Dictionary = {}
	for tile in tiles:
		var index = tile_index(str(tile))
		if index < 0 or index >= counts.size():
			return false
		required[index] = int(required.get(index, 0)) + 1
	for index in required.keys():
		if int(counts[int(index)]) < int(required[index]):
			return false
	return true

func remove_known_tile_list(hand: Array, tiles: Array) -> bool:
	for tile in tiles:
		var index = find_tile_in_hand(hand, str(tile))
		if index < 0:
			return false
		hand.remove_at(index)
	return true

func remove_known_tiles(hand: Array, tile: String, amount: int) -> bool:
	if amount <= 0:
		return false
	for n in range(amount):
		var index = find_tile_in_hand(hand, tile)
		if index < 0:
			return false
		hand.remove_at(index)
	return true

func remove_tile_list(hand: Array, tiles: Array) -> bool:
	for tile in tiles:
		if count_tile(hand, str(tile)) <= 0:
			return false
	for tile in tiles:
		var index = find_tile_in_hand(hand, str(tile))
		if index >= 0:
			hand.remove_at(index)
	return true

func remove_tiles(hand: Array, tile: String, amount: int) -> bool:
	if count_tile(hand, tile) < amount:
		return false
	for n in range(amount):
		var index = find_tile_in_hand(hand, tile)
		if index >= 0:
			hand.remove_at(index)
	return true

func find_tile_in_hand(hand: Array, tile: String) -> int:
	for i in range(hand.size()):
		if str(hand[i]) == tile:
			return i
	return -1

func count_tile(hand: Array, tile: String) -> int:
	var count = 0
	for item in hand:
		if str(item) == tile:
			count += 1
	return count

func add_log(text: String) -> void:
	if offline_sim_quiet:
		return
	table_logs.append(text)
	while table_logs.size() > 10:
		table_logs.pop_front()

func log_performance_stats() -> void:
	# 输出性能统计信息
	var stats_lines: Array[String] = []

	if perf_render_count > 0:
		var avg_render = perf_render_total_ms / float(perf_render_count)
		stats_lines.append("渲染: %d次, 平均%.1fms" % [perf_render_count, avg_render])

	if perf_ai_decision_count > 0:
		var avg_ai = perf_ai_decision_total_ms / float(perf_ai_decision_count)
		stats_lines.append("AI决策: %d次, 平均%.1fms" % [perf_ai_decision_count, avg_ai])

	# 缓存统计
	var total_shanten = shanten_cache_hits + shanten_cache_misses
	if total_shanten > 0:
		var shanten_hit_rate = float(shanten_cache_hits) / float(total_shanten) * 100.0
		stats_lines.append("向听缓存: %.1f%% (%d/%d)" % [shanten_hit_rate, shanten_cache_hits, total_shanten])

	var total_effective = effective_tiles_cache_hits + effective_tiles_cache_misses
	if total_effective > 0:
		var effective_hit_rate = float(effective_tiles_cache_hits) / float(total_effective) * 100.0
		stats_lines.append("进张缓存: %.1f%% (%d/%d)" % [effective_hit_rate, effective_tiles_cache_hits, total_effective])

	var total_ai_report = ai_report_cache_hits + ai_report_cache_misses
	if total_ai_report > 0:
		var ai_report_hit_rate = float(ai_report_cache_hits) / float(total_ai_report) * 100.0
		stats_lines.append("AI报告缓存: %.1f%% (%d/%d)" % [ai_report_hit_rate, ai_report_cache_hits, total_ai_report])

	if not stats_lines.is_empty():
		print("=== 性能统计 ===")
		for line in stats_lines:
			print(line)
		print("===============")

func reset_performance_stats() -> void:
	# 重置性能统计
	perf_render_count = 0
	perf_render_total_ms = 0.0
	perf_ai_decision_count = 0
	perf_ai_decision_total_ms = 0.0

# ===== Shared state display helpers =====
func get_self_hand() -> Array:
	if mode == "offline":
		return players[0]["hand"]
	return online_game.get("hand", [])

func get_discards(seat: int) -> Array:
	if mode == "offline":
		return players[seat]["discards"]
	var result = []
	for p in online_game.get("players", []):
		if int(p.get("seat", -1)) == seat:
			result = p.get("discards", [])
	return result

func get_melds(seat: int) -> Array:
	if mode == "offline":
		return players[seat]["melds"]
	for p in online_game.get("players", []):
		if int(p.get("seat", -1)) == seat:
			return p.get("melds", [])
	return []

func get_player_info(seat: int) -> Dictionary:
	if mode == "offline":
		var player: Dictionary = players[seat] if seat >= 0 and seat < players.size() else {}
		var hand_value = player.get("hand", [])
		var hand_count = hand_value.size() if hand_value is Array else int(player.get("hand_count", 0))
		return {
			"name": str(player.get("name", "玩家")),
			"hand_count": hand_count,
			"flowers": int(player.get("flowers", 0)),
			"flower_tiles": player.get("flower_tiles", []),
			"score": int(player.get("score", 0)),
		}
	for p in online_game.get("players", []):
		if int(p.get("seat", -1)) == seat:
			return {
				"name": str(p.get("name", "玩家")),
				"hand_count": int(p.get("handCount", 0)),
				"flowers": int(p.get("flowerCount", 0)),
				"score": int(p.get("score", 0)),
			}
	return {"name": "空位", "hand_count": 0, "flowers": 0, "score": 0}

func get_current_seat() -> int:
	return current_seat if mode == "offline" else int(online_game.get("currentSeat", 0))

func get_wall_count() -> int:
	return wall.size() if mode == "offline" else int(online_game.get("wallCount", 0))

func get_last_discard() -> String:
	if mode == "offline":
		return last_discard
	return str(online_game.get("lastDiscard", ""))

func get_last_discard_seat() -> int:
	if mode == "offline":
		return last_discard_seat
	return int(online_game.get("lastDiscardSeat", -1))

func can_self_discard() -> bool:
	if mode == "offline":
		return offline_phase == "await_discard" and current_seat == 0 and not offline_turn_needs_draw
	return str(online_game.get("phase", "")) == "awaitDiscard" and int(online_game.get("currentSeat", -1)) == int(online_game.get("youSeat", -2))

func discard_preview(seat: int) -> String:
	var discards = get_discards(seat)
	return join_tile_labels(discards, tail_window_start(discards.size(), 8))

func tail_window_start(total: int, limit: int) -> int:
	return max(0, total - max(0, limit))

func join_tail_lines(items: Array, limit: int) -> String:
	var start := tail_window_start(items.size(), limit)
	var output := ""
	for i in range(start, items.size()):
		if output != "":
			output += "\n"
		output += str(items[i])
	return output

func join_tile_labels(tiles: Array, start_index: int = 0, max_count: int = -1) -> String:
	var start: int = min(max(0, start_index), tiles.size())
	var end: int = tiles.size()
	if max_count >= 0:
		end = min(end, start + max_count)
	var output := ""
	for i in range(start, end):
		if output != "":
			output += " "
		output += tile_label(str(tiles[i]))
	return output

func join_limited_strings(values: Array, separator: String, max_count: int) -> String:
	var end: int = min(values.size(), max(0, max_count))
	var output := ""
	for i in range(end):
		if output != "":
			output += separator
		output += str(values[i])
	return output

func flower_preview(seat: int) -> String:
	if mode != "offline" or seat < 0 or seat >= players.size():
		return ""
	return join_tile_labels(players[seat].get("flower_tiles", []))


func package_payer_from_state(winner: int) -> int:
	if winner < 0 or winner >= players.size() or not offline_package_liability.has(winner):
		return -1
	var payer = int(offline_package_liability.get(winner, -1))
	if payer < 0 or payer >= players.size() or payer == winner:
		return -1
	return payer


func package_preview(seat: int) -> String:
	if mode != "offline":
		return ""
	var payer = package_payer_from_state(seat)
	if payer >= 0:
		return "%s包" % players[payer]["name"]
	var targets: Array[String] = []
	for key in offline_package_liability.keys():
		if int(offline_package_liability[key]) == seat:
			var winner = int(key)
			if package_payer_from_state(winner) == seat:
				targets.append(str(players[winner]["name"]))
	if not targets.is_empty():
		return "包%s" % "、".join(targets)
	return ""

func active_package_lines() -> Array[String]:
	var lines: Array[String] = []
	for key in offline_package_liability.keys():
		var winner = int(key)
		var payer = package_payer_from_state(winner)
		if payer >= 0:
			lines.append("包三搭：%s包赔%s" % [players[payer]["name"], players[winner]["name"]])
	return lines

func tile_label(tile: String) -> String:
	if not tile_metadata_ready:
		setup_tile_order()
	if tile_label_cache.has(tile):
		return str(tile_label_cache[tile])
	if is_flower_tile(tile):
		match tile:
			"H1":
				return "春"
			"H2":
				return "夏"
			"H3":
				return "秋"
			"H4":
				return "冬"
			"H5":
				return "梅"
			"H6":
				return "兰"
			"H7":
				return "竹"
			"H8":
				return "菊"
	if tile.ends_with("W"):
		return tile.left(tile.length() - 1) + "万"
	if tile.ends_with("T"):
		return tile.left(tile.length() - 1) + "条"
	if tile.ends_with("B"):
		return tile.left(tile.length() - 1) + "筒"
	match tile:
		"E":
			return "东"
		"S":
			return "南"
		"N":
			return "西"
		"R":
			return "北"
		"Z":
			return "中"
		"F":
			return "发"
		"P":
			return "白"
	return tile

func tile_speech_label(tile: String) -> String:
	if not tile_metadata_ready:
		setup_tile_order()
	if tile_speech_label_cache.has(tile):
		return str(tile_speech_label_cache[tile])
	if is_flower_tile(tile):
		return tile_label(tile)
	if tile.ends_with("W"):
		return chinese_rank(tile.left(tile.length() - 1)) + "万"
	if tile.ends_with("T"):
		return chinese_rank(tile.left(tile.length() - 1)) + "条"
	if tile.ends_with("B"):
		return chinese_rank(tile.left(tile.length() - 1)) + "筒"
	match tile:
		"E":
			return "东风"
		"S":
			return "南风"
		"N":
			return "西风"
		"R":
			return "北风"
		"Z":
			return "红中"
		"F":
			return "发财"
		"P":
			return "白板"
	return tile_label(tile)

func chinese_rank(text: String) -> String:
	match text:
		"1":
			return "一"
		"2":
			return "二"
		"3":
			return "三"
		"4":
			return "四"
		"5":
			return "五"
		"6":
			return "六"
		"7":
			return "七"
		"8":
			return "八"
		"9":
			return "九"
	return text

func tile_corner(tile: String) -> String:
	if not tile_metadata_ready:
		setup_tile_order()
	if tile_corner_cache.has(tile):
		return str(tile_corner_cache[tile])
	if is_flower_tile(tile):
		return "花"
	if tile.ends_with("W") or tile.ends_with("T") or tile.ends_with("B"):
		return tile.left(tile.length() - 1)
	return tile_label(tile)

func tile_accent(tile: String) -> Color:
	if not tile_metadata_ready:
		setup_tile_order()
	if tile_accent_cache.has(tile):
		return tile_accent_cache[tile]
	if is_flower_tile(tile):
		return Color(0.60, 0.34, 0.12)
	if tile.ends_with("W") or tile == "Z":
		return Color(0.66, 0.16, 0.16)
	if tile.ends_with("T") or tile == "F":
		return Color(0.10, 0.42, 0.28)
	if tile.ends_with("B"):
		return Color(0.14, 0.28, 0.62)
	return Color(0.14, 0.16, 0.16)

func claim_label(claim: String) -> String:
	match claim:
		"chi":
			return "吃"
		"peng":
			return "碰"
		"gang":
			return "杠"
		"hu":
			return "胡"
	return claim

func claim_color(claim: String) -> Color:
	match claim:
		"hu":
			return Color(0.66, 0.20, 0.14)
		"gang":
			return Color(0.64, 0.42, 0.18)
		"peng":
			return Color(0.72, 0.48, 0.22)
		"chi":
			return Color(0.36, 0.46, 0.32)
	return Color(0.36, 0.30, 0.22)

# ===== Shared wall view helpers =====
func make_wall_back_strip(count: int, horizontal: bool, capacity: int = -1, wall_ratio: float = 1.0, low_wall: bool = false, recent_feedback: bool = false) -> Control:
	var strip = WallBackStrip.new()
	strip.configure(count, horizontal, WALL_BACK_TILE_SIZE, Color(0.20, 0.34, 0.27, 0.72), Color(0.82, 0.66, 0.36, 0.24), capacity, wall_ratio, low_wall, recent_feedback)
	return strip
