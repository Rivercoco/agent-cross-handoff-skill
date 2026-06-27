$ErrorActionPreference = "Stop"
$srcDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$skillSrc = Join-Path $srcDir ".agents/skills/agent-cross-handoff"
$codexDest = Join-Path $HOME ".agents/skills/agent-cross-handoff"
$claudeDest = Join-Path $HOME ".claude/skills/agent-cross-handoff"
New-Item -ItemType Directory -Path (Split-Path $codexDest -Parent) -Force | Out-Null
New-Item -ItemType Directory -Path (Split-Path $claudeDest -Parent) -Force | Out-Null
if (Test-Path $codexDest) { Remove-Item $codexDest -Recurse -Force }
if (Test-Path $claudeDest) { Remove-Item $claudeDest -Recurse -Force }
Copy-Item $skillSrc $codexDest -Recurse -Force
Copy-Item $skillSrc $claudeDest -Recurse -Force
Write-Host "Installed for Codex: $codexDest"
Write-Host "Installed for Claude Code: $claudeDest"
Write-Host 'Use in Codex:  $agent-cross-handoff'
Write-Host 'Use in Claude: /agent-cross-handoff'
