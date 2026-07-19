# offline_table_3d_overlay rim-shadow v3 candidate 01 report

- Prompt: `garden-gpt-image-2/prompt/offline_table_3d_overlay_rim_shadow_v3-20260706.md`
- Raw candidate: `garden-gpt-image-2/image/candidates/p0/offline_table_3d_overlay_rim_shadow_v3_candidate_01.png`
- Clean candidate: `garden-gpt-image-2/image/candidates/p0/offline_table_3d_overlay_rim_shadow_v3_candidate_01_clean.png`
- Stable target after approval: `assets/illustrations/offline_table_3d_overlay.png`

## Validation

- Raw candidate: `1672x941 RGB`; used only as the chroma-key source.
- Clean candidate: `1280x720 RGBA`, alpha range `(0,255)`, nonzero alpha pixels `222232`.
- Strict center zone remains fully transparent; the critical center zone has only 10 low-alpha pixels, max alpha `70`, from soft shadow residue.
- The overlay is edge-local: black-lacquer rim highlights, jade corner depth, brushed-gold accents, and low-alpha contact shadows. It does not introduce text, tile faces, dice, UI controls, or a complete tabletop.

## Decision

Accepted and promoted. The previous v2 candidate was rejected because it read as a full table surface. This v3 candidate works as a sparse foreground depth overlay above `table_gpt_backdrop` and below engine-rendered gameplay nodes.

## Screenshot Checks

- `build/qa/pages/03_offline_battle.png`
- `build/qa/pages_960x540/03_offline_battle.png`

Both reviewed screenshots keep the discard river, walls, hand tray, pending action dock, seat panels, and HUD readable.
