---
name: guidance-setup
description: Creates a fresh .guidance/ configuration for this project via the Guidance configuration assistant. Use when the user asks to "set up guidance", "create the guidance config", "guidance setup", or wants a new configuration generated from their own answers. Asks every wizard question one at a time and waits for the operator's answer — never answers on their behalf and never assumes defaults.
---

# Guidance Setup — Fresh Configuration

## When to Use

- The project has no `.guidance/` configuration yet, or a fresh configuration is explicitly requested.
- The operator wants to decide every configuration question themselves (fresh mode: everything is generated from their answers only).

## Never

- Do NOT answer wizard questions on the operator's behalf.
- Do NOT assume default values without explicit confirmation.
- Do NOT batch all questions into one form — one question at a time, then WAIT.

## Procedure

1. Run the `setup_guidance_start` tool (pass the repository name as `workspaceNameHint`).
2. Take the current question, present it with its options, help text, and a derived recommendation, and ask the operator — **one question at a time**.
3. WAIT for the operator's answer before continuing; feed each answer via `setup_guidance_answer` and repeat until the wizard reports `done`.
4. Run `setup_guidance_generate` with the collected answers.
5. Write the returned files to the project root (`.guidance/` structure, including schemas and scripts).
6. Report the created files and the chosen configuration to the operator.
