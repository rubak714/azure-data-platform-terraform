# Platform Architecture

This document explains the design of the Azure data platform, why certain decisions were made, and what would change in a production deployment.

---

## Overview

The platform provisions four core components on Azure, all managed through Terraform and deployed via a GitHub Actions CI/CD pipeline. No resource is created by clicking through the portal. Every change goes through code review before reaching Azure.

    GitHub Actions CI/CD
           |
           v
    Azure Resource Group: rg-dataplatform-dev-gwc-001
           |
           |-- Virtual Network: vnet-dataplatform-dev-gwc-001
           |       |-- Subnet: snet-dbx-public-001
           |       |-- Subnet: snet-dbx-private-001
           |       |-- NSG: nsg-dataplatform-dev-001
           |
           |-- ADLS Gen2 Storage: stdataplatformdevgwc001
           |       |-- Container: raw
           |       |-- Container: processed
           |       |-- Container: curated
           |
           |-- Key Vault: kv-dataplatform-dev-gwc-001
           |       |-- Secret: databricks-pat-token
           |
           |-- Databricks Workspace: dbw-dataplatform-dev-gwc-001
                   |-- VNet injection into subnets above

---

## Region choice: Germany West Central

All resources are deployed to Germany West Central (Frankfurt). This region is chosen because it falls under German data residency laws and is DSGVO compliant by default. For a German insurance company handling customer data, this is not optional. It is a legal requirement.

---

## Network design

The platform uses VNet injection for the Databricks workspace. This means Databricks cluster traffic stays inside the private network instead of routing through Databricks-managed infrastructure on the public internet.

Two subnets are required for Databricks VNet injection:

- snet-dbx-public-001 (10.0.1.0/24): handles control plane traffic
- snet-dbx-private-001 (10.0.2.0/24): handles data plane traffic

Both subnets require service delegation to Microsoft.Databricks/workspaces. This was initially missed and caused a deployment failure. See TROUBLESHOOTING.md Issue 4 for the full details.

A Network Security Group is attached to both subnets with a default deny-all inbound rule. Only VirtualNetwork and AzureLoadBalancer traffic is allowed inbound.

---

## Storage design: medallion architecture

The ADLS Gen2 storage account uses hierarchical namespace which enables directory-level operations and fine-grained access control. This is required for Delta Lake and Unity Catalog to work on Databrickks.

Three containers follow the medallion architecture pattern:

- raw: landing zone for unprocessed source data
- processed: cleaned and transformed data
- curated: business-ready data for analytics and ML workloads

Data moves through these layers as it is processed. Each layer has progressively higher data quality. This pattern is standard in modern data platforms and is what Databricks recommends for Delta Lake implementations.

A lifecycle management policy automatically moves blobs to the cool storage tier after 30 days. This reduces storage costs for data that is infrequently accessed but still needs to be retained.

Public network access is disabled on the storage account. Access is restricted to service principals with RBAC assignments.

---

## Secrets management

Key Vault uses RBAC authorization mode instead of the legacy access policies model. RBAC mode integrates with Azure AD role assignments which makes access auditable and follows least privilege principles.

Access policies are vault-level and harder to audit at scale. RBAC assignments are visible in Azure Policy and Microsoft Defender for Cloud which makes compliance reporting easier.

Soft delete is enabled with a 7 day retention period. This protects against accidental deletion of secrets during development.

Purge protection is disabled in the dev environment to allow clean teardown with terraform destroy. In production this would be enabled.

---

## CI/CD pipeline design

The GitHub Actions pipeline has four jobs:

- fmt: runs terraform fmt -check on every PR. Fails if any file is not properly formatted.  This enforces consistent style acros all contributors.

- validate: runs terraform validate on every PR. Catches syntax errors and invalid references before anything reaches Azure.

- plan: runs terraform plan on every PR and posts the full output as a comment on the PR. Reviewers can see exactly what will be created, changed or destroyed before approving the merge.

- apply: runs terraform apply automatically on merge to main.
  Infrastructure changes reach Azure only after code review.

Azure credentials are stored as GitHub repository secrets and injected into the pipeline at runtime. No credentials are stored in the pipeline file or in the repository.

---

## What would change in production

This is a dev environment. Several decisions were made for
simplicity and cost that would change in production:

- Purge protection on Key Vault would be enabled
- Storage account replication would change from LRS to GRS
- Private endpoints would replace the network ACL allow rule
- Azure Monitor alerts would be configured for cost and security
- Databricks Unity Catalog would be configured for data governance
- A separate state storage account with stricter RBAC would be used
- Resource locks would be applied to prevent accidental deletion

---

## Cost management

The dev environment is designed to run at near-zero cost when idle.
The Databricks workspace itself costs nothing when no clusters are running. Storage costs at this scale are negligible.

To avoid any charges, resources should be destroyed after testing with terraform destroy from the environments/dev directory. A bootstrap script for recreating the remote state storage account is provided separately.