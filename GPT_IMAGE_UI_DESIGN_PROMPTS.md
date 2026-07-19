# 国风 3D UI 页面生图 Prompts

日期：2026-07-05
设计来源：`qa/agents/ui_design_agent.md`
执行 Agent：`qa/agents/gpt_image_agent.md`
模式：GPT Image 2 / Garden Mode A prompt handoff

## 全局要求

所有页面图都必须遵守：

- 只生成背景、框体、材质、装饰层，不生成可读 UI 文案。
- 不要文字、数字、Logo、水印、真实品牌、人物脸部。
- 不要可读麻将牌面；如要生成可玩牌面，必须改用 `assets/tiles/*.png` 作为参考图执行 GPT edit。
- 主色：深墨绿、黑漆木、温润玉、暖金、少量朱砂。
- 材质：PBR 3D、漆木、玉石、锦缎、金属镶边、轻微磨损、柔和接触阴影。
- 光源：月光冷主光 + 宫灯暖边缘光，整体暗而清晰。
- UI 安全区必须低对比，方便 Godot 叠加文字、按钮、牌面和状态。

## 1. 主菜单完整背景框体

- key：`menu_lobby_gpt_scene_v2`
- 建议输出：`assets/illustrations/menu_lobby_gpt_scene_v2.png`
- 尺寸：`1280x720`
- 用途：替换/升级主菜单全屏 GPT 场景，保留标题、三主入口、快捷按钮和底栏安全区。

```text
Create a premium Chinese guofeng 3D main menu scene for a commercial mahjong mobile game, 1280x720 PNG.
Scene: an elegant indoor mahjong room with a deep jade table in the foreground, black lacquer wood frame, moon gate window, lake reflection, distant ink mountains, bamboo shadows, plum blossoms, and warm palace lanterns.
UI asset purpose: background and decorative frame only; the game engine will add title text, three main menu cards, quick action buttons, and footer status.
Composition: leave a clean title safe zone at upper left, three large low-contrast card safe zones across the middle, a thin low-contrast quick button band below the cards, and a dark footer safe zone along the bottom.
Style: high-end 3D mobile game UI, PBR jade, lacquered wood, carved gold trim, brocade texture, cinematic moonlight, soft contact shadows.
Color palette: deep ink green, black lacquer, muted teal, warm gold, small cinnabar accents.
Constraints: no words, no numbers, no logo, no watermark, no people, no readable mahjong tile faces, no hard button labels.
Avoid: procedural dots, line routes, debug-looking rectangles, bright white moon covering UI, busy center, neon sci-fi HUD, flat web-card look, beige parchment dominance.
```

## 2. 主菜单卡片框体套件

- key：`menu_card_frame_kit`
- 建议输出：`assets/illustrations/menu_card_frame_kit.png`
- 尺寸：`1536x768`
- 用途：主菜单三个入口卡片的统一 3D 框体，后续可切片或按区域叠加。

```text
Create a production-ready transparent PNG asset sheet for three premium Chinese guofeng 3D menu card frames for a mahjong mobile game, 1536x768.
Subject: three matching rectangular card frames with carved black lacquer wood, jade inlay, warm gold corner ornaments, subtle inner shadow, and clean empty centers for game-engine text and icons.
Layout: three cards side by side, equal size, generous padding between cards, each card centered in its cell. The canvas outside the frame assets must be real transparent alpha pixels only.
Style: commercial mobile game UI, PBR 3D, lacquer, jade, metal trim, soft contact shadow, restrained ornament density.
States: left card calm jade accent, middle card cool teal accent, right card warm cinnabar-gold accent; keep differences subtle.
Constraints: no words, no numbers, no logo, no watermark, no characters, no readable tile symbols, no arrows or route lines, no visible background.
Avoid: flat rectangles, glowing neon borders, procedural dots/ticks, busy interiors, Western fantasy frames, casino style, checkerboard backgrounds, dark backing plates, fake transparency.
```

