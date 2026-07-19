#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
split_main_parts.py — 调试用：把 scripts/main_src/_legacy_body.gd.part 按「顶层块」拆分清单，
帮助阶段化提取时定位每个 func/const/var 的精确边界。

不修改任何文件，只打印 JSON 清单到 stdout：[{kind, name, start_line, end_line, snippet}]
其中 kind ∈ {func, static_func, const, var, enum, decl_multi}，行号 1-based。
"""
from __future__ import annotations
import json, re, sys
from pathlib import Path

LEGACY = Path("scripts/main_src/_legacy_body.gd.part")
TOP_RE = re.compile(r"^(func|static func|const|var|enum)\b")

def main() -> int:
    lines = LEGACY.read_text(encoding="utf-8").split("\n")
    # Legacy part starts with a blank "leading" line (was line 7 of original main.gd).
    # We treat top-level blocks as runs that begin with a TOP_RE line at col 0.
    blocks = []
    i = 0
    n = len(lines)
    # skip leading blank lines (preserve them as a leading "preamble" note)
    while i < n and lines[i].strip() == "":
        i += 1
    while i < n:
        m = TOP_RE.match(lines[i])
        if not m:
            # blank line or continuation between blocks — skip; blocks bounded by TOP_RE starts.
            i += 1
            continue
        kind = m.group(1)
        start = i + 1  # 1-based
        # gather following lines until the next TOP_RE line OR EOF;
        # include trailing blank lines that belong to this block, but stop at a new TOP_RE.
        j = i + 1
        while j < n:
            if TOP_RE.match(lines[j]):
                break
            j += 1
        # trim trailing blank lines from block extent (they belong to inter-block spacing)
        k = j
        while k - 1 > i and lines[k - 1].strip() == "":
            k -= 1
        end = k  # 1-based, inclusive
        name = lines[i].split("(", 1)[0]
        name = re.sub(r"^(func|static func|const|var|enum)\s+", "", name).strip()
        blocks.append({
            "kind": "func" if kind == "func" else ("static_func" if kind == "static func" else kind),
            "name": name,
            "start": start,
            "end": end,
            "snippet": lines[i][:90],
        })
        i = j
    json.dump(blocks, sys.stdout, ensure_ascii=False, indent=0)
    print()
    return 0

if __name__ == "__main__":
    sys.exit(main())
