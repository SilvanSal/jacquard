# Stage 07 — Execute Step

**Run by:** `Coder` subagent (fresh context per step, full Write/Edit/Bash with scoped paths from `.claude/settings.json`)
**Reads:** `specs/[feature]/slices/[N]/step-spec.md`, `specs/[feature]/slices/[N]/knowledge.md`, `best-practices.md`, `code-style.md`, `tech-stack.md`, `specs/[feature]/slices/[N-1]/handoff.md` (if `N > 1`), `specs/error-registry.md` (grep-only before debugging), `specs/research/hallucination-traps.md` (grep-only before writing in an unfamiliar area)
**Produces:** code + one or more commits in the target project · may append one entry to `specs/error-registry.md` and/or one row to `specs/research/hallucination-traps.md` per confirmed trap

## Purpose

Execute exactly one slice. The Coder writes real application code. This is the ONLY stage where application code is written.

## What the Coder does

1. Read the step-spec top to bottom. Internalize the TDD sub-task pairs, files, eval criteria, out-of-scope list.
2. Read knowledge.md. Note the pinned versions and any footguns.
3. Read the previous handoff.md (if any). Internalize decisions and gotchas from the prior slice that affect this one.
4. Read best-practices.md, code-style.md, tech-stack.md. These frame *how* to write, not *what* to write.
5. Execute sub-tasks in TDD pairs — Red then Green. See "TDD discipline" below.
6. After the last GREEN sub-task, run the full test suite (or whatever `best-practices.md` says "done" means). If tests fail, fix. If you cannot fix within your scope, write a clear failure report and stop — do not proceed to review.
7. Hand off to the Orchestrator with: commit SHAs, test status, Red/Green confirmation per pair, any deviations from the step-spec and why.

## TDD discipline — Red-Green-Refactor

The Coder follows strict test-driven development. Every functional unit is built in a Red-Green pair as defined in the step-spec. This is not optional. The pipeline enforces the cycle because code that passes tests that were never seen failing proves nothing.

The eval-spec classifies each criterion as either **deterministic** (unit test, integration test) or **non-deterministic** (llm-as-judge, schema-check, semantic-match, regex-match, threshold). The TDD cycle applies to both, but the mechanics differ.

### Deterministic TDD (unit tests, integration tests)

For criteria with predictable, reproducible outputs.

**RED phase (odd sub-tasks):**
1. Write the test(s) for the behavior described in the sub-task. Use the test names from `eval-spec.md` exactly.
2. Run the test(s). They MUST fail. If they pass, something is wrong: either the test is vacuous (testing nothing), the behavior already exists (step-spec is wrong — raise to orchestrator), or the assertion is tautological. Investigate before proceeding.
3. Commit the failing tests. Message format: `test: [description] (red — not yet implemented)`.

**GREEN phase (even sub-tasks):**
1. Write the minimum implementation code to make the RED phase tests pass. No more, no less.
2. Run the test(s) from the RED phase. They MUST pass. If they don't, fix the implementation — do not weaken the test.
3. Run any previously-passing tests to confirm no regressions.
4. Commit the implementation. Message format: `feat: [description] (green — tests pass)`.

### Non-deterministic TDD (LLM evals) — conditional read

If the step-spec contains sub-tasks marked `(RED — eval)`, the Coder also reads `pipeline/07a-eval-harness.md` before starting those sub-tasks. That file covers the full non-deterministic cycle: eval harness structure (dataset, evaluator, runner), free framework options, evaluator-specific rules (judge pinning, local embeddings), smoke vs. full run protocol, and the detailed Red-Green cycle for LLM code.

**If the step-spec has NO eval sub-tasks, skip `07a-eval-harness.md` entirely.** The deterministic TDD rules above are sufficient.

The same hard rules apply to both types — never skip RED, never weaken a test or lower a threshold, one pair at a time. Non-deterministic evals use `eval:` commit prefix instead of `test:`.

### REFACTOR (optional, within GREEN phase)

If the code works but is messy, refactor immediately after the GREEN confirmation. Re-run tests/evals to confirm they still pass. Include the refactor in the GREEN commit or as a separate `refactor:` commit — do not mix refactor with new RED tests.

