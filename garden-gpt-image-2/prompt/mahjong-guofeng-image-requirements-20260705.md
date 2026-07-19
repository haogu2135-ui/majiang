# 国风麻将生图任务入口

执行对象：GPT Image / 生图 Agent
项目：`/root/yunzhuo-mahjong-godot`
完整需求文件：`/root/yunzhuo-mahjong-godot/GPT_IMAGE_AGENT_EXECUTION_BRIEF.md`

请严格按完整需求文件执行，不要只按本入口摘要出图。

## 优先级

1. P0：人机对战页。
2. P1：联机大厅。
3. P2：通用页面资产。

## 必看参考

```text
build/qa/pages/03_offline_battle.png
build/qa/pages_960x540/03_offline_battle.png
build/qa/pages/08_online_lobby.png
build/qa/pages_960x540/08_online_lobby.png
```

## 第一批必须执行

- `table_gpt_backdrop_v4.png`
- `mahjong_tile_3d_edit_set` 数牌第一批
- `wall_strip_landscape_v2.png`
- `tile_back_3d.png`
- `wall_live_feedback_kit_v1.png`
- `hand_gpt_tray_v4.png`
- `action_gpt_dock_v5.png`
- `seat_gpt_brocade_v4.png`
- `pending_claim_status_strip.png`

## 硬约束

- 不要生成文字、数字、Logo、水印、人物脸、随机按钮、随机牌面。
- 透明素材必须是真 alpha。
- 麻将牌必须基于现有 `assets/tiles/*.png` 编辑，不能凭文本重画。
- 牌墙剩余量反馈只生成状态材质，不要把“余88”等数字画进图片。
- 所有候选图放入 `garden-gpt-image-2/image/candidates/`，验收后再进入 `assets/illustrations/`。
