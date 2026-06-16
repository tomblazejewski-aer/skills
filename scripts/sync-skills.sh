#!/usr/bin/env bash
# sync-skills.sh
# 1. Copies registered skills from plugin.json into .opencode/skills/
#    so OpenCode discovers them as project-local skills.
# 2. Deploys all skills, AGENTS.md, and opencode.json to ~/.config/opencode/
#    so this repo is the single source of truth for global OpenCode config.
#
# Run from the repo root:
#   ./scripts/sync-skills.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGIN_JSON="$REPO_ROOT/.claude-plugin/plugin.json"
LOCAL_DEST="$REPO_ROOT/.opencode/skills"
GLOBAL_CONFIG="$HOME/.config/opencode"
GLOBAL_DEST="$GLOBAL_CONFIG/skills"

if [[ ! -f "$PLUGIN_JSON" ]]; then
  echo "ERROR: $PLUGIN_JSON not found." >&2
  exit 1
fi

# Parse the skills array from plugin.json using node
mapfile -t SKILL_PATHS < <(node -e "
  const p = require('$PLUGIN_JSON');
  p.skills.forEach(s => console.log(s));
")

mkdir -p "$LOCAL_DEST"
mkdir -p "$GLOBAL_DEST"

# Track which skill names we write so we can clean up stale ones
declare -a WRITTEN_NAMES=()

for rel_path in "${SKILL_PATHS[@]}"; do
  src="$REPO_ROOT/$rel_path"
  name="$(basename "$rel_path")"

  if [[ ! -d "$src" ]]; then
    echo "WARN: skill source not found, skipping: $src"
    continue
  fi

  # Copy all .md files from the skill folder to both destinations
  copied=0
  mkdir -p "$LOCAL_DEST/$name"
  mkdir -p "$GLOBAL_DEST/$name"
  while IFS= read -r -d '' f; do
    cp "$f" "$LOCAL_DEST/$name/"
    cp "$f" "$GLOBAL_DEST/$name/"
    ((copied++)) || true
  done < <(find "$src" -maxdepth 1 -name "*.md" -print0)

  WRITTEN_NAMES+=("$name")
  echo "  synced  $name  ($copied files)"
done

# Remove stale skill folders no longer in plugin.json — both destinations
for dest_dir in "$LOCAL_DEST" "$GLOBAL_DEST"; do
  if [[ -d "$dest_dir" ]]; then
    while IFS= read -r -d '' existing; do
      existing_name="$(basename "$existing")"
      keep=false
      for n in "${WRITTEN_NAMES[@]}"; do
        [[ "$n" == "$existing_name" ]] && keep=true && break
      done
      if [[ "$keep" == false ]]; then
        rm -rf "$existing"
        echo "  removed $existing_name from $dest_dir (no longer registered)"
      fi
    done < <(find "$dest_dir" -mindepth 1 -maxdepth 1 -type d -print0)
  fi
done

echo ""
echo "Done. ${#WRITTEN_NAMES[@]} skill(s) synced to project-local and global config."

# Deploy AGENTS.md and opencode.json to global OpenCode config
echo ""
echo "Deploying global config to $GLOBAL_CONFIG ..."

if [[ -f "$REPO_ROOT/AGENTS.md" ]]; then
  cp "$REPO_ROOT/AGENTS.md" "$GLOBAL_CONFIG/agents.md"
  echo "  synced  AGENTS.md -> $GLOBAL_CONFIG/agents.md"
else
  echo "  WARN: AGENTS.md not found, skipping"
fi

if [[ -f "$REPO_ROOT/opencode.json" ]]; then
  cp "$REPO_ROOT/opencode.json" "$GLOBAL_CONFIG/opencode.json"
  echo "  synced  opencode.json -> $GLOBAL_CONFIG/opencode.json"
else
  echo "  WARN: opencode.json not found, skipping"
fi

if [[ -f "$REPO_ROOT/STANDARDS.md" ]]; then
  cp "$REPO_ROOT/STANDARDS.md" "$GLOBAL_CONFIG/STANDARDS.md"
  echo "  synced  STANDARDS.md -> $GLOBAL_CONFIG/STANDARDS.md"
else
  echo "  INFO: STANDARDS.md not found, skipping"
fi

COMMANDS_SOURCE="$REPO_ROOT/.opencode/commands"
COMMANDS_DEST="$GLOBAL_CONFIG/commands"
if [[ -d "$COMMANDS_SOURCE" ]]; then
  mkdir -p "$COMMANDS_DEST"
  while IFS= read -r -d '' f; do
    cp "$f" "$COMMANDS_DEST/"
    echo "  synced  commands/$(basename "$f") -> $COMMANDS_DEST/$(basename "$f")"
  done < <(find "$COMMANDS_SOURCE" -maxdepth 1 -name "*.md" -print0)
else
  echo "  INFO: no .opencode/commands/ directory, skipping command deploy"
fi

echo ""
echo "Global config deploy complete."
