terraform {
  required_version = ">= 1.5.0"
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-eus-01"
    storage_account_name = "strtfstateeusbs001"
    container_name       = "tfstate-container"
    key                  = "lz-test.tfstate"
    use_azuread_auth     = true
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.14.0"
    }
  }
}

#####Configure the Azure Provider ####
provider "azurerm" {
  features {}
  storage_use_azuread = true
}