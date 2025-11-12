locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../terraform-modules/talos"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders("root.hcl")
}

dependency "talos_base_controlplane" {
  config_path = "../talos-base-controlplane"

  mock_outputs = {
    image = "temporary-dummy-id"
  }

  mock_outputs_allowed_terraform_commands = ["validate", "plan", "destroy"]
}

dependency "talos_base_worker" {
  config_path = "../talos-base-worker"

  mock_outputs = {
    image = "temporary-dummy-id"
  }

  mock_outputs_allowed_terraform_commands = ["validate", "plan", "destroy"]
}

inputs = {
  cluster_name     = local.environment_vars.locals.cluster_name
  cluster_endpoint = "https://192.168.3.25:6443"

  node_data = {
    controlplanes = {
      "192.168.3.25" = {
        install_disk = "/dev/mmcblk0"
        image        = dependency.talos_base_controlplane.outputs.image
      }
    }
    workers = {
      "192.168.3.10" = {
        install_disk = "/dev/sdb"
        image        = dependency.talos_base_worker.outputs.image
      }
    }
  }
}
