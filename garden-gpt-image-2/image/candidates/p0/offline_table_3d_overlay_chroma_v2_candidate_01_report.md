# offline_table_3d_overlay chroma v2 candidate 01

- Prompt: `garden-gpt-image-2/prompt/offline_table_3d_overlay_chroma_v2-20260706.md`
- Raw candidate: `garden-gpt-image-2/image/candidates/p0/offline_table_3d_overlay_chroma_v2_candidate_01.png`
- Clean candidate: `garden-gpt-image-2/image/candidates/p0/offline_table_3d_overlay_chroma_v2_candidate_01_clean.png`
- Intended stable path after screenshot approval: `assets/illustrations/offline_table_3d_overlay.png`
- Runtime consumer: `render_game()` / `OfflineTable3DOverlayTexture`

## Validation

- Mode: explicit Garden Mode A with `ENABLE_GARDEN_IMAGEGEN=1`.
- Raw output: `1672x941` RGB on green chroma background.
- Clean output: `1280x720` RGBA, alpha `(0, 255)`.
- Transparent corners: yes.
- Edge alpha max: `0`.
- Partial-alpha edge pixels: `5634`.
- Nonzero alpha pixels: `521260`.
- Content check: no text, numbers, logo, people, buttons, or readable mahjong tile faces observed.

## QA Decision

Hold as a technical candidate only. The alpha and format are usable, but the composition reads as a complete table surface rather than a lightweight overlay. It may compete with `table_gpt_backdrop_v4.png` and runtime table/wall layout even at low alpha. Prefer screenshot-testing this only after the main menu overlay candidate, or regenerate with a stricter "rim and contact shadows only, no full felt surface" brief.
