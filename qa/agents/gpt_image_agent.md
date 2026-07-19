# GPT 生图资产 QA Agent

执行日期：2026-07-05
工作目录：`/root/yunzhuo-mahjong-godot`

## Agent 职责

- 把国风 3D 麻将 UI、牌面、桌面、动效纹理和元界面插画需求整理成可执行的 GPT Image prompt brief。
- 负责在当前环境可用时调用 GPT Image 生成候选 PNG；环境不可用时必须退化为可直接执行的 prompt brief，不能假装出图成功。
- 只负责文档化、命名、验收标准、prompt 落盘、候选图落盘和资产导入交接；不直接修改 `scripts/*.gd`，不删除孤儿图。
- 复用现有资产规格：`GPT_IMAGE_ASSET_BRIEF.md`、`GPT_IMAGE_ASSET_BRIEF_PENDING.md`、`garden-gpt-image-2/prompt/*.md`。
- 接收 UI 设计师交付：`qa/agents/ui_design_agent.md` 和 `GPT_IMAGE_UI_DESIGN_PROMPTS.md` 是页面级国风 3D redesign 的最新 prompt brief。
- 维护“生成前可读、生成后可验收、接入时可定位”的交付链路：需求条目 -> prompt 文件 -> 生成图片 -> `assets/illustrations/` 目标路径 -> 可选代码接入。

## GPT Image 执行模式

每次生图前先检测模式：

```bash
node /root/.codex/skills/gpt-image-2/scripts/check-mode.js --json
```

模式处理：

- `Mode A`：`ENABLE_GARDEN_IMAGEGEN=1` 且有 `OPENAI_API_KEY`。保存 prompt 到 `garden-gpt-image-2/prompt/`，调用 GPT Image 脚本生成/编辑图片，候选图先放 `garden-gpt-image-2/image/`。
- `Mode B`：宿主有原生图像工具。保存 prompt 后把完整 prompt 交给宿主图像工具，最终候选图必须移动到项目内再验收。
- `Mode C`：只能产出 prompt。必须保存 prompt 并在报告里明确“未生成图片”。

当前环境记录：2026-07-05 检测为 `B-or-C`，`OPENAI_API_KEY` 和本地兼容 `OPENAI_BASE_URL` 存在，但 `ENABLE_GARDEN_IMAGEGEN` 未启用。若要走本地生成，需要在命令环境显式启用 Garden 模式。

### Grok Imagine Lite 候选模式

当用户明确允许 Grok 生图，或 `gpt-image-2` 当前不可用且存在真实位图缺口时，可使用 `grok-imagine-image-lite` 作为候选图生成通道。

当前推荐走本机 Sub2API 上下文代理：

```bash
export GROK_IMAGE_API_KEY="<Sub2API API key>"
export GROK_IMAGE_BASE_URL="http://127.0.0.1:8080/v1"
export GROK_IMAGE_MODEL="grok-imagine-image-lite"
```

先确认 Key 可以看到 Grok 生图模型：

```bash
curl --fail-with-body -sS \
  -H "Authorization: Bearer ${GROK_IMAGE_API_KEY}" \
  "${GROK_IMAGE_BASE_URL}/models" \
| jq -e '.data[] | select(.id == "grok-imagine-image-lite")'
```

再通过项目脚本生成并下载候选图：

```bash
python3 tools/generate_grok_image.py \
  --prompt-file garden-gpt-image-2/prompt/<prompt>.md \
  --out garden-gpt-image-2/image/candidates/grok/<candidate-name>
```

快速测试也可以直接传 prompt；输出扩展名会按服务实际返回的图片格式调整：

```bash
python3 tools/generate_grok_image.py \
  --prompt "A single white jade mahjong tile body, blank face, no text, studio lighting" \
  --out garden-gpt-image-2/image/candidates/grok/connectivity_test
```

执行规则：

- 2026-07-10 已实测 `http://127.0.0.1:8080/v1/images/generations`：模型 `grok-imagine-image-lite` 返回 HTTP `200`、一条非空图片 URL，完整请求约 15.8 秒。
- `127.0.0.1:8080` 是本机 Sub2API 上下文代理入口；项目调用统一使用该入口，不绕到容器映射端口 `18080`。
- 只从 `GROK_IMAGE_API_KEY` / `GROK_IMAGE_BASE_URL` 读取凭证和网关；不得把真实 Key 写入仓库、prompt、命令示例、日志或受版本控制的 `.env`。
- `tools/generate_grok_image.py` 会附带兼容外部网关的浏览器式请求头；本机 Sub2API 不依赖这些请求头，但保留它们不影响调用。
- 单个上游账号返回 `503` 时，Sub2API 会尝试切换其他账号；只有最终请求返回 `200` 且脚本成功保存可识别图片，才算生成成功。
- 返回可能是 URL、可能是 `b64_json`；实际内容可能是 JPEG 且尺寸可能不等于请求的 `size`，保存时以真实图片头判断扩展名。
- Grok 产物先保存到 `garden-gpt-image-2/image/candidates/grok/` 或更具体候选目录；通过尺寸、文字/水印、风格、安全区和截图验收前，不得覆盖 `assets/illustrations/` 稳定图。
- 透明资产默认不依赖 Grok 原生 alpha；应先生成 chroma-key 或 opaque reference，再用本地清理/切片/归一化工具处理。
- 可玩麻将牌面仍禁止直接 Grok 生完整牌字；只允许生成空白牌坯、材质、mask 或 depth reference，牌面符号继续由 `assets/tiles/*.png` 确定性合成。

## 生成工作流

1. 接收来自 `ui_test_engineer_agent.md` 或 `ui_design_agent.md` 的问题条目，确认是否真的需要位图资产；能用原生 UI 修复的，不发起生图。
2. 为每张资产建立单独 brief，包含 `key`、目标路径、尺寸、透明要求、用途、接入点和安全区。
3. 保存 prompt 到 `garden-gpt-image-2/prompt/`，文件名稳定可追溯。
4. 生成候选图时先保存为候选文件，不直接覆盖 `assets/illustrations/<key>.png`。
5. 验收候选：尺寸、alpha、无文字/水印/假按钮/棋盘格、中心安全区、风格一致。
6. 通过后再复制到稳定路径；旧稳定图备份到 `assets/illustrations/_replaced_<YYYYMMDD>/`。
7. 若新增稳定 key，需要工程 agent 另行登记 `GPT_ILLUSTRATION_ASSET_PATHS` 并跑截图回归。

## 输入

- 视觉需求：界面位置、用途、屏幕尺寸、是否透明、是否可平铺、是否需要 3D 质感。
- 代码/界面锚点：推荐记录到函数或节点名，例如 `draw_center`、`ActionButtonDock`、`GPT_ILLUSTRATION_ASSET_PATHS`。
- 现有参考：已生成 PNG、旧 prompt、截图、`GPT_IMAGE_ASSET_BRIEF*.md` 中的同类条目。
- 限制条件：无文字、无 Logo、无水印、无人脸、无可读随机牌面；中心区域留给 Godot 原生 UI 叠加。

## 输出

- 单张资产 brief：包含 `key`、保存路径、推荐尺寸、透明/不透明要求、用途、接入点、构图、材质、负面约束、最终 prompt。
- 批量资产 brief：按功能区分组，输出清单表和每张图的可复制 prompt。
- prompt 归档文件：保存到 `garden-gpt-image-2/prompt/<asset-key>-<YYYYMMDD-HHMMSS>.md` 或现有稳定文件名。
- 资产交付记录：生成后记录源 prompt、目标 PNG、尺寸、透明度、是否需要接入 `GPT_ILLUSTRATION_ASSET_PATHS`。

## 命名规范

- `key` 使用小写 snake_case，直接对应可选资产字典 key，例如 `table_gpt_backdrop`。
- PNG 文件使用 `assets/illustrations/<key>.png`。
- prompt 文件使用 `garden-gpt-image-2/prompt/<key>.md`；多轮实验使用 `garden-gpt-image-2/prompt/<key>-<YYYYMMDD-HHMMSS>.md`。
- 同一语义的变体使用后缀：
  - 版本：`_v2`、`_v3`，只用于候选图，不作为最终接入 key。
  - 状态：`_active`、`_warning`、`_disabled`。
  - 方向/比例：`_landscape`、`_portrait`、`_strip`、`_icon`。
  - 等级：`_bronze`、`_jade`、`_gold`。
- 已接入或计划接入的稳定 key 不随 prompt 文件时间戳变化。

## Prompt Brief 模板

````markdown
### <编号>. `<key>.png`

- 保存路径：`assets/illustrations/<key>.png`
- Prompt 路径：`garden-gpt-image-2/prompt/<key>-<YYYYMMDD-HHMMSS>.md`
- 推荐尺寸：`1280x720`
- 透明要求：opaque / transparent PNG / transparent-friendly dark ink backing
- 用途：说明叠加在哪个界面或动效层，Godot 原生 UI 会覆盖哪些内容。
- 接入点：函数、节点、字典 key 或待确认。
- 构图：安全区、主体位置、边缘装饰密度、可缩放要求。
- 风格：国风 3D 麻将 UI，深墨绿、温润玉色、黑漆、金箔、少量朱砂。
- 避免：文字、数字、Logo、水印、人物脸部、可读随机牌面、现代科幻 HUD、霓虹、过亮中心。

Prompt:

```text
Create ...
```
````

## 国风 3D UI 素材清单

### 对局桌面核心层

| key | 目标路径 | 尺寸 | 透明 | 需求摘要 |
|---|---|---:|---|---|
| `table_gpt_backdrop` | `assets/illustrations/table_gpt_backdrop.png` | 1280x720 | 否 | 3D 深玉桌面底纹，中心和四边弃牌区低对比。 |
| `hand_gpt_tray` | `assets/illustrations/hand_gpt_tray.png` | 1280x360 | 可透明 | 手牌托盘，顶部留给手牌按钮，下缘锦缎和金线。 |
| `action_gpt_dock` | `assets/illustrations/action_gpt_dock.png` | 1024x256 | 可透明 | 吃碰杠胡操作栏底座，中央按钮区干净。 |
| `top_hud_gpt_banner` | `assets/illustrations/top_hud_gpt_banner.png` | 1280x180 | 可透明 | 顶部 HUD 信息条，左右控制区域低对比。 |
| `seat_gpt_brocade` | `assets/illustrations/seat_gpt_brocade.png` | 768x512 | 可透明 | 四方座位卡底纹，头像、名字、分数区留白。 |
| `center_wind_gpt_compass` | `assets/illustrations/center_wind_gpt_compass.png` | 512x512 | 可透明 | 中央风位罗盘，内圈留给引擎叠风位和状态。 |
| `wall_strip_landscape` | `assets/illustrations/wall_strip_landscape.png` | 1024x128 | 可透明 | 牌墙横向条带，可平铺，强调层叠背牌质感。 |

### 牌面与牌墙

| key | 目标路径 | 尺寸 | 透明 | 需求摘要 |
|---|---|---:|---|---|
| `mahjong_3d_tile_atlas` | `assets/illustrations/mahjong_3d_tile_atlas.png` | 1536x1024 | 是 | 统一 3D 牌面图集，8 列 x 5 行，后续手工切片。 |
| `tile_back_3d_reference` | `assets/illustrations/tile_back_3d_reference.png` | 512x512 | 是 | 温润玉色背牌参考，金线背纹，供背牌或墙牌派生。 |
| `wall_strip_portrait` | `assets/illustrations/wall_strip_portrait.png` | 512x256 | 可透明 | 竖向牌墙条带，与横向条带同材质同光源。 |

### 对局动效与状态

| key | 目标路径 | 尺寸 | 透明 | 需求摘要 |
|---|---|---:|---|---|
| `discard_splash_wash` | `assets/illustrations/discard_splash_wash.png` | 768x768 | 可透明 | 弃牌落点水墨涟漪，64-96 px 缩放仍可读。 |
| `claim_response_trail` | `assets/illustrations/claim_response_trail.png` | 1024x288 | 可透明 | 吃碰杠响应轨道，从弃牌源点到决策门。 |
| `win_result_stage` | `assets/illustrations/win_result_stage.png` | 1280x720 | 否 | 胡牌结算舞台，中央给分数和番型留空。 |
| `win_cover_self_draw` | `assets/illustrations/win_cover_self_draw.png` | 1024x256 | 可透明 | 自摸结局封面，玉青墨晕和金线放射。 |
| `win_cover_deal_in` | `assets/illustrations/win_cover_deal_in.png` | 1024x256 | 可透明 | 点炮结局封面，朱砂和金线封印感。 |
| `win_cover_draw_game` | `assets/illustrations/win_cover_draw_game.png` | 1024x256 | 可透明 | 流局封面，灰墨残卷和低对比留白。 |
| `center_active_bloom` | `assets/illustrations/center_active_bloom.png` | 256x256 | 可透明 | 中央盘活跃态金线绽放。 |
| `fly_transition_flip` | `assets/illustrations/fly_transition_flip.png` | 128x128 | 可透明 | 摸牌飞行中段背面到正面的翻转火花。 |

### 元界面与功能面板

| key | 目标路径 | 尺寸 | 透明 | 需求摘要 |
|---|---|---:|---|---|
| `menu_hero_gpt_backdrop` | `assets/illustrations/menu_hero_gpt_backdrop.png` | 1280x960 | 否 | 主菜单月门庭院背景，下中部留给桌面和按钮。 |
| `loading_scene_gpt_backdrop` | `assets/illustrations/loading_scene_gpt_backdrop.png` | 1280x720 | 否 | 加载页月门、牌墙剪影、远山水面。 |
| `rules_gpt_scroll` | `assets/illustrations/rules_gpt_scroll.png` | 1280x720 | 否 | 规则页卷轴底纹，标题、正文、示例区域干净。 |
| `settings_gpt_panel` | `assets/illustrations/settings_gpt_panel.png` | 1024x768 | 否 | 设置面板罗盘和分区底纹，开关区域低对比。 |
| `shop_gpt_vault` | `assets/illustrations/shop_gpt_vault.png` | 1280x720 | 否 | 商店宝阁和货架底纹，顶部货币和列表区留空。 |
| `online_gpt_lobby` | `assets/illustrations/online_gpt_lobby.png` | 1280x720 | 否 | 联机大厅四席连接与房间同步背景。 |
| `chat_gpt_panel` | `assets/illustrations/chat_gpt_panel.png` | 768x768 | 否 | 聊天消息面板底纹，三条消息区域干净。 |
| `update_gpt_dialog` | `assets/illustrations/update_gpt_dialog.png` | 1024x512 | 否 | 更新下载/校验对话框底纹，进度路径可叠加。 |
| `diagnostic_gpt_panel` | `assets/illustrations/diagnostic_gpt_panel.png` | 1024x512 | 否 | 诊断结果面板，波形和状态区域留给引擎文字。 |

