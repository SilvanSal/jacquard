# Stage 11 — Iteration Loop

**Run by:** Orchestrator (triage) + appropriate subagents per track
**Enters after:** Stage 10 critique + sharing nudge (or user declines)
**Exits when:** User explicitly says "done", "that's all", "wrap up", or equivalent

## Purpose

Software doesn't end when the first feature ships. The iteration loop keeps the pipeline's guardrails active during ongoing development — bug fixes, refinements, enhancements, new capabilities — without forcing every two-line fix through 11 stages of ceremony.

The orchestrator triages each request into the right track, then executes just enough pipeline to maintain quality without wasting tokens.

## Entering the loop

After the Stage 10 critique and sharing nudge, the orchestrator transitions:

> Your feature is live. I'm here for whatever comes next — bugs, refinements, new ideas, optimizations. Just describe what you need and I'll figure out the fastest safe path to get it done.
>
> Say **"done"** whenever you want to wrap up.

Then wait for the user's next input. Every time the user describes a change, run the triage.

## Triage — the orchestrator's job

This is the load-bearing decision. Get it wrong and you either waste tokens (full pipeline for a typo fix) or lose quality (no research for something that touches domain logic). Think carefully.

**For every user request in the loop, the orchestrator MUST think through these questions before choosing a track:**

### Triage questions (evaluate all 6, in order)

1. **Scope — how many files will this likely touch?**
   - 1–2 files → leans Patch
   - 3–8 files → leans Enhancement
   - 8+ files or new directories → leans New Feature

2. **Domain surface — does this touch domain logic that was researched in Stage 01?**
   - No (pure infra, config, UI polish) → Patch or Enhancement
   - Yes, but within already-researched territory → Enhancement
   - Yes, and it enters un-researched domain territory → New Feature

3. **Architecture — does this require design decisions not already made?**
   - No, works within existing design.md → Patch or Enhancement
   - Extends existing architecture in a natural direction → Enhancement
   - Needs new architectural thinking (new data flows, new services, new integrations) → New Feature

4. **Existing coverage — does the current slice-plan account for this?**
   - It's fixing something already built → Patch
   - It's a natural extension of an existing slice → Enhancement
   - It's entirely outside the slice-plan's scope → Enhancement or New Feature

5. **Risk — what breaks if this is done wrong?**
   - Cosmetic or low-stakes → Patch
   - Could break existing functionality → Enhancement (needs review)
   - Could corrupt data, break security, or violate domain rules → Enhancement or New Feature (needs research)

6. **User's own framing — how did they describe it?**
   - "fix", "bug", "typo", "tweak", "adjust" → leans Patch
   - "add", "extend", "improve", "also make it..." → leans Enhancement
   - "new feature", "I also want...", "what about adding..." with significant scope → leans New Feature

### Decision rules

- **If ≥4 answers lean Patch** → Patch track
- **If ≥3 answers lean Enhancement** → Enhancement track
- **If ≥2 answers say New Feature, OR domain surface is un-researched, OR architecture needs new decisions** → New Feature track
- **When in doubt between Patch and Enhancement** → Enhancement (the cost of extra research is low; the cost of skipping it can be high)
- **When in doubt between Enhancement and New Feature** → ask the user: "This feels bigger than a quick enhancement — want me to do proper research and design for it, or keep it lightweight?"

### Communicating the triage

After deciding, tell the user which track and why — one sentence:

> "That's a patch — config-only change in one file. I'll fix it, get it reviewed, and we're done."

> "This is an enhancement — it touches the auth flow across a few files. I'll do targeted research, write a step-spec, build it, and get it reviewed."

> "This is a new feature — it needs domain research I haven't done yet. I'll spin up the full pipeline for it starting from research."

If the user disagrees with the triage, defer to them. They know their codebase.

---

## Track 1: Patch

**For:** Bug fixes, typos, config changes, small behavioral tweaks in ≤2 files.
**Time:** Minutes.
**Guardrails kept:** Review. Error-registry update (if bug fix).

### Flow

```
User describes fix
    │
    ▼
Orchestrator reads:
  - error-registry.md (grep for related entries)
  - hallucination-traps.md (grep for related patterns)
  - last relevant handoff.md (for context)
    │
    ▼
Dispatch Coder with:
  - The user's description
  - Relevant error-registry/hallucination-traps entries (if any)
  - The file(s) to modify (orchestrator identifies from description)
  - instruction: "Fix this. Commit when done."
    │
    ▼
Dispatch Code-Reviewer:
  - Reads the diff
  - Pass/block verdict
    │
    ▼
If pass → commit stands, update error-registry if bug fix
If block → Coder fixes, re-review
    │
    ▼
"Done. Anything else?"
```

**What's skipped:** Research-step, step-spec, knowledge.md, handoff.md, security review (unless the patch touches auth/crypto/input-handling — then security review runs too).

**Artifacts produced:**
- Commit(s)
- Error-registry entry (if bug fix)
- No handoff — patches are too small to warrant one

---

