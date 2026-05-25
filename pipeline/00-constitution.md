# Stage 00 — Constitution

**Run by:** Orchestrator (no subagent; short enough to stay in main context)
**Reads:** the user's initial project brief (verbal description, requirements doc, or prompt)
**Produces:** `specs/constitution.md` in the target project

## Purpose

Pin down the non-negotiable rules for this project before any research or design. The constitution is short, load-bearing, and referenced by almost every downstream stage. It is NOT a requirements document. It does not describe features.

## What goes in the constitution

Copy `templates/constitution.md` into `specs/constitution.md` and fill in:

1. **Project identity** — one paragraph. What the app is. Who the user is. What it is NOT (scope exclusions).
2. **Human profile** — who is operating the pipeline and who (if anyone) is the domain expert. Ask the user:
   - Are you the domain expert, or is there a separate person with deep domain knowledge?
   - If separate: will that person be available during the pipeline (inline), or do we need to gather their input asynchronously via questionnaires?
   - If async: roughly how much time can the expert give, and across how many rounds?
   This determines how Stage 01 (domain research) and Stage 03 (clarify) behave. See `templates/constitution.md` § "Human profile" for the field definitions.
3. **Non-negotiables** — 3 to 7 rules that cannot be traded off during design or execution. Examples: "all user data encrypted at rest", "works offline", "no external paid APIs", "accessible to screen readers". Be specific. "High quality" is not a non-negotiable.
4. **Integration context** — the app rarely exists in a vacuum. Ask the user:
   - What systems, files, or APIs feed data into this app? (upstream sources)
   - What reads the app's output? (downstream consumers)
   - Are there specific data formats the app must ingest or produce? (HL7, IFC, CSV schemas, PDF reports, etc.)
   - Does the app need to coexist with existing systems it cannot modify? (legacy DBs, company SSO, shared infrastructure)
   - Where will it run? (cloud, on-prem, local machine, offline-capable)
   If the user says "standalone / greenfield / not sure yet," record that explicitly. The Architect and Domain-Researcher both need to know whether integration constraints exist.
5. **Tech-stack locks** — only if the user has already committed to specific tech. If they haven't, leave this section empty; stage 02 will write it.
6. **Compliance / legal constraints** — GDPR, HIPAA, license compatibility, data residency. Empty is OK if none apply.
7. **Non-goals** — explicit anti-features. "We are NOT building multi-tenant." "We do NOT support IE11."

## Gates

- **Stop and ask the user** for any of the above that can't be inferred from the brief. Use the A/B/C/D numbered-options format from stage 03 for anything with 3+ reasonable choices.
- **Do not proceed to stage 01 until the constitution is committed** to the target project's repo with a message like `chore: project constitution`.

## Pipeline invariants carried into every constitution

These are not project-specific choices — they're non-negotiables of the pipeline itself. The orchestrator copies them into `specs/constitution.md` so downstream stages see them without having to re-read this playbook.

1. **Research before code.** No `Write`/`Edit` on application code before the stages 01–05 artifacts are committed.
2. **Fresh context per stage.** Every stage runs in a new subagent with a narrow read-list.
3. **Sub-agent nesting cap: depth ≤ 1.** A pipeline-stage subagent (Coder, Architect, Step-Researcher, etc.) may spawn **at most one** level of further subagents, and only a general-purpose `Explore` agent for read-only lookups. Forbidden: a Coder spawning an Architect; a Step-Researcher spawning a Coder; any two-deep chain (`stage-agent → spawn → spawn`). Rationale: open-claude-code caps nesting at depth 3 runtime-side; this pipeline is stricter because its stages already carry fresh-context isolation — deeper nesting is almost always a sign the stage is wrong, not that the task needs more agents. Violating this wastes tokens on re-reading context that the calling stage already holds.
4. **Sub-agent return = final artifact path + one-paragraph delta, not a running commentary.** The parent only sees the child's final text, not its tool trace. If the parent needs detail, it comes from the committed artifact, not from the child's transcript.
5. **Commit between stages, auto-advance.** Each stage commits before returning. The orchestrator auto-advances to the next stage — no manual intervention required except at human gates.

The Architect and Slice-Planner do not get to trade these off. The constitution may add project-specific rules on top; it may not weaken these.

## Rules for this stage

- Constitution fits on two screens. If it's longer, you're writing requirements. Stop.
- No feature list. No user stories. No architecture. Those come later.
- Every rule in "Non-negotiables" must be testable or auditable. A rule nobody can check is noise.
- If you cannot fill a section honestly, write `_TBD — to be revisited at stage 04_` and move on. Do not invent.

## Stop condition

File `specs/constitution.md` exists in the target repo, committed, and contains at minimum: project identity, non-negotiables, and non-goals. Tech-stack-locks and compliance may be deferred.
