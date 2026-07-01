#!/usr/bin/env python3
"""Fast Chinese ink-wash illustration generator"""
import math, os, struct, zlib, time

OUT_DIR = "assets/illustrations"
os.makedirs(OUT_DIR, exist_ok=True)
t0 = time.time()

def rgba(h, a=255):
    h = h.lstrip("#")
    return (int(h[0:2],16),int(h[2:4],16),int(h[4:6],16),a)

def blend(d,s):
    sa=s[3]/255.0;da=d[3]/255.0;oa=sa+da*(1.0-sa)
    if oa<=0: return (0,0,0,0)
    return tuple(int((s[i]*sa+d[i]*da*(1.0-sa))/oa) for i in range(3))+(int(oa*255),)

def mk(w,h,c=(0,0,0,0)):
    return bytearray(w*h*4)  # RGBA flat bytearray

def _px(img,w,x,y):
    return (y*w+x)*4

def sp(img,w,x,y,r,g,b,a):
    if x<0 or y<0 or x>=w: return
    h=len(img)//(w*4)
    if y>=h: return
    i=(y*w+x)*4
    sa=a/255.0;da=img[i+3]/255.0;oa=sa+da*(1.0-sa)
    if oa<=0:
        img[i:i+4]=bytes([0,0,0,0])
        return
    for c in range(3):
        v=int((img[i+c]*da*(1.0-sa)+(r,g,b)[c]*sa)/oa)
        img[i+c]=max(0,min(255,v))
    img[i+3]=int(oa*255)

def spl(img,w,x,y,c):
    sp(img,w,x,y,c[0],c[1],c[2],c[3])

def fill(img,w,x0,y0,x1,y1,r,g,b,a):
    h=len(img)//(w*4)
    y0i=max(0,int(y0));y1i=min(h,int(y1))
    x0i=max(0,int(x0));x1i=min(w,int(x1))
    sa=a/255.0
    for y in range(y0i,y1i):
        row_start=y*w*4
        for x in range(x0i,x1i):
            i=row_start+x*4
            da=img[i+3]/255.0;oa=sa+da*(1.0-sa)
            if oa<=0:
                img[i:i+4]=bytes([0,0,0,0]); continue
            for c in range(3):
                v=int((img[i+c]*da*(1.0-sa)+(r,g,b)[c]*sa)/oa)
                img[i+c]=max(0,min(255,v))
            img[i+3]=int(oa*255)

def fillc(img,w,x0,y0,x1,y1,c):
    fill(img,w,x0,y0,x1,y1,c[0],c[1],c[2],c[3])

def grad(img,w,x0,y0,x1,y1,tr,tg,tb,ta,br,bg,bg2,ba):
    h=len(img)//(w*4);hh=max(1,int(y1-y0))
    for y in range(int(y0),int(y1)):
        t=(y-y0)/hh
        r=int(tr*(1.0-t)+br*t);g=int(tg*(1.0-t)+bg*t);b_=int(tb*(1.0-t)+bg2*t);a=int(ta*(1.0-t)+ba*t)
        fill(img,w,x0,y,x1,y+1,r,g,b_,a)

def gradcc(img,w,x0,y0,x1,y1,tc,bc):
    grad(img,w,x0,y0,x1,y1,tc[0],tc[1],tc[2],tc[3],bc[0],bc[1],bc[2],bc[3])

def ell(img,w,cx,cy,rx,ry,r,g,b,a):
    if rx<=0 or ry<=0: return
    h=len(img)//(w*4)
    y0=max(0,int(cy-ry));y1=min(h,int(cy+ry)+1)
    x0=max(0,int(cx-rx));x1=min(w,int(cx+rx)+1)
    sa=a/255.0
    for y in range(y0,y1):
        dy2=((y-cy)/ry)**2
        if dy2>1.0: continue
        hw=int(math.sqrt(1.0-dy2)*rx)
        xl=max(x0,cx-hw);xr=min(x1,cx+hw+1)
        row_start=y*w*4
        for x in range(xl,xr):
            i=row_start+x*4
            da=img[i+3]/255.0;oa=sa+da*(1.0-sa)
            if oa<=0: img[i:i+4]=bytes([0,0,0,0]); continue
            for c in range(3):
                v=int((img[i+c]*da*(1.0-sa)+(r,g,b)[c]*sa)/oa)
                img[i+c]=max(0,min(255,v))
            img[i+3]=int(oa*255)

def ellc(img,w,cx,cy,rx,ry,c):
    ell(img,w,cx,cy,rx,ry,c[0],c[1],c[2],c[3])

def ln(img,w,x0,y0,x1,y1,c,th=2):
    s=max(abs(int(x1-x0)),abs(int(y1-y0)),1)
    for i in range(s+1):
        t=i/s
        ellc(img,w,int(round(x0+(x1-x0)*t)),int(round(y0+(y1-y0)*t)),th,th,c)

def poly(img,w,pts,c):
    h=len(img)//(w*4);my0=max(0,int(min(p[1]for p in pts)));my1=min(h-1,int(max(p[1]for p in pts)))
    for y in range(my0,my1+1):
        xs=[]
        for i in range(len(pts)):
            x1,y1=pts[i];x2,y2=pts[(i+1)%len(pts)]
            if(y1<=y<y2)or(y2<=y<y1):xs.append(x1+(y-y1)*(x2-x1)/(y2-y1))
        xs.sort()
        for i in range(0,len(xs),2):
            if i+1<len(xs): fillc(img,w,int(xs[i]),y,int(xs[i+1]),y+1,c)

def cloud(img,w,cx,cy,s,c):
    for dx,dy,rx,ry in [(-58,8,56,25),(-24,-5,62,32),(24,0,58,28),(68,12,44,22),(0,18,86,18)]:
        ellc(img,w,int(cx+dx*s),int(cy+dy*s),int(rx*s),int(ry*s),c)

