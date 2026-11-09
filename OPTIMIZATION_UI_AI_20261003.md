# UI / AI 改进记录 · 2026-10-03

## 范围与约束

- 持续目标：完善游戏的 UI 和 AI；本记录只描述本批次，不代表整个目标完成。
- 保持版本 `1.0.180-godot`、既有 2D 牌面与位图 UI，不新增程序绘制装饰。
- UI 工程师只读审计；主 agent 修改源码、assemble，并串行运行 Godot QA。

## AI：字牌见尽的风险判断

原先即使行动者通过公开牌与自己的手牌已知某字牌的四枚，对手已有副露或暗杠，风险函数仍会根据副露、牌河深度与字牌路线累加点炮风险。另一方面，闭门对手的风险又可能被稀缺度扣分压到零，遗漏本仓库支持的十三幺单缺字牌。

现在：

- 已知四枚字牌且对手有任何已完成副露/杠组时，该家的点炮风险为零；该对手无法组字牌对子/刻子，也无法形成十三幺。
- 闭门对手仍保留十三幺的残余风险；`0.5` 是启发式风险分下限，不是概率，不读取对手暗牌判断其是否真持有十三幺。
- 已知四枚的字牌不再叠加字牌副露路线威胁；批量风险向量与单独路线查询保持一致。
- 补杠风险使用公开牌加行动者自己的手牌，而非只计公开的三枚碰牌；补杠威胁缓存将行动者自己的手牌纳入签名，不读取其他人的暗牌。
- 对手公开打过该张的振听优先返回零；三枚已知字牌与数牌不使用这一豁免，数牌仍可能补成顺子。
- UI 不将闭门对手的第四枚字牌标为全桌安牌。

回归：`scripts/ai_play_round293_check.gd`。修改前已复现失败，修改后覆盖七种字牌、公开/自知数量分离、暗牌替换不影响判断、十三幺真实成和例外、暗杠、振听、数牌顺子例外及完整弃牌报告。用例接入 `scripts/verify_ai_commercial.sh`。

## UI：真实焦点、弹层与操作后果

UI 工程师记录 F-033～F-036。新增 `scripts/ui_input_safety_smoke_test.gd` 通过真实键盘事件复现修复前问题，再覆盖修复后的行为；复用既有交互 smoke 的测试辅助函数和用户文件备份/恢复，不改玩家本地资料。

- 非手牌原生按钮焦点的 Enter / 小键盘 Enter / Space 在手牌快捷键节流前放行，避免取消、改打、碰牌被历史选牌或“过”快捷键抢走。
- Esc 优先关闭真实可见的隐私、设置、聊天、牌势详情或牌桌日志弹层，不作用于被遮挡的响应/危险确认。设置中的已武装重置先撤销确认；保留无弹层时 Esc 过/取消的契约及残留 advisor 状态回归。
- 手牌 tooltip 与视图共享安全标签“非空才优先”的规则；空或空白安全标签正确回退到风险高/中/低，不丢失推荐/确认/新摸状态。
- 待确认的手牌使用该确认已经锁存的风险报告，避免重绘后混入其他建议而显示“高危确认 / 风险低”的矛盾提示。
- 重置的默认/确认文案、tooltip、元数据、确认 art、toast 和截图契约统一为“仅清空离线续局存档，保留战绩”。删除范围不扩大；五秒二次确认在回调入口也检查有效期。
- 重开设置时先检查缓存控件是否仍有效，避免对已释放对象做类型转换。新增三档输入安全 smoke 的日志均纳入完整 QA 的运行错误/泄漏扫描，不仅依赖脚本退出码。
- 三档 QA 额外暴露响应超时死锁：`human_claim("pass")` 在期限已过时提前返回，自动过和过水状态均不生效。改为将过期响应统一转为 `pass` 后正常结算响应；新增 round 294 覆盖显式过、过期吃碰杠胡、自动超时、重复处理与未过期正常胡牌，并接入 AI 门禁。弹层测试单独保持未过期窗口，超时行为由明确的过期用例验证。

## 本批验证

- 已完成：assemble / verify、AI round 96、13、281、268、292、293、91，第一轮完整 AI 门禁 42/42，以及 UI 修复前真实键盘事件复现。
- 已完成：UI 修复后定向测试，以及最终源码的完整串行 UI 与 AI QA；最终门禁结果见下方此轮证据。
- 最终证据以本批新生成的 QA 报告为准，不将历史 PASS 当成当前改动的完成证明。

## 2026-10-06：HUD、章节状态与大厅反馈

- 维持顶部 HUD 外壳边界与顶家安全区；联机分值条与余牌槽保留独立列，不向下扩展 HUD 侵入顶家铭牌。
- 余牌槽由 `TopHudWallText` / `TopHudWallState` 独占可见墙数、状态及上张文字；停用 meter 的重复数字、上张印章、低量小字与穿过状态行的轨道，保留既有位图及低量警示。离线 smoke 增加正常/低量时重复元素不可见断言。
- 规则页当前章节标签扩大现有位图槽，首帧与章节更新统一显示 `第n/6 · 章节名`，首帧字号提升至 12px；不新增绘图资源。
- 大厅按钮上方使用短句区分连接、创建、加入条件；创建不要求房号，加入要求房号。当前开局条件使用实际 start gate，而不是长期保留的同步成功/等房主反馈。
- 截图 fixture 的“房间同步完成，等待房主开始”改为中性“房间同步完成”，不改三人/未准备的局面，也不更改服务器权限或开局逻辑。
- 新增 `scripts/ui_lobby_feedback_smoke_test.gd`：修复前真实复现人数变化仍沿用旧原因、已就绪房主仍显示等待、禁用开局时同步错误被普通 gate 文案覆盖三项失败；修复后均通过。start gate 的 `reason` 纳入两个大厅状态签名，错误反馈优先保留，历史反馈仍可在日志中查看。
- 新 smoke 接入完整 UI QA 的门禁与运行错误/资源泄漏扫描，不仅依赖退出码。

### 此轮证据边界

- 已通过：定向 AI round 293/294、真实键盘三档输入安全、离线 smoke、Xvfb 交互 smoke、布局 smoke、大厅反馈/动态 gate smoke；在本次最终 gate 修正前也完成完整 UI 29/29 和 AI 43/43。
- 最终完成：完整 UI **30/30**、AI fresh **43/43**，均无失败。UI 包括三分辨率截图/清单、输入安全/可访问性、运行错误/资源泄漏扫描与新增大厅反馈门禁；AI 包括信息公平性、规则合法性、牌/分守恒、多种子强度与独立固定玩家压力抽样。
- 两份最终报告与当前运行源码的 diff fingerprint 均为 `1f009ea5d2c70897abf15cef3ae79fb3714090a3ace4131b7a848f0975db2328`。报告为 `build/qa/ui_regression_verification_report.md` 与 `build/qa/ai_play_commercial_evidence/EVIDENCE_LATEST.md`；未拿历史 PASS 支撑最终源码。
- 本记录不是整体目标完成声明。规则导航/滚动可读性和整局交互仍需依当前截图及运行证据逐项复核；Xvfb 不代替真实触屏设备验证。

## 2026-10-07：动态 HUD 与规则滚动回验

- 先复现 HUD-only 刷新中的主状态、tooltip 和可访问牌墙状态滞后：旧签名仅含墙数/上张，换家或进入响应窗口时可以跳过更新；健康牌墙首次渲染也不创建低墙警示，之后进入低量无法切换该位图。
- `refresh_battle_hud_lane()` 的去重签名纳入实际短状态与 tooltip；更新 `wall_state` 元数据，并缓存/切换既有低墙位图。初次渲染常驻创建该警示但按墙量控制可见，不增加重复小字、不重建牌桌。
- 新增 `scripts/ui_hud_live_smoke_test.gd`：三分辨率覆盖离线墙量 `64→24→18→0→64`、联机四川墙量 `55→18→14→24→18`、换家、响应、服务器等待/拒绝、上张变更、HUD 实例保留与延迟 `hud_only` flush 去重。当前定向结果通过。
- UI 工程师复核最新三档截图，确认 F-908 规则握柄可发现性问题，另列 F-909 非顶部规则截图、F-910 compact 长反馈证据缺口。未重开已关闭的历史 HUD/大厅短句问题。
- F-908 根因不是父轨道颜色继承：共享 quiet-chrome 路径把握柄请求的 `ui_progress_signal_strip` 替换成暗色 scrim。仅规则握柄改用原 authored 位图的中心裁切，不改共享静音策略、轨道尺寸或 44px 独立命中层；布局测试锁定实际纹理来源。
- 新真实鼠标拖动测试复现了不可达的 `relative_y` 赋值（错误缩进到 `return` 后），修正后鼠标、合成触控拖动、滚轮、Home/End/PageDown 均更新原生 scroll range 与握柄位置。
- 长服务器拒绝/同步失败反馈定向复现缩到 10px，现保持至少 12px，并沿用明确省略号与完整 tooltip；不修改服务器权限或开局门禁。满员未准备、空房间创建/加入条件也保留截图与状态元数据。
- 新增 `scripts/ui_reading_evidence_smoke_test.gd`，在三档 Xvfb 下保存规则顶部/第3章/第6章及大厅长反馈/满员/空房间证据；定向三档均通过。对应截图位于 `build/qa/reading_evidence_960x540/`、`build/qa/reading_evidence_1280x720/`、`build/qa/reading_evidence_1920x1080/`。
- 两个新 smoke 接入完整 UI 门禁，其全部日志都纳入运行错误与资源泄漏扫描。完整 UI/AI 最新源码验证仍以此轮最终串行报告为准，不沿用 10 月 6 日的 PASS。
- 定点截图复验关闭 F-908～F-910 后，发现 F-911：规则章节被专用/通用焦点位图遮字。章名、状态和图标提升到同一文本绘制层，焦点面仍在原底层，保留真实按钮焦点与 44px 命中；新 smoke 检查两层焦点面与文字的层级，并补保留焦点/Tab 后的截图。
- F-911 后续复验进一步确认两条 Label 原本仅相隔约 4～5px 的顶部位置，字形自身叠行。入口现在按 Label 的实际最小行高分配两条独立像素槽与 2px 行距，图标独立放在状态左侧；不缩字号、不清焦点、不更改章节跳转。初次完整 QA 在早期交互检查时主动中止，不作为完成证据；以修正后的新一轮完整报告为准。
- 版本仍为 `1.0.180-godot`；未改 `assets/tiles`，未新增程序绘图或视觉资产；整体验收目标继续保持进行中，真实触屏设备体验未由 Xvfb 证明。

### 10 月 7 日最终串行证据

- 最终完整 UI **34/34 PASS**、AI **43/43 PASS**，两条脚本退出码均为 `0`；AI 为 `fresh`，执行 43 项、缓存复用 0 项。UI 的运行错误与资源泄漏扫描均通过。
- UI 批次为 `20261007T042404Z-582e174-92f268d6cd6e`，AI 批次为 `20261007T044825Z-582e174-92f268d6cd6e`。两份报告、三档页面截图、三档可访问性元数据与 27 份阅读位置/反馈证据 JSON 均已核对到当前源码指纹 `92f268d6cd6e91afdf3e91a5768ff242298dcdc2524859d70e0b2c3e5fc78a79`。
- 最新证据为 `build/qa/ui_regression_verification_report.md` 和 `build/qa/ai_play_commercial_evidence/EVIDENCE_LATEST.md`。UI 工程师在 `build/qa/ui_engineer/AUDIT_LATEST.md` 的最终定点附录确认 F-908～F-911 可关闭；早期中止的 QA 和此前旧图不计为当前通过证据。
- 本轮保持单线程、低 CPU/I/O 优先级与每次 Godot 180 秒硬超时，未并行启动重型任务，未提交代码。以上是本批修复与回验的完成记录，不是整个 UI/AI 持续目标或真机触屏验收的完成声明。

## 2026-10-07：大字阅读布局与抢杠缓存边界

- 重新核查当前工作树，而非沿用凌晨门禁：960×540 的大字＋高对比阅读测试重新复现 10 条失败，包括六章导航侵入标题、前两章裁字、长错误反馈被刷新路径压回 12px。UI 工程师只读审计记录 F-912～F-915，并区分已确证缺陷与尚缺组合截图的 F-916～F-918 风险。
- 规则导航在大字模式按实际字体宽度和两行最小高度分配入口，在标题下方排布；正文、既有位图滚动轨道与独立 44px 命中区使用同一导航底部预算。不缩字、不取消章节状态、不清除真实键盘焦点。
- 大厅反馈保留 `accessibility_font_size(12)`；仅提高字号曾定向暴露反馈侵入按钮行，现按实际字段/反馈/操作高度分配独立纵向槽，保留 8px 间隙。紧凑布局的连接、创建、加入、开始、返回均保持至少 44px，底部状态单独避让，不改联机权限或服务器开局条件。
- 房间日志标题与范围按真实字体最小高度排成两行，正文从完整头部及“最新”44px 触控区之后开始；沿用既有位图底板。测试检查头部行距、正文间距、完整行高与独立按钮命中区。
- 承接工作树中的 AI round 295 缓存修复：补杠威胁 memo 纳入难度、剩余牌墙与公开过水状态，避免没有新弃牌时继续使用旧风险门槛/准备度。已有测试覆盖真实难度切换、墙量变化、过水及解除、返回数据隔离、对手暗牌替换不影响公开信息判断；本批再补 64 项上限、LRU 淘汰/命中提升及淘汰后重算一致性验证。
- 将三分辨率大字＋高对比阅读检查接入完整 UI QA，所有新日志纳入运行错误和资源泄漏扫描；AI round 295 已接入完整 AI 门禁。
- 定向证据：assemble / verify、AI round 295（含新增 LRU 断言）、91、281、293，以及 960×540 / 1280×720 / 1920×1080 大字阅读截图与行为断言通过。最终完整门禁见下方本批归档，不使用此前 34/34、43/43 替代。
- 本批不新增视觉资产、不改 2D 牌面、不回 3D，版本保持 `1.0.180-godot`。F-916～F-918 的真实对战弹层组合证据和真机触屏体验仍待继续核查，持续目标保持进行中。

