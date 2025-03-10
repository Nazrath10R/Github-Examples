#!/usr/bin/env bash
set -euo pipefail

ZIP_FILE="lambda-bash-custom-runtime.zip"

# Clean up any old zip
rm -f "$ZIP_FILE"

# Create the zip with bootstrap and run.sh
zip -j "$ZIP_FILE" "./bootstrap" "./run.sh"

echo "Created $ZIP_FILE"