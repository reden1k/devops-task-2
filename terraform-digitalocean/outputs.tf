output "server_ip" {
  description = "Public IP of the Redmine server"
  value       = digitalocean_droplet.redmine.ipv4_address
}

output "redmine_url" {
  description = "URL to access Redmine"
  value       = var.domain != "" ? "https://${var.domain}" : "http://${digitalocean_droplet.redmine.ipv4_address}"
}

output "ssh_command" {
  description = "SSH command to connect to the server"
  value       = "ssh root@${digitalocean_droplet.redmine.ipv4_address}"
}

# Generate Ansible inventory file
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tmpl", {
    server_ip            = digitalocean_droplet.redmine.ipv4_address
    ssh_private_key_path = var.ssh_private_key_path
  })
  filename = "${path.module}/../ansible/inventory/hosts.yml"
}
