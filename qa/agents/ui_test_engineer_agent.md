# UI 测试工程师 Agent

执行日期：2026-07-05
工作目录：`/root/yunzhuo-mahjong-godot`

## Agent 职责

- 作为新增 UI 测试工程师，负责把测试工程师提出的截图问题转成可复跑门禁、人工验收准则和工程修复清单。
- 统一调度 `ui_layout_agent.md`、`ui_screenshot_agent.md`、`ui_design_agent.md` 和 `gpt_image_agent.md` 的输入输出。
- 每轮 UI 改动后必须先跑布局/截图脚本，再基于最新单张截图做人工审查；不能用过期 contact sheet 作为结论证据。
- 只对 UI 可读性、布局、触控、风格、截图证据和 GPT 资产安全区负责；玩法正确性仍交给 `e2e_agent.md` 和 `offline_smoke_test.gd`。

## 可执行门禁

```bash
python3 tools/assemble_main.py --check
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 godot --headless --path . -s scripts/ui_layout_smoke_test.gd
GODOT_SILENCE_ROOT_WARNING=1 xvfb-run -a godot --path . -s scripts/page_screenshot_capture.gd
python3 scripts/ui_screenshot_manifest_check.py
```

扩展回归：

```bash
GODOT_SILENCE_ROOT_WARNING=1 godot --headless --path . -s scripts/offline_smoke_test.gd
```

## 截图证据规则

- 最新证据以 `build/qa/pages/*.png` 的单张截图为准。
- `build/qa/pages/contact_sheet.jpg` 必须由 `scripts/ui_screenshot_manifest_check.py` 在本轮重新生成；如果它早于任一页面截图，必须标记为过期。
- 人工报告必须写入 `build/qa/ui_screenshot_review_report.md`，至少记录：页面、严重程度、现象、修复建议、是否需要 GPT 生图。
- 截图只覆盖 `1280x720` 时，不得声称移动端安全区完成；还要依赖 `scripts/ui_layout_smoke_test.gd` 的 `960x540`、`1280x720`、`1920x1080` 几何检查。

## UI 验收准则

- 所有可点击控件最小触控区域不低于 `48x48` 逻辑像素；主操作按钮推荐 `56px` 高，相邻触控区间距不低于 `8px`。
- 人机对战最大响应状态必须截图验收：同时出现 `胡 / 杠 / 碰 / 3 个吃法 / 过` 时，不得遮挡手牌、弃牌河、座位信息。
- 响应区必须和手牌托盘保持清晰层级，推荐固定高度 bottom sheet 或两行网格；长文案使用短标签，例如 `吃3-4-5`。
- 联机大厅输入框、状态牌、房间号和操作按钮必须在移动横屏下无重叠；输入框内装饰不能像可点击控件。
- 商店、成就等列表页最后一行必须完整显示或明确可滚动；滚动条不得覆盖文字或状态徽标。
- 深色国风背景上，正文、价格、状态、输入占位文字必须有本地暗底或描边，禁止直接压在高纹理背景上。
- 禁用态按钮仍需可读：允许降低饱和度，不允许把文字压到接近背景亮度。
- GPT/美术资产不得包含假文字、烘焙棋盘格、疑似按钮但不可点击的强装饰元素；文本和数字由 Godot 原生 UI 覆盖。

## 当前高优先级问题

| 优先级 | 页面 | 问题 | 修复方向 |
|---|---|---|---|
| P1 | `03_offline_battle.png` | 已改善：pending claim 取消重叠的额外意图条，改为单行摘要 + 单一 action dock；本轮已降低 dock/按钮装饰权重并增强与手牌托盘间距。 | 保持布局烟测覆盖 summary/dock/hand tray 间距、GPT dock 透明度和按钮底板透明度；后续只需真机触控手感复核。 |
| P1 | `08_online_lobby.png` | 已改善：输入组和操作组分离，输入框右端装饰和按钮小印章已降噪；本轮已提高右侧玩家席位和房间日志文本层级。 | 保持收紧后的 layout smoke 阈值，覆盖右侧 roster/log 的行高、字号、亮度和裁剪；后续只需真机触控手感复核。 |
| P1 | `06_achievements.png` | 已改善：列表只显示完整行，底部安全区充足；锁定态文字、状态徽记和右侧胶囊已提亮。 | 保持成就页 layout smoke 的完整行、底部安全区和锁定态亮度阈值。 |
| P2 | `04_rules.png` | 已改善：规则正文恢复高亮度，本地文字背板和示例背板降低背景干扰，960x540 下四段内容仍完整。 | 保持规则页 smoke 覆盖标题/正文亮度、裁剪省略、文字与示例 lane 不重叠；不作为生图缺口跟踪。 |
| P2 | `07_shop.png` | 已改善：专属 charm v2 已接入；商品名/说明增加本地背板并提亮，行内路线/刻度已降噪。 | 保持商店 layout smoke 覆盖文字亮度、裁剪和 charm/徽章/购买按钮避让；不再作为生图缺口跟踪。 |
| P2 | `02_menu_settings.png` | 已改善：设置行按钮改为短命令文案，行高和按钮锚点提升到实用触控区，旧长标签已由 smoke test 禁止回归。 | 保持设置页 smoke 覆盖短文本、字号、裁剪、48px 目标高度和旧长标签缺席；不需要生图。 |

## 与其他 Agent 的协作

- `ui_layout_agent.md`：维护可执行几何门禁。
- `ui_screenshot_agent.md`：维护截图集、contact sheet 和人工观感报告。
- `ui_design_agent.md`：给出国风 3D 方向和页面级设计规范。
- `gpt_image_agent.md`：接收需要新 PNG 的问题，生成 prompt/图片并记录交付。
- `e2e_agent.md`：确认 UI 改动没有破坏玩法流程。

## 2026-07-05 新增门禁记录

- `scripts/ui_layout_smoke_test.gd` 在 pending claim 场景中绘制 `HandTray`，并检查 `PendingClaimIllustration`、`ActionButtonDock`、`HandTray` 的垂直间距。
- pending claim 场景明确要求 `ActionIntentDock == null`，避免响应摘要条与意图条再次叠加。
- pending claim 的操作按钮必须使用 compact 样式，不允许重新出现 `ActionButtonEnergyDot_0` 等内部能量点装饰，避免吃碰杠胡区域再次变成元素堆砌。
- 联机大厅房间号输入框必须保留细轨式 `LineEditInputFocusGlow_room`，并检查宽高比例，避免输入框右侧装饰重新变成像可点击控件的圆形/块状按钮。
- `scripts/offline_smoke_test.gd` 已同步为“单一 compact dock”预期：不再要求 pending claim 下存在 `ActionIntentDock` 或 `ActionDockFocusLabel`。

## 2026-07-06 联机大厅控件减噪记录

- `draw_line_edit_input_art()` 降低了输入框右端 focus rail、accent wash、corner seal 的尺寸和透明度，保留材质提示但不再像额外按钮。
- `draw_lobby_action_button_art()` 降低了按钮内部 GPT token、右侧 glow、左侧 seal/glyph 的权重，按钮文本成为主要视觉焦点。
- `scripts/ui_layout_smoke_test.gd` 收紧了对应阈值：输入 focus rail <= 4% 宽/高、corner seal <= 3.5% 宽且 <= 18% 高，按钮右侧 glow <= 4% 宽，按钮 seal <= 10% 宽且 <= 22% 高。
- 最新 `08_online_lobby.png` 与 `pages_960x540/08_online_lobby.png` 已目视确认无重叠，输入框右端装饰为被动细节。

## 2026-07-06 成就页锁定态复核记录

- `06_achievements.png` 与 `pages_960x540/06_achievements.png` 已复核：列表底部不再贴边，当前视口只露出完整成就行。
- 未解锁行的名称、状态、进度门、左侧锁定纹理和右侧状态胶囊均已提亮，但仍保持低于已解锁行的视觉层级。
- 右侧状态胶囊改为短名 / 状态徽记 / 状态文字三段式，未解锁行使用原生 `未` 徽记替代偏黑的 `x-circle` SVG，避免读成可点击或不可读的黑色图标。
- `scripts/ui_layout_smoke_test.gd` 覆盖完整可见行、底部 spacer/fade、锁定文字亮度、锁定状态图标亮度和标签裁剪。

## 2026-07-06 规则页可读性复核记录

- 生图需求先行复核：`rules_gpt_scroll`、`rules_guide_panel`、`rules_reading_progress_panel`、`rules_pattern_quads` 已存在并被运行时消费；注册 PNG 缺失为 0，因此未派发新的 GPT 图片任务。
- `04_rules.png` 与 `pages_960x540/04_rules.png` 已复核：正文行恢复可见且亮度更高，左侧 text lane 和右侧 example lane 有明确分隔。
- `scripts/ui_layout_smoke_test.gd` 现在覆盖规则页四段 section：本地文字背板、标题/正文亮度、裁剪省略策略、示例背板、示例 strip 与文字 lane 不重叠，以及 GPT teaching strip 消费。
- 验证记录：`assemble_main --verify`、`git diff --check`、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`、两套截图 manifest 均通过；headless/offscreen 输出只保留已知音频/资源退出噪声。

## 2026-07-06 Pending-Claim Action Dock 复核记录

- 生图需求先行复核：`gpt-image-2` 默认模式为 `B-or-C`，`GPT_ILLUSTRATION_ASSET_PATHS` 注册 95 个资产且缺失为 0，候选/QA `.import` 噪声为 0；`pending_claim_action_dock` 和 `pending_claim_status_strip` 已存在并被运行时消费，因此未派发新的 GPT 图片任务。
- `03_offline_battle.png` 与 `pages_960x540/03_offline_battle.png` 已复核：pending claim action dock 更轻，dock 下缘与手牌托盘之间保留更清楚的暗带，`胡/杠/碰/吃1-3/吃2-4/吃3-5/过` 仍完整可点。
- `scripts/ui_layout_smoke_test.gd` 现在额外覆盖 pending claim dock 与手牌托盘至少 18px 间距、专用 GPT dock alpha 上限、compact button panel plate alpha 上限，以及既有的无重叠/无长标签/无能量点规则。
- 验证记录：`assemble_main --verify`、`git diff --check`、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`、两套截图 manifest、注册资产缺失检查和候选/QA `.import` 检查均通过；离线 smoke 仅保留已知 headless lambda/ObjectDB 退出噪声。

## 2026-07-06 联机大厅右侧信息层级复核记录

