# Stage 01 — Domain Research

**Run by:** `Domain-Researcher` subagent (fresh context, read-only tools + WebSearch/WebFetch + browser tools)
**Reads:** user brief, `specs/constitution.md`
**Produces:** `specs/research/domain.md` · optionally seeds `specs/research/hallucination-traps.md` and creates an empty `specs/error-registry.md`

## Purpose

Understand the domain the app lives in *deeply* before designing. This is NOT tech-stack research. It is: what do real users in this space do today? What prior art exists (open-source, commercial, academic)? What are the known failure modes, UX conventions, and regulatory quirks? **What does the research literature reveal about problem structure, complexity classes, or algorithmic approaches that would constrain or shape the software architecture?**

This stage is intentionally thorough. The Domain-Researcher should spend significant time reading, following references, and building genuine understanding. A shallow skim that produces bullet points is a failure. The output should demonstrate that the researcher *understood* the material, not just found it.

## Interaction model

The Domain-Researcher may (and should) engage the human in extended back-and-forth during this stage. Research is not a one-shot operation. Examples of when to pause and ask the human:

- A competitor app requires a paid subscription or login — ask the human if they have access or can provide feedback on the tool's behavior.
- A paper references a concept or technique the researcher doesn't fully understand — ask the human if they can clarify or if the researcher should do additional reading.
- The researcher found something architecturally significant and wants to confirm the human considers it relevant before going deeper.
- The research is branching into multiple promising directions and the researcher needs the human to prioritize.

**Do not rush.** A thorough 45-minute research session with 3–4 human check-ins is far more valuable than a 5-minute skim.

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
8. **Open questions for the user** — numbered A/B/C/D format. These feed directly into stage 03.

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

## Rules for this stage

- **Do not propose an architecture.** That is stage 04's job. However, you MUST extract and document architectural *implications* from research — facts and findings that will constrain or shape the architecture. There is a critical difference: "use a microservices architecture" is proposing architecture (forbidden); "the literature identifies 4 complexity classes requiring different algorithms, which implies a routing stage" is extracting an implication (required).
- **Do not pick a tech stack.** That is stage 04's job.
- **Do not write code or pseudocode.**
- **Cite sources.** Every claim about a competitor, a paper, or a regulation must have a URL. Unsourced claims get deleted by the reviewer.
- **Pin timestamps.** At the top of the file, write `Research pass: [YYYY-MM-DD]`. Domain research ages — downstream stages decide whether to trust or refresh.
- **Use browser tools actively** for competitor UX study and free tool exploration. Do not just read about tools — use them.
- **Ask the human when blocked.** If a tool requires paid access, if a concept is unclear, or if the research is branching — pause and ask. Extended back-and-forth is expected and encouraged.
- **Read papers thoroughly.** "URL + one-paragraph distillation" is insufficient. Every significant paper gets a detailed multi-paragraph summary. Follow up on unfamiliar concepts.
- **Extract architectural implications.** Every source (paper, competitor, specification) should be examined for findings that would constrain or shape the software's structure. Document these explicitly in section 7.

## Orchestrator dispatch prompt (copy verbatim)

> You are the Domain-Researcher subagent. You have a fresh context window. Read ONLY these files: `specs/constitution.md`, and the user's original brief (attached below).
>
> Your job: produce `specs/research/domain.md` following the structure in `pipeline/01-research-domain.md`. Read that pipeline file carefully — it contains detailed protocols for deep paper reading, active tool usage, architectural implication extraction, and human interaction.
>
> **Key expectations:**
> - You MUST actually use browser tools to click through freely-accessible competitor products. If a product requires paid access, ask the human.
> - You MUST read papers thoroughly (full text, not just abstracts), summarize them in detail, and follow up on concepts you don't understand with additional research.
> - You MUST extract architectural implications from every source — findings that constrain or shape the software's structure (problem taxonomies, complexity classes, required processing stages, data model constraints, etc.).
> - You SHOULD engage the human in extended back-and-forth when you need access, clarification, or prioritization guidance. This is not a one-shot task.
>
> You may use WebSearch, WebFetch, and browser tools. You may NOT propose an architecture, pick a tech stack, or write code.
>
> While researching, if you encounter 1–5 well-documented wrong-pattern/right-pattern pairs for this domain (each with a source URL), seed `specs/research/hallucination-traps.md` from `templates/hallucination-traps.md` with one row per confirmed pair. Do not invent traps. Regardless of whether traps are found, also create `specs/error-registry.md` from `templates/error-registry.md` as an empty registry for the Coder to grow later.
>
> When you are done, output the file paths (including the two optional seeds) and a 5-bullet summary of the key findings, plus a separate summary of architectural implications discovered. Stop.

## Stop condition

File `specs/research/domain.md` exists, has all 8 sections filled or explicitly marked "none identified" with reasoning, every factual claim has a source URL, and the timestamp is at the top. Section 4 (academic prior art) contains detailed multi-paragraph summaries for each significant paper — not just one-line distillations. Section 7 (architectural implications) is present and non-empty for any domain with research literature. `specs/error-registry.md` exists (empty or with the delete-me example). `specs/research/hallucination-traps.md` exists if 1–5 documented traps were found; otherwise is skipped with a one-line reason in the Domain-Researcher's output.
