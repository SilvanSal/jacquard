# Handoff: Slice [ID]

_Feature: [feature-slug] · Slice: [S0N] · Written: [YYYY-MM-DD] · Word budget: 200–600_

> **Read this instead of the full slice history.** The next slice's Coder reads this file; they do not read the step-spec, knowledge, or diff of this slice.
> **Author:** Handoff-Writer subagent (not the Coder).

## What shipped

[1 paragraph — user-visible outcome. What can the user do now that they couldn't before? Reference eval criteria by ID.]

**Eval criteria green (deterministic):** [E-XX.Y, E-XX.Z — all tests pass]
**Eval criteria green (non-deterministic):** [E-XX.A — 9/10 runs ≥4/5 (threshold: 8/10)]
**Eval criteria still red:** [E-XX.W, if any, with reason]
**Eval criteria untested:** [IDs, if any]

## Names the next slice will type

Public surface introduced by this slice. Names only — not explanations.

- Modules: `src/path/module.ext`, `src/other/file.ext`
- Functions: `functionName(arg1, arg2)`, `anotherFn()`
- Env vars: `ENV_VAR_NAME`, `OTHER_VAR`
- DB tables / columns: `table_name(col1, col2)`
- API routes: `POST /api/path`, `GET /api/other`

## Decisions that affect downstream

Choices made during this slice that weren't in the step-spec but will constrain future work. Each cited to a commit.

- [Decision] — [commit SHA or path]
- [Decision] — [commit SHA or path]

## Gotchas the next slice should know

Things that bit us or will bite the next Coder. Specific.

- [Gotcha with a concrete pointer]
- [Gotcha with a concrete pointer]

## Micro-research corrections

Factual contradictions between this slice's `knowledge.md` and observed library behavior, found via the Coder's bounded micro-research. Update `knowledge.md` patterns here so the Step-Researcher can correct future `knowledge.md` files.

| Blocker | Query | Answer (2–4 lines) | Source URL | In-scope adjustment |
|---|---|---|---|---|
| | | | | |

## Review notes carried forward

Non-blocking findings from `review.md` that the next slice should honor.

- [Note] — `review.md` section

## Out of scope surfaced but not done

Items discovered during this slice that belong in future slices, not this one.

- [Item] — [which future slice, or "unplanned"]

## Open risks

- [Risk that is now known but unresolved]

## Links (for debugging, not for the next Coder to read routinely)

- Step spec: `specs/[feature]/slices/[N]/step-spec.md`
- Knowledge: `specs/[feature]/slices/[N]/knowledge.md`
- Review: `specs/[feature]/slices/[N]/review.md`
- Commits: [SHA1 (RED)], [SHA2 (GREEN)], [SHA3 (RED)], [SHA4 (GREEN)]
