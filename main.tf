terraform {
    required_providers {
        azurerm ={
            source = "Hashicorpe/azurerm"
            version = 3.97
        }
    }
}

provider "azurerm" {
    features {}
}

