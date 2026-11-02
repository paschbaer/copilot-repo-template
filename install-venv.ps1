#Requires -Version 5.1
<#
.SYNOPSIS
    Installs the Copilot repository template configuration into the current directory
    using a uv-managed virtual environment for Python and Node.js tooling.
.DESCRIPTION
    Variant of install.ps1 that ALWAYS creates a .venv in the target repository.
    Spec Kit is installed into the venv and Node.js 24 is provided by nodeenv inside
    the venv (no system-wide Node.js installation). When AGENTS.md is copied by this
    script, an "Environment" section describing the venv usage is inserted after the
    Working Rules. Existing files are never overwritten.
.PARAMETER Author
    Git user.name to configure in the target repository.
.PARAMETER Email
    Git user.email to configure in the target repository.
.PARAMETER Beads
    Install beads (bd) if missing, then run bd init and bd setup copilot.
.PARAMETER Integration
    Integration passed to specify init (default: generic, which also appends --integration-options="--commands-dir .agents").
.PARAMETER Help
    Show usage information.
#>
param(
    [string]$Author = "",
    [string]$Email = "",
    [string]$Integration = "",
    [switch]$Beads,
    [switch]$Analyze,
    [switch]$Help
)

$ErrorActionPreference = 'Stop'

# Suppress uv's hardlink warning: cache and target often sit on different filesystems,
# so tell uv to fall back to copying packages without printing a warning.
$env:UV_LINK_MODE = 'copy'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TargetDir = (Get-Location).Path

function Write-Usage {
    Write-Host "Usage: install-venv.ps1 [-Author NAME] [-Email EMAIL] [-Integration NAME] [-Beads] [-Analyze]"
    Write-Host "  -Integration NAME  Integration passed to specify init (default: generic, which also appends --integration-options=""--commands-dir .agents"")."
    Write-Host "  -Beads    Install beads (bd) if missing, then run bd init and bd setup copilot."
    Write-Host "  -Analyze  Also initialize GitNexus (gitnexus setup and gitnexus analyze) in the target repository."
    Write-Host ""
    Write-Host "Always creates a .venv in the target repository; Spec Kit and Node.js 24 (via nodeenv) are installed into it."
}

if ($Help) {
    Write-Usage
    exit 0
}

if ($args.Count -gt 0) {
    Write-Error ("Unknown argument(s): " + ($args -join ' '))
    Write-Usage
    exit 1
}

function Test-CommandAvailable {
    param([string]$Name)
    if (Get-Command $Name -ErrorAction SilentlyContinue) {
        return $true
    }
    return $false
}

function Copy-FileIfMissing {
    param([string]$Source, [string]$Target)
    $relativeTarget = $Target.Substring($TargetDir.Length + 1)

    if (Test-Path -LiteralPath $Target) {
        Write-Host ("SKIP: {0} already exists and was not overwritten." -f $relativeTarget)
        return
    }

    if (-not (Test-Path -LiteralPath $Source -PathType Leaf)) {
        Write-Host ("SKIP: Source file {0} does not exist." -f $Source)
        return
    }

    $targetParent = Split-Path -Parent $Target
    if (-not (Test-Path -LiteralPath $targetParent)) {
        New-Item -ItemType Directory -Path $targetParent -Force | Out-Null
    }
    Copy-Item -LiteralPath $Source -Destination $Target
    Write-Host ("COPY: {0}" -f $relativeTarget)
}

function Copy-AgentsMd {
    $source = Join-Path $ScriptDir 'AGENTS.md'
    $target = Join-Path $TargetDir 'AGENTS.md'

    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
        Write-Host ("SKIP: Source file {0} does not exist." -f $source)
        return $false
    }

    if (Test-Path -LiteralPath $target) {
        $answer = Read-Host "AGENTS.md already exists in the target. Overwrite it with the template version? [y/N]"
        if ($answer -notmatch '^(y|yes)$') {
            Write-Host "SKIP: AGENTS.md already exists and was not overwritten."
            return $false
        }
        Copy-Item -LiteralPath $source -Destination $target -Force
        Write-Host "OVERWRITE: AGENTS.md"
    }
    else {
        Copy-Item -LiteralPath $source -Destination $target
        Write-Host "COPY: AGENTS.md"
    }

    return $true
}

