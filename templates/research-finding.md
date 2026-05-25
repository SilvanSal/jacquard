---
id: RF-[YYYY-MM-DD]-[NNN]
title: "[descriptive title — what was found, not what was searched for]"
date: YYYY-MM-DD
stage: "01"
author: domain-researcher

category: [one of the categories below]
# Categories:
#   algorithmic-constraint    — problem taxonomy, complexity class, required algorithm family
#   data-model                — non-obvious entity relationships, cardinality surprises, schema constraints
#   performance-cliff         — algorithmic complexity transitions, resource limits, scaling walls
#   processing-pipeline       — required ordering of stages, normalization/validation prerequisites
#   interop-standard          — mandated formats, protocols, handshake sequences, version constraints
#   failure-mode              — categories of failure requiring structurally different recovery paths
#   regulatory                — legal, compliance, certification, audit trail requirements
#   ux-pattern                — domain-specific interaction conventions, user mental models
#   security                  — attack surfaces, threat models, required mitigations specific to this domain
#   competitive-intel         — what competitors do, their tradeoffs, gaps in the market
#   domain-concept            — foundational concept the team must understand to build correctly

confidence: [one of the levels below]
# Confidence levels:
#   established    — consensus across 3+ independent sources, peer-reviewed or industry standard
#   corroborated   — 2 independent sources agree, or 1 authoritative source (RFC, spec, official docs)
#   single-source  — 1 credible source, not independently verified
#   contested      — sources disagree; both positions documented
#   unverified     — plausible but no authoritative source found; flagged for user confirmation

relevance: [one of the levels below]
# Relevance to the software being built:
#   critical       — ignoring this finding would produce a fundamentally broken design
#   significant    — affects architecture or major design decisions
#   contextual     — useful background; does not directly constrain design but informs tradeoffs

architectural-impact: [true/false — does this finding constrain or shape the software's structure?]

supersedes: []          # list of RF-IDs this finding replaces (e.g., [RF-2026-05-20-001])
related: []             # list of RF-IDs with related findings
intake-qa-ref: []       # which intake Q&A answers this finding relates to (e.g., [Q1, Q3])
domain-md-section: []   # which sections of domain.md this maps to (e.g., [4, 7])
tags: []                # free-form tags for grep-based discovery (e.g., [redis, session-store, ttl])

status: active
# Status:
#   active         — current and load-bearing
#   superseded     — replaced by a newer finding (see supersedes field on the replacement)
#   retracted      — found to be incorrect; retraction reason in body
#   pending-review — surfaced but not yet confirmed by user
---

# RF-[YYYY-MM-DD]-[NNN]: [Title]

## Summary
[2–3 sentences. What was found and why it matters for this project. A downstream agent reading only this paragraph should know whether to read further.]

## Source chain

Primary sources are authoritative origins. Corroborating sources independently confirm. Dissenting sources present alternative views. Every claim in "Detailed analysis" must trace to at least one source here.

### Primary
- **[Source title]** — [URL]
  - Type: [peer-reviewed paper | RFC/spec | official docs | industry report | blog/article | first-hand observation]
  - Accessed: YYYY-MM-DD
  - Key contribution: [1 sentence — what this source uniquely provides]

### Corroborating
- **[Source title]** — [URL]
  - Agrees with: [which primary source claim]
  - Key addition: [what new evidence or angle this adds]

### Dissenting (if any)
- **[Source title]** — [URL]
  - Disagrees with: [which claim]
  - Their position: [1 sentence]
  - Evidence quality vs. primary: [stronger / weaker / comparable, and why]

## Detailed analysis

The substance of the finding. Structure by sub-questions or sub-topics as needed. Every factual claim cites a source from the chain above using `[Source title]` inline references.

### [Sub-topic or question]
[Analysis with inline source citations]

### [Sub-topic or question]
[Analysis with inline source citations]

## Evidence quality assessment

| Dimension | Rating | Reasoning |
|---|---|---|
| Source diversity | [high/medium/low] | [How many independent sources? Are they from different communities?] |
| Recency | [current/aging/stale] | [When was the evidence produced? Is the domain fast-moving?] |
| Reproducibility | [verified/plausible/untested] | [Can the claims be independently verified? Were experiments reproduced?] |
| Applicability | [direct/analogous/distant] | [How closely does the evidence's context match our project?] |

## Architectural implications

_Only present if `architectural-impact: true` in frontmatter._

For each implication, use the structured format from domain.md Section 7:

### Implication 1: [short title]
- **Source finding:** [Which sub-topic above, with source citation]
- **What it means for the software:** [Structural consequence — not "use X library" but "the system needs a Y stage/component/routing mechanism because Z"]
- **Design constraint introduced:** [Specific constraint the Architect must respect — e.g., "data must be normalized before comparison", "routing layer must classify input before dispatching to algorithm-specific handlers"]
- **If ignored:** [What breaks — not vague "bad things" but specific failure mode]

### Implication 2: [short title]
[Same structure]

## Constraints introduced

Explicit constraints this finding creates for downstream stages. Each constraint names WHO is constrained and HOW.

| Constraint | Affects stage | Affects role | Detail |
|---|---|---|---|
| [e.g., "Input must be normalized to Unicode NFC before comparison"] | 04, 07 | Architect, Coder | [Why: source X showed that NFD/NFC mismatch causes false negatives in Y% of cases] |

## Open threads

Research questions this finding raises that have NOT been answered yet. Each should be actionable — either the researcher will pursue it in the next loop iteration, or it should be surfaced to the user.

- [ ] [Open question] — _priority: [high/medium/low]_ — _action: [research next / ask user / defer to Stage 06]_
- [ ] [Open question] — _priority: [high/medium/low]_ — _action: [research next / ask user / defer to Stage 06]_

## Cross-references

- **Intake Q&A:** [Which questions/answers this finding connects to, e.g., "Q3 — user chose option B (single-region). This finding shows single-region is sufficient for the compliance requirement."]
- **Constitution:** [Which non-negotiables or integration context this finding relates to]
- **Related findings:** [RF-IDs with 1-sentence explanation of the relationship, e.g., "RF-2026-05-20-003 (performance cliff in the same algorithm family)"]
- **Error registry / hallucination traps:** [If this finding should seed either, note it here. The researcher creates the entry separately.]
