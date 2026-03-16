variable "yc_token" {
  description = "Yandex Cloud OAuth token"
  type        = string
  sensitive   = true
}

variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "folder_id" {
  description = "Yandex Cloud Folder ID"
  type        = string
}

variable "zone" {
  description = "Yandex Cloud availability zone"
  type        = string
  default     = "ru-central1-a"
}

variable "image_id" {
  description = "OS image ID (Ubuntu 22.04)"
  type        = string
  default     = "fd8kdq6d0p8sij7h5qe3" # Ubuntu 22.04 LTS
}

variable "vm_cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 2
}

variable "vm_memory" {
  description = "RAM in GB"
  type        = number
  default     = 2
}

variable "disk_size" {
  description = "Boot disk size in GB"
  type        = number
  default     = 20
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
