# AGENTS.md

## 1. Working Rules (Hard Rules)
- **Strict Compliance**: Strictly adhere to all guidelines in AGENTS.md. Any deviation requires explicit user approval: (1) explain the reason, (2) request explicit consent, (3) document the approved deviation in AGENTS.md. This rule takes precedence over all others when conflicts arise.
- **No Unrequested Changes**: After findings/analyses, the response is observation + solution options. Any corrective action — config edits, registry changes, file changes outside the given task — first requires a concrete confirmation from the user ("Should I do X?") and the agent waits. Ambiguity resolves to NOT acting. This overrides proactivity defaults.
- **Ask, Don't Assume**: When requirements are unclear or a decision is pending, ask the user concretely: present the available action options with their trade-offs, name a recommendation, and wait for the user's answer before continuing. Do not decide unilaterally.
- **File Deletion**: Ask for approval before deleting files you haven't created yourself.
- **Communication**: Keep explanations concise.

## 2. Planning & Reasoning
- Break down complex tasks into a plan first.
- For complex tasks, architectural decisions, or refactoring requests, break the problem into logical steps, verify assumptions, and identify edge cases BEFORE writing code or modifying files. Document the thought process in at least 3-5 steps; revise the plan if it seems uncertain.
- **Bugfix Protocol** — when investigating and fixing bugs, reasoning steps MUST include:
  1. **Reproduction:** Describe exactly how to reproduce the bug; create a failing test case first if possible.
  2. **Root Cause Analysis:** Explain *why* the bug happens, not just *where*.
  3. **Impact Assessment:** Check whether the bug or fix affects other parts of the system.
  4. **Fix Strategy:** Compare at least two approaches (e.g., "quick fix" vs. "robust refactor") before choosing one.
  5. **Verification Plan:** Define how the fix is proven (e.g., "Run npm test", manual UI check).
- **Baseline-aware testing:** Run focused tests first and label pre-existing full-suite failures separately to avoid attributing unrelated regressions to the current task.

## 3. Architecture
- Keep responsibilities isolated by clear module boundaries.
- Extend this section with project-specific implementation rules — see the prompt `.github/prompts/fill-agents-md.prompt.md`.

## 4. Git & Branch Management
- **Feature branches:** When working on `main` or `develop`, always create a feature branch `feature/<meaningful-name>`; all code changes go there (use working trees for concurrent changes), never directly on `main`/`develop`.
- **Before merging:** perform a thorough code review; run all tests and verify error-free execution.
- **Merging:** prefer rebase when merging into `develop`; use squash commits when merging into `main`.
- **After merge:** delete the feature branch.
- **Commits:** clear, descriptive messages following conventional commits format.
- **Cleanup:** remove temporary files before committing (ask for approval before deletion).
- **Documentation:** update README.md for new features or configuration changes and keep documentation in sync with code.

## 5. Memory Bank
Durable project knowledge in `memory-bank/`:

| File | Content |
|---|---|
| `projectBrief.md` | Project purpose, scope, users, success criteria |
| `productContext.md` | User needs, workflows, domain language, business rules |
| `systemPatterns.md` | Architecture, design patterns, boundaries, engineering conventions |
| `techContext.md` | Technology stack, tooling, environments, operational constraints |
| `activeContext.md` | Current focus, recent decisions, open questions, next actions |
| `progress.md` | Status of completed, active, and planned work |
| `lessonsLearned.md` | Reusable lessons from incidents, mistakes, experiments, successes |
| `remaining-work-plan.md` | Tracked follow-ups from review findings and deferred work |

**Before a task:** read `projectBrief.md`, `systemPatterns.md`, `techContext.md`, `activeContext.md`, `progress.md`; consult `productContext.md` for user-facing/domain changes; review `lessonsLearned.md` for prior experience.