function Repair-GitNexusProjectName {
    $agentsMd = Join-Path $TargetDir 'AGENTS.md'
    if (-not (Test-Path -LiteralPath $agentsMd -PathType Leaf)) {
        return
    }

    $projectName = Split-Path -Path $TargetDir -Leaf
    $content = Get-Content -LiteralPath $agentsMd -Raw
    $pattern = 'indexed by GitNexus as \*\*copilot-repo-template\*\*'
    if ($content -match $pattern) {
        $content = $content -replace 'indexed by GitNexus as \*\*copilot-repo-template\*\*', "indexed by GitNexus as **$projectName**"
        Set-Content -LiteralPath $agentsMd -Value $content -NoNewline
        Write-Host ("FIX: Rewrote GitNexus project name in AGENTS.md to {0}." -f $projectName)
    }
}

function Add-EnvironmentSection {
    $agentsMd = Join-Path $TargetDir 'AGENTS.md'
    if (-not (Test-Path -LiteralPath $agentsMd -PathType Leaf)) {
        return
    }

    $content = Get-Content -LiteralPath $agentsMd -Raw
    if ($content -match '(?m)^## Environment\b') {
        Write-Host "SKIP: Environment section already present in AGENTS.md."
        return
    }

    $section = @"
`n## Environment

This project uses a uv-managed virtual environment at ``.venv/`` for Python **and** Node.js tooling.

- Activate it before working: ``.venv\Scripts\activate`` (PowerShell) or ``source .venv/bin/activate`` (bash).
- Node.js 24 is provided by **nodeenv** inside the venv (no system-wide Node.js install); while activated, ``node``/``npm``/``npx`` resolve to ``.venv\Scripts``.
- Spec Kit (``specify``) is installed into the same venv.
- Recreate the tooling if needed: ``uv pip install nodeenv`` then ``nodeenv -p --node=24`` (Node.js), or ``uv pip install --python .venv\Scripts\python.exe specify-cli`` (Spec Kit).
"@

    $anchor = '## SOLID Principles (binding)'
    if ($content.Contains($anchor)) {
        $content = $content.Replace($anchor, $section.TrimStart() + "`n`n" + $anchor)
    }
    else {
        $content = $content.TrimEnd() + "`n`n" + $section.TrimStart()
    }

    Set-Content -LiteralPath $agentsMd -Value $content -NoNewline
    Write-Host "ADD: Environment section inserted into AGENTS.md."
}

function Copy-DirectoryContents {
    param([string]$SourceDir, [string]$TargetDirParam)

    if (-not (Test-Path -LiteralPath $SourceDir -PathType Container)) {
        Write-Host ("SKIP: Source directory {0} does not exist." -f $SourceDir)
        return
    }

    Get-ChildItem -LiteralPath $SourceDir -Recurse -File | ForEach-Object {
        $relativePath = $_.FullName.Substring($SourceDir.Length + 1)
        Copy-FileIfMissing -Source $_.FullName -Target (Join-Path $TargetDirParam $relativePath)
    }
}

function Ensure-GitRepository {
    git rev-parse --is-inside-work-tree *> $null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "CHECK: Git repository detected."
        return
    }

    Write-Host "INIT: No Git repository found. Initializing repository..."
    git init
    if ($LASTEXITCODE -ne 0) {
        Write-Error "INIT: git init failed."
        exit 1
    }
    Write-Host "INIT: Git repository created."
}

function Configure-GitAuthor {
    if (($Author -eq "") -and ($Email -eq "")) {
        Write-Host "SKIP: No Git author configuration specified."
        return
    }

    Write-Host "CONFIG: Setting Git repository author information..."

    if ($Author -ne "") {
        git config user.name $Author
        Write-Host ("CONFIG: user.name = {0}" -f $Author)
    }

    if ($Email -ne "") {
        git config user.email $Email
        Write-Host ("CONFIG: user.email = {0}" -f $Email)
    }
}

function Install-NodeViaNodeenv {
    Write-Host "CHECK: Looking for Node.js inside the virtual environment..."

    $venvNode = Join-Path $script:VenvDir 'Scripts\node.exe'
    if (Test-Path -LiteralPath $venvNode -PathType Leaf) {
        Write-Host ("SKIP: Node.js is already installed in the virtual environment ({0})." -f $venvNode)
        return
    }

    Write-Host "INSTALL: Installing nodeenv into the virtual environment..."
    uv pip install --python $script:VenvPython nodeenv
    if ($LASTEXITCODE -ne 0) {
        Write-Error "ERROR: uv pip install nodeenv failed."
        exit 1
    }

    Write-Host "INSTALL: Installing Node.js 24 into the virtual environment via nodeenv..."
    & (Join-Path $script:VenvDir 'Scripts\nodeenv.exe') -p --node=24
    if ($LASTEXITCODE -ne 0) {
        Write-Error "ERROR: nodeenv -p --node=24 failed."
        exit 1
    }

    Write-Host "INSTALL: Node.js installation completed (inside the virtual environment)."
}

function Install-GitNexus {
    $venvNpm = Join-Path $script:VenvDir 'Scripts\npm.cmd'
    if (-not (Test-Path -LiteralPath $venvNpm -PathType Leaf)) {
        $venvNpm = Join-Path $script:VenvDir 'Scripts\npm'
    }

    if (-not (Test-Path -LiteralPath $venvNpm -PathType Leaf)) {
        Write-Error ("ERROR: npm was not found in the virtual environment {0}." -f $script:VenvDir)
        Write-Error "ERROR: Node.js is provisioned by nodeenv; re-run the script or install nodeenv manually (uv pip install nodeenv && nodeenv -p --node=24)."
        exit 1
    }

    Write-Host "CHECK: Looking for an existing GitNexus installation inside the virtual environment..."

    $venvGitnexus = Join-Path $script:VenvDir 'Scripts\gitnexus.cmd'
    if (-not (Test-Path -LiteralPath $venvGitnexus -PathType Leaf)) {
        $venvGitnexus = Join-Path $script:VenvDir 'Scripts\gitnexus'
    }

    if (Test-Path -LiteralPath $venvGitnexus -PathType Leaf) {
        Write-Host ("SKIP: GitNexus is already installed in the virtual environment ({0})." -f $venvGitnexus)
        & $venvGitnexus --version
        return
    }

    Write-Host "INSTALL: GitNexus was not found. Installing it into the virtual environment with npm..."
    & $venvNpm install --global gitnexus@latest
    if ($LASTEXITCODE -ne 0) {
        Write-Error "ERROR: The GitNexus installation failed."
        exit 1
    }
    Write-Host "INSTALL: GitNexus installation completed (inside the virtual environment)."
}

function Initialize-GitNexus {
    $gitnexusCmd = Join-Path $script:VenvDir 'Scripts\gitnexus.cmd'
    if (-not (Test-Path -LiteralPath $gitnexusCmd -PathType Leaf)) {
        $gitnexusCmd = Join-Path $script:VenvDir 'Scripts\gitnexus'
    }

    if (-not (Test-Path -LiteralPath $gitnexusCmd -PathType Leaf)) {
        Write-Error ("ERROR: gitnexus was not found in the virtual environment {0}." -f $script:VenvDir)
        exit 1
    }

    Write-Host "INIT: Configuring GitNexus MCP integrations..."
    & $gitnexusCmd setup
    if ($LASTEXITCODE -ne 0) {
        Write-Error "ERROR: gitnexus setup failed."
        exit 1
    }

    Write-Host ("INIT: Analyzing repository {0}..." -f $TargetDir)
    Push-Location $TargetDir
    try {
        & $gitnexusCmd analyze
        if ($LASTEXITCODE -ne 0) {
            Write-Error "ERROR: gitnexus analyze failed."
            exit 1
        }
    }
    finally {
        Pop-Location
    }
    Write-Host "INIT: GitNexus initialization completed."
}

function Ensure-Uv {
    Write-Host "CHECK: Looking for an existing uv installation..."

    if (Test-CommandAvailable -Name 'uv') {
        Write-Host ("SKIP: uv is already installed at {0}." -f (Get-Command uv).Source)
        uv --version
        return
    }

    Write-Host "INSTALL: uv was not found. Installing it with the official standalone installer..."
    Write-Host "INSTALL: https://astral.sh/uv/install.ps1"

    try {
        Invoke-RestMethod -Uri 'https://astral.sh/uv/install.ps1' | Invoke-Expression
    }
    catch {
        Write-Warning "The uv installer reported a failure."
    }

    $env:PATH = "$env:USERPROFILE\.local\bin;$env:USERPROFILE\.cargo\bin;$env:PATH"

    if (Test-CommandAvailable -Name 'uv') {
        Write-Host ("INSTALL: uv installation completed ({0})." -f (Get-Command uv).Source)
        return
    }

    Write-Error "ERROR: uv is required for the virtual environment but could not be installed."
    Write-Error "ERROR: Install uv manually (https://docs.astral.sh/uv/getting-started/installation/) and run this script again."
    exit 1
}

function New-ProjectVenv {
    $script:VenvDir = Join-Path $TargetDir '.venv'

    if (Test-Path -LiteralPath $script:VenvDir -PathType Container) {
        Write-Host ("SKIP: Virtual environment already exists at {0}." -f $script:VenvDir)
    }
    else {
        Write-Host ("INIT: Creating virtual environment at {0} (uv-managed Python)..." -f $script:VenvDir)
        uv venv $script:VenvDir
        if ($LASTEXITCODE -ne 0) {
            Write-Error "ERROR: uv venv failed."
            exit 1
        }
        Write-Host "INIT: Virtual environment created."
    }

    $windowsPython = Join-Path $script:VenvDir 'Scripts\python.exe'
    $unixPython = Join-Path $script:VenvDir 'bin\python'

    if (Test-Path -LiteralPath $windowsPython -PathType Leaf) {
        $script:VenvPython = $windowsPython
    }
    elseif (Test-Path -LiteralPath $unixPython -PathType Leaf) {
        $script:VenvPython = $unixPython
    }
    else {
        Write-Error ("ERROR: No Python interpreter found inside {0}." -f $script:VenvDir)
        exit 1
    }

    Write-Host ("INIT: Using virtual environment interpreter {0}." -f $script:VenvPython)
}

function Install-SpecKit {
    Write-Host "INSTALL: Installing Spec Kit into the virtual environment..."
    uv pip install --python $script:VenvPython specify-cli
    if ($LASTEXITCODE -ne 0) {
        Write-Error "ERROR: uv pip install specify-cli failed."
        exit 1
    }
}

function Initialize-SpecKit {
    Write-Host "INIT: Initializing Spec Kit for GitHub Copilot..."

    $specifyCmd = 'specify'

    $windowsSpecify = Join-Path $script:VenvDir 'Scripts\specify.exe'
    $unixSpecify = Join-Path $script:VenvDir 'bin\specify'
    if (Test-Path -LiteralPath $windowsSpecify -PathType Leaf) {
        $specifyCmd = $windowsSpecify
    }
    elseif (Test-Path -LiteralPath $unixSpecify -PathType Leaf) {
        $specifyCmd = $unixSpecify
    }
    else {
        Write-Error ("ERROR: specify was not found in the virtual environment {0}." -f $script:VenvDir)
        exit 1
    }

    Push-Location $TargetDir
    try {
        if (-not (Test-Path -LiteralPath '.specify' -PathType Container)) {
            if ([string]::IsNullOrEmpty($Integration)) {
                & $specifyCmd init --here --integration generic --integration-options="--commands-dir .agents"
            }
            else {
                & $specifyCmd init --here --integration $Integration
            }
            if ($LASTEXITCODE -ne 0) {
                Write-Error "ERROR: specify init failed."
                exit 1
            }
        }
        else {
            Write-Host "SKIP: Spec Kit already appears to be initialized."
        }
    }
    finally {
        Pop-Location
    }
    Write-Host "INIT: Spec Kit initialization completed."
}

function Install-Beads {
    Write-Host "CHECK: Looking for an existing beads installation..."

    if (Test-CommandAvailable -Name 'bd') {
        Write-Host ("SKIP: beads is already installed at {0}." -f (Get-Command bd).Source)
        bd version
        return
    }

    Write-Host "INSTALL: beads was not found. Installing it with winget..."
    Write-Host "INSTALL: winget install --id GasTownHall.Beads --source winget"

    try {
        winget install --id GasTownHall.Beads --source winget --disable-interactivity --accept-package-agreements --accept-source-agreements
    }
    catch {
        Write-Warning "The winget installation of beads reported a failure."
    }

    $env:PATH = "$env:USERPROFILE\.local\bin;$env:USERPROFILE\.cargo\bin;$env:PATH"

    if (Test-CommandAvailable -Name 'bd') {
        Write-Host ("INSTALL: beads installation completed ({0})." -f (Get-Command bd).Source)
        return
    }

    if (Test-CommandAvailable -Name 'npm') {
        Write-Host "INSTALL: Falling back to the npm installation of beads..."
        npm install --global "@beads/bd"
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "The npm fallback installation of beads failed."
        }
    }
    else {
        Write-Warning "npm fallback unavailable (npm not found)."
    }

    if (Test-CommandAvailable -Name 'bd') {
        Write-Host ("INSTALL: beads installation completed ({0})." -f (Get-Command bd).Source)
        return
    }

    Write-Error "ERROR: beads could not be installed (winget and npm fallback failed)."
    Write-Error "ERROR: Install beads manually (https://github.com/gastownhall/beads) and run this script again."
    exit 1
}

function Initialize-Beads {
    Push-Location $TargetDir
    try {
        if (Test-Path -LiteralPath '.beads' -PathType Container) {
            Write-Host "SKIP: beads appears to be already initialized (.beads exists)."
        }
        else {
            Write-Host "INIT: Running bd init..."
            bd init
            if ($LASTEXITCODE -ne 0) {
                Write-Error "ERROR: bd init failed."
                exit 1
            }
        }

        Write-Host "INIT: Running bd setup copilot..."
        bd setup copilot
        if ($LASTEXITCODE -ne 0) {
            Write-Error "ERROR: bd setup copilot failed."
            exit 1
        }
    }
    finally {
        Pop-Location
    }
    Write-Host "INIT: beads initialization completed."
}

# --- Main flow (mirrors install.sh ordering) ---

Ensure-GitRepository
Configure-GitAuthor

Copy-DirectoryContents -SourceDir (Join-Path $ScriptDir '.github') -TargetDirParam (Join-Path $TargetDir '.github')
$agentsMdCopied = Copy-AgentsMd
Repair-GitNexusProjectName
Copy-DirectoryContents -SourceDir (Join-Path $ScriptDir '.vscode') -TargetDirParam (Join-Path $TargetDir '.vscode')
Copy-FileIfMissing -Source (Join-Path $ScriptDir '.gitignore') -Target (Join-Path $TargetDir '.gitignore')
Copy-DirectoryContents -SourceDir (Join-Path $ScriptDir '.github/skills') -TargetDirParam (Join-Path $TargetDir '.agents/skills')
Copy-DirectoryContents -SourceDir (Join-Path $ScriptDir 'memory-bank-template') -TargetDirParam (Join-Path $TargetDir 'memory-bank')

Ensure-Uv
New-ProjectVenv
Install-NodeViaNodeenv

# Make the venv's node/npm (and other tools) available for the remaining steps.
$env:PATH = "$script:VenvDir\Scripts;$env:PATH"

Install-GitNexus

if ($Analyze) {
    Initialize-GitNexus
}

Install-SpecKit
Initialize-SpecKit

if ($Beads) {
    Install-Beads
    Initialize-Beads
}

# Inserted only when AGENTS.md was copied by this script into the target repository.
if ($agentsMdCopied) {
    Add-EnvironmentSection
}

Write-Host "Copilot setup installation completed. Existing files were preserved."
