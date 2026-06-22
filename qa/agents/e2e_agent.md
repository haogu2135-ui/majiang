# E2E 测试 Agent 报告

日期：2026-06-15 UTC

## 测试职责

- 作为 E2E 测试 Agent，负责验证当前 Godot 麻将项目的完整离线对局路径：进入离线模式、发牌、玩家出牌/响应、电脑摸打、吃碰杠胡、计分、续局/重开与终局边界。
- 优先复用 `scripts/offline_smoke_test.gd` 做可执行 headless 场景级 E2E 检查，不修改源码、README、manifest 或 APK。
- 本次只写入本文件记录职责、检查项、执行命令、发现的问题和通过结果。

## 可执行检查项

- 启动与发牌：`Main.tscn` 可实例化，`start_offline()` 可进入离线模式；发牌后真人可出牌；牌墙包含 144 张和 8 张花牌；补花逻辑会补到普通牌且花牌不留在手牌。
- 玩家操作：真人出牌会立即提交到弃牌区；危险牌确认、推荐出牌、AI 辅助提示在离线玩家侧保持禁用；操作栏只展示合法响应。
- 电脑出牌：AI 出牌候选、路线判断、听牌张数、危险度、防守压力、缓存命中与状态变化后的缓存失效均被检查；AI 不会打出手牌中不存在的牌。
- 吃/碰/杠/胡：覆盖真人吃选择、AI 吃选择、碰判断、明杠/加杠/暗杠决策、杠后补牌、抢杠胡、放铳胡、自摸计分与胡牌优先级。
- 胡牌与番种：覆盖普通和牌、七对、十三幺、清一色、混一色、一条龙、断幺九、大三元、小三元、大四喜、小四喜、碰碰胡、字一色、杠上开花、海底捞月、大吊车。
- 结算与续局/重开：覆盖 `finish_offline_round()` 后进入 `ended`；非庄家和牌后庄家轮转、分数保留；庄家和牌连庄且局号不增加；最后一局结束后 `start_next_offline_hand(false)` 不再推进；多次 `start_offline()` 可重置离线路径。
- 资源与 UI 基础链路：覆盖牌面贴图、音频/语音资源加载、设置按钮、动作按钮、牌面按钮、花牌区、墙牌布局和局面摘要。
- 在线状态兼容 smoke：覆盖在线 game state 归一化、claim payload、ack/rejected/message、房间日志、在线弃牌语音去重和语音 payload 基础编码。

## 执行命令

```bash
command -v godot
godot --version
godot --headless --path . -s scripts/offline_smoke_test.gd
```

关键环境结果：

```text
/usr/local/bin/godot
4.6.3.stable.official.7d41c59c4
```

关键测试结果：

```text
Godot Engine v4.6.3.stable.official.7d41c59c4 - https://godotengine.org
WARNING: Started the engine as `root`/superuser. This is a security risk, and subsystems like audio may not work correctly.
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
```

退出码：`0`

## 发现的问题/通过结果

- 通过：`scripts/offline_smoke_test.gd` headless 执行完成，退出码为 `0`，未出现 `offline smoke test failed`，说明脚本内全部 `check()` 断言通过。
- 非阻断警告：以 root 运行 Godot 会输出 superuser 警告；这是当前容器执行环境导致的环境提示，不是游戏逻辑失败。
- 非阻断警告：退出时出现 `ObjectDB instances leaked at exit`。当前 smoke 脚本仍返回 `0`，但建议后续若 CI 把 warning 视为失败，应单独用 `--verbose` 跟踪泄漏对象来源。
- 未覆盖风险：本次为 headless 场景级 E2E，没有安装或修改 APK，也未做真机 Android 触控、真实音频/TTS、服务端联网联调和长时间随机整局游玩压力测试。
