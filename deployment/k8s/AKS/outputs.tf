resource "local_file" "kubeconfig" {
  depends_on   = [azurerm_kubernetes_cluster.aks_cluster]
  filename     = "kubeconfig"
  content      = azurerm_kubernetes_cluster.aks_cluster.kube_config_raw
}



output "db_name" {
  value = azurerm_postgresql_database.postgres_endpoint_aks.name
}

output "db_administrator_login" {
  value = azurerm_postgresql_server.postgres_endpoint_aks.administrator_login
}

output "postgres_server_name" {
  value = azurerm_postgresql_server.postgres_endpoint_aks.name
}
output "db_password" {
  value     = azurerm_postgresql_server.postgres_endpoint_aks.administrator_login_password
  sensitive = true
}