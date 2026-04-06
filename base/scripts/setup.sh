#!/usr/bin/env bash
set -euo pipefail

echo "Setting up [PROJECT_NAME]..."

# Check required tools
command -v python3 >/dev/null || { echo "python3 required"; exit 1; }

# Install dependencies
# e.g. pip install -r requirements.txt

echo "Done. Run ./scripts/run.sh to start."
