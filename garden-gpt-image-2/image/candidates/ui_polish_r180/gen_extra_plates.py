#!/usr/bin/env python3
from __future__ import annotations
import base64, json, time, io, urllib.request, subprocess, sys
from pathlib import Path
from PIL import Image, ImageOps

CAND = Path(__file__).resolve().parent
STATUS = CAND / "batch_status_r180_extra.json"
LOG = CAND / "gen_extra_plates.log"

def log(msg: str) -> None:
    line = f"[{time.strftime('%H:%M:%S')}] {msg}"
    print(line, flush=True)
    with LOG.open("a", encoding="utf-8") as f:
        f.write(line + "\n")

def creds():
    out = subprocess.check_output(
        ["docker","exec","sub2api-postgres","psql","-U","sub2api","-d","sub2api","-tAc",
         "SELECT credentials::text FROM accounts WHERE id=2;"],
        text=True,
    ).strip()
    return json.loads(out)

STYLE = (
    "Style: premium Chinese guofeng mobile mahjong game UI illustration. "
    "Materials: dark jade lacquer, warm ivory porcelain, muted gold foil edges, ink wash atmosphere, soft cinnabar accents only. "
    "Lighting: calm elegant tactile, soft top light, no harsh specular. "
    "Constraints: no words, no numbers, no logo, no watermark, no people, no readable mahjong tile symbols, no casino neon, no pure green felt flood. "
    "Avoid flat programmatic gradients, beige parchment dominance, cluttered centers."
)

TASKS = [
    ("ui_action_role_rail_v2", (64, 256),
     "Vertical slim role accent rail for mahjong action buttons. Tall narrow dark jade lacquer strip with soft gold filigree edges and tiny cinnabar finials. Empty soft center for tinting. "
     + STYLE),
    ("ui_hand_tray_state_chip_v2", (256, 96),
     "Compact mahjong hand-tray state chip plate, horizontal capsule, gold rim, soft jade core glow, empty center for text overlay. "
     + STYLE),
    ("ui_chat_lane_plate_v1", (768, 128),
     "Horizontal soft message lane plate for mahjong chat list. Dark ink-silk band with warm gold hairline and pale jade inner glow, empty center. "
     + STYLE),
    ("ui_confirm_sheet_plate_v1", (1024, 512),
     "Wide confirmation dialog plate for mahjong UI. Warm dark lacquer wood panel with gold corner brackets, soft ivory reading band center. "
     + STYLE),
    ("ui_button_face_plate_v1", (512, 160),
     "Primary mahjong UI button face plate, horizontal rounded rectangle, dark jade lacquer with gold rim and soft ivory center highlight, empty center for labels. "
     + STYLE),
    ("ui_shop_row_plate_v1", (1024, 192),
     "Shop item row plate for mahjong store UI, wide horizontal dark silk lacquer card with gold corner clips and soft jade edge glow, empty center. "
     + STYLE),
]

def gen(base: str, key: str, prompt: str, target: tuple[int,int]) -> Image.Image:
    w, h = target
    ratio = w / h
    api_size = "1536x1024" if ratio >= 1.18 else ("1024x1536" if ratio <= 0.85 else "1024x1024")
    payload = json.dumps({"model": "gpt-image-2", "prompt": prompt, "size": api_size, "n": 1}).encode()
    last = None
    for attempt in range(1, 5):
        req = urllib.request.Request(
            base.rstrip("/") + "/images/generations",
            data=payload,
            method="POST",
            headers={
                "Authorization": "Bearer " + key,
                "Content-Type": "application/json",
                "Accept": "application/json",
                "User-Agent": "yunzhuo-ui-polish/1.0",
            },
        )
        t0 = time.time()
        try:
            with urllib.request.urlopen(req, timeout=240) as resp:
                data = json.loads(resp.read())
            d0 = data["data"][0]
            if d0.get("b64_json"):
                raw = base64.b64decode(d0["b64_json"])
            else:
                with urllib.request.urlopen(d0["url"], timeout=120) as r:
                    raw = r.read()
            with Image.open(io.BytesIO(raw)) as src:
                img = ImageOps.exif_transpose(src).convert("RGBA")
                img = ImageOps.fit(img, target, method=Image.Resampling.LANCZOS, centering=(0.5, 0.5))
            log(f"  ok attempt={attempt} {time.time()-t0:.1f}s")
            return img
        except Exception as e:
            last = e
            log(f"  fail attempt={attempt} {time.time()-t0:.1f}s {e}")
            time.sleep(min(20, 3 * attempt))
    raise last

def main() -> int:
    LOG.write_text("", encoding="utf-8")
    c = creds()
    base, key = c["base_url"], c["api_key"]
    log(f"start base={base}")
    results = []
    for name, size, prompt in TASKS:
        path = CAND / f"{name}.png"
        log(f"=== {name} ===")
        try:
            img = gen(base, key, prompt, size)
            img.save(path, "PNG")
            log(f"  saved {path} bytes={path.stat().st_size}")
            results.append({"name": name, "ok": True, "path": str(path), "bytes": path.stat().st_size})
            STATUS.write_text(json.dumps(results, indent=2, ensure_ascii=False), encoding="utf-8")
        except Exception as e:
            log(f"  FATAL {e}")
            results.append({"name": name, "ok": False, "error": str(e)})
            STATUS.write_text(json.dumps(results, indent=2, ensure_ascii=False), encoding="utf-8")
    ok = sum(1 for r in results if r.get("ok"))
    log(f"DONE {ok}/{len(results)}")
    return 0 if ok else 1

if __name__ == "__main__":
    sys.exit(main())
