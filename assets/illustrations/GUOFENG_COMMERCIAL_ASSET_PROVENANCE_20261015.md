# 国风成品视觉资源 · 2026-10-15

这批资源使用 GPT Image API 工作流生成，经原样复制接入游戏。命令观测记录包含显式 `gpt-image-2` 和官方 imagegen 技能 CLI，生成日志记录实际产物；未保存密钥或请求正文。此前 x666 接口的 401 失败保留，后续成功产物来自已授权的 sub2api 调用。

| 运行资源 | 原始生成产物（相对 output/imagegen） | 用途 |
| --- | --- | --- |
| table_scholar_jade_gpt_20261015.png | guofeng_commercial_calm_table_20261015.png | 平视玉绿毡面与周边木框，替换透视错位的旧桌景 |
| menu_jade_ink_gpt_20261015.png | guofeng_commercial_primary_panel_20261015.png | 深墨主行动、当前状态与桌心 |
| shop_item_swap_gpt_20261015.png | guofeng_commercial_items_20261015/guofeng_commercial_item_swap_20261015.png | 换牌环形玉佩 |
| shop_item_peek_gpt_20261015.png | guofeng_commercial_items_20261015/guofeng_commercial_item_peek_20261015.png | 观牌玉坠 |
| shop_item_lucky_gpt_20261015.png | guofeng_commercial_items_20261015/guofeng_commercial_item_lucky_20261015.png | 幸运葫芦 |
| shop_item_double_gpt_20261015.png | guofeng_commercial_items_20261015/guofeng_commercial_item_double_20261015.png | 双倍铜钱 |

六份运行 PNG 与原始生成产物 SHA-256 完全一致，没有程序重画、填色或代码合成。提示词、命令观测摘要、生成日志及逐文件哈希位于 `build/qa/guofeng_commercial_20261015/generation/` 和 `logs/`。原始麻将牌面 `assets/tiles` 保持不变。

页面标题使用 Noto Serif SC 的 600 字重子集，许可证为 SIL Open Font License 1.1。字体来源、原文件和子集哈希见 `assets/fonts/NotoSerifSC-Display.provenance.json`，许可证随字体保存；普通正文及任意玩家名继续使用完整 CJK 字体，标题字体亦设置同一回退。

最后弃牌提示仅复用既有边框位图，移除牌内底片、轨道和徽章；不新增程序绘制装饰。截图审阅 JPEG 位于 `build/qa/ui_review`，仅为 QA 副本，不接入游戏，也不替代原始 PNG/JSON 验收证据。
