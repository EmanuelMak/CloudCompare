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

locals {

  default_tags = {
    environment = "dev"
    owner       = "E.Mak"
    app         = "myapp"
  }

}

###################### credentials for login ######################
provider "azurerm" {
  features {}
  client_id       = var.AZURE_SERVICE_PRINCIPAL_APP_ID
  client_secret   = var.AZURE_SERVICE_PRINCIPAL_PASSWORD
  subscription_id = var.AZURE_ID
  tenant_id       = var.AZURE_TENANT_ID
}

###################### resource group whole setup resides in ######################
resource "azurerm_resource_group" "rg" {
  name     = "myResourceGroup" # Choose a meaningful name
  location = "Germany West Central"
}
###################### virtual network and subnets ######################

resource "azurerm_virtual_network" "vnet" {
  name                = "myVNet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "subnet2" {
  name                 = "subnet2"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

###################### workspace  and environment ######################

# Log Analytics Workspace for monitoring
resource "azurerm_log_analytics_workspace" "log_workspace" {
  name                = "myLogAnalyticsWorkspace"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
}

# Container App Environment
resource "azurerm_container_app_environment" "app_env" {
  name                       = "myContainerAppEnvironment"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_workspace.id
}

###################### container app defenitions using Azurerm ######################

# Docker Getting Started Container App
# resource "azurerm_container_app" "docker_hello_world" {
#   name                         = "docker-helloworld"
#   container_app_environment_id = azurerm_container_app_environment.app_env.id
#   resource_group_name          = azurerm_resource_group.rg.name
#   revision_mode                = "Single"

#   registry {
#     server               = "docker.io"
#     username             = "EmanuelMak"
#     password_secret_name = "docker-io-pass"
#   }

#   ingress {
#     allow_insecure_connections = true
#     external_enabled           = true
#     target_port                = 80
#     traffic_weight {
#       latest_revision = true  # see: https://github.com/hashicorp/terraform-provider-azurerm/issues/20435#issuecomment-1443418097
#       percentage = 100
#     }
#   }

#   template {
#     container {
#       name   = "docker-test"
#       image  = "docker/getting-started:latest"
#       cpu    = 0.25
#       memory = "0.5Gi"
#     }
#   }

#   secret { 
#     name  = "docker-io-pass" 
#     value = "TQU_kxk3ktz!tyv6qdx" 
#   }

#   tags = local.default_tags

# }

# using the azapi becaus azurerm does not support autoscaling for container apps yet (2023)
# and azureerm does not seem stable for container apps right now: https://github.com/hashicorp/terraform-provider-azurerm/issues/20435#issuecomment-1443418097
resource "azapi_resource" "containerapp-apache" {
  type      = "Microsoft.App/containerapps@2022-03-01"
  name      = "docker-helloworld"
  parent_id = azurerm_resource_group.rg.id
  location  = azurerm_resource_group.rg.location

  body = jsonencode({
    properties = {
      managedEnvironmentId = azurerm_container_app_environment.app_env.id
      configuration = {
        ingress = {
          external : true,
          allowInsecure : true,
          targetPort : 80
        },

      }
      template = {
        containers = [
          {
            image = "docker/getting-started:latest"
            name  = "getting-started"
            resources = {
              cpu    = 0.25
              memory = "0.5Gi"
            }
          }
        ]
        scale = {
          rules = [
            {
              name = "http-rule",
              http = {
                metadata = {
                  concurrentRequests = "10"
                }
              }
            }
          ]
        }
      }
    }

  })
  #  depends_on = [azapi_resource.containerapp-environment]
}

# # Spring Boot Container App
# resource "azurerm_container_app" "springboot_app" {
#   name                         = "springbootapp"
#   container_app_environment_id = azurerm_container_app_environment.app_env.id
#   resource_group_name          = azurerm_resource_group.rg.name
#   revision_mode                = "Single"

#   # Assuming you have your Spring Boot app in Docker Hub as well, adjust if different
#   registry {
#     server               = "docker.io"
#     username             = "dockerUser"  # Change this to your Docker Hub username
#     password_secret_name = "docker-io-pass-spring"
#   }

#   ingress {
#     allow_insecure_connections = true
#     external_enabled           = true
#     target_port                = 8080  # Assuming your Spring Boot app runs on port 8080 inside the container
#     traffic_weight {
#       percentage = 100
#     }
#   }

#   template {
#     container {
#       name   = "springboot-container"
#       image  = "YourDockerUsername/springboot-image:latest"  # Adjust this to your Spring Boot image path
#       cpu    = 0.25
#       memory = "0.5Gi"
#     }
#   }

#   secret {
#     name  = "docker-io-pass-spring"
#     value = "YourDockerPasswordForSpring"  # Change this to your Docker Hub password for the Spring Boot app repository
#   }
# }


###################### update services to autoscale based on number of incomming http requests ######################
# using the azapi becaus azurerm does not support autoscaling for container apps yet (2023)


