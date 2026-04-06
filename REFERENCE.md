# Dev Template System — Reference & Context

> Last updated: 2026-04-06
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
│       └── lint.sh                # Stub — override in project root
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

Base is always applied last so its files (`AGENTS.md`, `opencode.json`, etc.) are never
overwritten by a layer.

---

## Key Files Explained

### `AGENTS.md` (base)
The most important file. Opencode reads this to understand the project before doing anything.
**Always fill this in before opening opencode on a new project.**

Sections:
- **Overview** — what the project does
- **Structure** — what lives where
- **Stack** — language, framework, key deps
- **Conventions** — naming, style, patterns
- **Workflows** — how to run, test, build
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

### `base/.opencode/` (base)
Empty placeholder directories (`agents/`, `commands/`) for project-level overrides.
The `.gitkeep` files keep these tracked by git. Drop agent or command files here to
customise opencode behaviour for a specific project without changing the shared layer.

### `docs/context.md` (ai layer)
Persistent context file for AI sessions. Unlike `AGENTS.md` which describes the project structure,
`context.md` describes the *current state* — what works, what's in flight, what's out of scope.
Update it regularly. Reference it in opencode with `@docs/context.md`.

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

| Agent | Purpose | Modifies files? |
|---|---|---|
| `planner` | Breaks goals into tasks, writes to backlog | No (only tasks/) |
| `builder` | Implements tasks from in-progress/ | Yes |
| `reviewer` | Reviews code for quality and conventions | No |
| `task-expander` | Expands vague tasks into concrete subtasks | No (only tasks/) |

Invoke with `@agentname` in an opencode message, e.g.:
```
@planner I want to add an export feature. Plan it out.
```

Switch the active agent with `Tab` in the TUI.

---

## Commands

Custom opencode slash commands live in `.opencode/commands/` and are available inside the TUI.

| Command | Agent | What it does |
|---|---|---|
| `/expand <description>` | task-expander | Breaks a vague task into subtasks in backlog/ |
| `/next` | builder | Picks next backlog task, moves to in-progress, implements it |
| `/review <file or path>` | reviewer | Reviews the specified file or recent changes |

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

6. Build
   Tab  (switch to builder / build mode)
   /next
   → Builder picks next task and implements it

7. Review
   @reviewer  (or /review src/)
   → Reviewer reports findings without touching code

8. Repeat from step 6 until milestone is done

9. Update docs/plan.md and docs/context.md
   Keep them current so future sessions have good context
```

---

## Known Issues & Decisions

### Agents must be in `.opencode/agents/`, not `agents/`
Opencode only resolves `@agentname` from `.opencode/agents/`. The template was initially
placing them in `agents/` at the project root — this was fixed. The `ai` layer now scaffolds
directly into `.opencode/agents/`.

### `base/` applied last (not first)
Early versions applied base first and layers on top, which caused layer files to overwrite
base files like `AGENTS.md`. Order was reversed so base always wins.

### `cp -r .` not `cp -r *`
Glob `*` silently skips dotfiles, which means `.opencode/` would never be copied.
The script uses `cp -r "$src/." "$DEST/"` to include hidden files and directories.

### Stub scripts in `base/scripts/`
`run.sh`, `test.sh`, and `lint.sh` are intentional stubs that exit with an error.
They exist to keep `AGENTS.md` workflow references valid at all times, and to make
it obvious when a project hasn't been wired up yet. Replace them at the project level.

---

## Future Improvements

- [ ] Add a `django` layer for org backend projects
- [ ] Add a `python-lib` layer for standalone Python packages
- [ ] Add `.opencode/commands/plan.md` — trigger a full planning session from scratch
- [ ] Populate `docs/context.md` with project name during scaffold (currently blank)
- [ ] Add a `validate.sh` script that checks a scaffolded project for missing required files
- [ ] Consider moving `tasks/` into `.opencode/tasks/` to keep AI workflow files together
- [ ] Add a `--list` flag to `newproj.sh` to enumerate available layers and presets
