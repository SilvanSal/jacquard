# Stage 04 — Requirements, Design, Eval Spec

**Run by:** `Architect` subagent (fresh context, read-only + Write for the three output files)
**Reads:** `specs/constitution.md`, `specs/research/domain.md`, `specs/clarify-[feature].md`, `tech-stack.md` (if filled)
**Produces:** `specs/[feature]/requirements.md`, `specs/[feature]/design.md`, `specs/[feature]/eval-spec.md`

## Purpose

Translate research + clarifications into three named artifacts. Each has a different reader: requirements is for humans (to sign off), design is for Slice-Planner and Coder, eval-spec is for Reviewer cluster.

## The three files (Kiro-style split)

### `requirements.md`
- User stories in the form: `As a [role], I want [capability], so that [outcome]`.
- Acceptance criteria per story in bullet form. Testable. No vague words like "fast" without a number.
- Non-functional requirements (performance targets, accessibility, i18n, security posture).
- Explicit non-requirements ("this feature does NOT handle X").
- Use `templates/requirements.md` as the skeleton.

### `design.md`
- Architecture diagram (ASCII or mermaid) — components and their connections.
- Data model — entities, fields, relationships. Migration path if applicable.
- API surface — endpoints, request/response shapes, auth model. For non-HTTP, equivalent contract.
- Key sequence flows for 2–4 core user actions.
- Tech-stack choices, with reasoning per choice. If tech-stack.md is already filled, reuse; if not, fill it in and also update `tech-stack.md` in the project root.
- Rejected alternatives — 2–3 options considered and why they lost. This is for future readers.
- Use `templates/design.md` as the skeleton.

### `eval-spec.md`
- Per user-story, a list of testable pass criteria. Each criterion has an **evaluator** — either deterministic or non-deterministic:
  - **Deterministic evaluators** (for code with predictable outputs): `unit test`, `integration test`, `browser verifier`, `manual`.
  - **Non-deterministic evaluators** (for LLM-based / AI code where outputs vary): `llm-as-judge`, `schema-check`, `semantic-match`, `regex-match`, `threshold`.
- **Deterministic criteria:** a **named test signature** (one line, no code) encoding the black-box behavior: `test_upload_rejects_files_over_10mb` for pytest, `uploadRejectsFilesOver10MB()` for vitest.
- **Non-deterministic criteria:** a **named eval signature**, plus a **pass threshold** (e.g., "≥4/5 judge score", "100% schema valid", "≥0.85 cosine similarity") and a **sample size** (how many runs to evaluate, e.g., N=10). The Architect defines what "pass" means quantitatively — not vague ("good quality") but measurable ("judge rates ≥4/5 on rubric R in 8/10 runs").
- The Architect classifies each criterion independently. A single feature can mix both types.
- Architect does NOT write test/eval files. Names only. File paths, fixtures, eval harnesses, and actual bodies are decided by the Step-Researcher and written by the Coder.
- The Code-Reviewer in Stage 08 checks that each named test/eval exists in the diff for the slice that owns the criterion.
- Regression criteria — list of previously-shipped slices whose behavior must not change when this feature lands.
- Performance budgets if applicable.
- Security checks required for this feature (e.g., "auth-free routes must not leak PII").
- Use `templates/eval-spec.md` as the skeleton.

## Rules for this stage

- **Respect the clarify answers literally.** If the user chose option B, design for option B. Do not silently upgrade to option C because it's "better".
- **Respect the constitution's non-negotiables.** If a design choice violates a non-negotiable, stop and raise it — do not design around it without explicit user override.
- **Design one feature at a time.** If the project has 5 features, run stage 04 five times. Do not produce a monolithic design covering everything.
- **Reject features that weren't clarified.** If the user didn't answer questions about a capability, do not design it. Surface it as a gap.
- **Link, don't copy.** The design references the clarify file and constitution by path, not by copy-pasting their contents.
- **The eval-spec must be written *before* Slice-Planner runs.** Slice-Planner reads eval-spec to shape slices around testable outcomes.
- **Name tests, do not write them.** Architect lists one test signature per test-evaluated criterion. No test files, no fixtures, no skeleton code. The Coder writes test bodies in Stage 07; the Code-Reviewer then verifies each named test exists in the diff.

## Orchestrator dispatch prompt (copy verbatim)

> You are the Architect subagent. Fresh context window. Read these files in this order: `specs/constitution.md`, `specs/research/domain.md`, `specs/clarify-[feature].md`, `tech-stack.md` (if it exists and is not `_TBD_`).
>
> Your job: produce three files under `specs/[feature]/` — `requirements.md`, `design.md`, `eval-spec.md` — using the skeletons in `templates/`. You may also update `tech-stack.md` in the project root if it was deferred from stage 02. You may NOT read `specs/research/domain.md` sections beyond what you've already read, propose slices, or write application code.
>
> When done, output the three file paths and a 3-bullet summary of the key design decisions. Stop.

## Stop condition

All three files exist under `specs/[feature]/`, are committed, and each section of each template is either filled or explicitly marked as a gap. `tech-stack.md` is no longer `_TBD_`.
