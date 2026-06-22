#!/bin/bash
# 自动化代码验证脚本

echo "====== 云桌麻将 v1.0.159 代码验证 ======"
echo ""

SCRIPT_DIR="/root/yunzhuo-mahjong-godot"
MAIN_SCRIPT="$SCRIPT_DIR/scripts/main.gd"
BUILD_DIR="$SCRIPT_DIR/build"
APK_FILE="$BUILD_DIR/YunzhuoMahjongGodot-v1.0.159-godot.apk"
APP_VERSION="1.0.159-godot"

PASS=0
FAIL=0

check_pass() {
    echo "✓ $1"
    ((PASS++))
}

check_fail() {
    echo "✗ $1: $2"
    ((FAIL++))
}

echo "1. 检查关键文件存在性..."
if [ -f "$MAIN_SCRIPT" ]; then
    check_pass "main.gd 存在"
else
    check_fail "main.gd 存在" "文件不存在"
fi

if [ -f "$APK_FILE" ]; then
    check_pass "APK文件存在"
else
    check_fail "APK文件存在" "文件不存在"
fi

echo ""
echo "2. 检查音频文件..."
if [ -f "$SCRIPT_DIR/assets/audio/bgm_loop.wav" ]; then
    check_pass "bgm_loop.wav 存在"
else
    check_fail "bgm_loop.wav 存在" "文件不存在"
fi

for file in discard draw pong kong win; do
    if [ -f "$SCRIPT_DIR/assets/audio/${file}.mp3" ]; then
        check_pass "${file}.mp3 存在"
    else
        check_fail "${file}.mp3 存在" "文件不存在"
    fi
done

echo ""
echo "3. 检查关键代码路径..."

# 检查 wake_audio_from_interaction 函数
if grep -q "func wake_audio_from_interaction" "$MAIN_SCRIPT"; then
    check_pass "wake_audio_from_interaction 函数存在"

    # 检查首次交互同步初始化逻辑
    if grep -A 10 "func wake_audio_from_interaction" "$MAIN_SCRIPT" | grep -q "if not audio_touch_unlocked"; then
        check_pass "首次交互同步初始化逻辑存在"
    else
        check_fail "首次交互同步初始化逻辑" "代码缺失"
    fi
else
    check_fail "wake_audio_from_interaction 函数" "函数不存在"
fi

# 检查 start_background_music 函数
if grep -q "func start_background_music" "$MAIN_SCRIPT"; then
    check_pass "start_background_music 函数存在"
else
    check_fail "start_background_music 函数" "函数不存在"
fi

# 检查 test_audio_setting 函数
if grep -q "func test_audio_setting" "$MAIN_SCRIPT"; then
    check_pass "test_audio_setting 函数存在"

    # 检查是否播放音效测试
    if grep -A 30 "^func test_audio_setting" "$MAIN_SCRIPT" | grep -q "play_sfx"; then
        check_pass "试音功能包含音效测试"
    else
        check_fail "试音功能音效测试" "代码缺失"
    fi
else
    check_fail "test_audio_setting 函数" "函数不存在"
fi

# 检查加载屏幕
if grep -q "func show_loading_screen" "$MAIN_SCRIPT"; then
    check_pass "加载屏幕函数存在"
else
    check_fail "加载屏幕函数" "函数不存在"
fi

# 检查资源延迟加载
if grep -q "_load_tile_textures" "$MAIN_SCRIPT"; then
    check_pass "麻将牌纹理延迟加载逻辑存在"
else
    check_fail "麻将牌纹理延迟加载" "代码缺失"
fi

echo ""
echo "4. 检查APK内容..."
if [ -f "$APK_FILE" ]; then
    # 检查APK中是否包含音频文件
    if unzip -l "$APK_FILE" | grep -q "bgm_loop.wav"; then
        check_pass "APK包含bgm_loop.wav"
    else
        check_fail "APK包含bgm_loop.wav" "文件不在APK中"
    fi

    if unzip -l "$APK_FILE" | grep -q "discard.mp3"; then
        check_pass "APK包含音效文件"
    else
        check_fail "APK包含音效文件" "文件不在APK中"
    fi
fi

echo ""
echo "5. 检查版本号..."
if grep -q "config/version=\"$APP_VERSION\"" "$SCRIPT_DIR/project.godot"; then
    check_pass "版本号正确 (1.0.159)"
else
    check_fail "版本号" "版本号不正确"
fi

echo ""
echo "====== 验证结果 ======"
echo "通过: $PASS"
echo "失败: $FAIL"
echo ""

if [ $FAIL -eq 0 ]; then
    echo "✓ 所有检查通过！v1.0.159 已就绪"
    exit 0
else
    echo "✗ 有 $FAIL 项检查失败，需要修复"
    exit 1
fi
