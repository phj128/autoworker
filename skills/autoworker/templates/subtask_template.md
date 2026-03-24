# Subtask: <task-name> — <one-line description>

Status: <active/paused/completed>

> **Structure reference**: This file defines subtask section structure and table formats.
> Auto-filled by `autoworker:subtask-init` and `autoworker:subtask-plan`. No need to manually Read this template.
> `<fill-in>` marks required fields.

---

## User Confirmation Record (Gate 1.1 Output)

**Confirmation method**: <AskUserQuestion / user specified in instructions / confirmed during plan discussion>

| Question | User Answer |
|----------|------------|
| Which Phase to complete this time? | <fill-in> |
| What are the completion criteria? | <fill-in> |
| <other key questions> | <fill-in> |

---

## task_plan Positioning

> When no task_plan.md exists, write "No task_plan, skipped" for this entire section.
> After subtask completion, sync-docs updates task_plan.md based on this analysis.

**Corresponding Phase**: <fill-in: Phase number and name from task_plan.md, e.g., "Phase 2: Data Preprocessing">
**Position in overall plan**: <fill-in: prerequisites (which phases completed), what this subtask unlocks>
**Impact on task_plan after completion**: <fill-in: which phases can be checked off, whether follow-up steps need adjustment>

---

## Goal

<fill-in: 1-3 sentences, including WHY (motivation) and WHAT (deliverable)>

### Success Criteria

- [ ] <fill-in: specific measurable completion criterion 1>
- [ ] <fill-in: specific measurable completion criterion 2>

> Self-check: Can each criterion be verified with a command/observation? "Code is written" is NOT a success criterion. "pnpm build passes + message received" IS.

### Acceptance Criteria

| Metric | Measurement (command) | Expected Value/Range | Tolerance |
|--------|----------------------|---------------------|-----------|
| <fill-in> | <fill-in> | <fill-in> | <fill-in> |

> Self-check: Is each metric derived from the goal? "Format correct" is just baseline — what else could silently fail?
> When no quantitative metrics exist, explicitly write: "No quantitative metrics. Reason: <fill-in>"

---

## Core Assumptions

| Assumption (I assume X because Y) | Verification Experiment (one-line command) | Result |
|------------------------------------|------------------------------------------|--------|
| <fill-in> | <fill-in> | <filled by autoworker:subtask-init after running verification> |

> For pure internal logic changes, write: "No external dependencies | — | —"

---

## Design Decisions

| Decision Point | Choice | Rationale (why not alternatives) |
|---------------|--------|--------------------------------|
| <fill-in> | <fill-in> | <fill-in> |

> Self-check: Is the direction derived from the problem's nature, or pattern-matched from experience? Is there a simpler solution?

---

## Plan

### Phase 1: <phase-name>

- [ ] Step 1.1: <specific change>
  - Files: `<path>`
  - Verification: <how to confirm this step is correct>
- [ ] Step 1.2: ...

### Phase 2: ...

> Self-check: Does every Step have a verification method? Are inter-step dependencies clear?

---

## Reference Files

| File Path:Line | What to Reference (specific function/type/pattern) |
|---------------|---------------------------------------------------|
| <fill-in> | <fill-in> |

> Self-check: Is there an existing implementation of similar functionality? Is the style consistent?

---

## Verification Plan

### Upstream Verification Traceability

> When a plan / user instruction exists, copy each verification/testing requirement verbatim into the table below.
> Subsequent L1-L4 must not be weaker than this table. Downgrade must be justified in the "Delta Rationale" column.
> When no upstream requirements exist, write: "No upstream requirements | Self-designed | —"

| Upstream Requirement (verbatim from plan/user instruction) | Subtask Item | Delta Rationale (write "—" if none) |
|-----------------------------------------------------------|-------------|-------------------------------------|
| <copy> | <L-level item> | <—> |

### L1 Build

- [ ] <specific command> → Expected: <what output means pass>

### L2 Unit

- [ ] <specific command + expected input/output> → Expected: <values/behavior>

> Reason for skipping L2: <fill-in, or delete this line if not skipping>

### L3 Chain

- [ ] <command feeding real upstream output to downstream> → Expected: <data passes correctly>

> Reason for skipping L3: <fill-in, or delete this line if not skipping>

### L4 End-to-End (Required)

- [ ] <command simulating actual user operation path> → Expected: <final effect>

| # | Action | Expected Result | Actual Result |
|---|--------|----------------|---------------|
| 1 | <fill-in> | <fill-in> | <fill after execution> |

> Self-check: Does the L4 operation path = actual user usage path? Any skipped steps?

### Verification Coverage

| Modified File | Change Description | Corresponding Verification Item |
|--------------|-------------------|-------------------------------|
| <fill-in> | <fill-in> | <L-level item number> |

> Self-check: Does every modified file have a corresponding verification item? If not → add one.

---

## Test Results (Gate 2 — after completing each layer, call autoworker:checkpoint to sync)

### L1
(Filled by autoworker:checkpoint)

### L2
(Filled by autoworker:checkpoint)

### L3
(Filled by autoworker:checkpoint)

### L4
(Filled by autoworker:checkpoint)

---

## Confidence Assessment (Filled by autoworker:gate-check)

| Change Point | Test Layer | Confidence | Verification Method (specific command + what was observed) | Unverified / Risk |
|-------------|-----------|------------|----------------------------------------------------------|-------------------|
| (Filled by autoworker:gate-check) | | | | |

### < 95% Supplementary Verification

| Change Point | Supplementary Verification Command | Execution Result | Updated Confidence |
|-------------|-------------------|-----------------|-------------------|
| (Filled by autoworker:gate-check) | | | |

---

## Gate 3 Self-Check (autoworker:gate-check checks each item and writes evidence)

- [ ] **Verification depth**: Test results section has L2+ records
  - Evidence:
- [ ] **L4 = user path**: L4 operation path = actual user usage path
  - Evidence:
- [ ] **Supplementary verification complete**: All < 95% items have supplementary verification executed
  - Evidence:
- [ ] **Instruction file tested**: Changed SKILL.md/CLAUDE.md has actual trigger verification
  - Evidence:
- [ ] **Coverage complete**: Every modified file has a corresponding verification item
  - Evidence:

---

## Progress Log

### <date>

**Phase X completed/in-progress**

<Brief description of changes and key findings>

---

## Findings / Conclusions (Fill after completion)

### Change Summary

| File | Change Type | Description |
|------|-----------|-------------|
| <fill-in> | new/modified/deleted | <fill-in> |

### Key Findings

- **<finding title>**: <observation -> cause -> applicability>

### Failed Attempts (record when valuable)

1. <approach> -> failure reason -> lesson learned
