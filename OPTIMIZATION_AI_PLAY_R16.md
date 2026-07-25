# AI / 玩法 Round 16 - 全 Bot 特殊终局统计

日期：2026-07-25  
版本：1.0.180  
验收：`scripts/ai_play_round16_check.gd`

## 问题

全 Bot 同步模拟按当前触发动作推断结果。弃牌后发生碰杠并杠上自摸时，会被误计为原出牌者点炮；部分杠后终局还会漏记胜局与自摸。

## 修复

新增 `_ai_sim_note_terminal_result`，以 `finish_offline_round` 写入的 `last_win_score.self_draw` 和 `offline_last_winner` 为唯一事实来源，统一统计：

- 胜局、赢家、自摸
- 点炮座位与点炮玩家计数
- 荒庄不生成胜局或点炮，并计入 `wall_ends`

## 运行

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=2 godot --headless --path . -s scripts/ai_play_round16_check.gd
```
