---
name: execute-step
description: Use to execute exactly one slice after its `step-spec.md` + `knowledge.md` exist. Invokes the Coder subagent using strict TDD (Red-Green-Refactor). For deterministic code: writes failing tests first, then implementation. For LLM-based code: conditionally loads `eval-harness` sub-skill. This is the ONLY skill where application code is written.
allowed-tools: Read, Grep, Glob, Write, Edit, Bash, WebSearch, WebFetch
---

# execute-step — Stage 07

## When to trigger
- `specs/[feature]/slices/[N]/step-spec.md` AND `knowledge.md` exist for slice `[N]`.
- Slice `[N]` has not been executed yet (no commits referencing its SHAs, no `review.md`).

## Do not trigger
- If step-spec or knowledge is missing — run `research-step` first.
- If the slice is already reviewed and shipped.

## Produces
Application code + commits in the target project.

## Rules for the Coder
- **Strict TDD.** Sub-tasks come in Red-Green pairs. RED: write tests, run, must fail, commit. GREEN: write implementation, run, must pass, commit. One pair at a time. Never skip RED. Never weaken a test.
- **Non-deterministic criteria (if present):** when the step-spec has `(RED — eval)` sub-tasks, the Coder also reads `pipeline/07a-eval-harness.md` for the full eval mechanics. This is triggered by the orchestrator via the dispatch prompt — the Coder does NOT read it for purely deterministic slices.
- Do NOT read `specs/research/domain.md`, earlier slices' `knowledge.md` or `step-spec.md`, or `specs/[feature]/design.md` (unless the step-spec explicitly points to a section).
- Only the most recent `handoff.md` from slice `[N-1]` (if `N > 1`).
- Stay inside the step-spec's file list. Small additions OK; large detours mean step-spec is wrong — raise to orchestrator.
- Respect out-of-scope list literally.
- Follow tech-stack pinning. No silent version bumps.
- RED commits: `test: [desc] (red — not yet implemented)`. GREEN commits: `feat: [desc] (green — tests pass)`.
- Run full test suite after the last GREEN sub-task. If tests fail and cannot be fixed in scope, report failure and stop — do not advance to review.
- No backwards-compat shims, no "just in case" code, no `// removed` comments.

## Micro-research escape hatch (bounded)

The Coder may invoke ONE `WebSearch` or `WebFetch` per factual blocker where a library demonstrably contradicts `knowledge.md`. This is a narrow unblock path, not a redefine-the-task path.

- Hard limits: one lookup per blocker; must not change step-spec sub-tasks / file list / out-of-scope / pinned versions; must not be a judgment call. Any of those → halt and raise.
- Log outcome in the Coder's report: blocker, query, 2–4-line answer, source URL, in-scope adjustment.
- Full rules: `pipeline/07-execute-step.md` § "Micro-research escape hatch".

## Long-stage context discipline (Coder self-manages)

The Coder runs 3–10 sub-tasks in one context. Apply these markers in order:
- After every sub-task, abbreviate verbose tool output older than two sub-tasks back.
- Before sub-task 4 (if ≥ 4 sub-tasks), write a one-paragraph self-summary.
- Before sub-task 7, drop detail from sub-tasks 1..N−3 except SHAs + deviation log.
- Any tool result > ~4K chars: abbreviate to first ~20 lines + count tag in reasoning.
- Never discard: deviation log, micro-research log, registry appends, running file list, step-spec.
- On 413 mid-sub-task: bigger-drop, retry once, log as deviation.
- Full rules: `pipeline/07-execute-step.md` § "Long-stage context discipline".

## Error registry + hallucination-traps lookup

