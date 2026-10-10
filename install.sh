#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$PWD"

GIT_AUTHOR_NAME=""
GIT_AUTHOR_EMAIL=""
VENV_ENABLED=0
VENV_DIR=""
VENV_PYTHON=""
BEADS_ENABLED=0
ANALYZE_ENABLED=0

usage() {
  printf 'Usage: install.sh [--author NAME] [--email EMAIL] [--venv] [--beads] [--analyze]\n'
  printf '  --venv    Run all uv/Python calls in a .venv inside the target repository.\n'
  printf '  --beads   Install beads (bd) if missing, then run bd init and bd setup copilot.\n'
  printf '  --analyze Also initialize GitNexus (gitnexus setup and gitnexus analyze) in the target repository.\n'
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --author)
      [[ $# -ge 2 ]] || { printf 'ERROR: --author requires a value.\n' >&2; usage; exit 1; }
      GIT_AUTHOR_NAME="$2"
      shift 2
      ;;
    --email)
      [[ $# -ge 2 ]] || { printf 'ERROR: --email requires a value.\n' >&2; usage; exit 1; }
      GIT_AUTHOR_EMAIL="$2"
      shift 2
      ;;
    --venv)
      VENV_ENABLED=1
      shift
      ;;
    --beads)
      BEADS_ENABLED=1
      shift
      ;;
    --analyze)
      ANALYZE_ENABLED=1
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown option: %s\n' "$1" >&2
      usage
      exit 1
      ;;
  esac
done

ensure_git_repository() {
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    printf 'CHECK: Git repository detected.\n'
    return 0
  fi

  printf 'INIT: No Git repository found. Initializing repository...\n'

  git init

  printf 'INIT: Git repository created.\n'
}

configure_git_author() {
  if [[ -z "$GIT_AUTHOR_NAME" && -z "$GIT_AUTHOR_EMAIL" ]]; then
    printf 'SKIP: No Git author configuration specified.\n'
    return 0
  fi

  printf 'CONFIG: Setting Git repository author information...\n'

  if [[ -n "$GIT_AUTHOR_NAME" ]]; then
    git config user.name "$GIT_AUTHOR_NAME"
    printf 'CONFIG: user.name = %s\n' "$GIT_AUTHOR_NAME"
  fi

  if [[ -n "$GIT_AUTHOR_EMAIL" ]]; then
    git config user.email "$GIT_AUTHOR_EMAIL"
    printf 'CONFIG: user.email = %s\n' "$GIT_AUTHOR_EMAIL"
  fi
}

copy_file_if_missing() {
  local source="$1"
  local target="$2"
  local relative_target="${target#"$TARGET_DIR/"}"

  if [[ -e "$target" || -L "$target" ]]; then
    printf 'SKIP: %s already exists and was not overwritten.\n' "$relative_target"
    return 0
  fi

  if [[ ! -f "$source" ]]; then
    printf 'SKIP: Source file %s does not exist.\n' "$source"
    return 0
  fi

  mkdir -p -- "$(dirname -- "$target")"
  cp -- "$source" "$target"
  printf 'COPY: %s\n' "$relative_target"
}

copy_directory_contents() {
  local source_dir="$1"
  local target_dir="$2"
  local source_file relative_path

  if [[ ! -d "$source_dir" ]]; then
    printf 'SKIP: Source directory %s does not exist.\n' "$source_dir"
    return 0
  fi

  while IFS= read -r -d '' source_file; do
    relative_path="${source_file#"$source_dir/"}"
    copy_file_if_missing "$source_file" "$target_dir/$relative_path"
  done < <(find "$source_dir" -type f -print0)
}

ensure_node() {
  printf 'CHECK: Looking for an existing npm/npx installation...\n'

  if command -v npm >/dev/null 2>&1 && command -v npx >/dev/null 2>&1; then
    printf 'SKIP: npm and npx are already installed (%s).\n' "$(command -v npm)"
    return 0
  fi

  printf 'INSTALL: npm/npx incomplete or missing. Bootstrapping Node.js via fnm (lightest per-user install)...\n'

  if ! command -v fnm >/dev/null 2>&1; then
    printf 'INSTALL: fnm was not found. Installing it with the official install script...\n'
    printf 'INSTALL: https://fnm.vercel.app/install\n'

    if command -v curl >/dev/null 2>&1; then
      if ! curl -fsSL https://fnm.vercel.app/install | bash; then
        printf 'WARNING: The fnm install script reported a failure.\n' >&2
      fi
    else
      printf 'WARNING: curl is required for the fnm install script but was not found.\n' >&2
    fi

    export PATH="$HOME/.local/share/fnm:$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
  fi

  if ! command -v fnm >/dev/null 2>&1; then
    printf 'ERROR: fnm is required to bootstrap Node.js but could not be installed.\n' >&2
    printf 'ERROR: Install Node.js manually (https://nodejs.org) and run this script again.\n' >&2
    return 1
  fi

  printf 'INSTALL: Installing the Node.js LTS release via fnm...\n'
  eval "$(fnm env --shell bash)"

  if ! fnm install --lts; then
    printf 'ERROR: fnm could not install the Node.js LTS release.\n' >&2
    printf 'ERROR: Install Node.js manually (https://nodejs.org) and run this script again.\n' >&2
    return 1
  fi

  fnm use lts-latest
  fnm default lts-latest || true

  if command -v npm >/dev/null 2>&1 && command -v npx >/dev/null 2>&1; then
    printf 'INSTALL: Node.js bootstrap completed (npm at %s).\n' "$(command -v npm)"
    return 0
  fi

  printf 'ERROR: npm/npx are still unavailable after the Node.js bootstrap.\n' >&2
  printf 'ERROR: Install Node.js manually (https://nodejs.org) and run this script again.\n' >&2
  return 1
}

