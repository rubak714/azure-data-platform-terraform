output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = azurerm_key_vault.main.id
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.main.name
}

output "key_vault_uri" {
  description = "URI of the Key Vault for accessing secrets"
  value       = azurerm_key_vault.main.vault_uri
}

output "databricks_token_secret_name" {
  description = "Name of the Databricks PAT token secret in Key Vault"
  value       = azurerm_key_vault_secret.databricks_token.name
}