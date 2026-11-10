# Quiet jade table, 2026-11-09

- Asset: `table_jade_quiet_gpt_20261109.png`
- Generator: OpenAI-compatible image API configured by the repository `.gateway.env`, model `gpt-image-2`, via the bundled imagegen skill CLI; quality high, size 1536×1024.
- Prompt: `output/imagegen/ui_refresh_20261109/table_prompt.txt`.
- Original output: `output/imagegen/ui_refresh_20261109/table_jade.png` (copied byte for byte).
- Runtime use: full-screen table. Seats and table center use the separate quiet ink bitmap listed below. Native 2D tile art is unchanged.
- Generation log: `build/qa/ui_refresh_20261109/imagegen_table_02.log`. First attempt stopped because the system Python lacked the SDK; the repository virtual environment succeeded.

## Shared ink reading surface

- Asset: `reading_ink_quiet_gpt_20261109.png` (1024×1024).
- Same generator and quality as above; prompt `output/imagegen/ui_refresh_20261109/reading_prompt.txt`.
- Original: `output/imagegen/ui_refresh_20261109/reading_ink.png`, copied byte for byte.
- Log: `build/qa/ui_refresh_20261109/imagegen_reading_01.log`.
- Replaces the shared `menu_ink_primary` surface for seats, center and primary controls with unornamented ink paper. Runtime uses the bitmap without tinting.

## Gold focus accent

- Asset: `gold_paper_gpt_20261109.png` (1024×1024).
- Same generator and quality as above; prompt `output/imagegen/ui_refresh_20261109/gold_prompt.txt`.
- Original: `output/imagegen/ui_refresh_20261109/gold_paper.png`, copied byte for byte.
- Log: `build/qa/ui_refresh_20261109/imagegen_gold_01.log`.
- Used only for the home focus underline and the latest-discard marker outside tile faces.
