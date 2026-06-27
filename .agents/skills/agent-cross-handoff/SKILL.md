---
name: agent-cross-handoff
description: Cross-agent project migration and handoff workflow for Codex, Claude Code, and other coding agents. Use when the user wants to package, export, hand off, transfer, resume, inherit, import, or take over a Git project across machines, OSes, Codex CLI/App, Claude Code, or other agents. Also use for short Chinese requests such as 打包项目, 准备移交项目, 接手项目, 继承项目, 迁移到 Claude, 迁移到 Codex, 检查能否迁移, or 打包本地 Agent 配置.
---

# Agent Cross Handoff

Use this skill to move a project between machines and between AI coding agents, especially Codex ↔ Claude Code. The goal is not to clone private chat history or login state. The goal is to make the repository itself carry enough project context that another agent can continue safely.

## Natural-language shortcut router

This skill is designed so users do not need to write long prompts. Treat short natural-language requests as sufficient when the intent is clear.

Accept these equivalent skill names and spellings as referring to this skill:

- `agent-cross-handoff`
- `agent cross handoff`
- `agent-cross- handoff`
- `Agent Cross Handoff`

### Primary shortcut intents

Use the following routing table before asking clarifying questions.

| User says, in Chinese or English | Inferred mode | Default action |
|---|---|---|
| `打包项目`, `对项目进行打包`, `package this project`, `export this project` | `export-project` | Prepare repository-level handoff files. Do not copy credentials. |
| `准备移交项目`, `移交项目`, `交接项目`, `prepare handoff`, `handoff this project` | `export-project` | Run check, normalize memory, create/update handoff docs. |
| `接手项目`, `继承项目`, `恢复项目`, `继续这个项目`, `resume/take over/import this project` | `import-project` | Read existing handoff docs and produce a continuation plan before editing code. |
| `检查能否迁移`, `预检`, `检查项目`, `check migration readiness` | `check` | Run a read-only repository and environment check. |
| `从 Codex 交给 Claude`, `迁移到 Claude`, `Codex to Claude` | `codex-to-claude` + `export-project` | Create/update `CLAUDE.md`, preserve `AGENTS.md`, prepare handoff docs. |
| `从 Claude 交给 Codex`, `迁移到 Codex`, `Claude to Codex` | `claude-to-codex` + `export-project` | Extract durable project rules into `AGENTS.md`, prepare handoff docs. |
| `打包本地 Agent 配置`, `导出本地 Agent 状态`, `export local agent state` | `export-local-agent-state` | Create a sanitized state archive and manifest; exclude credentials and raw secrets. |
| `导入本地 Agent 配置`, `恢复本地 Agent 状态`, `import local agent state` | `import-local-agent-state` | Inspect archive, back up existing config, refuse credential-like contents by default. |
| `同步到 GitHub`, `提交并推送`, `commit and push handoff` | `export-project` with Git commit/push intent | Commit handoff files to a handoff branch and push only if repository checks pass. |

### Default assumptions

When the user uses a short request, apply these defaults:

1. The source agent is the currently running agent unless the user names another source.
2. The destination agent is `unknown / to be decided` unless the user names Codex, Claude Code, another agent, or another machine.
3. The current working directory is the project if it is inside a Git repository.
4. If the user says `打包`, `移交`, `导出`, `package`, `handoff`, or `export`, prefer `export-project`.
5. If the user says `接手`, `继承`, `恢复`, `导入`, `resume`, `take over`, or `import`, prefer `import-project`.
6. If the current directory is not a Git repository during export/import, ask for exactly one missing detail: the local repository path or the Git remote URL.
7. Do not ask the user to restate a long prompt. If the intent is clear enough, execute the relevant mode.
8. Do not commit or push unless the user says `提交`, `推送`, `GitHub`, `上传`, `同步`, `commit`, or `push`.
9. It is acceptable to create or update handoff Markdown files for export when the user says `打包项目` or `准备移交项目`.
10. Never include credentials, login state, `.env` files, private keys, raw chat logs, raw local memory databases, logs, caches, or dependency/build outputs in the handoff.

### Minimal command examples

Codex examples:

```text
$agent-cross-handoff 打包项目
$agent-cross-handoff 准备移交项目
$agent-cross-handoff 接手项目
$agent-cross-handoff 从 Codex 迁移到 Claude
$agent-cross-handoff 从 Claude 迁移到 Codex
$agent-cross-handoff 检查能否迁移
```

Claude Code examples:

