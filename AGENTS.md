#  AGENTS.md

## Architecture Map
- Before answering architecture or codebase questions, use the GitNexus graph tools to analyze the codebase (skill: gitnexus-workflow.md).
- Do not make blind edits or assumptions about execution pathways. Always query the precomputed knowledge graph for context.
- Type `gitnexus analyze --no-stats` in Terminal to build or update the knowledge graph. The `--no-stats` flag is mandatory in this repo: it keeps AGENTS.md/CLAUDE.md free of volatile symbol/relationship counts so code changes don't dirty these files.

## Agent Working Rules
- Always break down complex tasks into a plan first. See Reasoning & Planning Rules.
- Ask for approval before deleting files you haven't created yourself.
- Keep strategy logic isolated by module responsibility (scanner/signal/risk/execution).
- Keep console output readable;

## Review Evidence Protocol
- Never dismiss a HIGH or CRITICAL review finding without first verifying it against the current source and a reproducible check.
- For every review finding, record a concise evidence table containing: file/symbol; reproducible execution path; current code location; test or direct check that proves or disproves it; whether the current diff introduced it; and the actual severity.
- When reviewer reports conflict, treat the current source plus reproducible test/check as authoritative over the agent's claim.
- A review may be marked approved only after every HIGH/CRITICAL finding is either fixed or explicitly classified with evidence as already fixed, pre-existing, out of scope with a tracked follow-up, or a verified false positive.
- Stale or contradictory reviewer reports must themselves be recorded as review-quality issues; this does not remove the obligation to classify the underlying technical concern separately.
- Before reviewing, the reviewer must verify `git status --short --branch`, `git rev-parse HEAD`, `git diff`, `git diff --cached`, and the exact review scope; a changed snapshot invalidates the review.
- The reviewer output must include a snapshot table stating the branch, HEAD, review basis, staged/unstaged diff status, current-source reads, and tests actually executed.
- The reviewer must provide one evidence-table row for every finding and must not output `approved` or equivalent without an explicit count of unresolved HIGH/CRITICAL findings.
- For post-commit reviews, the reviewer must verify the target commit with `git show <commit> --stat` and inspect that commit's file diff directly.

## Findings Lifecycle Rule
- Every unresolved review finding (any severity) must be persisted in `memory-bank/activeContext.md` AND `memory-bank/remaining-work-plan.md` as a tracked follow-up BEFORE the scope is closed or the session ends. Reviewer reports and chat summaries do not count as documentation.
- Each tracked follow-up must state: the finding, its trigger point (the concrete future scope, stage, or condition under which it must be handled), and whether action is required or it is an accepted observation with rationale.
- When a future scope begins, its owner must check the tracked follow-ups for entries whose trigger point matches that scope and either handle them or explicitly re-schedule them with a new trigger point.
- A finding may only be removed from the tracked follow-ups when it is fixed with regression coverage or explicitly reclassified with evidence (e.g., verified false positive or subsumed by another change).

## Reasoning & Planning Rules
- For complex tasks, architectural decisions, or refactoring requests, you MUST use the `clearthought` tool.
- Use the `clearthought` process to break down the problem into logical steps, verify assumptions, and identify edge cases BEFORE writing code or modifying files.
- Document your thought process in at least 3-5 steps within the tool to ensure a structured solution.
- If a solution seems uncertain, use the "thought revision" capability of the server to adjust your plan accordingly.

## Branch Management Rules
- **Feature Branch Requirement**: When working on `main` or `develop` branches, always create a feature branch following the pattern `feature/<meaningful-name>`.
- **Code Changes**: All code changes must be made in the feature branch, not directly on `main` or `develop`. Use `working trees` for concurrent changes. 
- **Code Review**: Before merging to `develop` or `main`, perform a thorough code review to identify and fix any issues.
- **Test Execution**: Run all tests and verify their error-free execution before merging.
- **Documentation Standards**: Update README.md for any new features or configuration changes and keep documentation in sync with code changes.
- **Meta-Data**: Update the knowledge graph (see Architecture Map).
- **Rebase**: When merging to `develop`, try to rebase. If this is not possible merge branches the common way.
- **Squash Commit**: When merging to `main`, use squash commit to maintain a clean history.
- **Branch Cleanup**: Delete the feature branch after successful merge.
- **Commit Messages**: Use clear, descriptive commit messages following conventional commits format.
- **Cleanup**: Remove temporary files before committing. Ask for approval before deletion.