- 生图需求先行复核：`gpt-image-2` 默认模式为 `B-or-C`，注册 GPT 资产 95 个且缺失为 0，候选/QA `.import` 噪声为 0；`online_lobby_panel_frame`、`online_lobby_group_plate`、`online_feedback_gpt_strip` 已存在并消费，因此未派发新的 GPT 图片任务。
- `08_online_lobby.png` 与 `pages_960x540/08_online_lobby.png` 已复核：右侧“玩家席位”和“房间日志”不再像背景纹理，席位行高更稳定，玩家名、状态和日志正文在 960x540 下仍可读。
- `scripts/ui_layout_smoke_test.gd` 现在覆盖右侧 roster/log 文本：席位行高、name/state 标签存在、字号下限、字体亮度、裁剪策略和日志正文字号/亮度。
- 验证记录：`assemble_main --verify`、`git diff --check`、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`、两套截图 manifest、注册资产缺失检查和候选/QA `.import` 检查均通过；headless/offscreen 输出只保留已知音频/资源退出噪声。

## 2026-07-06 统计页小屏行高复核记录

- 生图需求先行复核：`gpt-image-2` 默认模式为 `B-or-C`，注册 GPT 资产 95 个且缺失为 0，候选/QA `.import` 噪声为 0；`stats_gpt_dashboard` 与 `stats_winrate_scroll` 已存在并被统计页消费，因此未派发新的 GPT 图片任务。
- `05_stats.png` 与 `pages_960x540/05_stats.png` 已复核：顶部摘要改为三个本地 summary chip，6 条统计行在 960x540 下完整显示，最后一行不再贴近或压到底部边框。
- `scripts/ui_layout_smoke_test.gd` 现在覆盖统计页：`StatsRows` 必须在 `StatsRowReadabilityLane` 内，6 条 named stats row 必须完整、间距稳定、数值使用本地背板，摘要 chip 的 value/caption 必须裁剪且亮度达标。
- `scripts/offline_smoke_test.gd` 已同步统计页 summary chip 的命名和值断言，替代旧的长文案摘要检查。
- 验证记录：`assemble_main --verify`、`git diff --check`、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`、两套截图 manifest、注册资产缺失检查和候选/QA `.import` 检查均通过；离线 smoke 仅保留已知 headless lambda/ObjectDB 退出噪声。

## 2026-07-06 主菜单底栏状态条复核记录

- 生图需求先行复核：`gpt-image-2` 默认模式为 `B-or-C`，注册 GPT 资产 95 个且缺失为 0，候选/QA `.import` 噪声为 0；主菜单底栏问题不是缺图或透明 PNG 失败，因此未派发新的 GPT 图片任务。
- `01_menu.png` 与 `pages_960x540/01_menu.png` 已复核：底栏从分散小字改为版本、货币、段位、统计四个本地 status chip，设置按钮保持右侧独立触控目标；960x540 下统计文案已压缩为短标签并完整显示。
- `scripts/ui_layout_smoke_test.gd` 现在覆盖菜单底栏：footer 安全边界、四个 `MenuFooterStatusChip_*`、标签裁剪/亮度/字号、chip 间距、设置按钮触控区、currency/stats/settings material art 或 fallback 节点。
- `scripts/offline_smoke_test.gd` 已同步新底栏结构，同时保留旧兼容节点 `MenuCurrencyBadge`、`MenuStatsBadge`、`MenuSettingsButton` 及 route-art 断言。
- 验证记录：`assemble_main --verify`、`git diff --check`、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`、两套截图 manifest、注册资产缺失检查和候选/QA `.import` 检查均通过；headless/offscreen 输出只保留已知音频/资源退出噪声。

## 2026-07-06 设置页行文案与按钮安全区复核记录

- 生图需求先行复核：`gpt-image-2` 默认模式为 `B-or-C`，注册 GPT 资产 95 个且缺失为 0，候选/QA `.import` 噪声为 0；只读子 agent 也确认没有必须生图缺口。
- `02_menu_settings.png` 与 `pages_960x540/02_menu_settings.png` 已复核：每个设置项左侧新增本地文字底板，标题/状态字号和亮度提高，`出牌辅助`、`播放测试`、`本地进度` 状态文案缩短。
- `试听` 与 `切歌` 按钮的 command/playback route、tick、gate、波形/音符装饰已移动到按钮上沿或下沿，不再穿过中央文字区域。
- `scripts/ui_layout_smoke_test.gd` 现在覆盖设置页标题/状态/文字底板存在性、字号、亮度、裁剪、按钮 lane 避让，以及 `播放测试`/`播放曲目` 按钮中央文字安全区不与命名装饰节点相交。
- `scripts/offline_smoke_test.gd` 已同步设置行 `SettingRowTextReadabilityPanel_*`、标题/状态裁剪和字号结构断言，同时保留旧 row rail/dot 缺席规则。
- 验证记录：`assemble_main --verify`、`git diff --check`、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`、两套截图 manifest、注册资产缺失检查和候选/QA `.import` 检查均通过；离线 smoke 仅保留已知 headless lambda/ObjectDB 退出噪声。

## 2026-07-06 每日签到可读性复核记录

- 生图需求先行复核：`gpt-image-2` 默认模式为 `B-or-C`，注册 GPT 资产 95 个且缺失为 0，`build/qa`/`.tmp` 候选 `.import` 噪声为 0；`daily_login_gpt_calendar` 已存在并被签到页消费，因此未派发新的 GPT 图片任务。
- `09_daily_login.png` 与 `pages_960x540/09_daily_login.png` 已复核：7 天节点的标题/奖励、今日奖励行、进度文字和底部提示都有本地可读性底板；960x540 下领取按钮与提示条保持清楚间距。
- `scripts/ui_layout_smoke_test.gd` 现在覆盖每日签到页：7 个 day node、`DailyLoginDayTextBack_*`、day/reward 标签裁剪和亮度、奖励文字/图标底板、进度文字/fill、领取按钮触控尺寸、底部提示底板和按钮避让。
- `scripts/offline_smoke_test.gd` 已同步每日签到结构断言，要求 7 组 day label/reward label/text backplate，以及 reward/progress/tip 的命名节点存在。
- 验证记录：`assemble_main --verify`、`git diff --check`、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`、两套截图 manifest、注册资产缺失检查均通过；离线 smoke 仅保留已知 headless lambda/ObjectDB 退出噪声。

## 2026-07-06 离线战斗 HUD 与座位卡信息层级复核记录

- 生图需求先行复核：`gpt-image-2` 默认模式为 `B-or-C`，注册 GPT 资产 95 个且缺失为 0，`build/qa`/`.tmp` 候选 `.import` 噪声为 0；离线战斗页关键资产已存在并被消费，因此未派发新的 GPT 图片任务。
- `03_offline_battle.png` 与 `pages_960x540/03_offline_battle.png` 已复核：顶部 HUD 的标题、事件状态和余牌信息拆成更清楚的可读性块；顶部座位卡增高，四家座位卡的头像/风位和 name/score/meta 文本区分离。
- Native changes：顶部 HUD 新增 `TopHudTitleBack`、`TopHudStatusBack`、`TopHudWallBack`、`TopHudWallText`，离线余牌 slot 加宽；座位卡新增 `SeatCompactTextBack_*`、`SeatAvatar_*`、`SeatAvatarWindMark_*`、`SeatAvatarShortName_*`，并降低紧凑卡字体/重排上下两行。
- `scripts/ui_layout_smoke_test.gd` 现在覆盖离线战斗 HUD：title/status/wall 背板包含关系、亮度、裁剪、status 与 wall 避让、wall 与设置按钮避让；同时覆盖座位卡文本背板、头像避让、name/score/meta 不重叠和亮度。
- `scripts/offline_smoke_test.gd` 已同步 HUD/seat 命名结构断言，以及离线 HUD 余牌 slot 的新几何。
- 验证记录：`assemble_main --verify`、`git diff --check`、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`、两套截图 manifest、注册资产缺失检查均通过；离线 smoke 仅保留已知 headless lambda/ObjectDB 退出噪声。

## 2026-07-06 设置弹窗 960 密度复核记录

- 生图需求先行复核：`gpt-image-2` 默认模式为 `B-or-C`，注册 GPT 资产 95 个且缺失为 0，`build/qa`/`.tmp` 候选 `.import` 噪声为 0；只读子 agent 也确认没有缺失/损坏的生成 PNG，因此未派发新的 GPT 图片任务。
- `02_menu_settings.png` 与 `pages_960x540/02_menu_settings.png` 已复核：弹窗整体略放宽放高，声音/体验分区行高更松，维护行的左侧本地进度文字与右侧“重置”按钮清楚分离。
- Native changes：新增稳定节点 `SettingsPanel`、`SettingsSection_*`、`SettingsSectionGrid_*`、`SettingRow_*`；设置面板 GPT 纹理 alpha 降低；设置行高度提升到 52；reset 按钮的 hold/lock/danger 节点移出中央文字安全区。
- `scripts/ui_layout_smoke_test.gd` 现在覆盖设置弹窗视口边界、section/grid 命名和不重叠、row 高度/宽度、文字底板与按钮 lane 间距、reset 全按钮纹理 alpha，以及 reset 装饰安全区。
- `scripts/offline_smoke_test.gd` 已同步设置弹窗新命名结构、按钮字号上限、reset 纹理 alpha 和锚点安全区断言。
- 验证记录：`assemble_main --verify`、`git diff --check`、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`、两套截图 manifest、注册资产缺失检查均通过；离线 smoke 仅保留已知 headless lambda/ObjectDB 退出噪声。

## 2026-07-06 成就页顶部进度卡复核记录

- 生图需求先行复核：`gpt-image-2` 默认模式为 `B-or-C`，注册 GPT 资产 95 个且缺失为 0，`build/qa`、`.tmp` 和 `garden-gpt-image-2/image/candidates` 候选 `.import` 噪声为 0；`achievement_gpt_gallery` 已存在并被成就页消费，因此未派发新的 GPT 图片任务。
- `06_achievements.png` 与 `pages_960x540/06_achievements.png` 已复核：顶部 dashboard 的奖章从偏黑轮廓改为明亮原生 `奖` 印章，`已解锁`、`完成度` 和底部进度轨在 960x540 下保持可读，列表完整行数不回退。
- Native changes：修复 `draw_achievements_dashboard_art()` 中过早 `return` 导致后续 progress rail/fill/gate 死代码的问题，新增 `AchievementsProgressDetailLabel` 和 `AchievementsMedalGlyph`，并给 summary labels 开启裁剪策略。
- `scripts/ui_layout_smoke_test.gd` 现在覆盖成就页顶部 dashboard：summary/detail label、medal glyph、progress rail/fill/gate 必须存在、保持在 dashboard 内、颜色亮度达标并安全裁剪。
- `scripts/offline_smoke_test.gd` 已同步 dashboard detail/glyph 结构和亮度断言，同时继续覆盖进度轨、解锁路线、节点和 tick。
- 验证记录：`assemble_main --verify`、`git diff --check`、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`、两套截图 capture 和 manifest 均通过；offline smoke 仅保留已知 headless lambda/ObjectDB 清理噪声。

