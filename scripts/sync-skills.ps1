# sync-skills.ps1
# 1. Copies registered skills from plugin.json into .opencode/skills/
#    so OpenCode discovers them as project-local skills.
# 2. Deploys all skills, AGENTS.md, and opencode.json to $env:USERPROFILE\.config\opencode\
#    so this repo is the single source of truth for global OpenCode config.
#
# Run from the repo root:
#   .\scripts\sync-skills.ps1

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$PluginJson = Join-Path $RepoRoot '.claude-plugin\plugin.json'
$LocalDest = Join-Path $RepoRoot '.opencode\skills'
$GlobalConfig = Join-Path $env:USERPROFILE '.config\opencode'
$GlobalDest = Join-Path $GlobalConfig 'skills'

if (-not (Test-Path -LiteralPath $PluginJson)) {
    Write-Error "ERROR: $PluginJson not found."
    exit 1
}

# Parse the skills array from plugin.json using node
$SkillPaths = @(node -e "const p = require('$($PluginJson -replace '\\','/')'); p.skills.forEach(s => console.log(s))")

New-Item -ItemType Directory -Path $LocalDest -Force | Out-Null
New-Item -ItemType Directory -Path $GlobalDest -Force | Out-Null

# Track which skill names we write so we can clean up stale ones
$WrittenNames = @()

foreach ($RelPath in $SkillPaths) {
    $Src = Join-Path $RepoRoot $RelPath
    $Name = Split-Path $RelPath -Leaf

    if (-not (Test-Path -LiteralPath $Src)) {
        Write-Host "  WARN: skill source not found, skipping: $Src"
        continue
    }

    # Copy all .md files from the skill folder to both destinations
    $Files = @(Get-ChildItem -LiteralPath $Src -Filter '*.md' -File)

    $LocalSkill = Join-Path $LocalDest $Name
    New-Item -ItemType Directory -Path $LocalSkill -Force | Out-Null
    foreach ($File in $Files) {
        Copy-Item -LiteralPath $File.FullName -Destination $LocalSkill -Force
    }

    $GlobalSkill = Join-Path $GlobalDest $Name
    New-Item -ItemType Directory -Path $GlobalSkill -Force | Out-Null
    foreach ($File in $Files) {
        Copy-Item -LiteralPath $File.FullName -Destination $GlobalSkill -Force
    }

    $WrittenNames += $Name
    Write-Host "  synced  $Name  ($($Files.Count) files)"
}

# Remove stale skill folders no longer in plugin.json — both destinations
foreach ($DestDir in @($LocalDest, $GlobalDest)) {
    if (Test-Path -LiteralPath $DestDir) {
        Get-ChildItem -LiteralPath $DestDir -Directory | ForEach-Object {
            if ($WrittenNames -notcontains $_.Name) {
                Remove-Item -LiteralPath $_.FullName -Recurse -Force
                Write-Host "  removed $($_.Name) from $DestDir (no longer registered)"
            }
        }
    }
}

Write-Host ""
Write-Host "Done. $($WrittenNames.Count) skill(s) synced to project-local and global config."

# Deploy AGENTS.md and opencode.json to global OpenCode config
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
    $GlobalOpenCodeJson = Join-Path $GlobalConfig 'opencode.json'
    $MergeScript = Join-Path $RepoRoot 'scripts\merge-json.js'
    node $MergeScript $GlobalOpenCodeJson $OpenCodeJson
    if ($LASTEXITCODE -ne 0) { throw "merge-json.js failed (exit $LASTEXITCODE)" }
    Write-Host "  merged  opencode.json -> $GlobalConfig\opencode.json"
} else {
    Write-Host "  WARN: opencode.json not found, skipping"
}

$StandardsMd = Join-Path $RepoRoot 'STANDARDS.md'
if (Test-Path -LiteralPath $StandardsMd) {
    Copy-Item -LiteralPath $StandardsMd -Destination (Join-Path $GlobalConfig 'STANDARDS.md') -Force
    Write-Host "  synced  STANDARDS.md -> $GlobalConfig\STANDARDS.md"
} else {
    Write-Host "  INFO: STANDARDS.md not found, skipping"
}

$CommandsSource = Join-Path $RepoRoot '.opencode\commands'
$CommandsDest = Join-Path $GlobalConfig 'commands'
if (Test-Path -LiteralPath $CommandsSource) {
    New-Item -ItemType Directory -Path $CommandsDest -Force | Out-Null
    $CommandFiles = @(Get-ChildItem -LiteralPath $CommandsSource -Filter '*.md' -File)
    foreach ($File in $CommandFiles) {
        Copy-Item -LiteralPath $File.FullName -Destination $CommandsDest -Force
        Write-Host "  synced  commands/$($File.Name) -> $CommandsDest\$($File.Name)"
    }
} else {
    Write-Host "  INFO: no .opencode/commands/ directory, skipping command deploy"
}

Write-Host ""
Write-Host "Global config deploy complete."