## Track 2: Enhancement

**For:** Extending existing functionality, adding behavior within the existing architecture, touching 3–8 files.
**Time:** One slice worth of work.
**Guardrails kept:** Research, step-spec, review, handoff. Full slice discipline.

### Flow

```
User describes enhancement
    │
    ▼
Drift check (same as pre-slice drift check in 00-START-HERE.md)
    │
    ▼
Stage 06: Research-step (Step-Researcher)
  - Reads existing design.md, relevant handoffs, error-registry
  - Produces step-spec.md + knowledge.md
  - Scoped to the enhancement, not the whole feature
    │
    ▼
Stage 07: Execute (Coder, TDD)
    │
    ▼
Stage 08: Review (Code-Reviewer + Security-Reviewer)
    │
    ▼
Stage 09: Handoff (Handoff-Writer)
    │
    ▼
"Done. Anything else?"
```

**Where artifacts go:** `specs/[feature]/slices/[N+1]/` — the enhancement gets the next slice number after the last shipped slice. The slice-plan.md gets a new entry appended (orchestrator writes: `- [N+1]: [description] (iteration-loop enhancement)`).

**What's skipped:** Domain research, architecture/design, slice planning ceremony. The existing design is assumed to be sufficient.

---

## Track 3: New Feature

**For:** New user-facing capabilities, un-researched domain surfaces, architectural changes.
**Time:** Multiple slices.
**Guardrails kept:** Everything. Full pipeline.

### Flow

The orchestrator determines the re-entry point:

- **If the domain is already researched** (the new feature is in a domain area covered by existing `input/research-findings/`):
  → Re-enter at Stage 03 (Clarify). Reuse existing domain research. New requirements, design, slice plan.

- **If the domain is NOT already researched** (new domain surface, new regulatory area, new technical territory):
  → Re-enter at Stage 01 (Research). Full domain research for the new area, then design, plan, build.

```
User describes new feature
    │
    ▼
Orchestrator decides re-entry point (01 or 03)
    │
    ▼
Run pipeline from that stage forward
(same as initial feature, with its own specs/[new-feature]/ directory)
    │
    ▼
Stage 10 critique (for the new feature)
    │
    ▼
Back to iteration loop: "Anything else?"
```

**Artifacts:** Gets its own `specs/[new-feature]/` directory. Completely separate from the original feature's artifacts.

---

## Loop behavior rules

1. **Always triage.** Never execute without deciding which track first. Even if it seems obvious, run through the 6 questions mentally.

2. **Patches don't accumulate without review.** Each patch gets reviewed before the next request is handled. No "I'll batch these."

3. **Enhancements update the slice-plan.** Every enhancement adds a new slice entry so the history stays traceable.

4. **Error-registry stays current.** Every bug fix (patch or enhancement) that reveals a pattern gets an error-registry entry.

5. **Hallucination-traps stays current.** If a patch reveals a wrong-pattern/right-pattern pair, append it.

6. **Context overflow in the loop.** Same protocol: write `specs/.pipeline-state/continue.md` with the current loop state (which track, what was requested, where in the track execution). The continuation file should note `loop-state: iteration` so the resuming orchestrator knows to re-enter the loop after completing the current track.

7. **Critique cadence.** If the user accumulates ≥3 enhancement-track iterations without a critique, the orchestrator may offer a lightweight critique run ("We've done a few rounds of changes — want me to do a quick pipeline health check?"). This is optional and soft — never block on it.

8. **Exit.** When the user says "done" / "that's all" / "wrap up":
   - If ≥1 enhancement or new-feature track was executed since the last critique: offer Stage 10 critique + sharing nudge.
   - If only patches: skip critique, just wrap up warmly.

---

## Triage examples

| User says | Track | Reasoning |
|---|---|---|
| "The date picker is off by one day" | Patch | Bug fix, likely 1 file, no domain research needed |
| "Can you make the export also include PDF format?" | Enhancement | Extends existing export feature, may touch 3-5 files, within existing architecture |
| "Add a notification system that emails users when their report is ready" | New Feature | New capability, likely needs research (email delivery, templates, queue), new architecture |
| "The error message is confusing, change it to say X" | Patch | Copy change, 1 file |
| "Also handle the case where the input has Unicode characters" | Enhancement | Behavioral extension, may need research into Unicode handling, touches validation + display |
| "I want to add a billing module with Stripe integration" | New Feature | Entirely new domain surface (payments), new architecture, needs research |
| "The tests are flaky on CI" | Enhancement | Could be simple but risk is high (CI stability), needs investigation/research |
| "Fix the typo in the footer" | Patch | 1 file, cosmetic |

---

## Orchestrator prompt for loop entry

After Stage 10 critique and nudge are complete, the orchestrator presents the loop entry message and waits. No subagent dispatch needed — the orchestrator handles triage directly, then dispatches the appropriate track.

## Stop condition

The iteration loop has no fixed stop condition. It runs until the user explicitly exits. The feature (and the orchestrator session) is truly complete only when the user says they're done.
