# APP UI 测试 Agent

执行日期：2026-06-15  
工作目录：`/root/yunzhuo-mahjong-godot`

## 测试职责

- 覆盖 Android APP 级 UI 可用性风险：主菜单入口、设置面板、音频按钮、报牌/试音、快速模式、人机对战入口。
- 优先复用 `scripts/offline_smoke_test.gd` 做可执行 headless 检查。
- 对现有 APK 做只读静态校验：包名、版本、权限、签名、ABI、关键 Godot 资源与音频/牌图资源是否打入包内。
- 本轮不修改源码、README、manifest、APK 或导出配置。

## 检查项

- UI/入口：
  - 主菜单存在“单机人机 AI 自动打牌”入口，并能调用 `start_offline()`。
  - 离线人机模式启动后 `mode == "offline"`，玩家发牌后可出牌。
  - 菜单卡、普通按钮、牌按钮、设置按钮使用 `button_down` 触发，适配移动端按下即响应。
- 设置面板：
  - 设置浮层渲染“音乐”“音效”“报牌”“快速”“试音”。
  - 音乐、音效、报牌、快速模式状态可保存并重新加载。
  - 设置按钮按下会唤醒音频启动路径。
- 音频/报牌：
  - BGM 使用 `assets/audio/bgm_loop.wav`，WAV 循环开启，44.1 kHz 单声道，音量留有移动端余量。
  - 音效播放器和一次性音效挂在持久音频层，屏幕重绘不会销毁活跃音效。
  - 触摸交互会设置音频解锁标志。
  - 牌名和动作语音资源可加载，报牌队列能排入中文牌名。
- APK 静态：
  - `build/YunzhuoMahjongGodot.apk` 可由 Android build tools 读取。
  - 包名、版本、权限、签名、ABI、横屏/屏幕支持、Godot 资源、音频资源、牌图资源可检查。
  - 兼容文件名 APK 与主 APK 哈希一致。

## 执行命令与关键结果

```bash
GODOT_SILENCE_ROOT_WARNING=1 godot --headless --path . --script scripts/offline_smoke_test.gd
```

结果：通过，进程退出码 `0`。脚本没有失败输出；退出时有 Godot 警告：`ObjectDB instances leaked at exit`。

```bash
/opt/android-sdk/build-tools/35.0.0/aapt2 dump badging build/YunzhuoMahjongGodot.apk
```

结果：可读取 APK。关键输出：

- `package: name='com.yunzhuo.mahjong' versionCode='103' versionName='1.0.103-godot'`
- `minSdkVersion:'24'`
- `targetSdkVersion:'36'`
- `application-label:'云桌麻将'`
- 权限包含 `ACCESS_NETWORK_STATE`、`INTERNET`、`RECORD_AUDIO`、`REQUEST_INSTALL_PACKAGES`
- 支持 `small`、`normal`、`large`、`xlarge` 屏幕
- 警告：`res/mipmap-anydpi-v26/themed_icon.xml` 被引用但 APK 内不存在

```bash
/opt/android-sdk/build-tools/35.0.0/aapt dump permissions build/YunzhuoMahjongGodot.apk
```

结果：通过，权限为：

- `android.permission.ACCESS_NETWORK_STATE`
- `android.permission.INTERNET`
- `android.permission.RECORD_AUDIO`
- `android.permission.REQUEST_INSTALL_PACKAGES`

```bash
/opt/android-sdk/build-tools/35.0.0/apksigner verify --verbose --print-certs build/YunzhuoMahjongGodot.apk
```

结果：通过。

- `Verifies`
- v2 签名：`true`
- v3 签名：`true`
- 签名者：`CN=Yunzhuo Mahjong, O=Yunzhuo, C=CN`

```bash
/opt/android-sdk/build-tools/35.0.0/aapt dump xmltree build/YunzhuoMahjongGodot.apk AndroidManifest.xml
```

结果：可读取 manifest 树。关键输出：