## 质量验收标准

- 路径与命名：prompt、PNG、brief 中的 `key` 完全一致；目标路径在 `assets/illustrations/` 下。
- 尺寸：生成图与推荐尺寸一致，或等比例更高分辨率；不得低于 brief 要求。
- 透明度：标记 transparent 的图片必须有真实 alpha，不能出现灰白棋盘格预览；opaque 背景不能意外透明。
- 安全区：Godot 原生文本、按钮、牌面、头像会覆盖的位置必须低对比、少纹理、无强焦点。
- 风格一致：深墨绿/温润玉色/黑漆/金箔/少量朱砂；3D 材质应有统一光源、倒角、接触阴影和适度高光。
- 内容约束：不得有文字、随机数字、Logo、水印、人物脸部、真实品牌、可读无关牌面、现代科幻线框或霓虹网格。
- 可缩放性：小图标和动效纹理在 64-128 px 预览仍能识别主形；大背景在 1280x720 不抢 UI。
- 接入友好：边缘不裁切，中心锚点资产需要围绕精确中心旋转；可平铺条带左右或上下边界应连续。
- 版本留痕：每张候选图能追溯到 prompt 文件；被淘汰候选不覆盖稳定 key，可保留 `_vN` 文件名。

## 麻将牌面额外规则

- 可玩麻将牌不是普通装饰插画。任何 GPT 牌面候选都必须以当前同名运行时牌图 `assets/tiles/<tile>.png` 作为编辑参考图。
- 当前牌图是权威来源：花色数量、字牌文字、花牌编号、颜色顺序、版面位置不得靠 prompt 臆想。
- 不允许从纯文本 prompt 直接生成可玩牌面；不允许用不相关外部参考替代当前游戏内牌图。
- 生成工具必须走 `tools/generate_gpt_mahjong_tiles.py` 或等价的 GPT edit 流程；导入前逐张核对玩法可读性。

## Prompt 落到 `garden-gpt-image-2/prompt`

1. 先确认是否已有同名稳定 prompt；若只是改写，新增带时间戳文件，不覆盖历史候选。
2. prompt 文件顶部记录元信息：

```markdown
# <key>

- Output path: `assets/illustrations/<key>.png`
- Size: `1280x720`
- Mode: C advisor/offline prompt for GPT Image 2
- Source brief: `qa/agents/gpt_image_agent.md`
```

3. 正文使用可直接复制给 GPT Image 的 `text` 代码块，包含：
   - asset type、尺寸、透明要求；
   - subject、scene/backdrop、style/medium；
   - composition/framing、lighting/mood、color palette；
   - constraints 与 avoid。
4. 批量生成时，每张资产单独一个 prompt 文件；不要把多个最终目标混在一个不可拆分的 prompt 中，除非明确要生成资产 sheet。

## 导入 `assets/illustrations`

1. 生成图片后先保存候选到明确文件名，例如 `assets/illustrations/<key>_v2.png`。
2. 验收通过后再复制或重命名为稳定路径 `assets/illustrations/<key>.png`；不要覆盖用户已经选定的稳定图，除非有明确替换结论。
3. 在 Godot 中导入后确认生成 `.import` 文件；如本轮只交付图片，不手动编辑 `.import`。
4. 若资产已在 `GPT_ILLUSTRATION_ASSET_PATHS` 登记，只需放入稳定路径；缺失时另开代码任务登记 key，本 Agent 只在 brief 中注明。
5. 接入前检查：
   - `file assets/illustrations/<key>.png`
   - `identify assets/illustrations/<key>.png`（如 ImageMagick 可用）
   - 透明资产抽查 alpha，不接受棋盘格烘焙。

## 需求交付清单

- [ ] 需求条目包含 `key`、目标路径、尺寸、透明要求、用途、接入点。
- [ ] prompt 已保存到 `garden-gpt-image-2/prompt/`，且元信息指向目标 PNG。
- [ ] prompt 明确国风 3D 麻将 UI 材质和负面约束。
- [ ] 已记录本轮 GPT Image 模式：A / B / C，以及是否实际生成 PNG。
- [ ] brief 标明 UI 安全区、缩放要求和是否可平铺/旋转。
- [ ] 生成后 PNG 放入 `assets/illustrations/`，候选不覆盖稳定图。
- [ ] 质量验收通过：尺寸、透明、无文字水印、风格一致、中心不抢 UI。
- [ ] 如需代码接入，已另行记录 `GPT_ILLUSTRATION_ASSET_PATHS` key 和目标渲染函数。
- [ ] 交付报告记录 prompt 路径、PNG 路径、验收结果和待办。

## 本 Agent 不做

- 不调用、恢复或重建旧的本地 PIL/程序化生图脚本；这些脚本已从 `scripts/` 删除。
- 不改 `scripts/*.gd`、`*.gd.part`、`project.godot`、导出配置或 APK。
- 不删除、压缩、重采样或覆盖现有二进制图片。
- 不把 prompt 中的临时视觉探索直接认定为最终接入资产。

## 2026-07-05 执行记录

- 本轮使用 `gpt-image-2` Garden 本地 Mode A 生成并接入了截图驱动的三张替换资产：
  - `assets/illustrations/stats_gpt_dashboard.png`
  - `assets/illustrations/achievement_gpt_gallery.png`
  - `assets/illustrations/lobby_room_gate_token.png`
- Prompt 归档：
  - `garden-gpt-image-2/prompt/stats_readability_backplate_gpt-20260705.md`
  - `garden-gpt-image-2/prompt/achievement_gallery_backplate_gpt-20260705.md`
  - `garden-gpt-image-2/prompt/achievement_gallery_backplate_gpt-20260705-v2.md`
  - `garden-gpt-image-2/prompt/lobby_room_gate_token_gpt-20260705.md`
- 被替换的旧稳定 PNG 已备份到 `assets/illustrations/_replaced_20260705/`。
- 临时候选 PNG 已迁移到 `garden-gpt-image-2/image/candidates/`，不要留在 `assets/illustrations/` 根目录，否则离线 smoke 会把它们识别为未登记运行时资产。

## 2026-07-05 商店道具符 v2 Handoff

- 模式检测：`node /root/.codex/skills/gpt-image-2/scripts/check-mode.js --json` 返回 `B-or-C`；`OPENAI_API_KEY` 与本地兼容 `OPENAI_BASE_URL` 存在，但 `ENABLE_GARDEN_IMAGEGEN` 未启用。
- 本轮未生成新 PNG；已保存可直接交给 GPT Image 2 的 prompt handoff：
  - `garden-gpt-image-2/prompt/shop_charm_icon_set_v2-20260705.md`
- 目标：生成 2x2 透明 asset sheet，并裁切成 `shop_charm_huan_v2.png`、`shop_charm_kan_v2.png`、`shop_charm_yun_v2.png`、`shop_charm_bei_v2.png`。
- 接入说明：当前代码已修正 `shop_charm_gpt_key()`，四个现有稳定 charm 资产会分别映射到 `swap_card`、`peek_card`、`lucky_charm`、`double_coins`；v2 通过截图验收后才能覆盖稳定路径。
- 非 GPT 最终美术生成工具已删除：`scripts/generate_flower_tiles.py`、`scripts/generate_illustration_assets.py`、`scripts/generate_mahjong_tiles.py`、`scripts/generate_stage_illustrations.py`、`scripts/import_real_mahjong_tiles.py`。保留的 `tools/generate_gpt_*` / `tools/import_gpt_*` / `tools/normalize_gpt_images.py` 只服务 GPT 生成、导入和归一化。
- `tools/generate_gpt_mahjong_tiles.py` 已收紧为只引用当前 `assets/tiles/*.png` 的 GPT edit 流程，不再接受外部 sheet/flower reference 覆盖。
- 验证结果：
  - `python3 tools/assemble_main.py --verify` passed
  - `GODOT_SILENCE_ROOT_WARNING=1 godot --headless --path . -s scripts/offline_smoke_test.gd` passed
  - `GODOT_SILENCE_ROOT_WARNING=1 godot --headless --path . -s scripts/ui_layout_smoke_test.gd` passed
  - `GODOT_SILENCE_ROOT_WARNING=1 xvfb-run -a godot --path . -s scripts/page_screenshot_capture.gd` captured 10 pages
  - `python3 scripts/ui_screenshot_manifest_check.py` passed

## 2026-07-05 UI designer prompt intake

- 新增 UI 设计师 agent：`qa/agents/ui_design_agent.md`。
- 页面级生图 prompt brief：`GPT_IMAGE_UI_DESIGN_PROMPTS.md`。
- Prompt 目录索引：`garden-gpt-image-2/prompt/guofeng-3d-ui-page-prompts-20260705.md`。
- 该 brief 覆盖主菜单、菜单卡片、设置、离线对局、规则、统计、成就、商店、联机大厅、每日签到、加载页和通用 3D 控件套件。
- 执行优先级：先生成 `menu_card_frame_kit` / `guofeng_3d_control_kit`，用于替换首页和表单内剩余程序点线控件；再生成 `online_gpt_lobby_v3` 和 `table_gpt_backdrop_v4`。
  - `python3 tools/generate_gpt_mahjong_tiles.py --list` shows all 43 tile outputs bound to matching current `assets/tiles/*.png` references.

## 2026-07-05 GPT-only cleanup follow-up

- `ILLUSTRATION_ASSET_PATHS` 已清空，旧强制非 GPT 插画注册表不再加载。
- `assets/illustrations/` 根目录已清理为 GPT 注册资产集合：87 个 `GPT_ILLUSTRATION_ASSET_PATHS` PNG 全部存在，根目录未登记 PNG 为 0。
- 已补齐新稳定 GPT 资产的 `.import` sidecar；QA 截图和 `garden-gpt-image-2` 候选目录的导入副产物已删除。
- 主菜单已移除旧程序绘制装饰层：月亮、印章、云团、竹梅、锦鲤、风轨、金粉、赛季进度点线、每日任务点线。首页现在由 `menu_lobby_gpt_scene`、`menu_lobby_ui_overlay` 和原生按钮/文字构成。
- 新生成并接入 `online_gpt_lobby` commercial v2；旧稳定图备份到 `assets/illustrations/_replaced_20260705/online_gpt_lobby.before_commercial_v2.png`。
- 最新验证：
  - `python3 tools/assemble_main.py --verify` passed
  - `GODOT_SILENCE_ROOT_WARNING=1 godot --headless --path . -s scripts/ui_layout_smoke_test.gd` passed
  - `GODOT_SILENCE_ROOT_WARNING=1 godot --headless --path . -s scripts/offline_smoke_test.gd` passed with existing headless lambda cleanup noise
  - `GODOT_SILENCE_ROOT_WARNING=1 xvfb-run -a godot --path . -s scripts/page_screenshot_capture.gd` captured 10 pages
  - `python3 scripts/ui_screenshot_manifest_check.py` passed

## 2026-07-06 blank mahjong tile body exploration

- 任务：探索替代当前偏重金边 3D 牌体的 AI 生图方案；只设计空白牌体、材质和光影，禁止生成任何牌面符号。后续牌面图案仍由主线程用 `assets/tiles/*.png` 确定性叠加。
- 模式检测：`node /root/.codex/skills/gpt-image-2/scripts/check-mode.js --json` 返回 `B-or-C`；`OPENAI_API_KEY` 与本地兼容 `OPENAI_BASE_URL` 存在，但 `ENABLE_GARDEN_IMAGEGEN` 未启用。当前宿主无可调用内置 image generation tool，因此本轮按 Mode C 只交付 prompt，未生成 PNG。
- 参考检查：现有 `assets/tiles_3d/_tile_face_3d_body.png` 为 200x280 RGBA，视觉上有较明显金色边框；本轮 prompt 明确禁止金属边框、内框和任何符号，并保留 74-76% 以上中心空白叠加区。
- Prompt 候选：
  - `garden-gpt-image-2/prompt/blank_tile_body_jade_flat_v6-20260706-200310.md`：推荐默认候选，温润象牙/白玉正面、轻微厚度、绿幕背景，最适合后续 alpha cutout 和确定性叠牌面。
  - `garden-gpt-image-2/prompt/blank_tile_body_ink_green_side_v1-20260706-200310.md`：薄墨绿侧边候选，能增强 3D 体积，但需验收侧边不要变成视觉边框。
  - `garden-gpt-image-2/prompt/blank_tile_body_wood_shadow_v1-20260706-200310.md`：国风木质暖反光候选，适合暗色桌面氛围，但背景为纯暖白，若要透明需后处理或重新改成 chroma key。
- 推荐生成规格：`1024x1440`，再裁切/归一化到项目当前 200x280 tile sprite；生成候选先放 `garden-gpt-image-2/image/candidates/`，验收通过后再替换 `assets/tiles_3d/_tile_face_3d_body.png`。
- 验收重点：透明或可干净抠图、中心叠加安全区平整、无随机符号、无金边、无厚重透视、下采样到 200x280 后倒角仍清晰。

## 2026-07-05 P0/P1 prompt split handoff

- 模式检测：`node /root/.codex/skills/gpt-image-2/scripts/check-mode.js --json` 返回 `B-or-C`；当前 shell 未启用 `ENABLE_GARDEN_IMAGEGEN`，因此本轮只交付独立 prompt 文件，没有生成 PNG。
- 完整生产需求：`GPT_IMAGE_AGENT_EXECUTION_BRIEF.md`。
- 入口 prompt：`garden-gpt-image-2/prompt/mahjong-guofeng-image-requirements-20260705.md`。
- 执行 manifest：`garden-gpt-image-2/prompt/p0_p1_prompt_manifest_20260705.md`。
- P0 人机对战 prompt：
  - `garden-gpt-image-2/prompt/p0_table_gpt_backdrop_v4.md`
  - `garden-gpt-image-2/prompt/p0_mahjong_tile_3d_edit_template.md`
  - `garden-gpt-image-2/prompt/p0_wall_strip_landscape_v2.md`
  - `garden-gpt-image-2/prompt/p0_tile_back_3d.md`
  - `garden-gpt-image-2/prompt/p0_wall_live_feedback_kit_v1.md`
  - `garden-gpt-image-2/prompt/p0_hand_gpt_tray_v4.md`
  - `garden-gpt-image-2/prompt/p0_action_gpt_dock_v5.md`
  - `garden-gpt-image-2/prompt/p0_seat_gpt_brocade_v4.md`
  - `garden-gpt-image-2/prompt/p0_pending_claim_status_strip.md`
