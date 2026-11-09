# 国风快捷入口与按钮素材 · 2026-10-25

模型 GPT Image 2；使用 imagegen skill 原版 CLI，提示词 `garden-gpt-image-2/prompt/menu_navigation_seals_20261025.md`。原始输出 `output/imagegen/menu_navigation_seals_20261025.png`；运行副本 `assets/illustrations/menu_navigation_seals_gpt_20261025.png`；QA副本 `build/qa/commercial_polish_20261025/assets/menu_navigation_seals_20261025.png`。三者逐字节相同，实际1536×1024 RGBA，SHA256 `c0802cd5702fac8377a7790c9fac9229355f9d97b4d41c2f9b761147b6383812`。

未做像素绘制、调色、透明化或合成。3×2原图只通过AtlasTexture非破坏性引用：首行书册/奖杯/玉佩，末行日历/空白按钮面/回放卷轴。生成结果的末两格与提示词顺序不同，以实际图像为准。空白按钮面采用Rect2(523,512,490,488)保留边框，其余五格为512×512。

首次调用旧端点返回401 Invalid token，证据 `build/qa/menu_navigation_seals_20261025_r1.log`；仓库当前配置端点成功调用日志 `build/qa/menu_navigation_seals_20261025_r2.log`，耗时33.3秒。端点凭据不记入素材文档。

资产审阅 `build/qa/ui_engineer/NAV_ATLAS_ASSET_20261025_R1.md`；资产可用不等于页面整合签收。原始牌面assets/tiles不重生图、不调色，版本保持1.0.180。
