terraform {
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