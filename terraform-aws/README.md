# AWS Deployment

## Настройка

### 1. Создать IAM пользователя

1. Зайти в [IAM Console](https://console.aws.amazon.com/iam/)
2. Users → Add user
3. Включить "Programmatic access"
4. Прикрепить политику: `AmazonEC2FullAccess` (или создать custom policy)
5. Сохранить Access Key ID и Secret Access Key

### 2. Настроить переменные

```bash
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars
```

Минимальная конфигурация:
```hcl
aws_access_key = "AKIAXXXXXXXXXXXXXXXX"
aws_secret_key = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
region         = "eu-central-1"
```

### 3. Найти AMI ID для вашего региона

AMI ID зависит от региона! Найти актуальный:
- https://cloud-images.ubuntu.com/locator/ec2/
- Ищите: `22.04 LTS` + `amd64` + ваш регион

Примеры:
```hcl
# eu-central-1 (Frankfurt)
ami_id = "ami-0a628e1e89aaedf80"

# us-east-1 (Virginia)
ami_id = "ami-0866a3c8686eaeeba"

# us-west-2 (Oregon)
ami_id = "ami-05134c8ef96964280"
```

### 4. Опциональные настройки

```hcl
# Тип инстанса
instance_type = "t3.small"  # 2 vCPU, 2GB RAM

# Размер диска
disk_size = 20

# Elastic IP (рекомендуется для production)
use_elastic_ip = true

# SSH ключи
ssh_public_key_path  = "~/.ssh/id_ed25519.pub"
ssh_private_key_path = "~/.ssh/id_ed25519"

# Домен и Route53
domain          = "redmine.example.com"
route53_zone_id = "Z1234567890ABC"
```

### 5. Деплой

```bash
terraform init
terraform apply
```

## Регионы

| Код | Локация | Зоны |
|-----|---------|------|
| `us-east-1` | N. Virginia | 6 |
| `us-west-2` | Oregon | 4 |
| `eu-central-1` | Frankfurt | 3 |
| `eu-west-1` | Ireland | 3 |
| `ap-southeast-1` | Singapore | 3 |
| `ap-northeast-1` | Tokyo | 4 |

Полный список: https://aws.amazon.com/about-aws/global-infrastructure/regions_az/

## Instance Types

### General Purpose (T3)
| Type | vCPU | RAM | Цена/час (eu-central-1) |
|------|------|-----|------------------------|
| `t3.micro` | 2 | 1GB | $0.0114 (~$8/мес) |
| `t3.small` | 2 | 2GB | $0.0228 (~$16/мес) |
| `t3.medium` | 2 | 4GB | $0.0456 (~$32/мес) |

**Free Tier:** t3.micro - 750 часов/месяц первые 12 месяцев

Калькулятор: https://calculator.aws/

## DNS настройка (Route53)

### Если домен в Route53:

1. Найти Zone ID:
```bash
aws route53 list-hosted-zones
```

2. Добавить в terraform.tfvars:
```hcl
domain          = "redmine.example.com"
route53_zone_id = "Z1234567890ABC"
```

### Если домен у другого регистратора:

1. Создать Hosted Zone в Route53
2. Делегировать домен на NS-серверы Route53
3. Использовать конфигурацию выше

## Elastic IP

По умолчанию `use_elastic_ip = true` для постоянного IP.

Отключить для экономии (~$3.6/мес за неиспользуемый IP):
```hcl
use_elastic_ip = false
```

**Важно:** Без Elastic IP адрес меняется при перезапуске instance!

## Security Group

Автоматически создается с правилами:
- SSH (22) - 0.0.0.0/0
- HTTP (80) - 0.0.0.0/0
- HTTPS (443) - 0.0.0.0/0

Для production рекомендуется ограничить SSH по IP.

## VPC

Использует Default VPC для простоты.

Для production рекомендуется создать отдельную VPC с приватными subnet'ами.

## Особенности

- Дефолтный пользователь: **ubuntu**
- AMI ID зависит от региона
- Free Tier доступен 12 месяцев
- Elastic IP рекомендуется для production
- Много дополнительных сервисов (RDS, S3, CloudWatch и др.)

## Полезные команды

```bash
# Список инстансов
aws ec2 describe-instances --region eu-central-1

# Подключение по SSH (с Elastic IP)
ssh ubuntu@$(terraform output -raw server_ip)

# Удалить ресурсы
terraform destroy
```

## Free Tier ограничения

- 750 часов t3.micro в месяц (1 инстанс 24/7)
- 30GB EBS storage
- 1GB Elastic IP (если инстанс запущен)
- 15GB bandwidth out

Подробнее: https://aws.amazon.com/free/

## Документация

- [Getting Started](https://aws.amazon.com/getting-started/)
- [EC2 User Guide](https://docs.aws.amazon.com/ec2/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
