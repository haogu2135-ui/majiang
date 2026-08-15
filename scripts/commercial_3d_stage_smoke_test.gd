extends SceneTree

const StageScript := preload("res://scripts/ui/commercial_3d_stage.gd")

var failed := false


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	var host := Control.new()
	host.name = "Commercial3DTestHost"
	host.size = Vector2(1600, 900)
	root.add_child(host)

	var stage = StageScript.new()
	stage.name = "Commercial3DStageProbe"
	stage.size = host.size
	stage.configure("menu", false)
	host.add_child(stage)
	await process_frame
	await process_frame

	check(stage.mouse_filter == Control.MOUSE_FILTER_IGNORE, "3D stage never intercepts gameplay input")
	check(stage.find_child("Realtime3DViewport", true, false) is SubViewport, "3D stage creates a dedicated viewport")
	check(stage.find_child("CommercialStageCamera", true, false) is Camera3D, "3D stage creates an active perspective camera")
	check(stage.find_child("CinematicKeyLight", true, false) is DirectionalLight3D, "3D stage creates a shadow-casting cinematic key light")
	check(stage.find_child("MenuTableBody", true, false) is MeshInstance3D, "menu mode creates a lacquer table body")
	var menu_table_body := stage.find_child("MenuTableBody", true, false) as MeshInstance3D
	check(menu_table_body != null and menu_table_body.mesh is ArrayMesh, "menu table shell uses rounded physical geometry")
	check(stage.find_child("Menu3DShowcase", true, false) is Node3D, "menu mode keeps a decorative 3D stage behind the 2D menu")
	check(stage.find_child("HeroTile_0", true, false) == null and stage.find_child("HeroTile_2", true, false) == null, "menu mode never creates executable 3D tile showcases")
	check(stage.find_child("TileBack", true, false) == null and stage.find_child("PorcelainBody", true, false) == null, "menu mode keeps tile faces out of the 3D stage")
	check(stage.stretch_shrink >= 1 and stage.stretch_shrink <= 4, "3D render resolution uses a bounded adaptive scale")

	var focus_texture = load("res://assets/tiles/tile_honor_east.png") as Texture2D
	stage.configure("battle", false, 2, 0.25, focus_texture)
	await process_frame
	check(stage.find_child("BattleTableBody", true, false) is MeshInstance3D, "battle mode creates a physical table shell")
	var felt_instance := stage.find_child("BattleTableFelt", true, false) as MeshInstance3D
	var felt_material := felt_instance.material_override as StandardMaterial3D if felt_instance != null else null
	var lacquer_instance := stage.find_child("BattleTableBody", true, false) as MeshInstance3D
	var lacquer_material := lacquer_instance.material_override as StandardMaterial3D if lacquer_instance != null else null
	check(felt_instance != null and felt_instance.mesh is ArrayMesh and lacquer_instance != null and lacquer_instance.mesh is ArrayMesh, "battle felt and lacquer shell use rounded physical geometry")
	var felt_arrays := felt_instance.mesh.surface_get_arrays(0) if felt_instance != null and felt_instance.mesh != null else []
	check(not felt_arrays.is_empty() and (felt_arrays[Mesh.ARRAY_TANGENT] as PackedFloat32Array).size() > 0, "rounded table mesh preserves tangents for normal mapping")
	check(felt_material != null and felt_material.albedo_texture != null, "battle table loads the GPT-generated seamless felt material")
	check(lacquer_material != null and lacquer_material.albedo_texture != null, "battle shell loads the GPT-generated seamless lacquer material")
	check(felt_material != null and felt_material.normal_enabled and felt_material.normal_texture != null and felt_material.roughness_texture != null, "standard quality adds seamless felt normal and roughness maps")
	check(lacquer_material != null and lacquer_material.normal_enabled and lacquer_material.normal_texture != null and lacquer_material.roughness_texture != null, "standard quality adds lacquer grain normal and roughness maps")
	check(stage.find_child("BattleWallBodies3D", true, false) == null and stage.find_child("BattleWallBackFaces3D", true, false) == null, "battle mode leaves wall faces to the 2D assets/tiles layer")
	check(stage.find_child("SeatPlaque_0", true, false) == null and stage.find_child("SeatPlaque_3", true, false) == null, "battle mode keeps wind plaques in the 2D seat panels")
	check(stage.find_child("FocusDiscard3DTile", true, false) == null and stage.find_child("FocusDiscardContactShadow", true, false) != null, "battle mode has no 3D focus tile, only an optional contact shadow")
	check(stage.find_child("CornerGoldCap_0", true, false) is MeshInstance3D and stage.find_child("CornerGoldCap_3", true, false) is MeshInstance3D, "battle mode creates four diamond corner fittings")
	var marker := stage.find_child("ActiveSeat3DMarker", true, false) as Node3D
	check(marker != null and marker.position.z < 0.0, "battle mode places the active marker at the requested seat")
	stage.configure("battle", false, 0, 1.0, focus_texture, StageScript.QUALITY_HIGH)
	await process_frame
	check(stage.find_child("BattleWallBodies3D", true, false) == null and stage.find_child("BattleWallBackFaces3D", true, false) == null, "high quality battle mode still does not instantiate 3D wall faces")
	var realtime_viewport := stage.find_child("Realtime3DViewport", true, false) as SubViewport
	check(realtime_viewport != null and realtime_viewport.msaa_3d == Viewport.MSAA_4X and realtime_viewport.positional_shadow_atlas_size == 2048, "high quality profile raises antialiasing and shadow precision")
	stage.sync_battle_state(3, 0.10)
	await process_frame
	marker = stage.find_child("ActiveSeat3DMarker", true, false) as Node3D
	check(stage.find_child("BattleWallBodies3D", true, false) == null and stage.find_child("BattleWallBackFaces3D", true, false) == null, "incremental state sync never rebuilds 3D wall faces")
	check(marker != null and marker.position.x < 0.0, "incremental state sync also updates the active seat marker")
	stage.configure("battle", false, 1, 0.50, focus_texture, StageScript.QUALITY_LOW)
	await process_frame
	realtime_viewport = stage.find_child("Realtime3DViewport", true, false) as SubViewport
	felt_instance = stage.find_child("BattleTableFelt", true, false) as MeshInstance3D
	felt_material = felt_instance.material_override as StandardMaterial3D if felt_instance != null else null
	check(realtime_viewport != null and realtime_viewport.msaa_3d == Viewport.MSAA_DISABLED and realtime_viewport.positional_shadow_atlas_size == 512, "low quality profile caps antialiasing and shadow cost")
	check(felt_material != null and not felt_material.normal_enabled, "low quality profile skips secondary PBR maps")

	var profile_expectations := [
		{"quality": StageScript.QUALITY_LOW, "pixels": 960 * 540, "bevel": 1, "cylinder": 20, "max_faces": 9000},
		{"quality": StageScript.QUALITY_STANDARD, "pixels": 1280 * 720, "bevel": 2, "cylinder": 32, "max_faces": 15000},
		{"quality": StageScript.QUALITY_HIGH, "pixels": 1440 * 810, "bevel": 3, "cylinder": 48, "max_faces": 23000},
	]
	stage.size = Vector2(2560, 1440)
	for expected in profile_expectations:
		stage.configure("battle", false, 0, 1.0, focus_texture, int(expected.quality))
		await process_frame
		var diagnostics: Dictionary = stage.performance_diagnostics()
		check(int(diagnostics.render_pixels) <= int(expected.pixels), "quality profile keeps viewport pixels within its mobile render budget")
		check(int(diagnostics.render_pixel_budget) == int(expected.pixels), "quality profile exposes the configured render pixel budget")
		check(int(diagnostics.bevel_segments) == int(expected.bevel) and int(diagnostics.cylinder_segments) == int(expected.cylinder), "quality profile applies its deterministic mesh tessellation")
		check(int(diagnostics.multimesh_instances) == 0 and int(diagnostics.batched_instances) == 0, "battle stage has no 3D tile batches")
		check(int(diagnostics.mesh_instances) <= 42 and int(diagnostics.unique_mesh_faces) <= int(expected.max_faces), "battle scene stays within its per-profile geometry budget")

	var hand_faces: Array = [
		load("res://assets/tiles/tile_man1.png") as Texture2D,
		load("res://assets/tiles/tile_pin5.png") as Texture2D,
		load("res://assets/tiles/tile_honor_east.png") as Texture2D,
	]
	var hand_positions := PackedFloat32Array([-0.62, 0.0, 0.62])
	var hand_states: Array = [
		{"highlighted": false, "drawn": false, "risk_strength": 0.0, "accent": Color(0.80, 0.58, 0.24)},
		{"highlighted": true, "drawn": false, "risk_strength": 0.0, "accent": Color(0.94, 0.72, 0.24)},
		{"highlighted": false, "drawn": true, "risk_strength": 0.5, "accent": Color(0.82, 0.24, 0.16)},
	]
	stage.size = Vector2(1200, 140)
	stage.configure_hand(hand_faces, hand_positions, hand_states, 0.735, false, StageScript.QUALITY_STANDARD)
	await process_frame
	await process_frame
	var hand_camera := stage.find_child("CommercialStageCamera", true, false) as Camera3D
	var hand_tiles := stage.find_children("HandPhysicalTile3D_*", "Node3D", true, false)
	check(hand_camera != null and hand_camera.projection == Camera3D.PROJECTION_ORTHOGONAL, "hand mode uses a stable orthographic 3D camera aligned to hit targets")
	check(stage.find_child("HandTray3DFloor", true, false) is MeshInstance3D and stage.find_child("HandTray3DGoldRail", true, false) is MeshInstance3D, "hand mode creates a physical lacquer tray and gold rail")
	check(hand_tiles.is_empty() and stage.find_child("HandTilePorcelainBodies3D", true, false) == null and stage.find_child("HandTileJadeBacks3D", true, false) == null and stage.find_child("HandTileJadeFeet3D", true, false) == null, "hand mode keeps all tile faces in the 2D render path")
	check(stage.find_child("HandTileDecal_00", true, false) == null, "hand mode does not create 3D face decals")
	stage.set_hand_hovered(1, true)
	stage._process(0.12)
	check(stage.find_child("HandPhysicalTile3D_01", true, false) == null, "hand hover state never creates a 3D tile hit target")

	var table_entries: Array[Dictionary] = [
		{"texture": hand_faces[0], "center": Vector2(0.32, 0.35), "size": Vector2(0.035, 0.070), "rotation": -0.01, "highlighted": false, "accent": Color(0.42, 0.72, 0.60)},
		{"texture": hand_faces[1], "center": Vector2(0.50, 0.62), "size": Vector2(0.035, 0.070), "rotation": 0.0, "highlighted": true, "accent": Color(0.94, 0.72, 0.28)},
		{"texture": hand_faces[2], "center": Vector2(0.72, 0.46), "size": Vector2(0.035, 0.070), "rotation": 0.01, "highlighted": false, "accent": Color(0.54, 0.70, 0.86)},
	]
	stage.size = Vector2(900, 600)
	stage.configure_table_tiles(table_entries, false, StageScript.QUALITY_STANDARD)
	await process_frame
	await process_frame
	var table_tile_camera := stage.find_child("CommercialStageCamera", true, false) as Camera3D
	var table_tiles := stage.find_children("TableTilePhysical3D_*", "Node3D", true, false)
	check(table_tile_camera != null and table_tile_camera.projection == Camera3D.PROJECTION_ORTHOGONAL and is_equal_approx(table_tile_camera.rotation_degrees.x, -90.0), "table tile mode uses a stable top-down orthographic camera")
	check(table_tiles.is_empty() and stage.find_child("TableTilePorcelainBodies3D", true, false) == null and stage.find_child("TableTileGlazeLips3D", true, false) == null and stage.find_child("TableTileJadeBases3D", true, false) == null and stage.find_child("TableTileContactShadows3D", true, false) == null, "table tile mode keeps all discard and meld faces in the 2D render path")
	check(stage.find_child("TableTileDecal_00", true, false) == null and stage.find_child("TableTileLatestRim", true, false) == null, "table tile mode does not create 3D face decals or tile rims")

	host.queue_free()
	await process_frame
	if failed:
		quit(1)
	else:
		print("commercial 3D stage smoke test passed")
		quit(0)


func check(condition: bool, message: String) -> void:
	if condition:
		return
	failed = true
	push_error("commercial 3D stage smoke test failed: %s" % message)
