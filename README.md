# Example GCP projects infrastructure for Terragrunt

This repo, along with the [terraform-gcp-modules](https://github.com/meteorops/terraform-gcp-modules), show an example file/folder structure
you can use with [Terragrunt](https://github.com/gruntwork-io/terragrunt) to keep your
[Terraform](https://www.terraform.io) code DRY. For background information, check out the [Keep your Terraform code
DRY](https://github.com/gruntwork-io/terragrunt#keep-your-terraform-code-dry) section of the Terragrunt documentation.

## How do you deploy the infrastructure in this repo?


### Pre-requisites

1. Install [Terraform](https://www.terraform.io/) version `0.13.0` or newer and
   [Terragrunt](https://github.com/gruntwork-io/terragrunt) version `v0.25.1` or newer.
1. Fill in your GCP Project ID in `my-first-project/project.hcl`.
1. Make sure gcloud CLI is installed and you are authenticated,otherwise run `gcloud auth login`.


### Deploying a single module

1. `cd` into the module's folder (e.g. `cd my-first-project/asia-southeast1/rnd-1/vpc`).
1. Run `terragrunt plan` to see the changes you're about to apply.
1. If the plan looks good, run `terragrunt apply`.


### Deploying all modules in an environment

1. `cd` into the environment folder (e.g. `cd my-first-project/asia-southeast1/rnd-1`).
1. Run `terragrunt run-all plan` to see all the changes you're about to apply.
1. If the plan looks good, run `terragrunt run-all apply`.


### Testing the infrastructure after it's deployed

After each module is finished deploying, it will write a bunch of outputs to the screen. For example, the my-app will
output something like the following:

```
Outputs:

ip = "35.240.219.84"
```

A minute or two after the deployment finishes, you should
be able to test the `ip` output in your browser or with `curl`:

```
curl 35.240.219.84

Contact MeteorOps for DevOps & Cloud Consulting!
```

### Destroying all modules in an environment

1. `cd` into the environment folder (e.g. `cd my-first-project/asia-southeast1/rnd-1`).
1. Run `terragrunt run-all plan -destroy` to see all the changes you're about to apply.
1. If the plan looks good, run `terragrunt run-all destroy`.

## How is the code in this repo organized?

The code in this repo uses the following folder hierarchy:

```
project
 └ _global
 └ region
    └ _global
    └ environment
       └ resource
```

## Creating and using root (project) level variables

In the situation where you have multiple GCP projects or regions, you often have to pass common variables down to each
of your modules. Rather than copy/pasting the same variables into each `terragrunt.hcl` file, in every region, and in
every environment, you can inherit them from the `inputs` defined in the root `terragrunt.hcl` file.