### 本批最终证据

- 完整 UI **37/37 PASS**，失败 0；三档标准/大字＋高对比阅读、真实输入、可访问性、页面截图清单、运行错误及资源泄漏扫描均通过。UI 批次 `20261007T230228Z-582e174-79501d319e1d`，报告为 `build/qa/ui_regression_verification_report.md`。
- 完整 AI **44/44 PASS**，失败 0，实际执行 44 项、缓存复用 0 项，运行模式 `fresh`。AI 脚本默认就是 fresh，无参数运行；批次 `20261007T232837Z-582e174-79501d319e1d`，报告为 `build/qa/ai_play_commercial_evidence/EVIDENCE_LATEST.md`。包括新 round 295、信息公平性、规则合法性、牌/分守恒、多种子强度及独立固定玩家压力抽样；AI 日志追加扫描未发现运行错误/资源泄漏标记。
- 两份报告与当前运行源码均匹配指纹 `79501d319e1d8ed3e166b8b7dcd69d54215ab4311a43f80ede166bf38b5fb7c4`。另核对三档双阅读配置的 **54 对 PNG/JSON**：全部与 UI 批次及同一源码指纹一致，版本和大小正确，不拿旧目录中残留图代替当前证据。
- UI 工程师在 `build/qa/ui_engineer/AUDIT_LATEST.md` 的新图附录逐档复验 27 张大字组合图，关闭 F-912～F-915；保留 F-916～F-918 为尚缺真实组合证据的风险，不将它们误记为已修。
- 早期被终止的门禁和未执行检查的参数错误调用不计 PASS。最终完整 UI 和 AI 均正常退出 0；完成后确认无 Godot/Xvfb 残留，资源任务没有并行执行，未提交代码。本批完成不代表整个 UI/AI 持续目标或真机触屏验收完成。


## 2026-10-08：牌桌阅读、聊天滚动与推荐焦点

- 补齐真实对战阅读回归，复用生产出牌日志、AI 弃牌报告、聊天传输及实际鼠标／触摸／键盘事件。修前有效 960 大字证据确证 F-916～F-920：聊天各行与动作相互侵入、牌势详解头部和正文重叠、ledger／archive 字号被重置、紧凑日志合并后只显示旧事件、定位推荐后焦点归属错误。
- 聊天保留既有避让座位／副露／牌河的抽屉边界，按真实字高固定标题、范围与 44px 历史／关闭入口；消息、全部快捷、完整字符计数、输入／发送及冷却提示由原生纵向滚动布局承载。透明布局容器仅负责顺排，底板与装饰仍使用仓库既有 illustrations 位图。
- 输入／发送以真实 8px 间距排布。扩展回归发现清空代理还留在抽屉外层，现把输入与代理放进同一透明字段容器，随 body 一起滚动；触摸清空实际清空输入、更新 0/64 计数并恢复输入焦点。副露 2／1 座的替代路由和已连接大厅的非紧凑聊天同样验证完整输入可达。
- 牌势详解按实际标题／上下文字高排头部，推荐与关闭保持 44px，正文从完整头部以下开始；推荐保留大字字号。定位仅更新选牌与关闭后的恢复目标，手牌聚焦函数遵守 modal 输入许可，详情内建立明确焦点顺序；真实触摸定位不出牌／不弹危险确认，Esc 关闭后焦点精确落到 AI 报告推荐的手牌索引。另验证其他玩家回合的“暂无推荐”禁用入口。
- 牌桌 ledger 保留无障碍字号，紧凑行直接显示生产日志最新事件，按实际字高选择可容纳的行数；archive 标题与计数保留字号，头部／route／正文独立排布。pending 响应继续隐藏次要 ledger。
- 新焦点路径触发 retained action dock 再挂载时发现重复连接 focus_entered 的运行错误，现仅连接尚未注册的同一 callable，保留原提示逻辑。
- 三分辨率 × 标准／大字高对比的 battle reading smoke 接入完整 UI QA，六份日志同时加入运行错误与资源泄漏扫描。layout 检查逐个原生滚动并测量消息、标签、全部快捷、输入、发送及冷却提示的完整可达矩形，并在副露替代路由重复验证，不仅检查节点存在或 meta 声明。
- 第一轮完整 UI 为 **42/43**，唯一失败是错误扫描发现 `offline_smoke_test.gd` 未引用四个新透明布局节点，并非六档聊天行为检查失败；已保留失败报告 `build/qa/ui_regression_verification_report_20261008T001308Z_failed.md`。补充原生 scroll／VBox／HBox／输入字段的实际类型、父子归属、44px 目标和 8px 间距断言后，定向 offline smoke 正常退出且无运行错误；原失败批次因 UI 不通过而未启动 AI，不计为完整通过。
- 定向 960×540 大字 smoke、三档 headless layout、assemble／verify 和 whitespace 已通过，运行源码指纹为 `3854bb072a48598b56862318daa86df8d6ad09a5972030f807c4c8dc3c89f92f`。同源码完整门禁已正常结束，见下方归档；旧报告不能替代本批证据。

### 本批自动回归归档

- 完整 UI **43/43 PASS**，失败 0，终端退出 0；包括六档新的 battle reading、三档真实输入安全、既有规则／大厅阅读、可访问性、全页面截图清单、运行错误和资源泄漏扫描。UI 批次 `20261008T035238Z-582e174-3854bb072a48`，报告为 `build/qa/ui_regression_verification_report.md`。
- 完整 AI／玩法 **44/44 PASS**，失败 0，实际执行 44、缓存复用 0，运行模式 `fresh`，终端退出 0。AI 批次 `20261008T042221Z-582e174-3854bb072a48`，报告为 `build/qa/ai_play_commercial_evidence/EVIDENCE_LATEST.md`；补杠 memo／LRU 边界、公开信息公平性、规则合法性、牌／分守恒、多种子强度与独立固定玩家压力抽样均通过，追加扫描未发现 AI 运行错误／资源泄漏标记。
- 核对两份报告与当前工作树的同一运行源码指纹 `3854bb072a48598b56862318daa86df8d6ad09a5972030f807c4c8dc3c89f92f`。重新验证三分辨率双配置的 **102 对 battle PNG/JSON** 与 **54 对原 reading PNG/JSON**：统一最终 UI 批次、版本与实际 PNG 尺寸一致；额外检查定位／恢复索引及 modal owner、禁用推荐、64/64 计数、发送文本、副露替代路由。结果保存于 `build/qa/battle_reading_capture_manifest_validation.log`，不使用旧目录残图或旧批次充数。
- 最终串行完整门禁记录在 `build/qa/ui_ai_battle_lanes_20261008T035238Z.log`；保持单线程、低 CPU/I/O 优先级与每次 Godot 180 秒硬超时。完成后 assemble／verify、whitespace 再次通过，确认无 Godot/Xvfb/xvfb-run 残留，未提交代码，未新增视觉资产或修改牌面，版本保持 `1.0.180-godot`。
- **视觉签核仍待返回**：用户中断后的旧 UI 审计协作多次无响应，已关闭旧实例并启动有界只读复审。尚未收到本批独立视觉结论，故不凭自动门禁 PASS 将 F-916～F-920 记为视觉关闭，F-912～F-915 的既有关闭记录不回滚。真机触屏、实时状态更新与整局更多动态组合仍需后续验证；本批自动回归完成不代表整个 UI/AI 持续目标完成。

## 2026-10-08：弃牌风险缓存的过水生命周期

- 持续目标重新 active 后核查工作树：上一批 UI 43／AI 44 和 156 对截图均确实对应 `3854bb072a48598b56862318daa86df8d6ad09a5972030f807c4c8dc3c89f92f`，没有沿用不匹配源码的通过声明。沿用现有只读 UI 审计实例，观察超时不视为任务终止，不另行重复派工。
- 新 round 296 在未修改生产源码前复现 **10 条失败**：合法放弃 7 万和牌后，在无新公开牌、无 gameplay revision 变化的情况下，弃牌报告继续返回旧的点炮风险／针对玩家压力；清除过水后又继续使用零风险报告。缓存键还混淆了“过水人数相同但座位不同”以及多家同时过水的状态。修前日志为 `build/qa/ai_play_round296_before.log`。
- 弃牌和座位威胁共用的 table-state key 现在纳入每座临时过水状态的位掩码，同时进入输入快键和最终公开状态键。依据本仓库 `is_passed_win_tile` 的全等待过水规则，只记录活跃座位，不纳入具体放弃牌或对手暗牌；重复添加另一张过水牌继续命中同一有效缓存，清除后恢复原策略键。
- 同一回归还确证复用 `evaluation_context_output` 时，缓存命中／无效座位／空手牌出口会遗留旧压力与风险上下文。现在统一在函数入口清空输出 sink，缓存 miss 仍导出完整新上下文，缓存 hit 仍保持惰性创建，未把多余上下文重建加到热路径。
- round 296 验证缓存和 fresh 的完整排序／风险／玩家压力一致、清除状态恢复原报告、合法实际和牌等待、多座位区别、同时过水、重复过水缓存复用、对手暗牌替换不影响键与决策，以及输出 sink 的所有早退分支。修后独立运行通过，另串行回验 131／268／295／296 全部退出 0，无运行错误或资源泄漏标记。
- 新用例接入统一 AI／玩法门禁，项数从 44 增至 45；没有降低难度、缩减强度样本或放宽性能／安全阈值。源码指纹变为 `0370045e9af3b253f698e5e0c8ddf98b14b114dc7cf28f58bcd88aa616826863`，因此旧 43／44 和旧截图不能替代本轮完整回验；本轮同源码完整 UI → fresh AI 已串行执行完毕，最终证据见下。
- 保持 `1.0.180-godot`、既有 2D 牌面与位图 UI；本轮不改 UI 几何、视觉资源或规则，不修改对手暗牌信息边界，不标记整个 UI／AI 目标完成。

### 过水缓存修复的最终证据

- 沿用既有 PTY 会话 `77980` 至正常终结，没有因观察超时重启重型任务。完整 UI **43/43 PASS**，失败 0，批次 `20261008T093942Z-582e174-0370045e9af3`；完整 AI **45/45 PASS**，失败 0，实际执行 45、缓存复用 0，模式 `fresh`，批次 `20261008T100918Z-582e174-0370045e9af3`。两套脚本均退出 0。
- 两份最终报告均与该批验证时的运行源码指纹 `0370045e9af3b253f698e5e0c8ddf98b14b114dc7cf28f58bcd88aa616826863` 一致。通过快照为 `build/qa/ui_regression_verification_report_20261008T093942Z_pass.md` 和 `build/qa/ai_play_commercial_evidence/EVIDENCE_20261008T100918Z_pass.md`，不以旧批次报告代替后续改动的证据。
- 三档尺寸、标准／大字＋高对比共 **102 对 battle PNG/JSON + 54 对 reading PNG/JSON** 均核对名称成对、UI 批次、源码指纹、版本、阅读配置及 PNG 实际尺寸。推荐定位时焦点在详情内、关闭后恢复推荐牌、无推荐入口禁用、完整 64/64 计数、单次实际发送以及副露聊天安全路由断言全部通过。记录为 `build/qa/battle_reading_capture_manifest_validation.log`。
- 逐项核对本批全部 **45 份新执行 AI 日志** 的时间与终结记录，未发现运行错误或资源泄漏标记；新 round 296 在统一门禁中通过，未用定向测试结果替代全量 fresh 验证。
- 强度种子、每难度样本、shuffle 配置及独立固定玩家抽样保持不变，paired／fixed 聚合结果与上一批一致。paired 门禁 152 秒，独立压力样本 93 秒，均未放宽 180 秒阈值；强度 JSON 总计 135160ms（旧批 135173ms，仅作观测，不宣称加速），快照为 `build/qa/ai_play_commercial_evidence/STRENGTH_PACK_20261008T100918Z.json`。
- 组装字节一致性、shell 语法和 whitespace 检查通过，最终确认没有 Godot／Xvfb／批量生图进程残留。资源任务全程串行，没有提交代码或修改版本。
- 现存只读 UI 工程师仍未返回修后视觉结论，沿用同一实例与阅读进度，不因等待超时重派；F-916～F-920 尚未取得视觉签字，不能因自动门禁通过而记录关闭。真机触屏及未覆盖动态组合仍是后续验收项，整个 UI／AI 持续目标保持 active。


