variable "proxmox_api_token_secret" {
  type      = string
  sensitive = true
}

variable "ssh_public_key_path" {
  type    = string
  default = "/home/admin/.ssh/id_ed25519.pub"
}

