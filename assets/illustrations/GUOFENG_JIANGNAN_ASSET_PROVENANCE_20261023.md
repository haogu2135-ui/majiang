# 清雅江南素材 · 2026-10-23

## 首页园林

- 运行资产：`menu_jiangnan_ink_gpt_20261023.png`，接入 `menu_guofeng_moonlit` 键。
- 模型：GPT Image 2，经本仓库已配置的图像 API；使用 imagegen skill 的原版 CLI，无自定义 SDK 请求。
- 提示词：`garden-gpt-image-2/prompt/guofeng_garden_ink_twilight_20261023_r2.md`。
- 原始输出：`output/imagegen/guofeng_art_refresh_20261023/garden_ink_twilight_r2.png`；QA原图副本：`build/qa/guofeng_art_refresh_20261023/assets/garden_ink_twilight_r2.png`。
- 运行资产与原始输出逐字节相同，未经程序绘图、调色或合成；SHA256：`13ad671b1b8bc1399cd910d76465a2d1e909df8382075d52ce7e82204b2f3e47`，实际尺寸1672×940。
- 原始调用日志：`build/qa/guofeng_art_refresh_20261023/generate_garden_r2.log`；耗时37.2秒。
- r1保留为弃选过程证据；r2修正摄影式虚焦及写实材质，独立只读审阅推荐接入。审阅报告：`build/qa/ui_engineer/JIANGNAN_ASSET_REVIEW_20261023.md`。整合页美术签收另行进行。

原始2D牌面 `assets/tiles` 未重生图、调色或改动。API密钥及订阅信息不记入素材文档。

## 首卡及牌桌材料

均由相同 imagegen CLI / GPT Image 2 生成；提示词位于 `garden-gpt-image-2/prompt/<同名>.md`，原始输出位于 `output/imagegen/guofeng_art_refresh_20261023/<同名>.png`，运行PNG是逐字节副本。日志分别为 `generate_offline_entry_r1.log`、`generate_battle_assets_r1.log`（同一QA目录）。牌桌三项使用 concurrency=1 顺序调用，没有与Godot并行。

| 运行素材 | 实际像素 | SHA256 | 使用方式 |
| --- | --- | --- | --- |
| menu_offline_jiangnan_20261023.png | 1672×940 | 87e576c0c6fa394bc892bfc35bfa31119b7ad27b7fa4a061302825f6ab7d2a48 | 首卡专用 `menu_entry_offline_gpt`；保留真实原2D东牌另接，不改变全局 `menu_ink_primary` |
| battle_hud_jiangnan_20261023.png | 2048×768 | c4001221ce21646e133aaa290e0fb805c6b17070567061499c5eb3b54dba5e0c | AtlasTexture `battle_hud_jiangnan_crop_20261023.tres`，仅引用原图 Rect2(0,0,2048,580)，保留金线并去纸尾 |
| battle_actions_jiangnan_20261023.png | 2172×724 | f30bf63486ba2952c45a53c49d4989683fb6ff15f163e6777689e5645ee02f6e | 专用操作底板已审阅；接线/整合待后续 |
| hand_tray_jiangnan_20261023.png | 2172×724 | 6aea879b2650b906c0c719e8c5d69282cc5a94eee61e5859adbff63d6dee948a | `hand_tray_jiangnan_gpt`，原生浅字和原牌覆盖在黛绿材料上 |

请求尺寸与返回尺寸存在差异，以上只记录实际PNG尺寸；不把请求值当作生成结果。HUD源区裁切仅为非破坏性引用，不绘制、合成或改变任何PNG像素。所有原始输出、弃选与失败日志保留。图像 API 不支持超过3:1的请求，因此三项条状材料请求1536×512后在实际UI窄幅接线；请求验证失败记录保留于 `battle-assets-dry-run.log`，修正后的无网络预检为 `battle-assets-dry-run-r2.log`。

素材只读审阅见 `JIANGNAN_BATTLE_ASSET_R1_20261023.md`、`JIANGNAN_HOME_CARD_R1_20261023.md`（`build/qa/ui_engineer/`）。素材通过只允许进入整合，不等于整页商业美术验收完成。
