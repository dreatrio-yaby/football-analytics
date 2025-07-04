# Тестирование исправленного ML Training Dataset workflow

## Проблема и решение

### Исходная проблема
ClickHouse 25.3.3 не поддерживает `!=` в JOIN ON условиях:
```sql
LEFT JOIN match_results m2 ON m1.match_id = m2.match_id AND m1.team_id != m2.team_id
```

### Решение
Заменили JOIN с `!=` на подзапросы:
```sql
(SELECT goals_scored 
 FROM match_results m2 
 WHERE m2.match_id = m1.match_id AND m2.team_id != m1.team_id
 LIMIT 1
) as goals_conceded
```

## Внесенные изменения

### 1. Файл `generate_team_features.sql`
- ✅ Заменен JOIN с `!=` на подзапрос для получения `goals_conceded`
- ✅ Добавлен подзапрос для получения `xg_conceded` 
- ✅ Исправлен расчет `xg_conceded_avg_*` для использования правильного поля

### 2. Файл `ml-training-dataset.yml`
- ✅ Добавлен шаг тестирования синтаксиса SQL перед выполнением
- ✅ Создан тестовый файл `test_generate_features.sql`

### 3. Новые файлы
- `test_generate_features.sql` - тестовый запрос для проверки синтаксиса
- `TESTING.md` - данная инструкция

## Тестирование

### Локальное тестирование (если есть доступ к ClickHouse)
```bash
# Тест синтаксиса
curl -s "https://YOUR_CLICKHOUSE_HOST:8443/" \
  --user "user:password" \
  --data-binary @data/ml/sql/test_generate_features.sql
```

### Тестирование через GitHub Actions
```bash
# Запуск только создания таблиц
gh workflow run ml-training-dataset.yml -f operation=create_ml_tables

# Запуск полной генерации датасета
gh workflow run ml-training-dataset.yml -f operation=build_dataset

# Запуск только верификации
gh workflow run ml-training-dataset.yml -f operation=verify_dataset
```

## Ожидаемые результаты

### При успешном выполнении:
1. ✅ Тест синтаксиса SQL проходит без ошибок
2. ✅ Создается view `ml.temp_team_features` 
3. ✅ Создается view `ml.temp_targets`
4. ✅ Заполняется таблица `ml.training_dataset`
5. ✅ Проходят все проверки валидации
6. ✅ Генерируется статистика по данным

### Возможные проблемы:
- **Недостаточно данных**: Минимум 20 матчей для качественных признаков
- **Производительность**: Большие датасеты могут требовать больше времени
- **Пропуски**: Команды с малым количеством матчей могут иметь NULL значения

## Мониторинг

### Логи GitHub Actions
Проверяйте следующие этапы:
1. 🔍 Test team features syntax
2. ⚙️ Generate team features  
3. 🎯 Generate targets
4. 🚀 Build training dataset
5. 🔍 Verify training dataset quality

### Проверка результатов в ClickHouse
```sql
-- Проверка созданной таблицы
SELECT COUNT(*) FROM ml.training_dataset;

-- Проверка качества данных
SELECT 
  COUNT(*) as total_records,
  COUNT(DISTINCT match_id) as unique_matches,
  AVG(home_team_goals_avg_7) as avg_home_goals_7
FROM ml.training_dataset;
```

## Откат в случае проблем

### Очистка данных
```bash
gh workflow run ml-training-dataset.yml -f operation=cleanup
```

### Ручная очистка
```sql
DROP VIEW IF EXISTS ml.temp_team_features;
DROP VIEW IF EXISTS ml.temp_targets;
TRUNCATE TABLE ml.training_dataset;
```

## Следующие шаги

После успешного тестирования:
1. Настроить автоматический запуск workflow
2. Добавить мониторинг качества данных
3. Интегрировать с ML pipeline
4. Экспортировать данные для обучения моделей