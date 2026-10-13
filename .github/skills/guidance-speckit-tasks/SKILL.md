---
name: guidance-speckit-tasks
description: Drives an EXISTING Spec-Kit feature (specs/<id> with spec.md, plan.md, tasks.md) on the standard workflow using evidence-gated task batches. Use when the user mentions "spec-kit feature", "import the artifacts", "work through tasks.md", "task batches", or names a feature id like 001-rate-limit whose artifacts already exist.
---

# Guidance Workflow — Standard + Spec-Kit Task Tools (Mode 2)

## When to use
Spec-Kit artifacts already exist on disk and the work is executing the
imported plan task by task. The workflow itself stays the default
`standard-development`; the Spec-Kit tools provide the task machinery.

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
