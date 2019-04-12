output "pan_untrust_addresses" {
  value = "${data.azurerm_public_ip.untrust.*.ip_address}"
}

output "pan_management_addresses" {
  value = "${data.azurerm_public_ip.management.*.ip_address}"
}