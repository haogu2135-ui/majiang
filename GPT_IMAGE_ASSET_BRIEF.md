# GPT 插画资产生成规格

本项目的游戏插画需要由 GPT 生图生成后落盘到 `assets/illustrations/`，不要再通过 `scripts/generate_illustration_assets.py` 生成新增 PNG。

这些 GPT 图片通过 `GPT_ILLUSTRATION_ASSET_PATHS` 作为可选资源加载：文件未生成时游戏继续使用现有 UI，文件放入指定路径后会自动加载并叠加到对应界面。

## 全局风格

- 国风麻将 UI 插画，深墨绿、温润玉色、金箔点缀、少量朱砂警示色。
- 画面用于 Godot UI 叠加，主体清晰，边缘留足安全边距。
- 不要包含文字、Logo、水印、真实品牌、复杂人物脸部。
- 背景不要纯透明，使用暗色水墨底，便于在 UI 面板低透明度叠加。
- 输出 PNG，RGBA 或普通 RGB 均可；项目会以 `TextureRect` 半透明叠加使用。

## 待生成资产

### 1. `menu_hero_gpt_backdrop.png`

- 保存路径：`assets/illustrations/menu_hero_gpt_backdrop.png`
- 推荐尺寸：`1280x960`
- 用途：主菜单 Hero 背景的 GPT 生图增强层，会叠加在现有 `menu_hero_painting.png` 和原生桌面/牌面装饰之下。
- 构图：右侧主视觉空间，水墨庭院/月门/湖面，中央下方给圆桌和麻将牌留干净空间。
- 视觉元素：远山、月门、湖面、竹影、少量金箔、轻薄云纹。
- 避免：文字、具体 UI 按钮、人物、过亮背景、和现有桌面牌面冲突的复杂中心主体。

Prompt:

```text
Create a premium Chinese guofeng main menu hero backdrop for a mahjong mobile game.
Asset type: reusable PNG overlay, 1280x960.
Scene/backdrop: moon gate garden, distant ink mountains, calm jade lake, bamboo shadows and subtle silk texture.
Subject: elegant atmospheric background only, leaving a clean lower-center area for a circular mahjong table and three tile UI elements added by the game engine.
Style/medium: polished mobile game UI illustration, Chinese ink wash, refined brocade detail, soft gold foil accents.
Composition/framing: right-side hero visual, generous safe padding, no text, no buttons, no characters, low-contrast central play space.
Lighting/mood: calm, premium, evening moonlight, warm gold highlights.
Color palette: deep jade, ink black, muted teal, warm gold, very small cinnabar accents.
Constraints: no words, no logo, no watermark, no people, no readable tile symbols, no hard UI controls.
Avoid: busy center composition, photorealistic casino table, western fantasy style, neon, beige parchment dominance.
```

### 2. `loading_scene_gpt_backdrop.png`

- 保存路径：`assets/illustrations/loading_scene_gpt_backdrop.png`
- 推荐尺寸：`1280x720`
- 用途：加载页整屏背景增强层，会叠加在现有 `loading_gate.png` 上方、原生远山/月亮/中心面板下方。
- 构图：月门、牌墙剪影、远山水面，中央给加载面板保留低对比空间。
- 视觉元素：水墨月门、湖面反光、牌阵剪影、薄雾、少量金箔光点。
- 避免：文字、进度条、按钮、Logo、人物、过亮背景。

Prompt:

```text
Create a Chinese guofeng loading screen backdrop for a mahjong mobile game.
Asset type: reusable PNG overlay, 1280x720.
Scene/backdrop: moon gate garden, distant ink mountains, calm water reflection, subtle mahjong wall silhouettes and mist.
Subject: atmospheric loading background only, with a clean central area reserved for the game engine's title, loading text, and shuffle UI.
Style/medium: polished mobile game UI background, Chinese ink wash, soft silk texture, restrained gold foil specks.
Composition/framing: full-screen landscape, dark low-contrast center, decorative detail at edges and upper corners, no text.
Lighting/mood: calm first-load moment, moonlit, premium, quiet.
Color palette: deep jade black, muted teal, ink gray, warm gold highlights.
Constraints: no words, no logo, no watermark, no characters, no readable tile symbols, no progress bar.
Avoid: busy center, bright white flash, sci-fi neon, photorealistic casino room, beige parchment dominance.
```

### 3. `daily_login_gpt_calendar.png`

- 保存路径：`assets/illustrations/daily_login_gpt_calendar.png`
- 推荐尺寸：`1024x768`
- 用途：每日签到面板的 GPT 生图增强层，会叠加在现有 `daily_calendar.png` 之上、签到节点和奖励 UI 之下。
- 构图：七日签到册、卷轴边框、奖励路线，中心区域保持低对比，方便 Godot 原生签到节点覆盖。
- 视觉元素：锦缎册页、玉色进度线、金色奖励印章、淡梅枝、轻薄云纹。
- 避免：文字、数字、具体按钮、可读日期、人物、过亮背景。

Prompt:

```text
Create a Chinese guofeng daily login calendar backdrop for a mahjong mobile game.
Asset type: reusable PNG overlay, 1024x768.
Scene/backdrop: open silk ledger and scroll frame with seven subtle reward positions, jade progress trail, plum branch accents, and soft cloud motifs.
Subject: decorative calendar background only, leaving clean space for the game engine's seven day nodes, reward text, and claim button.
Style/medium: premium mobile game UI illustration, Chinese ink wash, brocade texture, refined gold foil accents.
Composition/framing: centered panel-friendly composition, low-contrast middle, decorative detail at borders and corners, no text.
Lighting/mood: welcoming daily reward moment, warm but restrained.
Color palette: deep jade, ink black, muted teal, warm gold, small cinnabar accents.
Constraints: no words, no numbers, no logo, no watermark, no characters, no readable calendar labels.
Avoid: busy center, hard button shapes, bright neon, beige parchment dominance, western fantasy reward chest.
```

### 4. `shop_gpt_vault.png`

- 保存路径：`assets/illustrations/shop_gpt_vault.png`
- 推荐尺寸：`1280x720`
- 用途：商店页主面板的 GPT 生图增强层，会叠加在现有 `shop_vault.png` 之上、货币面板和道具列表之下。
- 构图：国风宝阁/货架背景，顶部留给货币，中央和下方留给道具行列表。
- 视觉元素：玉石柜台、锦缎货架、金色价格轨迹、卷轴式陈列、少量宝石光点。
- 避免：文字、价格数字、按钮、人物、真实品牌、过亮珠宝堆。

Prompt:

```text
Create a Chinese guofeng shop vault backdrop for a mahjong mobile game.
Asset type: reusable PNG overlay, 1280x720.
Scene/backdrop: refined treasure pavilion and item shelf, jade counter, silk brocade panels, subtle gold transaction routes, small gem highlights.
Subject: decorative shop background only, leaving clean top space for currency panels and clean middle/lower space for item rows and buy buttons added by the game engine.
Style/medium: premium mobile game UI illustration, Chinese ink wash with brocade texture, polished but restrained.
Composition/framing: full panel background, low-contrast central list area, richer decoration near edges and corners, no text.
Lighting/mood: elegant marketplace, calm premium reward economy.
Color palette: deep jade black, muted teal, warm gold, small amethyst gem accents, restrained cinnabar.
Constraints: no words, no numbers, no logo, no watermark, no characters, no readable price tags, no button labels.
Avoid: cluttered treasure pile, casino style, bright neon, western fantasy shopkeeper, beige parchment dominance.
```

### 5. `claim_response_trail.png`

- 保存路径：`assets/illustrations/claim_response_trail.png`
- 推荐尺寸：`1024x288`
- 用途：待响应提示面板、吃碰杠选择阶段的响应轨道底图。
- 构图：横向丝绸/水墨轨道，从左侧弃牌源点流向右侧响应门，包含 3 到 4 个发光节点。
- 视觉元素：玉色光环、金色细线、轻薄云纹、丝绸纹理、低对比水墨底。
- 避免：文字、麻将牌具体牌面、按钮样式、强烈高饱和背景。

Prompt:

```text
Create a horizontal Chinese ink-wash game UI illustration for a mahjong claim response panel.
Asset type: reusable PNG overlay, 1024x288.
Scene/backdrop: dark jade ink-wash background with subtle silk texture.
Subject: a flowing response trail from a left source seal to a right decision gate, with 3-4 softly glowing jade and gold nodes along the route.
Style/medium: polished Chinese guofeng game UI illustration, painterly ink wash, gold foil accents, refined mobile game asset.
Composition/framing: wide horizontal banner, generous safe padding, readable at small UI size, no text.
Lighting/mood: calm but urgent response moment, soft jade glow and restrained gold highlights.
Color palette: deep ink green, jade, muted teal, warm gold, tiny cinnabar accents only.
Constraints: no words, no logo, no watermark, no characters, no photorealistic people, no hard button labels.
Avoid: clutter, bright neon, western fantasy style, heavy gradients, pure black empty areas.
```

### 6. `discard_splash_wash.png`

