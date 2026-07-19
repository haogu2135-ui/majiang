#!/usr/bin/env bash
# 一键验证前期 UI 排查问题是否回归。

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPORT="$ROOT_DIR/build/qa/ui_regression_verification_report.md"
LOG_DIR="$ROOT_DIR/build/qa/logs"
TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S %z')"

mkdir -p "$LOG_DIR" "$(dirname "$REPORT")"

PASS=0
FAIL=0
ROWS=()

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

check_no_runtime_leaks() {
	local log_path
	for log_path in "$@"; do
		if rg -n "ObjectDB instances leaked|resources still in use|RIDs of type .* leaked|RID allocations .* leaked|Leaked instance:" "$log_path"; then
			return 1
		fi
	done
	return 0
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

run_check "UI layout regression smoke" "ui_layout_smoke.log" \
	env GODOT_SILENCE_ROOT_WARNING=1 godot --headless --path "$ROOT_DIR" -s scripts/ui_layout_smoke_test.gd

run_check "Offline gameplay smoke" "offline_smoke.log" \
	env GODOT_SILENCE_ROOT_WARNING=1 godot --headless --path "$ROOT_DIR" -s scripts/offline_smoke_test.gd

run_check "Capture UI screenshots 1280x720" "capture_pages_1280x720.log" \
	env GODOT_SILENCE_ROOT_WARNING=1 xvfb-run -a godot --path "$ROOT_DIR" -s scripts/page_screenshot_capture.gd

run_check "Screenshot manifest 1280x720" "manifest_1280x720.log" \
	python3 scripts/ui_screenshot_manifest_check.py

run_check "Capture UI screenshots 960x540" "capture_pages_960x540.log" \
	env GODOT_SILENCE_ROOT_WARNING=1 xvfb-run -a godot --path "$ROOT_DIR" -s scripts/page_screenshot_capture.gd -- --size=960x540

run_check "Screenshot manifest 960x540" "manifest_960x540.log" \
	python3 scripts/ui_screenshot_manifest_check.py \
	--pages-dir build/qa/pages_960x540 \
	--report build/qa/ui_screenshot_manifest_report_960x540.md \
	--expected-size 960x540

run_check "Runtime resource leak scan" "runtime_leak_scan.log" \
	check_no_runtime_leaks \
	"$LOG_DIR/ui_layout_smoke.log" \
	"$LOG_DIR/offline_smoke.log" \
	"$LOG_DIR/capture_pages_1280x720.log" \
	"$LOG_DIR/capture_pages_960x540.log"

STATUS="PASS"
if [ "$FAIL" -ne 0 ]; then
	STATUS="FAIL"
fi

{
	echo "# UI Regression Verification Report"
	echo ""
	echo "- Time: $TIMESTAMP"
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
	echo "| 每日签到七日预告贴底、层级弱 | UI layout smoke + screenshots |"
	echo "| 加载页 GPT 背景上叠 native fallback 矩形 | UI layout smoke + screenshots |"
	echo "| 生成 chrome 伪文字、伪控件、强残影 | UI layout smoke alpha 上限 + screenshots |"
	echo ""
	echo "## Screenshot Artifacts"
	echo ""
	echo "- 1280x720 contact sheet: \`$ROOT_DIR/build/qa/pages/contact_sheet.jpg\`"
	echo "- 960x540 contact sheet: \`$ROOT_DIR/build/qa/pages_960x540/contact_sheet.jpg\`"
	echo "- 1280x720 manifest: \`$ROOT_DIR/build/qa/ui_screenshot_manifest_report.md\`"
	echo "- 960x540 manifest: \`$ROOT_DIR/build/qa/ui_screenshot_manifest_report_960x540.md\`"
	echo ""
	echo "This report is a gate over the known UI regression set. It still complements, rather than replaces, manual visual review for newly introduced aesthetic issues."
} >"$REPORT"

echo ""
echo "wrote $REPORT"
echo "result: $STATUS ($PASS passed, $FAIL failed)"

if [ "$FAIL" -ne 0 ]; then
	exit 1
fi
