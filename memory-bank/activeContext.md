# Active Context

> This file describes the current working state. Keep it concise and update it after substantial work.

## Current Focus

Initial repository setup and definition of project context.

## Current Objective

Replace the placeholders in the Memory Bank with repository-specific information and validate the development setup.

## Current Work

- [ ] Complete `projectBrief.md`.
- [ ] Document user needs and domain rules in `productContext.md`.
- [ ] Describe the architecture in `systemPatterns.md`.
- [ ] Record the actual toolchain and commands in `techContext.md`.
- [ ] Define the initial roadmap in `progress.md`.

## Recent Changes

- Created the initial Memory Bank structure.
- Added `lessonsLearned.md` for reusable insights.
- Extended the template: Copilot custom instructions, starter skill `update-memory-bank`, Memory Bank banners, fill prompt, MIT license.
- Corrected the README structure and documented the Memory Bank workflow (placeholders, fill prompt, skill).
- Added the `fill-agents-md` prompt and documented it in the README.
- Removed leftovers from `AGENTS.md` (trading-specific architecture rule, `.clinerules.bak`).
- Separated distributable Memory Bank templates into `memory-bank-template/`; `memory-bank/` is now this repository's own instance; `install.sh` copies from the template folder.
- Added `remaining-work-plan.md` (template and instance); the pre-existing §7 reference became valid, and a §5 table row was added.
- Added the "Ask, Don't Assume" rule to `AGENTS.md` §1.
- Fixed all post-commit review findings RW-001 to RW-009 (see `remaining-work-plan.md`).
- Guidance workflow session active: install.sh extension (uv bootstrap + --venv option) on branch `feature/install-uv-venv`.
- Guidance workflow cancelled by operator decision after infrastructure blocker (stale v1 config snapshot on the guidance server; see RW-011).
- Guidance v2 config active (server restarted); --beads workflow session session-bbbf628c running on branch `feature/install-beads-option`.
- --beads workflow COMPLETED (all gates passed incl. repository-analysis after indexing the repo into the gitnexus-server container). Working tree carries operator-created artifacts (AGENTS.md GitNexus section, CLAUDE.md, .claude/) from the operator's WSL bd/gitnexus live test — not committed by the agent. Implementation is complete, committed, and validated.

## Recent Decisions

- The Memory Bank is version-controlled with the repository.
- Durable context belongs in the Memory Bank, while task-specific details belong in issues or work items.
- Secrets and sensitive data must never be stored in Memory Bank files.

## Open Questions

- [ ] What is the first deliverable?
- [ ] Which technical constraints are mandatory?
- [ ] Which validations must pass before changes are considered complete?

## Blockers

- Project-specific context has not yet been supplied.

## Next Actions

1. Run the prompt `.github/prompts/fill-memory-bank.prompt.md` to replace the TODO placeholders.
2. Complete the project brief.
3. Document the initial architecture and toolchain.
4. Define the first milestone and acceptance criteria.
5. Remove resolved TODO placeholders.

## Last Updated

TODO (YYYY-MM-DD, author)
