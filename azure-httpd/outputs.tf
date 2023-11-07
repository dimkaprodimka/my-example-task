output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}


output "azure_vm_name" {
  value = azurerm_linux_virtual_machine.vm.name
}

output "azure_vm_location" {
  value = azurerm_linux_virtual_machine.vm.location
}

output "vm_size" {
  value = azurerm_linux_virtual_machine.vm.size
}

output "azure_os_disk_name" {
  value = azurerm_linux_virtual_machine.vm.os_disk[*].name
}

output "public_ip_address" {
  #value = azurerm_public_ip.ip.ip_address
  value = azurerm_linux_virtual_machine.vm.public_ip_address
}

output "tls_private_key" {
  value     = data.tls_public_key.tls_ssh_public.private_key_pem
  sensitive = true
}





