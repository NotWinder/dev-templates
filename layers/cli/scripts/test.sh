#!/usr/bin/env bash
set -euo pipefail
exec python3 -m pytest tests/ -v "$@"
