# AI / 玩法 Round 20 - 全 Bot 对局不变量回归

日期：2026-07-25  
验收：`scripts/ai_play_round20_check.gd`

## 覆盖

对简单、标准、困难三档各运行三手固定种子的全 Bot 对局，逐手验证：

- 在同步模拟步数上限内进入终局
- 四家总分守恒
- 牌墙、手牌、牌河、副露与花牌的总牌张守恒
- 本局分差守恒
- 胡牌只保留当前结算详情；荒庄不保留历史胡牌数据

## 运行

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=2 godot --headless --path . -s scripts/ai_play_round20_check.gd
```
