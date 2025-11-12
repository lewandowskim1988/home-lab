locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../terraform-modules/talos-base"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  platform        = "metal"
  extension_names = [
    "siderolabs/nonfree-kmod-nvidia-production",
    "siderolabs/nvidia-container-toolkit-production",
    "siderolabs/zfs"
  ]
}
