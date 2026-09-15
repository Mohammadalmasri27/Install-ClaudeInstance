<#
.SYNOPSIS
  Run several Claude Desktop accounts side by side on one Windows user.

.DESCRIPTION
  Creates isolated Claude Desktop instances: each gets its own Electron user-data dir
  (login, settings, MCP servers, sessions) and its own Claude Code config dir,
  plus Desktop and Start-menu shortcuts. Your default Claude install is never touched.

  Not an official Anthropic feature: it relies on Electron's standard
  --user-data-dir switch, which a future Claude update could stop honouring.

.EXAMPLE
  .\Install-ClaudeInstance.ps1                          # asks how many (Enter = 1) and their names
  .\Install-ClaudeInstance.ps1 -Count 3                 # three instances, automatic names
  .\Install-ClaudeInstance.ps1 -Name Work,Personal      # named instances
  .\Install-ClaudeInstance.ps1 -List                    # show existing instances
  .\Install-ClaudeInstance.ps1 -Name Work -Uninstall    # remove shortcuts, keep data
  .\Install-ClaudeInstance.ps1 -Name Work -Uninstall -RemoveData
#>
param(
    [string[]]$Name,
    [ValidateRange(1, 20)][int]$Count,
    [switch]$List,
    [switch]$Uninstall,
    [switch]$RemoveData,
    [switch]$NoLaunch
)

$ErrorActionPreference = 'Stop'
$root      = Join-Path $env:LOCALAPPDATA 'ClaudeInstances'
$launcher  = Join-Path $root 'Launch-Claude.ps1'
$desktop   = [Environment]::GetFolderPath('Desktop')
$startMenu = Join-Path ([Environment]::GetFolderPath('Programs')) 'Claude Instances'
$namePattern = '^[A-Za-z0-9_-]{1,40}$'
# "-Name a,b" arrives as one string through -File or a .cmd; accept both forms.
$Name = @($Name | ForEach-Object { $_ -split '\s*,\s*' } | Where-Object { $_ })

function Get-Instances {
    if (-not (Test-Path $root)) { return @() }
    @(Get-ChildItem $root -Directory | Select-Object -ExpandProperty Name)
}
function Get-ShortcutPaths([string]$n) {
    @((Join-Path $desktop "Claude - $n.lnk"), (Join-Path $startMenu "Claude - $n.lnk"))
}
function Assert-Name([string]$n) {
    if ($n -notmatch $namePattern) { throw "Invalid name '$n'. Use letters, digits, - or _ only." }
}
# Next unused AccountN, starting at 2 (the default install is account 1).
function Get-NextName([string[]]$taken) {
    $i = 2
    while ($taken -contains "Account$i") { $i++ }
    "Account$i"
}

