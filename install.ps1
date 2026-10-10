#Requires -Version 5.1
<#
.SYNOPSIS
    Installs the Copilot repository template configuration into the current directory.
.DESCRIPTION
    PowerShell port of install.sh with full feature parity. Existing files are never overwritten.
.PARAMETER Author
    Git user.name to configure in the target repository.
.PARAMETER Email
    Git user.email to configure in the target repository.
.PARAMETER Venv
    Run all uv/Python calls in a .venv inside the target repository.
.PARAMETER Beads
    Install beads (bd) if missing, then run bd init and bd setup copilot.
.PARAMETER Help
    Show usage information.
#>
param(
    [string]$Author = "",
    [string]$Email = "",
    [switch]$Venv,
    [switch]$Beads,
    [switch]$Help
)

$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TargetDir = (Get-Location).Path

function Write-Usage {
    Write-Host "Usage: install.ps1 [-Author NAME] [-Email EMAIL] [-Venv] [-Beads]"
    Write-Host "  -Venv     Run all uv/Python calls in a .venv inside the target repository."
    Write-Host "  -Beads    Install beads (bd) if missing, then run bd init and bd setup copilot."
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

function Ensure-Node {
    Write-Host "CHECK: Looking for an existing npm/npx installation..."

    if ((Test-CommandAvailable -Name 'npm') -and (Test-CommandAvailable -Name 'npx')) {
        Write-Host ("SKIP: npm and npx are already installed ({0})." -f (Get-Command npm).Source)
        return
    }

    Write-Host "INSTALL: npm/npx incomplete or missing. Bootstrapping Node.js via fnm (lightest per-user install)..."

    if (-not (Test-CommandAvailable -Name 'fnm')) {
        Write-Host "INSTALL: fnm was not found. Installing it with winget..."
        Write-Host "INSTALL: winget install --id Schniz.fnm --source winget"

        try {
            winget install --id Schniz.fnm --source winget --disable-interactivity --accept-package-agreements --accept-source-agreements
        }
        catch {
            Write-Warning "The winget installation of fnm reported a failure."
        }

        # Refresh PATH from the machine and user environment (winget persists its links there).
        $machinePath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
        $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
        $env:PATH = "$machinePath;$userPath"
    }

    if (-not (Test-CommandAvailable -Name 'fnm')) {
        Write-Error "ERROR: fnm is required to bootstrap Node.js but could not be installed."
        Write-Error "ERROR: Install Node.js manually (https://nodejs.org) and run this script again."
        exit 1
    }

    Write-Host "INSTALL: Installing the Node.js LTS release via fnm..."
    Invoke-Expression -Command (fnm env --shell powershell | Out-String)

    fnm install --lts
    if ($LASTEXITCODE -ne 0) {
        Write-Error "ERROR: fnm could not install the Node.js LTS release."
        Write-Error "ERROR: Install Node.js manually (https://nodejs.org) and run this script again."
        exit 1
    }

    fnm use lts-latest
    fnm default lts-latest

    if ((Test-CommandAvailable -Name 'npm') -and (Test-CommandAvailable -Name 'npx')) {
        Write-Host ("INSTALL: Node.js bootstrap completed (npm at {0})." -f (Get-Command npm).Source)
        return
    }

    Write-Error "ERROR: npm/npx are still unavailable after the Node.js bootstrap."
    Write-Error "ERROR: Install Node.js manually (https://nodejs.org) and run this script again."
    exit 1
}

function Install-GitNexus {
    Write-Host "CHECK: Looking for an existing GitNexus installation..."

    if (Test-CommandAvailable -Name 'gitnexus') {
        Write-Host ("SKIP: GitNexus is already installed at {0}." -f (Get-Command gitnexus).Source)
        gitnexus --version
        return
    }

    if (-not (Test-CommandAvailable -Name 'npm')) {
        Write-Error "ERROR: npm is required to install GitNexus but was not found."
        Write-Error "ERROR: Install Node.js and npm, then run this script again."
        exit 1
    }

    Write-Host "INSTALL: GitNexus was not found. Installing it globally with npm..."
    npm install --global gitnexus@latest
    if ($LASTEXITCODE -ne 0) {
        Write-Error "ERROR: The GitNexus installation failed."
        exit 1
    }
    Write-Host "INSTALL: GitNexus installation completed."
}

function Initialize-GitNexus {
    Write-Host "INIT: Configuring GitNexus MCP integrations..."
    gitnexus setup
    if ($LASTEXITCODE -ne 0) {
        Write-Error "ERROR: gitnexus setup failed."
        exit 1
    }

    Write-Host ("INIT: Analyzing repository {0}..." -f $TargetDir)
    Push-Location $TargetDir
    try {
        gitnexus analyze
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

    if ($Venv) {
        Write-Error "ERROR: uv is required for -Venv but could not be installed."
        Write-Error "ERROR: Install uv manually (https://docs.astral.sh/uv/getting-started/installation/) and run this script again."
        exit 1
    }

    Write-Warning "uv could not be installed; continuing without it. Spec Kit will fall back to pipx or pip."
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
    Write-Host "CHECK: Looking for an existing Spec Kit installation..."

    if ($Venv) {
        Write-Host "INSTALL: Installing Spec Kit into the virtual environment..."
        uv pip install --python $script:VenvPython specify-cli
        if ($LASTEXITCODE -ne 0) {
            Write-Error "ERROR: uv pip install specify-cli failed."
            exit 1
        }
        return
    }

    if (Test-CommandAvailable -Name 'specify') {
        Write-Host ("SKIP: Spec Kit is already installed at {0}." -f (Get-Command specify).Source)
        specify version
        return
    }

    if (Test-CommandAvailable -Name 'uv') {
        Write-Host "INSTALL: Installing Spec Kit using uv..."
        uv tool install specify-cli
        if ($LASTEXITCODE -ne 0) {
            Write-Error "ERROR: uv tool install specify-cli failed."
            exit 1
        }
        return
    }

    if (Test-CommandAvailable -Name 'pipx') {
        Write-Host "INSTALL: Installing Spec Kit using pipx..."
        pipx install specify-cli
        if ($LASTEXITCODE -ne 0) {
            Write-Error "ERROR: pipx install specify-cli failed."
            exit 1
        }
        return
    }

    if (Test-CommandAvailable -Name 'pip') {
        Write-Host "INSTALL: Installing Spec Kit using pip..."
        pip install specify-cli
        if ($LASTEXITCODE -ne 0) {
            Write-Error "ERROR: pip install specify-cli failed."
            exit 1
        }
        return
    }

    Write-Error "ERROR: Could not install Spec Kit."
    Write-Error "ERROR: Install uv, pipx, or pip and run the script again."
    exit 1
}

function Initialize-SpecKit {
    Write-Host "INIT: Initializing Spec Kit for GitHub Copilot..."

    $specifyCmd = 'specify'

    if ($Venv) {
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
    }

    Push-Location $TargetDir
    try {
        if (-not (Test-Path -LiteralPath '.specify' -PathType Container)) {
            & $specifyCmd init --here --integration copilot
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
Copy-FileIfMissing -Source (Join-Path $ScriptDir 'AGENTS.md') -Target (Join-Path $TargetDir 'AGENTS.md')
Copy-DirectoryContents -SourceDir (Join-Path $ScriptDir '.vscode') -TargetDirParam (Join-Path $TargetDir '.vscode')
Copy-FileIfMissing -Source (Join-Path $ScriptDir '.gitignore') -Target (Join-Path $TargetDir '.gitignore')
Copy-DirectoryContents -SourceDir (Join-Path $ScriptDir '.github/skills') -TargetDirParam (Join-Path $TargetDir '.agents/skills')
Copy-DirectoryContents -SourceDir (Join-Path $ScriptDir 'memory-bank-template') -TargetDirParam (Join-Path $TargetDir 'memory-bank')

Ensure-Node

Install-GitNexus
Initialize-GitNexus

Ensure-Uv

if ($Venv) {
    New-ProjectVenv
}

Install-SpecKit
Initialize-SpecKit

if ($Beads) {
    Install-Beads
    Initialize-Beads
}

Write-Host "Copilot setup installation completed. Existing files were preserved."
