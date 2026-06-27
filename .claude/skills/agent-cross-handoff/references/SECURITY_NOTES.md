# Security Notes

Do not put raw agent state into a Git repository. Raw state may contain credentials, prompts, user data, logs, API keys, local paths, and vendor-specific session data.

Prefer durable summaries:

- stable project facts → `AGENTS.md`
- current migration status → `docs/AI_AGENT_HANDOFF.md`
- known issues → `docs/BUGS_AND_REGRESSIONS.md`
- tool compatibility → `docs/AGENT_COMPATIBILITY.md`

Never commit:

- `~/.codex/auth.json`
- `~/.claude` auth/session databases
- `.env` or `.env.*`
- SSH private keys, `*.pem`, `*.key`
- browser cookies or credential stores
- raw chat transcripts containing private context
