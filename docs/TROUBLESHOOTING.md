# Troubleshooting Log

This file documents real errors encountered while building this project. Each entry includes the exact error message, what caused it, and how it was fixed. This is not a cleaned-up tutorial. It is a record of what actually happened.

---

## Issue 1: Storage container attribute not supported in provider version

**When it happened:** During the first CI pipeline run after the GitHub Actions workflow was added.

**The error:**

An argument named "storage_account_id" is not expected here. The azurerm_storage_container resource does not accept storage_account_id in azurerm provider version 3.90. Terraform validate failed in CI with an unsupported argument error on all three container resources.

**What caused it:** The storage container resources were written using storage_account_id which was introduced in a later version of the AzureRM provider. This project targets azurerm ~> 3.90 which still requires storage_account_name as the argument.

**The fix:** Changed all three container resources from storage_account_id to storage_account_name like this:

    resource "azurerm_storage_container" "raw" {
      name                  = "raw"
      storage_account_name  = azurerm_storage_account.main.name
      container_access_type = "private"
    }

**Lesson learned:** Always check the provider version changelog when using attributes found in recent documentation. The Terraform registry defaults to the latest version which may differ from the version pinned in the project.

---

## Issue 2: Databricks workspace output attribute does not exist

**When it happened:** During the same CI pipeline run as Issue 1.

**The error:**

This object has no argument, nested block, or exported attribute named "workspace_resource_id". The outputs.tf file for the Databricks module referenced an attribute that does not exist in azurerm ~> 3.90.

**What caused it:** The workspace_resource_id attribute was added in a later version of the AzureRM provider. In version 3.90 it is not an exported attribute on azurerm_databricks_workspace.

**The fix:** Removed the unsupported output from modules/databricks/outputs.tf. The remaining outputs cover everything needed: workspace_id, workspace_name, and workspace_url.

**Lesson learned:** Before referencing resource attributes in outputs, verify they exist in the provider documentation for the specific version being used, not just the latest version.

---

## Issue 3: GitHub Actions pipeline missing from main after merge

**When it happened:** After merging the GitHub Actions pipeline PR, the terraform.yml file was not present on main either locally or on GitHub.

**What caused it:** The pipeline PR was merged but the commit did not make it into main properly. This can happen when there is a conflict during the merge that silently drops files, or when the branch state at merge time does not match expectations.

**The fix:** Recreated the .github/workflows/terraform.yml file on the fix branch and merged it together with the other fixes. Verified the file exists on main after merging by running ls .github/workflows/ locally after git pull.

**Lesson learned:** Always verify critical files are present on main after merging. Do not assume the merge worked correctly just because GitHub shows it as merged. Pull and check locally.

---

## Issue 4: Subnet delegation missing for Databricks VNet injection

**Status:** Known issue, not yet fixed. Documented here for transparency.

**What the error will look like when terraform apply runs:**

The subnet snet-dbx-public-001 does not have the required delegation to Microsoft.Databricks/workspaces. Databricks VNet injection requires service delegation on both the public and private subnets before the workspace can be created.

**What caused it:** The networking module subnets were created without the delegation block required for Databricks VNet injection. This was an intentional omission to document what the real error looks like before applying the fix.

**The fix that will be applied:**

Add a delegation block to both subnets in modules/networking/main.tf:

    delegation {
      name = "databricks-delegation"
      service_delegation {
        name = "Microsoft.Databricks/workspaces"
        actions = [
          "Microsoft.Network/virtualNetworks/subnets/join/action",
          "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
          "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"
        ]
      }
    }

This fix will be applied in a follow-up commit after the initial terraform apply attempt documents the exact error output.

---

## Issue 5: variable.tf filename typo in storage module

**When it happened:** During development of the storage module.

**What caused it:** The variables file was accidentally saved as variable.tf instead of variables.tf. Terraform does not care about filenames since it reads all .tf files in a directory. However it broke the naming convention used across all other modules and caused Git to track the file under the wrong name.

**The fix:** Renamed variable.tf to variables.tf and committed the rename as part of the fix branch for Issues 1 and 2. Used git rm to remove the old file and staged the correctly named file so Git tracks the rename cleanly.

**Lesson learned:** Small naming inconsistencies are easy to miss during development but confusing for anyone reading the codebase later. A consistent convention across all modules makes the project easier to navigate.

## Issue 6: Resource provider registration failures

**When it happened:** During the first terraform plan run after credentials were configured.

**The error:**

Terraform encountered connection reset errors when trying to automatically register Azure resource providers like Microsoft.Cdn, Microsoft.Automation, and Microsoft.Web.

