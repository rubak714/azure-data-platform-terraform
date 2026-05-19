variable "resource_group_name" {
  description = "Name of the resource group where storage will be created"
  type        = string
}

variable "location" {
  description = "Azure region where storage will be deployed"
  type        = string
  default     = "germanywestcentral"
}

variable "storage_account_name" {
  description = "Name of the storage account. Must be globally unique, lowercase, 3-24 characters"
  type        = string
}

variable "account_tier" {
  description = "Storage account tier"
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "Storage account replication type"
  type        = string
  default     = "LRS"
}

variable "cool_tier_after_days" {
  description = "Number of days after which blobs are moved to cool tier"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}