- P1 联机大厅 prompt：
  - `garden-gpt-image-2/prompt/p1_online_gpt_lobby_v3.md`
  - `garden-gpt-image-2/prompt/p1_online_lobby_panel_kit.md`
  - `garden-gpt-image-2/prompt/p1_online_feedback_gpt_strip_v2.md`
- 执行要求：每个 prompt 至少生成 3 个候选，候选先放 `garden-gpt-image-2/image/candidates/`；禁止直接覆盖 `assets/illustrations/` 稳定路径；牌面编辑必须使用同名 `assets/tiles/*.png` 作为原图。

## 2026-07-06 P0 missing-candidate generation

- Mode check:
  - Default shell: `B-or-C`, `OPENAI_API_KEY` present, `OPENAI_BASE_URL=http://127.0.0.1:8080/v1`, `ENABLE_GARDEN_IMAGEGEN` unset.
  - Explicit Garden: `ENABLE_GARDEN_IMAGEGEN=1 node /root/.codex/skills/gpt-image-2/scripts/check-mode.js --json` returned `Mode A`.
- Filesystem pending check:
  - Already present before this run: `table_gpt_backdrop_v4`, `wall_strip_landscape_v2`, `tile_back_3d`, `hand_gpt_tray_v4`, latest `action_gpt_dock_v6` candidates/stable files.
  - Missing before this run: `wall_live_feedback_kit_v1`, `seat_gpt_brocade_v4`, `pending_claim_status_strip` candidate PNGs.
  - Tile edit batch: `assets/tiles_3d/` already contains first-batch 200x280 RGBA tile outputs (`tile_man1-9`, `tile_pin1-9`, `tile_sou1-9`) plus honors/flowers and `_tile_face_3d_body.png`; no new tile edit generation was run.
- Commands attempted:
  - `ENABLE_GARDEN_IMAGEGEN=1 node /root/.codex/skills/gpt-image-2/scripts/generate.js --promptfile garden-gpt-image-2/prompt/p0_wall_live_feedback_kit_v1.md --image garden-gpt-image-2/image/candidates/p0/wall_live_feedback_kit_v1_candidate_01.png --size 1536x512 --quality high --background transparent --output-format png --json`
  - `ENABLE_GARDEN_IMAGEGEN=1 node /root/.codex/skills/gpt-image-2/scripts/generate.js --promptfile garden-gpt-image-2/prompt/p0_seat_gpt_brocade_v4.md --image garden-gpt-image-2/image/candidates/p0/seat_gpt_brocade_v4_candidate_01.png --size 768x384 --quality high --background transparent --output-format png`
  - `ENABLE_GARDEN_IMAGEGEN=1 node /root/.codex/skills/gpt-image-2/scripts/generate.js --promptfile garden-gpt-image-2/prompt/p0_pending_claim_status_strip.md --image garden-gpt-image-2/image/candidates/p0/pending_claim_status_strip_candidate_01.png --size 768x120 --quality high --background transparent --output-format png`
- Prompt copies written by the skill script:
  - `garden-gpt-image-2/prompt/p0-wall-live-feedback-kit-v1-output-path-assets-20260706-042148.md`
  - `garden-gpt-image-2/prompt/p0-seat-gpt-brocade-v4-output-path-assets-illust-20260706-042237.md`
  - `garden-gpt-image-2/prompt/p0-pending-claim-status-strip-output-path-assets-20260706-042309.md`
- Generated raw candidates:
  - `garden-gpt-image-2/image/candidates/p0/wall_live_feedback_kit_v1_candidate_01.png` -> raw gateway output `2172x724 RGB`; gateway ignored requested alpha/size and baked a checkerboard preview.
  - `garden-gpt-image-2/image/candidates/p0/seat_gpt_brocade_v4_candidate_01.png` -> raw gateway output `1774x887 RGB`; gateway ignored requested alpha/size and baked a checkerboard preview.
  - `garden-gpt-image-2/image/candidates/p0/pending_claim_status_strip_candidate_01.png` -> raw gateway output `1774x887 RGB`; gateway ignored requested alpha/size and baked a checkerboard preview.
- Cleaned candidate derivatives:
  - `garden-gpt-image-2/image/candidates/p0/wall_live_feedback_kit_v1_candidate_01_clean.png` -> `1536x512 RGBA`, alpha `(0,255)`, `336224/786432` fully transparent pixels, `51933` partial-alpha pixels.
  - `garden-gpt-image-2/image/candidates/p0/seat_gpt_brocade_v4_candidate_01_clean.png` -> `768x384 RGBA`, alpha `(0,255)`, `186500/294912` fully transparent pixels, `12850` partial-alpha pixels.
  - `garden-gpt-image-2/image/candidates/p0/pending_claim_status_strip_candidate_01_clean.png` -> `768x120 RGBA`, alpha `(0,255)`, `37178/92160` fully transparent pixels, `6780` partial-alpha pixels.
- Verification:
  - Used `file` for PNG dimensions/color mode and Pillow read-only alpha histogram checks because ImageMagick `identify` is not installed.
  - Existing spot checks confirmed `hand_gpt_tray_v4_candidate_01_clean.png` (`1280x260 RGBA`), `action_gpt_dock_v6_candidate_01_clean_v7.png` (`1024x220 RGBA`), `wall_strip_landscape_v2_candidate_02_empty_base_clean_v2.png` (`1024x160 RGBA`), `tile_back_3d_candidate_01_clean_v2.png` (`200x280 RGBA`), and `table_gpt_backdrop_v4_candidate_01.png` (`1672x941 RGB` opaque).
- QA notes:
  - `seat_gpt_brocade_v4_candidate_01_clean.png` and `pending_claim_status_strip_candidate_01_clean.png` are usable first candidates but still require screenshot review before promotion.
  - `wall_live_feedback_kit_v1_candidate_01_clean.png` is structurally close to the brief but has visible light edge residue from baked checkerboard cleanup; treat as a candidate needing manual review or a second generation pass.
  - No files under `assets/illustrations/`, `assets/tiles/`, Godot scripts, or registries were modified by this run.

## 2026-07-06 P0 wall live feedback kit v2 integration

- The GPT image worker was reused for a focused `wall_live_feedback_kit` v2 task after the v1 asset sheet failed edge cleanup review.
- Prompts:
  - `garden-gpt-image-2/prompt/p0_wall_live_feedback_kit_v2_chroma_no_edge-20260706.md`
  - `garden-gpt-image-2/prompt/p0_wall_live_feedback_kit_v2_candidate_02_chroma_no_lines-20260706.md`
- Rejected:
  - `garden-gpt-image-2/image/candidates/p0/wall_live_feedback_kit_v2_candidate_01_clean.png` because alpha/visual scan found long horizontal residue between rail rows.
- Accepted:
  - `garden-gpt-image-2/image/candidates/p0/wall_live_feedback_kit_v2_candidate_02_clean.png`
  - Promoted to `assets/illustrations/wall_live_feedback_kit.png`.
- Validation:
  - Stable asset is `1536x512 RGBA`, alpha `(0,255)`, transparent corners.
  - Candidate report: `garden-gpt-image-2/image/candidates/p0/wall_live_feedback_kit_v2_candidate_02_report.md`.
  - Godot `.import` sidecar exists for the stable asset; candidate and QA screenshot `.import` sidecars were removed.
- Integration:
  - Registered `wall_live_feedback_kit` in `GPT_ILLUSTRATION_ASSET_PATHS`.
  - Runtime slices the sheet with `AtlasTexture` for `WallLiveFeedbackBadgeFrameTexture`, `WallLiveFeedbackRailTexture`, `WallLiveFeedbackPulseTexture`, `WallLiveFeedbackCornerLeftTexture`, and `WallLiveFeedbackCornerRightTexture`.
  - Native live count, state, delta, and exact progress fill remain engine-rendered; the GPT sheet is decorative only and has native fallback.
- Verification:
  - `python3 tools/assemble_main.py --verify` passed.
  - `git diff --check` passed.
  - `GODOT_SILENCE_ROOT_WARNING=1 godot --headless --path . -s scripts/offline_smoke_test.gd` passed with known headless cleanup noise.
  - `GODOT_SILENCE_ROOT_WARNING=1 godot --headless --path . -s scripts/ui_layout_smoke_test.gd` passed.
  - `03_offline_battle.png` refreshed at `1280x720` and `960x540`; both screenshot manifests passed.

## 2026-07-06 overlay gap image execution

- User request: first check whether any GPT image generation is still needed, and send execution to the image agent when needed.
- Subagent status: two delegated image-agent attempts errored because of temporary high demand, so the main agent executed the bounded image task locally under this agent's rules.
- Mode check:
  - Default shell: `B-or-C`, `OPENAI_API_KEY` present, `OPENAI_BASE_URL=http://127.0.0.1:8080/v1`, `ENABLE_GARDEN_IMAGEGEN` unset.
  - Explicit Garden: `ENABLE_GARDEN_IMAGEGEN=1 node /root/.codex/skills/gpt-image-2/scripts/check-mode.js --json` returned `Mode A`.
- Demand audit:
  - Latest screenshots do not require new rule-page art; `rules_gpt_scroll`, `rules_guide_panel`, `rules_reading_progress_panel`, and `rules_pattern_quads` already exist and are consumed.
  - P1 online-lobby panel demand is already split and integrated as `online_lobby_panel_frame_v1`, `online_lobby_group_plate_v1`, and `online_feedback_gpt_strip_v2`.
  - Two registered optional overlays still had no stable PNG: `menu_primary_3d_stage_overlay` and `offline_table_3d_overlay`. Historical GPT outputs existed, but they were fully opaque and failed the transparent-overlay requirement.
- New prompts saved:
  - `garden-gpt-image-2/prompt/menu_primary_3d_stage_overlay_chroma_v2-20260706.md`
  - `garden-gpt-image-2/prompt/offline_table_3d_overlay_chroma_v2-20260706.md`
- Generated candidates:
  - `garden-gpt-image-2/image/candidates/menu/menu_primary_3d_stage_overlay_chroma_v2_candidate_01.png`
  - `garden-gpt-image-2/image/candidates/p0/offline_table_3d_overlay_chroma_v2_candidate_01.png`
- Cleaned true-alpha candidates:
  - `garden-gpt-image-2/image/candidates/menu/menu_primary_3d_stage_overlay_chroma_v2_candidate_01_clean.png` -> `1280x720 RGBA`, alpha `(0,255)`, transparent corners and edge alpha max `0`; accepted as a candidate for screenshot testing before promotion.
  - `garden-gpt-image-2/image/candidates/p0/offline_table_3d_overlay_chroma_v2_candidate_01_clean.png` -> `1280x720 RGBA`, alpha `(0,255)`, transparent corners and edge alpha max `0`; held as a technical candidate because it reads as a full table surface rather than a light overlay.
- Candidate reports:
  - `garden-gpt-image-2/image/candidates/menu/menu_primary_3d_stage_overlay_chroma_v2_candidate_01_report.md`
  - `garden-gpt-image-2/image/candidates/p0/offline_table_3d_overlay_chroma_v2_candidate_01_report.md`
- Stable assets and Godot code were not modified in this pass. Next handoff: promote only the menu overlay first, then run menu screenshots at `1280x720` and `960x540`; regenerate the offline overlay with a stricter rim/contact-shadow-only brief unless a low-alpha screenshot test proves the current candidate is unobtrusive.

## 2026-07-06 menu primary 3D stage overlay promotion

- Promoted accepted candidate:
  - From: `garden-gpt-image-2/image/candidates/menu/menu_primary_3d_stage_overlay_chroma_v2_candidate_01_clean.png`
  - To: `assets/illustrations/menu_primary_3d_stage_overlay.png`
- Godot import sidecar:
  - `assets/illustrations/menu_primary_3d_stage_overlay.png.import`
- Runtime registration already existed in `GPT_ILLUSTRATION_ASSET_PATHS`; no Godot script changes were needed.
- Screenshot review:
  - `build/qa/pages/01_menu.png`
  - `build/qa/pages_960x540/01_menu.png`
  - The stage overlay renders behind the three primary menu cards, grounds the cards with black-lacquer/jade/gold 3D depth, and does not cover the title plaque, quick actions, footer, or settings button.
- Verification passed:
  - `python3 tools/assemble_main.py --verify`
  - `git diff --check`
  - `GODOT_SILENCE_ROOT_WARNING=1 godot --headless --path . -s scripts/ui_layout_smoke_test.gd`
  - `GODOT_SILENCE_ROOT_WARNING=1 godot --headless --path . -s scripts/offline_smoke_test.gd`
  - `GODOT_SILENCE_ROOT_WARNING=1 xvfb-run -a godot --path . -s scripts/page_screenshot_capture.gd`
  - `GODOT_SILENCE_ROOT_WARNING=1 xvfb-run -a godot --path . -s scripts/page_screenshot_capture.gd -- --size=960x540`
  - `python3 scripts/ui_screenshot_manifest_check.py`
  - `python3 scripts/ui_screenshot_manifest_check.py --pages-dir build/qa/pages_960x540 --report build/qa/ui_screenshot_manifest_report_960x540.md --expected-size 960x540`
- Candidate/QA `.import` sidecars generated by editor import were removed again; the stable asset sidecar under `assets/illustrations/` remains.
- Superseded handoff: `offline_table_3d_overlay` was regenerated as a rim/contact-shadow-only v3 overlay and promoted in the follow-up pass below.

## 2026-07-06 offline table 3D overlay rim-shadow v3 promotion

- Prompt:
  - `garden-gpt-image-2/prompt/offline_table_3d_overlay_rim_shadow_v3-20260706.md`
- Rejected prior candidate:
  - `garden-gpt-image-2/image/candidates/p0/offline_table_3d_overlay_chroma_v2_candidate_01_clean.png` remained technically valid alpha but read as a full table surface, so it was not promoted.
- Accepted candidate:
  - Raw: `garden-gpt-image-2/image/candidates/p0/offline_table_3d_overlay_rim_shadow_v3_candidate_01.png` (`1672x941 RGB`, chroma-key source).
  - Clean: `garden-gpt-image-2/image/candidates/p0/offline_table_3d_overlay_rim_shadow_v3_candidate_01_clean.png` (`1280x720 RGBA`, alpha `(0,255)`, sparse rim/contact-shadow overlay).
  - Candidate report: `garden-gpt-image-2/image/candidates/p0/offline_table_3d_overlay_rim_shadow_v3_candidate_01_report.md`.
- Promotion:
  - From: `garden-gpt-image-2/image/candidates/p0/offline_table_3d_overlay_rim_shadow_v3_candidate_01_clean.png`
  - To: `assets/illustrations/offline_table_3d_overlay.png`
  - Godot sidecar: `assets/illustrations/offline_table_3d_overlay.png.import`
