# AI / 玩法 Round 52 - 杠后补牌的自摸决策窗口

日期：2026-07-27  
验收：`scripts/ai_play_round52_check.gd`

## 问题

`draw_after_gang` 会在补牌后直接结束任何成和手牌。这绕过了玩家的正常自摸操作，也让 AI 不能对杠上低价值自摸执行既有的留听价值判断。

## 修复

- 杠后补牌只建立普通的 `await_discard` 自摸行动窗口，不直接结算。
- 同步全 Bot 与可见牌桌 AI 循环在“无需再摸牌但仍有当前自摸资格”时，复用普通 `ai_tsumo_decision_report` 和留听回打逻辑。
- 玩家仍由现有自摸按钮完成结算；杠上开花计分条件不变。

## 资源

补牌后每次最多增加一次既有自摸报告调用，不新增向听搜索或后台任务；常规非杠回合不增加额外分支。

## 运行

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 godot --headless --path . -s scripts/ai_play_round52_check.gd
```
