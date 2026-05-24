# Stage 06 — Per-Step Research

**Run by:** `Step-Researcher` subagent (fresh context per step, read-only + WebSearch/WebFetch)
**Reads:** the current step-spec, `specs/[feature]/design.md` (relevant section only), `tech-stack.md`, `specs/constitution.md`, `specs/error-registry.md` (grep-only), `specs/research/hallucination-traps.md` (grep-only), plus targeted topic-level reads of prior slice `knowledge.md` files triggered by the dedup check below
**Produces:** `specs/[feature]/slices/[N]/knowledge.md` and `specs/[feature]/slices/[N]/step-spec.md`

## Purpose

Just-in-time research for exactly ONE slice. Fresh context window means the researcher isn't polluted by prior step output or slice planning history. Output is tight reference material the Coder will read when it writes code.

This stage does two things in one pass: **first draft the step-spec**, then **research what's needed to execute it**.

## Step-spec (produced first)

Use `templates/step-spec.md`. Contains:
- Slice ID (e.g., `S02`) and the user-visible outcome from `slice-plan.md` (copied verbatim)
- Concrete sub-tasks, ordered as **TDD Red-Green pairs**. Odd sub-tasks are RED (write failing tests); even sub-tasks are GREEN (write implementation to pass them). 3–10 sub-tasks typical (i.e. 2–5 pairs, plus optional standalone sub-tasks for non-testable work like config).
- Each RED sub-task names the eval criteria it covers and the test names from `eval-spec.md`.
- Each GREEN sub-task references which RED sub-task it satisfies.
- Sub-tasks with no testable behavior (config changes, pure file moves) get standalone entries, not pairs.
- **If the slice has non-deterministic eval criteria:** mark those RED sub-tasks as `(RED — eval)` and include the evaluator type, pass threshold, and sample size from the eval-spec. The orchestrator uses these markers to conditionally load `pipeline/07a-eval-harness.md` for the Coder. Also document the chosen eval framework in `knowledge.md` (see below).
- Files expected to be created or modified (best guess — the Coder may diverge, but this catches obvious mistakes).
- Eval criteria this step satisfies, copied from `eval-spec.md` by ID. Verbatim.
- Explicit out-of-scope list. "This step does NOT touch the payment module."

## Knowledge.md (produced second, after step-spec)

Use `templates/knowledge.md`. Contains:
- **Timestamp + tech-stack versions pinned at the top.** Non-negotiable.
- **API / library reference** — specific endpoints, function signatures, or config shapes the Coder will use. Copy-paste from canonical docs with source URLs. Prefer showing the exact call shape over summarizing.
- **Gotchas and footguns** — known issues with this library/pattern at this version. Cite StackOverflow / GitHub issue / changelog entries.
- **Minimal working example** — smallest code snippet that demonstrates the pattern. From official docs where possible.
- **Refresh policy** — when this knowledge should be re-verified (e.g., "on any version bump of library X"). Default: every 90 days.

## Precondition: pre-slice drift check (orchestrator, slices N ≥ 2)

Before dispatching the Step-Researcher, the orchestrator must have run the pre-slice drift check described in `00-START-HERE.md` § "Pre-slice drift check" and either found no drift or resolved drift via an explicit user decision (absorb / ignore / revert). If drift is unresolved, this stage does not start.

When the user chose **ignore**, the orchestrator must append a one-line "known drift" note to this slice's `knowledge.md` inputs (passed in the dispatch prompt) so the Step-Researcher knows a delta exists without re-classifying it.

## Dedup check (before writing new knowledge.md content)

The Step-Researcher's default is self-contained output. The dedup check is the narrow exception: if a topic is already covered verbatim in a prior artifact, reference it instead of re-researching. This exists because re-researching the same library three slices in a row burns tokens and drifts subtly each time.

**Protocol (runs once, at the start of drafting knowledge.md):**

1. For every external library / API / endpoint the step-spec sub-tasks will touch, build a short keyword list (library name + method/endpoint name).
2. For each keyword, `grep` across `specs/research/domain.md`, `specs/research/hallucination-traps.md`, `specs/error-registry.md`, and all existing `specs/[feature]/slices/*/knowledge.md` files. `grep`-only — do not open-and-read by default.
3. If a match exists:
   - Open that specific section (not the whole file). Check its timestamp: if older than 90 days or the pinned version differs from `tech-stack.md`, ignore the match and research fresh.
   - If current: add a "See also:" pointer to your slice's `knowledge.md` — `See also: specs/[feature]/slices/S02/knowledge.md § POST /x endpoint (verified 2026-03-01, requests==2.31.0)`. Copy the minimum shape into your file anyway if the Coder would otherwise need to open two files; prefer pointer-only for large blobs.
   - Record the reuse in your 5-bullet summary.