- Runtime registration already existed in `GPT_ILLUSTRATION_ASSET_PATHS`; no Godot registry or render-code change was needed. The asset is consumed by `OfflineTable3DOverlayTexture` in `render_game()`.
- Screenshot review:
  - `build/qa/pages/03_offline_battle.png`
  - `build/qa/pages_960x540/03_offline_battle.png`
  - The v3 overlay adds edge/corner depth while leaving the discard river, tile walls, hand tray, pending dock, seat text, and HUD readable.
- Current image-demand audit:
  - `GPT_ILLUSTRATION_ASSET_PATHS` registered assets: 95.
  - Missing registered files: 0.
  - Remaining mandatory image-generation handoff: none.
- Verification passed:
  - `python3 tools/assemble_main.py --verify`
  - `git diff --check`
  - `GODOT_SILENCE_ROOT_WARNING=1 godot --headless --path . -s scripts/ui_layout_smoke_test.gd`
  - `python3 scripts/ui_screenshot_manifest_check.py`
  - `python3 scripts/ui_screenshot_manifest_check.py --pages-dir build/qa/pages_960x540 --report build/qa/ui_screenshot_manifest_report_960x540.md --expected-size 960x540`
  - Candidate/QA `.import` sidecars were removed again; stable sidecars under `assets/illustrations/` remain.

## 2026-07-06 image-demand re-audit after shop readability pass

- User request: prioritize checking whether any image generation is needed before continuing UI polish.
- Mode check: `node /root/.codex/skills/gpt-image-2/scripts/check-mode.js --json` returned `B-or-C`; Garden is not enabled in the default shell, though API key/base URL are present.
- Runtime asset audit:
  - `GPT_ILLUSTRATION_ASSET_PATHS` registered assets: 95.
  - Missing registered files: 0.
  - Candidate/QA `.import` sidecars: 0.
  - Key follow-up assets are stable RGBA PNGs: `menu_primary_3d_stage_overlay.png`, `offline_table_3d_overlay.png`, and the four `shop_charm_*.png` v2 crops.
- Decision: no image-generation task was dispatched. The remaining shop issue was native UI readability, fixed by brighter labels, a local text backplate, lower row-decoration alpha, and layout smoke assertions.

## 2026-07-06 settings safe-label audit

- Follow-up issue checked: `02_menu_settings.png` long button labels touching ornamental borders.
- Decision: no GPT image-generation task was needed. The issue was caused by native button text, row height, and button anchoring, not by missing bitmap assets.
- Native fix recorded in UI QA: toggle buttons use compact `切换` labels, reset uses `重置`/`清空`, setting rows are taller, and smoke tests now forbid the old long labels.

## 2026-07-06 rules-page image-demand audit

- User request: prioritize checking whether any image generation is needed before continuing UI polish, and dispatch to the image agent only when there is a real bitmap gap.
- Mode check: `node /root/.codex/skills/gpt-image-2/scripts/check-mode.js --json` returned `B-or-C`; Garden generation is not enabled in the default shell.
- Runtime audit:
  - `GPT_ILLUSTRATION_ASSET_PATHS` registered assets: 95.
  - Missing registered PNG files: 0.
  - Candidate/QA `.import` sidecars: 0.
  - Rule-page GPT assets already exist and are consumed: `rules_gpt_scroll`, `rules_guide_panel`, `rules_reading_progress_panel`, and `rules_pattern_quads`.
- Screenshot review: `04_rules.png` is darker than the strongest pages, but the gap is local text/example-lane contrast, not a missing illustration.
- Decision: no image-generation task was dispatched. Continue with native rules-page readability work: brighter text, local backplates, and smoke assertions for clipping, contrast, and non-overlap.

## 2026-07-06 pending-claim action-dock image-demand audit

- User request: prioritize checking whether any image generation is needed and dispatch to the image agent only if there is a real bitmap gap.
- Mode check: `node /root/.codex/skills/gpt-image-2/scripts/check-mode.js --json` returned `B-or-C`; Garden generation is not enabled in the default shell.
- Runtime audit:
  - `GPT_ILLUSTRATION_ASSET_PATHS` registered assets: 95.
  - Missing registered PNG files: 0.
  - Candidate/QA `.import` sidecars: 0.
  - Pending-claim action assets already exist and are consumed: `pending_claim_action_dock` and `pending_claim_status_strip`.
- Screenshot review: `03_offline_battle.png` still benefited from action-area polish, but the issue was dock/button weight and spacing against the hand tray, not a missing or failed bitmap asset.
- Decision: no image-generation task was dispatched. The follow-up was handled as native UI polish by moving the pending-claim action layout upward, lowering dock/button overlay alpha, and adding smoke assertions for spacing and alpha caps.

## 2026-07-06 online-lobby roster/log image-demand audit

- User request: keep checking for image-generation needs before UI polish and dispatch only for a real bitmap gap.
- Mode check: `node /root/.codex/skills/gpt-image-2/scripts/check-mode.js --json` returned `B-or-C`; Garden generation is not enabled in the default shell.
- Runtime audit:
  - `GPT_ILLUSTRATION_ASSET_PATHS` registered assets: 95.
  - Missing registered PNG files: 0.
  - Candidate/QA `.import` sidecars: 0.
  - Online-lobby GPT assets already exist and are consumed: `online_gpt_lobby`, `online_lobby_panel_frame`, `online_lobby_group_plate`, and `online_feedback_gpt_strip`.
- Screenshot review: `08_online_lobby.png` benefited from right-panel readability polish, but the issue was native roster/log text hierarchy, row height, and label contrast, not missing panel art.
- Decision: no image-generation task was dispatched. The follow-up was handled as native UI polish by enlarging roster rows, brightening name/state/log labels, and adding smoke assertions for row height, font size, luma, and clipping.

## 2026-07-06 stats-page image-demand audit

- User request: continue prioritizing image-generation checks before native UI polish and dispatch only for a real bitmap gap.
- Mode check: `node /root/.codex/skills/gpt-image-2/scripts/check-mode.js --json` returned `B-or-C`; Garden generation is not enabled in the default shell.
- Runtime audit:
  - `GPT_ILLUSTRATION_ASSET_PATHS` registered assets: 95.
  - Missing registered PNG files: 0.
  - Candidate/QA `.import` sidecars: 0.
  - Stats-page GPT assets already exist and are consumed: `stats_gpt_dashboard` and `stats_winrate_scroll`.
- Screenshot review: `05_stats.png` and `pages_960x540/05_stats.png` benefited from responsive row fitting and native summary chip readability, but the issue was row height/content overflow and local text hierarchy, not missing dashboard art.
- Decision: no image-generation task was dispatched. The follow-up was handled as native UI polish by fitting all six stats rows into the 960x540 content lane, adding local summary chips, and adding smoke assertions for row bounds, value backplates, text luma, and clipping.

## 2026-07-06 menu-footer image-demand audit

- User request: check image-generation needs first and dispatch to the image agent only when a real bitmap gap exists.
- Mode check: `node /root/.codex/skills/gpt-image-2/scripts/check-mode.js --json` returned `B-or-C`; Garden generation is not enabled in the default shell.
- Runtime audit:
  - `GPT_ILLUSTRATION_ASSET_PATHS` registered assets: 95.
  - Missing registered PNG files: 0.
  - Candidate/QA `.import` sidecars: 0.
- Screenshot review: `01_menu.png` and `pages_960x540/01_menu.png` had a weak, scattered footer status strip, but no broken/missing PNG, failed alpha, or new art requirement.
- Decision: no GPT image-generation task was dispatched. The issue was native status-chip hierarchy, label length, backplate contrast, and settings-button anchoring.

## 2026-07-06 settings-row/button image-demand audit

- User request: keep checking image-generation needs first and dispatch only for a real bitmap gap.
- Mode check: `node /root/.codex/skills/gpt-image-2/scripts/check-mode.js --json` returned `B-or-C`; Garden generation is not enabled in the default shell.
- Runtime audit:
  - `GPT_ILLUSTRATION_ASSET_PATHS` registered assets: 95.
  - Missing registered PNG files: 0.
  - Candidate/QA `.import` sidecars: 0.
- Read-only subagent audit agreed there was no mandatory bitmap gap. The apparent blank tile in QA imagery is the real `tile_honor_white` white dragon tile, not a missing generated asset.
- Screenshot review: `02_menu_settings.png` and `pages_960x540/02_menu_settings.png` needed native row readability and button-decoration cleanup. The issue was text backplates, status wording, and route/tick art crossing `试听` / `切歌`, not missing PNG art.
- Decision: no GPT image-generation task was dispatched. The follow-up was handled in Godot UI code by adding local setting-row text panels, shortening status strings, lowering settings panel overlay alpha, and moving audio/BGM button decoration out of the text safe zone.

## 2026-07-06 daily-login image-demand audit

- User request: check image-generation needs before native UI work and dispatch only for a real bitmap/PNG gap.
- Mode check: `node /root/.codex/skills/gpt-image-2/scripts/check-mode.js --json` returned `B-or-C`; Garden generation is not enabled in the default shell.
- Runtime audit:
  - `GPT_ILLUSTRATION_ASSET_PATHS` registered assets: 95.
  - Missing registered PNG files: 0.
  - Candidate `.import` sidecars under `build/qa` and `.tmp`: 0.
  - Daily-login GPT asset already exists and is consumed: `daily_login_gpt_calendar`.
- Screenshot review: `09_daily_login.png` and `pages_960x540/09_daily_login.png` needed stronger native day/reward/tip readability, but no missing, broken, or low-fidelity PNG asset was found.
- Decision: no image-generation task was dispatched. The follow-up was handled in Godot UI code by adding local text backplates, named reward/progress/tip controls, brighter clipped labels, and small-viewport spacing fixes.

## 2026-07-06 offline-battle HUD/seat image-demand audit

- User request: keep checking image-generation needs before UI work and dispatch only for a real bitmap/PNG gap.
- Mode check: `node /root/.codex/skills/gpt-image-2/scripts/check-mode.js --json` returned `B-or-C`; Garden generation is not enabled in the default shell.
- Runtime audit:
  - `GPT_ILLUSTRATION_ASSET_PATHS` registered assets: 95.
  - Missing registered PNG files: 0.
  - Candidate `.import` sidecars under `build/qa` and `.tmp`: 0.
  - Offline-battle assets already exist and are consumed: `table_gpt_backdrop`, `offline_table_3d_overlay`, `top_hud_gpt_banner`, `seat_gpt_brocade`, `pending_claim_action_dock`, `pending_claim_status_strip`, and `hand_gpt_tray`.
- Screenshot review: `03_offline_battle.png` and `pages_960x540/03_offline_battle.png` needed native HUD/seat information hierarchy cleanup, not new PNG art.
- Decision: no image-generation task was dispatched. The follow-up was handled in Godot UI code by adding local HUD title/status/wall backplates, widening the offline wall badge, adding seat text backplates, and tightening compact seat label geometry.

## 2026-07-06 settings modal density image-demand audit

- User request: continue checking image-generation needs first and dispatch only for a real bitmap/PNG gap.
- Mode check: `node /root/.codex/skills/gpt-image-2/scripts/check-mode.js --json` returned `B-or-C`; Garden generation is not enabled in the default shell.
- Runtime audit:
  - `GPT_ILLUSTRATION_ASSET_PATHS` registered assets: 95.
  - Missing registered PNG files: 0.
  - Candidate `.import` sidecars under `build/qa` and `.tmp`: 0.
- Read-only UI/image audit found no missing or broken generated PNG. The loading page has visible background banding, but it is an art artifact, not a failed PNG load.
- Screenshot review: `pages_960x540/02_menu_settings.png` needed native modal density, row rhythm, button safe-zone, and maintenance-row separation work. Existing settings GPT panel art already exists; no replacement PNG was required.
- Decision: no image-generation task was dispatched. The follow-up was handled in Godot UI code by widening/tallening the modal, increasing section row rhythm, reducing panel-art alpha, and moving reset-button warning art out of the text lane.

## 2026-07-06 achievements dashboard image-demand audit

- User request: continue checking image-generation needs first and dispatch only for a real bitmap/PNG gap.
- Mode check: `node /root/.codex/skills/gpt-image-2/scripts/check-mode.js --json` returned `B-or-C`; Garden generation is not enabled in the default shell.
- Runtime audit:
  - `GPT_ILLUSTRATION_ASSET_PATHS` registered assets: 95.
  - Missing registered PNG files: 0.
  - Candidate `.import` sidecars under `build/qa`, `.tmp`, and `garden-gpt-image-2/image/candidates`: 0.
  - Achievement page already consumes `achievement_gpt_gallery`; no broken alpha, missing asset, baked placeholder, or new bitmap requirement was found.
- Screenshot review: `06_achievements.png` and `pages_960x540/06_achievements.png` had a dark top dashboard award outline and missing visible progress-route structure caused by native dashboard rendering, not by failed generated art.
- Decision: no image-generation task was dispatched. The follow-up was handled in Godot UI code by restoring the achievement dashboard progress rail/fill/gate, replacing the dark award outline with a bright native `奖` glyph, and adding smoke assertions for the top dashboard labels and glyph.

## 2026-07-06 loading-page image-demand audit

- User request: keep checking image-generation needs first and dispatch only for a real bitmap/PNG gap.
- Mode check: `node /root/.codex/skills/gpt-image-2/scripts/check-mode.js --json` returned `B-or-C`; Garden generation is not enabled in the default shell.
- Runtime audit:
  - `GPT_ILLUSTRATION_ASSET_PATHS` registered assets: 95.
  - Missing registered PNG files: 0.
  - Candidate/QA `.import` sidecars under `build/qa`, `.tmp`, and `garden-gpt-image-2/image/candidates`: 0.
  - Loading page already consumes `loading_scene_gpt_backdrop`; no missing, broken, placeholder, fake-alpha, or watermark PNG issue was found.
- Screenshot review: `10_loading.png` and `pages_960x540/10_loading.png` needed native progress/tip layer ordering and brightness cleanup. The issue was dormant/overlapping Godot route art, not a new generated image requirement.
- Decision: no GPT image-generation task was dispatched. The follow-up was handled in Godot UI code by enabling existing progress/tip route nodes, lowering their alpha, putting text above them, and adding layout smoke coverage.

## 2026-07-06 offline-battle compact seat and tile strategy audit

