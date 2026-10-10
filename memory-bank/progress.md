# Progress

## Overall Status

**Phase:** Initial setup

**Summary:** The Memory Bank has been initialized. Project-specific content is still required.

## Completed

- [x] Create the Memory Bank directory structure.
- [x] Add baseline documents for product, architecture, technology, and delivery context.
- [x] Add a reusable lessons-learned document.
- [x] Add Copilot custom instructions and a starter skill.

## In Progress

- [ ] Define project purpose, scope, and success criteria.
- [ ] Document the initial architecture.
- [ ] Record development and validation commands.

## Planned

- [ ] Define the first milestone.
- [ ] Add acceptance criteria for the first deliverable.
- [ ] Record initial architectural decisions.
- [ ] Validate the development environment.

## Known Issues

- Project-specific placeholders remain unresolved.

## Milestones

### Milestone 1: Repository Ready

**Status:** Not started

**Exit criteria:**

- [ ] Project brief is complete.
- [ ] Build, test, lint, and run commands are documented and verified.
- [ ] Architecture and important boundaries are documented.
- [ ] Repository instructions reference the Memory Bank.
- [ ] No unresolved critical setup issues remain.

## Change Log

### Initial Setup

- Initialized the Memory Bank.
- Added `lessonsLearned.md`.

### Template Completion

- Added `.github/copilot-instructions.md`.
- Added starter skill `.github/skills/update-memory-bank/`.
- Added prompt `.github/prompts/fill-memory-bank.prompt.md`.
- Added prompt `.github/prompts/fill-agents-md.prompt.md`.
- Added template banners to all `memory-bank-template/` files (the instance `memory-bank/` carries no banners).
- Added an MIT license (`LICENSE`).
- Corrected the README structure, fixed the `git add` example, and documented the Memory Bank workflow.
- Removed leftovers from `AGENTS.md` (backup at `AGENTS.md.bak`).
- Added `memory-bank-template/` with clean templates and switched `install.sh` to it.
- Added `remaining-work-plan.md` (template + instance) and the "Ask, Don't Assume" rule in `AGENTS.md`.
- Fixed all review findings RW-001 to RW-009, including `install.sh` argument guards/usage and a shipped `.gitignore`.

### install.sh: uv bootstrap and --venv option

- Added `ensure_uv()` (official standalone installer, PATH refresh for `~/.local/bin` and `~/.cargo/bin`).
- Added `--venv` flag: creates `.venv` via uv-managed Python, installs specify-cli with `uv pip install --python`, invokes specify via the venv entry point (portable bin/Scripts resolution).
- Template `.gitignore` ships `.venv/`; README documents both features including the curl|sh security note.
- Guidance config regenerated with operator-confirmed wizard answers (http-docker transport, insight off); workflow session cancelled after stale-config infrastructure blocker — follow-ups RW-010 (smoke test) and RW-011 (server restart) tracked.

### install.sh: --beads option

- Added `--beads` flag with `install_beads()` (official install script with checksum verification, npm fallback, hard abort on double failure) and `initialize_beads()` (`bd init` skipped when `.beads/` exists, then always `bd setup copilot`).
- README documents the option incl. AGENTS.md ordering note; RW-010 extended to cover --beads.

### install.ps1: PowerShell port

- New install.ps1 (repo root, PS 5.1-compatible, full feature parity: named params -Author/-Email/-Venv/-Beads, never-overwrite copies, GitNexus/uv/Spec-Kit bootstraps, -Venv and -Beads chains; winget id GasTownHall.Beads verified via winget search).
- README restructured: Installation on Linux/macOS/WSL (Bash), Installation on Windows (PowerShell), shared review/validate/commit section, dual Quick Start, Windows troubleshooting.
- Validation: AST parser 0 errors, -Help exit 0, unknown-arg exit 1, install.sh byte-identical.
