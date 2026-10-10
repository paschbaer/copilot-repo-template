# Copilot Repository Template

A reusable repository template for bootstrapping new projects with a consistent GitHub Copilot and Visual Studio Code configuration.

The repository provides a predefined structure for:

- Repository-specific instructions in `AGENTS.md`
- GitHub Copilot custom instructions
- Custom agents
- Agent skills
- Prompt files, where required
- MCP server configuration
- A Memory Bank with knowledge templates in `memory-bank/`
- Shared development conventions

The goal is to give new repositories a consistent and maintainable foundation for AI-assisted development.

## Repository Structure

```text
.
├── AGENTS.md
├── LICENSE
├── README.md
├── install.sh
├── install.ps1
├── .gitignore
├── .github/
│   ├── copilot-instructions.md
│   ├── agents/
│   ├── prompts/
│   └── skills/
├── .vscode/
│   ├── mcp.json
│   └── tasks.json
├── .gitignore
├── memory-bank/
└── memory-bank-template/
```

`memory-bank-template/` contains the distributable Memory Bank templates that `install.sh` (Linux/macOS/WSL) and `install.ps1` (Windows) copy into the target repository's `memory-bank/` directory. `memory-bank/` in this repository is this template project's own Memory Bank and is not installed.

## Installation on Linux / macOS / WSL (Bash)

Follow these steps to install the template configuration in a repository using the Bash installer `install.sh`.

### 1. Open a terminal

Clone this template repository locally (if you have not already) and open a terminal in its root directory, the directory that contains `install.sh`.

You can verify that you are in the correct directory by running:

```bash
ls -la install.sh
```

The command should display the `install.sh` file.

In the examples below, `/path/to/copilot-repo-template` refers to this directory. Replace it with the actual path on your system.

### 2. Make the installation script executable

On Linux, macOS, or another Unix-like environment, grant execute permission to the script:

```bash
chmod +x /path/to/copilot-repo-template/install.sh
```

This step is normally required only once.

### 3. Change into the repository directory

Change into the root directory of the repository you want to initialize with this template:

```bash
cd /path/to/your/target-repository
```

Replace `/path/to/your/target-repository` with the actual path to the repository that should receive the template configuration. All subsequent steps must be run from this directory — the script installs the template configuration into the current working directory.

### 4. Run the installation script

Execute the script by its path in the template repository:

```bash
/path/to/copilot-repo-template/install.sh
```

If the template repository is a sibling directory of your target repository, a relative path works as well:

```bash
../copilot-repo-template/install.sh
```

This is the actual installation command. The script copies the template configuration from its own directory into the current working directory.

If you do not want to change the file permissions, you can alternatively invoke the script with Bash:

```bash
bash /path/to/copilot-repo-template/install.sh
```

To set the git attributes for *Author* and *E-Mail* call the script this way:

```bash
../copilot-repo-template/install.sh \
  --author "paschbaer" \
  --email "paschbaer@users.noreply.github.com"
```

#### Virtual environment mode (`--venv`)

Add the `--venv` option to run all `uv`/Python calls in a virtual environment associated with the target repository:

```bash
../copilot-repo-template/install.sh --venv
```

With `--venv`:

- The script ensures `uv` is available (see below) and creates a `.venv` directory in the target repository root using an uv-managed Python interpreter. An existing `.venv` is never recreated.
- Spec Kit (`specify-cli`) is installed into that virtual environment via `uv pip install` (instead of `uv tool install`) and `specify init` is invoked through the virtual environment's `specify` entry point.
- Without `--venv`, behavior is unchanged: Spec Kit is installed via `uv tool install` (or pipx/pip as fallback) outside any project virtual environment.

#### beads integration (`--beads`)

