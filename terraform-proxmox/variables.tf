# terraform-proxmox/variables.tf

variable "proxmox_api_token_secret" {
  type      = string
  sensitive = true
  description = "b8470799-7251-454b-940a-0ac64ee18d1d"
}

variable "proxmox_endpoint" {
  type        = string
  description = "L'URL de l'API de Proxmox."
  default     = "https://192.168.2.3:8006"
}

variable "proxmox_node" {
  type        = string
  description = "Le nom du nœud Proxmox où créer les VMs."
  default     = "iLO"
}

variable "template_id" {
  type        = number
  description = "L'ID du template de VM à cloner."
  default     = 101
}
