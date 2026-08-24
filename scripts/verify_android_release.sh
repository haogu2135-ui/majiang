#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEFAULT_RELEASE_APK="$ROOT_DIR/build/qa/YunzhuoMahjongGodot-v1.0.180-commercial-sdk36.apk"
DEFAULT_UNSIGNED_DEBUG_APK="$ROOT_DIR/build/qa/YunzhuoMahjongGodot-v1.0.180-debug-sdk36.apk"
BUILD_TOOLS="${ANDROID_BUILD_TOOLS:-/opt/android-sdk/build-tools/36.1.0}"
AAPT2="$BUILD_TOOLS/aapt2"
APKSIGNER="$BUILD_TOOLS/apksigner"
RETIRED_ILLUSTRATIONS=(
	"online_gpt_lobby.png"
	"online_feedback_gpt_strip.png"
	"online_gpt_lobby_v2.png"
	"seat_gpt_brocade_v3.png"
	"settings_gpt_panel_v2.png"
	"online_lobby_panel_frame_v1.png"
	"online_lobby_panel_frame_v2.png"
	"table_gpt_backdrop_v3.png"
	"menu_primary_3d_stage_overlay_v2.png"
	"action_gpt_dock_v7.png"
	"action_gpt_dock_v4.png"
	"online_lobby_group_plate_v2.png"
	"top_hud_gpt_banner_v4.png"
	"top_hud_gpt_banner_v5.png"
	"top_hud_gpt_banner_v3.png"
	"hand_gpt_tray_v3.png"
	"top_hud_gpt_banner_v2.png"
	"hand_gpt_tray_v4.png"
	"seat_gpt_brocade_v6.png"
	"seat_gpt_brocade_v9.png"
	"seat_gpt_brocade_v7.png"
	"seat_gpt_brocade_v8.png"
	"action_gpt_dock_v6.png"
	"seat_gpt_brocade_v4.png"
	"action_gpt_dock_v8.png"
	"action_gpt_dock_banner_r433.png"
	"action_gpt_dock_bright_r431.png"
	"ui_jade_ink_strip.png"
	"action_gpt_dock_warm_v391.png"
	"stats_gpt_dashboard_warm_v392.png"
	"offline_table_3d_overlay.png"
	"settings_gpt_panel.png"
	"claim_response_trail.png"
	"seat_gpt_plaque_warm_r429.png"
	"table_gpt_backdrop_warm_v391.png"
	"table_log_gpt_scroll.png"
	"daily_login_gpt_calendar_warm_v392.png"
	"rules_gpt_scroll.png"
	"achievement_gpt_gallery_warm_v391.png"
	"menu_primary_3d_stage_overlay_warm_v390.png"
	"settings_gpt_panel_warm_v391.png"
	"menu_hero_gpt_backdrop_warm_v390.png"
	"rules_gpt_scroll_warm_v391.png"
	"shop_gpt_vault_warm_v392.png"
	"exit_gpt_confirm_warm_v392.png"
	"top_hud_gpt_banner_warm_v392.png"
)
MAX_RELEASE_APK_BYTES="${ANDROID_RELEASE_MAX_BYTES:-155000000}"
QA_RESOURCE_PATTERN='(^|/)(build/qa(/|$)|qa(/|$)|garden-gpt-image-2(/|$)|tools/|assets/references/|assets/illustrations/_replaced_[^/]+/|scripts/(_tmp_[^/]+|ai_play_[^/]*_check|round[0-9]+_check|[^/]*_smoke_test|[^/]*_capture|test_animations|verify_[^/]+)(\.|/|$)|test_[^/]+\.(gd|gdc|gde|tscn)(\.uid)?$|extension_api\.json$)'

fail() {
	echo "FAIL: $*" >&2
	exit 1
}

usage() {
	cat <<EOF
Usage:
  $(basename "$0") [SIGNED_RELEASE_APK]
  $(basename "$0") --unsigned-debug [UNSIGNED_DEBUG_APK]
  $(basename "$0") --self-test
  $(basename "$0") --toolchain-self-test
EOF
}

configure_android_host_compat() {
	if [ "$(uname -m)" = "aarch64" ] && file "$AAPT2" | grep -q 'x86-64'; then
		[ -x /usr/bin/qemu-x86_64 ] || fail "qemu-x86_64 is required for Google build-tools on this ARM64 host"
		[ -x /usr/x86_64-linux-gnu/lib/ld-linux-x86-64.so.2 ] || fail "amd64 cross sysroot is required for Google build-tools on this ARM64 host"
		export QEMU_LD_PREFIX="${QEMU_LD_PREFIX:-/usr/x86_64-linux-gnu}"
	fi
}

