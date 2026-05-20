# Deployment Guide

This guide covers every command needed to go from zero to a fully
provisioned Azure data platform. Written from real experience building
this project, including the errors that came up and how they were fixed.

Every command is shown in both PowerShell and Git Bash where they differ.

---

## Prerequisites

Before starting, make sure these tools are installed:

- Terraform >= 1.5: https://developer.hashicorp.com/terraform/install
- Azure CLI: https://learn.microsoft.com/en-us/cli/azure/install-azure-cli
- Git: https://git-scm.com/downloads
- An Azure subscription with sufficient permissions

---

## Step 1: Clone the repository

Git Bash and PowerShell:

    git clone https://github.com/rubak714/azure-data-platform-terraform.git
    cd azure-data-platform-terraform

---

## Step 2: Authenticate with Azure

Git Bash and PowerShell:

    az login --use-device-code

This shows a code and a URL. Go to the URL in your browser, enter
the code, and sign in with your Azure account.

Verify the correct subscription is active:

    az account show

Note down the id (subscription ID) and tenantId from the output.
You will need both in the next steps.

If you have multiple subscriptions, set the correct one:

    PowerShell:
    az account set --subscription "YOUR_SUBSCRIPTION_ID"

    Git Bash:
    az account set --subscription "YOUR_SUBSCRIPTION_ID"

---

## Step 3: Register required resource providers

Terraform needs these providers registered on your subscription.
Register them manually to avoid auto-registration failures.

Git Bash and PowerShell:

    az provider register --namespace Microsoft.Databricks
    az provider register --namespace Microsoft.Storage
    az provider register --namespace Microsoft.KeyVault
    az provider register --namespace Microsoft.Network

Note: Auto-registration was disabled in the provider block after
hitting connection reset errors during the first terraform plan run.
The error looked like this:

    registering resource provider "Microsoft.Cdn": HTTP response
    was nil; connection may have been reset

See TROUBLESHOOTING.md Issue 6 for full details.

---

## Step 4: Create a service principal

Terraform needs a service principal to authenticate to Azure.

Important: Use PowerShell for this command, not Git Bash.
Git Bash converts the subscription scope path to a local file
path which causes a MissingSubscription error.

PowerShell:

    az ad sp create-for-rbac --name "sp-dataplatform-terraform-dev" --role "Contributor" --scopes "/subscriptions/YOUR_SUBSCRIPTION_ID"

The output will show four values. Note them down:

    appId    = this is ARM_CLIENT_ID
    password = this is ARM_CLIENT_SECRET
    tenant   = this is ARM_TENANT_ID
    your subscription ID from Step 2 = ARM_SUBSCRIPTION_ID

Also assign the Storage Blob Data Contributor role.
The Contributor role alone is not enough to create storage
containers in AzureRM v4.

PowerShell:

    az role assignment create --assignee "YOUR_APP_ID" --role "Storage Blob Data Contributor" --scope "/subscriptions/YOUR_SUBSCRIPTION_ID"

Note: This was discovered during terraform apply when all three
storage containers failed with 403 unauthorized errors. The error
looked like this:

    unexpected status 403 This request is not authorized to perform
    this operation. AuthorizationFailure on container "raw"

See TROUBLESHOOTING.md Issue 9 for full details.

---

## Step 5: Add GitHub repository secrets

Go to your GitHub repository and navigate to:
Settings > Secrets and variables > Actions > New repository secret

Add these four secrets one by one:

    ARM_CLIENT_ID      = appId from Step 4
    ARM_CLIENT_SECRET  = password from Step 4
    ARM_TENANT_ID      = tenant from Step 4
    ARM_SUBSCRIPTION_ID = your subscription ID

These are used by the GitHub Actions pipeline to authenticate
to Azure during plan and apply runs.

---

## Step 6: Create remote state storage

Terraform state must be stored remotely so the GitHub Actions
pipeline can access it. Create the state backend.

Important: Use PowerShell for these commands. Git Bash causes
SubscriptionNotFound errors on storage account commands.

PowerShell:

    az group create --name "rg-tfstate-dev-gwc-001" --location "germanywestcentral"

    az storage account create --name "YOUR_UNIQUE_STATE_STORAGE_NAME" --resource-group "rg-tfstate-dev-gwc-001" --location "germanywestcentral" --sku "Standard_LRS" --kind "StorageV2"

    az storage container create --name "tfstate" --account-name "YOUR_UNIQUE_STATE_STORAGE_NAME" --auth-mode login

Important: Storage account names must be globally unique across all
of Azure. The original name sttfstatedevgwc001 was taken so this
project used sttfstategwc2026. Choose something unique with lowercase
letters and numbers only, no hyphens, 3-24 characters.

Then update environments/dev/terraform.tf with your storage account
name in the backend block:

    backend "azurerm" {
      resource_group_name  = "rg-tfstate-dev-gwc-001"
      storage_account_name = "YOUR_UNIQUE_STATE_STORAGE_NAME"
      container_name       = "tfstate"
      key                  = "dataplatform.dev.tfstate"
    }

Critical warning: Keep the state storage account in a separate
resource group from the platform resources. Never put it in
rg-dataplatform-dev-gwc-001. If you run terraform destroy it
will delete everything in that group including the state file.
See TROUBLESHOOTING.md Issue 11 for what happens when this goes wrong.

