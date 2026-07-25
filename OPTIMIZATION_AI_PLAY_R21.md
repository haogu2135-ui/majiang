# AI / 玩法 Round 21 - 无副露残局主威胁

日期：2026-07-25  
验收：`scripts/ai_play_round21_check.gd`

## 问题

主威胁原先只按副露和染手路线选择。无副露对手在深牌河、残墙时即使已达到近听/疑听级别，也不会成为主威胁，其已打出的现物无法触发 AI 的主威胁安全标签和防守加分。

## 修复

主威胁评分现在取路线压力与达到快进级别后的就绪压力中的较强值，和威胁面板一致。副露染手仍保持原有高优先级，而无副露残局威胁也能为其现物提供正确防守依据。

## 运行

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=2 godot --headless --path . -s scripts/ai_play_round21_check.gd
```
