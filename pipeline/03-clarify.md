# Stage 03 — Clarify

**Run by:** Orchestrator in the main session, with the user in the loop. NOT a subagent — this stage requires real-time interaction.
**Reads:** `specs/constitution.md`, `specs/research/domain.md`, the open questions section from stage 01
**Produces:** `specs/clarify-[feature].md` — a transcript of questions and the user's decisions

## Purpose

Collapse the ambiguity uncovered in stages 00–02 into explicit user decisions before the Architect designs anything. This is the single most important gate in the pipeline. Skipping it forces the Architect to guess, which produces designs that look plausible but don't match user intent.

## Adapting to the human profile

Check `specs/constitution.md` § "Human profile" before generating questions.

- **Domain expert inline or developer:** All questions go to the person at the keyboard. Standard behavior.
- **Domain expert async:** Many domain decisions may already be answered in `specs/research/expert-answers-R*.md` and confirmed via `specs/research/expert-summary.md`. Before generating your clarify questions:
  1. Read all `specs/research/expert-answers-R*.md` files and `specs/research/expert-summary.md`.
  2. For each question you would normally ask: check whether the expert already answered it. If yes, pre-fill the answer with a citation (`"Answered by domain expert in R1 Q3: [answer]"`) and do NOT re-ask it.
  3. Remaining questions split into two categories:
     - **Domain questions the expert didn't cover** — if the expert is still reachable, the operator can relay these. Flag them as `[expert-needed]`.
     - **Technical questions** (deployment target, API style, performance targets) — ask the pipeline operator directly. These are developer decisions, not domain decisions.
  4. If the pipeline operator is not the domain expert AND the operator cannot answer domain questions, record `"deferred — no domain expert available for this question"` so the Architect knows it was unresolved.

## The A/B/C/D format (non-negotiable)

Every question you ask must:

1. Be **numbered**.
2. Present **2–4 concrete, mutually exclusive options** labeled A/B/C/D. Never ask open-ended questions like "what do you want?".
3. Include a **"recommend"** marker on the option you would pick, with one-sentence reasoning.
4. Allow **"other: [user-supplied text]"** as an implicit fifth option.

### Example

```
1. Authentication model
   A. Email + password, no third-party
   B. Email + password plus Google/GitHub OAuth  [recommend: standard for SaaS, low friction]
   C. Passwordless magic-link only
   D. Enterprise SSO (SAML/OIDC) only
   Other: _______

2. Data residency
   A. Single region (US)                         [recommend: simplest, matches constitution's non-goal of multi-tenant]
   B. Single region (EU)
   C. Multi-region with per-user pinning
   Other: _______
```

The user replies "1B, 2A, 3-other: something custom". You record their reply verbatim in `specs/clarify-[feature].md`.

## How many questions

- Target: 5 to 12 questions per clarify session. Fewer than 5 means you missed ambiguities; more than 12 exhausts the user.
- Prioritize questions that materially change the Architect's output. Skip questions the constitution already answers.
- Group related questions (auth + session storage + password reset all in one auth block).

## What to ask about

In rough order of priority:
1. User-facing behavior at key decision points (auth model, pricing model, sharing model, offline behavior).
2. Data model shape — what are the core entities, what do they relate to?
3. Integration context (if not fully covered in the constitution) — upstream data sources, downstream consumers, data formats the app must ingest or produce (HL7, IFC, CSV schemas, proprietary exports, etc.), existing systems it must coexist with (legacy DBs, corporate SSO, shared infrastructure). The app rarely exists in a vacuum — the Architect needs to know what surrounds it.
4. Deployment target — web only? mobile? desktop? CLI? On-prem vs cloud vs local machine?
5. Performance / scale targets — rough order of magnitude (10 users vs 10k vs 10M).
6. Anything the domain research flagged as contentious in the "Open questions" section.

## Rules for this stage

- **Do not answer questions on the user's behalf.** If the user is not responsive, halt and wait. A clarify session without the user is worthless.
- **Do not let the user skip to design.** If they say "just build something", you respond with the A/B/C/D list anyway and note that they need to pick. If they refuse, record the refusal explicitly in the clarify doc so the Architect knows what was guessed.
- **Record decisions in the order asked**, not rearranged. Future stages reference by question number.
- **One clarify doc per feature**, not per project. If the project has multiple features, each gets its own clarify + requirements + design trio.

## "Go" gate

After the user has answered every question (or explicitly deferred), write the file and present a summary:

> I have recorded [N] decisions in `specs/clarify-[feature].md`. Next stage is 04 (Architect produces requirements + design + eval-spec). Respond with **"Go"** to proceed, or raise any concerns.

Do not dispatch the Architect until the user says "Go" (or equivalent explicit approval).

## Stop condition

`specs/clarify-[feature].md` exists with all questions, all recommendations, and all user answers (including "other:" or explicit deferrals). User has typed "Go".
