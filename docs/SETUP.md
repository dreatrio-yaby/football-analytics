# Настройка проекта

## Необходимые GitHub Secrets

Для работы автоматизации добавьте следующие секреты в настройки репозитория:

### ClickHouse подключение
- `CLICKHOUSE_HOST` - хост ClickHouse кластера
- `CLICKHOUSE_USER` - пользователь ClickHouse  
- `CLICKHOUSE_PASSWORD` - пароль ClickHouse

### Yandex Cloud S3
- `ACCESS_KEY_ID` - ключ доступа к S3
- `ACCESS_KEY_SECRET` - секретный ключ S3

## Локальная настройка

Создайте файл `.env` в корне проекта с реальными значениями (этот файл исключен из Git):

```bash
CLICKHOUSE_HOST=your_host_here
CLICKHOUSE_USER=your_user_here  
CLICKHOUSE_PASSWORD=your_password_here
ACCESS_KEY_ID=your_key_here
ACCESS_KEY_SECRET=your_secret_here
```

## SSL Сертификаты

GitHub Actions автоматически устанавливает SSL сертификаты Yandex Cloud для подключения к ClickHouse. Сертификаты загружаются с официальных URL:
- `https://storage.yandexcloud.net/cloud-certs/RootCA.pem`
- `https://storage.yandexcloud.net/cloud-certs/IntermediateCA.pem`

## Безопасность

✅ Файл `.env` исключен из Git через `.gitignore`
✅ SQL файлы используют плейсхолдеры вместо реальных ключей
✅ GitHub Actions использует секреты для подстановки значений
✅ SSL сертификаты устанавливаются автоматически в GitHub Actions
✅ Никакие секретные данные не сохраняются в репозитории