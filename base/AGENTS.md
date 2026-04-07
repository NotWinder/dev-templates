# Project: [PROJECT_NAME]

## Overview
[One paragraph describing what this project does and why it exists]

## Structure
[Describe key directories and what lives where]

## Stack
- Language: [e.g. Python 3.12]
- Framework: [e.g. Django / FastAPI / none]
- Key dependencies: [list the important ones]

## Source of Truth

When determining project state, use this strict priority order:

1. **Code and tests** — the only ground truth; what runs is what exists
2. **Filesystem** — scripts/, directory structure, file presence
3. **docs/plan.md** — intended state and current milestone
4. **tasks/** — active work queue and execution history
5. **Git history** — informational only; may not reflect working directory

Rules:
- Never assume git reflects the current working state
- Always verify claims against the filesystem and tests
- When in doubt, run the code

## Behavior Rules

Before answering any question about how to run the project:
- Verify the relevant script exists on the filesystem before citing it
- Do not describe a workflow that hasn't been confirmed to exist

Before answering any question about project state:
- Inspect the actual code and tests, not just documentation
- Run tests if needed to confirm what is working

Before answering any question about task state:
- Inspect tasks/in-progress/, tasks/backlog/, and tasks/done/ directly

When an inconsistency is detected between documentation, code, and filesystem:
- Report it explicitly before proceeding
- Do not silently paper over it
- Never rely solely on documentation as a substitute for verification

## Task Rules

- Only ONE task file may exist in tasks/in-progress/ at any time
- Completed tasks MUST be moved to tasks/done/ — never deleted
- Tasks missing required sections are invalid and must not be executed
- Always read docs/context.md before starting work
- Update docs/context.md after completing a task

Required sections in every task file:

```
## Goal
## Context
## Acceptance Criteria
## Steps
```

Any task file missing one or more of these sections is considered malformed.
Run `./scripts/validate.sh` to check task integrity before starting work.

## Git Rules

- Uncommitted changes are part of the current state — do not ignore them
- Git history reflects past snapshots, not necessarily present reality
- Always prefer the working directory over git log or git blame
- Do not assume a file was deleted just because it isn't tracked

## Conventions
- Use snake_case for files and variables
- Each module has a single responsibility
- Keep functions small and focused
- Write tests alongside implementation

## Workflows
- Setup:    `./scripts/setup.sh`
- Run:      `./scripts/run.sh`
- Test:     `./scripts/test.sh`
- Lint:     `./scripts/lint.sh`
- Validate: `./scripts/validate.sh`

## Current Focus
[What is actively being worked on right now]

## Known Issues / Constraints
[Anything the AI should be aware of — workarounds, tech debt, env quirks]