## 3. 设置面板 3D 黑漆仪表盘

- key：`settings_gpt_panel_v2`
- 建议输出：`assets/illustrations/settings_gpt_panel_v2.png`
- 尺寸：`1280x720`
- 用途：设置模态面板背景与分区框体。

```text
Create a premium Chinese guofeng 3D settings panel background for a mahjong mobile game, 1280x720 PNG.
Subject: a centered black lacquer settings dashboard with jade inset panels, gold dividers, carved corner details, and subtle brocade texture.
UI safe zones: leave a clean title area top left, two large column areas for settings rows, a bottom strip for diagnostics, and a close button safe zone at top right.
Style: commercial mobile game modal UI, PBR lacquered wood, jade controls, warm gold trim, soft bevels, quiet work-focused layout.
Lighting: dark room ambience, soft lantern rim light, readable contrast on all inner panels.
Color palette: black lacquer, deep jade, muted teal, warm gold, tiny cinnabar warning accents.
Constraints: no text, no labels, no icons, no numbers, no logo, no watermark, no people.
Avoid: web form look, flat panels, bright gradients, ornamental clutter behind text areas, neon, random symbols.
```

## 4. 离线对局桌面升级背景

- key：`table_gpt_backdrop_v4`
- 建议输出：`assets/illustrations/table_gpt_backdrop_v4.png`
- 尺寸：`1280x720`
- 用途：对局桌面底图，中心低对比，边缘高质感。

```text
Create a commercial Chinese guofeng 3D mahjong battle table background, 1280x720 PNG.
Scene: top-down three-quarter view of a deep jade felt mahjong table with black lacquer wooden rails, carved gold trim, corner ornaments, subtle room depth at the edges.
UI safe zones: keep the exact center and discard river areas very low contrast for engine-rendered tiles; keep bottom hand area dark and clean; keep top HUD band readable; keep four seat side panels unobstructed.
Style: PBR 3D mobile game table, realistic material thickness, soft contact shadows, restrained guofeng ornament, premium but playable.
Color palette: deep jade felt, black lacquer, muted teal, warm gold, tiny cinnabar markers only near corners.
Constraints: no words, no logo, no watermark, no people, no readable tile faces, no dice, no random UI buttons.
Avoid: busy center texture, casino room, bright reflections under tiles, flat 2D illustration, neon lines, procedural route ticks.
```

## 5. 规则页玩法手册背景

- key：`rules_gpt_scroll_v2`
- 建议输出：`assets/illustrations/rules_gpt_scroll_v2.png`
- 尺寸：`1280x720`
- 用途：规则页背景和示例区框体。

```text
Create a Chinese guofeng 3D rules guide background for a mahjong mobile game, 1280x720 PNG.
Subject: a black lacquer framed gameplay manual with silk scroll insets, jade separators, subtle carved gold edge pieces, and a small low-contrast example table area.
UI safe zones: title area upper left, tab strip across upper center, large clean text list area in the middle, small example card safe zones on the right side, back button safe zone upper right.
Style: premium mobile game guide page, PBR lacquer, brocade, jade, warm gold, restrained museum-like clarity.
Constraints: no text, no numbers, no logo, no watermark, no people, no readable mahjong tile faces, no button labels.
Avoid: parchment dominance, dense tutorial diagrams, random icons, bright center, web article layout, neon.
```

## 6. 统计页赛后数据仪表盘

- key：`stats_gpt_dashboard_v3`
- 建议输出：`assets/illustrations/stats_gpt_dashboard_v3.png`
- 尺寸：`1280x720`
- 用途：统计页底图和数据槽位。

