#!/bin/bash

# Exit on any error
set -e

echo "DEBUG: contrib_extension_names is: '$TALOS_CONTRIB_EXTENSION_NAMES'"
echo "DEBUG: Length of contrib_extension_names: ${#TALOS_CONTRIB_EXTENSION_NAMES}"

# Check if contrib_extension_names is populated
if [ -z "$TALOS_CONTRIB_EXTENSION_NAMES" ]; then
    echo "TALOS_CONTRIB_EXTENSION_NAMES is not populated, skipping Talos build"
    exit 0
fi

echo "Building Talos with contrib extensions..."

# Determine architecture from TALOS_ARCH variable
ARCH=$TALOS_ARCH
echo "Using architecture: $ARCH"

# Create _out directory
mkdir -p _out

# Clean up _out directory
rm -rf _out/*

# Handle extension names properly - they might be passed as space-separated or colon-separated
IFS=',' read -ra EXTENSIONS <<< "$TALOS_CONTRIB_EXTENSION_NAMES"
if [ ${#EXTENSIONS[@]} -eq 1 ] && [[ "${EXTENSIONS[0]}" == *" "* ]]; then
    # If there's only one element but it contains spaces, it might be space-separated
    IFS=' ' read -ra EXTENSIONS <<< "$TALOS_CONTRIB_EXTENSION_NAMES"
fi

echo "Building installer with extensions: ${EXTENSIONS[*]}"

# Run the Docker commands
# Build installer with system extensions in a single command
DOCKER_ARGS=""
for extension in "${EXTENSIONS[@]}"; do
    echo "Adding extension: $extension"
    DOCKER_ARGS="$DOCKER_ARGS --system-extension-image $extension"
done

docker run --rm -t \
    -v $PWD/_out:/out \
    -v /dev:/dev \
    --privileged \
    ghcr.io/siderolabs/imager:${TALOS_VERSION} \
    --arch $ARCH \
    $DOCKER_ARGS \
    installer

# Load the installer
docker load -i _out/installer-$ARCH.tar

# Tag and push the image
docker tag ghcr.io/siderolabs/installer-base:${TALOS_VERSION} ${TALOS_IMAGE_CONTAINER_REGISTRY}/talos:${TALOS_VERSION}
docker push ${TALOS_IMAGE_CONTAINER_REGISTRY}/talos:${TALOS_VERSION}

# Save the image path to a file for Terraform consumption
echo "${TALOS_IMAGE_CONTAINER_REGISTRY}/talos:${TALOS_VERSION}" > _out/image_path.txt

# Clean up _out directory after use
rm -rf _out

echo "Talos build completed successfully"
echo "Created image: ${TALOS_IMAGE_CONTAINER_REGISTRY}/talos:${TALOS_VERSION}"
