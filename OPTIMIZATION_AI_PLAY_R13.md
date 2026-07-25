# AI / 玩法 Round 13 - 补杠抢杠全桌预判

日期：2026-07-25  
版本：1.0.180  
验收：`scripts/ai_play_round13_check.gd`

## 目标

1. 补杠决策扫描所有对手，不再只检查玩家座位的抢杠胡。
2. AI 对 AI 对局中，避免宣告已经会被另一 AI 立即抢走的补杠。
3. 记录可抢杠座位和近家优先座位，便于规则层和调试报告复用。

## 实现

| API | 作用 |
|---|---|
| `added_gang_rob_threat_report` | 汇总所有可抢杠者、玩家/AI 类型及近家优先座位 |
| `build_ai_self_gang_report` | 补杠命中任意抢杠者时标记风险并拒绝动作 |
| `choose_ai_added_gang` | 复用报告，不再产出必被截胡的补杠牌 |

## 运行

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=2 godot --headless --path . -s scripts/ai_play_round13_check.gd
```
