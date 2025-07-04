-- Тестовый запрос для проверки извлечения данных из одного файла
-- Используется для проверки корректности работы с JSON структурой

SELECT
    JSONExtractString(json, 'match_id') as match_id,
    JSONExtractString(json, 'match_date') as match_date,
    team_id,
    JSONExtractString(json, 'teams_stats', team_id, 'summary', 'goals') as goals,
    JSONExtractString(json, 'teams_stats', team_id, 'summary', 'assists') as assists,
    JSONExtractString(json, 'teams_stats', team_id, 'summary', 'shots') as shots,
    JSONExtractString(json, 'teams_stats', team_id, 'passing', 'passes_completed') as passes_completed,
    JSONExtractString(json, 'teams_stats', team_id, 'goalkeeping', 'nationality') as gk_nationality
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