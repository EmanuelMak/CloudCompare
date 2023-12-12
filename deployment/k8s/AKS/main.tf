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

# Local variables
locals {
  default_tags = {
    environment = "dev"
    owner       = "E.Mak"
    app         = "myapp"
  }
}

# Azure provider configuration
provider "azurerm" {
  features {}
  client_id       = var.AZURE_SERVICE_PRINCIPAL_APP_ID
  client_secret   = var.AZURE_SERVICE_PRINCIPAL_PASSWORD
  subscription_id = var.AZURE_ID
  tenant_id       = var.AZURE_TENANT_ID
}

# Resource group
resource "azurerm_resource_group" "rg" {
  name     = "aksResourceGroup"
  location = "Germany West Central"
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "myVnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# AKS Subnet
resource "azurerm_subnet" "aks_subnet" {
  name                 = "aksSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "myAKSCluster"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "myAKSDNSPrefix"

  default_node_pool {
    name           = "default"
    node_count     = 2
    vm_size        = "Standard_D2_v2"
    vnet_subnet_id = azurerm_subnet.aks_subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    service_cidr   = "10.1.0.0/16"
    dns_service_ip = "10.1.0.10"
  }
}

# PostgreSQL Subnet
resource "azurerm_subnet" "postgres_subnet" {
  name                 = "postgresSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.3.0/24"]
  service_endpoints    = ["Microsoft.Sql"]
}

# PostgreSQL Network Security Group
resource "azurerm_network_security_group" "postgres_nsg" {
  name                = "my-postgres-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# PostgreSQL Security Rule
resource "azurerm_network_security_rule" "postgres_rule" {
  name                        = "postgresql"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "5432"
  source_address_prefix       = "10.0.0.0/16"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.postgres_nsg.name
}
# resource "azurerm_postgresql_firewall_rule" "allow_all" {
#   name                = "allow_all"
#   resource_group_name = azurerm_postgresql_server.postgres_endpoint_aks.resource_group_name
#   server_name         = azurerm_postgresql_server.postgres_endpoint_aks.name
#   start_ip_address    = "0.0.0.0"
#   end_ip_address      = "255.255.255.255"
#}

# Association of NSG with PostgreSQL Subnet
resource "azurerm_subnet_network_security_group_association" "postgres_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.postgres_subnet.id
  network_security_group_id = azurerm_network_security_group.postgres_nsg.id
}

# Azure PostgreSQL Server
resource "azurerm_postgresql_server" "postgres_endpoint_aks" {
  name                = "my-postgres-server"
 
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku_name = "GP_Gen5_4"

  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  administrator_login          = var.DB_USERNAME
  administrator_login_password = "H@Sh1CoR3!"
  version                      = "11"
  public_network_access_enabled = true
  ssl_enforcement_enabled     = false
  ssl_minimal_tls_version_enforced = "TLSEnforcementDisabled"

}
resource "azurerm_postgresql_database" "postgres_endpoint_aks" {
  name                = var.DB_NAME 
  resource_group_name = azurerm_postgresql_server.postgres_endpoint_aks.resource_group_name
  server_name         = azurerm_postgresql_server.postgres_endpoint_aks.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

# Outputst
output "aks_cluster_id" {
  value = azurerm_kubernetes_cluster.aks_cluster.id
}

output "postgres_endpoint" {
  value = azurerm_postgresql_server.postgres_endpoint_aks.fqdn
}


