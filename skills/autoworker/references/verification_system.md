# Verification System — Examples & Methodology

> **Core rules are in the main autoworker SKILL.md** (Gate 1.2 assumption verification + solution review, Gate 2.1 test ladder, Gate 3 confidence table + violation patterns).
> This file provides **detailed examples, failure modes, and methodology expansions** for reference when filling in subtask verification plans.

---

## Counter-Intuitive Principle Examples

Changed one regex line → unit test string matching passed → build passed → told user "done" → never actually called the function end-to-end → user asks "did you do E2E verification?" → no. The danger of small changes isn't "high probability of error" — it's "feeling like verification isn't needed."

Commonly overlooked checkpoints:
- Interactive behavior in scripts (`read`) may not work in non-interactive environments

---

## Stage 0: Assumption Verification — Failure Cases

> Rule (inlined in main SKILL.md Gate 1.2): List core assumptions → one minimal experiment per assumption → confirm before writing code.

**Common failure modes**:
- Assumed URL parameter controls sorting → built full implementation → parameter deprecated in new SPA, complete rework needed
- Assumed DOM element has certain class → wrote selector → actual site uses CSS module hashed names
- Assumed API returns a certain field → wrote parsing logic → field name changed or nesting level differs

**Method**: List core assumptions → one minimal experiment per assumption (one-line command / one REPL call) → confirm before proceeding.

## Stage 1: Solution Review — Failure Cases

> Rule (inlined in main SKILL.md Gate 1.2): Is the direction right? Correct abstraction level? 10x robust? Simpler alternative?

**Common failure modes**:
- Built synonym mapping table for fuzzy matching (6/6 tests passed) → user says "can't enumerate all" → switched to LLM reading the list directly (0 lines of matching code, better results)
- Wrote specific handler branches for each error type → grew increasingly complex → stepping back revealed a single generic strategy covering all cases

## Stage 2: Implementation Verification — Failure Cases

> Rule (inlined in main SKILL.md Gate 2.1): L1→L2→L3→L4 progressive, pass each layer before advancing.

**Common failure modes**:
- All unit tests pass, but function A's output format doesn't match function B's expected input (encoding, field names, nesting)
- Tested with simplified URL, but real search result URLs have tracking parameters causing entirely different behavior
- Function returns empty array without error → marked as passed (empty = failure, should return data to count as success)
- Test environment differs from production (isolated script vs in-process, browser locks, env variable differences)

## Stage 3: Quality Audit — Additional Checkpoints

> Rule (inlined in main SKILL.md Gate 3): Confidence self-assessment table + chain integrity check.

Supplementary checks not fully covered by Gate 3:

1. **Garbled text check**: After Edit/Write of content, Grep output files for `\ufffd` (U+FFFD replacement character).
2. **Specific strategies for < 95% confidence remediation**:
   - Reduce parameters for quick verification (fewer steps, smaller intervals, data subsets)
   - Automated verification (scripts, curl, simulated input, screenshot checks)
   - Long-running but adjustable (e.g., train 500 steps → 20 steps + reduce vis_every)

---

## Verification Methodology (Detailed)

### 4.1 Decompose Before Verifying — Don't Run E2E All at Once

Break complex features into independently testable minimal units. Verify each individually, then combine. Arrange execution as: unit verification → combined verification → full run.

### 4.2 Layered Verification — Who Does What

| Layer | Executor | Content | Example |
|-------|----------|---------|---------|
| **L1 Build** | Claude | Compile/type check | `pnpm build` / `cargo check` |
| **L2 Log/Unit** | Claude | Service startup, module load, single function call | `grep "plugin"` / jiti script |
| **L3 Function/Chain** | Claude | API calls, chained data flow | `curl ...` / feed upstream output to downstream |
| **L4 End-to-End/UI** | User | Full user experience | Card styles, push notifications received |

Claude completes and checks L1-L3, then hands L4 to user only after all pass.

### 4.3 Verification Patterns by Change Type (Quick Reference)

| Change Type | Verification Method |
|-------------|-------------------|
| Code change | build + test + API call |
| Instruction files (CLAUDE.md/SKILL.md/prompts) | **Re-run affected workflows** + grep check output |
| Config change (json/env) | Restart service + log verification |
| Pure text/formatting | Read + grep check modified points |

**Four verification path principles**:
1. **Same-condition testing**: Use production config/environment for testing
2. **Create → Verify → Cleanup**: Test data must be cleaned up after verification
3. **Unit + Integration**: After isolated testing, run complete path in real system
4. **Chained data flow**: When multiple functions collaborate, feed downstream with **real upstream output**

### 4.4 Async Task Verification

| Estimated Duration | Mechanism | Notes |
|-------------------|-----------|-------|
| < 2 minutes | Synchronous | Wait for results directly |
| 2-10 minutes | `run_in_background=true` | Auto-notified on completion, use TaskOutput for results |
| > 10 minutes | `run_in_background=true` | Auto-notification + record task info in subtask.md for recovery |

### 4.5 Subtask Self-Check Table (Complete)

> Simplified version is inlined in main SKILL.md Gate 1.3. This is the full version with methodology references.

| Check Item | Methodology Ref | Failure Indicator |
|-----------|----------------|-------------------|
| Decomposed into independently testable units? | 4.1 | Verification plan has only one E2E step |
| Layered (L1→L2→L3→L4)? | 4.2 | No layers, or pushing Claude-automatable work to user |
| Each verification immediately executable? | 4.3 | Contains "observe next time", "verify later", "check at runtime" |
| Automated verification self-tracked? | — | Contains "you can use the following command to check" |
| Verification covers all modified files? | — | Changed 4 files but only verified 2 |
