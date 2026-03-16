terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# Default VPC и subnet для простоты
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "default" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = "${var.region}a"
  default_for_az    = true
}

# Security Group
resource "aws_security_group" "redmine" {
  name        = "redmine-sg"
  description = "Security group for Redmine server"
  vpc_id      = data.aws_vpc.default.id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "redmine-security-group"
  }
}

# SSH Key Pair
resource "aws_key_pair" "redmine" {
  key_name   = "redmine-key"
  public_key = file(var.ssh_public_key_path)
}

# EC2 Instance
resource "aws_instance" "redmine" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.redmine.key_name
  subnet_id     = data.aws_subnet.default.id

  vpc_security_group_ids = [aws_security_group.redmine.id]

  root_block_device {
    volume_size = var.disk_size
    volume_type = "gp3"
  }

  tags = {
    Name = "redmine-server"
  }
}

# Elastic IP (опционально, для постоянного IP)
resource "aws_eip" "redmine" {
  count    = var.use_elastic_ip ? 1 : 0
  instance = aws_instance.redmine.id
  domain   = "vpc"

  tags = {
    Name = "redmine-eip"
  }
}

# DNS записи (если используется Route53)
data "aws_route53_zone" "redmine" {
  count = var.domain != "" && var.route53_zone_id != "" ? 1 : 0
  zone_id = var.route53_zone_id
}

resource "aws_route53_record" "redmine" {
  count   = var.domain != "" && var.route53_zone_id != "" ? 1 : 0
  zone_id = data.aws_route53_zone.redmine[0].zone_id
  name    = var.domain
  type    = "A"
  ttl     = 300
  records = [var.use_elastic_ip ? aws_eip.redmine[0].public_ip : aws_instance.redmine.public_ip]
}

# Генерация Ansible inventory
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tmpl", {
    server_ip            = var.use_elastic_ip ? aws_eip.redmine[0].public_ip : aws_instance.redmine.public_ip
    ssh_private_key_path = var.ssh_private_key_path
  })
  filename = "${path.module}/../ansible/inventory/hosts.yml"
}
