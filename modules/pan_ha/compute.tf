# Create the availability set
resource "azurerm_availability_set" "pan" {
  name                           = "pan_avset_${var.environment}"
  location                       = "${azurerm_resource_group.pan.location}" 
  resource_group_name            = "${azurerm_resource_group.pan.name}"
  platform_update_domain_count   = "5"
  platform_fault_domain_count    = "2"
  managed                        = true
  depends_on                     = ["azurerm_resource_group.pan"]
} 

# Create the virtual machine. Use the "count" variable to define how many
# to create.
resource "azurerm_virtual_machine" "pan" {
  count                 = "${var.azurerm_instances}"
  name                  = "pan_${count.index+1}_vm_${var.environment}"
  location              = "${azurerm_resource_group.pan.location}" 
  resource_group_name   = "${azurerm_resource_group.pan.name}"
  depends_on            = ["azurerm_resource_group.pan"]
  network_interface_ids = 
  [
    #"${element(azurerm_network_interface.diagnostic.*.id, count.index)}",
    "${element(azurerm_network_interface.untrust.*.id, count.index)}",
    "${element(azurerm_network_interface.trust.*.id, count.index)}",
    "${element(azurerm_network_interface.management.*.id, count.index)}",
  ]

  primary_network_interface_id    = "${element(azurerm_network_interface.management.*.id, count.index)}"
  vm_size                         = "${var.pan_vm_type}"
  availability_set_id             = "${azurerm_availability_set.pan.id}"
  
  storage_image_reference {
    publisher   = "${var.pan_publisher}"
    offer       = "${var.pan_offer}"
    sku         = "${var.pan_sku}"
    version     = "${var.pan_version}"
  }

  plan {
    name      = "${var.pan_plan_name}"
    product   = "${var.pan_plan_product}"
    publisher = "${var.pan_publisher}"
  }

  storage_os_disk {
    name              = "pan-vm-osdisk-${count.index+1}-${var.environment}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "StandardSSD_LRS"
    disk_size_gb      = "${var.pan_os_disk_size}"
  }

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true
  
  os_profile  {
    computer_name   = "pan-1000v-${count.index+1}-${var.environment}"
    admin_username  = "${var.azurerm_vm_admin_username}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.azurerm_vm_admin_username}/.ssh/authorized_keys"
      key_data = "${file("${var.azurerm_ssh_key_path}")}"
    }
  }

  provisioner "remote-exec" {

    connection {
      type        = "ssh"
      user        = "${var.azurerm_vm_admin_username}"
      private_key = "${file(var.azurerm_ssh_private_key_path)}"
    }
  }
}
