---
name: subtask-plan
description: |
  Complete subtask verification plan: upstream traceability table + L1-L4 test plan + self-check.
  Call after autoworker:subtask-init. Makes subtask ready for code implementation.
---

# autoworker:subtask-plan — Complete Verification Plan (Gate 1.3 Step C+D+E)

Invoked after autoworker:subtask-init completes. Fills in upstream traceability table, L1-L4 verification plan, and solution self-check.

## Execution Flow

### 1. Locate and Check Subtask

```
Glob `subtask_*.md` (exclude subtask_template.md) →
  0 found → stop, prompt to create subtask
  1 found → use directly (backward compatible)
  multiple → grep `status:` to filter:
    - Files without status field treated as active (backward compatible)
    - Exactly 1 active → use it
    - 0 active → list all files + status, prompt user to choose
    - >1 active → report anomaly
→ Read → check first-half completeness
```

**Pre-checks**:
- Assumptions table "Result" column has empty rows → **FAIL**, prompt to complete autoworker:subtask-init first
- User confirmation record is empty → **FAIL**
- Goal/success criteria is empty → **FAIL**

### 2. Fill In Upstream Verification Traceability Table

**Source**: Read plan file (if exists) + review conversation for user's verification/testing requirements.

Edit subtask's "Upstream Verification Traceability" table:

| Upstream text (copy verbatim) | Subtask item | Delta rationale |
|------------------------------|--------------|-----------------|

**Rules**:
- **Copy verbatim** from upstream text — not summarize (the act of copying forces you to see what upstream required)
- When no upstream requirements exist, write one line: `No upstream requirements | Self-designed | —`
- Subsequent L1-L4 are not allowed to be lower than the traceability table; downgrades must state delta rationale

### 2.5. Silent Failure Analysis

Read the subtask's "Acceptance Criteria" table, for each metric ask:

> If this metric deviates, which L1-L4 layer would catch it?

- Metric has no corresponding test → add in subsequent L2-L4
- All metrics have corresponding tests → continue

**Purpose**: Prevent acceptance criteria defined in the plan but not covered by the verification plan (silent failure).

### 3. Write L1-L4 Verification Plan

Cross-reference the traceability table, Edit subtask to fill in each layer's verification plan:

**L1 Build**:
- Specific build/check commands → expected output

**L2 Unit** (can skip but state reason):
- Specific function calls + expected input/output

**L3 Chain** (can skip but state reason):
- Commands feeding downstream with actual upstream output

**L4 End-to-End** (mandatory):
- Complete steps simulating actual user operation path
- Operation table: # | Action | Expected result | Actual result (leave empty)

**Verification coverage table**:
| Modified file | Change content | Corresponding verification item |
Each file planned for modification must have a corresponding verification item.

**Constraints**:
- Cannot be lower than upstream requirements in the traceability table. Downgrades must be explicitly noted in the delta rationale column
- Each metric in the acceptance criteria table must have at least one corresponding test in L2-L4

### 4. Acceptance Criteria Coverage Check

Build metric-to-test mapping table:

| Acceptance metric | Corresponding test item (which L, which item) | Coverage status |
|------------------|-----------------------------------------------|----------------|

- Uncovered metrics found → return to Step 3 and add corresponding tests
- All covered → continue

### 5. Solution Self-Check (Four Questions)

Answer each one (any unsatisfactory → report the issue, do not continue):

0. **Is the direction right?** Derived from problem essence, or pattern-matched from similar scenarios?
1. **Is the abstraction level right?** Does the caller naturally possess this capability?
2. **10x robustness**: Still robust if input diversity increases 10x?
3. **Does a simpler solution exist?** Same effect, less code/assumptions?

Edit self-check results into subtask's progress log.

### 6. Output

```
Subtask ready: subtask_<sequence>_<name>.md
- Traceability: <N> upstream requirements aligned
- Verification plan: L1 done, L2 <done/skip>, L3 <done/skip>, L4 done
- Coverage: <N>/<N> files have verification items
- Acceptance criteria coverage: <N>/<N> metrics have corresponding tests
- Self-check: 4/4 passed
→ Automatically invoking autoworker:dispatch
```

### 7. Chain: Immediately Invoke autoworker:dispatch

**After outputting the summary above, immediately invoke `autoworker:dispatch`. Do not wait for user instructions, do nothing else.**

## Important Notes

- **Traceability table is an anti-downgrade mechanism**: Skipping the traceability table and writing L1-L4 directly = may miss upstream requirements
- **L4 is mandatory**: End-to-end verification cannot be skipped — it's the ultimate safeguard for the user path
- **Complete coverage**: Uncovered modified files → add verification items before continuing
- **Chaining is mandatory**: Must invoke autoworker:dispatch after completion, cannot skip or manually substitute
