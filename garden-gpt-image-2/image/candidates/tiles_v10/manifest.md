# Blank Mahjong Tile Body Candidates v10

Mode:
- Initial skill check: `B-or-C` because `ENABLE_GARDEN_IMAGEGEN` was unset.
- Actual generation path: temporary `ENABLE_GARDEN_IMAGEGEN=1` command environment, using the existing local OpenAI-compatible gateway and `gpt-image-2`.
- No changes were made to `scripts/main.gd`.

Candidates:

1. Orthographic white jade low-relief
- Image: `garden-gpt-image-2/image/candidates/tiles_v10/blank_tile_body_orthographic_white_jade_v10_200x280.png`
- Raw: `garden-gpt-image-2/image/candidates/tiles_v10/blank_tile_body_orthographic_white_jade_v10_raw.png`
- Alpha full-size: `garden-gpt-image-2/image/candidates/tiles_v10/blank_tile_body_orthographic_white_jade_v10_alpha_full.png`
- Prompt: `garden-gpt-image-2/prompt/candidates/tiles_v10/blank_tile_body_orthographic_white_jade_v10.md`
- QA: 200x280 RGBA, visible alpha bbox `(9, 10, 194, 275)`, no visible green residual.
- Note: Best production candidate. Clean center, premium material, refined side lip after downscale.

2. Guofeng silk / paper-cut low-relief
- Image: `garden-gpt-image-2/image/candidates/tiles_v10/blank_tile_body_guofeng_silk_papercut_v10_200x280.png`
- Raw: `garden-gpt-image-2/image/candidates/tiles_v10/blank_tile_body_guofeng_silk_papercut_v10_raw.png`
- Alpha full-size: `garden-gpt-image-2/image/candidates/tiles_v10/blank_tile_body_guofeng_silk_papercut_v10_alpha_full.png`
- Prompt: `garden-gpt-image-2/prompt/candidates/tiles_v10/blank_tile_body_guofeng_silk_papercut_v10.md`
- QA: 200x280 RGBA, visible alpha bbox `(10, 10, 193, 275)`, no visible green residual.
- Note: Strongest artisanal texture, but the rim reads thicker; better as a style reference or special UI skin.

3. Programmatic baked nine-slice body
- Image: `garden-gpt-image-2/image/candidates/tiles_v10/blank_tile_body_baked_nineslice_v10_200x280.png`
- Nine-slice guide preview: `garden-gpt-image-2/image/candidates/tiles_v10/blank_tile_body_baked_nineslice_v10_9slice_guides.png`
- Prompt / recipe: `garden-gpt-image-2/prompt/candidates/tiles_v10/blank_tile_body_baked_nineslice_v10.md`
- QA: 200x280 RGBA, visible alpha bbox `(6, 4, 195, 278)`, no visible green residual.
- Nine-slice margins: left `24`, top `24`, right `24`, bottom `24`.
- Note: Most reusable and deterministic. Less material richness than GPT candidates, but safe if generated output drifts.

Recommendation:
- Use candidate 1 for the next visual integration test.
- Keep candidate 3 as a deterministic fallback / NinePatchRect source.
- Do not use candidate 2 as the default base unless a more illustrated hand-painted tile skin is desired.
