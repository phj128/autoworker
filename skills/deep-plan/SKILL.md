---
name: deep-plan
description: "Structured deep discussion for Plan Mode that asks clarifying questions about requirements, surfaces hidden assumptions, defines acceptance criteria, and identifies design trade-offs. Use when planning a feature, thinking through a task, discussing requirements before coding, or entering Plan Mode for any non-trivial task. Runs inside EnterPlanMode to ensure thorough questioning before writing a plan."
---

# autoworker:deep-plan — Structured Deep Discussion (Inside Plan Mode)

Invoke immediately after entering Plan Mode. Ensures discussion depth through 5 structured phases, producing a structured plan file for autoworker:subtask-init to extract from. Plan depth determines the quality ceiling of the entire execution chain.

## Execution Flow

### Phase 1: Motivation Exploration

**Goal**: Understand what problem the user truly needs to solve, rather than rushing to think about how.

**Pre-action**: Check if the project has a `task_plan.md`. If so, read the overall goals and phase list; subsequent questioning should address the relationship to the overall plan.

**Questioning approach** (use AskUserQuestion, 2-3 questions per round):

1. **Why do this?** Do not accept tautological answers like "because we need X". Probe to root causes at the business/experience/efficiency level.
2. **Relationship to overall goal?** (when task_plan exists) Which phase does this correspond to? Is it planned or ad-hoc? If ad-hoc, why is it higher priority than planned phases?
3. **What if we don't do it?** What's the worst consequence? Can we tolerate it? The lighter the consequence, the simpler the solution should be.
4. **Is this really needed?** Is there a simpler way (don't do it, do it manually, approach from a different angle)?

**Anti-patterns**:
- User says "add caching" → immediately designing cache solution → should first ask "why is it slow?"
- User says "refactor to X" → immediately designing X architecture → should first ask "what problem does refactoring solve?"
- User gives detailed solution → skip motivation and discuss implementation → the solution might be the user's guess, not optimal

**Depth gate**: Motivation expressible in 1-3 clear sentences (WHY + consequence of not doing it). Can't write it = don't understand it = keep asking.

---

### Phase 2: Assumption Challenge

**Goal**: Make implicit assumptions explicit and challenge each one.

**Steps**:

1. **List assumptions**: Extract all implicit premises from Phase 1 discussion
   - Technical assumptions (API available, data format stable, dependencies reliable...)
   - Requirement assumptions (user actually needs this, frequency is high enough, priority is correct...)
   - Environment assumptions (has GPU, network works, permissions sufficient...)

2. **Challenge each one** (AskUserQuestion):
   - "You assumed X — what happens if X doesn't hold?"
   - "Can this assumption be verified? With what command?"
   - "Is there anything you consider 'obviously true' but haven't actually confirmed?"

3. **Explore code** (Glob/Grep/Read):
   - When assumptions involve existing code, actually read the code to confirm — don't rely on memory

**Depth gate**: Each assumption either has a verification method (one-line command) or is flagged as risk ("cannot pre-verify, monitor during execution").

---

### Phase 3: Solution Derivation

**Goal**: Derive solution from motivation, not apply from experience.

**Steps**:

1. **Start from motivation**: What's the minimum-change solution to the problem confirmed in Phase 1?
2. **At least 1 alternative**: What are the trade-offs of different approaches?
3. **Use AskUserQuestion for user to choose**: Present solution comparison, let user decide based on trade-offs

**Solution review — four questions** (any unsatisfactory → redesign):

0. **Is the direction right?** Derived from problem essence, or pattern-matched from similar scenarios?
1. **Is the abstraction level right?** Does the caller naturally possess this capability, letting us do only structured operations?
2. **10x robustness**: Still robust if input diversity increases 10x? Can enumeration scale?
3. **Does a simpler solution exist?** Same effect, less code/assumptions?

**Depth gate**: User explicitly chose a solution + can articulate the reason.

---

### Phase 4: Acceptance Criteria

**Goal**: Define how to judge "done", giving the execution phase clear expectations.

**Steps** (AskUserQuestion):

1. **Categorized discussion**:
   - **Quantitative** (data precision, performance, coverage): specific values + tolerance
   - **Behavioral** (workflow changes, instruction files): "Scenario X → expected behavior Y"

2. **Every metric must have a measurement method**:
   - Quantitative: what command to test? Expected output?
   - Behavioral: how to simulate the scenario? How to observe behavior?

3. **Confirm completeness with user**:
   - "Besides these metrics, what other situation counts as 'not done'?"
   - "If all these metrics pass, will you accept it?"

**Depth gate**: Every metric can directly become an L4 test case (has input, has operation steps, has expected output).

**Standard for "discussed thoroughly"**: Goals, motivation, core assumptions, acceptance criteria all clear — during execution, when actual results deviate, you can logically analyze the cause rather than guess blindly.

---

### Phase 5: Plan Output

**Goal**: Consolidate Phase 1-4 discussion output into the plan file.

**95% confidence self-check**: If you write the plan now and the user accepts it, would they overturn it due to misunderstanding? No = ready to output. Yes = return to the relevant Phase and continue discussing.

**Plan file format** (fixed structure, autoworker:subtask-init extracts by section):

```markdown
# Plan: <task name>

## task_plan Positioning
Corresponds to Phase: <Phase number and name from task_plan.md, or "N/A" if no task_plan>
Position in overall plan: <dependencies, what completing this unlocks>

## Motivation
<1-3 sentences: WHY + consequence of not doing it>

## Core Assumptions
| Assumption | What if wrong | Verification method |
|-----------|---------------|-------------------|

## Design Decisions
| Decision point | Choice | Alternative | Reason for choice |
|---------------|--------|-------------|-------------------|

## Acceptance Criteria
| Metric | Type | Measurement (command) | Expected value/range | Tolerance |
|--------|------|----------------------|---------------------|-----------|

## Implementation Plan

### Phase 1: <phase name>
- ...

### Phase 2: ...

## Verification
L1: <specific items>
L2: <specific items>
L3: <specific items>
L4: <specific items>

## Files Involved
| # | File | Change type |
|---|------|------------|
```

**Write**: Write the above content to the plan file (path specified in Plan Mode system message).

**Output**:

```
Plan complete:
- Motivation: <one sentence>
- Assumptions: <N> (<M> have verification methods)
- Solution: <chosen solution> (compared <K> alternatives)
- Acceptance criteria: <N> (quantitative <X> / behavioral <Y>)
- Phases: <N>
→ ExitPlanMode
```

Then immediately call `ExitPlanMode`.

## Key Constraints

- **Each Phase has a depth gate**: Can't pass = don't proceed to next Phase, return to current one
- **Don't skip Phases**: Even if the user gave very detailed requirements, still go through each (Phase 1-2 may be quick, but can't skip)
- **Questioning is not adversarial**: The goal is to help the user think clearly, not to grill them. But "I agree with everything you said" is not good discussion
- **Use AskUserQuestion**: Don't self-answer in your output — actually ask the user
- **Explore code**: For assumptions/solutions involving existing code in Phase 2-3, use Glob/Grep/Read to actually confirm

## Forbidden

- Using assumptions instead of questions ("I assume you want X" → should ask "X or Y?")
- Outputting a complete solution in the first round
- Moving to Phase 5 after only one round of questions
- Phase 4 writing "no quantitative metrics" without behavioral metrics as substitute (at minimum, have behavioral metrics)
