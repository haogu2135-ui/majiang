#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEFAULT_RELEASE_APK="$ROOT_DIR/build/qa/YunzhuoMahjongGodot-v1.0.180-commercial-sdk36.apk"
DEFAULT_UNSIGNED_DEBUG_APK="$ROOT_DIR/build/qa/YunzhuoMahjongGodot-v1.0.180-debug-sdk36-current.apk"
PACKAGE="com.yunzhuo.mahjong"
REPORT_DIR="$ROOT_DIR/build/qa/android_device_smoke"
REPORT="$REPORT_DIR/EVIDENCE_LATEST.md"
ADB_BIN="${ADB_BIN:-}"
if [ -z "$ADB_BIN" ]; then
	if [ -x /usr/bin/adb ]; then
		ADB_BIN="/usr/bin/adb"
	elif [ -x /opt/android-sdk/platform-tools/adb ]; then
		ADB_BIN="/opt/android-sdk/platform-tools/adb"
	else
		ADB_BIN="adb"
	fi
fi

STATUS="FAIL"
FAIL_REASON="not started"
APK=""
MODE="signed-release"
SERIAL="${ANDROID_SERIAL:-}"
DISPLAY_SIZE="unknown"
SAFE_AREA_LINE="not collected"
SAFE_AREA_APP_LINE="not collected"
SAFE_AREA_COMPARISON="not collected"
NAVIGATION_MODE="unknown"
IME_VISIBLE="not collected"
RULES_SCROLL_RESULT="not collected"
ONLINE_SCROLL_RESULT="not collected"
PAGE_READY_RESULTS=()
declare -A PAGE_READY_LAST_MSEC=()
CAPTURES=()
CAPTURE_METADATA=()
ADB=()

fail() {
	FAIL_REASON="$*"
	exit 1
}

write_report() {
	mkdir -p "$REPORT_DIR"
	{
		echo "# Android Device Smoke Evidence"
		echo
		echo "- Time: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
		echo "- Result: $STATUS"
		echo "- Package: \`$PACKAGE\`"
		echo "- Mode: \`$MODE\`"
		echo "- APK: \`$APK\`"
		echo "- ADB: \`$ADB_BIN\`"
		echo "- Device serial: \`${SERIAL:-none}\`"
		echo "- Display size: \`$DISPLAY_SIZE\`"
		echo "- Safe-area evidence: $SAFE_AREA_LINE"
		echo "- App safe-area marker: $SAFE_AREA_APP_LINE"
		echo "- Safe-area comparison: $SAFE_AREA_COMPARISON"
		echo "- Navigation mode: \`$NAVIGATION_MODE\`"
		echo "- IME visible after field tap: $IME_VISIBLE"
		echo "- Rules scroll result: $RULES_SCROLL_RESULT"
		echo "- Lobby scroll result: $ONLINE_SCROLL_RESULT"
		if [ "$STATUS" = "PASS" ]; then
			echo "- Checks: install, launch, page markers, exact screenshot dimensions, parsed system/app safe-area, rules single-finger swipe with offset change, settings/rules/lobby/offline return, gesture-nav edge-back when applicable, lobby IME show/dismiss"
		else
			echo "- Failure: $FAIL_REASON"
		fi
		echo
		echo "## Captures"
		echo
		if [ "${#CAPTURES[@]}" -eq 0 ]; then
			echo "No captures were completed."
		else
			for capture in "${CAPTURES[@]}"; do
				echo "- \`$capture\`"
			done
		fi
		if [ "${#CAPTURE_METADATA[@]}" -gt 0 ]; then
			echo
			echo "## Capture dimensions"
			echo
		for metadata in "${CAPTURE_METADATA[@]}"; do
				echo "- $metadata"
			done
		fi
		if [ "${#PAGE_READY_RESULTS[@]}" -gt 0 ]; then
			echo
			echo "## Page-ready bounds"
			echo
		for result in "${PAGE_READY_RESULTS[@]}"; do
			echo "- $result"
		done
		fi
		echo
		echo "This gate requires a physical or explicitly authorized Android device. A localhost desktop/Xvfb run cannot satisfy it."
	} > "$REPORT"
}
trap write_report EXIT