# ---------- list ----------
if ($List) {
    $all = Get-Instances
    if (-not $all) { 'No instances yet.'; return }
    foreach ($n in $all) {
        $running = Get-CimInstance Win32_Process -Filter "Name='claude.exe'" |
            Where-Object { $_.CommandLine -like "*ClaudeInstances\$n`"*" }
        '{0,-20} {1}' -f $n, $(if ($running) { 'running' } else { '' })
    }
    return
}

# ---------- uninstall ----------
if ($Uninstall) {
    if (-not $Name) { $Name = (Read-Host 'Instance name(s) to remove, comma-separated') -split '\s*,\s*' }
    foreach ($n in $Name | Where-Object { $_ }) {
        Assert-Name $n
        $dataDir = Join-Path $root $n
        Get-ShortcutPaths $n | Where-Object { Test-Path $_ } | ForEach-Object { Remove-Item $_; "Removed shortcut: $_" }
        if ($RemoveData -and (Test-Path $dataDir)) {
            $running = Get-CimInstance Win32_Process -Filter "Name='claude.exe'" |
                Where-Object { $_.CommandLine -like "*ClaudeInstances\$n`"*" }
            if ($running) { Write-Warning "'$n' is running. Close its window, then run again to delete its data."; continue }
            Remove-Item $dataDir -Recurse -Force
            "Removed data: $dataDir"
        } elseif (Test-Path $dataDir) {
            "Data kept at: $dataDir  (add -RemoveData to delete it)"
        }
    }
    return
}

# ---------- find Claude ----------
function Get-ClaudeExe {
    $pkg = Get-AppxPackage -Name Claude -ErrorAction SilentlyContinue |
        Sort-Object Version -Descending | Select-Object -First 1
    if ($pkg) { return Join-Path $pkg.InstallLocation 'app\claude.exe' }
    $legacy = Join-Path $env:LOCALAPPDATA 'AnthropicClaude\claude.exe'   # older non-MSIX installer
    if (Test-Path $legacy) { return $legacy }
    return $null
}
$exe = Get-ClaudeExe
if (-not $exe) { throw 'Claude Desktop is not installed. Get it from https://claude.ai/download first.' }

# ---------- decide which instances to create ----------
$taken = Get-Instances
if ($Name) {
    $names = @($Name | Where-Object { $_ })
} elseif ($Count) {
    $names = @()
    for ($i = 0; $i -lt $Count; $i++) { $n = Get-NextName ($taken + $names); $names += $n }
} else {
    $answer = Read-Host 'How many Claude instances to create? [1]'
    $want = 1
    if ($answer -and -not [int]::TryParse($answer, [ref]$want)) { throw "'$answer' is not a number." }
    if ($want -lt 1 -or $want -gt 20) { throw 'Choose between 1 and 20 instances.' }
    $names = @()
    for ($i = 1; $i -le $want; $i++) {
        $suggested = Get-NextName ($taken + $names)
        $n = Read-Host "Name for instance $i [$suggested]"
        if (-not $n) { $n = $suggested }
        Assert-Name $n
        if ($names -contains $n) { throw "Name '$n' was entered twice." }
        $names += $n
    }
}
$names | ForEach-Object { Assert-Name $_ }

# ---------- launcher (shared by every instance) ----------
New-Item -ItemType Directory -Force $root, $startMenu | Out-Null
@'
# Generated by Install-ClaudeInstance.ps1 - launches one isolated Claude Desktop instance.
param([Parameter(Mandatory)][string]$Name)
$dataDir = Join-Path (Join-Path $env:LOCALAPPDATA 'ClaudeInstances') $Name
$codeDir = Join-Path $dataDir 'claude-code'
New-Item -ItemType Directory -Force $dataDir, $codeDir | Out-Null

# Resolved on every launch: the MSIX path contains the version and changes on update.
$pkg = Get-AppxPackage -Name Claude -ErrorAction SilentlyContinue | Sort-Object Version -Descending | Select-Object -First 1
$exe = if ($pkg) { Join-Path $pkg.InstallLocation 'app\claude.exe' } else { Join-Path $env:LOCALAPPDATA 'AnthropicClaude\claude.exe' }
if (-not (Test-Path $exe)) { exit 1 }

$env:CLAUDE_CONFIG_DIR = $codeDir
Start-Process -FilePath $exe -ArgumentList "--user-data-dir=`"$dataDir`""
'@ | Set-Content -Path $launcher -Encoding UTF8

# ---------- create instances ----------
$ws = New-Object -ComObject WScript.Shell
""
foreach ($n in $names) {
    $existed = $taken -contains $n
    New-Item -ItemType Directory -Force (Join-Path $root $n) | Out-Null
    foreach ($p in Get-ShortcutPaths $n) {
        $l = $ws.CreateShortcut($p)
        $l.TargetPath   = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
        $l.Arguments    = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$launcher`" -Name $n"
        $l.IconLocation = "$exe,0"
        $l.WindowStyle  = 7
        $l.Description  = "Claude Desktop - isolated instance '$n'"
        $l.Save()
    }
    if ($existed) { "  Updated  'Claude - $n'  (already existed; login and data kept)" }
    else          { "  Created  'Claude - $n'" }
}

""
"Shortcuts are on the Desktop and in the Start menu. Data: $root"
"Tip: sign in to each new window with an email code. A browser login that"
"returns through a claude:// link is delivered to your default Claude window."

if (-not $NoLaunch) {
    foreach ($n in $names) {
        & powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File $launcher -Name $n
    }
}
