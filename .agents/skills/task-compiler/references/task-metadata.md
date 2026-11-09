# Spec Kit parallel task metadata contract

Add a fenced `taskmeta` block immediately below each task line.

```markdown
- [ ] T004 [P] [US1] Implement GoalFirstStrategy in `crates/forge-clearthought/src/methods/goal_first.rs`

  ```taskmeta
  depends_on: [T001, T003]
  write_scope:
    - crates/forge-clearthought/src/methods/goal_first.rs
  read_scope:
    - crates/forge-decision/**
    - specs/004-clearthought/contracts/**
  exclusive_resources:
    - forge-clearthought-method-registry
  validation:
    - cargo test -p forge-clearthought goal_first
    - cargo clippy -p forge-clearthought --all-targets -- -D warnings
  agent_profile: rust-builder
  estimated_minutes: 30
  max_attempts: 2
  non_goals:
    - Do not change public decision contracts.
    - Do not add MCP integration.
  ```
```

## Supported fields

| Field | Required | Meaning |
|---|---:|---|
| `depends_on` | yes | Task IDs that must complete first. Use `[]` when empty. |
| `write_scope` | yes | Files or glob-like paths the task may modify. |
| `read_scope` | no | Context paths the agent may inspect. |
| `exclusive_resources` | no | Logical resources that cannot be changed concurrently. |
| `validation` | yes | Commands that prove completion. |
| `agent_profile` | yes | Scheduler adapter/profile name. |
| `estimated_minutes` | yes | Expected agent runtime. Prefer 15 to 45. |
| `max_attempts` | yes | Maximum execution attempts. Recommended maximum: 2. |
| `non_goals` | yes | Explicit scope exclusions. |

The parser supports a deliberately small YAML subset: inline arrays and indented string lists. Avoid nested mappings.
