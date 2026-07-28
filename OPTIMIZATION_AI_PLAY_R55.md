# AI / Gameplay Round 55 - Context-Stable Threat Cache

Date: 2026-07-27  
Validation: `scripts/ai_play_round55_check.gd`

## Problem

Threat reports can receive an AI evaluation context with captured visibility and
opponent state. Their cache key was still reconstructed from mutable live state
for every opponent report. This repeated key construction and could make one
batch mix its snapshot analysis with a later table update.

## Fix

- Capture one context-local threat table signature in `make_ai_evaluation_context`.
- Reuse that signature for all seat threat reports using the context.
- Preserve the live-state key path for callers without a context.
- Include the supplied visibility snapshot in the context signature.

## Resource Impact

One AI evaluation pass now constructs its long threat table signature once,
rather than once per opponent report. Existing report scoring and cache
isolation remain unchanged.

## Run

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=1 nice -n 10 ionice -c 2 -n 7 godot --headless --path . -s scripts/ai_play_round55_check.gd
```
