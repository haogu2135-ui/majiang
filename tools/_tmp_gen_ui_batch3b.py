#!/usr/bin/env python3
import base64, json, time, urllib.request, io, subprocess, shutil
from pathlib import Path
from PIL import Image, ImageOps, ImageFilter

ROOT = Path('/home/guhao/majiang')
CAND = ROOT / 'garden-gpt-image-2/image/candidates/ui_polish_r180'
ASSETS = ROOT / 'assets/illustrations'
BAK = ASSETS / '_replaced_20260719'
LOG = Path('/tmp/gen_ui_polish_batch3b.log')
CAND.mkdir(parents=True, exist_ok=True)
BAK.mkdir(exist_ok=True)

STYLE = (
 "Style: premium Chinese guofeng mobile mahjong UI illustration. "
 "Materials: dark jade lacquer, warm ivory porcelain, muted gold foil edges, soft ink wash. "
 "Soft transparent outer margin, empty soft center for UI overlay. "
 "No words, no numbers, no logo, no watermark, no people, no mahjong tile symbols, no neon."
)
TASKS = [
 ("ui_toast_banner_dense_v1", (1024,256), "1536x1024", "toast_gpt_banner.png",
  "Horizontal toast banner plate for mobile mahjong: dark lacquer ribbon with gold hairline and soft ivory glow center empty for short status text. " + STYLE),
 ("ui_seat_info_plate_dense_v1", (512,256), "1536x1024", "ui_seat_info_plate.png",
  "Seat info plate card for four-player mahjong HUD: rounded dark jade lacquer panel, gold corner brackets, soft ivory reading band empty center. " + STYLE),
 ("ui_river_soft_wash_dense_v1", (1024,512), "1536x1024", "ui_river_soft_wash.png",
  "Soft ivory-gold river wash plate for discarded tile bed, very soft feathered edges, low-contrast guofeng silk texture, empty center. " + STYLE),
 ("ui_button_face_dense_v1", (512,160), "1536x1024", "ui_button_face_plate.png",
  "Horizontal primary button face plate, dark jade lacquer with warm gold rim, soft ivory center empty for button label. " + STYLE),
]

def log(m):
    line=f"[{time.strftime('%H:%M:%S')}] {m}"
    print(line, flush=True)
    with LOG.open('a', encoding='utf-8') as f: f.write(line+'\n')

def creds():
    out=subprocess.check_output([
        'docker','exec','sub2api-postgres','psql','-U','sub2api','-d','sub2api','-tAc',
        'SELECT credentials::text FROM accounts WHERE id=2;'
    ], text=True).strip()
    return json.loads(out)

def feather(im, edge_px):
    im=im.convert('RGBA'); w,h=im.size
    mask=Image.new('L',(w,h),255); px=mask.load(); e=max(4,edge_px)
    for y in range(h):
        for x in range(w):
            d=min(x,w-1-x,y,h-1-y)
            if d>=e: a=255
            else:
                t=d/float(e); t=t*t*(3-2*t); a=int(255*t)
            cx=min(x,w-1-x)/max(1.0,e*1.3); cy=min(y,h-1-y)/max(1.0,e*1.3)
            if cx<1 and cy<1: a=int(a*(0.55+0.45*min(cx,cy)))
            px[x,y]=a
    mask=mask.filter(ImageFilter.GaussianBlur(max(1.0,e*0.22)))
    r,g,b,a0=im.split(); a_new=Image.new('L',(w,h)); ap=a0.load(); mp=mask.load(); npx=a_new.load()
    for y in range(h):
        for x in range(w): npx[x,y]=(ap[x,y]*mp[x,y])//255
    return Image.merge('RGBA',(r,g,b,a_new))

def gen(base, key, prompt, api_size):
    payload=json.dumps({"model":"gpt-image-2","prompt":prompt,"size":api_size,"n":1}).encode()
    for attempt in range(1,8):
        t0=time.time()
        req=urllib.request.Request(base.rstrip('/')+'/images/generations', data=payload, method='POST', headers={
            'Authorization':'Bearer '+key,'Content-Type':'application/json','Accept':'application/json',
            'User-Agent':'yunzhuo-ui-polish/1.1'})
        try:
            with urllib.request.urlopen(req, timeout=200) as resp:
                obj=json.loads(resp.read())
            item=(obj.get('data') or [None])[0]
            b64=item.get('b64_json') or item.get('b64'); url=item.get('url')
            raw=base64.b64decode(b64) if b64 else urllib.request.urlopen(url, timeout=60).read()
            log(f'  ok attempt={attempt} {time.time()-t0:.1f}s bytes={len(raw)}')
            return Image.open(io.BytesIO(raw))
        except Exception as e:
            log(f'  fail attempt={attempt} {time.time()-t0:.1f}s {e}')
            time.sleep(min(35, 5*attempt))
    return None

def main():
    # append mode if already started
    c=creds()
    base=(c.get('base_url') or 'https://new-api.abrdns.com/v1').rstrip('/')
    if not base.endswith('/v1'): base=base+'/v1'
    key=c['api_key']
    log(f'start base={base}')
    results=[]
    for name,size,api_size,asset_name,prompt in TASKS:
        # skip if already denser produced this run
        cand = CAND / f'{name}.png'
        if cand.exists() and cand.stat().st_mtime > time.time() - 3600 and cand.stat().st_size > 20000:
            log(f'=== {name} SKIP existing cand ===')
            results.append({'name':name,'ok':True,'skipped':True})
            continue
        log(f'=== {name} ===')
        src=gen(base,key,prompt,api_size)
        if src is None:
            results.append({'name':name,'ok':False}); continue
        img=ImageOps.exif_transpose(src).convert('RGBA')
        img=ImageOps.fit(img,size,method=Image.Resampling.LANCZOS,centering=(0.5,0.5))
        edge=14 if min(size)<=160 else 22
        img=feather(img,edge)
        img.save(cand,'PNG')
        asset=ASSETS/asset_name
        if asset.exists():
            shutil.copy2(asset, BAK/f'pre_batch3b_{asset_name}')
        img.save(asset,'PNG')
        log(f'  saved {cand.name} -> {asset_name} bytes={asset.stat().st_size}')
        results.append({'name':name,'ok':True,'bytes':asset.stat().st_size})
    ok=sum(1 for r in results if r.get('ok'))
    log(json.dumps(results, ensure_ascii=False))
    log(f'DONE {ok}/{len(results)}')
    return 0 if ok==len(results) else 1

if __name__=='__main__':
    raise SystemExit(main())
