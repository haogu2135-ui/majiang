# 待生成 GPT 插画 prompt（下一轮 UI 完善）

本文件记录 UI 审计后待补的 8 张图片 prompt。生成后把 PNG 放到 `assets/illustrations/`，
在 `scripts/main_base.gd` 的 `GPT_ILLUSTRATION_ASSET_PATHS` 登记 key，再用
`add_optional_gpt_illustration_texture(panel, "<key>", rect, alpha, false)` 接入对应渲染函数。

统一风格基线（与现有 GPT 插画一致）：国风水墨，深墨绿 / 温润玉色 / 金箔 / 少朱砂，
**无文字 / Logo / 水印 / 人物脸部**，暗色水墨底便于低透明度叠加，RGBA PNG。

---

### 41. `daily_login_milestone_seal.png`

- 保存路径：`assets/illustrations/daily_login_milestone_seal.png`
- 推荐尺寸：`256x256`
- 用途：每日签到第 7 日里程碑节点奖章（screens.gd.part:954-972 当前用纯几何圆+对勾，无插画）。
- 接入点：`show_daily_login_panel` 内第 7 日节点。
- 构图：圆形锦缎奖章，金箔边，朱砂「×2」风格印章；中心留干净空间由引擎叠奖励数字。
- 避免：文字、Logo、人物、可读牌面。

Prompt:

```text
Create a Chinese guofeng daily-login milestone medal for a mahjong mobile game.
Asset type: reusable PNG seal/medal, 256x256, transparent-friendly dark ink backing.
Subject: a round brocade medal with gold foil rim and a cinnabar "x2" stamp marking a 7-day streak milestone; no readable words except a stylized Chinese seal glyph shape.
Style: Chinese ink wash, refined gold foil filigree, jade-green silk ribbon tail; mobile game UI reward token.
Composition: centered circular medal, generous safe margin, soft inner glow.
Color palette: deep jade, warm gold, very small cinnabar accent, ink black backing.
Constraints: no text, no logo, no watermark, no people, no readable tile symbols.
Avoid: photoreal, neon, western fantasy, beige dominance.
```

---

### 42. `lobby_room_gate_token.png`

- 保存路径：`assets/illustrations/lobby_room_gate_token.png`
- 推荐尺寸：`768x256`
- 用途：对联大厅房号承载条（screens.gd.part:385-388 当前房号仅文本徽章，无国风门承载插画）。
- 接入点：`draw_online_lobby_connection_route` 内房号徽章处。
- 构图：金线国风月门 + 朱砂号码印章窗；印章区留干净，引擎叠房号数字。
- 避免：数字、文字、Logo、人物。

Prompt:

```text
Create a Chinese guofeng room-number gate panel for a mahjong game online lobby.
Asset type: reusable PNG overlay banner, 768x256.
Subject: a moon-gate window with golden filigree frame, containing a cinnabar number seal plaque holder; the plaque is left clean (no digits — engine overlays room code).
Style: Chinese ink wash, jade and gold moon gate, silk cloud border; premium mobile lobby token.
Composition: horizontal banner, clean central seal area, symmetrical gate, edge padding.
Color palette: deep jade black, warm gold frame, muted teal, small cinnabar seal.
Constraints: no text, no digits, no logo, no watermark, no people.
Avoid: neon, photoreal, modern UI chrome, cluttered center.
```

---

### 43. `exit_save_scroll.png`

- 保存路径：`assets/illustrations/exit_save_scroll.png`
- 推荐尺寸：`1024x256`
- 用途：退出确认对话框「存档进度」说明插画（screens.gd.part:1139-1235 当前仅有 exit_gpt_confirm 背景，保存说明全为文字）。
- 接入点：`show_exit_confirm` 内保存进度说明段。
- 构图：水墨卷轴 + 金色封印蜡；传达「存档/封缄」语义。
- 避免：文字、Logo、人物、UI 按钮。

Prompt:

```text
Create a Chinese guofeng save-progress scroll illustration for a mahjong game exit-confirm dialog.
Asset type: reusable PNG overlay strip, 1024x256.
Subject: an ink scroll partially rolled with a gold seal wax stamp anchoring it; conveys archiving/saving a match.
Style: Chinese ink wash scroll, gold seal wax, jade silk tie; quiet, premium.
Composition: horizontal scroll, central seal focal, soft mist at ends, safe margins.
Color palette: ink black, jade green, warm gold seal, small cinnabar wax.
Constraints: no text, no logo, no watermark, no people, no UI buttons.
Avoid: western scroll, neon, parchment-dominant beige.
```

---

### 44. `stats_winrate_scroll.png`

- 保存路径：`assets/illustrations/stats_winrate_scroll.png`
- 推荐尺寸：`512x256`
- 用途：统计页中央胜率卷 hero（screens.gd.part:693,719-721 当前用 `draw_stats_dashboard_art` 几何画，无独立胜率卷插画）。
- 接入点：`_show_stats_screen_impl` 中央胜率环处。
- 构图：金线锦缎胜率卷 + 朱砂节点；中央留干净供引擎叠胜率环。
- 避免：文字、数字、Logo、人物。

Prompt:

```text
Create a Chinese guofeng win-rate dashboard scroll for a mahjong game stats screen.
Asset type: reusable PNG hero overlay, 512x256.
Subject: a jade-and-gold brocade win-rate scroll with small cinnabar node markers along its length (engine overlays the percentage).
Style: Chinese ink wash, brocade gold thread, jade ribbon; refined game UI instrument.
Composition: horizontal hero strip, clean central gauge area for engine-drawn ring, symmetric ends.
Color palette: deep jade, warm gold thread, small cinnabar nodes, ink backing.
Constraints: no text, no numerals, no logo, no watermark, no people.
Avoid: western chart bars, neon, photoreal, beige dominance.
```

---

### 45. `rules_pattern_quads.png`

- 保存路径：`assets/illustrations/rules_pattern_quads.png`
- 推荐尺寸：`512x128`
- 用途：规则页牌型示例 4 连图（screens.gd.part:447-475 当前内容全为 emoji+文字，无牌型示意图）。
- 接入点：`show_rules_screen` 牌型说明段。
- 构图：横向 4 等格，依次为顺子/刻子/杠/将头四种 mini 牌簇；牌面抽象剪影，不画可读牌纹。
- 避免：文字、数字、Logo、人物、可读牌面。

Prompt:

```text
Create a Chinese guofeng mahjong hand-pattern teaching strip for a rules screen.
Asset type: reusable PNG overlay, 512x128, four equal cells left-to-right.
Subject: four mini mahjong tile-cluster icons in sequence: a chow/sequence, a pong/triplet, a kong/quad, and a pair-head; each cluster abstracted (no readable real tile glyphs needed — silhouettes).
Style: Chinese ink wash, gold-line annotation strokes, jade tile backs; clean educational icon set.
Composition: four equal panels in one strip, each centered cluster, generous inter-cell gap, safe outer margin.
Color palette: deep jade, ink tile silhouettes, warm gold annotation, small cinnabar highlight.
Constraints: no text, no numerals, no logo, no watermark, no people, no readable tile faces.
Avoid: cluttered, neon, photorealistic tile photography.
```

