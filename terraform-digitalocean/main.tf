terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_ssh_key" "default" {
  name       = "redmine-key"
  public_key = file(var.ssh_public_key_path)
}

resource "digitalocean_droplet" "redmine" {
  name     = "redmine-server"
  region   = var.region
  size     = var.droplet_size
  image    = "ubuntu-22-04-x64"
  ssh_keys = [digitalocean_ssh_key.default.fingerprint]

  tags = ["redmine", "ansible-managed"]
}

resource "digitalocean_domain" "redmine" {
  count = var.domain != "" ? 1 : 0
  name  = var.domain
}

resource "digitalocean_record" "redmine_a" {
  count  = var.domain != "" ? 1 : 0
  domain = digitalocean_domain.redmine[0].name
  type   = "A"
  name   = "@"
  value  = digitalocean_droplet.redmine.ipv4_address
  ttl    = 300
}

# После создания дропа — генерируем Ansible inventory
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tmpl", {
    ip      = digitalocean_droplet.redmine.ipv4_address
    ssh_key = var.ssh_private_key_path
  })
  filename = "${path.module}/../ansible/inventory/hosts.yml"
}
