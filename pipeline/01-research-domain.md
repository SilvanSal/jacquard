# Stage 01 — Domain Research

**Run by:** `Domain-Researcher` subagent (fresh context, read-only tools + WebSearch/WebFetch + browser tools)
**Reads:** `specs/intake-brief.md`, `specs/intake-qa.md`, `specs/constitution.md`
**Produces:** `specs/research/domain.md` · dated insight files in `input/research-findings/` · optionally seeds `specs/research/hallucination-traps.md` and creates an empty `specs/error-registry.md`

## Purpose

Understand the domain the app lives in *deeply* before designing. This is NOT tech-stack research. It is: what do real users in this space do today? What prior art exists (open-source, commercial, academic)? What are the known failure modes, UX conventions, and regulatory quirks? **What does the research literature reveal about problem structure, complexity classes, or algorithmic approaches that would constrain or shape the software architecture?**

This stage is intentionally thorough. The Domain-Researcher should spend significant time reading, following references, and building genuine understanding. A shallow skim that produces bullet points is a failure. The output should demonstrate that the researcher *understood* the material, not just found it.

Research is now **grounded in intake artifacts**. Read `specs/intake-brief.md` and `specs/intake-qa.md` first. Derive the research agenda from those files — do not do a generic domain scan.

## Research agenda (derived from intake artifacts)

Before forming any research queries, read `specs/intake-brief.md` and `specs/intake-qa.md`. Derive research targets from:

1. **Papers and products referenced** in `intake-brief.md` § "Referenced prior art" — fetch abstracts or full text where available
2. **Competitors or products named** in the intake materials — research their known tradeoffs and failure modes
3. **Technologies referenced** in the intake materials — look for migration guides, version pitfalls, known failure modes
4. **Conflicts identified** in `intake-brief.md` § "Identified conflicts" — research which side is correct or more current
5. **Unstated assumptions** in `intake-brief.md` § "Unstated assumptions" — research whether they hold in the target domain
6. **Architecturally consequential Q&A answers** in `intake-qa.md` — research the implications of the user's selected options

If `specs/intake-brief.md` does not exist (pipeline running without Stage 00.5), proceed with the user brief directly.

## Saving discovered insights

All newly discovered insights must be saved as **dated markdown files** in `input/research-findings/`:

```
input/research-findings/YYYY-MM-DD-[slug].md
```

Example: `input/research-findings/2026-04-30-competitor-stripe-analysis.md`

This is in addition to `specs/research/domain.md`. The `input/research-findings/` folder accumulates insights across the whole process, making them available to the Architect (Stage 04) directly from the `input/` tree.

Format for each research-findings file:
```markdown
# Research Finding: [Topic]
_Date: YYYY-MM-DD · Stage: 01 Domain Research_

## Summary
[2–3 sentences]

## Details
[Sourced findings — every claim has a URL]

## Architectural implications
[What this means for the software's structure, if anything]
```

## Interaction model — iterative research loop

Research is not a one-shot operation. The Domain-Researcher runs an **iterative loop**: research a thread, surface what you found and what new questions it raises, get the user's input, then research deeper based on their answers. Repeat until genuine understanding is reached.

```
┌─────────────────────────────────────────────────┐
│  Research a thread from the agenda               │
│  (papers, competitors, tools, standards)         │
└──────────────────────┬──────────────────────────┘
                       ▼
┌─────────────────────────────────────────────────┐
│  Surface findings + new questions to the user    │
│  "I found X, which suggests Y. Does that match  │
│   your experience? And should I dig into Z?"     │
└──────────────────────┬──────────────────────────┘
                       ▼
┌─────────────────────────────────────────────────┐
│  User answers / clarifies / redirects            │
└──────────────────────┬──────────────────────────┘
                       ▼
┌─────────────────────────────────────────────────┐
│  Deep follow-up research based on their answer   │
│  (new terms, standards, tools they named)        │
└──────────────────────┬──────────────────────────┘
                       ▼
              ◆ Understanding sufficient? ◆
              │ No → loop back to top     │
              │ Yes → write domain.md     │
              └───────────────────────────┘
```