## 2026-10-08：聊天草稿的动态重绘生命周期

- 上一目标轮属于有效进展：过水缓存修复的完整 UI／fresh AI 正常结束，并核对同源码报告与截图；本轮没有把旧批绿色状态当作整个 UI／AI 目标完成。
- 在现有真实 battle reading smoke 中补入聊天动态回归，修前复现 **6 条失败**：联网牌桌连续重绘后草稿被清空、焦点离开输入、原生 caret／选区消失、外层 composing 滚动位置改变、内部消息历史跳回最新；大厅重绘更直接销毁整个已打开抽屉。修前日志为 `build/qa/ui_chat_live_redraw_before.log`。
- `clear_screen` 现在仅对同一页面／连接 session／房间的有效聊天抽屉保存文本、原生 caret／选区、焦点及两个独立滚动位置。重新挂载时恢复草稿并同步字符计数；连续同帧重绘使用尚待恢复的逻辑状态，不把刚创建、尚未完成原生排版的空选区写回。
- 保留原生 focus-follow 完成后的恢复顺序，避免多次 ensure-control 把外层视口额外推到最底。焦点恢复检查当前实例、所属 root、连接／房间和更高优先级弹层；较新的用户焦点优先，旧回调不得抢确认焦点、复活已关闭草稿或向新会话／房间带入旧输入。断线清除暂存状态，大厅重绘重新挂载有效聊天抽屉。
- **960×540、1280×720、1920×1080，标准／大字＋高对比六档定向动态回归全部退出 0**。覆盖来消息时继续编辑、连续重绘、选区／caret、字符计数、消息／外层视口、关闭重开、旧回调、新 session、换房、较新焦点和退出确认优先级；无聊天／出牌／鸣牌误发送。日志为 `build/qa/ui_chat_live_redraw_<size>_<profile>.log`。
- 回归保留在六个既有 battle reading 门禁中，不以临时 probe 代替持久覆盖。新增真实重绘后 compose PNG/JSON 两对／档，battle 证据从 17 对／档增至 **19 对／档，114 对总计**；加上现有 reading 54 对，完整回验预期 **168 对**。单次发送元数据另记录实际 `chat_writes`／`table_writes`，不把握手／心跳的总写入数当成重复聊天。
- 本批运行源码指纹 `d38686325ecfa21277e4576e9ef8a5815d461a53be239f9ef3cb88d1fd61c823`。版本、2D 牌面及既有位图不动，没有新增装饰或改变聊天避让几何；组装一致性、shell 语法和 whitespace 检查通过。旧 0370 报告只证明历史批次；本轮完整同源码 UI → fresh AI 已正常结束，最终 43／45 及证据校验见下。
- 继续保留同一只读审计实例与既有看图进度；自动回归不等于 F-916～F-920 的视觉签字，也不替代真机中文输入法／触屏验收。整个 UI／AI 持续目标保持 active。
- 完整 960 大字 battle smoke 已通过，独立输出目录 `build/qa/chat_live_redraw_after_960_large/` 的 19 对截图／元数据均生成，两张重绘 compose 的草稿、焦点、caret、选区、计数及视口位置进一步核对。完整串行回验沿用 PTY 会话 `24624` 至退出 0，总日志为 `build/qa/ui_ai_chat_live_redraw_20261008T144246Z.log`，UI 批次 `20261008T144335Z-582e174-d38686325ecf`；没有因观察超时重启，亦未用定向回归替代全量门禁。
- 新增持久证据校验 `tools/verify_reading_capture_manifests.py`，统一检查 168 对命名／成对／尺寸／阅读配置、同批次与当前运行源码，以及推荐焦点、单次真实聊天发送、原生重绘编辑状态；可同时核对 fresh AI 的完整 gate 计数与新日志／终结／运行错误标记。旧源码报告的拒绝测试、19 份实际定向状态和六种损坏编辑状态的拒绝测试通过。最终运行 `python3 tools/verify_reading_capture_manifests.py --ai-report build/qa/ai_play_commercial_evidence/EVIDENCE_LATEST.md` 已返回 PASS，不使用旧 latest 报告替代当前接受结果。

### 动态重绘修复的最终证据

- 完整 UI **43/43 PASS**，失败 0，批次 `20261008T144335Z-582e174-d38686325ecf`；完整 AI **45/45 PASS**，失败 0，执行 45、缓存 0、模式 `fresh`，批次 `20261008T151611Z-582e174-d38686325ecf`。目标脚本、UI 脚本、AI 脚本和组合会话均正常退出 0，当前源码指纹与两份报告一致。
- 持久校验器实际核对 **114 对 battle + 54 对 reading = 168 对 PNG/JSON**，包含六档重绘后牌桌／大厅编辑状态；以及本批 **45 份 fresh AI 日志**，无运行错误或资源泄漏标记。最终日志为 `build/qa/battle_reading_capture_manifest_validation.log`，未把 capture-only 校验或旧源码的绿色报告混作本批全量接受。
- 报告快照为 `build/qa/ui_regression_verification_report_20261008T144335Z_pass.md`、`build/qa/ai_play_commercial_evidence/EVIDENCE_20261008T151611Z_pass.md`，强度快照为 `build/qa/ai_play_commercial_evidence/STRENGTH_PACK_20261008T151611Z.json`；组装和 whitespace 复核通过，完成后确认没有 Godot／Xvfb／批量生图进程残留。
- 强度种子、每难度样本及 paired／fixed 聚合结果与上一批一致。paired 门禁 152 秒、独立压力样本 93 秒；强度 JSON 总计 134484ms（上一批 135160ms，仅作观测），没有缩减样本、放宽 180 秒阈值或宣称 AI 加速。
- 只读 UI 工程师仍未返回视觉结论，保留同一实例与既有阅读进度；F-916～F-920 不据自动门禁记为视觉关闭。真机触屏及中文输入法组成态仍待验收，整体 UI／AI 目标保持 active。
- 下一步候选：只读排查见 `send_online_action` 对 chat 也写入共用的等待确认／重试槽，`online_response_matches_current_action` 又按最近的 requestId 匹配；优先在现有 online protocol smoke 复现“聊天是否覆盖未确认的弃牌／响应及其 ACK／重试”后再判断缺陷。本轮未在全量验证中途改这条发送逻辑，也不将尚未复现的问题记成已修。

## 2026-10-08：联机聊天事务隔离与 TCP 缓冲排空

- 按上一批候选先复现：在现有 `TCPServer`／`StreamPeerTCP` 的真实本地 23333 端口夹具中，用碎片 JSON、生产发送入口和生产超时／重试路径确证聊天会覆盖未确认的弃牌、过牌及重试槽；修前 `build/qa/online_chat_ownership_before.log` 共 17 条失败。另用不执行新增聊天检查的基线探针独立复现原有 burst／后续消息 5 条失败，定位为收包预算后的完整缓冲帧在没有新 socket 字节时停止处理。
- 聊天现在用独立、最多 16 项的 requestId 关联表；仅在 TCP 写入成功后登记，记录 session／room，连接更换、断线和实际房间切换清理。同房普通快照与牌桌 ACK 不抹掉聊天关联；超限淘汰最旧项而非禁止继续聊天，原有 650ms 冷却保留。
- 合法聊天仍能与未确认弃牌／响应并行；空消息、冷却拒绝和聊天 ACK／error 不改牌桌 payload、等待状态、计时、反馈、重试或弃牌身份。孤立聊天不再创建牌桌等待，合法出牌仍可使用；真正牌桌重试仍发送原弃牌并换新 nonce，旧弃牌和延迟聊天回执不能完成新重试。
- 保留 requestId／request_id／actionId／action_id，以及 actionType／action_type／requestType／request_type 别名。乱序、重复、淘汰项、错 session 与矛盾类型回执不误确认牌桌；旧版无标识回执仅在可无歧义归属时兼容，聊天与牌桌同时待确认时显示提示并继续等待，不猜测归属。本批只验证仓库客户端和真实本地 TCP 夹具，不宣称未知外部服务器已完成兼容验收。
- `poll_online` 无新字节但已有缓冲时继续按每 poll 8 帧排空，保留分块读取、断线生命周期、帧大小限制与 180 秒超时。新增单次写入 11 帧后不再写入的排空断言，以及完整 1500 帧严格计数与最新 14 条日志检查；未缩减 burst 样本或放宽解析预算。
- 扩展真实协议测试最终 **102 条断言 PASS**。增加 19 条连续聊天的有限关联压力、乱序／重复／旧版／房间切换／断线／重连清理检查；扩展夹具曾留下测试房间导致原重连 3 条假失败，修正为恢复 QA180 后再进入重连，不据此修改生产恢复逻辑。一次失败的 patch 后 shell 继续生成的 `online_chat_ownership_after.log` 不是有效修后证据；实际成功证据以 `online_chat_ownership_fixed.log`、`online_chat_ownership_extended_pass.log` 及本批归档协议日志为准。
- 将真实 TCP 协议检查纳入完整 UI，门禁由历史 43 项增至 **44 项**，日志同时进入运行错误／资源泄漏扫描。每份 UI gate 日志写入 batch／源码指纹；持久 capture 校验器同步要求 44 项，并检查协议日志的批次、源码、时间、关键断言和正常结束。校验器正例通过，另实际拒绝错 batch、错源码、缺结束、失败断言、运行错误、缺 burst 断言和过期时间戳七类坏证据。

### 聊天与 TCP 修复的最终证据

- 完整 UI **44/44 PASS**，失败 0，批次 `20261008T170714Z-582e174-888c6b407887`；完整 AI **45/45 PASS**，失败 0，执行 45、缓存 0、模式 `fresh`，批次 `20261008T173959Z-582e174-888c6b407887`。当前 runtime 源码与两份报告同指纹 `888c6b4078871d3cc661e841664739d75ba728a41209480fed2abc9bdec36ae1`，组合会话正常退出 0。
- 持久校验器重新核对 **114 对 battle + 54 对 reading = 168 对 PNG/JSON**、本批真实 TCP 协议日志，以及 **45 份 fresh AI 日志**，全部通过；本批运行错误和资源泄漏扫描均通过。日志为 `build/qa/battle_reading_capture_manifest_validation_20261008T170714Z.log`，未混用上一批 d386 源码的绿色结果。
- 快照为 `build/qa/ui_regression_verification_report_20261008T170714Z_pass.md`、`build/qa/ai_play_commercial_evidence/EVIDENCE_20261008T173959Z_pass.md`、`build/qa/ai_play_commercial_evidence/STRENGTH_PACK_20261008T173959Z.json`；真实 TCP 日志另存 `build/qa/online_protocol_smoke_20261008T170714Z_pass.log`，runtime diff 保存于 `build/qa/runtime_source_diff_20261008T170714Z.patch`。组装／whitespace／shell 语法复核通过，完成后无 Godot／Xvfb 进程残留。
- paired 强度门禁 151 秒、独立 fixed-player 压力门禁 92 秒，样本、种子和 180 秒硬阈值未放宽；本批不改 AI 决策，不宣称 AI 强度或速度提升。无新增视觉资产、不改 2D 牌面、不回 3D，版本仍为 `1.0.180-godot`。
- 同一只读 UI 工程师仍未返回视觉结论，保留其阅读进度，F-916～F-920 不凭自动绿色关闭；真机触屏、中文输入法组成态与外部联机服务兼容仍待验收。整个 UI／AI 持续目标保持 active。

## 2026-10-08：可见 AI 协程的牌局归属与续局接管

