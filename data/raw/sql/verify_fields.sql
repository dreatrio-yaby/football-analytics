-- Запрос для проверки извлечения всех полей из всех разделов
-- Показывает примеры из каждого раздела статистики

SELECT 
    -- Основные поля
    JSONExtractString(json, 'match_id') as match_id,
    JSONExtractString(json, 'match_date') as match_date,
    team_id,
    
    -- Примеры из Summary
    JSONExtractString(json, 'teams_stats', team_id, 'summary', 'goals') as summary_goals,
    JSONExtractString(json, 'teams_stats', team_id, 'summary', 'assists') as summary_assists,
    JSONExtractString(json, 'teams_stats', team_id, 'summary', 'xg') as summary_xg,
    
    -- Примеры из Passing
    JSONExtractString(json, 'teams_stats', team_id, 'passing', 'passes_completed') as passing_passes_completed,
    JSONExtractString(json, 'teams_stats', team_id, 'passing', 'passes_pct') as passing_passes_pct,
    JSONExtractString(json, 'teams_stats', team_id, 'passing', 'passes_total_distance') as passing_passes_total_distance,
    
    -- Примеры из Pass Types
    JSONExtractString(json, 'teams_stats', team_id, 'pass_types', 'passes_live') as pass_types_passes_live,
    JSONExtractString(json, 'teams_stats', team_id, 'pass_types', 'through_balls') as pass_types_through_balls,
    JSONExtractString(json, 'teams_stats', team_id, 'pass_types', 'corner_kicks') as pass_types_corner_kicks,
    
    -- Примеры из Defensive Actions
    JSONExtractString(json, 'teams_stats', team_id, 'defensive_actions', 'tackles') as defensive_actions_tackles,
    JSONExtractString(json, 'teams_stats', team_id, 'defensive_actions', 'interceptions') as defensive_actions_interceptions,
    JSONExtractString(json, 'teams_stats', team_id, 'defensive_actions', 'clearances') as defensive_actions_clearances,
    
    -- Примеры из Possession
    JSONExtractString(json, 'teams_stats', team_id, 'possession', 'touches') as possession_touches,
    JSONExtractString(json, 'teams_stats', team_id, 'possession', 'carries') as possession_carries,
    JSONExtractString(json, 'teams_stats', team_id, 'possession', 'take_ons_won') as possession_take_ons_won,
    
    -- Примеры из Miscellaneous
    JSONExtractString(json, 'teams_stats', team_id, 'miscellaneous', 'cards_yellow') as miscellaneous_cards_yellow,
    JSONExtractString(json, 'teams_stats', team_id, 'miscellaneous', 'fouls') as miscellaneous_fouls,
    JSONExtractString(json, 'teams_stats', team_id, 'miscellaneous', 'aerials_won') as miscellaneous_aerials_won,
    
    -- Примеры из Goalkeeping
    JSONExtractString(json, 'teams_stats', team_id, 'goalkeeping', 'nationality') as goalkeeping_nationality,
    JSONExtractString(json, 'teams_stats', team_id, 'goalkeeping', 'gk_saves') as goalkeeping_gk_saves,
    JSONExtractString(json, 'teams_stats', team_id, 'goalkeeping', 'gk_crosses_stopped') as goalkeeping_gk_crosses_stopped
FROM (
    SELECT 
        json,
        arrayJoin(JSONExtractKeysAndValues(json, 'teams_stats')).1 AS team_id
    FROM s3(
        'https://storage.yandexcloud.net/fbref-json/match.json',
        '{ACCESS_KEY_ID}', 
        '{ACCESS_KEY_SECRET}',
        'JSONAsString'
    )
);