# Guofeng 3D UI Page Prompt Pack

- Output brief: `GPT_IMAGE_UI_DESIGN_PROMPTS.md`
- Designer agent: `qa/agents/ui_design_agent.md`
- Image agent: `qa/agents/gpt_image_agent.md`
- Mode: GPT Image 2 Garden Mode A prompt handoff
- Date: 2026-07-05

This is a batch prompt handoff for the commercial guofeng 3D redesign of the Mahjong app UI.

Use `GPT_IMAGE_UI_DESIGN_PROMPTS.md` as the source of truth. It contains copy-ready prompts for:

1. `menu_lobby_gpt_scene_v2`
2. `menu_card_frame_kit`
3. `settings_gpt_panel_v2`
4. `table_gpt_backdrop_v4`
5. `rules_gpt_scroll_v2`
6. `stats_gpt_dashboard_v3`
7. `achievement_gpt_gallery_v3`
8. `shop_gpt_vault_v2`
9. `online_gpt_lobby_v3`
10. `daily_login_gpt_calendar_v2`
11. `loading_scene_gpt_backdrop_v2`
12. `guofeng_3d_control_kit`

Important generation rules:

- Generate only UI art layers: background, frame, material, empty slots, and decorative surfaces.
- Do not generate readable UI text, numbers, buttons with labels, logos, watermarks, people, or readable mahjong tile faces.
- Runtime text, buttons, tile faces, player state, prices, room IDs, and stats must remain Godot-rendered.
- Any playable tile image must use the current matching `assets/tiles/*.png` image as a GPT edit reference. Do not create playable tile faces from text-only prompts.
- Save accepted candidates under `assets/illustrations/` only after visual review; keep experiments under `garden-gpt-image-2/image/`.

Recommended first generation batch:

```bash
# Generate each prompt from GPT_IMAGE_UI_DESIGN_PROMPTS.md as an individual image task.
# Do not run non-GPT procedural image scripts.
```
