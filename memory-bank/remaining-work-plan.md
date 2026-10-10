# Remaining Work Plan

Durable record of unresolved review findings and deferred work, as required by the Findings Lifecycle rules in `AGENTS.md`. Reviewer reports and chat summaries do not count as documentation.

## Entry Format

For every tracked follow-up, include:

- **ID:** Short stable identifier
- **Finding:** What was found or deferred
- **Trigger point:** The concrete future scope, stage, or condition under which it must be handled
- **Action:** Required action, or accepted observation with rationale
- **Origin:** Review, session, or decision that produced it; link where useful
- **Status:** Open | Handled | Reclassified

## Rules

- When a future scope begins, check open follow-ups for matching trigger points; handle them or re-schedule them with a new trigger point.
- A follow-up may only be removed or moved to `Handled` when it is fixed with regression coverage or explicitly reclassified with evidence (e.g., verified false positive or subsumed by another change).
- Keep entries concise and current; remove obsolete information instead of letting contradictions accumulate.
- Never store credentials, tokens, personal data, or secrets here.

## Open Follow-Ups

- **ID:** RW-010 (tracked)
  **Finding:** No full-run smoke test of install.sh (uv bootstrap + --venv, and the --beads option) was executed — a full run would trigger npm global installs, the uv installer, and the beads installer on the development host.
  **Trigger point:** First real installation of the template into a scratch or actual target repository (cover both bd-missing and bd-present paths for --beads).
  **Action:** Run install.sh --venv --beads in a scratch repo; verify .venv creation, uv pip install of specify-cli, specify invocation via the venv entry point, beads installation or skip, bd init, and bd setup copilot; remove this entry afterwards.
  **Status:** Partially handled — bd init behavior live-validated by the operator (AGENTS.md updated, CLAUDE.md/.claude created in this repo); install-chain smoke test still open.

- **ID:** RW-011 (resolved)
  **Finding:** The guidance workflow session for the install.sh extension was cancelled after formal completion kept failing on infrastructure (guidance server served a stale v1 config snapshot; requires server restart to pick up the committed v2 http-docker config).
  **Trigger point:** Resolved — server restarted; the --beads session ran on v2.
  **Action:** Verified: new sessions receive the v2 configuration (no v1-only operations, host.docker.internal URLs). REMAINING: the GitNexus server index for this repo lives in the gitnexus-server container at /tmp (docker cp copy); a future re-analysis should use a persistent mount or the /data/gitnexus storage.
  **Status:** Handled (partial follow-up: persistent GitNexus index location)

## Handled Follow-Ups

All actionable findings from the post-commit review of `e8e429c` were fixed in the follow-up work on `feature/complete-template-assets` (validated via `bash -n install.sh`, `install.sh --help`, and grep checks; the repo has no automated test suite):

- RW-001: Corrected the change records in `activeContext.md` and `progress.md`.
- RW-002: Added the AGENTS.md §5 exception to the `fill-agents-md` prompt.
- RW-003: Generalized the test tooling wording in `review.agent.md` (removed Vitest hardcoding).
- RW-004: Aligned the quoted `progress.md` headings in AGENTS.md §5.
- RW-005: Extended `fill-memory-bank` acceptance criteria to all placeholder-bearing files.
- RW-006: Added `.vscode/tasks.json` to the README checklist and documented the `--allow-all-tools` implication.
- RW-008: Added argument guards, a usage function, and `--help` to `install.sh`.
- RW-009: Shipped a minimal `.gitignore` (ignores `AGENTS.md.bak`) via `install.sh`.

## Accepted Observations

- RW-007: Template banners hardcode the source repo name `copilot-repo-template`. Accepted: the name is an intentional provenance pointer; reword only if the template is forked or renamed.
