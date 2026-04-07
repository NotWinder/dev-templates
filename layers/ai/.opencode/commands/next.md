---
description: "Move the next backlog task into in-progress"
agent: "planner"
---

Run:

./scripts/validate.sh

---

## If validation PASSES

* Output:
  "System already has exactly one active task. Nothing to do."
* STOP

---

## If validation FAILS

### Case 1 — NO task in progress (count = 0)

* Read `docs/plan.md` to determine task priority order
* Select the next task from `tasks/backlog/`:
  * Use the order defined in `docs/plan.md` if present
  * Otherwise select the file with the earliest date in its name (alphabetical ascending)
* Run this exact command to move it (do NOT copy — the file must be removed from backlog):

```
mv tasks/backlog/<filename> tasks/in-progress/<filename>
```

* Confirm the file no longer exists in `tasks/backlog/`
* Output:
  "Moved <filename> to in-progress. Run builder to execute it."
* STOP

---

### Case 2 — MULTIPLE tasks in progress

* Output:
  "Invalid state: multiple tasks in progress. Manual intervention required."
* List all filenames
* STOP

---

### Case 3 — DUPLICATES or other errors

* Output:
  "Validation failed due to task inconsistencies."
* Print all errors
* STOP

