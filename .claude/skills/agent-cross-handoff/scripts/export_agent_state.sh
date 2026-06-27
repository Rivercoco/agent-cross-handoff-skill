#!/usr/bin/env bash
set -euo pipefail
OUT="${1:-agent-state-safe-export-$(date +%Y%m%d-%H%M%S).tar.gz}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/export"
MANIFEST="$TMP/export/MANIFEST.txt"
{
  echo "Agent safe state export"
  date
  echo "Excluded: credentials, auth.json, tokens, caches, logs, .env, private keys"
} > "$MANIFEST"
copy_if_exists() {
  local src="$1" dst="$2"
  if [ -e "$src" ]; then
    mkdir -p "$(dirname "$TMP/export/$dst")"
    rsync -a --exclude 'auth.json' --exclude 'logs' --exclude 'log' --exclude 'cache' --exclude 'caches' --exclude '.env' --exclude '.env.*' --exclude '*token*' --exclude '*secret*' --exclude '*.pem' --exclude '*.key' "$src" "$TMP/export/$dst" || true
    echo "Included: $src -> $dst" >> "$MANIFEST"
  fi
}
copy_if_exists "$HOME/.agents/skills" "codex-user-skills"
copy_if_exists "$HOME/.codex/AGENTS.md" "codex/AGENTS.md"
copy_if_exists "$HOME/.codex/config.toml" "codex/config.toml"
copy_if_exists "$HOME/.codex/memories" "codex/memories"
copy_if_exists "$HOME/.claude/skills" "claude-user-skills"
copy_if_exists "$HOME/.claude/CLAUDE.md" "claude/CLAUDE.md"
copy_if_exists "$HOME/.claude/settings.json" "claude/settings.json"
tar -czf "$OUT" -C "$TMP" export
echo "Created $OUT"
