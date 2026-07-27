# AI / 玩法 Round 32 - 荣和与抢杠胡的牌源边界

日期：2026-07-26  
验收：`scripts/ai_play_round32_check.gd`

## 问题

终局结算已验证牌形与支付方，但普通荣和没有确认和牌牌张确实来自当前弃牌；过期或伪造的结算请求可以使用任意支付方结束牌局。抢杠胡不能复用弃牌规则，需验证放铳方仍处于可补杠状态。

## 修复

- `can_finish_offline_round` 接收 `win_context`。
- 普通荣和要求仍处于弃牌响应窗口，且 `last_discard`、`last_discard_seat` 与支付方牌河最后一张都匹配和牌。
- 抢杠胡要求支付方在该牌上仍满足 `can_added_gang`，不要求存在弃牌。
- 已结束和非单机状态不能再次进入离线结算。
- R16 与 R30 的普通荣和夹具补齐真实牌河状态。

## 回归

下列命令按顺序运行，不并发启动 Godot：

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=2 godot --headless --path . -s scripts/ai_play_round32_check.gd
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=2 godot --headless --path . -s scripts/ai_play_round13_check.gd
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=2 godot --headless --path . -s scripts/ai_play_round16_check.gd
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=2 godot --headless --path . -s scripts/ai_play_round30_check.gd
```
