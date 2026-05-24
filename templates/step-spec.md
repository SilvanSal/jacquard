# Step Spec: Slice [ID]

_Feature: [feature-slug] · Slice: [S0N] · Created: [YYYY-MM-DD]_

## User-visible outcome

[Copy verbatim from `slice-plan.md`. One sentence.]

## Eval criteria this step satisfies

Copied verbatim from `eval-spec.md`:

- **E-XX.Y** — [text]
- **E-XX.Z** — [text]

## Sub-tasks (TDD pairs)

Sub-tasks follow the Red-Green cycle. Each functional unit gets a test-first pair: write the failing test/eval, then write the implementation that makes it pass. 3–10 sub-tasks typical. Ordered.

**Deterministic pairs** (unit test / integration test criteria):

- [ ] **T1 (RED):** Write tests for [behavior] — eval criteria E-XX.Y. Run → expect FAIL.
- [ ] **T2 (GREEN):** Implement [behavior] to pass T1 tests. Run → expect PASS.

**Non-deterministic pairs** (llm-as-judge / schema-check / semantic-match / regex-match / threshold criteria):

- [ ] **T3 (RED — eval):** Write eval harness for [LLM behavior] — eval criteria E-XX.Z. Evaluator: [type]. Threshold: [value]. Sample: N=[size]. Run → expect FAIL (missing impl).
- [ ] **T4 (GREEN):** Implement [prompt/chain/agent] to pass T3 eval at threshold. Run full sample → expect PASS.

**Standalone** (non-testable work — config, file moves, scaffolding):

- [ ] **T5:** [action — no TDD pair needed]

> **Numbering convention:** odd sub-tasks in pairs are RED (test/eval-writing), even are GREEN (implementation). A RED sub-task names the eval criteria it covers, the test/eval names from `eval-spec.md`, and for non-deterministic criteria, the evaluator type, pass threshold, and sample size. A GREEN sub-task references which RED sub-task it satisfies. Non-testable work gets standalone entries. The Step-Researcher authors the pairs; the Coder executes them in order.

## Files expected to be touched

Best guess. Coder may diverge but must raise significant deviations.

- `path/to/file1.ext` — [create / modify]
- `path/to/file2.ext` — [create / modify]
- `path/to/file3.test.ext` — [create]

## Out of scope (do NOT touch)

- [module / path] — [reason]
- [module / path] — [reason]

## Done definition

This step is done when:
- [ ] All TDD pairs committed — RED (failing test/eval) then GREEN (passing implementation) for each pair
- [ ] Every RED commit has a confirmed test/eval failure
- [ ] Every GREEN commit has those tests/evals passing, plus no regressions
- [ ] Deterministic criteria: all tests pass (exact assertions)
- [ ] Non-deterministic criteria: all evals meet their pass thresholds at the specified sample sizes
- [ ] Full test + eval suite is green (or failures are explicitly documented)
- [ ] No new lint errors
- [ ] Commits follow TDD message format: `test: ... (red)` / `eval: ... (red)` / `feat: ... (green)`

## Links

- Slice plan: `specs/[feature]/slice-plan.md`
- Knowledge for this step: `specs/[feature]/slices/[N]/knowledge.md`
- Previous handoff: `specs/[feature]/slices/[N-1]/handoff.md` (if N > 1)
