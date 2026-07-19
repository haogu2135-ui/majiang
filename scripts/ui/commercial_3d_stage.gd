class_name Commercial3DStage
extends SubViewportContainer

const TILE_BACK_TEXTURE_PATH := "res://assets/tiles/tile_back.png"  # r389 warm 2D back
const FELT_TEXTURE_PATH := "res://assets/table/table_felt_warm_gpt.png"  # r428: GPT warm bright felt (lifted from gpt-image-2)
const LACQUER_TEXTURE_PATH := "res://assets/table/table_lacquer_3d_gpt.png"
const FELT_NORMAL_PATH := "res://assets/table/table_felt_3d_normal.png"
const FELT_ROUGHNESS_PATH := "res://assets/table/table_felt_3d_roughness.png"
const LACQUER_NORMAL_PATH := "res://assets/table/table_lacquer_3d_normal.png"
const LACQUER_ROUGHNESS_PATH := "res://assets/table/table_lacquer_3d_roughness.png"
const QUALITY_AUTO := -1
const QUALITY_LOW := 0
const QUALITY_STANDARD := 1
const QUALITY_HIGH := 2
const MENU_TILE_PATHS := [
	"res://assets/tiles_subtle_3d/tile_man1.png",
	"res://assets/tiles_subtle_3d/tile_honor_east.png",
	"res://assets/tiles_subtle_3d/tile_pin5.png",
]
const SEAT_TILE_PATHS := [
	"res://assets/tiles_subtle_3d/tile_honor_east.png",
	"res://assets/tiles_subtle_3d/tile_honor_south.png",
	"res://assets/tiles_subtle_3d/tile_honor_west.png",
	"res://assets/tiles_subtle_3d/tile_honor_north.png",
]

var stage_mode := "battle"
var effects_enabled := true
var active_seat := 0
var wall_ratio := 1.0
var focus_texture_cache: Texture2D
var requested_quality := QUALITY_AUTO
var resolved_quality := QUALITY_STANDARD
var hand_face_textures: Array[Texture2D] = []
var hand_normalized_positions := PackedFloat32Array()
var hand_tile_states: Array[Dictionary] = []
var hand_tile_aspect := 0.735
var hand_world_tile_height := 1.80
var table_tile_entries: Array[Dictionary] = []

var viewport_3d: SubViewport
var stage_root: Node3D
var camera: Camera3D
var showcase_root: Node3D
var active_marker: Node3D
var active_light: OmniLight3D
var focus_tile_root: Node3D
var gold_material: StandardMaterial3D
var showcase_tiles: Array[Node3D] = []
var hand_tile_roots: Array[Node3D] = []
var hand_body_batch: MultiMeshInstance3D
var hand_back_batch: MultiMeshInstance3D
var hand_foot_batch: MultiMeshInstance3D
var table_tile_roots: Array[Node3D] = []
var table_tile_body_batch: MultiMeshInstance3D
var table_tile_face_batch: MultiMeshInstance3D
var table_tile_base_batch: MultiMeshInstance3D
var table_tile_shadow_batch: MultiMeshInstance3D
var table_decal_shader: Shader
var hand_hovered_index := -1
var hand_pressed_index := -1
var pointer_target := Vector2.ZERO
var pointer_smooth := Vector2.ZERO
var elapsed := 0.0
var beveled_mesh_cache: Dictionary = {}


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	stretch = true
	resized.connect(_sync_viewport_size)
	_build_scene()
	call_deferred("_sync_viewport_size")


func configure(requested_mode: String, animate: bool = true, requested_active_seat: int = 0, requested_wall_ratio: float = 1.0, focus_texture: Texture2D = null, quality: int = QUALITY_AUTO) -> void:
	stage_mode = "menu" if requested_mode == "menu" else "battle"
	var adapter := str(RenderingServer.get_video_adapter_name()).to_lower()
	var software_gl := adapter.find("llvmpipe") >= 0 or adapter.find("swiftshader") >= 0 or adapter.find("softpipe") >= 0
	effects_enabled = animate and not software_gl
	if software_gl and quality == QUALITY_AUTO:
		quality = QUALITY_LOW
	active_seat = clamp(requested_active_seat, 0, 3)
	wall_ratio = clamp(requested_wall_ratio, 0.0, 1.0)
	focus_texture_cache = focus_texture
	requested_quality = clampi(quality, QUALITY_AUTO, QUALITY_HIGH)
	if is_node_ready():
		_build_scene(focus_texture)


func configure_hand(face_textures: Array, normalized_positions: PackedFloat32Array, tile_states: Array, tile_aspect: float, animate: bool = true, quality: int = QUALITY_AUTO) -> void:
	stage_mode = "hand"
	effects_enabled = animate
	requested_quality = clampi(quality, QUALITY_AUTO, QUALITY_HIGH)
	hand_face_textures.clear()
	for texture in face_textures:
		hand_face_textures.append(texture as Texture2D)
	hand_normalized_positions = normalized_positions.duplicate()
	hand_tile_states.clear()
	for state in tile_states:
		hand_tile_states.append((state as Dictionary).duplicate(true))
	hand_tile_aspect = clampf(tile_aspect, 0.58, 0.86)
	hand_hovered_index = -1
	hand_pressed_index = -1
	if is_node_ready():
		_build_scene()


func configure_table_tiles(entries: Array, animate: bool = true, quality: int = QUALITY_AUTO) -> void:
	stage_mode = "table_tiles"
	effects_enabled = animate
	requested_quality = clampi(quality, QUALITY_AUTO, QUALITY_HIGH)
	table_tile_entries.clear()
	for entry in entries:
		if entry is Dictionary:
			table_tile_entries.append((entry as Dictionary).duplicate(true))
	if is_node_ready():
		_build_scene()


func set_pointer_normalized(value: Vector2) -> void:
	pointer_target = Vector2(clamp(value.x, -1.0, 1.0), clamp(value.y, -1.0, 1.0))


func set_hand_hovered(index: int, hovered: bool) -> void:
	if stage_mode != "hand":
		return
	if hovered:
		hand_hovered_index = index
	elif hand_hovered_index == index:
		hand_hovered_index = -1


func set_hand_pressed(index: int, pressed: bool) -> void:
	if stage_mode != "hand":
		return
	if pressed:
		hand_pressed_index = index
	elif hand_pressed_index == index:
		hand_pressed_index = -1


func sync_battle_state(requested_active_seat: int, requested_wall_ratio: float) -> void:
	active_seat = clamp(requested_active_seat, 0, 3)
	wall_ratio = clamp(requested_wall_ratio, 0.0, 1.0)
	if is_node_ready() and stage_mode == "battle":
		var bodies := find_child("BattleWallBodies3D", true, false) as MultiMeshInstance3D
		var current_count := bodies.multimesh.instance_count if bodies != null and bodies.multimesh != null else -1
		if current_count != _wall_instance_count(wall_ratio):
			_build_scene(focus_texture_cache)
			return
	_update_active_marker()


func _build_scene(focus_texture: Texture2D = null) -> void:
	_clear_scene()
	resolved_quality = _resolve_quality()
	viewport_3d = SubViewport.new()
	viewport_3d.name = "Realtime3DViewport"
	viewport_3d.transparent_bg = true
	viewport_3d.own_world_3d = true
	viewport_3d.msaa_3d = _quality_msaa()
	viewport_3d.positional_shadow_atlas_size = _quality_shadow_atlas_size()
	viewport_3d.render_target_update_mode = SubViewport.UPDATE_ALWAYS if effects_enabled and DisplayServer.get_name().to_lower() != "headless" else SubViewport.UPDATE_ONCE
	add_child(viewport_3d)

	stage_root = Node3D.new()
	stage_root.name = "Commercial3DWorld"
	viewport_3d.add_child(stage_root)
	_build_environment()
	_build_lighting()
	_build_camera()
	if stage_mode == "menu":
		_build_menu_stage()
	elif stage_mode == "hand":
		_build_hand_stage()
	elif stage_mode == "table_tiles":
		_build_table_tiles_stage()
	else:
		_build_battle_stage(focus_texture)
	set_process(effects_enabled and DisplayServer.get_name().to_lower() != "headless")
	_sync_viewport_size()


