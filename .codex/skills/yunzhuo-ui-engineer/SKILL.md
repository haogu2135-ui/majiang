---
name: yunzhuo-ui-engineer
description: "云桌麻将 UI 测试协作流：spawn ui-engineer 做只读 UI 审计，主 agent 按 findings 修复。用于对战/菜单/大厅/设置/规则/商店视觉与布局问题、截图复盘、layout smoke。"
---

# 云桌麻将 · UI 工程师协作

## 何时使用
用户要求 UI 测试、对战画面复盘、找布局问题，或说「让 UI 工程师看看 / 继续测 UI」时使用。

## 角色分工
1. **ui-engineer**（`agent_type=ui-engineer`）：只读审计，输出 findings。
2. **主 agent**：按 findings 修代码并回验。

## 启动
```
spawn_agent(
  agent_type="ui-engineer",
  fork_context=false,
  message="对 /root/yunzhuo-mahjong-godot 做整局 UI 审计（只读）。先看 build/qa/current_commercial_3d_1280/ 截图，再查 layout 常量与 render/gameplay part。输出 findings + Top3 + 一句话派工，写入 build/qa/ui_engineer/AUDIT_LATEST.md。"
)
```

定义文件：
- 个人：`~/.codex/agents/ui-engineer.toml`
- 项目：`.codex/agents/ui-engineer.toml`
- 项目指引：`AGENTS.md`

## 修复后回验
```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=2 godot --headless --path . -s scripts/ui_layout_smoke_test.gd
timeout 180 xvfb-run -a -s "-screen 0 1280x720x24" \
  godot --path . --rendering-driver opengl3 -s /tmp/capture_battle_only_v180.gd
```

## 硬约束
- 2D `assets/tiles`，不重生图、不代码调色牌面
- **禁止程序画图（硬性）**；**视觉只允许 GROK/GPT 生图** + 既有 illustrations
- 不回 3D 牌；版本 1.0.180
- 副露：上下横、左右竖，贴座位朝桌心
- 牌河贴近各家座位，不挤桌心

## 硬约束（强制）
- **禁止程序画图**：不得用 ColorRect / make_color_rect / 代码 Panel 叠层充当 UI 视觉
- **只使用 GROK / GPT 生图**（及仓库既有 illustrations 位图）补国风资产；新增装饰先出图再接线
- 牌面 `assets/tiles` 纯 2D，不代码调色；不回 3D 牌；版本 1.0.180

