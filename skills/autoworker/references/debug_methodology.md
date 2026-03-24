# Debug Methodology — Examples & Reference

> **Core rule is in the main autoworker SKILL.md Gate 2.4** (2 failures → 3-step diagnosis → write findings.md).
> This file provides **observation methods table, diagnostic examples** for reference during debugging.

---

## Observation Methods Table (Lookup by Scenario)

Break failing complex operations into minimal steps. After each step, observe the actual state (not the assumed state).

| Scenario | Observation Method |
|----------|-------------------|
| Terminal interactive UI | tmux capture-pane (capture after each keystroke) |
| API call chain | console.log / print each intermediate result |
| Training not converging | Print per-step loss / grad / data samples |
| Config not taking effect | Print actual loaded values (not loaded? or overridden?) |
| Multi-process / pipeline | Each process writes to separate log file |
| File I/O | Verify file exists + content correct after each write |
| Network requests | Log request/response headers + body |

**Key principle**: Observation must show "what actually happened" — not "no error was raised so it must be fine." Many bugs are silent (silent failures, empty returns, wrong branch taken).

## Diagnostic Tool Construction

Extract the failing step and write a minimal reproducible standalone test. Do not repeatedly run within the full system — feedback cycles are too long with too many confounding factors.

## Self-Check List (After Each Debug Failure)

> "Is this failure the same root cause as last time? If yes → diagnose, don't retry."
> "Can I write 'I assume X because Y'? If not → I'm guessing blindly."
> "Did I observe actual state after each step? If not → add observation first."
