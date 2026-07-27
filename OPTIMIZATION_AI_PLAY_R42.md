# AI / 玩法 Round 42 - 过水与漏胡状态

日期：2026-07-27  
验收：`scripts/ai_play_round42_check.gd`

## 问题

AI 可以为了高价值听口主动放弃荣和，玩家也可以在可胡响应窗选择过；旧状态没有记住这次放弃，同一张牌下一次出现时仍可立即荣和。规则行为与“过水/漏胡”的常见商业玩法不一致。

## 修复

- 新增按座位、按牌张记录的短生命周期过水状态。
- 玩家放弃已展示的胡牌、AI 主动放弃低价值荣和，都会记录该张。
- 响应选项、AI 荣和报告、普通荣和、抢杠胡和最终结算统一拒绝处于过水状态的同张。
- 座位摸到下一张实牌（包括杠后补牌）时自动清除该座位的过水状态。
- 过水不影响自摸，且不影响不同牌张的荣和。

## 资源

状态为每座位一个很小的字典；查询是常数时间，不新增 AI 扫描、缓存或线程负担。

## 运行

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 godot --headless --path . -s scripts/ai_play_round42_check.gd
```
