# AI / 玩法 Round 19 - 结算状态跨局隔离

日期：2026-07-25  
验收：`scripts/ai_play_round19_check.gd`

## 问题

荒庄结算没有清空上一局的 `last_win_score`。结算页会正确显示荒庄摘要，却仍渲染上局胡牌的番数和牌型明细；直接开始新局时也会保留该过期状态。

## 修复

荒庄与每局发牌初始化都会清空 `last_win_score`。胡牌详情现在只会出现在实际胡牌的当前结算中，荒庄与新局不再携带历史赢家数据。

## 运行

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=2 godot --headless --path . -s scripts/ai_play_round19_check.gd
```
