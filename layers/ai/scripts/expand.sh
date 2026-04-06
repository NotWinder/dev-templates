#!/usr/bin/env bash
set -euo pipefail

# Expand a task file into subtasks via opencode
TASK=${1:-}
[[ -z "$TASK" ]] && { echo "Usage: expand.sh <task-file-or-description>"; exit 1; }

opencode run --agent task-expander "Expand this task: $TASK"
