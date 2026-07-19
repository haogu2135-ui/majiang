# tiles_v14_local blank-body candidate

- Date: 2026-07-06
- Purpose: test another 3D/2.5D mahjong tile effect using GPT Image 2 while keeping playable markings deterministic.
- Mode: local GPT Image 2 Mode A via `ENABLE_GARDEN_IMAGEGEN=1`, gateway `http://127.0.0.1:8080/v1`.

## Candidate

- Prompt: `garden-gpt-image-2/prompt/candidates/tiles_v14_local/blank_tile_body_orthographic_low_relief_v14.md`
- Raw image: `garden-gpt-image-2/image/candidates/tiles_v14_local/blank_tile_body_orthographic_low_relief_v14_raw.png`
- Normalized body preview: `.tmp/subtle_3d_v14_low_relief/_tile_body_subtle_3d.png`
- Deterministic composed samples: `.tmp/subtle_3d_v14_low_relief/tile_*.png`
- Contact sheet: `build/qa/subtle_3d_tile_contact_sheet_v14_low_relief.png`

## Review

- Pros: clean blank center, no generated playable markings, restrained orthographic shape, more porcelain/jade material than the current procedural thin-bevel runtime body.
- Cons: the 200x280 composite retains thin dark top-edge artifacts and an inset/frame-like rim on several tiles, which makes it read less cleanly in the full contact sheet.
- Decision: do not promote this candidate to `assets/tiles_subtle_3d/`. Keep it as a useful prompt direction for a follow-up pass that removes the top-edge line and reduces the inset rim.

## Safety Rule

GPT-generated assets must remain blank body/material candidates only. Runtime playable tile faces should continue to be composed from `assets/tiles/*.png` markings so tile identities stay deterministic.