- 上一目标轮是有效进展：联机聊天事务与 TCP 缓冲修复已完成同源码 UI／fresh AI 验证。本轮先从现有可见桌面 AI 的真实 `Timer`／`process_frame` 生命周期复现，不按绿色商业强度报告假定所有异步路径已经正确。
- 新增 `scripts/ai_play_round297_check.gd`：实际发牌、提交弃牌、过牌、重新发牌、恢复合法完整存档及菜单入口都走生产函数；只暂停／释放真实等待 Timer 来控制交错，不用替代 AI／摸切策略。修前 `build/qa/ai_play_round297_before.log` 确证 **6 条失败**，另出现同一 `process_frame` callable 重复连接错误：旧摸牌协程会改新局，旧玩家摸牌结束会清新协程的 active，菜单未立即释放归属，同 roundId 恢复会复活旧协程，旧队列回调会抢新任务。
- 为运行和排队任务加入单调 generation＋roundId 归属，重新发牌、进入／恢复单机、离开单机页面和 shutdown 取消旧归属。所有等待之后及下一次状态提交前核查归属，旧协程收尾只能释放自己的 generation；正常同局 redraw 不取消 AI，合法新工作仍执行摸切并交回玩家。
- 调度保存当前 callable，取消时主动断开尚未派发的 `process_frame` 连接；回调仍核查绑定的 generation／roundId，已经派发的旧 handle 也不能清新 queue／active。实际探针确认仅 `.bind` 不足以避免该信号重复连接，最终保留主动 disconnect 和入口归属检查，而非忽略 Godot 错误或等旧协程自然结束。
- 追加真实保存→菜单→`start_offline(true)` 恢复路径，又复现玩家 13 张待摸边界没有新工作接管（`ai_play_round297_human_resume_before.log` 1 条失败）。恢复调度条件现在同时包含 bot 回合及玩家仍待摸牌；旧工作取消后由新合法协程恰好摸一张、保留完整牌账并恢复可出牌的 14 张手牌。
- 新门禁最终 **46 条断言 PASS**，包括同 roundId 恢复、已派发旧 handle、正常 redraw／真实 AI 循环、真实存档续局和 shutdown；另 round52 杠后可见桌面自摸决策与 offline smoke 均退出 0。补充非 quiet 探针开启真实生产事件记录，每个初始夹具保留至少 53 条摸切／过牌事件，**56 条断言 PASS**，确证旧工作在真实记录开启时仍不能改变牌账、摸牌身份或重放序列，不只依赖 quiet 场景的空事件列表。
- 原型第一次修改在 base 中直接调用派生 helper 导致解析失败，随后按现有继承风格改为 `call` 并通过 check-only；该失败日志及下一次尚有重复连接的日志都不作为最终修后证据。实际修后证据为 `ai_play_round297_resume_fixed.log`、本批正式 round297 日志及非 quiet 补充日志。
- 真实协程用例接入完整 AI／玩法，历史 45 项增至 **46 项**；全部 fresh AI 日志新增 batch／runtime 指纹绑定。持久校验器同步要求 46 项、round297 门禁与归属／正常推进／玩家续局关键断言，并拒绝失败断言。明确的合成校验夹具正例通过，错 batch、错源码、缺结束、失败断言、缺续局断言、缓存证据、缺归属门禁及过期日志八类负例均被拒绝；该合成测试不冒充产品 AI 执行证据。
- **额外历史检查未修**：另行试跑旧 `ai_play_round24_check.gd` 仍有 8 条失败，直接自摸报告与同步模拟的前置检查就期待拒绝当前“危张自摸落袋”接受的牌形，不是仅可见协程失效。`ai_brain.gd.part` 的 binary diff 与上一 888 批 runtime 归档逐字一致，本轮未改该算法、放宽危险牌策略或修改此历史夹具以掩盖失败；它不在本批 46 项商业门禁内，失败日志为 `build/qa/ai_run_ownership_ai_play_round24_check.log`。

### 协程与续局修复的最终证据

- 完整 UI **44/44 PASS**，失败 0，批次 `20261008T181309Z-582e174-e228cd0a3aaa`；完整 AI **46/46 PASS**，失败 0，执行 46、缓存 0、模式 `fresh`，批次 `20261008T184556Z-582e174-e228cd0a3aaa`。两报告与当前 runtime 同指纹 `e228cd0a3aaaa31ab36b0b9307c42ae99dab14e22176f83fed9f44701fd1984d`，完整串行会话正常退出 0。
- 持久校验器重新核对 **168 对 PNG/JSON**、本批实际 TCP 协议门禁和 **46 份 fresh AI 日志**，全部通过；完整 UI 与 AI 错误／泄漏检查通过，非 quiet 补充探针也无运行错误或泄漏标记。最终校验日志为 `build/qa/battle_reading_capture_manifest_validation_20261008T181309Z.log`。
- 归档为 `build/qa/ui_regression_verification_report_20261008T181309Z_pass.md`、`build/qa/ai_play_commercial_evidence/EVIDENCE_20261008T184556Z_pass.md`、`build/qa/ai_play_commercial_evidence/STRENGTH_PACK_20261008T184556Z.json`、`build/qa/ai_play_round297_20261008T184556Z_pass.log` 与 `build/qa/runtime_source_diff_20261008T181309Z.patch`；新用例原文、非 quiet 探针原文和补充结果也保存为 `build/qa/ai_play_round297_fixture_20261008T184556Z.gd`、`build/qa/ai_run_real_event_probe_20261008T184556Z.gd`、`build/qa/ai_run_real_event_probe_20261008T184556Z_pass.log`。
- paired 强度门禁 152 秒、独立 fixed-player 压力门禁 92 秒；paired／fixed 的全部 aggregate 与上一 888 批完全一致，种子、每难度样本及 180 秒硬阈值未放宽。本批改善异步运行与续局正确性，不宣称战略强度或速度提升；版本保持 `1.0.180-godot`，无新增视觉资产、不改 2D 牌面、不回 3D。
- 组装、whitespace、shell 语法及最终源码指纹复核通过，无 Godot／Xvfb／批量生图任务残留。同一只读 UI 审计本轮观察超时不是结束，保留其 handle 与阅读进度；F-916～F-920 未据自动门禁关闭，真机触屏／中文输入法组成态和外部服务兼容仍待验收。整个 UI／AI 持续目标保持 active。

## 2026-10-08：真人出牌与原生手牌控件的异步归属

- 用真实 `start_new_offline_match()` 发牌、完整实体牌账、非 quiet 生产重放事件、原生 `Button.pressed` 和真实下一帧信号复现四个问题：快速重开后不同牌的 resolver 丢失并卡在 resolving；已派发的同面旧 resolver 裁定新局；旧原生手牌按钮切走新局手牌；点击第二张同面牌却移除第一张实体 serial。修前日志 `build/qa/offline_input_lifecycle_before.log` 实际退出 1，四条失败并含两条 `process_frame` 重复连接错误。
- 真人 resolver 保存专属 callable，成功出牌递增 action sequence 并绑定 generation／roundId／sequence；重新发牌、离开单机和 shutdown 主动断开未派发连接。入口核查四项归属，旧已派发 handle 不得消费新回调槽；合法同局 redraw 不取消出牌裁定，已消费 handle 不能二次裁定或扰动 AI 接力。保留 disconnect，不能只靠 `.bind` 回避 Godot 的重复连接约束。
- 原生手牌回调与托盘复用键共同采用实体手牌 fingerprint＋mode，单机额外包含 generation／roundId／action sequence。恢复同 roundId、相同面牌与相同实体序列仍使旧按钮失效；普通同手牌 redraw 保留合法操作。按索引出牌把准确索引传入 `commit_discard`，错面／越界索引拒绝提交，不退回找第一张同面牌；旧按牌值调用保持原语义。
- 新持久 smoke `scripts/ui_offline_input_lifecycle_smoke_test.gd` 扩展至 **61 条断言 PASS**、实际退出 0，日志 `build/qa/offline_input_lifecycle_extended.log`。覆盖四条修前失败、真实 AI／合法过牌后的同局同面第二意图、正常 redraw／重复提交、同 roundId 恢复、实体 serial、完整牌账／真实事件、菜单及 shutdown。重点 `ai_play_round297_check.gd` 46 条断言与 `offline_smoke_test.gd` 也实际退出 0，无错误／泄漏标记。
- 新 smoke 接入完整 UI（历史 44 项增至 **45 项**）以及错误／资源泄漏扫描；AI 仍为 **46 项**。持久校验器要求新 UI gate 的本批 batch、当前 runtime 指纹、时间、开始／成功结束标记和 18 条关键断言，不用独立旧绿日志替代完整报告。隔离校验夹具的正例与 12 类负例检查通过：错 gate／batch／源码、缺开始／结束、失败断言两种格式、缺实体身份／正常推进断言、运行错误、泄漏及旧日志均被拒绝；这是校验器自检，不冒充产品 QA 批次。

### 真人输入修复的最终证据

- 完整 UI **45/45 PASS**，失败 0，批次 `20261008T193447Z-582e174-5870d7875c41`；完整 AI **46/46 PASS**，失败 0，执行 46、缓存 0、模式 `fresh`，批次 `20261008T200754Z-582e174-5870d7875c41`。两报告均绑定 runtime 指纹 `5870d7875c41d512a860d941355520fdef5bf58bd53b5da1ff23616ed3c879a0`，完整 UI→AI→持久校验的同一串行会话实际退出 0。上一 e228 批证据仅作历史基线，不代替本批新 runtime 的验证。
- 持久校验重新核对 **168 对 PNG/JSON**（114 对对战、54 对规则／大厅阅读）、本批 TCP 102 条断言、真人输入 61 条断言及全部 46 份 fresh AI 日志。真实异步 AI 归属门禁另有 46 条断言；完整错误／泄漏扫描通过，三种分辨率的输入安全、无障碍和页面截图／manifest 均通过。完整校验归档为 `build/qa/offline_input_capture_validation_20261008T193447Z_pass.log`。
- 报告归档为 `build/qa/ui_regression_verification_report_20261008T193447Z_pass.md`、`build/qa/ai_play_commercial_evidence/EVIDENCE_20261008T200754Z_pass.md`，runtime patch 为 `build/qa/runtime_source_diff_20261008T193447Z.patch`。真人 smoke 原文、正式结果与持久校验器原文分别归档到 `build/qa/ui_offline_input_lifecycle_fixture_20261008T193447Z.gd`、`build/qa/ui_offline_input_lifecycle_20261008T193447Z_pass.log` 和 `build/qa/capture_manifest_validator_20261008T193447Z.py`。
- 强度数据归档为 `build/qa/ai_play_commercial_evidence/STRENGTH_PACK_20261008T200754Z.json`。paired／fixed 两份 aggregate 与上一 e228 批逐项一致，全部非耗时字段（包括 fixed／shuffled 行）完全一致，种子、每难度样本、paired 输入与 180 秒硬阈值未放宽。独立 normal-seat0 压力探针的 aggregate 和全部 8 个种子遥测行也逐字一致（忽略实际耗时），仍为每难度 16 手；对比证据为 `build/qa/offline_input_strength_comparison_20261008T200754Z_pass.log`，新旧 round68／89 正式日志都另存，防止后续 fresh 覆写丢失基线。
- paired 强度门禁实际 152 秒、独立压力门禁 92 秒；`ai_brain.gd.part` 的 binary diff 与上一 e228 批逐字一致。本批改善真人输入、实体身份和异步运行正确性，不宣称算法强度或速度提升；版本保持 `1.0.180-godot`，不新增视觉资产、不改牌面、不回 3D。本轮未修补或重跑已记录的旧 round24 八条历史策略预期失败，不将 46 项商业绿门禁扩写成“仓库所有测试通过”。
- 全批期间 runtime 保持冻结，组装／whitespace／shell 语法和最终指纹复核通过，无 Godot／Xvfb／批量生图进程残留。独立 UI 审计仍使用原有 handle，F-916～F-920 未据自动门禁关闭；真机触屏／中文输入法组成态、外部服务兼容及独立视觉签收仍待验收，整个 UI／AI 持续目标保持 active。

## 2026-10-08：危险确认与响应按钮的实体／意图所有权

- 在上一批真人出牌修复后继续追踪确认路径，实际复现 **8 条失败**：选中第二张同面实体后，确认按钮按牌值回找第一张，第一次确认另开意图、第二次误切另一实体；旧取消／确认控制能影响同手牌同面牌重新打开的危险意图；旧确认能在新局提交；保存→菜单→恢复相同 roundId 的真实响应窗口后，旧原生“过”及已派发 callable 仍能回答该窗口。修前完整日志 `build/qa/offline_native_action_before.log` 退出 1，八条失败无运行错误，修前夹具另存 `build/qa/offline_native_action_before_fixture.gd`。
- 危险提示仅注入可重复的高／低风险建议以验证 UI 授权路径，不冒充真实战略威胁评估；仍由生产重开发牌、实际 `human_discard` 进入确认、原生按钮提交，完整真实实体牌账始终保留。响应窗口则由真实 AI 摸切／实际定时器／生产 claim 裁定打开，不拼造 pending dict 或墙牌；同 roundId 恢复使用被生产验证器接受的真实保存 payload，并保留非 quiet 事件序列。
- 确认按钮改走 `confirm_pending_danger_discard()`，只提交待确认的准确索引／面牌，不回退为按牌值寻找第一张。普通按牌值推荐／安全替代调用保留原语义；合法确认一次即切选中实体，重复按钮不能再消费另一张副本。
- 单机动作按钮绑定统一输入归属（实体手牌／generation／roundId／真人序号、phase／seat／待摸状态、claim sequence、危险意图 sequence、待确认索引／面牌、辅助／重开状态），先核查归属和 shutdown 再调用原生产方法。普通弃牌响应、抢杠响应及真实 pending 恢复产生新 claim sequence；危险窗口重新打开产生新 danger sequence，不把同局同面同手牌当同一授权。动作栏保留键同步使用同一输入归属，防止直接恢复相同手牌时旧 bar 被保留却携带过期 callback，造成新合法按钮失效。
- 扩展原持久 lifecycle gate 至 **137 条断言 PASS**，实际退出 0，日志 `build/qa/offline_native_action_extended.log`；原八条失败已全部通过。新增正例验证同窗口 redraw／当前过牌／重复过牌／真实同局下一窗口、当前取消／安全替代、直接相同手牌恢复后的新推荐按钮，以及到期原生动作仍按自动过规则处理。首版运行因继承字段的 `index` 缺显式类型解析失败，该日志单独保留为 `build/qa/offline_native_action_initial_parse.log`，不计作修后证据；补明确类型后 main 与扩展 fixture check-only 均通过。
- 仍使用原第 45 个 UI gate，不虚增 gate 项数；持久校验器关键断言从历史 18 项扩展为 **38 项**。隔离自检的 1 个正例和 18 个负例通过，除了源码／batch／时间／完整性／错误／泄漏，还拒绝缺实体授权、旧响应归属、正常过牌、同局新窗口、到期规则或缓存重建断言的日志，并拒绝历史 61／106 断言绿日志充当新覆盖；证据为 `build/qa/native_action_validator_selfcheck.log`。这仍是校验器自检，不冒充完整产品 QA。