- `package="com.yunzhuo.mahjong"`
- `android:versionCode = 0x67`，即 `103`
- `android:versionName = "1.0.103-godot"`
- `android:screenOrientation = 0xb`
- `android:allowBackup = false`
- `android:resizeableActivity = true`
- Godot 版本元数据：`4.6.3.stable`
- 渲染方式元数据：`mobile`

```bash
zipinfo -1 build/YunzhuoMahjongGodot.apk | rg '^lib/' | sort | uniq
```

结果：通过，仅包含 arm64-v8a 原生库：

- `lib/arm64-v8a/libc++_shared.so`
- `lib/arm64-v8a/libgodot_android.so`

```bash
zipinfo -1 build/YunzhuoMahjongGodot.apk | rg -c '^assets/assets/audio/voice/.*\.mp3\.import$'
zipinfo -1 build/YunzhuoMahjongGodot.apk | rg -c '^assets/assets/tiles/.*\.png\.import$'
zipinfo -1 build/YunzhuoMahjongGodot.apk | rg -c '^assets/scripts/main\.gdc$|^assets/Main\.tscn\.remap$|^assets/project\.binary$'
```

结果：通过。

- 语音导入资源计数：`49`
- 牌图导入资源计数：`43`
- 主脚本、主场景 remap、Godot project binary 计数：`3`

```bash
sha256sum build/YunzhuoMahjongGodot.apk build/YunzhuoMahjong.apk build/YunzhuoMahjongGodot-v1.0.42-godot.apk build/YunzhuoMahjongGodot-v1.0.103-godot.apk
```

结果：通过，四个 APK 哈希一致：

- `66774aab38e14498ea0b85fb1d70033831dc4e50ad89b32556e4bfd42a19634a`

```bash
find build -maxdepth 1 -type f -name 'YunzhuoMahjongGodot-v1.0.105-godot.apk' -printf '%p\n'
```

结果：未找到输出。

## 通过结果

- `scripts/offline_smoke_test.gd` 覆盖的 UI、设置、音频、人机入口、按钮响应、牌面渲染、离线人机流程、AI 行牌/响应等检查通过。
- APK 可读取、可验签，主 APK 与兼容命名 APK 哈希一致。
- APK 内包含 Godot 主资源、主脚本、主场景 remap、BGM、语音导入资源和牌图导入资源。
- Android 权限与当前功能面相符：网络更新、录音/语音能力、安装更新包。

## 发现的问题

1. 当前 APK 版本落后于项目配置。
   - `project.godot`、`export_presets.cfg`、`scripts/main.gd` 当前为 `1.0.105-godot` / `versionCode=105`。
   - `build/YunzhuoMahjongGodot.apk` 静态读取为 `versionName='1.0.103-godot'` / `versionCode='103'`。
   - `build/YunzhuoMahjongGodot-v1.0.105-godot.apk` 不存在。
   - 结论：当前构建目录里的 APK 不是本轮项目配置对应的 1.0.105 导出产物。若要发布 1.0.105，需要重新导出并复跑 APK 静态校验。

2. `aapt2 dump badging` 报 themed icon 引用警告。
   - 警告内容：`res/mipmap-anydpi-v26/themed_icon.xml` 被引用但 APK 内不存在。
   - 影响：可能影响 Android themed icon 展示；不影响本轮 headless smoke 与签名校验通过。

3. `aapt dump badging` 使用旧 `aapt` 时返回非零退出码。
   - 错误内容：`failed to read attribute 'android:required': attribute is not an integer value`。
   - 交叉检查：`aapt2 dump badging` 与 `aapt dump xmltree` 可读取包信息和 manifest，因此本轮静态检查以 `aapt2`/`xmltree` 结果为准。

## 未覆盖范围

- 本轮未连接 Android 真机或模拟器，未做实际触摸、截图、扬声器播放、系统 TTS 初始化、安装后启动验证。
- 本轮未重新导出 APK，也未修改任何源码或打包配置。