usage() {
	cat <<EOF
Usage:
  $(basename "$0") [SIGNED_RELEASE_APK]
  $(basename "$0") --unsigned-debug [UNSIGNED_DEBUG_APK]
  $(basename "$0") --self-test

The device gate requires exactly one connected adb device. Set ANDROID_SERIAL
when more than one authorized device is available.
EOF
}

self_test() {
	command -v python3 >/dev/null 2>&1 || fail "python3 not found"
	python3 - <<'PY'
from PIL import Image, ImageStat
print("PASS: Pillow image validation available")
PY
	[ -n "$PACKAGE" ] || fail "package name is empty"
	[ "$DEFAULT_UNSIGNED_DEBUG_APK" != "$DEFAULT_RELEASE_APK" ] || fail "APK defaults must remain distinct"
	grep -q 'UI_QA_MARKER' "$ROOT_DIR/scripts/main.gd" || fail "generated runtime is missing Android UI QA markers"
	grep -q 'emit_ui_qa_marker' "$ROOT_DIR/scripts/main_src/core.gd.part" || fail "runtime marker helper is missing"
	grep -q 'page_ready' "$ROOT_DIR/scripts/main_src/core.gd.part" || fail "runtime page-ready marker is missing"
	grep -q 'ready_msec' "$ROOT_DIR/scripts/main_src/core.gd.part" || fail "runtime page-ready freshness token is missing"
	for required_function in wait_for_page wait_for_page_ready wait_for_marker_payload wait_for_scroll_ready wait_for_touch_drag tap_page_ready_node; do
		declare -F "$required_function" >/dev/null || fail "device gate helper is missing: $required_function"
	done
	echo "PASS: Android device smoke self-test"
}

ui_log() {
	"${ADB[@]}" logcat -d -v brief 2>/dev/null | tr -d '\r'
}

wait_for_marker() {
	local marker="$1"
	local description="$2"
	for _ in $(seq 1 30); do
		if ui_log | grep -Fq "UI_QA_MARKER|$marker"; then
			return 0
		fi
		sleep 1
	done
	fail "UI state marker not observed for $description: UI_QA_MARKER|$marker"
}

latest_marker_payload() {
	local prefix="$1"
	ui_log | sed -n "s/.*UI_QA_MARKER|${prefix}\\(.*\\)/\\1/p" | tail -n 1
}

wait_for_safe_area_marker() {
	local payload=""
	for _ in $(seq 1 30); do
		payload="$(latest_marker_payload 'safe_area|')"
		if [ -n "$payload" ]; then
			SAFE_AREA_APP_LINE="$payload"
			return 0
		fi
		sleep 1
	done
	fail "app safe-area marker was not observed"
}

latest_scroll_payload() {
	local page="$1"
	ui_log | sed -n "s/.*UI_QA_MARKER|scroll|${page}|\\([0-9-][0-9-]*|[0-9-][0-9-]*\\).*/\\1/p" | tail -n 1
}

wait_for_scroll_change() {
	local page="$1"
	local before="$2"
	local after=""
	for _ in $(seq 1 30); do
		after="$(latest_scroll_payload "$page")"
		if [ -n "$after" ] && [ "$after" != "$before" ]; then
			printf '%s' "$after"
			return 0
		fi
		sleep 1
	done
	fail "$page single-finger swipe did not change the reported scroll offset (before=${before:-none}, after=${after:-none})"
}

wait_for_focus() {
	local focus=""
	for _ in $(seq 1 20); do
		focus="$("${ADB[@]}" shell dumpsys window windows 2>/dev/null | tr -d '\r' | grep -m1 -E 'mCurrentFocus=|mFocusedApp=' || true)"
		if [[ "$focus" == *"$PACKAGE"* ]]; then
			return 0
		fi
		sleep 1
	done
	fail "app did not become the focused window: ${focus:-no focus line}"
}