install_gitnexus() {
  printf 'CHECK: Looking for an existing GitNexus installation...\n'

  if command -v gitnexus >/dev/null 2>&1; then
    printf 'SKIP: GitNexus is already installed at %s.\n' "$(command -v gitnexus)"
    gitnexus --version || true
    return 0
  fi

  if ! command -v npm >/dev/null 2>&1; then
    printf 'ERROR: npm is required to install GitNexus but was not found.\n' >&2
    printf 'Install Node.js and npm, then run this script again.\n' >&2
    return 1
  fi

  printf 'INSTALL: GitNexus was not found. Installing it globally with npm...\n'
  npm install --global gitnexus@latest
  printf 'INSTALL: GitNexus installation completed.\n'
}

initialize_gitnexus() {
  printf 'INIT: Configuring GitNexus MCP integrations...\n'
  gitnexus setup

  printf 'INIT: Analyzing repository %s...\n' "$TARGET_DIR"
  (
    cd -- "$TARGET_DIR"
    gitnexus analyze
  )

  printf 'INIT: GitNexus initialization completed.\n'
}

ensure_uv() {
  printf 'CHECK: Looking for an existing uv installation...\n'

  if command -v uv >/dev/null 2>&1; then
    printf 'SKIP: uv is already installed at %s.\n' "$(command -v uv)"
    uv --version || true
    return 0
  fi

  printf 'INSTALL: uv was not found. Installing it with the official standalone installer...\n'
  printf 'INSTALL: https://astral.sh/uv/install.sh\n'

  if command -v curl >/dev/null 2>&1; then
    if ! curl -LsSf https://astral.sh/uv/install.sh | sh; then
      printf 'WARNING: The uv installer reported a failure.\n' >&2
    fi
  else
    printf 'WARNING: curl is required to install uv but was not found.\n' >&2
  fi

  export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

  if command -v uv >/dev/null 2>&1; then
    printf 'INSTALL: uv installation completed (%s).\n' "$(command -v uv)"
    return 0
  fi

  if [[ "$VENV_ENABLED" -eq 1 ]]; then
    printf 'ERROR: uv is required for --venv but could not be installed.\n' >&2
    printf 'ERROR: Install uv manually (https://docs.astral.sh/uv/getting-started/installation/) and run this script again.\n' >&2
    return 1
  fi

  printf 'WARNING: uv could not be installed; continuing without it. Spec Kit will fall back to pipx or pip.\n' >&2
}

create_project_venv() {
  VENV_DIR="$TARGET_DIR/.venv"

  if [[ -d "$VENV_DIR" ]]; then
    printf 'SKIP: Virtual environment already exists at %s.\n' "$VENV_DIR"
  else
    printf 'INIT: Creating virtual environment at %s (uv-managed Python)...\n' "$VENV_DIR"
    uv venv "$VENV_DIR"
    printf 'INIT: Virtual environment created.\n'
  fi

  if [[ -x "$VENV_DIR/bin/python" ]]; then
    VENV_PYTHON="$VENV_DIR/bin/python"
  elif [[ -x "$VENV_DIR/Scripts/python.exe" ]]; then
    VENV_PYTHON="$VENV_DIR/Scripts/python.exe"
  else
    printf 'ERROR: No Python interpreter found inside %s.\n' "$VENV_DIR" >&2
    return 1
  fi

  printf 'INIT: Using virtual environment interpreter %s.\n' "$VENV_PYTHON"
}

