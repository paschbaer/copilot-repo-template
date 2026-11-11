---
name: guidance-speckit-tasks
description: Drives an EXISTING Spec-Kit feature (specs/<id> with spec.md, plan.md, tasks.md) on the standard workflow using evidence-gated task batches. Use when the user mentions "spec-kit feature", "import the artifacts", "work through tasks.md", "task batches", or names a feature id like 001-rate-limit whose artifacts already exist.
---

# Guidance Workflow — Standard + Spec-Kit Task Tools (Mode 2)

## When to use
Spec-Kit artifacts already exist on disk and the work is executing the
imported plan task by task. The workflow itself stays the default
`standard-development`; the Spec-Kit tools provide the task machinery.

## Workspace resolution

- `start_workflow` takes the workspace's REGISTERED NAME (kebab-case, e.g. `dcfamily`) — never a display name, a host path, or free text from the request.
- Discover the registered name BEFORE calling: check prior run records, the repository's `.guidance/` configuration, or ask the operator. Do not guess.
- If the workspace is not yet registered: register it with
  `registry_register { name: "<kebab-case>", root: "<absolute repository path>" }`
  — Windows paths are supported (e.g. `D:\repos\cabp`); there is no
  Docker/pool path indirection. On failure, ask the operator; do not guess.

## Procedure
1. `start_workflow { workspace: "<registered-name>", request: "<task>" }`
   — NO `workflowId`.
2. Locate and import the feature (task tools FAIL without import):
   `discover_spec_kit_feature` (only if the feature id is unknown) →
   `import_spec_kit_artifacts { featureId }` → creates a hash-pinned snapshot.
3. Task loop (repeat until no ready tasks remain). Two levels —
   implementation and review are BATCH calls (one submission covers all
   tasks of the batch), only verification and completion are per task:
   - Batch level:
     `get_next_task` → `release_batch { mode: "single"|"batch"|"allReady" }` →
     `start_task { batchId, taskIds[] }` → implement →
     `submit_task_implementation { evidence: [...] }` — ONE call for the whole
     batch, one evidence item PER TASK (`taskId`, summary, changedFiles, tests;
     a checkbox in tasks.md is a hint, NEVER proof) →
     `submit_task_review { findings: [...] }` — ONE review for the whole batch;
     each finding carries `taskIds[]` (may span multiple tasks), `severity`,
     `fixRequired`, `fixApplied`; blocking findings gate completion.
   - Task level (per task):
     `verify_task { taskId, succeeded, executions }` →
     `complete_task { taskId }`.
   - Parallel execution (preferred when tasks.md carries parallelization
     metadata or tasks are wave-parallelizable): the current agent stays the
     guidance-workflow session owner and dispatches implementation through
     the skills `task-compiler` and `agent-scheduler`:
     1. Compile the batch's tasks with `task-compiler` → validated
        `task-graph.json` with waves and write scopes.
     2. Execute wave by wave with `agent-scheduler`: the current agent acts
        as orchestrator, prepares worktrees, and spawns AT MOST 3 parallel
        subagents (`spawn_agent`), each executing exactly one task in its
        worktree as a guidance workflow (per `guidance-plain-workflow`).
     3. Collect subagent results; the orchestrator — not the subagents —
        performs the guidance task-tool submissions above (batch evidence,
        review, `verify_task`, `complete_task`) from the collected
        changedFiles/tests. Failed tasks block dependent tasks; a retry is a
        new subagent session (max 2 attempts).
     The workflow gates (review, verification, completion) run unchanged on
     the orchestrator's session — parallelism affects EXECUTION only.
4. Plan deviations: NEVER edit artifacts silently — `propose_plan_change`
   (minor/major classification) → user decision → `approve_plan_change` →
   `apply_plan_change`, then `refresh_spec_kit_artifacts`.
5. Finish: `get_traceability_report` → `validate_spec_kit_completion` →
   `complete_workflow`.

## Hard rules
- Import FIRST. `import_spec_kit_artifacts` before any task tool call.
- Stale snapshot (artifacts changed on disk) blocks completion —
  `refresh_spec_kit_artifacts` reconciles.
- `complete_task` requires evidence + review + verification + satisfied
  dependencies; the returned `spec_kit_task_*` error names what is missing.
- Parallel dispatch: never exceed 3 concurrently running subagents; subagents
  only implement (guidance workflow in their worktree) — ALL task-tool
  submissions (`submit_task_*`, `verify_task`, `complete_task`) are made by
  the orchestrator session.
