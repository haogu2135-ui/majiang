# UAT 测试 Agent 记录

测试日期：2026-06-15 UTC

## 测试职责

- 从玩家验收角度验证当前 Godot 版本的人机对战可玩性。
- 重点覆盖玩家方不需要 AI 辅助、背景音乐不是白噪声、打牌流畅性、更新 APK 信息、基础可玩性。
- 只做只读验证和记录，不修改源码、README、manifest、导出预设或 APK。

## 验收场景

1. 人机对战玩家方不需要 AI 辅助
   - 验收点：玩家侧 AI 辅助关闭；人机对战不显示推荐牌、最安牌、备选牌、风险徽标、提示按钮和响应建议；玩家出牌路径不触发辅助计算。
   - 结果：通过。`PLAYER_AI_ASSIST_ENABLED := false`，离线冒烟测试验证 `not scene.player_ai_assist_enabled()`，并覆盖玩家可正常自摸后出牌。

2. 背景音乐不是白噪声
   - 验收点：BGM 使用干净 WAV 循环，不再使用旧 MP3 背景音乐；音量留余量；APK 内包含导入后的 WAV sample。
   - 结果：条件通过。文件级验证显示 `assets/audio/bgm_loop.wav` 是 44.1 kHz、16-bit、mono PCM WAV，导入配置 `compress/mode=0`，冒烟测试验证 BGM 为 `AudioStreamWAV`、循环模式和默认音量余量。当前环境无 Android 真机/扬声器，未做主观听感验收。

3. 打牌流畅性
   - 验收点：玩家点击按下即响应；快速模式延迟较短；AI 连续行牌期间合帧刷新；玩家侧不做 AI 推荐重算。
   - 结果：通过。冒烟测试覆盖 `BaseButton.ACTION_MODE_BUTTON_PRESS`、按钮/手牌 `button_down` 回调、快速模式延迟、80 ms UI 合帧、玩家侧 AI 辅助关闭和缓存复用路径。

4. 更新 APK 信息
   - 验收点：项目版本、manifest 版本、远端 APK 大小和 SHA-256 一致；更新 URL 可访问。
   - 结果：部分通过，有问题需跟进。远端 manifest 为 `1.0.105-godot`，远端 APK `Content-Length=37116161` 且流式 SHA-256 为 `66774aab38e14498ea0b85fb1d70033831dc4e50ad89b32556e4bfd42a19634a`，与本地 manifest 和 `build/YunzhuoMahjongGodot.apk` 一致。但本地缺少导出预设声明的 `build/YunzhuoMahjongGodot-v1.0.105-godot.apk`，且 APK 内打包了旧的 `assets/build/YunzhuoMahjongGodot-update.json`，内容仍是 `1.0.103-godot`。

5. 基础可玩性
   - 验收点：主场景可启动离线桌；牌墙、花牌、摸打、吃碰杠胡、补花、番型和计分基础路径可用。
   - 结果：通过。离线冒烟测试退出码 0，覆盖 144 张含花牌牌墙、玩家出牌、花牌补牌、标准胡、七对、十三幺、大小三元/四喜、断幺、一条龙、抢杠胡、多局/分数等基础路径。

## 执行命令与关键结果

```bash
godot --version
```

结果：`4.6.3.stable.official.7d41c59c4`

```bash
godot --headless --path . --script scripts/offline_smoke_test.gd
```

结果：退出码 0。仅出现 root 运行警告和退出时 ObjectDB leak 警告，未出现测试失败；关键断言覆盖玩家侧 AI 辅助关闭、音频/BGM、操作响应、性能缓存和基础规则。

```bash
godot --headless --path . --scene res://Main.tscn --quit-after 180 -- --offline-preview
```

结果：退出码 0。主场景离线预览入口可启动并在固定帧数后正常退出。

```bash
file assets/audio/bgm_loop.wav assets/audio/discard.mp3 build/YunzhuoMahjongGodot.apk
```

结果：`bgm_loop.wav` 为 `RIFF/WAVE Microsoft PCM, 16 bit, mono 44100 Hz`；APK 为 zip archive。

