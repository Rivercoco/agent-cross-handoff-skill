#!/usr/bin/env bash
set -euo pipefail
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_SRC="$SRC_DIR/.agents/skills/agent-cross-handoff"
mkdir -p "$HOME/.agents/skills" "$HOME/.claude/skills"
rm -rf "$HOME/.agents/skills/agent-cross-handoff" "$HOME/.claude/skills/agent-cross-handoff"
cp -R "$SKILL_SRC" "$HOME/.agents/skills/agent-cross-handoff"
cp -R "$SKILL_SRC" "$HOME/.claude/skills/agent-cross-handoff"
echo "Installed for Codex: $HOME/.agents/skills/agent-cross-handoff"
echo "Installed for Claude Code: $HOME/.claude/skills/agent-cross-handoff"
echo "Use in Codex:  \$agent-cross-handoff"
echo "Use in Claude: /agent-cross-handoff"