- 保存路径：`assets/illustrations/discard_splash_wash.png`
- 推荐尺寸：`768x768`
- 用途：弃牌飞行动画落点、水墨水花/涟漪底纹。
- 构图：中心落点向外扩散的水墨涟漪，少量金色碎光，适合圆形或方形裁切。
- 视觉元素：墨滴、涟漪、轻微玉色水面反光、金箔微粒。
- 避免：文字、明显真实水花照片、强烈白色闪爆、复杂背景。

Prompt:

```text
Create a square Chinese ink-wash splash illustration for a mahjong discard landing effect.
Asset type: reusable PNG overlay, 768x768.
Scene/backdrop: dark jade tabletop water-ink surface.
Subject: a centered ink splash and expanding circular ripple, with small gold foil sparks around the impact point.
Style/medium: polished guofeng game VFX texture, painterly ink wash, soft alpha-friendly edges, refined mobile game effect.
Composition/framing: centered splash, circular readable silhouette, generous padding, works when scaled down to 64-96 px.
Lighting/mood: quick tactile discard impact, elegant not explosive.
Color palette: deep green-black ink, muted teal ripple, warm gold highlights.
Constraints: no words, no logo, no watermark, no tile symbols, no photorealistic water photo.
Avoid: overexposed white flash, noisy particles, busy background, sci-fi neon.
```

### 7. `win_result_stage.png`

- 保存路径：`assets/illustrations/win_result_stage.png`
- 推荐尺寸：`1280x720`
- 用途：胡牌结算背景的 GPT 生图替换候选。
- 构图：中央留空放分数与番型，外围是月门、金箔、锦缎和淡水墨山影。
- 视觉元素：胜利徽章空间、卷轴层次、金色放射纹但保持低对比。
- 避免：文字、人物、具体牌面、过亮烟花。

Prompt:

```text
Create a Chinese guofeng victory result stage background for a mahjong mobile game.
Asset type: 1280x720 PNG background overlay.
Scene/backdrop: moon gate, distant ink mountains, silk brocade frame, subtle gold foil celebration.
Subject: elegant empty central stage for score text and fan details, with decorative laurel-like gold accents around the edges.
Style/medium: premium mobile game UI illustration, Chinese ink wash plus refined brocade texture.
Composition/framing: central area clean and low contrast, decorative detail concentrated at edges, safe margins for UI text.
Lighting/mood: triumphant, warm, calm, polished.
Color palette: deep jade, ink black, muted teal, warm gold, small cinnabar accents.
Constraints: no words, no logo, no watermark, no people, no readable symbols.
Avoid: fireworks clutter, western casino style, beige parchment dominance, one-note purple/blue palette.
```

### 8. `rules_gpt_scroll.png`

- 保存路径：`assets/illustrations/rules_gpt_scroll.png`
- 推荐尺寸：`1280x720`
- 用途：规则页底纹增强层，会叠加在现有 `rules_scroll.png` 和原生规则文本/示例图之下。
- 构图：横向规则卷轴、牌型路线和淡水墨牌桌提示，左上标题区、中央规则段落区和右下示例区保持低对比。
- 视觉元素：卷轴边框、玉色流程线、吃碰杠胡的抽象节点、淡金箔、轻薄云纹。
- 避免：文字、数字、可读麻将牌面、按钮、人物、过亮背景。

Prompt:

```text
Create a Chinese guofeng rules guide scroll backdrop for a mahjong mobile game.
Asset type: reusable PNG overlay, 1280x720.
Scene/backdrop: dark jade ink-wash rule scroll, subtle mahjong table geometry, silk brocade border, soft cloud motifs and refined gold foil accents.
Subject: decorative rules page background only, with abstract route nodes for learning hand structure and player actions, leaving clean areas for game-engine text, examples, and buttons.
Style/medium: premium mobile game UI illustration, Chinese ink wash, polished brocade texture, restrained gold detailing.
Composition/framing: full panel landscape, low-contrast title area at upper left, clean central content area, subtle example-art space at lower right, generous safe padding, no text.
Lighting/mood: clear tutorial reading moment, calm, elegant, focused.
Color palette: deep jade, ink black, muted teal, warm gold, very small cinnabar accents.
Constraints: no words, no numbers, no logo, no watermark, no people, no readable tile symbols, no button labels.
Avoid: busy center, bright parchment dominance, photorealistic casino table, western fantasy style, neon, hard UI controls.
```

### 9. `stats_gpt_dashboard.png`

- 保存路径：`assets/illustrations/stats_gpt_dashboard.png`
- 推荐尺寸：`1280x720`
- 用途：统计页仪表盘底纹增强层，会叠加在现有 `stats_chart.png` 和原生统计卡片/行项目之下。
- 构图：横向数据仪表盘、胜率环、趋势路线和战绩卷轴，顶部标题区、中央仪表盘区、下方统计行区域保持低对比。
- 视觉元素：玉色数据环、金色趋势线、锦缎网格、淡水墨山影、少量节点光点。
- 避免：文字、数字、真实图表标签、按钮、人物、过亮背景。

Prompt:

```text
Create a Chinese guofeng statistics dashboard backdrop for a mahjong mobile game.
Asset type: reusable PNG overlay, 1280x720.
Scene/backdrop: dark jade ink-wash dashboard with silk brocade grid, subtle scroll frame, faint mountain wash, and refined gold foil data routes.
Subject: decorative statistics background only, with abstract win-rate ring shapes, trend route lines, score medal space, and small jade/gold metric nodes.
Style/medium: premium mobile game UI illustration, Chinese ink wash, polished brocade texture, restrained data-visualization motifs.
Composition/framing: full panel landscape, low-contrast upper title area, clean central dashboard area, clean lower rows area for game-engine metric text and progress rails, generous safe padding.
Lighting/mood: focused progression review, calm, refined, analytical but still guofeng.
Color palette: deep jade, ink black, muted teal, warm gold, very small cinnabar accents.
Constraints: no words, no numbers, no logo, no watermark, no people, no readable chart labels, no hard UI buttons.
Avoid: bright business chart look, neon cyberpunk, cluttered center, beige parchment dominance, western casino style.
```

### 10. `achievement_gpt_gallery.png`

- 保存路径：`assets/illustrations/achievement_gpt_gallery.png`
- 推荐尺寸：`1280x720`
- 用途：成就页图鉴底纹增强层，会叠加在现有 `achievement_medal_glow.png` 和原生成就仪表盘/成就行之下。
- 构图：奖章墙、图鉴卷轴和解锁路线，顶部标题区、中央进度仪表盘区、下方两列成就列表区保持低对比。
- 视觉元素：金色奖章光晕、玉色解锁路径、锦缎展示架、半透明锁形纹样、少量朱砂印记。
- 避免：文字、数字、具体奖章标题、按钮、人物、过亮奖杯堆。

Prompt:

```text
Create a Chinese guofeng achievement gallery backdrop for a mahjong mobile game.
Asset type: reusable PNG overlay, 1280x720.
Scene/backdrop: dark jade achievement archive, silk brocade display wall, subtle scroll frame, soft medal glow, and refined gold foil unlock routes.
Subject: decorative achievement screen background only, with abstract medal spaces, locked/unlocked route motifs, jade progress nodes, and gentle archive lighting.
Style/medium: premium mobile game UI illustration, Chinese ink wash, polished brocade texture, restrained gold medal accents.
Composition/framing: full panel landscape, low-contrast upper title area, clean central progress dashboard area, clean lower two-column list area for game-engine achievement rows, generous safe padding.
Lighting/mood: celebratory but calm, collection archive, premium progression.
Color palette: deep jade, ink black, muted teal, warm gold, subtle cinnabar seal accents.
Constraints: no words, no numbers, no logo, no watermark, no people, no readable achievement names, no hard UI buttons.
Avoid: cluttered trophy pile, bright casino gold, western fantasy armory, neon, beige parchment dominance.
```

### 11. `online_gpt_lobby.png`

- 保存路径：`assets/illustrations/online_gpt_lobby.png`
- 推荐尺寸：`1280x720`
- 用途：联机大厅网络底纹增强层，会叠加在现有 `online_network.png` 和原生连接表单/房间状态/日志面板之下。
- 构图：左侧连接表单区域、右侧房间状态和日志区域都保持低对比，中上部可有网络月门和玩家座位连接线。
- 视觉元素：玉色网络节点、金色握手路线、四席同步光点、锦缎扇面、远山水墨和轻薄云纹。
- 避免：文字、IP 地址、房间号、按钮标签、人物脸部、强发光科技网格。

Prompt:

