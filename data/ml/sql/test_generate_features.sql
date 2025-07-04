-- Тестовый запрос для проверки синтаксиса generate_team_features.sql
-- Проверяем только первые несколько строк без создания view

WITH match_results AS (
    SELECT 
        match_id,
        match_date,
        team_id,
        is_home,
        toFloat32OrZero(summary_goals) as goals_scored,
        toFloat32OrZero(summary_shots) as shots,
        toFloat32OrZero(summary_xg) as xg
    FROM raw.match_stats
    LIMIT 100
),

match_results_with_conceded AS (
    SELECT 
        *,
        (SELECT goals_scored 
         FROM match_results m2 
         WHERE m2.match_id = m1.match_id AND m2.team_id != m1.team_id
         LIMIT 1
        ) as goals_conceded,
        (SELECT xg 
         FROM match_results m2 
         WHERE m2.match_id = m1.match_id AND m2.team_id != m1.team_id
         LIMIT 1
        ) as xg_conceded
    FROM match_results m1
)

SELECT 
    match_id,
    team_id,
    goals_scored,
    goals_conceded,
    xg,
    xg_conceded
FROM match_results_with_conceded
LIMIT 10;