func _clear_scene() -> void:
	for child in get_children():
		remove_child(child)
		child.free()
	viewport_3d = null
	stage_root = null
	camera = null
	showcase_root = null
	active_marker = null
	active_light = null
	focus_tile_root = null
	showcase_tiles.clear()
	hand_tile_roots.clear()
	hand_body_batch = null
	hand_back_batch = null
	hand_foot_batch = null
	table_tile_roots.clear()
	table_tile_body_batch = null
	table_tile_face_batch = null
	table_tile_base_batch = null
	table_tile_shadow_batch = null


func _build_environment() -> void:
	var world_environment := WorldEnvironment.new()
	world_environment.name = "CommercialWorldEnvironment"
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.0, 0.0, 0.0, 0.0)
	environment.background_energy_multiplier = 0.0
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	var is_tile_stage := stage_mode == "hand" or stage_mode == "table_tiles"
	# Soft warm ambient sculpts porcelain; faces stay unshaded so ambient cannot bleach ink.
	# r286: slightly higher battle ambient (faces unshaded; tiles not bleached).
	# r408: warm ambient only — no mint fill that tints 2D rivers/hand through the transparent stage.
	environment.ambient_light_color = Color(0.72, 0.68, 0.60) if is_tile_stage else Color(0.78, 0.70, 0.58)
	environment.ambient_light_energy = 1.85 if stage_mode == "table_tiles" else (1.48 if stage_mode == "hand" else (1.22 if stage_mode == "menu" else 2.90))  # r445 battle river readability
	environment.reflected_light_source = Environment.REFLECTION_SOURCE_BG
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world_environment.environment = environment
	stage_root.add_child(world_environment)


func _build_lighting() -> void:
	var is_table_tiles := stage_mode == "table_tiles"
	var is_hand := stage_mode == "hand"
	var key := DirectionalLight3D.new()
	key.name = "CinematicKeyLight"
	key.light_color = Color(1.0, 0.97, 0.92) if is_table_tiles else (Color(1.0, 0.95, 0.90) if is_hand else Color(1.0, 0.86, 0.64))
	# Soft key for porcelain volume only; faces are unshaded so this cannot wash inks.
	key.light_energy = 2.75 if is_table_tiles else (2.22 if is_hand else (1.70 if stage_mode == "menu" else 3.45))  # r428
	key.shadow_enabled = false  # r427: shadows read as dark slabs under pure-2D rivers
	key.light_angular_distance = 1.35
	key.directional_shadow_max_distance = 24.0
	# r444: center key so right river is not left-biased dark
	key.position = Vector3(0.0, 9.0, 6.2)
	stage_root.add_child(key)
	key.look_at(Vector3.ZERO, Vector3.UP)

	var cool_fill := OmniLight3D.new()
	cool_fill.name = "JadeFillLight"
	# r408: warm fill (was cyan-jade cool fill casting green over table/rivers).
	# r444: dual-side warm fills — left + right balanced for 2D river readability
	cool_fill.light_color = Color(0.62, 0.54, 0.42) if is_table_tiles else (Color(0.58, 0.50, 0.40) if is_hand else Color(0.52, 0.44, 0.34))
	cool_fill.light_energy = 1.55 if is_table_tiles else (1.35 if is_hand else (1.70 if stage_mode == "menu" else 1.85))
	cool_fill.omni_range = 9.0
	cool_fill.position = Vector3(-4.0, 2.8, 1.6)
	stage_root.add_child(cool_fill)

	var right_fill := OmniLight3D.new()
	right_fill.name = "RightRiverFillLight"
	right_fill.light_color = Color(0.70, 0.60, 0.46) if is_table_tiles else (Color(0.64, 0.56, 0.44) if is_hand else Color(0.62, 0.52, 0.38))
	right_fill.light_energy = 2.15 if is_table_tiles else (1.75 if is_hand else (2.25 if stage_mode == "menu" else 3.85))
	right_fill.omni_range = 12.5
	right_fill.position = Vector3(4.8, 3.5, 0.9)
	stage_root.add_child(right_fill)

	active_light = OmniLight3D.new()
	active_light.name = "WarmPracticalLight"
	active_light.light_color = Color(1.0, 0.86, 0.68) if is_table_tiles else (Color(1.0, 0.86, 0.70) if is_hand else Color(1.0, 0.70, 0.36))
	active_light.light_energy = 0.95 if is_table_tiles else (0.85 if is_hand else 2.55)
	active_light.omni_range = 7.5
	active_light.position = Vector3(3.6, 2.4, 2.0)
	stage_root.add_child(active_light)

	var center_spot := SpotLight3D.new()
	center_spot.name = "TableCenterSpotLight"
	center_spot.light_color = Color(1.0, 0.96, 0.90) if is_table_tiles else (Color(1.0, 0.95, 0.88) if is_hand else Color(1.0, 0.84, 0.56))
	# Keep center soft — hard spots made porcelain look like it was glowing from the middle.
	center_spot.light_energy = 1.15 if is_table_tiles else (0.70 if is_hand else (2.20 if stage_mode == "menu" else 3.10))
	center_spot.spot_range = 12.0 if is_table_tiles else (11.0 if is_hand else 15.0)
	center_spot.spot_angle = 62.0 if is_table_tiles else (64.0 if is_hand else (52.0 if stage_mode == "menu" else 56.0))
	center_spot.spot_attenuation = 1.15 if is_hand or is_table_tiles else 0.82
	center_spot.position = Vector3(0.0, 8.0, 1.8) if is_table_tiles else (Vector3(0.0, 3.2, 5.2) if is_hand else Vector3(0.0, 7.2, 2.0))
	stage_root.add_child(center_spot)
	center_spot.look_at(Vector3(0.0, 0.0, 0.0), Vector3.UP)
	if stage_mode == "battle":
		var warm_rim := OmniLight3D.new()
		warm_rim.name = "BattleWarmRimLight"
		warm_rim.light_color = Color(1.0, 0.88, 0.64)
		warm_rim.light_energy = 3.40  # r444
		warm_rim.omni_range = 12.5
		warm_rim.position = Vector3(1.2, 3.6, 3.6)  # r444 slight right bias balance
		stage_root.add_child(warm_rim)


func _build_camera() -> void:
	camera = Camera3D.new()
	camera.name = "CommercialStageCamera"
	camera.current = true
	camera.fov = 43.0 if stage_mode == "menu" else 47.0
	camera.near = 0.1
	camera.far = 60.0
	stage_root.add_child(camera)
	if stage_mode == "menu":
		camera.position = Vector3(0.0, 5.5, 9.2)
		camera.look_at(Vector3(0.0, 0.10, -0.15), Vector3.UP)
	elif stage_mode == "hand":
		camera.projection = Camera3D.PROJECTION_ORTHOGONAL
		camera.size = 2.16
		camera.position = Vector3(0.0, 0.72, 6.6)
		camera.look_at(Vector3(0.0, -0.08, 0.0), Vector3.UP)
	elif stage_mode == "table_tiles":
		camera.projection = Camera3D.PROJECTION_ORTHOGONAL
		camera.size = 10.0
		camera.position = Vector3(0.0, 9.0, 0.0)
		camera.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	else:
		camera.position = Vector3(0.0, 8.4, 8.8)
		camera.look_at(Vector3(0.0, -0.15, -0.20), Vector3.UP)


