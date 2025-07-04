# ML Training Dataset - Простое решение

## 🎯 Суть 

Создает таблицу `ml.training_dataset` где одна строка = один матч с признаками команд и таргетами.

## 🔧 Как работает

**Один SQL файл** `build_training_dataset.sql` делает всё:

1. **Извлекает данные** из `raw.match_stats`
2. **Вычисляет признаки** через ClickHouse window функции за 3 и 7 матчей
3. **Создает таргеты** прямо в запросе (результат, тоталы, угловые, карточки)
4. **Объединяет команды** простым JOIN по `is_home = 1/0`
5. **Создает финальную таблицу** одной операцией

## 📊 Что получаем

**Таблица**: `ml.training_dataset`
- **Строки**: Один матч (домашняя vs гостевая команда)
- **Таргеты**: 12 бинарных целей (результат, тоталы, угловые, карточки)
- **Признаки**: 40+ признаков для каждой команды (средние за 3/7 матчей + сравнения)

## 🚀 Запуск

### GitHub Action (автоматически)
```bash
# Полная генерация
gh workflow run ml-training-dataset.yml -f operation=build

# Только проверка
gh workflow run ml-training-dataset.yml -f operation=verify
```

### Ручной запуск SQL
```sql
-- Запустить в ClickHouse
SOURCE data/ml/sql/build_training_dataset.sql
```

## 📈 Использование данных

```sql
-- Проверить таблицу
SELECT COUNT(*), COUNT(DISTINCT match_id) FROM ml.training_dataset;

-- Экспорт для ML (Python/R)
SELECT * FROM ml.training_dataset 
WHERE match_date >= '2023-01-01'
FORMAT CSV;

-- Анализ таргетов
SELECT 
    AVG(target_total_goals_over_2_5) * 100 as pct_over_2_5,
    AVG(target_match_result = 2) * 100 as pct_home_wins
FROM ml.training_dataset;
```

## 🏗️ Архитектура

```
raw.match_stats → window функции → JOIN по is_home → ml.training_dataset
```

**Преимущества простого решения:**
- ✅ **Один файл** вместо 4 сложных
- ✅ **Window функции** - используем силу ClickHouse
- ✅ **Понятно** - вся логика в одном месте
- ✅ **Быстро** - оптимизированные запросы ClickHouse
- ✅ **Надежно** - никаких сложных JOIN с `!=`

## 🎯 Признаки

**Домашняя команда**: `home_*`
- Голы, xG, удары за 3/7 матчей
- Процент попаданий, точность пасов
- Угловые, фолы, карточки
- Форма команды (средний результат)

**Гостевая команда**: `away_*`
- Те же признаки для гостевой команды

**Сравнительные**: `diff_*`, `ratio_*`
- Разности и отношения между командами
- Эффективность атаки (голы/удары)

## 🎯 Таргеты

- `target_match_result` - результат (0/1/2)
- `target_total_goals_over_X_5` - тоталы голов
- `target_home/away_goals_over_X_5` - индивидуальные тоталы
- `target_corners_over_9_5` - угловые
- `target_cards_over_3_5` - карточки  
- `target_fouls_over_20_5` - фолы

Всё готово для машинного обучения!