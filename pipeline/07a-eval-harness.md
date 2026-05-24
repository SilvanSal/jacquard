# Stage 07a — Eval Harness (Non-Deterministic TDD)

**Read by:** the Coder subagent, ONLY when the step-spec contains non-deterministic TDD pairs (marked `RED — eval`).
**Purpose:** Extend the TDD discipline from `07-execute-step.md` with the mechanics of writing, running, and scoring evals for LLM-based / AI code.

> **When to skip this file:** if every sub-task in the step-spec is deterministic (plain `RED` / `GREEN` with unit/integration tests), the Coder does NOT read this file. The orchestrator controls this via the dispatch prompt.

## Why evals are different from tests

A unit test asserts an exact value: `assert add(2, 3) == 5`. It passes or fails identically every run.

An LLM eval asserts a *property* of a *variable* output: "the summary preserves the key facts" or "the JSON is schema-valid." The output changes on every call, so you need multiple runs, a scoring function, and a pass threshold. The TDD cycle still applies — write the eval first, watch it fail, implement, watch it pass — but the machinery around "fail" and "pass" is heavier.

## Eval harness structure

Every non-deterministic RED sub-task produces an **eval harness** — a test file the runner can execute. The harness has four parts:

### 1. Eval dataset (test cases)

A list of representative inputs the implementation will be called with, plus optional reference outputs or facts for the evaluator to check against.

```python
# Example: eval dataset for a summarizer
EVAL_CASES = [
    {
        "input": "The board voted 7-2 to approve the merger...",
        "reference_facts": ["board voted 7-2", "merger approved"],
        "max_output_tokens": 100,
    },
    {
        "input": "Quarterly revenue rose 12% year-over-year...",
        "reference_facts": ["revenue rose 12%", "year-over-year"],
        "max_output_tokens": 100,
    },
    # ... more cases up to the eval-spec's sample size
]
```

**Rules for eval datasets:**
- Minimum cases = the eval-spec's sample size (N). More is better.
- Cases must be diverse — cover the input distribution the feature will see. Do not repeat the same pattern N times.
- If the eval-spec provides reference outputs or facts, include them. If not, the evaluator must work without references (e.g., schema-check, regex-match).
- Eval datasets live alongside the test files (same directory conventions as `code-style.md`). They are committed in the RED commit.
- Keep cases small. Each case should run in seconds, not minutes. If the target LLM call is slow, that is implementation cost, not eval cost.

### 2. Evaluator function (the scorer)

A function that takes the LLM output (and optionally a reference) and returns a score. One per evaluator type:

**`llm-as-judge`** — calls a pinned judge model with a rubric:
```python
def judge_summary_quality(output, reference_facts, client):
    response = client.messages.create(
        model="claude-sonnet-4-6-20250514",  # PINNED — do not use unpinned aliases
        max_tokens=256,
        messages=[{
            "role": "user",
            "content": (
                "Score this summary 1-5 on fact preservation.\n"
                "Required facts: {facts}\n"
                "Summary: {summary}\n"
                "Respond with JSON: {{\"score\": <int 1-5>, \"reasoning\": \"...\"}}"
            ).format(facts=reference_facts, summary=output),
        }],
    )
    return parse_json_score(response)  # returns int 1-5
```

**`schema-check`** — validates structure:
```python
import jsonschema

RESPONSE_SCHEMA = {
    "type": "object",
    "required": ["summary", "confidence"],
    "properties": {
        "summary": {"type": "string", "minLength": 10},
        "confidence": {"type": "number", "minimum": 0, "maximum": 1},
    },
}

def check_schema(output):
    try:
        parsed = json.loads(output)
        jsonschema.validate(parsed, RESPONSE_SCHEMA)
        return True
    except (json.JSONDecodeError, jsonschema.ValidationError):
        return False
```

**`semantic-match`** — compares meaning to a reference (use free local embeddings):
```python
from sentence_transformers import SentenceTransformer

model = SentenceTransformer("all-MiniLM-L6-v2")  # free, local, no API cost

def semantic_similarity(output, reference):
    embeddings = model.encode([output, reference])
    cosine_sim = np.dot(embeddings[0], embeddings[1]) / (
        np.linalg.norm(embeddings[0]) * np.linalg.norm(embeddings[1])
    )
    return float(cosine_sim)  # 0.0 to 1.0
```

**`regex-match`** — checks pattern:
```python
import re

def check_format(output, patterns):
    return all(re.search(p, output) for p in patterns)
```

