# AI / 玩法 Round 23 - 座位威胁卡按目标对手给安全牌

日期：2026-07-26  
验收：`scripts/ai_play_round23_check.gd`

## 问题

每个对手座位的威胁卡此前复用了全桌主威胁的安全牌标签和总风险排序。当牌桌存在更强的另一家时，当前卡片不会优先展示自己已打过的现物，安全提示会把两家的信息混在一起。

## 修复

座位威胁卡现在对当前展示的对手单独计算现物、筋、壁与风险；全桌都安全的牌仍保留最高优先级。这样每张卡片的安全牌都对应其自身威胁，而不是误用桌面主威胁的结论。

## 运行

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=2 godot --headless --path . -s scripts/ai_play_round23_check.gd
```
