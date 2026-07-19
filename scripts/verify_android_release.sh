#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APK="${1:-$ROOT_DIR/build/qa/YunzhuoMahjongGodot-v1.0.180-ui3d-commercial-sdk36.apk}"
BUILD_TOOLS="${ANDROID_BUILD_TOOLS:-/opt/android-sdk/build-tools/36.0.0}"
AAPT2="$BUILD_TOOLS/aapt2"
APKSIGNER="$BUILD_TOOLS/apksigner"

fail() {
	echo "FAIL: $*" >&2
	exit 1
}

[ -f "$APK" ] || fail "APK not found: $APK"
[ -x "$AAPT2" ] || fail "aapt2 not found: $AAPT2"
[ -x "$APKSIGNER" ] || fail "apksigner not found: $APKSIGNER"

BADGING="$($AAPT2 dump badging "$APK")"
grep -q "package: name='com.yunzhuo.mahjong' versionCode='180' versionName='1.0.180-godot'" <<<"$BADGING" || fail "package or version metadata mismatch"
grep -q "minSdkVersion:'24'" <<<"$BADGING" || fail "min SDK mismatch"
grep -q "targetSdkVersion:'36'" <<<"$BADGING" || fail "target SDK mismatch"
grep -q "compileSdkVersion='36'" <<<"$BADGING" || fail "compile SDK mismatch"

SIGNATURE="$($APKSIGNER verify --verbose --print-certs "$APK")"
grep -q "Verified using v2 scheme .*: true" <<<"$SIGNATURE" || fail "APK v2 signature missing"
grep -q "Verified using v3 scheme .*: true" <<<"$SIGNATURE" || fail "APK v3 signature missing"
grep -q "CN=Yunzhuo Mahjong, O=Yunzhuo, C=CN" <<<"$SIGNATURE" || fail "release signing certificate mismatch"

if zipinfo -1 "$APK" | grep -Eq '^(assets/)?(build/qa|garden-gpt-image-2|tools/|references/|scripts/(offline_smoke_test|page_screenshot_capture|ui_layout_smoke_test|commercial_3d_stage_smoke_test|verify_ui_regressions))'; then
	fail "development or QA resources are packaged"
fi

ENTRIES="$(zipinfo -1 "$APK")"
grep -q 'commercial_3d_stage.gdc' <<<"$ENTRIES" || fail "commercial 3D stage missing"
grep -q 'battle_table_depth.gdc' <<<"$ENTRIES" || fail "battle table depth renderer missing"
grep -q 'table_cinematic_lighting.gdshader' <<<"$ENTRIES" || fail "cinematic table shader missing"
grep -q 'tile_decals_3d' <<<"$ENTRIES" || fail "3D tile decals missing"

python3 - "$APK" <<'PY'
import io
import sys
import zipfile

from PIL import Image

expected = {
    "res/mipmap-xxxhdpi-v4/icon.webp": ((192, 192), "RGBA"),
    "res/mipmap-xxxhdpi-v4/icon_foreground.webp": ((432, 432), "RGBA"),
    "res/mipmap-xxxhdpi-v4/icon_background.webp": ((432, 432), "RGB"),
}
with zipfile.ZipFile(sys.argv[1]) as apk:
    for path, (size, mode) in expected.items():
        image = Image.open(io.BytesIO(apk.read(path)))
        if image.size != size or image.mode != mode:
            raise SystemExit(f"invalid launcher icon {path}: {image.size} {image.mode}")
PY

SIZE="$(stat -c '%s' "$APK")"
HASH="$(sha256sum "$APK" | awk '{print $1}')"
echo "PASS: Android release audit"
echo "APK: $APK"
echo "Size: $SIZE bytes"
echo "SHA-256: $HASH"