---

### 46. `diagnostic_wave_hero.png`

- 保存路径：`assets/illustrations/diagnostic_wave_hero.png`
- 推荐尺寸：`1280x180`
- 用途：诊断对话框顶部状态波形 hero（render.gd.part:2666 调 `draw_diagnostic_result_sync_art`，当前波形为 ColorRect，缺 hero 插画）。
- 接入点：`show_diagnostic_dialog` 顶部状态带。
- 构图：翡翠金线波形 + 巡检节点 + 一点朱砂故障标记；静止优雅不做告警风。
- 避免：文字、数字、Logo、人物、医疗/示波器风格。

Prompt:

```text
Create a Chinese guofeng diagnostic waveform banner for a mahjong game audio-system dialog.
Asset type: reusable PNG top-strip overlay, 1280x180.
Subject: a calm jade waveform with gold inspection nodes and a small cinnabar fault marker; conveys health-check trace.
Style: Chinese ink wash wave, gold node studs, silk cloud edge; serene diagnostic instrument.
Composition: wide thin top banner, central wave focal, soft mist sides, safe margins.
Color palette: deep jade, warm gold nodes, very small cinnabar fault dot, ink backing.
Constraints: no text, no numerals, no logo, no watermark, no people.
Avoid: medical/clinical style, neon, photoreal oscilloscope, red alarm dominance.
```

---

### 47. `center_wind_pointer.png`

- 保存路径：`assets/illustrations/center_wind_pointer.png`
- 推荐尺寸：`256x256`（带旋转锚点：围绕精确中心旋转）
- 用途：中心风位可旋转金指针（render.gd.part:1781-1824 当前活跃指针为纯 make_panel 矩形，无可旋转插画资产）。
- 接入点：`draw_center` / `draw_center_wind_*` 活跃指针层。
- 构图：细金指南针针 + 末端朱砂方向印；默认指向正上,精确中心旋转枢轴,圆形安全边距防旋转裁切。
- 避免：方位字母、文字、Logo、人物、西方航海风、枢轴偏心。

Prompt:

```text
Create a Chinese guofeng compass pointer for a mahjong game center wind indicator.
Asset type: reusable PNG rotary pointer, 256x256, designed to rotate around its exact center.
Subject: a slender gold compass needle with a cinnabar direction seal at its tip; isolated, dark ink halo so it reads over the compass base.
Style: Chinese ink wash, gold filigree needle, jade halo; elegant premium instrument.
Composition: needle pointing straight up by default, exact-center rotation pivot, generous circular safe margin so rotation never clips; transparent/ink edges.
Color palette: warm gold needle, deep jade halo, small cinnabar tip seal, ink backing.
Constraints: no text, no cardinal letters, no logo, no watermark, no people.
Avoid: neon, photoreal compass, western nautical style, off-center pivot.
```

---

### 48. `seat_avatar_scenic_frame.png`

- 保存路径：`assets/illustrations/seat_avatar_scenic_frame.png`
- 推荐尺寸：`384x384`（中央留干净景窗供引擎叠头像）
- 用途：座位面板头像景窗框（render.gd.part:6981 `make_avatar_view` 当前仅几何框，无国风景窗插画）。
- 接入点：`draw_seat` 内头像区。
- 构图：锦缎卷轴景窗 + 金箔卡边，缘边水墨山影；中心暗/干净由引擎叠头像。
- 避免：文字、Logo、人物、脸部、写实相框、巴洛克风。

Prompt:

```text
Create a Chinese guofeng avatar scenic frame for a mahjong game seat panel.
Asset type: reusable PNG frame, 384x384, with a clean central window cut for the engine-drawn avatar.
Subject: a brocade scroll window with gold foil card border and faint ink landscape at the rim; the central area is left dark/clean (engine overlays the avatar inside).
Style: Chinese ink wash, gold foil card edge, jade silk border; premium seat-portrait frame.
Composition: centered square frame, large clean central window, symmetric border, safe outer margin.
Color palette: deep jade, warm gold border, muted teal silk, small cinnabar corner seal, ink center.
Constraints: no text, no logo, no watermark, no people, no faces.
Avoid: photoreal frame, neon, western baroque, busy center.
```

---

## 接入步骤（每张图）

1. 用上面 Prompt 生成 PNG，放入对应保存路径。
2. 在 `scripts/main_base.gd` 的 `GPT_ILLUSTRATION_ASSET_PATHS` 字典登记该 key。
3. 在对应渲染函数里调 `add_optional_gpt_illustration_texture(panel, "<key>", rect, alpha, false)`（仿 `screens.gd.part:695` 的 `stats_gpt` 用法）——文件缺失时游戏继续用现有 UI，存在则自动叠加。
4. 可选：在 `scripts/offline_smoke_test.gd` 加「存在时显示、缺失时不报错」断言。
5. `python3 tools/assemble_main.py --verify` 校验一致性。

---

## ⚠️ 重要纠偏：上轮 41-48 中 8 张图磁盘已存在

第二轮审计时核对 `assets/illustrations/` 发现，下列 8 张图**实际已生成并落盘**（均为真实 PNG，非占位），
但**在 `GPT_ILLUSTRATION_ASSET_PATHS` 字典中未登记、代码里零引用**——是「已生成未接入」的孤儿图。
意味着**无需重新生成，只需登记 key + 接入渲染函数**即可启用，41-48 里的 Prompt 留作历史记录。

| key | 磁盘文件 | 尺寸 | 字节 | 上轮 Prompt 编号 |
|---|---|---|---|---|
| `daily_login_milestone_seal` | 已存在 | 256×256 | 121 KB | 41 |
| `lobby_room_gate_token` | 已存在 | 768×256 | 404 KB | 42 |
| `exit_save_scroll` | 已存在 | 1024×256 | 493 KB | 43 |
| `stats_winrate_scroll` | 已存在 | 512×256 | 222 KB | 44 |
| `rules_pattern_quads` | 已存在 | 512×128 | 110 KB | 45 |
| `diagnostic_wave_hero` | 已存在 | 1280×180 | 449 KB | 46 |
| `center_wind_pointer` | 已存在 | 256×256 | 102 KB | 47 |
| `seat_avatar_scenic_frame` | 已存在 | 384×384 | 233 KB | 48 |

> 另有两张孤儿图 `table_ink_wash`（1024×1024）与 `menu_hero_painting`（960×540）磁盘有但未在字典登记，
> 若属于既有功能应一并核对是否漏登记。

---

## 第二轮审计追加：对局内 + 元界面（49+）

以下为第二轮 Explore 审计新增的图片与动效缺口，每点带 `file:line` 锚点。
风格基线同前（国风水墨 / 深墨绿·玉色·金箔·少朱砂 / 无文字 Logo 人物脸 / 暗色水墨底 / RGBA PNG）。

