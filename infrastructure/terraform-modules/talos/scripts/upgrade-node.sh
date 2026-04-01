#!/bin/sh

# Expects the following environment variables set:
#   TALOS_IMAGE
#   TALOS_NODE
#   TIMEOUT

if [ -z "$TALOS_IMAGE" ] || [ -z "$TALOS_NODE" ] || [ -z "$TIMEOUT" ]; then
  echo "Missing required environment variables."
  exit 1
fi

talosctl --nodes "$TALOS_NODE" upgrade --image="$TALOS_IMAGE" --timeout=$TIMEOUT