- User request: prioritize the single-player battle page, compact AI info, and replace the ugly generated 3D tile approach.
- Mode check: `node /root/.codex/skills/gpt-image-2/scripts/check-mode.js --json` returned `B-or-C`; Garden generation is not enabled in the default shell.
- Runtime audit:
  - `GPT_ILLUSTRATION_ASSET_PATHS` registered assets: 95.
  - Missing registered PNG files: 0.
  - Offline-battle layout assets already exist and are consumed; no missing table, seat, HUD, action, wall, or hand-tray bitmap was found.
- Screenshot review: `03_offline_battle.png` and `pages_960x540/03_offline_battle.png` needed native compact-seat geometry and a tile-rendering strategy change, not a new battle-page PNG.
- Decision: no GPT image-generation task was dispatched. Playable tile faces now prefer the authoritative `assets/tiles/*.png` sprites and use Godot-native depth/shadow/highlight layers; `assets/tiles_3d/*.png` is only a fallback for missing base sprites.

## 2026-07-06 online-lobby right-panel image-demand audit

- User request context: continue screenshot-led UI polish and check image-generation needs before native work.
- Mode check: `node /root/.codex/skills/gpt-image-2/scripts/check-mode.js --json` returned `B-or-C`; Garden generation is not enabled in the default shell.
- Runtime audit:
  - `GPT_ILLUSTRATION_ASSET_PATHS` registered assets: 95.
  - Missing registered PNG files: 0.
  - Online-lobby assets already exist and are consumed: `online_gpt_lobby`, `online_lobby_panel_frame`, `online_lobby_group_plate`, `online_feedback_gpt_strip`, and `lobby_room_gate_token`.
- Screenshot review: `08_online_lobby.png` and `pages_960x540/08_online_lobby.png` needed stronger native roster/log hierarchy in the right panel. No missing, broken, or low-quality bitmap gap was found.
- Decision: no GPT image-generation task was dispatched. The follow-up was handled in Godot UI code by increasing local right-panel backplate strength, roster/log panel height allocation, and text luma/font-size coverage.

## 2026-07-06 playable-tile 3D generation deprecation audit

- User request: the generated 3D mahjong tiles look poor; switch to another approach.
- Mode check: `node /root/.codex/skills/gpt-image-2/scripts/check-mode.js --json` returned `B-or-C`; Garden generation is not enabled in the default shell.
- Runtime audit:
  - `GPT_ILLUSTRATION_ASSET_PATHS` registered assets: 95.
  - Missing registered PNG files: 0.
  - Candidate/QA `.import` sidecars under `build/qa`, `.tmp`, and `garden-gpt-image-2/image/candidates`: 0.
- Decision: no GPT image-generation task was dispatched. Runtime playable tiles now use only the clean `assets/tiles/*.png` sprites plus Godot-native shadow/highlight/depth; missing tile assets fall back to `assets/tiles/tile_back.png`, not `assets/tiles_3d`.
- Generation workflow note: `tools/generate_gpt_mahjong_tiles.py` now prompts for clean flat 2D retouched sprites instead of fake 3D physical tiles, and the old `tools/build_3d_tile_faces.py` path refuses to run unless explicitly passed `--allow-deprecated-3d`.

## 2026-07-06 subtle 3D blank-tile body generation

- User request: explore another way to get a 3D tile effect and explicitly allow image generation.
- Mode check with `ENABLE_GARDEN_IMAGEGEN=1`: `node /root/.codex/skills/gpt-image-2/scripts/check-mode.js --json` returned `A`, so Garden local GPT Image 2 generation was used.
- Generated prompts:
  - `garden-gpt-image-2/prompt/p0_blank_tile_body_subtle_3d_v2-20260706.md`
  - `garden-gpt-image-2/prompt/p0_blank_tile_body_subtle_3d_v2_chroma-20260706.md`
- Generated candidates:
  - `garden-gpt-image-2/image/candidates/p0/blank_tile_body_subtle_3d_v2_candidate_01.png`
  - `garden-gpt-image-2/image/candidates/p0/blank_tile_body_subtle_3d_v2_candidate_01_clean.png`
  - `garden-gpt-image-2/image/candidates/p0/blank_tile_body_subtle_3d_v2_candidate_02_chroma.png`
  - `garden-gpt-image-2/image/candidates/p0/blank_tile_body_subtle_3d_v2_candidate_02_clean.png`
  - `garden-gpt-image-2/image/candidates/p0/blank_tile_body_subtle_3d_v2_200x280.png`
- Review result: candidate 02 is the usable direction. It uses a chroma-key generation pass, then local true-alpha cleanup and green-edge decontamination. A deterministic composite preview is at `.tmp/tile_body_preview_v2/tile_man1.png`, with comparison at `build/qa/tile_3d_strategy_comparison_v2.png`.
- Integration status: this generation direction has been wired into runtime through the follow-up below.

## 2026-07-06 subtle 3D playable-tile runtime integration

- Asset generation: `tools/build_subtle_3d_tile_faces.py` now builds a full deterministic tile set from one GPT-generated blank body and the authoritative `assets/tiles/*.png` markings.
- Runtime assets:
  - `assets/tiles_subtle_3d/_tile_body_subtle_3d.png`
  - `assets/tiles_subtle_3d/tile_*.png` (42 playable face sprites)
- QA artifacts:
  - `build/qa/subtle_3d_tile_contact_sheet.png`
  - `build/qa/pages/03_offline_battle.png`
  - `build/qa/pages_960x540/03_offline_battle.png`
- Runtime decision: `tile_path()` now prefers `assets/tiles_subtle_3d/*.png`, falls back to `assets/tiles/*.png`, and never uses legacy `assets/tiles_3d/*.png`.
- Verification: full candidate set has 42 `200x280 RGBA` sprites; `assemble_main --check`, `assemble_main --verify`, `git diff --check`, `ui_layout_smoke_test.gd`, `offline_smoke_test.gd`, refreshed 1280/960 screenshots, and both screenshot manifest checks passed.

## 2026-07-06 offline-battle side-thumbnail image-demand audit

- User request: continue prioritizing the single-player battle page, keep AI information compact, and use the improved 3D tile approach.
- Mode check: default `gpt-image-2` mode remains `B-or-C`; with `ENABLE_GARDEN_IMAGEGEN=1`, local Mode A is available, but no new bitmap gap was found for this pass.
- Decision: no additional GPT image-generation task was dispatched. The correct 3D path remains the existing subtle blank-tile body plus deterministic source-marking composite in `assets/tiles_subtle_3d/`.
- Follow-up handled natively: left/right AI seat cards were changed into thumbnail cards with short name, score, hand/flower count, and one clipped recent-river line; the table art and tile sprites did not require new generated assets.

## 2026-07-06 online-lobby endpoint-chip image-demand audit

- User request context: continue screenshot-led UI polish, check image-generation needs first, and fix visible UI containment/readability issues.
- Mode check: `node /root/.codex/skills/gpt-image-2/scripts/check-mode.js --json` returned `B-or-C`; Garden local generation remains available only when explicitly enabled with `ENABLE_GARDEN_IMAGEGEN=1`.
- Screenshot review: `pages_960x540/08_online_lobby.png` showed the top-right server endpoint chip rendering `129.146.180.88:233...`, hiding the port in the primary status area.
- Decision: no GPT image-generation task was dispatched. This was a native layout/text-allocation issue, not a missing or low-quality bitmap. The endpoint badge was widened, named for tests, and validated with font-width layout coverage.

## 2026-07-06 shop lower-cabinet image-demand audit

- User request context: continue screenshot-led UI polish and check GPT image needs before native work.
- Mode check: `node /root/.codex/skills/gpt-image-2/scripts/check-mode.js --json` returned `B-or-C`; no local generation was enabled for this pass.
- Screenshot review: `pages_960x540/07_shop.png` showed the item rows concentrated in the upper half with a large unused lower cabinet area. Existing `shop_gpt_vault` and `shop_charm_*` assets were present and consumed.
- Decision: no GPT image-generation task was dispatched. The issue was native layout/content hierarchy, handled by adding a Godot-rendered lower cabinet footer with inventory and purchase guidance.

## 2026-07-06 menu-card readability image-demand audit

- User request context: continue screenshot-led UI polish and keep GPT image needs checked first.
- Mode check: `node /root/.codex/skills/gpt-image-2/scripts/check-mode.js --json` returned `B-or-C`; no local generation was enabled for this pass.
- Screenshot review: `pages_960x540/01_menu.png` showed the primary action cards using the existing generated stage/backdrop successfully, but card title/subtitle readability depended too much on the transparent card surface.
- Decision: no GPT image-generation task was dispatched. The correct fix was native: add Godot-rendered text backplates and named title/subtitle labels inside the three menu cards.

## 2026-07-06 alternate 3D tile-body generation audit

- User request: ask whether another 3D tile-generation method can be used, with image generation allowed.
- Mode check:
  - Default shell: `node /root/.codex/skills/gpt-image-2/scripts/check-mode.js --json` returned `B-or-C`.
  - With `ENABLE_GARDEN_IMAGEGEN=1`, local GPT Image 2 Mode A was available and used.
- Subagent note: the delegated image-strategy worker failed due to temporary high demand, so the generation audit was handled locally.
- Existing best path remains: generate only a blank 3D-feel tile body, then deterministically composite authoritative `assets/tiles/*.png` markings. Do not ask the model to redraw complete mahjong faces.
- New candidate prompts:
  - `garden-gpt-image-2/prompt/p0_blank_tile_body_thin_bevel_v3-20260706.md`
  - `garden-gpt-image-2/prompt/p0_blank_tile_body_transparent_v4-20260706.md`
- New generated candidates:
  - `garden-gpt-image-2/image/candidates/p0/blank_tile_body_thin_bevel_v3_candidate_01_chroma.png`
  - `garden-gpt-image-2/image/candidates/p0/blank_tile_body_transparent_v4_candidate_01.png`
- QA previews:
  - `build/qa/subtle_3d_tile_contact_sheet_v3.png`
  - `build/qa/subtle_3d_tile_contact_sheet_v4.png`
- Review result:
  - v3 produced a thinner body, but its green-screen background had gradients/shadows; cleanup left dark edge noise on the tile body.
  - v4 was requested as transparent, but the gateway returned opaque RGB with a fake checkerboard background; deterministic cleanup turned that into noisy face artifacts.
- Decision: neither v3 nor v4 was integrated. Runtime should continue using `assets/tiles_subtle_3d/*.png`, which is the current stable implementation of the blank-body-plus-source-marking strategy.

## 2026-07-06 procedural thin-bevel tile-body follow-up

- User request: replace the unattractive generated 3D mahjong tiles with another 3D-effect method, and call/delegate image generation first if useful.
- Mode check: `node /root/.codex/skills/gpt-image-2/scripts/check-mode.js --json` returned `B-or-C` in the default shell.
- Delegated image-strategy result:
  - `garden-gpt-image-2/prompt/blank_mahjong_tile_body_jade_side_200x280-20260706.md`
  - `build/qa/blank_tile_body_generation_strategy_20260706.md`
- Decision: do not generate complete playable tile faces. The stable approach remains one blank body plus deterministic compositing from authoritative `assets/tiles/*.png` markings.
- Integration chosen for this pass: no new bitmap candidate was promoted. `tools/build_subtle_3d_tile_faces.py` now defaults to a deterministic procedural thin-bevel body with a clean ivory face, restrained jade side edge, no inner frame, and stricter symbol extraction so source border/gray artifacts are not copied into the output.
- Runtime visual adjustment: textured tile views no longer receive the old gold-lip or porcelain-inset overlay from `draw_tile_depth_art()`. They keep only subtle contact shadow, low-alpha jade edge shading, and light sheen.
- Rebuilt artifacts:
  - `assets/tiles_subtle_3d/_tile_body_subtle_3d.png`
  - `assets/tiles_subtle_3d/tile_*.png` (42 deterministic playable sprites)
  - `build/qa/subtle_3d_tile_contact_sheet.png`
- Verification: `py_compile`, `assemble_main --check`, `assemble_main --verify`, `git diff --check`, Godot headless startup, `ui_layout_smoke_test.gd`, `offline_smoke_test.gd`, refreshed 1280/960 screenshots, and both screenshot manifest checks passed. Headless/offscreen runs only retained the known Xvfb/ALSA/ObjectDB/lambda cleanup noise.

## 2026-07-06 direct blank-body generation retry

- User request: ask whether another 3D effect can be generated, with image generation allowed.
- Mode check:
  - Default shell remained `B-or-C`.
  - `ENABLE_GARDEN_IMAGEGEN=1` successfully enabled local Mode A against `http://127.0.0.1:8080/v1`.
- New prompt:
  - `garden-gpt-image-2/prompt/p0_blank_tile_body_flat_face_jade_edge_v5-20260706.md`
- New generated candidates:
  - `garden-gpt-image-2/image/candidates/p0/blank_tile_body_thin_bevel_v3_raw.png`
  - `garden-gpt-image-2/image/candidates/p0/blank_tile_body_thin_bevel_v3_alpha.png`
  - `garden-gpt-image-2/image/candidates/p0/blank_tile_body_flat_face_jade_edge_v5_raw.png`
  - `garden-gpt-image-2/image/candidates/p0/blank_tile_body_flat_face_jade_edge_v5_alpha.png`
- QA previews:
  - `build/qa/subtle_3d_tile_contact_sheet_generated_v3.png`
  - `build/qa/subtle_3d_tile_contact_sheet_generated_v5.png`
- Review result:
  - v3 is visually clean and symbol-safe, but the model kept a recessed face highlight and a warmer/browner side edge than requested.
  - v5 produced the requested jade side material, but the side wall is thicker and the face still has an inset rim.
  - Both candidates validate the blank-body-plus-deterministic-markings path, but neither is cleaner than the current procedural thin-bevel runtime body.
- Decision: keep both as reusable candidates and do not promote either to `assets/tiles_subtle_3d/` by default. Runtime should continue using the procedural body unless a later pass deliberately tunes the generated-body look.

## 2026-07-06 loading-page UI pass image-demand audit

- User goal context: continue improving the game app, check image-generation needs first, and use screenshot analysis to address UI-test findings.
- Mode check: `node /root/.codex/skills/gpt-image-2/scripts/check-mode.js --json` returned `B-or-C`; local Mode A remains available only when explicitly invoked with `ENABLE_GARDEN_IMAGEGEN=1`.
- Screenshot/test finding: the loading page had native layout overlap between the status text and loading progress/shuffle decoration. Existing loading backdrop art was present and usable.
- Decision: no new GPT bitmap was needed. The issue was native anchor/layout spacing, handled in Godot code and smoke tests.

## 2026-07-06 matte orthographic tile-body v7 promotion

