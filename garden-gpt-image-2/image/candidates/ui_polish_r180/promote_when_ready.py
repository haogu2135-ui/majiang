#!/usr/bin/env python3
import json, time, shutil
from pathlib import Path
from PIL import Image, ImageOps
cand=Path(__file__).resolve().parent
assets=Path('/home/guhao/majiang/assets/illustrations')
pid_file=cand/'gen_extra_plates.pid'
map_pairs=[
 ('ui_chat_lane_plate_v1.png','ui_chat_lane_plate.png',(768,128)),
 ('ui_confirm_sheet_plate_v1.png','ui_confirm_sheet_plate.png',(1024,512)),
 ('ui_button_face_plate_v1.png','ui_button_face_plate.png',(512,160)),
 ('ui_shop_row_plate_v1.png','ui_shop_row_plate.png',(1024,192)),
]
log=cand/'promote_when_ready.log'
def L(m):
    line=f"[{time.strftime('%H:%M:%S')}] {m}"
    print(line, flush=True)
    log.open('a').write(line+'\n')

pid=int(pid_file.read_text().strip()) if pid_file.exists() else -1
L(f'watch pid={pid}')
for i in range(80):
    alive=(pid>0 and Path(f'/proc/{pid}').exists())
    for src_name,dst_name,size in map_pairs:
        src=cand/src_name
        if not src.exists():
            continue
        dst=assets/dst_name
        # promote if newer or larger
        if (not dst.exists()) or src.stat().st_mtime >= dst.stat().st_mtime - 1:
            with Image.open(src) as im:
                im=ImageOps.exif_transpose(im).convert('RGBA')
                out=ImageOps.fit(im,size,method=Image.Resampling.LANCZOS,centering=(0.5,0.5))
                out.save(dst,'PNG')
            L(f'promoted {src_name} -> {dst_name} ({dst.stat().st_size})')
    if not alive:
        L('gen process ended')
        break
    time.sleep(10)
else:
    L('timeout watching')
if (cand/'batch_status_r180_extra.json').exists():
    L((cand/'batch_status_r180_extra.json').read_text())
L('done')
