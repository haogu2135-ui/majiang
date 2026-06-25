extends Control

class WallBackStrip:
	extends Control

	var tile_count := 0
	var horizontal := true
	var tile_size := Vector2.ZERO
	var tile_style: StyleBoxFlat
	var shade_color := Color(0.53, 0.45, 0.28, 0.16)

	func configure(count: int, is_horizontal: bool, requested_tile_size: Vector2, fill_color: Color, border_color: Color) -> void:
		tile_count = count
		horizontal = is_horizontal
		tile_size = requested_tile_size
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		if tile_style == null:
			tile_style = StyleBoxFlat.new()
		tile_style.bg_color = fill_color
		tile_style.border_color = border_color
		tile_style.set_border_width_all(1)
		tile_style.set_corner_radius_all(7)
		queue_redraw()

	func _notification(what: int) -> void:
		if what == NOTIFICATION_RESIZED:
			queue_redraw()

	func _draw() -> void:
		if tile_count <= 0 or tile_size.x <= 0.0 or tile_size.y <= 0.0 or tile_style == null:
			return
		for tile_number in range(tile_count):
			var center = Vector2(
				(float(tile_number) + 0.5) * size.x / float(tile_count) if horizontal else size.x * 0.5,
				size.y * 0.5 if horizontal else (float(tile_number) + 0.5) * size.y / float(tile_count)
			)
			var tile_rect = Rect2(center - tile_size * 0.5, tile_size)
			draw_style_box(tile_style, tile_rect)
			var shade_rect = Rect2(
				Vector2(tile_rect.position.x + tile_rect.size.x * 0.76, tile_rect.position.y + 2.0),
				Vector2(max(1.0, tile_rect.size.x * 0.16), max(1.0, tile_rect.size.y - 4.0))
			)
			draw_rect(shade_rect, shade_color, true)

const DEFAULT_HOST := "129.146.180.88"
const DEFAULT_PORT := 23333
const APP_VERSION := "1.0.159-godot"
const UPDATE_MANIFEST_URL := "http://129.146.180.88:18081/YunzhuoMahjongGodot-update.json"
const UPDATE_URL := "http://129.146.180.88:18081/YunzhuoMahjongGodot-v1.0.159-godot.apk"
const UPDATE_FILE_PATH := "user://updates/YunzhuoMahjongGodot-v1.0.159-godot.apk"
const SETTINGS_PATH := "user://settings.cfg"
const PROGRESS_PATH := "user://offline_progress.cfg"
const STATS_PATH := "user://game_stats.cfg"
const TUTORIAL_PATH := "user://tutorial.cfg"
const AUDIO_DEFAULTS_VERSION := "1.0.159-godot"
const BGM_STREAM_PATH := "res://assets/audio/bgm_guofeng2.mp3"
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
const AI_PROFILES := [
	{
		"label": "",
		"short": "",
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
		"label": "守门清",
		"short": "守",
		"attack": 1.02,
		"defense": 1.18,
		"claim": 0.88,
		"risk": 1.22,
		"route": 1.15,
		"gang": 0.92,
		"wait": 1.05,
		"pressure": 0.96,
	},
	{
		"label": "速攻",
		"short": "速",
		"attack": 1.18,
		"defense": 0.96,
		"claim": 1.28,
		"risk": 0.92,
		"route": 0.98,
		"gang": 1.16,
		"wait": 1.08,
		"pressure": 1.22,
	},
	{
		"label": "做大牌",
		"short": "大",
		"attack": 1.12,
		"defense": 1.06,
		"claim": 1.02,
		"risk": 1.02,
		"route": 1.32,
		"gang": 1.08,
		"wait": 1.24,
		"pressure": 1.08,
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

var tile_textures: Dictionary = {}
var tile_back: Texture2D
var felt_texture: Texture2D
var wood_texture: Texture2D
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
var music_enabled = true
var sfx_enabled = true
var tts_enabled = true
var fast_mode_enabled = true
var fx_enabled = true
var current_bgm_index = 0  # v1.0.157: 当前BGM索引
var settings_panel_open = false
var reset_progress_confirming = false
var tutorial_step = 0  # 新手教程步骤：0=未开始，1-5=各步骤，-1=已完成
var tutorial_panel: Control = null
var game_stats = {
	"games_played": 0,
	"games_won": 0,
	"total_score": 0,
	"best_score": 0,
	"win_rate": 0.0,
	"total_hands": 0,
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
var offline_last_draw: Dictionary = {}
var offline_ai_active = false
var round_summary = ""
var last_score_deltas: Array[int] = []
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
var next_online_poll_msec = 0
var next_update_progress_msec = 0
var safe_area_margins := Vector4(0.0, 0.0, 0.0, 0.0)
var fx_layer: Control
var fx_turn_pulse: Control
var fx_turn_glow: Panel
var fx_turn_pulse_tween: Tween
var fx_burst_root: Control
var fx_burst_label: Label
var fx_burst_rings: Array[Panel] = []
var fx_burst_flash: ColorRect
var fx_burst_tween: Tween
var fx_ripple_root: Control
var fx_ripple_rings: Array[Panel] = []
var fx_ripple_tween: Tween

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
const DISCARD_TILE_MAX_SIZE := Vector2(38, 52)
const DISCARD_TILE_MIN_SIZE := Vector2(22, 30)
const DISCARD_TILE_ASPECT := 52.0 / 38.0
const DISCARD_GRID_SEPARATION := 2
const WALL_LAYOUTS := [
	[Vector2(0.22, 0.055), Vector2(0.78, 0.135), 16, true],
	[Vector2(0.22, 0.865), Vector2(0.78, 0.945), 16, true],
	[Vector2(0.045, 0.205), Vector2(0.130, 0.795), 12, false],
	[Vector2(0.870, 0.205), Vector2(0.955, 0.795), 12, false],
]
const DISCARD_ZONES := [
	[0, Rect2(Vector2(0.285, 0.585), Vector2(0.715, 0.825)), 10],
	[2, Rect2(Vector2(0.285, 0.175), Vector2(0.715, 0.415)), 10],
	[3, Rect2(Vector2(0.135, 0.315), Vector2(0.300, 0.705)), 4],
	[1, Rect2(Vector2(0.700, 0.315), Vector2(0.865, 0.705)), 4],
]
const MELD_LAYOUTS := [
	[0, Rect2(Vector2(0.14, 0.78), Vector2(0.39, 0.93))],
	[1, Rect2(Vector2(0.72, 0.72), Vector2(0.94, 0.86))],
	[2, Rect2(Vector2(0.61, 0.08), Vector2(0.86, 0.21))],
	[3, Rect2(Vector2(0.06, 0.72), Vector2(0.28, 0.86))],
]
const CENTER_WIND_LABELS := ["东", "南", "西", "北"]
const CENTER_PANEL_RECT := Rect2(Vector2(0.392, 0.348), Vector2(0.608, 0.660))
const CENTER_INNER_RECT := Rect2(Vector2(0.17, 0.14), Vector2(0.83, 0.78))
const CENTER_STATUS_RECT := Rect2(Vector2(0.15, 0.13), Vector2(0.85, 0.27))
const CENTER_WALL_LABEL_RECT := Rect2(Vector2(0.38, 0.30), Vector2(0.62, 0.42))
const CENTER_WALL_COUNT_RECT := Rect2(Vector2(0.35, 0.39), Vector2(0.65, 0.58))
const CENTER_LAST_LABEL_RECT := Rect2(Vector2(0.38, 0.60), Vector2(0.62, 0.69))
const CENTER_LAST_TILE_RECT := Rect2(Vector2(0.39, 0.68), Vector2(0.61, 0.97))
const CENTER_LAST_TILE_SIZE := Vector2(56, 76)
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
const CENTER_INNER_FILL := Color(0.004, 0.040, 0.040, 0.97)
const CENTER_INNER_BORDER := Color(0.30, 0.28, 0.20, 0.38)
const CENTER_WALL_COUNT_COLOR := Color(0.68, 0.76, 0.72, 0.90)
const CENTER_ACTIVE_WIND_COLOR := Color(0.72, 0.72, 0.48, 0.90)
const CENTER_IDLE_WIND_COLOR := Color(0.52, 0.50, 0.34, 0.76)
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
const TABLE_OUTER_RECT := Rect2(Vector2(0.145, 0.108), Vector2(0.855, 0.765))
const TABLE_OUTER_TEXTURE_RECT := Rect2(Vector2(0.008, 0.012), Vector2(0.992, 0.988))
const TABLE_INNER_RECT := Rect2(Vector2(0.045, 0.055), Vector2(0.955, 0.945))
const TABLE_INNER_TEXTURE_RECT := Rect2(Vector2(0.012, 0.016), Vector2(0.988, 0.984))
const SEAT_LAYOUTS := [
	[2, Rect2(Vector2(0.375, 0.100), Vector2(0.625, 0.218)), "top"],
	[3, Rect2(Vector2(0.018, 0.300), Vector2(0.188, 0.588)), "left"],
	[1, Rect2(Vector2(0.812, 0.300), Vector2(0.982, 0.588)), "right"],
	[0, Rect2(Vector2(0.018, 0.738), Vector2(0.190, 0.955)), "bottom"],
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
const HAND_TILE_MAX_WIDTH := 78.0
const HAND_TILE_MIN_TOUCH_WIDTH := 48.0
const HAND_TILE_ASPECT := 1.36
const HAND_TRAY_RECT := Rect2(Vector2(0.180, 0.765), Vector2(0.990, 0.985))
const HAND_TRAY_TOP_RAIL_RECT := Rect2(Vector2(0.012, 0.055), Vector2(0.988, 0.135))
const HAND_TRAY_DIVIDER_RECT := Rect2(Vector2(0.012, 0.145), Vector2(0.988, 0.170))
const HAND_TRAY_TEXT_RECT := Rect2(Vector2(0.030, 0.040), Vector2(0.760, 0.145))
const HAND_TRAY_STATE_BADGE_RECT := Rect2(Vector2(0.795, 0.040), Vector2(0.970, 0.145))
const HAND_TRAY_TILES_RECT := Rect2(Vector2(0.015, 0.15), Vector2(0.985, 0.96))
const HAND_LAYOUT_CANDIDATES := [
	[12.0, 5],
	[8.0, 3],
	[5.0, 2],
	[0.0, 1],
]
const ACTION_BUTTON_MAX_WIDTH := 86.0
const ACTION_BUTTON_MIN_TOUCH_WIDTH := 64.0
const ACTION_BUTTON_HEIGHT := 52.0
const ACTION_BAR_DOCK_RECT := Rect2(Vector2(0.375, 0.655), Vector2(0.975, 0.748))
const ACTION_BAR_RECT := Rect2(Vector2(0.392, 0.667), Vector2(0.965, 0.735))
const TOP_HUD_BUTTON_SIZE := Vector2(68, 44)
const TOP_HUD_MODE_BADGE_RECT := Rect2(Vector2(0.018, 0.14), Vector2(0.100, 0.44))
const SAFE_CONTENT_MIN_MARGIN := Vector4(12.0, 8.0, 12.0, 10.0)
const SAFE_CONTENT_MAX_SIDE_FRACTION := 0.16
const SAFE_CONTENT_MAX_TOP_FRACTION := 0.16
const SAFE_CONTENT_MAX_BOTTOM_FRACTION := 0.18
const TOP_HUD_RECT := Rect2(Vector2(0.018, 0.018), Vector2(0.982, 0.094))
const TOP_HUD_TITLE_RECT := Rect2(Vector2(0.135, 0.08), Vector2(0.205, 0.92))
const TOP_HUD_STATUS_RECT := Rect2(Vector2(0.212, 0.10), Vector2(0.430, 0.90))
const TOP_HUD_SCORE_STRIP_RECT := Rect2(Vector2(0.440, 0.13), Vector2(0.708, 0.87))
const TOP_HUD_WALL_RECT := Rect2(Vector2(0.716, 0.12), Vector2(0.800, 0.88))
const TOP_HUD_SETTINGS_BUTTON_RECT := Rect2(Vector2(0.806, 0.10), Vector2(0.866, 0.90))
const TOP_HUD_BACK_BUTTON_RECT := Rect2(Vector2(0.872, 0.10), Vector2(0.932, 0.90))
const TOP_HUD_UPDATE_BUTTON_RECT := Rect2(Vector2(0.938, 0.10), Vector2(0.998, 0.90))
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
	Rect2(Vector2(0.39, 0.38), Vector2(0.52, 0.58)),
	Rect2(Vector2(0.535, 0.38), Vector2(0.655, 0.58)),
	Rect2(Vector2(0.670, 0.38), Vector2(0.96, 0.58)),
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
const UI_GOLD := Color(0.034, 0.036, 0.034, 0.18)
const UI_GOLD_SOFT := Color(0.050, 0.052, 0.049, 0.08)
const UI_DARK := Color(0.007, 0.009, 0.010, 0.992)
const UI_DARK_SOFT := Color(0.014, 0.017, 0.019, 0.930)
const UI_FELT := Color(0.010, 0.020, 0.020, 0.988)
const UI_FELT_LINE := Color(0.034, 0.046, 0.044, 0.16)
const UI_TEXT_MAIN := Color(0.94, 0.92, 0.84, 1.0)
const UI_TEXT_SUB := Color(0.86, 0.88, 0.81, 0.98)
const UI_TEXT_MUTED := Color(0.77, 0.78, 0.71, 0.94)
const UI_PANEL_FILL := Color(0.012, 0.015, 0.018, 0.996)
const UI_PANEL_BORDER := Color(0.072, 0.074, 0.070, 0.12)
const UI_PANEL_SHADOW := Color(0.0, 0.0, 0.0, 0.075)
const TOP_HUD_FILL := Color(0.013, 0.018, 0.021, 0.982)
const TOP_HUD_BORDER := Color(0.14, 0.15, 0.13, 0.24)
const SCORE_STRIP_FILL := Color(0.012, 0.021, 0.023, 0.92)
const SCORE_STRIP_BORDER := Color(0.14, 0.16, 0.16, 0.18)
const SCORE_STRIP_NAME_FILL := Color(0.92, 0.88, 0.76, 0.92)
const SETTINGS_PANEL_FILL := Color(0.009, 0.015, 0.018, 0.986)
const SETTINGS_PANEL_BORDER := Color(0.12, 0.12, 0.08, 0.24)
const SETTINGS_PANEL_RECT := Rect2(Vector2(0.290, 0.080), Vector2(0.710, 0.820))
const SETTINGS_TITLE_RECT := Rect2(Vector2(0.06, 0.045), Vector2(0.42, 0.165))
const SETTINGS_CLOSE_RECT := Rect2(Vector2(0.760, 0.055), Vector2(0.940, 0.165))
const SETTINGS_AUDIO_SECTION_RECT := Rect2(Vector2(0.070, 0.165), Vector2(0.930, 0.470))
const SETTINGS_PLAY_SECTION_RECT := Rect2(Vector2(0.070, 0.505), Vector2(0.930, 0.720))
const SETTINGS_MAINT_SECTION_RECT := Rect2(Vector2(0.070, 0.755), Vector2(0.930, 0.925))
const SETTINGS_SECTION_TITLE_RECT := Rect2(Vector2(0.035, 0.045), Vector2(0.300, 0.300))
const SETTINGS_SECTION_GRID_RECT := Rect2(Vector2(0.035, 0.295), Vector2(0.965, 0.910))
const SETTINGS_ROW_STATUS_RECT := Rect2(Vector2(0.045, 0.145), Vector2(0.510, 0.855))
const SETTINGS_ROW_BUTTON_RECT := Rect2(Vector2(0.565, 0.145), Vector2(0.955, 0.855))
const UI_BACKGROUND_TINT := Color(0.004, 0.006, 0.008, 0.996)
# 动画 / 特效层参数。特效节点全部挂在持久化的 fx_layer 上，整桌每次 render_game
# 调用 clear_screen 时 fx_layer 不被释放，因此补间动画可以跨整桌重绘连续播放。
const FX_WIN_BURST_DURATION_MSEC := 1400
const FX_DISCARD_RIPPLE_DURATION_MSEC := 460
const FX_TURN_PULSE_PERIOD_MSEC := 1700
const FX_WIN_RING_COUNT := 3
const FX_BURST_LABEL_FONT_SIZE := 58
const FX_LAYER_Z_INDEX := 16

func _ready() -> void:
	randomize()
	DisplayServer.screen_set_orientation(DisplayServer.SCREEN_LANDSCAPE)
	setup_tile_order()
	show_loading_screen()
	load_assets()
	verify_audio_assets()
	load_settings()
	load_game_stats()
	load_tutorial_state()
	setup_audio()
	ensure_fx_layer()
	setup_update_downloader()
	# v1.0.149: 移除立即播放，恢复用户交互触发
	call_deferred("_finish_startup")

func _finish_startup() -> void:
	if OS.get_cmdline_user_args().has("--offline-preview"):
		start_offline()
	else:
		show_menu()

func show_loading_screen() -> void:
	clear_screen()
	var loading = make_label(root_layer, "正在加载...", 32, Color(1.0, 0.90, 0.48), true)
	apply_rect(loading, rect_full(0.3, 0.4, 0.7, 0.6))
	loading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _process(_delta: float) -> void:
	var now = Time.get_ticks_msec()
	keep_background_music_alive(now)
	# 音频系统健康检查 - 每5秒检查一次
	audio_health_check_counter += 1
	if audio_health_check_counter >= 300:  # 60fps * 5秒 = 300帧
		audio_health_check_counter = 0
		check_audio_health(now)
	if update_state == "downloading":
		update_download_progress(now)
	if voice_enabled:
		poll_voice_capture()
	if mode == "online_lobby" or mode == "online_game":
		poll_online(now)

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_RESUMED or what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
		recover_audio_after_screen_change()
		update_safe_area_layout()
	elif what == NOTIFICATION_WM_SIZE_CHANGED or what == NOTIFICATION_WM_DPI_CHANGE:
		update_safe_area_layout()
		call_deferred("refresh_current_screen")

func _input(event: InputEvent) -> void:
	var pressed = false
	if event is InputEventScreenTouch:
		pressed = event.pressed
	elif event is InputEventMouseButton:
		pressed = event.pressed
	if pressed:
		wake_audio_from_interaction()

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
	felt_texture = load("res://assets/table/table_felt_green.jpg")
	wood_texture = load("res://assets/table/table_dark_wood.jpg")
	tile_back = load("res://assets/tiles/tile_back.png")

	# 音频资源立即加载
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
	call_deferred("load_voice_assets")

func _load_tile_textures() -> void:
	for code in TILE_CODES:
		tile_textures[code] = load(tile_path(code))
	for code in FLOWER_CODES:
		tile_textures[code] = load(tile_path(code))

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

func setup_audio() -> void:
	print("AudioSetup: Starting audio system initialization")
	ensure_master_audio_bus()
	ensure_audio_layer()

	# v1.0.153: Android音频焦点请求
	if OS.get_name() == "Android":
		request_android_audio_focus()

	if bgm_player == null or not is_instance_valid(bgm_player):
		print("AudioSetup: Creating background music player")
		bgm_player = AudioStreamPlayer.new()
		bgm_player.name = "BackgroundMusic"
		bgm_player.volume_db = BGM_VOLUME_DB
		bgm_player.bus = "Master"
		bgm_player.process_mode = Node.PROCESS_MODE_ALWAYS
		attach_audio_node(bgm_player)
		if not bgm_player.finished.is_connected(_on_background_music_finished):
			bgm_player.finished.connect(_on_background_music_finished)
		print("AudioSetup: BGM player created successfully")
	else:
		print("AudioSetup: BGM player already exists")
	if sfx_player == null or not is_instance_valid(sfx_player):
		print("AudioSetup: Creating SFX player")
		sfx_player = AudioStreamPlayer.new()
		sfx_player.name = "TileSfx"
		sfx_player.volume_db = -1.0
		sfx_player.bus = "Master"
		sfx_player.process_mode = Node.PROCESS_MODE_ALWAYS
		attach_audio_node(sfx_player)
	if action_sfx_player == null or not is_instance_valid(action_sfx_player):
		print("AudioSetup: Creating action SFX player")
		action_sfx_player = AudioStreamPlayer.new()
		action_sfx_player.name = "ActionSfx"
		action_sfx_player.volume_db = -1.0
		action_sfx_player.bus = "Master"
		action_sfx_player.process_mode = Node.PROCESS_MODE_ALWAYS
		attach_audio_node(action_sfx_player)
	bgm_player.stream = audio_streams.get("bgm", null)
	if bgm_player.stream != null:
		print("AudioSetup: BGM stream loaded successfully")
	else:
		print("AudioSetup: WARNING - BGM stream is null")
	configure_background_music_stream()
	select_tts_voice()
	apply_audio_settings()
	print("AudioSetup: Audio system initialization complete")

func _exit_tree() -> void:
	shutdown_android_tts()

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

func load_settings() -> void:
	var config = ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return
	music_enabled = bool(config.get_value("audio", "music_enabled", music_enabled))
	sfx_enabled = bool(config.get_value("audio", "sfx_enabled", sfx_enabled))
	tts_enabled = bool(config.get_value("audio", "tts_enabled", tts_enabled))
	fast_mode_enabled = bool(config.get_value("gameplay", "fast_mode_enabled", fast_mode_enabled))
	fx_enabled = bool(config.get_value("gameplay", "fx_enabled", fx_enabled))
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

func apply_audio_settings() -> void:
	if bgm_player == null or not is_instance_valid(bgm_player):
		return
	ensure_master_audio_bus()
	configure_background_music_stream()
	bgm_player.volume_db = BGM_VOLUME_DB
	if music_enabled and audio_runtime_enabled() and bgm_player.stream != null:
		if not bgm_player.playing:
			bgm_player.play()
	elif bgm_player.playing:
		bgm_player.stop()

func audio_runtime_enabled() -> bool:
	return DisplayServer.get_name().to_lower() != "headless"

func wake_audio_from_interaction() -> void:
	if not audio_touch_unlocked:
		# v1.0.150: 首次交互也改为异步，不阻塞UI
		print("AudioWake: 首次用户交互，异步初始化音频系统")
		audio_touch_unlocked = true
		# 立即异步执行，不阻塞按钮响应
		call_deferred("_wake_audio_first_time")
	else:
		# 后续交互：异步
		call_deferred("_wake_audio_deferred")

func _wake_audio_first_time() -> void:
	print("AudioWake: 开始异步初始化")
	ensure_master_audio_bus()
	print("AudioWake: 主音频总线已确保")
	warm_speech_backend()
	print("AudioWake: TTS初始化完成")
	if music_enabled:
		print("AudioWake: 准备启动背景音乐")
		start_background_music()
	print("AudioWake: 首次初始化完成")

func _wake_audio_deferred() -> void:
	ensure_master_audio_bus()
	warm_speech_backend()
	if music_enabled:
		start_background_music()

func recover_audio_after_screen_change() -> void:
	if not audio_runtime_enabled():
		return
	ensure_master_audio_bus()
	warm_speech_backend()
	if music_enabled:
		call_deferred("start_background_music")

func switch_bgm_track() -> void:
	# v1.0.157: 切换到下一首BGM
	current_bgm_index = (current_bgm_index + 1) % BGM_TRACKS.size()
	var track = BGM_TRACKS[current_bgm_index]
	print("BGM: 切换到", track["name"], " - ", track["path"])

	# 停止当前BGM
	if bgm_player != null and is_instance_valid(bgm_player) and bgm_player.playing:
		bgm_player.stop()

	# 加载新BGM
	var new_stream = load(track["path"])
	if new_stream == null:
		print("BGM: 警告 - 无法加载", track["path"])
		set_status("BGM文件不存在: " + track["name"])
		return

	audio_streams["bgm"] = new_stream

	# 更新播放器
	if bgm_player != null and is_instance_valid(bgm_player):
		bgm_player.stream = new_stream
		configure_background_music_stream()
		if music_enabled:
			bgm_player.play()
			print("BGM: 开始播放", track["name"])
			set_status("正在播放: " + track["name"])

func start_background_music() -> void:
	if not music_enabled or not audio_runtime_enabled():
		print("BGM: 音乐已关闭或音频不可用")
		return

	# 确保播放器存在
	if bgm_player == null or not is_instance_valid(bgm_player):
		print("BGM: 播放器不存在，调用setup_audio")
		setup_audio()
		if bgm_player == null or not is_instance_valid(bgm_player):
			print("BGM: ERROR - setup_audio后播放器仍然为null")
			return

	# 确保音频流已加载
	if bgm_player.stream == null:
		print("BGM: 音频流为null，尝试加载")
		bgm_player.stream = audio_streams.get("bgm", null)
		if bgm_player.stream == null:
			print("BGM: ERROR - 音频流加载失败")
			return
		print("BGM: 音频流加载成功")

	# 配置循环
	configure_background_music_stream()

	# 确保主音频总线开启
	ensure_master_audio_bus()

	# 如果已经在播放，不要重复播放
	if bgm_player.playing:
		print("BGM: 已经在播放中")
		return

	# v1.0.149: 使用AudioServer直接播放，绕过可能的播放阻止
	print("BGM: 尝试方法1 - 标准play()")
	bgm_player.stream_paused = false
	bgm_player.volume_db = BGM_VOLUME_DB
	bgm_player.play()

	# 等待一帧验证
	await get_tree().process_frame

	if bgm_player.playing:
		print("BGM: ✓ 方法1成功")
		next_bgm_retry_msec = Time.get_ticks_msec() + 850
		return

	# 方法1失败，尝试方法2：从0位置开始
	print("BGM: 尝试方法2 - play(0.0)")
	bgm_player.play(0.0)
	await get_tree().process_frame

	if bgm_player.playing:
		print("BGM: ✓ 方法2成功")
		next_bgm_retry_msec = Time.get_ticks_msec() + 850
		return

	# 方法2失败，尝试方法3：重新加载stream
	print("BGM: 尝试方法3 - 重新加载stream")
	var stream_backup = bgm_player.stream
	bgm_player.stream = null
	await get_tree().process_frame
	bgm_player.stream = stream_backup
	configure_background_music_stream()
	bgm_player.play()
	await get_tree().process_frame

	if bgm_player.playing:
		print("BGM: ✓ 方法3成功")
		next_bgm_retry_msec = Time.get_ticks_msec() + 850
		return

	# 方法3失败，尝试方法4：完全重建播放器
	print("BGM: 尝试方法4 - 重建播放器")
	if bgm_player.get_parent() != null:
		bgm_player.get_parent().remove_child(bgm_player)
	bgm_player.queue_free()
	bgm_player = null
	setup_audio()
	if bgm_player != null and bgm_player.stream != null:
		bgm_player.play()
		await get_tree().process_frame
		if bgm_player.playing:
			print("BGM: ✓ 方法4成功")
		else:
			print("BGM: ✗ 所有方法都失败")

	next_bgm_retry_msec = Time.get_ticks_msec() + 850

func configure_background_music_stream() -> void:
	if bgm_player == null or not is_instance_valid(bgm_player) or bgm_player.stream == null:
		return
	var bgm_mp3 = bgm_player.stream as AudioStreamMP3
	if bgm_mp3 != null:
		bgm_mp3.loop = true
		return
	var bgm_wav = bgm_player.stream as AudioStreamWAV
	if bgm_wav != null:
		bgm_wav.loop_mode = AudioStreamWAV.LOOP_FORWARD

func keep_background_music_alive(now_msec: int = -1) -> void:
	if not music_enabled or not audio_runtime_enabled():
		return
	if bgm_player != null and is_instance_valid(bgm_player) and bgm_player.playing:
		return
	var now = now_msec if now_msec >= 0 else Time.get_ticks_msec()
	if now < next_bgm_retry_msec:
		return
	start_background_music()

func check_audio_health(now_msec: int) -> void:
	# 音频系统健康检查，用于检测和恢复音频问题
	if not audio_touch_unlocked:
		return  # 用户还未激活音频，跳过检查

	# 检查背景音乐状态
	if music_enabled and audio_runtime_enabled():
		if bgm_player == null or not is_instance_valid(bgm_player):
			print("AudioHealth: BGM player lost, recreating...")
			setup_audio()
			return

		if bgm_player.stream == null:
			print("AudioHealth: BGM stream lost, reloading...")
			bgm_player.stream = audio_streams.get("bgm", null)
			configure_background_music_stream()

		# 如果音乐应该播放但没有播放，且已经很久没检查了
		if not bgm_player.playing and (now_msec - last_bgm_health_check) > 10000:
			last_bgm_health_check = now_msec
			print("AudioHealth: BGM should be playing but isn't, attempting restart...")
			# 强制重新初始化
			ensure_master_audio_bus()
			start_background_music()

	# 检查音效播放器
	if sfx_enabled and (sfx_player == null or not is_instance_valid(sfx_player)):
		print("AudioHealth: SFX player lost, recreating...")
		setup_audio()

func _on_background_music_finished() -> void:
	next_bgm_retry_msec = 0
	start_background_music()

func play_sfx(name: String, volume_db: float = -3.0) -> void:
	if not sfx_enabled or not audio_runtime_enabled():
		return
	ensure_master_audio_bus()
	if music_enabled and bgm_player != null and is_instance_valid(bgm_player) and not bgm_player.playing:
		start_background_music()
	var stream = audio_streams.get(name, null)
	if stream == null:
		return
	var player = action_sfx_player if is_action_sfx(name) else sfx_player
	if player == null or not is_instance_valid(player):
		player = make_one_shot_sfx_player(stream, boosted_sfx_volume_db(volume_db))
		player.play()
	else:
		play_stream_on_audio_player(player, stream, boosted_sfx_volume_db(volume_db))

func is_action_sfx(name: String) -> bool:
	return ["peng", "gang", "win"].has(name)

func play_stream_on_audio_player(player: AudioStreamPlayer, stream: AudioStream, volume_db: float) -> void:
	if player == null or stream == null:
		return
	if player.playing:
		player.stop()
	player.stream = stream
	player.volume_db = volume_db
	player.bus = "Master"
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	attach_audio_node(player)
	player.play()

func boosted_sfx_volume_db(volume_db: float) -> float:
	return clamp(volume_db + SFX_VOLUME_BOOST_DB, -10.0, 1.5)

func make_one_shot_sfx_player(stream: AudioStream, volume_db: float) -> AudioStreamPlayer:
	var player = AudioStreamPlayer.new()
	player.name = "OneShotSfx"
	player.stream = stream
	player.volume_db = volume_db
	player.bus = "Master"
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	attach_audio_node(player)
	player.finished.connect(func() -> void:
		if is_instance_valid(player):
			player.queue_free()
	)
	if get_tree() != null:
		get_tree().create_timer(3.0).timeout.connect(func() -> void:
			if is_instance_valid(player):
				player.queue_free()
		)
	return player

func select_tts_voice() -> void:
	tts_voice_id = ""
	if ClassDB.class_has_method("DisplayServer", "tts_get_voices_for_language"):
		for language in ["zh", "zh_CN", "zh-CN", "cmn"]:
			var zh_voices = DisplayServer.tts_get_voices_for_language(language)
			if not zh_voices.is_empty():
				tts_voice_id = tts_voice_identifier(zh_voices[0])
				if tts_voice_id != "":
					return
	if not ClassDB.class_has_method("DisplayServer", "tts_get_voices"):
		return
	for voice in DisplayServer.tts_get_voices():
		var voice_id = tts_voice_identifier(voice)
		if typeof(voice) == TYPE_DICTIONARY:
			var language = str(voice.get("language", "")).to_lower()
			if voice_id != "" and (tts_voice_id == "" or language.begins_with("zh")):
				tts_voice_id = voice_id
				if language.begins_with("zh"):
					return
		elif tts_voice_id == "":
			tts_voice_id = voice_id

func tts_voice_identifier(voice) -> String:
	if typeof(voice) == TYPE_DICTIONARY:
		return str(voice.get("id", voice.get("name", "")))
	return str(voice)

func display_tts_runtime_available() -> bool:
	return ClassDB.class_has_method("DisplayServer", "tts_speak")

func warm_speech_backend() -> void:
	if not tts_enabled or not audio_runtime_enabled():
		return
	if display_tts_runtime_available():
		if tts_voice_id == "":
			select_tts_voice()
		return
	setup_android_tts()

func can_speak_text() -> bool:
	if not tts_enabled or not audio_runtime_enabled():
		return false
	if display_tts_runtime_available():
		return true
	if android_tts_runtime_available():
		setup_android_tts()
		return true
	return false

func speech_backend_ready() -> bool:
	if not tts_enabled or not audio_runtime_enabled():
		return false
	if display_tts_runtime_available():
		return true
	if android_tts_runtime_available():
		setup_android_tts()
		if android_tts != null:
			configure_android_tts()
			return Time.get_ticks_msec() - android_tts_started_msec >= ANDROID_TTS_WARMUP_MSEC
		if android_tts_requested and android_tts_requested_msec > 0:
			if Time.get_ticks_msec() - android_tts_requested_msec < ANDROID_TTS_FALLBACK_MSEC:
				return false
		return ClassDB.class_has_method("DisplayServer", "tts_speak")
	return ClassDB.class_has_method("DisplayServer", "tts_speak")

func speak_text(text: String, interrupt: bool = false) -> bool:
	if text.strip_edges() == "" or not can_speak_text():
		return false
	if speak_text_display(text, interrupt):
		return true
	if speak_text_android(text, interrupt):
		return true
	return false

func speak_text_display(text: String, interrupt: bool = false) -> bool:
	if not display_tts_runtime_available():
		return false
	if tts_voice_id == "":
		select_tts_voice()
	ensure_master_audio_bus()
	if interrupt and ClassDB.class_has_method("DisplayServer", "tts_stop"):
		DisplayServer.tts_stop()
	var utterance_id = next_tts_utterance_id()
	DisplayServer.tts_speak(text, tts_voice_id, 100, 1.0, 1.03, utterance_id, interrupt)
	return true

func request_android_audio_focus() -> void:
	# v1.0.154: 请求Android音频焦点，针对小米MIUI优化
	if not OS.get_name() == "Android":
		return

	print("AudioFocus: 请求Android音频焦点（小米MIUI优化）")

	# 强制设置AudioServer为最大音量
	var master_idx = AudioServer.get_bus_index("Master")
	if master_idx >= 0:
		AudioServer.set_bus_volume_db(master_idx, 0.0)
		AudioServer.set_bus_mute(master_idx, false)
		print("AudioFocus: Master总线音量=0dB，未静音")

	# 小米专属：强制启用所有音频效果
	var bus_count = AudioServer.get_bus_count()
	for i in range(bus_count):
		AudioServer.set_bus_mute(i, false)
		print("AudioFocus: 总线", i, AudioServer.get_bus_name(i), "已解除静音")

func play_test_tone_440hz() -> void:
	# v1.0.155: 播放440Hz测试音，验证AudioStreamGenerator是否能工作
	print("TestTone: 创建440Hz测试音播放器")

	var generator = AudioStreamGenerator.new()
	generator.mix_rate = 44100.0
	generator.buffer_length = 0.1

	var tone_player = AudioStreamPlayer.new()
	tone_player.name = "TestTonePlayer"
	tone_player.stream = generator
	tone_player.volume_db = 0.0
	tone_player.bus = "Master"
	tone_player.process_mode = Node.PROCESS_MODE_ALWAYS

	ensure_audio_layer()
	get_node("/root/Main/AudioLayer").add_child(tone_player)

	tone_player.play()
	print("TestTone: 开始播放440Hz音调")

	var playback = tone_player.get_stream_playback() as AudioStreamGeneratorPlayback
	if playback == null:
		print("TestTone: ERROR - 无法获取AudioStreamGeneratorPlayback")
		tone_player.queue_free()
		return

	# 生成1秒的440Hz正弦波
	var frequency = 440.0
	var sample_rate = 44100.0
	var samples_to_generate = int(sample_rate * 1.0)  # 1秒
	var phase = 0.0

	for i in range(samples_to_generate):
		var sample = sin(phase * TAU)
		playback.push_frame(Vector2(sample, sample))
		phase = fmod(phase + frequency / sample_rate, 1.0)

		# 每1000个样本让出一帧，避免阻塞
		if i % 1000 == 0:
			await get_tree().process_frame

	print("TestTone: 440Hz音调生成完成")

	# 等待播放完成后清理
	await get_tree().create_timer(1.2).timeout
	tone_player.stop()
	tone_player.queue_free()
	print("TestTone: 测试音播放器已清理")

func android_tts_runtime_available() -> bool:
	return OS.get_name() == "Android" and Engine.has_singleton("AndroidRuntime") and Engine.has_singleton("JavaClassWrapper")

func setup_android_tts() -> void:
	if not android_tts_runtime_available() or android_tts != null:
		return
	var now = Time.get_ticks_msec()
	if android_tts_requested:
		if android_tts_requested_msec > 0 and now - android_tts_requested_msec < ANDROID_TTS_FALLBACK_MSEC:
			return
		android_tts_requested = false
		android_tts_requested_msec = 0
	if android_tts_retry_after_msec > 0 and now < android_tts_retry_after_msec:
		return
	android_tts_requested = true
	android_tts_requested_msec = now
	var android_runtime = Engine.get_singleton("AndroidRuntime")
	var activity = android_runtime.getActivity()
	if activity == null:
		android_tts_requested = false
		android_tts_requested_msec = 0
		android_tts_retry_after_msec = now + ANDROID_TTS_RETRY_MSEC
		return
	var create_tts = func() -> void:
		var TextToSpeech = JavaClassWrapper.wrap("android.speech.tts.TextToSpeech")
		var created_tts = TextToSpeech.TextToSpeech(activity, null)
		var exception = JavaClassWrapper.get_exception()
		if exception != null or created_tts == null:
			android_tts = null
			android_tts_requested = false
			android_tts_requested_msec = 0
			android_tts_retry_after_msec = Time.get_ticks_msec() + ANDROID_TTS_RETRY_MSEC
			return
		android_tts = created_tts
		android_tts_started_msec = Time.get_ticks_msec()
		android_tts_retry_after_msec = 0
		android_tts_language_configured = false
	if activity.has_java_method("runOnUiThread"):
		activity.runOnUiThread(android_runtime.createRunnableFromGodotCallable(create_tts))
	else:
		create_tts.call()

func configure_android_tts() -> void:
	if android_tts == null or android_tts_language_configured:
		return
	if Time.get_ticks_msec() - android_tts_started_msec < ANDROID_TTS_WARMUP_MSEC:
		return
	var Locale = JavaClassWrapper.wrap("java.util.Locale")
	var result = android_tts.setLanguage(Locale.CHINA)
	if int(result) == -1 or int(result) == -2:
		android_tts.setLanguage(Locale.CHINESE)
	var exception = JavaClassWrapper.get_exception()
	if exception != null:
		android_tts_language_configured = false
		android_tts_retry_after_msec = Time.get_ticks_msec() + ANDROID_TTS_RETRY_MSEC
		return
	android_tts.setSpeechRate(1.08)
	android_tts.setPitch(1.02)
	android_tts_language_configured = true

func speak_text_android(text: String, interrupt: bool = false) -> bool:
	if not android_tts_runtime_available():
		return false
	setup_android_tts()
	if android_tts == null:
		return false
	configure_android_tts()
	if Time.get_ticks_msec() - android_tts_started_msec < ANDROID_TTS_WARMUP_MSEC:
		return false
	var queue_mode = 0 if interrupt else 1
	var utterance_id = "mahjong-%d" % next_tts_utterance_id()
	var result = android_tts.speak(text, queue_mode, make_android_tts_params(), utterance_id)
	var exception = JavaClassWrapper.get_exception()
	if exception != null:
		android_tts = null
		android_tts_requested = false
		android_tts_requested_msec = 0
		android_tts_language_configured = false
		android_tts_retry_after_msec = Time.get_ticks_msec() + ANDROID_TTS_RETRY_MSEC
		return false
	return int(result) == 0

func make_android_tts_params():
	var Bundle = JavaClassWrapper.wrap("android.os.Bundle")
	var wrap_exception = JavaClassWrapper.get_exception()
	if wrap_exception != null or Bundle == null:
		return null
	var params = Bundle.Bundle()
	var exception = JavaClassWrapper.get_exception()
	if exception != null:
		return null
	return params

func next_tts_utterance_id() -> int:
	var utterance_id = tts_utterance_id
	tts_utterance_id += 1
	if tts_utterance_id > 1000000000:
		tts_utterance_id = 1
	return utterance_id

func shutdown_android_tts() -> void:
	if android_tts == null:
		return
	if android_tts.has_java_method("stop"):
		android_tts.stop()
	if android_tts.has_java_method("shutdown"):
		android_tts.shutdown()
	android_tts = null
	android_tts_requested = false
	android_tts_requested_msec = 0
	android_tts_retry_after_msec = 0
	android_tts_language_configured = false

func stop_current_speech() -> void:
	if android_tts != null and android_tts.has_java_method("stop"):
		android_tts.stop()
	if ClassDB.class_has_method("DisplayServer", "tts_stop") and audio_runtime_enabled():
		DisplayServer.tts_stop()

func speak_text_delayed(text: String, delay_seconds: float = 0.0, interrupt: bool = false) -> void:
	if text.strip_edges() == "":
		return
	if not tts_enabled:
		return
	if interrupt:
		speech_queue.clear()
		speech_queue_generation += 1
		stop_current_speech()
	speech_queue.append({
		"text": text,
		"delay": max(0.0, delay_seconds),
		"interrupt": interrupt,
		"generation": speech_queue_generation,
		"attempts": 0,
		"queued_msec": Time.get_ticks_msec(),
	})
	if not speech_queue_active:
		call_deferred("drain_speech_queue")

func speak_voice_clips_delayed(clips: Array, delay_seconds: float = 0.0, interrupt: bool = false) -> bool:
	if clips.is_empty() or not tts_enabled or not audio_runtime_enabled():
		return false
	var normalized: Array[String] = []
	for clip in clips:
		var key = str(clip)
		if key == "" or voice_streams.get(key, null) == null:
			return false
		normalized.append(key)
	if interrupt:
		speech_queue.clear()
		speech_queue_generation += 1
		stop_current_speech()
	speech_queue.append({
		"clips": normalized,
		"delay": max(0.0, delay_seconds),
		"interrupt": interrupt,
		"generation": speech_queue_generation,
		"queued_msec": Time.get_ticks_msec(),
	})
	if not speech_queue_active:
		call_deferred("drain_speech_queue")
	return true

func drain_speech_queue() -> void:
	if speech_queue_active:
		return
	speech_queue_active = true
	while not speech_queue.is_empty():
		var next_item: Dictionary = speech_queue[0]
		if next_item.has("clips"):
			var clip_item: Dictionary = speech_queue.pop_front()
			var clip_generation = int(clip_item.get("generation", speech_queue_generation))
			var clip_delay = float(clip_item.get("delay", 0.0))
			if clip_delay > 0.0:
				await get_tree().create_timer(clip_delay).timeout
			if clip_generation != speech_queue_generation:
				continue
			var clips: Array = clip_item.get("clips", [])
			for clip in clips:
				if clip_generation != speech_queue_generation:
					break
				play_voice_clip(str(clip))
				await get_tree().create_timer(SPEECH_CLIP_GAP_SECONDS).timeout
			if clip_generation == speech_queue_generation and SPEECH_CLIP_TAIL_SECONDS > 0.0:
				await get_tree().create_timer(SPEECH_CLIP_TAIL_SECONDS).timeout
			continue
		if not speech_backend_ready():
			var queued_msec = int(speech_queue[0].get("queued_msec", Time.get_ticks_msec()))
			if Time.get_ticks_msec() - queued_msec < SPEECH_MAX_READY_WAIT_MSEC and can_speak_text():
				await get_tree().create_timer(SPEECH_READY_RETRY_SECONDS).timeout
				continue
			speech_queue.pop_front()
			continue
		var item: Dictionary = speech_queue.pop_front()
		var generation = int(item.get("generation", speech_queue_generation))
		var delay = float(item.get("delay", 0.0))
		if delay > 0.0:
			await get_tree().create_timer(delay).timeout
		if generation != speech_queue_generation:
			continue
		var spoken = speak_text(str(item.get("text", "")), bool(item.get("interrupt", false)))
		if spoken:
			await get_tree().create_timer(0.34).timeout
		else:
			var attempts = int(item.get("attempts", 0))
			if attempts < 2 and can_speak_text():
				item["attempts"] = attempts + 1
				speech_queue.push_front(item)
				await get_tree().create_timer(SPEECH_READY_RETRY_SECONDS).timeout
	speech_queue_active = false

func play_voice_clip(key: String) -> bool:
	if key == "" or not tts_enabled or not audio_runtime_enabled():
		return false
	var stream = voice_streams.get(key, null)
	if stream == null:
		return false
	ensure_master_audio_bus()
	if music_enabled and bgm_player != null and is_instance_valid(bgm_player) and not bgm_player.playing:
		start_background_music()
	var player = make_one_shot_sfx_player(stream, VOICE_VOLUME_DB)
	player.play()
	return true

func speak_tile_call(tile: String) -> void:
	if speak_voice_clips_delayed([voice_clip_key_for_tile(tile)], SPEECH_TILE_DELAY_SECONDS, false):
		return
	speak_text_delayed(tile_speech_label(tile), SPEECH_TILE_DELAY_SECONDS, false)

func speak_action_call(action: String, tile: String) -> void:
	var clips: Array[String] = []
	var action_key = voice_clip_key_for_action(action)
	if action_key != "":
		clips.append(action_key)
	var tile_key = voice_clip_key_for_tile(tile)
	if tile_key != "":
		clips.append(tile_key)
	if not clips.is_empty() and speak_voice_clips_delayed(clips, SPEECH_ACTION_DELAY_SECONDS, true):
		return
	var suffix = tile_speech_label(tile)
	speak_text_delayed(action + suffix if suffix != "" else action, SPEECH_ACTION_DELAY_SECONDS, true)

func ai_draw_delay() -> float:
	return AI_DRAW_DELAY_SECONDS if fast_mode_enabled else 0.18

func ai_discard_delay() -> float:
	return AI_DISCARD_DELAY_SECONDS if fast_mode_enabled else 0.35

func ai_action_gap_delay() -> float:
	return AI_ACTION_GAP_SECONDS if fast_mode_enabled else 0.35

func human_discard_response_gap_delay() -> float:
	return HUMAN_DISCARD_RESPONSE_GAP_SECONDS if fast_mode_enabled else 0.05

func ai_return_to_human_gap_delay() -> float:
	return AI_RETURN_TO_HUMAN_GAP_SECONDS if fast_mode_enabled else 0.12

func human_draw_delay() -> float:
	return HUMAN_DRAW_DELAY_SECONDS if fast_mode_enabled else 0.08

func pace_after_human_discard_response() -> void:
	await get_tree().process_frame
	var delay = human_discard_response_gap_delay()
	if delay > 0.0:
		await get_tree().create_timer(delay).timeout

func pace_after_visible_ai_action(returning_to_human: bool = false) -> void:
	await get_tree().process_frame
	var delay = ai_return_to_human_gap_delay() if returning_to_human else ai_action_gap_delay()
	if delay > 0.0:
		await get_tree().create_timer(delay).timeout

func toggle_music_setting() -> void:
	music_enabled = not music_enabled
	apply_audio_settings()
	save_settings()
	refresh_current_screen()

func toggle_sfx_setting() -> void:
	sfx_enabled = not sfx_enabled
	save_settings()
	refresh_current_screen()

func toggle_tts_setting() -> void:
	tts_enabled = not tts_enabled
	save_settings()
	refresh_current_screen()

func toggle_fast_mode_setting() -> void:
	fast_mode_enabled = not fast_mode_enabled
	save_settings()
	refresh_current_screen()

func toggle_fx_setting() -> void:
	fx_enabled = not fx_enabled
	save_settings()
	if not fx_enabled:
		clear_fx_overlays()
	refresh_current_screen()

func test_audio_setting() -> void:
	music_enabled = true
	sfx_enabled = true
	tts_enabled = true
	save_settings()

	# 强制同步初始化
	ensure_master_audio_bus()
	warm_speech_backend()

	print("===== 开始音频测试 v1.0.155 =====")

	# v1.0.155: 先测试AudioStreamGenerator生成的音调
	print("AudioTest: 播放440Hz测试音（1秒）")
	play_test_tone_440hz()
	await get_tree().create_timer(1.2).timeout

	if music_enabled:
		start_background_music()

	# 播放测试音效
	await get_tree().create_timer(0.3).timeout
	play_sfx("discard", -1.0)
	await get_tree().create_timer(0.7).timeout

	# 收集诊断信息
	var diag = []
	diag.append("【音频系统诊断 v1.0.156】")
	diag.append("")
	diag.append("1. 用户激活: " + ("是" if audio_touch_unlocked else "否"))
	diag.append("2. 设备: 小米手机 (MIUI)")
	diag.append("")
	diag.append("⚠️ v1.0.156重大改动")
	diag.append("BGM已从WAV改为MP3格式")
	diag.append("因为您能听到TTS语音提示")
	diag.append("说明音频系统正常")
	diag.append("只是WAV格式不兼容")
	diag.append("")
	diag.append("【请回答】")
	diag.append("1. 能听到背景音乐了吗？")
	diag.append("2. 刚才的440Hz测试音听到了吗？")
	diag.append("")

	if bgm_player != null and is_instance_valid(bgm_player):
		diag.append("3. BGM播放器: 正常")
		diag.append("4. BGM音频流: " + ("已加载" if bgm_player.stream != null else "未加载"))
		diag.append("5. BGM正在播放: " + ("是" if bgm_player.playing else "否"))
		diag.append("6. BGM音量: " + str(bgm_player.volume_db) + "dB (0dB=最大)")
		diag.append("7. 音频总线: " + bgm_player.bus)

		# 检查音频总线音量
		var master_idx = AudioServer.get_bus_index("Master")
		if master_idx >= 0:
			var bus_vol = AudioServer.get_bus_volume_db(master_idx)
			var bus_muted = AudioServer.is_bus_mute(master_idx)
			diag.append("8. Master总线音量: " + str(bus_vol) + "dB")
			diag.append("9. Master总线静音: " + ("是" if bus_muted else "否"))

		if bgm_player.stream != null:
			var stream_type = bgm_player.stream.get_class()
			diag.append("10. 音频格式: " + stream_type)

			# 检查音频流大小
			if stream_type == "AudioStreamWAV":
				var wav = bgm_player.stream as AudioStreamWAV
				if wav != null and wav.data != null:
					diag.append("11. 音频数据大小: " + str(wav.data.size()) + " bytes")

		if bgm_player.playing:
			diag.append("")
			diag.append("✓ BGM播放成功")
			diag.append("")
			diag.append("小米手机听不到声音？")
			diag.append("请检查以下MIUI设置:")
			diag.append("")
			diag.append("1. 断开蓝牙设备")
			diag.append("2. 按音量+键调整【媒体音量】")
			diag.append("3. 关闭【游戏加速】")
			diag.append("4. 关闭【省电模式】")
			diag.append("5. 设置→应用管理→本应用")
			diag.append("   →省电策略→无限制")
			diag.append("6. 尝试重启手机")
		else:
			diag.append("")
			diag.append("✗ BGM未播放")
			diag.append("")
			diag.append("已尝试4种播放方法:")
			diag.append("1. 标准play()")
			diag.append("2. play(0.0)从头播放")
			diag.append("3. 重新加载音频流")
			diag.append("4. 完全重建播放器")
			diag.append("")
			diag.append("所有方法都被系统阻止")
	else:
		diag.append("3. ✗ BGM播放器未初始化")

	diag.append("")
	diag.append("点击任意位置关闭")

	print("===== 诊断结果 =====")
	for line in diag:
		print(line)

	# 在屏幕中央显示诊断窗口
	show_diagnostic_dialog(diag)

func show_diagnostic_dialog(lines: Array) -> void:
	# 清除当前屏幕
	clear_screen()

	# 创建半透明背景
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.72)
	root_layer.add_child(bg)
	apply_rect(bg, rect_full(0, 0, 1, 1))

	# 创建诊断信息面板
	var panel = make_panel(root_layer, rect_full(0.1, 0.15, 0.9, 0.85), Color(0.026, 0.058, 0.060, 0.95), 10, Color(0.66, 0.55, 0.28, 0.62))

	# 创建文本容器
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	panel.add_child(vbox)
	apply_rect(vbox, rect_full(0.05, 0.05, 0.95, 0.95))

	# 添加每一行文本
	for line in lines:
		var label = Label.new()
		label.text = line
		label.add_theme_font_size_override("font_size", 28)
		if line.begins_with("【"):
			label.add_theme_color_override("font_color", Color(0.94, 0.86, 0.44))
			label.add_theme_font_size_override("font_size", 36)
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		elif line.begins_with("✓"):
			label.add_theme_color_override("font_color", Color(0.42, 0.82, 0.56))
		elif line.begins_with("✗"):
			label.add_theme_color_override("font_color", Color(0.84, 0.42, 0.38))
		elif line.begins_with("•"):
			label.add_theme_color_override("font_color", Color(0.76, 0.78, 0.84))
		else:
			label.add_theme_color_override("font_color", Color(0.88, 0.90, 0.91))
		vbox.add_child(label)

	# 添加点击关闭功能
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	bg.gui_input.connect(func(event):
		if event is InputEventScreenTouch and event.pressed:
			refresh_current_screen()
	)

func toggle_settings_panel() -> void:
	settings_panel_open = not settings_panel_open
	reset_progress_confirming = false
	refresh_current_screen()

func close_settings_panel() -> void:
	settings_panel_open = false
	reset_progress_confirming = false
	refresh_current_screen()

func refresh_current_screen() -> void:
	if mode == "menu":
		show_menu()
	elif mode == "online_lobby":
		show_online_lobby()
	elif mode == "offline" or mode == "online_game":
		request_game_render()

func request_game_render() -> void:
	if mode != "offline" and mode != "online_game":
		return
	if game_render_queued:
		return
	game_render_queued = true
	call_deferred("flush_game_render")

func flush_game_render() -> void:
	var elapsed = Time.get_ticks_msec() - last_game_render_msec
	if last_game_render_msec > 0 and elapsed < UI_RENDER_MIN_INTERVAL_MSEC:
		await get_tree().create_timer(float(UI_RENDER_MIN_INTERVAL_MSEC - elapsed) / 1000.0).timeout
	game_render_queued = false
	if mode == "offline" or mode == "online_game":
		render_game()

func should_yield_before_ai_discard() -> bool:
	return game_render_queued

func tile_path(code: String) -> String:
	if is_flower_tile(code):
		return "res://assets/tiles/tile_flower_%s.png" % code.to_lower()
	if code.ends_with("W"):
		return "res://assets/tiles/tile_man%s.png" % code.left(code.length() - 1)
	if code.ends_with("T"):
		return "res://assets/tiles/tile_sou%s.png" % code.left(code.length() - 1)
	if code.ends_with("B"):
		return "res://assets/tiles/tile_pin%s.png" % code.left(code.length() - 1)
	match code:
		"E":
			return "res://assets/tiles/tile_honor_east.png"
		"S":
			return "res://assets/tiles/tile_honor_south.png"
		"N":
			return "res://assets/tiles/tile_honor_west.png"
		"R":
			return "res://assets/tiles/tile_honor_north.png"
		"Z":
			return "res://assets/tiles/tile_honor_red.png"
		"F":
			return "res://assets/tiles/tile_honor_green.png"
		"P":
			return "res://assets/tiles/tile_honor_white.png"
	return "res://assets/tiles/tile_back.png"

func clear_screen() -> void:
	for child in get_children():
		if child == audio_layer or child.name == "PersistentAudio":
			continue
		if child == update_request:
			continue
		if child == voice_mic_player:
			continue
		if child == bgm_player or child == sfx_player or child == action_sfx_player:
			continue
		if child == fx_layer:
			continue
		child.queue_free()
	screen_layer = null
	status_label = null
	logs_label = null
	action_bar = null
	update_dialog = null
	update_status_label = null
	update_progress_label = null
	update_progress = null
	update_primary_button = null
	update_secondary_button = null
	safe_area_margins = current_safe_area_margins()
	screen_layer = Control.new()
	screen_layer.name = "ScreenLayer"
	screen_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(screen_layer)
	add_background(screen_layer)
	root_layer = Control.new()
	root_layer.name = "SafeContent"
	root_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	apply_safe_area_offsets(root_layer)
	screen_layer.add_child(root_layer)

func show_menu() -> void:
	if voice_enabled:
		stop_voice_chat(false)
	mode = "menu"
	clear_fx_overlays()
	recover_audio_after_screen_change()
	clear_screen()

	# 增强的背景效果
	add_background(root_layer)

	# 主标题区域 - 增大高度，更好的视觉层次
	var header = make_panel(root_layer, rect_full(0.02, 0.03, 0.98, 0.22), Color(0.012, 0.032, 0.040, 0.96), 20, Color(0.62, 0.52, 0.32, 0.62))
	# 左侧金色装饰条
	header.add_child(make_color_rect(rect_full(0.008, 0.04, 0.018, 0.96), Color(0.92, 0.78, 0.38, 0.88)))
	# 顶部高光线
	header.add_child(make_color_rect(rect_full(0.018, 0.015, 0.982, 0.035), Color(1.0, 1.0, 1.0, 0.06)))
	# 底部分隔线
	header.add_child(make_color_rect(rect_full(0.018, 0.92, 0.982, 0.96), Color(0.56, 0.48, 0.28, 0.28)))

	# 游戏标题 - 更大更突出
	var title = make_label(header, "云桌麻将", 42, Color(0.96, 0.88, 0.52), true)
	apply_rect(title, rect_full(0.04, 0.08, 0.42, 0.55))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

	# 副标题
	var subtitle = make_label(header, "Godot 4.6 开源引擎 · 横屏牌桌 · 真实牌面素材", 16, Color(0.74, 0.84, 0.80), false)
	apply_rect(subtitle, rect_full(0.04, 0.56, 0.56, 0.82))
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

	# 版本徽章
	var version = make_badge(header, rect_full(0.04, 0.82, 0.14, 0.95), "v%s" % app_version(), 12, Color(0.020, 0.044, 0.052, 0.94), Color(0.48, 0.40, 0.22, 0.48), Color(0.84, 0.86, 0.78))
	version.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# 右侧功能徽章组 - 重新布局，更紧凑
	var hero_badge_a = make_badge(header, rect_full(0.72, 0.12, 0.82, 0.36), "单机模式", 14, Color(0.14, 0.38, 0.34, 0.92), Color(0.26, 0.62, 0.54, 0.42), Color(0.94, 0.96, 0.92))
	hero_badge_a.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var hero_badge_b = make_badge(header, rect_full(0.84, 0.12, 0.94, 0.36), "联机对战", 14, Color(0.14, 0.32, 0.42, 0.92), Color(0.30, 0.56, 0.74, 0.42), Color(0.94, 0.96, 0.92))
	hero_badge_b.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# 主菜单卡片区域 - 居中，增大间距
	var row = HBoxContainer.new()
	configure_passive_container(row)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 32)
	row.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE, 0)
	row.custom_minimum_size = Vector2(1040, 240)
	root_layer.add_child(row)
	var content_size = safe_content_pixel_size()
	row.position = Vector2(max(0.0, (content_size.x - 1040.0) * 0.5), max(0.0, (content_size.y - 240.0) * 0.5))

	# 三个主功能卡片 - 更大更醒目
	row.add_child(make_menu_card("单机人机\nAI 自动打牌", Color(0.58, 0.50, 0.32), func() -> void:
		start_offline()
	))
	row.add_child(make_menu_card("联机房间\n连接本机服务器", Color(0.24, 0.48, 0.44), func() -> void:
		show_online_lobby()
	))
	row.add_child(make_menu_card("检查更新\n游戏内下载", Color(0.30, 0.42, 0.58), func() -> void:
		start_update_download()
	))

	# 底部信息栏
	var footer = make_panel(root_layer, rect_full(0.02, 0.82, 0.98, 0.97), Color(0.014, 0.028, 0.036, 0.88), 16, Color(0.42, 0.36, 0.22, 0.32))
	footer.add_child(make_color_rect(rect_full(0.008, 0.04, 0.018, 0.96), Color(0.88, 0.74, 0.34, 0.56)))

	var footer_text = make_label(footer, "当前版本 v%s · 开源免费" % app_version(), 15, Color(0.78, 0.76, 0.66), true)
	apply_rect(footer_text, rect_full(0.04, 0.25, 0.52, 0.75))
	footer_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

	# 统计概览 - 显示胜率等信息
	var stats_text = "已玩%d局 · 胜率%d%%" % [
		int(game_stats.get("games_played", 0)),
		int(float(game_stats.get("win_rate", 0.0)) * 100.0)
	]
	var stats_badge = make_badge(footer, rect_full(0.36, 0.20, 0.52, 0.80), stats_text, 12, Color(0.024, 0.046, 0.052, 0.92), Color(0.34, 0.50, 0.46, 0.30), Color(0.80, 0.86, 0.76))
	stats_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# 规则按钮
	var rules = make_small_button("规则", Color(0.32, 0.46, 0.40), func() -> void:
		show_rules_screen()
	)
	rules.custom_minimum_size = Vector2(88, 48)
	footer.add_child(rules)
	apply_rect(rules, rect_full(0.56, 0.20, 0.65, 0.80))

	# 设置按钮 - 更大的触摸目标
	var settings = make_small_button("设置", Color(0.26, 0.44, 0.58), func() -> void:
		toggle_settings_panel()
	)
	settings.custom_minimum_size = Vector2(100, 52)
	footer.add_child(settings)
	apply_rect(settings, rect_full(0.68, 0.20, 0.78, 0.80))

	# 首次游戏提示
	if tutorial_step == 0:
		var tutorial_hint = make_badge(root_layer, rect_full(0.35, 0.70, 0.65, 0.78), "新玩家？点击查看规则", 15, Color(0.18, 0.40, 0.36, 0.92), Color(0.30, 0.62, 0.52, 0.48), Color(0.94, 0.96, 0.92))
		tutorial_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE

	draw_settings_overlay(root_layer)
	ensure_update_dialog()

func make_menu_card(text: String, color: Color, callback: Callable) -> Button:
	var button = Button.new()
	button.text = ""
	button.custom_minimum_size = Vector2(310, 210)
	configure_touch_button(button)
	var muted = soften_menu_color(color)
	# 增强的卡片样式 - 更大的圆角，更显眼的边框高亮
	button.add_theme_stylebox_override("normal", style(Color(0.018, 0.032, 0.038, 0.97), 20, muted.darkened(0.78), 2, 6))
	button.add_theme_stylebox_override("hover", style(Color(0.026, 0.042, 0.048, 0.98), 20, muted.darkened(0.60), 2, 4))
	button.add_theme_stylebox_override("pressed", style(Color(0.014, 0.026, 0.032, 0.99), 20, muted.darkened(0.72), 2, 2))
	# 左侧彩色条纹装饰 - 更宽更醒目
	button.add_child(make_color_rect(rect_full(0.02, 0.08, 0.055, 0.92), Color(color.r, color.g, color.b, 0.24)))
	# 顶部高光
	button.add_child(make_color_rect(rect_full(0.055, 0.04, 0.945, 0.11), Color(1.0, 1.0, 1.0, 0.025)))
	# 底部渐变
	button.add_child(make_color_rect(rect_full(0.055, 0.86, 0.945, 0.92), Color(0.0, 0.0, 0.0, 0.045)))
	var parts = text.split("\n", false, 2)
	var title_text = parts[0] if parts.size() > 0 else text
	var subtitle_text = parts[1] if parts.size() > 1 else ""
	var title = make_label(button, title_text, 26, Color(0.94, 0.92, 0.84), true)
	apply_rect(title, rect_full(0.10, 0.14, 0.92, 0.52))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	configure_clipped_label(title)
	if subtitle_text != "":
		var subtitle = make_label(button, subtitle_text, 14, Color(0.74, 0.84, 0.78), false)
		apply_rect(subtitle, rect_full(0.10, 0.52, 0.92, 0.82))
		subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		subtitle.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		configure_clipped_label(subtitle)
	if callback.is_valid():
		connect_immediate_button_action(button, callback)
	return button

func show_online_lobby() -> void:
	mode = "online_lobby"
	recover_audio_after_screen_change()
	clear_screen()

	# 主面板 - 统一的全屏面板
	var panel = make_panel(root_layer, rect_full(0.02, 0.02, 0.98, 0.98), Color(0.012, 0.032, 0.040, 0.96), 20, Color(0.62, 0.52, 0.30, 0.52))
	# 左侧金色装饰
	panel.add_child(make_color_rect(rect_full(0.006, 0.03, 0.016, 0.97), Color(0.92, 0.78, 0.38, 0.84)))
	# 顶部分隔线
	panel.add_child(make_color_rect(rect_full(0.016, 0.012, 0.984, 0.03), Color(1.0, 1.0, 1.0, 0.05)))

	# 标题区域
	var title = make_label(panel, "联机大厅", 32, Color(0.94, 0.86, 0.48), true)
	apply_rect(title, rect_full(0.04, 0.028, 0.28, 0.10))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	var subtitle = make_label(panel, "连接本机或局域网房间，创建后等待玩家进入。", 15, Color(0.70, 0.82, 0.76), false)
	apply_rect(subtitle, rect_full(0.04, 0.095, 0.48, 0.14))
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

	# 服务器和状态徽章
	var server_badge = make_badge(panel, rect_full(0.68, 0.040, 0.84, 0.105), "%s:%d" % [DEFAULT_HOST, DEFAULT_PORT], 12, Color(0.020, 0.046, 0.054, 0.94), Color(0.34, 0.52, 0.48, 0.36), Color(0.82, 0.90, 0.82))
	server_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var state_badge = make_badge(panel, rect_full(0.86, 0.040, 0.96, 0.105), lobby_connection_state_text(), 12, Color(0.18, 0.28, 0.26, 0.94), Color(0.36, 0.56, 0.46, 0.36), Color(0.90, 0.94, 0.84))
	state_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# 表单面板 - 连接与房间设置
	var form_panel = make_panel(panel, rect_full(0.035, 0.17, 0.475, 0.87), Color(0.010, 0.026, 0.034, 0.95), 16, Color(0.38, 0.44, 0.40, 0.28))
	# 表单标题栏装饰
	form_panel.add_child(make_color_rect(rect_full(0.006, 0.02, 0.016, 0.98), Color(0.84, 0.72, 0.38, 0.52)))
	form_panel.add_child(make_color_rect(rect_full(0.02, 0.065, 0.98, 0.08), Color(0.84, 0.74, 0.42, 0.10)))
	var form_title = make_label(form_panel, "连接与房间", 20, Color(0.90, 0.86, 0.60), true)
	apply_rect(form_title, rect_full(0.05, 0.020, 0.50, 0.095))
	form_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

	var form = VBoxContainer.new()
	configure_passive_container(form)
	form.anchor_left = 0.06
	form.anchor_top = 0.15
	form.anchor_right = 0.94
	form.anchor_bottom = 0.68
	form.add_theme_constant_override("separation", 14)
	form_panel.add_child(form)
	online_name_edit = add_line_edit(form, "昵称", "云桌道友")
	online_host_edit = add_line_edit(form, "服务器 IP/域名", DEFAULT_HOST)
	online_room_edit = add_line_edit(form, "房间号", selected_room)

	# 操作按钮组 - 连接/创建/加入
	var button_row = HBoxContainer.new()
	configure_passive_container(button_row)
	button_row.add_theme_constant_override("separation", 10)
	apply_rect(button_row, rect_full(0.06, 0.72, 0.94, 0.81))
	form_panel.add_child(button_row)
	button_row.add_child(make_lobby_action_button("连接", Color(0.20, 0.48, 0.66), func() -> void:
		connect_online()
	))
	button_row.add_child(make_lobby_action_button("创建", Color(0.22, 0.54, 0.42), func() -> void:
		send_online_action({"type": "createRoom", "name": online_name_edit.text}, "创建房间")
	))
	button_row.add_child(make_lobby_action_button("加入", Color(0.72, 0.48, 0.24), func() -> void:
		selected_room = online_room_edit.text
		send_online_action({"type": "joinRoom", "roomCode": online_room_edit.text, "name": online_name_edit.text}, "加入房间")
	))

	# 底部按钮 - 开始/返回
	var start_row = HBoxContainer.new()
	configure_passive_container(start_row)
	start_row.add_theme_constant_override("separation", 10)
	apply_rect(start_row, rect_full(0.06, 0.84, 0.94, 0.93))
	form_panel.add_child(start_row)
	start_row.add_child(make_lobby_action_button("开始游戏", Color(0.56, 0.28, 0.22), func() -> void:
		send_online_action({"type": "startGame"}, "开始游戏")
	))
	start_row.add_child(make_lobby_action_button("返回菜单", Color(0.28, 0.34, 0.36), func() -> void:
		show_menu()
	))

	# 状态栏
	status_label = make_label(panel, "未连接。服务器默认 %s:%d" % [DEFAULT_HOST, DEFAULT_PORT], 15, Color(0.82, 0.94, 0.86), false)
	apply_rect(status_label, rect_full(0.04, 0.885, 0.50, 0.945))
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	configure_clipped_label(status_label)

	# 房间状态面板
	var log_panel = make_panel(panel, rect_full(0.505, 0.17, 0.965, 0.87), Color(0.010, 0.026, 0.032, 0.95), 16, Color(0.34, 0.44, 0.38, 0.28))
	log_panel.add_child(make_color_rect(rect_full(0.006, 0.02, 0.016, 0.98), Color(0.84, 0.72, 0.38, 0.42)))
	log_panel.add_child(make_color_rect(rect_full(0.02, 0.13, 0.98, 0.15), Color(1.0, 1.0, 1.0, 0.028)))
	var log_title = make_label(log_panel, "房间状态", 20, Color(0.84, 0.87, 0.74), true)
	apply_rect(log_title, rect_full(0.05, 0.020, 0.48, 0.095))
	log_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	var room_badge_text = "房间号 " + (selected_room if selected_room != "" else "--")
	var room_badge = make_badge(log_panel, rect_full(0.68, 0.030, 0.94, 0.100), room_badge_text, 12, Color(0.020, 0.044, 0.050, 0.94), Color(0.46, 0.52, 0.34, 0.30), Color(0.82, 0.87, 0.72))
	room_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	logs_label = make_label(log_panel, "", 15, Color(0.84, 0.87, 0.76), false)
	apply_rect(logs_label, rect_full(0.05, 0.16, 0.95, 0.94))
	logs_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	logs_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	logs_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	render_room_log()
	ensure_update_dialog()

func add_line_edit(parent: Control, label_text: String, value: String) -> LineEdit:
	var caption = Label.new()
	caption.text = label_text
	caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	caption.add_theme_font_size_override("font_size", 18)
	caption.add_theme_color_override("font_color", Color(0.92, 0.86, 0.62))
	parent.add_child(caption)
	var edit = LineEdit.new()
	edit.text = value
	edit.custom_minimum_size = Vector2(360, 46)
	edit.add_theme_font_size_override("font_size", 21)
	var input_styles = input_style_set()
	edit.add_theme_stylebox_override("normal", input_styles["normal"])
	edit.add_theme_stylebox_override("focus", input_styles["focus"])
	edit.add_theme_stylebox_override("read_only", input_styles["read_only"])
	edit.add_theme_color_override("font_color", Color(0.96, 0.95, 0.89))
	edit.add_theme_color_override("font_placeholder_color", Color(0.70, 0.74, 0.68))
	edit.add_theme_color_override("font_selected_color", Color(0.10, 0.12, 0.10))
	edit.add_theme_color_override("selection_color", Color(0.56, 0.70, 0.48, 0.72))
	edit.add_theme_color_override("caret_color", Color(0.94, 0.86, 0.54))
	parent.add_child(edit)
	return edit

func make_lobby_action_button(text: String, color: Color, callback: Callable) -> Button:
	var button = make_small_button(text, color, callback)
	button.custom_minimum_size = Vector2(130, 50)
	button.add_theme_font_size_override("font_size", 17)
	return button

func lobby_connection_state_text() -> String:
	match tcp.get_status():
		StreamPeerTCP.STATUS_CONNECTED:
			return "已连接"
		StreamPeerTCP.STATUS_CONNECTING:
			return "连接中"
		StreamPeerTCP.STATUS_ERROR:
			return "异常"
	return "未连接"

func connect_online() -> void:
	tcp.disconnect_from_host()
	tcp = StreamPeerTCP.new()
	tcp_buffer = ""
	next_online_poll_msec = 0
	online_room.clear()
	online_game.clear()
	clear_online_feedback()
	sent_hello = false
	var err = tcp.connect_to_host(online_host_edit.text.strip_edges(), DEFAULT_PORT)
	set_status("正在连接 %s:%d ..." % [online_host_edit.text.strip_edges(), DEFAULT_PORT])
	if err != OK:
		set_status("连接失败：%s" % error_string(err))

func poll_online(now_msec: int = -1) -> void:
	if mode != "online_lobby" and mode != "online_game":
		return
	if now_msec >= 0:
		if now_msec < next_online_poll_msec:
			return
		next_online_poll_msec = now_msec + ONLINE_POLL_INTERVAL_MSEC
	tcp.poll()
	var status = tcp.get_status()
	if status != tcp_status:
		tcp_status = status
		if status == StreamPeerTCP.STATUS_CONNECTED:
			set_status("已连接服务器")
			if not sent_hello:
				sent_hello = true
				send_online({"type": "hello", "name": online_name_edit.text if online_name_edit else "云桌道友"})
		elif status == StreamPeerTCP.STATUS_ERROR:
			set_status("连接出错")
		elif status == StreamPeerTCP.STATUS_NONE and mode.begins_with("online"):
			pass
	if status != StreamPeerTCP.STATUS_CONNECTED:
		return
	var available = tcp.get_available_bytes()
	if available <= 0:
		return
	tcp_buffer += tcp.get_utf8_string(available)
	while tcp_buffer.find("\n") >= 0:
		var split_at = tcp_buffer.find("\n")
		var line = tcp_buffer.substr(0, split_at).strip_edges()
		tcp_buffer = tcp_buffer.substr(split_at + 1)
		if line.length() > 0:
			handle_online_message(line)

func send_online(payload: Dictionary) -> bool:
	if tcp.get_status() != StreamPeerTCP.STATUS_CONNECTED:
		set_status("请先连接服务器。")
		return false
	var text = JSON.stringify(payload) + "\n"
	tcp.put_data(text.to_utf8_buffer())
	return true

func send_online_action(payload: Dictionary, label: String = "") -> void:
	var action_label = label if label.strip_edges() != "" else online_action_label(payload)
	if send_online(payload):
		play_outgoing_online_action_audio(payload)
		online_last_sent_action = action_label
		online_last_sent_msec = Time.get_ticks_msec()
		set_online_feedback("已发送%s，等待服务器确认。" % action_label, true)

func play_outgoing_online_action_audio(payload: Dictionary) -> void:
	var kind = str(payload.get("type", "")).to_lower()
	if kind == "discard":
		var tile = str(payload.get("tile", ""))
		if tile == "":
			return
		var seat = int(online_game.get("youSeat", -1))
		online_pending_local_discard_identity = online_discard_identity(seat, tile)
		play_sfx("discard", -1.0)
		speak_tile_call(tile)
	elif kind == "claim":
		var claim = str(payload.get("claim", ""))
		if claim == "pass":
			return
		var tile = str(first_present(payload, ["tile", "discard", "lastDiscard"], ""))
		if tile == "" and typeof(online_game.get("pending", null)) == TYPE_DICTIONARY:
			tile = str(online_game.get("pending", {}).get("tile", ""))
		play_sfx(claim_sfx_key(claim), -1.5)
		speak_action_call(claim_label(claim), tile)

func claim_sfx_key(claim: String) -> String:
	match claim:
		"peng":
			return "peng"
		"gang":
			return "gang"
		"hu":
			return "win"
		"chi":
			return "peng"
	return "discard"

func online_action_label(payload: Dictionary) -> String:
	var kind = str(payload.get("type", "操作"))
	if kind == "discard":
		return "打出%s" % tile_label(str(payload.get("tile", "")))
	if kind == "claim":
		return claim_label(str(payload.get("claim", "操作")))
	if kind == "createRoom":
		return "创建房间"
	if kind == "joinRoom":
		return "加入房间"
	if kind == "startGame":
		return "开始游戏"
	return "操作"

func set_online_feedback(text: String, waiting: bool = false) -> void:
	online_feedback = text
	online_waiting_for_server = waiting
	if not waiting:
		online_last_sent_msec = 0
	set_status(text)

func clear_online_feedback() -> void:
	online_feedback = ""
	online_waiting_for_server = false
	online_last_sent_action = ""
	online_last_sent_msec = 0

func online_claim_payload(claim: String, choice: Dictionary = {}) -> Dictionary:
	var payload: Dictionary = {"type": "claim", "claim": claim}
	if not choice.is_empty():
		var meld = normalize_tile_array(choice.get("meld", choice.get("tiles", [])))
		var needed = normalize_tile_array(choice.get("needed", []))
		payload["choice"] = choice
		payload["meld"] = meld
		payload["tiles"] = meld
		payload["needed"] = needed
	return payload

func toggle_voice_chat() -> void:
	if mode != "online_game" and mode != "online_lobby":
		set_status("语音需要进入联机房间后使用。")
		return
	if tcp.get_status() != StreamPeerTCP.STATUS_CONNECTED:
		set_status("语音需要先连接服务器。")
		return
	if voice_enabled:
		stop_voice_chat(true)
	else:
		start_voice_chat()
	render_game()

func start_voice_chat() -> void:
	if not ensure_voice_capture():
		set_status("麦克风初始化失败。")
		return
	voice_sequence = 0
	voice_peak = 0.0
	voice_capture_effect.clear_buffer()
	voice_mic_player.play()
	voice_enabled = true
	send_online({"type": "voiceState", "speaking": true})
	set_status("语音已开启。")

func stop_voice_chat(notify: bool = true) -> void:
	if voice_mic_player != null and is_instance_valid(voice_mic_player):
		voice_mic_player.stop()
	if voice_capture_effect != null:
		voice_capture_effect.clear_buffer()
	voice_enabled = false
	voice_peak = 0.0
	if notify and tcp.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		send_online({"type": "voiceState", "speaking": false})
	set_status("语音已关闭。")

func ensure_voice_capture() -> bool:
	if voice_capture_effect != null and voice_mic_player != null and is_instance_valid(voice_mic_player):
		return true
	var bus_index = AudioServer.get_bus_index(VOICE_BUS_NAME)
	if bus_index < 0:
		AudioServer.add_bus()
		bus_index = AudioServer.get_bus_count() - 1
		AudioServer.set_bus_name(bus_index, VOICE_BUS_NAME)
		AudioServer.set_bus_volume_db(bus_index, -80.0)
	voice_capture_effect = AudioEffectCapture.new()
	AudioServer.add_bus_effect(bus_index, voice_capture_effect)
	voice_mic_player = AudioStreamPlayer.new()
	voice_mic_player.stream = AudioStreamMicrophone.new()
	voice_mic_player.bus = VOICE_BUS_NAME
	voice_mic_player.process_mode = Node.PROCESS_MODE_ALWAYS
	attach_audio_node(voice_mic_player)
	return true

func poll_voice_capture() -> void:
	if not voice_enabled or voice_capture_effect == null:
		return
	if tcp.get_status() != StreamPeerTCP.STATUS_CONNECTED:
		stop_voice_chat(false)
		return
	while voice_capture_effect.get_frames_available() >= VOICE_CHUNK_FRAMES:
		var frames = voice_capture_effect.get_buffer(VOICE_CHUNK_FRAMES)
		var payload = build_voice_payload(frames)
		if payload.is_empty():
			return
		send_online(payload)

func build_voice_payload(frames: PackedVector2Array) -> Dictionary:
	var encoded = encode_voice_frames(frames)
	if encoded.is_empty():
		return {}
	var payload = {
		"type": "voiceMessage",
		"format": "pcm16",
		"sampleRate": int(AudioServer.get_mix_rate()),
		"channels": 1,
		"sequence": voice_sequence,
		"audio": str(encoded.get("audio", "")),
		"peak": float(encoded.get("peak", 0.0)),
	}
	voice_sequence += 1
	voice_peak = float(encoded.get("peak", 0.0))
	return payload

func encode_voice_frames(frames: PackedVector2Array) -> Dictionary:
	if frames.is_empty():
		return {}
	var bytes = PackedByteArray()
	var peak = 0.0
	for frame in frames:
		var mono = clamp((frame.x + frame.y) * 0.5, -1.0, 1.0)
		peak = max(peak, abs(mono))
		var sample = int(round(mono * 32767.0))
		if sample < 0:
			sample += 65536
		bytes.append(sample & 0xff)
		bytes.append((sample >> 8) & 0xff)
	return {
		"audio": Marshalls.raw_to_base64(bytes),
		"peak": peak,
		"bytes": bytes.size(),
	}

func handle_voice_message(data: Dictionary) -> void:
	var speaker_seat = int(data.get("seat", data.get("fromSeat", -1)))
	if speaker_seat >= 0 and speaker_seat == int(online_game.get("youSeat", -2)):
		return
	var stream = make_voice_stream(str(data.get("audio", "")), int(data.get("sampleRate", AudioServer.get_mix_rate())), int(data.get("channels", 1)))
	if stream == null:
		return
	var player = AudioStreamPlayer.new()
	player.stream = stream
	player.bus = "Master"
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	attach_audio_node(player)
	player.finished.connect(func() -> void:
		player.queue_free()
	)
	player.play()

func make_voice_stream(audio_base64: String, sample_rate: int, channels: int) -> AudioStreamWAV:
	if audio_base64 == "":
		return null
	var data = Marshalls.base64_to_raw(audio_base64)
	if data.is_empty():
		return null
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = max(8000, sample_rate)
	stream.stereo = channels == 2
	stream.data = data
	return stream

func handle_online_message(line: String) -> void:
	var data = JSON.parse_string(line)
	if typeof(data) != TYPE_DICTIONARY:
		set_status("服务器消息解析失败")
		return
	var kind = normalize_online_message_kind(data)
	if kind == "welcome":
		set_status("已连接：" + str(data.get("name", "")))
	elif kind == "info":
		set_online_feedback(online_server_message_text(data, "服务器提示"), false)
	elif kind == "error":
		handle_online_error(data)
	elif kind == "ack":
		handle_online_ack(data)
	elif kind == "log":
		handle_online_log(data)
	elif kind == "roomState":
		clear_online_feedback()
		var room_value = data.get("room", data)
		online_room = (room_value as Dictionary).duplicate(true) if typeof(room_value) == TYPE_DICTIONARY else {}
		selected_room = str(first_present(online_room, ["code", "roomCode", "room_code"], ""))
		if online_room_edit:
			online_room_edit.text = selected_room
		render_room_log()
	elif kind == "gameState":
		clear_online_feedback()
		var next_game = normalize_online_game_state(data)
		announce_online_game_audio(next_game)
		online_game = next_game
		mode = "online_game"
		request_game_render()
	elif kind == "voiceMessage":
		handle_voice_message(data)
	else:
		var message = online_server_message_text(data, "")
		if message != "":
			set_online_feedback(message, false)

func normalize_online_message_kind(data: Dictionary) -> String:
	var raw = str(first_present(data, ["type", "event", "kind", "messageType"], "")).strip_edges()
	var compact = raw.to_lower().replace("_", "").replace("-", "")
	if compact == "message" and data.has("event"):
		raw = str(data.get("event", ""))
		compact = raw.to_lower().replace("_", "").replace("-", "")
	match compact:
		"welcome", "hello":
			return "welcome"
		"info", "notice", "status", "servermessage", "message":
			return "info"
		"error", "err", "reject", "rejected", "actionrejected", "invalidaction", "denied":
			return "error"
		"ack", "ok", "success", "accepted", "actionack", "actionaccepted":
			return "ack"
		"roomstate", "roomupdate", "lobbystate", "lobbyupdate", "room":
			return "roomState"
		"gamestate", "gameupdate", "gamesnapshot", "state", "snapshot", "game":
			return "gameState"
		"voicemessage", "voice", "voicepacket":
			return "voiceMessage"
		"log", "roomlog", "eventlog":
			return "log"
	if data.has("game") or data.has("hand") or data.has("yourHand") or data.has("selfHand"):
		return "gameState"
	if data.has("room") or (data.has("players") and data.has("roomCode")):
		return "roomState"
	return raw

func online_server_message_text(data: Dictionary, fallback: String) -> String:
	var value = first_present(data, ["message", "text", "detail", "reason", "error"], fallback)
	var text = str(value).strip_edges()
	return text if text != "" else fallback

func handle_online_ack(data: Dictionary) -> void:
	var message = online_server_message_text(data, "")
	if message == "":
		message = "%s已确认" % (online_last_sent_action if online_last_sent_action != "" else "操作")
	set_online_feedback("服务器确认：%s" % message, false)

func handle_online_error(data: Dictionary) -> void:
	var message = online_server_message_text(data, "操作被服务器拒绝")
	set_online_feedback("服务器拒绝：%s" % message, false)

func handle_online_log(data: Dictionary) -> void:
	var message = online_server_message_text(data, "")
	if message == "":
		return
	if typeof(online_room.get("logs", [])) != TYPE_ARRAY:
		online_room["logs"] = []
	var logs: Array = online_room.get("logs", [])
	logs.append(message)
	while logs.size() > 14:
		logs.remove_at(0)
	online_room["logs"] = logs
	set_online_feedback(message, false)
	render_room_log()

func announce_online_game_audio(next_game: Dictionary) -> void:
	var tile = str(next_game.get("lastDiscard", ""))
	var seat = int(next_game.get("lastDiscardSeat", -1))
	if tile == "" or seat < 0:
		return
	var next_key = online_discard_audio_key(next_game)
	if next_key == "" or next_key == online_announced_discard_key:
		return
	if online_game.is_empty():
		online_announced_discard_key = next_key
		return
	var identity = online_discard_identity(seat, tile)
	if identity != "" and identity == online_pending_local_discard_identity:
		online_pending_local_discard_identity = ""
		online_announced_discard_key = next_key
		return
	online_announced_discard_key = next_key
	play_sfx("discard", -1.0)
	speak_tile_call(tile)

func online_discard_audio_key(game: Dictionary) -> String:
	var tile = str(game.get("lastDiscard", ""))
	var seat = int(game.get("lastDiscardSeat", -1))
	if tile == "" or seat < 0:
		return ""
	var discard_count = 0
	for player in game.get("players", []):
		if typeof(player) != TYPE_DICTIONARY:
			continue
		if int(player.get("seat", -1)) == seat:
			var discards = player.get("discards", [])
			if typeof(discards) == TYPE_ARRAY:
				discard_count = discards.size()
			break
	return "%s:%d" % [online_discard_identity(seat, tile), discard_count]

func online_discard_identity(seat: int, tile: String) -> String:
	if seat < 0 or tile == "":
		return ""
	return "%d:%s" % [seat, tile]

func normalize_online_game_state(message: Dictionary) -> Dictionary:
	var source = message.get("game", message)
	if typeof(source) != TYPE_DICTIONARY:
		source = {}
	var game: Dictionary = (source as Dictionary).duplicate(true)
	game["roomCode"] = str(first_present(game, ["roomCode", "room_code", "code"], selected_room))
	game["youSeat"] = int(first_present(game, ["youSeat", "seat", "playerSeat", "selfSeat"], message.get("seat", game.get("youSeat", -1))))
	game["currentSeat"] = int(first_present(game, ["currentSeat", "turnSeat", "activeSeat", "current"], 0))
	game["wallCount"] = int(first_present(game, ["wallCount", "wallRemaining", "remainingTiles"], game.get("wallCount", 0)))
	game["phase"] = normalize_online_phase(str(first_present(game, ["phase", "state", "status"], "")))
	game["hand"] = normalize_tile_array(first_present(game, ["hand", "tiles", "yourHand", "selfHand"], []))
	var last_discard_value = first_present(game, ["lastDiscard", "discard", "lastTile"], "")
	game["lastDiscard"] = normalize_last_discard_tile(last_discard_value)
	game["lastDiscardSeat"] = normalize_last_discard_seat(last_discard_value, int(first_present(game, ["lastDiscardSeat", "discardSeat", "lastDiscarder", "fromSeat"], -1)))
	game["players"] = normalize_online_players(first_present(game, ["players", "seats"], []))
	game["pending"] = normalize_online_pending(first_present(game, ["pending", "pendingClaim", "claim"], {}), game)
	if str(game.get("phase", "")) == "" and typeof(game.get("pending", null)) == TYPE_DICTIONARY and game["pending"].get("options", []).size() > 0:
		game["phase"] = "pendingClaim"
	return game

func first_present(data: Dictionary, keys: Array, fallback = null):
	for key in keys:
		if data.has(key):
			var value = data[key]
			if value != null:
				return value
	return fallback

func normalize_online_phase(value: String) -> String:
	var phase = value.strip_edges()
	var compact = phase.to_lower().replace("_", "").replace("-", "")
	if compact == "awaitdiscard" or compact == "discard" or compact == "turn":
		return "awaitDiscard"
	if compact == "pendingclaim" or compact == "claim" or compact == "response":
		return "pendingClaim"
	if compact == "ended" or compact == "finished" or compact == "gameover":
		return "ended"
	if compact == "ready" or compact == "waiting":
		return compact
	return phase

func normalize_tile_array(value) -> Array:
	var result: Array = []
	if typeof(value) != TYPE_ARRAY:
		return result
	for item in value:
		if typeof(item) == TYPE_DICTIONARY:
			result.append(str(first_present(item, ["tile", "code", "id"], "")))
		else:
			result.append(str(item))
	return result

func normalize_last_discard_tile(value) -> String:
	if typeof(value) == TYPE_DICTIONARY:
		return str(first_present(value, ["tile", "code", "id"], ""))
	return str(value)

func normalize_last_discard_seat(value, fallback: int) -> int:
	if typeof(value) == TYPE_DICTIONARY:
		return int(first_present(value, ["seat", "fromSeat", "discardSeat"], fallback))
	return fallback

func normalize_online_players(value) -> Array:
	var result: Array = []
	if typeof(value) != TYPE_ARRAY:
		return result
	for item in value:
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var player: Dictionary = (item as Dictionary).duplicate(true)
		var hand_value = first_present(player, ["hand", "tiles"], [])
		var normalized_hand = normalize_tile_array(hand_value)
		player["seat"] = int(first_present(player, ["seat", "index", "position"], result.size()))
		player["name"] = str(first_present(player, ["name", "nickname", "userName"], "玩家"))
		player["handCount"] = numeric_count(first_present(player, ["handCount", "hand_count", "tileCount"], normalized_hand), normalized_hand.size())
		player["flowerCount"] = numeric_count(first_present(player, ["flowerCount", "flowers", "flower_count"], 0), 0)
		player["score"] = int(first_present(player, ["score", "points"], 0))
		player["discards"] = normalize_tile_array(first_present(player, ["discards", "discarded", "river"], []))
		player["melds"] = normalize_online_melds(first_present(player, ["melds", "openMelds", "sets"], []))
		result.append(player)
	return result

func numeric_count(value, fallback: int = 0) -> int:
	if value == null:
		return fallback
	if typeof(value) == TYPE_ARRAY:
		return value.size()
	return int(value)

func normalize_online_melds(value) -> Array:
	var melds: Array = []
	if typeof(value) != TYPE_ARRAY:
		return melds
	for meld in value:
		if typeof(meld) == TYPE_ARRAY:
			melds.append(normalize_tile_array(meld))
		elif typeof(meld) == TYPE_DICTIONARY:
			melds.append(normalize_tile_array(first_present(meld, ["tiles", "meld", "cards"], [])))
	return melds

func normalize_online_pending(value, game: Dictionary) -> Dictionary:
	var pending: Dictionary = {}
	if typeof(value) == TYPE_DICTIONARY:
		pending = (value as Dictionary).duplicate(true)
	var options = normalize_claim_options(first_present(pending, ["options", "claims", "actions"], game.get("claimOptions", [])))
	pending["options"] = options
	pending["tile"] = normalize_last_discard_tile(first_present(pending, ["tile", "discard", "lastDiscard"], game.get("lastDiscard", "")))
	pending["fromSeat"] = int(first_present(pending, ["fromSeat", "discardSeat", "lastDiscardSeat"], game.get("lastDiscardSeat", -1)))
	pending["chi_choices"] = normalize_online_chi_choices(first_present(pending, ["chi_choices", "chiChoices", "choices", "chi"], game.get("chiChoices", [])), str(pending.get("tile", "")))
	if pending["chi_choices"].size() > 0 and not options.has("chi"):
		options.append("chi")
	return pending

func normalize_claim_options(value) -> Array:
	var options: Array = []
	if typeof(value) != TYPE_ARRAY:
		return options
	for item in value:
		var name = ""
		if typeof(item) == TYPE_DICTIONARY:
			name = str(first_present(item, ["claim", "type", "action", "name"], "")).strip_edges().to_lower()
		else:
			name = str(item).strip_edges().to_lower()
		match name:
			"吃", "chi":
				name = "chi"
			"碰", "peng", "pong":
				name = "peng"
			"杠", "gang", "kong":
				name = "gang"
			"胡", "hu", "win":
				name = "hu"
			"过", "pass":
				name = "pass"
		if name != "" and not options.has(name):
			options.append(name)
	return options

func normalize_online_chi_choices(value, claimed_tile: String = "") -> Array:
	var choices: Array = []
	if typeof(value) != TYPE_ARRAY:
		return choices
	for item in value:
		var choice = normalize_online_chi_choice(item, claimed_tile)
		if not choice.is_empty():
			choices.append(choice)
	return choices

func normalize_online_chi_choice(value, claimed_tile: String = "") -> Dictionary:
	var meld: Array = []
	var needed: Array = []
	if typeof(value) == TYPE_DICTIONARY:
		meld = normalize_tile_array(first_present(value, ["meld", "tiles", "cards"], []))
		needed = normalize_tile_array(first_present(value, ["needed", "handTiles", "use"], []))
	elif typeof(value) == TYPE_ARRAY:
		meld = normalize_tile_array(value)
	if meld.is_empty() and not needed.is_empty() and claimed_tile != "":
		meld = needed.duplicate()
		meld.append(claimed_tile)
		sort_hand(meld)
	if needed.is_empty() and not meld.is_empty() and claimed_tile != "":
		needed = meld.duplicate()
		needed.erase(claimed_tile)
	if meld.size() < 3:
		return {}
	return {"meld": meld, "needed": needed}

func render_room_log() -> void:
	if logs_label == null:
		return
	var room_code = str(first_present(online_room, ["code", "roomCode", "room_code"], selected_room))
	if room_code == "":
		room_code = "--"
	var text = "房间号：" + room_code + "\n\n"
	var players = online_room.get("players", [])
	if typeof(players) == TYPE_ARRAY and not players.is_empty():
		for player in players:
			if typeof(player) != TYPE_DICTIONARY:
				continue
			text += "%d号位  %s%s\n" % [int(player.get("seat", 0)) + 1, str(player.get("name", "空位")), "  AI" if bool(player.get("bot", false)) else ""]
	else:
		text += "等待房间状态同步。\n"
	text += "\n房间日志\n"
	var logs = online_room.get("logs", [])
	if typeof(logs) != TYPE_ARRAY:
		logs = []
	if logs.is_empty():
		text += "暂无日志。\n"
	for log_item in logs:
		if typeof(log_item) == TYPE_DICTIONARY:
			text += str(log_item.get("text", "")) + "\n"
		else:
			text += str(log_item) + "\n"
	logs_label.text = text

func start_offline() -> void:
	if voice_enabled:
		stop_voice_chat(false)
	mode = "offline"
	recover_audio_after_screen_change()
	# 尝试加载进度
	var loaded = load_offline_progress()
	if not loaded:
		# 没有保存的进度，开始新游戏
		dealer_seat = 0
		offline_hand_number = 1
		offline_last_winner = -1
		offline_dealer_repeat = false
		table_logs.clear()
		players.clear()
		for i in range(4):
			players.append({
				"name": SEAT_NAMES[i],
				"hand": [],
				"discards": [],
				"melds": [],
				"flowers": 0,
				"flower_tiles": [],
				"score": MATCH_START_SCORE,
				"bot": i != 0,
			})
	else:
		# 加载了进度，继续之前的游戏
		set_status("已加载进度：第%d局" % offline_hand_number)
		offline_last_winner = -1
		offline_dealer_repeat = false
		table_logs.clear()
		# 确保players数组已经有4个玩家
		while players.size() < 4:
			players.append({
				"name": SEAT_NAMES[players.size()],
				"hand": [],
				"discards": [],
				"melds": [],
				"flowers": 0,
				"flower_tiles": [],
				"score": MATCH_START_SCORE,
				"bot": players.size() != 0,
			})
	deal_offline_hand()

func deal_offline_hand() -> void:
	mode = "offline"
	offline_phase = "await_discard"
	offline_turn_needs_draw = false
	offline_pending_claim.clear()
	clear_pending_danger_discard()
	offline_claim_counts.clear()
	offline_package_liability.clear()
	offline_last_draw.clear()
	offline_ai_active = false
	round_summary = ""
	last_score_deltas.clear()
	offline_last_winner = -1
	offline_dealer_repeat = false
	current_seat = dealer_seat
	last_discard = ""
	last_discard_seat = -1
	for seat in range(players.size()):
		players[seat]["hand"] = []
		players[seat]["discards"] = []
		players[seat]["melds"] = []
		players[seat]["flowers"] = 0
		players[seat]["flower_tiles"] = []
	wall = make_wall()
	wall.shuffle()
	for round_index in range(13):
		for seat in range(4):
			draw_tile_for(seat, false)
	draw_tile_for(dealer_seat, false)
	for seat in range(4):
		sort_hand(players[seat]["hand"])
	add_log("第%d局开始，%s坐庄。" % [offline_hand_number, players[dealer_seat]["name"]])
	render_game()

func start_next_offline_hand(auto_run_ai: bool = true) -> void:
	if mode != "offline":
		return
	if is_offline_match_finished():
		return
	clear_fx_overlays()
	if not offline_dealer_repeat:
		dealer_seat = (dealer_seat + 1) % 4
		offline_hand_number += 1
	else:
		add_log("%s连庄。" % players[dealer_seat]["name"])
	deal_offline_hand()
	if auto_run_ai and current_seat != 0:
		run_ai_until_human()

func make_wall() -> Array[String]:
	var next_wall: Array[String] = []
	for code in TILE_CODES:
		for copy in range(4):
			next_wall.append(code)
	for code in FLOWER_CODES:
		next_wall.append(code)
	return next_wall

func draw_tile_for(seat: int, announce: bool = true, source: String = "normal") -> String:
	while not wall.is_empty():
		var tile = wall.pop_back()
		if is_flower_tile(tile):
			players[seat]["flowers"] = int(players[seat].get("flowers", 0)) + 1
			players[seat]["flower_tiles"].append(tile)
			if announce:
				add_log("%s补花%s。" % [players[seat]["name"], tile_label(tile)])
				play_sfx("draw", -7.0)
			continue
		players[seat]["hand"].append(tile)
		if announce:
			play_sfx("draw", -8.0)
		offline_last_draw = {
			"seat": seat,
			"tile": tile,
			"source": source,
			"wall_empty": wall.is_empty(),
		}
		return tile
	return ""

func sort_hand(hand: Array) -> void:
	hand.sort_custom(func(a, b): return tile_sort_index(str(a)) < tile_sort_index(str(b)))

func render_game() -> void:
	var render_start_time = Time.get_ticks_msec()
	game_render_queued = false
	last_game_render_msec = Time.get_ticks_msec()
	clear_screen()
	# 延迟AI辅助计算，优先渲染关键UI
	current_human_advice = []
	draw_game_top_hud(root_layer)

	var outer = make_panel(root_layer, TABLE_OUTER_RECT, Color(0.11, 0.070, 0.033, 0.98), 34, UI_GOLD_SOFT)
	add_texture(outer, wood_texture, TABLE_OUTER_TEXTURE_RECT, 0.58)
	draw_table_ornaments(outer)

	var table = make_panel(outer, TABLE_INNER_RECT, UI_FELT, 26, UI_FELT_LINE)
	add_texture(table, felt_texture, TABLE_INNER_TEXTURE_RECT, 0.88)
	draw_walls(table)
	draw_discards(table)
	draw_center(table)
	draw_melds(table)

	# 座位面板暂时不显示威胁报告
	var seat_threat_reports: Dictionary = {}
	for seat_layout in SEAT_LAYOUTS:
		draw_seat(root_layer, int(seat_layout[0]), seat_layout[1], str(seat_layout[2]), seat_threat_reports)
	draw_table_log(root_layer)
	draw_advisor_panel(root_layer)
	draw_hand(root_layer)
	draw_actions(root_layer)
	draw_round_summary(root_layer)

	# 记录渲染性能
	var render_elapsed = Time.get_ticks_msec() - render_start_time
	perf_render_count += 1
	perf_render_total_ms += render_elapsed

	# AI辅助异步更新（延迟到下一帧）
	if player_ai_assist_enabled() and mode == "offline" and can_self_discard():
		call_deferred("update_ai_assistance_async")
	draw_settings_overlay(root_layer)
	ensure_update_dialog()
	update_fx_turn_pulse()

func player_ai_assist_enabled() -> bool:
	return PLAYER_AI_ASSIST_ENABLED

func update_ai_assistance_async() -> void:
	# 异步更新AI辅助信息，不阻塞UI渲染
	if mode != "offline" or not can_self_discard():
		return

	var start_time = Time.get_ticks_msec()

	# 计算AI推荐
	current_human_advice = get_ai_discard_reports(0)

	var elapsed = Time.get_ticks_msec() - start_time
	perf_ai_decision_count += 1
	perf_ai_decision_total_ms += elapsed

	# 更新手牌显示的AI标注
	if not current_human_advice.is_empty():
		update_hand_ai_hints()

	# 计算对手威胁（如果启用）
	if player_ai_assist_enabled():
		var seat_threat_context = make_ai_evaluation_context(0, visible_tile_counts())
		var seat_threat_reports = render_seat_threat_reports(0, seat_threat_context)
		# 更新座位威胁显示
		update_seat_threats_display(seat_threat_reports)

func update_hand_ai_hints() -> void:
	# 更新手牌上的AI提示标记（如果手牌托盘已渲染）
	# 这里可以选择性地重绘手牌区域，或者等待下次render_game
	pass

func update_seat_threats_display(seat_threat_reports: Dictionary) -> void:
	# 更新座位威胁显示（如果座位面板已渲染）
	# 这里可以选择性地更新座位信息，或者等待下次render_game
	pass

func draw_game_top_hud(parent: Control) -> void:
	# 顶部HUD面板 - 增强视觉效果
	var hud = make_panel(parent, TOP_HUD_RECT, Color(0.010, 0.018, 0.022, 0.98), 20, Color(0.52, 0.44, 0.26, 0.58), 6)
	# 左侧金色装饰
	hud.add_child(make_color_rect(rect_full(0.008, 0.08, 0.015, 0.92), Color(0.90, 0.76, 0.36, 0.82)))
	# 顶部高光线
	hud.add_child(make_color_rect(rect_full(0.015, 0.04, 0.985, 0.12), Color(1.0, 1.0, 1.0, 0.04)))

	# 模式徽章
	var mode_text = "单机" if mode == "offline" else "联机"
	var mode_badge = make_badge(hud, TOP_HUD_MODE_BADGE_RECT, mode_text, 12, Color(0.018, 0.042, 0.048, 0.94), SEAT_ACCENT_COLORS[0], Color(0.92, 0.94, 0.88))
	mode_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# 标题
	var title_text = "单机修炼场 第%d局" % [offline_hand_number] if mode == "offline" else "联机房间 " + str(online_game.get("roomCode", selected_room))
	var title = make_label(hud, title_text, 22, Color(0.96, 0.90, 0.60), true)
	apply_rect(title, TOP_HUD_TITLE_RECT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	configure_clipped_label(title)

	# 状态
	var status = make_label(hud, current_status_text(), 17, UI_TEXT_SUB, true)
	apply_rect(status, TOP_HUD_STATUS_RECT)
	configure_clipped_label(status)

	# 分数条
	draw_score_strip(hud, TOP_HUD_SCORE_STRIP_RECT)

	# 余牌信息
	var wall = make_label(hud, top_hud_wall_text(), 12, Color(0.74, 0.78, 0.72), true)
	wall.add_theme_stylebox_override("normal", style(Color(0.016, 0.024, 0.028, 0.94), 10, Color(0.24, 0.28, 0.26, 0.36), 1, 0))
	apply_rect(wall, TOP_HUD_WALL_RECT)
	configure_clipped_label(wall)

	# 操作按钮组
	var settings = make_top_hud_button("设置", Color(0.22, 0.44, 0.56), func() -> void:
		toggle_settings_panel()
	)
	hud.add_child(settings)
	apply_rect(settings, TOP_HUD_SETTINGS_BUTTON_RECT)

	var back = make_top_hud_button("返回", Color(0.36, 0.40, 0.40), func() -> void:
		if mode == "offline":
			show_menu()
		else:
			show_online_lobby()
	)
	hud.add_child(back)
	apply_rect(back, TOP_HUD_BACK_BUTTON_RECT)

	var update = make_top_hud_button("更新", Color(0.38, 0.48, 0.74), func() -> void:
		start_update_download()
	)
	hud.add_child(update)
	apply_rect(update, TOP_HUD_UPDATE_BUTTON_RECT)

func top_hud_wall_text() -> String:
	var last = get_last_discard()
	return "余%d 上%s" % [get_wall_count(), tile_label(last) if last != "" else "--"]

func draw_score_strip(parent: Control, rect: Rect2) -> void:
	var strip = Control.new()
	parent.add_child(strip)
	apply_rect(strip, rect)
	for seat in range(4):
		var active = get_current_seat() == seat
		var player = get_player_info(seat)
		var chip_fill = Color(0.008, 0.016, 0.018, 0.96) if active else Color(0.006, 0.014, 0.016, 0.92)
		var chip_border = Color(0.56, 0.46, 0.22, 0.72) if active else Color(0.28, 0.32, 0.30, 0.28)
		var chip = make_panel(strip, SCORE_STRIP_CHIP_RECTS[seat], chip_fill, 12, chip_border, 3)
		# 座位颜色标识
		chip.add_child(make_color_rect(SCORE_STRIP_ACCENT_RECT, SEAT_ACCENT_COLORS[seat]))
		# 玩家名称
		var name_text = "我" if seat == 0 else ai_profile_short_label(seat) if mode == "offline" else str(player.get("name", "玩家"))
		var name = make_label(chip, name_text, 11, Color(0.94, 0.90, 0.78), true)
		name.add_theme_stylebox_override("normal", style(SEAT_NAME_BADGE_COLORS[seat].darkened(0.12), 8, Color(0.88, 0.78, 0.44, 0.14), 1, 0))
		apply_rect(name, SCORE_STRIP_NAME_RECT)
		configure_clipped_label(name)
		# 分数
		var score = make_label(chip, compact_score_text(int(player.get("score", 0))), 13, Color(0.96, 0.94, 0.88), true)
		apply_rect(score, SCORE_STRIP_SCORE_RECT)
		score.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		configure_clipped_label(score)

func draw_settings_overlay(parent: Control) -> void:
	if not settings_panel_open:
		return
	var overlay = Control.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	parent.add_child(overlay)

	# 设置面板 - 更精致的样式
	var panel = make_panel(overlay, SETTINGS_PANEL_RECT, Color(0.008, 0.014, 0.016, 0.99), 20, Color(0.14, 0.12, 0.08, 0.36), 5)
	# 标题栏
	make_panel(panel, rect_full(0.0, 0.0, 1.0, 0.16), Color(0.040, 0.052, 0.048, 0.76), 20, Color(1.0, 1.0, 1.0, 0.030))
	# 左侧金色装饰
	panel.add_child(make_color_rect(rect_full(0.006, 0.02, 0.014, 0.98), Color(0.90, 0.76, 0.36, 0.72)))

	var title = make_label(panel, "设置", 24, Color(0.94, 0.82, 0.42), true)
	apply_rect(title, SETTINGS_TITLE_RECT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

	var close = make_small_button("关闭", Color(0.30, 0.34, 0.36), func() -> void:
		close_settings_panel()
	)
	close.custom_minimum_size = Vector2(88, 42)
	panel.add_child(close)
	apply_rect(close, SETTINGS_CLOSE_RECT)

	# 声音设置
	var audio_grid = make_settings_section(panel, SETTINGS_AUDIO_SECTION_RECT, "声音")
	audio_grid.columns = 1
	make_setting_row(audio_grid, "背景音乐", "当前: %s" % ("开启" if music_enabled else "关闭"), make_setting_button("音乐", music_enabled, func() -> void:
		toggle_music_setting()
	))
	make_setting_row(audio_grid, "音效反馈", "当前: %s" % ("开启" if sfx_enabled else "关闭"), make_setting_button("音效", sfx_enabled, func() -> void:
		toggle_sfx_setting()
	))
	make_setting_row(audio_grid, "语音报牌", "当前: %s" % ("开启" if tts_enabled else "关闭"), make_setting_button("报牌", tts_enabled, func() -> void:
		toggle_tts_setting()
	))
	make_setting_row(audio_grid, "播放测试", "试听当前音效音量", make_audio_test_button(func() -> void:
		test_audio_setting()
	))

	# 体验设置
	var play_grid = make_settings_section(panel, SETTINGS_PLAY_SECTION_RECT, "体验")
	play_grid.columns = 1
	make_setting_row(play_grid, "AI 节奏", "当前: %s" % ("快速" if fast_mode_enabled else "标准"), make_setting_button("快速", fast_mode_enabled, func() -> void:
		toggle_fast_mode_setting()
	))
	make_setting_row(play_grid, "桌面特效", "当前: %s" % ("开启" if fx_enabled else "关闭"), make_setting_button("特效", fx_enabled, func() -> void:
		toggle_fx_setting()
	))
	make_setting_row(play_grid, "播放曲目", str(BGM_TRACKS[current_bgm_index].get("name", "默认曲目")), make_bgm_switch_button(func() -> void:
		switch_bgm_track()
	))

	# 维护设置
	var maint_grid = make_settings_section(panel, SETTINGS_MAINT_SECTION_RECT, "维护")
	maint_grid.columns = 1
	make_setting_row(maint_grid, "本地进度", "清空统计、偏好和离线记录", make_reset_progress_button(func() -> void:
		reset_offline_progress()
		close_settings_panel()
	))

func make_settings_section(parent: Control, rect: Rect2, title_text: String) -> GridContainer:
	var section = make_panel(parent, rect, Color(0.010, 0.018, 0.022, 0.88), 14, Color(0.30, 0.34, 0.30, 0.26), 0)
	# 左侧彩色装饰条
	section.add_child(make_color_rect(rect_full(0.004, 0.02, 0.012, 0.98), Color(0.86, 0.74, 0.38, 0.52)))
	var section_title = make_label(section, title_text, 14, Color(0.90, 0.84, 0.60), true)
	apply_rect(section_title, SETTINGS_SECTION_TITLE_RECT)
	section_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	var grid = GridContainer.new()
	configure_passive_container(grid)
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 12)
	section.add_child(grid)
	apply_rect(grid, SETTINGS_SECTION_GRID_RECT)
	return grid

func make_setting_row(parent: Control, title: String, status: String, button: Button) -> void:
	var row = Panel.new()
	configure_passive_container(row)
	row.custom_minimum_size = Vector2(0, 42)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_stylebox_override("panel", style(Color(0.018, 0.028, 0.032, 0.88), 10, Color(0.28, 0.34, 0.30, 0.42), 1, 0))
	parent.add_child(row)
	var label = make_label(row, "%s\n%s" % [title, status], 12, Color(0.82, 0.84, 0.78), false)
	apply_rect(label, SETTINGS_ROW_STATUS_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	configure_clipped_label(label)
	button.custom_minimum_size = Vector2(0, 0)
	apply_rect(button, SETTINGS_ROW_BUTTON_RECT)
	row.add_child(button)

func make_setting_button(label: String, enabled: bool, callback: Callable) -> Button:
	var color = Color(0.22, 0.52, 0.42) if enabled else Color(0.44, 0.32, 0.28)
	var button = make_small_button("%s%s" % [label, "开" if enabled else "关"], color, callback)
	button.custom_minimum_size = Vector2(140, 48)
	button.add_theme_font_size_override("font_size", 18)
	return button

func make_audio_test_button(callback: Callable) -> Button:
	var button = make_small_button("试音", Color(0.28, 0.42, 0.56), callback)
	button.custom_minimum_size = Vector2(140, 48)
	button.add_theme_font_size_override("font_size", 18)
	return button

func make_bgm_switch_button(callback: Callable) -> Button:
	# v1.0.157: 切换BGM按钮
	var track_name = BGM_TRACKS[current_bgm_index]["name"]
	var button = make_small_button("切歌:" + track_name, Color(0.38, 0.40, 0.56), callback)
	button.custom_minimum_size = Vector2(140, 48)
	button.add_theme_font_size_override("font_size", 16)
	return button

func make_reset_progress_button(callback: Callable) -> Button:
	var button = make_small_button("重置进度", Color(0.56, 0.36, 0.30), callback)
	button.custom_minimum_size = Vector2(140, 48)
	button.add_theme_font_size_override("font_size", 18)
	return button

func draw_table_ornaments(parent: Control) -> void:
	for item in TABLE_ORNAMENT_EDGES:
		make_panel(parent, item[0], item[1], 8, item[2], 0)
	for item in TABLE_CORNER_RECTS:
		draw_table_corner(parent, item)

func draw_table_corner(parent: Control, rects: Array) -> void:
	make_panel(parent, rects[0], TABLE_CORNER_FILL, 5, TABLE_CORNER_BORDER, 0)
	make_panel(parent, rects[1], TABLE_CORNER_VERTICAL_FILL, 5, TABLE_CORNER_VERTICAL_BORDER, 0)

func draw_walls(parent: Control) -> void:
	for item in WALL_LAYOUTS:
		var strip = make_wall_back_strip(int(item[2]), bool(item[3]))
		strip.anchor_left = item[0].x
		strip.anchor_top = item[0].y
		strip.anchor_right = item[1].x
		strip.anchor_bottom = item[1].y
		parent.add_child(strip)

func make_wall_back_strip(count: int, horizontal: bool) -> Control:
	var strip = WallBackStrip.new()
	strip.configure(count, horizontal, WALL_BACK_TILE_SIZE, Color(0.73, 0.69, 0.56, 0.98), Color(0.34, 0.29, 0.18, 0.82))
	return strip

func make_wall_back_tile(size: Vector2 = WALL_BACK_TILE_SIZE, detailed: bool = true) -> Control:
	var panel = Panel.new()
	panel.custom_minimum_size = size
	panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.clip_contents = true
	panel.add_theme_stylebox_override("panel", style(Color(0.73, 0.69, 0.56, 0.98), 7, Color(0.34, 0.29, 0.18, 0.82), 1, 2 if detailed else 0))
	if not detailed:
		return panel
	var texture = TextureRect.new()
	texture.texture = tile_back
	texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture.modulate = Color(1, 1, 1, 0.20)
	texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture.set_anchors_preset(Control.PRESET_FULL_RECT)
	texture.offset_left = 3
	texture.offset_top = 3
	texture.offset_right = -3
	texture.offset_bottom = -3
	panel.add_child(texture)
	var mark = make_label(panel, "云", max(9, int(size.y * 0.34)), Color(0.22, 0.17, 0.10, 0.82), true)
	mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(mark, rect_full(0.12, 0.18, 0.88, 0.82))
	return panel

func draw_discards(parent: Control) -> void:
	var table_size = game_table_pixel_size()
	for zone in DISCARD_ZONES:
		var seat = int(zone[0])
		var zone_rect: Rect2 = zone[1]
		var grid = GridContainer.new()
		configure_passive_container(grid)
		grid.columns = int(zone[2])
		apply_rect(grid, zone_rect)
		grid.add_theme_constant_override("h_separation", DISCARD_GRID_SEPARATION)
		grid.add_theme_constant_override("v_separation", DISCARD_GRID_SEPARATION)
		parent.add_child(grid)
		var discards = get_discards(seat)
		var visible_rows = discard_zone_visible_rows_for_table_size(zone_rect, grid.columns, table_size)
		var tile_size = discard_zone_tile_size_for_table_size(zone_rect, grid.columns, visible_rows, table_size)
		var visible_start = tail_window_start(discards.size(), grid.columns * visible_rows)
		var visible_count = discards.size() - visible_start
		for i in range(visible_count):
			var source_index = visible_start + i
			var highlighted = seat == get_last_discard_seat() and i == visible_count - 1
			grid.add_child(make_tile_view(str(discards[source_index]), tile_size, false, Callable(), highlighted))

func discard_zone_visible_rows(zone_rect: Rect2, columns: int) -> int:
	return discard_zone_visible_rows_for_table_size(zone_rect, columns, game_table_pixel_size())

func discard_zone_visible_rows_for_table_size(zone_rect: Rect2, columns: int, table_size: Vector2) -> int:
	var zone_size = discard_zone_pixel_size_for_table_size(zone_rect, table_size)
	var max_rows = int(floor((zone_size.y + float(DISCARD_GRID_SEPARATION)) / (DISCARD_TILE_MIN_SIZE.y + float(DISCARD_GRID_SEPARATION))))
	return clamp(max_rows, 1, 3)

func discard_zone_tile_size(zone_rect: Rect2, columns: int, rows: int) -> Vector2:
	return discard_zone_tile_size_for_table_size(zone_rect, columns, rows, game_table_pixel_size())

func discard_zone_tile_size_for_table_size(zone_rect: Rect2, columns: int, rows: int, table_size: Vector2) -> Vector2:
	var zone_size = discard_zone_pixel_size_for_table_size(zone_rect, table_size)
	var safe_columns = max(1, columns)
	var safe_rows = max(1, rows)
	var available_width = max(1.0, (zone_size.x - float(DISCARD_GRID_SEPARATION * (safe_columns - 1))) / float(safe_columns))
	var available_height = max(1.0, (zone_size.y - float(DISCARD_GRID_SEPARATION * (safe_rows - 1))) / float(safe_rows))
	var width = min(DISCARD_TILE_MAX_SIZE.x, available_width, available_height / DISCARD_TILE_ASPECT)
	var height = min(DISCARD_TILE_MAX_SIZE.y, available_height, width * DISCARD_TILE_ASPECT)
	width = min(width, height / DISCARD_TILE_ASPECT)
	return Vector2(max(1.0, floor(width)), max(1.0, floor(height)))

func discard_grid_fits_zone(zone_rect: Rect2, columns: int, rows: int, tile_size: Vector2) -> bool:
	return discard_grid_fits_zone_for_table_size(zone_rect, columns, rows, tile_size, game_table_pixel_size())

func discard_grid_fits_zone_for_table_size(zone_rect: Rect2, columns: int, rows: int, tile_size: Vector2, table_size: Vector2) -> bool:
	var zone_size = discard_zone_pixel_size_for_table_size(zone_rect, table_size)
	var required_width = float(columns) * tile_size.x + float(max(0, columns - 1) * DISCARD_GRID_SEPARATION)
	var required_height = float(rows) * tile_size.y + float(max(0, rows - 1) * DISCARD_GRID_SEPARATION)
	return required_width <= zone_size.x + 0.5 and required_height <= zone_size.y + 0.5

func discard_zone_pixel_size(zone_rect: Rect2) -> Vector2:
	return discard_zone_pixel_size_for_table_size(zone_rect, game_table_pixel_size())

func discard_zone_pixel_size_for_table_size(zone_rect: Rect2, table_size: Vector2) -> Vector2:
	return Vector2((zone_rect.size.x - zone_rect.position.x) * table_size.x, (zone_rect.size.y - zone_rect.position.y) * table_size.y)

func game_table_pixel_size() -> Vector2:
	var content_size = safe_content_pixel_size()
	return Vector2(content_size.x * 0.710 * 0.910, content_size.y * 0.657 * 0.890)

func effective_viewport_size() -> Vector2:
	var viewport_size = get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		viewport_size = Vector2(
			float(ProjectSettings.get_setting("display/window/size/viewport_width", 1280)),
			float(ProjectSettings.get_setting("display/window/size/viewport_height", 720))
		)
	return viewport_size

func current_safe_area_margins() -> Vector4:
	var window_size_i = DisplayServer.window_get_size()
	var safe_area_i = DisplayServer.get_display_safe_area()
	var window_size = Vector2(float(window_size_i.x), float(window_size_i.y))
	var safe_area = Rect2(
		Vector2(float(safe_area_i.position.x), float(safe_area_i.position.y)),
		Vector2(float(safe_area_i.size.x), float(safe_area_i.size.y))
	)
	return safe_area_margins_for_viewport(effective_viewport_size(), window_size, safe_area)

func safe_area_margins_for_viewport(viewport_size: Vector2, window_size: Vector2 = Vector2.ZERO, safe_area: Rect2 = Rect2()) -> Vector4:
	var margins = SAFE_CONTENT_MIN_MARGIN
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return margins
	if window_size.x > 0.0 and window_size.y > 0.0 and safe_area.size.x > 0.0 and safe_area.size.y > 0.0:
		var scale_x = viewport_size.x / window_size.x
		var scale_y = viewport_size.y / window_size.y
		margins.x = max(margins.x, max(0.0, safe_area.position.x) * scale_x)
		margins.y = max(margins.y, max(0.0, safe_area.position.y) * scale_y)
		margins.z = max(margins.z, max(0.0, window_size.x - safe_area.position.x - safe_area.size.x) * scale_x)
		margins.w = max(margins.w, max(0.0, window_size.y - safe_area.position.y - safe_area.size.y) * scale_y)
	return clamp_safe_area_margins(margins, viewport_size)

func clamp_safe_area_margins(margins: Vector4, viewport_size: Vector2) -> Vector4:
	return Vector4(
		clamp(margins.x, 0.0, viewport_size.x * SAFE_CONTENT_MAX_SIDE_FRACTION),
		clamp(margins.y, 0.0, viewport_size.y * SAFE_CONTENT_MAX_TOP_FRACTION),
		clamp(margins.z, 0.0, viewport_size.x * SAFE_CONTENT_MAX_SIDE_FRACTION),
		clamp(margins.w, 0.0, viewport_size.y * SAFE_CONTENT_MAX_BOTTOM_FRACTION)
	)

func update_safe_area_layout() -> void:
	safe_area_margins = current_safe_area_margins()
	if root_layer != null and is_instance_valid(root_layer):
		apply_safe_area_offsets(root_layer)

func apply_safe_area_offsets(control: Control) -> void:
	if control == null:
		return
	control.set_anchors_preset(Control.PRESET_FULL_RECT)
	control.offset_left = safe_area_margins.x
	control.offset_top = safe_area_margins.y
	control.offset_right = -safe_area_margins.z
	control.offset_bottom = -safe_area_margins.w

func safe_content_pixel_size() -> Vector2:
	return safe_content_pixel_size_for_margins(effective_viewport_size(), safe_area_margins)

func safe_content_pixel_size_for_margins(viewport_size: Vector2, margins: Vector4) -> Vector2:
	return Vector2(max(1.0, viewport_size.x - margins.x - margins.z), max(1.0, viewport_size.y - margins.y - margins.w))

func draw_center(parent: Control) -> void:
	# 中心区域面板 - 增强视觉效果
	var center = make_panel(parent, CENTER_PANEL_RECT, Color(0.006, 0.014, 0.016, 0.96), 30, Color(0.48, 0.42, 0.24, 0.52), 4)
	# 内部装饰框
	make_panel(center, CENTER_INNER_RECT, Color(0.004, 0.036, 0.036, 0.98), 62, Color(0.28, 0.26, 0.18, 0.42), 0)

	# 状态文本
	var status = make_label(center, current_status_text(), 16, Color(0.92, 0.90, 0.82), true)
	apply_rect(status, CENTER_STATUS_RECT)

	# 余牌信息
	var wall_label = make_label(center, "余牌", 13, Color(0.72, 0.76, 0.70), false)
	apply_rect(wall_label, CENTER_WALL_LABEL_RECT)
	var wall_text = make_label(center, "%d" % get_wall_count(), 28, Color(0.66, 0.74, 0.70, 0.94), true)
	apply_rect(wall_text, CENTER_WALL_COUNT_RECT)

	# 上张牌
	var last = get_last_discard()
	if last != "":
		var last_label = make_label(center, "上张", 13, Color(0.72, 0.76, 0.70), false)
		apply_rect(last_label, CENTER_LAST_LABEL_RECT)
		var tile = make_tile_view(last, CENTER_LAST_TILE_SIZE, false, Callable(), true)
		center.add_child(tile)
		apply_rect(tile, CENTER_LAST_TILE_RECT)

	# 风位标签
	for i in range(4):
		var wind_color = Color(0.70, 0.70, 0.46, 0.94) if i == get_current_seat() else Color(0.50, 0.48, 0.32, 0.76)
		var wind = make_label(center, str(CENTER_WIND_LABELS[i]), 19, wind_color, true)
		apply_rect(wind, CENTER_WIND_RECTS[i])

	# 骰子点装饰
	for dot_rect in CENTER_DICE_DOT_RECTS:
		make_panel(center, dot_rect, Color(0.58, 0.54, 0.40, 0.64), 22, Color(0.74, 0.70, 0.56, 0.28), 0)

func draw_dice_dot(parent: Control, x: float, y: float) -> void:
	make_panel(parent, rect_full(x - CENTER_DICE_DOT_RADIUS, y - CENTER_DICE_DOT_RADIUS, x + CENTER_DICE_DOT_RADIUS, y + CENTER_DICE_DOT_RADIUS), CENTER_DICE_DOT_FILL, 20, CENTER_DICE_DOT_BORDER, 0)

func draw_melds(parent: Control) -> void:
	for layout in MELD_LAYOUTS:
		var seat = int(layout[0])
		var meld_list = get_melds(seat)
		if meld_list.is_empty():
			continue
		var area = HBoxContainer.new()
		configure_passive_container(area)
		area.add_theme_constant_override("separation", 3)
		apply_rect(area, layout[1])
		parent.add_child(area)
		for meld in meld_list:
			for tile in meld:
				area.add_child(make_tile_view(str(tile), Vector2(34, 46), false, Callable()))

func draw_seat(parent: Control, seat: int, rect: Rect2, side: String, seat_threat_reports: Dictionary = {}) -> void:
	var active = get_current_seat() == seat
	var p = get_player_info(seat)
	# 座位面板 - 增强的视觉区分
	var panel_fill = Color(0.016, 0.028, 0.032, 0.94) if active else Color(0.012, 0.020, 0.024, 0.90)
	var panel_border = Color(0.60, 0.52, 0.30, 0.56) if active else Color(0.32, 0.36, 0.34, 0.28)
	var panel = make_panel(parent, rect, panel_fill, 18, panel_border, 3)
	# 左侧座位颜色条
	panel.add_child(make_color_rect(rect_full(0.0, 0.0, 0.025, 1.0), SEAT_ACCENT_COLORS[seat].blend(Color(0.12, 0.14, 0.14, 1.0))))
	# 顶部高光
	panel.add_child(make_color_rect(rect_full(0.025, 0.015, 0.975, 0.05), Color(1.0, 1.0, 1.0, 0.03)))
	# 头部区域
	make_panel(panel, rect_full(0.0, 0.0, 1.0, 0.19), SEAT_HEADER_COLORS[seat].darkened(0.14), 18, Color(1.0, 0.90, 0.52, 0.06))
	# 底部区域
	make_panel(panel, rect_full(0.0, 0.78, 1.0, 1.0), Color(0.008, 0.014, 0.016, 0.24), 18, Color(0.14, 0.18, 0.18, 0.05))

	# 头像
	var avatar = make_avatar_view(seat, active)
	panel.add_child(avatar)
	apply_rect(avatar, rect_full(0.04, 0.14, 0.36, 0.92))

	var threat_report = seat_threat_report_from_map(seat, seat_threat_reports)
	var threat_badge_text = opponent_seat_threat_badge_text_from_report(threat_report)
	var display_name = str(p.get("name", "玩家"))
	if mode == "offline" and seat != 0:
		display_name += " · " + ai_profile_short_label(seat)
	var name = make_label(panel, display_name, 15, Color(0.94, 0.90, 0.80), true)
	var name_right = 0.55 if threat_badge_text != "" else 0.75 if active else 0.96
	apply_rect(name, rect_full(0.39, 0.10, name_right, 0.36))
	name.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	configure_clipped_label(name)

	if active:
		var turn_badge = make_badge(panel, rect_full(0.77, 0.11, 0.96, 0.32), "行牌", 11, Color(0.72, 0.60, 0.24, 0.92), Color(1.0, 0.86, 0.44, 0.42), Color(0.13, 0.12, 0.08))
		turn_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if threat_badge_text != "":
		var threat_badge = make_badge(panel, rect_full(0.57, 0.11, 0.75, 0.32), threat_badge_text, 12, opponent_seat_threat_color_from_report(threat_report), Color(1.0, 0.91, 0.48, 0.56), Color(0.10, 0.11, 0.10))
		threat_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var package_text = package_preview(seat)
	var threat_line = opponent_seat_threat_line_from_report(threat_report)
	# 统计信息 - 增强的视觉效果
	draw_seat_stat_pill(panel, SEAT_STAT_RECTS[0], "手", str(int(p.get("hand_count", 0))), SEAT_ACCENT_COLORS[seat])
	draw_seat_stat_pill(panel, SEAT_STAT_RECTS[1], "花", str(int(p.get("flowers", 0))), Color(0.56, 0.44, 0.28))
	draw_seat_stat_pill(panel, SEAT_STAT_RECTS[2], "分", compact_score_text(int(p.get("score", 0))), Color(0.32, 0.44, 0.46))

	if package_text != "" or threat_line != "":
		var info_text = package_text if package_text != "" else threat_line
		var info = make_label(panel, info_text, 11, Color(0.70, 0.74, 0.68), false)
		apply_rect(info, rect_full(0.39, 0.58, 0.96, 0.72))
		info.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		configure_clipped_label(info)

	var river_text = discard_preview(seat)
	var flowers = flower_preview(seat)
	var has_flower_tiles = draw_seat_flower_tiles(panel, seat)
	if flowers != "" and not has_flower_tiles:
		river_text = "花 " + flowers + ("\n" + river_text if river_text != "" else "")
	var river = make_label(panel, river_text, 12, UI_TEXT_MUTED, false)
	apply_rect(river, rect_full(0.39, 0.78 if has_flower_tiles else 0.63, 0.96, 0.92))
	river.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	configure_clipped_label(river)
	if seat == dealer_seat:
		var dealer = make_badge(panel, rect_full(0.27, 0.06, 0.38, 0.28), "庄", 16, Color(0.58, 0.12, 0.08, 0.90), Color(1.0, 0.79, 0.34, 0.76), Color(0.96, 0.90, 0.72))
		dealer.mouse_filter = Control.MOUSE_FILTER_IGNORE

func draw_seat_stat_pill(parent: Control, rect: Rect2, label_text: String, value_text: String, accent: Color) -> void:
	var pill = make_panel(parent, rect, Color(0.010, 0.018, 0.022, 0.92), 10, accent.blend(Color(0.18, 0.19, 0.17, 1.0)), 0)
	# 左侧强调色条
	pill.add_child(make_color_rect(rect_full(0.0, 0.0, 0.06, 1.0), accent.darkened(0.06)))
	var label = make_label(pill, label_text, 9, Color(0.72, 0.74, 0.66, 0.94), false)
	apply_rect(label, rect_full(0.10, 0.12, 0.42, 0.88))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	configure_clipped_label(label)
	var value = make_label(pill, value_text, 12, Color(0.96, 0.94, 0.88), true)
	apply_rect(value, rect_full(0.34, 0.06, 0.94, 0.94))
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	configure_clipped_label(value)

func draw_seat_flower_tiles(parent: Control, seat: int) -> bool:
	if mode != "offline" or seat < 0 or seat >= players.size():
		return false
	var flowers: Array = players[seat].get("flower_tiles", [])
	if flowers.is_empty():
		return false
	var strip = HBoxContainer.new()
	configure_passive_container(strip)
	strip.alignment = BoxContainer.ALIGNMENT_BEGIN
	strip.add_theme_constant_override("separation", 2)
	apply_rect(strip, rect_full(0.39, 0.60, 0.96, 0.76))
	parent.add_child(strip)
	var visible_count = min(4, flowers.size())
	for i in range(visible_count):
		strip.add_child(make_tile_view(str(flowers[i]), Vector2(22, 31), false, Callable()))
	if flowers.size() > visible_count:
		var more = make_label(strip, "+%d" % (flowers.size() - visible_count), 11, Color(0.96, 0.86, 0.58), true)
		more.custom_minimum_size = Vector2(24, 31)
	return true

func draw_table_log(parent: Control) -> void:
	var panel = make_panel(parent, rect_full(0.018, 0.585, 0.205, 0.755), Color(0.012, 0.028, 0.032, 0.90), 14, Color(0.34, 0.44, 0.40, 0.26))
	make_panel(panel, rect_full(0.0, 0.0, 1.0, 0.24), Color(0.040, 0.052, 0.050, 0.68), 14, Color(1.0, 1.0, 1.0, 0.025))
	var title = make_label(panel, "行动流", 12, Color(0.84, 0.78, 0.60), true)
	apply_rect(title, rect_full(0.06, 0.02, 0.45, 0.24))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	var count = make_label(panel, "%d条" % table_logs.size(), 10, Color(0.54, 0.66, 0.62), false)
	apply_rect(count, rect_full(0.52, 0.03, 0.94, 0.24))
	count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	var recent = table_log_tail(3)
	if recent.is_empty():
		var empty = make_label(panel, "等待开局", 11, Color(0.62, 0.72, 0.68), false)
		apply_rect(empty, rect_full(0.06, 0.36, 0.94, 0.72))
		empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		configure_clipped_label(empty)
		return
	for i in range(recent.size()):
		draw_table_log_row(panel, i, str(recent[i]))

func table_log_tail(limit: int) -> Array[String]:
	var result: Array[String] = []
	var start = max(0, table_logs.size() - limit)
	for i in range(start, table_logs.size()):
		result.append(str(table_logs[i]))
	return result

func draw_table_log_row(parent: Control, index: int, text: String) -> void:
	var top = 0.30 + float(index) * 0.215
	var row = make_panel(parent, rect_full(0.045, top, 0.955, top + 0.175), Color(0.026, 0.044, 0.044, 0.76), 8, Color(1.0, 1.0, 1.0, 0.030), 0)
	var tag = table_log_tag(text)
	var tag_color = table_log_tag_color(tag)
	var badge = make_panel(row, rect_full(0.035, 0.22, 0.205, 0.78), tag_color.darkened(0.16), 6, tag_color, 0)
	var badge_text = make_label(badge, tag, 10, Color(0.98, 0.96, 0.86), true)
	apply_rect(badge_text, rect_full(0.0, 0.0, 1.0, 1.0))
	var body = make_label(row, table_log_display_text(text), 11, Color(0.76, 0.84, 0.78), false)
	apply_rect(body, rect_full(0.24, 0.10, 0.96, 0.90))
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	configure_clipped_label(body)

func table_log_tag(text: String) -> String:
	if text.find("胡") >= 0 or text.find("自摸") >= 0:
		return "胡"
	if text.find("杠") >= 0:
		return "杠"
	if text.find("碰") >= 0:
		return "碰"
	if text.find("吃") >= 0:
		return "吃"
	if text.find("可响应") >= 0:
		return "应"
	if text.find("打出") >= 0:
		return "打"
	if text.find("摸到") >= 0 or text.find("补花") >= 0:
		return "摸"
	if text.find("开始") >= 0 or text.find("坐庄") >= 0 or text.find("连庄") >= 0:
		return "局"
	return "记"

func table_log_tag_color(tag: String) -> Color:
	match tag:
		"胡":
			return Color(0.94, 0.42, 0.30, 0.96)
		"杠":
			return Color(0.62, 0.54, 0.88, 0.96)
		"碰", "吃":
			return Color(0.38, 0.66, 0.82, 0.96)
		"应":
			return Color(0.88, 0.62, 0.22, 0.96)
		"打":
			return Color(0.22, 0.58, 0.48, 0.96)
		"摸":
			return Color(0.42, 0.62, 0.52, 0.96)
		"局":
			return Color(0.74, 0.62, 0.34, 0.96)
	return Color(0.44, 0.54, 0.54, 0.92)

func table_log_display_text(text: String) -> String:
	return text.replace("。", "")

func draw_advisor_panel(parent: Control) -> void:
	if mode != "offline" or offline_phase == "ended" or not player_ai_assist_enabled():
		return
	var panel = make_panel(parent, rect_full(0.155, 0.625, 0.545, 0.755), Color(0.014, 0.034, 0.040, 0.90), 14, Color(0.42, 0.36, 0.22, 0.34))
	make_panel(panel, rect_full(0.0, 0.0, 1.0, 0.14), Color(0.044, 0.056, 0.058, 0.72), 14, Color(1.0, 1.0, 1.0, 0.025))
	var title = make_label(panel, "牌势", 13, Color(0.86, 0.78, 0.56), true)
	apply_rect(title, rect_full(0.03, 0.04, 0.16, 0.22))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	var context = make_label(panel, advisor_context_line(), 11, Color(0.62, 0.72, 0.68), false)
	apply_rect(context, rect_full(0.17, 0.04, 0.97, 0.22))
	context.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	configure_clipped_label(context)
	if offline_phase == "pending_claim":
		draw_advisor_info_card(panel, rect_full(0.03, 0.28, 0.36, 0.88), "响应", "%s · %s" % [
			tile_label(str(offline_pending_claim.get("tile", ""))),
			claim_options_text(offline_pending_claim),
		], human_claim_hint_text(), Color(0.86, 0.78, 0.56))
		draw_advisor_info_card(panel, rect_full(0.38, 0.28, 0.68, 0.88), "牌局", advisor_turn_line(), current_status_text(), Color(0.62, 0.78, 0.82))
		draw_advisor_info_card(panel, rect_full(0.70, 0.28, 0.97, 0.88), "防守", advisor_defense_text(0), opponent_threat_summary(0), Color(0.84, 0.62, 0.54))
		return
	if can_self_discard():
		var reports = current_human_advice if not current_human_advice.is_empty() else get_ai_discard_reports(0)
		if reports.is_empty():
			draw_advisor_info_card(panel, rect_full(0.03, 0.28, 0.36, 0.88), "推荐", "整理手牌", "等待可执行出牌", Color(0.86, 0.78, 0.56))
			draw_advisor_info_card(panel, rect_full(0.38, 0.28, 0.68, 0.88), "收益", score_strategy_text(0), advisor_turn_line(), Color(0.62, 0.78, 0.82))
			draw_advisor_info_card(panel, rect_full(0.70, 0.28, 0.97, 0.88), "防守", advisor_defense_text(0), opponent_threat_summary(0), Color(0.84, 0.62, 0.54))
			return
		var best: Dictionary = reports[0]
		draw_advisor_info_card(panel, rect_full(0.03, 0.28, 0.36, 0.88), "推荐", advisor_primary_text(best), advisor_options_text(reports, 3), Color(0.86, 0.78, 0.56))
		draw_advisor_info_card(panel, rect_full(0.38, 0.28, 0.68, 0.88), "收益", advisor_value_text(best), advisor_shape_text(best), Color(0.62, 0.78, 0.82))
		draw_advisor_info_card(panel, rect_full(0.70, 0.28, 0.97, 0.88), "防守", advisor_defense_text(0, best), opponent_threat_summary(0), Color(0.84, 0.62, 0.54))
		return
	draw_advisor_info_card(panel, rect_full(0.03, 0.28, 0.36, 0.88), "牌局", advisor_turn_line(), current_status_text(), Color(0.86, 0.78, 0.56))
	draw_advisor_info_card(panel, rect_full(0.38, 0.28, 0.68, 0.88), "进程", score_strategy_text(0), "余牌%d" % get_wall_count(), Color(0.62, 0.78, 0.82))
	draw_advisor_info_card(panel, rect_full(0.70, 0.28, 0.97, 0.88), "防守", advisor_defense_text(0), opponent_threat_summary(0), Color(0.84, 0.62, 0.54))

func draw_advisor_info_card(parent: Control, rect: Rect2, heading: String, main_text: String, sub_text: String, accent: Color) -> void:
	var card = make_panel(parent, rect, Color(0.028, 0.048, 0.050, 0.78), 10, accent.darkened(0.28), 0)
	var label = make_label(card, heading, 10, accent, true)
	apply_rect(label, rect_full(0.07, 0.07, 0.93, 0.26))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	configure_clipped_label(label)
	var primary = make_label(card, main_text if main_text != "" else "--", 12, Color(0.86, 0.91, 0.84), true)
	apply_rect(primary, rect_full(0.07, 0.30, 0.93, 0.56))
	primary.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	configure_clipped_label(primary)
	var secondary = make_label(card, sub_text if sub_text != "" else "暂无", 10, Color(0.66, 0.74, 0.70), false)
	apply_rect(secondary, rect_full(0.07, 0.58, 0.93, 0.92))
	secondary.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	secondary.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	secondary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	secondary.clip_text = true

func advisor_context_line() -> String:
	if offline_phase == "pending_claim":
		return "响应窗口 · %s" % advisor_turn_line()
	if can_self_discard():
		return "我方决策 · %s" % advisor_turn_line()
	return "观测中 · %s" % advisor_turn_line()

func advisor_turn_line() -> String:
	if current_seat >= 0 and current_seat < players.size():
		return "%s行牌 · 余牌%d" % [players[current_seat]["name"], get_wall_count()]
	return "余牌%d" % get_wall_count()

func advisor_primary_text(report: Dictionary) -> String:
	return "打%s · %s/%d" % [
		tile_label(str(report.get("tile", ""))),
		shanten_label(int(report.get("shanten", 8))),
		int(report.get("ukeire", 0)),
	]

func advisor_options_text(reports: Array, limit: int = 3) -> String:
	var options: Array[String] = []
	for i in range(min(limit, reports.size())):
		var report: Dictionary = reports[i]
		var reason = str(report.get("reason_label", ""))
		options.append("%s %s/%d%s" % [
			tile_label(str(report.get("tile", ""))),
			shanten_label(int(report.get("shanten", 8))),
			int(report.get("ukeire", 0)),
			" " + reason if reason != "" else "",
		])
	return "备选 " + "  ".join(options) if not options.is_empty() else "暂无备选"

func advisor_value_text(report: Dictionary) -> String:
	var parts: Array[String] = []
	var plan_hint = hand_plan_text(report)
	if plan_hint != "":
		parts.append(plan_hint)
	var tile_hint = effective_tile_text(report, 5)
	if tile_hint != "":
		parts.append(tile_hint)
	var value_hint = wait_value_text(report)
	if value_hint != "":
		parts.append(value_hint)
	return " · ".join(parts) if not parts.is_empty() else "保持牌型"

func advisor_shape_text(report: Dictionary) -> String:
	var parts: Array[String] = []
	var reason_hint = str(report.get("reason_label", ""))
	if reason_hint != "":
		parts.append(reason_hint)
	var shape_hint = str(report.get("shape_label", ""))
	if shape_hint != "":
		parts.append(shape_hint)
	var quality_hint = wait_quality_text(report)
	if quality_hint != "":
		parts.append(quality_hint)
	var score_text = score_strategy_text(0)
	if score_text != "":
		parts.append(score_text)
	return " · ".join(parts)

func advisor_defense_text(seat: int, best: Dictionary = {}) -> String:
	var parts: Array[String] = []
	if not best.is_empty():
		parts.append(discard_safety_text(best))
		var safest_hint = safest_discard_hint_text(best, safest_discard_report())
		if safest_hint != "":
			parts.append(safest_hint)
	var threat = opponent_threat_summary(seat)
	if threat != "":
		parts.append(threat)
	if get_last_discard() != "":
		parts.append("上张 " + tile_label(get_last_discard()))
	return " · ".join(parts) if not parts.is_empty() else "无明显压力"

func advisor_panel_text() -> String:
	if offline_phase == "pending_claim":
		return "响应 %s · %s\n%s" % [
			tile_label(str(offline_pending_claim.get("tile", ""))),
			claim_options_text(offline_pending_claim),
			human_claim_hint_text(),
		]
	if can_self_discard():
		return ai_advice_summary(0, 3)
	if current_seat >= 0 and current_seat < players.size():
		return "%s行牌 · 余牌%d\n上张 %s" % [
			players[current_seat]["name"],
			get_wall_count(),
			tile_label(get_last_discard()) if get_last_discard() != "" else "--",
		]
	return current_status_text()

func draw_round_summary(parent: Control) -> void:
	if mode != "offline" or offline_phase != "ended":
		return
	var panel = make_panel(parent, ROUND_SUMMARY_PANEL_RECT, Color(0.014, 0.034, 0.040, 0.95), 18, Color(0.50, 0.40, 0.24, 0.50))
	make_panel(panel, ROUND_SUMMARY_HEADER_RECT, Color(0.048, 0.060, 0.058, 0.76), 18, Color(1.0, 1.0, 1.0, 0.025))
	var title = make_label(panel, "本局结算" if not is_offline_match_finished() else "全场结算", 24, Color(0.88, 0.80, 0.56), true)
	apply_rect(title, ROUND_SUMMARY_TITLE_RECT)
	var lines: Array[String] = [round_summary]
	var package_lines = active_package_lines()
	if not package_lines.is_empty():
		lines.append("")
		lines.append_array(package_lines)
	var body = make_label(panel, "\n".join(lines), 14, Color(0.76, 0.86, 0.80), false)
	apply_rect(body, ROUND_SUMMARY_TEXT_RECT)
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	body.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	configure_clipped_label(body)
	var rank = 1
	for seat in ranked_seats_by_score():
		draw_round_summary_rank_row(panel, seat, rank)
		rank += 1
	if not is_offline_match_finished():
		var next_dealer = dealer_seat if offline_dealer_repeat else (dealer_seat + 1) % 4
		var next = make_badge(panel, ROUND_SUMMARY_NEXT_DEALER_RECT, "下一局庄家  %s" % players[next_dealer]["name"], 13, Color(0.030, 0.046, 0.048, 0.90), Color(0.46, 0.40, 0.24, 0.36), Color(0.82, 0.86, 0.76))
		next.mouse_filter = Control.MOUSE_FILTER_IGNORE

func draw_round_summary_rank_row(parent: Control, seat: int, rank: int) -> void:
	var top = ROUND_SUMMARY_RANK_START_Y + float(rank - 1) * (ROUND_SUMMARY_RANK_ROW_HEIGHT + ROUND_SUMMARY_RANK_ROW_GAP)
	var row_rect = Rect2(Vector2(0.08, top), Vector2(0.92, top + ROUND_SUMMARY_RANK_ROW_HEIGHT))
	var delta = round_summary_score_delta(seat)
	var accent = round_summary_delta_color(delta, rank)
	var row = make_panel(parent, row_rect, Color(0.016, 0.026, 0.030, 0.92), 11, accent.darkened(0.10), 0)
	row.add_child(make_color_rect(rect_full(0.0, 0.0, 0.026, 1.0), accent))
	var rank_badge = make_badge(row, rect_full(0.045, 0.18, 0.155, 0.82), "第%d" % rank, 12, accent.darkened(0.12), accent.lightened(0.10), Color(0.96, 0.94, 0.84))
	rank_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var name = make_label(row, str(players[seat]["name"]), 14, UI_TEXT_MAIN, true)
	apply_rect(name, rect_full(0.185, 0.12, 0.500, 0.88))
	name.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	configure_clipped_label(name)
	var score = make_label(row, compact_score_text(int(players[seat].get("score", 0))), 14, UI_TEXT_MAIN, true)
	apply_rect(score, rect_full(0.500, 0.12, 0.675, 0.88))
	score.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	configure_clipped_label(score)
	var delta_label = make_label(row, round_summary_delta_text(delta), 13, accent.lightened(0.28), true)
	apply_rect(delta_label, rect_full(0.700, 0.12, 0.835, 0.88))
	delta_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	configure_clipped_label(delta_label)
	var flowers = make_label(row, "花%d" % int(players[seat].get("flowers", 0)), 12, UI_TEXT_MUTED, false)
	apply_rect(flowers, rect_full(0.860, 0.12, 0.970, 0.88))
	flowers.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	configure_clipped_label(flowers)

func round_summary_score_delta(seat: int) -> int:
	if seat < 0 or seat >= last_score_deltas.size():
		return 0
	return int(last_score_deltas[seat])

func round_summary_delta_text(delta: int) -> String:
	if delta > 0:
		return "+%s" % compact_score_text(delta)
	if delta < 0:
		return compact_score_text(delta)
	return "+0"

func round_summary_delta_color(delta: int, rank: int) -> Color:
	if delta > 0:
		return Color(0.30, 0.64, 0.46, 0.92)
	if delta < 0:
		return Color(0.64, 0.34, 0.30, 0.88)
	if rank == 1:
		return Color(0.70, 0.58, 0.28, 0.90)
	return Color(0.34, 0.42, 0.44, 0.84)

func score_delta_text(seat: int) -> String:
	if seat < 0 or seat >= last_score_deltas.size():
		return ""
	var delta = int(last_score_deltas[seat])
	if delta > 0:
		return " +%s" % compact_score_text(delta)
	if delta < 0:
		return " %s" % compact_score_text(delta)
	return " +0"

func compact_score_text(value: int) -> String:
	var sign = "-" if value < 0 else ""
	var amount = abs(value)
	if amount >= 100000:
		return "%s%d万" % [sign, int(round(float(amount) / 10000.0))]
	if amount >= 10000:
		return "%s%.1f万" % [sign, float(amount) / 10000.0]
	return "%s%d" % [sign, amount]

func draw_hand(parent: Control) -> void:
	# 手牌托盘 - 增强视觉效果
	var tray = make_panel(parent, HAND_TRAY_RECT, Color(0.014, 0.022, 0.024, 0.98), 22, Color(0.62, 0.54, 0.34, 0.56), 4)
	# 顶部栏
	make_panel(tray, HAND_TRAY_TOP_RAIL_RECT, Color(0.062, 0.070, 0.058, 0.82), 14, Color(1.0, 0.88, 0.45, 0.20))
	# 分隔线
	make_panel(tray, HAND_TRAY_DIVIDER_RECT, Color(0.010, 0.018, 0.020, 0.36), 12, Color(0.16, 0.18, 0.16, 0.08))

	# 状态文本
	var tray_text = make_label(tray, hand_tray_text(), 14, Color(0.92, 0.86, 0.62), true)
	tray_text.clip_text = true
	apply_rect(tray_text, HAND_TRAY_TEXT_RECT)
	tray_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	configure_clipped_label(tray_text)

	# 状态徽章
	var state_badge = make_badge(tray, HAND_TRAY_STATE_BADGE_RECT, hand_tray_state_text(), 12, hand_tray_state_fill(), hand_tray_state_border(), Color(0.92, 0.92, 0.84))
	state_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var hand = get_self_hand()
	var hand_layout = hand_layout_metrics(hand)
	var hand_box = HBoxContainer.new()
	hand_box.alignment = BoxContainer.ALIGNMENT_CENTER
	configure_passive_container(hand_box)
	hand_box.add_theme_constant_override("separation", int(hand_layout.get("separation", 5)))
	apply_rect(hand_box, HAND_TRAY_TILES_RECT)
	tray.add_child(hand_box)

	var assist_enabled = player_ai_assist_enabled()
	var suggested_tile = suggest_human_discard() if assist_enabled else ""
	var hand_reports = discard_report_map_for_hand() if assist_enabled else {}
	var pending_tile = pending_danger_discard_tile if assist_enabled and has_pending_danger_discard() else ""
	var tile_width = float(hand_layout.get("tile_width", HAND_TILE_MAX_WIDTH))
	var tile_height = float(hand_layout.get("tile_height", tile_width * HAND_TILE_ASPECT))
	var group_gap_width = float(hand_layout.get("group_gap_width", 12.0))
	for i in range(hand.size()):
		var index = i
		var tile = str(hand[i])
		if should_insert_hand_group_gap(hand, i):
			hand_box.add_child(make_hand_group_spacer(tile_height, group_gap_width))
		var clickable = can_self_discard()
		var highlighted = clickable and ((suggested_tile != "" and tile == suggested_tile) or (pending_tile != "" and tile == pending_tile))
		var report: Dictionary = hand_reports.get(tile, {})
		var risk = str(report.get("safety_label", report.get("risk_label", ""))) if assist_enabled and clickable else ""
		var hint_badge = hand_tile_hint_badge(tile, suggested_tile, pending_tile) if assist_enabled and clickable else ""
		var callback = func() -> void:
			if mode == "offline":
				human_discard(index)
			else:
				send_online_action({"type": "discard", "tile": tile}, "打出%s" % tile_label(tile))
		hand_box.add_child(make_tile_view(tile, Vector2(tile_width, tile_height), clickable, callback, highlighted, risk, hint_badge))

func hand_layout_metrics(hand: Array) -> Dictionary:
	return hand_layout_metrics_for_content(hand, hand_content_pixel_size())

func hand_layout_metrics_for_content(hand: Array, content_size: Vector2) -> Dictionary:
	var count = max(1, hand.size())
	var gap_count = hand_group_gap_count(hand)
	var selected_gap = 0.0
	var selected_separation = 1
	var selected_width = 1.0
	for candidate in HAND_LAYOUT_CANDIDATES:
		var gap_width = float(candidate[0])
		var separation = int(candidate[1])
		var candidate_width = hand_tile_width_for_space(content_size, count, gap_count, gap_width, separation)
		selected_gap = gap_width
		selected_separation = separation
		selected_width = candidate_width
		if candidate_width >= HAND_TILE_MIN_TOUCH_WIDTH:
			break
	var tile_width = min(HAND_TILE_MAX_WIDTH, floor(max(1.0, selected_width)))
	var tile_height = floor(tile_width * HAND_TILE_ASPECT)
	return {
		"tile_width": tile_width,
		"tile_height": tile_height,
		"group_gap_width": selected_gap,
		"separation": selected_separation,
		"content_width": content_size.x,
		"content_height": content_size.y,
	}

func hand_tile_width_for_space(content_size: Vector2, tile_count: int, gap_count: int, gap_width: float, separation: int) -> float:
	var gaps_width = float(max(0, gap_count)) * gap_width
	var separations_width = float(max(0, tile_count - 1)) * float(max(0, separation))
	var width_by_space = (content_size.x - gaps_width - separations_width) / float(max(1, tile_count))
	var width_by_height = content_size.y / HAND_TILE_ASPECT
	return min(width_by_space, width_by_height)

func hand_group_gap_count(hand: Array) -> int:
	var count = 0
	for i in range(1, hand.size()):
		if should_insert_hand_group_gap(hand, i):
			count += 1
	return count

func hand_content_pixel_size() -> Vector2:
	var content_size = safe_content_pixel_size()
	return Vector2(content_size.x * 0.810 * 0.970, content_size.y * 0.220 * 0.810)

func hand_layout_required_width(hand: Array, metrics: Dictionary) -> float:
	var tile_count = hand.size()
	var gap_count = hand_group_gap_count(hand)
	return float(tile_count) * float(metrics.get("tile_width", 0.0)) + float(gap_count) * float(metrics.get("group_gap_width", 0.0)) + float(max(0, tile_count - 1)) * float(metrics.get("separation", 0))

func hand_layout_fits_content(hand: Array, metrics: Dictionary) -> bool:
	return hand_layout_required_width(hand, metrics) <= float(metrics.get("content_width", hand_content_pixel_size().x)) + 0.5

func hand_tile_hint_badge(tile: String, suggested_tile: String, pending_tile: String) -> String:
	if pending_tile != "" and tile == pending_tile:
		return "确认"
	if suggested_tile != "" and tile == suggested_tile:
		return "荐"
	return ""

func should_insert_hand_group_gap(hand: Array, index: int) -> bool:
	if index <= 0 or index >= hand.size():
		return false
	return hand_group_index(str(hand[index - 1])) != hand_group_index(str(hand[index]))

func hand_group_index(tile: String) -> int:
	var index = tile_index(tile)
	if index >= 0 and index < 27:
		return int(index / 9)
	if index >= 27:
		return 3
	if is_flower_tile(tile):
		return 4
	return 5

func make_hand_group_spacer(height: float, width: float = 12.0) -> Control:
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(width, height)
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var line = ColorRect.new()
	line.color = Color(1.0, 0.78, 0.30, 0.38)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(line, rect_full(0.44, 0.12, 0.56, 0.88))
	spacer.add_child(line)
	return spacer

func discard_report_map_for_hand() -> Dictionary:
	if not player_ai_assist_enabled() or mode != "offline" or not can_self_discard():
		return {}
	var reports = current_human_advice if not current_human_advice.is_empty() else get_ai_discard_reports(0)
	var result: Dictionary = {}
	for report in reports:
		if typeof(report) == TYPE_DICTIONARY:
			result[str(report.get("tile", ""))] = report
	return result

func hand_tray_text() -> String:
	if not player_ai_assist_enabled():
		return current_status_text()
	if has_pending_danger_discard():
		return pending_danger_discard_text()
	if mode == "offline" and offline_phase == "pending_claim":
		return human_claim_hint_text()
	if mode == "offline" and can_self_discard():
		var reports = current_human_advice if not current_human_advice.is_empty() else get_ai_discard_reports(0)
		if not reports.is_empty():
			var best: Dictionary = reports[0]
			var safest = safest_discard_report()
			return compact_hand_tray_summary(best, safest)
	return current_status_text()

func compact_hand_tray_summary(best: Dictionary, safest: Dictionary = {}) -> String:
	if best.is_empty():
		return current_status_text()
	var parts: Array[String] = []
	parts.append("荐%s" % tile_label(str(best.get("tile", ""))))
	parts.append(shanten_label(int(best.get("shanten", 8))))
	var reason = str(best.get("reason_label", ""))
	if reason != "":
		parts.append(reason)
	var plan = hand_plan_text(best)
	if plan != "":
		parts.append(plan)
	parts.append("进%d/%d" % [int(best.get("ukeire", 0)), int(best.get("variety", 0))])
	var wait = effective_tile_text(best, 2)
	if wait != "":
		parts.append(wait)
	var safety = discard_safety_short_text(best)
	if safety != "":
		parts.append(safety)
	parts.append(str(best.get("stance", "均衡")))
	var safe_hint = safest_discard_hint_text(best, safest)
	if safe_hint != "":
		parts.append(safe_hint)
	return " · ".join(parts)

func hand_tray_state_text() -> String:
	if mode == "offline":
		if offline_phase == "ended":
			return "结算"
		if offline_phase == "pending_claim":
			return "响应"
		if can_self_discard():
			return "出牌"
		return "等待"
	if mode == "online_game":
		var pending = online_game.get("pending", null)
		if typeof(pending) == TYPE_DICTIONARY and pending.get("options", []).size() > 0:
			return "响应"
		return "出牌" if can_self_discard() else "等待"
	return "准备"

func hand_tray_state_fill() -> Color:
	match hand_tray_state_text():
		"出牌":
			return Color(0.20, 0.48, 0.42, 0.94)
		"响应":
			return Color(0.62, 0.38, 0.22, 0.94)
		"结算":
			return Color(0.42, 0.32, 0.54, 0.94)
		"等待":
			return Color(0.24, 0.30, 0.34, 0.92)
	return Color(0.26, 0.34, 0.42, 0.92)

func hand_tray_state_border() -> Color:
	var fill = hand_tray_state_fill()
	return Color(fill.r + 0.18, fill.g + 0.16, fill.b + 0.12, 0.42)

func draw_actions(parent: Control) -> void:
	action_bar = HBoxContainer.new()
	action_bar.alignment = BoxContainer.ALIGNMENT_END
	configure_passive_container(action_bar)
	action_bar.add_theme_constant_override("separation", 6)
	apply_rect(action_bar, ACTION_BAR_RECT)
	parent.add_child(action_bar)
	if mode == "offline":
		if offline_phase == "ended":
			if not is_offline_match_finished():
				action_bar.add_child(make_action_button("下一局", Color(0.32, 0.72, 0.60), func() -> void:
					start_next_offline_hand()
				))
			action_bar.add_child(make_action_button("新赛", Color(0.86, 0.42, 0.32), func() -> void:
				start_offline()
			))
			action_bar.add_child(make_action_button("菜单", Color(0.48, 0.54, 0.56), func() -> void:
				show_menu()
			))
			draw_action_dock(parent)
			finalize_action_bar_layout()
			return
		if offline_phase == "pending_claim":
			var claim_recommendation = recommended_claim_report() if player_ai_assist_enabled() else {}
			for claim in offline_pending_claim.get("options", []):
				var claim_name = str(claim)
				if claim_name == "chi":
					var chi_choices: Array = offline_pending_claim.get("chi_choices", [])
					if chi_choices.is_empty():
						var is_recommended_claim = is_recommended_claim_action(claim_name, {}, claim_recommendation)
						action_bar.add_child(make_action_button(claim_action_button_text(claim_name, {}, claim_recommendation), claim_action_button_color(claim_name, is_recommended_claim), func() -> void:
							human_claim(claim_name)
						))
					else:
						for choice in chi_choices:
							var selected_choice: Dictionary = choice
							var is_recommended_choice = is_recommended_claim_action(claim_name, selected_choice, claim_recommendation)
							action_bar.add_child(make_action_button(claim_action_button_text(claim_name, selected_choice, claim_recommendation), claim_action_button_color(claim_name, is_recommended_choice), func() -> void:
								human_claim("chi", selected_choice)
							))
				else:
					var is_recommended_claim = is_recommended_claim_action(claim_name, {}, claim_recommendation)
					action_bar.add_child(make_action_button(claim_action_button_text(claim_name, {}, claim_recommendation), claim_action_button_color(claim_name, is_recommended_claim), func() -> void:
						human_claim(claim_name)
					))
			action_bar.add_child(make_action_button(pass_claim_button_text(claim_recommendation), pass_claim_button_color(claim_recommendation), func() -> void:
				human_claim("pass")
			))
			draw_action_dock(parent)
			finalize_action_bar_layout()
			return
		if can_self_discard() and can_win_for_seat(0):
			action_bar.add_child(make_action_button("自摸", Color(0.94, 0.42, 0.32), func() -> void:
				human_self_win()
			))
		var gang_tile = first_concealed_gang_tile(0)
		if can_self_discard() and gang_tile != "":
			action_bar.add_child(make_action_button("暗杠", Color(0.62, 0.54, 0.88), func() -> void:
				human_concealed_gang(gang_tile)
			))
		var added_gang_tile = first_added_gang_tile(0)
		if can_self_discard() and added_gang_tile != "":
			action_bar.add_child(make_action_button("补杠", Color(0.66, 0.58, 0.92), func() -> void:
				human_added_gang(added_gang_tile)
			))
		if player_ai_assist_enabled() and can_self_discard() and not has_pending_danger_discard():
			var recommended_report = recommended_discard_report()
			var recommended_tile = str(recommended_report.get("tile", ""))
			var safest_report = safest_discard_report()
			var safest_tile = str(safest_report.get("tile", ""))
			var offer_safest = should_offer_safest_discard_button(recommended_report, safest_report)
			var excluded_action_tiles: Array[String] = []
			if recommended_tile != "":
				var selected_recommended_tile = recommended_tile
				excluded_action_tiles.append(selected_recommended_tile)
				if offer_safest and safest_tile != "" and safest_tile != recommended_tile:
					var selected_safest_tile = safest_tile
					excluded_action_tiles.append(selected_safest_tile)
					action_bar.add_child(make_action_button(safest_discard_button_text(safest_report), safe_discard_button_color(safest_report), func() -> void:
						human_discard_by_tile(selected_safest_tile)
					))
				var recommended_button_text = safest_discard_button_text(recommended_report) if offer_safest and safest_tile == recommended_tile else recommended_discard_button_text(selected_recommended_tile)
				action_bar.add_child(make_action_button(recommended_button_text, recommended_discard_button_color(recommended_report), func() -> void:
					human_discard_by_tile(selected_recommended_tile)
				))
				var alternative_limit = 1 if offer_safest and safest_tile != "" and safest_tile != recommended_tile else 2
				for report in discard_action_alternative_reports(excluded_action_tiles, alternative_limit):
					var alternative_tile = str(report.get("tile", ""))
					if alternative_tile == "":
						continue
					var selected_action_tile = alternative_tile
					action_bar.add_child(make_action_button(alternative_discard_button_text(report), alternative_discard_button_color(report), func() -> void:
						human_discard_by_tile(selected_action_tile)
					))
		if player_ai_assist_enabled() and has_pending_danger_discard():
			for report in safe_discard_alternative_reports(pending_danger_discard_tile, 2):
				var alternative_tile = str(report.get("tile", ""))
				if alternative_tile == "":
					continue
				var selected_alternative_tile = alternative_tile
				action_bar.add_child(make_action_button("改打%s" % tile_label(selected_alternative_tile), safe_discard_button_color(report), func() -> void:
					human_discard_by_tile(selected_alternative_tile)
				))
			action_bar.add_child(make_action_button("取消", Color(0.52, 0.56, 0.58), func() -> void:
				clear_pending_danger_discard()
				set_status(current_status_text())
				render_game()
			))
		action_bar.add_child(make_action_button("重开", Color(0.70, 0.32, 0.22), func() -> void:
			start_offline()
		))
		if player_ai_assist_enabled():
			action_bar.add_child(make_action_button("提示", Color(0.25, 0.58, 0.48), func() -> void:
				set_status(human_hint_text())
			))
	if mode == "online_game":
		var pending = online_game.get("pending", null)
		if typeof(pending) == TYPE_DICTIONARY:
			for claim in pending.get("options", []):
				var claim_name = str(claim)
				if claim_name == "chi":
					var chi_choices: Array = pending.get("chi_choices", [])
					if chi_choices.is_empty():
						action_bar.add_child(make_action_button(claim_label(claim_name), claim_color(claim_name), func() -> void:
							send_online_action(online_claim_payload(claim_name), claim_label(claim_name))
						))
					else:
						for choice in chi_choices:
							var selected_choice: Dictionary = choice
							action_bar.add_child(make_action_button(chi_choice_label(selected_choice), claim_color(claim_name), func() -> void:
								send_online_action(online_claim_payload("chi", selected_choice), chi_choice_label(selected_choice))
							))
				else:
					action_bar.add_child(make_action_button(claim_label(claim_name), claim_color(claim_name), func() -> void:
						send_online_action(online_claim_payload(claim_name), claim_label(claim_name))
					))
			if pending.get("options", []).size() > 0:
				action_bar.add_child(make_action_button("过", Color(0.38, 0.43, 0.44), func() -> void:
					send_online_action(online_claim_payload("pass"), "过")
				))
	var voice = make_action_button("闭麦" if voice_enabled else "语音", Color(0.74, 0.24, 0.24) if voice_enabled else Color(0.24, 0.52, 0.72), func() -> void:
		toggle_voice_chat()
	)
	action_bar.add_child(voice)
	draw_action_dock(parent)
	finalize_action_bar_layout()

func draw_action_dock(parent: Control) -> void:
	var count = action_bar_button_count()
	if count <= 0:
		return
	var dock = make_panel(parent, action_dock_rect_for_count(count), Color(0.014, 0.021, 0.024, 0.76), 16, Color(0.46, 0.40, 0.24, 0.24), 2)
	parent.move_child(dock, max(0, action_bar.get_index()))

func action_dock_rect_for_count(count: int) -> Rect2:
	var content_width = max(1.0, safe_content_pixel_size().x)
	var separation = action_button_separation_for_count(count)
	var width = action_button_width_for_count(count, separation)
	var dock_pixels = float(count) * width + float(max(0, count - 1) * separation) + 36.0
	var left = max(ACTION_BAR_DOCK_RECT.position.x, ACTION_BAR_RECT.size.x - dock_pixels / content_width)
	return Rect2(Vector2(left, ACTION_BAR_DOCK_RECT.position.y), ACTION_BAR_DOCK_RECT.size)

func finalize_action_bar_layout() -> void:
	if action_bar == null:
		return
	var count = action_bar_button_count()
	if count <= 0:
		return
	var separation = action_button_separation_for_count(count)
	action_bar.add_theme_constant_override("separation", separation)
	var width = action_button_width_for_count(count, separation)
	var font_size = action_button_font_size(width)
	var height = ACTION_BUTTON_HEIGHT if width >= ACTION_BUTTON_MIN_TOUCH_WIDTH else 48.0
	for child in action_bar.get_children():
		if child is Button:
			configure_action_button_size(child as Button, width, height, font_size)

func action_bar_button_count() -> int:
	if action_bar == null:
		return 0
	var count = 0
	for child in action_bar.get_children():
		if child is Button:
			count += 1
	return count

func action_bar_buttons() -> Array[Button]:
	var buttons: Array[Button] = []
	if action_bar == null:
		return buttons
	for child in action_bar.get_children():
		if child is Button:
			buttons.append(child as Button)
	return buttons

func action_bar_pixel_width() -> float:
	return safe_content_pixel_size().x * (ACTION_BAR_RECT.size.x - ACTION_BAR_RECT.position.x)

func action_button_separation_for_count(count: int) -> int:
	if count <= 5:
		return 6
	if count <= 8:
		return 4
	return 2

func action_button_width_for_count(count: int, separation: int = -1) -> float:
	return action_button_width_for_available(count, action_bar_pixel_width(), separation)

func action_button_width_for_available(count: int, available_width: float, separation: int = -1) -> float:
	if count <= 0:
		return ACTION_BUTTON_MAX_WIDTH
	var gap = action_button_separation_for_count(count) if separation < 0 else separation
	var available = available_width - float(max(0, count - 1) * gap)
	return min(ACTION_BUTTON_MAX_WIDTH, floor(max(1.0, available / float(count))))

func action_button_font_size(width: float) -> int:
	if width >= 78.0:
		return 18
	if width >= 68.0:
		return 16
	return 14

func action_buttons_fit_width(count: int) -> bool:
	return action_buttons_fit_available(count, action_bar_pixel_width())

func action_buttons_fit_available(count: int, available_width: float) -> bool:
	var separation = action_button_separation_for_count(count)
	var width = action_button_width_for_available(count, available_width, separation)
	var required = float(count) * width + float(max(0, count - 1) * separation)
	return required <= available_width + 0.5

func setup_update_downloader() -> void:
	update_request = HTTPRequest.new()
	update_request.use_threads = true
	update_request.timeout = 180.0
	update_request.request_completed.connect(_on_update_request_completed)
	add_child(update_request)

func start_update_download() -> void:
	if update_state == "checking":
		update_message = "正在检查更新 manifest..."
		ensure_update_dialog()
		refresh_update_dialog()
		return
	if update_state == "downloading":
		update_message = "升级包正在下载中。"
		ensure_update_dialog()
		refresh_update_dialog()
		return
	update_downloaded_bytes = 0
	update_total_bytes = 0
	update_download_url = UPDATE_URL
	update_remote_version = app_version()
	update_release_notes = ""
	update_remote_sha256 = ""
	update_remote_size = 0
	update_file_path = UPDATE_FILE_PATH
	next_update_progress_msec = 0
	update_state = "checking"
	update_request_mode = "manifest"
	update_message = "正在检查更新 manifest..."
	update_request.download_file = ""
	ensure_update_dialog()
	refresh_update_dialog()
	var err = update_request.request(UPDATE_MANIFEST_URL)
	if err != OK:
		begin_update_download(UPDATE_URL, app_version(), "manifest 请求失败，使用备用下载。")
	set_status(update_message)

func begin_update_download(url: String, version: String, notes: String = "") -> void:
	var dir_error = DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://updates"))
	if dir_error != OK:
		update_state = "error"
		update_request_mode = "idle"
		update_message = "创建下载目录失败：%s" % error_string(dir_error)
		ensure_update_dialog()
		refresh_update_dialog()
		return
	update_download_url = url if url.strip_edges() != "" else UPDATE_URL
	update_remote_version = version if version.strip_edges() != "" else app_version()
	update_release_notes = notes
	update_file_path = "user://updates/YunzhuoMahjongGodot-v%s.apk" % safe_filename_part(update_remote_version)
	if FileAccess.file_exists(update_file_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(update_file_path))
	update_downloaded_bytes = 0
	update_total_bytes = 0
	next_update_progress_msec = 0
	update_state = "downloading"
	update_request_mode = "download"
	update_message = "正在下载 v%s 升级包..." % update_remote_version
	update_request.download_file = update_file_path
	ensure_update_dialog()
	refresh_update_dialog()
	var err = update_request.request(update_download_url)
	if err != OK:
		update_request.download_file = ""
		update_request_mode = "idle"
		update_state = "error"
		update_message = "开始下载失败：%s" % error_string(err)
		refresh_update_dialog()
	set_status(update_message)

func update_download_progress(now_msec: int = -1) -> void:
	if update_state != "downloading" or update_request == null:
		return
	if now_msec >= 0 and now_msec < next_update_progress_msec:
		return
	update_downloaded_bytes = update_request.get_downloaded_bytes()
	update_total_bytes = update_request.get_body_size()
	if now_msec >= 0:
		next_update_progress_msec = now_msec + UPDATE_PROGRESS_INTERVAL_MSEC
	refresh_update_dialog()

func _on_update_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if update_request_mode == "manifest":
		handle_update_manifest_completed(result, response_code, body)
		return
	update_downloaded_bytes = update_request.get_downloaded_bytes()
	update_total_bytes = update_request.get_body_size()
	update_request.download_file = ""
	update_request_mode = "idle"
	if result == HTTPRequest.RESULT_SUCCESS and response_code >= 200 and response_code < 300 and FileAccess.file_exists(update_file_path):
		if verify_downloaded_update():
			update_state = "ready"
			update_message = "v%s 升级包下载完成。" % update_remote_version
	else:
		update_state = "error"
		if response_code > 0:
			update_message = "下载失败：HTTP %d，结果码 %d。" % [response_code, result]
		else:
			update_message = "下载失败：结果码 %d。" % result
		if FileAccess.file_exists(update_file_path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(update_file_path))
	refresh_update_dialog()
	set_status(update_message)

func verify_downloaded_update() -> bool:
	if update_remote_sha256.strip_edges() == "":
		return true
	var expected = update_remote_sha256.strip_edges().to_lower()
	if not is_valid_sha256(expected):
		update_state = "error"
		update_message = "manifest SHA-256 格式无效。"
		remove_downloaded_update_file()
		return false
	var actual = file_sha256(update_file_path)
	if actual == "":
		update_state = "error"
		update_message = "无法读取下载包校验 SHA-256。"
		remove_downloaded_update_file()
		return false
	if actual != expected:
		update_state = "error"
		update_message = "下载包 SHA-256 不匹配，已删除。"
		remove_downloaded_update_file()
		return false
	return true

func remove_downloaded_update_file() -> void:
	if FileAccess.file_exists(update_file_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(update_file_path))

func is_valid_sha256(value: String) -> bool:
	if value.length() != 64:
		return false
	for i in range(value.length()):
		var ch = value.substr(i, 1)
		var is_digit = ch >= "0" and ch <= "9"
		var is_hex = ch >= "a" and ch <= "f"
		if not is_digit and not is_hex:
			return false
	return true

func file_sha256(path: String) -> String:
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	var context = HashingContext.new()
	var err = context.start(HashingContext.HASH_SHA256)
	if err != OK:
		return ""
	while not file.eof_reached():
		var chunk = file.get_buffer(65536)
		if not chunk.is_empty():
			context.update(chunk)
	return context.finish().hex_encode()

func handle_update_manifest_completed(result: int, response_code: int, body: PackedByteArray) -> void:
	update_request_mode = "idle"
	if result != HTTPRequest.RESULT_SUCCESS or response_code < 200 or response_code >= 300:
		begin_update_download(UPDATE_URL, app_version(), "manifest 暂不可用，使用备用下载。")
		return
	var parsed = JSON.parse_string(body.get_string_from_utf8())
	if typeof(parsed) != TYPE_DICTIONARY:
		begin_update_download(UPDATE_URL, app_version(), "manifest 解析失败，使用备用下载。")
		return
	var manifest = parse_update_manifest(parsed)
	if manifest.is_empty():
		begin_update_download(UPDATE_URL, app_version(), "manifest 缺少下载地址，使用备用下载。")
		return
	var remote_version = str(manifest.get("version", app_version()))
	update_remote_sha256 = str(manifest.get("sha256", ""))
	update_remote_size = int(manifest.get("size", 0))
	if not is_newer_version(remote_version, app_version()):
		update_state = "current"
		update_download_url = str(manifest.get("url", UPDATE_URL))
		update_remote_version = remote_version
		update_release_notes = str(manifest.get("notes", ""))
		update_message = "当前已是最新版本 v%s。" % app_version()
		refresh_update_dialog()
		set_status(update_message)
		return
	begin_update_download(str(manifest.get("url", UPDATE_URL)), remote_version, str(manifest.get("notes", "")))

func ensure_update_dialog() -> void:
	if update_state == "idle" or root_layer == null:
		return
	if update_dialog != null and is_instance_valid(update_dialog):
		refresh_update_dialog()
		return
	update_dialog = Control.new()
	update_dialog.set_anchors_preset(Control.PRESET_FULL_RECT)
	update_dialog.mouse_filter = Control.MOUSE_FILTER_STOP
	root_layer.add_child(update_dialog)

	var dim = ColorRect.new()
	dim.color = Color(0.0, 0.0, 0.0, 0.40)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	update_dialog.add_child(dim)

	var panel = make_panel(update_dialog, rect_full(0.325, 0.275, 0.675, 0.640), Color(0.016, 0.050, 0.058, 0.98), 18, Color(0.66, 0.54, 0.24, 0.62))
	var title = make_label(panel, "游戏更新", 22, Color(0.90, 0.82, 0.46), true)
	apply_rect(title, rect_full(0.06, 0.06, 0.94, 0.22))
	update_status_label = make_label(panel, "", 18, Color(0.84, 1.0, 0.90), false)
	apply_rect(update_status_label, rect_full(0.08, 0.25, 0.92, 0.42))
	update_progress = ProgressBar.new()
	update_progress.min_value = 0.0
	update_progress.max_value = 100.0
	update_progress.value = 0.0
	update_progress.show_percentage = false
	update_progress.mouse_filter = Control.MOUSE_FILTER_IGNORE
	update_progress.add_theme_stylebox_override("background", style(Color(0.014, 0.034, 0.038, 0.92), 10, Color(0.22, 0.30, 0.30, 0.52), 1))
	update_progress.add_theme_stylebox_override("fill", style(Color(0.16, 0.48, 0.36, 0.96), 10, Color(0.54, 0.76, 0.60, 0.34), 1))
	panel.add_child(update_progress)
	apply_rect(update_progress, rect_full(0.08, 0.45, 0.92, 0.55))
	update_progress_label = make_label(panel, "", 15, Color(0.88, 0.90, 0.78), false)
	update_progress_label.clip_contents = true
	apply_rect(update_progress_label, rect_full(0.08, 0.57, 0.92, 0.72))

	var row = HBoxContainer.new()
	configure_passive_container(row)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	panel.add_child(row)
	apply_rect(row, rect_full(0.08, 0.76, 0.92, 0.94))
	update_primary_button = make_small_button("安装", Color(0.18, 0.42, 0.34), func() -> void:
		on_update_primary_pressed()
	)
	row.add_child(update_primary_button)
	update_secondary_button = make_small_button("关闭", Color(0.26, 0.30, 0.34), func() -> void:
		on_update_secondary_pressed()
	)
	row.add_child(update_secondary_button)
	refresh_update_dialog()

func refresh_update_dialog() -> void:
	if update_state == "idle":
		if update_dialog != null and is_instance_valid(update_dialog):
			update_dialog.queue_free()
		return
	if update_status_label == null or not is_instance_valid(update_status_label):
		return
	update_status_label.text = update_message
	if update_progress != null and is_instance_valid(update_progress):
		if update_total_bytes > 0:
			update_progress.value = clamp(float(update_downloaded_bytes) * 100.0 / float(update_total_bytes), 0.0, 100.0)
		elif update_state == "ready":
			update_progress.value = 100.0
		else:
			update_progress.value = 0.0
	if update_progress_label != null and is_instance_valid(update_progress_label):
		update_progress_label.text = update_progress_text()
	if update_primary_button != null and is_instance_valid(update_primary_button):
		update_primary_button.visible = update_state != "checking" and update_state != "downloading" and update_state != "current"
		update_primary_button.text = "安装" if update_state == "ready" else "重试"
	if update_secondary_button != null and is_instance_valid(update_secondary_button):
		update_secondary_button.text = "取消" if update_state == "checking" or update_state == "downloading" else "关闭"

func update_progress_text() -> String:
	if update_state == "checking":
		return "manifest " + UPDATE_MANIFEST_URL
	if update_state == "downloading":
		if update_total_bytes > 0:
			var percent = int(round(float(update_downloaded_bytes) * 100.0 / float(update_total_bytes)))
			return "%s / %s  %d%%" % [format_bytes(update_downloaded_bytes), format_bytes(update_total_bytes), percent]
		return "已下载 %s\n%s" % [format_bytes(update_downloaded_bytes), update_download_url]
	if update_state == "ready":
		return "已保存 v%s 升级包%s%s" % [update_remote_version, update_manifest_detail_text(), update_release_notes_summary()]
	if update_state == "current":
		return "远端版本 v%s%s%s" % [update_remote_version, update_manifest_detail_text(), update_release_notes_summary()]
	if update_state == "error":
		return "下载地址 " + update_download_url
	return ""

func update_manifest_detail_text() -> String:
	var parts: Array[String] = []
	if update_remote_size > 0:
		parts.append(format_bytes(update_remote_size))
	if update_remote_sha256 != "":
		parts.append("SHA-256 " + update_remote_sha256.substr(0, 12))
	if parts.is_empty():
		return ""
	return "\n" + "  ".join(parts)

func update_release_notes_summary() -> String:
	var first_line = ""
	var count = 0
	for raw_line in update_release_notes.split("\n", false):
		var line = str(raw_line).strip_edges()
		if line == "":
			continue
		count += 1
		if first_line == "":
			first_line = line
	if count <= 0:
		return ""
	if first_line.length() > UPDATE_NOTES_PREVIEW_CHARS:
		first_line = first_line.substr(0, UPDATE_NOTES_PREVIEW_CHARS).strip_edges() + "..."
	var suffix = " 等%d项" % count if count > 1 else ""
	return "\n更新说明: %s%s" % [first_line, suffix]

func on_update_primary_pressed() -> void:
	if update_state == "ready":
		open_downloaded_update()
	else:
		start_update_download()

func on_update_secondary_pressed() -> void:
	if update_state == "checking" or update_state == "downloading":
		update_request.cancel_request()
		update_request.download_file = ""
		update_request_mode = "idle"
		update_state = "error"
		update_message = "已取消更新。"
		if FileAccess.file_exists(update_file_path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(update_file_path))
		refresh_update_dialog()
		set_status(update_message)
	else:
		update_state = "idle"
		update_message = ""
		refresh_update_dialog()

func open_downloaded_update() -> void:
	if not FileAccess.file_exists(update_file_path):
		update_state = "error"
		update_message = "安装包不存在，请重新下载。"
		refresh_update_dialog()
		return
	var absolute_path = ProjectSettings.globalize_path(update_file_path)
	var err = OS.shell_open(absolute_path)
	if err != OK:
		err = OS.shell_open("file://" + absolute_path)
	if err == OK:
		update_message = "已请求系统打开安装包。"
	else:
		update_state = "error"
		update_message = "无法打开安装包：%s" % error_string(err)
	refresh_update_dialog()
	set_status(update_message)

func format_bytes(value: int) -> String:
	if value < 0:
		return "未知大小"
	var amount = float(value)
	var units = ["B", "KB", "MB", "GB"]
	var unit_index = 0
	while amount >= 1024.0 and unit_index < units.size() - 1:
		amount /= 1024.0
		unit_index += 1
	if unit_index == 0:
		return "%d %s" % [int(amount), units[unit_index]]
	return "%.1f %s" % [amount, units[unit_index]]

func app_version() -> String:
	return str(ProjectSettings.get_setting("application/config/version", APP_VERSION))

func parse_update_manifest(data: Dictionary) -> Dictionary:
	var source: Dictionary = data
	if data.has("android") and typeof(data["android"]) == TYPE_DICTIONARY:
		source = data["android"]
	var version = str(source.get("version", data.get("version", ""))).strip_edges()
	var url = str(source.get("apkUrl", source.get("apk_url", source.get("downloadUrl", source.get("url", ""))))).strip_edges()
	var notes_value = source.get("releaseNotes", source.get("notes", data.get("releaseNotes", data.get("notes", ""))))
	var notes = manifest_notes_to_text(notes_value)
	var sha256 = str(source.get("sha256", data.get("sha256", ""))).strip_edges()
	var size = int(source.get("apkSize", source.get("size", data.get("apkSize", data.get("size", 0)))))
	if url == "":
		return {}
	if version == "":
		version = app_version()
	return {
		"version": version,
		"url": url,
		"notes": notes,
		"sha256": sha256,
		"size": size,
	}

func manifest_notes_to_text(value) -> String:
	if typeof(value) == TYPE_ARRAY:
		var lines: Array[String] = []
		for item in value:
			lines.append(str(item))
		return "\n".join(lines)
	return str(value)

func is_newer_version(remote: String, current: String) -> bool:
	var remote_numbers = version_numbers(remote)
	var current_numbers = version_numbers(current)
	var count = max(remote_numbers.size(), current_numbers.size())
	for i in range(count):
		var remote_part = int(remote_numbers[i]) if i < remote_numbers.size() else 0
		var current_part = int(current_numbers[i]) if i < current_numbers.size() else 0
		if remote_part > current_part:
			return true
		if remote_part < current_part:
			return false
	return false

func version_numbers(version: String) -> Array:
	var numbers: Array = []
	var current = ""
	for i in range(version.length()):
		var ch = version.substr(i, 1)
		if ch >= "0" and ch <= "9":
			current += ch
		elif current != "":
			numbers.append(int(current))
			current = ""
	if current != "":
		numbers.append(int(current))
	if numbers.is_empty():
		numbers.append(0)
	return numbers

func safe_filename_part(text: String) -> String:
	var result = ""
	for i in range(text.length()):
		var ch = text.substr(i, 1)
		if (ch >= "0" and ch <= "9") or (ch >= "A" and ch <= "Z") or (ch >= "a" and ch <= "z") or ch == "." or ch == "-" or ch == "_":
			result += ch
		else:
			result += "_"
	return result if result != "" else app_version()

func human_discard(index: int) -> void:
	if not can_self_discard():
		return
	var hand: Array = players[0]["hand"]
	if index < 0 or index >= hand.size():
		return
	var tile = str(hand[index])
	var report = discard_report_for_tile(tile)
	if should_confirm_danger_discard(index, tile, report):
		begin_danger_discard_confirmation(index, tile, report)
		render_game()
		return
	clear_pending_danger_discard()
	tile = discard_tile_by_index(0, index)
	render_game()
	await get_tree().process_frame
	if mode != "offline" or offline_phase != "resolving" or last_discard_seat != 0 or last_discard != tile:
		return
	resolve_after_discard(0, tile)
	if mode == "offline" and offline_phase == "await_discard" and current_seat != 0:
		run_ai_until_human()

func human_discard_by_tile(tile: String) -> void:
	if not can_self_discard() or tile == "":
		return
	var index = find_tile_in_hand(players[0]["hand"], tile)
	if index < 0:
		set_status("手牌中没有%s。" % tile_label(tile))
		return
	var report = discard_report_for_tile(tile)
	if not is_high_risk_discard_report(report):
		clear_pending_danger_discard()
	human_discard(index)

func human_claim(claim: String, chi_choice: Dictionary = {}) -> void:
	if mode != "offline" or offline_phase != "pending_claim":
		return
	clear_pending_danger_discard()
	var from_seat = int(offline_pending_claim.get("from_seat", -1))
	var tile = str(offline_pending_claim.get("tile", ""))
	if from_seat < 0 or tile == "":
		return
	if claim == "pass":
		add_log("你选择过。")
		var was_rob_gang = bool(offline_pending_claim.get("rob_gang", false))
		var prepared_ai_claim: Dictionary = offline_pending_claim.get("ai_claim", {})
		offline_pending_claim.clear()
		if was_rob_gang:
			resolve_after_rob_gang_pass(from_seat, tile, prepared_ai_claim)
		else:
			resolve_ai_or_advance(from_seat, tile)
		if offline_phase == "await_discard":
			run_ai_until_human()
		return
	var options: Array = offline_pending_claim.get("options", [])
	if not options.has(claim):
		return
	if claim == "chi" and not chi_choice.is_empty() and not is_valid_pending_chi_choice(chi_choice):
		return
	var was_rob_gang = bool(offline_pending_claim.get("rob_gang", false))
	offline_pending_claim.clear()
	if was_rob_gang and claim == "hu":
		finish_offline_round(0, tile, false, from_seat, "rob_gang")
	else:
		apply_offline_claim(0, from_seat, tile, claim, chi_choice)
	render_game()

func human_self_win() -> void:
	if mode != "offline" or not can_self_discard() or not can_win_for_seat(0):
		return
	finish_offline_round(0, str(players[0]["hand"].back()), true, -1)

func human_concealed_gang(tile: String) -> void:
	if mode != "offline" or not can_self_discard():
		return
	if count_tile(players[0]["hand"], tile) < 4:
		return
	clear_pending_danger_discard()
	perform_concealed_gang(0, tile)
	render_game()

func human_added_gang(tile: String) -> void:
	if mode != "offline" or not can_self_discard():
		return
	if not can_added_gang(0, tile):
		return
	clear_pending_danger_discard()
	perform_added_gang(0, tile)
	render_game()

func run_ai_until_human() -> void:
	if offline_ai_active:
		return
	offline_ai_active = true
	if last_discard_seat == 0:
		await pace_after_human_discard_response()
	while mode == "offline" and offline_phase == "await_discard" and current_seat != 0:
		var seat = current_seat
		if offline_turn_needs_draw:
			if wall.is_empty():
				finish_wall_draw()
				break
			await get_tree().create_timer(ai_draw_delay()).timeout
			if mode != "offline" or offline_phase != "await_discard" or current_seat != seat:
				break
			var drawn = draw_tile_for(seat)
			sort_hand(players[seat]["hand"])
			offline_turn_needs_draw = false
			if can_win_for_seat(seat):
				finish_offline_round(seat, drawn, true, -1)
				break
			var gang_tile = choose_ai_concealed_gang(seat)
			var ai_declared_gang = false
			if gang_tile != "":
				perform_concealed_gang(seat, gang_tile)
				ai_declared_gang = true
				if offline_phase == "ended":
					break
			else:
				gang_tile = choose_ai_added_gang(seat)
				if gang_tile != "":
					perform_added_gang(seat, gang_tile)
					ai_declared_gang = true
					if offline_phase == "ended":
						break
			if ai_declared_gang and mode == "offline" and offline_phase == "await_discard":
				request_game_render()
				await pace_after_visible_ai_action()
			if should_yield_before_ai_discard():
				await get_tree().process_frame
			await get_tree().create_timer(ai_discard_delay()).timeout
		if mode != "offline" or offline_phase != "await_discard" or current_seat == 0:
			break
		seat = current_seat
		var tile = choose_ai_discard_for_seat(seat)
		discard_tile_by_value(seat, tile)
		resolve_after_discard(seat, tile)
		if offline_phase == "pending_claim" or offline_phase == "ended":
			break
		if mode == "offline" and offline_phase == "await_discard":
			await pace_after_visible_ai_action(current_seat == 0)
	if mode == "offline" and offline_phase == "await_discard" and current_seat == 0 and offline_turn_needs_draw:
		if wall.is_empty():
			finish_wall_draw()
		else:
			await get_tree().create_timer(human_draw_delay()).timeout
			if mode == "offline" and offline_phase == "await_discard" and current_seat == 0:
				var drawn = draw_tile_for(0)
				sort_hand(players[0]["hand"])
				offline_turn_needs_draw = false
				if can_win_for_seat(0):
					add_log("你摸到%s，可以自摸。" % tile_label(drawn))
				else:
					add_log("轮到你出牌。")
				render_game()
	offline_ai_active = false

func discard_tile_by_index(seat: int, index: int) -> String:
	var hand: Array = players[seat]["hand"]
	var tile = str(hand[index])
	hand.remove_at(index)
	commit_discard(seat, tile)
	return tile

func discard_tile_by_value(seat: int, tile: String) -> void:
	var hand: Array = players[seat]["hand"]
	var index = find_tile_in_hand(hand, tile)
	if index < 0 and hand.size() > 0:
		index = 0
		tile = str(hand[index])
	if index >= 0:
		hand.remove_at(index)
	commit_discard(seat, tile)

func commit_discard(seat: int, tile: String) -> void:
	if seat == 0:
		clear_pending_danger_discard()
	players[seat]["discards"].append(tile)
	last_discard = tile
	last_discard_seat = seat
	offline_phase = "resolving"
	offline_turn_needs_draw = false
	play_sfx("discard", -2.5)
	play_fx_discard_ripple()
	speak_tile_call(tile)
	add_log("%s打出%s。" % [players[seat]["name"], tile_label(tile)])

func resolve_after_discard(from_seat: int, tile: String) -> void:
	if mode != "offline" or offline_phase == "ended":
		return
	var ai_claim = choose_ai_claim(from_seat, tile)
	if from_seat != 0:
		var human_hand_counts = tile_counts(players[0]["hand"])
		var human_options = get_claim_options(0, from_seat, tile, human_hand_counts)
		var visible_human_options = filter_claim_options_by_priority(human_options, claim_priority(str(ai_claim.get("claim", ""))))
		if not visible_human_options.is_empty():
			offline_pending_claim = {
				"from_seat": from_seat,
				"tile": tile,
				"options": visible_human_options,
				"chi_choices": get_chi_choices_from_counts(human_hand_counts, tile) if visible_human_options.has("chi") else [],
			}
			offline_phase = "pending_claim"
			add_log("你可响应%s。" % tile_label(tile))
			render_game()
			return
	resolve_ai_or_advance(from_seat, tile, ai_claim)

func resolve_ai_or_advance(from_seat: int, tile: String, prepared_claim: Dictionary = {}) -> void:
	var claim = prepared_claim if not prepared_claim.is_empty() else choose_ai_claim(from_seat, tile)
	if not claim.is_empty():
		apply_offline_claim(int(claim.get("seat", -1)), from_seat, tile, str(claim.get("claim", "")), claim.get("chi_choice", {}))
	else:
		pass_discard_to_next(from_seat)
	request_game_render()

func filter_claim_options_by_priority(options: Array, minimum_priority: int) -> Array:
	var result: Array = []
	for option in options:
		var claim = str(option)
		if claim_priority(claim) >= minimum_priority:
			result.append(claim)
	return result

func claim_priority(claim: String) -> int:
	match claim:
		"hu":
			return 4
		"gang", "peng":
			return 3
		"chi":
			return 2
	return 0

func get_claim_options(seat: int, from_seat: int, tile: String, hand_counts_snapshot: Array = []) -> Array:
	var options: Array = []
	if seat == from_seat or offline_phase == "ended":
		return options
	var hand: Array = players[seat]["hand"] if seat >= 0 and seat < players.size() else []
	var hand_counts = hand_counts_snapshot if not hand_counts_snapshot.is_empty() else tile_counts(hand)
	if can_win_for_seat_from_counts(seat, hand_counts, tile):
		options.append("hu")
	var held_count = tile_count_from_counts(tile, hand_counts)
	if held_count >= 3:
		options.append("gang")
	if held_count >= 2:
		options.append("peng")
	if seat == (from_seat + 1) % 4 and not get_chi_choices_from_counts(hand_counts, tile).is_empty():
		options.append("chi")
	return options

func choose_ai_claim(from_seat: int, tile: String) -> Dictionary:
	var best: Dictionary = {}
	var best_score = -1.0
	var visible_counts_snapshot = visible_tile_counts()
	for offset in range(1, 4):
		var seat = (from_seat + offset) % 4
		if seat == 0:
			continue
		var hand_counts = tile_counts(players[seat]["hand"])
		var options = get_claim_options(seat, from_seat, tile, hand_counts)
		if options.is_empty():
			continue
		if options.has("hu"):
			return {"seat": seat, "claim": "hu", "score": 1000.0 - offset}
		var claim_context = make_ai_claim_context(seat, visible_counts_snapshot, hand_counts)
		if options.has("gang"):
			var gang_report = build_ai_claim_report(seat, "gang", tile, {}, claim_context)
			if not bool(gang_report.get("allow", false)):
				pass
			else:
				var gang_score = ai_claim_action_score(gang_report, offset)
				if gang_score > best_score:
					best = {"seat": seat, "claim": "gang", "score": gang_score, "claim_report": gang_report}
					best_score = gang_score
		if options.has("peng"):
			var peng_report = build_ai_claim_report(seat, "peng", tile, {}, claim_context)
			if not bool(peng_report.get("allow", false)):
				pass
			else:
				var peng_score = ai_claim_action_score(peng_report, offset)
				if peng_score > best_score:
					best = {"seat": seat, "claim": "peng", "score": peng_score, "claim_report": peng_report}
					best_score = peng_score
		if options.has("chi"):
			var chi_claim = best_ai_chi_claim(seat, tile, offset, claim_context)
			var chi_score = float(chi_claim.get("score", -1000000.0))
			if not chi_claim.is_empty() and chi_score > best_score:
				best = chi_claim
				best_score = chi_score
	return best

func best_ai_chi_claim(seat: int, tile: String, offset: int = 1, claim_context: Dictionary = {}) -> Dictionary:
	var best: Dictionary = {}
	var best_score = -1000000.0
	if seat < 0 or seat >= players.size() or tile == "":
		return best
	var choices = get_chi_choices_from_counts(claim_context.get("hand_counts", []), tile) if is_ai_claim_context_for_seat(claim_context, seat) else get_chi_choices(players[seat]["hand"], tile)
	for choice in choices:
		var chi_choice: Dictionary = choice
		var report = build_ai_claim_report(seat, "chi", tile, chi_choice, claim_context)
		if not bool(report.get("allow", false)):
			continue
		var score = ai_claim_action_score(report, offset)
		if best.is_empty() or score > best_score or (is_equal_approx(score, best_score) and ai_chi_choice_tiebreak(report) > ai_chi_choice_tiebreak(best.get("claim_report", {}))):
			best = {
				"seat": seat,
				"claim": "chi",
				"score": score,
				"chi_choice": duplicate_chi_choice(chi_choice),
				"claim_report": report,
			}
			best_score = score
	return best

func ai_chi_choice_tiebreak(report: Dictionary) -> float:
	if report.is_empty():
		return -1000000.0
	return -float(report.get("after_shanten", 8)) * 1000.0 + float(report.get("shape_gain", 0.0)) - float(report.get("forced_discard_risk", 0.0)) * 0.25

func ai_claim_action_score(report: Dictionary, offset: int) -> float:
	var claim = str(report.get("claim", ""))
	var base = 0.0
	match claim:
		"gang":
			base = 82.0
		"peng":
			base = 58.0
		"chi":
			base = 36.0
	var before_shanten = int(report.get("before_shanten", 8))
	var after_shanten = int(report.get("after_shanten", before_shanten))
	var shanten_gain = max(0, before_shanten - after_shanten)
	var shape_gain = float(report.get("shape_gain", 0.0))
	var forced_risk = float(report.get("forced_discard_risk", 0.0))
	var seat = int(report.get("seat", -1))
	var attack = ai_total_attack_multiplier(seat)
	var claim_aggression = ai_claim_aggression(seat)
	var risk_multiplier = clamp((2.0 - attack) * ai_risk_factor(seat), 0.64, 1.42)
	return base * claim_aggression - float(offset) + (float(shanten_gain) * 28.0 + clamp(shape_gain, -24.0, 96.0) * 0.05) * attack - forced_risk * 0.03 * risk_multiplier

func make_ai_claim_context(seat: int, visible_counts_snapshot: Array = [], hand_counts_snapshot: Array = []) -> Dictionary:
	if seat < 0 or seat >= players.size():
		return {}
	var hand: Array = players[seat]["hand"]
	var open_melds = players[seat]["melds"].size()
	var hand_counts = hand_counts_snapshot if not hand_counts_snapshot.is_empty() else tile_counts(hand)
	var route_focus = ai_route_focus(seat)
	var visible_counts = visible_counts_snapshot if not visible_counts_snapshot.is_empty() else visible_tile_counts()
	var eval_context = make_ai_evaluation_context(seat, visible_counts)
	var pressure_context = ai_pressure_context(seat, eval_context)
	eval_context["pressure_context"] = pressure_context
	var before_shanten = calculate_min_shanten_from_counts(hand_counts, open_melds)
	return {
		"seat": seat,
		"hand_counts": hand_counts,
		"hand_size": hand.size(),
		"open_melds": open_melds,
		"before_shanten": before_shanten,
		"before_plan_label": str(hand_plan_report_for_seat_from_counts(seat, hand_counts, hand.size()).get("label", "")),
		"route_focus": route_focus,
		"before_score": evaluate_ai_hand_from_counts(hand_counts) + hand_plan_score_from_counts(hand_counts, hand.size()) * 0.35 * route_focus,
		"visible_counts": visible_counts,
		"eval_context": eval_context,
		"pressure_context": pressure_context,
	}

func is_ai_claim_context_for_seat(claim_context: Dictionary, seat: int) -> bool:
	if claim_context.is_empty() or int(claim_context.get("seat", -1)) != seat:
		return false
	var hand_counts = claim_context.get("hand_counts", [])
	return typeof(hand_counts) == TYPE_ARRAY and not (hand_counts as Array).is_empty()

func ai_context_pressure_context(seat: int, eval_context: Dictionary = {}) -> Dictionary:
	if not eval_context.is_empty() and (not eval_context.has("seat") or int(eval_context.get("seat", -1)) == seat):
		var cached_pressure = eval_context.get("pressure_context", {})
		if typeof(cached_pressure) == TYPE_DICTIONARY and not (cached_pressure as Dictionary).is_empty():
			return cached_pressure
	var pressure_context = ai_pressure_context(seat, eval_context)
	if not eval_context.is_empty():
		eval_context["pressure_context"] = pressure_context
	return pressure_context

func build_ai_claim_report(seat: int, claim: String, tile: String, chi_choice: Dictionary = {}, claim_context: Dictionary = {}) -> Dictionary:
	var report: Dictionary = {
		"seat": seat,
		"claim": claim,
		"tile": tile,
		"allow": false,
		"reason": "非法响应",
		"before_shanten": 8,
		"after_shanten": 8,
		"shape_gain": 0.0,
		"threshold": 0.0,
		"defense": 0.0,
		"pressure": 0.0,
		"forced_discard": "",
		"forced_discard_risk": 0.0,
		"forced_discard_safety": "",
		"declined_by_pressure": false,
		"declined_by_plan": false,
		"plan_label": "",
		"chi_choice": {},
		"ai_profile": ai_profile_label(seat),
		"ai_profile_short": ai_profile_short_label(seat),
	}
	if seat < 0 or seat >= players.size() or tile == "":
		return report
	var hand: Array = players[seat]["hand"]
	var has_claim_context = is_ai_claim_context_for_seat(claim_context, seat)
	var open_melds = int(claim_context.get("open_melds", 0)) if has_claim_context else players[seat]["melds"].size()
	var hand_counts = claim_context.get("hand_counts", []) if has_claim_context else tile_counts(hand)
	var before_shanten = int(claim_context.get("before_shanten", 8)) if has_claim_context else calculate_min_shanten_from_counts(hand_counts, open_melds)
	var before_plan_label = str(claim_context.get("before_plan_label", "")) if has_claim_context else str(hand_plan_report_for_seat_from_counts(seat, hand_counts, hand.size()).get("label", ""))
	var after = hand.duplicate()
	var after_counts = hand_counts.duplicate()
	var route_focus = float(claim_context.get("route_focus", 1.0)) if has_claim_context else ai_route_focus(seat)
	var bonus = ai_claim_meld_bonus(seat, claim, tile, chi_choice)
	var threshold = ai_claim_shape_threshold(seat, claim, open_melds)
	match claim:
		"gang":
			if not consume_tile_count(after_counts, tile, 3) or not remove_known_tiles(after, tile, 3):
				return report
		"peng":
			if not consume_tile_count(after_counts, tile, 2) or not remove_known_tiles(after, tile, 2):
				return report
		"chi":
			var needed: Array = chi_choice.get("needed", [])
			if needed.is_empty() or not consume_tile_list_counts(after_counts, needed) or not remove_known_tile_list(after, needed):
				return report
			report["chi_choice"] = duplicate_chi_choice(chi_choice)
		_:
			return report
	var after_open_melds = open_melds + 1
	var after_shanten = calculate_min_shanten_from_counts(after_counts, after_open_melds)
	var before_score = float(claim_context.get("before_score", 0.0)) if has_claim_context else evaluate_ai_hand_from_counts(hand_counts) + hand_plan_score_from_counts(hand_counts, hand.size()) * 0.35 * route_focus
	var after_score = evaluate_ai_hand_from_counts(after_counts) + hand_plan_score_from_counts(after_counts, after.size()) * 0.35 * route_focus + bonus
	var shape_gain = after_score - before_score
	var allow = false
	var reason = "牌型收益不足"
	if after_shanten < before_shanten:
		allow = true
		reason = "降向听"
	elif after_shanten > before_shanten:
		reason = "升向听"
	elif shape_gain >= threshold:
		allow = true
		reason = "牌型收益"
	var declined_by_plan = false
	if open_melds == 0 and before_plan_label == "七对":
		allow = false
		reason = "保七对"
		declined_by_plan = true
	elif open_melds == 0 and seat != 0 and ai_route_focus(seat) >= 1.15 and ["清一色", "混一色", "一条龙", "十三幺"].has(before_plan_label) and after_shanten >= before_shanten and shape_gain < max(18.0, threshold * 1.2):
		allow = false
		reason = "保路线"
		declined_by_plan = true
	var pressure_report = ai_open_claim_pressure_report(seat, claim, tile, before_shanten, after_shanten, after, after_open_melds, claim_context, after_counts)
	var declined_by_pressure = allow and bool(pressure_report.get("decline", false))
	if declined_by_pressure:
		allow = false
		reason = "高压防守"
	report["allow"] = allow
	report["reason"] = reason
	report["before_shanten"] = before_shanten
	report["after_shanten"] = after_shanten
	report["shape_gain"] = shape_gain
	report["threshold"] = threshold
	report["defense"] = float(pressure_report.get("defense", 0.0))
	report["pressure"] = float(pressure_report.get("pressure", 0.0))
	report["forced_discard"] = str(pressure_report.get("discard", ""))
	report["forced_discard_risk"] = float(pressure_report.get("risk", 0.0))
	report["forced_discard_safety"] = str(pressure_report.get("safety", ""))
	report["declined_by_pressure"] = declined_by_pressure
	report["declined_by_plan"] = declined_by_plan
	report["plan_label"] = before_plan_label
	return report

func ai_claim_meld_bonus(seat: int, claim: String, tile: String, chi_choice: Dictionary = {}) -> float:
	var claim_aggression = ai_claim_aggression(seat)
	match claim:
		"gang":
			return (64.0 if is_terminal_or_honor(tile) else 48.0) * claim_aggression
		"peng":
			return (50.0 if is_terminal_or_honor(tile) else 34.0) * claim_aggression
		"chi":
			return (28.0 + float(chi_choice.get("score", 0.0)) * 0.08) * claim_aggression
	return 0.0

func ai_claim_shape_threshold(seat: int, claim: String, open_melds: int) -> float:
	var threshold = 9999.0
	match claim:
		"peng":
			threshold = 10.0 if open_melds == 0 else -4.0
		"chi":
			threshold = 14.0 if open_melds == 0 else 0.0
		"gang":
			threshold = 6.0 if open_melds == 0 else -2.0
	if threshold >= 0.0:
		return threshold / max(0.45, ai_claim_aggression(seat))
	return threshold - max(0.0, ai_claim_aggression(seat) - 1.0) * 6.0

func ai_open_claim_pressure_report(seat: int, claim: String, tile: String, before_shanten: int, after_shanten: int, after_hand: Array, after_open_melds: int, claim_context: Dictionary = {}, after_counts_snapshot: Array = []) -> Dictionary:
	var eval_context: Dictionary = {}
	var pressure_context: Dictionary = {}
	if is_ai_claim_context_for_seat(claim_context, seat):
		var shared_eval_context = claim_context.get("eval_context", {})
		if typeof(shared_eval_context) == TYPE_DICTIONARY:
			eval_context = shared_eval_context
		var shared_pressure_context = claim_context.get("pressure_context", {})
		if typeof(shared_pressure_context) == TYPE_DICTIONARY:
			pressure_context = shared_pressure_context
	if eval_context.is_empty():
		var visible_counts_snapshot = visible_tile_counts()
		eval_context = make_ai_evaluation_context(seat, visible_counts_snapshot)
	if pressure_context.is_empty():
		pressure_context = ai_context_pressure_context(seat, eval_context)
	var defense = ai_defense_weight(seat, before_shanten, pressure_context)
	var pressure = float(pressure_context.get("opponent_pressure", 0.0))
	var best_post = best_ai_post_claim_discard_report(seat, after_hand, after_open_melds, eval_context, after_counts_snapshot) if claim != "gang" else {}
	var forced_tile = str(best_post.get("tile", ""))
	var forced_risk = float(best_post.get("risk", 0.0))
	var forced_safety = str(best_post.get("safety_label", ""))
	var decline = false
	var pressure_limit = 4.6 * ai_pressure_tolerance(seat)
	var risk_limit = 27.0 * ai_pressure_tolerance(seat)
	if after_shanten >= before_shanten and before_shanten >= 2 and defense >= 1.45:
		if claim == "gang":
			decline = after_shanten > 1 and pressure >= pressure_limit and not is_terminal_or_honor(tile)
		elif forced_safety != "安":
			decline = forced_risk >= risk_limit or pressure >= pressure_limit
	return {
		"defense": defense,
		"pressure": pressure,
		"discard": forced_tile,
		"risk": forced_risk,
		"safety": forced_safety,
		"decline": decline,
	}

func best_ai_post_claim_discard_report(seat: int, after_hand: Array, open_melds: int, eval_context: Dictionary = {}, after_counts_snapshot: Array = []) -> Dictionary:
	var best: Dictionary = {}
	var visible_counts_snapshot = visible_tile_counts() if eval_context.is_empty() else ai_context_visible_counts(eval_context)
	var shared_context = make_ai_evaluation_context(seat, visible_counts_snapshot) if eval_context.is_empty() else eval_context
	var pressure_context = ai_context_pressure_context(seat, shared_context)
	var after_counts = after_counts_snapshot if not after_counts_snapshot.is_empty() else tile_counts(after_hand)
	var evaluated_tiles := {}
	var simulated = after_hand.duplicate()
	var simulated_counts = after_counts.duplicate()
	for i in range(after_hand.size()):
		var candidate = str(after_hand[i])
		if evaluated_tiles.has(candidate):
			continue
		evaluated_tiles[candidate] = true
		var candidate_index = tile_index(candidate)
		if candidate_index < 0 or candidate_index >= simulated_counts.size() or int(simulated_counts[candidate_index]) <= 0:
			continue
		simulated.remove_at(i)
		simulated_counts[candidate_index] = int(simulated_counts[candidate_index]) - 1
		var report = build_ai_discard_report(seat, candidate, simulated, open_melds, visible_counts_snapshot, pressure_context, shared_context, simulated_counts, after_counts)
		simulated_counts[candidate_index] = int(simulated_counts[candidate_index]) + 1
		simulated.insert(i, candidate)
		if best.is_empty() or float(report.get("score", -1000000.0)) > float(best.get("score", -1000000.0)):
			best = report
	return best

func apply_offline_claim(seat: int, from_seat: int, tile: String, claim: String, chi_choice: Dictionary = {}) -> void:
	if seat < 0 or seat >= players.size():
		return
	if claim == "hu":
		finish_offline_round(seat, tile, false, from_seat)
		return
	remove_last_discard(from_seat, tile)
	var hand: Array = players[seat]["hand"]
	var meld: Array = []
	match claim:
		"peng":
			if not remove_tiles(hand, tile, 2):
				pass_discard_to_next(from_seat)
				return
			meld = [tile, tile, tile]
			play_sfx("peng", -2.0)
			speak_action_call("碰", tile)
			add_log("%s碰%s。" % [players[seat]["name"], tile_label(tile)])
		"gang":
			if not remove_tiles(hand, tile, 3):
				pass_discard_to_next(from_seat)
				return
			meld = [tile, tile, tile, tile]
			play_sfx("gang", -2.0)
			speak_action_call("杠", tile)
			add_log("%s杠%s。" % [players[seat]["name"], tile_label(tile)])
		"chi":
			var choice = chi_choice if not chi_choice.is_empty() else best_chi_choice(hand, tile)
			if choice.is_empty():
				pass_discard_to_next(from_seat)
				return
			var needed: Array = choice.get("needed", [])
			if not remove_tile_list(hand, needed):
				pass_discard_to_next(from_seat)
				return
			meld = choice.get("meld", [])
			play_sfx("peng", -4.0)
			speak_action_call("吃", tile)
			add_log("%s吃%s。" % [players[seat]["name"], tile_label(tile)])
		_:
			pass_discard_to_next(from_seat)
			return
	players[seat]["melds"].append(meld)
	record_claim_source(seat, from_seat, claim)
	sort_hand(hand)
	last_discard = ""
	last_discard_seat = -1
	current_seat = seat
	offline_turn_needs_draw = false
	offline_phase = "await_discard"
	offline_pending_claim.clear()
	if claim == "gang":
		draw_after_gang(seat)

func pass_discard_to_next(from_seat: int) -> void:
	current_seat = (from_seat + 1) % 4
	offline_turn_needs_draw = true
	offline_phase = "await_discard"
	offline_pending_claim.clear()

func record_claim_source(claimer: int, from_seat: int, claim: String) -> void:
	if claimer < 0 or from_seat < 0 or claimer == from_seat:
		return
	if claim != "chi" and claim != "peng" and claim != "gang":
		return
	var key = claim_source_key(claimer, from_seat)
	var count = int(offline_claim_counts.get(key, 0)) + 1
	offline_claim_counts[key] = count
	if count >= 3 and not offline_package_liability.has(claimer):
		offline_package_liability[claimer] = from_seat
		add_log("%s对%s三搭成包。" % [players[from_seat]["name"], players[claimer]["name"]])

func claim_source_key(claimer: int, from_seat: int) -> String:
	return "%d:%d" % [claimer, from_seat]

func package_payer_for(winner: int) -> int:
	return int(offline_package_liability.get(winner, -1))

func remove_last_discard(seat: int, tile: String) -> void:
	var discards: Array = players[seat]["discards"]
	if not discards.is_empty() and str(discards.back()) == tile:
		discards.pop_back()
		return
	var index = find_tile_in_hand(discards, tile)
	if index >= 0:
		discards.remove_at(index)

func perform_concealed_gang(seat: int, tile: String) -> void:
	var hand: Array = players[seat]["hand"]
	if not remove_tiles(hand, tile, 4):
		return
	players[seat]["melds"].append([tile, tile, tile, tile])
	play_sfx("gang", -2.0)
	speak_action_call("暗杠", tile)
	add_log("%s暗杠%s。" % [players[seat]["name"], tile_label(tile)])
	sort_hand(hand)
	draw_after_gang(seat)

func perform_added_gang(seat: int, tile: String) -> void:
	if not can_added_gang(seat, tile):
		return
	if begin_rob_gang_resolution(seat, tile):
		return
	complete_added_gang(seat, tile)

func complete_added_gang(seat: int, tile: String) -> void:
	var hand: Array = players[seat]["hand"]
	if not remove_tiles(hand, tile, 1):
		return
	var melds: Array = players[seat]["melds"]
	for i in range(melds.size()):
		var meld: Array = melds[i]
		if is_triplet_meld(meld, tile):
			meld.append(tile)
			melds[i] = meld
			break
	play_sfx("gang", -2.0)
	speak_action_call("补杠", tile)
	add_log("%s补杠%s。" % [players[seat]["name"], tile_label(tile)])
	sort_hand(hand)
	draw_after_gang(seat)

func begin_rob_gang_resolution(gang_seat: int, tile: String) -> bool:
	var ai_claim = choose_ai_rob_gang(gang_seat, tile)
	if gang_seat != 0 and can_win_for_seat(0, tile):
		offline_pending_claim = {
			"from_seat": gang_seat,
			"tile": tile,
			"options": ["hu"],
			"rob_gang": true,
			"ai_claim": ai_claim,
		}
		offline_phase = "pending_claim"
		add_log("你可抢杠胡%s。" % tile_label(tile))
		render_game()
		return true
	if not ai_claim.is_empty():
		finish_offline_round(int(ai_claim.get("seat", -1)), tile, false, gang_seat, "rob_gang")
		return true
	return false

func resolve_after_rob_gang_pass(gang_seat: int, tile: String, prepared_ai_claim: Dictionary = {}) -> void:
	var ai_claim = prepared_ai_claim if not prepared_ai_claim.is_empty() else choose_ai_rob_gang(gang_seat, tile)
	if not ai_claim.is_empty():
		finish_offline_round(int(ai_claim.get("seat", -1)), tile, false, gang_seat, "rob_gang")
	else:
		complete_added_gang(gang_seat, tile)
	render_game()

func choose_ai_rob_gang(gang_seat: int, tile: String) -> Dictionary:
	for offset in range(1, 4):
		var seat = (gang_seat + offset) % 4
		if seat == gang_seat or seat == 0:
			continue
		if can_win_for_seat(seat, tile):
			return {"seat": seat, "claim": "hu", "score": 1100.0 - offset}
	return {}

func can_added_gang(seat: int, tile: String) -> bool:
	if seat < 0 or seat >= players.size() or tile == "":
		return false
	if count_tile(players[seat]["hand"], tile) <= 0:
		return false
	for meld in players[seat]["melds"]:
		if is_triplet_meld(meld, tile):
			return true
	return false

func is_triplet_meld(meld: Array, tile: String) -> bool:
	if meld.size() != 3:
		return false
	for item in meld:
		if str(item) != tile:
			return false
	return true

func draw_after_gang(seat: int) -> void:
	if wall.is_empty():
		finish_wall_draw()
		return
	var drawn = draw_tile_for(seat, true, "gang")
	sort_hand(players[seat]["hand"])
	offline_turn_needs_draw = false
	offline_phase = "await_discard"
	add_log("%s杠后补牌。" % players[seat]["name"])
	if can_win_for_seat(seat):
		finish_offline_round(seat, drawn, true, -1)

func finish_wall_draw() -> void:
	offline_phase = "ended"
	offline_turn_needs_draw = false
	offline_pending_claim.clear()
	offline_last_winner = -1
	offline_dealer_repeat = true
	last_score_deltas = [0, 0, 0, 0]
	round_summary = "荒庄，牌墙已空。%s连庄。" % players[dealer_seat]["name"]
	add_log(round_summary)
	play_fx_win_burst("荒庄", Color(0.80, 0.80, 0.74, 1.0))
	save_offline_progress()
	render_game()

func finish_offline_round(winner: int, win_tile: String, self_draw: bool, from_seat: int, win_context: String = "") -> void:
	play_sfx("win", -1.0)
	speak_action_call("自摸" if self_draw else "胡", win_tile)
	var fx_burst_text = ("自摸" if self_draw else "胡") + ("" if winner == 0 else " " + str(players[winner].get("name", "")))
	var fx_burst_color = UI_GOLD_SOFT if winner == 0 else Color(0.88, 0.42, 0.32, 1.0)
	play_fx_win_burst(fx_burst_text, fx_burst_color)
	var score_data = calculate_win_score(winner, win_tile, self_draw, win_context)
	var points = int(score_data.get("points", 0))
	var package_payer = package_payer_for(winner)
	var before_scores: Array[int] = []
	for seat in range(players.size()):
		before_scores.append(int(players[seat].get("score", 0)))
	var has_package_self_draw = self_draw and package_payer >= 0 and package_payer != winner
	if has_package_self_draw:
		var package_payment = points * 3
		players[package_payer]["score"] = int(players[package_payer].get("score", 0)) - package_payment
		players[winner]["score"] = int(players[winner].get("score", 0)) + package_payment
	elif self_draw:
		for seat in range(4):
			if seat == winner:
				continue
			players[seat]["score"] = int(players[seat].get("score", 0)) - points
			players[winner]["score"] = int(players[winner].get("score", 0)) + points
	else:
		var payer = from_seat if from_seat >= 0 else last_discard_seat
		var payment = points * 3
		players[payer]["score"] = int(players[payer].get("score", 0)) - payment
		players[winner]["score"] = int(players[winner].get("score", 0)) + payment
	last_score_deltas = []
	for seat in range(players.size()):
		last_score_deltas.append(int(players[seat].get("score", 0)) - int(before_scores[seat]))

	# 记录游戏统计
	var player_score_delta = int(last_score_deltas[0])
	var player_won = winner == 0
	record_game_result(player_won, player_score_delta, offline_hand_number)

	offline_phase = "ended"
	offline_turn_needs_draw = false
	offline_pending_claim.clear()
	current_seat = winner
	offline_last_winner = winner
	offline_dealer_repeat = winner == dealer_seat
	var limit_text = " %s" % str(score_data.get("limit_name", "")) if str(score_data.get("limit_name", "")) != "" else ""
	round_summary = "%s%s%s，%d番%s %d分。%s" % [
		players[winner]["name"],
		"自摸" if self_draw else "胡",
		tile_label(win_tile) if win_tile != "" else "",
		int(score_data.get("fan", 1)),
		limit_text,
		points,
		"、".join(score_data.get("reasons", [])),
	]
	round_summary += " %s" % ("庄家连庄。" if offline_dealer_repeat else "庄家下庄。")
	if has_package_self_draw:
		round_summary += " 包三搭：%s包赔。" % players[package_payer]["name"]
	if is_offline_match_finished():
		round_summary += " 全场结束。"
	add_log(round_summary)
	save_offline_progress()
	render_game()

func is_offline_match_finished() -> bool:
	return offline_hand_number >= MATCH_MAX_HANDS

func ranked_seats_by_score() -> Array:
	var seats: Array = [0, 1, 2, 3]
	seats.sort_custom(func(a, b): return int(players[int(a)].get("score", 0)) > int(players[int(b)].get("score", 0)))
	return seats

func score_context_report(seat: int) -> Dictionary:
	if mode != "offline" or seat < 0 or seat >= players.size() or players.is_empty():
		return {}
	var ranked = ranked_seats_by_score()
	var rank = ranked.find(seat) + 1
	if rank <= 0:
		return {}
	var score = int(players[seat].get("score", 0))
	var leader = int(ranked[0])
	var leader_score = int(players[leader].get("score", 0))
	var second_score = leader_score
	if ranked.size() > 1:
		second_score = int(players[int(ranked[1])].get("score", 0))
	var lead_gap = score - second_score if rank == 1 else score - leader_score
	var late = clamp((float(offline_hand_number) - float(MATCH_MAX_HANDS - 3)) / 3.0, 0.0, 1.0)
	var strategy = "均衡"
	if late > 0.0 and rank == 1 and lead_gap >= 1200:
		strategy = "守成"
	elif late > 0.0 and rank >= 3 and lead_gap <= -1800:
		strategy = "追分"
	return {
		"rank": rank,
		"score": score,
		"leader_gap": lead_gap,
		"late": late,
		"strategy": strategy,
	}

func score_strategy_text(seat: int) -> String:
	var report = score_context_report(seat)
	if report.is_empty():
		return ""
	var rank = int(report.get("rank", 0))
	var gap = int(report.get("leader_gap", 0))
	var strategy = str(report.get("strategy", "均衡"))
	if rank == 1:
		return "分势 第1 %s %s" % ["均分" if gap == 0 else "领先%d" % gap, strategy]
	return "分势 第%d 落后%d %s" % [rank, abs(gap), strategy]

func score_defense_adjustment(seat: int) -> float:
	var report = score_context_report(seat)
	if report.is_empty():
		return 0.0
	var late = float(report.get("late", 0.0))
	if late <= 0.0:
		return 0.0
	var rank = int(report.get("rank", 0))
	var gap = int(report.get("leader_gap", 0))
	if rank == 1 and gap > 0:
		return min(0.30, 0.08 + float(gap) / 18000.0) * late
	if rank >= 3 and gap < 0:
		return -min(0.18, 0.04 + float(abs(gap)) / 26000.0) * late
	return 0.0

func score_attack_multiplier(seat: int) -> float:
	var report = score_context_report(seat)
	if report.is_empty():
		return 1.0
	var late = float(report.get("late", 0.0))
	if late <= 0.0:
		return 1.0
	var rank = int(report.get("rank", 0))
	var gap = int(report.get("leader_gap", 0))
	if rank == 1 and gap > 0:
		return clamp(1.0 - (0.06 + float(gap) / 60000.0) * late, 0.84, 1.0)
	if rank >= 3 and gap < 0:
		return clamp(1.0 + (0.08 + float(abs(gap)) / 52000.0) * late, 1.0, 1.34)
	return 1.0

func ai_profile(seat: int) -> Dictionary:
	return ai_profile_source(seat).duplicate(true)

func ai_profile_source(seat: int) -> Dictionary:
	if seat >= 0 and seat < AI_PROFILES.size():
		return AI_PROFILES[seat] as Dictionary
	return AI_PROFILES[0] as Dictionary

func ai_profile_value(seat: int, key: String, fallback: float = 1.0) -> float:
	return float(ai_profile_source(seat).get(key, fallback))

func ai_profile_label(seat: int) -> String:
	return str(ai_profile_source(seat).get("label", ""))

func ai_profile_short_label(seat: int) -> String:
	return str(ai_profile_source(seat).get("short", ""))

func ai_total_attack_multiplier(seat: int) -> float:
	return score_attack_multiplier(seat) * ai_profile_value(seat, "attack")

func ai_claim_aggression(seat: int) -> float:
	return ai_profile_value(seat, "claim")

func ai_risk_factor(seat: int) -> float:
	return ai_profile_value(seat, "risk")

func ai_route_focus(seat: int) -> float:
	return ai_profile_value(seat, "route")

func ai_wait_value_focus(seat: int) -> float:
	return ai_profile_value(seat, "wait")

func ai_gang_aggression(seat: int) -> float:
	return ai_profile_value(seat, "gang")

func ai_pressure_tolerance(seat: int) -> float:
	return ai_profile_value(seat, "pressure")

func calculate_win_score(seat: int, win_tile: String, self_draw: bool, win_context: String = "") -> Dictionary:
	var test_hand: Array = players[seat]["hand"].duplicate()
	if not self_draw and win_tile != "":
		test_hand.append(win_tile)
	return calculate_win_score_from_tiles(seat, test_hand, self_draw, win_context)

func calculate_win_score_from_tiles(seat: int, test_hand: Array, self_draw: bool, win_context: String = "") -> Dictionary:
	if seat < 0 or seat >= players.size():
		return {"fan": 0, "limit_fan": 0, "limit_name": "", "points": 0, "reasons": []}
	var fan = 1
	var reasons: Array[String] = ["平胡"]
	if self_draw:
		fan += 1
		reasons.append("自摸")
	if self_draw and is_last_draw_context(seat, "gang"):
		fan += 2
		reasons.append("杠上开花")
	if self_draw and bool(offline_last_draw.get("wall_empty", false)) and int(offline_last_draw.get("seat", -1)) == seat:
		fan += 1
		reasons.append("海底捞月")
	if win_context == "rob_gang":
		fan += 1
		reasons.append("抢杠胡")
	if seat == dealer_seat:
		fan += 1
		reasons.append("庄家")
	if int(players[seat]["flowers"]) > 0:
		fan += int(players[seat]["flowers"])
		reasons.append("花牌")
	if players[seat]["melds"].size() == 0:
		fan += 1
		reasons.append("门清")
	if players[seat]["melds"].size() == 0 and is_seven_pairs(test_hand):
		fan += 3
		reasons.append("七对")
	if players[seat]["melds"].size() == 0 and is_thirteen_orphans(test_hand):
		fan += 7
		reasons.append("十三幺")
	if is_all_honor_hand(seat, test_hand):
		fan += 5
		reasons.append("字一色")
	elif is_pure_one_suit_hand(seat, test_hand):
		fan += 3
		reasons.append("清一色")
	elif is_mixed_one_suit_hand(seat, test_hand):
		fan += 2
		reasons.append("混一色")
	if is_big_three_dragons_hand(seat, test_hand):
		fan += 6
		reasons.append("大三元")
	elif is_small_three_dragons_hand(seat, test_hand):
		fan += 4
		reasons.append("小三元")
	if is_big_four_winds_hand(seat, test_hand):
		fan += 7
		reasons.append("大四喜")
	elif is_small_four_winds_hand(seat, test_hand):
		fan += 5
		reasons.append("小四喜")
	if is_all_simples_hand(seat, test_hand):
		fan += 1
		reasons.append("断幺九")
	if is_full_straight_hand(seat, test_hand):
		fan += 2
		reasons.append("一条龙")
	if is_all_triplet_hand(seat, test_hand):
		fan += 2
		reasons.append("碰碰胡")
	if players[seat]["melds"].size() >= 4:
		fan += 2
		reasons.append("大吊车")
	var gang_count = count_gang_melds(seat)
	if gang_count > 0:
		fan += gang_count
		reasons.append("杠")
	var points = score_points_for_fan(fan)
	return {
		"fan": fan,
		"limit_fan": min(fan, SCORE_LIMIT_FAN),
		"limit_name": "封顶" if fan >= SCORE_LIMIT_FAN else "",
		"points": points,
		"reasons": reasons,
	}

func score_points_for_fan(fan: int) -> int:
	var key = clamp(fan, 1, SCORE_LIMIT_FAN)
	return int(SCORE_TABLE.get(key, SCORE_TABLE[SCORE_LIMIT_FAN]))

func is_last_draw_context(seat: int, source: String) -> bool:
	return int(offline_last_draw.get("seat", -1)) == seat and str(offline_last_draw.get("source", "")) == source

func can_win_for_seat(seat: int, extra_tile: String = "") -> bool:
	if seat < 0 or seat >= players.size():
		return false
	var tiles: Array = players[seat]["hand"].duplicate()
	if extra_tile != "":
		tiles.append(extra_tile)
	return is_complete_hand(tiles, players[seat]["melds"].size())

func can_win_for_seat_from_counts(seat: int, hand_counts: Array, extra_tile: String = "") -> bool:
	if seat < 0 or seat >= players.size() or hand_counts.is_empty():
		return false
	var counts = hand_counts
	var tile_count = players[seat]["hand"].size()
	if extra_tile != "":
		var index = tile_index(extra_tile)
		if index < 0 or index >= counts.size():
			return false
		counts = hand_counts.duplicate()
		counts[index] = int(counts[index]) + 1
		tile_count += 1
	return is_complete_hand_from_counts(counts, tile_count, players[seat]["melds"].size())

func is_complete_hand(tiles: Array, open_melds: int) -> bool:
	return is_complete_hand_from_counts(tile_counts(tiles), tiles.size(), open_melds)

func is_complete_hand_from_counts(counts: Array, tile_count: int, open_melds: int) -> bool:
	var needed_melds = 4 - open_melds
	if needed_melds < 0:
		return false
	if tile_count != needed_melds * 3 + 2:
		return false
	if open_melds == 0 and is_seven_pairs_from_counts(counts, tile_count):
		return true
	if open_melds == 0 and is_thirteen_orphans_from_counts(counts, tile_count):
		return true
	return is_standard_complete_from_counts(counts, needed_melds)

func is_seven_pairs(tiles: Array) -> bool:
	return is_seven_pairs_from_counts(tile_counts(tiles), tiles.size())

func is_seven_pairs_from_counts(counts: Array, tile_count: int) -> bool:
	if tile_count != 14:
		return false
	var pairs = 0
	for count in counts:
		if int(count) == 2:
			pairs += 1
		elif int(count) == 4:
			pairs += 2
		elif int(count) != 0:
			return false
	return pairs == 7

func is_thirteen_orphans(tiles: Array) -> bool:
	return is_thirteen_orphans_from_counts(tile_counts(tiles), tiles.size())

func is_thirteen_orphans_from_counts(counts: Array, tile_count: int) -> bool:
	if not tile_metadata_ready:
		setup_tile_order()
	if tile_count != 14:
		return false
	var unique = 0
	var has_pair = false
	for i in range(TILE_CODES.size()):
		var amount = int(counts[i])
		if amount <= 0:
			continue
		if i >= tile_order.size() or not bool(tile_thirteen_orphans_cache.get(TILE_CODES[i], false)):
			return false
		unique += 1
		if amount >= 2:
			if has_pair or amount > 2:
				return false
			has_pair = true
	return unique == THIRTEEN_ORPHANS_CODES.size() and has_pair

func is_thirteen_orphans_tile(tile: String) -> bool:
	if not tile_metadata_ready:
		setup_tile_order()
	if tile_thirteen_orphans_cache.has(tile):
		return bool(tile_thirteen_orphans_cache[tile])
	return THIRTEEN_ORPHANS_CODES.has(tile)

func is_standard_complete(tiles: Array, needed_melds: int) -> bool:
	return is_standard_complete_from_counts(tile_counts(tiles), needed_melds)

func is_standard_complete_from_counts(counts: Array, needed_melds: int) -> bool:
	var memo: Dictionary = {}
	for i in range(TILE_CODES.size()):
		if int(counts[i]) >= 2:
			counts[i] = int(counts[i]) - 2
			if can_form_sets_with_memo(counts, needed_melds, memo):
				counts[i] = int(counts[i]) + 2
				return true
			counts[i] = int(counts[i]) + 2
	return false

func can_form_sets(counts: Array, melds_needed: int) -> bool:
	var memo: Dictionary = {}
	return can_form_sets_with_memo(counts, melds_needed, memo)

func can_form_sets_with_memo(counts: Array, melds_needed: int, memo: Dictionary) -> bool:
	var first = -1
	for i in range(TILE_CODES.size()):
		if int(counts[i]) > 0:
			first = i
			break
	if first == -1:
		return melds_needed == 0
	if melds_needed <= 0:
		return false
	var memo_key = "%d:%s" % [melds_needed, counts_compact_key(counts)]
	if memo.has(memo_key):
		return bool(memo[memo_key])
	if int(counts[first]) >= 3:
		counts[first] = int(counts[first]) - 3
		if can_form_sets_with_memo(counts, melds_needed - 1, memo):
			counts[first] = int(counts[first]) + 3
			memo[memo_key] = true
			return true
		counts[first] = int(counts[first]) + 3
	if can_sequence_from(counts, first):
		counts[first] = int(counts[first]) - 1
		counts[first + 1] = int(counts[first + 1]) - 1
		counts[first + 2] = int(counts[first + 2]) - 1
		if can_form_sets_with_memo(counts, melds_needed - 1, memo):
			counts[first] = int(counts[first]) + 1
			counts[first + 1] = int(counts[first + 1]) + 1
			counts[first + 2] = int(counts[first + 2]) + 1
			memo[memo_key] = true
			return true
		counts[first] = int(counts[first]) + 1
		counts[first + 1] = int(counts[first + 1]) + 1
		counts[first + 2] = int(counts[first + 2]) + 1
	memo[memo_key] = false
	return false

func can_sequence_from(counts: Array, index: int) -> bool:
	if index < 0 or index >= 27:
		return false
	var rank = index % 9
	if rank > 6:
		return false
	return int(counts[index]) > 0 and int(counts[index + 1]) > 0 and int(counts[index + 2]) > 0

func choose_ai_discard_for_seat(seat: int) -> String:
	if seat < 0 or seat >= players.size():
		return ""
	var hand: Array = players[seat]["hand"]
	if hand.is_empty():
		return ""
	var reports = get_ai_discard_reports(seat)
	if reports.is_empty():
		return str(hand[0])
	return str(reports[0].get("tile", hand[0]))

func get_ai_discard_reports(seat: int) -> Array:
	var reports: Array = []
	if seat < 0 or seat >= players.size():
		return reports
	var hand: Array = players[seat]["hand"]
	if hand.is_empty():
		return reports
	var cache_key = ai_report_cache_key(seat)
	if ai_report_cache.has(cache_key):
		ai_report_cache_hits += 1
		return duplicate_report_array(ai_report_cache[cache_key])
	ai_report_cache_misses += 1
	var open_melds = players[seat]["melds"].size()
	var visible_counts_snapshot = visible_tile_counts()
	var eval_context = make_ai_evaluation_context(seat, visible_counts_snapshot)
	var pressure_context = ai_pressure_context(seat, eval_context)
	eval_context["pressure_context"] = pressure_context
	var hand_counts = tile_counts(hand)
	var evaluated_tiles := {}
	var simulated = hand.duplicate()
	var simulated_counts = hand_counts.duplicate()
	for i in range(hand.size()):
		var candidate = str(hand[i])
		if evaluated_tiles.has(candidate):
			continue
		evaluated_tiles[candidate] = true
		var candidate_index = tile_index(candidate)
		if candidate_index < 0 or candidate_index >= simulated_counts.size() or int(simulated_counts[candidate_index]) <= 0:
			continue
		simulated.remove_at(i)
		simulated_counts[candidate_index] = int(simulated_counts[candidate_index]) - 1
		var report = build_ai_discard_report(seat, candidate, simulated, open_melds, visible_counts_snapshot, pressure_context, eval_context, simulated_counts, hand_counts)
		reports.append(report)
		simulated_counts[candidate_index] = int(simulated_counts[candidate_index]) + 1
		simulated.insert(i, candidate)
	sort_ai_discard_reports(reports)
	store_ai_report_cache(cache_key, reports)
	return duplicate_report_array(reports)

func sort_ai_discard_reports(reports: Array) -> void:
	reports.sort_custom(func(a, b):
		var score_a = float(a.get("score", 0.0))
		var score_b = float(b.get("score", 0.0))
		if is_equal_approx(score_a, score_b):
			return tile_sort_index(str(a.get("tile", ""))) < tile_sort_index(str(b.get("tile", "")))
		return score_a > score_b
	)

func duplicate_report_array(reports: Array, copy_nested: bool = false) -> Array:
	var result: Array = []
	for report in reports:
		if typeof(report) == TYPE_DICTIONARY:
			result.append(duplicate_ai_report(report, copy_nested))
		else:
			result.append(report)
	return result

func duplicate_ai_report(report: Dictionary, copy_nested: bool = false) -> Dictionary:
	var copy: Dictionary = report.duplicate(false)
	if not copy_nested:
		return copy
	duplicate_report_array_field(copy, "effective_tiles")
	duplicate_report_array_field(copy, "wait_self_discarded")
	duplicate_report_dictionary_field(copy, "effective_remaining")
	duplicate_report_dictionary_field(copy, "danger_source")
	var feed_report = copy.get("feed_report", {})
	if typeof(feed_report) == TYPE_DICTIONARY:
		copy["feed_report"] = duplicate_feed_report(feed_report)
	return copy

func duplicate_report_array_field(report: Dictionary, key: String) -> void:
	var value = report.get(key, [])
	if typeof(value) == TYPE_ARRAY:
		report[key] = (value as Array).duplicate(false)

func duplicate_report_dictionary_field(report: Dictionary, key: String) -> void:
	var value = report.get(key, {})
	if typeof(value) == TYPE_DICTIONARY:
		report[key] = (value as Dictionary).duplicate(false)

func duplicate_feed_report(feed_report: Dictionary) -> Dictionary:
	var copy: Dictionary = feed_report.duplicate(false)
	var details = copy.get("details", [])
	if typeof(details) == TYPE_ARRAY:
		var detail_copies: Array = []
		for detail in details:
			if typeof(detail) == TYPE_DICTIONARY:
				detail_copies.append((detail as Dictionary).duplicate(false))
			else:
				detail_copies.append(detail)
		copy["details"] = detail_copies
	return copy

func duplicate_risk_vector(vector: Dictionary) -> Dictionary:
	var copy: Dictionary = vector.duplicate(false)
	duplicate_report_dictionary_field(copy, "danger_source")
	return copy

func duplicate_chi_choice(choice: Dictionary) -> Dictionary:
	var copy: Dictionary = choice.duplicate(false)
	duplicate_report_array_field(copy, "needed")
	duplicate_report_array_field(copy, "meld")
	return copy

func duplicate_claim_report(report: Dictionary) -> Dictionary:
	var copy: Dictionary = report.duplicate(false)
	var chi_choice = copy.get("chi_choice", {})
	if typeof(chi_choice) == TYPE_DICTIONARY:
		copy["chi_choice"] = duplicate_chi_choice(chi_choice)
	var declined = copy.get("declined", {})
	if typeof(declined) == TYPE_DICTIONARY and not (declined as Dictionary).is_empty():
		copy["declined"] = duplicate_claim_report(declined)
	return copy

func make_ai_evaluation_context(seat: int, visible_counts_snapshot: Array = []) -> Dictionary:
	var visible_counts = visible_counts_snapshot if not visible_counts_snapshot.is_empty() else visible_tile_counts()
	var opponents: Dictionary = {}
	for other in range(players.size()):
		if other == seat:
			continue
		opponents[other] = build_opponent_runtime_state(other)
	return {
		"seat": seat,
		"visible_counts": visible_counts,
		"opponents": opponents,
		"discard_pressures": {},
		"feed_reports": {},
		"risk_vectors": {},
		"safety_labels": {},
		"self_discard_lookup_ready": false,
		"main_threat": -2,
	}

func build_opponent_runtime_state(opponent: int) -> Dictionary:
	var state: Dictionary = {
		"discard_counts": {},
		"suit_discards": [0, 0, 0],
		"meld_count_by_suit": [0, 0, 0],
		"meld_tile_count_by_suit": [0, 0, 0],
		"honor_meld_count": 0,
		"melds": 0,
		"discards": 0,
		"suit_plan_threats": [0.0, 0.0, 0.0],
		"honor_plan_threat": 0.0,
		"plan_pressure": 0.0,
		"readiness": 0.0,
	}
	if opponent < 0 or opponent >= players.size():
		return state
	var discards: Array = players[opponent]["discards"]
	state["discards"] = discards.size()
	for item in discards:
		var tile = str(item)
		var counts: Dictionary = state["discard_counts"]
		counts[tile] = int(counts.get(tile, 0)) + 1
		var suit = tile_suit_index(tile)
		if suit >= 0 and suit < 3:
			var suit_discards: Array = state["suit_discards"]
			suit_discards[suit] = int(suit_discards[suit]) + 1
	var melds: Array = players[opponent]["melds"]
	state["melds"] = melds.size()
	for meld in melds:
		var suit_seen := [false, false, false]
		var has_honor = false
		for item in meld:
			var tile = str(item)
			var suit = tile_suit_index(tile)
			if suit >= 0 and suit < 3:
				suit_seen[suit] = true
				var tile_counts_by_suit: Array = state["meld_tile_count_by_suit"]
				tile_counts_by_suit[suit] = int(tile_counts_by_suit[suit]) + 1
			elif is_honor_tile(tile):
				has_honor = true
		for suit in range(3):
			if bool(suit_seen[suit]):
				var meld_counts_by_suit: Array = state["meld_count_by_suit"]
				meld_counts_by_suit[suit] = int(meld_counts_by_suit[suit]) + 1
		if has_honor:
			state["honor_meld_count"] = int(state["honor_meld_count"]) + 1
	var suit_plan_threats: Array = state["suit_plan_threats"]
	for suit in range(3):
		var meld_count = int((state["meld_count_by_suit"] as Array)[suit])
		if meld_count <= 0:
			suit_plan_threats[suit] = 0.0
			continue
		var meld_tiles = int((state["meld_tile_count_by_suit"] as Array)[suit])
		var suit_discards = int((state["suit_discards"] as Array)[suit])
		var off_suit_discards = max(0, discards.size() - suit_discards)
		var score = float(meld_count) * 4.0 + float(meld_tiles) * 0.70 + min(5.0, float(off_suit_discards) * 0.45)
		if meld_count >= 2:
			score += 6.0
		if meld_count >= 3:
			score += 8.0
		if suit_discards == 0:
			score += 4.0
		elif suit_discards <= 2:
			score += 1.8
		suit_plan_threats[suit] = score
	var honor_melds = int(state["honor_meld_count"])
	var honor_plan = 0.0
	if honor_melds > 0:
		honor_plan = float(honor_melds) * 5.0 + float(melds.size()) * 0.9
	state["honor_plan_threat"] = honor_plan
	var plan_pressure = honor_plan
	for suit in range(3):
		plan_pressure = max(plan_pressure, float(suit_plan_threats[suit]))
	state["plan_pressure"] = plan_pressure
	state["readiness"] = opponent_readiness_score_from_plan(opponent, plan_pressure)
	return state

func ai_context_visible_counts(eval_context: Dictionary, fallback: Array = []) -> Array:
	if not eval_context.is_empty() and eval_context.has("visible_counts"):
		var counts = eval_context.get("visible_counts", [])
		if typeof(counts) == TYPE_ARRAY and not counts.is_empty():
			return counts
	return fallback if not fallback.is_empty() else visible_tile_counts()

func ai_context_opponent_state(eval_context: Dictionary, opponent: int) -> Dictionary:
	if eval_context.is_empty() or not eval_context.has("opponents"):
		return {}
	var opponents = eval_context.get("opponents", {})
	if typeof(opponents) != TYPE_DICTIONARY or not opponents.has(opponent):
		return {}
	var state = opponents.get(opponent, {})
	return state if typeof(state) == TYPE_DICTIONARY else {}

func ai_context_self_discard_lookup(eval_context: Dictionary, seat: int) -> Dictionary:
	if not eval_context.is_empty() and bool(eval_context.get("self_discard_lookup_ready", false)):
		var cached = eval_context.get("self_discard_lookup", {})
		if typeof(cached) == TYPE_DICTIONARY:
			return cached
	if seat < 0 or seat >= players.size():
		return {}
	var lookup = tile_presence_set(players[seat]["discards"])
	if not eval_context.is_empty():
		eval_context["self_discard_lookup"] = lookup
		eval_context["self_discard_lookup_ready"] = true
	return lookup

func opponent_discard_tile_count(opponent: int, tile: String, eval_context: Dictionary = {}) -> int:
	var state = ai_context_opponent_state(eval_context, opponent)
	if not state.is_empty():
		var counts = state.get("discard_counts", {})
		if typeof(counts) == TYPE_DICTIONARY:
			return int(counts.get(tile, 0))
	if opponent < 0 or opponent >= players.size():
		return 0
	return count_tile(players[opponent]["discards"], tile)

func ai_context_cache_key(tile: String, seat: int) -> String:
	return "%d:%s" % [seat, tile]

func store_ai_report_cache(key: String, reports: Array) -> void:
	if key == "":
		return
	if not ai_report_cache.has(key):
		ai_report_cache_order.append(key)
	ai_report_cache[key] = duplicate_report_array(reports, true)
	while ai_report_cache_order.size() > AI_REPORT_CACHE_LIMIT:
		var oldest = ai_report_cache_order.pop_front()
		ai_report_cache.erase(oldest)

func clear_ai_report_cache() -> void:
	ai_report_cache.clear()
	ai_report_cache_order.clear()
	ai_report_cache_hits = 0
	ai_report_cache_misses = 0
	effective_tiles_cache.clear()
	effective_tiles_cache_order.clear()
	effective_tiles_cache_hits = 0
	effective_tiles_cache_misses = 0

func ai_report_cache_key(seat: int) -> String:
	var parts: Array[String] = [
		"seat=%d" % seat,
		"mode=" + mode,
		"phase=" + offline_phase,
		"cur=%d" % current_seat,
		"draw=%d" % (1 if offline_turn_needs_draw else 0),
		"dealer=%d" % dealer_seat,
		"handno=%d" % offline_hand_number,
		"wall=%d" % get_wall_count(),
	]
	for player_seat in range(players.size()):
		var player: Dictionary = players[player_seat]
		parts.append("p%d_score=%d" % [player_seat, int(player.get("score", 0))])
		parts.append("p%d_flowers=%d" % [player_seat, int(player.get("flowers", 0))])
		parts.append("p%d_hand=%s" % [player_seat, tile_array_key(player.get("hand", [])) if player_seat == seat else "%d" % numeric_count(player.get("hand", []), 0)])
		parts.append("p%d_disc=%s" % [player_seat, tile_array_key(player.get("discards", []))])
		parts.append("p%d_meld=%s" % [player_seat, meld_array_key(player.get("melds", []))])
	return "|".join(parts)

func tile_array_key(tiles: Array) -> String:
	if tiles.is_empty():
		return ""
	if tiles.size() <= 4:
		return small_tile_array_key(tiles)
	var counts: Dictionary = {}
	var indices: Array[int] = []
	for item in tiles:
		var index = tile_index(str(item))
		if index < 0:
			continue
		if not counts.has(index):
			counts[index] = 1
			indices.append(index)
		else:
			counts[index] = int(counts[index]) + 1
	if indices.is_empty():
		return ""
	indices.sort()
	var parts: Array[String] = []
	for i in indices:
		var amount = int(counts[i])
		if amount > 0:
			parts.append("%s%d" % [TILE_CODES[i], amount])
	return ",".join(parts)

func small_tile_array_key(tiles: Array) -> String:
	var first = -1
	var second = -1
	var third = -1
	var fourth = -1
	var valid = 0
	for item in tiles:
		var index = tile_index(str(item))
		if index < 0:
			continue
		match valid:
			0:
				first = index
			1:
				second = index
			2:
				third = index
			3:
				fourth = index
		valid += 1
	if valid == 0:
		return ""
	var swap = 0
	if valid > 1 and second < first:
		swap = first
		first = second
		second = swap
	if valid > 2:
		if third < second:
			swap = second
			second = third
			third = swap
		if second < first:
			swap = first
			first = second
			second = swap
	if valid > 3:
		if fourth < third:
			swap = third
			third = fourth
			fourth = swap
		if third < second:
			swap = second
			second = third
			third = swap
		if second < first:
			swap = first
			first = second
			second = swap
	var key = ""
	var current = first
	var amount = 1
	if valid > 1:
		if second == current:
			amount += 1
		else:
			key = append_tile_array_key_part(key, current, amount)
			current = second
			amount = 1
	if valid > 2:
		if third == current:
			amount += 1
		else:
			key = append_tile_array_key_part(key, current, amount)
			current = third
			amount = 1
	if valid > 3:
		if fourth == current:
			amount += 1
		else:
			key = append_tile_array_key_part(key, current, amount)
			current = fourth
			amount = 1
	return append_tile_array_key_part(key, current, amount)

func append_tile_array_key_part(key: String, index: int, amount: int) -> String:
	var part = TILE_CODES[index] + str(amount)
	return part if key == "" else key + "," + part

func meld_array_key(melds: Array) -> String:
	var parts: Array[String] = []
	for meld in melds:
		if typeof(meld) == TYPE_ARRAY:
			parts.append(tile_array_key(meld))
		else:
			parts.append(str(meld))
	return ";".join(parts)

func build_ai_discard_report(seat: int, tile: String, simulated: Array, open_melds: int, visible_counts_snapshot: Array = [], pressure_context: Dictionary = {}, eval_context: Dictionary = {}, simulated_counts_snapshot: Array = [], original_counts_snapshot: Array = []) -> Dictionary:
	var simulated_counts = simulated_counts_snapshot if not simulated_counts_snapshot.is_empty() else tile_counts(simulated)
	var original_counts = original_counts_snapshot
	if original_counts.is_empty():
		original_counts = simulated_counts.duplicate()
		var discarded_index = tile_index(tile)
		if discarded_index >= 0 and discarded_index < original_counts.size():
			original_counts[discarded_index] = int(original_counts[discarded_index]) + 1
	var simulated_tile_count = simulated.size()
	var visible_counts = ai_context_visible_counts(eval_context, visible_counts_snapshot)
	var shanten = calculate_min_shanten_from_counts(simulated_counts, open_melds)
	var attack = ai_total_attack_multiplier(seat)
	var route_focus = ai_route_focus(seat)
	var risk_factor = ai_risk_factor(seat)
	var metrics = effective_tile_metrics(simulated, open_melds, seat, shanten, visible_counts, simulated_counts)
	var ukeire = int(metrics.get("count", 0))
	var variety = int(metrics.get("variety", 0))
	var effective_tiles: Array = metrics.get("tiles", [])
	var effective_remaining: Dictionary = metrics.get("remaining_by_tile", {})
	var wait_value = 0.0
	var wait_best_tile = ""
	var wait_best_fan = 0
	var wait_best_points = 0
	var wait_average_points = 0.0
	var wait_total_remaining = 0
	var wait_adjusted_remaining = 0.0
	var wait_self_discarded: Array = []
	var wait_quality_text = ""
	if shanten <= 0:
		var self_discard_lookup = ai_context_self_discard_lookup(eval_context, seat)
		var wait_metrics = wait_value_metrics(seat, simulated, open_melds, shanten, effective_tiles, effective_remaining, true, self_discard_lookup, attack)
		wait_value = float(wait_metrics.get("score", 0.0))
		wait_best_tile = str(wait_metrics.get("best_tile", ""))
		wait_best_fan = int(wait_metrics.get("best_fan", 0))
		wait_best_points = int(wait_metrics.get("best_points", 0))
		wait_average_points = float(wait_metrics.get("average_points", 0.0))
		wait_total_remaining = int(wait_metrics.get("total_remaining", 0))
		wait_adjusted_remaining = float(wait_metrics.get("adjusted_remaining", 0.0))
		wait_self_discarded = wait_metrics.get("self_discarded", [])
		wait_quality_text = str(wait_metrics.get("quality_text", ""))
	var shape_metrics = ai_hand_shape_metrics_from_counts(simulated_counts)
	var shape = float(shape_metrics.get("value", 0.0))
	var shape_report: Dictionary = shape_metrics.get("quality_report", {})
	var shape_quality = float(shape_report.get("score", 0.0))
	var shape_label = hand_shape_quality_text(shape_report)
	var plan_eval = hand_plan_eval_for_seat_from_counts(seat, simulated_counts, simulated_tile_count)
	var plan = float(plan_eval.get("score", 0.0))
	var plan_report: Dictionary = plan_eval.get("report", {})
	var plan_label = str(plan_report.get("label", "标准"))
	var plan_suit = int(plan_report.get("suit", -1))
	var plan_bonus = float(plan_report.get("score_bonus", 0.0))
	var pressure = discard_pressure_score(tile, seat, visible_counts, eval_context)
	var risk_vector = tile_risk_vector(tile, seat, visible_counts, eval_context)
	var risk_summary = deal_in_risk_summary(tile, seat, visible_counts, risk_vector)
	var risk = float(risk_summary.get("score", 0.0))
	var risk_label_text = risk_label(risk)
	var feed_report = discard_feed_risk_report(tile, seat, visible_counts, eval_context)
	var feed_risk = float(feed_report.get("score", 0.0))
	var threat = opponent_tile_threat_score(tile, seat, visible_counts, risk_vector, eval_context)
	var safety = tile_safety_label(tile, seat, visible_counts, eval_context)
	var danger_source: Dictionary = risk_summary.get("danger_source", {})
	var defense = ai_defense_weight(seat, shanten, pressure_context)
	var safety_bonus = ai_safety_bonus(safety, defense, shanten)
	var emergency_defense = emergency_defense_adjustment(seat, shanten, safety, risk, feed_risk, pressure_context)
	var tenpai_bonus = 220.0 if shanten <= 0 else 0.0
	var score = -float(shanten) * 760.0
	score += (float(ukeire) * 26.0 + float(variety) * 18.0) * attack
	score += (shape * 0.30 + shape_quality * 0.42) * attack
	score += (plan * 0.42 + plan_bonus) * route_focus + tenpai_bonus * attack
	score += pressure * 1.12 - risk * defense * risk_factor + safety_bonus + emergency_defense
	score -= feed_risk * discard_feed_penalty_weight(defense, shanten) * risk_factor
	score += wait_value
	return {
		"tile": tile,
		"score": score,
		"shanten": shanten,
		"ukeire": ukeire,
		"variety": variety,
		"effective_tiles": effective_tiles,
		"effective_remaining": effective_remaining,
		"shape": shape,
		"shape_quality": shape_quality,
		"shape_label": shape_label,
		"plan": plan,
		"plan_label": plan_label,
		"plan_progress": int(plan_report.get("progress", 0)),
		"plan_suit": plan_suit,
		"plan_bonus": plan_bonus,
		"pressure": pressure,
		"risk": risk,
		"feed_risk": feed_risk,
		"feed_report": feed_report,
		"feed_text": discard_feed_risk_text(feed_report),
		"threat": threat,
		"safety_label": safety,
		"danger_source": danger_source,
		"danger_text": discard_danger_text(danger_source),
		"safety_bonus": safety_bonus,
		"emergency_defense": emergency_defense,
		"stance": ai_stance_label(defense, shanten),
		"defense": defense,
		"ai_profile": ai_profile_label(seat),
		"ai_profile_short": ai_profile_short_label(seat),
		"ai_attack_multiplier": attack,
		"ai_route_focus": route_focus,
		"ai_risk_factor": risk_factor,
		"risk_label": risk_label_text,
		"wait_value": wait_value,
		"wait_best_tile": wait_best_tile,
		"wait_best_fan": wait_best_fan,
		"wait_best_points": wait_best_points,
		"wait_average_points": wait_average_points,
		"wait_total_remaining": wait_total_remaining,
		"wait_adjusted_remaining": wait_adjusted_remaining,
		"wait_self_discarded": wait_self_discarded,
		"wait_quality_text": wait_quality_text,
		"reason_label": discard_reason_label(tile, [], {
			"safety_label": safety,
			"risk_label": risk_label_text,
			"plan_label": plan_label,
			"plan_suit": plan_suit,
			"shape_label": shape_label,
			"shanten": shanten,
			"wait_value": wait_value,
		}, original_counts),
	}

func empty_wait_value_metrics() -> Dictionary:
	var result = EMPTY_WAIT_VALUE_METRICS_TEMPLATE.duplicate(false)
	result["self_discarded"] = []
	return result

func wait_value_metrics(seat: int, hand: Array, open_melds: int, shanten: int, effective_tiles: Array, remaining_by_tile: Dictionary, effective_tiles_are_winning: bool = false, self_discarded_lookup_snapshot: Dictionary = {}, attack_multiplier_snapshot: float = -1.0, wait_focus_snapshot: float = -1.0) -> Dictionary:
	if shanten > 0 or seat < 0 or seat >= players.size():
		return empty_wait_value_metrics()
	var result = empty_wait_value_metrics()
	var attack_base = attack_multiplier_snapshot if attack_multiplier_snapshot >= 0.0 else ai_total_attack_multiplier(seat)
	var wait_focus = wait_focus_snapshot if wait_focus_snapshot >= 0.0 else ai_wait_value_focus(seat)
	result["attack_multiplier"] = attack_base
	result["wait_focus"] = wait_focus
	var total_remaining = 0
	var weighted_points = 0.0
	var adjusted_remaining = 0.0
	var self_discarded_waits: Array[String] = []
	var self_discarded_lookup = self_discarded_lookup_snapshot if not self_discarded_lookup_snapshot.is_empty() else tile_presence_set(players[seat]["discards"])
	var best_tile = ""
	var best_fan = 0
	var best_points = 0
	var best_score = 0.0
	var winning_hand = hand.duplicate()
	for item in effective_tiles:
		var tile = str(item)
		var remaining = int(remaining_by_tile.get(tile, remaining_tile_count(tile, hand)))
		if remaining <= 0:
			continue
		winning_hand.append(tile)
		if not effective_tiles_are_winning and not is_complete_hand(winning_hand, open_melds):
			winning_hand.pop_back()
			continue
		var score_data = calculate_win_score_from_tiles(seat, winning_hand, false)
		winning_hand.pop_back()
		var fan = int(score_data.get("fan", 0))
		var points = int(score_data.get("points", 0))
		var self_discarded = self_discarded_lookup.has(tile)
		var wait_weight = 0.62 if self_discarded else 1.0
		if self_discarded:
			self_discarded_waits.append(tile)
		total_remaining += remaining
		adjusted_remaining += float(remaining) * wait_weight
		weighted_points += float(points * remaining) * wait_weight
		var candidate_best_score = float(points) + float(remaining) * 24.0 - (150.0 if self_discarded else 0.0)
		if candidate_best_score > best_score:
			best_tile = tile
			best_fan = fan
			best_points = points
			best_score = candidate_best_score
	if total_remaining <= 0:
		return result
	var average_points = weighted_points / max(1.0, adjusted_remaining)
	var attack_multiplier = attack_base * wait_focus
	var quality_penalty = wait_quality_penalty(total_remaining, self_discarded_waits.size(), effective_tiles.size())
	result["best_tile"] = best_tile
	result["best_fan"] = best_fan
	result["best_points"] = best_points
	result["total_remaining"] = total_remaining
	result["adjusted_remaining"] = adjusted_remaining
	result["average_points"] = average_points
	result["self_discarded"] = self_discarded_waits
	result["quality_penalty"] = quality_penalty
	result["quality_text"] = wait_quality_text_from_values(total_remaining, self_discarded_waits)
	result["score"] = max(0.0, (adjusted_remaining * 12.0 + float(effective_tiles.size()) * 16.0 + float(result["best_points"]) * 0.04 + average_points * 0.02 - quality_penalty) * attack_multiplier)
	return result

func wait_quality_penalty(total_remaining: int, self_discarded_count: int, wait_variety: int) -> float:
	var penalty = 0.0
	if total_remaining <= 2:
		penalty += float(3 - total_remaining) * 18.0
	if self_discarded_count > 0:
		var ratio = float(self_discarded_count) / max(1.0, float(wait_variety))
		penalty += 24.0 + 34.0 * ratio + float(self_discarded_count - 1) * 10.0
	return penalty

func wait_quality_text_from_values(total_remaining: int, self_discarded_waits: Array) -> String:
	var parts: Array[String] = []
	if total_remaining > 0:
		if total_remaining <= 2:
			parts.append("待薄%d张" % total_remaining)
		elif total_remaining >= 6:
			parts.append("待厚%d张" % total_remaining)
	if not self_discarded_waits.is_empty():
		var labels: Array[String] = []
		var label_count = min(2, self_discarded_waits.size())
		for i in range(label_count):
			labels.append(tile_label(str(self_discarded_waits[i])))
		var suffix = "等" if self_discarded_waits.size() > 2 else ""
		parts.append("回头待%s%s" % ["、".join(labels), suffix])
	return " ".join(parts)

func discard_report_for_tile(tile: String) -> Dictionary:
	if not player_ai_assist_enabled() or mode != "offline" or not can_self_discard() or tile == "":
		return {}
	var reports = current_human_advice if not current_human_advice.is_empty() else get_ai_discard_reports(0)
	for report in reports:
		if typeof(report) == TYPE_DICTIONARY and str(report.get("tile", "")) == tile:
			return report
	if not current_human_advice.is_empty():
		for report in get_ai_discard_reports(0):
			if typeof(report) == TYPE_DICTIONARY and str(report.get("tile", "")) == tile:
				return report
	return {}

func is_high_risk_discard_report(report: Dictionary) -> bool:
	if report.is_empty():
		return false
	if str(report.get("safety_label", "")) != "":
		return false
	return str(report.get("risk_label", "")) == "高" or float(report.get("risk", 0.0)) >= 31.0 or float(report.get("feed_risk", 0.0)) >= 34.0

func should_confirm_danger_discard(index: int, tile: String, report: Dictionary) -> bool:
	if not player_ai_assist_enabled():
		clear_pending_danger_discard()
		return false
	if not is_high_risk_discard_report(report):
		if pending_danger_discard_tile != "":
			clear_pending_danger_discard()
		return false
	if has_pending_danger_discard() and pending_danger_discard_tile == tile:
		return false
	pending_danger_discard_index = index
	pending_danger_discard_tile = tile
	pending_danger_discard_report = duplicate_ai_report(report, true)
	return true

func begin_danger_discard_confirmation(index: int, tile: String, report: Dictionary) -> void:
	pending_danger_discard_index = index
	pending_danger_discard_tile = tile
	pending_danger_discard_report = duplicate_ai_report(report, true)
	var message = pending_danger_discard_text()
	add_log(message)
	set_status(message)

func has_pending_danger_discard() -> bool:
	if not player_ai_assist_enabled():
		return false
	if pending_danger_discard_tile == "":
		return false
	if mode != "offline" or not can_self_discard():
		return false
	return count_tile(players[0]["hand"], pending_danger_discard_tile) > 0

func clear_pending_danger_discard() -> void:
	pending_danger_discard_index = -1
	pending_danger_discard_tile = ""
	pending_danger_discard_report.clear()

func pending_danger_discard_text() -> String:
	if pending_danger_discard_tile == "":
		return current_status_text()
	var report = pending_danger_discard_report if not pending_danger_discard_report.is_empty() else discard_report_for_tile(pending_danger_discard_tile)
	var alternatives = safe_discard_alternative_text(pending_danger_discard_tile)
	var details = discard_safety_text(report) if not report.is_empty() else "风险高"
	return "高危：再点确认打出%s · %s%s" % [
		tile_label(pending_danger_discard_tile),
		details,
		" · 可改打" + alternatives if alternatives != "" else "",
	]

func safe_discard_alternative_text(excluded_tile: String, limit: int = 2) -> String:
	var text := ""
	for report in safe_discard_alternative_reports(excluded_tile, limit):
		if text != "":
			text += "、"
		text += tile_label(str(report.get("tile", "")))
	return text

func safe_discard_alternative_reports(excluded_tile: String, limit: int = 2) -> Array:
	var result: Array = []
	if not player_ai_assist_enabled():
		return result
	var reports = current_human_advice if not current_human_advice.is_empty() else get_ai_discard_reports(0)
	for report in reports:
		if typeof(report) != TYPE_DICTIONARY:
			continue
		var tile = str(report.get("tile", ""))
		if tile == "" or tile == excluded_tile or count_tile(players[0]["hand"], tile) <= 0:
			continue
		var safety = str(report.get("safety_label", ""))
		var risk = str(report.get("risk_label", ""))
		if safety == "安" or safety == "现" or safety == "熟" or safety == "筋" or safety == "壁" or risk == "低":
			result.append(duplicate_ai_report(report, true))
		if result.size() >= limit:
			break
	return result

func safe_discard_button_color(report: Dictionary) -> Color:
	var safety = str(report.get("safety_label", ""))
	if safety != "":
		return tile_risk_color(safety)
	var risk = str(report.get("risk_label", "低"))
	return tile_risk_color(risk)

func safest_discard_report(excluded_tiles = []) -> Dictionary:
	if not player_ai_assist_enabled():
		return {}
	var excluded = discard_excluded_tile_set(excluded_tiles)
	var best: Dictionary = {}
	var best_score = -1000000.0
	for report in human_discard_reports():
		if typeof(report) != TYPE_DICTIONARY:
			continue
		var tile = str(report.get("tile", ""))
		if tile == "" or excluded.has(tile) or count_tile(players[0]["hand"], tile) <= 0:
			continue
		if not is_safety_candidate_report(report):
			continue
		var score = safest_discard_action_score(report)
		if best.is_empty() or score > best_score:
			best = duplicate_ai_report(report, true)
			best_score = score
	return best

func is_safety_candidate_report(report: Dictionary) -> bool:
	if report.is_empty():
		return false
	if str(report.get("safety_label", "")) != "":
		return true
	return str(report.get("risk_label", "")) == "低" and float(report.get("risk", 0.0)) < 18.0

func safest_discard_action_score(report: Dictionary) -> float:
	var base = 0.0
	match str(report.get("safety_label", "")):
		"安":
			base = 1000.0
		"现":
			base = 920.0
		"熟":
			base = 820.0
		"筋":
			base = 740.0
		"壁":
			base = 700.0
		_:
			base = 610.0 if str(report.get("risk_label", "")) == "低" else 0.0
	return base - float(report.get("risk", 0.0)) * 7.0 + float(report.get("score", 0.0)) * 0.025 + float(report.get("ukeire", 0)) * 0.4

func should_offer_safest_discard_button(recommended_report: Dictionary, safest_report: Dictionary) -> bool:
	if safest_report.is_empty() or str(safest_report.get("tile", "")) == "":
		return false
	if is_high_risk_discard_report(recommended_report):
		return true
	if str(recommended_report.get("stance", "")) == "防守" or str(safest_report.get("stance", "")) == "防守":
		return true
	var threat = opponent_threat_report(0)
	var level = str(threat.get("level", ""))
	return level == "高" or level == "危"

func safest_discard_button_text(report: Dictionary) -> String:
	return "最安%s" % tile_label(str(report.get("tile", "")))

func safest_discard_hint_text(recommended_report: Dictionary, safest_report: Dictionary) -> String:
	if not should_offer_safest_discard_button(recommended_report, safest_report):
		return ""
	var tile = str(safest_report.get("tile", ""))
	if tile == "":
		return ""
	return "最安打%s%s" % [tile_label(tile), discard_safety_text(safest_report)]

func suggest_human_discard() -> String:
	if not player_ai_assist_enabled() or mode != "offline" or not can_self_discard():
		return ""
	var reports = human_discard_reports()
	if reports.is_empty():
		return ""
	return str(reports[0].get("tile", ""))

func recommended_discard_report() -> Dictionary:
	if not player_ai_assist_enabled():
		return {}
	var reports = human_discard_reports()
	if reports.is_empty() or typeof(reports[0]) != TYPE_DICTIONARY:
		return {}
	return duplicate_ai_report(reports[0], true)

func human_discard_reports() -> Array:
	if not player_ai_assist_enabled() or mode != "offline" or not can_self_discard():
		return []
	return current_human_advice if not current_human_advice.is_empty() else get_ai_discard_reports(0)

func recommended_discard_button_text(tile: String) -> String:
	return "推荐%s" % tile_label(tile)

func recommended_discard_button_color(report: Dictionary) -> Color:
	var safety = str(report.get("safety_label", ""))
	if safety != "":
		return tile_risk_color(safety)
	if float(report.get("feed_risk", 0.0)) >= 34.0:
		return Color(0.76, 0.34, 0.18)
	var risk = str(report.get("risk_label", "低"))
	if risk == "高":
		return Color(0.76, 0.34, 0.18)
	return tile_risk_color(risk)

func discard_action_alternative_reports(excluded_tiles = [], limit: int = 2) -> Array:
	var result: Array = []
	if not player_ai_assist_enabled():
		return result
	var excluded = discard_excluded_tile_set(excluded_tiles)
	for report in human_discard_reports():
		if typeof(report) != TYPE_DICTIONARY:
			continue
		var tile = str(report.get("tile", ""))
		if tile == "" or excluded.has(tile) or count_tile(players[0]["hand"], tile) <= 0:
			continue
		if is_high_risk_discard_report(report):
			continue
		result.append(duplicate_ai_report(report, true))
		if result.size() >= limit:
			break
	return result

func discard_excluded_tile_set(excluded_tiles) -> Dictionary:
	var excluded: Dictionary = {}
	if typeof(excluded_tiles) == TYPE_ARRAY:
		for item in excluded_tiles:
			var tile = str(item)
			if tile != "":
				excluded[tile] = true
	elif str(excluded_tiles) != "":
		excluded[str(excluded_tiles)] = true
	return excluded

func alternative_discard_button_text(report: Dictionary) -> String:
	return "备%s" % tile_label(str(report.get("tile", "")))

func alternative_discard_button_color(report: Dictionary) -> Color:
	var safety = str(report.get("safety_label", ""))
	if safety != "":
		return tile_risk_color(safety)
	return tile_risk_color(str(report.get("risk_label", "低")))

func human_hint_text(limit: int = 2) -> String:
	if not player_ai_assist_enabled() or mode != "offline" or not can_self_discard():
		return current_status_text()
	var reports = human_discard_reports()
	if reports.is_empty():
		return "整理手牌"
	var best: Dictionary = reports[0]
	var parts: Array[String] = []
	parts.append("建议打%s" % tile_label(str(best.get("tile", ""))))
	parts.append(shanten_label(int(best.get("shanten", 8))))
	var reason_hint = str(best.get("reason_label", ""))
	if reason_hint != "":
		parts.append(reason_hint)
	var plan_hint = hand_plan_text(best)
	if plan_hint != "":
		parts.append(plan_hint)
	var shape_hint = str(best.get("shape_label", ""))
	if shape_hint != "":
		parts.append(shape_hint)
	parts.append("进张%d/%d" % [int(best.get("ukeire", 0)), int(best.get("variety", 0))])
	var tile_hint = effective_tile_text(best, 4)
	if tile_hint != "":
		parts.append(tile_hint)
		var value_hint = wait_value_text(best)
		if value_hint != "":
			parts.append(value_hint)
		var quality_hint = wait_quality_text(best)
		if quality_hint != "":
			parts.append(quality_hint)
		parts.append(discard_safety_text(best))
	parts.append("模式%s" % str(best.get("stance", "均衡")))
	var score_text = score_strategy_text(0)
	if score_text != "":
		parts.append(score_text)
	var safest_hint = safest_discard_hint_text(best, safest_discard_report())
	if safest_hint != "":
		parts.append(safest_hint)
	var alternatives = discard_alternative_text(reports, limit)
	if alternatives != "":
		parts.append("备选%s" % alternatives)
	var threat = opponent_threat_summary(0)
	if threat != "":
		parts.append("防守%s" % threat)
	return " · ".join(parts)

func discard_alternative_text(reports: Array, limit: int = 2) -> String:
	var options: Array[String] = []
	for i in range(1, min(reports.size(), limit + 1)):
		var report: Dictionary = reports[i]
		var reason = str(report.get("reason_label", ""))
		options.append("%s%s/%d%s%s" % [
			tile_label(str(report.get("tile", ""))),
			shanten_label(int(report.get("shanten", 8))),
			int(report.get("ukeire", 0)),
			discard_safety_short_text(report),
			"/" + reason if reason != "" else "",
		])
	return "、".join(options)

func discard_safety_short_text(report: Dictionary) -> String:
	var safety = str(report.get("safety_label", ""))
	if safety != "":
		return safety
	return str(report.get("risk_label", "中"))

func recommended_claim_report() -> Dictionary:
	if not player_ai_assist_enabled() or mode != "offline" or offline_phase != "pending_claim":
		return {}
	var options: Array = offline_pending_claim.get("options", [])
	var tile = str(offline_pending_claim.get("tile", ""))
	if bool(offline_pending_claim.get("rob_gang", false)) and options.has("hu"):
		return {"claim": "hu", "label": claim_label("hu"), "allow": true, "tile": tile}
	if options.has("hu"):
		return {"claim": "hu", "label": claim_label("hu"), "allow": true, "tile": tile}
	var candidates = human_claim_candidate_reports()
	if candidates.is_empty():
		return {"claim": "pass", "label": "过", "allow": true, "tile": tile}
	var best: Dictionary = candidates[0]
	if not bool(best.get("allow", false)):
		return {"claim": "pass", "label": "过", "allow": true, "tile": tile, "declined": duplicate_claim_report(best)}
	return duplicate_claim_report(best)

func claim_action_button_text(claim: String, chi_choice: Dictionary, recommendation: Dictionary) -> String:
	var base = chi_choice_label(chi_choice) if claim == "chi" and not chi_choice.is_empty() else claim_label(claim)
	return "荐%s" % base if is_recommended_claim_action(claim, chi_choice, recommendation) else base

func is_recommended_claim_action(claim: String, chi_choice: Dictionary, recommendation: Dictionary) -> bool:
	if recommendation.is_empty() or str(recommendation.get("claim", "")) != claim:
		return false
	if claim != "chi":
		return true
	var recommended_choice = recommendation.get("chi_choice", {})
	if typeof(recommended_choice) != TYPE_DICTIONARY:
		return chi_choice.is_empty()
	if chi_choice.is_empty():
		return false
	return same_tile_list(chi_choice.get("meld", []), recommended_choice.get("meld", [])) and same_tile_list(chi_choice.get("needed", []), recommended_choice.get("needed", []))

func claim_action_button_color(claim: String, recommended: bool) -> Color:
	return Color(0.88, 0.61, 0.20) if recommended else claim_color(claim)

func pass_claim_button_text(recommendation: Dictionary) -> String:
	return "建议过" if str(recommendation.get("claim", "")) == "pass" else "过"

func pass_claim_button_color(recommendation: Dictionary) -> Color:
	return Color(0.25, 0.58, 0.48) if str(recommendation.get("claim", "")) == "pass" else Color(0.38, 0.43, 0.44)

func human_claim_hint_text() -> String:
	if mode != "offline" or offline_phase != "pending_claim":
		return current_status_text()
	if not player_ai_assist_enabled():
		var tile = str(offline_pending_claim.get("tile", ""))
		return "可响应%s · %s" % [
			tile_label(tile) if tile != "" else "",
			claim_options_text(offline_pending_claim),
		]
	if bool(offline_pending_claim.get("rob_gang", false)):
		return "建议胡 · 抢杠机会优先确认"
	var options: Array = offline_pending_claim.get("options", [])
	var tile = str(offline_pending_claim.get("tile", ""))
	if tile == "":
		return "等待响应"
	if options.has("hu"):
		return "建议胡%s · 胡牌优先" % tile_label(tile)
	var candidates = human_claim_candidate_reports()
	if candidates.is_empty():
		return "建议过 · 没有明显收益"
	var best: Dictionary = candidates[0]
	if not bool(best.get("allow", false)):
		return "建议过 · %s" % claim_report_reason_text(best)
	var forced = str(best.get("forced_discard", ""))
	var forced_text = ""
	if forced != "":
		forced_text = " · 后续打%s %s" % [tile_label(forced), forced_discard_risk_text(best)]
	return "建议%s · %s%s" % [
		str(best.get("label", claim_label(str(best.get("claim", ""))))),
		claim_report_reason_text(best),
		forced_text,
	]

func human_claim_candidate_reports() -> Array:
	var tile = str(offline_pending_claim.get("tile", ""))
	var candidates: Array = []
	var claim_context: Dictionary = {}
	for claim in offline_pending_claim.get("options", []):
		var claim_name = str(claim)
		if claim_name == "hu":
			continue
		if claim_name == "chi":
			var chi_choices: Array = offline_pending_claim.get("chi_choices", [])
			if chi_choices.is_empty():
				if claim_context.is_empty():
					claim_context = make_ai_claim_context(0)
				var choice = best_chi_choice_from_counts(claim_context.get("hand_counts", []), tile)
				if not choice.is_empty():
					var report = build_ai_claim_report(0, "chi", tile, choice, claim_context)
					report["label"] = chi_choice_label(choice)
					report["chi_choice"] = choice
					candidates.append(report)
			else:
				for choice in chi_choices:
					if typeof(choice) != TYPE_DICTIONARY:
						continue
					if claim_context.is_empty():
						claim_context = make_ai_claim_context(0)
					var report = build_ai_claim_report(0, "chi", tile, choice, claim_context)
					report["label"] = chi_choice_label(choice)
					report["chi_choice"] = choice
					candidates.append(report)
		else:
			if claim_context.is_empty():
				claim_context = make_ai_claim_context(0)
			var report = build_ai_claim_report(0, claim_name, tile, {}, claim_context)
			report["label"] = claim_label(claim_name)
			candidates.append(report)
	candidates.sort_custom(func(a, b):
		var score_a = human_claim_report_score(a)
		var score_b = human_claim_report_score(b)
		if is_equal_approx(score_a, score_b):
			return claim_priority(str(a.get("claim", ""))) > claim_priority(str(b.get("claim", "")))
		return score_a > score_b
	)
	return candidates

func human_claim_report_score(report: Dictionary) -> float:
	var score = ai_claim_action_score(report, 0)
	if not bool(report.get("allow", false)):
		score -= 120.0
	if str(report.get("reason", "")) == "高压防守":
		score -= 80.0
	return score

func claim_report_reason_text(report: Dictionary) -> String:
	var before = int(report.get("before_shanten", 8))
	var after = int(report.get("after_shanten", 8))
	var reason = str(report.get("reason", "牌型收益不足"))
	var shape_gain = float(report.get("shape_gain", 0.0))
	if reason == "降向听":
		return "%s到%s" % [shanten_label(before), shanten_label(after)]
	if reason == "高压防守":
		return "高压防守，吃碰后风险偏高"
	if reason == "保七对":
		return "保七对，不拆对子路线"
	if reason == "牌型收益":
		return "牌型收益+%d" % int(round(shape_gain))
	if reason == "升向听":
		return "会升向听"
	return reason

func forced_discard_risk_text(report: Dictionary) -> String:
	var safety = str(report.get("forced_discard_safety", ""))
	if safety != "":
		return discard_safety_text({"safety_label": safety, "risk_label": risk_label(float(report.get("forced_discard_risk", 0.0)))})
	return "风险%s" % risk_label(float(report.get("forced_discard_risk", 0.0)))

func ai_advice_summary(seat: int, limit: int = 3) -> String:
	var reports = current_human_advice if seat == 0 and not current_human_advice.is_empty() else get_ai_discard_reports(seat)
	if reports.is_empty():
		return "整理手牌"
	var best: Dictionary = reports[0]
	var lines: Array[String] = []
	lines.append(ai_discard_brief(best))
	lines.append("模式 " + str(best.get("stance", "均衡")))
	var reason_hint = str(best.get("reason_label", ""))
	if reason_hint != "":
		lines.append("理由 " + reason_hint)
	var plan_hint = hand_plan_text(best)
	if plan_hint != "":
		lines.append(plan_hint)
	var shape_hint = str(best.get("shape_label", ""))
	if shape_hint != "":
		lines.append(shape_hint)
	var score_text = score_strategy_text(seat)
	if score_text != "":
		lines.append(score_text)
	if seat == 0:
		var safest_hint = safest_discard_hint_text(best, safest_discard_report())
		if safest_hint != "":
			lines.append(safest_hint)
	var options: Array[String] = []
	for i in range(min(limit, reports.size())):
		var report: Dictionary = reports[i]
		var reason = str(report.get("reason_label", ""))
		options.append("%s %s/%d%s" % [
			tile_label(str(report.get("tile", ""))),
			shanten_label(int(report.get("shanten", 8))),
			int(report.get("ukeire", 0)),
			"/" + reason if reason != "" else "",
		])
	var best_tiles = effective_tile_text(best, 6)
	if best_tiles != "":
		lines.append(best_tiles)
	var value_hint = wait_value_text(best)
	if value_hint != "":
		lines.append(value_hint)
	var quality_hint = wait_quality_text(best)
	if quality_hint != "":
		lines.append(quality_hint)
	lines.append("备选 " + "  ".join(options))
	var threat = opponent_threat_summary(seat)
	if threat != "":
		lines.append("防守 " + threat)
	return "\n".join(lines)

func ai_discard_brief(report: Dictionary) -> String:
	var primary_parts: Array[String] = [
		shanten_label(int(report.get("shanten", 8))),
	]
	var tile_hint = effective_tile_text(report, 3)
	var value_hint = wait_value_text(report)
	var quality_hint = wait_quality_text(report)
	var plan_hint = hand_plan_text(report)
	var shape_hint = str(report.get("shape_label", ""))
	var reason_hint = str(report.get("reason_label", ""))
	if reason_hint != "":
		primary_parts.append(reason_hint)
	if plan_hint != "":
		primary_parts.append(plan_hint)
	if shape_hint != "":
		primary_parts.append(shape_hint)
	var draw_parts: Array[String] = [
		"进张%d/%d" % [
			int(report.get("ukeire", 0)),
			int(report.get("variety", 0)),
		],
	]
	if tile_hint != "":
		draw_parts.append(tile_hint)
	if value_hint != "":
		draw_parts.append(value_hint)
	if quality_hint != "":
		draw_parts.append(quality_hint)
	return "推荐打%s · %s · %s · %s" % [
		tile_label(str(report.get("tile", ""))),
		" · ".join(primary_parts),
		" · ".join(draw_parts),
		discard_safety_text(report),
	]

func effective_tile_text(report: Dictionary, limit: int = 5) -> String:
	var tiles: Array = report.get("effective_tiles", [])
	if tiles.is_empty():
		return ""
	var remaining_by_tile: Dictionary = report.get("effective_remaining", {})
	var labels: Array[String] = []
	var label_count = min(limit, tiles.size())
	for i in range(label_count):
		labels.append(effective_tile_label(str(tiles[i]), remaining_by_tile))
	var suffix = "等%d种" % tiles.size() if tiles.size() > limit else ""
	var prefix = "听" if int(report.get("shanten", 8)) <= 0 else "进"
	return "%s%s%s" % [prefix, "、".join(labels), suffix]

func effective_tile_label(tile: String, remaining_by_tile: Dictionary) -> String:
	var remaining = int(remaining_by_tile.get(tile, 0))
	if remaining <= 0:
		return tile_label(tile)
	return "%s%d张" % [tile_label(tile), remaining]

func hand_plan_text(report: Dictionary) -> String:
	var label = str(report.get("plan_label", "标准"))
	if label == "" or label == "标准":
		return ""
	return "路线%s" % label

func discard_reason_label(tile: String, original_hand: Array, report: Dictionary, original_counts_snapshot: Array = []) -> String:
	var safety = str(report.get("safety_label", ""))
	if safety != "":
		return "防守" + discard_safety_short_text(report)
	if is_plan_offcut(tile, report, original_hand, original_counts_snapshot):
		return "保路线"
	if is_discard_isolated(tile, original_hand, original_counts_snapshot):
		return "切孤张"
	if int(report.get("shanten", 8)) <= 0 and float(report.get("wait_value", 0.0)) > 0.0:
		return "成听牌"
	if str(report.get("shape_label", "")) != "":
		return "保好形"
	return "提效率"

func is_plan_offcut(tile: String, report: Dictionary, original_hand: Array = [], original_counts_snapshot: Array = []) -> bool:
	var label = str(report.get("plan_label", "标准"))
	if label == "标准" or tile == "":
		return false
	if label == "七对":
		if not original_counts_snapshot.is_empty():
			return tile_count_from_counts(tile, original_counts_snapshot) == 1
		return not original_hand.is_empty() and count_tile(original_hand, tile) == 1
	if label == "字一色":
		return not is_honor_tile(tile)
	if label == "清一色":
		return is_number_tile(tile) and tile_suit_index(tile) != int(report.get("plan_suit", -1))
	if label == "混一色":
		return is_number_tile(tile) and tile_suit_index(tile) != int(report.get("plan_suit", -1))
	if label == "碰碰胡":
		return is_number_tile(tile) and not is_terminal_or_honor(tile)
	if label == "十三幺":
		return not is_thirteen_orphans_tile(tile)
	if label == "一条龙":
		return not is_number_tile(tile) or tile_suit_index(tile) != int(report.get("plan_suit", -1))
	if label == "断幺九":
		return not is_simple_number_tile(tile)
	if label == "大三元" or label == "小三元":
		return not DRAGON_CODES.has(tile)
	if label == "大四喜" or label == "小四喜":
		return not WIND_CODES.has(tile)
	return false

func is_discard_isolated(tile: String, original_hand: Array, original_counts_snapshot: Array = []) -> bool:
	var counts = original_counts_snapshot if not original_counts_snapshot.is_empty() else tile_counts(original_hand)
	var index = tile_index(tile)
	if index < 0:
		return false
	return is_isolated_shape_tile(counts, index)

func wait_value_text(report: Dictionary) -> String:
	if int(report.get("shanten", 8)) > 0:
		return ""
	var best_tile = str(report.get("wait_best_tile", ""))
	var points = int(report.get("wait_best_points", 0))
	var fan = int(report.get("wait_best_fan", 0))
	if best_tile == "" or points <= 0 or fan <= 0:
		return ""
	return "价值%s%d番%d分" % [tile_label(best_tile), fan, points]

func wait_quality_text(report: Dictionary) -> String:
	if int(report.get("shanten", 8)) > 0:
		return ""
	var text = str(report.get("wait_quality_text", ""))
	if text != "":
		return text
	var total_remaining = int(report.get("wait_total_remaining", 0))
	var self_discarded_waits: Array = report.get("wait_self_discarded", [])
	return wait_quality_text_from_values(total_remaining, self_discarded_waits)

func discard_safety_text(report: Dictionary) -> String:
	var feed = str(report.get("feed_text", ""))
	var suffix = " · " + feed if feed != "" else ""
	match str(report.get("safety_label", "")):
		"安":
			return "全现物" + suffix
		"现":
			return "主现物" + suffix
		"熟":
			return "熟张" + suffix
		"筋":
			return "筋线" + suffix
		"壁":
			return "壁牌" + suffix
	var danger = discard_danger_text(report.get("danger_source", {}))
	var extra_parts: Array[String] = []
	if danger != "":
		extra_parts.append(danger)
	if feed != "":
		extra_parts.append(feed)
	return "风险%s%s" % [
		str(report.get("risk_label", "中")),
		" · " + " · ".join(extra_parts) if not extra_parts.is_empty() else "",
	]

func ai_safety_bonus(safety: String, defense: float, shanten: int) -> float:
	if safety == "":
		return 0.0
	var urgency = clamp((defense - 0.70) / 1.20, 0.0, 1.0)
	if shanten <= 0:
		urgency *= 0.25
	elif shanten == 1:
		urgency *= 0.55
	var base = 22.0
	if safety == "安":
		base = 72.0
	elif safety == "现":
		base = 46.0
	elif safety == "熟":
		base = 36.0
	elif safety == "壁":
		base = 28.0
	return base * urgency

func emergency_defense_adjustment(seat: int, shanten: int, safety: String, risk: float, feed_risk: float, pressure_context: Dictionary = {}) -> float:
	if seat < 0 or seat >= players.size() or shanten <= 1:
		return 0.0
	var readiness = float(pressure_context.get("readiness_pressure", 0.0)) if pressure_context.has("readiness_pressure") else opponent_readiness_pressure_score(seat)
	var threat_rank = int(pressure_context.get("threat_rank", -1))
	if threat_rank < 0:
		var threat_level = str(opponent_threat_report(seat).get("level", ""))
		threat_rank = threat_level_rank(threat_level)
	if readiness < 9.5 and threat_rank < 2:
		return 0.0
	var scale = clamp(0.55 + max(0.0, readiness - 7.0) / 6.0 + float(threat_rank) * 0.18, 0.55, 1.85)
	var safety_value = 0.0
	match safety:
		"安":
			safety_value = 280.0
		"现":
			safety_value = 230.0
		"熟":
			safety_value = 175.0
		"筋":
			safety_value = 125.0
		"壁":
			safety_value = 110.0
	var danger_penalty = risk * 0.84 + feed_risk * 0.34
	if risk >= 31.0:
		danger_penalty += 130.0
	elif risk >= 18.0:
		danger_penalty += 58.0
	return (safety_value - danger_penalty) * scale

func ai_stance_label(defense: float, shanten: int) -> String:
	if shanten <= 0 and defense < 1.0:
		return "进攻"
	if defense >= 1.45:
		return "防守"
	if shanten <= 1:
		return "进攻"
	return "均衡"

func evaluate_ai_hand(hand: Array) -> float:
	return evaluate_ai_hand_from_counts(tile_counts(hand))

func evaluate_ai_hand_from_counts(counts: Array) -> float:
	var score = 0.0
	for i in range(TILE_CODES.size()):
		var amount = int(counts[i])
		if amount == 0:
			continue
		score += tile_base_value(i) * amount
		if amount >= 2:
			score += 22.0
		if amount >= 3:
			score += 42.0
		if amount == 4:
			score += 10.0
		if i < 27:
			if has_neighbor(counts, i, -1):
				score += 9.0
			if has_neighbor(counts, i, 1):
				score += 9.0
			if has_neighbor(counts, i, -2):
				score += 5.0
			if has_neighbor(counts, i, 2):
				score += 5.0
	for start in NUMBER_SUIT_STARTS:
		for rank in range(0, 7):
			var index = start + rank
			if int(counts[index]) > 0 and int(counts[index + 1]) > 0 and int(counts[index + 2]) > 0:
				score += 28.0
	return score

func ai_hand_shape_metrics_from_counts(counts: Array) -> Dictionary:
	var value = 0.0
	var sequences = 0
	var ryanmen = 0
	var kanchan = 0
	var penchan = 0
	var pairs = 0
	var triplets = 0
	var isolated = 0
	for i in range(TILE_CODES.size()):
		var amount = int(counts[i])
		if amount == 0:
			continue
		value += tile_base_value(i) * amount
		if amount >= 2:
			value += 22.0
			pairs += 1
		if amount >= 3:
			value += 42.0
			triplets += 1
		if amount == 4:
			value += 10.0
		if i < 27:
			if has_neighbor(counts, i, -1):
				value += 9.0
			if has_neighbor(counts, i, 1):
				value += 9.0
			if has_neighbor(counts, i, -2):
				value += 5.0
			if has_neighbor(counts, i, 2):
				value += 5.0
		if is_isolated_shape_tile(counts, i):
			isolated += amount
	for start in NUMBER_SUIT_STARTS:
		for rank in range(0, 7):
			var index = start + rank
			if int(counts[index]) > 0 and int(counts[index + 1]) > 0 and int(counts[index + 2]) > 0:
				value += 28.0
				sequences += 1
		for rank in range(0, 8):
			if int(counts[start + rank]) <= 0 or int(counts[start + rank + 1]) <= 0:
				continue
			if rank == 0 or rank == 7:
				penchan += 1
			else:
				ryanmen += 1
		for rank in range(0, 7):
			if int(counts[start + rank]) > 0 and int(counts[start + rank + 2]) > 0:
				kanchan += 1
	var quality_score = float(sequences) * 30.0 + float(ryanmen) * 24.0 + float(kanchan) * 13.0 + float(penchan) * 9.0 + float(pairs) * 14.0 + float(triplets) * 20.0 - float(isolated) * 8.0
	return {
		"value": value,
		"quality_report": {
			"score": quality_score,
			"sequences": sequences,
			"ryanmen": ryanmen,
			"kanchan": kanchan,
			"penchan": penchan,
			"pairs": pairs,
			"triplets": triplets,
			"isolated": isolated,
		},
	}

func hand_shape_quality_report(hand: Array) -> Dictionary:
	return hand_shape_quality_report_from_counts(tile_counts(hand))

func hand_shape_quality_report_from_counts(counts: Array) -> Dictionary:
	var sequences = 0
	var ryanmen = 0
	var kanchan = 0
	var penchan = 0
	var pairs = 0
	var triplets = 0
	var isolated = 0
	for i in range(TILE_CODES.size()):
		var amount = int(counts[i])
		if amount <= 0:
			continue
		if amount >= 2:
			pairs += 1
		if amount >= 3:
			triplets += 1
		if is_isolated_shape_tile(counts, i):
			isolated += amount
	for start in NUMBER_SUIT_STARTS:
		for rank in range(0, 7):
			if int(counts[start + rank]) > 0 and int(counts[start + rank + 1]) > 0 and int(counts[start + rank + 2]) > 0:
				sequences += 1
		for rank in range(0, 8):
			if int(counts[start + rank]) <= 0 or int(counts[start + rank + 1]) <= 0:
				continue
			if rank == 0 or rank == 7:
				penchan += 1
			else:
				ryanmen += 1
		for rank in range(0, 7):
			if int(counts[start + rank]) > 0 and int(counts[start + rank + 2]) > 0:
				kanchan += 1
	var score = float(sequences) * 30.0 + float(ryanmen) * 24.0 + float(kanchan) * 13.0 + float(penchan) * 9.0 + float(pairs) * 14.0 + float(triplets) * 20.0 - float(isolated) * 8.0
	return {
		"score": score,
		"sequences": sequences,
		"ryanmen": ryanmen,
		"kanchan": kanchan,
		"penchan": penchan,
		"pairs": pairs,
		"triplets": triplets,
		"isolated": isolated,
	}

func is_isolated_shape_tile(counts: Array, index: int) -> bool:
	if index < 0 or index >= TILE_CODES.size() or int(counts[index]) <= 0:
		return false
	if int(counts[index]) >= 2:
		return false
	if index >= 27:
		return true
	for delta in SHAPE_NEIGHBOR_DELTAS:
		if has_neighbor(counts, index, delta):
			return false
	return true

func hand_shape_quality_text(report: Dictionary) -> String:
	var parts: Array[String] = []
	var ryanmen = int(report.get("ryanmen", 0))
	var kanchan = int(report.get("kanchan", 0))
	var penchan = int(report.get("penchan", 0))
	var pairs = int(report.get("pairs", 0))
	if ryanmen > 0:
		parts.append("两面%d" % ryanmen)
	if kanchan > 0:
		parts.append("坎%d" % kanchan)
	if penchan > 0:
		parts.append("边%d" % penchan)
	if pairs > 0:
		parts.append("对%d" % pairs)
	if parts.is_empty():
		return ""
	return "形" + join_limited_strings(parts, " ", 3)

func calculate_min_shanten(hand: Array, open_melds: int = 0) -> int:
	return calculate_min_shanten_from_counts(tile_counts(hand), open_melds)

func calculate_min_shanten_from_counts(counts: Array, open_melds: int = 0) -> int:
	var cache_key = shanten_cache_key(counts, open_melds)
	if shanten_cache.has(cache_key):
		shanten_cache_hits += 1
		return int(shanten_cache[cache_key])
	shanten_cache_misses += 1
	var memo: Dictionary = {}
	var standard = standard_shanten_search(counts, open_melds, 0, false, memo)
	if open_melds == 0:
		standard = min(standard, seven_pairs_shanten(counts))
		standard = min(standard, thirteen_orphans_shanten(counts))
	store_shanten_cache(cache_key, standard)
	return standard

func shanten_cache_key(counts: Array, open_melds: int) -> String:
	return "%d:%s" % [open_melds, counts_compact_key(counts)]

func counts_compact_key(counts: Array) -> String:
	var bytes := PackedByteArray()
	bytes.resize(counts.size())
	for i in range(counts.size()):
		var amount = int(counts[i])
		if amount < 0 or amount > 9:
			var fallback: Array[String] = []
			for count in counts:
				fallback.append(str(int(count)))
			return "".join(fallback)
		bytes[i] = 48 + amount
	return bytes.get_string_from_ascii()

func store_shanten_cache(key: String, value: int) -> void:
	if key == "":
		return
	if not shanten_cache.has(key):
		shanten_cache_order.append(key)
	shanten_cache[key] = value
	while shanten_cache_order.size() > SHANTEN_CACHE_LIMIT:
		var oldest = shanten_cache_order.pop_front()
		shanten_cache.erase(oldest)

func clear_shanten_cache() -> void:
	shanten_cache.clear()
	shanten_cache_order.clear()
	shanten_cache_hits = 0
	shanten_cache_misses = 0

func standard_shanten_search(counts: Array, melds: int, taatsu: int, has_pair: bool, memo: Dictionary) -> int:
	var first = -1
	for i in range(TILE_CODES.size()):
		if int(counts[i]) > 0:
			first = i
			break
	if first == -1:
		var capped_taatsu = min(taatsu, max(0, 4 - melds))
		return 8 - melds * 2 - capped_taatsu - (1 if has_pair else 0)
	var key = shanten_memo_key(counts, melds, taatsu, has_pair)
	if memo.has(key):
		return int(memo[key])
	var best = 8
	counts[first] = int(counts[first]) - 1
	best = min(best, standard_shanten_search(counts, melds, taatsu, has_pair, memo))
	counts[first] = int(counts[first]) + 1
	if int(counts[first]) >= 3:
		counts[first] = int(counts[first]) - 3
		best = min(best, standard_shanten_search(counts, melds + 1, taatsu, has_pair, memo))
		counts[first] = int(counts[first]) + 3
	if can_sequence_from(counts, first):
		counts[first] = int(counts[first]) - 1
		counts[first + 1] = int(counts[first + 1]) - 1
		counts[first + 2] = int(counts[first + 2]) - 1
		best = min(best, standard_shanten_search(counts, melds + 1, taatsu, has_pair, memo))
		counts[first] = int(counts[first]) + 1
		counts[first + 1] = int(counts[first + 1]) + 1
		counts[first + 2] = int(counts[first + 2]) + 1
	if int(counts[first]) >= 2:
		counts[first] = int(counts[first]) - 2
		if not has_pair:
			best = min(best, standard_shanten_search(counts, melds, taatsu, true, memo))
		best = min(best, standard_shanten_search(counts, melds, taatsu + 1, has_pair, memo))
		counts[first] = int(counts[first]) + 2
	if first < 27:
		if same_suit_index(first, first + 1) and int(counts[first + 1]) > 0:
			counts[first] = int(counts[first]) - 1
			counts[first + 1] = int(counts[first + 1]) - 1
			best = min(best, standard_shanten_search(counts, melds, taatsu + 1, has_pair, memo))
			counts[first] = int(counts[first]) + 1
			counts[first + 1] = int(counts[first + 1]) + 1
		if same_suit_index(first, first + 2) and int(counts[first + 2]) > 0:
			counts[first] = int(counts[first]) - 1
			counts[first + 2] = int(counts[first + 2]) - 1
			best = min(best, standard_shanten_search(counts, melds, taatsu + 1, has_pair, memo))
			counts[first] = int(counts[first]) + 1
			counts[first + 2] = int(counts[first + 2]) + 1
	memo[key] = best
	return best

func shanten_memo_key(counts: Array, melds: int, taatsu: int, has_pair: bool) -> String:
	return "%d:%d:%d:%s" % [melds, taatsu, 1 if has_pair else 0, counts_compact_key(counts)]

func same_suit_index(a: int, b: int) -> bool:
	if a < 0 or b < 0 or a >= 27 or b >= 27:
		return false
	return a / 9 == b / 9

func seven_pairs_shanten(counts: Array) -> int:
	var pairs = 0
	var unique = 0
	for count in counts:
		var amount = int(count)
		if amount <= 0:
			continue
		unique += 1
		pairs += min(2, amount / 2)
	return 6 - pairs + max(0, 7 - unique)

func thirteen_orphans_shanten(counts: Array) -> int:
	if not tile_metadata_ready:
		setup_tile_order()
	var unique = 0
	var has_pair = false
	for index in thirteen_orphans_indices:
		if index < 0 or index >= counts.size():
			continue
		var amount = int(counts[index])
		if amount > 0:
			unique += 1
		if amount >= 2:
			has_pair = true
	return THIRTEEN_ORPHANS_CODES.size() - unique - (1 if has_pair else 0)

func effective_tile_count(hand: Array, open_melds: int, seat: int) -> int:
	return int(effective_tile_metrics(hand, open_melds, seat).get("count", 0))

func effective_tile_variety(hand: Array, open_melds: int, seat: int) -> int:
	return int(effective_tile_metrics(hand, open_melds, seat).get("variety", 0))

func effective_tile_metrics(hand: Array, open_melds: int, seat: int, known_shanten: int = 99, visible_counts_snapshot: Array = [], hand_counts_snapshot: Array = []) -> Dictionary:
	var hand_counts = hand_counts_snapshot if not hand_counts_snapshot.is_empty() else tile_counts(hand)
	var current_shanten = known_shanten if known_shanten != 99 else calculate_min_shanten_from_counts(hand_counts, open_melds)

	# 缓存键：向听数 + 手牌计数
	var cache_key = "%d:%d:%s" % [current_shanten, open_melds, counts_compact_key(hand_counts)]
	if effective_tiles_cache.has(cache_key):
		effective_tiles_cache_hits += 1
		# 移到最近使用
		effective_tiles_cache_order.erase(cache_key)
		effective_tiles_cache_order.append(cache_key)
		return effective_tiles_cache[cache_key]

	effective_tiles_cache_misses += 1
	var next_tile_count = hand.size() + 1
	var visible_counts = visible_counts_snapshot if not visible_counts_snapshot.is_empty() else visible_tile_counts()
	var total = 0
	var variety = 0
	var tiles: Array[String] = []
	var remaining_by_tile: Dictionary = {}
	for i in range(TILE_CODES.size()):
		var tile = TILE_CODES[i]
		var remaining = remaining_tile_count_from_counts(i, visible_counts, hand_counts)
		if remaining <= 0:
			continue
		hand_counts[i] = int(hand_counts[i]) + 1
		var improves = false
		if current_shanten <= 0:
			improves = is_complete_hand_from_counts(hand_counts, next_tile_count, open_melds)
		if not improves:
			improves = calculate_min_shanten_from_counts(hand_counts, open_melds) < current_shanten
		hand_counts[i] = int(hand_counts[i]) - 1
		if improves:
			total += remaining
			variety += 1
			tiles.append(tile)
			remaining_by_tile[tile] = remaining
	sort_effective_tiles_by_remaining(tiles, remaining_by_tile)

	var result = {"count": total, "variety": variety, "tiles": tiles, "remaining_by_tile": remaining_by_tile}

	# 存入缓存
	effective_tiles_cache[cache_key] = result
	effective_tiles_cache_order.append(cache_key)
	while effective_tiles_cache_order.size() > EFFECTIVE_TILES_CACHE_LIMIT:
		var old_key = effective_tiles_cache_order.pop_front()
		effective_tiles_cache.erase(old_key)

	return result

func sort_effective_tiles_by_remaining(tiles: Array, remaining_by_tile: Dictionary) -> void:
	tiles.sort_custom(func(a, b):
		var remaining_a = int(remaining_by_tile.get(str(a), 0))
		var remaining_b = int(remaining_by_tile.get(str(b), 0))
		if remaining_a == remaining_b:
			return tile_sort_index(str(a)) < tile_sort_index(str(b))
		return remaining_a > remaining_b
	)

func remaining_tile_count_from_counts(index: int, visible_counts: Array, hand_counts: Array) -> int:
	if index < 0 or index >= TILE_CODES.size():
		return 0
	return max(0, 4 - int(visible_counts[index]) - int(hand_counts[index]))

func remaining_tile_count(tile: String, hand: Array) -> int:
	return max(0, 4 - visible_tile_count(tile) - count_tile(hand, tile))

func hand_plan_score(hand: Array) -> float:
	return hand_plan_score_from_counts(tile_counts(hand), hand.size())

func hand_plan_score_from_counts(counts: Array, tile_count: int) -> float:
	return hand_plan_score_from_features(counts, hand_plan_features_from_counts(counts, tile_count))

func rank_mask_unique_count(mask: int) -> int:
	var total = 0
	while mask > 0:
		total += mask & 1
		mask >>= 1
	return total

func hand_plan_features_from_counts(counts: Array, tile_count: int) -> Dictionary:
	var suit_counts = [0, 0, 0]
	var suit_rank_masks = [0, 0, 0]
	var honor_count = 0
	var pair_count = 0
	var triplet_count = 0
	var unique_count = 0
	var seven_pair_slots = 0
	var single_tile_count = 0
	var orphan_unique = 0
	var orphan_tiles = 0
	var orphan_pair = false
	var simple_tiles = 0
	var terminal_honor_tiles = 0
	for i in range(TILE_CODES.size()):
		var amount = int(counts[i])
		if amount <= 0:
			continue
		unique_count += 1
		seven_pair_slots += min(2, int(amount / 2))
		if amount % 2 == 1:
			single_tile_count += 1
		if is_simple_number_tile(TILE_CODES[i]):
			simple_tiles += amount
		else:
			terminal_honor_tiles += amount
		if i < 27:
			var suit_index = int(i / 9)
			suit_counts[suit_index] = int(suit_counts[suit_index]) + amount
			suit_rank_masks[suit_index] = int(suit_rank_masks[suit_index]) | (1 << (i % 9))
		else:
			honor_count += amount
		if is_thirteen_orphans_tile(TILE_CODES[i]):
			orphan_unique += 1
			orphan_tiles += amount
			if amount >= 2:
				orphan_pair = true
		if amount >= 2:
			pair_count += 1
		if amount >= 3:
			triplet_count += 1
	var best_suit = 0
	for suit in range(1, 3):
		if int(suit_counts[suit]) > int(suit_counts[best_suit]):
			best_suit = suit
	return {
		"total": tile_count,
		"suit_counts": suit_counts,
		"suit_rank_masks": suit_rank_masks,
		"honor_count": honor_count,
		"best_suit": best_suit,
		"pair_count": pair_count,
		"triplet_count": triplet_count,
		"unique_count": unique_count,
		"seven_pair_slots": seven_pair_slots,
		"single_tile_count": single_tile_count,
		"orphan_unique": orphan_unique,
		"orphan_tiles": orphan_tiles,
		"orphan_pair": orphan_pair,
		"simple_tiles": simple_tiles,
		"terminal_honor_tiles": terminal_honor_tiles,
	}

func hand_plan_score_from_features(counts: Array, features: Dictionary) -> float:
	var tile_count = int(features.get("total", 0))
	var suit_counts: Array = features.get("suit_counts", [0, 0, 0])
	var suit_rank_masks: Array = features.get("suit_rank_masks", EMPTY_SUIT_RANK_MASKS)
	var honor_count = int(features.get("honor_count", 0))
	var pair_count = int(features.get("pair_count", 0))
	var triplet_count = int(features.get("triplet_count", 0))
	var orphan_unique = int(features.get("orphan_unique", 0))
	var orphan_tiles = int(features.get("orphan_tiles", 0))
	var orphan_pair = bool(features.get("orphan_pair", false))
	var simple_tiles = int(features.get("simple_tiles", 0))
	var terminal_honor_tiles = int(features.get("terminal_honor_tiles", 0))
	var max_suit = max(int(suit_counts[0]), max(int(suit_counts[1]), int(suit_counts[2])))
	var off_suit = tile_count - max_suit - honor_count
	var score = float(max_suit) * 2.8 + float(honor_count) * 1.3
	if max_suit >= 8 and off_suit == 0:
		score += 72.0
	elif max_suit >= 7 and off_suit <= 2:
		score += 36.0
	if max_suit + honor_count >= 10 and off_suit == 0:
		score += 46.0
	elif max_suit + honor_count >= 9 and off_suit <= 1:
		score += 22.0
	score += float(pair_count) * 8.0 + float(triplet_count) * 18.0
	if pair_count + triplet_count >= 5:
		score += 28.0
	score += seven_pairs_route_score_from_features(features) * 0.65
	var non_orphan = max(0, tile_count - orphan_tiles)
	if orphan_unique >= 9:
		score += float(orphan_unique) * 7.6 + (18.0 if orphan_pair else 0.0) - float(non_orphan) * 18.0
	var best_dragon_unique = 0
	var best_dragon_suit = 0
	for suit in range(3):
		var unique = rank_mask_unique_count(int(suit_rank_masks[suit]))
		if unique > best_dragon_unique:
			best_dragon_unique = unique
			best_dragon_suit = suit
	var dragon_off_suit = max(0, tile_count - int(suit_counts[best_dragon_suit]) - honor_count)
	if best_dragon_unique >= 6:
		score += float(best_dragon_unique) * 7.2 + float(suit_counts[best_dragon_suit]) * 1.2 - float(dragon_off_suit) * 7.0
	if simple_tiles >= 9 and terminal_honor_tiles <= 2:
		score += float(simple_tiles) * 6.2 - float(terminal_honor_tiles) * 12.0
	score += max(honor_route_score_from_counts(counts, DRAGON_CODES), honor_route_score_from_counts(counts, WIND_CODES))
	return score

func hand_plan_report_for_seat(seat: int, hand: Array) -> Dictionary:
	return hand_plan_report_for_seat_from_counts(seat, tile_counts(hand), hand.size())

func hand_plan_report_for_seat_from_counts(seat: int, counts: Array, tile_count: int) -> Dictionary:
	return hand_plan_report_for_seat_from_features(seat, counts, tile_count, hand_plan_features_from_counts(counts, tile_count))

func hand_plan_report_for_seat_from_features(seat: int, counts: Array, tile_count: int, features: Dictionary) -> Dictionary:
	var plan_counts = counts.duplicate()
	var total = tile_count
	var open_melds = 0
	if seat >= 0 and seat < players.size():
		open_melds = players[seat]["melds"].size()
		for meld in players[seat]["melds"]:
			for item in meld:
				var index = tile_index(str(item))
				if index >= 0 and index < plan_counts.size():
					plan_counts[index] = int(plan_counts[index]) + 1
					total += 1
	var report: Dictionary
	if open_melds > 0:
		report = hand_plan_report_from_counts(plan_counts, total)
	else:
		report = hand_plan_report_from_features(plan_counts, total, features)
	if open_melds > 0 and (str(report.get("label", "")) == "十三幺" or str(report.get("label", "")) == "七对"):
		report["label"] = "标准"
		report["score_bonus"] = 0.0
	return report

func hand_plan_eval_for_seat_from_counts(seat: int, counts: Array, tile_count: int) -> Dictionary:
	var features = hand_plan_features_from_counts(counts, tile_count)
	return {
		"score": hand_plan_score_from_features(counts, features),
		"report": hand_plan_report_for_seat_from_features(seat, counts, tile_count, features),
	}

func hand_plan_report(tiles: Array) -> Dictionary:
	return hand_plan_report_from_counts(tile_counts(tiles), tiles.size())

func hand_plan_report_from_counts(counts: Array, total: int) -> Dictionary:
	return hand_plan_report_from_features(counts, total, hand_plan_features_from_counts(counts, total))

func hand_plan_report_from_features(counts: Array, total: int, features: Dictionary) -> Dictionary:
	var suit_counts: Array = features.get("suit_counts", [0, 0, 0])
	var suit_rank_masks: Array = features.get("suit_rank_masks", EMPTY_SUIT_RANK_MASKS)
	var honors = int(features.get("honor_count", 0))
	var pair_count = int(features.get("pair_count", 0))
	var triplet_count = int(features.get("triplet_count", 0))
	var orphan_unique = int(features.get("orphan_unique", 0))
	var orphan_tiles = int(features.get("orphan_tiles", 0))
	var orphan_pair = bool(features.get("orphan_pair", false))
	var simple_tiles = int(features.get("simple_tiles", 0))
	var terminal_honor_tiles = int(features.get("terminal_honor_tiles", 0))
	var best_suit = int(features.get("best_suit", 0))
	var best_suit_count = int(suit_counts[best_suit])
	var off_suit = max(0, total - best_suit_count - honors)
	var best = {
		"label": "标准",
		"score": 0.0,
		"score_bonus": 0.0,
		"progress": 0,
		"suit": best_suit,
	}
	if total <= 0:
		return best
	var non_orphan = max(0, total - orphan_tiles)
	var orphan_score = float(orphan_unique) * 8.4 + (20.0 if orphan_pair else 0.0) - float(non_orphan) * 22.0
	if orphan_unique >= 9 and non_orphan <= 3 and orphan_score > float(best.get("score", 0.0)):
		best = {"label": "十三幺", "score": orphan_score, "progress": orphan_unique, "suit": -1}
	var dragon_suit = 0
	var dragon_unique = 0
	for suit in range(3):
		var unique = rank_mask_unique_count(int(suit_rank_masks[suit]))
		if unique > dragon_unique:
			dragon_unique = unique
			dragon_suit = suit
	var dragon_off_suit = max(0, total - int(suit_counts[dragon_suit]) - honors)
	var dragon_score = float(dragon_unique) * 8.0 + float(suit_counts[dragon_suit]) * 1.3 - float(dragon_off_suit) * 7.5
	if dragon_unique >= 7 and dragon_score > float(best.get("score", 0.0)):
		best = {"label": "一条龙", "score": dragon_score, "progress": dragon_unique, "suit": dragon_suit}
	var simple_score = float(simple_tiles) * 6.6 - float(terminal_honor_tiles) * 13.0
	if simple_tiles >= 10 and terminal_honor_tiles <= 1 and simple_score > float(best.get("score", 0.0)):
		best = {"label": "断幺九", "score": simple_score, "progress": simple_tiles, "suit": -1}
	var seven_pairs_report = seven_pairs_plan_report_from_features(features)
	if not seven_pairs_report.is_empty() and float(seven_pairs_report.get("score", 0.0)) > float(best.get("score", 0.0)):
		best = seven_pairs_report
	var dragon_honor_report = honor_group_plan_report_from_counts(counts, DRAGON_CODES, "大三元", "小三元")
	if not dragon_honor_report.is_empty() and float(dragon_honor_report.get("score", 0.0)) > float(best.get("score", 0.0)):
		best = dragon_honor_report
	var wind_honor_report = honor_group_plan_report_from_counts(counts, WIND_CODES, "大四喜", "小四喜")
	if not wind_honor_report.is_empty() and float(wind_honor_report.get("score", 0.0)) > float(best.get("score", 0.0)):
		best = wind_honor_report
	var honor_score = float(honors) * 8.2 - float(total - honors) * 20.0
	if honors >= 8 and honor_score > float(best.get("score", 0.0)):
		best = {"label": "字一色", "score": honor_score, "progress": honors, "suit": -1}
	var pure_score = float(best_suit_count) * 7.0 - float(off_suit) * 24.0 - float(honors) * 10.0
	if best_suit_count >= 8 and off_suit + honors <= 2 and pure_score > float(best.get("score", 0.0)):
		best = {"label": "清一色", "score": pure_score, "progress": best_suit_count, "suit": best_suit}
	var mixed_score = float(best_suit_count + honors) * 6.2 + float(honors) * 1.6 - float(off_suit) * 24.0
	if best_suit_count + honors >= 9 and honors > 0 and off_suit <= 2 and mixed_score > float(best.get("score", 0.0)):
		best = {"label": "混一色", "score": mixed_score, "progress": best_suit_count + honors, "suit": best_suit}
	var triplet_progress = pair_count + triplet_count * 2
	var triplet_score = float(pair_count) * 10.0 + float(triplet_count) * 22.0
	if triplet_progress >= 5 and triplet_score > float(best.get("score", 0.0)):
		best = {"label": "碰碰胡", "score": triplet_score, "progress": triplet_progress, "suit": -1}
	var score = float(best.get("score", 0.0))
	if score < 42.0:
		best["label"] = "标准"
		best["score_bonus"] = 0.0
	else:
		best["score_bonus"] = clamp((score - 36.0) * 0.85, 0.0, 88.0)
	return best

func seven_pairs_route_score_from_features(features: Dictionary) -> float:
	var pair_slots = int(features.get("seven_pair_slots", 0))
	if pair_slots < 4:
		return 0.0
	var unique = int(features.get("unique_count", 0))
	var single_tiles = int(features.get("single_tile_count", 0))
	var missing_unique = max(0, 7 - unique)
	var score = float(pair_slots) * 21.0 - float(single_tiles) * 6.0 - float(missing_unique) * 16.0
	if pair_slots >= 5:
		score += 36.0
	if pair_slots >= 6:
		score += 46.0
	return max(0.0, score)

func seven_pairs_plan_report_from_features(features: Dictionary) -> Dictionary:
	var score = seven_pairs_route_score_from_features(features)
	if score <= 0.0:
		return {}
	var pair_slots = int(features.get("seven_pair_slots", 0))
	if pair_slots < 6:
		return {}
	return {
		"label": "七对",
		"score": score,
		"progress": pair_slots,
		"suit": -1,
	}

func seven_pairs_route_score_from_counts(counts: Array) -> float:
	var pair_slots = 0
	var unique = 0
	var single_tiles = 0
	for count in counts:
		var amount = int(count)
		if amount <= 0:
			continue
		unique += 1
		pair_slots += min(2, int(amount / 2))
		if amount % 2 == 1:
			single_tiles += 1
	if pair_slots < 4:
		return 0.0
	var missing_unique = max(0, 7 - unique)
	var score = float(pair_slots) * 21.0 - float(single_tiles) * 6.0 - float(missing_unique) * 16.0
	if pair_slots >= 5:
		score += 36.0
	if pair_slots >= 6:
		score += 46.0
	return max(0.0, score)

func seven_pairs_plan_report_from_counts(counts: Array) -> Dictionary:
	var score = seven_pairs_route_score_from_counts(counts)
	if score <= 0.0:
		return {}
	var pair_slots = 0
	for count in counts:
		pair_slots += min(2, int(int(count) / 2))
	if pair_slots < 6:
		return {}
	return {
		"label": "七对",
		"score": score,
		"progress": pair_slots,
		"suit": -1,
	}

func honor_route_score_from_counts(counts: Array, codes: Array) -> float:
	var stats = honor_group_stats_from_counts(counts, codes)
	var triplets = int(stats.get("triplets", 0))
	var pairs = int(stats.get("pairs", 0))
	var singles = int(stats.get("singles", 0))
	var tiles = int(stats.get("tiles", 0))
	if codes.size() == 3:
		if triplets >= 2 and pairs + singles >= 1:
			return float(tiles) * 3.5 + float(triplets) * 28.0 + float(pairs) * 12.0 + 70.0
		if triplets + pairs >= 2 and tiles >= 5:
			return float(tiles) * 3.0 + float(triplets) * 22.0 + float(pairs) * 10.0 + 34.0
		return 0.0
	if codes.size() == 4:
		if triplets >= 3 and pairs + singles >= 1:
			return float(tiles) * 3.5 + float(triplets) * 28.0 + float(pairs) * 12.0 + 90.0
		if triplets + pairs >= 3 and tiles >= 7:
			return float(tiles) * 3.0 + float(triplets) * 22.0 + float(pairs) * 10.0 + 48.0
	return 0.0

func honor_group_plan_report_from_counts(counts: Array, codes: Array, big_label: String, small_label: String) -> Dictionary:
	var score = honor_route_score_from_counts(counts, codes)
	if score <= 0.0:
		return {}
	var stats = honor_group_stats_from_counts(counts, codes)
	var triplets = int(stats.get("triplets", 0))
	var pairs = int(stats.get("pairs", 0))
	var singles = int(stats.get("singles", 0))
	var label = small_label
	if codes.size() == 3:
		if triplets >= 3 or (triplets >= 2 and pairs == 0 and singles >= 1):
			label = big_label
	elif codes.size() == 4:
		if triplets >= 4 or (triplets >= 3 and pairs == 0 and singles >= 1):
			label = big_label
	return {
		"label": label,
		"score": score,
		"progress": triplets * 2 + pairs + singles,
		"suit": -1,
	}

func ai_defense_weight(seat: int, shanten: int, pressure_context: Dictionary = {}) -> float:
	var base = 0.40
	if shanten <= 0:
		base = 0.42
	elif shanten == 1:
		base = 0.86
	elif shanten == 2:
		base = 1.16
	else:
		base = 1.34
	var progress = clamp(1.0 - float(get_wall_count()) / 84.0, 0.0, 1.0)
	var pressure = float(pressure_context.get("opponent_pressure", 0.0)) if pressure_context.has("opponent_pressure") else opponent_pressure_score(seat)
	var readiness = float(pressure_context.get("readiness_pressure", 0.0)) if pressure_context.has("readiness_pressure") else opponent_readiness_pressure_score(seat)
	return max(0.20, (base + progress * 0.52 + pressure * 0.08 + readiness * 0.10 + score_defense_adjustment(seat)) * ai_risk_factor(seat))

func ai_pressure_context(seat: int, eval_context: Dictionary = {}) -> Dictionary:
	var context: Dictionary = {
		"opponent_pressure": 0.0,
		"readiness_pressure": 0.0,
		"threat_rank": 0,
	}
	if seat < 0 or seat >= players.size():
		return context
	var pressure = 0.0
	var readiness_pressure = 0.0
	for other in range(players.size()):
		if other == seat:
			continue
		var plan = opponent_plan_pressure(other, eval_context)
		var readiness = opponent_readiness_score_from_plan(other, plan)
		var value = float(players[other]["melds"].size()) * 1.55 + float(players[other]["discards"].size()) * 0.12
		value += plan * 0.18
		value += readiness * 0.42
		if players[other]["discards"].size() >= 12:
			value += 1.0
		pressure = max(pressure, value)
		readiness_pressure = max(readiness_pressure, readiness)
	var threat = opponent_threat_report(seat, eval_context)
	context["opponent_pressure"] = pressure
	context["readiness_pressure"] = readiness_pressure
	context["threat_rank"] = threat_level_rank(str(threat.get("level", ""))) if typeof(threat) == TYPE_DICTIONARY else 0
	return context

func opponent_pressure_score(seat: int, eval_context: Dictionary = {}) -> float:
	var pressure = 0.0
	for other in range(players.size()):
		if other == seat:
			continue
		var value = float(players[other]["melds"].size()) * 1.55 + float(players[other]["discards"].size()) * 0.12
		var plan = opponent_plan_pressure(other, eval_context)
		value += plan * 0.18
		value += opponent_readiness_score_from_plan(other, plan) * 0.42
		if players[other]["discards"].size() >= 12:
			value += 1.0
		pressure = max(pressure, value)
	return pressure

func opponent_readiness_pressure_score(seat: int, eval_context: Dictionary = {}) -> float:
	var pressure = 0.0
	for other in range(players.size()):
		if other == seat:
			continue
		pressure = max(pressure, opponent_readiness_score(other, eval_context))
	return pressure

func shanten_label(shanten: int) -> String:
	if shanten < 0:
		return "已胡"
	if shanten == 0:
		return "听牌"
	return "%d向听" % shanten

func risk_label(risk: float) -> String:
	if risk < 18.0:
		return "低"
	if risk < 31.0:
		return "中"
	return "高"

func tile_safety_label(tile: String, seat: int, visible_counts_snapshot: Array = [], eval_context: Dictionary = {}) -> String:
	if tile == "" or seat < 0 or seat >= players.size():
		return ""
	var cache_key = ""
	if not eval_context.is_empty():
		cache_key = ai_context_cache_key(tile, seat)
		var cache = eval_context.get("safety_labels", {})
		if typeof(cache) == TYPE_DICTIONARY and cache.has(cache_key):
			return str(cache.get(cache_key, ""))
	var visible_counts = ai_context_visible_counts(eval_context, visible_counts_snapshot)
	var label = ""
	if is_tile_safe_against_all(tile, seat, eval_context):
		label = "安"
	elif is_main_threat_genbutsu(tile, seat, eval_context):
		label = "现"
	elif visible_tile_count_from_counts(tile, visible_counts) >= 3:
		label = "熟"
	elif is_suji_safe_tile(tile, seat, eval_context):
		label = "筋"
	elif is_kabe_safe_tile(tile, seat, visible_counts, eval_context):
		label = "壁"
	if not eval_context.is_empty():
		var cache = eval_context.get("safety_labels", {})
		if typeof(cache) == TYPE_DICTIONARY:
			cache[cache_key] = label
	return label

func is_main_threat_genbutsu(tile: String, seat: int, eval_context: Dictionary = {}) -> bool:
	var opponent = main_threat_opponent(seat, eval_context)
	return opponent >= 0 and opponent_discard_tile_count(opponent, tile, eval_context) > 0

func main_threat_opponent(seat: int, eval_context: Dictionary = {}) -> int:
	if seat < 0 or seat >= players.size():
		return -1
	if not eval_context.is_empty() and int(eval_context.get("main_threat", -2)) != -2:
		return int(eval_context.get("main_threat", -1))
	var best_opponent = -1
	var best_score = 0.0
	for other in range(players.size()):
		if other == seat:
			continue
		var score = opponent_plan_pressure(other, eval_context)
		if score > best_score:
			best_score = score
			best_opponent = other
	var result = best_opponent if best_score >= 8.0 else -1
	if not eval_context.is_empty():
		eval_context["main_threat"] = result
	return result

func is_tile_safe_against_all(tile: String, seat: int, eval_context: Dictionary = {}) -> bool:
	var opponents = 0
	for other in range(players.size()):
		if other == seat:
			continue
		opponents += 1
		if opponent_discard_tile_count(other, tile, eval_context) <= 0:
			return false
	return opponents > 0

func is_suji_safe_tile(tile: String, seat: int, eval_context: Dictionary = {}) -> bool:
	if not is_number_tile(tile) or seat < 0 or seat >= players.size():
		return false
	for other in range(players.size()):
		if other == seat:
			continue
		if players[other]["melds"].size() <= 0 and players[other]["discards"].size() < 6:
			continue
		if is_suji_safe_against_opponent(tile, other, eval_context):
			return true
	return false

func is_suji_safe_against_opponent(tile: String, opponent: int, eval_context: Dictionary = {}) -> bool:
	if not is_number_tile(tile) or opponent < 0 or opponent >= players.size():
		return false
	var index = tile_index(tile)
	if index < 0 or index >= 27:
		return false
	var rank = index % 9
	if rank <= 2:
		return opponent_discard_tile_count(opponent, TILE_CODES[index + 3], eval_context) > 0
	if rank >= 6:
		return opponent_discard_tile_count(opponent, TILE_CODES[index - 3], eval_context) > 0
	return opponent_discard_tile_count(opponent, TILE_CODES[index - 3], eval_context) > 0 and opponent_discard_tile_count(opponent, TILE_CODES[index + 3], eval_context) > 0

func suji_anchor_tiles(tile: String) -> Array[String]:
	var result: Array[String] = []
	if not is_number_tile(tile):
		return result
	var suit = tile.right(1)
	var rank = int(tile.left(tile.length() - 1))
	match rank:
		1, 7:
			result.append("4" + suit)
		2, 8:
			result.append("5" + suit)
		3, 9:
			result.append("6" + suit)
		4:
			result.append("1" + suit)
			result.append("7" + suit)
		5:
			result.append("2" + suit)
			result.append("8" + suit)
		6:
			result.append("3" + suit)
			result.append("9" + suit)
	return result

func is_kabe_safe_tile(tile: String, seat: int, visible_counts_snapshot: Array = [], eval_context: Dictionary = {}) -> bool:
	if not is_number_tile(tile) or seat < 0 or seat >= players.size():
		return false
	if visible_tile_count_from_counts(tile, visible_counts_snapshot) >= 3:
		return false
	for other in range(players.size()):
		if other == seat:
			continue
		if players[other]["melds"].size() <= 0 and players[other]["discards"].size() < 6:
			continue
		if is_kabe_safe_against_opponent(tile, other, visible_counts_snapshot, eval_context):
			return true
	return false

func is_kabe_safe_against_opponent(tile: String, opponent: int, visible_counts_snapshot: Array = [], eval_context: Dictionary = {}) -> bool:
	if not is_number_tile(tile) or opponent < 0 or opponent >= players.size():
		return false
	var visible_counts = ai_context_visible_counts(eval_context, visible_counts_snapshot)
	var index = tile_index(tile)
	if index < 0 or index >= 27 or index >= visible_counts.size():
		return false
	var rank = index % 9
	if rank > 0 and int(visible_counts[index - 1]) >= 3:
		return true
	if rank < 8 and int(visible_counts[index + 1]) >= 3:
		return true
	return false

func kabe_wall_tiles(tile: String) -> Array[String]:
	var result: Array[String] = []
	if not is_number_tile(tile):
		return result
	var suit = tile.right(1)
	var rank = int(tile.left(tile.length() - 1))
	if rank > 1:
		result.append(str(rank - 1) + suit)
	if rank < 9:
		result.append(str(rank + 1) + suit)
	return result

func discard_pressure_score(tile: String, seat: int, visible_counts_snapshot: Array = [], eval_context: Dictionary = {}) -> float:
	var cache_key = ""
	if not eval_context.is_empty():
		cache_key = ai_context_cache_key(tile, seat)
		var cache = eval_context.get("discard_pressures", {})
		if typeof(cache) == TYPE_DICTIONARY and cache.has(cache_key):
			return float(cache.get(cache_key, 0.0))
	var score = 0.0
	var visible_counts = ai_context_visible_counts(eval_context, visible_counts_snapshot)
	var visible = visible_tile_count_from_counts(tile, visible_counts)
	score += float(visible) * 3.4
	if is_terminal_or_honor(tile):
		score += 3.0
	var next_seat = (seat + 1) % 4
	if next_seat != seat and opponent_discard_tile_count(next_seat, tile, eval_context) > 0:
		score += 5.0
	for other in range(players.size()):
		if other == seat:
			continue
		if opponent_discard_tile_count(other, tile, eval_context) > 0:
			score += 3.5
		if same_suit_pressure(other, tile, eval_context):
			score += 1.2
	if not eval_context.is_empty():
		var cache = eval_context.get("discard_pressures", {})
		if typeof(cache) == TYPE_DICTIONARY:
			cache[cache_key] = score
	return score

func discard_feed_risk_report(tile: String, seat: int, visible_counts_snapshot: Array = [], eval_context: Dictionary = {}) -> Dictionary:
	var cache_key = ""
	if not eval_context.is_empty():
		cache_key = ai_context_cache_key(tile, seat)
		var cache = eval_context.get("feed_reports", {})
		if typeof(cache) == TYPE_DICTIONARY and cache.has(cache_key):
			return duplicate_feed_report(cache[cache_key])
	var report = {"score": 0.0, "details": []}
	if tile == "" or seat < 0 or seat >= players.size():
		return report
	var details: Array = []
	var visible_counts = ai_context_visible_counts(eval_context, visible_counts_snapshot)
	var visible = visible_tile_count_from_counts(tile, visible_counts)
	var next_seat = (seat + 1) % 4
	if next_seat != seat:
		var chi_score = chi_feed_risk_score(tile, seat, next_seat, visible, eval_context)
		if chi_score > 0.0:
			details.append({
				"opponent": next_seat,
				"name": str(players[next_seat]["name"]),
				"claim": "chi",
				"label": "吃",
				"score": chi_score,
			})
	for other in range(players.size()):
		if other == seat:
			continue
		var meld_score = meld_feed_risk_score(tile, seat, other, visible, eval_context)
		if meld_score > 0.0:
			details.append({
				"opponent": other,
				"name": str(players[other]["name"]),
				"claim": "peng",
				"label": "碰",
				"score": meld_score,
			})
	details.sort_custom(func(a, b):
		var score_a = float(a.get("score", 0.0))
		var score_b = float(b.get("score", 0.0))
		if is_equal_approx(score_a, score_b):
			return int(a.get("opponent", 0)) < int(b.get("opponent", 0))
		return score_a > score_b
	)
	var total = 0.0
	for i in range(details.size()):
		var score = float(details[i].get("score", 0.0))
		total += score if i == 0 else score * 0.28
	report["details"] = details
	report["score"] = total
	if not eval_context.is_empty():
		var cache = eval_context.get("feed_reports", {})
		if typeof(cache) == TYPE_DICTIONARY:
			cache[cache_key] = duplicate_feed_report(report)
	return report

func chi_feed_risk_score(tile: String, seat: int, opponent: int, visible_override: int = -1, eval_context: Dictionary = {}) -> float:
	if not can_feed_chi(tile) or opponent < 0 or opponent >= players.size():
		return 0.0
	if opponent_discard_tile_count(opponent, tile, eval_context) > 0:
		return 0.0
	var index = tile_index(tile)
	var rank = index % 9
	var score = 7.0
	if rank >= 2 and rank <= 6:
		score += 7.0
	elif rank == 1 or rank == 7:
		score += 4.0
	var visible = visible_override if visible_override >= 0 else visible_tile_count(tile)
	if visible == 0:
		score += 3.5
	elif visible == 1:
		score += 1.5
	elif visible >= 3:
		score -= 6.0
	var suit = tile_suit_index(tile)
	var suit_pressure = opponent_suit_plan_threat(opponent, suit, eval_context)
	score += suit_pressure * 0.42
	if opponent_meld_count_for_suit(opponent, suit, eval_context) > 0:
		score += 4.5
	if players[opponent]["discards"].size() >= 10:
		score += 2.5
	return max(0.0, score)

func meld_feed_risk_score(tile: String, seat: int, opponent: int, visible_override: int = -1, eval_context: Dictionary = {}) -> float:
	if tile == "" or opponent < 0 or opponent >= players.size() or opponent == seat:
		return 0.0
	if opponent_discard_tile_count(opponent, tile, eval_context) > 0:
		return 0.0
	var visible = visible_override if visible_override >= 0 else visible_tile_count(tile)
	if visible >= 3:
		return 0.0
	var unseen = max(0, 4 - visible)
	var score = float(unseen) * 3.0
	score += float(players[opponent]["melds"].size()) * 2.2
	if visible == 0:
		score += 4.0
	elif visible == 1:
		score += 1.8
	if is_number_tile(tile):
		var suit = tile_suit_index(tile)
		var suit_pressure = opponent_suit_plan_threat(opponent, suit, eval_context)
		score += suit_pressure * 0.34
		if opponent_meld_count_for_suit(opponent, suit, eval_context) > 0:
			score += 3.0
		if is_middle_number_tile(tile):
			score += 2.5
	elif is_honor_tile(tile):
		var honor_pressure = opponent_honor_plan_threat(opponent, eval_context)
		score += honor_pressure * 0.42
		if opponent_honor_meld_count(opponent, eval_context) > 0:
			score += 4.0
		else:
			score += 1.5
	if players[opponent]["discards"].size() >= 10:
		score += 1.8
	return max(0.0, score)

func discard_feed_penalty_weight(defense: float, shanten: int) -> float:
	var weight = 0.42 + max(0.0, defense - 0.70) * 0.28
	if shanten <= 0:
		weight *= 0.35
	elif shanten == 1:
		weight *= 0.62
	return weight

func discard_feed_risk_text(feed_report) -> String:
	if typeof(feed_report) != TYPE_DICTIONARY:
		return ""
	var details: Array = feed_report.get("details", [])
	if details.is_empty() or float(feed_report.get("score", 0.0)) < 10.0:
		return ""
	var best: Dictionary = details[0]
	return "喂%s%s" % [str(best.get("name", "")), str(best.get("label", ""))]

func deal_in_risk_score(tile: String, seat: int, eval_context: Dictionary = {}) -> float:
	return float(tile_risk_vector(tile, seat, [], eval_context).get("score", 0.0))

func deal_in_risk_summary(tile: String, seat: int, visible_counts_snapshot: Array = [], risk_vector: Dictionary = {}, eval_context: Dictionary = {}) -> Dictionary:
	var summary: Dictionary = {"score": 0.0, "danger_source": {}}
	if tile == "" or seat < 0 or seat >= players.size():
		return summary
	if not risk_vector.is_empty():
		summary["score"] = float(risk_vector.get("score", 0.0))
		var vector_source = risk_vector.get("danger_source", {})
		if typeof(vector_source) == TYPE_DICTIONARY:
			summary["danger_source"] = vector_source
		return summary
	var vector = tile_risk_vector(tile, seat, visible_counts_snapshot, eval_context)
	summary["score"] = float(vector.get("score", 0.0))
	var computed_source = vector.get("danger_source", {})
	if typeof(computed_source) == TYPE_DICTIONARY:
		summary["danger_source"] = computed_source
	return summary

func tile_risk_vector(tile: String, seat: int, visible_counts_snapshot: Array = [], eval_context: Dictionary = {}) -> Dictionary:
	var cache_key = ""
	if not eval_context.is_empty():
		cache_key = ai_context_cache_key(tile, seat)
		var cache = eval_context.get("risk_vectors", {})
		if typeof(cache) == TYPE_DICTIONARY and cache.has(cache_key):
			return duplicate_risk_vector(cache[cache_key])
	var vector: Dictionary = {"score": 0.0, "threat": 0.0, "visible": 0, "danger_source": {}}
	if tile == "" or seat < 0 or seat >= players.size():
		return vector
	var visible_counts = ai_context_visible_counts(eval_context, visible_counts_snapshot)
	var visible = visible_tile_count_from_counts(tile, visible_counts)
	vector["visible"] = visible
	var risk = 0.0
	var threat = 0.0
	var best_opponent = -1
	var best_risk = 0.0
	var opponent_vector: Dictionary = {"risk": 0.0, "pattern_threat": 0.0}
	for other in range(players.size()):
		if other == seat:
			continue
		write_single_opponent_deal_in_risk_components(opponent_vector, tile, seat, other, visible, visible_counts, eval_context)
		var opponent_risk = float(opponent_vector.get("risk", 0.0))
		risk += opponent_risk
		threat += float(opponent_vector.get("pattern_threat", 0.0))
		if opponent_risk > best_risk:
			best_risk = opponent_risk
			best_opponent = other
	vector["score"] = risk
	vector["threat"] = threat
	if best_opponent >= 0 and best_risk >= 10.0:
		vector["danger_source"] = {
				"opponent": best_opponent,
				"name": str(players[best_opponent]["name"]),
				"risk": best_risk,
				"reason": discard_danger_reason(tile, seat, best_opponent, eval_context),
			}
	if not eval_context.is_empty():
		var cache = eval_context.get("risk_vectors", {})
		if typeof(cache) == TYPE_DICTIONARY:
			cache[cache_key] = duplicate_risk_vector(vector)
	return vector

func single_opponent_deal_in_risk(tile: String, seat: int, opponent: int, visible_override: int = -1, visible_counts_snapshot: Array = []) -> float:
	return float(single_opponent_deal_in_risk_components(tile, seat, opponent, visible_override, visible_counts_snapshot).get("risk", 0.0))

func single_opponent_deal_in_risk_components(tile: String, seat: int, opponent: int, visible_override: int = -1, visible_counts_snapshot: Array = [], eval_context: Dictionary = {}) -> Dictionary:
	var result: Dictionary = {"risk": 0.0, "pattern_threat": 0.0}
	write_single_opponent_deal_in_risk_components(result, tile, seat, opponent, visible_override, visible_counts_snapshot, eval_context)
	return result

func write_single_opponent_deal_in_risk_components(result: Dictionary, tile: String, seat: int, opponent: int, visible_override: int = -1, visible_counts_snapshot: Array = [], eval_context: Dictionary = {}) -> void:
	result["risk"] = 0.0
	result["pattern_threat"] = 0.0
	if tile == "" or seat < 0 or seat >= players.size() or opponent < 0 or opponent >= players.size() or opponent == seat:
		return
	if opponent_discard_tile_count(opponent, tile, eval_context) > 0:
		return
	var visible = visible_override if visible_override >= 0 else visible_tile_count(tile)
	var pressure = 2.0 + float(players[opponent]["melds"].size()) * 3.2
	var readiness = opponent_readiness_score(opponent, eval_context)
	if visible == 0:
		pressure += 4.8
	elif visible == 1:
		pressure += 2.2
	elif visible >= 3:
		pressure -= 4.0
	if is_middle_number_tile(tile):
		pressure += 3.0
	elif is_terminal_or_honor(tile):
		pressure -= 1.4
	if is_honor_tile(tile) and visible == 0:
		pressure += 2.0
	if opponent == (seat + 1) % 4 and can_feed_chi(tile):
		pressure += 1.8
	if players[opponent]["discards"].size() >= 12 or players[opponent]["melds"].size() >= 3:
		pressure += 2.8
	if readiness >= 7.0:
		pressure += readiness * (0.32 if is_terminal_or_honor(tile) else 0.52)
		if is_middle_number_tile(tile):
			pressure += readiness * 0.18
	if is_suji_safe_against_opponent(tile, opponent, eval_context):
		pressure -= 8.6
	elif is_kabe_safe_against_opponent(tile, opponent, visible_counts_snapshot, eval_context):
		pressure -= 5.4
	var pattern_threat = opponent_pattern_threat_score(opponent, tile, visible, eval_context)
	pressure += pattern_threat
	result["risk"] = max(0.0, pressure)
	result["pattern_threat"] = pattern_threat

func discard_danger_source_report(tile: String, seat: int) -> Dictionary:
	var source = deal_in_risk_summary(tile, seat).get("danger_source", {})
	if typeof(source) == TYPE_DICTIONARY:
		return source
	return {}

func discard_danger_reason(tile: String, seat: int, opponent: int, eval_context: Dictionary = {}) -> String:
	var parts: Array[String] = []
	var visible_counts = ai_context_visible_counts(eval_context)
	var visible = visible_tile_count_from_counts(tile, visible_counts)
	if is_number_tile(tile):
		var suit = tile_suit_index(tile)
		var suit_melds = opponent_meld_count_for_suit(opponent, suit, eval_context)
		if suit_melds >= 2:
			parts.append("%s染手" % suit_label(suit_code(suit)))
		elif suit_melds == 1:
			parts.append("%s副露" % suit_label(suit_code(suit)))
		if is_middle_number_tile(tile):
			parts.append("中张")
	elif is_honor_tile(tile):
		if opponent_honor_meld_count(opponent, eval_context) > 0:
			parts.append("字牌副露")
		else:
			parts.append("字牌")
	if visible == 0:
		parts.append("生张")
	elif visible == 1:
		parts.append("少见")
	if opponent == (seat + 1) % 4 and can_feed_chi(tile):
		parts.append("下家可吃")
	if players[opponent]["melds"].size() >= 3:
		parts.append("三副露")
	elif players[opponent]["melds"].size() >= 2:
		parts.append("两副露")
	if players[opponent]["discards"].size() >= 12:
		parts.append("末盘")
	if parts.is_empty():
		parts.append("牌路危险")
	return join_limited_strings(parts, "、", 3)

func discard_danger_text(source) -> String:
	if typeof(source) != TYPE_DICTIONARY or source.is_empty():
		return ""
	var reason = str(source.get("reason", "牌路危险"))
	return "主危%s：%s" % [str(source.get("name", "")), reason]

func opponent_tile_threat_score(tile: String, seat: int, visible_counts_snapshot: Array = [], risk_vector: Dictionary = {}, eval_context: Dictionary = {}) -> float:
	if seat < 0 or seat >= players.size():
		return 0.0
	if not risk_vector.is_empty():
		return float(risk_vector.get("threat", 0.0))
	var total = 0.0
	var visible = visible_tile_count_from_counts(tile, visible_counts_snapshot)
	for other in range(players.size()):
		if other == seat:
			continue
		if opponent_discard_tile_count(other, tile, eval_context) > 0:
			continue
		total += opponent_pattern_threat_score(other, tile, visible, eval_context)
	return total

func opponent_pattern_threat_score(opponent: int, tile: String, visible: int, eval_context: Dictionary = {}) -> float:
	if opponent < 0 or opponent >= players.size():
		return 0.0
	var index = tile_index(tile)
	if index < 0:
		return 0.0
	var threat = 0.0
	if index < 27:
		var suit = tile_suit_index(tile)
		var meld_count = opponent_meld_count_for_suit(opponent, suit, eval_context)
		if meld_count <= 0:
			return 0.0
		var meld_tiles = opponent_meld_tile_count_for_suit(opponent, suit, eval_context)
		var suit_discards = opponent_discard_count_for_suit(opponent, suit, eval_context)
		var off_suit_discards = max(0, players[opponent]["discards"].size() - suit_discards)
		threat += float(meld_count) * 3.2 + float(meld_tiles) * 0.65
		if meld_count >= 2:
			threat += 6.0
		if meld_count >= 3:
			threat += 8.0
		if suit_discards == 0:
			threat += 4.2
		elif suit_discards <= 2:
			threat += 2.0
		threat += min(5.0, float(off_suit_discards) * 0.45)
		if is_middle_number_tile(tile):
			threat += 2.4
		elif is_terminal_or_honor(tile):
			threat += 0.6
	else:
		var honor_melds = opponent_honor_meld_count(opponent, eval_context)
		if honor_melds <= 0:
			return 0.0
		threat += float(honor_melds) * 4.4 + float(players[opponent]["melds"].size()) * 0.9
		if visible == 0:
			threat += 3.6
		elif visible >= 2:
			threat -= 1.2
	return max(0.0, threat)

func opponent_threat_summary(seat: int) -> String:
	var report = opponent_threat_report(seat)
	if report.is_empty():
		return ""
	var safe_tiles: Array = report.get("safe_tiles", [])
	var safe_text = "，安牌%s" % "、".join(safe_tiles) if not safe_tiles.is_empty() else ""
	var readiness = str(report.get("readiness_label", ""))
	var plan = str(report.get("plan_label", ""))
	var plan_text = "偏%s" % plan if plan != "" else "手牌推进"
	return "%s %s%s%s，慎放%s%s" % [
		str(report.get("level", "中")),
		str(report.get("name", "")),
		readiness,
		plan_text,
		str(report.get("avoid", "")),
		safe_text,
	]

func opponent_threat_report(seat: int, eval_context: Dictionary = {}) -> Dictionary:
	if seat < 0 or seat >= players.size():
		return {}
	var best_score = 0.0
	var best_report: Dictionary = {}
	for other in range(players.size()):
		if other == seat:
			continue
		var report = opponent_seat_threat_report(seat, other, eval_context)
		var score = float(report.get("score", 0.0))
		if score > best_score:
			best_score = score
			best_report = report
	if best_score < 8.0 or best_report.is_empty():
		return {}
	return best_report

func opponent_seat_threat_report(viewer: int, opponent: int, eval_context: Dictionary = {}) -> Dictionary:
	if viewer < 0 or viewer >= players.size() or opponent < 0 or opponent >= players.size() or viewer == opponent:
		return {}
	var cache_key = threat_report_cache_key(viewer, opponent)
	if cache_key != "" and threat_report_cache.has(cache_key):
		return duplicate_threat_report(threat_report_cache[cache_key])
	var best_score = 0.0
	var best_label = ""
	var best_hint = ""
	var best_type = ""
	var best_suit = -1
	for suit in range(3):
		var score = opponent_suit_plan_threat(opponent, suit, eval_context)
		if score > best_score:
			best_score = score
			best_label = suit_label(suit_code(suit))
			best_hint = "%s中张" % best_label
			best_type = "suit"
			best_suit = suit
	var honor_score = opponent_honor_plan_threat(opponent, eval_context)
	if honor_score > best_score:
		best_score = honor_score
		best_label = "字牌"
		best_hint = "生张字牌"
		best_type = "honor"
		best_suit = -1
	var readiness = opponent_readiness_report(viewer, opponent, eval_context)
	var readiness_score = float(readiness.get("score", 0.0))
	var readiness_label = str(readiness.get("label", ""))
	if best_score < 8.0 and readiness_label != "":
		best_score = readiness_score * 1.55
		best_label = ""
		best_hint = "生张中张"
		best_type = "readiness"
		best_suit = -1
	if best_score < 8.0 and readiness_label == "":
		store_threat_report_cache(cache_key, {})
		return {}
	var level = opponent_threat_level(best_score)
	if readiness_label != "":
		level = stronger_threat_level(level, readiness_threat_level(readiness_score))
	var report = {
		"opponent": opponent,
		"name": str(players[opponent]["name"]),
		"score": best_score,
		"level": level,
		"plan_type": best_type,
		"plan_suit": best_suit,
		"plan_label": best_label,
		"avoid": best_hint,
		"readiness_score": readiness_score,
		"readiness_label": readiness_label,
		"readiness_reasons": readiness.get("reasons", []),
		"safe_tiles": threat_safe_tile_labels(viewer, best_type, best_suit, 3, eval_context),
	}
	store_threat_report_cache(cache_key, report)
	return duplicate_threat_report(report)

func threat_report_cache_key(viewer: int, opponent: int) -> String:
	if mode != "offline" or viewer < 0 or opponent < 0:
		return ""
	var parts: Array[String] = [
		"viewer=%d" % viewer,
		"opponent=%d" % opponent,
		"phase=" + offline_phase,
		"cur=%d" % current_seat,
		"wall=%d" % get_wall_count(),
	]
	for seat in range(players.size()):
		var player: Dictionary = players[seat]
		parts.append("p%d_hand=%s" % [seat, tile_array_key(player.get("hand", [])) if seat == viewer else "%d" % numeric_count(player.get("hand", []), 0)])
		parts.append("p%d_disc=%s" % [seat, tile_array_key(player.get("discards", []))])
		parts.append("p%d_meld=%s" % [seat, meld_array_key(player.get("melds", []))])
	return "|".join(parts)

func store_threat_report_cache(key: String, report: Dictionary) -> void:
	if key == "":
		return
	if not threat_report_cache.has(key):
		threat_report_cache_order.append(key)
	threat_report_cache[key] = duplicate_threat_report(report)
	while threat_report_cache_order.size() > THREAT_REPORT_CACHE_LIMIT:
		var oldest = threat_report_cache_order.pop_front()
		threat_report_cache.erase(oldest)

func duplicate_threat_report(report) -> Dictionary:
	if typeof(report) != TYPE_DICTIONARY:
		return {}
	var copy: Dictionary = (report as Dictionary).duplicate(false)
	var safe_tiles = copy.get("safe_tiles", [])
	if typeof(safe_tiles) == TYPE_ARRAY:
		copy["safe_tiles"] = (safe_tiles as Array).duplicate(false)
	var reasons = copy.get("readiness_reasons", [])
	if typeof(reasons) == TYPE_ARRAY:
		copy["readiness_reasons"] = (reasons as Array).duplicate(false)
	return copy

func clear_threat_report_cache() -> void:
	threat_report_cache.clear()
	threat_report_cache_order.clear()

func render_seat_threat_reports(viewer: int, eval_context: Dictionary = {}) -> Dictionary:
	var reports: Dictionary = {}
	if mode != "offline" or viewer < 0 or viewer >= players.size():
		return reports
	for seat in range(players.size()):
		if seat == viewer:
			continue
		var report = opponent_seat_threat_report(viewer, seat, eval_context)
		if not report.is_empty():
			reports[seat] = report
	return reports

func seat_threat_report_from_map(seat: int, seat_threat_reports: Dictionary) -> Dictionary:
	if seat_threat_reports.has(seat):
		var report = seat_threat_reports.get(seat, {})
		if typeof(report) == TYPE_DICTIONARY:
			return report
	if not player_ai_assist_enabled():
		return {}
	if mode == "offline" and seat != 0:
		return opponent_seat_threat_report(0, seat)
	return {}

func opponent_seat_threat_badge_text(seat: int, viewer: int = 0) -> String:
	if mode != "offline" or seat == viewer:
		return ""
	var report = opponent_seat_threat_report(viewer, seat)
	return opponent_seat_threat_badge_text_from_report(report)

func opponent_seat_threat_badge_text_from_report(report: Dictionary) -> String:
	if report.is_empty():
		return ""
	var readiness = str(report.get("readiness_label", ""))
	if readiness != "":
		return "%s%s" % [readiness, str(report.get("plan_label", ""))]
	return "%s%s" % [str(report.get("level", "中")), str(report.get("plan_label", ""))]

func opponent_seat_threat_line(seat: int, viewer: int = 0) -> String:
	if mode != "offline" or seat == viewer:
		return ""
	var report = opponent_seat_threat_report(viewer, seat)
	return opponent_seat_threat_line_from_report(report)

func opponent_seat_threat_line_from_report(report: Dictionary) -> String:
	if report.is_empty():
		return ""
	var safe_tiles: Array = report.get("safe_tiles", [])
	var safe_text = " 安%s" % join_limited_strings(safe_tiles, "、", 2) if not safe_tiles.is_empty() else ""
	var readiness = str(report.get("readiness_label", ""))
	var plan = str(report.get("plan_label", ""))
	var threat_text = "威%s" % plan if plan != "" else "威手"
	return "%s%s%s" % [readiness + " " if readiness != "" else "", threat_text, safe_text]

func opponent_seat_threat_color(seat: int, viewer: int = 0) -> Color:
	var report = opponent_seat_threat_report(viewer, seat)
	return opponent_seat_threat_color_from_report(report)

func opponent_seat_threat_color_from_report(report: Dictionary) -> Color:
	match str(report.get("level", "")):
		"危":
			return Color(0.84, 0.20, 0.14, 0.96)
		"高":
			return Color(0.90, 0.54, 0.18, 0.96)
		"中":
			return Color(0.86, 0.72, 0.22, 0.94)
	return Color(0.32, 0.56, 0.48, 0.90)

func opponent_threat_level(score: float) -> String:
	if score >= 24.5:
		return "危"
	if score >= 16.0:
		return "高"
	if score >= 8.0:
		return "中"
	return "低"

func readiness_threat_level(score: float) -> String:
	if score >= 13.0:
		return "危"
	if score >= 9.5:
		return "高"
	if score >= 7.0:
		return "中"
	return "低"

func stronger_threat_level(left: String, right: String) -> String:
	return left if threat_level_rank(left) >= threat_level_rank(right) else right

func threat_level_rank(level: String) -> int:
	match level:
		"危":
			return 3
		"高":
			return 2
		"中":
			return 1
	return 0

func opponent_plan_pressure(opponent: int, eval_context: Dictionary = {}) -> float:
	var state = ai_context_opponent_state(eval_context, opponent)
	if not state.is_empty():
		return float(state.get("plan_pressure", 0.0))
	var pressure = opponent_honor_plan_threat(opponent, eval_context)
	for suit in range(3):
		pressure = max(pressure, opponent_suit_plan_threat(opponent, suit, eval_context))
	return pressure

func opponent_readiness_report(viewer: int, opponent: int, eval_context: Dictionary = {}) -> Dictionary:
	if viewer < 0 or viewer >= players.size() or opponent < 0 or opponent >= players.size() or viewer == opponent:
		return {"score": 0.0, "label": "", "reasons": []}
	var score = opponent_readiness_score(opponent, eval_context)
	var reasons: Array[String] = []
	var discards = players[opponent]["discards"].size()
	var melds = players[opponent]["melds"].size()
	var wall_count = get_wall_count()
	if discards >= 13:
		reasons.append("弃牌多")
	elif discards >= 10:
		reasons.append("中后盘")
	if melds >= 3:
		reasons.append("三副露")
	elif melds >= 2:
		reasons.append("两副露")
	elif melds == 1:
		reasons.append("一副露")
	if wall_count <= 24:
		reasons.append("末盘")
	elif wall_count <= 40:
		reasons.append("后盘")
	var plan = opponent_plan_pressure(opponent, eval_context)
	if plan >= 16.0:
		reasons.append("牌路集中")
	elif plan >= 8.0:
		reasons.append("有主线")
	return {
		"score": score,
		"label": opponent_readiness_label(score),
		"reasons": reasons,
	}

func opponent_readiness_score(opponent: int, eval_context: Dictionary = {}) -> float:
	if opponent < 0 or opponent >= players.size():
		return 0.0
	var state = ai_context_opponent_state(eval_context, opponent)
	if not state.is_empty():
		return float(state.get("readiness", 0.0))
	return opponent_readiness_score_from_plan(opponent, opponent_plan_pressure(opponent, eval_context))

func opponent_readiness_score_from_plan(opponent: int, plan_pressure: float) -> float:
	if opponent < 0 or opponent >= players.size():
		return 0.0
	var discards = players[opponent]["discards"].size()
	var melds = players[opponent]["melds"].size()
	var wall_progress = clamp(1.0 - float(get_wall_count()) / 84.0, 0.0, 1.0)
	var score = float(discards) * 0.45 + float(melds) * 2.15 + wall_progress * 5.2 + plan_pressure * 0.20
	if discards >= 10:
		score += 1.0
	if discards >= 13:
		score += 1.2
	if melds >= 2:
		score += 1.2
	if melds >= 3:
		score += 1.8
	var wall_count = get_wall_count()
	if wall_count <= 40:
		score += 1.0
	if wall_count <= 24:
		score += 1.2
	return score

func opponent_readiness_label(score: float) -> String:
	if score >= 13.0:
		return "疑听"
	if score >= 9.5:
		return "近听"
	if score >= 7.0:
		return "快进"
	return ""

func threat_safe_tile_labels(seat: int, plan_type: String, plan_suit: int, limit: int, eval_context: Dictionary = {}) -> Array:
	if seat < 0 or seat >= players.size() or limit <= 0:
		return []
	var seen: Dictionary = {}
	var best_tiles: Array[String] = []
	var best_scores: Array = []
	var best_sorts: Array = []
	for item in players[seat]["hand"]:
		var tile = str(item)
		if seen.has(tile):
			continue
		seen[tile] = true
		var safety = tile_safety_label(tile, seat, [], eval_context)
		var risk = float(tile_risk_vector(tile, seat, [], eval_context).get("score", 0.0))
		var score = -risk
		if safety == "安":
			score += 120.0
		elif safety == "熟":
			score += 72.0
		elif safety == "筋":
			score += 42.0
		elif safety == "壁":
			score += 34.0
		if plan_type == "suit" and tile_suit_index(tile) != plan_suit:
			score += 16.0
		if plan_type == "honor" and not is_honor_tile(tile):
			score += 12.0
		if is_terminal_or_honor(tile):
			score += 4.0
		var tile_sort = tile_sort_index(tile)
		var insert_at = best_tiles.size()
		for i in range(best_tiles.size()):
			var current_score = float(best_scores[i])
			if score > current_score or (is_equal_approx(score, current_score) and tile_sort < int(best_sorts[i])):
				insert_at = i
				break
		if best_tiles.size() < limit or insert_at < limit:
			best_tiles.insert(insert_at, tile)
			best_scores.insert(insert_at, score)
			best_sorts.insert(insert_at, tile_sort)
			if best_tiles.size() > limit:
				best_tiles.resize(limit)
				best_scores.resize(limit)
				best_sorts.resize(limit)
	var labels: Array[String] = []
	for i in range(best_tiles.size()):
		labels.append(tile_label(best_tiles[i]))
	return labels

func opponent_suit_plan_threat(opponent: int, suit: int, eval_context: Dictionary = {}) -> float:
	var state = ai_context_opponent_state(eval_context, opponent)
	if not state.is_empty():
		var threats = state.get("suit_plan_threats", [])
		if typeof(threats) == TYPE_ARRAY and suit >= 0 and suit < threats.size():
			return float(threats[suit])
	var meld_count = opponent_meld_count_for_suit(opponent, suit, eval_context)
	if meld_count <= 0:
		return 0.0
	var meld_tiles = opponent_meld_tile_count_for_suit(opponent, suit, eval_context)
	var suit_discards = opponent_discard_count_for_suit(opponent, suit, eval_context)
	var off_suit_discards = max(0, players[opponent]["discards"].size() - suit_discards)
	var score = float(meld_count) * 4.0 + float(meld_tiles) * 0.70 + min(5.0, float(off_suit_discards) * 0.45)
	if meld_count >= 2:
		score += 6.0
	if meld_count >= 3:
		score += 8.0
	if suit_discards == 0:
		score += 4.0
	elif suit_discards <= 2:
		score += 1.8
	return score

func opponent_honor_plan_threat(opponent: int, eval_context: Dictionary = {}) -> float:
	var state = ai_context_opponent_state(eval_context, opponent)
	if not state.is_empty():
		return float(state.get("honor_plan_threat", 0.0))
	var honor_melds = opponent_honor_meld_count(opponent, eval_context)
	if honor_melds <= 0:
		return 0.0
	return float(honor_melds) * 5.0 + float(players[opponent]["melds"].size()) * 0.9

func opponent_meld_count_for_suit(opponent: int, suit: int, eval_context: Dictionary = {}) -> int:
	var state = ai_context_opponent_state(eval_context, opponent)
	if not state.is_empty():
		var counts = state.get("meld_count_by_suit", [])
		if typeof(counts) == TYPE_ARRAY and suit >= 0 and suit < counts.size():
			return int(counts[suit])
	var count = 0
	for meld in players[opponent]["melds"]:
		for tile in meld:
			if tile_suit_index(str(tile)) == suit:
				count += 1
				break
	return count

func opponent_meld_tile_count_for_suit(opponent: int, suit: int, eval_context: Dictionary = {}) -> int:
	var state = ai_context_opponent_state(eval_context, opponent)
	if not state.is_empty():
		var counts = state.get("meld_tile_count_by_suit", [])
		if typeof(counts) == TYPE_ARRAY and suit >= 0 and suit < counts.size():
			return int(counts[suit])
	var count = 0
	for meld in players[opponent]["melds"]:
		for tile in meld:
			if tile_suit_index(str(tile)) == suit:
				count += 1
	return count

func opponent_discard_count_for_suit(opponent: int, suit: int, eval_context: Dictionary = {}) -> int:
	var state = ai_context_opponent_state(eval_context, opponent)
	if not state.is_empty():
		var counts = state.get("suit_discards", [])
		if typeof(counts) == TYPE_ARRAY and suit >= 0 and suit < counts.size():
			return int(counts[suit])
	var count = 0
	for tile in players[opponent]["discards"]:
		if tile_suit_index(str(tile)) == suit:
			count += 1
	return count

func opponent_honor_meld_count(opponent: int, eval_context: Dictionary = {}) -> int:
	var state = ai_context_opponent_state(eval_context, opponent)
	if not state.is_empty():
		return int(state.get("honor_meld_count", 0))
	var count = 0
	for meld in players[opponent]["melds"]:
		for tile in meld:
			if is_honor_tile(str(tile)):
				count += 1
				break
	return count

func tile_suit_index(tile: String) -> int:
	if not tile_metadata_ready:
		setup_tile_order()
	if tile_suit_cache.has(tile):
		return int(tile_suit_cache[tile])
	var index = tile_index(tile)
	if index < 0 or index >= 27:
		return -1
	return int(index / 9)

func suit_code(suit: int) -> String:
	match suit:
		0:
			return "W"
		1:
			return "T"
		2:
			return "B"
	return ""

func should_ai_gang_claim(seat: int, tile: String) -> bool:
	return bool(build_ai_claim_report(seat, "gang", tile).get("allow", false))

func should_ai_peng(seat: int, tile: String) -> bool:
	return bool(build_ai_claim_report(seat, "peng", tile).get("allow", false))

func should_ai_chi(seat: int, tile: String, choice: Dictionary) -> bool:
	return bool(build_ai_claim_report(seat, "chi", tile, choice).get("allow", false))

func choose_ai_concealed_gang(seat: int) -> String:
	if seat < 0 or seat >= players.size():
		return ""
	var best_tile = ""
	var best_score = -1000000.0
	for tile in TILE_CODES:
		var report = build_ai_self_gang_report(seat, tile, "concealed")
		if not bool(report.get("allow", false)):
			continue
		var score = float(report.get("score", 0.0))
		if best_tile == "" or score > best_score:
			best_tile = tile
			best_score = score
	return best_tile

func choose_ai_added_gang(seat: int) -> String:
	if seat < 0 or seat >= players.size():
		return ""
	var best_tile = ""
	var best_score = -1000000.0
	for tile in TILE_CODES:
		var report = build_ai_self_gang_report(seat, tile, "added")
		if not bool(report.get("allow", false)):
			continue
		var score = float(report.get("score", 0.0))
		if best_tile == "" or score > best_score:
			best_tile = tile
			best_score = score
	return best_tile

func build_ai_self_gang_report(seat: int, tile: String, gang_kind: String) -> Dictionary:
	var report: Dictionary = {
		"seat": seat,
		"tile": tile,
		"gang_kind": gang_kind,
		"allow": false,
		"reason": "非法杠",
		"before_shanten": 8,
		"after_shanten": 8,
		"before_plan_label": "",
		"score": -1000000.0,
		"pressure": 0.0,
		"defense": 0.0,
		"rob_risk": false,
		"declined_by_plan": false,
	}
	if seat < 0 or seat >= players.size() or tile == "":
		return report
	var hand: Array = players[seat]["hand"]
	var open_melds = players[seat]["melds"].size()
	var before_shanten = calculate_min_shanten(hand, open_melds)
	var before_plan_label = str(hand_plan_report_for_seat(seat, hand).get("label", ""))
	var after = hand.duplicate()
	var after_open_melds = open_melds
	match gang_kind:
		"concealed":
			if count_tile(hand, tile) < 4 or not remove_tiles(after, tile, 4):
				return report
			after_open_melds = open_melds + 1
		"added":
			if not can_added_gang(seat, tile) or not remove_tiles(after, tile, 1):
				return report
		_:
			return report
	var after_shanten = calculate_min_shanten(after, after_open_melds)
	var pressure = opponent_pressure_score(seat)
	var defense = ai_defense_weight(seat, before_shanten)
	var rob_risk = gang_kind == "added" and seat != 0 and can_win_for_seat(0, tile)
	report["before_shanten"] = before_shanten
	report["after_shanten"] = after_shanten
	report["before_plan_label"] = before_plan_label
	report["pressure"] = pressure
	report["defense"] = defense
	report["rob_risk"] = rob_risk
	report["score"] = ai_self_gang_action_score(report)
	var route_break = gang_kind == "concealed" and open_melds == 0 and (before_plan_label == "七对" or before_plan_label == "十三幺")
	if route_break:
		report["reason"] = "保%s" % before_plan_label
		report["declined_by_plan"] = true
	elif rob_risk:
		report["reason"] = "防抢杠"
	elif after_shanten > before_shanten:
		report["reason"] = "升向听"
	elif after_shanten < before_shanten:
		report["allow"] = true
		report["reason"] = "降向听"
	elif after_shanten <= 0:
		report["allow"] = true
		report["reason"] = "听牌杠"
	elif after_shanten <= 1 and float(report.get("score", 0.0)) >= 34.0:
		report["allow"] = true
		report["reason"] = "近听杠"
	elif float(report.get("score", 0.0)) >= ai_self_gang_score_threshold(gang_kind, before_shanten):
		report["allow"] = true
		report["reason"] = "牌值杠"
	else:
		report["reason"] = "杠牌收益不足"
	if bool(report.get("allow", false)) and pressure >= 6.8 and after_shanten >= 2 and not is_terminal_or_honor(tile):
		report["allow"] = false
		report["reason"] = "高压防守"
	return report

func ai_self_gang_action_score(report: Dictionary) -> float:
	if report.is_empty():
		return -1000000.0
	var gang_kind = str(report.get("gang_kind", ""))
	var tile = str(report.get("tile", ""))
	var before_shanten = int(report.get("before_shanten", 8))
	var after_shanten = int(report.get("after_shanten", before_shanten))
	var shanten_gain = max(0, before_shanten - after_shanten)
	var score = 44.0 if gang_kind == "concealed" else 36.0
	score += float(shanten_gain) * 46.0
	if after_shanten <= 0:
		score += 38.0
	elif after_shanten == 1:
		score += 22.0
	if is_honor_tile(tile):
		score += 18.0
	elif is_terminal_or_honor(tile):
		score += 10.0
	var seat = int(report.get("seat", -1))
	var attack = ai_total_attack_multiplier(seat)
	score *= ai_gang_aggression(seat)
	score += max(0.0, attack - 1.0) * 36.0
	var pressure = float(report.get("pressure", 0.0))
	var defense = float(report.get("defense", 0.0))
	if after_shanten >= 2:
		score -= pressure * 0.90 + defense * 8.0
	else:
		score -= pressure * 0.28
	if gang_kind == "added":
		score -= 6.0
	if bool(report.get("rob_risk", false)):
		score -= 1000.0
	if bool(report.get("declined_by_plan", false)):
		score -= 1000.0
	return score

func ai_self_gang_score_threshold(gang_kind: String, before_shanten: int) -> float:
	if before_shanten <= 1:
		return 34.0
	if gang_kind == "concealed":
		return 54.0
	return 46.0

func first_concealed_gang_tile(seat: int) -> String:
	if seat < 0 or seat >= players.size():
		return ""
	for tile in TILE_CODES:
		if count_tile(players[seat]["hand"], tile) >= 4:
			return tile
	return ""

func first_added_gang_tile(seat: int) -> String:
	if seat < 0 or seat >= players.size():
		return ""
	for tile in TILE_CODES:
		if can_added_gang(seat, tile):
			return tile
	return ""

func best_chi_choice(hand: Array, tile: String) -> Dictionary:
	return best_chi_choice_from_counts(tile_counts(hand), tile)

func best_chi_choice_from_counts(hand_counts: Array, tile: String) -> Dictionary:
	var choices = get_chi_choices_from_counts(hand_counts, tile)
	var best: Dictionary = {}
	var best_score = -100000.0
	for choice in choices:
		var needed: Array = choice.get("needed", [])
		if not consume_tile_list_counts(hand_counts, needed):
			continue
		var score = evaluate_ai_hand_from_counts(hand_counts)
		restore_tile_list_counts(hand_counts, needed)
		if score > best_score:
			best_score = score
			best = choice
			best["score"] = score
	return best

func get_chi_choices(hand: Array, tile: String) -> Array:
	return get_chi_choices_from_counts(tile_counts(hand), tile)

func get_chi_choices_from_counts(hand_counts: Array, tile: String) -> Array:
	var choices: Array = []
	var index = tile_index(tile)
	if index < 0 or index >= 27 or hand_counts.is_empty():
		return choices
	var rank = index % 9
	var suit_start = index - rank
	for offset in range(3):
		var start_rank = rank - offset
		if start_rank < 0 or start_rank > 6:
			continue
		var first_index = suit_start + start_rank
		var second_index = first_index + 1
		var third_index = first_index + 2
		var need_a = second_index if index == first_index else first_index
		var need_b = second_index if index == third_index else third_index
		if need_a < 0 or need_b < 0 or need_b >= hand_counts.size():
			continue
		if int(hand_counts[need_a]) <= 0 or int(hand_counts[need_b]) <= 0:
			continue
		choices.append({
			"needed": [TILE_CODES[need_a], TILE_CODES[need_b]],
			"meld": [TILE_CODES[first_index], TILE_CODES[second_index], TILE_CODES[third_index]],
		})
	return choices

func is_valid_pending_chi_choice(choice: Dictionary) -> bool:
	var choices: Array = offline_pending_claim.get("chi_choices", [])
	if choices.is_empty():
		return true
	for item in choices:
		if typeof(item) != TYPE_DICTIONARY:
			continue
		if same_tile_list(item.get("meld", []), choice.get("meld", [])) and same_tile_list(item.get("needed", []), choice.get("needed", [])):
			return true
	return false

func same_tile_list(left: Array, right: Array) -> bool:
	if left.size() != right.size():
		return false
	for i in range(left.size()):
		if str(left[i]) != str(right[i]):
			return false
	return true

func claim_options_text(pending: Dictionary) -> String:
	var names: Array[String] = []
	for claim in pending.get("options", []):
		var claim_name = str(claim)
		if claim_name == "chi":
			var chi_choices: Array = pending.get("chi_choices", [])
			if chi_choices.is_empty():
				names.append(claim_label(claim_name))
			else:
				for choice in chi_choices:
					if typeof(choice) == TYPE_DICTIONARY:
						names.append(chi_choice_label(choice))
		else:
			names.append(claim_label(claim_name))
	return " / ".join(names)

func chi_choice_label(choice: Dictionary) -> String:
	return "吃" + compact_tile_run_label(choice.get("meld", []))

func compact_tile_run_label(tiles: Array) -> String:
	if tiles.is_empty():
		return ""
	var first = str(tiles[0])
	if is_number_tile(first):
		var suit = first.right(1)
		var ranks = ""
		var same_suit = true
		for tile in tiles:
			var code = str(tile)
			if not is_number_tile(code) or code.right(1) != suit:
				same_suit = false
				break
			ranks += code.left(code.length() - 1)
		if same_suit:
			return ranks + suit_label(suit)
	var labels: Array[String] = []
	for tile in tiles:
		labels.append(tile_label(str(tile)))
	return "".join(labels)

func is_number_tile(tile: String) -> bool:
	if not tile_metadata_ready:
		setup_tile_order()
	if tile_number_cache.has(tile):
		return bool(tile_number_cache[tile])
	return tile.ends_with("W") or tile.ends_with("T") or tile.ends_with("B")

func suit_label(suit: String) -> String:
	match suit:
		"W":
			return "万"
		"T":
			return "条"
		"B":
			return "筒"
	return suit

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

func tile_base_value(index: int) -> float:
	if index < 0 or index >= TILE_BASE_VALUES.size():
		return 0.0
	return float(TILE_BASE_VALUES[index])

func has_neighbor(counts: Array, index: int, delta: int) -> bool:
	var neighbor = index + delta
	if neighbor < 0 or neighbor >= 27:
		return false
	return index / 9 == neighbor / 9 and int(counts[neighbor]) > 0

func can_feed_chi(tile: String) -> bool:
	var index = tile_index(tile)
	return index >= 0 and index < 27

func is_middle_number_tile(tile: String) -> bool:
	var index = tile_index(tile)
	if index < 0 or index >= 27:
		return false
	var rank = index % 9
	return rank >= 2 and rank <= 6

func same_suit_pressure(seat: int, tile: String, eval_context: Dictionary = {}) -> bool:
	var index = tile_index(tile)
	if index < 0 or index >= 27:
		return false
	var suit = index / 9
	var state = ai_context_opponent_state(eval_context, seat)
	if not state.is_empty():
		var counts = state.get("suit_discards", [])
		if typeof(counts) == TYPE_ARRAY and suit >= 0 and suit < counts.size():
			return int(counts[suit]) >= 3
	var count = 0
	for discarded in players[seat]["discards"]:
		var discarded_index = tile_index(str(discarded))
		if discarded_index >= 0 and discarded_index < 27 and discarded_index / 9 == suit:
			count += 1
	return count >= 3

func is_honor_tile(tile: String) -> bool:
	if not tile_metadata_ready:
		setup_tile_order()
	if tile_honor_cache.has(tile):
		return bool(tile_honor_cache[tile])
	var index = tile_index(tile)
	return index >= 27

func is_terminal_or_honor(tile: String) -> bool:
	if not tile_metadata_ready:
		setup_tile_order()
	if tile_terminal_or_honor_cache.has(tile):
		return bool(tile_terminal_or_honor_cache[tile])
	var index = tile_index(tile)
	if index >= 27:
		return true
	if index < 0:
		return false
	var rank = index % 9
	return rank == 0 or rank == 8

func is_simple_number_tile(tile: String) -> bool:
	if not tile_metadata_ready:
		setup_tile_order()
	if tile_simple_number_cache.has(tile):
		return bool(tile_simple_number_cache[tile])
	var index = tile_index(tile)
	if index < 0 or index >= 27:
		return false
	var rank = index % 9
	return rank >= 1 and rank <= 7

func visible_tile_counts() -> Array:
	var counts = make_empty_tile_counts()
	for seat in range(players.size()):
		add_visible_tile_counts(counts, players[seat]["discards"])
		for meld in players[seat]["melds"]:
			add_visible_tile_counts(counts, meld)
	return counts

func add_visible_tile_counts(counts: Array, tiles: Array) -> void:
	for tile in tiles:
		var index = tile_index(str(tile))
		if index >= 0 and index < counts.size():
			counts[index] = int(counts[index]) + 1

func visible_tile_count(tile: String) -> int:
	var visible = 0
	for seat in range(players.size()):
		visible += count_tile(players[seat]["discards"], tile)
		for meld in players[seat]["melds"]:
			visible += count_tile(meld, tile)
	return visible

func visible_tile_count_from_counts(tile: String, visible_counts_snapshot: Array = []) -> int:
	if visible_counts_snapshot.is_empty():
		return visible_tile_count(tile)
	var index = tile_index(tile)
	if index < 0 or index >= visible_counts_snapshot.size():
		return 0
	return int(visible_counts_snapshot[index])

func is_pure_one_suit_hand(seat: int, tiles: Array) -> bool:
	var suit = ""
	var has_number = false
	for tile in all_scoring_tiles(seat, tiles):
		var code = str(tile)
		if is_honor_tile(code):
			return false
		has_number = true
		var current = code.right(1)
		if suit == "":
			suit = current
		elif suit != current:
			return false
	return has_number

func is_mixed_one_suit_hand(seat: int, tiles: Array) -> bool:
	var suit = ""
	var has_number = false
	var has_honor = false
	for tile in all_scoring_tiles(seat, tiles):
		var code = str(tile)
		if is_honor_tile(code):
			has_honor = true
			continue
		has_number = true
		var current = code.right(1)
		if suit == "":
			suit = current
		elif suit != current:
			return false
	return has_number and has_honor

func is_all_simples_hand(seat: int, tiles: Array) -> bool:
	var has_tile = false
	for tile in all_scoring_tiles(seat, tiles):
		var code = str(tile)
		if not is_simple_number_tile(code):
			return false
		has_tile = true
	return has_tile

func is_big_three_dragons_hand(seat: int, tiles: Array) -> bool:
	return int(honor_group_stats(seat, tiles, DRAGON_CODES).get("triplets", 0)) == DRAGON_CODES.size()

func is_small_three_dragons_hand(seat: int, tiles: Array) -> bool:
	var stats = honor_group_stats(seat, tiles, DRAGON_CODES)
	return int(stats.get("triplets", 0)) == 2 and int(stats.get("pairs", 0)) >= 1

func is_big_four_winds_hand(seat: int, tiles: Array) -> bool:
	return int(honor_group_stats(seat, tiles, WIND_CODES).get("triplets", 0)) == WIND_CODES.size()

func is_small_four_winds_hand(seat: int, tiles: Array) -> bool:
	var stats = honor_group_stats(seat, tiles, WIND_CODES)
	return int(stats.get("triplets", 0)) == 3 and int(stats.get("pairs", 0)) >= 1

func honor_group_stats(seat: int, tiles: Array, codes: Array) -> Dictionary:
	return honor_group_stats_from_counts(tile_counts(all_scoring_tiles(seat, tiles)), codes)

func honor_group_stats_from_counts(counts: Array, codes: Array) -> Dictionary:
	var triplets = 0
	var pairs = 0
	var singles = 0
	var tile_total = 0
	for code in codes:
		var index = tile_index(str(code))
		if index < 0 or index >= counts.size():
			continue
		var amount = int(counts[index])
		tile_total += amount
		if amount >= 3:
			triplets += 1
		elif amount == 2:
			pairs += 1
		elif amount == 1:
			singles += 1
	return {
		"triplets": triplets,
		"pairs": pairs,
		"singles": singles,
		"tiles": tile_total,
	}

func is_all_honor_hand(seat: int, tiles: Array) -> bool:
	for tile in all_scoring_tiles(seat, tiles):
		if not is_honor_tile(str(tile)):
			return false
	return true

func is_full_straight_hand(seat: int, tiles: Array) -> bool:
	return full_straight_suit(seat, tiles) >= 0

func full_straight_suit(seat: int, tiles: Array) -> int:
	var ranks_by_suit: Array = []
	for suit in range(3):
		var ranks: Dictionary = {}
		ranks_by_suit.append(ranks)
	for tile in all_scoring_tiles(seat, tiles):
		var code = str(tile)
		if not is_number_tile(code):
			continue
		var index = tile_index(code)
		if index < 0 or index >= 27:
			continue
		var suit = int(index / 9)
		var rank = index % 9
		(ranks_by_suit[suit] as Dictionary)[rank] = true
	for suit in range(3):
		var ranks: Dictionary = ranks_by_suit[suit]
		var complete = true
		for rank in range(9):
			if not ranks.has(rank):
				complete = false
				break
		if complete:
			return suit
	return -1

func is_all_triplet_hand(seat: int, tiles: Array) -> bool:
	for meld in players[seat]["melds"]:
		if meld.size() < 3:
			return false
		var first = str(meld[0])
		for tile in meld:
			if str(tile) != first:
				return false
	return can_form_triplets_with_pair(tiles)

func can_form_triplets_with_pair(tiles: Array) -> bool:
	if tiles.size() % 3 != 2:
		return false
	var counts = tile_counts(tiles)
	var pair_found = false
	for count in counts:
		var amount = int(count)
		if amount == 0:
			continue
		if amount == 2 and not pair_found:
			pair_found = true
		elif amount == 3:
			continue
		else:
			return false
	return pair_found

func all_scoring_tiles(seat: int, tiles: Array) -> Array:
	var result = tiles.duplicate()
	for meld in players[seat]["melds"]:
		for tile in meld:
			result.append(tile)
	return result

func count_gang_melds(seat: int) -> int:
	var amount = 0
	for meld in players[seat]["melds"]:
		if meld.size() == 4:
			amount += 1
	return amount

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

func make_tile_view(tile: String, size: Vector2, clickable: bool, callback: Callable, highlighted: bool = false, risk: String = "", hint_badge: String = "") -> Control:
	var lightweight_static_tile = should_use_lightweight_static_tile(clickable, size)
	var frame: Control = null
	var tile_body: Control
	var button: Button = null
	if lightweight_static_tile:
		var panel = Panel.new()
		panel.custom_minimum_size = size
		panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		panel.clip_contents = true
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tile_body = panel
	elif clickable:
		frame = Control.new()
		frame.custom_minimum_size = size
		frame.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		frame.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		frame.mouse_filter = Control.MOUSE_FILTER_PASS
		frame.clip_contents = true
		button = Button.new()
		button.text = ""
		button.custom_minimum_size = size
		button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		button.clip_contents = true
		configure_touch_button(button)
		tile_body = button
	else:
		frame = Control.new()
		frame.custom_minimum_size = size
		frame.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		frame.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		frame.mouse_filter = Control.MOUSE_FILTER_PASS
		frame.clip_contents = true
		var panel = Panel.new()
		panel.custom_minimum_size = size
		panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		panel.clip_contents = true
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tile_body = panel
	if frame != null:
		frame.add_child(tile_body)
		apply_centered_rect(tile_body, Vector2(0.5, 0.5), size)
	var risk_text = risk_badge_text(risk)
	var border = tile_risk_color(risk) if risk_text != "" else Color(0.55, 0.48, 0.30, 0.90)
	if highlighted:
		border = Color(0.80, 0.64, 0.26, 0.90)
	var face = Color(0.98, 0.96, 0.88, 1.0) if not highlighted else Color(0.99, 0.96, 0.84, 1.0)
	if button != null:
		button.add_theme_stylebox_override("normal", style(face, 8, border, 2 if not highlighted else 2))
		button.add_theme_stylebox_override("hover", style(Color(0.93, 0.91, 0.80), 8, Color(0.74, 0.60, 0.22), 2))
		button.add_theme_stylebox_override("pressed", style(Color(0.78, 0.74, 0.60), 8, Color(0.46, 0.40, 0.24), 2))
		button.add_theme_stylebox_override("disabled", style(face.darkened(0.14), 8, border.darkened(0.16), 1 if not highlighted else 2))
	else:
		(tile_body as Panel).add_theme_stylebox_override("panel", style(face, 8, border, 2 if not highlighted else 2, static_tile_shadow_size(size)))
	var tile_texture = tile_textures.get(tile, null)
	if tile_texture != null:
		if not lightweight_static_tile:
			var shade = ColorRect.new()
			shade.color = Color(0.66, 0.60, 0.42, 0.24)
			shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
			shade.set_anchors_preset(Control.PRESET_FULL_RECT)
			shade.offset_left = size.x * 0.78
			shade.offset_top = size.y * 0.06
			shade.offset_right = -2
			shade.offset_bottom = -2
			tile_body.add_child(shade)
		var texture = TextureRect.new()
		texture.texture = tile_texture
		texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		texture.modulate = Color(1, 1, 1, tile_art_alpha(tile, size))
		texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
		texture.set_anchors_preset(Control.PRESET_FULL_RECT)
		var inset_x = max(2, int(size.x * 0.07)) if lightweight_static_tile else max(3, int(size.x * 0.08))
		var inset_y = max(2, int(size.y * 0.06)) if lightweight_static_tile else max(3, int(size.y * 0.07))
		texture.offset_left = inset_x
		texture.offset_top = inset_y
		texture.offset_right = -inset_x
		texture.offset_bottom = -inset_y
		tile_body.add_child(texture)
	if should_draw_tile_face_label(tile, tile_texture, lightweight_static_tile):
		if lightweight_static_tile:
			draw_compact_tile_face(tile_body, tile, size)
		else:
			draw_tile_face(tile_body, tile, size)
	if should_draw_tile_corner(clickable, size, tile_texture, lightweight_static_tile):
		var corner = Label.new()
		corner.text = tile_corner(tile)
		corner.mouse_filter = Control.MOUSE_FILTER_IGNORE
		corner.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		corner.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		corner.add_theme_font_size_override("font_size", max(9, int(size.y * 0.16)))
		corner.add_theme_color_override("font_color", tile_accent(tile))
		tile_body.add_child(corner)
		apply_rect(corner, rect_full(0.08, 0.04, 0.45, 0.30))
	if TILE_TEXT_OVERLAYS_ENABLED and risk_text != "":
		var badge = make_label(tile_body, risk_text, max(9, int(size.y * 0.14)), Color(1.0, 0.98, 0.90), true)
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var risk_color = tile_risk_color(risk)
		badge.add_theme_stylebox_override("normal", style(risk_color.darkened(0.20), 8, risk_color.lightened(0.16), 1))
		apply_rect(badge, rect_full(0.12, 0.76, 0.88, 0.96))
	if TILE_TEXT_OVERLAYS_ENABLED and hint_badge != "":
		var hint = make_label(tile_body, hint_badge, max(9, int(size.y * 0.13)), Color(0.09, 0.12, 0.08), true)
		hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hint.clip_text = true
		var hint_color = tile_hint_badge_color(hint_badge)
		hint.add_theme_stylebox_override("normal", style(hint_color, 8, hint_color.lightened(0.16), 1))
		var left = 0.50 if hint_badge.length() > 1 else 0.62
		apply_rect(hint, rect_full(left, 0.04, 0.92, 0.23))
	if button != null and callback.is_valid():
		connect_immediate_button_action(button, callback)
	return tile_body if lightweight_static_tile else frame

func tile_hint_badge_color(hint_badge: String) -> Color:
	return HINT_BADGE_COLORS.get(hint_badge, DEFAULT_HINT_BADGE_COLOR)

func should_draw_tile_corner(clickable: bool, size: Vector2, texture: Texture2D, _lightweight_static_tile: bool) -> bool:
	return TILE_TEXT_OVERLAYS_ENABLED and texture == null and (clickable or size.x >= 50.0)

func should_use_lightweight_static_tile(clickable: bool, size: Vector2) -> bool:
	return not clickable and size.x < 50.0

func static_tile_shadow_size(size: Vector2) -> int:
	if size.x < 50.0:
		return 0
	if size.x < 60.0:
		return 3
	return 8

func should_draw_tile_face_label(tile: String, texture: Texture2D, _lightweight_static_tile: bool) -> bool:
	return TILE_TEXT_OVERLAYS_ENABLED and tile != "" and texture == null

func tile_art_alpha(tile: String, size: Vector2) -> float:
	if size.x < 30.0:
		return 0.62
	if size.x >= 50.0:
		return 1.0
	if is_flower_tile(tile):
		return 0.94
	if is_honor_tile(tile):
		return 0.94
	return 0.96

func draw_tile_face(parent: Control, tile: String, size: Vector2) -> void:
	var main = make_label(parent, tile_face_main(tile), tile_face_font_size(size), tile_accent(tile), true)
	main.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main.clip_text = true
	var sub_text = tile_face_sub(tile)
	if is_number_tile(tile):
		apply_rect(main, rect_full(0.18, 0.22, 0.82, 0.64))
	else:
		apply_rect(main, rect_full(0.12, 0.20, 0.88, 0.72))
	if sub_text != "" and size.y >= 40:
		var sub = make_label(parent, sub_text, max(9, int(size.y * 0.20)), tile_accent(tile).darkened(0.08), true)
		sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
		sub.clip_text = true
		apply_rect(sub, rect_full(0.16, 0.58, 0.84, 0.83))

func draw_compact_tile_face(parent: Control, tile: String, size: Vector2) -> void:
	var face = make_label(parent, tile_label(tile), compact_tile_face_font_size(size), tile_accent(tile), true)
	face.mouse_filter = Control.MOUSE_FILTER_IGNORE
	face.clip_text = true
	apply_rect(face, rect_full(0.08, 0.15, 0.92, 0.85))

func tile_face_main(tile: String) -> String:
	if not tile_metadata_ready:
		setup_tile_order()
	if tile_face_main_cache.has(tile):
		return str(tile_face_main_cache[tile])
	if is_number_tile(tile):
		return tile.left(tile.length() - 1)
	return tile_label(tile)

func tile_face_sub(tile: String) -> String:
	if not tile_metadata_ready:
		setup_tile_order()
	if tile_face_sub_cache.has(tile):
		return str(tile_face_sub_cache[tile])
	if tile.ends_with("W"):
		return "万"
	if tile.ends_with("T"):
		return "条"
	if tile.ends_with("B"):
		return "筒"
	if is_flower_tile(tile):
		return "花"
	if ["E", "S", "N", "R"].has(tile):
		return "风"
	if ["Z", "F", "P"].has(tile):
		return "箭"
	return ""

func tile_face_font_size(size: Vector2) -> int:
	return max(10, int(size.y * 0.42))

func compact_tile_face_font_size(size: Vector2) -> int:
	return max(9, int(size.y * 0.32))

func risk_badge_text(risk: String) -> String:
	return RISK_BADGE_TEXT.get(risk, "")

func tile_risk_color(risk: String) -> Color:
	return RISK_BADGE_COLORS.get(risk, DEFAULT_RISK_BADGE_COLOR)

func make_action_button(text: String, color: Color, callback: Callable) -> Button:
	var button = make_base_button(text, callback)
	configure_action_button_size(button, ACTION_BUTTON_MIN_TOUCH_WIDTH, ACTION_BUTTON_HEIGHT, 19)
	apply_button_style(button, color, 14, 2, 3)
	return button

func configure_action_button_size(button: Button, width: float, height: float, font_size: int) -> void:
	button.custom_minimum_size = Vector2(width, height)
	button.clip_text = true
	button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	button.add_theme_font_size_override("font_size", font_size)

func make_avatar_view(seat: int, active: bool) -> Control:
	var avatar = Panel.new()
	avatar.clip_contents = true
	avatar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var border = Color(0.66, 0.58, 0.40, 0.52) if active else SEAT_AVATAR_BORDER_COLORS[seat].blend(Color(0.28, 0.27, 0.26, 1.0))
	avatar.add_theme_stylebox_override("panel", style(Color(0.018, 0.038, 0.042, 0.96), 13, border, 1))
	var band = ColorRect.new()
	band.color = SEAT_AVATAR_BAND_COLORS[seat].blend(Color(0.12, 0.14, 0.14, 1.0))
	band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	avatar.add_child(band)
	apply_rect(band, rect_full(0.0, 0.0, 1.0, 0.22))
	var cap = ColorRect.new()
	cap.color = Color(1.0, 1.0, 1.0, 0.045)
	cap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	avatar.add_child(cap)
	apply_rect(cap, rect_full(0.0, 0.22, 1.0, 0.26))
	var seat_mark = make_label(avatar, seat_wind_label(seat), 33, Color(0.88, 0.82, 0.66), true)
	seat_mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(seat_mark, rect_full(0.10, 0.22, 0.90, 0.70))
	var name = make_label(avatar, seat_short_name(seat), 12, Color(0.70, 0.80, 0.76), false)
	name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(name, rect_full(0.08, 0.68, 0.92, 0.90))
	if active:
		var active_badge = make_label(avatar, "行牌", 11, Color(0.12, 0.13, 0.10), true)
		active_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		active_badge.add_theme_stylebox_override("normal", style(Color(0.66, 0.56, 0.22, 0.82), 8, Color(0.84, 0.76, 0.46, 0.22), 1))
		apply_rect(active_badge, rect_full(0.18, 0.06, 0.82, 0.25))
	return avatar

func seat_wind_label(seat: int) -> String:
	match seat:
		0:
			return "东"
		1:
			return "南"
		2:
			return "西"
		3:
			return "北"
	return "位"

func seat_short_name(seat: int) -> String:
	if seat >= 0 and seat < SEAT_NAMES.size():
		if seat == 0:
			return "你"
		return SEAT_NAMES[seat].substr(0, 2)
	return "玩家"

func add_background(parent: Control) -> void:
	var bg = TextureRect.new()
	bg.texture = wood_texture
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	parent.add_child(bg)
	var tint = ColorRect.new()
	tint.color = Color(0.010, 0.013, 0.015, 0.988)
	tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tint.set_anchors_preset(Control.PRESET_FULL_RECT)
	parent.add_child(tint)
	parent.add_child(make_color_rect(rect_full(0.0, 0.0, 1.0, 0.08), Color(0.0, 0.0, 0.0, 0.006)))
	parent.add_child(make_color_rect(rect_full(0.0, 0.90, 1.0, 1.0), Color(0.0, 0.0, 0.0, 0.028)))
	parent.add_child(make_color_rect(rect_full(0.0, 0.0, 0.03, 1.0), Color(0.0, 0.0, 0.0, 0.006)))
	parent.add_child(make_color_rect(rect_full(0.97, 0.0, 1.0, 1.0), Color(0.0, 0.0, 0.0, 0.006)))
	parent.add_child(make_color_rect(rect_full(0.10, 0.08, 0.90, 0.92), Color(0.010, 0.016, 0.018, 0.002)))
	parent.add_child(make_color_rect(rect_full(0.21, 0.16, 0.79, 0.84), Color(0.014, 0.022, 0.024, 0.001)))
	parent.add_child(make_color_rect(rect_full(0.02, 0.02, 0.98, 0.03), Color(0.62, 0.56, 0.42, 0.002)))
	parent.add_child(make_color_rect(rect_full(0.02, 0.97, 0.98, 0.98), Color(0.03, 0.03, 0.04, 0.036)))
	parent.add_child(make_color_rect(rect_full(0.02, 0.03, 0.03, 0.97), Color(0.03, 0.03, 0.04, 0.036)))
	parent.add_child(make_color_rect(rect_full(0.97, 0.03, 0.98, 0.97), Color(0.03, 0.03, 0.04, 0.036)))

func add_texture(parent: Control, texture: Texture2D, rect: Rect2, alpha: float) -> TextureRect:
	var tex = TextureRect.new()
	tex.texture = texture
	tex.modulate = Color(1, 1, 1, alpha)
	tex.stretch_mode = TextureRect.STRETCH_SCALE
	tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(tex, rect)
	parent.add_child(tex)
	return tex

func make_color_rect(rect: Rect2, color: Color) -> ColorRect:
	var color_rect = ColorRect.new()
	color_rect.color = color
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(color_rect, rect)
	return color_rect

func make_panel(parent: Control, rect: Rect2, color: Color, radius: int, border: Color, shadow_size: int = 7) -> Panel:
	var panel = Panel.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_rect(panel, rect)
	var fill_color = soften_panel_color(color)
	panel.add_theme_stylebox_override("panel", style(fill_color, radius, border.blend(UI_PANEL_BORDER).darkened(0.10), 1, max(0, shadow_size - 3)))
	parent.add_child(panel)
	return panel

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

func make_small_button(text: String, color: Color, callback: Callable) -> Button:
	var button = make_base_button(text, callback)
	button.custom_minimum_size = Vector2(104, 44)
	button.add_theme_font_size_override("font_size", 18)
	apply_button_style(button, color, 11, 2, 3)
	return button

func make_top_hud_button(text: String, color: Color, callback: Callable) -> Button:
	var button = make_base_button(text, callback)
	button.custom_minimum_size = TOP_HUD_BUTTON_SIZE
	button.clip_text = true
	button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	button.add_theme_font_size_override("font_size", 15)
	apply_button_style(button, color, 10, 2, 2)
	return button

func make_base_button(text: String, callback: Callable) -> Button:
	var button = Button.new()
	button.text = text
	configure_touch_button(button)
	button.add_theme_color_override("font_color", Color(0.94, 0.91, 0.80))
	button.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.45))
	button.add_theme_constant_override("shadow_offset_x", 1)
	button.add_theme_constant_override("shadow_offset_y", 1)
	if callback.is_valid():
		connect_immediate_button_action(button, callback)
	return button

func configure_touch_button(button: Button) -> void:
	button.focus_mode = Control.FOCUS_NONE
	button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	# v1.0.152: 移除音频唤醒连接，改为全局_input处理，减少按钮延迟

func connect_immediate_button_action(button: Button, callback: Callable) -> void:
	if button == null or not callback.is_valid():
		return
	button.button_down.connect(callback)

func apply_button_style(button: Button, color: Color, radius: int, border_width: int = 2, shadow_size: int = 8) -> void:
	var style_set = button_style_set(color, radius, border_width, shadow_size)
	button.add_theme_stylebox_override("normal", style_set["normal"])
	button.add_theme_stylebox_override("hover", style_set["hover"])
	button.add_theme_stylebox_override("pressed", style_set["pressed"])

func button_style_set(color: Color, radius: int, border_width: int = 2, shadow_size: int = 8) -> Dictionary:
	var key = button_style_set_cache_key(color, radius, border_width, shadow_size)
	if button_style_set_cache.has(key):
		return button_style_set_cache[key]
	var fill = soften_button_color(color)
	var cached_set = {
		"normal": style(fill.darkened(0.26), radius, fill.darkened(0.15), border_width, shadow_size),
		"hover": style(fill.darkened(0.21), radius, fill.darkened(0.11), border_width, shadow_size + 1),
		"pressed": style(fill.darkened(0.29), radius, fill.darkened(0.17), border_width, max(0, shadow_size - 1)),
	}
	store_button_style_set_cache(key, cached_set)
	return cached_set

func input_style_set() -> Dictionary:
	var key = "default"
	if input_style_set_cache.has(key):
		return input_style_set_cache[key]
	var cached_set = {
		"normal": style(Color(0.032, 0.040, 0.044, 0.96), 10, Color(0.30, 0.36, 0.34, 0.28), 1, 0),
		"focus": style(Color(0.040, 0.052, 0.056, 0.98), 10, Color(0.56, 0.52, 0.30, 0.56), 1, 0),
		"read_only": style(Color(0.026, 0.032, 0.036, 0.94), 10, Color(0.18, 0.22, 0.22, 0.20), 1, 0),
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
	var key = style_cache_key(color, radius, border, border_width, shadow_size)
	if style_cache.has(key):
		return style_cache[key]
	var box = StyleBoxFlat.new()
	box.bg_color = color
	box.set_corner_radius_all(radius)
	box.set_border_width_all(border_width)
	box.border_color = border
	box.shadow_color = UI_PANEL_SHADOW
	box.shadow_size = shadow_size
	if shadow_size > 0:
		box.shadow_offset = Vector2(0, 1)
	store_style_cache(key, box)
	return box

func soften_panel_color(color: Color) -> Color:
	return Color(
		color.r * 0.15 + UI_PANEL_FILL.r * 0.85,
		color.g * 0.15 + UI_PANEL_FILL.g * 0.85,
		color.b * 0.15 + UI_PANEL_FILL.b * 0.85,
		min(1.0, color.a)
	)

func soften_button_color(color: Color) -> Color:
	return Color(
		color.r * 0.18 + UI_PANEL_FILL.r * 0.82,
		color.g * 0.18 + UI_PANEL_FILL.g * 0.82,
		color.b * 0.18 + UI_PANEL_FILL.b * 0.82,
		min(1.0, color.a)
	)

func soften_menu_color(color: Color) -> Color:
	return Color(
		color.r * 0.14 + UI_PANEL_FILL.r * 0.86,
		color.g * 0.14 + UI_PANEL_FILL.g * 0.86,
		color.b * 0.14 + UI_PANEL_FILL.b * 0.86,
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

# ===== 动画 / 特效 (FX) =====
# fx_layer 是 self 的直接子节点，覆盖整个视口并在 clear_screen 中被保留。
# 所有动画节点挂在其下，因此整桌每次 render_game 重建时补间动画不会被中断。
# 所有动效都使用持久节点上的 tween 驱动，fx 关闭或离开牌桌时立刻清空，空闲时零开销。

func ensure_fx_layer() -> void:
	if fx_layer != null and is_instance_valid(fx_layer):
		return
	fx_layer = Control.new()
	fx_layer.name = "FxLayer"
	fx_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	fx_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fx_layer.z_index = FX_LAYER_Z_INDEX
	add_child(fx_layer)
	_build_fx_turn_pulse()
	_build_fx_burst()
	_build_fx_ripple()

func _build_fx_turn_pulse() -> void:
	fx_turn_pulse = Control.new()
	fx_turn_pulse.name = "TurnPulse"
	fx_turn_pulse.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fx_turn_pulse.visible = false
	fx_layer.add_child(fx_turn_pulse)
	fx_turn_glow = Panel.new()
	fx_turn_glow.name = "TurnGlow"
	fx_turn_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fx_turn_glow.set_anchors_preset(Control.PRESET_FULL_RECT)
	fx_turn_glow.modulate.a = 0.0
	fx_turn_pulse.add_child(fx_turn_glow)
	fx_turn_pulse_tween = create_tween()
	fx_turn_pulse_tween.set_loops()
	var half_pulse := float(FX_TURN_PULSE_PERIOD_MSEC) / 2000.0
	fx_turn_pulse_tween.tween_property(fx_turn_glow, "modulate:a", 0.95, half_pulse).from(0.40)
	fx_turn_pulse_tween.tween_property(fx_turn_glow, "modulate:a", 0.40, half_pulse).from(0.95)
	fx_turn_pulse_tween.pause()

func _build_fx_burst() -> void:
	fx_burst_root = Control.new()
	fx_burst_root.name = "WinBurst"
	fx_burst_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fx_burst_root.visible = false
	fx_layer.add_child(fx_burst_root)
	fx_burst_flash = ColorRect.new()
	fx_burst_flash.name = "Flash"
	fx_burst_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fx_burst_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	fx_burst_flash.color = Color(1.0, 0.90, 0.55, 0.0)
	fx_burst_root.add_child(fx_burst_flash)
	fx_burst_rings.clear()
	for i in range(FX_WIN_RING_COUNT):
		var ring = Panel.new()
		ring.name = "Ring%d" % i
		ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ring.set_anchors_preset(Control.PRESET_CENTER)
		fx_burst_root.add_child(ring)
		fx_burst_rings.append(ring)
	fx_burst_label = Label.new()
	fx_burst_label.name = "BurstLabel"
	fx_burst_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fx_burst_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	fx_burst_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	fx_burst_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	fx_burst_label.add_theme_font_size_override("font_size", FX_BURST_LABEL_FONT_SIZE)
	fx_burst_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.72))
	fx_burst_label.add_theme_constant_override("shadow_offset_x", 2)
	fx_burst_label.add_theme_constant_override("shadow_offset_y", 3)
	fx_burst_label.modulate.a = 0.0
	fx_burst_root.add_child(fx_burst_label)

func _build_fx_ripple() -> void:
	fx_ripple_root = Control.new()
	fx_ripple_root.name = "DiscardRipple"
	fx_ripple_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fx_ripple_root.visible = false
	fx_layer.add_child(fx_ripple_root)
	fx_ripple_rings.clear()
	for i in range(2):
		var ring = Panel.new()
		ring.name = "Ripple%d" % i
		ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ring.set_anchors_preset(Control.PRESET_CENTER)
		fx_ripple_root.add_child(ring)
		fx_ripple_rings.append(ring)

func fx_enabled_effective() -> bool:
	return fx_enabled and fx_layer != null and is_instance_valid(fx_layer)

# 把 root_layer（已扣除安全区）相对的归一化锚点矩形换算成覆盖整个视口的归一化锚点矩形，
# 这样挂在全视口 fx_layer 上的特效节点可以对齐到座位等牌桌元素。
func root_layer_rect_to_screen_rect_for(layer_rect: Rect2, viewport_size: Vector2, margins: Vector4) -> Rect2:
	var vp_w = viewport_size.x if viewport_size.x > 0.0 else 1.0
	var vp_h = viewport_size.y if viewport_size.y > 0.0 else 1.0
	var content_w = max(1.0, vp_w - margins.x - margins.z)
	var content_h = max(1.0, vp_h - margins.y - margins.w)
	var left = (margins.x + layer_rect.position.x * content_w) / vp_w
	var top = (margins.y + layer_rect.position.y * content_h) / vp_h
	var right = (margins.x + layer_rect.size.x * content_w) / vp_w
	var bottom = (margins.y + layer_rect.size.y * content_h) / vp_h
	return Rect2(Vector2(left, top), Vector2(right, bottom))

func root_layer_rect_to_screen_rect(layer_rect: Rect2) -> Rect2:
	return root_layer_rect_to_screen_rect_for(layer_rect, effective_viewport_size(), safe_area_margins)

func fx_seat_screen_rect(seat: int) -> Rect2:
	for layout in SEAT_LAYOUTS:
		if int(layout[0]) == seat:
			return root_layer_rect_to_screen_rect(layout[1])
	return root_layer_rect_to_screen_rect(Rect2(Vector2(0.40, 0.40), Vector2(0.60, 0.60)))

func update_fx_turn_pulse() -> void:
	if fx_turn_pulse == null or not is_instance_valid(fx_turn_pulse):
		return
	# 提前退出：特效未启用时避免后续计算
	if not fx_enabled_effective() or settings_panel_open or (mode != "offline" and mode != "online_game"):
		fx_turn_pulse.visible = false
		var tween_running = fx_turn_pulse_tween != null and is_instance_valid(fx_turn_pulse_tween)
		if tween_running and fx_turn_pulse_tween.is_running():
			fx_turn_pulse_tween.pause()
		return
	var tween_running = fx_turn_pulse_tween != null and is_instance_valid(fx_turn_pulse_tween)
	var seat = get_current_seat()
	apply_rect(fx_turn_pulse, fx_seat_screen_rect(seat))
	var accent = SEAT_ACCENT_COLORS[seat] if seat >= 0 and seat < SEAT_ACCENT_COLORS.size() else UI_GOLD
	fx_turn_glow.add_theme_stylebox_override("panel", style(Color(accent.r * 0.18, accent.g * 0.18, accent.b * 0.18, 0.08), 22, Color(accent.r, accent.g, accent.b, 0.30), 2, 0))
	fx_turn_pulse.visible = true
	if tween_running:
		fx_turn_pulse_tween.play()

func play_fx_win_burst(text: String, color: Color) -> void:
	if not fx_enabled_effective() or fx_burst_root == null or not is_instance_valid(fx_burst_root):
		return
	if fx_burst_tween != null and is_instance_valid(fx_burst_tween):
		fx_burst_tween.kill()
	apply_rect(fx_burst_root, rect_full(0.18, 0.24, 0.82, 0.76))
	fx_burst_flash.color = Color(color.r, color.g, color.b, 0.0)
	for ring in fx_burst_rings:
		ring.modulate.a = 0.0
		ring.add_theme_stylebox_override("panel", style(Color(0, 0, 0, 0), 60, color.darkened(0.18), 3, 0))
		ring.offset_left = -42.0
		ring.offset_top = -42.0
		ring.offset_right = 42.0
		ring.offset_bottom = 42.0
	fx_burst_label.text = text
	fx_burst_label.add_theme_color_override("font_color", color)
	fx_burst_label.modulate.a = 0.0
	fx_burst_label.offset_top = 28.0
	fx_burst_label.offset_bottom = 28.0
	fx_burst_root.visible = true
	var half := float(FX_WIN_BURST_DURATION_MSEC) / 1000.0
	var tw := create_tween()
	fx_burst_tween = tw
	tw.set_parallel(true)
	tw.tween_property(fx_burst_flash, "color:a", 0.10, 0.18).from(0.0)
	tw.tween_property(fx_burst_flash, "color:a", 0.0, 0.55).set_delay(max(0.0, half - 0.55))
	tw.tween_property(fx_burst_label, "modulate:a", 1.0, 0.22).from(0.0)
	tw.tween_property(fx_burst_label, "modulate:a", 0.0, 0.45).set_delay(max(0.0, half - 0.45))
	tw.tween_property(fx_burst_label, "offset_top", -16.0, half).from(28.0)
	tw.tween_property(fx_burst_label, "offset_bottom", -16.0, half).from(28.0)
	for i in range(fx_burst_rings.size()):
		var ring = fx_burst_rings[i]
		var delay = float(i) * 0.10
		var span = max(0.30, half - delay)
		tw.tween_property(ring, "modulate:a", 0.0, span).from(0.72).set_delay(delay)
		tw.tween_property(ring, "offset_left", -185.0, span).from(-42.0).set_delay(delay)
		tw.tween_property(ring, "offset_top", -185.0, span).from(-42.0).set_delay(delay)
		tw.tween_property(ring, "offset_right", 185.0, span).from(42.0).set_delay(delay)
		tw.tween_property(ring, "offset_bottom", 185.0, span).from(42.0).set_delay(delay)
	tw.tween_callback(_hide_fx_burst).set_delay(half + 0.05)

func _hide_fx_burst() -> void:
	if fx_burst_root != null and is_instance_valid(fx_burst_root):
		fx_burst_root.visible = false

func play_fx_discard_ripple() -> void:
	if not fx_enabled_effective() or fx_ripple_root == null or not is_instance_valid(fx_ripple_root):
		return
	if fx_ripple_tween != null and is_instance_valid(fx_ripple_tween):
		fx_ripple_tween.kill()
	apply_rect(fx_ripple_root, root_layer_rect_to_screen_rect(CENTER_PANEL_RECT))
	for ring in fx_ripple_rings:
		ring.modulate.a = 0.0
		ring.add_theme_stylebox_override("panel", style(Color(0, 0, 0, 0), 36, Color(0.74, 0.58, 0.22, 0.34), 1, 0))
		ring.offset_left = -16.0
		ring.offset_top = -16.0
		ring.offset_right = 16.0
		ring.offset_bottom = 16.0
	fx_ripple_root.visible = true
	var span := float(FX_DISCARD_RIPPLE_DURATION_MSEC) / 1000.0
	var tw := create_tween()
	fx_ripple_tween = tw
	tw.set_parallel(true)
	for i in range(fx_ripple_rings.size()):
		var ring = fx_ripple_rings[i]
		var delay = float(i) * 0.10
		var dur = max(0.20, span - delay)
		tw.tween_property(ring, "modulate:a", 0.0, dur).from(0.42).set_delay(delay)
		tw.tween_property(ring, "offset_left", -52.0, dur).from(-16.0).set_delay(delay)
		tw.tween_property(ring, "offset_top", -52.0, dur).from(-16.0).set_delay(delay)
		tw.tween_property(ring, "offset_right", 52.0, dur).from(16.0).set_delay(delay)
		tw.tween_property(ring, "offset_bottom", 52.0, dur).from(16.0).set_delay(delay)
	tw.tween_callback(_hide_fx_ripple).set_delay(span + 0.05)

func _hide_fx_ripple() -> void:
	if fx_ripple_root != null and is_instance_valid(fx_ripple_root):
		fx_ripple_root.visible = false

func clear_fx_overlays() -> void:
	if fx_burst_tween != null and is_instance_valid(fx_burst_tween):
		fx_burst_tween.kill()
	if fx_ripple_tween != null and is_instance_valid(fx_ripple_tween):
		fx_ripple_tween.kill()
	if fx_burst_root != null and is_instance_valid(fx_burst_root):
		fx_burst_root.visible = false
	if fx_ripple_root != null and is_instance_valid(fx_ripple_root):
		fx_ripple_root.visible = false
	if fx_turn_pulse != null and is_instance_valid(fx_turn_pulse):
		fx_turn_pulse.visible = false

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
		return {
			"name": players[seat]["name"],
			"hand_count": players[seat]["hand"].size(),
			"flowers": players[seat]["flowers"],
			"flower_tiles": players[seat].get("flower_tiles", []),
			"score": players[seat].get("score", 0),
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

func current_status_text() -> String:
	if mode == "offline":
		if offline_phase == "ended":
			if is_offline_match_finished():
				return "全场结束"
			return round_summary if round_summary != "" else "牌局结束"
		if has_pending_danger_discard():
			return pending_danger_discard_text()
		if offline_phase == "pending_claim":
			return "等待你响应%s" % tile_label(str(offline_pending_claim.get("tile", "")))
		if wall.is_empty() and offline_turn_needs_draw:
			return "牌墙已空"
		if current_seat == 0:
			return "轮到你出牌"
		return "%s行牌" % players[current_seat]["name"]
	var phase = str(online_game.get("phase", ""))
	if online_feedback != "":
		return online_feedback
	if phase == "ended":
		return str(online_game.get("winnerText", "牌局结束"))
	if phase == "pendingClaim":
		return "等待吃碰杠胡响应"
	return "轮到你出牌" if can_self_discard() else "等待对家行牌"

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

func package_preview(seat: int) -> String:
	if mode != "offline":
		return ""
	if offline_package_liability.has(seat):
		var payer = int(offline_package_liability[seat])
		return "%s包" % players[payer]["name"]
	var targets: Array[String] = []
	for key in offline_package_liability.keys():
		if int(offline_package_liability[key]) == seat:
			targets.append(str(players[int(key)]["name"]))
	if not targets.is_empty():
		return "包%s" % "、".join(targets)
	return ""

func active_package_lines() -> Array[String]:
	var lines: Array[String] = []
	for key in offline_package_liability.keys():
		var winner = int(key)
		var payer = int(offline_package_liability[key])
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
			return Color(0.72, 0.26, 0.22)
		"gang":
			return Color(0.50, 0.42, 0.72)
		"peng":
			return Color(0.80, 0.56, 0.28)
		"chi":
			return Color(0.28, 0.58, 0.46)
	return Color(0.40, 0.44, 0.45)

func show_rules_screen() -> void:
	"""显示麻将规则和玩法说明"""
	mode = "rules"
	clear_screen()

	# 主面板
	var panel = make_panel(root_layer, rect_full(0.02, 0.02, 0.98, 0.98), Color(0.010, 0.024, 0.032, 0.98), 20, Color(0.52, 0.44, 0.26, 0.48))
	panel.add_child(make_color_rect(rect_full(0.006, 0.02, 0.014, 0.98), Color(0.90, 0.76, 0.36, 0.72)))
	panel.add_child(make_color_rect(rect_full(0.014, 0.012, 0.986, 0.028), Color(1.0, 1.0, 1.0, 0.045)))

	# 标题
	var title = make_label(panel, "麻将玩法指南", 30, Color(0.94, 0.86, 0.48), true)
	apply_rect(title, rect_full(0.04, 0.028, 0.40, 0.095))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

	# 返回按钮
	var back = make_small_button("返回", Color(0.32, 0.38, 0.40), func() -> void:
		show_menu()
	)
	back.custom_minimum_size = Vector2(100, 48)
	panel.add_child(back)
	apply_rect(back, rect_full(0.84, 0.030, 0.94, 0.090))

	# 内容区域
	var content = VBoxContainer.new()
	content.anchor_left = 0.05
	content.anchor_top = 0.12
	content.anchor_right = 0.95
	content.anchor_bottom = 0.95
	content.add_theme_constant_override("separation", 16)
	panel.add_child(content)

	# 基础规则
	add_rule_section(content, "🎯 游戏目标", [
		"组成4组面子（顺子或刻子）+ 1对将牌即可胡牌",
		"通过摸牌、打牌、吃碰杠来组合手牌",
		"可以自摸胡牌，也可以点炮胡牌",
	])

	# 牌型说明
	add_rule_section(content, "🀄 牌型介绍", [
		"顺子：同花色连续3张牌（如 123万）",
		"刻子：相同3张牌（如 111万）",
		"杠子：相同4张牌（杠牌专用）",
		"将牌：任意一对相同的牌",
	])

	# 特殊牌型
	add_rule_section(content, "⭐ 特殊牌型", [
		"七对：7对将牌即可胡牌",
		"十三幺：13种幺九牌各一张 + 其中任意一对",
		"清一色：全部是同一花色的牌",
	])

	# 操作说明
	add_rule_section(content, "🎮 游戏操作", [
		"点击手牌打出该张牌",
		"出现吃、碰、杠、胡按钮时点击操作",
		"点击'重开'可重新开始本局",
	])

	# 记录已查看教程
	tutorial_step = -1
	save_tutorial_state()

func add_rule_section(parent: VBoxContainer, title_text: String, lines: Array) -> void:
	var section = make_panel(parent, rect_full(0.0, 0.0, 1.0, 0.22), Color(0.012, 0.022, 0.028, 0.92), 14, Color(0.34, 0.38, 0.36, 0.28), 0)
	section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	section.custom_minimum_size.y = 0

	var vbox = VBoxContainer.new()
	vbox.anchor_left = 0.04
	vbox.anchor_top = 0.08
	vbox.anchor_right = 0.96
	vbox.anchor_bottom = 0.92
	section.add_child(vbox)

	var title_label = make_label(vbox, title_text, 18, Color(0.90, 0.82, 0.50), true)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

	for line in lines:
		var line_label = make_label(vbox, "  " + str(line), 14, Color(0.80, 0.84, 0.76), false)
		line_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		line_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func show_stats_screen() -> void:
	"""显示详细游戏统计"""
	mode = "stats"
	clear_screen()

	var panel = make_panel(root_layer, rect_full(0.02, 0.02, 0.98, 0.98), Color(0.010, 0.024, 0.032, 0.98), 20, Color(0.52, 0.44, 0.26, 0.48))
	panel.add_child(make_color_rect(rect_full(0.006, 0.02, 0.014, 0.98), Color(0.90, 0.76, 0.36, 0.72)))

	var title = make_label(panel, "游戏统计", 30, Color(0.94, 0.86, 0.48), true)
	apply_rect(title, rect_full(0.04, 0.028, 0.40, 0.095))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

	var back = make_small_button("返回", Color(0.32, 0.38, 0.40), func() -> void:
		show_menu()
	)
	back.custom_minimum_size = Vector2(100, 48)
	panel.add_child(back)
	apply_rect(back, rect_full(0.84, 0.030, 0.94, 0.090))

	# 统计数据
	var content = VBoxContainer.new()
	content.anchor_left = 0.08
	content.anchor_top = 0.15
	content.anchor_right = 0.92
	content.anchor_bottom = 0.92
	content.add_theme_constant_override("separation", 20)
	panel.add_child(content)

	add_stat_row(content, "总场次", "%d 局" % int(game_stats.get("games_played", 0)))
	add_stat_row(content, "胜场", "%d 局" % int(game_stats.get("games_won", 0)))
	add_stat_row(content, "胜率", "%.1f%%" % (float(game_stats.get("win_rate", 0.0)) * 100.0))
	add_stat_row(content, "累计分数", "%s 分" % compact_score_text(int(game_stats.get("total_score", 0))))
	add_stat_row(content, "最高得分", "%s 分" % compact_score_text(int(game_stats.get("best_score", 0))))
	add_stat_row(content, "总手牌数", "%d 局" % int(game_stats.get("total_hands", 0)))

func add_stat_row(parent: VBoxContainer, label_text: String, value_text: String) -> void:
	var row = Panel.new()
	row.custom_minimum_size = Vector2(0, 52)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_stylebox_override("panel", style(Color(0.014, 0.024, 0.030, 0.92), 12, Color(0.30, 0.34, 0.32, 0.32), 0))
	parent.add_child(row)

	var label = make_label(row, label_text, 18, Color(0.82, 0.84, 0.78), true)
	apply_rect(label, rect_full(0.06, 0.15, 0.45, 0.85))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

	var value = make_label(row, value_text, 20, Color(0.94, 0.90, 0.68), true)
	apply_rect(value, rect_full(0.52, 0.12, 0.94, 0.88))
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
