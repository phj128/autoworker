## Anti-Loss Protocol

**CRITICAL**: Context is lost on /clear. All progress must be persisted to files before any session interruption.

### Rules
1. **NEVER suggest /clear** or ending the session without first ensuring all progress is saved
2. **Before any interruption**, verify:
   - subtask file has all completed steps checked off
   - progress.md reflects current state
   - findings.md captures any discoveries
3. **Trust auto-compression**: The 1M context window has automatic compression. Do NOT interrupt the execution chain due to context concerns.
4. **If user requests /clear**: First run autoworker:sync-docs to persist all state, THEN allow /clear

### Recovery after /clear
When starting a new session after /clear:
1. Check for subtask_*.md files → if found, call autoworker:dispatch to resume
2. No subtask but user gives new task → call autoworker:subtask-init
3. Neither → normal conversation
