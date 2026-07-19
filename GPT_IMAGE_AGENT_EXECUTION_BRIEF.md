# 国风麻将图片需求执行 Brief（完整生产版）

日期：2026-07-05
项目：`yunzhuo-mahjong-godot`
执行对象：GPT Image / 生图 Agent
优先级：人机对战页 P0，联机页 P1，通用页面资产 P2

## 目标

为当前国风麻将游戏建立一套统一、可执行、可验收的图片资产需求。生图结果用于提升页面质感，但不能替代 Godot 原生 UI 的文字、按钮、牌逻辑和交互反馈。

本轮生图的核心不是继续堆背景，而是补齐三类资产：

- 对局物理感：桌面、牌墙、手牌托盘、行动条、座位 HUD、麻将牌实体厚度。
- 联机大厅质感：四席雅间背景、表单/房间状态区域的统一 3D 材质。
- 通用材质体系：黑漆木、温润玉、锦缎、金属镶边、少量朱砂状态反馈。

## 当前页面问题和落点

本 brief 按最新截图和用户反馈制定。生图 agent 需要优先解决以下实际问题：

- 人机对战页存在多层背景覆盖感：只允许一个桌面主背景，其他资产必须是低透明、低噪声、可叠加的材质件。
- 堆牌区质感不足：牌墙需要真实堆叠厚度、背牌材质、底座阴影，以及可被程序实时驱动的剩余量反馈。
- 麻将牌偏 2D：牌面不能重画错，必须基于现有牌面做编辑，保留玩法可读性。
- 操作区和待响应区元素堆砌：行动条只提供材质底座，不要烘焙按钮、文字、图标和状态。
- 联机大厅需要统一材质：背景应服务左侧连接表单和右侧房间状态，不要生成复杂可读 UI。

## 参考输入

生图 agent 执行前必须打开这些截图作为视觉约束：

```text
build/qa/pages/03_offline_battle.png
build/qa/pages_960x540/03_offline_battle.png
build/qa/pages/08_online_lobby.png
build/qa/pages_960x540/08_online_lobby.png
```

对麻将牌编辑任务，必须使用现有牌面 PNG 作为输入参考：

```text
assets/tiles/*.png
assets/tiles/tile_back.png
assets/references/mahjong_real/tile_back_source.jpg
```

禁止只凭文本重新生成可玩牌面。所有数牌、字牌、花牌必须逐张核验。

## 全局风格规范

- 主题：商业级中国国风麻将移动游戏 UI。
- 材质：深墨绿桌毡、黑漆木、温润玉、暖金金属镶边、锦缎暗纹、轻微磨损、柔和接触阴影。
- 光源：冷月光主光 + 宫灯暖边缘光，整体暗而清晰。
- 色彩：深墨绿、黑漆、低饱和青绿、暖金、少量朱砂。避免整页单一棕橙、米黄、紫蓝、霓虹。
- 构图：中心与 UI 安全区低对比，边缘和角落负责装饰；不要让背景抢文字、麻将牌、按钮。
- 禁止：可读文字、随机数字、Logo、水印、真实品牌、人物脸部、现代科幻 HUD、霓虹线路、程序化点线、无关可读麻将牌面。
- 透明资产必须是真 alpha，不接受棋盘格烘焙图。

## 执行模式

生图前先运行：

```bash
node /root/.codex/skills/gpt-image-2/scripts/check-mode.js --json
```

如走本地 Garden 模式，使用：

```bash
ENABLE_GARDEN_IMAGEGEN=1 node /root/.codex/skills/gpt-image-2/scripts/generate.js \
  --promptfile garden-gpt-image-2/prompt/<asset-key>.md \
  --size <size> \
  --quality high
```

所有候选图先放：

```text
garden-gpt-image-2/image/candidates/
```

验收通过后再复制到：

```text
assets/illustrations/
```

不要直接覆盖稳定 PNG。需要替换时，先备份到：

```text
assets/illustrations/_replaced_20260705/
```

## 生图 agent 工作流

