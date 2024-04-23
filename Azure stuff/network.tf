resource "azurerm_virtual_network" "VN" {
  name                = "virtual_network"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.CIDR
}

resource "azurerm_network_security_group" "NSG" {
  name                = "NSG"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "allowhttp" {
  name                        = "allow-http"
  resource_group_name         = azurerm_network_security_group.NSG.resource_group_name
  network_security_group_name = azurerm_network_security_group.NSG.name
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"

}
resource "azurerm_network_security_rule" "allowhttps" {
  name                        = "allow-https"
  resource_group_name         = azurerm_network_security_group.NSG.resource_group_name
  network_security_group_name = azurerm_network_security_group.NSG.name
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"

}

resource "azurerm_network_security_rule" "allowssh" {
  name                        = "allow-ssh"
  resource_group_name         = azurerm_network_security_group.NSG.resource_group_name
  network_security_group_name = azurerm_network_security_group.NSG.name
  priority                    = 102
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}


resource "azurerm_subnet" "Websubnet" {
  name                 = "Websubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.VN.name
  address_prefixes     = ["192.168.0.0/26"]
}

resource "azurerm_subnet_network_security_group_association" "name" {
  network_security_group_id = azurerm_network_security_group.NSG.id
  subnet_id                 = azurerm_subnet.Websubnet.id
}

resource "azurerm_subnet" "Appsubnet" {
  name                 = "Appsubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.VN.name
  address_prefixes     = ["192.168.1.0/26"]


}

resource "azurerm_public_ip" "pubip" {
  name                = "Pubip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "eoghantestwebapp"
  sku_tier            = "Regional"

}

resource "azurerm_lb" "Front_lb" {
  name                = "Front_lb"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  frontend_ip_configuration {
    name                 = "Web_IP"
    public_ip_address_id = azurerm_public_ip.pubip.id
  }

}
resource "azurerm_lb_backend_address_pool" "Web_Pool" {
  name            = "Web_Pool"
  loadbalancer_id = azurerm_lb.Front_lb.id


}
resource "azurerm_lb_probe" "Frontlb_probe" {
  name            = "probe"
  loadbalancer_id = azurerm_lb.Front_lb.id
  port            = "80"
  request_path    = ""

}
resource "azurerm_lb_rule" "Front_lbrule" {
  name                           = "http"
  loadbalancer_id                = azurerm_lb.Front_lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "Web_IP"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.Web_Pool.id]
  probe_id                       = azurerm_lb_probe.Frontlb_probe.id
}
resource "azurerm_lb" "Back_lb" {
  name                = "Back_lb"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "App_IP"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.Websubnet.id
  }
}

resource "azurerm_lb_backend_address_pool" "App_Pool" {
  name            = "App_Pool"
  loadbalancer_id = azurerm_lb.Back_lb.id



}
resource "azurerm_lb_probe" "Back_lb_probe" {
  name            = "probe"
  loadbalancer_id = azurerm_lb.Back_lb.id
  port            = "80"
  request_path    = ""

}
resource "azurerm_lb_rule" "Back_lbrule" {
  name                           = "http"
  loadbalancer_id                = azurerm_lb.Back_lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "App_IP"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.App_Pool.id]
  probe_id                       = azurerm_lb_probe.Back_lb_probe.id
  disable_outbound_snat          = true

}
# Looked at the pricing of azure firewall - I will secure via another method
# resource "azurerm_firewall" "basic_firewall" {
#     name = "basic_firewall"
#     location = azurerm_resource_group.rg.location
#     resource_group_name = azurerm_resource_group.rg.name
#     sku_tier = "Basic"
#     sku_name = "AZFW_VNet"

#     ip_configuration {
#       name = "fwconfig"
#       subnet_id = azurerm_subnet.subnet.id
#       public_ip_address_id = azurerm_public_ip.pubip.id


#     }
# }

resource "azurerm_nat_gateway" "natg" {
  name                    = "nat_gateway"
  location                = azurerm_resource_group.rg.location
  resource_group_name     = azurerm_resource_group.rg.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = "5"
  zones                   = ["1"]

}

resource "azurerm_public_ip" "natgip" {
  name                = "natgip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1"]

}

resource "azurerm_nat_gateway_public_ip_association" "nat_pip_link" {
  public_ip_address_id = azurerm_public_ip.natgip.id
  nat_gateway_id       = azurerm_nat_gateway.natg.id

}
resource "azurerm_subnet_nat_gateway_association" "subnet_nat_link" {
  subnet_id      = azurerm_subnet.Websubnet.id
  nat_gateway_id = azurerm_nat_gateway.natg.id

}

resource "azurerm_network_interface" "WebNic" {
  name                = "WebNic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "Webconfig"
    subnet_id                     = azurerm_subnet.Websubnet.id
    private_ip_address_allocation = "Dynamic"
    primary                       = true

  }
}

resource "azurerm_network_interface" "AppNic" {
  name                = "AppNic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "Appconfig"
    subnet_id                     = azurerm_subnet.Appsubnet.id
    private_ip_address_allocation = "Dynamic"
    primary                       = true

  }

}

resource "azurerm_network_interface_backend_address_pool_association" "WebPoolLink" {
  network_interface_id    = azurerm_network_interface.WebNic.id
  ip_configuration_name   = "Webconfig"
  backend_address_pool_id = azurerm_lb_backend_address_pool.Web_Pool.id

}

resource "azurerm_network_interface_backend_address_pool_association" "APpPoolLink" {
  network_interface_id    = azurerm_network_interface.AppNic.id
  ip_configuration_name   = "Appconfig"
  backend_address_pool_id = azurerm_lb_backend_address_pool.App_Pool.id


}  