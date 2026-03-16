# DigitalOcean Deployment

## Настройка

### 1. Получить API токен

1. Зайти на https://cloud.digitalocean.com/account/api/tokens
2. Создать новый токен (Personal Access Token)
3. Скопировать токен

### 2. Настроить переменные

```bash
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars
```

Минимальная конфигурация:
```hcl
do_token = "dop_v1_xxxxxxxxxxxxx"
```

### 3. Опциональные настройки

```hcl
# Регион (fra1 = Frankfurt, nyc1 = New York, sgp1 = Singapore)
region = "fra1"

# Размер дроплета
droplet_size = "s-1vcpu-2gb"  # $12/мес

# SSH ключи
ssh_public_key_path  = "~/.ssh/id_ed25519.pub"
ssh_private_key_path = "~/.ssh/id_ed25519"

# Домен (если есть)
domain = "redmine.example.com"
```

### 4. Деплой

```bash
terraform init
terraform apply
```

## Доступные регионы

- `nyc1`, `nyc3` - New York
- `sfo3` - San Francisco
- `tor1` - Toronto
- `lon1` - London
- `fra1` - Frankfurt
- `ams3` - Amsterdam
- `sgp1` - Singapore
- `blr1` - Bangalore

Полный список: https://slugs.do-api.dev/

## Размеры дроплетов

| Slug | vCPU | RAM | Цена/мес |
|------|------|-----|----------|
| `s-1vcpu-1gb` | 1 | 1GB | $6 |
| `s-1vcpu-2gb` | 1 | 2GB | $12 |
| `s-2vcpu-2gb` | 2 | 2GB | $18 |
| `s-2vcpu-4gb` | 2 | 4GB | $24 |

## DNS настройка

Если домен управляется через DigitalOcean:

1. Убедитесь что NS записи домена указывают на DigitalOcean
2. Добавьте домен в terraform.tfvars:
```hcl
domain = "redmine.example.com"
```

Terraform автоматически создаст DNS зону и A-запись.

## Особенности

- Дефолтный пользователь: **root**
- IP адрес появляется сразу после создания
- Простая интеграция с DNS
- Firewall управляется через UFW (настраивается Ansible)