```text
Create a Chinese guofeng online lobby backdrop for a mahjong mobile game.
Asset type: reusable PNG overlay, 1280x720.
Scene/backdrop: dark jade ink-wash network lobby, moon gate communication hub, subtle four-seat mahjong room layout, silk brocade fan accents, distant mountain wash.
Subject: decorative online lobby background only, with abstract connection nodes, handshake routes, room sync paths, and gentle jade/gold signal glows.
Style/medium: premium mobile game UI illustration, Chinese ink wash, polished brocade texture, restrained network visualization motifs.
Composition/framing: full panel landscape, clean low-contrast left area for connection form fields, clean right area for room status and log panels, decorative network detail near upper center and edges, generous safe padding.
Lighting/mood: calm connection setup, reliable, elegant, social tabletop atmosphere.
Color palette: deep jade, ink black, muted teal, warm gold, tiny cinnabar status accents.
Constraints: no words, no numbers, no IP addresses, no room codes, no logo, no watermark, no people, no readable tile symbols, no hard UI buttons.
Avoid: sci-fi neon grid, cluttered wires, bright casino room, western tech dashboard, beige parchment dominance.
```

### 12. `settings_gpt_panel.png`

- 保存路径：`assets/illustrations/settings_gpt_panel.png`
- 推荐尺寸：`1024x768`
- 用途：设置面板底纹增强层，会叠加在现有 `settings_compass.png` 和原生开关/按钮/分区控件之下。
- 构图：顶部罗盘和系统总线，中部三组设置分区，底部维护操作区域都保持低对比。
- 视觉元素：玉色罗盘、锦缎分区框、金色控制线路、音频波纹、维护印章和淡水墨底。
- 避免：文字、开关状态文字、按钮标签、真实齿轮 Logo、人物、过亮中心。

Prompt:

```text
Create a Chinese guofeng settings panel backdrop for a mahjong mobile game.
Asset type: reusable PNG overlay, 1024x768.
Scene/backdrop: dark jade settings control panel, subtle compass motif, silk brocade section frames, faint audio wave lines, maintenance seal accents, and soft ink-wash texture.
Subject: decorative settings panel background only, with abstract system routes, toggle paths, sound-control ripples, and maintenance nodes.
Style/medium: premium mobile game UI illustration, Chinese ink wash, polished brocade texture, restrained gold control-line accents.
Composition/framing: vertical modal-friendly panel, low-contrast top title area, clean middle sections for toggles and controls, clean lower area for maintenance buttons, generous safe padding.
Lighting/mood: calm configuration surface, precise, elegant, readable.
Color palette: deep jade, ink black, muted teal, warm gold, subtle cinnabar maintenance accents.
Constraints: no words, no numbers, no logo, no watermark, no people, no readable switch labels, no hard UI buttons.
Avoid: bright dashboard glare, neon tech style, cluttered center, beige parchment dominance, photorealistic hardware controls.
```

### 13. `table_gpt_backdrop.png`

- 保存路径：`assets/illustrations/table_gpt_backdrop.png`
- 推荐尺寸：`1280x720`
- 用途：对局内牌桌氛围底纹增强层，会叠加在现有 `table_ink_wash.png` 和 Godot 原生牌墙/弃牌/中心区之下。
- 构图：中央牌局区域、四边座位和弃牌河区域都保持低对比，细节集中在角落和桌面外缘。
- 视觉元素：深玉色毛毡、水墨涟漪、竹影、金色回纹边线、淡淡月门倒影、少量梅花或金箔颗粒。
- 避免：可读麻将牌面、文字、数字、按钮、人物、亮色中心图案、真实赌场桌。

Prompt:

```text
Create a Chinese guofeng mahjong table backdrop for the live gameplay screen of a mobile game.
Asset type: reusable PNG overlay, 1280x720.
Scene/backdrop: dark jade felt tabletop, subtle ink-wash ripples, bamboo shadow edges, refined gold corner ornaments, faint moon-gate reflection, and soft brocade texture.
Subject: atmospheric table surface only, leaving clean low-contrast space for the game engine's tile walls, discards, center wind marker, seats, hand tray, and action buttons.
Style/medium: premium mobile game table illustration, Chinese ink wash, tactile felt texture, restrained gold foil accents.
Composition/framing: full landscape table layer, quiet center play area, quiet four-side discard and wall zones, richer detail only near corners and outer edges, generous safe padding.
Lighting/mood: focused live match, calm, elegant, readable, premium tabletop atmosphere.
Color palette: deep jade, ink black, muted teal, warm gold, tiny cinnabar accents.
Constraints: no words, no numbers, no logo, no watermark, no people, no readable mahjong tile symbols, no hard UI controls.
Avoid: bright central emblem, cluttered tabletop, photorealistic casino room, neon, beige parchment dominance, western fantasy board.
```

### 14. `hand_gpt_tray.png`

- 保存路径：`assets/illustrations/hand_gpt_tray.png`
- 推荐尺寸：`1280x360`
- 用途：对局内手牌托盘底纹增强层，会叠加在手牌托盘面板底部、Godot 原生手牌按钮/状态徽章/新手提示之下。
- 构图：横向低矮托盘，顶部状态栏、中央手牌按钮区、下方路线提示区都保持干净低对比。
- 视觉元素：深玉锦缎托盘、金色细线、玉色出牌路线、淡水墨牌槽、轻薄云纹和少量朱砂警示点。
- 避免：具体麻将牌面、文字、数字、按钮形状、人物、强亮边框。

Prompt:

```text
Create a Chinese guofeng hand tray backdrop for the live gameplay screen of a mahjong mobile game.
Asset type: reusable PNG overlay, 1280x360.
Scene/backdrop: dark jade silk hand tray, subtle brocade texture, soft ink-wash tile slots, restrained gold guide lines, jade discard-route glow, faint cloud motifs.
Subject: decorative hand-area background only, leaving clean low-contrast space for the game engine's hand tile buttons, state badge, tutorial hint, and action route overlays.
Style/medium: premium mobile game UI illustration, Chinese ink wash, tactile brocade and felt texture, refined gold foil accents.
Composition/framing: wide horizontal tray, clean upper status strip, clean central tile row area, clean lower guidance route area, richer detail near side edges only, generous safe padding.
Lighting/mood: focused decision surface, calm, readable, elegant.
Color palette: deep jade, ink black, muted teal, warm gold, tiny cinnabar warning accents.
Constraints: no words, no numbers, no logo, no watermark, no people, no readable mahjong tile symbols, no hard UI buttons.
Avoid: bright tile drawings, cluttered center, thick ornamental borders, photorealistic casino table, neon, beige parchment dominance.
```

### 15. `action_gpt_dock.png`

- 保存路径：`assets/illustrations/action_gpt_dock.png`
- 推荐尺寸：`1024x256`
- 用途：对局内操作按钮栏底纹增强层，会叠加在 `ActionButtonDock` 底部、Godot 原生吃碰杠胡/过按钮之下。
- 构图：横向低矮命令托盘，中央按钮区域保持干净，左右尾部可有卷轴或丝带收口。
- 视觉元素：深玉色命令底座、金色执行路线、玉色决策节点、锦缎丝带、轻微朱砂响应提示点。
- 避免：文字、操作标签、具体按钮形状、麻将牌面、人物、强烈高亮。

Prompt:

```text
Create a Chinese guofeng action command dock backdrop for the live gameplay screen of a mahjong mobile game.
Asset type: reusable PNG overlay, 1024x256.
Scene/backdrop: dark jade command tray, silk brocade ribbon, subtle scroll tails, restrained gold execution routes, jade decision nodes, tiny cinnabar response accents.
Subject: decorative action dock background only, leaving clean low-contrast space for the game engine's Chi, Peng, Gang, Hu, Pass, and other action buttons.
Style/medium: premium mobile game UI illustration, Chinese ink wash, polished brocade texture, refined gold foil command-line accents.
Composition/framing: wide horizontal low-profile dock, clean central button row area, decorative detail near left and right tails, generous safe padding, readable at small height.
Lighting/mood: responsive decision moment, calm but urgent, elegant, tactile.
Color palette: deep jade, ink black, muted teal, warm gold, small cinnabar urgency accents.
Constraints: no words, no numbers, no logo, no watermark, no people, no readable mahjong tile symbols, no actual button labels.
Avoid: hard rectangular buttons, bright neon, cluttered center, photorealistic casino controls, beige parchment dominance.
```

### 16. `table_log_gpt_scroll.png`

- 保存路径：`assets/illustrations/table_log_gpt_scroll.png`
- 推荐尺寸：`768x512`
- 用途：对局内牌局日志底纹增强层，会叠加在 `TableLogScrollTexture` 附近、Godot 原生日志标题/条数/行动行之下。
- 构图：竖向紧凑卷轴面板，顶部标题区和三条日志行区域保持低对比且干净。
- 视觉元素：深玉卷轴、金色时间线、玉色行动节点、淡水墨边纹、轻薄锦缎底。
- 避免：文字、数字、具体日志内容、可读牌面、按钮、过亮背景。

Prompt:

```text
Create a Chinese guofeng compact action log scroll backdrop for the live gameplay screen of a mahjong mobile game.
Asset type: reusable PNG overlay, 768x512.
Scene/backdrop: dark jade scroll panel, subtle silk brocade grain, restrained gold timeline, jade event nodes, soft ink-wash border patterns.
Subject: decorative table log background only, leaving clean low-contrast space for the game engine's title, count label, and three compact action log rows.
Style/medium: premium mobile game UI illustration, Chinese ink wash, polished scroll texture, refined gold route accents.
Composition/framing: compact vertical panel, clean upper title strip, clean stacked row area, small decorative timeline accents near the left edge, generous safe padding.
Lighting/mood: quiet match history, readable, elegant, unobtrusive.
Color palette: deep jade, ink black, muted teal, warm gold, tiny cinnabar event accents.
Constraints: no words, no numbers, no logo, no watermark, no people, no readable mahjong tile symbols, no hard UI buttons.
Avoid: busy calligraphy, bright parchment, cluttered row area, neon, photorealistic paper.
```

