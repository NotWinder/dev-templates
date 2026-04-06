#!/usr/bin/env bash
set -euo pipefail

# Review a file or path via opencode
TARGET=${1:-.}

opencode run --agent reviewer "Review: $TARGET"
