# AI / 玩法 Round 8 — 快评模拟与高危校准

日期：2026-07-25  
版本：1.0.180  
验收：`scripts/ai_play_round8_check.gd`

## 目标

1. 降低全 bot 单手模拟耗时（R7 ~18–45s → 实测单手 ~7–12s，快评单次 ~40ms）  
2. 校准「危险弃牌」统计（区分 soft/high）  
3. 困难档对高危张显式加罚，降低实战放炮倾向  
4. 多手胜率采样 API，验证循环稳定

## 实现要点

| 项 | 说明 |
|----|------|
| `offline_sim_quiet` → `fx_enabled_effective=false` | 静默模拟彻底跳过 FX |
| `speak_*` / `play_claim_animation` | quiet 早退 |
| 快评 Top-K | `get_ai_discard_reports` 在 quiet 下先廉价排序，只完整评估 `AI_FAST_EVAL_TOP_K`(4) |
| 高危罚分 | `risk>=18` 额外扣分；困难 ×1.55，且 `risk>=31` 再加重 |
| 统计 | `high_danger_discards`、`deal_ins`；采样默认**固定人设**可比三档 |
| `sample_bot_match_winrates` | 多手胜率/放铳座位 |

常量：`AI_DANGER_RISK_SOFT=18`、`AI_DANGER_RISK_HIGH=31`、`AI_FAST_EVAL_TOP_K=4`

## 运行

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=2 godot --headless --path . -s scripts/ai_play_round8_check.gd
```

## 注意

- 快评仅用于 `offline_sim_quiet`（强度采样），真人对局仍全量评估。  
- 单手高危/放铳有随机噪声；断言用软容差，趋势靠多手采样观察。