### Hard rules

- **Never skip RED.** Every GREEN commit must be preceded by a RED commit whose tests/evals it satisfies. If a sub-task has no testable behavior (e.g., config file changes, pure refactors), the step-spec should not mark it as a TDD pair — it gets a standalone sub-task instead.
- **Never weaken a test or lower a threshold to make GREEN easier.** If the test is wrong, fix it and re-confirm RED before proceeding to GREEN. If a threshold is unreachable, halt and raise — the Architect owns the threshold, not the Coder. Log the correction as a deviation.
- **Tests/evals that pass on first write are a smell.** If a RED-phase test/eval passes immediately, halt and diagnose. Valid reasons: the behavior was implemented by a prior pair (in which case it's a test gap from that pair — note it). Invalid: the test doesn't assert anything meaningful.
- **One pair at a time.** Do not batch-write all tests/evals then batch-write all implementations. The point of TDD is the tight feedback loop: test, fail, implement, pass, next.
- **Test/eval scope matches sub-task scope.** A RED sub-task covers the eval criteria listed in it — no more. Don't write tests for future sub-tasks.

## Rules for the Coder

- **Do not read `specs/research/domain.md`.** Not your job. The design and step-spec have already distilled what you need.
- **Do not read earlier slices' knowledge.md or step-spec.md.** Only the most recent handoff.md. If you think you need prior detail, raise it to the orchestrator — usually it means the handoff was insufficient (a bug worth fixing).
- **Stay inside the step-spec's file list.** If you need a file not listed, raise it to the orchestrator. Small additions are usually fine; large detours mean the step-spec is wrong.
- **Respect out-of-scope.** If the step-spec says "do not touch the payment module", don't, even if you see an easy improvement there. File a follow-up note instead.
- **Follow tech-stack pinning.** If tech-stack.md pins `requests==2.31.0`, do not install 2.32.0.
- **Do not invent requirements.** If a requirement is ambiguous, stop and raise it. Do not guess.
- **Commit frequently, atomically.** Each commit should pass tests on its own where possible.
- **No backwards-compat shims, no "just in case" code, no dead `_removed` comments.** The constitution and best-practices enforce this.

## Micro-research escape hatch

The Coder is allowed a narrow, bounded lookup when a library or API demonstrably behaves differently than `knowledge.md` describes. This exists because docs lie, not as a back door to redefine the task.

**When it is allowed:**
- A factual contradiction between `knowledge.md` / step-spec and observed runtime behavior (e.g., function signature wrong, parameter ignored, error type mismatch).
- The answer is a single objective fact recoverable from official docs, a package changelog, a GitHub issue, or source.

**Hard limits (any of these → halt instead, do not micro-research):**
- You would need more than ONE `WebSearch` or `WebFetch` call per blocker. A second question means the scope has grown — halt.
- The answer would require changing the step-spec's sub-tasks, file list, or out-of-scope list.
- The answer would require changing a pinned version in `tech-stack.md` or swapping one library for another.
- The answer is a judgment call (architectural shape, security posture, UX).
- You would be fixing something outside the current slice's diff surface.

**Protocol:**
1. Write down the blocker in one sentence before searching.
2. Run exactly one `WebSearch` or `WebFetch`. Prefer official docs or the package's own repo.
3. If the answer resolves the blocker within scope, continue and log the event for the Handoff-Writer with: blocker sentence, query, answer (2–4 lines), source URL, what you adjusted.
4. If the answer does not resolve it, or would push you past any hard limit above, halt and report the blocker + finding to the orchestrator. Do not attempt a second lookup.

**What this is not:** spawning a research subagent, re-running step-research, or reading `specs/research/domain.md`. One lookup, logged, bounded.

## Long-stage context discipline

A slice can take 3–10 sub-tasks in a single Coder session. Tool results (test output, grep dumps, large file reads) accumulate. Without a discipline the context fills up and the last sub-tasks silently lose the earlier ones, or the API rejects the turn. "Fresh context per stage" handles cross-stage spillover only — within a stage, the Coder must manage the window.

**Turn-budget markers (apply in order):**
1. **After every sub-task**: drop or abbreviate verbose tool outputs from sub-tasks older than the last two. Keep commit SHAs, error signatures, and the names of files touched; discard raw diffs, full test-runner output, and full `grep` dumps. The handoff will reconstruct these from git.
2. **Before sub-task 4 (if the step-spec has ≥ 4 sub-tasks)**: write a one-paragraph self-summary into your working notes covering (a) sub-tasks completed, (b) files touched with SHAs, (c) any deviations, (d) remaining sub-task list verbatim from step-spec. This is the Coder's own compaction pass — a cheap "truncate" before the more expensive "self-summarize".
3. **Before sub-task 7 (if applicable)**: drop ALL detail from sub-tasks 1–N−3 except commit SHAs and the running deviation log. If you need prior detail later, re-read the commit or the file.
4. **If any single tool result exceeds ~4,000 characters**: abbreviate it in your reasoning to the first ~20 lines plus a one-line "N more lines, M chars truncated" tag. Do NOT paste the full result into your own text; it's already in the transcript.

**Self-compaction prompt template (use when discarding detail):**

> Summary of sub-tasks 1–N:
> - Files touched: `path/a.ts`, `path/b.ts` (SHA abc1234, def5678)
> - Deviations: _1 micro-research lookup: X contradicted knowledge, adjusted Y (see source Z)._
> - Open: sub-tasks N+1 .. last from step-spec, verbatim.
>
> (All verbose tool output from 1–N is intentionally dropped. Re-read commits or files if needed.)

**Hard rules:**
- Never discard the **deviation log**, **micro-research lookups**, **error-registry appends**, or the **running file list**. Those feed the handoff.
- Never discard the **step-spec itself** from your working context. If you feel you need to re-read it, that is a compaction warning — run marker 2 or 3 instead.
- If you hit a 413 / "prompt too long" from the API in the middle of a sub-task, stop, apply marker 3 before retrying the same tool call, and log it as a deviation. Do NOT silently retry.

Rationale: open-claude-code's `context.ts` applies this ladder programmatically (truncate → LLM summarize → circuit breaker). The Coder has no runtime, so the discipline has to live in prose and get re-read each stage. The markers are the cheapest strategy at each threshold — the same ordering the runtime uses.

## Error registry + hallucination-traps lookup

The Coder treats `specs/error-registry.md` and `specs/research/hallucination-traps.md` as grep-targets, not read-through docs. They exist so you do not re-debug the same failure twice and do not fall into known wrong-pattern traps.

**Before you write code in an unfamiliar area of the project:**
- `grep` `specs/research/hallucination-traps.md` for the library, API, or concept you are about to use. If a row matches, follow the Correct column.

**Before you spend more than ~10 minutes debugging a non-trivial failure:**
- `grep` `specs/error-registry.md` for a word or two from the error signature. If an entry matches, apply the recorded fix and note it in the deviation log. If it matches but the fix no longer works, bump the Recurrence counter after you fix it.

**Appending (keep this tight):**
- After you resolve a non-trivial bug — multi-attempt, silent misbehavior, schema/version mismatch, or one that cost you a `WebSearch`/`WebFetch` — append one entry to `specs/error-registry.md` per the format in `templates/error-registry.md`. One entry per bug class, not per occurrence.
- When an error-registry entry hits `Recurrence: 3` OR when your micro-research lookup confirms a wrong-pattern/right-pattern pair that future code in this project would also trip on, promote it to a row in `specs/research/hallucination-traps.md`.
- You do NOT append design decisions, style preferences, feature gotchas, or one-line typos. Those belong in other files (or nowhere).
- Appending to these two files is in-scope by default — it does not count against your step-spec file list. Commit the append in the same commit that fixed the bug.

## Orchestrator dispatch prompt (copy verbatim)

> You are the Coder subagent for slice `[ID]`. Fresh context. Read these files in this order:
> 1. `specs/[feature]/slices/[N]/step-spec.md`
> 2. `specs/[feature]/slices/[N]/knowledge.md`
> 3. `specs/[feature]/slices/[N-1]/handoff.md` (skip if N == 1)
> 4. `best-practices.md`
> 5. `code-style.md`
> 6. `tech-stack.md`
>
> Do NOT read `specs/research/domain.md`, any prior slice's step-spec or knowledge, `specs/[feature]/design.md` (unless the step-spec explicitly points you to a section), or `specs/constitution.md` directly (it's been distilled into best-practices).
>
> Two grep-only lookups: before writing code in an unfamiliar area, `grep` `specs/research/hallucination-traps.md` for the library/API you're about to use. Before spending >10 min debugging a non-trivial failure, `grep` `specs/error-registry.md` for a word from the error signature. Do not read these cover-to-cover.
>
> **You follow strict TDD (Test-Driven Development).** Sub-tasks come in Red-Green pairs:
> - **RED:** Write the test(s) from the odd sub-task. Run. Must FAIL. Commit: `test: [desc] (red — not yet implemented)`.
> - **GREEN:** Write the minimum implementation. Run. Must PASS. Confirm no regressions. Commit: `feat: [desc] (green — tests pass)`.
> Never skip RED. Never weaken a test. One pair at a time.
> Full TDD rules: `pipeline/07-execute-step.md` § "TDD discipline — Red-Green-Refactor".
>
> [CONDITIONAL — include ONLY if step-spec has `(RED — eval)` sub-tasks]:
> **This slice has non-deterministic eval criteria.** Also read `pipeline/07a-eval-harness.md` before starting any `(RED — eval)` sub-task. It covers eval harness structure, free framework options, evaluator-specific rules, and the non-deterministic Red-Green cycle. For eval sub-tasks, use `eval:` commit prefix instead of `test:`.
>
> Do not touch files outside the step-spec's file list without raising it. Do not proceed to the review stage — the orchestrator handles that.
>
> You have a bounded micro-research escape hatch: one `WebSearch` or `WebFetch` per factual blocker where a library demonstrably contradicts `knowledge.md`. Log the Q+A as a deviation. You may NOT use it to change the step-spec, pinned versions, or scope — any of those = halt. See "Micro-research escape hatch" in `pipeline/07-execute-step.md`.
>
> When you resolve a non-trivial bug, append one entry to `specs/error-registry.md` (format in `templates/error-registry.md`). If your micro-research surfaced a confirmed wrong-pattern/right-pattern pair, also append one row to `specs/research/hallucination-traps.md`. These appends are in-scope and go in the same commit as the fix. See `pipeline/07-execute-step.md` § "Error registry + hallucination-traps lookup".
>
> Long-stage context discipline: after every sub-task, abbreviate tool output older than two sub-tasks back (keep SHAs, files, error signatures; drop raw diffs/dumps). Before sub-task 4, write a one-paragraph self-summary (sub-tasks done, files+SHAs, deviations, remaining verbatim). Before sub-task 7, drop all detail from sub-tasks 1..N−3 except SHAs + deviation log. Any single tool result >~4K chars: abbreviate to first ~20 lines + count tag in your reasoning. Never discard the deviation log, micro-research log, registry appends, running file list, or the step-spec itself. On 413 mid-sub-task: stop, compact per marker 3, retry once, log as deviation. Full rules: `pipeline/07-execute-step.md` § "Long-stage context discipline".
>
> When done, output: commit SHAs in order (tagged RED or GREEN), test status (pass/fail/skipped), eval status (pass/fail/skipped with pass rates per non-deterministic criterion), Red-Green confirmation per pair (test/eval failed at RED, passed at GREEN), any deviations with reasoning (including any micro-research lookups), and any error-registry / hallucination-traps appends. Stop.

## Stop condition

All sub-task pairs from step-spec.md are committed (RED then GREEN for each pair). Every RED commit has a confirmed test failure; every GREEN commit has those tests passing. Full test suite passes (or failures are documented with reasoning). Coder has reported commit SHAs (tagged RED/GREEN) and deviations back to the orchestrator. Orchestrator then dispatches stage 08.
