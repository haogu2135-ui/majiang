extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var scene = load("res://scripts/main.gd").new()
	root.add_child(scene)
	await process_frame
	scene.mode = "offline"
	scene.players = []
	for i in range(4):
		scene.players.append({"name":"P%d"%i,"hand":[],"discards":[],"melds":[],"flowers":0,"flower_tiles":[],"score":25000})
	scene.wall = scene.make_wall()
	if scene.has_method("setup_tile_order"):
		scene.setup_tile_order()
	var candidates = [
		["2W","3W","4W","2T","3T","4T","2B","3B","4B","5W","6W","7W","8W"],
		["2W","3W","4W","5W","6W","7W","2T","3T","4T","5T","6T","7T","8T"],
		["2W","2W","3W","3W","4W","4W","5W","6W","7W","2T","3T","4T","5T"],
		["1W","1W","1W","2W","3W","4W","5W","6W","7W","8W","9W","E","E"],
		["2W","3W","4W","5W","6W","7W","8W","8W","2T","3T","4T","5T","6T"],
		["2W","3W","4W","5W","6W","7W","8W","9W","9W","2T","3T","4T","5T"],
		["2B","3B","4B","5B","6B","7B","8B","8B","2W","3W","4W","5W","6W"],
	]
	for hand in candidates:
		scene.players[3]["hand"] = hand.duplicate()
		scene.players[3]["melds"] = []
		var m = scene.effective_tile_metrics(hand, 0, 3, 99)
		var tiles = m.get("tiles", [])
		if tiles.size() < 2:
			continue
		var scores = []
		for wt in tiles:
			var probe = hand.duplicate(); probe.append(str(wt))
			var sc = scene.calculate_win_score_from_tiles(3, probe, false)
			scores.append([str(wt), int(sc.get("fan",0)), int(sc.get("points",0)), sc.get("reasons",[])])
		var pts = scores.map(func(x): return x[2])
		var mn = pts.min(); var mx = pts.max()
		if mx > mn:
			print("HAND", hand)
			print("  waits", scores, "gap", mx-mn)
	scene.queue_free()
	quit(0)