qa_filter_self_test() {
	local bad_path good_path required_filter retired
	local -a bad_paths=(
		"assets/build/qa/report.md"
		"assets/scripts/ai_play_soak_check.gdc"
		"assets/scripts/ai_play_rule_variant_soak_check.gdc"
		"assets/scripts/verify_android_device.sh"
		"assets/scripts/verify_online_production.sh"
		"assets/scripts/ai_play_round95_check.gd.uid"
		"assets/scripts/_tmp_find_multiwait.gd.remap"
		"assets/scripts/ui_interaction_smoke_test.gdc"
		"assets/scripts/ui_preview_capture.gdc"
		"assets/scripts/verify_ai_soak.sh"
		"assets/assets/illustrations/_replaced_20260820/old.png"
		"assets/test_audio.gdc"
		"assets/extension_api.json"
	)
	local -a good_paths=(
		"assets/scripts/main.gdc"
		"assets/scripts/ui/commercial_3d_stage.gdc"
		"assets/assets/illustrations/toast_gpt_banner.png"
		"assets/shaders/table_cinematic_lighting.gdshader"
	)
	for bad_path in "${bad_paths[@]}"; do
		grep -Eq "$QA_RESOURCE_PATTERN" <<<"$bad_path" || fail "QA leakage pattern missed: $bad_path"
	done
	for good_path in "${good_paths[@]}"; do
		if grep -Eq "$QA_RESOURCE_PATTERN" <<<"$good_path"; then
			fail "QA leakage pattern rejected a runtime resource: $good_path"
		fi
	done
	for required_filter in \
		'assets/illustrations/_replaced_*/**' \
		'assets/tiles_3d/**' \
		'assets/tiles/tile_back_3d.png' \
		'scripts/_tmp_*.gd*' \
		'assets/audio/bgm_loop.wav' \
		'assets/audio/bgm_guofeng1.mp3' \
		'assets/audio/bgm_guofeng2.mp3' \
		'assets/audio/bgm_guofeng3.mp3' \
		'assets/tiles_subtle_3d/**' \
		'assets/tile_decals_3d/**' \
		'assets/table/table_felt_3d_gpt.png' \
		'assets/table/table_felt_warm_bright_r428.png' \
		'assets/table/table_felt_green.jpg' \
		'assets/table/table_dark_wood.jpg' \
		'assets/illustrations/wall_strip_landscape.png' \
		'scripts/*_smoke_test.gd*' \
		'scripts/*_capture.gd*' \
		'scripts/verify_*.sh' \
		'scripts/ai_play_*_check.gd*' \
		'scripts/round*_check.gd*' \
		'test_*.gd*' \
		'test_*.tscn'; do
	grep -Fq "$required_filter" "$ROOT_DIR/export_presets.example.cfg" || fail "export filter missing: $required_filter"
	done
	for required_include in \
		'scripts/ui/commercial_3d_stage.gd' \
		'scripts/ui_enhancements.gd'; do
		grep -Fq "$required_include" "$ROOT_DIR/export_presets.example.cfg" || fail "include filter missing: $required_include"
	done
	for retired in "${RETIRED_ILLUSTRATIONS[@]}"; do
		required_filter="assets/illustrations/$retired"
		grep -Fq "$required_filter" "$ROOT_DIR/export_presets.example.cfg" || fail "retired illustration export filter missing: $required_filter"
	done
	grep -q '^export_filter="scenes"$' "$ROOT_DIR/export_presets.example.cfg" || fail "Android export must use the scene dependency filter"
	for required_include in \
		'Main.tscn' \
		'scripts/main.gd' \
		'assets/audio/mobile/*.mp3' \
		'assets/illustrations/*.png'; do
		grep -Fq "$required_include" "$ROOT_DIR/export_presets.example.cfg" || fail "runtime include filter missing: $required_include"
	done
	grep -q '^gradle_build/use_gradle_build=true$' "$ROOT_DIR/export_presets.example.cfg" || fail "SDK overrides require Gradle build"
	grep -q '^gradle_build/min_sdk="24"$' "$ROOT_DIR/export_presets.example.cfg" || fail "min SDK export contract mismatch"
	grep -q '^gradle_build/target_sdk="36"$' "$ROOT_DIR/export_presets.example.cfg" || fail "target SDK export contract mismatch"
	echo "PASS: Android QA resource filter self-test"
}

