output "storage_account_id" {
  description = "ID of the storage account"
  value       = azurerm_storage_account.main.id
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.main.name
}

output "storage_account_primary_dfs_endpoint" {
  description = "Primary DFS endpoint for ADLS Gen2 access"
  value       = azurerm_storage_account.main.primary_dfs_endpoint
}

output "container_raw_name" {
  description = "Name of the raw data container"
  value       = azurerm_storage_container.raw.name
}

output "container_processed_name" {
  description = "Name of the processed data container"
  value       = azurerm_storage_container.processed.name
}

output "container_curated_name" {
  description = "Name of the curated data container"
  value       = azurerm_storage_container.curated.name
}