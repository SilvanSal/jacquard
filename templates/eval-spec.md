# Eval Spec: [Feature Name]

_Feature ID: [feature-slug] · Created: [YYYY-MM-DD]_

The reviewer cluster (code / security / browser) checks against THIS file. Every criterion has a unique ID so slice-plan and handoff can reference it.

> **Evaluator types — deterministic vs. non-deterministic:**
>
> **Deterministic evaluators** — for code with predictable outputs:
> - `unit test` — isolated function-level test, exact assertions
> - `integration test` — multi-component test, exact assertions
> - `browser verifier` — UI behavioral check (end-of-feature only)
> - `manual` — human approval required
>
> **Non-deterministic evaluators** — for LLM-based / AI-powered code where outputs vary per run:
> - `llm-as-judge` — a judge model scores the output (e.g., GPT-4 rates response quality 1–5). Specify judge model, rubric, and pass threshold.
> - `schema-check` — output must conform to a structure (valid JSON, required fields, type constraints). Deterministic assertion on non-deterministic output.
> - `semantic-match` — output must be semantically similar to a reference (cosine similarity, entailment). Specify similarity metric and threshold.
> - `regex-match` — output must match a pattern (contains keywords, format constraints). Deterministic assertion on non-deterministic output.
> - `threshold` — a numeric metric (latency, token count, cost, accuracy over N runs) must meet a target. Specify metric, target, and sample size.
>
> **Test-name convention:** For deterministic evaluators (`unit test`, `integration test`), the `Test name` column holds the one-line signature the Coder will implement — e.g., `test_upload_rejects_files_over_10mb` (pytest) or `uploadRejectsFilesOver10MB()` (vitest). For non-deterministic evaluators, the `Test name` holds the eval function signature — e.g., `eval_summarizer_preserves_key_facts` or `eval_classifier_accuracy_above_90pct`. Names only, no file paths, no bodies. Pick the runner based on `tech-stack.md`. For `browser verifier` and `manual` evaluators, leave `Test name` as `—`. The Code-Reviewer (Stage 08) verifies each named test/eval exists in the slice that owns the criterion.

## Pass criteria (per user story)

### US-01 criteria (deterministic)

| ID | Criterion | Evaluator | Test name | Notes |
|---|---|---|---|---|
| E-01.1 | [Testable statement] | unit test / integration test / browser verifier / manual | `test_name_here` or `—` | [how to run, what to assert] |
| E-01.2 | | | | |

### US-02 criteria (non-deterministic — LLM-based)

| ID | Criterion | Evaluator | Test name | Pass threshold | Sample size | Notes |
|---|---|---|---|---|---|---|
| E-02.1 | [Observable behavior statement] | llm-as-judge / schema-check / semantic-match / regex-match / threshold | `eval_name_here` | [e.g., ≥4/5 judge score, ≥0.85 similarity, 100% schema valid] | [e.g., N=10, N=50] | [judge rubric, reference text, schema, or metric details] |
| E-02.2 | | | | | | |

> **Mixing types:** A feature can have both deterministic and non-deterministic criteria. The Architect classifies each criterion independently. A user story about "AI-powered search" might have deterministic criteria for the API endpoint (unit test) and non-deterministic criteria for search relevance (llm-as-judge). Each type follows its own TDD rules in Stage 07.

## Regression criteria

Previously-shipped slices whose behavior must NOT change when this feature lands.

| ID | Behavior that must stay intact | Reference | Evaluator | Test name |
|---|---|---|---|---|
| R-01 | | slice `[ID]` | browser verifier / integration test | `test_name_here` or `—` |

## Performance budgets

| Metric | Target | Measurement method |
|---|---|---|
| | | |

## Security checks

Diff-scoped checks the Security-Reviewer runs on every commit in this feature.

- [ ] No secrets committed
- [ ] Auth-free routes do not return PII
- [ ] Input validation at every new trust boundary
- [ ] [Feature-specific check]

## Manual approval gates

Criteria that can't be automated. Must be explicitly approved by the user before the feature is considered complete.

- [ ] [User behavior that a human must confirm]

## Links

- Requirements: `specs/[feature]/requirements.md`
- Design: `specs/[feature]/design.md`
