# Lessons Learned

This document captures reusable, evidence-based knowledge from implementation work, incidents, experiments, reviews, and successful practices.

Do not use it as a chronological activity log. Only record lessons that are likely to influence future decisions or prevent repeated mistakes.

## How to Add a Lesson

For every lesson, include:

- **Date:** When the lesson was validated
- **Context:** What was being attempted
- **Observation:** What happened
- **Root cause:** Why it happened, if known
- **Lesson:** The reusable insight
- **Action:** What should be done differently
- **Evidence:** Relevant issue, pull request, log, test, ADR, or source file
- **Status:** Proposed, validated, or superseded

## Validated Lessons

### Preserve Existing User-Owned Files

- **Date:** Initial setup
- **Context:** Installing shared repository configuration into an existing project.
- **Observation:** Blindly copying template files can overwrite project-specific changes.
- **Root cause:** Copy operations did not distinguish between missing and existing target files.
- **Lesson:** Installation and bootstrap processes must preserve existing files by default.
- **Action:** Check every target file individually, skip existing files, and print a clear message. Require an explicit option for destructive replacement.
- **Evidence:** Repository bootstrap design.
- **Status:** Validated

### Verify Prerequisites Before Installation

- **Date:** Initial setup
- **Context:** Installing command-line tools during project initialization.
- **Observation:** Reinstalling available tools wastes time and can unexpectedly change versions.
- **Root cause:** Installers did not check whether the required executable was already available.
- **Lesson:** Detect tools before installing them and report the discovered executable and version where possible.
- **Action:** Use command discovery before package-manager installation and fail with an actionable message when required package managers are missing.
- **Evidence:** Repository bootstrap design.
- **Status:** Validated

## Proposed Lessons

No proposed lessons yet.

## Superseded Lessons

No superseded lessons yet.

## Entry Template

Copy this section when adding a lesson:

```markdown
### Short Descriptive Title

- **Date:** YYYY-MM-DD
- **Context:** TODO
- **Observation:** TODO
- **Root cause:** TODO
- **Lesson:** TODO
- **Action:** TODO
- **Evidence:** TODO
- **Status:** Proposed | Validated | Superseded
```
