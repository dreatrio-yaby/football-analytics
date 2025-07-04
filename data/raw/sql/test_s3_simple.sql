-- Простой тест подключения к S3 без сложных операций
-- Проверяем базовую доступность файлов и структуру данных

SELECT 
    COUNT(*) as total_files,
    COUNT(DISTINCT JSONExtractString(json, 'match_id')) as unique_matches
FROM s3(
    'https://storage.yandexcloud.net/fbref-json/*.json',
    '{ACCESS_KEY_ID}', 
    '{ACCESS_KEY_SECRET}',
    'JSONAsString'
)
LIMIT 10;