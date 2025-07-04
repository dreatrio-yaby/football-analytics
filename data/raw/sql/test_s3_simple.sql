-- Простой тест подключения к S3 - проверка доступа к одному файлу
-- Проверяем базовую доступность и структуру данных

SELECT 
    JSONExtractString(json, 'match_id') as match_id,
    JSONExtractString(json, 'match_date') as match_date,
    'S3 access successful' as status
FROM s3(
    'https://storage.yandexcloud.net/fbref-json/000105e9.json',
    '{ACCESS_KEY_ID}', 
    '{ACCESS_KEY_SECRET}',
    'JSONAsString'
)
LIMIT 1;