# petals_winter_v3 alpha audit candidate

- Output candidate: `garden-gpt-image-2/image/candidates/alpha_audit/petals_winter_v3_candidate_05.png`
- Prior candidate note: candidate_01/02/03 all rendered a stemmed bamboo branch (candidate_02 also added a whole blossom). Root cause: "bamboo" is too strong a prior for the model and keeps producing a stalk regardless of negatives. candidate_04 fixed the subject (frost-dusted white plum petals only) but the white-on-white luma keyer hollowed out the snow-white petal cores. This revision keeps the petal subject and switches to a solid blue chroma-key background so the white petals can be keyed by hue instead of luma.
- Alpha decision: this candidate is generated on a solid blue chroma background (NOT a checkerboard) and keyed with a blue chroma-key step, because winter's snow-white petals collide with the luma-based transparency keyer used for the other three seasons.
- Stable target after review only: `assets/illustrations/petals_winter.png`
- Size: `128x128`
- Mode: Garden GPT Image 2 candidate generation
- Source: alpha audit follow-up from `qa/agents/gpt_image_agent.md`
- Style decision: semi-realistic translucent petals (supersedes v2 ink-wash direction)

```text
Create a production-ready winter petal cluster asset for a mahjong game flower-bloom effect.

Asset type: reusable PNG VFX sprite, target 128x128, rendered on a solid pure-blue chroma-key background for later keying.

Subject: 4 to 6 individual detached white plum petals drifting diagonally — cool snow-white with faint pale-blue and silver-gray shading, each a single loose petal fully separated from the others with clear empty space between them, semi-realistic and translucent, with soft light passing through each petal, delicate curled edges, faint natural veining, a light dusting of frost-white highlights and a few tiny snow flecks, and a few tiny gold specks. These are loose falling single petals only — no leaves, no branch, no stem, no twig, no plant, never a whole assembled blossom, no flower center, no stamen, not a full flower head.

Style and material: soft semi-realistic painted petals with gentle translucency and subtle rim light, premium mobile game effect, elegant and restrained. NOT a flat ink-wash brush stroke.

Composition: 4 to 7 sparse petals scattered across the canvas with generous empty blue padding around them, no hard focal object, no border frame, no central mass.

Background requirements:
- Fill the ENTIRE background with one flat, uniform, solid pure-blue chroma-key color (#005BFF), edge to edge, behind and between all petals.
- The blue must be a single even color with no gradient, no vignette, no texture, no shadow, and no lighter or darker patches.
- Keep a clear blue gap between every petal so each stays separable.
- Do NOT paint transparency, alpha, checkerboard squares, white, gray, or any second background color. The only non-petal color in the image is the blue.

Constraints: no words, no numbers, no logo, no watermark, no people, no faces, no readable tile symbols.

Avoid: bamboo, bamboo leaves, any leaf, whole branch, standing stalk, connected stem, twigs, elements attached to a branch, complete flower, whole blossom, flower head, flower with center stamen, assembled bloom, central mass, dark ink blobs, black smudges, mold-like spots, heavy black splatter, photoreal flower photo, neon particles, dense full bloom, blue color bleeding onto the petals, blue rim light on petal edges, petals tinted the same blue as the background.
```
