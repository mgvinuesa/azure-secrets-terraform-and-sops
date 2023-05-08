terraform {
  
  backend "azurerm" {
    resource_group_name  = "<RESOURCE_GROUP_NAME>"
    storage_account_name = "<STORAGE_ACCOUNT_NAME>"
    container_name       = "<CONTAINER_NAME>"
    key                  = "sops.terraform.tfstate"
  }

  required_providers {
    sops = {
      source = "carlpett/sops"
      version = "0.7.2"
    }
  }
}


provider "azurerm" {
  features {}
}

provider "sops" {
}