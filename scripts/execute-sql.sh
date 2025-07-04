#!/bin/bash

# Скрипт для выполнения SQL команд в ClickHouse
# Использование: ./execute-sql.sh <sql_file>

set -e

# Проверка аргументов
if [ $# -ne 1 ]; then
    echo "Использование: $0 <sql_file>"
    echo "Пример: $0 create_match_stats_table.sql"
    exit 1
fi

SQL_FILE=$1

# Проверка существования файла
if [ ! -f "$SQL_FILE" ]; then
    echo "❌ Ошибка: Файл '$SQL_FILE' не найден"
    exit 1
fi

# Загрузка переменных из .env если файл существует
if [ -f .env ]; then
    export $(cat .env | xargs)
fi

# Проверка обязательных переменных
if [ -z "$CLICKHOUSE_HOST" ] || [ -z "$CLICKHOUSE_USER" ] || [ -z "$CLICKHOUSE_PASSWORD" ]; then
    echo "❌ Ошибка: Не заданы обязательные переменные окружения"
    echo "Необходимо задать: CLICKHOUSE_HOST, CLICKHOUSE_USER, CLICKHOUSE_PASSWORD"
    exit 1
fi

echo "🚀 Выполнение SQL файла: $SQL_FILE"
echo "Хост: $CLICKHOUSE_HOST"
echo "Пользователь: $CLICKHOUSE_USER"

# Подстановка переменных окружения в SQL файл
temp_sql="/tmp/processed_sql.sql"
sed "s/{ACCESS_KEY_ID}/$ACCESS_KEY_ID/g; s/{ACCESS_KEY_SECRET}/$ACCESS_KEY_SECRET/g" "$SQL_FILE" > "$temp_sql"

# Выполнение SQL команды
response=$(curl -s -w "%{http_code}" \
    "https://$CLICKHOUSE_HOST:8443/" \
    --user "$CLICKHOUSE_USER:$CLICKHOUSE_PASSWORD" \
    --data-binary "@$temp_sql" \
    --output /tmp/clickhouse_result.txt)

echo "HTTP код ответа: $response"

if [ "$response" -eq 200 ]; then
    echo "✅ SQL команда выполнена успешно!"
    
    # Показать результат если он не пустой
    if [ -s /tmp/clickhouse_result.txt ]; then
        echo ""
        echo "📊 Результат выполнения:"
        cat /tmp/clickhouse_result.txt
    fi
else
    echo "❌ Ошибка выполнения SQL команды"
    echo "Ответ сервера:"
    cat /tmp/clickhouse_result.txt
    exit 1
fi

# Очистка временных файлов
rm -f /tmp/clickhouse_result.txt /tmp/processed_sql.sql

echo ""
echo "🎉 Выполнение завершено успешно!"