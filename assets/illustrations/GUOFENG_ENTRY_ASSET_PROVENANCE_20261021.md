# 主菜单业务入口插画 · 2026-10-21

两张插画使用 imagegen 技能提供的官方 `scripts/image_gen.py generate` CLI，通过仓库 `.gateway.env` 配置的 GPT API 网关生成。请求模型为 `gpt-image-2`，质量 `high`，尺寸请求 `1536x832`，格式 PNG。网关实际返回两张 `1716x917` PNG；运行资产逐字节复制原图，没有重画、调色、合成或重采样。密钥不写入日志或本文。

| 运行资源 | 原始 API 产物 | SHA-256 |
| --- | --- | --- |
| `assets/illustrations/menu_entry_online_gpt_20261021.png` | `output/imagegen/home_entries_20261021/online.png` | `12d065fe62be22186af8dac8d12d6c9f9093e61bc74da1f390d70f5c0153bfd1` |
| `assets/illustrations/menu_entry_shop_gpt_20261021.png` | `output/imagegen/home_entries_20261021/shop.png` | `298a205d85a9069d0f43a2d7aa7fdcecfecf642afbd7fd52e1e3e1c0c31afd06` |

最终完整提示词：

- [联机入口：江南桥亭](../../garden-gpt-image-2/prompt/home_online_entry_20261021.md)
- [商店入口：铜钱与玉葫芦](../../garden-gpt-image-2/prompt/home_shop_entry_20261021.md)

两张图均为右侧题材、左侧纸面留白的完整底板，文字由 Godot 原生控件绘制。单机入口的麻将图案直接复用 `assets/tiles` 既有“东”牌，没有生成或修改牌面。

原始生成日志：`build/qa/current_20261021/generate_online_project_r1.log`、`generate_shop_project_r1.log`。第一次访问 `https://x666.me/v1` 返回明确 HTTP 401 / Invalid token，失败日志 `generate_online_x666_r1.log` 原样保留；成功调用使用当前仓库配置的网关。

压缩审阅图与原始 PNG 哈希收据位于 `build/qa/ui_review/current_20261021/assets/`，仅用于审阅。独立审计报告位于 `build/qa/ui_engineer/HOME_ENTRY_ASSET_REVIEW_20261021.md`。生成候选目录 `output/` 通过 `.gdignore` 排除 Godot 导入与游戏资源扫描。