func _build_menu_stage() -> void:
	var lacquer := _material("Black lacquer", Color(0.030, 0.022, 0.018), 0.58, 0.20)
	var jade := _material("Warm lacquer felt", Color(0.14, 0.11, 0.08), 0.12, 0.36)  # r408 no deep jade green
	_apply_material_texture(lacquer, LACQUER_TEXTURE_PATH, Vector3(1.35, 1.35, 1.35), Color(0.90, 0.86, 0.80), LACQUER_NORMAL_PATH, LACQUER_ROUGHNESS_PATH, 0.50)
	_apply_material_texture(jade, FELT_TEXTURE_PATH, Vector3(1.0, 1.0, 1.0), Color(1.20, 1.06, 0.90), FELT_NORMAL_PATH, FELT_ROUGHNESS_PATH, 0.62)  # r423
	gold_material = _material("Antique gold", Color(0.72, 0.48, 0.16), 0.86, 0.18, Color(0.22, 0.10, 0.02))
	var porcelain := _material("Warm porcelain", Color(0.97, 0.94, 0.86), 0.05, 0.12, Color(0.10, 0.08, 0.05))

	_add_beveled_box(stage_root, "MenuTableBody", Vector3(10.8, 0.58, 4.65), Vector3(0.0, -0.58, 0.15), lacquer, 0.16)
	_add_beveled_box(stage_root, "MenuTableSurface", Vector3(10.35, 0.18, 4.22), Vector3(0.0, -0.20, 0.10), jade, 0.075)
	_add_beveled_box(stage_root, "MenuFrontGoldRail", Vector3(10.15, 0.075, 0.075), Vector3(0.0, -0.08, 2.18), gold_material, 0.026)
	_add_beveled_box(stage_root, "MenuBackGoldRail", Vector3(10.15, 0.055, 0.055), Vector3(0.0, -0.05, -1.98), gold_material, 0.020)

	showcase_root = Node3D.new()
	showcase_root.name = "Menu3DShowcase"
	stage_root.add_child(showcase_root)
	var x_positions := [-3.45, 0.0, 3.45]
	var rotations := [-0.10, 0.0, 0.10]
	for i in range(3):
		var pedestal := Node3D.new()
		pedestal.name = "ShowcasePedestal_%d" % i
		pedestal.position = Vector3(x_positions[i], 0.0, 0.08)
		showcase_root.add_child(pedestal)
		_add_beveled_box(pedestal, "PedestalBase", Vector3(2.42, 0.18, 1.85), Vector3(0.0, 0.02, 0.12), lacquer, 0.070)
		_add_beveled_box(pedestal, "PedestalJadeInset", Vector3(2.16, 0.08, 1.58), Vector3(0.0, 0.14, 0.08), jade, 0.030)
		_add_beveled_box(pedestal, "PedestalGoldLip", Vector3(2.22, 0.055, 0.055), Vector3(0.0, 0.19, 0.88), gold_material, 0.020)
		var texture := _load_texture(MENU_TILE_PATHS[i])
		showcase_tiles.append(_add_upright_tile(pedestal, "HeroTile_%d" % i, Vector3(0.0, 1.48, -0.05), rotations[i], porcelain, texture))
		showcase_tiles.append(_add_upright_tile(pedestal, "CompanionTileLeft_%d" % i, Vector3(-0.62, 1.17, 0.14), rotations[i] - 0.10, porcelain, _load_texture(MENU_TILE_PATHS[(i + 1) % 3]), Vector2(0.54, 0.78)))
		showcase_tiles.append(_add_upright_tile(pedestal, "CompanionTileRight_%d" % i, Vector3(0.62, 1.17, 0.14), rotations[i] + 0.10, porcelain, _load_texture(MENU_TILE_PATHS[(i + 2) % 3]), Vector2(0.54, 0.78)))


func _build_hand_stage() -> void:
	var lacquer := _material("Hand tray lacquer", Color(0.020, 0.017, 0.013), 0.60, 0.20)
	_apply_material_texture(lacquer, LACQUER_TEXTURE_PATH, Vector3(2.2, 2.2, 2.2), Color(0.86, 0.82, 0.76), LACQUER_NORMAL_PATH, LACQUER_ROUGHNESS_PATH, 0.42)
	var porcelain := _material("Hand tile porcelain", Color(0.86, 0.84, 0.79), 0.01, 0.30, Color(0.0, 0.0, 0.0))
	var jade_back := _material("Hand tile jade back", Color(0.18, 0.12, 0.08), 0.14, 0.24, Color(0.06, 0.04, 0.02))
	var hand_gold := _material("Hand tray gold", Color(0.74, 0.50, 0.16), 0.88, 0.16, Color(0.16, 0.055, 0.006))
	_add_beveled_box(stage_root, "HandTray3DFloor", Vector3(24.0, 0.16, 1.30), Vector3(0.0, -0.91, -0.08), lacquer, 0.065)
	_add_beveled_box(stage_root, "HandTray3DGoldRail", Vector3(23.4, 0.055, 0.065), Vector3(0.0, -0.805, 0.61), hand_gold, 0.020)

	var tile_height := hand_world_tile_height
	var tile_width := clampf(tile_height * hand_tile_aspect, 0.88, 1.25)
	var identity_transforms: Array[Transform3D] = []
	for i in range(hand_face_textures.size()):
		identity_transforms.append(Transform3D.IDENTITY)
	hand_body_batch = _add_multimesh(stage_root, "HandTilePorcelainBodies3D", _beveled_box_mesh(Vector3(tile_width, tile_height, 0.20), 0.060, _quality_bevel_segments()), identity_transforms)
	hand_body_batch.material_override = porcelain
	hand_back_batch = _add_multimesh(stage_root, "HandTileJadeBacks3D", _beveled_box_mesh(Vector3(tile_width * 0.94, tile_height * 0.94, 0.060), 0.025, _quality_bevel_segments()), identity_transforms)
	hand_back_batch.material_override = jade_back
	hand_foot_batch = _add_multimesh(stage_root, "HandTileJadeFeet3D", _beveled_box_mesh(Vector3(tile_width * 0.92, 0.090, 0.235), 0.026, _quality_bevel_segments()), identity_transforms)
	hand_foot_batch.material_override = jade_back
	for i in range(hand_face_textures.size()):
		var state: Dictionary = hand_tile_states[i] if i < hand_tile_states.size() else {}
		var highlighted := bool(state.get("highlighted", false))
		var risk_strength := float(state.get("risk_strength", 0.0))
		var accent: Color = state.get("accent", Color(0.78, 0.56, 0.20))
		var tile_root := Node3D.new()
		tile_root.name = "HandPhysicalTile3D_%02d" % i
		tile_root.set_meta("rest_y", 0.015 + (0.128 if highlighted else 0.0))
		tile_root.set_meta("rest_z", 0.0)
		tile_root.set_meta("rest_roll", 0.0)
		tile_root.set_meta("highlighted", highlighted)
		tile_root.set_meta("drawn", bool(state.get("drawn", false)))
		stage_root.add_child(tile_root)
		hand_tile_roots.append(tile_root)

		if highlighted or risk_strength > 0.15:
			var rim_color := Color(accent.r, accent.g, accent.b, 1.0)
			var rim_material := _material("Hand tile state rim %d" % i, rim_color.lightened(0.14 if highlighted else 0.0).darkened(0.04 if highlighted else 0.16), 0.84 if highlighted else 0.60, 0.11 if highlighted else 0.20, rim_color * (0.44 if highlighted else 0.09))
			_add_beveled_box(tile_root, "HandTileStateRim_%02d" % i, Vector3(tile_width + (0.100 if highlighted else 0.060), tile_height + (0.100 if highlighted else 0.060), 0.128 if highlighted else 0.105), Vector3(0.0, 0.0, -0.060), rim_material, 0.060 if highlighted else 0.052)
		var decal_texture := hand_face_textures[i]
		if decal_texture != null:
			var decal := _add_quad(tile_root, "HandTileDecal_%02d" % i, Vector2(tile_width * 0.94, tile_height * 0.94), Vector3(0.0, 0.0, 0.106), _face_decal_material(decal_texture, true))
			decal.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_apply_hand_layout()
	_apply_hand_pose(1.0, true)
	if effects_enabled:
		for tile_root in hand_tile_roots:
			if bool(tile_root.get_meta("drawn", false)):
				tile_root.position.y += 0.28
				tile_root.position.z += 0.12
				tile_root.scale = Vector3(0.88, 0.88, 0.88)


