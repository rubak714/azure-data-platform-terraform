variable "resource_group_name" {
  description = "Name of the resource group where Databricks will be created"
  type        = string
}

variable "location" {
  description = "Azure region where Databricks will be deployed"
  type        = string
  default     = "germanywestcentral"
}

variable "workspace_name" {
  description = "Name of the Databricks workspace"
  type        = string
}

variable "sku" {
  description = "SKU tier for Databricks workspace. Standard, Premium or Trial"
  type        = string
  default     = "standard"
}

variable "vnet_id" {
  description = "ID of the Virtual Network for VNet injection"
  type        = string
}

variable "public_subnet_name" {
  description = "Name of the public subnet for Databricks"
  type        = string
}

variable "private_subnet_name" {
  description = "Name of the private subnet for Databricks"
  type        = string
}

variable "public_subnet_nsg_association_id" {
  description = "ID of the NSG association for the public subnet"
  type        = string
}

variable "private_subnet_nsg_association_id" {
  description = "ID of the NSG association for the private subnet"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}