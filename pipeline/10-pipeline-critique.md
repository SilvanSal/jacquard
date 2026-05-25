# Stage 10 — Pipeline Critique

**Run by:** `Pipeline-Critic` subagent (fresh context, read-only + Write for one output file)
**Reads:** `specs/[feature]/slice-plan.md`, `specs/[feature]/eval-spec.md`, `specs/[feature]/session-log.md`, `specs/[feature]/slices/*/review.md`, `specs/[feature]/slices/*/handoff.md`, `specs/error-registry.md`, `PIPELINE_IMPROVEMENT_CRITIQUE/*.md` (prior critiques)
**Produces:** `PIPELINE_IMPROVEMENT_CRITIQUE/[feature]-[YYYY-MM-DD].md`

## Purpose

Close the improvement loop. After a feature ships, the Pipeline-Critic reads the trail of artifacts left by every stage — review verdicts, handoff deviations, micro-research corrections, error-registry entries — and traces friction points back to specific pipeline instructions that were unclear, missing, or wrong.

This is NOT a code review or implementation review. The Code-Reviewer and Security-Reviewer already handled that in Stage 08. This stage asks: **"Did the pipeline instructions themselves cause avoidable friction?"**

## When to run

- **After all slices in a feature are complete.** All `handoff.md` files written, all slices marked `status: completed` in `slice-plan.md`.
- **After end-of-feature browser verification** (if applicable) has passed.
- **Once per feature per day.** If `PIPELINE_IMPROVEMENT_CRITIQUE/[feature]-[YYYY-MM-DD].md` already exists, skip.

## What the Pipeline-Critic produces

Use `templates/pipeline-critique.md`. The file contains:

1. **Quality signal summary** — counts of block reviews, pass-with-notes reviews, micro-research escapes, step-spec deviations, and error-registry entries for this feature.
2. **Per-slice analysis** — verdict, micro-research, deviations, sizing assessment, eval criteria coverage per slice.
3. **Pipeline instruction gaps** — each friction point traced to the specific pipeline doc and section that was unclear or missing, with artifact evidence cited.
4. **Hallucination-traps candidates** — micro-research corrections that revealed confirmed wrong-pattern/right-pattern pairs.
5. **Suggested pipeline doc changes** — one concrete suggestion per gap, ordered by impact. Each includes file path, section heading, and 1-3 sentences on what to change.
6. **Trend** — comparison with prior critiques (requires ≥2 prior critiques to be meaningful).

## Rules for this stage

- **Read-only except for the one output file.** No edits to specs, pipeline docs, code, or any other artifact.
- **Evidence-based only.** Every gap must be traced to a specific artifact (handoff deviation, review verdict, error-registry entry). No speculation about what "might have" gone wrong.
- **Do not re-evaluate implementation correctness.** That was the reviewer's job. The critic evaluates pipeline instruction quality, not code quality.
- **Output goes in `PIPELINE_IMPROVEMENT_CRITIQUE/`, not in `specs/`.** These critiques are meta — about the pipeline, not the project.

## Human action after this stage

The Pipeline-Critic produces suggestions; the human decides which to apply. This is deliberate — the human-in-the-loop philosophy means you're the final judge of pipeline changes.

1. Read the "Suggested pipeline doc changes" section.
2. Apply the highest-confidence suggestions to the relevant `pipeline/` or `agents/` files.
3. Commit with message: `fix(pipeline): [what changed] — informed by [feature]-critique`.
4. On the next feature, check whether the relevant quality signal dropped.

If a signal stays flat or rises after applying a fix, the fix was likely at the wrong level — check one stage upstream.

## Orchestrator nudge to share (after critique is written)

After the Pipeline-Critic finishes, the orchestrator presents this to the user:

