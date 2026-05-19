# Key Vault module for BarTech Versicherung GmbH data platform
# Handles all secrets and credentials for the platform
# Uses RBAC authorization mode instead of legacy access policies

resource "azurerm_key_vault" "main" {
  name                       = var.key_vault_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = var.tenant_id
  sku_name                   = var.sku_name

  # RBAC mode means access is controlled via Azure role assignments
  # instead of Key Vault access policies. This is the modern approach
  # and integrates cleanly with Azure AD and least privilege principles.
  enable_rbac_authorization  = true

  # Soft delete protects against accidental deletion
  # Once enabled this cannot be disabled
  soft_delete_retention_days = var.soft_delete_retention_days

  # Purge protection prevents permanent deletion during retention period
  # Important for production environments handling sensitive credentials
  purge_protection_enabled   = false

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }

  tags = var.tags
}

# Grant the admin user or service principal full Key Vault admin rights
# This allows managing secrets, keys, and certificates
resource "azurerm_role_assignment" "key_vault_admin" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = var.admin_object_id
}

# Databricks token stored as a secret
# Value is set to a placeholder here and updated manually after
# Databricks workspace is provisioned
resource "azurerm_key_vault_secret" "databricks_token" {
  name         = "databricks-pat-token"
  value        = "placeholder-update-after-databricks-provisioning"
  key_vault_id = azurerm_key_vault.main.id

  tags = var.tags

  depends_on = [
    azurerm_role_assignment.key_vault_admin
  ]
}