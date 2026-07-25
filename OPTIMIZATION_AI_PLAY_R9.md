# AI / 玩法 Round 9 — 防点炮玩家 + 开局简报 + 多手基准

日期：2026-07-25  
版本：1.0.180  
验收：`scripts/ai_play_round9_check.gd`

## 目标

1. **真人对局手感**：AI 更不愿点炮给玩家（seat0），困难明显强于简单  
2. **开局可读性**：发牌后提示 AI 难度与对手人设  
3. **多手强度基准**：`sample_ai_strength_benchmark` 聚合高危/放铳趋势  

## 实现

| API / 钩子 | 作用 |
|------------|------|
| `human_readiness_for_defense()` | 玩家副露/河深/残墙 → 压迫分 |
| `human_target_discard_penalty(...)` | 喂 seat0 的额外弃牌罚分（难×1.45 / 易×0.55） |
| `build_ai_discard_report` | `score -= human_pen`，报告字段 `human_target_penalty` |
| `offline_hand_ai_briefing_text()` | 「AI难度 · 座位人设」 |
| `deal_offline_hand` | 非 quiet 时 `add_log` + `show_toast` 简报 |
| `sample_ai_strength_benchmark` | 多手 fixed-profile 三档对比摘要 |

## 运行

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=2 godot --headless --path . -s scripts/ai_play_round9_check.gd
```

## 与 R1–R8 关系

- R8 快评/高危通用罚分仍在；R9 在其上叠加**对玩家定向**防点炮。  
- 全 bot 采样把 seat0 当探针，难度仍可区分。  
