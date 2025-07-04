# Football Analytics - ClickHouse Data Pipeline

Проект для загрузки и анализа футбольных данных с использованием ClickHouse и Yandex Cloud S3.

## Архитектура

- **Источник данных**: JSON файлы в Yandex Cloud S3 (`fbref-json/*.json`)
- **Хранилище**: ClickHouse кластер в Yandex Cloud
- **Автоматизация**: GitHub Actions для синхронизации данных
- **База данных**: `raw` - для хранения плоских таблиц

## Структура проекта

```
.
├── .github/workflows/
│   └── clickhouse-data-sync.yml    # GitHub Actions workflow
├── scripts/
│   ├── test-connection.sh          # Проверка подключения к ClickHouse
│   └── execute-sql.sh              # Выполнение SQL команд
├── docs/                           # Документация проекта
│   ├── README.md                   # Основная документация
│   ├── SETUP.md                    # Инструкции по настройке
│   └── tasks/
│       └── todo.md                 # Список задач проекта
├── data/                           # Слои данных
│   └── raw/                        # Слой raw данных
│       ├── sql/                    # SQL скрипты для raw слоя
│       │   ├── create_tables.sql   # Создание таблиц
│       │   ├── insert_data.sql     # Загрузка данных из S3
│       │   ├── test_queries.sql    # Тестовые запросы
│       │   └── verify_fields.sql   # Проверка всех полей
│       └── sample/                 # Примеры данных
│           ├── match.json          # Пример структуры данных
│           └── glossary.txt        # Глоссарий терминов
└── claude.md                       # Инструкции проекта
```

## Быстрый старт

### 1. Настройка GitHub Secrets

Добавьте в настройки репозитория следующие секреты:

```
CLICKHOUSE_HOST=your_clickhouse_host
CLICKHOUSE_USER=your_username
CLICKHOUSE_PASSWORD=your_password
ACCESS_KEY_ID=your_yandex_access_key_id
ACCESS_KEY_SECRET=your_yandex_access_key_secret
```

**Как добавить секреты:**
1. Settings → Secrets and variables → Actions
2. New repository secret
3. Введите имя и значение секрета

### 2. Локальная настройка

Создайте файл `.env` в корне проекта:

```bash
CLICKHOUSE_HOST=your_clickhouse_host
CLICKHOUSE_USER=your_username
CLICKHOUSE_PASSWORD=your_password
ACCESS_KEY_ID=your_yandex_access_key_id
ACCESS_KEY_SECRET=your_yandex_access_key_secret
```

### 3. Проверка подключения

```bash
# Проверка подключения к ClickHouse
./scripts/test-connection.sh
```

### 4. Создание таблицы

```bash
# Создание таблицы в ClickHouse
./scripts/execute-sql.sh data/raw/sql/create_tables.sql
```

### 5. Загрузка данных

```bash
# Загрузка данных из S3
./scripts/execute-sql.sh data/raw/sql/insert_data.sql
```

## GitHub Actions

### Автоматический запуск

- **Расписание**: Каждый день в 2:00 UTC
- **Ручной запуск**: Через интерфейс GitHub Actions

### Доступные операции

1. **sync** (по умолчанию) - Полная синхронизация данных
2. **create_table** - Создание таблицы
3. **test_connection** - Проверка подключения
4. **verify_data** - Проверка данных

### Ручной запуск

1. Перейдите в раздел Actions
2. Выберите "ClickHouse Data Sync"
3. Нажмите "Run workflow"
4. Выберите операцию

## Структура данных

### Исходные данные (JSON)

```json
{
  "match_id": "000fb8fc",
  "match_date": "2025-04-19",
  "teams_stats": {
    "team_id_1": {
      "summary": { ... },
      "passing": { ... },
      "pass_types": { ... },
      "defensive_actions": { ... },
      "possession": { ... },
      "miscellaneous": { ... },
      "goalkeeping": { ... }
    },
    "team_id_2": { ... }
  }
}
```

### Результирующая таблица

Таблица `raw.match_stats` содержит **142 поля**:

- **Основные поля**: match_id, match_date, team_id
- **Summary**: 26 полей (голы, передачи, атаки)
- **Passing**: 22 поля (статистика передач)
- **Pass Types**: 15 полей (типы передач)
- **Defensive Actions**: 16 полей (защитные действия)
- **Possession**: 23 поля (владение мячом)
- **Miscellaneous**: 17 полей (разное)
- **Goalkeeping**: 23 поля (вратарская статистика)

## Примеры запросов

### Базовая статистика

```sql
SELECT 
    COUNT(*) as total_records,
    COUNT(DISTINCT match_id) as unique_matches,
    COUNT(DISTINCT team_id) as unique_teams
FROM raw.match_stats;
```

### Анализ голов

```sql
SELECT 
    team_id,
    SUM(toInt32(summary_goals)) as total_goals,
    AVG(toFloat32(summary_xg)) as avg_xg
FROM raw.match_stats
WHERE summary_goals != ''
GROUP BY team_id
ORDER BY total_goals DESC;
```

## Мониторинг

### Логи GitHub Actions

- Все операции логируются в GitHub Actions
- Доступны статистики загруженных данных
- Уведомления об ошибках

### Проверка данных

```bash
# Проверка тестовых данных
./scripts/execute-sql.sh data/raw/sql/test_queries.sql

# Проверка всех полей
./scripts/execute-sql.sh data/raw/sql/verify_fields.sql
```

## Безопасность

⚠️ **Важно**: 
- Никогда не коммитьте секреты в код
- Используйте GitHub Secrets для чувствительных данных
- Регулярно обновляйте пароли доступа

## Поддержка

Если возникли проблемы:

1. Проверьте статус GitHub Actions
2. Убедитесь, что все секреты настроены
3. Запустите локальную проверку подключения
4. Проверьте логи выполнения

## Технические детали

- **ClickHouse**: Используется HTTP API для выполнения запросов
- **S3**: Прямое чтение JSON через функцию `s3()`
- **JSON**: Извлечение полей через `JSONExtractString()`
- **Автоматизация**: GitHub Actions с расписанием и ручным запуском