#AZURE PROVIDER DECLERATION
provider "azurerm" {}

#GLOBAL SETTINGS
variable "location"                     {default = "East US"}
variable "pan_rg"                       {default = "pan_ha"}
variable "environment"                  {default = "lab"}

#PAN VM PARAMETERS
variable "azurerm_instances"            {default = "2"}
variable "azurerm_vm_admin_username"    {default = "panadmin"}
variable "pan_vm_type"                  {default = "Standard_D3_V2"}
variable "pan_vm_tier"                  {default = "Standard"}
variable "pan_publisher"                {default = "paloaltonetworks"}
variable "pan_offer"                    {default = "vmseries1"}
variable "pan_sku"                      {default = "bundle1"}
variable "pan_version"                  {default = "8.1.0"}
variable "pan_os_disk_size"             {default = "128"}
variable "pan_plan_name"                {default = "bundle1"}
variable "pan_plan_product"             {default = "vmseries1"}

#NETWORK PARAMETERS. CHANGE AS YOU WISH
variable "vnet_prefix"                  {default = "10.10.0.0/24"}
variable "summary_address_space"        {default = "10.10.0.0/24"}

#CONNECTION PARAMETERS
variable "azurerm_ssh_key_path"         {
  default     = "~/.ssh/id_rsa.pub"
  description = "Enter the path of the public key to be uploaded to the pans. (Ex. ~/.ssh/publickey.pub)"}
variable "azurerm_ssh_private_key_path" {
  default     = "~/.ssh/id_rsa"
  description = "Enter the path of the corresponding private key to be used by Ansible. (Ex. ~/.ssh/privatekey)"}

#PUBLIC IP ADDRESSES THAT WILL BE GIVEN ACCESS
variable "allowed_public_addresses"     {
  type        = "list"
  description = "The public IP addresses that will be allowed to SSH to the pans. Add and remove addresses to the list as neccesary"
  default     = ["204.101.39.202"]
}

locals{
  app_route_table = "app_route_table_${var.environment}"
}

module "pan_ha" {
  source = "modules/pan_ha"
  environment                   = "${var.environment}"
  azurerm_instances             = "${var.azurerm_instances}"
  azurerm_vm_admin_username     = "${var.azurerm_vm_admin_username}"
  azurerm_ssh_key_path          = "${var.azurerm_ssh_key_path}"
  azurerm_ssh_private_key_path  = "${var.azurerm_ssh_private_key_path}"
  location                      = "${var.location}"
  pan_rg                        = "${var.pan_rg}"
  vnet_prefix                   = "${var.vnet_prefix}"
  untrust_subnet                = "${local.untrust_subnet}"
  trust_subnet                  = "${local.trust_subnet}"
  management_subnet             = "${local.management_subnet}"
  pan_vm_type                   = "${var.pan_vm_type}"
  pan_vm_tier                   = "${var.pan_vm_tier}"
  pan_publisher                 = "${var.pan_publisher}"
  pan_offer                     = "${var.pan_offer}"
  pan_sku                       = "${var.pan_sku}"
  pan_version                   = "${var.pan_version}"
  pan_plan_name                 = "${var.pan_plan_name}"
  pan_plan_product              = "${var.pan_plan_product}"
  pan_os_disk_size              = "${var.pan_os_disk_size}"
  allowed_public_addresses      = "${var.allowed_public_addresses}"
  azure_gateway                 = "${local.azure_gateway}"
  pan_untrust_int_addresses     = "${local.pan_untrust_int_addresses}"
  pan_trust_int_addresses       = "${local.pan_trust_int_addresses}"
  pan_management_int_addresses  = "${local.pan_management_int_addresses}"
  summary_address_space         = "${var.summary_address_space}"
}