# Agentic Coding Pipeline

A reusable, stage-gated playbook you hand to an LLM coding agent so it bootstraps a disciplined research-then-execute pipeline for a new app. Not a framework. Not a runtime. A set of linked Markdown instructions plus templates plus a bootstrap step that emits a project-specific `.claude/` scaffolding into the target repo.

## What this is

A **meta-pipeline**: the agent reads these files, runs them in order against a new project idea, and the output is (a) a filled-out `specs/` tree with research, requirements, design, eval specs, and vertical-slice plan, plus (b) a `.claude/` directory in the target project with skills, subagents, settings, and a `CLAUDE.md` triad that enforces the pipeline for every subsequent coding session.

## Guiding principles (non-negotiable)

1. **Research before code.** No `Write` / `Edit` calls until domain research, codebase discovery, requirements, design, and eval spec are committed.
2. **Fresh context per stage.** Every stage runs in a new subagent with narrow tool access and a specified read-list. No stage reads the whole prior history — it reads named artifacts.
3. **Plan one phase ahead, not the whole tree.** Vertical slices are planned coarse; the next slice's task breakdown is generated *after* the previous slice lands and its handoff is written.
4. **Vertical slices, not backend-first.** Every slice ships a thin end-to-end piece of user-visible behavior, verified per-slice by automated tests. Chromium browser verification runs once at end-of-feature, not per slice — running it mid-build burns tokens on UI that is still in flux.
5. **Stop-and-commit between steps.** Each executed step ends with a commit, a review cluster verdict, and a handoff written by a non-coder subagent. Then the session stops.
6. **The handoff is the handoff.** The next step's coder reads only the previous step's `handoff.md`, not the previous step's full spec or code.
7. **Differentiated reads per role.** A researcher does not read `best-practices.md`. A coder does not read raw domain research. See [read-access matrix](#read-access-matrix).
8. **Evals are per step, written before code.** Each step-spec carries pass/fail criteria. The reviewer cluster checks against them.
9. **Reviewer cluster is separate from executors.** Code review, browser verification, and security review are subagents with their own fresh context.

## How to use

1. Open a fresh Claude Code session in the target project directory (empty repo or greenfield).
2. Paste or `@`-reference `00-START-HERE.md` from this pipeline directory.
3. Follow the prompts. The pipeline is gated — the agent will stop and ask for input at each clarifying gate.
4. Final output: a `specs/` directory + a `.claude/` directory in the target project.

## Directory layout

```
Agentic_Coding_Pipeline/
├── README.md                     # this file
├── 00-START-HERE.md              # entrypoint the orchestrator reads first
├── pipeline/                     # ordered stage instructions
│   ├── 00-constitution.md
│   ├── 01-research-domain.md
│   ├── 02-research-codebase.md
│   ├── 03-clarify.md
│   ├── 04-requirements-design.md
│   ├── 05-plan-slices.md
│   ├── 06-research-step.md
│   ├── 07-execute-step.md
│   ├── 08-review.md
│   └── 09-write-handoff.md
├── templates/                    # skeleton artifacts the stages fill in
│   ├── constitution.md
│   ├── requirements.md
│   ├── design.md
│   ├── eval-spec.md
│   ├── slice-plan.md
│   ├── step-spec.md
│   ├── knowledge.md
│   ├── handoff.md
│   ├── error-registry.md         # project-scoped bug memory, empty-seeded at stage 01, grown by Coder
│   └── hallucination-traps.md    # project-scoped wrong/right-pattern lookup, optionally seeded at stage 01
├── claude-md-template/           # target-project conventions (CLAUDE.md triad)
│   ├── CLAUDE.md
│   ├── tech-stack.md
│   ├── code-style.md
│   └── best-practices.md
├── skills/                       # pre-authored SKILL.md per stage — copied into .claude/skills/ at bootstrap
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
│   ├── domain-researcher.md
│   ├── codebase-explorer.md
│   ├── architect.md
│   ├── slice-planner.md
│   ├── step-researcher.md
│   ├── coder.md
│   ├── code-reviewer.md
│   ├── security-reviewer.md
│   ├── browser-verifier.md
│   └── handoff-writer.md
└── bootstrap/
    └── generate-claude-scaffolding.md   # meta-step: copies skills/ + agents/ into .claude/ and substitutes tokens
```

## Read-access matrix

Each subagent reads only what its job requires. The orchestrator enforces this in the dispatch prompt; the generated `.claude/hooks/restrict-reads.sh` enforces the load-bearing restrictions at runtime via a stage-marker file (`.claude/.state/current-stage`). See [`bootstrap/generate-claude-scaffolding.md`](bootstrap/generate-claude-scaffolding.md) and [`00-START-HERE.md`](00-START-HERE.md) § "Stage marker protocol". `grep` = keyword lookup only, not a cover-to-cover read.

| Agent | constitution | domain-research | tech-stack | code-style | best-practices | step-spec | knowledge | prev-handoff | diff | eval-spec | repo | error-registry | hallucination-traps |
|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| Domain-Researcher | v | — | — | — | — | — | — | — | — | — | — | writes (empty seed) | writes (optional seed) |
| Codebase-Explorer | v | — | — | — | — | — | — | — | — | — | v (read-only) | — | — |
| Architect | v | v | v | — | — | — | — | — | — | — | — | — | — |
| Slice-Planner | v | — | v | — | — | — | — | — | — | v | — | — | — |
| Step-Researcher | v | — | v | — | — | v | grep | — | — | — | — | grep | grep |
| Coder | v | — | v | v | v | v | v | v | — | — | v (scoped paths) | grep + append | grep + append |
| Coder + eval-harness | (same as Coder, plus reads `pipeline/07a-eval-harness.md` — only when step-spec has `(RED — eval)` sub-tasks) |
| Code-Reviewer | — | — | — | v | v | v | — | — | v | v (test-name column only) | — | — | — |
| Security-Reviewer | v | — | — | — | — | — | — | — | v | — | — | — | — |
| Browser-Verifier (end-of-feature only) | — | — | — | — | — | — | — | — | — | v | running app | — | — |
| Handoff-Writer | — | — | — | — | — | v | — | — | v | v | — | — | — |

## When this pipeline is wrong for the task

- Throwaway scripts, one-file tools, prototypes with <2 hours of work — the ceremony outweighs the value.
- Exploratory research code where the goal is learning, not shipping.
- Existing large codebases with strong established conventions — use only the review cluster and per-step research bits.


