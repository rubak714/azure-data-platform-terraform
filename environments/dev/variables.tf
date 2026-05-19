# Input variables for the dev environment
# Actual values are passed in via terraform.tfvars or CI/CD pipeline secrets

variable "resource_group_name" {
  description = "Name of the main resource group for the data platform"
  type        = string
  default     = "rg-dataplatform-dev-gwc-001"
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "germanywestcentral"
}

variable "vnet_name" {
  description = "Name of the Virtual Network"
  type        = string
  default     = "vnet-dataplatform-dev-gwc-001"
}

variable "vnet_address_space" {
  description = "Address space for the Virtual Network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_public_name" {
  description = "Name of the Databricks public subnet"
  type        = string
  default     = "snet-dbx-public-001"
}

variable "subnet_private_name" {
  description = "Name of the Databricks private subnet"
  type        = string
  default     = "snet-dbx-private-001"
}

variable "subnet_public_prefix" {
  description = "Address prefix for the Databricks public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_private_prefix" {
  description = "Address prefix for the Databricks private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "nsg_name" {
  description = "Name of the Network Security Group"
  type        = string
  default     = "nsg-dataplatform-dev-001"
}

variable "storage_account_name" {
  description = "Name of the ADLS Gen2 storage account. Must be globally unique"
  type        = string
}

variable "key_vault_name" {
  description = "Name of the Key Vault. Must be globally unique"
  type        = string
}

variable "tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
}

variable "admin_object_id" {
  description = "Object ID of the admin user or service principal"
  type        = string
}

variable "workspace_name" {
  description = "Name of the Databricks workspace"
  type        = string
  default     = "dbw-dataplatform-dev-gwc-001"
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default = {
    environment = "dev"
    project     = "data-platform"
    managed_by  = "terraform"
    company     = "bartech-versicherung"
  }
}