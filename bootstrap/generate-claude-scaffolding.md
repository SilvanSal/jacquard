# Bootstrap — Generate `.claude/` Scaffolding

**Run by:** Orchestrator, ONCE per target project, after stage 02 (Codebase Discovery) has produced the triad.
**Reads:** `claude-md-template/`, `pipeline/*.md`, `templates/*.md`, the target project's existing state.
**Produces:** a `.claude/` directory in the target project root with subagents, settings, and hook scripts.

## Purpose

Turn the playbook (these files) into *target-project-native* Claude Code scaffolding, so subsequent sessions in the target project don't need to re-read this pipeline directory. Each subagent role becomes an `.claude/agents/` entry. Each gate becomes a hook.

## What to produce in the target project

```
<target-project>/
├── CLAUDE.md                        # already written in stage 02
├── tech-stack.md                    # already written in stage 02
├── code-style.md                    # already written in stage 02
├── best-practices.md                # already written in stage 02
├── specs/                           # already written / will be written by stages 03+
│   └── ...
└── .claude/
    ├── settings.json                # permissions + hooks
    ├── agents/
    │   ├── intake-reader.md
    │   ├── domain-researcher.md
    │   ├── codebase-explorer.md
    │   ├── architect.md
    │   ├── phase-planner.md
    │   ├── slice-planner.md
    │   ├── step-researcher.md
    │   ├── coder.md
    │   ├── code-reviewer.md
    │   ├── security-reviewer.md
    │   ├── browser-verifier.md
    │   ├── handoff-writer.md
    │   └── pipeline-critic.md
    ├── hooks/
    │   ├── require-step-spec.sh     # PreToolUse: block Write/Edit outside specs/ without a step-spec
    │   ├── require-plan.sh          # PreToolUse: block Write if no slice-plan.md exists
    │   ├── no-bypass-hooks.sh       # PreToolUse: block --no-verify / --no-gpg-sign
    │   ├── restrict-reads.sh        # PreToolUse: enforce per-agent read-lists per current stage marker
    │   └── stop-after-handoff.sh    # Stop: remind session to end after handoff.md is written
    └── .state/
        └── current-stage            # single-line marker: orchestrator writes this before each subagent dispatch
```

## Agents are pre-authored — copy, don't distill

Subagent definitions live at `agents/[name].md`. **Copy them into `.claude/agents/` in the target project.** Do NOT re-derive them from `pipeline/*.md` — the pre-authored versions are the source of truth and are designed to stay consistent across projects.

### Agents to copy (13)
```
agents/intake-reader.md
agents/domain-researcher.md
agents/codebase-explorer.md
agents/architect.md
agents/phase-planner.md
agents/slice-planner.md
agents/step-researcher.md
agents/coder.md
agents/code-reviewer.md
agents/security-reviewer.md
agents/browser-verifier.md
agents/handoff-writer.md
agents/pipeline-critic.md
```

### Per-project substitutions
The pre-authored files are almost project-agnostic. Only these tokens vary and must be substituted during copy:

| Token | Substitute with | Source |
|---|---|---|
| `[feature]` / `[N]` / `[ID]` / `[SHAs]` / `[URL]` | runtime values | left as literal in the agent; the orchestrator fills them at dispatch time |
| `tools: ... Bash` in `coder.md` / `code-reviewer.md` / `security-reviewer.md` / `handoff-writer.md` | scoped Bash allowlist | `tech-stack.md` |

**Do not narrow tool lists beyond the pinned tech-stack.** If `tech-stack.md` pins `pytest`, add `Bash(pytest*)`; if it doesn't, omit.

### Model overrides
Default is `sonnet` for most agents. `architect` and `slice-planner` are pinned to `opus` — they make structural decisions that downstream stages cannot revisit cheaply. Keep reviewers on `sonnet` — parallel dispatch benefits from faster, cheaper runs.

### Constraints that must survive the copy
- **All reviewers are read-only.** No Write/Edit in `tools:`.
- **Browser-Verifier runs end-of-feature only, never per slice.** The skill description and agent description already say this — do not edit it out.
- **Coder gets path-scoped Write/Edit/Bash via `settings.json`**, not via narrowed `tools:` in its frontmatter.
- **Handoff-Writer's `Write` is scoped to `specs/**/handoff.md`** via `settings.json` (the agent file lists Write generally; `settings.json` scopes it).