4. If no match: research fresh per the normal flow.

**Hard rules:**
- Dedup is topic-scoped, not read-the-whole-prior-file. The fresh-subagent invariant still holds — you do not pull prior step-spec, handoff, or design content through the dedup check.
- If a prior entry is stale (version drift or >90 days), DO NOT update the prior file. Research fresh for this slice and note the stale prior entry in the orchestrator handoff so it can be refreshed separately.
- Stop after one pass. Dedup is not a research rabbit hole — budget one round of greps, then draft.

## Hallucination-traps + error-registry surfacing

Independent of the dedup check, the Step-Researcher `grep`s `specs/research/hallucination-traps.md` and `specs/error-registry.md` for the library/API names this slice will touch. Any matching rows or entries get a one-line pointer in `knowledge.md` § "Gotchas and footguns":

- For hallucination-traps matches: `Trap — [trap name]. Use [correct pattern], not [wrong pattern]. Source: specs/research/hallucination-traps.md.`
- For error-registry matches (only if the error signature is still relevant at the pinned version): `Prior bug — [slug]. See specs/error-registry.md.`

The Step-Researcher does NOT edit either file. They are read-and-reference only at this stage.

## Rules for this stage

- **Step-Researcher does not read `best-practices.md` or `code-style.md`.** Those are for the Coder. The researcher's job is external knowledge, not in-repo conventions.
- **Every API claim has a URL.** If you cannot find a source for an API shape, write "unverified" next to it — do not omit the warning.
- **Pin versions explicitly.** `requests ==2.31.0`, not `requests`. If `tech-stack.md` doesn't pin, ask the orchestrator to update it.
- **Cap knowledge.md at ~500 lines.** If you need more, you're summarizing the whole library instead of the parts this step needs.
- **Do not write code beyond minimal examples from docs.** The Coder writes code.
- **Do not read prior steps' knowledge files cover-to-cover.** Each step's research is self-contained by default. The only exception is a targeted section read triggered by the dedup check above, and even then you pull the minimum needed or just leave a pointer.

## Orchestrator dispatch prompt (copy verbatim)

> You are the Step-Researcher subagent for slice `[ID]`. Fresh context. Read: `specs/[feature]/slice-plan.md` (for the slice definition), `specs/[feature]/design.md` (relevant section only), `tech-stack.md`, `specs/constitution.md`. Do NOT read `best-practices.md`, `code-style.md`, `specs/research/domain.md` cover-to-cover, or any prior slice's `knowledge.md` or `handoff.md` cover-to-cover.
>
> Before drafting `knowledge.md`, run the dedup check from `pipeline/06-research-step.md` § "Dedup check": for each external library/API this slice will touch, `grep` `specs/research/domain.md`, `specs/research/hallucination-traps.md`, `specs/error-registry.md`, and `specs/[feature]/slices/*/knowledge.md`. For any current matches (timestamp < 90 days, pinned versions still match `tech-stack.md`), add a `See also:` pointer in your `knowledge.md` instead of re-researching. Ignore stale matches and research fresh. One round of greps, not a rabbit hole.
>
> Independently, `grep` `specs/research/hallucination-traps.md` and `specs/error-registry.md` for the library/API names. Surface every matching trap row and every still-relevant prior bug as one-line pointers under `knowledge.md` § "Gotchas and footguns". Do NOT edit those files.
>
> Your job:
> 1. Produce `specs/[feature]/slices/[N]/step-spec.md` using the skeleton in `templates/step-spec.md`. Copy the user-visible outcome verbatim from `slice-plan.md`.
> 2. Produce `specs/[feature]/slices/[N]/knowledge.md` using the skeleton in `templates/knowledge.md`. Timestamp at top, versions pinned, every API claim sourced. Include dedup pointers and hallucination-trap surfacings per above.
>
> You may use WebSearch and WebFetch. You may NOT write application code or modify anything outside these two slice files. When done, output both file paths, list of dedup reuses (if any), and a 5-bullet summary of key findings the Coder must know. Stop.

## Stop condition

Both files exist under `specs/[feature]/slices/[N]/`, step-spec has sub-tasks and eval criteria copied by ID, knowledge.md has timestamp and pinned versions at the top, every API claim has a source URL or explicit "unverified" tag, the dedup pass has been run (reuses noted or "none" recorded), and any hallucination-trap / error-registry matches for the slice's libraries have been surfaced as one-line pointers in `knowledge.md` § "Gotchas and footguns".
