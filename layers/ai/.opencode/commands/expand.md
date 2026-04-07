---
description: "Expand a vague task into concrete subtasks"
agent: "task-expander"
---

If no argument is given:

- List the task files currently in `tasks/backlog/`
- Ask the user which task to expand
- STOP and wait for a response before proceeding

If an argument is given, expand it into concrete subtasks:

$ARGUMENTS

Write each subtask to `tasks/backlog/` as a separate markdown file.