## `.claude/settings.json`

```json
{
  "permissions": {
    "defaultMode": "default",
    "allow": [
      "Read(**)",
      "Grep(**)",
      "Glob(**)",
      "WebSearch",
      "WebFetch",
      "Bash(git status)",
      "Bash(git diff*)",
      "Bash(git log*)",
      "Bash(git add*)",
      "Bash(git commit*)",
      "Write(specs/**)",
      "Write(.claude/**)",
      "Edit(specs/**)"
    ],
    "ask": [
      "Write(src/**)",
      "Edit(src/**)",
      "Bash(npm*)",
      "Bash(pnpm*)",
      "Bash(pytest*)",
      "Bash(cargo*)"
    ],
    "deny": [
      "Bash(rm -rf*)",
      "Bash(git push --force*)",
      "Bash(git reset --hard*)",
      "Bash(*--no-verify*)",
      "Bash(*--no-gpg-sign*)",
      "Write(.env*)",
      "Edit(.env*)"
    ]
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          { "type": "command", "command": ".claude/hooks/require-step-spec.sh" },
          { "type": "command", "command": ".claude/hooks/require-plan.sh" }
        ]
      },
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": ".claude/hooks/no-bypass-hooks.sh" }
        ]
      },
      {
        "matcher": "Read",
        "hooks": [
          { "type": "command", "command": ".claude/hooks/restrict-reads.sh" }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          { "type": "command", "command": ".claude/hooks/stop-after-handoff.sh" }
        ]
      }
    ]
  }
}
```

Replace the `Bash(npm*)` / `Bash(pytest*)` / etc. lines with whatever test/build tool `tech-stack.md` pins for this project. Delete the ones that don't apply. Don't leave unused entries — the ask list is load-bearing (every entry is an extra permission prompt otherwise).

## Hook scripts

### `.claude/hooks/require-step-spec.sh`

Blocks Write/Edit on application code when no `step-spec.md` for an active slice exists. Allows all writes inside `specs/`, `.claude/`, and the triad files themselves.

```bash
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
```

### `.claude/hooks/require-plan.sh`

Blocks Write on application code when no `slice-plan.md` exists for any feature.

```bash
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
    permissionDecisionReason: "No slice-plan.md exists. Run the plan-slices skill before writing application code."
  }
}'
```

### `.claude/hooks/no-bypass-hooks.sh`

Blocks any Bash command that passes `--no-verify` / `--no-gpg-sign` / equivalent.

```bash
#!/usr/bin/env bash
set -euo pipefail

cmd=$(jq -r '.tool_input.command // empty' <<< "$CLAUDE_HOOK_INPUT")

if [[ "$cmd" == *"--no-verify"* || "$cmd" == *"--no-gpg-sign"* ]]; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Hook-bypass flags are not allowed. Fix the underlying issue."
    }
  }'
  exit 0
fi
```

### `.claude/hooks/restrict-reads.sh`

Enforces the load-bearing "must not read" rules from each agent's read-list (the `Does not read` sections in `agents/[name].md`). Blocks `Read` when the current stage's subagent has no business reading that path.

**Convention — stage marker:** before dispatching any subagent, the orchestrator writes a single line to `.claude/.state/current-stage` containing the subagent's role slug (e.g. `coder`, `step-researcher`, `architect`). The hook consults this marker; if it's missing or holds `orchestrator`, the hook is permissive (the orchestrator is allowed broad reads). The `00-START-HERE.md` hard rules require this write — missing markers surface as an orchestrator bug, not a permission bug.

```bash
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
    # Also forbid other slices' step-spec / knowledge / handoff — handled by the caller
    # via file_path pattern (if path contains "slices/" but NOT the active slice id,
    # the orchestrator has the active slice id in .claude/.state/active-slice; we
    # check that below).
    ;;
  step-researcher)
    deny_patterns="best-practices.md
code-style.md"
    ;;
  codebase-explorer|domain-researcher)
    deny_patterns="specs/research/domain.md"
    # Domain-Researcher ran first; Codebase-Explorer has no business rereading it.
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
```

