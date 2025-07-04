-- Создание таблицы обучающей выборки для футбольной аналитики
-- Один матч = одна строка
-- Таргеты с префиксом target_*
-- Признаки с префиксами home_team_*, away_team_*, diff_*

CREATE TABLE IF NOT EXISTS ml.training_dataset (
    -- Технические поля (не используются как признаки)
    match_id String,
    match_date Date,
    home_team_id String,
    away_team_id String,
    
    -- ТАРГЕТЫ --
    
    -- Результат матча (0 - проигрыш домашней команды, 1 - ничья, 2 - победа домашней команды)
    target_match_result UInt8,
    
    -- Тоталы голов (over/under)
    target_total_goals_over_0_5 UInt8,
    target_total_goals_over_1_5 UInt8,
    target_total_goals_over_2_5 UInt8,
    target_total_goals_over_3_5 UInt8,
    target_total_goals_over_4_5 UInt8,
    target_total_goals_over_5_5 UInt8,
    
    -- Индивидуальные тоталы голов домашней команды
    target_home_goals_over_0_5 UInt8,
    target_home_goals_over_1_5 UInt8,
    target_home_goals_over_2_5 UInt8,
    target_home_goals_over_3_5 UInt8,
    
    -- Индивидуальные тоталы голов гостевой команды
    target_away_goals_over_0_5 UInt8,
    target_away_goals_over_1_5 UInt8,
    target_away_goals_over_2_5 UInt8,
    target_away_goals_over_3_5 UInt8,
    
    -- Угловые (общие)
    target_corners_over_8_5 UInt8,
    target_corners_over_9_5 UInt8,
    target_corners_over_10_5 UInt8,
    target_corners_over_11_5 UInt8,
    target_corners_over_12_5 UInt8,
    
    -- Карточки (общие)
    target_cards_over_2_5 UInt8,
    target_cards_over_3_5 UInt8,
    target_cards_over_4_5 UInt8,
    target_cards_over_5_5 UInt8,
    
    -- Фолы (общие)
    target_fouls_over_18_5 UInt8,
    target_fouls_over_20_5 UInt8,
    target_fouls_over_22_5 UInt8,
    target_fouls_over_24_5 UInt8,
    
    -- ПРИЗНАКИ ДОМАШНЕЙ КОМАНДЫ --
    
    -- Окно 3 матча
    home_team_goals_avg_3 Float32,
    home_team_goals_sum_3 Float32,
    home_team_goals_conceded_avg_3 Float32,
    home_team_goals_conceded_sum_3 Float32,
    home_team_shots_avg_3 Float32,
    home_team_shots_on_target_avg_3 Float32,
    home_team_shots_on_target_pct_3 Float32,
    home_team_xg_avg_3 Float32,
    home_team_xg_sum_3 Float32,
    home_team_xg_conceded_avg_3 Float32,
    home_team_passes_completed_avg_3 Float32,
    home_team_passes_pct_3 Float32,
    home_team_progressive_passes_avg_3 Float32,
    home_team_possession_avg_3 Float32,
    home_team_tackles_avg_3 Float32,
    home_team_interceptions_avg_3 Float32,
    home_team_fouls_avg_3 Float32,
    home_team_cards_yellow_avg_3 Float32,
    home_team_cards_red_avg_3 Float32,
    home_team_corners_avg_3 Float32,
    home_team_crosses_avg_3 Float32,
    home_team_take_ons_won_pct_3 Float32,
    home_team_aerials_won_pct_3 Float32,
    home_team_form_3 Float32, -- средний результат за 3 матча (0-проигрыш, 1-ничья, 2-победа)
    
    -- Окно 7 матчей
    home_team_goals_avg_7 Float32,
    home_team_goals_sum_7 Float32,
    home_team_goals_conceded_avg_7 Float32,
    home_team_goals_conceded_sum_7 Float32,
    home_team_shots_avg_7 Float32,
    home_team_shots_on_target_avg_7 Float32,
    home_team_shots_on_target_pct_7 Float32,
    home_team_xg_avg_7 Float32,
    home_team_xg_sum_7 Float32,
    home_team_xg_conceded_avg_7 Float32,
    home_team_passes_completed_avg_7 Float32,
    home_team_passes_pct_7 Float32,
    home_team_progressive_passes_avg_7 Float32,
    home_team_possession_avg_7 Float32,
    home_team_tackles_avg_7 Float32,
    home_team_interceptions_avg_7 Float32,
    home_team_fouls_avg_7 Float32,
    home_team_cards_yellow_avg_7 Float32,
    home_team_cards_red_avg_7 Float32,
    home_team_corners_avg_7 Float32,
    home_team_crosses_avg_7 Float32,
    home_team_take_ons_won_pct_7 Float32,
    home_team_aerials_won_pct_7 Float32,
    home_team_form_7 Float32,
    
    -- Окно 11 матчей
    home_team_goals_avg_11 Float32,
    home_team_goals_sum_11 Float32,
    home_team_goals_conceded_avg_11 Float32,
    home_team_goals_conceded_sum_11 Float32,
    home_team_shots_avg_11 Float32,
    home_team_shots_on_target_avg_11 Float32,
    home_team_shots_on_target_pct_11 Float32,
    home_team_xg_avg_11 Float32,
    home_team_xg_sum_11 Float32,
    home_team_xg_conceded_avg_11 Float32,
    home_team_passes_completed_avg_11 Float32,
    home_team_passes_pct_11 Float32,
    home_team_progressive_passes_avg_11 Float32,
    home_team_possession_avg_11 Float32,
    home_team_tackles_avg_11 Float32,
    home_team_interceptions_avg_11 Float32,
    home_team_fouls_avg_11 Float32,
    home_team_cards_yellow_avg_11 Float32,
    home_team_cards_red_avg_11 Float32,
    home_team_corners_avg_11 Float32,
    home_team_crosses_avg_11 Float32,
    home_team_take_ons_won_pct_11 Float32,
    home_team_aerials_won_pct_11 Float32,
    home_team_form_11 Float32,
    
    -- ПРИЗНАКИ ГОСТЕВОЙ КОМАНДЫ --
    
    -- Окно 3 матча
    away_team_goals_avg_3 Float32,
    away_team_goals_sum_3 Float32,
    away_team_goals_conceded_avg_3 Float32,
    away_team_goals_conceded_sum_3 Float32,
    away_team_shots_avg_3 Float32,
    away_team_shots_on_target_avg_3 Float32,
    away_team_shots_on_target_pct_3 Float32,
    away_team_xg_avg_3 Float32,
    away_team_xg_sum_3 Float32,
    away_team_xg_conceded_avg_3 Float32,
    away_team_passes_completed_avg_3 Float32,
    away_team_passes_pct_3 Float32,
    away_team_progressive_passes_avg_3 Float32,
    away_team_possession_avg_3 Float32,
    away_team_tackles_avg_3 Float32,
    away_team_interceptions_avg_3 Float32,
    away_team_fouls_avg_3 Float32,
    away_team_cards_yellow_avg_3 Float32,
    away_team_cards_red_avg_3 Float32,
    away_team_corners_avg_3 Float32,
    away_team_crosses_avg_3 Float32,
    away_team_take_ons_won_pct_3 Float32,
    away_team_aerials_won_pct_3 Float32,
    away_team_form_3 Float32,
    
    -- Окно 7 матчей
    away_team_goals_avg_7 Float32,
    away_team_goals_sum_7 Float32,
    away_team_goals_conceded_avg_7 Float32,
    away_team_goals_conceded_sum_7 Float32,
    away_team_shots_avg_7 Float32,
    away_team_shots_on_target_avg_7 Float32,
    away_team_shots_on_target_pct_7 Float32,
    away_team_xg_avg_7 Float32,
    away_team_xg_sum_7 Float32,
    away_team_xg_conceded_avg_7 Float32,
    away_team_passes_completed_avg_7 Float32,
    away_team_passes_pct_7 Float32,
    away_team_progressive_passes_avg_7 Float32,
    away_team_possession_avg_7 Float32,
    away_team_tackles_avg_7 Float32,
    away_team_interceptions_avg_7 Float32,
    away_team_fouls_avg_7 Float32,
    away_team_cards_yellow_avg_7 Float32,
    away_team_cards_red_avg_7 Float32,
    away_team_corners_avg_7 Float32,
    away_team_crosses_avg_7 Float32,
    away_team_take_ons_won_pct_7 Float32,
    away_team_aerials_won_pct_7 Float32,
    away_team_form_7 Float32,
    
    -- Окно 11 матчей
    away_team_goals_avg_11 Float32,
    away_team_goals_sum_11 Float32,
    away_team_goals_conceded_avg_11 Float32,
    away_team_goals_conceded_sum_11 Float32,
    away_team_shots_avg_11 Float32,
    away_team_shots_on_target_avg_11 Float32,
    away_team_shots_on_target_pct_11 Float32,
    away_team_xg_avg_11 Float32,
    away_team_xg_sum_11 Float32,
    away_team_xg_conceded_avg_11 Float32,
    away_team_passes_completed_avg_11 Float32,
    away_team_passes_pct_11 Float32,
    away_team_progressive_passes_avg_11 Float32,
    away_team_possession_avg_11 Float32,
    away_team_tackles_avg_11 Float32,
    away_team_interceptions_avg_11 Float32,
    away_team_fouls_avg_11 Float32,
    away_team_cards_yellow_avg_11 Float32,
    away_team_cards_red_avg_11 Float32,
    away_team_corners_avg_11 Float32,
    away_team_crosses_avg_11 Float32,
    away_team_take_ons_won_pct_11 Float32,
    away_team_aerials_won_pct_11 Float32,
    away_team_form_11 Float32,
    
    -- ПРИЗНАКИ ВЗАИМОДЕЙСТВИЯ КОМАНД (разности и отношения) --
    
    -- Окно 3 матча
    diff_goals_avg_3 Float32, -- разность средних голов
    diff_goals_conceded_avg_3 Float32,
    diff_xg_avg_3 Float32,
    diff_shots_avg_3 Float32,
    diff_possession_avg_3 Float32,
    diff_form_3 Float32,
    ratio_goals_avg_3 Float32, -- отношение средних голов
    ratio_xg_avg_3 Float32,
    ratio_shots_avg_3 Float32,
    
    -- Окно 7 матчей
    diff_goals_avg_7 Float32,
    diff_goals_conceded_avg_7 Float32,
    diff_xg_avg_7 Float32,
    diff_shots_avg_7 Float32,
    diff_possession_avg_7 Float32,
    diff_form_7 Float32,
    ratio_goals_avg_7 Float32,
    ratio_xg_avg_7 Float32,
    ratio_shots_avg_7 Float32,
    
    -- Окно 11 матчей
    diff_goals_avg_11 Float32,
    diff_goals_conceded_avg_11 Float32,
    diff_xg_avg_11 Float32,
    diff_shots_avg_11 Float32,
    diff_possession_avg_11 Float32,
    diff_form_11 Float32,
    ratio_goals_avg_11 Float32,
    ratio_xg_avg_11 Float32,
    ratio_shots_avg_11 Float32,
    
    -- ПРОИЗВОДНЫЕ ПРИЗНАКИ --
    
    -- Эффективность атаки домашней команды
    home_team_attack_efficiency_3 Float32, -- goals per shot за 3 матча
    home_team_attack_efficiency_7 Float32,
    home_team_attack_efficiency_11 Float32,
    
    -- Эффективность защиты домашней команды
    home_team_defense_efficiency_3 Float32, -- goals conceded per shot on target against за 3 матча
    home_team_defense_efficiency_7 Float32,
    home_team_defense_efficiency_11 Float32,
    
    -- Эффективность атаки гостевой команды
    away_team_attack_efficiency_3 Float32,
    away_team_attack_efficiency_7 Float32,
    away_team_attack_efficiency_11 Float32,
    
    -- Эффективность защиты гостевой команды
    away_team_defense_efficiency_3 Float32,
    away_team_defense_efficiency_7 Float32,
    away_team_defense_efficiency_11 Float32,
    
    -- Стабильность показателей (стандартное отклонение)
    home_team_goals_std_3 Float32,
    home_team_goals_std_7 Float32,
    home_team_goals_std_11 Float32,
    away_team_goals_std_3 Float32,
    away_team_goals_std_7 Float32,
    away_team_goals_std_11 Float32
)
ENGINE = MergeTree()
ORDER BY (match_date, match_id)
PARTITION BY toYYYYMM(match_date);