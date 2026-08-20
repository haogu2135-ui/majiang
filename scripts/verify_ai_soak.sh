#!/usr/bin/env bash
# Longer, serial AI stability evidence. Kept separate from the fast commercial gate.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_BIN="${GODOT_BIN:-godot}"
EXPECTED_GODOT_VERSION_PREFIX="${EXPECTED_GODOT_VERSION_PREFIX:-4.6.3}"
REPORT_DIR="$ROOT_DIR/build/qa/ai_play_soak_evidence"
REPORT="$REPORT_DIR/EVIDENCE_LATEST.md"
LOG="$REPORT_DIR/ai_play_soak.log"
mkdir -p "$REPORT_DIR"

ensure_no_runtime() {
	local active=""
	active+="$(pgrep -ia '^godot' 2>/dev/null || true)"
	active+="$(pgrep -ax Xvfb 2>/dev/null || true)"
	active+="$(pgrep -af '(^|/)[x]vfb-run([[:space:]]|$)' 2>/dev/null || true)"
	if [ -n "$active" ]; then
		echo "Refusing to start AI soak while another Godot/Xvfb process is active." >&2
		echo "$active" >&2
		return 1
	fi
}

ensure_no_runtime
GODOT_VERSION="$("$GODOT_BIN" --version 2>/dev/null | head -n 1)"
if [[ "$GODOT_VERSION" != "$EXPECTED_GODOT_VERSION_PREFIX"* ]]; then
	echo "Expected Godot $EXPECTED_GODOT_VERSION_PREFIX, got: ${GODOT_VERSION:-unavailable}" >&2
	exit 2
fi
set +e
timeout --foreground --signal=TERM --kill-after=15s 180s \
	env GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 \
	nice -n 10 ionice -c 2 -n 7 \
	"$GODOT_BIN" --headless --path "$ROOT_DIR" -s scripts/ai_play_soak_check.gd \
	2>&1 | tee "$LOG"
EXIT_CODE=${PIPESTATUS[0]}
set -e

STATUS="PASS"
if [ "$EXIT_CODE" -ne 0 ]; then STATUS="FAIL"; fi
REVISION="$(git -C "$ROOT_DIR" rev-parse --short HEAD 2>/dev/null || printf 'unknown')"
{
	echo "# AI Long Soak Evidence Latest"
	echo
	echo "- Time: $(date '+%Y-%m-%d %H:%M:%S %z')"
	printf -- '- Git revision: `%s`\n' "$REVISION"
	echo "- Result: **$STATUS**"
	printf -- '- Godot: `%s` (`%s`)\n' "$GODOT_VERSION" "$GODOT_BIN"
	echo "- Contract: 5 independent seeds, 2 paired easy/hard hands per seed, fixed normal player probe, per-seed terminal/tile/score integrity, and aggregate difficulty/actionable-pressure gates"
	echo "- Log: $LOG"
	echo "- Durable artifacts: $REPORT_DIR/AI_SOAK_LATEST.json and $REPORT_DIR/AI_SOAK_LATEST.md"
} >"$REPORT"

echo "wrote $REPORT"
exit "$EXIT_CODE"