**Orchestrator responsibilities:**
- Before each subagent dispatch, `Write(.claude/.state/current-stage)` with the agent's role slug.
- During slice execution, also `Write(.claude/.state/active-slice)` with the slice ID (e.g. `1`, `2a`) so the Coder deny rule can scope to the active slice.
- After a subagent returns, either leave the markers (next dispatch overwrites) or clear them back to `orchestrator`.

**What this does NOT enforce:** grep-only lookups (the matrix marks `grep` on some cells). Enforcing grep-only without a file-read would require a different hook keyed on tool name `Read` and target path — which this hook is. The subtlety: the matrix says Coder grep-only on `error-registry.md` and `hallucination-traps.md`, so a cover-to-cover `Read` of those files should be blocked too. Add to the Coder deny list if that discipline slips in practice; left out of the default to avoid false positives on small files.

### `.claude/hooks/stop-after-handoff.sh`

After a handoff is committed, reminds the orchestrator to auto-advance to the next slice or finalize the feature.

```bash
#!/usr/bin/env bash
# Reminder only; does not block. Emits a note if the latest commit touched a handoff.md.
latest_handoff=$(git log -1 --name-only --format='' 2>/dev/null | grep 'handoff\.md$' || true)
if [[ -n "$latest_handoff" ]]; then
  jq -n --arg path "$latest_handoff" '{
    systemMessage: ("Handoff committed: " + $path + ". Auto-advance: run drift check then dispatch stage 06 for the next slice, or stage 10 if this was the final slice.")
  }'
fi
```

## Rules for this bootstrap step

- **Run once per project.** If `.claude/` already exists in the target, do not overwrite. Instead, diff the existing files against the expected structure and surface mismatches to the user.
- **Copy pre-authored agents verbatim.** Do not distill or re-derive them from `pipeline/*.md`. The pre-authored versions in `agents/` are the source of truth.
- **Substitute only the documented tokens.** Bash allowlists from `tech-stack.md`; runtime tokens like `[feature]` / `[N]` stay literal (orchestrator fills them at dispatch).
- **Pin the tool allowlist to this project's actual tech stack.** Read `tech-stack.md` to decide which `Bash(xxx*)` entries to include.
- **Do not write into `specs/`.** Specs are the output of stages 03+, not of bootstrap.
- **After scaffolding is generated, stop.** The orchestrator does not immediately proceed to stage 03. The bootstrapped `.claude/` must be loaded by the current session's context before stage 03 can proceed — this is the one exception where the orchestrator pauses for the user to start a fresh session so the new `.claude/` hooks and settings take effect.

## Orchestrator dispatch prompt (this stage)

> You are the Bootstrap subagent. Read `tech-stack.md` from the target project root (it must exist — if not, stop and report that stage 02 is incomplete).
>
> Your job:
> 1. Copy every file under the pipeline's `agents/` to `.claude/agents/` in the target project.
> 2. Substitute per-project tokens per the "Per-project substitutions" table in `bootstrap/generate-claude-scaffolding.md` (only Bash allowlists vary — everything else stays verbatim).
> 3. Write `.claude/settings.json` and `.claude/hooks/*.sh` per the templates in this file. Create an empty `.claude/.state/` directory (markers are created on demand by the orchestrator, not at bootstrap).
> 4. Pin Bash allowlist entries in `settings.json` to match `tech-stack.md`. Delete unused entries — do not leave placeholders. Make all hook scripts executable (`chmod +x`).
>
> Do NOT re-derive agents from `pipeline/*.md`. The `agents/` directory is the source of truth.
>
> When done, output the file tree under `.claude/` and a note that the user should start a fresh session so the new `.claude/` hooks and settings take effect before stage 03. Stop.

## Stop condition

`.claude/` exists in the target project with settings.json, all 13 agent files, **5 hook scripts (executable)**, a `.state/` directory, and a final message to the user to start a fresh session so the bootstrapped `.claude/` is active for stage 03.
