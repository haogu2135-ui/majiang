# AI / 玩法 Round 30 - 结算入口验证真实和牌状态

日期：2026-07-26  
验收：`scripts/ai_play_round30_check.gd`

## 问题

计分函数已经会将非法牌形记为零分，但 `finish_offline_round` 仍会先播放和牌效果、写入终局状态。错误外部状态、过期响应或未来联机消息可能因此把对局以零分和牌结束；荣和还可能接受赢家自己作为支付方。

## 修复

- 新增 `can_finish_offline_round`，自摸验证现有手牌成和；荣和验证补入放铳牌后的和牌与有效支付座位。
- 无效结算直接返回，不播放特效、不改分、不切换终局。
- 更新 R16 荣和夹具为真实的 13 张听牌手，避免测试依赖非法结算。

## 运行

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=2 godot --headless --path . -s scripts/ai_play_round30_check.gd
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=2 godot --headless --path . -s scripts/ai_play_round16_check.gd
```