1. 先做 P0 人机对战页，P0 未通过前不要批量做 P1/P2。
2. 每个资产至少出 3 个候选，命名为 `<asset-key>_candidate_01.png`、`02`、`03`。
3. 透明资产必须用 alpha 检查工具确认边缘没有棋盘格、纯黑底、纯白底残留。
4. 所有候选先拼 contact sheet，人工选择后再导入 Godot。
5. 导入后必须重新截图 `03_offline_battle` 或 `08_online_lobby`，检查 UI 安全区和遮挡。
6. 任何图只要出现可读文字、随机数字、Logo、水印、错牌面，直接判废，不做局部容忍。
7. 桌面、联机背景这类整图资产只允许低对比安全区；按钮、文本、数字、麻将牌、房号全部由 Godot 渲染。

推荐产物结构：

```text
garden-gpt-image-2/
  prompt/
    p0_table_gpt_backdrop_v4.md
    p0_tiles_number_batch_01.md
    p0_wall_feedback_kit_v1.md
    p1_online_lobby_v3.md
  image/
    candidates/
      p0/
      p1/
      p2/
```

## 资产接入约定

当前代码稳定 key 和候选 vNext 的关系如下。生图 agent 只产出候选图，是否改 registry 由集成 agent 决定。

| 优先级 | 当前 key / 源文件 | 候选文件 | 页面 | 接入策略 |
|---|---|---|---|---|
| P0 | `table_gpt_backdrop` -> `assets/illustrations/table_gpt_backdrop_v3.png` | `table_gpt_backdrop_v4.png` | 人机对战 | 通过截图后改 `GPT_ILLUSTRATION_ASSET_PATHS` |
| P0 | `assets/tiles/*.png` | `assets/tiles/<same-name>_3d_candidate.png` | 人机对战 | 逐张编辑核验，不能覆盖原牌面 |
| P0 | `wall_strip_landscape.png` | `wall_strip_landscape_v2.png` | 人机对战 | 通过后改 `scripts/ui/wall_back_strip.gd` |
| P0 | `assets/tiles/tile_back.png` | `tile_back_3d.png` | 人机对战 | 通过后改背牌加载路径 |
| P0 | `hand_gpt_tray` -> `hand_gpt_tray_v3.png` | `hand_gpt_tray_v4.png` | 人机对战 | 通过截图后改 registry |
| P0 | `action_gpt_dock` -> `action_gpt_dock_v4.png` | `action_gpt_dock_v5.png` | 人机对战 | 通过截图后改 registry |
| P0 | `seat_gpt_brocade` -> `seat_gpt_brocade_v3.png` | `seat_gpt_brocade_v4.png` | 人机对战 | 通过截图后改 registry |
| P0 | 新增 | `wall_live_feedback_kit_v1.png` | 人机对战 | 程序切片/裁剪使用，用于剩余牌量反馈 |
| P1 | `online_gpt_lobby` -> `online_gpt_lobby.png` | `online_gpt_lobby_v3.png` | 联机大厅 | 通过截图后改 registry 或替换稳定图 |
| P1 | 新增 | `online_lobby_panel_kit.png` | 联机大厅 | 作为面板材质切片参考 |
| P1 | `online_feedback_gpt_strip` | `online_feedback_gpt_strip_v2.png` | 联机大厅 | 通过后改 registry |

## P0 人机对战页资产

### 1. `table_gpt_backdrop_v4.png`

- 目标路径：`assets/illustrations/table_gpt_backdrop_v4.png`
- 推荐尺寸：`1672x941` 或 `1920x1080`
- 透明要求：不透明背景
- 用途：对局桌面主背景，只保留一套桌面材质，减少多张背景互相覆盖。
- 安全区：中心、四方牌河、牌墙、底部手牌区都必须低对比。

Prompt:

