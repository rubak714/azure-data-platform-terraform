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
