# Mahjong Tile Body Candidates v11

Date: 2026-07-06

Goal: replace the generated-looking 3D mahjong tile body with a cleaner, smaller-game-friendly 2.5D body while keeping deterministic playable markings.

Mode: GPT Image 2 local Mode A via `ENABLE_GARDEN_IMAGEGEN=1`.

Promoted source:

- `blank_tile_body_thin_chroma_v11_raw.png`
- prompt: `garden-gpt-image-2/prompt/candidates/tiles_v11/blank_tile_body_thin_chroma_v11.md`

Runtime output:

- `assets/tiles_subtle_3d/_tile_body_subtle_3d.png`
- all 42 `assets/tiles_subtle_3d/tile_*.png`
- `build/qa/subtle_3d_tile_contact_sheet.png`

Decision notes:

- `blank_tile_body_thin_chroma_v11_raw.png` was promoted because the chroma-key background cleaned up reliably, the face stayed bright and empty, and the shallow bevel gives a cleaner physical-tile read than the previous cream-button body.
- `blank_tile_body_baked_nineslice_v11_raw.png` kept readable markings but produced noisy/dark edge residue after cleanup.
- `blank_tile_body_real_orthographic_v11_raw.png` and `blank_tile_body_clean_chroma_v11_raw.png` were rejected because the center face gained gray/black texture noise that competes with tile markings.
- `blank_tile_body_low_relief_papercut_v11_raw.png` and `tile_blank_v11_b_bake_grid_raw.png` were rejected because cleanup made the face too dark.
- `tile_blank_v11_a_real_desktop_raw.png` was kept as reference only; it has a stronger tabletop physical feel but rough edges and face texture are too busy for small tiles.

Safety rule:

- GPT generated only blank body/material candidates. Playable symbols still come from deterministic compositing of authoritative `assets/tiles/*.png` sources.
