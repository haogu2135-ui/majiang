# UI Screenshot Review Agent

执行日期：2026-07-05

## 职责

- 作为新增 UI 测试工程师的截图审查角色，负责复跑页面截图、核对截图集完整性，并给出人工 UI 观感结论。
- 覆盖主菜单、设置、离线对局、规则、统计、成就、商店、联机大厅、每日签到和加载页。
- 关注国风风格一致性、3D 质感、可读性、控件遮挡、信息密度、暗度和 GPT 资产安全区。

## 可执行流程

```bash
GODOT_SILENCE_ROOT_WARNING=1 xvfb-run -a godot --path . -s scripts/page_screenshot_capture.gd
python3 scripts/ui_screenshot_manifest_check.py
```

## 输出

- 页面截图：`build/qa/pages/01_menu.png` 至 `build/qa/pages/10_loading.png`
- 截图总览：`build/qa/pages/contact_sheet.jpg`，由 `scripts/ui_screenshot_manifest_check.py` 每轮重新生成。
- 机器清单报告：`build/qa/ui_screenshot_manifest_report.md`
- 人工审查报告：`build/qa/ui_screenshot_review_report.md`

## 验收项

- 10 张目标页面截图都存在，尺寸为 `1280x720`，且不是空白图。
- `contact_sheet.jpg` 不得早于任一单张截图；若过期，只能用单张 PNG 做审查证据。
- 截图脚本不能出现 `DisplayServer TTS synth null` 或 lambda capture freed 这类会污染 QA 信号的运行时错误。
- 人工报告必须逐页记录：当前状态、可读性风险、国风/3D 风格表现和下一轮资产优先级。
- 若发现需要 GPT 生图修复的问题，交给 `qa/agents/gpt_image_agent.md` 的 brief/prompt 流程，不直接在截图 Agent 内覆盖 PNG。

## 本轮结论

- 截图集机器检查通过。
- 本轮截图捕获日志没有 `DisplayServer TTS synth null`、`Lambda capture`、无限循环或方向设置错误；仅保留 Xvfb/OpenGL/ALSA/退出资源类环境噪声。
- 主菜单、设置、对局、商店、签到、加载页已有稳定国风基调。
- 统计页已完成一轮原生行/数值对比度修复，`05_stats.png` 平均亮度从 `18.2` 提升到 `22.6`，不需要新的非 GPT 图片。
- 成就、联机大厅仍需要下一轮小型专属资产和输入区密度打磨。
