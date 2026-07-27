# AI / 玩法 Round 28 - 结算入口拒绝非法牌形

日期：2026-07-26  
验收：`scripts/ai_play_round28_check.gd`

## 问题

`calculate_win_score_from_tiles` 过去假定调用方已经确认和牌。外部 UI、模拟工具或未来网络状态若直接传入未完成的 14 张或副露牌形，函数仍会返回“平胡”和基础分，存在伪结算风险。

## 修复

- 结算入口默认使用现有和牌判定，非法牌形统一返回零番、零分、空番种。
- 已由有效张逻辑确认的 AI 内部待牌评分明确传入 `assume_complete`，不重复做向听/和牌搜索，保持热路径资源占用不变。

## 运行

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=2 godot --headless --path . -s scripts/ai_play_round28_check.gd
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=2 godot --headless --path . -s scripts/ai_play_round25_check.gd
```
