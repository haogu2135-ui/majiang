# AI / 玩法 Round 22 - AI 评估缓存隔离

日期：2026-07-26  
验收：`scripts/ai_play_round22_check.gd`

## 问题

全 Bot 静默模拟为了速度只完整评估弃牌候选中的 Top-K。原缓存键没有记录该模式，切回完整评估时可能复用只有四项的近似报告。AI 座位人设映射同样不在缓存键内，重排人设后也可能沿用上一次的攻守权重。

## 修复

弃牌报告缓存键现在包含静默模拟标志和四座人设映射。快评仅服务于同步模拟，玩家对局或映射变化后都会得到与当前上下文一致的完整决策报告。

## 运行

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=2 godot --headless --path . -s scripts/ai_play_round22_check.gd
```