```text
/agent-cross-handoff 打包项目
/agent-cross-handoff 准备移交项目
/agent-cross-handoff 接手项目
/agent-cross-handoff 从 Codex 迁移到 Claude
/agent-cross-handoff 从 Claude 迁移到 Codex
/agent-cross-handoff 检查能否迁移
```

Plain natural-language examples, when automatic skill selection is available:

```text
调用 agent-cross-handoff 对项目进行打包。
使用 agent-cross-handoff 准备移交项目。
使用 agent-cross-handoff 接手项目。
用 agent-cross-handoff 把这个 Claude 项目交给 Codex 继续开发。
用 agent-cross-handoff 检查这个项目能不能迁移。
```

### Ambiguity handling

Ask a clarification only when execution is impossible or unsafe. Examples:

- If the user says `接手项目` outside any repository and provides no repository URL, ask for the repo URL or local path.
- If the user asks to push but no remote exists, ask for the remote name/URL or provide the exact commands to add one.
- If likely secrets are detected, stop before commit/push and explain which paths require review.
- If the user asks to migrate login state or raw memory, refuse that part and offer a sanitized repository summary instead.


## Supported directions

- Codex → Codex
- Claude Code → Claude Code
- Codex → Claude Code
- Claude Code → Codex
- macOS ↔ Windows ↔ Linux, where the destination agent and toolchain are installed
- CLI ↔ desktop app when both read the same Git repository and project instruction files

## Boundaries

Do migrate:
- Git repository, branches, commits, tags, and PR-ready diffs
- `AGENTS.md` as canonical cross-agent project instructions
- `CLAUDE.md` or `.claude/CLAUDE.md` as Claude Code entrypoint
- `.claude/rules/` when project-specific Claude rules exist
- `.agents/skills/` and `.claude/skills/` when the project intentionally shares skills
- `docs/AI_AGENT_HANDOFF.md`, `docs/PROJECT_STATUS.md`, `docs/BUGS_AND_REGRESSIONS.md`, `docs/AGENT_COMPATIBILITY.md`
- Explicitly approved, sanitized local memories summarized into repository docs

Do not migrate automatically:
- `~/.codex/auth.json`
- `~/.claude` auth/session databases
- API keys, `.env`, SSH private keys, tokens, browser cookies, keychains, credential stores
- Build outputs, dependency directories, package caches, logs, or crash dumps
- Tool-internal conversation history unless the user explicitly requests a sanitized summary

## Canonical memory strategy

Use `AGENTS.md` as the shared, agent-neutral root instruction file. Keep it concise and stable.

For Claude Code, create `CLAUDE.md` with this shape:

```markdown
@AGENTS.md

## Claude Code

- Claude-specific workflow notes go here.
- Prefer plan mode before broad refactors.
- Use `.claude/rules/` for path-scoped rules when needed.
```

For Codex, keep `AGENTS.md` at the repository root and optionally add `.codex/config.toml` only for non-secret project configuration.

For both tools, create `docs/AI_AGENT_HANDOFF.md` for fast continuation. This file should explain the current project state, recent changes, next tasks, risks, test commands, and files that should not be casually rewritten.

## Operating modes

When invoked, infer the mode from the user request. If unclear, run `check` first and then ask for the smallest missing detail.

### check

Inspect the current repository and machine without changing files.

1. Locate the Git repository root.
2. Report OS, shell, Git version, current branch, remotes, worktrees, uncommitted changes, and untracked files.
3. Detect Codex files: `AGENTS.md`, `.codex/`, `.agents/skills/`, `~/.codex`, `~/.agents/skills`.
4. Detect Claude files: `CLAUDE.md`, `.claude/CLAUDE.md`, `.claude/rules/`, `.claude/skills/`, `~/.claude`, `~/.claude/skills`.
5. Flag likely secrets or files that should not be committed.
6. Recommend the safest next mode.

Suggested scripts:
- macOS/Linux: `scripts/preflight.sh`
- Windows PowerShell: `scripts/preflight.ps1`

### normalize-project-memory

Create or update agent-neutral project instructions.

1. Read existing `AGENTS.md`, `CLAUDE.md`, `.claude/CLAUDE.md`, README, package/build files, and docs.
2. Preserve any valid existing instructions.
3. Create/update `AGENTS.md` as the canonical shared file.
4. Create/update `CLAUDE.md` so it imports `@AGENTS.md` and includes only Claude-specific additions.
5. If `.claude/rules/` exists, summarize its purpose in `docs/AGENT_COMPATIBILITY.md` rather than duplicating large content.
6. Add `CLAUDE.local.md`, `.env`, credential files, build outputs, logs, and local memory exports to `.gitignore` if appropriate.

