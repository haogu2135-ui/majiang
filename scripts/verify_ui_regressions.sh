#!/usr/bin/env bash
# 一键验证前期 UI 排查问题是否回归。

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_BIN="${GODOT_BIN:-godot}"
EXPECTED_GODOT_VERSION_PREFIX="${EXPECTED_GODOT_VERSION_PREFIX:-4.6.3}"
REPORT="$ROOT_DIR/build/qa/ui_regression_verification_report.md"
LOG_DIR="$ROOT_DIR/build/qa/logs"
TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S %z')"
REVISION="$(git -C "$ROOT_DIR" rev-parse --short HEAD 2>/dev/null || printf 'unknown')"
WORKTREE_STATE="clean"
RUNTIME_SOURCE_STATE="clean"
if [ -n "$(git -C "$ROOT_DIR" status --porcelain 2>/dev/null)" ]; then
	WORKTREE_STATE="dirty"
fi
if [ -n "$(git -C "$ROOT_DIR" status --porcelain -- project.godot scripts/main_base.gd scripts/main.gd scripts/main_src scripts/ui 2>/dev/null)" ]; then
	RUNTIME_SOURCE_STATE="dirty"
fi

mkdir -p "$LOG_DIR" "$(dirname "$REPORT")"

PASS=0
FAIL=0
ROWS=()
GODOT_TIMEOUT_SECONDS=180
GODOT_KILL_GRACE_SECONDS=15
RUNTIME_CLEAR_RETRIES=20
RUNTIME_CLEAR_RETRY_SECONDS=0.25

active_godot_processes() {
	local active
	active="$(
		{
				pgrep -ia '^godot' 2>/dev/null || true
			pgrep -ax Xvfb 2>/dev/null || true
			pgrep -af '(^|/)[x]vfb-run([[:space:]]|$)' 2>/dev/null || true
		} | while IFS= read -r process_line; do
			[ -n "$process_line" ] || continue
			local process_pid="${process_line%% *}"
			local process_state
			process_state="$(ps -o stat= -p "$process_pid" 2>/dev/null | awk '{print $1}')"
			case "$process_state" in
				""|Z*) continue ;;
			esac
			printf '%s\n' "$process_line"
			done
	)"
	printf '%s' "$active"
}

ensure_no_active_godot() {
	local active=""
	local attempt
	for attempt in $(seq 0 "$RUNTIME_CLEAR_RETRIES"); do
		active="$(active_godot_processes)"
		if [ -z "$active" ]; then
			return 0
		fi
		if [ "$attempt" -lt "$RUNTIME_CLEAR_RETRIES" ]; then
			sleep "$RUNTIME_CLEAR_RETRY_SECONDS"
		fi
	done
	echo "Refusing to start QA while another Godot/Xvfb process is active:" >&2
	echo "$active" >&2
	return 1
}

run_low_resource_godot() {
	if ! ensure_no_active_godot; then
		return 1
	fi
	timeout --foreground --signal=TERM --kill-after="${GODOT_KILL_GRACE_SECONDS}s" "${GODOT_TIMEOUT_SECONDS}s" \
		env GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 \
		nice -n 10 ionice -c 2 -n 7 "$GODOT_BIN" "$@"
}

run_low_resource_xvfb_godot() {
	local screen_size="$1"
	shift
	if ! ensure_no_active_godot; then
		return 1
	fi
	timeout --foreground --signal=TERM --kill-after="${GODOT_KILL_GRACE_SECONDS}s" "${GODOT_TIMEOUT_SECONDS}s" \
		env GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 \
		nice -n 10 ionice -c 2 -n 7 xvfb-run -a -s "-screen 0 ${screen_size}x24" \
			"$GODOT_BIN" --rendering-driver opengl3 --audio-driver Dummy "$@"
}

check_target_godot_version() {
	local version
	command -v "$GODOT_BIN" >/dev/null 2>&1 || return 1
	version="$("$GODOT_BIN" --version 2>/dev/null | head -n 1)"
	printf '%s\n' "$version"
	[[ "$version" == "$EXPECTED_GODOT_VERSION_PREFIX"* ]]
}

