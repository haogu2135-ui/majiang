# AGENTS.md — 云桌麻将

## UI 测试分工

- **ui-engineer**（自定义 agent）：只读 UI 审计，输出 findings。定义：`.codex/agents/ui-engineer.toml`（同步 `~/.codex/agents/ui-engineer.toml`）。
- **主 agent**：按 findings 修 `scripts/main_src/*.gd.part` / `scripts/main_base.gd`，再 assemble / smoke / 截图。

启动示例：

```
spawn_agent(agent_type="ui-engineer", fork_context=false,
  message="对本仓库做整局 UI 审计（只读）。先看 build/qa/current_commercial_3d_1280/，再查 layout 常量。输出 findings + Top3 + 一句话派工。")
```

协作 skill：`.codex/skills/yunzhuo-ui-engineer/SKILL.md`

### 硬约束
- **禁止程序画图**：不得用代码 `Image`/`fill`/程序生成纹理当 UI 图；视觉资源只用 GPT / GROK 生图或仓库既有 `assets/illustrations`（gpt-image-2 @ https://x666.me/v1）
- 牌面：`assets/tiles` 纯 2D，不重生图、不代码调色
- **禁止程序画图（硬性）**：任何 UI 装饰 / 底板 / 河牌垫 / 副露垫 / 横幅 / 面板纹理 **不得** 用 `ColorRect`、`make_color_rect`、代码 `Panel` 叠层当视觉方案
- **视觉资产只允许 GROK / GPT 生图**（及仓库内已有的 `assets/illustrations` 位图）；新增装饰必须先 API 出图再接线，禁止再堆程序色块
- 不回 3D 牌
- 版本保持 1.0.180
- 副露：上下横 / 左右竖，贴座位朝桌心
- 改 part 后：`python3 tools/assemble_main.py --verify`

### 验证
```bash
python3 tools/assemble_main.py --verify
timeout --foreground --signal=TERM --kill-after=15s 180s env GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 godot --headless --path . -s scripts/ui_layout_smoke_test.gd
```

### 资源预算
- 双 Codex 运行时，Godot smoke、截图、生图和批量导入必须串行；启动重型任务前先确认没有现存 `godot`、`xvfb-run` 或批量生图进程。
- 使用 `scripts/verify_ui_regressions.sh` 执行完整 QA；脚本已固定为单线程、低 CPU 优先级、低 I/O 优先级和 180 秒硬超时，并会拒绝与既有 Godot 进程并发。不得并行运行多个完整 QA。

审计报告：`build/qa/ui_engineer/AUDIT_LATEST.md`