**After substantial work:**
- Update `activeContext.md` with new state and next actions; also after every significant change.
- Update `progress.md` ("Overall Status", "Completed", "In Progress", "Planned") — required BEFORE marking a task completed or ending a session; provide a final summary in chat afterwards.
- Update `systemPatterns.md` when architectural decisions change.
- Update `lessonsLearned.md` when resolving a recurring bug, a recurring failing command, a difficult bug, a clever optimization, or a strategic architectural decision. Focus on *why* things failed and *how* to do them right next time.
- After a confirmed bugfix, reflect on whether it is a recurring pattern or a non-obvious trap; if so, add a concise entry ("issue, root cause, preventive measure") to the "Avoid These Mistakes" section of `lessonsLearned.md`.

**Maintenance rules:** Keep entries concise, factual, and current; don't duplicate source code or generated docs; link ADRs/issues/PRs/source files where useful; mark assumptions and unresolved questions explicitly; never store credentials, tokens, personal data, or secrets; remove obsolete information instead of letting contradictions accumulate. These files are the source of truth — always keep them maintained.

## 6. Code Review Protocol
- **Reviewer requirement:** Reviews MUST be performed by the `Review Agent` (`.github/agents/review.agent.md`) as a subagent with a fresh context window (see also the checklist in `.github/prompts/code-review-checklist.prompt.md`). Do not review directly in the main conversation.
- **Before reviewing:** verify `git status --short --branch`, `git rev-parse HEAD`, `git diff`, `git diff --cached`, and the exact review scope; a changed snapshot invalidates the review. For post-commit reviews, verify the target commit with `git show <commit> --stat` and inspect its file diff directly.
- **Evidence:** never dismiss a HIGH/CRITICAL finding without verifying it against the current source and a reproducible check. Record a concise evidence table per finding: file/symbol; reproducible execution path; current code location; test/direct check that proves or disproves it; whether the current diff introduced it; actual severity. One evidence-table row per finding.
- **Approval:** a review may be marked approved only after every HIGH/CRITICAL finding is either fixed or explicitly classified with evidence (already fixed, pre-existing, out of scope with a tracked follow-up, or verified false positive). Never output "approved" without an explicit count of unresolved HIGH/CRITICAL findings.
- **Output:** include a snapshot table stating branch, HEAD, review basis, staged/unstaged diff status, current-source reads, and tests actually executed.
- **Conflicting reports:** treat current source plus reproducible test/check as authoritative over the agent's claim. Stale or contradictory reviewer reports must be recorded as review-quality issues — without removing the obligation to classify the underlying technical concern separately.

## 7. Findings Lifecycle
- Every unresolved review finding (any severity) must be persisted as a tracked follow-up in `memory-bank/activeContext.md` AND `memory-bank/remaining-work-plan.md` BEFORE the scope is closed or the session ends. Reviewer reports and chat summaries do not count as documentation.
- Each entry must state: the finding; its trigger point (the concrete future scope, stage, or condition under which it must be handled); and whether action is required or it is an accepted observation with rationale.
- When a future scope begins, its owner must check tracked follow-ups for matching trigger points and either handle them or explicitly re-schedule them with a new trigger point.
- A finding may only be removed when it is fixed with regression coverage or explicitly reclassified with evidence (e.g., verified false positive or subsumed by another change).

## 8. Rule Updates & Self-Evolution
- **Rule updates:** BEFORE modifying AGENTS.md or any rule file: (1) back it up to `AGENTS.md.bak`, (2) verify the new rules don't contradict existing ones, (3) state in chat what changes are being made and why. If an update fails or causes logic loops, immediately offer to restore from the `.bak` file.
- **Self-evolution:** If a reasoning error or incomplete planning occurs, proactively suggest a Memory Bank Protocol update. After completing a complex task, analyze whether the existing rules were sufficient; if not, ask "Should I optimize the Memory Bank Protocol to avoid this mistake in the future?". The agent is authorized to propose new best practices discovered during work as permanent rules for future sessions.
