---
name: eval-harness
description: Sub-skill of execute-step. Read ONLY when the step-spec contains non-deterministic TDD pairs (marked `RED — eval`). Provides the Coder with eval harness structure, free framework options, evaluator patterns, and the non-deterministic Red-Green cycle. Skip entirely for purely deterministic slices.
allowed-tools: Read, Grep, Glob, Write, Edit, Bash, WebSearch, WebFetch
---

# eval-harness — Stage 07a (conditional)

## When to trigger
- The step-spec for the current slice contains at least one sub-task marked `(RED — eval)`.
- The eval-spec for the feature has at least one non-deterministic evaluator type (`llm-as-judge`, `schema-check`, `semantic-match`, `regex-match`, `threshold`).

## Do not trigger
- Every sub-task in the step-spec is deterministic (plain `RED` / `GREEN` with unit/integration tests).
- The slice has no LLM-based or AI-powered code.

## What it provides
The full non-deterministic TDD mechanics that the Coder needs to write and run eval harnesses. This is a reference read, not a separate execution — the Coder reads it alongside its normal stage-07 inputs and applies the rules during execution.

## Coder reads (in addition to normal stage-07 reads)
- `pipeline/07a-eval-harness.md` — the full reference doc

## Key rules (summary — full details in pipeline doc)
- **Eval harness = 4 parts:** eval dataset (test cases), evaluator function (scorer), eval runner (test function), smoke/full run protocol.
- **Free tools only.** Eval frameworks and scoring infrastructure must be open-source / free. The only cost is the LLM API calls themselves (target + judge).
- **Framework options:** hand-rolled (always available), promptfoo (JS/TS), deepeval (Python/pytest), Inspect AI (safety evals). The Step-Researcher picks the framework in `knowledge.md`.
- **Pin the judge model.** Dated version strings only — no unpinned aliases.
- **Smoke vs. full run.** Iterate with N=1–3. Full sample only for GREEN confirmation.
- **Coder does not own the threshold.** Meet it or raise to orchestrator. Never lower it.
- **Local embeddings for semantic-match.** Use `sentence-transformers` (Python) or `@xenova/transformers` (JS). No paid embedding APIs.

## Dispatch addition (append to Coder dispatch prompt when triggered)

> **This slice has non-deterministic eval criteria.** Also read `pipeline/07a-eval-harness.md` before starting any `(RED — eval)` sub-task. It covers: eval harness structure (dataset, evaluator, runner, smoke/full protocol), free framework options, evaluator-specific rules (judge pinning, local embeddings, schema validation), and the detailed non-deterministic Red-Green cycle. Apply its rules alongside the deterministic TDD rules from `pipeline/07-execute-step.md`.
