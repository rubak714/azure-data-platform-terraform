variable "resource_group_name" {
  description = "Name of the resource group where Key Vault will be created"
  type        = string
}

variable "location" {
  description = "Azure region where Key Vault will be deployed"
  type        = string
  default     = "germanywestcentral"
}

variable "key_vault_name" {
  description = "Name of the Key Vault. Must be globally unique, 3-24 characters"
  type        = string
}

variable "tenant_id" {
  description = "Azure AD tenant ID for Key Vault access policies"
  type        = string
}

variable "sku_name" {
  description = "SKU tier for Key Vault. Standard is sufficient for secrets management"
  type        = string
  default     = "standard"
}

variable "soft_delete_retention_days" {
  description = "Number of days to retain soft deleted Key Vault and its contents"
  type        = number
  default     = 7
}

variable "admin_object_id" {
  description = "Object ID of the user or service principal that gets Key Vault admin rights"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}