# 插画和动画素材状态报告

更新日期：2026-07-06

## 当前结论

- `assets/illustrations/` 根目录以运行时登记的 GPT 插画 PNG 为主，另保留少量历史版本和回退 PNG。
- `scripts/main_base.gd` 中 `ILLUSTRATION_ASSET_PATHS := {}` 已清空；旧的非 GPT 强制插画通道不再加载。
- 运行时插画统一走 `GPT_ILLUSTRATION_ASSET_PATHS`、`optional_gpt_illustration_textures`、`add_optional_gpt_illustration_texture()`。
- 当前 GPT 插画注册数：95；注册路径缺失：0；待生成透明 PNG：0；已补齐稳定运行时 `.import` sidecar，并清理候选图/QA 截图目录下的 Godot 临时 `.import` 噪声。
- `assets/illustrations/` 根目录仍保留 5 个历史版本或回退 PNG（例如 `wall_strip_landscape.png` 和部分 v3 候选）；它们不是新的生图缺口，运行时缺失检查已通过。
- 旧的程序/PIL 生图脚本已删除；最终美术不得再通过本地脚本画点、线、纹理或牌面。
- `garden-gpt-image-2/image/menu_card_frame_kit-20260705*.png` 和 `garden-gpt-image-2/image/guofeng_3d_control_kit-20260705*.png` 仅作为 GPT 风格参考保留：视觉方向可用，但文件是 RGB/opaque 并画入棋盘格，未通过真实 alpha 验收，不能接入 `assets/illustrations/` 作为切片资源。
- `garden-gpt-image-2/image/menu_primary_3d_stage_overlay-20260705*.png` 和 `garden-gpt-image-2/image/offline_table_3d_overlay-20260705*.png` 仅作为失败候选保留：普通 generate/edit 输出为 RGB/1672x941，未通过真实 alpha 和目标尺寸验收。当前稳定版已改用 chroma-key 清理流程生成 true-alpha PNG 并接入 `assets/illustrations/`。

## 保留资产

### 图标

- 位置：`assets/icons/lucide/`
- 数量：38 个 SVG
- 许可证：MIT License
- 用途：按钮图标、HUD 图标、设置入口、状态提示。

### 动画 JSON

- 位置：`assets/animations/`
- 文件：`coin_spin.json`、`victory_sparkle.json`、`claim_response_orbit.json`、`discard_ink_splash.json`
- 用途：通过项目内轻量解析和 Godot 控件预览接入，不依赖额外插件。

### GPT 插画 PNG

- 位置：`assets/illustrations/`
- 规范：`GPT_IMAGE_ASSET_BRIEF.md`
- 生成记录：`garden-gpt-image-2/prompt/`
- 替换备份：`assets/illustrations/_replaced_20260705/`、`assets/illustrations/_replaced_20260706/`

重点已接入资产包括：

- 主菜单：`menu_lobby_gpt_scene`、`menu_lobby_ui_overlay`、`menu_hero_gpt_backdrop`
- 加载页：`loading_scene_gpt_backdrop`
- 对局桌面：`table_gpt_backdrop`、`offline_table_3d_overlay`、`hand_gpt_tray`、`action_gpt_dock`、`pending_claim_status_strip`、`wall_live_feedback_kit`、`top_hud_gpt_banner`、`seat_gpt_brocade`
- 元界面：`rules_gpt_scroll`、`stats_gpt_dashboard`、`achievement_gpt_gallery`、`shop_gpt_vault`、`online_gpt_lobby`、`settings_gpt_panel`
- 弹窗/状态：`exit_gpt_confirm`、`chat_gpt_panel`、`update_gpt_dialog`、`diagnostic_gpt_panel`、`toast_gpt_banner`、`reset_gpt_warning`
- 胡牌/动效：`win_result_stage`、`win_detail_gpt_scroll`、`win_celebration_gpt_burst`、`discard_splash_wash`、`claim_response_trail`

## 已移除内容

- 旧的非 GPT 插画 PNG 及对应 `.import` 已从 `assets/illustrations/` 根目录删除。
- 删除的脚本包括：`scripts/generate_flower_tiles.py`、`scripts/generate_illustration_assets.py`、`scripts/generate_mahjong_tiles.py`、`scripts/generate_stage_illustrations.py`、`scripts/import_real_mahjong_tiles.py`。
- 主菜单已移除旧程序绘制的月亮、印章、竹梅、云团、风轨、金粉、赛季/每日任务点线装饰，以及入口卡/快捷栏内的 route/node/tick/spark 类小装饰；当前改为 GPT 背景 + GPT UI 框体 + 原生 3D 质感控件。

## 动效策略

- 允许使用 Godot Tween 做控件动效：入场错峰、悬停缩放、低频呼吸、按压 wash/glow。
- 禁止把动效实现成程序生成的点线、路线、刻度、粒子贴图或伪插画。
- 主菜单当前新增动效：入口卡错峰淡入缩放、悬停轻微放大/旋转、快捷栏底板低频呼吸、快捷按钮错峰入场、卡片/快捷按钮按压柔光反馈。

## 麻将牌规则

- 可玩牌面必须参考当前 `assets/tiles/*.png`。
- 不允许只凭文字 prompt 生成可玩麻将牌。
- 任何 GPT 牌面候选必须走 `tools/generate_gpt_mahjong_tiles.py` 或等价 GPT edit 流程，并逐张核对花色、数量、文字和可读性。

## 验证记录

- `python3 tools/assemble_main.py --verify`
- `GODOT_SILENCE_ROOT_WARNING=1 godot --headless --path . -s scripts/ui_layout_smoke_test.gd`
- `GODOT_SILENCE_ROOT_WARNING=1 godot --headless --path . -s scripts/offline_smoke_test.gd`
- `GODOT_SILENCE_ROOT_WARNING=1 xvfb-run -a godot --path . -s scripts/page_screenshot_capture.gd`
- `python3 scripts/ui_screenshot_manifest_check.py`

截图输出：`build/qa/pages/`，总览图：`build/qa/pages/contact_sheet.jpg`。
