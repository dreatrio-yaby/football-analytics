-- Простое и эффективное создание обучающей выборки для футбольной аналитики
-- Использует window функции ClickHouse для максимальной производительности
-- Один запрос вместо сложной системы CTE и JOIN

-- Создаем схему ml если не существует
CREATE DATABASE IF NOT EXISTS ml;

-- Удаляем старую таблицу если существует
DROP TABLE IF EXISTS ml.training_dataset;

-- Создаем и заполняем таблицу одним запросом
CREATE TABLE ml.training_dataset 
ENGINE = MergeTree()
ORDER BY (match_date, match_id)
PARTITION BY toYYYYMM(match_date)
AS

WITH 
-- 1. Базовые данные матчей
match_data AS (
    SELECT 
        match_id,
        match_date,
        team_id,
        is_home,
        -- Основные метрики
        toFloat32OrZero(summary_goals) as goals,
        toFloat32OrZero(summary_shots) as shots,
        toFloat32OrZero(summary_shots_on_target) as shots_on_target,
        toFloat32OrZero(summary_xg) as xg,
        toFloat32OrZero(summary_passes_completed) as passes_completed,
        toFloat32OrZero(summary_passes) as passes,
        toFloat32OrZero(summary_progressive_passes) as progressive_passes,
        toFloat32OrZero(summary_tackles) as tackles,
        toFloat32OrZero(summary_interceptions) as interceptions,
        toFloat32OrZero(miscellaneous_fouls) as fouls,
        toFloat32OrZero(summary_cards_yellow) as cards_yellow,
        toFloat32OrZero(summary_cards_red) as cards_red,
        toFloat32OrZero(pass_types_corner_kicks) as corners,
        toFloat32OrZero(miscellaneous_crosses) as crosses,
        toFloat32OrZero(possession_take_ons_won) as take_ons_won,
        toFloat32OrZero(possession_take_ons) as take_ons,
        toFloat32OrZero(miscellaneous_aerials_won) as aerials_won,
        toFloat32OrZero(miscellaneous_aerials_lost) as aerials_lost
    FROM raw.match_stats
),

-- 2. Добавляем признаки через window функции (сила ClickHouse!)
team_features AS (
    SELECT *,
        -- Процентные показатели
        CASE WHEN shots > 0 THEN shots_on_target / shots * 100 ELSE 0 END as shots_on_target_pct,
        CASE WHEN passes > 0 THEN passes_completed / passes * 100 ELSE 0 END as passes_pct,
        CASE WHEN take_ons > 0 THEN take_ons_won / take_ons * 100 ELSE 0 END as take_ons_won_pct,
        CASE WHEN (aerials_won + aerials_lost) > 0 THEN aerials_won / (aerials_won + aerials_lost) * 100 ELSE 0 END as aerials_won_pct,
        
        -- Результат матча будет вычислен позже в final_dataset
        0 as match_result,
        
        -- Признаки за 3 матча (window функции исключают текущий матч)
        AVG(goals) OVER (
            PARTITION BY team_id ORDER BY match_date 
            ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
        ) as goals_avg_3,
        
        AVG(xg) OVER (
            PARTITION BY team_id ORDER BY match_date 
            ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
        ) as xg_avg_3,
        
        AVG(shots) OVER (
            PARTITION BY team_id ORDER BY match_date 
            ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
        ) as shots_avg_3,
        
        AVG(shots_on_target_pct) OVER (
            PARTITION BY team_id ORDER BY match_date 
            ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
        ) as shots_on_target_pct_3,
        
        AVG(passes_pct) OVER (
            PARTITION BY team_id ORDER BY match_date 
            ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
        ) as passes_pct_3,
        
        AVG(corners) OVER (
            PARTITION BY team_id ORDER BY match_date 
            ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
        ) as corners_avg_3,
        
        AVG(fouls) OVER (
            PARTITION BY team_id ORDER BY match_date 
            ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
        ) as fouls_avg_3,
        
        AVG(cards_yellow + cards_red) OVER (
            PARTITION BY team_id ORDER BY match_date 
            ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
        ) as cards_avg_3,
        
        -- Форма команды вычислим позже
        0 as form_3,
        
        -- Признаки за 7 матчей
        AVG(goals) OVER (
            PARTITION BY team_id ORDER BY match_date 
            ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
        ) as goals_avg_7,
        
        AVG(xg) OVER (
            PARTITION BY team_id ORDER BY match_date 
            ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
        ) as xg_avg_7,
        
        AVG(shots) OVER (
            PARTITION BY team_id ORDER BY match_date 
            ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
        ) as shots_avg_7,
        
        AVG(shots_on_target_pct) OVER (
            PARTITION BY team_id ORDER BY match_date 
            ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
        ) as shots_on_target_pct_7,
        
        AVG(passes_pct) OVER (
            PARTITION BY team_id ORDER BY match_date 
            ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
        ) as passes_pct_7,
        
        AVG(corners) OVER (
            PARTITION BY team_id ORDER BY match_date 
            ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
        ) as corners_avg_7,
        
        AVG(fouls) OVER (
            PARTITION BY team_id ORDER BY match_date 
            ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
        ) as fouls_avg_7,
        
        AVG(cards_yellow + cards_red) OVER (
            PARTITION BY team_id ORDER BY match_date 
            ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
        ) as cards_avg_7,
        
        -- Форма команды вычислим позже
        0 as form_7,
        
        -- Стабильность (стандартное отклонение)
        stddevPop(goals) OVER (
            PARTITION BY team_id ORDER BY match_date 
            ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
        ) as goals_std_7
        
    FROM match_data
),

