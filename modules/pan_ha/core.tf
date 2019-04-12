#Resource Group
resource "azurerm_resource_group" "pan" {
  name     = "${var.pan_rg}_${var.environment}"
  location = "${var.location}"
}

#GENERATING NETWORK VALUES FROM THE VNET PREFIX
locals {
  untrust_subnet          = "${cidrsubnet(var.vnet_prefix, 3, 0)}"
  trust_subnet           = "${cidrsubnet(var.vnet_prefix, 3, 1)}"
  management_subnet       = "${cidrsubnet(var.vnet_prefix, 3, 2)}"
  diagnostic_subnet       = "${cidrsubnet(var.vnet_prefix, 3, 3)}"
  app_1_subnet            = "${cidrsubnet(var.vnet_prefix, 3, 4)}"
  app_2_subnet            = "${cidrsubnet(var.vnet_prefix, 3, 5)}"
  gateway_subnet_prefix   = "${cidrsubnet(var.vnet_prefix, 3, 7)}"
  azure_gateway           = "${cidrhost(local.untrust_subnet, 1)}"
}

# Create a virtual network in the resource group
resource "azurerm_virtual_network" "pan" {
  name                 = "pan_pan_vnet_${var.environment}"
  address_space        = ["${var.vnet_prefix}"]
  location             = "${azurerm_resource_group.pan.location}"
  resource_group_name  = "${azurerm_resource_group.pan.name}"
  depends_on           = ["azurerm_resource_group.pan"]
}

#SUBNETS
resource "azurerm_subnet" "untrust" {
  name                       = "pan_untrust_subnet_${var.environment}"
  resource_group_name        = "${azurerm_resource_group.pan.name}"
  virtual_network_name       = "${azurerm_virtual_network.pan.name}"
  address_prefix             = "${local.untrust_subnet}"
  route_table_id             = "${azurerm_route_table.untrust.id}"
  network_security_group_id = "${azurerm_network_security_group.pan.id}"
  depends_on                 = ["azurerm_resource_group.pan"]
}

resource "azurerm_subnet" "trust" {
  name                 = "pan_trust_subnet_${var.environment}"
  resource_group_name  = "${azurerm_resource_group.pan.name}"
  virtual_network_name = "${azurerm_virtual_network.pan.name}"
  address_prefix       = "${local.trust_subnet}"
  route_table_id       = "${azurerm_route_table.trust.id}"
  depends_on           = ["azurerm_resource_group.pan"]
}

resource "azurerm_subnet" "management" {
  name                 = "pan_management_subnet_${var.environment}"
  resource_group_name  = "${azurerm_resource_group.pan.name}"
  virtual_network_name = "${azurerm_virtual_network.pan.name}"
  address_prefix       = "${local.management_subnet}"
  route_table_id       = "${azurerm_route_table.management.id}"
  network_security_group_id = "${azurerm_network_security_group.pan.id}"
  depends_on           = ["azurerm_resource_group.pan"]
}


#untrust Route Table
resource "azurerm_route_table" "untrust" {
  name                = "pan_untrust_rt_${var.environment}"
  location            = "${azurerm_resource_group.pan.location}"
  resource_group_name = "${azurerm_resource_group.pan.name}"
  depends_on          = ["azurerm_resource_group.pan"]
}

#trust Route Table
resource "azurerm_route_table" "trust" {
  name                = "pan_trust_rt_${var.environment}"
  location            = "${azurerm_resource_group.pan.location}"
  resource_group_name = "${azurerm_resource_group.pan.name}"
  depends_on          = ["azurerm_resource_group.pan"]
}

#trust Route Table
resource "azurerm_route_table" "management" {
  name                = "pan_management_rt_${var.environment}"
  location            = "${azurerm_resource_group.pan.location}"
  resource_group_name = "${azurerm_resource_group.pan.name}"
  depends_on          = ["azurerm_resource_group.pan"]
}


#untrust Network Security Groups
resource "azurerm_network_security_group" "pan" {
  name                = "pan_untrust_nsg_${var.environment}"
  resource_group_name = "${azurerm_resource_group.pan.name}"
  location            = "${azurerm_resource_group.pan.location}"
  depends_on          = ["azurerm_resource_group.pan"]

    security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = ["${var.allowed_public_addresses}"]
    destination_address_prefix = "VirtualNetwork"
  }

    security_rule {
    name                       = "FMC_Management"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8305"
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
  }
}


