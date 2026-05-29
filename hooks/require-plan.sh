#!/usr/bin/env bash
set -euo pipefail

path=$(jq -r '.tool_input.file_path // empty' <<< "$CLAUDE_HOOK_INPUT")

case "$path" in
  specs/*|*/specs/*) exit 0 ;;
  .claude/*|*/.claude/*) exit 0 ;;
  input/*|*/input/*) exit 0 ;;
  */CLAUDE.md|*/tech-stack.md|*/code-style.md|*/best-practices.md|CLAUDE.md|tech-stack.md|code-style.md|best-practices.md) exit 0 ;;
esac

if ls specs/*/slice-plan.md >/dev/null 2>&1; then
  exit 0
fi

jq -n '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: "No slice-plan.md exists. Run the plan-slices stage before writing application code."
  }
}'