**There is no fixed round limit.** The loop runs as many times as the domain requires. A simple CRUD app might need 1 round. A compliance engine or scientific data pipeline might need 5–8 rounds of progressively deeper research. The stop criterion is **genuine understanding**, not elapsed time.

### When to surface findings and ask

- You found something architecturally significant — confirm the user considers it relevant before going deeper.
- A paper references a concept or technique you don't fully understand — ask the user if they can clarify or if you should do additional reading.
- The research is branching into multiple promising directions — ask the user to prioritize.
- A competitor app requires a paid subscription or login — ask the user if they have access.
- You discovered something that contradicts what the user told you in intake — surface the contradiction and ask which is correct.
- A new term, standard, or regulation appeared that wasn't in the intake materials — confirm it's in scope before researching it deeply.

### What makes each round valuable

Each round should make the research **materially better**. If the user names a specific standard, regulation, or tool — research it thoroughly (same deep reading protocol as Section 4). If the user says "it depends on X" — research the X dimension. If the user corrects a finding — re-examine the source. The user's domain knowledge is a research accelerator, not a rubber stamp.

**Do not rush.** A thorough session with multiple check-ins is far more valuable than a quick skim. Do not batch all questions to the end — surface findings incrementally so the user can redirect early.

## Active tool usage

The Domain-Researcher must actively use the tools available to it, not just search and summarize:

- **Browser tools:** If a competitor product or relevant tool is freely accessible (free tier, demo, open-source), the researcher MUST actually navigate to it, click through the UI, and document the interaction pattern, UX friction points, and capabilities first-hand. Screenshots and step-by-step observations are far more valuable than marketing copy.
- **Subscription-gated tools:** If a tool requires a paid subscription, login, or sign-up that the researcher cannot complete, **stop and ask the human**. The human may already have access and can provide guided feedback, or may decide the tool isn't worth investigating.
- **WebFetch for papers:** When a paper is found, fetch the full text (not just the abstract). If the full text is behind a paywall, try alternative sources (arXiv, author's personal page, institutional repositories, Semantic Scholar). If truly inaccessible, note this and ask the human if they have access.

## What the Domain-Researcher must produce

Copy `templates/knowledge.md` layout (but save as `specs/research/domain.md`) and fill in the following sections:

1. **Problem framing** — 1 paragraph. What problem the app solves, stated in the user's words, not the product's.
2. **Current solutions survey** — at least 3 existing tools / products / approaches that address this problem. For each: URL, one-sentence description, what they do well, what they do badly. Prefer the 2–3 closest competitors over a wide survey. **If the tool is freely accessible, the researcher must actually use it** (see "Active tool usage" above) and document observations from first-hand interaction, not just website descriptions.
3. **User workflows observed** — describe how real users accomplish this task today, even if clumsily. The researcher MUST use browser tools to actually click through 1–2 competitor apps (if freely available) and record the interaction pattern step-by-step. If no free competitor is available, ask the human for guided walkthrough feedback.
4. **Academic / technical prior art** — see dedicated section below. This is not a bibliography — it is a deep reading exercise.
5. **Known failure modes** — what goes wrong for users of existing solutions? Security issues, UX frustrations, performance cliffs, data-loss patterns. 3–7 items.
6. **Regulatory / legal surface** — GDPR, COPPA, HIPAA, PCI, accessibility mandates, content moderation obligations. One paragraph or "none identified" with reasoning.
7. **Architectural implications extracted from research** — see dedicated section below. This is a critical new section.
8. **Open questions for the user** — numbered A/B/C/D format. These feed directly into stage 03. **Must include questions derived from architectural implications** (section 7). For every implication that involves a choice or scope decision, generate a clarify question so the Architect in Stage 04 gets the answer pre-resolved. Example: if the research finds "4 complexity classes each requiring different algorithms," the open questions must include something like "Which complexity classes does your use case require? A. Simple rule matching only. B. Rule matching + constraint propagation. C. All four classes. D. Unsure — need to support all as a safety net."

## Section 4 — Academic / technical prior art (deep reading protocol)

This section is NOT "URL + one-paragraph distillation each." The researcher must genuinely read and understand each source. For each paper, RFC, or technical specification:

1. **Read the full text** (or as much as is accessible). Do not stop at the abstract.
2. **Summarize in detail** (minimum 1 page per significant paper):
   - What problem does the paper address and why?
   - What methodology or approach does it propose?
   - What are the key results, metrics, or conclusions?
   - What are the stated limitations?
   - What datasets, benchmarks, or real-world systems were used for evaluation?
3. **Follow up on concepts you don't understand.** If the paper references a technique, algorithm, taxonomy, or framework that the researcher is not confident about, the researcher MUST do additional targeted research to understand it before summarizing. Do not gloss over unfamiliar concepts — they are often the most architecturally relevant.
4. **Extract cited references that seem relevant.** If the paper's bibliography points to foundational work that would deepen understanding, follow those references (up to 2–3 levels deep for truly important threads).
5. **Note disagreements across sources.** If two papers or approaches contradict each other, document both positions and the evidence for each.

Skip this section ONLY if the domain genuinely has no research literature (most CRUD apps). For any domain involving algorithms, data processing, compliance, NLP, ML, optimization, scheduling, or similar — there WILL be relevant literature. Search thoroughly before concluding "none."

**Search strategy for papers:** Don't rely on a single query. Try: Google Scholar, Semantic Scholar, arXiv, ACM Digital Library, IEEE Xplore, relevant conference proceedings. Vary search terms — the academic term for a concept often differs from the industry term.

## Section 7 — Architectural implications extracted from research

This is the most important new section. While reading papers, competitor documentation, and technical prior art, the researcher MUST actively look for information that has implications for the software's architecture. Examples of what to look for:

- **Problem taxonomies / complexity classes.** A paper might state that a domain has N distinct classes of problems, each requiring fundamentally different algorithmic approaches. This implies the software needs a routing/classification stage. (Real example: compliance checking literature identifies 4 complexity classes — simple rule matching, constraint propagation, model checking, and theorem proving — each requiring different algorithms. This means the architecture needs a complexity classifier that routes to different checking engines.)
- **Data model constraints.** Research might reveal that certain data relationships are non-obvious (e.g., a tree that is actually a DAG, a 1:1 relationship that is actually 1:N in edge cases).
- **Performance cliffs.** Literature might show that a seemingly linear algorithm becomes exponential beyond a certain input size, implying the need for tiered processing or early termination.
- **Required processing stages.** Papers might describe pipelines or processing stages that are necessary for correctness (e.g., normalization before comparison, tokenization before parsing).
- **Interoperability standards.** RFCs or specifications might mandate certain data formats, protocols, or handshake sequences.
- **Failure mode categories.** Research might enumerate categories of failures that the software must handle differently (not just "error handling" but structurally different recovery paths).

For each architectural implication found, document:
- **Source:** URL and specific section/page of the source.
- **Finding:** What was stated or demonstrated.
- **Implication:** What this means for the software's structure, not just its behavior.
- **Confidence:** How well-established is this finding? (Single paper vs. consensus across multiple sources.)

## Optional seed: hallucination-traps.md + empty error-registry.md

While surveying prior art and failure modes, the Domain-Researcher will occasionally discover *well-documented wrong-pattern/right-pattern pairs* — e.g., a BIM schema where `.FireRating` looks like an attribute but is actually inside a property set; a charting library whose default behaviour silently swallows NaN; a payment API whose `amount` field is in cents, not dollars.

If 1–5 such pairs surface during domain research, seed `specs/research/hallucination-traps.md` from `templates/hallucination-traps.md` and add one row per confirmed pair, each with a source URL. Do NOT invent traps — only include ones you ran into or found explicitly documented.

Regardless of whether traps exist, create `specs/error-registry.md` from `templates/error-registry.md` as an empty registry with the delete-me example intact. The Coder will grow it during execution.

Skip both seeds only if the domain has no known documented traps AND you cannot create the empty error-registry file for some reason (log why in your output).

## Domain-expert-async mode

**Applies when:** `specs/constitution.md` § "Human profile" has `domain-expert-async` set for domain expert availability. The pipeline operator (developer) is at the keyboard but a separate domain expert is not. The expert's input is gathered via questionnaire rounds that the operator relays.

### How it works

The Domain-Researcher runs a **multi-round loop**:

```
Round 0: Autonomous research (no expert input yet)
  - Do ALL research: papers, competitors, prior art, architectural implications
  - Identify what you're uncertain about, what requires domain confirmation
  - Decide how many questionnaire rounds are needed (see "Round budget" below)
  - Generate Round 1 questionnaire → specs/research/expert-questionnaire-R1.md

[PAUSE — operator sends questionnaire to expert, answers come back]

Round 1: Incorporate answers + targeted follow-up research
  - Read expert-answers-R1.md
  - Do DEEP follow-up research specifically based on answers
    (expert says "we use ISO 19650" → research ISO 19650 thoroughly)
  - Update domain.md with new findings
  - If more rounds needed: generate next questionnaire → expert-questionnaire-R2.md
  - If sufficient: produce summary for expert approval

[PAUSE — repeat if more rounds needed]

Final: Summary approval
  - Write a plain-language summary of all research findings and architectural implications
  - The operator relays this to the expert for approval
  - Expert confirms "yes, you got it right" or provides corrections
  - Finalize domain.md
```

### Round planning

Before generating the first questionnaire, the researcher must assess the domain's complexity and decide how to structure the rounds. There is no fixed round limit — **keep going until you genuinely understand everything you need.** A simple domain might need 1 round. A complex domain (compliance, medical, financial) might need 4-5.

After each round, the researcher evaluates: "Do I now understand the domain well enough that the Architect can design without guessing?" If no → generate another round with targeted follow-up questions informed by the latest answers and research. If yes → produce the summary for approval.

Guidelines for round structure:
- **Round 1:** Broad — cover the major domain areas, terminology, workflows, constraints.
- **Round 2+:** Targeted — dig into specifics surfaced by previous answers and the follow-up research they triggered.
- **Final round:** Confirmation — present your understanding back to the expert to catch misunderstandings.

State the current round count and what this round aims to clarify at the top of each questionnaire. Do not artificially limit rounds to save time — thoroughness is more important than speed.

### Questionnaire format

Each questionnaire is a standalone markdown file that can be printed, emailed, or read over a call. It must be understandable WITHOUT technical jargon — the expert is a domain person, not a developer.

```markdown
# Domain Expert Questionnaire — Round [N]
_Project: [name] · Date: [YYYY-MM-DD] · Estimated time: [X] minutes_
_Planned rounds: [N of M] · Why this round: [one sentence]_

## Context
[2-3 sentences: what we're building, what we've researched so far,
 what this round of questions is trying to clarify]

## Questions

### 1. [Topic — in domain language, not tech language]
**Why we're asking:** [The research finding or uncertainty that prompted this question]
**Background:** [What we found so far — enough that the expert can give an informed answer]

A. [Option — described in domain terms]
B. [Option — described in domain terms]  [recommend: reason]
C. [Option — described in domain terms]
Other: _______

[Space for free-text elaboration: "Please add any context we're missing:"]

### 2. ...

## If you have extra time
[2-3 open-ended prompts for bonus context the expert might volunteer:
 "Are there industry practices we haven't mentioned?"
 "What's the most common mistake newcomers to this domain make?"]
```

### What triggers follow-up research

When expert answers come back, the researcher does NOT just record them. It MUST do targeted deep research based on the answers:

- Expert names a specific standard, regulation, or tool → research it thoroughly (same deep reading protocol as Section 4)
- Expert says "it depends on X" → research the X dimension
- Expert corrects a research finding → re-examine the source, update domain.md
- Expert provides an answer the researcher didn't anticipate → assess whether it has architectural implications and update Section 7

This follow-up research is what makes multi-round questionnaires valuable — each round gets smarter because the researcher learns from the previous answers.

### Artifacts produced

In addition to the standard Stage 01 artifacts:
- `specs/research/expert-questionnaire-R[N].md` — one per round sent to the expert
- `specs/research/expert-answers-R[N].md` — the operator creates this file with the expert's answers (can be verbatim transcript, filled-in questionnaire, or summary notes)
- `specs/research/expert-summary.md` — final plain-language summary the expert approves before the pipeline proceeds

### Summary approval gate

After the last questionnaire round, the researcher produces `specs/research/expert-summary.md` — a plain-language summary of:
1. What we understand about the domain (key findings)
2. What architectural implications we extracted (phrased in domain terms, not tech terms)
3. What decisions the expert made and how they affect the software
4. What we're still uncertain about (if anything)

The operator relays this to the expert. The expert either approves or provides corrections. Only after approval does the pipeline proceed to Stage 03.

## Rules for this stage

- **Do not propose an architecture.** That is stage 04's job. However, you MUST extract and document architectural *implications* from research — facts and findings that will constrain or shape the architecture. There is a critical difference: "use a microservices architecture" is proposing architecture (forbidden); "the literature identifies 4 complexity classes requiring different algorithms, which implies a routing stage" is extracting an implication (required).
- **Do not pick a tech stack.** That is stage 04's job.
- **Do not write code or pseudocode.**
- **Cite sources.** Every claim about a competitor, a paper, or a regulation must have a URL. Unsourced claims get deleted by the reviewer.
- **Pin timestamps.** At the top of the file, write `Research pass: [YYYY-MM-DD]`. Domain research ages — downstream stages decide whether to trust or refresh.
- **Use browser tools actively** for competitor UX study and free tool exploration. Do not just read about tools — use them.
- **Run the iterative research loop** (inline mode) or **multi-round questionnaires** (async mode). In inline mode: research a thread, surface findings and new questions to the user, incorporate their answer, research deeper — repeat until genuine understanding is reached. There is no fixed round limit. In async mode: generate questionnaire rounds and do deep follow-up research after each answer set. Do not batch all questions to the end — surface findings incrementally.
- **Read papers thoroughly.** "URL + one-paragraph distillation" is insufficient. Every significant paper gets a detailed multi-paragraph summary. Follow up on unfamiliar concepts.
- **Extract architectural implications.** Every source (paper, competitor, specification) should be examined for findings that would constrain or shape the software's structure. Document these explicitly in section 7.
- **In async mode: do deep follow-up research after every answer round.** Do not just record answers — research what the expert told you. Each round should make the research materially better.

## Orchestrator dispatch prompt — inline mode (copy verbatim)

> You are the Domain-Researcher subagent. You have a fresh context window. Read ONLY these files: `specs/intake-brief.md`, `specs/intake-qa.md`, `specs/constitution.md`.
>
> Your job: produce `specs/research/domain.md` following the structure in `pipeline/01-research-domain.md`. Read that pipeline file carefully — it contains detailed protocols for deep paper reading, active tool usage, architectural implication extraction, and human interaction. **Start with the "Research agenda" section** — derive your research targets from the intake artifacts, not from a generic domain scan.
>
> **Key expectations:**
> - You MUST actually use browser tools to click through freely-accessible competitor products. If a product requires paid access, ask the human.
> - You MUST read papers thoroughly (full text, not just abstracts), summarize them in detail, and follow up on concepts you don't understand with additional research.
> - You MUST extract architectural implications from every source — findings that constrain or shape the software's structure (problem taxonomies, complexity classes, required processing stages, data model constraints, etc.).
> - You MUST run the iterative research loop: research a thread, surface findings + new questions to the user, incorporate their answer, research deeper based on what they told you, repeat. There is no fixed round limit — keep looping until you genuinely understand the domain. Surface findings incrementally, not all at the end.
> - You MUST save discovered insights as dated files in `input/research-findings/` per the format in `pipeline/01-research-domain.md`.
>
> You may use WebSearch, WebFetch, and browser tools. You may NOT propose an architecture, pick a tech stack, or write code.
>
> While researching, if you encounter 1–5 well-documented wrong-pattern/right-pattern pairs for this domain (each with a source URL), seed `specs/research/hallucination-traps.md` from `templates/hallucination-traps.md` with one row per confirmed pair. Do not invent traps. Regardless of whether traps are found, also create `specs/error-registry.md` from `templates/error-registry.md` as an empty registry for the Coder to grow later.
>
> When you are done, output the file paths (including the two optional seeds and all research-findings files) and a 5-bullet summary of the key findings, plus a separate summary of architectural implications discovered. Stop.

## Orchestrator dispatch prompt — domain-expert-async mode (copy verbatim)

> You are the Domain-Researcher subagent. You have a fresh context window. Read: `specs/intake-brief.md`, `specs/intake-qa.md`, `specs/constitution.md` (note the Human Profile section — this project has an async domain expert).
>
> Your job: produce `specs/research/domain.md` following the structure in `pipeline/01-research-domain.md`. Read that pipeline file's "Domain-expert-async mode" section carefully.
>
> **Round 0 (this invocation):** Do ALL autonomous research first — papers, competitors, prior art, architectural implications. Use the full deep reading protocol. Then:
> 1. Decide how many questionnaire rounds are needed based on the expert's time budget in the constitution.
> 2. Generate `specs/research/expert-questionnaire-R1.md` using the format in `pipeline/01-research-domain.md`. Questions must be in domain language, not tech jargon. Each question must include context (why we're asking) and background (what we found).
> 3. Write a preliminary `specs/research/domain.md` with what you know so far — mark sections where expert input is needed as `_PENDING EXPERT INPUT_`.
>
> Also seed `specs/error-registry.md` and optionally `specs/research/hallucination-traps.md` per standard protocol.
>
> Output all file paths and a summary of what the questionnaire covers and why. Stop and wait for expert answers.

## Orchestrator dispatch prompt — domain-expert-async follow-up round (copy verbatim)

> You are the Domain-Researcher subagent, follow-up round [N]. Fresh context. Read: `specs/constitution.md`, `specs/research/domain.md` (your prior draft), `specs/research/expert-answers-R[N-1].md` (the expert's latest answers).
>
> Your job:
> 1. Do DEEP targeted research based on the expert's answers. If the expert named a standard, regulation, or tool — research it thoroughly. If the expert corrected a finding — re-examine the source.
> 2. Update `specs/research/domain.md` — fill in `_PENDING EXPERT INPUT_` sections and add new findings from the follow-up research. Update Section 7 (architectural implications) if the answers revealed new structural constraints.
> 3. If more rounds remain: generate `specs/research/expert-questionnaire-R[N].md` with follow-up questions informed by the answers AND your new research.
> 4. If this is the last round: generate `specs/research/expert-summary.md` — a plain-language summary for expert approval.
>
> Output file paths and a summary of what changed. Stop.

## Stop condition

**Inline mode:** File `specs/research/domain.md` exists, has all 8 sections filled or explicitly marked "none identified" with reasoning, every factual claim has a source URL, and the timestamp is at the top. Section 4 (academic prior art) contains detailed multi-paragraph summaries for each significant paper — not just one-line distillations. Section 7 (architectural implications) is present and non-empty for any domain with research literature. `specs/error-registry.md` exists (empty or with the delete-me example). `specs/research/hallucination-traps.md` exists if 1–5 documented traps were found; otherwise is skipped with a one-line reason in the Domain-Researcher's output. Discovered insights are saved as dated files in `input/research-findings/`.

**Async mode:** All of the above, plus: at least one `expert-questionnaire-R[N].md` and corresponding `expert-answers-R[N].md` exist. `specs/research/expert-summary.md` exists and has been approved by the domain expert (operator confirms approval). No `_PENDING EXPERT INPUT_` markers remain in `domain.md`.
