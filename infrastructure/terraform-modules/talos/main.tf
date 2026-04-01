resource "talos_machine_secrets" "this" {}

data "talos_machine_configuration" "controlplane" {
  cluster_name     = var.cluster_name
  cluster_endpoint = var.cluster_endpoint
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
}

data "talos_machine_configuration" "worker" {
  cluster_name     = var.cluster_name
  cluster_endpoint = var.cluster_endpoint
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
}

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = [for k, v in var.node_data.controlplanes : k]
}

resource "talos_machine_configuration_apply" "controlplane" {
  for_each                    = var.node_data.controlplanes

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = each.key
  config_patches = [
    templatefile("${path.module}/templates/controlplane.tmpl", {
      install_disk = each.value.install_disk
      image        = each.value.image
    })
  ]
}

resource "talos_machine_configuration_apply" "worker" {
  for_each                    = var.node_data.workers

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = each.key
  config_patches = [
    templatefile("${path.module}/templates/worker.tmpl", {
      install_disk = each.value.install_disk
      image        = each.value.image
    })
  ]
}

resource "talos_machine_bootstrap" "this" {
  depends_on = [talos_machine_configuration_apply.controlplane]

  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = [for k, v in var.node_data.controlplanes : k][0]
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on           = [talos_machine_bootstrap.this]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = [for k, v in var.node_data.controlplanes : k][0]
}

# # Hack: https://github.com/siderolabs/terraform-provider-talos/issues/140
# resource "null_resource" "talos_controlplane_upgrade_trigger" {
#   for_each = var.node_data.controlplanes

#   triggers = {
#     image       = each.value.image
#   }

#   provisioner "local-exec" {
#     command = "flock $LOCK_FILE --command ${path.module}/scripts/upgrade-node.sh"

#     environment = {
#       LOCK_FILE = "${path.module}/scripts/.upgrade-node.lock"

#       TALOS_NODE  = each.key
#       TALOS_IMAGE = each.value.image
#       K8S_VERSION = each.value.k8s_version
#       TIMEOUT     = "20m"
#     }
#   }
# }

# resource "null_resource" "talos_worker_upgrade_trigger" {
#   for_each = var.node_data.workers

#   triggers = {
#     image = each.value.image
#   }

#   provisioner "local-exec" {
#     command = "flock $LOCK_FILE --command ${path.module}/scripts/upgrade-node.sh"

#     environment = {
#       LOCK_FILE = "${path.module}/scripts/.upgrade-node.lock"

#       TALOS_NODE  = each.key
#       TALOS_IMAGE = each.value.image
#       TIMEOUT     = "20m"
#     }
#   }
# }

# resource "null_resource" "talos_upgrade_k8s_trigger" {
#   for_each = var.node_data.controlplanes

#   triggers = {
#     k8s_version = each.value.k8s_version
#   }

#   provisioner "local-exec" {
#     command = "flock $LOCK_FILE --command ${path.module}/scripts/upgrade-k8s.sh"

#     environment = {
#       LOCK_FILE = "${path.module}/scripts/.upgrade-k8s.lock"

#       TALOS_NODE  = each.key
#       K8S_VERSION = each.value.k8s_version
#     }
#   }
# }