```text
Create a premium Chinese guofeng 3D stats dashboard background for a mahjong mobile game, 1280x720 PNG.
Subject: jade data dashboard set inside a black lacquer frame, with low-contrast empty metric slots, subtle circular win-rate medallion space, horizontal value lanes, and gold-trimmed separators.
UI safe zones: title upper left, back button upper right, three summary cards near top, six row lanes in the lower center, all areas dark enough for engine text.
Style: commercial mobile game analytics page, PBR jade, lacquer wood, brushed gold, brocade shadow, restrained high-end casino-free aesthetic.
Constraints: no text, no numbers, no chart labels, no logo, no watermark, no people, no readable tile symbols.
Avoid: actual fake charts with numbers, bright grid, sci-fi dashboard, flat spreadsheet, busy row backgrounds.
```

## 7. 成就图鉴陈列柜

- key：`achievement_gpt_gallery_v3`
- 建议输出：`assets/illustrations/achievement_gpt_gallery_v3.png`
- 尺寸：`1280x720`
- 用途：成就页背景、奖章槽位和滚动行底层。

```text
Create a premium Chinese guofeng 3D achievement gallery background for a mahjong mobile game, 1280x720 PNG.
Subject: a dark jade and black lacquer trophy gallery with carved gold frame, empty medal alcoves, subtle silk backing, and clean horizontal achievement row lanes.
UI safe zones: title upper left, progress badge area upper center, back button upper right, large scroll list area with 5-6 low-contrast row slots.
Style: high-end mobile game collection UI, PBR jade medal sockets, lacquer, warm gold trim, soft cabinet lighting, restrained details.
Constraints: no words, no numbers, no arrows, no buttons, no logo, no watermark, no people, no readable tile faces.
Avoid: generated button artifacts, fake labels, noisy medals, overdark locked areas, neon, Western trophy room style.
```

## 8. 商店宝阁和道具柜

- key：`shop_gpt_vault_v2`
- 建议输出：`assets/illustrations/shop_gpt_vault_v2.png`
- 尺寸：`1280x720`
- 用途：商店页货币区、道具行和购买区底图。

```text
Create a Chinese guofeng 3D shop vault background for a mahjong mobile game, 1280x720 PNG.
Scene: refined treasure pavilion with black lacquer shelves, jade counter, silk brocade panels, warm gold trim, and subtle charm display niches.
UI safe zones: title upper left, currency meters upper right, four to five horizontal item row lanes across the center, buy-button safe zones on the right side of each row.
Style: premium mobile game shop UI, PBR lacquer, jade, gold, soft lantern reflections, calm reward economy.
Constraints: no text, no numbers, no price tags, no logo, no watermark, no shopkeeper, no readable mahjong tile faces.
Avoid: cluttered treasure pile, casino style, bright gem overload, hard generated buttons, neon, Western fantasy market.
```

## 9. 联机大厅四席雅间

- key：`online_gpt_lobby_v3`
- 建议输出：`assets/illustrations/online_gpt_lobby_v3.png`
- 尺寸：`1280x720`
- 用途：联机大厅背景升级，左表单和右房间状态区域清晰。

```text
Create a commercial Chinese guofeng 3D online lobby background for a mahjong mobile game, 1280x720 PNG.
Scene: elegant four-seat mahjong lounge seen through a moon gate courtyard, dark jade table, black lacquer room dividers, lantern reflections, subtle network/synchronization mood expressed through architecture rather than glowing lines.
UI safe zones: title upper left, small server badge upper right, clean left form panel area, clean right room-status panel area, bottom status strip. Keep both panel interiors very low contrast.
Style: PBR 3D guofeng lobby, jade, lacquer, carved gold, cinematic moonlight, warm lantern edge light.
Constraints: no words, no numbers, no logo, no watermark, no people, no readable tile faces, no generated buttons, no route lines.
Avoid: sci-fi network grid, procedural connection dots, busy form background, bright center, flat web dashboard.
```

## 10. 每日签到锦缎奖励册

- key：`daily_login_gpt_calendar_v2`
- 建议输出：`assets/illustrations/daily_login_gpt_calendar_v2.png`
- 尺寸：`1024x768`
- 用途：每日签到弹窗背景。

