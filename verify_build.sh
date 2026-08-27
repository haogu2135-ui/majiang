#!/usr/bin/env bash
# Fast, repository-local build contract for 云桌麻将.
# Full commercial QA remains in scripts/verify_ai_commercial.sh and
# scripts/verify_ui_regressions.sh; this entrypoint must stay useful before an
# APK has been exported.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_BIN="${PYTHON_BIN:-python3}"
DEFAULT_GODOT_BIN="/opt/godot/Godot_v4.6.3-stable_linux.arm64"
if [ -z "${GODOT_BIN:-}" ]; then
	if [ -x "$DEFAULT_GODOT_BIN" ]; then
		GODOT_BIN="$DEFAULT_GODOT_BIN"
	else
		GODOT_BIN="godot"
	fi
fi

usage() {
	cat <<EOF
Usage:
  $(basename "$0")                 Check project files, version and assembly
  $(basename "$0") --check          Validate all source parts
  $(basename "$0") --verify         Validate generated scripts/main.gd parity
  $(basename "$0") --ui-smoke       Run the serial UI layout smoke test
  $(basename "$0") --help

The Android APK is audited separately with scripts/verify_android_release.sh.
EOF
}

run_check() {
	local label="$1"
	shift
	printf '==> %s\n' "$label"
	"$@"
	printf 'PASS: %s\n' "$label"
}

check_files() {
	local required
	for required in \
		"$ROOT_DIR/project.godot" \
		"$ROOT_DIR/Main.tscn" \
		"$ROOT_DIR/scripts/main.gd" \
		"$ROOT_DIR/scripts/main_base.gd" \
		"$ROOT_DIR/scripts/main_src" \
		"$ROOT_DIR/assets/tiles" \
		"$ROOT_DIR/assets/audio/bgm_loop.mp3" \
		"$ROOT_DIR/assets/audio/discard.mp3" \
		"$ROOT_DIR/assets/audio/draw.mp3" \
		"$ROOT_DIR/assets/audio/pong.mp3" \
		"$ROOT_DIR/assets/audio/kong.mp3" \
		"$ROOT_DIR/assets/audio/win.mp3"; do
		[ -e "$required" ] || { printf 'FAIL: missing required path: %s\n' "$required" >&2; return 1; }
	done
}

check_version() {
	grep -q '^config/version="1\.0\.180-godot"$' "$ROOT_DIR/project.godot"
	grep -q '^const APP_VERSION := "1\.0\.180-godot"$' "$ROOT_DIR/scripts/main_base.gd"
}

check_runtime_contract() {
	local symbol
	for symbol in \
		"func wake_audio_from_interaction" \
		"func start_background_music" \
		"func test_audio_setting" \
		"func show_loading_screen" \
		"func _load_tile_textures"; do
		grep -qF "$symbol" "$ROOT_DIR/scripts/main.gd" "$ROOT_DIR/scripts/main_base.gd"
	done
}

run_ui_smoke() {
	command -v timeout >/dev/null 2>&1 || { printf 'FAIL: timeout command not found\n' >&2; return 1; }
	command -v "$GODOT_BIN" >/dev/null 2>&1 || { printf 'FAIL: Godot not found: %s\n' "$GODOT_BIN" >&2; return 1; }
	timeout --foreground --signal=TERM --kill-after=15s 180s \
		env GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 \
		nice -n 10 ionice -c 2 -n 7 \
		"$GODOT_BIN" --headless --path "$ROOT_DIR" -s scripts/ui_layout_smoke_test.gd
}

case "${1:-}" in
	--help|-h)
		usage
		exit 0
		;;
	--check)
		cd "$ROOT_DIR"
		run_check "main_src part legality" "$PYTHON_BIN" tools/assemble_main.py --check
		;;
	--verify)
		cd "$ROOT_DIR"
		run_check "generated main.gd parity" "$PYTHON_BIN" tools/assemble_main.py --verify
		;;
	--ui-smoke)
		cd "$ROOT_DIR"
		run_check "UI layout regression smoke" run_ui_smoke
		;;
	"")
		cd "$ROOT_DIR"
		run_check "required project files and runtime assets" check_files
		run_check "release version contract" check_version
		run_check "runtime symbol contract" check_runtime_contract
		run_check "main_src part legality" "$PYTHON_BIN" tools/assemble_main.py --check
		run_check "generated main.gd parity" "$PYTHON_BIN" tools/assemble_main.py --verify
		printf '\nPASS: build contract ready for version 1.0.180-godot\n'
		printf 'Run the full commercial gates from README.md before release.\n'
		;;
	*)
		usage >&2
		exit 2
		;;
esac
