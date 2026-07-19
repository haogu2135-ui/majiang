# menu_primary_3d_stage_overlay chroma v2 candidate 01

- Prompt: `garden-gpt-image-2/prompt/menu_primary_3d_stage_overlay_chroma_v2-20260706.md`
- Raw candidate: `garden-gpt-image-2/image/candidates/menu/menu_primary_3d_stage_overlay_chroma_v2_candidate_01.png`
- Clean candidate: `garden-gpt-image-2/image/candidates/menu/menu_primary_3d_stage_overlay_chroma_v2_candidate_01_clean.png`
- Saved prompt copy: `garden-gpt-image-2/prompt/menu-primary-3d-stage-overlay-chroma-v2-output-p-20260706-073427.md`
- Intended stable path after screenshot approval: `assets/illustrations/menu_primary_3d_stage_overlay.png`
- Runtime consumer: `draw_menu_primary_3d_stage()` / `MenuPrimary3DStageGPTOverlay`

## Validation

- Mode: explicit Garden Mode A with `ENABLE_GARDEN_IMAGEGEN=1`.
- Raw output: `1672x941` RGB on green chroma background.
- Clean output: `1280x720` RGBA, alpha `(0, 255)`.
- Transparent corners: yes.
- Edge alpha max: `0`.
- Partial-alpha edge pixels: `7394`.
- Nonzero alpha pixels: `389602`.
- Content check: no text, numbers, logo, people, buttons, or readable mahjong tile faces observed.

## QA Decision

Accepted as a candidate for later promotion and screenshot testing. It matches the intended three-card main menu stage concept and is safe to test under the existing runtime alpha (`0.92`). Do not copy to `assets/illustrations/` until a screenshot pass confirms card alignment and no overlap with title, quick actions, or footer.