capture_pages_for_size() {
	local screen_size="$1"
	run_low_resource_xvfb_godot "$screen_size" --path "$ROOT_DIR" -s scripts/page_screenshot_capture.gd -- \
		--size="$screen_size" \
		--screens=01_menu,02_menu_settings,03_offline_battle,04_rules,05_stats || return 1
	run_low_resource_xvfb_godot "$screen_size" --path "$ROOT_DIR" -s scripts/page_screenshot_capture.gd -- \
		--size="$screen_size" \
		--screens=06_achievements,07_shop,08_online_lobby,09_daily_login,10_loading,23_online_lobby_connected,24_online_lobby_disconnect_recovery || return 1
	run_low_resource_xvfb_godot "$screen_size" --path "$ROOT_DIR" -s scripts/page_screenshot_capture.gd -- \
		--size="$screen_size" \
		--screens=13_round_summary,14_danger_discard,15_pending_claim_full,16_win_detail,21_diagnostic
}

run_check() {
	local name="$1"
	local log_name="$2"
	shift 2
	local log_path="$LOG_DIR/$log_name"

	echo "==> $name"
	if (cd "$ROOT_DIR" && "$@") >"$log_path" 2>&1; then
		echo "PASS: $name"
		ROWS+=("| $name | PASS | \`$log_path\` |")
		PASS=$((PASS + 1))
	else
		local exit_code=$?
		echo "FAIL: $name (exit $exit_code)"
		ROWS+=("| $name | FAIL | \`$log_path\` |")
		FAIL=$((FAIL + 1))
	fi
}

# scan_absent PATTERN TARGET...
# Passes (0) only when the scan actually ran and found nothing. A missing
# scanner, a missing target, or any grep error fails (1) instead of reporting
# a clean result: these gates must never pass without having scanned.
scan_absent() {
	local pattern="$1"
	shift
	if ! command -v grep >/dev/null 2>&1; then
		echo "scan tool unavailable: grep not found; refusing to report a clean scan" >&2
		return 1
	fi
	local target
	for target in "$@"; do
		if [ ! -e "$target" ]; then
			echo "scan target missing: $target; refusing to report a clean scan" >&2
			return 1
		fi
	done
	# grep -rnE: 0 = matched (regression present), 1 = clean, 2+ = scan error.
	local status=0
	grep -rnE "$pattern" "$@" || status=$?
	case "$status" in
		0) return 1 ;;
		1) return 0 ;;
		*)
			echo "scan failed with grep status $status; refusing to report a clean scan" >&2
			return 1
			;;
	esac
}

check_no_runtime_leaks() {
	scan_absent "ObjectDB instances leaked|resources still in use|RIDs of type .* leaked|RID allocations .* leaked|Leaked instance:" "$@"
}

check_no_runtime_errors() {
	scan_absent '^(SCRIPT )?ERROR:' "$@"
}

check_no_runtime_generated_bitmap_textures() {
	scan_absent '\bImage\.(new|create)|ImageTexture\.create_from_image' \
		"$ROOT_DIR/scripts/main_base.gd" \
		"$ROOT_DIR/scripts/main_src" \
		"$ROOT_DIR/scripts/ui"
}

run_check "Python QA tools compile" "py_compile.log" \
	python3 -m py_compile \
	tools/assemble_main.py \
	scripts/ui_screenshot_manifest_check.py

if [ -f "$ROOT_DIR/tools/generate_grok_image.py" ]; then
	run_check "Optional Grok image tool compile" "generate_grok_image_py_compile.log" \
		python3 -m py_compile tools/generate_grok_image.py
fi

run_check "main_src part legality" "assemble_check.log" \
	python3 tools/assemble_main.py --check

run_check "main.gd generated output parity" "assemble_verify.log" \
	python3 tools/assemble_main.py --verify

