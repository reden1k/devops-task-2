# Yandex Cloud Deployment

## Настройка

### 1. Установить Yandex Cloud CLI

```bash
# Linux/macOS
curl https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash

# Инициализация
yc init
```

### 2. Получить учетные данные

```bash
# Получить токен
yc iam create-token

# Получить Cloud ID и Folder ID
yc config list
```

### 3. Настроить переменные

```bash
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars
```

Минимальная конфигурация:
```hcl
yc_token  = "t1.xxxxxxxxxxxxxxxxxx"
cloud_id  = "b1gxxxxxxxxxxxxxxxxx"
folder_id = "b1gxxxxxxxxxxxxxxxxx"
```

### 4. Опциональные настройки

```hcl
# Зона доступности
zone = "ru-central1-a"  # Москва (Новинский)

# Размер VM
vm_cores  = 2
vm_memory = 2

# Образ Ubuntu 22.04 (может меняться!)
image_id = "fd8kdq6d0p8sij7h5qe3"

# SSH ключи
ssh_public_key_path  = "~/.ssh/id_ed25519.pub"
ssh_private_key_path = "~/.ssh/id_ed25519"
```

### 5. Деплой

```bash
terraform init
terraform apply
```

## Зоны доступности

- `ru-central1-a` - Москва, ЦОД Новинский
- `ru-central1-b` - Москва, ЦОД NORD4 (Северный Чертаново)
- `ru-central1-d` - Москва, ЦОД DataLine NORD (Владимировка)

## Размеры VM

| vCPU | RAM | Диск | Примерная цена/мес |
|------|-----|------|-------------------|
| 2 | 2GB | 20GB | ~500₽ |
| 2 | 4GB | 20GB | ~800₽ |
| 4 | 4GB | 20GB | ~1000₽ |

**Важно:** Первые 60 дней - бесплатно по программе Trial!

Калькулятор: https://cloud.yandex.ru/prices

## Как найти актуальный Image ID

```bash
# Список образов Ubuntu
yc compute image list --folder-id standard-images | grep ubuntu-22-04

# Или использовать семейство образов
yc compute image get-latest-from-family ubuntu-2204-lts --folder-id standard-images
```

## DNS настройка

Если домен управляется через Yandex Cloud DNS:

1. Создайте DNS зону в консоли или добавьте в terraform.tfvars:
```hcl
domain = "redmine.example.com"
```

2. Terraform автоматически создаст DNS зону и A-запись
3. Делегируйте домен на NS-серверы Yandex Cloud

## Сетевая настройка

- Автоматически создается VPC Network
- Subnet: 10.2.0.0/16
- NAT включен для доступа в интернет
- Внешний IP назначается автоматически

## Особенности

- Дефолтный пользователь: **ubuntu**
- Требует cloud_id и folder_id
- Бесплатный Trial на 60 дней
- Российское законодательство, хранение данных в РФ
- Поддержка на русском языке

## Полезные команды

```bash
# Посмотреть VM
yc compute instance list

# Подключиться по SSH
yc compute ssh redmine-server

# Удалить все ресурсы
terraform destroy
```

## Документация

- [Начало работы](https://cloud.yandex.ru/docs/getting-started/)
- [Compute Cloud](https://cloud.yandex.ru/docs/compute/)
- [Terraform Provider](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs)
