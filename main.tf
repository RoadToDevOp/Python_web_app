terraform {
    required_providers {
        azurerm ={
            source = "Hashicorp/azurerm"
            version = "~>3.0"
        }
        random = {
            source = "Hashicorp/random"
            version = "~>3.0"
        }
    }
}

provider "azurerm" {
    features {}
}

resource "azurerm_resource_group" "rg" {
    name = var.resource_group_name
    location = var.resource_group_location
}


# resource "azurerm_virtual_machine" "webvm" {
#     name = var.web_vm_name
#     location = local.resource_group_location.rg
#     resource_group_name = local.resource_group_name.rg
#     vm_size = 
#     network_interface_ids = [  ]
#     storage_os_disk {
#       name =
#       create_option =
      
#     }
# }

# resource "azurerm_virtual_machine" "appvm" {
#     name = 
#     location = var.resource_group_location.rg
#     resource_group_name = resource_group_name.rg
# }

# resource "azurerm_lb" "Primary_lb" {
#     resource_group_name = resource_group_name.rg
#     location = resource_group_location.rg
#     name = "primary_lb"
# }