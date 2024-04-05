resource "azurerm_virtual_network" "VN" {
        name = "virtual network"
        location = resource_group_location.rg.location
        resource_group_name = resource_group_name.rg.name
        address_space = var.CIDR 
}

resource "azurerm_network_security_group" "NSG" {
    name = NSG
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    

    security_rule {
        name = "allow http"
        priority = 100
        direction = "inbound"
        access = "allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "80"
        destination_address_prefix = "*"

    }
     security_rule {
        name                       = "allow-https"
        priority                   = 101
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
  }
    security_rule {
        name                       = "allow-ssh"
        priority                   = 102
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = address_space.CIDR
        destination_address_prefix = "*"
  }
}
