#!/usr/bin/env bash
set -euo pipefail

path=$(jq -r '.tool_input.file_path // empty' <<< "$CLAUDE_HOOK_INPUT")

# Always allow writes inside specs/, .claude/, input/, or the triad root files.
case "$path" in
  specs/*|*/specs/*) exit 0 ;;
  .claude/*|*/.claude/*) exit 0 ;;
  input/*|*/input/*) exit 0 ;;
  */CLAUDE.md|*/tech-stack.md|*/code-style.md|*/best-practices.md|CLAUDE.md|tech-stack.md|code-style.md|best-practices.md) exit 0 ;;
esac

# Application-code writes require a step-spec for the ACTIVE slice — not just any step-spec
# that has ever existed. If the orchestrator has set the active-slice marker, require THAT
# slice's step-spec specifically; this closes the gap where one early step-spec latches the
# gate open for the rest of the project. If no marker is set, fall back to "any step-spec
# exists" so patch-track / legacy writes are not blocked.
active=""
[[ -f ".claude/.state/active-slice" ]] && active=$(tr -d '[:space:]' < .claude/.state/active-slice)

if [[ -n "$active" ]]; then
  ls specs/*/slices/"$active"/step-spec.md >/dev/null 2>&1 && exit 0
else
  ls specs/*/slices/*/step-spec.md >/dev/null 2>&1 && exit 0
fi

jq -n '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: "No step-spec.md for the active slice. Run plan-slices + research-step for this slice before writing application code."
  }
}'
