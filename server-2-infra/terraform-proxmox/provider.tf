terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.45.0"
    }
  }
}

provider "proxmox" {
  endpoint  = "https://192.168.2.2:8006"
  api_token = "admin-api@pam!upload=${var.proxmox_api_token_secret}"
  insecure  = true
}

