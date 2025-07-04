-- Генерация всех таргетов из данных матча
-- Таргеты вычисляются на основе результатов текущего матча

WITH match_targets AS (
    SELECT 
        match_id,
        match_date,
        
        -- Получаем данные домашней команды
        h.team_id as home_team_id,
        toFloat32OrZero(h.summary_goals) as home_goals,
        toFloat32OrZero(h.pass_types_corner_kicks) as home_corners,
        toFloat32OrZero(h.summary_cards_yellow) + toFloat32OrZero(h.summary_cards_red) as home_cards,
        toFloat32OrZero(h.miscellaneous_fouls) as home_fouls,
        
        -- Получаем данные гостевой команды
        a.team_id as away_team_id,
        toFloat32OrZero(a.summary_goals) as away_goals,
        toFloat32OrZero(a.pass_types_corner_kicks) as away_corners,
        toFloat32OrZero(a.summary_cards_yellow) + toFloat32OrZero(a.summary_cards_red) as away_cards,
        toFloat32OrZero(a.miscellaneous_fouls) as away_fouls
        
    FROM raw.match_stats h
    INNER JOIN raw.match_stats a ON h.match_id = a.match_id
    WHERE h.is_home = 1 AND a.is_home = 0
),

calculated_targets AS (
    SELECT 
        match_id,
        match_date,
        home_team_id,
        away_team_id,
        home_goals,
        away_goals,
        home_corners,
        away_corners,
        home_cards,
        away_cards,
        home_fouls,
        away_fouls,
        
        -- Вычисляемые агрегированные показатели
        home_goals + away_goals as total_goals,
        home_corners + away_corners as total_corners,
        home_cards + away_cards as total_cards,
        home_fouls + away_fouls as total_fouls,
        
        -- ТАРГЕТ: Результат матча (относительно домашней команды)
        CASE 
            WHEN home_goals > away_goals THEN 2 -- победа домашней команды
            WHEN home_goals = away_goals THEN 1 -- ничья
            ELSE 0 -- поражение домашней команды
        END as target_match_result,
        
        -- ТАРГЕТЫ: Тоталы голов (over/under)
        CASE WHEN (home_goals + away_goals) > 0.5 THEN 1 ELSE 0 END as target_total_goals_over_0_5,
        CASE WHEN (home_goals + away_goals) > 1.5 THEN 1 ELSE 0 END as target_total_goals_over_1_5,
        CASE WHEN (home_goals + away_goals) > 2.5 THEN 1 ELSE 0 END as target_total_goals_over_2_5,
        CASE WHEN (home_goals + away_goals) > 3.5 THEN 1 ELSE 0 END as target_total_goals_over_3_5,
        CASE WHEN (home_goals + away_goals) > 4.5 THEN 1 ELSE 0 END as target_total_goals_over_4_5,
        CASE WHEN (home_goals + away_goals) > 5.5 THEN 1 ELSE 0 END as target_total_goals_over_5_5,
        
        -- ТАРГЕТЫ: Индивидуальные тоталы домашней команды
        CASE WHEN home_goals > 0.5 THEN 1 ELSE 0 END as target_home_goals_over_0_5,
        CASE WHEN home_goals > 1.5 THEN 1 ELSE 0 END as target_home_goals_over_1_5,
        CASE WHEN home_goals > 2.5 THEN 1 ELSE 0 END as target_home_goals_over_2_5,
        CASE WHEN home_goals > 3.5 THEN 1 ELSE 0 END as target_home_goals_over_3_5,
        
        -- ТАРГЕТЫ: Индивидуальные тоталы гостевой команды
        CASE WHEN away_goals > 0.5 THEN 1 ELSE 0 END as target_away_goals_over_0_5,
        CASE WHEN away_goals > 1.5 THEN 1 ELSE 0 END as target_away_goals_over_1_5,
        CASE WHEN away_goals > 2.5 THEN 1 ELSE 0 END as target_away_goals_over_2_5,
        CASE WHEN away_goals > 3.5 THEN 1 ELSE 0 END as target_away_goals_over_3_5,
        
        -- ТАРГЕТЫ: Угловые (общие)
        CASE WHEN (home_corners + away_corners) > 8.5 THEN 1 ELSE 0 END as target_corners_over_8_5,
        CASE WHEN (home_corners + away_corners) > 9.5 THEN 1 ELSE 0 END as target_corners_over_9_5,
        CASE WHEN (home_corners + away_corners) > 10.5 THEN 1 ELSE 0 END as target_corners_over_10_5,
        CASE WHEN (home_corners + away_corners) > 11.5 THEN 1 ELSE 0 END as target_corners_over_11_5,
        CASE WHEN (home_corners + away_corners) > 12.5 THEN 1 ELSE 0 END as target_corners_over_12_5,
        
        -- ТАРГЕТЫ: Карточки (общие)
        CASE WHEN (home_cards + away_cards) > 2.5 THEN 1 ELSE 0 END as target_cards_over_2_5,
        CASE WHEN (home_cards + away_cards) > 3.5 THEN 1 ELSE 0 END as target_cards_over_3_5,
        CASE WHEN (home_cards + away_cards) > 4.5 THEN 1 ELSE 0 END as target_cards_over_4_5,
        CASE WHEN (home_cards + away_cards) > 5.5 THEN 1 ELSE 0 END as target_cards_over_5_5,
        
        -- ТАРГЕТЫ: Фолы (общие)
        CASE WHEN (home_fouls + away_fouls) > 18.5 THEN 1 ELSE 0 END as target_fouls_over_18_5,
        CASE WHEN (home_fouls + away_fouls) > 20.5 THEN 1 ELSE 0 END as target_fouls_over_20_5,
        CASE WHEN (home_fouls + away_fouls) > 22.5 THEN 1 ELSE 0 END as target_fouls_over_22_5,
        CASE WHEN (home_fouls + away_fouls) > 24.5 THEN 1 ELSE 0 END as target_fouls_over_24_5
        
    FROM match_targets
)

SELECT 
    match_id,
    match_date,
    home_team_id,
    away_team_id,
    
    -- Сырые данные для проверки
    home_goals,
    away_goals,
    total_goals,
    home_corners,
    away_corners,
    total_corners,
    home_cards,
    away_cards,
    total_cards,
    home_fouls,
    away_fouls,
    total_fouls,
    
    -- Все таргеты
    target_match_result,
    target_total_goals_over_0_5,
    target_total_goals_over_1_5,
    target_total_goals_over_2_5,
    target_total_goals_over_3_5,
    target_total_goals_over_4_5,
    target_total_goals_over_5_5,
    target_home_goals_over_0_5,
    target_home_goals_over_1_5,
    target_home_goals_over_2_5,
    target_home_goals_over_3_5,
    target_away_goals_over_0_5,
    target_away_goals_over_1_5,
    target_away_goals_over_2_5,
    target_away_goals_over_3_5,
    target_corners_over_8_5,
    target_corners_over_9_5,
    target_corners_over_10_5,
    target_corners_over_11_5,
    target_corners_over_12_5,
    target_cards_over_2_5,
    target_cards_over_3_5,
    target_cards_over_4_5,
    target_cards_over_5_5,
    target_fouls_over_18_5,
    target_fouls_over_20_5,
    target_fouls_over_22_5,
    target_fouls_over_24_5
    
FROM calculated_targets
ORDER BY match_date, match_id;