### 49. `wall_strip_landscape.png`（牌墙条带插画）

- 保存路径：`assets/illustrations/wall_strip_landscape.png`
- 推荐尺寸：`1024x128`（横向条带；纵向版另出 `wall_strip_portrait.png` 512×256）
- 用途：牌墙底层条带插画。当前 `make_wall_back_tile`（`render.gd.part:11663-11688`）仅用 `Panel` + 稀薄 `tile_back.png` + "云"字 `make_label`，整个 `draw_walls:10149` 与 `make_wall_back_strip:2953` 无独立牌墙插画，牌墙与手牌背面共用一张 `tile_back.png`。
- 接入点：`make_wall_back_strip` / `draw_walls` 横墙条带。
- 构图：深墨青底、金箔细描云纹回环、边沿极淡朱砂晕染，突出条状层叠堆叠感；横向可无缝平铺。
- 避免：文字、Logo、人物、可读牌面。

Prompt:

```text
Create a Chinese guofeng mahjong wall-back strip illustration for the table wall.
Asset type: reusable PNG strip, 1024x128, tileable left-to-right.
Subject: stacked mahjong tile-back wall seen edge-on, with subtle stacked-layer depth; no readable tile faces.
Style: Chinese ink wash, gold-foil cloud scroll pattern, deep teal ink backing, faint cinnabar rim bloom.
Composition: horizontal repeating strip, even thickness, safe margin top and bottom, no central focal.
Color palette: deep teal-black, warm gold cloud lines, tiny cinnabar rim, jade undertone.
Constraints: no text, no logo, no watermark, no people, no readable tile symbols.
Avoid: photoreal tile photography, neon, western tile backs, busy center focal.
```

### 50. `win_cover_self_draw.png` / `win_cover_deal_in.png` / `win_cover_draw_game.png`（三结局封面）

- 保存路径：`assets/illustrations/win_cover_self_draw.png` / `..._deal_in.png` / `..._draw_game.png`
- 推荐尺寸：`1024x256` each
- 用途：自摸/点炮/流局揭示封面。当前 `play_fx_win_burst_enhanced:12855` 与 `draw_win_celebration_art:10158` 三种结局仅靠 `make_panel`/`make_color_rect` 几何区分轨道/冠/缎带，通用 `win_celebration_gpt_burst`/`win_resolution_seal`/`win_result_stage` 各一张共用，无结局差异化封面。
- 接入点：`play_fx_win_burst_enhanced` 按 `win_type` 分支选图。
- 构图：
  - 自摸：玉青色墨晕中心莲开，金线放射；
  - 点炮：朱砂金线「点」字封印风，留中央暗；
  - 流局：灰墨残卷留白，无人物。
- 避免：文字、Logo、人物、可读牌面。

Prompt（自摸，其余替换主体与色调关键词）:

```text
Create a Chinese guofeng self-draw (zimo) win cover for a mahjong mobile game.
Asset type: reusable PNG cover strip, 1024x256.
Subject: a jade-ink lotus bloom opening in the center with gold radial lines — conveys self-drawn win — dark clean center for engine overlay.
Style: Chinese ink wash, gold foil rays, jade lotus; celebratory but restrained, no characters.
Composition: horizontal cover, centered lotus, soft mist edges, safe margin.
Color palette: jade green, ink black, warm gold rays, tiny cinnabar center dot.
Constraints: no text, no logo, no watermark, no people, no readable tile symbols.
Avoid: neon, photoreal flowers, western victory laurel, busy center.
```

### 51. `gang_closeup_concealed.png` / `gang_closeup_open.png` / `gang_closeup_added.png`（杠特写）

- 保存路径：`assets/illustrations/gang_closeup_concealed.png` / `..._open.png` / `..._added.png`
- 推荐尺寸：`256x256` each
- 用途：暗/明/补杠特写插画。当前 `play_fx_gang_burst:12658` 仅按 `gang_type` 改 `accent` 颜色与 rail 比例，全部奔几何绘制 route/fill/gate/quad_node，无任何 `add_illustration_texture`。
- 接入点：`play_fx_gang_burst` 按 `gang_type` 选图叠加。
- 构图：
  - 暗杠：深紫墨四方闭合印；
  - 明杠：金箔四联竖立；
  - 补杠：玉色嵌补缺口纹。
- 避免：文字、Logo、人物、可读牌面。

Prompt:

```text
Create a Chinese guofeng concealed-gang (ankan) closeup emblem for a mahjong mobile game.
Asset type: reusable PNG emblem, 256x256.
Subject: a deep purple-ink four-square closed seal matrix — conveys a concealed quad — symmetrical,centered, dark clean center for engine overlay.
Style: Chinese ink wash, gold foil grid, jade seal wax; premium emphatic emblem.
Composition: centered symmetric seal, generous safe margin, faint inner glow.
Color palette: deep purple-black, warm gold grid, jade seal, tiny cinnabar corner.
Constraints: no text, no logo, no watermark, no people, no readable tile symbols.
Avoid: neon, photoreal tiles, western shield, off-center.
```

### 52. `petals_spring.png` / `petals_summer.png` / `petals_autumn.png` / `petals_winter.png`（四季补花）

- 保存路径：`assets/illustrations/petals_{spring,summer,autumn,winter}.png`
- 推荐尺寸：`128x128` each
- 用途：四季补花花瓣插画。当前 `play_fx_flower_bloom:12528` 仅复用 `flower_gpt_bloom` 一张，8 片花瓣全是 `Panel` + 随机 `Color`（无季节区分）；`seat_flower_gpt_strip:7156` 单条共用。
- 接入点：`play_fx_flower_bloom` 按 seat 季节/花牌取对应花瓣图。
- 构图：春梅淡粉 / 夏荷玉青 / 秋菊金箔 / 冬竹墨绿，无脸无字。
- 避免：文字、Logo、人物、可读牌面。

Prompt（春，其余替换花与色调）:

```text
Create a Chinese guofeng spring plum petal cluster for a mahjong game flower-bloom effect.
Asset type: reusable PNG petal cluster, 128x128, transparent-friendly dark ink backing.
Subject: a few pale-pink plum blossom petals drifting, soft and clean — conveys spring bloom, no flowers faces.
Style: Chinese ink wash, soft petals, tiny gold stamen dots; delicate.
Composition: scattered petals, generous safe margin, no hard focal.
Color palette: pale pink, ink black backing, tiny gold stamen, jade undertone.
Constraints: no text, no logo, no watermark, no people, no readable tile symbols.
Avoid: photoreal petals, neon, western cherry-blossom cliché, busy center.
```

### 53. `dealer_seal.png`（庄家徽章）+ `dealer_repeat_ring.png`（连庄环）

