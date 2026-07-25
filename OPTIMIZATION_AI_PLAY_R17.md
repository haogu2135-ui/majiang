# AI / 玩法 Round 17 - 主威胁筋线校正

日期：2026-07-25  
验收：`scripts/ai_play_round17_check.gd`

## 问题

弃牌安全标签的 `筋` 原先只要对任意一名对手成立就会显示，同时会参与 AI 的全局防守加分。当牌桌存在一名明显的副露高威胁对手时，另一名低威胁对手的筋线可能把对主威胁并不安全的牌误标为安全。

## 修复

存在主威胁时，`is_suji_safe_tile` 只接受该座位提供的筋线；没有明确主威胁时保留原有的任意有效筋线提示。这样 `筋` 的 UI 提示与 AI 防守奖励都对准当前最危险的对手。

## 运行

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=2 godot --headless --path . -s scripts/ai_play_round17_check.gd
```
