terraform {
    required_providers {
        azurerm ={
            source = "Hashicorp/azurerm"
            version = "3.97"
        }
    }
}

provider "azurerm" {
    features {}
}

