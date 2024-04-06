terraform {
  required_providers {
    azurerm = {
      source  = "Hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "Hashicorp/random"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

