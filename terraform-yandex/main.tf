terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.100"
    }
  }
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
}

resource "yandex_compute_instance" "redmine" {
  name        = "redmine-server"
  platform_id = "standard-v3"
  zone        = var.zone

  resources {
    cores  = var.vm_cores
    memory = var.vm_memory
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = var.disk_size
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.redmine.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key_path)}"
  }
}

resource "yandex_vpc_network" "redmine" {
  name = "redmine-network"
}

resource "yandex_vpc_subnet" "redmine" {
  name           = "redmine-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.redmine.id
  v4_cidr_blocks = ["10.2.0.0/16"]
}

# DNS записи (опционально, если домен управляется через Yandex DNS)
resource "yandex_dns_zone" "redmine" {
  count = var.domain != "" ? 1 : 0
  name  = "${replace(var.domain, ".", "-")}-zone"
  zone  = "${var.domain}."

  public = true
}

resource "yandex_dns_recordset" "redmine_a" {
  count   = var.domain != "" ? 1 : 0
  zone_id = yandex_dns_zone.redmine[0].id
  name    = "${var.domain}."
  type    = "A"
  ttl     = 300
  data    = [yandex_compute_instance.redmine.network_interface.0.nat_ip_address]
}

# Генерация Ansible inventory
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tmpl", {
    server_ip            = yandex_compute_instance.redmine.network_interface.0.nat_ip_address
    ssh_private_key_path = var.ssh_private_key_path
  })
  filename = "${path.module}/../ansible/inventory/hosts.yml"
}