## 2026-07-06 规则页扫读性复核记录

- 生图需求先行复核：`gpt-image-2` 默认模式为 `B-or-C`，注册 GPT 资产 95 个且缺失为 0，候选/QA `.import` 噪声为 0；规则页已有 GPT scroll、guide、reading progress 和 pattern strip 资产，因此未派发新的 GPT 图片任务。
- `04_rules.png` 与 `pages_960x540/04_rules.png` 已复核：规则正文改为更短的扫读文案，正文从 12px 提升到 13px，四行段落增加到底部安全高度，960x540 下 `牌型介绍` 最后一行不再贴近分隔线。
- `scripts/ui_layout_smoke_test.gd` 现在额外覆盖规则页 title/body 字号下限，并继续覆盖正文亮度、裁剪省略、文本 lane 与示例 lane 分离。
- 验证记录：`assemble_main --verify`、`git diff --check`、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`、两套截图 capture 和 manifest 均通过；headless/offscreen 输出只保留已知音频/资源退出噪声。

## 2026-07-06 加载页进度层级复核记录

- 生图需求先行复核：`gpt-image-2` 默认模式仍为 `B-or-C`，注册 GPT 资产 95 个且缺失为 0，`build/qa`、`.tmp`、`garden-gpt-image-2/image/candidates` 的候选 `.import` 噪声为 0；加载页已有 `loading_scene_gpt_backdrop`，没有缺图或坏 PNG，因此未派发新的 GPT 图片任务。
- 修复点：`draw_loading_progress_feedback()` 与 `draw_loading_tip_art()` 原先在创建父节点后立即 `return`，导致后续 progress/tip route 子节点成为死代码。现已启用这些既有原生层，并把轨道/ready 小徽记透明度压低，避免读成额外按钮。
- `10_loading.png` 与 `pages_960x540/10_loading.png` 已复核：标题、副标题、`正在加载中`、提示和版本信息均保持在中心面板内；进度/提示线作为背景纹理，不再压住文字。
- `scripts/ui_layout_smoke_test.gd` 现在覆盖加载页中心面板、标题/副标题/状态/提示/版本标签、progress route/fill/gate、tip rail/fill，并检查跨 `1280x720`、`1920x1080`、`960x540` 的面板安全区、亮度、裁剪和 route containment。
- `scripts/offline_smoke_test.gd` 已补充 `LoadingCenterPanel` 引用，避免新增视觉节点只出现在 `main.gd` 而没有 smoke 证据。
- 验证记录：`assemble_main --verify`、`git diff --check`、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`、两套加载页截图和 screenshot manifest 均通过；headless/offscreen 输出只保留既有音频/资源退出噪声。

## 2026-07-06 联机大厅右栏可读性复核记录

