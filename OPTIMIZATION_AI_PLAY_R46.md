# AI / 玩法 Round 46 - 暗杠门清与 AI 明副露语义

日期：2026-07-27  
验收：`scripts/ai_play_round46_check.gd`

## 问题

暗杠被存放在固定副露数组中，旧计分逻辑把任何固定组都视为明副露，导致暗杠和牌错误失去门清。AI 的听牌价值也把暗杠当作明副露，额外压低薄听评价。

## 修复

- 每局保存 `seat -> tile` 的暗杠来源；只有实战 `perform_concealed_gang` 会写入该来源。
- 门清改为“没有明副露”，因此已登记的合法暗杠不破门清；七对与十三幺仍要求没有任何固定组。
- 未登记的四张组按明杠保守处理，兼容旧存档和导入状态，避免虚增番种。
- AI 继续使用所有固定组计算向听，但听牌质量和副露听牌修正只使用明副露数。

## 资源

暗杠来源仅为每座位的短字典。计分和 AI 报告最多遍历四个固定组，不进入 34 张有效牌扫描或额外模拟循环。

## 运行

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 godot --headless --path . -s scripts/ai_play_round46_check.gd
```