android_toolchain_self_test() {
	[ -x "$AAPT2" ] || fail "aapt2 not found: $AAPT2"
	[ -x "$APKSIGNER" ] || fail "apksigner not found: $APKSIGNER"
	[ -x "$BUILD_TOOLS/zipalign" ] || fail "zipalign not found: $BUILD_TOOLS/zipalign"
	[ -x /opt/android-sdk/platform-tools/adb ] || fail "SDK adb not found"
	[ -f /opt/android-sdk/platforms/android-36/android.jar ] || fail "Android 36 platform not found"
	[ -f /root/.local/share/godot/export_templates/4.6.3.stable/android_debug.apk ] || fail "Godot 4.6.3 Android debug template not found"
	[ -f /root/.local/share/godot/export_templates/4.6.3.stable/android_release.apk ] || fail "Godot 4.6.3 Android release template not found"
	[ -f /root/.local/share/godot/export_templates/4.6.3.stable/android_source.zip ] || fail "Godot 4.6.3 Android source template not found"
	grep -q '^Pkg.Revision=36\.1\.0$' "$BUILD_TOOLS/source.properties" || fail "Android build-tools revision mismatch"
	grep -q '^AndroidVersion.ApiLevel=36$' /opt/android-sdk/platforms/android-36/source.properties || fail "Android platform API mismatch"
	configure_android_host_compat
	"$AAPT2" version 2>&1 | grep -q 'Android Asset Packaging Tool'
	"$APKSIGNER" version >/dev/null
	"$BUILD_TOOLS/zipalign" -c 1 /root/.local/share/godot/export_templates/4.6.3.stable/android_release.apk >/dev/null
	/opt/android-sdk/platform-tools/adb version | grep -q 'Android Debug Bridge version'
	echo "PASS: Android SDK 36 toolchain self-test"
}

AUDIT_MODE="release"
APK="$DEFAULT_RELEASE_APK"
case "${1:-}" in
	--self-test)
		[ "$#" -eq 1 ] || fail "--self-test does not accept an APK"
		qa_filter_self_test
		exit 0
		;;
	--toolchain-self-test)
		[ "$#" -eq 1 ] || fail "--toolchain-self-test does not accept an APK"
		android_toolchain_self_test
		exit 0
		;;
	--unsigned-debug)
		[ "$#" -le 2 ] || fail "--unsigned-debug accepts at most one APK path"
		AUDIT_MODE="unsigned-debug"
		APK="${2:-$DEFAULT_UNSIGNED_DEBUG_APK}"
		;;
	--help|-h)
		usage
		exit 0
		;;
	-*)
		usage >&2
		fail "unknown option: $1"
		;;
	"")
		;;
	*)
		[ "$#" -eq 1 ] || fail "release audit accepts at most one APK path"
		APK="$1"
		;;
esac

[ -f "$APK" ] || fail "APK not found: $APK"
[ -x "$AAPT2" ] || fail "aapt2 not found: $AAPT2"
[ -x "$APKSIGNER" ] || fail "apksigner not found: $APKSIGNER"
configure_android_host_compat

BADGING="$($AAPT2 dump badging "$APK")"
grep -q "package: name='com.yunzhuo.mahjong' versionCode='180' versionName='1.0.180-godot'" <<<"$BADGING" || fail "package or version metadata mismatch"
grep -q "minSdkVersion:'24'" <<<"$BADGING" || fail "min SDK mismatch"
grep -q "targetSdkVersion:'36'" <<<"$BADGING" || fail "target SDK mismatch"
grep -q "compileSdkVersion='36'" <<<"$BADGING" || fail "compile SDK mismatch"

if [ "$AUDIT_MODE" = "unsigned-debug" ]; then
	if SIGNATURE="$($APKSIGNER verify --verbose --print-certs "$APK" 2>&1)"; then
		fail "debug evidence APK is signed; use the release audit for signed artifacts"
	fi
	grep -q '^DOES NOT VERIFY$' <<<"$SIGNATURE" || fail "unexpected unsigned APK verification result"
	grep -q 'ERROR: Missing META-INF/MANIFEST.MF' <<<"$SIGNATURE" || fail "APK signature failure is not the expected unsigned status"
else
	SIGNATURE="$($APKSIGNER verify --verbose --print-certs "$APK")"
	grep -q "Verified using v2 scheme .*: true" <<<"$SIGNATURE" || fail "APK v2 signature missing"
	grep -q "Verified using v3 scheme .*: true" <<<"$SIGNATURE" || fail "APK v3 signature missing"
	grep -q "CN=Yunzhuo Mahjong, O=Yunzhuo, C=CN" <<<"$SIGNATURE" || fail "release signing certificate mismatch"
fi

"$BUILD_TOOLS/zipalign" -c -P 16 4 "$APK" >/dev/null || fail "APK is not zip-aligned for Android 16 KiB pages"

ENTRIES="$(zipinfo -1 "$APK")"
if grep -Eq "$QA_RESOURCE_PATTERN" <<<"$ENTRIES"; then
	fail "development or QA resources are packaged"
