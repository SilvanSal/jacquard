#!/usr/bin/env bash
set -euo pipefail

path=$(jq -r '.tool_input.file_path // empty' <<< "$CLAUDE_HOOK_INPUT")
stage_file=".claude/.state/current-stage"

# Orchestrator's own reads — permissive (the matrix applies to subagents).
[[ ! -f "$stage_file" ]] && exit 0
stage=$(tr -d '[:space:]' < "$stage_file")
[[ -z "$stage" || "$stage" == "orchestrator" ]] && exit 0

# Deny-map: stage-slug → one forbidden path pattern per line.
# Encodes the load-bearing "MUST NOT read" rules from each agent's read-list (agents/[name].md).
# Patterns are literal substrings against the Read file_path.
deny_patterns=""
case "$stage" in
  coder)
    deny_patterns="specs/research/domain.md
specs/constitution.md"
    ;;
  step-researcher)
    deny_patterns="best-practices.md
code-style.md"
    ;;
  codebase-explorer|domain-researcher)
    deny_patterns="specs/research/domain.md"
    ;;
  code-reviewer|security-reviewer|handoff-writer)
    deny_patterns="specs/research/domain.md"
    ;;
esac

# Active-slice scope for the Coder — forbid reading other slices' specs.
if [[ "$stage" == "coder" && -f ".claude/.state/active-slice" ]]; then
  active=$(tr -d '[:space:]' < .claude/.state/active-slice)
  if [[ -n "$active" && "$path" == *"slices/"* && "$path" != *"slices/$active/"* ]]; then
    # Exception: the prior slice's handoff.md is explicitly allowed for the Coder.
    if [[ "$path" != *"/handoff.md" ]]; then
      jq -n --arg p "$path" --arg a "$active" '{
        hookSpecificOutput: {
          hookEventName: "PreToolUse",
          permissionDecision: "deny",
          permissionDecisionReason: ("Coder may only read slice " + $a + "; requested " + $p + ". Read only the prior slice'\''s handoff.md.")
        }
      }'
      exit 0
    fi
  fi
fi

if [[ -n "$deny_patterns" ]]; then
  while IFS= read -r pattern; do
    [[ -z "$pattern" ]] && continue
    if [[ "$path" == *"$pattern"* ]]; then
      jq -n --arg p "$path" --arg s "$stage" --arg x "$pattern" '{
        hookSpecificOutput: {
          hookEventName: "PreToolUse",
          permissionDecision: "deny",
          permissionDecisionReason: ("Agent " + $s + " is not permitted to Read " + $p + " (matches denied pattern " + $x + " from its read-list). If you need this, the playbook says raise to the orchestrator — it usually means the handoff or step-spec is insufficient.")
        }
      }'
      exit 0
    fi
  done <<< "$deny_patterns"
fi

exit 0
