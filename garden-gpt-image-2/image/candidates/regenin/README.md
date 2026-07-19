# regenin.online image pipeline

Tool: `tools/generate_regenin_image.py`

## API (verified 2026-07-12)
| Method | Path | Notes |
|---|---|---|
| GET | `/api/status` | `{"accounts": N}` |
| GET | `/api/models` | image/video models + point costs |
| POST | `/api/chat` | SSE; body `{prompt,type,model,ratio,resolution}` |

No API key required for the public web API. Response media is usually hosted on `cdn.oreateai.com`.

### SSE shape
```
data: {"event":"start",...}
data: {"event":"ping",...}
data: {"event":"generating","data":{"result":"![](https://cdn.../xxx.png)"}}
data: {"event":"end",...}
```

## Measured samples (this machine)
| Request | Real raw pixels | Format | Gen time | Watermark detect |
|---|---:|---|---:|---|
| GPT Image 2.0 / 1K / 1:1 | **512×512** | JPEG | ~48s | br strip often |
| GPT Image 2.0 / 2K / 1:1 | **1024×1024** | JPEG | ~58s | br/bc/bl footer bands |
| Nano Banana 2 Lite / 1K | 512×512 | JPEG | ~5s | usually clean simple icons |

Tool auto-appends “no watermark/logo/caption” to prompts, downloads CDN (`--insecure` TLS for this host), optional heuristic dewmark, optional `--normalize-size`.

## Watermark removal
- Heuristic HF/edge scoring on corner + bottom bands
- Feathered local inpaint (Pillow only, no OpenCV)
- Flags: `--remove-watermark` (default on generate), `--force-corner-clean`, `--watermark-strength`
- **Not perfect** — always visual-QA before promoting into `assets/`

## Engineering usability verdict

### Can use now
- Concept / mood / illustration drafts
- Menu/hero decorative stills
- Temporary placeholders while gateway GPT/Grok is down
- Candidate exploration before committing final art

### Not drop-in ship-ready for commercial tiles/UI chrome
- Resolution labels overstate pixels (`1K`→512, `2K`→1024 observed)
- Opaque JPEG, no true alpha (need `clean_gpt_transparent_asset.py` or hand cutout for sprites)
- Watermark cleaner is probabilistic; bottom text/logo can survive or leave blur scars
- Public free API: rate/account pool risk, CDN dependency, no SLA
- Style consistency weaker than controlled local gateway + project brief prompts

### Recommended project policy
1. Generate with **2K** (or higher when available) + `--normalize-size` to target.
2. Keep `.raw.*` beside cleaned PNG for audit.
3. Manual eye-check corners/bottom before copy into `assets/illustrations` or tile faces.
4. Prefer local `127.0.0.1:8080` / project GPT pipeline for final ship assets.
5. Use regenin as **fallback source**, not sole production renderer.

## Commands
```bash
python3 tools/generate_regenin_image.py status
python3 tools/generate_regenin_image.py models

python3 tools/generate_regenin_image.py generate \
  --prompt "..." \
  --model "GPT Image 2.0" \
  --resolution 2K \
  --ratio 1:1 \
  --out garden-gpt-image-2/image/candidates/regenin/demo.png \
  --normalize-size 1024x1024 \
  --remove-watermark \
  --report-json garden-gpt-image-2/image/candidates/regenin/demo.report.json

python3 tools/generate_regenin_image.py dewmark \
  --input path/to/raw.jpg \
  --out path/to/clean.png \
  --force-corner-clean
```

## Files in this folder
- `mahjong_zhong_regenin_1k.png` / `.raw.jpg` / `.report.json`
- `mahjong_zhong_regenin_2k.png` / `.raw.jpg` / `.report.json`
