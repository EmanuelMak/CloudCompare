provider "azurerm" {
  features {}
}

resource "azurerm_kubernetes_cluster" "my_aks_cluster" {
  name                = "my-aks-cluster"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  dns_prefix          = "myakscluster"

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_resource_group" "example" {
  name     = "my-aks-resource-group"
  location = "East US" # Change this to your preferred Azure region
}

# Additional resources and configurations go here