```bash
sed -n '1,80p' assets/audio/bgm_loop.wav.import
```

结果：BGM 使用 `importer="wav"`、`force/mono=true`、`compress/mode=0`。

```bash
sha256sum build/YunzhuoMahjongGodot.apk build/YunzhuoMahjongGodot-v1.0.42-godot.apk build/YunzhuoMahjongGodot-v1.0.103-godot.apk
```

结果：三者均为 `66774aab38e14498ea0b85fb1d70033831dc4e50ad89b32556e4bfd42a19634a`，与当前本地/远端 manifest 一致。

```bash
curl --max-time 10 -fsS http://129.146.180.88:18081/YunzhuoMahjongGodot-update.json
curl --max-time 10 -fsSI http://129.146.180.88:18081/YunzhuoMahjongGodot.apk
curl --max-time 60 -fsS http://129.146.180.88:18081/YunzhuoMahjongGodot.apk | sha256sum
```

结果：远端 manifest 返回 `version=1.0.105-godot`、`apkSize=37116161`、SHA-256 `66774aab38e14498ea0b85fb1d70033831dc4e50ad89b32556e4bfd42a19634a`；APK HEAD 为 200；流式下载 SHA-256 匹配。

```bash
stat -c '%n %s bytes mtime=%y' build/YunzhuoMahjongGodot-v1.0.105-godot.apk build/YunzhuoMahjongGodot-release.apk
```

结果：`build/YunzhuoMahjongGodot-v1.0.105-godot.apk` 不存在；`build/YunzhuoMahjongGodot-release.apk` 存在但大小为 `34936955`，不是当前 manifest 指向的包。

```bash
unzip -p build/YunzhuoMahjongGodot.apk assets/build/YunzhuoMahjongGodot-update.json
```

结果：APK 内嵌的 `assets/build/YunzhuoMahjongGodot-update.json` 仍为 `version=1.0.103-godot`、旧 `apkSize=37112065`、旧 SHA-256 `2b4427e4f32553ef82175b98f7a3cb2f4f1272bc0b1f1969e4fc9838815adcec`。

## 发现的问题

1. UAT-UPDATE-001：缺少版本化的 1.0.105 APK 文件
   - 严重级别：中
   - 现象：`export_presets.cfg` 的导出路径为 `build/YunzhuoMahjongGodot-v1.0.105-godot.apk`，源码 `UPDATE_FILE_PATH` 也使用 `YunzhuoMahjongGodot-v1.0.105-godot.apk`，但本地 `build/` 中没有该文件。
   - 影响：远端通用下载包可用，但验收/归档/手动分发时找不到与当前版本号一致的 APK 文件，容易误判仍停在 `1.0.103`。

2. UAT-UPDATE-002：APK 内嵌旧 update manifest
   - 严重级别：低到中
   - 现象：`build/YunzhuoMahjongGodot.apk` 内包含 `assets/build/YunzhuoMahjongGodot-update.json`，内容仍是 `1.0.103-godot` 和旧哈希。
   - 影响：当前运行代码使用远端 `UPDATE_MANIFEST_URL`，所以不一定影响在线更新；但 APK 内携带陈旧更新信息，会干扰验收排查，也可能在未来若改用本地兜底 manifest 时导致错误。

## 通过结果

- 人机对战玩家侧无 AI 辅助：通过。
- BGM 资源格式、导入方式、APK 打包路径：条件通过，待 Android 真机听感确认。
- 打牌响应和流畅性回归：通过。
- 主场景离线启动与基础规则可玩性：通过。
- 远端更新 manifest、远端 APK 大小和 SHA-256：通过。
- 更新 APK 本地版本化产物和 APK 内嵌 manifest：未通过，见 UAT-UPDATE-001 和 UAT-UPDATE-002。

## 未覆盖限制

- 未安装 APK 到 Android 真机，因此未验证真实设备上的音频白噪声、扬声器音量、触控手感、系统安装器和权限弹窗。
- 未修改或重导出 APK，所有 APK 检查均为只读校验。
