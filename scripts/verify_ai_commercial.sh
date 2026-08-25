#!/usr/bin/env bash
# Unified, serial commercial gate for offline rules and AI behavior.

set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEFAULT_GODOT_BIN="/opt/godot/Godot_v4.6.3-stable_linux.arm64"
if [ -z "${GODOT_BIN:-}" ]; then
	if [ -x "$DEFAULT_GODOT_BIN" ]; then
		GODOT_BIN="$DEFAULT_GODOT_BIN"
	else
		GODOT_BIN="godot"
	fi
fi
EXPECTED_GODOT_VERSION_PREFIX="${EXPECTED_GODOT_VERSION_PREFIX:-4.6.3}"
REPORT_DIR="$ROOT_DIR/build/qa/ai_play_commercial_evidence"
REPORT="$REPORT_DIR/EVIDENCE_LATEST.md"
LOG_DIR="$REPORT_DIR/logs"
TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S %z')"
REVISION="$(git -C "$ROOT_DIR" rev-parse --short HEAD 2>/dev/null || printf 'unknown')"
REVISION_FULL="$(git -C "$ROOT_DIR" rev-parse HEAD 2>/dev/null || printf 'unknown')"
git_state_fingerprint() {
	{
		git -C "$ROOT_DIR" diff --binary -- "$@" 2>/dev/null || true
		git -C "$ROOT_DIR" status --porcelain -- "$@" 2>/dev/null || true
	} | sha256sum | awk '{print $1}'
}
WORKTREE_DIFF_FINGERPRINT="$(git_state_fingerprint)"
RUNTIME_SOURCE_DIFF_FINGERPRINT="$(git_state_fingerprint project.godot scripts/main_base.gd scripts/main.gd scripts/main_src scripts/ui)"
QA_BATCH_ID="$(date -u '+%Y%m%dT%H%M%SZ')-${REVISION}-${RUNTIME_SOURCE_DIFF_FINGERPRINT:0:12}"
WORKTREE_STATE="clean"
RUNTIME_SOURCE_STATE="clean"
if [ -n "$(git -C "$ROOT_DIR" status --porcelain 2>/dev/null)" ]; then
	WORKTREE_STATE="dirty"
fi
if [ -n "$(git -C "$ROOT_DIR" status --porcelain -- project.godot scripts/main_base.gd scripts/main.gd scripts/main_src 2>/dev/null)" ]; then
	RUNTIME_SOURCE_STATE="dirty"
fi
GODOT_TIMEOUT_SECONDS=180
GODOT_KILL_GRACE_SECONDS=15
RESUME=false
RUN_MODE="fresh"

if [ "${1:-}" = "--resume" ]; then
	RESUME=true
	RUN_MODE="resume successful Godot logs"
	shift
fi
if [ "$#" -ne 0 ]; then
	echo "usage: $0 [--resume]" >&2
	exit 2
fi

PASS=0
FAIL=0
CACHED=0
EXECUTED=0
ROWS=()

mkdir -p "$LOG_DIR"

ensure_no_active_runtime() {
	local active=""
	active+="$(pgrep -ia '^godot' 2>/dev/null || true)"
	active+="$(pgrep -ax Xvfb 2>/dev/null || true)"
	active+="$(pgrep -af '(^|/)[x]vfb-run([[:space:]]|$)' 2>/dev/null || true)"
	if [ -n "$active" ]; then
		echo "Refusing to start AI QA while another Godot/Xvfb process is active:" >&2
		echo "$active" >&2
		return 1
	fi
	return 0
}

run_low_resource_godot() {
	if ! ensure_no_active_runtime; then
		return 1
	fi
	timeout --foreground --signal=TERM --kill-after="${GODOT_KILL_GRACE_SECONDS}s" "${GODOT_TIMEOUT_SECONDS}s" \
		env GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 \
		nice -n 10 ionice -c 2 -n 7 "$GODOT_BIN" "$@"
}

check_target_godot_version() {
	local version
	command -v "$GODOT_BIN" >/dev/null 2>&1 || return 1
	version="$("$GODOT_BIN" --version 2>/dev/null | head -n 1)"
	printf '%s\n' "$version"
	[[ "$version" == "$EXPECTED_GODOT_VERSION_PREFIX"* ]]
}

check_release_version() {
	# Use grep, not rg: rg is not guaranteed to exist in a non-interactive shell.
	grep -qE '^config/version="1\.0\.180-godot"$' "$ROOT_DIR/project.godot" &&
		grep -qE '^const APP_VERSION := "1\.0\.180-godot"$' "$ROOT_DIR/scripts/main_base.gd"
}

