# AGENTS.md — 云桌麻将

## UI 测试分工

- **ui-engineer**（自定义 agent）：只读 UI 审计，输出 findings。定义：`.codex/agents/ui-engineer.toml`（同步 `~/.codex/agents/ui-engineer.toml`）。
- **主 agent**：按 findings 修 `scripts/main_src/*.gd.part` / `scripts/main_base.gd`，再 assemble / smoke / 截图。

启动示例：

```
spawn_agent(agent_type="ui-engineer", fork_turns="none",
  message="对本仓库做 UI 审计（只读）。先读 AGENTS.md 硬约束及审阅防错，再看主 agent 指定的当前截图证据。输出 findings + Top3 + 一句话派工。")
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
set -e
python3 tools/assemble_main.py
python3 tools/assemble_main.py --verify
timeout --foreground --signal=TERM --kill-after=15s 180s env GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 /opt/godot/Godot_v4.6.3-stable_linux.arm64 --headless --audio-driver Dummy --path . -s scripts/ui_layout_smoke_test.gd
```

生成或校验失败时立即停止，不得继续测试旧的 `main.gd`。每次重跑使用新的日志名，保留失败和中止证据。

### 资源预算
- 双 Codex 运行时，Godot smoke、截图、生图和批量导入必须串行；启动重型任务前先确认没有现存 `godot`、`xvfb-run` 或批量生图进程。
- 使用 `scripts/verify_ui_regressions.sh` 执行完整 QA；脚本已固定为单线程、低 CPU 优先级、低 I/O 优先级和 180 秒硬超时，并会拒绝与既有 Godot 进程并发。不得并行运行多个完整 QA。

审计报告：`build/qa/ui_engineer/AUDIT_LATEST.md`

## Codex 审阅防错

- 2026-10-15 已出现多批原始 PNG 累计后模型网关返回 `413 Payload Too Large`。每次只回传 **1 张**审阅图；先用 `python3 tools/prepare_ui_review_image.py <build/qa/内的截图路径>` 生成有大小上限的 JPEG 副本，再 `view_image`。原始 PNG 和逐帧 JSON 保留，副本不能代替原始验收证据；需要细查时只打开相关单张原图。
- 按阶段收敛上下文，禁止在同一长会话反复灌入多批原图。每个审阅任务最多查看 3 张图，更多图片拆成独立审计任务；UI 审计启动使用 `fork_turns="none"`，显式传任务、当前证据路径及硬约束，不继承完整图片历史。发现 413 时停止重复发送同一大请求，改用精简上下文与审阅副本；不得把反复重试当作进展。这些是本仓库的保守工作预算，不代表已测得网关的请求上限。
- 查看截图前先 `rg --files` 确认真实路径。1280 默认页面目录是 `captures/pages/`，不能推测成 `captures/pages_1280x720/`；末章实际叫 `rules_chapter_6`，不能推测 `rules_end`。
- 历史审计只读相关节或末尾，禁止整份 `cat`；日志按时间、线程和错误类别筛选，只输出必要摘要，避免超长截断与无关配置内容进入上下文。
- HTTP 错误按真实状态码/错误字段识别；不得把 request ID、哈希中的 413/502 数字子串算作报错。HTTP 与 retry 的重复记录须按时间和线程核对，不能直接当成独立事件数。
- 长 QA 同时核对实际 PID/命令、状态文件和控制台；只报告日志明确完成的检查名。观察超时不等于进程中断，不得因此重复启动；SIGTERM 的发送方无证据时保持未知。
