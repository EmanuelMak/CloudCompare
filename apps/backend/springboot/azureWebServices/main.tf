terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.52.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "=0.4.0"
    }
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "azure-web-apps-rg"
  location = "Germany West Central"
}

resource "azurerm_container_registry" "acr" {
  name                = "azure-web-apps-acr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Premium"
  admin_enabled       = false

  identity {
    type = "SystemAssigned"
  }

  georeplications {
    location                = "Australia Southeast"
    zone_redundancy_enabled = true
    tags                    = {}
  }
  georeplications {
    location                = "Australia Central"
    zone_redundancy_enabled = true
    tags                    = {}
  }
}