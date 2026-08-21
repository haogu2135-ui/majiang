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
IME_VISIBLE="not collected"
CAPTURES=()
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
		echo "- IME visible after field tap: $IME_VISIBLE"
		if [ "$STATUS" = "PASS" ]; then
			echo "- Checks: install, launch, nonblank screenshots, rules touch, rules system-back, lobby touch, IME show/dismiss, lobby system-back"
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
	echo "PASS: Android device smoke self-test"
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
	if ! python3 - "$path" <<'PY'
import sys
from PIL import Image, ImageStat

with Image.open(sys.argv[1]) as image:
    rgba = image.convert("RGBA")
    if rgba.width < 2 or rgba.height < 2:
        raise SystemExit("screenshot has invalid dimensions")
    if ImageStat.Stat(rgba.convert("L")).stddev[0] < 4.0:
        raise SystemExit("screenshot is near blank")
    if rgba.getchannel("A").getextrema()[1] == 0:
        raise SystemExit("screenshot is fully transparent")
PY
	then
		fail "invalid or blank screenshot for $name"
	fi
	CAPTURES+=("$path")
}

tap_percent() {
	local x_percent="$1"
	local y_percent="$2"
	local x=$((SCREEN_W * x_percent / 100))
	local y=$((SCREEN_H * y_percent / 100))
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
SAFE_AREA_LINE="$(printf '%s\n' "$WINDOW_DISPLAYS" | grep -m1 -E 'mStableInsets=|mDisplayCutout=|mOverscanInsets=|mContentInsets=' || true)"
[ -n "$SAFE_AREA_LINE" ] || fail "Android window dump did not expose stable/display inset evidence"

mkdir -p "$REPORT_DIR"
if ! "${ADB[@]}" install -r -d -g "$APK" > "$REPORT_DIR/install.log" 2>&1; then
	fail "adb install failed; see $REPORT_DIR/install.log"
fi
"${ADB[@]}" shell am force-stop "$PACKAGE"
"${ADB[@]}" shell monkey -p "$PACKAGE" -c android.intent.category.LAUNCHER 1 > "$REPORT_DIR/launch.log" 2>&1 || fail "launcher activity did not start"
wait_for_focus
capture_screen "01_launch"

# These normalized taps match the authored 1280x720 menu while remaining usable on landscape devices.
tap_percent 32 75
sleep 1
wait_for_focus
capture_screen "02_rules_touch"
"${ADB[@]}" shell input keyevent KEYCODE_BACK >/dev/null
sleep 1
wait_for_focus
capture_screen "03_rules_system_back"

tap_percent 50 54
sleep 1
wait_for_focus
capture_screen "04_online_lobby_touch"
tap_percent 26 32
sleep 1
IME_DUMP="$("${ADB[@]}" shell dumpsys input_method 2>/dev/null | tr -d '\r')"
if printf '%s\n' "$IME_DUMP" | grep -qE 'mInputShown=true|mShowRequested=true|InputMethodWindowVisible=true'; then
	IME_VISIBLE="true"
else
	IME_VISIBLE="false"
	fail "IME did not report visible after tapping the lobby name field"
fi
"${ADB[@]}" shell input text DeviceQA >/dev/null
capture_screen "05_lobby_ime"
"${ADB[@]}" shell input keyevent KEYCODE_BACK >/dev/null
sleep 1
IME_AFTER_BACK="$("${ADB[@]}" shell dumpsys input_method 2>/dev/null | tr -d '\r')"
if printf '%s\n' "$IME_AFTER_BACK" | grep -qE 'mInputShown=true|mShowRequested=true|InputMethodWindowVisible=true'; then
	fail "system back did not dismiss the IME"
fi
capture_screen "06_lobby_ime_dismissed"
"${ADB[@]}" shell input keyevent KEYCODE_BACK >/dev/null
sleep 1
wait_for_focus
capture_screen "07_lobby_system_back"

STATUS="PASS"
FAIL_REASON=""
exit 0
