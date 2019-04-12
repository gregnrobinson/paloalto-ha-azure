variable "azurerm_instances"            {}
variable "azurerm_vm_admin_username"    {}
variable "azurerm_ssh_key_path"         {}
variable "azurerm_ssh_private_key_path" {}
variable "location"                     {}
variable "pan_rg"                       {}
variable "vnet_prefix"                  {}
variable "untrust_subnet"               {}
variable "trust_subnet"                 {}
variable "management_subnet"            {}
variable "pan_vm_type"                  {}
variable "pan_vm_tier"                  {}
variable "pan_publisher"                {}
variable "pan_offer"                    {}
variable "pan_sku"                      {}
variable "pan_version"                  {}
variable "pan_os_disk_size"             {}
variable "pan_plan_name"                {}
variable "pan_plan_product"             {}
variable "azure_gateway"                {}
variable "summary_address_space"        {}
variable "environment"                  {}
variable "pan_untrust_int_addresses"    {type = "list"}
variable "pan_trust_int_addresses"      {type = "list"}
variable "pan_management_int_addresses" {type = "list"}
variable "allowed_public_addresses"     {type = "list"}