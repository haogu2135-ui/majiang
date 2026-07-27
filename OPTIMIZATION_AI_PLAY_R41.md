# AI / 玩法 Round 41 - 舍张振听硬规则

日期：2026-07-27  
验收：`scripts/ai_play_round41_check.gd`

## 问题

听口评估早已把“回头待”当作软惩罚，但规则层仍允许荣和/抢杠胡自己河牌中出现过的牌。这与多数商用地方麻将的舍张振听习惯冲突，也会让 AI 在振听位继续点炮或误展示胡按钮。

## 修复

- 新增 `is_discard_furiten` / `can_ron_for_seat` / `can_ron_for_seat_from_counts`。
- `get_claim_options`、普通荣和结算、抢杠胡结算统一走荣和边界，振听时不给 `hu`。
- AI 荣和报告、抢杠选择与补杠威胁扫描共用同一硬规则。
- 自摸仍只看牌形，不受舍张振听影响。
- 规则说明补充舍张振听条目。

## 资源

振听判断只扫描当前座位河牌，不新增缓存、不增加 AI 完整评估路径，热路径额外开销可忽略。

## 运行

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 godot --headless --path . -s scripts/ai_play_round41_check.gd
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 godot --headless --path . -s scripts/ai_play_round32_check.gd
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 godot --headless --path . -s scripts/ai_play_round40_check.gd
```
