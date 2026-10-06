# Copilot Repository Template

A reusable repository template for bootstrapping new projects with a consistent GitHub Copilot and Visual Studio Code configuration.

The repository provides a predefined structure for:

- Repository-specific instructions in `AGENTS.md`
- GitHub Copilot custom instructions
- Custom agents
- Agent skills
- Prompt files, where required
- MCP server configuration
- Shared development conventions

The goal is to give new repositories a consistent and maintainable foundation for AI-assisted development.

## Repository Structure

```text
.
├── AGENTS.md
├── .github/
│   ├── copilot-instructions.md
│   ├── agents/
│   ├── prompts/
│   └── skills/
├── .vscode/
│   └── mcp.json
└── install.sh
```

## Installation

Follow these steps to install the template configuration in a repository.

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

### 5. Wait for the installation to finish

The script installs or updates the repository-specific Copilot configuration. Depending on its implementation, this can include:

- Creating or updating `AGENTS.md`
- Installing Copilot custom instructions
- Adding custom agents
- Adding reusable agent skills
- Adding prompt files
- Configuring MCP servers
- Applying shared repository conventions

Review any messages printed by the script. If the script reports an error, resolve it before continuing.

### 6. Review the resulting changes

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
.vscode/mcp.json
```

Adjust the generated configuration if the repository requires project-specific rules, commands, or integrations.

### 7. Validate the setup

Open the repository in Visual Studio Code:

```bash
code .
```

Check that the expected agents, skills, instructions, prompts, and MCP servers are available in the Copilot integration.

Never commit credentials, tokens, passwords, or other secrets. MCP configuration should reference environment variables or another approved secret-management mechanism.

### 8. Commit the configuration

Once the generated configuration has been reviewed and validated, commit it to the repository:

```bash
git add AGENTS.md .github .vscode
git commit -m "chore: initialize Copilot repository configuration"
```

The configuration is now versioned and can be shared with the rest of the team.

## Quick Start

With the template cloned locally and the terminal in the root directory of the target repository, the complete installation consists of:

```bash
chmod +x /path/to/copilot-repo-template/install.sh
cd /path/to/your/target-repository
/path/to/copilot-repo-template/install.sh
```

Then review the resulting changes:

```bash
git status
git diff
```

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

### Windows

Run the script from an environment that provides Bash, such as Windows Subsystem for Linux or Git Bash:

```bash
bash /path/to/copilot-repo-template/install.sh
```

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

See the repository license for details.