Add the `--beads` option to install [beads](https://github.com/gastownhall/beads) — a graph issue tracker and persistent memory for coding agents — and set it up for GitHub Copilot:

```bash
../copilot-repo-template/install.sh --beads
```

With `--beads`:

1. The script checks whether the `bd` CLI is available (`command -v bd`). If it is already installed, the installation is skipped.
2. Otherwise beads is installed with the official install script (`curl -fsSL https://raw.githubusercontent.com/gastownhall/beads/main/scripts/install.sh | bash`; the URL is printed before execution and the script verifies release checksums). If the install script fails or `curl` is missing, the script falls back to `npm install --global @beads/bd`. If both paths fail, the script aborts with an actionable error.
3. In the target repository the script runs `bd init` (skipped when a `.beads/` directory already exists) and then `bd setup copilot`.

Note that `bd init` creates or updates `AGENTS.md`: the script copies its own `AGENTS.md` template first, and `bd init` extends it afterwards. The `.beads/` directory is intentionally not added to `.gitignore` — beads' default mode versions it through git.

#### Node.js bootstrap (npm/npx)

The script checks that both `npm` and `npx` are available. If either is missing, it bootstraps Node.js with [fnm](https://github.com/Schniz/fnm) — a single per-user binary that needs no administrator rights:

1. `fnm` is installed with its official install script (`curl -fsSL https://fnm.vercel.app/install | bash`; the URL is printed before execution).
2. `fnm install --lts` installs the current Node.js LTS release (which ships `npm` and `npx`) for the current user.

If the bootstrap fails, the script aborts with an actionable error message — GitNexus requires npm. Install Node.js manually from https://nodejs.org to resolve it.

#### uv bootstrap

The script checks whether `uv` is installed. If it is missing, the script downloads and executes the official standalone installer:

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

Note that this pipes a remote script from `https://astral.sh` into `sh`; the URL is fixed and printed before execution. If the installation fails and `--venv` was requested, the script aborts with an actionable error message; without `--venv` it warns and continues (Spec Kit then falls back to pipx or pip).

## Installation on Windows (PowerShell)

The template ships a PowerShell port, `install.ps1`, with full feature parity to `install.sh`. It runs on Windows PowerShell 5.1 and PowerShell 7+.

### 1. Open a terminal

Open PowerShell in the root directory of the repository you want to initialize with this template. Verify that the template is available as a sibling directory:

```powershell
Test-Path ..\copilot-repo-template\install.ps1
```

The command should return `True`.

Prerequisites: Git for Windows (`git`). Node.js with `npm`/`npx` is bootstrapped automatically when missing — `fnm` is installed via winget (`Schniz.fnm`), then the Node.js LTS release is installed per user. Install Node.js manually (https://nodejs.org) only if the bootstrap fails (the script then aborts with an actionable error).

### 2. Run the installation script

```powershell
..\copilot-repo-template\install.ps1
```

If script execution is restricted by policy, run it with an execution-policy bypass for this process only:

```powershell
powershell -ExecutionPolicy Bypass -File ..\copilot-repo-template\install.ps1
```

Options mirror `install.sh`; PowerShell uses named parameters:

```powershell
..\copilot-repo-template\install.ps1 -Author "paschbaer" -Email "paschbaer@users.noreply.github.com" -Venv -Beads
```

Platform notes:

- `-Venv` creates the same `.venv` in the target repository (uv-managed Python, never recreated); Spec Kit is installed via `uv pip install --python` and `specify init` runs through the venv entry point resolved from `Scripts\`.
- `-Beads` checks for the `bd` CLI and, if missing, installs beads via winget (`GasTownHall.Beads`) with the npm fallback (`npm install --global @beads/bd`); `bd init` (skipped when `.beads/` exists) and `bd setup copilot` then run in the target repository, exactly as under Bash.
- npm/npx are checked before GitNexus; when missing, Node.js is bootstrapped via fnm (winget `Schniz.fnm`, then `fnm install --lts`) — the lightest per-user install, no administrator rights.
- `uv` is bootstrapped with the official Windows installer (`https://astral.sh/uv/install.ps1`, executed via `Invoke-RestMethod | Invoke-Expression`; the URL is printed before execution). On failure the script aborts in `-Venv` mode and warns otherwise, mirroring the Bash behavior.
- Existing files are never overwritten.

### 3. Continue with the shared steps

Wait for the script to finish, then follow the shared review, validation, and commit steps below — they apply to both platforms.

## Reviewing, Validating, and Committing (both platforms)

### 1. Wait for the installation to finish

The script installs or updates the repository-specific Copilot configuration. Depending on its implementation, this can include:

- Creating or updating `AGENTS.md`
- Installing Copilot custom instructions
- Adding custom agents
- Adding reusable agent skills (`.github/skills/` for Copilot, mirrored to `.agents/skills/` for Zed)
- Adding prompt files
- Installing the Memory Bank templates from `memory-bank-template/` into `memory-bank/`
- Configuring MCP servers
- Applying shared repository conventions

Review any messages printed by the script. If the script reports an error, resolve it before continuing.

### 2. Review the resulting changes

After the script has completed, inspect the repository status:

```bash
git status
```

Review the generated or modified files:

```bash
git diff
```

Pay particular attention to:

```text
AGENTS.md
.github/copilot-instructions.md
.github/agents/
.github/prompts/
.github/skills/
.agents/skills/
.vscode/mcp.json
.vscode/tasks.json
memory-bank/
```

Note: `.vscode/tasks.json` defines a background task that runs GitHub Copilot with `--allow-all-tools` for post-commit reviews. Review this configuration before keeping it in repositories with stricter security requirements.

Adjust the generated configuration if the repository requires project-specific rules, commands, or integrations.

### 3. Validate the setup

Open the repository in Visual Studio Code:

```bash
code .
```

Check that the expected agents, skills, instructions, prompts, and MCP servers are available in the Copilot integration.

Never commit credentials, tokens, passwords, or other secrets. MCP configuration should reference environment variables or another approved secret-management mechanism.

### 4. Commit the configuration

Once the generated configuration has been reviewed and validated, commit it to the repository:

```bash
git add AGENTS.md .github .agents .vscode memory-bank .gitignore
git commit -m "chore: initialize Copilot repository configuration"
```

The configuration is now versioned and can be shared with the rest of the team.

## Quick Start

With the template cloned locally and the terminal in the root directory of the target repository, the complete installation consists of:

Linux / macOS / WSL (Bash):

```bash
chmod +x /path/to/copilot-repo-template/install.sh
cd /path/to/your/target-repository
/path/to/copilot-repo-template/install.sh
```

Windows (PowerShell):

```powershell
cd \path\to\your\target-repository
..\copilot-repo-template\install.ps1
```

Then review the resulting changes:

```bash
git status
git diff
```

## After Installation: Fill the Memory Bank

The files in `memory-bank/` are templates. They contain TODO placeholders and begin with a template banner pointing to this task. Fill them with repository-specific content before they provide value:

1. Run the prompt `.github/prompts/fill-memory-bank.prompt.md` from GitHub Copilot. It guides through all placeholders based on the repository contents and short interviews.
2. Alternatively, fill the files manually; `memory-bank/README.md` describes the purpose of each file.
3. Remove the template banner from each file once its placeholders are resolved.

For ongoing maintenance, the repository includes the agent skill `.github/skills/update-memory-bank/`: after substantial work, it describes which Memory Bank files to update and which rules apply.

## After Installation: Customize AGENTS.md

The installed `AGENTS.md` contains general working rules but no project-specific context. Complete it with the prompt `.github/prompts/fill-agents-md.prompt.md`. It establishes:

- A short repository description (two to three sentences)
- The programming language used, including version and style guide
- Basic implementation rules, such as dependency injection, defining interfaces, or writing unit tests

The prompt preserves all existing rules, creates a backup (`AGENTS.md.bak`) before modifying, and interviews the user instead of inventing standards.

## Updating the Configuration

Run the installation script again when the template has been updated or the repository configuration needs to be refreshed (from the target repository root):

```bash
/path/to/copilot-repo-template/install.sh
```

Always review the resulting changes before committing them.

## Troubleshooting

### Permission denied

If the shell reports `Permission denied`, make the script executable and run it again:

```bash
chmod +x /path/to/copilot-repo-template/install.sh
/path/to/copilot-repo-template/install.sh
```

Alternatively, invoke it directly with Bash:

```bash
bash /path/to/copilot-repo-template/install.sh
```

### Script not found

If the shell reports that the script cannot be found, verify the current directory and the template contents:

```bash
pwd
ls -la /path/to/copilot-repo-template/install.sh
```

Change to the target repository root before invoking the script:

```bash
cd /path/to/your/target-repository
/path/to/copilot-repo-template/install.sh
```

### Windows (PowerShell)

Use the native PowerShell port:

```powershell
..\copilot-repo-template\install.ps1
```

If execution is restricted by policy:

```powershell
powershell -ExecutionPolicy Bypass -File ..\copilot-repo-template\install.ps1
```

Alternatively, run the Bash installer from an environment that provides Bash, such as Windows Subsystem for Linux or Git Bash:

```bash
bash /path/to/copilot-repo-template/install.sh
```

## Included Skills

The template ships these agent skills (available to GitHub Copilot in VS Code via `.github/skills/` and to Zed via `.agents/skills/` — the installers mirror all skills into both locations):

- `update-memory-bank`: updates the Memory Bank after substantial work.
- `guidance-product-refinement`: interactive Product-to-Feature refinement (Product → Epic → Capability → Feature Candidate) and controlled Spec-Kit feature handoff with iterative generate/audit/revise cycles; see `.github/skills/guidance-product-refinement/docs/user-guide-en.md`.

## Customization

After installation, the generated configuration can be adapted to the repository. Common customization points include:

- Build, test, lint, and formatting commands in `AGENTS.md`
- Repository-wide rules in `.github/copilot-instructions.md`
- Specialized roles in `.github/agents/`
- Reusable workflows in `.github/skills/`
- MCP server definitions in `.vscode/mcp.json`

Keep reusable defaults in the template and repository-specific information in the generated repository configuration.

## Contributing

When changing this template:

- Keep the setup deterministic and reproducible.
- Avoid hardcoded machine-specific paths.
- Never add credentials or secrets.
- Keep generated files suitable for version control.
- Document new agents, skills, MCP servers, and configuration options.
- Test `install.sh` before publishing template changes.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