capture_screen() {
	local name="$1"
	local path="$REPORT_DIR/$name.png"
	if ! "${ADB[@]}" exec-out screencap -p > "$path"; then
		fail "screencap failed for $name"
	fi
	[ -s "$path" ] || fail "empty screenshot for $name"
	local metadata=""
	if ! metadata="$(python3 - "$path" "$SCREEN_W" "$SCREEN_H" <<'PY'
import sys
from PIL import Image, ImageStat

with Image.open(sys.argv[1]) as image:
    rgba = image.convert("RGBA")
    expected_width = int(sys.argv[2])
    expected_height = int(sys.argv[3])
    if rgba.width != expected_width or rgba.height != expected_height:
        raise SystemExit(f"screenshot dimensions {rgba.width}x{rgba.height} != device {expected_width}x{expected_height}")
    if rgba.width < 2 or rgba.height < 2:
        raise SystemExit("screenshot has invalid dimensions")
    stddev = ImageStat.Stat(rgba.convert("L")).stddev[0]
    if stddev < 4.0:
        raise SystemExit("screenshot is near blank")
    if rgba.getchannel("A").getextrema()[1] == 0:
        raise SystemExit("screenshot is fully transparent")
print(f"{rgba.width}x{rgba.height}, grayscale_stddev={stddev:.2f}")
PY
)"; then
		fail "invalid or blank screenshot for $name"
	fi
	CAPTURES+=("$path")
	CAPTURE_METADATA+=("$name: $metadata")
}

tap_percent() {
	local x_percent="$1"
	local y_percent="$2"
	local x=$((SCREEN_W * x_percent / 100))
	local y=$((SCREEN_H * y_percent / 100))
	"${ADB[@]}" shell input tap "$x" "$y" >/dev/null
}

swipe_percent() {
	local x1_percent="$1"
	local y1_percent="$2"
	local x2_percent="$3"
	local y2_percent="$4"
	local duration_ms="${5:-700}"
	local x1=$((SCREEN_W * x1_percent / 100))
	local y1=$((SCREEN_H * y1_percent / 100))
	local x2=$((SCREEN_W * x2_percent / 100))
	local y2=$((SCREEN_H * y2_percent / 100))
	"${ADB[@]}" shell input swipe "$x1" "$y1" "$x2" "$y2" "$duration_ms" >/dev/null
}

wait_for_page() {
	local expected="$1"
	local description="$2"
	local current=""
	for _ in $(seq 1 30); do
		current="$(latest_marker_payload 'page|')"
		if [ "$current" = "$expected" ]; then
			return 0
		fi
		sleep 1
	done
	fail "page marker did not settle on $description: expected=$expected actual=${current:-none}"
}

wait_for_marker_payload() {
	local prefix="$1"
	local expected="$2"
	local description="$3"
	local current=""
	for _ in $(seq 1 30); do
		current="$(latest_marker_payload "$prefix")"
		if [ "$current" = "$expected" ]; then
			return 0
		fi
		sleep 1
	done
	fail "UI marker did not settle on $description: expected=$expected actual=${current:-none}"
}

wait_for_scroll_ready() {
	local page="$1"
	local payload=""
	local range=""
	for _ in $(seq 1 30); do
		payload="$(latest_scroll_payload "$page")"
		range="${payload##*|}"
		if [ -n "$payload" ] && [[ "$range" =~ ^[0-9]+$ ]] && [ "$range" -gt 0 ]; then
			printf '%s' "$payload"
			return 0
		fi
		sleep 1
	done
	fail "$page did not expose a positive scroll range: ${payload:-none}"
}

wait_for_touch_drag() {
	local page="$1"
	for _ in $(seq 1 30); do
		if ui_log | grep -Fq "UI_QA_MARKER|touch_drag|$page|"; then
			return 0
		fi
		sleep 1
	done
	fail "$page did not report a single-finger drag marker"
}

