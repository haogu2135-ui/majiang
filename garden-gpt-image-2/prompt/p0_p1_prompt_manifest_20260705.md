# P0/P1 Prompt Manifest

- Mode check: `B-or-C`
- Garden local generation: not enabled in the current shell
- Source brief: `GPT_IMAGE_AGENT_EXECUTION_BRIEF.md`
- Entry prompt: `garden-gpt-image-2/prompt/mahjong-guofeng-image-requirements-20260705.md`
- Candidate output directory: `garden-gpt-image-2/image/candidates/`

## P0 Human-vs-AI

1. `garden-gpt-image-2/prompt/p0_table_gpt_backdrop_v4.md`
2. `garden-gpt-image-2/prompt/p0_mahjong_tile_3d_edit_template.md`
3. `garden-gpt-image-2/prompt/p0_wall_strip_landscape_v2.md`
4. `garden-gpt-image-2/prompt/p0_tile_back_3d.md`
5. `garden-gpt-image-2/prompt/p0_wall_live_feedback_kit_v1.md`
6. `garden-gpt-image-2/prompt/p0_hand_gpt_tray_v4.md`
7. `garden-gpt-image-2/prompt/p0_action_gpt_dock_v5.md`
8. `garden-gpt-image-2/prompt/p0_seat_gpt_brocade_v4.md`
9. `garden-gpt-image-2/prompt/p0_pending_claim_status_strip.md`

## P1 Online Lobby

1. `garden-gpt-image-2/prompt/p1_online_gpt_lobby_v3.md`
2. `garden-gpt-image-2/prompt/p1_online_lobby_panel_kit.md`
3. `garden-gpt-image-2/prompt/p1_online_feedback_gpt_strip_v2.md`

## Execution Rules

- Generate at least 3 candidates per prompt.
- Keep candidates under `garden-gpt-image-2/image/candidates/`.
- Do not overwrite stable files under `assets/illustrations/` until screenshot review passes.
- For tile edits, use the current same-name `assets/tiles/*.png` as the source image.
- Reject any output with text, numbers, logo, watermark, fake transparency, random UI buttons, or changed tile identity.
