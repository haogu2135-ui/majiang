# 商用验收矩阵

版本：`1.0.180-godot`

本矩阵定义仓库内可重复的 AI、玩法与 UI 商用门禁。所有结论必须绑定同一 Git revision；旧截图、旧强度样本或单支局部回归不能单独构成最终验收。

| 验收域 | 商用合同 | 自动门禁 | 人工证据 |
| --- | --- | --- | --- |
| 构建与版本 | part 合法、生成文件一致，版本固定 `1.0.180-godot` | `scripts/verify_ai_commercial.sh`、`python3 tools/assemble_main.py --verify` | 无 |
| 规则合法性 | 自摸、荣和、抢杠、振听、过水、食替、包三搭、荒庄查听、响应仲裁和番分均按本地规则合同执行 | `scripts/verify_ai_commercial.sh` 中 R15/R30/R32/R41/R42/R57/R58/R60/R61/R65/R77 | `RULES_ACCEPTANCE_MATRIX.md` |
| 隐藏信息公平 | AI 决策不得读取对手暗手；真实动作落地后仍正常开放抢杠等规则窗口 | R13、R91 | 日志中暗手互换不变量 |
| 策略质量 | 规划奖励不重复、候选各自评估路线、末盘吃碰/杠牌纪律和安全替代判定稳定；危险 telemetry 只统计同向听牌且有实质降压的可行动替代 | R63、R67、R87、R88、R90、R93 | 无 |
| 账本与稳定性 | 牌墙、手牌、河牌、副露、花牌合计保持 144 张；四座总分守恒；新场景模拟能终局 | R66、R74、R82 | 无 |
| 难度与强度 | easy/normal/hard 均可终局；hard 在配对牌墙和固定玩家探针下通过危险率、可避免压力与放铳门槛，并覆盖薄听牌灾难保护 | R68、R82、R89、R90、R92 | `build/qa/ai_play_commercial_evidence/STRENGTH_PACK_LATEST.md` |
| UI 全页面 | 菜单、对战、规则、设置、统计、成就、商店、签到、大厅等页面无阻挡、越界、空标签、泄漏与关键状态不可读 | `scripts/verify_ui_regressions.sh` | `build/qa/ui_engineer/AUDIT_LATEST.md`，三分辨率截图复审 |
| 运行资源 | Godot 与截图任务必须串行、单线程、低 CPU/I/O 优先级，并受 180 秒硬超时约束 | 两个统一验证脚本内置并发拒绝与超时 | QA 报告的耗时和日志 |
| Android 发布物 | APK 包名、版本、SDK、v2/v3 签名、证书、资源排除和启动图标均符合发布合同 | `scripts/verify_android_release.sh` | 待审 APK 的哈希与签名信息 |

最终通过条件：AI 商业门禁与完整 UI QA 在当前 revision 全绿，UI 工程师没有未关闭 finding，证据时间新鲜；若声明“可直接发布 Android”，还必须提供并通过签名 APK 审计。
