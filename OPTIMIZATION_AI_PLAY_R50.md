# AI / 玩法 Round 50 - 暗杠后的首次明副露策略

日期：2026-07-27  
验收：`scripts/ai_play_round50_check.gd`

## 问题

R46 已让暗杠保留门清，但 AI 副露决策仍用总固定组数判断是否“已经开门”。暗杠后的首次吃/碰会被误当作后续明副露，门槛过低，序盘和路线保护也会被不必要地放宽。

## 修复

- `open_melds` 继续只用于向听和牌形结构。
- 新增 `exposed_melds` 到副露评估上下文，只用于首次开门阈值、序盘开门约束、明副露纪律及副露后弃牌路线。
- 未登记四张组仍按明杠保守处理，保持旧状态兼容。

## 资源

复用 R46 的最多四组副露计数，在每次副露报告中只做常数规模遍历；向听和有效张路径不增加额外搜索。

## 运行

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 godot --headless --path . -s scripts/ai_play_round50_check.gd
```