def mtn(img,w,by,cl,phase,hs=1.0):
    ps=[(w*(i/6.0),by-(95+52*math.sin(i*1.73+phase))*hs) for i in range(7)]
    poly(img,w,[(0,by)]+ps+[(w,by),(w,len(img)//(w*4)),(0,len(img)//(w*4))],cl)

def save(path,data,w,h):
    raw=b""
    for y in range(h):
        raw+=b"\x00"+bytes(data[y*w*4:(y+1)*w*4])
    def ck(t,d):
        c=struct.pack(">I",len(d))+t+d
        c+=struct.pack(">I",zlib.crc32(c)&0xffffffff)
        return c
    ihdr=struct.pack(">IIBBBBB",w,h,8,6,0,0,0)
    open(path,"wb").write(b"\x89PNG\r\n\x1a\n"+ck(b"IHDR",ihdr)+ck(b"IDAT",zlib.compress(raw))+ck(b"IEND",b""))

def gen(fn,w,h):
    return mk(w,h)

print("Generate illustrations...")
#!/usr/bin/env python3
"""Fast Chinese ink-wash illustration generator v2 - bytearray based"""
import math, os, struct, zlib, time

OUT_DIR = "assets/illustrations"
os.makedirs(OUT_DIR, exist_ok=True)

def rgba(h, a=255):
    h = h.lstrip("#"); return (int(h[0:2],16),int(h[2:4],16),int(h[4:6],16),a)

def _s(r,g,b,a): return (r,g,b,a)

def mk(w,h,c=(0,0,0,0)):
    return bytearray([c[0],c[1],c[2],c[3]]*w*h), w, h

def fill(data,w, x0,y0,x1,y1, r,g,b,a):
    h=len(data)//(w*4)
    y0i=max(0,int(y0));y1i=min(h,int(y1));x0i=max(0,int(x0));x1i=min(w,int(x1))
    if a==255:# opaque - fast path
        for y in range(y0i,y1i):
            rs=y*w*4
            for x in range(x0i,x1i):
                i=rs+x*4;data[i]=r;data[i+1]=g;data[i+2]=b;data[i+3]=255
    else:
        sa=a/255.0
        for y in range(y0i,y1i):
            rs=y*w*4
            for x in range(x0i,x1i):
                i=rs+x*4
                da=data[i+3]/255.0;oa=sa+da*(1.0-sa)
                if oa<=0: data[i:i+4]=bytes([0,0,0,0]); continue
                for c in range(3):
                    v=int((data[i+c]*da*(1.0-sa)+(r,g,b)[c]*sa)/oa)
                    data[i+c]=max(0,min(255,v))
                data[i+3]=int(oa*255)

def fillc(data,w,x0,y0,x1,y1,c):
    fill(data,w,x0,y0,x1,y1,c[0],c[1],c[2],c[3])

def grad(data,w,x0,y0,x1,y1,tc,bc):
    h=len(data)//(w*4);hh=max(1,int(y1-y0))
    for y in range(int(y0),int(y1)):
        t=(y-y0)/hh
        c=tuple(int(tc[i]*(1.0-t)+bc[i]*t) for i in range(4))
        fill(data,w,x0,y,x1,y+1,c[0],c[1],c[2],c[3])

def ell(data,w,cx,cy,rx,ry,r,g,b,a):
    if rx<=0 or ry<=0: return
    h=len(data)//(w*4)
    y0=max(0,int(cy-ry));y1=min(h,int(cy+ry)+1);x0=max(0,int(cx-rx));x1=min(w,int(cx+rx)+1)
    sa=a/255.0
    for y in range(y0,y1):
        dy2=((y-cy)/ry)**2
        if dy2>1.0: continue
        hw=int(math.sqrt(1.0-dy2)*rx)
        xl=max(x0,cx-hw);xr=min(x1,cx+hw+1);rs=y*w*4
        for x in range(xl,xr):
            i=rs+x*4
            da=data[i+3]/255.0;oa=sa+da*(1.0-sa)
            if oa<=0: data[i:i+4]=bytes([0,0,0,0]); continue
            for c in range(3):
                v=int((data[i+c]*da*(1.0-sa)+(r,g,b)[c]*sa)/oa)
                data[i+c]=max(0,min(255,v))
            data[i+3]=int(oa*255)

def ellc(data,w,cx,cy,rx,ry,c):
    ell(data,w,cx,cy,rx,ry,c[0],c[1],c[2],c[3])

def line(data,w,x0,y0,x1,y1,c,th=2):
    s=max(abs(int(x1-x0)),abs(int(y1-y0)),1)
    for i in range(s+1):
        t=i/s
        ellc(data,w,int(round(x0+(x1-x0)*t)),int(round(y0+(y1-y0)*t)),th,th,c)

def poly(data,w,pts,c):
    h=len(data)//(w*4)
    my0=max(0,int(min(p[1]for p in pts)));my1=min(h-1,int(max(p[1]for p in pts)))
    for y in range(my0,my1+1):
        xs=[]
        for i in range(len(pts)):
            x1,y1=pts[i];x2,y2=pts[(i+1)%len(pts)]
            if(y1<=y<y2)or(y2<=y<y1):xs.append(x1+(y-y1)*(x2-x1)/(y2-y1))
        xs.sort()
        for i in range(0,len(xs),2):
            if i+1<len(xs): fillc(data,w,int(xs[i]),y,int(xs[i+1]),y+1,c)

def cloud(data,w,cx,cy,s,c):
    for dx,dy,rx,ry in [(-58,8,56,25),(-24,-5,62,32),(24,0,58,28),(68,12,44,22),(0,18,86,18)]:
        ellc(data,w,int(cx+dx*s),int(cy+dy*s),int(rx*s),int(ry*s),c)

def mtn(data,w,by,cl,phase,hs=1.0):
    h=len(data)//(w*4)
    ps=[(w*(i/6.0),by-(95+52*math.sin(i*1.73+phase))*hs) for i in range(7)]
    poly(data,w,[(0,by)]+ps+[(w,by),(w,h),(0,h)],cl)

def brk(data,w,y,c,strength=7):
    for i in range(7):
        yy=y+math.sin(i*1.7)*strength
        line(data,w,int(w*0.08+i*w*0.13),int(yy),int(w*0.20+i*w*0.13),int(yy+math.sin(i)*5),c,4+i%3)

def border(data,w,h,m,c,th=2):
    for cx,cy in [(m,m),(w-m,m),(m,h-m),(w-m,h-m)]:
        ellc(data,w,cx,cy,10,10,c)
    fillc(data,w,m,m,w-m,m+th,c)
    fillc(data,w,m,h-m-th,w-m,h-m,c)
    fillc(data,w,m,m,m+th,h-m,c)
    fillc(data,w,w-m-th,m,w-m,h-m,c)
    im=m+10
    fillc(data,w,im,im,w-im,im+1,(c[0],c[1],c[2],c[3]//2))
    fillc(data,w,im,h-im-1,w-im,h-im,(c[0],c[1],c[2],c[3]//2))
    fillc(data,w,im,im,im+1,h-im,(c[0],c[1],c[2],c[3]//2))
    fillc(data,w,w-im-1,im,w-im,h-im,(c[0],c[1],c[2],c[3]//2))

def starburst(data,w,cx,cy,r,g,b,a,n=24,mr=300):
    for i in range(n):
        ang=i*math.tau/n
        for rd in range(20,mr,20):
            x=int(cx+math.cos(ang)*rd);y=int(cy+math.sin(ang)*rd)
            if x>=0 and x<w and y>=0 and y<len(data)//(w*4):
                al=max(5,int(a*(60-2*rd/20)/60))
                sp=data[(y*w+x)*4+3]
                sp_=sp+al if sp<255-al else 255
                data[(y*w+x)*4+3]=sp_

def save(path,data,w,h):
    raw=b""
    for y in range(h):
        raw+=b"\x00"+bytes(data[y*w*4:(y+1)*w*4])
    def ck(t,d):
        c=struct.pack(">I",len(d))+t+d
        c+=struct.pack(">I",zlib.crc32(c)&0xffffffff)
        return c
    ihdr=struct.pack(">IIBBBBB",w,h,8,6,0,0,0)
    open(path,"wb").write(b"\x89PNG\r\n\x1a\n"+ck(b"IHDR",ihdr)+ck(b"IDAT",zlib.compress(raw))+ck(b"IEND",b""))

t0=time.time()
print("Generating illustrations...")

# ── menu_hero (960x540) ──
data,w,h = mk(960,540)
grad(data,w,0,0,w,h,rgba("#0a1a1e"),rgba("#15282e"))
mtn(data,w,320,rgba("#1a3a3c",120),0,0.7)
mtn(data,w,370,rgba("#1e4246",140),2.3,0.85)
mtn(data,w,420,rgba("#214a4e",100),4.1,1.0)
for i in range(3): cloud(data,w,120+i*340,280+math.sin(i)*20,0.35+math.sin(i*0.7)*0.1,rgba("#d4e0cc",16+5*i))
for r,a in [(80,12),(50,18),(30,26)]: ell(data,w,760,72,r,r,rgba("#e8c84a",a)[0],rgba("#e8c84a",a)[1],rgba("#e8c84a",a)[2],rgba("#e8c84a",a)[3])
for i in range(5):
    bx,by=100+i*170,140+math.sin(i*2.3)*30
    line(data,w,bx-10,by,bx,by-6,rgba("#3a5a5a",180),2)
    line(data,w,bx,by-6,bx+10,by,rgba("#3a5a5a",180),2)
border(data,w,h,8,rgba("#c8b050",60),1)
save(os.path.join(OUT_DIR,"menu_hero_painting.png"),data,w,h)
print(f"  ✓ menu_hero ({time.time()-t0:.1f}s)")

# ── table_wash (1024x1024) ──
t1=time.time()
data,w,h = mk(1024,1024,rgba("#1a2e2c",200))
grad(data,w,0,0,w,h,rgba("#1a2e2c",200),rgba("#0e1e1c",220))
for i in range(6):
    r=80+math.sin(i)*30
    ellc(data,w,512+int(math.sin(i)*200),512+int(math.cos(i*0.7)*150),int(r),int(r),rgba("#2a5a4e",6+2*i))
for i in range(4): brk(data,w,120+i*220,rgba("#8a7a4a",12+i*3),5)
border(data,w,h,16,rgba("#5a7a6a",30),2)
save(os.path.join(OUT_DIR,"table_ink_wash.png"),data,w,h)
print(f"  ✓ table_wash ({time.time()-t1:.1f}s)")

# ── victory_badge (512x512) ──
t1=time.time()
data,w,h = mk(512,512)
grad(data,w,0,0,w,h,rgba("#1a0e08",200),rgba("#2a1e18",180))
for r,a in [(180,10),(120,16),(80,24)]: ellc(data,w,256,256,r,r,rgba("#d8a838",a))
for r,a in [(112,180),(100,220),(88,120)]: ellc(data,w,256,256,r,r,rgba("#e8c050",a))
line(data,w,232,220,232,260,rgba("#5a3010",200),4)
line(data,w,232,260,248,280,rgba("#5a3010",200),4)
line(data,w,216,240,264,240,rgba("#5a3010",200),4)
for s in[-1,1]:
    for i in range(3):
        poly(data,w,[(246-10*s,105),(256+s*80+i*10-15,256+60+i*30-10),(256+s*80+i*10+15,256+60+i*30+10),(246+10*s,105)],rgba("#c84030",140-i*20))
starburst(data,w,256,256,248,232,160,8,180)
save(os.path.join(OUT_DIR,"victory_badge.png"),data,w,h)
print(f"  ✓ victory_badge ({time.time()-t1:.1f}s)")

# ── loading_gate (960x540) ──
t1=time.time()
data,w,h = mk(960,540)
grad(data,w,0,0,w,h,rgba("#060e12"),rgba("#0e1a20"))
for r,a in [(50,16),(36,22),(22,32)]: ellc(data,w,760,90,r,r,rgba("#d8d0b0",a))
for i in range(3): mtn(data,w,350+i*50,rgba("#1a3a3c",60+20*i),i*2.0,0.8-i*0.2)
save(os.path.join(OUT_DIR,"loading_gate.png"),data,w,h)
print(f"  ✓ loading_gate ({time.time()-t1:.1f}s)")

# ── daily_calendar (960x300) ──
t1=time.time()
data,w,h = mk(960,300)
grad(data,w,0,0,w,h,rgba("#0e1618"),rgba("#1a2428"))
fillc(data,w,30,40,930,260,rgba("#1c2828",220))
for i in range(7):
    x=60+i*120;c=rgba("#58a07a",80) if i!=6 else rgba("#e8c850",80)
    ellc(data,w,x,150,22,22,rgba("#488a6a",60) if i!=6 else rgba("#c8b048",60))
    ellc(data,w,x,150,16,16,c)
fillc(data,w,40,50,920,54,rgba("#c8b050",20))
fillc(data,w,40,246,920,250,rgba("#c8b050",20))
save(os.path.join(OUT_DIR,"daily_calendar.png"),data,w,h)
print(f"  ✓ daily_calendar ({time.time()-t1:.1f}s)")

# ── win_fanfare (960x540) ──
t1=time.time()
data,w,h = mk(960,540)
grad(data,w,0,0,w,h,rgba("#1a1208"),rgba("#2a1e0e"))
starburst(data,w,480,270,248,224,96,24,300)
for i in range(15):
    x=int(100+math.sin(i*1.3)*480*0.4);y=int(100+i*25+math.sin(i*0.7)*20)
    ellc(data,w,x,y,6,12,[rgba("#d84030",180),rgba("#e8c040",180),rgba("#48a060",180),rgba("#4070c0",180)][i%4])
save(os.path.join(OUT_DIR,"win_fanfare.png"),data,w,h)
print(f"  ✓ win_fanfare ({time.time()-t1:.1f}s)")

# ── toast_ribbon (768x128) ──
t1=time.time()
data,w,h = mk(768,128)
grad(data,w,0,0,w,h,rgba("#1a0e08"),rgba("#2a1a12"))
for i in range(5):
    x=80+i*140;a=60-8*i
    line(data,w,x,20,x+40,108,rgba("#c8a848",a),3)
    line(data,w,x-20,20,x-40,108,rgba("#c8a848",a-10),2)
border(data,w,h,8,rgba("#c8a848",40),1)
save(os.path.join(OUT_DIR,"toast_ribbon.png"),data,w,h)
print(f"  ✓ toast_ribbon ({time.time()-t1:.1f}s)")

# ── rules_scroll (960x300) ──
t1=time.time()
data,w,h = mk(960,300)
grad(data,w,0,0,w,h,rgba("#1a1a12"),rgba("#2a2a1e"))
for i in range(8):
    y=20+i*34
    fillc(data,w,40,y,920,y+2,rgba("#a09060",18-i))
for side in[0,944]: fillc(data,w,side,0,side+16,300,rgba("#6a5a3a",200))
save(os.path.join(OUT_DIR,"rules_scroll.png"),data,w,h)
print(f"  ✓ rules_scroll ({time.time()-t1:.1f}s)")

# ── stats_chart (960x300) ──
t1=time.time()
data,w,h = mk(960,300)
grad(data,w,0,0,w,h,rgba("#0e1618"),rgba("#182228"))
for i in range(10): fillc(data,w,0,i*30,960,i*30+1,rgba("#3a6a6a",16))
vals=[30,65,42,78,54,88,62,95]
bw=(960-80)//len(vals)
for i,v in enumerate(vals):
    bh=int(v*2.2)
    for j in range(bh):
        t=j/bh
        cl=rgba("#488a6a",int(40+80*t)) if t<0.5 else rgba("#c8a838",int(60+60*(t-0.5)))
        fillc(data,w,40+i*bw,270-bh+j,40+i*bw+bw-4,270-bh+j+1,cl)
save(os.path.join(OUT_DIR,"stats_chart.png"),data,w,h)
print(f"  ✓ stats_chart ({time.time()-t1:.1f}s)")

# ── shop_vault (960x300) ──
t1=time.time()
data,w,h = mk(960,300)
grad(data,w,0,0,w,h,rgba("#1a1208"),rgba("#2a1e10"))
for i in range(3):
    x,p=120+i*320,180+int(math.sin(i*0.5)*40)
    fillc(data,w,x-60,40,x+60,p,rgba("#6a4a2a",120))
    fillc(data,w,x-50,50,x+50,p-10,rgba("#8a6a3a",100))
    ellc(data,w,x,25,40,12,rgba("#c8a848",80))
save(os.path.join(OUT_DIR,"shop_vault.png"),data,w,h)
print(f"  ✓ shop_vault ({time.time()-t1:.1f}s)")

# ── online_network (960x300) ──
t1=time.time()
data,w,h = mk(960,300)
grad(data,w,0,0,w,h,rgba("#0a1620"),rgba("#162a38"))
nodes=[(100,120),(320,60),(540,150),(760,80),(480,220),(200,200),(680,180)]
for i,(x,y) in enumerate(nodes):
    for j in range(i+1,len(nodes)):
        x2,y2=nodes[j];d=math.hypot(x2-x,y2-y)
        if d<350: line(data,w,x,y,x2,y2,rgba("#4a7a9a",int(40*(1-d/350))),1)
for x,y in nodes:
    ellc(data,w,x,y,12,12,rgba("#6aaaca",120))
    ellc(data,w,x,y,5,5,rgba("#aad8f0",200))
save(os.path.join(OUT_DIR,"online_network.png"),data,w,h)
print(f"  ✓ online_network ({time.time()-t1:.1f}s)")

# ── update_package (768x256) ──
t1=time.time()
data,w,h = mk(768,256)
grad(data,w,0,0,w,h,rgba("#0e1618"),rgba("#1a2428"))
cx,cy=120,128
fillc(data,w,65,63,175,193,rgba("#3a5a6a",120))
fillc(data,w,75,73,165,183,rgba("#4a6a7a",100))
fillc(data,w,68,53,180,73,rgba("#6a8a9a",140))
line(data,w,100,98,120,118,rgba("#8abaea",160),3)
line(data,w,120,118,140,98,rgba("#8abaea",160),3)
line(data,w,120,118,120,158,rgba("#8abaea",160),3)
for i in range(4):
    x,y=220+i*130,40+math.sin(i)*25
    fillc(data,w,x,y,x+100,y+60,rgba("#3a5a6a",50))
save(os.path.join(OUT_DIR,"update_package.png"),data,w,h)
print(f"  ✓ update_package ({time.time()-t1:.1f}s)")

print(f"Done in {time.time()-t0:.1f}s")
"""Remaining illustrations"""
import math,os,struct,zlib,time
OUT_DIR="assets/illustrations"
os.makedirs(OUT_DIR,exist_ok=True)

def rgba(h,a=255):
    h=h.lstrip("#");return(int(h[0:2],16),int(h[2:4],16),int(h[4:6],16),a)

def mk(w,h,c=(0,0,0,0)):
    return bytearray([c[0],c[1],c[2],c[3]]*w*h),w,h

def fill(data,w,x0,y0,x1,y1,r,g,b,a):
    h=len(data)//(w*4)
    y0i=max(0,int(y0));y1i=min(h,int(y1));x0i=max(0,int(x0));x1i=min(w,int(x1))
    if a==255:
        for y in range(y0i,y1i):
            rs=y*w*4
            for x in range(x0i,x1i):
                i=rs+x*4;data[i]=r;data[i+1]=g;data[i+2]=b;data[i+3]=255
    else:
        sa=a/255.0
        for y in range(y0i,y1i):
            rs=y*w*4
            for x in range(x0i,x1i):
                i=rs+x*4
                da=data[i+3]/255.0;oa=sa+da*(1.0-sa)
                if oa<=0:data[i:i+4]=bytes([0,0,0,0]);continue
                for c in range(3):
                    v=int((data[i+c]*da*(1.0-sa)+(r,g,b)[c]*sa)/oa)
                    data[i+c]=max(0,min(255,v))
                data[i+3]=int(oa*255)

def fillc(data,w,x0,y0,x1,y1,c):
    fill(data,w,x0,y0,x1,y1,c[0],c[1],c[2],c[3])

def grad(data,w,x0,y0,x1,y1,tc,bc):
    h=len(data)//(w*4);hh=max(1,int(y1-y0))
    for y in range(int(y0),int(y1)):
        t=(y-y0)/hh;c=tuple(int(tc[i]*(1.0-t)+bc[i]*t) for i in range(4))
        fill(data,w,x0,y,x1,y+1,c[0],c[1],c[2],c[3])

def ell(data,w,cx,cy,rx,ry,r,g,b,a):
    if rx<=0 or ry<=0:return
    h=len(data)//(w*4);y0=max(0,int(cy-ry));y1=min(h,int(cy+ry)+1);x0=max(0,int(cx-rx));x1=min(w,int(cx+rx)+1)
    sa=a/255.0
    for y in range(y0,y1):
        dy2=((y-cy)/ry)**2
        if dy2>1.0:continue
        hw=int(math.sqrt(1.0-dy2)*rx);xl=max(x0,cx-hw);xr=min(x1,cx+hw+1);rs=y*w*4
        for x in range(xl,xr):
            i=rs+x*4;da=data[i+3]/255.0;oa=sa+da*(1.0-sa)
            if oa<=0:data[i:i+4]=bytes([0,0,0,0]);continue
            for c_ in range(3):
                v=int((data[i+c_]*da*(1.0-sa)+(r,g,b)[c_]*sa)/oa)
                data[i+c_]=max(0,min(255,v))
            data[i+3]=int(oa*255)

def ellc(data,w,cx,cy,rx,ry,c):
    ell(data,w,cx,cy,rx,ry,c[0],c[1],c[2],c[3])

def line(data,w,x0,y0,x1,y1,c,th=2):
    s=max(abs(int(x1-x0)),abs(int(y1-y0)),1)
    for i in range(s+1):
        t=i/s;ellc(data,w,int(round(x0+(x1-x0)*t)),int(round(y0+(y1-y0)*t)),th,th,c)

def poly(data,w,pts,c):
    h=len(data)//(w*4);my0=max(0,int(min(p[1]for p in pts)));my1=min(h-1,int(max(p[1]for p in pts)))
    for y in range(my0,my1+1):
        xs=[]
        for i in range(len(pts)):
            x1,y1=pts[i];x2,y2=pts[(i+1)%len(pts)]
            if(y1<=y<y2)or(y2<=y<y1):xs.append(x1+(y-y1)*(x2-x1)/(y2-y1))
        xs.sort()
        for i_ in range(0,len(xs),2):
            if i_+1<len(xs): fillc(data,w,int(xs[i_]),y,int(xs[i_+1]),y+1,c)

def cloud(data,w,cx,cy,s,c):
    for dx,dy,rx,ry in [(-58,8,56,25),(-24,-5,62,32),(24,0,58,28),(68,12,44,22),(0,18,86,18)]:
        ellc(data,w,int(cx+dx*s),int(cy+dy*s),int(rx*s),int(ry*s),c)

def save(path,data,w,h):
    raw=b""
    for y in range(h):raw+=b"\x00"+bytes(data[y*w*4:(y+1)*w*4])
    def ck(t,d):
        c=struct.pack(">I",len(d))+t+d;c+=struct.pack(">I",zlib.crc32(c)&0xffffffff);return c
    ihdr=struct.pack(">IIBBBBB",w,h,8,6,0,0,0)
    open(path,"wb").write(b"\x89PNG\r\n\x1a\n"+ck(b"IHDR",ihdr)+ck(b"IDAT",zlib.compress(raw))+ck(b"IEND",b""))

t0=time.time()

# ── settings_compass (960x300) ──
data,w,h=mk(960,300);grad(data,w,0,0,w,h,rgba("#0e1a1e"),rgba("#1a2a30"))
cx,cy=140,140
for i in range(4):
    a=i*math.tau/4;line(data,w,cx,cy,int(cx+90*math.cos(a)),int(cy+90*math.sin(a)),rgba("#5a8a9a",50),2)
for r in[30,60,90]:ellc(data,w,cx,cy,r,r,rgba("#5a8a9a",30))
for cl in[rgba("#c8b048",200),rgba("#d8c060",160),rgba("#e8d070",120)]:
    for r,rr in[(25,0),(19,6),(13,12)]:
        if cl==rgba("#c8b048",200):ellc(data,w,cx,cy,25-rr,25-rr,cl);break
ellc(data,w,cx,cy,25,25,rgba("#c8b048",200))
ellc(data,w,cx,cy,19,19,rgba("#d8c060",160))
ellc(data,w,cx,cy,13,13,rgba("#e8d070",120))
save(os.path.join(OUT_DIR,"settings_compass.png"),data,w,h)
print(f"  ✓ settings_compass")

# ── diagnostic_wave (960x300) ──
data,w,h=mk(960,300);grad(data,w,0,0,w,h,rgba("#0e1218"),rgba("#1a222a"))
for i in range(3):
    by=120+math.sin(i)*30;c=rgba("#4a8a6a",60-10*i)
    for x in range(20,w-20,2):ellc(data,w,x,int(by+math.sin(x*0.02+i*2.3)*30),2,2,c)
save(os.path.join(OUT_DIR,"diagnostic_wave.png"),data,w,h)
print(f"  ✓ diagnostic_wave")

# ── exit_gate (768x256) ──
data,w,h=mk(768,256);grad(data,w,0,0,w,h,rgba("#1a0e0a"),rgba("#2a1a12"))
cx,cy=384,140
for r in[60,50,40]:ellc(data,w,cx,cy,r,r,rgba("#8a3a2a",60-10*(60-r)))
ellc(data,w,cx,cy,30,30,rgba("#d85f4a",100))
ellc(data,w,cx,cy,18,18,rgba("#f0705a",140))
for i in range(3):fillc(data,w,cx-40+i*40,cy+60,cx-40+i*40+10,cy+100,rgba("#6a4a3a",80-i*15))
save(os.path.join(OUT_DIR,"exit_gate.png"),data,w,h)
print(f"  ✓ exit_gate")

# ── chat_stream (768x512) ──
data,w,h=mk(768,512);grad(data,w,0,0,w,h,rgba("#0a1418"),rgba("#16222a"))
for i in range(6):
    x,y=40,30+i*80
    fillc(data,w,x,y,x+300,y+55,rgba("#1a2e38",140))
    fillc(data,w,x+10,y+8,x+280,y+48,rgba("#2a424e",120))
    ellc(data,w,x+28,y+28,16,16,rgba("#5a8aaa",100))
    fillc(data,w,x+55,y+16,x+240,y+26,rgba("#4a7a9a",60))
    fillc(data,w,x+55,y+32,x+170,y+40,rgba("#4a7a9a",40))
save(os.path.join(OUT_DIR,"chat_stream.png"),data,w,h)
print(f"  ✓ chat_stream")

# ── danger_warning (960x180) ──
data,w,h=mk(960,180);grad(data,w,0,0,w,h,rgba("#1a0a08"),rgba("#2e1410"))
cx,cy=70,90
for r,a in[(52,60),(42,60),(30,80),(18,110)]:ellc(data,w,cx,cy,r,r,rgba("#d84a3a",a))
for i in range(3):
    x=26+i*12
    line(data,w,x+2,cy-18,x+2,cy-10,rgba("#f8e8a0",200),3)
    line(data,w,x-4,cy-6,x+8,cy-6,rgba("#f8e8a0",200),3)
fillc(data,w,130,80,920,84,rgba("#d84a3a",40))
for i in range(4):
    bx=150+i*180;fillc(data,w,bx,70,bx+80,78,rgba("#a04030",60))
    fillc(data,w,bx,94,bx+100,102,rgba("#a04030",50))
save(os.path.join(OUT_DIR,"danger_warning.png"),data,w,h)
print(f"  ✓ danger_warning")

# ── pending_claim_banner (960x220) ──
data,w,h=mk(960,220);grad(data,w,0,0,w,h,rgba("#0e1a18"),rgba("#1a2824"))
cx,cy=70,110
for r in[45,35,25]:ellc(data,w,cx,cy,r,r,rgba("#58a07a",60-10*(45-r)))
ellc(data,w,cx,cy,15,15,rgba("#78c09a",120))
for i in range(5):
    x,y=120+i*80,40+math.sin(i)*20
    fillc(data,w,x,y,x+50,y+50,rgba("#2a4a42",80))
    fillc(data,w,x+5,y+5,x+45,y+45,rgba("#3a6a5a",60))
save(os.path.join(OUT_DIR,"pending_claim_banner.png"),data,w,h)
print(f"  ✓ pending_claim_banner")

# ── voice_wave (512x256) ──
data,w,h=mk(512,256);grad(data,w,0,0,w,h,rgba("#0e1620"),rgba("#1a2a38"))
cx,cy=120,128
for r in[70,56,42,28,14]:ellc(data,w,cx,cy,r,r,rgba("#5a9aba",40-5*(70-r)))
for i in range(7):
    x=210+i*36;h_=int(40+30*math.sin(i*1.1))
    fillc(data,w,x,cy-h_,x+20,cy+h_,rgba("#6aaaca",100-10*i))
save(os.path.join(OUT_DIR,"voice_wave.png"),data,w,h)
print(f"  ✓ voice_wave")

# ── hand_tray_flow (960x180) ──
data,w,h=mk(960,180);grad(data,w,0,0,w,h,rgba("#0e1412"),rgba("#1a2420"))
for i in range(8):
    x,y=20+i*115,20+math.sin(i*0.8)*15
    fillc(data,w,x,y,x+90,y+140,rgba("#3a5a4a",60+5*i))
    fillc(data,w,x+8,y+10,x+82,y+130,rgba("#4a7a5a",40+3*i))
fillc(data,w,0,174,960,180,rgba("#c8a848",30))
save(os.path.join(OUT_DIR,"hand_tray_flow.png"),data,w,h)
print(f"  ✓ hand_tray_flow")

# ── hud_status_banner (960x128) ──
data,w,h=mk(960,128);grad(data,w,0,0,w,h,rgba("#0e1618"),rgba("#1a2428"))
fillc(data,w,0,0,960,4,rgba("#c8a848",60))
fillc(data,w,0,124,960,128,rgba("#c8a848",30))
for i in range(4):
    x=40+i*240;y=30+math.sin(i)*10
    ellc(data,w,x+20,y,16,16,rgba("#488a6a",80))
    fillc(data,w,x+40,y-8,x+180,y+8,rgba("#3a6a5a",50))
save(os.path.join(OUT_DIR,"hud_status_banner.png"),data,w,h)
print(f"  ✓ hud_status_banner")

# ── action_dock_ribbon (768x180) ──
data,w,h=mk(768,180);grad(data,w,0,0,w,h,rgba("#0e1a1c"),rgba("#1a2a2e"))
for i in range(5):
    x=40+i*150
    for r in[30,20,10]:ellc(data,w,x+15,90,int(r+5-r*0.3),r,rgba("#488a7a",60-10*(30-r)))
    ellc(data,w,x+15,90,8,8,rgba("#68aa9a",120))
line(data,w,180,40,w-40,40,rgba("#c8a848",24),1)
line(data,w,180,140,w-40,140,rgba("#c8a848",24),1)
save(os.path.join(OUT_DIR,"action_dock_ribbon.png"),data,w,h)
print(f"  ✓ action_dock_ribbon")

# ── table_log_scroll (512x512) ──
data,w,h=mk(512,512);grad(data,w,0,0,w,h,rgba("#0e1412"),rgba("#1a2220"))
for i in range(6):
    y=30+i*75
    fillc(data,w,30,y,482,y+55,rgba("#1a2e2a",100))
    fillc(data,w,35,y+6,477,y+48,rgba("#2a423e",80))
    fillc(data,w,45,y+14,452,y+24,rgba("#4a7a6a",50))
    fillc(data,w,45,y+30,432,y+38,rgba("#4a7a6a",35))
save(os.path.join(OUT_DIR,"table_log_scroll.png"),data,w,h)
print(f"  ✓ table_log_scroll")

# ── advisor_map (960x260) ──
data,w,h=mk(960,260);grad(data,w,0,0,w,h,rgba("#0e1418"),rgba("#1a222a"))
cx,cy=80,130
for r in[55,45,35,25,15]:ellc(data,w,cx,cy,r,r,rgba("#488a7a",55-6*(55-r)))
for i in range(4):
    x=160+i*200
    poly(data,w,[(x,60),(x+80,90),(x+60,160),(x-20,130)],rgba("#2a5a4e",70))
    poly(data,w,[(x+5,65),(x+70,92),(x+55,152),(x-12,128)],rgba("#3a6a5e",50))
save(os.path.join(OUT_DIR,"advisor_map.png"),data,w,h)
print(f"  ✓ advisor_map")

# ── flower_bloom_shadow (512x384) ──
data,w,h=mk(512,384);grad(data,w,0,0,w,h,rgba("#120e0a"),rgba("#1e1a12"))
cx,cy=236,160
for r,a in[(120,12),(90,18),(65,26),(45,36)]:ellc(data,w,cx,cy,r,r,rgba("#c06050",a))
for i in range(5):
    a=i*math.tau/5-0.3
    ellc(data,w,int(cx+math.cos(a)*50),int(cy+math.sin(a)*50),16,26,rgba("#d07060",80+i*8))
ellc(data,w,cx,cy,12,12,rgba("#e8c050",120))
line(data,w,cx,cy+30,cx,cy+120,rgba("#3a6a3a",100),4)
save(os.path.join(OUT_DIR,"flower_bloom_shadow.png"),data,w,h)
print(f"  ✓ flower_bloom_shadow")

# ── win_detail_scroll (960x320) ──
data,w,h=mk(960,320);grad(data,w,0,0,w,h,rgba("#1a1410"),rgba("#2a221e"))
for i in range(5):
    y=25+i*58
    fillc(data,w,50,y,910,y+44,rgba("#2a1e18",120))
    fillc(data,w,55,y+6,905,y+38,rgba("#3a2e28",100))
    fillc(data,w,60,y+12,880,y+22,rgba("#6a5a3a",50))
border(data,w,h,12,rgba("#c8a848",30),1)
save(os.path.join(OUT_DIR,"win_detail_scroll.png"),data,w,h)
print(f"  ✓ win_detail_scroll")

# ── seat_brocade (512x512) ──
data,w,h=mk(512,512);grad(data,w,0,0,w,h,rgba("#1a1e20"),rgba("#2a2e30"))
for i in range(8):
    for j in range(8):
        x=10+i*64;y=10+j*64
        for r in[12,8,4]:ellc(data,w,x+28,y+28,r,r,rgba("#c8a848",16+8*(12-r)))
for i in range(9):
    line(data,w,0,i*64,512,i*64,rgba("#c8a848",8),1)
    line(data,w,i*64,0,i*64,512,rgba("#c8a848",8),1)
border(data,w,h,8,rgba("#c8a848",40),2)
save(os.path.join(OUT_DIR,"seat_brocade.png"),data,w,h)
print(f"  ✓ seat_brocade")

# ── discard_river_wash (960x260) ──
data,w,h=mk(960,260);grad(data,w,0,0,w,h,rgba("#0e1412"),rgba("#1a221e"))
for i in range(5):
    by=50+i*40;c=rgba("#4a7a6a",14+3*i)
    for x in range(0,w,3):ellc(data,w,x,int(by+math.sin(x*0.03+i*1.3)*8),1,1,c)
for i in range(10):
    x,y=20+i*95,30+math.sin(i*0.7)*20
    fillc(data,w,x,y,x+50,y+50,rgba("#2a4a42",60))
    fillc(data,w,x+5,y+5,x+45,y+45,rgba("#3a5a52",40))
save(os.path.join(OUT_DIR,"discard_river_wash.png"),data,w,h)
print(f"  ✓ discard_river_wash")
"""Remaining illustrations part 2"""
import math,os,struct,zlib,time
OUT_DIR="assets/illustrations"
os.makedirs(OUT_DIR,exist_ok=True)

def rgba(h,a=255):
    h=h.lstrip("#");return(int(h[0:2],16),int(h[2:4],16),int(h[4:6],16),a)

def mk(w,h,c=(0,0,0,0)):
    return bytearray([c[0],c[1],c[2],c[3]]*w*h),w,h

def fill(data,w,x0,y0,x1,y1,r,g,b,a):
    h=len(data)//(w*4)
    y0i=max(0,int(y0));y1i=min(h,int(y1));x0i=max(0,int(x0));x1i=min(w,int(x1))
    if a==255:
        for y in range(y0i,y1i):
            rs=y*w*4
            for x in range(x0i,x1i):
                i=rs+x*4;data[i]=r;data[i+1]=g;data[i+2]=b;data[i+3]=255
    else:
        sa=a/255.0
        for y in range(y0i,y1i):
            rs=y*w*4
            for x in range(x0i,x1i):
                i=rs+x*4
                da=data[i+3]/255.0;oa=sa+da*(1.0-sa)
                if oa<=0:data[i:i+4]=bytes([0,0,0,0]);continue
                for c_ in range(3):
                    v=int((data[i+c_]*da*(1.0-sa)+(r,g,b)[c_]*sa)/oa)
                    data[i+c_]=max(0,min(255,v))
                data[i+3]=int(oa*255)

def fillc(data,w,x0,y0,x1,y1,c):
    fill(data,w,x0,y0,x1,y1,c[0],c[1],c[2],c[3])

def grad(data,w,x0,y0,x1,y1,tc,bc):
    h=len(data)//(w*4);hh=max(1,int(y1-y0))
    for y in range(int(y0),int(y1)):
        t=(y-y0)/hh;c=tuple(int(tc[i]*(1.0-t)+bc[i]*t) for i in range(4))
        fill(data,w,x0,y,x1,y+1,c[0],c[1],c[2],c[3])

def ell(data,w,cx,cy,rx,ry,r,g,b,a):
    if rx<=0 or ry<=0:return
    h=len(data)//(w*4);y0=max(0,int(cy-ry));y1=min(h,int(cy+ry)+1);x0=max(0,int(cx-rx));x1=min(w,int(cx+rx)+1)
    sa=a/255.0
    for y in range(y0,y1):
        dy2=((y-cy)/ry)**2
        if dy2>1.0:continue
        hw=int(math.sqrt(1.0-dy2)*rx);xl=max(x0,cx-hw);xr=min(x1,cx+hw+1);rs=y*w*4
        for x in range(xl,xr):
            i=rs+x*4;da=data[i+3]/255.0;oa=sa+da*(1.0-sa)
            if oa<=0:data[i:i+4]=bytes([0,0,0,0]);continue
            for c_ in range(3):
                v=int((data[i+c_]*da*(1.0-sa)+(r,g,b)[c_]*sa)/oa)
                data[i+c_]=max(0,min(255,v))
            data[i+3]=int(oa*255)

def ellc(data,w,cx,cy,rx,ry,c):
    ell(data,w,cx,cy,rx,ry,c[0],c[1],c[2],c[3])

def line(data,w,x0,y0,x1,y1,c,th=2):
    s=max(abs(int(x1-x0)),abs(int(y1-y0)),1)
    for i in range(s+1):
        t=i/s;ellc(data,w,int(round(x0+(x1-x0)*t)),int(round(y0+(y1-y0)*t)),th,th,c)

def poly(data,w,pts,c):
    h=len(data)//(w*4);my0=max(0,int(min(p[1]for p in pts)));my1=min(h-1,int(max(p[1]for p in pts)))
    for y in range(my0,my1+1):
        xs=[]
        for i in range(len(pts)):
            x1,y1=pts[i];x2,y2=pts[(i+1)%len(pts)]
            if(y1<=y<y2)or(y2<=y<y1):xs.append(x1+(y-y1)*(x2-x1)/(y2-y1))
        xs.sort()
        for i_ in range(0,len(xs),2):
            if i_+1<len(xs): fillc(data,w,int(xs[i_]),y,int(xs[i_+1]),y+1,c)

def border(data,w,h,m,c,th=2):
    for cx,cy in [(m,m),(w-m,m),(m,h-m),(w-m,h-m)]:
        ellc(data,w,cx,cy,10,10,c)
    fillc(data,w,m,m,w-m,m+th,c)
    fillc(data,w,m,h-m-th,w-m,h-m,c)
    fillc(data,w,m,m,m+th,h-m,c)
    fillc(data,w,w-m-th,m,w-m,h-m,c)
    im=m+10
    fillc(data,w,im,im,w-im,im+1,(c[0],c[1],c[2],c[3]//2))
    fillc(data,w,im,h-im-1,w-im,h-im,(c[0],c[1],c[2],c[3]//2))
    fillc(data,w,im,im,im+1,h-im,(c[0],c[1],c[2],c[3]//2))
    fillc(data,w,w-im-1,im,w-im,h-im,(c[0],c[1],c[2],c[3]//2))

def cloud(data,w,cx,cy,s,c):
    for dx,dy,rx,ry in [(-58,8,56,25),(-24,-5,62,32),(24,0,58,28),(68,12,44,22),(0,18,86,18)]:
        ellc(data,w,int(cx+dx*s),int(cy+dy*s),int(rx*s),int(ry*s),c)

def save(path,data,w,h):
    raw=b""
    for y in range(h):raw+=b"\x00"+bytes(data[y*w*4:(y+1)*w*4])
    def ck(t,d):
        c=struct.pack(">I",len(d))+t+d;c+=struct.pack(">I",zlib.crc32(c)&0xffffffff);return c
    ihdr=struct.pack(">IIBBBBB",w,h,8,6,0,0,0)
    open(path,"wb").write(b"\x89PNG\r\n\x1a\n"+ck(b"IHDR",ihdr)+ck(b"IDAT",zlib.compress(raw))+ck(b"IEND",b""))

t0=time.time()

# ── last_discard_aura (512x512) ──
data,w,h=mk(512,512);grad(data,w,0,0,w,h,rgba("#0e1412"),rgba("#1a221e"))
for r in range(200,0,-10):
    a=int(40*(1-r/200))
    ellc(data,w,256,256,r,r,rgba("#e8c848",a))
for i in range(8):
    a=i*math.tau/8;d=140
    line(data,w,256,256,int(256+math.cos(a)*d),int(256+math.sin(a)*d),rgba("#f0d060",20),2)
save(os.path.join(OUT_DIR,"last_discard_aura.png"),data,w,h)
print(f"  ✓ last_discard_aura")

# ── rank_row_ribbon (960x160) ──
data,w,h=mk(960,160);grad(data,w,0,0,w,h,rgba("#1a1008"),rgba("#2a1e12"))
for i in range(4):
    x=20+i*240;colors=[rgba("#f0d060",160),rgba("#98a8b0",140),rgba("#c08050",120),rgba("#6890a0",100)]
    fillc(data,w,x,20,x+120,140,colors[i])
    ellc(data,w,x+60,20,60,20,rgba("#181008",60))
    ellc(data,w,x+60,140,60,20,rgba("#181008",60))
save(os.path.join(OUT_DIR,"rank_row_ribbon.png"),data,w,h)
print(f"  ✓ rank_row_ribbon")

# ── menu_season_scroll (512x320) ──
data,w,h=mk(512,320);grad(data,w,0,0,w,h,rgba("#0e1412"),rgba("#1a2420"))
fillc(data,w,30,20,482,300,rgba("#1c2828",220))
for x,y in[(30,107),(482,107),(30,214),(482,214)]:ellc(data,w,x,y,8,8,rgba("#c8a848",120))
for i in range(4):
    x=80+i*110;colors=[rgba("#88b848",100),rgba("#d88838",100),rgba("#d84838",100),rgba("#4888b8",100)]
    ellc(data,w,x,180,16,16,colors[i])
save(os.path.join(OUT_DIR,"menu_season_scroll.png"),data,w,h)
print(f"  ✓ menu_season_scroll")

# ── menu_daily_ledger (768x220) ──
data,w,h=mk(768,220);grad(data,w,0,0,w,h,rgba("#0e1614"),rgba("#1a2422"))
for i in range(7):
    x=40+i*100
    fillc(data,w,x,30,x+70,190,rgba("#2a4a3e",80))
    fillc(data,w,x+8,40,x+62,180,rgba("#3a5a4e",60))
    h_=int(60+40*math.sin(i*1.1))
    fillc(data,w,x+15,180-h_,x+55,178,rgba("#c8a848",int(40+20*(h_/100))))
save(os.path.join(OUT_DIR,"menu_daily_ledger.png"),data,w,h)
print(f"  ✓ menu_daily_ledger")

# ── stats_dashboard_grid (960x260) ──
data,w,h=mk(960,260);grad(data,w,0,0,w,h,rgba("#0e1418"),rgba("#1a222a"))
for i in range(8):
    for j in range(2):
        x=30+i*120;y=20+j*120
        fillc(data,w,x,y,x+100,100+j*120,rgba("#2a424a",60))
        fillc(data,w,x+5,y+5,x+95,y+45,rgba("#3a5a62",40))
        fillc(data,w,x+5,y+50,x+95,y+90,rgba("#4a7a6a",30))
save(os.path.join(OUT_DIR,"stats_dashboard_grid.png"),data,w,h)
print(f"  ✓ stats_dashboard_grid")

# ── shop_item_shelf (768x180) ──
data,w,h=mk(768,180);grad(data,w,0,0,w,h,rgba("#1a1208"),rgba("#2a1e14"))
fillc(data,w,0,170,768,180,rgba("#6a4a32",180))
fillc(data,w,0,160,768,168,rgba("#8a5a42",140))
for i in range(4):
    x=40+i*190
    ellc(data,w,x+30,90,24,30,rgba("#6a4a3a",120))
    ellc(data,w,x+30,90,16,22,rgba("#8a6a4a",100))
    for j in range(3):ellc(data,w,x+10+j*12,130,4,4,rgba("#f0d060",100))
save(os.path.join(OUT_DIR,"shop_item_shelf.png"),data,w,h)
print(f"  ✓ shop_item_shelf")

# ── rules_example_table (768x220) ──
data,w,h=mk(768,220);grad(data,w,0,0,w,h,rgba("#0e1412"),rgba("#1a2220"))
for i in range(6):
    x=20+i*125
    fillc(data,w,x,30,x+100,190,rgba("#1a2e28",100))
    fillc(data,w,x+5,35,x+95,185,rgba("#2a423c",80))
    for j in range(3):
        tx=x+10+j*28;ty=50+math.sin(j)*5
        fillc(data,w,tx,ty,tx+24,ty+32,rgba("#e8e0d0",60))
        fillc(data,w,tx+2,ty+2,tx+22,ty+30,rgba("#f0e8d8",40))
save(os.path.join(OUT_DIR,"rules_example_table.png"),data,w,h)
print(f"  ✓ rules_example_table")

# ── achievement_medal_glow (360x220) ──
data,w,h=mk(360,220);grad(data,w,0,0,w,h,rgba("#1a1208"),rgba("#2a1e10"))
cx,cy=80,110
for r,a in[(65,12),(50,18),(38,26)]:ellc(data,w,cx,cy,r,r,rgba("#f0d060",a))
ellc(data,w,cx,cy,30,30,rgba("#e8c848",160))
ellc(data,w,cx,cy,22,22,rgba("#f8e070",120))
line(data,w,cx-8,cy-6,cx+8,cy-6,rgba("#6a4010",180),3)
for i in range(4):
    x=130+i*50;y=50+math.sin(i)*20
    fillc(data,w,x,y,x+40,y+30,rgba("#3a5a4a",80))
save(os.path.join(OUT_DIR,"achievement_medal_glow.png"),data,w,h)
print(f"  ✓ achievement_medal_glow")

# ── item_activation_charm (360x220) ──
data,w,h=mk(360,220);grad(data,w,0,0,w,h,rgba("#0e1418"),rgba("#1a2228"))
cx,cy=80,110
for r,a in[(50,14),(36,20),(22,28)]:ellc(data,w,cx,cy,r,r,rgba("#6a9aca",a))
for i in range(5):
    a=i*math.tau/5-math.tau/10;a2=a+math.tau/10;r1,r2=30,14
    x1=int(cx+math.cos(a)*r1);y1=int(cy+math.sin(a)*r1)
    x2=int(cx+math.cos(a2)*r2);y2=int(cy+math.sin(a2)*r2)
    line(data,w,x1,y1,x2,y2,rgba("#8abaea",180),3)
for i in range(4):
    x=130+i*50;y=50+math.sin(i*1.3)*20
    fillc(data,w,x,y,x+40,y+30,rgba("#4a7a9a",70))
save(os.path.join(OUT_DIR,"item_activation_charm.png"),data,w,h)
print(f"  ✓ item_activation_charm")

# ── settings_audio_wave (420x160) ──
data,w,h=mk(420,160);grad(data,w,0,0,w,h,rgba("#0e1620"),rgba("#1a2a38"))
for i in range(6):
    x=30+i*30;h_=int(40+30*math.sin(i*1.1))
    fillc(data,w,x,80-h_,x+18,80+h_,rgba("#6aaaca",80-8*i))
for i in range(3):
    x=200+i*60;h_=int(20+15*math.sin(i*2.3))
    fillc(data,w,x,80-h_,x+14,80+h_,rgba("#4a8aaa",60-10*i))
save(os.path.join(OUT_DIR,"settings_audio_wave.png"),data,w,h)
print(f"  ✓ settings_audio_wave")

# ── settings_music_disc (420x160) ──
data,w,h=mk(420,160);grad(data,w,0,0,w,h,rgba("#0e1416"),rgba("#1e2428"))
cx,cy=80,80
for r,a in[(60,12),(44,20),(30,28),(18,36),(8,50)]:
    c=rgba("#408080" if r%10<5 else "#60a8a8",a)
    ellc(data,w,cx,cy,r,r,c)
for i in range(3):
    x=160+i*80
    for r in[18,12,6]:ellc(data,w,x,cy,r,r,rgba("#489090",50-10*(18-r)))
save(os.path.join(OUT_DIR,"settings_music_disc.png"),data,w,h)
print(f"  ✓ settings_music_disc")

# ── secondary_back_path (360x140) ──
data,w,h=mk(360,140);grad(data,w,0,0,w,h,rgba("#0e1418"),rgba("#1a222a"))
for i in range(3):
    x=20+i*110
    fillc(data,w,x,40,x+80,110,rgba("#3a5a6a",70))
    fillc(data,w,x+8,48,x+72,102,rgba("#4a6a7a",50))
    line(data,w,x+40,60,x+40,100,rgba("#8abaea",60),2)
save(os.path.join(OUT_DIR,"secondary_back_path.png"),data,w,h)
print(f"  ✓ secondary_back_path")

# ── menu_currency_brocade (520x180) ──
data,w,h=mk(520,180);grad(data,w,0,0,w,h,rgba("#1a1e18"),rgba("#1e2218"))
for i in range(3):
    x=20+i*170
    ellc(data,w,x+40,90,32,32,rgba("#e8c848",100))
    ellc(data,w,x+40,90,20,20,rgba("#f0d860",80))
    for j in range(8):
        a=j*math.tau/8;sz=3 if j%2==0 else 2
        ellc(data,w,int(x+40+math.cos(a)*24),int(90+math.sin(a)*24),sz,sz,rgba("#f8e870",50))
    fillc(data,w,x+85,70,x+160,110,rgba("#4a7a5a",60))
save(os.path.join(OUT_DIR,"menu_currency_brocade.png"),data,w,h)
print(f"  ✓ menu_currency_brocade")

# ── menu_settings_gear (360x150) ──
data,w,h=mk(360,150);grad(data,w,0,0,w,h,rgba("#0e1a20"),rgba("#162a34"))
cx,cy=80,75
for i in range(8):
    a=i*math.tau/8
    line(data,w,int(cx+math.cos(a)*28),int(cy+math.sin(a)*28),int(cx+math.cos(a)*42),int(cy+math.sin(a)*42),rgba("#6ab0ca",60),4)
ellc(data,w,cx,cy,20,20,rgba("#6ab0ca",80))
ellc(data,w,cx,cy,10,10,rgba("#f0d860",120))
for i in range(3):
    x=140+i*60;fillc(data,w,x,60,x+40,90,rgba("#4a8aa0",60))
save(os.path.join(OUT_DIR,"menu_settings_gear.png"),data,w,h)
print(f"  ✓ menu_settings_gear")

# ── lobby_action_token (420x160) ──
data,w,h=mk(420,160);grad(data,w,0,0,w,h,rgba("#0e1a1c"),rgba("#1a2a2e"))
cx,cy=80,80
for r in[35,28,20,12]:ellc(data,w,cx,cy,r,r,rgba("#58a880",60-10*(35-r)))
ellc(data,w,cx,cy,8,8,rgba("#f0d860",140))
for i in range(4):
    x=140+i*60;poly(data,w,[(x,50),(x+30,65),(x+20,90),(x-10,75)],rgba("#58a880",60+10*i))
save(os.path.join(OUT_DIR,"lobby_action_token.png"),data,w,h)
print(f"  ✓ lobby_action_token")

# ── reset_danger_seal (420x160) ──
data,w,h=mk(420,160);grad(data,w,0,0,w,h,rgba("#1a0e0a"),rgba("#2e1a14"))
cx,cy=80,80
for r in[50,40,30,20,10]:
    a=40-8*(50-r) if r>30 else 90-6*(30-r)
    ellc(data,w,cx,cy,r,r,rgba("#d84a3a",a))
for i in range(4):
    x=140+i*60;fillc(data,w,x,55,x+40,105,rgba("#a04030",70))
    fillc(data,w,x+5,60,x+35,100,rgba("#c05040",50))
save(os.path.join(OUT_DIR,"reset_danger_seal.png"),data,w,h)
print(f"  ✓ reset_danger_seal")

# ── update_notes_strip (640x160) ──
data,w,h=mk(640,160);grad(data,w,0,0,w,h,rgba("#0e1614"),rgba("#1a2422"))
for i in range(4):
    x=40+i*150;y=30+math.sin(i)*20
    fillc(data,w,x,y,x+120,y+40,rgba("#3a6a5a",60))
    fillc(data,w,x,y+45,x+120,y+85,rgba("#4a7a6a",50))
    fillc(data,w,x+5,y+5,x+115,y+35,rgba("#4a7a6a",40))
save(os.path.join(OUT_DIR,"update_notes_strip.png"),data,w,h)
print(f"  ✓ update_notes_strip")

# ── win_detail_scroll (960x320) fix ──
data,w,h=mk(960,320);grad(data,w,0,0,w,h,rgba("#1a1410"),rgba("#2a221e"))
for i in range(5):
    y=25+i*58
    fillc(data,w,50,y,910,y+44,rgba("#2a1e18",120))
    fillc(data,w,55,y+6,905,y+38,rgba("#3a2e28",100))
    fillc(data,w,60,y+12,880,y+22,rgba("#6a5a3a",50))
border(data,w,h,12,rgba("#c8a848",30),1)
save(os.path.join(OUT_DIR,"win_detail_scroll.png"),data,w,h)
print(f"  ✓ win_detail_scroll")

print(f"Done in {time.time()-t0:.1f}s")
