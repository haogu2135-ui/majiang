#!/usr/bin/env python3
"""Generate an image candidate using Gemini (via CLIProxyAPI) without extra setup."""

from __future__ import annotations

import argparse
import base64
import json
import os
import re
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_BASE_URL = os.environ.get("GEMINI_BASE_URL") or os.environ.get("OPENAI_BASE_URL") or "https://api.686888666.xyz/v1"
DEFAULT_MODEL = "gemini-3.1-flash-image"
DEFAULT_KEY = os.environ.get("GEMINI_API_KEY") or os.environ.get("OPENAI_API_KEY") or "sk-946ec44b4905967756350925751ca936e0336f8f98c6b896b5faa46cdf888fe2"
DEFAULT_USER_AGENT = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36"
DEFAULT_TIMEOUT = 90
DEFAULT_RETRIES = 3


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--prompt", help="Prompt text.")
    parser.add_argument("--prompt-file", type=Path, help="Path to prompt text file.")
    parser.add_argument("--out", type=Path, required=True, help="Output image file path.")
    parser.add_argument("--model", default=DEFAULT_MODEL, help=f"Default: {DEFAULT_MODEL}")
    parser.add_argument("--base-url", default=None, help=f"Default: {DEFAULT_BASE_URL}")
    parser.add_argument("--api-key", default=None, help="CPA API key (defaults to configured key)")
    parser.add_argument("--timeout", type=int, default=DEFAULT_TIMEOUT, help=f"Request timeout in seconds (default: {DEFAULT_TIMEOUT}).")
    parser.add_argument("--retries", type=int, default=DEFAULT_RETRIES, help=f"Max retry attempts (default: {DEFAULT_RETRIES}).")
    return parser.parse_args()


def get_prompt(args: argparse.Namespace) -> str:
    if args.prompt:
        return args.prompt.strip()
    if args.prompt_file:
        return args.prompt_file.read_text(encoding="utf-8").strip()
    raise SystemExit("Error: either --prompt or --prompt-file is required.")


def _call_gemini_once(prompt: str, base_url: str, api_key: str, model: str, timeout: int) -> bytes:
    url = f"{base_url.rstrip('/')}/chat/completions"
    user_content = prompt if prompt.lower().startswith("generate an image") else f"Generate an image: {prompt}"
    payload = {
        "model": model,
        "messages": [
            {"role": "user", "content": user_content}
        ]
    }
    req = urllib.request.Request(
        url,
        data=json.dumps(payload).encode("utf-8"),
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
            "User-Agent": DEFAULT_USER_AGENT
        }
    )
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            data = json.loads(resp.read().decode())
    except urllib.error.HTTPError as e:
        body = e.read().decode(errors="replace")
        raise RuntimeError(f"HTTP {e.code}: {body}") from e

    choices = data.get("choices", [])
    if not choices:
        raise RuntimeError(f"No choices returned: {data}")

    message = choices[0].get("message", {})
    images = message.get("images", [])
    if images:
        img_url = images[0].get("image_url", {}).get("url", "")
        if not img_url:
            raise RuntimeError(f"Empty image url in: {images[0]}")
        if "," in img_url:
            _, b64 = img_url.split(",", 1)
        else:
            b64 = img_url
        return base64.b64decode(b64)

    content = message.get("content", "")
    match = re.search(r"data:image/(?:jpeg|png|webp);base64,([A-Za-z0-9+/=]+)", content)
    if match:
        return base64.b64decode(match.group(1))

    match_b64 = re.search(r"base64,([A-Za-z0-9+/=]+)", content)
    if match_b64:
        return base64.b64decode(match_b64.group(1))

    raise RuntimeError(f"No images found in message (content len: {len(content)}, message: {message})")


def generate_image(prompt: str, base_url: str, api_key: str, model: str, timeout: int, retries: int = 3) -> bytes:
    last_err = None
    for attempt in range(1, retries + 1):
        try:
            return _call_gemini_once(prompt, base_url, api_key, model, timeout)
        except Exception as e:
            last_err = e
            print(f"[Attempt {attempt}/{retries}] Generation failed: {e}", file=sys.stderr)
            if attempt < retries:
                time.sleep(attempt * 6)
    raise RuntimeError(f"All {retries} attempts failed. Last error: {last_err}") from last_err


def main() -> None:
    args = parse_args()
    prompt = get_prompt(args)
    base_url = args.base_url or os.environ.get("CPA_BASE_URL") or DEFAULT_BASE_URL
    api_key = args.api_key or os.environ.get("CPA_API_KEY") or DEFAULT_KEY

    print(f"Generating image with {args.model} via {base_url}...")
    img_bytes = generate_image(prompt, base_url, api_key, args.model, args.timeout, args.retries)

    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_bytes(img_bytes)
    print(f"Image saved to: {args.out} ({len(img_bytes)} bytes)")


if __name__ == "__main__":
    main()
