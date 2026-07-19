Use REFERENCE_0 as the authoritative source image. The reference image contains the current 2D mahjong tile faces from the actual game assets, arranged as a contact sheet. These tile faces are the only correct designs.

Task:
Transform the reference contact sheet into a clean 3D mahjong tile sprite atlas/contact sheet suitable for later slicing and importing into Godot.

Absolute preservation requirements:
- Preserve every tile face symbol, color, ordering, proportions, and identity exactly as shown in REFERENCE_0.
- Preserve the same left-to-right, top-to-bottom tile ordering and the same overall contact-sheet structure.
- Preserve all Chinese characters, numbers, suit marks, flower art, season/flower text, dragon/wind symbols, dot patterns, bamboo patterns, character-suit marks, and the tile back pattern exactly.
- Do not invent, replace, translate, simplify, reinterpret, redraw, or restyle any symbol.
- Do not change any tile identity. A tile that is 1-man in the reference must remain 1-man; a flower tile must remain the same flower tile; the back tile must remain the same back tile.
- Do not add labels, captions, UI text, watermarks, logos, explanations, decorative text, or extra symbols.

Allowed transformation only:
- Convert each existing flat 2D tile into a physical 3D mahjong tile while keeping the original face artwork locked to the front surface.
- Add a warm white porcelain tile body.
- Add subtle rounded bevels, realistic tile thickness, and a slight top-down 3D perspective.
- Add jade green side edges with a restrained muted-gold rim or trim.
- Add soft tabletop contact shadows under each tile, consistent across the atlas.
- Add unified soft studio lighting and gentle porcelain highlights without obscuring any symbol.

Composition:
- Output a single 1536x1024 PNG contact sheet.
- Keep all tiles evenly spaced in a grid, with clear gutters for later slicing.
- Every tile must remain upright, fully visible, uncropped, and separated from neighboring tiles.
- The result should look like one coherent 3D asset atlas made from the current game tile artwork, not a newly designed mahjong set.

Negative constraints:
- No new tile faces, no alternate mahjong glyphs, no generic stock mahjong symbols.
- No extra dice, coins, cards, chips, table props, hands, people, game board, menus, or UI panels.
- No scene background or decorative environment; keep it clean and atlas-like.
- No perspective drift between tiles, no mismatched material style, no inconsistent scale.