func _build_table_tiles_stage() -> void:
	if table_tile_entries.is_empty():
		return
	var porcelain := _material("River tile porcelain", Color(0.87, 0.85, 0.80), 0.01, 0.28, Color(0.0, 0.0, 0.0))
	var glaze_lip := _material("River tile glaze lip", Color(0.93, 0.91, 0.87), 0.02, 0.22, Color(0.0, 0.0, 0.0))
	var jade_base := _material("River tile lacquer base", Color(0.12, 0.09, 0.06), 0.14, 0.24, Color(0.04, 0.03, 0.02))  # r408
	var shadow_material := _material("River tile contact shadow", Color(0.0, 0.0, 0.0, 0.28), 0.0, 1.0)
	shadow_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	shadow_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	var identity_transforms: Array[Transform3D] = []
	for i in range(table_tile_entries.size()):
		identity_transforms.append(Transform3D.IDENTITY)
	table_tile_body_batch = _add_multimesh(stage_root, "TableTilePorcelainBodies3D", _beveled_box_mesh(Vector3(1.0, 0.14, 1.0), 0.055, _quality_bevel_segments()), identity_transforms)
	table_tile_body_batch.material_override = porcelain
	table_tile_face_batch = _add_multimesh(stage_root, "TableTileGlazeLips3D", _beveled_box_mesh(Vector3(0.965, 0.030, 0.965), 0.038, _quality_bevel_segments()), identity_transforms)
	table_tile_face_batch.material_override = glaze_lip
	table_tile_base_batch = _add_multimesh(stage_root, "TableTileJadeBases3D", _beveled_box_mesh(Vector3(1.0, 0.055, 1.0), 0.025, _quality_bevel_segments()), identity_transforms)
	table_tile_base_batch.material_override = jade_base
	var shadow_mesh := QuadMesh.new()
	shadow_mesh.size = Vector2(1.12, 1.12)
	table_tile_shadow_batch = _add_multimesh(stage_root, "TableTileContactShadows3D", shadow_mesh, identity_transforms)
	table_tile_shadow_batch.material_override = shadow_material
	table_tile_shadow_batch.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for i in range(table_tile_entries.size()):
		var entry: Dictionary = table_tile_entries[i]
		var tile_root := Node3D.new()
		tile_root.name = "TableTilePhysical3D_%02d" % i
		tile_root.set_meta("highlighted", bool(entry.get("highlighted", false)))
		tile_root.set_meta("raised", bool(entry.get("raised", false)))
		tile_root.set_meta("role", str(entry.get("role", "discard")))
		tile_root.set_meta("phase", float(i) * 0.31)
		stage_root.add_child(tile_root)
		table_tile_roots.append(tile_root)
		var accent: Color = entry.get("accent", Color(0.84, 0.65, 0.28))
		if bool(entry.get("highlighted", false)):
			var rim_material := _material("River latest tile rim", accent.lightened(0.18).darkened(0.0), 0.90, 0.08, accent * 0.50)
			_add_beveled_box(tile_root, "TableTileLatestRim", Vector3(1.20, 0.075, 1.20), Vector3(0.0, -0.038, 0.0), rim_material, 0.058)
		var face_texture := entry.get("texture", null) as Texture2D
		if face_texture != null:
			var decal_material := _face_decal_material(face_texture, false)
			var decal := _add_quad(tile_root, "TableTileDecal_%02d" % i, Vector2(0.94, 0.94), Vector3(0.0, 0.096, 0.0), decal_material)
			decal.rotation.x = -PI * 0.5
			decal.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_apply_table_tile_layout()
	_apply_table_tile_pose(1.0, true)


func _build_battle_stage(focus_texture: Texture2D) -> void:
	var lacquer := _material("Battle lacquer", Color(0.070, 0.052, 0.036), 0.55, 0.24)
	# r298-revert: restore r296 felt (readable jade, not bleach).
	# r384b: warm dark table felt — desaturate green (G not dominant), kill neon emission.
	var felt := _material("Woven warm lacquer felt", Color(0.52, 0.42, 0.30), 0.10, 0.34)  # r428 bright GPT felt base
	# r408: wall stack uses warm lacquer (was mid-jade green slabs behind/around 2D rivers).
	var jade := _material("Wall lacquer", Color(0.24, 0.18, 0.13), 0.18, 0.22)  # r427
	_apply_material_texture(lacquer, LACQUER_TEXTURE_PATH, Vector3(1.6, 1.6, 1.6), Color(1.22, 1.14, 1.00), LACQUER_NORMAL_PATH, LACQUER_ROUGHNESS_PATH, 0.36)
	_apply_material_texture(felt, FELT_TEXTURE_PATH, Vector3(1.0, 1.0, 1.0), Color(1.08, 1.02, 0.96), FELT_NORMAL_PATH, FELT_ROUGHNESS_PATH, 0.42)  # r428 texture carries brightness
	felt.emission_enabled = true
	felt.emission = Color(0.20, 0.15, 0.09)
	felt.emission_energy_multiplier = 0.34  # r447 mild lift for side river gutters
	gold_material = _material("Battle gold", Color(0.70, 0.48, 0.16), 0.84, 0.20, Color(0.12, 0.045, 0.006))
	var porcelain := _material("Battle porcelain", Color(0.925, 0.905, 0.86), 0.01, 0.24, Color(0.0, 0.0, 0.0))

	_add_beveled_box(stage_root, "BattleTableBody", Vector3(11.2, 0.66, 6.55), Vector3(0.0, -0.58, 0.0), lacquer, 0.18)
	_add_beveled_box(stage_root, "BattleTableFelt", Vector3(10.58, 0.15, 5.92), Vector3(0.0, -0.16, 0.0), felt, 0.060)
	_add_beveled_box(stage_root, "BattleRailNear", Vector3(11.15, 0.34, 0.30), Vector3(0.0, 0.05, 3.15), lacquer, 0.11)
	_add_beveled_box(stage_root, "BattleRailFar", Vector3(11.15, 0.30, 0.28), Vector3(0.0, 0.03, -3.14), lacquer, 0.10)
	_add_beveled_box(stage_root, "BattleRailLeft", Vector3(0.30, 0.32, 6.06), Vector3(-5.43, 0.04, 0.0), lacquer, 0.11)
	_add_beveled_box(stage_root, "BattleRailRight", Vector3(0.30, 0.32, 6.06), Vector3(5.43, 0.04, 0.0), lacquer, 0.11)
	_add_beveled_box(stage_root, "BattleGoldNear", Vector3(10.85, 0.065, 0.055), Vector3(0.0, 0.24, 3.00), gold_material, 0.020)
	_add_beveled_box(stage_root, "BattleGoldFar", Vector3(10.85, 0.055, 0.050), Vector3(0.0, 0.21, -3.00), gold_material, 0.018)
	_add_box(stage_root, "BattleFeltInlayNear", Vector3(9.56, 0.032, 0.032), Vector3(0.0, -0.045, 2.66), gold_material)
	_add_box(stage_root, "BattleFeltInlayFar", Vector3(9.56, 0.032, 0.032), Vector3(0.0, -0.045, -2.66), gold_material)
	_add_box(stage_root, "BattleFeltInlayLeft", Vector3(0.032, 0.032, 4.82), Vector3(-4.80, -0.045, 0.0), gold_material)
	_add_box(stage_root, "BattleFeltInlayRight", Vector3(0.032, 0.032, 4.82), Vector3(4.80, -0.045, 0.0), gold_material)
	_build_corner_hardware(lacquer)

	var compass_outer := _add_cylinder(stage_root, "CenterCompassGold", 1.18, 0.07, Vector3(0.0, 0.02, 0.0), gold_material)
	compass_outer.rotation_degrees.x = 0.0
	_add_cylinder(stage_root, "CenterCompassJade", 1.04, 0.09, Vector3(0.0, 0.08, 0.0), felt)
	_add_box(stage_root, "CompassAxisEastWest", Vector3(2.72, 0.035, 0.035), Vector3(0.0, 0.15, 0.0), gold_material)
	_add_box(stage_root, "CompassAxisNorthSouth", Vector3(0.035, 0.035, 2.72), Vector3(0.0, 0.15, 0.0), gold_material)

	_build_wall_arc(jade)
	# r426: skip 3D seat plaques — pure 2D GPT seat panels own nameplates; plaques read as fake tiles
	# _build_seat_plaques(porcelain)
	active_marker = Node3D.new()
	active_marker.name = "ActiveSeat3DMarker"
	stage_root.add_child(active_marker)
	_add_cylinder(active_marker, "ActiveSeatGlowDisc", 0.27, 0.045, Vector3.ZERO, gold_material)
	_update_active_marker()

	# r425: pure 2D river/focus tiles only — do not spawn 3D focus discard (was jade base + occluding 2D faces).
	if focus_texture != null:
		var focus_shadow_material := _material("Focus contact shadow", Color(0.0, 0.0, 0.0, 0.22), 0.0, 1.0)
		focus_shadow_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		focus_shadow_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		var focus_shadow := _add_cylinder(stage_root, "FocusDiscardContactShadow", 0.48, 0.016, Vector3(0.0, 0.12, 0.32), focus_shadow_material)
		focus_shadow.scale.z = 0.70
		focus_tile_root = null


func _build_wall_arc(material: StandardMaterial3D) -> void:
	var body_transforms := _wall_body_transforms()
	var back_transforms := _wall_back_transforms(body_transforms)

	var body_mesh := _beveled_box_mesh(Vector3(0.43, 0.15, 0.64), 0.045, _quality_bevel_segments())
	var body_instance := _add_multimesh(stage_root, "BattleWallBodies3D", body_mesh, body_transforms)
	body_instance.material_override = material

	var back_texture := _load_texture(TILE_BACK_TEXTURE_PATH)
	if back_texture == null or back_transforms.is_empty():
		return
	var back_mesh := QuadMesh.new()
	back_mesh.size = Vector2(0.405, 0.605)
	back_mesh.material = _texture_material(back_texture, 0.06)  # r427 less wall-back noise near rivers
	var back_instance := _add_multimesh(stage_root, "BattleWallBackFaces3D", back_mesh, back_transforms)
	back_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


