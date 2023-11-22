#!/bin/bash

# Define the release name and namespace
RELEASE_NAME="test-release"
NAMESPACE="default"

# Define custom arguments
CUSTOM_ARGS=(
  "controller.ingressClassResource.default=true"
  "controller.watchIngressWithoutClass=true"
)

# Combine custom arguments for the Helm command
SET_ARGS=$(printf ",%s" "${CUSTOM_ARGS[@]}")
SET_ARGS=${SET_ARGS:1}

# Helm upgrade (or install) command
helm upgrade $RELEASE_NAME ./helm \
  --namespace $NAMESPACE \
  --install \
  --set $SET_ARGS \
  --wait \
  --timeout 120s

# Check if the upgrade (or install) was successful
if [ $? -ne 0 ]; then
    echo "Deployment failed."
    exit 1
else
    echo "Deployment succeeded."
fi
