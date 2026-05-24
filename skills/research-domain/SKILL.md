---
name: research-domain
description: Use when the user is starting a new feature and no `specs/research/domain.md` exists yet. Invokes the Domain-Researcher subagent to deeply survey prior art (reading papers in full, not abstracts), actively use competitor tools via browser, extract architectural implications from research, and engage the human in extended dialogue. Runs after `specs/constitution.md` is committed, before stage 03 (clarify).
allowed-tools: Read, Grep, Glob, WebSearch, WebFetch, Write, browser tools
---

# research-domain — Stage 01

## When to trigger
- `specs/constitution.md` exists.
- `specs/research/domain.md` does NOT exist (or is stale — see refresh policy below).
- User has asked to start a new feature OR explicitly invoked this skill.

## Do not trigger
- If `specs/research/domain.md` exists and is < 90 days old.
- If this is a tech-stack question (that's stage 04's job).
- If the user wants to go straight to design — route them to clarify (stage 03) instead and raise that domain research is missing.

## Produces
`specs/research/domain.md` with 8 sections: problem framing, current solutions survey, user workflows, academic/technical prior art (detailed deep reading), known failure modes, regulatory/legal surface, architectural implications extracted from research, open questions (A/B/C/D format for stage 03).

Also:
- Always creates an empty `specs/error-registry.md` from `templates/error-registry.md` for the Coder to grow during Stage 07.
- Optionally seeds `specs/research/hallucination-traps.md` from `templates/hallucination-traps.md` with 1–5 rows ONLY if well-documented wrong-pattern/right-pattern pairs surface during research (each with a source URL). Do not invent traps.

## Rules
- Do not propose architecture or tech stack. But DO extract architectural implications from research (there is a critical difference — see pipeline/01-research-domain.md).
- Every factual claim has a source URL; unsourced claims are deleted.
- Timestamp at top: `Research pass: [YYYY-MM-DD]`.
- Papers must be read in full and summarized in detail (multi-paragraph, not one-line distillations). Follow up on unfamiliar concepts with additional research.
- Freely-accessible competitor tools must be used first-hand via browser tools. Subscription-gated tools: ask the human.
- Architectural implications must be explicitly extracted and documented in section 7.
- Extended human interaction is expected and encouraged — ask the human when blocked on access, unsure about concepts, or when research is branching.

## Dispatch the Domain-Researcher subagent (verbatim)

> You are the Domain-Researcher subagent. Fresh context window. Read ONLY these files: `specs/constitution.md`, and the user's original brief (attached below).
>
> Produce `specs/research/domain.md` following the structure in `pipeline/01-research-domain.md`. Read that pipeline file carefully — it contains detailed protocols for deep paper reading, active tool usage, architectural implication extraction, and human interaction.
>
> **Key expectations:**
> - You MUST actually use browser tools to click through freely-accessible competitor products. If a product requires paid access, ask the human.
> - You MUST read papers thoroughly (full text, not just abstracts), summarize them in detail (minimum 1 page per significant paper), and follow up on concepts you don't understand with additional research.
> - You MUST extract architectural implications from every source — findings that constrain or shape the software's structure (problem taxonomies, complexity classes, required processing stages, data model constraints, performance cliffs, etc.).
> - You SHOULD engage the human in extended back-and-forth when you need access, clarification, or prioritization guidance. This is not a one-shot task. Do not rush.
>
> You may use WebSearch, WebFetch, and browser tools. You may NOT propose an architecture, pick a tech stack, or write code.
>
> If 1–5 well-documented wrong-pattern/right-pattern pairs surface during research (each with a source URL), seed `specs/research/hallucination-traps.md` from `templates/hallucination-traps.md` with one row per confirmed pair. Do not invent traps. Regardless, also create `specs/error-registry.md` from `templates/error-registry.md` as an empty registry for later growth.
>
> When done, output all file paths and a 5-bullet summary of key findings, PLUS a separate summary of architectural implications discovered. If hallucination-traps was skipped, state the reason in one line. Stop.

## Stop condition
`specs/research/domain.md` exists, has all 8 sections filled (or explicitly "none identified" with reasoning), timestamp at top, every factual claim sourced. Section 4 (academic prior art) contains detailed multi-paragraph summaries — not one-line distillations. Section 7 (architectural implications) is present and non-empty for any domain with research literature. `specs/error-registry.md` exists (empty or with the delete-me example). `specs/research/hallucination-traps.md` exists if 1–5 documented traps were found; otherwise skipped with a one-line reason in the output. Then the orchestrator proceeds to stage 03 (clarify).