- 保存路径：`assets/illustrations/dealer_seal.png`（256×256）/ `assets/illustrations/dealer_repeat_ring.png`（256×256）
- 用途：庄家/连庄徽章独立插画。当前 `draw_seat:7031-7033` 庄家徽章纯 `make_badge`；`9551-9555` "连庄"亦纯 `make_badge` + `make_panel` route，无插图。
- 接入点：`draw_seat` 庄家徽章 + `draw_games` 连庄计数。
- 构图：朱砂方印嵌金色"庄"字位（中心暗供引擎叠 glyph）/ 连庄金箔环按计数叠加。
- 避免：文字、Logo、人物、可读牌面。

Prompt:

```text
Create a Chinese guofeng dealer seal for a mahjong game seat panel.
Asset type: reusable PNG seal, 256x256.
Subject: a cinnabar square seal with a gold inlay glyph slot — conveys the dealer — clean dark center for engine overlay.
Style: Chinese ink wash, gold foil seal rim, jade silk corner; premium seat marker.
Composition: centered square seal, generous safe margin, faint inner glow.
Color palette: cinnabar, warm gold rim, ink black backing, jade undertone.
Constraints: no text, no logo, no watermark, no people, no readable tile symbols.
Avoid: photoreal stamp, neon, western badge, busy center.
```

### 54. `center_active_bloom.png`（中央盘活跃态）

- 保存路径：`assets/illustrations/center_active_bloom.png`
- 推荐尺寸：`256x256`
- 用途：中央盘活跃态金线绽放插画。当前 `draw_center:1323` 活跃区分仅靠 `accent` 颜色 `make_panel`（phase ribbon 1592、pulse 1602），`center_focus_mandala` 仅作微旋转 halo（1594），无活跃态专用插画。
- 接入点：`draw_center` 活跃态层。
- 构图：玉青团花中心向外金线辐射，边沿墨色羽毛纹扩散。
- 避免：文字、Logo、人物、可读牌面。

Prompt:

```text
Create a Chinese guofeng center-panel active-state bloom for a mahjong game table.
Asset type: reusable PNG overlay, 256x256.
Subject: a jade rosette with gold radial filaments blooming outward, ink feather rim — conveys the active turn — clean dark core.
Style: Chinese ink wash, gold foil filaments, jade rosette; premium active marker.
Composition: centered radial bloom, generous safe margin, faint outer feather fade.
Color palette: jade green, warm gold rays, ink black, tiny cinnabar core.
Constraints: no text, no logo, no watermark, no people, no readable tile symbols.
Avoid: neon, photoreal flower, western mandala clash, busy center.
```

### 55. `guide_pointing_finger.png`（教程引导手势）

- 保存路径：`assets/illustrations/guide_pointing_finger.png`
- 推荐尺寸：`128x128`
- 用途：教程引导手指/箭头插画。当前 `draw_hand_tutorial_hint_art:3717` 用 `hand_tutorial_scroll` + `hand_tutorial_gpt_hint` 一张，高亮本身是 `make_panel` 涟漪 + lucide icon，丢弃流 `draw_hand_tutorial_discard_flow:3671` 纯几何。
- 接入点：`draw_hand_tutorial_hint_art` / `draw_hand_tutorial_discard_flow`。
- 构图：金箔水墨勾勒指向手指，无手部，仅虚化指尖光晕与墨迹箭头。
- 避免：文字、Logo、人物面、真实手部。

Prompt:

```text
Create a Chinese guofeng tutorial guide pointing indicator for a mahjong game.
Asset type: reusable PNG indicator, 128x128, transparent-friendly dark ink backing.
Subject: a stylized pointing fingertip glow with an ink arrow — conveys "tap here" — no real hand, no face.
Style: Chinese ink wash, gold foil fingertip halo, ink arrow tail; soft instructive.
Composition: diagonal pointing motif, generous safe margin, soft glow.
Color palette: warm gold halo, ink black, jade undertone, tiny cinnabar tip.
Constraints: no text, no logo, no watermark, no people, no faces, no real hands.
Avoid: neon, photoreal hand, western cursor arrow, busy center.
```

### 56. `fly_transition_flip.png`（摸牌飞行翻面过渡）

- 保存路径：`assets/illustrations/fly_transition_flip.png`
- 推荐尺寸：`128x128`
- 用途：摸牌飞行中段过渡（背面→正面）。当前 `play_tile_fly_animation:13347` 仅 `make_tile_view` 一张飞行牌 + 线 route，中途无亮灭/翻面过渡；`flying_tile_arc` 挂在 route art 但未做帧序。
- 接入点：`play_tile_fly_animation` 飞行中段叠加。
- 构图：金线弧迹 + 水墨飞溅点，半透背→正转化。
- 避免：文字、Logo、人物、可读牌面。

Prompt:

```text
Create a Chinese guofeng tile-fly mid-transition spark for a mahjong game.
Asset type: reusable PNG transitional sparkle, 128x128, transparent-friendly dark ink backing.
Subject: a gold arc trail with ink splatter specks and a half-turned tile silhouette — conveys back-to-face tile transition.
Style: Chinese ink wash, gold foil arc, ink spatter; dynamic but unobtrusive.
Composition: diagonal arc, scattered specks, generous safe margin, no hard focal.
Color palette: warm gold arc, ink black, jade speck, tiny cinnabar tip.
Constraints: no text, no logo, no watermark, no people, no readable tile symbols.
Avoid: neon, photoreal tile, western motion blur, busy center.
```

### 57-62. 元界面新增图（商店道具 / 成就奖章 / 三甲绶带 / 赛季奖杯 / 校验封缄 / 发送印章）

以下为元界面审计新增，部分**已有现成孤儿图可考虑复用**（见各自标注）。

#### 57. `shop_charm_{huan,kan,yun,bei}.png`（4 张商店道具独立符牌）256×256
- 用途：`draw_shop_item_row_art`（`render.gd.part:8060-8085`）所有商品共用 `shop_item_shelf` 一张，只靠 `item_short_mark`「换/看/运/倍」文字区分，无独立道具插画。
- 构图：国风护符形，金线压边，朱砂一点，中央留白供引擎叠 glyph。

Prompt:

```text
Create a Chinese guofeng shop-item charm emblem for a mahjong game store row.
Asset type: reusable PNG charm, 256x256, transparent-friendly dark ink backing.
Subject: a guofeng talisman with gold-foil border and a cinnabar dot — conveys a purchasable charm — clean dark center for engine overlay.
Style: Chinese ink wash, gold foil calligraphic edge, jade tassel tail; premium shop icon.
Composition: centered charm, generous safe margin, faint inner glow.
Color palette: warm gold border, deep jade, tiny cinnabar dot, ink backing.
Constraints: no text, no logo, no watermark, no people, no readable tile symbols.
Avoid: neon, photoreal prop, western loot icon, busy center.
```