func _wall_instance_count(ratio: float) -> int:
	return _wall_stack_count(ratio) * 2


func _wall_stack_count(ratio: float) -> int:
	return clampi(ceili(36.0 * ratio), 0, 36)


func _wall_stack_path() -> Array[Transform3D]:
	var path: Array[Transform3D] = []
	for i in range(11):
		path.append(_wall_tile_transform(Vector3(-2.45 + float(i) * 0.49, 0.0, -2.42), 0.0))
	for i in range(7):
		path.append(_wall_tile_transform(Vector3(4.58, 0.0, -1.52 + float(i) * 0.51), -PI * 0.5))
	for i in range(11):
		path.append(_wall_tile_transform(Vector3(2.45 - float(i) * 0.49, 0.0, 2.42), PI))
	for i in range(7):
		path.append(_wall_tile_transform(Vector3(-4.58, 0.0, 1.52 - float(i) * 0.51), PI * 0.5))
	return path


func _wall_body_transforms() -> Array[Transform3D]:
	var stack_path := _wall_stack_path()
	var consumed_stack_count := stack_path.size() - _wall_stack_count(wall_ratio)
	var body_transforms: Array[Transform3D] = []
	for stack_index in range(consumed_stack_count, stack_path.size()):
		var stack_transform: Transform3D = stack_path[stack_index]
		var lower_transform := stack_transform
		lower_transform.origin.y = 0.070
		body_transforms.append(lower_transform)
		var upper_transform := stack_transform
		upper_transform.origin.y = 0.215
		body_transforms.append(upper_transform)
	return body_transforms


func _wall_back_transforms(body_transforms: Array[Transform3D]) -> Array[Transform3D]:
	var back_transforms: Array[Transform3D] = []
	for body_index in range(1, body_transforms.size(), 2):
		var upper_transform := body_transforms[body_index]
		var yaw := upper_transform.basis.get_euler().y
		var back_basis := Basis(Vector3.UP, yaw) * Basis(Vector3.RIGHT, -PI * 0.5)
		back_transforms.append(Transform3D(back_basis, upper_transform.origin + Vector3(0.0, 0.081, 0.0)))
	return back_transforms


func _build_corner_hardware(lacquer: StandardMaterial3D) -> void:
	var corners := [
		Vector3(-5.08, 0.24, -2.80),
		Vector3(5.08, 0.24, -2.80),
		Vector3(-5.08, 0.24, 2.80),
		Vector3(5.08, 0.24, 2.80),
	]
	for i in range(corners.size()):
		var gold_cap := _add_beveled_box(stage_root, "CornerGoldCap_%d" % i, Vector3(0.43, 0.11, 0.43), corners[i], gold_material, 0.042)
		gold_cap.rotation.y = PI * 0.25
		var lacquer_inset := _add_beveled_box(stage_root, "CornerLacquerInset_%d" % i, Vector3(0.27, 0.125, 0.27), corners[i] + Vector3(0.0, 0.035, 0.0), lacquer, 0.040)
		lacquer_inset.rotation.y = PI * 0.25


func _build_seat_plaques(porcelain: StandardMaterial3D) -> void:
	var positions := [
		Vector3(0.0, 0.23, 2.02),
		Vector3(4.04, 0.23, 0.0),
		Vector3(0.0, 0.23, -2.02),
		Vector3(-4.04, 0.23, 0.0),
	]
	var rotations := [0.0, -PI * 0.5, PI, PI * 0.5]
	for i in range(4):
		var plaque := _add_flat_tile(stage_root, "SeatPlaque_%d" % i, positions[i], porcelain, _load_texture(SEAT_TILE_PATHS[i]), Vector2(0.42, 0.58))
		plaque.rotation.y = rotations[i]


func _wall_tile_transform(position: Vector3, yaw: float) -> Transform3D:
	return Transform3D(Basis(Vector3.UP, yaw), position)


func _update_active_marker() -> void:
	if active_marker == null or not is_instance_valid(active_marker):
		return
	var positions := [
		Vector3(0.0, 0.23, 2.66),
		Vector3(4.82, 0.23, 0.0),
		Vector3(0.0, 0.23, -2.66),
		Vector3(-4.82, 0.23, 0.0),
	]
	active_marker.position = positions[active_seat]
	if active_light != null and is_instance_valid(active_light):
		active_light.position = active_marker.position + Vector3(0.0, 1.35, 0.0)


func _add_upright_tile(parent: Node3D, node_name: String, position: Vector3, yaw: float, body_material: StandardMaterial3D, texture: Texture2D, tile_size: Vector2 = Vector2(0.72, 1.02)) -> Node3D:
	var tile := Node3D.new()
	tile.name = node_name
	tile.position = position
	tile.rotation.y = yaw
	tile.set_meta("rest_y", position.y)
	tile.set_meta("rest_yaw", yaw)
	parent.add_child(tile)
	var jade_back := _material("Carved jade tile back", Color(0.20, 0.14, 0.09), 0.14, 0.18, Color(0.06, 0.04, 0.02))
	_add_beveled_box(tile, "PorcelainBody", Vector3(tile_size.x, tile_size.y, 0.16), Vector3.ZERO, body_material, 0.055)
	_add_beveled_box(tile, "JadeBackLayer", Vector3(tile_size.x * 0.92, tile_size.y * 0.90, 0.035), Vector3(0.0, 0.0, -0.090), jade_back, 0.014)
	_add_beveled_box(tile, "JadeFoot", Vector3(tile_size.x * 0.92, 0.09, 0.19), Vector3(0.0, -tile_size.y * 0.45, -0.012), jade_back, 0.026)
	var back_texture := _load_texture(TILE_BACK_TEXTURE_PATH)
	if back_texture != null:
		var back := _add_quad(tile, "TileBack", tile_size * Vector2(0.88, 0.86), Vector3(0.0, 0.0, -0.110), _texture_material(back_texture, 0.18))
		back.rotation.y = PI
		back.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	if texture != null:
		var face := _add_quad(tile, "TileFace", tile_size * Vector2(0.94, 0.94), Vector3(0.0, 0.0, 0.086), _face_decal_material(texture, true))
		face.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return tile


func _add_flat_tile(parent: Node3D, node_name: String, position: Vector3, body_material: StandardMaterial3D, texture: Texture2D, tile_size: Vector2) -> Node3D:
	var tile := Node3D.new()
	tile.name = node_name
	tile.position = position
	tile.set_meta("rest_y", position.y)
	parent.add_child(tile)
	var jade_base := _material("Flat tile lacquer base", Color(0.14, 0.10, 0.07), 0.16, 0.22, Color(0.05, 0.03, 0.02))  # r425 no jade green under focus/seat plaques
	_add_beveled_box(tile, "JadeBase", Vector3(tile_size.x * 0.94, 0.060, tile_size.y * 0.94), Vector3(0.0, -0.090, 0.0), jade_base, 0.022)
	_add_beveled_box(tile, "PorcelainBody", Vector3(tile_size.x, 0.16, tile_size.y), Vector3.ZERO, body_material, 0.048)
	var face := _add_quad(tile, "TileFace", tile_size * Vector2(0.94, 0.94), Vector3(0.0, 0.092, 0.0), _face_decal_material(texture, true))
	face.rotation.x = -PI * 0.5
	face.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return tile


func _add_box(parent: Node3D, node_name: String, dimensions: Vector3, position: Vector3, material: StandardMaterial3D) -> MeshInstance3D:
	var box := BoxMesh.new()
	box.size = dimensions
	box.material = material
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = box
	instance.position = position
	parent.add_child(instance)
	return instance


func _add_beveled_box(parent: Node3D, node_name: String, dimensions: Vector3, position: Vector3, material: StandardMaterial3D, bevel_radius: float) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = _beveled_box_mesh(dimensions, bevel_radius, _quality_bevel_segments())
	instance.material_override = material
	instance.position = position
	parent.add_child(instance)
	return instance


