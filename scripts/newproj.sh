#!/usr/bin/env bash
# newproj.sh — scaffold a new project from template layers
#
# Usage:
#   bash ~/dev/templates/scripts/newproj.sh <name> <layer1> [layer2] ...
#   bash ~/dev/templates/scripts/newproj.sh <name> --preset <preset>
#
# Examples:
#   bash ~/dev/templates/scripts/newproj.sh my-tool ai cli
#   bash ~/dev/templates/scripts/newproj.sh my-app ai cli infra
#   bash ~/dev/templates/scripts/newproj.sh my-site ai web
#   bash ~/dev/templates/scripts/newproj.sh my-app --preset ai-project

set -euo pipefail

TEMPLATES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECTS_DIR="${PROJECTS_DIR:-"$HOME/dev/active"}"

# ── helpers ──────────────────────────────────────────────────────────────────

usage() {
  echo "Usage: $(basename "$0") <name> <layer1> [layer2] ..."
  echo "       $(basename "$0") <name> --preset <preset>"
  echo ""
  echo "Available layers:  $(ls "$TEMPLATES_DIR/layers" | tr '\n' ' ')"
  echo "Available presets: $(ls "$TEMPLATES_DIR/presets" | tr '\n' ' ')"
  exit 1
}

die() { echo "ERROR: $*" >&2; exit 1; }

# ── argument parsing ──────────────────────────────────────────────────────────

[[ $# -lt 2 ]] && usage

NAME="$1"; shift

# Validate project name
[[ "$NAME" =~ ^[a-zA-Z0-9_-]+$ ]] || die "Project name must be alphanumeric (hyphens/underscores allowed): $NAME"

LAYERS=()

if [[ "${1:-}" == "--preset" ]]; then
  [[ $# -ge 2 ]] || die "--preset requires a preset name"
  PRESET="$2"
  PRESET_FILE="$TEMPLATES_DIR/presets/$PRESET/preset.json"
  [[ -f "$PRESET_FILE" ]] || die "Preset not found: $PRESET (looked in $PRESET_FILE)"

  # Parse layers array from preset.json (requires python3 or jq)
  if command -v python3 >/dev/null 2>&1; then
    mapfile -t LAYERS < <(python3 -c "
import json, sys
data = json.load(open('$PRESET_FILE'))
for l in data['layers']:
    print(l)
")
  elif command -v jq >/dev/null 2>&1; then
    mapfile -t LAYERS < <(jq -r '.layers[]' "$PRESET_FILE")
  else
    die "python3 or jq is required to read preset files"
  fi
else
  LAYERS=("$@")
fi

[[ ${#LAYERS[@]} -gt 0 ]] || die "No layers specified"

# ── validation ────────────────────────────────────────────────────────────────

echo "Validating layers: ${LAYERS[*]}"

for layer in "${LAYERS[@]}"; do
  if [[ "$layer" == "base" ]]; then
    continue  # base is always applied; skip explicit validation message
  fi
  [[ -d "$TEMPLATES_DIR/layers/$layer" ]] || die "Layer not found: $layer (looked in $TEMPLATES_DIR/layers/$layer)"
done

DEST="$PROJECTS_DIR/$NAME"
[[ ! -e "$DEST" ]] || die "Project already exists: $DEST"

# ── apply layers ──────────────────────────────────────────────────────────────

mkdir -p "$DEST"
echo "Scaffolding '$NAME' into $DEST"

# Apply base first so layers can override its stub scripts (run.sh, test.sh, lint.sh)
echo "  Applying layer: base"
cp -r "$TEMPLATES_DIR/base/." "$DEST/"

# Apply non-base layers in order (later layers win on conflicts)
for layer in "${LAYERS[@]}"; do
  [[ "$layer" == "base" ]] && continue
  SRC="$TEMPLATES_DIR/layers/$layer"
  echo "  Applying layer: $layer"
  cp -r "$SRC/." "$DEST/"
done

# Re-apply base config files that must always be canonical regardless of layers.
# This preserves layer script overrides (run.sh, test.sh, lint.sh) while ensuring
# AGENTS.md, opencode.json, and validate.sh are always the base versions.
echo "  Re-applying base config: AGENTS.md, opencode.json, scripts/validate.sh"
cp "$TEMPLATES_DIR/base/AGENTS.md"             "$DEST/AGENTS.md"
cp "$TEMPLATES_DIR/base/opencode.json"         "$DEST/opencode.json"
cp "$TEMPLATES_DIR/base/scripts/validate.sh"   "$DEST/scripts/validate.sh"

# ── substitute [PROJECT_NAME] ─────────────────────────────────────────────────

echo "  Substituting [PROJECT_NAME] → $NAME"

# Detect sed flavour for in-place editing (GNU vs BSD/macOS)
if sed --version 2>/dev/null | grep -q GNU; then
  _sed_inplace() { sed -i "s/\[PROJECT_NAME\]/$NAME/g" "$1"; }
else
  _sed_inplace() { sed -i '' "s/\[PROJECT_NAME\]/$NAME/g" "$1"; }
fi

# Find all text files and do in-place substitution (skip .git and binary files)
while IFS= read -r -d '' file; do
  # Skip .gitkeep
  [[ "$(basename "$file")" == ".gitkeep" ]] && continue

  # Skip binary files (grep -I exits non-zero for binary files)
  grep -qI '' "$file" 2>/dev/null || continue

  _sed_inplace "$file" 2>/dev/null || true
done < <(find "$DEST" -not -path '*/.git/*' -type f -print0)

# ── git init ──────────────────────────────────────────────────────────────────

echo "  Initialising git repository"
git -C "$DEST" init -q
git -C "$DEST" add .
git -C "$DEST" commit -q -m "chore: scaffold $NAME from template layers [${LAYERS[*]}]"

# ── done ──────────────────────────────────────────────────────────────────────

echo ""
echo "Done! Project created at: $DEST"
echo ""
echo "Next steps:"
echo "  1. Fill in AGENTS.md"
echo "  2. cd $DEST && opencode"
