# AI / 玩法 Round 7 — 全 Bot 同步模拟与残局追分

日期：2026-07-25  
版本：1.0.180  
验收：`scripts/ai_play_round7_check.gd`

## 目标

打通 **seat0 也可 AI 操控** 的离线全 bot 路径，支持 headless **整手牌同步模拟**；并补强残局追分/守成弃攻与人设轮换。

## 新增能力

| API | 作用 |
|-----|------|
| `is_ai_controlled_seat(seat)` | 常规：seat≠0；`offline_all_bot_mode`：全座位 |
| `enable_offline_all_bot_mode(enabled, quiet)` | 开全 bot + 静默（跳过渲染/音效/存档/成就） |
| `simulate_offline_bot_hand_sync(max_steps)` | 单局同步推演至终局/荒庄 |
| `sample_bot_strength_across_difficulties(n, seed)` | 三档危险弃牌率短采样 |
| `reshuffle_ai_profiles_for_hand()` | 简单固定；标准打乱 1–3；困难全座位乱序 |
| `ai_profile_seat_map` | seat → `AI_PROFILES` 索引 |

`choose_ai_claim` / `choose_ai_rob_gang` / 人类响应入口均改为 `is_ai_controlled_seat`，人机对战行为不变。

## 残局调参

- `tenpai_fold_adjustment`：守成 ×(1+0.28·late)，追分 ×(1−0.22·late)；困难 ×1.10 / 简单 ×0.80
- 荣和 `追分落袋`：困难可吃 1 番起，简单需 3 番起

## 验收要点

1. 常规 seat0 非 AI；全 bot 下 seat0 可碰/胡响应  
2. 人设映射排列合法；简单固定  
3. 同座位守成弃攻 ≥ 追分；困难守成 ≥ 简单  
4. 同步模拟能终局且无死循环  
5. 困难危险弃牌率不显著高于简单（+0.35 容差）

## 运行

```bash
python3 tools/assemble_main.py --verify
GODOT_SILENCE_ROOT_WARNING=1 LP_NUM_THREADS=2 godot --headless --path . -s scripts/ai_play_round7_check.gd
```

单手全 bot 模拟约 15–25s（每弃牌全量 `get_ai_discard_reports`）。

## 后续（R8 候选）

- 降低模拟算力（候选剪枝 / 浅层评估）
- 多手胜率统计（固定种子 20+ hands）
- 危险弃牌阈值阈值校准（当前绝对危险率偏高，相对序更有意义）
- 真人对局中按难度提示「对手人设」
