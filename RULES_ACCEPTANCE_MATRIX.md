# 本地规则验收矩阵

版本：`1.0.180-godot`

本文件描述当前单机模式的可执行规则合同：以运行时代码和列出的回归为准。它不是高邮线下麻将或任何组织规则的外部认证；特殊地方番型、包赔口径与正式发布规则仍需另行确认。

| 规则项 | 当前本地合同 | 权威实现 | 自动回归 |
| --- | --- | --- | --- |
| 番分表与封顶 | 1/2/3/4/5/6/7/8+ 番对应 200/400/800/1600/3200/6400/12800/25600 分 | `scripts/main_base.gd` 的 `SCORE_TABLE`；`scripts/main_src/ai_brain.gd.part` 的 `score_points_for_fan` | `scripts/ai_play_round77_check.gd` |
| 基础计番 | 平胡 1 番；自摸、庄家、门清各 1 番；花牌及每组杠各加 1 番 | `scripts/main_src/core.gd.part` 的 `calculate_win_score_from_tiles` | `scripts/ai_play_round77_check.gd` |
| 特殊番型 | 七对、十三幺、清/混一色、字一色、大小三元、大小四喜、断幺九、碰碰胡、一条龙、大吊车 | `scripts/main_src/core.gd.part` 的 `calculate_win_score_from_tiles` 及牌型判定 helpers | `scripts/ai_play_round77_check.gd` |
| 自摸、荣和与抢杠胡 | 自摸三家各付一份；点炮/抢杠胡责任方付三份；结算前校验真实回合与牌源 | `scripts/main_src/gameplay.gd.part` 的 `can_finish_offline_round`、`finish_offline_round`；`scripts/main_src/core.gd.part` 的 `begin_rob_gang_resolution` | `scripts/ai_play_round30_check.gd`、`scripts/ai_play_round32_check.gd` |
| 包三搭 | 同一来源三次吃/碰/明杠形成包家；该赢家当局自摸、荣和、抢杠胡均由包家承担三份 | `scripts/main_src/core.gd.part` 的 `record_claim_source`、`package_payer_for`；`scripts/main_src/gameplay.gd.part` 的 `finish_offline_round` | `scripts/ai_play_round60_check.gd` |
| 荒庄查听 | 牌墙耗尽即荒庄；每名未听支付 1000 分，听牌者均分，总分守恒；全听或全未听不罚 | `scripts/main_base.gd` 的 `WALL_DRAW_NOTEN_BA`；`scripts/main_src/gameplay.gd.part` 的 `finish_wall_draw`、`settle_wall_draw_tenpai_payments` | `scripts/ai_play_round15_check.gd`、`scripts/ai_play_round61_check.gd` |
| 舍张振听 | 自家河牌命中当前任一听口时，全部荣和听口无效；自摸仍可结算 | `scripts/main_src/gameplay.gd.part` 的 `is_discard_furiten`、`can_ron_for_seat` | `scripts/ai_play_round41_check.gd` |
| 过水 | 放弃有效荣和后，下一次实际摸牌前不可荣和任一当前听口；摸牌后解除 | `scripts/main_src/gameplay.gd.part` 的 `record_passed_win_tile`、`is_passed_win_tile`、`clear_passed_win_tiles` | `scripts/ai_play_round42_check.gd`、`scripts/ai_play_round57_check.gd` |
| 食替 | 吃/碰后本拍禁打副露相关张；边吃额外禁换位张；实摸或成功出牌后解除，且不会锁死出牌 | `scripts/main_src/gameplay.gd.part` 的 `claim_discard_ban_tiles`、`is_claim_discard_banned`、`release_claim_discard_deadlock` | `scripts/ai_play_round58_check.gd` |
| 响应仲裁 | 胡优先于碰/杠/吃；同级碰杠吃由近家优先；玩家多人荣和窗口最终按提交者单家结算 | `scripts/main_src/gameplay.gd.part` 的 `resolve_ai_or_advance`、`apply_offline_claim`；`scripts/main_src/core.gd.part` 的抢杠入口 | `scripts/ai_play_round30_check.gd`、`scripts/ai_play_round32_check.gd` |
| 全桌账本 | 每局牌张账与四座总分均须守恒；静默商业模拟会输出 `score_conserved` | `scripts/main_src/gameplay.gd.part` 的 `offline_score_ledger_report` 和模拟聚合 | `scripts/ai_play_round82_check.gd` |

游戏内“麻将玩法指南”和 README 只展示上述本地合同的玩家可见摘要；改动番分、支付或牌型时，必须同时更新这三处并运行对应回归。