func _beveled_box_mesh(dimensions: Vector3, requested_radius: float, bevel_segments: int) -> ArrayMesh:
	var half := dimensions * 0.5
	var radius: float = minf(requested_radius, minf(half.x, minf(half.y, half.z)) * 0.92)
	var segments := maxi(1, bevel_segments)
	var cache_key := "%.4f:%.4f:%.4f:%.4f:%d" % [dimensions.x, dimensions.y, dimensions.z, radius, segments]
	var cached = beveled_mesh_cache.get(cache_key)
	if cached is ArrayMesh:
		return cached as ArrayMesh

	var x_samples := _bevel_axis_samples(half.x, radius, segments)
	var y_samples := _bevel_axis_samples(half.y, radius, segments)
	var z_samples := _bevel_axis_samples(half.z, radius, segments)
	var surface_tool := SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	_append_beveled_face(surface_tool, Vector3.RIGHT, Vector3.UP, Vector3.BACK, half, y_samples, z_samples, radius)
	_append_beveled_face(surface_tool, Vector3.LEFT, Vector3.BACK, Vector3.UP, half, z_samples, y_samples, radius)
	_append_beveled_face(surface_tool, Vector3.UP, Vector3.BACK, Vector3.RIGHT, half, z_samples, x_samples, radius)
	_append_beveled_face(surface_tool, Vector3.DOWN, Vector3.RIGHT, Vector3.BACK, half, x_samples, z_samples, radius)
	_append_beveled_face(surface_tool, Vector3.BACK, Vector3.RIGHT, Vector3.UP, half, x_samples, y_samples, radius)
	_append_beveled_face(surface_tool, Vector3.FORWARD, Vector3.UP, Vector3.RIGHT, half, y_samples, x_samples, radius)
	surface_tool.generate_tangents()
	var mesh := surface_tool.commit() as ArrayMesh
	mesh.resource_name = "Commercial beveled box %.3fx%.3fx%.3f" % [dimensions.x, dimensions.y, dimensions.z]
	beveled_mesh_cache[cache_key] = mesh
	return mesh


func _bevel_axis_samples(half_extent: float, radius: float, segments: int) -> PackedFloat32Array:
	var samples := PackedFloat32Array()
	var inner: float = maxf(0.0, half_extent - radius)
	for i in range(segments + 1):
		samples.append(-half_extent + radius * float(i) / float(segments))
	if inner > 0.0001:
		samples.append(inner)
	for i in range(1, segments + 1):
		samples.append(inner + radius * float(i) / float(segments))
	return samples


func _append_beveled_face(surface_tool: SurfaceTool, face_normal: Vector3, u_axis: Vector3, v_axis: Vector3, half: Vector3, u_samples: PackedFloat32Array, v_samples: PackedFloat32Array, radius: float) -> void:
	var face_extent := _axis_extent(half, face_normal)
	var u_extent := _axis_extent(half, u_axis)
	var v_extent := _axis_extent(half, v_axis)
	var face_origin := face_normal * face_extent
	for u_index in range(u_samples.size() - 1):
		for v_index in range(v_samples.size() - 1):
			var u0 := float(u_samples[u_index])
			var u1 := float(u_samples[u_index + 1])
			var v0 := float(v_samples[v_index])
			var v1 := float(v_samples[v_index + 1])
			var p00 := face_origin + u_axis * u0 + v_axis * v0
			var p10 := face_origin + u_axis * u1 + v_axis * v0
			var p11 := face_origin + u_axis * u1 + v_axis * v1
			var p01 := face_origin + u_axis * u0 + v_axis * v1
			_add_beveled_vertex(surface_tool, p00, half, radius, Vector2(_normalized_axis_uv(u0, u_extent), _normalized_axis_uv(v0, v_extent)))
			_add_beveled_vertex(surface_tool, p10, half, radius, Vector2(_normalized_axis_uv(u1, u_extent), _normalized_axis_uv(v0, v_extent)))
			_add_beveled_vertex(surface_tool, p11, half, radius, Vector2(_normalized_axis_uv(u1, u_extent), _normalized_axis_uv(v1, v_extent)))
			_add_beveled_vertex(surface_tool, p00, half, radius, Vector2(_normalized_axis_uv(u0, u_extent), _normalized_axis_uv(v0, v_extent)))
			_add_beveled_vertex(surface_tool, p11, half, radius, Vector2(_normalized_axis_uv(u1, u_extent), _normalized_axis_uv(v1, v_extent)))
			_add_beveled_vertex(surface_tool, p01, half, radius, Vector2(_normalized_axis_uv(u0, u_extent), _normalized_axis_uv(v1, v_extent)))


func _add_beveled_vertex(surface_tool: SurfaceTool, cube_point: Vector3, half: Vector3, radius: float, uv: Vector2) -> void:
	var inner := Vector3(max(0.0, half.x - radius), max(0.0, half.y - radius), max(0.0, half.z - radius))
	var core := Vector3(
		clamp(cube_point.x, -inner.x, inner.x),
		clamp(cube_point.y, -inner.y, inner.y),
		clamp(cube_point.z, -inner.z, inner.z)
	)
	var normal := (cube_point - core).normalized()
	surface_tool.set_normal(normal)
	surface_tool.set_uv(uv)
	surface_tool.add_vertex(core + normal * radius)


func _axis_extent(extents: Vector3, axis: Vector3) -> float:
	return abs(axis.x) * extents.x + abs(axis.y) * extents.y + abs(axis.z) * extents.z


func _normalized_axis_uv(value: float, extent: float) -> float:
	return value / max(0.0001, extent * 2.0) + 0.5


func _add_cylinder(parent: Node3D, node_name: String, radius: float, height: float, position: Vector3, material: StandardMaterial3D) -> MeshInstance3D:
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = radius
	cylinder.bottom_radius = radius
	cylinder.height = height
	cylinder.radial_segments = _quality_cylinder_segments()
	cylinder.material = material
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = cylinder
	instance.position = position
	parent.add_child(instance)
	return instance


func _add_quad(parent: Node3D, node_name: String, dimensions: Vector2, position: Vector3, material: Material) -> MeshInstance3D:
	var quad := QuadMesh.new()
	quad.size = dimensions
	quad.material = material
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = quad
	instance.position = position
	parent.add_child(instance)
	return instance


func _add_multimesh(parent: Node3D, node_name: String, mesh: Mesh, transforms: Array[Transform3D]) -> MultiMeshInstance3D:
	var multimesh := MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = mesh
	multimesh.instance_count = transforms.size()
	var instance := MultiMeshInstance3D.new()
	instance.name = node_name
	instance.multimesh = multimesh
	parent.add_child(instance)
	for i in range(transforms.size()):
		multimesh.set_instance_transform(i, transforms[i])
	return instance


func _material(resource_name: String, color: Color, metallic: float, roughness: float, emission: Color = Color.BLACK) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.resource_name = resource_name
	material.albedo_color = color
	material.metallic = metallic
	material.roughness = roughness
	material.clearcoat_enabled = roughness < 0.40
	if material.clearcoat_enabled:
		# Soft porcelain glaze — hard clearcoat read as a glowing hot-spot on tile faces.
		material.clearcoat = clamp(0.18 + metallic * 0.12, 0.0, 0.42)
		material.clearcoat_roughness = clamp(roughness * 1.05, 0.14, 0.42)
	if color.a < 0.999:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if emission != Color.BLACK:
		material.emission_enabled = true
		material.emission = emission
		material.emission_energy_multiplier = 0.28
	return material


func _texture_material(texture: Texture2D, roughness: float = 0.18) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.resource_name = "Mahjong face material"
	# Ivory base without bleaching texture inks under battle lighting.
	material.albedo_color = Color(0.93, 0.91, 0.87, 1.0)
	material.albedo_texture = texture
	material.metallic = 0.02
	material.roughness = maxf(roughness, 0.16)
	material.clearcoat_enabled = true
	material.clearcoat = 0.34
	material.clearcoat_roughness = clamp(maxf(roughness, 0.16) * 0.90, 0.12, 0.30)
	# No emissive face texture: emission was the main wash-out source.
	material.emission_enabled = false
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	return material


func _hand_face_material(texture: Texture2D) -> StandardMaterial3D:
	return _face_decal_material(texture, true)


func _table_tile_decal_material(texture: Texture2D) -> StandardMaterial3D:
	return _face_decal_material(texture, false)


func _face_decal_material(texture: Texture2D, hand_strength: bool = false) -> StandardMaterial3D:
	# Faithful display of authored assets/tiles art — no color grading / no mipmap blur.
	var material := StandardMaterial3D.new()
	material.resource_name = "Mahjong faithful tile face" if hand_strength else "River faithful tile face"
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(1.0, 1.0, 1.0, 1.0)
	material.albedo_texture = texture
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.emission_enabled = false
	return material