#### 58. `achievement_medal_{bronze,jade,gold}.png`（3 档差异化奖章）256×256
- 用途：`achievement_medal_glow`（`render.gd.part:6137,6235`）全部成就复用一张发光底纹，各行奖章是纯几何 `make_panel` + `achievement_short_mark` 文字（`render.gd.part:77-79`）。
- 构图：铜鉴 / 玉璧 / 金章三档，国风圆形勋章，金箔鳞纹边，玉色绶带尾，中心暗。

Prompt:

```text
Create a Chinese guofeng achievement medal for a mahjong game unlock row (gold tier).
Asset type: reusable PNG medal, 256x256, transparent-friendly dark ink backing.
Subject: a round guofeng medal with gold-foil scale rim and a jade ribbon tail — conveys a high-tier unlock — clean dark center for engine overlay.
Style: Chinese ink wash, gold foil scales, jade ribbon; premium achievement tablet.
Composition: centered circular medal, generous safe margin, soft inner glow.
Color palette: warm gold, deep jade ribbon, ink backing, tiny cinnabar core.
Constraints: no text, no logo, no watermark, no people, no readable tile symbols.
Avoid: photoreal medal, neon, western trophy, busy center.
```

#### 59. `rank_ribbon_{gold,silver,bronze}.png`（三甲锦绶）256×128
- 用途：`draw_round_summary_rank_row`（`render.gd.part:6307`）四名共用同一 `rank_row_ribbon`，仅靠 `make_badge` "第%d" 文字（`render.gd.part:6313`）区分，无金/银/铜差异化图。
- 构图：金箔满纹冠 / 玉色银绶 / 铜褐素绶，左端留干净供引擎叠名次号。

Prompt:

```text
Create a Chinese guofeng rank ribbon banner for a mahjong round summary (gold tier).
Asset type: reusable PNG ribbon, 256x128, transparent-friendly dark ink backing.
Subject: a guofeng brocade ribbon with gold-foil weave and a clean left slot — conveys first place — no digits.
Style: Chinese ink wash, gold foil brocade, jade silk tassel; premium rank banner.
Composition: horizontal ribbon, clean left emblem slot, safe margin.
Color palette: warm gold weave, deep jade silk, ink backing, tiny cinnabar thread.
Constraints: no text, no digits, no logo, no watermark, no people.
Avoid: photoreal sash, neon, western podium banner, busy center.
```

#### 60. `season_trophy_loop.png`（赛季奖杯璎珞）256×256
- 用途：`menu_season_scroll`（`render.gd.part:5004`）仅一段进度卷轴，无段位里程碑/奖杯插画。
- 构图：金线卷轴托翠玉段位印，朱砂节点沿卷，中心暗供引擎叠段位名。

Prompt:

```text
Create a Chinese guofeng season trophy for a mahjong game season progress.
Asset type: reusable PNG trophy, 256x256, transparent-friendly dark ink backing.
Subject: a gold scroll cradling a jade rank seal with cinnabar milestone nodes along its length — conveys season rank — clean dark center for engine overlay.
Style: Chinese ink wash, gold-foil scroll, jade seal; premium season trophy.
Composition: centered trophy, generous safe margin, faint inner glow.
Color palette: warm gold scroll, deep jade seal, tiny cinnabar nodes, ink backing.
Constraints: no text, no logo, no watermark, no people, no readable tile symbols.
Avoid: photoreal trophy, neon, western league badge, busy center.
```

#### 61. `update_verify_stamp.png`（校验封缄印）256×256
- 用途：`draw_update_dialog_art` 校验节点（`render.gd.part:9766-9768`）与 install gate（`render.gd.part:9793-9796`）都是几何 + lucide `shield-check` + 文字「装」，无校验通过盖章差异插画。
- 构图：朱砂方印套金圈「验」字位，中心暗供引擎叠状态。

Prompt:

```text
Create a Chinese guofeng verify-and-install seal stamp for a mahjong game update dialog.
Asset type: reusable PNG stamp, 256x256, transparent-friendly dark ink backing.
Subject: a cinnabar square seal inside a gold ring — conveys verified-integrity — clean dark center for engine overlay.
Style: Chinese ink wash, gold foil ring, cinnabar seal wax; premium progress stamp.
Composition: centered seal, generous safe margin, faint inner glow.
Color palette: cinnabar, warm gold ring, ink backing, jade undertone.
Constraints: no text, no logo, no watermark, no people, no readable tile symbols.
Avoid: neon, photoreal stamp, western check badge, busy center.
```

#### 62. `chat_send_seal.png`（发送封缄印章 icon）128×128
- 用途：聊天面板 head 用通用 lucide `users`（`render.gd.part:1911`），无发送/麦克风专属图标；语音按钮有 `voice_wave` 但「发送」语义无图。
- 构图：国风朱砂印章式发送封缄 icon，金边方印，朱砂满底，中心暗。

Prompt:

```text
Create a Chinese guofeng send-seal icon for a mahjong game chat send button.
Asset type: reusable PNG icon, 128x128, transparent-friendly dark ink backing.
Subject: a cinnabar square seal with a gold foil border — conveys "send/seal message" — clean dark center for engine overlay.
Style: Chinese ink wash, gold foil border, cinnabar fill; compact chat action icon.
Composition: centered seal, generous safe margin, no hard edges.
Color palette: cinnabar, warm gold border, ink backing, jade undertone.
Constraints: no text, no logo, no watermark, no people, no faces.
Avoid: neon, photoreal stamp, western paper-plane icon, busy center.
```

---

## 第二轮：动画/特效缺口（B 列，直接落 GDScript，无需生图）

以下每项给 `file:line` 锚点与建议动效，沿用既有 tween / `play_fx_*` 语汇。

### 对局内

- **B-G1 手牌 hint/风险徽章呼吸** — `draw_tile_status_route_art:9368-9379` route/fill/gate 全 `make_panel` 无 tween；`draw_hand_tray_suit_flow:3613` 的 `HandTraySuitDangerGlow`(3666-3668) 静态。建议：摸到可胡/可杠牌时 hint_badge 玉色呼吸环 + danger glow 红光脉冲。
- **B-G2 听牌徽章呼吸** — `hand_tile_hint_badge`(line ~6666) 文本徽章只静态显示。建议：「听」徽章 1.2s `set_loops` 玉色外扩呼吸。
- **B-G3 庄家徽章轻摇 / 连庄环点亮** — `draw_seat:7031` 庄家 `make_badge` 无补间；`9551-9555` 连庄无旋转/呼吸。建议：庄家朱砂印轻摇 + 连庄金环逐圈点亮。
- **B-G4 弃牌河新张滴入** — `draw_last_discard_focus_marker:3908` 已有 aura 呼吸(3921-3927)，但 route_fill/source_dot 就位是单次绘制无入场补间；弃牌河整体无「新一张滑入」动效。建议：新张水墨滴入错峰扩散。
- **B-G5 副露逐张错峰就位** — `play_claim_animation:11931` 调单张飞牌 + `play_claim_resolution_art`，但 `make_meld_group_view:11077` 直接 `HBoxContainer.add_child` 一次到位。建议：碰杠吃副露 3-4 张逐张翻落入座、杠最后一张「立起」缓动。
- **B-G6 自摸胡牌逐张翻面** — `play_fx_win_burst_enhanced:12855` 仅印章弹出+圆环扩散；`play_card_flip_animation:11729` 仅用于菜单卡片。建议：胡牌时赢家手牌按花色/序逐张翻红光升起。
- **B-G7 牌墙余牌层叠塌缩** — `draw_top_hud_wall_meter:9621` 的 `low_pulse` 有呼吸，但 `TopHudWallStackLayer_0..2`(9646-9648) 静态。建议：余牌 ≤24 时墙层逐层淡出下沉。
- **B-G8 威胁 readiness 印章呼吸** — `draw_seat_threat_badge_art:7315` 中 `readiness` 印章(7352-7353) 静态 `make_panel`，未与 pressure 同步。建议：按 score 强度金光呼吸。

