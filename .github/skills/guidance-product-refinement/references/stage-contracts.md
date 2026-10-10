# Internal Stage Contracts

## Product Refinement

- **PR-1 Initialize/Resume:** validate source, transition, contract, previous state, and pinned inputs.
- **PR-2 Generate:** create a complete direct Child Set plus coverage, overlap, dependencies, decisions, and questions.
- **PR-3 Audit:** check coverage, overlap, cohesion, level, scope, constraints, dependencies, traceability, identity, and contract conformity.
- **PR-4 Revise:** resolve every blocking finding in a complete new proposal revision, preserving prior evidence.
- **PR-5 Gate:** return `auto-approved`, `rejected`, or `pending-verification`; prose alone never approves.
- **PR-6 Materialize:** stage, validate, and atomically persist approved artifacts and hierarchy-index changes.

## Spec-Kit Feature Handoff

- **SH-1 Eligibility:** validate candidate, approval, findings, contract, path, and invocation availability.
- **SH-2 Input:** create the complete `/speckit.specify` request with traceability and scope controls.
- **SH-3 Capture:** record result files, invocation metadata, paths, and digests without accepting them.
- **SH-4 Audit:** compare the generated specification with the approved Feature Candidate.
- **SH-5 Correct:** produce or apply a correction for all blocking findings, then repeat capture and audit.
- **SH-6 Gate:** return `auto-accepted`, `rejected`, or `pending-verification`.

All stage transitions are driven internally by the initial workflow controller.
