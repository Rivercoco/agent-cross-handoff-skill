param([string]$Output = "agent-state-safe-export-$(Get-Date -Format yyyyMMdd-HHmmss).zip")
$ErrorActionPreference = "Continue"
$temp = Join-Path ([System.IO.Path]::GetTempPath()) ("agent-export-" + [System.Guid]::NewGuid())
New-Item -ItemType Directory -Path "$temp/export" -Force | Out-Null
$manifest = Join-Path $temp "export/MANIFEST.txt"
@("Agent safe state export", (Get-Date), "Excluded: credentials, auth.json, tokens, caches, logs, .env, private keys") | Set-Content $manifest
function Copy-Safe($src, $dst) {
  if (Test-Path $src) {
    $target = Join-Path "$temp/export" $dst
    New-Item -ItemType Directory -Path (Split-Path $target -Parent) -Force | Out-Null
    Copy-Item $src $target -Recurse -Force -ErrorAction SilentlyContinue
    Add-Content $manifest "Included: $src -> $dst"
  }
}
Copy-Safe "$HOME/.agents/skills" "codex-user-skills"
Copy-Safe "$HOME/.codex/AGENTS.md" "codex/AGENTS.md"
Copy-Safe "$HOME/.codex/config.toml" "codex/config.toml"
Copy-Safe "$HOME/.codex/memories" "codex/memories"
Copy-Safe "$HOME/.claude/skills" "claude-user-skills"
Copy-Safe "$HOME/.claude/CLAUDE.md" "claude/CLAUDE.md"
Copy-Safe "$HOME/.claude/settings.json" "claude/settings.json"
Get-ChildItem "$temp/export" -Recurse -Force | Where-Object { $_.Name -match 'auth\.json|\.env|token|secret|\.pem$|\.key$' } | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
Compress-Archive -Path "$temp/export" -DestinationPath $Output -Force
Remove-Item $temp -Recurse -Force
Write-Host "Created $Output"