### 元界面

- **B-M1 成就解锁金光弹入+盖章** — `draw_achievement_row_art:71-133` 仅 unlocked 时多画一个静态 `AchievementRowUnlockedShine`；(126-129) 无 tween；toast `draw_achievement_toast_art:136` 静态。建议：行 fade+slide + 盖章 scale-from-1.3 → ease-out。
- **B-M2 商店道具行 shelf-slide 错峰** — `draw_shop_item_row_art:8060` 行静态出现，仅 `price_aura` 循环呼吸(8135-8139)。建议：每行错峰从左 -12px 滑入 + fade（仿胜利结算行 6343-6352）。
- **B-M3 设置开关 knob 滑动** — `draw_setting_switch_art:7508` knob 由 enabled 二值硬切(7535)；`play_settings_action_feedback:874` 仅叠 seal flash。建议：toggle 时 knob 0.18s `TRANS_BACK` 从旧位 tween 到新位。
- **B-M4 更新下载进度条连续** — `refresh_update_dialog_art:786-797` 直接 `apply_rect` 重设宽度无 tween，与上半 `AnimationEffects.animate_progress_bar` 连续性不一致。建议：fill 宽度 0.2s tween 到 target。
- **B-M5 联机连接成功脉冲** — `draw_online_lobby_feedback_sync_art:5461-5506` 仅 waiting 时 fill 循环，`online_waiting_for_server=false` 后无成功收束。建议：success 时 gate scale-pulse 一次 + fill 收束到满 + seal stamp 弹入。
- **B-M6 每日签到领取 bounce/sparkle** — `_play_reward_claim_animation`(core.gd.part:26) 存在，但第 7 日里程碑节点(screens.gd.part:954-972)静态几何无 bounce；`draw_daily_login_reward_art:2210-2213` 里程碑 burst 静态矩形。建议：领取时 reward_panel scale 1→1.12→1 + `create_enhanced_starlight`。
- **B-M7 规则 section 错峰入场** — `draw_rules_*_art` 系列(6603/6649/6695/6731)静态摆位。建议：基础/番型/流程/礼仪四模块错峰 fade+slide 120ms。
- **B-M8 成就/商店面板行集合错峰** — `_show_achievements_screen_impl`(screens.gd.part:1-56) 与 `_show_shop_screen_impl`(screens.gd.part:490) 的行集合静态铺开。建议：行集合按 index 0.06s 错峰 fade-in（仿结算排名行 `delay = 0.14 + (rank-1)*0.072`）。

> 已完善（确认跳过，第二轮复核）：胜利庆祝层、加载页、聊天面板底纹、语音按钮脉动/波形、设置面板整体滑入、中心低墙警告呼吸、威胁雷达 drift+呼吸、中心 phase ribbon halo 旋转、座位 turn_handoff art、飞牌弧线 trail 粒子。


---

## 第三轮：替换代码自绘线条的底板插画（C 列，需生图）

起因：操作按钮与行动意图 dock 内部原先塞满代码自绘的 route/fill/gate/tick 微装饰碎块（`draw_action_button_art`/`draw_action_intent_*` 等），在按钮内叠 ~18 个 `ColorRect`/`Panel` + 无限循环呼吸 tween，读作"碎色仪表盘"，与国风水墨主基调冲突。本轮已将这些**纯装饰碎块删去**，改为在按钮/dock 内层铺一张可选 GPT 底板插画（`add_optional_gpt_illustration_texture` 在 PNG 缺失时返回 `null`，按钮即回落为干净的文字+icon+role 色）。下列两张底板若生出并落盘登记，即可让按钮/dock 拥有国风底纹而不靠代码描线。统一风格基线沿用既有：国风水墨，深墨绿/温润玉色/金箔/少朱砂，**无文字/Logo/水印/人物脸**，暗色水墨底便于低透明度叠加，RGBA PNG。

### C1. `action_button_panel.png`

- 保存路径：`assets/illustrations/action_button_panel.png`
- 推荐尺寸：`256x96`
- 用途：吃碰杠胡/暗杠/补杠/自摸/过/重开/提示/安全/推荐等操作按钮的内层底板纹理，叠 alpha≈0.28（过按钮叠 0.20）。接入点：`scripts/main_src/render.gd.part` 的 `draw_action_button_art`（已加 `add_optional_gpt_illustration_texture(button, "action_button_panel", rect_full(-0.04,-0.04,1.04,1.04), 0.20 if role=="pass" else 0.28, false)`，命名 `ActionButtonPanelPlate`）。登记 key：`scripts/main_base.gd` 的 `GPT_ILLUSTRATION_ASSET_PATHS` 加 `"action_button_panel": "res://assets/illustrations/action_button_panel.png"`，并确保 `optional_gpt_illustration_texture` 能解析。
- 构图：横长条按钮底板，左侧一根细金线竖封、右下角一处淡朱砂落款位、中部留干净叠加区（引擎叠 lucide 图标/文字/role 色）；墨色底便于低透明度叠加，不喧宾夺主。
- 避免：文字、Logo、人物脸、可读牌面、亮色块、霓虹。

Prompt:

```text
Create a Chinese guofeng action-button panel backdrop for a mahjong mobile game.
Asset type: reusable PNG panel texture, 256x96, transparent-friendly dark ink backing, designed to sit under text and an icon at low alpha.
Subject: a slim horizontal button panel with a thin gold foil vertical seal on the left, a soft cinnabar under-stamp mark near the lower right corner, and a clean central field left empty for engine overlay of an icon and text.
Style: Chinese ink wash, jade-green and gold filigree edges, muted ink-black body; premium mobile game action button base.
Composition: horizontal panel, generous safe margin, low-contrast, balanced left/right weight, soft inner shading.
Color palette: deep jade black body, warm gold seal line, very small cinnabar corner mark.
Constraints: no text, no logo, no watermark, no people, no readable tile symbols, no busy center.
Avoid: neon, photoreal, western UI chrome, bright dominant fills, high contrast.
```

### C2. `intent_panel_plate.png`

