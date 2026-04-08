#!/usr/bin/env bash
set -euo pipefail

# Create a virtual environment if one doesn't exist
if [[ ! -d .venv ]]; then
  echo "Creating virtual environment..."
  python3 -m venv .venv
fi

echo "Installing dependencies..."
.venv/bin/pip install -q --upgrade pip
.venv/bin/pip install -q -e ".[dev]"

echo "Setup complete. Activate with: source .venv/bin/activate"
