# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

locals {
  # Automatically load account-level variables
  project_vars = read_terragrunt_config(find_in_parent_folders("project.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract the variables we need for easy access
  gcp_region   = local.region_vars.locals.gcp_region
  project_id = local.project_vars.locals.project_id
}

# Generate a GCP provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "google" {
  region = "${local.gcp_region}"

}
EOF
}

# Configure Terragrunt to automatically store tfstate files in a GCS bucket

remote_state {
  backend = "gcs"

  config = {
    project  = local.project_id # The GCP project where the bucket will be created.
    location = local.gcp_region # The GCP location where the bucket will be created.
    bucket = "terragrunt-state-${local.project_id}" # (Required) The name of the GCS bucket. This name must be globally unique. For more information, see Bucket Naming Guidelines.
    prefix = "${path_relative_to_include()}/terraform.tfstate" #- (Optional) GCS prefix inside the bucket. Named states for workspaces are stored in an object called <prefix>/<name>.tfstate.
    #credentials = local.project_cred_path #/ GOOGLE_BACKEND_CREDENTIALS / GOOGLE_CREDENTIALS - (Optional) Local path to Google Cloud Platform account credentials in JSON format. If unset, Google Application Default Credentials are used. The provided credentials must have Storage Object Admin role on the bucket. Warning: if using the Google Cloud Platform provider as well, it will also pick up the GOOGLE_CREDENTIALS environment variable.
    #impersonate_service_account #- (Optional) The service account to impersonate for accessing the State Bucket. You must have roles/iam.serviceAccountTokenCreator role on that account for the impersonation to succeed. If you are using a delegation chain, you can specify that using the impersonate_service_account_delegates field. Alternatively, this can be specified using the GOOGLE_IMPERSONATE_SERVICE_ACCOUNT environment variable.
    #impersonate_service_account_delegates #- (Optional) The delegation chain for an impersonating a service account as described here.
    #access_token #- (Optional) A temporary [OAuth 2.0 access token] obtained from the Google Authorization server, i.e. the Authorization: Bearer token used to authenticate HTTP requests to GCP APIs. This is an alternative to credentials. If both are specified, access_token will be used over the credentials field.
    #encryption_key #/ GOOGLE_ENCRYPTION_KEY - (Optional) A 32 byte base64 encoded 'customer supplied encryption key' used to encrypt all state. For more information see Customer Supplied Encryption Keys.
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL PARAMETERS
# These variables apply to all configurations in this subfolder. These are automatically merged into the child
# `terragrunt.hcl` config via the include block.
# ---------------------------------------------------------------------------------------------------------------------

# Configure root level variables that all resources can inherit. This is especially helpful with multi-account configs
# where terraform_remote_state data sources are placed directly into the modules.
inputs = merge(
  local.project_vars.locals,
  local.region_vars.locals,
  local.environment_vars.locals,
)