- 保存路径：`assets/illustrations/intent_panel_plate.png`
- 推荐尺寸：`512x128`
- 用途：行动意图横条（"等待出牌/可吃可碰/有暗杠/已听牌"等意图提示条）的底板纹理，叠 alpha≈0.22。接入点：`scripts/main_src/render.gd.part` 的 `draw_action_intent_dock`（已加 `add_optional_gpt_illustration_texture(intent, "intent_panel_plate", rect_full(-0.02,0.04,1.02,0.96), 0.22, false)`，命名 `IntentPanelPlate`）。登记 key：`scripts/main_base.gd` 的 `GPT_ILLUSTRATION_ASSET_PATHS` 加 `"intent_panel_plate": "res://assets/illustrations/intent_panel_plate.png"`。
- 构图：横向带状底板，金线栏边框包裹，中央留干净文字区（引擎叠意图文字与 lucide 图标），右端一处朱砂计数窗（引擎叠「N 项」计数徽章）；墨色底便于低透明度叠加。
- 避免：文字、数字、Logo、人物、可读牌面、亮色块。

Prompt:

```text
Create a Chinese guofeng intent-panel plate for a mahjong mobile game top action strip.
Asset type: reusable PNG banner texture, 512x128, transparent-friendly dark ink backing, designed to sit under intent text and a count badge at low alpha.
Subject: a horizontal ribbon plate framed by thin gold ink borders, a clean central field left empty for engine overlay of intent text and an icon, and a small cinnabar counting window near the right end for a count badge.
Style: Chinese ink wash, jade and gold border filigree, muted ink-black ribbon; premium mobile game status/banner plate.
Composition: horizontal banner, generous safe margin, low-contrast, balanced center and right weighting, soft inner glow.
Color palette: deep jade black ribbon, warm gold frame lines, very small cinnabar right-end window.
Constraints: no text, no digits, no logo, no watermark, no people, no readable tile symbols, no busy center.
Avoid: neon, photoreal, modern UI chrome, high contrast, ornament clutter.
```

---

## 第三轮补充（C3-C8）：剩余重度代码自绘装饰簇的底板插画

用途同 C 列：删去相应函数内的 rail/fill/gate/tick 等代码自绘微装饰，改叠可选底板插画（`add_optional_gpt_illustration_texture` 缺图返回 null，回退干净）。下列每张新增一张后即可整段装饰簇改为底板叠层 + 保留必要文字/计数/状态节点；**本轮已落代码的只有 C1/C2，下列 C3-C8 为下一轮改造的待补资产，需先有图再动 part**。统一风格基线沿用既有国风水墨深墨绿/温润玉色/金箔/少朱砂，无文字/Logo/水印/人物脸，RGBA PNG。

### C3. `rules_guide_panel.png`

- 保存路径：`assets/illustrations/rules_guide_panel.png`
- 推荐尺寸：`960x160`
- 用途：规则页"目标→组牌→听牌→胡牌"四步导览横条底板（`draw_rules_guide_art` 当前用 rail/rail_fill/gate/RhythmTick/LeadGlow + 四步 node + connector 描线）。
- 接入点（下一轮）：`scripts/main_src/render.gd.part` `draw_rules_guide_art`，叠 `add_optional_gpt_illustration_texture(art, "rules_guide_panel", rect_full(-0.02,-0.05,1.02,1.05), 0.30)`，保留四步 node 的 lucide icon + 文字标签。
- 构图：横向四段式水墨画卷底板，四段间留干净节点位（引擎叠 lucide 图标），底部一笔金线贯通，右端淡朱砂落款位。
- 避免：文字、Logo、人物、可读牌面。

Prompt:

```text
Create a Chinese guofeng rules-guide panel for a mahjong game tutorial strip.
Asset type: reusable PNG banner texture, 960x160, transparent-friendly dark ink backing.
Subject: a horizontal four-segment scroll panel with a continuous base brush stroke and gold under-line; four even clean segment cells left empty for engine overlay of step icons and labels (target -> group -> tenpai -> win); a small cinnabar stamp mark near the right end.
Style: Chinese ink wash, jade and gold scroll, soft ink-black segments; premium mobile tutorial ribbon.
Composition: horizontal banner, four balanced segments, generous safe margin per cell, low-contrast body, soft inner glow on each cell.
Color palette: deep jade black scroll, warm gold under-line and segment dividers, very small cinnabar corner stamp.
Constraints: no text, no logo, no watermark, no people, no readable tile symbols, no busy segments.
Avoid: neon, photoreal, modern UI chrome, high contrast, ornament clutter in cells.
```

### C4. `rules_reading_progress_panel.png`

- 保存路径：`assets/illustrations/rules_reading_progress_panel.png`
- 推荐尺寸：`960x80`
- 用途：规则页顶部阅读进度条底板（`draw_rules_reading_progress_art` 当前用 rail/fill/source/gate/Node_/Drop_/Tick_ 描线 + 呼吸 tween，0 处冒烟断言）。
- 接入点（下一轮）：`render.gd.part` `draw_rules_reading_progress_art`，叠 `add_optional_gpt_illustration_texture(art, "rules_reading_progress_panel", rect_full(-0.02,-0.05,1.02,1.05), 0.26)`，进度 fill 仍由代码绘制（动态）。
- 构图：横向窄卷条底板，金线两端封边，中部留干净区由引擎叠动态进度 fill 与 4 个分段 drop。
- 避免：文字、数字、Logo、人物、可读牌面。

Prompt:

```text
Create a Chinese guofeng reading-progress strip panel for a mahjong game rules page.
Asset type: reusable PNG banner texture, 960x80, transparent-friendly dark ink backing.
Subject: a slim horizontal scroll strip with thin gold end caps and a clean central track left empty for engine overlay of a dynamic progress fill and four segment drops.
Style: Chinese ink wash, jade and gold end caps, muted ink-black track; premium mobile progress ribbon.
Composition: horizontal slim banner, generous safe margin, low-contrast track, soft inner glow.
Color palette: deep jade black track, warm gold end caps, very small cinnabar accent.
Constraints: no text, no digits, no logo, no watermark, no people, no readable tile symbols, no busy center.
Avoid: neon, photoreal, modern UI chrome, high contrast, ornament clutter across the track.
```

### C5. `action_dock_track_panel.png`

- 保存路径：`assets/illustrations/action_dock_track_panel.png`
- 推荐尺寸：`1024x128`
- 用途：行动 dock 按钮轨道与节奏点底板（`draw_action_dock` 当前仍用 ButtonTrack/TrackFill/SafeLeft/SafeRight/ButtonSlot_/RhythmDot_/LeftTail/RightTail 描线，被烟测锁死）。
- 接入点（下一轮）：`render.gd.part` `draw_action_dock`，叠 `add_optional_gpt_illustration_texture(dock, "action_dock_track_panel", rect_full(-0.02,-0.10,1.02,1.10), 0.20)`，保留 FocusLabel 文字与按 count 动态的 slot 位置（slot 可保留为极少量细金点或转为图上预设位）。
- 构图：横向按钮轨道底板，两端金线竖封，沿底部一排小金点节奏位（数量按按钮数），中部留干净按钮位。
- 避免：文字、数字、Logo、人物、可读牌面。

