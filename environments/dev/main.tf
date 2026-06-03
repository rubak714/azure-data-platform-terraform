# Dev environment entry point for BarTech Versicherung GmbH data platform
# This file wires all four modules together in the correct dependency order
#
# Dependency order:
# 1. networking  - must exist first, everything depends on the VNet
# 2. storage     - independent of networking, can run in parallel
# 3. keyvault    - independent of networking, can run in parallel
# 4. databricks  - depends on networking module outputs for VNet injection

module "networking" {
  source = "../../modules/networking"

  resource_group_name   = var.resource_group_name
  location              = var.location
  vnet_name             = var.vnet_name
  vnet_address_space    = var.vnet_address_space
  subnet_public_name    = var.subnet_public_name
  subnet_private_name   = var.subnet_private_name
  subnet_public_prefix  = var.subnet_public_prefix
  subnet_private_prefix = var.subnet_private_prefix
  nsg_name              = var.nsg_name
  tags                  = var.tags
}

module "storage" {
  source = "../../modules/storage"

  resource_group_name      = module.networking.resource_group_name
  location                 = var.location
  storage_account_name     = var.storage_account_name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  cool_tier_after_days     = 30
  tags                     = var.tags
}

module "keyvault" {
  source = "../../modules/keyvault"

  resource_group_name        = module.networking.resource_group_name
  location                   = var.location
  key_vault_name             = var.key_vault_name
  tenant_id                  = var.tenant_id
  admin_object_id            = var.admin_object_id
  soft_delete_retention_days = 90
  tags                       = var.tags
}

module "databricks" {
  source = "../../modules/databricks"

  resource_group_name               = module.networking.resource_group_name
  location                          = var.location
  workspace_name                    = var.workspace_name
  sku                               = "trial"
  vnet_id                           = module.networking.vnet_id
  public_subnet_name                = var.subnet_public_name
  private_subnet_name               = var.subnet_private_name
  public_subnet_nsg_association_id  = module.networking.nsg_id
  private_subnet_nsg_association_id = module.networking.nsg_id
  tags                              = var.tags

  depends_on = [
    module.networking
  ]
}