func _table_tile_decal_material_legacy(texture: Texture2D) -> StandardMaterial3D:
	return _face_decal_material(texture, false)


func _apply_material_texture(material: StandardMaterial3D, path: String, uv_scale: Vector3, tint: Color, normal_path: String = "", roughness_path: String = "", normal_scale: float = 1.0) -> void:
	var texture := _load_texture(path)
	if texture == null:
		return
	material.albedo_texture = texture
	material.albedo_color = tint
	material.uv1_scale = uv_scale
	material.texture_repeat = true
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	if resolved_quality == QUALITY_LOW:
		return
	var normal_texture := _load_texture(normal_path)
	if normal_texture != null:
		material.normal_enabled = true
		material.normal_texture = normal_texture
		material.normal_scale = normal_scale
	var roughness_texture := _load_texture(roughness_path)
	if roughness_texture != null:
		material.roughness = 1.0
		material.roughness_texture = roughness_texture
		material.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED


func _load_texture(path: String) -> Texture2D:
	if not ResourceLoader.exists(path):
		return null
	var resource = load(path)
	return resource as Texture2D


func _sync_viewport_size() -> void:
	if viewport_3d == null or not is_instance_valid(viewport_3d):
		return
	var requested := Vector2i(max(1, int(round(size.x))), max(1, int(round(size.y))))
	var max_render_size := _quality_render_size()
	var width_shrink := ceili(float(requested.x) / float(max_render_size.x))
	var height_shrink := ceili(float(requested.y) / float(max_render_size.y))
	# Keep hand/river faces 1:1 with container pixels so authored tile art stays sharp.
	if stage_mode == "hand" or stage_mode == "table_tiles":
		stretch_shrink = 1
	else:
		stretch_shrink = clampi(maxi(1, maxi(width_shrink, height_shrink)), 1, 4)
	if stage_mode == "hand":
		_apply_hand_layout()
	elif stage_mode == "table_tiles":
		_apply_table_tile_layout()


func _apply_hand_layout() -> void:
	if stage_mode != "hand" or camera == null or not is_instance_valid(camera) or hand_tile_roots.is_empty():
		return
	var safe_height := maxf(1.0, size.y)
	var horizontal_span := camera.size * maxf(1.0, size.x) / safe_height
	for i in range(hand_tile_roots.size()):
		var tile_root := hand_tile_roots[i]
		if tile_root == null or not is_instance_valid(tile_root):
			continue
		var normalized_x := float(hand_normalized_positions[i]) if i < hand_normalized_positions.size() else (float(i) / maxf(1.0, float(hand_tile_roots.size() - 1)) * 1.8 - 0.9)
		var rest_x := normalized_x * horizontal_span * 0.485
		tile_root.set_meta("rest_x", rest_x)
		tile_root.set_meta("rest_yaw", -normalized_x * 0.045)
		tile_root.position.x = rest_x
		tile_root.rotation.y = float(tile_root.get_meta("rest_yaw", 0.0))
	_sync_hand_batches()


func _apply_hand_pose(delta: float, immediate: bool = false) -> void:
	for i in range(hand_tile_roots.size()):
		var tile_root := hand_tile_roots[i]
		if tile_root == null or not is_instance_valid(tile_root):
			continue
		var rest_y := float(tile_root.get_meta("rest_y", 0.015))
		var rest_z := float(tile_root.get_meta("rest_z", 0.0))
		var rest_roll := float(tile_root.get_meta("rest_roll", 0.0))
		var is_hovered := i == hand_hovered_index
		var is_pressed := i == hand_pressed_index
		var is_drawn := bool(tile_root.get_meta("drawn", false))
		var is_highlighted := bool(tile_root.get_meta("highlighted", false))
		var target_y := rest_y + (0.190 if is_hovered else 0.0) + (0.034 if is_highlighted and not is_hovered else 0.0) - (0.050 if is_pressed else 0.0)
		if is_drawn and effects_enabled:
			target_y += 0.028 + sin(elapsed * 2.15 + float(i) * 0.3) * 0.016
		if is_highlighted and effects_enabled and not is_hovered:
			target_y += sin(elapsed * 1.8 + float(i) * 0.22) * 0.012
		var target_z := rest_z + (0.125 if is_hovered else 0.0) + (0.042 if is_highlighted and not is_hovered else 0.0) + (0.030 if is_pressed else 0.0)
		var target_scale := Vector3.ONE * (0.955 if is_pressed else (1.065 if is_hovered else (1.034 if is_highlighted else 1.0)))
		var target_roll := rest_roll + (-0.034 if is_hovered else (-0.016 if is_highlighted else 0.0))
		if immediate:
			tile_root.position.y = target_y
			tile_root.position.z = target_z
			tile_root.scale = target_scale
			tile_root.rotation.z = target_roll
		else:
			var motion_weight := clampf(delta * 11.0, 0.0, 1.0)
			tile_root.position.y = lerpf(tile_root.position.y, target_y, motion_weight)
			tile_root.position.z = lerpf(tile_root.position.z, target_z, motion_weight)
			tile_root.scale = tile_root.scale.lerp(target_scale, motion_weight)
			tile_root.rotation.z = lerpf(tile_root.rotation.z, target_roll, motion_weight)
	_sync_hand_batches()


func _sync_hand_batches() -> void:
	if hand_body_batch == null or hand_back_batch == null or hand_foot_batch == null:
		return
	if not is_instance_valid(hand_body_batch) or not is_instance_valid(hand_back_batch) or not is_instance_valid(hand_foot_batch):
		return
	for i in range(hand_tile_roots.size()):
		var tile_root := hand_tile_roots[i]
		if tile_root == null or not is_instance_valid(tile_root):
			continue
		var root_transform := tile_root.transform
		hand_body_batch.multimesh.set_instance_transform(i, root_transform)
		hand_back_batch.multimesh.set_instance_transform(i, root_transform * Transform3D(Basis.IDENTITY, Vector3(0.0, 0.0, -0.125)))
		hand_foot_batch.multimesh.set_instance_transform(i, root_transform * Transform3D(Basis.IDENTITY, Vector3(0.0, -hand_world_tile_height * 0.455, -0.012)))


func _apply_table_tile_layout() -> void:
	if stage_mode != "table_tiles" or camera == null or not is_instance_valid(camera) or table_tile_roots.is_empty():
		return
	var safe_height := maxf(1.0, size.y)
	var vertical_span := camera.size
	var horizontal_span := vertical_span * maxf(1.0, size.x) / safe_height
	for i in range(table_tile_roots.size()):
		var tile_root := table_tile_roots[i]
		if tile_root == null or not is_instance_valid(tile_root):
			continue
		var entry: Dictionary = table_tile_entries[i] if i < table_tile_entries.size() else {}
		var center: Vector2 = entry.get("center", Vector2(0.5, 0.5))
		var normalized_size: Vector2 = entry.get("size", Vector2(0.035, 0.065))
		var world_size := Vector3(
			maxf(0.10, normalized_size.x * horizontal_span),
			1.0,
			maxf(0.14, normalized_size.y * vertical_span)
		)
		var highlighted := bool(tile_root.get_meta("highlighted", false))
		var raised := bool(tile_root.get_meta("raised", false)) or str(tile_root.get_meta("role", "discard")) == "meld"
		var rest_y := (0.060 if raised else 0.0) + (0.105 if highlighted else 0.0)
		tile_root.position = Vector3(
			(center.x - 0.5) * horizontal_span,
			rest_y,
			(center.y - 0.5) * vertical_span
		)
		tile_root.rotation.y = float(entry.get("rotation", 0.0))
		# A restrained physical lean exposes the porcelain thickness in a top-down
		# UI without moving the transparent hit proxies away from their tiles.
		var lean_sign := -1.0 if center.x < 0.5 else 1.0
		tile_root.rotation.x = deg_to_rad(-1.35 if raised else -0.65)
		tile_root.rotation.z = deg_to_rad(lean_sign * (2.15 if highlighted else 0.65))
		tile_root.scale = world_size
		tile_root.set_meta("rest_y", rest_y)
		tile_root.set_meta("rest_scale", world_size)
	_sync_table_tile_batches()


