# Dev Template System — Reference & Context

> Last updated: 2026-04-07 (updated after agent/script improvements)
> Purpose: Reference document for the `~/dev/templates/` system — what it is, how it works, and how to evolve it.

---

## What This Is

A composable project scaffolding system built around AI-driven development with opencode.
Instead of copying projects by hand or using a single monolithic template, projects are assembled
from **layers** on top of a **base**, then wrapped into **presets** for common combinations.

---

## Directory Structure

```
~/dev/templates/
├── scripts/
│   └── newproj.sh                 # Scaffolding script — the main entrypoint
│
├── base/                          # Applied to every project regardless of type
│   ├── AGENTS.md                  # Opencode context file — fill this in before opening opencode
│   ├── README.md
│   ├── opencode.json              # Sets default_agent to "plan"
│   ├── .aiignore
│   ├── .editorconfig
│   ├── .gitignore
│   ├── .opencode/
│   │   ├── agents/                # Slot for project-level agent overrides (.gitkeep)
│   │   └── commands/              # Slot for project-level custom commands (.gitkeep)
│   └── scripts/
│       ├── setup.sh
│       ├── run.sh                 # Stub — override in project root
│       ├── test.sh                # Stub — override in project root
│       ├── lint.sh                # Stub — override in project root
│       └── validate.sh            # Strict project consistency validator
│
├── layers/                        # Composable feature layers
│   ├── ai/                        # AI-driven workflow layer
│   │   ├── .opencode/
│   │   │   ├── agents/            # Planner, builder, reviewer, task-expander
│   │   │   │   ├── builder.md
│   │   │   │   ├── planner.md
│   │   │   │   ├── reviewer.md
│   │   │   │   └── task-expander.md
│   │   │   └── commands/          # /expand, /next, /review
│   │   │       ├── expand.md
│   │   │       ├── next.md
│   │   │       └── review.md
│   │   ├── docs/
│   │   │   ├── architecture.md
│   │   │   ├── context.md         # Persistent AI context — update as project evolves
│   │   │   ├── decisions.md       # ADR-style decision log
│   │   │   └── plan.md            # Current milestone and task tracking
│   │   ├── tasks/
│   │   │   ├── backlog/           # Tasks not yet started
│   │   │   ├── in-progress/       # Current active task (one at a time)
│   │   │   └── done/              # Completed tasks
│   │   └── scripts/
│   │       ├── expand.sh          # Calls opencode run --agent task-expander
│   │       ├── review.sh          # Calls opencode run --agent reviewer
│   │       └── run.sh
│   │
│   ├── cli/                       # CLI tool layer
│   │   ├── cmd/main.py
│   │   ├── internal/              # Internal modules (empty stub)
│   │   ├── docs/                  # Project docs (empty stub)
│   │   └── scripts/
│   │       ├── build.sh
│   │       ├── run.sh
│   │       └── test.sh
│   │
│   ├── infra/                     # Infrastructure / ops layer
│   │   ├── config/                # Config files (empty stub)
│   │   ├── Makefile
│   │   └── scripts/
│   │       ├── check.sh
│   │       ├── format.sh
│   │       └── lint.sh
│   │
│   └── web/                       # Web frontend layer
│       ├── src/
│       ├── components/
│       ├── hooks/
│       ├── lib/
│       ├── styles/
│       ├── public/
│       ├── docs/
│       └── scripts/
│           ├── build.sh
│           └── dev.sh
│
└── presets/                       # Named combinations of layers
    ├── ai-project/
    │   └── preset.json            # layers: [base, ai, cli, infra]
    ├── ai-cli/
    │   └── preset.json            # layers: [base, ai, cli]
    └── ai-web/
        └── preset.json            # layers: [base, ai, web]
```

---

## How It Works

### Scaffolding a new project

```bash
bash ~/dev/templates/scripts/newproj.sh <name> <layer1> [layer2] ...
bash ~/dev/templates/scripts/newproj.sh <name> --preset <preset>
```

Examples:
```bash
bash ~/dev/templates/scripts/newproj.sh ai-todo ai cli
bash ~/dev/templates/scripts/newproj.sh my-api ai cli infra
bash ~/dev/templates/scripts/newproj.sh my-site ai web
bash ~/dev/templates/scripts/newproj.sh my-app --preset ai-project
```

