# AI / 玩法 Round 27 - 静默副露预演的喂牌与包赔纪律

日期：2026-07-26  
验收：`scripts/ai_play_round27_check.gd`

## 问题

全 Bot 静默模拟中的副露后弃牌预演只检查向听、放铳风险和安全牌。它会遗漏前台完整弃牌评分已有的喂吃碰、对玩家风险和包三搭责任，因此模拟中的吃碰选择可能比真实对局更冒进。

## 修复

- 快速副露后弃牌报告补入喂牌风险、对玩家风险与包三搭惩罚。
- 这些查询复用同一轮的评估上下文和喂牌缓存，保持每张候选只计算一次。
- 副露纪律复用预演结果中的喂牌报告，避免完整前台路径二次扫描。

## 运行

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=2 godot --headless --path . -s scripts/ai_play_round27_check.gd
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=2 godot --headless --path . -s scripts/ai_play_round11_check.gd
```