### 17. `advisor_gpt_panel.png`

- 保存路径：`assets/illustrations/advisor_gpt_panel.png`
- 推荐尺寸：`1024x384`
- 用途：对局内牌势/辅助信息面板底纹增强层，会叠加在 `AdvisorMapTexture` 附近、Godot 原生牌势标题/上下文/三张信息卡之下。
- 构图：横向三栏信息面板，顶部标题与上下文区域、下方三张信息卡区域都保持低对比。
- 视觉元素：深玉策略图谱、金色决策桥、玉色信号节点、防守/收益/推荐三路轻微分区、锦缎纹理。
- 避免：文字、数字、建议标签、可读牌面、按钮、强烈警示色。

Prompt:

```text
Create a Chinese guofeng advisor strategy panel backdrop for the live gameplay screen of a mahjong mobile game.
Asset type: reusable PNG overlay, 1024x384.
Scene/backdrop: dark jade strategy map panel, subtle silk brocade texture, restrained gold decision bridge, jade signal nodes, faint three-lane card structure for recommendation, value, and defense.
Subject: decorative advisor panel background only, leaving clean low-contrast space for the game engine's title, context line, and three compact information cards.
Style/medium: premium mobile game UI illustration, Chinese ink wash, polished strategy-map texture, refined gold route accents.
Composition/framing: wide compact panel, clean top context strip, clean three-column card area, subtle route detail behind cards, generous safe padding.
Lighting/mood: tactical but calm, readable, elegant, trustworthy.
Color palette: deep jade, ink black, muted teal, warm gold, small muted cinnabar risk accents.
Constraints: no words, no numbers, no logo, no watermark, no people, no readable mahjong tile symbols, no hard UI buttons.
Avoid: cluttered dashboard, bright warning red, neon cyber style, photorealistic paper, beige parchment dominance.
```

### 18. `top_hud_gpt_banner.png`

- 保存路径：`assets/illustrations/top_hud_gpt_banner.png`
- 推荐尺寸：`1280x180`
- 用途：对局内顶部 HUD 横幅底纹增强层，会叠加在顶部 HUD 面板底部、Godot 原生模式徽章/标题/状态/分数/余牌/按钮之下。
- 构图：窄幅横向信息条，左侧模式区、中间标题状态区、右侧余牌和按钮区都保持低对比。
- 视觉元素：深玉横幅、金色状态路线、玉色余牌节点、锦缎边线、轻薄水墨云纹。
- 避免：文字、数字、具体按钮、可读牌面、人物、强亮装饰。

Prompt:

```text
Create a Chinese guofeng top HUD banner backdrop for the live gameplay screen of a mahjong mobile game.
Asset type: reusable PNG overlay, 1280x180.
Scene/backdrop: dark jade horizontal HUD banner, subtle silk brocade texture, restrained gold status routes, jade wall-count nodes, soft ink-wash cloud motifs.
Subject: decorative top status background only, leaving clean low-contrast space for the game engine's mode badge, title, status text, score strip, wall count, and control buttons.
Style/medium: premium mobile game UI illustration, Chinese ink wash, polished brocade texture, refined gold line accents.
Composition/framing: wide shallow banner, clean left badge area, clean central title/status area, clean right control area, richer detail only near edges, generous safe padding.
Lighting/mood: focused live match status, calm, readable, elegant.
Color palette: deep jade, ink black, muted teal, warm gold, tiny cinnabar alert accents.
Constraints: no words, no numbers, no logo, no watermark, no people, no readable mahjong tile symbols, no hard UI buttons.
Avoid: busy center, bright decorative emblem, neon dashboard style, beige parchment dominance, photorealistic casino UI.
```

### 19. `seat_gpt_brocade.png`

- 保存路径：`assets/illustrations/seat_gpt_brocade.png`
- 推荐尺寸：`768x512`
- 用途：对局内四方座位面板底纹增强层，同一张图会复用于四个座位，叠加在玩家名/头像/分数/威胁提示之下。
- 构图：紧凑座位卡片底纹，左侧头像区域、顶部名字区、底部分数与状态区都保持低对比。
- 视觉元素：深玉锦缎、金色座位边线、玉色轮转路线、淡水墨座席纹、少量朱砂威胁提示点。
- 避免：文字、数字、头像、人脸、具体麻将牌面、强烈中心图案。

Prompt:

```text
Create a Chinese guofeng seat panel brocade backdrop for the live gameplay screen of a mahjong mobile game.
Asset type: reusable PNG overlay, 768x512.
Scene/backdrop: dark jade compact player seat card, subtle silk brocade grain, restrained gold seat border, jade turn-route accents, soft ink-wash seat motifs, tiny cinnabar risk pips.
Subject: decorative player seat background only, reusable for all four seats, leaving clean low-contrast space for the game engine's avatar, player name, score, hand count, flower count, and threat badges.
Style/medium: premium mobile game UI illustration, Chinese ink wash, polished brocade texture, refined gold and jade accents.
Composition/framing: compact card-friendly layout, clean left avatar area, clean upper name strip, clean lower stat strip, decorative detail near edges only, generous safe padding.
Lighting/mood: calm player status surface, readable, elegant, tactical.
Color palette: deep jade, ink black, muted teal, warm gold, small muted cinnabar warning accents.
Constraints: no words, no numbers, no logo, no watermark, no people, no faces, no readable mahjong tile symbols, no hard UI buttons.
Avoid: portrait art, busy center, bright casino gold, neon, beige parchment dominance.
```

### 20. `exit_gpt_confirm.png`

- 保存路径：`assets/illustrations/exit_gpt_confirm.png`
- 推荐尺寸：`1024x512`
- 用途：退出确认弹层底纹增强层，会叠加在 `ExitConfirmDialog` 底部、Godot 原生保存流插画/说明文字/继续与离开按钮之下。
- 构图：中央保存提示区、下方左右选择路径和按钮区域保持低对比且清晰。
- 视觉元素：深玉确认面板、金色存档路线、玉色继续路径、低饱和朱砂离开路径、锦缎丝带和保存印章轮廓。
- 避免：文字、按钮标签、数字、人物、强烈红色警报、具体麻将牌面。

Prompt:

```text
Create a Chinese guofeng exit confirmation dialog backdrop for a mahjong mobile game.
Asset type: reusable PNG overlay, 1024x512.
Scene/backdrop: dark jade confirmation panel, subtle silk brocade texture, refined gold autosave route, jade keep-playing path, muted cinnabar leave path, soft save-seal silhouette.
Subject: decorative exit confirmation background only, leaving clean low-contrast space for the game engine's title, save-flow illustration, explanatory text, and two action buttons.
Style/medium: premium mobile game UI illustration, Chinese ink wash, polished brocade texture, restrained gold and jade route accents.
Composition/framing: centered modal panel, clean upper title/save area, clear lower left and lower right choice zones, gentle bridge route between choices, generous safe padding.
Lighting/mood: careful decision moment, calm, reassuring, readable.
Color palette: deep jade, ink black, muted teal, warm gold, low-saturation cinnabar warning accents.
Constraints: no words, no numbers, no logo, no watermark, no people, no readable mahjong tile symbols, no hard UI buttons.
Avoid: alarm dialog style, bright red warning screen, cluttered center, neon, beige parchment dominance.
```

### 21. `chat_gpt_panel.png`

- 保存路径：`assets/illustrations/chat_gpt_panel.png`
- 推荐尺寸：`768x768`
- 用途：联机聊天/消息面板底纹增强层，会叠加在 `ChatPanelArt` 底部、Godot 原生消息文本/发送者/未读节点之下。
- 构图：竖向消息面板，顶部消息计数区、中部三条消息区域、底部同步/输入反馈区保持低对比。
- 视觉元素：深玉聊天卷轴、玉色消息流节点、金色同步路线、锦缎边框、轻薄水墨气泡纹。
- 避免：文字、聊天内容、数字、头像、人脸、按钮标签、强亮气泡。

Prompt:

```text
Create a Chinese guofeng chat message panel backdrop for a mahjong mobile game.
Asset type: reusable PNG overlay, 768x768.
Scene/backdrop: dark jade compact chat scroll, subtle silk brocade border, jade message-flow nodes, restrained gold sync routes, soft ink-wash speech-bubble motifs.
Subject: decorative chat panel background only, leaving clean low-contrast space for the game engine's message count, sender chips, three recent chat rows, unread beads, and delivery status.
Style/medium: premium mobile game UI illustration, Chinese ink wash, polished brocade texture, refined message-flow accents.
Composition/framing: vertical compact panel, clean top header area, clean stacked message rows, clean lower sync/input area, detail concentrated near edges and timeline path, generous safe padding.
Lighting/mood: calm social table talk, readable, elegant, unobtrusive.
Color palette: deep jade, ink black, muted teal, warm gold, tiny cinnabar notification accents.
Constraints: no words, no numbers, no logo, no watermark, no people, no faces, no readable mahjong tile symbols, no hard UI buttons.
Avoid: modern neon chat bubbles, cluttered message area, bright parchment, photorealistic phone UI.
```

