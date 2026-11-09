# 国风美化素材来源 · 2026-10-15

本轮运行素材全部来自仓库既有 `assets/illustrations` 位图。没有新生成图片、调色或重绘牌面，也没有程序绘制 UI 装饰。

| 运行资源 | 原位图 | 原图像素裁切 | 用途 |
| --- | --- | --- | --- |
| `table_calm_crop_20261015.tres` | `table_gpt_backdrop_bright_gpt_r185.png` (1536×864) | x208, y108, w1120, h630 | 单张对战背景聚焦原毡面，减少桌外家具和地毯；按原色显示 |
| `menu_ink_quiet_crop_20261015.tres` | `menu_ink_entry_gpt.png` (1024×1024) | x300, y210, w420, h590 | 主行动、选中状态、桌心、滑块使用原墨面内部，避免整张金角被不同比例拉伸 |

两份 `.tres` 仅声明 `AtlasTexture` 对原图的取景，没有合成、填色、滤镜或新像素。原始 PNG 保持逐字节不变。设置与阅读纸面、商店商品图、月洞园景沿用原素材。

本轮按仓库授权尝试通过 imagegen skill 的内置 CLI 调用 `gpt-image-2`，接口 `https://x666.me/v1` 返回 **HTTP 401 / Invalid token**，没有图像产物。三个提示词草案保存于 `garden-gpt-image-2/prompt/guofeng_*_20261015.md`；它们不能作为新素材已经生成的证据。失败记录见 `build/qa/guofeng_beauty_20261015/generation_attempt.json`，没有保存密钥。

运行资源与原位图的 SHA-256、源码快照、前后截图及测试日志随本轮 QA 归档。牌面 `assets/tiles` 和版本 `1.0.180-godot` 保持原样。
