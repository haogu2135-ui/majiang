# 页面 UI 测试 Agent

执行日期：2026-06-15

## 测试职责

- 针对 Godot 麻将项目的页面与界面布局做可复跑检查，优先覆盖主菜单、单机桌面、设置浮层、行动按钮区、手牌区、弃牌/墙牌/花牌区、座位信息和结算浮层。
- 优先复用现有 `scripts/offline_smoke_test.gd`，使用 headless Godot 加载 `Main.tscn` 后直接验证 UI 节点、尺寸、文案、可点击控件和关键资源。
- 本 Agent 只写入本报告，不修改源码、README、manifest 或 APK。

## 检查项设计

1. 启动与根布局
   - `project.godot` 主场景指向 `res://Main.tscn`，窗口为 1280x720、`canvas_items` stretch、`expand` aspect。
   - `Main.tscn` 根节点为全屏 `Control`，应能在 headless 下实例化并进入单机模式。

2. 单机桌面页面
   - `render_game()` 应绘制顶部 HUD、桌面木纹/毡面、四家座位、牌谱、手牌托盘、行动按钮、设置浮层入口和结算浮层入口。
   - 墙牌应使用固定 `WALL_BACK_TILE_SIZE`，四边总数不少于 56 个固定居中背牌。
   - 花牌条应在座位面板内渲染真实花牌面，并限制最多显示 4 张加余量标记。

3. 牌面组件
   - 字牌、数牌、花牌都应保持调用方传入尺寸，内层按钮/贴图不受原始图片像素尺寸撑开。
   - 牌面应有可见真实贴图，并叠加规范化文字面，如 `东/风`、`5/万`、`春/花`。
   - 可点击手牌和菜单/设置按钮应使用 `button_down` 即时响应，适配移动端触控。

4. 浮层与按钮
   - 设置浮层应渲染 `音乐开`、`快速开`、`试音` 等按钮。
   - 行动栏应只渲染合法响应，不显示已禁用的人类 AI 推荐按钮或推荐徽标。
   - 风险/安全徽标应在牌面中按状态显示，如 `高危`、`安`、`筋`、`壁`。

5. 座位与信息面板
   - 座位头像应使用轻量 2D 节点，不使用 `SubViewport`。
   - 活动座位应显示方位和 `行牌` 状态。
   - 对手威胁徽标、在线反馈、服务器拒绝原因等可见文本应保留。

## 可执行命令

本次使用的 Godot 版本：

```bash
godot --version
```

关键结果：

```text
4.6.3.stable.official.7d41c59c4
```

本次执行的 UI/离线冒烟测试：

```bash
GODOT_SILENCE_ROOT_WARNING=1 godot --headless --path . -s scripts/offline_smoke_test.gd
```

关键结果：

```text
Godot Engine v4.6.3.stable.official.7d41c59c4 - https://godotengine.org
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
```

退出码：`0`

## 通过结果

- `scripts/offline_smoke_test.gd` 本次 headless 执行通过，未出现 `offline smoke test failed`。
- 静态扫描该脚本包含 `459` 处 `check(...)` 断言调用，且包含多处循环资源检查；本次执行覆盖了牌面贴图、音频资源、设置浮层、按钮触控、座位头像、墙牌布局、花牌条、行动栏、风险/安全徽标、在线反馈可见性等 UI 相关断言。
- 当前未发现页面/界面布局断言失败。

## 发现的问题与风险

- 运行结束出现 Godot 清理警告：`ObjectDB instances leaked at exit`。该警告未导致测试失败，暂未定位为页面布局问题，但建议后续在允许改测试或源码时用 `--verbose` 复查泄漏对象来源。
- 本次未生成新截图或 APK，未修改 `build/`、源码、README、manifest。headless 断言能验证节点结构、尺寸、资源和文案，但不能替代真实设备上的像素级截图比对与触控验收。

## 后续复跑建议

- 每次 UI 布局调整后先复跑：

```bash
GODOT_SILENCE_ROOT_WARNING=1 godot --headless --path . -s scripts/offline_smoke_test.gd
```

- 若后续允许新增 QA 脚本，可补充多分辨率 headless 截图检查：1280x720、1920x1080、720x1280，验证主要区域非空、控件无明显重叠、关键文字仍在父容器内。
