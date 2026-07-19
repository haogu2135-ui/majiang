# Tiles v15 Agent Candidates

Date: 2026-07-07 UTC

## Mode Detection

- Skill: gpt-image-2
- Detection command: `ENABLE_GARDEN_IMAGEGEN=1 OPENAI_BASE_URL=http://127.0.0.1:8080/v1 OPENAI_IMAGE_MODEL=gpt-image-2 node /root/.codex/skills/gpt-image-2/scripts/check-mode.js --json`
- Result: Mode A / Garden local image generation
- Garden flag: enabled (`ENABLE_GARDEN_IMAGEGEN=1`)
- API key: present
- Base URL: `http://127.0.0.1:8080/v1`
- Model: `gpt-image-2`

## Generation Settings

- Size requested: `1024x1536`
- Quality requested: `high`
- Output format: `png`
- Background requested: opaque pure chroma-key `#00ff00`
- Note: the first raw API response reported `quality: low` despite the `--quality high` request; the gateway still returned a 1024x1536 PNG.

## Candidates

### continuous_porcelain_slab_v15

- Prompt: `garden-gpt-image-2/prompt/candidates/tiles_v15_agent/continuous_porcelain_slab_v15.md`
- Image: `garden-gpt-image-2/image/candidates/tiles_v15_agent/continuous_porcelain_slab_v15.png`
- Raw generated backup: `garden-gpt-image-2/image/candidates/tiles_v15_agent/continuous_porcelain_slab_v15_raw.png`
- Initial visual screening: pass for blank tile body. No mahjong symbols, text, inner frame, groove, or checkerboard visible. Center is continuous and empty. Right and bottom volume shading is soft.
- Background screening: raw generation had near-green background variation, then the main candidate PNG was normalized so sampled outer-border pixels are exact `#00ff00`.

### baked_ui_depth_layer_v15

- Prompt: `garden-gpt-image-2/prompt/candidates/tiles_v15_agent/baked_ui_depth_layer_v15.md`
- Image: `garden-gpt-image-2/image/candidates/tiles_v15_agent/baked_ui_depth_layer_v15.png`
- Raw generated backup: `garden-gpt-image-2/image/candidates/tiles_v15_agent/baked_ui_depth_layer_v15_raw.png`
- Initial visual screening: pass as a blank baked UI depth direction. No mahjong symbols, text, inner frame, groove, or checkerboard visible. Center remains blank and continuous.
- Caution: bottom and right depth/ambient occlusion are more pronounced than candidate 1, so this is the stronger-depth option.
- Background screening: raw generation had near-green background variation, then the main candidate PNG was normalized so sampled outer-border pixels are exact `#00ff00`.

## Verification

- Both main candidate images are PNG, RGB, 1024x1536.
- Pixel sampling after normalization: outer 20px border sampled as exact `(0, 255, 0)` for both main candidate images.
- No Godot code was modified.
- No files under `assets/tiles_subtle_3d` were modified.
- No runtime resources were replaced.