### 动作归属修复的最终证据

- 完整 UI **45/45 PASS**，失败 0，批次 `20261008T204558Z-582e174-878765a0014b`；完整 AI **46/46 PASS**，失败 0，执行 46、缓存 0、模式 `fresh`，批次 `20261008T211952Z-582e174-878765a0014b`。两个报告与全部捕获均绑定冻结 runtime `878765a0014b1bb45c5e901306d19a443bd44ceff1fc272e963ce0ffd3262112`，完整 UI→AI→持久校验的同一串行会话退出 0，不引用上一 5870 批绿报告充当本批新源码证明。
- 正式 lifecycle gate **137 条断言通过**，TCP gate 102 条、异步 AI round297 46 条断言通过；本批 46 份 fresh AI 日志及 **168 对 PNG/JSON**（114 对对战、54 对规则／大厅阅读）重新核验通过。三分辨率焦点／模态／破坏性操作输入、无障碍、页面截图与 manifest 全部通过，完整运行错误／资源泄漏扫描通过；完整核验归档为 `build/qa/native_action_capture_validation_20261008T204558Z_pass.log`。
- UI 与 AI 报告归档为 `build/qa/ui_regression_verification_report_20261008T204558Z_pass.md`、`build/qa/ai_play_commercial_evidence/EVIDENCE_20261008T211952Z_pass.md`，runtime diff 为 `build/qa/runtime_source_diff_20261008T204558Z.patch`。正式真人输入结果、fixture、父级 userdata snapshot fixture 与持久校验器分别存为 `build/qa/ui_offline_input_lifecycle_20261008T204558Z_pass.log`、`build/qa/ui_offline_input_lifecycle_fixture_20261008T204558Z.gd`、`build/qa/ui_interaction_fixture_20261008T204558Z.gd`、`build/qa/capture_manifest_validator_20261008T204558Z.py`；隔离负例校验也另存同批日志。
- paired 强度门禁实际 151 秒、独立 fixed-player 压力门禁 92 秒，均在原 180 秒预算内；`STRENGTH_PACK_20261008T211952Z.json` 的 paired／fixed aggregate、全部 fixed／shuffled 非耗时 payload、种子、每难度样本与 paired 输入同上一 5870 批逐项一致。独立 normal-seat0 探针的 aggregate 和 8 个种子遥测行也相同（忽略实际耗时），仍为每难度 16 手。对比归档为 `build/qa/native_action_strength_comparison_20261008T211952Z_pass.log`；round68／89／297 新正式日志都另存，不依赖后续会覆盖的 latest。
- `ai_brain.gd.part` binary diff 与上一 5870 批逐字一致，未放宽任何强度或安全阈值，也不宣称 AI 强度／速度提升。本批修复真实操作归属、确认实体身份及稳定接力；版本保持 `1.0.180-godot`，无新增视觉资产、不改 2D 牌面、不回 3D。旧 round24 八条历史策略预期失败本轮未重跑／未修补，不把本批商业门禁全绿宣称成仓库全部测试通过。
- 冻结期未改 runtime，最终组装／shell 语法／whitespace 与指纹／归档 patch 一致性复核通过，无 Godot／Xvfb／批量生图进程残留。同一 UI 审计 handle 在实际新阅读证据就绪后收到有界 F-916～F-920 复验任务，没有重启或另起审计；观察超时不当作终止，也不依据自动门禁关闭视觉 finding。独立视觉签收、真机触屏／中文输入法组成态、外部服务兼容仍待验收，整个 UI／AI 持续目标保持 active。

### 离线响应预检与裁定边界持久化（2026-10-08）

- 扩展真实发牌、完整牌账、生产 replay 与实际 AI timer 的原 lifecycle fixture，修前串行复现 **14 条失败断言**，进程退出 1，无运行错误；日志 `build/qa/claim_resolution_before.log`、fixture `build/qa/claim_resolution_before_fixture.gd` 保留，不用不可能的库存构造生产缺陷。
- 非法 `human_claim` 以前在验证选项／吃牌组合前就隐藏 response stack、禁用按钮并清理焦点／引导，牌桌未变化却让合法过牌失效。现改为先验证来源、已展示选项、吃牌参数形状及实际组合／抢杠胡资格，再失效当前控件并消费动作；到期点击仍先转为过牌，不改变既有超时契约。
- 真人弃牌已提交、下一帧裁定未执行时立即返回菜单，旧保存方法**明确跳过 resolving**，因此自然路径会丢失这次提交、续局回退或重新发牌；不是“原自然路径保存 resolving 后卡死”。与此同时直接 loader 接受 resolving payload 却不重新调度裁定。现允许通过完整牌账与来源验证的提交边界保存，恢复后绑定新 generation／roundId／sequence 的一次性裁定，旧 callable 不得消费新归属；真人提交也先分配序号再 render，避免重建原生按钮期间暴露旧输入授权。
- resolving payload 须认证四家范围内的座位、非空面牌及对应牌河末张；拒绝错误座位、未知／空面牌、另一家的空牌河或合法但不同的面牌，失败发生在覆盖现场或取消合法异步归属之前。保存验证缓存除 revision／规则外还比较深拷贝的完整状态，堵住同 revision 改库存复用旧有效结果的漏洞，并验证缓存的非法结果不污染随后合法的同 revision 恢复。
- 扩展 focused lifecycle **201 条断言 PASS**，退出 0，日志 `build/qa/claim_resolution_final.log`。新增真实机器人庄家 seat3 的保存／重复恢复／旧裁定拒绝／真人补摸，以及真实吃牌窗口的畸形参数拒绝／原生合法吃牌仍可用正例。首版 bot 正例把 Callable 本体不等当作绑定归属不同，出现一条 fixture 误报；隔离诊断证实旧／新绑定 generation 5／6、sequence 1／2、现场不变且合法补摸成功。现核对绑定参数与连接中的实际参数，而非 Callable 本体不等；原日志 `build/qa/claim_resolution_expanded.log` 与 `build/qa/claim_resolution_bot_diagnostic.log` 不计作通过证据。
- 仍扩展原第 45 个 UI gate；持久校验器必需断言从 **38 项增至 79 项**。隔离自检 1 个正例、91 个负例通过，逐条删除必需覆盖均拒绝，并拒绝旧 137／171 条绿日志、原 14 条失败、过期时间、批次／源码不符、错误或泄漏。日志 `build/qa/claim_resolution_validator_selfcheck.log` 与同名 `.py` 为合成校验器自检，不冒充产品完整 QA；上一 8787 批的历史绿色报告仍仅证明上一冻结源码。
- 针对性 round36 抓到本轮首版预检重排的真实抢杠过牌 fallthrough：完成补杠后未 return，会继续把 phase 写回 resolving；原后置 options 检查恰好挡住这条路径。现所有已消费的 pass 都显式返回，原 round36 不改预期重新通过，并在已有正式 round294 gate 增加 4 条未到期抢杠资格／过牌完成／一次补摸／重复消费拒绝契约断言；round294／36／65／297 均通过。扩展 round294 初版错误地将未类型化 Array 直接赋给 `Array[String]` 牌墙，GDScript 运行错误日志存为 `build/qa/claim_resolution_round294_initial_typed_fixture.log`，只终止确认属于本次命令的 Godot 进程；改用原牌墙 clear／append 后重跑通过，不将该中止运行算成成功。该小型规则契约 fixture 不宣称是真实发牌的完整牌账正例，真实库存与异步恢复另由 lifecycle gate 验证。

### 响应与裁定边界修复的最终证据

- 完整 UI **45/45 PASS**，失败 0，批次 `20261008T221021Z-582e174-99411400dae2`；完整 AI **46/46 PASS**，失败 0，执行 46、缓存 0、模式 `fresh`，批次 `20261008T224434Z-582e174-99411400dae2`。同一串行 UI→AI→持久核验会话退出 0，冻结 runtime 为 `99411400dae2c112c4a5b8073a02a79840c8adbd78156ea588055ae9123c520f`；源码和四个测试／校验 fixture 的运行前后 hash 完全一致，不用上一 8787 批绿色报告证明本批修改。
- 正式 lifecycle gate **201 条断言通过**，真实 TCP gate 102 条；正式 round294 **48 条**、异步 AI round297 **46 条**断言通过。新批次 46 份 fresh AI 日志及 **168 对当前 PNG/JSON**（114 对对战、54 对规则／大厅阅读）验证通过，三分辨率原生输入、无障碍、页面捕获、完整运行错误／泄漏扫描全部通过；核验归档 `build/qa/claim_resolution_capture_validation_20261008T221021Z_pass.log`。针对性 round36／65／297 分别 10／14／46 条通过，960 原生 input safety 50 条通过；不将历史全部测试或不可能库存 fixture 一并宣称全绿。
- UI／AI 报告归档为 `build/qa/ui_regression_verification_report_20261008T221021Z_pass.md`、`build/qa/ai_play_commercial_evidence/EVIDENCE_20261008T224434Z_pass.md`，runtime patch 为 `build/qa/runtime_source_diff_20261008T221021Z.patch`。**45 份 UI 与 46 份 AI gate 日志**另存不可变目录 `build/qa/claim_resolution_evidence_20261008T221021Z/`；正式 lifecycle、两份真人输入／userdata fixture、round294 fixture、79 项持久校验器与自检日志均有同批带日期快照。归档 SHA256SUMS 全部复核通过，日志 `build/qa/claim_resolution_archive_checksums_20261008T221021Z_pass.log`。
- paired 强度门禁实际 **152 秒**、独立 fixed-player 压力门禁 **92 秒**，均在原 180 秒单进程预算内；`STRENGTH_PACK_20261008T224434Z.json` 的 paired／fixed aggregate、完整 fixed／shuffled 非耗时 payload、种子／配对输入与上一 211952 批逐项相同。独立 fixed-seat0 aggregate、固定玩家遥测和全部 8 个种子行也完全相同（仅忽略实际耗时）；round68／89／294／297 正式日志均另存，完整比较 `build/qa/claim_resolution_strength_comparison_20261008T224434Z_pass.log`。`ai_brain.gd.part` binary diff 与上一 runtime 逐字一致，未改 AI 策略或放宽强度／安全阈值，不宣称强度／速度提升。
- 本批 960 默认与大字高对比阅读证据生成并验证实际 batch／fingerprint 后，已通知同一审计 handle 做有界 F-916～F-920 复验；未重启或新建审计，禁止其开重型任务或改产品代码。观察仍超时、没有新 terminal 报告，`AUDIT_LATEST.md` 尚为 2026-10-07 23:52:54 UTC，因此这些视觉 finding **继续待独立签收**，不以自动绿色门禁关闭。版本保持 `1.0.180-godot`，无新增视觉资产、不重绘／调色 2D tiles、不回 3D；真机触屏／中文输入法组成态与外部服务兼容仍待验收，整个 UI／AI 持续目标保持 active。

### AI 候选舍张：实体库存与自舍听口（2026-10-08）

- 上一目标轮是有效进展：离线响应／恢复边界修复以 994114 runtime 完成 UI45／fresh AI46／168 对阅读证据核验。本轮不把这些绿色报告当作 AI 所有估值都准确的证明；从当前源码的 hypothetical hand／公开牌快照边界继续检查，旧 round24 的不可能库存预期不用于调弱安全策略。
- `build_ai_discard_report` 原先将候选牌从手牌移除，却仍使用提交前的牌河计数计算剩余有效张；这一枚实体牌因此被当成未知牌重新计入进张。四枚已经全部自知／公开时也会出现一枚“幽灵听张”。同一个候选的 wait quality 还没有把未来舍张纳入自己的弃牌记录，遗漏已有自舍听口折损，影响 AI 排序及玩家建议显示。
- 新增 `scripts/ai_play_round298_check.gd`，控制分配真实完整规则牌墙的每枚牌，给四家合法手牌／必要花牌并保留全部余牌，不伪造几十张相同牌。修前在闭门／副露、quiet／visible、0／1／2 枚已公开同面牌的组合中复现 **46 条真实失败**，日志 `build/qa/candidate_inventory_verified_before.log`、fixture `build/qa/candidate_inventory_before_fixture.gd` 保留。首版 54 条失败中另有 8 条过严地要求派生缓存也不变，已按现有 context 可缓存契约改为检查现场、可见／自知计数及自己牌河输入；这 8 条不是新增产品缺陷。
- 修复仅投影真正从 original counts 移入牌河的一张候选：进张扫描使用独立复制并加一的 visible vector 和相应 cache key，两个扫描入口（正常估值及 hard 二向听保护）共用；点炮／喂副露仍用提交前信息，风险和强度阈值不变。自舍听口 lookup 也复制后加入该候选，不污染兄弟候选／live context。已经提交的诊断 original==simulated 不再次加一，避免重复扣减实际牌河副本。
- 扩展定向 fixture **133 条断言 PASS**，退出 0，日志 `build/qa/candidate_inventory_final.log`；覆盖已有 pre-discard 缓存显式预热、投影与非投影 cache 隔离、所有 retained 候选的完整实体剩余数量、真实 `commit_discard` 前后独立测量相等、自舍折损、风险边界不变与暗牌／牌墙交换不影响等待估值。首版修后 fixture 误要求 quiet Top-K 永远保留某张合法候选，出现 2 条测试假设失败；现不扩大候选或改策略，只要求所有保留候选库存正确，以及未剪枝的 visible 与小手牌 open quiet 保留该面牌。新 fixture 继承既有 userdata snapshot／restore，避免非静默覆盖玩家文件。
- round88／117／290／292／96／268 针对性回归全部通过；round292 原真实种子 step22 仍选更安全的 5W，不删除旧策略期望。新实体库存 gate 接入商业 AI，第47项；持久证据默认要求 AI47，round298 除成功标记外必需保留 **23 项关键断言**。完整产品 QA 尚需以本轮新冻结指纹重新执行，不引用上一994114批的绿报告。

