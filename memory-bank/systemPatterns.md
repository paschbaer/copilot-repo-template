# System Patterns

## Architecture Overview

Describe the system at a high level, including its major components, responsibilities, and boundaries.

TODO

## Component Map

- **Component:** TODO
  - Responsibility: TODO
  - Inputs and outputs: TODO
  - Dependencies: TODO

## Architectural Principles

- Keep responsibilities explicit and components loosely coupled.
- Prefer deterministic and reproducible behavior.
- Preserve existing user-owned files and data by default.
- Apply least privilege to external tools and integrations.
- Keep core logic independent from user-interface integrations.

## Design Patterns

### Pattern: TODO

- **Use when:** TODO
- **Implementation:** TODO
- **Avoid when:** TODO

## Data Flow

1. TODO
2. TODO
3. TODO

## Integration Boundaries

- **External system:** TODO
  - Protocol or interface: TODO
  - Authentication: TODO
  - Failure behavior: TODO

## Error Handling

- Fail early for missing mandatory prerequisites.
- Include the failed operation and an actionable correction in error messages.
- Do not hide partial failures.
- Avoid destructive recovery steps unless explicitly requested.

## Security Patterns

- Never commit secrets.
- Reference secrets through approved environment or secret-management mechanisms.
- Validate external input before use.
- Pin or constrain dependencies where appropriate.
- Document tools that can modify files, execute commands, or access networks.

## Testing Strategy

- Unit tests: TODO
- Integration tests: TODO
- End-to-end tests: TODO
- Manual checks: TODO

## Architectural Decisions

Record durable decisions as ADRs and link them here.

- TODO: `docs/adr/0001-example.md`

## Known Technical Risks

- TODO: Risk, impact, and mitigation
