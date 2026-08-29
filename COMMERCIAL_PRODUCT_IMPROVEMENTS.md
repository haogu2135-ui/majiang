# 云桌麻将商业产品改进清单

版本基线：`1.0.180-godot`

本清单把当前客户端的产品能力、商业价值和发布缺口放在同一张表里。`已完成`表示当前代码和自动验收已有可重复证据；`部分完成`表示已有可用路径，但仍缺少产品闭环或真实环境证据；`待实现`表示尚未进入当前版本合同。它不替代 `COMMERCIAL_ACCEPTANCE_MATRIX.md`、`RULES_ACCEPTANCE_MATRIX.md` 或 Android 发布审计。

| 编号 | 产品改进与价值 | 当前缺口 | 主要实现文件 | 验收标准 | 状态 |
| --- | --- | --- | --- | --- | --- |
| P01 | 离线对局精确续局：用户退出或切后台后可回到同一手牌、牌墙和响应窗口，降低中断成本。 | 当前只覆盖本机单局快照；跨设备同步未提供。 | `scripts/main_base.gd`、`scripts/main_src/gameplay.gd.part`、`scripts/main_src/core.gd.part` | 保存后重启仍保持手牌、牌河、副露、阶段、倒计时和事件链；新赛季不会复用旧快照。 | 已完成 |
| P02 | 牌账与分数完整性：阻止损坏进度造成复制牌、丢牌或结算漂移。 | 错误信息仍是面向用户的通用提示，缺少可导出的诊断包。 | `scripts/main_base.gd`、`scripts/main_src/gameplay.gd.part`、`scripts/offline_smoke_test.gd` | 非法牌、重复牌、缺牌、异常分数和错误 schema 均被拒绝；四家牌张与分数守恒。 | 已完成 |
| P03 | 回放码导入与时间线：让玩家可复盘、分享和核验一局关键事件。 | 尚无本地回放收藏夹、搜索和批量管理。 | `scripts/main_src/quality.gd.part`、`scripts/main_src/screens.gd.part`、`scripts/ui_layout_smoke_test.gd` | 导出码可导入；SHA-256 链校验通过后显示事件时间线；篡改或无效码给出明确反馈。 | 已完成 |
| P04 | 地方规则选择：覆盖广东、四川、南京、扬州的牌墙和基础规则差异，扩大目标用户。 | 特殊地方番型和包赔细则仍需与正式线下规则逐项确认。 | `scripts/main_src/core.gd.part`、`scripts/main_src/gameplay.gd.part`、`RULES_ACCEPTANCE_MATRIX.md` | 四种规则牌墙数量、花牌、吃牌权限、最低番和包赔开关稳定，设置切换在下一局生效。 | 部分完成 |
| P05 | 牌势信息架构：顶部进度、余牌、风位、座位状态和中心牌桌形成快速扫桌路径。 | 真实用户可读性仍需人工视觉复审，尤其是极端长文本和小屏设备。 | `scripts/main_src/render.gd.part`、`scripts/ui_layout_smoke_test.gd` | 三种分辨率下关键状态不越界、不遮挡，手牌、牌河、副露方向符合座位朝桌心规则。 | 已完成 |
| P06 | 可解释 AI：展示推荐出牌、进张、牌型路线、风险来源和安全替代，提升学习价值与信任。 | 解释文本尚未做用户分层，也没有独立的教学数据指标。 | `scripts/main_src/ai_brain.gd.part`、`scripts/main_src/render.gd.part` | 推荐与说明来自同一评估结果；高危出牌能提供安全替代；玩家辅助默认关闭且可设置开启。 | 已完成 |
| P07 | 分级 AI 对手：简单、标准、困难保持可终局，并体现守门、速攻和做大牌风格。 | 尚无按玩家胜率自动调节或赛季平衡面板。 | `scripts/main_src/ai_brain.gd.part`、`scripts/main_src/gameplay.gd.part`、`scripts/verify_ai_commercial.sh` | 多难度、多种子和固定探针通过终局、风险和隐藏信息公平门禁。 | 部分完成 |
| P08 | 无障碍阅读配置：大字、高对比、减动效及组合 profile 降低视觉和操作门槛。 | 尚缺真实 Android 字体、系统字号和 TalkBack 的设备证据。 | `scripts/main_base.gd`、`scripts/main_src/screens.gd.part`、`scripts/ui_accessibility_smoke_test.gd` | 六种 profile 可循环切换；字号、对比边界、动效和键盘焦点状态正确；三种尺寸截图可审阅。 | 已完成 |
| P09 | 模态层和键盘焦点恢复：设置、规则、回放、诊断等页面可预测地进入和退出。 | 触控、硬件返回键和 IME 仍需在真机矩阵中补证。 | `scripts/main_src/core.gd.part`、`scripts/main_src/screens.gd.part`、`scripts/ui_interaction_smoke_test.gd` | Esc/系统返回关闭当前层并恢复来源控件焦点；遮罩不透出底层文字，按钮有明确触控尺寸。 | 部分完成 |
| P10 | 聊天安全抽屉：聊天面板避开牌河、副露、牌桌记录和行动区，保证联机沟通不遮牌。 | 当前按固定牌桌几何路由，尚未适配动态浮层优先级和用户自定义位置。 | `scripts/main_src/core.gd.part`、`scripts/main_src/screens.gd.part`、`scripts/ui_layout_smoke_test.gd` | 顶部和副露路线在 1280/960 等尺寸均不与牌桌元素相交，输入框和发送按钮保持可用。 | 已完成 |
| P11 | 联机语音消息：提供麦克风状态、PCM 分片传输和远端播放，缩短实时沟通链路。 | 需要真实网络丢包、权限拒绝、回声和隐私提示测试；服务端容量合同未记录。 | `scripts/main_src/core.gd.part`、`scripts/main_src/audio.gd.part`、`scripts/main_src/online.gd.part` | 无麦克风权限时可降级；语音状态和分片序号去重；断线或异常音频不阻塞牌局。 | 部分完成 |
| P12 | 本地语音与音频兜底：牌名/动作优先用随包语音，TTS 和音频唤醒作为兜底。 | 设备型号覆盖、音量焦点和蓝牙路由仍需真机验收。 | `scripts/main_base.gd`、`scripts/main_src/audio.gd.part` | 进入牌桌、触摸和恢复前台后能唤醒音频；资源缺失时无崩溃并保留文字提示。 | 部分完成 |
| P13 | 新手引导：用教程解释摸切、吃碰杠胡、响应窗口和牌势提示，降低首次流失。 | 客户端已覆盖教学状态机和本地断点；完整新用户漏斗/完成率统计仍未接入服务端。 | `scripts/main_base.gd`、`scripts/main_src/screens.gd.part`、`scripts/main_src/render.gd.part`、`scripts/ui_layout_smoke_test.gd`、`scripts/offline_smoke_test.gd` | 首次进入可完成不依赖真人的四步教学；摸切、响应和收尾 checkpoint 可中断/继续；完成与跳过状态持久化，菜单仅保留轻量复习入口。 | 已完成 |
| P14 | 日常任务与赛季成长：通过签到、任务、段位和连胜形成回访理由。 | 奖励经济仍是本地状态，尚未接入服务端防刷和赛季运营配置。 | `scripts/main_base.gd`、`scripts/main_src/screens.gd.part` | 任务进度封顶且只领奖一次；赛季换期清理旧状态；段位和连胜显示与结算一致。 | 部分完成 |
| P15 | 商店与虚拟经济：金币、宝石、道具和奖励形成可理解的长期循环。 | 尚无支付、退款、服务端库存和反作弊闭环；当前不能单独宣称可变现。 | `scripts/main_base.gd`、`scripts/main_src/screens.gd.part`、`scripts/main_src/core.gd.part` | 消费、奖励和双倍道具幂等；余额不为负；离线状态损坏时可恢复到安全值。 | 部分完成 |
| P16 | 联机断线恢复：将服务器确认、拒绝、重连和房间状态恢复成明确流程。 | 已具备掉线上下文保存、重连后的单次幂等入房和状态回填；仍缺真实网络抖动、多客户端 soak 与服务端重复动作验收。 | `scripts/main_src/online.gd.part`、`scripts/main_src/core.gd.part`、`scripts/online_protocol_smoke_test.gd` | 网络短断后可恢复房间和当前状态；重复动作不重复结算；拒绝原因可见且不锁死输入。 | 部分完成 |
| P17 | 回放产品闭环：从导入页扩展到历史记录、收藏、删除、搜索和分享入口。 | 本地归档闭环已具备；跨设备同步、云端分享和账号侧历史仍未接入。 | `scripts/main_src/quality.gd.part`、`scripts/main_src/screens.gd.part`、`scripts/main_base.gd` | 最近回放可按日期/规则检索；删除有确认；分享码在版本兼容范围内可再次核验。 | 本地完成 |
| P18 | 产品遥测与问题诊断：用匿名事件识别卡顿、断线、放弃和崩溃热点。 | 已具备隐私同意、字段白名单、版本化 schema、本地 outbox、导出和清除；尚无上传后端与运营看板。 | `scripts/main_src/quality.gd.part`、`scripts/main_src/online.gd.part`、`scripts/main_base.gd` | 用户明确同意后才记录最小化匿名事件；上传失败不影响牌局；事件版本可回放和删除。 | 部分完成 |
| P19 | 更新体验与发布安全：manifest、版本化 APK 直链和 SHA-256 校验降低更新失败率。 | 当前下载地址是本机回环服务；正式 CDN、签名 manifest 和灰度回滚尚未配置。 | `scripts/main_base.gd`、`scripts/main_src/core.gd.part`、`scripts/verify_android_release.sh` | 版本较新才下载；下载后哈希不匹配拒绝安装；manifest 不可用时有可理解的降级提示。 | 部分完成 |
| P20 | 可重复商业发布门禁：把规则、AI、UI、资源、Android 签名和真机证据绑定到同一 revision。 | UI/AI 静态与运行时门禁已具备，仍缺最终签名 APK、真机设备矩阵和生产多客户端 soak。 | `COMMERCIAL_ACCEPTANCE_MATRIX.md`、`scripts/verify_ui_regressions.sh`、`scripts/verify_ai_commercial.sh`、`scripts/verify_android_release.sh` | 当前 revision 的 assemble、AI/UI QA、APK 签名审计和真机 smoke 全绿，证据时间新鲜且可追溯。 | 部分完成 |

## 当前发布判断

当前版本已具备可重复的离线续局、回放归档与校验、牌账校验、联机恢复基础、UI 布局和无障碍基础。要声明“可直接商业发布”，仍需补齐 P04 的正式地方规则确认、P11/P12/P16 的真实网络与设备证据，以及 P18 的上传后端、P19/P20 的正式签名发布链路；本地 P17/P18 实现不能替代云端运营和隐私合规验收。

## 本地验收入口

```bash
python3 tools/assemble_main.py --verify
scripts/verify_ai_commercial.sh
GODOT_BIN=/opt/godot/Godot_v4.6.3-stable_linux.arm64 scripts/verify_ui_regressions.sh
scripts/verify_android_release.sh /path/to/signed-v1.0.180-godot.apk
```

上述门禁应串行执行；Android 签名 APK、真机和生产联机证据不应以本地 headless 结果替代。
