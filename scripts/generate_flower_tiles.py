#!/usr/bin/env python3
import math
import os
import struct
import zlib

WIDTH = 200
HEIGHT = 280
OUT_DIR = os.path.join("assets", "tiles")

FLOWERS = [
    ("h1", (210, 55, 66), (250, 188, 154)),
    ("h2", (24, 139, 86), (178, 235, 158)),
    ("h3", (196, 103, 24), (255, 199, 94)),
    ("h4", (40, 104, 198), (166, 219, 255)),
    ("h5", (193, 43, 98), (250, 180, 210)),
    ("h6", (116, 70, 204), (214, 188, 255)),
    ("h7", (22, 130, 55), (178, 228, 144)),
    ("h8", (207, 141, 22), (255, 225, 112)),
]


def blend(dst, src):
    sa = src[3] / 255.0
    da = dst[3] / 255.0
    out_a = sa + da * (1.0 - sa)
    if out_a <= 0:
        return (0, 0, 0, 0)
    out = []
    for i in range(3):
        out.append(int((src[i] * sa + dst[i] * da * (1.0 - sa)) / out_a))
    out.append(int(out_a * 255))
    return tuple(out)


def set_px(img, x, y, color):
    if 0 <= x < WIDTH and 0 <= y < HEIGHT:
        img[y][x] = blend(img[y][x], color)


def rounded_rect(img, x0, y0, x1, y1, radius, color):
    for y in range(y0, y1):
        for x in range(x0, x1):
            dx = max(x0 + radius - x, 0, x - (x1 - radius - 1))
            dy = max(y0 + radius - y, 0, y - (y1 - radius - 1))
            if dx * dx + dy * dy <= radius * radius:
                set_px(img, x, y, color)


def rect(img, x0, y0, x1, y1, color):
    for y in range(y0, y1):
        for x in range(x0, x1):
            set_px(img, x, y, color)


def ellipse(img, cx, cy, rx, ry, color):
    for y in range(int(cy - ry), int(cy + ry) + 1):
        for x in range(int(cx - rx), int(cx + rx) + 1):
            nx = (x - cx) / rx
            ny = (y - cy) / ry
            if nx * nx + ny * ny <= 1.0:
                set_px(img, x, y, color)


def line(img, x0, y0, x1, y1, color, width=3):
    steps = max(abs(x1 - x0), abs(y1 - y0), 1)
    for i in range(steps + 1):
        t = i / steps
        x = int(round(x0 + (x1 - x0) * t))
        y = int(round(y0 + (y1 - y0) * t))
        ellipse(img, x, y, width, width, color)


def flower(img, cx, cy, accent, soft, variant):
    petals = 5 + (variant % 4)
    for i in range(petals):
        angle = math.tau * i / petals + variant * 0.13
        px = cx + math.cos(angle) * 34
        py = cy + math.sin(angle) * 31
        ellipse(img, px, py, 24, 34, (*soft, 210))
        line(img, cx, cy, int(px), int(py), (*accent, 105), 2)
    ellipse(img, cx, cy, 22, 22, (*accent, 230))
    ellipse(img, cx, cy, 9, 9, (255, 241, 180, 235))


def leaf_strip(img, accent):
    for i in range(4):
        y = 66 + i * 38
        line(img, 56, y + 23, 144, y - 9, (*accent, 70), 2)
        ellipse(img, 70, y + 17, 12, 22, (*accent, 95))
        ellipse(img, 130, y - 3, 12, 22, (*accent, 95))


def make_tile(code, accent, soft, variant):
    img = [[(0, 0, 0, 0) for _x in range(WIDTH)] for _y in range(HEIGHT)]
    rounded_rect(img, 0, 0, WIDTH, HEIGHT, 18, (86, 72, 42, 255))
    rounded_rect(img, 5, 5, WIDTH - 5, HEIGHT - 5, 14, (246, 241, 219, 255))
    rounded_rect(img, 14, 16, WIDTH - 14, 57, 10, (*soft, 220))
    rounded_rect(img, 14, HEIGHT - 57, WIDTH - 14, HEIGHT - 16, 10, (*soft, 205))
    rect(img, 26, 62, WIDTH - 26, HEIGHT - 62, (255, 250, 231, 95))
    leaf_strip(img, accent)
    flower(img, WIDTH // 2, HEIGHT // 2 - 2, accent, soft, variant)
    rounded_rect(img, 18, 18, 52, 48, 8, (255, 252, 238, 220))
    rounded_rect(img, WIDTH - 52, 18, WIDTH - 18, 48, 8, (255, 252, 238, 220))
    rounded_rect(img, 18, HEIGHT - 48, 52, HEIGHT - 18, 8, (255, 252, 238, 220))
    rounded_rect(img, WIDTH - 52, HEIGHT - 48, WIDTH - 18, HEIGHT - 18, 8, (255, 252, 238, 220))
    return img


def save_png(path, img):
    raw = bytearray()
    for row in img:
        raw.append(0)
        for px in row:
            raw.extend(px)
    def chunk(kind, data):
        payload = kind + data
        return struct.pack(">I", len(data)) + payload + struct.pack(">I", zlib.crc32(payload) & 0xFFFFFFFF)
    png = b"\x89PNG\r\n\x1a\n"
    png += chunk(b"IHDR", struct.pack(">IIBBBBB", WIDTH, HEIGHT, 8, 6, 0, 0, 0))
    png += chunk(b"IDAT", zlib.compress(bytes(raw), 9))
    png += chunk(b"IEND", b"")
    with open(path, "wb") as f:
        f.write(png)


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    for idx, (code, accent, soft) in enumerate(FLOWERS):
        img = make_tile(code, accent, soft, idx)
        save_png(os.path.join(OUT_DIR, f"tile_flower_{code}.png"), img)


if __name__ == "__main__":
    main()