**`threshold`** — aggregates a numeric metric:
```python
def measure_latency(func, input_data, n_runs=10):
    times = []
    for _ in range(n_runs):
        start = time.time()
        func(input_data)
        times.append(time.time() - start)
    return {"mean": statistics.mean(times), "p95": sorted(times)[int(n_runs * 0.95)]}
```

### 3. Eval runner (the test function)

The function that ties it together: runs the target, scores each output, aggregates, asserts against threshold. This is what the test runner (pytest / vitest) actually executes.

```python
def test_summarizer_preserves_key_facts():
    """Eval: llm-as-judge, threshold ≥4/5 in 80% of runs, N=10."""
    client = anthropic.Anthropic()
    pass_count = 0

    for case in EVAL_CASES:
        output = summarize(case["input"])  # ← target function (doesn't exist at RED)
        score = judge_summary_quality(output, case["reference_facts"], client)
        if score >= 4:
            pass_count += 1

    pass_rate = pass_count / len(EVAL_CASES)
    assert pass_rate >= 0.8, (
        f"Eval FAIL: {pass_rate:.0%} of runs scored ≥4/5 "
        f"(threshold: 80%, got {pass_count}/{len(EVAL_CASES)})"
    )
```

**At RED:** `summarize()` doesn't exist → `ImportError` or `NameError` → test fails. This is the expected RED state.
**At GREEN:** `summarize()` is implemented → judge scores each output → pass rate computed → assert checks threshold.

### 4. Smoke vs. full run

LLM evals cost API calls. During iteration (writing the implementation, tuning the prompt), do NOT run the full N-sample eval on every change. Instead:

- **Smoke run (N=1–3):** quick sanity check during development. Run after each prompt tweak. Not a pass/fail gate.
- **Full run (N=eval-spec sample size):** the official GREEN confirmation. Run once when you believe the implementation is ready. This is what the commit records.
- If the full run fails borderline (e.g., 7/10 when threshold is 8/10), run one more full batch before concluding. Log both results.

## Free eval framework options

All tools below are open-source and free. The only cost is the LLM API calls themselves (target model + judge model), which are inherent to running LLM code. No additional subscriptions or paid platforms.

### Option 1: Hand-rolled (no dependency)

Write the eval loop directly in your test files using the project's existing test runner (pytest, vitest, etc.). The examples above show this pattern.

**When to use:** small projects, few eval criteria, team already comfortable with the test runner. Least setup. Most control.

### Option 2: promptfoo (open-source CLI)

`promptfoo` is a free, open-source eval CLI that handles the run-score-aggregate loop. MIT license.

- **Install:** `npm install -g promptfoo` (Node) or `pip install promptfoo` (Python)
- **Config:** YAML file defines test cases, evaluators, and thresholds
- **Evaluators built-in:** LLM rubric (llm-as-judge), JSON schema, regex, similarity, contains, custom JS/Python
- **Output:** CLI table, JSON, or CI-friendly exit codes
- **Integration:** can wrap any CLI command, HTTP endpoint, or JS/Python function as the target

**When to use:** multiple eval criteria, want structured reporting, CI integration. The YAML config makes eval cases easy to version and review.

### Option 3: deepeval (open-source, pytest plugin)

`deepeval` is a free, open-source Python framework that integrates with pytest. Apache 2.0 license.

- **Install:** `pip install deepeval`
- **Usage:** write eval tests as pytest functions using `deepeval` metrics
- **Metrics built-in:** G-Eval (LLM-as-judge with structured rubrics), hallucination, answer relevancy, faithfulness, JSON correctness, bias, toxicity
- **Output:** pytest output + optional local dashboard

**When to use:** Python projects already using pytest. Rich built-in metrics for common LLM patterns (RAG, summarization, Q&A).

### Option 4: Inspect AI (open-source, by UK AISI)

`inspect_ai` is a free, open-source framework for AI evaluation. MIT license.

- **Install:** `pip install inspect-ai`
- **Usage:** Python-based eval definitions with built-in solvers and scorers
- **Scorers built-in:** model-graded, pattern match, includes, accuracy
- **Output:** rich logs with per-sample detail

**When to use:** safety-focused evals, complex multi-step agent evaluations.

### Framework selection rule

The Step-Researcher picks the framework in `knowledge.md` based on:
1. **Language match:** Python project → deepeval or hand-rolled pytest. JS/TS project → promptfoo or hand-rolled vitest.
2. **Eval complexity:** 1–3 criteria → hand-rolled. 4+ criteria or needing structured reporting → framework.
3. **Existing test runner:** prefer the framework that integrates with what's already in `tech-stack.md`.
4. If unsure, default to hand-rolled. It's always available and has zero dependency cost.

## Evaluator-specific rules

