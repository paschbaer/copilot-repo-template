# Remaining Work Plan

> **Template notice:** This file is a template from `copilot-repo-template` and contains TODO placeholders. Replace the placeholders with repository-specific content — see `.github/prompts/fill-memory-bank.prompt.md`.

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

- TODO: First entry

## Handled Follow-Ups

None yet.

## Accepted Observations

None yet.
