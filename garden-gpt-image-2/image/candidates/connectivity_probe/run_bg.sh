#!/usr/bin/env bash
set +e
OUT=/home/guhao/majiang/garden-gpt-image-2/image/candidates/connectivity_probe
cd "$OUT" || exit 1
exec >>"$OUT/bg_curl.log" 2>&1
echo "=== $(date -Iseconds) detached start pid=$$ ==="
echo "{\"status\":\"running\",\"pid\":$$,\"started_at\":\"$(date -Iseconds)\"}" > "$OUT/bg_status.json"

echo "$(date -Iseconds) abrdns image start"
curl -m 300 -sS -o "$OUT/abrdns_resp.json" -w "abrdns HTTP:%{http_code} time:%{time_total}\n" \
  https://new-api.abrdns.com/v1/images/generations \
  -H "Authorization: Bearer sk-Tfz2iKijSuudodNDrmOslg5qFijJjBRvCZAIWEPoO6Lv6woS" \
  -H "Content-Type: application/json" \
  -d '{"model":"gpt-image-2","prompt":"Chinese guofeng mahjong UI soft ivory lacquer plate texture seamless no text warm cream pale gold wood grain square UI asset","size":"1024x1024","n":1}'
echo "$(date -Iseconds) abrdns image curl exit=$?"

python3 - <<'PY'
import base64, json
from pathlib import Path
from datetime import datetime, timezone
out = Path("/home/guhao/majiang/garden-gpt-image-2/image/candidates/connectivity_probe")
raw_path = out / "abrdns_resp.json"
raw = raw_path.read_text(encoding="utf-8", errors="replace") if raw_path.exists() else ""
print("abrdns resp len", len(raw))
print(raw[:400])
status = {"via_attempted": ["abrdns_direct"]}
try:
    data = json.loads(raw)
except Exception as e:
    status.update({"status":"error","stage":"abrdns","error":str(e),"raw_head":raw[:500]})
    (out/"bg_status.json").write_text(json.dumps(status,indent=2,ensure_ascii=False),encoding="utf-8")
    raise SystemExit(0)
if "error" in data:
    status.update({"status":"error","stage":"abrdns","error":data["error"]})
    (out/"bg_status.json").write_text(json.dumps(status,indent=2,ensure_ascii=False),encoding="utf-8")
else:
    item = (data.get("data") or [{}])[0]
    path = out / "abrdns_direct_gpt-image-2.png"
    if item.get("b64_json"):
        path.write_bytes(base64.b64decode(item["b64_json"]))
    elif item.get("url"):
        import urllib.request
        urllib.request.urlretrieve(item["url"], path)
    status.update({
        "status":"ok","via":"abrdns_direct","path":str(path),
        "bytes": path.stat().st_size if path.exists() else 0,
        "finished_at": datetime.now(timezone.utc).isoformat(),
    })
    (out/"bg_status.json").write_text(json.dumps(status,indent=2,ensure_ascii=False),encoding="utf-8")
    print("saved abrdns", path, status.get("bytes"))
PY

echo "$(date -Iseconds) sub2api image start"
curl -m 300 -sS -o "$OUT/sub2api_resp.json" -w "sub2api HTTP:%{http_code} time:%{time_total}\n" \
  http://127.0.0.1:8080/v1/images/generations \
  -H "Authorization: Bearer sk-79b753febfa9dc8117c5cde4545b2b0a1c6874b793d4a235f4000ab5300e8844" \
  -H "Content-Type: application/json" \
  -d '{"model":"gpt-image-2","prompt":"Chinese guofeng mahjong UI soft ivory lacquer plate texture seamless no text warm cream pale gold wood grain square UI asset","size":"1024x1024","n":1}'
echo "$(date -Iseconds) sub2api image curl exit=$?"

python3 - <<'PY'
import base64, json
from pathlib import Path
from datetime import datetime, timezone
out = Path("/home/guhao/majiang/garden-gpt-image-2/image/candidates/connectivity_probe")
raw_path = out / "sub2api_resp.json"
raw = raw_path.read_text(encoding="utf-8", errors="replace") if raw_path.exists() else ""
print("sub2api resp len", len(raw))
print(raw[:400])
status = {}
try:
    status = json.loads((out/"bg_status.json").read_text(encoding="utf-8"))
except Exception:
    status = {}
try:
    data = json.loads(raw)
except Exception as e:
    status["sub2api_error"] = str(e)
    status["sub2api_raw_head"] = raw[:500]
    (out/"bg_status.json").write_text(json.dumps(status,indent=2,ensure_ascii=False),encoding="utf-8")
    raise SystemExit(0)
if "error" in data:
    status["sub2api_error"] = data["error"]
else:
    item = (data.get("data") or [{}])[0]
    path = out / "sub2api_enabled_gpt-image-2.png"
    if item.get("b64_json"):
        path.write_bytes(base64.b64decode(item["b64_json"]))
    elif item.get("url"):
        import urllib.request
        urllib.request.urlretrieve(item["url"], path)
    status["sub2api_ok"] = True
    status["sub2api_path"] = str(path)
    status["sub2api_bytes"] = path.stat().st_size if path.exists() else 0
    if status.get("status") != "ok":
        status["status"] = "ok"
        status["via"] = "sub2api"
        status["path"] = str(path)
        status["bytes"] = status["sub2api_bytes"]
    status["sub2api_finished_at"] = datetime.now(timezone.utc).isoformat()
    print("saved sub2api", path, status.get("sub2api_bytes"))
(out/"bg_status.json").write_text(json.dumps(status,indent=2,ensure_ascii=False),encoding="utf-8")
PY

echo "=== $(date -Iseconds) ALL DONE ==="