run_check "Git whitespace check" "git_diff_check.log" \
	git diff --check

run_check "Runtime UI uses imported bitmap assets only" "runtime_bitmap_policy.log" \
	check_no_runtime_generated_bitmap_textures

run_check "Target Godot engine is 4.6.3" "godot_version.log" \
	check_target_godot_version

run_check "UI layout regression smoke" "ui_layout_smoke.log" \
	run_low_resource_godot --headless --path "$ROOT_DIR" -s scripts/ui_layout_smoke_test.gd

run_check "UI hover pressed focus and connected-lobby smoke" "ui_interaction_smoke.log" \
	run_low_resource_xvfb_godot 960x540 --path "$ROOT_DIR" -s scripts/ui_interaction_smoke_test.gd

run_check "Offline gameplay smoke" "offline_smoke.log" \
	run_low_resource_godot --headless --path "$ROOT_DIR" -s scripts/offline_smoke_test.gd

run_check "Capture UI screenshots 1280x720 (3 serial batches)" "capture_pages_1280x720.log" \
	capture_pages_for_size 1280x720

run_check "Screenshot manifest 1280x720" "manifest_1280x720.log" \
	python3 scripts/ui_screenshot_manifest_check.py

run_check "Capture UI screenshots 960x540 (3 serial batches)" "capture_pages_960x540.log" \
	capture_pages_for_size 960x540

run_check "Screenshot manifest 960x540" "manifest_960x540.log" \
	python3 scripts/ui_screenshot_manifest_check.py \
	--pages-dir build/qa/pages_960x540 \
	--report build/qa/ui_screenshot_manifest_report_960x540.md \
	--expected-size 960x540

run_check "Capture UI screenshots 1920x1080 (3 serial batches)" "capture_pages_1920x1080.log" \
	capture_pages_for_size 1920x1080

run_check "Screenshot manifest 1920x1080" "manifest_1920x1080.log" \
	python3 scripts/ui_screenshot_manifest_check.py \
	--pages-dir build/qa/pages_1920x1080 \
	--report build/qa/ui_screenshot_manifest_report_1920x1080.md \
	--expected-size 1920x1080

run_check "Runtime resource leak scan" "runtime_leak_scan.log" \
	check_no_runtime_leaks \
	"$LOG_DIR/ui_layout_smoke.log" \
	"$LOG_DIR/ui_interaction_smoke.log" \
	"$LOG_DIR/offline_smoke.log" \
	"$LOG_DIR/capture_pages_1280x720.log" \
	"$LOG_DIR/capture_pages_960x540.log" \
	"$LOG_DIR/capture_pages_1920x1080.log"

run_check "Runtime error log scan" "runtime_error_scan.log" \
	check_no_runtime_errors \
	"$LOG_DIR/ui_layout_smoke.log" \
	"$LOG_DIR/ui_interaction_smoke.log" \
	"$LOG_DIR/offline_smoke.log" \
	"$LOG_DIR/capture_pages_1280x720.log" \
	"$LOG_DIR/capture_pages_960x540.log" \
	"$LOG_DIR/capture_pages_1920x1080.log"

STATUS="PASS"
if [ "$FAIL" -ne 0 ]; then
	STATUS="FAIL"
fi