install_beads() {
  printf 'CHECK: Looking for an existing beads installation...\n'

  if command -v bd >/dev/null 2>&1; then
    printf 'SKIP: beads is already installed at %s.\n' "$(command -v bd)"
    bd version || true
    return 0
  fi

  printf 'INSTALL: beads was not found. Installing it with the official install script...\n'
  printf 'INSTALL: https://raw.githubusercontent.com/gastownhall/beads/main/scripts/install.sh\n'

  if command -v curl >/dev/null 2>&1; then
    if ! curl -fsSL https://raw.githubusercontent.com/gastownhall/beads/main/scripts/install.sh | bash; then
      printf 'WARNING: The beads install script reported a failure.\n' >&2
    fi
  else
    printf 'WARNING: curl is required for the beads install script but was not found.\n' >&2
  fi

  export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

  if command -v bd >/dev/null 2>&1; then
    printf 'INSTALL: beads installation completed (%s).\n' "$(command -v bd)"
    return 0
  fi

  if command -v npm >/dev/null 2>&1; then
    printf 'INSTALL: Falling back to the npm installation of beads...\n'
    if ! npm install --global @beads/bd; then
      printf 'WARNING: The npm fallback installation of beads failed.\n' >&2
    fi
  else
    printf 'WARNING: npm fallback unavailable (npm not found).\n' >&2
  fi

  if command -v bd >/dev/null 2>&1; then
    printf 'INSTALL: beads installation completed (%s).\n' "$(command -v bd)"
    return 0
  fi

  printf 'ERROR: beads could not be installed (install script and npm fallback failed).\n' >&2
  printf 'ERROR: Install beads manually (https://github.com/gastownhall/beads) and run this script again.\n' >&2
  return 1
}

initialize_beads() {
  (
    cd -- "$TARGET_DIR"

    if [[ -d ".beads" ]]; then
      printf 'SKIP: beads appears to be already initialized (.beads exists).\n'
    else
      printf 'INIT: Running bd init...\n'
      bd init
    fi

    printf 'INIT: Running bd setup copilot...\n'
    bd setup copilot
  )

  printf 'INIT: beads initialization completed.\n'
}

install_speck_kit() {
  printf 'CHECK: Looking for an existing Spec Kit installation...\n'

  if [[ "$VENV_ENABLED" -eq 1 ]]; then
    printf 'INSTALL: Installing Spec Kit into the virtual environment...\n'
    uv pip install --python "$VENV_PYTHON" specify-cli
    return 0
  fi

  if command -v specify >/dev/null 2>&1; then
    printf 'SKIP: Spec Kit is already installed at %s.\n' "$(command -v specify)"
    specify version || true
    return 0
  fi

  if command -v uv >/dev/null 2>&1; then
    printf 'INSTALL: Installing Spec Kit using uv...\n'
    uv tool install specify-cli
    return 0
  fi

  if command -v pipx >/dev/null 2>&1; then
    printf 'INSTALL: Installing Spec Kit using pipx...\n'
    pipx install specify-cli
    return 0
  fi

  if command -v pip >/dev/null 2>&1; then
    printf 'INSTALL: Installing Spec Kit using pip...\n'
    pip install specify-cli
    return 0
  fi

  printf 'ERROR: Could not install Spec Kit.\n' >&2
  printf 'Install uv, pipx, or pip and run the script again.\n' >&2
  return 1
}

initialize_speck_kit() {
  printf 'INIT: Initializing Spec Kit for GitHub Copilot...\n'

  local specify_cmd="specify"

  if [[ "$VENV_ENABLED" -eq 1 ]]; then
    if [[ -x "$VENV_DIR/bin/specify" ]]; then
      specify_cmd="$VENV_DIR/bin/specify"
    elif [[ -x "$VENV_DIR/Scripts/specify.exe" ]]; then
      specify_cmd="$VENV_DIR/Scripts/specify.exe"
    else
      printf 'ERROR: specify was not found in the virtual environment %s.\n' "$VENV_DIR" >&2
      return 1
    fi
  fi

  (
    cd -- "$TARGET_DIR"

    if [[ ! -d ".specify" ]]; then
      "$specify_cmd" init --here --integration copilot
    else
      printf 'SKIP: Spec Kit already appears to be initialized.\n'
    fi
  )

  printf 'INIT: Spec Kit initialization completed.\n'
}

ensure_git_repository
configure_git_author

copy_directory_contents "$SCRIPT_DIR/.github" "$TARGET_DIR/.github"
copy_file_if_missing "$SCRIPT_DIR/AGENTS.md" "$TARGET_DIR/AGENTS.md"
copy_directory_contents "$SCRIPT_DIR/.vscode" "$TARGET_DIR/.vscode"
copy_file_if_missing "$SCRIPT_DIR/.gitignore" "$TARGET_DIR/.gitignore"
copy_directory_contents "$SCRIPT_DIR/.github/skills" "$TARGET_DIR/.agents/skills"
copy_directory_contents "$SCRIPT_DIR/memory-bank-template" "$TARGET_DIR/memory-bank"

ensure_node

install_gitnexus

if [[ "$ANALYZE_ENABLED" -eq 1 ]]; then
  initialize_gitnexus
fi

ensure_uv

if [[ "$VENV_ENABLED" -eq 1 ]]; then
  create_project_venv
fi

install_speck_kit
initialize_speck_kit

if [[ "$BEADS_ENABLED" -eq 1 ]]; then
  install_beads
  initialize_beads
fi

printf 'Copilot setup installation completed. Existing files were preserved.\n'
