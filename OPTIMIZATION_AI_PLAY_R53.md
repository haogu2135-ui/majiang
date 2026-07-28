# AI / 玩法 Round 53 - 离线终局的四家桌面守卫

日期：2026-07-27  
验收：`scripts/ai_play_round53_check.gd`

## 问题

`can_finish_offline_round` 只验证赢家和付款座位是否落在当前数组中，但 `finish_offline_round` 固定对四家做支付与分差结算。畸形导入或过期状态若只有两三家，可能越过前置校验后在四座循环中访问越界。

## 修复

- 离线终局守卫要求桌面恰有四家后才允许进入任何自摸、荣和或抢杠结算。
- 少于或多于四家的状态均保持原回合，不改分、不生成结算详情。
- 正常四家牌桌的既有结算路径不变。

## 资源

仅增加一次数组长度比较；不进入 AI 评估、向听搜索或渲染热路径。

## 运行

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 godot --headless --path . -s scripts/ai_play_round53_check.gd
```
