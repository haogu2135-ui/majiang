#!/usr/bin/env python3
"""Generate the four rules-screen section illustration panels via GPT image API.

These replace the sparse code-drawn example strips on the right side of each
rule section card. Each panel is a decorative dark-jade backdrop that sits
behind the engine-drawn section content, matching the project guofeng style.
"""
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))

from openai import OpenAI  # noqa: E402
import generate_gpt_images as gpt  # noqa: E402


# name -> (target size, purpose cue, scene detail)
PANELS = {
    "rules_section_goal_panel": (
        "512x768",
        "objective / win-condition example plaque",
        "four calm meld groupings and one paired keystone arranged as a quiet "
        "vertical shrine of jade tile blocks, a soft gold completion halo at top",
    ),
    "rules_section_meld_panel": (
        "512x768",
        "meld types example plaque (sequence / triplet / kong / pair)",
        "three short stacked rows of abstract jade tile blocks suggesting a run, "
        "a triple and a quad, with a small paired keystone below, gentle gold rims",
    ),
    "rules_section_special_panel": (
        "512x768",
        "special hands example plaque (seven pairs / thirteen orphans / flush)",
        "a lattice of small paired jade blocks and a single luminous violet "
        "orphan token, restrained purple-gold accents, rare-hand aura",
    ),
    "rules_section_action_panel": (
        "512x768",
        "gameplay actions example plaque (discard / chow-pong-kong / win)",
        "a soft downward flow of a single highlighted tile toward a warm gold "
        "response seal, calm directional motes, tactile lacquer surface",
    ),
}


def build_prompt(cue: str, scene: str, size: str) -> str:
    return (
        "Create a Chinese guofeng mobile mahjong rules-screen side example panel.\n"
        f"Asset purpose: {cue}.\n"
        f"Asset type: reusable vertical PNG UI backdrop, {size}, sits behind engine text.\n"
        f"Scene/backdrop: {scene}, on a deep ink-jade lacquer plaque with subtle silk-paper grain.\n"
        "Style/medium: polished premium game UI illustration, Chinese ink wash, "
        "dark jade silk, warm gold foil rims, restrained cinnabar accents.\n"
        "Composition/framing: single centered decorative motif, generous safe "
        "padding, low-contrast so overlaid UI text stays readable, quiet edges.\n"
        "Lighting/mood: calm, elegant, tactile, museum-plaque stillness.\n"
        "Color palette: deep jade, ink black, muted teal, warm gold, tiny cinnabar details only.\n"
        "Constraints: no words, no numbers, no logo, no watermark, no real brands, "
        "no people, no readable mahjong tile symbols or pips.\n"
        "Avoid: flat programmatic gradients, casino neon, western fantasy styling, "
        "beige parchment dominance, cluttered centers, hard engine-rendered button labels."
    )


def main() -> int:
    gpt.load_project_env()
    import os

    if not os.environ.get("OPENAI_API_KEY"):
        print("OPENAI_API_KEY is not set.", file=sys.stderr)
        return 2

    model = os.environ.get("OPENAI_IMAGE_MODEL") or gpt.DEFAULT_MODEL
    client = OpenAI(base_url=os.environ.get("OPENAI_BASE_URL") or None)

    out_dir = ROOT / "assets" / "illustrations"
    for offset, (name, (size, cue, scene)) in enumerate(PANELS.items(), start=1):
        path = out_dir / f"{name}.png"
        task = gpt.ImageTask(
            index=offset,
            name=name,
            path=path,
            size=size,
            prompt=build_prompt(cue, scene, size),
            source="rules-section-panels",
        )
        print(f"generate: {path.relative_to(ROOT)} ({size})")
        gpt.generate_image_with_retry(client, task, model)
        print(f"  done: {path.relative_to(ROOT)}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
