# AI / Gameplay Round 72 - Offline Runtime QA Stabilization

Date: 2026-07-28  
Validation: `scripts/verify_ui_regressions.sh`, `scripts/ai_play_round64_check.gd`

## Problem

The R71 AI strength gates were green, but the product QA sweep exposed runtime
stability gaps that blocked commercial evidence:

- Offline smoke could trip Godot 4 async-call semantics when a test or input
  path invoked `human_discard()` without awaiting the first frame yield.
- Screenshot capture was too expensive because every page rebuilt a fresh main
  scene, making the 1280/960 capture gates vulnerable to the 180s hard timeout.
- Runtime shutdown left visual tweens and transient UI references alive long
  enough to create noisy freed-target warnings and leak-scan risk.
- Capture mode still initialized audio/TTS-heavy paths that add no value to
  deterministic visual QA.

## Fix

- Replace direct offline AI continuation calls with a queued
  `schedule_ai_until_human()` dispatcher, and make `human_discard()` synchronous
  by resolving the discard on the next process frame through a one-shot signal.
- Add runtime visual/tween shutdown helpers so offline smoke and screenshot
  capture can drain transient FX without freeing the whole game tree mid-tween.
- Reuse one main scene across the page screenshot matrix, reset each page in
  place, and skip audio setup while `YUNZHUO_UI_CAPTURE=1` is active.
- Register missing optional GPT illustration variants and tighten smoke
  assertions around the new commercial no-text-fallback tile policy.
- Guard seasonal blossom callbacks with instance-id checks so delayed tween
  callbacks do not dereference freed nodes.

## Result

- Full UI/gameplay regression QA passed: `12 passed, 0 failed`.
- Offline gameplay smoke passed as part of the full QA gate.
- 1280x720 and 960x540 screenshot captures both completed and rebuilt contact
  sheets; both screenshot manifests passed freshness, size, alpha, and nonblank
  checks.
- Runtime resource leak scan passed after the shutdown/drain changes.
- The full serial low-resource QA run completed in `5:51.46` with no concurrent
  Godot/xvfb/image-generation processes started.
- R64 fixed-seed strength gate still passes after the runtime scheduling
  changes: high-danger easy/hard `0.476/0.423`, deal-in `0.50/0.50`, human
  deal-in `0.00/0.00`, finished `2/2/2`.

## Resource Impact

Normal gameplay cost stays minimal. The offline AI dispatcher only queues a
single deferred continuation when the game needs to advance from AI to the next
human decision. Capture-mode audio skipping and single-scene screenshot reuse
reduce QA wall time and avoid extra Godot launches while preserving the serial
resource policy.

## Run

```bash
python3 tools/assemble_main.py --verify
scripts/verify_ui_regressions.sh
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 godot --headless --path . -s scripts/ai_play_round64_check.gd
```

All commands passed on 2026-07-28 under the serial low-resource policy.
