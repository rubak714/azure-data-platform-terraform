# Databricks module for BarTech Versicherung GmbH data platform
# Provisions the Databricks workspace with VNet injection
# VNet injection keeps all cluster traffic inside the private network

resource "azurerm_databricks_workspace" "main" {
  name                = var.workspace_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku

  # VNet injection configuration
  # This keeps Databricks cluster traffic inside our private network
  # instead of routing through Databricks-managed infrastructure
  custom_parameters {
    virtual_network_id                                   = var.vnet_id
    public_subnet_name                                   = var.public_subnet_name
    private_subnet_name                                  = var.private_subnet_name
    public_subnet_network_security_group_association_id  = var.public_subnet_nsg_association_id
    private_subnet_network_security_group_association_id = var.private_subnet_nsg_association_id

    # Disable public IP for worker nodes
    # All traffic goes through private endpoints
    no_public_ip = true
  }

  tags = var.tags
}