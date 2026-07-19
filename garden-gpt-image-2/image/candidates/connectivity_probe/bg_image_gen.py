#!/usr/bin/env python3
"""Background Sub2API + direct abrdns gpt-image-2 probe."""
from __future__ import annotations

import base64
import json
import os
import sys
import time
import urllib.error
import urllib.request
from datetime import datetime, timezone
from pathlib import Path

OUT = Path(__file__).resolve().parent
STATUS = OUT / "bg_status.json"
LOG = OUT / "bg_image_gen.log"

SUB2API_KEY = os.environ.get(
    "SUB2API_KEY",
    "sk-79b753febfa9dc8117c5cde4545b2b0a1c6874b793d4a235f4000ab5300e8844",
)
SUB2API_BASE = os.environ.get("SUB2API_BASE", "http://127.0.0.1:8080/v1")
ABRDNS_KEY = os.environ.get(
    "ABRDNS_KEY",
    "sk-Tfz2iKijSuudodNDrmOslg5qFijJjBRvCZAIWEPoO6Lv6woS",
)
ABRDNS_BASE = os.environ.get("ABRDNS_BASE", "https://new-api.abrdns.com/v1")

PROMPT = (
    "Chinese guofeng mahjong game UI soft ivory lacquer plate texture, seamless, "
    "no text, no characters, soft warm cream and pale gold, subtle wood grain, "
    "square composition, high quality UI asset"
)


def log(msg: str) -> None:
    line = f"[{datetime.now(timezone.utc).isoformat()}] {msg}"
    print(line, flush=True)
    with LOG.open("a", encoding="utf-8") as f:
        f.write(line + "\n")


def write_status(payload: dict) -> None:
    STATUS.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")


def post_images(base: str, key: str, timeout: int = 300) -> dict:
    url = base.rstrip("/") + "/images/generations"
    body = json.dumps(
        {
            "model": "gpt-image-2",
            "prompt": PROMPT,
            "size": "1024x1024",
            "n": 1,
        }
    ).encode("utf-8")
    req = urllib.request.Request(
        url,
        data=body,
        method="POST",
        headers={
            "Authorization": f"Bearer {key}",
            "Content-Type": "application/json",
            "Accept": "application/json",
        },
    )
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            raw = resp.read()
            return {
                "ok": True,
                "status": resp.status,
                "data": json.loads(raw.decode("utf-8")),
            }
    except urllib.error.HTTPError as e:
        raw = e.read().decode("utf-8", errors="replace")
        try:
            data = json.loads(raw)
        except Exception:
            data = {"raw": raw[:2000]}
        return {"ok": False, "status": e.code, "data": data}
    except Exception as e:
        return {"ok": False, "status": 0, "data": {"error": f"{type(e).__name__}: {e}"}}


def save_image(data: dict, path: Path) -> int:
    items = data.get("data") or []
    if not items:
        raise RuntimeError(f"no data in response keys={list(data.keys())}")
    item = items[0]
    if item.get("b64_json"):
        path.write_bytes(base64.b64decode(item["b64_json"]))
        return path.stat().st_size
    if item.get("url"):
        urllib.request.urlretrieve(item["url"], path)
        return path.stat().st_size
    raise RuntimeError(f"no b64/url keys={list(item.keys())}")


def try_once(name: str, base: str, key: str, out_name: str) -> dict:
    log(f"TRY {name} base={base}")
    t0 = time.time()
    result = post_images(base, key, timeout=300)
    elapsed = round(time.time() - t0, 2)
    log(f"RESULT {name} ok={result['ok']} status={result['status']} elapsed={elapsed}s")
    if not result["ok"]:
        log(f"ERR {name}: {json.dumps(result['data'], ensure_ascii=False)[:800]}")
        return {
            "name": name,
            "ok": False,
            "status": result["status"],
            "elapsed": elapsed,
            "error": result["data"],
        }
    path = OUT / out_name
    size = save_image(result["data"], path)
    log(f"SAVED {name} -> {path} ({size} bytes)")
    return {
        "name": name,
        "ok": True,
        "status": result["status"],
        "elapsed": elapsed,
        "path": str(path),
        "bytes": size,
    }


def main() -> int:
    write_status(
        {
            "status": "running",
            "started_at": datetime.now(timezone.utc).isoformat(),
            "pid": os.getpid(),
        }
    )
    log("=== bg image gen start ===")
    results = []

    # Prefer direct abrdns first (more stable per prior notes), then sub2api
    results.append(
        try_once(
            "abrdns_direct",
            ABRDNS_BASE,
            ABRDNS_KEY,
            "abrdns_direct_gpt-image-2.png",
        )
    )
    results.append(
        try_once(
            "sub2api",
            SUB2API_BASE,
            SUB2API_KEY,
            "sub2api_enabled_gpt-image-2.png",
        )
    )

    ok_any = any(r.get("ok") for r in results)
    write_status(
        {
            "status": "ok" if ok_any else "error",
            "finished_at": datetime.now(timezone.utc).isoformat(),
            "results": results,
        }
    )
    log(f"=== done ok_any={ok_any} ===")
    return 0 if ok_any else 1


if __name__ == "__main__":
    sys.exit(main())
