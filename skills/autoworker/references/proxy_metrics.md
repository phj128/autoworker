# Proxy Metrics — Design Principles & Examples

> **Core rules are in the main autoworker SKILL.md**.
> This file provides **detailed metric design principles, scenario examples, and evaluation script workflows**.

---

## Core Workflow

```
User reports qualitative issue (Claude cannot directly perceive)
  -> 1. Design proxy metrics (confirm reasonableness with user)
  -> 2. Write evaluation script (one command produces results, reused throughout iteration)
  -> 3. Compute baseline on existing data
  -> 4. After each change, auto-compute -> compare to baseline -> decide next step
  -> 5. Only notify user when subjective judgment needed (e.g., "is this good enough?")
```

## Metric Design Principles

| Principle | Description | Counter-Example |
|-----------|-------------|-----------------|
| **Auto-computable** | Calculate directly from existing output data, no human observation needed | "Watch the video and judge if naturalness improved" |
| **Monotonically correlated** | Metric improvement <-> problem improvement | Using training loss to measure visual quality |
| **Discriminative** | Large numerical difference between good/bad results | Good and bad both fall in 0.98-0.99 range |
| **Multi-angle complementary** | Single metric can be one-sided; use 2-3 for cross-validation | Only looking at mean, ignoring distribution/time-segments/extremes |

## Key Output — Evaluation Script

Once metrics are determined, immediately write a reusable evaluation script (one command produces comparison results). After each change, auto-run the script to compare against baseline: significant improvement → keep stacking, no improvement → change strategy, degradation → rollback. Only notify user when uncertain about "good enough."

## Applicable Scenario Examples

| Qualitative Issue | Proxy Metric | Data Source |
|------------------|-------------|-------------|
| Animation jitter | Body jerk (3rd derivative), velocity reversal rate | Eval trajectory NPZ |
| Generated images blurry | FID / LPIPS | Generated vs reference images |
| API response slow | P50/P99 latency | Request logs |
| Text summary loses info | Key entity coverage rate | NER extraction → set comparison |
| UI layout broken | Element overlap area, viewport overflow ratio | DOM bbox calculation |