```text
Create a commercial Chinese guofeng 3D mahjong battle table backdrop for a Godot mobile game.
Output: 1672x941 PNG, opaque background.
Scene: top-down three-quarter deep jade mahjong table, black lacquer wooden rails, carved warm gold trim, subtle corner ornaments, dark room depth around the outer edges.
UI safe zones: keep the center panel, four discard river areas, wall tile lanes, bottom hand tray area, and top HUD band very low contrast for engine-rendered UI and mahjong tiles.
Style: premium PBR 3D mobile game table, tactile jade felt, lacquered wood thickness, soft contact shadows, restrained Chinese guofeng ornament.
Lighting: cool moonlight over the table with warm lantern rim light on the rails.
Palette: deep jade, ink black, muted teal, warm gold, tiny cinnabar only at corners.
Constraints: no words, no numbers, no logo, no people, no readable tile faces, no dice, no random UI buttons, no baked action prompts.
Avoid: busy center texture, casino room, bright reflections under tiles, flat 2D illustration, sci-fi lines, neon grids, procedural route ticks.
```

### 2. `mahjong_tile_3d_edit_set`

- 目标路径：候选先放 `garden-gpt-image-2/image/candidates/tiles/`
- 最终路径：`assets/tiles/*.png`
- 推荐尺寸：每张 `200x280` PNG RGBA
- 透明要求：真实 alpha
- 用途：解决当前麻将牌偏 2D 的问题。
- 硬规则：必须用当前 `assets/tiles/<same file>.png` 作为编辑参考，不允许纯文本直接生成可玩牌面。

Prompt 模板：

```text
Edit the provided source mahjong tile image into a premium physical 3D guofeng mahjong tile.
Output: 200x280 transparent PNG, same canvas size and same tile identity as the source.
Preserve exactly: all tile symbols, suit count, Chinese characters, color order, placement, flower/season identity, and gameplay readability.
Improve only: ivory jade body thickness, rounded bevel, subtle side wall, bottom contact shadow, glossy porcelain face inset, warm gold rim, soft top-left highlight.
Style: realistic tactile mobile game mahjong tile, Chinese guofeng, clean front-facing orthographic view.
Constraints: no extra symbols, no added text, no changed characters, no changed suit count, no hand, no table, no background, no watermark.
Avoid: decorative reinterpretation, wrong bamboo/circle counts, altered wind or dragon glyphs, excessive perspective, cropped tile, fake transparency.
```

执行范围建议：

- 第一批只做 `tile_man1.png` 到 `tile_man9.png`、`tile_pin1.png` 到 `tile_pin9.png`、`tile_sou1.png` 到 `tile_sou9.png`。
- 第二批再做字牌、花牌、背牌。
- 每批必须输出 contact sheet 给人工核验后再导入。

### 3. `wall_strip_landscape_v2.png`

- 目标路径：`assets/illustrations/wall_strip_landscape_v2.png`
- 推荐尺寸：`1024x160`
- 透明要求：透明或透明友好，不能有棋盘格
- 用途：牌墙底座和材质参考，让牌墙区有堆叠实体感。

Prompt:

```text
Create a horizontal physical mahjong wall strip material for a Chinese guofeng mahjong game UI.
Output: 1024x160 PNG, transparent alpha outside the strip silhouette.
Subject: a long low black-lacquer and jade base for stacked mahjong backs, with warm gold inlay, subtle carved cloud corners, soft contact shadow, and dark felt underneath.
Composition: clean horizontal strip, continuous left and right edges for possible tiling, no labels, no individual readable tile faces.
Style: premium PBR 3D mobile game asset, tactile lacquer, jade, brushed gold, restrained ornament.
Palette: deep jade, ink black, muted teal, warm gold.
Constraints: no words, no numbers, no logo, no people, no checkerboard transparency preview.
Avoid: busy scroll decoration, sci-fi route lines, neon glow, flat vector strip, fake transparency.
```

### 4. `tile_back_3d.png`

- 目标路径：`assets/tiles/tile_back_3d.png`
- 推荐尺寸：`200x280`
- 透明要求：真实 alpha
- 用途：牌墙和盖牌共用背牌升级。

Prompt:

```text
Create a premium Chinese guofeng 3D mahjong tile back.
Output: 200x280 transparent PNG, centered front-facing orthographic tile.
Subject: jade-green tile back with rounded ivory side walls, carved cloud-scroll back pattern, warm gold inlay, glossy porcelain bevels, subtle bottom contact shadow.
Style: tactile mobile game asset, PBR material, clean readable silhouette.
Lighting: top-left soft highlight, right and bottom side thickness visible.
Constraints: no words, no numbers, no logo, no people, no background, no extra tile faces.
Avoid: flat 2D card, busy pattern, fake transparency, strong perspective, cropped edges.
```

