#!/usr/bin/env bash
# validate.sh — strict project consistency validator
#
# HARD RULES:
# - Exactly ONE task must exist in tasks/in-progress/
# - No duplicate or hidden task inconsistencies
# - All tasks must follow required format
# - Required scripts must exist
#
# Exit codes:
#   0 — all checks passed
#   1 — validation failed

set -euo pipefail

FAILED=0

pass() { echo "✅ $*"; }
fail() { echo "❌ $*"; FAILED=1; }
warn() { echo "⚠️  $*"; }

echo "Running strict validation..."

# ─────────────────────────────────────────────────────────────────────────────
# 🔒 TASK COUNT (STRICT INVARIANT)
# ─────────────────────────────────────────────────────────────────────────────

IN_PROGRESS="tasks/in-progress"

if [[ ! -d "$IN_PROGRESS" ]]; then
  fail "$IN_PROGRESS/ does not exist"
else
  mapfile -t in_progress_files < <(find "$IN_PROGRESS" -maxdepth 1 -type f -name "*.md" 2>/dev/null)
  count="${#in_progress_files[@]}"

  if [[ "$count" -ne 1 ]]; then
    fail "Exactly ONE task must exist in $IN_PROGRESS/, found $count"

    if [[ "$count" -eq 0 ]]; then
      echo "     ⚠️ No active task (system idle — invalid state)"
    else
      echo "     ⚠️ Multiple tasks detected:"
      for f in "${in_progress_files[@]}"; do
        echo "     - $(basename "$f")"
      done
    fi

    # HARD STOP — prevent zombie continuation
  else
    pass "In-progress task count: $count"
  fi
fi

# ─────────────────────────────────────────────────────────────────────────────
# 🚫 ZOMBIE / DUPLICATE DETECTION
# ─────────────────────────────────────────────────────────────────────────────

# Check for hidden or duplicate files
declare -A file_map

while IFS= read -r -d '' file; do
  base=$(basename "$file")

  if [[ -n "${file_map[$base]:-}" ]]; then
    fail "Duplicate task filename detected: $base"
    echo "     - ${file_map[$base]}"
    echo "     - $file"
  else
    file_map["$base"]="$file"
  fi
done < <(find tasks/backlog tasks/in-progress -type f -name "*.md" -print0 2>/dev/null)

# Ensure no task exists in both done and in-progress
for file in tasks/in-progress/*.md; do
  [[ -e "$file" ]] || continue
  base=$(basename "$file")

  if [[ -f "tasks/done/$base" ]]; then
    fail "Task exists in BOTH in-progress and done: $base"
  fi
done

# Ensure no task exists in BOTH backlog and in-progress
for file in tasks/in-progress/*.md; do
  [[ -e "$file" ]] || continue
  base=$(basename "$file")

  if [[ -f "tasks/backlog/$base" ]]; then
    fail "Task exists in BOTH backlog and in-progress: $base"
  fi
done

# ─────────────────────────────────────────────────────────────────────────────
# 📄 TASK FORMAT VALIDATION
# ─────────────────────────────────────────────────────────────────────────────

REQUIRED_SECTIONS=(
  "## Goal"
  "## Context"
  "## Acceptance Criteria"
  "## Steps"
)

check_task_sections() {
  local file="$1"
  local name
  name="$(basename "$file")"
  local missing=()

  for section in "${REQUIRED_SECTIONS[@]}"; do
    if ! grep -qF "$section" "$file"; then
      missing+=("$section")
    fi
  done

  if [[ "${#missing[@]}" -gt 0 ]]; then
    fail "Task missing required sections: $name"
    for s in "${missing[@]}"; do
      echo "     missing: $s"
    done
  else
    pass "Task format OK: $name"
  fi
}

for dir in "tasks/backlog" "tasks/in-progress"; do
  [[ -d "$dir" ]] || continue

  while IFS= read -r -d '' task_file; do
    check_task_sections "$task_file"
  done < <(find "$dir" -maxdepth 1 -type f -name "*.md" ! -name ".gitkeep" -print0 2>/dev/null)
done

# ─────────────────────────────────────────────────────────────────────────────
# 📜 REQUIRED SCRIPTS
# ─────────────────────────────────────────────────────────────────────────────

for script in "scripts/run.sh" "scripts/test.sh" "scripts/setup.sh"; do
  if [[ -f "$script" ]]; then
    pass "Script exists: $script"
  else
    fail "Missing required script: $script"
  fi
done

# ─────────────────────────────────────────────────────────────────────────────
# ⚠️  STALE CONTEXT DETECTION
# ─────────────────────────────────────────────────────────────────────────────

if [[ -d "tasks/done" ]] && [[ -f "docs/context.md" ]]; then
  latest_done=""
  while IFS= read -r -d '' f; do
    latest_done="$f"
    break
  done < <(find "tasks/done" -maxdepth 1 -type f -name "*.md" -newer "docs/context.md" -print0 2>/dev/null)

  if [[ -n "$latest_done" ]]; then
    warn "docs/context.md may be stale — $(basename "$latest_done") in tasks/done/ is newer"
    warn "A previous task may have completed without updating docs/context.md"
  fi
fi

# ─────────────────────────────────────────────────────────────────────────────
# 🚨 FINAL GUARD (NO FALSE PASS)
# ─────────────────────────────────────────────────────────────────────────────

echo ""

if [[ "$FAILED" -ne 0 ]]; then
  echo "❌ Validation failed — FIX ALL ISSUES before proceeding"
  exit 1
fi

# Ensure we are NOT in an invalid empty state
count=$(find "$IN_PROGRESS" -maxdepth 1 -type f -name "*.md" 2>/dev/null | wc -l)

if [[ "$count" -ne 1 ]]; then
  echo "❌ CRITICAL: System must have exactly ONE active task"
  exit 1
fi

echo "✅ All checks passed"
