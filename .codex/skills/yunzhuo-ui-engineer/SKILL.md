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
  fork_turns="none",
  message="对 /home/guhao/majiang 做 UI 审计（只读）。先读 AGENTS.md 硬约束及 Codex 审阅防错，再按主 agent 提供的当前证据路径审阅；不得默认使用历史 current_commercial_3d_1280。每次只看一张压缩审阅副本，原 PNG/JSON 留作验收。核对 layout 常量与 render/gameplay part，输出 findings + Top3 + 一句话派工，写入 build/qa/ui_engineer/AUDIT_LATEST.md。不得运行 Godot/截图/生图，与主 agent 共享工作树。"
)
```

定义文件：
- 个人：`~/.codex/agents/ui-engineer.toml`
- 项目：`.codex/agents/ui-engineer.toml`
- 项目指引：`AGENTS.md`

## 修复后回验
先生成主文件，再校验；任一步失败都必须停止，不得启动基于旧产物的测试。
```bash
set -e
python3 tools/assemble_main.py
python3 tools/assemble_main.py --verify
# 启动前按 AGENTS.md 确认无现存 Godot / Xvfb / 批量生图。
timeout --foreground --signal=TERM --kill-after=15s 180s \
  env GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 \
  nice -n 10 ionice -c 2 -n 7 /opt/godot/Godot_v4.6.3-stable_linux.arm64 \
  --headless --audio-driver Dummy --path . -s scripts/ui_layout_smoke_test.gd
```

完整回归使用 `scripts/verify_ui_regressions.sh`，不得与上述定向检查并发。

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

