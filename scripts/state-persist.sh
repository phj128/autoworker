#!/bin/bash
# state-persist.sh — Stop hook for autoworker plugin
# Fires every time Claude stops.
#
# Core problem: /clear loses discussion conclusions that are only in context
# (not written to files). Disk files (subtask, progress) survive /clear fine.
# This hook reminds Claude to persist discussion results before session ends.

# Signal 1: Plan file exists but nearly empty (discussed but not written)
for pf in .claude/plans/*.md; do
  [ -f "$pf" ] || continue
  content=$(grep -cv '^$' "$pf" 2>/dev/null || echo "0")
  if [ "$content" -lt 5 ]; then
    echo ""
    echo "⚠️ [autoworker] Plan file exists but nearly empty: $pf"
    echo "   If you discussed a plan, write conclusions to this file before /clear."
  fi
done

# Signal 2: Active subtask with no entries for today
subtask_files=$(ls subtask_*.md 2>/dev/null | grep -v template)
if [ -n "$subtask_files" ]; then
  today=$(date '+%Y-%m-%d')
  for sf in $subtask_files; do
    has_today=$(grep -c "$today" "$sf" 2>/dev/null || echo "0")
    if [ "$has_today" -eq 0 ]; then
      echo ""
      echo "⚠️ [autoworker] Subtask ($sf) has no entries for today."
      echo "   If you made progress, update it before /clear."
    fi
  done
fi

# Generic reminder (always output — short and effective)
echo ""
echo "💡 [autoworker] If there are discussion conclusions not yet in files (plan decisions, scope changes, findings), persist them NOW."
