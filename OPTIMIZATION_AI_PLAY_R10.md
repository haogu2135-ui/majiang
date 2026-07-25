# AI / 玩法 Round 10 — 吃碰玩家纪律 + 点炮玩家统计

日期：2026-07-25  
版本：1.0.180  
验收：`scripts/ai_play_round10_check.gd`

## 目标

1. **吃碰玩家弃牌更克制**：困难拒脏吃/无收益碰；副露后必喂 seat0 则拒  
2. **副露评分扣分**：`human_claim_penalty` 进入 `ai_claim_action_score`  
3. **点炮玩家可度量**：sim / benchmark 增加 `deal_ins_to_human`  
4. **开局简报不刷屏**：整场比赛 toast 一次，日志仍每局写  

## 实现

| API / 钩子 | 作用 |
|------------|------|
| `make_ai_claim_context(..., from_seat)` | 副露上下文带弃牌来源 |
| `human_claim_discipline_report(...)` | 拒吃玩家 / 防点玩家 / 罚分 |
| `build_ai_claim_report` | `declined_by_human` + `human_claim_penalty` |
| `ai_claim_action_score` | `score -= human_claim_penalty` |
| `deal_ins_to_human` / `human_claim_declines` | 全 bot 采样指标 |
| `offline_match_briefing_shown` | 首局 toast 一次 |

## 运行

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=2 godot --headless --path . -s scripts/ai_play_round10_check.gd
```

## 与 R9 关系

- R9 管**弃牌**防点炮；R10 管**吃碰**防点炮与可观测指标。  
