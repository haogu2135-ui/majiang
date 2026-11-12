#!/usr/bin/env python3
"""Bind a UI QA batch to source/asset bytes, including uncommitted changes."""
import argparse
import datetime
import hashlib
import json
from pathlib import Path
import subprocess


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    paths = {root / "project.godot", root / "Main.tscn"}
    for directory in ("scripts", "shaders", "scenes", "assets", "tools"):
        for path in (root / directory).rglob("*"):
            if not path.is_file() or "__pycache__" in path.parts:
                continue
            if any(part.startswith("_replaced_") for part in path.parts):
                continue
            if path.name.endswith((".orig", ".log", ".pyc")):
                continue
            paths.add(path)
    files = {
        str(path.relative_to(root)): hashlib.sha256(path.read_bytes()).hexdigest()
        for path in sorted(paths)
    }
    digest = hashlib.sha256(json.dumps(files, sort_keys=True).encode()).hexdigest()
    receipt = {
        "created_utc": datetime.datetime.now(datetime.timezone.utc).isoformat(),
        "revision": subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=root, text=True).strip(),
        "manifest_sha256": digest,
        "files": files,
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(receipt, indent=2) + "\n")
    print(digest)


if __name__ == "__main__":
    main()
