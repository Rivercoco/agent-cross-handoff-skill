<div align="center">

# Agent Cross Handoff

**在 Codex、Claude Code 和不同电脑之间移交正在开发的项目。**

**简体中文** · [English](./README.en.md)

![Version](https://img.shields.io/badge/version-0.2.0-blue)
![Codex](https://img.shields.io/badge/Codex-supported-2ea44f)
![Claude%20Code](https://img.shields.io/badge/Claude%20Code-supported-7b61ff)
![Platforms](https://img.shields.io/badge/macOS%20%7C%20Windows%20%7C%20Linux-supported-lightgrey)

</div>

---

`agent-cross-handoff` 是一个用于 AI 编程 Agent 的项目交接 Skill。

它不搬运登录态、不复制私有聊天记录，也不打包缓存。它做的是更适合长期维护的事：把一个正在开发的 Git 项目整理成另一台电脑、另一个系统、另一个 Agent 可以接手的状态。

适合这些场景：

- Codex 换到另一台电脑继续开发。
- Claude Code 换到另一台电脑继续开发。
- Codex 开发过的项目交给 Claude Code。
- Claude Code 开发过的项目交给 Codex。
- 在 macOS、Windows、Linux 之间迁移项目。
- 把 Agent 对话里的项目背景整理成仓库中的长期文档。

核心原则很简单：**代码走 Git，项目规则写进 `AGENTS.md`，Claude Code 入口写进 `CLAUDE.md`，交接状态写进 `docs/AI_AGENT_HANDOFF.md`，敏感数据永远不进仓库。**

> [!IMPORTANT]
> 这个 Skill 处理的是“项目交接”，不是“账号搬家”。新机器上仍然应该正常登录 Codex 或 Claude Code。

<details>
<summary>目录</summary>

- [快速上手](#快速上手)
- [常用短句](#常用短句)
- [它会生成什么](#它会生成什么)
- [安装](#安装)
- [推荐工作流](#推荐工作流)
- [包内结构](#包内结构)
- [内置脚本](#内置脚本)
- [安全边界](#安全边界)
- [常见问题](#常见问题)
- [维护建议](#维护建议)
- [参考](#参考)

</details>

---

## 快速上手

解压后进入目录：

```bash
cd /path/to/agent-cross-handoff-skill
```

macOS / Linux：

```bash
bash install.sh
```

Windows PowerShell：

```powershell
.\install.ps1
```

然后在项目根目录里使用短句即可。

Codex：

```text
$agent-cross-handoff 打包项目
```

Claude Code：

```text
/agent-cross-handoff 接手项目
```

也可以直接用自然语言：

```text
调用 agent-cross-handoff 对项目进行打包。
使用 agent-cross-handoff 准备移交项目。
使用 agent-cross-handoff 接手项目。
```

建议写标准名称 `agent-cross-handoff`。Skill 也兼容 `agent cross handoff`、`agent-cross- handoff` 等常见写法，但标准名称最稳定。

---

## 常用短句

大多数情况下不需要写长提示词。

| 你想做什么 | 在 Codex 中输入 | 在 Claude Code 中输入 | 默认行为 |
|---|---|---|---|
| 检查项目是否适合迁移 | `$agent-cross-handoff 检查能否迁移` | `/agent-cross-handoff 检查能否迁移` | 只读检查，不改文件 |
| 打包当前项目 | `$agent-cross-handoff 打包项目` | `/agent-cross-handoff 打包项目` | 创建或更新交接文档 |
| 准备移交项目 | `$agent-cross-handoff 准备移交项目` | `/agent-cross-handoff 准备移交项目` | 整理项目规则和 handoff 文档 |
| 接手一个项目 | `$agent-cross-handoff 接手项目` | `/agent-cross-handoff 接手项目` | 读取交接文档，输出接手计划 |
| 继承一个项目 | `$agent-cross-handoff 继承项目` | `/agent-cross-handoff 继承项目` | 同“接手项目” |
| Codex 交给 Claude Code | `$agent-cross-handoff 从 Codex 迁移到 Claude` | `/agent-cross-handoff 从 Codex 迁移到 Claude` | 准备 `CLAUDE.md` 和兼容说明 |
| Claude Code 交给 Codex | `$agent-cross-handoff 从 Claude 迁移到 Codex` | `/agent-cross-handoff 从 Claude 迁移到 Codex` | 准备 `AGENTS.md` 和兼容说明 |
| 打包本地 Agent 配置 | `$agent-cross-handoff 打包本地 Agent 配置` | `/agent-cross-handoff 打包本地 Agent 配置` | 只导出安全子集 |
| 提交并推送交接分支 | `$agent-cross-handoff 提交并推送移交分支` | `/agent-cross-handoff 提交并推送移交分支` | 通过检查后再 commit / push |

> [!NOTE]
> `打包项目` 默认不会提交或推送。只有你明确说“提交”“推送”“GitHub”“同步”“commit”或“push”时，Skill 才会进入提交和推送流程。

---

## 它会生成什么

在准备移交时，Skill 会引导 Agent 创建或更新这些文件：

```text
AGENTS.md
CLAUDE.md
docs/
  AI_AGENT_HANDOFF.md
  PROJECT_STATUS.md
  BUGS_AND_REGRESSIONS.md
  AGENT_COMPATIBILITY.md
```

这些文件各有用途：

| 文件 | 用途 |
|---|---|
| `AGENTS.md` | 跨 Agent 的项目规则。Codex、Claude Code 和其他工具都可以读取。 |
| `CLAUDE.md` | Claude Code 的入口文件，通常导入 `@AGENTS.md`。 |
| `docs/AI_AGENT_HANDOFF.md` | 当前交接状态：做了什么、还差什么、下一步做什么。 |
| `docs/PROJECT_STATUS.md` | 项目阶段、运行方式、构建方式、测试方式。 |
| `docs/BUGS_AND_REGRESSIONS.md` | 已知问题、复现方式、回归测试记录。 |
| `docs/AGENT_COMPATIBILITY.md` | Codex、Claude Code、其他 Agent 之间的差异说明。 |

接手项目时，Skill 会先读这些文档，再检查当前机器环境，最后给出继续开发计划。默认不会立刻改业务代码。

---

## 安装

### macOS / Linux

```bash
cd /path/to/agent-cross-handoff-skill
bash install.sh
```

安装后会复制到：

```text
Codex:       ~/.agents/skills/agent-cross-handoff
Claude Code: ~/.claude/skills/agent-cross-handoff
```

### Windows PowerShell

```powershell
Set-Location C:\path\to\agent-cross-handoff-skill
.\install.ps1
```

安装后会复制到：

```text
Codex:       %USERPROFILE%\.agents\skills\agent-cross-handoff
Claude Code: %USERPROFILE%\.claude\skills\agent-cross-handoff
```

如果 PowerShell 阻止脚本执行，可以只在当前终端放宽策略：

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\install.ps1
```

### 安装到某个项目仓库

如果希望团队成员 clone 仓库后也能用这个 Skill，可以把它放进项目目录：

```text
项目根目录/.agents/skills/agent-cross-handoff
项目根目录/.claude/skills/agent-cross-handoff
```

示例：

```bash
cd /path/to/your/repo
mkdir -p .agents/skills .claude/skills
cp -R /path/to/agent-cross-handoff-skill/.agents/skills/agent-cross-handoff .agents/skills/
cp -R /path/to/agent-cross-handoff-skill/.claude/skills/agent-cross-handoff .claude/skills/
git add .agents/skills/agent-cross-handoff .claude/skills/agent-cross-handoff
git commit -m "chore: add agent cross handoff skill"
```

个人常用建议安装到用户目录；团队共享建议安装到项目仓库。

---

## 推荐工作流

### 1. 在源机器上准备移交

进入项目根目录：

```bash
cd /path/to/your/project
```

先检查：

```text
$agent-cross-handoff 检查能否迁移
```

然后打包项目上下文：

```text
$agent-cross-handoff 准备移交项目
```

如果你希望直接同步到 GitHub：

```text
$agent-cross-handoff 提交并推送移交分支
```

Skill 会优先检查敏感文件、未提交改动、远程仓库和 worktree 状态。检查没过时，不应继续 push。

### 2. 在目标机器上接手

克隆项目：

```bash
git clone <repo-url>
cd <repo-name>
```

接手：

```text
$agent-cross-handoff 接手项目
```

在 Claude Code 中则使用：

```text
/agent-cross-handoff 接手项目
```

接手时应先看计划，再决定是否让 Agent 开始修改代码。

### 3. Codex 与 Claude Code 之间迁移

Codex 交给 Claude Code：

```text
$agent-cross-handoff 从 Codex 迁移到 Claude
```

Claude Code 交给 Codex：

```text
/agent-cross-handoff 从 Claude 迁移到 Codex
```

这类迁移的重点不是复制某个工具的私有状态，而是把可复用的工程规则和当前进度写进仓库。

---

## 包内结构

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

说明：

| 路径 | 说明 |
|---|---|
| `.agents/skills/agent-cross-handoff/` | Codex 使用的 Skill。 |
| `.claude/skills/agent-cross-handoff/` | Claude Code 使用的 Skill。 |
| `SKILL.md` | Skill 的入口和规则文件。 |
| `scripts/preflight.*` | 只读预检脚本。 |
| `scripts/export_agent_state.*` | 安全导出本地 Agent 配置子集。 |
| `assets/templates/` | 项目交接文档模板。 |
| `references/SECURITY_NOTES.md` | 安全说明。 |
| `references/SHORT_INVOCATIONS.md` | 短句调用速查表。 |

---

## 内置脚本

一般情况下，让 Codex 或 Claude Code 调用 Skill 即可，不需要手动运行脚本。需要排查问题时，可以直接执行。

macOS / Linux 预检：

```bash
bash ~/.agents/skills/agent-cross-handoff/scripts/preflight.sh
```

Windows PowerShell 预检：

```powershell
& "$HOME\.agents\skills\agent-cross-handoff\scripts\preflight.ps1"
```

macOS / Linux 导出安全配置子集：

```bash
bash ~/.agents/skills/agent-cross-handoff/scripts/export_agent_state.sh
```

Windows PowerShell 导出安全配置子集：

```powershell
& "$HOME\.agents\skills\agent-cross-handoff\scripts\export_agent_state.ps1"
```

导出的本地配置只包含可复用的安全子集，例如个人 Skills、部分非敏感配置、部分已整理的记忆文件。导出包会带 `MANIFEST.txt`，用来说明包含了什么、排除了什么。

---

## 安全边界

会迁移或整理：

- Git 仓库、分支、提交、tag。
- 项目级说明文件和交接文档。
- `AGENTS.md`、`CLAUDE.md`、`.claude/rules/` 中可公开的项目规则。
- 经用户确认、已经清洗过的本地记忆摘要。
- 可复用的 Skills 和模板。

不会自动迁移：

- Codex 登录态。
- Claude Code 登录态。
- `~/.codex/auth.json`。
- `~/.claude` 中的 auth / session 数据库。
- API key、token、`.env`、SSH 私钥、cookie。
- 系统钥匙串或凭据管理器内容。
- 原始聊天记录、未清洗的本地记忆数据库。
- 日志、缓存、依赖目录、构建产物、crash dump。

> [!WARNING]
> 不要把 `auth.json`、`.env`、私钥、token、cookie 或任何凭据提交到 Git。这个 Skill 的默认策略是排除它们；如果预检发现可疑文件，应先人工确认。

---

## 常见问题

### 这个 Skill 能不能迁移完整聊天记录？

不做。聊天记录通常包含无关内容、私密信息和临时推理。更稳妥的方式是让 Agent 把有用信息整理成摘要，写入 `docs/AI_AGENT_HANDOFF.md`。

### 能不能迁移登录态？

不做。新机器应该重新登录 Codex 或 Claude Code。登录态、token 和系统凭据不适合被脚本打包。

### 只说“打包项目”够不够？

够。Skill 会把它理解为准备仓库级交接文档。默认不会 commit / push。

### 为什么默认不提交和推送？

因为项目里可能有未检查的敏感文件或大文件。只有你明确说“提交并推送”“同步到 GitHub”“commit and push”时，Skill 才会走 Git 提交流程。

### 当前目录不是 Git 仓库怎么办？

Skill 会要求你提供本地仓库路径或 Git remote URL。项目交接应以 Git 仓库为核心，否则很容易丢分支、历史和未提交改动。

### macOS 上用 Codex CLI 支持吗？

支持。macOS + Codex CLI 是推荐场景之一。项目上下文通过 Git 和仓库文档迁移，和桌面应用不是同一件事。

### 可以支持 Cursor、Windsurf、Copilot 等其他工具吗？

可以部分支持。它们至少可以读取仓库里的 `AGENTS.md`、README 和 docs。但本包内置的 Skill 目录主要面向 Codex 和 Claude Code。

### 安装后没有识别 Skill 怎么办？

先确认目录存在：

```text
~/.agents/skills/agent-cross-handoff/SKILL.md
~/.claude/skills/agent-cross-handoff/SKILL.md
```

然后重启 Codex 或 Claude Code，再重新调用。

---

## 维护建议

- 修改规则时，优先改 `.agents/skills/agent-cross-handoff/SKILL.md`。
- 安装脚本会把 `.agents` 里的 Skill 复制到 Codex 和 Claude Code 的用户目录，因此两边内容应保持一致。
- 如果你新增短句触发规则，请同步更新 `references/SHORT_INVOCATIONS.md`。
- 如果你新增模板，请放在 `assets/templates/`。

---

## 参考

- [Codex Skills](https://developers.openai.com/codex/skills)
- [Codex AGENTS.md](https://developers.openai.com/codex/guides/agents-md)
- [Claude Code Skills](https://code.claude.com/docs/en/skills)
- [Claude Code Memory](https://code.claude.com/docs/en/memory)

---

## License / 许可证

This project is released under the MIT License. See [LICENSE](./LICENSE) for details.

本项目基于 MIT License 开源，详情见 [LICENSE](./LICENSE)。