fi
for retired in "${RETIRED_ILLUSTRATIONS[@]}"; do
	if grep -Fq "assets/.godot/imported/$retired-" <<<"$ENTRIES" || grep -Fxq "assets/assets/illustrations/$retired.import" <<<"$ENTRIES"; then
		fail "retired illustration is packaged: $retired"
	fi
done

grep -qx 'assets/scripts/main.gdc' <<<"$ENTRIES" || fail "compiled main runtime script missing"
grep -qx 'assets/scripts/ui/commercial_3d_stage.gdc' <<<"$ENTRIES" || fail "commercial 3D stage missing"
grep -qx 'assets/scripts/ui/battle_table_depth.gdc' <<<"$ENTRIES" || fail "battle table depth renderer missing"
grep -qx 'assets/shaders/table_cinematic_lighting.gdshader' <<<"$ENTRIES" || fail "cinematic table shader missing"
grep -q 'assets/.godot/imported/tile_man1.png-' <<<"$ENTRIES" || fail "2D tile faces missing"

for excluded_entry in \
	'assets/assets/audio/bgm_loop.wav' \
	'assets/assets/audio/bgm_guofeng1.mp3' \
	'assets/assets/audio/bgm_guofeng2.mp3' \
	'assets/assets/audio/bgm_guofeng3.mp3' \
	'assets/assets/tiles_3d/' \
	'assets/assets/tiles_subtle_3d/' \
	'assets/assets/tile_decals_3d/' \
	'assets/assets/tiles/tile_back_3d.png' \
	'assets/assets/table/table_felt_3d_gpt.png' \
	'assets/assets/table/table_felt_warm_bright_r428.png' \
	'assets/assets/table/table_felt_green.jpg' \
	'assets/assets/table/table_dark_wood.jpg' \
	'assets/.godot/imported/bgm_loop.wav-' \
	'assets/.godot/imported/table_felt_3d_gpt.png-' \
	'assets/.godot/imported/table_felt_warm_bright_r428.png-' \
	'assets/.godot/imported/table_felt_green.jpg-' \
	'assets/.godot/imported/table_dark_wood.jpg-' \
	'assets/.godot/imported/wall_strip_landscape.png-'; do
	if grep -Fq "$excluded_entry" <<<"$ENTRIES"; then
		fail "excluded resource is packaged: $excluded_entry"
	fi
done

python3 - "$APK" "$AAPT2" <<'PY'
import io
import re
import subprocess
import sys
import zipfile

from PIL import Image

expected = {
    "icon": ((192, 192), "RGBA"),
    "icon_foreground": ((432, 432), "RGBA"),
    "icon_background": ((432, 432), "RGB"),
}
resource_dump = subprocess.check_output(
    [sys.argv[2], "dump", "resources", "-v", sys.argv[1]], text=True
)
resource_paths = {}
current = None
for line in resource_dump.splitlines():
    resource_match = re.match(r"\s*resource\s+\S+\s+mipmap/(icon(?:_foreground|_background)?)\s*$", line)
    if resource_match:
        current = resource_match.group(1)
        continue
    if line.lstrip().startswith("resource "):
        current = None
        continue
    if current is not None and current not in resource_paths:
        file_match = re.search(r"\(file\)\s+(res/\S+)", line)
        if file_match:
            resource_paths[current] = file_match.group(1)

with zipfile.ZipFile(sys.argv[1]) as apk:
    for resource_name, (size, mode) in expected.items():
        path = resource_paths.get(resource_name)
        if path is None:
            raise SystemExit(f"launcher resource missing: mipmap/{resource_name}")
        image = Image.open(io.BytesIO(apk.read(path)))
        if image.size != size or image.mode != mode:
            raise SystemExit(f"invalid launcher icon {resource_name} ({path}): {image.size} {image.mode}")
PY

SIZE="$(stat -c '%s' "$APK")"
HASH="$(sha256sum "$APK" | awk '{print $1}')"
if [ "$AUDIT_MODE" = "release" ]; then
	[[ "$MAX_RELEASE_APK_BYTES" =~ ^[0-9]+$ ]] || fail "ANDROID_RELEASE_MAX_BYTES must be an integer"
	[ "$SIZE" -le "$MAX_RELEASE_APK_BYTES" ] || fail "release APK exceeds size budget: $SIZE > $MAX_RELEASE_APK_BYTES bytes"
fi
if [ "$AUDIT_MODE" = "unsigned-debug" ]; then
	echo "PASS: Android unsigned debug APK audit (not distributable)"
else
	echo "PASS: Android signed release audit"
fi
echo "APK: $APK"
echo "Size: $SIZE bytes"
echo "SHA-256: $HASH"