- User request: replace the ugly generated 3D tile look and call image generation if useful.
- Mode check:
  - Default shell: `node /root/.codex/skills/gpt-image-2/scripts/check-mode.js --json` returned `B-or-C`.
  - `ENABLE_GARDEN_IMAGEGEN=1` enabled local GPT Image 2 Mode A against `http://127.0.0.1:8080/v1`.
- Generated prompts/candidates:
  - `garden-gpt-image-2/prompt/candidates/p0/blank_tile_body_orthographic_slab_v6.md`
  - `garden-gpt-image-2/prompt/candidates/p0/blank_tile_body_nineslice_bevel_frame_v6.md`
  - `garden-gpt-image-2/prompt/candidates/p0/blank_tile_body_soft_ceramic_skin_v6.md`
  - `garden-gpt-image-2/prompt/candidates/p0/blank_tile_body_matte_orthographic_v7.md`
  - `garden-gpt-image-2/image/candidates/p0/blank_tile_body_matte_orthographic_v7_alpha.png`
  - `garden-gpt-image-2/image/candidates/p0/blank_tile_body_matte_orthographic_v7_200x280.png`
- Review decision:
  - v6 candidates were not promoted because they still had heavy side walls, inner grooves, or dark border emphasis.
  - v7 is the accepted direction: matte ivory, orthographic, minimal bottom edge, no full playable face generation.
- Runtime promotion:
  - `tools/clean_gpt_transparent_asset.py` normalized the v7 candidate to true-alpha `200x280`.
  - `tools/build_subtle_3d_tile_faces.py --body-mode generated` composited the authoritative `assets/tiles/*.png` markings onto the v7 body.
  - `assets/tiles_subtle_3d/_tile_body_subtle_3d.png` and all 42 `assets/tiles_subtle_3d/tile_*.png` were regenerated from the v7 body.
  - `build/qa/subtle_3d_tile_contact_sheet.png` and `build/qa/subtle_3d_tile_contact_sheet_generated_v7.png` record the accepted visual set.
- Safety rule remains unchanged: do not GPT-generate complete playable mahjong faces. GPT may generate only blank bodies/material layers; tile identity must come from deterministic source-marking composition.

## 2026-07-06 shop scrollbar and online feedback audit

- User goal context: keep checking image-generation needs before UI work and submit true bitmap needs to the GPT image agent.
- Mode check: `ENABLE_GARDEN_IMAGEGEN=1 node /root/.codex/skills/gpt-image-2/scripts/check-mode.js --json` returned local Mode A against `http://127.0.0.1:8080/v1`.
- Reviewed pages: `07_shop.png` and `08_online_lobby.png` at both `1280x720` and `960x540`.
- Decision: no new GPT PNG was needed. The shop issue was a default native scrollbar/gutter styling problem; the online lobby issue was feedback-text safe area and native backplate placement.
- Engineering handoff: keep existing `shop_gpt_vault`, `shop_charm_*`, `online_gpt_lobby`, `online_lobby_panel_frame`, `online_lobby_group_plate`, and `online_feedback_gpt_strip` assets. Do not generate replacement images for this pass.

## 2026-07-06 settings modal scrim audit

- User goal context: continue UI polish with image-generation demand checked first.
- Mode check: `ENABLE_GARDEN_IMAGEGEN=1 node /root/.codex/skills/gpt-image-2/scripts/check-mode.js --json` returned local Mode A against `http://127.0.0.1:8080/v1`.
- Reviewed page: `02_menu_settings.png` at `1280x720` and `960x540`.
- Decision: no new GPT PNG was needed. Existing settings panel art is present; the issue was native overlay dimming, solved with a full-screen Godot-rendered scrim.
- Engineering handoff: keep `settings_gpt_panel_v2` and related settings assets unchanged. Do not generate a replacement settings backdrop for this pass.

## 2026-07-06 chroma-key blank tile body promotion

- User request: ask for another way to create the 3D mahjong tile effect and explicitly allow image generation.
- Skill/mode check: `ENABLE_GARDEN_IMAGEGEN=1 node /root/.codex/skills/gpt-image-2/scripts/check-mode.js --json` returned local Mode A against `http://127.0.0.1:8080/v1`.
- Delegated image agent produced reusable Mode C prompts; the main run then generated the recommended chroma-key blank body through Mode A.
- Generated prompt and source candidate:
  - `garden-gpt-image-2/prompt/p0_blank_tile_body_jade_flat_v6_actual-20260706.md`
  - `garden-gpt-image-2/image/candidates/p0/blank_tile_body_jade_flat_v6_actual_raw.png`
- Rejected candidate:
  - `garden-gpt-image-2/image/candidates/p0/blank_tile_body_low_relief_v8_raw.png` because the gateway baked a fake checkerboard background, leaving noisier edges after cleanup.
- Runtime promotion:
  - `tools/build_subtle_3d_tile_faces.py --body-mode generated` used the chroma-key blank body and deterministic `assets/tiles/*.png` markings.
  - `assets/tiles_subtle_3d/_tile_body_subtle_3d.png` and all 42 playable `assets/tiles_subtle_3d/tile_*.png` were regenerated as `200x280 RGBA` true-alpha sprites.
  - `build/qa/subtle_3d_tile_contact_sheet.png` records the promoted set.
- Safety rule remains unchanged: GPT generated only the blank body/material layer. No complete playable mahjong face was generated by GPT.

## 2026-07-06 achievements summary image-demand audit

- User goal context: continue screenshot-led UI polish and check generated-image demand first.
- Mode check: `ENABLE_GARDEN_IMAGEGEN=1 node /root/.codex/skills/gpt-image-2/scripts/check-mode.js --json` returned local Mode A against `http://127.0.0.1:8080/v1`.
- Reviewed page: `06_achievements.png` at `1280x720` and `960x540`.
- Decision: no new GPT PNG was needed. Existing `achievement_gpt_gallery` art is present; the visible issue was native text/decorator layering in the summary card and loose status-chip spacing in achievement rows.
- Engineering handoff: keep achievement generated art unchanged. The fix was handled in Godot UI code with local text backplate layering and compact status-chip typography.

## 2026-07-06 soft jade blank tile body generation

- User request: find another way to create the 3D mahjong tile effect and call image generation if useful.
- Mode check: `ENABLE_GARDEN_IMAGEGEN=1 node /root/.codex/skills/gpt-image-2/scripts/check-mode.js --json` returned local Mode A against `http://127.0.0.1:8080/v1`.
- Delegation: image-generation worker `Descartes` was assigned a bounded blank-body task. It was instructed not to edit runtime assets and to generate only blank tile bodies, never playable tile faces.
- Generated prompts:
  - `garden-gpt-image-2/prompt/blank_tile_body_soft_jade_relief_20260706.md`
  - `garden-gpt-image-2/prompt/blank_tile_body_ink_green_thin_side_20260706.md`
  - `garden-gpt-image-2/prompt/blank_tile_body_clay_lacquer_soft_shadow_20260706.md`
- Generated candidates:
  - `garden-gpt-image-2/image/candidates/tiles/blank_tile_body_soft_jade_relief_candidate_2.png`
  - `garden-gpt-image-2/image/candidates/tiles/blank_tile_body_ink_green_thin_side_candidate_2.png`
  - `garden-gpt-image-2/image/candidates/tiles/blank_tile_body_clay_lacquer_soft_shadow_candidate_2.png`
- Review decision:
  - `ink_green_thin_side` was rejected because the generated front face became too dark and reduced symbol readability.
  - `clay_lacquer_soft_shadow` was rejected for runtime promotion because candidate 2 has a heavier top black line, despite a clean warm face.
  - `soft_jade_relief` was promoted because it is the most front-facing, keeps the largest clean center area for deterministic symbol compositing, and reads as a restrained low-relief jade body at small game sizes.
- Runtime promotion:
  - `tools/build_subtle_3d_tile_faces.py` now accepts blue chroma-key backgrounds in addition to green/neutral backgrounds.
  - `assets/tiles_subtle_3d/_tile_body_subtle_3d.png` and all 42 playable `assets/tiles_subtle_3d/tile_*.png` were regenerated from `blank_tile_body_soft_jade_relief_candidate_2.png` plus deterministic `assets/tiles/*.png` markings.
  - `build/qa/subtle_3d_tile_contact_sheet.png` records the promoted set.
- Safety rule remains unchanged: GPT generated only the blank body/material layer. No complete playable mahjong face was generated by GPT.

## 2026-07-06 stats narrative panel image-demand audit

- User goal context: continue screenshot-led UI polish and check generated-image demand first.
- Mode check: `ENABLE_GARDEN_IMAGEGEN=1 node /root/.codex/skills/gpt-image-2/scripts/check-mode.js --json` returned local Mode A against `http://127.0.0.1:8080/v1`.
- Reviewed page: `05_stats.png` at `1280x720` and `960x540`.
- Decision: no new GPT PNG was needed. Existing `stats_gpt_dashboard` and `stats_winrate_scroll` assets are present and consumed; the remaining issue was the native top-dashboard left lane reading as decorative dead space.
- Engineering handoff: keep stats generated art unchanged. The fix was handled with a native `StatsSummaryNarrativePanel` that labels the current record state and fills the left dashboard lane without changing GPT assets.

## 2026-07-06 soft orthographic tile-body v9 promotion

- User request: ask for another way to create the 3D mahjong tile effect and explicitly allow image generation.
- Mode check: `ENABLE_GARDEN_IMAGEGEN=1 node /root/.codex/skills/gpt-image-2/scripts/check-mode.js --json` returned local Mode A against `http://127.0.0.1:8080/v1`.
- Generated prompts:
  - `garden-gpt-image-2/prompt/candidates/tiles/blank_tile_body_soft_orthographic_v9.md`
  - `garden-gpt-image-2/prompt/candidates/tiles/blank_tile_body_jade_thin_side_v9.md`
  - `garden-gpt-image-2/prompt/candidates/tiles/blank_tile_body_studio_clay_v9.md`
- Generated candidates and previews:
  - `garden-gpt-image-2/image/candidates/tiles/blank_tile_body_soft_orthographic_v9_raw.png`
  - `garden-gpt-image-2/image/candidates/tiles/blank_tile_body_soft_orthographic_v9_200x280.png`
  - `garden-gpt-image-2/image/candidates/tiles/blank_tile_body_jade_thin_side_v9_raw.png`
  - `garden-gpt-image-2/image/candidates/tiles/blank_tile_body_jade_thin_side_v9_200x280.png`
  - `garden-gpt-image-2/image/candidates/tiles/blank_tile_body_studio_clay_v9_raw.png`
  - `garden-gpt-image-2/image/candidates/tiles/blank_tile_body_studio_clay_v9_200x280.png`
  - `build/qa/tile_body_v9_candidate_comparison.png`
  - `build/qa/subtle_3d_v9_soft_orthographic_samples.png`
  - `build/qa/subtle_3d_v9_jade_thin_side_samples.png`
  - `build/qa/subtle_3d_v9_studio_clay_samples.png`
- Review decision:
  - `soft_orthographic_v9` was promoted. It gives a low-relief 2.5D body through soft bevels and material gradient rather than a thick rendered side wall.
  - `jade_thin_side_v9` was kept as a reference only; after downsampling the right jade edge reads darker and dirtier than desired.
  - `studio_clay_v9` was rejected because cleanup produced a hard dark outline.
- Runtime promotion:
  - `tools/build_subtle_3d_tile_faces.py --body-mode generated` rebuilt `assets/tiles_subtle_3d/_tile_body_subtle_3d.png` and all 42 playable `assets/tiles_subtle_3d/tile_*.png`.
  - `build/qa/subtle_3d_tile_contact_sheet.png` records the promoted full set.
- Safety rule remains unchanged: GPT generated only the blank body/material layer. Playable markings still come from deterministic compositing of authoritative `assets/tiles/*.png` sources.

## 2026-07-06 orthographic white-jade tile-body v10 promotion

- User request: try another way to make the 3D mahjong tile effect and allow image generation.
- Skill/mode check: `ENABLE_GARDEN_IMAGEGEN=1 node /root/.codex/skills/gpt-image-2/scripts/check-mode.js --json` returned local Mode A against `http://127.0.0.1:8080/v1`.
- Delegation: image-generation worker `Banach` produced three blank-body strategies under `garden-gpt-image-2/image/candidates/tiles_v10/` and prompts under `garden-gpt-image-2/prompt/candidates/tiles_v10/`.
- Promoted source:
  - `garden-gpt-image-2/image/candidates/tiles_v10/blank_tile_body_orthographic_white_jade_v10_200x280.png`
  - prompt: `garden-gpt-image-2/prompt/candidates/tiles_v10/blank_tile_body_orthographic_white_jade_v10.md`
- Kept as references:
  - `blank_tile_body_baked_nineslice_v10_200x280.png` as deterministic/NinePatch-style fallback.
  - `blank_tile_body_guofeng_silk_papercut_v10_200x280.png` as a more illustrated special-skin direction.
- Runtime promotion: `tools/build_subtle_3d_tile_faces.py --body-mode generated` rebuilt `assets/tiles_subtle_3d/_tile_body_subtle_3d.png` and all 42 playable `assets/tiles_subtle_3d/tile_*.png`; `build/qa/subtle_3d_tile_contact_sheet.png` records the promoted set.
- Safety rule remains unchanged: GPT generated only the blank body/material layer. Playable markings still come from deterministic compositing of authoritative `assets/tiles/*.png` sources.

## 2026-07-06 daily-login forecast image-demand audit

- Mode A was available, but no new daily-login bitmap was generated. Existing `assets/illustrations/daily_login_gpt_calendar.png` is present and consumed by `DailyLoginGPTCalendarTexture`.
- The visible change was native layout/information hierarchy: daily-login now exposes a compact `DailyLoginForecastPanel` with title/body/badge for the seven-day reward preview.

## 2026-07-06 rules page reading-priority image-demand audit

- Mode A remained available, but no new rules-page bitmap was needed. Existing rules art assets are sufficient; the visible issue was native reading width versus the right-side example strip.
- Runtime/layout decision: keep the current generated art unchanged and solve the page with native layout only. `RuleSectionTextBackplate` and the text vbox were widened, while `RuleSectionArtStrip` was shifted right and narrowed.
- Screenshot review target: `build/qa/pages/04_rules.png` and `build/qa/pages_960x540/04_rules.png` now prioritize the text lane, with the decorative example strip staying compact.

## 2026-07-06 online lobby room-summary image-demand audit

- Mode A remained available through `ENABLE_GARDEN_IMAGEGEN=1`, but no new online-lobby bitmap was needed. Existing `online_gpt_lobby`, `online_lobby_panel_frame`, `online_lobby_group_plate`, `lobby_room_gate_token`, and `online_feedback_gpt_strip` assets are already consumed.
- Decision: solve this pass with native UI only. The visible gap was room-state hierarchy, not missing generated art.
- Runtime handoff: `OnlineLobbyRoomArt` now includes compact native summary chips for occupancy, ready count, and connection state above the four seat beads.

