# AI / 玩法 Round 18 - 有效张缓存与可见牌同步

日期：2026-07-25  
验收：`scripts/ai_play_round18_check.gd`

## 问题

`effective_tile_metrics` 的缓存键只包含手牌与向听数，但缓存结果包含根据牌河和副露计算出的有效张剩余数。相同手牌在牌河变化后可能复用旧 `ukeire`，让 AI 高估已被看尽的听口，或低估新局面的进张。

## 修复

将可见张数快照加入有效张缓存键。手牌、向听或任意已见牌改变时，都会使用独立的有效张计算结果；相同局面仍可命中缓存。

## 运行

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=2 godot --headless --path . -s scripts/ai_play_round18_check.gd
```