### 候选库存修复的最终证据

- 完整 UI **45/45 PASS**，失败 0，批次 `20261008T230618Z-582e174-eeb1073a3b42`；完整 AI **47/47 PASS**，失败 0，执行 47、缓存 0、模式 `fresh`，批次 `20261008T234028Z-582e174-eeb1073a3b42`。同一串行 UI→AI→持久验证会话退出 0，冻结 runtime 为 `eeb1073a3b42a10928f28ad5377ebb425df7393c0c7f87d9e1ee615b03b6fdcd`；运行前后 runtime 与六份 fixture／wrapper／validator hash 一致，不能用上一994114批绿色报告替代本批证明。
- 正式 round298 **133 条断言**、lifecycle **201 条**、TCP **102 条**、round294 **48 条**、round297 **46 条**全部通过。47 份 fresh AI 日志及 **168 对当前 PNG/JSON**（114 对对战、54 对规则／大厅阅读）验证通过，三分辨率阅读／输入／无障碍／页面捕获及完整运行错误与资源泄漏扫描通过；核验归档 `build/qa/candidate_inventory_capture_validation_20261008T230618Z_pass.log`。新增 gate 的隔离 validator 自检 **1 正例／38 负例**通过，逐条删除23项覆盖、旧46项报告、缺fresh执行／有缓存、旧125条不完整覆盖、源／batch／时间不符、错误或泄漏均拒绝；自检归档 `build/qa/candidate_inventory_validator_selfcheck_20261008T230618Z_pass.log`，不把合成自检计为产品47项门禁。
- UI／AI报告归档为 `build/qa/ui_regression_verification_report_20261008T230618Z_pass.md`、`build/qa/ai_play_commercial_evidence/EVIDENCE_20261008T234028Z_pass.md`，runtime patch 为 `build/qa/runtime_source_diff_20261008T230618Z.patch`。**45 份 UI 与47份 AI gate 日志**存为不可变目录 `build/qa/candidate_inventory_evidence_20261008T230618Z/`；同批 round298 fixture、lifecycle／userdata fixture、validator、round68／89／294／297／298 日志、完整强度 pack 与比较 JSON 均另存带日期快照。归档 checksum 全部通过，日志 `build/qa/candidate_inventory_archive_checksums_20261008T230618Z_pass.log`。
- paired 强度门禁 **153 秒**、独立 fixed-player 门禁 **96 秒**，均在原180秒单进程预算内，未放宽任何强度／风险阈值。修正估值会改变候选排序和真实决策，因此本批完整非耗时 payload **不再与上一批一致**：同样24手 paired 样本，hard 向固定玩家点炮4→3、easy 7→9，hard 总点炮9→9；hard 原始高危舍张381→391。独立8种子每难度16手样本的固定玩家赢手数easy/hard仍2/5，但总分差从-5600/+13600变为-4400/-3800；风险数据有升有降，不能据此宣称整体强度／速度提升。完整变化记录 `build/qa/candidate_inventory_strength_comparison_20261008T234028Z.json` 与同名前缀 `_pass.log`，保留完整 before／after seed遥测，不只挑选改善指标。
- 额外运行原 `scripts/verify_ai_soak.sh`：**14 独立种子、56手、37断言 PASS**，实际计算 **133091ms**，进程退出0，全部种子终局、实体牌账、分数守恒及配对输入通过；沿用8个百分点 aggregate容差与170秒内部／180秒外部预算，未改旧 soak fixture或放宽预期。旧2026-09-25最新证据运行前完整备份，不当作本源码证明。由于旧 soak wrapper 本身没有源码绑定字段，本轮在同一外层运行会话记录 frozen fingerprint、核对前后一致，并将产物／runner／fixture连同 `SOURCE_BINDING.json`、checksum独立归档为 `build/qa/candidate_inventory_long_soak_20261008T235111Z/`；这证明本批压力与稳定性覆盖，不构成与旧源码的强度或速度比较。
- 当前默认与大字高对比960图生成并核对真实batch／fingerprint后，已向同一审计handle发送非重启的证据更新；观察仍超时、没有terminal结论，`AUDIT_LATEST.md`仍为2026-10-07 23:52:54 UTC，F-916～F-920继续等待独立视觉签收，不凭绿色门禁关闭。当前环境无adb，未完成真机触屏／中文IME验收；外部服务兼容仍待验收。版本保持 `1.0.180-godot`，不改2D牌面、无新增视觉资源或程序装饰、不回3D，整个UI／AI目标保持active。

## 2026-10-09：吃碰后的未来库存、路线与番型预测

- 修复真实吃碰预演的三类状态遗漏：从暗手移入新副露的两张实体牌未计入未来公开库存，可能生成四枚见尽后的假听口；路线合并只看 live 副露，忽略即将形成的首副露；待牌计分沿用 live 副露，可能误保留门清或漏算一条龙／碰碰胡。新增独立 post-claim context，投影 consumed counts、meld indices、scoring melds 与 exposed count；点炮／喂牌风险继续保留提交前的 visible／known 信息，不修改 live 桌面或共享输入。拒绝从新副露之外移除牌或 consumed 总数不符的投影。
- 正常公开计分仍走原验证入口；新增可选的未来副露快照参与完整实体库存验证、门清／杠／一条龙／碰碰胡计算。未来一条龙分组绕开 live cache，避免污染真实副露缓存；空快照维持原 live 行为。路线 helper 也接受 supplied meld indices，不再仅凭 live meld count 决定是否合并或禁止七对／十三幺。
- 新 `scripts/ai_play_round299_check.gd` **131条断言 PASS**：7组完整实体牌账用例覆盖碰／吃死听、首碰改变路线、门清消失、规范化龙牌别名、未来一条龙及已有暗杠共存；真实 source discard→claim→forced discard 后独立测量等待库存、fan／points／quality／route，逐等待比较完整公开计分结果。另验证非法／第五枚快照、live cache 隔离、hidden hand／wall swap 公平性及原700ms静默轻量安全路径与数组不变性。round26／27／77／97／117／258／265／271／285／298针对性回归全部通过，没有放宽旧策略或源契约。
- 正式修前复现为 `build/qa/post_claim_verified_before.log`：27条失败中，15条是新增输出／快照契约，12条是已存在行为的库存／分数／路线对比失败，不能称为27个独立产品缺陷。最早 raw C/Z 夹具未归一化，造成不可能牌账，相关日志仅用于调试；正式修前及修后用例均先规范化，再从完整牌墙分配实体牌。修前有效夹具及日志独立保留在本轮证据目录。
- 新门禁接入现有商业 verifier 为第48项，持久验证默认要求 **AI48 fresh／cache0**；round299必须保留7种case、28条关键断言及4类各7次真实提交对比。隔离 validator 自检 **1正例／55负例 PASS**，包括删断言／case／重复覆盖、旧47项、非fresh／缓存、缺门禁、源／batch／revision／时间不符及错误／泄漏；这些合成自检不计入产品48项门禁。
- 冻结 runtime `5268802c5fa7918464e458b0453bb1792934883475e9af774aa0b1340a56f003`：串行完整 **UI45/45 PASS**，批次 `20261009T001427Z-582e174-5268802c5fa7`；完整 **AI48/48 PASS**，失败0、执行48、缓存0、模式fresh，批次 `20261009T004842Z-582e174-5268802c5fa7`。同一会话退出0，前后 runtime及8份fixture／wrapper／validator hash一致；正式round299为131条、round298为133条、lifecycle为201条、round294为48条、round297为46条断言。当前 **168对PNG/JSON** 源／batch／状态验证通过，并与45份UI／48份AI日志、报告、fixture、validator、runtime patch一起保存在 `build/qa/post_claim_evidence_20261009T001427Z/`，完整归档checksum通过，不用上一eeb107批绿色报告替代本轮证据。
- paired强度门禁153秒、独立fixed-player门禁95秒，保持原180秒单进程预算和全部风险阈值。与 `20261008T234028Z-582e174-eeb1073a3b42` 基线相比，完整非耗时strength payload、paired／fixed aggregate及独立8种子遥测均完全一致；quiet仍走轻量安全评估。本轮证明前台吃碰预测正确性与原强度样本稳定，不宣称普遍强度或速度提升。完整比较为 `build/qa/post_claim_strength_comparison_20261009T004842Z.json`，含完整before／after遥测。
- 额外运行未修改的long soak：**14独立种子／56手／37断言 PASS**，实际计算133693ms，退出0，终局／实体牌账／分数守恒／paired输入均通过，保持8个百分点aggregate容差及170秒内部／180秒外部预算。旧latest产物先保存为previous reference，本轮源码前后hash及原fixture hash一致，独立 `soak/SOURCE_BINDING.json` 绑定当前runtime；产物与runner保存在同一证据目录的 `soak/`，不当作旧／新强度或速度对比。
- 960默认／large contrast真实源绑定图产生后，已向同一UI审计handle发送非重启证据更新；本轮观察仍10秒超时、无terminal findings，`AUDIT_LATEST.md`仍为2026-10-07 23:52:54 UTC。F-916～F-920继续待独立视觉签收；无adb，真机触屏／中文IME和外部服务兼容仍未验收。本轮无视觉资产／布局改动，不改2D牌面、不程序画图、不回3D，版本保持 `1.0.180-godot`，整个UI／AI目标保持active。

## 2026-10-13：国风首页与设置纸面统一

- 用户本轮优先目标改为国风游戏 UI。本次聚焦首页／设置，不扩展 AI 强度研究，也不以局部页面改善宣布整个游戏完成。保留之前全部工作树变更，版本仍为 `1.0.180-godot`。
- 先收尾上轮振听夹具：十三幺西风使用规范牌码 `R`，不是 `W`；补顾问紧凑提示与详情的整手仅自摸说明。round300／298／299 在 `build/qa/wait_wide_furiten/focused/` 分别通过 212／133／131 条断言。这些针对性结果不代表当前完整 AI48 门禁或强度验收；round300 尚未接入商业 AI wrapper。
- 已授权 GPT 生图接口返回 HTTP 401，没有产出新图，也未切换供应商或用程序纹理代替。保留两份未执行成功的提示词草案。本次复用仓库既有月夜园林／墨色细框两张位图，归档 `.gdignore` 会阻止直接导入，因此逐字节复制到 active illustrations 路径；原图与副本 SHA-256 相同。来源、用途及失败边界见 `assets/illustrations/GUOFENG_HOME_ASSET_PROVENANCE.md`。
- 首页以月洞窗、月色园林和原生象牙白标题建立国风场景；主动作明确为「入席开局／单机对局 · 三家陪练」，使用独有深墨卡面，其余入口使用整张宣纸。删卡片黄文字垫、顶／底粗条、重复舞台层和页脚伪进度条；原有开局、联机、商店、教学、快捷入口及设置回调保留。教学入口移到右上露出月亮，进行中教学横幅移到标题右侧，继续／跳过各有完整独立目标，不靠缩小字体解决窄屏相交。
- 设置保留一张完整不透明纸面与单一模态遮罩；移除 console 外轨、角块、section 厚框、行内双黄垫、开关锁及试听／切歌／重置／关闭的装饰轨道。十三行原生操作、地方规则、分区导航、大字滚动及重置二次确认保留；已开／已关和当前分区由原生文字与整张墨／纸位图表达。局部更新同步位图状态并保留焦点，不修改全局其它页面按钮材质。
- 目视中间批次发现真实高对比缺陷：教学标题／进度、设置 header 继承浅色而在纸面上低对比，大字 active tab 截断，窄屏规则按钮最小宽挤到关闭目标。已显式恢复深墨文字，大字 tab 用完整「当前声音」，规则 selector 缩减多余最小宽但保留 44px 高目标。真实开关操作的提示 toast 曾污染之后的教学截图；测试改为先保存所有静态状态证据，再验证真实鼠标／键盘切换，不隐藏产品通知。旧 `28ded` 图与中断日志保存在 `intermediate_28ded/`，不当作最终绿色证据。
- 新 `scripts/ui_guofeng_home_smoke_test.gd` 检查真实首页／设置输入、焦点恢复、13 行目标、单层材质、可读文字、教学不相交及大字末端重置可达。完整 UI wrapper 新增六档合并门禁，计数由45增至46，额外生成27对 PNG／JSON；validator 默认同步46，并核对全部六次执行、批次／源码、菜单主次和教学对比等状态。metadata validator 隔离自检为5正例／13负例通过，不计入产品门禁。
- 首次全量冻结 runtime：`e36c86008ebcffc4b9af0dcb73713357cfa53a590e427693b11c40910917daac`。完整 wrapper 实际完成 **42/46，FAIL**：离线旧断言仍要求已经删掉的设置 cast shadow／reset ornament；1280与960重置截图 fixture 仍从已删的确认装饰读取 scope；错误扫描发现上述离线失败。1920截图在 fixture 更新后执行并通过。这4个门禁失败不是4个独立产品漏洞，也不把整体改写为 PASS；报告、日志和当时 runtime 保存于 `e36_full_qa_failed/`。实际流程遵守单线程、nice10／ionice低优先级及180秒单进程硬超时；无并发 Godot／Xvfb／生图／批量导入。
- 完整回归使用隔离 `XDG_DATA_HOME` 并复制既有 pre-QA cfg 作为存档前置条件，避免继续读写个人配置。首次完全空 userdata 只在既有回放非空行／滚动断言失败，保留于 `empty_userdata_precondition/`，不改无关产品代码或降低断言来绕过；该前置缺陷仍未修复。本轮原用户 cfg 在隔离回归期间逐文件比较未变。
- 一次 e36 完整回归的终端会话收到终止信号、退出143，没有生成新版完整报告；具体信号来源未确认，不能称为完整 PASS。该次已通过的27对首页／设置图及中断日志保存于 `interrupted_e36/`，同源码视觉审计可用，不能替代完整门禁。之后使用一个独立会话的串行 runner 重新执行原 wrapper，所有 Godot 单进程仍保留180秒硬超时，不并发另一份 QA。
- 主 agent 还在 e36 的960默认设置 PNG 观察到本地进度状态疑似被截为「清空续局…」，未见第二行「保留战绩」；大字末端图两行可读。已经交同 handle 判定该具体视觉残留，不以 tooltip、源字符串或自动测试通过替代实际可见状态；当前不宣称这处已修或全部视觉签收。