```text
Create a premium Chinese guofeng 3D daily login reward calendar background for a mahjong mobile game, 1024x768 PNG.
Subject: an open silk reward ledger mounted in a black lacquer frame, jade reward slots, gold trim, subtle plum and cloud ornament at the edges.
UI safe zones: title top center, seven day node positions across the middle, progress/reward strip below, large claim button safe zone near bottom center.
Style: polished mobile game reward modal, PBR silk, jade, lacquer, warm gold, soft contact shadows, clean center.
Constraints: no words, no numbers, no logo, no watermark, no people, no readable reward labels, no readable tile faces.
Avoid: generated checkmarks, fake day numbers, busy central illustration, bright parchment dominance, Western treasure chest style.
```

## 11. 加载页月门牌墙场景

- key：`loading_scene_gpt_backdrop_v2`
- 建议输出：`assets/illustrations/loading_scene_gpt_backdrop_v2.png`
- 尺寸：`1280x720`
- 用途：加载页全屏背景，保持当前视觉标杆并提升 3D 材质。

```text
Create a premium Chinese guofeng 3D loading screen background for a mahjong mobile game, 1280x720 PNG.
Scene: moon gate garden over a calm lake, distant ink mountains, subtle stacked mahjong wall silhouettes without readable tile faces, black lacquer center plinth, warm lanterns at edges, mist and moonlight.
UI safe zones: clean dark central panel area for title and loading progress, low-contrast lower center for status text, decorative richness only at edges and upper corners.
Style: commercial mobile game loading screen, PBR lacquer and jade, cinematic moonlight, soft fog, refined gold trim.
Constraints: no words, no numbers, no logo, no watermark, no people, no readable tile symbols, no progress bar baked into the image.
Avoid: bright white flash, procedural moon overlay, busy center, casino room, neon, flat painting without 3D material.
```

## 12. 通用 3D 控件套件

- key：`guofeng_3d_control_kit`
- 建议输出：`assets/illustrations/guofeng_3d_control_kit.png`
- 尺寸：`1536x1024`
- 用途：后续替换小按钮、状态徽章、输入框和弹窗控件的统一材质参考。

```text
Create a transparent PNG UI control kit for a Chinese guofeng 3D mahjong mobile game, 1536x1024.
Include: empty button frames, small icon badge frames, input field frames, modal header plaque, status pill backgrounds, reward slot frames, divider ornaments.
Style: PBR black lacquer, jade inlay, carved warm gold trim, soft bevels, subtle brocade texture, consistent light from upper left.
Layout: clean asset sheet, each element separated with padding, no text inside any control, real transparent alpha outside every control, suitable for slicing into game UI.
Color variants: jade, teal, muted gold, cinnabar warning, slate disabled.
Constraints: no words, no numbers, no logo, no watermark, no people, no readable mahjong tile faces, no visible background.
Avoid: neon glow, flat vector UI, procedural dots/lines/ticks, random icons, cluttered ornaments, inconsistent perspective, checkerboard backgrounds, dark backing plates, fake transparency.
```

## 执行顺序建议

1. `menu_card_frame_kit` 和 `guofeng_3d_control_kit`：仅在 alpha 检查通过后替换首页控件；RGB/棋盘格候选只能作为风格参考。
2. `online_gpt_lobby_v3`：简化联机大厅输入区，去掉连接轨迹感。
3. `table_gpt_backdrop_v4`：继续提升对局 3D 商用品质，但必须保护中心牌河可读性。
4. `achievement_gpt_gallery_v3`、`shop_gpt_vault_v2`：增强元界面质感。
5. `rules_gpt_scroll_v2`、`stats_gpt_dashboard_v3`、`daily_login_gpt_calendar_v2`、`loading_scene_gpt_backdrop_v2`：逐页统一材质语言。

## 13. 主页优先 3D 入口舞台 Overlay

