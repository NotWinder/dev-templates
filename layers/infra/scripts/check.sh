#!/usr/bin/env bash
set -euo pipefail
exec .venv/bin/pytest "$@"