run_check() {
	local category="$1"
	local name="$2"
	local log_name="$3"
	shift 3
	local log_path="$LOG_DIR/$log_name"
	local started finished elapsed exit_code
	if $RESUME &&
		[ "$RUNTIME_SOURCE_STATE" = "clean" ] &&
		[ -f "$log_path" ] &&
		grep -q '=== RESULT: OK ===' "$log_path" &&
		grep -Fqx "=== QA REVISION: $REVISION_FULL ===" "$log_path"; then
		echo "PASS: $name (cached successful Godot log)"
		ROWS+=("| $category | $name | PASS | cached | \`$log_path\` |")
		PASS=$((PASS + 1))
		CACHED=$((CACHED + 1))
		return 0
	fi

	EXECUTED=$((EXECUTED + 1))
	started="$(date +%s)"
	echo "==> $name"
	if (cd "$ROOT_DIR" && "$@") >"$log_path" 2>&1; then
		if [ "$RUNTIME_SOURCE_STATE" = "clean" ]; then
			printf '\n=== QA REVISION: %s ===\n' "$REVISION_FULL" >>"$log_path"
		else
			printf '\n=== QA REVISION: unbound-dirty-runtime ===\n' >>"$log_path"
		fi
		finished="$(date +%s)"
		elapsed=$((finished - started))
		echo "PASS: $name (${elapsed}s)"
		ROWS+=("| $category | $name | PASS | ${elapsed}s | \`$log_path\` |")
		PASS=$((PASS + 1))
	else
		exit_code=$?
		finished="$(date +%s)"
		elapsed=$((finished - started))
		echo "FAIL: $name (exit $exit_code, ${elapsed}s)"
		ROWS+=("| $category | $name | FAIL (exit $exit_code) | ${elapsed}s | \`$log_path\` |")
		FAIL=$((FAIL + 1))
	fi
}

run_godot_check() {
	local category="$1"
	local round="$2"
	local name="$3"
	run_check "$category" "$name" "ai_play_round${round}.log" \
		run_low_resource_godot --headless --path "$ROOT_DIR" -s "scripts/ai_play_round${round}_check.gd"
}

run_check "Build contract" "main_src part legality" "assemble_check.log" \
	python3 tools/assemble_main.py --check
run_check "Build contract" "main.gd generated output parity" "assemble_verify.log" \
	python3 tools/assemble_main.py --verify
run_check "Build contract" "release version remains 1.0.180-godot" "version_contract.log" \
	check_release_version
run_check "Build contract" "target Godot engine is 4.6.3" "godot_version.log" \
	check_target_godot_version

run_godot_check "Rule legality" 15 "wall exhaustion ends the hand safely"
run_godot_check "Rule legality" 30 "illegal win declarations cannot settle"
run_godot_check "Rule legality" 32 "discard and rob-gang sources are proven"
run_godot_check "Information fairness" 13 "added-gang decisions ignore concealed waits"
run_godot_check "Rule legality" 41 "discard furiten blocks ron and chankan"
run_godot_check "Rule legality" 42 "passed-win state follows the local contract"
run_godot_check "Rule legality" 57 "passed-win multi-wait lifecycle remains correct"
run_godot_check "Rule legality" 58 "post-claim discard bans cannot deadlock play"
run_godot_check "Rule legality" 60 "package-payer settlement remains conserved"
run_godot_check "Rule legality" 61 "wall-draw tenpai payments remain conserved"
run_godot_check "Endgame policy" 63 "late-wall open claims preserve tenpai discipline"
run_godot_check "Rule legality" 65 "single-winner ron arbitration is deterministic"
run_godot_check "Endgame policy" 67 "late-wall self-gang discipline is bounded"
run_godot_check "Runtime stability" 66 "fresh-scene benchmarks initialize and finish"
run_godot_check "Tile integrity" 74 "the full 144-tile ledger is conserved"
run_check "Rule variants" "all local rule profiles complete AI hands and score correctly" "ai_rule_variant_soak.log" \
	run_low_resource_godot --headless --path "$ROOT_DIR" -s "scripts/ai_play_rule_variant_soak_check.gd"
