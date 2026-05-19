# Example variable values for the dev environment
# Copy this file to terraform.tfvars and fill in your actual values
# Never commit terraform.tfvars to Git - it is in .gitignore

# Resource naming
# Storage account name must be globally unique, lowercase, 3-24 chars
# No hyphens allowed in storage account names
storage_account_name = "stdataplatformdevgwc001"

# Key Vault name must be globally unique, 3-24 chars
key_vault_name = "kv-dataplatform-dev-gwc-001"

# Azure AD tenant ID
# Find this in Azure Portal under Azure Active Directory > Overview
tenant_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

# Object ID of the admin user or service principal
# Find this in Azure Portal under Azure Active Directory > Users
# or run: az ad signed-in-user show --query id -o tsv
admin_object_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

# Optional overrides - defaults are set in variables.tf
# Uncomment and change if needed

# resource_group_name  = "rg-dataplatform-dev-gwc-001"
# location             = "germanywestcentral"
# workspace_name       = "dbw-dataplatform-dev-gwc-001"

# tags = {
#   environment = "dev"
#   project     = "data-platform"
#   managed_by  = "terraform"
#   company     = "bartech-versicherung"
# }