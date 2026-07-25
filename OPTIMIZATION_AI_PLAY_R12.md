# AI / 玩法 Round 12 — 响应优先级与座次仲裁

日期：2026-07-25  
版本：1.0.180  
验收：`scripts/ai_play_round12_check.gd`

## 目标

1. AI 响应先按玩法优先级裁决：胡 > 碰/杠 > 吃，避免高估值吃越过碰。
2. 不同座位的同级响应按出牌后的近家优先，不再由策略分数改变牌权。
3. 同一座位同时可碰/杠时，仍由 AI 策略评分选择具体动作。
4. 玩家与 AI 同级响应也按近家裁决；保留现有多人可胡时玩家可选择的体验。
5. 响应窗口缓存已经算好的 AI 选择，玩家点“过”后不重复评估。

## 运行

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=2 godot --headless --path . -s scripts/ai_play_round12_check.gd
```