Prompt:

```text
Create a Chinese guofeng action-dock track panel for a mahjong game button rail.
Asset type: reusable PNG banner texture, 1024x128, transparent-friendly dark ink backing.
Subject: a horizontal button-rail track panel with gold vertical end caps on both sides, a row of small gold rhythm dots along the base for button slots, and a clean central field left empty for engine overlay of action buttons.
Style: Chinese ink wash, jade and gold track, muted ink-black body; premium mobile game action dock.
Composition: horizontal banner, balanced end caps, low-contrast body, soft rhythm dots baseline, generous safe margin for buttons.
Color palette: deep jade black track, warm gold end caps and rhythm dots, very small cinnabar accent.
Constraints: no text, no digits, no logo, no watermark, no people, no readable tile symbols, no busy center.
Avoid: neon, photoreal, modern UI chrome, high contrast, ornament clutter across the track.
```

### C6. `settings_overview_panel.png`

- 保存路径：`assets/illustrations/settings_overview_panel.png`
- 推荐尺寸：`768x160`
- 用途：设置页概览横条底板（`draw_settings_overview_art` 当前用 Rail/Fill/Node_/StatusLight/SystemBus/SystemBusFill/SystemBusGate/SystemBusTick_/BusPulse_ 描线 + 呼吸 tween，被烟测锁死）。
- 接入点（下一轮）：`render.gd.part` `draw_settings_overview_art`，叠 `add_optional_gpt_illustration_texture(art, "settings_overview_panel", rect_full(-0.03,-0.05,1.03,1.05), 0.26)`，保留 3 段 audio/play/maint 的 `Node_` 状态色（动态）与文字 glyph；删 Rail/Bus/Gate/Tick 装饰并同步放宽烟测。
- 构图：横向三段式设置概览横条底板，左中右三段留干净位（引擎叠 0/3 数字 glyph），右端一处玉色状态灯位。
- 避免：文字、数字、Logo、人物、可读牌面。

Prompt:

```text
Create a Chinese guofeng settings-overview panel for a mahjong game settings page header.
Asset type: reusable PNG banner texture, 768x160, transparent-friendly dark ink backing.
Subject: a horizontal three-segment overview panel with a thin gold rail under-line; three even clean segment cells left empty for engine overlay of enabled/total glyphs; a small jade status-light mark near the right end.
Style: Chinese ink wash, jade and gold rail, muted ink-black segments; premium mobile settings header.
Composition: horizontal banner, three balanced segments, generous safe margin per cell, low-contrast body, soft inner glow on each cell.
Color palette: deep jade black segments, warm gold under-line and dividers, small jade status mark.
Constraints: no text, no digits, no logo, no watermark, no people, no readable tile symbols, no busy segments.
Avoid: neon, photoreal, modern UI chrome, high contrast, ornament clutter in cells.
```

### C7. `settings_section_signal_panel.png`

- 保存路径：`assets/illustrations/settings_section_signal_panel.png`
- 推荐尺寸：`384x160`
- 用途：设置页各分组右上信号横条底板（`draw_settings_section_signal` 当前用 Rail/Icon/Pulse_/_/_/_ 描线，被烟测锁死）。
- 接入点（下一轮）：`render.gd.part` `draw_settings_section_signal`，叠 `add_optional_gpt_illustration_texture(art, "settings_section_signal_panel", rect_full(-0.02,-0.05,1.02,1.05), 0.24)`，保留 lucide icon 与 accent 色；删 Rail/Pulse 装饰。
- 构图：横向窄信号横条底板，左侧留干净图标窗，右端三段淡色脉冲位。
- 避免：文字、Logo、人物、可读牌面。

Prompt:

```text
Create a Chinese guofeng settings-section signal panel for a mahjong game settings page.
Asset type: reusable PNG banner texture, 384x160, transparent-friendly dark ink backing.
Subject: a slim horizontal signal panel with a clean left icon window for a lucide glyph and three soft accent pulse slots along the right.
Style: Chinese ink wash, jade and gold filigree, muted ink-black body; premium mobile settings signal strip.
Composition: horizontal slim banner, balanced left icon window and right pulse slots, generous safe margin, low-contrast body.
Color palette: deep jade black body, warm gold filigree, small jade pulse slots.
Constraints: no text, no logo, no watermark, no people, no readable tile symbols, no busy center.
Avoid: neon, photoreal, modern UI chrome, high contrast, ornament clutter.
```

### C8. `shop_currency_meter_panel.png`

- 保存路径：`assets/illustrations/shop_currency_meter_panel.png`
- 推荐尺寸：`512x128`
- 用途：商店货币计量条底板（`draw_shop_currency_meter_art` 当前描线装饰，被烟测 10 处锁死）。
- 接入点（下一轮）：`render.gd.part` `draw_shop_currency_meter_art`，叠 `add_optional_gpt_illustration_texture(art, "shop_currency_meter_panel", rect_full(-0.02,-0.05,1.02,1.05), 0.24)`，保留 amount 数字与 accent 色；删纯描线装饰并放宽烟测。
- 构图：横向货币计量条底板，左侧金线竖封，中部留干净数字位（引擎叠 amount），右端一处金箔币徽位。
- 避免：文字、数字、Logo、人物、可读牌面。

Prompt:

```text
Create a Chinese guofeng shop currency-meter panel for a mahjong game shop header.
Asset type: reusable PNG banner texture, 512x128, transparent-friendly dark ink backing.
Subject: a horizontal currency-meter strip with a gold vertical seal on the left, a clean central field left empty for engine overlay of the amount, and a small gold-foil coin emblem near the right end.
Style: Chinese ink wash, jade and gold filigree, muted ink-black body; premium mobile game currency bar.
Composition: horizontal banner, generous safe margin, low-contrast body, balanced coin emblem on the right.
Color palette: deep jade black body, warm gold seal and coin emblem.
Constraints: no text, no digits, no logo, no watermark, no people, no readable tile symbols, no busy center.
Avoid: neon, photoreal, modern UI chrome, high contrast, ornament clutter.
```

> 下一轮按 [[code-drawn-lines-to-gpt-plates]] 的 pattern：每张图生盘后，删对应函数内的纯装饰 `make_color_rect`/`make_panel` 簇 → 改叠底板插画 → 保留动态状态节点 → 同步放宽 `scripts/offline_smoke_test.gd` 中的 `find_child`/`count_nodes_with_name_prefix` 断言 → `assemble_main.py` 重生 → `--verify` → headless 烟测。手牌托盘/弃牌河装饰因承载动态游戏状态且烟测深度锁死，**本轮不改造**，留作功能态装饰。
