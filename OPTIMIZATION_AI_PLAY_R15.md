# AI / 玩法 Round 15 - 补花耗尽牌墙的荒庄收束

日期：2026-07-25  
版本：1.0.180  
验收：`scripts/ai_play_round15_check.gd`

## 问题

摸牌或杠后补牌前只检查“牌墙是否为空”。若尾墙只剩花牌，补花过程会把牌墙抽空并返回空牌，旧逻辑仍会继续进入出牌阶段，导致手牌张数和回合状态错误。

## 修复

新增 `draw_turn_tile_or_finish`：抽取实际牌前自动完成补花；没有实牌时立即调用 `finish_wall_draw`。

- AI 正常摸牌：停止当前行牌循环
- 玩家正常摸牌：不再进入可出牌状态
- 杠后补牌：不再带空牌进入和牌/出牌流程

## 运行

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=2 godot --headless --path . -s scripts/ai_play_round15_check.gd
```
