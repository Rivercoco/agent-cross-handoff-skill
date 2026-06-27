# Changelog

## 0.2.0 - Natural-language shortcut routing

- Added bilingual natural-language shortcut examples to `SKILL.md`.
- Added intent inference rules for short Chinese and English commands, including 打包项目, 准备移交项目, 接手项目, 继承项目, package this project, prepare handoff, and resume from handoff.
- Updated README with short command examples for Codex and Claude Code.
- Clarified that `打包项目` means repository-level handoff preparation, not raw credential/session migration.

## 0.1.0 - Initial cross-agent handoff skill

- Supports Codex ↔ Codex, Claude Code ↔ Claude Code, Codex ↔ Claude Code, and cross-OS repository-level handoff.
- Provides preflight and sanitized local agent-state export helpers.
- Generates or updates AGENTS.md, CLAUDE.md, and handoff documentation.