---

## Step 7: Configure your variables

Git Bash:

    cd environments/dev
    cp example.tfvars terraform.tfvars

PowerShell:

    cd environments/dev
    Copy-Item example.tfvars terraform.tfvars

Open terraform.tfvars in any text editor and fill in your values:

    storage_account_name = "your-globally-unique-storage-name"
    key_vault_name       = "your-globally-unique-keyvault-name"
    tenant_id            = "your-tenant-id-from-step-2"
    admin_object_id      = "your-personal-object-id"

To get your personal object ID:

Git Bash and PowerShell:

    az ad signed-in-user show --query id -o tsv

Note: Both storage account and Key Vault names must be globally
unique. Common names like stdataplatformdev001 and
kv-dataplatform-dev-001 may already be taken. If terraform apply
fails with StorageAccountAlreadyTaken or VaultAlreadyExists errors,
choose different names in terraform.tfvars and run apply again.

---

## Step 8: Initialize Terraform

Git Bash and PowerShell:

    terraform init

This connects Terraform to the remote state backend and downloads
the AzureRM provider v4. If you update the backend configuration
later run:

    terraform init -reconfigure

If you upgrade the provider version run:

    terraform init -upgrade

---

## Step 9: Preview the changes

Git Bash and PowerShell:

    terraform plan

This shows exactly what will be created without touching Azure.
Review the output carefully. You should see 16 resources to add
with no errors.

If you see errors at this stage check TROUBLESHOOTING.md for
the most common issues encountered during this build.

---

## Step 10: Apply

Git Bash and PowerShell:

    terraform apply

Type yes when prompted. The full provisioning takes around
10-15 minutes. The Databricks workspace takes the longest.

Expected output at the end:

    Apply complete! Resources: 16 added, 0 changed, 0 destroyed.

    Outputs:
    databricks_workspace_id  = "/subscriptions/.../workspaces/dbw-..."
    databricks_workspace_url = "adb-xxxx.azuredatabricks.net"
    key_vault_name           = "your-keyvault-name"
    key_vault_uri            = "https://your-keyvault.vault.azure.net/"
    resource_group_name      = "rg-dataplatform-dev-gwc-001"
    storage_account_name     = "your-storage-name"
    storage_account_dfs_endpoint = "https://your-storage.dfs.core.windows.net/"
    vnet_id                  = "/subscriptions/.../virtualNetworks/vnet-..."
    vnet_name                = "vnet-dataplatform-dev-gwc-001"

---

## Step 11: Verify on Azure portal

Go to https://portal.azure.com and open rg-dataplatform-dev-gwc-001.
You should see five resources:

    Azure Databricks workspace: dbw-dataplatform-dev-gwc-001
    Key Vault: your-keyvault-name
    Network Security Group: nsg-dataplatform-dev-001
    Storage account: your-storage-name
    Virtual Network: vnet-dataplatform-dev-gwc-001

Click on each one and verify:

Databricks workspace:
- Status shows Active
- VNet injection is configured
- Workspace URL matches the terraform output

Storage account:
- Hierarchical namespace is enabled (ADLS Gen2)
- Three containers exist: raw, processed, curated

Key Vault:
- Permission model shows Azure role-based access control
- Soft delete shows enabled

Virtual Network:
- Two subnets exist with the correct address prefixes
- Both subnets show service delegation to Microsoft.Databricks/workspaces

---

## Step 12: Destroy when done

To avoid ongoing cost, destroy all resources when finished.

Git Bash and PowerShell:

    terraform destroy

Type yes when prompted.

If destroy fails with this error:

    NetworkSecurityGroupCannotBeRemovedDueToNipOnSubnet: Network
    security group cannot be removed from subnet because it has
    network intent policy applied.

This happens when Databricks applies NetworkIntentPolicy to the
subnets which blocks NSG removal via Terraform. In this case
delete the resource group manually from the Azure portal:

1. Go to https://portal.azure.com
2. Open rg-dataplatform-dev-gwc-001
3. Click Delete resource group
4. Type the name to confirm
5. Click Delete

After deletion, also delete the auto-created Databricks managed
resource group. It will be named something like:
databricks-rg-rg-dataplatform-dev-gwc-001

The state storage group rg-tfstate-dev-gwc-001 should remain
so you can redeploy later without bootstrapping again.

See TROUBLESHOOTING.md Issue 11 for the full story of what
happened during this build when destroy failed.

---

## Full error reference

All errors encountered during this build are documented in
docs/TROUBLESHOOTING.md with exact error messages, root causes,
and fixes applied. Quick reference:

    Issue 1:  Storage container attribute error (provider version)
    Issue 2:  Databricks output attribute does not exist
    Issue 3:  GitHub Actions pipeline missing after merge
    Issue 4:  Subnet delegation missing for Databricks VNet injection
    Issue 5:  variable.tf filename typo in storage module
    Issue 6:  Resource provider registration connection reset
    Issue 7:  Databricks Standard SKU deprecated
    Issue 8:  NSG conflicts with Databricks NetworkIntentPolicy
    Issue 9:  Storage containers 403 unauthorized
    Issue 10: Databricks workspace dependency ordering
    Issue 11: State backend lost during failed destroy