wait_for_page_ready() {
	local page="$1"
	local description="$2"
	shift 2
	local payload=""
	local previous_msec="${PAGE_READY_LAST_MSEC[$page]:-0}"
	for _ in $(seq 1 45); do
		payload="$(latest_marker_payload "page_ready|${page}|")"
		if [ -n "$payload" ]; then
			if python3 - "$payload" "$SCREEN_W" "$SCREEN_H" "$SAFE_AREA_APP_LINE" "$previous_msec" "$@" <<'PY'
import re
import sys

payload, screen_w, screen_h, safe_payload, previous_msec = sys.argv[1:6]
required = sys.argv[6:]
screen_w = float(screen_w)
screen_h = float(screen_h)
previous_msec = int(previous_msec)
safe = [float(value) for value in safe_payload.split("|")]
if len(safe) != 6:
    raise SystemExit("app safe-area marker must contain four margins and viewport size")
app_left, app_top, app_right, app_bottom, viewport_w, viewport_h = safe
if viewport_w <= 0 or viewport_h <= 0:
    raise SystemExit("app safe-area viewport is invalid")
root_match = re.search(r"(?:^|\|)root=(-?[0-9.]+),(-?[0-9.]+),([0-9.]+),([0-9.]+)", payload)
viewport_match = re.search(r"(?:^|\|)viewport=([0-9.]+),([0-9.]+)", payload)
nodes_match = re.search(r"(?:^|\|)nodes=(.*?)(?:\|missing=|$)", payload)
missing_match = re.search(r"(?:^|\|)missing=([^|]*)", payload)
if root_match is None or viewport_match is None or nodes_match is None:
    raise SystemExit("page-ready marker is missing root, viewport, or nodes payload")
ready_match = re.search(r"(?:^|\|)ready_msec=([0-9]+)", payload)
if ready_match is None or int(ready_match.group(1)) <= previous_msec:
    raise SystemExit("page-ready marker predates the current page action")
root = [float(value) for value in root_match.groups()]
marker_vp = [float(value) for value in viewport_match.groups()]
if abs(marker_vp[0] - viewport_w) > 1.0 or abs(marker_vp[1] - viewport_h) > 1.0:
    raise SystemExit(f"page-ready viewport mismatch: marker={marker_vp} safe={(viewport_w, viewport_h)}")
expected_root = [app_left, app_top, viewport_w - app_left - app_right, viewport_h - app_top - app_bottom]
for actual, expected in zip(root, expected_root):
    if abs(actual - expected) > 3.0:
        raise SystemExit(f"SafeContent bounds mismatch: marker={root} expected={expected_root}")
if missing_match and missing_match.group(1):
    raise SystemExit(f"missing required nodes: {missing_match.group(1)}")
node_payload = nodes_match.group(1)
for name in required:
    match = re.search(r"(?:^|;)" + re.escape(name) + r"@(-?[0-9.]+),(-?[0-9.]+),([0-9.]+),([0-9.]+)", node_payload)
    if match is None:
        raise SystemExit(f"required node {name} has no bounds")
    x, y, width, height = [float(value) for value in match.groups()]
    if width <= 0.0 or height <= 0.0:
        raise SystemExit(f"required node {name} has invalid bounds: {width}x{height}")
    if x < app_left - 3.0 or y < app_top - 3.0 or x + width > viewport_w - app_right + 3.0 or y + height > viewport_h - app_bottom + 3.0:
        raise SystemExit(f"required node {name} leaves app safe rect: {(x, y, width, height)} vs {expected_root}")
print("PASS")
PY
			then
				PAGE_READY_LAST_MSEC[$page]="$(python3 - "$payload" <<'PY'
import re
import sys
match = re.search(r"(?:^|\|)ready_msec=([0-9]+)", sys.argv[1])
if match is None:
    raise SystemExit("page-ready marker has no ready_msec")
print(match.group(1))
PY
)"
				PAGE_READY_RESULTS+=("$page: $payload")
				return 0
			fi
		fi
		sleep 1
	done
	fail "page-ready marker/bounds did not settle for $description: ${payload:-none}"
}

