# pending_claim_status_strip_v2_candidate_01

## Inputs

- Prompt: `garden-gpt-image-2/prompt/p0_pending_claim_status_strip_v2_no_tile_well-20260706.md`
- Previous rejection addressed: old pending-claim strip baked an empty tile placeholder; this v2 prompt explicitly forbids tile wells, empty slots, tile-shaped frames, text, labels, numbers, route lines, buttons, and tile symbols.

## Mode A

- Check command: `ENABLE_GARDEN_IMAGEGEN=1 node /root/.codex/skills/gpt-image-2/scripts/check-mode.js --json`
- Result: Mode A / Garden local generation.
- Summary: `MODE A · Garden local image generation`, API base `http://127.0.0.1:8080/v1`, model `gpt-image-2`, `ENABLE_GARDEN_IMAGEGEN=1`, API key present.

## Files

- Normalized chroma source: `garden-gpt-image-2/image/candidates/p0/pending_claim_status_strip_v2_candidate_01_chroma.png`
- Clean true-alpha output: `garden-gpt-image-2/image/candidates/p0/pending_claim_status_strip_v2_candidate_01_clean.png`
- Dark preview: `garden-gpt-image-2/image/candidates/p0/pending_claim_status_strip_v2_candidate_01_preview_dark.png`
- Raw API output retained for traceability: `garden-gpt-image-2/image/candidates/p0/pending_claim_status_strip_v2_candidate_01_chroma_raw.png`

## Checks

- `pending_claim_status_strip_v2_candidate_01_chroma.png`: `768x120 RGB`; four corners are pure `#00ff00`.
- `pending_claim_status_strip_v2_candidate_01_clean.png`: `768x120 RGBA`; alpha extrema `(0, 255)`; four corner alpha values `[0, 0, 0, 0]`.
- `pending_claim_status_strip_v2_candidate_01_preview_dark.png`: `768x120 RGB`; no visible green-screen residue after cleanup.
- Visual review: no visible text, numbers, watermark, checkerboard baking, route lines, buttons, tile symbols, tile well, blank tile rectangle, or readable tile face.
- Layout review: left source-seal backing is decorative only; middle and right lanes remain low-contrast and suitable for Godot-rendered text/focus overlays.

## Recommendation

- Recommend main-thread integration: yes, use `pending_claim_status_strip_v2_candidate_01_clean.png` if the main UI pass wants the pending-claim material strip replacement.
