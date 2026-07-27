# AI / 玩法 Round 45 - 包三搭归属状态校验

日期：2026-07-27  
验收：`scripts/ai_play_round45_check.gd`

## 问题

包赔归属通常由单机状态机产生，但导入状态或错误外部状态可能写入越界座位、赢家自包等非法归属。旧实现会在结算或牌桌预览中直接用该值索引玩家数组，导致崩溃或错误支付。

## 修复

- `package_payer_for` 统一验证赢家、付款座位和自包情况。
- 包赔预览、活动提示和 AI 第三搭纪律统一使用已验证归属。
- 非法归属回退为普通自摸支付，合法包三搭仍保持“包家承担三份”的现有规则。
- `record_claim_source` 也拒绝越界座位输入。

## 资源

只在副露来源、结算和 UI 预览边界做常数时间座位校验，不进入弃牌搜索或有效张循环。

## 运行

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 godot --headless --path . -s scripts/ai_play_round45_check.gd
```
