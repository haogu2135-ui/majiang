# AI / 玩法 Round 44 - 河底捞鱼终局计分

日期：2026-07-27  
验收：`scripts/ai_play_round44_check.gd`

## 问题

已有最后实牌自摸的“海底捞月”，但最后实牌被打出后由他家荣和没有对应的“河底捞鱼”番种，终局计分不完整。

## 修复

- 新增严格的最后弃牌上下文：单机、处于弃牌响应窗口、最后实牌由当前弃牌者摸到。
- 满足上下文的普通荣和增加“河底捞鱼”一番。
- 抢杠胡、普通非尾张荣和、离开响应窗口后的陈旧状态和自摸都不会误加该番。
- AI 的 `assume_complete` 假设性待牌估分不读取该临时事件，避免污染弃牌策略。

## 资源

仅在实际结算或默认分数查询读取已有的摸牌/弃牌状态；不新增牌型搜索、缓存或后台任务。

## 运行

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 godot --headless --path . -s scripts/ai_play_round44_check.gd
```
