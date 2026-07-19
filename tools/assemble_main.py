#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
assemble_main.py — 把 scripts/main_src/*.gd.part 拼接为发货用的 scripts/main.gd。

背景:
  GDScript 4.6 仅支持单继承，main.gd extends main_base.gd extends Control，
  继承链已用满，无法用额外 extends 分文件存方法；也无 #include / mixin。
  因此采用「源子模块 + 构建期拼接」方案：人类编辑 main_src/*.gd.part，
  本脚本按固定顺序拼出单一 main.gd 供 Godot 加载。

用法:
  python tools/assemble_main.py            # 生成 scripts/main.gd（默认）
  python tools/assemble_main.py --check     # 仅校验 part 合法性，不写盘
  python tools/assemble_main.py --diff      # 比对现有 main.gd 与生成产物的函数名集合差异
  python tools/assemble_main.py --verify    # 生成并与现有 main.gd 做字节比对（CI 守门）

约定:
  - _header.gd.part 是唯一允许的「全局头部」：可含 extends / preload / const / var / signal。
  - 其余 *.gd.part 仅允许 func 体与模块私有 const/var/enum；禁止顶层
    extends / class_name / preload / signal / @onready / @export（否则报错不写盘）。
"""
from __future__ import annotations

import argparse
import difflib
import os
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SRC_DIR = ROOT / "scripts" / "main_src"
HEADER_PART = SRC_DIR / "_header.gd.part"
OUTPUT = ROOT / "scripts" / "main.gd"

BANNER = (
    "# ============================================================\n"
    "# !!! AUTO-GENERATED — 请勿手工编辑 !!!\n"
    "# 本文件由 tools/assemble_main.py 从 scripts/main_src/*.gd.part 拼接生成。\n"
    "# 请改对应的 .part 文件后运行:  python tools/assemble_main.py\n"
    "# 直接改本文件将在下次拼接时丢失。\n"
    "# ============================================================\n"
)

# 仅允许出现在 _header.gd.part 顶层的关键字；其余 part 不得出现
HEADER_ONLY_TOKENS = ("extends", "class_name", "preload", "signal", "@onready", "@export")


def read_parts() -> list[Path]:
    """返回按固定顺序排列的 part 文件列表（_header 在最前，其余按 ORDER 指定的子系统顺序）。"""
    if not SRC_DIR.is_dir():
        raise SystemExit(f"assemble_main: 缺少源目录 {SRC_DIR}")
    found = {p.name: p for p in SRC_DIR.glob("*.gd.part")}
    if not found:
        raise SystemExit(f"assemble_main: 源目录 {SRC_DIR} 内没有 *.gd.part 文件")
    if HEADER_PART.name not in found:
        raise SystemExit(f"assemble_main: 缺少必需的头部文件 {HEADER_PART.name}")
    # 期望的子系统顺序（_header 强制首位）。其余 part 按 ORDER 排；
    # 未列出的 part 追加到末尾（按文件名升序），保证新加 part 不会被漏拼。
    ORDER = [
        "_header.gd.part",
        "audio.gd.part",
        "ai_brain.gd.part",
        "gameplay.gd.part",
        "render.gd.part",
        "screens.gd.part",
        "online.gd.part",
        "core.gd.part",
    ]
    ordered: list[Path] = [found.pop("_header.gd.part")]
    for name in ORDER[1:]:
        if name in found:
            ordered.append(found.pop(name))
    # 任何未在 ORDER 中登记但确实存在的 part 追加到末尾
    for name in sorted(found):
        ordered.append(found[name])
    return ordered


_INDEX_RE = re.compile(r"^\s*#", re.MULTILINE)
_FUNC_RE = re.compile(r"^\s*func\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(", re.MULTILINE)
_TOPLEVEL_FORBIDDEN_RE = re.compile(
    r"^(?!\s|#)(?:extends|class_name|preload|signal|@onready|@export)\b",
    re.MULTILINE,
)


def validate_part(path: Path) -> None:
    text = path.read_text(encoding="utf-8")
    # 顶层禁止关键字（_header 例外）
    if path != HEADER_PART:
        m = _TOPLEVEL_FORBIDDEN_RE.search(text)
        if m:
            line_no = text.count("\n", 0, m.start()) + 1
            raise SystemExit(
                f"assemble_main: {path.name} 第 {line_no} 行出现仅允许在 _header 使用的"
                f" 顶层关键字「{m.group(0)}」"
            )
    # 统计 func 名（用于跨文件重名/重复检测与 --diff）
    names = _FUNC_RE.findall(text)
    if len(names) != len(set(names)):
        seen = set()
        dup = [n for n in names if n in seen or seen.add(n)]
        raise SystemExit(f"assemble_main: {path.name} 内存在重复 func: {sorted(set(dup))}")


def collect_func_names(parts: list[Path]) -> dict[str, str]:
    """返回 {func_name: owning_part}。"""
    owner: dict[str, str] = {}
    for p in parts:
        text = p.read_text(encoding="utf-8")
        for name in _FUNC_RE.findall(text):
            if name in owner:
                raise SystemExit(
                    f"assemble_main: func `{name}` 在 {owner[name]} 与 {p.name} 中重复定义"
                )
            owner[name] = p.name
    return owner


def assemble_text(parts: list[Path], with_banner: bool = True) -> str:
    """按顺序拼接各 part，产物以单个换行结尾（GDScript 习惯）。
    - _header（第一个 part）紧接在 banner 后；banner 与 _header 之间无空行。
    - 第一个 part 内部本身就是真·全局声明，其后用一个换行接 body ——
      为保持与原 main.gd 字节级一致（_header 末为 var 行，_legacy_body 以空行(行7)开头），
      _header → 其后第一个 part 用 ("\n") 单换行衔接。
    - 其余 part 之间用 ("\n\n") 双换行分隔，便于阅读。"""
    chunks: list[str] = []
    if with_banner:
        chunks.append(BANNER)
    for idx, p in enumerate(parts):
        body = p.read_text(encoding="utf-8").rstrip("\n")
        if idx == 0:
            # banner 后直接接 _header（banner 末尾自带换行）；
            # 纯 header 模（无 banner）时 _header 即为产物起始。
            chunks.append(body)
        elif idx == 1:
            # _header 后接第一个 body：用单换行，复刻原文件的「行6\n行7空\n行8」结构
            chunks.append("\n" + body)
        else:
            chunks.append("\n\n" + body)
    return "".join(chunks) + "\n"


def cmd_generate(args: argparse.Namespace) -> int:
    parts = read_parts()
    for p in parts:
        validate_part(p)
    collect_func_names(parts)  # 跨 part 重名检测
    text = assemble_text(parts, with_banner=args.banner)
    if args.stdout:
        sys.stdout.write(text)
        return 0
    OUTPUT.write_text(text, encoding="utf-8")
    print(f"assemble_main: 已生成 {OUTPUT.relative_to(ROOT)} ({len(text.splitlines())} 行, "
          f"来自 {len(parts)} 个 part)")
    return 0


def cmd_check(args: argparse.Namespace) -> int:
    parts = read_parts()
    for p in parts:
        validate_part(p)
    owner = collect_func_names(parts)
    print(f"assemble_main: 校验通过 — {len(parts)} 个 part, {len(owner)} 个 func 全部唯一")
    return 0


def cmd_diff(args: argparse.Namespace) -> int:
    parts = read_parts()
    for p in parts:
        validate_part(p)
    generated = assemble_text(parts, with_banner=True)
    if not OUTPUT.exists():
        print("assemble_main --diff: 现有 main.gd 不存在，无法比对。")
        return 1
    current = OUTPUT.read_text(encoding="utf-8")
    cur_funcs = set(_FUNC_RE.findall(current))
    gen_funcs = set(_FUNC_RE.findall(generated))
    only_curr = sorted(cur_funcs - gen_funcs)
    only_gen = sorted(gen_funcs - cur_funcs)
    if not only_curr and not only_gen:
        print("assemble_main --diff: func 名集合一致（无增减）")
        # 进一步做逐行 diff 摘要
        diff = list(difflib.unified_diff(current.splitlines(), generated.splitlines(),
                                         fromfile="main.gd(now)", tofile="main.gd(gen)", lineterm=""))
        print(f"  逐行差异: {sum(1 for l in diff if l.startswith(('+','-')) and not l.startswith(('+++','---')))} 处")
        if diff:
            print("\n".join(diff[:40]))
        return 0
    print(f"assemble_main --diff: 现有 main.gd 独有 func ({len(only_curr)}): {only_curr[:30]}")
    print(f"assemble_main --diff: 生成产物独有 func ({len(only_gen)}): {only_gen[:30]}")
    return 1


def cmd_verify(args: argparse.Namespace) -> int:
    """生成并与现有 main.gd 字节比对；CI 守门用。"""
    parts = read_parts()
    for p in parts:
        validate_part(p)
    collect_func_names(parts)
    generated = assemble_text(parts, with_banner=True)
    if not OUTPUT.exists():
        print("assemble_main --verify: 现有 main.gd 不存在。")
        return 1
    current = OUTPUT.read_text(encoding="utf-8")
    if current == generated:
        print("assemble_main --verify: OK — 现有 main.gd 与生成产物字节一致")
        return 0
    diff = list(difflib.unified_diff(current.splitlines(), generated.splitlines(),
                                     fromfile="main.gd(now)", tofile="main.gd(gen)", lineterm=""))
    only_curr = [l for l in diff if l.startswith("-") and not l.startswith("---")]
    only_gen = [l for l in diff if l.startswith("+") and not l.startswith("+++")]
    print(f"assemble_main --verify: 主文件与产物不一致 (现减 {len(only_curr)} 行 / 现加 {len(only_gen)} 行)")
    print("  摘要:")
    print("\n".join(diff[:30]))
    print("  → 请运行 `python tools/assemble_main.py` 重新生成后再提交。")
    return 1


def main() -> int:
    parser = argparse.ArgumentParser(description="拼接 scripts/main.gd 的生成工具")
    parser.add_argument("--check", action="store_true", help="仅校验 part 合法性，不写盘")
    parser.add_argument("--diff", action="store_true", help="比对现有 main.gd 与生成产物")
    parser.add_argument("--verify", action="store_true", help="生成并比对，不一致则非零退出")
    parser.add_argument("--no-banner", dest="banner", action="store_false",
                        help="不在产物顶部插入 AUTO-GENERATED 警示头")
    parser.add_argument("--stdout", action="store_true",
                        help="将生成产物写到标准输出而非 scripts/main.gd（便于流水线比对）", )
    args = parser.parse_args()
    if args.verify:
        return cmd_verify(args)
    if args.diff:
        return cmd_diff(args)
    if args.check:
        return cmd_check(args)
    return cmd_generate(args)


if __name__ == "__main__":
    sys.exit(main())
