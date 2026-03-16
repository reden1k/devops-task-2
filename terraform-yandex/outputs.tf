output "server_ip" {
  description = "Public IP of the Redmine server"
  value       = yandex_compute_instance.redmine.network_interface.0.nat_ip_address
}

output "redmine_url" {
  description = "URL to access Redmine"
  value       = var.domain != "" ? "https://${var.domain}" : "http://${yandex_compute_instance.redmine.network_interface.0.nat_ip_address}"
}

output "ssh_command" {
  description = "SSH command to connect to the server"
  value       = "ssh ubuntu@${yandex_compute_instance.redmine.network_interface.0.nat_ip_address}"
}

output "internal_ip" {
  description = "Internal IP address"
  value       = yandex_compute_instance.redmine.network_interface.0.ip_address
}
