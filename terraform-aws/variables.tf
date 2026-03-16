variable "aws_access_key" {
  description = "AWS Access Key ID"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS Secret Access Key"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "ami_id" {
  description = "AMI ID for Ubuntu 22.04 (region-specific)"
  type        = string
  default     = "ami-0a628e1e89aaedf80" # Ubuntu 22.04 LTS в eu-central-1
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "disk_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 20
}

variable "use_elastic_ip" {
  description = "Use Elastic IP for static public IP"
  type        = bool
  default     = true
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key (for Ansible inventory)"
  type        = string
  default     = "~/.ssh/id_ed25519"
}

variable "domain" {
  description = "Domain name (optional, leave empty to skip DNS setup)"
  type        = string
  default     = ""
}

variable "route53_zone_id" {
  description = "Route53 Hosted Zone ID (required if using domain)"
  type        = string
  default     = ""
}
