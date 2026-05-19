variable "resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
  default     = "germanywestcentral"
}

variable "vnet_name" {
  description = "Name of the Virtual Network"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the Virtual Network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_public_name" {
  description = "Name of the public subnet for Databricks"
  type        = string
  default     = "snet-dbx-public-001"
}

variable "subnet_private_name" {
  description = "Name of the private subnet for Databricks"
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

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}