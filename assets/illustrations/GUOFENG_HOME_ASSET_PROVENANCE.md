# 国风首页素材来源（2026-10-13）

本轮复用仓库内已有的 illustrations 位图，不生成、重绘或调色麻将牌面。

## 从归档恢复到运行资源目录

归档目录有 `.gdignore`，直接注册归档路径会导致 Godot 无法导入资源。
保留归档规则，将以下两张既有位图逐字节复制到可导入的资源目录：

| 运行文件 | 仓库原文件 | 用途 |
| --- | --- | --- |
| `menu_moonlit_garden_gpt.png` | `_replaced_20260720_r182/menu_hero_gpt_backdrop.png` | 首页月夜园林背景，保留月洞窗与空桌面 |
| `menu_ink_entry_gpt.png` | `_replaced_20260720_r182/ui_dark_scrim.png` | 入席开局主卡、选中设置项、主要关闭按钮及对战中央事实底图 |

两对文件的 SHA-256 分别相同：

```text
6faae0d3da62681e76ffc400aeffa871cfa3c272e9f4e59a32adf9070cc4dcfa  menu_moonlit_garden_gpt.png
fb9575d19609ee19699b71a158368efd70279016ae73f53b1130ff61ae7fb34f  menu_ink_entry_gpt.png
```

运行注册键为 `menu_guofeng_moonlit`、`menu_ink_primary`。
这些文件不是本轮 API 生图产物，也不是代码合成的新位图。

## 继续使用的阅读素材

- `menu_card_readable_gpt_20261006.png`：首页次级卡片、快捷按钮、页脚、设置原生按钮、商店商品行，以及对战顶部／最近牌桌记录的一层纸面。
- `settings_readable_gpt_20261006.png`：设置弹层及商店的一张完整不透明纸面。
- `shop_charm_huan.png`、`shop_charm_kan.png`、`shop_charm_yun.png`、`shop_charm_bei.png`：商店沿用的四种道具位图，本轮未重画或调色。
- 既有 Lucide 图标和原生文字：表达动作、设置状态与键盘焦点，不重画图标系统。

## 未完成的生成请求

本轮另有山水背景和墨玉主卡的提示词草案，保存在
`garden-gpt-image-2/prompt/home_shanshui_20261013.md` 和
`garden-gpt-image-2/prompt/home_jade_entry_20261013.md`。
已授权 GPT 接口返回 HTTP 401，未产出新图片；这些提示词不能作为素材已生成的证据。
本次交付使用上述既有位图，不以程序色块或代码纹理代替失败的生成请求。

源码与素材哈希、最终截图和回归日志由 `build/qa/guofeng_home_20261013/` 保存。
商店阶段的独立证据保存在 `build/qa/guofeng_battle_shop_20261013/`；上述背景、深墨按钮与阅读纸面仍为同一批既有位图，不是新的API产物。
对战阅读区的修改前后与定向验证证据保存在 `build/qa/guofeng_battle_20261013/`；没有重生牌面或新增代码绘制的视觉资源。
