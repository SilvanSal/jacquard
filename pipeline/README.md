# Pipeline — Flow at a Glance

One-screen map of the 10 stages. For rules, read `pipeline/00-constitution.md` and the root [README.md](../README.md). For orchestrator behavior, read [00-START-HERE.md](../00-START-HERE.md).

## Stage DAG

```
                          ┌─────────────────────────┐
                          │  user brief + intent    │
                          └───────────┬─────────────┘
                                      ▼
  00  constitution            (orchestrator)        → specs/constitution.md
                                      │
                                      ▼
  01  research-domain         (Domain-Researcher)   → specs/research/domain.md
                                                      + specs/error-registry.md           (empty seed)
                                                      + specs/research/hallucination-traps.md (optional seed)
                                      │
                                      ▼
  02  research-codebase       (Codebase-Explorer)   → CLAUDE.md + tech-stack.md
                                                      + code-style.md + best-practices.md
                                      │
                                      ▼
  03  clarify                 (orchestrator ↔ user) → specs/clarify-[feature].md   ◄── USER GATE ("Go")
                                      │
                                      ▼
  04  requirements-design     (Architect)           → specs/[feature]/requirements.md
                                                      + design.md + eval-spec.md
                                      │
                                      ▼
  05  plan-slices             (Slice-Planner)       → specs/[feature]/slice-plan.md   ◄── USER GATE
                                      │
  ╔═══════════════════════════════════╪═══════════════════════════════════════════╗
  ║          per-slice loop           ▼             (one slice per session)        ║
  ║                                                                                ║
  ║  05.5 drift-check          (orchestrator)       halt-and-surface if repo drift ║
  ║                                   │             (skipped for slice 1)          ║
  ║                                   ▼                                            ║
  ║  06  research-step         (Step-Researcher)    → slices/[N]/step-spec.md      ║
  ║                                                 + knowledge.md                 ║
  ║                                                 (dedup-greps specs/ first)     ║
  ║                                   │                                            ║
  ║                                   ▼                                            ║
  ║  07  execute-step          (Coder, TDD)          → code + commits (RED/GREEN)   ║
  ║       07a eval-harness     (conditional read)    only if step-spec has evals   ║
  ║                                                 may append error-registry +    ║
  ║                                                 hallucination-traps            ║
  ║                                   │                                            ║
  ║                                   ▼                                            ║
  ║  08  review                ┌─ Code-Reviewer ─┐  → slices/[N]/review.md         ║
  ║                            └─ Security-Rev.  ┘  (parallel, fresh context)      ║
  ║                                   │                                            ║
  ║                                   ▼                                            ║
  ║  09  write-handoff         (Handoff-Writer)     → slices/[N]/handoff.md        ║
  ║                                   │                                            ║
  ║                                   ▼                                            ║
  ║                              ◆ STOP ◆  (new session picks up slice N+1)        ║
  ║                                                                                ║
  ╚════════════════════════════════════════════════════════════════════════════════╝
                                      │
                        (after final UI-touching slice)
                                      ▼
  end-of-feature              (Browser-Verifier)    → specs/[feature]/ui-verification.md
                                                    (only if UI + Chromium/Preview + dev server)
```

## Gates and stops

| Where | Who blocks | What unblocks |
|---|---|---|
| After stage 03 | User ("A/B/C/D" clarify answers) | User types "Go" |
| After stage 05 | User reviews slice-plan | User approves |
| Before stage 06 (N ≥ 2) | drift check halts if repo moved outside last slice's file list | User picks absorb / ignore / revert |
| After stage 08 | `block` verdict from Code- or Security-Reviewer | Return to stage 07 with fixes |
| After stage 09 | Session ends — no auto-chain | User starts new session for slice N+1 |
| End-of-feature | Browser-Verifier runs once (not per slice) | `fail` opens a remediation slice (re-run 05–09) |

## Artifacts by location

```
specs/
├── constitution.md                    ← stage 00
├── error-registry.md                  ← seeded 01, appended at 07
├── research/
│   ├── domain.md                      ← stage 01
│   └── hallucination-traps.md         ← optional at 01, appended at 07
├── clarify-[feature].md               ← stage 03
└── [feature]/
    ├── requirements.md                ← stage 04
    ├── design.md                      ← stage 04
    ├── eval-spec.md                   ← stage 04
    ├── slice-plan.md                  ← stage 05
    ├── ui-verification.md             ← end-of-feature
    └── slices/[N]/
        ├── step-spec.md               ← stage 06
        ├── knowledge.md               ← stage 06
        ├── review.md                  ← stage 08
        └── handoff.md                 ← stage 09

project root/
├── CLAUDE.md                          ← stage 02
├── tech-stack.md                      ← stage 02 (refined at 04)
├── code-style.md                      ← stage 02
└── best-practices.md                  ← stage 02
```

## Invariants (if you only remember five)

1. **Fresh context per stage.** No subagent inherits prior history; it reads a narrow named list.
2. **Stop-and-commit after every slice.** The handoff is the only thing the next session reads.
3. **Research before code.** No `Write`/`Edit` on application code until stages 00–06 are done for the current slice.
4. **Reviewers don't edit.** They write verdicts and text-only suggested-fixes. The Coder patches.
5. **Plan one slice ahead.** Don't pre-generate step-specs for future slices.

## Read-access matrix

Lives in the root [README.md § Read-access matrix](../README.md#read-access-matrix). Every dispatch prompt enforces a row from that table.
