#!/bin/sh

# Expects the following environment variables set:
#   K8S_VERSION
#   TALOS_NODE
#   TIMEOUT

if [ -z "$K8S_VERSION" ] || [ -z "$TALOS_NODE" ]; then
  echo "Missing required environment variables."
  exit 1
fi

talosctl --nodes "$TALOS_NODE" upgrade-k8s --to="$K8S_VERSION"
