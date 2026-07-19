# wall_live_feedback_kit_v2_candidate_01

## Final Status

- Rejected by main-thread review.
- Reason: despite valid size/basic alpha checks, alpha/visual scan found unacceptable horizontal cleanup residue:
  - Strong alpha thin horizontal line/shadow residue below the first rail around `y=133-156`, spanning more than 600 px.
  - Weak alpha horizontal line residue between the third and fourth rails around `y=333-356`.
- Do not promote this candidate to stable assets.

## Inputs

- Prompt: `garden-gpt-image-2/prompt/p0_wall_live_feedback_kit_v2_chroma_no_edge-20260706.md`
- Source spec: `qa/agents/gpt_image_agent.md`
- Prior prompt reused: `garden-gpt-image-2/prompt/p0_wall_live_feedback_kit_v1.md`
- Prior rejection addressed: `wall_live_feedback_kit_v1_candidate_01_clean.png` was not promoted because cleanup left visible light edge residue.

## Mode A

- Check command: `ENABLE_GARDEN_IMAGEGEN=1 node /root/.codex/skills/gpt-image-2/scripts/check-mode.js --json`
- Result: Mode A / Garden local generation.
- Summary: `MODE A · Garden local image generation`, API base `http://127.0.0.1:8080/v1`, model `gpt-image-2`, `ENABLE_GARDEN_IMAGEGEN=1`, API key present.

## Files

- Raw chroma output: `garden-gpt-image-2/image/candidates/p0/wall_live_feedback_kit_v2_candidate_01_chroma_raw.png`
- Clean true-alpha output: `garden-gpt-image-2/image/candidates/p0/wall_live_feedback_kit_v2_candidate_01_clean.png`
- Dark preview: `garden-gpt-image-2/image/candidates/p0/wall_live_feedback_kit_v2_candidate_01_preview_dark.png`

## Checks

- Raw output: `2172x724 RGB`; generated on near-#ff00ff chroma background.
- Clean output: `1536x512 RGBA`.
- Alpha extrema: `(0, 255)`.
- Corner alpha values: `[0, 0, 0, 0]`.
- Alpha counts: transparent `456623`, opaque `310931`, partial `18878`.
- Magenta key residue pixels after strict cleanup: `0`.
- Partial light-edge pixels after strict cleanup: `0`.
- Opaque gray checkerboard-like pixels: `0`.
- Visual review: four slim progress rails, four empty count badge frames, three update pulse glows, and two corner warning accents are present.
- Content review: no visible text, numbers, watermark, checkerboard background, mahjong tile faces, tile symbols, route labels, or baked count placeholders.
- Runtime safety: rail and badge interiors remain empty and low-contrast for Godot-rendered live digits.

## Cleanup Notes

- The first cleanup pass preserved a visible magenta edge on rails and badge frames, so it was not accepted.
- The final clean file was regenerated from the same raw chroma candidate with stricter key-color removal and matte decontamination.
- No second GPT generation was needed.

## Recommendation

- Recommend main-thread acceptance: no.
- Do not promote automatically from this worker; stable `assets/illustrations/` was not modified.
