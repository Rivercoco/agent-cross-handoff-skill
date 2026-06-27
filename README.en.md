<div align="center">

# Agent Cross Handoff

**Hand off active projects between Codex, Claude Code, and different machines.**

[简体中文](./README.md) · **English**

![Version](https://img.shields.io/badge/version-0.2.0-blue)
![Codex](https://img.shields.io/badge/Codex-supported-2ea44f)
![Claude%20Code](https://img.shields.io/badge/Claude%20Code-supported-7b61ff)
![Platforms](https://img.shields.io/badge/macOS%20%7C%20Windows%20%7C%20Linux-supported-lightgrey)

</div>

---

`agent-cross-handoff` is a project handoff Skill for AI coding agents.

It does not move login state, private chat history, or caches. It does something more durable: it turns an in-progress Git project into a state that another machine, another operating system, or another agent can continue safely.

It is useful when you need to:

- Continue a Codex project on another machine.
- Continue a Claude Code project on another machine.
- Move a project from Codex to Claude Code.
- Move a project from Claude Code to Codex.
- Move a project across macOS, Windows, and Linux.
- Convert project context from agent conversations into long-lived repository documents.

The rule is simple: **code lives in Git, project rules live in `AGENTS.md`, the Claude Code entry point lives in `CLAUDE.md`, handoff status lives in `docs/AI_AGENT_HANDOFF.md`, and secrets never enter the repository.**

> [!IMPORTANT]
> This Skill handles project handoff. It is not an account migration tool. On the destination machine, log in to Codex or Claude Code normally.

<details>
<summary>Table of contents</summary>

- [Quick start](#quick-start)
- [Short commands](#short-commands)
- [What it creates](#what-it-creates)
- [Installation](#installation)
- [Recommended workflow](#recommended-workflow)
- [Package structure](#package-structure)
- [Built-in scripts](#built-in-scripts)
- [Security boundary](#security-boundary)
- [FAQ](#faq)
- [Maintenance notes](#maintenance-notes)
- [References](#references)

</details>

---

## Quick start

After extracting the package, enter the directory:

```bash
cd /path/to/agent-cross-handoff-skill
```

macOS / Linux:

```bash
bash install.sh
```

Windows PowerShell:

```powershell
.\install.ps1
```

Then use a short command from the project root.

Codex:

```text
$agent-cross-handoff package this project
```

Claude Code:

```text
/agent-cross-handoff take over this project
```

Plain natural language also works when the client can select the Skill automatically:

```text
Use agent-cross-handoff to package this project.
Use agent-cross-handoff to prepare this project for handoff.
Use agent-cross-handoff to take over this project.
```

The recommended spelling is `agent-cross-handoff`. The Skill also accepts common variants such as `agent cross handoff` and `agent-cross- handoff`, but the standard name is the most reliable.

---

## Short commands

Most handoff tasks do not need a long prompt.

| Goal | In Codex | In Claude Code | Default behavior |
|---|---|---|---|
| Check whether the project is ready to migrate | `$agent-cross-handoff check migration readiness` | `/agent-cross-handoff check migration readiness` | Read-only check |
| Package the current project | `$agent-cross-handoff package this project` | `/agent-cross-handoff package this project` | Create or update handoff docs |
| Prepare a handoff | `$agent-cross-handoff prepare handoff` | `/agent-cross-handoff prepare handoff` | Normalize project rules and handoff docs |
| Take over a project | `$agent-cross-handoff take over this project` | `/agent-cross-handoff take over this project` | Read handoff docs and produce a continuation plan |
| Resume a project | `$agent-cross-handoff resume this project` | `/agent-cross-handoff resume this project` | Same as “take over” |
| Move from Codex to Claude Code | `$agent-cross-handoff move from Codex to Claude` | `/agent-cross-handoff move from Codex to Claude` | Prepare `CLAUDE.md` and compatibility notes |
| Move from Claude Code to Codex | `$agent-cross-handoff move from Claude to Codex` | `/agent-cross-handoff move from Claude to Codex` | Prepare `AGENTS.md` and compatibility notes |
| Export local agent configuration | `$agent-cross-handoff export local agent state` | `/agent-cross-handoff export local agent state` | Export a safe subset only |
| Commit and push the handoff branch | `$agent-cross-handoff commit and push handoff` | `/agent-cross-handoff commit and push handoff` | Commit / push after checks pass |

> [!NOTE]
> `package this project` does not commit or push by default. The Skill enters commit / push mode only when you explicitly mention “commit”, “push”, “GitHub”, “upload”, or “sync”.

---

## What it creates

When preparing a handoff, the Skill guides the agent to create or update these files:

```text
AGENTS.md
CLAUDE.md
docs/
  AI_AGENT_HANDOFF.md
  PROJECT_STATUS.md
  BUGS_AND_REGRESSIONS.md
  AGENT_COMPATIBILITY.md
```

Each file has a narrow job:

| File | Purpose |
|---|---|
| `AGENTS.md` | Shared project rules for Codex, Claude Code, and other agents. |
| `CLAUDE.md` | Claude Code entry point, usually importing `@AGENTS.md`. |
| `docs/AI_AGENT_HANDOFF.md` | Current handoff state: what changed, what remains, what to do next. |
| `docs/PROJECT_STATUS.md` | Project stage, run commands, build commands, and test commands. |
| `docs/BUGS_AND_REGRESSIONS.md` | Known issues, reproduction notes, and regression checks. |
| `docs/AGENT_COMPATIBILITY.md` | Differences between Codex, Claude Code, and other agents. |

When taking over a project, the Skill reads these documents first, checks the destination environment, and then produces a continuation plan. It does not edit application code by default.

---

## Installation

### macOS / Linux

```bash
cd /path/to/agent-cross-handoff-skill
bash install.sh
```

After installation, the Skill is copied to:

```text
Codex:       ~/.agents/skills/agent-cross-handoff
Claude Code: ~/.claude/skills/agent-cross-handoff
```

### Windows PowerShell

```powershell
Set-Location C:\path\to\agent-cross-handoff-skill
.\install.ps1
```

After installation, the Skill is copied to:

```text
Codex:       %USERPROFILE%\.agents\skills\agent-cross-handoff
Claude Code: %USERPROFILE%\.claude\skills\agent-cross-handoff
```

If PowerShell blocks script execution, loosen the policy only for the current terminal session:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\install.ps1
```

### Install into a project repository

To make this Skill available to everyone who clones a repository, place it inside the project:

```text
<repo>/.agents/skills/agent-cross-handoff
<repo>/.claude/skills/agent-cross-handoff
```

Example:

```bash
cd /path/to/your/repo
mkdir -p .agents/skills .claude/skills
cp -R /path/to/agent-cross-handoff-skill/.agents/skills/agent-cross-handoff .agents/skills/
cp -R /path/to/agent-cross-handoff-skill/.claude/skills/agent-cross-handoff .claude/skills/
git add .agents/skills/agent-cross-handoff .claude/skills/agent-cross-handoff
git commit -m "chore: add agent cross handoff skill"
```

Install to the user directory for personal reuse. Install to a project repository for team sharing.

---

## Recommended workflow

### 1. Prepare handoff on the source machine

Enter the project root:

```bash
cd /path/to/your/project
```

Run a check first:

```text
$agent-cross-handoff check migration readiness
```

Then package the project context:

```text
$agent-cross-handoff prepare handoff
```

To sync the handoff branch to GitHub:

```text
$agent-cross-handoff commit and push handoff
```

The Skill checks for sensitive files, uncommitted changes, remotes, and worktree state first. If the check fails, do not push until the issue is reviewed.

### 2. Take over on the destination machine

Clone the project:

```bash
git clone <repo-url>
cd <repo-name>
```

Take over in Codex:

```text
$agent-cross-handoff take over this project
```

Or in Claude Code:

```text
/agent-cross-handoff take over this project
```

Review the continuation plan before allowing the agent to edit code.

### 3. Move between Codex and Claude Code

Codex to Claude Code:

```text
$agent-cross-handoff move from Codex to Claude
```

Claude Code to Codex:

```text
/agent-cross-handoff move from Claude to Codex
```

The point is not to copy private tool state. The point is to write reusable engineering rules and current progress into the repository.

---

## Package structure

```text
agent-cross-handoff-skill/
  README.md
  README.en.md
  CHANGELOG.md
  install.sh
  install.ps1
  .agents/
    skills/
      agent-cross-handoff/
        SKILL.md
        scripts/
          preflight.sh
          preflight.ps1
          export_agent_state.sh
          export_agent_state.ps1
        assets/
          templates/
            AGENTS.template.md
            CLAUDE.template.md
            AI_AGENT_HANDOFF.template.md
            AGENT_COMPATIBILITY.template.md
        references/
          SECURITY_NOTES.md
          SHORT_INVOCATIONS.md
  .claude/
    skills/
      agent-cross-handoff/
        SKILL.md
        scripts/
        assets/
        references/
```

Notes:

| Path | Description |
|---|---|
| `.agents/skills/agent-cross-handoff/` | Skill used by Codex. |
| `.claude/skills/agent-cross-handoff/` | Skill used by Claude Code. |
| `SKILL.md` | Skill entry point and rules. |
| `scripts/preflight.*` | Read-only preflight scripts. |
| `scripts/export_agent_state.*` | Safe local agent-state export helpers. |
| `assets/templates/` | Handoff document templates. |
| `references/SECURITY_NOTES.md` | Security notes. |
| `references/SHORT_INVOCATIONS.md` | Short command reference. |

---

## Built-in scripts

In normal use, ask Codex or Claude Code to invoke the Skill. You only need to run scripts directly when debugging.

macOS / Linux preflight:

```bash
bash ~/.agents/skills/agent-cross-handoff/scripts/preflight.sh
```

Windows PowerShell preflight:

```powershell
& "$HOME\.agents\skills\agent-cross-handoff\scripts\preflight.ps1"
```

macOS / Linux safe local-state export:

```bash
bash ~/.agents/skills/agent-cross-handoff/scripts/export_agent_state.sh
```

Windows PowerShell safe local-state export:

```powershell
& "$HOME\.agents\skills\agent-cross-handoff\scripts\export_agent_state.ps1"
```

The local-state export contains only a safe subset, such as user Skills, selected non-secret configuration, and curated memory files. The archive includes `MANIFEST.txt`, which lists what was included and what was excluded.

---

## Security boundary

May be migrated or summarized:

- Git repository, branches, commits, and tags.
- Project instruction files and handoff documents.
- Public project rules from `AGENTS.md`, `CLAUDE.md`, and `.claude/rules/`.
- User-approved, sanitized memory summaries.
- Reusable Skills and templates.

Will not be migrated automatically:

- Codex login state.
- Claude Code login state.
- `~/.codex/auth.json`.
- Auth / session databases under `~/.claude`.
- API keys, tokens, `.env` files, SSH private keys, or cookies.
- System keychain or credential-manager data.
- Raw chat history or unreviewed local memory databases.
- Logs, caches, dependency directories, build outputs, or crash dumps.

> [!WARNING]
> Do not commit `auth.json`, `.env`, private keys, tokens, cookies, or any credential file to Git. This Skill excludes them by default; if preflight detects a suspicious file, review it manually before committing.

---

## FAQ

### Can this Skill migrate full chat history?

No. Chat history often contains unrelated content, private details, and temporary reasoning. Ask the agent to summarize useful facts into `docs/AI_AGENT_HANDOFF.md` instead.

### Can it migrate login state?

No. Log in to Codex or Claude Code again on the destination machine. Login state, tokens, and system credentials should not be packed by scripts.

### Is “package this project” enough?

Yes. The Skill treats it as a request to prepare repository-level handoff documents. It does not commit or push by default.

### Why does it not commit and push automatically?

The repository may contain secrets or large files that need review. The Skill enters commit / push mode only when you explicitly ask it to “commit and push”, “sync to GitHub”, or similar.

### What if the current directory is not a Git repository?

The Skill asks for a local repository path or Git remote URL. Project handoff should be Git-centered; otherwise branches, history, and in-progress changes are easy to lose.

### Does it support Codex CLI on macOS?

Yes. macOS + Codex CLI is one of the recommended setups. Project context is migrated through Git and repository documents, not through desktop app state.

### Can it work with Cursor, Windsurf, Copilot, or other tools?

Partially. Other tools can still read `AGENTS.md`, README, and docs. The packaged Skill directories are mainly for Codex and Claude Code.

### The Skill is not detected after installation. What should I check?

Confirm these files exist:

```text
~/.agents/skills/agent-cross-handoff/SKILL.md
~/.claude/skills/agent-cross-handoff/SKILL.md
```

Then restart Codex or Claude Code and try again.

---

## Maintenance notes

- Edit `.agents/skills/agent-cross-handoff/SKILL.md` first when changing rules.
- The installer copies the `.agents` Skill into both Codex and Claude Code user locations, so both copies should stay equivalent.
- If you add short command routing, update `references/SHORT_INVOCATIONS.md` as well.
- Put new templates under `assets/templates/`.
- If you publish this project on GitHub, keep `CHANGELOG.md` and add an appropriate `LICENSE` file.

---

## References

- [Codex Skills](https://developers.openai.com/codex/skills)
- [Codex AGENTS.md](https://developers.openai.com/codex/guides/agents-md)
- [Claude Code Skills](https://code.claude.com/docs/en/skills)
- [Claude Code Memory](https://code.claude.com/docs/en/memory)

---

## License

No license is included by default. Before publishing on GitHub, add a `LICENSE` file that matches how you want others to use the project.

