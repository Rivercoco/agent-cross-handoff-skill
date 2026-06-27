#!/usr/bin/env bash
set -euo pipefail

printf '== Agent Cross Handoff preflight ==\n'
printf 'OS: '; uname -a || true
printf 'Shell: %s\n' "${SHELL:-unknown}"
printf 'User home: %s\n' "${HOME:-unknown}"

if command -v git >/dev/null 2>&1; then
  printf '\n== Git ==\n'
  git --version || true
  if git rev-parse --show-toplevel >/dev/null 2>&1; then
    ROOT="$(git rev-parse --show-toplevel)"
    printf 'Repository root: %s\n' "$ROOT"
    cd "$ROOT"
    printf 'Branch: '; git branch --show-current || true
    printf 'HEAD: '; git rev-parse --short HEAD || true
    printf '\nRemotes:\n'; git remote -v || true
    printf '\nWorktrees:\n'; git worktree list || true
    printf '\nStatus:\n'; git status --short || true
    printf '\nUntracked sample:\n'; git ls-files --others --exclude-standard | head -50 || true
  else
    printf 'Not inside a Git repository.\n'
  fi
else
  printf 'Git not found.\n'
fi

printf '\n== Agent project files ==\n'
for p in AGENTS.md CLAUDE.md .claude/CLAUDE.md .claude/rules .claude/skills .agents/skills .codex .codex/config.toml .cursor/rules .cursorrules .windsurfrules .github/copilot-instructions.md; do
  if [ -e "$p" ]; then printf 'FOUND %s\n' "$p"; fi
done

printf '\n== Agent user dirs ==\n'
for p in "$HOME/.codex" "$HOME/.agents/skills" "$HOME/.claude" "$HOME/.claude/skills"; do
  if [ -e "$p" ]; then printf 'FOUND %s\n' "$p"; else printf 'missing %s\n' "$p"; fi
done

printf '\n== Tool detection ==\n'
for c in codex claude node npm pnpm yarn python python3 swift xcodebuild; do
  if command -v "$c" >/dev/null 2>&1; then printf '%-12s %s\n' "$c" "$(command -v "$c")"; fi
done

printf '\n== Likely sensitive files in repo (review before commit) ==\n'
if git rev-parse --show-toplevel >/dev/null 2>&1; then
  find . -maxdepth 4 -type f \( \
    -iname '.env' -o -iname '.env.*' -o -iname '*secret*' -o -iname '*token*' -o \
    -iname '*credential*' -o -iname 'auth.json' -o -iname '*.pem' -o -iname '*.key' -o \
    -iname 'id_rsa' -o -iname 'id_ed25519' \
  \) -not -path './.git/*' | sed 's#^./##' | head -100 || true
fi

printf '\n== Large files > 50MB in repo (review before commit) ==\n'
if git rev-parse --show-toplevel >/dev/null 2>&1; then
  find . -type f -size +50M -not -path './.git/*' -print | sed 's#^./##' | head -100 || true
fi

printf '\nPreflight complete.\n'
