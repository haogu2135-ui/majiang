# AI / 玩法 Round 31 - 副露落地前验证状态机合法性

日期：2026-07-26  
验收：`scripts/ai_play_round31_check.gd`

## 问题

`apply_offline_claim` 过去直接修改手牌和牌河，只依赖 UI 或 AI 调用方已提前验证。过期响应、非法座位或伪造的吃牌组合一旦直达该函数，可能消耗无关牌或错误夺取牌河。

## 修复

- `get_claim_options` 先拒绝非法座位、空牌和已结束状态。
- 新增 `is_valid_offline_claim`，统一验证响应阶段、当前弃牌、来源座位、动作选项以及吃牌组合。
- `apply_offline_claim` 成为真正的状态变更边界，非法请求不改动任何牌桌状态。

## 运行

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=2 godot --headless --path . -s scripts/ai_play_round31_check.gd
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=2 godot --headless --path . -s scripts/ai_play_round12_check.gd
```
