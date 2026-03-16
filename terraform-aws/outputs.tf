output "server_ip" {
  description = "Public IP of the Redmine server"
  value       = var.use_elastic_ip ? aws_eip.redmine[0].public_ip : aws_instance.redmine.public_ip
}

output "redmine_url" {
  description = "URL to access Redmine"
  value       = var.domain != "" ? "https://${var.domain}" : "http://${var.use_elastic_ip ? aws_eip.redmine[0].public_ip : aws_instance.redmine.public_ip}"
}

output "ssh_command" {
  description = "SSH command to connect to the server"
  value       = "ssh ubuntu@${var.use_elastic_ip ? aws_eip.redmine[0].public_ip : aws_instance.redmine.public_ip}"
}

output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.redmine.id
}

output "private_ip" {
  description = "Private IP address"
  value       = aws_instance.redmine.private_ip
}
