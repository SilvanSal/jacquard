# Stage 08 — Review Cluster

**Run by:** Two subagents in parallel (all fresh context, read-only):
  - `Code-Reviewer`
  - `Security-Reviewer`
**Reads:** see per-reviewer read-lists below
**Produces:** `specs/[feature]/slices/[N]/review.md` (aggregated verdict)

> **Browser-Verifier does NOT run per slice.** UI evaluation happens once, at end-of-feature, after the last UI-touching slice lands. See `## End-of-feature UI verification` below. Per-slice UI sanity is covered by the Coder's own local dev-run and by automated tests named in `eval-spec.md`. Running Chromium per slice is expensive, context-heavy, and its output churns while the UI is still in flux.

## Purpose

Catch problems the Coder missed. Two narrow reviewers with differentiated reads beat one generalist reviewer. They run in parallel. Each produces a short verdict. The orchestrator aggregates them into one `review.md` and decides whether to advance.

## Code-Reviewer

**Reads:** `code-style.md`, `best-practices.md`, `specs/[feature]/slices/[N]/step-spec.md`, `specs/[feature]/eval-spec.md` (only the `Test name` column rows for criteria this slice owns), the git diff for this slice's commits.
**Does not read:** constitution, design, knowledge.md, any other slice's files.
**Checks:**
- Does the code follow `code-style.md`? Naming, imports, file organization.
- Does it follow `best-practices.md`? Error handling, logging, test coverage.
- Does the diff match the step-spec's file list? Deviations flagged.
- Are there obvious bugs, race conditions, unhandled error paths, or dead code?
- Any `TODO` / `FIXME` / `_removed` / commented-out-code left behind?
- Are tests added for new code? Do they actually test the new behavior?
- **Named-test/eval presence:** every criterion in `eval-spec.md` owned by this slice whose `Test name` is filled must have a test or eval with that exact name in the diff. Missing named test/eval = `block`.
- **TDD commit discipline:** commits must follow the Red-Green pattern. RED commits (`test:` or `eval:` prefix) contain only test/eval code. GREEN commits (`feat:` prefix) contain only implementation code. Each GREEN must be preceded by a RED whose tests/evals it satisfies. Missing or out-of-order RED/GREEN pairing = `warn`.
- **Non-deterministic eval quality:** for `eval:` commits, verify the eval harness includes: evaluator function matching the eval-spec type, pass threshold matching eval-spec, sample size ≥ eval-spec minimum, and pinned judge model (if `llm-as-judge`). Missing any of these = `warn`.
**Output format:** verdict = `pass` / `pass-with-notes` / `block`, followed by a numbered list of issues. Each issue has severity (`block` / `warn` / `nit`) and a file:line reference. `block` and `warn` issues MAY include a **suggested-fix snippet** when the fix is obvious and local — see rules below. Suggestions are text only; the Coder writes the actual patch.

**Suggested-fix rules (Code-Reviewer only):**
- Local: edits one function or one block. No whole-file rewrites.
- Minimal: smallest diff that resolves the issue. No opportunistic cleanup.
- Text only: a fenced code block with the replacement snippet plus a one-line pointer to where it goes. Not an applied patch.
- Omit when not confident — a `warn` without a suggestion is fine.
- Never attach a suggestion to a `nit`.
- The Coder reads suggestions as input, not as authority — they may write a different fix if they see a better one, and must explain the deviation.

## Security-Reviewer

**Reads:** `specs/constitution.md`, the git diff for this slice's commits.
**Does not read:** style/best-practices, step-spec, design, knowledge.
**Checks (diff-scoped only):**
- Injection surfaces introduced (SQL, command, HTML, JSON).
- Secrets or credentials committed.
- Auth / authz changes — are they consistent with the constitution's security posture?
- Input validation at trust boundaries.
- Dependency changes — any added package with known CVEs at the pinned version? (Use WebSearch.)
- Logging of sensitive data.
**Output format:** verdict = `pass` / `block`, followed by numbered findings with CVSS-style severity (`critical` / `high` / `medium` / `low`) and diff location.

## Aggregation