## Self-Evolution Rule
- If you make an error in the reasoning process or realize your planning steps were incomplete, you MUST proactively suggest an update to `Memory Bank Protocol`.
- After completing a complex task, analyze whether the existing rules were sufficient. If not, ask: "Should I optimize the `Memory Bank Protocol` to avoid this mistake in the future?"
- You are authorized to propose new best practices discovered during our work as permanent rules for future sessions.

## Strict Compliance Rule
- You MUST strictly adhere to all guidelines in AGENTS.md.
- Any deviation from AGENTS.md rules requires explicit user approval.
- Before deviating from established procedures, you must:
  1. Explain the reason for the proposed deviation
  2. Request explicit user consent
  3. Document the approved deviation in AGENTS.md
- This rule takes precedence over all other guidelines when conflicts arise.

## Bugfix Protocol (clearthought)
When investigating and fixing bugs, your reasoning steps MUST include:
1. **Reproduction:** Describe exactly how to reproduce the bug. If possible, create a failing test case first.
2. **Root Cause Analysis:** Explain *why* the bug is happening, not just *where*. Identify the underlying logic flaw.
3. **Impact Assessment:** Check if this bug (or the proposed fix) affects other parts of the system or related components.
4. **Fix Strategy:** Compare at least two ways to fix the issue (e.g., a "quick fix" vs. a "robust refactor") before choosing one.
5. **Verification Plan:** Define how you will prove the bug is gone (e.g., "Run npm test" or "Verify manual UI state").

## User Preferences & Persistent Memory
- **Communication:**
	- Keep explanations concise

## Lessons Learned (Self-Evolving)
- When we resolve a recurring bug or make a strategic architectural decision, update `memory-bank/lessonsLearned.md`.
- Check these lessons before starting any new task to avoid repeating past mistakes.
- Baseline-aware testing: run focused tests first and label pre-existing full-suite failures separately to avoid attributing unrelated regressions to the current task.

# Rule Update & Backup Protocol
- BEFORE modifying `AGENTS.md` or any rule file, you MUST:
  1. Create a backup of the current file by copying it to `.clinerules.bak` or `AGENTS.md.bak`.
  2. Use the `clearthought` tool to verify that the new rules do not contradict existing ones.
  3. Clearly state in the chat what changes you are making and why.
- If an update fails or causes logic loops, immediately offer to restore from the `.bak` file.

# Memory Bank Protocol
- Before starting any task, read all files in the `memory-bank/` directory.
- Update `activeContext.md` after every significant change to track progress.
- Update `systemPatterns.md` when new architectural decisions are made.
- Update `lessonsLearned.md` when you resolve a recurring bug or recurring failing command.
- Always maintain the source of truth in these files.

# Session Termination, Progress Tracking $ Self-Evolving
- BEFORE marking a task as "completed" or ending a session, you MUST update `memory-bank/progress.md` and `memory-bank/lessonsLearned.md`.
- In `progress.md`, document:
  1. **What works:** Features or fixes successfully implemented.
  2. **What's left:** Pending tasks or known issues.
  3. **Current State:** A brief summary of the overall project status.
- In `lessonsLearned.md`, document:
  1. **What bugs occured:** How were these bugs fixed or how to work around them. Focus on "why" things failed and "how" to do them right next time.
- Once updated, provide a final summary in the chat so I know the documentation is current.

# Automatic Post-Bugfix Documentation
- Immediately AFTER a bug is confirmed as fixed (verified by tests or manual check), you MUST:
  1. Reflect on whether this bug represents a recurring pattern or a non-obvious trap.
  2. If so, add a new entry to the "Avoid These Mistakes" section in `memory-bank/lessonsLearned.md`.
  3. Keep the entries concise: State the issue, the root cause, and the preventive measure (e.g., a specific code pattern or a new rule for `AGENTS.md` and `.clinerules`).
- **Lessons Learned Tracking:** Whenever you solve a particularly difficult bug, find a clever optimization, or we decide on a specific "best practice," you MUST document this in `memory-bank/lessonsLearned.md`. 
- Focus on "why" things failed and "how" to do them right next time.