### 22. `update_gpt_dialog.png`

- 保存路径：`assets/illustrations/update_gpt_dialog.png`
- 推荐尺寸：`1024x768`
- 用途：游戏更新弹窗底纹增强层，会叠加在 `UpdatePrimaryButton`、下载进度、阶段图和更新说明之下。
- 构图：居中弹窗背景，顶部标题区、中央进度区、下方按钮区保持低对比。
- 视觉元素：深玉下载包、金色校验路线、玉色进度轨、安装门、锦缎边框、轻薄云纹。
- 避免：文字、版本号、按钮标签、进度数字、真实设备图标、过亮警示色。

Prompt:

```text
Create a Chinese guofeng game update dialog backdrop for a mahjong mobile game.
Asset type: reusable PNG overlay, 1024x768.
Scene/backdrop: dark jade modal panel, silk brocade border, refined download package silhouette, jade progress rail, warm gold verification route, small install gate motif.
Subject: decorative update dialog background only, leaving clean low-contrast space for the game engine's title, status text, progress bar, release notes summary, stage map, and two action buttons.
Style/medium: premium mobile game UI illustration, Chinese ink wash, polished brocade texture, refined gold and jade route accents.
Composition/framing: centered compact modal, clean upper title zone, clean central progress corridor, clean lower button zone, details concentrated at edges and route endpoints, generous safe padding.
Lighting/mood: calm technical update moment, trustworthy, readable, polished.
Color palette: deep jade, ink black, muted teal, warm gold, soft green status glow, tiny cinnabar only for caution accents.
Constraints: no words, no numbers, no logo, no watermark, no people, no readable mahjong tile symbols, no hard UI buttons, no progress percentage.
Avoid: app store screenshot style, neon cyber UI, cluttered package art, bright red warning panel, beige parchment dominance.
```

### 23. `diagnostic_gpt_panel.png`

- 保存路径：`assets/illustrations/diagnostic_gpt_panel.png`
- 推荐尺寸：`1024x768`
- 用途：音频/系统诊断弹窗底纹增强层，会叠加在诊断文本和状态轨道之下。
- 构图：顶部状态波形区、中部文本列表区、右侧信号地图区保持低对比。
- 视觉元素：玉色波形、金色巡检节点、信号地图、深墨绿面板、低饱和红色故障提示光。
- 避免：文字、OK/ERR 字样、数字、真实电路板、复杂线缆、人像。

Prompt:

```text
Create a Chinese guofeng diagnostic status panel backdrop for a mahjong mobile game.
Asset type: reusable PNG overlay, 1024x768.
Scene/backdrop: dark jade diagnostic modal, subtle silk texture, jade waveform traces, warm gold inspection nodes, compact signal-map motif, muted cinnabar fault glows.
Subject: decorative diagnostic panel background only, leaving clean low-contrast space for the game engine's diagnostic title, status counters, health rail, detailed text list, and tap-to-dismiss route.
Style/medium: premium mobile game UI illustration, Chinese ink wash blended with elegant technical signal lines, polished brocade texture.
Composition/framing: centered modal panel, clean top status band, clean middle text area, subtle right-side trace map, detail at edges and node routes, generous safe padding.
Lighting/mood: calm system check, precise, readable, not alarming.
Color palette: deep jade, ink black, muted teal, warm gold, soft green status glow, restrained cinnabar fault accents.
Constraints: no words, no numbers, no logo, no watermark, no people, no faces, no readable mahjong tile symbols, no hard UI controls.
Avoid: sci-fi neon dashboard, real circuit-board photo, chaotic graph lines, bright red error screen, beige parchment dominance.
```

### 24. `toast_gpt_banner.png`

- 保存路径：`assets/illustrations/toast_gpt_banner.png`
- 推荐尺寸：`1024x256`
- 用途：顶部 Toast 提示横幅底纹增强层，会叠加在图标、消息文本、确认轨道和奖励节点之下。
- 构图：横向短横幅，左侧图标印章区、中部消息区、右侧状态/奖励区保持干净。
- 视觉元素：深玉丝带、玉色消息路线、金色确认门、少量奖励星点、锦缎纹理。
- 避免：文字、按钮、具体金币数字、头像、强烈光爆、现代聊天气泡。

Prompt:

```text
Create a horizontal Chinese guofeng toast notification banner backdrop for a mahjong mobile game.
Asset type: reusable PNG overlay, 1024x256.
Scene/backdrop: dark jade silk ribbon banner, subtle brocade texture, jade message route, warm gold confirmation gate, small reward spark motifs near the right edge.
Subject: decorative notification background only, leaving clean low-contrast space for the game engine's icon seal, message text, lifetime rail, confirmation route, and contextual reward or chat nodes.
Style/medium: premium mobile game UI illustration, Chinese ink wash, polished silk ribbon asset, refined gold foil accents.
Composition/framing: wide compact banner, clean left icon zone, clean central text zone, clean right status/reward zone, readable at small height, generous safe padding.
Lighting/mood: quick polished feedback, calm, tactile, elegant.
Color palette: deep jade, ink black, muted teal, warm gold, small cinnabar notification accents.
Constraints: no words, no numbers, no logo, no watermark, no people, no faces, no readable mahjong tile symbols, no hard UI buttons.
Avoid: modern neon notification bubble, high-contrast clutter, bright white flash, photorealistic phone UI, beige parchment dominance.
```

### 25. `reset_gpt_warning.png`

- 保存路径：`assets/illustrations/reset_gpt_warning.png`
- 推荐尺寸：`1024x512`
- 用途：设置页清空进度二次确认的危险提示底纹，会叠加在 `ResetProgressConfirmArt` 底部。
- 构图：横向警示确认区，左侧警示印章、中部确认路线、右侧提交门保持低对比。
- 视觉元素：深玉警示面板、低饱和朱砂脉冲、金色确认轨道、锁形印章、锦缎裂纹。
- 避免：文字、按钮标签、强烈红屏、恐怖风、真实破损贴图。

Prompt:

```text
Create a Chinese guofeng reset-warning confirmation backdrop for a mahjong mobile game.
Asset type: reusable PNG overlay, 1024x512.
Scene/backdrop: dark jade warning panel, subtle brocade texture, muted cinnabar caution pulse, warm gold confirmation route, lock-seal silhouette, restrained ink crack motifs.
Subject: decorative reset confirmation background only, leaving clean low-contrast space for the game engine's warning seal, confirmation route, commit gate, button label, and safety text.
Style/medium: premium mobile game UI illustration, Chinese ink wash, polished brocade texture, restrained danger accents.
Composition/framing: wide compact warning panel, clean left alert zone, clean center confirmation path, clean right commit gate zone, generous safe padding.
Lighting/mood: serious but controlled, readable, not panic-inducing.
Color palette: deep jade, ink black, muted teal, warm gold, low-saturation cinnabar warning accents.
Constraints: no words, no numbers, no logo, no watermark, no people, no readable mahjong tile symbols, no hard UI buttons.
Avoid: bright red alarm screen, horror style, neon cyber warning, cluttered cracks, beige parchment dominance.
```

### 26. `win_detail_gpt_scroll.png`

- 保存路径：`assets/illustrations/win_detail_gpt_scroll.png`
- 推荐尺寸：`1280x720`
- 用途：胡牌明细面板底纹增强层，会叠加在胡牌者、番数、番种轨道和胡牌牌展示之下。
- 构图：左侧胡牌者信息区、中部番种轨道、右侧牌面展示区都保持干净。
- 视觉元素：深玉结算卷轴、金色番种星轨、玉色分数弧线、胜利印章轮廓、锦缎边框。
- 避免：文字、数字、具体牌面、人物、强烈烟花。

Prompt:

```text
Create a Chinese guofeng winning-hand detail scroll backdrop for a mahjong mobile game.
Asset type: reusable PNG overlay, 1280x720.
Scene/backdrop: dark jade result scroll, silk brocade frame, warm gold yaku constellation route, jade score arc, subtle victory seal silhouette.
Subject: decorative scoring detail background only, leaving clean low-contrast space for the game engine's winner text, fan and points text, winning tile, yaku nodes, and score routes.
Style/medium: premium mobile game UI illustration, Chinese ink wash, refined brocade texture, elegant gold foil scoring accents.
Composition/framing: wide result panel, clean left identity area, clean middle yaku track, clean right tile showcase, detail concentrated near borders and route endpoints.
Lighting/mood: triumphant, precise, readable, polished.
Color palette: deep jade, ink black, muted teal, warm gold, small cinnabar stamp accents.
Constraints: no words, no numbers, no logo, no watermark, no people, no readable mahjong tile symbols, no hard UI controls.
Avoid: casino jackpot style, bright fireworks, cluttered center, photorealistic table, beige parchment dominance.
```

