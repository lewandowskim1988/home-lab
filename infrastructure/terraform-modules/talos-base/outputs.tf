output "image" {
  value = data.talos_image_factory_urls.this.urls.installer
}

output "talos_version" {
  value = element(data.talos_image_factory_versions.this.talos_versions, length(data.talos_image_factory_versions.this.talos_versions) - 1)
}