- 生图需求先行复核：`gpt-image-2` 默认模式仍为 `B-or-C`，注册 GPT 资产 95 个且缺失为 0；联机大厅已有 `online_gpt_lobby`、panel frame、group plate、feedback strip 和 room token 资产并被消费，因此未派发新的 GPT 图片任务。
- `08_online_lobby.png` 与 `pages_960x540/08_online_lobby.png` 已复核：右侧玩家席位行更亮，房间日志面板更高，960x540 下 `甲加入房间` / `乙准备` 两条日志不再因高度不足出现省略。
- Native changes：提高 `OnlineLobbyLogReadabilityBackplate`、`OnlineLobbyRosterPanel`、`OnlineLobbyLogListPanel` 的本地底板强度；提升 roster/log 标题、席位名、状态、日志正文的字号和亮度；重新分配 roster/log 纵向空间。
- `scripts/ui_layout_smoke_test.gd` 现在额外覆盖 roster/log 标题字号和亮度、日志计数徽章 containment、席位名/状态字号亮度阈值，以及 14px 日志正文。
- 验证记录：`assemble_main --verify`、`git diff --check`、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`、两套截图 capture 和 manifest 均通过；offline/headless 输出只保留已知 lambda/ObjectDB 清理噪声。

## 2026-07-06 可玩牌面 3D 生成弃用复核记录

- 生图需求先行复核：`gpt-image-2` 默认模式仍为 `B-or-C`，注册 GPT 资产 95 个且缺失为 0，`build/qa`、`.tmp`、`garden-gpt-image-2/image/candidates` 候选 `.import` 噪声为 0；当前问题不是缺图，而是 3D 牌面风格不合格，因此未派发新的 GPT 图片任务。
- `03_offline_battle.png` 与 `pages_960x540/03_offline_battle.png` 已复核：手牌和桌面可玩牌使用清晰基础牌面，配合 Godot 原生阴影/高光，不再依赖金边厚体的生成 3D 牌。
- Native changes：`tile_path()` 只返回 `assets/tiles/*.png` 或基础 `tile_back.png`；`tile_back` 不再回退到 `tile_back_3d.png`；旧 `assets/tiles_3d` 不再是运行时兜底路径。
- 生成工具策略：`tools/generate_gpt_mahjong_tiles.py` 的 prompt 改成平面清晰 2D retouch；`tools/build_3d_tile_faces.py` 默认拒绝执行，只有显式 `--allow-deprecated-3d` 才能跑旧实验。
- 验证记录：`py_compile`、`assemble_main --check`、`assemble_main --verify`、`git diff --check`、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`、旧 3D 生成工具拒绝执行检查、两套截图 capture 和 manifest 均通过；离线 smoke 仅保留既有 headless lambda/ObjectDB 噪声。

## 2026-07-06 新 subtle 3D 可玩牌面接入复核记录

- 生图需求执行：用户明确允许调用生图探索 3D 效果；`ENABLE_GARDEN_IMAGEGEN=1` 后 `gpt-image-2` 检测为 Mode A，已生成空白 3D 牌胚并用确定性脚本合成整套牌。
- 新资源：`assets/tiles_subtle_3d/` 包含 42 张 `tile_*.png` 和 `_tile_body_subtle_3d.png`，全部为 `200x280 RGBA`；`build/qa/subtle_3d_tile_contact_sheet.png` 已生成用于整套视觉复核。
- Runtime changes：`tile_path()` 现在优先 `assets/tiles_subtle_3d/*.png`，缺失时回退 `assets/tiles/*.png`，仍禁止旧 `assets/tiles_3d/*.png` 参与运行时。
- `03_offline_battle.png` 与 `pages_960x540/03_offline_battle.png` 已复核：手牌和桌面明牌显示为克制的 3D 体块，符号仍来自基础牌面，未出现旧金边厚墙或 GPT 错字。
- 验证记录：`py_compile`、`assemble_main --check`、`assemble_main --verify`、`git diff --check`、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`、两套截图 capture 和 manifest 均通过；离线 smoke 仅保留既有 headless lambda/ObjectDB 噪声。

## 2026-07-06 离线战斗左右 AI 缩略卡复核记录

- 生图需求先行复核：当前没有新的 bitmap 缺口；3D 牌继续使用 `assets/tiles_subtle_3d/` 的空白牌胚合成方案，本轮未派发新的 GPT 图片任务。
- `03_offline_battle.png` 与 `pages_960x540/03_offline_battle.png` 已刷新复核：左右 AI 卡收窄为缩略信息块，保留短名、分数、手牌/花数和一行裁剪后的最近牌河，释放桌面两侧空间。
- Native changes：调整 `SEAT_LAYOUTS` 左右座位宽度和位置；`draw_seat()` 增加 left/right thumbnail 分支，避免侧边卡使用底部玩家卡的信息密度。
- `scripts/ui_layout_smoke_test.gd` 现在覆盖侧边 AI 缩略卡，确保非当前/非最近来源的 side river 文案保持缩略长度，文本仍在 panel/text backplate 内并避开头像。
- 验证记录：`assemble_main --check`、`assemble_main --verify`、`git diff --check`、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`、两套截图 capture 和 manifest 均通过；离线 smoke 仅保留既有 headless lambda/ObjectDB 噪声。

## 2026-07-06 联机大厅端点 chip 复核记录

- 生图需求先行复核：`gpt-image-2` 默认模式为 `B-or-C`，本轮问题是顶部 endpoint 文本分配不足，不是图片缺口，因此未派发新的 GPT 图片任务。
- `08_online_lobby.png` 与 `pages_960x540/08_online_lobby.png` 已刷新复核：顶部服务器端点现在完整显示 `129.146.180.88:23333`，不再把端口省略成 `233...`；连接状态 chip 与端点 chip 保持独立间距。
- Native changes：新增 `OnlineLobbyServerEndpointBadge`、`OnlineLobbyServerEndpointLabel`、`OnlineLobbyConnectionStateBadge`、`OnlineLobbyConnectionStateLabel`，扩大 endpoint chip，收窄 label 内边距，并将状态 chip 右移到独立槽位。
- `scripts/ui_layout_smoke_test.gd` 现在覆盖 endpoint/source 文本完整性、无预截断、endpoint/state badge 分离、endpoint 清除内容面板，以及使用字体测量验证 `host:port` 能在 960x540 下完整渲染。
- `scripts/offline_smoke_test.gd` 已同步新增顶部 endpoint/state badge 的命名节点引用，保持视觉节点 smoke 审计闭环。
- 验证记录：`assemble_main --check`、`assemble_main --verify`、`git diff --check`、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`、两套截图 capture 和 manifest 均通过；截图 capture 仍保留既有 Xvfb/ALSA/ObjectDB 噪声。

## 2026-07-06 商店下方宝阁信息柜复核记录

- 生图需求先行复核：`gpt-image-2` 默认模式为 `B-or-C`；商店已有 `shop_gpt_vault` 和四个 true-alpha `shop_charm_*` 道具图，本轮问题是下半屏 native 内容空洞，不是图片缺口。
- `07_shop.png` 与 `pages_960x540/07_shop.png` 已刷新复核：商品列表不再独占上半屏后留下空黑底，下方新增“宝阁说明 / 库存 / 可购”信息柜，明确道具用途和购买状态。
- Native changes：商店 ScrollContainer 底部收至 footer 上方，新增 `ShopCabinetFooterPanel`、`ShopCabinetFooterTitle`、`ShopCabinetFooterBody`、`ShopCabinetFooterInventoryBadge`、`ShopCabinetFooterStateBadge`。
- `scripts/ui_layout_smoke_test.gd` 现在覆盖商店 footer 存在性、低屏空间占用、与最后一行商品不重叠、文本/徽章 containment、字号、裁剪和亮度。
- `scripts/offline_smoke_test.gd` 已同步新增商店 footer 命名节点引用，保持视觉节点 smoke 审计闭环。
- 验证记录：`assemble_main --check`、`assemble_main --verify`、`git diff --check`、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`、两套截图 capture 和 manifest 均通过；截图 capture 仍保留既有 Xvfb/ALSA/ObjectDB 噪声。

## 2026-07-06 主菜单主卡文字层复核记录

- 生图需求先行复核：`gpt-image-2` 默认模式为 `B-or-C`；主菜单已有稳定生成背景和 3D stage overlay，本轮问题是卡片标题/副标题的 native 可读层不足，不是图片缺口。
- `01_menu.png` 与 `pages_960x540/01_menu.png` 已刷新复核：三个主操作卡保留国风桌台和卡框，新增暗色文字底板后，`单机人机`、`联机房间`、`商店` 及副标题在小屏下更稳。
- Native changes：`make_menu_card()` 新增 `MenuCardTextBackplate`、`MenuCardTitleLabel`、`MenuCardSubtitleLabel`，并把副标题收进图标左侧的文字安全区。
- `scripts/ui_layout_smoke_test.gd` 现在覆盖主菜单卡片文字底板、标题/副标题数量、containment、字号、亮度、互不重叠，以及与快捷入口/底栏的避让。
- `scripts/offline_smoke_test.gd` 已同步新增主菜单卡片文字层命名节点断言。
- 验证记录：`assemble_main --check`、`assemble_main --verify`、`git diff --check`、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`、两套截图 capture 和 manifest 均通过；截图 capture 仍保留既有 Xvfb/ALSA/ObjectDB 噪声。

## 2026-07-06 单机对战牌体薄倒角复核记录

- 生图需求先行复核：`gpt-image-2` 默认模式为 `B-or-C`；已委托生图侧车产出空白麻将牌胚 prompt，但本轮未提升新的生成 PNG。整套可玩牌面继续禁止直接生图，避免错字、错点数和花牌细节漂移。
- `03_offline_battle.png` 与 `pages_960x540/03_offline_battle.png` 已刷新复核：手牌和桌面可玩牌从厚金边 3D 改为更干净的薄倒角牌体，符号仍来自基础牌面；左右 AI 卡保持缩略信息块，文字和徽章仍在面板内。
- Native/tooling changes：`tools/build_subtle_3d_tile_faces.py` 默认生成程序化薄青玉侧边牌胚，并收紧符号抽取阈值，避免把原牌灰色边框/斜线带入合成图；`draw_tile_depth_art()` 对已有纹理牌不再叠加 `TileDepthGoldLip`、`TileDepthRightGoldLip` 和 `TilePorcelainFaceInset`。
- 生成资源：`assets/tiles_subtle_3d/` 已重建 42 张 `200x280 RGBA` 可玩牌图和 `_tile_body_subtle_3d.png`；`build/qa/subtle_3d_tile_contact_sheet.png` 已刷新用于整套视觉复核。
- 验证记录：`py_compile`、`assemble_main --check`、`assemble_main --verify`、`git diff --check`、Godot headless 启动、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`、两套截图 capture 和 manifest 均通过；headless/offscreen 输出只保留既有 Xvfb/ALSA/ObjectDB/lambda 清理噪声。

## 2026-07-06 加载页层级与安全区回归记录

- 生图需求先行复核：`gpt-image-2` 默认模式为 `B-or-C`；加载页已有 `loading_scene_gpt_backdrop` 和原生进度/提示层，问题不是缺图。
- UI 测试工程师复核发现：`10_loading.png` 与 `pages_960x540/10_loading.png` 中，`正在加载中` 状态文字与洗牌/进度装饰纵向层级过近，读起来像文字压在进度牌组上。
- Native changes：`draw_loading_shuffle_art()` 上移洗牌牌组，`draw_loading_progress_feedback()` 下移为状态文字下方的细轨；`show_loading_screen()` 将 `LoadingStatusLabel` 放入独立中间条，底部提示和 tip art 下移避让。
- `scripts/ui_layout_smoke_test.gd` 现在新增 960x540 模拟安全区 probe，并断言关键页面可见文字/按钮保持在 `SafeContent` 内；加载页新增 shuffle/status/progress/tip 的明确垂直间距断言。
- 复核结果：刷新后的 `pages_960x540/10_loading.png` 中，洗牌牌组、`正在加载中` 和进度细轨已分层，不再压字。
- 验证记录：`assemble_main --check`、`assemble_main --verify`、`git diff --check`、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`、两套截图 capture 和 manifest 均通过；截图 capture 仅保留既有 Xvfb/ALSA/ObjectDB 退出噪声。

## 2026-07-06 单机对战 AI 缩略卡与 v7 牌体回归记录

- 生图需求先行复核：默认 `gpt-image-2` 为 `B-or-C`；本轮显式用 `ENABLE_GARDEN_IMAGEGEN=1` 调用本地 Mode A 生成空白牌体候选。v6 仍偏厚/有内框，v7 作为哑光正交牌体被推广。
- `03_offline_battle.png` 与 `pages_960x540/03_offline_battle.png` 已刷新复核：左右 AI 卡收窄为状态缩略块，只保留短名、分数、手牌/花数、弃牌计数和最近短动作；文本/徽章均在卡框内。
- 牌体复核：`assets/tiles_subtle_3d/` 已用 v7 空白牌体重新合成，手牌和桌面牌去掉厚绿边/厚墙感，牌面符号仍由 `assets/tiles/*.png` 确定性叠加。
- Native/test changes：`SEAT_LAYOUTS` 缩小并内收左右座位；`draw_seat()` 给 side 分支使用缩略排版、panel overflow clipping 和弃牌计数；`scripts/ui_layout_smoke_test.gd` 使用长 AI 名/多弃牌数据并断言侧边卡尺寸、裁剪、短状态和弃牌计数；`scripts/offline_smoke_test.gd` 同步新缩略语义。
- 验证记录：`assemble_main --check`、`assemble_main --verify`、`git diff --check`、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`、两套截图 capture 和 manifest 均通过；headless/offscreen 输出只保留既有 Xvfb/ALSA/ObjectDB/lambda 清理噪声。

## 2026-07-06 商店滚动槽与联机反馈条安全区复核记录

- 生图需求先行复核：`ENABLE_GARDEN_IMAGEGEN=1` 后 `gpt-image-2` 检测为 Mode A；本轮没有缺失/损坏 PNG，也没有需要新纹理的视觉缺口，因此未派发新的 GPT 图片任务。
- `07_shop.png` 与 `pages_960x540/07_shop.png` 已复核：商店列表右侧不再显示默认亮白系统滚动条，改为不可点击的窄暗金滚动槽和 thumb，商品文字、数量徽章、购买按钮均避开 gutter。
- `08_online_lobby.png` 与 `pages_960x540/08_online_lobby.png` 已复核：底部服务器反馈文字新增本地暗底，文字安全区收在右侧饰件之前，状态印章与反馈文本不重叠。
- Native changes：`ShopItemsScroll` 隐藏内置 `ShopItemsScrollBar`，新增 `ShopItemsScrollGutter` / `ShopItemsScrollThumb`；`draw_online_feedback_art()` 新增 `OnlineFeedbackTextBackplate` 并收窄 `OnlineFeedbackText` 锚点。
- `scripts/ui_layout_smoke_test.gd` 现在覆盖自绘滚动槽/滑块、隐藏默认系统滚动条、商品交互/文字节点避让 gutter，以及在线反馈文字背板 containment、亮度、裁剪、状态印章避让和右侧饰件避让。
- 验证记录：`assemble_main --check`、`assemble_main --verify`、`git diff --check`、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`、目标页面两套截图 capture 和两套 screenshot manifest 均通过；运行日志只保留既有 headless/offscreen 清理噪声。

## 2026-07-06 设置弹窗背景遮罩复核记录

- 生图需求先行复核：`ENABLE_GARDEN_IMAGEGEN=1` 后 `gpt-image-2` 检测为 Mode A；问题是设置弹窗背后的主菜单底栏和设置按钮层级过亮，不是缺少 GPT 贴图，因此未派发新的 GPT 图片任务。
- `02_menu_settings.png` 与 `pages_960x540/02_menu_settings.png` 已复核：弹窗背后的主菜单和底栏被深墨遮罩压暗，保留场景语境但不再像可点击前景控件。
- Native changes：`draw_settings_overlay()` 新增 `SettingsOverlayScrim`，位于 `SettingsPanel` 下方并覆盖整个 overlay。
- `scripts/ui_layout_smoke_test.gd` 现在覆盖设置遮罩存在性、全屏 containment、暗度/alpha 阈值，以及 modal panel 在 scrim 之上的层级。
- 验证记录：`assemble_main --check`、`assemble_main --verify`、`git diff --check`、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`、设置页两套截图 capture 和两套 screenshot manifest 均通过；运行日志只保留既有 headless/offscreen 清理噪声。

## 2026-07-06 单机对战绿幕空白牌胚回归记录

- 生图需求先行复核：本轮确实存在牌体材质问题，已用 `ENABLE_GARDEN_IMAGEGEN=1` 调用本地 Mode A。生成范围限定为空白牌胚，牌面仍由 `assets/tiles/*.png` 确定性叠加。
- `03_offline_battle.png` 与 `pages_960x540/03_offline_battle.png` 已刷新复核：新牌体比旧厚 3D 牌更像低浮雕白玉/骨瓷材质，手牌和桌面明牌在 960x540 下仍可读；左右 AI 缩略卡继续保持在框内。
- 资源变化：`assets/tiles_subtle_3d/` 已用 `blank_tile_body_jade_flat_v6_actual_raw.png` 重建 42 张可玩牌图和 `_tile_body_subtle_3d.png`，全部为 `200x280 RGBA` true-alpha。
- 验证记录：`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`、两套 screenshot manifest、`git diff --check` 均通过；1280 截图刷新了整组页面，960 目标刷新了单机对战页。日志只保留既有 Xvfb/ALSA/ObjectDB/lambda 清理噪声。

## 2026-07-06 成就页摘要层级与状态 chip 复核记录

- 生图需求先行复核：`ENABLE_GARDEN_IMAGEGEN=1` 后 `gpt-image-2` 检测为 Mode A；成就页已有 `achievement_gpt_gallery`，本轮问题是 native 摘要文字层级和 row 状态 chip 间距，不是缺图。
- `06_achievements.png` 与 `pages_960x540/06_achievements.png` 已刷新复核：顶部 `已解锁 5/17` / `完成度 29%` 坐在独立暗底上，不再被进度路线压字；右侧 row 状态改成 `首 · 已解锁` / `七 · 待达成` 这种紧凑读法。
- Native changes：`draw_achievements_dashboard_art()` 新增 `AchievementsSummaryTextBackplate` 并把摘要文字提升到装饰层之上；`draw_achievement_row_art()` 扩大 `AchievementRowSeal_*` 的安全区并把状态分隔改为轻量点号；`make_achievement_row()` 收窄状态文字 lane。
- `scripts/ui_layout_smoke_test.gd` 现在覆盖成就摘要文字底板、进度条避让奖励节点、摘要文字与进度轨道的垂直关系、状态 chip 文本与锁定行 seal containment。
- 验证记录：`assemble_main --check`、`assemble_main --verify`、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`、目标页两套截图 capture、两套 screenshot manifest 和 `git diff --check` 均通过；运行日志只保留既有 headless/offscreen 清理噪声。

## 2026-07-06 单机对战 soft jade 牌体回归记录

- 生图需求先行复核：本轮确实是 3D 牌体观感问题，已显式用 `ENABLE_GARDEN_IMAGEGEN=1` 调用本地 GPT Image 2 Mode A，并由 Descartes 生图 worker 生成空白牌胚候选。
- `03_offline_battle.png` 与 `pages_960x540/03_offline_battle.png` 已刷新复核：手牌和桌面牌切换为 soft jade 低浮雕牌体，去掉此前明显绿边/厚边卡片感；牌面符号仍清楚，AI 缩略卡继续保持在框内。
- 资源变化：`assets/tiles_subtle_3d/` 已用 `blank_tile_body_soft_jade_relief_candidate_2.png` 重建 42 张 `200x280 RGBA` 可玩牌图和 `_tile_body_subtle_3d.png`。整套牌面仍由 `assets/tiles/*.png` 确定性叠加，未让 GPT 生成完整可玩牌面。
- 工具链变化：`tools/build_subtle_3d_tile_faces.py` 的背景 alpha 推断支持蓝幕候选，便于后续生图 worker 使用绿色或蓝色 chroma key。
- 验证记录：`py_compile`、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`、目标页两套截图 capture、两套 screenshot manifest 和 `git diff --check` 均通过；运行日志只保留既有 headless/offscreen 清理噪声。

## 2026-07-06 统计页左侧摘要面板复核记录

- 生图需求先行复核：`ENABLE_GARDEN_IMAGEGEN=1` 后 `gpt-image-2` 检测为 Mode A；统计页已有 `stats_gpt_dashboard` 与 `stats_winrate_scroll`，本轮问题是顶部 dashboard 左侧信息密度不足，不是缺图。
- `05_stats.png` 与 `pages_960x540/05_stats.png` 已刷新复核：左上新增 `战绩 / 蓄势 / 1胜/9局` 摘要块，填补原先纯装饰空位；三个指标卡仍保持独立，不与左侧摘要重叠。
- Native changes：`draw_stats_dashboard_art()` 新增 `StatsSummaryNarrativePanel`、`StatsSummaryNarrativeRail`、`StatsSummaryNarrativeTitle`、`StatsSummaryNarrativeBody`、`StatsSummaryNarrativeMeta`，根据胜率给出短状态。
- `scripts/ui_layout_smoke_test.gd` 现在覆盖统计页 narrative panel 的 containment、尺寸、裁剪、亮度，以及与三个 summary chip 的不重叠关系；`scripts/offline_smoke_test.gd` 同步新增语义节点和状态文案检查。
- 验证记录：`assemble_main --check`、`assemble_main --verify`、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`、目标页两套截图 capture、两套 screenshot manifest 和 `git diff --check` 均通过；运行日志只保留既有 headless/offscreen 清理噪声。

## 2026-07-06 单机对战 soft orthographic 牌体回归记录

- 生图需求执行：用户明确询问其他 3D 生成方式并允许调用生图；本轮使用 `ENABLE_GARDEN_IMAGEGEN=1` 调用本地 GPT Image 2 Mode A。
- 视觉决策：推广 `soft_orthographic_v9` 空白牌胚，用低浮雕正交牌体和柔和倒角替代厚侧壁 3D；继续禁止 GPT 直接生成完整可玩牌面。
- 资源变化：`assets/tiles_subtle_3d/_tile_body_subtle_3d.png` 和 42 张 `assets/tiles_subtle_3d/tile_*.png` 已从 `blank_tile_body_soft_orthographic_v9_raw.png` 加确定性 `assets/tiles/*.png` 标记重建。
- `03_offline_battle.png` 与 `pages_960x540/03_offline_battle.png` 已刷新复核：手牌和桌面牌不再有厚边/棋盘格残留，符号保持清晰；底部手牌仍在托盘内，左右 AI 缩略卡继续保持在框内。
- 验证记录：`assemble_main --verify`、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`、目标页两套截图 capture、两套 screenshot manifest 和 `git diff --check` 均通过；运行日志只保留既有 headless/offscreen 清理噪声。

## 2026-07-06 单机对战 orthographic white-jade 牌体与日签预告回归记录

- 生图需求执行：用户明确允许调用生图；本轮采用生图 worker 产出的 `orthographic_white_jade_v10` 空白牌胚，继续禁止 GPT 生成完整可玩牌面。
- 资源变化：`assets/tiles_subtle_3d/_tile_body_subtle_3d.png` 和 42 张 `assets/tiles_subtle_3d/tile_*.png` 已从 `blank_tile_body_orthographic_white_jade_v10_200x280.png` 加确定性 `assets/tiles/*.png` 标记重建。
- `03_offline_battle.png` 与 `pages_960x540/03_offline_battle.png` 已刷新复核：手牌和桌面牌转为更精致的低浮雕白玉底胚，不再是厚 3D 侧墙；左右 AI 缩略卡文字/徽章保持在框内。
- 日签补充：`DailyLoginForecastPanel`、`DailyLoginForecastTitle`、`DailyLoginForecastBody`、`DailyLoginForecastBadge`、`DailyLoginForecastBadgeBack` 已纳入 `offline_smoke_test.gd` 和 `ui_layout_smoke_test.gd`，覆盖 forecast 内容、可读性、背板 containment 与 claim 按钮避让。
- 验证记录：`py_compile`、`assemble_main --check`、`assemble_main --verify`、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`、目标页两套截图 capture、两套 screenshot manifest 和 `git diff --check` 均通过；运行日志只保留既有 headless/offscreen 清理噪声。

## 2026-07-06 规则页阅读宽度回归记录

- 生图需求先行复核：`gpt-image-2` Mode A 可用，但规则页不缺新 PNG；问题是正文 lane 过窄，右侧示例条占比偏高。
- `04_rules.png` 与 `pages_960x540/04_rules.png` 已刷新复核：正文背板和文字列更宽，右侧例牌/图示条压缩到阅读辅助，不再抢主阅读区。
- Native changes：`RuleSectionTextBackplate` 和 rules text vbox 右边界外扩；`RuleSectionArtStrip` 右移并收窄，badge/glyph 同步调整。
- `scripts/ui_layout_smoke_test.gd` 现在断言规则页正文宽度至少约占 section 的 68%，右侧 example strip 不超过约 24%，避免后续回退成装饰挤正文。
- 验证记录：`assemble_main --check`、`assemble_main --verify`、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`、目标规则页两套截图 capture、两套 screenshot manifest 和 `git diff --check` 均通过；运行日志只保留既有 headless/offscreen 清理噪声。

## 2026-07-06 联机大厅房间摘要回归记录

- 生图需求先行复核：`gpt-image-2` Mode A 可用，但联机大厅已消费稳定 GPT 背景/面板/反馈条素材，本轮不需要新 PNG。
- `08_online_lobby.png` 与 `pages_960x540/08_online_lobby.png` 已刷新复核：右侧房间状态区顶部新增 `入席 2/4`、`已备 0`、`未连接` 三个紧凑摘要胶囊，下面保留四席明细和日志，阅读顺序更清楚。
- Native changes：`draw_online_lobby_room_art()` 新增 `OnlineLobbyRoomSummaryPanel`、`OnlineLobbyRoomSummaryOccupancy`、`OnlineLobbyRoomSummaryReady`、`OnlineLobbyRoomSummaryState` 及对应 label，并把席位圆点移到底部作为辅助状态。
- `scripts/ui_layout_smoke_test.gd` 现在覆盖摘要 panel/chip/label 的 containment、水平间距、字号、亮度、裁剪和文字 lane 宽度；`scripts/offline_smoke_test.gd` 同步断言摘要语义文案。
- 验证记录：`assemble_main --check`、`assemble_main --verify`、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`、两套截图 capture、两套 screenshot manifest 和 `git diff --check` 均通过；运行日志只保留既有 Xvfb/OpenGL/ALSA/ObjectDB/lambda 清理噪声。

## 2026-07-06 单机对战 thin chroma 牌体回归记录

- 生图需求执行：用户明确允许调用生图，本轮使用本地 GPT Image 2 Mode A 生成空白牌胚候选，并由主流程验证候选接入效果。
- 资源变化：`assets/tiles_subtle_3d/` 已用 `blank_tile_body_thin_chroma_v11_raw.png` 重建 42 张可玩牌图和 `_tile_body_subtle_3d.png`；牌面符号仍由 `assets/tiles/*.png` 确定性叠加。
- 工具链变化：`tools/build_subtle_3d_tile_faces.py` 的默认 body 指向 v11 绿幕薄倒角候选，默认 `--body-mode` 改为 `generated`，后续默认重建会复现当前正式牌体。
- `03_offline_battle.png` 与 `pages_960x540/03_offline_battle.png` 已刷新复核：底部手牌、桌面明牌和牌墙都保持在各自框内；AI 缩略卡继续保持在框内；960x540 下牌面符号仍可读。
- 验证记录：`python3 -m py_compile tools/build_subtle_3d_tile_faces.py`、默认 `python3 tools/build_subtle_3d_tile_faces.py`、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`、两套截图 capture、两套 screenshot manifest 和 `git diff --check` 均通过；运行日志只保留既有 headless/Xvfb/OpenGL/ALSA/ObjectDB/lambda 清理噪声。

## 2026-07-06 每日签到七日预告层级回归记录

- 生图需求先行复核：`daily_login_gpt_calendar` 已存在且正常消费，本轮问题是 native forecast 区太薄、太贴底，不是缺少 GPT PNG。
- `09_daily_login.png` 与 `pages_960x540/09_daily_login.png` 已刷新复核：七日奖励预告从底部细条改为更宽更高的信息区，标题、`还差 2 天` 状态徽章和奖励说明分别占独立 lane；确认按钮与预告区有明确间距。
- Native changes：`show_daily_login_panel()` 上收 reward/progress/claim 区域，收窄 claim button 最小高度，扩大 `DailyLoginForecastPanel` 并调整 title/body/badge/backplate/rail 锚点。
- `scripts/ui_layout_smoke_test.gd` 现在覆盖 forecast panel 的更大最小尺寸、claim button 间距、标题/徽章分 lane、正文位于标题行下方、正文宽阅读 lane 和 badge/body 背板 containment。
- 验证记录：`assemble_main --check`、`assemble_main --verify`、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`（用 `timeout 90s` 包裹确认 `OFFLINE_SMOKE_EXIT:0`）、目标页两套截图 capture、两套 screenshot manifest 和 `git diff --check` 均通过；运行日志只保留既有 headless/Xvfb/OpenGL/ALSA/ObjectDB/lambda 清理噪声。

## 2026-07-06 单机对战框内布局与 v12 牌体回归记录

- 生图需求先行复核：本轮确实存在牌体观感问题，Mode A 可用；同时单机对战页存在视觉越界/拥挤问题，需要 native 布局修复。
- Layout changes：左右 AI seat panel 缩成更小缩略卡，pending claim 操作栏下移到桌面与手牌托盘之间的通道，Top HUD / action dock / hand tray 开启裁剪，pending claim 时隐藏手牌托盘标题和状态徽章，避免文字压到手牌。
- Tile changes：正式 `assets/tiles_subtle_3d/` 改用 v12 shallow-relief ivory/jade 空白牌胚重建，保留确定性牌字叠加；2.5D baked UI 候选因 contact sheet 噪点未推广。
- Test coverage：`scripts/ui_layout_smoke_test.gd` 现在覆盖 Top HUD/hand tray/action dock 裁剪、pending claim dock 与手牌托盘通道关系、GPT dock texture containment，以及 side AI thumbnail 更严格尺寸阈值。
- Screenshot review：`build/qa/pages/03_offline_battle.png` 和 `build/qa/pages_960x540/03_offline_battle.png` 已刷新。手牌、操作栏、侧边 AI 卡均在框内；AI 信息变成缩略卡；新牌体在 960x540 下仍可读。
- 验证记录：`py_compile`、`assemble_main --check`、`assemble_main --verify`、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`（`OFFLINE_SMOKE_EXIT:0`）、单机页两套截图 capture、两套 screenshot manifest 和 `git diff --check` 均通过；运行日志只保留既有 headless/Xvfb/OpenGL/ALSA/ObjectDB/lambda 清理噪声。

## 2026-07-06 单机对战程序薄倒角牌体回归记录

- 生图需求先行复核：用户允许调用生图；v13 生图候选已生成并合成验证，但未通过 runtime 提升标准。
- Tile changes：正式 `assets/tiles_subtle_3d/` 改为 `tools/build_subtle_3d_tile_faces.py` 的程序薄倒角牌胚重建，去掉 v12 shallow-relief 的相框感和后续 v13 候选的边缘噪声。牌面符号仍由 `assets/tiles/*.png` 确定性叠加。
- Tooling changes：`tools/build_subtle_3d_tile_faces.py` 默认 `--body-mode procedural`；需要继续试生图材质时仍可传 `--body-mode generated --body <候选路径>`。
- Screenshot review：`build/qa/pages/03_offline_battle.png` 和 `build/qa/pages_960x540/03_offline_battle.png` 已刷新。手牌、操作栏、桌面牌墙和左右 AI 缩略卡均保持在框内；小屏下牌面符号清楚，牌体边缘比 v12 更干净。
- 验证记录：`python3 -m py_compile tools/build_subtle_3d_tile_faces.py`、`assemble_main --check`、`assemble_main --verify`、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`（`OFFLINE_SMOKE_EXIT:0`）、单机页两套截图 capture、两套 screenshot manifest 和 `git diff --check` 均通过；运行日志只保留既有 headless/Xvfb/OpenGL/ALSA/ObjectDB/lambda 清理噪声。

## 2026-07-06 统计页语义文案回归记录

- 生图需求先行复核：统计页已有 `stats_gpt_dashboard` / `stats_winrate_scroll` 等生成图，截图问题是 native metric 文案含义不准，不需要新 PNG。
- Text changes：`累计分数` 改为 `累计净分`，明确可为负的累计净胜分；`最高得分` 改为 `单局最佳`，summary chip 同步使用 `单局最佳`。
- Test coverage：`scripts/ui_layout_smoke_test.gd` 和 `scripts/offline_smoke_test.gd` 已同步新的统计行节点名与可读性检查，继续覆盖 6 个统计行、summary chip、narrative panel 和 row containment。
- Screenshot review：`build/qa/pages/05_stats.png` 与 `build/qa/pages_960x540/05_stats.png` 已刷新；`累计净分 -2.6万 分` 和 `单局最佳 9600 分` 在两种分辨率下都保持在值框内。
- 验证记录：`assemble_main --check`、`assemble_main --verify`、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`（`OFFLINE_SMOKE_EXIT:0`）、统计页两套截图 capture、两套 screenshot manifest 和 `git diff --check` 均通过；运行日志只保留既有 headless/Xvfb/OpenGL/ALSA/ObjectDB/lambda 清理噪声。

## 2026-07-06 联机大厅未连接状态层级回归记录

- 生图需求先行复核：联机大厅已有 `online_gpt_lobby`、`online_lobby_panel_frame`、`online_lobby_group_plate`、`online_feedback_gpt_strip` 等生成图，截图问题是 native 未连接状态表达，不需要新 PNG。
- UI changes：底部状态栏从重复 `服务器默认 host:port` 改为 `未连接 · 先连服，再建房或入房`；未连接时主操作位显示禁用态 `待连接`，连接成功后才恢复 `开始游戏`。
- Test coverage：`scripts/ui_layout_smoke_test.gd` 现在覆盖 `OnlineLobbyStatusLabel` 必须在状态背板内、不得重复 raw endpoint、文本必须完整显示；同时断言未连接时 `OnlineLobbyPrimaryStartButton` 是禁用的 `待连接`。`scripts/offline_smoke_test.gd` 同步语义检查。
- Screenshot review：`build/qa/pages/08_online_lobby.png` 与 `build/qa/pages_960x540/08_online_lobby.png` 已刷新；小屏下底部状态、反馈条、房间摘要和左右面板仍保持在框内。
- 验证记录：`assemble_main --check`、`assemble_main --verify`、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`（`OFFLINE_SMOKE_EXIT:0`）、联机页两套截图 capture、两套 screenshot manifest 和 `git diff --check` 均通过；运行日志只保留既有 headless/Xvfb/OpenGL/ALSA/ObjectDB/lambda 清理噪声。

## 2026-07-06 v14 生图牌坯候选复核记录

- 生图需求先行复核：用户明确询问是否有其他方式生成 3D 效果，并允许调用生图；本轮只做空白牌坯材质探针，不生成完整可玩牌面。
- Candidate review：`garden-gpt-image-2/image/candidates/tiles_v14_local/blank_tile_body_orthographic_low_relief_v14_raw.png` 已用 `tools/build_subtle_3d_tile_faces.py --body-mode generated` 合成到 `.tmp/subtle_3d_v14_low_relief/`。
- Contact sheet：`build/qa/subtle_3d_tile_contact_sheet_v14_low_relief.png` 显示 v14 方向中心干净、材质更像瓷牌，但 200x280 下仍有顶边细线和轻微相框感。
- Runtime decision：不推广 v14，不覆盖 `assets/tiles_subtle_3d/`；正式牌体继续使用当前程序薄倒角方案，待后续候选去掉顶边 hairline 和 inset rim 后再评估。
- 验证记录：本轮未改 Godot runtime 代码，未刷新游戏页面截图，未执行布局/冒烟测试；仅完成生图候选、确定性合成 contact sheet 和人工视觉复核。

## 2026-07-06 成就页行语义可读性回归记录

- 生图需求先行复核：成就页已有 `achievement_gpt_gallery` 和奖章 glow 资源，截图问题是 native 行内容过弱，不需要新 PNG。
- UI changes：成就行新增 `目标：...` 说明和二值进度文案；右侧徽章从单字短码扩成 `首局`、`七对`、`十三幺` 等可读标题；进度轨加宽加厚，锁定态仍保持低调国风色。
- Test coverage：`scripts/ui_layout_smoke_test.gd` 现在覆盖目标说明、进度文案、文本避开自定义滚动条、锁定行文案对比度与垂直顺序；`scripts/offline_smoke_test.gd` 同步断言 `进度 0/1`、`进度 1/1` 和十三幺目标文案。
- Screenshot review：`build/qa/pages/06_achievements.png` 与 `build/qa/pages_960x540/06_achievements.png` 已刷新；小屏下每行的目标、进度和状态 chip 均保持在行框内，右侧滚动条不被文字遮挡。
- 验证记录：`assemble_main --check`、`assemble_main --verify`、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`（`OFFLINE_SMOKE_EXIT:0`）、成就页两套截图 capture、两套 screenshot manifest 和 `git diff --check` 均通过；运行日志只保留既有 Xvfb/OpenGL/ALSA/ObjectDB/lambda 清理噪声。

## 2026-07-06 商店购买 CTA 语义回归记录

- 生图需求先行复核：商店页已有 `shop_gpt_vault`、`shop_charm_*` 等资源并正常显示，本轮问题是 native 购买按钮只显示数字，缺少“购买/不足”和玉符单位，不需要新 PNG。
- UI changes：每个 `ShopItemBuyButton_*` 新增 `ShopBuyButtonCommand_*` 与 `ShopBuyButtonPrice_*`；可买时显示 `购买` + `n玉`，资源不足时显示 `不足` + `n玉`；物品数量从 `拥有 0` 调整为 `持有 0`，底部状态改为 `库存 0件` / `可买 3种`。
- Test coverage：`scripts/ui_layout_smoke_test.gd` 覆盖按钮 command/price label 的 containment、滚动条避让、clip 和独立 lane；`scripts/offline_smoke_test.gd` 覆盖高玉符可买与低玉符不足两种语义。
- Screenshot review：`build/qa/pages/07_shop.png` 与 `build/qa/pages_960x540/07_shop.png` 已刷新；小屏下购买按钮两行文字仍在按钮内，底部状态 chip 在宝阁说明框内。
- 验证记录：`assemble_main --check`、`assemble_main --verify`、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`（`OFFLINE_SMOKE_EXIT:0`）、商店页两套截图 capture、两套 screenshot manifest 和 `git diff --check` 均通过；运行日志只保留既有 Xvfb/OpenGL/ALSA/ObjectDB/lambda 清理噪声。

## 2026-07-07 单机对战 v15 mask 材质牌体回归记录

- 生图需求执行：用户询问其他 3D 生成方式并允许生图；v15 候选由生图 worker 生成，主流程做小尺寸合成验收。
- 直接候选复核：`continuous_porcelain_slab_v15` 和 `baked_ui_depth_layer_v15` 都没有符号/文字/内框，但直接合成到 200x280 后出现灰黑材质污点，因此不直接使用 GPT RGB。
- Tooling changes：`tools/build_subtle_3d_tile_faces.py` 新增默认 `--body-mode generated-mask-material`，只取 GPT 候选的外轮廓 mask，并用确定性象牙白材质、右下微阴影和浅倒角重建牌体。
- Tile changes：`assets/tiles_subtle_3d/_tile_body_subtle_3d.png` 和 42 张 `assets/tiles_subtle_3d/tile_*.png` 已重建；牌面字样仍由 `assets/tiles/*.png` 确定性叠加。
- Screenshot review：`build/qa/pages/03_offline_battle.png` 和 `build/qa/pages_960x540/03_offline_battle.png` 已刷新；底部手牌、桌面明牌、牌河和 AI 缩略卡仍保持在框内，新牌体在小屏下干净且没有脏纹理。
- 验证记录：`python3 -m py_compile tools/build_subtle_3d_tile_faces.py`、默认 `python3 tools/build_subtle_3d_tile_faces.py`、`assemble_main --check`、`assemble_main --verify`、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`（`OFFLINE_SMOKE_EXIT:0`）、单机页两套截图 capture、两套 screenshot manifest 和 `git diff --check` 均通过；运行日志只保留既有 OpenGL/ALSA/ObjectDB/lambda 清理噪声。

## 2026-07-07 单机对战 v16 生图探针与程序 2.5D 牌体回归记录

- 生图需求执行：用户继续询问其他 3D 生成方式并允许调用生图；本轮由生图 worker `Popper` 做只读方案审计，主流程用本地 GPT Image 2 Mode A 生成 v16 空白低浮雕牌体候选。
- Candidate review：`low_relief_ui_depth_v16_raw.png` 中央干净、无牌字，但右/下侧仍偏实物厚边；经 `generated-mask-material` 合成后与 v15 差异很小，因此不推广 raw GPT RGB 或 v16 mask。
- Tile changes：正式 `assets/tiles_subtle_3d/` 改用 `tools/build_subtle_3d_tile_faces.py` 的程序薄倒角 2.5D 牌体重建。该方式在 200x280 下更干净，有轻微玉色侧边，并继续保留确定性 `assets/tiles/*.png` 牌字叠加。
- Tooling changes：`tools/build_subtle_3d_tile_faces.py` 默认 `--body-mode procedural`，使默认重建结果与当前正式 runtime 牌体一致；`generated` 和 `generated-mask-material` 继续作为显式生图候选评估路径。
- Screenshot review：`build/qa/pages/03_offline_battle.png` 与 `build/qa/pages_960x540/03_offline_battle.png` 已刷新。底部手牌仍在托盘内，响应按钮仍在独立 dock 内，桌面牌墙/明牌没有越界；左右 AI 信息继续是缩略卡，文本和徽章在框内。
- 验证记录：`python3 -m py_compile tools/build_subtle_3d_tile_faces.py`、默认 `python3 tools/build_subtle_3d_tile_faces.py --out-dir assets/tiles_subtle_3d --contact-sheet build/qa/subtle_3d_tile_contact_sheet.png`、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`（`OFFLINE_SMOKE_EXIT:0`）、两套 screenshot manifest 和 `git diff --check` 均通过；运行日志只保留既有 Xvfb/OpenGL/ALSA/ObjectDB/lambda 清理噪声。

## 2026-07-07 单机对战缩略布局与加载页叠层回归记录

- 生图需求先行处理：已派发生图 worker 生成 v17 空白牌体候选，并用 contact sheet 验证；候选只作参考，不推广到 runtime。
- Native layout changes：左右 AI seat panel 进一步收成缩略卡，侧边 meta 文案改为 `手13` / `手13 花1` 这类短文本；pending claim action dock 上移并压缩为更清楚的按钮通道，与手牌托盘保持至少 8px 可读间距。
- Loading fix：当 `loading_scene_gpt_backdrop` 存在时，`LoadingMoon`、`MoonGlowBloom`、`LoadingFarMountain`、`LoadingWater` fallback 叠层显式透明，避免 GPT 背景上再出现半透明矩形块。
- Test coverage：`scripts/ui_layout_smoke_test.gd` 新增 action dock 与 hand tray 间距、dock 高度、action button 与 hand tray 间距、side AI thumbnail 更严格尺寸阈值，以及 loading GPT backdrop 抑制 fallback 叠层的断言。
- Screenshot review：`build/qa/pages_960x540/03_offline_battle.png` 中行动条保持在独立框内且不贴手牌；左右 AI 信息卡为缩略态。`build/qa/pages_960x540/10_loading.png` 中右上月亮/山水区域不再有 native fallback 矩形叠层。
- 验证记录：`assemble_main --check`、`assemble_main --verify`、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`（`OFFLINE_SMOKE_EXIT:0`）、单机/加载页两套截图 capture、两套 screenshot manifest 和 `git diff --check` 均通过；运行日志只保留既有 Xvfb/OpenGL/ALSA/ObjectDB/lambda 清理噪声。

## 2026-07-07 设置页 Header 与 v18 生图牌坯复核记录

- 生图需求执行：用户继续询问其他 3D 生成方式并允许调用生图；生图 worker `Euler` 生成 3 个 v18 空白牌坯候选，均不包含文字、花色或可玩牌面。
- Candidate review：候选 1/2 经 `generated-mask-material` 合成后生成 `build/qa/subtle_3d_tile_contact_sheet_v18_candidate_01_mask_material.png` 与 `build/qa/subtle_3d_tile_contact_sheet_v18_candidate_02_mask_material.png`。候选 1 的正交薄倒角方向可用作参考；候选 3 仍有透视侧墙，不作为优先方案。
- Tooling changes：`tools/build_subtle_3d_tile_faces.py` 的 `generated-mask-material` 模式现在支持白底/中性背景候选的 alpha 推断，避免把整张白底方图当成牌体轮廓。
- Runtime tile decision：暂不推广 v18 到 `assets/tiles_subtle_3d/`。正式 runtime 继续使用当前程序薄倒角 2.5D 牌体，因为它在 200x280 下更规整，且继续保留确定性 `assets/tiles/*.png` 牌字叠加。
- Native layout changes：设置弹窗 header 拆成标题/关闭按钮一行，`SettingsOverviewArt` 下移到独立状态条；声音/体验区下移并压缩行高，避免 960x540 下标题、overview 和关闭按钮互相挤压。
- Test coverage：`scripts/ui_layout_smoke_test.gd` 新增 `SettingsTitleLabel`、`SettingsOverviewArt`、`SettingsOverviewSummary` 命名节点检查，覆盖 overview 不与标题或关闭按钮重叠、summary 文本裁剪和宽度适配。
- Screenshot review：`build/qa/pages_960x540/02_menu_settings.png` 已刷新，顶部标题和关闭按钮各自占位，overview 状态条独立在下一行；两套 screenshot manifest 已重建 contact sheet 并通过。
- 验证记录：`python3 -m py_compile tools/build_subtle_3d_tile_faces.py`、v18 两张 contact sheet 重建、`assemble_main --check`、`assemble_main --verify`、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`、设置页两套截图 capture 和两套 screenshot manifest 均通过；运行日志只保留既有 Xvfb/OpenGL/ALSA/ObjectDB/lambda 清理噪声。

## 2026-07-07 设置页密度与成就页进度 Chip 回归记录

- 生图需求先行复核：只读 UI tester `Raman` 复核两套 contact sheet 后判断不需要新增 GPT 图片；本轮问题是 native 布局密度和小屏文本层级。
- Settings changes：`SettingsOverviewArt` 进一步压薄并上移，声音/体验区与 overview 保持小屏 8px 以上间距，维护区增高并与上方分区留出明确通道。
- Achievements changes：成就行的进度文案从细进度线旁挪到独立 `AchievementRowProgressTextBackplate_*` 胶囊；名称/目标/进度/状态四个信息 lane 更明确，避免小屏下进度文本贴线。
- Test coverage：`scripts/ui_layout_smoke_test.gd` 新增设置页小屏 overview-section 间距、维护区高度、设置行垂直间距，以及成就行进度 chip containment、文本适配、与目标/状态分离断言。
- Screenshot review：`build/qa/pages_960x540/02_menu_settings.png` 与 `build/qa/pages_960x540/06_achievements.png` 已刷新；设置页正文不再贴 overview/维护区，成就页进度文案以独立胶囊显示。
- 验证记录：`assemble_main --check`、`assemble_main --verify`、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`、两套设置/成就截图 capture、两套 screenshot manifest 均通过；运行日志只保留既有 Xvfb/OpenGL/ALSA/ObjectDB/lambda 清理噪声。

## 2026-07-07 商店小屏右侧控件间距回归记录

- 生图需求先行复核：商店页已有 `shop_gpt_vault` 和 `shop_charm_*` 透明 charm 资源，本轮截图问题是 native 行内布局过密，不需要新增 GPT 图片。
- UI changes：`ShopItemsScroll` 右边界内收并让自定义滚动槽独立；商品文本背板略加宽，`ShopItemCountBadge_*` 右移到独立列，`ShopItemBuyButton_*` 收窄但保持可用触控尺寸；`持有` 徽章、购买按钮和滚动槽之间留出可见间距。
- Art changes：同步调整 `draw_shop_item_row_art()` 的货架、路线、库存 pip、结算轨和价格 aura 坐标，使装饰层跟随新的库存/购买列，不再按旧宽度穿到按钮区域。
- Test coverage：`scripts/ui_layout_smoke_test.gd` 新增商店行右侧控件 containment、`count_badge` 与 `buy_button` 可见间距、购买按钮避开行右缘/滚动槽、购买按钮最小触控尺寸断言。
- Screenshot review：`build/qa/pages/07_shop.png` 与 `build/qa/pages_960x540/07_shop.png` 已刷新；960x540 下库存徽章、购买按钮、滚动槽已经分开，列表底部仍避开 footer 说明栏。
- 验证记录：`assemble_main --check`、`assemble_main --verify`、`ui_layout_smoke_test.gd`、`verify_build.sh`、两套截图 capture、两套 screenshot manifest 和 `git diff --check` 均通过；运行日志只保留既有 Xvfb/OpenGL/ALSA/ObjectDB 资源清理噪声。

## 2026-07-07 规则页移动阅读优先回归记录

- 生图需求先行复核：只读 UI tester `Feynman` 复核两套 contact sheet 后判断 `04_rules.png` 的问题是 960x540 下 native 正文过密，不是缺少规则页 GPT 素材；不需要 GPT/Grok 生图。
- UI changes：规则内容从固定 4 段同屏改为 `RulesContentScroll` 可滚动阅读区；section 卡片高度增大，标题提升到 18px，正文提升到 15px 并增加行距；返回按钮触控高度提升到 44px。
- Visual hierarchy：保留国风卷轴/GPT guide/示例 strip，但正文阅读 lane 成为主要信息层；960x540 下只露出 2 个完整规则卡和第 3 个卡片开头，避免把全部规则压成桌面表格。
- Test coverage：`scripts/ui_layout_smoke_test.gd` 新增 rules scroll、暗色 gutter/thumb、compact viewport scroll depth、返回按钮 44px 高度、规则卡 8px 分隔、正文 15px 下限断言；`scripts/offline_smoke_test.gd` 同步 `RulesContentScroll/Gutter/Thumb` 结构断言。
- Screenshot review：`build/qa/pages/04_rules.png` 与 `build/qa/pages_960x540/04_rules.png` 已刷新；小屏下正文更大，卡片间距清楚，右侧为自定义暗色滚动槽，没有系统亮色滚动条。
- 验证记录：`assemble_main --check`、`assemble_main --verify`、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`、两套截图 capture、两套 screenshot manifest 和 `git diff --check` 均通过；运行日志只保留既有 Xvfb/OpenGL/ALSA/ObjectDB/lambda 清理噪声。

## 2026-07-07 主菜单版本 Chip 小屏完整显示回归记录

- 截图发现：`build/qa/pages_960x540/01_menu.png` 左下版本 chip 显示为 `版本 v1.0.165-go...`，属于展示层文案被迫省略，不是发布版本或更新逻辑问题。
- UI changes：新增 `app_version_short()`，主菜单 footer 只显示 `版本 v1.0.165`；`app_version()` 继续保留完整 `1.0.165-godot` 给更新比较、manifest 和发布 smoke 使用。
- Test coverage：`scripts/ui_layout_smoke_test.gd` 覆盖版本 chip 使用 compact 文案、不包含 `-godot` / `...` / `…`、并用字体测量确认文本在小屏 chip 内完整显示；`scripts/offline_smoke_test.gd` 同步检查菜单版本 badge 文案。
- Screenshot review：`build/qa/pages/01_menu.png` 与 `build/qa/pages_960x540/01_menu.png` 已刷新；两个视口左下版本 chip 均完整显示 `版本 v1.0.165`。
- 验证记录：`assemble_main --check`、`assemble_main --verify`、`git diff --check`、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`、两套截图 capture、两套 screenshot manifest 和 Grok 脚本 `py_compile` 均通过；运行日志只保留既有 Xvfb/OpenGL/ALSA/ObjectDB/lambda 清理噪声。

## 2026-07-07 生成 Chrome 残影降噪回归记录

- 只读复核：UI tester `Arendt` 复核最新 contact sheet 后指出 settings/achievements/shop 的部分生成 chrome 仍有伪文字、伪控件或过强线条残影；960 gameplay 底部行动区偏紧但未构成本轮阻塞。
- 生图优先处理：已先创建 text-free chrome prompt handoff；GPT Image 2 实际生成返回 `502 upstream access forbidden`。用户随后提供 Grok 会话凭证，Grok 成功生成两个 settings overview 候选，但都返回 RGB JPG 而非透明 PNG，暂不推广。
- Native mitigation：将 settings overview、settings section signal、shop currency meter 的可选生成贴图 alpha 下调到材质背景级；成就页全屏 gallery 贴图 alpha 下调到 `0.22`，避免生成画面被误读为第二套 UI。
- Achievements dashboard follow-up：截图确认残余横线主要来自原生 `AchievementsDashboardArt`，不是 GPT gallery；进一步降低 progress/unlock 装饰的 rail/fill/gate/source/node/tick alpha，保留 `已解锁` / `完成度` native 文本作为主信息。
- Test coverage：`scripts/ui_layout_smoke_test.gd` 新增 settings/shop/achievements 生成贴图 alpha 上限，以及 achievements dashboard progress/unlock 装饰 alpha 上限，防止后续回到高对比伪控件状态。
- Screenshot review：`build/qa/pages/02_menu_settings.png`、`06_achievements.png`、`07_shop.png` 与对应 `build/qa/pages_960x540/` 截图已刷新；960 contact sheet 全局扫视未发现新增遮挡、截断或控件重叠。
- Grok candidate review：`settings_overview_ultrawide_text_free_grok_v20.jpg` 是较好的长条参考，无伪文字/伪控件，但背景不透明；`settings_overview_ultrawide_text_free_grok_v20_extracted.png` 仍有背景残留，不进入 runtime。
- 验证记录：`assemble_main --check`、`assemble_main --verify`、`git diff --check`、`python3 -m py_compile tools/generate_grok_image.py`、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`、两套 screenshot capture、两套 screenshot manifest 均通过；运行日志只保留既有 Xvfb/OpenGL/ALSA/ObjectDB/lambda 清理噪声。

## 2026-07-07 核心对战通道与规则示例权威牌面回归记录

- 只读复核：新增 UI tester `Sartre` 复核最新 960/1280 contact sheet 后确认无新 P1 遮挡；指出两处可继续改善的问题：规则页 `牌型介绍` 示例像生成装饰图，多个二级页共享 `返回` 按钮中心线条穿过文字。
- Battle layout changes：压短 `ACTION_BAR_*` / `PENDING_CLAIM_ACTION_BAR_*` 下沿，让单机对战行动 dock 和按钮与 `HandTray` 之间保留更明确的 960-safe 通道。
- Back button changes：降低 `SecondaryBackConfirmRoute/Fill/Gate/Tick_*` alpha，让共享 `返回` 按钮保留边框与触控 affordance，但中心标签不再被路线装饰覆盖。
- Rules example changes：`牌型介绍` 不再优先消费 `rules_pattern_quads` 生成图；改为用 runtime `make_tile_view()` 绘制顺/刻/杠/将四组权威牌面示例。
- Test coverage：`scripts/ui_layout_smoke_test.gd` 将 battle action dock/button 与 hand tray 的最小间距提高到 12px；新增二级返回按钮中心装饰 alpha 检查；规则页新增 native pattern example group/tile 检查并断言不再使用 `RulesPatternQuadsTexture`。
- Screenshot review：`build/qa/pages_960x540/03_offline_battle.png` 行动按钮和手牌托盘之间通道更清楚；`build/qa/pages_960x540/04_rules.png` 与 `build/qa/pages/04_rules.png` 的 `牌型介绍` 示例已显示正式牌面小组；`build/qa/pages_960x540/05_stats.png` 的 `返回` 文案不再被中心线穿过。
- 验证记录：`assemble_main --check`、`assemble_main --verify`、`git diff --check`、`python3 -m py_compile tools/generate_grok_image.py`、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`、两套截图 capture 和两套 screenshot manifest 均通过；运行日志只保留既有 Xvfb/OpenGL/ALSA/ObjectDB/lambda 清理噪声。

## 2026-07-07 统计页 Summary 单位一致性回归记录

- 截图发现：`build/qa/pages_960x540/05_stats.png` 的顶部 `单局最佳` summary chip 曾只显示裸分值，而下方 `单局最佳` 行显示带 `分` 的数值，读起来像两个不同单位。
- UI changes：`StatsSummaryValue_best` 改为使用 `compact_score_text(best_score_value) + "分"`，顶部 summary 与明细行统一使用分值单位。
- Test coverage：`scripts/ui_layout_smoke_test.gd` 覆盖 `StatsSummaryValue_best` 必须以 `分` 结尾且在小屏 chip 内适配；`scripts/offline_smoke_test.gd` 同步从旧的精确 `9600` 改为 `9600分`，防止回退到裸数字。
- Screenshot review：`build/qa/pages/05_stats.png` 与 `build/qa/pages_960x540/05_stats.png` 已刷新；两个视口顶部 `单局最佳` 均显示带单位数值，行内 `累计净分` / `单局最佳` 仍完整显示。
- 验证记录：`assemble_main --check`、`assemble_main --verify`、`git diff --check`、`python3 -m py_compile tools/generate_grok_image.py`、Grok key 扫描、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`、两套截图 capture 和两套 screenshot manifest 均通过；运行日志只保留既有 Xvfb/OpenGL/ALSA/ObjectDB/lambda 清理噪声。

## 2026-07-07 成就页目标/进度分层回归记录

- 只读复核：新增 UI tester `Noether` 复核最新 contact sheet 后把 `build/qa/pages_960x540/06_achievements.png` 列为最高优先级；问题是成就行目标说明、进度 chip、进度线和状态胶囊挤在一行，扫读“已解锁 / 待达成 / 还差多少”不够直接。
- 生图需求先行复核：成就页已有 `achievement_gpt_gallery` 和 medal glow 资源，本轮问题是 native 行高、文本层级和状态 lane，不需要 GPT/Grok 生图。
- UI changes：成就行高从 `62` 提升到 `84`，960x540 下改为显示 3 个完整但更清晰的条目；`AchievementRowGoalBackplate_*` 为目标说明提供独立暗底；`AchievementRowProgressTextBackplate_*` 与进度 rail 下移到目标行下方；右侧状态胶囊加宽提亮，`已解锁` 状态文案提亮。
- Test coverage：`scripts/ui_layout_smoke_test.gd` 覆盖成就行最小高度、目标背板 containment、目标/进度纵向分离、进度 rail 避开状态 lane、目标/进度/状态字号和亮度阈值，以及锁定行同样的分层规则。
- Screenshot review：`build/qa/pages_960x540/06_achievements.png` 已刷新；小屏下前三个成就行均完整显示，目标、进度和状态分为清楚的上下/左右 lane。`build/qa/pages/06_achievements.png` 在桌面尺寸下显示四个完整行，列表更像任务卡而不是压缩表格。
- 验证记录：`assemble_main --check`、`assemble_main --verify`、`git diff --check`、`python3 -m py_compile tools/generate_grok_image.py`、Grok key 扫描、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`、两套截图 capture 和两套 screenshot manifest 均通过；运行日志只保留既有 Xvfb/OpenGL/ALSA/ObjectDB/lambda 清理噪声。

## 2026-07-07 前期 UI 问题一键回归验证记录

- Automation changes：新增 `scripts/verify_ui_regressions.sh`，把前期 UI 排查结果对应的自动化门禁串成一条命令。
- Gate coverage：脚本依次运行 Python QA 工具编译、可选 Grok 工具编译、`assemble_main --check`、`assemble_main --verify`、`git diff --check`、`ui_layout_smoke_test.gd`、`offline_smoke_test.gd`、1280x720 截图 capture + manifest、960x540 截图 capture + manifest。
- Finding matrix：聚合报告把主菜单版本 chip、设置页密度、单机对战行动区/手牌通道、规则页可读性/权威牌面、统计页单位、成就页层级、商店右侧控件、联机未连接状态、每日签到预告、加载页 fallback 叠层和生成 chrome 残影映射到对应 gate。
- Latest run：`./scripts/verify_ui_regressions.sh` 已通过，结果为 `PASS (11 passed, 0 failed)`。
- Artifacts：聚合报告写入 `build/qa/ui_regression_verification_report.md`；两套截图 contact sheet 分别为 `build/qa/pages/contact_sheet.jpg` 和 `build/qa/pages_960x540/contact_sheet.jpg`。
