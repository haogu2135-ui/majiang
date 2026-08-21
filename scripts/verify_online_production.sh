#!/usr/bin/env bash
# Probe the declared production endpoint without creating a room or mutating state.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEFAULT_HOST="129.146.180.88"
DEFAULT_PORT="23333"
HOST="${ONLINE_PRODUCTION_HOST:-$DEFAULT_HOST}"
PORT="${ONLINE_PRODUCTION_PORT:-$DEFAULT_PORT}"
TIMEOUT_SECONDS="${ONLINE_PRODUCTION_TIMEOUT_SECONDS:-8}"
NAME="${ONLINE_PRODUCTION_NAME:-QA180}"
REPORT_DIR="$ROOT_DIR/build/qa/online_production_evidence"
REPORT="$REPORT_DIR/EVIDENCE_LATEST.md"
STATUS="FAIL"
FAIL_REASON="not started"
RESPONSE_SUMMARY="none"

fail() {
	FAIL_REASON="$*"
	exit 1
}

write_report() {
	mkdir -p "$REPORT_DIR"
	{
		echo "# Production Online Handshake Evidence"
		echo
		echo "- Time: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
		echo "- Result: $STATUS"
		echo "- Endpoint: \`$HOST:$PORT\`"
		echo "- Timeout: \`${TIMEOUT_SECONDS}s\`"
		echo "- Probe: newline-delimited JSON hello only; no room creation or join action"
		if [ "$STATUS" = "PASS" ]; then
			echo "- Response: $RESPONSE_SUMMARY"
		else
			echo "- Failure: $FAIL_REASON"
		fi
		echo
		echo "This probe proves only production TCP reachability and a compatible hello response. It does not replace multi-client online soak or Android device validation."
	} > "$REPORT"
}
trap write_report EXIT

usage() {
	cat <<EOF
Usage:
  $(basename "$0") [HOST] [PORT]
  $(basename "$0") --self-test

Environment overrides: ONLINE_PRODUCTION_HOST, ONLINE_PRODUCTION_PORT,
ONLINE_PRODUCTION_TIMEOUT_SECONDS, ONLINE_PRODUCTION_NAME.
EOF
}

self_test() {
	command -v python3 >/dev/null 2>&1 || fail "python3 not found"
	command -v timeout >/dev/null 2>&1 || fail "timeout command not found"
	python3 - <<'PY'
import json
payload = json.dumps({"type": "hello", "name": "QA180"})
assert json.loads(payload)["type"] == "hello"
print("PASS: production hello payload self-test")
PY
	[[ "$DEFAULT_PORT" =~ ^[0-9]+$ ]] || fail "default port is not numeric"
	[ "$DEFAULT_PORT" -ge 1 ] && [ "$DEFAULT_PORT" -le 65535 ] || fail "default port is out of range"
	echo "PASS: production online probe self-test"
}

case "${1:-}" in
	--self-test)
		[ "$#" -eq 1 ] || fail "--self-test does not accept endpoint arguments"
		trap - EXIT
		self_test
		STATUS="PASS"
		exit 0
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
		;;
	*)
		[ "$#" -le 2 ] || fail "probe accepts at most HOST and PORT"
		HOST="$1"
		PORT="${2:-$DEFAULT_PORT}"
		;;
esac

[[ "$HOST" != *$'\n'* && "$HOST" != *$'\r'* ]] || fail "host contains a line break"
[[ "$PORT" =~ ^[0-9]+$ ]] || fail "port is not numeric: $PORT"
[ "$PORT" -ge 1 ] && [ "$PORT" -le 65535 ] || fail "port is out of range: $PORT"
[[ "$TIMEOUT_SECONDS" =~ ^[1-9][0-9]*$ ]] || fail "timeout must be a positive integer"

HELLO="$(python3 - "$NAME" <<'PY'
import json
import sys
print(json.dumps({"type": "hello", "name": sys.argv[1]}, ensure_ascii=False))
PY
)"

PROBE_COMMAND='set -e
exec 3<>"/dev/tcp/$1/$2"
printf "%s\\n" "$3" >&3
IFS= read -r response <&3
printf "%s\\n" "$response"'
set +e
PROBE_OUTPUT="$(timeout --foreground "${TIMEOUT_SECONDS}s" bash -c "$PROBE_COMMAND" _ "$HOST" "$PORT" "$HELLO" 2>&1)"
PROBE_EXIT=$?
set -e
if [ "$PROBE_EXIT" -ne 0 ]; then
	if [ "$PROBE_EXIT" -eq 124 ]; then
		fail "TCP connection or hello response timed out after ${TIMEOUT_SECONDS}s"
	fi
	fail "TCP hello probe failed: ${PROBE_OUTPUT:-unknown error}"
fi
RESPONSE="$(printf '%s\n' "$PROBE_OUTPUT" | head -n 1)"
[ -n "$RESPONSE" ] || fail "server returned an empty response"

RESPONSE_SUMMARY="$(printf '%s' "$RESPONSE" | tr '\n' ' ' | cut -c1-240)"
if ! python3 - "$RESPONSE" <<'PY'
import json
import sys

payload = json.loads(sys.argv[1])
if not isinstance(payload, dict):
    raise SystemExit("response is not an object")
kind = str(payload.get("type", payload.get("event", payload.get("kind", "")))).lower().replace("_", "").replace("-", "")
if kind not in {"welcome", "hello", "info", "ack", "roomstate", "gamestate"}:
    raise SystemExit(f"unexpected response type: {kind or 'missing'}")
PY
then
	fail "production server returned an incompatible hello response: $RESPONSE_SUMMARY"
fi

STATUS="PASS"
FAIL_REASON=""
exit 0
