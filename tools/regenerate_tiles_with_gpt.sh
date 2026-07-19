#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

generate_args=("$@")
import_args=()
while (($#)); do
  case "$1" in
    --only)
      if (($# < 2)); then
        echo "--only requires a value" >&2
        exit 2
      fi
      import_args+=(--only "$2")
      shift 2
      ;;
    --only=*)
      import_args+=(--only "${1#--only=}")
      shift
      ;;
    *)
      shift
      ;;
  esac
done

python3 tools/generate_gpt_mahjong_tiles.py --force "${generate_args[@]}"
python3 tools/import_gpt_mahjong_tiles.py "${import_args[@]}"
python3 - <<'PY'
from pathlib import Path
from PIL import Image

root = Path.cwd()
tile_dir = root / "assets" / "tiles"
expected = [
    "tile_back.png",
    *[f"tile_man{n}.png" for n in range(1, 10)],
    *[f"tile_pin{n}.png" for n in range(1, 10)],
    *[f"tile_sou{n}.png" for n in range(1, 10)],
    "tile_honor_east.png",
    "tile_honor_south.png",
    "tile_honor_west.png",
    "tile_honor_north.png",
    "tile_honor_red.png",
    "tile_honor_green.png",
    "tile_honor_white.png",
    *[f"tile_flower_h{n}.png" for n in range(1, 9)],
]
bad = []
for name in expected:
    path = tile_dir / name
    if not path.exists():
        bad.append(f"missing {name}")
        continue
    with Image.open(path) as image:
        if image.size != (200, 280):
            bad.append(f"{name} has size {image.size}")
if bad:
    raise SystemExit("\n".join(bad))
print(f"Verified {len(expected)} tile sprites at 200x280 in {tile_dir}")
PY
