# [PROJECT_NAME]

[Short description of what this project does and why it exists]

## Setup

```bash
./scripts/setup.sh
```

> Before opening opencode, fill in `AGENTS.md` with the project overview, stack, and conventions.

## Usage

```bash
./scripts/run.sh
```

## Development

| Task | Command |
|---|---|
| Run | `./scripts/run.sh` |
| Test | `./scripts/test.sh` |
| Lint | `./scripts/lint.sh` |

## AI Workflow

This project uses opencode with a structured task queue in `tasks/`.

```
opencode             # opens in plan mode (default)
@planner [goal]      # break a goal into tasks
/next                # implement the next backlog task
/review src/         # review recent changes
```

See `docs/plan.md` for current milestone and `docs/context.md` for project state.
