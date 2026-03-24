# Autoworker

**An auto-loop execution workflow with quality gates for Claude Code.**

Give Claude a task. Autoworker decomposes it, implements code, runs tests, and iterates through quality gates — autonomously looping until the job is done right.

> The problem: Claude often claims "done" before truly verifying. It skips tests, forgets edge cases, and moves on. Autoworker fixes this by enforcing a state machine that **won't let Claude say "done" until it actually passes quality checks**.

## Why Autoworker?

Without Autoworker, Claude Code:
- Says "done" after writing code but before testing it
- Skips verification steps when it "feels confident"
- Loses all context on `/clear` with no recovery
- Has no mechanism to catch its own mistakes

With Autoworker:
- **Enforced execution chain** — every step must complete before the next begins
- **4-layer testing** — from syntax checks to end-to-end user path verification
- **Quality gates** — acceptance criteria are traced, confidence is assessed, gaps trigger re-work
- **Anti-loss protection** — discussion conclusions are persisted; `/clear` won't erase progress
- **Self-iteration loop** — fails the gate? Automatically adds fix steps and retries

## Installation

```bash
# Add the marketplace
/plugin marketplace add phj128/autoworker

# Install the plugin
/plugin install autoworker@autoworker
```

## Quick Start

### Option A: Plan first, then execute (recommended for complex tasks)

```
You: I need to add authentication to my Express app

Claude: [enters Plan Mode]
→ /autoworker triggers autoworker:deep-plan
→ 5-phase structured discussion (motivation, assumptions, design, acceptance criteria, plan)
→ Produces a plan file

You: /clear

Claude: [sees plan, enters execution]
→ autoworker:subtask-init → autoworker:subtask-plan → autoworker:dispatch
→ Autonomous loop until gate-check PASS
```

### Option B: Direct execution (for well-defined tasks)

```
You: /autoworker
     Add a retry mechanism to the API client with exponential backoff

Claude: → Creates subtask → Builds verification plan → Implements → Tests → Gates → Done
```

## How It Works

### The Execution Loop

Autoworker runs as a **state machine**. Each skill reads the current state, does its job, and hands off to the next. No step can be skipped.

```
                    ┌─────────────────────────────────────┐
                    │                                     │
  subtask-init ──→ subtask-plan ──→ dispatch ──→ code ──→ checkpoint ──┐
                                      ↑                               │
                                      │         ┌────────────────────┘
                                      │         ↓
                                      ├──── dispatch ──→ test ──→ checkpoint
                                      │         ↓
                                      │    gate-check
                                      │      ↓     ↓
                                      │    FAIL   PASS ──→ done ✅
                                      │      ↓
                                      └── subtask-update
```

### What Each Skill Does

| Skill | Role | What happens |
|-------|------|-------------|
| **deep-plan** | Planning | 5-phase structured discussion: motivation → assumptions → design → acceptance criteria → plan output |
| **subtask-init** | Setup | Creates subtask document with goals, assumptions (verified by running commands), and acceptance criteria |
| **subtask-plan** | Verification design | Builds L1-L4 test plan, traces each acceptance criterion to a test, checks coverage |
| **dispatch** | Router | Reads subtask checkboxes, routes to the right next step. The only routing point — prevents skipping |
| **code** | Implementation | Implements one phase of code, following the subtask plan step by step |
| **test** | Verification | Executes one test layer (L1/L2/L3/L4), records actual output vs expected |
| **checkpoint** | Record keeping | Checks off completed phases, writes test results to subtask |
| **gate-check** | Quality gate | Traces every acceptance criterion to test results, assesses confidence, triggers re-work if < 95% |
| **subtask-update** | Fix & retry | When gate-check fails, adds remediation steps and feeds back into the loop |
| **sync-docs** | Documentation | Syncs progress, findings, and archives completed work |

### Testing: 4 Progressive Layers

| Layer | Verifies | Example | Required? |
|-------|----------|---------|-----------|
| **L1 Build** | Code compiles/parses | `pnpm build`, `bash -n *.sh` | Yes |
| **L2 Unit** | Individual function logic | Specific function call + expected output | Optional (with justification) |
| **L3 Chain** | Multi-module data flow | Feed real upstream output to downstream | Optional (with justification) |
| **L4 End-to-End** | Complete user path | Simulate actual user operations | **Always required** |

### Gate Check: How "Done" Is Verified

The gate-check doesn't just ask "does it work?" — it:

1. **Traces acceptance criteria** — every metric defined in planning must have a corresponding test result
2. **Assesses confidence** — each change area gets a confidence score based on test coverage
3. **Triggers supplementary verification** — anything below 95% confidence gets additional targeted tests
4. **Runs a 6-point self-check** — verification depth, user path match, review status, coverage completeness
5. **Cannot be faked** — "no evidence = not checked = FAIL"

## Anti-Loss Protection

Claude Code's `/clear` command wipes all conversation context. Autoworker protects against this:

### Prevention
- **Hard rule**: Autoworker will never suggest `/clear`. It trusts the 1M context auto-compression.
- **Real-time persistence**: Discussion conclusions are written to files as they happen, not saved up for the end.
- **Stop hook**: Every time Claude pauses, a reminder fires: "Are there unpersisted discussion conclusions?"

### Recovery
- **SessionStart hook**: After `/clear`, explicitly warns what survived (disk files) vs what may have been lost (conversation-only context).
- **State machine resume**: `autoworker:dispatch` reads subtask checkboxes from disk and picks up exactly where it left off.

## Core Principles

These rules are enforced throughout the execution chain:

- **"Tested" means executed** — `grep` confirming content exists ≠ tested. `bash -n` passing ≠ tested. Only actual command execution with observed output counts.
- **Minimum change** — only change what was asked for. No opportunistic refactoring.
- **No silent error swallowing** — every `catch` must have specific recovery logic.
- **2 failures → diagnose, don't retry** — if the same approach fails twice, stop and enter diagnostic mode.
- **No manual skill substitution** — you cannot "fill in the test results yourself" instead of running `autoworker:test`.

## File Structure

Autoworker creates and manages these files in your project:

```
your-project/
├── subtask_001_feature_name.md    # Active work document (created by subtask-init)
├── task_plan.md                    # Project-level plan (big picture)
├── progress.md                     # Progress tracking across subtasks
├── findings.md                     # Discoveries and counter-intuitive behaviors
└── claude_docs/
    └── subtask/                    # Archived completed subtasks
```

## Reference Documents

The plugin includes reference materials that Claude consults when needed:

| File | Used for |
|------|----------|
| `references/verification_system.md` | Examples of verification plans and assumption checks |
| `references/debug_methodology.md` | Diagnostic procedures when hitting repeated failures |
| `references/file_conventions.md` | File naming, archiving, and project structure conventions |
| `references/proxy_metrics.md` | Designing acceptance metrics and proxy indicators |
| `templates/subtask_template.md` | Full subtask document template with all sections |

## Requirements

- Claude Code (with plugin support)
- Works with any Claude model, optimized for Opus

## License

MIT
