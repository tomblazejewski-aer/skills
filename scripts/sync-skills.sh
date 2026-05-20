#!/usr/bin/env bash
# sync-skills.sh
# Copies registered skills from plugin.json into .opencode/skills/
# so OpenCode discovers them as project-local skills.
#
# Run from the repo root:
#   ./scripts/sync-skills.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGIN_JSON="$REPO_ROOT/.claude-plugin/plugin.json"
DEST="$REPO_ROOT/.opencode/skills"

if [[ ! -f "$PLUGIN_JSON" ]]; then
  echo "ERROR: $PLUGIN_JSON not found." >&2
  exit 1
fi

# Parse the skills array from plugin.json using node
mapfile -t SKILL_PATHS < <(node -e "
  const p = require('$PLUGIN_JSON');
  p.skills.forEach(s => console.log(s));
")

mkdir -p "$DEST"

# Track which skill names we write so we can clean up stale ones
declare -a WRITTEN_NAMES=()

for rel_path in "${SKILL_PATHS[@]}"; do
  src="$REPO_ROOT/$rel_path"
  name="$(basename "$rel_path")"

  if [[ ! -d "$src" ]]; then
    echo "WARN: skill source not found, skipping: $src"
    continue
  fi

  dest_skill="$DEST/$name"
  mkdir -p "$dest_skill"

  # Copy all .md files from the skill folder
  copied=0
  while IFS= read -r -d '' f; do
    cp "$f" "$dest_skill/"
    ((copied++)) || true
  done < <(find "$src" -maxdepth 1 -name "*.md" -print0)

  WRITTEN_NAMES+=("$name")
  echo "  synced  $name  ($copied files)"
done

# Remove stale skill folders no longer in plugin.json
if [[ -d "$DEST" ]]; then
  while IFS= read -r -d '' existing; do
    existing_name="$(basename "$existing")"
    keep=false
    for n in "${WRITTEN_NAMES[@]}"; do
      [[ "$n" == "$existing_name" ]] && keep=true && break
    done
    if [[ "$keep" == false ]]; then
      rm -rf "$existing"
      echo "  removed $existing_name (no longer registered)"
    fi
  done < <(find "$DEST" -mindepth 1 -maxdepth 1 -type d -print0)
fi

echo ""
echo "Done. ${#WRITTEN_NAMES[@]} skill(s) active in .opencode/skills/"
