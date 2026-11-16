# Sync agent-config into local agent roots.
# Usage: . .\sync.ps1 [-DryRun] [-PersistEnv] [-InstallDeps] [-HomeDir <path>]
[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$PersistEnv,
    [switch]$InstallDeps,
    [string]$HomeDir = $env:USERPROFILE
)

if ($DryRun) { $WhatIfPreference = $true }

$ErrorActionPreference = 'Stop'
$Repo = $PSScriptRoot

$envFile = "$Repo\.env.local"
if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        $line = $_.Trim()
        if ($line -and -not $line.StartsWith('#') -and $line -match '^([^=]+)=(.*)$') {
            $k = $matches[1].Trim()
            $v = $matches[2].Trim().Trim('"').Trim("'")
            if (-not [Environment]::GetEnvironmentVariable($k)) {
                [Environment]::SetEnvironmentVariable($k, $v, 'Process')
            }
            if ($PersistEnv -and -not $DryRun) {
                [Environment]::SetEnvironmentVariable($k, $v, 'User')
            }
        }
    }
}

function Sync-Dir {
    param([string]$Source, [string]$Destination)
    if (-not (Test-Path $Source)) { return }
    if ($DryRun) {
        Write-Host "[dry-run] sync $Source -> $Destination"
        return
    }
    New-Item -ItemType Directory -Force -Path $Destination | Out-Null
    robocopy $Source $Destination /MIR /XD node_modules .git /XF auth.json *.gif /NFL /NDL /NJH /NJS /NP /R:1 /W:1 | Out-Null
    if ($LASTEXITCODE -ge 8) {
        throw "robocopy falló ($LASTEXITCODE): $Source -> $Destination"
    }
}

# 1. Skills -> 4 roots
$skillRoots = @(
    "$HomeDir\.agents\skills",
    "$HomeDir\.config\opencode\skills",
    "$HomeDir\.dsh\skills",
    "$HomeDir\.gemini\config\skills"
)
foreach ($root in $skillRoots) {
    Sync-Dir "$Repo\skills" $root
}

# 2. OpenCode
$oc = "$HomeDir\.config\opencode"
New-Item -ItemType Directory -Force -Path $oc | Out-Null

$ocVars = 'CONTEXT7_API_KEY', 'TESTSPRITE_API_KEY', 'GITHUB_PAT', 'OPENCODE_SERVICE_PASSWORD'
$ocMissing = @($ocVars | Where-Object { -not [Environment]::GetEnvironmentVariable($_) })
if ($ocMissing.Count -gt 0) {
    Write-Warning "OpenCode: faltan vars ($($ocMissing -join ', ')); los placeholders quedarán vacíos."
}

# Secret-bearing configs: only seed when missing, never overwrite.
if (-not (Test-Path "$oc\opencode.json")) {
    Copy-Item "$Repo\opencode\opencode.example.json" "$oc\opencode.json" -Force
}
if (-not (Test-Path "$oc\service.json")) {
    Copy-Item "$Repo\opencode\service.example.json" "$oc\service.json" -Force
}

# Non-secret configs: repo is source of truth.
foreach ($f in 'cli.json', 'tui.json', 'dcp.jsonc', 'AGENTS.md', 'package.json', 'package-lock.json') {
    $src = "$Repo\opencode\$f"
    if (Test-Path $src) { Copy-Item $src "$oc\$f" -Force }
}
Sync-Dir "$Repo\opencode\agents" "$oc\agents"
Sync-Dir "$Repo\opencode\commands" "$oc\commands"
Sync-Dir "$Repo\opencode\plugins" "$oc\plugins"

# 3. Antigravity (Gemini config root)
$ag = "$HomeDir\.gemini\config"
New-Item -ItemType Directory -Force -Path $ag | Out-Null

if (Test-Path "$Repo\opencode\AGENTS.md") {
    Copy-Item "$Repo\opencode\AGENTS.md" "$HomeDir\.gemini\GEMINI.md" -Force
}

if (Test-Path "$Repo\antigravity\config.json") {
    Copy-Item "$Repo\antigravity\config.json" "$ag\config.json" -Force
}

$mcpExample = "$Repo\antigravity\mcp_config.example.json"
if (-not (Test-Path "$ag\mcp_config.json") -and (Test-Path $mcpExample)) {
    $agVars = 'TESTSPRITE_API_KEY', 'GITHUB_PAT', 'SUPERMEMORY_TOKEN', 'INVGATE_TOKEN'
    $missing = @($agVars | Where-Object { -not [Environment]::GetEnvironmentVariable($_) })
    if ($missing.Count -gt 0) {
        Write-Warning "Antigravity: faltan vars ($($missing -join ', ')); sus placeholders quedarán sin reemplazar en mcp_config.json."
    }
    $json = Get-Content $mcpExample -Raw
    foreach ($v in $agVars) {
        $val = [Environment]::GetEnvironmentVariable($v)
        if ($val) {
            $json = $json.Replace("__${v}__", $val)
        }
    }
    if ($DryRun) {
        Write-Host "[dry-run] generaría $ag\mcp_config.json"
    } else {
        [System.IO.File]::WriteAllText("$ag\mcp_config.json", $json, (New-Object System.Text.UTF8Encoding($false)))
        Write-Host "Generado $ag\mcp_config.json"
    }
}

Sync-Dir "$Repo\antigravity\plugins" "$ag\plugins"

if ($InstallDeps) {
    if ($DryRun) {
        Write-Host "[dry-run] npm --prefix $oc install"
    } else {
        npm --prefix $oc install
        if ($LASTEXITCODE -ne 0) { throw "npm install falló ($LASTEXITCODE)" }
    }
}

Write-Host "Sync completado."