### 27. `win_celebration_gpt_burst.png`

- 保存路径：`assets/illustrations/win_celebration_gpt_burst.png`
- 推荐尺寸：`1024x1024`
- 用途：胡牌爆发/庆祝动画底纹增强层，会叠加在 `WinCelebrationArt` 底部。
- 构图：中心奖章区、下方分数能量轨、外围星点和金箔，中心保持可读。
- 视觉元素：金色水墨爆发、玉色环形轨道、胜利奖章光晕、锦缎丝带、少量星点。
- 避免：文字、具体麻将牌面、人物、过亮白闪、烟花照片。

Prompt:

```text
Create a square Chinese guofeng win celebration burst illustration for a mahjong mobile game.
Asset type: reusable PNG overlay, 1024x1024.
Scene/backdrop: dark jade ink-wash celebration field, warm gold foil burst, jade circular score orbit, soft medal halo, silk ribbon accents.
Subject: decorative win burst background only, leaving clean central space for the game engine's trophy, victory label, score track, stars, and self-draw or special-win overlays.
Style/medium: premium mobile game VFX illustration, Chinese ink wash, polished gold foil, refined mobile UI effect.
Composition/framing: centered burst with readable silhouette, clean medal center, clean lower score route, decorative particles at outer edges, generous safe padding.
Lighting/mood: triumphant, elegant, celebratory without overexposure.
Color palette: deep jade, ink black, muted teal, warm gold, tiny cinnabar stamp accents.
Constraints: no words, no numbers, no logo, no watermark, no people, no readable mahjong tile symbols, no hard UI buttons.
Avoid: casino jackpot, white flash explosion, photorealistic fireworks, neon, beige parchment dominance.
```

### 28. `voice_gpt_channel.png`

- 保存路径：`assets/illustrations/voice_gpt_channel.png`
- 推荐尺寸：`768x512`
- 用途：语音按钮/闭麦按钮的频道底纹增强层，会叠加在麦克风状态、音量峰值和网络回声路线之下。
- 构图：左侧麦克风状态点、中部声波通道、右侧发送门保持干净。
- 视觉元素：玉色声波、金色传输路线、深玉频道面板、低饱和红色静音暗纹、轻薄环形回声。
- 避免：文字、现代通讯 App UI、头像、人脸、刺眼波形。

Prompt:

```text
Create a Chinese guofeng voice channel button backdrop for a mahjong mobile game.
Asset type: reusable PNG overlay, 768x512.
Scene/backdrop: dark jade compact voice-channel panel, jade waveform traces, warm gold transmit route, subtle circular echo rings, muted cinnabar silence pattern for inactive state.
Subject: decorative voice button background only, leaving clean low-contrast space for the game engine's microphone status dot, wave bars, peak meter, transmit gate, feedback loop, and mute slash.
Style/medium: premium mobile game UI illustration, Chinese ink wash blended with elegant signal-line motifs, polished brocade texture.
Composition/framing: compact horizontal control, clean left mic zone, clean middle waveform channel, clean right network transmit zone, readable at small button size.
Lighting/mood: responsive voice communication, calm, precise, unobtrusive.
Color palette: deep jade, ink black, muted teal, warm gold, soft green active glow, restrained cinnabar mute accents.
Constraints: no words, no numbers, no logo, no watermark, no people, no faces, no readable mahjong tile symbols, no hard UI labels.
Avoid: modern chat app screenshot, neon audio visualizer, cluttered waveform, bright red mute screen, beige parchment dominance.
```

### 29. `online_feedback_gpt_strip.png`

- 保存路径：`assets/illustrations/online_feedback_gpt_strip.png`
- 推荐尺寸：`1280x256`
- 用途：联机大厅服务器反馈条底纹增强层，会叠加在状态图标、反馈文本、等待脉冲和确认路线之下。
- 构图：左侧状态印章、中部服务器消息区、右侧等待/结果节点保持清晰。
- 视觉元素：深玉网络丝带、玉色握手路线、金色响应门、服务器回执节点、轻薄锦缎纹理。
- 避免：文字、IP 地址、按钮、现代系统弹窗、过亮网络线。

Prompt:

```text
Create a horizontal Chinese guofeng online server feedback strip for a mahjong mobile game.
Asset type: reusable PNG overlay, 1280x256.
Scene/backdrop: dark jade network silk strip, subtle brocade texture, jade handshake route, warm gold response gate, compact acknowledgement nodes, soft message-lane glow.
Subject: decorative online feedback background only, leaving clean low-contrast space for the game engine's status icon, server feedback text, waiting pulses, response route, result node, and acknowledgement route.
Style/medium: premium mobile game UI illustration, Chinese ink wash blended with elegant network signal lines, refined gold and jade accents.
Composition/framing: wide compact status strip, clean left seal zone, clean central text lane, clean right response/result zone, readable at small height, generous safe padding.
Lighting/mood: connected, calm, reliable, readable.
Color palette: deep jade, ink black, muted teal, warm gold, soft green/blue network glow, tiny cinnabar error accents.
Constraints: no words, no numbers, no logo, no watermark, no people, no faces, no readable mahjong tile symbols, no hard UI buttons.
Avoid: sci-fi neon network dashboard, bright system notification, cluttered cables, photorealistic device UI, beige parchment dominance.
```

### 30. `table_turn_gpt_flow.png`

- 保存路径：`assets/illustrations/table_turn_gpt_flow.png`
- 推荐尺寸：`1024x1024`
- 用途：对局桌面当前回合流向底纹，会叠加在 `TableTurnFlowTrail` 附近、中心风位和座位路线之下。
- 构图：中心到四方座位的柔和流向轨道，中央和四角保留低对比空间。
- 视觉元素：玉色回合轨、金色节拍点、水墨圆环、锦缎细纹、轻薄风向纹。
- 避免：文字、方向字、具体牌面、强亮箭头、复杂中心主体。

Prompt:

```text
Create a square Chinese guofeng turn-flow table overlay for a mahjong mobile game.
Asset type: reusable PNG overlay, 1024x1024.
Scene/backdrop: dark jade tabletop aura, subtle ink-wash circular orbit, jade turn-flow trails from center toward four seats, warm gold rhythm nodes, faint brocade texture.
Subject: decorative current-turn flow background only, leaving clean low-contrast space for the game engine's center wind compass, seat panels, route fill, active halo, and table tiles.
Style/medium: premium mobile game UI/VFX illustration, Chinese ink wash, refined gold foil, subtle silk texture.
Composition/framing: centered circular flow, clean center, clean four directional endpoints, readable when scaled down, generous safe padding.
Lighting/mood: calm tactical turn handoff, elegant, unobtrusive.
Color palette: deep jade, ink black, muted teal, warm gold, tiny cinnabar timing accents.
Constraints: no words, no numbers, no logo, no watermark, no people, no readable mahjong tile symbols, no hard UI arrows.
Avoid: bright neon arrows, busy center, casino felt table, photorealistic objects, beige parchment dominance.
```

### 31. `center_wind_gpt_compass.png`

- 保存路径：`assets/illustrations/center_wind_gpt_compass.png`
- 推荐尺寸：`768x768`
- 用途：中心风位罗盘底纹增强层，会叠加在 `CenterWindCompass` 底部。
- 构图：同心圆罗盘，四方风位空间干净，中央留给当前风位轨道。
- 视觉元素：玉色罗盘环、金色风向珠、暗纹印章、水墨云纹、低对比锦缎底。
- 避免：文字、东南西北字、复杂符号、具体麻将牌面。

Prompt:

```text
Create a square Chinese guofeng center-wind compass backdrop for a mahjong mobile game.
Asset type: reusable PNG overlay, 768x768.
Scene/backdrop: dark jade circular compass, subtle silk brocade texture, jade concentric rings, warm gold direction beads, faint ink-cloud seal motifs.
Subject: decorative compass background only, leaving clean low-contrast space for the game engine's four wind badges, active halo, dealer marker, current pointer, and next-seat cue.
Style/medium: premium mobile game UI illustration, Chinese ink wash, refined brocade and gold foil accents.
Composition/framing: centered round compass, clean center, clean four cardinal badge zones, gentle outer ring detail, generous safe padding.
Lighting/mood: precise table state indicator, calm, ceremonial, readable.
Color palette: deep jade, ink black, muted teal, warm gold, small cinnabar seal accents.
Constraints: no words, no numbers, no logo, no watermark, no people, no readable mahjong tile symbols, no hard UI labels.
Avoid: literal compass letters, busy astrology chart, bright neon ring, western fantasy compass, beige parchment dominance.
```

### 32. `danger_gpt_discard.png`

- 保存路径：`assets/illustrations/danger_gpt_discard.png`
- 推荐尺寸：`1280x320`
- 用途：危险弃牌确认条底纹增强层，会叠加在风险牌、风险轨道、安全替代和确认路线之下。
- 构图：横向风险决策条，左侧弃牌源点、中部风险轨道、右侧确认/替代分支保持干净。
- 视觉元素：深玉危险决策面板、低饱和朱砂风险脉冲、金色确认门、玉色安全替代路线、锦缎格纹。
- 避免：文字、风险数字、强红警告屏、真实血色、人物。

