# shop_charm_icon_set_v2_candidate_02 Report

- Date: 2026-07-06 UTC
- Prompt source: `garden-gpt-image-2/prompt/shop_charm_icon_set_v2-20260705.md`
- Chroma prompt archive: `garden-gpt-image-2/prompt/shop_charm_icon_set_v2_candidate_02_chroma-20260706.md`
- Mode: GPT Image 2 Garden Mode A (`ENABLE_GARDEN_IMAGEGEN=1`)

## Candidate Results

- `shop_charm_icon_set_v2_candidate_01.png`: rejected. The generated image was `1254x1254`, fully opaque, and baked a gray checkerboard background into RGB pixels.
- `shop_charm_icon_set_v2_candidate_02_chroma.png`: accepted as a source plate after chroma-key cleanup. The generated image was `1254x1254`, fully opaque, with a near-green-screen background.
- `shop_charm_icon_set_v2_candidate_02_clean_v2.png`: accepted cleaned sheet. It was normalized to `1024x1024` RGBA with transparent corners and no visible green-key residue.

## Promoted Crops

- `garden-gpt-image-2/image/candidates/shop/shop_charm_huan_v2_candidate_02_clean_v2.png` -> `assets/illustrations/shop_charm_huan.png`
- `garden-gpt-image-2/image/candidates/shop/shop_charm_kan_v2_candidate_02_clean_v2.png` -> `assets/illustrations/shop_charm_kan.png`
- `garden-gpt-image-2/image/candidates/shop/shop_charm_yun_v2_candidate_02_clean_v2.png` -> `assets/illustrations/shop_charm_yun.png`
- `garden-gpt-image-2/image/candidates/shop/shop_charm_bei_v2_candidate_02_clean_v2.png` -> `assets/illustrations/shop_charm_bei.png`

Previous opaque stable PNGs were backed up under:

- `assets/illustrations/_replaced_20260706/shop_charm_v1_opaque/`

## Validation

- Stable assets are `512x512` RGBA PNGs.
- Alpha extrema for all four stable assets: `(0, 255)`.
- All four stable assets have transparent corners.
- 96px dark-row preview: `garden-gpt-image-2/image/candidates/shop/shop_charm_v2_candidate_02_clean_v2_96px_preview.png`.
- Visual screenshot review passed at `1280x720` and `960x540`: four shop items are distinguishable without relying only on text or generic icons.
- `scripts/ui_layout_smoke_test.gd` now asserts `ShopItemCharmTexture_*` is present and `ShopItemNativeCharm_*` is absent for all four shop rows.
