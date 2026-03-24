# File Conventions — Reference

> **Core rules are in the main autoworker SKILL.md** (file structure, task tracking, /clear recovery).
> This file provides **complete file tables, naming conventions, workflow details**.

---

## Root Directory Markdown Files (Common Pattern)

| File | Purpose | Git Tracked |
|------|---------|-------------|
| `CLAUDE.md` | Claude instructions, project rules, technical info | Yes |
| `README.md` | Project introduction (for humans) | Yes |
| `findings.md` | Key conclusions, concise summary | Yes |
| `progress.md` | Progress log, per-session records | Yes |
| `task_plan.md` | Task planning, phases and decisions | Yes |
| `subtask_*.md` | Development subtask workspace (with `Status:` field: active/paused/completed) | **Ignored** |

## Project CLAUDE.md Structure Guidelines (Target: 300 lines max)

Project CLAUDE.md loads every conversation. Too much content = token waste + key info buried.

**Progressive disclosure principle**: Keep headings in CLAUDE.md (triggers), detailed content in separate reference files (Read on demand).

**Must include** (needed every conversation):

| Section | Content | Target Lines |
|---------|---------|-------------|
| Project overview | One paragraph describing what the project is | 5-10 |
| Environment & commands | How to install, run, build | 30-50 |
| Architecture | Key directories/files and their purposes, module index | 50-80 |
| Project-specific rules | Coding standards, known constraints | 20-40 |
| Known pitfalls index | Title + one-liner + link to reference | As needed |

**Should NOT include** (move to appropriate location):

| Content | Move To | Reason |
|---------|---------|--------|
| Experiment logs, hyperparameter comparisons | `progress.md` | Temporal, not needed every time |
| Detailed bug fix history (> 20 lines) | `findings.md` or reference files | Keep heading in CLAUDE.md as trigger |
| Detailed technical docs (> 20 lines/section) | Reference files | Read on demand |

## Navigation Rules (CLAUDE.md First)

**Trigger**: Anytime you need to understand a directory's content, structure, or functionality.

**Core principle**: CLAUDE.md is a human-maintained semantic index with far higher information density than a Glob file listing. Read the index before searching — don't skip the index to brute-force scan.

**Required flow**:
1. **Check CLAUDE.md first**: Before exploring a directory, check if it has a `CLAUDE.md`
2. **Targeted search second**: After CLAUDE.md tells you "what exists" and "how it's organized", use Glob/Grep only for specific details not covered by the index
3. **Drill down layer by layer**: Root `CLAUDE.md` (structure tree + module index) → target subdirectory `CLAUDE.md` (file list + purposes) → specific file `Read`

## Subtask State Machine

| State | Meaning | Transition From | Trigger |
|-------|---------|----------------|---------|
| `active` | Currently executing subtask | Created by subtask-init | — |
| `paused` | Suspended by new subtask | subtask-init creates new, old active → paused | subtask-init |
| `completed` | gate-check PASS | active → completed | gate-check |

**Rules**:
- At most 1 active subtask at any time
- subtask-init automatically changes all `Status: active` to `Status: paused` when creating new subtask
- gate-check PASS changes `Status: active` to `Status: completed`
- sync-docs archive only archives `Status: completed` subtasks

## /clear Recovery Protocol

After re-entering a conversation, recover context in this order (< 30 seconds):

1. Read `subtask_*.md` (if exists) → understand current task, progress, next step
2. Read last few lines of `progress.md` → understand overall progress
3. Continue from the last checked-off position in subtask

If no subtask file → read `progress.md` + `task_plan.md` → ask user "what should we continue?"

## Testing Conventions

- Directory: `tests/`
- Naming: `test_<module_name>.py`

## Git Tracking

**Must git track and push**:

| File | Notes |
|------|-------|
| `CLAUDE.md` (project + subdirectory level) | Project rules, technical info, structure index |
| `progress.md` | Progress log |
| `findings.md` | Key findings and conclusions |
| `task_plan.md` | Task planning |

**Timing**: Commit + push after task archival. Workspace files (`subtask_*.md`) are gitignored.
