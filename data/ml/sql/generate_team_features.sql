-- Генерация признаков команд с агрегацией по окнам 3, 7, 11 матчей
-- Исключаем текущий матч из расчета признаков

WITH match_results AS (
    -- Сначала определяем результаты матчей для каждой команды
    SELECT 
        match_id,
        match_date,
        team_id,
        is_home,
        -- Голы забитые
        toFloat32OrZero(summary_goals) as goals_scored,
        -- Голы пропущенные (нужно получить из противника)
        0 as goals_conceded, -- будет заполнено позже
        -- Остальные основные метрики
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

-- Добавляем пропущенные голы для каждой команды
match_results_with_conceded AS (
    SELECT 
        m1.match_id,
        m1.match_date,
        m1.team_id,
        m1.is_home,
        m1.goals_scored,
        m1.shots,
        m1.shots_on_target,
        m1.xg,
        m1.passes_completed,
        m1.passes,
        m1.progressive_passes,
        m1.tackles,
        m1.interceptions,
        m1.fouls,
        m1.cards_yellow,
        m1.cards_red,
        m1.corners,
        m1.crosses,
        m1.take_ons_won,
        m1.take_ons,
        m1.aerials_won,
        m1.aerials_lost,
        m2.goals_scored as goals_conceded,
        m2.xg as xg_conceded
    FROM match_results m1
    INNER JOIN match_results m2 ON (
        m1.match_id = m2.match_id 
        AND m1.team_id != m2.team_id
    )
),

-- Добавляем результат матча для каждой команды
match_results_with_outcome AS (
    SELECT 
        *,
        CASE 
            WHEN goals_scored > goals_conceded THEN 2 -- победа
            WHEN goals_scored = goals_conceded THEN 1 -- ничья
            ELSE 0 -- поражение
        END as match_result,
        -- Процентные показатели
        CASE WHEN shots > 0 THEN shots_on_target / shots * 100 ELSE 0 END as shots_on_target_pct,
        CASE WHEN passes > 0 THEN passes_completed / passes * 100 ELSE 0 END as passes_pct,
        CASE WHEN take_ons > 0 THEN take_ons_won / take_ons * 100 ELSE 0 END as take_ons_won_pct,
        CASE WHEN (aerials_won + aerials_lost) > 0 THEN aerials_won / (aerials_won + aerials_lost) * 100 ELSE 0 END as aerials_won_pct,
        -- Владение мячом (примерная формула на основе пасов)
        CASE WHEN passes > 0 THEN passes / (passes + 100) * 100 ELSE 0 END as possession_pct
    FROM match_results_with_conceded
),

-- Создаем агрегированные признаки для каждого окна
team_features AS (
    SELECT 
        match_id,
        match_date,
        team_id,
        is_home,
        
        -- Окно 3 матча
        AVG(goals_scored) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
        ) as goals_avg_3,
        
        SUM(goals_scored) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
        ) as goals_sum_3,
        
        AVG(goals_conceded) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
        ) as goals_conceded_avg_3,
        
        SUM(goals_conceded) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
        ) as goals_conceded_sum_3,
        
        AVG(shots) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
        ) as shots_avg_3,
        
        AVG(shots_on_target) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
        ) as shots_on_target_avg_3,
        
        AVG(shots_on_target_pct) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
        ) as shots_on_target_pct_3,
        
        AVG(xg) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
        ) as xg_avg_3,
        
        SUM(xg) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
        ) as xg_sum_3,
        
        AVG(passes_completed) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
        ) as passes_completed_avg_3,
        
        AVG(passes_pct) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
        ) as passes_pct_3,
        
        AVG(progressive_passes) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
        ) as progressive_passes_avg_3,
        
        AVG(possession_pct) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
        ) as possession_avg_3,
        
        AVG(tackles) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
        ) as tackles_avg_3,
        
        AVG(interceptions) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
        ) as interceptions_avg_3,
        
        AVG(fouls) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
        ) as fouls_avg_3,
        
        AVG(cards_yellow) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
        ) as cards_yellow_avg_3,
        
        AVG(cards_red) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
        ) as cards_red_avg_3,
        
        AVG(corners) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
        ) as corners_avg_3,
        
        AVG(crosses) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
        ) as crosses_avg_3,
        
        AVG(take_ons_won_pct) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
        ) as take_ons_won_pct_3,
        
        AVG(aerials_won_pct) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
        ) as aerials_won_pct_3,
        
        AVG(match_result) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
        ) as form_3,
        
        -- Окно 7 матчей
        AVG(goals_scored) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
        ) as goals_avg_7,
        
        SUM(goals_scored) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
        ) as goals_sum_7,
        
        AVG(goals_conceded) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
        ) as goals_conceded_avg_7,
        
        SUM(goals_conceded) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
        ) as goals_conceded_sum_7,
        
        AVG(shots) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
        ) as shots_avg_7,
        
        AVG(shots_on_target) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
        ) as shots_on_target_avg_7,
        
        AVG(shots_on_target_pct) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
        ) as shots_on_target_pct_7,
        
        AVG(xg) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
        ) as xg_avg_7,
        
        SUM(xg) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
        ) as xg_sum_7,
        
        AVG(passes_completed) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
        ) as passes_completed_avg_7,
        
        AVG(passes_pct) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
        ) as passes_pct_7,
        
        AVG(progressive_passes) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
        ) as progressive_passes_avg_7,
        
        AVG(possession_pct) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
        ) as possession_avg_7,
        
        AVG(tackles) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
        ) as tackles_avg_7,
        
        AVG(interceptions) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
        ) as interceptions_avg_7,
        
        AVG(fouls) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
        ) as fouls_avg_7,
        
        AVG(cards_yellow) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
        ) as cards_yellow_avg_7,
        
        AVG(cards_red) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
        ) as cards_red_avg_7,
        
        AVG(corners) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
        ) as corners_avg_7,
        
        AVG(crosses) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
        ) as crosses_avg_7,
        
        AVG(take_ons_won_pct) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
        ) as take_ons_won_pct_7,
        
        AVG(aerials_won_pct) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
        ) as aerials_won_pct_7,
        
        AVG(match_result) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
        ) as form_7,
        
        -- Окно 11 матчей
        AVG(goals_scored) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 11 PRECEDING AND 1 PRECEDING
        ) as goals_avg_11,
        
        SUM(goals_scored) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 11 PRECEDING AND 1 PRECEDING
        ) as goals_sum_11,
        
        AVG(goals_conceded) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 11 PRECEDING AND 1 PRECEDING
        ) as goals_conceded_avg_11,
        
        SUM(goals_conceded) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 11 PRECEDING AND 1 PRECEDING
        ) as goals_conceded_sum_11,
        
        AVG(shots) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 11 PRECEDING AND 1 PRECEDING
        ) as shots_avg_11,
        
        AVG(shots_on_target) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 11 PRECEDING AND 1 PRECEDING
        ) as shots_on_target_avg_11,
        
        AVG(shots_on_target_pct) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 11 PRECEDING AND 1 PRECEDING
        ) as shots_on_target_pct_11,
        
        AVG(xg) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 11 PRECEDING AND 1 PRECEDING
        ) as xg_avg_11,
        
        SUM(xg) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 11 PRECEDING AND 1 PRECEDING
        ) as xg_sum_11,
        
        AVG(passes_completed) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 11 PRECEDING AND 1 PRECEDING
        ) as passes_completed_avg_11,
        
        AVG(passes_pct) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 11 PRECEDING AND 1 PRECEDING
        ) as passes_pct_11,
        
        AVG(progressive_passes) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 11 PRECEDING AND 1 PRECEDING
        ) as progressive_passes_avg_11,
        
        AVG(possession_pct) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 11 PRECEDING AND 1 PRECEDING
        ) as possession_avg_11,
        
        AVG(tackles) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 11 PRECEDING AND 1 PRECEDING
        ) as tackles_avg_11,
        
        AVG(interceptions) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 11 PRECEDING AND 1 PRECEDING
        ) as interceptions_avg_11,
        
        AVG(fouls) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 11 PRECEDING AND 1 PRECEDING
        ) as fouls_avg_11,
        
        AVG(cards_yellow) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 11 PRECEDING AND 1 PRECEDING
        ) as cards_yellow_avg_11,
        
        AVG(cards_red) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 11 PRECEDING AND 1 PRECEDING
        ) as cards_red_avg_11,
        
        AVG(corners) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 11 PRECEDING AND 1 PRECEDING
        ) as corners_avg_11,
        
        AVG(crosses) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 11 PRECEDING AND 1 PRECEDING
        ) as crosses_avg_11,
        
        AVG(take_ons_won_pct) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 11 PRECEDING AND 1 PRECEDING
        ) as take_ons_won_pct_11,
        
        AVG(aerials_won_pct) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 11 PRECEDING AND 1 PRECEDING
        ) as aerials_won_pct_11,
        
        AVG(match_result) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 11 PRECEDING AND 1 PRECEDING
        ) as form_11,
        
        -- Стандартные отклонения для стабильности
        stddevPop(goals_scored) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
        ) as goals_std_3,
        
        stddevPop(goals_scored) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
        ) as goals_std_7,
        
        stddevPop(goals_scored) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 11 PRECEDING AND 1 PRECEDING
        ) as goals_std_11,
        
        -- Добавляем XG против (для расчета эффективности защиты)
        AVG(xg_conceded) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
        ) as xg_conceded_avg_3,
        
        AVG(xg_conceded) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 7 PRECEDING AND 1 PRECEDING
        ) as xg_conceded_avg_7,
        
        AVG(xg_conceded) OVER (
            PARTITION BY team_id 
            ORDER BY match_date 
            ROWS BETWEEN 11 PRECEDING AND 1 PRECEDING
        ) as xg_conceded_avg_11
        
    FROM match_results_with_outcome
)

SELECT * FROM team_features
WHERE 
    -- Исключаем матчи без достаточной истории
    goals_avg_3 IS NOT NULL 
    AND goals_avg_7 IS NOT NULL 
    AND goals_avg_11 IS NOT NULL
ORDER BY match_date, match_id;