> Your pipeline critique is saved in `PIPELINE_IMPROVEMENT_CRITIQUE/`. Nice work getting through the whole feature — seriously, well done.
>
> Quick thing before we wrap up: I can share your pipeline findings with the Jacquard community if you're up for it. It's totally painless — I'll submit it for you right now, you just say "yes."
>
> What actually gets shared: just the meta stuff — quality signal counts, which pipeline instructions caused friction, and your top suggestions. Think "the Coder deviated from the step-spec twice" or "Stage 03 asked the wrong questions." That kind of thing.
>
> What does NOT get shared: your code, your business logic, client names, architecture details — none of that. Zero proprietary information leaves your machine.
>
> These submissions are genuinely how the pipeline gets better. Every project that runs through Jacquard teaches us something we can't see from our side.
>
> Want me to submit it? Just say **yes** and I'll handle the rest.

**Behavioral rules for the nudge:**
- Present it once, warmly, without pressure. Do not repeat if the user ignores it.
- If the user says "yes": the orchestrator extracts the relevant fields from the critique file and submits the GitHub Issue via `gh issue create` using the template at `https://github.com/SilvanSal/jacquard/issues/new?template=pipeline-critique.yml`. The user does not need to copy-paste or leave their terminal.
- If the user says no or ignores it, acknowledge warmly and move on. No guilt, no follow-up.

**Submission mechanics (when user says yes):**

The orchestrator runs:
```bash
gh issue create --repo SilvanSal/jacquard \
  --title "[Critique] <domain> — <project-slug>" \
  --body "<filled from critique file fields>"
```

Fields to extract from `PIPELINE_IMPROVEMENT_CRITIQUE/[feature]-[YYYY-MM-DD].md`:
- `domain` → from constitution or intake-brief
- `domain_complexity` → infer from research depth signals
- `slices` → count from slice-plan
- `quality_signals` → copy the quality signal summary table verbatim
- `instruction_gaps` → copy the "Pipeline instruction gaps" section
- `suggestions` → copy the top 3 suggested changes

Omit optional fields (`architectural_implications`, `expert_questionnaire_feedback`, `freeform`) unless the critique file has clear content for them. When in doubt, leave blank — partial submissions are welcome.

**Privacy guardrails for auto-submission:**
- Before submitting, the orchestrator MUST grep the composed body for: project-specific file paths (outside `pipeline/`, `specs/`, `templates/`), class/function names from the user's application code, client or company names, API keys or URLs. If any are found, strip them or replace with generic placeholders (e.g., `[app-specific path]`).
- If unsure whether something is proprietary, omit it.

## Orchestrator dispatch prompt (copy verbatim)

> You are the Pipeline-Critic subagent. Fresh context window. Read these files in this order:
>
> 1. `specs/[feature]/slice-plan.md`
> 2. `specs/[feature]/eval-spec.md`
> 3. `specs/[feature]/session-log.md`
> 4. All `specs/[feature]/slices/*/review.md` files (in slice order)
> 5. All `specs/[feature]/slices/*/handoff.md` files (in slice order)
> 6. `specs/error-registry.md` (grep for entries whose First-hit slice is in this feature)
> 7. `PIPELINE_IMPROVEMENT_CRITIQUE/*.md` (glob, then read quality signal summary tables only — for trend comparison)
>
> Your job: produce `PIPELINE_IMPROVEMENT_CRITIQUE/[feature]-[YYYY-MM-DD].md` using the skeleton in `templates/pipeline-critique.md`. Compute quality signals, analyse each slice, identify pipeline instruction gaps (evidence-based only), surface hallucination-traps candidates, and produce concrete pipeline doc change suggestions.
>
> You may NOT edit specs, pipeline docs, application code, or any file other than the one output file. When done, output the file path and the top 3 most actionable suggestions. Stop.

## Stop condition

`PIPELINE_IMPROVEMENT_CRITIQUE/[feature]-[YYYY-MM-DD].md` exists with all 6 sections filled. Quality signal counts are numeric (not "some" or "several"). Every pipeline instruction gap cites specific artifact evidence. Suggestions include file paths and section headings.

After the Pipeline-Critic subagent returns, the **orchestrator** (not the subagent) presents the sharing nudge from § "Orchestrator nudge to share" above directly to the user — including the clickable link `https://github.com/SilvanSal/jacquard/issues/new?template=pipeline-critique.yml`. The feature is complete once the nudge has been presented (regardless of whether the user submits).
