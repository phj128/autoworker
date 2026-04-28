---
name: gate-check
description: "Final quality gate and pre-completion verification before reporting task completion. Use when all tests are complete and the task needs a final quality check, task completion verification, or pre-delivery review. Fills confidence assessment, runs supplementary verification for items below 95% confidence, completes a self-check checklist, and writes PASS/FAIL result to subtask.md before calling autoworker:dispatch for routing."
---

# autoworker:gate-check — Pre-Completion Self-Check (Gate 3)

**Trigger**: Called by autoworker:dispatch when all tests are complete. **Pure assessment skill — does not make routing decisions.**

## Execution Flow

### 1. Pre-Check

```
Glob `subtask_*.md` (exclude subtask_template.md) →
  0 found → stop, prompt to create subtask
  1 found → use directly (backward compatible)
  multiple → grep `status:` to filter:
    - Files without status field treated as active (backward compatible)
    - Exactly 1 active → use it
    - 0 active → list all files + status, prompt user to choose
    - >1 active → report anomaly
→ Read → check "Test Results" section
```

- Test results section is empty → **FAIL**, prompt to complete tests and call `autoworker:checkpoint` first
- Has test results → continue

### 1.5. Acceptance Criteria Traceability

Read subtask's "Acceptance Criteria" table, check whether each metric was measured in L1-L4 test results:

- Metric not measured → that change point's confidence < 95% (Step 3 will trigger supplementary verification)
- All metrics have corresponding test results → continue
- No acceptance criteria table (legacy subtask format) → skip this step

### 2. Fill Confidence Assessment Table

In subtask.md's "Confidence Assessment" section, fill in for each change point:

| Change point | Test level | Confidence | Verification method | Unverified/Risk |
|-------------|-----------|------------|-------------------|-----------------|

Confidence inference basis:
- Has L4 pass + meaningful output → 95%+
- Has L2 but no L4 → 70-85%
- Only L1 → 50-70%
- Untested → 30%

### 3. Supplementary Verification for < 95% Items

When the table above has < 95% items:
1. Design supplementary verification commands (specific, executable)
2. **Execute immediately**
3. Fill in results
4. Update confidence

Record in subtask.md's "< 95% Supplementary Verification" table.

**Boundary for "requires user confirmation"** — only scenarios depending on human senses qualify:
- Programmatically verifiable (API responses, config validity, selector changes) → execute verification autonomously, NOT "requires user confirmation"
- UI appearance, interaction feel → legitimate "requires user confirmation"

When all items are >= 95%, write "All >= 95%, no supplementary verification needed".

### 4. Gate 3 Self-Check Checklist

In subtask.md's "Gate 3 Self-Check" section, check each item and provide evidence:

- [ ] **Verification depth**: Test results section has L2+ records
  - Evidence: <state which is the highest layer reached>
- [ ] **L4 = user path**: L4 operation path = actual user usage path
  - Evidence: <state what L4 did, compare with how user would use it>
- [ ] **Supplementary verification complete**: All < 95% items had supplementary verification executed
  - Evidence: <how many items supplemented, or "all >= 95%">
- [ ] **Instruction file tested**: If SKILL.md / config files were changed, they were actually trigger-tested
  - Evidence: <how verified, or "no instruction files changed">
- [ ] **Coverage complete**: Every modified file has a corresponding verification item
  - Evidence: <how many files changed, how many verified>

**Can't write evidence = didn't do it = can't check the box = FAIL**.

### 5. Chain Integrity Check

Answer each question (any No → FAIL):

1. **Is the chain fully traced?** From config/code change → to user-perceivable effect, is there a verification point at every link?
2. **Any "should be fine" links?** Anything you feel "obviously works" but haven't actually run?
3. **Does verification path = user path?** Is your verification method consistent with how users actually use it?

### 6. Write Result and Invoke autoworker:dispatch

**PASS (all self-checks pass + all >= 95%)**:

Edit subtask.md:
1. Append `Gate result: PASS` at the end of "Progress Log" section
2. Change `status: active` to `status: completed` (if status field exists)

Output:
```
Gate 3 PASS
- Confidence: all >= 95%
- Self-check: 5/5 passed
- Chain: complete
→ Invoking autoworker:dispatch
```

**FAIL loop limit**: If already consecutively FAIL 2 times (check "Progress Log" for `Gate result: FAIL` count), on the 3rd FAIL, do not invoke autoworker:subtask-update. Instead output a complete failure report to the user and let them decide next steps.

**FAIL (any self-check fails or has < 95% that can't be self-resolved)**:

Edit subtask.md, append at end of "Progress Log" section:

```
Gate result: FAIL
```

Output:
```
Gate 3 FAIL
- Failed items: <specifics>
- Needs additional work: <specifics>
→ Invoking autoworker:dispatch
```

**Both cases always invoke `autoworker:dispatch`. No routing decisions — autoworker:dispatch reads Gate result and decides next step.**

### 7. Chain: Immediately Invoke autoworker:dispatch

**After outputting the result, immediately invoke `autoworker:dispatch`. Do not wait for user instructions, do nothing else.**

## Important Notes

- **gate-check is pure assessment**: Only assesses + writes results, does not make routing decisions
- **Evidence is a hard constraint**: Each self-check item must have traceable evidence — "I think it's fine" doesn't count
- **Gate result format is fixed**: Must be `Gate result: PASS` or `Gate result: FAIL` — autoworker:dispatch reads this exact format
- **Don't ask user "should I supplement?"**: Autonomously executable supplementary verification goes directly through autoworker:dispatch → autoworker:subtask-update loop
