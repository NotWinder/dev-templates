#!/usr/bin/env bash
set -euo pipefail
PYTHONPATH=. exec .venv/bin/pytest tests/ -v "$@"