-- 3. Финальный датасет: объединяем домашние и гостевые команды
final_dataset AS (
    SELECT 
        h.match_id,
        h.match_date,
        h.team_id as home_team_id,
        a.team_id as away_team_id,
        
        -- ТАРГЕТЫ (вычисляем прямо здесь)
        CASE 
            WHEN h.goals > a.goals THEN 2  -- победа домашней команды
            WHEN h.goals = a.goals THEN 1  -- ничья
            ELSE 0                         -- поражение домашней команды
        END as target_match_result,
        
        -- Тоталы голов
        CASE WHEN (h.goals + a.goals) > 0.5 THEN 1 ELSE 0 END as target_total_goals_over_0_5,
        CASE WHEN (h.goals + a.goals) > 1.5 THEN 1 ELSE 0 END as target_total_goals_over_1_5,
        CASE WHEN (h.goals + a.goals) > 2.5 THEN 1 ELSE 0 END as target_total_goals_over_2_5,
        CASE WHEN (h.goals + a.goals) > 3.5 THEN 1 ELSE 0 END as target_total_goals_over_3_5,
        
        -- Индивидуальные тоталы
        CASE WHEN h.goals > 0.5 THEN 1 ELSE 0 END as target_home_goals_over_0_5,
        CASE WHEN h.goals > 1.5 THEN 1 ELSE 0 END as target_home_goals_over_1_5,
        CASE WHEN a.goals > 0.5 THEN 1 ELSE 0 END as target_away_goals_over_0_5,
        CASE WHEN a.goals > 1.5 THEN 1 ELSE 0 END as target_away_goals_over_1_5,
        
        -- Угловые и карточки
        CASE WHEN (h.corners + a.corners) > 9.5 THEN 1 ELSE 0 END as target_corners_over_9_5,
        CASE WHEN (h.cards_yellow + h.cards_red + a.cards_yellow + a.cards_red) > 3.5 THEN 1 ELSE 0 END as target_cards_over_3_5,
        CASE WHEN (h.fouls + a.fouls) > 20.5 THEN 1 ELSE 0 END as target_fouls_over_20_5,
        
        -- ПРИЗНАКИ ДОМАШНЕЙ КОМАНДЫ
        h.goals_avg_3 as home_goals_avg_3,
        h.goals_avg_7 as home_goals_avg_7,
        h.xg_avg_3 as home_xg_avg_3,
        h.xg_avg_7 as home_xg_avg_7,
        h.shots_avg_3 as home_shots_avg_3,
        h.shots_avg_7 as home_shots_avg_7,
        h.shots_on_target_pct_3 as home_shots_on_target_pct_3,
        h.shots_on_target_pct_7 as home_shots_on_target_pct_7,
        h.passes_pct_3 as home_passes_pct_3,
        h.passes_pct_7 as home_passes_pct_7,
        h.corners_avg_3 as home_corners_avg_3,
        h.corners_avg_7 as home_corners_avg_7,
        h.fouls_avg_3 as home_fouls_avg_3,
        h.fouls_avg_7 as home_fouls_avg_7,
        h.cards_avg_3 as home_cards_avg_3,
        h.cards_avg_7 as home_cards_avg_7,
        -- Форма команд пока не используется
        0 as home_form_3,
        0 as home_form_7,
        h.goals_std_7 as home_goals_std_7,
        
        -- ПРИЗНАКИ ГОСТЕВОЙ КОМАНДЫ
        a.goals_avg_3 as away_goals_avg_3,
        a.goals_avg_7 as away_goals_avg_7,
        a.xg_avg_3 as away_xg_avg_3,
        a.xg_avg_7 as away_xg_avg_7,
        a.shots_avg_3 as away_shots_avg_3,
        a.shots_avg_7 as away_shots_avg_7,
        a.shots_on_target_pct_3 as away_shots_on_target_pct_3,
        a.shots_on_target_pct_7 as away_shots_on_target_pct_7,
        a.passes_pct_3 as away_passes_pct_3,
        a.passes_pct_7 as away_passes_pct_7,
        a.corners_avg_3 as away_corners_avg_3,
        a.corners_avg_7 as away_corners_avg_7,
        a.fouls_avg_3 as away_fouls_avg_3,
        a.fouls_avg_7 as away_fouls_avg_7,
        a.cards_avg_3 as away_cards_avg_3,
        a.cards_avg_7 as away_cards_avg_7,
        -- Форма команд пока не используется  
        0 as away_form_3,
        0 as away_form_7,
        a.goals_std_7 as away_goals_std_7,
        
        -- СРАВНИТЕЛЬНЫЕ ПРИЗНАКИ (разности и отношения)
        h.goals_avg_7 - a.goals_avg_7 as diff_goals_avg_7,
        h.xg_avg_7 - a.xg_avg_7 as diff_xg_avg_7,
        -- Разность форм пока не используется
        0 as diff_form_7,
        
        CASE WHEN a.goals_avg_7 > 0 THEN h.goals_avg_7 / a.goals_avg_7 ELSE 0 END as ratio_goals_avg_7,
        CASE WHEN a.xg_avg_7 > 0 THEN h.xg_avg_7 / a.xg_avg_7 ELSE 0 END as ratio_xg_avg_7,
        
        -- ПРОИЗВОДНЫЕ ПРИЗНАКИ
        CASE WHEN h.shots_avg_7 > 0 THEN h.goals_avg_7 / h.shots_avg_7 ELSE 0 END as home_attack_efficiency_7,
        CASE WHEN a.shots_avg_7 > 0 THEN a.goals_avg_7 / a.shots_avg_7 ELSE 0 END as away_attack_efficiency_7
        
    FROM team_features h
    INNER JOIN team_features a ON h.match_id = a.match_id
    WHERE h.is_home = 1 AND a.is_home = 0  -- Простой JOIN по домашней/гостевой команде
)

SELECT * 
FROM final_dataset
WHERE 
    home_goals_avg_7 IS NOT NULL  -- Только матчи с достаточной историей
    AND away_goals_avg_7 IS NOT NULL
ORDER BY match_date, match_id;