### `llm-as-judge`
- **Pin the judge model** to a dated version (e.g., `claude-sonnet-4-6-20250514`, `gpt-4o-2024-08-06`). Unpinned aliases (`claude-sonnet-4-6`, `gpt-4o`) drift across API updates and silently change eval scores.
- **The judge prompt is code.** Version-control it. Include it in the RED commit. Changes to the judge prompt after RED require re-confirming RED.
- **The judge must return structured output** (JSON with score + reasoning). Do not parse free-text scores with regex — use the model's structured output mode or a strict JSON format instruction.
- **The judge model should differ from the target model** when possible. Self-judging (target model grades its own output) inflates scores. Use a different model or at minimum a different system prompt.
- **Cost:** each eval case = 1 target call + 1 judge call. At N=10 cases, that's 20 API calls per full run. Budget accordingly.

### `schema-check`
- Use `jsonschema` (Python) or `ajv` (JS) — both free, battle-tested.
- The schema is committed in the RED commit. It IS the evaluator.
- This is a deterministic assertion on non-deterministic output. Each individual check is pass/fail, but you need N runs because the LLM might produce valid JSON 9/10 times.

### `semantic-match`
- **Use free local embedding models** — no API cost:
  - Python: `sentence-transformers` (`all-MiniLM-L6-v2` is fast and good enough for eval)
  - JS/TS: `@xenova/transformers` (ONNX runtime, runs locally)
- Do NOT use paid embedding APIs for eval scoring. The eval infrastructure must not add per-run cost beyond the target model call.
- Cosine similarity is the standard metric. Thresholds are domain-specific but ≥0.8 is a reasonable starting point.

### `regex-match`
- Pure string/regex assertions. No LLM or embedding cost.
- The patterns are committed in the RED commit.
- Same N-sample logic as schema-check: each check is pass/fail, threshold is "X% of N runs must match."

### `threshold`
- For numeric metrics (latency, token count, cost-per-call, accuracy).
- The measurement function is committed in the RED commit.
- Thresholds are from the eval-spec's performance budgets.

## Non-deterministic TDD cycle (detailed)

This is the expanded version of the cycle from `pipeline/07-execute-step.md`. The Coder reads this section instead of the brief pointers in that file.

### RED phase (odd sub-tasks)

1. **Write the eval harness.** Create a test file with:
   - Eval dataset (test cases with inputs + references)
   - Evaluator function (matching the eval-spec's type)
   - Eval runner function (the test the runner executes)
   - Pass threshold and sample size as constants, matching eval-spec
2. **Run the eval.** It MUST fail. Expected failure modes:
   - `ImportError` / `NameError` — target function doesn't exist yet. Most common at RED.
   - Target returns empty/stub → evaluator scores 0 → below threshold.
   - If the eval passes: the eval is vacuous, the behavior already exists, or the assertion is tautological. Investigate before proceeding.
3. **Commit.** Message: `eval: [description] (red — not yet implemented)`.

### GREEN phase (even sub-tasks)

1. **Write the implementation** — prompt, chain, agent, or model call. Minimum viable.
2. **Smoke run (N=1–3).** Quick check that the basic flow works. Not a pass/fail gate.
3. **Iterate.** Tune prompt, adjust chain logic, fix output parsing. Run smoke after each change.
4. **Full run (N=eval-spec sample size).** The official gate. Must meet or exceed the pass threshold.
   - If it fails: improve the implementation. Do NOT lower the threshold.
   - If borderline: run one more full batch. Log both results.
   - If unreachable after 3+ full-run attempts: halt and report to orchestrator. The threshold may need revision — but that's a design decision (Architect's job), not a Coder decision.
5. **Regression check.** Run previously-passing tests/evals.
6. **Commit.** Message: `feat: [description] (green — evals pass, [pass_rate])`. Include the pass rate in the commit message.

### Hard rules (non-deterministic specific)

- **Evals must be automated.** No human scoring. An `llm-as-judge` eval calls the judge model programmatically.
- **Evals must be reproducible enough to trust.** Flaky at N=5 → increase N. The eval-spec sample size is a minimum, not a cap.
- **The Coder does NOT own the threshold.** The Architect set it in the eval-spec. The Coder implements to meet it. If it's wrong, that's a design issue — raise it, don't change it.
- **Eval infrastructure has zero added subscription cost.** Only the LLM API calls themselves (target + judge) cost money. Frameworks, embedding models, and scoring logic are free/local/open-source.
- **Separate eval code from application code.** Eval harnesses live in test directories. Judge prompts, schemas, and eval datasets are test fixtures. They do not ship to production.
