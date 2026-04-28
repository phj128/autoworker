---
name: dispatch
description: "Read subtask.md checkbox state and route to the next skill in the execution loop. Use when resuming work, continuing tasks, determining what's next, or recovering after context loss. The sole routing point — called after autoworker:checkpoint, autoworker:gate-check, autoworker:subtask-update, or autoworker:subtask-plan."
---

# autoworker:dispatch — Execution Chain Router (Sole Routing Point)

Reads subtask.md checkbox state and routes to the next skill based on fixed priority.

**When to call**: Automatically called after autoworker:checkpoint, autoworker:gate-check, autoworker:subtask-update, autoworker:subtask-plan complete, or manually called after context loss.

## Execution Flow

### 1. Locate Subtask

```
Glob `subtask_*.md` (exclude subtask_template.md) →
  0 found → stop, prompt to create subtask
  1 found → use directly (backward compatible)
  multiple → grep `status:` to filter:
    - Files without status field treated as active (backward compatible)
    - Exactly 1 active → use it
    - 0 active → list all files + status, prompt user to choose
    - >1 active → report anomaly
→ Read → extract:
- Plan section Phase checkbox states
- Verification plan section L1-L4 checkbox states
- Whether a `Gate result:` line exists and its value
```

### 2. Status Summary

Tally and output current state:

```
dispatch (subtask: <filename>):
- Phases: X/N complete
- Tests: L1 done/pending, L2 done/pending/skip, L3 done/pending/skip, L4 done/pending
- Gate: <empty/PASS/FAIL>
```

### 3. Fixed Priority Routing

Evaluate in this order, **execute the first match, do not continue evaluating**:

1. **Has incomplete Phase?** → invoke `autoworker:code`
2. **All Phases complete, has untested layer?** → invoke `autoworker:test <level>` (pass the first incomplete level)
3. **All tests complete, no Gate result?** → invoke `autoworker:gate-check`
4. **Gate result = PASS?** → output completion report (**terminal point, do not invoke any further skill**)
5. **Gate result = FAIL?** → invoke `autoworker:subtask-update`

### 4. Output Routing Decision

Append routing decision after the status summary:

```
→ Invoking autoworker:code to implement Phase Y
```
or
```
→ Invoking autoworker:test L2
```
or
```
→ Invoking autoworker:gate-check
```
or
```
Task complete! Outputting completion report.
```
or
```
→ Invoking autoworker:subtask-update (Gate FAIL)
```

### 5. Execute Route

**After outputting the routing decision, immediately invoke the corresponding skill. Do not wait for user instructions, do nothing else.**

Only exception: Gate PASS — directly output completion report, do not invoke any other skill.

## Constraints

- **Stateless — reads only, never infers**: State comes entirely from the file on each invocation, not from conversation context. Ensures consistency after context loss
- **Layers marked "skip" count as complete**: If the plan says "skip L2, reason: ..." and has no L2 items → treated as complete
- **Accepts no arguments**: Entirely driven by file state
- **Gate result reading method**: grep for `Gate result:` line, read PASS or FAIL
- **PASS is the only terminal point**: Only when Gate PASS does dispatch terminate the loop
- **Makes no modifications**: Does not edit files, write code, or run tests — only reads and routes
- **Loop-safe**: Never calls itself — only calls autoworker:code, autoworker:test, autoworker:gate-check, or autoworker:subtask-update
