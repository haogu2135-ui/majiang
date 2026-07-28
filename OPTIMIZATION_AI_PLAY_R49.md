# AI / 玩法 Round 49 - 和牌物理牌张上限

日期：2026-07-27  
验收：`scripts/ai_play_round49_check.gd`

## 问题

面子递归只判断能否按规则分解，不负责校验牌的物理库存。导入或外部状态若给同一牌五张，仍可能被拆成一副刻子和一对将，并通过公开和牌、荣和或计分入口。

## 修复

- 公开和牌与计分入口统一验证“暗手加固定组”中每种牌不超过四张。
- 计数快照入口还验证计数总数与实际手牌张数一致，拒绝错配快照。
- 已确认完整性的 AI 内部待牌计分继续走 `assume_complete` 路径，不增加 34 张有效牌扫描的热路径成本。

## 资源

只在和牌、荣和和公共计分边界遍历 34 个计数槽与最多四组固定牌；正常弃牌候选与向听搜索不新增循环。

## 运行

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 godot --headless --path . -s scripts/ai_play_round49_check.gd
```