By default, projects are created in `$HOME/dev/active/`. Override with:
```bash
PROJECTS_DIR=/path/to/dir bash ~/dev/templates/scripts/newproj.sh ...
```

The script:
1. Validates all layers exist before touching the filesystem
2. Prevents overwriting an existing project
3. Applies layers in order (later layers win on file conflicts)
4. Applies `base/` last so base files always win
5. Substitutes `[PROJECT_NAME]` in all text files
6. Runs `git init` and makes an initial commit

### Layer application order

```
layers/ai/  →  layers/cli/  →  base/
```

Base is applied first and layers are applied on top so layer-provided implementations (for
example `cli/scripts/run.sh` or `infra/scripts/lint.sh`) are preserved. After layers are
applied, the scaffolder re-applies a small set of authoritative base files so they remain
canonical: `AGENTS.md`, `opencode.json`, and `scripts/validate.sh`.

---

## Key Files Explained

### `AGENTS.md` (base)
The most important file. Opencode reads this to understand the project before doing anything.
**Always fill this in before opening opencode on a new project.**

Sections:
- **Overview** — what the project does
- **Structure** — what lives where
- **Stack** — language, framework, key deps
- **Source of Truth** — priority order for resolving conflicts between docs, code, and git
- **Behavior Rules** — how the AI must verify claims before answering
- **Task Rules** — one-task invariant, format requirements, validate.sh enforcement
- **Git Rules** — working directory takes precedence over git history
- **Conventions** — naming, style, patterns
- **Workflows** — how to run, test, build, lint, validate
- **Current Focus** — what's actively being worked on
- **Known Issues** — gotchas, workarounds, tech debt

### `opencode.json` (base)
Sets `default_agent` to `"plan"` so opencode always opens in plan mode.
Prevents accidental file edits when you just want to think something through.

```json
{
  "default_agent": "plan"
}
```

### `base/scripts/` (base)
The base layer provides stub scripts (`run.sh`, `test.sh`, `lint.sh`) that print an error and
exit. These exist so `AGENTS.md`'s workflow references are never broken. Override them at the
project level or by applying a layer that provides real implementations (e.g., `cli` or `infra`).

`validate.sh` is a strict project consistency validator. It enforces:
- Exactly **one** task exists in `tasks/in-progress/` at all times
- No duplicate task filenames across `backlog/` and `in-progress/`
- No task exists in both `in-progress/` and `done/`
- All active tasks contain the four required sections (`## Goal`, `## Context`, `## Acceptance Criteria`, `## Steps`)
- Required scripts (`run.sh`, `test.sh`, `setup.sh`) are present

It also emits a **warning** (non-fatal) if any file in `tasks/done/` is newer than `docs/context.md`,
which indicates a task may have completed without updating context.

Run it before starting any task: `./scripts/validate.sh`

> **Fresh projects:** a newly scaffolded project has zero tasks in `in-progress/`, so
> `validate.sh` will fail immediately. This is expected — run `/next` first to move a task
> from the backlog, then the builder can proceed. The `/next` command explicitly handles the
> 0-task case and does not require validation to pass before moving a task.

### `base/.opencode/` (base)
Empty placeholder directories (`agents/`, `commands/`) for project-level overrides.
The `.gitkeep` files keep these tracked by git. Drop agent or command files here to
customise opencode behaviour for a specific project without changing the shared layer.

### `docs/context.md` (ai layer)
Persistent context file for AI sessions. Unlike `AGENTS.md` which describes the project structure,
`context.md` describes the *current state* — what works, what's in flight, what's out of scope.
Update it regularly. Reference it in opencode with `@docs/context.md`.
The builder agent updates it after completing every task.

### `docs/plan.md` (ai layer)
Current milestone and task priority order. The planner writes to this when planning a feature.
The `/next` command reads it to decide which backlog task to move into `in-progress/` — tasks
listed here take precedence over alphabetical filename order.

### `docs/decisions.md` (ai layer)
ADR-style log of architectural and design decisions. The planner and reviewer both read this
before acting, so decisions made in previous sessions inform new work and review findings.

### `docs/architecture.md` (ai layer)
High-level structural description of the project — major components, boundaries, and data flow.
The planner reads this before creating tasks to avoid producing work that conflicts with the
intended structure.