### 2026-10-13：窄屏重置后果提示的实测修正

- 针对 e36 原生设置测量，960默认的重置状态有两行文字、每行字体高度18px，但标签实际高度只有30.24px；这是可见裁切，不是 tooltip 缺失。保持13px字号，调整该行的文字／动作宽度分配，将后果完整显示为一行「清空续局·保留战绩」。重置动作约68×52px，仍满足44px目标且四字「确认清空」完整；大字模式保留原有两行与滚动。第一下键盘操作只进入 armed 状态，关闭设置取消，不提交清空；局部刷新沿用完整单行后果，不把它改回高度不足的两行。
- 更新相关旧视觉 fixture，不补空节点或扩大既有 suppression：离线断言直接验证纸面源纹理、无 console 子层、原生 reset face 与二次确认语义；截图 fixture 的 scope／armed／second-click 条件来自真实原生按钮 metadata，required nodes 改为真实操作与状态标签，不再依赖装饰 `ResetProgressConfirmArt`。布局断言另外测量完整状态文本、68px动作中文字宽与44px高度，比旧32px高条件更明确。
- 新冻结 runtime：`0d5b3e357dcd3f688556727efa912351fed919d73f988353258b5cdff46e721b`。证据目录 `build/qa/guofeng_home_20261013/final_revision/`，新960设置 PNG 已目视确认整句显示；当前源码的13项串行针对性验证全部通过，`focused.exit=0`，最后一项960真实交互也已通过。六档首页／设置共有497条显式OK断言，960输入安全50条、真实交互383条，合计930条；布局和离线脚本通过但不输出逐条OK计数，不将其虚构加入930。旧全量42/46报告不是这个最终 runtime 的全面证明；本轮不宣称新版完整46项已重跑通过。
- 完成最终元数据复核：27对首页／设置PNG与JSON、3张重置armed截图的批次、尺寸与runtime fingerprint一致；首页状态调用既有`validate_home_state()`验证。冻结源码／资源校验和、assemble parity、`git diff --check`均通过，当前根目录日志未检出运行时错误或泄漏。隔离QA结束后，再次逐字节比较原root用户12份cfg，均与本次QA前快照一致；此结论仅覆盖快照以来，不扩展为此前整轮都未读写个人存档。汇总见`build/qa/guofeng_home_20261013/FINAL_VERIFICATION.md`。
- 独立只读审计继续复用同 handle，报告为 `build/qa/ui_engineer/AUDIT_GUOFENG_HOME_20261013.md`；原 `AUDIT_LATEST.md` 与 F-916～F-920 不覆盖、不冒充新签收。对战／商店等其它页面尚未做本轮国风统一，真机触屏／IME／外部兼容仍未验收；整个国风游戏目标保持 active。

## 2026-10-13 国风第二阶段：宝阁宣纸陈列与原生购买

- 先以首页完成后的源码重新截取1280对战、极限桌面、副露响应及旧商店，证据位于`build/qa/guofeng_battle_shop_20261013/before_1280/`；这些是修改前基线，不冒充新的国风对战。对战只读审计交给原Spectate handle，本阶段主agent先实现商店。
- 商店改用同首页的既有月夜背景，前景是一张`settings_readable_gpt`宣纸；四商品每行只铺一张`menu_card_readable_gpt`，保留已有道具位图和原生名字／说明／分类／持有数量。移除厚cabinet／plinth／外轨、重复文字垫、货币及库存伪meter和交易示意轨道。可购买动作深墨、玉符不足动作宣纸，显示准确不足数和未接充值的真实解释，没有新生图或程序视觉替代。
- 新六档定向测试直接使用鼠标／触摸／Enter购买同一真实道具，核对每次只扣5玉符、库存只增1、铜钱不变、经济存档相同、重绘后同商品焦点，以及禁用购买、获取说明、End／Home／PageDown／触摸拖动原生滚动。测试发现原`restore_shop_scroll_state`的else缩进使仍可购买的商品不恢复焦点，已修正；加宽购买lane使两位价格及大字模式不裁切。
- 旧layout／offline的商店装饰断言按真实纸面、库存、价格与操作状态更新，保留命中、行间距、滚动、文字边界与购买语义测试；没有扩大旧视觉suppression或添加兼容空节点。首个15项runner在layout通过后由offline指出尚未同步的旧纸面／阴影断言，以及已移除引用但仍留在源码中的旧装饰helper；失败证据保留在`shop_final_failed_7553bb1d050c/`。已删除四个无调用的旧商店装饰helper，修正剩余断言而非弱化named-node引用门禁。
- 独立`ui-engineer`审计指出960大字通知遮盖余额、CTA fit抵消大字、焦点视觉过弱。按finding修复：购买字号使用accessibility后的preferred与至少12px＋大字增量的floor；返回／购买／获取按钮使用唯一native `›`焦点标记；商店通知移至真实页脚说明lane，以原生文字替换说明，保留通知队列、原有dwell和cleanup／dismiss后原说明恢复，重绘也不叠字。额外保存`shop_recovery`通知证据，最终每档4态，共24对商店PNG／JSON。
- revision4的960长获取说明测试发现页脚高度仍略不足，保留失败日志与截图后调整页脚内部标题／说明留白，不缩小文字或放宽包围断言。revision5的960与1920大字高对比均113条显式OK通过，真实通知不再遮标题、余额、返回或商品。metadata验证器自检4个有效状态／52个无效变体全部符合预期；这是验证器单测数量，不是产品gate数量。
- 新商店六档合为完整UI门禁一项，当前配置47项，metadata verifier同步核对24对商店截图、余额／库存变更、唯一焦点标记和获取／购买通知生命周期。旧42／46失败报告保持原样，未宣称新完整47项已经通过。
- 当前冻结runtime为`eb938bac38a205574b7f1cd24eea56eec30f619218831b3e36ed2d620d99b3d4`，最终15项串行验证全部通过（layout、offline、商店六档、首页／设置六档、960真实交互），`shop_final/focused.exit=0`。商店6×113=678条显式OK，首页／设置497条、真实交互383条，共1558条；layout／offline未输出逐条OK计数。24对商店＋27对首页／设置PNG／JSON均通过状态、批次、尺寸及源码fingerprint复核；冻源／素材校验和、静态bitmap／shape策略、assemble parity与whitespace均通过，最终日志无错误／泄漏，原root用户12份cfg与既有快照一致。汇总为`build/qa/guofeng_battle_shop_20261013/VERIFICATION.md`，不把15项定向验证写成完整47项通过。
- 独立商店审计为新`ui-engineer`handle；报告已在相同runtime的revision5 960／1920大字两档将F-001～F-003全部closed，局部remaining阻塞0，最终shop_final六档视觉复核待追加。旧首页最终审计未交付即结束委派，不虚构签收；原全局`AUDIT_LATEST.md`保持历史范围。
- 对战仍待审计及国风减层；其原有2D牌面与上下横／左右竖朝桌心副露布局不变。整局游戏、真机触屏／IME与完整47项QA尚未验收，整体目标保持active。

### 2026-10-13 国风对战阅读区：宣纸顶部／记录与深墨中央

- 本阶段统一顶部HUD、中央事实与左上牌桌记录；复用既有宣纸／深墨位图，去掉厚阴影、重复文字底垫、手数伪进度与重复墙计数，不修改原2D牌面／牌河／副露几何，版本仍为1.0.180-godot。
- 修复旧注册契约覆盖深字样式、大字拟合回退默认字号、历史每行误取最后事件类型，以及HUD-only变化时中央墙状态／tooltip不跟随墙数的真实问题；顶部原生按钮保留回调与命中范围，聚焦浅字墨面、失焦深字纸面。
- 独立UI复核仅对revision5的960大字高对比三张图提出F-001（深墨焦点面仍用深绿图标与箭头）；主agent按该finding修复，agent随后复核当前冻结的healthy／keyboard两图，将F-001 closed、限定视觉问题remaining 0；未独立运行输入测试或量化3:1，不把局部审计扩大为六档或整局签收。
- 新对战六档定向脚本接入完整UI门禁，当前配置48项；metadata validator默认48并核验54对对战状态。旧完整42/46 FAIL报告保持原样，本阶段未运行完整48项。
- 当前冻结runtime为`dab061d68f61cd423eb7e84956f48f22bfdb7e11e4df8b18f75586b3be6a1b3e`；独立批次29项串行定向验证全部通过，`verified/focused.exit=0`。3727条显式OK包含新对战756、完整对战阅读870、首页／设置497、商店678、live HUD342、input lifecycle201、960真实交互383；layout／offline无逐条OK，不虚构计入。219对当前矩阵PNG／JSON通过源码／批次／版本／尺寸／辅助配置与状态核验；额外原生Enter／Escape及焦点配色往返9条OK、1对配对证据与3张正式预览通过，`verified/evidence.exit=0`，不混入29项计数，也不将共用metadata的3张预览算为3对JSON。冻源／素材与全部牌面校验、assemble parity、whitespace、语法与bitmap／shape策略通过，最终日志无错误／泄漏，原root用户12份cfg与既有快照一致。源码未变但被中断的`final/`批次和独立审计引用截图保留原位，不把中断结果改写为完整通过；全部证据与失败保留说明见`build/qa/guofeng_battle_20261013/VERIFICATION.md`。行动区、座位卡、大字手牌及其它页面未完成国风统一，整体目标保持active。


## 2026-10-13 · 国风操作按钮、响应阅读与侧家金额

- 关闭本轮限定审计的三个具体问题：多吃组合错误共用 C、响应提示叠字、侧家庄家金额丢失“万”。C 角标、tooltip 与 core finalize summary 均按真实 payload 归属；按钮改为仓库既有纸／墨位图与原生文字，保留输入 signature 和原动作回调。
- 当前冻结 runtime diff fingerprint：`ff8abc62f992330822308d0e4e2aebf1a3a2fbc91f479e9f548f6e941f765812`。本轮 18 个串行定向运行通过，2708 条显式 OK；layout / offline 不逐条打印，不虚计其数量。90 对配对截图通过身份／状态验证，另有 3 张共享 metadata 的比较 PNG。
- ui-engineer 仅复查两个 profile／四张图，原三项 finding 限定关闭，未签收全游戏。完整 wrapper 现配置 49 项但没有重跑；原 42/46 FAIL 的历史报告保留。容量 preview 的花牌契约与显示尚需核查，不用比较图冒充计数或牌守恒验收。
- 本轮不生图、不增资产、不改牌面、不改四家外框或牌河副露几何、版本不变。原用户 12 cfg 自本轮 snapshot 起一致。完整记录：`build/qa/guofeng_action_seats_20261013/VERIFICATION.md`；后续仍需统一 dock / timer、上下家／头像、手牌及剩余页面，再做完整 QA。

## 2026-10-13 · 国风行动底座、倒计时与四家卡