- Before writing code in an unfamiliar area: `grep` `specs/research/hallucination-traps.md` for the library/API.
- Before spending >10 min debugging a non-trivial failure: `grep` `specs/error-registry.md` for a word from the error signature.
- After resolving a non-trivial bug: append one entry to `specs/error-registry.md` (template: `templates/error-registry.md`), in the same commit as the fix. In-scope by default.
- If the bug's cause is a confirmed wrong-pattern/right-pattern pair (or an error-registry entry reached Recurrence 3), also append one row to `specs/research/hallucination-traps.md`.
- Do NOT read these files cover-to-cover. Do NOT append design decisions, style preferences, feature gotchas, or one-line typos.
- Full rules: `pipeline/07-execute-step.md` § "Error registry + hallucination-traps lookup".

## Dispatch the Coder subagent (verbatim)

> You are the Coder subagent for slice `[ID]`. Fresh context. Read these files in this order:
> 1. `specs/[feature]/slices/[N]/step-spec.md`
> 2. `specs/[feature]/slices/[N]/knowledge.md`
> 3. `specs/[feature]/slices/[N-1]/handoff.md` (skip if N == 1)
> 4. `best-practices.md`
> 5. `code-style.md`
> 6. `tech-stack.md`
>
> Do NOT read `specs/research/domain.md`, any other slice's step-spec / knowledge / handoff, `specs/[feature]/design.md` (unless step-spec points to a section), or `specs/constitution.md` directly.
>
> Two grep-only lookups: before writing code in an unfamiliar area, `grep` `specs/research/hallucination-traps.md` for the library/API. Before spending >10 min debugging a non-trivial failure, `grep` `specs/error-registry.md` for a word from the error signature. Do not read either file cover-to-cover.
>
> **You follow strict TDD.** Sub-tasks come in Red-Green pairs:
> - **RED:** Write the test(s). Run. Must FAIL. Commit: `test: [desc] (red — not yet implemented)`.
> - **GREEN:** Write the minimum implementation. Run. Must PASS. Confirm no regressions. Commit: `feat: [desc] (green — tests pass)`.
> Never skip RED. Never weaken a test. One pair at a time. Full rules: `pipeline/07-execute-step.md` § "TDD discipline".
>
> [CONDITIONAL — include ONLY if step-spec has `(RED — eval)` sub-tasks]:
> **This slice has non-deterministic eval criteria.** Also read `pipeline/07a-eval-harness.md` before starting any `(RED — eval)` sub-task. Use `eval:` commit prefix instead of `test:` for those pairs.
>
> Do not touch files outside the step-spec's file list without raising. Do not run the review stage — the orchestrator handles that.
>
> Long-stage context discipline: after every sub-task, abbreviate tool output older than two sub-tasks back; before sub-task 4 write a one-paragraph self-summary; before sub-task 7 drop detail from sub-tasks 1..N−3 except SHAs + deviation log; any single tool result >~4K chars → abbreviate in your reasoning. Never drop: deviation log, micro-research log, registry appends, running file list, step-spec. On 413 mid-sub-task: bigger-drop, retry once, log as deviation. Full rules: `pipeline/07-execute-step.md` § "Long-stage context discipline".
>
> You have a bounded micro-research escape hatch: one `WebSearch` or `WebFetch` per factual blocker where a library contradicts `knowledge.md`. Log the Q+A. You may NOT use it to change the step-spec, pinned versions, or scope — halt instead.
>
> When you resolve a non-trivial bug, append one entry to `specs/error-registry.md` in the same commit as the fix. If your fix confirms a wrong-pattern/right-pattern pair (or an error-registry entry reaches Recurrence 3), also append one row to `specs/research/hallucination-traps.md`. These appends are in-scope.
>
> When done, output: commit SHAs in order (tagged RED or GREEN), Red-Green confirmation per pair (test/eval failed at RED, passed at GREEN), test status (pass/fail/skipped), eval status if applicable (pass rates per criterion), any deviations with reasoning (including micro-research lookups), any error-registry / hallucination-traps appends. Stop.

## Stop condition
All step-spec sub-task pairs committed (RED then GREEN for each). Every RED commit has confirmed test/eval failure; every GREEN commit has those tests/evals passing. Full test suite passes (or failures documented). Coder has reported commit SHAs (tagged RED/GREEN) + Red-Green confirmations + deviations. Orchestrator then invokes `review`.
