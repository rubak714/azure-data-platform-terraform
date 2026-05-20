# Terraform configuration for the dev environment
# Declares required providers and remote state backend
#
# Remote state is stored in Azure Blob Storage so that:
# - State is not lost if the local machine is wiped
# - Multiple team members can work on the same infrastructure
# - CI/CD pipeline can access state during plan and apply

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
  }

  # Backend configuration for remote state storage
  # Storage account and container must exist before running terraform init
  # Create them manually once or via a bootstrap script
    backend "azurerm" {
    resource_group_name  = "rg-tfstate-dev-gwc-001"
    storage_account_name = "sttfstategwc2026"
    container_name       = "tfstate"
    key                  = "dataplatform.dev.tfstate"
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}