locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  project_vars = read_terragrunt_config(find_in_parent_folders("project.hcl"))

  # Extract out common variables for reuse
  env = local.environment_vars.locals.environment
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "git::git@github.com:meteorops/terraform-gcp-modules.git//vpc"
#  source = "git::git@github.com:meteorops/terraform-gcp-modules.git//vpc?ref=v0.0.2" # use remote module version
#  source = "../../../../../terraform-gcp-modules//vpc" # use module locally
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  project_id  = local.project_vars.locals.project_id
  network_name = "my-meteorops-network"
  subnets = [
    {
      subnet_name   = "subnet-01"
      subnet_ip     = "10.186.0.0/19"
      subnet_region = "asia-southeast1"
    },
    {
      subnet_name           = "subnet-02"
      subnet_ip             = "10.186.32.0/19"
      subnet_region         = "asia-southeast1"
      subnet_private_access = "true"
    }
  ]
}
