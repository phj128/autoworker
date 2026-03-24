#!/bin/bash
# state-recover.sh — SessionStart hook for autoworker plugin
# Fires after /clear. Reminds about potentially lost discussion context.
#
# Core insight: Disk files (subtask, progress) survive /clear — autoworker:dispatch
# can detect and resume from those. This hook addresses the OTHER problem:
# discussion conclusions that were only in conversation context, now gone.

echo ""
echo "⚠️ [autoworker] /clear detected — conversation context has been wiped."
echo ""
echo "   Things that survive /clear (on disk):"
echo "   - subtask_*.md, progress.md, findings.md, task_plan.md, plan files"
echo "   → Call autoworker:dispatch to detect and resume from these."
echo ""
echo "   Things that may have been LOST (were only in conversation):"
echo "   - Discussion conclusions not yet written to plan/subtask"
echo "   - Scope decisions, assumption analysis, design choices"
echo "   - User preferences or corrections from this session"
echo ""
echo "   If you recall discussing something not yet in files,"
echo "   ask the user to re-state it — do NOT guess from memory."
echo ""