### `tasks/` (ai layer)
The AI task queue. Three-state kanban on the filesystem:

| Directory | Meaning |
|---|---|
| `tasks/backlog/` | Planned but not started |
| `tasks/in-progress/` | Currently being worked on (keep to one at a time) |
| `tasks/done/` | Completed — keep for context |

Task files are named `YYYYMMDD-slug.md` and follow this format:
```markdown
# Task: [title]

## Goal
[One sentence describing what this task achieves]

## Context
[Why this task is needed — link to relevant decisions or prior work]

## Acceptance Criteria
- [ ] [concrete, verifiable outcome]

## Steps
1. [first concrete action]
2. [next action]
```

---

## Presets

| Preset | Layers | Description |
|---|---|---|
| `ai-project` | `base, ai, cli, infra` | Full AI-driven project with CLI and infrastructure |
| `ai-cli` | `base, ai, cli` | Lightweight AI-assisted CLI tool |
| `ai-web` | `base, ai, web` | AI-assisted web frontend project |

---

## Agents

All agent files live in `.opencode/agents/` at the project root after scaffolding.

| Agent | Purpose | Modifies source code? |
|---|---|---|
| `planner` | Reads AGENTS.md + docs, breaks goals into tasks, writes to backlog | No (writes to `tasks/` only) |
| `builder` | Reads AGENTS.md, checkpoints any partial work via git, implements the in-progress task, runs tests + lint | Yes |
| `reviewer` | Reads AGENTS.md + decisions, reviews code for quality and conventions | No |
| `task-expander` | Reads AGENTS.md + context, expands vague tasks into concrete subtasks | No (writes to `tasks/`, moves original to `done/`) |

Switch the active agent with `Tab` in the TUI.

---

## Commands

Custom opencode slash commands live in `.opencode/commands/` and are available inside the TUI.

| Command | Agent | What it does |
|---|---|---|
| `/next` | planner | Runs validate.sh; if no task is in-progress, moves the next backlog task there (priority from plan.md, then filename order) |
| `/build` | builder | Implements the current in-progress task — runs validate.sh, writes code, tests, lint, moves task to done/ |
| `/expand [description]` | task-expander | Expands a task into subtasks; lists backlog and prompts if no argument given |
| `/review [file or path]` | reviewer | Reviews the specified file or recent git changes if no argument given |

---

## Typical AI-Driven Workflow

```
1. Scaffold
   bash ~/dev/templates/scripts/newproj.sh myproject ai cli

2. Fill in AGENTS.md
   Describe the project, stack, conventions, current focus

3. Open opencode
   cd ~/dev/active/myproject && opencode

4. Plan (default mode — Tab to check)
   @planner [describe what you want to build]
   → Agent writes task files to tasks/backlog/

5. Expand if needed
   /expand [vague task description]
   → task-expander breaks it into smaller tasks

6. Start next task
   /next
   → Moves the next backlog task to in-progress (uses plan.md priority order)
   → Confirm the correct task was selected before proceeding

7. Implement it
   /build
   → Builder reads AGENTS.md, runs validate.sh, implements the task, runs tests + lint,
     moves task to done/, updates docs/context.md

8. Review
   /review src/
   → Reviewer reports findings without touching code

9. Repeat from step 6 until milestone is done

10. Update docs/plan.md and docs/context.md
    Keep them current so future sessions have good context
```

---

## Design Decisions

### Agents must be in `.opencode/agents/`, not `agents/`
Opencode only resolves `@agentname` from `.opencode/agents/`. The template was initially
placing them in `agents/` at the project root — this was fixed. The `ai` layer now scaffolds
directly into `.opencode/agents/`.

### `base/` applied first; layers override scripts; config files re-applied last
The application order went through two iterations:

1. **v1 (base last):** Base applied after layers so `AGENTS.md` and `opencode.json` always came
   from base. Problem: base stub scripts (`run.sh`, `test.sh`, `lint.sh`) also "won", overwriting
   working implementations provided by `cli` and `infra` layers. The builder would then fail on
   `./scripts/test.sh` and `./scripts/lint.sh` because they exited 1.

2. **v2 (current):** Base is applied first. Layers are applied on top (so `cli/scripts/run.sh`,
   `cli/scripts/test.sh`, `infra/scripts/lint.sh` survive). Then a final pass re-applies only
   the three files that must always be canonical base versions: `AGENTS.md`, `opencode.json`,
   and `scripts/validate.sh`. This preserves both working layer scripts and authoritative base
   config.