func _apply_table_tile_pose(delta: float, immediate: bool = false) -> void:
	for tile_root in table_tile_roots:
		if tile_root == null or not is_instance_valid(tile_root):
			continue
		var highlighted := bool(tile_root.get_meta("highlighted", false))
		var rest_y := float(tile_root.get_meta("rest_y", 0.0))
		var rest_scale: Vector3 = tile_root.get_meta("rest_scale", tile_root.scale)
		var phase := float(tile_root.get_meta("phase", 0.0))
		var target_y := rest_y
		var target_scale := rest_scale
		if highlighted and effects_enabled:
			target_y += 0.048 + sin(elapsed * 1.75 + phase) * 0.018
			target_scale = rest_scale * (1.055 + sin(elapsed * 1.40 + phase) * 0.014)
		if immediate:
			tile_root.position.y = target_y
			tile_root.scale = target_scale
		else:
			var motion_weight := clampf(delta * 8.0, 0.0, 1.0)
			tile_root.position.y = lerpf(tile_root.position.y, target_y, motion_weight)
			tile_root.scale = tile_root.scale.lerp(target_scale, motion_weight)
	_sync_table_tile_batches()


func _sync_table_tile_batches() -> void:
	if table_tile_body_batch == null or table_tile_face_batch == null or table_tile_base_batch == null or table_tile_shadow_batch == null:
		return
	if not is_instance_valid(table_tile_body_batch) or not is_instance_valid(table_tile_face_batch) or not is_instance_valid(table_tile_base_batch) or not is_instance_valid(table_tile_shadow_batch):
		return
	for i in range(table_tile_roots.size()):
		var tile_root := table_tile_roots[i]
		if tile_root == null or not is_instance_valid(tile_root):
			continue
		var root_transform := tile_root.transform
		table_tile_body_batch.multimesh.set_instance_transform(i, root_transform)
		table_tile_face_batch.multimesh.set_instance_transform(i, root_transform * Transform3D(Basis.IDENTITY, Vector3(0.0, 0.078, 0.0)))
		table_tile_base_batch.multimesh.set_instance_transform(i, root_transform * Transform3D(Basis.IDENTITY, Vector3(0.035, -0.094, 0.045)))
		var shadow_basis := Basis(Vector3.RIGHT, -PI * 0.5)
		table_tile_shadow_batch.multimesh.set_instance_transform(i, root_transform * Transform3D(shadow_basis, Vector3(0.060, -0.128, 0.065)))


func _resolve_quality() -> int:
	if requested_quality != QUALITY_AUTO:
		return requested_quality
	var display_name := DisplayServer.get_name().to_lower()
	if display_name == "headless" or OS.has_feature("web"):
		return QUALITY_STANDARD
	# Software GL (llvmpipe / SwiftShader) cannot sustain commercial HIGH profile.
	var adapter := str(RenderingServer.get_video_adapter_name()).to_lower()
	if adapter.find("llvmpipe") >= 0 or adapter.find("swiftshader") >= 0 or adapter.find("softpipe") >= 0:
		return QUALITY_LOW
	if OS.has_feature("mobile"):
		var screen_size := DisplayServer.screen_get_size()
		var largest_edge := maxi(screen_size.x, screen_size.y)
		if largest_edge <= 1600 or OS.get_processor_count() <= 4:
			return QUALITY_LOW
		return QUALITY_STANDARD
	return QUALITY_HIGH


func _quality_render_size() -> Vector2i:
	match resolved_quality:
		QUALITY_LOW:
			return Vector2i(960, 540)
		QUALITY_HIGH:
			return Vector2i(1440, 810)
		_:
			return Vector2i(1280, 720)


func _quality_msaa() -> Viewport.MSAA:
	match resolved_quality:
		QUALITY_LOW:
			return Viewport.MSAA_DISABLED
		QUALITY_HIGH:
			return Viewport.MSAA_4X
		_:
			return Viewport.MSAA_2X


func _quality_shadow_atlas_size() -> int:
	match resolved_quality:
		QUALITY_LOW:
			return 512
		QUALITY_HIGH:
			return 2048
		_:
			return 1024


func _quality_bevel_segments() -> int:
	return [1, 2, 3][resolved_quality]


func _quality_cylinder_segments() -> int:
	return [20, 32, 48][resolved_quality]


func performance_diagnostics() -> Dictionary:
	var mesh_instances := stage_root.find_children("*", "MeshInstance3D", true, false) if stage_root != null else []
	var multimesh_instances := stage_root.find_children("*", "MultiMeshInstance3D", true, false) if stage_root != null else []
	var mesh_faces := 0
	var multimesh_faces := 0
	var batched_instances := 0
	for node in mesh_instances:
		var instance := node as MeshInstance3D
		if instance.mesh != null:
			mesh_faces += instance.mesh.get_faces().size() / 3
	for node in multimesh_instances:
		var instance := node as MultiMeshInstance3D
		if instance.multimesh == null:
			continue
		batched_instances += instance.multimesh.instance_count
		if instance.multimesh.mesh != null:
			multimesh_faces += instance.multimesh.mesh.get_faces().size() / 3
	var render_size := Vector2i(maxi(1, int(round(size.x)) / stretch_shrink), maxi(1, int(round(size.y)) / stretch_shrink))
	return {
		"quality": resolved_quality,
		"render_size": render_size,
		"render_pixels": render_size.x * render_size.y,
		"render_pixel_budget": _quality_render_size().x * _quality_render_size().y,
		"bevel_segments": _quality_bevel_segments(),
		"cylinder_segments": _quality_cylinder_segments(),
		"mesh_instances": mesh_instances.size(),
		"multimesh_instances": multimesh_instances.size(),
		"batched_instances": batched_instances,
		"unique_mesh_faces": mesh_faces + multimesh_faces,
	}


func _process(delta: float) -> void:
	if camera == null or not is_instance_valid(camera):
		return
	elapsed += delta
	pointer_smooth = pointer_smooth.lerp(pointer_target, clamp(delta * 3.8, 0.0, 1.0))
	if stage_mode == "menu":
		camera.position = Vector3(pointer_smooth.x * 0.30 + sin(elapsed * 0.22) * 0.045, 5.5 - pointer_smooth.y * 0.16, 9.2)
		camera.look_at(Vector3(pointer_smooth.x * 0.12, 0.10 - pointer_smooth.y * 0.06, -0.15), Vector3.UP)
		if showcase_root != null and is_instance_valid(showcase_root):
			showcase_root.position.y = sin(elapsed * 0.78) * 0.025
			showcase_root.rotation.y = sin(elapsed * 0.31) * 0.006
		for i in range(showcase_tiles.size()):
			var tile := showcase_tiles[i]
			if tile == null or not is_instance_valid(tile):
				continue
			var rest_y := float(tile.get_meta("rest_y", tile.position.y))
			var rest_yaw := float(tile.get_meta("rest_yaw", tile.rotation.y))
			tile.position.y = rest_y + sin(elapsed * 0.92 + float(i) * 0.72) * 0.018
			tile.rotation.y = rest_yaw + sin(elapsed * 0.48 + float(i) * 0.44) * 0.012
	elif stage_mode == "hand":
		_apply_hand_pose(delta)
	elif stage_mode == "table_tiles":
		_apply_table_tile_pose(delta)
	else:
		camera.position = Vector3(sin(elapsed * 0.18) * 0.055, 8.4, 8.8 + cos(elapsed * 0.16) * 0.035)
		camera.look_at(Vector3(0.0, -0.15, -0.20), Vector3.UP)
		if active_marker != null and is_instance_valid(active_marker):
			var pulse := 0.96 + sin(elapsed * 2.2) * 0.08
			active_marker.scale = Vector3(pulse, 1.0, pulse)
		if focus_tile_root != null and is_instance_valid(focus_tile_root):
			var rest_y := float(focus_tile_root.get_meta("rest_y", focus_tile_root.position.y))
			focus_tile_root.position.y = rest_y + sin(elapsed * 1.70) * 0.045
			focus_tile_root.rotation.y = sin(elapsed * 0.48) * 0.042
			focus_tile_root.rotation.x = deg_to_rad(-2.6 + sin(elapsed * 0.9) * 0.40)
	if active_light != null and is_instance_valid(active_light):
		if stage_mode == "hand":
			active_light.light_energy = 2.25 + sin(elapsed * 0.85) * 0.16
		elif stage_mode == "table_tiles":
			active_light.light_energy = 2.05 + sin(elapsed * 0.85) * 0.12
		else:
			active_light.light_energy = 3.25 + sin(elapsed * 0.85) * 0.22
