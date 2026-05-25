# Jacquard
![Jacquard Loom — every thread precisely routed](assets/banner.jpg)

Research-first AI coding pipeline for complex domains. Drop your materials and the agent handles everything — researching, designing, building, reviewing, and iterating with you.

---

## Why Jacquard

**Deep domain research, not skimming.** Scientific papers read in full. Every source traced for architectural implications. The agent loops back to you when it finds something that needs your input — no fixed round limit, just depth until the domain is actually understood.

**Hyper-precise context routing.** Every subagent gets a fresh context window with only the files it needs — a researcher never sees code style rules, a coder never sees raw research papers. Twelve specialized roles, each with an enforced read-list. No context pollution, no confusion, no hallucinations from stale information bleeding across stages.

**Professional TDD infrastructure.** Every slice is built test-first with a separate review cluster — code reviewer and security reviewer running in parallel, each in their own fresh context. Evals are written before code. Pass/fail criteria exist before the first line is implemented. The reviewer can block, and the coder has to fix it before anything advances.

---

## Get Started

Open a Claude Code session in the Jacquard folder and say "Go." The agent takes it from there.

---

## Directory Layout

```
Jacquard/
├── README.md                     # this file
├── 00-START-HERE.md              # entrypoint the orchestrator reads first
├── input/                        # user-supplied project materials (briefs, PDFs, wireframes, specs)
│   └── README.md
├── pipeline/                     # ordered stage instructions
│   ├── 00-constitution.md
│   ├── 00.5-intake-reader.md
│   ├── 01-research-domain.md
│   ├── 02-research-codebase.md
│   ├── 03-clarify.md
│   ├── 04-requirements-design.md
│   ├── 05-plan-slices.md
│   ├── 06-research-step.md
│   ├── 07-execute-step.md
│   ├── 08-review.md
│   ├── 09-write-handoff.md
│   ├── 10-pipeline-critique.md
│   └── 11-iteration-loop.md
├── templates/                    # skeleton artifacts the stages fill in
│   ├── constitution.md
│   ├── intake-brief.md
│   ├── intake-qa.md
│   ├── research-finding.md       # rich schema for each research insight (YAML frontmatter + source chain)
│   ├── research-findings-index.md # auto-maintained index with filter tables + dependency graph
│   ├── requirements.md
│   ├── design.md
│   ├── eval-spec.md
│   ├── slice-plan.md
│   ├── step-spec.md
│   ├── knowledge.md
│   ├── handoff.md
│   ├── error-registry.md         # project-scoped bug memory, empty-seeded at stage 01, grown by Coder
│   ├── hallucination-traps.md    # project-scoped wrong/right-pattern lookup, optionally seeded at stage 01
│   └── pipeline-critique.md      # post-feature critique skeleton for stage 10
├── claude-md-template/           # target-project conventions (CLAUDE.md triad)
│   ├── CLAUDE.md
│   ├── tech-stack.md
│   ├── code-style.md
│   └── best-practices.md
├── skills/                       # pre-authored SKILL.md per stage — copied into .claude/skills/ at bootstrap
│   ├── intake-reader/SKILL.md
│   ├── research-domain/SKILL.md
│   ├── research-codebase/SKILL.md
│   ├── clarify/SKILL.md
│   ├── requirements-design/SKILL.md
│   ├── plan-slices/SKILL.md
│   ├── research-step/SKILL.md
│   ├── execute-step/SKILL.md
│   ├── review/SKILL.md
│   └── write-handoff/SKILL.md
├── agents/                       # pre-authored subagent definitions — copied into .claude/agents/ at bootstrap
│   ├── intake-reader.md
│   ├── domain-researcher.md
│   ├── codebase-explorer.md
│   ├── architect.md
│   ├── slice-planner.md
│   ├── step-researcher.md
│   ├── coder.md
│   ├── code-reviewer.md
│   ├── security-reviewer.md
│   ├── browser-verifier.md
│   ├── handoff-writer.md
│   └── pipeline-critic.md
├── PIPELINE_IMPROVEMENT_CRITIQUE/  # post-feature critiques — stage 10 output, one per feature
│   └── README.md
└── bootstrap/
    └── generate-claude-scaffolding.md   # meta-step: copies skills/ + agents/ into .claude/ and substitutes tokens
```

---

## What the Pipeline Does

### Phase 1 — Understand

The agent reads your materials, asks you targeted questions, then does deep domain research. Papers, tools, APIs, competitors — it digs until it actually understands the problem space. It loops back to you whenever it finds something that needs your input.

### Phase 2 — Design

Architecture, requirements, evaluation criteria, and a vertical slice plan. You approve the plan before any code gets written.

### Phase 3 — Build

One slice at a time — research the step, write code with tests, get it reviewed by separate agents (code + security), write a handoff, auto-advance to the next slice. Repeat until the feature ships.

### Phase 4 — Iterate

After shipping, you stay in a loop. Describe bugs, refinements, or new features — the agent triages each into the right track:

- **Patch** — small fix, 1–2 files. Execute, review, done.
- **Enhancement** — extends existing functionality. Full slice: research, build, review, handoff.
- **New feature** — un-researched domain surface. Re-enters the full pipeline from research or design.

Say "done" when you're finished.

---

## Built For

**Deep domain complexity** — projects where getting the domain wrong means building the wrong thing.

Compliance engines. Medical device controllers. Financial modeling tools. Scientific data pipelines. If your project has academic literature, regulatory constraints, or domain-specific algorithms — this is for you.

**Not for** throwaway scripts, simple CRUD apps, or "build a todo app faster."

---

## Community

After each feature ships, the agent offers to share pipeline friction data with the community — say "yes" and it handles the submission. Nothing proprietary leaves your machine.

[View submitted critiques](https://github.com/SilvanSal/jacquard/issues?q=label%3Acritique) | [Questions & discussion](https://github.com/SilvanSal/jacquard/discussions)
