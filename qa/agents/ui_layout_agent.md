# UI Layout Test Agent

执行日期：2026-07-05

## 职责

- 作为新增 UI 测试工程师，专门守住测试报告中已发现的页面布局问题。
- 覆盖顶部 HUD 按钮、复杂响应行动条、设置模态遮罩和安全内容区域。
- 使用 Godot headless 运行可复跑脚本，不依赖截图或 Android 真机。

## 可执行门禁

```bash
GODOT_SILENCE_ROOT_WARNING=1 godot --headless --path . -s scripts/ui_layout_smoke_test.gd
```

## 验收项

- 1280x720、1920x1080、960x540 横屏下，“设置 / 返回 / 更新”按钮均在屏内、无重叠，并保持可触控尺寸。
- 人类响应同时包含 `胡 / 杠 / 碰 / 3 个吃法 / 过` 时，所有按钮都可见、顺序稳定、没有越出屏幕。
- 人类响应状态还必须绘制手牌托盘，并验证响应摘要条、行动 dock、手牌托盘之间保留垂直间距；pending claim 不允许再出现额外 `ActionIntentDock`。
- 设置面板打开时创建全屏 `Control` 遮罩，`mouse_filter == MOUSE_FILTER_STOP`，底层主菜单和对局按钮不会误触。
- 测试只检查几何和模态行为，不替代完整玩法 smoke、截图审查或 Android 真机刘海屏验收。

## 报告输出

- 通过时输出 `ui layout smoke test passed` 并以退出码 `0` 结束。
- 失败时通过 `push_error` 输出具体 viewport 和控件名称，并以退出码 `1` 结束。

## 已接入门禁

- `verify_build.sh` 在检测到 `godot` 可用时会运行本 Agent 的 smoke 脚本。
- 本轮报告：`build/qa/ui_layout_report.md`

## 本轮实测

- `python3 tools/assemble_main.py --check`：通过。
- `python3 tools/assemble_main.py --verify`：通过。
- `GODOT_SILENCE_ROOT_WARNING=1 godot --headless --path . -s scripts/ui_layout_smoke_test.gd`：通过。
