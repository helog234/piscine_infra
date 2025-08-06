# terraform-proxmox/outputs.tf

output "ldap_server_ip" {
  description = "Adresse IP du serveur LDAP."
  # Accède à la première IP de la première interface
  value       = proxmox_virtual_environment_vm.ldap-server.ipv4_addresses[0][0]
}

output "desktop_vm_ip" {
  description = "Adresse IP de la VM Desktop."
  # Accède à la première IP de la première interface
  value       = proxmox_virtual_environment_vm.desktop-vm.ipv4_addresses[0][0]
}