resource "azurerm_subnet_network_security_group_association" "untrust" {
  subnet_id                 = "${azurerm_subnet.untrust.id}"
  network_security_group_id = "${azurerm_network_security_group.pan.id}"
}

resource "azurerm_subnet_network_security_group_association" "management" {
  subnet_id                 = "${azurerm_subnet.management.id}"
  network_security_group_id = "${azurerm_network_security_group.pan.id}"
}


#Retrieve untrust IP addresses for outputs
data "azurerm_public_ip" "management" {
  count                         = "${var.azurerm_instances}"
  name                          = "pan_${count.index+1}_management_ip_${var.environment}"
  resource_group_name           = "${azurerm_resource_group.pan.name}"
  depends_on                    = ["azurerm_virtual_machine.pan"]
}

data "azurerm_public_ip" "untrust" {
  count                         = "${var.azurerm_instances}"
  name                          = "pan_${count.index+1}_untrust_ip_${var.environment}"
  resource_group_name           = "${azurerm_resource_group.pan.name}"
  depends_on                    = ["azurerm_virtual_machine.pan"]
}

# PUBLIC IP ADDRESSES
resource "azurerm_public_ip" "management" {
  count                         = "${var.azurerm_instances}"
  name                          = "pan_${count.index+1}_management_ip_${var.environment}"
  resource_group_name           = "${azurerm_resource_group.pan.name}"
  location                      = "${azurerm_resource_group.pan.location}"
  public_ip_address_allocation  = "static"
  sku                           = "Standard"
  depends_on                    = ["azurerm_resource_group.pan"]
}

resource "azurerm_public_ip" "untrust" {
  count                         = "${var.azurerm_instances}"
  name                          = "pan_${count.index+1}_untrust_ip_${var.environment}"
  resource_group_name           = "${azurerm_resource_group.pan.name}"
  location                      = "${azurerm_resource_group.pan.location}"
  public_ip_address_allocation  = "static"
  sku                           = "Standard"
  depends_on                    = ["azurerm_resource_group.pan"]
}

resource "azurerm_public_ip" "elb" {
  name                          = "pan_lb_ip_${var.environment}"
  resource_group_name           = "${azurerm_resource_group.pan.name}"
  location                      = "${azurerm_resource_group.pan.location}"
  allocation_method             = "Static"
  sku                           = "Standard"
  depends_on                    = ["azurerm_resource_group.pan"]
}


# untrust INTERFACE
resource "azurerm_network_interface" "untrust" {
  count                      = "${var.azurerm_instances}"
  name                       = "pan_${count.index+1}_untrust_nic_${var.environment}"
  resource_group_name        = "${azurerm_resource_group.pan.name}"
  location                   = "${azurerm_resource_group.pan.location}"
  #network_security_group_id  = "${element(azurerm_network_security_group.pan.*.id, count.index)}"
  enable_ip_forwarding       = "true"
  depends_on                 = ["azurerm_resource_group.pan"]
  
  ip_configuration {
    name                            = "pan-${count.index+1}-ip"
    subnet_id                       = "${azurerm_subnet.untrust.id}"
    private_ip_address_allocation   = "static"
    private_ip_address              = "${cidrhost(local.untrust_subnet, count.index+4)}"
    public_ip_address_id            = "${element(azurerm_public_ip.untrust.*.id, count.index)}"
  }
}

# trust INTERFACE
resource "azurerm_network_interface" "trust" {
  count                 = "${var.azurerm_instances}"
  name                  = "pan_${count.index+1}_trust_nic_${var.environment}"
  resource_group_name   = "${azurerm_resource_group.pan.name}"
  location              = "${azurerm_resource_group.pan.location}"
  enable_ip_forwarding  = "true"
  depends_on            = ["azurerm_resource_group.pan"]
  
  ip_configuration {
    name                            = "pan-${count.index+1}-ip"
    subnet_id                       = "${azurerm_subnet.trust.id}"
    private_ip_address_allocation   = "static"
    private_ip_address              = "${cidrhost(local.trust_subnet, count.index+4)}"
  }
}