Orchestrator reads both verdicts and writes `specs/[feature]/slices/[N]/review.md`:

```
## Code-Reviewer: [verdict]
[issues]

## Security-Reviewer: [verdict]
[findings]

## Orchestrator decision
- [ ] Advance to stage 09 (Handoff-Writer)
- [ ] Return to stage 07 (Coder) with fixes required
- [ ] Escalate to user (design-level issue surfaced)
```

**Advance only if:** both verdicts are `pass` or `pass-with-notes`. Any `block` or `fail` returns to stage 07 with the specific findings attached.

## End-of-feature UI verification

**Runs once per feature**, after the final UI-touching slice's handoff is written — not per slice. Produces `specs/[feature]/ui-verification.md`.

**Runs only if:** the feature has user-visible UI AND the Chromium/Preview MCP tools are available AND the app has a runnable dev server.
**Reads:** `specs/[feature]/eval-spec.md` (all UI-evaluator criteria), the running app at its dev URL.
**Does not read:** code, diffs, step-specs, knowledge, handoffs.
**Checks:**
- Golden path for every eval-spec criterion whose evaluator is "browser verifier".
- 2–3 named edge cases per criterion from the eval-spec.
- Cross-slice regression — confirm earlier slices still behave per their criteria.
**Output format:** verdict = `pass` / `partial` / `fail` / `inconclusive`, per-criterion results quoting the criterion text and the observed behavior. Flag inconclusives; do not force a verdict.
**On fail/partial:** orchestrator opens a remediation slice (run stages 05–09 for it). Do not patch code from the verification session.

## Rules for this stage

- **Parallel dispatch.** Fire both reviewers in one message. Do not run them sequentially — you waste latency and they have no dependencies.
- **Reviewers do not talk to each other.** Each writes its own verdict. The orchestrator aggregates.
- **Do not spawn Browser-Verifier here.** UI verification is deferred to end-of-feature. If a reviewer or the orchestrator is tempted to run Chromium mid-build, stop and revisit — the pipeline explicitly defers it.
- **Reviewers cannot edit code.** Read-only only. Fixes are the Coder's job in a return-to-07 loop.
- **Reviewers cannot expand scope.** A Code-Reviewer that finds a pre-existing bug outside the diff writes it as a `nit` but does not block.
- **Do not let reviewers auto-fix.** The separation between write (Coder) and review (cluster) is load-bearing. Suggested-fix snippets are text, read by the Coder — they are never applied by the reviewer or by the orchestrator.

## Orchestrator dispatch prompts

**Code-Reviewer:**
> You are the Code-Reviewer subagent. Fresh context, read-only. Read: `code-style.md`, `best-practices.md`, `specs/[feature]/slices/[N]/step-spec.md`, and the git diff for commits `[SHAs]`. Output verdict + numbered issues per `pipeline/08-review.md`. For `block` or `warn` issues, you may include a minimal, local suggested-fix snippet (text only — the Coder writes the actual patch). Never for `nit`. Stop.

**Security-Reviewer:**
> You are the Security-Reviewer subagent. Fresh context, read-only. Read: `specs/constitution.md` and the git diff for commits `[SHAs]`. You may use WebSearch for CVE checks on any added dependencies. Output verdict + numbered findings per `pipeline/08-review.md`. Stop.

**Browser-Verifier (end-of-feature only — do NOT dispatch per slice):**
> You are the Browser-Verifier subagent. Fresh context, no file reads except `specs/[feature]/eval-spec.md`. You have access to the Chromium/Preview MCP tools. The dev server is at `[URL]`. The feature is complete: exercise every UI-evaluator criterion, 2–3 edge cases each, and regression-check earlier criteria. Output `specs/[feature]/ui-verification.md` with verdict + per-criterion results per `pipeline/08-review.md`. If anything is inconclusive, say so. Stop.

## Stop condition

`specs/[feature]/slices/[N]/review.md` exists with both reviewer verdicts and an orchestrator decision checked. End-of-feature UI verification runs once after the final UI slice lands and produces `specs/[feature]/ui-verification.md`.