## 2026-07-06 thin chroma tile-body v11 promotion

- User request: find another way to make the 3D mahjong tile effect and explicitly allow image generation.
- Mode check: `ENABLE_GARDEN_IMAGEGEN=1 node /root/.codex/skills/gpt-image-2/scripts/check-mode.js --json` returned local Mode A against `http://127.0.0.1:8080/v1`.
- Delegation: image-generation worker `Bernoulli` generated additional blank-body candidates under `garden-gpt-image-2/image/candidates/tiles_v11/` and prompts under `garden-gpt-image-2/prompt/candidates/tiles_v11/`.
- Main-agent follow-up generation used chroma-key prompts because opaque white/fake-transparent outputs were not reliable for alpha cleanup.
- Promoted source:
  - `garden-gpt-image-2/image/candidates/tiles_v11/blank_tile_body_thin_chroma_v11_raw.png`
  - prompt: `garden-gpt-image-2/prompt/candidates/tiles_v11/blank_tile_body_thin_chroma_v11.md`
- Rejected or reference-only candidates are documented in `garden-gpt-image-2/image/candidates/tiles_v11/manifest.md`; the main failure modes were dark face cleanup, gray texture noise, or opaque white backgrounds that could not be separated from the porcelain face.
- Runtime promotion: `assets/tiles_subtle_3d/_tile_body_subtle_3d.png` and all 42 playable `assets/tiles_subtle_3d/tile_*.png` were rebuilt from the promoted blank body plus deterministic `assets/tiles/*.png` markings; `build/qa/subtle_3d_tile_contact_sheet.png` records the promoted set.
- Safety rule remains unchanged: GPT generated only the blank body/material layer. Playable markings still come from deterministic compositing of authoritative source tiles.

## 2026-07-06 daily-login forecast hierarchy image-demand audit

- Image-demand audit: no new GPT bitmap was needed. Existing `daily_login_gpt_calendar` art is present and consumed; the defect was the native seven-day forecast panel reading as a thin bottom footer.
- Decision: keep generated daily-login art unchanged and solve with native layout hierarchy.
- Runtime handoff: `DailyLoginForecastPanel` was widened and made taller, the claim button/reward/progress stack was tightened upward, and the forecast title/body/status badge now use separate readable lanes.

## 2026-07-06 shallow-relief tile-body v12 promotion

- User request: fix the offline battle page first, keep image-generation needs ahead of native work, and try another way to make the generated 3D mahjong tiles less ugly.
- Mode check: `ENABLE_GARDEN_IMAGEGEN=1 node /root/.codex/skills/gpt-image-2/scripts/check-mode.js --json` returned local Mode A against `http://127.0.0.1:8080/v1`.
- Delegation: image-generation worker `Archimedes` generated two blank-body candidates only under `garden-gpt-image-2/image/candidates/tiles_v12_agent/` and prompts under `garden-gpt-image-2/prompt/candidates/tiles_v12_agent/`; it did not modify code or runtime assets.
- Review decision: `blank_tile_body_25d_baked_ui_v12.png` was rejected after deterministic composition because the resulting contact sheet had visible gray/black face noise. `blank_tile_body_shallow_relief_ivory_jade_v12.png` was promoted because the contact sheet stayed clean and the raised rim reads as a different shallow-relief 3D method.
- Runtime promotion: `assets/tiles_subtle_3d/_tile_body_subtle_3d.png` and all 42 playable `assets/tiles_subtle_3d/tile_*.png` were rebuilt from the v12 shallow-relief blank body plus deterministic `assets/tiles/*.png` markings; `build/qa/subtle_3d_tile_contact_sheet.png` records the promoted set.
- Tooling: `tools/build_subtle_3d_tile_faces.py` now defaults to the v12 shallow-relief source so the promoted body is reproducible by default.
- Safety rule remains unchanged: GPT generated only the blank body/material layer. Playable markings still come from deterministic compositing of authoritative source tiles.

## 2026-07-06 v13 blank-body retry and procedural promotion

- User request: ask for another way to generate the 3D tile effect, with image generation allowed.
- Mode check: default shell returned `B-or-C`; local Mode A was available with `ENABLE_GARDEN_IMAGEGEN=1` against `http://127.0.0.1:8080/v1`.
- Delegation: image-generation worker `Planck` was assigned a bounded blank-body task under `garden-gpt-image-2/prompt/candidates/tiles_v13_agent/` and `garden-gpt-image-2/image/candidates/tiles_v13_agent/`. The worker produced images but timed out before final reporting, so the main agent reviewed and documented the candidates.
- Generated prompts/candidates:
  - `garden-gpt-image-2/prompt/candidates/tiles_v13_agent/blank_tile_body_clean_white_v13.md`
  - `garden-gpt-image-2/image/candidates/tiles_v13_agent/blank_tile_body_clean_white_v13.png`
  - `garden-gpt-image-2/prompt/candidates/tiles_v13_agent/blank_tile_body_chroma_green_v13.md`
  - `garden-gpt-image-2/image/candidates/tiles_v13_agent/blank_tile_body_chroma_green_v13.png`
  - `garden-gpt-image-2/image/candidates/tiles_v13_agent/manifest.md`
- Review decision: neither v13 candidate was promoted. The white-background candidate left dark/gray cleanup artifacts; the chroma candidate had a non-uniform green floor and still read as a thick framed tile after 200x280 composition.
- Runtime promotion: `assets/tiles_subtle_3d/_tile_body_subtle_3d.png` and all 42 playable `assets/tiles_subtle_3d/tile_*.png` were rebuilt from the deterministic procedural thin-bevel body plus authoritative `assets/tiles/*.png` markings.
- Tooling: `tools/build_subtle_3d_tile_faces.py` now defaults to `--body-mode procedural`, while `--body-mode generated --body <path>` remains available for future material experiments.
- Safety rule remains unchanged: GPT may generate only blank body/material candidates. Playable markings still come from deterministic source-tile compositing.

## 2026-07-06 stats semantics image-demand audit

- User goal context: continue screenshot-led UI polish and check generated-image demand before native work.
- Mode check: `node /root/.codex/skills/gpt-image-2/scripts/check-mode.js --json` returned `B-or-C`; local Mode A remains available by setting `ENABLE_GARDEN_IMAGEGEN=1`.
- Screenshot review: `build/qa/pages_960x540/05_stats.png` showed that generated stats art is present and usable, but native metric labels `累计分数` and `最高得分` were semantically ambiguous beside negative net score and single-game best score values.
- Decision: no GPT image-generation task was dispatched. The issue was native wording and test semantics, not a missing or low-quality bitmap.
- Runtime handoff: statistics now use `累计净分` for `total_score` and `单局最佳` for `best_score`; the summary chip caption also uses `单局最佳`.

## 2026-07-06 online lobby status hierarchy image-demand audit

- User goal context: continue screenshot-led UI polish and check generated-image demand first.
- Mode check: `node /root/.codex/skills/gpt-image-2/scripts/check-mode.js --json` returned `B-or-C`; local Mode A remains available with `ENABLE_GARDEN_IMAGEGEN=1`.
- Screenshot review: `build/qa/pages_960x540/08_online_lobby.png` already consumed the generated lobby/panel/feedback art correctly. The visible issue was native state hierarchy: the lower-left status repeated raw server endpoint details while the primary start button looked actionable before a server connection.
- Decision: no GPT image-generation task was dispatched. Existing online-lobby generated assets are sufficient.
- Runtime handoff: lower status now says `未连接 · 先连服，再建房或入房`, avoiding duplicate endpoint text; the primary start slot shows disabled `待连接` until the server connection state becomes `已连接`.

## 2026-07-06 v14 local orthographic low-relief blank-body review

- User request: ask whether there is another way to generate the 3D tile effect and explicitly allow image generation.
- Mode check: default shell returned `B-or-C`; local Mode A was available with `ENABLE_GARDEN_IMAGEGEN=1` against `http://127.0.0.1:8080/v1`.
- Delegation: image-generation worker `Boole` was assigned a bounded three-candidate blank-body task, but it did not return before shutdown. The main agent ran one local candidate directly so the user request could be answered with an actual generated asset.
- Generated prompt/candidate:
  - `garden-gpt-image-2/prompt/candidates/tiles_v14_local/blank_tile_body_orthographic_low_relief_v14.md`
  - `garden-gpt-image-2/image/candidates/tiles_v14_local/blank_tile_body_orthographic_low_relief_v14_raw.png`
  - `garden-gpt-image-2/image/candidates/tiles_v14_local/manifest.md`
- Deterministic review artifacts:
  - `.tmp/subtle_3d_v14_low_relief/_tile_body_subtle_3d.png`
  - `.tmp/subtle_3d_v14_low_relief/tile_*.png`
  - `build/qa/subtle_3d_tile_contact_sheet_v14_low_relief.png`
- Review decision: do not promote v14 to `assets/tiles_subtle_3d/`. It is a better material direction than the old ugly full-3D generated faces, with a clean center and no GPT-made tile symbols, but the 200x280 contact sheet shows thin top-edge artifacts and a slight frame/inset look.
- Recommended next image prompt direction: keep the orthographic low-relief porcelain body, but explicitly remove all top-edge hairlines, remove inset grooves, and request a single continuous rounded slab with only right/bottom micro-shadow.
- Safety rule remains unchanged: GPT may generate only blank body/material candidates. Playable markings still come from deterministic source-tile compositing.

## 2026-07-06 achievements readability image-demand audit

- User goal context: continue screenshot-led UI polish and check generated-image demand before native work.
- Mode check: `node /root/.codex/skills/gpt-image-2/scripts/check-mode.js --json` returned `B-or-C`; local Mode A remains available with `ENABLE_GARDEN_IMAGEGEN=1`.
- Screenshot review: `build/qa/pages_960x540/06_achievements.png` already consumes the generated achievement gallery/medal art. The visible issue was native row information hierarchy: progress rails were too thin to explain binary achievement state, and the right chip used overly terse one-character marks.
- Decision: no GPT image-generation task was dispatched. The page needed clearer native labels and progress semantics, not another bitmap.
- Runtime handoff: achievement rows now show player-facing goal copy, binary progress text (`进度 0/1` or `进度 1/1`), and readable badge titles such as `七对` / `十三幺` instead of one-character-only marks.

## 2026-07-06 shop purchase CTA image-demand audit

- User goal context: continue screenshot-led UI polish and check generated-image demand before native work.
- Mode check: `node /root/.codex/skills/gpt-image-2/scripts/check-mode.js --json` returned `B-or-C`; local Mode A remains available with `ENABLE_GARDEN_IMAGEGEN=1`.
- Screenshot review: `build/qa/pages_960x540/07_shop.png` already consumes generated shop/vault/charm art. The visible issue was native command semantics: buy buttons only showed a diamond and a number, and footer status badges lacked item/gem units.
- Decision: no GPT image-generation task was dispatched. Existing shop art is sufficient; the fix belongs to native CTA copy and layout.
- Runtime handoff: shop buy buttons now show explicit `购买` or `不足` command text plus gem prices such as `5玉`, and footer badges now use `库存 0件` / `可买 3种`.

## 2026-07-07 v15 generated-mask material tile-body promotion

- User request: ask for another way to generate the 3D mahjong tile effect and allow image generation.
- Mode check: default shell returned `B-or-C`; the delegated image worker used `ENABLE_GARDEN_IMAGEGEN=1` and confirmed local Mode A against `http://127.0.0.1:8080/v1` with model `gpt-image-2`.
- Delegation: image-generation worker `Beauvoir` generated two blank-body candidates only; it did not modify Godot code or runtime tile assets.
- Generated prompts/candidates:
  - `garden-gpt-image-2/prompt/candidates/tiles_v15_agent/continuous_porcelain_slab_v15.md`
  - `garden-gpt-image-2/image/candidates/tiles_v15_agent/continuous_porcelain_slab_v15.png`
  - `garden-gpt-image-2/prompt/candidates/tiles_v15_agent/baked_ui_depth_layer_v15.md`
  - `garden-gpt-image-2/image/candidates/tiles_v15_agent/baked_ui_depth_layer_v15.png`
  - `garden-gpt-image-2/prompt/candidates/tiles_v15_agent/manifest.md`
- Review decision: neither v15 PNG was promoted as raw RGB material. Direct 200x280 composition showed gray/black face flecks, especially in `build/qa/subtle_3d_tile_contact_sheet_v15_continuous.png` and `build/qa/subtle_3d_tile_contact_sheet_v15_baked_ui_depth.png`.
- Accepted method: use the GPT image only as a silhouette/depth mask, discard all generated RGB texture, then rebuild a deterministic clean porcelain body in `tools/build_subtle_3d_tile_faces.py --body-mode generated-mask-material`.
- Runtime promotion: `assets/tiles_subtle_3d/_tile_body_subtle_3d.png` and all 42 playable `assets/tiles_subtle_3d/tile_*.png` were rebuilt with `generated-mask-material` from `baked_ui_depth_layer_v15.png`; `build/qa/subtle_3d_tile_contact_sheet.png` records the promoted set.
- Safety rule remains unchanged: GPT generated only a blank body mask. Playable markings still come from deterministic source-tile compositing of authoritative `assets/tiles/*.png`.

## 2026-07-07 v16 low-relief probe and procedural 2.5D promotion

- User request: ask whether another 3D generation route is possible and allow calling image generation.
- Mode check: default shell returned `B-or-C`; main flow used local Mode A with `ENABLE_GARDEN_IMAGEGEN=1` against `http://127.0.0.1:8080/v1`, model `gpt-image-2`.
- Delegation: image-generation worker `Popper` reviewed the existing tile-body pipeline and recommended the same safety boundary: GPT may generate only blank body/material/depth references, never Chinese characters, suits, numbers, flowers, or playable tile faces.
- Generated v16 prompt/candidate:
  - `garden-gpt-image-2/prompt/candidates/tiles_v16_agent/low_relief_ui_depth_v16.md`
  - `garden-gpt-image-2/image/candidates/tiles_v16_agent/low_relief_ui_depth_v16_raw.png`
  - auto-saved prompt copy: `garden-gpt-image-2/prompt/low-relief-ui-depth-v16-output-candidate-garden-20260707-005051.md`
