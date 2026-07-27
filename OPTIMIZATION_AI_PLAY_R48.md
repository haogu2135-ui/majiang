# AI / 玩法 Round 48 - 自摸结算状态机守卫

日期：2026-07-27  
验收：`scripts/ai_play_round48_check.gd`

## 问题

R47 已确认“当前真实摸牌”来源，但结算入口仍可在弃牌响应、非当前座位或待摸牌状态下，只凭完整手牌和摸牌记录尝试自摸。正常流程不会走到这些状态，外部调用、过期异步任务或导入状态仍可能触发错误结算。

## 修复

- 自摸结算必须处于本家 `await_discard` 的行动窗口，且本家已经实际摸牌。
- AI 自摸报告使用相同窗口守卫，避免任何调用方把过期状态当作可执行自摸。
- 荣和、抢杠和历史摸牌的计分语义保持不变。

## 资源

复用既有 `is_valid_offline_discard_turn`，每次自摸决策和结算只增加常数时间状态判断。

## 运行

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 godot --headless --path . -s scripts/ai_play_round48_check.gd
```
