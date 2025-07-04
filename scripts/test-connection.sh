#!/bin/bash

# Скрипт для проверки подключения к ClickHouse
# Использует переменные окружения или значения по умолчанию из .env

set -e

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

echo "🔍 Проверка подключения к ClickHouse..."
echo "Хост: $CLICKHOUSE_HOST"
echo "Пользователь: $CLICKHOUSE_USER"

# Тест подключения
response=$(curl -s -w "%{http_code}" \
    "https://$CLICKHOUSE_HOST:8443/" \
    --user "$CLICKHOUSE_USER:$CLICKHOUSE_PASSWORD" \
    --data "SELECT 1" \
    --output /tmp/clickhouse_test.txt)

if [ "$response" -eq 200 ]; then
    echo "✅ Подключение успешно!"
    echo "Ответ сервера: $(cat /tmp/clickhouse_test.txt)"
else
    echo "❌ Ошибка подключения. HTTP код: $response"
    echo "Ответ сервера: $(cat /tmp/clickhouse_test.txt)"
    exit 1
fi

# Проверка доступности базы данных raw
echo ""
echo "🔍 Проверка доступности базы данных 'raw'..."
response=$(curl -s -w "%{http_code}" \
    "https://$CLICKHOUSE_HOST:8443/" \
    --user "$CLICKHOUSE_USER:$CLICKHOUSE_PASSWORD" \
    --data "SHOW DATABASES" \
    --output /tmp/clickhouse_databases.txt)

if [ "$response" -eq 200 ]; then
    if grep -q "raw" /tmp/clickhouse_databases.txt; then
        echo "✅ База данных 'raw' найдена"
    else
        echo "⚠️  База данных 'raw' не найдена"
        echo "Доступные базы данных:"
        cat /tmp/clickhouse_databases.txt
    fi
else
    echo "❌ Ошибка при проверке баз данных. HTTP код: $response"
    exit 1
fi

# Очистка временных файлов
rm -f /tmp/clickhouse_test.txt /tmp/clickhouse_databases.txt

echo ""
echo "🎉 Проверка подключения завершена успешно!"