### 5. `wall_live_feedback_kit_v1.png`

- 目标路径：`assets/illustrations/wall_live_feedback_kit_v1.png`
- 推荐尺寸：`1536x512`
- 透明要求：真实 alpha
- 用途：堆牌区剩余牌量的实时反馈素材套件。图片只提供状态材质，剩余数字和“余88”等文字必须由 Godot 渲染。
- 组成：4 条不同剩余量状态的细轨、4 个数量徽章底座、3 个短促更新脉冲、2 个低牌量警示角标。
- 状态：`full`、`mid`、`low`、`critical`。颜色从深玉绿到低饱和朱砂，不允许霓虹。

Prompt:

```text
Create a transparent PNG asset sheet for live wall-count feedback in a Chinese guofeng mahjong mobile game.
Output: 1536x512 transparent PNG.
Include separated assets with generous padding: four slim wall progress rails (full, mid, low, critical), four empty count badge frames, three short update pulse glows, two small low-wall warning corner accents.
Subject style: black lacquer base, jade inset, warm gold bevel, muted cinnabar only for low and critical states, soft contact shadow, tactile PBR mobile game material.
Composition: every element is empty and text-safe, no baked numbers, no labels, no icons, no tile symbols, no connected background.
Functional requirement: assets must support realtime programmatic refresh of remaining wall count; the image should make count changes feel responsive through pulse and state overlays while Godot renders all digits.
Palette: deep jade, ink black, muted teal, warm gold, restrained cinnabar warning.
Constraints: real alpha outside every element, no words, no numbers, no logo, no people, no readable tile faces, no checkerboard background.
Avoid: neon progress bars, sci-fi signal dots, busy route ticks, big decorative badges, fake transparency, baked "88" or any count text.
```

### 6. `hand_gpt_tray_v4.png`

- 目标路径：`assets/illustrations/hand_gpt_tray_v4.png`
- 推荐尺寸：`1280x260`
- 透明要求：真实 alpha
- 用途：底部手牌托盘，降低背景堆叠，突出手牌。

Prompt:

```text
Create a transparent Chinese guofeng 3D hand tray for a mahjong mobile game.
Output: 1280x260 transparent PNG.
Subject: a low black-lacquer hand shelf with jade inset, warm gold front lip, subtle brocade texture, and soft contact shadow.
Composition: upper 55 percent mostly transparent for engine-rendered mahjong tiles; ornament only on lower edge and side corners; no button shapes.
Style: premium PBR game UI asset, tactile, quiet, restrained.
Palette: black lacquer, deep jade, muted teal, warm gold.
Constraints: no words, no numbers, no logo, no people, no tile faces, real alpha outside tray.
Avoid: heavy ink wash under tile area, bright highlights behind tiles, decorative clutter, fake transparency.
```

### 7. `action_gpt_dock_v5.png`

- 目标路径：`assets/illustrations/action_gpt_dock_v5.png`
- 推荐尺寸：`1024x220`
- 透明要求：真实 alpha
- 用途：吃碰杠胡操作命令带，贴近底部手牌区域，不再像浮动拼贴卡。

Prompt:

```text
Create a compact transparent action command dock for a Chinese guofeng mahjong mobile game.
Output: 1024x220 transparent PNG.
Subject: one slim black-lacquer command band with jade button wells and warm gold bevel, designed to hold 4-7 engine-rendered action buttons.
Composition: transparent outside silhouette; button well area quiet and low contrast; no text, no icons, no separate buttons baked into the image.
Style: premium PBR mobile UI, lacquer, jade, gold trim, soft contact shadow.
Palette: deep jade, black lacquer, warm gold, tiny cinnabar warning accent.
Constraints: no words, no numbers, no logo, no people, no tile faces, no checkerboard.
Avoid: scroll tails, ribbons, procedural dots, neon, oversized decoration, crowded button slots.
```

### 8. `seat_gpt_brocade_v4.png`