- 行动底座、意图条、独立倒计时与四家卡改为既有纸面位图承载原生事实文字，删除厚阴影、伪头像、重复轨道／脉冲与内层底垫；真实实例复用不再依赖阴影节点。整个响应窗口可见“到0自动过”，最后3秒原位更新、到0执行真实过牌并展示反馈；意图数量不再叠装饰徽章，自家“行牌”浅底深字。四家外框、牌河、副露、手牌几何与1.0.180-godot版本保持不变，无生图／新增资产／牌面修改或程序装饰。
- 截图 fixture 直接改事实后递增对应 revision 再走真实 render；保存前核对 raw 玩家事实、player-info 缓存与原生金额／手／花，修复容量预览旧金额／花数。新增 smoke 先暖旧缓存再改花8／金额，并检查真实倒计时和 seat / dock / intent reuse；容量视觉 fixture 不是实体牌守恒证明。
- 当前冻结 runtime diff fingerprint 为 `c8f87e5e12e209b1f0eb1bd5f843d759b17e012676507268c8ea420cc46da103`，批次 `dock-plaques-final2-20261013T142953Z`；18/18串行定向运行、5180条显式OK、114对配对证据与三张共享metadata预览通过。60307行组装产物、9 parts／1887唯一函数、source／asset／QA工具checksum、原用户12 cfg、bitmap／shape策略、语法与whitespace通过。
- 独立 ui-engineer 对两档六图追加复核，原F-DP-001～003限定closed、剩余0；另补看同批1280默认的一张expired图，直接确认“1项”清楚无纹样干扰。限定七图，不扩大未复核profile或全游戏签收。保留 `final/` 首批同一源码 offline smoke 的7个失败，未改源码／断言的复跑通过不等于其不稳定性已根治；revision1～3及历史报告均未覆盖。
- 完整wrapper仍配置49项，本轮没有运行完整49项；旧42/46 FAIL报告保留。手牌托盘、底层透字、advisor与剩余页面／全游戏／真机触屏IME／外部在线服务尚未验收，整体目标保持active。完整记录：`build/qa/guofeng_dock_plaques_20261013/VERIFICATION.md`。

## 2026-10-13 · 国风手牌纸面、教学与上家透字

- 手牌托盘收为单张既有纸面与原生标题／键位／状态，删除装饰树、厚阴影、轨道及重复文字；按真实行高分配独立横向阅读槽，960大字纸面向上延伸而不移动手牌。教学使用原生进度、现有help图标和真实跳过／完成按钮，目标落在实际手牌，不再要求装饰假牌。真实对战关闭纸面背后的冗余wall读数，由顶部HUD负责余牌；不生图、不增资产、不改牌面／副露牌河几何，版本保持1.0.180-godot。
- 在线等待显示“已提交 · 等待服务器确认”，并让 `can_self_discard()` 实际拒绝等待输入；新增六档hand smoke与48对证据检查真实方向键、鼠标跳过／触摸完成、只读状态、实例保留及阅读槽。相关旧装饰断言同步为原生文字／真实手牌，不补假节点或扩大suppression。
- 最终冻结runtime fingerprint为 `27cf4826b11006f0c3d12d516b0d1bb1f23743bb084465b759b5011d77c67eb2`，批次 `hand-tray-final-20261013T161018Z`；59788行、9 parts／1881唯一函数。**27项串行定向运行26通过、1失败，整体focused FAIL**；通过gate打印7288条OK，162对截图经验证，另四张预览共享一份metadata。失败snapshot_pack在旧section N第440行读取已退休 `retained_battle_action_dock_shadow`，尚未到本轮修改的155／156节；同引用存在于HEAD，不伪造阴影或跳过gate，失败前44条OK不计入通过总数。
- 首次证据工具因action tuple多一元素失败，原 `evidence.exit=1`、日志及工具checksum保留；另增v2工具收尾成功、`evidence_v2.exit=0`，仅代表截图／完整性通过，不覆盖 `focused.exit=1`。revision1～5的重叠／缺失图标／旧helper／旧preview契约及等待可选牌证据均保留。329个截图证据文件与报告／工具／失败记录归档校验，source／assets／12份原用户cfg、assemble、bitmap／shape、语法与whitespace通过。
- 独立ui-engineer累计只复核960大字／1280默认／1920大字的idle／pending六图，F-HT-001～003在精确范围内closed、未闭0项，补足原1920复现尺寸；不外推教学、在线远端、其他profile或整局。完整wrapper现配置50项但本轮未跑，旧42/46 FAIL报告不覆盖。advisor、在线HUD噪声、结算／大厅／规则及真机触屏IME／远端服务仍待验收，整体目标保持active。完整记录：`build/qa/guofeng_hand_tray_20261013/VERIFICATION.md`。

## 2026-10-13 · 国风行牌建议与只读详解

- advisor与详解各收为一张仓库既有不透明 `settings_readable_gpt` 纸面，三块建议／牌势／防守区为非视觉host，删除7个伪meter／signal／scan等helper；深墨原生文字与墨面浅字按钮保持同一阅读语言，不生图／增资产，不程序叠层遮透底，2D牌面、手牌／副露牌河几何与1.0.180-godot版本不变。
- 核心结论按字体实际行高及line_spacing完整显示两行，通用clip尊重显式原生wrap约束，44px header入口与卡带间隔6px。详情加宽／增高但仍与actiondock净距6px且不碰手牌；原生RichText按实际滚动宽度呈现全部原文与振听限制，阅读提示跟随真实范围。modal隐藏compact可见面但保留实例；原位延迟建议使render快照失效，同步正文与真实定位目标，回调不再捕获过期牌索引。真实触摸只定位、不出牌，关闭恢复确切手牌焦点。
- 最终冻结runtime `6dc8555f7d05cb624d1ae1c52c29c6d70e76033a9b8eb829232581a6bd33dc3a`，批次 `advisor-final-20261013T173757Z`；59631行／9 parts／1878唯一函数。**原始18项17通过、1失败，focused.exit=1保留**：本轮新标题漏接offline命名覆盖。补真实Label断言后，同runtime独立offline补测退出0；没有将初批重写为18/18或整批重跑。通过gate显式OK为3683，97对PNG／JSON校验通过，工具自检5正向／15反向不计产品断言。
- validator v1误将原生自动折行数与硬换行数作等式；保留旧工具／失败日志后修正，同时保留selfcheck最初误选隐藏top而非真实坏restored的失败，另增v2自检。原v1工具／offline源码快照与manifest、当前工具检查分开归档。baseline960外层143且缺exit不算通过，revision1～7的编译／视觉／行距／空依据／报告别名／释放节点等失败不覆盖。原用户12cfg、既有1966asset文件、assemble／bitmap／shape／语法／whitespace通过。
- 独立ui-engineer仅复核960大字、1280默认、1920大字各restored／top／end九图，三类视觉问题在精确子范围已消除；精确44px／6px及行为由主agent六档运行确认，不签其他状态或全游戏。完整wrapper复用原六档battle reading gate，仍配置50项，本轮未跑完整50；旧42/46 FAIL及退休dock阴影字段的综合快照失败仍保留。在线反馈／toast、结算／大厅／规则、整局及真机触屏IME／远端服务待验收，目标active。完整记录：`build/qa/guofeng_advisor_20261013/VERIFICATION.md`。

## 2026-10-13 · 国风通知、真实定位结果与完整阅读

- Toast收为一张既有不透明宣纸与原生深墨字，删除金横幅、伪路线和“达”装饰；真实HUD／座位／动作／墙牌视觉bounds避让，pending独立列或小屏独立下行。动效仅淡入淡出，不穿过事实区；牌面、手牌、河／副露与1.0.180-godot未变，不新增资产。
- 长通知以44px入口打开原生只读滚动，暂停dwell，Esc／分页／Home／End及焦点恢复，底层牌桌不提交。显式key只合并普通定位／设置旧值，不清错误／奖励队列；默认FIFO、重复计数、优先级与entry／byte／repeat预算保留。同页计时不再被screen tween清理误杀；未挂载尺寸guard与原生resized恢复，模态无安全外槽则保留完整dwell；商店内联替换页脚说明。
- 初始b8批16/17失败（queue负Rect2，虽表面RESULT OK仍被错误扫描拒绝）；9202 accepted批17/17、124对、4486显式OK后，目检仍发现小屏短提示藏牌名。保留历史通过但不认作视觉完成，真实定位文案缩为“已定位：1万”，加入原生完整牌名且无详情硬断言，不靠缩字号或删重要词过测试。
- 当前release源码 `26ebd7ae86b7411d4f1c3d85cb3a260b2656a793285d501df58afa35e8fd5abf`，批次 `toast-release-20261013T212052Z`；59454行／9 parts。17/17定向退出0、artifact退出0，124对PNG／JSON身份与状态核验通过，4506条显式OK；校验器1合成正例／9反向mutation不计产品断言。既有1966资产、原用户12cfg、assemble／bitmap／shape／语法／whitespace均核验，重型任务全串行。
- 独立ui-engineer被派当前16图限定复核，结论尚待返回，不冒充90张Toast或124对全部视觉签收。另按真实纸面／原生字owner修旧dock保留契约，综合C首次重测越过旧字段但仍有座位shadow契约与5条AI源码形状断言失败；座位契约已修，第二次重测UI契约通过、无运行时ERROR，但5条AI源码形状断言仍失败、退出1。未修改AI生产逻辑或放宽5条AI断言，完整50项及真机／远端验收仍未完成，原目标active。记录：`build/qa/guofeng_toast_20261013/VERIFICATION.md`。

## 2026-10-14 · 国风结算账页、精确账目与实际末行

- 结算统一为既有不透明宣纸与两列原生深墨文字：赢家、原2D和牌牌面、番分、完整番种与完整说明独立排布；右侧四家整数总分、带符号整数增减、花数及下局庄家/完场冠军。移除11个退休装饰helper；盾51、账页52、操作53覆盖最后弃牌z50。通知详情关闭改深墨面配浅字。版本仍为1.0.180-godot，2D牌面与副露几何未改。
- 新压力样本捕获原formatter将+76800缩写为+7.7万，结算行与tooltip改为完整带符号整数；HUD紧凑formatter不变。荒庄fixture使用有类型零数组、实际空墙和四家25000，人工改数据后更新revision，避免背景缓存沿用赢家。商店截图冻结真实toast tween速度，保留实际购买/扣款/持久化行为。
- 独立视觉审计新增F-924：960默认末行裁切，960大字滚到底完全空白。旧的“scroll到range”检查漏检；新增原生Label最后字符矩形及JSON包含断言后真实复现exit1。正文改原生WORD_SMART最小高度，dynamic标记保护共享重排，native_wrapped_height只跳过估算，阅读区高度取整数，先后捕获并保留单行重置和0.864px边缘裁切两个开发失败。
- runtime3be9的六档30对结算与两档30对Toast通过实际身份/状态/整数账目/末字断言；ui-engineer独立目视16图与16JSON，限定关闭F-924六档end/retained及当前Toast关闭字色/末句问题，不扩大到未看的状态或全游戏。修后报告为 `build/qa/ui_engineer/AUDIT_GUOFENG_SETTLEMENT_SCROLL_FIXED_20261014.md`。
- 首个完整3be9批次真实结束50/51 FAIL：运行时错误扫描拒绝offline测试缺少RoundSummaryPanel/WinDetailPanel显式覆盖引用。已补真实面板、正文、赢家详情祖先归属检查，未加backfill/假节点/跳过项；定向offline重测exit0且无error/leak。旧完整失败报告/日志/截图留于 `build/qa/guofeng_settlement_20261014/full_50_of_51_failure/`。覆盖引用修正后已重新完整执行，最终51/51 PASS，批次20261014T074734Z-582e174-3be9b08c66b6。
- 修改过的C pack已在3be9实际重测：新结算保留/复用及UI契约通过，仍有历史5条AI源码形状断言失败，退出1，无运行时错误；不改AI生产源或削弱这些断言。首轮后置assemble/whitespace、1503份PNG与12份原root cfg哈希核验均通过；后续完整QA收尾仍重新校验。
- 第二批四页审计已实际看12张历史图及6张3be9新图。当前确认规则960标题重叠、三档成就错误报告1-17/17余0、旧金黑体系、大厅空令牌/返回近似禁用/双清除叉。不可变证据与报告见 `build/qa/guofeng_secondary_pages_20261014/` 和 `build/qa/ui_engineer/CURRENT_CONFIRMATION_20261014.md`；未在冻结QA期间修改四页。F-005未接入草稿与F-002布局说明保存在该批draft目录，不称已修。
- 整体国风UI目标保持active；完整运行终态、411对capture校验与证据边界以 `build/qa/guofeng_settlement_20261014/VERIFICATION.md` 为准。

- 最终收尾：411对当前reading证据通过，8份fixture及runtime冻结校验true，assemble/whitespace、1503份PNG和12份原root cfg通过；全部证据和实际fixture源码归档 `build/qa/guofeng_settlement_20261014/owner_final_run/`。后置汇总曾误读C状态文件而KeyError，保留错误状态后仅续跑后置检查，未影响真实51/51结果。整体目标与四页待修项继续active。