### export-project

Prepare the source project for another machine or another agent.

1. Run `check`.
2. Run `normalize-project-memory`.
3. Create/update:
   - `docs/AI_AGENT_HANDOFF.md`
   - `docs/PROJECT_STATUS.md`
   - `docs/BUGS_AND_REGRESSIONS.md`
   - `docs/AGENT_COMPATIBILITY.md`
4. Include source agent, destination agent, OS, branch, tag, commit hash, build/test commands, known problems, and next recommended task.
5. Ask before committing if the user has not explicitly requested commit/push.
6. If asked to commit/push, create a branch such as `handoff/<agent>-to-<agent>-YYYYMMDD` and optionally a tag such as `handoff-YYYYMMDD-<shortsha>`.

### import-project

Resume the project on a destination machine or destination agent.

1. Clone or open the repository.
2. Checkout the requested branch/tag, or infer the latest `handoff/*` branch.
3. Read `AGENTS.md`, `CLAUDE.md` if present, and all docs under `docs/*HANDOFF*`, `docs/PROJECT_STATUS.md`, and `docs/BUGS_AND_REGRESSIONS.md`.
4. Run `check`.
5. Verify toolchain availability and list missing tools.
6. Do not modify code until the user confirms the continuation plan, unless the user explicitly asked for autonomous continuation.
7. Produce `docs/AI_AGENT_RESUME_REPORT.md` if asked.

### codex-to-claude

Use when a project was developed with Codex and will continue in Claude Code.

1. Treat `AGENTS.md` as canonical.
2. If `CLAUDE.md` is missing, create it with `@AGENTS.md` and a short Claude-specific section.
3. Translate Codex-specific workflow notes into neutral rules where possible.
4. Convert Codex-only skill notes into either:
   - a shared skill under both `.agents/skills/<name>/` and `.claude/skills/<name>/`, or
   - a doc entry under `docs/AGENT_COMPATIBILITY.md` if execution semantics differ.
5. Do not copy `~/.codex/auth.json`, logs, caches, or credentials.

### claude-to-codex

Use when a project was developed with Claude Code and will continue in Codex.

1. Read `CLAUDE.md` and `.claude/CLAUDE.md`.
2. If `AGENTS.md` is missing, create it from durable project-level content in Claude instructions.
3. Keep `CLAUDE.md` as an import wrapper around `@AGENTS.md` plus Claude-only notes.
4. Summarize `.claude/rules/` into `docs/AGENT_COMPATIBILITY.md`; keep the rules themselves only if the repo will continue supporting Claude Code.
5. If the user explicitly asks to include Claude auto memory, inspect it, remove secrets and volatile chatter, and summarize durable facts into `docs/AI_AGENT_HANDOFF.md`. Do not commit raw auto memory by default.

### export-local-agent-state

Optional. Create a sanitized archive of reusable agent configuration.

1. Include only safe files that the user explicitly approves.
2. Prefer exporting skills and instruction templates over sessions.
3. Exclude credentials, tokens, caches, logs, browser state, and private keys.
4. Create a manifest listing every included file and every excluded class.

Suggested scripts:
- macOS/Linux: `scripts/export_agent_state.sh`
- Windows PowerShell: `scripts/export_agent_state.ps1`

### import-local-agent-state

Optional. Import a sanitized archive onto a new machine.

1. Backup existing target folders first.
2. Refuse archives that contain credential-like filenames by default.
3. Install shared skills to the correct tool-specific location:
   - Codex personal skills: `~/.agents/skills/`
   - Claude Code personal skills: `~/.claude/skills/`
4. Do not overwrite user configuration without a backup and explicit approval.

## Output requirements

When running this skill, always state:
- Source agent and destination agent, if known
- Source OS and destination OS, if known
- Which files will be changed
- Which files will not be migrated for security reasons
- Whether the repository is safe to commit/push
- The exact next command the user should run in the destination agent

## Handoff document minimum content

`docs/AI_AGENT_HANDOFF.md` must include:

```markdown
# AI Agent Handoff

## Source and destination

- Source agent:
- Destination agent:
- Source OS:
- Destination OS:
- Repository:
- Branch/tag:
- Last verified commit:

## Current project goal

## Current state

## Recent changes

## Known bugs and regressions

## Build, run, and test commands

## High-risk files

## Do-not-do list

## Next recommended task

## Verification checklist
```

## Safety rule

If a requested migration would copy credentials, login state, private keys, `.env` files, raw chat logs, or raw local memories into a repository, refuse that part and offer a sanitized summary instead.
