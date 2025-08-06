resource "proxmox_virtual_environment_vm" "desktop-vm" {
  name      = "desktop-01"
  node_name = var.proxmox_node
  on_boot   = true

  clone {
    vm_id = var.template_id
    full  = true
  }

  agent {
    enabled = true
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 4096
  }

  disk {
    interface = "scsi0"
    size      = 32
  }

  boot_order = ["scsi0"]

  initialization {
    user_account {
      username = "ubuntu"
      keys     = [trimspace(file("~/.ssh/id_ed25519.pub"))]
    }
    ip_config {
      ipv4 {
        address = "192.168.2.31/24"
        gateway = "192.168.1.1"
      }
    }
  }

 provisioner "remote-exec" {
    inline = [
      "echo 'SSH is ready, waiting for cloud-init to finish...'",
      "sudo cloud-init status --wait",
      "echo 'Cloud-init finished!'"
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_ed25519")
      host        = self.ipv4_addresses[1][0]
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i ../ansible-ldap/inventory.ini ../ansible-ldap/client-ldap.yml"
  }
  
}
