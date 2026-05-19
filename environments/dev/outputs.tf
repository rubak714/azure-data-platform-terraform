output "resource_group_name" {
  description = "Name of the provisioned resource group"
  value       = module.networking.resource_group_name
}

output "vnet_id" {
  description = "ID of the provisioned Virtual Network"
  value       = module.networking.vnet_id
}

output "vnet_name" {
  description = "Name of the provisioned Virtual Network"
  value       = module.networking.vnet_name
}

output "storage_account_name" {
  description = "Name of the ADLS Gen2 storage account"
  value       = module.storage.storage_account_name
}

output "storage_account_dfs_endpoint" {
  description = "Primary DFS endpoint for ADLS Gen2 access"
  value       = module.storage.storage_account_primary_dfs_endpoint
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = module.keyvault.key_vault_name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = module.keyvault.key_vault_uri
}

output "databricks_workspace_url" {
  description = "URL of the Databricks workspace"
  value       = module.databricks.databricks_workspace_url
}

output "databricks_workspace_id" {
  description = "ID of the Databricks workspace"
  value       = module.databricks.databricks_workspace_id
}