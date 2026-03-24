---
name: subtask-update
description: |
  Update subtask with fixes or new steps. Two trigger modes:
  (A) Auto-called by autoworker:gate-check on FAIL — reads FAIL info, adds supplementary steps.
  (B) User calls with a finding/bug during testing — diagnoses, fixes, updates subtask.
  Both modes end by invoking autoworker:dispatch to re-enter the loop.
---

# autoworker:subtask-update — Supplement/Correct Subtask Plan

**Two trigger modes**:
- **Mode A**: Automatically called after `autoworker:gate-check` FAIL (no arguments)
- **Mode B**: User calls manually with a finding/bug description

Both modes ultimately return to the `autoworker:dispatch` loop.

## Mode Determination

```
Has user-provided argument?
  ├─ Yes → Mode B (user feedback)
  └─ No  → Mode A (gate-check FAIL)
```

---

## Mode A: Auto-Called After gate-check FAIL

### A1. Read gate-check FAIL Information

Extract from conversation context the autoworker:gate-check FAIL output:
- Which self-check items didn't pass
- Which change points have confidence < 95%
- What's specifically missing (untested tests, unverified links, uncovered files, etc.)

### A2. Design Supplementary Steps

For each failed item, design specific supplementary steps:
- What code/scripts to write (e.g., test scripts, verification scripts)
- What operations to execute (e.g., restart service, run end-to-end test)
- What the expected result is

### A3. Update subtask → jump to "Common Steps: Update subtask + Chain"

---

## Mode B: User Feedback Trigger

### B1. Understand User Feedback

Extract the problem found by user from the argument. Examples:
- "Tags have no spaces between them" → tag input has a bug in the publish feature
- "deleteNote click does nothing" → DOM selector may have broken
- "Received note list format is wrong" → tool return format issue

### B2. Read Current Subtask + Locate Context

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
- Current Phase/Step progress
- Which tests have passed
- Related reference file list
```

### B3. Diagnose the Problem

**Follow Debug methodology** (2 failures → diagnose, don't retry):

1. **Make assumptions explicit**: "I assume the root cause is [X], because [evidence]"
2. **Read related code**: Based on subtask reference files + user description, locate likely problematic files
3. **Minimum observable unit**: Screenshots, logs, scripts, etc. — narrow down to specific code line
4. **Confirm root cause before acting**

### B4. Design Fix Steps

Based on diagnosis results, design specific fix steps:
- Which functions in which files need modification
- What the modification logic is
- How to verify the fix works

### B5. Update subtask → jump to "Common Steps: Update subtask + Chain"

---

## Common Steps: Update Subtask + Chain

### C1. Update Subtask

Edit subtask.md:

**Append new Phase in "Plan" section**:
```markdown
### Phase N+1: <source label>

Source label format:
- Mode A: `Supplementary verification (gate-check FAIL fix)`
- Mode B: `Bug fix (user feedback: <problem summary>)`

- [ ] <specific step 1>
- [ ] <specific step 2>
```

**Append corresponding verification items in "Verification Plan" section** (if existing items don't cover the new changes):
```markdown
### Supplementary Verification
- <specific verification command> → <expected result>
```

**Append new changed files to "Verification Coverage Table"** (if modifying files outside the original plan).

**Append to "Progress Log" section**:
```markdown
- <date>: <source> — <specific content>
```

### C2. Chain: Immediately Invoke autoworker:dispatch

**After updating subtask, immediately invoke `autoworker:dispatch`. Do not wait for user instructions, do nothing else.**

## Important Notes

- **Supplementary steps must be specific and executable**: Cannot write "add tests" — must write "write script to verify deleteNote function complete flow"
- **Don't repeat already-passed steps**: Only supplement missing parts
- **Mode B must diagnose before acting**: User says "tags have no spaces" — cannot guess the cause and change code directly, must first use logs/screenshots to confirm
- **Mode B fixes must update coverage table**: Out-of-plan file changes also need verification coverage
- **Chaining is mandatory**: Must invoke autoworker:dispatch after completion
