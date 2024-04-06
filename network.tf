resource "azurerm_virtual_network" "VN" {
        name = "virtual_network"
        location = azurerm_resource_group.rg.location
        resource_group_name = azurerm_resource_group.rg.name
        address_space = var.CIDR 
}

resource "azurerm_network_security_group" "NSG" {
    name = "NSG"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    

    security_rule {
        name = "allow-http"
        priority = 100
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "80"
        source_address_prefix = "*"
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
        source_address_prefix      = "*"
        destination_address_prefix = "*"
  }
}

resource "azurerm_subnet" "subnet" {
    name = "subnet"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.VN.name
    address_prefixes = ["192.168.0.0/26"]
}

resource "azurerm_subnet_network_security_group_association" "name" {
    network_security_group_id = azurerm_network_security_group.NSG.id
    subnet_id = azurerm_subnet.subnet.id
}

resource "azurerm_public_ip" "pubip" {
    name = "Pubip"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    allocation_method = "Static"
    sku = "Standard"
    domain_name_label = "eoghantestwebapp"
    sku_tier = "Regional"

}

resource "azurerm_lb" "Primary_lb" {
    name = "primary_lb"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    sku = "Standard"
    frontend_ip_configuration {
      name = "Web_IP"
      public_ip_address_id = azurerm_public_ip.pubip.id
    }

}
resource "azurerm_lb_backend_address_pool" "backendpool" {
    name = "backendpool"
    loadbalancer_id = azurerm_lb.Primary_lb.id

  
}

resource "azurerm_lb_rule" "lbule" {
    name = "http"
    loadbalancer_id = azurerm_lb.Primary_lb.id
    protocol = "Tcp"
    frontend_port = 80
    backend_port = 80
    frontend_ip_configuration_name = "Web_IP"
    backend_address_pool_ids = [azurerm_lb_backend_address_pool.backendpool.id]
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
    name = "nat_gateway"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    sku_name = "Standard"
    idle_timeout_in_minutes = "5"
    zones = ["1"]
  
}

resource "azurerm_public_ip" "natgip" {
    name = "nat_gateway_ip"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    allocation_method = "Static"
    sku = "Standard"
    zones = ["1"]

}

resource "azurerm_nat_gateway_public_ip_association" "nat_pip_link" {
    public_ip_address_id = azurerm_public_ip.natgip.id
    nat_gateway_id = azurerm_nat_gateway.natg.id
  
}
resource "azurerm_subnet_nat_gateway_association" "subnet_nat_link" {
        subnet_id = azurerm_subnet.subnet.id
        nat_gateway_id = azurerm_nat_gateway.natg.id
    
}