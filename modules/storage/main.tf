# Storage module for BarTech Versicherung GmbH data platform
# Provisions ADLS Gen2 storage account with lifecycle management
# This is the primary data lake layer for the Databricks workspace

resource "azurerm_storage_account" "main" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type

  # Enables hierarchical namespace which turns this into ADLS Gen2
  # Required for Databricks Unity Catalog and Delta Lake
  is_hns_enabled           = true

  # No public access - all access goes through private endpoints or
  # service principals with RBAC assignments
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = false

  blob_properties {
    delete_retention_policy {
      days = 7
    }
    container_delete_retention_policy {
      days = 7
    }
  }

  tags = var.tags
}

# Lifecycle policy to manage storage costs
# Moves blobs to cool tier after 30 days automatically
resource "azurerm_storage_management_policy" "main" {
  storage_account_id = azurerm_storage_account.main.id

  rule {
    name    = "move-to-cool-after-30-days"
    enabled = true

    filters {
      blob_types = ["blockBlob"]
    }

    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than = var.cool_tier_after_days
      }
    }
  }
}

# Three data zone containers following medallion architecture
# raw      = landing zone for unprocessed data
# processed = cleaned and transformed data
# curated  = business-ready data for analytics and ML

resource "azurerm_storage_container" "raw" {
  name                  = "raw"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "processed" {
  name                  = "processed"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "curated" {
  name                  = "curated"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}