Prompt:

```text
Create a horizontal Chinese guofeng dangerous-discard confirmation backdrop for a mahjong mobile game.
Asset type: reusable PNG overlay, 1280x320.
Scene/backdrop: dark jade decision strip, muted cinnabar risk pulse, warm gold confirmation gate, jade alternative-safe route, subtle brocade lattice, ink-wash warning haze.
Subject: decorative danger discard background only, leaving clean low-contrast space for the game engine's discard tile, risk seal, detail text, risk nodes, safe alternatives, and confirm-versus-alternative bridge.
Style/medium: premium mobile game UI illustration, Chinese ink wash, polished brocade texture, restrained warning accents.
Composition/framing: wide compact decision bar, clean left tile zone, clean middle risk route, clean right decision split, generous safe padding.
Lighting/mood: serious tactical warning, readable, controlled, not alarming.
Color palette: deep jade, ink black, muted teal, warm gold, low-saturation cinnabar warning accents.
Constraints: no words, no numbers, no logo, no watermark, no people, no readable mahjong tile symbols, no hard UI buttons.
Avoid: bright red danger screen, horror visuals, casino jackpot colors, neon, beige parchment dominance.
```

### 33. `menu_tutorial_gpt_hint.png`

- 保存路径：`assets/illustrations/menu_tutorial_gpt_hint.png`
- 推荐尺寸：`1024x384`
- 用途：主菜单新手教程提示底纹增强层，会叠加在菜单教程提示条底部。
- 构图：横向提示条，左侧引导印章、中部提示文本区、右侧规则入口路线保持干净。
- 视觉元素：深玉教程丝带、玉色引导路径、金色入口门、轻薄云纹、锦缎边框。
- 避免：文字、按钮标签、手指图标、人物、现代弹窗风。

Prompt:

```text
Create a horizontal Chinese guofeng tutorial hint banner for a mahjong mobile game main menu.
Asset type: reusable PNG overlay, 1024x384.
Scene/backdrop: dark jade tutorial silk banner, subtle brocade border, jade guide path, warm gold entry gate, faint cloud motifs and small marker nodes.
Subject: decorative tutorial hint background only, leaving clean low-contrast space for the game engine's tutorial text, guide seal, entry route, target ticks, and menu buttons.
Style/medium: premium mobile game UI illustration, Chinese ink wash, refined silk ribbon, polished gold foil accents.
Composition/framing: wide compact hint banner, clean left seal zone, clean central text lane, clean right entry route zone, generous safe padding.
Lighting/mood: gentle onboarding, calm, inviting, readable.
Color palette: deep jade, ink black, muted teal, warm gold, soft green guide glow.
Constraints: no words, no numbers, no logo, no watermark, no people, no hands, no readable mahjong tile symbols, no hard UI buttons.
Avoid: modern pop-up tutorial bubble, neon arrows, cartoon hand pointer, cluttered center, beige parchment dominance.
```

### 34. `hand_tutorial_gpt_hint.png`

- 保存路径：`assets/illustrations/hand_tutorial_gpt_hint.png`
- 推荐尺寸：`1024x384`
- 用途：手牌区新手弃牌提示底纹增强层，会叠加在 `HandTrayTutorialHintArt` 底部。
- 构图：横向手牌教学条，左侧点击印章、中部步骤进度、右侧弃牌到牌河路线保持干净。
- 视觉元素：深玉手牌托盘、玉色点击涟漪、金色弃牌路线、牌河节点、轻薄锦缎纹。
- 避免：文字、具体牌面、手指/人物、按钮标签、过亮箭头。

Prompt:

```text
Create a horizontal Chinese guofeng hand tutorial hint backdrop for a mahjong mobile game.
Asset type: reusable PNG overlay, 1024x384.
Scene/backdrop: dark jade hand-tray tutorial strip, subtle silk brocade texture, jade click-ripple motifs, warm gold discard route, small river-node accents.
Subject: decorative hand tutorial background only, leaving clean low-contrast space for the game engine's hint text, click seal, step rail, target tile, discard route, and river node.
Style/medium: premium mobile game UI illustration, Chinese ink wash, refined brocade texture, elegant guide-route accents.
Composition/framing: wide compact tutorial strip, clean left click zone, clean middle step progress, clean right discard-to-river route, generous safe padding.
Lighting/mood: helpful first-action guidance, calm, readable, tactile.
Color palette: deep jade, ink black, muted teal, warm gold, soft green guide glow.
Constraints: no words, no numbers, no logo, no watermark, no people, no hands, no readable mahjong tile symbols, no hard UI buttons.
Avoid: bright tutorial arrows, modern mobile onboarding bubble, cluttered tile art, beige parchment dominance.
```

### 35. `flower_gpt_bloom.png`

- 保存路径：`assets/illustrations/flower_gpt_bloom.png`
- 推荐尺寸：`768x768`
- 用途：花牌补花动画底纹增强层，会叠加在 `FlowerBloomFx` 底部。
- 构图：中心补花牌区域留空，外围花瓣/玉色光环/补牌路线环绕。
- 视觉元素：国风花瓣、水墨绽放、玉色环、金色补牌路线、柔和光晕。
- 避免：文字、具体花牌字样、真实照片花朵、过亮白闪、人像。

Prompt:

```text
Create a square Chinese guofeng flower replacement bloom effect for a mahjong mobile game.
Asset type: reusable PNG overlay, 768x768.
Scene/backdrop: dark jade ink-wash bloom field, soft flower petals, jade circular halo, warm gold replacement route, subtle silk sparkle.
Subject: decorative flower-bloom VFX background only, leaving clean central space for the game engine's flower tile, replacement label, ring, petals, and route ticks.
Style/medium: premium mobile game VFX illustration, Chinese ink wash, refined floral brushwork, soft alpha-friendly edges.
Composition/framing: centered bloom, clean tile center, petals and route accents around the perimeter, readable when scaled down, generous safe padding.
Lighting/mood: graceful bonus replacement moment, elegant, celebratory, not explosive.
Color palette: deep jade, ink black, muted teal, warm gold, soft pink/cinnabar petal accents.
Constraints: no words, no numbers, no logo, no watermark, no people, no readable mahjong tile symbols.
Avoid: photorealistic flower photo, overexposed white flash, neon particles, busy center, beige parchment dominance.
```

### 36. `seat_discard_gpt_preview.png`

- 保存路径：`assets/illustrations/seat_discard_gpt_preview.png`
- 推荐尺寸：`768x384`
- 用途：座位面板最近弃牌/牌河预览底纹增强层。
- 构图：左侧最近 3 张弃牌空间、中部历史路线、右侧溢出/结束门保持干净。
- 视觉元素：深玉牌河水墨、玉色历史轨、金色结束门、低对比水波纹、锦缎边框。
- 避免：文字、具体牌面、数字、强亮水波、真实牌桌照片。

Prompt:

```text
Create a compact Chinese guofeng discard preview strip for a mahjong seat panel.
Asset type: reusable PNG overlay, 768x384.
Scene/backdrop: dark jade discard river wash, subtle ink-water ripples, jade history route, warm gold overflow gate, refined brocade edge texture.
Subject: decorative discard preview background only, leaving clean low-contrast space for the game engine's recent discard tiles, glyphs, overflow badge, rail fill, history route, and rhythm ticks.
Style/medium: premium mobile game UI illustration, Chinese ink wash, polished brocade texture, refined route accents.
Composition/framing: compact seat-panel strip, clean left recent-tile zone, clean middle history lane, clean right overflow gate, readable at small size.
Lighting/mood: quiet river tracking, tactical, unobtrusive.
Color palette: deep jade, ink black, muted teal, warm gold, small cinnabar history accents.
Constraints: no words, no numbers, no logo, no watermark, no people, no readable mahjong tile symbols, no hard UI buttons.
Avoid: photorealistic tile photos, bright neon river, cluttered glyphs, beige parchment dominance.
```

### 37. `seat_flower_gpt_strip.png`

- 保存路径：`assets/illustrations/seat_flower_gpt_strip.png`
- 推荐尺寸：`768x384`
- 用途：座位面板花牌收集条底纹增强层。
- 构图：左侧花牌印章、中部 4 张花牌陈列、右侧补牌路线保持干净。
- 视觉元素：深玉花牌收集条、金色花瓣轨、玉色补牌路线、柔和花影、锦缎纹理。
- 避免：文字、具体花牌字、真实花朵照片、强亮粉色。

Prompt:

