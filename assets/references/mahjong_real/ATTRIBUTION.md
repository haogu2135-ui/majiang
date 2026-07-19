# Real Mahjong Tile References

The 42 front tile sprites in `assets/tiles/` are derived from real-photo crops
selected from `Camerash/mahjong-dataset`. The back tile sprite is derived from
a separate real-photo back-side crop.

- Source: https://github.com/Camerash/mahjong-dataset
- Dataset description: "Computer Vision Dataset for Chinese Mahjong Tiles"
- License: MIT, as stated by the dataset README
- Selected source crops: `assets/references/mahjong_real/selected_tiles/*.jpg`
- Import status: historical source only. The old import script has been
  deleted; future playable tile replacement must use GPT-generated candidates
  plus tile-by-tile verification.

Back tile source:

- Source page: https://commons.wikimedia.org/wiki/File:Japanese_Mahjong_Tiles_1.jpg
- License: CC BY-SA 4.0
- Author: Thomas McKelvey Cleaver
- Back-side crop: `assets/references/mahjong_real/tile_back_source.jpg`

These references explain the origin of the current frozen runtime tile PNGs.
They are not an active generation pipeline. Do not rebuild gameplay tiles from
these photos; use the GPT-only tile workflow recorded in
`GPT_IMAGE_TILE_ASSET_BRIEF.md` for any future replacement.

## Class Mapping

Dataset classes are mapped to the project's existing tile filenames as follows:

| Dataset label | Project tile |
| --- | --- |
| dots-1 | tile_pin1.png |
| dots-2 | tile_pin2.png |
| dots-3 | tile_pin3.png |
| dots-4 | tile_pin4.png |
| dots-5 | tile_pin5.png |
| dots-6 | tile_pin6.png |
| dots-7 | tile_pin7.png |
| dots-8 | tile_pin8.png |
| dots-9 | tile_pin9.png |
| bamboo-1 | tile_sou1.png |
| bamboo-2 | tile_sou2.png |
| bamboo-3 | tile_sou3.png |
| bamboo-4 | tile_sou4.png |
| bamboo-5 | tile_sou5.png |
| bamboo-6 | tile_sou6.png |
| bamboo-7 | tile_sou7.png |
| bamboo-8 | tile_sou8.png |
| bamboo-9 | tile_sou9.png |
| characters-1 | tile_man1.png |
| characters-2 | tile_man2.png |
| characters-3 | tile_man3.png |
| characters-4 | tile_man4.png |
| characters-5 | tile_man5.png |
| characters-6 | tile_man6.png |
| characters-7 | tile_man7.png |
| characters-8 | tile_man8.png |
| characters-9 | tile_man9.png |
| honors-east | tile_honor_east.png |
| honors-south | tile_honor_south.png |
| honors-west | tile_honor_west.png |
| honors-north | tile_honor_north.png |
| honors-red | tile_honor_red.png |
| honors-green | tile_honor_green.png |
| honors-white | tile_honor_white.png |
| bonus-spring | tile_flower_h1.png |
| bonus-summer | tile_flower_h2.png |
| bonus-autumn | tile_flower_h3.png |
| bonus-winter | tile_flower_h4.png |
| bonus-plum | tile_flower_h5.png |
| bonus-orchid | tile_flower_h6.png |
| bonus-bamboo | tile_flower_h7.png |
| bonus-chrysanthemum | tile_flower_h8.png |

## Back Tile

`assets/tiles/tile_back.png` is generated from the separate Wikimedia Commons
real-photo crop listed above because the front-tile dataset covers 42 labeled
front tile classes and does not include a matching tile back crop.
