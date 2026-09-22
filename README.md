# Copilot Repository Template

A reusable repository template for bootstrapping new projects with a consistent GitHub Copilot and Visual Studio Code configuration.

This repository provides a predefined structure for:

- Repository-specific instructions in `AGENTS.md`
- GitHub Copilot custom instructions
- Custom agents
- Agent skills
- Prompt files (where required)
- MCP (Model Context Protocol) server configuration
- Shared development conventions and best practices

The goal is to ensure that every new repository starts with a consistent, maintainable, and AI-friendly development environment.

---

# Repository Structure

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

---

# Getting Started

Follow the steps below to create a new project using this template.

## 1. Clone the Template Repository

Clone the template repository into your local workspace:

```bash
git clone https://github.com/<organization>/copilot-repo-template.git

cd ..
```

Example workspace layout:

```text
workspace/
└── copilot-repo-template/
```

---

## 2. Create a New Project Directory

Create a new directory for your project next to the template repository:

```bash
mkdir my-new-project
```

Your workspace should now look similar to:

```text
workspace/
├── copilot-repo-template/
└── my-new-project/
```

---

## 3. Change to the Project Directory

```bash
cd my-new-project
```

---

## 4. Initialize a Git Repository (Optionally)

If the directory is not already a Git repository, initialize one:

```bash
git init
```

---

## 5. Run the Installation Script

Execute the installation script from the template repository:

```bash
../copilot-repo-template/install.sh
```

If necessary, make the script executable first:

```bash
chmod +x ../copilot-repo-template/install.sh
```

Then run:

```bash
../copilot-repo-template/install.sh
```

The script will:

- Copy the Copilot configuration into the current repository
- Preserve existing files
- Install GitNexus if required
- Initialize GitNexus
- Install Spec Kit if required
- Initialize Spec Kit
- Configure agents, skills, prompts, and MCP integrations

---

## 6. Review the Generated Files

Inspect the generated repository:

```bash
git status
```

Expected files include:

```text
AGENTS.md
.github/
.vscode/
.specify/
.gitnexus/
```

Review all generated content before committing.

---

## 7. Commit the Initial Configuration

```bash
git add .
git commit -m "chore: initialize Copilot configuration"
```

---

## 8. Open the Repository in Visual Studio Code

```bash
code .
```

You can now use GitHub Copilot with the preconfigured agents, skills, instructions, and MCP integrations.

---

# Quick Start

```bash
git clone https://github.com/<organization>/copilot-repo-template.git

mkdir my-new-project
cd my-new-project

git init

chmod +x ../copilot-repo-template/install.sh
../copilot-repo-template/install.sh

git add .
git commit -m "chore: initialize Copilot configuration"

code .
```


# Quick Start

For experienced users, the entire setup process is:

```bash
git clone https://github.com/<organization>/<repository>.git
cd <repository>

chmod +x install.sh
./install.sh

git status
git diff
```

---

# Updating an Existing Repository

To apply the latest template configuration to an existing repository, rerun the installation script:

```bash
./install.sh
```

Always review the resulting changes before committing them.

---

# Troubleshooting

## Permission Denied

If the script cannot be executed:

```bash
Permission denied
```

Grant execute permissions and run it again:

```bash
chmod +x install.sh
./install.sh
```

Alternatively:

```bash
bash install.sh
```

---

## Script Not Found

If the shell reports that the script cannot be found:

```bash
./install.sh: No such file or directory
```

Verify that you are in the repository root:

```bash
pwd
ls -la
```

You should see:

```text
install.sh
```

before executing the script.

---

## Windows

Run the script using one of the following environments:

- Windows Subsystem for Linux (WSL)
- Git Bash
- VS Code Integrated Terminal with Bash

Example:

```bash
bash install.sh
```

---

# Customization

After installation, the generated configuration can be adapted to your project's requirements.

Common customization points include:

- Build and test commands in `AGENTS.md`
- Repository-wide rules in `.github/copilot-instructions.md`
- Specialized agents in `.github/agents/`
- Reusable workflows in `.github/skills/`
- MCP server definitions in `.vscode/mcp.json`

Repository-specific configuration should be committed to version control so that all team members share the same setup.

---

# Contributing

When updating this template:

- Keep the setup deterministic and reproducible
- Avoid machine-specific paths
- Never include secrets or credentials
- Keep generated files suitable for version control
- Document all agents, skills, prompts, and MCP integrations
- Test `install.sh` before publishing template changes

---

# License

See the repository license for details.