# MANAGEMENT INTERFACE
resource "azurerm_network_interface" "management" {
  count                 = "${var.azurerm_instances}"
  name                  = "pan_${count.index+1}_management_nic_${var.environment}"
  resource_group_name   = "${azurerm_resource_group.pan.name}"
  location              = "${azurerm_resource_group.pan.location}"
  enable_ip_forwarding  = "true"
  depends_on            = ["azurerm_resource_group.pan"]
  
  ip_configuration {
    name                            = "pan-${count.index+1}-ip"
    subnet_id                       = "${azurerm_subnet.management.id}"
    private_ip_address_allocation   = "static"
    private_ip_address              = "${cidrhost(local.management_subnet, count.index+4)}"
    public_ip_address_id            = "${element(azurerm_public_ip.management.*.id, count.index)}"
  }
}


#CONFIGURE EXTERNAL LOAD BALANCER
resource "azurerm_lb" "external_lb" {
  name                  = "pan_external_lb_${var.environment}"
  resource_group_name   = "${azurerm_resource_group.pan.name}"
  location              = "${azurerm_resource_group.pan.location}"
  sku                   = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = "${azurerm_public_ip.elb.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "external_lb_pool" {
  resource_group_name = "${azurerm_resource_group.pan.name}"
  loadbalancer_id     = "${azurerm_lb.external_lb.id}"
  name                = "BackEndAddressPool"
}

resource "azurerm_network_interface_backend_address_pool_association" "external_backend_pool" {
  count                   = "${var.azurerm_instances}"
  network_interface_id    = "${element(azurerm_network_interface.untrust.*.id, count.index)}"
  ip_configuration_name   = "pan-${count.index+1}-ip"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.external_lb_pool.id}"
}

resource "azurerm_lb_probe" "external_ssh_probe" {
  resource_group_name = "${azurerm_resource_group.pan.name}"
  loadbalancer_id     = "${azurerm_lb.external_lb.id}"
  name                = "ssh-running-probe"
  port                = 22
}

resource "azurerm_lb_rule" "external_http_rule" {
  resource_group_name            = "${azurerm_resource_group.pan.name}"
  loadbalancer_id                = "${azurerm_lb.external_lb.id}"
  name                           = "ElbHTTP"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.external_lb_pool.id}"
  probe_id                       = "${azurerm_lb_probe.external_ssh_probe.id}"
}


#CONFIGURE INTERNAL LOAD BALANCER
resource "azurerm_lb" "internal_lb" {
  name                  = "pan_internal_lb_${var.environment}"
  resource_group_name   = "${azurerm_resource_group.pan.name}"
  location              = "${azurerm_resource_group.pan.location}"
  sku                   = "Standard"

  frontend_ip_configuration {
    name                          = "InternalIPAddress"
    subnet_id                     = "${azurerm_subnet.trust.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "${cidrhost(local.trust_subnet, count.index+28)}"
  }
}

resource "azurerm_lb_backend_address_pool" "internal_lb_pool" {
  resource_group_name = "${azurerm_resource_group.pan.name}"
  loadbalancer_id     = "${azurerm_lb.internal_lb.id}"
  name                = "BackEndAddressPool"
}

resource "azurerm_network_interface_backend_address_pool_association" "internal_backend_pool" {
  count                   = "${var.azurerm_instances}"
  network_interface_id    = "${element(azurerm_network_interface.trust.*.id, count.index)}"
  ip_configuration_name   = "pan-${count.index+1}-ip"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.internal_lb_pool.id}"
}

resource "azurerm_lb_probe" "internal_ssh_probe" {
  resource_group_name = "${azurerm_resource_group.pan.name}"
  loadbalancer_id     = "${azurerm_lb.internal_lb.id}"
  name                = "ssh-running-probe"
  port                = 22
}


resource "azurerm_lb_rule" "egress_all" {
  resource_group_name            = "${azurerm_resource_group.pan.name}"
  loadbalancer_id                = "${azurerm_lb.internal_lb.id}"
  name                           = "egress_all"
  protocol                       = "All"
  frontend_port                  = 0
  backend_port                   = 0
  frontend_ip_configuration_name = "InternalIPAddress"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.internal_lb_pool.id}"
  probe_id                       = "${azurerm_lb_probe.internal_ssh_probe.id}"
}