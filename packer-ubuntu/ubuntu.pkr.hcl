packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.3"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

// Variables pour tes informations personnelles
variable "proxmox_api_url" {
  type    = string
  default = "https://192.168.2.3:8006/api2/json"
}

variable "proxmox_api_token_id" {
  type    = string
  default = "admin-api@pam!upload"
}

variable "proxmox_api_token_secret" {
  type      = string
  sensitive = true
}

// Définition de la source (comment construire l'image)
source "proxmox-iso" "ubuntu-server" {
  // Connexion à Proxmox
  proxmox_url              = var.proxmox_api_url
  username                 = var.proxmox_api_token_id
  token                    = var.proxmox_api_token_secret
  insecure_skip_tls_verify = true

  // Configuration de la VM de base
  node         = "iLO"
  
  // Use the new boot_iso block instead of deprecated iso_file
  boot_iso {
    iso_file     = "local:iso/ubuntu-22.04.5-live-server-amd64.iso"
    unmount      = true
  }

  // Configuration de l'installation automatisée (via cloud-init)
  http_directory = "http"
boot_command = [
  "<wait10s>",
  "<esc><wait>",
  "e<wait2s>",
  "<down><down><down><end><wait>",
  "<left><left><left><left><wait>",
  "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ",
  "<wait10s>",
  "<f10>" 
]
  boot_wait = "10s"  // Increased wait time

  // SSH pour que Packer se connecte et configure la VM
  ssh_username = "ubuntu"
  ssh_password = "packer"
  ssh_timeout  = "30m"  // Increased timeout
  ssh_handshake_attempts = 10

  // Spécifications de la VM
  qemu_agent      = true
  cores           = 2
  memory          = 2048
  scsi_controller = "virtio-scsi-pci"
  cloud_init      = true
  cloud_init_storage_pool = "local-lvm"
  
  disks {
    type         = "scsi"
    disk_size    = "32G"
    storage_pool = "local-lvm"
  }
  
  network_adapters {
    model  = "virtio"
    bridge = "vmbr0"
  }

  // Conversion en Template
  template_name        = "ubuntu-2204-template"
  template_description = "Template Ubuntu 22.04 LTS généré par Packer"
}

// Tâche de construction
build {
  sources = ["source.proxmox-iso.ubuntu-server"]

  provisioner "shell-local" {
    inline = ["echo '--- Démarrage du build Packer ---'"]
  }

  // Si vous voulez voir l'IP, faites-le depuis la VM :
  provisioner "shell" {
    inline = [
      "echo '==> IP de la VM: '",
      "ip addr show | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}'"
    ]
  }
  // Attendre cloud-init et nettoyer
  provisioner "shell" {
    inline = [
      "echo '==> Attente de la fin de cloud-init...'",
      "sudo cloud-init status --wait",
      "echo '==> Cloud-init terminé.'",
      "echo '==> Nettoyage des configurations réseau cloud-init...'",
      "# Suppression avec vérification d'existence",
      "[ -f /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg ] && sudo rm -f /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg || echo 'Fichier 99-disable pas trouvé'",
      "[ -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg ] && sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg || echo 'Fichier subiquity pas trouvé'",
      "echo '==> Reset cloud-init pour les déploiements futurs...'",
      "sudo cloud-init clean --logs --machine-id",
      "echo '==> Préparation terminée, arrêt de la VM...'"
    ]
  }

  // Arrêt avec gestion propre
  provisioner "shell" {
    inline = [
      "echo '==> Arrêt de la VM dans 2 secondes...'",
      "sudo shutdown -h +2"
    ]
    expect_disconnect = true
    valid_exit_codes = [0, 2300218]  # Accepter les codes d'erreur de déconnexion
  }

  // Post-processeur pour attendre l'arrêt complet
  post-processor "shell-local" {
    inline = [
      "echo 'Attente de 10 secondes pour finalisation...'",
      "sleep 10"
    ]
  }
}