tap_page_ready_node() {
	local page="$1"
	local node_name="$2"
	local payload="$(latest_marker_payload "page_ready|${page}|")"
	[ -n "$payload" ] || fail "cannot tap $node_name: no page-ready marker for $page"
	local point=""
	if ! point="$(python3 - "$payload" "$SCREEN_W" "$SCREEN_H" "$node_name" <<'PY'
import re
import sys

payload, screen_w, screen_h, name = sys.argv[1:]
viewport = re.search(r"(?:^|\|)viewport=([0-9.]+),([0-9.]+)", payload)
node = re.search(r"(?:^|;)" + re.escape(name) + r"@(-?[0-9.]+),(-?[0-9.]+),([0-9.]+),([0-9.]+)", payload)
if viewport is None or node is None:
    raise SystemExit(f"node bounds unavailable for {name}")
vp_w, vp_h = [float(value) for value in viewport.groups()]
x, y, width, height = [float(value) for value in node.groups()]
print(f"{int(round((x + width * 0.5) * float(screen_w) / vp_w))} {int(round((y + height * 0.5) * float(screen_h) / vp_h))}")
PY
	)"; then
		fail "could not resolve page-ready coordinate for $page/$node_name"
	fi
	read -r x y <<< "$point"
	[ "$x" -ge 0 ] && [ "$y" -ge 0 ] || fail "invalid page-ready coordinate for $page/$node_name: $point"
	"${ADB[@]}" shell input tap "$x" "$y" >/dev/null
}

case "${1:-}" in
	--self-test)
		[ "$#" -eq 1 ] || fail "--self-test does not accept an APK"
		trap - EXIT
		self_test
		STATUS="PASS"
		exit 0
		;;
	--unsigned-debug)
		MODE="unsigned-debug"
		APK="${2:-$DEFAULT_UNSIGNED_DEBUG_APK}"
		[ "$#" -le 2 ] || fail "--unsigned-debug accepts at most one APK path"
		;;
	--help|-h)
		trap - EXIT
		usage
		STATUS="PASS"
		exit 0
		;;
	-*)
		usage >&2
		fail "unknown option: $1"
		;;
	"")
		APK="$DEFAULT_RELEASE_APK"
		;;
	*)
		[ "$#" -eq 1 ] || fail "release mode accepts one APK path"
		APK="$1"
		;;
esac

[ -f "$APK" ] || fail "APK not found: $APK"
[ -x "$ADB_BIN" ] || fail "adb not executable: $ADB_BIN"

"$ADB_BIN" start-server >/dev/null
mapfile -t DEVICE_ROWS < <("$ADB_BIN" devices | awk 'NR > 1 && $1 != "" {print $1 "\t" $2}')
if [ -n "$SERIAL" ]; then
	DEVICE_STATUS=""
	for row in "${DEVICE_ROWS[@]}"; do
		if [ "${row%%$'\t'*}" = "$SERIAL" ]; then
			DEVICE_STATUS="${row#*$'\t'}"
			break
		fi
	done
	[ "$DEVICE_STATUS" = "device" ] || fail "ANDROID_SERIAL=$SERIAL is not an authorized online device"
else
	ACTIVE_SERIALS=()
	for row in "${DEVICE_ROWS[@]}"; do
		if [ "${row#*$'\t'}" = "device" ]; then
			ACTIVE_SERIALS+=("${row%%$'\t'*}")
		fi
	done
	[ "${#ACTIVE_SERIALS[@]}" -eq 1 ] || fail "expected exactly one authorized device, found ${#ACTIVE_SERIALS[@]}"
	SERIAL="${ACTIVE_SERIALS[0]}"
fi
ADB=("$ADB_BIN" -s "$SERIAL")

DISPLAY_INFO="$("${ADB[@]}" shell wm size | tr -d '\r')"
DISPLAY_SIZE="$(printf '%s\n' "$DISPLAY_INFO" | sed -nE 's/.*size: ([0-9]+x[0-9]+).*/\1/p' | tail -1)"
[[ "$DISPLAY_SIZE" =~ ^([0-9]+)x([0-9]+)$ ]] || fail "could not read device display size: $DISPLAY_INFO"
SCREEN_W="${BASH_REMATCH[1]}"
SCREEN_H="${BASH_REMATCH[2]}"

WINDOW_DISPLAYS="$("${ADB[@]}" shell dumpsys window displays 2>/dev/null | tr -d '\r')"
mkdir -p "$REPORT_DIR"
printf '%s\n' "$WINDOW_DISPLAYS" > "$REPORT_DIR/window_displays.txt"
SAFE_AREA_RESULT="$(python3 "$REPORT_DIR/window_displays.txt" <<'PY'
import re
import sys

