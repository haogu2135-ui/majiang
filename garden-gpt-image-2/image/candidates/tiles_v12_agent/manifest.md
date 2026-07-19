# tiles_v12_agent blank mahjong tile candidates

Mode: A / Garden local image generation
Model: gpt-image-2 via http://127.0.0.1:8080/v1
Generation date: 2026-07-06
Requested scope: blank tile bodies only, no tile face characters, no atlas assembly.

## Outputs

### Candidate 1: shallow-relief ivory/jade

Prompt:
- `garden-gpt-image-2/prompt/candidates/tiles_v12_agent/blank_tile_body_shallow_relief_ivory_jade_v12.md`

Image:
- `garden-gpt-image-2/image/candidates/tiles_v12_agent/blank_tile_body_shallow_relief_ivory_jade_v12.png`

Image facts:
- 1060x1484 PNG, RGB
- Chroma green background, no alpha channel

Pros:
- Stronger ivory/jade material read.
- Soft shallow-relief rim gives a premium physical tile feel.
- Blank central face remains large enough for programmatic glyph overlay.

Cons:
- Outer rim and highlight are more prominent, so large glyphs may feel slightly inset.
- Slightly heavier baked shadow and green edge contamination may need cleanup before final atlas use.

### Candidate 2: 2.5D baked UI tile

Prompt:
- `garden-gpt-image-2/prompt/candidates/tiles_v12_agent/blank_tile_body_25d_baked_ui_v12.md`

Image:
- `garden-gpt-image-2/image/candidates/tiles_v12_agent/blank_tile_body_25d_baked_ui_v12.png`

Image facts:
- 1060x1484 PNG, RGB
- Chroma green background, no alpha channel

Pros:
- Flatter and cleaner UI asset silhouette.
- Larger uninterrupted blank face, better for adding existing tile glyphs.
- Thin side edge and restrained bevel should scale down better to 200x280.

Cons:
- Less distinctive material character than the ivory/jade candidate.
- Contact shadow and green background still require keying or cleanup.

## Recommendation

Use Candidate 2 (`blank_tile_body_25d_baked_ui_v12.png`) for the next programmatic composition pass. It is less visually noisy, has the broadest usable face, and should tolerate downscaling and glyph overlay better than the more material-heavy shallow-relief option.

Candidate 1 is a good fallback if the art direction wants a more premium jade/ivory physical tile look.
