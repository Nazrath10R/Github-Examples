#!/usr/bin/env bash

set -euo pipefail

LAYER_NAME="awscli-layer"
BUILD_DIR=".build_layer"
AWSCLI_VERSION="2.9.12" # or whichever version you prefer

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR/bin"

# Download AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWSCLI_VERSION}.zip" -o "$BUILD_DIR/awscliv2.zip"
unzip "$BUILD_DIR/awscliv2.zip" -d "$BUILD_DIR"

# Install to a custom directory within BUILD_DIR
"$BUILD_DIR/aws/install" -i "$BUILD_DIR/aws-cli" -b "$BUILD_DIR/bin"

# Create a zip of the final layer content
cd "$BUILD_DIR/aws-cli"
zip -r9 ../awscli-layer.zip .

# Publish the layer to AWS (adjust Region as needed)
aws lambda publish-layer-version \
  --layer-name "$LAYER_NAME" \
  --zip-file "fileb://../awscli-layer.zip" \
  --region us-east-1

echo "Layer published as $LAYER_NAME"
