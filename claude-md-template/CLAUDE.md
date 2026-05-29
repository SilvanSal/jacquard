# CLAUDE.md — [Project Name]

> This is the top-level pointer every Claude Code session reads first. It is deliberately short. It points to the three files that carry the project's conventions: `tech-stack.md`, `code-style.md`, `best-practices.md`.
>
> This project was bootstrapped from the Agentic Coding Pipeline. The pipeline's rules (research before code, vertical slices, fresh context per step, handoff-not-transcript) are enforced by `.claude/` hooks and agents.

## For every session, before writing code

Read, in this order:
1. This file (`CLAUDE.md`).
2. `tech-stack.md` — what you're allowed to use.
3. `code-style.md` — how to write.
4. `best-practices.md` — how "done" is defined.

Then read the current slice's step-spec, knowledge.md, and previous slice's handoff.md as directed by the orchestrator prompt.

## Read-access lists (enforced)

Your role determines what you read. Do not read outside your list. If you need something outside the list, stop and ask the orchestrator.

Each agent's full read-list lives in its own `.claude/agents/[name].md` definition (the `Reads` / `Does not read` / `Grep-only` sections). Short version:

- **Researchers** read constitution + research artifacts. Not best-practices or code-style.
- **Coders** read step-spec + knowledge + handoff + triad (tech-stack / code-style / best-practices). Not domain research, not prior slices' knowledge.
- **Reviewers** read only what their review needs. Code-Reviewer sees the diff, not the design.

## Hard rules for every session

1. **Never write application code without a step-spec.** If there isn't one, stop and raise it.
2. **Never skip the review cluster.** Every slice goes through code + security review, and browser verification if UI-visible.
3. **The orchestrator auto-advances after each slice's handoff.md is written.** No manual session restart needed — the orchestrator continues to the next slice (or stage 10 if final). The only exception is context overflow, which triggers a continuation file.
4. **No backwards-compat shims, no "just in case" code, no `// removed` comments, no dead flags.** Delete decisively.
5. **Commit after every sub-task** with the message format in `best-practices.md`.
6. **Pin versions.** Never silently upgrade a dependency past what `tech-stack.md` lists.

## Project-specific overrides

[Any project-specific rule that overrides a default in the triad. Keep this list short — if it grows, move the rule into the relevant triad file.]

- [Override, if any]

## Links

- Constitution: `specs/constitution.md`
- Tech stack: `tech-stack.md`
- Code style: `code-style.md`
- Best practices: `best-practices.md`
- Features: `specs/[feature]/...`
