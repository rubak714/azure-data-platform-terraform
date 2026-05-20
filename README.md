# Azure Data Platform: Terraform and GitHub Actions

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Last commit](https://img.shields.io/github/last-commit/rubak714/azure-data-platform-terraform)](https://github.com/rubak714/azure-data-platform-terraform/commits/main)
[![Issues](https://img.shields.io/github/issues/rubak714/azure-data-platform-terraform)](https://github.com/rubak714/azure-data-platform-terraform/issues)
[![Built with Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC?logo=terraform)](https://www.terraform.io/)

---

> A lot of cloud projects on GitHub are just portal screenshots with some notes underneath.
> This one is different.
> Every resource here is provisioned from code. Every change goes through a pipeline.
> Every error that came up during the entire process is documented.
> This is not a walkthrough of what **Terraform** can do. This is what actually happened when building **a real data platform on Azure** from scratch.

---

## ☁️ The scenario

☁️ **The company:** BarTech Versicherung GmbH. Fictional. Mid-size German insurer.
They are building a new data and AI platform on Azure and need a solid infrastructure foundation before any data pipelines or machine learning workloads can run on top of it.

☁️ **The task:** Provision the entire platform foundation with Terraform. No manual portal steps. Everything reproducible, everything auditable, everything deployable from a single pipeline run.

## ☁️ The problem with most tutorials

Most tutorials show audience how to deploy a storage account or a virtual network in isolation. That is useful for learning individual resources. But it does not teach what happens when those resources need to talk to each other, when a Databricks workspace needs specific subnet delegations, when Key Vault needs RBAC mode or access policies fail silently, when Terraform state gets locked and the pipeline hangs.

This project works through all of that and documents what actually went wrong.

## ☁️ What gets provisioned

☁️ Everything is deployed to **Germany West Central** inside a single resource group.
The four core components are:

    GitHub Actions (CI/CD)
            |
            v
    Azure Resource Group: rg-dataplatform-dev-gwc-001
        |
        |-- Virtual Network: vnet-dataplatform-dev-gwc-001
        |       |-- Subnet: snet-dbx-public-001  (Databricks public)
        |       |-- Subnet: snet-dbx-private-001 (Databricks private)
        |       |-- NSG: nsg-dataplatform-dev-001
        |               |-- 3 inbound rules
        |               |-- 4 outbound rules (required by Databricks)
        |
        |-- ADLS Gen2 Storage: stdataplatformrb2026
        |       |-- Container: raw      (landing zone)
        |       |-- Container: processed (cleaned data)
        |       |-- Container: curated  (business-ready data)
        |       |-- Lifecycle policy: cool tier after 30 days
        |
        |-- Key Vault: kv-dataplatform-rb-001
        |       |-- RBAC authorization mode
        |       |-- Soft delete: 7 days
        |       |-- Secret: databricks-pat-token
        |
        |-- Databricks Workspace: dbw-dataplatform-dev-gwc-001
                |-- Trial SKU
                |-- VNet injection into subnets above
                |-- No public IP for worker nodes

## ☁️ Project structure

    .
        modules/
            networking/     VNet, subnets, NSG with Databricks rules
            storage/        ADLS Gen2 with medallion architecture
            keyvault/       Key Vault with RBAC authorization
            databricks/     Workspace with VNet injection
        environments/
            dev/            Entry point wiring all modules together
        .github/
            workflows/      CI/CD pipeline: fmt, validate, plan, apply
        docs/
            architecture.md     Design decisions and trade-offs
            TROUBLESHOOTING.md  11 real errors documented with fixes
        screenshots/
            Portal evidence of successful provisioning on Azure

## ☁️ How the pipeline works

☁️ Every pull request triggers three jobs in sequence:

☁️ **fmt** checks that all Terraform files are properly formatted.
Fails immediately if anything is off. No exceptions.

☁️ **validate** checks that the configuration is syntactically correct
and all resource references are valid. Catches errors before they
reach Azure.

☁️ **plan** runs terraform plan and posts the full output as a comment
directly on the PR. Reviewers see exactly what will be created,
changed or destroyed before approving the merge.

☁️ **apply** runs automatically on merge to main. Nothing reaches
Azure without going through these three jobs first.

Azure credentials are stored as GitHub repository secrets and
injected at runtime. No credentials are stored in the pipeline
file or anywhere in the repository.

## ☁️ Requirements

☁️ To deploy this project you need:

- Terraform >= 1.5
- Azure CLI
- An Azure subscription
- A service principal with Contributor and Storage Blob Data
  Contributor roles on the subscription
- These GitHub repository secrets configured:
  - ARM_CLIENT_ID
  - ARM_CLIENT_SECRET
  - ARM_TENANT_ID
  - ARM_SUBSCRIPTION_ID
- A remote state storage account (see example.tfvars for naming)

## ☁️ Getting started

    # Authenticate with Azure
    az login

    # Register required resource providers
    az provider register --namespace Microsoft.Databricks
    az provider register --namespace Microsoft.Storage
    az provider register --namespace Microsoft.KeyVault
    az provider register --namespace Microsoft.Network

    # Copy example vars and fill in your values
    cd environments/dev
    cp example.tfvars terraform.tfvars

    # Initialize Terraform
    terraform init

    # Preview changes
    terraform plan

    # Apply
    terraform apply

    # Destroy when done to avoid cost
    terraform destroy

## ☁️ What is documented

☁️ Rather than just showing the final working code, every non-obvious
decision and every real error is written up.

☁️ **docs/TROUBLESHOOTING.md** covers 11 real issues encountered during
the build. Each entry has the exact error message, what caused it,
the fix applied, and the lesson learned.

☁️ **docs/architecture.md** explains every design decision: why VNet
injection, why RBAC mode for Key Vault, why the medallion architecture
for storage, what would change in a production deployment.

## ☁️ Deployment results

☁️ All 16 resources were successfully provisioned on Azure in Germany
West Central. Screenshots of the provisioned infrastructure are in
the screenshots folder.

☁️ **Databricks workspace URL:**
adb-7405608226176395.15.azuredatabricks.net

☁️ **Key Vault URI:**
https://kv-dataplatform-rb-001.vault.azure.net/

☁️ **Storage DFS endpoint:**
https://stdataplatformrb2026.dfs.core.windows.net/

Resources were destroyed after verification to avoid ongoing cost.
The infrastructure can be reprovisioned from scratch with a single
terraform apply run.

## ☁️ Current status

☁️ Project complete. All modules built, tested, and documented.
Open issues track potential future improvements.

Feedback and questions are welcome. Open an issue.

---

## ☁️ About

Built as part of a cloud engineering portfolio focused on Azure
platform engineering, Infrastructure-as-Code, and data platform
architecture. Currently looking for Cloud Platform Engineer and
DevOps roles in Germany.