- 目标路径：`assets/illustrations/seat_gpt_brocade_v4.png`
- 推荐尺寸：`768x384`
- 透明要求：真实 alpha
- 用途：四方座位 HUD，减少信息卡厚重感。

Prompt:

```text
Create a slim transparent seat HUD frame for a Chinese guofeng mahjong game.
Output: 768x384 transparent PNG.
Subject: compact black-lacquer and jade player info frame with a circular avatar opening on the left, quiet body area for name/stats, small dealer seal zone, warm gold edge.
Composition: low ornament density, generous text-safe interior, clear avatar-safe circle, transparent outside frame.
Style: premium PBR mobile game UI, tactile lacquer, jade, brocade shadow, restrained gold.
Constraints: no words, no numbers, no logo, no people, no tile faces, no fake transparency.
Avoid: large report-card feel, busy silk pattern under text, bright background, sci-fi HUD, oversized badge ornaments.
```

### 9. `pending_claim_status_strip.png`

- 目标路径：`assets/illustrations/pending_claim_status_strip.png`
- 推荐尺寸：`768x120`
- 透明要求：真实 alpha
- 用途：待响应状态条，只承载来源、牌、焦点提示，不再占据桌面主视觉。

Prompt:

```text
Create a compact transparent pending-claim status strip for a Chinese guofeng mahjong game.
Output: 768x120 transparent PNG.
Subject: slim jade and black-lacquer strip with a small source seal area, a tiny tile preview well, and a clean text-safe lane.
Composition: horizontal, low height, transparent outside silhouette, no button wells, no baked labels.
Style: premium PBR guofeng UI, soft gold rim, subtle ink mist, tactile material.
Constraints: no words, no numbers, no logo, no people, no readable tile symbols, no checkerboard.
Avoid: large banner, silk clutter, route lines, sparks everywhere, neon.
```

## P1 联机大厅资产

### 10. `online_gpt_lobby_v3.png`

- 目标路径：`assets/illustrations/online_gpt_lobby_v3.png`
- 推荐尺寸：`1280x720`
- 透明要求：不透明背景
- 用途：联机大厅背景，左连接表单和右房间状态区需要清晰。

Prompt:

```text
Create a commercial Chinese guofeng 3D online lobby background for a mahjong mobile game.
Output: 1280x720 PNG, opaque background.
Scene: elegant four-seat mahjong lounge seen through a moon gate courtyard, dark jade table, black lacquer room dividers, lantern reflections, subtle architectural rhythm showing online synchronization without sci-fi lines.
UI safe zones: title upper left, server/status badges upper right, clean left form panel area, clean right room-status panel area, bottom status strip. Keep both panel interiors low contrast.
Style: PBR 3D guofeng lobby, jade, lacquer, carved gold, cinematic moonlight, warm lantern edge light.
Palette: deep jade, ink black, muted teal, warm gold, tiny cinnabar.
Constraints: no words, no numbers, no logo, no people, no readable tile faces, no generated buttons, no route lines.
Avoid: sci-fi network grid, procedural connection dots, busy form background, bright center, flat web dashboard.
```

### 11. `online_lobby_panel_kit.png`

- 目标路径：`assets/illustrations/online_lobby_panel_kit.png`
- 推荐尺寸：`1536x1024`
- 透明要求：真实 alpha
- 用途：联机页表单框、房间状态框、玩家槽、状态徽章的统一材质套件。

Prompt:

```text
Create a transparent PNG asset sheet for Chinese guofeng online lobby UI panels in a mahjong mobile game.
Output: 1536x1024 transparent PNG.
Include: one large form panel frame, one large room-status panel frame, four small player slot frames, two status pill frames, one bottom feedback strip, one small room-number plaque.
Style: premium PBR black lacquer, jade inlay, warm gold bevel, subtle brocade texture, consistent top-left lighting.
Layout: each element separated with padding, transparent outside every element, no text inside any control.
Palette: deep jade, black lacquer, muted teal, warm gold, tiny cinnabar for warning state.
Constraints: no words, no numbers, no logo, no people, no tile faces, no checkerboard background.
Avoid: flat web forms, random icons, bright input fields, sci-fi network lines, inconsistent perspective.
```

