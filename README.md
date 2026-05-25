# Jacquard
![Jacquard Loom — every thread precisely routed](assets/banner.jpg)

Research-first AI coding pipeline for complex domains. Drop your materials, say "Ready", and the pipeline researches, designs, builds, reviews, and iterates — with you in the loop at every decision point.

---

## How It Works

An orchestrator agent runs **12 stages** in sequence. Each stage dispatches a fresh subagent with isolated context and a narrow read-list. You never `/clear` or manually advance — the orchestrator auto-chains everything.

```
00   Constitution         → project rules locked
00.5 Intake Reader        → reads your materials, asks targeted questions
01   Domain Research      → deep iterative research (papers, tools, APIs)
02   Codebase Discovery   → CLAUDE.md + tech-stack + code-style
03   Clarify              → back-and-forth with you until "Go"
04   Requirements/Design  → requirements.md + design.md + eval-spec.md
05   Plan Slices          → vertical slice plan (you approve)
─── per slice ───────────────────────────────────────────────────
06   Step Research        → step-spec + knowledge for this slice
07   Execute (TDD)        → code + tests + commits
08   Review Cluster       → code review + security review (parallel)
09   Handoff              → handoff.md → auto-advance to next slice
─── after final slice ───────────────────────────────────────────
10   Pipeline Critique    → self-critique + offers to share findings
11   Iteration Loop       → you describe changes, pipeline triages:
                            patch / enhancement / new feature
```

The iteration loop runs until you say "done."

---

## Quick Start

### 1. Drop your materials

Place project briefs, PDFs, wireframes, specs, research — anything — into:

```
input/          ← your materials go here (optional, pipeline will ask what it needs)
```

### 2. Start the pipeline

Open Claude Code in your target project directory and reference the entrypoint:

```
@00-START-HERE.md
```

The pipeline greets you, explains what to expect, and asks you to say "Ready."

### 3. Answer questions, approve gates

The pipeline pauses at human gates:

| Gate | What happens | You do |
|------|-------------|--------|
| Intake Q&A | Pipeline asks 5–10 targeted questions | Answer them |
| Clarify | Pipeline presents A/B/C/D choices | Pick answers, say "Go" |
| Slice plan | Pipeline shows the build plan | Approve or adjust |
| Block verdict | Reviewer blocks a slice | Pipeline fixes, re-reviews |

Between gates, everything auto-advances.

### 4. Iterate after shipping

After the feature ships, you stay in the **iteration loop**. Describe bugs, refinements, or new features — the orchestrator triages each into the right track and executes it. Say "done" when finished.

### 5. Context overflow

If the context window fills, the orchestrator writes a continuation file:

```
specs/.pipeline-state/continue.md
```

Start a fresh session, `@`-reference that file, and it picks up exactly where it left off.

---

## Pipeline Files

```
Jacquard/
├── 00-START-HERE.md              # orchestrator entrypoint
├── input/                        # your project materials
├── pipeline/                     # stage instructions (00–11)
├── templates/                    # artifact skeletons (research findings, specs, handoffs)
├── agents/                       # subagent definitions (one per role)
├── skills/                       # SKILL.md per stage (copied to .claude/skills/ at bootstrap)
├── claude-md-template/           # CLAUDE.md triad for the target project
├── bootstrap/                    # generates .claude/ scaffolding in the target repo
└── PIPELINE_IMPROVEMENT_CRITIQUE/  # stage 10 output (one per feature)
```

---

## Key Principles

| # | Principle | What it means |
|---|-----------|--------------|
| 1 | Research before code | No `Write`/`Edit` until research + design are committed |
| 2 | Deep reading, not skimming | Papers read in full, competitors used hands-on, implications traced |
| 3 | Human in the loop | Pipeline pauses at gates — your judgment is a load-bearing input |
| 4 | Fresh context per stage | Each subagent gets a clean window + narrow read-list |
| 5 | Vertical slices | Every slice ships end-to-end behavior, not layers |
| 6 | Auto-advance | Orchestrator chains stages — you never manually continue |
| 7 | Handoff is the handoff | Next coder reads only `handoff.md`, not prior code/specs |
| 8 | Reviewers don't edit | They write verdicts — the Coder patches |
| 9 | Evals before code | Pass/fail criteria exist before implementation starts |

---

## Read-Access Matrix

Each subagent reads only what its job requires. Enforced by stage markers + runtime hooks.

| Agent | constitution | domain-research | tech-stack | code-style | best-practices | step-spec | knowledge | prev-handoff | diff | eval-spec | repo | error-registry | hallucination-traps |
|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| Intake-Reader | v | — | — | — | — | — | — | — | — | — | input/ (R) | — | — |
| Domain-Researcher | v | — | — | — | — | — | — | — | — | — | findings (W+index) | writes (empty seed) | writes (optional seed) |
| Codebase-Explorer | v | — | — | — | — | — | — | — | — | — | v (read-only) | — | — |
| Architect | v | v | v | — | — | — | — | — | — | — | findings/INDEX (R) | — | — |
| Slice-Planner | v | — | v | — | — | — | — | — | — | v | — | — | — |
| Step-Researcher | v | — | v | — | — | v | grep | — | — | — | findings/INDEX (grep) | grep | grep |
| Coder | v | — | v | v | v | v | v | v | — | — | v (scoped paths) | grep + append | grep + append |
| Code-Reviewer | — | — | — | v | v | v | — | — | v | v (test-name column only) | — | — | — |
| Security-Reviewer | v | — | — | — | — | — | — | — | v | — | — | — | — |
| Browser-Verifier | — | — | — | — | — | — | — | — | — | v | running app | — | — |
| Handoff-Writer | — | — | — | — | — | v | — | — | v | v | — | — | — |
| Pipeline-Critic | — | — | — | — | — | — | — | — | — | v | — | grep | — |

---

## Built For

**Deep domain complexity** — projects where getting the domain wrong means building the wrong thing.

Compliance engines. Medical device controllers. Financial modeling tools. Scientific data pipelines. If your project has academic literature, regulatory constraints, or domain-specific algorithms — this is for you.

## Not For

- Throwaway scripts, one-file tools, prototypes with <2 hours of work
- Exploratory research code where the goal is learning, not shipping
- "Build a todo app faster" — there are better tools for that

---

## Community

After each feature ships, the pipeline critiques itself and offers to share findings with the community. Say "yes" and the agent submits a GitHub Issue on your behalf — zero copy-paste, zero leaving your terminal.

**What gets shared:** quality signal counts, instruction gaps, suggestions. Pipeline friction data only.
**What does NOT get shared:** your code, business logic, client names, architecture. Nothing proprietary leaves your machine.

[View submitted critiques](https://github.com/SilvanSal/jacquard/issues?q=label%3Acritique) | [Pipeline questions](https://github.com/SilvanSal/jacquard/discussions)
