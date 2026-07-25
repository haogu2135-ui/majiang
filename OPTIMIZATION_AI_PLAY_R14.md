# AI / 玩法 Round 14 - 和牌演出按番分级

日期：2026-07-25  
版本：1.0.180  
验收：`scripts/ai_play_round14_check.gd`

## 问题

结算页原先以 `points >= 6` 识别高番。`points` 是分表结果，最低 1 番也为 200，导致所有普通和牌都误用高番特效。

## 修复

新增 `win_fx_type_for_score`，统一以原始 `fan >= 6` 判定高番：

| 条件 | 演出 |
|---|---|
| 6 番及以上 | `special` |
| 非高番自摸 | `self_draw` |
| 非高番荣和 | `normal` |

## 运行

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=2 godot --headless --path . -s scripts/ai_play_round14_check.gd
```
