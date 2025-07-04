-- Запрос для заполнения таблицы данными из S3
-- Используется функция s3 для чтения JSON файлов и их преобразования в плоскую структуру

INSERT INTO raw.match_stats
SELECT
    -- Основные поля матча
    JSONExtractString(json, 'match_id') as match_id,
    toDate(JSONExtractString(json, 'match_date')) as match_date,
    team_id,
    is_home,
    
    -- Summary статистика
    JSONExtractString(json, 'teams_stats', team_id, 'summary', 'minutes') as summary_minutes,
    JSONExtractString(json, 'teams_stats', team_id, 'summary', 'goals') as summary_goals,
    JSONExtractString(json, 'teams_stats', team_id, 'summary', 'assists') as summary_assists,
    JSONExtractString(json, 'teams_stats', team_id, 'summary', 'pens_made') as summary_pens_made,
    JSONExtractString(json, 'teams_stats', team_id, 'summary', 'pens_att') as summary_pens_att,
    JSONExtractString(json, 'teams_stats', team_id, 'summary', 'shots') as summary_shots,
    JSONExtractString(json, 'teams_stats', team_id, 'summary', 'shots_on_target') as summary_shots_on_target,
    JSONExtractString(json, 'teams_stats', team_id, 'summary', 'cards_yellow') as summary_cards_yellow,
    JSONExtractString(json, 'teams_stats', team_id, 'summary', 'cards_red') as summary_cards_red,
    JSONExtractString(json, 'teams_stats', team_id, 'summary', 'touches') as summary_touches,
    JSONExtractString(json, 'teams_stats', team_id, 'summary', 'tackles') as summary_tackles,
    JSONExtractString(json, 'teams_stats', team_id, 'summary', 'interceptions') as summary_interceptions,
    JSONExtractString(json, 'teams_stats', team_id, 'summary', 'blocks') as summary_blocks,
    JSONExtractString(json, 'teams_stats', team_id, 'summary', 'xg') as summary_xg,
    JSONExtractString(json, 'teams_stats', team_id, 'summary', 'npxg') as summary_npxg,
    JSONExtractString(json, 'teams_stats', team_id, 'summary', 'xg_assist') as summary_xg_assist,
    JSONExtractString(json, 'teams_stats', team_id, 'summary', 'sca') as summary_sca,
    JSONExtractString(json, 'teams_stats', team_id, 'summary', 'gca') as summary_gca,
    JSONExtractString(json, 'teams_stats', team_id, 'summary', 'passes_completed') as summary_passes_completed,
    JSONExtractString(json, 'teams_stats', team_id, 'summary', 'passes') as summary_passes,
    JSONExtractString(json, 'teams_stats', team_id, 'summary', 'passes_pct') as summary_passes_pct,
    JSONExtractString(json, 'teams_stats', team_id, 'summary', 'progressive_passes') as summary_progressive_passes,
    JSONExtractString(json, 'teams_stats', team_id, 'summary', 'carries') as summary_carries,
    JSONExtractString(json, 'teams_stats', team_id, 'summary', 'progressive_carries') as summary_progressive_carries,
    JSONExtractString(json, 'teams_stats', team_id, 'summary', 'take_ons') as summary_take_ons,
    JSONExtractString(json, 'teams_stats', team_id, 'summary', 'take_ons_won') as summary_take_ons_won,
    
    -- Passing статистика
    JSONExtractString(json, 'teams_stats', team_id, 'passing', 'minutes') as passing_minutes,
    JSONExtractString(json, 'teams_stats', team_id, 'passing', 'passes_completed') as passing_passes_completed,
    JSONExtractString(json, 'teams_stats', team_id, 'passing', 'passes') as passing_passes,
    JSONExtractString(json, 'teams_stats', team_id, 'passing', 'passes_pct') as passing_passes_pct,
    JSONExtractString(json, 'teams_stats', team_id, 'passing', 'passes_total_distance') as passing_passes_total_distance,
    JSONExtractString(json, 'teams_stats', team_id, 'passing', 'passes_progressive_distance') as passing_passes_progressive_distance,
    JSONExtractString(json, 'teams_stats', team_id, 'passing', 'passes_completed_short') as passing_passes_completed_short,
    JSONExtractString(json, 'teams_stats', team_id, 'passing', 'passes_short') as passing_passes_short,
    JSONExtractString(json, 'teams_stats', team_id, 'passing', 'passes_pct_short') as passing_passes_pct_short,
    JSONExtractString(json, 'teams_stats', team_id, 'passing', 'passes_completed_medium') as passing_passes_completed_medium,
    JSONExtractString(json, 'teams_stats', team_id, 'passing', 'passes_medium') as passing_passes_medium,
    JSONExtractString(json, 'teams_stats', team_id, 'passing', 'passes_pct_medium') as passing_passes_pct_medium,
    JSONExtractString(json, 'teams_stats', team_id, 'passing', 'passes_completed_long') as passing_passes_completed_long,
    JSONExtractString(json, 'teams_stats', team_id, 'passing', 'passes_long') as passing_passes_long,
    JSONExtractString(json, 'teams_stats', team_id, 'passing', 'passes_pct_long') as passing_passes_pct_long,
    JSONExtractString(json, 'teams_stats', team_id, 'passing', 'assists') as passing_assists,
    JSONExtractString(json, 'teams_stats', team_id, 'passing', 'xg_assist') as passing_xg_assist,
    JSONExtractString(json, 'teams_stats', team_id, 'passing', 'pass_xa') as passing_pass_xa,
    JSONExtractString(json, 'teams_stats', team_id, 'passing', 'assisted_shots') as passing_assisted_shots,
    JSONExtractString(json, 'teams_stats', team_id, 'passing', 'passes_into_final_third') as passing_passes_into_final_third,
    JSONExtractString(json, 'teams_stats', team_id, 'passing', 'passes_into_penalty_area') as passing_passes_into_penalty_area,
    JSONExtractString(json, 'teams_stats', team_id, 'passing', 'crosses_into_penalty_area') as passing_crosses_into_penalty_area,
    JSONExtractString(json, 'teams_stats', team_id, 'passing', 'progressive_passes') as passing_progressive_passes,
    
    -- Pass Types статистика
    JSONExtractString(json, 'teams_stats', team_id, 'pass_types', 'minutes') as pass_types_minutes,
    JSONExtractString(json, 'teams_stats', team_id, 'pass_types', 'passes') as pass_types_passes,
    JSONExtractString(json, 'teams_stats', team_id, 'pass_types', 'passes_live') as pass_types_passes_live,
    JSONExtractString(json, 'teams_stats', team_id, 'pass_types', 'passes_dead') as pass_types_passes_dead,
    JSONExtractString(json, 'teams_stats', team_id, 'pass_types', 'passes_free_kicks') as pass_types_passes_free_kicks,
    JSONExtractString(json, 'teams_stats', team_id, 'pass_types', 'through_balls') as pass_types_through_balls,
    JSONExtractString(json, 'teams_stats', team_id, 'pass_types', 'passes_switches') as pass_types_passes_switches,
    JSONExtractString(json, 'teams_stats', team_id, 'pass_types', 'crosses') as pass_types_crosses,
    JSONExtractString(json, 'teams_stats', team_id, 'pass_types', 'throw_ins') as pass_types_throw_ins,
    JSONExtractString(json, 'teams_stats', team_id, 'pass_types', 'corner_kicks') as pass_types_corner_kicks,
    JSONExtractString(json, 'teams_stats', team_id, 'pass_types', 'corner_kicks_in') as pass_types_corner_kicks_in,
    JSONExtractString(json, 'teams_stats', team_id, 'pass_types', 'corner_kicks_out') as pass_types_corner_kicks_out,
    JSONExtractString(json, 'teams_stats', team_id, 'pass_types', 'corner_kicks_straight') as pass_types_corner_kicks_straight,
    JSONExtractString(json, 'teams_stats', team_id, 'pass_types', 'passes_completed') as pass_types_passes_completed,
    JSONExtractString(json, 'teams_stats', team_id, 'pass_types', 'passes_offsides') as pass_types_passes_offsides,
    JSONExtractString(json, 'teams_stats', team_id, 'pass_types', 'passes_blocked') as pass_types_passes_blocked,
    
    -- Defensive Actions статистика
    JSONExtractString(json, 'teams_stats', team_id, 'defensive_actions', 'minutes') as defensive_actions_minutes,
    JSONExtractString(json, 'teams_stats', team_id, 'defensive_actions', 'tackles') as defensive_actions_tackles,
    JSONExtractString(json, 'teams_stats', team_id, 'defensive_actions', 'tackles_won') as defensive_actions_tackles_won,
    JSONExtractString(json, 'teams_stats', team_id, 'defensive_actions', 'tackles_def_3rd') as defensive_actions_tackles_def_3rd,
    JSONExtractString(json, 'teams_stats', team_id, 'defensive_actions', 'tackles_mid_3rd') as defensive_actions_tackles_mid_3rd,
    JSONExtractString(json, 'teams_stats', team_id, 'defensive_actions', 'tackles_att_3rd') as defensive_actions_tackles_att_3rd,
    JSONExtractString(json, 'teams_stats', team_id, 'defensive_actions', 'challenge_tackles') as defensive_actions_challenge_tackles,
    JSONExtractString(json, 'teams_stats', team_id, 'defensive_actions', 'challenges') as defensive_actions_challenges,
    JSONExtractString(json, 'teams_stats', team_id, 'defensive_actions', 'challenge_tackles_pct') as defensive_actions_challenge_tackles_pct,
    JSONExtractString(json, 'teams_stats', team_id, 'defensive_actions', 'challenges_lost') as defensive_actions_challenges_lost,
    JSONExtractString(json, 'teams_stats', team_id, 'defensive_actions', 'blocks') as defensive_actions_blocks,
    JSONExtractString(json, 'teams_stats', team_id, 'defensive_actions', 'blocked_shots') as defensive_actions_blocked_shots,
    JSONExtractString(json, 'teams_stats', team_id, 'defensive_actions', 'blocked_passes') as defensive_actions_blocked_passes,
    JSONExtractString(json, 'teams_stats', team_id, 'defensive_actions', 'interceptions') as defensive_actions_interceptions,
    JSONExtractString(json, 'teams_stats', team_id, 'defensive_actions', 'tackles_interceptions') as defensive_actions_tackles_interceptions,
    JSONExtractString(json, 'teams_stats', team_id, 'defensive_actions', 'clearances') as defensive_actions_clearances,
    JSONExtractString(json, 'teams_stats', team_id, 'defensive_actions', 'errors') as defensive_actions_errors,
    
    -- Possession статистика
    JSONExtractString(json, 'teams_stats', team_id, 'possession', 'minutes') as possession_minutes,
    JSONExtractString(json, 'teams_stats', team_id, 'possession', 'touches') as possession_touches,
    JSONExtractString(json, 'teams_stats', team_id, 'possession', 'touches_def_pen_area') as possession_touches_def_pen_area,
    JSONExtractString(json, 'teams_stats', team_id, 'possession', 'touches_def_3rd') as possession_touches_def_3rd,
    JSONExtractString(json, 'teams_stats', team_id, 'possession', 'touches_mid_3rd') as possession_touches_mid_3rd,
    JSONExtractString(json, 'teams_stats', team_id, 'possession', 'touches_att_3rd') as possession_touches_att_3rd,
    JSONExtractString(json, 'teams_stats', team_id, 'possession', 'touches_att_pen_area') as possession_touches_att_pen_area,
    JSONExtractString(json, 'teams_stats', team_id, 'possession', 'touches_live_ball') as possession_touches_live_ball,
    JSONExtractString(json, 'teams_stats', team_id, 'possession', 'take_ons') as possession_take_ons,
    JSONExtractString(json, 'teams_stats', team_id, 'possession', 'take_ons_won') as possession_take_ons_won,
    JSONExtractString(json, 'teams_stats', team_id, 'possession', 'take_ons_won_pct') as possession_take_ons_won_pct,
    JSONExtractString(json, 'teams_stats', team_id, 'possession', 'take_ons_tackled') as possession_take_ons_tackled,
    JSONExtractString(json, 'teams_stats', team_id, 'possession', 'take_ons_tackled_pct') as possession_take_ons_tackled_pct,
    JSONExtractString(json, 'teams_stats', team_id, 'possession', 'carries') as possession_carries,
    JSONExtractString(json, 'teams_stats', team_id, 'possession', 'carries_distance') as possession_carries_distance,
    JSONExtractString(json, 'teams_stats', team_id, 'possession', 'carries_progressive_distance') as possession_carries_progressive_distance,
    JSONExtractString(json, 'teams_stats', team_id, 'possession', 'progressive_carries') as possession_progressive_carries,
    JSONExtractString(json, 'teams_stats', team_id, 'possession', 'carries_into_final_third') as possession_carries_into_final_third,
    JSONExtractString(json, 'teams_stats', team_id, 'possession', 'carries_into_penalty_area') as possession_carries_into_penalty_area,
    JSONExtractString(json, 'teams_stats', team_id, 'possession', 'miscontrols') as possession_miscontrols,
    JSONExtractString(json, 'teams_stats', team_id, 'possession', 'dispossessed') as possession_dispossessed,
    JSONExtractString(json, 'teams_stats', team_id, 'possession', 'passes_received') as possession_passes_received,
    JSONExtractString(json, 'teams_stats', team_id, 'possession', 'progressive_passes_received') as possession_progressive_passes_received,
    
    -- Miscellaneous статистика
    JSONExtractString(json, 'teams_stats', team_id, 'miscellaneous', 'minutes') as miscellaneous_minutes,
    JSONExtractString(json, 'teams_stats', team_id, 'miscellaneous', 'cards_yellow') as miscellaneous_cards_yellow,
    JSONExtractString(json, 'teams_stats', team_id, 'miscellaneous', 'cards_red') as miscellaneous_cards_red,
    JSONExtractString(json, 'teams_stats', team_id, 'miscellaneous', 'cards_yellow_red') as miscellaneous_cards_yellow_red,
    JSONExtractString(json, 'teams_stats', team_id, 'miscellaneous', 'fouls') as miscellaneous_fouls,
    JSONExtractString(json, 'teams_stats', team_id, 'miscellaneous', 'fouled') as miscellaneous_fouled,
    JSONExtractString(json, 'teams_stats', team_id, 'miscellaneous', 'offsides') as miscellaneous_offsides,
    JSONExtractString(json, 'teams_stats', team_id, 'miscellaneous', 'crosses') as miscellaneous_crosses,
    JSONExtractString(json, 'teams_stats', team_id, 'miscellaneous', 'interceptions') as miscellaneous_interceptions,
    JSONExtractString(json, 'teams_stats', team_id, 'miscellaneous', 'tackles_won') as miscellaneous_tackles_won,
    JSONExtractString(json, 'teams_stats', team_id, 'miscellaneous', 'pens_won') as miscellaneous_pens_won,
    JSONExtractString(json, 'teams_stats', team_id, 'miscellaneous', 'pens_conceded') as miscellaneous_pens_conceded,
    JSONExtractString(json, 'teams_stats', team_id, 'miscellaneous', 'own_goals') as miscellaneous_own_goals,
    JSONExtractString(json, 'teams_stats', team_id, 'miscellaneous', 'ball_recoveries') as miscellaneous_ball_recoveries,
    JSONExtractString(json, 'teams_stats', team_id, 'miscellaneous', 'aerials_won') as miscellaneous_aerials_won,
    JSONExtractString(json, 'teams_stats', team_id, 'miscellaneous', 'aerials_lost') as miscellaneous_aerials_lost,
    JSONExtractString(json, 'teams_stats', team_id, 'miscellaneous', 'aerials_won_pct') as miscellaneous_aerials_won_pct,
    
    -- Goalkeeping статистика
    JSONExtractString(json, 'teams_stats', team_id, 'goalkeeping', 'nationality') as goalkeeping_nationality,
    JSONExtractString(json, 'teams_stats', team_id, 'goalkeeping', 'age') as goalkeeping_age,
    JSONExtractString(json, 'teams_stats', team_id, 'goalkeeping', 'minutes') as goalkeeping_minutes,
    JSONExtractString(json, 'teams_stats', team_id, 'goalkeeping', 'gk_shots_on_target_against') as goalkeeping_gk_shots_on_target_against,
    JSONExtractString(json, 'teams_stats', team_id, 'goalkeeping', 'gk_goals_against') as goalkeeping_gk_goals_against,
    JSONExtractString(json, 'teams_stats', team_id, 'goalkeeping', 'gk_saves') as goalkeeping_gk_saves,
    JSONExtractString(json, 'teams_stats', team_id, 'goalkeeping', 'gk_save_pct') as goalkeeping_gk_save_pct,
    JSONExtractString(json, 'teams_stats', team_id, 'goalkeeping', 'gk_psxg') as goalkeeping_gk_psxg,
    JSONExtractString(json, 'teams_stats', team_id, 'goalkeeping', 'gk_passes_launched') as goalkeeping_gk_passes_launched,
    JSONExtractString(json, 'teams_stats', team_id, 'goalkeeping', 'gk_passes') as goalkeeping_gk_passes,
    JSONExtractString(json, 'teams_stats', team_id, 'goalkeeping', 'gk_passes_throws') as goalkeeping_gk_passes_throws,
    JSONExtractString(json, 'teams_stats', team_id, 'goalkeeping', 'gk_pct_passes_launched') as goalkeeping_gk_pct_passes_launched,
    JSONExtractString(json, 'teams_stats', team_id, 'goalkeeping', 'gk_passes_length_avg') as goalkeeping_gk_passes_length_avg,
    JSONExtractString(json, 'teams_stats', team_id, 'goalkeeping', 'gk_goal_kicks') as goalkeeping_gk_goal_kicks,
    JSONExtractString(json, 'teams_stats', team_id, 'goalkeeping', 'gk_pct_goal_kicks_launched') as goalkeeping_gk_pct_goal_kicks_launched,
    JSONExtractString(json, 'teams_stats', team_id, 'goalkeeping', 'gk_goal_kick_length_avg') as goalkeeping_gk_goal_kick_length_avg,
    JSONExtractString(json, 'teams_stats', team_id, 'goalkeeping', 'gk_crosses') as goalkeeping_gk_crosses,
    JSONExtractString(json, 'teams_stats', team_id, 'goalkeeping', 'gk_crosses_stopped') as goalkeeping_gk_crosses_stopped,
    JSONExtractString(json, 'teams_stats', team_id, 'goalkeeping', 'gk_crosses_stopped_pct') as goalkeeping_gk_crosses_stopped_pct,
    JSONExtractString(json, 'teams_stats', team_id, 'goalkeeping', 'gk_def_actions_outside_pen_area') as goalkeeping_gk_def_actions_outside_pen_area,
    JSONExtractString(json, 'teams_stats', team_id, 'goalkeeping', 'gk_avg_distance_def_actions') as goalkeeping_gk_avg_distance_def_actions,
    JSONExtractString(json, 'teams_stats', team_id, 'goalkeeping', 'gk_passes_completed_launched') as goalkeeping_gk_passes_completed_launched,
    JSONExtractString(json, 'teams_stats', team_id, 'goalkeeping', 'gk_passes_pct_launched') as goalkeeping_gk_passes_pct_launched
FROM (
    SELECT 
        json,
        JSONExtractKeys(json, 'teams_stats')[1] AS team_id,
        1 as is_home
    FROM s3(
        'https://storage.yandexcloud.net/fbref-json/*.json',
        '{ACCESS_KEY_ID}', 
        '{ACCESS_KEY_SECRET}',
        'JSONAsString'
    )
    WHERE JSONExtractString(json, 'match_date') != '' 
      AND JSONExtractString(json, 'match_date') IS NOT NULL
      AND isNotNull(JSONExtractString(json, 'match_date'))
    
    UNION ALL
    
    SELECT 
        json,
        JSONExtractKeys(json, 'teams_stats')[2] AS team_id,
        0 as is_home
    FROM s3(
        'https://storage.yandexcloud.net/fbref-json/*.json',
        '{ACCESS_KEY_ID}', 
        '{ACCESS_KEY_SECRET}',
        'JSONAsString'
    )
    WHERE JSONExtractString(json, 'match_date') != '' 
      AND JSONExtractString(json, 'match_date') IS NOT NULL
      AND isNotNull(JSONExtractString(json, 'match_date'))
);