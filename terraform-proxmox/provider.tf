# terraform-proxmox/provider.tf

terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.45.0"
    }
  }
}

# Configuration de la connexion à l'API de Proxmox
provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = "admin-api@pam!upload=${var.proxmox_api_token_secret}"
  insecure  = true
}
