provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "func_rg" {
  name     = "java-functions-group"
  location = "westus"
}

resource "azurerm_storage_account" "funcstore" {
  name                     = "camelcasefuncstore"
  resource_group_name      = azurerm_resource_group.func_rg.name
  location                 = azurerm_resource_group.func_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "funcplan" {
  name                = "java-functions-app-service-plan"
  location            = azurerm_resource_group.func_rg.location
  resource_group_name = azurerm_resource_group.func_rg.name

  # Tier and Size depends on requirements
  # Change to premium, standard, etc. based on need
  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "funcapp" {
  name                       = "camelcaseazurefunc-20230817224503699"
  location                   = azurerm_resource_group.func_rg.location
  resource_group_name        = azurerm_resource_group.func_rg.name
  app_service_plan_id        = azurerm_app_service_plan.funcplan.id
  storage_account_name       = azurerm_storage_account.funcstore.name
  storage_account_access_key = azurerm_storage_account.funcstore.primary_access_key
  os_type                    = "linux"
  
  app_settings = {
    FUNCTIONS_EXTENSION_VERSION = "~4"
  }

  site_config {
    dotnet_framework_version = "v5.0"
    java_version             = "1.8" # Azure Functions currently supports Java 8
  }
}
