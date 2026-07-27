# AI / 玩法 Round 43 - 副露语义校验

日期：2026-07-27  
验收：`scripts/ai_play_round43_check.gd`

## 问题

和牌与计分过去只使用副露的数量计算剩余面子数。若导入状态、过期网络状态或错误外部调用写入混杂三张、跨花色“顺子”或四张顺子的畸形副露，结构完整的手牌仍可能被结算为合法和牌。

## 修复

- 新增副露语义验证：仅接受同花色连续三张、同牌三张或同牌四张。
- 普通和牌入口、按计数和牌入口、公开计分入口统一拒绝畸形副露。
- AI 预评分的 `assume_complete` 内部路径不增加扫描；其调用方只处理由状态机产生的已验证副露。

## 资源

一局正常路径最多检查四组、每组四张。只在结算、响应和明确和牌判定边界触发，不增加弃牌枚举和有效张搜索成本。

## 运行

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 godot --headless --path . -s scripts/ai_play_round43_check.gd
```
