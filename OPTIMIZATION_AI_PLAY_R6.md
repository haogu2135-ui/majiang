# AI / 玩法 Round 6 — 强度采样与难度验收

日期：2026-07-25  
版本：1.0.180  
验收脚本：`scripts/ai_play_round6_check.gd`

## 目标

在 R1–R5 决策钩子（荣和/自摸留听、多威胁、难度缩放、中盘防守、副露路线、人机分差、危险确认、副露听牌质量）之上，做 **headless 强度采样**，验证：

**困难 ≥ 标准 ≥ 简单** 在防守意识 / 听牌价值 / 路线专注上成立；  
**简单 ≥ 标准 ≥ 困难** 在吃碰贪吃程度上成立。

## 离线循环约束（采样设计依据）

- 人机位固定 **seat 0**；`choose_ai_claim` 跳过 seat 0。
- `run_ai_until_human()` 在轮到 seat 0 时停止，不适合直接 AI-vs-AI 整局。
- R6 采用 **固定场景 + 决策 API 采样**（`get_ai_discard_reports` / `choose_ai_claim` / 各 adjustment），不依赖完整 UI 对局。

## 难度行为摘要

| 维度 | 简单 | 标准 | 困难 |
|------|------|------|------|
| 防守 / 危险意识 | 弱（risk×0.70, defense×0.76） | 基准 | 强（risk×1.24, defense×1.18） |
| 吃碰 | 更贪（claim×1.22） | 基准 | 更挑（claim×0.90） |
| 听牌 / 路线 | 偏钝 | 基准 | 更重 wait/route |
| 弃牌 | 30% 概率次优（分差≤55） | 最优 | 最优 |
| 荣和/自摸留听 | 几乎落袋 | 有价值判断 | 更愿留高价值听 |
| 中盘/终局 | 防守幅度小 | 基准 | multi-threat 与残局分差标定更明显 |
| 节奏 | 略快 | 基准 | 略慢（思考感） |
| 座位人设反差 | 压缩（×0.55 向中性） | 原 profile | 放大（×1.18） |

设置入口：设置页 **AI 难度**（`cycle_ai_difficulty_setting`），持久化 `gameplay/ai_difficulty`。

## 采样场景（R6）

1. **尺度单调性**：defense / risk / wait / route / claim 跨三档。
2. **多威胁中盘**：3 家热副露 + 残墙，比较 midgame push 与危险张相对分。
3. **序盘效率**：孤张字牌 opening dump 分 hard≥normal≥easy。
4. **吃碰纪律**：早期薄形吃，简单分不低于困难。
5. **残局人机分差**：落后追分 / 领先收力（困难不低于简单）。
6. **多座位短采样**：bot seats 1–3 固定 14 张手，平均 defense 单调；困难平均选牌风险不显著高于简单。

## 运行

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=2 godot --headless --path . -s scripts/ai_play_round6_check.gd
# 回归
for i in 1 2 3 4 5 6; do
  GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=2 godot --headless --path . -s scripts/ai_play_round${i}_check.gd || break
done
```

## 后续

已实现见 `OPTIMIZATION_AI_PLAY_R7.md`（全 bot 模拟 / 人设轮换 / 残局追分）。

## 后续可选（R8+）

- seat 0 纯 bot 模式跑完整小局胜率统计
- 按难度随机/轮换 `AI_PROFILES` 权重
- 残局追分与薄听弃和阈值的对局级统计

## R6 代码增量

- `ai_profile_contrast()`：简单压缩 / 困难放大 `AI_PROFILES` 个性
- `ai_ron_decision_report`：`raw_wait >= 1.30` 保大牌型留听身份
- `scripts/ai_play_round6_check.gd`：headless 强度采样验收
- `scripts/ai_play_round1_check.gd`：显式钉死难度，避免 user settings 污染

## R1–R5 钩子索引

| Round | 焦点 |
|-------|------|
| 1 | 荣和留听、多威胁、吃碰形状门槛 |
| 2 | 三档难度、中盘防守、薄一向听弃攻 |
| 3 | 自摸留听、序盘效率、序盘蓄力少吃 |
| 4 | 副露路线重估、人机分差、AI 节奏 |
| 5 | 危险出牌二次确认、副露听牌质量、强度单测 |
| 6 | 整包采样验收 + 本文档 |
