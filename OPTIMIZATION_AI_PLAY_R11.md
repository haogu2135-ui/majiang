# AI / 玩法 Round 11 — 副露喂牌修正与包三搭纪律

日期：2026-07-25  
版本：1.0.180  
验收：`scripts/ai_play_round11_check.gd`

## 目标

1. 修复副露后强制弃牌误用点炮摘要、读不到吃碰喂牌详情的问题。
2. AI 弃牌识别同一来源的第三次吃碰杠，避免无谓触发包三搭包赔。
3. 包赔风险按难度、向听、残局和对手威胁缩放，困难档更克制，听牌可适度进攻。
4. 将吃碰来源与包赔归属写入 AI 报告缓存键，防止局内状态变化后复用旧评分。

## 实现

| API / 接线 | 作用 |
|------------|------|
| `human_claim_discipline_report` | 强制弃牌改读 `discard_feed_risk_report`，恢复 `feed_human` 信号 |
| `package_feed_discipline_report` | 评估第三搭责任、对手威胁和攻守取舍 |
| `build_ai_discard_report` | 扣除 `package_feed_penalty` 并输出责任对手与原因 |
| `package_liability_ai_cache_key` | 缓存键包含 `offline_claim_counts` / `offline_package_liability` |

## 运行

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=2 godot --headless --path . -s scripts/ai_play_round11_check.gd
```
