# Generate a random id for the storage account due to the need to be unique across azure.
resource "random_id" "storage_account" {
  prefix      = "storagepan${var.environment}"
  byte_length = "2"
}

# Create the storage account
resource "azurerm_storage_account" "pan" {
  name                     = "${lower(random_id.storage_account.hex)}"
  resource_group_name      = "${azurerm_resource_group.pan.name}"
  location                 = "${azurerm_resource_group.pan.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  depends_on               = ["azurerm_resource_group.pan"]
}

# Create the storage account container
resource "azurerm_storage_container" "pan" {
  name                      = "pan-${var.environment}"
  resource_group_name       = "${azurerm_resource_group.pan.name}"
  storage_account_name      = "${azurerm_storage_account.pan.name}"
  container_access_type     = "private" 
  depends_on                = ["azurerm_resource_group.pan"]
}