#!/usr/bin/env bash
# Serial local TCP integration gate for the newline-delimited online protocol.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_BIN="${GODOT_BIN:-godot}"
EXPECTED_GODOT_VERSION_PREFIX="${EXPECTED_GODOT_VERSION_PREFIX:-4.6.3}"
REPORT_DIR="$ROOT_DIR/build/qa/online_protocol_evidence"
REPORT="$REPORT_DIR/EVIDENCE_LATEST.md"
LOG="$REPORT_DIR/online_protocol_smoke.log"
mkdir -p "$REPORT_DIR"

if pgrep -ia '^godot' >/dev/null 2>&1 || pgrep -ax Xvfb >/dev/null 2>&1; then
	echo "Refusing to start online protocol QA while another Godot/Xvfb process is active." >&2
	exit 1
fi

GODOT_VERSION="$("$GODOT_BIN" --version 2>/dev/null | head -n 1)"
if [[ "$GODOT_VERSION" != "$EXPECTED_GODOT_VERSION_PREFIX"* ]]; then
	echo "Expected Godot $EXPECTED_GODOT_VERSION_PREFIX, got: ${GODOT_VERSION:-unavailable}" >&2
	exit 2
fi

set +e
timeout --foreground --signal=TERM --kill-after=15s 180s \
	env GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 \
	nice -n 10 ionice -c 2 -n 7 \
	"$GODOT_BIN" --headless --path "$ROOT_DIR" -s scripts/online_protocol_smoke_test.gd \
	>"$LOG" 2>&1
EXIT_CODE=$?
set -e

STATUS="PASS"
if [ "$EXIT_CODE" -ne 0 ]; then STATUS="FAIL"; fi
REVISION="$(git -C "$ROOT_DIR" rev-parse --short HEAD 2>/dev/null || printf 'unknown')"
{
	echo "# Online Protocol Integration Evidence Latest"
	echo
	echo "- Time: $(date '+%Y-%m-%d %H:%M:%S %z')"
	printf -- '- Git revision: `%s`\n' "$REVISION"
	echo "- Result: **$STATUS**"
	printf -- '- Godot: `%s` (`%s`)\n' "$GODOT_VERSION" "$GODOT_BIN"
	echo "- Contract: real localhost TCPServer/StreamPeerTCP, byte-safe newline framing, fragmented JSON, 1,500-message burst, bounded fields and wire buffer, oversized-frame rejection, outbound actions, in-game disconnect recovery, and reconnect"
	printf -- '- Log: `%s`\n' "$LOG"
} >"$REPORT"

cat "$LOG"
echo "wrote $REPORT"
exit "$EXIT_CODE"