### `cp -r .` not `cp -r *`
Glob `*` silently skips dotfiles, which means `.opencode/` would never be copied.
The script uses `cp -r "$src/." "$DEST/"` to include hidden files and directories.

### Stub scripts in `base/scripts/`
`run.sh`, `test.sh`, and `lint.sh` are intentional fallback stubs that exit with an error.
They serve as a final safety net for projects where no layer provided a real implementation.
In practice, the `cli` layer always overrides `run.sh` and `test.sh`, and the `infra` layer
overrides `lint.sh`. A project using neither of those layers should replace these scripts
manually before running `/build`.

### `validate.sh` implemented in `base/scripts/`
Initially listed as a future improvement, `validate.sh` is now fully implemented. It is a
strict consistency validator that enforces the one-task invariant, checks for task format
compliance, detects duplicates, and verifies required scripts exist. The builder agent runs
it as a mandatory pre-flight check before executing any task.

### Builder reads `AGENTS.md` before any work
The builder agent runs `AGENTS.md` as its first pre-flight step, before `validate.sh`. This
ensures project conventions, stack details, and naming rules are loaded into context before
any code is written.

### Task-expander moves originals to `done/`
The task-expander previously said "archive or delete" the original vague task — ambiguous
and inconsistent with the three-state kanban. It now always moves the original to `tasks/done/`.

### Builder runs lint as part of task completion
Lint is a required step in the builder's completion workflow, run after tests pass. A task is
not considered complete until both `./scripts/test.sh` and `./scripts/lint.sh` pass.

### `sed -i` portability (GNU vs BSD)
GNU `sed -i` (Linux) and BSD `sed -i` (macOS) require different syntax for in-place editing.
`newproj.sh` detects which flavour is present at runtime and selects the correct form, so
`[PROJECT_NAME]` substitution works on both platforms. Binary file detection uses `grep -qI`
(portable) rather than the `file` command (not always available).

### Builder creates a git checkpoint before writing code
After `validate.sh` passes, the builder runs `git add -A && git commit -m "chore: wip <task>"` before
touching any source files. If there is nothing to commit (clean start) this is a no-op. If a
previous session was interrupted mid-implementation, the partial work is committed first, giving
a clean rollback point before new code is added.

### Builder has explicit interrupted-session recovery cases
The builder's Recovery Behavior distinguishes three cases: (A) clean start with no prior work,
(B) interrupted mid-implementation with uncommitted changes — assess what's done and continue
without re-doing completed work, (C) implementation appears complete — run tests and lint and
complete the lifecycle if they pass.

### `validate.sh` warns on stale `docs/context.md`
If any file in `tasks/done/` is newer than `docs/context.md`, `validate.sh` emits a warning
(non-fatal). This surfaces the most likely symptom of an interrupted completion — the task was
moved to done but context was never updated.

---

## Known Limitations

### `validate.sh` requires exactly one in-progress task
A freshly scaffolded project has zero tasks, so `validate.sh` will always fail on a new project.
Run `/next` first to move a task from backlog to in-progress before invoking the builder.
See the note in the `validate.sh` section above.

### Interrupting a task mid-implementation is safe; interrupting the completion lifecycle is not
If a session is interrupted while the builder is writing code, the next `/build` will detect
the partial work (via `git status`), commit it as a checkpoint, and continue from where it left
off. However, if a session is interrupted *after* `mv tasks/in-progress/ → tasks/done/` but
*before* `docs/context.md` is updated, the task count drops to zero, `validate.sh` warns about
stale context, and the user must manually update `docs/context.md` before running `/next`.
There is no automated recovery for the narrow window between the `mv` and the context update.

---

## Future Improvements

- [ ] Add a `django` layer for org backend projects
- [ ] Add a `python-lib` layer for standalone Python packages
- [ ] Add `.opencode/commands/plan.md` — trigger a full planning session from scratch
- [ ] Populate `docs/context.md` with project name during scaffold (currently blank)
- [ ] Consider moving `tasks/` into `.opencode/tasks/` to keep AI workflow files together
- [ ] Add a `--list` flag to `newproj.sh` to enumerate available layers and presets
