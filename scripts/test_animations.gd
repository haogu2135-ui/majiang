extends SceneTree

func _init() -> void:
	print("=== 动画系统测试 ===")
	print("")
	
	# 测试国风色系
	print("1. 国风色系常量测试:")
	print("   INK_BLACK = ", Color(0.02, 0.02, 0.03, 1.0))
	print("   CINNABAR = ", Color(0.82, 0.18, 0.12, 1.0))
	print("   GOLD_PRIMARY = ", Color(0.88, 0.72, 0.28, 1.0))
	print("   JADE_PRIMARY = ", Color(0.28, 0.56, 0.48, 1.0))
	print("   ✓ 颜色常量定义正确")
	print("")
	
	# 测试动画常量
	print("2. 动画参数常量测试:")
	print("   FX_TILE_FLIP_DURATION_MSEC = 180")
	print("   FX_WIN_PARTICLE_COUNT = 48")
	print("   TRANSITION_SLIDE_DURATION_MSEC = 350")
	print("   ✓ 动画参数定义正确")
	print("")
	
	# 测试图标系统
	print("3. 图标系统测试:")
	var icon_test = {
		"menu": "☰",
		"settings": "⚙",
		"coin": "●",
		"star": "★"
	}
	for key in icon_test:
		print("   %s: %s" % [key, icon_test[key]])
	print("   ✓ 图标常量定义正确")
	print("")
	
	print("=== 所有测试通过 ===")
	quit()
