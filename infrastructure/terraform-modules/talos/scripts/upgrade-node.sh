#!/bin/sh

# Expects the following environment variables set:
#   TALOS_IMAGE
#   TALOS_NODE
#   TIMEOUT

if [ -z "$TALOS_IMAGE" ] || [ -z "$TALOS_NODE" ] || [ -z "$TIMEOUT" ]; then
  echo "Missing required environment variables."
  exit 1
fi

CURRENT_TALOS_SCHEMATIC=$(talosctl --nodes "$TALOS_NODE" get extensions -o json 2>/dev/null | jq -s '.[] | select(.spec.metadata.name == "schematic") | .spec.metadata.version' | tr -d '"')
CURRENT_TALOS_TAG=$(talosctl --nodes "$TALOS_NODE" version --short 2>/dev/null | grep 'Tag:' | awk '{print $2}')
CURRENT_TALOS_IMAGE="factory.talos.dev/metal-installer/$CURRENT_TALOS_SCHEMATIC:$CURRENT_TALOS_TAG"

echo Current Image: $CURRENT_TALOS_IMAGE Desired Image: $TALOS_IMAGE

if [ "$CURRENT_TALOS_IMAGE" = "$TALOS_IMAGE" ]; then
  echo "No Upgrade required."
else
  echo "Upgrade required."
  talosctl --nodes "$TALOS_NODE" upgrade --image="$TALOS_IMAGE" --timeout=$TIMEOUT
fi