**What caused it:** By default azurerm provider version 4.x tries to register all supported resource providers on the subscription. The service principal either lacked permission or the network connection was reset during the registration attempts.

**The fix:** Added resource_provider_registrations = "none" to the provider block and manually registered only the four providers needed for this project via az provider register.

**Lesson learned:** In enterprise environments service principals often do not have permission to register resource providers at subscription level. Disabling auto-registration and registering manually is standard practice.

---

## Issue 7: Databricks Standard SKU deprecated

**When it happened:** During terraform apply.

**The error:**

DatabricksStandardSkuNotSupported: The Standard SKU is deprecated. Please use Premium SKU.

**What caused it:** Azure deprecated the Standard SKU for Databricks workspaces. New workspaces must use Premium or Trial SKU.

**The fix:** Changed the SKU from standard to trial in both modules/databricks/variables.tf and environments/dev/main.tf. Trial SKU is free and sufficient for development and testing.

**Lesson learned:** Cloud provider SKU availability changes over time. Always check current documentation before assuming a SKU is still available.

---

## Issue 8: NSG conflicts with Databricks NetworkIntentPolicy

**When it happened:** During terraform apply after subnet delegation was added.

**The error:**

ConflictWithNetworkIntentPolicy: Network Security Group cannot have resources which conflict with its subnets network intent policies. The NSG was missing four required outbound security rules for Databricks worker nodes.

**What caused it:** Databricks VNet injection applies a Network Intent Policy to the subnets that requires specific outbound rules in the attached NSG. The initial NSG only had inbound rules.

**The fix:** Added four outbound security rules to the NSG in modules/networking/main.tf:
- databricks-worker-to-databricks-webapp: ports 443, 3306, 8443-8451
- databricks-worker-to-sql: port 3306
- databricks-worker-to-storage: port 443
- databricks-worker-to-eventhub: port 9093

**Lesson learned:** Databricks VNet injection has strict NSG requirements that are not obvious from the basic documentation. The full list of required rules is in the Databricks networking documentation under supported regions.

---

## Issue 9: Storage containers 403 unauthorized

**When it happened:** During terraform apply after storage account was created.

**The error:**

unexpected status 403 This request is not authorized to perform this operation. AuthorizationFailure on all three containers.

**What caused it:** Two separate issues combined:
1. The storage module had public_network_access_enabled = false
   which blocked all external access including from the pipeline
2. The service principal needed Storage Blob Data Contributor role
   in addition to Contributor to create containers

**The fix:** Changed public_network_access_enabled to true in the storage module for the dev environment. Assigned Storage Blob Data Contributor role to the service principal via az role assignment create.

**Lesson learned:** In azurerm v4 the Contributor role alone is not sufficient to manage storage containers. Storage data plane operations require explicit data roles like Storage Blob Data Contributor.

---

## Issue 10: Databricks workspace dependency ordering

**When it happened:** During terraform apply after all other fixes.

**The error:**

failed to check public subnet delegation for snet-dbx-public-001: unexpected status 404 Not Found.

**What caused it:** Terraform was trying to create the Databricks workspace before the subnets were fully provisioned. Even though the Databricks module references the VNet ID from the networking module output, Terraform did not wait for the subnets to be ready before starting the workspace creation.

**The fix:** Added explicit depends_on = [module.networking] to the Databricks module block in environments/dev/main.tf. This forces Terraform to wait for the entire networking module to complete before starting the Databricks workspace.

**Lesson learned:** Implicit dependencies through output references are not always sufficient for complex resources like Databricks that check subnet state during provisioning. Explicit depends_on is sometimes necessary.

---

## Issue 11: State backend lost during failed destroy

**When it happened:** During terraform destroy after repeated apply failures.

**What happened:** The terraform destroy command failed because Databricks had applied NetworkIntentPolicy to the subnets which blocked NSG removal. During the partial destroy, the tfstate storage account was deleted along with other resources.

**The impact:** Terraform state was lost. Running terraform state list returned a 404 error for the state backend storage account.

**The fix:** Recreated the tfstate resource group and storage account manually via Azure CLI. Ran terraform init -reconfigure to reconnect to the new empty state backend. Since all Azure resources were also deleted, the empty state matched the empty Azure environment.

**Lesson learned:** Never put the Terraform state storage account in the same resource group as the resources it tracks. Use a separate resource group that is never touched by terraform destroy. This project uses rg-tfstate-dev-gwc-001 separately from rg-dataplatform-dev-gwc-001 for exactly this reason, but the destroy still caught it because it deleted everything in the subscription matching the pattern.
