#!/usr/bin/env python3
"""Build the small, licensed display face used by the Chinese page headings.

Requires fonttools. Pass the upstream NotoSerifSC[wght].ttf from Google Fonts.
Body copy and arbitrary player names continue to use the full CJK body font.
"""

import argparse
import hashlib
import json
from pathlib import Path

from fontTools import subset
from fontTools.ttLib import TTFont
from fontTools.varLib.instancer import instantiateVariableFont


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    sources = [root / "scripts/main_base.gd", *sorted((root / "scripts/main_src").glob("*.gd.part"))]
    characters = set("".join(path.read_text() for path in sources))
    characters.update(chr(codepoint) for codepoint in range(32, 127))
    font = TTFont(args.source, recalcTimestamp=False)
    font = instantiateVariableFont(font, {"wght": 600}, inplace=True)
    options = subset.Options()
    options.recalc_timestamp = False
    options.name_IDs = [0, 1, 2, 3, 4, 5, 6, 13, 14]
    subsetter = subset.Subsetter(options=options)
    subsetter.populate(text="".join(sorted(characters)))
    subsetter.subset(font)
    target = root / "assets/fonts/NotoSerifSC-Display.ttf"
    font.save(target)
    provenance = {
        "family": "Noto Serif SC",
        "license": "SIL Open Font License 1.1",
        "source": "https://github.com/google/fonts/blob/main/ofl/notoserifsc/NotoSerifSC%5Bwght%5D.ttf",
        "source_sha256": hashlib.sha256(args.source.read_bytes()).hexdigest(),
        "output_sha256": hashlib.sha256(target.read_bytes()).hexdigest(),
        "weight": 600,
        "glyphs": len(font.getGlyphOrder()),
        "bytes": target.stat().st_size,
        "fallback": "DroidSansFallbackFull.ttf; full CJK body font",
        "rebuild": "python3 tools/build_display_font.py /path/to/NotoSerifSC-wght.ttf",
    }
    (target.parent / "NotoSerifSC-Display.provenance.json").write_text(json.dumps(provenance, indent=2) + "\n")
    print(json.dumps(provenance, indent=2))


if __name__ == "__main__":
    main()