text = open(sys.argv[1], encoding="utf-8", errors="replace").read()
patterns = [
    ("stable", r"mStableInsets=Rect\(\s*(-?\d+)\s*,\s*(-?\d+)\s*-\s*(-?\d+)\s*,\s*(-?\d+)\s*\)"),
    ("content", r"mContentInsets=Rect\(\s*(-?\d+)\s*,\s*(-?\d+)\s*-\s*(-?\d+)\s*,\s*(-?\d+)\s*\)"),
    ("overscan", r"mOverscanInsets=Rect\(\s*(-?\d+)\s*,\s*(-?\d+)\s*-\s*(-?\d+)\s*,\s*(-?\d+)\s*\)"),
    ("cutout", r"mDisplayCutout=.*?insets=Rect\(\s*(-?\d+)\s*,\s*(-?\d+)\s*-\s*(-?\d+)\s*,\s*(-?\d+)\s*\)"),
]
found = []
for source, pattern in patterns:
    match = re.search(pattern, text, re.DOTALL)
    if match:
        values = [int(value) for value in match.groups()]
        if any(value < 0 for value in values):
            raise SystemExit(f"negative {source} insets: {values}")
        found.append((source, values))
if found:
    combined = [max(values[index] for _source, values in found) for index in range(4)]
    sources = ",".join(source for source, _values in found)
    print("|".join([f"max({sources})"] + [str(value) for value in combined]))
    raise SystemExit(0)
raise SystemExit("no parseable Android inset rect found")
PY
)" || fail "Android window dump has no parseable stable/content/cutout inset rect"
IFS='|' read -r SAFE_SOURCE SAFE_LEFT SAFE_TOP SAFE_RIGHT SAFE_BOTTOM <<< "$SAFE_AREA_RESULT"
SAFE_AREA_LINE="${SAFE_SOURCE}: left=${SAFE_LEFT}px top=${SAFE_TOP}px right=${SAFE_RIGHT}px bottom=${SAFE_BOTTOM}px"
[[ "$SAFE_LEFT" =~ ^[0-9]+$ && "$SAFE_TOP" =~ ^[0-9]+$ && "$SAFE_RIGHT" =~ ^[0-9]+$ && "$SAFE_BOTTOM" =~ ^[0-9]+$ ]] || fail "invalid parsed safe-area values: $SAFE_AREA_RESULT"
[ $((SAFE_LEFT + SAFE_RIGHT)) -lt "$SCREEN_W" ] || fail "horizontal safe insets consume the display: $SAFE_AREA_RESULT / $DISPLAY_SIZE"
[ $((SAFE_TOP + SAFE_BOTTOM)) -lt "$SCREEN_H" ] || fail "vertical safe insets consume the display: $SAFE_AREA_RESULT / $DISPLAY_SIZE"
NAVIGATION_MODE="$("${ADB[@]}" shell settings get secure navigation_mode 2>/dev/null | tr -d '\r' | tail -n 1)"
[ -n "$NAVIGATION_MODE" ] || NAVIGATION_MODE="unreported"

if ! "${ADB[@]}" install -r -d -g "$APK" > "$REPORT_DIR/install.log" 2>&1; then
	fail "adb install failed; see $REPORT_DIR/install.log"
fi
"${ADB[@]}" logcat -c >/dev/null 2>&1 || fail "could not clear logcat before UI marker run"
"${ADB[@]}" shell am force-stop "$PACKAGE"
"${ADB[@]}" shell monkey -p "$PACKAGE" -c android.intent.category.LAUNCHER 1 > "$REPORT_DIR/launch.log" 2>&1 || fail "launcher activity did not start"
wait_for_focus
wait_for_safe_area_marker
if ! SAFE_AREA_COMPARISON="$(python3 - "$SAFE_AREA_APP_LINE" "$SAFE_AREA_RESULT" "$SCREEN_W" "$SCREEN_H" <<'PY'
import sys

