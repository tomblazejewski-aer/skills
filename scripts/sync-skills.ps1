# sync-skills.ps1
# 1. Copies registered skills from plugin.json into .opencode/skills/
#    so OpenCode discovers them as project-local skills.
# 2. Deploys AGENTS.md and opencode.json to $env:USERPROFILE\.config\opencode\
#    so this repo is the single source of truth for global OpenCode config.
#
# Run from the repo root:
#   .\scripts\sync-skills.ps1

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$PluginJson = Join-Path $RepoRoot '.claude-plugin\plugin.json'
$Dest = Join-Path $RepoRoot '.opencode\skills'

if (-not (Test-Path -LiteralPath $PluginJson)) {
    Write-Error "ERROR: $PluginJson not found."
    exit 1
}

# Parse the skills array from plugin.json using node
$SkillPaths = @(node -e "const p = require('$($PluginJson -replace '\\','/')'); p.skills.forEach(s => console.log(s))")

New-Item -ItemType Directory -Path $Dest -Force | Out-Null

# Track which skill names we write so we can clean up stale ones
$WrittenNames = @()

foreach ($RelPath in $SkillPaths) {
    $Src = Join-Path $RepoRoot $RelPath
    $Name = Split-Path $RelPath -Leaf

    if (-not (Test-Path -LiteralPath $Src)) {
        Write-Host "  WARN: skill source not found, skipping: $Src"
        continue
    }

    $DestSkill = Join-Path $Dest $Name
    New-Item -ItemType Directory -Path $DestSkill -Force | Out-Null

    # Copy all .md files from the skill folder
    $Files = @(Get-ChildItem -LiteralPath $Src -Filter '*.md' -File)
    foreach ($File in $Files) {
        Copy-Item -LiteralPath $File.FullName -Destination $DestSkill -Force
    }

    $WrittenNames += $Name
    Write-Host "  synced  $Name  ($($Files.Count) files)"
}

# Remove stale skill folders no longer in plugin.json
if (Test-Path -LiteralPath $Dest) {
    Get-ChildItem -LiteralPath $Dest -Directory | ForEach-Object {
        if ($WrittenNames -notcontains $_.Name) {
            Remove-Item -LiteralPath $_.FullName -Recurse -Force
            Write-Host "  removed $($_.Name) (no longer registered)"
        }
    }
}

Write-Host ""
Write-Host "Done. $($WrittenNames.Count) skill(s) active in .opencode/skills/"

# Deploy AGENTS.md and opencode.json to global OpenCode config
$GlobalConfig = Join-Path $env:USERPROFILE '.config\opencode'

Write-Host ""
Write-Host "Deploying global config to $GlobalConfig ..."

$AgentsMd = Join-Path $RepoRoot 'AGENTS.md'
if (Test-Path -LiteralPath $AgentsMd) {
    Copy-Item -LiteralPath $AgentsMd -Destination (Join-Path $GlobalConfig 'agents.md') -Force
    Write-Host "  synced  AGENTS.md -> $GlobalConfig\agents.md"
} else {
    Write-Host "  WARN: AGENTS.md not found, skipping"
}

$OpenCodeJson = Join-Path $RepoRoot 'opencode.json'
if (Test-Path -LiteralPath $OpenCodeJson) {
    Copy-Item -LiteralPath $OpenCodeJson -Destination (Join-Path $GlobalConfig 'opencode.json') -Force
    Write-Host "  synced  opencode.json -> $GlobalConfig\opencode.json"
} else {
    Write-Host "  WARN: opencode.json not found, skipping"
}

Write-Host ""
Write-Host "Global config deploy complete."
