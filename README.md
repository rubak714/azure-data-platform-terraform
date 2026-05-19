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
