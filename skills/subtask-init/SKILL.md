---
name: subtask-init
description: |
  Create subtask document (first half): user confirmation, goals, assumptions.
  Auto-runs assumption verification experiments and fills in results.
  Call after Gate 1.1 (user confirmation) is done, before writing any code.
---

# autoworker:subtask-init — Create Subtask First Half (Gate 1.3 Step A+B)

After Plan Mode discussion is complete and user has confirmed direction, invoke this skill to create the first half of subtask.md.

## Execution Flow

### 1. Determine Sequence Number

```
Glob `subtask_*.md` (current directory) + Glob `claude_docs/subtask/*.md` (archive)
→ Extract all sequence numbers → take max + 1
```

### 2. Extract Confirmation Record from Conversation Context

Review the conversation and extract:
- **Confirmation method**: AskUserQuestion / confirmed in plan discussion / explicit in user instruction
- **Key Q&A**: scope, completion criteria, constraints, preferences
- **Goal**: WHY + WHAT (1-3 sentences)
- **Success criteria**: specific measurable items
- **Acceptance criteria**: Extract quantifiable metrics from plan (metric name + measurement method + expected value/range + tolerance). When no quantitative metrics exist, explicitly write "No quantitative metrics, reason: <fill in>"

### 3. Identify Core Assumptions

Extract assumptions that depend on external systems from plan and conversation. Each assumption needs:
- Assumption description (I assume X because Y)
- Verification experiment (one-line command)

**Pure internal logic changes** (e.g., refactoring, documentation): Write one line `No external dependencies | — | —`.

### 4. Search for Reference Files

```
Glob/Grep search for related files → confirm paths and line numbers
```

**Do not guess line numbers** — must Read to confirm.

### 5. Extract Design Decisions and Plan

Extract from plan file / conversation:
- Design decisions (decision point + choice + reason)
- Implementation plan (Phase/Step structure)

### 5.5. Pause Old Active Subtask

```
Glob `subtask_*.md` (exclude subtask_template.md) →
  For each file grep `status: active` →
    Edit all found to `status: paused`
```

**Purpose**: Ensure at most 1 active subtask at any time. Creating a new subtask automatically pauses old ones.

### 6. Write Subtask First Half

**Language rule**: subtask.md is an internal work document. Write it in the **user's conversation language** (as configured in their CLAUDE.md or inferred from their messages). Do NOT use the task's target language — e.g., if the task is "translate to English", the subtask itself should still be in the user's language.

Reference the table structure in subtask template, Write file:

```
subtask_<sequence>_<name>_<date>.md
```

**First line after title: write `status: active`** (flush left, grep-friendly format).

Include these sections (result columns left empty):
- User confirmation record
- task_plan positioning (extract corresponding Phase from plan file, position in overall plan, impact after completion. Write "No task_plan, skip" when none exists)
- Goal + success criteria
- Acceptance criteria table (extract from plan, or write "No quantitative metrics, reason: <fill in>")
- Core assumptions table (**result column left empty**)
- Design decisions
- Plan
- Reference files
- Verification plan (left empty, filled by autoworker:subtask-plan)
- Test results (left empty, filled by autoworker:checkpoint)
- Confidence assessment (left empty, filled by autoworker:gate-check)
- Gate 3 self-check (left empty, filled by autoworker:gate-check)
- Progress log
- Findings / Conclusions

### 7. Run Assumption Verification (Critical Step)

**Line by line**, read the "verification experiment" column of the assumptions table:
1. Execute the command
2. Observe the output
3. **Edit** subtask to fill in actual results

**Hard rules**:
- Result column must come from command execution output, **cannot be filled by reasoning**
- "—" (no verification needed) must be because there truly are no external dependencies, not laziness
- Verification failure → stop, report to user, do not continue

### 8. Output

```
Subtask first half created: subtask_<sequence>_<name>.md
- Assumption verification: <N>/<N> passed
- Acceptance criteria: <N> (or "No quantitative metrics")
- Paused old subtask: <list paused filenames, or "None">
→ Automatically invoking autoworker:subtask-plan
```

### 9. Chain: Immediately Invoke autoworker:subtask-plan

**After outputting the summary above, immediately invoke `autoworker:subtask-plan`. Do not wait for user instructions, do nothing else.**

## Important Notes

- **Cannot Write entire file then Edit results**: Write must leave result column empty; only Edit to fill after verification
- **Assumption verification is a blocking step**: Any verification failure → entire flow pauses
- **Reference files must be confirmed**: Glob/Read to confirm paths and line numbers exist — cannot write "approximately line XX"
- **Chaining is mandatory**: Must invoke autoworker:subtask-plan after completion, cannot skip or manually substitute