run_godot_check "Scoring contract" 77 "advertised special hands score correctly"
run_godot_check "Score integrity" 82 "all difficulties conserve table score"
run_godot_check "Strategy quality" 87 "pure-suit route reward is counted once"
run_godot_check "Strategy quality" 88 "each discard candidate owns its route plan"
run_godot_check "Strength evidence" 68 "paired multi-seed strength pack passes"
run_godot_check "Strength evidence" 89 "independent fixed-player pressure sample passes"
run_godot_check "Strength evidence" 90 "only actionable danger counts against hard AI"
run_godot_check "Information fairness" 91 "hidden-hand swaps cannot alter added-gang AI"
run_godot_check "Strategy quality" 96 "own concealed tiles inform defensive visibility"
run_godot_check "Endgame policy" 92 "hard guard covers catastrophic thin-tenpai pressure"
run_godot_check "Strategy quality" 93 "avoidable all-opponent danger telemetry stays actionable"
run_godot_check "Strength evidence" 94 "all-opponent avoidable danger is mandatory for commercial PASS"
run_godot_check "Strategy quality" 95 "exact-score discard ties preserve decision quality"
run_godot_check "Strategy quality" 97 "exposed melds affect numeric route scoring"

STATUS="PASS"
if [ "$FAIL" -ne 0 ]; then
	STATUS="FAIL"
fi

{
	echo "# AI / Gameplay Commercial Evidence Latest"
	echo ""
	echo "- Time: $TIMESTAMP"
	echo "- Git revision: \`$REVISION\`"
	echo "- QA batch: \`$QA_BATCH_ID\`"
	echo "- Worktree state: $WORKTREE_STATE"
	echo "- Runtime source vs HEAD: $RUNTIME_SOURCE_STATE"
	echo "- Worktree diff fingerprint: \`$WORKTREE_DIFF_FINGERPRINT\`"
	echo "- Runtime source diff fingerprint: \`$RUNTIME_SOURCE_DIFF_FINGERPRINT\`"
	echo "- Version: \`1.0.180-godot\`"
	echo "- Godot binary: \`$GODOT_BIN\`"
	echo "- Required Godot version: \`$EXPECTED_GODOT_VERSION_PREFIX\`"
	echo "- Result: **$STATUS**"
	echo "- Passed checks: $PASS"
	echo "- Failed checks: $FAIL"
	echo "- Executed checks: $EXECUTED"
	echo "- Cached checks: $CACHED"
	echo "- Run mode: $RUN_MODE"
	echo "- Execution policy: serial Godot processes, \`LP_NUM_THREADS=1\`, low CPU/I/O priority, 180-second hard timeout per Godot check"
	echo ""
	echo "## Gates"
	echo ""
	echo "| Area | Gate | Result | Elapsed | Log |"
	echo "|---|---|---|---:|---|"
	for row in "${ROWS[@]}"; do
		echo "$row"
	done
	echo ""
	echo "## Coverage Contract"
	echo ""
	echo "- Rule legality: legal tile source, self-draw/ron/chankan, furiten, passed-win, post-claim discard bans, package payer, exhaustive-draw settlement, ron arbitration, and advertised scoring."
	echo "- Endgame claims: late-wall open claims and self-gangs must preserve tenpai discipline while useful actions remain available."
	echo "- Fairness: decisions under test use only public information; concealed-hand swaps cannot change added-gang declarations."
	echo "- Defensive visibility: the acting AI counts its own concealed tiles for wall, feed, and deal-in risk without inspecting opponents' concealed tiles."
	echo "- Integrity: every sampled terminal hand keeps the 144-tile physical ledger and the four-seat score ledger."
	echo "- Difficulty and strength: easy/normal/hard conservation is exercised; paired easy/hard multi-seed packs and an independent fixed-player probe must pass."
	echo "- Strength outcome telemetry: raw danger and whole-table ron incidence remain recorded; actionable safer alternatives and deal-ins to the fixed player probe decide the commercial defense gate."
	echo "- Strategy determinism: exact-score discard ties prefer lower shanten, higher ukeire, lower combined danger, then canonical tile order."
	echo "- Hard-defense diagnostics: catastrophic thin-tenpai pressure is guarded; all-opponent danger telemetry only counts same-shanten actionable alternatives and is mandatory for commercial PASS."
	echo "- Performance: fresh-scene, primary strength, and independent strength samples must finish within their low-resource budgets."
	echo ""
	echo "## Durable Strength Artifact"
	echo ""
	echo "- Markdown: \`$REPORT_DIR/STRENGTH_PACK_LATEST.md\`"
	echo "- JSON: \`$REPORT_DIR/STRENGTH_PACK_LATEST.json\`"
	echo ""
	echo "This gate proves the repository's declared local rules and AI acceptance contract on the recorded revision. It does not certify an external regional-rules authority or replace manual UI review and signed-release auditing."
} >"$REPORT"

echo ""
echo "wrote $REPORT"
echo "result: $STATUS ($PASS passed, $FAIL failed)"

if [ "$FAIL" -ne 0 ]; then
	exit 1
fi