app = [float(value) for value in sys.argv[1].split("|")]
source, left, top, right, bottom = sys.argv[2].split("|")
system = [float(left), float(top), float(right), float(bottom)]
screen_w, screen_h = [float(value) for value in sys.argv[3:5]]
if len(app) != 6 or app[4] <= 0 or app[5] <= 0:
    raise SystemExit("invalid app safe-area marker")
expected = [system[0] * app[4] / screen_w, system[1] * app[5] / screen_h, system[2] * app[4] / screen_w, system[3] * app[5] / screen_h]
extra = [app[i] - expected[i] for i in range(4)]
if any(app[i] + 3.0 < expected[i] for i in range(4)):
    raise SystemExit(f"app safe rect does not cover system inset: app={app[:4]} expected={expected}")
if any(value > 24.0 for value in extra):
    raise SystemExit(f"app safe margins exceed system inset unexpectedly: app={app[:4]} expected={expected}")
print("PASS: system->app viewport coverage; system=%.1f,%.1f,%.1f,%.1f app=%.1f,%.1f,%.1f,%.1f expected=%.1f,%.1f,%.1f,%.1f" % (*system, *app[:4], *expected))
PY
)"; then
	fail "system/app safe-area comparison failed"
fi
wait_for_page "menu" "main menu"
wait_for_page_ready "menu" "main menu" MenuTitleLabel MenuSettingsButton MenuQuickRulesButton
capture_screen "01_launch"

# These normalized taps match the authored 1280x720 menu while page markers prove the target state.
tap_percent 32 75
wait_for_focus
wait_for_page "rules" "rules page"
wait_for_page_ready "rules" "rules page" RulesCodexFrontPanel RulesContentScroll RulesContentScrollHitTarget RulesContentScrollThumb
RULES_SCROLL_BEFORE="$(wait_for_scroll_ready rules)"
swipe_percent 94 76 94 34 800
RULES_SCROLL_AFTER="$(wait_for_scroll_change rules "$RULES_SCROLL_BEFORE")"
RULES_SCROLL_RESULT="changed:${RULES_SCROLL_BEFORE}->${RULES_SCROLL_AFTER}"
capture_screen "02_rules_single_finger_swipe"
if [ "$NAVIGATION_MODE" = "2" ]; then
	EDGE_Y=$((SCREEN_H / 2))
	"${ADB[@]}" shell input swipe 1 "$EDGE_Y" "$((SCREEN_W * 24 / 100))" "$EDGE_Y" 500 >/dev/null
	wait_for_page "menu" "menu after gesture-navigation edge back from rules"
	wait_for_page_ready "menu" "menu after gesture-navigation edge back" MenuTitleLabel MenuSettingsButton MenuQuickRulesButton
	capture_screen "03_rules_edge_back"
else
	"${ADB[@]}" shell input keyevent KEYCODE_BACK >/dev/null
	wait_for_page "menu" "menu after rules system back"
	wait_for_page_ready "menu" "menu after rules system back" MenuTitleLabel MenuSettingsButton MenuQuickRulesButton
	capture_screen "03_rules_system_back"
fi

tap_percent 88 90
wait_for_marker_payload "settings|" "open" "settings open"
wait_for_page_ready "settings" "settings open" SettingsPanel SettingsTitleLabel SettingsRuleVariantButton SettingsCloseButton
capture_screen "04_settings_open"
"${ADB[@]}" shell input keyevent KEYCODE_BACK >/dev/null
wait_for_marker_payload "settings|" "closed" "settings system back close"
wait_for_page "menu" "menu after settings system back"
wait_for_page_ready "menu" "menu after settings system back" MenuTitleLabel MenuSettingsButton MenuQuickRulesButton
capture_screen "05_settings_system_back"

