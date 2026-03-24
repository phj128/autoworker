---
name: sync-docs
description: |
  Sync tracking documents based on current conversation results.
  Updates subtask, progress, findings, task_plan, project CLAUDE.md.
  Use when finishing a task or reaching a milestone.
argument-hint: "[archive|park]"
---

# autoworker:sync-docs — Sync Tracking Documents

Based on work results and discoveries in the current conversation, update all tracking documents.

## Input

Optional argument: $ARGUMENTS
- No argument: Sync only (check off items, record progress, add findings, audit claude_docs)
- `park`: Sync + pause current subtask (set `status: paused`) + clear plan file. For "task still in progress (e.g., training) but need to switch to something else"
- `archive`: Sync + archive completed subtask (move to claude_docs/subtask/) + clear plan file. For "task fully complete"

## Execution Flow

### 1. Scan Current State

Find tracking files and document system in the project root:

**Top-level tracking files**:
- `subtask_*.md` — current in-progress subtasks
- `progress.md` — progress log
- `findings.md` — core discoveries
- `task_plan.md` — task planning
- Project-level `CLAUDE.md` — project rules and technical info
- `README.md` — project intro (for humans)

**Progressive disclosure documents**:
- `claude_docs/reference/*.md` — detailed documents referenced from CLAUDE.md
- Subdirectory `CLAUDE.md` — index files for each module

Read each existing file to understand current recorded state.

### 2. Compare Against Conversation Content

Review work completed in this conversation, determine updates needed item by item:

| File | Update condition | Update content |
|------|-----------------|----------------|
| `subtask_*.md` | Steps were completed | Check off `[x]`, record progress, add verification results |
| `progress.md` | Task completed or progressed | Update task item status, add result summary |
| `findings.md` | New conclusions or counter-intuitive behaviors discovered | Add new section or update existing section |
| `task_plan.md` | Task completed/progressed, or plan changed | Read subtask's "task_plan positioning → corresponding Phase" field, locate and check off `[x]` in task_plan.md with completion timestamp; match by content when no positioning field; update future steps if plan changed |
| `CLAUDE.md` | Reusable patterns or lessons learned discovered | Add to appropriate section (don't duplicate existing content) |
| `claude_docs/reference/*.md` | Findings in this conversation belong to an existing reference topic | Update corresponding reference document |
| Subdirectory `CLAUDE.md` | Changed code structure/files in a module | Update corresponding subdirectory file index |
| `README.md` | Added feature or changed usage/installation | Sync update (user-perceivable changes) |

### 2.5. Reference Document Consistency Check

**Dead link check**: Scan project CLAUDE.md for all `claude_docs/reference/` references, confirm files exist:
- Referenced file exists → OK
- Referenced file doesn't exist → report dead link, suggest creating or fixing reference

**New reference identification**: If this conversation produced new lessons or technical documentation (> 20 lines) and CLAUDE.md already exceeds 300 lines, suggest writing to `claude_docs/reference/<topic>.md` and adding a trigger heading in CLAUDE.md, rather than appending directly to CLAUDE.md.

### 3. Execute Updates

For each file needing update:
- Read current content first
- Use Edit for precise updates (don't rewrite entire file)
- Briefly describe what changed after each update

### 3.5. claude_docs/ Subdirectory Recursive Audit

Using claude_docs/ progressive disclosure structure, check if this conversation's changes affect subdirectory documents:

**Flow**:
1. `Glob claude_docs/*/CLAUDE.md` → get all subdirectory indexes
2. Read each subdirectory CLAUDE.md (it's the semantic index listing files and purposes)
3. Compare against this conversation's changes:
   - Files in this subdirectory were modified? → update corresponding index entry
   - This subdirectory's topic was affected (e.g., new archived subtask, modified reference)? → update index
   - New files should be added to index? → add
   - Old files should be removed from index? → remove
4. Skip unaffected subdirectories — no need to update everything

### 4. park (only when argument includes "park")

Pause the current active subtask, clean up workspace, facilitate switching to next task. Subtask file stays in workspace (not archived) and can be resumed later.

1. Glob `subtask_*.md` → grep `status: active` → Edit to `status: paused`
2. Append pause reason in the paused subtask's progress log: `**Paused** — <infer reason from conversation, e.g., "waiting for training completion">`
3. Clear plan file (same logic as archive)
4. Record pause status in `progress.md`

### 5. archive (only when argument includes "archive")

**Status filter**:
1. Glob `subtask_*.md` (exclude subtask_template.md) → grep `status:` to filter
2. Only archive subtasks with `status: completed`
3. None completed → report "no completed subtask to archive", skip remaining steps
4. Mixed status → report which were archived, which retained (and why: active/paused/no status field)

**Execute archive** (for each completed subtask):
1. Determine sequence number: read `claude_docs/subtask/CLAUDE.md` to find max sequence + 1
2. Copy file: `subtask_<name>.md` → `claude_docs/subtask/<sequence>_<name>_<date>.md`
3. **Delete workspace original**: `rm subtask_<name>.md` (after archiving, don't keep in workspace — prevents dispatch from selecting it next time)
4. Update indexes:
   - `claude_docs/subtask/CLAUDE.md` archive list + Phase grouping
   - `progress.md` add archive link
5. **Clear plan file**: Glob `.claude/plans/*.md`, find current project's plan file, clear contents (write empty string). Archiving = task done — stale plan would interfere with next autoworker:deep-plan.

### 6. Project CLAUDE.md Health Check

Check project-level `CLAUDE.md` size and structure (if exists):

**Size check**:
- <= 300 lines → healthy
- 301-500 lines → getting large, suggest organizing
- > 500 lines → bloated, list content that can be migrated

**Bloat identification** (when > 300 lines):

Scan CLAUDE.md sections, identify migratable content by these rules:

| Pattern | Should migrate to | How to detect |
|---------|------------------|---------------|
| Experiment logs, hyperparameter comparison tables | `progress.md` | Contains epoch/loss/reward numeric tables |
| Bug fix history, lessons learned (> 20 lines) | `findings.md` or `claude_docs/reference/` | Detailed content > 20 lines |
| Detailed data pipeline documentation | `claude_docs/reference/data_pipeline.md` | Data formats, field descriptions, transformation flows |
| Detailed API/config documentation | `claude_docs/reference/<topic>.md` | Detailed config item lists or code templates |

**Output**:
- Healthy → report "CLAUDE.md: N lines, healthy"
- Bloated → list section line counts + migration suggestions (don't auto-migrate, just report)

### 7. Git Commit (only when argument includes "park" or "archive")

After park or archive completes, commit and push all changes to remote.

### 8. Output Summary

List all updated files and change highlights:

```
sync-docs complete:
- subtask_xxx.md: Steps 3-5 checked off, verification results added
- progress.md: Task X marked complete
- CLAUDE.md: Added "YYY" lesson
- [archive] → claude_docs/subtask/40_xxx_20260227.md
- CLAUDE.md health: N lines, healthy / getting large, suggest migrating X sections
```

## Important Notes

- **Don't fabricate content**: Only update based on what actually happened in the conversation — don't write uncertain things
- **CLAUDE.md updates should be cautious**: Only add verified, reusable patterns — not one-time details
- **Don't create non-existent files**: If the project doesn't have findings.md, don't create it (unless the conversation has clear new findings needing recording)
- **archive condition is `status: completed`**: Only subtasks with completed status (after gate-check PASS) get archived
