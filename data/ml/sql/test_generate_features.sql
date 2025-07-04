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
        m1.match_id,
        m1.match_date,
        m1.team_id,
        m1.is_home,
        m1.goals_scored,
        m1.shots,
        m1.xg,
        m2.goals_scored as goals_conceded,
        m2.xg as xg_conceded
    FROM match_results m1
    INNER JOIN match_results m2 ON (
        m1.match_id = m2.match_id 
        AND m1.team_id != m2.team_id
    )
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