```text
Create a compact Chinese guofeng flower-tile collection strip for a mahjong seat panel.
Asset type: reusable PNG overlay, 768x384.
Scene/backdrop: dark jade flower collection panel, subtle silk brocade, warm gold petal route, jade replacement draw path, soft floral shadow motifs.
Subject: decorative flower strip background only, leaving clean low-contrast space for the game engine's flower tile miniatures, collection rail, replacement route, source node, gate, and overflow badge.
Style/medium: premium mobile game UI illustration, Chinese ink wash, refined floral brushwork, polished gold accents.
Composition/framing: compact horizontal strip, clean left seal zone, clean middle four-tile display zone, clean right replacement route, generous safe padding.
Lighting/mood: graceful flower bonus state, elegant, readable, unobtrusive.
Color palette: deep jade, ink black, muted teal, warm gold, soft muted petal pink/cinnabar accents.
Constraints: no words, no numbers, no logo, no watermark, no people, no readable mahjong tile symbols, no hard UI labels.
Avoid: photorealistic flower bouquet, bright pink overload, cluttered tile art, beige parchment dominance.
```

### 38. `center_wall_gpt_warning.png`

- 保存路径：`assets/illustrations/center_wall_gpt_warning.png`
- 推荐尺寸：`768x768`
- 用途：中心剩余牌墙/低墙警告底纹增强层。
- 构图：四方牌墙余量环、中央压力脉冲、低墙警告区保持低对比。
- 视觉元素：深玉四向牌墙、金色余量轨、朱砂低墙脉冲、玉色摸牌路线、中心曼陀罗。
- 避免：文字、数字、具体牌面、过亮红色、复杂中心。

Prompt:

```text
Create a square Chinese guofeng wall-count warning compass for a mahjong mobile game.
Asset type: reusable PNG overlay, 768x768.
Scene/backdrop: dark jade center-wall meter, four directional wall segments, jade draw handoff route, warm gold remaining-wall nodes, muted cinnabar low-wall pulse, faint mandala texture.
Subject: decorative wall-count warning background only, leaving clean low-contrast space for the game engine's wall segments, flow core, pressure pulse, draw route, low-wall badge, warning sparks, and countdown fill.
Style/medium: premium mobile game UI/VFX illustration, Chinese ink wash, refined brocade and gold foil accents.
Composition/framing: centered square meter, clean four wall edges, clean central pressure zone, clean low-warning badge area, generous safe padding.
Lighting/mood: tactical near-draw warning, serious but controlled, readable.
Color palette: deep jade, ink black, muted teal, warm gold, low-saturation cinnabar warning accents.
Constraints: no words, no numbers, no logo, no watermark, no people, no readable mahjong tile symbols.
Avoid: bright red alarm, neon dashboard, busy center, photorealistic tile wall, beige parchment dominance.
```

### 39. `top_hud_wall_gpt_warning.png`

- 保存路径：`assets/illustrations/top_hud_wall_gpt_warning.png`
- 推荐尺寸：`1024x256`
- 用途：顶部 HUD 剩余牌墙/低墙警告条底纹增强层。
- 构图：左侧牌墙堆叠、中部余量轨、右侧低墙警告脉冲保持清晰。
- 视觉元素：深玉 HUD 条、玉色牌墙堆、金色状态路线、朱砂低墙警告、轻薄锦缎底。
- 避免：文字、数字、具体牌面、现代警告横幅、过亮红色。

Prompt:

```text
Create a horizontal Chinese guofeng top-HUD wall-count warning strip for a mahjong mobile game.
Asset type: reusable PNG overlay, 1024x256.
Scene/backdrop: dark jade compact HUD strip, subtle brocade texture, jade wall-stack motif, warm gold status route, muted cinnabar low-wall pulse on the right.
Subject: decorative top-HUD wall meter background only, leaving clean low-contrast space for the game engine's wall rail, fill, status dot, wall stack, last-tile node, status route, and low-wall warning badge.
Style/medium: premium mobile game UI illustration, Chinese ink wash blended with compact HUD geometry, refined gold and jade accents.
Composition/framing: wide shallow HUD strip, clean left stack area, clean central progress rail, clean right warning zone, readable at small height.
Lighting/mood: compact tactical warning, calm, readable, polished.
Color palette: deep jade, ink black, muted teal, warm gold, restrained cinnabar warning accents.
Constraints: no words, no numbers, no logo, no watermark, no people, no readable mahjong tile symbols, no hard UI labels.
Avoid: modern system alert banner, neon red warning, cluttered icons, photorealistic device UI, beige parchment dominance.
```

### 40. `hand_completion_gpt_bus.png`

- 保存路径：`assets/illustrations/hand_completion_gpt_bus.png`
- 推荐尺寸：`1280x256`
- 用途：对局内手牌完成度路线底纹增强层，会叠加在手牌区域进度提示、牌型完成状态和 Godot 原生手牌按钮之下。
- 构图：超宽低矮路线条，中央保持透明感和低对比，左右端点可有印章式起点和档案门式终点。
- 视觉元素：深玉漆路线、四个分支进度槽、金色细线、玉色流光、丝纸纹理和少量方向性微光。
- 避免：文字、数字、具体牌面、按钮标签、人物、强亮边框。

Prompt:

```text
Create a slim hand-completion bus overlay for the live gameplay hand tray of a Chinese mahjong mobile game.
Asset type: reusable PNG overlay, 1280x256.
Scene/backdrop: horizontal dark lacquer route, left hand-source seal, four small branching progress sockets, right archive gate, subtle jade and warm gold edge lighting, silk-paper grain, tiny directional motes moving along the route.
Subject: decorative completion-route background only, quiet enough to sit behind live mahjong tiles, hand-progress hints, and native UI controls.
Style/medium: premium mobile game UI illustration, Chinese guofeng ink wash, polished lacquer, silk paper texture, refined gold foil accents.
Composition/framing: ultra-wide low-profile route, center mostly transparent-looking and uncluttered, clean middle lane, decorative detail near left and right endpoints, generous safe padding.
Lighting/mood: focused hand-building progress, calm, readable, elegant, tactile.
Color palette: deep jade, ink black, muted teal, warm gold, tiny cinnabar progress accents.
Constraints: no words, no numbers, no logo, no watermark, no people, no readable mahjong tile symbols, no hard UI buttons.
Avoid: bright tile drawings, cluttered center, thick ornamental border, neon progress bar, photorealistic casino table, beige parchment dominance.
```

### 41. `rules_reading_progress_panel.png`

- 保存路径：`assets/illustrations/rules_reading_progress_panel.png`
- 推荐尺寸：`960x80`
- 用途：规则页阅读进度区的国风底板增强层，会以低透明度叠加在原生进度节点之下。**它只是装饰底板，游戏不会在其上绘制真实进度填充**，因此绝对不能画出某个固定填充百分比的进度条。
- 构图：超宽低矮横条，左端可有玉色印章/花章式起点装饰，整条通道保持均匀、对称、无明显“已填充/未填充”分界，中央干净低对比。
- 视觉元素：深玉漆横轨、对称金色细描边、均匀玉色柔光、丝纸纹理、少量朱砂点缀，两端轻微收口。
- 避免：文字、数字、任何看起来像“进度已到某处”的半满填充条、明显的填充/空槽分界、按钮标签、人物、强亮边框。

Prompt:

```text
Create a slim decorative reading-progress backing plate for the rules screen of a Chinese guofeng mahjong mobile game.
Asset type: reusable PNG backing plate overlay, 960x80.
Important: this is a purely ornamental backdrop. The game does NOT render any live fill on top, so DO NOT draw a progress bar with a specific fill level, and DO NOT show any filled-versus-empty boundary. The rail must look uniform and evenly finished along its whole length.
Scene/backdrop: one ultra-wide low horizontal lacquer rail, symmetrical along its length, with a small jade seal or lotus-medallion flourish at the left end and a matching quiet cap at the right end, soft even jade sheen across the entire rail, warm gold hairline trim on both edges, silk-paper grain, a few tiny cinnabar specks.
Subject: elegant empty ornamental rail only, calm enough to sit behind native UI progress nodes.
Style/medium: premium mobile game UI illustration, Chinese guofeng ink wash, polished lacquer, silk paper texture, refined gold foil accents.
Composition/framing: ultra-wide low-profile rail, uniform and symmetrical, clean low-contrast center, decorative flourish only at the far endpoints, generous safe padding.
Lighting/mood: calm, premium, tactile, evenly lit end to end.
Color palette: deep jade, ink black, muted teal, warm gold, tiny cinnabar accents.
Constraints: no words, no numbers, no logo, no watermark, no people, no readable mahjong tile symbols, no hard UI buttons.
Avoid: half-filled progress bar, any filled-versus-empty split, bright glowing fill segment, neon, cluttered center, thick ornamental border, photorealistic casino table, beige parchment dominance.
```

## 接入步骤

1. 将 GPT 生成的 PNG 放入上述保存路径。
2. 如为上面已列出的资产，不需要再注册；`scripts/main_base.gd` 已通过 `GPT_ILLUSTRATION_ASSET_PATHS` 声明可选路径。
3. 如新增其他 GPT 资产，再使用 `add_optional_gpt_illustration_texture()` 挂到对应 UI。
4. 在 `scripts/offline_smoke_test.gd` 添加“存在时显示、缺失时不报错”的节点断言。
5. 运行：

```bash
godot --headless --path . --script res://scripts/offline_smoke_test.gd
```
