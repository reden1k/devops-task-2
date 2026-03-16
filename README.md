# Redmine Infrastructure

Деплой Redmine в облаке через Terraform + Ansible.

Работает с:
- DigitalOcean (проще всего)
- Yandex Cloud
- AWS

Стек: Terraform → VM → Ansible → Docker (Redmine + PostgreSQL) + nginx

## Что нужно

- Terraform >= 1.0
- Ansible >= 2.12
- SSH-ключ (сгенерить через `ssh-keygen -t ed25519`)
- Аккаунт в облаке (любой из списка выше)

## Как запустить

### 1. Клонировать

```bash
git clone <repo_url>
cd devops-task-2
```

### 2. Выбрать провайдер

Зайти в папку с нужным провайдером:

```bash
cd terraform-digitalocean  # или terraform-yandex, или terraform-aws
```

### 3. Настроить конфиг

```bash
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars  # вставить свои токены/ключи
```

### 4. Запустить Terraform

```bash
terraform init
terraform plan
terraform apply
```

После apply создастся файл `ansible/inventory/hosts.yml` с IP сервера.

### 5. Настроить Ansible

```bash
cd ../ansible
ansible-galaxy collection install -r requirements.yml

nano group_vars/all.yml
# !!! Обязательно поменять postgres_password и redmine_secret_key
# secret key можно сгенерить так: openssl rand -hex 64
```

### 6. Деплой

```bash
ansible-playbook -i inventory/hosts.yml playbook.yml
```

Всё, Redmine должен быть доступен по IP сервера.

## Структура

```
.
├── terraform-digitalocean/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars.example
│
├── terraform-yandex/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars.example
│
├── terraform-aws/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars.example
│
└── ansible/
    ├── playbook.yml
    ├── requirements.yml
    ├── group_vars/all.yml
    ├── inventory/hosts.yml  (автогенерится)
    └── roles/
        ├── docker/
        └── redmine/
```

## Что делает Ansible

Роль **docker** ставит Docker CE и Docker Compose.

Роль **redmine** разворачивает docker-compose с Redmine + PostgreSQL, настраивает nginx и файрволл (порты 22, 80, 443).

Роли работают на любом Ubuntu сервере.

## Удаление

```bash
cd terraform-<provider>
terraform destroy
```

