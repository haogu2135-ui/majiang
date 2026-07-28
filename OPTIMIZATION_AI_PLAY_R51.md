# AI / 玩法 Round 51 - 抢杠胡的当前动作归属

日期：2026-07-27  
验收：`scripts/ai_play_round51_check.gd`

## 问题

抢杠胡的直达 AI 路径只验证放杠方仍保有可补杠的碰牌与手牌。若过期协程或导入状态在其他座位的行动窗口保留这组牌，便可把历史上的可补杠结构伪造成当前抢杠牌源并结束牌局。

## 修复

- 直达 AI 抢杠胡除了验证赢家为 AI，也要求放杠方满足当前 `is_valid_offline_added_gang` 动作窗口。
- 已展示的人类抢杠响应仍按已捕获的 `pending_claim` 上下文认证，不受当前座位变化影响。
- 增加回归覆盖：合法 AI 抢杠、错座位过期来源、待摸牌来源及人类响应窗。

## 资源

复用既有回合合法性检查，只进行常数时间状态与牌张查询；不进入弃牌评估、向听搜索或有效张循环。

## 运行

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 godot --headless --path . -s scripts/ai_play_round51_check.gd
```
