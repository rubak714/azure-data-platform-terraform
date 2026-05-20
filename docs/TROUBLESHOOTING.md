# Troubleshooting Log

This file documents real errors encountered while building this project.
Each entry includes the exact error message, what caused it, and how it
was fixed. This is not a cleaned-up tutorial. It is a record of what
actually happened.

---

## Issue 1: Storage container attribute not supported in provider version

**When it happened:** During the first CI pipeline run after the GitHub
Actions workflow was added.

**The error:**

An argument named "storage_account_id" is not expected here. The
azurerm_storage_container resource does not accept storage_account_id
in azurerm provider version 3.90. Terraform validate failed in CI
with an unsupported argument error on all three container resources.

**What caused it:** The storage container resources were written using
storage_account_id which was introduced in a later version of the
AzureRM provider. This project targets azurerm ~> 3.90 which still
requires storage_account_name as the argument.

**The fix:** Changed all three container resources from storage_account_id
to storage_account_name like this:

    resource "azurerm_storage_container" "raw" {
      name                  = "raw"
      storage_account_name  = azurerm_storage_account.main.name
      container_access_type = "private"
    }

**Lesson learned:** Always check the provider version changelog when
using attributes found in recent documentation. The Terraform registry
defaults to the latest version which may differ from the version
pinned in the project.

---

## Issue 2: Databricks workspace output attribute does not exist

**When it happened:** During the same CI pipeline run as Issue 1.

**The error:**

This object has no argument, nested block, or exported attribute named
"workspace_resource_id". The outputs.tf file for the Databricks module
referenced an attribute that does not exist in azurerm ~> 3.90.

**What caused it:** The workspace_resource_id attribute was added in a
later version of the AzureRM provider. In version 3.90 it is not an
exported attribute on azurerm_databricks_workspace.

**The fix:** Removed the unsupported output from modules/databricks/outputs.tf.
The remaining outputs cover everything needed: workspace_id,
workspace_name, and workspace_url.

**Lesson learned:** Before referencing resource attributes in outputs,
verify they exist in the provider documentation for the specific version
being used, not just the latest version.

---

## Issue 3: GitHub Actions pipeline missing from main after merge

**When it happened:** After merging the GitHub Actions pipeline PR,
the terraform.yml file was not present on main either locally or
on GitHub.

**What caused it:** The pipeline PR was merged but the commit did not
make it into main properly. This can happen when there is a conflict
during the merge that silently drops files, or when the branch state
at merge time does not match expectations.

**The fix:** Recreated the .github/workflows/terraform.yml file on
the fix branch and merged it together with the other fixes. Verified
the file exists on main after merging by running ls .github/workflows/
locally after git pull.

**Lesson learned:** Always verify critical files are present on main
after merging. Do not assume the merge worked correctly just because
GitHub shows it as merged. Pull and check locally.

---

## Issue 4: Subnet delegation missing for Databricks VNet injection

**Status:** Known issue, not yet fixed. Documented here for transparency.

**What the error will look like when terraform apply runs:**

The subnet snet-dbx-public-001 does not have the required delegation
to Microsoft.Databricks/workspaces. Databricks VNet injection requires
service delegation on both the public and private subnets before the
workspace can be created.

**What caused it:** The networking module subnets were created without
the delegation block required for Databricks VNet injection. This was
an intentional omission to document what the real error looks like
before applying the fix.

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

This fix will be applied in a follow-up commit after the initial
terraform apply attempt documents the exact error output.

---

## Issue 5: variable.tf filename typo in storage module

**When it happened:** During development of the storage module.

**What caused it:** The variables file was accidentally saved as
variable.tf instead of variables.tf. Terraform does not care about
filenames since it reads all .tf files in a directory. However it
broke the naming convention used across all other modules and caused
Git to track the file under the wrong name.

**The fix:** Renamed variable.tf to variables.tf and committed the
rename as part of the fix branch for Issues 1 and 2. Used git rm
to remove the old file and staged the correctly named file so Git
tracks the rename cleanly.

**Lesson learned:** Small naming inconsistencies are easy to miss
during development but confusing for anyone reading the codebase
later. A consistent convention across all modules makes the project
easier to navigate.
