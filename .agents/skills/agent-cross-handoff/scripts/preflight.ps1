$ErrorActionPreference = "Continue"
Write-Host "== Agent Cross Handoff preflight =="
Write-Host "OS: $([System.Environment]::OSVersion.VersionString)"
Write-Host "PowerShell: $($PSVersionTable.PSVersion)"
Write-Host "User home: $HOME"

Write-Host "`n== Git =="
if (Get-Command git -ErrorAction SilentlyContinue) {
  git --version
  $root = git rev-parse --show-toplevel 2>$null
  if ($LASTEXITCODE -eq 0 -and $root) {
    Write-Host "Repository root: $root"
    Set-Location $root
    Write-Host "Branch: " -NoNewline; git branch --show-current
    Write-Host "HEAD: " -NoNewline; git rev-parse --short HEAD
    Write-Host "`nRemotes:"; git remote -v
    Write-Host "`nWorktrees:"; git worktree list
    Write-Host "`nStatus:"; git status --short
    Write-Host "`nUntracked sample:"; git ls-files --others --exclude-standard | Select-Object -First 50
  } else {
    Write-Host "Not inside a Git repository."
  }
} else {
  Write-Host "Git not found."
}

Write-Host "`n== Agent project files =="
$paths = @("AGENTS.md","CLAUDE.md",".claude/CLAUDE.md",".claude/rules",".claude/skills",".agents/skills",".codex",".codex/config.toml",".cursor/rules",".cursorrules",".windsurfrules",".github/copilot-instructions.md")
foreach ($p in $paths) { if (Test-Path $p) { Write-Host "FOUND $p" } }

Write-Host "`n== Agent user dirs =="
$userPaths = @("$HOME/.codex","$HOME/.agents/skills","$HOME/.claude","$HOME/.claude/skills")
foreach ($p in $userPaths) { if (Test-Path $p) { Write-Host "FOUND $p" } else { Write-Host "missing $p" } }

Write-Host "`n== Tool detection =="
$cmds = @("codex","claude","node","npm","pnpm","yarn","python","python3","swift","xcodebuild")
foreach ($c in $cmds) {
  $cmd = Get-Command $c -ErrorAction SilentlyContinue
  if ($cmd) { Write-Host ($c.PadRight(12)) $cmd.Source }
}

Write-Host "`n== Likely sensitive files in repo (review before commit) =="
Get-ChildItem -Path . -Recurse -File -ErrorAction SilentlyContinue |
  Where-Object { $_.FullName -notmatch '\\.git\\' -and ($_.Name -match '(^\.env(\..*)?$|secret|token|credential|auth\.json|\.pem$|\.key$|^id_rsa$|^id_ed25519$)') } |
  Select-Object -First 100 -ExpandProperty FullName

Write-Host "`n== Large files > 50MB in repo (review before commit) =="
Get-ChildItem -Path . -Recurse -File -ErrorAction SilentlyContinue |
  Where-Object { $_.FullName -notmatch '\\.git\\' -and $_.Length -gt 52428800 } |
  Select-Object -First 100 -ExpandProperty FullName

Write-Host "`nPreflight complete."