### 12. `online_feedback_gpt_strip_v2.png`

- 目标路径：`assets/illustrations/online_feedback_gpt_strip_v2.png`
- 推荐尺寸：`1024x160`
- 透明要求：真实 alpha
- 用途：联机反馈条，表现“等待服务器/确认/失败”的状态底座。

Prompt:

```text
Create a compact transparent online feedback strip for a Chinese guofeng mahjong game.
Output: 1024x160 transparent PNG.
Subject: slim black-lacquer status strip with jade signal well, gold response gate, subtle ink mist, and quiet text-safe center.
Composition: low height, transparent outside silhouette, one left status seal area, one long message lane, one right confirmation node.
Style: premium PBR guofeng UI, restrained glow, tactile material.
Constraints: no words, no numbers, no logo, no people, no icons, no tile faces.
Avoid: sci-fi network grid, blinking dot patterns, neon blue, busy center, fake transparency.
```

## P2 通用页面和功能资产

### 13. `top_hud_gpt_banner_v3.png`

- 目标路径：`assets/illustrations/top_hud_gpt_banner_v3.png`
- 推荐尺寸：`1280x160`
- 透明要求：真实 alpha
- 用途：通用顶部 HUD，单机/联机均可复用。

Prompt:

```text
Create a transparent top HUD banner for a Chinese guofeng mahjong mobile game.
Output: 1280x160 transparent PNG.
Subject: long thin black-lacquer and jade header band with carved gold corners, quiet title/status lanes, and three control-button safe wells on the right.
Style: premium PBR mobile UI, lacquer, jade, gold, subtle brocade shadow.
Constraints: no words, no numbers, no logo, no icons, no people, no tile faces.
Avoid: heavy ornament in text lanes, bright highlights, fake buttons with labels, neon, fake transparency.
```

### 14. `settings_gpt_panel_v3.png`

- 目标路径：`assets/illustrations/settings_gpt_panel_v3.png`
- 推荐尺寸：`1280x720`
- 透明要求：不透明或 dark backing
- 用途：设置页 modal 背板。

Prompt:

```text
Create a premium Chinese guofeng 3D settings panel background for a mahjong mobile game.
Output: 1280x720 PNG.
Subject: centered black-lacquer settings dashboard with jade inset panels, gold dividers, carved corners, and subtle brocade texture.
UI safe zones: title top left, close button top right, two column setting rows, bottom diagnostics strip. All interiors dark and text-safe.
Style: commercial mobile game modal UI, PBR lacquered wood, jade controls, warm gold trim, quiet work-focused layout.
Constraints: no text, no labels, no icons, no numbers, no logo, no people.
Avoid: web form look, flat panels, bright gradients, ornamental clutter behind rows, neon.
```

### 15. `menu_lobby_gpt_scene_v3.png`

- 目标路径：`assets/illustrations/menu_lobby_gpt_scene_v3.png`
- 推荐尺寸：`1280x720`
- 透明要求：不透明背景
- 用途：主菜单背景，当前不是第一优先，但应和对战页同材质。

Prompt:

```text
Create a premium Chinese guofeng 3D main menu scene for a commercial mahjong mobile game.
Output: 1280x720 PNG.
Scene: elegant indoor mahjong room with deep jade table foreground, black lacquer frame, moon gate window, lake reflection, distant ink mountains, bamboo shadows, plum blossoms, warm palace lanterns.
UI safe zones: title upper left, three large menu-card safe zones across the middle, quick button band below, dark footer strip.
Style: PBR jade, lacquered wood, carved gold trim, cinematic moonlight, soft contact shadows.
Constraints: no words, no numbers, no logo, no people, no readable tile faces, no hard button labels.
Avoid: busy center, neon, flat web-card look, beige parchment dominance.
```

### 16. `win_result_stage_v2.png`

- 目标路径：`assets/illustrations/win_result_stage_v2.png`
- 推荐尺寸：`1280x720`
- 透明要求：不透明背景
- 用途：胜负结算页统一舞台。

Prompt:

