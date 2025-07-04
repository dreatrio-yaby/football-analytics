-- Скрипт для валидации качества обучающей выборки
-- Проверяет корректность данных, пропуски, выбросы

-- 1. Базовая статистика по датасету
SELECT 
    'BASIC_STATS' as check_type,
    COUNT(*) as total_records,
    COUNT(DISTINCT match_id) as unique_matches,
    COUNT(DISTINCT home_team_id) as unique_home_teams,
    COUNT(DISTINCT away_team_id) as unique_away_teams,
    MIN(match_date) as earliest_date,
    MAX(match_date) as latest_date,
    dateDiff('day', MIN(match_date), MAX(match_date)) as date_range_days
FROM ml.training_dataset

UNION ALL

-- 2. Проверка пропусков в ключевых полях
SELECT 
    'NULL_CHECK' as check_type,
    SUM(CASE WHEN match_id IS NULL THEN 1 ELSE 0 END) as null_match_id,
    SUM(CASE WHEN home_team_id IS NULL THEN 1 ELSE 0 END) as null_home_team,
    SUM(CASE WHEN away_team_id IS NULL THEN 1 ELSE 0 END) as null_away_team,
    SUM(CASE WHEN target_match_result IS NULL THEN 1 ELSE 0 END) as null_match_result,
    SUM(CASE WHEN home_team_goals_avg_7 IS NULL THEN 1 ELSE 0 END) as null_home_goals_7,
    SUM(CASE WHEN away_team_goals_avg_7 IS NULL THEN 1 ELSE 0 END) as null_away_goals_7,
    0 as date_range_days  -- placeholder для совместимости
FROM ml.training_dataset

UNION ALL

-- 3. Проверка диапазонов таргетов (должны быть 0 или 1 для бинарных)
SELECT 
    'TARGET_RANGE_CHECK' as check_type,
    SUM(CASE WHEN target_match_result NOT IN (0, 1, 2) THEN 1 ELSE 0 END) as invalid_match_result,
    SUM(CASE WHEN target_total_goals_over_2_5 NOT IN (0, 1) THEN 1 ELSE 0 END) as invalid_total_goals,
    SUM(CASE WHEN target_home_goals_over_1_5 NOT IN (0, 1) THEN 1 ELSE 0 END) as invalid_home_goals,
    SUM(CASE WHEN target_corners_over_10_5 NOT IN (0, 1) THEN 1 ELSE 0 END) as invalid_corners,
    0 as null_away_goals_7,  -- placeholder
    0 as null_away_goals_7_2,  -- placeholder
    0 as date_range_days  -- placeholder
FROM ml.training_dataset

UNION ALL

-- 4. Проверка выбросов в признаках (негативные значения там, где их не должно быть)
SELECT 
    'FEATURE_OUTLIERS' as check_type,
    SUM(CASE WHEN home_team_goals_avg_7 < 0 THEN 1 ELSE 0 END) as negative_home_goals,
    SUM(CASE WHEN away_team_goals_avg_7 < 0 THEN 1 ELSE 0 END) as negative_away_goals,
    SUM(CASE WHEN home_team_xg_avg_7 < 0 THEN 1 ELSE 0 END) as negative_home_xg,
    SUM(CASE WHEN away_team_xg_avg_7 < 0 THEN 1 ELSE 0 END) as negative_away_xg,
    SUM(CASE WHEN home_team_shots_avg_7 < 0 THEN 1 ELSE 0 END) as negative_home_shots,
    SUM(CASE WHEN away_team_shots_avg_7 < 0 THEN 1 ELSE 0 END) as negative_away_shots,
    0 as date_range_days  -- placeholder
FROM ml.training_dataset

UNION ALL

-- 5. Проверка экстремальных значений
SELECT 
    'EXTREME_VALUES' as check_type,
    SUM(CASE WHEN home_team_goals_avg_7 > 10 THEN 1 ELSE 0 END) as extreme_home_goals,
    SUM(CASE WHEN away_team_goals_avg_7 > 10 THEN 1 ELSE 0 END) as extreme_away_goals,
    SUM(CASE WHEN home_team_shots_avg_7 > 50 THEN 1 ELSE 0 END) as extreme_home_shots,
    SUM(CASE WHEN away_team_shots_avg_7 > 50 THEN 1 ELSE 0 END) as extreme_away_shots,
    SUM(CASE WHEN home_team_passes_pct_7 > 100 OR home_team_passes_pct_7 < 0 THEN 1 ELSE 0 END) as invalid_home_pass_pct,
    SUM(CASE WHEN away_team_passes_pct_7 > 100 OR away_team_passes_pct_7 < 0 THEN 1 ELSE 0 END) as invalid_away_pass_pct,
    0 as date_range_days  -- placeholder
FROM ml.training_dataset

ORDER BY check_type;