# Short Invocation Guide

This reference lists the short phrases that `agent-cross-handoff` should treat as sufficient user intent.

## Chinese shortcuts

| User phrase | Mode |
|---|---|
| 调用 agent-cross-handoff 对项目进行打包 | export-project |
| 使用 agent-cross-handoff 准备移交项目 | export-project |
| 使用 agent-cross-handoff 接手项目 | import-project |
| 使用 agent-cross-handoff 继承项目 | import-project |
| 使用 agent-cross-handoff 检查能否迁移 | check |
| 用 agent-cross-handoff 从 Codex 迁移到 Claude | codex-to-claude + export-project |
| 用 agent-cross-handoff 从 Claude 迁移到 Codex | claude-to-codex + export-project |
| 用 agent-cross-handoff 打包本地 Agent 配置 | export-local-agent-state |
| 用 agent-cross-handoff 导入本地 Agent 配置 | import-local-agent-state |
| 使用 agent-cross-handoff 提交并推送移交分支 | export-project + commit/push intent |

## English shortcuts

| User phrase | Mode |
|---|---|
| Use agent-cross-handoff to package this project | export-project |
| Prepare this project for handoff | export-project |
| Take over this project | import-project |
| Resume this project | import-project |
| Check whether this project is ready to migrate | check |
| Move this project from Codex to Claude Code | codex-to-claude + export-project |
| Move this project from Claude Code to Codex | claude-to-codex + export-project |
| Export local agent state | export-local-agent-state |
| Import local agent state | import-local-agent-state |
| Commit and push the handoff branch | export-project + commit/push intent |

## Default behavior

- Prefer action over asking for a long prompt.
- Ask at most one essential clarification when the repo path, repo URL, or push target is missing.
- Never migrate credentials, auth files, API keys, raw memory databases, logs, caches, or build/dependency outputs.
- Do not commit or push unless the user explicitly mentions commit, push, GitHub, upload, sync, 提交, 推送, GitHub, 上传, or 同步.