```text
Create a Chinese guofeng victory result stage background for a mahjong mobile game.
Output: 1280x720 PNG.
Scene: moon gate, distant ink mountains, silk brocade frame, subtle gold celebration, dark jade stage.
UI safe zones: clean central area for score and fan details, decorative detail at edges only.
Style: premium mobile game UI illustration, PBR lacquer and jade, refined brocade texture, warm gold.
Constraints: no words, no numbers, no logo, no people, no readable symbols.
Avoid: fireworks clutter, western casino style, beige parchment dominance, neon.
```

### 17. `guofeng_3d_control_kit_v2.png`

- 目标路径：`assets/illustrations/guofeng_3d_control_kit_v2.png`
- 推荐尺寸：`1536x1024`
- 透明要求：真实 alpha
- 用途：后续替换小按钮、徽章、输入框、状态 pill 的统一材质参考。

Prompt:

```text
Create a transparent PNG UI control kit for a Chinese guofeng 3D mahjong mobile game.
Output: 1536x1024 transparent PNG.
Include: empty button frames, small icon badge frames, input field frames, modal header plaque, status pill backgrounds, reward slot frames, divider ornaments.
Style: PBR black lacquer, jade inlay, carved warm gold trim, soft bevels, subtle brocade texture, consistent light from upper left.
Layout: clean asset sheet, each element separated with padding, no text inside any control, real transparent alpha outside every control.
Color variants: jade, teal, muted gold, cinnabar warning, slate disabled.
Constraints: no words, no numbers, no logo, no people, no readable tile faces, no visible background.
Avoid: neon glow, flat vector UI, procedural dots/lines/ticks, random icons, cluttered ornaments, inconsistent perspective, fake transparency.
```

## 批次执行顺序

1. P0-1：先生成 `table_gpt_backdrop_v4.png`，用截图确认桌面不再多背景覆盖。
2. P0-2：生成 `mahjong_tile_3d_edit_set` 的数牌第一批，人工核验玩法可读性。
3. P0-3：生成 `wall_strip_landscape_v2.png`、`tile_back_3d.png`、`wall_live_feedback_kit_v1.png`，检查牌墙实体感和剩余牌量刷新反馈。
4. P0-4：生成 `hand_gpt_tray_v4.png`、`action_gpt_dock_v5.png`、`seat_gpt_brocade_v4.png`、`pending_claim_status_strip.png`，检查是否减少堆砌。
5. P1：生成 `online_gpt_lobby_v3.png`、`online_lobby_panel_kit.png`、`online_feedback_gpt_strip_v2.png`，检查左表单/右房间状态是否清楚。
6. P2：再处理顶部 HUD、设置、菜单、胜利舞台和通用控件套件。

## 验收清单

- 文件尺寸符合 brief，不低于推荐尺寸。
- 透明资产有真实 alpha，不能有棋盘格烘焙。
- 无文字、无数字、无 Logo、水印、人物脸、随机牌面。
- UI 安全区低对比，文本和牌面覆盖后清晰。
- 风格统一：黑漆、玉、金、锦缎、月光/宫灯，不是现代科幻 HUD。
- 对战页资产不能造成新的背景叠层；优先一个主背景 + 少量透明材质件。
- 牌墙剩余量反馈必须拆成可程序驱动的透明状态件；图片里不能烘焙任何剩余数字。
- 牌面资产必须逐张核验，不允许错花色、错数量、错字牌。
- 生成后提供 contact sheet 和单图预览，不直接覆盖稳定图。

## 交付记录格式

生图 agent 每批交付时写入报告：

```markdown
## Batch <N>

- Mode: A / B / C
- Prompt files:
  - `garden-gpt-image-2/prompt/<asset-key>.md`
- Candidate files:
  - `garden-gpt-image-2/image/candidates/<asset-key>_candidate_01.png`
- Passed:
  - `<asset-key>`: yes/no, reason
- Needs code integration:
  - `<asset-key>` -> `GPT_ILLUSTRATION_ASSET_PATHS` key or existing key replacement
- Notes:
  - Any issue with alpha, text artifacts, safe zones, tile readability, style mismatch.
```
