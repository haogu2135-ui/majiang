# AI / 玩法 Round 47 - 当前摸牌自摸资格

日期：2026-07-27  
验收：`scripts/ai_play_round47_check.gd`

## 问题

计分会保留最近的实际摸牌，用于结果文字、海底和河底判断。但旧的自摸入口也直接使用这条历史记录。玩家吃/碰一张本可荣和的弃牌后，手牌可能仍呈完整结构；若旧摸牌仍留在手中，就可能被错误当作当前自摸牌。

## 修复

- 每次实际摸入实牌时记录轻量的“当前自摸资格”（座位、牌、摸牌序号）。
- 出牌、吃/碰/明杠响应和荒庄会使资格失效，但不清除 `offline_last_draw`，故河底和海底的历史判定不受影响。
- 自摸结算与 AI 自摸决策只接受未失效且与最近摸牌序号完全一致的牌。
- 仅对没有该标记的旧导入状态保留原有手牌末张回退；新运行时的失效标记不可退回该路径。

## 资源

每次状态转换只写入一个至多三字段的字典；校验为常数时间，不增加弃牌候选、向听或有效张循环。

## 运行

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 godot --headless --path . -s scripts/ai_play_round47_check.gd
```
