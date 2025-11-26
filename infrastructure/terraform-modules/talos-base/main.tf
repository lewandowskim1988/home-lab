locals {
  sbc_platforms = [
    "rpi_generic",
    "revpi_generic",
    "bananapi_m64",
    "nanopi_r4s",
    "nanopi_r5s",
    "jetson_nano",
    "libretech_all_h3_cc_h5",
    "orangepi_r1_plus_lts",
    "pine64",
    "rock64",
    "rock4cplus",
    "rock4se",
    "rock5a",
    "rock5b",
    "rockpi_4",
    "rockpi_4c",
    "helios64",
    "turingrk1",
    "orangepi-5",
    "orangepi-5-plus",
    "rockpro64"
  ]

  is_sbc_platform = contains(local.sbc_platforms, var.platform)
}
resource "null_resource" "force_version_recompute" {
  triggers = {
    # Force recalculation on each Terraform run by using timestamp
    timestamp = timestamp()
    # Add variable trigger to catch changes in stable_versions_only
    stable_versions_only = var.stable_versions_only
  }
}

data "talos_image_factory_versions" "this" {
  depends_on = [null_resource.force_version_recompute]

  filters = {
    stable_versions_only = var.stable_versions_only
  }
}

data "talos_image_factory_extensions_versions" "this" {
  talos_version = element(data.talos_image_factory_versions.this.talos_versions, length(data.talos_image_factory_versions.this.talos_versions) - 1)
  filters = {
    names = var.extension_names
  }
}

resource "null_resource" "force_url_recompute" {
  triggers = {
    platform = var.platform
    timestamp = timestamp()
  }
}

resource "talos_image_factory_schematic" "this" {
  schematic = yamlencode(
    {
      customization = {
        systemExtensions = {
          officialExtensions = length(var.extension_names) > 0 ? data.talos_image_factory_extensions_versions.this.extensions_info.*.name : []
        }
      }
    }
  )
}

data "talos_image_factory_urls" "this" {
  depends_on = [null_resource.force_url_recompute]

  talos_version = element(data.talos_image_factory_versions.this.talos_versions, length(data.talos_image_factory_versions.this.talos_versions) - 1)
  schematic_id  = talos_image_factory_schematic.this.id

  platform = local.is_sbc_platform ? null : var.platform
  sbc      = local.is_sbc_platform ? var.platform : null
}