- key：`menu_primary_3d_stage_overlay`
- 建议输出：`assets/illustrations/menu_primary_3d_stage_overlay.png`
- 尺寸：`1280x720`
- 用途：叠加在主页背景和三张主入口卡片之间，替换代码绘制的卡片投影、舞台厚边和桌面接触阴影。

```text
Create a production-ready transparent PNG overlay for the main menu of a Chinese guofeng 3D mahjong mobile game, 1280x720.
Subject: one coherent 3D foreground stage for three large menu cards, with black lacquer table depth, soft card cast shadows, warm gold rim light, subtle jade reflections, and a grounded premium tabletop feel.
Composition: transparent canvas; only draw the stage, table lip, contact shadows, and soft light under/behind three main card slots. Leave the upper-left title plaque area, quick-button band, and bottom footer mostly empty.
Card safe zones: three empty card regions centered around x=0.24, x=0.50, x=0.76 and y=0.46; do not draw labels or icons inside them.
Integration: this is not a card-frame asset. Do not draw card borders, card interiors, glass rectangles, button shapes, icon placeholders, or visible slot outlines. Each of the three card regions must stay mostly transparent; only very soft ambient occlusion may appear under the lower edge of each future engine-rendered card. No wide translucent horizontal band across the card centers.
Style: high-end commercial 3D mobile game UI, PBR black lacquer, jade, carved warm gold trim, cinematic moonlight plus lantern rim light.
Alpha requirement: outside the stage and shadows must be real transparent alpha pixels; no checkerboard, no solid dark backing plate, no fake transparency.
Constraints: no text, no numbers, no logo, no watermark, no people, no readable mahjong tile faces, no buttons, no arrows, no route lines, no dots, no ticks.
Avoid: flat web cards, visible rectangles, procedural line art, sci-fi HUD, casino style, overly bright glow, busy ornaments under text.
```

## 14. 单机对战优先 3D 桌台 Overlay

- key：`offline_table_3d_overlay`
- 建议输出：`assets/illustrations/offline_table_3d_overlay.png`
- 尺寸：`1280x720`
- 用途：叠加在单机对战桌面 GPT 背景之上、牌和文字之下，提供真实桌边厚度、近端托盘阴影、中心绒布光照。

```text
Create a production-ready transparent PNG overlay for a Chinese guofeng 3D mahjong battle table UI, 1280x720.
Subject: realistic 3D table depth overlay: black lacquer table rails, jade felt inset shadow, near-edge thickness, subtle side-wall darkness, center soft spotlight, and contact-shadow zones where engine-rendered mahjong tiles will sit.
Composition: transparent canvas; draw only the table depth, rim highlights, soft shadows, and low-contrast material lighting. Keep the center discard river and four wall lanes clean and low contrast.
Safe zones: top HUD band y=0.02-0.10 should remain mostly transparent; bottom hand tray y=0.80-0.99 should only receive a soft grounding shadow, not a hard frame; side seat panels must remain readable.
Integration: do not generate mahjong tiles, tile backs, tile walls, placeholder tile rectangles, dice, compass marks, wind glyphs, center medallions, route graphics, progress tracks, or HUD panels. Tile lanes and discard river zones should remain transparent except for broad, low-opacity natural contact shadows. The center area must be calm felt material only; engine UI renders all wind, wall-count, discard, action-state, tile, and text information.
Style: commercial 3D mobile mahjong game, PBR jade felt, black lacquer wood, brushed gold inlay, soft contact shadows, restrained guofeng ornaments.
Alpha requirement: real transparent alpha outside overlay elements; no background image, no checkerboard, no dark rectangle behind the whole canvas.
Constraints: no text, no numbers, no logo, no watermark, no people, no readable mahjong tile faces, no dice, no buttons, no arrows, no route lines, no dots, no ticks.
Avoid: busy center patterns, bright reflections under tile faces, casino carpet, neon grid, flat 2D illustration, procedural technical overlays.
```
