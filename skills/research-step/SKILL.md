---
name: research-step
description: Use before executing each slice to produce that slice's `step-spec.md` and `knowledge.md`. Fresh context per slice. Invokes the Step-Researcher subagent. Runs between stages 05 and 07 for every slice.
allowed-tools: Read, Grep, Glob, WebSearch, WebFetch, Write
---

# research-step — Stage 06

## When to trigger
- A slice is about to execute.
- `specs/[feature]/slice-plan.md` exists and identifies slice `[N]`.
- `specs/[feature]/slices/[N]/step-spec.md` or `knowledge.md` do NOT exist.

## Do not trigger
- If both files already exist for this slice.
- If the slice-plan has not been approved by the user.

## Produces
`specs/[feature]/slices/[N]/step-spec.md` AND `specs/[feature]/slices/[N]/knowledge.md`.

## Rules
- Step-spec first, knowledge.md second.
- **Step-spec sub-tasks must be structured as TDD Red-Green pairs.** Odd sub-tasks = RED (write failing tests, naming eval criteria + test names from `eval-spec.md`). Even sub-tasks = GREEN (write implementation to pass those tests). Non-testable work (config, file moves) gets standalone entries, not pairs.
- Step-Researcher does NOT read `best-practices.md` or `code-style.md` — those are for the Coder.
- Every API claim has a source URL; unverified claims tagged `unverified`.
- Pin versions explicitly (`requests==2.31.0`, not `requests`).
- Cap `knowledge.md` at ~500 lines.
- Do NOT write code beyond minimal examples copied from docs.
- Do NOT read prior slices' `knowledge.md` or `handoff.md` cover-to-cover. The dedup check (see below) permits targeted section reads only.
- Timestamp + pinned versions at the top of `knowledge.md`.

## Dedup check + trap surfacing (before drafting knowledge.md)

- For each library/API the step-spec sub-tasks will touch, `grep` `specs/research/domain.md`, `specs/research/hallucination-traps.md`, `specs/error-registry.md`, and `specs/[feature]/slices/*/knowledge.md` for keywords.
- If a match is current (timestamp < 90 days AND pinned version matches `tech-stack.md`): add a `See also:` pointer to the new `knowledge.md` instead of re-researching. If stale: ignore and research fresh, flag the stale entry in output.
- Surface every hallucination-traps row and still-relevant error-registry entry for this slice's libraries as one-line pointers under `knowledge.md` § "Gotchas and footguns". Do NOT edit those files.
- Budget one round of greps per slice. Dedup is not a rabbit hole.
- Full rules: `pipeline/06-research-step.md` § "Dedup check" and § "Hallucination-traps + error-registry surfacing".

## Dispatch the Step-Researcher subagent (verbatim)

> You are the Step-Researcher subagent for slice `[ID]`. Fresh context. Read: `specs/[feature]/slice-plan.md`, `specs/[feature]/design.md` (relevant section only), `tech-stack.md`, `specs/constitution.md`. Do NOT read `best-practices.md`, `code-style.md`, `specs/research/domain.md` cover-to-cover, or any prior slice's `knowledge.md` or `handoff.md` cover-to-cover.
>
> Before drafting `knowledge.md`, run the dedup check from `pipeline/06-research-step.md` § "Dedup check": grep `specs/research/domain.md`, `specs/research/hallucination-traps.md`, `specs/error-registry.md`, and `specs/[feature]/slices/*/knowledge.md` for the library/API keywords this slice touches. Current matches → `See also:` pointer, no re-research. Stale matches → ignore, research fresh, flag in output. Surface any hallucination-trap rows and still-relevant error-registry entries as one-line pointers under `knowledge.md` § "Gotchas and footguns". Do NOT edit those files.
>
> Produce:
> 1. `specs/[feature]/slices/[N]/step-spec.md` using the skeleton in `templates/step-spec.md`. Copy the user-visible outcome verbatim from `slice-plan.md`. Include sub-tasks (3–10), expected files, eval criteria by ID, explicit out-of-scope list.
> 2. `specs/[feature]/slices/[N]/knowledge.md` using the skeleton in `templates/knowledge.md`. Timestamp at top, versions pinned, every API claim sourced, dedup pointers and trap/prior-bug surfacings included.
>
> You may use WebSearch and WebFetch. You may NOT write application code or modify anything outside these two slice files. When done, output both file paths, dedup reuses (list or "none"), any stale prior entries, and a 5-bullet summary the Coder must know. Stop.

## Stop condition
Both files exist under `specs/[feature]/slices/[N]/`, step-spec has sub-tasks + eval criteria by ID + out-of-scope list, knowledge.md has timestamp + pinned versions + sourced API claims.
