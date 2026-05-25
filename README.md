# Jacquard

![Jacquard Loom — every thread precisely routed](assets/banner.jpg)

An AI coding pipeline for projects where getting the domain wrong means building the wrong thing.

Drop your materials. The agent reads the papers, designs the architecture, builds test-first, and iterates with you — without losing its place, without hallucinating domain knowledge, and without one agent's context bleeding into another's.

Named after the first programmable machine, the [Jacquard](https://en.wikipedia.org/wiki/Jacquard_machine) loom (1804) — every agent precisely routed, like every thread on the loom.

---

## Get Started

Open a Claude Code session in the Jacquard folder and say `Go`. The orchestrator takes it from there — welcomes you, explains the process in plain language, and waits for you to drop materials in `input/` before beginning.

---

## What the Pipeline Does

### Phase 1 — Understand

An intake agent reads everything in `input/` (PDFs, briefs, wireframes, specs, competitor analyses), synthesizes a structured brief, and asks you the questions that would materially change the architecture. Domain research is then grounded in your actual gaps — papers read in full, every source traced for architectural implications. The agent loops back to you whenever it finds something that needs your input. If you have a domain expert who isn't at the keyboard, the pipeline generates questionnaire rounds they can answer on their own time — each round triggers deeper follow-up research based on their answers.

### Phase 2 — Design

Three or more candidate architectures enumerated and rejected or selected with explicit rationale. Requirements, evaluation criteria, and a vertical slice plan. Optional architect Q&A gate for decisions that hinge on your intent. You approve the plan before any code gets written.

### Phase 3 — Build

One slice at a time. Step-level research, TDD implementation, parallel code and security review, handoff written. Auto-advance to the next slice. Repeat until the feature ships.

### Phase 4 — Iterate

After shipping, you stay in a loop. Describe bugs, refinements, or new features — the agent triages each:

- **Patch** — 1–2 files. Execute, review, done.
- **Enhancement** — extends existing functionality. Full slice: research, build, review, handoff.
- **New feature** — un-researched domain surface. Re-enters the full pipeline from research or design.

When something goes wrong, you describe what you're seeing and the agent handles it — checks the error registry for known patterns, triages, fixes, gets it reviewed. If what it ships doesn't match what you meant, you say so and it course-corrects. You're always in the feedback loop, never stuck doing the debugging yourself.

Say `done` when you're finished.

---

## Why Jacquard

### It actually reads the literature

Scientific papers, competitor analyses, API docs, wireframes — drop them in `input/` before you start. The pipeline reads everything, synthesizes a structured brief, and asks you the 5–10 questions that would send the architecture in different directions if answered differently. Domain research is then targeted at *your* gaps, not a generic survey. The agent surfaces what it finds as it goes — you redirect, correct, or confirm, and it adjusts its research based on your feedback. This loops until the domain is genuinely understood, not just skimmed. Newly discovered insights accumulate in `input/research-findings/` across the whole project.

### It adapts to who you are

Not every pipeline operator is a developer. At the start, Jacquard profiles who's running it — developer, product owner, or domain expert working asynchronously — and adjusts every interaction accordingly. A domain expert gets jargon-free questionnaire rounds they can answer over email. A product owner approves plans and makes feature decisions without ever seeing a diff. A developer gets the full technical depth. The welcome flow, research conversations, clarification questions, and iteration loop all adapt to the operator's role. You don't need to be technical to use this.

### Agent isolation is enforced at runtime, not on the honor system

Every subagent gets a fresh context window with only the files it's allowed to see. A researcher never sees code style rules. A coder never sees raw research papers. Twelve specialized roles, each with an enforced read-list — enforced by a runtime hook (`restrict-reads.sh`) that checks the filesystem, not by asking the agent to behave. No context pollution, no attention drift, no hallucinations from stale information bleeding across stages.

### The architect has to justify its choices

Before writing a single design decision, the architect enumerates at least three candidate architectures with explicit tradeoffs — latency, cost, operational complexity, scalability ceiling. It picks one and documents why the others were rejected. If any architectural decision genuinely hinges on your intent rather than known tradeoffs, it pauses and asks you — up to three targeted A/B/C/D questions. You approve the plan before any code gets written.

### TDD with a review cluster that can block

Every slice is built test-first. Evaluation criteria and pass/fail conditions exist before the first line of implementation. After each slice, a code reviewer and a security reviewer run in parallel in separate fresh contexts — neither can see the other's verdict. Either can block. If blocked, the coder fixes and the review reruns. Nothing advances on a block verdict.

### It notices when the codebase drifts

Between slices, humans edit the repo. Before each new slice, the pipeline diffs the repository against the prior slice's known-touched files and surfaces anything that changed outside that scope. You choose: absorb the drift (re-run codebase research scoped to the changed files), ignore it (logged as a known delta for the next researcher), or handle the revert yourself. No silent staleness.

### It never loses your place

If Claude's context window fills mid-pipeline, the orchestrator writes a `specs/.pipeline-state/continue.md` file — current stage, current slice, exact dispatch prompt for the next step — and stops cleanly. Start a fresh session, reference that file, and the new orchestrator picks up exactly where the old one left off. You should never have to manually figure out where the pipeline was.

### You stay in the loop — not in the weeds

The agent doesn't disappear into a black box. During research, it surfaces findings incrementally and asks before going deeper — you redirect, correct, or confirm at every turn. If you have a separate domain expert, the pipeline generates structured questionnaire rounds and incorporates their answers with targeted follow-up research. During building and debugging, the agent does the work — but you're always in the feedback loop. If something doesn't look right, you say so and it course-corrects. The pipeline handles the complexity; you steer the direction.

### The pipeline learns from itself

After each feature ships, a Pipeline-Critic agent reviews the pipeline's own behavior — friction points, routing gaps, stages that ran longer than expected — and offers to submit that data back to the community. Nothing proprietary leaves your machine. The critique data is what improves this repo over time.

---

## Built For

**Deep domain complexity** — projects where the domain has academic literature, regulatory constraints, or domain-specific algorithms that an AI will hallucinate if it doesn't actually read the sources first.

Compliance engines. Medical device controllers. Financial modeling tools. Scientific data pipelines. Bioinformatics tooling. Signal processing systems.

**Not for** throwaway scripts, simple CRUD apps, or "build a todo app faster."

---

## Under the Hood

**Runtime access enforcement.** The read-access matrix is enforced by shell hooks at every tool call — not merely described to agents as guidelines. An agent denied a file gets a clear error, not a hallucination.

**Error registry + hallucination traps.** Two project-scoped memory files: one for bugs with recurrence tracking (the step-researcher checks these before writing new code), one for known wrong patterns in your domain (seeded from research, grown by the coder). Mistakes don't repeat across slices.

**Version-based knowledge staleness.** Research findings in `knowledge.md` are invalidated when a library's pinned version changes in `tech-stack.md` — not by a 90-day timestamp. The step-researcher explicitly searches for migration guides and breaking changes between the old and new version.

**Touched-files tracking.** After each sub-task commit, the coder appends modified files to `specs/.../touched-files.txt`. The pre-slice drift check uses this file, not orchestrator memory — making drift detection deterministic across session boundaries.

**Session log.** Every pipeline session appends one line to `session-log.md` — stage, slice, status, review verdict, handoff path. A returning orchestrator reads the last entry before doing anything.

**Pipeline versioning.** Generated projects carry a `pipeline-version` in `settings.json`. A version check fires at the start of each new feature. `CHANGELOG.md` documents every behavioral change with a flag for whether target projects should update.

---

## Directory Layout

```
Jacquard/
├── README.md                     # this file
├── 00-START-HERE.md              # orchestrator entrypoint
├── input/                        # drop your materials here (PDFs, briefs, wireframes, specs)
│   └── README.md
├── pipeline/                     # ordered stage instructions
│   ├── 00-constitution.md
│   ├── 00.5-intake-reader.md
│   ├── 01-research-domain.md
│   ├── 02-research-codebase.md
│   ├── 03-clarify.md
│   ├── 04-requirements-design.md
│   ├── 04.5-phase-planning.md
│   ├── 05-plan-slices.md
│   ├── 06-research-step.md
│   ├── 07-execute-step.md
│   ├── 08-review.md
│   ├── 09-write-handoff.md
│   ├── 10-pipeline-critique.md
│   └── 11-iteration-loop.md
├── templates/                    # skeleton artifacts filled in by each stage
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
├── docs/decisions/               # architecture decision records for the pipeline itself
└── bootstrap/
    └── generate-claude-scaffolding.md   # meta-step: copies agents/ into .claude/ and substitutes tokens
```

---

## Community

After each feature ships, the agent offers to share pipeline friction data with the community — say `yes` and it handles the submission. Nothing proprietary leaves your machine.

[View submitted critiques](https://github.com/SilvanSal/jacquard/issues?q=label%3Acritique) | [Questions & discussion](https://github.com/SilvanSal/jacquard/discussions)