tap_percent 50 54
wait_for_page "online_lobby" "online lobby"
wait_for_page_ready "online_lobby" "online lobby" OnlineLobbyFormPanel OnlineLobbyNameEdit OnlineLobbyLogPanel OnlineLobbyLogScroll
ONLINE_SCROLL_BEFORE="$(latest_scroll_payload online_lobby || true)"
swipe_percent 93 78 93 42 700
wait_for_touch_drag online_lobby
ONLINE_SCROLL_AFTER="$(latest_scroll_payload online_lobby || true)"
if [ -n "$ONLINE_SCROLL_BEFORE" ] && [ "${ONLINE_SCROLL_BEFORE##*|}" -gt 0 ] 2>/dev/null; then
	[ "$ONLINE_SCROLL_AFTER" != "$ONLINE_SCROLL_BEFORE" ] || fail "online lobby scroll range was positive but offset did not change"
	ONLINE_SCROLL_RESULT="changed:${ONLINE_SCROLL_BEFORE}->${ONLINE_SCROLL_AFTER}"
else
	ONLINE_SCROLL_RESULT="drag_observed_no_scrollable_log_content:${ONLINE_SCROLL_AFTER:-none}"
fi
capture_screen "06_online_lobby_single_finger_drag"
tap_percent 26 32
wait_for_focus
sleep 1
IME_DUMP="$("${ADB[@]}" shell dumpsys input_method 2>/dev/null | tr -d '\r')"
if printf '%s\n' "$IME_DUMP" | grep -qE 'mInputShown=true|mShowRequested=true|InputMethodWindowVisible=true'; then
	IME_VISIBLE="true"
else
	IME_VISIBLE="false"
	fail "IME did not report visible after tapping the lobby name field"
fi
"${ADB[@]}" shell input text DeviceQA >/dev/null
capture_screen "07_lobby_ime"
"${ADB[@]}" shell input keyevent KEYCODE_BACK >/dev/null
IME_AFTER_BACK="$("${ADB[@]}" shell dumpsys input_method 2>/dev/null | tr -d '\r')"
if printf '%s\n' "$IME_AFTER_BACK" | grep -qE 'mInputShown=true|mShowRequested=true|InputMethodWindowVisible=true'; then
	fail "system back did not dismiss the IME"
fi
capture_screen "08_lobby_ime_dismissed"
"${ADB[@]}" shell input keyevent KEYCODE_BACK >/dev/null
wait_for_page "menu" "menu after lobby system back"
wait_for_page_ready "menu" "menu after lobby system back" MenuTitleLabel MenuSettingsButton MenuQuickRulesButton
capture_screen "09_lobby_system_back"

tap_percent 26 54
wait_for_page "offline" "offline battle"
wait_for_page_ready "offline" "offline battle" TopHudTitle TopHudSettingsButton HandTray ActionButtonDock
capture_screen "10_offline_battle"
"${ADB[@]}" shell input keyevent KEYCODE_BACK >/dev/null
wait_for_marker_payload "exit_confirm|" "open" "offline system-back exit confirmation"
wait_for_page_ready "exit_confirm" "offline exit confirmation open" ExitConfirmDialog ExitConfirmContinueButton ExitConfirmLeaveButton
capture_screen "11_offline_exit_confirm"
"${ADB[@]}" shell input keyevent KEYCODE_BACK >/dev/null
wait_for_marker_payload "exit_confirm|" "closed" "offline exit-confirm dismissal"
wait_for_page_ready "offline" "offline after exit-confirm cancellation" TopHudTitle TopHudSettingsButton HandTray ActionButtonDock
capture_screen "12_offline_exit_confirm_dismissed"
"${ADB[@]}" shell input keyevent KEYCODE_BACK >/dev/null
wait_for_marker_payload "exit_confirm|" "open" "offline exit confirmation reopen"
wait_for_page_ready "exit_confirm" "offline exit confirmation reopen" ExitConfirmDialog ExitConfirmContinueButton ExitConfirmLeaveButton
tap_page_ready_node "exit_confirm" "ExitConfirmLeaveButton"
wait_for_marker_payload "exit_confirm|" "closed" "offline confirmed exit dialog close"
wait_for_page "menu" "menu after offline exit action"
wait_for_page_ready "menu" "menu after offline exit action" MenuTitleLabel MenuSettingsButton MenuQuickRulesButton
capture_screen "13_offline_return_menu"

STATUS="PASS"
FAIL_REASON=""
exit 0