- Review decision: v16 raw output had a useful clean center but still leaned toward a physical thick-side render. When used through `generated-mask-material`, the contact sheet was nearly identical to v15, so it was kept as a reference rather than promoted.
- Accepted method: switch runtime back to the deterministic procedural thin-bevel body. It provides a clearer jade side edge at 200x280, avoids GPT RGB dirt, and better matches the table/back-tile material language.
- Runtime promotion: `assets/tiles_subtle_3d/_tile_body_subtle_3d.png` and all 42 playable `assets/tiles_subtle_3d/tile_*.png` were rebuilt with `tools/build_subtle_3d_tile_faces.py --body-mode procedural`; the default tool mode now matches the promoted runtime assets.
- Review artifacts:
  - `build/qa/subtle_3d_tile_contact_sheet_v16_mask_material.png`
  - `build/qa/subtle_3d_tile_contact_sheet_procedural_current.png`
  - `build/qa/subtle_3d_tile_contact_sheet.png`
- Safety rule remains unchanged: playable markings still come from deterministic source-tile compositing of authoritative `assets/tiles/*.png`.

## 2026-07-07 v17 blank-body generation probe

- User request: ask for another way to make the 3D tile effect and allow calling image generation.
- Mode check: default shell was `B-or-C`; delegated image worker `Harvey` explicitly enabled Garden and confirmed local Mode A with `gpt-image-2` against `http://127.0.0.1:8080/v1`.
- Generated blank-body candidate only:
  - prompt: `garden-gpt-image-2/prompt/candidates/tiles_v17_agent/mahjong-blank-tile-body-20260707-012737.md`
  - image: `garden-gpt-image-2/image/candidates/tiles_v17_agent/mahjong-blank-tile-body-20260707-012737.png`
- Deterministic review artifact: `build/qa/subtle_3d_tile_contact_sheet_v17_mask_material.png`, generated with `tools/build_subtle_3d_tile_faces.py --body-mode generated-mask-material`.
- Review decision: keep v17 as a material/depth reference only. The raw image is clean and has no text or symbols, but the side wall and baked shadow still read as a physical thick tile. The mask-material contact sheet showed edge slivers/shadow artifacts at 200x280.
- Runtime decision: do not promote v17. The current procedural thin-bevel 2.5D body remains the runtime tile body because it is cleaner at gameplay scale and preserves deterministic `assets/tiles/*.png` markings.

## 2026-07-07 v18 orthographic blank-body generation probe

- User request: explicitly asked whether another 3D generation method is possible and allowed calling image generation.
- Mode check: default shell returned `B-or-C`; delegated image worker `Euler` used `ENABLE_GARDEN_IMAGEGEN=1` and confirmed local Mode A with `gpt-image-2` against `http://127.0.0.1:8080/v1`.
- Generated blank-body candidates only:
  - `garden-gpt-image-2/prompt/candidates/tiles_v18_agent/tile_v18_candidate_01_orthographic_thin_jade.md`
  - `garden-gpt-image-2/image/candidates/tiles_v18_agent/tile_v18_candidate_01_orthographic_thin_jade.png`
  - `garden-gpt-image-2/prompt/candidates/tiles_v18_agent/tile_v18_candidate_02_material_normal_reference.md`
  - `garden-gpt-image-2/image/candidates/tiles_v18_agent/tile_v18_candidate_02_material_normal_reference.png`
  - `garden-gpt-image-2/prompt/candidates/tiles_v18_agent/tile_v18_candidate_03_ultra_thin_isometric.md`
  - `garden-gpt-image-2/image/candidates/tiles_v18_agent/tile_v18_candidate_03_ultra_thin_isometric.png`
- Tooling note: `tools/build_subtle_3d_tile_faces.py --body-mode generated-mask-material` now uses neutral-background alpha inference when a generated candidate lacks true alpha, so white-background GPT candidates can be reviewed without square-image edge artifacts.
- Deterministic review artifacts:
  - `build/qa/subtle_3d_tile_contact_sheet_v18_candidate_01_mask_material.png`
  - `build/qa/subtle_3d_tile_contact_sheet_v18_candidate_02_mask_material.png`
- Review decision: v18 candidate 1 proves the better alternate method: front-facing orthographic blank body as a silhouette/depth reference, then deterministic material and source markings. It is cleaner than thick full-3D GPT tiles, but the rounded soft edge is not clearly better than the current procedural body at gameplay scale.
- Runtime decision: do not promote v18 yet. Keep the procedural thin-bevel 2.5D runtime tiles while preserving v18 as a reusable reference for future material tuning.

## 2026-07-07 settings and achievements density audit

- Image-demand audit: no new GPT image generation was needed. Current settings and achievements pages already have generated background/frame art; the visible issues were native layout density, spacing, and text hierarchy at 960x540.
- UI-test agent `Raman` independently reviewed `build/qa/pages_960x540/contact_sheet.jpg` and identified settings density as a native layout issue, not a bitmap gap.
- Runtime image decision: keep existing generated page art and existing procedural 2.5D runtime tile body. No new prompt was dispatched and no image asset was promoted.

## 2026-07-07 Grok Imagine Lite gateway probe

- User request: check whether `grok-imagine-image-lite` can be called for image generation through an external OpenAI-compatible gateway.
- Secret handling: the gateway key and full gateway URL were not written to this repository, prompt files, logs, or `.env` files.
- Probe result: `GET /v1/models` was reachable through `curl` and listed `grok-imagine-image-lite`; a Python urllib probe was blocked by Cloudflare `Error 1010 / browser_signature_banned`.
- Generation result: `POST /v1/images/generations` reached the gateway but returned `400` with `images endpoint requires an image model, got "grok-imagine-image-lite"`. A minimal payload and the official example model family showed the same gateway-side classification failure.
- Decision at that time: no Grok image was generated, no candidate PNG was saved, and no asset was promoted because the probe lacked the required browser-style headers documented below.
- Runtime handoff at that time: continue using the existing `gpt-image-2` Garden workflow until a corrected Grok call path is available.

## 2026-07-07 Grok Imagine Lite executable-path update

- User supplied working call notes at `/root/output/imagegen/grok-imagine-image-lite-call.md`; this supersedes the earlier failed probe root cause.
- Corrected call requirements: use browser-like headers (`User-Agent`/`Origin`/`Referer`) and `POST /images/generations` with `model: grok-imagine-image-lite`.
- Existing successful external test artifact: `/root/output/imagegen/grok-imagine-image-lite-test.jpg`, confirmed as JPEG `784x1168` RGB. The provider may ignore requested `size`, so candidates must be inspected and normalized explicitly when needed.
- Tooling added: `tools/generate_grok_image.py` reads `GROK_IMAGE_API_KEY` and optional `GROK_IMAGE_BASE_URL`, supports prompt files, handles both `url` and `b64_json` responses, and saves candidates with the real returned image extension unless PNG normalization is requested.
- Prompt handoff added: `garden-gpt-image-2/prompt/candidates/grok/blank_tile_body_orthographic_grok_v19.md` for a safe blank-tile material probe; expected candidate output prefix is `garden-gpt-image-2/image/candidates/grok/blank_tile_body_orthographic_grok_v19`.
- Current shell status: `GROK_IMAGE_API_KEY` and `GROK_IMAGE_BASE_URL` were not present, so no live Grok request was executed in this pass and no runtime asset was promoted.
- Pipeline decision: Grok is now an allowed candidate-generation route for real bitmap gaps, but stable game assets still require the same manual visual review, alpha/format checks, screenshot capture, and manifest gates as GPT Image 2 outputs.

## 2026-07-07 rules mobile readability image-demand audit

- User goal context: continue screenshot-led guofeng UI polish and check image-generation need before dispatching a bitmap task.
- Screenshot review: `build/qa/pages_960x540/04_rules.png` already consumes `rules_gpt_scroll`, `rules_guide_panel`, `rules_reading_progress_panel`, and `rules_pattern_quads`; the visible issue was compressed native text layout, not missing art.
- UI-test agent `Feynman` independently identified the same issue and recommended native scroll/readability work with no new bitmap.
- Decision: no GPT or Grok image-generation task was dispatched. Existing rules art remains stable.
- Runtime handoff: rules content now uses `RulesContentScroll` with larger native title/body labels, taller cards, 44px back-button height, and a custom dark scroll gutter.

## 2026-07-07 menu version-chip image-demand audit

- Screenshot review: `build/qa/pages_960x540/01_menu.png` showed the menu version chip truncating `1.0.165-godot` as `版本 v1.0.165-go...`.
- Image-demand audit: no GPT or Grok bitmap was needed. The issue was native text choice and chip fit, while the menu GPT stage/backdrop art was already rendering correctly.
- Runtime decision: use a compact display-only version string for the menu footer (`版本 v1.0.165`) while keeping `app_version()` unchanged for release/update logic.
- Verification: refreshed `01_menu.png` at `1280x720` and `960x540`; both now show the compact version without ellipsis. No image candidate was generated or promoted.

## 2026-07-07 text-free chrome candidate handoff and blocked generation

- Image-demand audit: read-only UI tester `Arendt` found settings, achievements, and shop still had some generated-chrome residue that could read as fake controls or fake marks. This was a legitimate bitmap-quality gap, so new text-free ornament prompts were prepared before native mitigation.
- Prompt handoff saved:
  - `garden-gpt-image-2/prompt/candidates/chrome_v20/settings_overview_panel_text_free_v20.md`
  - `garden-gpt-image-2/prompt/candidates/chrome_v20/settings_section_signal_panel_text_free_v20.md`
  - `garden-gpt-image-2/prompt/candidates/chrome_v20/shop_currency_meter_panel_text_free_v20.md`
  - auto-saved failed-run prompt copy: `garden-gpt-image-2/prompt/generate-a-transparent-png-game-ui-ornament-asse-20260707-164822.md`
- GPT Image 2 status: local Mode A check succeeded with `ENABLE_GARDEN_IMAGEGEN=1`, but the actual `gpt-image-2` generation call for the settings overview candidate failed with `Image API error (502): upstream access forbidden`.
- Initial Grok status: the user supplied the corrected Grok Imagine Lite call notes, and `tools/generate_grok_image.py` exists for that route, but the first shell did not contain `GROK_IMAGE_API_KEY` / `GROK_IMAGE_BASE_URL`, so no live Grok request was executed before native mitigation.
- Runtime decision before Grok credentials: no v20 chrome bitmap was available for promotion. The app mitigates the issue by lowering generated chrome alpha and native dashboard ornament alpha while keeping the prompt handoff ready for a future successful GPT/Grok run.
- Verification artifacts: refreshed `02_menu_settings.png`, `06_achievements.png`, `07_shop.png`, both screenshot manifests, and `build/qa/pages_960x540/contact_sheet.jpg` document the current native-mitigation state.

## 2026-07-07 Grok v20 settings overview chrome generation

- User supplied a Grok gateway URL and key for the current session. Secret handling: the key was passed only through an interactive shell read, was not written to repository files, prompt files, `.env`, QA records, or command output.
- Prompt/candidate artifacts:
  - Existing prompt: `garden-gpt-image-2/prompt/candidates/chrome_v20/settings_overview_panel_text_free_v20.md`
  - New Grok-specific prompt: `garden-gpt-image-2/prompt/candidates/grok/chrome_v20/settings_overview_ultrawide_text_free_grok_v20.md`
  - Raw candidate 1: `garden-gpt-image-2/image/candidates/grok/chrome_v20/settings_overview_panel_text_free_v20.jpg`
  - Raw candidate 2: `garden-gpt-image-2/image/candidates/grok/chrome_v20/settings_overview_ultrawide_text_free_grok_v20.jpg`
  - Local extraction attempt: `garden-gpt-image-2/image/candidates/grok/chrome_v20/settings_overview_ultrawide_text_free_grok_v20_extracted.png`
- Provider behavior: both successful Grok calls returned `1168x784` RGB JPEGs with EXIF metadata, not transparent PNGs, confirming that the proxy/model may ignore requested transparent PNG output and requested size.
- Visual review: candidate 1 is clean and text-free but too tall, with baked checkerboard background. Candidate 2 is the better ultra-wide chrome reference and has no fake text or controls, but it still has an opaque studio background; the local alpha extraction retained background residue and is not suitable for runtime use.
- Runtime decision: do not promote either Grok v20 image. Keep them as visual references only; runtime continues with native alpha mitigation until a true transparent PNG or a reliable background-removal path is available.

## 2026-07-07 rules pattern example image-demand audit

- UI-test finding: `Sartre` flagged `build/qa/pages_960x540/04_rules.png` because `牌型介绍` used the generated `rules_pattern_quads` teaching strip, which read more like decorative tile backs than clear instructional tile faces.
- Image-demand decision: no new GPT/Grok generation was needed. The issue required authoritative runtime tile faces, not another generated bitmap.
- Runtime decision: stop consuming `rules_pattern_quads` for the `牌型介绍` example. The rules page now uses native `make_tile_view()` examples for sequence, triplet, quad, and pair/jong groups, preserving the same official tile rendering used in gameplay.
- Verification artifacts: refreshed `build/qa/pages_960x540/04_rules.png` and `build/qa/pages/04_rules.png` show native tile groups; `scripts/ui_layout_smoke_test.gd` asserts `RulesPatternQuadsTexture` is absent and the native pattern example groups exist.

## 2026-07-07 stats summary unit consistency image-demand audit

- Screenshot finding: `build/qa/pages_960x540/05_stats.png` showed the top `单局最佳` summary value without the `分` unit while the detailed row used a score unit.
- Image-demand decision: no GPT/Grok generation was needed. The issue was native label formatting and test coverage, not a bitmap-quality gap.
- Runtime decision: keep existing stats generated dashboard art unchanged. `StatsSummaryValue_best` now appends the same score unit used by the detailed `单局最佳` row.
- Verification artifacts: refreshed `build/qa/pages/05_stats.png`, `build/qa/pages_960x540/05_stats.png`, and both screenshot manifests. `scripts/ui_layout_smoke_test.gd` and `scripts/offline_smoke_test.gd` now assert the unit-bearing summary value.

## 2026-07-07 achievements row hierarchy image-demand audit

- UI-test finding: `Noether` flagged `build/qa/pages_960x540/06_achievements.png` because achievement goals, progress chips, rails, and state seals were too compressed for fast scanning.
- Image-demand decision: no GPT/Grok generation was needed. Existing achievement gallery and medal-glow art are present; the problem was native row height, text hierarchy, and lane separation.
- Runtime decision: keep current generated achievement art subdued as a backdrop. The achievement rows now use taller native cards, a local goal backplate, progress chip/rail below the goal line, and brighter state text.
- Verification artifacts: refreshed `build/qa/pages/06_achievements.png`, `build/qa/pages_960x540/06_achievements.png`, and both screenshot manifests. `scripts/ui_layout_smoke_test.gd` asserts the separated goal/progress/state lanes.
