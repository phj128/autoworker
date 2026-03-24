---
name: test
description: |
  Execute ONE test level (L1/L2/L3/L4) from subtask verification plan. Only run tests, do not record results.
  Called by autoworker:dispatch with level argument. Ends by calling autoworker:checkpoint.
argument-hint: "[L1|L2|L3|L4]"
---

# autoworker:test — Execute One Test Layer

Called by autoworker:dispatch with a target level argument. Does one thing: execute all test items for that layer from the subtask verification plan.

## Execution Flow

### 1. Determine Target Level

- Has argument (e.g., `autoworker:test L2`) → use that level
- No argument → read subtask verification plan, infer the first incomplete level

### 2. Read Verification Plan

```
Glob `subtask_*.md` (exclude subtask_template.md) →
  0 found → stop, prompt to create subtask
  1 found → use directly (backward compatible)
  multiple → grep `status:` to filter:
    - Files without status field treated as active (backward compatible)
    - Exactly 1 active → use it
    - 0 active → list all files + status, prompt user to choose
    - >1 active → report anomaly
→ Read → extract all verification items for the target level
```

Each item contains:
- Specific command
- Expected output

### 3. Execute Verification Items One by One

For each verification item in the layer:

1. Execute the verification command (long-running commands like training use `run_in_background=true`, then `TaskOutput` to wait for results)
2. Record actual output
3. Compare against expected, determine pass/fail
4. **Do not ask the user to manually execute any command** — complete all verification autonomously

**Pass determination hard standard**:
- Function completes expected task and returns **meaningful results**
- Returning empty array/empty string without error ≠ pass
- "No exception thrown" ≠ pass

### 4. Handle Failures

When a test fails:
1. Analyze error cause, autonomously fix the bug → re-run all tests for the current layer
2. Same approach fails consecutively twice → enter diagnostic mode
3. After fixing code, record the fix in autoworker:checkpoint (don't just record test results — also record what code was changed)

### 5. Output Summary

When all pass:

```
L<N> tests passed:
- <item 1>: <actual output summary> PASS
- <item 2>: <actual output summary> PASS
→ Invoking autoworker:checkpoint
```

### 6. Chain: Immediately Invoke autoworker:checkpoint

**After outputting the summary, immediately invoke `autoworker:checkpoint`. Do not wait for user instructions, do nothing else.**

## Key Constraints

- **Only run one layer**: Don't jump to the next layer — autoworker:dispatch decides the next step
- **Don't record results to file**: autoworker:checkpoint handles record-keeping
- **Skipped layers won't be called**: dispatch already treats skipped layers as complete when reading
- **Don't return to user mid-way**: Unless hitting a genuine blocker requiring human decision

## Important Notes

- **Every item in the verification plan must be executed**: Cannot ad-hoc decide "this one doesn't need testing"
- **L4 is mandatory**: Cannot skip L4 after L2 passes
- **Chaining is mandatory**: Must invoke autoworker:checkpoint after completion, cannot skip or manually substitute