{
	echo "# UI Regression Verification Report"
	echo ""
	echo "- Time: $TIMESTAMP"
	echo "- Git revision: \`$REVISION\`"
	echo "- Worktree state: $WORKTREE_STATE"
	echo "- Runtime source vs HEAD: $RUNTIME_SOURCE_STATE"
	echo "- Godot binary: \`$GODOT_BIN\`"
	echo "- Required Godot version: \`$EXPECTED_GODOT_VERSION_PREFIX\`"
	echo "- Result: $STATUS"
	echo "- Passed checks: $PASS"
	echo "- Failed checks: $FAIL"
	echo ""
	echo "## Gates"
	echo ""
	echo "| Gate | Result | Log |"
	echo "|---|---|---|"
	for row in "${ROWS[@]}"; do
		echo "$row"
	done
	echo ""
	echo "## Previous Findings Covered"
	echo ""
	echo "| Previous UI finding | Automated gate |"
	echo "|---|---|"
	echo "| 主菜单版本 chip 小屏截断 | UI layout smoke + 960x540 screenshot manifest |"
	echo "| 设置页 header、overview、正文密度互相挤压 | UI layout smoke + 960x540 screenshot manifest |"
	echo "| 单机对战 action dock、手牌托盘、AI 缩略卡拥挤 | UI layout smoke + offline smoke + screenshots |"
	echo "| 规则页正文过密、滚动槽亮、牌型示例像装饰图 | UI layout smoke + offline smoke + screenshots |"
	echo "| 统计页 summary 单位和明细单位不一致 | UI layout smoke + offline smoke |"
	echo "| 成就页目标、进度、状态 lane 压缩 | UI layout smoke + screenshots |"
	echo "| 商店库存、购买 CTA、滚动槽小屏间距不足 | UI layout smoke + offline smoke + screenshots |"
	echo "| 联机大厅未连接状态重复 raw endpoint，主按钮语义不清 | UI layout smoke + offline smoke |"
	echo "| 联机大厅 hover/pressed/focus 与已连接房间状态缺少证据 | Xvfb interaction smoke + 23_online_lobby_connected 三分辨率截图 |"
	echo "| 联机对局断线后停留空游戏页、昵称丢失或错误提示不可见 | online protocol smoke + 24_online_lobby_disconnect_recovery 三分辨率截图 |"
	echo "| 每日签到七日预告贴底、层级弱 | UI layout smoke + screenshots |"
	echo "| 加载页 GPT 背景上叠 native fallback 矩形 | UI layout smoke + screenshots |"
	echo "| 生成 chrome 伪文字、伪控件、强残影 | UI layout smoke alpha 上限 + screenshots |"
	echo "| pending claim 上下文过小且远离操作栏 | UI layout smoke + 15_pending_claim_full 三分辨率截图 |"
	echo "| 每日签到 CTA 层级和退出路径 | UI layout smoke + 09_daily_login 三分辨率截图 |"
	echo "| AI 节奏/难度枚举误显示布尔状态 | UI layout smoke + 02_menu_settings 三分辨率截图 |"
	echo "| 规则滚动条触控命中过窄 | UI layout smoke 44px hit target + 04_rules 三分辨率截图 |"
	echo "| 结算、危险弃牌、完整响应、胡牌详情缺正式证据 | 13～16 三分辨率截图 + manifest |"
	echo "| 位图导入缓存缺失时运行时 ImageTexture 兜底并刷资源错误 | imported bitmap policy + runtime error log scan |"
	echo ""
	echo "## Screenshot Artifacts"
	echo ""
	echo "- 1280x720 contact sheet: \`$ROOT_DIR/build/qa/pages/contact_sheet.jpg\`"
	echo "- 960x540 contact sheet: \`$ROOT_DIR/build/qa/pages_960x540/contact_sheet.jpg\`"
	echo "- 1920x1080 contact sheet: \`$ROOT_DIR/build/qa/pages_1920x1080/contact_sheet.jpg\`"
	echo "- 1280x720 manifest: \`$ROOT_DIR/build/qa/ui_screenshot_manifest_report.md\`"
	echo "- 960x540 manifest: \`$ROOT_DIR/build/qa/ui_screenshot_manifest_report_960x540.md\`"
	echo "- 1920x1080 manifest: \`$ROOT_DIR/build/qa/ui_screenshot_manifest_report_1920x1080.md\`"
	echo ""
	echo "This report is a gate over the known UI regression set. It still complements, rather than replaces, manual visual review for newly introduced aesthetic issues."
} >"$REPORT"

echo ""
echo "wrote $REPORT"
echo "result: $STATUS ($PASS passed, $FAIL failed)"

if [ "$FAIL" -ne 0 ]; then
	exit 1
fi
