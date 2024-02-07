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
  source = "git::git@github.com:meteorops/terraform-gcp-modules.git//my-app"
#  source = "git::git@github.com:meteorops/terraform-gcp-modules.git//my-app?ref=v0.0.3" # use remote module version
#  source = "../../../../../terraform-gcp-modules//my-app" # use module locally
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    network_name = "my-meteorops-network"
    subnets_names = ["subnet-01","subnet-02"]
  }
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  network_name = dependency.vpc.outputs.network_name
  network_subnet_name = dependency.vpc.outputs.subnets_names[0]
  region = local.region_vars.locals.gcp_region
}
